**********
Cheatsheet
**********

.. index:: operator;precedence

Urutan Prioritas Operator
=========================

<<<<<<< HEAD
Berikut ini adalah urutan prioritas untuk operator, tercantum dalam urutan evaluasi.
=======
.. include:: types/operator-precedence-table.rst
>>>>>>> english/develop

.. index:: abi;decode, abi;encode, abi;encodePacked, abi;encodeWithSelector, abi;encodeCall, abi;encodeWithSignature

<<<<<<< HEAD
.. index:: assert, block, coinbase, difficulty, number, block;number, timestamp, block;timestamp, msg, data, gas, sender, value, gas price, origin, revert, require, keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography, this, super, selfdestruct, balance, codehash, send

Variabel Global
===============

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: :ref:`ABI <ABI>`-menerjemahkan
  data yang disediakan. Jenis diberikan dalam tanda kurung sebagai argumen kedua.
  Contoh: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: :ref:`ABI <ABI>`-mengkodekan argumen yang diberikan
- ``abi.encodePacked(...) returns (bytes memory)``: Melakukan :ref:`packed encoding <abi_packed_mode>` dari
  argumen yang diberikan. Perhatikan bahwa pengkodean ini bisa ambigu!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: :ref:`ABI <ABI>`-mengkodekan
  argumen yang diberikan mulai dari yang kedua dan menambahkan four-byte selector yang diberikan
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Setara dengan
  ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature)), ...)```
- ``bytes.concat(...) returns (bytes memory)``: :ref:`Menggabungkan jumlah
  variabel argumen ke satu byte array<bytes-concat>`
- ``block.basefee`` (``uint``): block's base fee saat ini (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ dan `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): chain id saat ini
- ``block.coinbase`` (``address payable``): block miner's address saat ini
- ``block.difficulty`` (``uint``): block difficulty saat ini
- ``block.gaslimit`` (``uint``): block gaslimit saat ini
- ``block.number`` (``uint``): block number saat ini
- ``block.timestamp`` (``uint``): block timestamp saat ini
- ``gasleft() returns (uint256)``: sisa gas
- ``msg.data`` (``bytes``): calldata lengkap
- ``msg.sender`` (``address``): Pengirim pesan (call saat ini)
- ``msg.value`` (``uint``): jumlah wei yang dikirim dengan pesan
- ``tx.gasprice`` (``uint``): harga gas saat transaksi
- ``tx.origin`` (``address``): pengirim transaksi (full call chain)
- ``assert(bool condition)``: batalkan eksekusi dan kembalikan perubahan state jika kondisinya ``false`` (digunakan untuk kesalahan internal)
- ``require(bool condition)``: batalkan eksekusi dan kembalikan perubahan state jika kondisinya ``false`` (digunakan
  untuk input yang salah atau kesalahan dalam komponen eksternal)
- ``require(bool condition, string memory message)``: batalkan eksekusi dan kembalikan perubahan state
  jika kondisinya ``false`` (untuk input yang salah atau kesalahan dalam komponen eksternal). Juga memberikan pesan kesalahan.
- ``revert()``: membatalkan eksekusi dan mengembalikan perubahan state
- ``revert(string memory message)``: batalkan eksekusi dan mengembalikan perubahan state dengan menyediakan string penjelas
- ``blockhash(uint blockNumber) returns (bytes32)``: hash dari blok yang diberikan - hanya berfungsi untuk 256 blok terbaru
- ``keccak256(bytes memory) returns (bytes32)``: hitung hash Keccak-256 dari input
- ``sha256(bytes memory) returns (bytes32)``: hitung hash SHA-256 dari input
- ``ripemd160(bytes memory) returns (bytes20)``: hitung hash RIPEMD-160 dari input
- ``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``: pulihkan alamat yang terkait dengan
  kunci publik dari tanda tangan kurva eliptik, menghasilkan nol saat error
- ``addmod(uint x, uint y, uint k) returns (uint)``:menghitung ``(x + y) % k`` di mana penambahan dilakukan dengan
  presisi arbitrer dan tidak membungkus pada kisaran ``2**256``.  Menegaskan bahwa ``k != 0`` mulai dari versi 0.5.0.
- ``mulmod(uint x, uint y, uint k) returns (uint)``:menghitung ``(x * y) % k`` di mana perkalian dilakukan
   dengan presisi arbitrer dan tidak membungkus pada kisaran ``2**256``. Menegaskan bahwa ``k != 0`` mulai dari versi 0.5.0.
- ``this`` (jenis kontrak saat ini): kontrak saat ini, secara eksplisit dapat dikonversi menjadi ``address`` atau ``address payable``
- ``super``: kontrak satu tingkat lebih tinggi dalam hierarki inheritance
- ``selfdestruct(address payable recipient)``: hancurkan kontrak saat ini, kirim dananya ke alamat yang diberikan
- ``<address>.balance`` (``uint256``): saldo dari :ref:`address` dalam Wei
- ``<address>.code`` (``bytes memory``): kode pada :ref:`address` (can be empty)
- ``<address>.codehash`` (``bytes32``): codehash dari :ref:`address`
- ``<address payable>.send(uint256 amount) returns (bool)``: kirim jumlah Wei yang diberikan ke :ref:`address`,
  menghasilkan ``false`` saat gagal.
- ``<address payable>.transfer(uint256 amount)``: kirim jumlah Wei yang diberikan ke :ref:`address`, terlempar saat gagal.
- ``type(C).name`` (``string``): nama kontrak
- ``type(C).creationCode`` (``bytes memory``): pembuatan bytecode dari kontrak yang diberikan, lihat :ref:`Type Information<meta-type>`.
- ``type(C).runtimeCode`` (``bytes memory``): bytecode runtime dari kontrak yang diberikan, lihat :ref:`Type Information<meta-type>`.
- ``type(I).interfaceId`` (``bytes4``): nilai yang berisi interface identifier EIP-165 dari interface yang diberikan, lihat :ref:`Type Information<meta-type>`.
- ``type(T).min`` (``T``): nilai minimum yang dapat diwakili oleh tipe integer ``T``, lihat :ref:`Type Information<meta-type>`.
- ``type(T).max`` (``T``): nilai maksimum yang dapat direpresentasikan oleh tipe integer ``T``, lihat :ref:`Type Information<meta-type>`.

.. note::
    Ketika kontrak dievaluasi secara off-chain dan bukan dalam konteks transaksi yang termasuk
    dalam blok, Anda tidak boleh berasumsi bahwa ``block.*`` dan ``tx.*`` merujuk ke nilai dari
    blok atau transaksi tertentu. Nilai-nilai ini disediakan oleh implementasi EVM yang mengeksekusi
    kontrak dan dapat berubah-ubah.

.. note::
    Jangan mengandalkan ``block.timestamp`` atau ``blockhash`` sebagai sumber randomness, kecuali Anda
    tahu apa yang Anda lakukan.

    Baik timestamp dan block hash dapat dipengaruhi oleh penambang sampai tingkat tertentu.
    Aktor jahat di komunitas penambangan misalnya dapat menjalankan fungsi pembayaran kasino pada hash yang dipilih
    dan coba ulangi hash yang berbeda jika mereka tidak menerima uang.

    Timestamp blok saat ini harus benar-benar lebih besar dari timestamp blok terakhir,
    tetapi satu-satunya jaminan adalah bahwa itu akan berada di antara timestamp dua
    blok berturut-turut dalam canonical chain.

.. note::
    Hash blok tidak tersedia untuk semua blok karena alasan skalabilitas.
    Anda hanya dapat mengakses hash dari 256 blok terbaru, semua nilai lainnya akan menjadi nol.

.. note::
    Di versi 0.5.0, alias berikut telah dihapus: ``suicide`` sebagai alias untuk ``selfdestruct``,
    ``msg.gas`` sebagai alias untuk ``gasleft``, ``block.blockhash`` sebagai alias untuk ``blockhash`` dan
    ``sha3`` sebagai alias untuk ``keccak256``.
.. note::
    Di versi 0.7.0, alias ``now`` (untuk ``block.timestamp``) telah dihilangkan.
=======
ABI Encoding and Decoding Functions
===================================

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: :ref:`ABI <ABI>`-decodes
  the provided data. The types are given in parentheses as second argument.
  Example: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: :ref:`ABI <ABI>`-encodes the given arguments
- ``abi.encodePacked(...) returns (bytes memory)``: Performs :ref:`packed encoding <abi_packed_mode>` of
  the given arguments. Note that this encoding can be ambiguous!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: :ref:`ABI <ABI>`-encodes
  the given arguments starting from the second and prepends the given four-byte selector
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI-encodes a call to ``functionPointer`` with the arguments found in the
  tuple. Performs a full type-check, ensuring the types match the function signature. Result equals ``abi.encodeWithSelector(functionPointer.selector, (...))``
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Equivalent
  to ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)``

.. index:: bytes;concat, string;concat

Members of ``bytes`` and  ``string``
====================================

- ``bytes.concat(...) returns (bytes memory)``: :ref:`Concatenates variable number of
  arguments to one byte array<bytes-concat>`

- ``string.concat(...) returns (string memory)``: :ref:`Concatenates variable number of
  arguments to one string array<string-concat>`

.. index:: address;balance, address;codehash, address;send, address;code, address;transfer

Members of ``address``
======================

- ``<address>.balance`` (``uint256``): balance of the :ref:`address` in Wei
- ``<address>.code`` (``bytes memory``): code at the :ref:`address` (can be empty)
- ``<address>.codehash`` (``bytes32``): the codehash of the :ref:`address`
- ``<address>.call(bytes memory) returns (bool, bytes memory)``: issue low-level ``CALL`` with the given payload,
  returns success condition and return data
- ``<address>.delegatecall(bytes memory) returns (bool, bytes memory)``: issue low-level ``DELEGATECALL`` with the given payload,
  returns success condition and return data
- ``<address>.staticcall(bytes memory) returns (bool, bytes memory)``: issue low-level ``STATICCALL`` with the given payload,
  returns success condition and return data
- ``<address payable>.send(uint256 amount) returns (bool)``: send given amount of Wei to :ref:`address`,
  returns ``false`` on failure
- ``<address payable>.transfer(uint256 amount)``: send given amount of Wei to :ref:`address`, throws on failure

.. index:: blockhash, blobhash, block, block;basefee, block;blobbasefee, block;chainid, block;coinbase, block;difficulty, block;gaslimit, block;number, block;prevrandao, block;timestamp
.. index:: gasleft, msg;data, msg;sender, msg;sig, msg;value, tx;gasprice, tx;origin

Block and Transaction Properties
================================

- ``blockhash(uint blockNumber) returns (bytes32)``: hash of the given block - only works for 256 most recent blocks
- ``blobhash(uint index) returns (bytes32)``: versioned hash of the ``index``-th blob associated with the current transaction.
  A versioned hash consists of a single byte representing the version (currently ``0x01``), followed by the last 31 bytes
  of the SHA256 hash of the KZG commitment (`EIP-4844 <https://eips.ethereum.org/EIPS/eip-4844>`_).
- ``block.basefee`` (``uint``): current block's base fee (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ and `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.blobbasefee`` (``uint``): current block's blob base fee (`EIP-7516 <https://eips.ethereum.org/EIPS/eip-7516>`_ and `EIP-4844 <https://eips.ethereum.org/EIPS/eip-4844>`_)
- ``block.chainid`` (``uint``): current chain id
- ``block.coinbase`` (``address payable``): current block miner's address
- ``block.difficulty`` (``uint``): current block difficulty (``EVM < Paris``). For other EVM versions it behaves as a deprecated alias for ``block.prevrandao`` that will be removed in the next breaking release
- ``block.gaslimit`` (``uint``): current block gaslimit
- ``block.number`` (``uint``): current block number
- ``block.prevrandao`` (``uint``): random number provided by the beacon chain (``EVM >= Paris``) (see `EIP-4399 <https://eips.ethereum.org/EIPS/eip-4399>`_ )
- ``block.timestamp`` (``uint``): current block timestamp in seconds since Unix epoch
- ``gasleft() returns (uint256)``: remaining gas
- ``msg.data`` (``bytes``): complete calldata
- ``msg.sender`` (``address``): sender of the message (current call)
- ``msg.sig`` (``bytes4``): first four bytes of the calldata (i.e. function identifier)
- ``msg.value`` (``uint``): number of wei sent with the message
- ``tx.gasprice`` (``uint``): gas price of the transaction
- ``tx.origin`` (``address``): sender of the transaction (full call chain)

.. index:: assert, require, revert

Validations and Assertions
==========================

- ``assert(bool condition)``: abort execution and revert state changes if condition is ``false`` (use for internal error)
- ``require(bool condition)``: abort execution and revert state changes if condition is ``false`` (use
  for malformed input or error in external component)
- ``require(bool condition, string memory message)``: abort execution and revert state changes if
  condition is ``false`` (use for malformed input or error in external component). Also provide error message.
- ``revert()``: abort execution and revert state changes
- ``revert(string memory message)``: abort execution and revert state changes providing an explanatory string

.. index:: cryptography, keccak256, sha256, ripemd160, ecrecover, addmod, mulmod

Mathematical and Cryptographic Functions
========================================

- ``keccak256(bytes memory) returns (bytes32)``: compute the Keccak-256 hash of the input
- ``sha256(bytes memory) returns (bytes32)``: compute the SHA-256 hash of the input
- ``ripemd160(bytes memory) returns (bytes20)``: compute the RIPEMD-160 hash of the input
- ``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``: recover address associated with
  the public key from elliptic curve signature, return zero on error
- ``addmod(uint x, uint y, uint k) returns (uint)``: compute ``(x + y) % k`` where the addition is performed with
  arbitrary precision and does not wrap around at ``2**256``. Assert that ``k != 0`` starting from version 0.5.0.
- ``mulmod(uint x, uint y, uint k) returns (uint)``: compute ``(x * y) % k`` where the multiplication is performed
  with arbitrary precision and does not wrap around at ``2**256``. Assert that ``k != 0`` starting from version 0.5.0.

.. index:: this, super, selfdestruct

Contract-related
================

- ``this`` (current contract's type): the current contract, explicitly convertible to ``address`` or ``address payable``
- ``super``: a contract one level higher in the inheritance hierarchy
- ``selfdestruct(address payable recipient)``: destroy the current contract, sending its funds to the given address

.. index:: type;name, type;creationCode, type;runtimeCode, type;interfaceId, type;min, type;max

Type Information
================

- ``type(C).name`` (``string``): the name of the contract
- ``type(C).creationCode`` (``bytes memory``): creation bytecode of the given contract, see :ref:`Type Information<meta-type>`.
- ``type(C).runtimeCode`` (``bytes memory``): runtime bytecode of the given contract, see :ref:`Type Information<meta-type>`.
- ``type(I).interfaceId`` (``bytes4``): value containing the EIP-165 interface identifier of the given interface, see :ref:`Type Information<meta-type>`.
- ``type(T).min`` (``T``): the minimum value representable by the integer type ``T``, see :ref:`Type Information<meta-type>`.
- ``type(T).max`` (``T``): the maximum value representable by the integer type ``T``, see :ref:`Type Information<meta-type>`.

>>>>>>> english/develop

.. index:: visibility, public, private, external, internal

Function Visibility Specifiers
==============================

.. code-block:: solidity
    :force:

    function myFunction() <visibility specifier> returns (bool) {
        return true;
    }

- ``public``: terlihat secara eksternal dan internal (membuat :ref:`getter function<getter-functions>` untuk variabel storage/state)
- ``private``: hanya terlihat di kontrak saat ini
- ``external``: hanya terlihat secara eksternal (hanya untuk fungsi) - yaitu hanya dapat dipanggil melalui pesan (via ``this.func``)
- ``internal``: hanya terlihat secara internal


.. index:: modifiers, pure, view, payable, constant, anonymous, indexed

Modifiers
=========

<<<<<<< HEAD
- ``pure`` untuk fungsi: Tidak mengizinkan modifikasi atau akses state.
- ``view`` untuk fungsi: Melarang modifikasi state.
- ``payable`` untuk fungsi: Memungkinkan mereka menerima Ether bersama dengan panggilan.
- ``constant`` untuk variabel state: Melarang penetapan (kecuali inisialisasi), tidak menempati slot penyimpanan.
- ``immutable`` untuk variabel state: Memungkinkan tepat satu penugasan pada waktu konstruksi dan konstan setelahnya. Disimpan dalam kode.
- ``anonymous`` untuk event: Tidak menyimpan tanda tangan event sebagai topik.
- ``indexed` untuk parameter event: Menyimpan parameter sebagai topik.
- ``virtual`` untuk fungsi dan modifier: Memungkinkan perilaku fungsi
  atau pengubah diubah dalam kontrak turunan.
- ``override``: Menyatakan bahwa fungsi, modifier, atau variabel state
  publik ini mengubah perilaku fungsi atau modifier dalam basis kontrak.

Kata Kunci Cadangan
===================

Kata kunci ini dicadangkan di Solidity. Mereka mungkin menjadi bagian dari sintaks di masa mendatang:

``after``, ``alias``, ``apply``, ``auto``, ``byte``, ``case``, ``copyof``, ``default``,
``define``, ``final``, ``implements``, ``in``, ``inline``, ``let``, ``macro``, ``match``,
``mutable``, ``null``, ``of``, ``partial``, ``promise``, ``reference``, ``relocatable``,
``sealed``, ``sizeof``, ``static``, ``supports``, ``switch``, ``typedef``, ``typeof``,
``var``.
=======
- ``pure`` for functions: Disallows modification or access of state.
- ``view`` for functions: Disallows modification of state.
- ``payable`` for functions: Allows them to receive Ether together with a call.
- ``constant`` for state variables: Disallows assignment (except initialisation), does not occupy storage slot.
- ``immutable`` for state variables: Allows assignment at construction time and is constant when deployed. Is stored in code.
- ``anonymous`` for events: Does not store event signature as topic.
- ``indexed`` for event parameters: Stores the parameter as topic.
- ``virtual`` for functions and modifiers: Allows the function's or modifier's
  behavior to be changed in derived contracts.
- ``override``: States that this function, modifier or public state variable changes
  the behavior of a function or modifier in a base contract.

>>>>>>> english/develop
