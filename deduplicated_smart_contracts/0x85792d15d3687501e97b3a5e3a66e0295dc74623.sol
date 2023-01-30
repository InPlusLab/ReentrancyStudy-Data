/**
 *Submitted for verification at Etherscan.io on 2019-08-31
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
 * @author Remco Bloemen <remco@2¦Ð.com>, Eenae <alexey@mixbytes.io>
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

    function increaseApproval(
        address _spender,
        uint256 _addedValue)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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

contract BZxObjects {

    struct LoanOrder {
        address loanTokenAddress;
        address interestTokenAddress;
        address collateralTokenAddress;
        address oracleAddress;
        uint256 loanTokenAmount;
        uint256 interestAmount;
        uint256 initialMarginAmount;
        uint256 maintenanceMarginAmount;
        uint256 maxDurationUnixTimestampSec;
        bytes32 loanOrderHash;
    }

    struct LoanPosition {
        address trader;
        address collateralTokenAddressFilled;
        address positionTokenAddressFilled;
        uint256 loanTokenAmountFilled;
        uint256 loanTokenAmountUsed;
        uint256 collateralTokenAmountFilled;
        uint256 positionTokenAmountFilled;
        uint256 loanStartUnixTimestampSec;
        uint256 loanEndUnixTimestampSec;
        bool active;
        uint256 positionId;
    }
}

contract OracleNotifierInterface {

    function closeLoanNotifier(
        BZxObjects.LoanOrder memory loanOrder,
        BZxObjects.LoanPosition memory loanPosition,
        address loanCloser,
        uint256 closeAmount,
        bool isLiquidation)
        public
        returns (bool);
}

interface IBZx {
    function takeOrderFromiToken(
        bytes32 loanOrderHash,              // existing loan order hash
        address trader,                     // borrower/trader
        address collateralTokenAddress,     // collateral token
        address tradeTokenAddress,          // trade token
        uint256 newInterestRate,            // new loan interest rate
        uint256 newLoanAmount,              // new loan size
        uint256[5] calldata sentAmounts)
            // interestInitialAmount: interestAmount sent to determine initial loan length (this is included in one of the below)
            // loanTokenSent: loanTokenAmount + interestAmount + any extra
            // collateralTokenSent: collateralAmountRequired + any extra
            // tradeTokenSent: tradeTokenAmount (optional)
            // withdrawalAmount: Actual amount sent to borrower (can't exceed newLoanAmount)
        external
        returns (uint256);

    function getLenderInterestForOracle(
        address lender,
        address oracleAddress,
        address interestTokenAddress)
        external
        view
        returns (
            uint256,    // interestPaid
            uint256,    // interestPaidDate
            uint256,    // interestOwedPerDay
            uint256);   // interestUnPaid

    function oracleAddresses(
        address oracleAddress)
        external
        view
        returns (address);

    function getRequiredCollateral(
        address loanTokenAddress,
        address collateralTokenAddress,
        address oracleAddress,
        uint256 newLoanAmount,
        uint256 marginAmount)
        external
        view
        returns (uint256 collateralTokenAmount);

    function getBorrowAmount(
        address loanTokenAddress,
        address collateralTokenAddress,
        address oracleAddress,
        uint256 collateralTokenAmount,
        uint256 marginAmount)
        external
        view
        returns (uint256 borrowAmount);
}

interface IBZxOracle {
    function getTradeData(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount)
        external
        view
        returns (uint256 sourceToDestRate, uint256 sourceToDestPrecision, uint256 destTokenAmount);
}

interface iTokenizedRegistry {
    function isTokenType(
        address _token,
        uint256 _tokenType)
        external
        view
        returns (bool valid);
}

contract LoanTokenLogicV2 is AdvancedToken, OracleNotifierInterface {
    using SafeMath for uint256;

    address internal target_;

    modifier onlyOracle() {
        require(msg.sender == IBZx(bZxContract).oracleAddresses(bZxOracle), "1");
        _;
    }


    function()
        external
        payable
    {}


    /* Public functions */

    function mintWithEther(
        address receiver)
        external
        payable
        nonReentrant
        returns (uint256 mintAmount)
    {
        require(loanTokenAddress == wethContract, "2");
        return _mintToken(
            receiver,
            msg.value
        );
    }

    function mint(
        address receiver,
        uint256 depositAmount)
        external
        nonReentrant
        returns (uint256 mintAmount)
    {
        return _mintToken(
            receiver,
            depositAmount
        );
    }

    function burnToEther(
        address payable receiver,
        uint256 burnAmount)
        external
        nonReentrant
        returns (uint256 loanAmountPaid)
    {
        require(loanTokenAddress == wethContract, "3");
        loanAmountPaid = _burnToken(
            receiver,
            burnAmount
        );

        if (loanAmountPaid != 0) {
            WETHInterface(wethContract).withdraw(loanAmountPaid);
            require(receiver.send(loanAmountPaid), "4");
        }
    }

    function burn(
        address receiver,
        uint256 burnAmount)
        external
        nonReentrant
        returns (uint256 loanAmountPaid)
    {
        loanAmountPaid = _burnToken(
            receiver,
            burnAmount
        );

        if (loanAmountPaid != 0) {
            require(ERC20(loanTokenAddress).transfer(
                receiver,
                loanAmountPaid
            ), "5");
        }
    }

    function borrowTokenFromDeposit(
        uint256 borrowAmount,
        uint256 leverageAmount,
        uint256 initialLoanDuration, // duration in seconds
        uint256 collateralTokenSent, // set to 0 if sending ETH
        address borrower,
        address collateralTokenAddress) // address(0) means ETH and ETH must be sent with the call
        public
        payable
        nonReentrant
        returns (bytes32 loanOrderHash)
    {
        require(
            borrowAmount != 0 &&
            ((msg.value == 0 && collateralTokenAddress != address(0) && collateralTokenSent != 0) ||
            (msg.value != 0 && (collateralTokenAddress == address(0) || collateralTokenAddress == wethContract) && collateralTokenSent == 0)),
            "6"
        );

        loanOrderHash = loanOrderHashes[leverageAmount];
        require(loanOrderHash != 0, "7");

        _settleInterest();

        uint256 assetSupply = totalAssetSupply();
        uint256 interestRate = _nextBorrowInterestRate(
            borrowAmount,
            assetSupply
        );

        // initial interestInitialAmount
        uint256 interestInitialAmount = borrowAmount
            .mul(interestRate)
            .mul(initialLoanDuration)
            .div(31536000 * 10**20); // 365 * 86400 * 10**20

        uint256 withdrawalAmount = borrowAmount;
        borrowAmount = borrowAmount.add(interestInitialAmount);

        // final interestRate
        interestRate = _nextBorrowInterestRate(
            borrowAmount,
            assetSupply
        );

        require(_borrowTokenAndUseFinal(
            loanOrderHash,
            borrowAmount,
            interestRate, // interestRate
            [
                interestInitialAmount, // interestInitialAmount
                0, // loanTokenSent
                msg.value == 0 ? collateralTokenSent : msg.value, // collateralTokenSent
                0, // tradeTokenSent
                withdrawalAmount
            ],
            borrower,
            msg.value == 0 ? collateralTokenAddress : wethContract,
            address(0) // tradeTokenAddress
        ) == borrowAmount, "8");
    }

    // Called to borrow token for withdrawal or trade
    // borrowAmount: loan amount to borrow
    // leverageAmount: signals the amount of initial margin we will collect
    //   Please reference the docs for supported values.
    //   Example: 2000000000000000000 -> 150% initial margin
    //            2000000000000000028 -> 150% initial margin, 28-day fixed-term
    // interestInitialAmount: This value will indicate the initial duration of the loan
    //   This is ignored if the loan order has a fixed-term
    // loanTokenSent: loan token sent (interestAmount + extra)
    // collateralTokenSent: collateral token sent
    // tradeTokenSent: trade token sent
    // borrower: the address the loan will be assigned to (this address can be different than msg.sender)
    //    Collateral and interest for loan will be withdrawn from msg.sender
    // collateralTokenAddress: The token to collateralize the loan in
    // tradeTokenAddress: The borrowed token will be swap for this token to start a leveraged trade
    //    If the borrower wished to instead withdraw the borrowed token to their wallet, set this to address(0)
    //    If set to address(0), initial collateral required will equal initial margin percent + 100%
    // returns loanOrderHash for the base protocol loan
    function borrowTokenAndUse(
        uint256 borrowAmount,
        uint256 leverageAmount,
        uint256 interestInitialAmount,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        uint256 tradeTokenSent,
        address borrower,
        address collateralTokenAddress,
        address tradeTokenAddress)
        public
        nonReentrant
        returns (bytes32 loanOrderHash)
    {
        require(collateralTokenAddress != address(0) &&
            (tradeTokenAddress == address(0) ||
                tradeTokenAddress != loanTokenAddress),
            "9"
        );

        loanOrderHash = _borrowTokenAndUse(
            borrowAmount,
            leverageAmount,
            [
                interestInitialAmount,
                loanTokenSent,
                collateralTokenSent,
                tradeTokenSent,
                borrowAmount
            ],
            borrower,
            collateralTokenAddress,
            tradeTokenAddress,
            false // amountIsADeposit
        );
    }

    // Called by pTokens to borrow and immediately get into a positions
    // Other traders can call this, but it's recommended to instead use borrowTokenAndUse(...) instead
    // assumption: depositAmount is collateral + interest deposit and will be denominated in deposit token
    // assumption: loan token and interest token are the same
    // returns loanOrderHash for the base protocol loan
    function marginTradeFromDeposit(
        uint256 depositAmount,
        uint256 leverageAmount,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        uint256 tradeTokenSent,
        address trader,
        address depositTokenAddress,
        address collateralTokenAddress,
        address tradeTokenAddress)
        public
        nonReentrant
        returns (bytes32 loanOrderHash)
    {
        require(tradeTokenAddress != address(0) &&
            tradeTokenAddress != loanTokenAddress,
            "10"
        );

        uint256 amount = depositAmount;
        // To calculate borrow amount and interest owed to lender we need deposit amount to be represented as loan token
        if (depositTokenAddress == tradeTokenAddress) {
            (,,amount) = IBZxOracle(bZxOracle).getTradeData(
                tradeTokenAddress,
                loanTokenAddress,
                amount
            );
        } else if (depositTokenAddress != loanTokenAddress) {
            // depositTokenAddress can only be tradeTokenAddress or loanTokenAddress
            revert("11");
        }

        loanOrderHash = _borrowTokenAndUse(
            amount,                     // amount of deposit
            leverageAmount,
            [
                0,                      // interestInitialAmount (interest is calculated based on fixed-term loan)
                loanTokenSent,
                collateralTokenSent,
                tradeTokenSent,
                0
            ],
            trader,
            collateralTokenAddress,     // collateralTokenAddress
            tradeTokenAddress,          // tradeTokenAddress
            true                        // amountIsADeposit
        );
    }


    // Claims owned loan token for the caller
    // Also claims for user with the longest reserves
    // returns amount claimed for the caller
    function claimLoanToken()
        external
        nonReentrant
        returns (uint256 claimedAmount)
    {
        claimedAmount = _claimLoanToken(msg.sender);

        if (burntTokenReserveList.length != 0) {
            _claimLoanToken(address(0));

            if (burntTokenReserveListIndex[msg.sender].isSet && nextOwedLender_ != msg.sender) {
                // ensure lender is paid next
                nextOwedLender_ = msg.sender;
            }
        }
    }

    function wrapEther()
        public
    {
        if (address(this).balance != 0) {
            WETHInterface(wethContract).deposit.value(address(this).balance)();
        }
    }

    // Sends non-LoanToken assets to the Oracle fund
    // These are assets that would otherwise be "stuck" due to a user accidently sending them to the contract
    function donateAsset(
        address tokenAddress)
        public
        returns (bool)
    {
        if (tokenAddress == loanTokenAddress)
            return false;

        uint256 balance = ERC20(tokenAddress).balanceOf(address(this));
        if (balance == 0)
            return false;

        require(ERC20(tokenAddress).transfer(
            IBZx(bZxContract).oracleAddresses(bZxOracle),
            balance
        ), "12");

        return true;
    }

    function transfer(
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        require(_value <= balances[msg.sender], "insufficient balance");
        require(_to != address(0), "13");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        // handle checkpoint update
        uint256 currentPrice = tokenPrice();
        if (burntTokenReserveListIndex[msg.sender].isSet || balances[msg.sender] != 0) {
            checkpointPrices_[msg.sender] = currentPrice;
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
        if (burntTokenReserveListIndex[_to].isSet || balances[_to] != 0) {
            checkpointPrices_[_to] = currentPrice;
        } else {
            checkpointPrices_[_to] = 0;
        }

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        uint256 allowanceAmount = allowed[_from][msg.sender];
        require(_value <= balances[_from], "14");
        require(_value <= allowanceAmount, "15");
        require(_to != address(0), "16");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (allowanceAmount < MAX_UINT) {
            allowed[_from][msg.sender] = allowanceAmount.sub(_value);
        }

        // handle checkpoint update
        uint256 currentPrice = tokenPrice();
        if (burntTokenReserveListIndex[_from].isSet || balances[_from] != 0) {
            checkpointPrices_[_from] = currentPrice;
        } else {
            checkpointPrices_[_from] = 0;
        }
        if (burntTokenReserveListIndex[_to].isSet || balances[_to] != 0) {
            checkpointPrices_[_to] = currentPrice;
        } else {
            checkpointPrices_[_to] = 0;
        }

        emit Transfer(_from, _to, _value);
        return true;
    }


    /* Public View functions */

    function tokenPrice()
        public
        view
        returns (uint256 price)
    {
        uint256 interestUnPaid = 0;
        if (lastSettleTime_ != block.timestamp) {
            (,,interestUnPaid) = _getAllInterest();

            interestUnPaid = interestUnPaid
                .mul(spreadMultiplier)
                .div(10**20);
        }

        return _tokenPrice(_totalAssetSupply(interestUnPaid));
    }

    function checkpointPrice(
        address _user)
        public
        view
        returns (uint256 price)
    {
        return checkpointPrices_[_user];
    }

    function totalReservedSupply()
        public
        view
        returns (uint256)
    {
        return burntTokenReserved.mul(tokenPrice()).div(10**18);
    }

    function marketLiquidity()
        public
        view
        returns (uint256)
    {
        uint256 totalSupply = totalAssetSupply();
        uint256 reservedSupply = totalReservedSupply();
        if (totalSupply > reservedSupply) {
            totalSupply = totalSupply.sub(reservedSupply);
        } else {
            return 0;
        }

        if (totalSupply > totalAssetBorrow) {
            return totalSupply.sub(totalAssetBorrow);
        } else {
            return 0;
        }
    }

    // interest that lenders are currently receiving for open loans, prior to any fees
    function supplyInterestRate()
        public
        view
        returns (uint256)
    {
        if (totalAssetBorrow != 0) {
            return _supplyInterestRate(totalAssetSupply());
        }
    }

    // the average interest that borrowers are currently paying for open loans, prior to any fees
    function avgBorrowInterestRate()
        public
        view
        returns (uint256)
    {
        if (totalAssetBorrow != 0) {
            return _protocolInterestRate(totalAssetSupply());
        } else {
            return baseRate;
        }
    }

    // the base rate the next base protocol borrower will receive
    function borrowInterestRate()
        public
        view
        returns (uint256)
    {
        return _nextBorrowInterestRate(
            0, // borrowAmount
            totalAssetSupply()
        );
    }

    // the rate the next base protocol borrower will receive based on the amount being borrowed
    function nextBorrowInterestRate(
        uint256 borrowAmount)
        public
        view
        returns (uint256)
    {
        if (borrowAmount != 0) {
            uint256 interestUnPaid = 0;
            if (lastSettleTime_ != block.timestamp) {
                (,,interestUnPaid) = _getAllInterest();

                interestUnPaid = interestUnPaid
                    .mul(spreadMultiplier)
                    .div(10**20);
            }

            uint256 balance = ERC20(loanTokenAddress).balanceOf(address(this)).add(interestUnPaid);
            if (borrowAmount > balance) {
                borrowAmount = balance;
            }
        }

        return _nextBorrowInterestRate(
            borrowAmount,
            totalAssetSupply()
        );
    }

    // kept for backwards compatability
    function nextLoanInterestRate(
        uint256 borrowAmount)
        public
        view
        returns (uint256)
    {
        return nextBorrowInterestRate(borrowAmount);
    }

    function nextSupplyInterestRate(
        uint256 supplyAmount)
        public
        view
        returns (uint256)
    {
        if (totalAssetBorrow != 0) {
            return _supplyInterestRate(totalAssetSupply().add(supplyAmount));
        }
    }

    function totalAssetSupply()
        public
        view
        returns (uint256)
    {
        uint256 interestUnPaid = 0;
        if (lastSettleTime_ != block.timestamp) {
            (,,interestUnPaid) = _getAllInterest();

            interestUnPaid = interestUnPaid
                .mul(spreadMultiplier)
                .div(10**20);
        }

        return _totalAssetSupply(interestUnPaid);
    }

    function getMaxEscrowAmount(
        uint256 leverageAmount)
        public
        view
        returns (uint256)
    {
        LoanData memory loanData = loanOrderData[loanOrderHashes[leverageAmount]];
        if (loanData.initialMarginAmount == 0)
            return 0;

        return marketLiquidity()
            .mul(loanData.initialMarginAmount)
            .div(_adjustValue(
                10**20, // maximum possible interest (100%)
                loanData.maxDurationUnixTimestampSec,
                loanData.initialMarginAmount));
    }

    function getLeverageList()
        public
        view
        returns (uint256[] memory)
    {
        return leverageList;
    }

    // returns the user's balance of underlying token
    function assetBalanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balanceOf(_owner)
            .mul(tokenPrice())
            .div(10**18);
    }

    function getDepositAmountForBorrow(
        uint256 borrowAmount,
        uint256 leverageAmount,             // use 2000000000000000000 for 150% initial margin
        uint256 initialLoanDuration,        // duration in seconds
        address collateralTokenAddress)     // address(0) means ETH
        public
        view
        returns (uint256 depositAmount)
    {
        // interestInitialAmount
        uint256 value = _getInterestInitialAmount(
            borrowAmount,
            initialLoanDuration
        );

        borrowAmount = borrowAmount
            .add(value);
        borrowAmount = _verifyBorrowAmount(borrowAmount);

        value = loanOrderData[loanOrderHashes[leverageAmount]].initialMarginAmount
            .add(10**20); // adjust for over-collateralized loan

        if (borrowAmount != 0) {
            return IBZx(bZxContract).getRequiredCollateral(
                loanTokenAddress,
                collateralTokenAddress != address(0) ? collateralTokenAddress : wethContract,
                bZxOracle,
                borrowAmount,
                value // marginAmount
            );
        } else {
            return 0;
        }
    }

    function getBorrowAmountForDeposit(
        uint256 depositAmount,
        uint256 leverageAmount,             // use 2000000000000000000 for 150% initial margin
        uint256 initialLoanDuration,        // duration in seconds
        address collateralTokenAddress)     // address(0) means ETH
        public
        view
        returns (uint256 borrowAmount)
    {
        uint256 value = loanOrderData[loanOrderHashes[leverageAmount]].initialMarginAmount
            .add(10**20); // adjust for over-collateralized loan

        borrowAmount = IBZx(bZxContract).getBorrowAmount(
            loanTokenAddress,
            collateralTokenAddress != address(0) ? collateralTokenAddress : wethContract,
            bZxOracle,
            depositAmount,
            value // marginAmount
        );

        // interestInitialAmount
        value = _getInterestInitialAmount(
            borrowAmount,
            initialLoanDuration
        );

        if (borrowAmount > value) {
            borrowAmount = borrowAmount
                .sub(value);
            return _verifyBorrowAmount(borrowAmount);
        } else {
            return 0;
        }
    }


    /* Internal functions */

    function _mintToken(
        address receiver,
        uint256 depositAmount)
        internal
        returns (uint256 mintAmount)
    {
        require (depositAmount != 0, "17");

        if (burntTokenReserveList.length != 0) {
            _claimLoanToken(address(0));
            _claimLoanToken(receiver);
            if (msg.sender != receiver)
                _claimLoanToken(msg.sender);
        } else {
            _settleInterest();
        }

        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));
        mintAmount = depositAmount.mul(10**18).div(currentPrice);

        if (msg.value == 0) {
            require(ERC20(loanTokenAddress).transferFrom(
                msg.sender,
                address(this),
                depositAmount
            ), "18");
        } else {
            WETHInterface(wethContract).deposit.value(depositAmount)();
        }

        _mint(receiver, mintAmount, depositAmount, currentPrice);

        checkpointPrices_[receiver] = currentPrice;
    }

    function _burnToken(
        address receiver,
        uint256 burnAmount)
        internal
        returns (uint256 loanAmountPaid)
    {
        require(burnAmount != 0, "19");

        if (burnAmount > balanceOf(msg.sender)) {
            burnAmount = balanceOf(msg.sender);
        }

        if (burntTokenReserveList.length != 0) {
            _claimLoanToken(address(0));
            _claimLoanToken(receiver);
            if (msg.sender != receiver)
                _claimLoanToken(msg.sender);
        } else {
            _settleInterest();
        }

        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));

        uint256 loanAmountOwed = burnAmount.mul(currentPrice).div(10**18);
        uint256 loanAmountAvailableInContract = ERC20(loanTokenAddress).balanceOf(address(this));

        loanAmountPaid = loanAmountOwed;
        if (loanAmountPaid > loanAmountAvailableInContract) {
            uint256 reserveAmount = loanAmountPaid.sub(loanAmountAvailableInContract);
            uint256 reserveTokenAmount = reserveAmount.mul(10**18).div(currentPrice);

            burntTokenReserved = burntTokenReserved.add(reserveTokenAmount);
            if (burntTokenReserveListIndex[receiver].isSet) {
                uint256 index = burntTokenReserveListIndex[receiver].index;
                burntTokenReserveList[index].amount = burntTokenReserveList[index].amount.add(reserveTokenAmount);
            } else {
                burntTokenReserveList.push(TokenReserves({
                    lender: receiver,
                    amount: reserveTokenAmount
                }));
                burntTokenReserveListIndex[receiver] = ListIndex({
                    index: burntTokenReserveList.length-1,
                    isSet: true
                });
            }

            loanAmountPaid = loanAmountAvailableInContract;
        }

        _burn(msg.sender, burnAmount, loanAmountPaid, currentPrice);

        if (burntTokenReserveListIndex[msg.sender].isSet || balances[msg.sender] != 0) {
            checkpointPrices_[msg.sender] = currentPrice;
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
    }

    function _settleInterest()
        internal
    {
        if (lastSettleTime_ != block.timestamp) {
            (bool success,) = bZxContract.call.gas(gasleft())(
                abi.encodeWithSignature(
                    "payInterestForOracle(address,address)",
                    bZxOracle, // (leave as original value)
                    loanTokenAddress // same as interestTokenAddress
                )
            );
            success;
            lastSettleTime_ = block.timestamp;
        }
    }

    function _getInterestInitialAmount(
        uint256 borrowAmount,
        uint256 initialLoanDuration)
        internal
        view
        returns (uint256 interestAmount)
    {
        uint256 assetSupply = totalAssetSupply();
        uint256 interestRate = _nextBorrowInterestRate(
            borrowAmount,
            assetSupply
        );

        // initial interestInitialAmount
        return borrowAmount
            .mul(interestRate)
            .mul(initialLoanDuration)
            .div(31536000 * 10**20); // 365 * 86400 * 10**20
    }

    function _getNextOwed()
        internal
        view
        returns (address)
    {
        if (nextOwedLender_ != address(0))
            return nextOwedLender_;
        else if (burntTokenReserveList.length != 0)
            return burntTokenReserveList[0].lender;
        else
            return address(0);
    }

    function _claimLoanToken(
        address lender)
        internal
        returns (uint256)
    {
        _settleInterest();

        if (lender == address(0))
            lender = _getNextOwed();

        if (!burntTokenReserveListIndex[lender].isSet)
            return 0;

        uint256 index = burntTokenReserveListIndex[lender].index;
        uint256 currentPrice = _tokenPrice(_totalAssetSupply(0));

        uint256 claimAmount = burntTokenReserveList[index].amount.mul(currentPrice).div(10**18);
        if (claimAmount == 0)
            return 0;

        uint256 availableAmount = ERC20(loanTokenAddress).balanceOf(address(this));
        if (availableAmount == 0) {
            return 0;
        }

        uint256 claimTokenAmount;
        if (claimAmount <= availableAmount) {
            claimTokenAmount = burntTokenReserveList[index].amount;
            _removeFromList(lender, index);
        } else {
            claimAmount = availableAmount;
            claimTokenAmount = claimAmount.mul(10**18).div(currentPrice);

            // prevents less than 10 being left in burntTokenReserveList[index].amount
            if (claimTokenAmount.add(10) < burntTokenReserveList[index].amount) {
                burntTokenReserveList[index].amount = burntTokenReserveList[index].amount.sub(claimTokenAmount);
            } else {
                _removeFromList(lender, index);
            }
        }

        require(ERC20(loanTokenAddress).transfer(
            lender,
            claimAmount
        ), "20");

        if (burntTokenReserveListIndex[lender].isSet || balances[lender] != 0) {
            checkpointPrices_[lender] = currentPrice;
        } else {
            checkpointPrices_[lender] = 0;
        }

        burntTokenReserved = burntTokenReserved > claimTokenAmount ?
            burntTokenReserved.sub(claimTokenAmount) :
            0;

        emit Claim(
            lender,
            claimTokenAmount,
            claimAmount,
            burntTokenReserveListIndex[lender].isSet ?
                burntTokenReserveList[burntTokenReserveListIndex[lender].index].amount :
                0,
            currentPrice
        );

        return claimAmount;
    }

    function _borrowTokenAndUse(
        uint256 amount,
        uint256 leverageAmount,
        uint256[5] memory sentAmounts,
        address borrower,
        address collateralTokenAddress,
        address tradeTokenAddress,
        bool amountIsADeposit)
        internal
        returns (bytes32 loanOrderHash)
    {
        require(amount != 0, "21");

        loanOrderHash = loanOrderHashes[leverageAmount];
        require(loanOrderHash != 0, "22");

        _settleInterest();

        uint256 interestRate;
        if (amountIsADeposit) {
            (amount, interestRate) = _getBorrowAmountAndRate(
                loanOrderHash,
                amount
            );

            // update for borrowAmount
            sentAmounts[4] = amount;
        } else {
            // amount is borrow amount
            interestRate = _nextBorrowInterestRate(
                amount,
                totalAssetSupply()
            );
        }

        if (tradeTokenAddress == address(0)) {
            // tradeTokenSent is ignored if trade token isn't specified
            sentAmounts[3] = 0;
        }

        uint256 borrowAmount = _borrowTokenAndUseFinal(
            loanOrderHash,
            amount, // borrowAmount
            interestRate,
            sentAmounts,
            borrower,
            collateralTokenAddress,
            tradeTokenAddress
        );
        require(borrowAmount == amount, "23");
    }

    // returns borrowAmount
    function _borrowTokenAndUseFinal(
        bytes32 loanOrderHash,
        uint256 borrowAmount,
        uint256 interestRate,
        uint256[5] memory sentAmounts,
        address borrower,
        address collateralTokenAddress,
        address tradeTokenAddress)
        internal
        returns (uint256)
    {
        borrowAmount = _verifyBorrowAmount(borrowAmount);
        require (borrowAmount != 0, "24");

        // handle transfers prior to adding borrowAmount to loanTokenSent
        _verifyTransfers(
            borrower,
            collateralTokenAddress,
            tradeTokenAddress,
            borrowAmount,
            sentAmounts[1], // loanTokenSent
            sentAmounts[2], // collateralTokenSent
            sentAmounts[3], // tradeTokenSent
            sentAmounts[4]  // withdrawalAmount
        );

        // adding the loan token amount from the lender to loanTokenSent
        sentAmounts[1] = sentAmounts[1].add(borrowAmount);

        borrowAmount = IBZx(bZxContract).takeOrderFromiToken(
            loanOrderHash,
            borrower,
            collateralTokenAddress,
            tradeTokenAddress,
            interestRate,
            borrowAmount,
            sentAmounts
        );
        require (borrowAmount != 0, "25");

        // update total borrowed amount outstanding in loans
        totalAssetBorrow = totalAssetBorrow.add(borrowAmount);

        // checkpoint supply since the base protocol borrow stats have changed
        checkpointSupply = _totalAssetSupply(0);

        if (burntTokenReserveList.length != 0) {
            _claimLoanToken(address(0));
            _claimLoanToken(borrower);
        }

        emit Borrow(
            borrower,
            borrowAmount,
            interestRate,
            collateralTokenAddress,
            tradeTokenAddress,
            tradeTokenAddress == address(0) // withdrawOnOpen
        );

        return borrowAmount;
    }

    function _verifyBorrowAmount(
        uint256 borrowAmount)
        internal
        view
        returns (uint256)
    {
        uint256 availableToBorrow = ERC20(loanTokenAddress).balanceOf(address(this));
        if (availableToBorrow == 0)
            return 0;

        uint256 reservedSupply = totalReservedSupply();
        if (availableToBorrow > reservedSupply) {
            availableToBorrow = availableToBorrow.sub(reservedSupply);
        } else {
            return 0;
        }

        if (borrowAmount > availableToBorrow) {
            //return availableToBorrow;
            return 0;
        }

        return borrowAmount;
    }

    function _verifyTransfers(
        address borrower,
        address collateralTokenAddress,
        address tradeTokenAddress,
        uint256 borrowAmount,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        uint256 tradeTokenSent,
        uint256 withdrawalAmount)
        internal
    {
        if (tradeTokenAddress == address(0)) { // withdrawOnOpen == true
            require(ERC20(loanTokenAddress).transfer(
                borrower,
                withdrawalAmount
            ), "26");

            if (borrowAmount > withdrawalAmount) {
                require(ERC20(loanTokenAddress).transfer(
                    bZxVault,
                    borrowAmount - withdrawalAmount
                ), "34");
            }
        } else {
            require(ERC20(loanTokenAddress).transfer(
                bZxVault,
                borrowAmount
            ), "27");
        }

        if (collateralTokenSent != 0) {
            if (msg.value != 0) {
                require(collateralTokenAddress == wethContract &&
                    collateralTokenSent == msg.value, "28");

                WETHInterface(wethContract).deposit.value(collateralTokenSent)();

                require(ERC20(collateralTokenAddress).transfer(
                    bZxVault,
                    collateralTokenSent
                ), "29");
            } else {
                if (collateralTokenAddress == loanTokenAddress) {
                    loanTokenSent = loanTokenSent.add(collateralTokenSent);
                } else if (collateralTokenAddress == tradeTokenAddress) {
                    tradeTokenSent = tradeTokenSent.add(collateralTokenSent);
                } else {
                    require(ERC20(collateralTokenAddress).transferFrom(
                        msg.sender,
                        bZxVault,
                        collateralTokenSent
                    ), "30");
                }
            }
        }

        if (loanTokenSent != 0) {
            if (loanTokenAddress == tradeTokenAddress) {
                tradeTokenSent = tradeTokenSent.add(loanTokenSent);
            } else {
                require(ERC20(loanTokenAddress).transferFrom(
                    msg.sender,
                    bZxVault,
                    loanTokenSent
                ), "31");
            }
        }

        if (tradeTokenSent != 0) {
            require(ERC20(tradeTokenAddress).transferFrom(
                msg.sender,
                bZxVault,
                tradeTokenSent
            ), "32");
        }
    }

    function _removeFromList(
        address lender,
        uint256 index)
        internal
    {
        // remove lender from burntToken list
        if (burntTokenReserveList.length > 1) {
            // replace item in list with last item in array
            burntTokenReserveList[index] = burntTokenReserveList[burntTokenReserveList.length - 1];

            // update the position of this replacement
            burntTokenReserveListIndex[burntTokenReserveList[index].lender].index = index;
        }

        // trim array and clear storage
        burntTokenReserveList.length--;
        burntTokenReserveListIndex[lender].index = 0;
        burntTokenReserveListIndex[lender].isSet = false;

        if (lender == nextOwedLender_) {
            nextOwedLender_ = address(0);
        }
    }


    /* Internal View functions */

    function _tokenPrice(
        uint256 assetSupply)
        internal
        view
        returns (uint256)
    {
        uint256 totalTokenSupply = totalSupply_.add(burntTokenReserved);

        return totalTokenSupply != 0 ?
            assetSupply
                .mul(10**18)
                .div(totalTokenSupply) : initialPrice;
    }

    function _protocolInterestRate(
        uint256 assetSupply)
        internal
        view
        returns (uint256)
    {
        uint256 interestRate;
        if (totalAssetBorrow != 0) {
            (,uint256 interestOwedPerDay,) = _getAllInterest();
            interestRate = interestOwedPerDay
                .mul(10**20)
                .div(totalAssetBorrow)
                .mul(365)
                .mul(checkpointSupply)
                .div(assetSupply);
        } else {
            interestRate = baseRate;
        }

        return interestRate;
    }

    // next supply interest adjustment
    function _supplyInterestRate(
        uint256 assetSupply)
        public
        view
        returns (uint256)
    {
        if (totalAssetBorrow != 0) {
            return _protocolInterestRate(assetSupply)
                .mul(_utilizationRate(assetSupply))
                .div(10**20);
        } else {
            return 0;
        }
    }

    // next borrow interest adjustment
    function _nextBorrowInterestRate(
        uint256 newBorrowAmount,
        uint256 assetSupply)
        internal
        view
        returns (uint256 nextRate)
    {
        uint256 utilRate = _utilizationRate(assetSupply)
            .add(newBorrowAmount != 0 ?
                newBorrowAmount
                .mul(10**20)
                .div(assetSupply) : 0);

        uint256 minRate = baseRate;
        uint256 maxRate = rateMultiplier.add(baseRate);

        if (utilRate > 90 ether) {
            // scale rate proportionally up to 100%

            utilRate = utilRate.sub(90 ether);
            if (utilRate > 10 ether)
                utilRate = 10 ether;

            maxRate = maxRate
                .mul(90)
                .div(100);

            nextRate = utilRate
                .mul(SafeMath.sub(100 ether, maxRate))
                .div(10 ether)
                .add(maxRate);
        } else {
            nextRate = utilRate
                .mul(rateMultiplier)
                .div(10**20)
                .add(baseRate);

            if (nextRate < minRate)
                nextRate = minRate;
            else if (nextRate > maxRate)
                nextRate = maxRate;
        }

        return nextRate;
    }

    function _getAllInterest()
        internal
        view
        returns (
            uint256 interestPaidSoFar,
            uint256 interestOwedPerDay,
            uint256 interestUnPaid)
    {
        // these values don't account for any fees retained by the oracle, so we account for it elsewhere with spreadMultiplier
        (interestPaidSoFar,,interestOwedPerDay,interestUnPaid) = IBZx(bZxContract).getLenderInterestForOracle(
            address(this),
            bZxOracle, // (leave as original value)
            loanTokenAddress // same as interestTokenAddress
        );
    }

    function _getBorrowAmountAndRate(
        bytes32 loanOrderHash,
        uint256 depositAmount)
        internal
        view
        returns (uint256 borrowAmount, uint256 interestRate)
    {
        LoanData memory loanData = loanOrderData[loanOrderHash];
        require(loanData.initialMarginAmount != 0, "33");

        interestRate = _nextBorrowInterestRate(
            depositAmount
                .mul(10**20)
                .div(loanData.initialMarginAmount),
            totalAssetSupply()
        );

        // assumes that loan, collateral, and interest token are the same
        borrowAmount = depositAmount
            .mul(10**40)
            .div(_adjustValue(
                interestRate,
                loanData.maxDurationUnixTimestampSec,
                loanData.initialMarginAmount))
            .div(loanData.initialMarginAmount);
    }

    function _adjustValue(
        uint256 interestRate,
        uint256 maxDuration,
        uint256 marginAmount)
        internal
        pure
        returns (uint256)
    {
        return maxDuration != 0 ?
            interestRate
                .mul(10**20)
                .div(31536000) // 86400 * 365
                .mul(maxDuration)
                .div(marginAmount)
                .add(10**20) :
            10**20;
    }

    function _utilizationRate(
        uint256 assetSupply)
        internal
        view
        returns (uint256)
    {
        if (totalAssetBorrow != 0 && assetSupply != 0) {
            // U = total_borrow / total_supply
            return totalAssetBorrow
                .mul(10**20)
                .div(assetSupply);
        } else {
            return 0;
        }
    }

    function _totalAssetSupply(
        uint256 interestUnPaid)
        internal
        view
        returns (uint256)
    {
        return totalSupply_.add(burntTokenReserved) != 0 ?
            ERC20(loanTokenAddress).balanceOf(address(this))
                .add(totalAssetBorrow)
                .add(interestUnPaid) : 0;
    }


    /* Oracle-Only functions */

    // called only by BZxOracle when a loan is partially or fully closed
    function closeLoanNotifier(
        BZxObjects.LoanOrder memory loanOrder,
        BZxObjects.LoanPosition memory loanPosition,
        address loanCloser,
        uint256 closeAmount,
        bool /* isLiquidation */)
        public
        onlyOracle
        returns (bool)
    {
        LoanData memory loanData = loanOrderData[loanOrder.loanOrderHash];
        if (loanData.loanOrderHash == loanOrder.loanOrderHash) {

            totalAssetBorrow = totalAssetBorrow > closeAmount ?
                totalAssetBorrow.sub(closeAmount) : 0;

            if (burntTokenReserveList.length != 0) {
                _claimLoanToken(address(0));
            } else {
                _settleInterest();
            }

            if (closeAmount == 0)
                return true;

            // checkpoint supply since the base protocol borrow stats have changed
            checkpointSupply = _totalAssetSupply(0);

            if (loanCloser != loanPosition.trader) {
                if (iTokenizedRegistry(tokenizedRegistry).isTokenType(
                    loanPosition.trader,
                    2 // tokenType=pToken
                )) {
                    (bool success,) = loanPosition.trader.call(
                        abi.encodeWithSignature(
                            "triggerPosition(bool)",
                            !loanPosition.active // openPosition
                        )
                    );
                    success;
                }
            }

            return true;
        } else {
            return false;
        }
    }


    /* Owner-Only functions */

    function updateSettings(
        address settingsTarget,
        bytes memory txnData)
        public
        onlyOwner
    {
        address currentTarget = target_;
        target_ = settingsTarget;

        (bool result,) = address(this).call(txnData);

        uint256 size;
        uint256 ptr;
        assembly {
            size := returndatasize
            ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            if eq(result, 0) { revert(ptr, size) }
        }

        target_ = currentTarget;

        assembly {
            return(ptr, size)
        }
    }
}