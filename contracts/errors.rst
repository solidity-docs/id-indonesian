.. index:: ! error, revert

.. _errors:

***************************
Error dan Pernyataan Revert
***************************

Error dalam Solidity memberikan cara yang nyaman dan hemat gas untuk menjelaskan
kepada pengguna mengapa suatu operasi gagal. Mereka dapat didefinisikan di dalam
dan di luar kontrak (termasuk antarmuka dan library).

Mereka harus digunakan bersama dengan :ref:`revert statement <revert-statement>` yang
menyebabkan semua perubahan dalam panggilan saat ini dikembalikan dan meneruskan data
error kembali ke pemanggil.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Insufficient balance for transfer. Needed `required` but only
    /// `available` available.
    /// @param available balance available.
    /// @param required requested amount to transfer.
    error InsufficientBalance(uint256 available, uint256 required);

    contract TestToken {
        mapping(address => uint) balance;
        function transfer(address to, uint256 amount) public {
            if (amount > balance[msg.sender])
                revert InsufficientBalance({
                    available: balance[msg.sender],
                    required: amount
                });
            balance[msg.sender] -= amount;
            balance[to] += amount;
        }
        // ...
    }

Error tidak dapat di-overload atau override tetapi diwariskan.
Kesalahan yang sama dapat didefinisikan di banyak tempat selama cakupannya berbeda.
Contoh kesalahan hanya dapat dibuat menggunakan pernyataan ``revert``.

Error membuat data yang kemudian diteruskan ke pemanggil dengan operasi revert untuk
kembali ke komponen off-chain atau menangkapnya dalam pernyataan :ref:`try/catch <try-catch>`.
Perhatikan bahwa error hanya dapat ditangkap saat datang dari panggilan eksternal,
pengembalian yang terjadi di panggilan internal atau di dalam fungsi yang sama tidak dapat ditangkap.

Jika Anda tidak memberikan parameter apa pun, kesalahan hanya membutuhkan empat byte data dan
Anda dapat menggunakan :ref:`NatSpec <natspec>` seperti di atas untuk menjelaskan lebih lanjut
alasan di balik kesalahan, yang tidak disimpan on chain.
Ini menjadikannya fitur pelaporan kesalahan yang sangat murah dan nyaman pada saat yang bersamaan.

Lebih khusus lagi, instance error dikodekan ABI dengan cara yang sama seperti pemanggilan fungsi
ke fungsi dengan nama dan tipe yang sama dan kemudian digunakan sebagai data yang dikembalikan
dalam opcode ``revert``.
Ini berarti bahwa data terdiri dari pemilih 4 byte yang diikuti oleh data :ref:`ABI-encoded<abi>`.
Selektor terdiri dari empat byte pertama dari keccak256-hash dari tanda tangan jenis kesalahan.

.. note::
    Kontrak dapat dikembalikan dengan kesalahan yang berbeda dengan nama yang sama atau bahkan
    dengan kesalahan yang ditentukan di tempat berbeda yang tidak dapat dibedakan oleh pemanggil.
    Untuk bagian luar, yaitu ABI, hanya nama kesalahan yang relevan, bukan kontrak atau file
    yang ditentukan.

Pernyataan ``require(condition, "description");`` akan sama dengan
``if (!condition) revert Error("description")`` jika Anda bisa mendefinisikan
``error Error(string)``.
Namun, perhatikan bahwa ``Error`` adalah tipe bawaan dan tidak dapat ditentukan dalam kode yang disediakan pengguna.

Demikian pula, ``assert`` yang gagal atau kondisi serupa akan dikembalikan dengan kesalahan
tipe bawaan ``Panic(uint256)``.

.. note::
    Data kesalahan seharusnya hanya digunakan untuk memberikan indikasi kegagalan, tetapi bukan
    sebagai sarana untuk control-flow. Alasannya adalah bahwa data pengembalian panggilan inner
    disebarkan kembali melalui rantai panggilan eksternal secara default. Ini berarti bahwa panggilan
    inner dapat "menempa" mengembalikan data yang sepertinya berasal dari kontrak yang memanggilnya.
