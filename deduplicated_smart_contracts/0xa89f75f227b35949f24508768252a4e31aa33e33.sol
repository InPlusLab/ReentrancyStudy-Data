/**
 *Submitted for verification at Etherscan.io on 2020-02-24
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
        if (allowanceAmount != MAX_UINT) {
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
        if (_value != MAX_UINT && allowance(msg.sender, _spender) == 0) {
            allowed[msg.sender][_spender] = 0;
        }

        emit Approval(msg.sender, _spender, _value);
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
        uint256 closeAmount,
        bytes calldata loanDataBytes)
        external
        payable
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

    function getTotalEscrowWithRate(
        bytes32 loanOrderHash,
        address trader,
        uint256 toCollateralRate,
        uint256 toCollateralPrecision)
        external
        view
        returns (
            uint256 netCollateralAmount,
            uint256 interestDepositRemaining,
            uint256 loanToCollateralAmount,
            uint256, // toCollateralRate
            uint256); // toCollateralPrecision

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

    function setSaneRate(
        address sourceTokenAddress,
        address destTokenAddress)
        external
        returns (uint256 saneRate);

    function clearSaneRate(
        address sourceTokenAddress,
        address destTokenAddress)
        external;

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
        address tradeTokenAddress,
        bytes calldata loanDataBytes)
        external
        payable
        returns (bytes32 loanOrderHash);
}

interface IWethHelper {
    function claimEther(
        address receiver,
        uint256 amount)
        external
        returns (uint256 claimAmount);
}

contract PositionTokenLogicV2 is SplittableTokenV2 {
    using SafeMath for uint256;

    address internal target_;

    modifier fixedSaneRate
    {
        address currentOracle_ = IBZx(bZxContract).oracleAddresses(bZxOracle);

        IBZxOracle(currentOracle_).setSaneRate(
            loanTokenAddress,
            tradeTokenAddress
        );

        _;

        IBZxOracle(currentOracle_).clearSaneRate(
            loanTokenAddress,
            tradeTokenAddress
        );
    }


    function()
        external
        payable
    {}


    /* Public functions */

    function mintWithEther(
        address receiver,
        uint256 maxPriceAllowed)
        public
        payable
        returns (uint256)
    {
        return mintWithEther(
            receiver,
            maxPriceAllowed,
            ""
        );
    }

    function mintWithToken(
        address receiver,
        address depositTokenAddress,
        uint256 depositAmount,
        uint256 maxPriceAllowed)
        public
        returns (uint256)
    {
        return mintWithToken(
            receiver,
            depositTokenAddress,
            depositAmount,
            maxPriceAllowed,
            ""
        );
    }

    function burnToToken(
        address receiver,
        address burnTokenAddress,
        uint256 burnAmount,
        uint256 minPriceAllowed)
        public
        returns (uint256)
    {
        return burnToToken(
            receiver,
            burnTokenAddress,
            burnAmount,
            minPriceAllowed,
            ""
        );
    }

    function burnToEther(
        address receiver,
        uint256 burnAmount,
        uint256 minPriceAllowed)
        public
        returns (uint256)
    {
        return burnToEther(
            receiver,
            burnAmount,
            minPriceAllowed,
            ""
        );
    }

    // returns the amount of token minted
    // maxPriceAllowed of 0 will be ignored
    function mintWithEther(
        address receiver,
        uint256 maxPriceAllowed,
        bytes memory /*loanDataBytes*/)
        public
        payable
        nonReentrant
        fixedSaneRate
        returns (uint256)
    {
        require(!mintingPaused, "paused");
        require(msg.value != 0, "no ether sent");

        uint256 netCollateralAmount;
        uint256 interestDepositRemaining;
        uint256 toCollateralRate;
        uint256 toCollateralPrecision;
        if (totalSupply() != 0) {
            (netCollateralAmount,
             interestDepositRemaining,
             ,
             toCollateralRate,
             toCollateralPrecision) = IBZx(bZxContract).getTotalEscrowWithRate(
                loanOrderHash,
                address(this),
                0,
                0
            );
        }
        uint256 currentPrice = _tokenPrice(netCollateralAmount, interestDepositRemaining);

        if (maxPriceAllowed != 0) {
            require(
                currentPrice <= maxPriceAllowed,
                "price too high"
            );
        }

        address _wethContract = wethContract;
        WETHInterface(_wethContract).deposit.value(msg.value)();

        return _mintWithToken(
            receiver,
            _wethContract,
            msg.value,
            currentPrice,
            toCollateralRate,
            toCollateralPrecision,
            "" // loanDataBytes
        );
    }

    // returns the amount of token minted
    // maxPriceAllowed of 0 is ignored
    function mintWithToken(
        address receiver,
        address depositTokenAddress,
        uint256 depositAmount,
        uint256 maxPriceAllowed,
        bytes memory loanDataBytes)
        public
        payable
        nonReentrant
        fixedSaneRate
        returns (uint256)
    {
        uint256 mintAmount;
        require(!mintingPaused, "paused");
        require(depositAmount != 0, "depositAmount == 0");

        uint256 value1; // netCollateralAmount
        uint256 value2; // interestDepositRemaining
        uint256 toCollateralRate;
        uint256 toCollateralPrecision;
        if (totalSupply() != 0) {
            (value1,
             value2,
             ,
             toCollateralRate,
             toCollateralPrecision) = IBZx(bZxContract).getTotalEscrowWithRate(
                loanOrderHash,
                address(this),
                0,
                0
            );
        }
        uint256 currentPrice = _tokenPrice(value1, value2);

        if (maxPriceAllowed != 0) {
            require(
                currentPrice <= maxPriceAllowed,
                "price too high"
            );
        }

        if (msg.value != 0) {
            value1 = address(this).balance.sub(msg.value); // beforeEtherBalance
        }

        if (depositTokenAddress == address(0)) {
            require(msg.value >= depositAmount, "insufficient ether");
            address _wethContract = wethContract;
            WETHInterface(_wethContract).deposit.value(depositAmount)();
            depositTokenAddress = _wethContract;
        } else {
            require(ERC20(depositTokenAddress).transferFrom(
                msg.sender,
                address(this),
                depositAmount
            ), "transfer of token failed");
        }

        mintAmount = _mintWithToken(
            receiver,
            depositTokenAddress,
            depositAmount,
            currentPrice,
            toCollateralRate,
            toCollateralPrecision,
            loanDataBytes
        );

        if (msg.value != 0) {
            value2 = address(this).balance; // finalEtherBalance
            if (value2 > value1) {
                (bool success,) = msg.sender.call.value(value2 - value1)("");
                require(success, "eth refund failed");
            }
        }

        return mintAmount;
    }

    function burnToEther(
        address receiver,
        uint256 burnAmount,
        uint256 minPriceAllowed,
        bytes memory loanDataBytes)
        public
        payable
        nonReentrant
        fixedSaneRate
        returns (uint256)
    {
        require(!burningPaused, "paused");
        (uint256 tradeTokenAmountOwed, uint256 currentPrice) = _burnToken(
            burnAmount,
            minPriceAllowed,
            loanDataBytes
        );
        if (tradeTokenAmountOwed != 0) {
            address _wethContract = wethContract;
            if (_wethContract != tradeTokenAddress) {
                (uint256 destTokenAmountReceived,) = _tradeUserAsset(
                    tradeTokenAddress,      // sourceTokenAddress
                    address(0),             // destTokenAddress (address(0) == Ether)
                    receiver,               // receiver
                    tradeTokenAmountOwed,   // sourceTokenAmount
                    true                    // throwOnError
                );

                tradeTokenAmountOwed = destTokenAmountReceived;
            } else {
                IWethHelper wethHelper = IWethHelper(0x3b5bDCCDFA2a0a1911984F203C19628EeB6036e0);

                bool success = ERC20(_wethContract).transfer(
                    address(wethHelper),
                    tradeTokenAmountOwed
                );
                if (success) {
                    success = tradeTokenAmountOwed == wethHelper.claimEther(receiver, tradeTokenAmountOwed);
                }
                require(success, "transfer of ETH failed");
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
        uint256 minPriceAllowed,
        bytes memory loanDataBytes)
        public
        payable
        nonReentrant
        fixedSaneRate
        returns (uint256)
    {
        require(!burningPaused, "paused");
        (uint256 tradeTokenAmountOwed, uint256 currentPrice) = _burnToken(
            burnAmount,
            minPriceAllowed,
            loanDataBytes
        );
        if (tradeTokenAmountOwed != 0) {
            if (burnTokenAddress != tradeTokenAddress) {
                (uint256 destTokenAmountReceived,) = _tradeUserAsset(
                    tradeTokenAddress,      // sourceTokenAddress
                    burnTokenAddress,       // destTokenAddress
                    receiver,               // receiver
                    tradeTokenAmountOwed,   // sourceTokenAmount
                    true                    // throwOnError
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

    // Sends non-tradeToken and non-loanToken assets to the Oracle fund
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
            address _wethContract = wethContract;
            WETHInterface(_wethContract).deposit.value(balance)();
            token = _wethContract;
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

        if (balanceOf(_from) == 0) {
            checkpointPrices_[_from] = 0;
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

        if (balanceOf(msg.sender) == 0) {
            checkpointPrices_[msg.sender] = 0;
        }

        return true;
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
        address depositTokenAddress,
        uint256 depositAmount,
        uint256 rebalanceAmount,
        bytes memory loanDataBytes)
        public
        payable
        onlyOwner
        fixedSaneRate
    {
        if (depositTokenAddress == address(0)) {
            depositTokenAddress = tradeTokenAddress;
        }

        if (rebalanceAmount != 0 && msg.sender == owner) {
            IBZx(bZxContract).withdrawCollateral(
                loanOrderHash,
                rebalanceAmount
            );
        }

        uint256 beforeEtherBalance;
        if (msg.value != 0) {
            beforeEtherBalance = address(this).balance.sub(msg.value);
        }

        _triggerPosition(
            depositTokenAddress,
            depositAmount,
            loanDataBytes
    	);

        if (msg.value != 0) {
            uint256 afterEtherBalance = address(this).balance;
            if (afterEtherBalance > beforeEtherBalance) {
                (bool success,) = msg.sender.call.value(afterEtherBalance - beforeEtherBalance)("");
                require(success, "eth refund failed");
            }
        }
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
            (netCollateralAmount, interestDepositRemaining,,,) = IBZx(bZxContract).getTotalEscrowWithRate(
                loanOrderHash,
                address(this),
                0,
                0
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
        returns (uint256 value)
    {
        value = ILoanToken(loanTokenLender).getMaxEscrowAmount(leverageAmount);
    }

    function getMaxDepositAmount()
        public
        view
        returns (uint256 value)
    {
        value = ILoanToken(loanTokenLender).getMaxEscrowAmount(leverageAmount);

        if (!shortPosition) {
            (uint256 sourceToDestRate, uint256 sourceToDestPrecision,) = IBZxOracle(bZxOracle).getTradeData(
                loanTokenAddress,
                tradeTokenAddress,
                MAX_UINT // get best rate
            );
            value = value
                .mul(sourceToDestRate)
                .div(sourceToDestPrecision);
        }
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
        uint256 currentPrice,
        uint256 toCollateralRate,
        uint256 toCollateralPrecision,
        bytes memory loanDataBytes)
        internal
        onlyOwner
        returns (uint256)
    {
        if (depositTokenAddress != tradeTokenAddress && depositTokenAddress != loanTokenAddress) {
            (uint256 destTokenAmountReceived, uint256 depositAmountUsed) = _tradeUserAsset(
                depositTokenAddress,    // sourceTokenAddress
                tradeTokenAddress,      // destTokenAddress
                address(this),          // receiver
                depositAmount,          // sourceTokenAmount
                true                    // throwOnError
            );

            if (depositAmount > depositAmountUsed) {
                require(ERC20(depositTokenAddress).transfer(
                    msg.sender,
                    depositAmount-depositAmountUsed
                ), "transfer of token failed");
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
            depositAmount,
            loanDataBytes
        );

        // get post-entry supply
        (uint256 netCollateralAmount, uint256 interestDepositRemaining,,,) = IBZx(bZxContract).getTotalEscrowWithRate(
            loanOrderHash,
            address(this),
            toCollateralRate,
            toCollateralPrecision
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
        uint256 minPriceAllowed,
        bytes memory loanDataBytes)
        internal
        returns (uint256 tradeTokenAmountOwed, uint256 currentPrice)
    {
        require(burnAmount != 0, "burnAmount == 0");

        if (burnAmount > balanceOf(msg.sender)) {
            burnAmount = balanceOf(msg.sender);
        }

        IBZx _bZxContract = IBZx(bZxContract);

        (uint256 netCollateralAmount,
         uint256 interestDepositRemaining,
         ,
         uint256 toCollateralRate,
         uint256 toCollateralPrecision) = _bZxContract.getTotalEscrowWithRate(
            loanOrderHash,
            address(this),
            0,
            0
        );
        currentPrice = _tokenPrice(netCollateralAmount, interestDepositRemaining);

        if (minPriceAllowed != 0) {
            require(
                currentPrice >= minPriceAllowed,
                "price too low"
            );
        }

        tradeTokenAmountOwed = burnAmount
            .mul(currentPrice);
        tradeTokenAmountOwed = tradeTokenAmountOwed
            .div(tradeTokenAdjustment);

        uint256 tradeTokenAmountAvailableInContract = ERC20(tradeTokenAddress).balanceOf(address(this));

        uint256 preCloseEscrow = tradeTokenAmountAvailableInContract
            .add(netCollateralAmount);
        preCloseEscrow = preCloseEscrow
            .add(interestDepositRemaining);

        uint256 tmpValue;
        bool didCallWithdraw;
        if (tradeTokenAmountAvailableInContract < tradeTokenAmountOwed) {
            if (burnAmount < totalSupply()) {
                tmpValue = tradeTokenAmountOwed - tradeTokenAmountAvailableInContract;
            } else {
                tmpValue = MAX_UINT;
            }

            _closeLoanPartially(
                _bZxContract,
                loanOrderHash,
                tmpValue,
                loanDataBytes
            );
            tradeTokenAmountAvailableInContract = ERC20(tradeTokenAddress).balanceOf(address(this));
            didCallWithdraw = true;
        }

        if (tradeTokenAmountAvailableInContract < tradeTokenAmountOwed && burnAmount < totalSupply()) {
            tmpValue = tradeTokenAmountOwed - tradeTokenAmountAvailableInContract;
            uint256 collateralWithdrawn = _bZxContract.withdrawCollateral(
                loanOrderHash,
                tmpValue
            );
            if (collateralWithdrawn != 0) {
                tradeTokenAmountAvailableInContract = tradeTokenAmountAvailableInContract.add(collateralWithdrawn);
                didCallWithdraw = true;
            }
        }

        if (didCallWithdraw) {
            uint256 slippageLoss;
            if (burnAmount < totalSupply()) {
                (netCollateralAmount, interestDepositRemaining,,,) = _bZxContract.getTotalEscrowWithRate(
                    loanOrderHash,
                    address(this),
                    toCollateralRate,
                    toCollateralPrecision
                );
                uint256 postCloseEscrow = tradeTokenAmountAvailableInContract
                    .add(netCollateralAmount);
                postCloseEscrow = postCloseEscrow
                    .add(interestDepositRemaining);

                if (postCloseEscrow < preCloseEscrow) {
                    /*uint256 slippageLoss = tradeTokenAmountOwed
                        .mul(preCloseEscrow - postCloseEscrow)
                        .div(netCollateralAmount);*/
                    slippageLoss = preCloseEscrow - postCloseEscrow;

                    require(tradeTokenAmountOwed > slippageLoss, "slippage too great");
                    tradeTokenAmountOwed = tradeTokenAmountOwed - slippageLoss;
                }
            } else {
                netCollateralAmount = 0;
                interestDepositRemaining = 0;
            }

            if (tradeTokenAmountOwed > tradeTokenAmountAvailableInContract) {
                /*
                // allow at most 5% loss here
                slippageLoss = tradeTokenAmountOwed
                    .sub(tradeTokenAmountAvailableInContract);
                slippageLoss = slippageLoss
                    .mul(10**20);
                slippageLoss = slippageLoss
                    .div(tradeTokenAmountOwed);

                require(
                    slippageLoss <= (5 * 10**18),
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

        if (totalSupply() == 0 || _tokenPrice(netCollateralAmount, interestDepositRemaining) == 0) {
            splitFactor = 10**18;
            currentPrice = initialPrice;
        }

        if (balanceOf(msg.sender) != 0) {
            checkpointPrices_[msg.sender] = denormalize(currentPrice);
        } else {
            checkpointPrices_[msg.sender] = 0;
        }
    }

    function _closeLoanPartially(
        IBZx _bZxContract,
        bytes32 loanOrderHash,
        uint256 cloanAmount,
        bytes memory loanDataBytes)
        internal
    {
        // will revert if the position needs to be liquidated
        uint256 beforeEtherBalance;
        if (msg.value != 0) {
            beforeEtherBalance = address(this).balance.sub(msg.value);
        }
        _bZxContract.closeLoanPartiallyFromCollateral.value(msg.value)(
            loanOrderHash,
            cloanAmount,
            loanDataBytes
        );
        if (msg.value != 0) {
            uint256 afterEtherBalance = address(this).balance;
            if (afterEtherBalance > beforeEtherBalance) {
                (bool success,) = msg.sender.call.value(afterEtherBalance - beforeEtherBalance)("");
                require(success, "eth refund failed");
            }
        }
    }

    function _tradeUserAsset(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiver,
        uint256 sourceTokenAmount,
        bool throwOnError)
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

        (bool success, bytes memory data) = oracleAddress.call(
            abi.encodeWithSignature(
                "tradeUserAsset(address,address,address,address,uint256,uint256,uint256)",
                sourceTokenAddress,
                destTokenAddress,
                receiver, // receiverAddress
                receiver, // returnToSenderAddress
                sourceTokenAmount,
                MAX_UINT, // maxDestTokenAmount
                0 // minConversionRate
            )
        );
        require(!throwOnError || success, "trade error");
        assembly {
            if eq(success, 1) {
                destTokenAmountReceived := mload(add(data, 32))
                sourceTokenAmountUsed := mload(add(data, 64))
            }
        }
    }

    function _triggerPosition(
        address depositTokenAddress,
        uint256 depositAmount,
        bytes memory loanDataBytes)
        internal
    {
        uint256 tradeTokenDeposit = ERC20(tradeTokenAddress).balanceOf(address(this));
        uint256 loanTokenDeposit = ERC20(loanTokenAddress).balanceOf(address(this));

        if (loanTokenDeposit != 0 || tradeTokenDeposit != 0) {
            if (depositTokenAddress == tradeTokenAddress) {
                if (depositAmount == 0 || depositAmount > tradeTokenDeposit) {
                    loanTokenDeposit = loanTokenDeposit;
                    depositAmount = tradeTokenDeposit;
                } else {
                    loanTokenDeposit = 0;
                    tradeTokenDeposit = depositAmount;
                }
            } else if (depositTokenAddress == loanTokenAddress) {
                if (depositAmount == 0 || depositAmount > loanTokenDeposit) {
                    tradeTokenDeposit = tradeTokenDeposit;
                    depositAmount = loanTokenDeposit;
                } else {
                    loanTokenDeposit = depositAmount;
                    tradeTokenDeposit = 0;
                }
            } else {
                revert("invalid deposit");
            }

            uint256 msgValue;
            if (msg.value != 0) {
                msgValue = address(this).balance;
                if (msgValue > msg.value) {
                    msgValue = msg.value;
                }
            }
            ILoanToken(loanTokenLender).marginTradeFromDeposit.value(msgValue)(
                depositAmount,          // depositAmount
                leverageAmount,         // leverageAmount
                loanTokenDeposit,       // loanTokenSent
                tradeTokenDeposit,      // collateralTokenSent
                0,                      // tradeTokenSent
                address(this),          // trader
                depositTokenAddress,    // depositTokenAddress
                tradeTokenAddress,      // collateralTokenAddress
                tradeTokenAddress,      // tradeTokenAddress
                loanDataBytes           // loanDataBytes
            );
        }
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

    function updateSettings(
        address settingsTarget,
        bytes memory callData)
        public
    {
        if (msg.sender != owner) {
            address _lowerAdmin;
            address _lowerAdminContract;

            //keccak256("pToken_LowerAdminAddress")
            //keccak256("pToken_LowerAdminContract")
            assembly {
                _lowerAdmin := sload(0x4d9d6037d7e53fa4549f7e532571af3aa103c886a59baf156ebf80c2b3b99b6e)
                _lowerAdminContract := sload(0x544cf74df6879599b75c5fbe7afeb236fc89a80fffaa97fdb08f1e24886a2491)
            }
            require(msg.sender == _lowerAdmin && settingsTarget == _lowerAdminContract);
        }

        address currentTarget = target_;
        target_ = settingsTarget;

        (bool result,) = address(this).call(callData);

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