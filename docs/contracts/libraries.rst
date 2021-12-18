.. index:: ! library, callcode, delegatecall

.. _libraries:

*********
Libraries
*********

Libraries mirip dengan kontrak, tetapi tujuannya adalah bahwa mereka hanya digunakan
sekali di alamat tertentu dan kodenya digunakan kembali menggunakan fitur ``DELEGATECALL``
(``CALLCODE`` hingga Homestead) dari EVM. Ini berarti bahwa jika fungsi library dipanggil, kodenya
dieksekusi dalam konteks kontrak panggilan, yaitu ``this`` menunjuk ke kontrak panggilan, dan terutama
penyimpanan dari kontrak panggilan dapat diakses. Karena library adalah bagian dari kode sumber yang
terisolasi, ia hanya dapat mengakses variabel state dari kontrak panggilan jika mereka disediakan secara
eksplisit (jika tidak, tidak ada cara untuk menamainya). Fungsi library hanya dapat dipanggil secara
langsung (yaitu tanpa menggunakan ``DELEGATECALL``) jika fungsi tersebut tidak mengubah state (yaitu
jika fungsi tersebut adalah ``view`` atau ``pure``), karena library diasumsikan menjadi *stateless*. Secara
khusus, tidak mungkin untuk menghancurkan library.

.. note::
    Hingga versi 0.4.20, library dapat dihancurkan dengan menghindari sistem tipe Solidity. Mulai dari
    versi tersebut, library berisi :ref:`mekanisme<call-protection>` yang melarang fungsi state-modifying
    dipanggil secara langsung (yaitu tanpa ``DELEGATECALL``).

Perpustakaan dapat dilihat sebagai basis kontrak implisit dari kontrak yang menggunakannya.
Mereka tidak akan terlihat secara eksplisit dalam hierarki pewarisan, tetapi panggilan ke
fungsi library terlihat seperti panggilan ke fungsi  eksplisit basis kontrak (menggunakan akses
yang memenuhi syarat seperti ``L.f()``).
Tentu saja, panggilan ke fungsi internal menggunakan konvensi panggilan internal,
yang berarti bahwa semua tipe internal dapat diteruskan dan tipe :ref:`disimpan dalam
memori <data-location>` akan diteruskan dengan referensi dan tidak disalin.
Untuk merealisasikan hal ini dalam EVM, kode fungsi library internal dan semua fungsi yang dipanggil
dari dalamnya pada waktu kompilasi akan dimasukkan dalam kontrak panggilan, dan panggilan ``JUMP`` biasa
akan digunakan sebagai pengganti ``DELEGATECALL``.

.. note::
    Analogi inheritance rusak ketika datang ke fungsi publik.
    Memanggil fungsi library umum dengan ``L.f()`` menghasilkan
    panggilan eksternal (``DELEGATECALL`` tepatnya). Sebaliknya, ``A.f()`` adalah
    panggilan internal ketika ``A`` adalah basis kontrak dari kontrak saat ini.

.. index:: using for, set

Contoh berikut mengilustrasikan cara menggunakan library (tetapi menggunakan metode manual,
pastikan untuk memeriksa :ref:`using for <using-for>` untuk contoh lebih lanjut untuk mengimplementasikan
satu set).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;


    // We define a new struct datatype that will be used to
    // hold its data in the calling contract.
    struct Data {
        mapping(uint => bool) flags;
    }

    library Set {
        // Note that the first parameter is of type "storage
        // reference" and thus only its storage address and not
        // its contents is passed as part of the call.  This is a
        // special feature of library functions.  It is idiomatic
        // to call the first parameter `self`, if the function can
        // be seen as a method of that object.
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
        Data knownValues;

        function register(uint value) public {
            // The library functions can be called without a
            // specific instance of the library, since the
            // "instance" will be the current contract.
            require(Set.insert(knownValues, value));
        }
        // In this contract, we can also directly access knownValues.flags, if we want.
    }

Tentu saja, Anda tidak harus mengikuti cara ini untuk menggunakan
library: mereka juga dapat digunakan tanpa mendefinisikan struct
tipe data. Fungsi juga berfungsi tanpa parameter referensi
penyimpanan apa pun, dan mereka dapat memiliki beberapa referensi parameter
penyimpanan dan dalam posisi apapun.

Panggilan ke ``Set.contains``, ``Set.insert`` dan ``Set.remove`` semuanya dikompilasi sebagai panggilan (``DELEGATECALL``) ke kontrak/library eksternal.
Jika Anda menggunakan library, ketahuilah bahwa panggilan fungsi eksternallah yang sebenarnya dilakukan.
``msg.sender``, ``msg.value`` dan ``this`` akan mempertahankan nilainya dalam panggilan ini, meskipun (sebelum Homestead, karena penggunaan ``CALLCODE``, ``msg. sender`` dan ``msg.value`` berubah)

Contoh berikut menunjukkan cara menggunakan :ref:`types yang disimpan di memori <data-location>`
dan fungsi internal di library untuk mengimplementasikan tipe kustom tanpa overhead dari panggilan
fungsi eksternal:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;

    struct bigint {
        uint[] limbs;
    }

    library BigInt {
        function fromUint(uint x) internal pure returns (bigint memory r) {
            r.limbs = new uint[](1);
            r.limbs[0] = x;
        }

        function add(bigint memory _a, bigint memory _b) internal pure returns (bigint memory r) {
            r.limbs = new uint[](max(_a.limbs.length, _b.limbs.length));
            uint carry = 0;
            for (uint i = 0; i < r.limbs.length; ++i) {
                uint a = limb(_a, i);
                uint b = limb(_b, i);
                unchecked {
                    r.limbs[i] = a + b + carry;

                    if (a + b < a || (a + b == type(uint).max && carry > 0))
                        carry = 1;
                    else
                        carry = 0;
                }
            }
            if (carry > 0) {
                // too bad, we have to add a limb
                uint[] memory newLimbs = new uint[](r.limbs.length + 1);
                uint i;
                for (i = 0; i < r.limbs.length; ++i)
                    newLimbs[i] = r.limbs[i];
                newLimbs[i] = carry;
                r.limbs = newLimbs;
            }
        }

        function limb(bigint memory _a, uint _limb) internal pure returns (uint) {
            return _limb < _a.limbs.length ? _a.limbs[_limb] : 0;
        }

        function max(uint a, uint b) private pure returns (uint) {
            return a > b ? a : b;
        }
    }

    contract C {
        using BigInt for bigint;

        function f() public pure {
            bigint memory x = BigInt.fromUint(7);
            bigint memory y = BigInt.fromUint(type(uint).max);
            bigint memory z = x.add(y);
            assert(z.limb(1) > 0);
        }
    }

Dimungkinkan untuk memperoleh alamat library dengan mengonversi tipe library
ke tipe ``address``, yaitu menggunakan ``address(LibraryName)``.

Karena kompilator tidak mengetahui alamat tempat library akan di-deploy, kode hex yang dikompilasi
akan berisi placeholder dalam bentuk ``__$30bbc0abd4d6364515865950d3e0d10953$__``. Placeholder adalah
prefiks 34 karakter dari pengkodean hex dari hash keccak256 dari nama libraray yang sepenuhnya memenuhi
syarat, yang akan menjadi contoh ``libraries/bigint.sol:BigInt`` jika perpustakaan disimpan dalam file
bernama ``bigint .sol`` dalam direktori ``libraries/``. Bytecode tersebut tidak lengkap dan tidak boleh
dideploy. Placeholder perlu diganti dengan alamat sebenarnya. Anda dapat melakukannya dengan meneruskannya
ke kompiler saat library sedang dikompilasi atau dengan menggunakan tautan untuk memperbarui biner yang sudah
dikompilasi. Lihat :ref:`library-linking` untuk informasi tentang cara menggunakan kompiler baris perintah
untuk penautan.

Dibandingkan dengan kontrak, library dibatasi dengan cara berikut:

- mereka tidak dapat memiliki variabel state
- mereka tidak dapat mewarisi atau diwarisi
- mereka tidak dapat menerima Ether
- mereka tidak dapat dihancurkan

(hal Ini mungkin akan diangkat di lain waktu.)

.. _library-selectors:
.. index:: selector

Fungsi Tanda Tangan dan Selektor di library
===========================================

Meskipun panggilan eksternal ke fungsi library publik atau eksternal dimungkinkan, konvensi panggilan untuk panggilan
tersebut dianggap internal untuk Solidity dan tidak sama seperti yang ditentukan untuk :ref:`contract ABI<ABI>` reguler.
Fungsi library eksternal mendukung lebih banyak tipe argumen daripada fungsi kontrak eksternal, misalnya struct rekursif
dan pointer penyimpanan. Untuk alasan itu, fungsi tanda tangan yang digunakan untuk menghitung pemilih 4-byte dihitung
mengikuti skema penamaan internal dan argumen jenis yang tidak didukung dalam kontrak ABI menggunakan pengkodean internal.

Pengidentifikasi berikut digunakan untuk tipe dalam tanda tangan:

- Jenis nilai, non-storage ``string``, dan non-storage ``byte`` menggunakan pengidentifikasi yang sama seperti dalam kontrak ABI.
- Jenis Non-storage array mengikuti konvensi yang sama seperti dalam kontrak ABI, yaitu ``<type>[]`` untuk array dinamis dan
  ``<type>[M]`` untuk array berukuran tetap ``M` ` elemen.
- Struktur Non-storage dirujuk dengan nama yang sepenuhnya memenuhi syarat, yaitu ``C.S`` untuk ``contract C { struct S { ... } }``.
- Storage pointer mapping menggunakan ``mapping(<keyType> =><valueType>) storage`` di mana ``<keyType>`` dan ``<valueType>`` adalah
  pengidentifikasi untuk tipe kunci dan nilai mapping, berturut-turut.
- Tipe storage pointer lainnya menggunakan tipe identifier dari tipe non-storage yang sesuai, tetapi menambahkan satu spasi diikuti oleh
  ``storage`` ke dalamnya.

Encoding argumen sama dengan kontrak ABI reguler, kecuali untuk storage pointer, yang dikodekan sebagai nilai
``uint256`` yang mengacu pada slot penyimpanan yang ditunjuknya.

Sama halnya dengan kontrak ABI, pemilih terdiri dari empat byte pertama dari tanda tangan Keccak256-hash.
Nilainya dapat diperoleh dari Solidity menggunakan anggota ``.selector`` sebagai berikut:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.14 <0.9.0;

    library L {
        function f(uint256) external {}
    }

    contract C {
        function g() public pure returns (bytes4) {
            return L.f.selector;
        }
    }



.. _call-protection:

Perlindungan Panggilan Untuk Libraries
======================================

Seperti disebutkan dalam pendahuluan, jika kode library dieksekusi menggunakan
``CALL`` alih-alih ``DELEGATECALL`` atau ``CALLCODE``, kode tersebut akan dikembalikan
kecuali fungsi ``view`` atau ``pure`` disebut.

EVM tidak menyediakan cara langsung bagi sebuah kontrak untuk mendeteksi
apakah kontrak tersebut dipanggil menggunakan ``CALL`` atau tidak, tetapi sebuah kontrak
dapat menggunakan opcode ``ADDRESS`` untuk mengetahui "di mana" kontrak
tersebut sedang berjalan. Kode yang dihasilkan membandingkan alamat ini
dengan alamat yang digunakan pada waktu konstruksi untuk menentukan mode panggilan.

Lebih khusus lagi, kode runtime library selalu dimulai dengan instruksi push, yang merupakan
nol dari 20 byte pada waktu kompilasi. Ketika kode penerapan berjalan, konstanta ini diganti
dalam memori dengan alamat saat ini dan kode yang dimodifikasi ini disimpan dalam kontrak.
Saat runtime, ini menyebabkan alamat waktu penerapan menjadi konstanta pertama yang didorong
ke stack dan kode operator membandingkan alamat saat ini dengan konstanta ini untuk fungsi
non-view dan non-pure.

Ini berarti bahwa kode sebenarnya disimpan di rantai untuk Library
berbeda dari kode yang dilaporkan oleh kompiler sebagai
``deployedBytecode``.
