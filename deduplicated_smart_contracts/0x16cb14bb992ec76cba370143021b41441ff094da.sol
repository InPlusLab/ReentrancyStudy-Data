/**

 *Submitted for verification at Etherscan.io on 2019-02-26

*/



/**

 * Copyright (c) 2018-present, Leap DAO (leapdao.org)

 *

 * This source code is licensed under the Mozilla Public License, version 2,

 * found in the LICENSE file in the root directory of this source tree.

 */



pragma solidity 0.5.2;



/**

 * @title Math

 * @dev Assorted math operations

 */

library Math {

    /**

    * @dev Returns the largest of two numbers.

    */

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;

    }



    /**

    * @dev Returns the smallest of two numbers.

    */

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    /**

    * @dev Calculates the average of two numbers. Since these are integers,

    * averages of an even and odd number cannot be represented, and will be

    * rounded down.

    */

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b) / 2 can overflow, so we distribute

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);

    }

}





contract Bridge {



  event NewHeight(uint256 height, bytes32 indexed root);

  event NewOperator(address operator);



  struct Period {

    uint32 height;  // the height of last block in period

    uint32 timestamp;

  }



  bytes32 constant GENESIS = 0x4920616d207665727920616e6772792c20627574206974207761732066756e21;



  bytes32 public tipHash; // hash of first period that has extended chain to some height

  uint256 public genesisBlockNumber;

  uint256 parentBlockInterval; // how often epochs can be submitted max

  uint256 public lastParentBlock; // last ethereum block when epoch was submitted

  address public operator; // the operator contract



  mapping(bytes32 => Period) public periods;



  function getParentBlockInterval() public view returns (uint256) {

    return parentBlockInterval;

  }



  function setParentBlockInterval(uint256 _parentBlockInterval) public {

    parentBlockInterval = _parentBlockInterval;

  }



  function submitPeriod(

    bytes32 _prevHash, 

    bytes32 _root) 

  public returns (uint256 newHeight) {



  }

}



contract Initializable {



  /**

   * @dev Indicates that the contract has been initialized.

   */

  bool private initialized;



  /**

   * @dev Indicates that the contract is in the process of being initialized.

   */

  bool private initializing;



  /**

   * @dev Modifier to use in the initializer function of a contract.

   */

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");



    bool wasInitializing = initializing;

    initializing = true;

    initialized = true;



    _;



    initializing = wasInitializing;

  }



  /// @dev Returns true if and only if the function is running in the constructor

  function isConstructor() private view returns (bool) {

    // extcodesize checks the size of the code stored in an address, and

    // address returns the current address. Since the code is still not

    // deployed when running a constructor, any checks on its code size will

    // yield zero, making it an effective way to detect if a contract is

    // under construction or not.

    uint256 cs;

    assembly { cs := extcodesize(address) }

    return cs == 0;

  }



  // Reserved storage space to allow for layout changes in the future.

  uint256[50] private ______gap;

}



/**

 * @title Adminable

 *

 * @dev Helper contract to support initializer functions. To use it, replace

 * the constructor with a function that has the `initializer` modifier.

 * WARNING: Unlike constructors, initializer functions must be manually

 * invoked. This applies both to deploying an Initializable contract, as well

 * as extending an Initializable contract via inheritance.

 * WARNING: When used with inheritance, manual care must be taken to not invoke

 * a parent initializer twice, or ensure that all initializers are idempotent,

 * because this is not dealt with automatically as with constructors.

 */

contract Adminable is Initializable {



  /**

   * @dev Storage slot with the admin of the contract.

   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is

   * validated in the constructor.

   */

  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;



  /**

   * @dev Modifier to check whether the `msg.sender` is the admin.

   * If it is, it will run the function. Otherwise, fails.

   */

  modifier ifAdmin() {

    require(msg.sender == _admin());

    _;

  }



  function admin() external view returns (address) {

    return _admin();

  }



    /**

   * @return The admin slot.

   */

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;

    assembly {

      adm := sload(slot)

    }

  }

}





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface ERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}



/**

 * @title IERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */

interface ERC165 {

    /**

     * @notice Query if a contract implements an interface

     * @param interfaceId The interface identifier, as specified in ERC-165

     * @dev Interface identification is specified in ERC-165. This function

     * uses less than 30,000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



contract TransferrableToken is ERC165 {

  function transferFrom(address _from, address _to, uint256 _valueOrTokenId) public;

  function approve(address _to, uint256 _value) public;

}





library SafeMath {

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}





contract Vault is Adminable {



  event NewToken(address indexed tokenAddr, uint16 color);



  Bridge public bridge;



  uint16 public erc20TokenCount;

  uint16 public nftTokenCount;



  mapping(uint16 => PriorityQueue.Token) public tokens;

  mapping(address => bool) public tokenColors;



  function initialize(Bridge _bridge) public initializer {

    bridge = _bridge;

  } 



  function getTokenAddr(uint16 _color) public view returns (address) {

    return address(tokens[_color].addr);

  }



  function registerToken(address _token, bool _isERC721) public ifAdmin {

    // make sure token is not 0x0 and that it has not been registered yet

    require(_token != address(0), "Tried to register 0x0 address");

    require(!tokenColors[_token], "Token already registered");

    uint16 color;

    if (_isERC721) {

      require(TransferrableToken(_token).supportsInterface(0x80ac58cd) == true, "Not an ERC721 token");

      color = 32769 + nftTokenCount; // NFT color namespace starts from 2^15 + 1

      nftTokenCount += 1;

    } else {

      require(ERC20(_token).totalSupply() >= 0, "Not an ERC20 token");

      color = erc20TokenCount;

      erc20TokenCount += 1;

    }

    uint256[] memory arr = new uint256[](1);

    tokenColors[_token] = true;

    tokens[color] = PriorityQueue.Token({

      addr: TransferrableToken(_token),

      heapList: arr,

      currentSize: 0

    });

    emit NewToken(_token, color);

  }



  // solium-disable-next-line mixedcase

  uint256[50] private ______gap;



}



contract DepositHandler is Vault {



  event NewDeposit(

    uint32 indexed depositId, 

    address indexed depositor, 

    uint256 indexed color, 

    uint256 amount

  );

  event MinGasPrice(uint256 minGasPrice);



  struct Deposit {

    uint64 time;

    uint16 color;

    address owner;

    uint256 amount;

  }



  uint32 public depositCount;

  uint256 public minGasPrice;



  mapping(uint32 => Deposit) public deposits;



  function setMinGasPrice(uint256 _minGasPrice) public ifAdmin {

    minGasPrice = _minGasPrice;

    emit MinGasPrice(minGasPrice);

  }



   /**

   * @notice Add to the network `(_amountOrTokenId)` amount of a `(_color)` tokens

   * or `(_amountOrTokenId)` token id if `(_color)` is NFT.

   * @dev Token should be registered with the Bridge first.

   * @param _owner Account to transfer tokens from

   * @param _amountOrTokenId Amount (for ERC20) or token ID (for ERC721) to transfer

   * @param _color Color of the token to deposit

   */

  function deposit(address _owner, uint256 _amountOrTokenId, uint16 _color) public {

    TransferrableToken token = tokens[_color].addr;

    require(address(token) != address(0), "Token color not registered");

    require(_amountOrTokenId > 0 || _color > 32769, "no 0 deposits for fungible tokens");

    token.transferFrom(_owner, address(this), _amountOrTokenId);



    bytes32 tipHash = bridge.tipHash();

    uint256 timestamp;

    (, timestamp) = bridge.periods(tipHash);



    depositCount++;

    deposits[depositCount] = Deposit({

      time: uint32(timestamp),

      owner: _owner,

      color: _color,

      amount: _amountOrTokenId

    });

    emit NewDeposit(

      depositCount, 

      _owner, 

      _color, 

      _amountOrTokenId

    );

  }



  // solium-disable-next-line mixedcase

  uint256[50] private ______gap;

}





library TxLib {



  uint constant internal WORD_SIZE = 32;

  uint constant internal ONES = ~uint(0);

  enum TxType { Deposit, Transfer }



  struct Outpoint {

    bytes32 hash;

    uint8 pos;

  }



  struct Input {

    Outpoint outpoint;

    bytes32 r;

    bytes32 s;

    uint8 v;

  }



  struct Output {

    uint256 value;

    uint16 color;

    address owner;

    uint32 gasPrice;

    bytes msgData;

    bytes32 stateRoot;

  }



  struct Tx {

    TxType txType;

    Input[] ins;

    Output[] outs;

  }



  function parseInput(

    TxType _type, bytes memory _txData, uint256 _pos, uint256 offset, Input[] memory _ins

  ) internal pure returns (uint256 newOffset) {

    bytes32 inputData;

    uint8 index;

    if (_type == TxType.Deposit) {

      assembly {

        // load the depositId (4 bytes) starting from byte 2 of tx

        inputData := mload(add(add(offset, 4), _txData))

      }

      inputData = bytes32(uint256(uint32(uint256(inputData))));

      index = 0;

      newOffset = offset + 4;

    } else {

      assembly {

        // load the prevHash (32 bytes) from input

        inputData := mload(add(add(offset, 32), _txData))

        // load the output index (1 byte) from input

        index := mload(add(add(offset, 33), _txData))

      }

      newOffset = offset + 33;

    }

    Outpoint memory outpoint = Outpoint(inputData, index);

    Input memory input = Input(outpoint, 0, 0, 0); // solium-disable-line arg-overflow

    if (_type == TxType.Transfer) {

      bytes32 r;

      bytes32 s;

      uint8 v;

      assembly {

        r := mload(add(add(offset, 65), _txData))

        s := mload(add(add(offset, 97), _txData))

        v := mload(add(add(offset, 98), _txData))

      }

      input.r = r;

      input.s = s;

      input.v = v;

      newOffset = offset + 33 + 65;

    }

    _ins[_pos] = input;

  }



  // Copies 'len' bytes from 'srcPtr' to 'destPtr'.

  // NOTE: This function does not check if memory is allocated, it only copies the bytes.

  function memcopy(uint srcPtr, uint destPtr, uint len) internal pure {

    uint offset = 0;

    uint size = len / WORD_SIZE;

    // Copy word-length chunks while possible.

    for (uint i = 0; i < size; i++) {

      offset = i * WORD_SIZE;

      assembly {

        mstore(add(destPtr, offset), mload(add(srcPtr, offset)))

      }

    }

    offset = size*WORD_SIZE;

    uint mask = ONES << 8*(32 - len % WORD_SIZE);

    assembly {

      let nSrc := add(srcPtr, offset)

      let nDest := add(destPtr, offset)

      mstore(nDest, or(and(mload(nSrc), mask), and(mload(nDest), not(mask))))

    }

  }



  function parseOutput(

    bytes memory _txData, uint256 _pos, uint256 offset, Output[] memory _outs

  ) internal pure returns (uint256 newOffset) {

    uint256 value;

    uint16 color;

    address owner;

    assembly {

      value := mload(add(add(offset, 32), _txData))

      color := mload(add(add(offset, 34), _txData))

      owner := mload(add(add(offset, 54), _txData))

    }

    bytes memory data = new bytes(0);

    Output memory output = Output(value, color, owner, 0, data, 0);  // solium-disable-line arg-overflow

    _outs[_pos] = output;

    newOffset = offset + 54;

  }



  function parseTx(bytes memory _txData) internal pure returns (Tx memory txn) {

    // read type

    TxType txType;

    uint256 a;

    assembly {

      a := mload(add(0x20, _txData))

    }

    a = a >> 248; // get first byte

    if (a == 2) {

      txType = TxType.Deposit;

    } else if (a == 3) {

      txType = TxType.Transfer;

    } else {

      revert("unknown tx type");

    }

    // read ins and outs

    assembly {

        a := mload(add(0x21, _txData))

    }

    a = a >> 252; // get ins-length nibble

    Input[] memory ins = new Input[](a);

    uint256 offset = 2;

    for (uint i = 0; i < ins.length; i++) {

      offset = parseInput(txType, _txData, i, offset, ins); // solium-disable-line arg-overflow

    }

    assembly {

        a := mload(add(0x21, _txData))

    }

    a = (a >> 248) & 0x0f; // get outs-length nibble

    Output[] memory outs = new Output[](a);

    for (uint256 i = 0; i < outs.length; i++) {

      offset = parseOutput(_txData, i, offset, outs); // solium-disable-line arg-overflow

    }

    txn = Tx(txType, ins, outs);

  }



  function getSigHash(bytes memory _txData) internal pure returns (bytes32 sigHash) {

    uint256 a;

    assembly {

      a := mload(add(0x20, _txData))

    }

    a = a >> 248;

    // if not transfer, sighash is just tx hash

    require(a == 3);

    // read ins

    assembly {

        a := mload(add(0x21, _txData))

    }

    a = a >> 252; // get ins-length nibble

    bytes memory sigData = new bytes(_txData.length);

    assembly {

      // copy type

      mstore8(add(sigData, 32), byte(0, mload(add(_txData, 32))))

      // copy #inputs / #outputs

      mstore8(add(sigData, 33), byte(1, mload(add(_txData, 32))))

      let offset := 0

      for

        { let i := 0 }

        lt(i, a)

        { i := add(i, 1) }

        {

          mstore(add(sigData, add(34, offset)), mload(add(_txData, add(34, offset))))

          mstore8(add(sigData, add(66, offset)), byte(0, mload(add(_txData, add(66, offset)))))

          offset := add(offset, add(33, 65))

        }

      for

        { let i := add(34, offset) }

        lt(i, add(64, mload(_txData)))

        { i := add(i, 0x20) }

        {

          mstore(add(sigData, i), mload(add(_txData, i)))

        }

    }



    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", uint2str(_txData.length), sigData));

  }



  // solium-disable-next-line security/no-assign-params

  function getMerkleRoot(

    bytes32 _leaf, uint256 _index, uint256 _offset, bytes32[] memory _proof

  ) internal pure returns (bytes32) {

    bytes32 temp;

    for (uint256 i = _offset; i < _proof.length; i++) {

      temp = _proof[i];

      if (_index % 2 == 0) {

        assembly {

          mstore(0, _leaf)

          mstore(0x20, temp)

          _leaf := keccak256(0, 0x40)

        }

      } else {

        assembly {

          mstore(0, temp)

          mstore(0x20, _leaf)

          _leaf := keccak256(0, 0x40)

        }

      }

      _index = _index / 2;

    }

    return _leaf;

  }



  //validate that transaction is included to the period (merkle proof)

  function validateProof(

    uint256 _cdOffset, bytes32[] memory _proof

  ) internal pure returns (uint64 txPos, bytes32 txHash, bytes memory txData) {

    uint256 offset = uint8(uint256(_proof[1] >> 248));

    uint256 txLength = uint16(uint256(_proof[1] >> 224));



    txData = new bytes(txLength);

    assembly {

      calldatacopy(add(txData, 0x20), add(68, add(offset, _cdOffset)), txLength)

    }

    txHash = keccak256(txData);

    txPos = uint64(uint256(_proof[1] >> 160));

    bytes32 root = getMerkleRoot(

      txHash, 

      txPos, 

      uint8(uint256(_proof[1] >> 240)),

      _proof

    ); 

    require(root == _proof[0]);

  }



  function recoverTxSigner(uint256 offset, bytes32[] memory _proof) internal pure returns (address dest) {

    uint16 txLength = uint16(uint256(_proof[1] >> 224));

    bytes memory txData = new bytes(txLength);

    bytes32 r;

    bytes32 s;

    uint8 v;

    assembly {

      calldatacopy(add(txData, 32), add(114, offset), 43)

      r := calldataload(add(157, offset))

      s := calldataload(add(189, offset))

      v := calldataload(add(190, offset))

      calldatacopy(add(txData, 140), add(222, offset), 28) // 32 + 43 + 65

    }

    dest = ecrecover(getSigHash(txData), v, r, s); // solium-disable-line arg-overflow

  }



  // https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol#L886

  // solium-disable-next-line security/no-assign-params

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

    if (_i == 0) {

      return "0";

    }

    uint j = _i;

    uint len;

    while (j != 0) {

      len++;

      j /= 10;

    }

    bytes memory bstr = new bytes(len);

    uint k = len - 1;

    while (_i != 0) {

      bstr[k--] = byte(uint8(48 + _i % 10));

      _i /= 10;

    }

    return string(bstr);

  }



}



contract ExitHandler is DepositHandler {



  using PriorityQueue for PriorityQueue.Token;



  event ExitStarted(

    bytes32 indexed txHash, 

    uint8 indexed outIndex, 

    uint256 indexed color, 

    address exitor, 

    uint256 amount

  );



  struct Exit {

    uint256 amount;

    uint16 color;

    address owner;

    bool finalized;

    uint32 priorityTimestamp;

    uint256 stake;

  }



  uint256 public exitDuration;

  uint256 public exitStake;

  uint256 public nftExitCounter;



  /**

   * UTXO ¡ú Exit mapping. Contains exits for both NFT and ERC20 colors

   */

  mapping(bytes32 => Exit) public exits;



  function initializeWithExit(

    Bridge _bridge, 

    uint256 _exitDuration, 

    uint256 _exitStake) public initializer {

    initialize(_bridge);

    exitDuration = _exitDuration;

    exitStake = _exitStake;

    emit MinGasPrice(0);

  }



  function setExitStake(uint256 _exitStake) public ifAdmin {

    exitStake = _exitStake;

  }



  function setExitDuration(uint256 _exitDuration) public ifAdmin {

    exitDuration = _exitDuration;

  }



  function startExit(

    bytes32[] memory _youngestInputProof, bytes32[] memory _proof,

    uint8 _outputIndex, uint8 _inputIndex

  ) public payable {

    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");

    uint32 timestamp;

    (, timestamp) = bridge.periods(_proof[0]);

    require(timestamp > 0, "The referenced period was not submitted to bridge");



    if (_youngestInputProof.length > 0) {

      (, timestamp) = bridge.periods(_youngestInputProof[0]);

      require(timestamp > 0, "The referenced period was not submitted to bridge");

    }



    // check exiting tx inclusion in the root chain block

    bytes32 txHash;

    bytes memory txData;

    uint64 txPos;

    (txPos, txHash, txData) = TxLib.validateProof(32 * (_youngestInputProof.length + 2) + 64, _proof);



    // parse exiting tx and check if it is exitable

    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);

    TxLib.Output memory out = exitingTx.outs[_outputIndex];



    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash)));

    require(out.owner == msg.sender, "Only UTXO owner can start exit");

    require(out.value > 0, "UTXO has no value");

    require(exits[utxoId].amount == 0, "The exit for UTXO has already been started");

    require(!exits[utxoId].finalized, "The exit for UTXO has already been finalized");



    uint256 priority;

    if (_youngestInputProof.length > 0) {

      // check youngest input tx inclusion in the root chain block

      bytes32 inputTxHash;

      (txPos, inputTxHash,) = TxLib.validateProof(96, _youngestInputProof);

      require(

        inputTxHash == exitingTx.ins[_inputIndex].outpoint.hash, 

        "Input from the proof is not referenced in exiting tx"

      );

      

      if (isNft(out.color)) {

        priority = (nftExitCounter << 128) | uint128(uint256(utxoId));

        nftExitCounter++;

      } else {      

        priority = getERC20ExitPriority(timestamp, utxoId, txPos);

      }

    } else {

      require(exitingTx.txType == TxLib.TxType.Deposit, "Expected deposit tx");

      if (isNft(out.color)) {

        priority = (nftExitCounter << 128) | uint128(uint256(utxoId));

        nftExitCounter++;

      } else {      

        priority = getERC20ExitPriority(timestamp, utxoId, txPos);

      }

    }



    tokens[out.color].insert(priority);



    exits[utxoId] = Exit({

      owner: out.owner,

      color: out.color,

      amount: out.value,

      finalized: false,

      stake: exitStake,

      priorityTimestamp: timestamp

    });

    emit ExitStarted(

      txHash, 

      _outputIndex, 

      out.color, 

      out.owner, 

      out.value

    );

  }



  function startDepositExit(uint256 _depositId) public payable {

    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");

    // check that deposit exits

    Deposit memory deposit = deposits[uint32(_depositId)];

    require(deposit.owner == msg.sender, "Only deposit owner can start exit");

    require(deposit.amount > 0, "deposit has no value");

    require(exits[bytes32(_depositId)].amount == 0, "The exit of deposit has already been started");

    require(!exits[bytes32(_depositId)].finalized, "The exit for deposit has already been finalized");

    

    uint256 priority;

    if (isNft(deposit.color)) {

      priority = (nftExitCounter << 128) | uint128(_depositId);

      nftExitCounter++;

    } else {      

      priority = getERC20ExitPriority(uint32(deposit.time), bytes32(_depositId), 0);

    }



    tokens[deposit.color].insert(priority);



    exits[bytes32(_depositId)] = Exit({

      owner: deposit.owner,

      color: deposit.color,

      amount: deposit.amount,

      finalized: false,

      stake: exitStake,

      priorityTimestamp: uint32(now)

    });

    emit ExitStarted(

      bytes32(_depositId), 

      0, 

      deposit.color, 

      deposit.owner, 

      deposit.amount

    );

  }



  // @dev Finalizes exit for the chosen color with the highest priority

  function finalizeTopExit(uint16 _color) public {

    bytes32 utxoId;

    uint256 exitableAt;

    (utxoId, exitableAt) = getNextExit(_color);



    require(exitableAt <= block.timestamp, "The top exit can not be exited yet");

    require(tokens[_color].currentSize > 0, "The exit queue for color is empty");



    Exit memory currentExit = exits[utxoId];



    if (currentExit.owner != address(0) || currentExit.amount != 0) { // exit was removed

      // Note: for NFTs, the amount is actually the NFT id (both uint256)

      if (isNft(currentExit.color)) {

        tokens[currentExit.color].addr.transferFrom(address(this), currentExit.owner, currentExit.amount);

      } else {

        tokens[currentExit.color].addr.approve(address(this), currentExit.amount);

        tokens[currentExit.color].addr.transferFrom(address(this), currentExit.owner, currentExit.amount);

      }

      // Pay exit stake

      address(uint160(currentExit.owner)).transfer(currentExit.stake);

    }



    tokens[currentExit.color].delMin();

    exits[utxoId].finalized = true;

  }



  function challengeExit(

    bytes32[] memory _proof, 

    bytes32[] memory _prevProof, 

    uint8 _outputIndex,

    uint8 _inputIndex

  ) public {

    // validate exiting tx

    uint256 offset = 32 * (_proof.length + 2);

    bytes32 txHash1;

    bytes memory txData;

    (, txHash1, txData) = TxLib.validateProof(offset + 64, _prevProof);

    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash1)));

    

    TxLib.Tx memory txn;

    if (_proof.length > 0) {

      // validate spending tx

      bytes32 txHash;

      (, txHash, txData) = TxLib.validateProof(96, _proof);

      txn = TxLib.parseTx(txData);



      // make sure one is spending the other one

      require(txHash1 == txn.ins[_inputIndex].outpoint.hash);

      require(_outputIndex == txn.ins[_inputIndex].outpoint.pos);



      // if transfer, make sure signature correct

      if (txn.txType == TxLib.TxType.Transfer) {

        bytes32 sigHash = TxLib.getSigHash(txData);

        address signer = ecrecover(

          sigHash, 

          txn.ins[_inputIndex].v, 

          txn.ins[_inputIndex].r, 

          txn.ins[_inputIndex].s

        );

        require(exits[utxoId].owner == signer);

      } else {

        revert("unknown tx type");

      }

    } else {

      // challenging deposit exit

      txn = TxLib.parseTx(txData);

      utxoId = txn.ins[_inputIndex].outpoint.hash;

      if (txn.txType == TxLib.TxType.Deposit) {

        // check that deposit was included correctly

        // only then it should be usable for challenge

        Deposit memory deposit = deposits[uint32(uint256(utxoId))];

        require(deposit.amount == txn.outs[0].value, "value mismatch");

        require(deposit.owner == txn.outs[0].owner, "owner mismatch");

        require(deposit.color == txn.outs[0].color, "color mismatch");

        // todo: check timely inclusion of deposit tx

        // this will prevent grieving attacks by the operator

      } else {

        revert("unexpected tx type");

      }

    }



    require(exits[utxoId].amount > 0, "exit not found");

    require(!exits[utxoId].finalized, "The exit has already been finalized");



    // award stake to challanger

    msg.sender.transfer(exits[utxoId].stake);

    // delete invalid exit

    delete exits[utxoId];

  }



  function challengeYoungestInput(

    bytes32[] memory _youngerInputProof,

    bytes32[] memory _exitingTxProof, 

    uint8 _outputIndex, 

    uint8 _inputIndex

  ) public {

    // validate exiting input tx

    bytes32 txHash;

    bytes memory txData;

    (, txHash, txData) = TxLib.validateProof(32 * (_youngerInputProof.length + 2) + 64, _exitingTxProof);

    bytes32 utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(txHash)));



    // check the exit exists

    require(exits[utxoId].amount > 0, "There is no exit for this UTXO");



    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);



    // validate younger input tx

    (,txHash,) = TxLib.validateProof(96, _youngerInputProof);

    

    // check younger input is actually an input of exiting tx

    require(txHash == exitingTx.ins[_inputIndex].outpoint.hash, "Given output is not referenced in exiting tx");

    

    uint32 youngerInputTimestamp;

    (,youngerInputTimestamp) = bridge.periods(_youngerInputProof[0]);

    require(youngerInputTimestamp > 0, "The referenced period was not submitted to bridge");



    require(exits[utxoId].priorityTimestamp < youngerInputTimestamp, "Challenged input should be older");



    // award stake to challanger

    msg.sender.transfer(exits[utxoId].stake);

    // delete invalid exit

    delete exits[utxoId];

  }



  function getNextExit(uint16 _color) internal view returns (bytes32 utxoId, uint256 exitableAt) {

    uint256 priority = tokens[_color].getMin();

    utxoId = bytes32(uint256(uint128(priority)));

    exitableAt = priority >> 192;

  }



  function isNft(uint16 _color) internal pure returns (bool) {

    return _color > 32768; // 2^15

  }



  function getERC20ExitPriority(

    uint32 timestamp, bytes32 utxoId, uint64 txPos

  ) internal view returns (uint256 priority) {

    uint256 exitableAt = Math.max(timestamp + (2 * exitDuration), block.timestamp + exitDuration);

    return (exitableAt << 192) | uint256(txPos) << 128 | uint128(uint256(utxoId));

  }



  // solium-disable-next-line mixedcase

  uint256[50] private ______gap;

}



contract FastExitHandler is ExitHandler {



  struct Data {

    uint32 timestamp;

    bytes32 txHash;

    uint64 txPos;

    bytes32 utxoId;

  }



  function startBoughtExit(

    bytes32[] memory _youngestInputProof, bytes32[] memory _proof,

    uint8 _outputIndex, uint8 _inputIndex, bytes32[] memory signedData

  ) public payable {

    require(msg.value >= exitStake, "Not enough ether sent to pay for exit stake");

    Data memory data;



    (,data.timestamp) = bridge.periods(_proof[0]);

    require(data.timestamp > 0, "The referenced period was not submitted to bridge");



    (, data.timestamp) = bridge.periods(_youngestInputProof[0]);

    require(data.timestamp > 0, "The referenced period was not submitted to bridge");



    // check exiting tx inclusion in the root chain block

    bytes memory txData;

    (data.txPos, data.txHash, txData) = TxLib.validateProof(32 * (_youngestInputProof.length + 2) + 96, _proof);



    // parse exiting tx and check if it is exitable

    TxLib.Tx memory exitingTx = TxLib.parseTx(txData);

    TxLib.Output memory out = exitingTx.outs[_outputIndex];

    data.utxoId = bytes32(uint256(_outputIndex) << 120 | uint120(uint256(data.txHash)));



    (uint256 buyPrice, bytes32 utxoIdSigned, address signer) = unpackSignedData(signedData);



    require(!isNft(out.color), "Can not fast exit NFTs");

    require(out.owner == address(this), "Funds were not sent to this contract");

    require(

      ecrecover(

        TxLib.getSigHash(txData), 

        exitingTx.ins[0].v, exitingTx.ins[0].r, exitingTx.ins[0].s

      ) == signer,

      "Signer was not the previous owner of UTXO"

    );

    require(

      data.utxoId == utxoIdSigned, 

      "The signed utxoid does not match the one in the proof"

    );



    require(out.value > 0, "UTXO has no value");

    require(exits[data.utxoId].amount == 0, "The exit for UTXO has already been started");

    require(!exits[data.utxoId].finalized, "The exit for UTXO has already been finalized");

    require(exitingTx.txType == TxLib.TxType.Transfer, "Can only fast exit transfer tx");



    uint256 priority;

    // check youngest input tx inclusion in the root chain block

    bytes32 inputTxHash;

    (data.txPos, inputTxHash,) = TxLib.validateProof(128, _youngestInputProof);

    require(

      inputTxHash == exitingTx.ins[_inputIndex].outpoint.hash, 

      "Input from the proof is not referenced in exiting tx"

    );

    

    if (isNft(out.color)) {

      priority = (nftExitCounter << 128) | uint128(uint256(data.utxoId));

      nftExitCounter++;

    } else {      

      priority = getERC20ExitPriority(data.timestamp, data.utxoId, data.txPos);

    }



    tokens[out.color].addr.transferFrom(msg.sender, signer, buyPrice);



    tokens[out.color].insert(priority);



    exits[data.utxoId] = Exit({

      owner: msg.sender,

      color: out.color,

      amount: out.value,

      finalized: false,

      stake: exitStake,

      priorityTimestamp: data.timestamp

    });

    emit ExitStarted(

      data.txHash, 

      _outputIndex, 

      out.color, 

      out.owner, 

      out.value

    );

  }



  function unpackSignedData(

    bytes32[] memory signedData

  ) internal pure returns (

    uint256 buyPrice, bytes32 utxoId, address signer

  ) {

    utxoId = signedData[0];

    buyPrice = uint256(signedData[1]);

    bytes32 r = signedData[2];

    bytes32 s = signedData[3];

    uint8 v = uint8(uint256(signedData[4]));

    // solium-disable-next-line

    bytes32 sigHash = keccak256(abi.encodePacked(

      "\x19Ethereum Signed Message:\n", 

      uint2str(64),

      utxoId, 

      buyPrice

    ));

    signer = ecrecover(sigHash, v, r, s); // solium-disable-line arg-overflow

  }



  // https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol#L886

  // solium-disable-next-line security/no-assign-params

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

    if (_i == 0) {

      return "0";

    }

    uint j = _i;

    uint len;

    while (j != 0) {

      len++;

      j /= 10;

    }

    bytes memory bstr = new bytes(len);

    uint k = len - 1;

    while (_i != 0) {

      bstr[k--] = byte(uint8(48 + _i % 10));

      _i /= 10;

    }

    return string(bstr);

  }

}



/**

 * @title PriorityQueue

 * @dev A priority queue implementation

 */



library PriorityQueue {

  using SafeMath for uint256;



  struct Token {

    TransferrableToken addr;

    uint256[] heapList;

    uint256 currentSize;

  }



  function insert(Token storage self, uint256 k) public {

    self.heapList.push(k);

    self.currentSize = self.currentSize.add(1);

    percUp(self, self.currentSize);

  }



  function minChild(Token storage self, uint256 i) public view returns (uint256) {

    if (i.mul(2).add(1) > self.currentSize) {

      return i.mul(2);

    } else {

      if (self.heapList[i.mul(2)] < self.heapList[i.mul(2).add(1)]) {

        return i.mul(2);

      } else {

        return i.mul(2).add(1);

      }

    }

  }



  function getMin(Token storage self) public view returns (uint256) {

    return self.heapList[1];

  }



  function delMin(Token storage self) public returns (uint256) {

    uint256 retVal = self.heapList[1];

    self.heapList[1] = self.heapList[self.currentSize];

    delete self.heapList[self.currentSize];

    self.currentSize = self.currentSize.sub(1);

    percDown(self, 1);

    self.heapList.length = self.heapList.length.sub(1);

    return retVal;

  }



  // solium-disable-next-line security/no-assign-params

  function percUp(Token storage self, uint256 i) private {

    uint256 j = i;

    uint256 newVal = self.heapList[i];

    while (newVal < self.heapList[i.div(2)]) {

      self.heapList[i] = self.heapList[i.div(2)];

      i = i.div(2);

    }

    if (i != j) self.heapList[i] = newVal;

  }



  // solium-disable-next-line security/no-assign-params

  function percDown(Token storage self, uint256 i) private {

    uint256 j = i;

    uint256 newVal = self.heapList[i];

    uint256 mc = minChild(self, i);

    while (mc <= self.currentSize && newVal > self.heapList[mc]) {

      self.heapList[i] = self.heapList[mc];

      i = mc;

      mc = minChild(self, i);

    }

    if (i != j) self.heapList[i] = newVal;

  }



}