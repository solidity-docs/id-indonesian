.. index:: purchase, remote purchase, escrow

*****************************************************
Pembelian Jarak Jauh yang Aman (Safe Remote Purchase)
*****************************************************

<<<<<<< HEAD
Membeli barang dari jarak jauh saat ini membutuhkan banyak pihak yang perlu saling percaya.
Konfigurasi paling sederhana melibatkan penjual dan pembeli.
Pembeli ingin menerima barang dari penjual dan penjual ingin mendapatkan uang
(atau yang setara) sebagai imbalannya. Bagian yang bermasalah pengiriman adalah di sini: Tidak ada cara
untuk menentukan dengan pasti bahwa barang tersebut sampai ke pembeli.

Ada banyak cara untuk menyelesaikan masalah ini, tetapi semuanya gagal dalam satu atau cara lain.
Dalam contoh berikut, kedua belah pihak harus memasukkan dua kali nilai item ke dalam
kontrak sebagai escrow. Sesaat setelah ini terjadi, uangnya akan tetap terkunci di dalam
kontrak sampai pembeli menegaskan bahwa mereka menerima item tersebut. Setelah itu,
nilainya dikembalikan ke pembeli (setengah dari deposit mereka) dan penjual mendapat tiga
kali nilai (deposit mereka ditambah nilai tersebut). Ide di balik ini adalah bahwa kedua belah pihak
memiliki insentif untuk menyelesaikan situasi atau sebaliknya uang mereka terkunci selamanya.
=======
Purchasing goods remotely currently requires multiple parties that need to trust each other.
The simplest configuration involves a seller and a buyer. The buyer would like to receive
an item from the seller and the seller would like to get some compensation, e.g. Ether,
in return. The problematic part is the shipment here: There is no way to determine for
sure that the item arrived at the buyer.

There are multiple ways to solve this problem, but all fall short in one or the other way.
In the following example, both parties have to put twice the value of the item into the
contract as escrow. As soon as this happened, the Ether will stay locked inside
the contract until the buyer confirms that they received the item. After that,
the buyer is returned the value (half of their deposit) and the seller gets three
times the value (their deposit plus the value). The idea behind
this is that both parties have an incentive to resolve the situation or otherwise
their Ether is locked forever.
>>>>>>> english/develop


Kontrak ini tentu saja tidak menyelesaikan masalah, tetapi memberikan gambaran tentang bagaimana Anda
dapat menggunakan konstruksi *state machine-like* di dalam kontrak.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract Purchase {
        uint public value;
        address payable public seller;
        address payable public buyer;

        enum State { Created, Locked, Release, Inactive }
        // The state variable has a default value of the first member, `State.created`
        State public state;

        modifier condition(bool condition_) {
            require(condition_);
            _;
        }

        /// Only the buyer can call this function.
        error OnlyBuyer();
        /// Only the seller can call this function.
        error OnlySeller();
        /// The function cannot be called at the current state.
        error InvalidState();
        /// The provided value has to be even.
        error ValueNotEven();

        modifier onlyBuyer() {
            if (msg.sender != buyer)
                revert OnlyBuyer();
            _;
        }

        modifier onlySeller() {
            if (msg.sender != seller)
                revert OnlySeller();
            _;
        }

        modifier inState(State state_) {
            if (state != state_)
                revert InvalidState();
            _;
        }

        event Aborted();
        event PurchaseConfirmed();
        event ItemReceived();
        event SellerRefunded();

        // Ensure that `msg.value` is an even number.
        // Division will truncate if it is an odd number.
        // Check via multiplication that it wasn't an odd number.
        constructor() payable {
            seller = payable(msg.sender);
            value = msg.value / 2;
            if ((2 * value) != msg.value)
                revert ValueNotEven();
        }

        /// Abort the purchase and reclaim the ether.
        /// Can only be called by the seller before
        /// the contract is locked.
        function abort()
            external
            onlySeller
            inState(State.Created)
        {
            emit Aborted();
            state = State.Inactive;
            // We use transfer here directly. It is
            // reentrancy-safe, because it is the
            // last call in this function and we
            // already changed the state.
            seller.transfer(address(this).balance);
        }

        /// Confirm the purchase as buyer.
        /// Transaction has to include `2 * value` ether.
        /// The ether will be locked until confirmReceived
        /// is called.
        function confirmPurchase()
            external
            inState(State.Created)
            condition(msg.value == (2 * value))
            payable
        {
            emit PurchaseConfirmed();
            buyer = payable(msg.sender);
            state = State.Locked;
        }

        /// Confirm that you (the buyer) received the item.
        /// This will release the locked ether.
        function confirmReceived()
            external
            onlyBuyer
            inState(State.Locked)
        {
            emit ItemReceived();
            // It is important to change the state first because
            // otherwise, the contracts called using `send` below
            // can call in again here.
            state = State.Release;

            buyer.transfer(value);
        }

        /// This function refunds the seller, i.e.
        /// pays back the locked funds of the seller.
        function refundSeller()
            external
            onlySeller
            inState(State.Release)
        {
            emit SellerRefunded();
            // It is important to change the state first because
            // otherwise, the contracts called using `send` below
            // can call in again here.
            state = State.Inactive;

            seller.transfer(3 * value);
        }
    }
