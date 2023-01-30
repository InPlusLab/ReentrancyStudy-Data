/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity 0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
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

/**
 * @title Initializable
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
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */





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
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */






contract Bridge is Adminable {
  using SafeMath for uint256;

  modifier onlyOperator() {
    require(msg.sender == operator, "Tried to call a only-operator function from non-operator");
    _;
  }

  event NewHeight(uint256 height, bytes32 indexed root);
  event NewOperator(address operator);

  struct Period {
    uint32 height;            // the height of last block in period
    uint32 timestamp;         // the block.timestamp at submission of period
    uint32 parentBlockNumber; // the block.number at submission of period
    bytes32 parentBlockHash;  // the blockhash(block.number -1) at submission of period
  }

  bytes32 constant GENESIS = 0x4920616d207665727920616e6772792c20627574206974207761732066756e21;

  bytes32 public tipHash; // hash of first period that has extended chain to some height
  uint256 public genesisBlockNumber;
  uint256 parentBlockInterval; // how often epochs can be submitted max
  uint256 public lastParentBlock; // last ethereum block when epoch was submitted
  address public operator; // the operator contract

  mapping(bytes32 => Period) public periods;

  function initialize(uint256 _parentBlockInterval) public initializer {
    // init genesis preiod
    Period memory genesisPeriod = Period({
      height: 1,
      timestamp: uint32(block.timestamp),
      parentBlockNumber: uint32(block.number),
      parentBlockHash: blockhash(block.number-1)
    });
    tipHash = GENESIS;
    periods[GENESIS] = genesisPeriod;
    genesisBlockNumber = block.number;
    parentBlockInterval = _parentBlockInterval;
    operator = msg.sender;
  }

  function setOperator(address _operator) public ifAdmin {
    operator = _operator;
    emit NewOperator(_operator);
  }

  function getParentBlockInterval() public view returns (uint256) {
    return parentBlockInterval;
  }

  function setParentBlockInterval(uint256 _parentBlockInterval) public ifAdmin {
    parentBlockInterval = _parentBlockInterval;
  }

  function submitPeriod(
    bytes32 _prevHash,
    bytes32 _root)
  public onlyOperator returns (uint256 newHeight) {

    require(periods[_prevHash].timestamp > 0, "Parent node should exist");
    require(periods[_root].timestamp == 0, "Trying to submit the same root twice");

    // calculate height
    newHeight = periods[_prevHash].height + 1;
    // do some magic if chain extended
    if (newHeight > periods[tipHash].height) {
      // new periods can only be submitted every x Ethereum blocks
      require(
        block.number >= lastParentBlock + parentBlockInterval,
        "Tried to submit new period too soon"
      );
      tipHash = _root;
      lastParentBlock = block.number;
    }
    // strictly speaking this event should be called "New Period"
    // but we don't want to break interfaces for now.
    emit NewHeight(newHeight, _root);
    // store the period
    Period memory newPeriod = Period({
      height: uint32(newHeight),
      timestamp: uint32(block.timestamp),
      parentBlockNumber: uint32(block.number),
      parentBlockHash: blockhash(block.number-1)
    });
    periods[_root] = newPeriod;
  }
}