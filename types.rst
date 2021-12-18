.. index:: type

.. _types:

*****
Types
*****

Solidity adalah bahasa yang diketik secara statis, yang berarti bahwa jenis masing-masing
variabel (state dan lokal) perlu ditentukan.
Solidity menyediakan beberapa type dasar yang dapat digabungkan untuk membentuk type kompleks.

Selain itu, type dapat berinteraksi satu sama lain dalam ekspresi yang mengandung operator.
Untuk referensi cepat dari berbagai operator, lihat :ref:`order`.

Konsep nilai "undefined" atau "null" tidak ada di Solidity, tetapi variabel yang baru
dideklarasikan selalu memiliki :ref:`default value<default-value>` bergantung pada tipenya.
Untuk menangani nilai yang tidak diharapkan, Anda harus menggunakan :ref:`revert function<assert-and-require>`
untuk mengembalikan seluruh transaksi, atau mengembalikan tuple dengan nilai ``bool`` kedua yang menunjukkan keberhasilan.

.. include:: types/value-types.rst

.. include:: types/reference-types.rst

.. include:: types/mapping-types.rst

.. include:: types/operators.rst

.. include:: types/conversion.rst
