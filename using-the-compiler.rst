*********************
Menggunakan Kompiler
*********************

.. index:: ! commandline compiler, compiler;commandline, ! solc

.. _commandline-compiler:

Menggunakan Kompiler Commandline
********************************

.. note::
    Bagian ini tidak berlaku untuk :ref:`solcjs <solcjs>`, bahkan jika digunakan dalam mode commandline.

Penggunaan Dasar
----------------

Salah satu target build dari repositori Solidity adalah ``solc``, compiler commandline solidity.
Menggunakan ``solc --help`` memberi Anda penjelasan tentang semua opsi. Kompiler dapat menghasilkan berbagai output mulai dari binary sederhana dan assembly melalui abstract syntax tree (parse tree) hingga perkiraan penggunaan gas.
Jika Anda hanya ingin mengkompilasi satu file, Anda menjalankannya sebagai ``solc --bin sourceFile.sol`` dan akan mencetak biner. Jika Anda ingin mendapatkan beberapa varian keluaran yang lebih maju dari ``solc``, mungkin lebih baik mengatakannya untuk menampilkan semuanya ke file terpisah menggunakan ``solc -o outputDirectory --bin --ast-compact-json - -asm sourceFile.sol``.

Opsi Optimizer
--------------

Sebelum Anda menerapkan kontrak Anda, aktifkan pengoptimal saat kompilasi menggunakan ``solc --optimize --bin sourceFile.sol``.
Secara default, pengoptimal akan mengoptimalkan kontrak dengan asumsi kontrak tersebut dipanggil 200 kali sepanjang masa pakainya
(lebih khusus, ini mengasumsikan setiap opcode dieksekusi sekitar 200 kali).
Jika Anda ingin penerapan kontrak awal lebih murah dan eksekusi fungsi selanjutnya lebih mahal,
setel ke ``--optimize-runs=1``. Jika Anda mengharapkan banyak transaksi dan tidak peduli dengan biaya penerapan yang lebih tinggi dan
ukuran output, setel ``--optimize-runs`` ke angka tinggi.
Parameter ini memiliki efek sebagai berikut (ini mungkin berubah di masa mendatang):

- ukuran pencarian biner dalam fungsi pengiriman rutin
- cara konstanta seperti angka atau string besar disimpan

.. index:: allowed paths, --allow-paths, base path, --base-path, include paths, --include-path

Base Path dan Import Remapping
------------------------------

Kompiler commandline akan secara otomatis membaca file yang diimpor dari sistem file, tetapi
Anda juga dapat menyediakan :ref:`path redirect <import-remapping>` menggunakan ``prefix=path`` dengan cara berikut:

.. code-block:: bash

    solc github.com/ethereum/dapp-bin/=/usr/local/lib/dapp-bin/ file.sol

Ini pada dasarnya menginstruksikan kompiler untuk mencari apa pun yang dimulai dengan
``github.com/ethereum/dapp-bin/`` di bawah ``/usr/local/lib/dapp-bin``.

Saat mengakses filesystem untuk mencari impor, :ref:`path yang tidak dimulai dengan ./
atau ../ <direct-imports>` diperlakukan sebagai relatif terhadap direktori yang ditentukan menggunakan
Opsi ``--base-path`` dan ``--include-path`` (atau direktori kerja saat ini jika jalur dasar tidak ditentukan).
Selanjutnya, bagian dari jalur yang ditambahkan melalui opsi ini tidak akan muncul dalam metadata kontrak.

Untuk alasan keamanan, kompiler memiliki :ref:`pembatasan pada direktori apa yang dapat diakses <allowed-paths>`.
Direktori file sumber yang ditentukan pada baris perintah dan jalur target dari
remapping secara otomatis diizinkan untuk diakses oleh pembaca file, tetapi yang
lainnya ditolak secara default.
Path tambahan (dan subdirektorinya) dapat diizinkan melalui
``--allow-paths /sample/path,/another/sample/path`` switch.
Segala sesuatu di dalam jalur yang ditentukan melalui ``--base-path`` selalu diizinkan.

Di atas hanyalah penyederhanaan bagaimana kompiler menangani jalur impor.
Untuk penjelasan rinci dengan contoh dan pembahasan kasus sudut, silakan merujuk ke bagian di
:ref:`resolusi path <path-resolusi>`.

.. index:: ! linker, ! --link, ! --libraries
.. _library-linking:

Penautan Library
----------------

Jika kontrak Anda menggunakan :ref:`libraries <libraries>`, Anda akan melihat bahwa bytecode berisi substring dalam bentuk ``__$53aea86b7d70b31448b230b20ae141a537$__``. Ini adalah tempat penampung untuk alamat library yang sebenarnya.
Placeholder adalah awalan 34 karakter dari pengkodean hex dari hash keccak256 dari nama library yang sepenuhnya memenuhi syarat.
File bytecode juga akan berisi baris formulir ``// <placeholder> -> <fq library name>`` di bagian akhir untuk membantu
mengidentifikasi library mana yang diwakili oleh placeholder. Perhatikan bahwa nama library yang sepenuhnya memenuhi syarat
adalah jalur file sumbernya dan nama library yang dipisahkan oleh ``:``.
Anda dapat menggunakan ``solc`` sebagai penghubung yang berarti bahwa itu akan memasukkan alamat library untuk Anda pada titik-titik tersebut:

Tambahkan ``--libraries "file.sol:Math=0x1234567890123456789012345678901234567890 file.sol:Heap=0xabCD567890123456789012345678901234567890"`` ke perintah Anda untuk memberikan alamat setiap library (gunakan koma atau spasi sebagai pemisah) atau simpan string dalam file (satu library per baris) dan jalankan ``solc`` menggunakan ``--libraries fileName``.

.. note::
    Memulai Solidity 0.8.1 menerima ``=`` sebagai pemisah antara library dan alamat, dan ``:`` sebagai pemisah tidak digunakan lagi. Ini akan dihapus di masa depan. Saat ini ``--libraries "file.sol:Math:0x1234567890123456789012345678901234567890 file.sol:Heap:0xabCD567890123456789012345678901234567890"`` juga akan berfungsi.

.. index:: --standard-json, --base-path

Jika ``solc`` dipanggil dengan opsi ``--standard-json``, ia akan mengharapkan input JSON (seperti yang dijelaskan di bawah) pada input standar, dan mengembalikan output JSON pada output standar. Ini adalah interface yang direkomendasikan untuk penggunaan yang lebih kompleks dan terutama otomatis. Proses akan selalu berakhir dalam status "sukses" dan melaporkan kesalahan apa pun melalui output JSON.
Opsi ``--base-path`` juga diproses dalam mode json standar.

Jika ``solc`` dipanggil dengan opsi ``--link``, semua file input ditafsirkan sebagai binari yang tidak terhubung (dikodekan hex) dalam format ``__$53aea86b7d70b31448b230b20ae141a537$__`` yang diberikan di atas dan ditautkan di tempat (jika input dibaca dari stdin, itu ditulis ke stdout). Semua opsi kecuali ``--libraries`` diabaikan (termasuk ``-o``) dalam kasus ini.

.. warning::
    Menautkan library secara manual pada bytecode yang dihasilkan tidak disarankan karena tidak memperbarui
    metadata kontrak. Karena metadata berisi daftar library yang ditentukan pada saat
    kompilasi dan bytecode berisi hash metadata, Anda akan mendapatkan binari yang berbeda, tergantung
    kapan penautan dilakukan.

    Anda harus meminta kompiler untuk menautkan library pada saat kontrak dikompilasi
    dengan menggunakan opsi ``--libraries`` dari ``solc`` atau kunci ``libraries`` jika Anda menggunakan
    antarmuka JSON standar ke kompiler.

.. note::
    Placeholder library dulunya adalah nama library itu sendiri
    yang sepenuhnya memenuhi syarat, bukan hashnya. Format ini masih didukung oleh ``solc --link`` tetapi
    kompilator tidak akan mengeluarkannya lagi. Perubahan ini dibuat untuk mengurangi
    kemungkinan tabrakan antar library, karena hanya 36 karakter
    pertama dari nama library yang memenuhi syarat yang dapat digunakan.

.. _evm-version:
.. index:: ! EVM version, compile target

Setting Versi EVM ke Target
***************************

Saat Anda mengkompilasi kode kontrak Anda, Anda dapat menentukan versi mesin virtual
Ethereum untuk dikompilasi untuk menghindari fitur atau perilaku tertentu.

.. warning::

   Kompilasi untuk versi EVM yang salah dapat menghasilkan perilaku yang salah, aneh,
   dan gagal. Harap pastikan, terutama jika menjalankan private chain, bahwa Anda
   menggunakan versi EVM yang cocok.

Pada baris perintah, Anda dapat memilih versi EVM sebagai berikut:

.. code-block:: shell

  solc --evm-version <VERSION> contract.sol

Di :ref:`antarmuka JSON standar <compiler-api>`, gunakan kunci ``"evmVersion"`` di bidang ``"settings"``:

.. code-block:: javascript

    {
      "sources": {/* ... */},
      "settings": {
        "optimizer": {/* ... */},
        "evmVersion": "<VERSION>"
      }
    }

Opsi Target
-----------

Di bawah ini adalah daftar versi EVM target dan perubahan yang relevan dengan kompiler yang diperkenalkan
di setiap versi. Kompatibilitas *Backward* tidak dijamin antara setiap versi.

- ``homestead``
   - (versi tertua)
- ``tangerineWhistle``
   - Biaya gas untuk akses ke akun lain meningkat, relevan untuk estimasi gas dan pengoptimalan.
   - Semua gas yang dikirim secara default untuk panggilan eksternal, sebelumnya jumlah tertentu harus dipertahankan.
- ``spuriousDragon``
   - Biaya gas untuk opcode ``exp`` meningkat, relevan untuk estimasi gas dan pengoptimalan.
- ``byzantium``
   - Opcode ``returndatacopy``, ``returndatasize`` dan ``staticcall`` tersedia dalam assembly.
   - Opcode ``staticcall`` digunakan saat memanggil tampilan non-library atau fungsi pure, yang mencegah fungsi mengubah state pada tingkat EVM, yaitu, bahkan berlaku saat Anda menggunakan konversi jenis yang tidak valid.
   - Dimungkinkan untuk mengakses data dinamis yang dikembalikan dari panggilan fungsi.
   - ``revert`` opcode diperkenalkan, yang berarti ``revert()`` tidak akan membuang gas.
- ``constantinople``
   - Opcode ``create2`, ``extcodehash``, ``shl``, ``shr`` and ``sar`` tersedia di assembly.
   - Shifting operators menggunakan shifting opcodes dan sehingga membutuhkan lebih sedikit gas.
- ``petersburg``
   - Kompiler berperilaku dengan cara yang sama seperti dengan konstantinopel.
- ``istanbul``
   - Opcodes ``chainid`` dan ``selfbalance`` tersedia di assembly.
- ``berlin``
   - Biaya gas untuk ``SLOAD``, ``*CALL``, ``BALANCE``, ``EXT*`` dan ``SELFDESTRUCT`` meningkat. Kompiler
     mengasumsikan biaya cold gas untuk operasi tersebut. Ini relevan untuk estimasi gas
     dan pengoptimal.
- ``london`` (**default**)
   - Block base fee (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ dan `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_) dapat diakses via global ``block.basefee`` atau ``basefee()`` di inline assembly.


.. index:: ! standard JSON, ! --standard-json
.. _compiler-api:

Deskripsi JSON Input dan Output Kompiler
****************************************

Cara yang disarankan untuk berinteraksi dengan kompiler Solidity terutama untuk
pengaturan yang lebih kompleks dan otomatis adalah yang disebut antarmuka input-output JSON.
Antarmuka yang sama disediakan oleh semua distribusi kompiler.

Bidang umumnya dapat berubah,
beberapa bersifat opsional (seperti yang disebutkan), tetapi kami mencoba hanya membuat perubahan yang kompatibel dengan versi sebelumnya.

Kompiler API mengharapkan input berformat JSON dan mengeluarkan hasil kompilasi dalam
output berformat JSON. Keluaran kesalahan standar tidak digunakan dan proses akan selalu
berakhir dalam keadaan "berhasil", bahkan jika ada kesalahan. Kesalahan selalu dilaporkan
sebagai bagian dari keluaran JSON.

Subbagian berikut menjelaskan format melalui contoh.
Komentar tentu saja tidak diizinkan dan digunakan di sini hanya untuk tujuan penjelasan.

Deskripsi Input
---------------

.. code-block:: javascript

    {
      // Required: Source code language. Currently supported are "Solidity" and "Yul".
      "language": "Solidity",
      // Required
      "sources":
      {
        // The keys here are the "global" names of the source files,
        // imports can use other files via remappings (see below).
        "myFile.sol":
        {
          // Optional: keccak256 hash of the source file
          // It is used to verify the retrieved content if imported via URLs.
          "keccak256": "0x123...",
          // Required (unless "content" is used, see below): URL(s) to the source file.
          // URL(s) should be imported in this order and the result checked against the
          // keccak256 hash (if available). If the hash doesn't match or none of the
          // URL(s) result in success, an error should be raised.
          // Using the commandline interface only filesystem paths are supported.
          // With the JavaScript interface the URL will be passed to the user-supplied
          // read callback, so any URL supported by the callback can be used.
          "urls":
          [
            "bzzr://56ab...",
            "ipfs://Qma...",
            "/tmp/path/to/file.sol"
            // If files are used, their directories should be added to the command line via
            // `--allow-paths <path>`.
          ]
        },
        "destructible":
        {
          // Optional: keccak256 hash of the source file
          "keccak256": "0x234...",
          // Required (unless "urls" is used): literal contents of the source file
          "content": "contract destructible is owned { function shutdown() { if (msg.sender == owner) selfdestruct(owner); } }"
        }
      },
      // Optional
      "settings":
      {
        // Optional: Stop compilation after the given stage. Currently only "parsing" is valid here
        "stopAfter": "parsing",
        // Optional: Sorted list of remappings
        "remappings": [ ":g=/dir" ],
        // Optional: Optimizer settings
        "optimizer": {
          // Disabled by default.
          // NOTE: enabled=false still leaves some optimizations on. See comments below.
          // WARNING: Before version 0.8.6 omitting the 'enabled' key was not equivalent to setting
          // it to false and would actually disable all the optimizations.
          "enabled": true,
          // Optimize for how many times you intend to run the code.
          // Lower values will optimize more for initial deployment cost, higher
          // values will optimize more for high-frequency usage.
          "runs": 200,
          // Switch optimizer components on or off in detail.
          // The "enabled" switch above provides two defaults which can be
          // tweaked here. If "details" is given, "enabled" can be omitted.
          "details": {
            // The peephole optimizer is always on if no details are given,
            // use details to switch it off.
            "peephole": true,
            // The inliner is always on if no details are given,
            // use details to switch it off.
            "inliner": true,
            // The unused jumpdest remover is always on if no details are given,
            // use details to switch it off.
            "jumpdestRemover": true,
            // Sometimes re-orders literals in commutative operations.
            "orderLiterals": false,
            // Removes duplicate code blocks
            "deduplicate": false,
            // Common subexpression elimination, this is the most complicated step but
            // can also provide the largest gain.
            "cse": false,
            // Optimize representation of literal numbers and strings in code.
            "constantOptimizer": false,
            // The new Yul optimizer. Mostly operates on the code of ABI coder v2
            // and inline assembly.
            // It is activated together with the global optimizer setting
            // and can be deactivated here.
            // Before Solidity 0.6.0 it had to be activated through this switch.
            "yul": false,
            // Tuning options for the Yul optimizer.
            "yulDetails": {
              // Improve allocation of stack slots for variables, can free up stack slots early.
              // Activated by default if the Yul optimizer is activated.
              "stackAllocation": true,
              // Select optimization steps to be applied.
              // Optional, the optimizer will use the default sequence if omitted.
              "optimizerSteps": "dhfoDgvulfnTUtnIf..."
            }
          }
        },
        // Version of the EVM to compile for.
        // Affects type checking and code generation. Can be homestead,
        // tangerineWhistle, spuriousDragon, byzantium, constantinople, petersburg, istanbul or berlin
        "evmVersion": "byzantium",
        // Optional: Change compilation pipeline to go through the Yul intermediate representation.
        // This is a highly EXPERIMENTAL feature, not to be used for production. This is false by default.
        "viaIR": true,
        // Optional: Debugging settings
        "debug": {
          // How to treat revert (and require) reason strings. Settings are
          // "default", "strip", "debug" and "verboseDebug".
          // "default" does not inject compiler-generated revert strings and keeps user-supplied ones.
          // "strip" removes all revert strings (if possible, i.e. if literals are used) keeping side-effects
          // "debug" injects strings for compiler-generated internal reverts, implemented for ABI encoders V1 and V2 for now.
          // "verboseDebug" even appends further information to user-supplied revert strings (not yet implemented)
          "revertStrings": "default",
          // Optional: How much extra debug information to include in comments in the produced EVM
          // assembly and Yul code. Available components are:
          // - `location`: Annotations of the form `@src <index>:<start>:<end>` indicating the
          //    location of the corresponding element in the original Solidity file, where:
          //     - `<index>` is the file index matching the `@use-src` annotation,
          //     - `<start>` is the index of the first byte at that location,
          //     - `<end>` is the index of the first byte after that location.
          // - `snippet`: A single-line code snippet from the location indicated by `@src`.
          //     The snippet is quoted and follows the corresponding `@src` annotation.
          // - `*`: Wildcard value that can be used to request everything.
          "debugInfo": ["location", "snippet"]
        },
        // Metadata settings (optional)
        "metadata": {
          // Use only literal content and not URLs (false by default)
          "useLiteralContent": true,
          // Use the given hash method for the metadata hash that is appended to the bytecode.
          // The metadata hash can be removed from the bytecode via option "none".
          // The other options are "ipfs" and "bzzr1".
          // If the option is omitted, "ipfs" is used by default.
          "bytecodeHash": "ipfs"
        },
        // Addresses of the libraries. If not all libraries are given here,
        // it can result in unlinked objects whose output data is different.
        "libraries": {
          // The top level key is the the name of the source file where the library is used.
          // If remappings are used, this source file should match the global path
          // after remappings were applied.
          // If this key is an empty string, that refers to a global level.
          "myFile.sol": {
            "MyLib": "0x123123..."
          }
        },
        // The following can be used to select desired outputs based
        // on file and contract names.
        // If this field is omitted, then the compiler loads and does type checking,
        // but will not generate any outputs apart from errors.
        // The first level key is the file name and the second level key is the contract name.
        // An empty contract name is used for outputs that are not tied to a contract
        // but to the whole source file like the AST.
        // A star as contract name refers to all contracts in the file.
        // Similarly, a star as a file name matches all files.
        // To select all outputs the compiler can possibly generate, use
        // "outputSelection: { "*": { "*": [ "*" ], "": [ "*" ] } }"
        // but note that this might slow down the compilation process needlessly.
        //
        // The available output types are as follows:
        //
        // File level (needs empty string as contract name):
        //   ast - AST of all source files
        //
        // Contract level (needs the contract name or "*"):
        //   abi - ABI
        //   devdoc - Developer documentation (natspec)
        //   userdoc - User documentation (natspec)
        //   metadata - Metadata
        //   ir - Yul intermediate representation of the code before optimization
        //   irOptimized - Intermediate representation after optimization
        //   storageLayout - Slots, offsets and types of the contract's state variables.
        //   evm.assembly - New assembly format
        //   evm.legacyAssembly - Old-style assembly format in JSON
        //   evm.bytecode.functionDebugData - Debugging information at function level
        //   evm.bytecode.object - Bytecode object
        //   evm.bytecode.opcodes - Opcodes list
        //   evm.bytecode.sourceMap - Source mapping (useful for debugging)
        //   evm.bytecode.linkReferences - Link references (if unlinked object)
        //   evm.bytecode.generatedSources - Sources generated by the compiler
        //   evm.deployedBytecode* - Deployed bytecode (has all the options that evm.bytecode has)
        //   evm.deployedBytecode.immutableReferences - Map from AST ids to bytecode ranges that reference immutables
        //   evm.methodIdentifiers - The list of function hashes
        //   evm.gasEstimates - Function gas estimates
        //   ewasm.wast - Ewasm in WebAssembly S-expressions format
        //   ewasm.wasm - Ewasm in WebAssembly binary format
        //
        // Note that using a using `evm`, `evm.bytecode`, `ewasm`, etc. will select every
        // target part of that output. Additionally, `*` can be used as a wildcard to request everything.
        //
        "outputSelection": {
          "*": {
            "*": [
              "metadata", "evm.bytecode" // Enable the metadata and bytecode outputs of every single contract.
              , "evm.bytecode.sourceMap" // Enable the source map output of every single contract.
            ],
            "": [
              "ast" // Enable the AST output of every single file.
            ]
          },
          // Enable the abi and opcodes output of MyContract defined in file def.
          "def": {
            "MyContract": [ "abi", "evm.bytecode.opcodes" ]
          }
        },
        // The modelChecker object is experimental and subject to changes.
        "modelChecker":
        {
          // Chose which contracts should be analyzed as the deployed one.
          "contracts":
          {
            "source1.sol": ["contract1"],
            "source2.sol": ["contract2", "contract3"]
          },
          // Choose whether division and modulo operations should be replaced by
          // multiplication with slack variables. Default is `true`.
          // Using `false` here is recommended if you are using the CHC engine
          // and not using Spacer as the Horn solver (using Eldarica, for example).
          // See the Formal Verification section for a more detailed explanation of this option.
          "divModWithSlacks": true,
          // Choose which model checker engine to use: all (default), bmc, chc, none.
          "engine": "chc",
          // Choose which types of invariants should be reported to the user: contract, reentrancy.
          "invariants": ["contract", "reentrancy"],
          // Choose whether to output all unproved targets. The default is `false`.
          "showUnproved": true,
          // Choose which solvers should be used, if available.
          // See the Formal Verification section for the solvers description.
          "solvers": ["cvc4", "smtlib2", "z3"],
          // Choose which targets should be checked: constantCondition,
          // underflow, overflow, divByZero, balance, assert, popEmptyArray, outOfBounds.
          // If the option is not given all targets are checked by default,
          // except underflow/overflow for Solidity >=0.8.7.
          // See the Formal Verification section for the targets description.
          "targets": ["underflow", "overflow", "assert"],
          // Timeout for each SMT query in milliseconds.
          // If this option is not given, the SMTChecker will use a deterministic
          // resource limit by default.
          // A given timeout of 0 means no resource/time restrictions for any query.
          "timeout": 20000
        }
      }
    }


Output Description
------------------

.. code-block:: javascript

    {
      // Optional: not present if no errors/warnings/infos were encountered
      "errors": [
        {
          // Optional: Location within the source file.
          "sourceLocation": {
            "file": "sourceFile.sol",
            "start": 0,
            "end": 100
          },
          // Optional: Further locations (e.g. places of conflicting declarations)
          "secondarySourceLocations": [
            {
              "file": "sourceFile.sol",
              "start": 64,
              "end": 92,
              "message": "Other declaration is here:"
            }
          ],
          // Mandatory: Error type, such as "TypeError", "InternalCompilerError", "Exception", etc.
          // See below for complete list of types.
          "type": "TypeError",
          // Mandatory: Component where the error originated, such as "general", "ewasm", etc.
          "component": "general",
          // Mandatory ("error", "warning" or "info", but please note that this may be extended in the future)
          "severity": "error",
          // Optional: unique code for the cause of the error
          "errorCode": "3141",
          // Mandatory
          "message": "Invalid keyword",
          // Optional: the message formatted with source location
          "formattedMessage": "sourceFile.sol:100: Invalid keyword"
        }
      ],
      // This contains the file-level outputs.
      // It can be limited/filtered by the outputSelection settings.
      "sources": {
        "sourceFile.sol": {
          // Identifier of the source (used in source maps)
          "id": 1,
          // The AST object
          "ast": {}
        }
      },
      // This contains the contract-level outputs.
      // It can be limited/filtered by the outputSelection settings.
      "contracts": {
        "sourceFile.sol": {
          // If the language used has no contract names, this field should equal to an empty string.
          "ContractName": {
            // The Ethereum Contract ABI. If empty, it is represented as an empty array.
            // See https://docs.soliditylang.org/en/develop/abi-spec.html
            "abi": [],
            // See the Metadata Output documentation (serialised JSON string)
            "metadata": "{/* ... */}",
            // User documentation (natspec)
            "userdoc": {},
            // Developer documentation (natspec)
            "devdoc": {},
            // Intermediate representation (string)
            "ir": "",
            // See the Storage Layout documentation.
            "storageLayout": {"storage": [/* ... */], "types": {/* ... */} },
            // EVM-related outputs
            "evm": {
              // Assembly (string)
              "assembly": "",
              // Old-style assembly (object)
              "legacyAssembly": {},
              // Bytecode and related details.
              "bytecode": {
                // Debugging data at the level of functions.
                "functionDebugData": {
                  // Now follows a set of functions including compiler-internal and
                  // user-defined function. The set does not have to be complete.
                  "@mint_13": { // Internal name of the function
                    "entryPoint": 128, // Byte offset into the bytecode where the function starts (optional)
                    "id": 13, // AST ID of the function definition or null for compiler-internal functions (optional)
                    "parameterSlots": 2, // Number of EVM stack slots for the function parameters (optional)
                    "returnSlots": 1 // Number of EVM stack slots for the return values (optional)
                  }
                },
                // The bytecode as a hex string.
                "object": "00fe",
                // Opcodes list (string)
                "opcodes": "",
                // The source mapping as a string. See the source mapping definition.
                "sourceMap": "",
                // Array of sources generated by the compiler. Currently only
                // contains a single Yul file.
                "generatedSources": [{
                  // Yul AST
                  "ast": {/* ... */},
                  // Source file in its text form (may contain comments)
                  "contents":"{ function abi_decode(start, end) -> data { data := calldataload(start) } }",
                  // Source file ID, used for source references, same "namespace" as the Solidity source files
                  "id": 2,
                  "language": "Yul",
                  "name": "#utility.yul"
                }],
                // If given, this is an unlinked object.
                "linkReferences": {
                  "libraryFile.sol": {
                    // Byte offsets into the bytecode.
                    // Linking replaces the 20 bytes located there.
                    "Library1": [
                      { "start": 0, "length": 20 },
                      { "start": 200, "length": 20 }
                    ]
                  }
                }
              },
              "deployedBytecode": {
                /* ..., */ // The same layout as above.
                "immutableReferences": {
                  // There are two references to the immutable with AST ID 3, both 32 bytes long. One is
                  // at bytecode offset 42, the other at bytecode offset 80.
                  "3": [{ "start": 42, "length": 32 }, { "start": 80, "length": 32 }]
                }
              },
              // The list of function hashes
              "methodIdentifiers": {
                "delegate(address)": "5c19a95c"
              },
              // Function gas estimates
              "gasEstimates": {
                "creation": {
                  "codeDepositCost": "420000",
                  "executionCost": "infinite",
                  "totalCost": "infinite"
                },
                "external": {
                  "delegate(address)": "25000"
                },
                "internal": {
                  "heavyLifting()": "infinite"
                }
              }
            },
            // Ewasm related outputs
            "ewasm": {
              // S-expressions format
              "wast": "",
              // Binary format (hex string)
              "wasm": ""
            }
          }
        }
      }
    }


Error Types
~~~~~~~~~~~

1. ``JSONError``: Input JSON tidak sesuai dengan format yang diperlukan, mis. input bukan objek JSON, bahasa tidak didukung, dll.
2. ``IOError``: IO dan kesalahan pemrosesan impor, seperti URL yang tidak dapat diselesaikan atau ketidakcocokan hash dalam sumber yang disediakan.
3. ``ParserError``: Kode sumber tidak sesuai dengan aturan bahasa.
4. ``DocstringParsingError``: Tag NatSpec di blok komentar tidak dapat diuraikan.
5. ``SyntaxError``: Kesalahan sintaksis, seperti ``continue`` digunakan di luar loop ``for``.
6. ``DeclarationError``: Nama pengidentifikasi tidak valid, tidak dapat diselesaikan, atau bentrok. misalnya ``Identifier tidak ditemukan``
7. ``TypeError``: Kesalahan dalam sistem tipe, seperti konversi tipe yang tidak valid, penetapan yang tidak valid, dll.
8. ``UnimplementedFeatureError``: Fitur tidak didukung oleh kompiler, tetapi diharapkan didukung di versi mendatang.
9. ``InternalCompilerError``: Bug internal terpicu dalam kompiler - ini harus dilaporkan sebagai masalah.
10. ``Pengecualian``: Kegagalan yang tidak diketahui selama kompilasi - ini harus dilaporkan sebagai masalah.
11. ``CompilerError``: Penggunaan tumpukan kompiler yang tidak valid - ini harus dilaporkan sebagai masalah.
12. ``FatalError``: Kesalahan fatal tidak diproses dengan benar - ini harus dilaporkan sebagai masalah.
13. ``Peringatan``: Peringatan, yang tidak menghentikan kompilasi, tetapi harus ditangani jika memungkinkan.
14. ``Info``: Informasi yang menurut kompiler mungkin berguna bagi pengguna, tetapi tidak berbahaya dan tidak perlu ditangani.


.. _compiler-tools:

Alat kompiler
*************

solidity-upgrade
----------------

``solidity-upgrade`` dapat membantu Anda meningkatkan versi kontrak
secara semi-otomatis untuk memecahkan perubahan bahasa. Meskipun tidak dan tidak dapat
mengimplementasikan semua perubahan yang diperlukan untuk setiap rilis yang terputus, ia masih
mendukungnya, yang akan membutuhkan banyak penyesuaian manual berulang.

.. note::

    ``solidity-upgrade`` melakukan sebagian besar pekerjaan, tetapi kontrak Anda kemungkinan
    besar akan membutuhkan penyesuaian manual lebih lanjut. Sebaiknya gunakan sistem kontrol
    versi untuk file Anda. Ini membantu meninjau dan akhirnya mengembalikan perubahan yang dibuat.

.. warning::

    ``solidity-upgrade`` tidak dianggap lengkap atau bebas dari bug, jadi harap gunakan dengan hati-hati.

Bagaimana cara kerjanya
~~~~~~~~~~~~~~~~~~~~~~~

Anda dapat meneruskan (sebuah) file sumber Solidity ke ``solidity-upgrade [files]``. Jika
ini menggunakan pernyataan ``import`` yang merujuk ke file di luar direktori
file sumber saat ini, Anda perlu menentukan direktori yang diizinkan untuk membaca dan
mengimpor file dari, dengan meneruskan ``--allow-paths [directory]` `. Anda dapat mengabaikan file yang hilang dengan
meneruskan ``--ignore-missing``.

``solidity-upgrade`` didasarkan pada ``libsolidity`` dan dapat mengurai, mengkompilasi dan
menganalisis file sumber Anda, dan mungkin menemukan peningkatan sumber yang berlaku di dalamnya.

Source upgrade dianggap sebagai perubahan tekstual kecil pada kode sumber Anda.
Mereka diterapkan pada representasi dalam memori dari file sumber
yang diberikan. File sumber terkait diperbarui secara default, tetapi Anda
dapat meneruskan ``--dry-run`` untuk mensimulasikan ke seluruh proses peningkatan tanpa menulis ke file apa pun.

Proses upgrade itu sendiri memiliki dua fase. Pada fase pertama, file sumber diurai,
dan karena kode sumber tidak dapat ditingkatkan pada level tersebut,
kesalahan dikumpulkan dan dapat dicatat dengan meneruskan ``--verbose``. Tidak ada
peningkatan sumber yang tersedia saat ini.

Pada fase kedua, semua sumber dikompilasi dan semua modul analisis pemutakhiran
yang diaktifkan dijalankan bersamaan dengan kompilasi. Secara default, semua modul yang
tersedia diaktifkan. Silakan baca dokumentasi di
:ref:`available modules <upgrade-modules>` untuk detail lebih lanjut.


Hal ini dapat mengakibatkan kesalahan kompilasi yang dapat diperbaiki oleh
peningkatan sumber. Jika tidak ada kesalahan yang terjadi, tidak ada pemutakhiran
sumber yang dilaporkan dan Anda selesai.
Jika kesalahan terjadi dan beberapa modul pemutakhiran melaporkan pemutakhiran sumber,
yang pertama dilaporkan akan diterapkan dan kompilasi dipicu lagi untuk semua file sumber
yang diberikan. Langkah sebelumnya diulang selama upgrade sumber adalah dilaporkan.
Jika kesalahan masih terjadi, Anda dapat mencatatnya dengan meneruskan ``--verbose``.
Jika tidak ada kesalahan yang terjadi, kontrak Anda mutakhir dan dapat dikompilasi
dengan versi kompiler terbaru.

.. _upgrade-modules:

Peningkatan Modul yang Tersedia
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+----------------------------+---------+--------------------------------------------------+
| Modul                      | Versi   | Deskstipsi                                       |
+============================+=========+==================================================+
| ``constructor``            | 0.5.0   | Konstruktor sekarang harus didefinisikan         |
|                            |         | menggunakan ``constructor`` keyword.             |
+----------------------------+---------+--------------------------------------------------+
| ``visibility``             | 0.5.0   | Visibilitas fungsi eksplisit sekarang wajib,     |
|                            |         | defaults ke ``public``.                          |
+----------------------------+---------+--------------------------------------------------+
| ``abstract``               | 0.6.0   | keyword ``abstract`` harus digunakan jika        |
|                            |         | kontrak tidak mengiplementasikan semua fungsinya.|
+----------------------------+---------+--------------------------------------------------+
| ``virtual``                | 0.6.0   | Fungsi tanpa implementasi di luar                |
|                            |         | antarmuka harus ditandai ``virtual``.            |
+----------------------------+---------+--------------------------------------------------+
| ``override``               | 0.6.0   | Saat mengganti fungsi atau pengubah, keyword     |
|                            |         | baru ``override`` harus digunakan.               |
+----------------------------+---------+--------------------------------------------------+
| ``dotsyntax``              | 0.7.0   | Sintaks berikut tidak digunakan lagi:            |
|                            |         | ``f.gas(...)()``, ``f.value(...)()`` dan         |
|                            |         | ``(new C).value(...)()``. Ganti panggilan ini    |
|                            |         | dengan ``f{gas: ..., value: ...}()`` dan         |
|                            |         | ``(new C){value: ...}()``.                       |
+----------------------------+---------+--------------------------------------------------+
| ``now``                    | 0.7.0   | Keyword ``now`` sudah ditinggalkan. Gunakan      |
|                            |         | ``block.timestamp`` Sebagai ganyinya.            |
+----------------------------+---------+--------------------------------------------------+
| ``constructor-visibility`` | 0.7.0   | Menghapus visibilitas konstruktor.               |
|                            |         |                                                  |
+----------------------------+---------+--------------------------------------------------+

Silahkan baca :doc:`0.5.0 release notes <050-breaking-changes>`,
:doc:`0.6.0 release notes <060-breaking-changes>`,
:doc:`0.7.0 release notes <070-breaking-changes>` dan :doc:`0.8.0 release notes <080-breaking-changes>` untuk rincian lebih lanjut.

Synopsis
~~~~~~~~

.. code-block:: none

    Usage: solidity-upgrade [options] contract.sol

    Allowed options:
        --help               Show help message and exit.
        --version            Show version and exit.
        --allow-paths path(s)
                             Allow a given path for imports. A list of paths can be
                             supplied by separating them with a comma.
        --ignore-missing     Ignore missing files.
        --modules module(s)  Only activate a specific upgrade module. A list of
                             modules can be supplied by separating them with a comma.
        --dry-run            Apply changes in-memory only and don't write to input
                             file.
        --verbose            Print logs, errors and changes. Shortens output of
                             upgrade patches.
        --unsafe             Accept *unsafe* changes.



Laporan Bug / Permintaan Fitur
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Jika Anda menemukan bug atau jika Anda memiliki permintaan fitur, silakan
`mengajukan masalah <https://github.com/ethereum/solidity/issues/new/choose>`_ di Github.


Contoh
~~~~~~

Misalnya Anda memiliki kontrak berikut di ``Source.sol``:

.. code-block:: Solidity

    pragma solidity >=0.6.0 <0.6.4;
    // This will not compile after 0.7.0
    // SPDX-License-Identifier: GPL-3.0
    contract C {
        // FIXME: remove constructor visibility and make the contract abstract
        constructor() internal {}
    }

    contract D {
        uint time;

        function f() public payable {
            // FIXME: change now to block.timestamp
            time = now;
        }
    }

    contract E {
        D d;

        // FIXME: remove constructor visibility
        constructor() public {}

        function g() public {
            // FIXME: change .value(5) =>  {value: 5}
            d.f.value(5)();
        }
    }



Perubahan yang Diperlukan
^^^^^^^^^^^^^^^^^^^^^^^^^

Kontrak di atas tidak akan dikompilasi mulai dari 0.7.0. Untuk memperbarui kontrak dengan
versi Solidity saat ini, modul pemutakhiran berikut harus dijalankan:
``constructor-visibility``, ``now`` dan ``dotsyntax``. Silakan baca dokumentasi di
:ref:`modul yang tersedia <upgrade-modules>` untuk detail lebih lanjut.


Menjalankan Upgrade
^^^^^^^^^^^^^^^^^^^

Direkomendasikan untuk secara eksplisit menentukan modul upgrade dengan menggunakan argumen ``--modules``.

.. code-block:: bash

    solidity-upgrade --modules constructor-visibility,now,dotsyntax Source.sol

Perintah di atas menerapkan semua perubahan seperti yang ditunjukkan di bawah ini. Harap tinjau dengan cermat (pragma
harus diperbarui secara manual.)

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    abstract contract C {
        // FIXME: remove constructor visibility and make the contract abstract
        constructor() {}
    }

    contract D {
        uint time;

        function f() public payable {
            // FIXME: change now to block.timestamp
            time = block.timestamp;
        }
    }

    contract E {
        D d;

        // FIXME: remove constructor visibility
        constructor() {}

        function g() public {
            // FIXME: change .value(5) =>  {value: 5}
            d.f{value: 5}();
        }
    }
