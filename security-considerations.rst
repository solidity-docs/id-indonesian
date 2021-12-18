.. _security_considerations:

#######################
Pertimbangan Keamanan
#######################

Meskipun biasanya cukup mudah untuk membangun perangkat lunak yang berfungsi seperti yang diharapkan,
jauh lebih sulit untuk memeriksa bahwa tidak ada yang dapat menggunakannya dengan cara yang **tidak** diantisipasi.

Di Solidity, ini bahkan lebih penting karena Anda dapat menggunakan smart kontrak untuk
menangani token atau, mungkin, hal-hal yang lebih berharga. Selanjutnya, setiap pelaksanaan
smart kontrak terjadi di depan umum dan, selain itu, kode sumbernya sering tersedia.

Tentu saja Anda harus selalu mempertimbangkan berapa banyak yang dipertaruhkan:
Anda dapat membandingkan smart kontrak dengan layanan web yang terbuka untuk umum
(dan dengan demikian, juga untuk aktor jahat) dan bahkan mungkin open source.
Jika Anda hanya menyimpan daftar belanjaan Anda di layanan web itu, Anda mungkin
tidak perlu terlalu berhati-hati, tetapi jika Anda mengelola rekening bank Anda
menggunakan layanan web itu, Anda harus lebih berhati-hati.

Bagian ini akan mencantumkan beberapa perangkap dan rekomendasi keamanan umum, tetapi
tentu saja tidak akan pernah lengkap. Juga, perlu diingat bahwa meskipun kode smart
kontrak Anda bebas bug, kompiler atau platform itu sendiri mungkin memiliki bug.
Daftar beberapa bug yang relevan dengan keamanan yang diketahui publik dari kompiler
dapat ditemukan di :ref:`list of known bugs<known_bugs>`, yang juga dapat dibaca mesin.
Perhatikan bahwa ada program bug bounty yang mencakup pembuat kode dari kompiler Solidity.

Seperti biasa, dengan dokumentasi open source, tolong bantu kami memperluas bagian ini
(terutama, beberapa contoh tidak ada salahnya)!

CATATAN: Selain daftar di bawah, Anda dapat menemukan lebih banyak rekomendasi keamanan dan praktik terbaik
`in Guy Lando's knowledge list <https://github.com/guylando/KnowledgeLists/blob/master/EthereumSmartContracts.md>`_ and
`the Consensys GitHub repo <https://consensys.github.io/smart-contract-best-practices/>`_.

********
Pitfalls
********

Private Information dan Randomness
==================================

Semua yang Anda gunakan dalam smart kontrak dapat dilihat oleh publik, meskipun
variabel lokal dan variabel state ditandai sebagai ``private``.

Menggunakan angka acak dalam smart kontrak cukup rumit jika Anda
tidak ingin penambang bisa curang.

Re-Entrancy
===========

Setiap interaksi dari kontrak (A) dengan kontrak lain (B) dan setiap transfer Ether
menyerahkan kendali ke kontrak itu (B). Ini memungkinkan B untuk memanggil kembali
ke A sebelum interaksi ini selesai. Sebagai contoh, kode berikut berisi bug (ini hanya
cuplikan dan bukan kontrak lengkap):

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // THIS CONTRACT CONTAINS A BUG - DO NOT USE
    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            if (payable(msg.sender).send(shares[msg.sender]))
                shares[msg.sender] = 0;
        }
    }

Masalahnya tidak terlalu serius di sini karena terbatasnya gas sebagai bagian dari ``send``,
tetapi masih memperlihatkan kelemahan: Transfer ether selalu dapat menyertakan kode eksekusi,
sehingga penerima dapat berupa kontrak yang memanggil kembali ke ``withdraw``. Ini akan membuatnya
mendapatkan beberapa pengembalian uang dan pada dasarnya mengambil semua Ether dalam kontrak.
Secara khusus, kontrak berikut akan memungkinkan penyerang untuk mengembalikan dana beberapa kali
karena menggunakan ``call`` yang meneruskan semua gas yang tersisa secara default:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    // THIS CONTRACT CONTAINS A BUG - DO NOT USE
    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            (bool success,) = msg.sender.call{value: shares[msg.sender]}("");
            if (success)
                shares[msg.sender] = 0;
        }
    }

Untuk menghindari re-entrancy, Anda dapat menggunakan pola Checks-Effects-Interactions seperti
diuraikan lebih lanjut di bawah ini:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            uint share = shares[msg.sender];
            shares[msg.sender] = 0;
            payable(msg.sender).transfer(share);
        }
    }

Perhatikan bahwa re-entrancy bukan hanya efek dari transfer Ether tetapi dari panggilan fungsi
apa pun pada kontrak lain. Selain itu, Anda juga harus mempertimbangkan situasi multi-kontrak.
Kontrak yang dipanggil dapat mengubah status kontrak lain yang Anda andalkan.

Gas Limit dan Loops
===================

Loop yang tidak memiliki jumlah iterasi tetap, misalnya loop yang bergantung pada nilai penyimpanan, harus digunakan dengan hati-hati:
Karena batasan gas blok, transaksi hanya dapat mengkonsumsi gas dalam jumlah tertentu. Baik secara eksplisit atau hanya karena
operasi normal, jumlah iterasi dalam satu lingkaran dapat tumbuh melampaui batas gas blok yang dapat menyebabkan penyelesaian
kontrak akan terhenti pada titik tertentu. Ini mungkin tidak berlaku untuk fungsi ``view`` yang hanya dijalankan
untuk membaca data dari blockchain. Namun, fungsi tersebut dapat dipanggil oleh kontrak lain sebagai bagian dari operasi on-chain
dan stall itu. Harap jelaskan secara eksplisit tentang kasus tersebut dalam dokumentasi kontrak Anda.

Mengirim dan Menerima Ether
===========================

- Baik kontrak maupun "akun eksternal" saat ini tidak dapat mencegah seseorang
  mengirim Ether kepada mereka. Kontrak dapat bereaksi dan menolak transfer biasa,
  tetapi ada cara untuk memindahkan Ether tanpa membuat panggilan pesan. Salah satu
  caranya adalah dengan "menambang ke" alamat kontrak dan cara kedua adalah menggunakan ``selfdestruct(x)``.

- Jika kontrak menerima Ether (tanpa fungsi dipanggil), baik fungsi :ref:`receive Ether <receive-ether-function>`
  atau :ref:`fallback <fallback-function>` dijalankan. Jika tidak memiliki fungsi terima atau fallback,
  Ether akan ditolak (dengan melempar pengecualian). Selama pelaksanaan salah satu fungsi ini, kontrak hanya
  dapat mengandalkan "gas stipend" yang diberikan (2300 gas) yang tersedia untuknya pada saat itu. Tunjangan
  ini tidak cukup untuk mengubah penyimpanan (jangan menganggap ini begitu saja, tunjangan mungkin berubah
  dengan hard forks di masa depan). Untuk memastikan bahwa kontrak Anda dapat menerima Ether dengan cara itu,
  periksa persyaratan gas dari fungsi terima dan fallback (misalnya di bagian "detail" di Remix).

- Ada cara untuk meneruskan lebih banyak gas ke kontrak penerima menggunakan
  ``addr.call{value: x}("")``. Ini pada dasarnya sama dengan ``addr.transfer(x)``, hanya saja ia meneruskan
  semua gas yang tersisa dan membuka kemampuan penerima untuk melakukan tindakan yang lebih mahal (dan
  mengembalikan kode kegagalan alih-alih secara otomatis menyebarkan kesalahan ). Ini mungkin termasuk
  memanggil kembali ke dalam kontrak pengiriman atau perubahan state lainnya yang mungkin tidak Anda pikirkan.
  Jadi memungkinkan fleksibilitas yang besar untuk pengguna yang jujur tetapi juga untuk aktor jahat.

- Gunakan unit yang paling tepat untuk mewakili jumlah wei sebanyak mungkin, karena Anda kehilangan
  semua yang dibulatkan karena kurangnya presisi.

- Jika Anda ingin mengirim Ether menggunakan ``address.transfer``, ada beberapa detail yang harus diperhatikan:

  1. Jika penerima adalah sebuah kontrak, itu menyebabkan fungsi recieve atau
     fallback dieksekusi yang pada gilirannya, dapat memanggil kembali kontrak pengirim.
  2. Mengirim Ether dapat gagal karena kedalaman panggilan di atas 1024. Karena pemanggil
     memegang kendali penuh atas kedalaman panggilan, mereka dapat memaksa transfer gagal;
     pertimbangkan kemungkinan ini atau gunakan ``send`` dan pastikan untuk selalu memeriksa
     nilai *return*nya. Lebih baik lagi, tulis kontrak Anda menggunakan pola di mana penerima
     dapat menarik Ether sebagai gantinya.
  3. Mengirim Ether juga dapat gagal karena pelaksanaan kontrak penerima membutuhkan lebih
     dari jumlah gas yang ditentukan (secara eksplisit dengan menggunakan :ref:`require <assert-and-require>`,
     :ref:`assert <assert-and-require> `, :ref:`revert <assert-and-require>` atau karena operasinya terlalu
     mahal) - "kehabisan gas" (OOG). Jika Anda menggunakan ``transfer`` atau ``send`` dengan pemeriksaan nilai
     pengembalian, ini mungkin memberikan cara bagi penerima untuk memblokir kemajuan dalam kontrak pengiriman.
     Sekali lagi, praktik terbaik di sini adalah menggunakan pola :ref:`"withdraw" alih-alih pola "send" <withdrawal_pattern>`.

Kedalaman Call Stack
====================

Panggilan fungsi eksternal dapat gagal kapan saja karena melebihi batas
ukuran stack panggilan maksimum 1024. Dalam situasi seperti itu, Solidity
mengeluarkan pengecualian. Pelaku jahat mungkin dapat memaksa stack panggilan
ke nilai tinggi sebelum mereka berinteraksi dengan kontrak Anda. Perhatikan
bahwa, sejak `Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_ hardfork, aturan `63/64 <https://eips.ethereum.org/EIPS/eip-150>`_
membuat serangan call stack depth menjadi tidak praktis. Perhatikan juga bahwa stack panggilan dan stack ekspresi tidak terkait, meskipun keduanya memiliki batas ukuran 1024 slot stack.

Perhatikan bahwa ``.send()`` **tidak** mengeluarkan pengecualian jika stack panggilan habis,
melainkan mengembalikan ``false`` dalam kasus tersebut. Fungsi tingkat rendah ``.call()``,
``.delegatecall()`` dan ``.staticcall()`` berperilaku dengan cara yang sama.

Authorized Proxies
==================

Jika kontrak Anda dapat bertindak sebagai proxy, yaitu jika kontrak tersebut dapat memanggil
kontrak arbitrer dengan data yang disediakan pengguna, maka pengguna pada dasarnya dapat mengasumsikan
identitas kontrak proxy. Bahkan jika Anda memiliki tindakan perlindungan lain, yang terbaik adalah
membangun sistem kontrak Anda sedemikian rupa sehingga proxy tidak memiliki izin apa pun (bahkan untuk
dirinya sendiri). Jika perlu, Anda dapat melakukannya menggunakan proxy kedua:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract ProxyWithMoreFunctionality {
        PermissionlessProxy proxy;

        function callOther(address _addr, bytes memory _payload) public
                returns (bool, bytes memory) {
            return proxy.callOther(_addr, _payload);
        }
        // Other functions and other functionality
    }

    // This is the full contract, it has no other functionality and
    // requires no privileges to work.
    contract PermissionlessProxy {
        function callOther(address _addr, bytes memory _payload) public
                returns (bool, bytes memory) {
            return _addr.call(_payload);
        }
    }

tx.origin
=========

Jangan pernah menggunakan tx.origin untuk otorisasi. Katakanlah Anda memiliki kontrak dompet seperti ini:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // THIS CONTRACT CONTAINS A BUG - DO NOT USE
    contract TxUserWallet {
        address owner;

        constructor() {
            owner = msg.sender;
        }

        function transferTo(address payable dest, uint amount) public {
            // THE BUG IS RIGHT HERE, you must use msg.sender instead of tx.origin
            require(tx.origin == owner);
            dest.transfer(amount);
        }
    }

Sekarang seseorang menipu Anda untuk mengirim Ether ke alamat dompet serangan ini:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    interface TxUserWallet {
        function transferTo(address payable dest, uint amount) external;
    }

    contract TxAttackWallet {
        address payable owner;

        constructor() {
            owner = payable(msg.sender);
        }

        receive() external payable {
            TxUserWallet(msg.sender).transferTo(owner, msg.sender.balance);
        }
    }

Jika dompet Anda telah memeriksa ``msg.sender`` untuk otorisasi, dompet tersebut akan mendapatkan alamat dompet penyerang, bukan alamat pemilik. Tetapi dengan memeriksa ``tx.origin``, ia mendapatkan alamat asli yang memulai transaksi, yang masih merupakan alamat pemilik. Dompet serangan langsung menguras semua dana Anda.

.. _underflow-overflow:

Dua Complement / Underflows / Overflows
=========================================

Seperti dalam banyak bahasa pemrograman, tipe integer Solidity sebenarnya bukan integer.
Mereka menyerupai integer ketika nilainya kecil, tetapi tidak dapat mewakili angka besar arbitrarily.

Kode berikut menyebabkan overflow karena hasil penjumlahan terlalu besar
untuk disimpan dalam tipe ``uint8``:

.. code-block:: solidity

  uint8 x = 255;
  uint8 y = 1;
  return x + y;

Solidity memiliki dua mode yang menangani overflows ini: mode Checked and Unchecked atau "wrapping".

Mode default checked akan mendeteksi overflows dan menyebabkan kegagalan assertion. Anda dapat menonaktifkan check
ini menggubakan ``unchecked { ... }``, menyebabkan overflow secara diam-diam di abaikan. Kode di atas akan kembali
``0`` jika di*wrap* dengan ``unchecked { ... }``.

Meskipun di mode checked, jangan berasumsi Anda terlindungi dari bug overflow.
Di dalam mode ini, overflows akan selalu revert. Jika tidak mungkin untuk menghindari
overflow, ini dapat menyebabkan smart kontrak terjebak dalam keadaan tertentu.

Secara umum, baca tentang batas representasi komplemen dua, yang bahkan memiliki beberapa
lebih banyak kasus tepi khusus untuk nomor yang ditandatangani.

Coba gunakan ``require`` untuk membatasi ukuran input ke kisaran yang wajar dan gunakan
:ref:`SMT checker<smt_checker>` untuk menemukan potensi overflow.

.. _clearing-mappings:

Clearing Mappings
=================

Solidity tipe ``mapping`` (lihat :ref:`mapping-types`) adalah struktur
storage-only key-value data yang tidak melacak kunci yang diberi nilai bukan nol.
Karena itu, pembersihan mapping tanpa informasi tambahan tentang kunci tertulis
tidak mungkin dilakukan. Jika ``mapping`` digunakan sebagai tipe dasar array penyimpanan
dinamis, menghapus atau memunculkan array tidak akan berpengaruh pada elemen ``mapping``.
Hal yang sama terjadi, misalnya, jika ``mapping`` digunakan sebagai tipe bidang anggota
dari ``struct`` yang merupakan tipe dasar array penyimpanan dinamis. ``mapping`` juga
diabaikan dalam penetapan struct atau array yang berisi ``mapping``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Map {
        mapping (uint => uint)[] array;

        function allocate(uint _newMaps) public {
            for (uint i = 0; i < _newMaps; i++)
                array.push();
        }

        function writeMap(uint _map, uint _key, uint _value) public {
            array[_map][_key] = _value;
        }

        function readMap(uint _map, uint _key) public view returns (uint) {
            return array[_map][_key];
        }

        function eraseMaps() public {
            delete array;
        }
    }

Perhatikan contoh di atas dan urutan panggilan berikut: ``allocate(10)``,
``writeMap(4, 128, 256)``.
Pada titik ini, memanggil ``readMap(4, 128)`` mengembalikan 256.
Jika kita memanggil ``eraseMaps``, panjang variabel status ``array`` adalah nol, tetapi
karena elemen ``pemetaan`` tidak dapat di-nolkan, informasinya tetap hidup
dalam penyimpanan kontrak.
Setelah menghapus ``array``, memanggil ``allocate(5)`` memungkinkan kita untuk mengakses
``array[4]`` lagi, dan memanggil ``readMap(4, 128)`` mengembalikan 256 bahkan tanpa
panggilan lain ke ``writeMap``.

Jika informasi ``mapping`` Anda harus dihapus, pertimbangkan untuk menggunakan library yang mirip dengan
`iterable mapping <https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol>`_,
memungkinkan Anda menelusuri kunci dan menghapus nilainya dalam ``mapping`` yang sesuai.

Minor Details
=============

- Jenis yang tidak menempati 32 byte penuh mungkin berisi "dirty higher order bits".
  Ini sangat penting jika Anda mengakses ``msg.data`` - itu menimbulkan resiko *malleability*:
  Anda dapat membuat transaksi yang memanggil fungsi ``f(uint8 x)`` dengan argumen byte mentah
  dari ``0xff000001`` dan dengan ``0x00000001``. Keduanya diumpankan ke kontrak dan keduanya akan
  terlihat seperti angka ``1`` sejauh menyangkut ``x``, tetapi ``msg.data`` akan
  berbeda, jadi jika Anda menggunakan ``keccak256(msg.data)`` untuk apa pun, Anda akan mendapatkan hasil yang berbeda.

***************
Rekomendasi
***************

Ambil Peringatan dengan Serius
==============================

Jika kompiler memperingatkan Anda tentang sesuatu, Anda harus mengubahnya.
Bahkan jika Anda tidak berpikir bahwa peringatan khusus ini memiliki implikasi
keamanan, mungkin ada masalah lain yang terkubur di bawahnya. Setiap peringatan
kompiler yang kami keluarkan dapat dibungkam dengan sedikit perubahan pada kode.

Selalu gunakan versi terbaru kompiler untuk diberi tahu tentang semua peringatan
yang baru saja diperkenalkan.

Pesan bertipe ``info`` yang dikeluarkan oleh kompilator tidak berbahaya, dan hanya
mewakili saran tambahan dan informasi opsional yang dipikirkan oleh kompiler
mungkin berguna bagi pengguna.

Membatasi Jumlah Ether
======================

Batasi jumlah Ether (atau token lainnya) yang dapat disimpan di smart
kontrak. Jika kode sumber Anda, kompiler, atau platform memiliki bug, dana
ini bisa hilang. Jika Anda ingin membatasi kerugian Anda, batasi jumlah Ether.

Tetap Kecil dan Modular
=======================

Jaga agar kontrak Anda tetap kecil dan mudah dimengerti. Pilih yang tidak terkait
fungsionalitas dalam kontrak lain atau ke perpustakaan. Rekomendasi umum
tentang kualitas kode sumber tentu saja berlaku: Batasi jumlah variabel lokal,
panjang fungsi dan sebagainya. Dokumentasikan fungsi Anda agar yang lain
dapat melihat apa niat Anda dan apakah itu berbeda dari apa yang dilakukan kode.

Gunakan pola Checks-Effects-Interactions
========================================

Sebagian besar fungsi pertama-tama akan melakukan beberapa pemeriksaan
(siapa yang memanggil fungsi, apakah argumen dalam jangkauan, apakah mereka
mengirim cukup Ether, apakah orang tersebut memiliki token, dll.). Pemeriksaan
ini harus dilakukan terlebih dahulu.

Sebagai langkah kedua, jika semua pemeriksaan lulus, efeknya pada variabel state
kontrak saat ini harus dibuat. Interaksi dengan kontrak lain
harus menjadi langkah terakhir dalam fungsi apa pun.

Kontrak awal menunda beberapa efek dan menunggu fungsi eksternal
panggilan untuk kembali dalam keadaan non-kesalahan. Ini sering merupakan kesalahan serius
karena masalah masuk kembali yang dijelaskan di atas.

Perhatikan bahwa, juga, panggilan ke kontrak yang diketahui dapat menyebabkan panggilan ke
kontrak yang tidak diketahui, jadi mungkin lebih baik untuk selalu menerapkan pola ini.

Sertakan mode Fail-Safe
=======================

Saat membuat sistem Anda terdesentralisasi sepenuhnya akan menghapus perantara apa pun,
mungkin ide yang bagus, terutama untuk kode baru, untuk memasukkan beberapa jenis
mekanisme fail-safe:

Anda dapat menambahkan fungsi dalam kontrak pintar Anda yang melakukan beberapa
self-check seperti "Apakah ada Ether yang bocor?",
"Apakah jumlah token sama dengan saldo kontrak?" atau hal serupa.
Ingatlah bahwa Anda tidak dapat menggunakan terlalu banyak gas untuk itu, jadi bantulah melalui off-chain
perhitungan mungkin diperlukan di sana.

Jika pemeriksaan mandiri gagal, kontrak secara otomatis berubah menjadi semacam
dari mode "failsafe", yang, misalnya, menonaktifkan sebagian besar fitur, menyerahkan
kontrol ke pihak ketiga yang tetap dan tepercaya atau hanya mengubah kontrak menjadi
kontrak sederhana "beri saya kembali uang saya".

Minta Review Sejawat
====================

Semakin banyak orang memeriksa sepotong kode, semakin banyak masalah yang ditemukan.
Meminta orang untuk meninjau kode Anda juga membantu sebagai pemeriksaan silang untuk mengetahui apakah kode Anda
mudah dimengerti - kriteria yang sangat penting untuk smart kontrak yang baik.
