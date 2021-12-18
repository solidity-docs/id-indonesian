.. index:: ! using for, library

.. _using-for:

*********
Using For
*********

Direktif ``using A for B;`` dapat digunakan untuk melampirkan fungsi library
(dari library ``A``) ke tipe apa pun (``B``) dalam konteks sebuah kontrak.
Fungsi-fungsi ini akan menerima objek yang mereka panggil sebagai parameter
pertama mereka (seperti variabel ``self`` dalam Python).

Efek dari ``using A for *;`` adalah bahwa fungsi dari
library ``A`` dilampirkan ke tipe *apa saja*.

Dalam kedua situasi tersebut, *semua* fungsi di library dilampirkan, bahkan tipe
parameter pertama yang tidak cocok dengan tipe objek. Tipe diperiksa pada titik
saat fungsi dipanggil dan resolusi fungsi yang berlebihan dilakukan.

Direktif ``using A for B;`` hanya aktif dalam arus
kontrak, termasuk dalam semua fungsinya, dan tidak memiliki efek
di luar kontrak di mana ia digunakan. Arahan hanya dapat digunakan di
dalam kontrak, bukan di dalam fungsinya.

Mari kita tulis ulang set contoh dari
:ref:`libraries` dengan cara ini:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;


    // This is the same code as before, just without comments
    struct Data { mapping(uint => bool) flags; }

    library Set {
        function insert(Data storage self, uint value)
            public
            returns (bool)
        {
            if (self.flags[value])
                return false; // already there
            self.flags[value] = true;
            return true;
        }

        function remove(Data storage self, uint value)
            public
            returns (bool)
        {
            if (!self.flags[value])
                return false; // not there
            self.flags[value] = false;
            return true;
        }

        function contains(Data storage self, uint value)
            public
            view
            returns (bool)
        {
            return self.flags[value];
        }
    }


    contract C {
        using Set for Data; // this is the crucial change
        Data knownValues;

        function register(uint value) public {
            // Here, all variables of type Data have
            // corresponding member functions.
            // The following function call is identical to
            // `Set.insert(knownValues, value)`
            require(knownValues.insert(value));
        }
    }

Dimungkinkan juga untuk memperluas tipe dasar dengan cara itu:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.8 <0.9.0;

    library Search {
        function indexOf(uint[] storage self, uint value)
            public
            view
            returns (uint)
        {
            for (uint i = 0; i < self.length; i++)
                if (self[i] == value) return i;
            return type(uint).max;
        }
    }

    contract C {
        using Search for uint[];
        uint[] data;

        function append(uint value) public {
            data.push(value);
        }

        function replace(uint _old, uint _new) public {
            // This performs the library function call
            uint index = data.indexOf(_old);
            if (index == type(uint).max)
                data.push(_new);
            else
                data[index] = _new;
        }
    }

Perhatikan bahwa semua panggilan library eksternal adalah panggilan
fungsi EVM yang sebenarnya. Ini berarti bahwa jika Anda melewatkan memori
atau tipe nilai, salinan akan dilakukan, bahkan untuk variabel ``self``. Satu-satunya situasi
di mana tidak ada salinan yang akan dilakukan adalah ketika variabel referensi penyimpanan
digunakan atau ketika fungsi library internal dipanggil.
