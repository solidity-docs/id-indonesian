.. _path-resolution:

**********************
Import Path Resolution
**********************

Agar dapat mendukung build yang dapat direproduksi di semua platform, kompiler Solidity harus
mengabstraksikan detail filesystem tempat file sumber disimpan.
Jalur yang digunakan dalam impor harus bekerja dengan cara yang sama di mana saja sedangkan antarmuka baris perintah harus
dapat bekerja dengan jalur khusus platform untuk memberikan pengalaman pengguna yang baik.
Bagian ini bertujuan untuk menjelaskan secara rinci bagaimana Solidity merekonsiliasi persyaratan ini.

.. index:: ! virtual filesystem, ! VFS, ! source unit name
.. _virtual-filesystem:

Virtual Filesystem
==================

Kompilator memelihara database internal (*sistem file virtual* atau *VFS* singkatnya) di mana masing-masing
unit sumber diberi *source unit name* unik yang merupakan pengidentifikasi buram dan tidak terstruktur.
Saat Anda menggunakan :ref:`import statement <import>`, Anda menentukan *import path* yang mereferensikan
nama unit sumber.

.. index:: ! import callback, ! Host Filesystem Loader
.. _import-callback:

Import Callback
---------------

VFS awalnya hanya diisi dengan file yang telah diterima oleh kompiler sebagai input.
File tambahan dapat dimuat selama kompilasi menggunakan *import callback*, yang berbeda
tergantung pada jenis kompiler yang Anda gunakan (lihat di bawah).
Jika kompiler tidak menemukan nama unit sumber yang cocok dengan jalur impor di VFS, ia akan memanggil
callback, yang bertanggung jawab untuk mendapatkan kode sumber untuk ditempatkan di bawah nama itu.
Import callback bebas untuk menafsirkan nama unit sumber dengan cara yang sewenang-wenang, bukan hanya sebagai jalur.
Jika tidak ada callback yang tersedia saat diperlukan atau jika gagal menemukan kode sumber,
kompilasi gagal.

Kompilator baris perintah menyediakan *Host Filesystem Loader* - callback yang belum sempurna
yang menafsirkan nama unit sumber sebagai jalur di sistem file lokal.
`Antarmuka JavaScript <https://github.com/ethereum/solc-js>`_ tidak menyediakan apa pun secara default,
tetapi satu dapat disediakan oleh pengguna.
Mekanisme ini dapat digunakan untuk mendapatkan kode sumber dari lokasi selain sistem file lokal
(yang bahkan mungkin tidak dapat diakses, misalnya ketika kompiler berjalan di browser).
Misalnya `Remix IDE <https://remix.ethereum.org/>`_ menyediakan callback serbaguna yang
memungkinkan Anda `mengimpor file dari HTTP, IPFS, dan URL Swarm atau merujuk langsung ke paket di registri NPM
<https://remix-ide.readthedocs.io/en/latest/import.html>`_.

.. note::

    Pencarian file Host Filesystem Loader bergantung pada platform.
    Misalnya garis miring terbalik dalam nama unit sumber dapat diartikan sebagai pemisah direktori atau tidak
    dan pencarian bisa peka huruf besar-kecil atau tidak, tergantung pada platform yang mendasarinya.

    Untuk portabilitas, disarankan untuk menghindari penggunaan jalur impor yang hanya berfungsi dengan benar
    dengan panggilan balik impor tertentu atau hanya pada satu platform.
    Misalnya, Anda harus selalu menggunakan garis miring ke depan karena garis miring tersebut berfungsi sebagai pemisah
    jalur juga pada platform yang mendukung garis miring terbalik.

Konten Awal Filesystem Virtual
------------------------------

Konten awal VFS bergantung pada cara Anda memanggil kompiler:

#. **solc / command-line interface**

   Saat Anda mengkompilasi file menggunakan antarmuka baris perintah kompiler, Anda menyediakan satu atau
   lebih banyak jalur ke file yang berisi kode Solidity:

   .. code-block:: bash

       solc contract.sol /usr/local/dapp-bin/token.sol

   Nama unit sumber dari file yang dimuat dengan cara ini dibuat dengan mengonversi jalurnya ke bentuk
   kanonik dan, jika mungkin, membuatnya relatif terhadap jalur dasar atau salah satu jalur penyertaan.
   Lihat :ref:`CLI Path Normalization and Stripping <cli-path-normalization-and-stripping>` untuk penjelasan
   rinci tentang proses ini.

   .. index:: standard JSON

#. **Standard JSON**

   Saat menggunakan :ref:`Standard JSON <compiler-api>` API (melalui antarmuka `JavaScript
   <https://github.com/ethereum/solc-js>`_ atau opsi baris perintah ``--standard-json``)
   Anda memberikan input dalam format JSON, yang berisi, antara lain, konten semua file sumber
   Anda:

   .. code-block:: json

       {
           "language": "Solidity",
           "sources": {
               "contract.sol": {
                   "content": "import \"./util.sol\";\ncontract C {}"
               },
               "util.sol": {
                   "content": "library Util {}"
               },
               "/usr/local/dapp-bin/token.sol": {
                   "content": "contract Token {}"
               }
           },
           "settings": {"outputSelection": {"*": { "*": ["metadata", "evm.bytecode"]}}}
       }

   Kamus ``sources`` menjadi konten awal sistem file virtual dan kuncinya
   digunakan sebagai nama unit sumber.

   .. _initial-vfs-content-standard-json-with-import-callback:

#. **Standard JSON (via import callback)**

   Dengan JSON Standar, juga memungkinkan untuk memberi tahu kompiler untuk menggunakan import callback untuk mendapatkan
   kode sumber:

   .. code-block:: json

       {
           "language": "Solidity",
           "sources": {
               "/usr/local/dapp-bin/token.sol": {
                   "urls": [
                       "/projects/mytoken.sol",
                       "https://example.com/projects/mytoken.sol"
                   ]
               }
           },
           "settings": {"outputSelection": {"*": { "*": ["metadata", "evm.bytecode"]}}}
       }

   Jika import callback tersedia, kompiler akan memberikan string yang ditentukan dalam
   ``urls`` satu per satu, sampai satu berhasil dimuat atau akhir dari daftar tercapai.

   Nama unit sumber ditentukan dengan cara yang sama seperti saat menggunakan ``content`` - mereka adalah kunci dari
   kamus ``sources`` dan konten ``url`` tidak memengaruhinya dengan cara apa pun.

   .. index:: standard input, stdin, <stdin>

#. **Standard input**

   Pada baris perintah juga dimungkinkan untuk menyediakan sumber dengan mengirimkan input standar
   ke kompiler:

   .. code-block:: bash

       echo 'import "./util.sol"; contract C {}' | solc -

   ``-`` digunakan sebagai salah satu argumen yang menginstruksikan kompiler untuk menempatkan
   konten input standar dalam sistem file virtual di bawah nama unit sumber khusus: ``<stdin>``.

Setelah VFS diinisialisasi, file tambahan masih dapat ditambahkan hanya melalui import
callback.

.. index:: ! import; path

Imports
=======

Pernyataan impor menentukan *jalur impor*.
Berdasarkan cara menentukan jalur impor, kita dapat membagi impor menjadi dua kategori:

- :ref:`Direct imports <direct-imports>`, di mana Anda menentukan nama unit sumber lengkap secara langsung.
- :ref:`Relative imports <relative-imports>`, di mana Anda menentukan jalur yang dimulai dengan ``./`` atau ``../``
  untuk digabungkan dengan nama unit sumber dari file pengimpor.


.. code-block:: solidity
    :caption: contracts/contract.sol

    import "./math/math.sol";
    import "contracts/tokens/token.sol";

Dalam ``./math/math.sol`` di atas dan ``contracts/token/token.sol`` adalah jalur impor sedangkan
nama unit sumber yang mereka terjemahkan adalah ``contracts/math/math.sol`` dan ``contracts/token/token.sol``
berturutan.

.. index:: ! direct import, import; direct
.. _direct-imports:

Direct Imports
--------------

Impor yang tidak dimulai dengan ``./`` atau ``../`` adalah *impor langsung*.

.. code-block:: solidity

    import "/project/lib/util.sol";         // source unit name: /project/lib/util.sol
    import "lib/util.sol";                  // source unit name: lib/util.sol
    import "@openzeppelin/address.sol";     // source unit name: @openzeppelin/address.sol
    import "https://example.com/token.sol"; // source unit name: https://example.com/token.sol

Setelah menerapkan :ref:`import remappings <import-remapping>` jalur impor menjadi
nama unit sumber.

.. note::

    Nama unit sumber hanyalah pengidentifikasi dan bahkan jika nilainya terlihat seperti jalur, itu
    tidak tunduk pada aturan normalisasi yang biasanya Anda harapkan di shell.
    Setiap segmen ``/./`` atau ``/../`` atau urutan beberapa garis miring tetap menjadi bagian darinya.
    Ketika sumber disediakan melalui antarmuka JSON Standar, sangat mungkin untuk mengaitkan
    konten yang berbeda dengan nama unit sumber yang akan merujuk ke file yang sama pada disk.

Ketika sumber tidak tersedia di sistem file virtual, kompiler meneruskan nama unit sumber
ke import callback.
Host Filesystem Loader akan mencoba menggunakannya sebagai jalur dan mencari file di disk.
Pada titik ini aturan normalisasi khusus platform mulai berlaku dan nama-nama yang dipertimbangkan
berbeda dalam VFS sebenarnya dapat mengakibatkan file yang sama sedang dimuat.
Misalnya ``/project/lib/math.sol`` dan ``/project/lib/../lib///math.sol`` dianggap
sama sekali berbeda di VFS meskipun mereka merujuk ke file yang sama di disk.

.. note::

    Bahkan jika import callback akhirnya memuat kode sumber untuk dua nama unit sumber yang berbeda dari
    file yang sama pada disk, kompiler masih akan melihatnya sebagai unit sumber yang terpisah.
    nama unit sumber yang terpenting, bukan lokasi fisik kode.

.. index:: ! relative import, ! import; relative
.. _relative-imports:

Relative Imports
----------------

Impor yang dimulai dengan ``./`` atau ``../`` adalah *impor relatif*.
Impor tersebut menentukan jalur relatif terhadap nama unit sumber dari unit sumber pengimpor:

.. code-block:: solidity
    :caption: /project/lib/math.sol

    import "./util.sol" as util;    // source unit name: /project/lib/util.sol
    import "../token.sol" as token; // source unit name: /project/token.sol

.. code-block:: solidity
    :caption: lib/math.sol

    import "./util.sol" as util;    // source unit name: lib/util.sol
    import "../token.sol" as token; // source unit name: token.sol

.. note::

    Impor relatif **selalu** dimulai dengan ``./`` atau ``../`` jadi ``import "util.sol"``, tidak seperti
    ``import "./util.sol"``, adalah impor langsung.
    Sementara kedua jalur akan dianggap relatif dalam sistem file host, ``util.sol`` sebenarnya
    mutlak dalam VFS.

Mari kita definisikan *segmen jalur* sebagai bagian jalur yang tidak kosong yang tidak mengandung pemisah
dan dibatasi oleh dua pemisah jalur.
Pemisah adalah garis miring ke depan atau awal/akhir string.
Misalnya dalam ``./abc/..//`` ada tiga segmen jalur: ``.``, ``abc`` dan ``..``.

Kompilator menghitung nama unit sumber dari jalur impor dengan cara berikut:

1. Pertama sebuah prefix dihitung

    - Awalan diinisialisasi dengan nama unit sumber dari unit sumber pengimpor.
    - Segmen jalur terakhir dengan garis miring sebelumnya dihapus dari awalan.
    - Kemudian, bagian utama dari jalur impor yang dinormalisasi, hanya terdiri dari ``/`` dan karakter ``.``
      dipertimbangkan.
      Untuk setiap segmen ``..`` yang ditemukan di bagian ini, segmen jalur terakhir dengan garis miring sebelumnya adalah
      dihapus dari prefix.

2. Kemudian prefix ditambahkan ke import path yang dinormalisasi.
   Jika prefix non-empty, satu garis miring disisipkan di antaranya dan import path.

Penghapusan segmen jalur terakhir dengan garis miring sebelumnya dipahami
bekerja sebagai berikut:

1. Semua yang melewati garis miring terakhir dihapus (yaitu ``a/b//c.sol`` menjadi ``a/b//``).
2. Semua garis miring dihilangkan (yaitu ``a/b//`` menjadi ``a/b``).

Aturan normalisasinya sama dengan jalur UNIX, yaitu:

- Semua segmen ``.`` internal dihapus.
- Setiap segmen internal ``..`` mundur satu tingkat ke atas dalam hierarki.
- Beberapa garis miring tergencet menjadi satu.

Perhatikan bahwa normalisasi dilakukan hanya pada import path.
Nama unit sumber modul pengimporan yang digunakan untuk awalan tetap tidak dinormalisasi.
Ini memastikan bahwa bagian ``protokol://`` tidak berubah menjadi ``protokol:/`` jika file pengimpor
diidentifikasi dengan URL.

Jika jalur impor Anda sudah dinormalisasi, Anda dapat mengharapkan algoritme di atas menghasilkan hasil yang
sangat intuitif.
Berikut adalah beberapa contoh dari apa yang dapat Anda harapkan jika tidak:

.. code-block:: solidity
    :caption: lib/src/../contract.sol

    import "./util/./util.sol";         // source unit name: lib/src/../util/util.sol
    import "./util//util.sol";          // source unit name: lib/src/../util/util.sol
    import "../util/../array/util.sol"; // source unit name: lib/src/array/util.sol
    import "../.././../util.sol";       // source unit name: util.sol
    import "../../.././../util.sol";    // source unit name: util.sol

.. note::

    Penggunaan impor relatif yang berisi segmen ``..`` di depan tidak disarankan.
     Efek yang sama dapat dicapai dengan cara yang lebih andal dengan menggunakan impor langsung dengan
    :ref:`base path and include paths <base-and-include-paths>`.

.. index:: ! base path, ! --base-path, ! include paths, ! --include-path
.. _base-and-include-paths:

Base Path dan Include Paths
===========================

Base path dan *include path* mewakili direktori tempat Filesystem Host Loader akan memuat file.
Ketika nama unit sumber diteruskan ke loader, itu menambahkan base path ke sana dan melakukan
filesystem lookup.
Jika lookup tidak berhasil, hal yang sama dilakukan dengan semua direktori pada daftar include path.

Direkomendasikan untuk menyetel base path ke direktori root proyek Anda dan menggunakan include path
untuk menentukan lokasi tambahan yang mungkin berisi library tempat proyek Anda bergantung.
Ini memungkinkan Anda mengimpor dari library ini dengan cara yang seragam, di mana pun mereka berada
di filesystem relatif terhadap proyek Anda.
Misalnya, jika Anda menggunakan npm untuk menginstal paket dan kontrak Anda mengimpor
``@openzeppelin/contracts/utils/Strings.sol``, Anda dapat menggunakan opsi ini untuk
memberi tahu kompiler bahwa library dapat ditemukan di salah satu paket npm direktori:

.. code-block:: bash

    solc contract.sol \
        --base-path . \
        --include-path node_modules/ \
        --include-path /usr/local/lib/node_modules/

Kontrak Anda akan dikompilasi (dengan metadata yang sama persis) tidak peduli apakah Anda menginstal library
di direktori paket lokal atau global atau bahkan langsung di bawah root proyek Anda.

Secara default, base path adalah kosong, yang membuat nama unit sumber tidak berubah.
Ketika nama unit sumber adalah jalur relatif, ini menghasilkan file yang dicari di direktori
tempat kompiler dipanggil.
Ini juga satu-satunya nilai yang menghasilkan jalur absolut dalam nama unit sumber yang
sebenarnya ditafsirkan sebagai jalur absolut pada disk.
Jika jalur dasar itu sendiri relatif, itu ditafsirkan sebagai relatif terhadap direktori
kerja kompiler saat ini.

.. note::

    Include paths tidak boleh memiliki nilai kosong dan harus digunakan bersama dengan non-empty base path.

.. note::

    Include paths dan base path dapat tumpang tindih selama tidak membuat resolusi impor menjadi ambigu.
    Misalnya, Anda dapat menentukan direktori di dalam jalur dasar sebagai direktori yang disertakan atau memiliki
    include direktori yang merupakan subdirektori dari direktori include lainnya.
    Kompiler hanya akan mengeluarkan kesalahan jika nama unit sumber diteruskan ke Sistem File Host
    Loader mewakili jalur yang ada saat digabungkan dengan beberapa include path atau include path
    dan base path.

.. _cli-path-normalization-and-stripping:

CLI Path Normalization dan Stripping
------------------------------------

Pada baris perintah, kompiler berperilaku seperti yang Anda harapkan dari program lain:
ia menerima jalur dalam format asli platform dan relative paths relatif terhadap direktori
kerja saat ini.
Namun, nama unit sumber yang ditetapkan ke file yang jalurnya ditentukan pada baris perintah,
tidak boleh berubah hanya karena proyek sedang dikompilasi pada platform yang berbeda atau karena
compiler kebetulan telah dipanggil dari direktori yang berbeda.
Untuk mencapai ini, jalur ke file sumber yang berasal dari baris perintah harus dikonversi ke bentuk
canonical, dan, jika mungkin, dibuat relatif terhadap base path atau salah satu include path.

Aturan normalisasi adalah sebagai berikut:

- Jika suatu jalur relatif, jalur itu dibuat absolut dengan menambahkan direktori kerja saat ini ke dalamnya.
- Segmen internal ``.`` dan ``..`` diciutkan.
- Pemisah jalur khusus platform diganti dengan garis miring.
- Urutan beberapa pemisah jalur berurutan dijepit menjadi satu pemisah (kecuali
  mereka adalah garis miring utama dari `jalur UNC <https://en.wikipedia.org/wiki/Path_(computing)#UNC>`_).
- Jika jalur menyertakan nama root (misalnya huruf drive di Windows) dan root sama dengan
  root dari direktori kerja saat ini, root diganti dengan ``/``.
- Tautan simbolis di jalur **tidak** diselesaikan.

  - Satu-satunya pengecualian adalah jalur ke direktori kerja saat ini yang ditambahkan ke jalur relatif di
    proses menjadikannya mutlak.
    Pada beberapa platform, direktori kerja selalu dilaporkan dengan *symbolic links resolved*, jadi untuk
    konsistensi kompiler menyelesaikannya di mana-mana.

- Case asli jalur dipertahankan bahkan jika sistem file tidak peka huruf besar-kecil tetapi
  `case-preserving <https://en.wikipedia.org/wiki/Case_preservation>`_ dan case aktual pada
  disk berbeda.

.. note::

    Ada situasi di mana jalur tidak dapat dibuat platform-independen.
    Misalnya pada Windows, kompiler dapat menghindari penggunaan huruf drive dengan merujuk ke direktori
    root drive saat ini sebagai ``/`` tetapi huruf drive masih diperlukan untuk jalur yang mengarah
    ke drive lain.
    Anda dapat menghindari situasi seperti itu dengan memastikan bahwa semua file tersedia dalam satu
    pohon direktori pada drive yang sama.

Setelah normalisasi, kompiler mencoba membuat jalur file sumber menjadi relatif.
Ia mencoba base path terlebih dahulu dan kemudian include path dalam urutan yang diberikan.
Jika base path kosong atau tidak ditentukan, ini diperlakukan seolah-olah itu sama dengan jalur ke
direktori kerja saat ini (dengan semua tautan symbolic resolved).
Hasilnya diterima hanya jika jalur direktori yang dinormalisasi adalah awalan yang tepat dari jalur file
yang dinormalisasi.
Kalau tidak, jalur file tetap absolut.
Ini membuat konversi menjadi tidak ambigu dan memastikan bahwa jalur relatif tidak dimulai dengan ``../``.
Jalur file yang dihasilkan menjadi nama unit sumber.

.. note::

    Jalur relatif yang dihasilkan oleh *stripping* harus tetap unik di dalam base path dan include path.
    Misalnya kompiler akan mengeluarkan kesalahan untuk perintah berikut jika keduanya
    ``/project/contract.sol`` dan ``/lib/contract.sol`` ada:

    .. code-block:: bash

        solc /project/contract.sol --base-path /project --include-path /lib

.. note::

    Sebelum versi 0.8.8, CLI path stripping tidak dilakukan dan satu-satunya normalisasi yang diterapkan
    adalah konversi pemisah jalur.
    Saat bekerja dengan versi kompiler yang lebih lama, disarankan untuk memanggil kompiler dari
    jalur dasar dan hanya menggunakan jalur relatif pada baris perintah.

.. index:: ! allowed paths, ! --allow-paths, remapping; target
.. _allowed-paths:

Jalur yang Diizinkan
====================

Sebagai tindakan keamanan, Host Filesystem Loader akan menolak memuat file dari luar beberapa
lokasi yang dianggap aman secara default:

- Di luar mode JSON Standar:

  - Direktori yang berisi file input yang terdaftar pada baris perintah.
  - Direktori yang digunakan sebagai target :ref:`remapping <import-remapping>`.
    Jika target bukan direktori (yaitu tidak diakhiri dengan ``/``, ``/.`` atau ``/..``) direktori
    berisi target digunakan sebagai gantinya.
  - Base path dan include path.

- Dalam mode JSON Standar:

  - Base path dan include path.

Direktori tambahan dapat dimasukkan ke whitelist menggunakan opsi ``--allow-paths``.
Opsi menerima daftar jalur yang dipisahkan koma:

.. code-block:: bash

    cd /home/user/project/
    solc token/contract.sol \
        lib/util.sol=libs/util.sol \
        --base-path=token/ \
        --include-path=/lib/ \
        --allow-paths=../utils/,/tmp/libraries

Ketika kompiler dipanggil dengan perintah yang ditunjukkan di atas, Host Filesystem Loader akan mengizinkan
mengimpor file dari direktori berikut:

- ``/home/user/project/token/`` (karena ``token/`` berisi file input dan juga karena itu adalah
  base path),
- ``/lib/`` (karena ``/lib/`` adalah salah satu dari include path),
- ``/home/user/project/libs/`` (karena ``libs/`` adalah direktori yang berisi remapping target),
- ``/home/user/utils/`` (karena ``../utils/`` diteruskan ke ``--allow-paths``),
- ``/tmp/libraries/`` (karena ``/tmp/libraries`` diteruskan ke ``--allow-paths``),

.. note::

    Direktori kerja kompiler adalah salah satu jalur yang diizinkan secara default hanya jika itu
    kebetulan merupakan jalur dasar (atau jalur dasar tidak ditentukan atau memiliki nilai kosong).

.. note::

    Kompiler tidak memeriksa apakah jalur yang diizinkan benar-benar ada dan apakah itu direktori.
    Jalur yang tidak ada atau kosong diabaikan begitu saja.
    Jika jalur yang diizinkan cocok dengan file dan bukan direktori, file tersebut juga dianggap masuk whitelist.

.. note::

    Jalur yang diizinkan peka huruf besar-kecil bahkan jika sistem file tidak.
    Kasing harus sama persis dengan yang digunakan dalam impor Anda.
    Misalnya ``--allow-paths tokens`` tidak akan cocok dengan ``import "Tokens/IERC20.sol"``.

.. warning::

    File dan direktori hanya dapat dijangkau melalui tautan simbolik dari direktori yang diizinkan tidak
    masuk withelist secara otomatis.
    Misalnya jika ``token/contract.sol`` pada contoh di atas sebenarnya adalah symlink yang menunjuk ke
    ``/etc/passwd`` kompiler akan menolak untuk memuatnya kecuali ``/etc/`` adalah salah satu path yang
    juga diizinkan.

.. index:: ! remapping; import, ! import; remapping, ! remapping; context, ! remapping; prefix, ! remapping; target
.. _import-remapping:

Import Remapping
================

Import remapping memungkinkan Anda untuk mengarahkan impor ke lokasi berbeda di virtual filesystem.
Mekanismenya bekerja dengan mengubah terjemahan antara jalur impor dan nama unit sumber.
Misalnya Anda dapat mengatur remapping sehingga setiap impor dari direktori virtual
``github.com/ethereum/dapp-bin/library/`` akan dilihat sebagai impor dari ``dapp-bin/library/`` sebagai gantinya.

Anda dapat membatasi cakupan pemetaan ulang dengan menentukan *context*.
Ini memungkinkan pembuatan remapping yang hanya berlaku untuk impor yang terletak di library tertentu atau file tertentu.
Tanpa konteks, remapping diterapkan ke setiap impor yang cocok di semua file di virtual
filesystem.

Import remappings memiliki bentuk ``context:prefix=target``:

- ``context`` harus cocok dengan awal nama unit sumber file yang berisi impor.
- ``prefix`` harus cocok dengan awal nama unit sumber yang dihasilkan dari impor.
- ``target`` adalah nilai prefix diganti dengan.

Misalnya, jika Anda mengkloning https://github.com/ethereum/dapp-bin/ secara lokal ke ``/project/dapp-bin``
dan jalankan kompiler dengan:

.. code-block:: bash

    solc github.com/ethereum/dapp-bin/=dapp-bin/ --base-path /project source.sol

Anda dapat menggunakan yang berikut ini di file sumber Anda:

.. code-block:: solidity

    import "github.com/ethereum/dapp-bin/library/math.sol"; // source unit name: dapp-bin/library/math.sol

Kompilator akan mencari file dalam VFS di bawah ``dapp-bin/library/math.sol``.
Jika file tidak tersedia di sana, nama unit sumber akan diteruskan ke Sistem File Host
Loader, yang kemudian akan mencari di ``/project/dapp-bin/library/iterable_mapping.sol``.

.. warning::

    Informasi tentang remappings disimpan dalam metadata kontrak.
    Karena biner yang dihasilkan oleh kompiler memiliki hash metadata yang tertanam di dalamnya, setiap
    modifikasi pada remapping akan menghasilkan bytecode yang berbeda.

    Untuk alasan ini, Anda harus berhati-hati untuk tidak memasukkan informasi lokal apa pun dalam me-remapping target.
    Misalnya jika library Anda terletak di ``/home/user/packages/mymath/math.sol``, remapping
    seperti ``@math/=/home/user/packages/mymath/`` akan mengakibatkan direktori home Anda dimasukkan ke dalam
    metadata.
    Untuk dapat mereproduksi bytecode yang sama dengan remapping pada mesin yang berbeda, Anda
    perlu membuat ulang bagian dari struktur direktori lokal Anda di VFS dan (jika Anda mengandalkan
    Host Filesystem Loader) juga di sistem file host.

    Untuk menghindari struktur direktori lokal Anda tertanam dalam metadata, disarankan untuk
    menentukan direktori yang berisi library sebagai *include path* sebagai gantinya.
    Misalnya, dalam contoh di atas ``--include-path /home/user/packages/`` akan membiarkan Anda menggunakan
    impor dimulai dengan ``mymath/``.
    Tidak seperti remapping, opsi itu sendiri tidak akan membuat ``mymath`` muncul sebagai ``@math`` tetapi ini
    dapat dicapai dengan membuat tautan simbolik atau mengganti nama subdirektori paket.

Sebagai contoh yang lebih kompleks, misalkan Anda mengandalkan modul yang menggunakan dapp-bin versi lama yang
Anda memeriksa ke ``/project/dapp-bin_old``, lalu Anda dapat menjalankan:

.. code-block:: bash

    solc module1:github.com/ethereum/dapp-bin/=dapp-bin/ \
         module2:github.com/ethereum/dapp-bin/=dapp-bin_old/ \
         --base-path /project \
         source.sol

Ini berarti bahwa semua impor di ``module2`` mengarah ke versi lama tetapi mengimpor di ``module1``
mengarahkan ke versi baru.

Berikut adalah aturan terperinci yang mengatur perilaku remapping:

#. **Remappings hanya memengaruhi terjemahan antara jalur impor dan nama unit sumber.**

   Nama unit sumber yang ditambahkan ke VFS dengan cara lain tidak dapat di*remap*.
   Misalnya, jalur yang Anda tentukan pada baris perintah dan jalur di ``sources.urls`` di
   JSON Standar tidak terpengaruh.

   .. code-block:: bash

       solc /project/=/contracts/ /project/contract.sol # source unit name: /project/contract.sol

   Pada contoh di atas compiler akan memuat kode sumber dari ``/project/contract.sol`` dan
   meletakkannya di bawah nama unit sumber yang tepat di VFS, bukan di bawah ``/contract/contract.sol``.

#. **Context dan prefix harus cocok dengan nama unit sumber, bukan jalur impor.**

   - Ini berarti Anda tidak bisa remap ``./`` atau ``../`` secara langsung, karena diganti selama
     terjemahan ke nama unit sumber tetapi Anda dapat memetakan kembali bagian dari nama yang diganti
     dengan:

     .. code-block:: bash

         solc ./=a/ /project/=b/ /project/contract.sol # source unit name: /project/contract.sol

     .. code-block:: solidity
         :caption: /project/contract.sol

         import "./util.sol" as util; // source unit name: b/util.sol

   - Anda tidak dapat remap jalur dasar atau bagian lain dari jalur yang hanya ditambahkan secara internal oleh
     import callback:

     .. code-block:: bash

         solc /project/=/contracts/ /project/contract.sol --base-path /project # source unit name: contract.sol

     .. code-block:: solidity
         :caption: /project/contract.sol

         import "util.sol" as util; // source unit name: util.sol

#. **Target dimasukkan langsung ke nama unit sumber dan tidak harus berupa jalur yang valid.**

   - Itu bisa apa saja selama import callback dapat menanganinya.
     Dalam hal Host Filesystem Loader, ini juga termasuk jalur relatif.
     Saat menggunakan antarmuka JavaScript, Anda bahkan dapat menggunakan URL dan pengidentifikasi abstrak jika
     callback Anda dapat menanganinya.

   - Remapping terjadi setelah impor relatif telah diselesaikan menjadi nama unit sumber.
     Artinya, target yang dimulai dengan ``./`` dan ``../`` tidak memiliki arti khusus dan
     relatif terhadap jalur dasar daripada ke lokasi file sumber.

   - Target Remapping tidak di normalized jadi ``@root/=./a/b//`` akan me-remap ``@root/contract.sol``
     ke ``./a/b//contract.sol`` dan bukan ``a/b/contract.sol``.

   - Jika target tidak diakhiri dengan garis miring, kompiler tidak akan menambahkannya secara otomatis:

     .. code-block:: bash

         solc /project/=/contracts /project/contract.sol # source unit name: /project/contract.sol

     .. code-block:: solidity
         :caption: /project/contract.sol

         import "/project/util.sol" as util; // source unit name: /contractsutil.sol

#. **Context dan prefix adalah pola dan kecocokan harus tepat.**

   - ``a//b=c`` tidak akan cocok ``a/b``.
   - source unit names tidak di normalized jadi ``a/b=c`` tidak akan cocok ``a//b`` satu sama lain.
   - Bagian dari nama file dan direktori juga bisa cocok.
     ``/newProject/con:/new=old`` akan cocok ``/newProject/contract.sol`` dan me-remap menjadi
     ``oldProject/contract.sol``.

#. **Paling banyak satu remapping diterapkan untuk satu impor.**

   - Jika beberapa remapping cocok dengan nama sumber yang sama, prefix yang paling
     cocok dipilih.
   - Jika prefix identik, yang ditentukan terakhir menang.
   - Remapping jangan bekerja pada remapping yang lain. Sebagai contoh ``a=b b=c c=d`` tidak akan menghasilkan ``a``
     dipetakan ulang ke ``d``.

#. **Prefix tidak boleh kosong tetapi konteks dan target bersifat opsional.**

   - Jika ``target`` adalah string kosong, ``prefix`` dihapus begitu saja dari jalur impor.
   - ``context`` kosong berarti bahwa remapping berlaku untuk semua impor di semua unit sumber.

.. index:: Remix IDE, file://

Menggunakan URL dalam impor
===========================

Kebanyakan URL prefix seperti ``https://`` atau ``data://`` tidak memiliki arti khusus dalam jalur impor.
Satu-satunya pengecualian adalah ``file://`` yang dihilangkan dari nama unit sumber oleh Host Filesystem
Loader.

Ketika mengkompil secara lokal anda dapat menggunakan import remapping untuk mengganti protokol dan bagian domain dengan
jalur local:

.. code-block:: bash

    solc :https://github.com/ethereum/dapp-bin=/usr/local/dapp-bin contract.sol

Perhatikan awalan ``:``, yang diperlukan saat konteks remapping kosong.
Jika tidak, bagian ``https:`` akan ditafsirkan oleh kompiler sebagai konteksnya.
