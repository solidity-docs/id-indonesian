
.. index: memory layout

****************
Layout di Memory
****************

Solidity mencadangkan empat slot 32-byte, dengan rentang byte tertentu (termasuk titik akhir) yang digunakan sebagai berikut:

- ``0x00`` - ``0x3f`` (64 bytes): ruang awal untuk metode hashing
- ``0x40`` - ``0x5f`` (32 bytes): ukuran memori yang dialokasikan saat ini (aka. free memory pointer)
- ``0x60`` - ``0x7f`` (32 bytes): zero slot

Ruang awal dapat digunakan di antara pernyataan (yaitu dalam inline assembly). Zero slot
digunakan sebagai nilai awal untuk array memori dinamis dan tidak boleh ditulis ke
(pointer memori bebas menunjuk ke ``0x80`` pada awalnya).

Solidity selalu menempatkan objek baru pada penunjuk memori bebas dan
memori tidak pernah dibebaskan (ini mungkin berubah di masa depan).

Elemen dalam array memori di Solidity selalu menempati kelipatan 32 byte (ini
bahkan berlaku untuk ``bytes1[]``, tetapi tidak untuk ``byte`` dan ``string``).
Array memori multi-dimensi adalah pointer ke array memori. panjang dari
array dinamis disimpan di slot pertama array dan diikuti oleh array
elemen.

.. warning::
  Ada beberapa operasi di Solidity yang membutuhkan area memori sementara
  yang lebih besar dari 64 byte dan oleh karena itu tidak akan muat ke dalam ruang awal.
  Mereka akan ditempatkan di mana memori bebas menunjuk, tetapi mengingat masa pakainya
  yang singkat, penunjuk tidak diperbarui. Memori mungkin atau mungkin tidak nol. Karena itu,
  seseorang seharusnya tidak mengharapkan memori bebas untuk menunjuk ke memori yang nol.

  Meskipun mungkin tampak seperti ide yang baik untuk menggunakan ``msize`` untuk tiba di
  area memori yang benar-benar nol, menggunakan penunjuk seperti itu untuk sementara tanpa
  memperbarui penunjuk memori bebas dapat memberikan hasil yang tidak diharapkan.


Perbedaan Layout di Storage
================================

Seperti yang dijelaskan diatas layout di memory berbeda dari layout di
:ref:`storage<storage-inplace-encoding>`. Di bawah ini ada beberapa contoh.

Contoh Perbedaan dalam Array
--------------------------------

Array berikut menempati 32 byte (1 slot) dalam penyimpanan, tetapi 128
byte (4 item dengan masing-masing 32 byte) di memori.

.. code-block:: solidity

    uint8[4] a;



Contoh untuk Perbedaan dalam Layout Struct
------------------------------------------

Struktur berikut menempati 96 byte (3 slot 32 byte) dalam penyimpanan,
tetapi 128 byte (4 item dengan masing-masing 32 byte) di memori.


.. code-block:: solidity

    struct S {
        uint a;
        uint b;
        uint8 c;
        uint8 d;
    }
