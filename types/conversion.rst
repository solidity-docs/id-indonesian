.. index:: ! type;conversion, ! cast

.. _types-conversion-elementary-types:

Konversi antara Tipe Elementary
===============================

Konversi Implisit
-----------------

Konversi tipe implisit secara otomatis diterapkan oleh kompiler dalam beberapa kasus
selama assignment, saat meneruskan argumen ke fungsi dan saat menerapkan operator.
Secara umum, konversi implisit antara tipe-nilai dimungkinkan jika masuk akal
secara semantik dan tidak ada informasi yang hilang.

Misalnya, ``uint8`` dapat dikonversi ke
``uint16`` dan ``int128`` menjadi ``int256``, tetapi ``int8`` tidak dapat dikonversi menjadi ``uint256``,
karena ``uint256`` tidak dapat menyimpan nilai seperti ``-1``.

Jika operator diterapkan ke tipe yang berbeda, kompiler mencoba untuk secara implisit
mengonversi salah satu operand ke tipe yang lain (hal yang sama berlaku untuk assignment).
Ini berarti bahwa operasi selalu dilakukan dalam jenis salah satu operand.

Untuk detail selengkapnya tentang konversi implisit mana yang memungkinkan,
silakan berkonsultasi bagian tentang tipe itu sendiri.

Pada contoh di bawah ini, ``y`` dan ``z``, operand penambahan,
tidak memiliki tipe yang sama, tetapi ``uint8`` dapat
secara implisit dikonversi ke ``uint16`` dan bukan sebaliknya. sebaliknya.
Karena itu, ``y`` dikonversi ke tipe ``z`` sebelum penambahan dilakukan
dalam tipe ``uint16``. Tipe ekspresi yang dihasilkan ``y + z`` adalah ``uint16``.
Karena ditugaskan ke variabel tipe ``uint32``, konversi implisit lain
dilakukan setelah penambahan.

.. code-block:: solidity

    uint8 y;
    uint16 z;
    uint32 x = y + z;


Konversi Eksplisit
------------------

Jika kompiler tidak mengizinkan konversi implisit tetapi Anda yakin konversi akan berhasil,
konversi tipe eksplisit terkadang dimungkinkan. Ini mungkin
menghasilkan perilaku yang tidak terduga dan memungkinkan Anda untuk melewati beberapa keamanan
fitur kompiler, jadi pastikan untuk menguji bahwa
hasilnya adalah apa yang Anda inginkan dan harapkan!

Take the following example that converts a negative ``int`` to a ``uint``:

.. code-block:: solidity

    int  y = -3;
    uint x = uint(y);

Di akhir cuplikan kode ini, ``x`` akan memiliki nilai ``0xfffff..fd`` (64
karakter hex), yaitu -3 dalam dua representasi komplemen 256 bit.

Jika integer secara eksplisit dikonversi ke tipe yang lebih kecil, bit *higher-order*
terpotong:

.. code-block:: solidity

    uint32 a = 0x12345678;
    uint16 b = uint16(a); // b will be 0x5678 now

Jika integer secara eksplisit dikonversi ke tipe yang lebih besar, itu diisi di sebelah kiri (yaitu, di ujung urutan yang lebih tinggi).
Hasil konversi akan dibandingkan sama dengan integer asli:

.. code-block:: solidity

    uint16 a = 0x1234;
    uint32 b = uint32(a); // b will be 0x00001234 now
    assert(a == b);

Tipe Fixed-size bytes berperilaku berbeda selama konversi.
Mereka dapat dianggap sebagai urutan byte individu dan mengonversi
ke tipe yang lebih kecil akan memotong urutan:

.. code-block:: solidity

    bytes2 a = 0x1234;
    bytes1 b = bytes1(a); // b will be 0x12

Jika tipe fixed-size bytes secara eksplisit dikonversi ke tipe yang lebih besar, itu diisi di sebelah kanan.
Mengakses byte pada indeks tetap akan menghasilkan nilai yang sama sebelum dan
sesudah konversi (jika indeks masih dalam kisaran):

.. code-block:: solidity

    bytes2 a = 0x1234;
    bytes4 b = bytes4(a); // b will be 0x12340000
    assert(a[0] == b[0]);
    assert(a[1] == b[1]);

Karena integer dan array byte ukuran tetap berperilaku berbeda saat truncating atau
padding, konversi eksplisit antara integer dan array byte fixed-size hanya diperbolehkan,
jika keduanya memiliki ukuran yang sama. Jika Anda ingin mengonversi antara integer dan array byte fixed-size
dengan ukuran berbeda, Anda harus menggunakan konversi menengah yang membuat aturan eksplisit untuk pemotongan dan padding
yang diinginkan:

.. code-block:: solidity

    bytes2 a = 0x1234;
    uint32 b = uint16(a); // b will be 0x00001234
    uint32 c = uint32(bytes4(a)); // c will be 0x12340000
    uint8 d = uint8(uint16(a)); // d will be 0x34
    uint8 e = uint8(bytes1(a)); // e will be 0x12

``bytes`` array dan ``bytes`` calldata slices dapat dikonversi secara eksplisit ke tipe fixed byte (``bytes1``/.../``bytes32``).
Jika array lebih panjang dari tipe byte fixed target, pemotongan pada akhirnya akan terjadi.
Jika array lebih pendek dari tipe target, array akan diisi dengan nol di akhir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.5;

    contract C {
        bytes s = "abcdefgh";
        function f(bytes calldata c, bytes memory m) public view returns (bytes16, bytes3) {
            require(c.length == 16, "");
            bytes16 b = bytes16(m);  // if length of m is greater than 16, truncation will happen
            b = bytes16(s);  // padded on the right, so result is "abcdefgh\0\0\0\0\0\0\0\0"
            bytes3 b1 = bytes3(s); // truncated, b1 equals to "abc"
            b = bytes16(c[:8]);  // also padded with zeros
            return (b, b1);
        }
    }

.. _types-conversion-literals:

Konversi antara Tipe Literal dan Elementary
===========================================

Tipe Integer
------------

Literal angka desimal dan heksadesimal dapat secara implisit dikonversi ke tipe integer apa pun yang
cukup besar untuk mewakilinya tanpa pemotongan:

.. code-block:: solidity

    uint8 a = 12; // fine
    uint32 b = 1234; // fine
    uint16 c = 0x123456; // fails, since it would have to truncate to 0x3456

.. note::
    Sebelum versi 0.8.0, literal angka desimal atau heksadesimal apa pun dapat secara eksplisit
    dikonversi ke tipe integer. Dari 0.8.0, konversi eksplisit seperti itu sama ketatnya dengan konversi implisit,
    yaitu, konversi hanya diperbolehkan jika literal cocok dengan rentang yang dihasilkan.

Fixed-Size Byte Arrays
----------------------

Sebelum versi 0.8.0, literal angka desimal atau heksadesimal apa pun dapat secara eksplisit
dikonversi ke tipe integer. Dari 0.8.0, konversi eksplisit seperti itu sama ketatnya dengan
konversi implisit, yaitu, konversi hanya diperbolehkan jika literal cocok dengan
rentang yang dihasilkan.

.. code-block:: solidity

    bytes2 a = 54321; // not allowed
    bytes2 b = 0x12; // not allowed
    bytes2 c = 0x123; // not allowed
    bytes2 d = 0x1234; // fine
    bytes2 e = 0x0012; // fine
    bytes4 f = 0; // fine
    bytes4 g = 0x0; // fine

Literal string dan literal string hex dapat secara implisit dikonversi ke array byte fixed-size,
jika jumlah karakternya cocok dengan ukuran tipe byte:

.. code-block:: solidity

    bytes2 a = hex"1234"; // fine
    bytes2 b = "xy"; // fine
    bytes2 c = hex"12"; // not allowed
    bytes2 d = hex"123"; // not allowed
    bytes2 e = "x"; // not allowed
    bytes2 f = "xyz"; // not allowed

Addresses
---------

Seperti yang dijelaskan dalam :ref:`address_literals`, literal heksadesimal dengan ukuran yang benar yang
lulus uji checksum bertipe ``address``. Tidak ada literal lain yang dapat secara implisit dikonversi ke tipe ``address``.

Konversi eksplisit dari ``bytes20`` atau tipe integer apa pun ke ``address`` menghasilkan ``address payable``.

``address a`` dapat dikonversi menjadi ``address payable`` melalui ``payable(a)``.
