Solidity
========

Solidity adalah bahasa tingkat tinggi berorientasi pada objek, untuk mengimplementasikan smart
kontrak. Smart kontrak adalah program yang mengatur perilaku akun
dalam lingkungan Ethereum.

Solidity adalah `bahasa curly-bracket <https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_.
yang dipengaruhi oleh C++, Python dan JavaScript, dan dirancang dan ditargetkan untuk Mesin Virtual Ethereum (EVM).
Anda dapat menemukan detail lebih lanjut tentang bahasa mana yang menginspirasi Solidity di
bagian :doc:`pengaruh bahasa <language-influences>`.

solidity diketik secara statis, mendukung *inheritance*, *libraries*, dan tipe-tipe
kompleks yang ditentukan pengguna di antara fitur-fitur lainnya.

Dengan Solidity, Anda dapat membuat kontrak yang dapat digunakan untuk misalnya *Voting*, *crowdfunding*, *blind auctions*,
dan dompet multi-signature.

Saat men-deploy kontrak, Anda harus menggunakan versi Solidity
terbaru yang dirilis. Selain dari kasus-kasus luar biasa, hanya versi terbaru yang menerima
`perbaikan keamanan <https://github.com/ethereum/solidity/security/policy#supported-versions>`_.
Selain itu, pembaharuan dan juga
fitur baru diperkenalkan secara teratur. Saat ini kami menggunakan
nomor versi 0.y.z `untuk menunjukkan laju perubahan yang cepat ini <https://semver.org/#spec-item-4>`_.

.. Warning::

  Solidity baru-baru ini merilis versi 0.8.x yang memperkenalkan banyak perubahan
  besar. Pastikan Anda membaca :doc:`daftar lengkap <080-breaking-changes>`.

Ide untuk meningkatkan Solidity atau dokumentasi ini selalu diterima,
baca :doc:`panduan kontributor <contributor>` kami untuk detail selengkapnya.

Mulai
-----

**1. Memahami Dasar-dasar smart Kontrak**

Jika Anda baru mengenal konsep smart kontrak, kami menyarankan Anda untuk memulai
dengan menggali bagian "Perkenalan smart Kontrak ", yang mencakup:

* :ref:`Contoh sederhana smart kontrak <simple-smart-contract>` ditulis dalam Solidity.
* :ref:`Dasar-dasar Blockchain <blockchain-basics>`.
* :ref:`Mesin Virtual Ethereum <the-ethereum-virtual-machine>`.

**2. Mengenal Solidity**

Setelah Anda memahami dasar-dasarnya, kami sarankan Anda membaca :doc:`"Contoh Solidity" <solidity-by-example>`
dan bagian “Deskripsi Bahasa” untuk memahami konsep inti bahasa solidity.

**3. Instal Solidity Compiler**

Ada berbagai cara untuk menginstal compiler Solidity,
cukup pilih opsi yang Anda inginkan dan ikuti langkah-langkah yang diuraikan di :ref:`halaman instalasi <installing-solidity>`.

.. Hint::
  Anda dapat mencoba contoh kode langsung di browser Anda dengan
  `Remix IDE <https://remix.ethereum.org>`_. Remix adalah IDE berbasis browser web
  yang memungkinkan Anda untuk menulis, menyebarkan, dan mengelola smart kontrak Solidity, tanpa
  perlu menginstal Solidity diperangkat anda.

.. Warning::
    Saat manusia menulis software, software tersebut dapat memiliki bug. Anda harus mengikuti
    *software development best-practices* yang sudah ada ketika menulis smart kontrak. Ini
    termasuk mereview kode, pengujian, audit, dan bukti kebenaran kode tersebut. Pengguna
    Smart kontrak terkadang lebih percaya pada kodenya daripada si pembuatnya,
    blockchains dan smart kontrak memiliki masalah uniknya sendiri yang
    harus diwaspadai, jadi sebelum mengerjakan kode, pastikan Anda membaca
    bagian :ref:`security_considerations`.

**4. Pelajari lebih lanjut**

Jika Anda ingin mempelajari lebih lanjut tentang membangun aplikasi terdesentralisasi di Ethereum,
`Sumber Daya Pengembang Ethereum <https://ethereum.org/en/developers/>`_
dapat membantu Anda dengan dokumentasi umum seputar Ethereum, dan berbagai pilihan tutorial,
alat dan kerangka pengembangan.

Jika Anda memiliki pertanyaan, Anda dapat mencari jawaban atau bertanya di
`Ethereum StackExchange <https://ethereum.stackexchange.com/>`_, atau
`saluran Gitter kami <https://gitter.im/ethereum/solidity/>`_.

.. _translations:

Terjemahan
----------

Relawan dari komunitas membantu menerjemahkan dokumentasi ini ke dalam beberapa bahasa.
Mereka memiliki berbagai tingkat kelengkapan dan  ke up-to-date-an. Versi
inggris digunakan sebagai referensi.

.. note::

   Kami baru-baru ini menyiapkan organisasi GitHub baru dan alur kerja terjemahan untuk membantu merampingkan
   upaya komunitas. Silakan merujuk ke `panduan terjemahan <https://github.com/solidity-docs/translation-guide>`_
   untuk informasi tentang bagaimana cara berkontribusi pada terjemahan ke depan.

* `French <https://solidity-fr.readthedocs.io>`_ (in progress)
* `Italian <https://github.com/damianoazzolini/solidity>`_ (in progress)
* `Japanese <https://solidity-jp.readthedocs.io>`_
* `Korean <https://solidity-kr.readthedocs.io>`_ (in progress)
* `Russian <https://github.com/ethereum/wiki/wiki/%5BRussian%5D-%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE-%D0%BF%D0%BE-Solidity>`_ (rather outdated)
* `Simplified Chinese <https://learnblockchain.cn/docs/solidity/>`_ (in progress)
* `Spanish <https://solidity-es.readthedocs.io>`_
* `Turkish <https://github.com/denizozzgur/Solidity_TR/blob/master/README.md>`_ (partial)
* `Indonesian <https://github.com/solidity-docs/id-indonesian>`_ (partial)

Daftar isi
==========

:ref:`Indeks Kata Kunci <genindex>`, :ref:`Halaman Pencarian <search>`

.. toctree::
   :maxdepth: 2
   :caption: Basics

   pengenalan-smart-kontrak.rst
   menginstal-solidity.rst
   contoh-solidity.rst

.. toctree::
   :maxdepth: 2
   :caption: Language Description

   layout-of-source-files.rst
   structure-of-a-contract.rst
   types.rst
   units-and-global-variables.rst
   control-structures.rst
   contracts.rst
   assembly.rst
   cheatsheet.rst
   grammar.rst

.. toctree::
   :maxdepth: 2
   :caption: Compiler

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Internals

   internals/layout_in_storage.rst
   internals/layout_in_memory.rst
   internals/layout_in_calldata.rst
   internals/variable_cleanup.rst
   internals/source_mappings.rst
   internals/optimizer.rst
   metadata.rst
   abi-spec.rst

.. toctree::
   :maxdepth: 2
   :caption: Additional Material

   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst
   natspec-format.rst
   security-considerations.rst
   smtchecker.rst
   resources.rst
   path-resolution.rst
   yul.rst
   style-guide.rst
   common-patterns.rst
   bugs.rst
   contributing.rst
   brand-guide.rst
   language-influences.rst
