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

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Overflow {
        uint immutable x;
        uint immutable y;

        function add(uint x_, uint y_) internal pure returns (uint) {
            return x_ + y_;
        }

        constructor(uint x_, uint y_) {
            (x, y) = (x_, y_);
        }

        function stateAdd() public view returns (uint) {
            return add(x, y);
        }
    }

<<<<<<< HEAD
Kontrak di atas menunjukkan contoh cek overflow.
SMTChecker tidak memeriksa underflow dan overflow secara default untuk Solidity >=0.8.7,
jadi kita perlu menggunakan opsi baris perintah ``--model-checker-targets "underflow,overflow"``
atau opsi JSON ``settings.modelChecker.targets = ["underflow", "overflow"]``.
Lihat :ref:`bagian ini untuk konfigurasi target<smtchecker_targets>`.
Di sini, ia melaporkan hal berikut:
=======
The contract above shows an overflow check example.
The SMTChecker does not check underflow and overflow by default for Solidity >=0.8.7,
so we need to use the command-line option ``--model-checker-targets "underflow,overflow"``
or the JSON option ``settings.modelChecker.targets = ["underflow", "overflow"]``.
See :ref:`this section for targets configuration<smtchecker_targets>`.
Here, it reports the following:
>>>>>>> english/develop

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
    9 |             return x_ + y_;
      |                    ^^^^^^^

Jika kita menambahkan pernyataan ``require`` yang memfilter kasus overflow,
SMTChecker membuktikan bahwa tidak ada overflow yang dapat dijangkau (dengan tidak melaporkan peringatan):

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Overflow {
        uint immutable x;
        uint immutable y;

        function add(uint x_, uint y_) internal pure returns (uint) {
            return x_ + y_;
        }

        constructor(uint x_, uint y_) {
            (x, y) = (x_, y_);
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

<<<<<<< HEAD
Kode di bawah ini mendefinisikan fungsi ``f`` yang menjamin tidak ada overflow.
Fungsi ``inv`` mendefinisikan spesifikasi bahwa ``f`` meningkat secara monoton:
untuk setiap kemungkinan pasangan ``(_a, _b)``, jika ``_b > _a`` maka ``f(_b) > f(_a)``.
Karena ``f`` memang meningkat secara monoton, SMTChecker membuktikan bahwa properti kita benar.
Anda didorong untuk bermain dengan properti dan definisi fungsi untuk melihat hasil apa yang keluar!
=======
The code below defines a function ``f`` that guarantees no overflow.
Function ``inv`` defines the specification that ``f`` is monotonically increasing:
for every possible pair ``(a, b)``, if ``b > a`` then ``f(b) > f(a)``.
Since ``f`` is indeed monotonically increasing, the SMTChecker proves that our
property is correct. You are encouraged to play with the property and the function
definition to see what results come out!
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Monotonic {
        function f(uint x) internal pure returns (uint) {
            require(x < type(uint128).max);
            return x * 42;
        }

        function inv(uint a, uint b) public pure {
            require(b > a);
            assert(f(b) > f(a));
        }
    }

Kami juga dapat menambahkan pernyataan di dalam loop untuk memverifikasi properti yang lebih rumit.
Kode berikut mencari elemen maksimum dari array angka yang tidak
dibatasi, dan menegaskan properti bahwa elemen yang ditemukan harus lebih besar atau
sama dengan setiap elemen dalam array.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Max {
        function max(uint[] memory a) public pure returns (uint) {
            uint m = 0;
            for (uint i = 0; i < a.length; ++i)
                if (a[i] > m)
                    m = a[i];

            for (uint i = 0; i < a.length; ++i)
                assert(m >= a[i]);

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

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Max {
        function max(uint[] memory a) public pure returns (uint) {
            require(a.length >= 5);
            uint m = 0;
            for (uint i = 0; i < a.length; ++i)
                if (a[i] > m)
                    m = a[i];

            for (uint i = 0; i < a.length; ++i)
                assert(m > a[i]);

            return m;
        }
    }

memberi kita:

.. code-block:: text

    Warning: CHC: Assertion violation happens here.
    Counterexample:

    a = [0, 0, 0, 0, 0]
     = 0

    Transaction trace:
    Test.constructor()
    Test.max([0, 0, 0, 0, 0])
      --> max.sol:14:4:
       |
    14 |            assert(m > a[i]);


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

.. code-block:: solidity

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

.. code-block:: solidity

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

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    interface Unknown {
        function run() external;
    }

    contract Mutex {
        uint x;
        bool lock;

        Unknown immutable unknown;

        constructor(Unknown u) {
            require(address(u) != address(0));
            unknown = u;
        }

        modifier mutex {
            require(!lock);
            lock = true;
            _;
            lock = false;
        }

        function set(uint x_) mutex public {
            x = x_;
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

<<<<<<< HEAD
Jika kita "lupa" untuk menggunakan pengubah ``mutex`` pada fungsi ``set``,
SMTChecker dapat mensintesis perilaku kode yang dipanggil secara eksternal
sehingga pernyataan gagal:
=======
If we "forget" to use the ``mutex`` modifier on function ``set``, the
SMTChecker is able to synthesize the behavior of the externally called code so
that the assertion fails:
>>>>>>> english/develop

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

Proved Targets
==============

If there are any proved targets, the SMTChecker issues one warning per engine stating
how many targets were proved. If the user wishes to see all the specific
proved targets, the CLI option ``--model-checker-show-proved`` and
the JSON option ``settings.modelChecker.showProved = true`` can be used.

Unproved Targets
================

Jika ada target yang belum terbukti, SMTTChecker mengeluarkan satu peringatan yang menyatakan:
berapa banyak target yang belum terbukti. Jika pengguna ingin melihat semua target
spesifik yang belum terbukti, opsi CLI ``--model-checker-show-unproved`` dan
opsi JSON ``settings.modelChecker.showUnproved = true`` dapat digunakan.

<<<<<<< HEAD
Kontrak Terverifikasi
=====================
=======
Unsupported Language Features
=============================

Certain Solidity language features are not completely supported by the SMT
encoding that the SMTChecker applies, for example assembly blocks.
The unsupported construct is abstracted via overapproximation to preserve
soundness, meaning any properties reported safe are safe even though this
feature is unsupported.
However such abstraction may cause false positives when the target properties
depend on the precise behavior of the unsupported feature.
If the encoder encounters such cases it will by default report a generic warning
stating how many unsupported features it has seen.
If the user wishes to see all the specific unsupported features, the CLI option
``--model-checker-show-unsupported`` and the JSON option
``settings.modelChecker.showUnsupported = true`` can be used, where their default
value is ``false``.

Verified Contracts
==================
>>>>>>> english/develop

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

<<<<<<< HEAD
Invarian Inductive Inferred yang Dilaporkan
===========================================

Untuk properti yang terbukti aman dengan mesin CHC,
SMTChecker dapat mengambil invarian induktif yang disimpulkan oleh Horn
solver sebagai bagian dari pembuktian.
Saat ini dua jenis invarian dapat dilaporkan kepada pengguna:
=======
Trusted External Calls
======================

By default, the SMTChecker does not assume that compile-time available code
is the same as the runtime code for external calls. Take the following contracts
as an example:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract Ext {
        uint public x;
        function setX(uint _x) public { x = _x; }
    }
    contract MyContract {
        function callExt(Ext _e) public {
            _e.setX(42);
            assert(_e.x() == 42);
        }
    }

When ``MyContract.callExt`` is called, an address is given as the argument.
At deployment time, we cannot know for sure that address ``_e`` actually
contains a deployment of contract ``Ext``.
Therefore, the SMTChecker will warn that the assertion above can be violated,
which is true, if ``_e`` contains another contract than ``Ext``.

However, it can be useful to treat these external calls as trusted, for example,
to test that different implementations of an interface conform to the same property.
This means assuming that address ``_e`` indeed was deployed as contract ``Ext``.
This mode can be enabled via the CLI option ``--model-checker-ext-calls=trusted``
or the JSON field ``settings.modelChecker.extCalls: "trusted"``.

Please be aware that enabling this mode can make the SMTChecker analysis much more
computationally costly.

An important part of this mode is that it is applied to contract types and high
level external calls to contracts, and not low level calls such as ``call`` and
``delegatecall``. The storage of an address is stored per contract type, and
the SMTChecker assumes that an externally called contract has the type of the
caller expression.  Therefore, casting an ``address`` or a contract to
different contract types will yield different storage values and can give
unsound results if the assumptions are inconsistent, such as the example below:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract D {
        constructor(uint _x) { x = _x; }
        uint public x;
        function setX(uint _x) public { x = _x; }
    }

    contract E {
        constructor() { x = 2; }
        uint public x;
        function setX(uint _x) public { x = _x; }
    }

    contract C {
        function f() public {
            address d = address(new D(42));

            // `d` was deployed as `D`, so its `x` should be 42 now.
            assert(D(d).x() == 42); // should hold
            assert(D(d).x() == 43); // should fail

            // E and D have the same interface, so the following
            // call would also work at runtime.
            // However, the change to `E(d)` is not reflected in `D(d)`.
            E(d).setX(1024);

            // Reading from `D(d)` now will show old values.
            // The assertion below should fail at runtime,
            // but succeeds in this mode's analysis (unsound).
            assert(D(d).x() == 42);
            // The assertion below should succeed at runtime,
            // but fails in this mode's analysis (false positive).
            assert(D(d).x() == 1024);
        }
    }

Due to the above, make sure that the trusted external calls to a certain
variable of ``address`` or ``contract`` type always have the same caller
expression type.

It is also helpful to cast the called contract's variable as the type of the
most derived type in case of inheritance.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    interface Token {
        function balanceOf(address _a) external view returns (uint);
        function transfer(address _to, uint _amt) external;
    }

    contract TokenCorrect is Token {
        mapping (address => uint) balance;
        constructor(address _a, uint _b) {
            balance[_a] = _b;
        }
        function balanceOf(address _a) public view override returns (uint) {
            return balance[_a];
        }
        function transfer(address _to, uint _amt) public override {
            require(balance[msg.sender] >= _amt);
            balance[msg.sender] -= _amt;
            balance[_to] += _amt;
        }
    }

    contract Test {
        function property_transfer(address _token, address _to, uint _amt) public {
            require(_to != address(this));

            TokenCorrect t = TokenCorrect(_token);

            uint xPre = t.balanceOf(address(this));
            require(xPre >= _amt);
            uint yPre = t.balanceOf(_to);

            t.transfer(_to, _amt);
            uint xPost = t.balanceOf(address(this));
            uint yPost = t.balanceOf(_to);

            assert(xPost == xPre - _amt);
            assert(yPost == yPre + _amt);
        }
    }

Note that in function ``property_transfer``, the external calls are
performed on variable ``t``.

Another caveat of this mode are calls to state variables of contract type
outside the analyzed contract. In the code below, even though ``B`` deploys
``A``, it is also possible for the address stored in ``B.a`` to be called by
anyone outside of ``B`` in between transactions to ``B`` itself. To reflect the
possible changes to ``B.a``, the encoding allows an unbounded number of calls
to be made to ``B.a`` externally. The encoding will keep track of ``B.a``'s
storage, therefore assertion (2) should hold. However, currently the encoding
allows such calls to be made from ``B`` conceptually, therefore assertion (3)
fails.  Making the encoding stronger logically is an extension of the trusted
mode and is under development. Note that the encoding does not keep track of
storage for ``address`` variables, therefore if ``B.a`` had type ``address``
the encoding would assume that its storage does not change in between
transactions to ``B``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0;

    contract A {
        uint public x;
        address immutable public owner;
        constructor() {
            owner = msg.sender;
        }
        function setX(uint _x) public {
            require(msg.sender == owner);
            x = _x;
        }
    }

    contract B {
        A a;
        constructor() {
            a = new A();
            assert(a.x() == 0); // (1) should hold
        }
        function g() public view {
            assert(a.owner() == address(this)); // (2) should hold
            assert(a.x() == 0); // (3) should hold, but fails due to a false positive
        }
    }

Reported Inferred Inductive Invariants
======================================

For properties that were proved safe with the CHC engine,
the SMTChecker can retrieve inductive invariants that were inferred by the Horn
solver as part of the proof.
Currently only two types of invariants can be reported to the user:
>>>>>>> english/develop

- Contract Invariants: ini adalah properti di atas variabel state kontrak yang benar sebelum dan sesudah setiap
  kemungkinan transaksi yang mungkin pernah dijalankan oleh kontrak. Misalnya, ``x >= y``, di mana ``x`` dan ``y`` adalah variabel status kontrak.
- Reentrancy Properties: mereka mewakili perilaku kontrak di hadapan panggilan eksternal ke kode yang tidak dikenal.
  Properti ini dapat mengekspresikan hubungan antara nilai variabel state sebelum dan sesudah panggilan eksternal, di mana panggilan eksternal bebas
  untuk melakukan apa saja, termasuk membuat panggilan masuk kembali ke kontrak yang dianalisis. Variabel prima mewakili nilai variabel state setelah panggilan eksternal tersebut. Contoh: ``lock -> x = x'``.

Pengguna dapat memilih jenis invarian yang akan dilaporkan menggunakan opsi CLI ``--model-checker-invariants "contract,reentrancy"`` atau sebagai array di bidang ``settings.modelChecker.invariants`` di : ref:`JSON input<compiler-api>`.
Secara default, SMTChecker tidak melaporkan invarian.

Division dan Modulo dengan Slack Variables
==========================================

<<<<<<< HEAD
Spacer, Horn solver default yang digunakan oleh SMTTChecker, sering kali tidak menyukai operasi division
dan modulo di dalam aturan Horn. Karena itu, secara default divisi Solidity dan operasi modulo
dikodekan menggunakan batasan ``a = b * d + m`` di mana ``d = a / b`` dan ``m = a % b``.
Namun, solver lain, seperti Eldarica, lebih menyukai operasi sintaksis yang tepat.
Command line flag ``--model-checker-div-mod-no-slacks`` dan opsi JSON
``settings.modelChecker.divModNoSlacks`` dapat digunakan untuk mengaktifkan pengkodean
tergantung pada preferensi solver yang digunakan.
=======
Spacer, the default Horn solver used by the SMTChecker, often dislikes division
and modulo operations inside Horn rules. Because of that, by default the
Solidity division and modulo operations are encoded using the constraint
``a = b * d + m`` where ``d = a / b`` and ``m = a % b``.
However, other solvers, such as Eldarica, prefer the syntactically precise operations.
The command-line flag ``--model-checker-div-mod-no-slacks`` and the JSON option
``settings.modelChecker.divModNoSlacks`` can be used to toggle the encoding
depending on the used solver preferences.
>>>>>>> english/develop

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

<<<<<<< HEAD
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
=======
The user can choose which solvers should be used, if available, via the CLI
option ``--model-checker-solvers {all,cvc4,eld,smtlib2,z3}`` or the JSON option
``settings.modelChecker.solvers=[smtlib2,z3]``, where:

- ``cvc4`` is only available if the ``solc`` binary is compiled with it. Only BMC uses ``cvc4``.
- ``eld`` is used via its binary which must be installed in the system. Only CHC uses ``eld``, and only if ``z3`` is not enabled.
- ``smtlib2`` outputs SMT/Horn queries in the `smtlib2 <http://smtlib.cs.uiowa.edu/>`_ format.
  These can be used together with the compiler's `callback mechanism <https://github.com/ethereum/solc-js>`_ so that
  any solver binary from the system can be employed to synchronously return the results of the queries to the compiler.
  This can be used by both BMC and CHC depending on which solvers are called.
- ``z3`` is available

  - if ``solc`` is compiled with it;
  - if a dynamic ``z3`` library of version >=4.8.x is installed in a Linux system (from Solidity 0.7.6);
  - statically in ``soljson.js`` (from Solidity 0.6.9), that is, the JavaScript binary of the compiler.

.. note::
  z3 version 4.8.16 broke ABI compatibility with previous versions and cannot
  be used with solc <=0.8.13. If you are using z3 >=4.8.16 please use solc
  >=0.8.14, and conversely, only use older z3 with older solc releases.
  We also recommend using the latest z3 release which is what SMTChecker also does.
>>>>>>> english/develop

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

<<<<<<< HEAD
Untuk detail lebih lanjut tentang bagaimana pengkodean SMT bekerja secara internal, lihat makalah
`Verifikasi Smart Kontrak Solidity berbasis SMT <https://github.com/leonardoalt/text/blob/master/solidity_isola_2018/main.pdf>`_.
=======
For more details on how the SMT encoding works internally, see the paper
`SMT-based Verification of Solidity Smart Contracts <https://github.com/chriseth/solidity_isola/blob/master/main.pdf>`_.
>>>>>>> english/develop

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
            uint8 v1, uint8 v2,
            bytes32 r1, bytes32 r2,
            bytes32 s1, bytes32 s2
        ) public pure returns (address) {
            address a1 = ecrecover(hash, v1, r1, s1);
            require(v1 == v2);
            require(r1 == r2);
            require(s1 == s2);
            address a2 = ecrecover(hash, v2, r2, s2);
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
