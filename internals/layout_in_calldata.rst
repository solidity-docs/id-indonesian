
.. index: calldata layout

*********************
Layout dari Call Data
*********************

Data masukan untuk panggilan fungsi diasumsikan dalam format yang ditentukan oleh :ref:`Spesifikasi ABI <ABI>`. Antara lain, spesifikasi ABI
membutuhkan argumen untuk diisi ke kelipatan 32 byte. Panggilan fungsi internal menggunakan konvensi yang berbeda.

Argumen untuk konstruktor kontrak langsung ditambahkan di akhir kode kontrak, juga dalam ABI encoding.
Konstruktor akan mengaksesnya melalui offset hard-code, dan bukan dengan menggunakan opcode ``codesize``, karena ini tentu saja berubah saat menambahkan data ke kode.

