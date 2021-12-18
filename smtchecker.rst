.. _formal_verification:

##################################
SMTChecker dan Verifikasi Formal
##################################

Dengan menggunakan verifikasi formal, dimungkinkan untuk melakukan pembuktian matematis
otomatis bahwa kode sumber Anda memenuhi spesifikasi formal tertentu.
Spesifikasinya masih formal (seperti kode sumber), tetapi biasanya jauh lebih sederhana.

Perhatikan bahwa verifikasi formal itu sendiri hanya dapat membantu Anda memahami perbedaan
antara apa yang Anda lakukan (spesifikasi) dan bagaimana Anda melakukannya (implementasi
sebenarnya). Anda masih perlu memeriksa apakah spesifikasinya adalah apa yang Anda inginkan
dan Anda tidak melewatkan efek yang tidak diinginkan.

Solidity menerapkan pendekatan verifikasi formal berdasarkan
`SMT (Satisfiability Modulo Theories) <https://en.wikipedia.org/wiki/Satisfiability_modulo_theories>`_ dan
penyelesaian `Horn <https://en.wikipedia.org/wiki/Horn-satisfiability>`_ .
Modul SMTChecker secara otomatis mencoba membuktikan bahwa kode memenuhi spesifikasi
yang diberikan oleh pernyataan ``require`` dan ``assert``. Artinya, ia menganggap
pernyataan ``require`` sebagai asumsi dan mencoba membuktikan bahwa kondisi di dalam
pernyataan ``assert`` selalu benar. Jika kegagalan pernyataan ditemukan, contoh tandingan
dapat diberikan kepada pengguna yang menunjukkan bagaimana pernyataan dapat dilanggar.
Jika tidak ada peringatan yang diberikan oleh SMTChecker untuk suatu properti, berarti properti
tersebut aman.

Target verifikasi lain yang diperiksa SMTChecker pada waktu kompilasi adalah:

- Aritmatika underflow dan overflow.
- Division by zero.
- Kondisi Trivial dan unreachable code.
- Memunculkan array kosong.
- Akses indeks di luar batas.
- Dana tidak cukup untuk transfer.

Semua target di atas secara otomatis diperiksa secara default jika semua mesin
diaktifkan, kecuali underflow dan overflow untuk Solidity >=0.8.7.

Peringatan potensial yang dilaporkan SMTChecker adalah:

- ``<failing  property> happens here.``. Ini berarti bahwa SMTChecker membuktikan bahwa properti tertentu gagal. Sebuah contoh tandingan dapat diberikan, namun dalam situasi yang kompleks mungkin juga tidak menunjukkan contoh tandingan. Hasil ini mungkin juga positif palsu dalam kasus tertentu, ketika penyandian SMT menambahkan abstraksi untuk kode Solidity yang sulit atau tidak mungkin untuk diungkapkan.
- ``<failing property> might happen here``. Ini berarti bahwa solver tidak dapat membuktikan kedua kasus dalam batas waktu yang diberikan. Karena hasilnya tidak diketahui, SMTChecker melaporkan potensi kegagalan untuk kesehatan. Ini dapat diselesaikan dengan meningkatkan batas waktu kueri, tetapi masalahnya mungkin juga terlalu sulit untuk dipecahkan oleh mesin.

Untuk mengaktifkan SMTChecker, Anda harus memilih :ref:`mesin mana yang harus dijalankan<smtchecker_engines>`,
di mana defaultnya adalah tidak ada mesin. Memilih mesin memungkinkan SMTChecker pada semua file.

.. note::

    Sebelum Solidity 0.8.4, cara default untuk mengaktifkan SMTChecker adalah melalui
    ``pragma experimental SMTTChecker;`` dan hanya kontrak yang berisi pragma yang akan
    dianalisis. Pragma itu sudah tidak digunakan lagi, dan meskipun masih memungkinkan
    SMTChecker untuk kompatibilitas ke belakang, pragma itu akan dihapus di Solidity 0.9.0.
    Perhatikan juga bahwa sekarang menggunakan pragma bahkan hanya dalam satu file akan
    memungkinkan SMTChecker untuk semua file.

.. note::

    Kurangnya peringatan untuk target verifikasi menunjukkan bukti kebenaran matematis yang
    tak terbantahkan, dengan asumsi tidak ada bug di SMTChecker dan pemecah yang mendasarinya.
    Perlu diingat bahwa masalah ini *sangat sulit* dan terkadang *tidak mungkin* untuk diselesaikan
    secara otomatis dalam kasus umum. Oleh karena itu, beberapa properti mungkin tidak dapat
    diselesaikan atau mungkin mengarah pada kesalahan positif untuk kontrak besar. Setiap properti
    yang telah terbukti harus dilihat sebagai pencapaian penting. Untuk pengguna tingkat lanjut,
    lihat :ref:`SMTChecker Tuning <smtchecker_options>` untuk mempelajari beberapa opsi yang mungkin
    membantu membuktikan properti yang lebih kompleks.

********
Tutorial
********

Overflow
========

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Overflow {
        uint immutable x;
        uint immutable y;

        function add(uint _x, uint _y) internal pure returns (uint) {
            return _x + _y;
        }

        constructor(uint _x, uint _y) {
            (x, y) = (_x, _y);
        }

        function stateAdd() public view returns (uint) {
            return add(x, y);
        }
    }

Kontrak di atas menunjukkan contoh cek overflow.
SMTChecker tidak memeriksa underflow dan overflow secara default untuk Solidity >=0.8.7,
jadi kita perlu menggunakan opsi baris perintah ``--model-checker-targets "underflow,overflow"``
atau opsi JSON ``settings.modelChecker.targets = ["underflow", "overflow"]``.
Lihat :ref:`bagian ini untuk konfigurasi target<smtchecker_targets>`.
Di sini, ia melaporkan hal berikut:

.. code-block:: text

    Warning: CHC: Overflow (resulting value larger than 2**256 - 1) happens here.
    Counterexample:
    x = 1, y = 115792089237316195423570985008687907853269984665640564039457584007913129639935
     = 0

    Transaction trace:
    Overflow.constructor(1, 115792089237316195423570985008687907853269984665640564039457584007913129639935)
    State: x = 1, y = 115792089237316195423570985008687907853269984665640564039457584007913129639935
    Overflow.stateAdd()
        Overflow.add(1, 115792089237316195423570985008687907853269984665640564039457584007913129639935) -- internal call
     --> o.sol:9:20:
      |
    9 |             return _x + _y;
      |                    ^^^^^^^

Jika kita menambahkan pernyataan ``require`` yang memfilter kasus overflow,
SMTChecker membuktikan bahwa tidak ada overflow yang dapat dijangkau (dengan tidak melaporkan peringatan):

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Overflow {
        uint immutable x;
        uint immutable y;

        function add(uint _x, uint _y) internal pure returns (uint) {
            return _x + _y;
        }

        constructor(uint _x, uint _y) {
            (x, y) = (_x, _y);
        }

        function stateAdd() public view returns (uint) {
            require(x < type(uint128).max);
            require(y < type(uint128).max);
            return add(x, y);
        }
    }


Assert
======

Sebuah pernyataan mewakili invarian dalam kode Anda: sebuah properti yang harus benar
*untuk semua transaksi, termasuk semua nilai input dan penyimpanan*, jika tidak ada bug.

Kode di bawah ini mendefinisikan fungsi ``f`` yang menjamin tidak ada overflow.
Fungsi ``inv`` mendefinisikan spesifikasi bahwa ``f`` meningkat secara monoton:
untuk setiap kemungkinan pasangan ``(_a, _b)``, jika ``_b > _a`` maka ``f(_b) > f(_a)``.
Karena ``f`` memang meningkat secara monoton, SMTChecker membuktikan bahwa properti kita benar.
Anda didorong untuk bermain dengan properti dan definisi fungsi untuk melihat hasil apa yang keluar!

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Monotonic {
        function f(uint _x) internal pure returns (uint) {
            require(_x < type(uint128).max);
            return _x * 42;
        }

        function inv(uint _a, uint _b) public pure {
            require(_b > _a);
            assert(f(_b) > f(_a));
        }
    }

Kami juga dapat menambahkan pernyataan di dalam loop untuk memverifikasi properti yang lebih rumit.
Kode berikut mencari elemen maksimum dari array angka yang tidak
dibatasi, dan menegaskan properti bahwa elemen yang ditemukan harus lebih besar atau
sama dengan setiap elemen dalam array.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Max {
        function max(uint[] memory _a) public pure returns (uint) {
            uint m = 0;
            for (uint i = 0; i < _a.length; ++i)
                if (_a[i] > m)
                    m = _a[i];

            for (uint i = 0; i < _a.length; ++i)
                assert(m >= _a[i]);

            return m;
        }
    }

Perhatikan bahwa dalam contoh ini SMTChecker akan secara otomatis mencoba membuktikan tiga properti:

1. ``++i``di loop pertama tidak overflow.
2. ``++i`` di loop kedua tidak overflow.
3. assertion selalu true.

.. note::

    Properti melibatkan loop, yang membuatnya *jauh* lebih sulit dari sebelumnya
    contoh, jadi waspadalah terhadap loop!

Semua properti benar terbukti aman. Jangan ragu untuk mengubah
properties dan/atau tambahkan batasan pada array untuk melihat hasil yang berbeda.
Misalnya, mengubah kode menjadi

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Max {
        function max(uint[] memory _a) public pure returns (uint) {
            require(_a.length >= 5);
            uint m = 0;
            for (uint i = 0; i < _a.length; ++i)
                if (_a[i] > m)
                    m = _a[i];

            for (uint i = 0; i < _a.length; ++i)
                assert(m > _a[i]);

            return m;
        }
    }

memberi kita:

.. code-block:: text

    Warning: CHC: Assertion violation happens here.
    Counterexample:

    _a = [0, 0, 0, 0, 0]
     = 0

    Transaction trace:
    Test.constructor()
    Test.max([0, 0, 0, 0, 0])
      --> max.sol:14:4:
       |
    14 |            assert(m > _a[i]);


State Properties
================

Sejauh ini contoh-contoh hanya menunjukkan penggunaan SMTTChecker di atas kode murni,
membuktikan properti tentang operasi atau algoritma tertentu.
Jenis properti umum dalam kontrak pintar adalah properti yang melibatkan
status kontrak. Beberapa transaksi mungkin diperlukan untuk membuat *assertion*
gagal untuk properti seperti itu.

Sebagai contoh, perhatikan grid 2D di mana kedua sumbu memiliki koordinat dalam rentang (-2^128, 2^128 - 1).
Mari kita tempatkan robot pada posisi (0, 0). Robot hanya bisa bergerak secara diagonal, selangkah demi selangkah,
dan tidak bisa bergerak di luar grid. Mesin state robot dapat diwakili oleh kontrak pintar
di bawah.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Robot {
        int x = 0;
        int y = 0;

        modifier wall {
            require(x > type(int128).min && x < type(int128).max);
            require(y > type(int128).min && y < type(int128).max);
            _;
        }

        function moveLeftUp() wall public {
            --x;
            ++y;
        }

        function moveLeftDown() wall public {
            --x;
            --y;
        }

        function moveRightUp() wall public {
            ++x;
            ++y;
        }

        function moveRightDown() wall public {
            ++x;
            --y;
        }

        function inv() public view {
            assert((x + y) % 2 == 0);
        }
    }

Fungsi ``inv`` merepresentasikan invarian dari mesin state bahwa ``x + y``
harus genap.
SMTChecker berhasil membuktikan bahwa terlepas dari berapa banyak perintah yang kita berikan kepada
robot, bahkan jika jumlahnya tak terhingga, invarian *tidak akan pernah* gagal. Pembaca yang
tertarik mungkin ingin membuktikan fakta itu secara manual. Petunjuk: invarian ini adalah
induktif.

Kita juga dapat mengelabui SMTChecker agar memberi kita jalur ke posisi tertentu
yang menurut kita dapat dijangkau. Kita dapat menambahkan properti yang (2, 4) *not*
reachable, dengan menambahkan fungsi berikut.

.. code-block:: Solidity

    function reach_2_4() public view {
        assert(!(x == 2 && y == 4));
    }

Properti ini salah, dan sambil membuktikan bahwa properti itu salah,
SMTChecker memberi tahu kita dengan tepat *bagaimana* mencapainya (2, 4):

.. code-block:: text

    Warning: CHC: Assertion violation happens here.
    Counterexample:
    x = 2, y = 4

    Transaction trace:
    Robot.constructor()
    State: x = 0, y = 0
    Robot.moveLeftUp()
    State: x = (- 1), y = 1
    Robot.moveRightUp()
    State: x = 0, y = 2
    Robot.moveRightUp()
    State: x = 1, y = 3
    Robot.moveRightUp()
    State: x = 2, y = 4
    Robot.reach_2_4()
      --> r.sol:35:4:
       |
    35 |            assert(!(x == 2 && y == 4));
       |            ^^^^^^^^^^^^^^^^^^^^^^^^^^^

Perhatikan bahwa jalur di atas belum tentu deterministik, karena ada
jalur lain yang bisa dijangkau (2, 4). Pilihan jalur mana yang ditampilkan
mungkin berubah tergantung pada pemecah yang digunakan, versinya, atau hanya secara acak.

External Call dan Reentrancy
=============================

Setiap panggilan eksternal diperlakukan sebagai panggilan ke kode yang tidak dikenal oleh SMTChecker.
Alasan di balik itu adalah bahwa meskipun kode kontrak yang dipanggil tersedia pada
waktu kompilasi, tidak ada jaminan bahwa kontrak yang digunakan memang akan sama
dengan kontrak dari mana antarmuka berasal pada waktu kompilasi.

Dalam beberapa kasus, dimungkinkan untuk secara otomatis menyimpulkan properti atas
variabel state yang masih benar bahkan jika kode yang dipanggil secara eksternal dapat
melakukan apa saja, termasuk memasukkan kembali kontrak pemanggil.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    interface Unknown {
        function run() external;
    }

    contract Mutex {
        uint x;
        bool lock;

        Unknown immutable unknown;

        constructor(Unknown _u) {
            require(address(_u) != address(0));
            unknown = _u;
        }

        modifier mutex {
            require(!lock);
            lock = true;
            _;
            lock = false;
        }

        function set(uint _x) mutex public {
            x = _x;
        }

        function run() mutex public {
            uint xPre = x;
            unknown.run();
            assert(xPre == x);
        }
    }

Contoh di atas menunjukkan kontrak yang menggunakan flag mutex untuk melarang reentrancy.
Solver dapat menyimpulkan bahwa ketika ``unknown.run()`` dipanggil, kontrak
sudah "dikunci", jadi tidak mungkin mengubah nilai ``x``,
terlepas dari apa yang dilakukan kode yang tidak dikenal.

Jika kita "lupa" untuk menggunakan pengubah ``mutex`` pada fungsi ``set``,
SMTChecker dapat mensintesis perilaku kode yang dipanggil secara eksternal
sehingga pernyataan gagal:

.. code-block:: text

    Warning: CHC: Assertion violation happens here.
    Counterexample:
    x = 1, lock = true, unknown = 1

    Transaction trace:
    Mutex.constructor(1)
    State: x = 0, lock = false, unknown = 1
    Mutex.run()
        unknown.run() -- untrusted external call, synthesized as:
            Mutex.set(1) -- reentrant call
      --> m.sol:32:3:
       |
    32 | 		assert(xPre == x);
       | 		^^^^^^^^^^^^^^^^^


.. _smtchecker_options:

*****************************
SMTChecker Options and Tuning
*****************************

Timeout
=======

SMTChecker menggunakan batas sumber daya hardcoded (``rlimit``) yang dipilih per pemecah,
yang tidak secara tepat terkait dengan waktu. Kami memilih opsi ``rlimit`` sebagai default
karena memberikan lebih banyak jaminan determinisme daripada waktu di dalam solver.

Opsi ini diterjemahkan secara kasar menjadi "batas waktu beberapa detik" per kueri. Tentu saja
banyak sifat yang sangat kompleks dan membutuhkan banyak waktu untuk diselesaikan, di mana
determinisme tidak menjadi masalah. Jika SMTChecker tidak berhasil menyelesaikan properti
kontrak dengan default ``rlimit``, batas waktu dapat diberikan dalam milidetik melalui opsi
CLI ``--model-checker-timeout <time>`` atau opsi JSON ``settings.modelChecker.timeout=<time>``,
di mana 0 berarti tidak ada batas waktu.

.. _smtchecker_targets:

Target Verifikasi
=================

Jenis target verifikasi yang dibuat oleh SMTChecker juga dapat
dikustomisasi melalui opsi CLI ``--model-checker-target <targets>`` atau JSON
opsi ``settings.modelChecker.targets=<targets>``.
Dalam kasus CLI, ``<targets>`` adalah daftar tanpa spasi-koma-dipisahkan dari satu atau
lebih banyak target verifikasi, dan array dari satu atau lebih target sebagai string dalam
input JSON.
Kata kunci yang mewakili target adalah:

- Pernyataan: ``assert``.
- Aritmatika underflow: ``underflow``.
- Aritmatika overflow: ``overflow``.
- Pembagian dengan nol: ``divByZero``.
- Kondisi sepele dan kode yang tidak dapat dijangkau: ``constantCondition``.
- Memunculkan array kosong: ``popEmptyArray``.
- Akses indeks array/byte tetap di luar batas: ``outOfBounds``.
- Dana tidak mencukupi untuk transfer: ``balance``.
- Semua hal di atas: ``default`` (khusus CLI).

Subset umum dari target mungkin, misalnya:
``--model-checker-targets assert,overflow``.

Semua target diperiksa secara default, kecuali underflow dan overflow untuk Solidity >=0.8.7.

Tidak ada heuristik yang tepat tentang bagaimana dan kapan harus membagi target verifikasi,
tetapi dapat berguna terutama ketika berhadapan dengan kontrak besar.

Unproved Targets
================

Jika ada target yang belum terbukti, SMTTChecker mengeluarkan satu peringatan yang menyatakan:
berapa banyak target yang belum terbukti. Jika pengguna ingin melihat semua target
spesifik yang belum terbukti, opsi CLI ``--model-checker-show-unproved`` dan
opsi JSON ``settings.modelChecker.showUnproved = true`` dapat digunakan.

Kontrak Terverifikasi
=====================

Secara default, semua kontrak yang dapat di-deploy dalam sumber yang diberikan dianalisis secara
terpisah sebagai kontrak yang akan di-deploy. Artinya, jika suatu kontrak memiliki banyak
*inheritance parents* langsung dan tidak langsung, semuanya akan dianalisis sendiri-sendiri,
meskipun hanya yang paling turunan yang akan diakses langsung di blockchain. Hal ini menyebabkan
beban yang tidak perlu pada SMTChecker dan solver. Untuk membantu kasus seperti ini, pengguna
dapat menentukan kontrak mana yang harus dianalisis sebagai kontrak yang diterapkan.
Kontrak induk tentu saja masih dianalisis, tetapi hanya dalam konteks kontrak yang paling diturunkan,
mengurangi kerumitan pengkodean dan kueri yang dihasilkan. Perhatikan bahwa kontrak abstrak secara
default tidak dianalisis sebagai kontrak yang paling diturunkan oleh SMTChecker.

Kontrak yang dipilih dapat diberikan melalui daftar yang dipisahkan koma (whitespace
tidak diperbolehkan) dari pasangan <source>:<contract> di CLI:
``--model-checker-contracts "<source1.sol:contract1>,<source2.sol:contract2>,<source2.sol:contract3>"``,
dan melalui objek ``settings.modelChecker.contracts`` di :ref:`JSON input<compiler-api>`,
yang memiliki bentuk sebagai berikut:

.. code-block:: json

    "contracts": {
        "source1.sol": ["contract1"],
        "source2.sol": ["contract2", "contract3"]
    }

Invarian Inductive Inferred yang Dilaporkan
===========================================

Untuk properti yang terbukti aman dengan mesin CHC,
SMTChecker dapat mengambil invarian induktif yang disimpulkan oleh Horn
solver sebagai bagian dari pembuktian.
Saat ini dua jenis invarian dapat dilaporkan kepada pengguna:

- Contract Invariants: ini adalah properti di atas variabel state kontrak yang benar sebelum dan sesudah setiap
  kemungkinan transaksi yang mungkin pernah dijalankan oleh kontrak. Misalnya, ``x >= y``, di mana ``x`` dan ``y`` adalah variabel status kontrak.
- Reentrancy Properties: mereka mewakili perilaku kontrak di hadapan panggilan eksternal ke kode yang tidak dikenal.
  Properti ini dapat mengekspresikan hubungan antara nilai variabel state sebelum dan sesudah panggilan eksternal, di mana panggilan eksternal bebas
  untuk melakukan apa saja, termasuk membuat panggilan masuk kembali ke kontrak yang dianalisis. Variabel prima mewakili nilai variabel state setelah panggilan eksternal tersebut. Contoh: ``lock -> x = x'``.

Pengguna dapat memilih jenis invarian yang akan dilaporkan menggunakan opsi CLI ``--model-checker-invariants "contract,reentrancy"`` atau sebagai array di bidang ``settings.modelChecker.invariants`` di : ref:`JSON input<compiler-api>`.
Secara default, SMTChecker tidak melaporkan invarian.

Division dan Modulo dengan Slack Variables
==========================================

Spacer, Horn solver default yang digunakan oleh SMTTChecker, sering kali tidak menyukai operasi division
dan modulo di dalam aturan Horn. Karena itu, secara default divisi Solidity dan operasi modulo
dikodekan menggunakan batasan ``a = b * d + m`` di mana ``d = a / b`` dan ``m = a % b``.
Namun, solver lain, seperti Eldarica, lebih menyukai operasi sintaksis yang tepat.
Command line flag ``--model-checker-div-mod-no-slacks`` dan opsi JSON
``settings.modelChecker.divModNoSlacks`` dapat digunakan untuk mengaktifkan pengkodean
tergantung pada preferensi solver yang digunakan.

Abstraksi Fungsi Natspec
========================

Fungsi tertentu termasuk metode matematika umum seperti ``pow``
dan ``sqrt`` mungkin terlalu rumit untuk dianalisis dengan cara yang sepenuhnya otomatis.
Fungsi-fungsi ini dapat dijelaskan dengan tag Natspec yang menunjukkan ke
SMTChecker bahwa fungsi-fungsi ini harus diabstraksikan. Ini berarti bahwa
badan fungsi tidak digunakan, dan ketika dipanggil, fungsi akan:

- Kembalikan nilai nondeterministik, dan pertahankan variabel status tidak berubah jika fungsi yang diabstraksi adalah tampilan/murni, atau juga atur variabel status ke nilai nondeterministik sebaliknya. Ini dapat digunakan melalui anotasi ``/// @custom:smtchecker abstract-function-nondet``.
- Bertindak sebagai fungsi yang tidak diinterpretasikan. Ini berarti bahwa semantik fungsi (diberikan oleh tubuh) diabaikan, dan satu-satunya properti yang dimiliki fungsi ini adalah bahwa dengan input yang sama, itu menjamin output yang sama. Ini sedang dalam pengembangan dan akan tersedia melalui anotasi ``/// @custom:smtchecker abstract-function-uf``.

.. _smtchecker_engines:

Model Checking Engines
======================

Modul SMTChecker mengimplementasikan dua mesin penalaran yang berbeda, sebuah Bounded
Model Checker (BMC) dan sistem Constrained Horn Clauses (CHC). Kedua
mesin sedang dalam pengembangan, dan memiliki karakteristik yang berbeda.
Mesinnya independen dan setiap peringatan properti menyatakan dari mesin mana
itu datang. Perhatikan bahwa semua contoh di atas dengan contoh tandingan
dilaporkan oleh CHC, mesin yang lebih kuat.

Secara default kedua mesin digunakan, di mana CHC berjalan lebih dulu, dan setiap properti yang
tidak terbukti diteruskan ke BMC. Anda dapat memilih mesin tertentu melalui opsi
CLI ``--model-checker-engine {all,bmc,chc,none}`` atau opsi JSON
``settings.modelChecker.engine={all,bmc,chc,none}``.

Bounded Model Checker (BMC)
---------------------------

Mesin BMC menganalisis fungsi secara terpisah, yaitu, tidak memerlukan
perilaku kontrak secara keseluruhan atas beberapa transaksi ketika
menganalisis setiap fungsi. Loop juga diabaikan dalam mesin ini saat ini.
Panggilan fungsi internal disejajarkan asalkan tidak rekursif, secara langsung
atau tidak langsung. Panggilan fungsi eksternal disejajarkan jika memungkinkan. Pengetahuan
yang berpotensi dipengaruhi oleh reentrancy akan dihapus.

Karakteristik di atas membuat BMC rentan melaporkan false positive,
tetapi juga ringan dan harus dapat dengan cepat menemukan bug lokal kecil.

Constrained Horn Clauses (CHC)
------------------------------

Control Flow Graph (CFG) kontrak dimodelkan sebagai sistem klausa Horn,
di mana siklus hidup kontrak diwakili oleh loop yang dapat mengunjungi
setiap fungsi publik/eksternal secara non-deterministik. Dengan cara ini,
perilaku seluruh kontrak atas jumlah transaksi yang tidak terbatas diperhitungkan
saat menganalisis fungsi apa pun. Loop didukung penuh oleh mesin ini. Panggilan
fungsi internal didukung, dan panggilan fungsi eksternal menganggap kode yang
dipanggil tidak diketahui dan dapat melakukan apa saja.

Mesin CHC jauh lebih bertenaga daripada BMC dalam hal apa yang dapat dibuktikannya,
dan mungkin memerlukan lebih banyak sumber daya komputasi.

SMT dan Horn solvers
====================

Kedua mesin yang dirinci di atas menggunakan pembuktian teorema otomatis sebagai backend
logisnya. BMC menggunakan SMT solver, sedangkan CHC menggunakan Horn solver.
Seringkali alat yang sama dapat bertindak sebagai keduanya, seperti yang terlihat di
`z3 <https://github.com/Z3Prover/z3>`_, yang terutama merupakan pemecah SMT dan membuat
`Spacer <https://spacer.bitbucket.io/>`_ tersedia sebagai Horn solver, dan
`Eldarica <https://github.com/uuverifiers/eldarica>`_ yang melakukan keduanya.

Pengguna dapat memilih pemecah mana yang harus digunakan, jika tersedia, melalui opsi
CLI ``--model-checker-solvers {all,cvc4,smtlib2,z3}`` atau opsi JSON
``settings.modelChecker.solvers=[smtlib2,z3]``, di mana:

- ``cvc4`` hanya tersedia jika biner ``solc`` dikompilasi dengannya. Hanya BMC yang menggunakan ``cvc4``.
- ``smtlib2`` mengeluarkan kueri SMT/Horn dalam format `smtlib2 <http://smtlib.cs.uiowa.edu/>`_.
   Ini dapat digunakan bersama dengan kompiler `callback mechanism <https://github.com/ethereum/solc-js>`_ sehingga
   solver binary apa pun dari sistem dapat digunakan untuk secara sinkron mengembalikan hasil kueri ke kompiler.
   Saat ini satu-satunya cara untuk menggunakan Eldarica, misalnya, karena tidak memiliki C++ API.
   Ini dapat digunakan oleh BMC dan CHC tergantung pada pemecah yang dipanggil.
- ``z3`` tersedia

  - jika ``solc`` dikompilasi dengannya;
  - jika library ``z3`` dinamis versi 4.8.x diinstal di sistem Linux (dari Solidity 0.7.6);
  - secara statis di ``soljson.js`` (dari Solidity 0.6.9), yaitu, biner Javascript dari compiler.

Karena BMC dan CHC menggunakan ``z3``, dan ``z3`` tersedia di lebih banyak variasi lingkungan,
termasuk di browser, sebagian besar pengguna hampir tidak perlu khawatir tentang opsi ini. Pengguna
yang lebih mahir mungkin menerapkan opsi ini untuk mencoba pemecah alternatif pada masalah yang
lebih kompleks.

Harap dicatat bahwa kombinasi tertentu dari mesin dan pemecah yang dipilih akan menyebabkan
SMTChecker tidak melakukan apa-apa, misalnya memilih CHC dan ``cvc4``.

*******************************
Abstraction dan False Positives
*******************************

SMTChecker mengimplementasikan abstraksi dengan cara yang tidak lengkap dan sehat: Jika ada bug
dilaporkan, itu mungkin false positive yang diperkenalkan oleh abstraksi (karena
menghapus pengetahuan atau menggunakan tipe yang tidak tepat). Jika ditentukan bahwa
target verifikasi aman, memang aman, yaitu tidak ada yang false
negatif (kecuali ada bug di SMTTChecker).

Jika target tidak dapat dibuktikan, Anda dapat mencoba membantu solver dengan
menggunakan opsi tuning di bagian sebelumnya.
Jika Anda yakin dengan false positive, tambahkan pernyataan ``require`` dalam kode
dengan lebih banyak informasi juga dapat memberikan lebih banyak kekuatan untuk pemecah.

SMT Encoding dan Types
======================

Pengkodean SMTChecker mencoba setepat mungkin, memetakan tipe Solidity
dan ekspresi ke representasi `SMT-LIB <http://smtlib.cs.uiowa.edu/>`_ terdekat,
seperti yang ditunjukkan pada tabel di bawah.

+-----------------------+--------------------------------+-----------------------------+
|Solidity type          |SMT sort                        |Theories                     |
+=======================+================================+=============================+
|Boolean                |Bool                            |Bool                         |
+-----------------------+--------------------------------+-----------------------------+
|intN, uintN, address,  |Integer                         |LIA, NIA                     |
|bytesN, enum, contract |                                |                             |
+-----------------------+--------------------------------+-----------------------------+
|array, mapping, bytes, |Tuple                           |Datatypes, Arrays, LIA       |
|string                 |(Array elements, Integer length)|                             |
+-----------------------+--------------------------------+-----------------------------+
|struct                 |Tuple                           |Datatypes                    |
+-----------------------+--------------------------------+-----------------------------+
|other types            |Integer                         |LIA                          |
+-----------------------+--------------------------------+-----------------------------+

Jenis yang belum didukung diabstraksikan oleh satu 256-bit unsigned
integer, di mana operasi mereka yang tidak didukung diabaikan.

Untuk detail lebih lanjut tentang bagaimana pengkodean SMT bekerja secara internal, lihat makalah
`Verifikasi Smart Kontrak Solidity berbasis SMT <https://github.com/leonardoalt/text/blob/master/solidity_isola_2018/main.pdf>`_.

Function Calls
==============

Di mesin BMC, panggilan fungsi ke kontrak yang sama (atau kontrak dasar) di-inlined
jika memungkinkan, yaitu saat implementasinya tersedia. Panggilan ke fungsi dalam kontrak lain
tidak di-inlined meskipun kodenya tersedia, karena kami tidak dapat menjamin bahwa kode yang
diterapkan sebenarnya sama.

Mesin CHC membuat klausa Horn nonlinier yang menggunakan ringkasan fungsi yang dipanggil
untuk mendukung panggilan fungsi internal. Panggilan fungsi eksternal diperlakukan
sebagai panggilan ke kode yang tidak dikenal, termasuk reentrant call yang potensial.

Fungsi pure yang kompleks diabstraksikan oleh fungsi yang tidak ditafsirkan (UF) di atas
argumen.

+-----------------------------------+--------------------------------------+
|Functions                          |Perilaku BMC/CHC                      |
+===================================+======================================+
|``assert``                         |Target verifikasi.                    |
+-----------------------------------+--------------------------------------+
|``require``                        |Asumsi.                               |
+-----------------------------------+--------------------------------------+
|internal call                      |BMC: Inline function call.            |
|                                   |CHC: Function summaries.              |
+-----------------------------------+--------------------------------------+
|external call to known code        |BMC: Inline function call atau        |
|                                   |menghapus knowledge tentang variabel  |
|                                   |state dan local storage references.   |
|                                   |CHC: Mwngasumsikan kode yang dipanggil|
|                                   |adalah unknown. Cobalah untuk         |
|                                   |menyimpulkan invarian yang bertahan   |
|                                   |setelah panggilan return.             |
+-----------------------------------+--------------------------------------+
|Storage array push/pop             |Didukung secara tepat.                |
|                                   |Memeriksa apakah itu memunculkan      |
|                                   |array kosong.                         |
+-----------------------------------+--------------------------------------+
|ABI functions                      |Diabstraksikan dengan UF.             |
+-----------------------------------+--------------------------------------+
|``addmod``, ``mulmod``             |Didukung secara tepat.                |
+-----------------------------------+--------------------------------------+
|``gasleft``, ``blockhash``,        |Diabstraksikan dengan UF.             |
|``keccak256``, ``ecrecover``       |                                      |
|``ripemd160``                      |                                      |
+-----------------------------------+--------------------------------------+
|pure functions without             |Diabstraksikan dengan UF.             |
|implementation (external or        |                                      |
|complex)                           |                                      |
+-----------------------------------+--------------------------------------+
|external functions without         |BMC: menghapus state knowledge dan    |
|implementation                     |anggap hasilnya nondeterminisc.       |
|                                   |CHC: Ringkasan Nondeterministic.      |
|                                   |Cobalah untuk menyimpulkan invarian   |
|                                   |yang bertahan setelah call returns.   |
+-----------------------------------+--------------------------------------+
|transfer                           |BMC: Memeriksa apakah                 |
|                                   |saldo kontrak mencukupi.              |
|                                   |CHC: belum melakukan pemeriksaan.     |
+-----------------------------------+--------------------------------------+
|others                             |Saat ini tidak didukung               |
+-----------------------------------+--------------------------------------+

Menggunakan abstraksi berarti kehilangan pengetahuan yang tepat, tetapi dalam banyak kasus
itu tidak berarti kehilangan kekuatan pembuktian.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Recover
    {
        function f(
            bytes32 hash,
            uint8 _v1, uint8 _v2,
            bytes32 _r1, bytes32 _r2,
            bytes32 _s1, bytes32 _s2
        ) public pure returns (address) {
            address a1 = ecrecover(hash, _v1, _r1, _s1);
            require(_v1 == _v2);
            require(_r1 == _r2);
            require(_s1 == _s2);
            address a2 = ecrecover(hash, _v2, _r2, _s2);
            assert(a1 == a2);
            return a1;
        }
    }

Dalam contoh di atas, SMTChecker tidak cukup ekspresif untuk benar-benar menghitung ``ecrecover``,
tetapi dengan memodelkan pemanggilan fungsi sebagai fungsi yang tidak diinterpretasikan, kita tahu
bahwa nilai yang dikembalikan adalah sama ketika dipanggil pada parameter yang setara. Ini cukup untuk
membuktikan bahwa pernyataan di atas selalu benar.

Mengabstraksi panggilan fungsi dengan UF dapat dilakukan untuk fungsi yang diketahui deterministik,
dan dapat dengan mudah dilakukan untuk fungsi pure. Namun sulit untuk melakukan ini dengan fungsi
eksternal umum, karena mereka mungkin bergantung pada variabel state.

Reference Types dan Aliasing
============================

Solidity mengimplementasikan aliasing untuk tipe referensi dengan
:ref:`lokasi data <data-location>` yang sama.
Itu berarti satu variabel dapat dimodifikasi melalui referensi ke area data
yang sama.
SMTChecker tidak melacak referensi mana yang merujuk ke data yang sama.
Ini menyiratkan bahwa setiap kali referensi lokal atau variabel state tipe referensi ditetapkan,
semua pengetahuan tentang variabel dengan tipe dan lokasi data yang sama dihapus.
Jika tipenya nested, penghapusan pengetahuan juga mencakup semua tipe dasar awalan.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Aliasing
    {
        uint[] array1;
        uint[][] array2;
        function f(
            uint[] memory a,
            uint[] memory b,
            uint[][] memory c,
            uint[] storage d
        ) internal {
            array1[0] = 42;
            a[0] = 2;
            c[0][0] = 2;
            b[0] = 1;
            // Erasing knowledge about memory references should not
            // erase knowledge about state variables.
            assert(array1[0] == 42);
            // However, an assignment to a storage reference will erase
            // storage knowledge accordingly.
            d[0] = 2;
            // Fails as false positive because of the assignment above.
            assert(array1[0] == 42);
            // Fails because `a == b` is possible.
            assert(a[0] == 2);
            // Fails because `c[i] == b` is possible.
            assert(c[0][0] == 2);
            assert(d[0] == 2);
            assert(b[0] == 1);
        }
        function g(
            uint[] memory a,
            uint[] memory b,
            uint[][] memory c,
            uint x
        ) public {
            f(a, b, c, array2[x]);
        }
    }

Setelah assignment ke ``b[0]``, kita perlu menghapus pengetahuan tentang ``a`` karena
memiliki tipe yang sama (``uint[]``) dan lokasi data (memori). Kita juga perlu
pengetahuan yang jelas tentang ``c``, karena tipe dasarnya juga terletak di ``uint[]``
dalam memori. Ini menyiratkan bahwa beberapa ``c[i]`` dapat merujuk ke data yang sama dengan
``b`` atau ``a``.

Perhatikan bahwa kita tidak menghapus pengetahuan tentang ``array`` dan ``d`` karena keduanya
terletak di penyimpanan, meskipun mereka juga memiliki tipe ``uint[]``. Namun,
jika ``d`` ditetapkan, kita perlu menghapus pengetahuan tentang ``array`` dan
sebaliknya.

Saldo Kontrak
=============

Kontrak dapat di-deploy dengan dana yang dikirim ke sana, jika ``msg.value`` > 0 saat
transaksi deployment.
Namun, alamat kontrak mungkin sudah memiliki dana sebelum deployment,
yang disimpan oleh kontrak.
Oleh karena itu, SMTChecker mengasumsikan bahwa ``address(this).balance >= msg.value``
di konstruktor agar konsisten dengan aturan EVM.
Saldo kontrak juga dapat meningkat tanpa memicu panggilan ke
kontrak, jika

- ``selfdestruct`` dieksekusi oleh kontrak lain dengan kontrak yang dianalisis
  sebagai target sisa dana,
- kontraknya adalah coinbase (yaitu, ``block.coinbase``) dari beberapa blok.

Untuk memodelkan ini dengan benar, SMTChecker mengasumsikan bahwa pada setiap transaksi baru
saldo kontrak dapat bertambah dengan setidaknya ``msg.value``.

**********************
Asumsi Dunia Nyata
**********************

Beberapa skenario dapat diekspresikan dalam Solidity dan EVM, tetapi diharapkan untuk
tidak pernah terjadi dalam praktik.
Salah satu kasus tersebut adalah panjang array penyimpanan dinamis yang meluap selama
push: Jika operasi ``push`` diterapkan ke array dengan panjang 2^256 - 1, panjangnya
akan overflow secara diam-diam.
Namun, ini tidak mungkin terjadi dalam praktiknya, karena operasi yang diperlukan untuk menumbuhkan
array ke titik itu akan membutuhkan waktu miliaran tahun untuk dieksekusi.
Asumsi serupa lainnya yang diambil oleh SMTChecker adalah bahwa saldo alamat
tidak pernah bisa overflow.

Ide serupa disampaikan di `EIP-1985 <https://eips.ethereum.org/EIPS/eip-1985>`_.
