.. index:: ! constant

.. _constants:

**************************************
Variabel Constant dan Immutable State
**************************************

Variabel state dapat dideklarasikan sebagai ``constant`` atau ``immutable``.
Dalam kedua kasus tersebut, variabel tidak dapat dimodifikasi setelah kontrak dibuat.
Untuk variabel ``constant``, nilainya harus ditetapkan pada waktu kompilasi, sedangkan
untuk ``immutable``, masih dapat ditetapkan pada waktu konstruksi.

Dimungkinkan juga untuk mendefinisikan variabel ``constant`` pada tingkat file.

Kompiler tidak memesan slot penyimpanan untuk variabel-variabel ini, dan setiap kemunculan
diganti dengan nilai masing-masing.

Dibandingkan dengan variabel keadaan biasa, biaya gas variabel constant dan immutable
jauh lebih rendah. Untuk variabel constant, ekspresi yang ditetapkan padanya disalin
ke semua tempat di mana ia diakses dan juga dievaluasi ulang setiap saat. Ini memungkinkan
pengoptimalan lokal. Variabel Immutable dievaluasi sekali pada waktu konstruksi dan nilainya
disalin ke semua tempat dalam kode di mana mereka diakses. Untuk nilai-nilai ini,
32 byte dicadangkan, meskipun mereka akan muat dalam byte lebih sedikit. Karena itu, nilai constant
terkadang bisa lebih murah daripada nilai immutable.

Tidak semua tipe untuk constants dan immutable diimplementasikan sekarang. Satu-satunya tipe yang didukung
adalah :ref:`strings <strings>` (hanya untuk constants) dan :ref:`tipe nilai <value-types>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.4;

    uint constant X = 32**22 + 8;

    contract C {
        string constant TEXT = "abc";
        bytes32 constant MY_HASH = keccak256("abc");
        uint immutable decimals;
        uint immutable maxBalance;
        address immutable owner = msg.sender;

        constructor(uint _decimals, address _reference) {
            decimals = _decimals;
            // Assignments to immutables can even access the environment.
            maxBalance = _reference.balance;
        }

        function isBalanceTooHigh(address _other) public view returns (bool) {
            return _other.balance > maxBalance;
        }
    }


Constant
========

Untuk variabel ``constant``, nilainya harus berupa konstanta pada waktu kompilasi dan harus
ditetapkan di mana variabel dideklarasikan. Ekspresi apa pun
yang mengakses penyimpanan, data blockchain (misalnya ``block.timestamp``, ``address(this).balance``
atau ``block.number``) atau data eksekusi (``msg.value`` atau ` `gasleft()``) atau melakukan panggilan ke kontrak eksternal tidak diizinkan.
Ekspresi yang mungkin memiliki efek samping pada alokasi memori diperbolehkan, tetapi ekspresi yang mungkin memiliki efek samping pada objek memori lain tidak diperbolehkan.
Fungsi bawaan ``keccak256``, ``sha256``, ``ripemd160``, ``ecrecover``, ``addmod`` dan ``mulmod``
diperbolehkan (meskipun, dengan pengecualian ``keccak256``, mereka memanggil kontrak eksternal).

Alasan di balik mengizinkan efek samping pada pengalokasi memori adalah bahwa itu
harus memungkinkan untuk membangun objek kompleks seperti mis. tabel pencarian.
Fitur ini belum sepenuhnya dapat digunakan.

Immutable
=========

Variabel yang dideklarasikan sebagai ``immutable`` sedikit kurang dibatasi daripada
yang dideklarasikan sebagai ``constant``: Variabel Immutable dapat diberi nilai arbitrer
dalam konstruktor kontrak atau pada titik deklarasinya. Mereka dapat ditugaskan hanya
sekali dan, sejak saat itu, dapat dibaca bahkan selama waktu konstruksi.

Kode pembuatan kontrak yang dihasilkan oleh kompiler akan memodifikasi kode runtime kontrak
sebelum dikembalikan dengan mengganti semua referensi ke immutables dengan nilai yang diberikan
padanya. Ini penting jika Anda membandingkan kode runtime yang dihasilkan oleh kompiler dengan
yang sebenarnya disimpan di blockchain.

.. note::
  Immutable yang ditetapkan pada deklarasi mereka hanya dianggap diinisialisasi setelah konstruktor
  kontrak dieksekusi. Ini berarti Anda tidak dapat menginisialisasi Immutable sejalan dengan nilai
  yang bergantung pada Immutablelainnya. Namun, Anda dapat melakukan ini di dalam konstruktor kontrak.

  Ini adalah perlindungan terhadap interpretasi yang berbeda tentang
  urutan inisialisasi variabel state dan eksekusi konstruktor, terutama
  yang berkaitan dengan pewarisan(inheritance).