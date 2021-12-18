.. index:: contract;modular, modular contract

*****************
Kontrak Modular
*****************

Pendekatan secara modular untuk membangun kontrak membantu Anda mengurangi kerumitan
dan meningkatkan keterbacaan yang akan membantu mengidentifikasi bug serta kerentanan
selama pengembangan dan peninjauan kode.
Jika Anda menentukan dan mengontrol perilaku setiap modul secara terpisah, interaksi
yang harus Anda pertimbangkan hanyalah interaksi antara spesifikasi modul bukan setiap
bagian kontrak yang bergerak lainnya.
Pada contoh di bawah, kontrak menggunakan metode ``move``
dari `Balances`` :ref:`library <libraries>` untuk memeriksa apakah saldo yang dikirim
antar alamat sesuai dengan yang Anda harapkan. Dengan cara ini, Library ``Balances``
menyediakan komponen terisolasi yang melacak saldo akun dengan benar.
Sangat mudah untuk memverifikasi bahwa Library ``Balances`` tidak pernah menghasilkan
saldo negatif atau Overflow dan jumlah semua saldo adalah invarian sepanjang masa kontrak.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    library Balances {
        function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal {
            require(balances[from] >= amount);
            require(balances[to] + amount >= balances[to]);
            balances[from] -= amount;
            balances[to] += amount;
        }
    }

    contract Token {
        mapping(address => uint256) balances;
        using Balances for *;
        mapping(address => mapping (address => uint256)) allowed;

        event Transfer(address from, address to, uint amount);
        event Approval(address owner, address spender, uint amount);

        function transfer(address to, uint amount) external returns (bool success) {
            balances.move(msg.sender, to, amount);
            emit Transfer(msg.sender, to, amount);
            return true;

        }

        function transferFrom(address from, address to, uint amount) external returns (bool success) {
            require(allowed[from][msg.sender] >= amount);
            allowed[from][msg.sender] -= amount;
            balances.move(from, to, amount);
            emit Transfer(from, to, amount);
            return true;
        }

        function approve(address spender, uint tokens) external returns (bool success) {
            require(allowed[msg.sender][spender] == 0, "");
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }

        function balanceOf(address tokenOwner) external view returns (uint balance) {
            return balances[tokenOwner];
        }
    }
