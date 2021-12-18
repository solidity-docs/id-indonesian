.. index:: assignment, ! delete, lvalue

Operator yang Melibatkan LValues
================================

Jika ``a`` adalah sebuah LValue (mis. variabel atau sesuatu yang dapat ditugaskan untuk),
operator berikut tersedia sebagai singkatan:

``a += e`` setara dengan ``a = a + e``. Operator ``-=``, ``*=``, ``/=``, ``%=``,
``|=``, ``&=``, ``^=``, ``<<=`` dan ``>>=`` didefinisikan sesuai. ``a++`` dan ``a--`` setara dengan
``a += 1`` / ``a -= 1`` tetapi ekspresi itu sendiri masih memiliki nilai sebelumnya
dari ``a``. Sebaliknya, ``--a`` dan ``++a`` memiliki efek yang sama pada ``a`` tetapi
mengembalikan nilai setelah perubahan.

.. _delete:

delete
------

``delete a`` memberikan nilai awal untuk tipe tersebut ke ``a``. yakni untuk integer adalah
setara dengan ``a = 0``, tetapi juga dapat digunakan pada array, di mana ia menetapkan array
dinamis dengan panjang nol atau array statis dengan panjang yang sama dengan semua elemen disetel ke
nilai awal. ``delete a[x]`` menghapus item di indeks ``x`` dari array dan membiarkan semua
elemen lain dan panjang array tidak tersentuh. Ini terutama berarti bahwa ia meninggalkan
celah dalam array. Jika Anda berencana untuk menghapus item, :ref:`mapping <mapping-types>` mungkin
merupakan pilihan yang lebih baik.

Untuk struct, ini menetapkan struct dengan semua member direset. Dengan kata lain,
nilai ``a`` setelah ``delete a`` sama dengan jika ``a`` akan dideklarasikan
tanpa assignment, dengan peringatan berikut:

``delete`` tidak berpengaruh pada mappings (karena kunci mapping mungkin arbitrer dan
umumnya tidak diketahui). Jadi jika Anda menghapus struct, itu akan mengatur ulang semua anggota yang
bukan mapping dan juga berulang menjadi anggota kecuali mereka adalah mapping.
Namun, kunci individual dan apa yang di*mapa8 dapat dihapus: Jika ``a`` adalah
mapping, maka ``delete a[x]`` akan menghapus nilai yang disimpan di ``x``.

Penting untuk dicatat bahwa ``delete a`` benar-benar berperilaku seperti
assignment ke ``a``, yaitu menyimpan objek baru di ``a``.
Perbedaan ini terlihat ketika ``a`` adalah variabel referensi: Ini
hanya akan mereset ``a`` itu sendiri, bukan nilai
yang dirujuk sebelumnya.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract DeleteExample {
        uint data;
        uint[] dataArray;

        function f() public {
            uint x = data;
            delete x; // sets x to 0, does not affect data
            delete data; // sets data to 0, does not affect x
            uint[] storage y = dataArray;
            delete dataArray; // this sets dataArray.length to zero, but as uint[] is a complex object, also
            // y is affected which is an alias to the storage object
            // On the other hand: "delete y" is not valid, as assignments to local variables
            // referencing storage objects can only be made from existing storage objects.
            assert(y.length == 0);
        }
    }
