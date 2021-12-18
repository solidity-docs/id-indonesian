.. _metadata:

#################
kontrak Metadata
#################

.. index:: metadata, contract verification

Kompiler Solidity secara otomatis menghasilkan file JSON, metadata kontrak, yang berisi
informasi tentang kontrak yang dikompilasi. Anda dapat menggunakan file ini untuk menanyakan
versi kompiler, sumber yang digunakan, dokumentasi ABI dan NatSpec untuk berinteraksi lebih aman
dengan kontrak dan memverifikasi kode sumbernya.

Kompiler menambahkan secara default hash IPFS dari file metadata ke akhir bytecode (untuk detailnya,
lihat di bawah) dari setiap kontrak, sehingga Anda dapat mengambil file dengan cara yang diautentikasi
tanpa harus menggunakan penyedia data terpusat. Opsi lain yang tersedia adalah hash Swarm dan tidak
menambahkan hash metadata ke bytecode. Ini dapat dikonfigurasi melalui
:ref:`Standard JSON Interface<compiler-api>`.

Anda harus mempublikasikan file metadata ke IPFS, Swarm, atau layanan lain agar orang lain dapat
mengaksesnya. Anda membuat file dengan menggunakan perintah ``solc --metadata`` yang menghasilkan
file bernama ``ContractName_meta.json``. Ini berisi referensi IPFS dan Swarm ke kode sumber,
jadi Anda harus mengunggah semua file sumber dan file metadata.

File metadata memiliki format berikut. Contoh di bawah ini disajikan dengan cara yang dapat
dibaca manusia. Metadata yang diformat dengan benar harus menggunakan tanda kutip dengan benar,
mengurangi whitespace seminimal mungkin, dan mengurutkan kunci semua objek untuk sampai pada
pemformatan yang unik. Komentar tidak diizinkan dan digunakan di sini hanya untuk tujuan penjelasan.

.. code-block:: javascript

    {
      // Required: The version of the metadata format
      "version": "1",
      // Required: Source code language, basically selects a "sub-version"
      // of the specification
      "language": "Solidity",
      // Required: Details about the compiler, contents are specific
      // to the language.
      "compiler": {
        // Required for Solidity: Version of the compiler
        "version": "0.4.6+commit.2dabbdf0.Emscripten.clang",
        // Optional: Hash of the compiler binary which produced this output
        "keccak256": "0x123..."
      },
      // Required: Compilation source files/source units, keys are file names
      "sources":
      {
        "myFile.sol": {
          // Required: keccak256 hash of the source file
          "keccak256": "0x123...",
          // Required (unless "content" is used, see below): Sorted URL(s)
          // to the source file, protocol is more or less arbitrary, but a
          // Swarm URL is recommended
          "urls": [ "bzzr://56ab..." ],
          // Optional: SPDX license identifier as given in the source file
          "license": "MIT"
        },
        "destructible": {
          // Required: keccak256 hash of the source file
          "keccak256": "0x234...",
          // Required (unless "url" is used): literal contents of the source file
          "content": "contract destructible is owned { function destroy() { if (msg.sender == owner) selfdestruct(owner); } }"
        }
      },
      // Required: Compiler settings
      "settings":
      {
        // Required for Solidity: Sorted list of remappings
        "remappings": [ ":g=/dir" ],
        // Optional: Optimizer settings. The fields "enabled" and "runs" are deprecated
        // and are only given for backwards-compatibility.
        "optimizer": {
          "enabled": true,
          "runs": 500,
          "details": {
            // peephole defaults to "true"
            "peephole": true,
            // inliner defaults to "true"
            "inliner": true,
            // jumpdestRemover defaults to "true"
            "jumpdestRemover": true,
            "orderLiterals": false,
            "deduplicate": false,
            "cse": false,
            "constantOptimizer": false,
            "yul": true,
            // Optional: Only present if "yul" is "true"
            "yulDetails": {
              "stackAllocation": false,
              "optimizerSteps": "dhfoDgvulfnTUtnIf..."
            }
          }
        },
        "metadata": {
          // Reflects the setting used in the input json, defaults to false
          "useLiteralContent": true,
          // Reflects the setting used in the input json, defaults to "ipfs"
          "bytecodeHash": "ipfs"
        },
        // Required for Solidity: File and name of the contract or library this
        // metadata is created for.
        "compilationTarget": {
          "myFile.sol": "MyContract"
        },
        // Required for Solidity: Addresses for libraries used
        "libraries": {
          "MyLib": "0x123123..."
        }
      },
      // Required: Generated information about the contract.
      "output":
      {
        // Required: ABI definition of the contract
        "abi": [/* ... */],
        // Required: NatSpec user documentation of the contract
        "userdoc": [/* ... */],
        // Required: NatSpec developer documentation of the contract
        "devdoc": [/* ... */]
      }
    }

.. warning::
  Karena bytecode dari kontrak yang dihasilkan berisi hash metadata secara default, setiap
  perubahan pada metadata dapat mengakibatkan perubahan bytecode. Ini termasuk perubahan
  pada nama file atau jalur, dan karena metadata menyertakan hash dari semua sumber yang
  digunakan, perubahan spasi tunggal menghasilkan metadata yang berbeda, dan
  bytecode yang berbeda.

.. note::
    Definisi ABI di atas tidak memiliki urutan yang pasti. Itu bisa berubah dengan versi compiler.
    Mulai dari Solidity versi 0.5.12, array mempertahankan urutan tertentu.

.. _encoding-of-the-metadata-hash-in-the-bytecode:

Encoding Hash Metadata dalam Bytecode
=====================================

Karena kami mungkin mendukung cara lain untuk mengambil file metadata di masa mendatang,
mapping ``{"ipfs": <IPFS hash>, "solc": <compiler version>}`` disimpan `CBOR <https://tools.ietf.org/html/rfc7049>`_-dikodekan. Karena mapping
mungkin berisi lebih banyak kunci (lihat di bawah) dan awal dari penyandian itu tidak mudah
ditemukan, panjangnya ditambahkan dalam penyandian big-endian dua byte. Versi kompiler Solidity
saat ini biasanya menambahkan yang berikut ini ke akhir bytecode yang digunakan:

.. code-block:: text

    0xa2
    0x64 'i' 'p' 'f' 's' 0x58 0x22 <34 bytes IPFS hash>
    0x64 's' 'o' 'l' 'c' 0x43 <3 byte version encoding>
    0x00 0x33

Jadi untuk mengambil data, akhir bytecode yang digunakan dapat diperiksa untuk mencocokkan
pola itu dan menggunakan hash IPFS untuk mengambil file.

Sedangkan rilis build solc menggunakan pengkodean 3 byte dari versi seperti yang ditunjukkan
di atas (masing-masing satu byte untuk nomor versi mayor, minor dan patch), build prarilis
akan menggunakan string versi lengkap termasuk hash komit dan tanggal build.

.. note::
  CBOR mapping juga dapat berisi kunci lain, jadi lebih baik untuk mendekode
  data sepenuhnyadaripada mengandalkannya dimulai dengan ``0xa264``.
  Misalnya, jika ada fitur eksperimental yang memengaruhi pembuatan kode
  yang digunakan, mapping juga akan berisi ``"eksperimental": true``.

.. note::
  Kompiler saat ini menggunakan hash IPFS dari metadata secara default, tetapi mungkin
  juga menggunakan hash bzzr1 atau hash lain di masa mendatang, jadi jangan mengandalkan
  urutan ini untuk memulai dengan ``0xa2 0x64 'i' 'p' ' f' 's'``. Kami mungkin juga
  menambahkan data tambahan ke struktur CBOR ini, jadi opsi terbaik adalah menggunakan
  pengurai CBOR yang tepat.


Penggunaan untuk Pembuatan Interface Otomatis dan NatSpec
=========================================================

Metadata digunakan dengan cara berikut: Komponen yang ingin berinteraksi dengan
kontrak (mis. Mist atau dompet apa pun) mengambil kode kontrak, dari hash IPFS/Swarm
file yang kemudian diambil. File itu didekodekan JSON menjadi struktur seperti di atas.

Komponen kemudian dapat menggunakan ABI untuk secara otomatis menghasilkan
user interface yang belum sempurna untuk kontrak.

Selanjutnya, dompet dapat menggunakan dokumentasi pengguna NatSpec untuk menampilkan pesan
konfirmasi kepada pengguna setiap kali mereka berinteraksi dengan kontrak, bersama dengan
meminta otorisasi untuk tanda tangan transaksi.

Untuk informasi tambahan, baca :doc:`Ethereum Natural Language Specification (NatSpec) format <natspec-format>`.

Penggunaan untuk Verifikasi Kode Sumber
=======================================

Untuk memverifikasi kompilasi, sumber dapat diambil dari IPFS/Swarm
melalui tautan di file metadata.
Kompiler dari versi yang benar (yang dicentang sebagai bagian dari kompiler "resmi")
dipanggil pada input itu dengan pengaturan yang ditentukan. bytecode yang
dihasilkan dibandingkan dengan data transaksi pembuatan atau data opcode ``CREATE``.
Ini secara otomatis memverifikasi metadata karena hashnya adalah bagian dari bytecode.
Data berlebih sesuai dengan data input konstruktor, yang harus didekodekan
sesuai dengan antarmuka dan disajikan kepada pengguna.

Di repository `sourcify <https://github.com/ethereum/sourcify>`_
(`npm package <https://www.npmjs.com/package/source-verify>`_) anda dapat melihat
contoh kode yang menunjukkan cara menggunakan fitur ini.
