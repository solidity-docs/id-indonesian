********************************
Solidity v0.5.0 Breaking Changes
********************************

Bagian ini menyoroti perubahan utama yang diperkenalkan di Solidity
versi 0.5.0, beserta alasan di balik perubahan dan cara memperbarui
kode yang terpengaruh.
Untuk daftar lengkap cek
`catatan perubahan rilis <https://github.com/ethereum/solidity/releases/tag/v0.5.0>`_.

.. note::
   Kontrak yang dikompilasi dengan Solidity v0.5.0 masih dapat berinteraksi dengan kontrak
   dan bahkan library yang dikompilasi dengan versi yang lebih lama tanpa mengkompilasi ulang atau
   memindahkan mereka. Mengubah antarmuka untuk menyertakan lokasi data dan
   penentu visibilitas dan mutabilitas sudah cukup. Lihat
   :ref:`Interoperabilitas Dengan Kontrak Lama <interoperabilitas>` bagian di bawah.

Perubahan Semantik Saja
=======================

Bagian ini mencantumkan perubahan yang hanya bersifat semantik, sehingga berpotensi
menyembunyikan perilaku baru dan berbeda dalam kode yang ada.

* Shift kanan bertanda sekarang menggunakan shift aritmatika yang tepat, yaitu pembulatan ke arah
  tak terhingga negatif, bukannya pembulatan menuju nol. Ditandatangani dan tidak ditandatangani
  shift akan memiliki opcode khusus di Konstantinopel, dan ditiru oleh
  Solidity untuk saat ini.

* Pernyataan ``continue`` dalam loop ``do... while`` sekarang melompat ke kondisi, yang
  merupakan perilaku umum dalam kasus tersebut. Itu digunakan untuk melompat ke
  tubuh loop. Jadi, jika kondisinya false, loop berakhir.

* Fungsi ``.call()``, ``.delegatecall()`` dan ``.staticcall()`` tidak
  pad lagi ketika diberi parameter ``byte`` tunggal.

* Fungsi Pure dan view sekarang dipanggil menggunakan opcode ``STATICCALL``
  alih-alih ``CALL`` jika versi EVM adalah Byzantium atau yang lebih baru. Ini
  tidak mengizinkan perubahan state pada level EVM.

* Encoder ABI sekarang menempatkan array byte dan string dengan benar dari calldata
  (``msg.data`` dan parameter fungsi eksternal) saat digunakan dalam panggilan
  fungsi eksternal dan di ``abi.encode``. Untuk unpadded encoding, gunakan
  ``abi.encodePacked``.`.

* Dekoder ABI kembali ke awal fungsi dan dalam
  ``abi.decode()`` jika data panggilan yang diteruskan terlalu pendek atau melampaui batas.
  Perhatikan bahwa bit order tertinggi yang kotor masih diabaikan begitu saja.

* Meneruskan semua gas yang tersedia dengan panggilan fungsi eksternal mulai dari
  Tangerine Whistle.

Perubahan Semantic dan Syntactic
================================

Bagian ini menyoroti perubahan yang memengaruhi sintaks dan semantik.

* Fungsi ``.call()``, ``.delegatecall()``, ``staticcall()``,
  ``keccak256()``, ``sha256()`` dan ``ripemd160()`` sekarang hanya menerima argumen
  single ``bytes``. Apalagi argumennya tidak di padded. Ini diubah untuk
  membuat lebih eksplisit dan jelas bagaimana argumen digabungkan. Mengubah setiap
  ``.call()`` (dan sejenisnya) menjadi ``.call("")`` dan setiap ``.call(signature, a,
  b, c)`` untuk menggunakan ``.call(abi.encodeWithSignature(signature, a, b, c))`` (yang
  terakhir hanya berfungsi untuk tipe nilai). Mengubah setiap ``keccak256(a, b, c)`` menjadi
  ``keccak256(abi.encodePacked(a, b, c))``. Meskipun itu bukan sebuah breaking
  change, developer disarankan untuk mengubah
  ``x.call(bytes4(keccak256("f(uint256)")), a, b)`` menjadi
  ``x.call(abi.encodeWithSignature("f(uint256)", a, b))``.

* Fungsi ``.call()``, ``.delegatecall()`` dan ``.staticcall()`` sekarang menghasilkan
  ``(bool, bytes memory)`` untuk memberikan akses ke return data.  Ubah
  ``bool success = otherContract.call("f")`` menjadi ``(bool success, bytes memory
  data) = otherContract.call("f")``.

* Solidity sekarang mengimplementasikan aturan C99-style scoping untuk fungsi variabel
  lokal, yaitu, variabel hanya dapat digunakan setelah mereka
  dideklarasikan dan hanya dalam lingkup yang sama atau netsted. Variabel yang dideklarasikan dalam
  blok inisialisasi dari loop ``for`` valid pada titik mana pun di dalam
  loop.

Persyaratan Eksplisititas
=========================

Bagian ini mencantumkan perubahan di mana kode sekarang perlu lebih eksplisit.
Untuk sebagian besar topik, kompiler akan memberikan saran.

* Visibilitas fungsi eksplisit sekarang wajib. Tambahkan ``public`` ke setiap
  fungsi dan konstruktor, dan ``external`` ke setiap fungsi fallback atau interface
  yang belum menentukan visibilitasnya.

* Lokasi data eksplisit untuk semua variabel tipe struct, array, atau mapping
  sekarang wajib. Ini juga diterapkan pada parameter fungsi dan variabel
  return. Misalnya, ubah ``uint[] x = m_x`` menjadi ``uint[] storage x =
  m_x``, dan ``function f(uint[][] x)`` menjadi ``function f(uint[ ][] memory x)``
  di mana ``memory`` adalah lokasi data dan dapat diganti dengan ``storage`` atau
  ``calldata`` yang sesuai. Perhatikan bahwa fungsi ``external`` memerlukan parameter
  dengan lokasi data ``calldata``.

* Jenis kontrak tidak lagi menyertakan anggota ``address``
  untuk memisahkan namespace. Oleh karena itu, sekarang perlu
  untuk secara eksplisit mengonversi nilai tipe kontrak ke alamat sebelum
  menggunakan anggota ``address``. Contoh: jika ``c`` adalah
  kontrak, ubah ``c.transfer(...)`` menjadi ``address(c).transfer(...)``,
  dan ``c.balance`` ke ``address(c).balance``.

* Konversi eksplisit antara jenis kontrak yang tidak terkait sekarang tidak diizinkan. Anda hanya
  dapat mengonversi dari jenis kontrak ke salah satu jenis basis atau ancestornya. Jika Anda yakin bahwa
  suatu kontrak kompatibel dengan jenis kontrak yang ingin Anda konversi, meskipun kontrak tersebut
  tidak mewarisi darinya, Anda dapat mengatasinya dengan mengonversi ke ``address`` terlebih dahulu.
  Contoh: jika ``A`` dan ``B`` adalah tipe kontrak, ``B`` tidak mewarisi dari ``A`` dan
  ``b`` adalah kontrak bertipe ``B``, Anda masih dapat mengonversi ``b`` untuk tipe ``A`` menggunakan ``A(address(b))``.
  Perhatikan bahwa Anda masih perlu berhati-hati untuk mencocokkan fungsi fallback payable, seperti yang dijelaskan di bawah ini.

* Jenis ``address`` dibagi menjadi ``address`` dan ``address payable``,
  di mana hanya ``address payable`` yang menyediakan fungsi ``transfer``. Sebuah
  ``Address payable`` dapat langsung dikonversi menjadi ``address``, tetapi
  sebaliknya tidak diperbolehkan. Konversi ``address`` ke ``address payable``
  dapat dilakukan melalui konversi melalui ``uint160``. Jika ``c`` adalah kontrak,
  ``address(c)`` menghasilkan ``address payable`` hanya jika ``c`` memiliki fungsi
  fallback payable. Jika Anda menggunakan :ref:`withdraw pattern<withdrawal_pattern>`,
  kemungkinan besar Anda tidak perlu mengubah kode karena ``transfer`` hanya digunakan pada ``msg.sender``
  alih-alih alamat tersimpan dan ``msg .sender`` adalah ``address payable``.

* Konversi antara ``bytesX`` dan ``uintY`` dengan ukuran berbeda sekarang tidak
  diizinkan karena pengisi ``bytesX`` di sebelah kanan dan pengisi ``uintY`` di sebelah kiri
  yang dapat menyebabkan hasil konversi yang tidak diharapkan. Ukuran sekarang
  harus disesuaikan dalam jenis sebelum konversi. Misalnya, Anda dapat mengonversi
  ``bytes4`` (4 byte) menjadi ``uint64`` (8 byte) dengan terlebih dahulu mengonversi variabel
  ``bytes4`` ke ``bytes8`` lalu ke ``uint64` `. Anda mendapatkan padding yang
  berlawanan saat mengonversi melalui ``uint32``. Sebelum v0.5.0 konversi apa pun
  antara ``bytesX`` dan ``uintY`` akan melalui ``uint8X``. Misalnya
  ``uint8(bytes3(0x291807))`` akan dikonversi menjadi ``uint8(uint24(bytes3(0x291807))``
  (hasilnya adalah ``0x07``).

* Menggunakan ``msg.value`` dalam non-payable fungsi (atau memperkenalkannya melalui
  modifier) tidak diizinkan sebagai fitur keamanan. Ubah fungsi menjadi ``payable``
  atau buat fungsi internal baru untuk logika program yang menggunakan
  ``msg.value``.

* Untuk alasan kejelasan, command line interface sekarang memerlukan ``-`` jika input
  standar digunakan sebagai sumber.

Elemen Usang
============

Bagian ini mencantumkan perubahan yang menghentikan fitur atau sintaks sebelumnya. Perhatikan bahwa
banyak dari perubahan ini sudah diaktifkan dalam mode eksperimental
``v0.5.0``.

Command Line dan JSON Interfaces
--------------------------------

* Opsi baris perintah ``--formal`` (digunakan untuk menghasilkan output Why3 untuk
  verifikasi formal lebih lanjut) tidak digunakan lagi dan sekarang dihapus. Modul verifikasi
  formal baru, SMTChecker, diaktifkan melalui ``pragma experimental SMTChecker;``.

* Opsi baris perintah ``--julia`` diubah namanya menjadi ``--yul`` karena
  penggantian nama bahasa perantara ``Julia`` menjadi ``Yul``.

* Opsi baris perintah ``--clone-bin`` dan ``--combined-json clone-bin`` telah dihapus.

* Remapping dengan awalan kosong tidak diizinkan.

* Kolom AST JSON ``constant`` dan ``payable`` telah dihapus. Informasi sekarang
  ada di bidang ``stateMutability``.

* Bidang JSON AST ``isConstructor`` dari simpul ``FunctionDefinition`` digantikan
  oleh bidang yang disebut ``kind`` yang dapat memiliki nilai ``"constructor"``, ``"fallback"``
  atau ``"function"``.

* Dalam file hex biner yang tidak ditautkan, placeholder alamat library sekarang menjadi
  36 karakter hex pertama dari hash keccak256 dari nama library yang sepenuhnya memenuhi
  syarat, dikelilingi oleh ``$...$``. Sebelumnya, hanya nama library yang sepenuhnya memenuhi
  syarat yang digunakan. Hal ini mengurangi kemungkinan tabrakan, terutama ketika jalur
  panjang digunakan. File biner sekarang juga berisi daftar mapping dari placeholder ini ke
  nama yang sepenuhnya memenuhi syarat.

Constructors
------------

* Konstruktor sekarang harus didefinisikan menggunakan kata kunci ``constructor``.

* Memanggil konstruktor dasar tanpa tanda kurung sekarang tidak diizinkan.

* Menentukan argumen konstruktor dasar beberapa kali dalam warisan yang sama
  hierarki sekarang tidak diizinkan.

* Memanggil konstruktor dengan argumen tetapi dengan jumlah argumen yang salah sekarang
  tidak diizinkan. Jika Anda hanya ingin menentukan relasi pewarisan tanpa
  memberikan argumen, tidak memberikan tanda kurung sama sekali.

Functions
---------

* Fungsi ``callcode`` sekarang tidak diizinkan (untuk kepentingan ``delegatecall``). Masih
  dimungkinkan untuk menggunakannya melalui perakitan

* ``suicide`` sekarang tidak diizinkan (untuk kepentingan ``selfdestruct``).

* ``sha3`` sekarang tidak diizinkan (untuk kepentingan ``keccak256``).

* ``throw`` sekarang tidak diizinkan (untuk kepentingan ``revert``, ``require`` dan
  ``assert``).

Conversions
-----------

* Konversi eksplisit dan implisit dari literal desimal ke tipe ``bytesXX`` sekarang tidak diizinkan.

* Konversi eksplisit dan implisit dari literal hex ke tipe ``bytesXX`` dengan ukuran berbeda sekarang tidak diizinkan.

Literals and Suffixes
---------------------

* Denominasi satuan ``years`` sekarang tidak diizinkan karena komplikasi dan
  kebingungan tentang tahun kabisat.

* Titik-titik trailing yang tidak diikuti oleh angka sekarang tidak diizinkan.

* Menggabungkan angka heksadesimal dengan denominasi satuan (mis. ``0x1e wei``) sekarang
  tidak diizinkan.

* Awalan ``0X`` untuk nomor hex tidak diizinkan, hanya ``0x`` yang dimungkinkan.

Variables
---------

* Mendeklarasikan struct kosong sekarang tidak diizinkan untuk kejelasan.

* Kata kunci ``var`` sekarang tidak diizinkan untuk mendukung ketegasan.

* Tugas antara tupel dengan jumlah komponen yang berbeda sekarang
  tidak diizinkan.

* Nilai untuk konstanta yang bukan konstanta compile-time tidak diizinkan.

* Deklarasi multi-variabel dengan jumlah nilai yang tidak cocok sekarang
  tidak diizinkan.

* Variabel penyimpanan yang tidak diinisialisasi sekarang tidak diizinkan.

* Komponen tuple kosong sekarang tidak diizinkan.

* Mendeteksi dependensi siklik dalam variabel dan struct terbatas di
  rekursi menjadi 256.

* Fixed-size array dengan panjang nol sekarang tidak diizinkan.

Syntax
------

* Menggunakan ``constant`` sebagai fungsi state mutability modifier sekarang tidak diizinkan.

* Ekspresi Boolean tidak dapat menggunakan operasi aritmatika.

* Operator ``+`` unary sekarang tidak diizinkan.

* Literal tidak dapat lagi digunakan dengan ``abi.encodePacked`` tanpa konversi sebelumnya ke tipe eksplisit.

* Return statement kosong untuk fungsi dengan satu atau lebih nilai pengembalian sekarang tidak diizinkan.

* Syntax "loose assembly" sekarang dilarang sama sekali, yaitu, jump labels,
  jumps dan non-functional instructions tidak dapat digunakan lagi. Gunakan konstruksi
  `` while``, ``switch`` dan ``if`` yang baru sebagai gantinya.

* Fungsi tanpa implementasi tidak dapat menggunakan modifier.

* Fungsi types dengan nama return values sekarang tidak diizinkan.

* Single statement variable declarations didalam tubuh if/while/for yang bukan
  block sekarang tidak diizinkan.

* Keywords baru: ``calldata`` dan ``constructor``.

* Keywords cadangan baru: ``alias``, ``apply``, ``auto``, ``copyof``,
  ``define``, ``immutable``, ``implements``, ``macro``, ``mutable``,
  ``override``, ``partial``, ``promise``, ``reference``, ``sealed``,
  ``sizeof``, ``supports``, ``typedef`` dan ``unchecked``.

.. _interoperability:

Interoperabilitas Dengan Kontrak Lama
=====================================

Masih dimungkinkan untuk berinteraksi dengan kontrak yang ditulis untuk versi Solidity sebelum
v0.5.0 (atau sebaliknya) dengan mendefinisikan antarmuka untuk mereka.
Pertimbangkan Anda memiliki kontrak pra-0.5.0 berikut yang sudah diterapkan:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.4.25;
    // This will report a warning until version 0.4.25 of the compiler
    // This will not compile after 0.5.0
    contract OldContract {
        function someOldFunction(uint8 a) {
            //...
        }
        function anotherOldFunction() constant returns (bool) {
            //...
        }
        // ...
    }

Ini tidak akan lagi dikompilasi dengan Solidity v0.5.0. Namun, Anda dapat menentukan antarmuka yang kompatibel untuknya:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    interface OldContract {
        function someOldFunction(uint8 a) external;
        function anotherOldFunction() external returns (bool);
    }

Perhatikan bahwa kami tidak mendeklarasikan ``anotherOldFunction`` sebagai ``view``, meskipun dinyatakan ``constant`` dalam
kontrak asli. Hal ini disebabkan oleh fakta bahwa dimulai dengan Solidity v0.5.0 ``staticcall`` digunakan untuk memanggil fungsi ``view``.
Sebelum v0.5.0 kata kunci ``constant`` tidak diterapkan, jadi memanggil fungsi yang dideklarasikan ``constant`` dengan ``staticcall``
masih dapat dikembalikan, karena fungsi ``constant`` mungkin masih mencoba mengubah penyimpanan. Akibatnya, ketika mendefinisikan suatu
antarmuka untuk kontrak lama, Anda hanya boleh menggunakan ``view`` sebagai ganti ``constant`` jika Anda benar-benar yakin bahwa
fungsi akan bekerja dengan ``staticcall``.

Dengan antarmuka yang ditentukan di atas, Anda sekarang dapat dengan mudah menggunakan kontrak pra-0.5.0 yang sudah diterapkan:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    interface OldContract {
        function someOldFunction(uint8 a) external;
        function anotherOldFunction() external returns (bool);
    }

    contract NewContract {
        function doSomething(OldContract a) public returns (bool) {
            a.someOldFunction(0x42);
            return a.anotherOldFunction();
        }
    }

Demikian pula, library pra-0.5.0 dapat digunakan dengan mendefinisikan fungsi library tanpa implementasi dan
memberikan alamat library pra-0.5.0 selama penautan (lihat :ref:`commandline-compiler` untuk cara menggunakan comamand line
kompiler untuk menautkan):

.. code-block:: solidity

    // This will not compile after 0.6.0
    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.5.0;

    library OldLibrary {
        function someFunction(uint8 a) public returns(bool);
    }

    contract NewContract {
        function f(uint8 a) public returns (bool) {
            return OldLibrary.someFunction(a);
        }
    }


Contoh
=======

Contoh berikut menunjukkan kontrak dan versi terbarunya untuk Solidity
v0.5.0 dengan beberapa perubahan yang tercantum di bagian ini.

Versi lama:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.4.25;
    // This will not compile after 0.5.0

    contract OtherContract {
        uint x;
        function f(uint y) external {
            x = y;
        }
        function() payable external {}
    }

    contract Old {
        OtherContract other;
        uint myNumber;

        // Function mutability not provided, not an error.
        function someInteger() internal returns (uint) { return 2; }

        // Function visibility not provided, not an error.
        // Function mutability not provided, not an error.
        function f(uint x) returns (bytes) {
            // Var is fine in this version.
            var z = someInteger();
            x += z;
            // Throw is fine in this version.
            if (x > 100)
                throw;
            bytes memory b = new bytes(x);
            y = -3 >> 1;
            // y == -1 (wrong, should be -2)
            do {
                x += 1;
                if (x > 10) continue;
                // 'Continue' causes an infinite loop.
            } while (x < 11);
            // Call returns only a Bool.
            bool success = address(other).call("f");
            if (!success)
                revert();
            else {
                // Local variables could be declared after their use.
                int y;
            }
            return b;
        }

        // No need for an explicit data location for 'arr'
        function g(uint[] arr, bytes8 x, OtherContract otherContract) public {
            otherContract.transfer(1 ether);

            // Since uint32 (4 bytes) is smaller than bytes8 (8 bytes),
            // the first 4 bytes of x will be lost. This might lead to
            // unexpected behavior since bytesX are right padded.
            uint32 y = uint32(x);
            myNumber += y + msg.value;
        }
    }

Versi baru:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.5.0;
    // This will not compile after 0.6.0

    contract OtherContract {
        uint x;
        function f(uint y) external {
            x = y;
        }
        function() payable external {}
    }

    contract New {
        OtherContract other;
        uint myNumber;

        // Function mutability must be specified.
        function someInteger() internal pure returns (uint) { return 2; }

        // Function visibility must be specified.
        // Function mutability must be specified.
        function f(uint x) public returns (bytes memory) {
            // The type must now be explicitly given.
            uint z = someInteger();
            x += z;
            // Throw is now disallowed.
            require(x <= 100);
            int y = -3 >> 1;
            require(y == -2);
            do {
                x += 1;
                if (x > 10) continue;
                // 'Continue' jumps to the condition below.
            } while (x < 11);

            // Call returns (bool, bytes).
            // Data location must be specified.
            (bool success, bytes memory data) = address(other).call("f");
            if (!success)
                revert();
            return data;
        }

        using address_make_payable for address;
        // Data location for 'arr' must be specified
        function g(uint[] memory /* arr */, bytes8 x, OtherContract otherContract, address unknownContract) public payable {
            // 'otherContract.transfer' is not provided.
            // Since the code of 'OtherContract' is known and has the fallback
            // function, address(otherContract) has type 'address payable'.
            address(otherContract).transfer(1 ether);

            // 'unknownContract.transfer' is not provided.
            // 'address(unknownContract).transfer' is not provided
            // since 'address(unknownContract)' is not 'address payable'.
            // If the function takes an 'address' which you want to send
            // funds to, you can convert it to 'address payable' via 'uint160'.
            // Note: This is not recommended and the explicit type
            // 'address payable' should be used whenever possible.
            // To increase clarity, we suggest the use of a library for
            // the conversion (provided after the contract in this example).
            address payable addr = unknownContract.make_payable();
            require(addr.send(1 ether));

            // Since uint32 (4 bytes) is smaller than bytes8 (8 bytes),
            // the conversion is not allowed.
            // We need to convert to a common size first:
            bytes4 x4 = bytes4(x); // Padding happens on the right
            uint32 y = uint32(x4); // Conversion is consistent
            // 'msg.value' cannot be used in a 'non-payable' function.
            // We need to make the function payable
            myNumber += y + msg.value;
        }
    }

    // We can define a library for explicitly converting ``address``
    // to ``address payable`` as a workaround.
    library address_make_payable {
        function make_payable(address x) internal pure returns (address payable) {
            return address(uint160(x));
        }
    }
