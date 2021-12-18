.. index:: Bugs

.. _known_bugs:

#########################
Daftar Bug yang Diketahui
#########################

Di bawah, Anda dapat menemukan daftar berformat JSON dari beberapa bug terkait keamanan yang diketahui di
Kompiler solidity. File itu sendiri di-host di `repositori Github
<https://github.com/ethereum/solidity/blob/develop/docs/bugs.json>`_.
Daftar ini terbentang hingga versi 0.3.0, bug yang diketahui hanya ada
dalam versi sebelumnya yang tidak terdaftar.

Ada file lain bernama `bugs_by_version.json
<https://github.com/ethereum/solidity/blob/develop/docs/bugs_by_version.json>`_,
yang dapat digunakan untuk memeriksa bug mana yang memengaruhi versi kompiler tertentu.

Alat verifikasi sumber kontrak dan juga alat lain yang berinteraksi dengan
kontrak harus berkonsultasi dengan daftar ini sesuai dengan kriteria berikut:

- Agak mencurigakan jika kontrak dikompilasi dengan versi kompiler nightly,
  bukan versi yang dirilis. Daftar ini tidak melacak versi yang belum dirilis
  atau versi nightly.
- Juga agak mencurigakan jika kontrak dikompilasi dengan versi yang bukan yang
  terbaru pada saat kontrak dibuat. Untuk kontrak yang dibuat dari kontrak lain,
  Anda harus mengikuti rantai pembuatan kembali ke transaksi dan menggunakan tanggal
  transaksi tersebut sebagai tanggal pembuatan.
- Sangat mencurigakan jika kontrak dikompilasi dengan kompiler yang berisi bug yang
  diketahui dan kontrak dibuat pada saat versi kompiler yang lebih baru yang berisi
  perbaikan sudah dirilis.

File JSON dari bug yang diketahui di bawah ini adalah array objek, satu untuk setiap bug,
dengan kunci berikut:

uid
    Pengenal unik yang diberikan untuk bug dalam bentuk ``SOL-<year>-<number>``.
    Ada kemungkinan bahwa ada beberapa entri dengan uid yang sama. Ini berarti
    beberapa rentang versi dipengaruhi oleh bug yang sama.
name
    Nama unik yang diberikan untuk bug
summary
    Deskripsi singkat tentang bug
description
    Deskripsi rinci tentang bug
link
    URL situs web dengan informasi lebih rinci, opsional
introduced
    Versi kompiler pertama yang diterbitkan yang berisi bug, opsional
fixed
    Versi kompiler pertama yang diterbitkan yang tidak mengandung bug lagi
publish
    Tanggal saat bug diketahui publik, opsional
severity
    Tingkat keparahan bug: sangat rendah, rendah, sedang, tinggi. Mempertimbangkan
    kemampuan untuk ditemukan dalam pengujian kontrak, kemungkinan terjadinya, dan
    potensi kerusakan akibat eksploitasi.
conditions
    Kondisi yang harus dipenuhi untuk memicu bug. Kunci berikut
    dapat digunakan:
    ``optimizer``, nilai boolean yang
    berarti pengoptimal harus diaktifkan untuk mengaktifkan bug.
    ``evmVersion``, string yang menunjukkan setelan kompiler
    versi EVM mana yang memicu bug. String dapat berisi operator
    perbandingan. Misalnya, ``">=constantinopel"`` berarti bug
    ada ketika versi EVM diatur ke ``constantinople`` atau
    nanti.
    Jika tidak ada kondisi yang diberikan, asumsikan bahwa bug tetap ada.
check
    Bidang ini berisi pemeriksaan berbeda yang melaporkan apakah kontrak pintar
    mengandung bug atau tidak. Jenis pemeriksaan pertama adalah ekspresi Javascript
    reguler yang akan dicocokkan dengan kode sumber ("source-regex")
    jika bug itu ada.  Jika tidak ada kecocokan, maka kemungkinan besar bug tersebut
    tidak ada. Jika ada kecocokan, bug mungkin ada. Untuk meningkatkan akurasi,
    pemeriksaan harus diterapkan ke kode sumber setelah menghapus komentar.
    Jenis pemeriksaan kedua adalah pola yang akan diperiksa pada compact AST dari
    program Solidity ("ast-compact-json-path"). Kueri penelusuran yang ditentukan
    adalah ekspresi `JsonPath <https://github.com/json-path/JsonPath>`_.
    Jika setidaknya satu jalur AST Soliditas cocok dengan kueri, kemungkinan besar bug ada.

.. literalinclude:: bugs.json
   :language: js
