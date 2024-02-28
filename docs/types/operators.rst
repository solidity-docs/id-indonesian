.. index:: ! operator

<<<<<<< HEAD
Operator yang Melibatkan LValues
================================
=======
Operators
=========

Arithmetic and bit operators can be applied even if the two operands do not have the same type.
For example, you can compute ``y = x + z``, where ``x`` is a ``uint8`` and ``z`` has
the type ``uint32``. In these cases, the following mechanism will be used to determine
the type in which the operation is computed (this is important in case of overflow)
and the type of the operator's result:

1. If the type of the right operand can be implicitly converted to the type of the left
   operand, use the type of the left operand,
2. if the type of the left operand can be implicitly converted to the type of the right
   operand, use the type of the right operand,
3. otherwise, the operation is not allowed.

In case one of the operands is a :ref:`literal number <rational_literals>` it is first converted to its
"mobile type", which is the smallest type that can hold the value
(unsigned types of the same bit-width are considered "smaller" than the signed types).
If both are literal numbers, the operation is computed with effectively unlimited precision in
that the expression is evaluated to whatever precision is necessary so that none is lost
when the result is used with a non-literal type.

The operator's result type is the same as the type the operation is performed in,
except for comparison operators where the result is always ``bool``.

The operators ``**`` (exponentiation), ``<<``  and ``>>`` use the type of the
left operand for the operation and the result.

Ternary Operator
----------------
The ternary operator is used in expressions of the form ``<expression> ? <trueExpression> : <falseExpression>``.
It evaluates one of the latter two given expressions depending upon the result of the evaluation of the main ``<expression>``.
If ``<expression>`` evaluates to ``true``, then ``<trueExpression>`` will be evaluated, otherwise ``<falseExpression>`` is evaluated.

The result of the ternary operator does not have a rational number type, even if all of its operands are rational number literals.
The result type is determined from the types of the two operands in the same way as above, converting to their mobile type first if required.

As a consequence, ``255 + (true ? 1 : 0)`` will revert due to arithmetic overflow.
The reason is that ``(true ? 1 : 0)`` is of ``uint8`` type, which forces the addition to be performed in ``uint8`` as well,
and 256 exceeds the range allowed for this type.

Another consequence is that an expression like ``1.5 + 1.5`` is valid but ``1.5 + (true ? 1.5 : 2.5)`` is not.
This is because the former is a rational expression evaluated in unlimited precision and only its final value matters.
The latter involves a conversion of a fractional rational number to an integer, which is currently disallowed.

.. index:: assignment, lvalue, ! compound operators

Compound and Increment/Decrement Operators
------------------------------------------
>>>>>>> english/develop

Jika ``a`` adalah sebuah LValue (mis. variabel atau sesuatu yang dapat ditugaskan untuk),
operator berikut tersedia sebagai singkatan:

``a += e`` setara dengan ``a = a + e``. Operator ``-=``, ``*=``, ``/=``, ``%=``,
``|=``, ``&=``, ``^=``, ``<<=`` dan ``>>=`` didefinisikan sesuai. ``a++`` dan ``a--`` setara dengan
``a += 1`` / ``a -= 1`` tetapi ekspresi itu sendiri masih memiliki nilai sebelumnya
dari ``a``. Sebaliknya, ``--a`` dan ``++a`` memiliki efek yang sama pada ``a`` tetapi
mengembalikan nilai setelah perubahan.

.. index:: !delete

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

.. index:: ! operator; precedence
.. _order:

Order of Precedence of Operators
--------------------------------

.. include:: types/operator-precedence-table.rst
