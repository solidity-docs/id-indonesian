.. index:: optimizer, optimiser, common subexpression elimination, constant propagation
.. _optimizer:

*********
Optimizer
*********

Kompiler Solidity menggunakan dua modul pengoptimal yang berbeda: Pengoptimal "lama"
yang beroperasi pada tingkat opcode dan pengoptimal "baru" yang beroperasi pada kode Yul IR.

Pengoptimal berbasis opcode menerapkan serangkaian `aturan penyederhanaan <https://github.com/ethereum/solidity/blob/develop/libevmasm/RuleList.h>`_
untuk opcode. Ini juga menggabungkan set kode yang sama dan menghapus kode yang tidak digunakan.

Pengoptimal berbasis Yul jauh lebih kuat, karena dapat bekerja di seluruh panggilan fungsi. Misalnya, arbitrary jump
tidak dimungkinkan di Yul, jadi dimungkinkan untuk menghitung efek samping dari setiap fungsi. Pertimbangkan dua panggilan fungsi,
di mana yang pertama tidak mengubah penyimpanan dan yang kedua mengubah penyimpanan.
Jika argumen dan nilai pengembaliannya tidak bergantung satu sama lain, kita dapat menyusun
ulang pemanggilan fungsi.
Demikian pula, jika suatu fungsi bebas efek samping dan hasilnya dikalikan dengan nol, Anda dapat
menghapus panggilan fungsi sepenuhnya.

Saat ini, parameter ``--optimize`` mengaktifkan pengoptimal berbasis opcode untuk bytecode yang dihasilkan
dan pengoptimal Yuluntuk kode Yul yang dihasilkan secara internal, misalnya untuk ABI coder v2.
Seseorang dapat menggunakan ``solc --ir-optimized --optimize`` untuk menghasilkan Yul IR
eksperimental yang dioptimalkan untuk sumber Soliditas. Demikian pula, seseorang dapat menggunakan ``solc --strict-assembly --optimize`` untuk mode Yul stand-alone.

Anda dapat menemukan detail lebih lanjut tentang modul pengoptimal dan langkah pengoptimalannya di bawah.

Manfaat Mengoptimalkan Kode Solidity
====================================

Secara keseluruhan, pengoptimal mencoba menyederhanakan ekspresi rumit, yang mengurangi ukuran kode dan biaya eksekusi,
yaitu, dapat mengurangi gas yang dibutuhkan untuk penerapan kontrak serta untuk panggilan eksternal yang dilakukan ke kontrak.
Ini juga mengkhususkan atau inline fungsi. Khususnya function inlining adalah operasi yang
dapat menyebabkan kode yang jauh lebih besar, tetapi sering dilakukan karena menghasilkan
peluang untuk lebih banyak penyederhanaan.


Perbedaan antara Kode yang Dioptimalkan dan Tidak Dioptimalkan
==============================================================

Umumnya, perbedaan yang paling terlihat adalah ekspresi konstan dievaluasi pada waktu kompilasi.
Ketika datang ke output ASM, kita juga dapat melihat pengurangan blok kode yang setara atau duplikat
(bandingkan output dari flag ``--asm`` dan ``--asm --optimize``). Namun,
ketika menyangkut Yul/representasi menengah, mungkin ada perbedaan
yang signifikan, misalnya, fungsi dapat disejajarkan, digabungkan, atau ditulis ulang untuk menghilangkan
redundansi, dll. (bandingkan output antara flag ``--ir`` dan
``--optimize --ir-optimized``).

.. _optimizer-parameter-runs:

Optimizer Parameter Runs
========================

Jumlah proses (``--optimize-runs``) menentukan secara kasar seberapa sering setiap opcode dari kode yang
di-deploy akan dieksekusi sepanjang masa kontrak. Ini berarti ini adalah parameter trade-off antara
ukuran kode (biaya penerapan) dan biaya eksekusi kode (biaya setelah penerapan).
Parameter "berjalan" dari "1" akan menghasilkan kode yang pendek tapi mahal. Sebaliknya, parameter "run"
yang lebih besar akan menghasilkan kode yang lebih lama tetapi lebih hemat gas. Nilai maksimum parameter
adalah ``2**32-1``.

.. note::

    Kesalahpahaman yang umum adalah bahwa parameter ini menentukan jumlah iterasi pengoptimal.
    Ini tidak benar: Pengoptimal akan selalu berjalan sesering yang masih dapat meningkatkan kode.

Modul Opcode-Based Optimizer
============================

Modul pengoptimal berbasis opcode beroperasi pada kode perakitan. Ini membagi
urutan instruksi menjadi blok dasar di ``JUMPs`` dan ``JUMPDESTs``.
Di dalam blok-blok ini, pengoptimal menganalisis instruksi dan mencatat setiap modifikasi pada stack,
memori, atau storage sebagai ekspresi yang terdiri dari instruksi dan
daftar argumen yang merupakan penunjuk ke ekspresi lain.

Selain itu, pengoptimal berbasis opcode
menggunakan komponen yang disebut "CommonSubexpressionEliminator" yang di antara
tugas-tugas lainnya, menemukan ekspresi yang selalu sama (pada setiap input) dan menggabungkannya
ke dalam kelas ekspresi. Ini pertama kali mencoba menemukan setiap ekspresi baru
dalam daftar ekspresi yang sudah dikenal. Jika tidak ada kecocokan seperti itu yang ditemukan,
ekspresi akan disederhanakan menurut aturan seperti ``constant + constant = sum_of_constants`` atau ``X * 1 = X``. Karena ini adalah
proses rekursif, kita juga dapat menerapkan aturan yang terakhir jika faktor kedua adalah ekspresi yang
lebih kompleks yang kita tahu selalu bernilai satu.

Langkah-langkah pengoptimal tertentu secara simbolis melacak lokasi penyimpanan dan memori. Misalnya, informasi
ini digunakan untuk menghitung hash Keccak-256 yang dapat dievaluasi selama waktu kompilasi. Pertimbangkan
urutannya:

.. code-block:: none

    PUSH 32
    PUSH 0
    CALLDATALOAD
    PUSH 100
    DUP2
    MSTORE
    KECCAK256

atau yul yang setara

.. code-block:: yul

    let x := calldataload(0)
    mstore(x, 100)
    let value := keccak256(x, 32)

Dalam hal ini, pengoptimal melacak nilai di lokasi memori ``calldataload(0)`` lalu
menyadari bahwa hash Keccak-256 dapat dievaluasi pada waktu kompilasi. Ini hanya berfungsi jika tidak ada
instruksi lain yang memodifikasi memori antara ``mstore`` dan ``keccak256``. Jadi jika ada
instruksi yang menulis ke memori (atau penyimpanan), maka kita perlu menghapus pengetahuan memori
saat ini (atau storage). Namun, ada pengecualian untuk penghapusan ini, ketika kita dapat dengan mudah melihat
instruksi tidak menulis ke lokasi tertentu.

Sebagai contoh,

.. code-block:: yul

    let x := calldataload(0)
    mstore(x, 100)
    // Current knowledge memory location x -> 100
    let y := add(x, 32)
    // Does not clear the knowledge that x -> 100, since y does not write to [x, x + 32)
    mstore(y, 200)
    // This Keccak-256 can now be evaluated
    let value := keccak256(x, 32)

Oleh karena itu, modifikasi lokasi penyimpanan dan memori, misalnya lokasi ``l``, harus menghapus
pengetahuan tentang penyimpanan atau lokasi memori yang mungkin sama dengan ``l``. Lebih khusus lagi, untuk
penyimpanan, pengoptimal harus menghapus semua pengetahuan tentang lokasi simbolis, yang mungkin sama dengan ``l``
dan untuk memori, pengoptimal harus menghapus semua pengetahuan tentang lokasi simbolis yang mungkin tidak
berjarak setidaknya 32 byte. Jika ``m`` menunjukkan lokasi arbitrer, maka keputusan penghapusan ini dilakukan dengan
menghitung nilai ``sub(l, m)``. Untuk penyimpanan, jika nilai ini dievaluasi ke literal yang bukan nol, maka
pengetahuan tentang ``m`` akan disimpan. Untuk memori, jika nilai dievaluasi ke literal antara ``32`` dan ``2**256 - 32``, maka pengetahuan tentang ``m`` akan disimpan.
Dalam semua kasus lain, pengetahuan tentang ``m`` akan dihapus.

Setelah proses ini, kita tahu ekspresi mana yang harus ada di stack
di akhir, dan memiliki daftar modifikasi pada memori dan penyimpanan. Informasi ini
disimpan bersama dengan blok dasar dan digunakan untuk menghubungkannya. Selanjutnya,
pengetahuan tentang konfigurasi stack, penyimpanan, dan memori diteruskan ke
blok berikutnya.

Jika kita mengetahui target dari semua instruksi ``JUMP`` dan ``JUMPI``,
kita dapat membangun grafik aliran kendali program yang lengkap. Jika hanya ada satu
target yang tidak kita ketahui (hal ini dapat terjadi karena pada prinsipnya, target jump dapat
dihitung dari input), kita harus menghapus semua pengetahuan tentang state input
dari suatu blok karena dapat menjadi target yang tidak diketahui ``JUMP``. Jika modul pengoptimal berbasis opcode
menemukan ``JUMPI`` yang kondisinya dievaluasi menjadi konstan, modul tersebut mengubahnya
menjadi lompatan tanpa syarat.

Sebagai langkah terakhir, kode di setiap blok dibuat ulang. Pengoptimal membuat
grafik dependency dari ekspresi pada tumpukan di akhir blok,
dan menghapus setiap operasi yang bukan bagian dari grafik ini. Ini menghasilkan kode
yang menerapkan modifikasi pada memori dan penyimpanan dalam urutan yang dibuat
dalam kode asli (menjatuhkan modifikasi yang ditemukan tidak diperlukan). Akhirnya,
itu menghasilkan semua nilai yang diperlukan untuk berada dalam stack di tempat yang benar.

Langkah-langkah ini diterapkan pada setiap blok dasar dan kode yang baru dibuat digunakan
sebagai pengganti jika lebih kecil. Jika blok dasar dipecah pada ``JUMPI`` dan selama analisis,
kondisinya dievaluasi menjadi konstanta, ``JUMPI`` diganti berdasarkan nilai konstanta. Jadi kode seperti

.. code-block:: solidity

    uint x = 7;
    data[7] = 9;
    if (data[x] != x + 2) // this condition is never true
      return 2;
    else
      return 1;

disederhanakan menjadi ini:

.. code-block:: solidity

    data[7] = 9;
    return 1;

Simple Inlining
---------------

Sejak Solidity versi 0.8.2, ada langkah pengoptimal lain yang menggantikan lompatan tertentu ke blok yang
berisi instruksi "sederhana" yang diakhiri dengan "lompatan" dengan salinan instruksi ini.
Ini sesuai dengan inlining fungsi Solidity atau Yul yang sederhana dan kecil. Secara khusus, urutan
``PUSHTAG(tag) JUMP`` dapat diganti, setiap kali ``JUMP`` ditandai sebagai lompat "ke" suatu fungsi
dan di belakang ``tag`` terdapat blok dasar (seperti dijelaskan di atas untuk "CommonSubexpressionEliminator")
yang diakhiri dengan ``JUMP`` lain yang ditandai sebagai lompatan "keluar dari" suatu fungsi.

Secara khusus, pertimbangkan contoh prototipe assembly berikut yang dihasilkan untuk
panggilan ke fungsi Solidity internal:

.. code-block:: text

      tag_return
      tag_f
      jump      // in
    tag_return:
      ...opcodes after call to f...

    tag_f:
      ...body of function f...
      jump      // out

Selama isi fungsi adalah blok dasar kontinu, "Inliner" dapat menggantikan ``tag_f jump`` dengan
blok di ``tag_f`` menghasilkan:

.. code-block:: text

      tag_return
      ...body of function f...
      jump
    tag_return:
      ...opcodes after call to f...

    tag_f:
      ...body of function f...
      jump      // out

Sekarang idealnya, langkah-langkah pengoptimal lain yang dijelaskan di atas akan mengakibatkan dorongan tag kembali dipindahkan
menuju lompatan yang tersisa menghasilkan:

.. code-block:: text

      ...body of function f...
      tag_return
      jump
    tag_return:
      ...opcodes after call to f...

    tag_f:
      ...body of function f...
      jump      // out

Dalam situasi ini "PeepholeOptimizer" akan menghapus lompatan kembali. Idealnya, semua ini bisa dilakukan
untuk semua referensi ke ``tag_f`` membiarkannya tidak digunakan, s.t. itu dapat dihapus, menghasilkan:

.. code-block:: text

    ...body of function f...
    ...opcodes after call to f...

Jadi panggilan ke fungsi ``f`` disejajarkan dan definisi asli ``f`` dapat dihapus.

Inlining seperti ini dicoba, setiap kali heuristik menunjukkan bahwa inlining lebih murah selama
masa kontrak daripada tidak inlining. Heuristik ini bergantung pada ukuran badan fungsi, jumlah
referensi lain ke tagnya (mendekati jumlah panggilan ke fungsi) dan
jumlah eksekusi kontrak yang diharapkan (parameter pengoptimal global "berjalan").


Modul Yul-Based Optimizer
=========================

Pengoptimal berbasis Yul terdiri dari beberapa tahap dan komponen yang semuanya mengubah AST
dengan cara yang setara secara semantik. Tujuannya adalah untuk mendapatkan kode yang lebih pendek atau setidaknya
hanya sedikit lebih panjang tetapi akan memungkinkan
langkah pengoptimalan lebih lanjut.

.. warning::

    Karena pengoptimal sedang dalam pengembangan yang berat, informasi di sini mungkin sudah usang.
    Jika Anda mengandalkan fungsi tertentu, hubungi tim secara langsung.

Pengoptimal saat ini mengikuti strategi murni serakah dan tidak melakukan backtracking.

Semua komponen modul pengoptimal berbasis Yul dijelaskan di bawah ini.
Langkah-langkah transformasi berikut adalah komponen utama:

- SSA Transform
- Common Subexpression Eliminator
- Expression Simplifier
- Redundant Assign Eliminator
- Full Inliner

Optimizer Step
--------------

Ini adalah daftar semua langkah pengoptimal berbasis Yul yang diurutkan berdasarkan abjad. Anda dapat menemukan informasi
lebih lanjut tentang masing-masing langkah dan urutannya di bawah ini.

- :ref:`block-flattener`.
- :ref:`circular-reference-pruner`.
- :ref:`common-subexpression-eliminator`.
- :ref:`conditional-simplifier`.
- :ref:`conditional-unsimplifier`.
- :ref:`control-flow-simplifier`.
- :ref:`dead-code-eliminator`.
- :ref:`equivalent-function-combiner`.
- :ref:`expression-joiner`.
- :ref:`expression-simplifier`.
- :ref:`expression-splitter`.
- :ref:`for-loop-condition-into-body`.
- :ref:`for-loop-condition-out-of-body`.
- :ref:`for-loop-init-rewriter`.
- :ref:`expression-inliner`.
- :ref:`full-inliner`.
- :ref:`function-grouper`.
- :ref:`function-hoister`.
- :ref:`function-specializer`.
- :ref:`literal-rematerialiser`.
- :ref:`load-resolver`.
- :ref:`loop-invariant-code-motion`.
- :ref:`redundant-assign-eliminator`.
- :ref:`reasoning-based-simplifier`.
- :ref:`rematerialiser`.
- :ref:`SSA-reverser`.
- :ref:`SSA-transform`.
- :ref:`structural-simplifier`.
- :ref:`unused-function-parameter-pruner`.
- :ref:`unused-pruner`.
- :ref:`var-decl-initializer`.

Meimilih Optimizations
-----------------------

Secara default, pengoptimal menerapkan urutan langkah pengoptimalan yang telah ditentukan sebelumnya
ke rakitan yang dihasilkan. Anda dapat mengganti urutan ini dan menyediakan urutan Anda sendiri menggunakan
opsi ``--yul-optimizations``:

.. code-block:: bash

    solc --optimize --ir-optimized --yul-optimizations 'dhfoD[xarrscLMcCTU]uljmul'

Urutan di dalam ``[...]`` akan diterapkan beberapa kali dalam satu lingkaran hingga kode Yul tetap tidak berubah
atau hingga jumlah putaran maksimum (saat ini 12) telah tercapai.

Singkatan yang tersedia tercantum dalam `Yul optimizer docs <yul.rst#optimization-step-sequence>`_.

Preprocessing
-------------

Komponen preprocessing melakukan transformasi untuk membuat program
menjadi bentuk normal tertentu yang lebih mudah untuk dikerjakan. Bentuk normal
ini disimpan selama sisa proses optimasi.

.. _disambiguator:

Disambiguator
^^^^^^^^^^^^^

Disambiguator mengambil AST dan mengembalikan salinan baru di mana semua pengidentifikasi
memiliki nama unik di AST input. Ini adalah prasyarat untuk semua tahap pengoptimal lainnya.
Salah satu manfaatnya adalah pencarian identifier tidak perlu memperhitungkan cakupan yang
menyederhanakan analisis yang diperlukan untuk langkah-langkah lain.

Semua tahapan selanjutnya memiliki properti bahwa semua nama tetap unik. Ini berarti jika
identifier baru perlu diperkenalkan, nama unik baru akan dibuat.

.. _function-hoister:

FunctionHoister
^^^^^^^^^^^^^^^

Function hoister memindahkan semua definisi fungsi ke ujung blok paling atas. Ini adalah
transformasi ekuivalen semantik asalkan dilakukan setelah tahap disambiguasi. Alasannya
adalah bahwa memindahkan definisi ke blok tingkat yang lebih tinggi tidak dapat mengurangi visibilitasnya
dan tidak mungkin untuk merujuk variabel yang didefinisikan dalam fungsi yang berbeda.

Manfaat dari tahap ini adalah definisi fungsi dapat dicari dengan lebih mudah
dan fungsi dapat dioptimalkan secara terpisah tanpa harus melintasi AST sepenuhnya.

.. _function-grouper:

FunctionGrouper
^^^^^^^^^^^^^^^

Fungsi grouper harus diterapkan setelah disambiguator dan function hoister.
Efeknya adalah semua elemen teratas yang bukan definisi fungsi dipindahkan
menjadi satu blok yang merupakan pernyataan pertama dari blok root.

Setelah langkah ini, sebuah program memiliki bentuk normal berikut:

.. code-block:: text

    { I F... }

Di mana ``I`` adalah blok (berpotensi kosong) yang tidak mengandung definisi fungsi apa pun (bahkan tidak secara rekursif)
dan ``F`` adalah daftar definisi fungsi sehingga tidak ada fungsi yang berisi definisi fungsi.

Manfaat dari tahap ini adalah kita selalu tahu di mana daftar fungsi dimulai.

.. _for-loop-condition-into-body:

ForLoopConditionIntoBody
^^^^^^^^^^^^^^^^^^^^^^^^

Transformasi ini memindahkan kondisi loop-iterasi dari for-loop ke badan loop.
Kita membutuhkan transformasi ini karena :ref:`expression-splitter` tidak akan
berlaku untuk ekspresi kondisi iterasi (``C`` dalam contoh berikut).

.. code-block:: text

    for { Init... } C { Post... } {
        Body...
    }

diubah menjadi

.. code-block:: text

    for { Init... } 1 { Post... } {
        if iszero(C) { break }
        Body...
    }

Transformasi ini juga dapat berguna saat dipasangkan dengan ``LoopInvariantCodeMotion``, karena
invarian dalam kondisi loop-invarian kemudian dapat diambil di luar loop.

.. _for-loop-init-rewriter:

ForLoopInitRewriter
^^^^^^^^^^^^^^^^^^^

Transformasi ini memindahkan bagian inisialisasi dari for-loop ke sebelum loop:

.. code-block:: text

    for { Init... } C { Post... } {
        Body...
    }

diubah menjadi

.. code-block:: text

    Init...
    for {} C { Post... } {
        Body...
    }

Ini memudahkan proses pengoptimalan lainnya karena kita dapat mengabaikan
aturan pelingkupan rumit dari blok untuk inisialisasi loop.

.. _var-decl-initializer:

VarDeclInitializer
^^^^^^^^^^^^^^^^^^
Langkah ini menulis ulang deklarasi variabel sehingga semuanya diinisialisasi.
Deklarasi seperti ``let x, y`` dipecah menjadi beberapa pernyataan deklarasi

Hanya mendukung inisialisasi dengan nol literal untuk saat ini.

Pseudo-SSA Transformation
-------------------------

Tujuan dari komponen ini adalah untuk membuat program menjadi bentukyang
lebih panjang, sehingga komponen lain dapat lebih mudah bekerja dengannya.
Representasi akhir akan mirip dengan bentuk static-single-assignment (SSA),
dengan perbedaan bahwa itu tidak menggunakan fungsi "phi" eksplisit yang
menggabungkan nilai dari cabang aliran kontrol yang berbeda karena fitur
seperti itu tidak ada dalam bahasa Yul. Sebagai gantinya, ketika aliran
kontrol bergabung, jika variabel ditetapkan kembali di salah satu cabang,
variabel SSA baru dideklarasikan untuk mempertahankan nilainya saat ini,
sehingga ekspresi berikut masih hanya perlu merujuk variabel SSA.

Contoh transformasinya adalah sebagai berikut:

.. code-block:: yul

    {
        let a := calldataload(0)
        let b := calldataload(0x20)
        if gt(a, 0) {
            b := mul(b, 0x20)
        }
        a := add(a, 1)
        sstore(a, add(b, 0x20))
    }


Ketika semua langkah transformasi berikut diterapkan, program akan terlihat sebagai berikut:

.. code-block:: yul

    {
        let _1 := 0
        let a_9 := calldataload(_1)
        let a := a_9
        let _2 := 0x20
        let b_10 := calldataload(_2)
        let b := b_10
        let _3 := 0
        let _4 := gt(a_9, _3)
        if _4
        {
            let _5 := 0x20
            let b_11 := mul(b_10, _5)
            b := b_11
        }
        let b_12 := b
        let _6 := 1
        let a_13 := add(a_9, _6)
        let _7 := 0x20
        let _8 := add(b_12, _7)
        sstore(a_13, _8)
    }

Perhatikan bahwa satu-satunya variabel yang ditetapkan ulang dalam cuplikan ini adalah ``b``.
Penetapan ulang ini tidak dapat dihindari karena ``b`` memiliki nilai yang berbeda tergantung
pada aliran kontrol. Semua variabel lain tidak pernah mengubah nilainya setelah didefinisikan.
Keuntungan dari properti ini adalah bahwa variabel dapat dengan bebas dipindahkan dan referensi
untuk mereka dapat ditukar dengan nilai awal mereka (dan sebaliknya), selama nilai-nilai ini masih
berlaku dalam konteks baru.

Tentu saja, kode di sini masih jauh dari optimal. Sebaliknya, itu jauh lebih lama. Harapannya adalah
kode ini akan lebih mudah untuk dikerjakan dan selanjutnya, ada langkah-langkah pengoptimal yang membatalkan
perubahan ini dan membuat kode lebih kompak lagi di akhir.

.. _expression-splitter:

ExpressionSplitter
^^^^^^^^^^^^^^^^^^

Pembagi ekspresi mengubah ekspresi seperti ``add(mload(0x123), mul(mload(0x456), 0x20))``
menjadi urutan deklarasi variabel unik yang diberi sub-ekspresi dari ekspresi itu sehingga
setiap pemanggilan fungsi memiliki hanya variabel atau literal sebagai argumen.

Di atas akan diubah menjadi

.. code-block:: yul

    {
        let _1 := mload(0x123)
        let _2 := mul(_1, 0x20)
        let _3 := mload(0x456)
        let z := add(_3, _2)
    }

Perhatikan bahwa transformasi ini tidak mengubah urutan opcode atau panggilan fungsi.

Ini tidak diterapkan pada kondisi iterasi loop, karena aliran kontrol loop tidak mengizinkan "outlining"
ini dari ekspresi dalam dalam semua kasus. Kita dapat menghindari batasan ini dengan menerapkan
:ref:`for-loop-condition-into-body` untuk memindahkan kondisi iterasi ke dalam loop body.

Program akhir harus dalam bentuk sedemikian rupa (dengan pengecualian kondisi loop)
panggilan fungsi tidak dapat muncul bersarang di dalam ekspresi
dan semua argumen pemanggilan fungsi harus berupa literal atau variabel.

Manfaat dari formulir ini adalah lebih mudah untuk mengurutkan ulang urutan opcode
dan juga lebih mudah untuk melakukan inlining panggilan fungsi. Selain itu, lebih sederhana
untuk mengganti bagian individu dari ekspresi atau mengatur ulang "pohon ekspresi".
Kekurangannya adalah bahwa kode tersebut jauh lebih sulit untuk dibaca oleh manusia.

.. _SSA-transform:

SSATransform
^^^^^^^^^^^^

Tahap ini mencoba mengganti penugasan yang berulang-ulang menjadi
variabel yang ada dengan deklarasi variabel baru sebanyak
mungkin.
Penugasan kembali masih ada, tetapi semua referensi ke
variabel yang ditugaskan kembali digantikan oleh variabel yang baru dideklarasikan.

Contoh:

.. code-block:: yul

    {
        let a := 1
        mstore(a, 2)
        a := 3
    }

diubah menjadi

.. code-block:: yul

    {
        let a_1 := 1
        let a := a_1
        mstore(a_1, 2)
        let a_3 := 3
        a := a_3
    }

Semantik yang tepat:

Untuk setiap variabel ``a`` yang ditetapkan ke suatu tempat dalam kode
(variabel yang dideklarasikan dengan nilai dan tidak pernah ditetapkan ulang
tidak dimodifikasi) lakukan transformasi berikut:

- ganti ``let a := v`` dengan ``let a_i := v   let a := a_i``
- ganti ``a := v`` dengan ``let a_i := v   a := a_i`` dimana ``i`` adalah angka sedemikian rupa sehingga ``a_i`` belum digunakan.

Selanjutnya, selalu catat nilai ``i`` saat ini yang digunakan untuk ``a`` dan ganti masing-masing
referensi ke ``a`` dengan ``a_i``.
Nilai mapping saat ini dihapus untuk variabel ``a`` di akhir setiap blok
di mana itu ditugaskan ke dan di akhir blok for loop init jika ditugaskan
di dalam for loop body atau post block.
Jika nilai variabel dihapus sesuai dengan aturan di atas dan variabel dideklarasikan di luar
blok, variabel SSA baru akan dibuat di lokasi di mana aliran kontrol bergabung,
ini termasuk awal dari loop post/body block dan lokasi tepat setelahnya
Pernyataan If/Switch/ForLoop/Block.

Setelah tahap ini, Redundant Assign Eliminator direkomendasikan untuk
menghapus tugas perantara yang tidak perlu.

Tahap ini memberikan hasil terbaik jika Expression Splitter dan Common Subexpression Eliminator
dijalankan tepat sebelum itu, karena itu tidak menghasilkan jumlah variabel yang berlebihan.
Di sisi lain, Eliminator Subekspresi Umum bisa lebih efisien jika dijalankan setelah
transformasi SSA.

.. _redundant-assign-eliminator:

RedundantAssignEliminator
^^^^^^^^^^^^^^^^^^^^^^^^^

Transformasi SSA selalu menghasilkan penugasan dalam bentuk ``a := a_i``, meskipun
ini mungkin tidak diperlukan dalam banyak kasus, seperti contoh berikut:

.. code-block:: yul

    {
        let a := 1
        a := mload(a)
        a := sload(a)
        sstore(a, 1)
    }

Transformasi SSA mengonversi cuplikan ini menjadi yang berikut:

.. code-block:: yul

    {
        let a_1 := 1
        let a := a_1
        let a_2 := mload(a_1)
        a := a_2
        let a_3 := sload(a_2)
        a := a_3
        sstore(a_3, 1)
    }

Redundant Assign Eliminator menghapus ketiga penetapan ke ``a``, karena
nilai ``a`` tidak digunakan dan dengan demikian mengubah snippet ini menjadi bentuk strict SSA:

.. code-block:: yul

    {
        let a_1 := 1
        let a_2 := mload(a_1)
        let a_3 := sload(a_2)
        sstore(a_3, 1)
    }

Tentu saja bagian-bagian rumit untuk menentukan apakah suatu penugasan berlebihan atau tidak terhubung
dengan aliran kontrol yang bergabung.

Komponen bekerja sebagai berikut secara rinci:

AST dilalui dua kali: dalam langkah pengumpulan informasi dan dalam langkah
penghapusan yang sebenarnya. Selama pengumpulan informasi, kami mempertahankan
mapping dari pernyataan penugasan ke tiga state "unused", "undecided" dan "used"
yang menandakan apakah nilai yang ditetapkan akan digunakan nanti dengan referensi ke variabel.

Ketika sebuah assignment dikunjungi, assignment itu ditambahkan ke mapping dalam status "undecided" (lihat komentar tentang for loop di bawah) dan setiap tugas lainnya ke variabel yang sama yang masih dalam status "undecided" diubah menjadi "unused".
Ketika sebuah variabel direferensikan, status penugasan apa pun ke variabel itu yang masih dalam status "undecided" diubah menjadi "used".

Pada titik di mana aliran kontrol terpecah, salinan mapping diserahkan ke setiap cabang. Pada titik di mana aliran kontrol bergabung, dua pemetaan yang berasal dari dua cabang digabungkan dengan cara berikut:
Pernyataan yang hanya dalam satu pemetaan atau memiliki status yang sama digunakan tidak berubah.
Nilai-nilai yang bertentangan diselesaikan dengan cara berikut:

- "unused", "undecided" -> "undecided"
- "unused", "used" -> "used"
- "undecided, "used" -> "used"

Untuk for-loop, condition, bodi dan post-part dikunjungi dua kali, dengan memperhitungkan aliran
kontrol penyambungan pada condition.
Dengan kata lain, kami membuat tiga jalur aliran kontrol: Zero run dari loop, satu run dan dua run
dan kemudian menggabungkannya di akhir.

Mensimulasikan putaran ketiga atau bahkan lebih tidak diperlukan, yang dapat dilihat sebagai berikut:

Keadaan penugasan pada awal iterasi secara deterministik akan menghasilkan keadaan penugasan tersebut
pada akhir iterasi.
Biarkan fungsi mapping keadaan ini disebut ``f``. Kombinasi dari tiga state berbeda ``unused``, ``undecided``
dan ``used`` seperti yang dijelaskan di atas adalah operasi ``max`` di mana ``unused = 0``, ``undecided = 1` ` dan ``digunakan = 2``.

Cara yang tepat adalah dengan menghitung

.. code-block:: none

    max(s, f(s), f(f(s)), f(f(f(s))), ...)

sebagai status setelah loop. Karena ``f`` hanya memiliki rentang tiga nilai yang berbeda,
iterasi itu harus mencapai siklus setelah paling banyak tiga iterasi,
dan dengan demikian ``f(f(f(s)))`` harus sama dengan salah satu dari ``s``, ``f(s)``, atau ``f(f(s))``
dan dengan demikian

.. code-block:: none

    max(s, f(s), f(f(s))) = max(s, f(s), f(f(s)), f(f(f(s))), ...).

Singkatnya, menjalankan loop paling banyak dua kali sudah cukup karena hanya ada tiga
state yang berbeda.

Untuk pernyataan switch yang memiliki kasus "default", tidak ada bagian aliran
kontrol yang melewatkan switch.

Ketika sebuah variabel keluar dari ruang lingkup, semua pernyataan masih dalam "undecided"
status diubah menjadi "unused", kecuali variabelnya adalah pengembalian
parameter suatu fungsi - di sana, statusnya berubah menjadi "used".

Dalam traversal kedua, semua penetapan yang berada dalam status "unused" dihapus.

Langkah ini biasanya dijalankan tepat setelah transformasi SSA selesai
generasi pseudo-SSA.

Tool
----

Movability
^^^^^^^^^^

Movability adalah properti dari sebuah ekspresi. Ini secara kasar berarti bahwa ekspresi
bebas efek samping dan evaluasinya hanya bergantung pada nilai variabel
dan call-constant state dari environment. Sebagian besar ekspresi dapat dipindahkan.
Bagian berikut membuat ekspresi tidak dapat dipindahkan:

- panggilan fungsi (mungkin santai di masa mendatang jika semua pernyataan dalam fungsi dapat dipindahkan)
- opcode yang (dapat) memiliki efek samping (seperti ``call`` atau ``selfdestruct``)
- opcode yang membaca atau menulis memori, penyimpanan, atau informasi status eksternal
- opcode yang bergantung pada PC saat ini, ukuran memori, atau ukuran data yang dikembalikan

DataflowAnalyzer
^^^^^^^^^^^^^^^^

Dataflow Analyzer bukanlah langkah pengoptimal itu sendiri tetapi digunakan sebagai
alat oleh komponen lain. Saat melintasi AST, ia melacak nilai saat ini dari setiap variabel,
selama nilai itu adalah ekspresi yang dapat dipindahkan. Ini merekam variabel yang merupakan
bagian dari ekspresi yang saat ini ditetapkan untuk satu sama lain variabel. Pada setiap penugasan
ke variabel ``a``, nilai tersimpan saat ini dari ``a`` diperbarui dan semua nilai tersimpan dari
semua variabel ``b`` dihapus setiap kali ``a`` adalah bagian dari yang saat ini disimpan ekspresi untuk ``b``.

Pada gabungan aliran kontrol, pengetahuan tentang variabel dihapus jika variabel tersebut telah
atau akan ditetapkan di salah satu jalur aliran kontrol. Misalnya, saat memasuki perulangan for,
semua variabel dihapus yang akan ditetapkan selama blok isi atau pos.

Expression-Scale Simplifications
--------------------------------

These simplification passes change expressions and replace them by equivalent
and hopefully simpler expressions.

.. _common-subexpression-eliminator:

CommonSubexpressionEliminator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Langkah ini menggunakan Dataflow Analyzer dan mengganti subekspresi yang secara sintaksis cocok
dengan nilai variabel saat ini dengan referensi ke variabel tersebut. Ini adalah transformasi ekuivalensi
karena subekspresi tersebut harus dapat dipindahkan.

Semua subekspresi yang merupakan pengidentifikasi itu sendiri diganti dengan nilainya saat ini jika
nilainya adalah pengidentifikasi.

Kombinasi kedua aturan di atas memungkinkan untuk menghitung penomoran nilai lokal, yang berarti
bahwa jika dua variabel memiliki nilai yang sama, salah satunya akan selalu tidak digunakan. Pemangkas
yang Tidak Digunakan atau
Redundant Assign Eliminator kemudian akan dapat sepenuhnya menghilangkan variabel tersebut.

Langkah ini sangat efisien jika pemisah ekspresi dijalankan sebelumnya. Jika kode dalam bentuk pseudo-SSA,
nilai-nilai variabel tersedia untuk waktu yang lebih lama dan dengan demikian kami memiliki peluang ekspresi yang lebih tinggi untuk dapat diganti.

Penyederhanaan ekspresi akan dapat melakukan penggantian yang lebih baik jika eliminator subekspresi umum dijalankan tepat sebelumnya.

.. _expression-simplifier:

Expression Simplifier
^^^^^^^^^^^^^^^^^^^^^

Expression Simplifier menggunakan Dataflow Analyzer dan menggunakan daftar transformasi
ekivalensi pada ekspresi seperti ``X + 0 -> X`` untuk menyederhanakan kode.

Ia mencoba mencocokkan pola seperti ``X + 0`` pada setiap subekspresi.
Selama prosedur pencocokan, ini menyelesaikan variabel ke ekspresi yang saat ini ditetapkan
untuk dapat mencocokkan pola bersarang lebih dalam bahkan ketika kode dalam bentuk pseudo-SSA.

Beberapa pola seperti ``X - X -> 0`` hanya dapat diterapkan selama ekspresi ``X`` dapat dipindahkan,
karena jika tidak, akan menghilangkan potensi efek sampingnya.
Karena referensi variabel selalu dapat dipindahkan, bahkan jika nilainya saat ini mungkin tidak,
Penyederhanaan Ekspresi sekali lagi lebih kuat dalam bentuk split atau pseudo-SSA.

.. _literal-rematerialiser:

LiteralRematerialiser
^^^^^^^^^^^^^^^^^^^^^

Untuk didokumentasikan.

.. _load-resolver:

LoadResolver
^^^^^^^^^^^^

Tahap pengoptimalan yang menggantikan ekspresi tipe ``sload(x)`` dan ``mload(x)``
dengan nilai yang saat ini disimpan dalam storage resp. memori, jika diketahui.

Bekerja paling baik jika kode dalam bentuk SSA.

Prasyarat: Disambiguator, ForLoopInitRewriter.

.. _reasoning-based-simplifier:

ReasoningBasedSimplifier
^^^^^^^^^^^^^^^^^^^^^^^^

Pengoptimal ini menggunakan pemecah SMT untuk memeriksa apakah kondisi ``if`` konstan.

- Jika `` constraints AND condition`` adalah UNSAT, kondisi tidak pernah benar dan seluruh tubuh dapat dihilangkan.
- Jika ``constraint AND NOT condition`` adalah UNSAT, kondisinya selalu benar dan dapat diganti dengan ``1``.

Penyederhanaan di atas hanya dapat diterapkan jika kondisinya bergerak.

Ini hanya efektif pada dialek EVM, tetapi aman digunakan pada dialek lain.

Prasyarat: Disambiguator, SSATransform.

Statement-Scale Simplifications
-------------------------------

.. _circular-reference-pruner:

CircularReferencesPruner
^^^^^^^^^^^^^^^^^^^^^^^^

This stage removes functions that call each other but are
neither externally referenced nor referenced from the outermost context.

.. _conditional-simplifier:

ConditionalSimplifier
^^^^^^^^^^^^^^^^^^^^^

Conditional Simplifier menyisipkan penetapan ke variabel kondisi jika nilainya dapat ditentukan
dari aliran kontrol.

Menghancurkan SSA form.

Saat ini, alat ini sangat terbatas, terutama karena kami belum memiliki dukungan
untuk tipe boolean. Karena kondisi hanya memeriksa ekspresi yang bukan nol,
kita tidak dapat menetapkan nilai tertentu.

Fitur saat ini:

- ganti kasus: masukkan "<kondisi> := <caseLabel>"
- setelah pernyataan if dengan penghentian aliran kontrol, masukkan "<condition> := 0"

Fitur masa depan:

- izinkan penggantian dengan "1"
- pertimbangkan penghentian fungsi yang ditentukan pengguna

Bekerja paling baik dengan formulir SSA dan jika penghapusan kode mati telah berjalan sebelumnya.

Prasyarat: Disambiguator.

.. _conditional-unsimplifier:

ConditionalUnsimplifier
^^^^^^^^^^^^^^^^^^^^^^^

Kebalikan dari Penyederhanaan Bersyarat.

.. _control-flow-simplifier:

ControlFlowSimplifier
^^^^^^^^^^^^^^^^^^^^^

Menyederhanakan beberapa struktur control-flow:

- ganti jika dengan badan kosong dengan pop(condition)
- hapus kotak switch default yang kosong
- hapus kotak switch kosong jika tidak ada case default
- ganti switch tanpa case dengan pop(expression)
- putar switch dengan case tunggal menjadi if
- ganti switch dengan hanya case default dengan pop(expression) dan body
- ganti switch dengan const expr dengan bodi case yang cocok
- ganti ``for`` dengan menghentikan aliran kontrol dan tanpa pemutusan/lanjutan lainnya dengan ``if``
- hapus ``leave`` di akhir fungsi.

Tak satu pun dari operasi ini bergantung pada aliran data. StructuralSimplifier melakukan tugas serupa yang bergantung pada aliran data.

ControlFlowSimplifier merekam ada atau tidaknya ``break``
dan pernyataan ``continue`` selama traversalnya.

Prasyarat: Disambiguator, FunctionHoister, ForLoopInitRewriter.
Penting: Memperkenalkan opcode EVM dan dengan demikian hanya dapat digunakan pada kode EVM untuk saat ini.

.. _dead-code-eliminator:

DeadCodeEliminator
^^^^^^^^^^^^^^^^^^

Tahap pengoptimalan ini menghapus kode yang tidak dapat dijangkau.

Kode yang tidak dapat dijangkau adalah kode apa pun dalam blok yang didahului oleh sebuah
leave, return, invalid, break, continue, selfdestruct atau revert.

Definisi fungsi dipertahankan seperti yang mungkin dipanggil oleh kode
sebelumnya dan dengan demikian dianggap dapat dijangkau.

Karena variabel yang dideklarasikan dalam blok init for loop memiliki cakupan yang diperluas ke badan loop,
kami membutuhkan ForLoopInitRewriter untuk dijalankan sebelum langkah ini.

Prasyarat: ForLoopInitRewriter, Function Hoister, Function Grouper

.. _unused-pruner:

UnusedPruner
^^^^^^^^^^^^

Langkah ini menghapus definisi semua fungsi yang tidak pernah direferensikan.

Itu juga menghapus deklarasi variabel yang tidak pernah direferensikan.
Jika deklarasi memberikan nilai yang tidak dapat dipindahkan, ekspresi dipertahankan,
tetapi nilainya dibuang.

Semua pernyataan ekspresi bergerak (ekspresi yang tidak ditetapkan) dihapus.

.. _structural-simplifier:

StructuralSimplifier
^^^^^^^^^^^^^^^^^^^^

Ini adalah langkah umum yang melakukan berbagai macam penyederhanaan pada
tingkat struktural:

- ganti pernyataan if dengan badan kosong dengan ``pop(condition)``
- ganti jika pernyataan dengan kondisi benar oleh tubuhnya
- hapus pernyataan if dengan kondisi salah
- putar switch dengan kasing tunggal menjadi if
- ganti switch dengan hanya case default dengan ``pop(expression)`` dan body
- ganti switch dengan ekspresi literal dengan mencocokkan badan case
- ganti for loop dengan kondisi false dengan bagian inisialisasinya

Komponen ini menggunakan Dataflow Analyzer.

.. _block-flattener:

BlockFlattener
^^^^^^^^^^^^^^

Tahap ini menghilangkan nested block dengan memasukkan pernyataan di
inner block pada tempat yang sesuai di outer block:

.. code-block:: yul

    {
        let x := 2
        {
            let y := 3
            mstore(x, y)
        }
    }

diubah menjadi

.. code-block:: yul

    {
        let x := 2
        let y := 3
        mstore(x, y)
    }

Selama kode disamarkan, ini tidak menimbulkan masalah karena
cakupan variabel hanya bisa tumbuh.

.. _loop-invariant-code-motion:

LoopInvariantCodeMotion
^^^^^^^^^^^^^^^^^^^^^^^
Pengoptimalan ini memindahkan deklarasi variabel SSA yang dapat dipindahkan ke luar loop.

Hanya pernyataan di tingkat atas dalam badan perulangan atau blok pos yang dipertimbangkan, yaitu deklarasi variabel di dalam cabang bersyarat tidak akan dipindahkan keluar dari perulangan.

Persyaratan:

- Disambiguator, ForLoopInitRewriter dan FunctionHoister harus dijalankan terlebih dahulu.
- Pemisah ekspresi dan transformasi SSA harus dijalankan terlebih dahulu untuk mendapatkan hasil yang lebih baik.


Function-Level Optimizations
----------------------------

.. _function-specializer:

FunctionSpecializer
^^^^^^^^^^^^^^^^^^^

Langkah ini mengkhususkan fungsi dengan argumen literalnya.

Jika suatu fungsi, katakanlah, ``fungsi f(a, b) { sstore (a, b) }``, dipanggil dengan argumen literal, untuk
contoh, ``f(x, 5)``, di mana ``x`` adalah pengidentifikasi, itu bisa dispesialisasikan dengan membuat yang baru
fungsi ``f_1`` yang hanya membutuhkan satu argumen, yaitu,

.. code-block:: yul

    function f_1(a_1) {
        let b_1 := 5
        sstore(a_1, b_1)
    }

Langkah pengoptimalan lainnya akan dapat membuat lebih banyak penyederhanaan fungsi. Langkah
pengoptimalan terutama berguna untuk fungsi yang tidak akan digariskan.

Prasyarat: Disambiguator, FunctionHoister

LiteralRematerialiser direkomendasikan sebagai prasyarat, meskipun tidak diperlukan untuk
ketepatan.

.. _unused-function-parameter-pruner:

UnusedFunctionParameterPruner
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Langkah ini menghapus parameter yang tidak digunakan dalam suatu fungsi.

Jika parameter tidak digunakan, seperti ``c`` dan ``y`` di, ``fungsi f(a,b,c) -> x, y { x := div(a,b) }``, kami
hapus parameter dan buat fungsi "tautan" baru sebagai berikut:

.. code-block:: yul

    function f(a,b) -> x { x := div(a,b) }
    function f2(a,b,c) -> x, y { x := f(a,b) }

dan ganti semua referensi ke ``f`` dengan ``f2``.
Inliner harus dijalankan setelahnya untuk memastikan bahwa semua referensi ke ``f2`` diganti oleh
``f``.

Prasyarat: Disambiguator, FunctionHoister, LiteralRematerialiser.

Langkah LiteralRematerialiser tidak diperlukan untuk kebenaran. Ini membantu menangani kasus-kasus seperti:
``function f(x) -> y { revert(y, y} }`` di mana literal ``y`` akan diganti dengan nilainya ``0``,
memungkinkan kita untuk menulis ulang fungsi.

.. _equivalent-function-combiner:

EquivalentFunctionCombiner
^^^^^^^^^^^^^^^^^^^^^^^^^^

Jika dua fungsi secara sintaksis setara, sementara memungkinkan variabel
mengganti nama tetapi tidak memesan ulang, maka referensi apa pun ke salah satu dari
fungsi digantikan oleh yang lain.

Penghapusan fungsi yang sebenarnya dilakukan oleh Pemangkas yang Tidak Digunakan.


Fungsi Inlining
---------------

.. _expression-inliner:

ExpressionInliner
^^^^^^^^^^^^^^^^^

Komponen pengoptimal ini melakukan inlining fungsi terbatas dengan inlining fungsi yang dapat
sebaris di dalam ekspresi fungsional, yaitu fungsi yang:

- mengembalikan nilai tunggal.
- memiliki body seperti ``r := <functional expression>``.
- tidak merujuk diri mereka sendiri atau ``r`` di sisi kanan.

Selanjutnya, untuk semua parameter, semua hal berikut harus benar:

- Argumennya bisa dipindahkan.
- Parameter direferensikan kurang dari dua kali di badan fungsi, atau argumennya agak murah
  ("biaya" paling banyak 1, seperti konstanta hingga 0xff).

Contoh: Fungsi yang akan digarisbawahi berbentuk ``fungsi f(...) -> r { r := E }`` dimana
``E`` adalah ekspresi yang tidak mereferensikan ``r`` dan semua argumen dalam pemanggilan fungsi adalah ekspresi yang dapat dipindahkan.

Hasil dari inlining ini selalu berupa ekspresi tunggal.

Komponen ini hanya dapat digunakan pada sumber dengan nama unik.

.. _full-inliner:

FullInliner
^^^^^^^^^^^

Full Inliner menggantikan panggilan tertentu dari fungsi tertentu
oleh tubuh fungsi. Ini tidak terlalu membantu dalam banyak kasus, karena
hanya meningkatkan ukuran kode tetapi tidak memiliki manfaat. Selain itu,
kode biasanya sangat mahal dan kita sering lebih suka memiliki kode yang
lebih pendek daripada kode yang lebih efisien. Namun, dalam kasus yang sama,
penyejajaran fungsi dapat memiliki efek positif pada langkah pengoptimal
berikutnya. Ini adalah kasus jika salah satu argumen fungsi adalah konstanta, misalnya.

Selama inlining, heuristik digunakan untuk mengetahui apakah fungsi memanggil
harus digarisbawahi atau tidak.
Heuristik saat ini tidak sejajar dengan fungsi "large" kecuali
fungsi yang dipanggil kecil. Fungsi yang hanya digunakan sekali adalah inline,
serta fungsi berukuran sedang, sedangkan pemanggilan fungsi dengan argumen konstan
memungkinkan fungsi yang sedikit lebih besar.


Di masa mendatang, kami mungkin menyertakan komponen lacak balik yang,
alih-alih langsung menyejajarkan fungsi, hanya mengkhususkannya,
yang berarti bahwa salinan fungsi dihasilkan di mana
parameter tertentu selalu diganti dengan konstanta. Setelah itu,
kita dapat menjalankan pengoptimal pada fungsi khusus ini. Jika
menghasilkan keuntungan besar, fungsi khusus dipertahankan,
jika tidak, fungsi asli digunakan sebagai gantinya.

Cleanup
-------

Pembersihan dilakukan pada akhir menjalankan pengoptimal. Ini mencoba
untuk menggabungkan ekspresi terpisah menjadi ekspresi yang sangat *nested* lagi dan juga
meningkatkan "compilability" untuk mesin stack dengan menghilangkan
variabel sebanyak mungkin.

.. _expression-joiner:

ExpressionJoiner
^^^^^^^^^^^^^^^^

Ini adalah operasi kebalikan dari pemisah ekspresi. Itu mengubah urutan deklarasi
variabel yang memiliki tepat satu referensi menjadi ekspresi kompleks.
Tahap ini sepenuhnya mempertahankan urutan panggilan fungsi dan eksekusi opcode.
Itu tidak menggunakan informasi apa pun mengenai komutatifitas opcode;
jika memindahkan nilai variabel ke tempat penggunaannya akan mengubah urutannya
dari setiap panggilan fungsi atau eksekusi opcode, transformasi tidak dilakukan.

Perhatikan bahwa komponen tidak akan memindahkan nilai yang ditetapkan dari assignment variabel
atau variabel yang direferensikan lebih dari satu kali.

Cuplikan ``let x := add(0, 2) let y := mul(x, mload(2))`` tidak ditransformasi,
karena akan menyebabkan urutan panggilan ke opcodes ``add`` dan
``mload`` untuk ditukar - meskipun ini tidak akan membuat perbedaan
karena ``add`` dapat dipindahkan.

Saat menyusun ulang opcode seperti itu, referensi variabel dan literal diabaikan.
Karena itu, cuplikan ``let x := add(0, 2) let y := mul(x, 3)`` adalah
ditransformasikan ke ``biarkan y := mul(add(0, 2), 3)``, meskipun opcode ``add``
akan dieksekusi setelah evaluasi literal ``3``.

.. _SSA-reverser:

SSAReverser
^^^^^^^^^^^

Ini adalah langkah kecil yang membantu membalikkan efek transformasi SSA
jika digabungkan dengan Common Subexpression Eliminator dan
Pemangkas yang tidak digunakan.

Formulir SSA yang kami hasilkan merusak pembuatan kode pada EVM dan
WebAssembly sama karena menghasilkan banyak variabel lokal. Itu akan
lebih baik hanya menggunakan kembali variabel yang ada dengan tugas daripada
deklarasi variabel baru.

Transformasi SSA menulis ulang

.. code-block:: yul

    let a := calldataload(0)
    mstore(a, 1)

ke

.. code-block:: yul

    let a_1 := calldataload(0)
    let a := a_1
    mstore(a_1, 1)
    let a_2 := calldataload(0x20)
    a := a_2

Masalahnya adalah sebagai ganti ``a``, variabel ``a_1`` digunakan
setiap kali ``a`` dirujuk. Pernyataan perubahan transformasi SSA
formulir ini hanya dengan menukar deklarasi dan penugasan. Di atas
cuplikan berubah menjadi

.. code-block:: yul

    let a := calldataload(0)
    let a_1 := a
    mstore(a_1, 1)
    a := calldataload(0x20)
    let a_2 := a

Ini adalah transformasi ekuivalensi yang sangat sederhana, tetapi saat kita menjalankan
Common Subexpression Eliminator, akan menggantikan semua kemunculan ``a_1``
oleh ``a`` (sampai ``a`` ditetapkan ulang). Pemangkas yang Tidak Digunakan kemudian akan
hilangkan variabel ``a_1`` sama sekali dan dengan demikian membalikkan sepenuhnya
transformasi SSA.

.. _stack-compressor:

StackCompressor
^^^^^^^^^^^^^^^

Satu masalah yang membuat pembuatan kode untuk Mesin Virtual Ethereum
sulit adalah kenyataan bahwa ada batas keras 16 slot untuk dicapai
ke bawah tumpukan ekspresi. Ini kurang lebih diterjemahkan menjadi batas
dari 16 variabel lokal. Kompresor tumpukan mengambil kode Yul dan
mengkompilasinya ke bytecode EVM. Kapan pun perbedaan tumpukan terlalu
besar, ini merekam fungsi tempat ini terjadi.

Untuk setiap fungsi yang menyebabkan masalah seperti itu, Rematerialiser
dipanggil dengan permintaan khusus untuk menghilangkan secara agresif
variabel diurutkan berdasarkan biaya nilainya.

Pada kegagalan, prosedur ini diulang beberapa kali.

.. _rematerialiser:

Rematerialiser
^^^^^^^^^^^^^^

Tahap rematerialisasi mencoba mengganti referensi variabel dengan ekspresi bahwa
terakhir ditugaskan ke variabel. Ini tentu saja hanya bermanfaat jika ungkapan ini
relatif murah untuk dievaluasi. Lebih jauh, itu hanya setara secara semantik jika
nilai ekspresi tidak berubah antara titik penugasan dan
titik penggunaan. Manfaat utama dari tahap ini adalah dapat menghemat slot tumpukan jika
mengarah ke variabel yang dihilangkan sepenuhnya (lihat di bawah), tetapi juga dapat
simpan opcode DUP pada EVM jika ekspresinya sangat murah.

Rematerialiser menggunakan Dataflow Analyzer untuk melacak nilai variabel saat ini,
yang selalu bergerak.
Jika nilainya sangat murah atau variabel tersebut secara eksplisit diminta untuk dihilangkan,
referensi variabel diganti dengan nilai saat ini.

.. _for-loop-condition-out-of-body:

ForLoopConditionOutOfBody
^^^^^^^^^^^^^^^^^^^^^^^^^

Membalikkan transformasi ForLoopConditionIntoBody.

Untuk setiap ``c`` bergerak, ternyata

.. code-block:: none

    for { ... } 1 { ... } {
    if iszero(c) { break }
    ...
    }

ke dalam

.. code-block:: none

    for { ... } c { ... } {
    ...
    }

dan ternyata

.. code-block:: none

    for { ... } 1 { ... } {
    if c { break }
    ...
    }

ke dalam

.. code-block:: none

    for { ... } iszero(c) { ... } {
    ...
    }

LiteralRematerialiser harus dijalankan sebelum langkah ini.


WebAssembly specific
--------------------

MainFunction
^^^^^^^^^^^^

Mengubah blok paling atas menjadi fungsi dengan nama tertentu ("main") yang tidak memiliki
input maupun output.

Tergantung pada Fungsi Kerapu.
