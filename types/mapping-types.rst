.. index:: !mapping
.. _mapping-types:

Tipe Mapping
=============

Tipe mapping menggunakan syntax ``mapping(_KeyType => _ValueType)`` dan tipe variabel
mapping dideklarasikan menggunakan syntax ``mapping(_KeyType => _ValueType) _VariableName``.
``_KeyType`` dapat berupa tipe nilai
bawaan apa saja, ``bytes``, ``string``, atau kontrak atau jenis enum apa pun. Tipe *user-defined*
atau tipe kompleks lainnya, seperti mapping, struct, atau tipe array tidak diizinkan.
``_ValueType`` dapat berupa tipe apa saja, termasuk mapping, array, dan struct.

Anda dapat menganggap mapping sebagai `tabel hash <https://en.wikipedia.org/wiki/Hash_table>`_, yang secara virtual diinisialisasi
sedemikian rupa sehingga setiap kunci yang mungkin ada dan dipetakan ke nilai yang
representasi byte-nya semuanya nol, tipe :ref:`nilai default <default-value>`.
Kesamaan berakhir di sana, data kunci tidak disimpan dalam
mapping, hanya hash ``keccak256`` yang digunakan untuk mencari nilainya.

Karena itu, mapping tidak memiliki panjang atau konsep kunci atau nilai yang ditetapkan,
dan oleh karena itu tidak dapat dihapus tanpa informasi tambahan mengenai
kunci yang ditetapkan (lihat :ref:`clearing-mappings`).

Mapping hanya dapat memiliki lokasi data ``storage`` dan oleh
karena itu diperbolehkan untuk variabel state, sebagai tipe referensi
storage dalam functions, atau sebagai parameter untuk fungsi library.
Mereka tidak dapat digunakan sebagai parameter atau menghasilkan parameter
fungsi kontrak yang dapat dilihat oleh publik. Pembatasan ini
juga berlaku untuk array dan struct yang berisi mapping.

Anda dapat menandai variabel state tipe mapping sebagai ``public`` dan Solidity membuat
:ref:`getter <visibility-and-getter>` untuk Anda. ``_KeyType`` menjadi parameter untuk gatter.
Jika ``_ValueType`` adalah tipe nilai atau struct, getter menghasilkan ``_ValueType``.
Jika ``_ValueType`` adalah array atau mapping, getter memiliki satu parameter untuk setiap
``_KeyType``, secara rekursif.

Dalam contoh di bawah, kontrak ``MappingExample`` mendefinisikan mapping ``balances``
publik, dengan tipe kunci sebuah ``address``, dan tipe nilai ``uint``, memapping
alamat Ethereum ke nilai integer yang tidak ditandatangani. Karena ``uint`` adalah tipe nilai, getter
menghasilkan nilai yang cocok dengan tipe tersebut, yang dapat Anda lihat di kontrak ``MappingUser``
yang menghasilkan nilai di alamat yang ditentukan.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract MappingExample {
        mapping(address => uint) public balances;

        function update(uint newBalance) public {
            balances[msg.sender] = newBalance;
        }
    }

    contract MappingUser {
        function f() public returns (uint) {
            MappingExample m = new MappingExample();
            m.update(100);
            return m.balances(address(this));
        }
    }

The example below is a simplified version of an
`ERC20 token <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol>`_.
``_allowances`` is an example of a mapping type inside another mapping type.
The example below uses ``_allowances`` to record the amount someone else is allowed to withdraw from your account.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract MappingExample {

        mapping (address => uint256) private _balances;
        mapping (address => mapping (address => uint256)) private _allowances;

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

        function allowance(address owner, address spender) public view returns (uint256) {
            return _allowances[owner][spender];
        }

        function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
            _transfer(sender, recipient, amount);
            approve(sender, msg.sender, amount);
            return true;
        }

        function approve(address owner, address spender, uint256 amount) public returns (bool) {
            require(owner != address(0), "ERC20: approve from the zero address");
            require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
            return true;
        }

        function _transfer(address sender, address recipient, uint256 amount) internal {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");

            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }


.. index:: !iterable mappings
.. _iterable-mappings:

Iterable Mappings
-----------------

Anda tidak dapat mengulangi mapping, yaitu Anda tidak dapat menghitung kuncinya.
Namun, dimungkinkan untuk menerapkan struktur data di atasnya dan mengulanginya.
Misalnya, kode di bawah ini mengimplementasikan sebuah library ``IterableMapping``
yang ``User`` kontrak  kemudian menambahkan data juga, dan fungsi ``sum`` diulang
untuk menjumlahkan semua nilai.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.8 <0.9.0;

    struct IndexValue { uint keyIndex; uint value; }
    struct KeyFlag { uint key; bool deleted; }

    struct itmap {
        mapping(uint => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }

    library IterableMapping {
        function insert(itmap storage self, uint key, uint value) internal returns (bool replaced) {
            uint keyIndex = self.data[key].keyIndex;
            self.data[key].value = value;
            if (keyIndex > 0)
                return true;
            else {
                keyIndex = self.keys.length;
                self.keys.push();
                self.data[key].keyIndex = keyIndex + 1;
                self.keys[keyIndex].key = key;
                self.size++;
                return false;
            }
        }

        function remove(itmap storage self, uint key) internal returns (bool success) {
            uint keyIndex = self.data[key].keyIndex;
            if (keyIndex == 0)
                return false;
            delete self.data[key];
            self.keys[keyIndex - 1].deleted = true;
            self.size --;
        }

        function contains(itmap storage self, uint key) internal view returns (bool) {
            return self.data[key].keyIndex > 0;
        }

        function iterate_start(itmap storage self) internal view returns (uint keyIndex) {
            return iterate_next(self, type(uint).max);
        }

        function iterate_valid(itmap storage self, uint keyIndex) internal view returns (bool) {
            return keyIndex < self.keys.length;
        }

        function iterate_next(itmap storage self, uint keyIndex) internal view returns (uint r_keyIndex) {
            keyIndex++;
            while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
                keyIndex++;
            return keyIndex;
        }

        function iterate_get(itmap storage self, uint keyIndex) internal view returns (uint key, uint value) {
            key = self.keys[keyIndex].key;
            value = self.data[key].value;
        }
    }

    // How to use it
    contract User {
        // Just a struct holding our data.
        itmap data;
        // Apply library functions to the data type.
        using IterableMapping for itmap;

        // Insert something
        function insert(uint k, uint v) public returns (uint size) {
            // This calls IterableMapping.insert(data, k, v)
            data.insert(k, v);
            // We can still access members of the struct,
            // but we should take care not to mess with them.
            return data.size;
        }

        // Computes the sum of all stored data.
        function sum() public view returns (uint s) {
            for (
                uint i = data.iterate_start();
                data.iterate_valid(i);
                i = data.iterate_next(i)
            ) {
                (, uint value) = data.iterate_get(i);
                s += value;
            }
        }
    }
