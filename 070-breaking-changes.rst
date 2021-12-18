********************************
Solidity v0.7.0 Breaking Changes
********************************

Bagian ini menyoroti perubahan utama yang diperkenalkan di Solidity
versi 0.7.0, beserta alasan di balik perubahan dan cara memperbarui
kode yang terpengaruh.
Untuk daftar lengkap cek
`release changelog <https://github.com/ethereum/solidity/releases/tag/v0.7.0>`_.


Perubahan Senyap dari Semantics
===============================

* Eksponen dan pergeseran literal dengan non-literal (misalnya ``1 << x`` atau ``2 ** x``)
  akan selalu menggunakan tipe ``uint256`` (untuk literal non-negatif) atau `` int256``
  (untuk literal negatif) untuk melakukan operasi. Sebelumnya, operasi dilakukan dalam jenis
  jumlah pergeseran / eksponen yang dapat menyesatkan.


Perubahan pada Syntax
=====================

* Dalam external function dan contract creation calls, Ether dan gas sekarang ditentukan menggunakan sintaks baru:
  ``x.f{gas: 10000, value: 2 ether}(arg1, arg2)``.
  Syntax lama -- ``x.f.gas(10000).value(2 ether)(arg1, arg2)`` -- akan memyebabkan error.

* Variabel global ``now`` tidak digunakan lagi, ``block.timestamp`` harus digunakan sebagai gantinya.
  Pengenal tunggal ``now`` terlalu umum untuk variabel global dan dapat memberi kesan bahwa
  itu berubah selama pemrosesan transaksi, sedangkan ``block.timestamp`` dengan
  benar mencerminkan fakta bahwa itu hanyalah properti dari blok.

* Komentar NatSpec pada variabel hanya diperbolehkan untuk variabel status publik dan tidak
  untuk variabel lokal atau internal.

* TToken ``gwei`` sekarang menjadi kata kunci (digunakan untuk menentukan, misalnya ``2 gwei`` sebagai angka)
  dan tidak dapat digunakan sebagai pengenal.

* Literal string sekarang hanya dapat berisi karakter ASCII yang dapat dicetak dan ini juga mencakup berbagai
  urutan escape, seperti heksadesimal (``\xff``) dan escape unicode (``\u20ac``).

* Literal string Unicode sekarang didukung untuk mengakomodasi urutan UTF-8 yang valid. Mereka diidentifikasi
  dengan awalan: ``unicode"Hello 😃"``.

* State Mutability: Perubahan status fungsi sekarang dapat dibatasi selama pewarisan:
  Fungsi dengan mutabilitas status default dapat ditimpa oleh fungsi ``pure`` dan ``view``
  sementara fungsi ``view`` dapat ditimpa oleh fungsi ``pure``.
  Pada saat yang sama, variabel state publik dianggap ``view`` dan bahkan ``pure``
  jika mereka adalah konstanta.



Inline Assembly
---------------

* Larang ``.`` dalam fungsi yang ditentukan pengguna dan nama variabel dalam inline assembly.
  Itu masih berlaku jika Anda menggunakan Solidity dalam mode Yul-only.

* Slot dan offset variabel penunjuk penyimpanan ``x`` diakses melalui ``x.slot``
  dan ``x.offset`` sebagai ganti ``x_slot`` dan ``x_offset``.

Penghapusan Fitur yang Tidak Digunakan atau Tidak Aman
======================================================

Mappings diluar Storage
-----------------------

* Jika sebuah struct atau array berisi mapping, itu hanya bisa digunakan dalam storage.
  Sebelumnya, mapping members diam-diam dilewati dalam memori, yang
  membingungkan dan rawan kesalahan.

* Assignmen ke structs atau arrays di storage tidak akan bekerja jika mereka mengandung
  mappings.
  Sebelumnya, mappings diam-diam dilewati selama operasi penyalinan, yang
  membingungkan dan rawan kesalahan.

Functions dan Events
--------------------

* Visibility (``public`` / ``internal``) tidak diperlukan lagi untuk konstruktor:
  Untuk mencegah kontrak dibuat, kontrak dapat ditandai ``abstract``.
  Ini membuat konsep visibilitas untuk konstruktor menjadi usang.

* Type Checker: Melarang ``virtual`` untuk fungsi library:
  Karena library tidak dapat diwarisi, fungsi perpustakaan tidak boleh virtual.

* Multiple events dengan nama yang sama dan tipe parameter dalam
  inheritance hierarchy yang sama, dilarang.

* ``using A for B`` hanya mempengaruhi kontrak yang disebutkan di dalamnya.
  Sebelumnya, efeknya diwariskan. Sekarang, Anda harus mengulangi ``menggunakan``
  pernyataan di semua kontrak turunan yang menggunakan fitur tersebut.

Expressions
-----------

* Shifts dengan tipe signed dilarang.
  Sebelumnya, pergeseran dengan jumlah negatif diizinkan, tetapi dikembalikan saat runtime.

* Denominasi ``finney`` dan ``szabo``telah dihilangkan.
  Mereka jarang digunakan dan tidak membuat jumlah sebenarnya mudah terlihat. Sebagai gantinya,
  nilai eksplisit seperti ``1e20`` atau ``gwei`` yang sangat umum dapat digunakan.

Declarations
------------

* Keyword ``var`` tidak dapat digunakan lagi.
  Sebelumnya, Keyword ini Previously, this keyword akan mengurai tetapi menghasilkan kesalahan tipe dan
  saran tentang jenis yang akan digunakan. Sekarang, ini menghasilkan kesalahan parser.

Perubahan Interface
===================

* JSON AST: Tandai literal string hex dengan ``kind: "hexString"``.
* JSON AST: Member dengan nilai ``null`` telah dihilangkan dari JSON output.
* NatSpec: Constructors adan functions mempunyai userdoc output yang konsisten.


Bagaimana cara memperbarui kode Anda?
=====================================

Bagian ini memberikan petunjuk terperinci tentang cara memperbarui kode sebelumnya untuk setiap breaking changes.

* Ubah ``x.f.value(...)()`` menjadi ``x.f{value: ...}()``. Serupa dengan ``(new C).value(...)()`` menjadi
  ``new C{value: ...}()`` dan ``x.f.gas(...).value(...)()`` menjadi ``x.f{gas: ..., value: ...}()``.
* Ubah ``now`` menjadi ``block.timestamp``.
* Ubah tipe dari operand kanan dalam operator sihft untuk tipe unsigned. Sebagai contoh ubah ``x >> (256 - y)`` menjadi
  ``x >> uint(256 - y)``.
* Ulangi pernyataan ``using A for B`` dalam semua *derived* kontrak jika dibutuhkan.
* Hilangkan Keyword ``public`` dari setiap constructor.
* Hilangkan Keyword ``internal`` dari setiap constructor dan tambahkan ``abstract`` ke kontrak (jika belum ditampilkan).
* Ubah suffixes ``_slot`` dan ``_offset`` dalam inline assembly menjadi ``.slot`` dan ``.offset``, berturutan.
