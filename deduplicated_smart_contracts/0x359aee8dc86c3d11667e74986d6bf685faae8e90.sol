/**
 *Submitted for verification at Etherscan.io on 2019-10-28
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */
 
pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title EIP20/ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract EIP20 is ERC20 {
    string public name;
    uint8 public decimals;
    string public symbol;
}

contract WETHInterface is EIP20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Integer division of two numbers, rounding up and truncating the quotient
  */
  function divCeil(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }

    return ((_a - 1) / _b) + 1;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2��.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
  uint256 internal constant REENTRANCY_GUARD_FREE = 1;

  /// @dev Constant for locked guard state
  uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

  /**
   * @dev We use a single lock for the whole contract.
   */
  uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
    reentrancyLock = REENTRANCY_GUARD_LOCKED;
    _;
    reentrancyLock = REENTRANCY_GUARD_FREE;
  }

}

contract LoanTokenization is ReentrancyGuard, Ownable {

    uint256 internal constant MAX_UINT = 2**256 - 1;

    string public name;
    string public symbol;
    uint8 public decimals;

    address public bZxContract;
    address public bZxVault;
    address public bZxOracle;
    address public wethContract;

    address public loanTokenAddress;

    // price of token at last user checkpoint
    mapping (address => uint256) internal checkpointPrices_;
}

contract LoanTokenStorage is LoanTokenization {

    struct ListIndex {
        uint256 index;
        bool isSet;
    }

    struct LoanData {
        bytes32 loanOrderHash;
        uint256 leverageAmount;
        uint256 initialMarginAmount;
        uint256 maintenanceMarginAmount;
        uint256 maxDurationUnixTimestampSec;
        uint256 index;
        uint256 marginPremiumAmount;
        address collateralTokenAddress;
    }

    struct TokenReserves {
        address lender;
        uint256 amount;
    }

    event Borrow(
        address indexed borrower,
        uint256 borrowAmount,
        uint256 interestRate,
        address collateralTokenAddress,
        address tradeTokenToFillAddress,
        bool withdrawOnOpen
    );

    event Claim(
        address indexed claimant,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 remainingTokenAmount,
        uint256 price
    );

    bool internal isInitialized_ = false;

    address public tokenizedRegistry;

    uint256 public baseRate = 1000000000000000000; // 1.0%
    uint256 public rateMultiplier = 18750000000000000000; // 18.75%

    // slot addition (non-sequential): lowUtilBaseRate = 8000000000000000000; // 8.0%
    // slot addition (non-sequential): lowUtilRateMultiplier = 4750000000000000000; // 4.75%

    // "fee percentage retained by the oracle" = SafeMath.sub(10**20, spreadMultiplier);
    uint256 public spreadMultiplier;

    mapping (uint256 => bytes32) public loanOrderHashes; // mapping of levergeAmount to loanOrderHash
    mapping (bytes32 => LoanData) public loanOrderData; // mapping of loanOrderHash to LoanOrder
    uint256[] public leverageList;

    TokenReserves[] public burntTokenReserveList; // array of TokenReserves
    mapping (address => ListIndex) public burntTokenReserveListIndex; // mapping of lender address to ListIndex objects
    uint256 public burntTokenReserved; // total outstanding burnt token amount
    address internal nextOwedLender_;

    uint256 public totalAssetBorrow; // current amount of loan token amount tied up in loans

    uint256 public checkpointSupply;

    uint256 internal lastSettleTime_;

    uint256 public initialPrice;
}

contract AdvancedTokenStorage is LoanTokenStorage {
    using SafeMath for uint256;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Mint(
        address indexed minter,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );
    event Burn(
        address indexed burner,
        uint256 tokenAmount,
        uint256 assetAmount,
        uint256 price
    );

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 internal totalSupply_;

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return totalSupply_;
    }

    function balanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }
}

contract AdvancedToken is AdvancedTokenStorage {
    using SafeMath for uint256;

    function approve(
        address _spender,
        uint256 _value)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _mint(
        address _to,
        uint256 _tokenAmount,
        uint256 _assetAmount,
        uint256 _price)
        internal
    {
        require(_to != address(0), "invalid address");
        totalSupply_ = totalSupply_.add(_tokenAmount);
        balances[_to] = balances[_to].add(_tokenAmount);

        emit Mint(_to, _tokenAmount, _assetAmount, _price);
        emit Transfer(address(0), _to, _tokenAmount);
    }

    function _burn(
        address _who,
        uint256 _tokenAmount,
        uint256 _assetAmount,
        uint256 _price)
        internal
    {
        require(_tokenAmount <= balances[_who], "burn value exceeds balance");
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_tokenAmount);
        if (balances[_who] <= 10) { // we can't leave such small balance quantities
            _tokenAmount = _tokenAmount.add(balances[_who]);
            balances[_who] = 0;
        }

        totalSupply_ = totalSupply_.sub(_tokenAmount);

        emit Burn(_who, _tokenAmount, _assetAmount, _price);
        emit Transfer(_who, address(0), _tokenAmount);
    }
}

interface IBZxSettings {
    function pushLoanOrderOnChain(
        address[8] calldata orderAddresses,
        uint256[11] calldata orderValues,
        bytes calldata oracleData,
        bytes calldata signature)
        external
        returns (bytes32); // loanOrderHash

    function setLoanOrderDesc(
        bytes32 loanOrderHash,
        string calldata desc)
        external
        returns (bool);

    function oracleAddresses(
        address oracleAddress)
        external
        view
        returns (address);
}

interface IBZxOracleSettings {
    function tradeUserAsset(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiverAddress,
        address returnToSenderAddress,
        uint256 sourceTokenAmount,
        uint256 maxDestTokenAmount,
        uint256 minConversionRate)
        external
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed);

    function interestFeePercent()
        external
        view
        returns (uint256);
}

contract LoanTokenSettings is AdvancedToken {
    using SafeMath for uint256;

    struct LeverageParams {
        uint256 leverageAmount;
        uint256 initialMarginAmount;
        uint256 maintenanceMarginAmount;
        uint256 maxDurationUnixTimestampSec;
        uint256 marginPremiumAmount;
        address collateralTokenAddress;
    }

    modifier onlyAdmin() {
        require(msg.sender == address(this) ||
            msg.sender == owner, "unauthorized");
        _;
    }

    function()
        external
    {
        revert("invalid");
    }

    function initLeverageBatch(
        LeverageParams[] memory leverageParamsArr,
        bool allowUpdate)
        public
        onlyAdmin
    {
        for (uint256 i=0; i < leverageParamsArr.length; i++) {
            LeverageParams memory leverageParams = leverageParamsArr[i];

            uint256 leverageAmount = leverageParams.collateralTokenAddress == address(0) ?
                leverageParams.leverageAmount :
                uint256(keccak256(abi.encodePacked(leverageParams.leverageAmount,leverageParams.collateralTokenAddress)));

            if (!allowUpdate && loanOrderHashes[leverageAmount] != 0) {
                continue;
            }

            address[8] memory orderAddresses = [
                address(this), // makerAddress
                loanTokenAddress, // loanTokenAddress
                loanTokenAddress, // interestTokenAddress (same as loanToken)
                leverageParams.collateralTokenAddress, // collateralTokenAddress
                address(0), // feeRecipientAddress
                bZxOracle, // (leave as original value)
                address(0), // takerAddress
                address(0) // tradeTokenAddress
            ];

            uint256[11] memory orderValues = [
                0, // loanTokenAmount
                0, // interestAmountPerDay
                leverageParams.initialMarginAmount, // initialMarginAmount,
                leverageParams.maintenanceMarginAmount, // maintenanceMarginAmount,
                0, // lenderRelayFee
                0, // traderRelayFee
                leverageParams.maxDurationUnixTimestampSec, // maxDurationUnixTimestampSec,
                0, // expirationUnixTimestampSec
                0, // makerRole (0 = lender)
                0, // withdrawOnOpen
                uint(keccak256(abi.encodePacked(msg.sender, block.timestamp))) // salt
            ];

            bytes32 loanOrderHash = IBZxSettings(bZxContract).pushLoanOrderOnChain(
                orderAddresses,
                orderValues,
                abi.encodePacked(address(this)), // oracleData -> closeLoanNotifier
                ""
            );
            IBZxSettings(bZxContract).setLoanOrderDesc(
                loanOrderHash,
                name
            );
            loanOrderData[loanOrderHash] = LoanData({
                loanOrderHash: loanOrderHash,
                leverageAmount: leverageParams.leverageAmount, // actutal leverage value
                initialMarginAmount: leverageParams.initialMarginAmount,
                maintenanceMarginAmount: leverageParams.maintenanceMarginAmount,
                maxDurationUnixTimestampSec: leverageParams.maxDurationUnixTimestampSec,
                index: leverageList.length,
                marginPremiumAmount: leverageParams.marginPremiumAmount, // applies for over-collateralized loans
                collateralTokenAddress: leverageParams.collateralTokenAddress
            });
            loanOrderHashes[leverageAmount] = loanOrderHash;
            leverageList.push(leverageAmount);
        }
    }

    function removeLeverageBatch(
        uint256[] memory leverageAmounts,
        address[] memory collateralTokenAddresses)
        public
        onlyAdmin
    {
        require(leverageAmounts.length == collateralTokenAddresses.length, "count mismatch");

        for (uint256 i=0; i < leverageAmounts.length; i++) {
            uint256 leverageAmount = leverageAmounts[i];
            address collateralTokenAddress = collateralTokenAddresses[i];

            leverageAmount = collateralTokenAddress == address(0) ?
                leverageAmount :
                uint256(keccak256(abi.encodePacked(leverageAmount,collateralTokenAddress)));

            bytes32 loanOrderHash = loanOrderHashes[leverageAmount];
            require(loanOrderHash != 0, "hash not found");

            if (leverageList.length > 1) {
                uint256 index = loanOrderData[loanOrderHash].index;
                leverageList[index] = leverageList[leverageList.length - 1];
                loanOrderData[loanOrderHashes[leverageList[index]]].index = index;
            }
            leverageList.length--;

            delete loanOrderHashes[leverageAmount];
            delete loanOrderData[loanOrderHash];
        }
    }

    function setLoanDataParams(
        bytes32 hashToUpdate,
        address collateralTokenAddress,
        uint256 leverageAmount,
        uint256 initialMarginAmount,
        uint256 maintenanceMarginAmount,
        uint256 maxDurationUnixTimestampSec,
        uint256 marginPremiumAmount)
        public
        onlyAdmin
    {
        LoanData storage loanData = loanOrderData[hashToUpdate];
        loanData.leverageAmount = leverageAmount;
        loanData.initialMarginAmount = initialMarginAmount;
        loanData.maintenanceMarginAmount = maintenanceMarginAmount;
        loanData.maxDurationUnixTimestampSec = maxDurationUnixTimestampSec;
        loanData.marginPremiumAmount = marginPremiumAmount;
        loanData.collateralTokenAddress = collateralTokenAddress;
    }

    function migrateLeverage(
        uint256 oldLeverageValue,
        uint256 newLeverageValue)
        public
        onlyAdmin
    {
        require(oldLeverageValue != newLeverageValue, "mismatch");
        bytes32 loanOrderHash = loanOrderHashes[oldLeverageValue];
        LoanData storage loanData = loanOrderData[loanOrderHash];
        require(loanData.initialMarginAmount != 0, "loan not found");

        delete loanOrderHashes[oldLeverageValue];

        leverageList[loanData.index] = newLeverageValue;
        loanData.leverageAmount = newLeverageValue;
        loanOrderHashes[newLeverageValue] = loanOrderHash;
    }

    // These params should be percentages represented like so: 5% = 5000000000000000000
    // rateMultiplier + baseRate can't exceed 100%
    function setDemandCurve(
        uint256 _baseRate,
        uint256 _rateMultiplier,
        uint256 _lowUtilBaseRate,
        uint256 _lowUtilRateMultiplier,
        uint256 _fixedInterestBaseRate,
        uint256 _fixedInterestRateMultiplier)
        public
        onlyAdmin
    {
        require(_rateMultiplier.add(_baseRate) <= 10**20, "");
        require(_lowUtilRateMultiplier.add(_lowUtilBaseRate) <= 10**20, "");
        require(_fixedInterestRateMultiplier.add(_fixedInterestBaseRate) <= 10**20, "");

        baseRate = _baseRate;
        rateMultiplier = _rateMultiplier;

        //keccak256("iToken_LowUtilBaseRate"), keccak256("iToken_LowUtilRateMultiplier")
        //keccak256("iToken_FixedInterestBaseRate"), keccak256("iToken_FixedInterestRateMultiplier")
        assembly {
            sstore(0x3d82e958c891799f357c1316ae5543412952ae5c423336f8929ed7458039c995, _lowUtilBaseRate)
            sstore(0x2b4858b1bc9e2d14afab03340ce5f6c81b703c86a0c570653ae586534e095fb1, _lowUtilRateMultiplier)

            sstore(0x185a40c6b6d3f849f72c71ea950323d21149c27a9d90f7dc5e5ea2d332edcf7f, _fixedInterestBaseRate)
            sstore(0x9ff54bc0049f5eab56ca7cd14591be3f7ed6355b856d01e3770305c74a004ea2, _fixedInterestRateMultiplier)
        }
    }

    function setInterestFeePercent(
        uint256 _newRate)
        public
        onlyAdmin
    {
        require(_newRate <= 10**20, "");
        spreadMultiplier = SafeMath.sub(10**20, _newRate);
    }

    function setBZxOracle(
        address _addr)
        public
        onlyAdmin
    {
        bZxOracle = _addr;
    }

    function setTokenizedRegistry(
        address _addr)
        public
        onlyAdmin
    {
        tokenizedRegistry = _addr;
    }

    function setWethContract(
        address _addr)
        public
        onlyAdmin
    {
        wethContract = _addr;
    }

    function recoverEther(
        address payable receiver,
        uint256 amount)
        public
        onlyAdmin
    {
        uint256 balance = address(this).balance;
        if (balance < amount)
            amount = balance;

        receiver.transfer(amount);
    }

    function recoverToken(
        address tokenAddress,
        address receiver,
        uint256 amount)
        public
        onlyAdmin
    {
        require(tokenAddress != loanTokenAddress, "invalid token");

        ERC20 token = ERC20(tokenAddress);

        uint256 balance = token.balanceOf(address(this));
        if (balance < amount)
            amount = balance;

        require(token.transfer(
            receiver,
            amount),
            "transfer failed"
        );
    }

    function swapIntoLoanToken(
        address sourceTokenAddress,
        uint256 amount)
        public
        onlyAdmin
    {
        require(sourceTokenAddress != loanTokenAddress, "invalid token");

        address oracleAddress = IBZxSettings(bZxContract).oracleAddresses(bZxOracle);

        uint256 balance = ERC20(sourceTokenAddress).balanceOf(address(this));
        if (balance < amount)
            amount = balance;

        uint256 tempAllowance = ERC20(sourceTokenAddress).allowance(address(this), oracleAddress);
        if (tempAllowance < amount) {
            if (tempAllowance != 0) {
                // reset approval to 0
                require(ERC20(sourceTokenAddress).approve(oracleAddress, 0), "token approval reset failed");
            }

            require(ERC20(sourceTokenAddress).approve(oracleAddress, MAX_UINT), "token approval failed");
        }

        IBZxOracleSettings(oracleAddress).tradeUserAsset(
            sourceTokenAddress,
            loanTokenAddress,
            address(this),  // receiverAddress
            address(this),  // returnToSenderAddress
            amount,         // sourceTokenAmount
            MAX_UINT,       // maxDestTokenAmount
            0               // minConversionRate
        );
    }

    function initialize(
        address _bZxContract,
        address _bZxVault,
        address _bZxOracle,
        address _wethContract,
        address _loanTokenAddress,
        address _tokenizedRegistry,
        string memory _name,
        string memory _symbol)
        public
        onlyAdmin
    {
        require (!isInitialized_);

        bZxContract = _bZxContract;
        bZxVault = _bZxVault;
        bZxOracle = _bZxOracle;
        wethContract = _wethContract;
        loanTokenAddress = _loanTokenAddress;
        tokenizedRegistry = _tokenizedRegistry;

        name = _name;
        symbol = _symbol;
        decimals = EIP20(loanTokenAddress).decimals();

        spreadMultiplier = SafeMath.sub(10**20, IBZxOracleSettings(_bZxOracle).interestFeePercent());

        initialPrice = 10**18; // starting price of 1

        isInitialized_ = true;
    }
}