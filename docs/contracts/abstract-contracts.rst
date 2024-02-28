.. index:: ! contract;abstract, ! abstract contract

.. _abstract-contract:

******************
Kontrak Abstrak
******************

<<<<<<< HEAD
Kontrak perlu ditandai sebagai abstrak ketika setidaknya salah satu fungsinya tidak diimplementasikan.
Kontrak dapat ditandai sebagai abstrak meskipun semua fungsi diimplementasikan.

Ini dapat dilakukan dengan menggunakan kata kunci ``abstract`` seperti yang ditunjukkan pada contoh berikut. Perhatikan bahwa kontrak
ini perlu didefinisikan sebagai abstrak, karena fungsi ``utterance()`` telah didefinisikan, tetapi tidak ada implementasi yang diberikan
(tidak ada badan implementasi ``{ }`` yang diberikan).
=======
Contracts must be marked as abstract when at least one of their functions is not implemented or when
they do not provide arguments for all of their base contract constructors.
Even if this is not the case, a contract may still be marked abstract, such as when you do not intend
for the contract to be created directly. Abstract contracts are similar to :ref:`interfaces` but an
interface is more limited in what it can declare.

An abstract contract is declared using the ``abstract`` keyword as shown in the following example.
Note that this contract needs to be defined as abstract, because the function ``utterance()`` is declared,
but no implementation was provided (no implementation body ``{ }`` was given).
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public virtual returns (bytes32);
    }

Kontrak abstrak semacam itu tidak dapat dipakai secara langsung. Ini juga benar, jika kontrak abstrak itu sendiri mengimplementasikan
semua fungsi yang ditentukan. Penggunaan kontrak abstrak sebagai basis kelas ditunjukkan dalam contoh berikut:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public pure virtual returns (bytes32);
    }

    contract Cat is Feline {
        function utterance() public pure override returns (bytes32) { return "miaow"; }
    }

Jika kontrak mewarisi dari kontrak abstrak dan tidak mengimplementasikan semua fungsi non-implemented
dengan menimpa, kontrak tersebut perlu ditandai sebagai abstrak juga.

Perhatikan bahwa fungsi tanpa implementasi berbeda
dari :ref:`Function Type <function_types>` meskipun sintaksnya terlihat sangat mirip.

Example of function without implementation (a function declaration):

.. code-block:: solidity

    function foo(address) external returns (address);

Contoh deklarasi variabel yang tipenya adalah tipe fungsi:

.. code-block:: solidity

    function(address) external returns (address) foo;

Kontrak abstrak memisahkan definisi kontrak dari implementasinya yang menyediakan
ekstensibilitas dan dokumentasi mandiri yang lebih baik serta pola fasilitasi seperti
`Metode template <https://en.wikipedia.org/wiki/Template_method_pattern>`_ dan menghapus duplikasi kode.
Kontrak abstrak berguna dengan cara yang sama seperti mendefinisikan metode dalam antarmuka. Ini adalah
cara bagi perancang kontrak abstrak untuk mengatakan "setiap anak saya harus menerapkan metode ini".

.. note::

  Kontrak abstrak tidak dapat mengesampingkan fungsi virtual yang diimplementasikan
  dengan yang tidak diimplementasikan.
