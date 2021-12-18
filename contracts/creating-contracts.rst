.. index:: ! contract;creation, constructor

******************
Membuat Kontrak
******************

Kontrak dapat dibuat "dari luar" melalui transaksi Ethereum atau dari dalam kontrak Solidity.

IDEs, seperti `Remix <https://remix.ethereum.org/>`_, membuat proses pembuatan lebih mulus dengan menggunakan elemen UI.

Salah satu cara untuk membuat kontrak secara terprogram di Ethereum adalah melalui JavaScript API `web3.js <https://github.com/ethereum/web3.js>`_.
Ini memiliki fungsi yang disebut `web3.eth.Contract <https://web3js.readthedocs.io/en/1.0/web3-eth-contract.html#new-contract>`_
untuk memfasilitasi pembuatan kontrak.

Saat kontrak dibuat, :ref:`constructor <constructor>` (fungsi yang dideklarasikan dengan
kata kunci ``constructor``) dijalankan satu kali.

Constructor adalah opsional. Hanya satu constructor yang diizinkan, yang berarti overloading tidak didukung.

Setelah constructor dieksekusi, kode final kontrak disimpan di blockchain.
Kode ini mencakup semua fungsi publik dan eksternal dan semua fungsi yang
dapat dijangkau dari sana melalui panggilan fungsi. Kode yang digunakan tidak
termasuk kode constructor atau fungsi internal yang hanya bisa dipanggil dari constructor.

.. index:: constructor;arguments

Secara internal, argumen constructor diteruskan :ref:`ABI encoded <ABI>` setelah kode kontrak itu sendiri,
tetapi Anda tidak perlu mempedulikan hal ini jika menggunakan ``web3.js``.

Jika sebuah kontrak ingin membuat kontrak lain, kode sumber (dan biner) dari
kontrak yang dibuat harus diketahui oleh pembuatnya.
Ini berarti bahwa *cyclic creation dependencies* tidak mungkin.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;


    contract OwnedToken {
        // `TokenCreator` is a contract type that is defined below.
        // It is fine to reference it as long as it is not used
        // to create a new contract.
        TokenCreator creator;
        address owner;
        bytes32 name;

        // This is the constructor which registers the
        // creator and the assigned name.
        constructor(bytes32 _name) {
            // State variables are accessed via their name
            // and not via e.g. `this.owner`. Functions can
            // be accessed directly or through `this.f`,
            // but the latter provides an external view
            // to the function. Especially in the constructor,
            // you should not access functions externally,
            // because the function does not exist yet.
            // See the next section for details.
            owner = msg.sender;

            // We perform an explicit type conversion from `address`
            // to `TokenCreator` and assume that the type of
            // the calling contract is `TokenCreator`, there is
            // no real way to verify that.
            // This does not create a new contract.
            creator = TokenCreator(msg.sender);
            name = _name;
        }

        function changeName(bytes32 newName) public {
            // Only the creator can alter the name.
            // We compare the contract based on its
            // address which can be retrieved by
            // explicit conversion to address.
            if (msg.sender == address(creator))
                name = newName;
        }

        function transfer(address newOwner) public {
            // Only the current owner can transfer the token.
            if (msg.sender != owner) return;

            // We ask the creator contract if the transfer
            // should proceed by using a function of the
            // `TokenCreator` contract defined below. If
            // the call fails (e.g. due to out-of-gas),
            // the execution also fails here.
            if (creator.isTokenTransferOK(owner, newOwner))
                owner = newOwner;
        }
    }


    contract TokenCreator {
        function createToken(bytes32 name)
            public
            returns (OwnedToken tokenAddress)
        {
            // Create a new `Token` contract and return its address.
            // From the JavaScript side, the return type
            // of this function is `address`, as this is
            // the closest type available in the ABI.
            return new OwnedToken(name);
        }

        function changeName(OwnedToken tokenAddress, bytes32 name) public {
            // Again, the external type of `tokenAddress` is
            // simply `address`.
            tokenAddress.changeName(name);
        }

        // Perform checks to determine if transferring a token to the
        // `OwnedToken` contract should proceed
        function isTokenTransferOK(address currentOwner, address newOwner)
            public
            pure
            returns (bool ok)
        {
            // Check an arbitrary condition to see if transfer should proceed
            return keccak256(abi.encodePacked(currentOwner, newOwner))[0] == 0x7f;
        }
    }
