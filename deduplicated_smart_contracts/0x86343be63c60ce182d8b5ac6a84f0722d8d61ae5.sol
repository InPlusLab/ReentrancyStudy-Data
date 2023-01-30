/*

  Copyright 2018 bZeroX, LLC

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

contract GasTracker {

    uint internal gasUsed;

    modifier tracksGas() {
        gasUsed = gasleft();
        _;
        gasUsed = 0;
    }
}

contract BZxObjects {

    struct LoanOrder {
        address maker;
        address loanTokenAddress;
        address interestTokenAddress;
        address collateralTokenAddress;
        address feeRecipientAddress;
        address oracleAddress;
        uint loanTokenAmount;
        uint interestAmount;
        uint initialMarginAmount;
        uint maintenanceMarginAmount;
        uint lenderRelayFee;
        uint traderRelayFee;
        uint expirationUnixTimestampSec;
        bytes32 loanOrderHash;
    }

    struct LoanRef {
        bytes32 loanOrderHash;
        address trader;
    }

    struct LoanPosition {
        address lender;
        address trader;
        address collateralTokenAddressFilled;
        address positionTokenAddressFilled;
        uint loanTokenAmountFilled;
        uint collateralTokenAmountFilled;
        uint positionTokenAmountFilled;
        uint loanStartUnixTimestampSec;
        uint index;
        bool active;
    }

    struct InterestData {
        address lender;
        address interestTokenAddress;
        uint interestTotalAccrued;
        uint interestPaidSoFar;
    }

    event LogLoanTaken (
        address lender,
        address trader,
        address collateralTokenAddressFilled,
        address positionTokenAddressFilled,
        uint loanTokenAmountFilled,
        uint collateralTokenAmountFilled,
        uint positionTokenAmountFilled,
        uint loanStartUnixTimestampSec,
        bool active,
        bytes32 loanOrderHash
    );

    event LogLoanCancelled(
        address maker,
        uint cancelLoanTokenAmount,
        uint remainingLoanTokenAmount,
        bytes32 loanOrderHash
    );

    event LogLoanClosed(
        address lender,
        address trader,
        bool isLiquidation,
        bytes32 loanOrderHash
    );

    event LogPositionTraded(
        bytes32 loanOrderHash,
        address trader,
        address sourceTokenAddress,
        address destTokenAddress,
        uint sourceTokenAmount,
        uint destTokenAmount
    );

    event LogMarginLevels(
        bytes32 loanOrderHash,
        address trader,
        uint initialMarginAmount,
        uint maintenanceMarginAmount,
        uint currentMarginAmount
    );

    event LogWithdrawProfit(
        bytes32 loanOrderHash,
        address trader,
        uint profitWithdrawn,
        uint remainingPosition
    );

    event LogPayInterest(
        bytes32 loanOrderHash,
        address lender,
        address trader,
        uint amountPaid,
        uint totalAccrued
    );

    function buildLoanOrderStruct(
        bytes32 loanOrderHash,
        address[6] addrs,
        uint[9] uints) 
        internal
        pure
        returns (LoanOrder) {

        return LoanOrder({
            maker: addrs[0],
            loanTokenAddress: addrs[1],
            interestTokenAddress: addrs[2],
            collateralTokenAddress: addrs[3],
            feeRecipientAddress: addrs[4],
            oracleAddress: addrs[5],
            loanTokenAmount: uints[0],
            interestAmount: uints[1],
            initialMarginAmount: uints[2],
            maintenanceMarginAmount: uints[3],
            lenderRelayFee: uints[4],
            traderRelayFee: uints[5],
            expirationUnixTimestampSec: uints[6],
            loanOrderHash: loanOrderHash
        });
    }
}

contract BZxStorage is BZxObjects, ReentrancyGuard, Ownable, GasTracker {
    uint internal constant MAX_UINT = 2**256 - 1;

    address public bZRxTokenContract;
    address public vaultContract;
    address public oracleRegistryContract;
    address public bZxTo0xContract;
    bool public DEBUG_MODE = false;

    mapping (bytes32 => LoanOrder) public orders; // mapping of loanOrderHash to taken loanOrders
    mapping (address => bytes32[]) public orderList; // mapping of lenders and trader addresses to array of loanOrderHashes
    mapping (bytes32 => address) public orderLender; // mapping of loanOrderHash to lender address
    mapping (bytes32 => address[]) public orderTraders; // mapping of loanOrderHash to array of trader addresses
    mapping (bytes32 => uint) public orderFilledAmounts; // mapping of loanOrderHash to loanTokenAmount filled
    mapping (bytes32 => uint) public orderCancelledAmounts; // mapping of loanOrderHash to loanTokenAmount cancelled
    mapping (address => address) public oracleAddresses; // mapping of oracles to their current logic contract
    mapping (bytes32 => mapping (address => LoanPosition)) public loanPositions; // mapping of loanOrderHash to mapping of traders to loanPositions
    mapping (bytes32 => mapping (address => uint)) public interestPaid; // mapping of loanOrderHash to mapping of traders to amount of interest paid so far to a lender

    LoanRef[] public loanList; // array of loans that need to be checked for liquidation or expiration
}

contract Proxiable {
    mapping (bytes4 => address) public targets;

    function initialize(address _target) public;

    function _replaceContract(address _target) internal {
        // bytes4(keccak256("initialize(address)")) == 0xc4d66de8
        require(_target.delegatecall(0xc4d66de8, _target), "Proxiable::_replaceContract: failed");
    }
}

contract BZxProxy is BZxStorage, Proxiable {

    function() public {
        address target = targets[msg.sig];
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function initialize(
        address)
        public
    {
        revert();
    }

    /*
     * Owner only functions
     */
    function replaceContract(
        address _target)
        public
        onlyOwner
    {
        _replaceContract(_target);
    }

    function setTarget(
        string _funcId,  // example: "takeLoanOrderAsTrader(address[6],uint256[9],address,uint256,bytes)"
        address _target) // logic contract address
        public
        onlyOwner
        returns(bytes4)
    {
        bytes4 f = bytes4(keccak256(abi.encodePacked(_funcId)));
        targets[f] = _target;
        return f;
    }

    function setBZxAddresses(
        address _bZRxToken,
        address _vault,
        address _oracleregistry,
        address _exchange0xWrapper) 
        public
        onlyOwner
    {
        if (_bZRxToken != address(0) && _vault != address(0) && _oracleregistry != address(0) && _exchange0xWrapper != address(0))
        bZRxTokenContract = _bZRxToken;
        vaultContract = _vault;
        oracleRegistryContract = _oracleregistry;
        bZxTo0xContract = _exchange0xWrapper;
    }

    function setDebugMode (
        bool _debug)
        public
        onlyOwner
    {
        if (DEBUG_MODE != _debug)
            DEBUG_MODE = _debug;
    }

    function setBZRxToken (
        address _token)
        public
        onlyOwner
    {
        if (_token != address(0))
            bZRxTokenContract = _token;
    }

    function setVault (
        address _vault)
        public
        onlyOwner
    {
        if (_vault != address(0))
            vaultContract = _vault;
    }

    function setOracleRegistry (
        address _registry)
        public
        onlyOwner
    {
        if (_registry != address(0))
            oracleRegistryContract = _registry;
    }

    function setOracleReference (
        address _oracle,
        address _logicContract)
        public
        onlyOwner
    {
        if (oracleAddresses[_oracle] != _logicContract)
            oracleAddresses[_oracle] = _logicContract;
    }

    function set0xExchangeWrapper (
        address _wrapper)
        public
        onlyOwner
    {
        if (_wrapper != address(0))
            bZxTo0xContract = _wrapper;
    }

    /*
     * View functions
     */

    function getTarget(
        string _funcId) // example: "takeLoanOrderAsTrader(address[6],uint256[9],address,uint256,bytes)"
        public
        view
        returns (address)
    {
        return targets[bytes4(keccak256(abi.encodePacked(_funcId)))];
    }
}