#############
Berkontribusi
#############

<<<<<<< HEAD
Bantuan selalu diterima dan ada banyak pilihan bagaimana Anda dapat berkontribusi pada Solidity.
=======
Help is always welcome and there are plenty of options to contribute to Solidity.
>>>>>>> english/develop

Secara khusus, kami menghargai dukungan di bidang-bidang berikut:

<<<<<<< HEAD
* Melaporkan masalah.
* Memperbaiki dan menanggapi `Solidity's GitHub issues
  <https://github.com/ethereum/solidity/issues>`_, terutama yang ditandai sebagai
  `"good first issue" <https://github.com/ethereum/solidity/labels/good%20first%20issue>`_ yang mana
   dimaksudkan sebagai masalah pengantar untuk kontributor eksternal.
* Memperbaiki dokumentasi.
* Menerjemahkan dokumentasi ke lebih banyak bahasa.
* Menanggapi pertanyaan dari pengguna lain di `StackExchange
  <https://ethereum.stackexchange.com>`_ dan `Solidity Gitter Chat
=======
* Reporting issues.
* Fixing and responding to `Solidity's GitHub issues
  <https://github.com/ethereum/solidity/issues>`_, especially those tagged as
  `"good first issue" <https://github.com/ethereum/solidity/labels/good%20first%20issue>`_ which are
  meant as introductory issues for external contributors.
* Improving the documentation.
* `Translating <https://github.com/solidity-docs>`_ the documentation into more languages.
* Responding to questions from other users on `StackExchange
  <https://ethereum.stackexchange.com>`_ and the `Solidity Gitter Chat
>>>>>>> english/develop
  <https://gitter.im/ethereum/solidity>`_.
* Terlibat dalam proses desain bahasa dengan mengusulkan perubahan bahasa atau fitur baru di `Forum Solidity <https://forum.soliditylang.org/>`_ dan memberikan masukan.

Untuk memulai, Anda dapat mencoba :ref:`building-from-source` untuk membiasakan
diri Anda dengan komponen Solidity dan proses build. Juga, mungkin
berguna untuk menjadi ahli dalam menulis kontrak pintar di Solidity.

<<<<<<< HEAD
Harap diperhatikan bahwa proyek ini dirilis dengan `Kode Etik Kontributor <https://raw.githubusercontent.com/ethereum/solidity/develop/CODE_OF_CONDUCT.md>`_. Dengan berpartisipasi dalam proyek ini - dalam masalah, permintaan tarik, atau saluran Gitter - Anda setuju untuk mematuhi persyaratannya.
=======
Please note that this project is released with a `Contributor Code of Conduct <https://raw.githubusercontent.com/ethereum/solidity/develop/CODE_OF_CONDUCT.md>`_. By participating in this project — in the issues, pull requests, or Gitter channels — you agree to abide by its terms.
>>>>>>> english/develop

Panggilan Tim
=============

<<<<<<< HEAD
Jika Anda memiliki masalah atau menarik permintaan untuk didiskusikan, atau tertarik
untuk mendengar apa yang sedang dikerjakan oleh tim dan kontributor, Anda dapat bergabung
dengan panggilan tim publik kami:

- Senin pukul 15:00 CET/CEST.
- Rabu pukul 14:00 CET/CEST.

Kedua panggilan berlangsung di `Jitsi <https://meet.komputing.org/solidity>`_.
=======
If you have issues or pull requests to discuss, or are interested in hearing what
the team and contributors are working on, you can join our public team call:

- Wednesdays at 3PM CET/CEST.

The call takes place on `Jitsi <https://meet.ethereum.org/solidity>`_.
>>>>>>> english/develop

Cara Melaporkan Masalah
=======================

Untuk melaporkan masalah, silakan gunakan
`GitHub issue tracker <https://github.com/ethereum/solidity/issues>`_. Saat
melaporkan masalah, harap sebutkan detail berikut:

<<<<<<< HEAD
* Versi solidity.
* Kode sumber (jika ada).
* Sistem operasi.
* Langkah-langkah untuk mereproduksi masalah.
* Perilaku aktual vs. yang diharapkan.

Mengurangi kode sumber yang menyebabkan masalah seminimal mungkin selalu
sangat membantu dan terkadang bahkan memperjelas kesalahpahaman.
=======
* Solidity version.
* Source code (if applicable).
* Operating system.
* Steps to reproduce the issue.
* Actual vs. expected behavior.

Reducing the source code that caused the issue to a bare minimum is always
very helpful, and sometimes even clarifies a misunderstanding.

For technical discussions about language design, a post in the
`Solidity forum <https://forum.soliditylang.org/>`_ is the correct place (see :ref:`solidity_language_design`).
>>>>>>> english/develop

Workflow untuk Pull Requests
============================

Untuk berkontribusi, harap keluar dari cabang ``develop`` dan buat
perubahan di sana. Pesan komit Anda harus merinci *mengapa* Anda melakukan perubahan
selain *apa* yang Anda lakukan (kecuali itu adalah perubahan kecil).

Jika Anda perlu menarik perubahan apa pun dari ``develop`` setelah membuat fork (untuk
misalnya, untuk menyelesaikan potensi konflik penggabungan), harap hindari menggunakan ``git merge``
dan sebagai gantinya, ``git rebase`` cabang Anda. Ini akan membantu kami meninjau perubahan Anda
lebih mudah.

Selain itu, jika Anda menulis fitur baru, pastikan Anda menambahkan kasus uji yang sesuai
di bawah ``test/`` (lihat di bawah).

<<<<<<< HEAD
Namun, jika Anda membuat perubahan yang lebih besar, silakan berkonsultasi dengan `Solidity Development Gitter channel
<https://gitter.im/ethereum/solidity-dev>`_ (berbeda dari yang disebutkan di atas, yang ini adalah
berfokus pada kompiler dan pengembangan bahasa daripada penggunaan bahasa) terlebih dahulu.
=======
However, if you are making a larger change, please consult with the `Solidity Development Gitter channel
<https://gitter.im/ethereum/solidity-dev>`_ (different from the one mentioned above — this one is
focused on compiler and language development instead of language usage) first.
>>>>>>> english/develop

Fitur baru dan perbaikan bug harus ditambahkan ke file ``Changelog.md``: harap
ikuti gaya entri sebelumnya, jika berlaku.

Terakhir, pastikan Anda menghormati `gaya pengkodean
<https://github.com/ethereum/solidity/blob/develop/CODING_STYLE.md>`_
untuk proyek ini. Juga, meskipun kami melakukan pengujian CI, harap uji kode Anda dan
pastikan itu dibangun secara lokal sebelum mengirimkan permintaan pull.

<<<<<<< HEAD
Terima kasih untuk bantuannya!
=======
We highly recommend going through our `review checklist <https://github.com/ethereum/solidity/blob/develop/ReviewChecklist.md>`_ before submitting the pull request.
We thoroughly review every PR and will help you get it right, but there are many common problems that can be easily avoided, making the review much smoother.

Thank you for your help!
>>>>>>> english/develop

Menjalankan Tes Compiler
==========================

Prasyarat
-------------

<<<<<<< HEAD
Untuk menjalankan semua pengujian kompiler, Anda mungkin ingin menginstal beberapa dependensi secara
opsional (`evmone <https://github.com/ethereum/evmone/releases>`_,
`libz3 <https://github.com/Z3Prover/z3>`_, dan
`libhera <https://github.com/ewasm/hera>`_).

Di macOS, beberapa skrip pengujian mengharapkan GNU coreutils diinstal.
Ini paling mudah dilakukan dengan menggunakan Homebrew: ``brew install coreutils``.

Menjalankan Tes
=======
For running all compiler tests you may want to optionally install a few
dependencies (`evmone <https://github.com/ethereum/evmone/releases>`_,
`libz3 <https://github.com/Z3Prover/z3>`_).

On macOS systems, some of the testing scripts expect GNU coreutils to be installed.
This can be easiest accomplished using Homebrew: ``brew install coreutils``.

On Windows systems, make sure that you have a privilege to create symlinks,
otherwise several tests may fail.
Administrators should have that privilege, but you may also
`grant it to other users <https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/create-symbolic-links#policy-management>`_
or
`enable Developer Mode <https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development>`_.

Running the Tests
>>>>>>> english/develop
-----------------

Solidity mencakup berbagai jenis tes, kebanyakan dibundel ke dalam aplikasi ``soltest``
`Boost C++ Test Framework <https://www.boost.org/doc/libs/release/libs/test/doc/html/index.html>`_.
Jalankan ``build/test/soltest`` atau wrapper ``scripts/soltest.sh`` cukup untuk sebagian besar perubahan.

<<<<<<< HEAD
Skrip ``./scripts/tests.sh`` menjalankan sebagian besar pengujian Solidity secara otomatis,
termasuk yang dibundel ke dalam `Boost C++ Test Framework <https://www.boost.org/doc/libs/release/libs/test/doc/html/index.html>`_
aplikasi ``soltest`` (atau pembungkusnya ``scripts/soltest.sh``), serta pengujian baris perintah dan
tes kompilasi.
=======
The ``./scripts/tests.sh`` script executes most Solidity tests automatically,
including those bundled into the `Boost C++ Test Framework <https://www.boost.org/doc/libs/release/libs/test/doc/html/index.html>`_
application ``soltest`` (or its wrapper ``scripts/soltest.sh``), as well as command-line tests and
compilation tests.
>>>>>>> english/develop

Sistem pengujian secara otomatis mencoba menemukan lokasi
`evmone <https://github.com/ethereum/evmone/releases>`_ untuk menjalankan tes semantik.

<<<<<<< HEAD
Library ``evmone`` harus ditempatkan di direktori ``deps`` atau ``deps/lib`` relatif terhadap
direktori kerja saat ini, ke induknya atau induknya. Atau lokasi eksplisit
untuk objek bersama ``evmone`` dapat ditentukan melalui environment variable ``ETH_EVMONE``.
=======
The ``evmone`` library must be located in the ``deps`` or ``deps/lib`` directory relative to the
current working directory, to its parent or its parent's parent. Alternatively, an explicit location
for the ``evmone`` shared object can be specified via the ``ETH_EVMONE`` environment variable.
>>>>>>> english/develop

``evmone`` diperlukan terutama untuk menjalankan tes semantik dan gas.
Jika Anda belum menginstalnya, Anda dapat melewati pengujian ini dengan meneruskan flag ``--no-semantic-tests``
ke ``scripts/soltest.sh``.

<<<<<<< HEAD
Menjalankan tes Ewasm dinonaktifkan secara default dan dapat diaktifkan secara eksplisit
melalui ``./scripts/soltest.sh --ewasm`` dan membutuhkan `hera <https://github.com/ewasm/hera>`_
untuk dapat ditemukan oleh ``soltest``.
Mekanisme untuk menemukan library ``hera`` sama seperti untuk ``evmone``, kecuali
variabel untuk menentukan lokasi eksplisit disebut ``ETH_HERA``.

Library ``evmone`` dan ``hera`` harus diakhiri dengan nama file
ekstensi ``.so`` di Linux, ``.dll`` di sistem Windows dan ``.dylib`` di macOS.
=======
The ``evmone`` library should both end with the file name
extension ``.so`` on Linux, ``.dll`` on Windows systems and ``.dylib`` on macOS.
>>>>>>> english/develop

Untuk menjalankan pengujian SMT, library ``libz3`` harus diinstal dan dapat ditemukan
oleh ``cmake`` selama tahap konfigurasi kompiler.

Jika library ``libz3`` tidak diinstal pada sistem Anda, Anda harus menonaktifkan
Tes SMT dengan mengekspor ``SMT_FLAGS=--no-smt`` sebelum menjalankan ``./scripts/tests.sh`` atau
menjalankan ``./scripts/soltest.sh --no-smt``.
Pengujian ini adalah ``libsolidity/smtCheckerTests`` dan ``libsolidity/smtCheckerTestsJSON``.

.. note::

    Untuk mendapatkan daftar semua pengujian unit yang dijalankan oleh Soltest, jalankan ``./build/test/soltest --list_content=HRF``.

Untuk hasil yang lebih cepat, Anda dapat menjalankan subset dari, atau tes tertentu.

Untuk menjalankan subset pengujian, Anda dapat menggunakan filter:
``./scripts/soltest.sh -t TestSuite/TestName``,
dimana ``TestName`` bisa menjadi wildcard ``*``.

Atau, misalnya, untuk menjalankan semua tes untuk yul disambiguator:
``./scripts/soltest.sh -t "yulOptimizerTests/disambiguator/*" --no-smt``.

``./build/test/soltest --help`` memiliki bantuan ekstensif pada semua opsi yang tersedia.

Lihat terutama:

- `show_progress (-p) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/show_progress.html>`_ to show test completion,
- `run_test (-t) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/run_test.html>`_ to run specific tests cases, and
- `report-level (-r) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/report_level.html>`_ give a more detailed report.

.. note::

    Mereka yang bekerja di lingkungan Windows yang ingin menjalankan set dasar di atas
    tanpa libz3. Menggunakan Git Bash, Anda menggunakan: ``./build/test/Release/soltest.exe -- --no-smt``.
    Jika Anda menjalankan ini di Command Prompt biasa, gunakan ``.\build\test\Release\soltest.exe -- --no-smt``.

<<<<<<< HEAD
Jika Anda ingin men-debug menggunakan GDB, pastikan Anda membangun yang berbeda dari "biasa".
Misalnya, Anda dapat menjalankan perintah berikut di folder ``build`` Anda:
=======
If you want to debug using GDB, make sure you build differently than the "usual".
For example, you could run the following command in your ``build`` folder:

>>>>>>> english/develop
.. code-block:: bash

   cmake -DCMAKE_BUILD_TYPE=Debug ..
   make

Ini menciptakan simbol sehingga saat Anda men-debug pengujian menggunakan flag ``--debug``,
Anda memiliki akses ke fungsi dan variabel di mana Anda dapat memecahkan atau mencetaknya.

CI menjalankan tes tambahan (termasuk ``solc-js`` dan menguji frameworks Solidity
pihak ketiga) yang memerlukan kompilasi target Emscripten.

Menulis dan Menjalankan Tes Sintaks
-----------------------------------

Tes sintaks memeriksa bahwa kompiler menghasilkan pesan kesalahan yang benar untuk kode yang tidak valid
dan menerima kode yang valid dengan benar.
Mereka disimpan dalam file individual di dalam folder ``tests/libsolidity/syntaxTests``.
File-file ini harus berisi anotasi, yang menyatakan hasil yang diharapkan dari pengujian masing-masing.
Test suite mengkompilasi dan memeriksanya terhadap ekspektasi yang diberikan.

Misalnya: ``./test/libsolidity/syntaxTests/double_stateVariable_declaration.sol``

.. code-block:: solidity

    contract test {
        uint256 variable;
        uint128 variable;
    }
    // ----
    // DeclarationError: (36-52): Identifier already declared.

Pengujian sintaks harus berisi setidaknya kontrak yang sedang diuji itu sendiri, diikuti oleh pemisah ``// ----``. Komentar yang mengikuti pemisah digunakan untuk menggambarkan
kesalahan atau peringatan kompiler yang diharapkan. Rentang angka menunjukkan lokasi di sumber tempat kesalahan terjadi.
Jika Anda ingin kontrak dikompilasi tanpa kesalahan atau peringatan, Anda dapat pergi
keluar pemisah dan komentar yang mengikutinya.

Dalam contoh di atas, variabel state ``variabel`` dideklarasikan dua kali, dimana itu tidak diperbolehkan. Ini menghasilkan ``DeclarationError`` yang menyatakan bahwa pengidentifikasi sudah dideklarasikan.

Alat ``isoltest`` digunakan untuk pengujian ini dan Anda dapat menemukannya di ``./build/test/tools/``. Ini adalah alat interaktif yang memungkinkan
mengedit kontrak yang gagal menggunakan editor teks pilihan Anda. Mari kita coba menghentikan pengujian ini dengan menghapus deklarasi kedua dari ``variabel``:

.. code-block:: solidity

    contract test {
        uint256 variable;
    }
    // ----
    // DeclarationError: (36-52): Identifier already declared.

Menjalankan ``./build/test/tools/isoltest`` lagi menghasilkan kegagalan pengujian:

.. code-block:: text

    syntaxTests/double_stateVariable_declaration.sol: FAIL
        Contract:
            contract test {
                uint256 variable;
            }

        Expected result:
            DeclarationError: (36-52): Identifier already declared.
        Obtained result:
            Success


``isoltest`` mencetak hasil yang diharapkan di sebelah hasil yang diperoleh, dan juga
menyediakan cara untuk mengedit, memperbarui atau melewati file kontrak saat ini, atau keluar dari aplikasi.

Ini menawarkan beberapa opsi untuk tes yang gagal:

<<<<<<< HEAD
- ``edit``: ``isoltest`` mencoba membuka kontrak di editor sehingga Anda dapat menyesuaikannya. Itu bisa menggunakan editor yang diberikan pada baris perintah (sebagai ``isoltest --editor /path/to/editor``), dalam environment variable ``EDITOR`` atau hanya ``/usr/bin/editor`` ( dalam urutan itu).
- ``update``: Memperbarui ekspektasi untuk kontrak yang sedang diuji. Ini memperbarui anotasi dengan menghapus harapan yang tidak terpenuhi dan menambahkan harapan yang hilang. Tes kemudian dijalankan lagi.
- ``skip``: Melewati eksekusi tes khusus ini.
- ``quit``: Keluar ``isoltest``.

Semua opsi ini berlaku untuk kontrak saat ini, mengharapkan ``quit`` yang menghentikan seluruh proses pengujian.
=======
- ``edit``: ``isoltest`` tries to open the contract in an editor so you can adjust it. It either uses the editor given on the command-line (as ``isoltest --editor /path/to/editor``), in the environment variable ``EDITOR`` or just ``/usr/bin/editor`` (in that order).
- ``update``: Updates the expectations for contract under test. This updates the annotations by removing unmet expectations and adding missing expectations. The test is then run again.
- ``skip``: Skips the execution of this particular test.
- ``quit``: Quits ``isoltest``.

All of these options apply to the current contract, except ``quit`` which stops the entire testing process.
>>>>>>> english/develop

Secara otomatis memperbarui tes di atas mengubahnya menjadi

.. code-block:: solidity

    contract test {
        uint256 variable;
    }
    // ----

dan menjalankan kembali tes. Sekarang lewat lagi:

.. code-block:: text

    Re-running test case...
    syntaxTests/double_stateVariable_declaration.sol: OK


.. note::

    Pilih nama untuk file kontrak yang menjelaskan apa yang sedang diuji, mis. ``double_variable_declaration.sol``.
    Jangan memasukkan lebih dari satu kontrak ke dalam satu file, kecuali Anda sedang menguji inheritance atau cross-contract calls.
    Setiap file harus menguji satu aspek dari fitur baru Anda.

Command-line Tests
------------------

Our suite of end-to-end command-line tests checks the behaviour of the compiler binary as a whole
in various scenarios.
These tests are located in `test/cmdlineTests/ <https://github.com/ethereum/solidity/tree/develop/test/cmdlineTests>`_,
one per subdirectory, and can be executed using the ``cmdlineTests.sh`` script.

By default the script runs all available tests.
You can also provide one or more `file name patterns <https://www.gnu.org/software/bash/manual/bash.html#Filename-Expansion>`_,
in which case only the tests matching at least one pattern will be executed.
It is also possible to exclude files matching a specific pattern by prefixing it with ``--exclude``.

By default the script assumes that a ``solc`` binary is available inside the ``build/`` subdirectory
inside the working copy.
If you build the compiler outside of the source tree, you can use the ``SOLIDITY_BUILD_DIR`` environment
variable to specify a different location for the build directory.

Example:

.. code-block:: bash

    export SOLIDITY_BUILD_DIR=~/solidity/build/
    test/cmdlineTests.sh "standard_*" "*_yul_*" --exclude "standard_yul_*"

The commands above will run tests from directories starting with ``test/cmdlineTests/standard_`` and
subdirectories of ``test/cmdlineTests/`` that have ``_yul_`` somewhere in the name,
but no test whose name starts with ``standard_yul_`` will be executed.
It will also assume that the file ``solidity/build/solc/solc`` inside your home directory is the
compiler binary (unless you are on Windows -- then ``solidity/build/solc/Release/solc.exe``).

There are several kinds of command-line tests:

- *Standard JSON test*: contains at least an ``input.json`` file.
  In general may contain:

    - ``input.json``: input file to be passed to the ``--standard-json`` option on the command line.
    - ``output.json``: expected Standard JSON output.
    - ``args``: extra command-line arguments passed to ``solc``.

- *CLI test*: contains at least an ``input.*`` file (other than ``input.json``).
  In general may contain:

    - ``input.*``: a single input file, whose name will be supplied to ``solc`` on the command line.
      Usually ``input.sol`` or ``input.yul``.
    - ``args``: extra command-line arguments passed to ``solc``.
    - ``stdin``: content to be passed to ``solc`` via standard input.
    - ``output``: expected content of the standard output.
    - ``err``: expected content of the standard error output.
    - ``exit``: expected exit code. If not provided, zero is expected.

- *Script test*: contains a ``test.*`` file.
  In general may contain:

    - ``test.*``: a single script to run, usually ``test.sh`` or ``test.py``.
      The script must be executable.

Menjalankan Fuzzer melalui AFL
==============================

Fuzzing adalah teknik yang menjalankan program pada input yang kurang lebih acak untuk menemukan status eksekusi yang
luar biasa (kesalahan segmentasi, pengecualian, dll). Fuzzers modern pintar dan menjalankan pencarian
terarah di dalam input. Kami memiliki biner khusus yang disebut ``solfuzzer`` yang mengambil kode sumber
sebagai input dan gagal setiap kali menemukan kesalahan kompiler internal, kesalahan segmentasi atau serupa, tetapi
tidak gagal jika misalnya, kode berisi kesalahan. Dengan cara ini, alat fuzzing dapat menemukan masalah internal di kompiler.

Kami terutama menggunakan `AFL <https://lcamtuf.coredump.cx/afl/>`_ untuk fuzzing. Anda perlu mengunduh dan
menginstal paket AFL dari repositori Anda (afl, afl-clang) atau buat secara manual.
Selanjutnya, buat Solidity (atau hanya biner ``solfuzzer``) dengan AFL sebagai kompiler Anda:

.. code-block:: bash

    cd build
    # if needed
    make clean
    cmake .. -DCMAKE_C_COMPILER=path/to/afl-gcc -DCMAKE_CXX_COMPILER=path/to/afl-g++
    make solfuzzer

<<<<<<< HEAD
Pada tahap ini Anda seharusnya dapat melihat pesan yang mirip dengan berikut ini:
=======
At this stage, you should be able to see a message similar to the following:
>>>>>>> english/develop

.. code-block:: text

    Scanning dependencies of target solfuzzer
    [ 98%] Building CXX object test/tools/CMakeFiles/solfuzzer.dir/fuzzer.cpp.o
    afl-cc 2.52b by <lcamtuf@google.com>
    afl-as 2.52b by <lcamtuf@google.com>
    [+] Instrumented 1949 locations (64-bit, non-hardened mode, ratio 100%).
    [100%] Linking CXX executable solfuzzer

Jika pesan instrumentasi tidak muncul, coba alihkan tanda cmake yang menunjuk ke biner dentang AFL:

.. code-block:: bash

    # if previously failed
    make clean
    cmake .. -DCMAKE_C_COMPILER=path/to/afl-clang -DCMAKE_CXX_COMPILER=path/to/afl-clang++
    make solfuzzer

Jika tidak, saat eksekusi, fuzzer berhenti dengan kesalahan yang mengatakan biner tidak diinstrumentasi:

.. code-block:: text

    afl-fuzz 2.52b by <lcamtuf@google.com>
    ... (truncated messages)
    [*] Validating target binary...

    [-] Looks like the target binary is not instrumented! The fuzzer depends on
        compile-time instrumentation to isolate interesting test cases while
        mutating the input data. For more information, and for tips on how to
        instrument binaries, please see /usr/share/doc/afl-doc/docs/README.

        When source code is not available, you may be able to leverage QEMU
        mode support. Consult the README for tips on how to enable this.
        (It is also possible to use afl-fuzz as a traditional, "dumb" fuzzer.
        For that, you can use the -n option - but expect much worse results.)

    [-] PROGRAM ABORT : No instrumentation detected
             Location : check_binary(), afl-fuzz.c:6920


Selanjutnya, Anda memerlukan beberapa contoh file sumber. Ini membuatnya lebih mudah bagi fuzzer
untuk menemukan kesalahan. Anda dapat menyalin beberapa file dari pengujian sintaks atau mengekstrak file pengujian
dari dokumentasi atau tes lainnya:

.. code-block:: bash

    mkdir /tmp/test_cases
    cd /tmp/test_cases
    # extract from tests:
    path/to/solidity/scripts/isolate_tests.py path/to/solidity/test/libsolidity/SolidityEndToEndTest.cpp
    # extract from documentation:
    path/to/solidity/scripts/isolate_tests.py path/to/solidity/docs

<<<<<<< HEAD
Dokumentasi AFL menyatakan bahwa corpus (file input awal) tidak boleh
terlalu besar. File itu sendiri tidak boleh lebih besar dari 1 kB dan harus ada
paling banyak satu file input per fungsionalitas, jadi lebih baik mulai dengan jumlah kecil.
Ada juga alat yang disebut ``afl-cmin`` yang dapat memangkas file input
yang menghasilkan perilaku biner yang serupa.
=======
The AFL documentation states that the corpus (the initial input files) should not be
too large. The files themselves should not be larger than 1 kB and there should be
at most one input file per functionality, so better start with a small number of.
There is also a tool called ``afl-cmin`` that can trim input files
that result in similar behavior of the binary.
>>>>>>> english/develop

Sekarang jalankan fuzzer (``-m`` menambah ukuran memori hingga 60 MB):

.. code-block:: bash

    afl-fuzz -m 60 -i /tmp/test_cases -o /tmp/fuzzer_reports -- /path/to/solfuzzer

Fuzzer membuat file sumber yang menyebabkan kegagalan di ``/tmp/fuzzer_reports``.
Seringkali ditemukan banyak file sumber serupa yang menghasilkan kesalahan yang sama. Kamu bisa
menggunakan alat ``scripts/uniqueErrors.sh`` untuk memfilter kesalahan unik.

Whisker
=======

*Whisker* adalah sistem templating string yang mirip dengan `Mustache <https://mustache.github.io>`_. Ini digunakan oleh
compiler di berbagai tempat untuk membantu keterbacaan, dan dengan demikian pemeliharaan dan verifikasi, kode.

Sintaksnya hadir dengan perbedaan substansial pada Kumis. Penanda template ``{{`` dan ``}}`` adalah
diganti dengan ``<`` dan ``>`` untuk membantu penguraian dan menghindari konflik dengan :ref:`yul`
(Simbol ``<`` dan ``>`` tidak valid dalam perakitan sebaris, sedangkan ``{`` dan ``}`` digunakan untuk membatasi blok).
Keterbatasan lain adalah bahwa daftar hanya diselesaikan satu kedalaman dan tidak berulang. Ini mungkin berubah di masa depan.

Spesifikasi kasarnya adalah sebagai berikut:

Setiap kemunculan ``<name>`` diganti dengan nilai string dari variabel yang disediakan ``name`` tanpa
pelolosan dan tanpa penggantian berulang. Suatu area dapat dibatasi dengan ``<#name>...</name>``. Itu digantikan
oleh sebanyak mungkin rangkaian isinya karena ada set variabel yang dipasok ke sistem templat,
setiap kali mengganti item ``<inner>`` dengan nilainya masing-masing. Variabel tingkat atas juga dapat digunakan
di dalam area tersebut.

Ada juga kondisional dari bentuk ``<?name>...<!name>...</name>``, di mana penggantian template
berlanjut secara rekursif baik di segmen pertama atau kedua tergantung pada nilai boolean
parameter ``name``. Jika ``<?+name>...<!+name>...</+name>`` digunakan, maka pemeriksaannya adalah apakah
parameter string ``name`` tidak kosong.

.. _documentation-style:

Panduan Gaya Dokumentasi
=========================

Di bagian berikut, Anda akan menemukan rekomendasi gaya yang secara khusus berfokus pada kontribusi
dokumentasi untuk Solidity.

Bahasa Inggris
----------------

<<<<<<< HEAD
Gunakan bahasa Inggris, dengan ejaan bahasa Inggris British lebih disukai, kecuali menggunakan nama proyek atau merek. Cobalah untuk mengurangi
penggunaan bahasa gaul dan referensi lokal, buat bahasa Anda sejelas mungkin untuk semua pembaca. Di bawah ini adalah beberapa referensi untuk membantu:

* `Bahasa Inggris teknis yang disederhanakan <https://en.wikipedia.org/wiki/Simplified_Technical_English>`_
* `Bahasa Inggris Internasional <https://en.wikipedia.org/wiki/International_English>`_
* `ejaan bahasa Inggris british <https://en.oxforddictionaries.com/spelling/british-and-spelling>`_


.. note::

    Walaupun dokumentasi resmi Solidity ditulis dalam bahasa Inggris, ada kontribusi komunitas :ref:`translations`
    dalam bahasa lain yang tersedia. Silakan merujuk ke `panduan terjemahan <https://github.com/solidity-docs/translation-guide>`_
    untuk informasi tentang bagaimana berkontribusi pada terjemahan komunitas.
=======
Use International English, unless using project or brand names. Try to reduce the usage of
local slang and references, making your language as clear to all readers as possible.
Below are some references to help:

* `Simplified technical English <https://en.wikipedia.org/wiki/Simplified_Technical_English>`_
* `International English <https://en.wikipedia.org/wiki/International_English>`_

.. note::

    While the official Solidity documentation is written in English, there are community contributed :ref:`translations`
    in other languages available. Please refer to the `translation guide <https://github.com/solidity-docs#solidity-documentation-translation-guide>`_
    for information on how to contribute to the community translations.
>>>>>>> english/develop

Judul Kasus untuk Judul
-----------------------

Gunakan `title case <https://titlecase.com>`_ untuk heading. Ini berarti huruf besar semua kata utama
dalam judul, tetapi bukan artikel, konjungsi, dan preposisi kecuali mereka memulai
judul.

Misalnya, berikut ini semua benar:

* Judul Kasus untuk Headings.
* Untuk Headings Gunakan Title Case.
* Nama Variabel Lokal dan state.
* Urutan Tata Letak.

Perluas Kontraksi
-------------------

Gunakan kontraksi yang diperluas untuk kata-kata, misalnya:

* "Do not" dari pada "Don't".
* "Can not" dari pada "Can't".

Suara Aktif dan Pasif
------------------------

Suara aktif biasanya direkomendasikan untuk dokumentasi gaya tutorial karena
membantu pembaca memahami siapa atau apa yang melakukan tugas. Namun, sebagai
Dokumentasi solidity adalah campuran dari tutorial dan konten referensi, suara
pasif terkadang lebih dapat diterapkan.

Sebagai ringkasan:

* Gunakan suara pasif untuk referensi teknis, misalnya definisi bahasa dan internal VM Ethereum.
* Gunakan suara aktif saat menjelaskan rekomendasi tentang cara menerapkan aspek Solidity.

Misalnya, di bawah ini dalam bentuk pasif karena menentukan aspek Solidity:

  Fungsi dapat dideklarasikan ``pure`` dalam hal ini mereka berjanji untuk tidak membaca
  dari atau mengubah state.

Sebagai contoh, di bawah ini adalah suara aktif saat membahas aplikasi Solidity:

  Saat menjalankan kompiler, Anda dapat menentukan cara menemukan elemen pertama
  dari sebuah jalur, dan juga pemetaan ulang awalan jalur.

Istilah Umum
------------

* "Function parameters" dan "return variables", bukan parameter input dan output.

Contoh Kode
-------------

Proses CI menguji semua contoh kode yang diformat blok kode yang dimulai dengan ``pragma solidity``, ``contract``, ``library``
atau ``interface`` menggunakan skrip ``./test/cmdlineTests.sh`` saat Anda membuat PR. Jika Anda menambahkan contoh kode baru,
pastikan mereka bekerja dan lulus tes sebelum membuat PR.

Pastikan bahwa semua contoh kode dimulai dengan versi ``pragma`` yang memiliki rentang terbesar di mana kode kontrak berlaku.
Misalnya ``pragma solidity >=0.4.0 <0.9.0;``.

Menjalankan Tes Dokumentasi
---------------------------

<<<<<<< HEAD
Pastikan kontribusi Anda lulus uji dokumentasi kami dengan menjalankan ``./scripts/docs.sh`` yang menginstal dependensi
yang diperlukan untuk dokumentasi dan memeriksa masalah apa pun seperti tautan rusak atau masalah sintaksis.

Desain Bahasa Solidity
========================

Untuk secara aktif terlibat dalam proses desain bahasa dan berbagi ide Anda tentang masa depan Solidity,
silakan bergabung dengan `forum Solidity <https://forum.soliditylang.org/>`_.
=======
Make sure your contributions pass our documentation tests by running ``./docs/docs.sh`` that installs dependencies
needed for documentation and checks for any problems such as broken links or syntax issues.

.. _solidity_language_design:

Solidity Language Design
========================

To actively get involved in the language design process and to share your ideas concerning the future of Solidity,
please join the `Solidity forum <https://forum.soliditylang.org/>`_.
>>>>>>> english/develop

Forum Solidity berfungsi sebagai tempat untuk mengusulkan dan mendiskusikan fitur bahasa baru dan implementasinya di
tahap awal ide atau modifikasi fitur yang ada.

Segera setelah proposal menjadi lebih nyata,
implementasinya juga akan dibahas di `Repositori GitHub Solidity <https://github.com/ethereum/solidity>`_
dalam bentuk masalah.

Selain forum dan diskusi masalah, kami secara teratur menyelenggarakan panggilan diskusi desain bahasa di mana topik, masalah, atau implementasi
fitur yang dipilih diperdebatkan secara rinci. Undangan untuk panggilan tersebut dibagikan melalui forum.

Kami juga membagikan survei umpan balik dan konten lain yang relevan dengan desain bahasa di forum.

Jika Anda ingin mengetahui posisi tim dalam hal atau menerapkan fitur baru, Anda dapat mengikuti status implementasi di `Solidity Github project <https://github.com/ethereum/solidity/projects/43>`_.
Masalah dalam backlog desain memerlukan spesifikasi lebih lanjut dan akan dibahas dalam panggilan desain bahasa atau dalam panggilan tim reguler. Anda dapat
melihat perubahan yang akan datang untuk rilis terbaru berikutnya dengan mengubah dari default branch (`develop`) ke `breaking branch <https://github.com/ethereum/solidity/tree/breaking>`_.

<<<<<<< HEAD
Untuk kasus dan pertanyaan ad-hoc, Anda dapat menghubungi kami melalui `Solidity-dev Gitter channel <https://gitter.im/ethereum/solidity-dev>`_,
ruang obrolan khusus untuk percakapan seputar kompiler Solidity dan pengembangan bahasa.
=======
For ad-hoc cases and questions, you can reach out to us via the `Solidity-dev Gitter channel <https://gitter.im/ethereum/solidity-dev>`_ — a
dedicated chatroom for conversations around the Solidity compiler and language development.
>>>>>>> english/develop

Kami senang mendengar pendapat Anda tentang bagaimana kami dapat meningkatkan proses desain bahasa menjadi lebih kolaboratif dan transparan.
