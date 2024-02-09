.. index:: ! inheritance, ! base class, ! contract;base, ! deriving

***********************
Inheritance (Pewarisan)
***********************

Solidity mendukung multiple inheritance termasuk Polimorfisme.

Polimorfisme berarti pemanggilan fungsi (internal dan eksternal)
selalu menjalankan fungsi dengan nama yang sama (dan tipe parameter)
dalam kontrak yang paling diturunkan dalam hierarki pewarisan.
Ini harus diaktifkan secara eksplisit pada setiap fungsi di
hierarki menggunakan kata kunci ``virtual`` dan ``override``.
Lihat :ref:`Function Overriding <function-overriding>` untuk detail selengkapnya.

Dimungkinkan untuk memanggil fungsi lebih jauh dalam hierarki pewarisan secara internal
dengan menetapkan kontrak secara eksplisit menggunakan ``ContractName.functionName()``
atau menggunakan ``super.functionName()`` jika Anda ingin memanggil fungsi satu tingkat
lebih tinggi dalam hierarki pewarisan yang diratakan (lihat di bawah).

Ketika sebuah kontrak mewarisi dari kontrak lain, hanya satu kontrak yang dibuat di blockchain,
dan kode dari semua kontrak dasar dikompilasi ke dalam kontrak yang dibuat. Ini berarti bahwa
semua panggilan internal ke fungsi kontrak dasar juga hanya menggunakan panggilan fungsi
internal (``super.f(..)`` akan menggunakan JUMP dan bukan panggilan pesan).

Variabel state shadowing dianggap sebagai kesalahan. Kontrak turunan hanya dapat mendeklarasikan
variabel state ``x``, jika tidak ada variabel state yang terlihat dengan nama yang sama di salah
satu basisnya.

Sistem pewarisan umum sangat mirip dengan
`Python <https://docs.python.org/3/tutorial/classes.html#inheritance>`_,
terutama tentang pewarisan berganda, tetapi ada juga
beberapa :ref:`perbedaan <multi-inheritance>`.

Details are given in the following example.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // This will report a warning due to deprecated selfdestruct

    contract Owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }


    // Use `is` to derive from another contract. Derived
    // contracts can access all non-private members including
    // internal functions and state variables. These cannot be
    // accessed externally via `this`, though.
    contract Destructible is Owned {
        // The keyword `virtual` means that the function can change
        // its behavior in derived classes ("overriding").
        function destroy() virtual public {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }


    // These abstract contracts are only provided to make the
    // interface known to the compiler. Note the function
    // without body. If a contract does not implement all
    // functions it can only be used as an interface.
    abstract contract Config {
        function lookup(uint id) public virtual returns (address adr);
    }


    abstract contract NameReg {
        function register(bytes32 name) public virtual;
        function unregister() public virtual;
    }


    // Multiple inheritance is possible. Note that `Owned` is
    // also a base class of `Destructible`, yet there is only a single
    // instance of `Owned` (as for virtual inheritance in C++).
    contract Named is Owned, Destructible {
        constructor(bytes32 name) {
            Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
            NameReg(config.lookup(1)).register(name);
        }

        // Functions can be overridden by another function with the same name and
        // the same number/types of inputs.  If the overriding function has different
        // types of output parameters, that causes an error.
        // Both local and message-based function calls take these overrides
        // into account.
        // If you want the function to override, you need to use the
        // `override` keyword. You need to specify the `virtual` keyword again
        // if you want this function to be overridden again.
        function destroy() public virtual override {
            if (msg.sender == owner) {
                Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
                NameReg(config.lookup(1)).unregister();
                // It is still possible to call a specific
                // overridden function.
                Destructible.destroy();
            }
        }
    }


    // If a constructor takes an argument, it needs to be
    // provided in the header or modifier-invocation-style at
    // the constructor of the derived contract (see below).
    contract PriceFeed is Owned, Destructible, Named("GoldFeed") {
        function updateInfo(uint newInfo) public {
            if (msg.sender == owner) info = newInfo;
        }

        // Here, we only specify `override` and not `virtual`.
        // This means that contracts deriving from `PriceFeed`
        // cannot change the behavior of `destroy` anymore.
        function destroy() public override(Destructible, Named) { Named.destroy(); }
        function get() public view returns(uint r) { return info; }

        uint info;
    }

Perhatikan bahwa di atas, kita memanggil ``Destructible.destroy()`` untuk "meneruskan" permintaan
penghancuran. Cara ini bermasalah, seperti yang terlihat pada contoh berikut:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // This will report a warning due to deprecated selfdestruct

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }

    contract Destructible is owned {
        function destroy() public virtual {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }

    contract Base1 is Destructible {
        function destroy() public virtual override { /* do cleanup 1 */ Destructible.destroy(); }
    }

    contract Base2 is Destructible {
        function destroy() public virtual override { /* do cleanup 2 */ Destructible.destroy(); }
    }

    contract Final is Base1, Base2 {
        function destroy() public override(Base1, Base2) { Base2.destroy(); }
    }

Panggilan ke ``Final.destroy()`` akan memanggil ``Base2.destroy`` karena kami menetapkannya secara
eksplisit dalam penggantian akhir, tetapi fungsi ini akan melewati
``Base1.destroy``. Cara mengatasinya adalah dengan menggunakan ``super``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // This will report a warning due to deprecated selfdestruct

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }

    contract Destructible is owned {
        function destroy() virtual public {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }

    contract Base1 is Destructible {
        function destroy() public virtual override { /* do cleanup 1 */ super.destroy(); }
    }


    contract Base2 is Destructible {
        function destroy() public virtual override { /* do cleanup 2 */ super.destroy(); }
    }

    contract Final is Base1, Base2 {
        function destroy() public override(Base1, Base2) { super.destroy(); }
    }

Jika ``Base2`` memanggil fungsi ``super``, ia tidak hanya memanggil fungsi ini pada salah
satu kontrak dasarnya. Sebaliknya, ia memanggil fungsi ini pada kontrak dasar berikutnya
dalam grafik pewarisan akhir, sehingga ia akan memanggil ``Base1.destroy()`` (perhatikan
bahwa urutan pewarisan terakhir adalah -- dimulai dengan kontrak yang paling diturunkan:
Final, Base2 , Base1, Dapat dirusak, dimiliki). Fungsi aktual yang dipanggil saat menggunakan
super tidak diketahui dalam konteks kelas di mana ia digunakan, meskipun jenisnya diketahui.
Ini mirip dengan pencarian metode virtual biasa.

.. index:: ! overriding;function

.. _function-overriding:

Fungsi Overriding
=================

Fungsi dasar dapat diganti dengan mewarisi kontrak untuk mengubah perilakunya
jika ditandai sebagai ``virtual``. Fungsi override kemudian harus menggunakan
kata kunci ``override`` di header fungsi.
Fungsi override hanya dapat mengubah visibilitas fungsi yang diganti dari ``external`` menjadi ``public``.
Mutabilitas dapat diubah menjadi yang lebih ketat mengikuti perintah:
``nonpayable`` dapat diganti dengan ``view`` dan ``pure``. ``view`` dapat diganti dengan ``pure``.
``payable`` adalah pengecualian dan tidak dapat diubah ke mutabilitas lainnya.

Contoh berikut menunjukkan perubahan mutabilitas dan visibilitas:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base
    {
        function foo() virtual external view {}
    }

    contract Middle is Base {}

    contract Inherited is Middle
    {
        function foo() override public pure {}
    }

Untuk multiple inheritance, kontrak turunan paling dasar yang mendefinisikan fungsi yang sama harus ditentukan secara eksplisit setelah kata kunci ``override``.
Dengan kata lain, Anda harus menentukan semua basis kontrak yang mendefinisikan fungsi yang sama dan belum ditimpa oleh basis kontrak lain (pada beberapa jalur melalui grafik pewarisan).
Selain itu, jika kontrak mewarisi fungsi yang sama dari beberapa basis (yang tidak terkait), kontrak harus secara eksplisit menimpanya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base1
    {
        function foo() virtual public {}
    }

    contract Base2
    {
        function foo() virtual public {}
    }

    contract Inherited is Base1, Base2
    {
        // Derives from multiple bases defining foo(), so we must explicitly
        // override it
        function foo() public override(Base1, Base2) {}
    }

Penentu override eksplisit tidak diperlukan jika fungsi didefinisikan dalam basis kontrak umum atau
jika ada fungsi unik dalam basis kontrak umum yang telah menimpa semua fungsi lainnya.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract A { function f() public pure{} }
    contract B is A {}
    contract C is A {}
    // No explicit override required
    contract D is B, C {}

Secara lebih formal, tidak diperlukan untuk menimpa fungsi (langsung atau tidak langsung) yang diwarisi
dari beberapa basis jika ada basis kontrak yang merupakan bagian dari semua jalur penimpaan untuk tanda
tangan, dan (1) basis tersebut mengimplementasikan fungsi dan tidak ada jalur dari kontrak saat ini ke
basis menyebutkan fungsi dengan tanda tangan itu atau (2) basis itu tidak mengimplementasikan fungsi dan
paling banyak ada satu penyebutan fungsi di semua jalur dari kontrak saat ini ke basis tersebut.

Dalam pengertian ini, jalur override untuk tanda tangan adalah jalur melalui grafik pewarisan yang dimulai
pada kontrak yang sedang dipertimbangkan dan berakhir pada kontrak yang menyebutkan fungsi dengan tanda tangan
tersebut yang tidak menimpa.

<<<<<<< HEAD
Jika Anda tidak menandai fungsi yang diganti sebagai ``virtual``, kontrak turunan tidak dapat lagi
mengubah perilaku fungsi tersebut.
=======
If you do not mark a function that overrides as ``virtual``, derived
contracts can no longer change the behavior of that function.
>>>>>>> english/develop

.. note::

  Fungsi dengan visibilitas ``private`` tidak bisa menjadi ``virtual``.

.. note::

  Fungsi tanpa implementasi harus ditandai ``virtual`` di luar antarmuka.
  Dalam antarmuka, semua fungsi secara otomatis dianggap ``virtual``.

.. note::

  Mulai dari Solidity 0.8.8, kata kunci ``override`` tidak diperlukan saat mengganti fungsi antarmuka,
  kecuali untuk kasus di mana fungsi didefinisikan dalam banyak basis.


Variabel state publik dapat menimpa fungsi eksternal jika parameter dan tipe return dari
fungsi cocok dengan fungsi pengambil variabel:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract A
    {
        function f() external view virtual returns(uint) { return 5; }
    }

    contract B is A
    {
        uint public override f;
    }

.. note::

  Sementara variabel state publik dapat menggantikan fungsi eksternal, mereka sendiri
  tidak dapat diganti.

.. index:: ! overriding;modifier

.. _modifier-overriding:

Modifier Overriding
===================

Fungsi modifier dapat saling menimpa. Ini bekerja dengan cara yang sama seperti
:ref:`function overriding <function-overriding>` (kecuali bahwa tidak ada overloading
untuk pengubah). Kata kunci ``virtual`` harus digunakan pada modifier yang ditimpa
dan kata kunci ``override`` harus digunakan dalam pengubah utama:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base
    {
        modifier foo() virtual {_;}
    }

    contract Inherited is Base
    {
        modifier foo() override {_;}
    }


Dalam kasus pewarisan berganda, semua basis kontrak langsung harus ditentukan
secara eksplisit:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base1
    {
        modifier foo() virtual {_;}
    }

    contract Base2
    {
        modifier foo() virtual {_;}
    }

    contract Inherited is Base1, Base2
    {
        modifier foo() override(Base1, Base2) {_;}
    }



.. index:: ! constructor

.. _constructor:

Konstruktor
============

Konstruktor adalah fungsi opsional yang dideklarasikan dengan kata kunci ``constructor`` yang
dijalankan saat pembuatan kontrak, dan tempat Anda dapat menjalankan kode inisialisasi kontrak.

Sebelum kode konstruktor dieksekusi, variabel state diinisialisasi ke nilai yang ditentukan jika
Anda menginisialisasinya secara inline, atau :ref:`nilai default<default-value>` jika tidak.

Setelah konstruktor berjalan, kode akhir kontrak dideploy ke blockchain.
Penerapan kode memerlukan biaya tambahan linier gas dengan panjang kode.
Kode ini mencakup semua fungsi yang merupakan bagian dari antarmuka publik dan semua fungsi yang dapat dijangkau dari sana melalui pemanggilan fungsi.
Itu tidak termasuk kode konstruktor atau fungsi internal yang hanya dipanggil dari konstruktor.

Jika tidak ada konstruktor, kontrak akan menganggap konstruktor default, yang setara
dengan ``constructor() {}``. Sebagai contoh:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    abstract contract A {
        uint public a;

        constructor(uint a_) {
            a = a_;
        }
    }

    contract B is A(1) {
        constructor() {}
    }

Anda dapat menggunakan parameter internal dalam konstruktor (misalnya pointer storage).
Dalam hal ini, kontrak harus ditandai sebagai :ref:`abstract <abstract-contract>`, karena
parameter ini tidak dapat diberi nilai valid dari luar tetapi hanya melalui konstruktor kontrak turunan.

<<<<<<< HEAD
.. warning ::
    Sebelum versi 0.4.22, konstruktor didefinisikan sebagai fungsi dengan nama yang sama dengan kontrak.
    Sintaks ini tidak digunakan lagi dan tidak diizinkan lagi di versi 0.5.0.

.. warning ::
    Sebelum versi 0.7.0, Anda harus menentukan visibilitas konstruktor sebagai
    ``internal`` atau ``publik``.
=======
.. warning::
    Prior to version 0.4.22, constructors were defined as functions with the same name as the contract.
    This syntax was deprecated and is not allowed anymore in version 0.5.0.

.. warning::
    Prior to version 0.7.0, you had to specify the visibility of constructors as either
    ``internal`` or ``public``.
>>>>>>> english/develop


.. index:: ! base;constructor, inheritance list, contract;abstract, abstract contract

Argumen untuk  Basis Konstruktor
================================

Konstruktor dari semua basis kontrak akan dipanggil mengikuti aturan
linearisasi yang dijelaskan di bawah ini. Jika Basis konstruktor  memiliki argumen,
kontrak turunan perlu menentukan semuanya. Ini dapat dilakukan dengan dua cara:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base {
        uint x;
        constructor(uint x_) { x = x_; }
    }

    // Either directly specify in the inheritance list...
    contract Derived1 is Base(7) {
        constructor() {}
    }

    // or through a "modifier" of the derived constructor...
    contract Derived2 is Base {
        constructor(uint y) Base(y * y) {}
    }

    // or declare abstract...
    abstract contract Derived3 is Base {
    }

    // and have the next concrete derived contract initialize it.
    contract DerivedFromDerived is Derived3 {
        constructor() Base(10 + 10) {}
    }

<<<<<<< HEAD
Salah satu caranya adalah langsung di daftar inheritance (``is Base(7)``).  Cara yang lainnya
adalah modifier dipanggil sebagai bagian dari
konstruktor turunan (``Base(_y * _y)``). Cara pertama untuk
melakukannya lebih mudah jika argumen konstruktor adalah konstan
dan mendefinisikan perilaku kontrak atau menggambarkannya. Cara kedua harus
digunakan jika argumen konstruktor dari basis bergantung pada argumen dari kontrak turunan.
Argumen harus diberikan baik dalam daftar pewarisan atau dalam gaya pengubah di konstruktor turunan.
Menentukan argumen di kedua tempat adalah kesalahan.

Jika kontrak turunan tidak menentukan argumen untuk semua basis konstruktor
kontraknya, itu akan menjadi abstrak.
=======
One way is directly in the inheritance list (``is Base(7)``).  The other is in
the way a modifier is invoked as part of
the derived constructor (``Base(y * y)``). The first way to
do it is more convenient if the constructor argument is a
constant and defines the behavior of the contract or
describes it. The second way has to be used if the
constructor arguments of the base depend on those of the
derived contract. Arguments have to be given either in the
inheritance list or in modifier-style in the derived constructor.
Specifying arguments in both places is an error.

If a derived contract does not specify the arguments to all of its base
contracts' constructors, it must be declared abstract. In that case, when
another contract derives from it, that other contract's inheritance list
or constructor must provide the necessary parameters
for all base classes that haven't had their parameters specified (otherwise,
that other contract must be declared abstract as well). For example, in the above
code snippet, see ``Derived3`` and ``DerivedFromDerived``.
>>>>>>> english/develop

.. index:: ! inheritance;multiple, ! linearization, ! C3 linearization

.. _multi-inheritance:

Multiple Inheritance dan Linearisasi
====================================

Bahasa yang memungkinkan multiple inheritance harus menghadapi
beberapa masalah. Salah satunya adalah `Diamond Problem <https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem>`_.
mirip dengan Python karena menggunakan "`linerarisasi C3 <https://en.wikipedia.org/wiki/C3_linearization>`_"
untuk memaksa urutan tertentu dalam directed acyclic graph (DAG) dari kelas dasar. Ini
menghasilkan properti monotonisitas yang diinginkan tetapi
tidak mengizinkan beberapa grafik inheritance. Khususnya, urutan dimana
basis kelas diberikan dalam direktif ``is`` adalah penting: Anda harus membuat
daftar basis kontrak langsung dalam urutan dari "most base-like" hingga "most derived".
Perhatikan bahwa urutan ini adalah kebalikan dari yang digunakan dalam Python.

Cara penyederhanaan lain untuk menjelaskan hal ini adalah bahwa ketika suatu fungsi
dipanggil yang didefinisikan beberapa kali dalam kontrak yang berbeda, basis yang diberikan
dicari dari kanan ke kiri (kiri ke kanan di Python) secara depth-first, berhenti pada kecocokan
pertama . Jika basis kontrak telah dicari, itu akan dilewati.

Dalam kode berikut, Solidity akan memberikan
kesalahan "Linearisasi grafik inheritance tidak memungkinkan".

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract X {}
    contract A is X {}
    // This will not compile
    contract C is A, X {}

Alasan untuk ini adalah bahwa ``C`` meminta ``X`` untuk menimpa ``A``
(dengan menentukan ``A, X`` dalam urutan ini), tetapi ``A`` sendiri meminta
untuk menimpa ``X``, yang merupakan kontradiksi yang tidak dapat diselesaikan.

Karena kenyataan bahwa Anda harus secara eksplisit mengganti fungsi
yang diwarisi dari banyak basis tanpa penimpaan yang unik,
Linearisasi C3 tidak terlalu penting dalam praktek.

Satu area di mana linearisasi pewarisan sangat penting dan mungkin tidak begitu jelas adalah ketika ada banyak konstruktor dalam hierarki pewarisan. Konstruktor akan selalu dieksekusi dalam urutan linier, terlepas dari urutan argumen mereka disediakan dalam konstruktor kontrak pewarisan. Sebagai contoh:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base1 {
        constructor() {}
    }

    contract Base2 {
        constructor() {}
    }

    // Constructors are executed in the following order:
    //  1 - Base1
    //  2 - Base2
    //  3 - Derived1
    contract Derived1 is Base1, Base2 {
        constructor() Base1() Base2() {}
    }

    // Constructors are executed in the following order:
    //  1 - Base2
    //  2 - Base1
    //  3 - Derived2
    contract Derived2 is Base2, Base1 {
        constructor() Base2() Base1() {}
    }

    // Constructors are still executed in the following order:
    //  1 - Base2
    //  2 - Base1
    //  3 - Derived3
    contract Derived3 is Base2, Base1 {
        constructor() Base1() Base2() {}
    }


Mewarisi Berbagai Jenis Anggota dengan Nama Yang Sama
======================================================

<<<<<<< HEAD
Ini adalah kesalahan ketika salah satu dari pasangan berikut dalam kontrak memiliki nama yang sama karena warisan:
  - sebuah fungsi dan modifier
  - sebuah fungsi dan event
  - senuah event dan modifier

Sebagai pengecualian, state variabel getter dapat menimpa fungsi eksternal.
=======
The only situations where, due to inheritance, a contract may contain multiple definitions sharing
the same name are:

- Overloading of functions.
- Overriding of virtual functions.
- Overriding of external virtual functions by state variable getters.
- Overriding of virtual modifiers.
- Overloading of events.
>>>>>>> english/develop
