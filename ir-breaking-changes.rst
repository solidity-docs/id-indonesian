
.. index: ir breaking changes

***********************************
Perubahan Solidity IR-based Codegen
***********************************

Solidity dapat menghasilkan bytecode EVM dengan dua cara berbeda:
Baik secara langsung dari opcode Solidity ke EVM ("codegen lama") atau melalui
representasi perantara ("IR") di Yul ("codegen baru" atau "codegen berbasis IR").

Pembuat kode berbasis IR diperkenalkan dengan tujuan untuk tidak
hanya memungkinkan pembuatan kode menjadi lebih transparan dan dapat diaudit, tetapi juga
untuk memungkinkan pengoptimalan yang lebih kuat yang menjangkau seluruh fungsi.

Saat ini, pembuat kode berbasis IR masih ditandai eksperimental,
tetapi mendukung semua fitur bahasa dan telah menerima banyak pengujian,
jadi kami menganggapnya hampir siap untuk penggunaan produksi.

Anda dapat mengaktifkannya di baris perintah menggunakan ``--experimental-via-ir``
atau dengan opsi ``{"viaIR": true}`` di json standar dan kami
mendorong semua orang untuk mencobanya!

Untuk beberapa alasan, ada perbedaan semantik kecil antara yang lama
dan pembuat kode berbasis IR, sebagian besar di area di mana kami tidak
mengharapkan orang untuk bergantung pada perilaku ini.
Bagian ini menyoroti perbedaan utama antara codegen lama dan IR-based.

Perubahan Semantik Saja
=======================

Bagian ini mencantumkan perubahan yang hanya bersifat semantik, sehingga berpotensi
menyembunyikan perilaku baru dan berbeda dalam kode yang ada.

- Ketika struct penyimpanan dihapus, setiap slot penyimpanan yang berisi
  anggota struct disetel ke nol seluruhnya. Sebelumnya, ruang padding
  dibiarkan tak tersentuh.
  Akibatnya, jika ruang padding dalam struct digunakan untuk menyimpan data
  (misalnya dalam konteks peningkatan kontrak), Anda harus menyadari bahwa
  ``delete`` sekarang juga akan menghapus anggota yang ditambahkan (sementara itu
  tidak akan dibersihkan di masa lalu).

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.1;

      contract C {
          struct S {
              uint64 y;
              uint64 z;
          }
          S s;
          function f() public {
              // ...
              delete s;
              // s occupies only first 16 bytes of the 32 bytes slot
              // delete will write zero to the full slot
          }
      }

  Kami memiliki perilaku yang sama untuk penghapusan implisit, misalnya ketika array struct dipersingkat.

- Fungsi modifier diimplementasikan dengan cara yang sedikit berbeda mengenai parameter fungsi dan variabel return.
  Ini terutama berpengaruh jika placeholder ``_;`` dievaluasi beberapa kali dalam modifier.
  Dalam generator kode lama, setiap parameter fungsi dan variabel return memiliki slot tetap pada stack.
  Jika fungsi dijalankan beberapa kali karena ``_;`` digunakan beberapa kali atau digunakan dalam satu lingkaran, maka
  perubahan pada parameter fungsi atau nilai variabel return akan terlihat pada eksekusi fungsi berikutnya.
  Generator kode baru mengimplementasikan modifier menggunakan fungsi aktual dan meneruskan parameter fungsi.
  Ini berarti bahwa beberapa evaluasi tubuh fungsi akan mendapatkan nilai yang sama untuk parameter,
  dan efek pada variabel return adalah bahwa mereka direset ke nilai default (nol) untuk masing-masing
  eksekusi.

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.0;
      contract C {
          function f(uint _a) public pure mod() returns (uint _r) {
              _r = _a++;
          }
          modifier mod() { _; _; }
      }

  Jika Anda menjalankan ``f(0)`` di Generator kode lama, ia akan menghasilkan ``2``, sementara
  akan menghasilkan ``1`` saat menggunakan Generator kode baru.

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.1 <0.9.0;

      contract C {
          bool active = true;
          modifier mod()
          {
              _;
              active = false;
              _;
          }
          function foo() external mod() returns (uint ret)
          {
              if (active)
                  ret = 1; // Same as ``return 1``
          }
      }

  Fungsi ``C.foo()`` menghasilkan nilai berikut:

  - Generator kode lama: ``1`` karena variabel return diinisialisasi ke ``0`` hanya sekali sebelum evaluasi ``_;``
    pertama dan kemudian ditimpa oleh ``return 1;``. Itu tidak diinisialisasi lagi untuk evaluasi ``_;``
    kedua dan ``foo()`` juga tidak secara eksplisit menetapkannya (karena ``active == false``), sehingga tetap mempertahankan
    nilai pertamanya.
  - Generator kode baru: ``0`` karena semua parameter, termasuk parameter return, akan diinisialisasi ulang sebelum setiap evaluasi ``_;``.

- Urutan inisialisasi kontrak telah berubah dalam hal inheritance.

  Urutannya dulu:

  - Semua variabel state zero-initialized sejak awal.
  - Evaluasi argumen basis konstruktor dari kontrak paling turunan hingga paling dasar.
  - Inisialisasi semua variabel state di seluruh hierarki inheritance dari paling dasar hingga paling turunan.
  - Jalankan konstruktor, jika ada, untuk semua kontrak dalam hierarki linier dari paling dasar hingga paling turunan.

  Urutan terbaru:

  - Semua variabel state zero-initialized sejak awal.
  - Evaluasi argumen basis konstruktor dari kontrak paling turunan hingga paling dasar.
  - Untuk setiap kontrak dalam urutan dari paling dasar hingga paling turunan dalam hierarki linier, jalankan:

      1. Jika ada saat deklarasi, nilai awal ditetapkan ke variabel state.
      2. Konstruktor, jika ada.

Hal ini menyebabkan perbedaan dalam beberapa kontrak, misalnya:

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.7.1;

      contract A {
          uint x;
          constructor() {
              x = 42;
          }
          function f() public view returns(uint256) {
              return x;
          }
      }
      contract B is A {
          uint public y = f();
      }

  Sebelumnya, ``y`` akan disetel ke 0. Hal ini disebabkan oleh fakta bahwa kita akan menginisialisasi variabel state terlebih dahulu: Pertama, ``x`` disetel ke 0, dan saat menginisialisasi ``y``, `` f()`` akan menghasilkan 0 menyebabkan ``y`` menjadi 0 juga.
   Dengan aturan baru, ``y`` akan disetel ke 42. Pertama-tama kita menginisialisasi ``x`` ke 0, kemudian memanggil konstruktor A yang menyetel ``x`` menjadi 42. Terakhir, saat menginisialisasi ``y`` , ``f()`` menghasilkan 42 menyebabkan ``y`` menjadi 42.

- Menyalin ``byte`` array dari memori ke penyimpanan diimplementasikan dengan cara yang berbeda.
  Generator kode lama selalu menyalin kata-kata penuh, sedangkan yang baru memotong
  array byte setelah akhirannya. Perilaku lama dapat menyebabkan data kotor disalin setelah
  akhir array (tetapi masih dalam slot penyimpanan yang sama).
  Hal ini menyebabkan perbedaan dalam beberapa kontrak, misalnya:

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;

      contract C {
          bytes x;
          function f() public returns (uint _r) {
              bytes memory m = "tmp";
              assembly {
                  mstore(m, 8)
                  mstore(add(m, 32), "deadbeef15dead")
              }
              x = m;
              assembly {
                  _r := sload(x.slot)
              }
          }
      }

  Sebelumnya ``f()`` akan meghasilkan ``0x6465616462656566313564656164000000000000000000000000000000000010``
  (memiliki panjang yang benar, dan 8 elemen pertama yang benar, tetapi kemudian berisi data kotor yang disetel melalui assembly).
  Sekarang itu kan menghasilkan ``0x6465616462656566000000000000000000000000000000000000000000000010`` (memiliki
  panjang yang benar, dan elemen yang benar, tetapi tidak mengandung data yang berlebihan).

  .. index:: ! evaluation order; expression

- For the old code generator, the evaluation order of expressions is unspecified.
  For the new code generator, we try to evaluate in source order (left to right), but do not guarantee it.
  This can lead to semantic differences.

  For example:

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;
      contract C {
          function preincr_u8(uint8 _a) public pure returns (uint8) {
              return ++_a + _a;
          }
      }

  Fungsi ``preincr_u8(1)`` menghasilkan nilai berikut:

  - Generator kode lama: 3 (``1 + 2``) tetapi secara umum, hasil nilainya tidak ditentukan
  - Generator kode baru: 4 (``2 + 2``) tetapi hasil nilainya tidak dijamin

  .. index:: ! evaluation order; function arguments

  Di sisi lain, ekspresi argumen fungsi dievaluasi dalam urutan yang sama oleh
  kedua kode generator dengan pengecualian fungsi global ``addmod`` dan ``mulmod``.
  Sebagai contoh:

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;
      contract C {
          function add(uint8 _a, uint8 _b) public pure returns (uint8) {
              return _a + _b;
          }
          function g(uint8 _a, uint8 _b) public pure returns (uint8) {
              return add(++_a + ++_b, _a + _b);
          }
      }

  Fungsi ``g(1, 2)`` menghasilkan nilai berikut:

  - Generator kode lama: ``10`` (``add(2 + 3, 2 + 3)``) tetapi secara umum, hasil nilainya tidak ditentukan
  - Generator kode baru: ``10`` tetapi hasil nilainya tidak dijamin

  Argumen untuk fungsi global ``addmod`` dan ``mulmod`` dievaluasi dari kanan ke kiri oleh generator kode lama
  dan kiri-ke-kanan oleh generator kode baru.
  Sebagai contoh:

  .. code-block:: solidity

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >=0.8.1;
      contract C {
          function f() public pure returns (uint256 aMod, uint256 mMod) {
              uint256 x = 3;
              // Old code gen: add/mulmod(5, 4, 3)
              // New code gen: add/mulmod(4, 5, 5)
              aMod = addmod(++x, ++x, x);
              mMod = mulmod(++x, ++x, x);
          }
      }

  Fungsi ``f()`` menghasilkan nilai berikut:

  - Generator kode lama: ``aMod = 0`` dan ``mMod = 2``
  - Generator kode baru: ``aMod = 4`` dan ``mMod = 0``

- Generator kode baru memberlakukan batasan keras dari ``type(uint64).max``
  (``0xffffffffffffffff``) untuk ponter memery bebas. Alokasi yang akan
  meningkatkan nilainya di luar batas ini dikembalikan. Generator kode lama
  tidak memiliki batas ini.

  Sebagai contoh:

  .. code-block:: solidity
      :force:

      // SPDX-License-Identifier: GPL-3.0
      pragma solidity >0.8.0;
      contract C {
          function f() public {
              uint[] memory arr;
              // allocation size: 576460752303423481
              // assumes freeMemPtr points to 0x80 initially
              uint solYulMaxAllocationBeforeMemPtrOverflow = (type(uint64).max - 0x80 - 31) / 32;
              // freeMemPtr overflows UINT64_MAX
              arr = new uint[](solYulMaxAllocationBeforeMemPtrOverflow);
          }
      }

  Fungsi `f()` berperilaku sebagai berikut:

  - Generator kode lama: kehabisan gas saat mengosongkan konten array setelah alokasi memori yang besar
  - Generator kode baru: kembali karena pointer memori bebas meluap (tidak kehabisan gas)


Internal
========

Pointer fungsi internal
-----------------------

.. index:: function pointers

Generator kode lama menggunakan offset kode atau tag untuk nilai pointer fungsi internal. Ini sangat rumit karena
offset ini berbeda pada waktu konstruksi dan setelah penerapan dan nilainya dapat melewati batas ini melalui penyimpanan.
Karena itu, kedua offset dikodekan pada waktu konstruksi menjadi nilai yang sama (ke dalam byte yang berbeda).

Di generator kode baru, pointer fungsi menggunakan ID internal yang dialokasikan secara berurutan. Karena panggilan melalui lompatan tidak dimungkinkan,
panggilan melalui pointer fungsi selalu harus menggunakan fungsi pengiriman internal yang menggunakan pernyataan ``switch`` untuk memilih
fungsi yang tepat.

ID ``0`` dicadangkan untuk pointer fungsi yang tidak diinisialisasi yang kemudian menyebabkan kepanikan pada fungsi pengiriman saat dipanggil.

Di generator kode lama, pointer fungsi internal diinisialisasi dengan fungsi khusus yang selalu menyebabkan kepanikan.
Hal ini menyebabkan penulisan penyimpanan pada waktu konstruksi untuk pointer fungsi internal di penyimpanan.

Cleanup
-------

.. index:: cleanup, dirty bits

Generator kode lama hanya melakukan pembersihan sebelum operasi yang hasilnya dapat dipengaruhi oleh nilai bit kotor.
Generator kode baru melakukan pembersihan setelah operasi apa pun yang dapat menghasilkan bit kotor.
Harapannya adalah pengoptimal akan cukup kuat untuk menghilangkan operasi pembersihan yang berlebihan.

Sebagai contoh:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.1;
    contract C {
        function f(uint8 _a) public pure returns (uint _r1, uint _r2)
        {
            _a = ~_a;
            assembly {
                _r1 := _a
            }
            _r2 = _a;
        }
    }

Fungsi ``f(1)`` menghasilkan nilai berikut:

- Generator kode lama: (``fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe``, ``00000000000000000000000000000000000000000000000000000000000000fe``)
- Generator kode baru: (``00000000000000000000000000000000000000000000000000000000000000fe``, ``00000000000000000000000000000000000000000000000000000000000000fe``)

Perhatikan bahwa, tidak seperti generator kode baru, generator kode lama tidak melakukan pembersihan setelah bit-not assignmen (``_a = ~_a``).
Ini menghasilkan nilai yang berbeda yang ditetapkan (dalam blok  inline assembly) untuk mengembalikan nilai ``_r1`` antara generator kode lama dan baru.
Namun, kedua generator kode melakukan pembersihan sebelum nilai baru ``_a`` ditetapkan ke ``_r2``.
