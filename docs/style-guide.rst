.. index:: style, coding style

#############
Panduan Gaya
#############

************
pengantar
************

<<<<<<< HEAD
Panduan ini dimaksudkan untuk memberikan konvensi pengkodean untuk menulis kode solidity.
Panduan ini harus dianggap sebagai dokumen yang berkembang yang akan berubah seiring waktu
karena konvensi yang berguna ditemukan dan konvensi lama dianggap usang.
=======
This guide is intended to provide coding conventions for writing Solidity code.
This guide should be thought of as an evolving document that will change over
time as useful conventions are found and old conventions are rendered obsolete.
>>>>>>> english/develop

Banyak proyek akan menerapkan panduan gaya mereka sendiri. Jika terjadi konflik,
panduan gaya proyek tertentu diutamakan.

<<<<<<< HEAD
Struktur dan banyak rekomendasi dalam panduan gaya ini
diambil dari python
`pep8 style guide <https://www.python.org/dev/peps/pep-0008/>`_.

Tujuan dari panduan ini adalah *bukan* menjadi cara yang benar atau cara terbaik untuk menulis
kode solidity. Tujuan dari panduan ini adalah *konsistensi*. Kutipan dari python's
`pep8 <https://www.python.org/dev/peps/pep-0008/#a-foolish-consistency-is-the-hobgoblin-of-little-minds>`_
menangkap konsep ini dengan baik.
=======
The structure and many of the recommendations within this style guide were
taken from Python's
`pep8 style guide <https://peps.python.org/pep-0008/>`_.

The goal of this guide is *not* to be the right way or the best way to write
Solidity code.  The goal of this guide is *consistency*.  A quote from Python's
`pep8 <https://peps.python.org/pep-0008/#a-foolish-consistency-is-the-hobgoblin-of-little-minds>`_
captures this concept well.
>>>>>>> english/develop

.. note::

    Panduan gaya adalah tentang konsistensi. Konsistensi dengan panduan gaya ini penting. Konsistensi dalam sebuah proyek lebih penting. Konsistensi dalam satu modul atau fungsi adalah yang paling penting.

<<<<<<< HEAD
    Namun yang terpenting: **tahu kapan harus tidak konsisten** -- terkadang panduan gaya tidak berlaku. Jika ragu, gunakan penilaian terbaik Anda. Lihat contoh lain dan putuskan apa yang terlihat terbaik. Dan jangan ragu untuk bertanya!
=======
    But most importantly: **know when to be inconsistent** -- sometimes the style guide just doesn't apply. When in doubt, use your best judgment. Look at other examples and decide what looks best. And do not hesitate to ask!
>>>>>>> english/develop


***********
Layout kode
***********


Indentasi
===========

Gunakan 4 spasi per level indentasi.

Tab atau Spasi
==============

Spasi adalah metode indentasi yang disarankan.

Pencampuran tab dan spasi harus dihindari.

Garis Kosong
============

<<<<<<< HEAD
Mengelilingi deklarasi tingkat atas di sumber solidity dengan dua baris kosong.
=======
Surround top level declarations in Solidity source with two blank lines.
>>>>>>> english/develop

Ya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }


    contract B {
        // ...
    }


    contract C {
        // ...
    }

Tidak:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }
    contract B {
        // ...
    }

    contract C {
        // ...
    }

Dalam deklarasi fungsi surround kontrak dengan satu baris kosong.

Baris kosong dapat dihilangkan di antara grup satu baris terkait (seperti fungsi rintisan untuk kontrak abstrak)

Ya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract A {
        function spam() public virtual pure;
        function ham() public virtual pure;
    }


    contract B is A {
        function spam() public pure override {
            // ...
        }

        function ham() public pure override {
            // ...
        }
    }

Tidak:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract A {
        function spam() virtual pure public;
        function ham() public virtual pure;
    }


    contract B is A {
        function spam() public pure override {
            // ...
        }
        function ham() public pure override {
            // ...
        }
    }

.. _maximum_line_length:

Panjang Garis Maksimum
======================

<<<<<<< HEAD
Menjaga garis di bawah `rekomendasi PEP 8 <https://www.python.org/dev/peps/pep-0008/#maximum-line-length>`_ hingga maksimum 79 (atau 99)
karakter membantu pembaca dengan mudah mengurai kode.
=======
Maximum suggested line length is 120 characters.
>>>>>>> english/develop

Garis yang dibungkus harus sesuai dengan pedoman berikut.

1. Argumen pertama tidak boleh dilampirkan pada kurung buka.
2. Satu, dan hanya satu, indentasi harus digunakan.
3. Setiap argumen harus berada pada jalurnya sendiri.
4. Elemen pengakhiran, :code:`);`, harus ditempatkan pada baris terakhir dengan sendirinya.

Fungsi Call

Ya:

.. code-block:: solidity

    thisFunctionCallIsReallyLong(
        longArgument1,
        longArgument2,
        longArgument3
    );

Tidak:

.. code-block:: solidity

    thisFunctionCallIsReallyLong(longArgument1,
                                  longArgument2,
                                  longArgument3
    );

    thisFunctionCallIsReallyLong(longArgument1,
        longArgument2,
        longArgument3
    );

    thisFunctionCallIsReallyLong(
        longArgument1, longArgument2,
        longArgument3
    );

    thisFunctionCallIsReallyLong(
    longArgument1,
    longArgument2,
    longArgument3
    );

    thisFunctionCallIsReallyLong(
        longArgument1,
        longArgument2,
        longArgument3);

Pernyataan Assignment

Ya:

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(
        argument1,
        argument2,
        argument3,
        argument4
    );

Tidak:

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(argument1,
                                                                       argument2,
                                                                       argument3,
                                                                       argument4);

Event Definitions dan Event Emitters

Ya:

.. code-block:: solidity

    event LongAndLotsOfArgs(
        address sender,
        address recipient,
        uint256 publicKey,
        uint256 amount,
        bytes32[] options
    );

    emit LongAndLotsOfArgs(
        sender,
        recipient,
        publicKey,
        amount,
        options
    );

Tidak:

.. code-block:: solidity

    event LongAndLotsOfArgs(address sender,
                            address recipient,
                            uint256 publicKey,
                            uint256 amount,
                            bytes32[] options);

    emit LongAndLotsOfArgs(sender,
                      recipient,
                      publicKey,
                      amount,
                      options);

Source File Encoding
====================

UTF-8 atau ASCII encoding diutamakan.

Imports
=======

Pernyataan Import harus selalu ditempatkan di bagian atas file.

Ya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    import "./Owned.sol";

    contract A {
        // ...
    }


    contract B is Owned {
        // ...
    }

Tidak:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }


    import "./Owned.sol";


    contract B is Owned {
        // ...
    }

Urutan Fungsi
=============

Pengurutan membantu pembaca mengidentifikasi fungsi mana yang dapat mereka panggil dan untuk menemukan definisi konstruktor dan fallback dengan lebih mudah.

Fungsi harus dikelompokkan menurut visibilitas dan urutannya:

- constructor
- receive function (jika ada)
- fallback function (jika ada)
- external
- public
- internal
- private

Dalam pengelompokan, tempatkan fungsi ``view`` dan ``pure`` terakhir.

Ya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract A {
        constructor() {
            // ...
        }

        receive() external payable {
            // ...
        }

        fallback() external {
            // ...
        }

        // External functions
        // ...

        // External functions that are view
        // ...

        // External functions that are pure
        // ...

        // Public functions
        // ...

        // Internal functions
        // ...

        // Private functions
        // ...
    }

Tidak:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract A {

        // External functions
        // ...

        fallback() external {
            // ...
        }
        receive() external payable {
            // ...
        }

        // Private functions
        // ...

        // Public functions
        // ...

        constructor() {
            // ...
        }

        // Internal functions
        // ...
    }

Whitespace di Expressi
======================

Hindari spasi kosong dalam situasi berikut:

Langsung di dalam kurung, kurung atau kurung kurawal, dengan pengecualian deklarasi fungsi baris tunggal.

Ya:

.. code-block:: solidity

    spam(ham[1], Coin({name: "ham"}));

Tidak:

.. code-block:: solidity

    spam( ham[ 1 ], Coin( { name: "ham" } ) );

Eksepsi:

.. code-block:: solidity

    function singleLine() public { spam(); }

Tepat sebelum koma, titik koma:

Ya:

.. code-block:: solidity

    function spam(uint i, Coin coin) public;

Tidak:

.. code-block:: solidity

    function spam(uint i , Coin coin) public ;

Lebih dari satu ruang di sekitar assignment atau operator lain untuk disejajarkan dengan yang lain:

Ya:

.. code-block:: solidity

    x = 1;
    y = 2;
    longVariable = 3;

Tidak:

.. code-block:: solidity

    x            = 1;
    y            = 2;
    longVariable = 3;

<<<<<<< HEAD
Jangan sertakan whitespace dalam fungsi receive dan fallback:
=======
Do not include a whitespace in the receive and fallback functions:
>>>>>>> english/develop

Ya:

.. code-block:: solidity

    receive() external payable {
        ...
    }

    fallback() external {
        ...
    }

Tidak:

.. code-block:: solidity

    receive () external payable {
        ...
    }

    fallback () external {
        ...
    }


Struktur Kontrol
==================

Tanda kurung yang menunjukkan isi kontrak, library, fungsi, dan struct
Sebaiknya:

* buka di baris yang sama dengan deklarasi
* tutup pada baris mereka sendiri pada tingkat lekukan yang sama dengan awal
   pernyataan.
* Tanda kurung kurawal harus didahului dengan satu spasi.

Ya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Coin {
        struct Bank {
            address owner;
            uint balance;
        }
    }

Tidak:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Coin
    {
        struct Bank {
            address owner;
            uint balance;
        }
    }

Rekomendasi yang sama berlaku untuk struktur kontrol ``if``, ``else``, `` while``,
dan ``for``.

Selain itu, harus ada spasi tunggal antara struktur kontrol
``if``, `` while``, dan ``untuk`` dan blok kurung yang mewakili kondisi,
serta satu spasi antara blok kurung kondisional dan blok kurung
bersyarat. penjepit pembuka.

Ya:

.. code-block:: solidity

    if (...) {
        ...
    }

    for (...) {
        ...
    }

Tidak:

.. code-block:: solidity

    if (...)
    {
        ...
    }

    while(...){
    }

    for (...) {
        ...;}

Untuk struktur kontrol yang tubuhnya berisi satu pernyataan, menghilangkan
kurung kurawal tidak masalah *jika* pernyataan dimuat dalam satu baris.

Ya:

.. code-block:: solidity

    if (x < 10)
        x += 1;

Tidak:

.. code-block:: solidity

    if (x < 10)
        someArray.push(Coin({
            name: 'spam',
            value: 42
        }));

Untuk blok ``if`` yang memiliki klausa ``else`` atau ``else if``, ``else`` harus
ditempatkan pada baris yang sama dengan kurung kurawal penutup ``if``. Ini adalah pengecualian dibandingkan
dengan aturan struktur seperti blok lainnya.

Ya:

.. code-block:: solidity

    if (x < 3) {
        x += 1;
    } else if (x > 7) {
        x -= 1;
    } else {
        x = 5;
    }


    if (x < 3)
        x += 1;
    else
        x -= 1;

Tidak:

.. code-block:: solidity

    if (x < 3) {
        x += 1;
    }
    else {
        x -= 1;
    }

Function Declaration
====================

Untuk deklarasi fungsi pendek, direkomendasikan untuk kurung kurawal pembuka dari
badan fungsi untuk disimpan pada baris yang sama dengan deklarasi fungsi.

Tanda kurung kurawal harus berada pada tingkat lekukan yang sama dengan
deklarasi fungsi.

Tanda kurung buka harus didahului dengan satu spasi.

Ya:

.. code-block:: solidity

    function increment(uint x) public pure returns (uint) {
        return x + 1;
    }

    function increment(uint x) public pure onlyOwner returns (uint) {
        return x + 1;
    }

Tidak:

.. code-block:: solidity

    function increment(uint x) public pure returns (uint)
    {
        return x + 1;
    }

    function increment(uint x) public pure returns (uint){
        return x + 1;
    }

    function increment(uint x) public pure returns (uint) {
        return x + 1;
        }

    function increment(uint x) public pure returns (uint) {
        return x + 1;}

Urutan modifier untuk suatu fungsi harus:

1. Visibility
2. Mutability
3. Virtual
4. Override
5. Custom modifiers

Ya:

.. code-block:: solidity

    function balance(uint from) public view override returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() public onlyOwner {
        selfdestruct(owner);
    }

Tidak:

.. code-block:: solidity

    function balance(uint from) public override view returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() onlyOwner public {
        selfdestruct(owner);
    }

<<<<<<< HEAD
Untuk deklarasi fungsi yang panjang, disarankan untuk menjatuhkan setiap argumen
ke barisnya sendiri pada tingkat lekukan yang sama dengan badan fungsi. Tanda kurung
tutup dan kurung buka harus ditempatkan pada barisnya masing-masing serta pada tingkat
lekukan yang sama dengan deklarasi fungsi.
=======
For long function declarations, it is recommended to drop each argument onto
its own line at the same indentation level as the function body.  The closing
parenthesis and opening bracket should be placed on their own line as well at
the same indentation level as the function declaration.
>>>>>>> english/develop

Ya:

.. code-block:: solidity

    function thisFunctionHasLotsOfArguments(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f
    )
        public
    {
        doSomething();
    }

Tidak:

.. code-block:: solidity

    function thisFunctionHasLotsOfArguments(address a, address b, address c,
        address d, address e, address f) public {
        doSomething();
    }

    function thisFunctionHasLotsOfArguments(address a,
                                            address b,
                                            address c,
                                            address d,
                                            address e,
                                            address f) public {
        doSomething();
    }

    function thisFunctionHasLotsOfArguments(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f) public {
        doSomething();
    }

Jika deklarasi fungsi yang panjang memiliki modifier, maka setiap pengubah harus
jatuh ke jalurnya sendiri.

Ya:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public
        onlyOwner
        priced
        returns (address)
    {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(
        address x,
        address y,
        address z
    )
        public
        onlyOwner
        priced
        returns (address)
    {
        doSomething();
    }

Tidak:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(address x, address y, address z)
                                          public
                                          onlyOwner
                                          priced
                                          returns (address) {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public onlyOwner priced returns (address)
    {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public
        onlyOwner
        priced
        returns (address) {
        doSomething();
    }

Parameter output multiline dan pernyataan return harus mengikuti gaya yang sama yang direkomendasikan untuk membungkus garis panjang yang ditemukan di bagian :ref:`Maximum Line Length <maximum_line_length>`.

Ya:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(
        address a,
        address b,
        address c
    )
        public
        returns (
            address someAddressName,
            uint256 LongArgument,
            uint256 Argument
        )
    {
        doSomething()

        return (
            veryLongReturnArg1,
            veryLongReturnArg2,
            veryLongReturnArg3
        );
    }

Tidak:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(
        address a,
        address b,
        address c
    )
        public
        returns (address someAddressName,
                 uint256 LongArgument,
                 uint256 Argument)
    {
        doSomething()

        return (veryLongReturnArg1,
                veryLongReturnArg1,
                veryLongReturnArg1);
    }

Untuk fungsi konstruktor pada kontrak yang diwarisi yang basisnya memerlukan argumen,
direkomendasikan untuk meletakkan konstruktor dasar ke baris baru dengan cara yang
sama seperti modifier jika deklarasi fungsi panjang atau sulit dibaca.

Ya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // Base contracts just to make this compile
    contract B {
        constructor(uint) {
        }
    }


    contract C {
        constructor(uint, uint) {
        }
    }


    contract D {
        constructor(uint) {
        }
    }


    contract A is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
            B(param1)
            C(param2, param3)
            D(param4)
        {
            // do something with param5
            x = param5;
        }
    }

Tidak:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // Base contracts just to make this compile
    contract B {
        constructor(uint) {
        }
    }


    contract C {
        constructor(uint, uint) {
        }
    }


    contract D {
        constructor(uint) {
        }
    }


    contract A is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
        B(param1)
        C(param2, param3)
        D(param4) {
            x = param5;
        }
    }


    contract X is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
            B(param1)
            C(param2, param3)
            D(param4) {
                x = param5;
            }
    }


Saat mendeklarasikan fungsi pendek dengan satu pernyataan, diizinkan untuk melakukannya pada satu baris.

Permissible:

.. code-block:: solidity

    function shortFunction() public { doSomething(); }

<<<<<<< HEAD
Panduan untuk deklarasi fungsi ini dimaksudkan untuk meningkatkan keterbacaan.
Penulis harus menggunakan penilaian terbaik mereka karena panduan ini tidak mencoba untuk mencakup semua
kemungkinan permutasi untuk deklarasi fungsi.
=======
These guidelines for function declarations are intended to improve readability.
Authors should use their best judgment as this guide does not try to cover all
possible permutations for function declarations.
>>>>>>> english/develop

Mapping
=======

Dalam deklarasi variabel, jangan pisahkan kata kunci ``mapping`` dari jenisnya
dengan spasi. Jangan pisahkan kata kunci nested ``mapping`` dari jenisnya berdasarkan
spasi.

Ya:

.. code-block:: solidity

    mapping(uint => uint) map;
    mapping(address => bool) registeredAddresses;
    mapping(uint => mapping(bool => Data[])) public data;
    mapping(uint => mapping(uint => s)) data;

Tidak:

.. code-block:: solidity

    mapping (uint => uint) map;
    mapping( address => bool ) registeredAddresses;
    mapping (uint => mapping (bool => Data[])) public data;
    mapping(uint => mapping (uint => s)) data;

Deklarasi Variabel
=====================

Deklarasi variabel array tidak boleh memiliki spasi antara tipe
dan tanda kurung.

Ya:

.. code-block:: solidity

    uint[] x;

Tidak:

.. code-block:: solidity

    uint [] x;


Rekomendasi lainnya
=====================

* String harus dikutip dengan tanda kutip ganda, bukan tanda kutip tunggal.

Ya:

.. code-block:: solidity

    str = "foo";
    str = "Hamlet says, 'To be or not to be...'";

Tidak:

.. code-block:: solidity

    str = 'bar';
    str = '"Be yourself; everyone else is already taken." -Oscar Wilde';

* Mengelilingi operator dengan satu ruang di kedua sisi.

Ya:

.. code-block:: solidity
    :force:

    x = 3;
    x = 100 / 10;
    x += 3 + 4;
    x |= y && z;

Tidak:

.. code-block:: solidity
    :force:

    x=3;
    x = 100/10;
    x += 3+4;
    x |= y&&z;

<<<<<<< HEAD
* Operator dengan prioritas lebih tinggi daripada yang lain dapat mengecualikan whitespace
  di sekitarnya untuk menunjukkan prioritas. Ini dimaksudkan untuk memungkinkan peningkatan
  keterbacaan untuk pernyataan yang kompleks. Anda harus selalu menggunakan jumlah spasi
  yang sama di kedua sisi operator:
=======
* Operators with a higher priority than others can exclude surrounding
  whitespace in order to denote precedence.  This is meant to allow for
  improved readability for complex statements. You should always use the same
  amount of whitespace on either side of an operator:
>>>>>>> english/develop

Ya:

.. code-block:: solidity

    x = 2**3 + 5;
    x = 2*y + 3*z;
    x = (a+b) * (a-b);

Tidak:

.. code-block:: solidity

    x = 2** 3 + 5;
    x = y+z;
    x +=1;

******************
Urutan Tata Letak
******************

<<<<<<< HEAD
Tata letak elemen kontrak dalam urutan berikut:
=======
Contract elements should be laid out in the following order:
>>>>>>> english/develop

1. Pragma statements
2. Import statements
3. Events
4. Errors
5. Interfaces
6. Libraries
7. Contracts

Di dalam setiap kontrak, library, atau interface, gunakan urutan berikut:

1. Type declarations
2. State variables
3. Events
4. Errors
5. Modifiers
6. Functions

.. note::

    Mungkin lebih jelas untuk mendeklarasikan tipe yang dekat dengan penggunaannya dalam
    event atau variabel state.

Yes:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.4 <0.9.0;

    abstract contract Math {
        error DivideByZero();
        function divide(int256 numerator, int256 denominator) public virtual returns (uint256);
    }

No:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.4 <0.9.0;

    abstract contract Math {
        function divide(int256 numerator, int256 denominator) public virtual returns (uint256);
        error DivideByZero();
    }


******************
Konvensi Penamaan
******************

Konvensi penamaan sangat kuat ketika diadopsi dan digunakan secara luas. penggunaan dari
konvensi yang berbeda dapat menyampaikan informasi *meta* signifikan yang jika tidak,
tidak akan segera tersedia.

Rekomendasi penamaan yang diberikan di sini dimaksudkan untuk meningkatkan keterbacaan,
dan dengan demikian itu bukan aturan, melainkan pedoman untuk mencoba dan membantu menyampaikan
sebagian besar informasi melalui nama-nama.

Terakhir, konsistensi dalam basis kode harus selalu menggantikan konvensi apa pun yang
diuraikan dalam dokumen ini.


Gaya Penamaan
=============

Untuk menghindari kebingungan, nama-nama berikut akan digunakan untuk merujuk ke gaya
penamaan yang berbeda.

<<<<<<< HEAD
* ``b`` (huruf kecil tunggal)
* ``B`` (huruf besar tunggal)
* ``lowercasel``
* ``lower_case_with_underscores``
* ``UPPERCASE``
* ``UPPER_CASE_WITH_UNDERSCORES``
* ``CapitalizedWords`` (atau CapWords)
* ``mixedCase`` (berbeda dari CapitalizedWords dengan karakter huruf kecil awal!)
* ``Capitalized_Words_With_Underscores``
=======
* ``b`` (single lowercase letter)
* ``B`` (single uppercase letter)
* ``lowercase``
* ``UPPERCASE``
* ``UPPER_CASE_WITH_UNDERSCORES``
* ``CapitalizedWords`` (or CapWords)
* ``mixedCase`` (differs from CapitalizedWords by initial lowercase character!)
>>>>>>> english/develop

.. note:: Saat menggunakan inisial di CapWords, gunakan huruf kapital untuk semua huruf inisial. Jadi HTTPServerError lebih baik daripada HttpServerError. Saat menggunakan inisialisme dalam mixedCase, gunakan huruf besar untuk semua huruf inisial, kecuali pertahankan huruf kecil pertama jika itu adalah awal dari nama. Jadi xmlHTTPRequest lebih baik daripada XMLHTTPRequest.


Nama yang Harus Dihindari
=========================

* ``l`` - Huruf kecil el
* ``O`` - Huruf besar oh
* ``I`` - Huruf besar i

Jangan pernah menggunakan salah satu dari ini untuk nama variabel satu huruf. Mereka sering
dibedakan dari angka satu dan nol.


Kontrak dan Nama Library
========================

* Kontrak dan library harus diberi nama menggunakan gaya CapWords. Contoh: ``SimpleToken``, ``SmartBank``, ``CertificateHashRepository``, ``Player``, ``Congress``, ``Owned``.
* Nama kontrak dan library juga harus sesuai dengan nama filenya.
* Jika file kontrak menyertakan beberapa kontrak dan/atau library, maka nama file harus cocok dengan *kontrak inti*. Namun hal ini tidak dianjurkan jika dapat dihindari.

Seperti yang ditunjukkan pada contoh di bawah ini, jika nama kontraknya adalah ``Congress`` dan nama library adalah ``Owned``, maka nama file terkaitnya harus ``Congress.sol`` dan ``Owned.sol``.

Ya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // Owned.sol
    contract Owned {
        address public owner;

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        constructor() {
            owner = msg.sender;
        }

        function transferOwnership(address newOwner) public onlyOwner {
            owner = newOwner;
        }
    }

dan di ``Congress.sol``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    import "./Owned.sol";


    contract Congress is Owned, TokenRecipient {
        //...
    }

Tidak:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // owned.sol
    contract owned {
        address public owner;

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        constructor() {
            owner = msg.sender;
        }

        function transferOwnership(address newOwner) public onlyOwner {
            owner = newOwner;
        }
    }

dan di ``Congress.sol``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.7.0;


    import "./owned.sol";


    contract Congress is owned, tokenRecipient {
        //...
    }

Nama Struct
==========================

Struct harus diberi nama menggunakan gaya CapWords. Contoh: ``MyCoin``, ``Position``, ``PositionXY``.


Nama Event
===========

Event harus diberi nama menggunakan gaya CapWords. Contoh: ``Deposit``, ``Transfer``, ``Approval``, ``BeforeTransfer``, ``AfterTransfer``.


Nama Fungsi
============

Fungsi harus menggunakan mixedCase. Contoh: ``getBalance``, ``transfer``, ``verifyOwner``, ``addMember``, ``changeOwner``.


Nama Argumen Fungsi
=======================

Argumen fungsi harus menggunakan mixedCase. Contoh: ``initialSupply``, ``account``, ``recipientAddress``, ``senderAddress``, ``newOwner``.

Saat menulis fungsi library yang beroperasi pada struct kustom, struct
harus menjadi argumen pertama dan harus selalu diberi nama ``self``.


Nama Lokal dan Variabel State
=============================

Gunakan mixedCase. Contoh: ``totalSupply``, ``remainingSupply``, ``balancesOf``, ``creatorAddress``, ``isPreSale``, ``tokenExchangeRate``.


Constants
=========

Konstanta harus diberi nama dengan semua huruf kapital dengan garis bawah memisahkan
kata-kata. Contoh: ``MAX_BLOCKS``, ``TOKEN_NAME``, ``TOKEN_TICKER``, ``CONTRACT_VERSION``.


Nama Modifier
==============

Gunakan mixedCase. Contoh: ``onlyBy``, ``onlyAfter``, ``onlyDuringThePreSale``.


Enums
=====

Enums, dalam gaya deklarasi tipe sederhana, harus diberi nama menggunakan gaya CapWords. Contoh: ``TokenGroup``, ``Frame``, ``HashStyle``, ``CharacterLocation``.


Menghindari Tabrakan Penamaan
=============================

* ``singleTrailingUnderscore_``

<<<<<<< HEAD
Konvensi ini disarankan ketika nama yang diinginkan bertabrakan dengan
nama bawaan atau nama yang dicadangkan.
=======
This convention is suggested when the desired name collides with that of
an existing state variable, function, built-in or otherwise reserved name.

Underscore Prefix for Non-external Functions and Variables
==========================================================

* ``_singleLeadingUnderscore``

This convention is suggested for non-external functions and state variables (``private`` or ``internal``). State variables without a specified visibility are ``internal`` by default.

When designing a smart contract, the public-facing API (functions that can be called by any account)
is an important consideration.
Leading underscores allow you to immediately recognize the intent of such functions,
but more importantly, if you change a function from non-external to external (including ``public``)
and rename it accordingly, this forces you to review every call site while renaming.
This can be an important manual check against unintended external functions
and a common source of security vulnerabilities (avoid find-replace-all tooling for this change).
>>>>>>> english/develop

.. _style_guide_natspec:

*******
NatSpec
*******

Kontrak solidity juga dapat berisi komentar NatSpec. Mereka ditulis dengan
garis miring tiga (``///``) atau blok asterisk ganda (``/** ... */``) dan
mereka harus digunakan langsung di atas deklarasi atau pernyataan fungsi.

Misalnya, kontrak dari :ref:`a simple smart contract <simple-smart-contract>` dengan komentar
ditambahkan terlihat seperti di bawah ini:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    /// @author The Solidity Team
    /// @title A simple storage example
    contract SimpleStorage {
        uint storedData;

        /// Store `x`.
        /// @param x the new value to store
        /// @dev stores the number in the state variable `storedData`
        function set(uint x) public {
            storedData = x;
        }

        /// Return the stored value.
        /// @dev retrieves the value of the state variable `storedData`
        /// @return the stored value
        function get() public view returns (uint) {
            return storedData;
        }
    }

Direkomendasikan agar kontrak Solidity diberi penjelasan lengkap menggunakan :ref:`NatSpec <natspec>` untuk semua antarmuka publik (semua yang ada di ABI).

Silakan lihat bagian tentang :ref:`NatSpec <natspec>` untuk penjelasan rinci.
