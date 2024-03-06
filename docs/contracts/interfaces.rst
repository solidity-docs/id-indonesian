.. index:: ! contract;interface, ! interface contract

.. _interfaces:

**********
Interfaces
**********

Interfaces mirip dengan kontrak abstrak, tetapi tidak dapat menerapkan fungsi apa pun.
Ada batasan lebih lanjut:

<<<<<<< HEAD
- Mereka tidak bisa mewarisi dari kontrak lain, tetapi mereka bisa mewarisi dari interfaces lain.
- Semua fungsi yang dideklarasikan harus bersifat eksternal.
- Mereka tidak dapat mendeklarasikan konstruktor.
- Mereka tidak dapat mendeklarasikan variabel state.
- Mereka tidak dapat mendeklarasikan modifier.
=======
- They cannot inherit from other contracts, but they can inherit from other interfaces.
- All declared functions must be external in the interface, even if they are public in the contract.
- They cannot declare a constructor.
- They cannot declare state variables.
- They cannot declare modifiers.
>>>>>>> english/develop

Beberapa pembatasan ini mungkin akan dicabut di masa mendatang.

Interface pada dasarnya terbatas pada apa yang dapat diwakili oleh ABI Kontrak, dan konversi antara
ABI dan sebuah interface harus dimungkinkan tanpa kehilangan informasi.

Interface dilambangkan dengan kata kunci mereka sendiri:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface Token {
        enum TokenType { Fungible, NonFungible }
        struct Coin { string obverse; string reverse; }
        function transfer(address recipient, uint amount) external;
    }

Kontrak dapat mewarisi interface karena mereka akan mewarisi dari kontrak lain.

Semua fungsi yang dideklarasikan dalam interface secara implisit ``virtual`` dan setiap fungsi yang
menimpanya tidak memerlukan kata kunci ``override``. Ini tidak secara otomatis berarti bahwa fungsi
utama dapat diganti lagi - ini hanya mungkin jika fungsi utama ditandai sebagai ``virtual``.

Interface dapat mewarisi dari Interface lain. Ini memiliki aturan yang sama dengan
pewarisan normal.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface ParentA {
        function test() external returns (uint256);
    }

    interface ParentB {
        function test() external returns (uint256);
    }

    interface SubInterface is ParentA, ParentB {
        // Must redefine test in order to assert that the parent
        // meanings are compatible.
        function test() external override(ParentA, ParentB) returns (uint256);
    }

Tipe yang didefinisikan di dalam interface dan struktur seperti kontrak
lainnya dapat diakses dari kontrak lain: ``Token.TokenType`` atau ``Token.Coin``.

.. warning::

    Interfaces telah mendukung jenis ``enum`` sejak :doc:`Solidity versi 0.5.0 <050-breaking-changes>`, pastikan
    menetapkan versi pragma ini sebagai minimum.
