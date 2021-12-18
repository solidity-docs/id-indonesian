.. index:: ! value type, ! type;value
.. _value-types:

Value Types (Nilai Types)
=========================

Tipe berikut ini juga disebut tipe nilai karena variabel dari tipe ini akan
selalu diteruskan dengan nilai, yaitu selalu disalin ketika digunakan sebagai
argumen fungsi atau dalam penugasan.

.. index:: ! bool, ! true, ! false

Booleans
--------

``bool``: Nilai yang mungkin adalah konstantan ``true`` dan ``false``.

Operators:

*  ``!`` (logical negation)
*  ``&&`` (logical conjunction, "and")
*  ``||`` (logical disjunction, "or")
*  ``==`` (equality)
*  ``!=`` (inequality)

Operator ``||`` dan ``&&`` menerapkan aturan *short-circuiting* yang umum. Ini berarti bahwa dalam ekspresi ``f(x) || g(y)``, jika ``f(x)`` bernilai ``true``, ``g(y)`` tidak akan dievaluasi meskipun mungkin memiliki efek samping.

.. index:: ! uint, ! int, ! integer
.. _integers:

Integers
--------

``int`` / ``uint``: Signed dan unsigned integers dalam berbagai ukuran. Keywords ``uint8`` ke ``uint256`` dalam langkah ``8`` (unsigned dari 8 sampai 256 bits) dan ``int8`` ke ``int256``. ``uint`` serta ``int`` adalah alias untuk ``uint256`` dan ``int256``, berturut-turut.

Operators:

* Comparisons: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (evaluasi ke ``bool``)
* Bit operators: ``&``, ``|``, ``^`` (bitwise eksklusif atau), ``~`` (bitwise negation)
* Shift operators: ``<<`` (shift kiri), ``>>`` (shift kanan)
* Arithmetic operators: ``+``, ``-``, unary ``-`` (hanya untuk signed integers), ``*``, ``/``, ``%`` (modulo), ``**`` (exponentiation)

Untuk integer tipe ``X``, anda dapat menggunakan ``type(X).min`` dan ``type(X).max`` untuk
mengakses nilai minimum dan maksimum yang dapat diwakili oleh tipenya.

.. warning::

  Integers di Solidity terbatas pada kisaran tertentu. Sebagai contoh, dengan ``uint32``, ini adalah ``0`` hingga ``2**32 - 1``.
  Ada dua mode di mana aritmatika dilakukan pada tipe-tipe ini: Mode "wrapping" atau "unchecked" dan mode "checked".
  Secara default, aritmatika selalu "checked", yang berarti bahwa jika hasil operasi berada di luar rentang nilai
  dari jenisnya, panggilan dikembalikan melalui :ref:`pernyataan gagal<assert-and-require>`. Anda dapat beralih ke mode "unchecked"
  menggunakan ``unchecked { ... }``. Detail lebih lanjut dapat ditemukan di bagian :ref:`unchecked <unchecked>`.

Comparisons (Perbandingan)
^^^^^^^^^^^^^^^^^^^^^^^^^^

Nilai sebuah comparison adalah yang diperoleh dengan membandingkan nilai integer.

Bit operations
^^^^^^^^^^^^^^

Bit operations dilakukan pada representasi komplemen dua dari nomor tersebut.
Ini berarti, sebagai contoh ``~int256(0) == int256(-1)``.

Shifts
^^^^^^

Hasil dari operasi shift memiliki tipe operand kiri, memotong hasil agar sesuai dengan tipenya.
Operand kanan harus dari tipe yang tidak ditandatangani, mencoba untuk *shift* dengan tipe yang ditandatangani akan menghasilkan kesalahan kompilasi.

Shifts dapat di "simulasi" menggunakan perkalian dengan kekuatan dua dengan cara berikut. Perhatikan bahwa pemotongan
untuk jenis operand kiri selalu dilakukan di akhir, tetapi tidak disebutkan secara eksplisit.

- ``x << y`` setara dengan ekspresi matematika ``x * 2**y``.
- ``x >> y`` setara dengan ekspresi matematika ``x / 2**y``, dibulatkan ke arah negatif infinity.

.. warning::
    Sebelum versi ``0.5.0`` shift kanan ``x >> y`` untuk negatif ``x`` setara dengan
    ekspresi matematika ``x / 2**y`` dibulatkan menuju nol,
    yaitu, Shift kanan menggunakan pembulatan ke atas (menuju nol) daripada pembulatan ke bawah (menuju tak terhingga negatif).

.. note::
    Pemeriksaan overflow tidak pernah dilakukan untuk operasi shift seperti yang dilakukan untuk operasi aritmatika.
    Sebaliknya, hasilnya selalu terpotong.

Addition, Subtraction and Multiplication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Addition, subtraction and multiplication memiliki semantics yang biasa, dengan dua mode
berbeda dalam hal over- dan underflow:

Secara default, semua aritmatika diperiksa untuk under- atau overflow, tetapi ini dapat dinonaktifkan
menggunakan :ref:`unchecked block<unchecked>`, menghasilkan *wrapping arithmetic*. Keterangan lebih lanjut
dapat ditemukan di bagian tersebut.

Ekspresi ``-x`` setara dengan ``(T(0) - x)`` dimana
``T`` adalah type dari ``x``. Ini hanya dapat diterapkan pada signed types.
Nilai ``-x`` dapat berupa
positif jika ``x`` adalah negatif. Ada peringatan lain yang juga dihasilkan
dari representasi dua komplemen:

Jika anda mempunyai ``int x = type(int).min;``, maka ``-x`` tidak sesuai dengan rentang positif.
Ini berarti bahwa ``unchecked { assert(-x == x); }`` bekerja, dan ekspresi ``-x``
ketika digunakan dalam mode checked akan menghasilkan pernyataan yang gagal

Division
^^^^^^^^

Karena tipe hasil operasi selalu tipe salah satu operan,
division pada integer selalu menghasilkan integer.
Di Solidity, putaran division menuju nol. Ini berarti bahwa ``int256(-5) / int256(2) == int256(-2)``.

Perhatikan bahwa sebaliknya, division pada :ref:`literals<rational_literals>` menghasilkan nilai
pecahan presisi arbitrary.

.. note::
  Division by zero mengakibatkan sebuah :ref:`Panic error<assert-and-require>`. Pemeriksaan ini **tidak** dapat dinonaktifkan melalui ``unchecked { ... }``.

.. note::
  Expression ``type(int).min / (-1)`` adalah satu-satunya kasus di mana division menyebabkan overflow.
  Di mode checked arithmetic, ini akan menyebabkan pernyataan yang gagal, sementara di
  mode wrapping, nilainya akan ``type(int).min``.

Modulo
^^^^^^

Operasi modulo ``a % n`` menghasilkan sisa ``r`` setelah pembagian operand ``a``
oleh operand ``n``, dimana ``q = int(a / n)`` dan ``r = a - (n * q)``. Ini berarti bahwa modulo
menghasilkan tanda yang sama dengan operand kiri (atau nol) dan ``a % n == -(-a % n)`` berlaku untuk ``a`` negatif:

* ``int256(5) % int256(2) == int256(1)``
* ``int256(5) % int256(-2) == int256(1)``
* ``int256(-5) % int256(2) == int256(-1)``
* ``int256(-5) % int256(-2) == int256(-1)``

.. note::
  Modulo dengan nol menyebabkan :ref:`Panic error<assert-and-require>`. Pemeriksaan ini **tidak** dapat dinonaktifkan melalui ``unchecked { ... }``.

Exponentiation
^^^^^^^^^^^^^^

Exponentiation hanya tersedia untuk tipe yang tidak ditandatangani dalam eksponen.
Jenis exponentiation yang dihasilkan selalu sama dengan tipe dasarnya.
Harap berhati-hati bahwa itu cukup besar untuk menampung hasil dan bersiap untuk
kemungkinan kegagalan pernyataan atau *wrapping behaviour*.

.. note::
  Di mode checked, exponentiation hanya menggunakan opcode ``exp`` yang relatif murah untuk basis kecil.
  Untuk kasus ``x**3``, expression ``x*x*x`` mungkin lebih murah.
  Bagaimanapun, tes biaya gas dan penggunaan pengoptimal disarankan.

.. note::
  Perhatikan bahwa ``0**0`` didefinisikan oleh EVM sebagai ``1``.

.. index:: ! ufixed, ! fixed, ! fixed point number

Fixed Point Numbers
-------------------

.. warning::
    Fixed point numbers belum sepenuhnya didukung oleh Solidity. Mereka dapat dideklarasikan,
    tetapi tidak dapat ditugaskan ke atau dari.

``fixed`` / ``ufixed``: Signed dan unsigned fixed point number dari berbagai ukuran. Keywords ``ufixedMxN`` dan ``fixedMxN``, dimana ``M`` mewakili jumlah bit yang diambil oleh
type dan ``N`` mewakili berapa banyak titik desimal yang tersedia. ``M`` harus habis dibagi 8 dan berubah dari 8 hingga 256 bit. ``N`` harus antara 0 dan 80, inklusif.
``ufixed`` dan ``fixed`` adalah alias untuk ``ufixed128x18`` dan ``fixed128x18``, secara respectif.

Operators:

* Comparisons: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (evaluate to ``bool``)
* Arithmetic operators: ``+``, ``-``, unary ``-``, ``*``, ``/``, ``%`` (modulo)

.. note::
    Perbedaan utama antara floating point (``float`` dan ``double`` dibanyak bahasa, lebih tepatnya nomor IEEE 754) dan nomor fixed point adalah
    bahwa jumlah bit yang digunakan untuk integer dan bagian pecahan (bagian setelah titik desimal) fleksibel di bagian pertama, sementara itu
    didefinisikan secara ketat di bagian terakhir. Umumnya, di floating point hampir seluruh ruang digunakan untuk mewakili nomor, sementara hanya sejumlah kecil bit yang mendefinisikan
    dimana titik desimal berada.

.. index:: address, balance, send, call, delegatecall, staticcall, transfer

.. _address:

Address (alamat)
----------------

Tipe Address terdiri dari dua jenis, yang sebagian besar identik:

- ``address``: Memegang nilai 20 byte (ukuran alamat Ethereum).
- ``address payable``: Sama seperti ``address``, tetapi dengan anggota tambahan ``transfer`` dan ``send``.

Gagasan di balik perbedaan ini adalah bahwa ``address payable`` adalah alamat yang dapat Anda kirimi Ether,
sementara ``address`` biasa tidak dapat menerima Ether.

Tipe konversi:

Konversi implisit dari ``address payable`` ke ``address`` diperbolehkan, sedangkan konversi dari ``address`` ke ``address payable``
harus eksplisit melalui ``payable(<address>)``.

Konversi eksplisit ke dan dari ``address`` diperbolehkan untuk ``uint160``, literal integer,
``bytes20`` dan tipe kontrak.

Hanya tipe expressions ``address`` and contract-type yang dapat dikonversi ke tipe ``address
payable`` via konversi eksplisit ``payable(...)``. Untuk contract-type, konversi ini hanya
diperbolehkan jika kontrak dapat menerima Ether, yaitu kontrak yang memiliki :ref:`receive
<receive-ether-function>` atau fungsi fallback yang *payable*. Perhatikan bahwa ``payable(0)`` valid dan
pengecualian untuk aturan ini.

.. note::
    Jika Anda membutuhkan variabel bertipe ``address`` dan berencana mengirim Ether ke sana, maka
    mendeklarasikan jenisnya sebagai ``address payable`` untuk membuat persyaratan ini terlihat. Juga,
    cobalah untuk membuat perbedaan atau konversi ini sedini mungkin.

Operators:

* ``<=``, ``<``, ``==``, ``!=``, ``>=`` dan ``>``

.. warning::
    Jika Anda mengonversi tipe yang menggunakan ukuran byte yang lebih besar ke ``address``, misalnya ``bytes32``, maka ``address`` akan terpotong.
    Untuk mengurangi ambiguitas konversi versi 0.4.24 dan lebih tinggi dari kekuatan kompiler, Anda membuat pemotongan eksplisit dalam konversi.
    Ambil contoh nilai 32-byte ``0x111122223333444455556666777788889999AAAABBBBCCCCDDDDEEEEFFFFCCCC``.

    Anda dapat menggunakan ``address(uint160(bytes20(b)))``, yang akan menghasilkan ``0x111122223333444455556666777788889999aAaa``,
    atau anda dapat menggunakan ``address(uint160(uint256(b)))``, yang akan menghasilkan ``0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc``.

.. note::
    Perbedaan antara ``address`` dan ``address payable`` diperkenalkan di versi 0.5.0.
    Juga mulai dari versi itu, kontrak tidak diturunkan dari tipe alamat, tetapi masih dapat secara eksplisit dikonversi ke
    ``address`` atau ke ``address payable``, jika mereka memiliki fungsi fallback terima atau *payable*.

.. _members-of-addresses:

Members of Addresses (Anggota Alamat)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Untuk referensi cepat dari semua anggota address, lihat :ref:`address_related`.

* ``balance`` dan ``transfer``

Dimungkinkan untuk menanyakan saldo alamat menggunakan properti ``balance``
dan untuk mengirim Ether (dalam satuan wei) ke alamat yang harus dibayar menggunakan fungsi ``transfer``:

.. code-block:: solidity
    :force:

    address payable x = payable(0x123);
    address myAddress = address(this);
    if (x.balance < 10 && myAddress.balance >= 10) x.transfer(10);

Fungsi ``transfer`` gagal jika saldo kontrak saat ini tidak cukup besar
atau jika transfer Ether ditolak oleh akun penerima. Fungsi ``transfer`` reverts saat kegagalan.

.. note::
    Jika ``x`` adalah alamat kontrak, kodenya (lebih spesifik: :ref:`receive-ether-function`, jika ada, atau sebaliknya :ref:`fallback-function`, jika ada) akan dieksekusi bersama dengan panggilan ``transfer`` (ini adalah fitur dari EVM dan tidak dapat dicegah). Jika saat eksekusi kehabisan gas atau gagal dengan cara apa pun, transfer Ether akan dikembalikan dan kontrak saat ini akan berhenti dengan pengecualian.

* ``send``

Send adalah mitra tingkat rendah dari ``transfer``. Jika eksekusi gagal, kontrak saat ini tidak akan berhenti dengan pengecualian, tetapi ``send`` akan kembali ``false``.

.. warning::
    Ada beberapa bahaya dalam menggunakan ``send``: Transfer gagal jika kedalaman tumpukan panggilan berada pada 1024
    (ini selalu dapat dipaksakan oleh penelepon) dan juga gagal jika penerima kehabisan bensin. Jadi untuk melakukan
    transfer Ether yang aman, selalu periksa nilai pengembalian ``send``, gunakan ``transfer`` atau lebih baik lagi:
    gunakan pola di mana penerima menarik uangnya.

* ``call``, ``delegatecall`` dan``staticcall``

Untuk berinteraksi dengan kontrak yang tidak mematuhi ABI,
atau untuk mendapatkan kontrol lebih langsung ke encoding,
fungsi ``call``, ``delegatecall`` dan ``staticcall`` disediakan.
Mereka semua mengambil satu parameter ``bytes memory`` dan
mengembalikan kondisi sukses (sebagai ``bool``) dan data yang
dikembalikan (``byte memory``).
Fungsi ``abi.encode``, ``abi.encodePacked``, ``abi.encodeWithSelector``
dan ``abi.encodeWithSignature`` dapat digunakan untuk mengkodekan data terstruktur.

Contoh:

.. code-block:: solidity

    bytes memory payload = abi.encodeWithSignature("register(string)", "MyName");
    (bool success, bytes memory returnData) = address(nameReg).call(payload);
    require(success);

.. warning::
    Semua fungsi ini adalah fungsi low-level dan harus digunakan dengan hati-hati.
    Secara khusus, kontrak yang tidak dikenal mungkin berbahaya dan jika Anda memanggilnya,
    Anda menyerahkan kendali ke kontrak itu yang pada gilirannya dapat memanggil kembali ke
    dalam kontrak Anda, jadi bersiaplah untuk perubahan pada variabel state Anda saat panggilan kembali.
    Cara biasa untuk berinteraksi dengan kontrak lain adalah dengan memanggil fungsi pada objek kontrak (``x.f()``).

.. note::
    Versi Solidity sebelumnya mengizinkan fungsi-fungsi ini untuk menerima argumen arbitrer
    dan juga akan menangani argumen pertama bertipe ``bytes4`` secara berbeda. Kasus edge
    ini telah dihapus di versi 0.5.0.

Dimungkinkan untuk menyesuaikan gas yang disediakan dengan pengubah ``gas``:

.. code-block:: solidity

    address(nameReg).call{gas: 1000000}(abi.encodeWithSignature("register(string)", "MyName"));

Demikian pula, nilai Ether yang disediakan juga dapat dikontrol:

.. code-block:: solidity

    address(nameReg).call{value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));

Terakhir, modifier ini dapat digabungkan. Urutannya tidak masalah:

.. code-block:: solidity

    address(nameReg).call{gas: 1000000, value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));

Dengan cara yang sama, fungsi ``delegatecall`` dapat digunakan: perbedaannya adalah hanya kode alamat yang diberikan yang digunakan, semua aspek lain (storage, balance, ...) diambil dari kontrak saat ini. Tujuan dari ``delegatecall`` adalah untuk menggunakan kode library yang disimpan dalam kontrak lain. Pengguna harus memastikan bahwa tata letak penyimpanan di kedua kontrak cocok untuk panggilan delegasi yang akan digunakan.

.. note::
    Sebelum homestead, hanya varian terbatas yang disebut ``callcode`` yang tersedia yang tidak menyediakan akses ke nilai ``msg.sender`` dan ``msg.value`` asli. Fungsi ini telah dihapus di versi 0.5.0.

Sejak byzantium ``staticcall`` dapat digunakan juga. Ini pada dasarnya sama dengan ``call``, tetapi akan dikembalikan jika fungsi yang dipanggil mengubah state dengan cara apa pun.

Ketiga fungsi ``call``, ``delegatecall`` dan ``staticcall`` adalah fungsi tingkat sangat rendah dan hanya boleh digunakan sebagai *pilihan terakhir* karena merusak keamanan tipe Solidity.

Opsi ``gas`` tersedia pada ketiga metode, sedangkan opsi ``nilai`` hanya tersedia
pada ``call``.

.. note::
    Yang terbaik adalah menghindari mengandalkan nilai gas yang dikodekan dalam kode smart kontrak Anda,
    terlepas dari apakah state dibaca atau ditulis, karena ini dapat memiliki banyak jebakan.
    Juga, akses ke gas mungkin berubah di masa depan.

.. note::
    Semua kontrak dapat dikonversi ke tipe ``address``, sehingga memungkinkan untuk menanyakan saldo kontrak
    saat ini menggunakan ``address(this).balance``.

.. index:: ! contract type, ! type; contract

.. _contract_types:

Tipe Kontrak
--------------

Setiap :ref:`kontrak<contracts>` mendefinisikan tipenya sendiri.
Anda dapat secara implisit mengonversi kontrak menjadi kontrak yang mereka warisi.
Kontrak dapat secara eksplisit dikonversi ke dan dari tipe ``address``.

Konversi eksplisit ke dan dari tipe ``address payable`` hanya dimungkinkan jika tipe
kontrak memiliki fungsi fallback payable atau terima. Konversi masih dilakukan
menggunakan ``address(x)``. Jika jenis kontrak tidak memiliki fungsi fallback payable
atau terima, konversi ke ``address payable`` dapat dilakukan menggunakan ``payable(address(x))``.
Anda dapat menemukan informasi lebih lanjut di bagian tentang :ref:`address type<address>`.

.. note::
    Sebelum versi 0.5.0, kontrak langsung diturunkan dari tipe alamat
    dan tidak ada perbedaan antara ``address`` dan ``address payable``.

Jika Anda mendeklarasikan variabel lokal tipe kontrak (``MyContract c``),
Anda dapat memanggil fungsi pada kontrak tersebut. Berhati-hatilah untuk
menetapkannya dari suatu tempat dengan jenis kontrak yang sama.

Anda juga dapat membuat instance kontrak (yang berarti kontrak tersebut baru dibuat).
Anda dapat menemukan detail selengkapnya di bagian :ref:`'Contracts via new'<creating-contracts>`.

Representasi data sebuah kontrak identik dengan representasi ``address``
type dan jenis ini juga digunakan dalam :ref:`ABI<ABI>`.

Kontrak tidak mendukung operator mana pun.

Anggota dari jenis kontrak adalah fungsi eksternal kontrak
termasuk variabel state apa pun yang ditandai sebagai ``public``.

Untuk kontrak ``C`` Anda dapat menggunakan ``type(C)`` untuk mengakses
:ref:`type information<meta-type>` tentang kontrak.

.. index:: byte array, bytes32

Fixed-size byte arrays
----------------------

Jenis nilai ``bytes1``, ``bytes2``, ``bytes3``, ..., ``byte32``
menyimpan urutan byte dari satu hingga 32.

Operator:

* Comparisons: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (mengevaluasi ke ``bool``)
* Bit operators: ``&``, ``|``, ``^`` (bitwise exclusive atau), ``~`` (negasi bitwise)
* Shift operators: ``<<`` (shift kiri), ``>>`` (shift kanan)
* Index access: Jika ``x`` adalah tipe dari ``bytesI``, maka ``x[k]`` untuk ``0 <= k < I`` mengembalikan byte ke ``k`` (read-only).

Operator shifting bekerja dengan tipe integer unsigned sebagai as operand kanan
(tetapi menghasilkan jenis operand kiri), yang menunjukkan jumlah bit yang akan digeser.
Shifting menggunakan tipe signed akan menghasilkan *compilation error*.

Members:

* ``.length`` menghasilkan panjang tetap dari array byte (read-only).

.. note::
    Tipe ``bytes1[]`` adalah array byte, tapi karena aturan padding, itu membuang
    31 byte ruang untuk setiap elemen (kecuali dalam storage). Lebih baik menggunakan tipe
    ``byte`` sebagai gantinya.

.. note::
    Sebelum versi 0.8.0, ``byte`` digunakan sebagai alias untuk ``bytes1``.

Dynamically-sized byte array
----------------------------

``bytes``:
    Dynamically-sized byte array, lihat :ref:`arrays`. Bukan sebuah value-type!
``string``:
    Dynamically-sized UTF-8-encoded string, lihat :ref:`arrays`. Bukan sebuah value-type!

.. index:: address, literal;address

.. _address_literals:

Address Literal
---------------

Literal heksadesimal yang lulus tes alamat checksum, misalnya
``0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF`` bertipe ``address``.
Literal heksadesimal dengan panjang antara
39 dan 41 digit dan tidak lulus tes checksum menghasilkan
sebuah kesalahan. Anda dapat menambahkan (untuk tipe integer) atau menambahkan (untuk tipe byteNN) nol untuk memperbaiki kesalahan.

.. note::
    Format mixed-case address checksum didefinisikan dalam `EIP-55 <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md>`_.

.. index:: literal, literal;rational

.. _rational_literals:

Rational dan Integer Literal
----------------------------

Literal integer dibentuk dari urutan angka dalam rentang 0-9.
Mereka ditafsirkan sebagai desimal. Misalnya, ``69`` berarti enam puluh sembilan.
Literal oktal tidak ada dalam Solidity dan angka nol di depan tidak valid.

Literal pecahan desimal dibentuk oleh ``.`` dengan setidaknya satu angka di satu sisi.
Contohnya termasuk ``1.``, ``.1`` dan ``1.3``.

Notasi ilmiah juga didukung, di mana basis dapat memiliki pecahan dan eksponen tidak bisa.
Contohnya termasuk ``2e10``, ``-2e10``, ``2e-10``, ``2.5e1``.

Garis bawah dapat digunakan untuk memisahkan digit literal numerik agar mudah dibaca.
Misalnya, desimal ``123_000``, heksadesimal ``0x2eff_abde``, notasi desimal ilmiah ``1_2e345_678`` semuanya valid.
Garis bawah hanya diperbolehkan antara dua digit dan hanya satu garis bawah berurutan yang diperbolehkan.
Tidak ada makna semantik tambahan yang ditambahkan ke angka literal yang mengandung garis bawah,
garis bawah diabaikan.

mempertahankan presisi arbitrer hingga dikonversi ke tipe non-literal (yaitu dengan
menggunakannya bersama dengan ekspresi non-literal atau dengan konversi eksplisit).
Ini berarti bahwa komputasi tidak overflow dan pembagian tidak terpotong
dalam number literal expressions.

Sebagai contoh, ``(2**800 + 1) - 2**800`` menghasilkan konstanta ``1`` (dari tipe ``uint8``)
ameskipun hasilnya antara atau bahkan tidak sesuai dengan ukuran *machine word*. Selanjutnya, hasil ``.5 * 8``
dalam integer ``4`` (walaupun non-integer bulat digunakan di antaranya).

Operator apa pun yang dapat diterapkan ke integer juga dapat diterapkan ke number literal expressions
selama operand adalah integer. Jika salah satu dari keduanya adalah pecahan, operasi bit tidak diizinkan
dan eksponensial tidak diizinkan jika eksponennya pecahan (karena itu mungkin menghasilkan
bilangan non-rasional)

Shifts dan exponentiation dengan angka literal sebagai operand kiri (atau basis) dan tipe integer
sebagai operand kanan (eksponen) selalu dilakukan
dalam tipe ``uint256`` (untuk literal non-negatif) atau ``int256`` (untuk literal negatif),
terlepas dari jenis operand kanan (eksponen).

.. warning::
    Division pada literal integer yang digunakan untuk memotong di Solidity sebelum versi 0.4.0, tetapi sekarang diubah menjadi bilangan rasional, yaitu ``5 / 2`` tidak sama dengan ``2``, tetapi menjadi ``2,5`` .

.. note::
    Solidity memiliki tipe literal bilangan untuk setiap bilangan rasional.
    Literal integer dan literal bilangan rasional termasuk dalam tipe literal bilangan.
    Selain itu, semua ekspresi literal angka (yaitu ekspresi yang hanya berisi literal
    angka dan operator) termasuk dalam tipe literal angka. Jadi number literal expressions
    ``1 + 2`` dan ``2 + 1`` keduanya termasuk dalam tipe literal bilangan yang sama untuk
    bilangan rasional tiga.


.. note::
    Number literal expressions diubah menjadi tipe non-literal segera setelah digunakan dengan ekspresi
    non-literal. Mengabaikan jenis, nilai ekspresi yang ditetapkan ke ``b`` di bawah
    ini dievaluasi menjadi integer. Karena ``a`` bertipe ``uint128``, maka
    ekspresi ``2.5 + a`` harus memiliki tipe yang tepat. Karena tidak ada tipe yang umum
    untuk tipe ``2.5`` dan ``uint128``, compiler Solidity tidak menerima
    kode ini.

.. code-block:: solidity

    uint128 a = 1;
    uint128 b = 2.5 + a + 0.5;

.. index:: literal, literal;string, string
.. _string_literals:

String Literals dan Tipe
-------------------------

String literals ditulis dengan double atau single-quotes (``"foo"`` atau ``'bar'``), dan mereka juga dapat dipecah menjadi beberapa bagian berurutan (``"foo" "bar"`` setara dengan ``"foobar"``) yang dapat membantu saat menangani string panjang. Mereka tidak menyiratkan nol trailing seperti di C; ``"foo"`` mewakili tiga byte, bukan empat. Seperti literal integer, tipenya dapat bervariasi, tetapi secara implisit dapat dikonversi ke ``bytes1``, ..., ``bytes32``, jika cocok, ke ``byte`` dan ke ``string``.

Misalnya, dengan ``bytes32 samevar = "stringliteral"``, literal string diinterpretasikan dalam bentuk byte mentahnya saat ditetapkan ke tipe ``bytes32``.

Literal string hanya dapat berisi karakter ASCII yang dapat dicetak, yang berarti karakter antara dan termasuk 0x1F .. 0x7E.

Selain itu, literal string juga mendukung karakter escape berikut:

- ``\<newline>`` (escapes an actual newline)
- ``\\`` (backslash)
- ``\'`` (single quote)
- ``\"`` (double quote)
- ``\n`` (newline)
- ``\r`` (carriage return)
- ``\t`` (tab)
- ``\xNN`` (hex escape, see below)
- ``\uNNNN`` (unicode escape, see below)

``\xNN`` mengambil nilai hex dan menyisipkan byte yang sesuai, sementara ``\uNNNN`` mengambil titik kode Unicode dan menyisipkan urutan UTF-8.

.. note::

    Hingga versi 0.8.0 ada tiga urutan escape tambahan: ``\b``, ``\f`` dan ``\v``.
    Mereka umumnya tersedia dalam bahasa lain tetapi jarang dibutuhkan dalam praktiknya.
    Jika Anda memang membutuhkannya, mereka masih dapat dimasukkan melalui escape heksadesimal, yaitu ``\x08``, ``\x0c``
    dan ``\x0b``, masing-masing, sama seperti karakter ASCII lainnya.

String dalam contoh berikut memiliki panjang sepuluh byte.
Ini dimulai dengan newline byte, diikuti dengan tanda kutip ganda,
tanda kutip tunggal karakter garis miring terbalik dan kemudian (tanpa pemisah)
urutan karakter ``abcdef``.

.. code-block:: solidity
    :force:

    "\n\"\'\\abc\
    def"

Setiap terminator baris Unicode yang bukan merupakan baris baru (yaitu LF, VF, FF, CR, NEL, LS, PS) dianggap
mengakhiri string literal. Baris baru hanya mengakhiri literal string jika tidak didahului oleh ``\``.

Literal Unicode
---------------

Sementara literal string biasa hanya dapat berisi ASCII, literal Unicode – diawali dengan kata kunci ``unicode`` – dapat berisi urutan UTF-8 yang valid.
Mereka juga mendukung urutan escape yang sama seperti literal string biasa.

.. code-block:: solidity

    string memory a = unicode"Hello 😃";

.. index:: literal, bytes

Literal Hexadecimal
-------------------

Literal heksadesimal diawali dengan kata kunci ``hex`` dan diapit dua kali
atau tanda kutip tunggal (``hex"001122FF"``, ``hex'0011_22_FF'``). Konten mereka harus
digit heksadesimal yang secara opsional dapat menggunakan garis bawah tunggal sebagai pemisah antara
batas byte. Nilai literal akan menjadi representasi biner
dari barisan heksadesimal.

Beberapa literal heksadesimal yang dipisahkan oleh spasi digabung menjadi satu literal:
``hex"00112233" hex"44556677"`` setara dengan ``hex"0011223344556677"``

Literal heksadesimal berperilaku seperti :ref:`string literal <string_literals>` dan memiliki batasan konvertibilitas yang sama.

.. index:: enum

.. _enums:

Enums
-----

Enum adalah salah satu cara untuk membuat tipe *user-defined* di Solidity.
Mereka secara eksplisit dapat dikonversi ke dan dari semua tipe integer tetapi konversi implisit tidak diperbolehkan.
Konversi eksplisit dari integer memeriksa saat runtime bahwa nilainya berada di dalam rentang enum dan menyebabkan :ref:`Panic error<assert-and-require>` sebaliknya.
Enum membutuhkan setidaknya satu anggota, dan nilai defaultnya saat dideklarasikan adalah anggota pertama.
Enum tidak boleh memiliki lebih dari 256 anggota.

Representasi data sama dengan enum di C: Opsi diwakili oleh nilai integer tak bertanda berikutnya yang dimulai dari ``0``.

Menggunakan ``type(NameOfEnum).min`` dan ``type(NameOfEnum).max`` Anda bisa mendapatkan nilai
terkecil dan terbesar dari enum yang diberikan.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.8;

    contract test {
        enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
        ActionChoices choice;
        ActionChoices constant defaultChoice = ActionChoices.GoStraight;

        function setGoStraight() public {
            choice = ActionChoices.GoStraight;
        }

        // Since enum types are not part of the ABI, the signature of "getChoice"
        // will automatically be changed to "getChoice() returns (uint8)"
        // for all matters external to Solidity.
        function getChoice() public view returns (ActionChoices) {
            return choice;
        }

        function getDefaultChoice() public pure returns (uint) {
            return uint(defaultChoice);
        }

        function getLargestValue() public pure returns (ActionChoices) {
            return type(ActionChoices).max;
        }

        function getSmallestValue() public pure returns (ActionChoices) {
            return type(ActionChoices).min;
        }
    }

.. note::
    Enum juga dapat dideklarasikan pada level file, di luar definisi kontrak atau library.

.. index:: ! user defined value type, custom type

.. _user-defined-value-types:

Tipe Nilai *user defined* (Ditentukan oleh pengguna)
-----------------------------------------------------

Tipe nilai yang ditentukan pengguna memungkinkan pembuatan abstraksi tanpa biaya di atas tipe nilai elementary.
Ini mirip dengan alias, tetapi dengan persyaratan tipe yang lebih ketat.

Tipe nilai yang ditentukan pengguna didefinisikan menggunakan ``type C is V``,
di mana ``C`` adalah nama tipe yang baru diperkenalkan dan ``V`` harus berupa tipe nilai bawaan ("underlying type").
Fungsi ``C.wrap`` digunakan untuk mengonversi dari tipe underlying ke tipe kustom.
Demikian pula, fungsi ``C.unwrap`` digunakan untuk mengonversi dari tipe kustom ke tipe underlying.

Tipe ``C`` tidak memiliki operator atau fungsi anggota terikat.
Secara khusus, bahkan operator ``==`` tidak didefinisikan.
Konversi eksplisit dan implisit ke dan dari jenis lain tidak diizinkan.

Representasi data dari nilai tipe tersebut diwarisi dari tipe underlying
dan tipe underlying juga digunakan dalam ABI.

Contoh berikut mengilustrasikan tipe kustom ``UFixed256x18`` yang mewakili tipe *decimal fixed point* dengan 18 desimal
dan sebuah library minimal untuk melakukan operasi aritmatika pada tipe tersebut.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.8;

    // Represent a 18 decimal, 256 bit wide fixed point type using a user defined value type.
    type UFixed256x18 is uint256;

    /// A minimal library to do fixed point operations on UFixed256x18.
    library FixedMath {
        uint constant multiplier = 10**18;

        /// Adds two UFixed256x18 numbers. Reverts on overflow, relying on checked
        /// arithmetic on uint256.
        function add(UFixed256x18 a, UFixed256x18 b) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(UFixed256x18.unwrap(a) + UFixed256x18.unwrap(b));
        }
        /// Multiplies UFixed256x18 and uint256. Reverts on overflow, relying on checked
        /// arithmetic on uint256.
        function mul(UFixed256x18 a, uint256 b) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(UFixed256x18.unwrap(a) * b);
        }
        /// Take the floor of a UFixed256x18 number.
        /// @return the largest integer that does not exceed `a`.
        function floor(UFixed256x18 a) internal pure returns (uint256) {
            return UFixed256x18.unwrap(a) / multiplier;
        }
        /// Turns a uint256 into a UFixed256x18 of the same value.
        /// Reverts if the integer is too large.
        function toUFixed256x18(uint256 a) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(a * multiplier);
        }
    }

Perhatikan bagaimana ``UFixed256x18.wrap`` dan ``FixedMath.toUFixed256x18`` memiliki tanda tangan
yang sama tetapi melakukan dua operasi yang sangat berbeda: Fungsi ``UFixed256x18.wrap`` menghasilkan
``UFixed256x18`` yang memiliki representasi data yang sama sebagai input, sedangkan ``toUFixed256x18``
menghasilkan ``UFixed256x18`` yang memiliki nilai numerik yang sama.

.. index:: ! function type, ! type; function

.. _function_types:

Function Types (Tipe Fungsi)
----------------------------

Function types adalah tipe-tipe fungsi. Variabel Function types dapat
ditetapkan oleh fungsi dan parameter fungsi dari Function types dapat
digunakan untuk meneruskan *fungsi to dan fungsi return* dari fungsi calls.
Function types datang dalam dua jenis - fungsi *internal* dan *eksternal*:

Fungsi internal hanya dapat dipanggil di dalam kontrak saat ini (lebih khusus,
di dalam unit kode saat ini, yang juga mencakup fungsi library internal dan fungsi inherited)
karena mereka tidak dapat dieksekusi di luar konteks kontrak saat ini.
Memanggil fungsi internal diwujudkan dengan melompat ke label entrinya, sama seperti
saat memanggil fungsi kontrak saat ini secara internal.

Fungsi eksternal terdiri dari alamat dan fungsi tanda tangan serta dapat diteruskan
dan dikembalikan dari panggilan fungsi eksternal.

Function types dinotasikan sebagai berikut:

.. code-block:: solidity
    :force:

    function (<parameter types>) {internal|external} [pure|view|payable] [returns (<return types>)]

Berbeda dengan tipe parameter, tipe return tidak boleh kosong - jika function
type tidak boleh mengembalikan apa pun, seluruh bagian ``returns (<return types>)``
harus dihilangkan.

Secara default, function types bersifat internal, sehingga kata kunci ``internal``
dapat dihilangkan. Perhatikan bahwa ini hanya berlaku untuk function types.
Visibilitas harus ditentukan secara eksplisit untuk fungsi yang didefinisikan dalam kontrak,
mereka tidak memiliki default.

Konversi:

Function type ``A`` secara implisit dapat dikonversi menjadi function type ``B`` jika
dan hanya jika tipe parameternya identik, tipe return identik, properti internal/eksternalnya identik, dan
status mutabilitas `` A`` lebih restriktif daripada mutabilitas status ``B``. Secara khusus:

- fungsi  ``pure`` dapat dikonversi menjadi ``view`` dann fungsi ``non-payable``
- fungsi ``view`` dapat dikonversi menjadi fungsi ``non-payable``
- fungsi ``payable`` dapat dikonversi menjadi fungsi ``non-payable``

Tidak ada konversi lain antara function types yang mungkinkan.

Aturan tentang ``payable`` dan ``non-payable`` mungkin sedikit
membingungkan, tetapi pada intinya, jika suatu fungsi adalah ``payable``, ini berarti bahwa itu
juga dapat menerima pembayaran nol Ether, jadi ini juga ``non-payable``.
Di sisi lain, fungsi ``non-payable`` akan menolak Ether yang dikirim ke sana,
jadi fungsi ``non-payable`` tidak dapat dikonversi ke fungsi ``payable``.

Jika variabel sebuah function type tidak diinialisasi, memanggilnya akan mengasilkan
:ref:`Panic error<assert-and-require>`. Hal yang sama terjadi jika Anda memanggil fungsi setelah menggunakan ``delete``
di dalamnya.

Jika function types eksternal digunakan di luar konteks Solidity,
mereka diperlakukan sebagai tipe ``function``, yang mengkodekan alamat yang diikuti oleh
pengidentifikasi fungsi bersama-sama dalam satu tipe ``bytes24``.

Perhatikan bahwa fungsi publik dari kontrak saat ini dapat digunakan baik sebagai fungsi
internal maupun sebagai fungsi eksternal. Untuk menggunakan ``f`` sebagai fungsi internal,
cukup gunakan ``f``, jika Anda ingin menggunakan bentuk eksternal, gunakan ``this.f``.

Fungsi dari tipe internal dapat ditetapkan ke variabel function type internal terlepas dari mana itu didefinisikan.
Ini termasuk fungsi pribadi, internal dan publik dari kontrak dan  liblary serta fungsi bebas.
function types eksternal, di sisi lain, hanya kompatibel dengan fungsi kontrak publik dan eksternal.
Library dikecualikan karena memerlukan ``delegatecall`` dan menggunakan :ref:`konvensi ABI yang berbeda
untuk pemilihnya <library-selectors>`.
Fungsi yang dideklarasikan dalam antarmuka tidak memiliki definisi sehingga menunjuknya juga tidak masuk akal.

Members (Anggota):

Fungsi External (atau public) memiliki anggota sebagai berikut:

* ``.address`` menghasilkan alamat kontrak dari fungsi tersebut.
* ``.selector`` menghasilkan :ref:`Pemilih fungsi ABI <abi_function_selector>`

.. note::
  Fungsi External (atau public) yang digunakan untuk memiliki anggota tambahan
  ``.gas(uint)`` dan ``.value(uint)``. Ini tidak digunakan lagi di Solidity 0.6.2
  dan dihapus di Solidity 0.7.0. Sebagai gantinya gunakan ``{gas: ...}`` dan ``{value: ...}``
  untuk menentukan jumlah gas atau jumlah wei yang dikirim ke suatu fungsi,
  secara masing-masing. Lihat :ref:`External Function Calls <external-function-calls>` untuk
  informasi lebih lanjut.

Contoh yang menunjukkan cara menggunakan member:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.4 <0.9.0;

    contract Example {
        function f() public payable returns (bytes4) {
            assert(this.f.address == address(this));
            return this.f.selector;
        }

        function g() public {
            this.f{gas: 10, value: 800}();
        }
    }

Contoh yang menunjukkan cara menggunakan function types internal:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library ArrayUtils {
        // internal functions can be used in internal library functions because
        // they will be part of the same code context
        function map(uint[] memory self, function (uint) pure returns (uint) f)
            internal
            pure
            returns (uint[] memory r)
        {
            r = new uint[](self.length);
            for (uint i = 0; i < self.length; i++) {
                r[i] = f(self[i]);
            }
        }

        function reduce(
            uint[] memory self,
            function (uint, uint) pure returns (uint) f
        )
            internal
            pure
            returns (uint r)
        {
            r = self[0];
            for (uint i = 1; i < self.length; i++) {
                r = f(r, self[i]);
            }
        }

        function range(uint length) internal pure returns (uint[] memory r) {
            r = new uint[](length);
            for (uint i = 0; i < r.length; i++) {
                r[i] = i;
            }
        }
    }


    contract Pyramid {
        using ArrayUtils for *;

        function pyramid(uint l) public pure returns (uint) {
            return ArrayUtils.range(l).map(square).reduce(sum);
        }

        function square(uint x) internal pure returns (uint) {
            return x * x;
        }

        function sum(uint x, uint y) internal pure returns (uint) {
            return x + y;
        }
    }

Contoh lain yang menggunakan function types eksternal:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;


    contract Oracle {
        struct Request {
            bytes data;
            function(uint) external callback;
        }

        Request[] private requests;
        event NewRequest(uint);

        function query(bytes memory data, function(uint) external callback) public {
            requests.push(Request(data, callback));
            emit NewRequest(requests.length - 1);
        }

        function reply(uint requestID, uint response) public {
            // Here goes the check that the reply comes from a trusted source
            requests[requestID].callback(response);
        }
    }


    contract OracleUser {
        Oracle constant private ORACLE_CONST = Oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa)); // known contract
        uint private exchangeRate;

        function buySomething() public {
            ORACLE_CONST.query("USD", this.oracleResponse);
        }

        function oracleResponse(uint response) public {
            require(
                msg.sender == address(ORACLE_CONST),
                "Only oracle can call this."
            );
            exchangeRate = response;
        }
    }

.. note::
    Lambda atau fungsi inline direncanakan tetapi belum didukung.
