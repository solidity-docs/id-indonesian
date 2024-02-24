.. index:: ! visibility, external, public, private, internal

.. |visibility-caveat| replace:: Making something ``private`` or ``internal`` only prevents other contracts from reading or modifying the information, but it will still be visible to the whole world outside of the blockchain.

.. _visibility-and-getters:

**********************
Visibility dan Getters
**********************

<<<<<<< HEAD
Solidity mengetahui dua jenis panggilan fungsi: panggilan internal yang
tidak membuat panggilan EVM aktual (juga disebut "pesan panggilan") dan
panggilan eksternal yang dapat melakukannya. Karena itu, ada empat jenis
visibilitas untuk fungsi dan variabel state.

Fungsi harus ditentukan sebagai ``external``,
``public``, ``internal`` atau ``private``.
Untuk variabel state, ``external`` tidak dimungkinkan.
=======
State Variable Visibility
=========================

``public``
    Public state variables differ from internal ones only in that the compiler automatically generates
    :ref:`getter functions<getter-functions>` for them, which allows other contracts to read their values.
    When used within the same contract, the external access (e.g. ``this.x``) invokes the getter
    while internal access (e.g. ``x``) gets the variable value directly from storage.
    Setter functions are not generated so other contracts cannot directly modify their values.

``internal``
    Internal state variables can only be accessed from within the contract they are defined in
    and in derived contracts.
    They cannot be accessed externally.
    This is the default visibility level for state variables.

``private``
    Private state variables are like internal ones but they are not visible in derived contracts.

.. warning::
    |visibility-caveat|

Function Visibility
===================

Solidity knows two kinds of function calls: external ones that do create an actual EVM message call and internal ones that do not.
Furthermore, internal functions can be made inaccessible to derived contracts.
This gives rise to four types of visibility for functions.
>>>>>>> english/develop

``external``
    Fungsi eksternal adalah bagian dari antarmuka kontrak, yang berarti mereka
    dapat dipanggil dari kontrak lain dan melalui transaksi. Fungsi eksternal
    ``f`` tidak dapat dipanggil secara internal (yaitu ``f()`` tidak berfungsi,
    tetapi ``this.f()`` akan berfungsi).

``public``
<<<<<<< HEAD
    Fungsi publik adalah bagian dari antarmuka kontrak dan dapat dipanggil secara
    internal atau melalui pesan. Untuk variabel state publik, fungsi getter otomatis
    (lihat di bawah) dihasilkan.

``internal``
    Fungsi dan variabel state tersebut hanya dapat diakses secara internal
    (yaitu dari dalam kontrak saat ini atau kontrak yang berasal darinya),
    tanpa menggunakan ``this``. Ini adalah tingkat visibilitas default untuk
    variabel state.

``private``
    Fungsi pribadi dan variabel state hanya terlihat untuk
    kontrak yangdidefinisikan di dalamnya dan bukan dalam
    kontrak turunan.

.. note::
    Segala sesuatu yang ada di dalam kontrak dapat dilihat oleh
    semua pengamat di luar blockchain. Membuat sesuatu ``pribadi``
    hanya mencegah kontrak lain membaca atau mengubah informasi,
    tetapi informasi itu masih akan terlihat oleh seluruh dunia
    di luar blockchain.
=======
    Public functions are part of the contract interface
    and can be either called internally or via message calls.

``internal``
    Internal functions can only be accessed from within the current contract
    or contracts deriving from it.
    They cannot be accessed externally.
    Since they are not exposed to the outside through the contract's ABI, they can take parameters of internal types like mappings or storage references.

``private``
    Private functions are like internal ones but they are not visible in derived contracts.

.. warning::
    |visibility-caveat|
>>>>>>> english/develop

Penentu visibilitas diberikan setelah jenis untuk
variabel state dan antara daftar parameter dan daftar
parameter kembali untuk fungsi.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        function f(uint a) private pure returns (uint b) { return a + 1; }
        function setData(uint a) internal { data = a; }
        uint public data;
    }

Dalam contoh berikut, ``D``, dapat memanggil ``c.getData()`` untuk mengambil nilai ``data`` dalam state storage,
tetapi tidak dapat memanggil ``f``. Kontrak ``E`` diturunkan dari ``C`` dan, dengan demikian, dapat memanggil ``compute``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        uint private data;

        function f(uint a) private pure returns(uint b) { return a + 1; }
        function setData(uint a) public { data = a; }
        function getData() public view returns(uint) { return data; }
        function compute(uint a, uint b) internal pure returns (uint) { return a + b; }
    }

    // This will not compile
    contract D {
        function readData() public {
            C c = new C();
            uint local = c.f(7); // error: member `f` is not visible
            c.setData(3);
            local = c.getData();
            local = c.compute(3, 5); // error: member `compute` is not visible
        }
    }

    contract E is C {
        function g() public {
            C c = new C();
            uint val = compute(3, 5); // access to internal member (from derived to parent contract)
        }
    }

.. index:: ! getter;function, ! function;getter
.. _getter-functions:

Fungsi Getter
================

Kompiler secara otomatis membuat fungsi getter untuk semua variabel state **public**.
Untuk kontrak yang diberikan di bawah ini, kompiler akan menghasilkan fungsi yang
disebut ``data`` yang tidak mengambil argumen apa pun dan menghasilkan ``uint``, nilai
variabel state ``data``. Variabel state dapat diinisialisasi saat dideklarasikan.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        uint public data = 42;
    }

    contract Caller {
        C c = new C();
        function f() public view returns (uint) {
            return c.data();
        }
    }

Fungsi getter memiliki visibilitas eksternal.
Jika simbol diakses secara internal (mis. tanpa ``this.``),
itu mengevaluasi ke variabel state.
Jika diakses secara eksternal (mis. dengan ``this.``), ia mengevaluasi ke suatu fungsi.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract C {
        uint public data;
        function x() public returns (uint) {
            data = 3; // internal access
            return this.data(); // external access
        }
    }

Jika Anda memiliki variabel state ``public`` dari tipe array, maka Anda hanya dapat mengambil
elemen tunggal dari array melalui fungsi getter yang dihasilkan. Mekanisme ini ada
untuk menghindari biaya gas yang tinggi saat mengembalikan seluruh array. Anda dapat menggunakan
argumen untuk menentukan elemen individual mana yang akan dikembalikan, misalnya ``myArray(0)``.
Jika Anda ingin mengembalikan seluruh array dalam satu panggilan, maka Anda perlu menulis
sebuah fungsi, misalnya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract arrayExample {
        // public state variable
        uint[] public myArray;

        // Getter function generated by the compiler
        /*
        function myArray(uint i) public view returns (uint) {
            return myArray[i];
        }
        */

        // function that returns entire array
        function getArray() public view returns (uint[] memory) {
            return myArray;
        }
    }

Sekarang Anda dapat menggunakan ``getArray()`` untuk mengambil seluruh array, alih-alih ``myArray(i)``,
yang mengembalikan satu elemen per panggilan.

Contoh berikutnya lebih kompleks:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Complex {
        struct Data {
            uint a;
            bytes3 b;
            mapping(uint => uint) map;
            uint[3] c;
            uint[] d;
            bytes e;
        }
        mapping(uint => mapping(bool => Data[])) public data;
    }

Ini menghasilkan fungsi dari bentuk berikut. Mapping dan array (dengan
pengecualian array byte) dalam struct dihilangkan karena tidak ada cara yang
baik untuk memilih anggota struct individu atau memberikan kunci untuk mapping:

.. code-block:: solidity

    function data(uint arg1, bool arg2, uint arg3)
        public
        returns (uint a, bytes3 b, bytes memory e)
    {
        a = data[arg1][arg2][arg3].a;
        b = data[arg1][arg2][arg3].b;
        e = data[arg1][arg2][arg3].e;
    }
