.. index:: analyse, asm

############################
Menganalisis Output Kompiler
############################

Seringkali berguna untuk melihat kode assembly yang dihasilkan oleh kompiler. Biner yang dihasilkan,
yaitu, output dari ``solc --bin contract.sol``, umumnya sulit dibaca. Direkomendasikan untuk menggunakan
flag ``--asm`` untuk menganalisis output assembly. Bahkan untuk kontrak besar, melihat perbedaan visual
dari perakitan sebelum dan sesudah perubahan seringkali sangat mencerahkan.

Pertimbangkan kontrak berikut (bernama, katakan ``contract.sol``):

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    contract C {
        function one() public pure returns (uint) {
            return 1;
        }
    }

The following would be the output of ``solc --asm contract.sol``

.. code-block:: none

    ======= contract.sol:C =======
    EVM assembly:
        /* "contract.sol":0:86  contract C {... */
      mstore(0x40, 0x80)
      callvalue
      dup1
      iszero
      tag_1
      jumpi
      0x00
      dup1
      revert
    tag_1:
      pop
      dataSize(sub_0)
      dup1
      dataOffset(sub_0)
      0x00
      codecopy
      0x00
      return
    stop

    sub_0: assembly {
            /* "contract.sol":0:86  contract C {... */
          mstore(0x40, 0x80)
          callvalue
          dup1
          iszero
          tag_1
          jumpi
          0x00
          dup1
          revert
        tag_1:
          pop
          jumpi(tag_2, lt(calldatasize, 0x04))
          shr(0xe0, calldataload(0x00))
          dup1
          0x901717d1
          eq
          tag_3
          jumpi
        tag_2:
          0x00
          dup1
          revert
            /* "contract.sol":17:84  function one() public pure returns (uint) {... */
        tag_3:
          tag_4
          tag_5
          jump	// in
        tag_4:
          mload(0x40)
          tag_6
          swap2
          swap1
          tag_7
          jump	// in
        tag_6:
          mload(0x40)
          dup1
          swap2
          sub
          swap1
          return
        tag_5:
            /* "contract.sol":53:57  uint */
          0x00
            /* "contract.sol":76:77  1 */
          0x01
            /* "contract.sol":69:77  return 1 */
          swap1
          pop
            /* "contract.sol":17:84  function one() public pure returns (uint) {... */
          swap1
          jump	// out
            /* "#utility.yul":7:125   */
        tag_10:
            /* "#utility.yul":94:118   */
          tag_12
            /* "#utility.yul":112:117   */
          dup2
            /* "#utility.yul":94:118   */
          tag_13
          jump	// in
        tag_12:
            /* "#utility.yul":89:92   */
          dup3
            /* "#utility.yul":82:119   */
          mstore
            /* "#utility.yul":72:125   */
          pop
          pop
          jump	// out
            /* "#utility.yul":131:353   */
        tag_7:
          0x00
            /* "#utility.yul":262:264   */
          0x20
            /* "#utility.yul":251:260   */
          dup3
            /* "#utility.yul":247:265   */
          add
            /* "#utility.yul":239:265   */
          swap1
          pop
            /* "#utility.yul":275:346   */
          tag_15
            /* "#utility.yul":343:344   */
          0x00
            /* "#utility.yul":332:341   */
          dup4
            /* "#utility.yul":328:345   */
          add
            /* "#utility.yul":319:325   */
          dup5
            /* "#utility.yul":275:346   */
          tag_10
          jump	// in
        tag_15:
            /* "#utility.yul":229:353   */
          swap3
          swap2
          pop
          pop
          jump	// out
            /* "#utility.yul":359:436   */
        tag_13:
          0x00
            /* "#utility.yul":425:430   */
          dup2
            /* "#utility.yul":414:430   */
          swap1
          pop
            /* "#utility.yul":404:436   */
          swap2
          swap1
          pop
          jump	// out

        auxdata: 0xa2646970667358221220a5874f19737ddd4c5d77ace1619e5160c67b3d4bedac75fce908fed32d98899864736f6c637827302e382e342d646576656c6f702e323032312e332e33302b636f6d6d69742e65613065363933380058
    }

Atau, output di atas juga dapat diperoleh dari `Remix <https://remix.ethereum.org/>`_,
di bawah opsi "Rincian Kompilasi" setelah menyusun kontrak.

Perhatikan bahwa output ``asm`` dimulai dengan kode pembuatan / konstruktor. Kode penerapan
disediakan sebagai bagian dari sub-objek (dalam contoh di atas, ini adalah bagian dari sub-objek ``sub_0``).
Bidang ``auxdata`` sesuai dengan kontrak :ref:`metadata
<encoding-of-the-metadata-hash-in-the-bytecode>`. Komentar di output assembly menunjuk ke
lokasi sumber. Perhatikan bahwa ``#utility.yul`` adalah file fungsi utilitas
yang dihasilkan secara internal yang dapat diperoleh dengan menggunakan flag ``--combined-json
generated-sources,generated-sources-runtime``.

Demikian pula, assembly yang dioptimalkan dapat diperoleh dengan perintah: ``solc --optimize --asm
contract.sol``. Sering kali, menarik untuk melihat apakah dua sumber yang berbeda di Solidity menghasilkan kode
yang dioptimalkan yang sama. Misalnya, untuk melihat apakah ekspresi ``(a * b) / c``, ``a * b / c``
menghasilkan bytecode yang sama. Ini dapat dengan mudah dilakukan dengan mengambil ``diff`` dari output
assembly yang sesuai, setelah berpotensi menghapus komentar yang mereferensikan lokasi sumber.

.. note::

   Output ``--asm`` tidak dirancang agar dapat dibaca mesin. Oleh karena itu, mungkin ada perubahan
   yang mengganggu pada output antara versi minor dari solc.
