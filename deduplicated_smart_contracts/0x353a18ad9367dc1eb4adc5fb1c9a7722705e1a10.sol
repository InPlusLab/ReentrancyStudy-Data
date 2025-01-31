/**
 *Submitted for verification at Etherscan.io on 2019-08-06
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

contract LoanTokenizationV2 is ReentrancyGuard, Ownable {

    uint256 internal constant MAX_UINT = 2**256 - 1;

    string public name;
    string public symbol;
    uint8 public decimals;

    address public bZxContract;
    address public bZxVault;
    address public bZxOracle;
    address public wethContract;

    address public loanTokenAddress;

    bool public mintingPaused;
    bool public burningPaused;

    // price of token at last user checkpoint
    mapping (address => uint256) internal checkpointPrices_;


    function pauseMinting(
        bool _isPaused)
        public
        onlyOwner
    {
        mintingPaused = _isPaused;
    }
    function pauseBurning(
        bool _isPaused)
        public
        onlyOwner
    {
        burningPaused = _isPaused;
    }
}

contract PositionTokenStorageV2 is LoanTokenizationV2 {

    bool internal isInitialized_ = false;

    address public loanTokenLender;
    address public tradeTokenAddress;

    uint256 public leverageAmount;
    bytes32 public loanOrderHash;

    uint256 public loanTokenDecimals;
    uint256 public loanTokenAdjustment;

    uint256 public tradeTokenDecimals;
    uint256 public tradeTokenAdjustment;

    uint256 public initialPrice;

    bool public shortPosition;

    mapping (address => uint256) public userSurplus;
    mapping (address => uint256) public userDeficit;

    uint256 public totalSurplus;
    uint256 public totalDeficit;
}

contract SplittableTokenStorageV2 is PositionTokenStorageV2 {
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
        address indexed depositAddress,
        uint256 depositAmount,
        uint256 tokenAmount,
        uint256 price
    );
    event Burn(
        address indexed burner,
        address indexed withdrawalAddress,
        uint256 withdrawalAmount,
        uint256 tokenAmount,
        uint256 price
    );

    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 internal totalSupply_;

    uint256 public splitFactor = 10**18;

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return denormalize(totalSupply_);
    }

    function balanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return denormalize(balances[_owner]);
    }

    function allowance(
        address _owner,
        address _spender)
        public
        view
        returns (uint256)
    {
        return denormalize(allowed[_owner][_spender]);
    }

    function normalize(
        uint256 _value)
        internal
        view
        returns (uint256)
    {
        return _value
            .mul(splitFactor)
            .div(10**18);
    }

    function denormalize(
        uint256 _value)
        internal
        view
        returns (uint256)
    {
        return _value
            .mul(10**18)
            .div(splitFactor);
    }
}

contract SplittableTokenV2 is SplittableTokenStorageV2 {
    using SafeMath for uint256;

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        uint256 allowanceAmount = denormalize(allowed[_from][msg.sender]);
        uint256 fromBalance = denormalize(balances[_from]);
        require(_value <= fromBalance, "insufficient balance");
        require(_value <= allowanceAmount, "insufficient allowance");
        require(_to != address(0), "invalid address");

        balances[_from] = normalize(fromBalance.sub(_value));
        if (balanceOf(_from) == 0) {
            balances[_from] = 0;
        }

        balances[_to] = normalize(denormalize(balances[_to]).add(_value));
        if (allowanceAmount < MAX_UINT) {
            allowed[_from][msg.sender] = normalize(allowanceAmount.sub(_value));
            if (allowance(_from, msg.sender) == 0) {
                allowed[_from][msg.sender] = 0;
            }
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        uint256 fromBalance = denormalize(balances[msg.sender]);
        require(_value <= fromBalance, "insufficient balance");
        require(_to != address(0), "invalid address");

        balances[msg.sender] = normalize(fromBalance.sub(_value));
        if (balanceOf(msg.sender) == 0) {
            balances[msg.sender] = 0;
        }

        balances[_to] = normalize(denormalize(balances[_to]).add(_value));
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        if (allowance(msg.sender, _spender) == 0) {
            allowed[msg.sender][_spender] = 0;
        }

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(
        address _spender,
        uint256 _addedValue)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = normalize(denormalize(allowed[msg.sender][_spender]).add(_addedValue));
        emit Approval(msg.sender, _spender, denormalize(allowed[msg.sender][_spender]));
        return true;
    }

    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = denormalize(allowed[msg.sender][_spender]);
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = normalize(oldValue.sub(_subtractedValue));
            if (allowance(msg.sender, _spender) == 0) {
                allowed[msg.sender][_spender] = 0;
            }
        }
        emit Approval(msg.sender, _spender, denormalize(allowed[msg.sender][_spender]));
        return true;
    }

    function _mint(
        address _to,
        uint256 _tokenAmount)
        internal
    {
        require(_to != address(0), "invalid address");
        totalSupply_ = normalize(denormalize(totalSupply_).add(_tokenAmount));
        balances[_to] = normalize(denormalize(balances[_to]).add(_tokenAmount));

        emit Transfer(address(0), _to, _tokenAmount);
    }

    function _burn(
        address _who,
        uint256 _tokenAmount)
        internal
    {
        uint256 whoBalance = denormalize(balances[_who]);
        require(_tokenAmount <= whoBalance, "burn value exceeds balance");
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        uint256 offsetAmount;
        balances[_who] = normalize(whoBalance.sub(_tokenAmount));
        if (balances[_who] <= 10 || balanceOf(_who) <= 10) { // we can't leave such small balance quantities
            offsetAmount = balances[_who];
            balances[_who] = 0;
        }

        uint256 normSupply = denormalize(totalSupply_);
        if (normSupply > _tokenAmount) {
            totalSupply_ = normalize(normSupply.sub(_tokenAmount));

            if (totalSupply() == 0) {
                totalSupply_ = 0;
                balances[_who] = 0;
            }
        } else {
            balances[_who] = 0;
            totalSupply_ = 0;
        }

        if (offsetAmount > 0) {
            _tokenAmount = _tokenAmount.add(denormalize(offsetAmount));
            if (totalSupply_ > offsetAmount)
                totalSupply_ = totalSupply_.sub(offsetAmount);
            else {
                totalSupply_ = 0;
            }
        }

        emit Transfer(_who, address(0), _tokenAmount);
    }
}

interface IBZx {
    function closeLoanPartiallyFromCollateral(
        bytes32 loanOrderHash,
        uint256 closeAmount)
        external
        returns (uint256 actualCloseAmount);

    function withdrawCollateral(
        bytes32 loanOrderHash,
        uint256 withdrawAmount)
        external
        returns (uint256 amountWithdrawn);

    function depositCollateral(
        bytes32 loanOrderHash,
        address depositTokenAddress,
        uint256 depositAmount)
        external
        returns (bool);

    function getMarginLevels(
        bytes32 loanOrderHash,
        address trader)
        external
        view
        returns (
            uint256 initialMarginAmount,
            uint256 maintenanceMarginAmount,
            uint256 currentMarginAmount);

    function getTotalEscrow(
        bytes32 loanOrderHash,
        address trader)
        external
        view
        returns (
            uint256 netCollateralAmount,
            uint256 interestDepositRemaining,
            uint256 loanTokenAmountBorrowed);

    function oracleAddresses(
        address oracleAddress)
        external
        view
        returns (address);
}

interface IBZxOracle {
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

    function getTradeData(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount)
        external
        view
        returns (uint256 sourceToDestRate, uint256 sourceToDestPrecision, uint256 destTokenAmount);
}

contract ILoanToken {
    function getMaxEscrowAmount(
        uint256 leverageAmount)
        public
        view
        returns (uint256);

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
        external
        returns (bytes32 loanOrderHash);
}

contract PositionTokenLogicV2 is SplittableTokenV2 {
    using SafeMath for uint256;


    function()
        external
        payable
    {}


    /* Public functions */

    // returns the amount of token minted
    // maxPriceAllowed of 0 will be ignored
    function mintWithEther(
        address receiver,
        uint256 maxPriceAllowed)
        external
        payable
        nonReentrant
        returns (uint256)
    {
        require(!mintingPaused, "paused");
        require (msg.value != 0, "msg.value == 0");

        uint256 netCollateralAmount;
        uint256 interestDepositRemaining;
        if (totalSupply() != 0) {
            (netCollateralAmount, interestDepositRemaining,) = IBZx(bZxContract).getTotalEscrow(
                loanOrderHash,
                address(this)
            );
        }
        uint256 currentPrice = _tokenPrice(netCollateralAmount, interestDepositRemaining);

        if (maxPriceAllowed != 0) {
            require(
                currentPrice <= maxPriceAllowed,
                "price too high"
            );
        }

        WETHInterface(wethContract).deposit.value(msg.value)();

        return _mintWithToken(
            receiver,
            wethContract,
            msg.value,
            currentPrice
        );
    }

    // returns the amount of token minted
    // maxPriceAllowed of 0 is ignored
    function mintWithToken(
        address receiver,
        address depositTokenAddress,
        uint256 depositAmount,
        uint256 maxPriceAllowed)
        external
        nonReentrant
        returns (uint256)
    {
        require(!mintingPaused, "paused");
        require (depositAmount != 0, "depositAmount == 0");

        uint256 netCollateralAmount;
        uint256 interestDepositRemaining;
        if (totalSupply() != 0) {
            (netCollateralAmount, interestDepositRemaining,) = IBZx(bZxContract).getTotalEscrow(
                loanOrderHash,
                address(this)
            );
        }
        uint256 currentPrice = _tokenPrice(netCollateralAmount, interestDepositRemaining);

        if (maxPriceAllowed != 0) {
            require(
                currentPrice <= maxPriceAllowed,
                "price too high"
            );
        }

        require(ERC20(depositTokenAddress).transferFrom(
            msg.sender,
            address(this),
            depositAmount
        ), "transfer of token failed");

        return _mintWithToken(
            receiver,
            depositTokenAddress,
            depositAmount,
            currentPrice
        );
    }

    function burnToEther(
        address payable receiver,
        uint256 burnAmount,
        uint256 minPriceAllowed)
        external
        nonReentrant
        returns (uint256)
    {
        require(!burningPaused, "paused");
        (uint256 tradeTokenAmountOwed, uint256 currentPrice) = _burnToken(
            burnAmount,
            minPriceAllowed
        );
        if (tradeTokenAmountOwed != 0) {
            if (wethContract != tradeTokenAddress) {
                (uint256 destTokenAmountReceived,) = _tradeUserAsset(
                    tradeTokenAddress,      // sourceTokenAddress
                    address(0),             // destTokenAddress (address(0) == Ether)
                    receiver,               // receiver
                    tradeTokenAmountOwed    // sourceTokenAmount
                );

                tradeTokenAmountOwed = destTokenAmountReceived;
            } else {
                WETHInterface(wethContract).withdraw(tradeTokenAmountOwed);
                require(receiver.send(tradeTokenAmountOwed), "transfer of ETH failed");
            }
        }

        emit Burn(
            receiver,
            address(0),
            tradeTokenAmountOwed,
            burnAmount,
            currentPrice
        );

        return tradeTokenAmountOwed;
    }

    function burnToToken(
        address receiver,
        address burnTokenAddress,
        uint256 burnAmount,
        uint256 minPriceAllowed)
        external
        nonReentrant
        returns (uint256)
    {
        require(!burningPaused, "paused");
        (uint256 tradeTokenAmountOwed, uint256 currentPrice) = _burnToken(
            burnAmount,
            minPriceAllowed
        );
        if (tradeTokenAmountOwed != 0) {
            if (burnTokenAddress != tradeTokenAddress) {
                (uint256 destTokenAmountReceived,) = _tradeUserAsset(
                    tradeTokenAddress,      // sourceTokenAddress
                    burnTokenAddress,       // destTokenAddress
                    receiver,               // receiver
                    tradeTokenAmountOwed    // sourceTokenAmount
                );

                tradeTokenAmountOwed = destTokenAmountReceived;
            } else {
                require(ERC20(tradeTokenAddress).transfer(
                    receiver,
                    tradeTokenAmountOwed
                ), "transfer of loanToken failed");
            }
        }

        emit Burn(
            receiver,
            burnTokenAddress,
            tradeTokenAmountOwed,
            burnAmount,
            currentPrice
        );

        return tradeTokenAmountOwed;
    }

    // Sends non-tradeToken assets to the Oracle fund
    // These are assets that would otherwise be "stuck" due to a user accidently sending them to the contract
    function donateAsset(
        address tokenAddress)
        external
        nonReentrant
        returns (bool)
    {
        if (tokenAddress == tradeTokenAddress || tokenAddress == loanTokenAddress)
            return false;

        uint256 balance;
        address token;
        if (tokenAddress == address(0)) {
            balance = address(this).balance;
            if (balance == 0)
                return false;
            WETHInterface(wethContract).deposit.value(balance)();
            token = wethContract;
        } else {
            balance = ERC20(tokenAddress).balanceOf(address(this));
            if (balance == 0)
                return false;
            token = tokenAddress;
        }

        require(ERC20(token).transfer(
            IBZx(bZxContract).oracleAddresses(bZxOracle),
            balance
        ), "transfer of token balance failed");

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        super.transferFrom(
            _from,
            _to,
            _value
        );

        // handle checkpoint update
        uint256 currentPrice = denormalize(tokenPrice());
        if (balanceOf(_from) != 0) {
            checkpointPrices_[_from] = currentPrice;
        } else {
            checkpointPrices_[_from] = 0;
        }
        if (balanceOf(_to) != 0) {
            checkpointPrices_[_to] = currentPrice;
        } else {
            checkpointPrices_[_to] = 0;
        }

        return true;
    }

    function transfer(
        address _to,
        uint256 _value)
        public
        returns (bool)
    {
        super.transfer(
            _to,
            _value
        );

        // handle checkpoint update
        uint256 currentPrice = denormalize(tokenPrice());
        if (balanceOf(msg.sender) != 0) {
            checkpointPrices_[msg.sender] = currentPrice;
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
        if (balanceOf(_to) != 0) {
            checkpointPrices_[_to] = currentPrice;
        } else {
            checkpointPrices_[_to] = 0;
        }

        return true;
    }

    /* Public View functions */

    function tokenPrice()
        public
        view
        returns (uint256 price)
    {
        uint256 netCollateralAmount;
        uint256 interestDepositRemaining;
        if (totalSupply() != 0) {
            (netCollateralAmount, interestDepositRemaining,) = IBZx(bZxContract).getTotalEscrow(
                loanOrderHash,
                address(this)
            );
        }

        return _tokenPrice(netCollateralAmount, interestDepositRemaining);
    }

    function liquidationPrice()
        public
        view
        returns (uint256 price)
    {
        (uint256 initialMarginAmount, uint256 maintenanceMarginAmount,uint256 currentMarginAmount) = IBZx(bZxContract).getMarginLevels(
            loanOrderHash,
            address(this));

        if (maintenanceMarginAmount == 0)
            return 0;
        else if (currentMarginAmount <= maintenanceMarginAmount)
            return tokenPrice();

        uint256 initialPrice;
        uint256 currentPrice = tokenPrice();
        uint256 offset = currentPrice
            .mul(initialMarginAmount);
        if (currentMarginAmount >= initialMarginAmount) {
            offset = offset
            .mul(currentMarginAmount - initialMarginAmount)
            .div(10**40);

            initialPrice = currentPrice
                .sub(offset);
        } else {
            offset = offset
            .mul(initialMarginAmount - currentMarginAmount)
            .div(10**40);

            initialPrice = currentPrice
                .add(offset);
        }

        uint256 initialLeverage = SafeMath.div(10**38, initialMarginAmount);
        uint256 currentLeverage = SafeMath.div(10**38, currentMarginAmount);

        price = initialPrice
            .mul(
                maintenanceMarginAmount
                .mul(currentLeverage)
                .div(10**20)
                .add(initialLeverage)
            )
            .div(initialLeverage.add(10**18));
    }

    function checkpointPrice(
        address _user)
        public
        view
        returns (uint256 price)
    {
        return normalize(checkpointPrices_[_user]);
    }

    function currentLeverage()
        public
        view
        returns (uint256 leverage)
    {
        (,,uint256 currentMarginAmount) = IBZx(bZxContract).getMarginLevels(
            loanOrderHash,
            address(this));

        if (currentMarginAmount == 0)
            return 0;

        return SafeMath.div(10**38, currentMarginAmount);
    }

    function marketLiquidityForLoan()
        public
        view
        returns (uint256)
    {
        return ILoanToken(loanTokenLender).getMaxEscrowAmount(leverageAmount);
    }

    function positionValue(
        address _owner)
        public
        view
        returns (uint256 value)
    {
        value = balanceOf(_owner)
            .mul(tokenPrice())
            .div(tradeTokenAdjustment);

        if (shortPosition) {
            (uint256 sourceToDestRate, uint256 sourceToDestPrecision,) = IBZxOracle(bZxOracle).getTradeData(
                tradeTokenAddress,
                loanTokenAddress,
                MAX_UINT // get best rate
            );
            value = value
                .mul(sourceToDestRate)
                .div(sourceToDestPrecision);
        }
    }

    function positionTokenPrice()
        public
        view
        returns (uint256 price)
    {
        uint256 sourceToDestRate;
        uint256 sourceToDestPrecision;
        if (shortPosition) {
            (sourceToDestRate, sourceToDestPrecision,) = IBZxOracle(bZxOracle).getTradeData(
                loanTokenAddress,
                tradeTokenAddress,
                MAX_UINT // get best rate
            );
            price = sourceToDestRate
                .mul(10**loanTokenDecimals)
                .div(sourceToDestPrecision);
        } else {
            (sourceToDestRate, sourceToDestPrecision,) = IBZxOracle(bZxOracle).getTradeData(
                tradeTokenAddress,
                loanTokenAddress,
                MAX_UINT // get best rate
            );
            price = sourceToDestRate
                .mul(10**tradeTokenDecimals)
                .div(sourceToDestPrecision);
        }
    }


    /* Internal functions */

    // returns the amount of token minted
    function _mintWithToken(
        address receiver,
        address depositTokenAddress,
        uint256 depositAmount,
        uint256 currentPrice)
        internal
        returns (uint256)
    {
        uint256 refundAmount;
        if (depositTokenAddress != tradeTokenAddress && depositTokenAddress != loanTokenAddress) {
            (uint256 destTokenAmountReceived, uint256 depositAmountUsed) = _tradeUserAsset(
                depositTokenAddress,    // sourceTokenAddress
                tradeTokenAddress,      // destTokenAddress
                address(this),          // receiver
                depositAmount           // sourceTokenAmount
            );

            if (depositAmount > depositAmountUsed) {
                refundAmount = depositAmount-depositAmountUsed;
                if (msg.value == 0) {
                    require(ERC20(depositTokenAddress).transfer(
                        msg.sender,
                        refundAmount
                    ), "transfer of token failed");
                } else {
                    WETHInterface(wethContract).withdraw(refundAmount);
                    require(msg.sender.send(refundAmount), "transfer of ETH failed");
                }
            }

            depositAmount = destTokenAmountReceived;
            depositTokenAddress = tradeTokenAddress;
        }

        // depositAmount must be >= 0.001 deposit token units
        require(depositAmount >= (10**15 *
            10**uint256(decimals) /
            (depositTokenAddress == tradeTokenAddress ?
                tradeTokenAdjustment :
                loanTokenAdjustment)
        ), "depositAmount too low");

        // open position
        _triggerPosition(
            depositTokenAddress,
            depositAmount
        );

        // get post-entry supply
        (uint256 netCollateralAmount, uint256 interestDepositRemaining,) = IBZx(bZxContract).getTotalEscrow(
            loanOrderHash,
            address(this)
        );
        uint256 postEntrySupply = ERC20(tradeTokenAddress).balanceOf(address(this))
            .add(netCollateralAmount)
            .add(interestDepositRemaining)
            .mul(tradeTokenAdjustment)
            .div(currentPrice);
        require(postEntrySupply > totalSupply(), "supply not added");

        uint256 mintAmount = postEntrySupply - totalSupply();

        _mint(
            receiver,
            mintAmount
        );
        emit Mint(
            receiver,
            depositTokenAddress,
            depositAmount,
            mintAmount,
            currentPrice
        );

        checkpointPrices_[receiver] = denormalize(currentPrice);

        return mintAmount;
    }

    function _burnToken(
        uint256 burnAmount,
        uint256 minPriceAllowed)
        internal
        returns (uint256 tradeTokenAmountOwed, uint256 currentPrice)
    {
        require(burnAmount != 0, "burnAmount == 0");

        if (burnAmount > balanceOf(msg.sender)) {
            burnAmount = balanceOf(msg.sender);
        }

        (uint256 netCollateralAmount, uint256 interestDepositRemaining,) = IBZx(bZxContract).getTotalEscrow(
            loanOrderHash,
            address(this)
        );
        currentPrice = _tokenPrice(netCollateralAmount, interestDepositRemaining);

        if (minPriceAllowed != 0) {
            require(
                currentPrice >= minPriceAllowed,
                "price too low"
            );
        }

        tradeTokenAmountOwed = burnAmount
            .mul(currentPrice)
            .div(tradeTokenAdjustment);

        uint256 tradeTokenAmountAvailableInContract = ERC20(tradeTokenAddress).balanceOf(address(this));

        uint256 preCloseEscrow = tradeTokenAmountAvailableInContract
            .add(netCollateralAmount)
            .add(interestDepositRemaining);

        bool didCallWithdraw;
        if (tradeTokenAmountAvailableInContract < tradeTokenAmountOwed) {
            // will revert if the position needs to be liquidated
            IBZx(bZxContract).closeLoanPartiallyFromCollateral(
                loanOrderHash,
                burnAmount < totalSupply() ?
                    tradeTokenAmountOwed.sub(tradeTokenAmountAvailableInContract) :
                    MAX_UINT
            );

            tradeTokenAmountAvailableInContract = ERC20(tradeTokenAddress).balanceOf(address(this));
            didCallWithdraw = true;
        }

        if (tradeTokenAmountAvailableInContract < tradeTokenAmountOwed) {
            uint256 collateralWithdrawn = IBZx(bZxContract).withdrawCollateral(
                loanOrderHash,
                tradeTokenAmountOwed.sub(tradeTokenAmountAvailableInContract)
            );
            if (collateralWithdrawn != 0) {
                tradeTokenAmountAvailableInContract = tradeTokenAmountAvailableInContract.add(collateralWithdrawn);
                didCallWithdraw = true;
            }
        }

        if (didCallWithdraw) {
            (netCollateralAmount, interestDepositRemaining,) = IBZx(bZxContract).getTotalEscrow(
                loanOrderHash,
                address(this)
            );
            uint256 postCloseEscrow = tradeTokenAmountAvailableInContract
                .add(netCollateralAmount)
                .add(interestDepositRemaining);

            if (postCloseEscrow < preCloseEscrow) {
                uint256 slippageLoss = preCloseEscrow - postCloseEscrow;

                require(tradeTokenAmountOwed > slippageLoss, "slippage too great");
                tradeTokenAmountOwed = tradeTokenAmountOwed - slippageLoss;
            } else {
                tradeTokenAmountOwed = tradeTokenAmountOwed.add(postCloseEscrow - preCloseEscrow);
            }

            if (tradeTokenAmountOwed > tradeTokenAmountAvailableInContract) {
                /*
                // allow at most 5% loss here
                require(
                    tradeTokenAmountOwed
                    .sub(tradeTokenAmountAvailableInContract)
                    .mul(10**20)
                    .div(tradeTokenAmountOwed) <= (5 * 10**18),
                    "contract value too low"
                );
                */
                tradeTokenAmountOwed = tradeTokenAmountAvailableInContract;
            }
        }

        // unless burning the full balance, tradeTokenAmountOwed must be >= 0.001 tradeToken units
        require(burnAmount == balanceOf(msg.sender) || tradeTokenAmountOwed >= (
            10**15 *
            10**uint256(decimals)
            / tradeTokenAdjustment
        ), "burnAmount too low");

        _burn(
            msg.sender,
            burnAmount
        );

        if (totalSupply() == 0 || tokenPrice() == 0) {
            splitFactor = 10**18;
            currentPrice = initialPrice;
        }

        if (balanceOf(msg.sender) != 0) {
            checkpointPrices_[msg.sender] = denormalize(currentPrice);
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
    }

    function _tradeUserAsset(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiver,
        uint256 sourceTokenAmount)
        internal
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed)
    {
        address oracleAddress = IBZx(bZxContract).oracleAddresses(bZxOracle);

        uint256 tempAllowance = ERC20(sourceTokenAddress).allowance(address(this), oracleAddress);
        if (tempAllowance < sourceTokenAmount) {
            if (tempAllowance != 0) {
                // reset approval to 0
                require(ERC20(sourceTokenAddress).approve(oracleAddress, 0), "token approval reset failed");
            }

            require(ERC20(sourceTokenAddress).approve(oracleAddress, MAX_UINT), "token approval failed");
        }

        (destTokenAmountReceived, sourceTokenAmountUsed) = IBZxOracle(oracleAddress).tradeUserAsset(
            sourceTokenAddress,
            destTokenAddress,
            receiver, // receiverAddress
            receiver, // returnToSenderAddress
            sourceTokenAmount,
            MAX_UINT, // maxDestTokenAmount
            0 // minConversionRate
        );
    }

    function _triggerPosition(
        address depositTokenAddress,
        uint256 depositAmount)
        internal
        returns (bool)
    {
        if (tradeTokenAddress == wethContract || loanTokenAddress == wethContract || depositAmount == 0 || depositAmount == MAX_UINT) {
            uint256 ethBalance = address(this).balance;
            if (ethBalance != 0) {
                WETHInterface(wethContract).deposit.value(ethBalance)();
                if (tradeTokenAddress != wethContract && loanTokenAddress != wethContract) {
                    _tradeUserAsset(
                        wethContract,       // sourceTokenAddress
                        tradeTokenAddress,  // destTokenAddress
                        address(this),      // receiver
                        ethBalance          // sourceTokenAmount
                    );
                }
            }
        }

        uint256 tradeTokenBalance = ERC20(tradeTokenAddress).balanceOf(address(this));
        uint256 loanTokenBalance = ERC20(loanTokenAddress).balanceOf(address(this));

        if (depositAmount == 0) {
            if (loanTokenBalance != 0) {
                (uint256 destTokenAmountReceived,) = _tradeUserAsset(
                    loanTokenAddress,   // sourceTokenAddress
                    tradeTokenAddress,  // destTokenAddress
                    address(this),      // receiver
                    loanTokenBalance    // sourceTokenAmount
                );
                tradeTokenBalance = tradeTokenBalance
                    .add(destTokenAmountReceived);
            }

            if (tradeTokenBalance != 0) {
                uint256 tempAllowance = ERC20(tradeTokenAddress).allowance(address(this), bZxVault);
                if (tempAllowance < tradeTokenBalance) {
                    if (tempAllowance != 0) {
                        // reset approval to 0
                        require(ERC20(tradeTokenAddress).approve(bZxVault, 0), "token approval reset failed");
                    }

                    require(ERC20(tradeTokenAddress).approve(bZxVault, MAX_UINT), "token approval failed");
                }

                return IBZx(bZxContract).depositCollateral(
                    loanOrderHash,
                    tradeTokenAddress,
                    tradeTokenBalance
                );
            }
        } else {
            if (tradeTokenBalance != 0) {
                uint256 tempAllowance = ERC20(tradeTokenAddress).allowance(address(this), loanTokenLender);
                if (tempAllowance < tradeTokenBalance) {
                    if (tempAllowance != 0) {
                        // reset approval to 0
                        require(ERC20(tradeTokenAddress).approve(loanTokenLender, 0), "token approval reset failed");
                    }

                    require(ERC20(tradeTokenAddress).approve(loanTokenLender, MAX_UINT), "token approval failed");
                }

                if (depositAmount == MAX_UINT) {
                    depositAmount = tradeTokenBalance;
                    depositTokenAddress = tradeTokenAddress;
                }
            }
            if (loanTokenBalance != 0) {
                uint256 tempAllowance = ERC20(loanTokenAddress).allowance(address(this), loanTokenLender);
                if (tempAllowance < loanTokenBalance) {
                    if (tempAllowance != 0) {
                        // reset approval to 0
                        require(ERC20(loanTokenAddress).approve(loanTokenLender, 0), "token approval reset failed");
                    }

                    require(ERC20(loanTokenAddress).approve(loanTokenLender, MAX_UINT), "token approval failed");
                }

                if (depositAmount == MAX_UINT) {
                    depositAmount = loanTokenBalance;
                    depositTokenAddress = loanTokenAddress;
                }
            }

            if (loanTokenBalance != 0 || tradeTokenBalance != 0) {
                ILoanToken(loanTokenLender).marginTradeFromDeposit(
                    depositAmount,          // depositAmount
                    leverageAmount,         // leverageAmount
                    loanTokenBalance,       // loanTokenSent
                    tradeTokenBalance,      // collateralTokenSent
                    0,                      // tradeTokenSent
                    address(this),          // trader
                    depositTokenAddress,    // depositTokenAddress
                    tradeTokenAddress,      // collateralTokenAddress
                    tradeTokenAddress       // tradeTokenAddress
                );
                return true;
            }
        }

        return false;
    }


    /* Internal View functions */

    function _tokenPrice(
        uint256 netCollateralAmount,
        uint256 interestDepositRemaining)
        internal
        view
        returns (uint256)
    {
        return totalSupply_ != 0 ?
            normalize(
                ERC20(tradeTokenAddress).balanceOf(address(this))
                .add(netCollateralAmount)
                .add(interestDepositRemaining)
                .mul(tradeTokenAdjustment)
                .div(totalSupply_)
            ) : initialPrice;
    }


    /* Owner-Only functions */

    function setLoanTokenLender(
        address _lender)
        public
        onlyOwner
    {
        loanTokenLender = _lender;
    }

    function setBZxContract(
        address _addr)
        public
        onlyOwner
    {
        bZxContract = _addr;
    }

    function setBZxVault(
        address _addr)
        public
        onlyOwner
    {
        bZxVault = _addr;
    }

    function setBZxOracle(
        address _addr)
        public
        onlyOwner
    {
        bZxOracle = _addr;
    }

    function setInitialPrice(
        uint256 _value)
        public
        onlyOwner
    {
        require(_value != 0, "value can't be 0");
        initialPrice = _value;
    }

    function setSplitValue(
        uint256 _value)
        public
        onlyOwner
    {
        require(_value != 0, "value can't be 0");
        splitFactor = _value;
    }

    function handleSplit()
        public
        onlyOwner
    {
        if (totalSupply() != 0) {
            splitFactor = splitFactor
                .mul(initialPrice)
                .div(
                    tokenPrice()
                );
        } else {
            splitFactor = 10**18;
        }
    }

    // depositTokenAddress is swapped to tradeTokenAddress (collateral token) if needed in the protocol
    // this is callable by anyone that wants to top up the collateral
    function depositCollateralToLoan(
        address depositTokenAddress,
        uint256 depositAmount)
        external
        nonReentrant
    {
        require(ERC20(depositTokenAddress).transferFrom(
            msg.sender,
            address(this),
            depositAmount
        ), "transfer of token failed");

        uint256 tempAllowance = ERC20(depositTokenAddress).allowance(address(this), bZxVault);
        if (tempAllowance < depositAmount) {
            if (tempAllowance != 0) {
                // reset approval to 0
                require(ERC20(depositTokenAddress).approve(bZxVault, 0), "token approval reset failed");
            }

            require(ERC20(depositTokenAddress).approve(bZxVault, MAX_UINT), "token approval failed");
        }

        require(IBZx(bZxContract).depositCollateral(
            loanOrderHash,
            depositTokenAddress,
            depositAmount
        ), "deposit failed");
    }

    function triggerPosition(
        bool openPosition)
        public
    {
        require(totalSupply_ != 0, "no supply");
        if (openPosition) {
            _triggerPosition(address(0), MAX_UINT);
        } else {
            _triggerPosition(address(0), 0);
        }
    }

    function initialize(
        address[7] memory addresses,
        bool _shortPosition,
        uint256 _leverageAmount,
        bytes32 _loanOrderHash,
        string memory _name,
        string memory _symbol)
        public
        onlyOwner
    {
        require (!isInitialized_, "already initialized");

        bZxContract = addresses[0];
        bZxVault = addresses[1];
        bZxOracle = addresses[2];
        wethContract = addresses[3];
        loanTokenAddress = addresses[4];
        tradeTokenAddress = addresses[5];
        loanTokenLender = addresses[6];

        shortPosition = _shortPosition;

        loanOrderHash = _loanOrderHash;
        leverageAmount = _leverageAmount;

        name = _name;
        symbol = _symbol;
        decimals = 18;

        loanTokenDecimals = uint256(EIP20(loanTokenAddress).decimals());
        // 10**18 * 10**(18-decimals_of_loan_token)
        loanTokenAdjustment = SafeMath.mul(
            10**18,
            10**(
                SafeMath.sub(
                    18,
                    loanTokenDecimals
                )
            )
        );

        tradeTokenDecimals = uint256(EIP20(tradeTokenAddress).decimals());
        // 10**18 * 10**(18-decimals_of_trade_token)
        tradeTokenAdjustment = SafeMath.mul(
            10**18,
            10**(
                SafeMath.sub(
                    18,
                    tradeTokenDecimals
                )
            )
        );

        initialPrice = 10**21; // starting price of 1,000

        isInitialized_ = true;
    }
}