.. index:: ! contract

.. _contracts:

##########
Kontrak
##########

Kontrak dalam Solidity mirip dengan kelas dalam bahasa object-oriented. Mereka
berisi data persisten dalam variabel state, dan fungsi yang dapat mengubah variabel ini.
Memanggil fungsi pada kontrak (instance) yang berbeda akan melakukan panggilan fungsi EVM dan dengan demikian
mengalihkan konteks sehingga variabel state dalam panggilan kontrak tidak dapat diakses.
Sebuah kontrak dan fungsinya perlu dipanggil agar apa pun bisa terjadi.
Tidak ada konsep "cron" di Ethereum untuk memanggil fungsi pada event tertentu secara otomatis.

.. include:: contracts/creating-contracts.rst

.. include:: contracts/visibility-and-getters.rst

.. include:: contracts/function-modifiers.rst

.. include:: contracts/constant-state-variables.rst
.. include:: contracts/functions.rst

.. include:: contracts/events.rst
.. include:: contracts/errors.rst

.. include:: contracts/inheritance.rst

.. include:: contracts/abstract-contracts.rst
.. include:: contracts/interfaces.rst

.. include:: contracts/libraries.rst

.. include:: contracts/using-for.rst