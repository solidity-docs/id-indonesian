###############################
Pengenalan Smart Kontrak
###############################

.. _simple-smart-contract:

************************
Smart Kontrak Sederhana
************************

Mari kita mulai dengan contoh dasar yang menetapkan nilai variabel dan mengeksposnya
untuk dapat diakses oleh kontrak lain. Tidak mengapa jika Anda tidak memahami
semuanya sekarang, kita akan bahas lebih detail nanti.

Contoh Storage
===============

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract SimpleStorage {
        uint storedData;

        function set(uint x) public {
            storedData = x;
        }

        function get() public view returns (uint) {
            return storedData;
        }
    }

Baris pertama memberitahu Anda bahwa kode sumber dilisensikan dibawah
GPL versi 3.0. Penentu lisensi yang dapat dibaca mesin adalah penting,
dalam pengaturan di mana penerbitan kode sumber adalah default.

Baris berikutnya menentukan bahwa kode sumber ditulis untuk
Solidity versi 0.4.16, atau versi bahasa yang lebih baru hingga, tetapi tidak termasuk versi 0.9.0.
Ini untuk memastikan bahwa kontrak tidak dapat dikompilasi dengan versi kompiler baru (breaking), di mana ia bisa berperilaku berbeda.
:ref:`Pragmas<pragma>` adalah instruksi umum untuk kompiler tentang cara memperlakukan
kode sumber (mis. `pragma Once <https://en.wikipedia.org/wiki/Pragma_once>`_).

Kontrak dalam arti Solidity adalah kumpulan kode (*fungsinya*) dan
data (*statusnya*) yang berada di alamat tertentu di blockchain
Ethereum. Baris ``uintstoredData;`` mendeklarasikan variabel state yang disebut ``storedData``
bertipe ``uint`` (*u*\nsigned *int*\eger dari *256* bits). Anda dapat menganggapnya sebagai satu slot
dalam database yang dapat Anda query dan ubah dengan memanggil fungsi
kode yang mengelola database. Dalam contoh ini, kontrak mendefinisikan
fungsi ``set`` dan ``get`` yang dapat digunakan untuk mengubah
atau mengambil nilai variabel.

Untuk mengakses member (seperti variabel state) dari kontrak saat ini, Anda biasanya tidak perlu menambahkan awalan ``this.``,
cukup mengaksesnya langsung melalui namanya.
Tidak seperti di beberapa bahasa lain, menghilangkannya bukan hanya masalah gaya,
tetapi menghasilkan cara yang berbeda untuk mengakses member, kita bahas tentang ini nanti.

Kontrak ini belum bisa berbuat banyak selain dari (karena infrastruktur
yang dibangun oleh Ethereum) memungkinkan siapa pun untuk menyimpan satu nomor yang dapat
diakses oleh siapa saja di dunia tanpa ada cara (yang layak) untuk mencegah Anda menerbitkan
nomor ini. Siapa pun dapat memanggil lagi fungsi ``set`` dengan nilai yang berbeda
dan menimpa nomor Anda, tetapi nomor tersebut masih tersimpan dalam riwayat
blockchain. Nanti, Anda akan melihat bagaimana Anda dapat memberlakukan pembatasan akses
sehingga hanya Anda yang dapat mengubah nomor tersebut.

.. warning::
    Hati-hati dalam menggunakan teks Unicode, karena karakter yang terlihat serupa (atau bahkan identik)
    dapat memiliki titik kode yang berbeda dan karenanya dikodekan sebagai byte array yang berbeda.

.. note::
    Semua pengidentifikasi (nama kontrak, nama fungsi, dan nama variabel) dibatasi untuk
    set karakter ASCII. Dimungkinkan untuk menyimpan data encoded UTF-8 dalam variabel string.

.. index:: ! subcurrency

Contoh Subcurrency
===================

Kontrak berikut mengimplementasikan bentuk paling sederhana dari
cryptocurrency. Kontrak hanya mengizinkan penciptanya untuk membuat koin baru (skema lain mungkin bisa digunakan).
Siapa pun dapat mengirim koin satu sama lain tanpa perlu
mendaftar dengan nama pengguna dan kata sandi, yang dibutuhkan hanyalah *keypair* Ethereum.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract Coin {
        // The keyword "public" makes variables
        // accessible from other contracts
        address public minter;
        mapping (address => uint) public balances;

        // Events allow clients to react to specific
        // contract changes you declare
        event Sent(address from, address to, uint amount);

        // Constructor code is only run when the contract
        // is created
        constructor() {
            minter = msg.sender;
        }

        // Sends an amount of newly created coins to an address
        // Can only be called by the contract creator
        function mint(address receiver, uint amount) public {
            require(msg.sender == minter);
            balances[receiver] += amount;
        }

        // Errors allow you to provide information about
        // why an operation failed. They are returned
        // to the caller of the function.
        error InsufficientBalance(uint requested, uint available);

        // Sends an amount of existing coins
        // from any caller to an address
        function send(address receiver, uint amount) public {
            if (amount > balances[msg.sender])
                revert InsufficientBalance({
                    requested: amount,
                    available: balances[msg.sender]
                });

            balances[msg.sender] -= amount;
            balances[receiver] += amount;
            emit Sent(msg.sender, receiver, amount);
        }
    }

Kontrak ini memperkenalkan beberapa konsep baru, mari kita bahas satu per satu.

Baris ``address public minter;`` mendeklarasikan variabel state dengan tipe :ref:`alamat<address>`.
Tipe ``alamat`` adalah 160-bit yang tidak mengizinkan operasi aritmatika apa pun.
Sangat cocok untuk menyimpan alamat kontrak, atau hash dari setengah pasangan
keypair publik milik :ref:`akun external<accounts>`.

Kata kunci ``public`` secara otomatis menghasilkan fungsi yang memungkinkan Anda mengakses nilai variabel state
saat ini dari luar kontrak. Tanpa kata kunci ini, kontrak lain tidak memiliki cara untuk mengakses variabel.
Kode fungsi yang dihasilkan oleh *compiler* setara dengan
kode berikut (untuk saat ini, abaikan ``external`` dan ``view``):

.. code-block:: solidity

    function minter() external view returns (address) { return minter; }

Anda dapat menambahkan sendiri fungsi seperti di atas, Anda akan memiliki fungsi dan variabel state dengan nama yang sama.
Anda tidak perlu melakukan ini, *compiler* akan mencarikannya untuk Anda.

.. index:: mapping

Baris berikutnya, ``mapping (address => uint) public balances;`` juga
membuat variabel state publik, tetapi ini adalah datatype yang lebih kompleks.
Jenis :ref:`mapping <mapping-types>` memetakan alamat ke :ref:`unsigned integer <integer>`.

Mapping dapat dilihat sebagai `tabel hash <https://en.wikipedia.org/wiki/Hash_table>`_ yang secara
virtual diinisialisasi sedemikian rupa sehingga setiap kunci yang mungkin ada sejak awal dan dipetakan
ke nilai yang representasi byte-nya adalah semua nol. Namun, tidak mungkin untuk mendapatkan semua daftar kunci mapping,
atau daftar semua values. Catat apa yang Anda tambahkan ke mapping,
atau gunakan dalam konteks di mana ini tidak diperlukan.
bahkan lebih baik, simpan daftar atau gunakan tipe data yang lebih cocok.

:ref:`getter function<getter-functions>` yang dibuat oleh kata kunci ``public``
lebih kompleks dalam hal mapping. Ini terlihat seperti berikut:

.. code-block:: solidity

    function balances(address _account) external view returns (uint) {
        return balances[_account];
    }

Anda dapat menggunakan fungsi ini untuk menampilkan saldo satu akun.

.. index:: event

Baris ``event Sent(address from, address to, uint amount);`` mendeklarasikan
sebuah :ref:`"event" <events>`, yang dikeluarkan di baris terakhir fungsi
``send``. Klien Ethereum seperti aplikasi web dapat mendengarkan
event yang dikeluarkan didalam blockchain tanpa membutuhkan banyak
biaya. Sesegera setelah dikeluarkan, pendengar menerima
argumen ``from``, ``to`` dan ``amount``, yang memungkinkan untuk
melacak transaksi.

Untuk mendengarkan event ini, anda harus menggunakan kode
JavaScript berikut, yang menggunakan `web3.js <https://github.com/ethereum/web3.js/>`_ untuk membuat objek kontrak  ``Coin``,
dan setiap antarmuka pengguna memanggil fungsi ``balances`` yang dibuat secara otomatis dari atas::

    Coin.Sent().watch({}, '', function(error, result) {
        if (!error) {
            console.log("Coin transfer: " + result.args.amount +
                " coins were sent from " + result.args.from +
                " to " + result.args.to + ".");
            console.log("Balances now:\n" +
                "Sender: " + Coin.balances.call(result.args.from) +
                "Receiver: " + Coin.balances.call(result.args.to));
        }
    })

.. index:: coin

:ref:`Constructor<constructor>` adalah fungsi khusus yang dijalankan selama pembuatan kontrak dan
tidak dapat dipanggil setelahnya. Dalam hal ini, secara permanen menyimpan alamat orang yang membuat kontrak.
``msg`` variable (bersama dengan ``tx`` dan ``block``) adalah
:ref:`variabel global khusus <special-variables-functions>`
berisi properti yang memungkinkan akses ke blockchain. ``msg.sender`` selalu
merupakan alamat dari mana panggilan fungsi (eksternal) saat ini berasal.

Fungsi yang membentuk kontrak, dan yang dapat dipanggil oleh pengguna dan kontrak adalah ``mint`` dan ``send``.

Fungsi ``mint`` mengirimkan sejumlah koin yang baru dibuat ke alamat lain. Panggilan fungsi
:ref:`require <assert-and-require>` mendefinisikan kondisi yang mengembalikan semua perubahan jika tidak terpenuhi. dalam
contoh ini, ``require(msg.sender == minter);`` memastikan bahwa hanya pembuat kontrak yang dapat memanggil funsi
``mint``. Secara umum, si pencipta dapat mencetak token sebanyak yang mereka suka, tapi di beberapa poin, ini akan
menyebabkan fenomena yang disebut "overflow". Perhatikan bahwa karena :ref:`Checked arithmetic
<unchecked>` adalah default, transaksi akan dikembalikan jika ekspresi ``balances[receiver] += amount;``
overflows, yaitu, ketika ``balances[receiver] + amount`` dalam aritmatika presisi arbitrer lebih besar dari
nilai maksimum ``uint`` (``2**256 - 1``). Hal ini juga berlaku untuk statement
``balances[receiver] += amount;`` dalam fungsi ``send``.

:ref:`Errors <errors>` memungkinkan Anda memberikan informasi lebih lanjut kepada pemanggil tentang
mengapa suatu kondisi atau operasi gagal. Kesalahan digunakan bersama dengan
:ref:`mengembalikan pernyataan <revert-statement>`. Pernyataan revert tanpa syarat membatalkan
dan mengembalikan semua perubahan yang serupa dengan fungsi ``require``, tetapi juga memungkinkan
Anda untuk memberikan nama kesalahan dan data tambahan yang akan diberikan ke pemanggil
(dan pada akhirnya ke aplikasi front-end atau block explorer) sehingga
kegagalan dapat lebih mudah di-debug atau direaksikan.

Fungsi ``send`` dapat digunakan oleh siapa saja (yang telah
memiliki beberapa koin ini) untuk mengirim koin kepada orang lain. Jika pengirim tidak memiliki
cukup koin untuk dikirim, kondisi ``if`` bernilai true. Akibatnya, ``revert`` akan menyebabkan operasi gagal
sambil memberikan detail kesalahan kepada pengirim menggunakan ``InsufficientBalance`` eror.

.. note::
    Jika Anda menggunakan
    kontrak ini untuk mengirimkan koin ke sebuah alamat, anda tidak akan melihat apapun ketika anda
    melihat alamat tersebut di blockchain explorer, karena catatan bahwa Anda mengirim koin
    dan saldo yang diubah hanya disimpan dalam penyimpanan data kontrak koin khusus ini.
    Dengan menggunakan events, anda dapat membuat sebuah "blockchain explorer" yang melacak transaksi dan saldo koin baru anda,
    tetapi Anda harus memeriksa alamat kontrak koin dan bukan alamat pemilik koin.

.. _blockchain-basics:

**********************
Dasar-dasar Blockchain
**********************

Blockchain sebagai sebuah konsep tidak terlalu sulit untuk dipahami oleh programmer. Alasannya adalah
sebagian besar komplikasi (mining, `hashing <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_,
`elliptic-curve cryptography <https://en.wikipedia.org/wiki/Elliptic_curve_cryptography>`_,
`peer-to-peer networks <https://en.wikipedia.org/wiki/Peer-to-peer>`_, etc.)
hanya ada untuk menyediakan serangkaian fitur dan janji tertentu untuk platform. Setelah Anda menerima
fitur-fitur seperti yang diberikan, Anda tidak perlu khawatir tentang teknologi yang mendasarinya - atau
apakah Anda harus tahu bagaimana Amazon AWS bekerja secara internal untuk menggunakannya? ora kan?

.. index:: transaction

Transaksi
============

Blockchain adalah basis data transaksional yang dibagikan secara global.
Ini berarti bahwa setiap orang dapat membaca entri dalam database hanya dengan berpartisipasi dalam jaringan.
Jika Anda ingin mengubah sesuatu dalam database, Anda harus membuat apa yang disebut dengan transaksi, yang
harus diterima oleh semua orang.
Kata transaksi menyiratkan bahwa perubahan yang ingin Anda buat (anggap anda ingin mengubah
dua nilai pada saat yang sama) sebenarnya tidak dilakukan sama sekali atau diterapkan secara menyeluruh. Selain itu,
ketika transaksi Anda diterapkan ke database, tidak ada transaksi lain yang dapat mengubahnya.

Sebagai contoh, bayangkan sebuah tabel yang mencantumkan saldo semua akun dalam
mata uang elektronik. Jika transfer dari satu akun ke akun lain diminta,
sifat transaksional database memastikan bahwa jika jumlahnya
dikurangi dari satu akun tersebut, selalu ditambahkan ke akun lain. Jika karena suatu hal
menambahkan jumlah ke akun target tidak memungkinkan, akun sumber juga tidak akan diubah.

Selanjutnya, transaksi selalu ditandatangani secara kriptografis oleh pengirim (creator).
Sehingga membuatnya mudah untuk menjaga akses ke modifikasi tertentu dari database.
Dalam contoh mata uang elektronik, pemeriksaan sederhana memastikan bahwa
hanya orang yang memegang kunci akun yang dapat mentransfer uang darinya.

.. index:: ! block

Blocks
======

Salah satu kendala utama yang harus diatasi adalah apa (dalam istilah Bitcoin) yang disebut dengan "double-spend attack":
Apa yang terjadi jika ada dua transaksi di satu jaringan yang keduanya sama sama ingin mengosongkan sebuah akun?
Hanya satu transaksi yang valid, biasanya yang pertama diterima.
Masalahnya adalah bahwa "pertama" bukanlah istilah objektif dalam jaringan peer-to-peer.

Jawaban abstrak untuk hal ini adalah Anda tidak perlu peduli. Urutan transaksi yang diterima secara global
akan dipilih, untuk menyelesaikan konflik ini. Transaksi akan digabungkan ke dalam apa yang disebut dengan "block"
dan kemudian akan dieksekusi dan didistribusikan ke semua node yang berpartisipasi.
Jika dua transaksi bertentangan satu sama lain, salah satu yang berakhir menjadi yang kedua akan
ditolak dan tidak menjadi bagian dari block.

Block-block ini membentuk urutan linier dalam waktu dan dari situlah kata "blockchain" berasal.
Block ditambahkan ke rantai/(chain) dalam interval yang agak teratur - untuk Ethereum, kira-kira setiap 17 detik.

Sebagai bagian dari "order selection mechanism" (yang disebut "menambang/*mining*") mungkin saja terjadi
pengembalian blocks dari waktu to waktu, tetapi hanya terjadi di "ujung" rantai/(chain). Semakin banyak
blok ditambahkan di atas blok tertentu, semakin kecil kemungkinan block ini akan dikembalikan. Jadi mungkin saja transaksi Anda dikembalikan
dan bahkan dihapus dari blockchain, tetapi semakin lama Anda menunggu, semakin kecil kemungkinannya.

.. note::
    Transaksi tidak dijamin untuk dimasukkan dalam block berikutnya atau block selanjutnya yang spesifik,
    karena tidak tergantung pada pengirim transaksi, tetapi tergantung pada penambang untuk menentukan di block mana transaksi tersebut disertakan.

    Jika Anda ingin menjadwalkan panggilan di masa mendatang dari kontrak Anda, Anda dapat menggunakan
    `jam alarm <https://www.ethereum-alarm-clock.com/>`_ atau layanan oracle serupa.

.. _the-ethereum-virtual-machine:

.. index:: !evm, ! ethereum virtual machine

****************************
Mesin Virtual Ethereum
****************************

Gambaran
========

Mesin Virtual Ethereum atau EVM adalah lingkungan runtime
untuk smart kontrak di Ethereum. Tidak hanya ter-*sandboxed* tetapi
benar benar sangat terisolasi, ini berarti kode yang berjalan
didalam EVM tidak memiliki akses ke jaringan, filesystem atau proses lain.
Smart kontrak bahkan memiliki akses terbatas ke smart kontrak lainnya.

.. index:: ! account, address, storage, balance

.. _accounts:

Akun
========

Ada dua jenis akun di Ethereum yang berbagi ruang alamat yang sama:
**Akun Eksternal** yang dikontrol oleh public-private key pairs
(yaitu manusia) dan **Akun Kontrak** yang dikontrol oleh sebuah kode
yang disimpan bersama dengan akun tersebut.

Alamat akun eksternal ditentukan dari public key
sementara alamat sebuah kontrak ditentukan pada saat
kontrak tersebut dibuat (berasal dari alamat si pembuat dan jumlah transaksi yang
dikirim dari alamat tersebut, yang disebut "nonce").

Terlepas dari apakah akun menyimpan kode atau tidak, kedua jenis akun tersebut
diperlakukan sama oleh EVM.

Setiap akun memiliki penyimpanan key-value persisten yang memetakan kata 256-bit
ke kata 256-bit yang disebut **storage**.

Selanjutnya, setiap akun memiliki **saldo** dalam Ether (tepatnya di "Wei", ``1 ether`` adalah ``10**18 wei``)
yang dapat dimodifikasi dengan mengirimkan transaksi yang menyertakan Ether.

.. index:: ! transaction

Transaksi
============

Transaksi adalah pesan yang dikirim dari satu akun ke akun lain
(yang mungkin sama atau kosong, lihat di bawah).
Ini dapat mencakup data biner (yang disebut "payload") dan Ether.

Jika akun target berisi kode, kode itu akan dieksekusi dan
payload disediakan sebagai data input.

Jika akun target tidak di set (transaksi tidak memiliki penerima atau penerima di set ke ``null``),
transaksi akan membuat **kontrak baru**.
Seperti yang telah disebutkan, alamat kontrak tersebut bukanlah
alamat kosong tetapi alamat yang berasal dari pengirim dan
nomor transaksi yang dikirim ("nonce"). payload
transaksi pembuatan kontrak semacam itu dianggap sebagai
bytecode EVM dan dieksekusi. Output data dari eksekusi ini
disimpan secara permanen sebagai kode kontrak.
Ini berarti bahwa untuk membuat kontrak, anda tidak perlu
mengirim kode aktual dari kontrak tersebut, tetapi sebenarnya
kode yang mengembalikan kode itu saat dieksekusi.

.. note::
  Saat kontrak sedang dibuat, kodenya masih kosong.
  Karena itu, Anda tidak boleh memanggil kembali
  kontrak yang sedang dibuat sampai konstruktornya
  selesai mengeksekusi.

.. index:: ! gas, ! gas price

Gas
===

Pada saat pembuatan, setiap transaksi dikenakan sejumlah **gas**,
yang tujuannya adalah untuk membatasi jumlah pekerjaan yang diperlukan untuk
melaksanakan transaksi dan untuk membayar biaya eksekusi pada waktu yang sama. Saat EVM melakukan
transaksi, gas secara bertahap habis sesuai dengan aturan tertentu.

**harga gas** adalah nilai yang ditetapkan oleh pembuat transaksi,
yang harus membayar ``gas_price * gas`` di muka dari rekening pengirim.
Jika beberapa gas tersisa setelah eksekusi, akan dikembalikan ke pengirim dengan cara yang sama.

Jika gas habis pada titik tertentu (yaitu akan menjadi negatif),
akan memicu *out-of-gas exception*, yang akan mengembalikan semua perubahan
yang dibuat pada state dalam rentang waktu saat ini.

.. index:: ! storage, ! memory, ! stack

Storage, Memory dan Stack
=============================

Mesin Virtual Ethereum memiliki tiga area di mana ia dapat menyimpan data-
storage, memory dan stack, yang akan dijelaskan dalam paragraf berikut.

Setiap akun memiliki area data yang disebut **storage**, yang persisten antara fungsi memanggil
dan transaksi.
Storage adalah sebuah *key-value store* yang memetakan kata 256-bit ke kata 256-bit.
Tidak mungkin untuk menghitung storage dari dalam kontrak, itu relatif
mahal untuk dibaca, dan bahkan lebih mahal untuk menginisialisasi dan memodifikasi storage. Karena mahalnya biaya,
Anda harus meminimalkan apa yang Anda simpan di presistant storage dengan apa yang perlu dihalankan oleh kontrak.
Simpan data seperti perhitungan turunan, caching, dan agregat di luar kontrak.
Kontrak tidak dapat membaca atau menulis ke storage manapun selain miliknya sendiri.

Area data kedua disebut **memory**, di mana kontrak memperoleh instance
yang baru dan fresh untuk setiap pesna panggilan. Memory bersifat linier dan bisa
dialamatkan pada tingkat byte, untuk membaca dibatasi dengan kelebaran 256 bit, sedangkan untuk menulis
dapat berupa 8 bit atau lebar 256 bit. Memori diperluas dengan kata (256-bit), ketika
mengakses (baik membaca ataupun menulis) kata memori yang sebelumnya tidak tersentuh (yaitu offset apa pun
dalam satu kata tsb). Pada saat ekspansi, biaya dalam gas harus dibayar. Semakin mahal Memori
semakin besar pertumbuhannya (berskala kuadrat).

EVM bukanlah mesin register tetapi mesin tumpukan, jadi semua
perhitungan dilakukan pada area data yang disebut **stack**. memiliki ukuran maksimum
1024 element dan berisi kata-kata 256 bit. Akses ke stack
terbatas pada *top end* dengan cara sebagai berikut:
Dimungkinkan untuk menyalin
salah satu dari 16 elemen teratas ke stack teratas atau menukar elemen
teratas dengan salah satu dari 16 elemen di bawahnya.
Semua operasi lain mengambil dua (atau satu, atau lebih, tergantung pada
operasi) elemen teratas dan mendorong hasilnya ke stack.
Tentu saja dimungkinkan untuk memindahkan elemen stack ke storage atau memory
untuk mendapatkan akses yang lebih dalam,
tetapi tidak mungkin hanya mengakses elemen arbitrer lebih dalam di stack
tanpa terlebih dahulu menghapus bagian atas stack.

.. index:: ! instruction

Set Instruksi
===============

Set instruksi EVM dijaga agar tetap seminimal mungkin untuk menghindari
implementasi yang salah atau tidak konsisten yang dapat menyebabkan masalah konsensus.
Semua instruksi beroperasi pada tipe data dasar, 256-bit kata atau pada slice memory
(atau array byte lainnya).
Operasi aritmatika, bit, logika, dan perbandingan yang biasa ada.
Lompatan bersyarat dan tidak bersyarat dimungkinkan. Selanjutnya,
kontrak dapat mengakses properti yang relevan dari block saat ini
seperti nomor dan stempel waktunya.

Untuk daftar lengkapnya, silakan lihat :ref:`daftar opcodes <opcodes>` sebagai bagian dari dokumentasi
inline *assembly*.

.. index:: ! message call, function;call

Pesan Panggilan (message call)
==============================

Kontrak dapat memanggil kontrak lain atau mengirim Ether ke akun
non-kontrak melalui pesan panggilan. Pesan panggilan mirip dengan
transaksi, karena mereka memiliki sumber, target, payload data, Ether,
gas, dan data pengembalian. Faktanya, setiap transaksi terdiri dari pesan
panggilan tingkat atas yang pada gilirannya dapat membuat pesan panggilan lebih lanjut.

Sebuah kontrak dapat memutuskan berapa banyak sisa **gas** yang harus dikirim
dengan pesan panggilan *inner* dan seberapa banyak yang ingin dipertahankan.
Jika pengecualian *out-of-gas* terjadi di panggilan *inner* (atau
pengecualian lainnya), ini akan ditandai dengan nilai kesalahan yang dimasukkan ke dalam stack.
Dalam hal ini, hanya gas yang dikirim bersamaan dengan panggilan yang digunakan.
Di Solidity, dalam situasi seperti itu panggilan kontrak menyebabkan pengecualian
manual secara default, sehingga pengecualian tersebut *mem-"bubble up"* panggilan stack.

Seperti yang sudah dikatakan, kontrak yang dipanggil (yang bisa sama dengan pemanggil)
akan menerima instance memori yang baru dibersihkan dan memiliki akses ke
payload panggilan - yang akan disediakan di area terpisah yang disebut **calldata**.
Setelah selesai dieksekusi, ia dapat mengembalikan data yang akan disimpan
didalam memori pemanggil yang telah dialokasikan sebelumnya oleh pemanggil.
Semua panggilan tersebut sepenuhnya sinkron.

Panggilan **terbatas** hingga kedalaman 1024, yang berarti untuk operasi yang lebih
kompleks, loop harus lebih didahulukan daripada panggilan rekursif. Selain itu,
hanya 63/64 gas yang dapat diteruskan dalam pesan panggilan, yang menyebabkan
batas kedalaman sedikit kurang dari 1000 dalam prakteknya.

.. index:: delegatecall, callcode, library

Delegatecall / Callcode dan Libraries
=====================================

Terdapat varian khusus dari pesan panggilan, bernama **delegatecall**
yang identik dengan pesan panggilan terlepas dari kenyataan bahwa
kode di alamat target dieksekusi dalam konteks panggilan
kontrak dan ``msg.sender`` dan ``msg.value`` tidak mengubah nilainya.

Ini berarti bahwa kontrak dapat memuat kode secara dinamis dari alamat yang
berbeda saat *runtime*. Storage, alamat saat ini, dan saldo masih mengacu pada panggilan kontrak,
hanya kode yang diambil dari alamat yang dipanggil.

Ini memungkinkan untuk mengimplementasikan fitur "perpustakaan" di Solidity:
Kode perpustakaan yang dapat digunakan kembali yang dapat diterapkan ke penyimpanan kontrak,
mis. untuk mengimplementasikan struktur data yang kompleks.

.. index:: log

Logs
====

Dimungkinkan untuk menyimpan data dalam struktur data yang diindeks secara khusus
yang memetakan sampai ke tingkat block. Fitur ini disebut **logs**
digunakan oleh Solidity untuk mengimplementasikan :ref:`events <events>`.
Kontrak tidak dapat mengakses data log setelah dibuat,
tetapi dapat diakses secara efisien dari luar blockchain.
Karena beberapa bagian dari data log disimpan di `bloom filters <https://en.wikipedia.org/wiki/Bloom_filter>`_, dimungkinkan
untuk mencari data ini dengan cara yang efisien dan aman secara kriptografis,
sehingga rekan jaringan yang tidak mengunduh seluruh blockchain (disebut "klien ringan") masih dapat menemukan log ini.

.. index:: contract creation

Membuat (Create)
================

Kontrak bahkan dapat membuat kontrak lain menggunakan opcode khusus (yaitu
mereka tidak hanya memanggil alamat nol sebagai transaksi). Satu-satunya perbedaan
antara **create calls** dan pesan panggilan normal ini adalah bahwa data payload
ijalankan dan hasilnya disimpan sebagai kode dan pemanggil/pembuat
menerima alamat kontrak baru di stack.


.. index:: selfdestruct, self-destruct, deactivate

Nonaktifkan dan penghancuran diri (Deactivate and Self-destruct)
================================================================

Satu-satunya cara untuk menghapus kode dari blockchain adalah ketika kontrak
di alamat tersebut melakukan operasi ``selfdestruct``. Ether yang tersisa disimpan
di alamat itu dikirim ke target yang ditentukan dan kemudian storage dan kode
akan dihapus dari state. Menghapus kontrak secara teori terdengar seperti ide
yang bagus, tetapi berpotensi berbahaya, seolah-olah seseorang mengirim Ether untuk menghapus
kontrak, Ether tersebut akan hilang selamanya.

.. warning::
    Even if a contract is removed by ``selfdestruct``, it is still part of the
    history of the blockchain and probably retained by most Ethereum nodes.
    So using ``selfdestruct`` is not the same as deleting data from a hard disk.

.. note::
    Even if a contract's code does not contain a call to ``selfdestruct``,
    it can still perform that operation using ``delegatecall`` or ``callcode``.

If you want to deactivate your contracts, you should instead **disable** them
by changing some internal state which causes all functions to revert. This
makes it impossible to use the contract, as it returns Ether immediately.


.. index:: ! precompiled contracts, ! precompiles, ! contract;precompiled

.. _precompiledContracts:

Kontrak prakompilasi (Precompiled contracts)
============================================

Ada satu set kecil alamat kontrak yang khusus:
Rentang alamat antara ``1`` dan (termasuk) ``8`` berisi
"kontrak prakompilasi" yang dapat disebut sebagai kontrak lain
tetapi perilakunya (dan konsumsi gasnya) tidak ditentukan oleh
kode EVM yang disimpan di alamat itu (tidak mengandung kode)
melainkan diimplementasikan di lingkungan eksekusi EVM itu sendiri.

Rantai yang kompatibel dengan EVM yang berbeda mungkin menggunakan kumpulan
kontrak prakompilasi yang berbeda. Mungkin juga kontrak prakompilasi baru
akan ditambahkan ke rantai utama Ethereum di masa depan,
tetapi Anda dapat secara wajar mengharapkannya untuk selalu berada dalam
kisaran antara ``1`` dan ``0xffff`` (inklusif).