.. index:: ! installing

.. _installing-solidity:

################################
Menginstal Kompiler Solidity
################################

Versioning
==========

Versi Solidity mengikuti `semantic versioning <https://semver.org>`_ dan sebagai tambahan
untuk rilis, versi **nightly development builds** juga tersedia. Nightly builds tidak
dijamin akan berfungsi dan meskipun telah dilakukan upaya terbaik build tersebut mungkin berisi perubahan
yang tidak terdokumentasi dan/atau rusak. Kami merekomendasikan menggunakan rilis terbaru. Penginstal paket di bawah ini
akan menggunakan rilis terbaru.

Remix
=====

*Kami merekomendasikan Remix untuk kontrak kecil dan untuk mempelajari Solidity dengan cepat.*

`Akses Remix online <https://remix.ethereum.org/>`_, anda tidak perlu menginstal apapun.
Jika ingin menggunakannya tanpa koneksi internet, silahkan kunjungi
https://github.com/ethereum/remix-live/tree/gh-pages dan download file ``.zip`` seperti
yang dijelaskan dalam halaman tersebut. Remix juga merupakan opsi yang nyaman untuk menguji nightly builds
tanpa menginstal beberapa versi Solidity.

Opsi lebih lanjut di halaman ini merinci penginstalan sofware commandline Solidity compiler
di komputer anda. Pilih commandline compiler jika anda mengerjakan kontrak yang lebih besar
atau jika anda membutuhkan lebih banyak opsi compilation.

.. _solcjs:

npm / Node.js
=============

Gunakan ``npm`` untuk cara pemasangan ``solcjs`` sebuah Solidity compiler yang nyaman dan portabel.
program `solcjs` memiliki sedikit fitur daripada cara mengakses kompiler yang dijelaskan
lebih lanjut di halaman ini. dokumentasi
:ref:`commandline-compiler` menganggap Anda menggunakan
kompiler berfitur lengkap, ``solc``. Penggunaan ``solcjs`` didokumentasikan di dalam
`repository <https://github.com/ethereum/solc-js>`_ nya sendiri.

Note: Proyek solc-js diturunkan dari C++
`solc` dengan menggunakan Emscripten yang artinya keduanya menggunakan source code compiler yang sama.
`solc-js` dapat digunakan dalam proyek JavaScript secara langsung (seperti Remix).
Silakan merujuk ke repositori solc-js untuk instruksi.

.. code-block:: bash

    npm install -g solc

.. note::

    Commandline yang dapat dieksekusi bernama ``solcjs``.

    Opsi baris perintah ``solcjs`` tidak kompatibel dengan ``solc`` dan alat (seperti ``geth``)
    mengharapkan perilaku ``solc`` tidak akan bekerja dengan ``solcjs``.

Docker
======

Image Docker dari build Solidity tersedia menggunakan image ``solc`` dari organisasi ``ethereum``.
Gunakan tag ``stable`` untuk versi rilis terbaru, dan ``nightly`` untuk perubahan yang berpotensi tidak stabil di branch pengembangan.

Image Docker menjalankan kompiler yang dapat dieksekusi, sehingga Anda dapat meneruskan semua argumen kompiler ke dalamnya.
Misalnya, perintah di bawah ini menarik versi stabil dari image ``solc`` (jika Anda belum memilikinya),
dan menjalankannya dalam kontainer baru, melewati argumen ``--help``.

.. code-block:: bash

    docker run ethereum/solc:stable --help

Anda juga dapat menentukan versi build rilis di tag, misalnya, untuk rilis 0.5.4.

.. code-block:: bash

    docker run ethereum/solc:0.5.4 --help

Untuk menggunakan image Docker untuk mengkompilasi file Solidity di mesin host, *mount* folder lokal untuk input dan output,
dan tentukan kontrak untuk dikompilasi. Sebagai contoh.

.. code-block:: bash

    docker run -v /local/path:/sources ethereum/solc:stable -o /sources/output --abi --bin /sources/Contract.sol

Anda juga dapat menggunakan antarmuka JSON standar (yang direkomendasikan saat menggunakan kompiler dengan *tooling*).
Saat menggunakan antarmuka ini, tidak perlu *me-mount* direktori apa pun selama input JSON
*self-contained* (yaitu tidak merujuk ke file eksternal apa pun yang harus
:ref:`dimuat oleh impor callback <initial-vfs -content-standard-json-with-import-callback>`).

.. code-block:: bash

    docker run ethereum/solc:stable --standard-json < input.json > output.json

paket linux
==============

Paket biner Solidity tersedia di
`solidity/releases <https://github.com/ethereum/solidity/releases>`_.

Kami juga memiliki PPA untuk Ubuntu, Anda bisa mendapatkan
versi stabil terbaru menggunakan perintah berikut:

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install solc

Versi nightly dapat diinstal menggunakan perintah berikut:

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo add-apt-repository ppa:ethereum/ethereum-dev
    sudo apt-get update
    sudo apt-get install solc

Kami juga merilis `paket snap <https://snapcraft.io/>`_,
yang dapat diinstal di semua `distro Linux yang didukung
<https://snapcraft.io/docs/core/install>`_. Untuk menginstal solc versi stabil terbaru:

.. code-block:: bash

    sudo snap install solc

Jika Anda ingin membantu menguji versi pengembangan terbaru Solidity
dengan perubahan terbaru, silakan gunakan yang berikut ini:

.. code-block:: bash

    sudo snap install solc --edge

.. note::

    Snap ``solc`` menggunakan *confinement* yang ketat. Ini adalah mode paling aman untuk paket snap
    tetapi memiliki batasan, seperti hanya mengakses file di direktori ``/home`` dan ``/media`` Anda.
    Untuk informasi selengkapnya, buka `Demystifying Snap Confinement <https://snapcraft.io/blog/demystifying-snap-confinement>`_.

Arch Linux juga mempunyai paket, meskipun terbatas pada versi pengembangan terbaru:

.. code-block:: bash

    pacman -S solidity

Gentoo Linux memiliki `Ethereum overlay <https://overlays.gentoo.org/#ethereum>`_ yang berisi paket Solidity.
Setelah overlay diatur, ``solc`` dapat diinstal di arsitektur x86_64 dengan:

.. code-block:: bash

    emerge dev-lang/solidity

Paket macOS
==============

Kami mendistribusikan compiler Solidity melalui Homebrew
sebagai versi build-from-source. Pre-built bottles saat
ini tidak didukung.

.. code-block:: bash

    brew update
    brew upgrade
    brew tap ethereum/ethereum
    brew install solidity

Untuk menginstal yang versi Solidity terbaru 0.4.x / 0.5.x anda juga bisa menggunakan ``brew install solidity@4``
dan ``brew install solidity@5``, berturut-turut.

Jika Anda memerlukan versi Solidity tertentu, Anda dapat menginstal
formula Homebrew langsung dari Github.

Lihat
`solidity.rb commits di Github <https://github.com/ethereum/homebrew-ethereum/commits/master/solidity.rb>`_.

Salin comit hash dari versi yang Anda inginkan dan periksa di mesin Anda.

.. code-block:: bash

    git clone https://github.com/ethereum/homebrew-ethereum.git
    cd homebrew-ethereum
    git checkout <your-hash-goes-here>

Menginstal menggunakan ``brew``:

.. code-block:: bash

    brew unlink solidity
    # eg. Install 0.4.8
    brew install solidity.rb

Binari statis
=============

Kami memaintain repositori yang berisi build statis dari versi kompiler sebelumnya dan saat ini untuk semua
platform yang didukung di `solc-bin`_. Ini juga merupakan lokasi di mana Anda dapat menemukan nightly builds.

Repositori bukan hanya cara cepat dan mudah bagi pengguna  untuk menyiapkan binari agar siap digunakan
*out-of-the-box*, tetapi juga dimaksudkan agar ramah terhadap alat pihak ketiga:

- Konten di*mirror*kan ke https://binaries.soliditylang.org di mana dapat dengan mudah diunduh
  melalui HTTPS tanpa autentikasi, pembatasan kecepatan, atau tanpa menggunakan git.
- Konten disajikan dengan header `Content-Type` yang benar dan konfigurasi CORS yang lunak sehingga
  dapat langsung dimuat oleh alat yang berjalan di browser.
- Binari tidak memerlukan instalasi atau unpacking (dengan pengecualian build Windows yang lebih lama
  dibundel dengan DLL yang diperlukan).
- Kami berusaha keras untuk backward-compatibility tingkat tinggi. File, setelah ditambahkan, tidak dihapus atau dipindahkan
  tanpa memberikan symlink/pengalihan di lokasi lama. Mereka juga tidak pernah dimodifikasi
  di tempat dan harus selalu cocok dengan checksum asli. Satu-satunya pengecualian adalah file yang rusak atau
  idak dapat digunakan dengan potensi menyebabkan lebih banyak kerusakan daripada perbaikan jika dibiarkan apa adanya.
- File disajikan melalui HTTP dan HTTPS. Selama Anda mendapatkan daftar file dengan cara yang aman
  (melalui git, HTTPS, IPFS atau hanya menyimpannya di cache secara lokal) dan memverifikasi hash dari binari
  setelah mengunduhnya, Anda tidak perlu menggunakan HTTPS untuk binari itu sendiri.

Binari yang sama biasanya tersedia di `Laman rilis Solidity di Github`_.
Perbedaannya adalah kami biasanya tidak memperbarui rilis lama di halaman rilis Github.
Ini berarti bahwa kami tidak mengganti namanya jika konvensi penamaan berubah dan kami tidak menambahkan
build untuk platform yang tidak didukung pada saat rilis. Ini hanya terjadi di ``solc-bin``.

Repositori ``solc-bin`` berisi beberapa direktori Top-level, masing-masing mewakili satu platform.
Masing-masing berisi file ``list.json`` yang mencantumkan binari yang tersedia. Sebagai contoh, di
``emscripten-wasm32/list.json`` Anda akan menemukan informasi berikut tentang versi 0.7.4:

.. code-block:: json

    {
      "path": "solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js",
      "version": "0.7.4",
      "build": "commit.3f05b770",
      "longVersion": "0.7.4+commit.3f05b770",
      "keccak256": "0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3",
      "sha256": "0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2",
      "urls": [
        "bzzr://16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1",
        "dweb:/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS"
      ]
    }

Ini berarti bahwa:

- Anda dapat menemukan biner di direktori yang sama dengan nama
  `solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js <https://github.com/ethereum/solc-bin/blob/gh-pages/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js>`_.
  Perhatikan bahwa file tersebut mungkin berupa symlink, dan Anda harus menyelesaikannya sendiri jika tidak menggunakan
  git untuk mengunduhnya atau sistem file Anda tidak mendukung symlink.
- Binary juga di*mirror*kan ke https://binaries.soliditylang.org/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js.
  Dalam hal ini git tidak diperlukan dan symlink diselesaikan secara transparan, baik dengan menyajikan salinan
  file atau mengembalikan pengalihan HTTP.
- File juga tersedia di IPFS di `QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS`_.
- File mungkin di masa depan juga tersedia di Swarm di `16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1`_.
- Anda dapat memverifikasi integritas biner dengan membandingkan hash keccak256 dengan
  ``0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3``.  Hash dapat dihitung
  pada baris perintah menggunakan utilitas ``keccak256sum`` yang disediakan oleh fungsi `sha3sum`_ atau fungsi `keccak256()
  dari ethereumjs-util`_ dalam JavaScript.
- Anda juga dapat memverifikasi integritas biner dengan membandingkan hash sha256 dengan
  ``0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2``.

.. warning::

   Karena persyaratan *backwards compatibility* yang kuat, repositori berisi beberapa elemen warisan
   tetapi Anda harus menghindari menggunakannya saat menulis alat baru:

   - Gunakan ``emscripten-wasm32/`` (dengan fallback ke ``emscripten-asmjs/``) daripada ``bin/`` jika
     anda ingin performa yang terbaik. Sampai versi 0.6.1 kami hanya menyediakan binari asm.js.
     Dimulai dengan 0.6.2 kami beralih ke `WebAssembly builds`_ dengan performa yang lebih baik. Kami telah
     membangun kembali versi lama untuk wasm tetapi file asm.js original tetap berada di ``bin/``.
     Yang baru harus ditempatkan di direktori terpisah untuk menghindari bentrokan nama.
   - Gunakan ``emscripten-asmjs/`` dan ``emscripten-wasm32/`` daripada direktori ``bin/`` dan ``wasm/``
     jika Anda ingin memastikan apakah Anda mengunduh biner wasm atau asm.js.
   - Gunakan ``list.json`` daripada ``list.js`` dan ``list.txt``. Format daftar JSON berisi semua
     informasi dari yang lama dan banyak lagi.
   - Gunakan https://binaries.soliditylang.org daripada https://solc-bin.ethereum.org. Untuk mempermudah,
     kami memindahkan hampir semua yang terkait dengan compiler dibawah domain ``soliditylang.org``
     yang baru dan ini berlakujuga untuk ``solc-bin``. Sementara domain baru direkomendasikan, yang lama
     masih didukung penuh dan dijamin mengarah ke lokasi yang sama.

.. warning::

    Binari juga tersedia di https://ethereum.github.io/solc-bin/ tetapi halaman ini
    berhenti diperbarui setelah rilis versi 0.7.2, dan tidak akan menerima rilis baru
    atau nightly build untuk platform apa pun juga tidak melayani struktur direktori baru, termasuk
    build non-emscripten.

    Jika Anda menggunakannya, silakan beralih ke https://binary.soliditylang.org, yang merupakan pengganti drop-in.
    Ini memungkinkan kami untuk membuat perubahan pada hosting yang mendasarinya secara transparan dan meminimalkan gangguan.
    Tidak seperti domain ``ethereum.github.io``, yang tidak kami kendalikan, ``binary.soliditylang.org`` dijamin berfungsi dan
    mempertahankan struktur URL yang sama dalam jangka panjang.

.. _IPFS: https://ipfs.io
.. _Swarm: https://swarm-gateways.net/bzz:/swarm.eth
.. _solc-bin: https://github.com/ethereum/solc-bin/
.. _Solidity release page on github: https://github.com/ethereum/solidity/releases
.. _sha3sum: https://github.com/maandree/sha3sum
.. _keccak256() function from ethereumjs-util: https://github.com/ethereumjs/ethereumjs-util/blob/master/docs/modules/_hash_.md#const-keccak256
.. _WebAssembly builds: https://emscripten.org/docs/compiling/WebAssembly.html
.. _QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS: https://gateway.ipfs.io/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS
.. _16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1: https://swarm-gateways.net/bzz:/16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1/

.. _building-from-source:

Membangun dari Sumber (Building from source)
============================================

Prasyarat - Semua Sistem Operasi
-------------------------------------

Berikut ini adalah dependensi untuk semua build Solidity:

+-----------------------------------+-------------------------------------------------------+
| Software                          | Notes                                                 |
+===================================+=======================================================+
| `CMake`_ (version 3.13+)          | Cross-platform build file generator.                  |
+-----------------------------------+-------------------------------------------------------+
| `Boost`_ (version 1.77+ on        | C++ libraries.                                        |
| Windows, 1.65+ otherwise)         |                                                       |
+-----------------------------------+-------------------------------------------------------+
| `Git`_                            | Command-line tool for retrieving source code.         |
+-----------------------------------+-------------------------------------------------------+
| `z3`_ (version 4.8+, Optional)    | For use with SMT checker.                             |
+-----------------------------------+-------------------------------------------------------+
| `cvc4`_ (Optional)                | For use with SMT checker.                             |
+-----------------------------------+-------------------------------------------------------+

.. _cvc4: https://cvc4.cs.stanford.edu/web/
.. _Git: https://git-scm.com/download
.. _Boost: https://www.boost.org
.. _CMake: https://cmake.org/download/
.. _z3: https://github.com/Z3Prover/z3

.. note::
    Versi solidity sebelum 0.5.10 dapat gagal menautkan dengan benar ke versi Boost 1.70+.
    Solusi yang mungkin adalah mengganti nama sementara ``<Boost install path>/lib/cmake/Boost-1.70.0``
    sebelum menjalankan perintah cmake untuk mengkonfigurasi solidity.

    Mulai dari 0.5.10 penautan terhadap Boost 1.70+ seharusnya bekerja tanpa intervensi manual.

.. note::
    Konfigurasi build default memerlukan versi Z3 tertentu (yang terbaru pada saat
    kode terakhir diperbarui). Perubahan yang diperkenalkan antara rilis Z3 sering menghasilkan sedikit perbedaan
    dengan hasil yang diperoleh (tetapi masih valid). Tes SMT kami tidak memperhitungkan perbedaan ini dan
    kemungkinan akan gagal dengan versi yang berbeda dari yang mereka tulis. Ini bukan berarti
    bahwa build yang menggunakan versiberbeda itu salah. Jika Anda melewati opsi ``-DSTRICT_Z3_VERSION=OFF``
    untuk CMake, Anda dapat membangun dengan versi apa pun yang memenuhi persyaratan yang diberikan dalam tabel di atas.
    Namun, jika Anda melakukan ini, harap ingat untuk meneruskan opsi ``--no-smt`` ke ``scripts/tests.sh``
    untuk melewati tes SMT.

Versi Compiler Minimum
^^^^^^^^^^^^^^^^^^^^^^^^^

Kompiler C++ berikut dan versi minimumnya dapat mem*build* basis kode Solidity:

- `GCC <https://gcc.gnu.org>`_, version 8+
- `Clang <https://clang.llvm.org/>`_, version 7+
- `MSVC <https://visualstudio.microsoft.com/vs/>`_, version 2019+

Prasyarat - macOS
---------------------

Untuk macOS, pastikan bahwa anda telah menginstal `Xcode <https://developer.apple.com/xcode/download/>`_
versi terbaru.
Yang berisi `Clang C++ compiler <https://en.wikipedia.org/wiki/Clang>`_,
`Xcode IDE <https://en.wikipedia.org/wiki/Xcode>`_ dan alat pengembangan Apple lainnya
yang dibuthkan untuk membangun aplikasi C++ di OS X.
Jika Anda menginstal Xcode untuk pertama kalinya, atau baru saja menginstal versi baru,
Anda harus menyetujui lisensi sebelum Anda dapat melakukan builds command-line :

.. code-block:: bash

    sudo xcodebuild -license accept

Build Skrip OS X kami menggunakan `Homebrew <https://brew.sh>`_
manajer paket untuk menginstal dependensi eksternal.
Berikut cara `mencopot pemasangan Homebrew
<https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew>`_,
jika Anda ingin memulai lagi dari awal.

Prasyarat - Windows
-----------------------

Anda perlu menginstal dependensi berikut untuk membangun Solidity di Windows:

+-----------------------------------+-------------------------------------------------------+
| Software                          | Notes                                                 |
+===================================+=======================================================+
| `Visual Studio 2019 Build Tools`_ | C++ compiler                                          |
+-----------------------------------+-------------------------------------------------------+
| `Visual Studio 2019`_  (Optional) | C++ compiler and dev environment.                     |
+-----------------------------------+-------------------------------------------------------+
| `Boost`_ (version 1.77+)          | C++ libraries.                                        |
+-----------------------------------+-------------------------------------------------------+

Jika Anda sudah memiliki satu IDE dan hanya membutuhkan compiler dan library,
anda dapat menginstal Visual Studio 2019 Build Tools.

Visual Studio 2019 menyediakan IDE,compiler dan library yang diperlukan.
Jadi jika Anda belum punya IDE dan lebih suka mengembangkan Solidity, Visual Studio 2019
mungkin menjadi pilihan bagi Anda untuk mendapatkan semuanya dengan mudah.

Berikut adalah daftar komponen yang harus diinstal
di Visual Studio 2019 Build Tools atau Visual Studio 2019:

* Visual Studio C++ core features
* VC++ 2019 v141 toolset (x86,x64)
* Windows Universal CRT SDK
* Windows 8.1 SDK
* C++/CLI support

.. _Visual Studio 2019: https://www.visualstudio.com/vs/
.. _Visual Studio 2019 Build Tools: https://www.visualstudio.com/downloads/#build-tools-for-visual-studio-2019

Kami memiliki skrip pembantu yang dapat Anda gunakan untuk menginstal semua dependensi eksternal yang diperlukan:

.. code-block:: bat

    scripts\install_deps.ps1

INi akan mengisntal ``boost`` dan ``cmake`` ke dalam subdirectory ``deps``.

Mengkloning Repositori
-----------------------

Untuk mengkloning kode sumber, jalankan perintah berikut:

.. code-block:: bash

    git clone --recursive https://github.com/ethereum/solidity.git
    cd solidity

Jika Anda ingin membantu mengembangkan Solidity,
anda harus mem*fork* Solidity dan tambahkan fork pribadi Anda sebagai remote kedua:

.. code-block:: bash

    git remote add personal git@github.com:[username]/solidity.git

.. note::
    Metode ini akan menghasilkan build prarilis yang mengarah ke mis. sebuah flag
    diatur dalam setiap bytecode yang dihasilkan oleh kompiler tersebut.
    Jika Anda ingin membangun kembali kompiler Solidity yang dirilis, maka
    silakan gunakan tarball dari sumber di halaman rilis github:

    https://github.com/ethereum/solidity/releases/download/v0.X.Y/solidity_0.X.Y.tar.gz

    (bukan "Kode sumber" yang disediakan oleh github).

Command-Line Build
------------------

**Pastikan untuk menginstal External Dependencies (lihat di atas) sebelum melakukan build.**

Proyek solidity menggunakan CMake untuk mengonfigurasi build.
Anda mungkin ingin menginstal `ccache`_ untuk mempercepat build berulang.
CMake akan mengambilnya secara otomatis.
Membangun Solidity sangat mirip di Linux, macOS, dan Unix lainnya:

.. _ccache: https://ccache.dev/

.. code-block:: bash

    mkdir build
    cd build
    cmake .. && make

atau bahkan lebih mudah di Linux dan macOS, Anda dapat menjalankan:

.. code-block:: bash

    #note: this will install binaries solc and soltest at usr/local/bin
    ./scripts/build.sh

.. warning::

    Build BSD seharusnya berfungsi, tetapi belum diuji oleh tim Solidity.

Dan untuk Windows:

.. code-block:: bash

    mkdir build
    cd build
    cmake -G "Visual Studio 16 2019" ..

Jika Anda ingin menggunakan versi boost yang diinstal oleh ``scripts\install_deps.ps1``, anda juga
harus melewati ``-DBoost_DIR="deps\boost\lib\cmake\Boost-*"`` dan ``-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded``
sebagai argumen untuk memanggil ``cmake``.

Ini akan menghasilkan pembuatan **solidity.sln** di direktori build tersebut.
Mengklik dua kali pada file itu akan menghasilkan Visual Studio yang terbuka.  Kami menyarankan untuk membuat
konfigurasi **Release**, tetapi yang lainnya tetap berfungsi.

Atau, Anda dapat mem*build* untuk Windows di command-line, dengan:

.. code-block:: bash

    cmake --build . --config Release

CMake Options
=============

Jika Anda tertarik dengan opsi CMake apa yang tersedia, jalankan ``cmake .. -LH``.

.. _smt_solvers_build:

SMT Solvers
-----------
Solidity dapat dibangun bertentangan dengan SMT solver dan akan melakukannya secara default
jika ditemukan dalam sistem. Setiap solver dapat dinonaktifkan dengan opsi `cmake`.

*Note: Dalam beberapa kasus, ini juga bisa menjadi solusi potensial untuk kegagalan build.*


Di dalam folder build Anda dapat menonaktifkannya, karena diaktifkan secara default:

.. code-block:: bash

    # disables only Z3 SMT Solver.
    cmake .. -DUSE_Z3=OFF

    # disables only CVC4 SMT Solver.
    cmake .. -DUSE_CVC4=OFF

    # disables both Z3 and CVC4
    cmake .. -DUSE_CVC4=OFF -DUSE_Z3=OFF

String Versi secara Detail
============================

String versi Solidity berisi empat bagian:

- nomor versi
- tag pra-rilis, biasanya disetel ke ``develop.YYYY.MM.DD`` atau ``nightly.YYYY.MM.DD``
- komit dalam format ``commit.GITHASH``
- platform, yang memiliki jumlah item yang berubah-ubah, berisi detail tentang platform dan kompiler

Jika ada modifikasi lokal, komit akan di-postfixed dengan ``.mod``.

Bagian-bagian ini digabungkan seperti yang dipersyaratkan oleh Semver, di mana tag pra-rilis Solidity sama dengan pra-rilis Semver
dan komit Solidity dan platform yang digabungkan membentuk metadata build Semver.

Contoh rilis: ``0.4.8+commit.60cc1668.Emscripten.clang``.

Contoh pre-release: ``0.4.9-nightly.2017.1.17+commit.6ecb4aa3.Emscripten.clang``

Informasi Penting Tentang Pembuatan Versi
=========================================

Setelah rilis dibuat, tingkat versi patch terbentur, karena kami berasumsi bahwa hanya
perubahan tingkat patch yang mengikuti. Saat perubahan digabung, versi harus dibenturkan sesuai
dengan semver dan tingkat keparahan perubahan. Terakhir, rilis selalu dibuat dengan versi nightly build
saat ini, tetapi tanpa specifier ``prerelease``.

Contoh:

0. Rilis 0.4.0 dibuat.
1. Nightly build memiliki versi 0.4.1 mulai sekarang.
2. Perubahan non-breaking diperkenalkan --> tidak ada perubahan versi.
3. Pembaharuan diperkenalkan --> versi terbentur ke 0.5.0.
4. Rilis 0.5.0 dibuat.

Perilaku ini berfungsi baik dengan :ref:`versi pragma <version_pragma>`.
