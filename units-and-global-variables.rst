*********************************************
Unit dan Variabel yang Tersedia Secara Global
*********************************************

.. index:: wei, finney, szabo, gwei, ether

Unit Ether
===========

Sebuah angka literal dapat mengambil akhiran ``wei``, ``gwei`` atau ``ether`` untuk menentukan subdenominasi Ether, di mana angka Ether tanpa postfix diasumsikan sebagai Wei.

.. code-block:: solidity
    :force:

    assert(1 wei == 1);
    assert(1 gwei == 1e9);
    assert(1 ether == 1e18);

Satu-satunya efek dari sufiks subdenominasi adalah perkalian dengan kekuatan sepuluh.

.. note::
    Denominasi ``finney`` dan ``szabo`` telah dihapus di versi 0.7.0.

.. index:: time, seconds, minutes, hours, days, weeks, years

Unit Waktu
==========

Sufiks seperti ``seconds``, ``minutes``, ``hours``, ``days`` dan ``weeks``
setelah angka literal dapat digunakan untuk menentukan satuan waktu di mana detik adalah satuan dasar dan
satuan dianggap naif dengan cara sebagai berikut:

* ``1 == 1 seconds``
* ``1 minutes == 60 seconds``
* ``1 hours == 60 minutes``
* ``1 days == 24 hours``
* ``1 weeks == 7 days``

Berhati-hatilah jika Anda melakukan perhitungan kalender menggunakan satuan ini, karena
tidak setiap tahun sama dengan 365 hari dan bahkan tidak setiap hari memiliki 24 jam
karena `detik kabisat <https://en.wikipedia.org/wiki/Leap_second>`_.
Karena fakta bahwa detik kabisat tidak dapat diprediksi, library kalender
yang tepat harus diperbarui oleh oracle eksternal.

.. note::
    Sufiks ``years` telah dihapus di versi 0.5.0 karena alasan yang di jealskan diatas.

Sufiks ini tidak dapat diterapkan pada variabel. Misalnya, jika Anda ingin
menginterpretasikan parameter fungsi dalam hari, Anda dapat dengan cara berikut:

.. code-block:: solidity

    function f(uint start, uint daysAfter) public {
        if (block.timestamp >= start + daysAfter * 1 days) {
          // ...
        }
    }

.. _special-variables-functions:

Variabel dan fungsi Spesial
===========================

Ada variabel dan fungsi khusus yang selalu ada di namespace
global dan terutama digunakan untuk memberikan informasi
tentang blockchain atau fungsi utilitas general-use.

.. index:: abi, block, coinbase, difficulty, encode, number, block;number, timestamp, block;timestamp, msg, data, gas, sender, value, gas price, origin


Properti Block dan Transaksi
----------------------------

- ``blockhash(uint blockNumber) returns (bytes32)``: hash dari block yang diberikan ketika ``blocknumber`` adalah salah satu dari 256 blok terbaru; jika tidak maka hasilnya nol
- ``block.basefee`` (``uint``): block base fee terkini (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ and `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): chain id terkini
- ``block.coinbase`` (``address payable``): alamat block miner terkini
- ``block.difficulty`` (``uint``): block difficulty terkini
- ``block.gaslimit`` (``uint``): block gaslimit terkini
- ``block.number`` (``uint``): nomor block terkini
- ``block.timestamp`` (``uint``): stempel waktu block saat ini sebagai detik sejak unix epoch
- ``gasleft() returns (uint256)``: gas yang tersisa
- ``msg.data`` (``bytes calldata``): calldata lengkap
- ``msg.sender`` (``address``): pengirim pesan (panggilan saat ini)
- ``msg.sig`` (``bytes4``): empat byte pertama dari calldata (mis. function identifier)
- ``msg.value`` (``uint``): jumlah wei yang dikirim bersama pesan
- ``tx.gasprice`` (``uint``): harga gas untuk transaksi
- ``tx.origin`` (``address``): pengirim transaksi (full call chain)

.. note::
    Nilai semua member ``msg``, termasuk ``msg.sender`` dan
    ``msg.value`` dapat berubah untuk setiap panggilan fungsi **eksternal**.
    Ini termasuk panggilan ke fungsi library.

.. note::
    Ketika kontrak dievaluasi secara off-chain dan bukan dalam konteks transaksi yang termasuk
    dalam block, Anda tidak boleh berasumsi bahwa ``block.*`` dan ``tx.*`` merujuk ke nilai dari
    atau transaksi tertentu. Nilai-nilai ini disediakan oleh implementasi EVM yang mengeksekusi kontrak
    dan dapat berubah-ubah.

.. note::
    Jangan mengandalkan ``block.timestamp`` atau ``blockhash`` sebagai sumber acak,
    kecuali Anda tahu apa yang Anda lakukan.

    Baik timestamp dan block hash dapat dipengaruhi oleh penambang sampai tingkat tertentu.
    Aktor jahat di komunitas penambangan misalnya dapat menjalankan fungsi pembayaran kasino pada hash yang dipilih
    dan coba ulangi hash yang berbeda jika mereka tidak menerima uang.

    Block timestamp saat ini harus benar-benar lebih besar dari block timestamp terakhir,
    tetapi satu-satunya jaminan adalah bahwa itu akan berada di antara timestamp
    dua block berturut-turut dalam canonical chain.

.. note::
    Block hash tidak tersedia untuk semua block untuk alasan skalabilitas.
    Anda hanya dapat mengakses hash dari 256 block terbaru, semua nilai
    lainnya akan menjadi nol.

.. note::
    Fungsi ``blockhash`` sebelumnya dikenal sebagai ``block.blockhash``, yang tidak digunakan lagi pada
    versi 0.4.22 dan dihapus di versi 0.5.0.

.. note::
    Fungsi ``gasleft`` sebelumnya dikenal sebagai ``msg.gas``, yang tidak digunakan lagi pada
    versi 0.4.21 dan dihapus di versi 0.5.0.

.. note::
    Pada versi 0.7.0, alias ``now`` (untuk ``block.timestamp``) telah dihapus.

.. index:: abi, encoding, packed

Fungsi ABI Encoding dan Decoding
--------------------------------

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: data ABI-decodes yang diberikan, sedangkan tipenya diberikan dalam tanda kurung sebagai argumen kedua. Misalnya: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: Argumen ABI-encodes yang diberikan
- ``abi.encodePacked(...) returns (bytes memory)``: Melakukan :ref:`packed encoding <abi_packed_mode>` dari argumen yang diberikan. Perhatikan bahwa packed encoding dapat menjadi ambigu!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: ABI-encodes argumen yang diberikan mulai dari yang kedua dan menambahkan pemilih empat byte yang diberikan
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Setara dengan ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)```

.. note::
    Fungsi encoding ini dapat digunakan untuk membuat data untuk panggilan fungsi eksternal tanpa
    benar-benar memanggil fungsi eksternal. Selanjutnya, ``keccak256(abi.encodePacked(a, b))`` adalah cara
    untuk menghitung hash dari data terstruktur (walaupun perlu diketahui bahwa "hash collision" dapat dibuat dengan
    menggunakan tipe parameter fungsi yang berbeda).

Lihat dokumentasi tentang :ref:`ABI <ABI>` dan
:ref:`tightly packed encoding <abi_packed_mode>` untuk detail tentang encoding.

.. index:: bytes members

Member dari bytes
-----------------

- ``bytes.concat(...) returns (bytes memory)``: :ref:`Menggabungkan jumlah variabel byte dan byte1, ..., argumen byte32 ke array satu byte<bytes-concat>`

.. index:: assert, revert, require

Penanganan Kesalahan
--------------------

Lihat bagian khusus tentang :ref:`assert dan require<assert-and-require>` untuk
lebih detail tentang penanganan kesalahan dan kapan harus menggunakan fungsi apa dan yang mana.

``assert(bool condition)``
    menyebabkan Panic error dan dengan demikian menyatakan perubahan reversi jika kondisinya tidak terpenuhi - digunakan untuk kesalahan internal.

``require(bool condition)``
    batal jika kondisi tidak terpenuhi - digunakan untuk kesalahan dalam input atau komponen eksternal.

``require(bool condition, string memory message)``
    batal jika kondisi tidak terpenuhi - digunakan untuk kesalahan dalam input atau komponen eksternal. Juga memberikan pesan error.

``revert()``
    membatalkan eksekusi dan memulihkan perubahan state

``revert(string memory reason)``
    membatalkan eksekusi dan memulihkan perubahan state, memberikan string penjelasan

.. index:: keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography,

.. _mathematical-and-cryptographic-functions:

Fungsi Matematika dan Kriptografi
---------------------------------

``addmod(uint x, uint y, uint k) returns (uint)``
    menghitung ``(x + y) % k`` di mana penambahan dilakukan dengan presisi arbitrer dan tidak membungkus dikisaran ``2**256``. Menegaskan bahwa ``k != 0`` mulai dari versi 0.5.0.

``mulmod(uint x, uint y, uint k) returns (uint)``
    menghitung ``(x * y) % k`` di mana perkalian dilakukan dengan presisi arbitrer dan tidak membungkus dikisaran ``2**256``. Menegaskan bahwa ``k != 0`` mulai dari versi 0.5.0.

``keccak256(bytes memory) returns (bytes32)``
    menghitung hash Keccak-256 dari input

.. note::

    Dulu ada alias untuk ``keccak256`` yang disebut ``sha3``, yang telah dihapus di versi 0.5.0.

``sha256(bytes memory) returns (bytes32)``
    menghitung hash SHA-256 dari input

``ripemd160(bytes memory) returns (bytes20)``
    menghitung RIPEMD-160 hash dari input

``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``
    memulihkan alamat yang terkait dengan kunci publik dari tanda tangan kurva eliptik atau menampilkan nol pada kesalahan.
    Parameter fungsi sesuai dengan nilai ECDSA dari tanda tangan:

    * ``r`` = 32 bytes pertama dari tanda tangan
    * ``s`` = 32 bytes kedua dari tanda tangan
    * ``v`` = 1 byte terakhir dari tanda tangan

    ``ecrecover`` menghasilkan sebuah ``address``, dan bukan sebuah ``address payable``. Lihat :ref:`address payable<address>` untuk
    konversi, jika Anda perlu mentransfer dana ke alamat yang dipulihkan.

    Untuk detail lebih lanjut, baca `contoh penggunaan <https://ethereum.stackexchange.com/questions/1777/workflow-on-signing-a-string-with-private-key-followed-by-signature-verificatio>`_.

.. warning::

    Jika Anda menggunakan ``ecrecover``, ketahuilah bahwa tanda tangan yang valid dapat diubah menjadi tanda tangan valid yang berbeda tanpa
    memerlukan pengetahuan tentang kunci pribadi yang sesuai. Di hard fork Homestead, masalah ini telah diperbaiki
    untuk tanda tangan _transaction_ (lihat `EIP-2 <https://eips.ethereum.org/EIPS/eip-2#specification>`_), tetapi
    fungsi ecrecover tetap tidak berubah.

    Ini biasanya tidak menjadi masalah kecuali Anda memerlukan tanda tangan untuk menjadi unik atau
    menggunakannya untuk mengidentifikasi item. OpenZeppelin memiliki `library pembantu ECDSA <https://docs.openzeppelin.com/contracts/2.x/api/cryptography#ECDSA>`_ yang dapat Anda gunakan sebagai wrapper untuk ``ecrecover`` tanpa masalah ini.

.. note::

    Saat menjalankan ``sha256``, ``ripemd160`` atau ``ecrecover`` pada *blockchain pribadi*, Anda mungkin mengalami Out-of-Gas. Ini karena fungsi-fungsi ini diimplementasikan sebagai "kontrak precompiled " dan hanya benar-benar ada setelah mereka menerima pesan pertama (walaupun kode kontrak mereka di-hardcode). Pesan ke *non-existing* kontrak lebih mahal dan dengan demikian eksekusi mungkin mengalami kesalahan Out-of-Gas. Solusi untuk masalah ini adalah terlebih dahulu mengirim Wei (1 misalnya) ke masing-masing kontrak sebelum Anda benar benar menggunakannya dalam kontrak Anda. Ini bukan masalah di jaringan utama atau uji coba.

.. index:: balance, codehash, send, transfer, call, callcode, delegatecall, staticcall

.. _address_related:

Member dari Tipe Address
------------------------

``<address>.balance`` (``uint256``)
    saldo :ref:`address` dalam Wei

``<address>.code`` (``bytes memory``)
    kode di :ref:`address` (bisa kosong)

``<address>.codehash`` (``bytes32``)
    codehash dari :ref:`address`

``<address payable>.transfer(uint256 amount)``
    kirim jumlah Wei yang diberikan ke :ref:`address`, pulih saat gagal, meneruskan 2300 tunjangan gas, tidak dapat disesuaikan

``<address payable>.send(uint256 amount) returns (bool)``
    kirim jumlah Wei yang diberikan ke :ref:`address`, menghasailkan ``false`` saat gagal, meneruskan 2300 tunjangan gas, tidak dapat disesuaikan

``<address>.call(bytes memory) returns (bool, bytes memory)``
    mengeluarkan low-level ``CALL`` dengan payload yang diberikan, menampilkan kondisi sukses dan data, meneruskan semua gas yang tersedia, dapat disesuaikan

``<address>.delegatecall(bytes memory) returns (bool, bytes memory)``
    mengeluarkan low-level ``DELEGATECALL`` dengan payload yang diberikan, menampilkan kondisi sukses dan data, meneruskan semua gas yang tersedia, dapat disesuaikan

``<address>.staticcall(bytes memory) returns (bool, bytes memory)``
    mengeluarkan low-level ``STATICCALL`` dengan payload yang diberikan, menampilkan kondisi sukses dan data, meneruskan semua gas yang tersedia, dapat disesuaikan

Untuk informasi lebih lanjut, lihat bagian :ref:`address`.

.. warning::
    Anda harus menghindari penggunaan ``.call()`` bila memungkinkan saat menjalankan fungsi kontrak lain karena ini akan me*baypass* pemeriksaan tipe,
    pengecekan keberadaan fungsi, dan argumen packing.

.. warning::
    Ada beberapa bahaya dalam menggunakan ``send``: Transfer gagal jika kedalaman call stack berada pada 1024
    (ini selalu dapat dipaksakan oleh pemanggil) dan juga gagal jika penerima kehabisan gas. Jadi untuk melakukan
    transfer Ether yang aman, selalu periksa nilai yang dihasilkan oleh ``send``, gunakan ``transfer`` atau bahkan lebih baik:
    Gunakan pola di mana penerima menarik uangnya.

.. warning::
    Karena kenyataan bahwa EVM menganggap panggilan ke kontrak non-existing selalu berhasil,
    Solidity menyediakan pemeriksaan tambahan menggunakan opcode ``extcodesize`` saat melakukan panggilan eksternal.
    Ini memastikan bahwa kontrak yang akan dipanggil benar-benar ada (berisi kode)
    atau pengecualian dimunculkan.

    Panggilan low-level yang beroperasi pada alamat, bukan instance kontrak (yaitu ``.call()``,
    ``.delegatecall()``, ``.staticcall()``, ``.send()`` dan ``.transfer()``) **jangan** menyertakan pemeriksaan ini,
    yang membuatnya lebih murah dalam hal gas tetapi juga kurang aman.

.. note::
   Sebelum versi 0.5.0, Solidity mengizinkan anggota alamat untuk diakses oleh instance kontrak, misalnya ``this.balance``.
   Ini sekarang dilarang dan konversi eksplisit ke alamat harus dilakukan: ``address(this).balance``.

.. note::
   Jika variabel state diakses melalui low-level delegatecall, tata letak penyimpanan kedua kontrak
   harus selaras agar kontrak yang dipanggil dapat mengakses variabel penyimpanan dari kontrak panggilan dengan benar berdasarkan nama.
   Ini tentu saja tidak terjadi jika pointer penyimpanan dilewatkan sebagai argumen fungsi seperti pada kasus
   untuk high-level libraries.

.. note::
    Sebelum versi 0.5.0, ``.call``, ``.delegatecall`` dan ``.staticcall`` hanya mengembalikan kondisi sukses
    dan bukan data yang dikembalikan.

.. note::
    Sebelum versi 0.5.0, ada anggota bernama ``callcode`` dengan semantik yang mirip tetapi
    sedikit berbeda dari ``delegatecall``.


.. index:: this, selfdestruct

Terkait Kontrak
---------------

``this`` (tipe kontrak saat ini)
    kontrak saat ini, secara eksplisit dapat dikonversi ke :ref:`address`

``selfdestruct(address payable recipient)``
    Hancurkan kontrak saat ini, kirimkan dananya ke :ref:`address` . yang diberikan
    dan mengakhiri eksekusi.
    Perhatikan bahwa ``selfdestruct`` memiliki beberapa kekhasan yang diwarisi dari EVM:

    - fungsi penerimaan kontrak penerima tidak dijalankan.
    - kontrak hanya benar-benar dihancurkan pada akhir transaksi dan ``revert`` mungkin "membatalkan" penghancuran tersebut.




Lebih lanjut, semua fungsi dari kontrak saat ini dapat dipanggil secara langsung termasuk fungsi saat ini.

.. note::
    Sebelum versi 0.5.0, ada fungsi yang disebut ``suicide`` dengan semantik yang sama dengan ``selfdestruct``.

.. index:: type, creationCode, runtimeCode

.. _meta-type:

Tipe Informasi
--------------

Ekspresi ``type(X)`` dapat digunakan untuk mengambil informasi tentang tipe ``X``.
Saat ini, ada dukungan terbatas untuk fitur ini (``X`` dapat berupa kontrak atau tipe integer)
tetapi mungkin akan diperluas di masa mendatang.

Properti berikut tersedia untuk tipe kontrak ``C``:

``type(C).name``
    Nama kontrak.

``type(C).creationCode``
    Memory byte array yang berisi bytecode pembuatan kontrak.
    Ini dapat digunakan dalam perakitan inline untuk membangun rutinitas pembuatan kustom,
    terutama dengan menggunakan opcode ``create2``.
    Properti ini **tidak** dapat diakses dalam kontrak itu sendiri atau kontrak
    turunan apa pun. Ini menyebabkan bytecode dimasukkan ke dalam bytecode
    dari situs panggilan dan dengan demikian referensi circular seperti itu tidak mungkin.

``type(C).runtimeCode``
    Memory byte array yang berisi bytecode runtime dari kontrak.
    Ini adalah kode yang biasanya digunakan oleh konstruktor ``C``.
    Jika ``C`` memiliki konstruktor yang menggunakan inline assembly, ini mungkin
    berbeda dari bytecode yang sebenarnya digunakan. Perhatikan juga bahwa library
    memodifikasi bytecode runtime mereka pada saat penerapan untuk menjaga dari
    regular calls.
    Pembatasan yang sama dengan ``.creationCode`` juga berlaku untuk properti ini.

Selain properti di atas, properti berikut tersedia untuk tipe antarmuka ``I``:

``type(I).interfaceId``:
    Nilai ``bytes4`` yang berisi `EIP-165 <https://eips.ethereum.org/EIPS/eip-165>`_
    pengidentifikasi antarmuka dari antarmuka yang diberikan ``I``. Pengidentifikasi ini didefinisikan sebagai ``XOR`` dari semua
    pemilih fungsi yang ditentukan dalam antarmuka itu sendiri - tidak termasuk semua fungsi yang diwariskan.

Properti berikut tersedia untuk tipe integer ``T``:

``type(T).min``
    Nilai terkecil yang dapat diwakili oleh tipe ``T``.

``type(T).max``
    Nilai terbesar yang dapat direpresentasikan menurut jenis ``T``.
