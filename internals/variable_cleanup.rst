.. index: variable cleanup

*********************
Cleaning Up Variabel
*********************

Ketika nilai lebih pendek dari 256 bit, dalam beberapa kasus bit yang tersisa harus dibersihkan.
Kompiler Solidity dirancang untuk membersihkan bit yang tersisa sebelum operasi apa pun yang
mungkin terpengaruh oleh potensi sampah dalam bit yang tersisa.
Misalnya, sebelum menulis nilai ke memori, bit yang tersisa perlu
dibersihkan karena isi memori dapat digunakan untuk komputasi
hash atau dikirim sebagai data panggilan pesan. Demikian pula, sebelumnya
menyimpan nilai dalam penyimpanan, bit yang tersisa perlu dibersihkan
karena jika tidak, nilai *garbled* dapat diamati.

Perhatikan bahwa akses melalui inline assembly tidak dianggap sebagai operasi seperti itu:
Jika Anda menggunakan inline assembly untuk mengakses variabel Solidityyang lebih pendek
dari 256 bit, kompiler tidak menjamin bahwa nilainya dibersihkan dengan benar.

Selain itu, kami tidak membersihkan bit jika operasiberikut segera tidak terpengaruh. Misalnya,
karena setiap nilai non-zero dianggap ``true`` oleh instruksi ``JUMPI``, kami tidak membersihkan
nilai boolean sebelum digunakan sebagai kondisi untuk ``JUMPI``.

Selain prinsip desain di atas, compiler Solidity
membersihkan data input saat dimuat ke stack.

Tipe yang berbeda memiliki aturan berbeda untuk membersihkan nilai yang tidak valid:

+---------------+---------------+-------------------+
|Tipe           | Nilai Valid   | Nilai Invalid Mean|
+===============+===============+===================+
|enum of n      |0 until n - 1  |exception          |
|members        |               |                   |
+---------------+---------------+-------------------+
|bool           |0 or 1         |1                  |
+---------------+---------------+-------------------+
|signed integers|sign-extended  |saat ini diam-diam |
|               |word           |wraps; di masa     |
|               |               |depan eksepsi      |
|               |               |akan diberikan     |
|               |               |                   |
|               |               |                   |
+---------------+---------------+-------------------+
|unsigned       |higher bits    |saat ini diam-diam |
|integers       |zeroed         |wraps; di masa     |
|               |               |depan eksepsi      |
|               |               |akan diberikan     |
+---------------+---------------+-------------------+
