.. index: variable cleanup

*********************
Cleaning Up Variabel
*********************

<<<<<<< HEAD
Ketika nilai lebih pendek dari 256 bit, dalam beberapa kasus bit yang tersisa harus dibersihkan.
Kompiler Solidity dirancang untuk membersihkan bit yang tersisa sebelum operasi apa pun yang
mungkin terpengaruh oleh potensi sampah dalam bit yang tersisa.
Misalnya, sebelum menulis nilai ke memori, bit yang tersisa perlu
dibersihkan karena isi memori dapat digunakan untuk komputasi
hash atau dikirim sebagai data panggilan pesan. Demikian pula, sebelumnya
menyimpan nilai dalam penyimpanan, bit yang tersisa perlu dibersihkan
karena jika tidak, nilai *garbled* dapat diamati.
=======
Ultimately, all values in the EVM are stored in 256 bit words.
Thus, in some cases, when the type of a value has less than 256 bits,
it is necessary to clean the remaining bits.
The Solidity compiler is designed to do such cleaning before any operations
that might be adversely affected by the potential garbage in the remaining bits.
For example, before writing a value to  memory, the remaining bits need
to be cleared because the memory contents can be used for computing
hashes or sent as the data of a message call.  Similarly, before
storing a value in the storage, the remaining bits need to be cleaned
because otherwise the garbled value can be observed.
>>>>>>> english/develop

Perhatikan bahwa akses melalui inline assembly tidak dianggap sebagai operasi seperti itu:
Jika Anda menggunakan inline assembly untuk mengakses variabel Solidityyang lebih pendek
dari 256 bit, kompiler tidak menjamin bahwa nilainya dibersihkan dengan benar.

Selain itu, kami tidak membersihkan bit jika operasiberikut segera tidak terpengaruh. Misalnya,
karena setiap nilai non-zero dianggap ``true`` oleh instruksi ``JUMPI``, kami tidak membersihkan
nilai boolean sebelum digunakan sebagai kondisi untuk ``JUMPI``.

Selain prinsip desain di atas, compiler Solidity
membersihkan data input saat dimuat ke stack.

<<<<<<< HEAD
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
=======
The following table describes the cleaning rules applied to different types,
where ``higher bits`` refers to the remaining bits in case the type has less than 256 bits.

+---------------+---------------+-------------------------+
|Type           |Valid Values   |Cleanup of Invalid Values|
+===============+===============+=========================+
|enum of n      |0 until n - 1  |throws exception         |
|members        |               |                         |
+---------------+---------------+-------------------------+
|bool           |0 or 1         |results in 1             |
+---------------+---------------+-------------------------+
|signed integers|higher bits    |currently silently       |
|               |set to the     |signextends to a valid   |
|               |sign bit       |value, i.e. all higher   |
|               |               |bits are set to the sign |
|               |               |bit; may throw an        |
|               |               |exception in the future  |
+---------------+---------------+-------------------------+
|unsigned       |higher bits    |currently silently masks |
|integers       |zeroed         |to a valid value, i.e.   |
|               |               |all higher bits are set  |
|               |               |to zero; may throw an    |
|               |               |exception in the future  |
+---------------+---------------+-------------------------+

Note that valid and invalid values are dependent on their type size.
Consider ``uint8``, the unsigned 8-bit type, which has the following valid values:

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

Any invalid value will have the higher bits set to zero:

.. code-block:: none

    0101...1101 0010 1010   invalid value
    0000...0000 0010 1010   cleaned value

For ``int8``, the signed 8-bit type, the valid values are:

Negative

.. code-block:: none

    1111...1111 1111 1111
    1111...1111 1111 1110
    ....
    1111...1111 1000 0000

Positive

.. code-block:: none

    0000...0000 0000 0000
    0000...0000 0000 0001
    0000...0000 0000 0010
    ....
    0000...0000 1111 1111

The compiler will ``signextend`` the sign bit, which is 1 for negative and 0 for
positive values, overwriting the higher bits:

Negative

.. code-block:: none

    0010...1010 1111 1111   invalid value
    1111...1111 1111 1111   cleaned value

Positive

.. code-block:: none

    1101...0101 0000 0100   invalid value
    0000...0000 0000 0100   cleaned value
>>>>>>> english/develop
