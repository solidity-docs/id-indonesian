##################################
Struktur Ekspresi dan Kontrol
##################################

.. index:: ! parameter, parameter;input, parameter;output, function parameter, parameter;function, return variable, variable;return, return


.. index:: if, else, while, do/while, for, break, continue, return, switch, goto

Struktur Kontrol
================

Sebagian besar struktur kontrol yang dikenal dari bahasa *curly-braces* tersedia di Solidity:

Ada: ``if``, ``else``, ``while``, ``do``, ``for``, ``break``, ``continue``, ``return``, dengan
semantik yang biasa dikenal dari C atau JavaScript.

Solidity juga mendukung penanganan eksepsi dalam bentuk pernyataan ``try``/``catch``,
tetapi hanya untuk :ref:`panggilan fungsi eksternal <external-function-calls>` dan
panggilan pembuatan kontrak. Kesalahan dapat dibuat menggunakan :ref:`revert statement <revert-statement>`.

Tanda kurung *tidak* dapat dihilangkan untuk kondisional, tetapi kurung kurawal dapat
dihilangkan di sekitar badan single-statement.

Perhatikan bahwa tidak ada tipe konversi dari tipe non-boolean ke boolean
seperti yang ada di C dan JavaScript, jadi ``if (1) { ... }`` *bukan* Solidity
yang valid.

.. index:: ! function;call, function;internal, function;external

.. _function-calls:

Function Calls (Panggilan Fungsi)
=================================

.. _internal-function-calls:

Panggilan Fungsi Internal
-------------------------

Fungsi kontrak saat ini dapat dipanggil secara langsung ("internally"), juga secara rekursif, seperti yang terlihat
dalam contoh yang tidak masuk akal ini:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    // This will report a warning
    contract C {
        function g(uint a) public pure returns (uint ret) { return a + f(); }
        function f() internal pure returns (uint ret) { return g(7) + f(); }
    }

Panggilan fungsi ini diterjemahkan ke dalam lompatan sederhana di dalam EVM.
Ini memiliki efek bahwa memori saat ini tidak dihapus, yaitu meneruskan referensi
memori ke fungsi yang dipanggil secara internal sangat efisien.
Hanya fungsi dari instance kontrak yang sama yang dapat dipanggil secara internal

Anda tetap harus menghindari rekursi yang berlebihan, karena setiap panggilan fungsi internal menggunakan
setidaknya satu slot stack dan hanya ada 1024 slot yang tersedia.

.. _external-function-calls:

Panggilan Fungsi Eksternal
--------------------------

Fungsi juga dapat dipanggil menggunakan notasi ``this.g(8);`` dan ``cg(2);``,
di mana ``c``adalah instance kontrak dan ``g`` adalah fungsi milik ``c``.
Memanggil fungsi ``g`` melalui salah satu cara untuk menghasilkan disebut "eksternal", menggunakan
panggilan pesan dan tidak secara langsung melalui lompatan.
Harap dicatat bahwa pemanggilan fungsi pada ``this`` tidak dapat digunakan dalam konstruktor,
karena kontrak yang sebenarnya belum dibuat.

Fungsi kontrak lain harus dipanggil secara eksternal. Untuk panggilan eksternal,
semua argumen fungsi harus disalin ke memori.

.. note::
    Panggilan fungsi dari satu kontrak ke kontrak lain tidak membuat transaksinya sendiri,
    itu adalah panggilan pesan sebagai bagian dari keseluruhan transaksi.

Saat memanggil fungsi kontrak lain, Anda dapat menentukan jumlah Wei atau gas yang dikirim
dengan panggilan dengan opsi khusus ``{nilai: 10, gas: 10000}``. Perhatikan bahwa tidak
disarankan untuk menentukan nilai gas secara eksplisit, karena biaya gas opcode dapat berubah
di masa mendatang. Setiap Wei yang Anda kirim ke kontrak ditambahkan ke total saldo kontrak itu:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract InfoFeed {
        function info() public payable returns (uint ret) { return 42; }
    }

    contract Consumer {
        InfoFeed feed;
        function setFeed(InfoFeed addr) public { feed = addr; }
        function callFeed() public { feed.info{value: 10, gas: 800}(); }
    }

Anda perlu menggunakan pengubah ``payable`` dengan fungsi ``info`` karena
jika tidak, opsi ``value`` tidak akan tersedia.

.. warning::
  Hati-hati bahwa ``feed.info{value: 10, gas: 800}`` hanya secara lokal menyetel ``value``
  dan jumlah ``gas`` yang dikirim dengan pemanggilan fungsi, dan tanda kurung di akhir menjalankan
  panggilan yang sebenarnya. Jadi ``feed.info{value: 10, gas: 800}`` tidak memanggil fungsi dan pengaturan
  ``value`` dan ``gas`` hilang, hanya ``feed.info{value: 10, gas: 800}()`` melakukan pemanggilan fungsi.

Karena fakta bahwa EVM menganggap panggilan ke kontrak yang tidak ada selalu berhasil, Solidity menggunakan
opcode ``extcodesize`` untuk memeriksa apakah kontrak yang akan dipanggil benar-benar ada (berisi kode) dan
menyebabkan pengecualian jika tidak. Pemeriksaan ini dilewati jika data yang dikembalikan akan didekode
setelah panggilan dan dengan demikian dekoder ABI akan menangkap kasus non-existing kontrak.

Perhatikan bahwa pemeriksaan ini tidak dilakukan dalam kasus :ref:`panggilan low-level <address_related>`
yang beroperasi pada alamat daripada instans kontrak.

.. note::
    Berhati-hatilah saat menggunakan panggilan tingkat tinggi ke :ref:`kontrak yang telah
    dikompilasi <precompiledContracts>`, karena kompiler menganggapnya tidak ada sesuai dengan
    logika di atas meskipun mereka mengeksekusi kode dan dapat mengembalikan data.

Panggilan fungsi juga menyebabkan pengecualian jika kontrak yang dipanggil itu
sendiri mengeluarkan pengecualian atau kehabisan gas.

.. warning::

    Setiap interaksi dengan kontrak lain menimbulkan potensi bahaya, terutama jika
    kode sumber kontrak tidak diketahui sebelumnya. Kontrak saat ini menyerahkan kendali
    ke kontrak yang disebut dan yang berpotensi melakukan apa saja. Bahkan jika kontrak
    yang dipanggil mewarisi dari kontrak induk yang diketahui, kontrak pewarisan hanya
    diperlukan untuk memiliki antarmuka yang benar.
    Pelaksanaan kontrak, bagaimanapun, dapat sepenuhnya sewenang-wenang dan dengan demikian,
    menimbulkan bahaya. Selain itu, bersiaplah jika panggilan ke kontrak lain dari sistem
    Anda atau bahkan kembali ke kontrak panggilan sebelum panggilan pertama kembali.
    Ini berarti bahwa kontrak yang dipanggil dapat mengubah variabel status dari kontrak
    pemanggilan melalui fungsinya. Tulis fungsi Anda sedemikian rupa sehingga, misalnya,
    panggilan ke fungsi eksternal terjadi setelah ada perubahan pada variabel status dalam
    kontrak Anda sehingga kontrak Anda tidak rentan terhadap eksploitasi reentrancy.

.. note::
    Sebelum Solidity 0.6.2, cara yang disarankan untuk menentukan nilai dan gas adalah
    dengan menggunakan ``f.value(x).gas(g)()``. Ini tidak digunakan lagi di Solidity 0.6.2
    dan tidak mungkin lagi sejak Solidity 0.7.0.

Panggilan Bernama dan Parameter Fungsi Anonim
---------------------------------------------

Argumen pemanggilan fungsi dapat diberikan berdasarkan nama, dalam urutan apa pun,
jika diapit dalam ``{ }`` seperti yang dapat dilihat pada contoh berikut.
Daftar argumen harus sesuai dengan nama dengan daftar parameter dari deklarasi fungsi,
tetapi bisa dalam urutan arbitrer.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract C {
        mapping(uint => uint) data;

        function f() public {
            set({value: 2, key: 3});
        }

        function set(uint key, uint value) public {
            data[key] = value;
        }

    }

Nama Parameter Fungsi yang Dihilangkan
--------------------------------------

Nama parameter yang tidak digunakan (terutama parameter pengembalian) dapat dihilangkan.
Parameter tersebut akan tetap ada pada stack, tetapi tidak dapat diakses.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        // omitted name for parameter
        function func(uint k, uint) public pure returns(uint) {
            return k;
        }
    }


.. index:: ! new, contracts;creating

.. _creating-contracts:

Membuat Kontrak melalui ``new``
===============================

Sebuah kontrak dapat membuat kontrak lain menggunakan kata kunci ``new``.
Kode lengkap dari kontrak yang sedang dibuat harus diketahui saat pembuatan
kontrak dikompilasi sehingga dependensi pembuatan rekursif tidak dimungkinkan.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract D {
        uint public x;
        constructor(uint a) payable {
            x = a;
        }
    }

    contract C {
        D d = new D(4); // will be executed as part of C's constructor

        function createD(uint arg) public {
            D newD = new D(arg);
            newD.x();
        }

        function createAndEndowD(uint arg, uint amount) public payable {
            // Send ether along with the creation
            D newD = new D{value: amount}(arg);
            newD.x();
        }
    }

Seperti yang terlihat pada contoh, adalah mungkin untuk mengirim Ether saat
membuat instance ``D`` menggunakan opsi ``value``, tetapi tidak mungkin untuk
membatasi jumlah gas. Jika pembuatan gagal (karena kehabisan stack,
tidak cukup keseimbangan atau masalah lain), pengecualian dilemparkan.

Pembuatan kontrak Salted / create2
-----------------------------------

Saat membuat kontrak, alamat kontrak dihitung dari alamat
pembuatan kontrak dan penghitung yang ditingkatkan dengan
setiap pembuatan kontrak.

Jika Anda menentukan opsi ``salt`` (nilai byte32), maka pembuatan kontrak akan
menggunakan mekanisme yang berbeda untuk memunculkan alamat kontrak baru:

Ini akan menghitung alamat dari alamat kontrak yang dibuat, nilai salt yang diberikan,
bytecode (pembuatan) dari kontrak yang dibuat dan argumen konstruktor.

Secara khusus, penghitung ("nonce") tidak digunakan.
Hal ini memungkinkan lebih banyak fleksibilitas dalam
membuat kontrak: Anda dapat memperoleh alamat kontrak
baru sebelum dibuat.
Selanjutnya, Anda dapat mengandalkan alamat ini juga jika
kontrak pembuatan membuat kontrak lain sementara itu.

Kasus penggunaan utama di sini adalah kontrak yang bertindak sebagai hakim untuk interaksi off-chain,
yang hanya perlu dibuat jika terjadi perselisihan.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract D {
        uint public x;
        constructor(uint a) {
            x = a;
        }
    }

    contract C {
        function createDSalted(bytes32 salt, uint arg) public {
            // This complicated expression just tells you how the address
            // can be pre-computed. It is just there for illustration.
            // You actually only need ``new D{salt: salt}(arg)``.
            address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(D).creationCode,
                    arg
                ))
            )))));

            D d = new D{salt: salt}(arg);
            require(address(d) == predictedAddress);
        }
    }

.. warning::
    Ada beberapa kekhasan dalam kaitannya dengan penciptaan *salt*.
    Kontrak dapat dibuat kembali di alamat yang sama setelah dihancurkan.
    Namun, kontrak yang baru dibuat mungkin memiliki bytecode yang berbeda
    meskipun bytecode pembuatannya sama (yang merupakan persyaratan karena
    jika tidak, alamatnya akan berubah). Hal ini disebabkan oleh fakta bahwa
    konstruktor dapat menanyakan keadaan eksternal yang mungkin telah berubah
    antara dua kreasi dan memasukkannya ke dalam bytecode yang digunakan sebelum
    ia disimpan.


Urutan Evaluasi Ekspresi
========================

Urutan evaluasi ekspresi tidak ditentukan (lebih formal, urutan anak dari satu node
di pohon ekspresi dievaluasi tidak ditentukan, tetapi tentu saja dievaluasi sebelum
node itu sendiri). Itu hanya dijamin bahwa pernyataan dieksekusi secara berurutan dan
short-circuiting untuk ekspresi boolean dilakukan.

.. index:: ! assignment

Assignmen
=========

.. index:: ! assignment;destructuring

Menghancurkan Assignments dan Mengembalikan Beberapa Nilai
----------------------------------------------------------

Solidity secara internal memungkinkan tipe tupel, yaitu daftar
objek dari tipe yang berpotensi berbeda yang jumlahnya konstan
pada waktu kompilasi. Tuple tersebut dapat digunakan untuk
menghasilkan beberapa nilai sekaligus. Ini kemudian dapat ditugaskan
ke variabel yang baru dideklarasikan atau ke variabel yang sudah
ada sebelumnya (atau LValues secara umum).

Tuple bukanlah tipe yang tepat dalam Solidity, mereka hanya dapat digunakan untuk
membentuk pengelompokan ekspresi syntactic.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        uint index;

        function f() public pure returns (uint, bool, uint) {
            return (7, true, 2);
        }

        function g() public {
            // Variables declared with type and assigned from the returned tuple,
            // not all elements have to be specified (but the number must match).
            (uint x, , uint y) = f();
            // Common trick to swap values -- does not work for non-value storage types.
            (x, y) = (y, x);
            // Components can be left out (also for variable declarations).
            (index, , ) = f(); // Sets the index to 7
        }
    }

Tidak mungkin untuk mencampur deklarasi variabel dan assignments non-deklarasi,
misalnya yang berikut ini tidaklah valid: ``(x, uint y) = (1, 2);``

.. note::
    Sebelum versi 0.5.0 dimungkinkan untuk menetapkan tupel dengan ukuran yang lebih kecil,
    baik mengisi di sisi kiri atau di sisi kanan (yang pernah kosong). Ini sekarang tidak diizinkan,
    jadi kedua belah pihak harus memiliki jumlah komponen yang sama.

.. warning::
    Berhati-hatilah saat menetapkan ke beberapa variabel pada saat yang
    sama ketika tipe referensi terlibat, karena dapat menyebabkan perilaku
    penyalinan yang tidak terduga.

Komplikasi untuk Array dan Struct
---------------------------------

Semantik assignments lebih rumit untuk tipe non-value seperti array dan struct,
termasuk ``byte`` dan ``string``, lihat :ref:`Lokasi data dan perilaku assignments <data-location-assignment>` untuk detailnya.

Pada contoh di bawah, panggilan ke ``g(x)`` tidak berpengaruh pada ``x`` karena
panggilan tersebut membuat salinan independen dari nilai penyimpanan di memori.
Namun, ``h(x)`` berhasil memodifikasi ``x`` karena hanya referensi dan bukan salinan yang dilewatkan.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        uint[20] x;

        function f() public {
            g(x);
            h(x);
        }

        function g(uint[20] memory y) internal pure {
            y[2] = 3;
        }

        function h(uint[20] storage y) internal {
            y[3] = 4;
        }
    }

.. index:: ! scoping, declarations, default value

.. _default-value:

Scoping dan Declarations
========================

Variabel yang dideklarasikan akan memiliki nilai default
awal yang representasi byte-nya adalah semua nol.
"Nilai default" variabel adalah "zero-state" tipikal
dari apa pun tipenya. Misalnya, nilai default untuk ``bool`` adalah
``false``. Nilai default untuk tipe ``uint`` atau ``int``
adalah ``0``. Untuk array berukuran statis dan ``bytes1`` hingga
``bytes32``, setiap elemen
individual akan diinisialisasi ke nilai default yang sesuai
dengan tipenya. Untuk larik berukuran dinamis, ``byte``
dan ``string``, nilai defaultnya adalah array atau string kosong.
Untuk tipe ``enum``, nilai defaultnya adalah anggota pertamanya.

Scoping dalam Solidity mengikuti aturan pelingkupan luas C99
(dan banyak bahasa lainnya): Variabel terlihat dari titik tepat setelah deklarasinya
hingga akhir ``{ }``-block terkecil yang berisi deklarasi.
Sebagai pengecualian untuk aturan ini, variabel yang dideklarasikan
di bagian inisialisasi for-loop hanya terlihat sampai akhir for-loop.

Variabel yang *parameter-like* (parameter fungsi, parameter modifier,
parameter catch, ...) terlihat di dalam block kode berikut -
badan fungsi/modifier untuk fungsi dan parameter modifier dan catch block
untuk parameter catch.

Variabel dan item lain yang dideklarasikan di luar blok kode, misalnya fungsi, kontrak,
tipe user-defined, dll., terlihat bahkan sebelum dideklarasikan. Ini berarti Anda dapat
menggunakan variabel state sebelum dideklarasikan dan memanggil fungsi secara rekursif.

Sebagai akibatnya, contoh berikut akan dikompilasi tanpa peringatan, karena kedua variabel
memiliki nama yang sama tetapi cakupannya terpisah.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    contract C {
        function minimalScoping() pure public {
            {
                uint same;
                same = 1;
            }

            {
                uint same;
                same = 3;
            }
        }
    }

Sebagai contoh khusus dari aturan pelingkupan C99, perhatikan bahwa berikut ini,
penugasan pertama ke ``x`` sebenarnya akan menetapkan variabel luar dan bukan variabel dalam.
Bagaimanapun, Anda akan mendapatkan peringatan tentang variabel luar yang dibayangi.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // This will report a warning
    contract C {
        function f() pure public returns (uint) {
            uint x = 1;
            {
                x = 2; // this will assign to the outer variable
                uint x;
            }
            return x; // x has value 2
        }
    }

.. warning::
    Sebelum versi 0.5.0 Solidity mengikuti aturan scoping yang sama seperti
    JavaScript, yaitu, variabel yang dideklarasikan di mana saja dalam suatu fungsi akan berada dalam cakupan
    untuk seluruh fungsi, terlepas dari mana ia dideklarasikan. Contoh berikut menunjukkan cuplikan kode yang
    digunakan untuk dikompilasi tetapi menyebabkan kesalahan mulai dari versi 0.5.0.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // This will not compile
    contract C {
        function f() pure public returns (uint) {
            x = 2;
            uint x;
            return x;
        }
    }


.. index:: ! safe math, safemath, checked, unchecked
.. _unchecked:

Aritmatika Checked atau Unchecked
=================================

Sebuah overflow atau underflow adalah situasi di mana nilai yang dihasilkan dari operasi aritmatika,
ketika dieksekusi pada integer tak terbatas, berada di luar kisaran tipe hasil.

Sebelum Solidity 0.8.0, operasi aritmatika akan selalu terbungkus dalam kasus
under- atau overflow yang mengarah ke meluasnya penggunaan libraries yang memperkenalkan
pemeriksaan tambahan.

Sejak Solidity 0.8.0, semua operasi aritmatika kembali ke over- dan underflow secara default,
sehingga membuat penggunaan libraries ini tidak perlu.

Untuk mendapatkan perilaku sebelumnya, blok ``unchecked`` dapat digunakan:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract C {
        function f(uint a, uint b) pure public returns (uint) {
            // This subtraction will wrap on underflow.
            unchecked { return a - b; }
        }
        function g(uint a, uint b) pure public returns (uint) {
            // This subtraction will revert on underflow.
            return a - b;
        }
    }

Panggilan ke ``f(2, 3)`` akan menghasilkan ``2**256-1``, sementara ``g(2, 3)`` akan menyebabkan
assertion yang gagal.

Blok ``unchecked`` dapat digunakan di mana saja di dalam blok, tetapi bukan sebagai
pengganti blok. Itu juga tidak bisa di nested.

Pengaturan hanya memengaruhi pernyataan yang secara sintaksis berada di dalam blok.
Fungsi yang dipanggil dari dalam blok ``unchecked`` tidak mewarisi properti.

.. note::
    Untuk menghindari ambiguitas, Anda tidak dapat menggunakan ``_;`` di dalam blok ``unchecked``.

Operator berikut akan menyebabkan pernyataan gagal pada overflow atau underflow
dan akan membungkus tanpa kesalahan jika digunakan di dalam blok yang tidak dicentang:

``++``, ``--``, ``+``, binary ``-``, unary ``-``, ``*``, ``/``, ``%``, ``**``

``+=``, ``-=``, ``*=``, ``/=``, ``%=``

.. warning::
    Tidak mungkin menonaktifkan pemeriksaan pembagian dengan
    nol atau modulo dengan nol menggunakan blok ``unchecked``.

.. note::
   Operator bitwise tidak melakukan pemeriksaan overflow atau underflow.
   Ini terutama terlihat saat menggunakan pergeseran bitwise (``<<``, ``>>``, ``<<=``, ``>>=``) di
   tempat integer divisi dan perkalian dengan pangkat 2.
   Misalnya ``type(uint256).max << 3`` tidak dikembalikan meskipun ``type(uint256).max * 8`` akan dikembalikan.

.. note::
    Pernyataan kedua dalam ``int x = type(int).min; -x;`` akan menghasilkan overflow
    karena rentang negatif dapat menampung satu nilai lebih banyak daripada rentang positif.

Konversi tipe eksplisit akan selalu terpotong dan tidak pernah menyebabkan assertion gagal
dengan pengecualian konversi dari integer ke tipe enum.

.. index:: ! exception, ! throw, ! assert, ! require, ! revert, ! errors

.. _assert-and-require:

Penanganan kesalahan: Assert, Require, Revert and Exceptions
============================================================

Solidity menggunakan eksepsi state-reverting untuk menangani kesalahan.
Pengecualian seperti itu membatalkan semua perubahan yang dibuat pada
state dalam panggilan saat ini (dan semua sub-panggilannya) dan
menandai kesalahan ke pemanggil.

Ketika eksepsi terjadi di sebuah sub-call, mereka "bubble up" (yaitu.,
eksepsi dimunculkan kembali) secara otomatis kecuali mereka terjebak dalam
pernyataan ``try/catch``. Eksepsi untuk aturan ini adalah ``send``
dan fungsi low-level ``call``, ``delegatecall`` dan
``staticcall``: mereka menghasilkan ``false`` sebagai nilai pengembalian pertama jika terjadi
pengecualian alih-alih "bubbling up".

.. warning::
    Fungsi tingkat rendah ``call``, ``delegatecall`` dan
    ``staticcall`` menghasilkan ``true`` sebagai nilai pengembalian pertama mereka
    jika akun yang dipanggil tidak ada, sebagai bagian dari desain
    dari EVM. Keberadaan akun harus diperiksa sebelum  jika panggilan diperlukan.

Pengecualian dapat berisi data kesalahan yang diteruskan kembali ke pemanggil dalam
bentuk :ref:`contoh kesalahan <kesalahan>`. Kesalahan bawaan ``Error(string)`` dan
``Panic(uint256)`` digunakan oleh fungsi khusus, seperti yang dijelaskan di bawah ini.
``Error`` digunakan untuk kondisi kesalahan "biasa" sementara ``Panic`` digunakan untuk
kesalahan yang seharusnya tidak ada dalam kode bebas bug.

Panic via ``assert`` dan Error via ``require``
----------------------------------------------

Fungsi kenyamanan ``assert`` dan ``require`` dapat digunakan untuk memeriksa kondisi dan melempar pengecualian
jika syarat tidak terpenuhi.

Fungsi ``assert`` membuat kesalahan tipe ``Panic(uint256)``.
Kesalahan yang sama dibuat oleh kompiler dalam situasi tertentu seperti yang tercantum di bawah ini.

Assert hanya boleh digunakan untuk menguji kesalahan internal, dan untuk memeriksa invarian.
Kode yang berfungsi dengan baik seharusnya tidak pernah membuat Panik, bahkan pada input eksternal yang tidak valid.
Jika ini terjadi, maka ada bug dalam kontrak Anda yang harus Anda perbaiki.
Alat analisis bahasa dapat mengevaluasi kontrak Anda untuk mengidentifikasi kondisi dan panggilan fungsi yang akan menyebabkan Kepanikan.

Eksepsi panik dihasilkan dalam situasi berikut.
Kode kesalahan yang disertakan dengan data kesalahan menunjukkan jenis panik.

#. 0x00: Digunakan untuk kompiler generik yang disisipkan panik.
#. 0x01: Jika Anda memanggil ``assert`` dengan argumen yang bernilai false.
#. 0x11: Jika operasi aritmatika menghasilkan underflow atau overflow di luar ``unchecked { ... }`` block.
#. 0x12; Jika Anda membagi atau modulo dengan nol (mis. ``5 / 0`` atau ``23 % 0``).
#. 0x21: Jika Anda mengonversi nilai yang terlalu besar atau negatif menjadi tipe enum.
#. 0x22: Jika Anda mengakses storage byte array yang dikodekan dengan tidak benar.
#. 0x31: Jika Anda memanggil ``.pop()`` pada array kosong.
#. 0x32: Jika Anda mengakses array, ``bytesN`` atau array slice pada indeks di luar batas atau negatif (yaitu ``x[i]`` di mana ``i >= x.length`` atau ` `i < 0``).
#. 0x41: Jika Anda mengalokasikan terlalu banyak memori atau membuat array yang terlalu besar.
#. 0x51: Jika Anda memanggil zero-initialized variabel dari tipe fungsi internal.

Fungsi ``require`` membuat kesalahan tanpa data apa pun atau
kesalahan tipe ``Error(string)``.
Ini harus digunakan untuk memastikan kondisi valid yang tidak dapat dideteksi sampai waktu eksekusi.
Ini termasuk kondisi pada input atau nilai yang dihasilkan dari panggilan ke kontrak eksternal.

.. note::

    Saat ini tidak mungkin untuk menggunakan kesalahan khusus dalam
    kombinasi dengan ``require``. Silakan gunakan ``if (!condition) revert CustomError();`` sebagai gantinya.

Pengecualian ``Error(string)`` (atau pengecualian tanpa data) dihasilkan
oleh kompiler
dalam situasi berikut:

#. Memanggil ``require(x)`` di mana ``x`` dievaluasi menjadi ``false``.
#. Jika Anda menggunakan ``revert()`` atau ``revert("description")``.
#. Jika Anda melakukan panggilan fungsi eksternal yang menargetkan kontrak yang tidak berisi kode.
#. Jika kontrak Anda menerima Ether melalui fungsi publik tanpa
   Pengubah ``payable`` (termasuk konstruktor dan fungsi fallback).
#. Jika kontrak Anda menerima Ether melalui fungsi getter publik.

Untuk kasus berikut, data kesalahan dari panggilan eksternal
(jika disediakan) diteruskan. Ini berarti bahwa hal itu dapat menyebabkan
sebuah `Error` atau `Panic` (atau apa pun yang diberikan):

#. Jika sebuah ``.transfer()`` gagal.
#. Jika Anda memanggil suatu fungsi melalui panggilan pesan tetapi tidak selesai
   dengan benar (yaitu, kehabisan gas, tidak memiliki fungsi yang cocok, atau
   melempar pengecualian itu sendiri), kecuali ketika operasi tingkat rendah
   ``call``, ``send``, ``delegatecall``, ``callcode`` atau ``staticcall``
   digunakan. Operasi tingkat rendah tidak pernah menampilkan pengecualian tetapi
   menunjukkan kegagalan dengan menampilkan ``false``.
#. Jika Anda membuat kontrak menggunakan kata kunci ``new`` tetapi pembuatan
   kontrak :ref:`tidak selesai dengan benar<creating-contracts>`.

Anda dapat secara opsional memberikan string pesan untuk ``require``, tetapi tidak untuk ``assert``.

.. note::
    Jika Anda tidak memberikan argumen string ke ``require``, argumen tersebut akan dikembalikan
    dengan data kesalahan kosong, bahkan tidak termasuk error selector.


Contoh berikut menunjukkan bagaimana Anda dapat menggunakan ``require`` untuk memeriksa kondisi pada input
dan ``assert`` untuk pemeriksaan kesalahan internal.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract Sharer {
        function sendHalf(address payable addr) public payable returns (uint balance) {
            require(msg.value % 2 == 0, "Even value required.");
            uint balanceBeforeTransfer = address(this).balance;
            addr.transfer(msg.value / 2);
            // Since transfer throws an exception on failure and
            // cannot call back here, there should be no way for us to
            // still have half of the money.
            assert(address(this).balance == balanceBeforeTransfer - msg.value / 2);
            return address(this).balance;
        }
    }

Secara internal, Solidity melakukan operasi revert
(instruksi ``0xfd``). Ini menyebabkan EVM
mengembalikan semua perubahan yang dibuat ke state.
Alasan untuk reverting adalah karena tidak ada cara yang aman untuk melanjutkan eksekusi,
karena efek yang diharapkan tidak terjadi. Karena kami ingin menjaga atomisitas transaksi,
tindakan teraman adalah mengembalikan semua perubahan dan membuat seluruh transaksi (atau
setidaknya panggilan) tanpa efek.

Dalam kedua kasus, pemanggil dapat bereaksi pada kegagalan tersebut menggunakan ``try``/``catch``, tetapi
perubahan pada pemanggil akan selalu dikembalikan.

.. note::

    Eksepsi panik digunakan untuk menggunakan opcode ``invalid`` sebelum Solidity 0.8.0,
    yang menghabiskan semua gas yang tersedia untuk panggilan tersebut.
    Eksepsi yang menggunakan ``require`` digunakan untuk mengkonsumsi semua gas sampai sebelum rilis Metropolis.

.. _revert-statement:

``revert``
----------

Direct revert dapat dipicu menggunakan pernyataan ``revert`` dan fungsi ``revert``.

Pernyataan ``revert`` mengambil kesalahan khusus sebagai argumen langsung tanpa tanda kurung:

    revert CustomError(arg1, arg2);

Untuk alasan backwards-compatibility, ada juga fungsi ``revert()``, yang menggunakan tanda kurung
dan menerima string:

    revert();
    revert("description");

Data kesalahan akan diteruskan kembali ke pemanggil dan dapat dilihat di sana.
Menggunakan ``revert()`` menyebabkan pengembalian tanpa data kesalahan apa pun sementara ``revert("description")``
akan membuat kesalahan ``Error(string)``.

Menggunakan instance kesalahan kustom biasanya akan jauh lebih murah daripada deskripsi string,
karena Anda dapat menggunakan nama kesalahan untuk menggambarkannya, yang dikodekan hanya dalam empat byte.
Deskripsi yang lebih panjang dapat diberikan melalui NatSpec yang tidak dikenakan biaya apa pun.

Contoh berikut menunjukkan cara menggunakan string kesalahan dan instance kesalahan khusus bersama
dengan ``revert`` dan ``require`` yang setara:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract VendingMachine {
        address owner;
        error Unauthorized();
        function buy(uint amount) public payable {
            if (amount > msg.value / 2 ether)
                revert("Not enough Ether provided.");
            // Alternative way to do it:
            require(
                amount <= msg.value / 2 ether,
                "Not enough Ether provided."
            );
            // Perform the purchase.
        }
        function withdraw() public {
            if (msg.sender != owner)
                revert Unauthorized();

            payable(msg.sender).transfer(address(this).balance);
        }
    }

Dua cara ``if (!condition) revert(...);`` dan ``require(condition, ...);``
ekuivalen selama argumen untuk ``revert`` dan ``require `` tidak memiliki
efek samping, misalnya jika hanya berupa string.

.. note::
    Fungsi ``require`` dievaluasi sama seperti fungsi lainnya.
    Ini berarti bahwa semua argumen dievaluasi sebelum fungsi itu sendiri dijalankan.
    Khususnya, dalam ``require(condition, f())`` fungsi ``f`` dijalankan bahkan jika ``condition`` benar.

The provided string is :ref:`abi-encoded <ABI>` as if it were a call to a function ``Error(string)``.
In the above example, ``revert("Not enough Ether provided.");`` returns the following hexadecimal as error return data:

.. code::

    0x08c379a0                                                         // Function selector for Error(string)
    0x0000000000000000000000000000000000000000000000000000000000000020 // Data offset
    0x000000000000000000000000000000000000000000000000000000000000001a // String length
    0x4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 // String data

Pesan yang diberikan dapat diambil oleh pemanggil menggunakan ``try``/``catch`` seperti yang ditunjukkan di bawah ini.

.. note::
    Dulu ada kata kunci yang disebut ``throw`` dengan semantik yang sama dengan
    ``revert()`` yang tidak digunakan lagi di versi 0.4.13 dan dihapus di versi 0.5.0.


.. _try-catch:

``try``/``catch``
-----------------

Kegagalan dalam panggilan eksternal dapat ditangkap menggunakan pernyataan try/catch, sebagai berikut:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.1;

    interface DataFeed { function getData(address token) external returns (uint value); }

    contract FeedConsumer {
        DataFeed feed;
        uint errorCount;
        function rate(address token) public returns (uint value, bool success) {
            // Permanently disable the mechanism if there are
            // more than 10 errors.
            require(errorCount < 10);
            try feed.getData(token) returns (uint v) {
                return (v, true);
            } catch Error(string memory /*reason*/) {
                // This is executed in case
                // revert was called inside getData
                // and a reason string was provided.
                errorCount++;
                return (0, false);
            } catch Panic(uint /*errorCode*/) {
                // This is executed in case of a panic,
                // i.e. a serious error like division by zero
                // or overflow. The error code can be used
                // to determine the kind of error.
                errorCount++;
                return (0, false);
            } catch (bytes memory /*lowLevelData*/) {
                // This is executed in case revert() was used.
                errorCount++;
                return (0, false);
            }
        }
    }

Kata kunci ``try`` harus diikuti oleh ekspresi yang mewakili panggilan fungsi eksternal
atau pembuatan kontrak (``new ContractName()``).
Kesalahan di dalam ekspresi tidak ditangkap (misalnya jika itu adalah ekspresi kompleks
yang juga melibatkan panggilan fungsi internal), hanya revert yang terjadi di dalam panggilan
eksternal itu sendiri. Bagian ``returns`` (yang adalah opsional) yang mengikuti mendeklarasikan variabel return
yang cocok dengan tipe yang dikembalikan oleh panggilan eksternal. Jika tidak ada kesalahan,
variabel-variabel ini ditetapkan dan eksekusi kontrak berlanjut di dalam blok pertama yang sukses .
Jika akhir dari blok yang sukses tercapai, eksekusi dilanjutkan setelah blok ``catch``.

Solidity mendukung berbagai jenis blok catch tergantung pada
jenis kesalahan:

- ``catch Error(string memory reason) { ... }``: Klausa catch ini dijalankan jika kesalahan disebabkan oleh ``revert("reasonString")`` atau
  ``require(false, "reasonString")`` (atau kesalahan internal yang menyebabkan
  eksepsi).

- ``catch Panic(uint errorCode) { ... }``: Jika kesalahan disebabkan oleh kepanikan, yaitu oleh ``assert`` yang gagal, pembagian dengan nol,
  akses array tidak valid, overflow aritmatika dan lainnya, klausa catch ini akan dijalankan.

- ``catch (bytes memory lowLevelData) { ... }``: Klausa ini dijalankan jika tanda tangan kesalahan
  tidak cocok dengan klausa lainnya, jika ada kesalahan saat mendekode pesan kesalahan,
  atau jika tidak ada data kesalahan yang diberikan dengan eksepsi.
  Variabel yang dideklarasikan menyediakan akses ke data kesalahan tingkat rendah dalam kasus itu.

- ``catch { ... }``: Jika Anda tidak tertarik dengan data kesalahan, Anda bisa menggunakan
  ``catch { ... }`` (bahkan sebagai satu-satunya klausa catch) alih-alih klausa sebelumnya.


Direncanakan untuk mendukung jenis data kesalahan lainnya di masa mendatang.
String ``Error`` dan ``Panic`` saat ini diuraikan apa adanya dan tidak diperlakukan sebagai identifiers.

Untuk menangkap semua kasus kesalahan, Anda harus memiliki setidaknya klausa
``catch { ...}`` atau klausa ``catch (byte memory lowLevelData) { ... }``.

Variabel yang dideklarasikan dalam klausa ``returns`` dan ``catch`` hanya berada
dalam cakupan di blok berikut.

.. note::

    Jika kesalahan terjadi selama decoding data yang dikembalikan di dalam pernyataan try/catch,
    ini menyebabkan pengecualian dalam kontrak yang sedang dijalankan dan karena itu, tidak tertangkap
    dalam klausa catch. Jika ada kesalahan selama decoding ``catch Error(string memory reason)`` dan
    ada klausa tangkapan tingkat rendah, kesalahan ini akan ditangkap di sana.

.. note::

    Jika eksekusi mencapai catch-block, maka efek perubahan status dari panggilan eksternal telah dikembalikan.
    Jika eksekusi mencapai blok sukses, efeknya tidak dikembalikan. Jika efeknya telah dikembalikan, maka eksekusi
    akan berlanjut di blok catch atau eksekusi dari pernyataan try/catch itu sendiri akan dikembalikan (misalnya karena
    kegagalan decoding seperti disebutkan di atas atau karena tidak menyediakan klausa catch level rendah).

.. note::
    Alasan di balik panggilan yang gagal bisa bermacam-macam. Jangan berasumsi bahwa pesan kesalahan datang langsung dari
    kontrak yang dipanggil: Kesalahan mungkin terjadi lebih dalam di rantai panggilan dan kontrak yang dipanggil baru saja
    meneruskannya. Juga, bisa jadi karena situasi out-of-gas dan bukan kondisi kesalahan yang disengaja: Penelepon selalu
    mempertahankan 63/64 gas dalam panggilan dan dengan demikian bahkan jika kontrak yang dipanggil kehabisan gas, pemanggil
    masih memiliki sisa gas.
