.. _inline-assembly:

###############
Inline Assembly
###############

.. index:: ! assembly, ! asm, ! evmasm


Anda dapat menyisipkan pernyataan Solidity dengan inline assembly dalam bahasa
yang mirip dengan salah satu mesin virtual Ethereum. Ini memberi Anda kontrol
yang lebih halus, yang sangat berguna saat Anda menyempurnakan bahasa dengan menulis library.

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
        function at(address _addr) public view returns (bytes memory o_code) {
            assembly {
                // retrieve the size of the code, this needs assembly
                let size := extcodesize(_addr)
                // allocate output byte array - this could also be done without assembly
                // by using o_code = new bytes(size)
                o_code := mload(0x40)
                // new "memory end" including padding
                mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                // store length in memory
                mstore(o_code, size)
                // actually retrieve the code, this needs assembly
                extcodecopy(_addr, add(o_code, 0x20), 0, size)
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
        function sumSolidity(uint[] memory _data) public pure returns (uint sum) {
            for (uint i = 0; i < _data.length; ++i)
                sum += _data[i];
        }

        // We know that we only access the array in bounds, so we can avoid the check.
        // 0x20 needs to be added to an array because the first slot contains the
        // array length.
        function sumAsm(uint[] memory _data) public pure returns (uint sum) {
            for (uint i = 0; i < _data.length; ++i) {
                assembly {
                    sum := add(sum, mload(add(add(_data, 0x20), mul(i, 0x20))))
                }
            }
        }

        // Same as above, but accomplish the entire code within inline assembly.
        function sumPureAsm(uint[] memory _data) public pure returns (uint sum) {
            assembly {
                // Load the length (first 32 bytes)
                let len := mload(_data)

                // Skip over the length field.
                //
                // Keep temporary variable so it can be incremented in place.
                //
                // NOTE: incrementing _data would result in an unusable
                //       _data variable after this assembly block
                let data := add(_data, 0x20)

                // Iterate until the bound is not met.
                for
                    { let end := add(data, mul(len, 0x20)) }
                    lt(data, end)
                    { data := add(data, 0x20) }
                {
                    sum := add(sum, mload(data))
                }
            }
        }
    }



Akses ke Variabel Eksternal, Fungsi dan library
-----------------------------------------------

Anda dapat mengakses variabel Solidity dan pengenal lainnya dengan menggunakan namanya.

Variabel lokal dari tipe nilai dapat langsung digunakan dalam inline assembly.
Keduanya dapat dibaca dan ditugaskan.

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


Sejak Solidity 0.6.0 nama variabel inline assembly tidak boleh membayangi deklarasi apa pun
yang terlihat dalam lingkup blok inline assembly (termasuk deklarasi variabel, kontrak, dan fungsi).

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
    Statically-sized memory arrays tidak memiliki bidang panjang, tetapi mungkin akan
    ditambahkan nanti untuk memungkinkan konvertibilitas yang lebih baik antara array
    berukuran statis dan dinamis, jadi jangan mengandalkan ini.
