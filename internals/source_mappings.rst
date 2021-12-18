.. index:: source mappings

***************
Source Mapping
***************

Sebagai bagian dari output AST, kompilator menyediakan rentang kode sumber yang diwakili
oleh masing-masing node di AST. Ini dapat digunakan untuk berbagai tujuan mulai dari alat
analisis statis yang melaporkan kesalahan berdasarkan AST dan alat debugging yang menyoroti
variabel lokal dan penggunaannya.

Selanjutnya, kompiler juga dapat menghasilkan mapping dari bytecode ke kisaran
dalam kode sumber yang menghasilkan instruksi. sekali lagi Ini penting untuk alat analisis statis yang beroperasi
pada tingkat bytecode dan untuk menampilkan posisi saat ini dalam kode sumber di dalam debugger
atau untuk penanganan breakpoint. Pemetaan ini juga berisi informasi lain, seperti jenis lompatan
dan kedalaman modifier (lihat di bawah).

Kedua jenis mapping sumber menggunakan pengidentifikasi integer untuk merujuk ke file sumber.
Pengidentifikasi file sumber disimpan di
``output['sources'][sourceName]['id']`` dimana ``output`` merupakan output dari
antarmuka kompiler standard-json diuraikan sebagai JSON.
Untuk beberapa rutinitas utilitas, kompiler menghasilkan file sumber "internal" yang bukan
bagian dari input asli tetapi direferensikan dari sumber
mapping. File sumber ini bersama dengan pengidentifikasinya dapat
diperoleh melalui ``output['contracts'][sourceName][contractName]['evm']['bytecode']['generatedSources']``.

.. note ::
    Dalam hal instruksi yang tidak terkait dengan file sumber tertentu,
    mapping sumber menetapkan pengidentifikasi integer ``-1``. Ini mungkin terjadi untuk
    bagian bytecode yang berasal dari pernyataan inline assembly yang dihasilkan oleh kompiler.

Source mapping di dalam AST menggunakan notasi
berikut:

``s:l:f``

Dimana ``s`` adalah byte-offset ke awal rentang dalam file sumber,
``l`` adalah panjang rentang sumber dalam byte dan ``f`` adalah indeks
sumber yang disebutkan di atas.

Encoding didalam source mapping untuk bytecode lebih rumit:
Ini adalah daftar ``s:l:f:j:m`` yang dipisahkan oleh ``;``. Masing-masing
elemen sesuai dengan instruksi, yaitu Anda tidak dapat menggunakan byte offset
tetapi harus menggunakan instruksi offset (instruksi push lebih panjang dari satu byte).
Kolom ``s``, ``l`` dan ``f`` adalah seperti di atas. ``j`` bisa jadi
``i``, ``o`` atau ``-`` menandakan apakah instruksi jump masuk ke sebuah
fungsi, kembali dari suatu fungsi atau merupakan lompatan reguler sebagai bagian dari mis. sebuah loop.
Bidang terakhir, ``m``, adalah integer yang menunjukkan "kedalaman modifier". Kedalaman ini
meningkat setiap kali pernyataan placeholder (``_``) dimasukkan ke dalam modifier
dan berkurang jika dibiarkan lagi. Ini memungkinkan para debugger untuk melacak kasus-kasus rumit
seperti modifier yang sama digunakan dua kali atau beberapa pernyataan placeholder
digunakan dalam pengubah tunggal.

Untuk mengompresi source mapping ini terutama untuk bytecode,
aturan berikut digunakan:

- Jika bidang kosong, nilai elemen sebelumnya digunakan.
- Jika ``:`` tidak ada, semua bidang berikut dianggap kosong.

Ini berarti source mapping berikut mewakili informasi yang sama:

``1:2:1;1:9:1;2:1:2;2:1:2;2:1:2``

``1:2:1;:9;2:1:2;;``

Penting untuk dicatat bahwa ketika builtin :ref:`verbatim <yul-verbatim>` digunakan,
source mapping akan tidak valid: Builtin dianggap sebagai instruksi tunggal alih-alih berpotensi banyak.
