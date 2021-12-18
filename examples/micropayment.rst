************************************************
Saluran Pembayaran Mikro (Micropayment Channel)
************************************************

Di bagian ini kita akan mempelajari cara membuat contoh
implementasi saluran pembayaran. Dengan menggunakan tanda tangan
kriptografi untuk membuat transfer Ether secara berulang antara pihak yang sama,
aman, seketika, dan tanpa biaya transaksi. Misalnya, kita perlu memahami cara menyetujui
dan memverifikasi tanda tangan, dan mengatur saluran pembayaran.


Membuat dan memverifikasi tanda tangan
======================================

Bayangkan, Alice ingin mengirim sejumlah Ether kepada Bob, misalnya
disini Alice sebagai pengirim dan Bob sebagai penerimanya.

Alice hanya perlu mengirim pesan yang ditandatangani secara kriptografis off-chain
(misalnya melalui email) ke Bob dan ini mirip dengan menulis cek.

Alice dan Bob menggunakan tanda tangan untuk mengotorisasi transaksi, hal ini dimungkinkan dengan smart kontrak di Ethereum.
Alice akan membuat smart kontrak sederhana yang memumngkinkan dia mengirim Ether, tetapi alih-alih memanggil fungsi sendiri
untuk melakukan pembayaran, dia akan membiarkan Bob melakukan itu, dan sekaligus membayar biaya transaksi.

Kontrak akan bekerja sebagai berikut:

    1. Alice mendeploy kontrak ``ReceiverPays``, melampirkan cukup Ether untuk menutupi pembayaran yang akan dilakukan.
    2. Alice mengotorisasi pembayaran dengan menandatangani pesan dengan kunci pribadinya.
    3. Alice mengirimkan pesan yang ditandatangani secara kriptografis ke Bob. Pesan tidak perlu dirahasiakan
       (dijelaskan nanti), dan mekanisme pengirimannya tidak masalah.
    4. Bob mengklaim pembayarannya dengan menyerahkan pesan yang ditandatangani ke smart kontrak,ini akan memverifikasi
       keaslian pesan dan kemudian mengeluarkan dana.

Membuat tanda tangan
----------------------

Alice tidak perlu berinteraksi dengan jaringan Ethereum
untuk menandatangani transaksi, prosesnya benar-benar offline.

Dalam tutorial ini, kita akan menandatangani pesan di browser
menggunakan `web3.js <https://github.com/ethereum/web3.js>`_ dan
`MetaMask <https://metamask.io>`_, menggunakan metode yang dijelaskan dalam `EIP-762 <https://github.com/ethereum/EIPs/pull/712>`_,
karena memberikan sejumlah manfaat keamanan lainnya.

.. code-block:: javascript

    /// Hashing first makes things easier
    var hash = web3.utils.sha3("message to sign");
    web3.eth.personal.sign(hash, web3.eth.defaultAccount, function () { console.log("Signed"); });

.. note::
  ``web3.eth.personal.sign`` menambahkan panjang pesan ke data yang ditandatangani.
  karena kita melakukan hash terlebih dahulu, pesan akan selalu memiliki panjang yang tepat 32 byte,
  dan dengan demikian prefix panjang ini selalu sama.

Apa yang Harus Ditandatangani?
------------------------------

Untuk kontrak yang memenuhi pembayaran, pesan yang ditandatangani harus menyertakan:

    1. Alamat penerima.
    2. Jumlah yang akan ditransfer.
    3. Perlindungan terhadap serangan replay.

Serangan replay adalah ketika pesan yang ditandatangani digunakan kembali untuk mengklaim otorisasi
untuk tindakan kedua. Untuk menghindari serangan replay, kami menggunakan teknik yang sama seperti
dalam transaksi Ethereum, yang disebut nonce, yang merupakan jumlah transaksi yang dikirim
oleh sebuah akun. Smart Kontrak akan memeriksa apakah nonce digunakan beberapa kali.

Jenis serangan replay lainnya dapat terjadi ketika pemilik mendeploy sebuah smart kontrak ``ReceiverPays``,
melakukan beberapa pembayaran, dan kemudian menghancurkan kontrak tersebut.
Kemudian, mereka memutuskan untuk menerapkan smart kontrak ``RecipientPays`` lagi, tetapi kontrak baru tersebut
tidak mengetahui nonces yang digunakan dalam penerapan sebelumnya, sehingga penyerang dapat menggunakan pesan yang sama.

Alice dapat melindungi dari serangan ini dengan memasukkan alamat kontrak kedalam pesan,
dan hanya pesan yang berisi alamat kontrak itu sendiri yang akan diterima.
Anda dapat menemukan contohnya di dua baris pertama fungsi ``claimPayment()`` dari kontrak
penuh di akhir bagian ini.

Packing arguments
-----------------

Sekarang kita telah mengidentifikasi informasi apa yang akan disertakan dalam pesan yang ditandatangani,
kita siap untuk menyatukan pesan, hash, dan menandatanganinya. Untuk kesederhanaan,
kita gabungkan datanya. Library `Ethereumjs-abi <https://github.com/ethereumjs/ethereumjs-abi>`_
menyediakan fungsi yang disebut ``soliditySHA3`` yang meniru perilaku fungsi
Solidity ``keccak256`` yang diterapkan pada argumen yang dikodekan menggunakan ``abi.encodePacked``.
Berikut adalah fungsi JavaScript yang membuat tanda tangan yang tepat untuk contoh ``ReceiverPays``:

.. code-block:: javascript

    // recipient is the address that should be paid.
    // amount, in wei, specifies how much ether should be sent.
    // nonce can be any unique number to prevent replay attacks
    // contractAddress is used to prevent cross-contract replay attacks
    function signPayment(recipient, amount, nonce, contractAddress, callback) {
        var hash = "0x" + abi.soliditySHA3(
            ["address", "uint256", "uint256", "address"],
            [recipient, amount, nonce, contractAddress]
        ).toString("hex");

        web3.eth.personal.sign(hash, web3.eth.defaultAccount, callback);
    }

Memulihkan Penandatangan Pesan dalam Solidity
----------------------------------------------

Secara umum, tanda tangan ECDSA terdiri dari dua parameter, ``r`` dan ``s``.
Tanda tangan di Ethereum menyertakan parameter ketiga yang disebut ``v``,
yang dapat Anda gunakan untuk memverifikasi kunci pribadi akun mana yang digunakan
untuk menandatangani pesan dan mengirim transaksi. Solidity menyediakan fungsi bawaan yaitu
:ref:`ecrecover <mathematical-and-cryptographic-functions>` yang menerima pesan bersama
dengan parameter ``r``, ``s`` dan ``v`` dan mengembalikan parameter alamat yang digunakan
untuk menandatangani pesan.

Mengekstrak Parameter Tanda Tangan
-----------------------------------

Tanda tangan yang dihasilkan oleh web3.js adalah gabungan dari
``r``, ``s`` dan ``v``, jadi langkah pertama adalah memisahkan
3 parameter tersebut. Anda dapat melakukan ini di sisi klien, tetapi jika ingin
melakukannya di dalam smart kontrak berarti Anda hanya perlu mengirim
satu parameter tanda tangan, bukan tiga.
Memisahkan array byte menjadi bagian-bagian penyusunnya merupakan hal yang berantakan,
jadi kami menggunakan :doc:`inline assembly <assembly>` untuk melakukan pekerjaan di
fungsi ``splitSignature`` (fungsi ketiga dalam kontrak penuh di akhir bagian ini).

Menghitung Hash Pesan
--------------------------

Smart Kontrak perlu tahu persis parameter apa yang ditandatangani, dan karenanya
harus membuat ulang pesan dari parameter dan menggunakannya untuk verifikasi tanda tangan.
Fungsi ``prefixed`` dan ``recoverSigner`` melakukan ini dalam fungsi ``claimPayment``.

Kontrak penuh
-----------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract ReceiverPays {
        address owner = msg.sender;

        mapping(uint256 => bool) usedNonces;

        constructor() payable {}

        function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) external {
            require(!usedNonces[nonce]);
            usedNonces[nonce] = true;

            // this recreates the message that was signed on the client
            bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

            require(recoverSigner(message, signature) == owner);

            payable(msg.sender).transfer(amount);
        }

        /// destroy the contract and reclaim the leftover funds.
        function shutdown() external {
            require(msg.sender == owner);
            selfdestruct(payable(msg.sender));
        }

        /// signature methods.
        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // first 32 bytes, after the length prefix.
                r := mload(add(sig, 32))
                // second 32 bytes.
                s := mload(add(sig, 64))
                // final byte (first byte of the next 32 bytes).
                v := byte(0, mload(add(sig, 96)))
            }

            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

            return ecrecover(message, v, r, s);
        }

        /// builds a prefixed hash to mimic the behavior of eth_sign.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


Menulis Saluran Pembayaran Sederhana
====================================

Alice sekarang membangun implementasi saluran pembayaran yang sederhana namun lengkap.
Saluran pembayaran menggunakan tanda tangan kriptografi untuk melakukan transfer Ether
secara berulang dengan aman, instan, dan tanpa biaya transaksi.

Apa itu Saluran Pembayaran?
---------------------------

Saluran pembayaran memungkinkan peserta untuk melakukan transfer Ether berulang
tanpa menggunakan transaksi. Ini berarti Anda dapat menghindari penundaan dan biaya
yang terkait dengan transaksi. Kita akan mengeksplor saluran pembayaran searah sederhana
antara dua pihak (Alice dan Bob). yang melibatkan tiga langkah berikut:

    1. Alice mendanai smart kontrak dengan Ether. Ini "membuka" saluran pembayaran.
    2. Alice menandatangani pesan yang menentukan berapa banyak Ether yang terutang kepada penerima. Langkah ini diulang untuk setiap pembayaran.
    3. Bob "menutup" saluran pembayaran, menarik bagiannya dan mengirimkan sisanya kembali ke pengirim.

.. note::
  Hanya langkah 1 dan 3 yang memerlukan transaksi Ethereum, langkah 2 berarti pengirim
  mengirimkan pesan yang ditandatangani secara kriptografis ke penerima melalui metode
  off-chain (mis. melalui email). Ini berarti hanya dua transaksi yang diperlukan untuk mendukung
  sejumlah transfer.

Bob dijamin akan menerima dananya karena smart kontrak menyimpan Ether dan menghormati
pesan bertanda tangan yang valid. Smart Kontrak juga memberlakukan batas waktu, sehingga
Alice dijamin pada akhirnya Alice akan menerima kembali dananya meskipun penerima menolak untuk
menutup saluran. Terserah para peserta di saluran pembayaran untuk memutuskan berapa lama
untuk tetap terbuka. Untuk transaksi yang berumur pendek, seperti membayar warnet untuk setiap
menit akses jaringan, saluran pembayaran dapat tetap terbuka untuk jangka waktu terbatas.
Di sisi lain, untuk pembayaran berulang, seperti membayar upah per jam kepada karyawan, saluran
pembayaran dapat tetap terbuka selama beberapa bulan atau tahun.

Membuka Saluran Pembayaran
---------------------------

Untuk membuka saluran pembayaran, Alice menyebarkan smart kontrak,
melampirkan Ether untuk di*escrow*kan dan menentukan penerima yang
dituju dan juga durasi maksimum dari saluran yang ada. Ini adalah
fungsi dari ``SimplePaymentChannel`` dalam kontrak, di akhir bagian ini.

Melakukan Pembayaran
--------------------

Alice melakukan pembayaran dengan mengirimkan pesan yang ditandatangani ke Bob.
Langkah ini dilakukan sepenuhnya di luar jaringan Ethereum.
Pesan secara kriptografis ditandatangani oleh pengirim dan kemudian dikirim langsung ke penerima.

Setiap pesan mencakup informasi berikut:

    * Alamat smart kontrak, digunakan untuk mencegah serangan replay di lintas kontrak.
    * Jumlah total Ether yang terutang kepada penerima sejauh ini.

Saluran pembayaran ditutup hanya sekali, di akhir serangkaian transfer.
Karena itu, hanya satu pesan yang dikirim yang ditukarkan.
Inilah sebabnya mengapa setiap pesan menentukan jumlah total kumulatif
Ether yang terutang, bukan jumlah pembayaran mikro individu. Penerima secara alami
akan memilih untuk menebus pesan terbaru karena itu adalah pesan dengan total nilai tertinggi.
Nonce per-pesan tidak diperlukan lagi, karena smart kontrak hanya menghargai satu pesan.
Alamat smart kontrak masih digunakan untuk mencegah pesan yang ditujukan untuk satu saluran
pembayaran digunakan untuk saluran yang berbeda.

Berikut adalah kode JavaScript yang dimodifikasi untuk menandatangani pesan secara kriptografis dari bagian sebelumnya:

.. code-block:: javascript

    function constructPaymentMessage(contractAddress, amount) {
        return abi.soliditySHA3(
            ["address", "uint256"],
            [contractAddress, amount]
        );
    }

    function signMessage(message, callback) {
        web3.eth.personal.sign(
            "0x" + message.toString("hex"),
            web3.eth.defaultAccount,
            callback
        );
    }

    // contractAddress is used to prevent cross-contract replay attacks.
    // amount, in wei, specifies how much Ether should be sent.

    function signPayment(contractAddress, amount, callback) {
        var message = constructPaymentMessage(contractAddress, amount);
        signMessage(message, callback);
    }


Menutup Saluran Pembayaran
---------------------------

Ketika Bob siap menerima dananya, saatnya untuk menutup saluran pembayaran
dengan memanggil fungsi ``close`` pada smart kontrak.
Menutup saluran membayar penerima Ether yang mereka miliki dan menghancurkan kontrak,
mengirim kembali Ether yang tersisa ke Alice. Untuk menutup saluran, Bob perlu
memberikan pesan yang ditandatangani oleh Alice.

Kontrak cerdas harus memverifikasi bahwa pesan berisi tanda tangan yang valid dari pengirim.
Proses untuk melakukan verifikasi ini sama dengan proses yang digunakan penerima.
Fungsi Solidity ``isValidSignature`` dan ``recoverSigner`` bekerja seperti fungsi JavaScript
yang ada di bagian sebelumnya, dan fungsi terakhir dipinjam dari kontrak ``ReceiverPays``.

Hanya penerima saluran pembayaran yang dapat memanggil fungsi ``close``,
yang secara alami melewati pesan pembayaran terbaru karena pesan tersebut
membawa total hutang tertinggi. Jika pengirim diizinkan untuk memanggil
fungsi ini, mereka dapat memberikan pesan dengan jumlah yang lebih rendah
dan menipu penerima .

Fungsi memverifikasi pesan yang ditandatangani cocok dengan parameter yang diberikan.
Jika semuanya selesai, penerima menerima Ether bagiannya,
dan pengirim dikirim sisanya melalui ``selfdestruct``.
Anda dapat melihat fungsi ``close`` dibagian kontrak lengkap.

Kedaluwarsa Saluran
-------------------

Bob dapat menutup saluran pembayaran kapan saja, tetapi jika mereka gagal melakukannya,
Alice membutuhkan cara untuk memulihkan dana escrow miliknya. Waktu *kedaluwarsa* telah ditetapkan
pada saat pelaksanaan kontrak. Setelah waktu itu tercapai, Alice dapat ,memanggil fungsi``claimTimeout``
untuk memulihkan dananya. Anda dapat melihat fungsi ``claimTimeout`` dibagian kontrak lengkap.

Setelah fungsi ini dijalankan, Bob tidak dapat lagi menerima Ether apa pun,
jadi penting bagi Bob untuk menutup saluran sebelum waktu kedaluwarsa tercapai.

Kontrak penuh
-----------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract SimplePaymentChannel {
        address payable public sender;      // The account sending payments.
        address payable public recipient;   // The account receiving the payments.
        uint256 public expiration;  // Timeout in case the recipient never closes.

        constructor (address payable recipientAddress, uint256 duration)
            payable
        {
            sender = payable(msg.sender);
            recipient = recipientAddress;
            expiration = block.timestamp + duration;
        }

        /// the recipient can close the channel at any time by presenting a
        /// signed amount from the sender. the recipient will be sent that amount,
        /// and the remainder will go back to the sender
        function close(uint256 amount, bytes memory signature) external {
            require(msg.sender == recipient);
            require(isValidSignature(amount, signature));

            recipient.transfer(amount);
            selfdestruct(sender);
        }

        /// the sender can extend the expiration at any time
        function extend(uint256 newExpiration) external {
            require(msg.sender == sender);
            require(newExpiration > expiration);

            expiration = newExpiration;
        }

        /// if the timeout is reached without the recipient closing the channel,
        /// then the Ether is released back to the sender.
        function claimTimeout() external {
            require(block.timestamp >= expiration);
            selfdestruct(sender);
        }

        function isValidSignature(uint256 amount, bytes memory signature)
            internal
            view
            returns (bool)
        {
            bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));

            // check that the signature is from the payment sender
            return recoverSigner(message, signature) == sender;
        }

        /// All functions below this are just taken from the chapter
        /// 'creating and verifying signatures' chapter.

        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // first 32 bytes, after the length prefix
                r := mload(add(sig, 32))
                // second 32 bytes
                s := mload(add(sig, 64))
                // final byte (first byte of the next 32 bytes)
                v := byte(0, mload(add(sig, 96)))
            }

            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

            return ecrecover(message, v, r, s);
        }

        /// builds a prefixed hash to mimic the behavior of eth_sign.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


.. note::
  Fungsi ``splitSignature`` tidak menggunakan semua pemeriksaan keamanan.
  Implementasi nyata harus menggunakan library yang telah diuji secara ketat,
  seperti versi openzepplin <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol>`_ of this code.

Memverifikasi Pembayaran
------------------------

Tidak seperti di bagian sebelumnya, pesan di saluran pembayaran tidak langsung ditukarkan.
Penerima melacak pesan terbaru dan menukarnya saat tiba waktunya untuk menutup saluran pembayaran.
Ini berarti sangat penting bahwa penerima harus melakukan verifikasi sendiri untuk setiap pesan.
Jika tidak, pada akhirnya tidak ada jaminan bahwa penerima akan dapat menerima pembayaran.

Penerima harus memverifikasi setiap pesan menggunakan proses berikut:

    1. Pastikan alamat kontrak dalam pesan cocok dengan saluran pembayaran.
    2. Verifikasi bahwa total baru adalah jumlah yang diharapkan.
    3. Pastikan jumlah baru tidak melebihi jumlah Ether yang diescrow.
    4. Verifikasi bahwa tanda tangan itu valid dan berasal dari pengirim saluran pembayaran.

Kita akan menggunakan library `ethereumjs-util <https://github.com/ethereumjs/ethereumjs-util>`_
untuk menulis verifikasi ini. langkah terakhir dapat dilakukan dengan beberapa cara,
dan kami menggunakan JavaScript. Kode berikut meminjam fungsi ``constructPaymentMessage`` dari **kode JavaScript** penandatanganan di atas:

.. code-block:: javascript

    // this mimics the prefixing behavior of the eth_sign JSON-RPC method.
    function prefixed(hash) {
        return ethereumjs.ABI.soliditySHA3(
            ["string", "bytes32"],
            ["\x19Ethereum Signed Message:\n32", hash]
        );
    }

    function recoverSigner(message, signature) {
        var split = ethereumjs.Util.fromRpcSig(signature);
        var publicKey = ethereumjs.Util.ecrecover(message, split.v, split.r, split.s);
        var signer = ethereumjs.Util.pubToAddress(publicKey).toString("hex");
        return signer;
    }

    function isValidSignature(contractAddress, amount, signature, expectedSigner) {
        var message = prefixed(constructPaymentMessage(contractAddress, amount));
        var signer = recoverSigner(message, signature);
        return signer.toLowerCase() ==
            ethereumjs.Util.stripHexPrefix(expectedSigner).toLowerCase();
    }
