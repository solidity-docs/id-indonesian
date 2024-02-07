.. index:: ! function;modifier

.. _modifiers:

****************
Fungsi Modifier
****************

<<<<<<< HEAD
Modifier dapat digunakan untuk mengubah perilaku fungsi dengan cara deklaratif.
Misalnya,
Anda dapat menggunakan Modifier untuk memeriksa kondisi secara otomatis sebelum menjalankan fungsi.
=======
Modifiers can be used to change the behavior of functions in a declarative way.
For example,
you can use a modifier to automatically check a condition prior to executing the function.
>>>>>>> english/develop

Modifier adalah
properti kontrak *inheritable* dan dapat ditimpa oleh kontrak turunan,
tetapi hanya jika ditandai sebagai ``virtual``.
Untuk detailnya, silakan lihat :ref:`Modifier Overriding <modifier-overriding>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;
    // This will report a warning due to deprecated selfdestruct

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;

        // This contract only defines a modifier but does not use
        // it: it will be used in derived contracts.
        // The function body is inserted where the special symbol
        // `_;` in the definition of a modifier appears.
        // This means that if the owner calls this function, the
        // function is executed and otherwise, an exception is
        // thrown.
        modifier onlyOwner {
            require(
                msg.sender == owner,
                "Only owner can call this function."
            );
            _;
        }
    }

    contract destructible is owned {
        // This contract inherits the `onlyOwner` modifier from
        // `owned` and applies it to the `destroy` function, which
        // causes that calls to `destroy` only have an effect if
        // they are made by the stored owner.
        function destroy() public onlyOwner {
            selfdestruct(owner);
        }
    }

    contract priced {
        // Modifiers can receive arguments:
        modifier costs(uint price) {
            if (msg.value >= price) {
                _;
            }
        }
    }

    contract Register is priced, destructible {
        mapping(address => bool) registeredAddresses;
        uint price;

        constructor(uint initialPrice) { price = initialPrice; }

        // It is important to also provide the
        // `payable` keyword here, otherwise the function will
        // automatically reject all Ether sent to it.
        function register() public payable costs(price) {
            registeredAddresses[msg.sender] = true;
        }

        function changePrice(uint price_) public onlyOwner {
            price = price_;
        }
    }

    contract Mutex {
        bool locked;
        modifier noReentrancy() {
            require(
                !locked,
                "Reentrant call."
            );
            locked = true;
            _;
            locked = false;
        }

        /// This function is protected by a mutex, which means that
        /// reentrant calls from within `msg.sender.call` cannot call `f` again.
        /// The `return 7` statement assigns 7 to the return value but still
        /// executes the statement `locked = false` in the modifier.
        function f() public noReentrancy returns (uint) {
            (bool success,) = msg.sender.call("");
            require(success);
            return 7;
        }
    }

Jika Anda ingin mengakses modifier ``m`` yang ditentukan dalam kontrak ``C``,
Anda dapat menggunakan ``C.m`` untuk mereferensikannya tanpa pencarian virtual.
Hanya dimungkinkan untuk menggunakan modifier yang ditentukan dalam kontrak saat
ini atau kontrak dasarnya. Modifier juga dapat didefinisikan di library tetapi
penggunaannya terbatas pada fungsi library yang sama.

Beberapa modifier diterapkan ke suatu fungsi dengan menentukannya dalam daftar yang
dipisahkan spasi dan dievaluasi dalam urutan yang disajikan

Modifier tidak dapat secara implisit mengakses atau mengubah argumen dan mengembalikan nilai fungsi yang mereka modifikasi.
Nilai-nilai mereka hanya dapat diberikan kepada mereka secara eksplisit pada saat permintaan.

<<<<<<< HEAD
Pengembalian eksplisit dari modifier atau badan fungsi hanya meninggalkan modifier
atau badan fungsi saat ini. Variabel return ditetapkan dan aliran kontrol berlanjut
setelah ``_`` di modifier sebelumnya.
=======
In function modifiers, it is necessary to specify when you want the function to which the modifier is
applied to be run. The placeholder statement (denoted by a single underscore character ``_``) is used to
denote where the body of the function being modified should be inserted. Note that the
placeholder operator is different from using underscores as leading or trailing characters in variable
names, which is a stylistic choice.

Explicit returns from a modifier or function body only leave the current
modifier or function body. Return variables are assigned and
control flow continues after the ``_`` in the preceding modifier.
>>>>>>> english/develop

.. warning::
    Dalam versi Solidity sebelumnya, pernyataan ``return`` dalam fungsi yang
    memiliki modifier berperilaku berbeda.

Pengembalian eksplisit dari modifier dengan ``return;`` tidak memengaruhi nilai yang dikembalikan oleh fungsi.
Akan tetapi, modifier dapat memilih untuk tidak menjalankan isi fungsi sama sekali dan dalam hal ini variabel
yang dikembalikan disetel ke :ref:`default values<default-value>` sama seperti jika fungsi memiliki isi kosong.

<<<<<<< HEAD
Simbol ``_`` dapat muncul di modifier beberapa kali. Setiap kemunculan diganti
dengan fungsi body.
=======
The ``_`` symbol can appear in the modifier multiple times. Each occurrence is replaced with
the function body, and the function returns the return value of the final occurrence.
>>>>>>> english/develop

Ekspresi Arbitrary diperbolehkan untuk argumen modifier dan dalam konteks ini,
semua simbol yang terlihat dari fungsi terlihat di modifier.
Simbol yang diperkenalkan di modifier tidak terlihat dalam fungsi
(karena mungkin berubah dengan menimpa).
