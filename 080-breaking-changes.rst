********************************
Solidity v0.8.0 Breaking Changes
********************************

Bagian ini menyoroti perubahan utama yang diperkenalkan di Solidity
versi 0.8.0.
Untuk daftar lengkap cek
`release changelog <https://github.com/ethereum/solidity/releases/tag/v0.8.0>`_.

Perubahan Senyap dari Semantics
===============================

Bagian ini mencantumkan perubahan di mana kode yang ada mengubah perilakunya tanpa
kompiler memberi tahu Anda tentang hal itu.

* Operasi aritmatika kembali pada underflow dan overflow. Anda dapat menggunakan ``unchecked { ... }`` untuk menggunakan
  perilaku wrapping sebelumnya.

  Pemeriksaan overflow sangat umum, jadi kami menjadikannya default untuk meningkatkan keterbacaan kode,
  bahkan jika itu datang dengan sedikit peningkatan biaya gas.

* ABI coder v2 diaktifkan secara default.

  Anda dapat memilih untuk menggunakan perilaku lama menggunakan ``pragma abicoder v1;``.
  Pragma ``pragma eksperimental ABIEncoderV2;`` masih valid, tetapi tidak digunakan lagi dan tidak berpengaruh.
  Jika Anda ingin eksplisit, gunakan ``pragma abicoder v2;`` sebagai gantinya.

  Perhatikan bahwa ABI coder v2 mendukung lebih banyak jenis daripada v1 dan melakukan lebih banyak pemeriksaan *sanity* pada input.
  ABI coder v2 membuat beberapa panggilan fungsi lebih mahal dan juga dapat membuat panggilan kontrak
  kembalikan yang tidak kembali dengan ABI coder v1 saat berisi data yang tidak sesuai dengan
  jenis parameter.

* Eksponen adalah asosiatif benar, yaitu, ekspresi ``a**b**c`` diuraikan sebagai ``a**(b**c)``.
  Sebelum 0.8.0, itu diuraikan sebagai ``(a**b)**c``.

  Ini adalah cara umum untuk mengurai operator eksponensial.

* Pernyataan yang gagal dan pemeriksaan internal lainnya seperti pembagian dengan nol atau overflow aritmatika
  tidak menggunakan opcode yang tidak valid melainkan opcode yang dikembalikan.
  Lebih khusus lagi, mereka akan menggunakan data kesalahan yang sama dengan panggilan fungsi ke ``Panic(uint256)`` dengan kode kesalahan tertentu
  terhadap keadaan.

  Ini akan menghemat gas pada kesalahan sementara masih memungkinkan alat analisis statis untuk membedakan
  situasi ini dari pengembalian input yang tidak valid, seperti ``require`` yang gagal.

* Jika array byte dalam penyimpanan diakses yang panjangnya dikodekan secara tidak benar, akan terjadi kepanikan.
  Sebuah kontrak tidak bisa masuk ke situasi ini kecuali perakitan inline digunakan untuk mengubah representasi mentah dari array byte penyimpanan.

* Jika konstanta digunakan dalam ekspresi panjang array, versi Solidity sebelumnya akan menggunakan presisi arbitrer
  di semua cabang dari pohon evaluasi. Sekarang, jika variabel konstan digunakan sebagai ekspresi perantara,
  nilainya akan dibulatkan dengan benar dengan cara yang sama seperti ketika digunakan dalam ekspresi run-time.

* Jenis ``byte`` telah dihapus. Itu adalah alias dari ``bytes1``.

Pembatasan Baru
===============

Bagian ini mencantumkan perubahan yang mungkin menyebabkan kontrak yang ada tidak dapat dikompilasi lagi.

* Ada batasan baru terkait dengan konversi literal yang eksplisit. Perilaku sebelumnya dalam
  kasus-kasus berikut mungkin ambigu:

  1. Konversi eksplisit dari literal negatif dan literal yang lebih besar dari ``type(uint160).max`` ke
     ``address`` tidak diizinkan.
  2. Konversi eksplisit antara literal dan tipe integer ``T`` hanya diperbolehkan jika literal
     terletak di antara ``type(T).min`` dan ``type(T).max``. Secara khusus, ganti penggunaan ``uint(-1)``
     dengan ``type(uint).max``.
  3. Konversi eksplisit antara literal dan enum hanya diperbolehkan jika literal can
     mewakili nilai dalam enum.
  4. Konversi eksplisit antara literal dan tipe ``address`` (misalnya ``address(literal)``) memiliki
     tipe ``address`` alih-alih ``address payable``. Seseorang bisa mendapatkan jenis alamat payable dengan menggunakan
     konversi eksplisit, yaitu, ``payable(literal)``.

* :ref:`Address literals<address_literals>` memiliki tipe ``address`` bukan ``address
  payable``. Mereka dapat dikonversi ke ``address payable`` dengan menggunakan konversi eksplisit, mis.
  ``payable(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF)``.

* Ada batasan baru pada konversi tipe eksplisit. Konversi hanya diperbolehkan jika ada
  paling banyak satu perubahan dalam tanda, lebar, atau kategori tipe (``int``, ``address``, ``bytesNN``, dll.).
  Untuk melakukan beberapa perubahan, gunakan beberapa konversi.

  Mari kita gunakan notasi ``T(S)`` untuk menyatakan konversi eksplisit ``T(x)``, di mana, ``T`` dan
  ``S`` adalah tipe, dan ``x`` adalah variabel arbitrer dari tipe ``S``. Contoh konversi
  yang tidak diizinkan seperti itu adalah ``uint16(int8)`` karena mengubah kedua lebar (8 bit menjadi 16 bit)
  dan tanda (signed integer ke unsigned integer).Untuk melakukan konversi, satunya harus
  melalui tipe perantara. Pada contoh sebelumnya, ini akan menjadi ``uint16(uint8(int8))`` atau
  ``uint16(int16(int8))``. Perhatikan bahwa dua cara untuk mengonversi akan menghasilkan hasil yang berbeda, mis.,
   untuk ``-1``. Berikut ini adalah beberapa contoh konversi yang tidak diizinkan oleh aturan ini.

  - ``address(uint)`` dan ``uint(address)``: mengonversi type-category dan width. Ganti ini dengan
    ``address(uint160(uint))`` dan ``uint(uint160(address))`` secara berurutan.
  - ``payable(uint160)``, ``payable(bytes20)`` dan ``payable(integer-literal)``: mengonversi kedua
    type-category dan state-mutability. Ganti ini dengan ``payable(address(uint160))``,
    ``payable(address(bytes20))`` dan ``payable(address(integer-literal))`` secara berurutan. Perhatikan bahwa
    ``payable(0)`` valid dan merupakan pengecualian dari aturan.
  - ``int80(bytes10)`` dan ``bytes10(int80)``: mengonversi kedua type-category and sign. Ganti ini dengan
    ``int80(uint80(bytes10))`` dan ``bytes10(uint80(int80)`` secara berurutan.
  - ``Contract(uint)``: mengonversi kedua type-category dan width. Ganti ini dengan
    ``Contract(address(uint160(uint)))``.

  Konversi ini tidak diizinkan untuk menghindari ambiguitas. Misalnya, dalam ekspresi ``uint16 x =
  uint16(int8(-1))``, nilai ``x`` akan bergantung pada apakah tanda atau konversi lebar
  diterapkan terlebih dahulu.

* Function call options hanya dapat diberikan satu kali, mis. ``c.f{gas: 10000}{value: 1}()`` adalah invalid dan harus diganti ke ``c.f{gas: 10000, value: 1}()``.

* Fungsi global ``log0``, ``log1``, ``log2``, ``log3`` dan ``log4`` tealah dihapus.

  Ini adalah fungsi low-level yang sebagian besar tidak terpakai. Perilaku mereka dapat diakses dari inline assembly.

* definisi ``enum`` tidak boleh berisi lebih dari 256 anggota.

  Ini akan membuat aman untuk mengasumsikan bahwa tipe dasar di ABI selalu ``uint8``.

* Deklarasi dengan nama ``this``, ``super`` dan ``_`` tidak diizinkan, dengan pengecualian
  fungsi dan event publik. Pengecualiannya adalah memungkinkan untuk mendeklarasikan antarmuka kontrak
  diimplementasikan dalam bahasa selain Solidity yang mengizinkan nama fungsi tersebut.

* Hapus dukungan untuk urutan escape ``\b``, ``\f``, dan ``\v`` dalam kode.
  Mereka masih dapat dimasukkan melalui heksadesimal escape, mis. ``\x08``, ``\x0c``, dan ``\x0b``, secara berurutan.

* Variabel global ``tx.origin`` dan ``msg.sender`` memiliki tipe ``address`` bukan
  ``address payable``. Seseorang dapat mengubahnya menjadi ``address payable`` dengan menggunakan konversi
  eksplisit, mis., ``payable(tx.origin)`` atau ``payable(msg.sender)``.

  Perubahan ini dilakukan karena kompiler tidak dapat menentukan apakah alamat ini payable
  atau tidak, jadi sekarang memerlukan konversi eksplisit untuk membuat persyaratan ini terlihat.

* Konversi eksplisit menjadi tipe ``address`` selalu mengembalikan tipe ``address`` payable. Secara
  khusus, konversi eksplisit berikut memiliki tipe ``address`` bukan ``address
  payable``:

  - ``address(u)`` dimana ``u`` adalah variable dari tipe ``uint160``. Yang satu dapat mengonversi ``u``
    menjadi tipe ``address payable`` dengan menggunakan dua konversi eksplisit, mis,
    ``payable(address(u))``.
  - ``address(b)`` dimana ``b`` adalah variable dari tipe ``bytes20``. Yang satu dapat mengonversi ``b``
    menjadi tipe ``address payable`` dengan menggunakan dua konversi eksplisit, mis,
    ``payable(address(b))``.
  - ``address(c)`` dimana ``c`` adalah sebuah kontrak. Sebelumnya, tipe return dari konversi ini
    bergantung pada apakah kontrak dapat menerima Ether (baik dengan fungsi receive
    atau fungsi payable fallback). Konversi ``payable(c)`` memiliki tipe ``address
    payable`` dan hanya diperbolehkan jika kontrak ``c`` dapat menerima Ether. Secara umum, seseorang selalu
    dapat mengubah ``c`` menjadi tipe ``address payable`` dengan menggunakan konversi eksplisit
    berikut: ``payable(address(c))``. Perhatikan bahwa ``address(this)`` termasuk dalam kategori yang sama
    sebagai ``address(c)`` dan aturan yang sama berlaku untuknya.

* ``chainid`` built-in inline assembly sekarang dianggap sebagai ``view`` bukan ``pure``.

* Negasi unary tidak dapat digunakan lagi pada unsigned integer, hanya pada signed integers.

PErubahan Interface
===================

* Output dari ``--combined-json`` telah diubah: Bidang JSON ``abi``, ``devdoc``, ``userdoc`` dan
  ``storage-layout`` adalah sub-objects sekarang. Sebelum 0.8.0 mereka digunakan untuk serial sebagai string.

* "legacy AST" telah dihapus (``--ast-json`` di commandline interface dan ``legacyAST`` untuk JSON standard).
  Gunakan "compact AST" (``--ast-compact--json`` resp. ``AST``) sebgai gantinya.

* Error reporter lama (``--old-reporter``) telah dihapus.


Bagaimana cara memperbarui kode Anda?
=====================================

- Jika Anda mengandalkan wrapping arithmetic, kelilingi setiap operasi dengan ``unchecked { ... }``.
- Opsional: Jika Anda menggunakan SafeMath atau library serupa, ubah ``x.add(y)`` menjadi ``x + y``, ``x.mul(y)`` menjadi ``x * y`` dll.
- Tambahkan ``pragma abicoder v1;`` jika Anda ingin tetap menggunakan ABI coder lama.
- Opsional hapus ``pragma experimental ABIEncoderV2`` atau ``pragma abicoder v2`` karena itu berlebihan.
- Ubah ``byte`` menjadi ``bytes1``.
- Tambahkan konversi tipe eksplisit menengah jika diperlukan.
- Gabungkan ``c.f{gas: 10000}{value: 1}()`` menjadi ``c.f{gas: 10000, value: 1}()``.
- Ubah ``msg.sender.transfer(x)`` menjadi ``payable(msg.sender).transfer(x)`` atau gunakan variabel yang disimpan dari tipe ``address payable``.
- ubah ``x**y**z`` menjadi ``(x**y)**z``.
- gunakan inline assembly sebagai pengganti untuk ``log0``, ..., ``log4``.
- Negate unsigned integers dengan menguranginya dari nilai maksimum tipe dan menambahkan 1 (mis. ``type(uint256).max - x + 1``, sambil memastikan bahwa `x` bukan nol)
