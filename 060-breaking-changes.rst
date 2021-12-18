********************************
Solidity v0.6.0 Breaking Changes
********************************

Bagian ini menyoroti perubahan utama yang diperkenalkan di Solidity
versi 0.6.0, beserta alasan di balik perubahan dan cara memperbarui
kode yang terpengaruh.
Untuk daftar lengkap cek
`release changelog <https://github.com/ethereum/solidity/releases/tag/v0.6.0>`_.


Perubahan yang Mungkin Tidak Diperingatkan oleh Kompiler
========================================================

Bagian ini mencantumkan perubahan di mana perilaku kode Anda mungkin
berubah tanpa kompiler memberi tahu Anda tentang hal itu.

* Jenis eksponensial yang dihasilkan adalah jenis basis. Dulunya adalah tipe terkecil
  yang dapat menampung tipe basis dan tipe eksponen, seperti halnya operasi simetris.
  Selain itu, jenis yang ditandatangani diperbolehkan untuk dasar eksponensial.


Persyaratan Eksplisititas
=========================

Bagian ini mencantumkan perubahan di mana kode sekarang perlu lebih eksplisit,
tetapi semantik tidak berubah.
Untuk sebagian besar topik, kompiler akan memberikan saran.

* Fungsi sekarang hanya dapat ditimpa jika ditandai dengan kata kunci ``virtual`` atau
  didefinisikan dalam antarmuka. Fungsi tanpa implementasi di luar antarmuka harus ditandai
  ``virtual``. Saat mengganti fungsi atau pengubah, kata kunci baru ``override`` harus digunakan.
  Saat mengganti fungsi atau pengubah yang didefinisikan dalam beberapa basis paralel, semua basis
  harus dicantumkan dalam tanda kurung setelah kata kunci seperti: ``override(Base1, Base2)``.

* Akses anggota ke ``length`` array sekarang selalu read-only, bahkan untuk array penyimpanan.
  Tidak mungkin lagi mengubah ukuran array penyimpanan dengan menetapkan nilai baru pada panjangnya.
  Gunakan ``push()``, ``push(value)`` atau ``pop()`` sebagai gantinya, atau tetapkan array lengkap, yang
  tentu saja akan menimpa konten yang ada. Alasan di balik ini adalah untuk mencegah tabrakan penyimpanan
  dari stack penyimpanan raksasa.

* Kata kunci baru ``abstract`` bisa digunakan untuk menandai kontrak sebagai abstrak. Itu harus digunakan
  jika kontrak tidak menjalankan semua fungsinya. Kontrak abstrak tidak dapat dibuat menggunakan operator
  ``new``, dan tidak mungkin menghasilkan bytecode untuk kontrak tersebut selama kompilasi.

* Libraries harus menjalankan semua fungsinya, tidak hanya internal.

* Nama variabel yang dideklarasikan dalam perakitan inline tidak boleh lagi diakhiri dengan ``_slot`` atau ``_offset``.

* Deklarasi variabel dalam rakitan sebaris mungkin tidak lagi membayangi deklarasi apa pun di luar blok inline assembly.
  Jika nama mengandung titik, awalan hingga titik tidak boleh bertentangan dengan deklarasi apa pun di luar inline
  assembly blok.

* Pembayangan variabel state sekarang tidak diizinkan. Kontrak turunan hanya bisa
  mendeklarasikan variabel state ``x``, jika tidak ada variabel state yang terlihat dengan
  nama yang sama di salah satu basisnya.


Perubahan Semantic dan Syntactic
================================

Bagian ini mencantumkan perubahan di mana Anda harus mengubah kode Anda
dan itu melakukan sesuatu yang lain setelahnya.

* Konversi dari jenis fungsi eksternal ke ``address`` sekarang tidak diizinkan. Sebagai gantinya,
  tipe fungsi eksternal memiliki anggota yang disebut ``address``, mirip dengan anggota ``selector`` yang ada.

* Fungsi ``Push(value)`` untuk array penyimpanan dinamis tidak lagi mengembalikan panjang baru (tidak mengembalikan apa pun).

* Fungsi yang tidak disebutkan namanya yang biasa disebut sebagai "fungsi fallback" dipecah menjadi fungsi fallback baru
  yang didefinisikan menggunakan kata kunci ``fallback`` dan fungsi receive ether yang ditentukan
  menggunakan kata kunci ``receive``.

  * Jika ada, fungsi receiver ether dipanggil setiap kali data panggilan kosong (baik ether
    diterima atau tidak). Fungsi ini secara implisit ``payable``.

  * Fungsi fallback baru dipanggil ketika tidak ada fungsi lain yang cocok (jika fungsi penerima
    ether tidak ada maka ini termasuk panggilan dengan data panggilan kosong). Anda dapat membuat
    fungsi ini ``dapat dibayar`` atau tidak. Jika tidak ``payable`` maka transaksi yang tidak cocok
    dengan fungsi lain yang mengirim nilai akan dikembalikan. Anda hanya perlu mengimplementasikan
    fungsi fallback baru jika Anda mengikuti pola upgrade atau proxy.


Fitur Baru
==========

Bagian ini mencantumkan hal-hal yang tidak mungkin dilakukan sebelum Solidity 0.6.0
atau lebih sulit untuk dicapai.

* Pernyataan :ref:`try/catch <try-catch>` memungkinkan Anda bereaksi pada panggilan eksternal yang gagal.
* Tipe ``struct`` dan ``enum`` dapat dideklarasikan pada level file.
* Array slices dapat digunakan untuk array data panggilan, misalnya ``abi.decode(msg.data[4:], (uint, uint))``
  adalah cara tingkat rendah untuk memecahkan kode payload panggilan fungsi.
* Natspec mendukung beberapa parameter pengembalian dalam dokumentasi pengembang, memberlakukan pemeriksaan penamaan yang sama dengan ``@param``.
* Yul dan Inline Assembly memiliki pernyataan baru yang disebut ``leave`` yang keluar dari fungsi saat ini.
* Konversi dari ``address`` ke ``address payable`` sekarang dapat dilakukan melalui ``payable(x)``, di mana
  ``x`` harus bertipe ``address``.


Perubahan Interface
===================

Bagian ini mencantumkan perubahan yang tidak terkait dengan bahasa itu sendiri, tetapi memiliki efek pada antarmuka
kompiler. Ini dapat mengubah cara Anda menggunakan kompiler pada baris perintah, cara Anda menggunakan antarmuka
yang dapat diprogram, atau cara Anda menganalisis output yang dihasilkan olehnya.

Reporter Error Baru
~~~~~~~~~~~~~~~~~~~

Reporter kesalahan baru diperkenalkan, yang bertujuan untuk menghasilkan pesan kesalahan yang lebih mudah diakses di baris perintah.
Ini diaktifkan secara default, tetapi meneruskan ``--old-reporter`` akan mengembalikan ke pelapor kesalahan lama yang tidak digunakan lagi.

Metadata Hash Options
~~~~~~~~~~~~~~~~~~~~~

Kompiler sekarang menambahkan hash `IPFS <https://ipfs.io/>`_ dari file metadata ke akhir bytecode secara default
(untuk detailnya, lihat dokumentasi di :doc:`contract metadata <metadata>`). Sebelum 0.6.0, kompiler menambahkan
`Swarm <https://ethersphere.github.io/swarm-home/>`_ hash secara default, dan untuk tetap mendukung perilaku ini,
opsi baris perintah baru ``--metadata-hash`` diperkenalkan. Ini memungkinkan Anda untuk memilih hash yang akan diproduksi dan
ditambahkan, dengan meneruskan ``ipfs`` atau ``swarm`` sebagai nilai ke opsi baris perintah ``--metadata-hash``.
Meneruskan nilai ``none`` akan menghapus hash sepenuhnya.

Perubahan ini juga dapat digunakan melalui :ref:`Standard JSON Interface<compiler-api>` dan mempengaruhi metadata JSON yang dihasilkan oleh compiler.

Cara yang direkomendasikan untuk membaca metadata adalah dengan membaca dua byte terakhir untuk menentukan panjang pengkodean CBOR
dan lakukan decoding yang tepat pada blok data tersebut seperti yang dijelaskan di :ref:`bagian metadata<encoding-of-the-metadata-hash-in-the-bytecode>`.

Yul Optimizer
~~~~~~~~~~~~~

Bersama dengan pengoptimal bytecode lama, pengoptimal :doc:`Yul <yul>` sekarang diaktifkan secara default saat Anda memanggil kompilator
dengan ``--mengoptimalkan``. Itu dapat dinonaktifkan dengan memanggil kompiler dengan ``--no-optimize-yul``.
Ini sebagian besar memengaruhi kode yang menggunakan ABI coder v2.

Perubahan API C
~~~~~~~~~~~~~~~

Kode klien yang menggunakan C API dari ``libsolc`` sekarang mengendalikan memori yang digunakan oleh kompiler. Untuk membuat
perubahan ini konsisten, ``solidity_free`` diubah namanya menjadi ``solidity_reset``, fungsi ``solidity_alloc`` dan
``solidity_free`` telah ditambahkan dan ``solidity_compile`` sekarang mengembalikan string yang harus dibebaskan secara eksplisit melalui
``solidity_free()``.


Bagaimana cara memperbarui kode Anda?
=====================================

Bagian ini memberikan petunjuk terperinci tentang cara memperbarui kode sebelumnya untuk setiap perubahan yang melanggar.

* Ubah ``address(f)`` menjadi ``f.address`` karena ``f`` bertipe fungsi eksternal.

* Ganti ``function () external [payable] { ... }`` oleh salah satu dari ``receive() external payable { ... }``,
  ``fallback() external [payable] { ... }`` atau keduanya. Memilih
  menggunakan fungsi ``receive`` saja, bila memungkinkan.

* Ubah ``uint length = array.push(value)`` menjadi ``array.push(value);``. Panjang baru dapat
  diakses melalui ``array.length``.

* Ubah ``array.length++`` menjadi ``array.push()`` untuk meningkatkan, dan gunakan ``pop()`` untuk mengurangi
  panjang array penyimpanan.

* Untuk setiap parameter pengembalian bernama dalam dokumentasi ``@dev`` suatu fungsi, tentukan entri
  ``@return`` yang berisi nama parameter sebagai kata pertama. Misalnya. jika Anda memiliki fungsi
  ``f()`` yang didefinisikan seperti ``function f() public returns (uint value)`` dan anotasi ``@dev``, dokumentasikan
  parameter pengembaliannya seperti: ``@return value The return value.``. Anda dapat mencampur dokumentasi
  parameter pengembalian bernama dan tidak bernama selama pemberitahuan berada dalam urutan yang
  muncul dalam tipe pengembalian Tuple.

* Pilih pengidentifikasi unik untuk deklarasi variabel di inline assembly yang tidak bertentangan
  dengan deklarasi di luar blok rakitan sebaris.

* Tambahkan ``virtual`` ke setiap fungsi non-antarmuka yang ingin Anda timpa. Tambahkan ``virtual``
  ke semua fungsi tanpa implementasi di luar antarmuka. Untuk pewarisan tunggal, tambahkan ``override``
  ke setiap fungsi utama. Untuk pewarisan berganda, tambahkan ``override(A, B, ..)``, tempat Anda
  mencantumkan semua kontrak yang mendefinisikan fungsi yang diganti dalam tanda kurung. Ketika beberap
  basis mendefinisikan fungsi yang sama, kontrak pewarisan harus mengesampingkan semua fungsi yang bertentangan.
