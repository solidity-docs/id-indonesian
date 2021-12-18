.. index:: storage, state variable, mapping

************************************
Layout Variabel State dalam Storage
************************************

.. _storage-inplace-encoding:

Variabel state kontrak disimpan dalam penyimpanan dengan cara yang ringkas
sehingga beberapa nilai terkadang menggunakan slot penyimpanan yang sama.
Kecuali untuk dynamically-sized array dan mapping (lihat di bawah), data disimpan
secara berurutan, item setelah item, dimulai dengan variabel state pertama,
yang disimpan di slot ``0``. Untuk setiap variabel,
ukuran dalam byte ditentukan menurut jenisnya.
Beberapa item bersebelahan yang membutuhkan kurang dari 32 byte dikemas menjadi satu
slot penyimpanan jika memungkinkan, sesuai dengan aturan berikut:

- Item pertama dalam slot penyimpanan disimpan dengan urutan yang lebih rendah.
- Tipe nilai hanya menggunakan byte sebanyak yang diperlukan untuk menyimpannya.
- Jika jenis nilai tidak sesuai dengan bagian yang tersisa dari slot penyimpanan, maka akan disimpan di slot penyimpanan berikutnya.
- Struct dan data array selalu memulai slot baru dan itemnya dikemas dengan ketat sesuai dengan aturan ini.
- Item yang mengikuti data struct atau array selalu memulai slot penyimpanan baru.

Untuk kontrak yang menggunakan inheritance, urutan variabel state ditentukan oleh urutan kontrak
C3-linearized yang dimulai dengan kontrak paling dasar. Jika diizinkan
oleh aturan di atas, variabel state dari kontrak yang berbeda berbagi slot penyimpanan yang sama.

Elemen struct dan array disimpan setelah satu sama lain, seolah-olah mereka diberikan
sebagai nilai individual.

.. warning::
    Saat menggunakan elemen yang lebih kecil dari 32 byte, penggunaan gas kontrak Anda mungkin lebih tinggi.
    Ini karena EVM beroperasi pada 32 byte sekaligus. Oleh karena itu, jika elemennya lebih kecil
    dari itu, EVM harus menggunakan lebih banyak operasi untuk mengurangi ukuran elemen dari 32
    byte ke ukuran yang diinginkan.

    Mungkin bermanfaat untuk menggunakan tipe ukuran yang diperkecil jika Anda berurusan dengan nilai penyimpanan
    karena kompiler akan mengemas beberapa elemen ke dalam satu slot penyimpanan, dan dengan demikian, menggabungkan
    beberapa pembacaan atau penulisan ke dalam satu operasi.
    Jika Anda tidak membaca atau menulis semua nilai dalam slot pada saat yang sama, ini dapat
    memiliki efek sebaliknya, meskipun: Ketika satu nilai ditulis ke slot penyimpanan
    multi-nilai, slot penyimpanan harus dibaca terlebih dahulu dan kemudian
    digabungkan dengan nilai baru sehingga data lain di slot yang sama tidak dihancurkan.

    Ketika berhadapan dengan argumen fungsi atau nilai
    memori, tidak ada manfaat yang melekat karena kompiler tidak mengemas nilai-nilai ini.

    Terakhir, agar EVM dapat mengoptimalkannya, pastikan Anda mencoba mengurutkan
    variabel penyimpanan dan anggota ``struct`` sedemikian rupa sehingga dapat dikemas dengan rapat. Misalnya,
    mendeklarasikan variabel storage Anda dalam urutan ``uint128, uint128, uint256`` alih-alih
    ``uint128, uint256, uint128``, karena yang pertama hanya akan menggunakan dua slot penyimpanan sedangkan
    yang terakhir akan menggunakan tiga.

.. note::
     Tata letak variabel state dalam penyimpanan dianggap sebagai bagian dari
     antarmuka eksternal Solidity karena fakta bahwa pointer penyimpanan dapat
     diteruskan ke library. Ini berarti bahwa setiap perubahan pada aturan yang
     diuraikan dalam bagian ini dianggap sebagai perubahan bahasa yang melanggar
     dan karena sifatnya yang kritis harus dipertimbangkan dengan sangat hati-hati
     sebelum dieksekusi.


Mapping dan Array Dinamis
===========================

.. _storage-hashed-encoding:

Karena ukurannya yang tidak dapat diprediksi, mapping dan tipe array dynamically-sized tidak dapat
disimpan "di antara" variabel state sebelum dan sesudahnya.
Sebaliknya, mereka dianggap hanya menempati 32 byte sehubungan dengan
:ref:`rules di atas <storage-inplace-encoding>` dan elemen yang dikandungnya
disimpan mulai dari slot penyimpanan berbeda yang dihitung menggunakan hash Keccak-256 .

Asumsikan lokasi penyimpanan mapping atau array akhirnya menjadi slot ``p``
setelah menerapkan :ref:`aturan storage layout <storage-inplace-encoding>`.
Untuk array dinamis,
slot ini menyimpan jumlah elemen dalam array (array byte dan
string adalah pengecualian, lihat :ref:`di bawah <byte-dan-string>`).
Untuk mapping, slot tetap kosong, tetapi masih diperlukan untuk memastikan bahwa meskipun ada
dua mapping yang bersebelahan, kontennya berakhir di lokasi penyimpanan yang berbeda.

Data array terletak mulai dari ``keccak256(p)`` dan ditata dengan cara yang sama seperti
data array berukuran statis akan: Satu demi satu elemen, berpotensi berbagi
slot penyimpanan jika elemen tidak lebih dari 16 byte. Array dinamis dari array dinamis menerapkan
aturan ini secara rekursif. Lokasi elemen ``x[i][j]``, dengan tipe ``x`` adalah ``uint24[][]``, adalah
dihitung sebagai berikut (sekali lagi, dengan asumsi ``x`` sendiri disimpan di slot ``p``):
Slotnya adalah ``keccak256(keccak256(p) + i) + floor(j / floor(256 / 24))`` dan
elemen dapat diperoleh dari data slot ``v`` menggunakan ``(v >> ((j % floor(256 / 24)) * 24)) & type(uint24).max``.

Nilai yang sesuai dengan kunci pemetaan ``k`` terletak di ``keccak256(h(k) . p)``
di mana ``.`` adalah rangkaian dan ``h`` adalah fungsi yang diterapkan ke kunci tergantung pada jenisnya:

- untuk tipe nilai, ``h`` memasukkan nilai ke 32 byte dengan cara yang sama seperti saat menyimpan nilai dalam memori.
- untuk string dan array byte, ``h`` menghitung hash ``keccak256`` dari data yang tidak diisi.

Jika nila mapping adalah
tipe non-value, slot yang dihitung menandai awal dari data. Jika nilainya bertipe struct,
misalnya, Anda harus menambahkan offset yang sesuai dengan anggota struct untuk menjangkau anggota.

Sebagai contoh, perhatikan kontrak berikut:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;


    contract C {
        struct S { uint16 a; uint16 b; uint256 c; }
        uint x;
        mapping(uint => mapping(uint => S)) data;
    }

Mari kita hitung lokasi penyimpanan ``data[4][9].c``.
Posisi mapping itu sendiri adalah ``1`` (variabel ``x`` dengan 32 byte mendahuluinya).
Ini berarti ``data[4]`` disimpan pada ``keccak256(uint256(4) . uint256(1))``. Tipe dari ``data[4]`` sekali
lagi adalah sebuah mapping dan data untuk ``data[4][9]`` dimulai dari slot
``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1)))``.
Slot offset anggota ``c`` di dalam struct ``S`` adalah ``1`` karena ``a`` dan ``b`` dikemas
dalam satu slot. Ini berarti slot untuk
``data[4][9].c`` adalah ``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1))) + 1``.
Jenis nilainya adalah ``uint256``, sehingga menggunakan satu slot.


.. _bytes-and-string:

``bytes`` dan ``string``
------------------------

``bytes`` dan ``string`` dikodekan secara identik.
Secara umum, pengkodean mirip dengan ``bytes1[]``, dalam arti bahwa ada slot untuk array itu sendiri dan
area data yang dihitung menggunakan hash ``keccak256`` dari posisi slot tersebut.
Namun, untuk nilai pendek (lebih pendek dari 32 byte) elemen array disimpan bersama dengan panjangnya di slot yang sama.

Khususnya: jika panjang data paling banyak ``31`` byte, elemen disimpan dalam byte tingkat tinggi (rata kiri) dan byte urutan terendah menyimpan nilai ``panjang * 2``.
Untuk array byte yang menyimpan data dengan panjang ``32`` atau lebih byte, slot utama ``p`` menyimpan ``length * 2 + 1`` dan data disimpan seperti biasa di ``keccak256(p) ``.
Ini berarti bahwa Anda dapat membedakan array pendek dari array panjang dengan memeriksa apakah bit terendah disetel: pendek (tidak disetel) dan panjang (diatur).

.. note::
  Menangani slot yang disandikan secara tidak valid saat ini tidak didukung tetapi dapat ditambahkan di masa mendatang.
  Jika Anda mengompilasi melalui pipeline compiler berbasis IR eksperimental, membaca slot yang dikodekan secara tidak
  valid akan menghasilkan kesalahan ``Panic(0x22)``.

JSON Output
===========

.. _storage-layout-top-level:

Tata letak penyimpanan kontrak dapat diminta melalui :ref:`antarmuka JSON standar <compiler-api>`.
Outputnya adalah objek JSON yang berisi dua kunci, ``storage`` dan ``types``.
Objek ``storage`` adalah array di mana setiap elemen memiliki bentuk berikut:


.. code::


    {
        "astId": 2,
        "contract": "fileA:A",
        "label": "x",
        "offset": 0,
        "slot": "0",
        "type": "t_uint256"
    }

Contoh di atas adalah tata letak penyimpanan ``contract A { uint x; }`` dari unit sumber ``fileA``
dan

- ``astId`` adalah id dari node AST dari deklarasi variabel state
- ``kontrak`` adalah nama kontrak termasuk jalurnya sebagai awalan
- ``label`` adalah nama variabel state
- ``offset`` adalah offset dalam byte dalam slot penyimpanan sesuai dengan pengkodean
- ``slot`` adalah slot penyimpanan tempat variabel state berada atau dimulai. Angka ini mungkin sangat besar dan oleh karena itu nilai JSON-nya direpresentasikan sebagai string.
- ``type`` adalah pengidentifikasi yang digunakan sebagai kunci untuk informasi tipe variabel (dijelaskan berikut ini)

``type`` yang diberikan, dalam hal ini ``t_uint256`` mewakili elemen dalam
``types``, yang berbentuk:


.. code::

    {
        "encoding": "inplace",
        "label": "uint256",
        "numberOfBytes": "32",
    }

dimana

- ``encoding`` bagaimana data dikodekan dalam penyimpanan, di mana nilai yang mungkin adalah:

  - ``inplace``: Data diletakkan secara berurutan dalam penyimpanan (lihat :ref:`di atas <storage-inplace-encoding>`).
  - ``mapping``: Metode Keccak-256 hash-based (lihat :ref:`di atas <storage-hashed-encoding>`).
  - ``dynamic_array``: Metode Keccak-256 hash-based (lihat :ref:`di atas <storage-hashed-encoding>`).
  - ``bytes``: single slot atau Keccak-256 hash-based tergantung dengan ukuran data (lihat :ref:`di atas <bytes-and-string>`).

- ``label`` adalah nama tipe canonical.
- ``numberOfBytes`` adalah jumlah byte yang digunakan (sebagai string desimal).
  Perhatikan bahwa jika ``numberOfBytes > 32`` ini berarti lebih dari satu slot yang digunakan.

Beberapa tipe memiliki informasi tambahan selain keempat di atas. Mapping mengandung
tipe ``key`` dan ``value``-nya (sekali lagi merujuk entri dalam Mapping ini
jenis), array memiliki tipe ``base``, dan struct mencantumkan ``members`` mereka di
format yang sama dengan ``storage`` tingkat atas (lihat :ref:`di atas
<storage-layout-top-level>`).

.. note ::
  Format output JSON dari layout penyimpanan kontrak masih dianggap eksperimental
  dan dapat berubah dalam rilis Solidity yang tidak melanggar.

Contoh berikut menunjukkan kontrak dan tata letak penyimpanannya, yang berisi:
tipe nilai dan referensi, tipe yang encoded packed, dan tipe nested.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;
    contract A {
        struct S {
            uint128 a;
            uint128 b;
            uint[2] staticArray;
            uint[] dynArray;
        }

        uint x;
        uint y;
        S s;
        address addr;
        mapping (uint => mapping (address => bool)) map;
        uint[] array;
        string s1;
        bytes b1;
    }

.. code:: json

    {
      "storage": [
        {
          "astId": 15,
          "contract": "fileA:A",
          "label": "x",
          "offset": 0,
          "slot": "0",
          "type": "t_uint256"
        },
        {
          "astId": 17,
          "contract": "fileA:A",
          "label": "y",
          "offset": 0,
          "slot": "1",
          "type": "t_uint256"
        },
        {
          "astId": 20,
          "contract": "fileA:A",
          "label": "s",
          "offset": 0,
          "slot": "2",
          "type": "t_struct(S)13_storage"
        },
        {
          "astId": 22,
          "contract": "fileA:A",
          "label": "addr",
          "offset": 0,
          "slot": "6",
          "type": "t_address"
        },
        {
          "astId": 28,
          "contract": "fileA:A",
          "label": "map",
          "offset": 0,
          "slot": "7",
          "type": "t_mapping(t_uint256,t_mapping(t_address,t_bool))"
        },
        {
          "astId": 31,
          "contract": "fileA:A",
          "label": "array",
          "offset": 0,
          "slot": "8",
          "type": "t_array(t_uint256)dyn_storage"
        },
        {
          "astId": 33,
          "contract": "fileA:A",
          "label": "s1",
          "offset": 0,
          "slot": "9",
          "type": "t_string_storage"
        },
        {
          "astId": 35,
          "contract": "fileA:A",
          "label": "b1",
          "offset": 0,
          "slot": "10",
          "type": "t_bytes_storage"
        }
      ],
      "types": {
        "t_address": {
          "encoding": "inplace",
          "label": "address",
          "numberOfBytes": "20"
        },
        "t_array(t_uint256)2_storage": {
          "base": "t_uint256",
          "encoding": "inplace",
          "label": "uint256[2]",
          "numberOfBytes": "64"
        },
        "t_array(t_uint256)dyn_storage": {
          "base": "t_uint256",
          "encoding": "dynamic_array",
          "label": "uint256[]",
          "numberOfBytes": "32"
        },
        "t_bool": {
          "encoding": "inplace",
          "label": "bool",
          "numberOfBytes": "1"
        },
        "t_bytes_storage": {
          "encoding": "bytes",
          "label": "bytes",
          "numberOfBytes": "32"
        },
        "t_mapping(t_address,t_bool)": {
          "encoding": "mapping",
          "key": "t_address",
          "label": "mapping(address => bool)",
          "numberOfBytes": "32",
          "value": "t_bool"
        },
        "t_mapping(t_uint256,t_mapping(t_address,t_bool))": {
          "encoding": "mapping",
          "key": "t_uint256",
          "label": "mapping(uint256 => mapping(address => bool))",
          "numberOfBytes": "32",
          "value": "t_mapping(t_address,t_bool)"
        },
        "t_string_storage": {
          "encoding": "bytes",
          "label": "string",
          "numberOfBytes": "32"
        },
        "t_struct(S)13_storage": {
          "encoding": "inplace",
          "label": "struct A.S",
          "members": [
            {
              "astId": 3,
              "contract": "fileA:A",
              "label": "a",
              "offset": 0,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 5,
              "contract": "fileA:A",
              "label": "b",
              "offset": 16,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 9,
              "contract": "fileA:A",
              "label": "staticArray",
              "offset": 0,
              "slot": "1",
              "type": "t_array(t_uint256)2_storage"
            },
            {
              "astId": 12,
              "contract": "fileA:A",
              "label": "dynArray",
              "offset": 0,
              "slot": "3",
              "type": "t_array(t_uint256)dyn_storage"
            }
          ],
          "numberOfBytes": "128"
        },
        "t_uint128": {
          "encoding": "inplace",
          "label": "uint128",
          "numberOfBytes": "16"
        },
        "t_uint256": {
          "encoding": "inplace",
          "label": "uint256",
          "numberOfBytes": "32"
        }
      }
    }
