.. _natspec:

##############
NatSpec Format
##############

Kontrak solidity dapat menggunakan bentuk komentar khusus untuk menyediakan dokumentasi
yang kaya untuk fungsi, variabel return, dan lainnya. Bentuk khusus ini diberi nama
Ethereum Natural Language Specification Format (NatSpec).

.. note::

  NatSpec terinspirasi oleh `Doxygen <https://en.wikipedia.org/wiki/Doxygen>`_.
  Meskipun menggunakan komentar dan tag bergaya Doxygen, tidak ada niat untuk menjaga
  kompatibilitas ketat dengan Doxygen. Harap periksa dengan cermat tag yang didukung yang
  tercantum di bawah ini.

Dokumentasi ini disegmentasikan ke dalam pesan yang berfokus pada pengembang dan pesan
yang ditujukan kepada pengguna akhir. Pesan-pesan ini dapat ditampilkan kepada pengguna
akhir (manusia) pada saat mereka akan berinteraksi dengan kontrak (yaitu menandatangani
transaksi).

Direkomendasikan agar kontrak Solidity dijelaskan sepenuhnya menggunakan NatSpec untuk
semua antarmuka publik (semua yang ada di ABI).

NatSpec menyertakan pemformatan untuk komentar yang akan digunakan oleh pembuat smart kontrak,
dan yang dipahami oleh kompiler Solidity. Juga dirinci di bawah ini adalah output dari kompiler
Solidity, yang mengekstrak komentar-komentar ini ke dalam format yang dapat dibaca mesin.

NatSpec juga dapat menyertakan anotasi yang digunakan oleh alat pihak ketiga. Ini kemungkinan besar
dicapai melalui tag ``@custom:<name>``, dan kasus penggunaan yang baik adalah alat analisis dan verifikasi.

.. _header-doc-example:

Contoh Dokumentasi
==================

Dokumentasi disisipkan di atas masing-masing ``contract``, ``interface``,
``function``, dan ``event`` menggunakn format notasi Doxygen.
``public`` state variable setara dengan ``function``
untuk keperluan NatSpec.

-  Untuk Solidity Anda dapat memilih ``///`` untuk single atau multi-line
   komentar, atau ``/**`` dan diakhiri dengan ``*/``.

-  Untuk Vyper, gunakan ``"""`` menjorok ke konten dalam dengan
   komentar kosong. Lihat `Vyper
   documentation <https://vyper.readthedocs.io/en/latest/natspec.html>`__.

Contoh berikut menunjukkan kontrak dan fungsi menggunakan semua tag yang tersedia.

.. note::

  Kompiler Solidity hanya menginterpretasikan tag jika tag eksternal atau
  publik. Anda dipersilakan untuk menggunakan komentar serupa untuk internal Anda dan
  fungsi pribadi, tetapi itu tidak akan diuraikan.

  Ini mungkin berubah di masa depan.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.2 < 0.9.0;

    /// @title A simulator for trees
    /// @author Larry A. Gardner
    /// @notice You can use this contract for only the most basic simulation
    /// @dev All function calls are currently implemented without side effects
    /// @custom:experimental This is an experimental contract.
    contract Tree {
        /// @notice Calculate tree age in years, rounded up, for live trees
        /// @dev The Alexandr N. Tetearing algorithm could increase precision
        /// @param rings The number of rings from dendrochronological sample
        /// @return Age in years, rounded up for partial years
        function age(uint256 rings) external virtual pure returns (uint256) {
            return rings + 1;
        }

        /// @notice Returns the amount of leaves the tree has.
        /// @dev Returns only a fixed number.
        function leaves() external virtual pure returns(uint256) {
            return 2;
        }
    }

    contract Plant {
        function leaves() external virtual pure returns(uint256) {
            return 3;
        }
    }

    contract KumquatTree is Tree, Plant {
        function age(uint256 rings) external override pure returns (uint256) {
            return rings + 2;
        }

        /// Return the amount of leaves that this specific kind of tree has
        /// @inheritdoc Tree
        function leaves() external override(Tree, Plant) pure returns(uint256) {
            return 3;
        }
    }

.. _header-tags:

Tags
====

Semua tag bersifat opsional. Tabel berikut menjelaskan tujuan masing-masing
Tag NatSpec dan di mana ia dapat digunakan. Sebagai kasus khusus, jika tidak ada tag adalah
digunakan maka kompiler Solidity akan menginterpretasikan komentar ``///`` atau ``/**``
dengan cara yang sama seperti jika diberi tag dengan ``@notice``.

=============== ====================================================================================== =============================
Tag                                                                                                    Context
=============== ====================================================================================== =============================
``@title``      Judul yang harus menggambarkan kontrak/interface                                       contract, library, interface
``@author``     Nama penulis                                                                           contract, library, interface
``@notice``     Jelaskan kepada pengguna akhir apa fungsinya                                           contract, library, interface, function, public state variable, event
``@dev``        Jelaskan kepada pengembang detail tambahan apa pun                                     contract, library, interface, function, state variable, event
``@param``      Mendokumentasikan parameter seperti di Doxygen (harus diikuti dengan nama parameter)   function, event
``@return``     Dokumentasikan variabel return dari fungsi kontrak                                     function, public state variable
``@inheritdoc`` Salin semua tag yang hilang dari fungsi dasar (harus diikuti dengan nama kontrak)      function, public state variable
``@custom:...`` Tag khusus, semantik ditentukan oleh aplikasi                                          everywhere
=============== ====================================================================================== =============================

Jika fungsi Anda mengembalikan banyak nilai, seperti ``(int quotient, int rest)``
kemudian gunakan beberapa pernyataan ``@return`` dalam format yang sama dengan pernyataan ``@param``.

Tag khusus dimulai dengan ``@kustom:`` dan harus diikuti oleh satu atau beberapa huruf kecil atau tanda hubung.
Namun, itu tidak dapat dimulai dengan tanda hubung. Mereka dapat digunakan di mana saja dan merupakan bagian dari dokumentasi pengembang.

.. _header-dynamic:

Dynamic expressions
-------------------

Kompiler Solidity akan melewati dokumentasi NatSpec dari kode sumber Solidity Anda ke output JSON
seperti yang dijelaskan dalam panduan ini. Konsumen dari output JSON ini, misalnya perangkat lunak
klien pengguna akhir, dapat menyajikan ini kepada pengguna akhir secara langsung atau mungkin menerapkan beberapa pra-pemrosesan.

Misalnya, beberapa perangkat lunak klien akan merender:

.. code:: Solidity

   /// @notice This function will multiply `a` by 7

kepada pengguna akhir sebagai:

.. code:: text

    This function will multiply 10 by 7

jika suatu fungsi dipanggil dan input ``a`` diberi nilai 10.

Menentukan ekspresi dinamis ini berada di luar cakupan dokumentasi
Solidity dan Anda dapat membaca lebih lanjut di
`the radspec project <https://github.com/aragon/radspec>`__.

.. _header-inheritance:

Inheritance Notes
-----------------

Fungsi tanpa NatSpec akan secara otomatis mewarisi dokumentas
fungsi dasarnya. Pengecualian untuk ini adalah:

* Ketika nama parameter berbeda.
* Bila ada lebih dari satu fungsi dasar.
* Ketika ada tag ``@inheritdoc`` eksplisit yang menentukan kontrak mana yang harus digunakan untuk mewarisi.

.. _header-output:

Dokumentasi Output
==================

Ketika diurai oleh compiler, dokumentasi seperti contoh di atas akan menghasilkan
dua file JSON yang berbeda. Satu dimaksudkan untuk dikonsumsi oleh pengguna akhir
sebagai pemberitahuan ketika suatu fungsi dijalankan dan yang lainnya untuk digunakan
oleh pengembang.

Jika kontrak di atas disimpan sebagai ``ex1.sol`` maka Anda dapat membuat
dokumentasi menggunakan:

.. code::

   solc --userdoc --devdoc ex1.sol

Dan outputnya ada di bawah.

.. note::
    Memulai Solidity versi 0.6.11, output NatSpec juga berisi bidang ``version`` dan ``kind``.
    Saat ini ``version`` disetel ke ``1`` dan ``kind`` harus salah satu dari ``user`` atau ``dev``.
    Di masa depan, ada kemungkinan bahwa versi baru akan diperkenalkan, tidak lagi menggunakan versi lama.

.. _header-user-doc:

Dokumentasi User
----------------

Dokumentasi di atas akan menghasilkan file JSON dokumentasi pengguna
berikut sebagai output:

.. code::

    {
      "version" : 1,
      "kind" : "user",
      "methods" :
      {
        "age(uint256)" :
        {
          "notice" : "Calculate tree age in years, rounded up, for live trees"
        }
      },
      "notice" : "You can use this contract for only the most basic simulation"
    }

Perhatikan bahwa kunci untuk menemukan metode adalah fungsi
tanda tangan kanonik sebagaimana didefinisikan dalam :ref:`Contract
ABI <abi_function_selector>` dan bukan hanya fungsi
nama.

.. _header-developer-doc:

Dokumentasi Developer
---------------------

Terlepas dari file dokumentasi pengguna, dokumentasi pengembang JSON
file juga harus diproduksi dan akan terlihat seperti ini:

.. code::

    {
      "version" : 1,
      "kind" : "dev",
      "author" : "Larry A. Gardner",
      "details" : "All function calls are currently implemented without side effects",
      "custom:experimental" : "This is an experimental contract.",
      "methods" :
      {
        "age(uint256)" :
        {
          "details" : "The Alexandr N. Tetearing algorithm could increase precision",
          "params" :
          {
            "rings" : "The number of rings from dendrochronological sample"
          },
          "return" : "age in years, rounded up for partial years"
        }
      },
      "title" : "A simulator for trees"
    }
