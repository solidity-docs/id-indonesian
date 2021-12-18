###############
Pola Umum
###############

.. index:: withdrawal

.. _withdrawal_pattern:

*************************
Penarikan dari Kontrak
*************************

Metode pengiriman dana setelah sebuah effect yang disarankan
adalah menggunakan pola penarikan. Meskipun metode pengiriman
Ether yang paling intuitif, sebagai akibat dari suatu efek, adalah
panggilan ``transfer`` langsung, ini tidak disarankan karena
memperkenalkan potensi risiko keamanan. Anda dapat membaca lebih
lanjut tentang ini di halaman :ref:`security_considerations`.

Berikut ini adalah contoh pola penarikan dalam praktik dalam sebuah
kontrak dimana tujuannya adalah untuk mengirimkan uang sebanyak-banyaknya
ke dalam kontrak agar menjadi “yang terkaya”, terinspirasi dari
`Raja Ether <https://www.kingoftheether.com/>`_.

Dalam kontrak berikut, jika Anda bukan lagi yang terkaya,
Anda menerima dana dari orang yang sekarang paling kaya.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract WithdrawalContract {
        address public richest;
        uint public mostSent;

        mapping (address => uint) pendingWithdrawals;

        /// The amount of Ether sent was not higher than
        /// the currently highest amount.
        error NotEnoughEther();

        constructor() payable {
            richest = msg.sender;
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            pendingWithdrawals[richest] += msg.value;
            richest = msg.sender;
            mostSent = msg.value;
        }

        function withdraw() public {
            uint amount = pendingWithdrawals[msg.sender];
            // Remember to zero the pending refund before
            // sending to prevent re-entrancy attacks
            pendingWithdrawals[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

Ini berbeda dengan pola pengiriman yang lebih intuitif:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract SendContract {
        address payable public richest;
        uint public mostSent;

        /// The amount of Ether sent was not higher than
        /// the currently highest amount.
        error NotEnoughEther();

        constructor() payable {
            richest = payable(msg.sender);
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            // This line can cause problems (explained below).
            richest.transfer(msg.value);
            richest = payable(msg.sender);
            mostSent = msg.value;
        }
    }

Perhatikan bahwa, dalam contoh ini, penyerang dapat menjebak
kontrak ke dalam status yang tidak dapat digunakan dengan menyebabkan
``terkaya`` menjadi alamat kontrak yang memiliki fungsi receive atau
fallback yang gagal (misalnya dengan menggunakan ``revert()`` atau
dengan hanya mengkonsumsi lebih dari 2300 cadangan gas yang ditransfer ke mereka). Dengan cara itu,
kapan pun ``transfer`` dipanggil untuk mengirimkan dana ke
kontrak yang "diracuni", itu akan gagal dan dengan demikian juga ``menjadi Terkaya``
akan gagal, dengan kontrak macet selamanya.

Sebaliknya, jika Anda menggunakan pola "withdraw" dari contoh pertama,
penyerang hanya dapat menyebabkan penarikannya sendiri yang gagal dan bukan
pekerjaan kontrak yang lainnya.

.. index:: access;restricting

******************
Membatasi Akses
******************

Membatasi akses adalah pola umum untuk kontrak.
Perhatikan bahwa Anda tidak pernah dapat membatasi
manusia atau komputer mana pun untuk membaca konten
transaksi Anda atau status kontrak Anda. Anda dapat membuatnya
sedikit lebih sulit dengan menggunakan enkripsi, tetapi jika kontrak
Anda seharusnya membaca data, begitu juga orang lain.

Anda dapat membatasi akses baca ke status kontrak
Anda dengan **kontrak lain**. Ini sebenarnya default
kecuali Anda mendeklarasikan variabel state Anda sebagai ``public``.

Selanjutnya, Anda dapat membatasi siapa yang dapat melakukan
modifikasi pada status kontrak Anda atau memanggil fungsi
kontrak Anda dan inilah yang dijelaskan dibagian ini.

.. index:: function;modifier

Penggunaan **function modifiers** membuat
batasan ini sangat mudah dibaca.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract AccessRestriction {
        // These will be assigned at the construction
        // phase, where `msg.sender` is the account
        // creating this contract.
        address public owner = msg.sender;
        uint public creationTime = block.timestamp;

        // Now follows a list of errors that
        // this contract can generate together
        // with a textual explanation in special
        // comments.

        /// Sender not authorized for this
        /// operation.
        error Unauthorized();

        /// Function called too early.
        error TooEarly();

        /// Not enough Ether sent with function call.
        error NotEnoughEther();

        // Modifiers can be used to change
        // the body of a function.
        // If this modifier is used, it will
        // prepend a check that only passes
        // if the function is called from
        // a certain address.
        modifier onlyBy(address _account)
        {
            if (msg.sender != _account)
                revert Unauthorized();
            // Do not forget the "_;"! It will
            // be replaced by the actual function
            // body when the modifier is used.
            _;
        }

        /// Make `_newOwner` the new owner of this
        /// contract.
        function changeOwner(address _newOwner)
            public
            onlyBy(owner)
        {
            owner = _newOwner;
        }

        modifier onlyAfter(uint _time) {
            if (block.timestamp < _time)
                revert TooEarly();
            _;
        }

        /// Erase ownership information.
        /// May only be called 6 weeks after
        /// the contract has been created.
        function disown()
            public
            onlyBy(owner)
            onlyAfter(creationTime + 6 weeks)
        {
            delete owner;
        }

        // This modifier requires a certain
        // fee being associated with a function call.
        // If the caller sent too much, he or she is
        // refunded, but only after the function body.
        // This was dangerous before Solidity version 0.4.0,
        // where it was possible to skip the part after `_;`.
        modifier costs(uint _amount) {
            if (msg.value < _amount)
                revert NotEnoughEther();

            _;
            if (msg.value > _amount)
                payable(msg.sender).transfer(msg.value - _amount);
        }

        function forceOwnerChange(address _newOwner)
            public
            payable
            costs(200 ether)
        {
            owner = _newOwner;
            // just some example condition
            if (uint160(owner) & 0 == 1)
                // This did not refund for Solidity
                // before version 0.4.0.
                return;
            // refund overpaid fees
        }
    }

Cara yang lebih khusus di mana akses ke fungsi
panggilan dapat dibatasi akan dibahas
dalam contoh berikutnya.

.. index:: state machine

*************
State Machine
*************

Kontrak sering bertindak sebagai mesin state, yang berarti
bahwa mereka memiliki **stages** tertentu di mana mereka berperilaku
berbeda atau di mana fungsi yang berbeda dapat
dipanggil. Pemanggilan fungsi sering kali mengakhiri sebuah stage
dan mentransisikan kontrak ke tahap berikutnya
(terutama jika model kontrak **interaksi**).
Juga umum bahwa beberapa tahapan secara otomatis
dicapai pada titik tertentu dalam **waktu**.

Contoh untuk ini adalah kontrak lelang buta yang
dimulai pada tahap "menerima tawaran buta", lalu
transisi ke "mengungkapkan tawaran" yang diakhiri dengan
“menentukan hasil lelang”.

.. index:: function;modifier

Fungsi modifier dapat digunakan dalam situasi ini
untuk mencontoh state dan waspada terhadap
penggunaan kontrak yang salah.

Contoh
=======

Dalam contoh berikut,
pengubah ``atStage`` memastikan bahwa fungsi hanya
dapat dipanggil pada tahap tertentu.

Transisi berwaktu otomatis ditangani oleh
pengubah ``timedTransitions``, yang
harus digunakan untuk semua fungsi.

.. note::
    **Urutan Modifier Penting**.
    Jika atStage digabungkan
    dengan timedTransitions, pastikan Anda menyebutkan
    itu setelah yang terakhir, sehingga tahap baru diperhitungkan.

Akhirnya, pengubah ``transitionNext`` dapat digunakan
untuk secara otomatis pergi ke tahap berikutnya ketika
fungsi selesai.

.. note::
    **modifier Mungkin Dilewati**.
    Ini hanya berlaku untuk Solidity sebelum versi 0.4.0:
    Karena pengubah diterapkan hanya dengan mengganti
    kode dan bukan dengan menggunakan panggilan fungsi,
    kode dalam pengubah transitionNext
    dapat dilewati jika fungsi itu sendiri menggunakan
    return. Jika Anda ingin melakukan itu, pastikan
    untuk memanggil nextStage secara manual dari fungsi-fungsi itu.
    Dimulai dengan versi 0.4.0, kode pengubah
    akan berjalan bahkan jika fungsi secara eksplisit kembali.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract StateMachine {
        enum Stages {
            AcceptingBlindedBids,
            RevealBids,
            AnotherStage,
            AreWeDoneYet,
            Finished
        }
        /// Function cannot be called at this time.
        error FunctionInvalidAtThisStage();

        // This is the current stage.
        Stages public stage = Stages.AcceptingBlindedBids;

        uint public creationTime = block.timestamp;

        modifier atStage(Stages _stage) {
            if (stage != _stage)
                revert FunctionInvalidAtThisStage();
            _;
        }

        function nextStage() internal {
            stage = Stages(uint(stage) + 1);
        }

        // Perform timed transitions. Be sure to mention
        // this modifier first, otherwise the guards
        // will not take the new stage into account.
        modifier timedTransitions() {
            if (stage == Stages.AcceptingBlindedBids &&
                        block.timestamp >= creationTime + 10 days)
                nextStage();
            if (stage == Stages.RevealBids &&
                    block.timestamp >= creationTime + 12 days)
                nextStage();
            // The other stages transition by transaction
            _;
        }

        // Order of the modifiers matters here!
        function bid()
            public
            payable
            timedTransitions
            atStage(Stages.AcceptingBlindedBids)
        {
            // We will not implement that here
        }

        function reveal()
            public
            timedTransitions
            atStage(Stages.RevealBids)
        {
        }

        // This modifier goes to the next stage
        // after the function is done.
        modifier transitionNext()
        {
            _;
            nextStage();
        }

        function g()
            public
            timedTransitions
            atStage(Stages.AnotherStage)
            transitionNext
        {
        }

        function h()
            public
            timedTransitions
            atStage(Stages.AreWeDoneYet)
            transitionNext
        {
        }

        function i()
            public
            timedTransitions
            atStage(Stages.Finished)
        {
        }
    }
