.. _security_considerations:

#######################
Pertimbangan Keamanan
#######################

Meskipun biasanya cukup mudah untuk membangun perangkat lunak yang berfungsi seperti yang diharapkan,
jauh lebih sulit untuk memeriksa bahwa tidak ada yang dapat menggunakannya dengan cara yang **tidak** diantisipasi.

<<<<<<< HEAD
Di Solidity, ini bahkan lebih penting karena Anda dapat menggunakan smart kontrak untuk
menangani token atau, mungkin, hal-hal yang lebih berharga. Selanjutnya, setiap pelaksanaan
smart kontrak terjadi di depan umum dan, selain itu, kode sumbernya sering tersedia.

Tentu saja Anda harus selalu mempertimbangkan berapa banyak yang dipertaruhkan:
Anda dapat membandingkan smart kontrak dengan layanan web yang terbuka untuk umum
(dan dengan demikian, juga untuk aktor jahat) dan bahkan mungkin open source.
Jika Anda hanya menyimpan daftar belanjaan Anda di layanan web itu, Anda mungkin
tidak perlu terlalu berhati-hati, tetapi jika Anda mengelola rekening bank Anda
menggunakan layanan web itu, Anda harus lebih berhati-hati.

Bagian ini akan mencantumkan beberapa perangkap dan rekomendasi keamanan umum, tetapi
tentu saja tidak akan pernah lengkap. Juga, perlu diingat bahwa meskipun kode smart
kontrak Anda bebas bug, kompiler atau platform itu sendiri mungkin memiliki bug.
Daftar beberapa bug yang relevan dengan keamanan yang diketahui publik dari kompiler
dapat ditemukan di :ref:`list of known bugs<known_bugs>`, yang juga dapat dibaca mesin.
Perhatikan bahwa ada program bug bounty yang mencakup pembuat kode dari kompiler Solidity.

Seperti biasa, dengan dokumentasi open source, tolong bantu kami memperluas bagian ini
(terutama, beberapa contoh tidak ada salahnya)!
=======
In Solidity, this is even more important because you can use smart contracts to handle tokens or,
possibly, even more valuable things.
Furthermore, every execution of a smart contract happens in public and,
in addition to that, the source code is often available.

Of course, you always have to consider how much is at stake:
You can compare a smart contract with a web service that is open to the public
(and thus, also to malicious actors) and perhaps even open-source.
If you only store your grocery list on that web service, you might not have to take too much care,
but if you manage your bank account using that web service, you should be more careful.

This section will list some pitfalls and general security recommendations
but can, of course, never be complete.
Also, keep in mind that even if your smart contract code is bug-free,
the compiler or the platform itself might have a bug.
A list of some publicly known security-relevant bugs of the compiler can be found
in the :ref:`list of known bugs<known_bugs>`, which is also machine-readable.
Note that there is a `Bug Bounty Program <https://ethereum.org/en/bug-bounty/>`_
that covers the code generator of the Solidity compiler.

As always, with open-source documentation,
please help us extend this section (especially, some examples would not hurt)!
>>>>>>> english/develop

CATATAN: Selain daftar di bawah, Anda dapat menemukan lebih banyak rekomendasi keamanan dan praktik terbaik
`in Guy Lando's knowledge list <https://github.com/guylando/KnowledgeLists/blob/master/EthereumSmartContracts.md>`_ and
`the Consensys GitHub repo <https://consensys.github.io/smart-contract-best-practices/>`_.

********
Pitfalls
********

Private Information dan Randomness
==================================

<<<<<<< HEAD
Semua yang Anda gunakan dalam smart kontrak dapat dilihat oleh publik, meskipun
variabel lokal dan variabel state ditandai sebagai ``private``.

Menggunakan angka acak dalam smart kontrak cukup rumit jika Anda
tidak ingin penambang bisa curang.
=======
Everything you use in a smart contract is publicly visible,
even local variables and state variables marked ``private``.

Using random numbers in smart contracts is quite tricky if you do not want block builders to be able to cheat.
>>>>>>> english/develop

Reentrancy
==========

<<<<<<< HEAD
Setiap interaksi dari kontrak (A) dengan kontrak lain (B) dan setiap transfer Ether
menyerahkan kendali ke kontrak itu (B). Ini memungkinkan B untuk memanggil kembali
ke A sebelum interaksi ini selesai. Sebagai contoh, kode berikut berisi bug (ini hanya
cuplikan dan bukan kontrak lengkap):
=======
Any interaction from a contract (A) with another contract (B)
and any transfer of Ether hands over control to that contract (B).
This makes it possible for B to call back into A before this interaction is completed.
To give an example, the following code contains a bug (it is just a snippet and not a complete contract):
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // THIS CONTRACT CONTAINS A BUG - DO NOT USE
    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            if (payable(msg.sender).send(shares[msg.sender]))
                shares[msg.sender] = 0;
        }
    }

<<<<<<< HEAD
Masalahnya tidak terlalu serius di sini karena terbatasnya gas sebagai bagian dari ``send``,
tetapi masih memperlihatkan kelemahan: Transfer ether selalu dapat menyertakan kode eksekusi,
sehingga penerima dapat berupa kontrak yang memanggil kembali ke ``withdraw``. Ini akan membuatnya
mendapatkan beberapa pengembalian uang dan pada dasarnya mengambil semua Ether dalam kontrak.
Secara khusus, kontrak berikut akan memungkinkan penyerang untuk mengembalikan dana beberapa kali
karena menggunakan ``call`` yang meneruskan semua gas yang tersisa secara default:
=======
The problem is not too serious here because of the limited gas as part of ``send``,
but it still exposes a weakness:
Ether transfer can always include code execution,
so the recipient could be a contract that calls back into ``withdraw``.
This would let it get multiple refunds and, basically, retrieve all the Ether in the contract.
In particular, the following contract will allow an attacker to refund multiple times
as it uses ``call`` which forwards all remaining gas by default:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    // THIS CONTRACT CONTAINS A BUG - DO NOT USE
    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            (bool success,) = msg.sender.call{value: shares[msg.sender]}("");
            if (success)
                shares[msg.sender] = 0;
        }
    }

<<<<<<< HEAD
Untuk menghindari re-entrancy, Anda dapat menggunakan pola Checks-Effects-Interactions seperti
diuraikan lebih lanjut di bawah ini:
=======
To avoid reentrancy, you can use the Checks-Effects-Interactions pattern as demonstrated below:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Fund {
        /// @dev Mapping of ether shares of the contract.
        mapping(address => uint) shares;
        /// Withdraw your share.
        function withdraw() public {
            uint share = shares[msg.sender];
            shares[msg.sender] = 0;
            payable(msg.sender).transfer(share);
        }
    }

<<<<<<< HEAD
Perhatikan bahwa re-entrancy bukan hanya efek dari transfer Ether tetapi dari panggilan fungsi
apa pun pada kontrak lain. Selain itu, Anda juga harus mempertimbangkan situasi multi-kontrak.
Kontrak yang dipanggil dapat mengubah status kontrak lain yang Anda andalkan.
=======
The Checks-Effects-Interactions pattern ensures that all code paths through a contract
complete all required checks of the supplied parameters before modifying the contract's state (Checks);
only then it makes any changes to the state (Effects);
it may make calls to functions in other contracts
*after* all planned state changes have been written to storage (Interactions).
This is a common foolproof way to prevent *reentrancy attacks*,
where an externally called malicious contract can double-spend an allowance,
double-withdraw a balance, among other things,
by using logic that calls back into the original contract before it has finalized its transaction.

Note that reentrancy is not only an effect of Ether transfer
but of any function call on another contract.
Furthermore, you also have to take multi-contract situations into account.
A called contract could modify the state of another contract you depend on.
>>>>>>> english/develop

Gas Limit dan Loops
===================

<<<<<<< HEAD
Loop yang tidak memiliki jumlah iterasi tetap, misalnya loop yang bergantung pada nilai penyimpanan, harus digunakan dengan hati-hati:
Karena batasan gas blok, transaksi hanya dapat mengkonsumsi gas dalam jumlah tertentu. Baik secara eksplisit atau hanya karena
operasi normal, jumlah iterasi dalam satu lingkaran dapat tumbuh melampaui batas gas blok yang dapat menyebabkan penyelesaian
kontrak akan terhenti pada titik tertentu. Ini mungkin tidak berlaku untuk fungsi ``view`` yang hanya dijalankan
untuk membaca data dari blockchain. Namun, fungsi tersebut dapat dipanggil oleh kontrak lain sebagai bagian dari operasi on-chain
dan stall itu. Harap jelaskan secara eksplisit tentang kasus tersebut dalam dokumentasi kontrak Anda.
=======
Loops that do not have a fixed number of iterations, for example,
loops that depend on storage values, have to be used carefully:
Due to the block gas limit, transactions can only consume a certain amount of gas.
Either explicitly or just due to normal operation,
the number of iterations in a loop can grow beyond the block gas limit
which can cause the complete contract to be stalled at a certain point.
This may not apply to ``view`` functions that are only executed to read data from the blockchain.
Still, such functions may be called by other contracts as part of on-chain operations and stall those.
Please be explicit about such cases in the documentation of your contracts.
>>>>>>> english/develop

Mengirim dan Menerima Ether
===========================

<<<<<<< HEAD
- Baik kontrak maupun "akun eksternal" saat ini tidak dapat mencegah seseorang
  mengirim Ether kepada mereka. Kontrak dapat bereaksi dan menolak transfer biasa,
  tetapi ada cara untuk memindahkan Ether tanpa membuat panggilan pesan. Salah satu
  caranya adalah dengan "menambang ke" alamat kontrak dan cara kedua adalah menggunakan ``selfdestruct(x)``.

- Jika kontrak menerima Ether (tanpa fungsi dipanggil), baik fungsi :ref:`receive Ether <receive-ether-function>`
  atau :ref:`fallback <fallback-function>` dijalankan. Jika tidak memiliki fungsi terima atau fallback,
  Ether akan ditolak (dengan melempar pengecualian). Selama pelaksanaan salah satu fungsi ini, kontrak hanya
  dapat mengandalkan "gas stipend" yang diberikan (2300 gas) yang tersedia untuknya pada saat itu. Tunjangan
  ini tidak cukup untuk mengubah penyimpanan (jangan menganggap ini begitu saja, tunjangan mungkin berubah
  dengan hard forks di masa depan). Untuk memastikan bahwa kontrak Anda dapat menerima Ether dengan cara itu,
  periksa persyaratan gas dari fungsi terima dan fallback (misalnya di bagian "detail" di Remix).

- Ada cara untuk meneruskan lebih banyak gas ke kontrak penerima menggunakan
  ``addr.call{value: x}("")``. Ini pada dasarnya sama dengan ``addr.transfer(x)``, hanya saja ia meneruskan
  semua gas yang tersisa dan membuka kemampuan penerima untuk melakukan tindakan yang lebih mahal (dan
  mengembalikan kode kegagalan alih-alih secara otomatis menyebarkan kesalahan ). Ini mungkin termasuk
  memanggil kembali ke dalam kontrak pengiriman atau perubahan state lainnya yang mungkin tidak Anda pikirkan.
  Jadi memungkinkan fleksibilitas yang besar untuk pengguna yang jujur tetapi juga untuk aktor jahat.

- Gunakan unit yang paling tepat untuk mewakili jumlah wei sebanyak mungkin, karena Anda kehilangan
  semua yang dibulatkan karena kurangnya presisi.
=======
- Neither contracts nor "external accounts" are currently able to prevent someone from sending them Ether.
  Contracts can react on and reject a regular transfer, but there are ways to move Ether without creating a message call.
  One way is to simply "mine to" the contract address and the second way is using ``selfdestruct(x)``.

- If a contract receives Ether (without a function being called), either the :ref:`receive Ether <receive-ether-function>`
  or the :ref:`fallback <fallback-function>` function is executed.
  If it does not have a ``receive`` nor a ``fallback`` function, the Ether will be rejected (by throwing an exception).
  During the execution of one of these functions, the contract can only rely on the "gas stipend" it is passed (2300 gas)
  being available to it at that time.
  This stipend is not enough to modify storage (do not take this for granted though, the stipend might change with future hard forks).
  To be sure that your contract can receive Ether in that way, check the gas requirements of the receive and fallback functions
  (for example in the "details" section in Remix).

- There is a way to forward more gas to the receiving contract using ``addr.call{value: x}("")``.
  This is essentially the same as ``addr.transfer(x)``, only that it forwards all remaining gas
  and opens up the ability for the recipient to perform more expensive actions
  (and it returns a failure code instead of automatically propagating the error).
  This might include calling back into the sending contract or other state changes you might not have thought of.
  So it allows for great flexibility for honest users but also for malicious actors.

- Use the most precise units to represent the Wei amount as possible, as you lose any that is rounded due to a lack of precision.
>>>>>>> english/develop

- Jika Anda ingin mengirim Ether menggunakan ``address.transfer``, ada beberapa detail yang harus diperhatikan:

  1. Jika penerima adalah sebuah kontrak, itu menyebabkan fungsi recieve atau
     fallback dieksekusi yang pada gilirannya, dapat memanggil kembali kontrak pengirim.
  2. Mengirim Ether dapat gagal karena kedalaman panggilan di atas 1024. Karena pemanggil
     memegang kendali penuh atas kedalaman panggilan, mereka dapat memaksa transfer gagal;
     pertimbangkan kemungkinan ini atau gunakan ``send`` dan pastikan untuk selalu memeriksa
     nilai *return*nya. Lebih baik lagi, tulis kontrak Anda menggunakan pola di mana penerima
     dapat menarik Ether sebagai gantinya.
  3. Mengirim Ether juga dapat gagal karena pelaksanaan kontrak penerima membutuhkan lebih
     dari jumlah gas yang ditentukan (secara eksplisit dengan menggunakan :ref:`require <assert-and-require>`,
     :ref:`assert <assert-and-require> `, :ref:`revert <assert-and-require>` atau karena operasinya terlalu
     mahal) - "kehabisan gas" (OOG). Jika Anda menggunakan ``transfer`` atau ``send`` dengan pemeriksaan nilai
     pengembalian, ini mungkin memberikan cara bagi penerima untuk memblokir kemajuan dalam kontrak pengiriman.
     Sekali lagi, praktik terbaik di sini adalah menggunakan pola :ref:`"withdraw" alih-alih pola "send" <withdrawal_pattern>`.

Kedalaman Call Stack
====================

<<<<<<< HEAD
Panggilan fungsi eksternal dapat gagal kapan saja karena melebihi batas
ukuran stack panggilan maksimum 1024. Dalam situasi seperti itu, Solidity
mengeluarkan pengecualian. Pelaku jahat mungkin dapat memaksa stack panggilan
ke nilai tinggi sebelum mereka berinteraksi dengan kontrak Anda. Perhatikan
bahwa, sejak `Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_ hardfork, aturan `63/64 <https://eips.ethereum.org/EIPS/eip-150>`_
membuat serangan call stack depth menjadi tidak praktis. Perhatikan juga bahwa stack panggilan dan stack ekspresi tidak terkait, meskipun keduanya memiliki batas ukuran 1024 slot stack.

Perhatikan bahwa ``.send()`` **tidak** mengeluarkan pengecualian jika stack panggilan habis,
melainkan mengembalikan ``false`` dalam kasus tersebut. Fungsi tingkat rendah ``.call()``,
``.delegatecall()`` dan ``.staticcall()`` berperilaku dengan cara yang sama.
=======
External function calls can fail at any time
because they exceed the maximum call stack size limit of 1024.
In such situations, Solidity throws an exception.
Malicious actors might be able to force the call stack to a high value
before they interact with your contract.
Note that, since `Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_ hardfork,
the `63/64 rule <https://eips.ethereum.org/EIPS/eip-150>`_ makes call stack depth attack impractical.
Also note that the call stack and the expression stack are unrelated,
even though both have a size limit of 1024 stack slots.

Note that ``.send()`` does **not** throw an exception if the call stack is depleted
but rather returns ``false`` in that case.
The low-level functions ``.call()``, ``.delegatecall()`` and ``.staticcall()`` behave in the same way.
>>>>>>> english/develop

Authorized Proxies
==================

<<<<<<< HEAD
Jika kontrak Anda dapat bertindak sebagai proxy, yaitu jika kontrak tersebut dapat memanggil
kontrak arbitrer dengan data yang disediakan pengguna, maka pengguna pada dasarnya dapat mengasumsikan
identitas kontrak proxy. Bahkan jika Anda memiliki tindakan perlindungan lain, yang terbaik adalah
membangun sistem kontrak Anda sedemikian rupa sehingga proxy tidak memiliki izin apa pun (bahkan untuk
dirinya sendiri). Jika perlu, Anda dapat melakukannya menggunakan proxy kedua:
=======
If your contract can act as a proxy, i.e. if it can call arbitrary contracts with user-supplied data,
then the user can essentially assume the identity of the proxy contract.
Even if you have other protective measures in place, it is best to build your contract system such
that the proxy does not have any permissions (not even for itself).
If needed, you can accomplish that using a second proxy:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract ProxyWithMoreFunctionality {
        PermissionlessProxy proxy;

        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return proxy.callOther(addr, payload);
        }
        // Other functions and other functionality
    }

    // This is the full contract, it has no other functionality and
    // requires no privileges to work.
    contract PermissionlessProxy {
        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return addr.call(payload);
        }
    }

tx.origin
=========

<<<<<<< HEAD
Jangan pernah menggunakan tx.origin untuk otorisasi. Katakanlah Anda memiliki kontrak dompet seperti ini:
=======
Never use ``tx.origin`` for authorization.
Let's say you have a wallet contract like this:
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // THIS CONTRACT CONTAINS A BUG - DO NOT USE
    contract TxUserWallet {
        address owner;

        constructor() {
            owner = msg.sender;
        }

        function transferTo(address payable dest, uint amount) public {
            // THE BUG IS RIGHT HERE, you must use msg.sender instead of tx.origin
            require(tx.origin == owner);
            dest.transfer(amount);
        }
    }

Sekarang seseorang menipu Anda untuk mengirim Ether ke alamat dompet serangan ini:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    interface TxUserWallet {
        function transferTo(address payable dest, uint amount) external;
    }

    contract TxAttackWallet {
        address payable owner;

        constructor() {
            owner = payable(msg.sender);
        }

        receive() external payable {
            TxUserWallet(msg.sender).transferTo(owner, msg.sender.balance);
        }
    }

<<<<<<< HEAD
Jika dompet Anda telah memeriksa ``msg.sender`` untuk otorisasi, dompet tersebut akan mendapatkan alamat dompet penyerang, bukan alamat pemilik. Tetapi dengan memeriksa ``tx.origin``, ia mendapatkan alamat asli yang memulai transaksi, yang masih merupakan alamat pemilik. Dompet serangan langsung menguras semua dana Anda.
=======
If your wallet had checked ``msg.sender`` for authorization, it would get the address of the attack wallet,
instead of the owner's address.
But by checking ``tx.origin``, it gets the original address that kicked off the transaction,
which is still the owner's address.
The attack wallet instantly drains all your funds.
>>>>>>> english/develop

.. _underflow-overflow:

Dua Complement / Underflows / Overflows
=========================================

Seperti dalam banyak bahasa pemrograman, tipe integer Solidity sebenarnya bukan integer.
Mereka menyerupai integer ketika nilainya kecil, tetapi tidak dapat mewakili angka besar arbitrarily.

Kode berikut menyebabkan overflow karena hasil penjumlahan terlalu besar
untuk disimpan dalam tipe ``uint8``:

.. code-block:: solidity

  uint8 x = 255;
  uint8 y = 1;
  return x + y;

Solidity memiliki dua mode yang menangani overflows ini: mode Checked and Unchecked atau "wrapping".

Mode default checked akan mendeteksi overflows dan menyebabkan kegagalan assertion. Anda dapat menonaktifkan check
ini menggubakan ``unchecked { ... }``, menyebabkan overflow secara diam-diam di abaikan. Kode di atas akan kembali
``0`` jika di*wrap* dengan ``unchecked { ... }``.

Meskipun di mode checked, jangan berasumsi Anda terlindungi dari bug overflow.
Di dalam mode ini, overflows akan selalu revert. Jika tidak mungkin untuk menghindari
overflow, ini dapat menyebabkan smart kontrak terjebak dalam keadaan tertentu.

Secara umum, baca tentang batas representasi komplemen dua, yang bahkan memiliki beberapa
lebih banyak kasus tepi khusus untuk nomor yang ditandatangani.

Coba gunakan ``require`` untuk membatasi ukuran input ke kisaran yang wajar dan gunakan
:ref:`SMT checker<smt_checker>` untuk menemukan potensi overflow.

.. _clearing-mappings:

Clearing Mappings
=================

<<<<<<< HEAD
Solidity tipe ``mapping`` (lihat :ref:`mapping-types`) adalah struktur
storage-only key-value data yang tidak melacak kunci yang diberi nilai bukan nol.
Karena itu, pembersihan mapping tanpa informasi tambahan tentang kunci tertulis
tidak mungkin dilakukan. Jika ``mapping`` digunakan sebagai tipe dasar array penyimpanan
dinamis, menghapus atau memunculkan array tidak akan berpengaruh pada elemen ``mapping``.
Hal yang sama terjadi, misalnya, jika ``mapping`` digunakan sebagai tipe bidang anggota
dari ``struct`` yang merupakan tipe dasar array penyimpanan dinamis. ``mapping`` juga
diabaikan dalam penetapan struct atau array yang berisi ``mapping``.
=======
The Solidity type ``mapping`` (see :ref:`mapping-types`) is a storage-only key-value data structure
that does not keep track of the keys that were assigned a non-zero value.
Because of that, cleaning a mapping without extra information about the written keys is not possible.
If a ``mapping`` is used as the base type of a dynamic storage array,
deleting or popping the array will have no effect over the ``mapping`` elements.
The same happens, for example, if a ``mapping`` is used as the type of a member field of a ``struct``
that is the base type of a dynamic storage array.
The ``mapping`` is also ignored in assignments of structs or arrays containing a ``mapping``.
>>>>>>> english/develop

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Map {
        mapping(uint => uint)[] array;

        function allocate(uint newMaps) public {
            for (uint i = 0; i < newMaps; i++)
                array.push();
        }

        function writeMap(uint map, uint key, uint value) public {
            array[map][key] = value;
        }

        function readMap(uint map, uint key) public view returns (uint) {
            return array[map][key];
        }

        function eraseMaps() public {
            delete array;
        }
    }

<<<<<<< HEAD
Perhatikan contoh di atas dan urutan panggilan berikut: ``allocate(10)``,
``writeMap(4, 128, 256)``.
Pada titik ini, memanggil ``readMap(4, 128)`` mengembalikan 256.
Jika kita memanggil ``eraseMaps``, panjang variabel status ``array`` adalah nol, tetapi
karena elemen ``pemetaan`` tidak dapat di-nolkan, informasinya tetap hidup
dalam penyimpanan kontrak.
Setelah menghapus ``array``, memanggil ``allocate(5)`` memungkinkan kita untuk mengakses
``array[4]`` lagi, dan memanggil ``readMap(4, 128)`` mengembalikan 256 bahkan tanpa
panggilan lain ke ``writeMap``.
=======
Consider the example above and the following sequence of calls: ``allocate(10)``, ``writeMap(4, 128, 256)``.
At this point, calling ``readMap(4, 128)`` returns 256.
If we call ``eraseMaps``, the length of the state variable ``array`` is zeroed,
but since its ``mapping`` elements cannot be zeroed, their information stays alive in the contract's storage.
After deleting ``array``, calling ``allocate(5)`` allows us to access ``array[4]`` again,
and calling ``readMap(4, 128)`` returns 256 even without another call to ``writeMap``.
>>>>>>> english/develop

Jika informasi ``mapping`` Anda harus dihapus, pertimbangkan untuk menggunakan library yang mirip dengan
`iterable mapping <https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol>`_,
memungkinkan Anda menelusuri kunci dan menghapus nilainya dalam ``mapping`` yang sesuai.

Minor Details
=============

<<<<<<< HEAD
- Jenis yang tidak menempati 32 byte penuh mungkin berisi "dirty higher order bits".
  Ini sangat penting jika Anda mengakses ``msg.data`` - itu menimbulkan resiko *malleability*:
  Anda dapat membuat transaksi yang memanggil fungsi ``f(uint8 x)`` dengan argumen byte mentah
  dari ``0xff000001`` dan dengan ``0x00000001``. Keduanya diumpankan ke kontrak dan keduanya akan
  terlihat seperti angka ``1`` sejauh menyangkut ``x``, tetapi ``msg.data`` akan
  berbeda, jadi jika Anda menggunakan ``keccak256(msg.data)`` untuk apa pun, Anda akan mendapatkan hasil yang berbeda.
=======
- Types that do not occupy the full 32 bytes might contain "dirty higher order bits".
  This is especially important if you access ``msg.data`` - it poses a malleability risk:
  You can craft transactions that call a function ``f(uint8 x)``
  with a raw byte argument of ``0xff000001`` and with ``0x00000001``.
  Both are fed to the contract and both will look like the number ``1`` as far as ``x`` is concerned,
  but ``msg.data`` will be different, so if you use ``keccak256(msg.data)`` for anything,
  you will get different results.
>>>>>>> english/develop

***************
Rekomendasi
***************

Ambil Peringatan dengan Serius
==============================

Jika kompiler memperingatkan Anda tentang sesuatu, Anda harus mengubahnya.
Bahkan jika Anda tidak berpikir bahwa peringatan khusus ini memiliki implikasi
keamanan, mungkin ada masalah lain yang terkubur di bawahnya. Setiap peringatan
kompiler yang kami keluarkan dapat dibungkam dengan sedikit perubahan pada kode.

Selalu gunakan versi terbaru kompiler untuk diberi tahu tentang semua peringatan
yang baru saja diperkenalkan.

Pesan bertipe ``info`` yang dikeluarkan oleh kompilator tidak berbahaya, dan hanya
mewakili saran tambahan dan informasi opsional yang dipikirkan oleh kompiler
mungkin berguna bagi pengguna.

Membatasi Jumlah Ether
======================

Batasi jumlah Ether (atau token lainnya) yang dapat disimpan di smart
kontrak. Jika kode sumber Anda, kompiler, atau platform memiliki bug, dana
ini bisa hilang. Jika Anda ingin membatasi kerugian Anda, batasi jumlah Ether.

Tetap Kecil dan Modular
=======================

<<<<<<< HEAD
Jaga agar kontrak Anda tetap kecil dan mudah dimengerti. Pilih yang tidak terkait
fungsionalitas dalam kontrak lain atau ke perpustakaan. Rekomendasi umum
tentang kualitas kode sumber tentu saja berlaku: Batasi jumlah variabel lokal,
panjang fungsi dan sebagainya. Dokumentasikan fungsi Anda agar yang lain
dapat melihat apa niat Anda dan apakah itu berbeda dari apa yang dilakukan kode.

Gunakan pola Checks-Effects-Interactions
========================================

Sebagian besar fungsi pertama-tama akan melakukan beberapa pemeriksaan
(siapa yang memanggil fungsi, apakah argumen dalam jangkauan, apakah mereka
mengirim cukup Ether, apakah orang tersebut memiliki token, dll.). Pemeriksaan
ini harus dilakukan terlebih dahulu.
=======
If the compiler warns you about something, you should change it.
Even if you do not think that this particular warning has security implications,
there might be another issue buried beneath it.
Any compiler warning we issue can be silenced by slight changes to the code.

Always use the latest version of the compiler to be notified about all recently introduced warnings.

Messages of type ``info``, issued by the compiler, are not dangerous
and simply represent extra suggestions and optional information
that the compiler thinks might be useful to the user.
>>>>>>> english/develop

Sebagai langkah kedua, jika semua pemeriksaan lulus, efeknya pada variabel state
kontrak saat ini harus dibuat. Interaksi dengan kontrak lain
harus menjadi langkah terakhir dalam fungsi apa pun.

<<<<<<< HEAD
Kontrak awal menunda beberapa efek dan menunggu fungsi eksternal
panggilan untuk kembali dalam keadaan non-kesalahan. Ini sering merupakan kesalahan serius
karena masalah masuk kembali yang dijelaskan di atas.
=======
Restrict the amount of Ether (or other tokens) that can be stored in a smart contract.
If your source code, the compiler or the platform has a bug, these funds may be lost.
If you want to limit your loss, limit the amount of Ether.
>>>>>>> english/develop

Perhatikan bahwa, juga, panggilan ke kontrak yang diketahui dapat menyebabkan panggilan ke
kontrak yang tidak diketahui, jadi mungkin lebih baik untuk selalu menerapkan pola ini.

<<<<<<< HEAD
Sertakan mode Fail-Safe
=======================
=======
Keep your contracts small and easily understandable.
Single out unrelated functionality in other contracts or into libraries.
General recommendations about the source code quality of course apply:
Limit the amount of local variables, the length of functions and so on.
Document your functions so that others can see what your intention was
and whether it is different than what the code does.
>>>>>>> english/develop

Saat membuat sistem Anda terdesentralisasi sepenuhnya akan menghapus perantara apa pun,
mungkin ide yang bagus, terutama untuk kode baru, untuk memasukkan beberapa jenis
mekanisme fail-safe:

<<<<<<< HEAD
Anda dapat menambahkan fungsi dalam kontrak pintar Anda yang melakukan beberapa
self-check seperti "Apakah ada Ether yang bocor?",
"Apakah jumlah token sama dengan saldo kontrak?" atau hal serupa.
Ingatlah bahwa Anda tidak dapat menggunakan terlalu banyak gas untuk itu, jadi bantulah melalui off-chain
perhitungan mungkin diperlukan di sana.

Jika pemeriksaan mandiri gagal, kontrak secara otomatis berubah menjadi semacam
dari mode "failsafe", yang, misalnya, menonaktifkan sebagian besar fitur, menyerahkan
kontrol ke pihak ketiga yang tetap dan tepercaya atau hanya mengubah kontrak menjadi
kontrak sederhana "beri saya kembali uang saya".

Minta Review Sejawat
====================

Semakin banyak orang memeriksa sepotong kode, semakin banyak masalah yang ditemukan.
Meminta orang untuk meninjau kode Anda juga membantu sebagai pemeriksaan silang untuk mengetahui apakah kode Anda
mudah dimengerti - kriteria yang sangat penting untuk smart kontrak yang baik.
=======
Most functions will first perform some checks and they should be done first
(who called the function, are the arguments in range, did they send enough Ether,
does the person have tokens, etc.).

As the second step, if all checks passed, effects to the state variables of the current contract should be made.
Interaction with other contracts should be the very last step in any function.

Early contracts delayed some effects and waited for external function calls to return in a non-error state.
This is often a serious mistake because of the reentrancy problem explained above.

Note that, also, calls to known contracts might in turn cause calls to
unknown contracts, so it is probably better to just always apply this pattern.

Include a Fail-Safe Mode
========================

While making your system fully decentralized will remove any intermediary,
it might be a good idea, especially for new code, to include some kind of fail-safe mechanism:

You can add a function in your smart contract that performs some self-checks like "Has any Ether leaked?",
"Is the sum of the tokens equal to the balance of the contract?" or similar things.
Keep in mind that you cannot use too much gas for that,
so help through off-chain computations might be needed there.

If the self-check fails, the contract automatically switches into some kind of "failsafe" mode,
which, for example, disables most of the features,
hands over control to a fixed and trusted third party
or just converts the contract into a simple "give me back my Ether" contract.

Ask for Peer Review
===================

The more people examine a piece of code, the more issues are found.
Asking people to review your code also helps as a cross-check to find out
whether your code is easy to understand -
a very important criterion for good smart contracts.
>>>>>>> english/develop
