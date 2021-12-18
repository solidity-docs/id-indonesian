**********
Cheatsheet
**********

.. index:: precedence

.. _order:

Urutan Prioritas Operator
=========================

Berikut ini adalah urutan prioritas untuk operator, tercantum dalam urutan evaluasi.

+------------+-------------------------------------+--------------------------------------------+
| Precedence | Description                         | Operator                                   |
+============+=====================================+============================================+
| *1*        | Postfix increment and decrement     | ``++``, ``--``                             |
+            +-------------------------------------+--------------------------------------------+
|            | New expression                      | ``new <typename>``                         |
+            +-------------------------------------+--------------------------------------------+
|            | Array subscripting                  | ``<array>[<index>]``                       |
+            +-------------------------------------+--------------------------------------------+
|            | Member access                       | ``<object>.<member>``                      |
+            +-------------------------------------+--------------------------------------------+
|            | Function-like call                  | ``<func>(<args...>)``                      |
+            +-------------------------------------+--------------------------------------------+
|            | Parentheses                         | ``(<statement>)``                          |
+------------+-------------------------------------+--------------------------------------------+
| *2*        | Prefix increment and decrement      | ``++``, ``--``                             |
+            +-------------------------------------+--------------------------------------------+
|            | Unary minus                         | ``-``                                      |
+            +-------------------------------------+--------------------------------------------+
|            | Unary operations                    | ``delete``                                 |
+            +-------------------------------------+--------------------------------------------+
|            | Logical NOT                         | ``!``                                      |
+            +-------------------------------------+--------------------------------------------+
|            | Bitwise NOT                         | ``~``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *3*        | Exponentiation                      | ``**``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *4*        | Multiplication, division and modulo | ``*``, ``/``, ``%``                        |
+------------+-------------------------------------+--------------------------------------------+
| *5*        | Addition and subtraction            | ``+``, ``-``                               |
+------------+-------------------------------------+--------------------------------------------+
| *6*        | Bitwise shift operators             | ``<<``, ``>>``                             |
+------------+-------------------------------------+--------------------------------------------+
| *7*        | Bitwise AND                         | ``&``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *8*        | Bitwise XOR                         | ``^``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *9*        | Bitwise OR                          | ``|``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *10*       | Inequality operators                | ``<``, ``>``, ``<=``, ``>=``               |
+------------+-------------------------------------+--------------------------------------------+
| *11*       | Equality operators                  | ``==``, ``!=``                             |
+------------+-------------------------------------+--------------------------------------------+
| *12*       | Logical AND                         | ``&&``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *13*       | Logical OR                          | ``||``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *14*       | Ternary operator                    | ``<conditional> ? <if-true> : <if-false>`` |
+            +-------------------------------------+--------------------------------------------+
|            | Assignment operators                | ``=``, ``|=``, ``^=``, ``&=``, ``<<=``,    |
|            |                                     | ``>>=``, ``+=``, ``-=``, ``*=``, ``/=``,   |
|            |                                     | ``%=``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *15*       | Comma operator                      | ``,``                                      |
+------------+-------------------------------------+--------------------------------------------+

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
