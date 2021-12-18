.. index:: abi, application binary interface

.. _ABI:

************************
Sepesifikasi Kontrak ABI
************************

Basic Design
============

Contract Application Binary Interface (ABI) adalah cara standar untuk berinteraksi dengan kontrak di ekosistem Ethereum, baik
dari luar blockchain maupun untuk interaksi kontrak-ke-kontrak. Data dikodekan menurut jenisnya,
seperti yang dijelaskan dalam spesifikasi ini. Pengkodean tidak menggambarkan diri sendiri dan dengan demikian memerlukan skema untuk memecahkan kode.

Kami menganggap fungsi antarmuka kontrak diketik dengan kuat, dikenal pada waktu kompilasi dan statis.
Kami berasumsi bahwa semua kontrak akan memiliki definisi antarmuka dari setiap kontrak yang mereka sebut tersedia pada waktu kompilasi.

Spesifikasi ini tidak membahas kontrak yang antarmukanya dinamis atau hanya diketahui saat run-time.

.. _abi_function_selector:
.. index:: selector

Fungsi Selector
===============

Empat byte pertama dari data panggilan untuk panggilan fungsi menentukan fungsi yang akan dipanggil. Ini adalah
yang pertama (kiri, orde tinggi dalam big-endian) empat byte hash Keccak-256 dari tanda tangan fungsi. Tanda tangan
didefinisikan sebagai ekspresi kanonik dari prototipe dasar tanpa penentu lokasi data, yaitu nama fungsi dengan daftar
tipe parameter yang dikurung. Jenis parameter dipisahkan dengan koma tunggal - tidak ada spasi yang digunakan.

.. note::
    Jenis kembalinya suatu fungsi bukan bagian dari tanda tangan ini. Di dalam
    :ref:`Pengembalian fungsi solidity yang berlebihan <overload-function>` tidak dipertimbangkan.
    Alasannya adalah untuk menjaga agar resolusi panggilan fungsi tidak bergantung pada konteks.
    Namun :ref:`JSON deskripsi ABI<abi_json>` berisi input dan output.

Argumen Encoding
================

Mulai dari byte kelima, argumen yang diencode-kan akan mengikuti. Pengkodean ini juga digunakan
di tempat lain, mis. nilai kembalian dan juga argumen event dikodekan dengan cara yang sama,
tanpa empat byte yang menentukan fungsi.

Types
=====

Ada tipe dasar berikut:

- ``uint<M>``: Tipe unsigned integer dari ``M`` bits, ``0 < M <= 256``, ``M % 8 == 0``. e.g. ``uint32``, ``uint8``, ``uint256``.

- ``int<M>``: tipe signed integer komplemen dua dari ``M`` bits, ``0 < M <= 256``, ``M % 8 == 0``.

- ``address``: setara dengan ``uint160``, kecuali untuk interpretasi asumsi dan pengetikan bahasa.
  Untuk menghitung pemilih fungsi, ``address`` digunakan.

- ``uint``, ``int``: sinonim untuk ``uint256``, ``int256`` berturutan. Untuk menghitung fungsi
  pemilih, ``uint256`` dan ``int256`` harus digunakan.

- ``bool``: setara dengan ``uint8`` terbatas pada nilai 0 dan 1. Untuk menghitung pemilih fungsi, ``bool`` digunakan.

- ``fixed<M>x<N>``: nomor desimal signed fixed-point dari ``M`` bits, ``8 <= M <= 256``,
  ``M % 8 == 0``, dan ``0 < N <= 80``, yang menunjukkan nilai ``v`` as ``v / (10 ** N)``.

- ``ufixed<M>x<N>``: unsigned varian dari ``fixed<M>x<N>``.

- ``fixed``, ``ufixed``: sinonim untuk ``fixed128x18``, ``ufixed128x18`` berturutan. Untuk
  menghitung pemilih fungsi, ``fixed128x18`` dan ``ufixed128x18`` harus digunakan.

- ``bytes<M>``: binary type dari ``M`` bytes, ``0 < M <= 32``.

- ``function``: sebuah address (20 bytes) diikuti oleh pemilih fungsi (4 bytes). Dikodekan identik dengan ``bytes24``.

Tipe array (fixed-size) berikut ini ada:

- ``<type>[M]``: fixed-length array dari ``M`` elements, ``M >= 0``, dari tipe yang diberikan.

  .. note::

      Meskipun spesifikasi ABI ini dapat mengekspresikan array dengan panjang tetap dengan elemen nol, mereka tidak didukung oleh kompiler.

Tipe Non-fixed-size berikut ini ada:

- ``bytes``: urutan byte berukuran dinamis.

- ``string``: string unicode berukuran dinamis diasumsikan dikodekan UTF-8.

- ``<type>[]``: array variabel-lenght elemen dari jenis yang diberikan.

Tipe dapat digabungkan ke tupel dengan melampirkannya di dalam tanda kurung, dipisahkan dengan koma:

- ``(T1,T2,...,Tn)``: tuple yang terdiri dari tipe ``T1``, ..., ``Tn``, ``n >= 0``

Hal ini dimungkinkan untuk membentuk tupel dari tupel, array dari tupel dan sebagainya. Dimungkinkan juga untuk membentuk tupel-nol (di mana ``n == 0``).

Mapping Solidity ke ABI types
-----------------------------

Solidity mendukung semua tipe yang disajikan di atas dengan nama
yang sama dengan pengecualian tupel. Di sisi lain, beberapa jenis Solidity
tidak didukung oleh ABI. Tabel berikut menunjukkan di kolom kiri Jenis solidity
yang bukan bagian dari ABI, dan di kolom kanan jenis ABI yang mewakilinya.

+-------------------------------+-----------------------------------------------------------------------------+
|      Solidity                 |                                           ABI                               |
+===============================+=============================================================================+
|:ref:`address payable<address>`|``address``                                                                  |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`contract<contracts>`     |``address``                                                                  |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`enum<enums>`             |``uint8``                                                                    |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`user defined value types |its underlying value type                                                    |
|<user-defined-value-types>`    |                                                                             |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`struct<structs>`         |``tuple``                                                                    |
+-------------------------------+-----------------------------------------------------------------------------+

.. warning::
    Sebelum versi ``0.8.0`` enum dapat memiliki lebih dari 256 anggota dan diwakili oleh
    tipe integer terkecil hanya cukup besar untuk menampung nilai dari setiap anggota.

Kriteria Desain untuk Encoding
==============================

Encoding dirancang untuk memiliki properti berikut, yang sangat berguna jika beberapa argumen adalah nested arrays:

1. Jumlah pembacaan yang diperlukan untuk mengakses nilai paling banyak adalah kedalaman nilai
   di dalam struktur array argumen, yaitu empat pembacaan diperlukan untuk mengambil ``a_i[k][l][r]``. Dalam
   versi ABI sebelumnya, jumlah pembacaan diskalakan secara linier dengan jumlah total parameter dinamis dalam
   kasus terburuk.

2. Data dari variabel atau elemen array tidak disisipkan dengan data lain dan itu adalah
   relocatable, yaitu hanya menggunakan "addresses" relatif.


Spesifikasi Formal Encoding
===========================

Kami membedakan tipe statis dan dinamis. Tipe statis dikodekan di tempat dan tipe dinamis adalah
dikodekan di lokasi yang dialokasikan secara terpisah setelah blok saat ini.

**Definisi:** Jenis berikut disebut "dynamic":

* ``bytes``
* ``string``
* ``T[]`` untuk ``T`` apa saja
* ``T[k]`` untuk ``T`` dinamis apa pun dan ``k >= 0`` apa pun
* ``(T1,...,Tk)`` jika ``Ti`` dinamis untuk beberapa ``1 <= i <= k``

Semua tipe lain disebut "static".

**Definisi:** ``len(a)`` adalah jumlah byte dalam string biner ``a``.
Jenis ``len(a)`` diasumsikan sebagai ``uint256``.

Kami mendefinisikan ``enc``, pengkodean aktual, sebagai mapping nilai tipe ABI ke string
biner sehingga ``len(enc(X))`` bergantung pada nilai ``X`` jika dan hanya jika tipe ``X`` dinamis.

**Definisi:** Untuk setiap nilai ABI ``X``, kami mendefinisikan ``enc(X)`` secara rekursif, bergantung
pada jenis ``X``

- ``(T1,...,Tk)`` for ``k >= 0`` dan tipe apa saja ``T1``, ..., ``Tk``

  ``enc(X) = head(X(1)) ... head(X(k)) tail(X(1)) ... tail(X(k))``

  dimana ``X = (X(1), ..., X(k))`` dan
  ``head`` dan ``tail`` didefinisikan untuk ``Ti`` sebagai berikut:

  jika ``Ti`` adalah static:

    ``head(X(i)) = enc(X(i))`` dan ``tail(X(i)) = ""`` (string kosong)

  jika tidak, atau jika ``It`` dinamis:

    ``head(X(i)) = enc(len( head(X(1)) ... head(X(k)) tail(X(1)) ... tail(X(i-1)) ))``
    ``tail(X(i)) = enc(X(i))``

  Perhatikan bahwa dalam kasus dinamis, ``head(X(i))`` didefinisikan dengan baik karena panjang
  bagian head hanya bergantung pada jenisnya dan bukan nilainya. Nilai ``head(X(i))`` adalah
  offset dari awal ``tail(X(i))`` relatif terhadap awal ``enc(X)``.

- ``T[k]`` untuk ``T`` apa saja dan ``k``:

  ``enc(X) = enc((X[0], ..., X[k-1]))``

  yaitu dikodekan seolah-olah itu adalah tuple dengan elemen ``k``
  dari jenis yang sama.

- ``T[]`` dimana ``X`` mempunyai elemen ``k`` (``k`` diasumsikan bertipe ``uint256``):

  ``enc(X) = enc(k) enc([X[0], ..., X[k-1]])``

  yaitu dikodekan seolah-olah itu adalah array ukuran statis ``k``, diawali dengan
  jumlah elemen.

- ``bytes``, panjang dari ``k`` (yang diasumsikan bertipe ``uint256``):

  ``enc(X) = enc(k) pad_right(X)``, yaitu jumlah byte dikodekan sebagai
  ``uint256`` diikuti dengan nilai aktual ``X`` sebagai urutan byte, diikuti oleh
  jumlah minimum nol-byte sehingga ``len(enc(X))`` adalah kelipatan 32.

- ``string``:

  ``enc(X) = enc(enc_utf8(X))``, yaitu ``X`` dikodekan UTF-8 dan nilai ini ditafsirkan
  pada tipe ``byte`` dan dikodekan lebih lanjut. Perhatikan bahwa panjang yang digunakan dalam encoding
  berikut ini adalah jumlah byte dari string yang disandikan UTF-8, bukan jumlah karakternya.

- ``uint<M>``: ``enc(X)`` adalah pengkodean big-endian dari ``X``, diisi pada tingkat yang lebih tinggi
   (kiri) dengan nol-byte sehingga panjangnya 32 byte.
- ``alamat``: seperti dalam kasus ``uint160``
- ``int<M>``: ``enc(X)`` adalah pengkodean komplemen dua big-endian dari ``X``, diisi di sisi orde tinggi (kiri) dengan byte ``0xff`` untuk ``X`` negatif dan dengan nol-byte untuk ``X`` non-negatif sehingga panjangnya adalah 32 byte.
- ``bool``: seperti dalam kasus ``uint8``, di mana ``1`` digunakan untuk ``true`` dan ``0`` untuk ``false``
- ``fixed<M>x<N>``: ``enc(X)`` adalah ``enc(X * 10**N)`` di mana ``X * 10**N`` diinterpretasikan sebagai sebuah ``int256``.
- ``fixed``: seperti pada kasus ``fixed128x18``
- ``ufixed<M>x<N>``: ``enc(X)`` adalah ``enc(X * 10**N)`` di mana ``X * 10**N`` diinterpretasikan sebagai sebuah ``uint256``.
- ``ufixed``: seperti dalam kasus ``ufixed128x18``
- ``bytes<M>``: ``enc(X)`` adalah urutan byte dalam ``X`` yang diisi dengan trailing nol-byte hingga panjang 32 byte.

Perhatikan bahwa untuk setiap ``X``, ``len(enc(X))`` adalah kelipatan 32.

Fungsi Selector dan Argumen Encoding
====================================

Secara keseluruhan, panggilan ke fungsi ``f`` dengan parameter ``a_1, ..., a_n`` dikodekan sebagai

  ``function_selector(f) enc((a_1, ..., a_n))``

dan menghasilkan nilai ``v_1, ..., v_k`` dari ``f`` di encoded sebagai

  ``enc((v_1, ..., v_k))``

yaitu nilai-nilai digabungkan menjadi tupel dan dikodekan.

Contoh
======

Diberikan kontrak:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Foo {
        function bar(bytes3[2] memory) public pure {}
        function baz(uint32 x, bool y) public pure returns (bool r) { r = x > 32 || y; }
        function sam(bytes memory, bool, uint[] memory) public pure {}
    }


Jadi untuk contoh ``Foo`` kita jika kita ingin memanggil ``baz`` dengan parameter ``69`` dan
``true``, kita akan melewati total 68 byte, yang dapat dipecah menjadi:

- ``0xcdcd77c0``: ID Metode. Ini diturunkan sebagai 4 byte pertama hash Keccak dari
  bentuk ASCII dari tanda tangan ``baz(uint32,bool)``.
- ``0x00000000000000000000000000000000000000000000000000000000000045``: parameter pertama,
  nilai uint32 ``69`` diisi hingga 32 byte
- ``0x0000000000000000000000000000000000000000000000000000000000001``: parameter kedua - boolean
  ``true``, diisi hingga 32 byte

Secara keseluruhan:

.. code-block:: none

    0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001

Ini mengembalikan satu ``bool``. Jika, misalnya, mengembalikan ``false``, outputnya adalah
array byte tunggal ``0x0000000000000000000000000000000000000000000000000000000000000000``, satu bool.

Jika kita ingin memanggil ``bar`` dengan argumen ``["abc", "def"]``, kita akan melewati total 68 byte, dipecah menjadi:

- ``0xfce353f6``: ID Metode. Ini diturunkan dari tanda tangan ``bar(bytes3[2])``.
- ``0x6162630000000000000000000000000000000000000000000000000000000000``: bagian pertama dari yang pertama
  parameter, nilai ``bytes3`` ``"abc"`` (rata kiri).
- ``0x64656600000000000000000000000000000000000000000000000000000000000``: bagian kedua dari yang pertama
  parameter, nilai ``bytes3`` ``"def"`` (rata kiri).

Secara keseluruhan:

.. code-block:: none

    0xfce353f661626300000000000000000000000000000000000000000000000000000000006465660000000000000000000000000000000000000000000000000000000000

Jika kita ingin memanggil ``sam`` dengan argumen ``"dave"``, ``true`` dan ``[1,2,3]``, kita akan
melewati total 292 byte, dipecah menjadi:

- ``0xa5643bf2``: ID Metode. Ini diturunkan dari tanda tangan ``sam(bytes,bool,uint256[])``. Perhatikan bahwa ``uint`` diganti dengan representasi kanoniknya ``uint256``.
- ``0x00000000000000000000000000000000000000000000000000000000000060``: lokasi bagian data dari parameter pertama (tipe dinamis), diukur dalam byte dari awal blok argumen. Dalam hal ini, ``0x60``.
- ``0x00000000000000000000000000000000000000000000000000000000000000001``: parameter kedua: boolean true.
- ``0x000000000000000000000000000000000000000000000000000000000000a0``: lokasi bagian data dari parameter ketiga (tipe dinamis), diukur dalam byte. Dalam hal ini, ``0xa0``.
- ``0x00000000000000000000000000000000000000000000000000000000000000004``: bagian data dari argumen pertama, dimulai dengan panjang array byte dalam elemen, dalam hal ini, 4.
- ``0x64617665000000000000000000000000000000000000000000000000000000000``: isi argumen pertama: pengkodean UTF-8 (sama dengan ASCII dalam kasus ini) dari ``"dave"``, diisi di sebelah kanan hingga 32 byte.
- ``0x00000000000000000000000000000000000000000000000000000000000000003``: bagian data dari argumen ketiga, dimulai dengan panjang array dalam elemen, dalam hal ini, 3.
- ``0x00000000000000000000000000000000000000000000000000000000000001``: entri pertama dari parameter ketiga.
- ``0x00000000000000000000000000000000000000000000000000000000000000002``: entri kedua dari parameter ketiga.
- ``0x00000000000000000000000000000000000000000000000000000000000000003``: entri ketiga dari parameter ketiga.

Secara keseluruhan:

.. code-block:: none

    0xa5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003

penggunaan Dynamic Types
========================

Panggilan ke fungsi dengan tanda tangan ``f(uint,uint32[],byte10,bytes)`` dengan nilai
``(0x123, [0x456, 0x789], "1234567890", "Hello, world!")`` dikodekan dengan cara berikut:

Kami mengambil empat byte pertama dari ``sha3("f(uint256,uint32[],bytes10,bytes)")``, yaitu ``0x8be65246``.
Kemudian kami mengkodekan bagian kepala dari keempat argumen. Untuk tipe statis ``uint256`` dan ``bytes10``,
ini adalah nilai yang ingin kita sampaikan secara langsung, sedangkan untuk tipe dinamis ``uint32[]`` dan ``byte``,
kami menggunakan offset dalam byte ke awal area datanya, diukur dari awal nilainya
encoding (yaitu tidak menghitung empat byte pertama yang berisi hash dari tanda tangan fungsi). Ini adalah:

- ``0x0000000000000000000000000000000000000000000000000000000000000000123`` (``0x123`` diisi hingga 32 byte)
- ``0x00000000000000000000000000000000000000000000000000000000000000080`` (offset untuk memulai bagian data dari parameter kedua, 4*32 byte, persis ukuran bagian kepala)
- ``0x31323334353637383930000000000000000000000000000000000000000000000`` (``"1234567890"`` diisi hingga 32 byte di sebelah kanan)
- ``0x000000000000000000000000000000000000000000000000000000000000e0`` (offset untuk memulai bagian data dari parameter keempat = offset untuk memulai bagian data dari parameter dinamis pertama + ukuran bagian data dari parameter dinamis pertama = 4\*32 + 3\*32 (lihat di bawah) )

Setelah ini, bagian data dari argumen dinamis pertama, ``[0x456, 0x789]`` berikut:

- ``0x00000000000000000000000000000000000000000000000000000000000000002`` (jumlah elemen array, 2)
- ``0x000000000000000000000000000000000000000000000000000000000000456`` (elemen pertama)
- ``0x0000000000000000000000000000000000000000000000000000000000000789`` (elemen kedua)

Terakhir, kami mengkodekan bagian data dari argumen dinamis kedua, ``"Hello, world!"``:

- ``0x0000000000000000000000000000000000000000000000000000000000000000d`` (jumlah elemen (byte dalam hal ini): 13)
- ``0x48656c6c6f2c20776f726c642100000000000000000000000000000000000000`` (``"Hello, world!"`` diisi hingga 32 byte di sebelah kanan)

Secara keseluruhan, encoding adalah (baris baru setelah pemilih fungsi dan masing-masing 32-byte untuk kejelasan):

.. code-block:: none

    0x8be65246
      0000000000000000000000000000000000000000000000000000000000000123
      0000000000000000000000000000000000000000000000000000000000000080
      3132333435363738393000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000e0
      0000000000000000000000000000000000000000000000000000000000000002
      0000000000000000000000000000000000000000000000000000000000000456
      0000000000000000000000000000000000000000000000000000000000000789
      000000000000000000000000000000000000000000000000000000000000000d
      48656c6c6f2c20776f726c642100000000000000000000000000000000000000

Mari kita terapkan prinsip yang sama untuk mengkodekan data untuk suatu fungsi dengan tanda tangan ``g(uint[][],string[])``
dengan nilai ``([[1, 2], [3]], ["satu", "dua", "tiga"])`` tetapi mulai dari bagian pengkodean yang paling atomik:

Pertama kita mengkodekan panjang dan data dari larik dinamis tertanam pertama ``[1, 2]`` dari larik akar pertama ``[[1, 2], [3]]``:

- ``0x00000000000000000000000000000000000000000000000000000000000000002`` (jumlah elemen dalam larik pertama, 2; elemen itu sendiri adalah ``1`` dan ``2``)
- ``0x00000000000000000000000000000000000000000000000000000000000000001`` (elemen pertama)
- ``0x00000000000000000000000000000000000000000000000000000000000000002`` (elemen kedua)

Kemudian kami menyandikan panjang dan data larik dinamis tertanam kedua ``[3]`` dari larik akar pertama ``[[1, 2], [3]]``:

- ``0x00000000000000000000000000000000000000000000000000000000000000001`` (jumlah elemen dalam larik kedua, 1; elemennya adalah ``3``)
- ``0x00000000000000000000000000000000000000000000000000000000000000003`` (elemen pertama)

Kemudian kita perlu mencari offset ``a`` dan ``b`` untuk array dinamis masing-masing ``[1, 2]`` dan ``[3]``.
Untuk menghitung offset, kita dapat melihat data yang dikodekan dari larik akar pertama ``[[[1, 2], [3]]``
menghitung setiap baris dalam pengkodean:

.. code-block:: none

    0 - a                                                                - offset of [1, 2]
    1 - b                                                                - offset of [3]
    2 - 0000000000000000000000000000000000000000000000000000000000000002 - count for [1, 2]
    3 - 0000000000000000000000000000000000000000000000000000000000000001 - encoding of 1
    4 - 0000000000000000000000000000000000000000000000000000000000000002 - encoding of 2
    5 - 0000000000000000000000000000000000000000000000000000000000000001 - count for [3]
    6 - 0000000000000000000000000000000000000000000000000000000000000003 - encoding of 3

Offset ``a`` menunjuk ke awal konten array ``[1, 2]`` yang merupakan baris
2 (64 byte); jadi ``a = 0x00000000000000000000000000000000000000000000000000000000000000040``.

Offset ``b`` menunjuk ke awal konten larik ``[3]`` yaitu baris 5 (160 byte);
jadi ``b = 0x0000000000000000000000000000000000000000000000000000000000000000a0``.


Kemudian kami menyandikan string yang disematkan dari larik root kedua:

- ``0x00000000000000000000000000000000000000000000000000000000000000003`` (jumlah karakter dalam kata ``"one"``)
- ``0x6f6e650000000000000000000000000000000000000000000000000000000000`` (utf8 representasi dari kata ``"satu"``)
- ``0x00000000000000000000000000000000000000000000000000000000000000003`` (jumlah karakter dalam kata ``"dua"``)
- ``0x74776f00000000000000000000000000000000000000000000000000000000000`` (utf8 representasi kata ``"dua"``)
- ``0x00000000000000000000000000000000000000000000000000000000000000005`` (jumlah karakter dalam kata ``"three"``)
- ``0x7468726565000000000000000000000000000000000000000000000000000000`` (utf8 representasi kata ``"three"``)

Sejalan dengan larik root pertama, karena string adalah elemen dinamis, kita perlu menemukan offsetnya ``c``, ``d`` dan ``e``:

.. code-block:: none

    0 - c                                                                - offset for "one"
    1 - d                                                                - offset for "two"
    2 - e                                                                - offset for "three"
    3 - 0000000000000000000000000000000000000000000000000000000000000003 - count for "one"
    4 - 6f6e650000000000000000000000000000000000000000000000000000000000 - encoding of "one"
    5 - 0000000000000000000000000000000000000000000000000000000000000003 - count for "two"
    6 - 74776f0000000000000000000000000000000000000000000000000000000000 - encoding of "two"
    7 - 0000000000000000000000000000000000000000000000000000000000000005 - count for "three"
    8 - 7468726565000000000000000000000000000000000000000000000000000000 - encoding of "three"

Offset ``c`` menunjuk ke awal konten string ``"satu"`` yaitu baris 3 (96 byte);
jadi ``c = 0x000000000000000000000000000000000000000000000000000000000000000060``.

Offset ``d`` menunjuk ke awal konten string ``"dua"`` yaitu baris 5 (160 byte);
jadi ``d = 0x0000000000000000000000000000000000000000000000000000000000000000a0``.

Offset ``e`` menunjuk ke awal konten string ``"three"`` yaitu baris 7 (224 byte);
jadi ``e = 0x000000000000000000000000000000000000000000000000000000000000000e0``.


Perhatikan bahwa pengkodean elemen tertanam dari array root tidak bergantung satu sama lain
dan memiliki penyandian yang sama untuk fungsi dengan tanda tangan ``g(string[],uint[][])``.

Kemudian kami menyandikan panjang array root pertama:

- ``0x00000000000000000000000000000000000000000000000000000000000000002`` (jumlah elemen dalam larik akar pertama, 2; elemen itu sendiri adalah ``[1, 2]`` dan ``[3]``)

Kemudian kami menyandikan panjang larik root kedua:

- ``0x00000000000000000000000000000000000000000000000000000000000000003`` (jumlah string dalam larik akar kedua, 3; string itu sendiri adalah ``"satu"``, ``"dua"`` dan ``"tiga"``)

Akhirnya kita menemukan offset ``f`` dan ``g`` untuk masing-masing root dynamic array ``[[[1, 2], [3]]`` dan
``["satu", "dua", "tiga"]``, dan merakit bagian dalam urutan yang benar:

.. code-block:: none

    0x2289b18c                                                            - function signature
     0 - f                                                                - offset of [[1, 2], [3]]
     1 - g                                                                - offset of ["one", "two", "three"]
     2 - 0000000000000000000000000000000000000000000000000000000000000002 - count for [[1, 2], [3]]
     3 - 0000000000000000000000000000000000000000000000000000000000000040 - offset of [1, 2]
     4 - 00000000000000000000000000000000000000000000000000000000000000a0 - offset of [3]
     5 - 0000000000000000000000000000000000000000000000000000000000000002 - count for [1, 2]
     6 - 0000000000000000000000000000000000000000000000000000000000000001 - encoding of 1
     7 - 0000000000000000000000000000000000000000000000000000000000000002 - encoding of 2
     8 - 0000000000000000000000000000000000000000000000000000000000000001 - count for [3]
     9 - 0000000000000000000000000000000000000000000000000000000000000003 - encoding of 3
    10 - 0000000000000000000000000000000000000000000000000000000000000003 - count for ["one", "two", "three"]
    11 - 0000000000000000000000000000000000000000000000000000000000000060 - offset for "one"
    12 - 00000000000000000000000000000000000000000000000000000000000000a0 - offset for "two"
    13 - 00000000000000000000000000000000000000000000000000000000000000e0 - offset for "three"
    14 - 0000000000000000000000000000000000000000000000000000000000000003 - count for "one"
    15 - 6f6e650000000000000000000000000000000000000000000000000000000000 - encoding of "one"
    16 - 0000000000000000000000000000000000000000000000000000000000000003 - count for "two"
    17 - 74776f0000000000000000000000000000000000000000000000000000000000 - encoding of "two"
    18 - 0000000000000000000000000000000000000000000000000000000000000005 - count for "three"
    19 - 7468726565000000000000000000000000000000000000000000000000000000 - encoding of "three"

Offset ``f`` menunjuk ke awal isi array ``[[1, 2], [3]]`` yang merupakan baris 2 (64 byte);
jadi ``f = 0x00000000000000000000000000000000000000000000000000000000000000040``.

Offset ``g`` menunjuk ke awal konten larik ``["satu", "dua", "tiga"]`` yang merupakan baris 10 (320 byte);
jadi ``g = 0x0000000000000000000000000000000000000000000000000000000000000140``.

.. _abi_events:

Events
======

Event adalah abstraksi dari protokol logging/event-watching Ethereum. Entri log menyediakan alamat
kontrak, serangkaian hingga empat topik dan beberapa arbitrary length binary data. Event memanfaatkan fungsi ABI yang
ada untuk menafsirkan ini (bersama dengan spesifikasi interface) sebagai struktur yang diketik dengan benar.

Diberikan nama peristiwa dan rangkaian parameter peristiwa, kami membaginya menjadi dua sub-seri: yang diindeks dan yang tidak.
Mereka yang diindeks, yang mungkin berjumlah hingga 3 (untuk event non-anonim) atau 4 (untuk yang anonim), digunakan
di samping hash Keccak dari tanda tangan event untuk membentuk topik entri log.
Mereka yang tidak diindeks membentuk array byte dari event tersebut.

Akibatnya, entri log menggunakan ABI ini dijelaskan sebagai:

- ``address``: alamat kontrak (secara intrinsik disediakan oleh Ethereum);
- ``topics[0]``: ``keccak(EVENT_NAME+"("+EVENT_ARGS.map(canonical_type_of).join(",")+")")`` (``canonical_type_of``
  adalah fungsi yang hanya mengembalikan tipe kanonik dari argumen yang diberikan, mis. untuk ``uint indexed foo``, itu akan
  kembali ``uint256``). Nilai ini hanya ada di ``topik[0]`` jika event tidak dideklarasikan sebagai ``anonymous``;
- ``topics[n]``: ``abi_encode(EVENT_INDEXED_ARGS[n - 1])`` jika event tidak dideklarasikan sebagai ``anonymous``
  atau ``abi_encode(EVENT_INDEXED_ARGS[n])`` jika memang (``EVENT_INDEXED_ARGS`` adalah rangkaian ``EVENT_ARGS`` yang
  diindeks);
- ``data``: ABI encoding dari ``EVENT_NON_INDEXED_ARGS`` (``EVENT_NON_INDEXED_ARGS`` adalah rangkaian dari ``EVENT_ARGS``
  yang tidak diindeks, ``abi_encode`` adalah fungsi pengkodean ABI yang digunakan untuk mengembalikan serangkaian nilai yang diketik
  dari suatu fungsi, seperti dijelaskan di atas).

Untuk semua jenis panjang paling banyak 32 byte, array ``EVENT_INDEXED_ARGS`` berisi
nilai secara langsung, diisi atau diperpanjang tanda (untuk signed integer) hingga 32 byte, sama seperti pengkodean ABI biasa.
Namun, untuk semua tipe "kompleks" atau tipe panjang dinamis, termasuk semua array, ``string``, ``bytes`` dan struct,
``EVENT_INDEXED_ARGS`` akan berisi *Keccak hash* dari nilai khusus yang dikodekan di tempat
(lihat :ref:`indexed_event_encoding`), daripada nilai yang disandikan secara langsung.
Ini memungkinkan aplikasi untuk secara efisien menanyakan nilai tipe dynamic-length
(dengan menetapkan hash dari nilai yang disandikan sebagai topik), tetapi membuat aplikasi tidak dapat
untuk memecahkan kode nilai yang diindeks yang belum mereka tanyakan. Untuk tipe dynamic-length,
pengembang aplikasi menghadapi trade-off antara pencarian cepat untuk nilai yang telah ditentukan
(jika argumen diindeks) dan keterbacaan nilai arbitrer (yang mengharuskan
argumen tidak diindeks). Pengembang dapat mengatasi tradeoff ini dan mencapai pencarian keduanya
yang efisien dan keterbacaan arbitrer dengan mendefinisikan peristiwa dengan dua argumen — satu
diindeks, satu tidak — dimaksudkan untuk memiliki nilai yang sama.

.. _abi_errors:

Errors
======

Dlam kasus sebuah kegagalan dalam kontrak, kontrak dapat menggunakan spesial opcode untuk membatalkan eksekusi dan mengebalikan
semua perubahan state. Sebagai tambahan ke efek ini, deskripsi data dapat dikembalikan ke pemanggil.
Deskripsi data ini adalah encoding dari sebuah eror dan argumennya dalam cara yang sama dengan data untuk sebuah
panggilan fungsi.

Sebagai contoh, mari kita pertimbangkan kontrak berikut dimana fungsi ``transfer`` selalu
dikembalikan dengan custom eror "insufficient balance"

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract TestToken {
        error InsufficientBalance(uint256 available, uint256 required);
        function transfer(address /*to*/, uint amount) public pure {
            revert InsufficientBalance(0, amount);
        }
    }

Data yang dihasilkan akan di encoded dengan cara yang sama dengan fungsi panggilan
``InsufficientBalance(0, amount)`` ke fungsi ``InsufficientBalance(uint256,uint256)``,
i.e. ``0xcf479181``, ``uint256(0)``, ``uint256(amount)``.

Eror selektor ``0x00000000`` dan ``0xffffffff`` dicadangkan untuk penggunaan dimasa mendatang.

.. warning::
    Jangan pernah percaya data error.
    Data eror secara default *bubbles up* melalui chain dari panggilan eksternal, yang
    berarti kontrak tersebut mungkin menerima eror tidak ditetapkan di kontrak manapun
    yang dipanggil secara langsung.
    Lebih lanjut, kontrak apapun dapat memalsukan eror dengan mengembalikan data yang cocok
    dengan eror signature, meski jika eror tidak didefinisikan dimanapun.

.. _abi_json:

JSON
====

Format JSON untuk kontrak interface diberikan oleh sebuah array dari deskripsi fungsi, event dan error.
Deskripsi fungsi adalah sebuah objek JSON dengan:

- ``type``: ``"function"``, ``"constructor"``, ``"receive"`` (:ref:`fungsi "receive Ether" <receive-ether-function>`) atau ``"fallback"`` (:ref:`fungsi "default" <fallback-function>`);
- ``name``: nama dari fungsi;
- ``inputs``: sebuah array dari ojek, masing-masing yang berisi:

  * ``name``: nama parameter.
  * ``type``: tipe canonical dari parameter (lebih lanjut dibawah).
  * ``components``: digunakan untuk tuple types (lebih lanjut dibawah).

- ``outputs``: sebuah array dari objek mirip dengan ``inputs``.
- ``stateMutability``: string dengan salah satu nilai berikut: ``pure`` (:ref:`specified to not read
  blockchain state <pure-functions>`), ``view`` (:ref:`specified to not modify the blockchain
  state <view-functions>`), ``nonpayable`` (fungsi yang tidak menerima Ether - default) dan ``payable`` (fungsi yang menerima Ether).

Konstruktor dan fungi fallback tidak pernah memiliki ``name`` atau ``output``. Fungsi fallback juga tidak memiliki ``input``.

.. note::
    Mengirim non-zero Ether ke fungsi non-payable akan menggagalkan transaksi.

.. note::
    State mutability ``nonpayable`` direfleksikan di Solidity dengan tidak menentukan
    state mutability modifier sama sekali.

Deskripsi sebuah event adalah objek JSON dengan bidang yang cukup mirip:

- ``type``: Selalu ``"event"``
- ``name``: nama dari event.
- ``inputs``: sebuah array dari objek, masing-masing yang berisi:

  * ``name``: nama dari parameter.
  * ``type``: tipe canonical dari parameter (lebih lanjut dibawah).
  * ``components``: digunakan untuk tuple types (lebih lanjut dibawah).
  * ``indexed``: ``true``jika bidang tersebut adalah bagian dari topik log, ``false`` jika itu salah satu segmen data log.

- ``anonymous``: ``true`` jika event dideklarasikan sebgai ``anonymous``.

Errors terlihat sebagai berikut:

- ``type``: selalu ``"error"``
- ``name``: nama dari error.
- ``inputs``: an array of objects, each of which contains:

  * ``name``: nama dari parameter.
  * ``type``: tipe canonical dari parameter (lebih lanjut dibawah).
  * ``components``: digunakan untuk tuple types (lebih lanjut dibawah).

.. note::

  Mungkin ada beberapa kesalahan dengan nama yang sama dan bahkan dengan
  tanda tangan yang identik dalam array JSON, misalnya jika kesalahan berasal
  dari file yang berbeda dalam kontrak pintar atau direferensikan dari smart kontrak lain.
  Untuk ABI, hanya nama kesalahan itu sendiri yang relevan dan bukan di mana itu didefinisikan.


Sebagai contoh,

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;


    contract Test {
        constructor() { b = hex"12345678901234567890123456789012"; }
        event Event(uint indexed a, bytes32 b);
        event Event2(uint indexed a, bytes32 b);
        error InsufficientBalance(uint256 available, uint256 required);
        function foo(uint a) public { emit Event(a, b); }
        bytes32 b;
    }

akan menghasilkan JSON:

.. code-block:: json

    [{
    "type":"error",
    "inputs": [{"name":"available","type":"uint256"},{"name":"required","type":"uint256"}],
    "name":"InsufficientBalance"
    }, {
    "type":"event",
    "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
    "name":"Event"
    }, {
    "type":"event",
    "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
    "name":"Event2"
    }, {
    "type":"function",
    "inputs": [{"name":"a","type":"uint256"}],
    "name":"foo",
    "outputs": []
    }]

Menangani jenis tupel
---------------------

Meskipun nama-nama itu sengaja bukan bagian dari pengkodean ABI, mereka sangat masuk akal untuk dimasukkan
dalam JSON untuk memungkinkan menampilkannya kepada pengguna akhir. Struktur *nested *dengan cara berikut:

Objek dengan anggota ``name``, ``type`` dan berpotensi ``components`` mendeskripsikan variabel yang diketik.
Tipe kanonik ditentukan hingga tipe tupel tercapai dan deskripsi string naik
ke titik itu disimpan dalam awalan ``type`` dengan kata ``tuple``, yaitu akan menjadi ``tuple`` diikuti oleh
urutan ``[]`` dan ``[k]`` dengan
integer ``k``. Komponen dari tupel kemudian disimpan dalam anggota ``components``,
yang merupakan tipe array dan memiliki struktur yang sama dengan objek tingkat atas kecuali itu
``indexed`` tidak diperbolehkan di sana.

Sebagai contoh, kode

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.5 <0.9.0;
    pragma abicoder v2;

    contract Test {
        struct S { uint a; uint[] b; T[] c; }
        struct T { uint x; uint y; }
        function f(S memory, T memory, uint) public pure {}
        function g() public pure returns (S memory, T memory, uint) {}
    }

akan menghasilkan JSON:

.. code-block:: json

    [
      {
        "name": "f",
        "type": "function",
        "inputs": [
          {
            "name": "s",
            "type": "tuple",
            "components": [
              {
                "name": "a",
                "type": "uint256"
              },
              {
                "name": "b",
                "type": "uint256[]"
              },
              {
                "name": "c",
                "type": "tuple[]",
                "components": [
                  {
                    "name": "x",
                    "type": "uint256"
                  },
                  {
                    "name": "y",
                    "type": "uint256"
                  }
                ]
              }
            ]
          },
          {
            "name": "t",
            "type": "tuple",
            "components": [
              {
                "name": "x",
                "type": "uint256"
              },
              {
                "name": "y",
                "type": "uint256"
              }
            ]
          },
          {
            "name": "a",
            "type": "uint256"
          }
        ],
        "outputs": []
      }
    ]

.. _abi_packed_mode:

Mode Strict Encoding
====================

Strict encoding mode adalah mode yang mengarah ke pengkodean yang sama persis seperti yang didefinisikan dalam spesifikasi formal di atas.
Ini berarti offset harus sekecil mungkin sambil tetap tidak membuat tumpang tindih di area data dan dengan demikian tidak ada celah yang
diizinkan.

Biasanya, decoder ABI ditulis secara langsung hanya dengan mengikuti pointer offset, tetapi beberapa decoder
mungkin menerapkan strict mode. Decoder Solidity ABI saat ini tidak menerapkan strict mode, tetapi encoder
selalu membuat data dalam strict mode.

Mode Non-standard Packed
========================

Melalui ``abi.encodePacked()``, Solidity mendukung mode non-standard packed di mana:

- tipe yang lebih pendek dari 32 byte tidak diisi nol atau tanda diperpanjang dan
- tipe dinamis dikodekan di tempat dan tanpa panjang.
- elemen array diisi, tetapi masih dikodekan di tempat

Selain itu, struct serta nested array tidak didukung.

Sebagai contoh, pengkodean ``int16(-1), bytes1(0x42), uint16(0x03), string("Hello, world!")`` menghasilkan:

.. code-block:: none

    0xffff42000348656c6c6f2c20776f726c6421
      ^^^^                                 int16(-1)
          ^^                               bytes1(0x42)
            ^^^^                           uint16(0x03)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ string("Hello, world!") without a length field

Lebih spesifik:

- Selama pengkodean, semuanya dikodekan di tempat. Artinya
  tidak ada perbedaan antara kepala dan ekor, seperti dalam penyandian ABI,
  dan panjang larik tidak disandikan.
- Argumen langsung dari ``abi.encodePacked`` dikodekan tanpa padding,
  selama mereka bukan array (atau ``string`` atau ``byte``).
- Pengkodean array adalah gabungan dari
  pengkodean elemennya **dengan** padding.
- Jenis berukuran dinamis seperti ``string``, ``bytes`` atau ``uint[]`` dikodekan
  tanpa bidang panjangnya.
- Encoding ``string`` atau ``bytes`` tidak menerapkan padding di akhir
  kecuali jika itu adalah bagian dari array atau struct (kemudian diisi ke kelipatan 32 byte).

Secara umum, pengkodean menjadi ambigu segera setelah ada dua elemen berukuran dinamis,
karena bidang panjang yang hilang.

Jika padding diperlukan, konversi tipe eksplisit dapat digunakan: ``abi.encodePacked(uint16(0x12)) == hex"0012"``.

Karena pengodean paket tidak digunakan saat memanggil fungsi, tidak ada dukungan khusus
untuk menambahkan pemilih fungsi. Karena penyandiannya ambigu, tidak ada fungsi penguraian kode.

.. warning::

    Jika Anda menggunakan ``keccak256(abi.encodePacked(a, b))`` dan ``a`` dan ``b`` keduanya adalah tipe dinamis,
    mudah untuk membuat tabrakan dalam nilai hash dengan memindahkan bagian dari ``a`` ke ``b`` dan
    dan sebaliknya. Lebih khusus lagi, ``abi.encodePacked("a", "bc") == abi.encodePacked("ab", "c")``.
    Jika Anda menggunakan ``abi.encodePacked`` untuk tanda tangan, otentikasi, atau integritas data
    pastikan untuk selalu menggunakan jenis yang sama dan periksa bahwa paling banyak salah satunya adalah dinamis.
    Kecuali ada alasan kuat, ``abi.encode`` harus lebih disukai.


.. _indexed_event_encoding:

Encoding Parameter Event Terindeks
==================================

Parameter Event Terindeks yang bukan tipe nilai, yaitu array dan struct tidak disimpan
secara langsung melainkan keccak256-hash dari pengkodean disimpan. Pengkodean ini
didefinisikan sebagai berikut:

- pengkodean nilai ``byte`` dan ``string`` hanyalah konten string
  tanpa awalan padding atau panjang.
- pengkodean struct adalah rangkaian penyandian anggotanya,
  selalu diisi ke kelipatan 32 byte (bahkan ``byte`` dan ``string``).
- pengkodean array (berukuran dinamis dan statis) adalah
  rangkaian penyandian elemen-elemennya, selalu diisi ke beberapa
  dari 32 byte (bahkan ``byte`` dan ``string``) dan tanpa awalan panjang apa pun

Di atas, seperti biasa, angka negatif diisi dengan ekstensi tanda dan bukan nol.
Jenis ``bytesNN`` diisi di sebelah kanan sementara ``uintNN`` / ``intNN`` diisi di sebelah kiri.

.. warning::

    Pengkodean struct ambigu jika berisi lebih dari satu array berukuran dinamis. Oleh karena itu,
    selalu periksa kembali data event dan jangan hanya mengandalkan hasil pencarian berdasarkan
    parameter yang diindeks saja.
