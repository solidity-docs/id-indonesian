.. index:: ! functions

.. _functions:

*****************
Function (fungsi)
*****************

Fungsi dapat didefinisikan di dalam dan di luar kontrak.

Fungsi di luar kontrak, juga disebut "fungsi bebas", selalu memiliki implisit ``internal``
:ref:`visibility<visibility-and-getter>`. Kode mereka termasuk dalam semua kontrak yang
memanggil mereka, mirip dengan fungsi library internal.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    function sum(uint[] memory _arr) pure returns (uint s) {
        for (uint i = 0; i < _arr.length; i++)
            s += _arr[i];
    }

    contract ArrayExample {
        bool found;
        function f(uint[] memory _arr) public {
            // This calls the free function internally.
            // The compiler will add its code to the contract.
            uint s = sum(_arr);
            require(s >= 10);
            found = true;
        }
    }

.. note::
    Fungsi yang didefinisikan di luar kontrak masih selalu dijalankan dalam konteks kontrak. Mereka masih
    memiliki akses ke variabel ``this``, dapat memanggil kontrak lain, mengirim mereka Ether dan menghancurkan
    kontrak yang memanggil mereka, antara lain. Perbedaan utama pada fungsi yang didefinisikan di dalam kontrak
    adalah bahwa fungsi bebas tidak memiliki akses langsung ke variabel storage dan fungsi tidak berada dalam
    cakupannya.

.. _function-parameters-return-variables:

Parameter Fungsi dan Variabel Return
====================================

Fungsi mengambil parameter yang diketik sebagai input dan mungkin, tidak seperti di banyak bahasa lain,
juga menghasilkan sejumlah nilai arbitrary sebagai output.

Prameter Fungsi
---------------

Parameter fungsi dideklarasikan dengan cara yang sama seperti variabel, dan nama parameter
yang tidak digunakan dapat dihilangkan.

Misalnya, jika Anda ingin kontrak Anda menerima satu jenis panggilan eksternal
dengan dua integer, Anda akan menggunakan sesuatu seperti berikut:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        uint sum;
        function taker(uint _a, uint _b) public {
            sum = _a + _b;
        }
    }

Parameter fungsi dapat digunakan sebagai variabel lokal lainnya dan mereka juga dapat ditugaskan.

.. note::

  Sebuah :ref:`external function<external-function-calls>` tidak dapat menerima
  array multidimensi sebagai input
  parameter. Fungsionalitas ini dimungkinkan jika Anda mengaktifkan ABI coder v2
  dengan menambahkan ``pragma abicoder v2;`` ke file sumber Anda.

  Sebuah :ref:`internal function<external-function-calls>` dapat menerima
  array multi-dimensi tanpa mengaktifkan fitur.

.. index:: return array, return string, array, string, array of strings, dynamic array, variably sized array, return struct, struct

Variabel Return
----------------

Variabel return fungsi dideklarasikan dengan sintaks yang sama setelah
kata kunci ``returns``.

Misalnya, Anda ingin mengembalikan dua hasil: jumlah dan produk dari dua integer
yang diteruskan sebagai parameter fungsi, maka Anda menggunakan sesuatu seperti:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        function arithmetic(uint _a, uint _b)
            public
            pure
            returns (uint o_sum, uint o_product)
        {
            o_sum = _a + _b;
            o_product = _a * _b;
        }
    }

Nama-nama variabel return dapat dihilangkan.
Variabel return dapat digunakan sebagai variabel lokal lainnya
dan variabel tersebut diinisialisasi dengan :ref:`nilai default
<default-value>` dan memiliki nilai tersebut hingga (kembali) ditetapkan.

Anda dapat secara eksplisit menetapkan ke variabel return dan kemudian
meninggalkan fungsi seperti di atas, atau Anda dapat memberikan nilai yang
dikembalikan (baik satu atau :ref:`multiple one<multi-return>`) secara
langsung dengan pernyataan ``return``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        function arithmetic(uint _a, uint _b)
            public
            pure
            returns (uint o_sum, uint o_product)
        {
            return (_a + _b, _a * _b);
        }
    }

Jika Anda menggunakan ``return`` lebih awal untuk meninggalkan fungsi yang memiliki variabel return,
Anda harus memberikan nilai return bersamaan dengan pernyataan return.

.. note::
    Anda tidak dapat mengembalikan beberapa tipe dari fungsi non-internal, terutama
    array dan struct dinamis multi-dimensi. Jika Anda mengaktifkan
    You cannot return some types from non-internal functions, notably
    multi-dimensional dynamic arrays and structs. If you enable the
    ABI coder v2 dengan menambahkan ``pragma abicoder v2;`` ke file sumber Anda,
    maka lebih banyak jenis yang tersedia, tetapi jenis ``mapping`` masih terbatas
    di dalam satu kontrak dan Anda tidak dapat mentransfernya.

.. _multi-return:

Mengembalikan Beberapa Nilai
----------------------------

Ketika suatu fungsi memiliki beberapa tipe pengembalian, pernyataan ``return (v0, v1, ..., vn)`` dapat digunakan untuk mengembalikan beberapa nilai.
Jumlah komponen harus sama dengan jumlah variabel return dan jenisnya harus cocok,
kemungkinan setelah :ref:`konversi implisit <types-conversion-elementary-types>`.

.. _state-mutability:

State Mutability
================

.. index:: ! view function, function;view

.. _view-functions:

Fungsi view
--------------

Fungsi dapat dideklarasikan dengan ``view`` dalam hal ini mereka berjanji untuk tidak mengubah state.

.. note::
  Jika target EVM compiler adalah Byzantium atau yang lebih baru (default) opcode
  ``STATICCALL`` digunakan ketika fungsi ``view`` dipanggil, yang memaksa state untuk tetap
  tidak dimodifikasi sebagai bagian dari eksekusi EVM. Untuk library ``view`` fungsi ``DELEGATECALL``
  digunakan, karena tidak ada gabungan antara ``DELEGATECALL`` dan ``STATICCALL``. Ini berarti fungsi
  library ``view`` tidak memiliki pemeriksaan run-time yang mencegah modifikasi state. Ini seharusnya
  tidak berdampak negatif pada keamanan karena kode library biasanya diketahui pada waktu kompilasi dan
  pemeriksa statis melakukan pemeriksaan compile-time.

Pernyataan berikut dianggap mengubah state:

#. Menulis ke variabel state.
#. :ref:`Emitting events <events>`.
#. :ref:`Membuat kontrak lain <creating-contracts>`.
#. Menggunakan ``selfdestruct``.
#. Mengirim Ether via call.
#. Memanggil fungsi apa pun yang tidak ditandai dengan ``view`` atau ``pure``.
#. Menggunakan low-level call.
#. Menggunakan perakitan inline yang berisi opcode tertentu.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        function f(uint a, uint b) public view returns (uint) {
            return a * (b + 42) + block.timestamp;
        }
    }

.. note::
  ``constant`` pada fungsi dulunya merupakan alias untuk ``view``, tetapi ini dihapus di versi 0.5.0.

.. note::
  Metode getter secara otomatis ditandai ``view``.

.. note::
  Sebelum versi 0.5.0, compiler tidak menggunakan opcode ``STATICCALL``
  untuk fungsi ``view``.
  Ini mengaktifkan modifikasi state dalam fungsi ``view`` melalui penggunaan
  konversi jenis eksplisit yang tidak valid.
  Dengan menggunakan ``STATICCALL`` untuk fungsi ``view``, modifikasi state
  dicegah pada level EVM.

.. index:: ! pure function, function;pure

.. _pure-functions:

Fungsi Pure
--------------

Fungsi dapat dideklarasikan dengan ``pure`` dalam hal ini mereka berjanji untuk tidak membaca atau mengubah state.
Secara khusus, seharusnya mungkin untuk mengevaluasi fungsi ``pure`` pada waktu kompilasi hanya dengan memasukkan
input dan ``msg.data``, tetapi tanpa pengetahuan tentang status blockchain saat ini.
Ini berarti bahwa membaca dari variabel ``immutable`` bisa menjadi operasi non-pure.

.. note::
  Jika target Kompiler EVM adalah Byzantium atau yang lebih baru (default) opcode ``STATICCALL`` digunakan,
  yang tidak menjamin bahwa state tidak dibaca, tetapi setidaknya tidak diubah.

Selain daftar pernyataan pengubah state yang dijelaskan di atas, berikut ini dianggap membaca dari state:

#. Membaca dari variabel state.
#. Mengakses ``address(this).balance`` atau ``<address>.balance``.
#. Mengakses salah satu anggota ``block``, ``tx``, ``msg`` (dengan pengecualian ``msg.sig`` dan ``msg.data``).
#. Memanggil fungsi apa pun yang tidak ditandai ``pure``.
#. Menggunakan perakitan inline yang berisi opcode tertentu.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        function f(uint a, uint b) public pure returns (uint) {
            return a * (b + 42);
        }
    }

Fungsi pure dapat menggunakan fungsi ``revert()`` dan ``require()`` untuk mengembalikan
potensi perubahan state saat :ref:`error terjadi <assert-and-require>`.

Mengembalikan perubahan state tidak dianggap sebagai "modifikasi state", karena hanya perubahan
state yang dibuat sebelumnya dalam kode yang tidak memiliki batasan ``view`` atau ``pure`` yang dikembalikan
dan kode tersebut memiliki opsi untuk menangkap ``revert`` dan tidak menyebarkannya.

Perilaku ini juga sejalan dengan opcode ``STATICCALL``.

.. warning::
  Tidak mungkin untuk mencegah fungsi membaca state di level EVM,
  hanya mungkin mencegahnya untuk menulis ke state (yaitu hanya ``view``
  yang dapat diterapkan di level EVM, sedangkan ``pure`` tidak bisa).

.. note::
  Sebelum versi 0.5.0, compiler tidak menggunakan opcode ``STATICCALL`` untuk fungsi ``pure``.
  Ini mengaktifkan modifikasi state dalam fungsi ``pure`` melalui penggunaan konversi jenis eksplisit yang tidak valid.
  Dengan menggunakan ``STATICCALL`` untuk fungsi ``pure``, modifikasi state dicegah pada level EVM.

.. note::
  Sebelum versi 0.4.17 kompiler tidak memaksakan bahwa ``pure`` tidak membaca state.
  Ini adalah pemeriksaan tipe compile-time, yang dapat dielakkan dengan melakukan konversi
  eksplisit yang tidak valid antara tipe kontrak, karena kompiler dapat memverifikasi bahwa
  tipe kontrak tidak melakukan operasi perubahan state, tetapi tidak dapat memeriksa apakah
  kontrak yang akan dipanggil saat runtime sebenarnya dari jenis itu.

.. _special-functions:

Fungsi Spesial
==============

.. index:: ! receive ether function, function;receive ! receive

.. _receive-ether-function:

Fungsi Terima Ether
----------------------

Sebuah kontrak dapat memiliki paling banyak satu fungsi, yang dideklarasikan menggunakan
``receive() external payable { ... }``
(tanpa kata kunci ``function``).
Fungsi ini tidak dapat memiliki argumen, tidak dapat mengembalikan apa pun dan harus memiliki
visibilitas ``eksternal`` dan mutabilitas state ``payable``.
Itu bisa virtual, dapat menimpa dan dapat memiliki modifiers.

Fungsi terima dieksekusi pada panggilan
ke kontrak dengan calldata kosong. Ini adalah fungsi yang dijalankan
pada transfer Ether biasa (misalnya melalui ``.send()`` atau ``.transfer()``). Jika tidak ada
fungsi seperti itu, tetapi ada :ref:`fallback function <fallback-function>`
yang harus dibayar, fungsi fallback akan dipanggil pada transfer Ether biasa. Jika
tidak ada Fungsi Terima Ehter maupun fungsi fallback yang dapat dibayarkan, kontrak
tidak dapat menerima Ether melalui transaksi reguler dan mengeluarkan eksepsi.

Dalam kasus terburuk, fungsi ``receive`` hanya dapat mengandalkan 2300 gas yang
tersedia (misalnya ketika ``send`` atau ``transfer`` digunakan), menyisakan sedikit
ruang untuk melakukan operasi lain kecuali basic logging.
Operasi berikut akan mengkonsumsi lebih banyak gas daripada 2300 tunjangan gas:

- Menulis ke storage
- Membuat Kontrak
- Memanggil fungsi eksternal yang menghabiskan banyak gas
- Mengirim Ether

.. warning::
    Kontrak yang menerima Ether secara langsung (tanpa pemanggilan fungsi,
    yaitu menggunakan ``send`` atau ``transfer``) tetapi tidak mendefinisikan
    fungsi terima Ether atau fungsi payable fallback, melempar pengecualian,
    mengirim kembali Ether (ini berbeda sebelum Solidity v0.4.0).
    Jadi jika Anda ingin kontrak Anda menerima Ether, Anda harus mengimplementasikan
    fungsi terima Ether (menggunakan fungsi payable fallback untuk menerima Ether
    tidak disarankan, karena tidak akan gagal pada *interface confusions*).


.. warning::
    Sebuah kontrak tanpa fungsi menerima Ether dapat menerima Ether sebagai
    penerima *coinbase transaction* (alias *miner block reward*) atau sebagai
    tujuan ``selfdestruct``.

    Sebuah kontrak tidak dapat bereaksi terhadap transfer Ether tersebut dan
    dengan demikian juga tidak dapat menolaknya. Ini adalah pilihan desain
    EVM dan Solidity tidak dapat mengatasinya.

    Ini juga berarti bahwa ``address(this).balance`` bisa lebih tinggi daripada
    jumlah beberapa akuntansi manual yang diterapkan dalam kontrak (mis. memiliki
    penghitung yang diperbarui dalam fungsi penerima Ether).

Di bawah ini Anda dapat melihat contoh kontrak Sink yang menggunakan fungsi ``receive``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // This contract keeps all Ether sent to it with no way
    // to get it back.
    contract Sink {
        event Received(address, uint);
        receive() external payable {
            emit Received(msg.sender, msg.value);
        }
    }

.. index:: ! fallback function, function;fallback

.. _fallback-function:

Fungsi Fallback
---------------

Kontrak dapat memiliki paling banyak satu fungsi ``fallback``, yang dideklarasikan
menggunakan ``fallback () external [payable]`` atau ``fallback (byte calldata _input)
external [payable] return (bytes memory _output)`` ( keduanya tanpa kata kunci ``fungsi``).
Fungsi ini harus memiliki visibilitas ``eksternal``. Fungsi fallback dapat berupa virtual,
dapat ditimpa, dan dapat memiliki modifier.

Fungsi fallback dijalankan pada panggilan ke kontrak jika tidak ada fungsi lain yang cocok
dengan tanda tangan fungsi yang diberikan, atau jika tidak ada data yang diberikan sama sekali
dan tidak ada :ref:`Fungsi terima Ether <receive-ether-function>` .
Fungsi fallback selalu menerima data, tetapi untuk juga menerima Eter, fungsi tersebut harus
ditandai ``dapat dibayar``.

Jika versi dengan parameter digunakan, ``_input`` akan berisi data lengkap yang dikirim ke
kontrak (sama dengan ``msg.data``) dan dapat mengembalikan data dalam ``_output``. Data yang
dikembalikan tidak akan dikodekan ABI. Sebaliknya itu akan dikembalikan tanpa modifikasi
(bahkan padding sekalipun).

Dalam kasus terburuk, jika fungsi payable fallback juga digunakan sebagai pengganti fungsi
penerimaan, itu hanya dapat mengandalkan 2300 gas yang tersedia (lihat :ref:`receive Ether
function <receive-ether-function>` untuk deskripsi singkat dari implikasi ini).

Seperti fungsi lainnya, fungsi fallback dapat menjalankan operasi
kompleks selama ada cukup gas yang diteruskan ke sana.

.. warning::
    Fungsi fallback ``payable`` juga dijalankan untuk transfer Ether biasa, jika
    tidak ada fungsi :ref:`terima Ether <receive-ether-function>`. Direkomendasikan
    untuk selalu mendefinisikan fungsi Ether terima juga, jika Anda mendefinisikan
    fungsi payablefallback untuk membedakan transfer Ether dari kebingungan antarmuka.

.. note::
    Jika Anda ingin mendekode data input, Anda dapat memeriksa empat byte pertama untuk
    pemilih fungsi dan kemudian Anda dapat menggunakan ``abi.decode`` bersama dengan
    sintaks slice array untuk mendekode data yang dikodekan ABI:
    ``(c, d) = abi.decode(_input[4:], (uint256, uint256));`` Perhatikan bahwa ini hanya
    boleh digunakan sebagai pilihan terakhir dan fungsi yang tepat harus digunakan
    sebagai gantinya.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract Test {
        uint x;
        // This function is called for all messages sent to
        // this contract (there is no other function).
        // Sending Ether to this contract will cause an exception,
        // because the fallback function does not have the `payable`
        // modifier.
        fallback() external { x = 1; }
    }

    contract TestPayable {
        uint x;
        uint y;
        // This function is called for all messages sent to
        // this contract, except plain Ether transfers
        // (there is no other function except the receive function).
        // Any call with non-empty calldata to this contract will execute
        // the fallback function (even if Ether is sent along with the call).
        fallback() external payable { x = 1; y = msg.value; }

        // This function is called for plain Ether transfers, i.e.
        // for every call with empty calldata.
        receive() external payable { x = 2; y = msg.value; }
    }

    contract Caller {
        function callTest(Test test) public returns (bool) {
            (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // results in test.x becoming == 1.

            // address(test) will not allow to call ``send`` directly, since ``test`` has no payable
            // fallback function.
            // It has to be converted to the ``address payable`` type to even allow calling ``send`` on it.
            address payable testPayable = payable(address(test));

            // If someone sends Ether to that contract,
            // the transfer will fail, i.e. this returns false here.
            return testPayable.send(2 ether);
        }

        function callTestPayable(TestPayable test) public returns (bool) {
            (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // results in test.x becoming == 1 and test.y becoming 0.
            (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // results in test.x becoming == 1 and test.y becoming 1.

            // If someone sends Ether to that contract, the receive function in TestPayable will be called.
            // Since that function writes to storage, it takes more gas than is available with a
            // simple ``send`` or ``transfer``. Because of that, we have to use a low-level call.
            (success,) = address(test).call{value: 2 ether}("");
            require(success);
            // results in test.x becoming == 2 and test.y becoming 2 ether.

            return true;
        }
    }

.. index:: ! overload

.. _overload-function:

Fungsi Overloading
====================

Kontrak dapat memiliki beberapa fungsi dengan nama yang sama tetapi dengan tipe parameter yang berbeda.
Proses ini disebut "overloading" dan juga berlaku untuk fungsi *inherited*.
Contoh berikut menunjukkan overloading fungsi:
``f`` dalam lingkup kontrak ``A``.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract A {
        function f(uint _in) public pure returns (uint out) {
            out = _in;
        }

        function f(uint _in, bool _really) public pure returns (uint out) {
            if (_really)
                out = _in;
        }
    }

Fungsi Overloaded juga ada di antarmuka eksternal. adalah kesalahan jika dua
fungsi yang terlihat secara eksternal berbedaberdasarkan tipe Solidity-nya tetapi tidak berdasarkan tipe eksternalnya.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    // This will not compile
    contract A {
        function f(B _in) public pure returns (B out) {
            out = _in;
        }

        function f(address _in) public pure returns (address out) {
            out = _in;
        }
    }

    contract B {
    }


Kedua fungsi ``f`` overloads di atas akhirnya menerima jenis alamat untuk ABI meskipun keduanya
dianggap berbeda di dalam Solidity.

Resolusi Overload dan Pencocokan argumen
----------------------------------------

Fungsi Overloaded dipilih dengan mencocokkan deklarasi fungsi dalam cakupan saat ini dengan
argumen yang disediakan dalam pemanggilan fungsi. Fungsi dipilih sebagai kandidat Overload
jika semua argumen dapat secara implisit dikonversi ke tipe yang diharapkan. Jika tidak ada
tepat satu kandidat, resolusi gagal.

.. note::
    Parameter Return tidak diambil kedalam akun untuk resolusi overload.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract A {
        function f(uint8 _in) public pure returns (uint8 out) {
            out = _in;
        }

        function f(uint256 _in) public pure returns (uint256 out) {
            out = _in;
        }
    }

Memanggil ``f(50)`` akan membuat kesalahan tipe karena ``50`` dapat dikonversi secara implisit menjadi ``uint8``
dan tipe ``uint256``. Di sisi lain ``f(256)`` akan diselesaikan menjadi ``f(uint256)`` overload karena ``256`` tidak dapat secara implisit
dikonversi ke ``uint8``.
