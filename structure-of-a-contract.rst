.. index:: contract, state variable, function, event, struct, enum, function;modifier

.. _contract_structure:

***********************
Struktur Kontrak
***********************

Kontrak di Solidity mirip dengan class dalam bahasa *object-oriented*.
Setiap kontrak dapat berisi pernyataan tentang :ref:`structure-state-variables`, :ref:`structure-functions`,
:ref:`structure-function-modifiers`, :ref:`structure-events`, :ref:`structure-errors`, :ref:`structure-struct-types` dan :ref:`structure-enum-types`.
Lebih jauh, kontrak dapat mewarisi dari kontrak lain.

Ada juga jenis kontrak khusus yang disebut :ref:`libraries<libraries>` dan :ref:`interfaces<interfaces>`.

Bagian tentang :ref:`kontrak<contracts>` berisi lebih banyak detail daripada bagian ini,
yang berfungsi untuk memberikan gambaran singkat.

.. _structure-state-variables:

Variabel State
===============

Variabel State adalah variabel yang nilainya disimpan secara permanen di dalam kontrak
storage.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract SimpleStorage {
        uint storedData; // State variable
        // ...
    }

lihat bagian :ref:`types` untuk tipe variabel state yang valid dan
:ref:`visibility-and-getters` untuk kemungkinan pilihan untuk
visibilitas.

.. _structure-functions:

Functions (Fungsi)
==================

Fungsi adalah unit kode yang dapat dieksekusi. Fungsi biasanya
didefinisikan di dalam kontrak, tetapi mereka juga dapat didefinisikan di luar
kontrak.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    contract SimpleAuction {
        function bid() public payable { // Function
            // ...
        }
    }

    // Helper function defined outside of a contract
    function helper(uint x) pure returns (uint) {
        return x * 2;
    }

:ref:`function-calls` dapat terjadi secara internal atau external
dan kami memiliki level :ref:`visibilitas<visibility-and-getters>` yang berbeda
terhadap kontrak lain. :ref:`Functions<functions>` menerima :ref:`variabel parameter and return<function-parameters-return-variables>` untuk melewati parameter
dan nilai-nilai di antara mereka.

.. _structure-function-modifiers:

Function Modifiers (Pengubah Fungsi)
====================================

Function modifiers dapat digunakan untuk mengubah semantics dari fungsi dengan cara deklaratif
(lihat :ref:`modifiers` di bagian kontrak).

Overloading, that is, memiliki nama modifier yang sama dengan paramater berbeda,
itu tidak mungkin.

Sama seperti functions, modifiers dapat :ref:`dikesampingkan <modifier-overriding>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract Purchase {
        address public seller;

        modifier onlySeller() { // Modifier
            require(
                msg.sender == seller,
                "Only seller can call this."
            );
            _;
        }

        function abort() public view onlySeller { // Modifier usage
            // ...
        }
    }

.. _structure-events:

Events
======

Events adalah antarmuka yang nyaman dengan fasilitas logging EVM.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.21 <0.9.0;

    contract SimpleAuction {
        event HighestBidIncreased(address bidder, uint amount); // Event

        function bid() public payable {
            // ...
            emit HighestBidIncreased(msg.sender, msg.value); // Triggering event
        }
    }

Lihat :ref:`events` dibagian kontrak untuk informasi bagaimana events dinyatakan
dan dapat digunakan dari dalam dapp.

.. _structure-errors:

Error (kesalahan)
==================

Error memungkinkan Anda untuk menentukan nama deskriptif dan data untuk situasi failure.
Error dapat digunakan dalam :ref:`revert statement <revert-statement>`.
Dibandingkan dengan deskripsi string, kesalahan jauh lebih murah dan memungkinkan Anda
untuk mengkodekan data tambahan. Anda dapat menggunakan NatSpec untuk menjelaskan kesalahan ke
pengguna.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Not enough funds for transfer. Requested `requested`,
    /// but only `available` available.
    error NotEnoughFunds(uint requested, uint available);

    contract Token {
        mapping(address => uint) balances;
        function transfer(address to, uint amount) public {
            uint balance = balances[msg.sender];
            if (balance < amount)
                revert NotEnoughFunds(amount, balance);
            balances[msg.sender] -= amount;
            balances[to] += amount;
            // ...
        }
    }

Lihat :ref:`errors` dibagian kontrak untuk info lebih lanjut.

.. _structure-struct-types:

Struct Types
=============

Struct adalah tipe yang ditentukan khusus yang dapat mengelompokkan beberapa variabel (lihat
:ref:`structs` dibagian types).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Ballot {
        struct Voter { // Struct
            uint weight;
            bool voted;
            address delegate;
            uint vote;
        }
    }

.. _structure-enum-types:

Enum Types
==========

Enums dapat digunakan untuk membuat tipe khusus dengan serangkaian 'nilai konstan' yang terbatas (lihat
:ref:`enums` dibagian types).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Purchase {
        enum State { Created, Locked, Inactive } // Enum
    }
