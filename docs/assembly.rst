.. _inline-assembly:

###############
Inline Assembly
###############

.. index:: ! assembly, ! asm, ! evmasm


<<<<<<< HEAD
Anda dapat menyisipkan pernyataan Solidity dengan inline assembly dalam bahasa
yang mirip dengan salah satu mesin virtual Ethereum. Ini memberi Anda kontrol
yang lebih halus, yang sangat berguna saat Anda menyempurnakan bahasa dengan menulis library.
=======
You can interleave Solidity statements with inline assembly in a language close
to the one of the Ethereum Virtual Machine. This gives you more fine-grained control,
which is especially useful when you are enhancing the language by writing libraries.
>>>>>>> english/develop

Bahasa yang digunakan untuk inline assembly di Solidity disebut :ref:`Yul <yul>`
dan didokumentasikan dalam bagiannya sendiri. Bagian ini hanya akan membahas bagaimana
kode inline assembly dapat berinteraksi dengan kode Solidity di sekitarnya.


.. warning::
    Inline assembly adalah cara untuk mengakses Mesin Virtual Ethereum
    pada level rendah. Ini melewati beberapa fitur safety dan pemeriksaan
    penting Solidity. Anda hanya boleh menggunakannya untuk tugas-tugas
    yang membutuhkannya, dan hanya jika Anda yakin untuk menggunakannya.


Sebuah blok inline assembly ditandai dengan ``assembly { ... }``, dimana kode di dalam
kurung kurawal adalah kode dalam bahasa :ref:`Yul <yul>`.

Kode inline assembly dapat mengakses variabel lokal Solidity seperti yang dijelaskan di bawah ini.

Blok inline assembly yang berbeda tidak berbagi namespace, misalnya tidak mungkin untuk memanggil
fungsi Yul atau mengakses variabel Yul yang ditentukan dalam blok inline assembly yang berbeda.

Contoh
-------

Contoh berikut menyediakan kode library untuk mengakses kode kontrak lain dan
memuatnya ke dalam variabel ``byte``. Hal ini dimungkinkan dengan "plain Solidity" juga,
dengan menggunakan ``<address>.code``. Tetapi intinya di sini adalah bahwa library rakitan
yang dapat digunakan kembali dapat meningkatkan bahasa Solidity tanpa perubahan kompiler.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library GetCode {
        function at(address addr) public view returns (bytes memory code) {
            assembly {
                // retrieve the size of the code, this needs assembly
                let size := extcodesize(addr)
                // allocate output byte array - this could also be done without assembly
                // by using code = new bytes(size)
                code := mload(0x40)
                // new "memory end" including padding
                mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                // store length in memory
                mstore(code, size)
                // actually retrieve the code, this needs assembly
                extcodecopy(addr, add(code, 0x20), 0, size)
            }
        }
    }

Inline assembly juga bermanfaat jika pengoptimal gagal menghasilkan
kode yang efisien, misalnya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;


    library VectorSum {
        // This function is less efficient because the optimizer currently fails to
        // remove the bounds checks in array access.
        function sumSolidity(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i)
                sum += data[i];
        }

        // We know that we only access the array in bounds, so we can avoid the check.
        // 0x20 needs to be added to an array because the first slot contains the
        // array length.
        function sumAsm(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i) {
                assembly {
                    sum := add(sum, mload(add(add(data, 0x20), mul(i, 0x20))))
                }
            }
        }

        // Same as above, but accomplish the entire code within inline assembly.
        function sumPureAsm(uint[] memory data) public pure returns (uint sum) {
            assembly {
                // Load the length (first 32 bytes)
                let len := mload(data)

                // Skip over the length field.
                //
                // Keep temporary variable so it can be incremented in place.
                //
                // NOTE: incrementing data would result in an unusable
                //       data variable after this assembly block
                let dataElementLocation := add(data, 0x20)

                // Iterate until the bound is not met.
                for
                    { let end := add(dataElementLocation, mul(len, 0x20)) }
                    lt(dataElementLocation, end)
                    { dataElementLocation := add(dataElementLocation, 0x20) }
                {
                    sum := add(sum, mload(dataElementLocation))
                }
            }
        }
    }

.. index:: selector; of a function

Akses ke Variabel Eksternal, Fungsi dan library
-----------------------------------------------

Anda dapat mengakses variabel Solidity dan pengenal lainnya dengan menggunakan namanya.

Variabel lokal dari tipe nilai dapat langsung digunakan dalam inline assembly.
Keduanya dapat dibaca dan ditugaskan.

<<<<<<< HEAD
Variabel lokal yang merujuk ke memori mengevaluasi ke alamat variabel dalam memori bukan nilai itu sendiri.
Variabel tersebut juga dapat ditetapkan, tetapi perhatikan bahwa tugas hanya akan mengubah penunjuk dan bukan
data dan Anda bertanggung jawab untuk menghormati manajemen memori Solidity.
Lihat :ref:`Konvensi dalam Solidity <conventions-in-solidity>`.

Demikian pula, variabel lokal yang merujuk ke array calldata berukuran statis atau struct calldata
mengevaluasi ke alamat variabel dalam calldata, bukan nilai itu sendiri.
Variabel juga dapat diberi offset baru, tetapi perhatikan bahwa tidak ada validasi untuk memastikan
bahwa variabel tidak akan menunjuk ke luar ``calldatasize()`` yang dilakukan.

Untuk pointer fungsi eksternal, alamat dan pemilih fungsi dapat diakses menggunakan
``x.address`` dan ``x.selector``.
Pemilih terdiri dari empat byte rata kanan.
Kedua nilai tersebut dapat ditetapkan. Sebagai contoh:
=======
Local variables that refer to memory evaluate to the address of the variable in memory, not the value itself.
Such variables can also be assigned to, but note that an assignment will only change the pointer and not the data
and that it is your responsibility to respect Solidity's memory management.
See :ref:`Conventions in Solidity <conventions-in-solidity>`.

Similarly, local variables that refer to statically-sized calldata arrays or calldata structs
evaluate to the address of the variable in calldata, not the value itself.
The variable can also be assigned a new offset, but note that no validation is performed to ensure that
the variable will not point beyond ``calldatasize()``.

For external function pointers the address and the function selector can be
accessed using ``x.address`` and ``x.selector``.
The selector consists of four right-aligned bytes.
Both values can be assigned to. For example:
>>>>>>> english/develop

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.10 <0.9.0;

    contract C {
        // Assigns a new selector and address to the return variable @fun
        function combineToFunctionPointer(address newAddress, uint newSelector) public pure returns (function() external fun) {
            assembly {
                fun.selector := newSelector
                fun.address  := newAddress
            }
        }
    }

Untuk dynamic calldata arrays, Anda dapat mengakses offset data
panggilannya (dalam byte) dan panjangnya (jumlah elemen) menggunakan ``x.offset`` dan ``x.length``.
Kedua ekspresi juga dapat ditetapkan, tetapi untuk kasus statis, tidak ada validasi yang akan dilakukan
untuk memastikan bahwa area data yang dihasilkan berada dalam batas ``calldatasize()``.

Untuk variabel penyimpanan lokal atau variabel state, pengidentifikasi Yul tunggal
tidak cukup, karena mereka tidak selalu menempati satu slot penyimpanan penuh.
Oleh karena itu, "alamat" mereka terdiri dari slot dan byte-offset di dalam slot itu. Untuk mengambil slot
yang ditunjuk oleh variabel ``x``, Anda menggunakan ``x.slot``, dan untuk mengambil byte-offset Anda
menggunakan ``x.offset``. Menggunakan hanya ``x`` sendiri akan menghasilkan kesalahan.

Anda juga dapat menetapkan ke bagian ``.slot`` dari pointer variabel penyimpanan lokal.
Untuk ini (struct, array, atau pemetaan), bagian ``.offset`` selalu nol.
Namun, tidak mungkin untuk menetapkan bagian ``.slot`` atau ``.offset`` dari variabel status.

Variabel Solidity Lokal tersedia untuk assignment, misalnya:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract C {
        uint b;
        function f(uint x) public view returns (uint r) {
            assembly {
                // We ignore the storage slot offset, we know it is zero
                // in this special case.
                r := mul(x, sload(b.slot))
            }
        }
    }

.. warning::
    Jika Anda mengakses variabel dari jenis yang memiliki rentang kurang dari 256 bit
    (misalnya ``uint64``, ``address``, atau ``bytes16``),
    Anda tidak dapat membuat asumsi apa pun tentang bit yang bukan bagian
    pengkodean dari Tipe. Terutama, jangan menganggap mereka nol.
    Agar aman, selalu bersihkan data dengan benar sebelum Anda menggunakannya
    dalam konteks di mana ini penting:
    ``uint32 x = f(); assembly { x := and(x, 0xffffffff) /* now use x */ }``
    Untuk membersihkan tipe yang ditandatangani, Anda dapat menggunakan opcode ``signextend`` :
    ``assembly { signextend(<num_bytes_of_x_minus_one>, x) }``


<<<<<<< HEAD
Sejak Solidity 0.6.0 nama variabel inline assembly tidak boleh membayangi deklarasi apa pun
yang terlihat dalam lingkup blok inline assembly (termasuk deklarasi variabel, kontrak, dan fungsi).
=======
Since Solidity 0.6.0, the name of a inline assembly variable may not
shadow any declaration visible in the scope of the inline assembly block
(including variable, contract and function declarations).
>>>>>>> english/develop

Sejak Solidity 0.7.0, variabel dan fungsi yang dideklarasikan di dalam blok inline assembly mungkin
tidak berisi ``.``, tetapi menggunakan ``.`` valid untuk mengakses variabel Solidity dari luar blok
inline assembly.

Hal yang Harus Dihindari
------------------------

Inline assembly mungkin memiliki tampilan tingkat yang cukup tinggi, tetapi sebenarnya
sangat rendah. Panggilan fungsi, loop, ifs, dan switch dikonversi dengan aturan penulisan
ulang sederhana dan setelah itu, satu-satunya hal yang dilakukan assembler untuk Anda adalah
mengatur ulang gaya fungsional opcode , menghitung tinggi stack untuk
akses variabel dan menghapus slot stack untuk variabel assembly-local ketika
akhir blok telah tercapai.

.. _conventions-in-solidity:

Konvensi dalam Solidiy
-----------------------

<<<<<<< HEAD
Berbeda dengan EVM assembly, Solidity memiliki tipe yang lebih sempit dari 256 bit,
mis. ``uint24``. Untuk efisiensi, sebagian besar operasi aritmatika mengabaikan fakta bahwa
tipe dapat lebih pendek dari 256
bits, dan bit higher-order dibersihkan bila perlu,
yaitu, sesaat sebelum ditulis ke memori atau sebelum perbandingan dilakukan.
Ini berarti bahwa jika Anda mengakses variabel
seperti itu dari dalam inline assembly, Anda mungkin harus membersihkan bit tingkat tinggi secara manual terlebih
dahulu.

Solidity mengelola memori dengan cara berikut. Ada "free memory pointer"
di posisi ``0x40`` di memori. Jika Anda ingin mengalokasikan memori, gunakan memori
mulai dari titik penunjuk ini dan perbarui.
Tidak ada jaminan bahwa memori tersebut belum pernah digunakan sebelumnya dan dengan
demikian Anda tidak dapat berasumsi bahwa isinya adalah nol byte.
Tidak ada mekanisme bawaan untuk melepaskan atau membebaskan memori yang dialokasikan.
Berikut adalah assembly snippet yang dapat Anda gunakan untuk mengalokasikan memori yang mengikuti proses yang diuraikan di atas
=======
.. _assembly-typed-variables:

Values of Typed Variables
=========================

In contrast to EVM assembly, Solidity has types which are narrower than 256 bits,
e.g. ``uint24``. For efficiency, most arithmetic operations ignore the fact that
types can be shorter than 256
bits, and the higher-order bits are cleaned when necessary,
i.e., shortly before they are written to memory or before comparisons are performed.
This means that if you access such a variable
from within inline assembly, you might have to manually clean the higher-order bits
first.

.. _assembly-memory-management:

Memory Management
=================

Solidity manages memory in the following way. There is a "free memory pointer"
at position ``0x40`` in memory. If you want to allocate memory, use the memory
starting from where this pointer points at and update it.
There is no guarantee that the memory has not been used before and thus
you cannot assume that its contents are zero bytes.
There is no built-in mechanism to release or free allocated memory.
Here is an assembly snippet you can use for allocating memory that follows the process outlined above:
>>>>>>> english/develop

.. code-block:: yul

    function allocate(length) -> pos {
      pos := mload(0x40)
      mstore(0x40, add(pos, length))
    }

Memori 64 byte pertama dapat digunakan sebagai "scratch space" untuk
alokasi jangka pendek. 32 byte setelah free memory pointer (yaitu, mulai dari ``0x60``)
dimaksudkan untuk menjadi nol secara permanen dan digunakan sebagai nilai awal untuk
dynamic memory array kosong.
Ini berarti bahwa memori yang dapat dialokasikan dimulai pada ``0x80``, yang merupakan nilai awal
dari free memory pointer.

Elemen dalam array memori di Solidity selalu menempati kelipatan 32 byte (ini bahkan
berlaku untuk ``byte1[]``, tetapi tidak untuk ``byte`` dan ``string``). Array memori multi-dimensi
adalah pointer ke array memori. Panjang array dinamis disimpan pada
slot array pertama dan diikuti oleh elemen array.

.. warning::
<<<<<<< HEAD
    Statically-sized memory arrays tidak memiliki bidang panjang, tetapi mungkin akan
    ditambahkan nanti untuk memungkinkan konvertibilitas yang lebih baik antara array
    berukuran statis dan dinamis, jadi jangan mengandalkan ini.
=======
    Statically-sized memory arrays do not have a length field, but it might be added later
    to allow better convertibility between statically and dynamically-sized arrays; so,
    do not rely on this.

Memory Safety
=============

Without the use of inline assembly, the compiler can rely on memory to remain in a well-defined
state at all times. This is especially relevant for :ref:`the new code generation pipeline via Yul IR <ir-breaking-changes>`:
this code generation path can move local variables from stack to memory to avoid stack-too-deep errors and
perform additional memory optimizations, if it can rely on certain assumptions about memory use.

While we recommend to always respect Solidity's memory model, inline assembly allows you to use memory
in an incompatible way. Therefore, moving stack variables to memory and additional memory optimizations are,
by default, globally disabled in the presence of any inline assembly block that contains a memory operation
or assigns to Solidity variables in memory.

However, you can specifically annotate an assembly block to indicate that it in fact respects Solidity's memory
model as follows:

.. code-block:: solidity

    assembly ("memory-safe") {
        ...
    }

In particular, a memory-safe assembly block may only access the following memory ranges:

- Memory allocated by yourself using a mechanism like the ``allocate`` function described above.
- Memory allocated by Solidity, e.g. memory within the bounds of a memory array you reference.
- The scratch space between memory offset 0 and 64 mentioned above.
- Temporary memory that is located *after* the value of the free memory pointer at the beginning of the assembly block,
  i.e. memory that is "allocated" at the free memory pointer without updating the free memory pointer.

Furthermore, if the assembly block assigns to Solidity variables in memory, you need to assure that accesses to
the Solidity variables only access these memory ranges.

Since this is mainly about the optimizer, these restrictions still need to be followed, even if the assembly block
reverts or terminates. As an example, the following assembly snippet is not memory safe, because the value of
``returndatasize()`` may exceed the 64 byte scratch space:

.. code-block:: solidity

    assembly {
      returndatacopy(0, 0, returndatasize())
      revert(0, returndatasize())
    }

On the other hand, the following code *is* memory safe, because memory beyond the location pointed to by the
free memory pointer can safely be used as temporary scratch space:

.. code-block:: solidity

    assembly ("memory-safe") {
      let p := mload(0x40)
      returndatacopy(p, 0, returndatasize())
      revert(p, returndatasize())
    }

Note that you do not need to update the free memory pointer if there is no following allocation,
but you can only use memory starting from the current offset given by the free memory pointer.

If the memory operations use a length of zero, it is also fine to just use any offset (not only if it falls into the scratch space):

.. code-block:: solidity

    assembly ("memory-safe") {
      revert(0, 0)
    }

Note that not only memory operations in inline assembly itself can be memory-unsafe, but also assignments to
Solidity variables of reference type in memory. For example the following is not memory-safe:

.. code-block:: solidity

    bytes memory x;
    assembly {
      x := 0x40
    }
    x[0x20] = 0x42;

Inline assembly that neither involves any operations that access memory nor assigns to any Solidity variables
in memory is automatically considered memory-safe and does not need to be annotated.

.. warning::
    It is your responsibility to make sure that the assembly actually satisfies the memory model. If you annotate
    an assembly block as memory-safe, but violate one of the memory assumptions, this **will** lead to incorrect and
    undefined behavior that cannot easily be discovered by testing.

In case you are developing a library that is meant to be compatible across multiple versions
of Solidity, you can use a special comment to annotate an assembly block as memory-safe:

.. code-block:: solidity

    /// @solidity memory-safe-assembly
    assembly {
        ...
    }

Note that we will disallow the annotation via comment in a future breaking release; so, if you are not concerned with
backward-compatibility with older compiler versions, prefer using the dialect string.
>>>>>>> english/develop
