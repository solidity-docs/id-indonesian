********************************
Tata Letak source files Solidity
********************************

Source files (*kode sumber*) dapat berisi sejumlah arbitrer
:ref:`contract definitions<contract_structure>`, import_ directives,
:ref:`pragma directives<pragma>` and
:ref:`struct<structs>`, :ref:`enum<enums>`, :ref:`function<functions>`, :ref:`error<errors>`
and :ref:`constant variable<constants>` definitions.

.. index:: ! license, spdx

Pengidentifikasi Lisensi SPDX
=======================++++++

Kepercayaan pada smart kontrak dapat dibangun dengan lebih baik jika kode sumbernya tersedia.
Karena menyediakan kode sumber selalu menyentuh masalah hukum yang berkaitan dengan hak cipta,
compiler Solidity mendorong penggunaan `SPDX license identifiers yang dapat dibaca mesin <https://spdx.org>`_.
Setiap kode sumber harus dimulai dengan komentar yang menunjukkan lisensinya:

``// SPDX-License-Identifier: MIT``

Kompiler tidak memvalidasi bahwa lisensi adalah bagian dari
`daftar yang diizinkan oleh SPDX <https://spdx.org/licenses/>`_, tapi
itu menyertakan string yang disediakan dalam :ref:`bytecode metadata <metadata>`.

Jika Anda tidak ingin menentukan lisensi atau jika kode sumbernya
bukan open-source, harap gunakan nilai khusus ``UNLICENSED``.

Memberikan komentar ini tentu saja tidak membebaskan Anda dari kewajiban lain
yang terkait dengan perizinan seperti harus menyebutkan
header lisensi tertentu di setiap file sumber atau
pemegang hak cipta asli.

Komentar dikenali oleh kompiler di mana saja di bagian file,
tetapi disarankan untuk meletakkannya di bagian atas file.

Informasi lebih lanjut tentang cara menggunakan pengidentifikasi lisensi SPDX
dapat ditemukan di `situs web SPDX <https://spdx.org/ids-how>`_.


.. index:: ! pragma

.. _pragma:

Pragma
=======

Kata kunci ``pragma`` digunakan untuk mengaktifkan fitur atau
pemeriksaan kompiler tertentu. Arahan pragma selalu lokal ke
file sumber, jadi Anda harus menambahkan pragma ke semua file
Anda jika Anda ingin mengaktifkannya di seluruh proyek Anda.
Jika Anda :ref:`import<import>` file lain, pragma dari file
tersebut *tidak* secara otomatis diterapkan ke file yang diimpor.

.. index:: ! pragma, version

.. _version_pragma:

Versi pragma
--------------

File sumber dapat (dan harus) dianotasi dengan versi pragma untuk menolak kompilasi dengan versi
kompiler masa depan yang mungkin memperkenalkan perubahan yang tidak kompatibel.
Kami mencoba untuk menjaga ini agar tetap minimum dan memperkenalkannya sedemikian rupa sehingga
perubahan dalam semantics juga memerlukan perubahan dalam syntax, tetapi ini tidak selalu memungkinkan.
karena itu, selalu merupakan ide yang baik untuk membaca changelog setidaknya untuk rilis yang berisi
perubahan yang melanggar. Rilis ini selalu memiliki versi dalam bentuk ``0.x.0`` atau ``x.0.0``.

penggunaan versi pragma adalah sebagai berikut: ``pragma solidity ^0.5.2;``

File sumber dengan baris di atas tidak dikompilasi dengan kompiler dibawah versi 0.5.2,
dan juga tidak bekerja pada compiler mulai dari versi 0.6.0 keatas (kondisi kedua ini
ditambahkan dengan menggunakan  tanda ``^``). Karena tidak akan ada perubahan yang mengganggu
hingga versi ``0.6.0``, Anda dapat yakin bahwa kode Anda dikompilasi dengan cara yang Anda inginkan.
Versi kompiler yang tepat tidak diperbaiki, sehingga rilis perbaikan bug masih dimungkinkan.

Dimungkinkan untuk menentukan aturan yang lebih kompleks untuk versi kompiler,
dengan menggunakan syntax yang sama yang digunakan `npm <https://docs.npmjs.com/cli/v6/using-npm/semver>`_.

.. note::
  Menggunakan versi pragma *tidak* mengubah versi kompilerr.
  juga *tidak* mengaktifkan atau menonaktifkan fitur sebuah kompiler.
  Ini hanya menginstruksikan kompiler untuk memeriksa apakah versinya
  cocok dengan yang dibutuhkan oleh pragma. Jika tidak cocok, akan
  terjadi kesalahan pada kompiler.

ABI Coder Pragma
----------------

Dengan menggunakan ``pragma abicoder v1`` atau ``pragma abicoder v2`` anda dapat
memilih antara dua implementasi ABI encoder dan decoder.

ABI coder terbaru (v2) mampu untuk meng*encode* dan decode nested arrays dan structs semaunya.
Ini mungkin menghasilkan kode yang kurang optimal  dan belum menerima pengujian sebanyak encoder lama,
tetapi dianggap non-eksperimental pada Solidity 0.6.0. Anda masih harus mengaktifkannya secara eksplisit
menggunakan ``pragma abicoder v2;``. Mulai dari Solidity 0.8.0 ini akan diaktifkan secara default,
ada pilihan untuk memilih coder lama dengan menggunakan ``pragma abicoder v1;``.

Kumpulan jenis yang didukung oleh encoder baru adalah strict superset dari yang didukung oleh versi yang lama.
Kontrak yang menggunakannya dapat berinteraksi dengan kontrak yang tidak menggunakannya tanpa batasan.
Kebalikannya hanya dimungkinkan selama kontrak non-``abicoder v2`` tidak mencoba melakukan panggilan yang
memerlukan jenis dekode yang hanya didukung oleh encoder baru. Kompiler dapat mendeteksi dan akan melaporkan kesalahan.
Dengan mengaktifkan ``abicoder v2`` untuk kontrak Anda sudah cukup untuk menghilangkan kesalahan.

.. note::

  Pragma ini berlaku untuk semua kode yang ditentukan dalam file tempat kode tersebut diaktifkan,
  terlepas dari di mana kode itu akan berakhir. Ini berarti bahwa kontrak yang file sumbernya
  dipilih untuk dikompilasi dengan ABI coder v1 masih dapat berisi kode yang menggunakan encoder baru
  dengan mewarisinya dari kontrak lain. Ini diperbolehkan jika tipe baru hanya digunakan secara internal
  dan bukan dalam tanda tangan fungsi eksternal.

.. note::
  Hingga Solidity 0.7.4, dimungkinkan untuk memilih ABI coder v2
  dengan menggunakan ``pragma experimental ABIEncoderV2``, tetapi itu tidak mungkin
  untuk secara eksplisit memilih coder v1 karena itu adalah default.

.. index:: ! pragma, experimental

.. _experimental_pragma:

Experimental Pragma
-------------------

Pragma kedua adalah pragma eksperimental. Ini dapat digunakan untuk mengaktifkan fitur
kompiler atau bahasa yang belum diaktifkan secara default.
Berikut Pragma experimental yang saat ini didukung:


ABIEncoderV2
~~~~~~~~~~~~

Karena ABI coder v2 tidak dianggap eksperimental lagi,
itu dapat dipilih melalui ``pragma abicoder v2`` (silakan lihat di atas)
mulai dari Solidity 0.7.4.

.. _smt_checker:

SMTChecker
~~~~~~~~~~

Komponen ini harus diaktifkan ketika compiler Solidity dibangun dan
oleh karena itu tidak tersedia di semua binari Solidity.
:ref:`build instruction<smt_solvers_build>` menjelaskan cara mengaktifkan opsi ini.
Ini diaktifkan untuk rilis PPA Ubuntu di sebagian besar versi,
tapi tidak untuk image Docker, binari Windows atau binari built statically-built Linux.
Ini dapat diaktifkan via `smtCallback <https://github.com/ethereum/solc-js#example-usage-with-smtsolver-callback>`_
jika anda SMT solver sudah terinstal dan menjalankan solc-js via node (bukan via browser).

Jika Anda menggunakan ``pragma eksperimental SMTTChecker;``, maka Anda mendapatkan tambahan
:ref:`peringatan keamanan<formal_verification>` yang diperoleh dengan menanyakan sebuah
SMT solver.
Komponen belum mendukung semua fitur bahasa Solidity dan kemungkinan mengeluarkan banyak peringatan.
Dalam hal ini melaporkan fitur yang tidak didukung, analisisnya mungkin tidak sepenuhnya baik.

.. index:: source file, ! import, module, source unit

.. _import:

Mengimpor Source Files lain
============================

Syntax and Semantics
--------------------

Solidity mendukung pernyataan impor untuk membantu memodulasi kode Anda yang
serupa dengan yang tersedia di JavaScript (mulai dari ES6).
Namun, Solidity tidak mendukung konsep `ekspor default <https://developer.mozilla.org/en-US/docs/web/javascript/reference/statements/export#Description>`_.

Di tingkat global, Anda dapat menggunakan pernyataan impor dengan form berikut:

.. code-block:: solidity

    import "filename";

Bagian ``filename`` disebut *import path*.
Pernyataan ini mengimpor semua simbol global dari "filename" (dan simbol yang diimpor di sana)
ke dalam lingkup global saat ini (berbeda dari ES6 tetapi backwards-compatible untuk Solidity).
Form tersebut tidak disarankan untuk digunakan, karena secara tak terduga mencemari namespace.
Jika Anda menambahkan item top-level baru di dalam "filename", item tersebut secara otomatis
muncul di semua file yang diimpor dari "filename". Lebih baik mengimpor simbol tertentu
secara eksplisit.

Contoh berikut membuat simbol global baru ``symbolName`` yang anggotanya
adalah semua simbol global dari ``"filename"``:

.. code-block:: solidity

    import * as symbolName from "filename";

yang menghasilkan semua simbol global yang tersedia dalam format ``symbolName.symbol``.

A variant of this syntax that is not part of ES6, but possibly useful is:

.. code-block:: solidity

  import "filename" as symbolName;

yang setara dengan ``import * sebagai nama simbol dari "filename";``.

Jika terjadi tabrakan penamaan,Anda dapat mengganti nama simbol saat mengimpor. Sebagai contoh,
kode di bawah ini membuat simbol global baru ``alias`` dan ``symbol2`` yang merujuk
``symbol1`` dan ``symbol2`` masing-masing dari dalam ``"filename"``.

.. code-block:: solidity

    import {symbol1 as alias, symbol2} from "filename";

.. index:: virtual filesystem, source unit name, import; path, filesystem path, import callback, Remix IDE

Import Path
------------

Agar dapat mendukung build yang dapat direproduksi di semua platform, kompiler Solidity
harus mengabstraksi detail sistem file tempat file sumber disimpan.
Untuk alasan ini import path tidak merujuk langsung ke file di host filesystem.
Sebaliknya kompilerr memelihara database internal (*virtual filesystem* atau *VFS* singkatnya)
di mana setiap unit sumber diberi *source unit name* unik yang merupakan pengidentifikasi buram dan tidak terstruktur.
Import path yang ditentukan dalam pernyataan import diterjemahkan ke dalam nama unit sumber dan digunakan untuk
menemukan unit sumber yang sesuai dalam database ini.

Dengan menggunakan :ref:`Standard JSON <compiler-api>` API, dimungkinkan untuk secara langsung memberikan
nama dan konten semua file sumber sebagai bagian dari input kompiler.
Dalam hal ini nama unit sumber benar-benar arbitrer.
Namun, jika Anda ingin kompilerr menemukan dan memuat kode sumber secara otomatis ke dalam VFS,
nama unit sumber Anda perlu disusun sedemikian rupa sehingga memungkinkan
:ref:`import callback <import-callback>` untuk mencari mereka.
Saat menggunakan kompiler command-line, callback impor default hanya mendukung pemuatan
kode sumber dari filesystem host, yang berarti bahwa nama unit sumber Anda harus berupa jalur.
Beberapa environment menyediakan callback khusus yang lebih fleksibel.
Misalnya `Remix IDE <https://remix.ethereum.org/>`_ menyediakan yang memungkinkan Anda
`mengimpor file dari HTTP, IPFS, dan URL Swarm atau merujuk langsung ke paket di
registri NPM <https://remix- ide.readthedocs.io/en/latest/import.html>`_.

Untuk deskripsi lengkap tentang virtual filesysytem dan logika resolusi jalur yang digunakan
oleh kompilerr, lihat :ref:`Path Resolution <path-resolution>`.

.. index:: ! comment, natspec

Komentar (Comments)
===================

Single-line comments (``//``) dan multi-line comments (``/*...*/``) dimungkinkan.

.. code-block:: solidity

    // This is a single-line comment.

    /*
    This is a
    multi-line comment.
    */

.. note::
  Sebuah single-line comment diakhiri oleh terminator baris unicode apa pun
  (LF, VF, FF, CR, NEL, LS or PS) di encoding UTF-8. Terminator masih menjadi bagian dari
  kode sumber setelah comment, jadi jika itu bukan simbol ASCII
  ( NEL, LS dan PS), itu akan menyebabkan kesalahan parser.

Selain itu, ada jenis komentar lain yang disebut komentar NatSpec,
yang dirinci dalam :ref:`style guide<style_guide_natspec>`. Mereka ditulis dengan
garis miring tiga (``///``) atau blok asterisk ganda (``/** ... */``) dan
mereka harus digunakan langsung di atas deklarasi atau pernyataan fungsi.
