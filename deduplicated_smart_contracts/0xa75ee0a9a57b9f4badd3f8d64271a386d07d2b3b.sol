/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

/**
 * Copyright 2017-2020, bZeroX, LLC. All Rights Reserved.
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

contract PositionTokenStorage is LoanTokenization {

    bool internal isInitialized_ = false;

    address public loanTokenLender;
    address public tradeTokenAddress;

    uint256 public leverageAmount;
    bytes32 public loanOrderHash;

    uint256 public initialPrice;
}

contract SplittableTokenStorage is PositionTokenStorage {
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

contract SplittableToken is SplittableTokenStorage {
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
        uint256 _tokenAmount,
        uint256 _assetAmount,
        uint256 _price)
        internal
    {
        require(_to != address(0), "invalid address");
        totalSupply_ = normalize(denormalize(totalSupply_).add(_tokenAmount));
        balances[_to] = normalize(denormalize(balances[_to]).add(_tokenAmount));

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

        emit Burn(_who, _tokenAmount, _assetAmount, _price);
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
}

interface IWethHelper {
    function claimEther(
        address receiver,
        uint256 amount)
        external
        returns (uint256 claimAmount);
}

contract PositionTokenLogic is SplittableToken {
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

    function burnToEther(
        address receiver,
        uint256 burnAmount,
        uint256 minPriceAllowed)
        external
        nonReentrant
        fixedSaneRate
        returns (uint256)
    {
        require(msg.sender == tx.origin, "no contract calls");
        uint256 loanAmountOwed = _burnToken(burnAmount, minPriceAllowed);
        if (loanAmountOwed != 0) {
            if (wethContract != loanTokenAddress) {
                (uint256 destTokenAmountReceived,) = _tradeUserAsset(
                    loanTokenAddress,   // sourceTokenAddress
                    address(0),         // destTokenAddress
                    receiver,           // receiver
                    loanAmountOwed,     // sourceTokenAmount
                    true                // throwOnError
                );

                loanAmountOwed = destTokenAmountReceived;
            } else {
                IWethHelper wethHelper = IWethHelper(0x3b5bDCCDFA2a0a1911984F203C19628EeB6036e0);

                bool success = ERC20(wethContract).transfer(
                    address(wethHelper),
                    loanAmountOwed
                );
                if (success) {
                    success = loanAmountOwed == wethHelper.claimEther(receiver, loanAmountOwed);
                }
                require(success, "transfer of ETH failed");
            }
        }

        return loanAmountOwed;
    }

    function burnToToken(
        address receiver,
        address burnTokenAddress,
        uint256 burnAmount,
        uint256 minPriceAllowed)
        external
        nonReentrant
        fixedSaneRate
        returns (uint256)
    {
        require(msg.sender == tx.origin, "no contract calls");
        uint256 loanAmountOwed = _burnToken(burnAmount, minPriceAllowed);
        if (loanAmountOwed != 0) {
            if (burnTokenAddress != loanTokenAddress) {
                (uint256 destTokenAmountReceived,) = _tradeUserAsset(
                    loanTokenAddress,   // sourceTokenAddress
                    burnTokenAddress,   // destTokenAddress
                    receiver,           // receiver
                    loanAmountOwed,     // sourceTokenAmount
                    true                // throwOnError
                );

                loanAmountOwed = destTokenAmountReceived;
            } else {
                require(ERC20(loanTokenAddress).transfer(
                    receiver,
                    loanAmountOwed
                ), "transfer of loanToken failed");
            }
        }

        return loanAmountOwed;
    }

    function wrapEther()
        external
        nonReentrant
    {
        if (address(this).balance != 0) {
            WETHInterface(wethContract).deposit.value(address(this).balance)();
        }
    }

    // Sends non-LoanToken assets to the Oracle fund
    // These are assets that would otherwise be "stuck" due to a user accidently sending them to the contract
    function donateAsset(
        address tokenAddress)
        external
        onlyOwner
        nonReentrant
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

    function depositCollateralToLoan(
        uint256 depositAmount)
        external
        nonReentrant
    {
        require(msg.sender == tx.origin, "no contract calls");
        require(ERC20(loanTokenAddress).transferFrom(
            msg.sender,
            address(this),
            depositAmount
        ), "transfer of token failed");

        uint256 tempAllowance = ERC20(loanTokenAddress).allowance(address(this), bZxVault);
        if (tempAllowance < depositAmount) {
            if (tempAllowance != 0) {
                // reset approval to 0
                require(ERC20(loanTokenAddress).approve(bZxVault, 0), "token approval reset failed");
            }

            require(ERC20(loanTokenAddress).approve(bZxVault, MAX_UINT), "token approval failed");
        }

        require(IBZx(bZxContract).depositCollateral(
            loanOrderHash,
            loanTokenAddress,
            depositAmount
        ), "deposit failed");
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
        (,uint256 maintenanceMarginAmount,uint256 currentMarginAmount) = IBZx(bZxContract).getMarginLevels(
            loanOrderHash,
            address(this));

        if (maintenanceMarginAmount == 0)
            return 0;
        else if (currentMarginAmount <= maintenanceMarginAmount)
            return tokenPrice();

        return tokenPrice()
            .mul(maintenanceMarginAmount)
            .div(currentMarginAmount);
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


    /* Internal functions */

    function _burnToken(
        uint256 burnAmount,
        uint256 minPriceAllowed)
        internal
        returns (uint256)
    {
        require(burnAmount != 0, "burnAmount == 0");

        if (burnAmount > balanceOf(msg.sender)) {
            burnAmount = balanceOf(msg.sender);
        }

        (uint256 netCollateralAmount,
         uint256 interestDepositRemaining,
         ,
         uint256 toCollateralRate,
         uint256 toCollateralPrecision) = IBZx(bZxContract).getTotalEscrowWithRate(
            loanOrderHash,
            address(this),
            0,
            0
        );
        uint256 currentPrice = _tokenPrice(netCollateralAmount, interestDepositRemaining);

        if (minPriceAllowed != 0) {
            require(
                currentPrice >= minPriceAllowed,
                "price too low"
            );
        }

        uint256 loanAmountOwed = burnAmount
            .mul(currentPrice)
            .div(10**18);

        uint256 loanAmountAvailableInContract = ERC20(loanTokenAddress).balanceOf(address(this));

        uint256 preCloseEscrow = loanAmountAvailableInContract
            .add(netCollateralAmount)
            .add(interestDepositRemaining);

        bool didCallWithdraw;
        if (loanAmountAvailableInContract < loanAmountOwed) {
            // will revert if the position needs to be liquidated
            IBZx(bZxContract).closeLoanPartiallyFromCollateral(
                loanOrderHash,
                burnAmount < totalSupply() ?
                    loanAmountOwed.sub(loanAmountAvailableInContract) :
                    MAX_UINT
            );

            loanAmountAvailableInContract = ERC20(loanTokenAddress).balanceOf(address(this));
            didCallWithdraw = true;
        }

        if (loanAmountAvailableInContract < loanAmountOwed && burnAmount < totalSupply()) {
            uint256 collateralWithdrawn = IBZx(bZxContract).withdrawCollateral(
                loanOrderHash,
                loanAmountOwed.sub(loanAmountAvailableInContract)
            );
            if (collateralWithdrawn != 0) {
                loanAmountAvailableInContract = loanAmountAvailableInContract.add(collateralWithdrawn);
                didCallWithdraw = true;
            }
        }

        if (didCallWithdraw) {
            if (burnAmount < totalSupply()) {
                (netCollateralAmount, interestDepositRemaining,,,) = IBZx(bZxContract).getTotalEscrowWithRate(
                    loanOrderHash,
                    address(this),
                    toCollateralRate,
                    toCollateralPrecision
                );
                uint256 postCloseEscrow = loanAmountAvailableInContract
                    .add(netCollateralAmount)
                    .add(interestDepositRemaining);

                if (postCloseEscrow < preCloseEscrow) {
                    /*uint256 slippageLoss = loanAmountOwed
                        .mul(preCloseEscrow - postCloseEscrow)
                        .div(netCollateralAmount);*/
                    uint256 slippageLoss = preCloseEscrow - postCloseEscrow;

                    require(loanAmountOwed > slippageLoss, "slippage too great");
                    loanAmountOwed = loanAmountOwed - slippageLoss;
                }
            }

            if (loanAmountOwed > loanAmountAvailableInContract) {
                /*
                // allow at most 5% loss here
                require(
                    loanAmountOwed
                    .sub(loanAmountAvailableInContract)
                    .mul(10**20)
                    .div(loanAmountOwed) <= (5 * 10**18),
                    "contract value too low"
                );
                */
                loanAmountOwed = loanAmountAvailableInContract;
            }
        }

        // unless burning the full balance, loanAmountOwed must be >= 0.001 loanToken units
        //require(burnAmount == balanceOf(msg.sender) || loanAmountOwed >= (10**15 * 10**uint256(decimals) / 10**18), "burnAmount too low");

        _burn(msg.sender, burnAmount, loanAmountOwed, currentPrice);

        if (totalSupply() == 0 || tokenPrice() == 0) {
            splitFactor = 10**18;
            currentPrice = initialPrice;
        }

        if (balanceOf(msg.sender) != 0) {
            checkpointPrices_[msg.sender] = denormalize(currentPrice);
        } else {
            checkpointPrices_[msg.sender] = 0;
        }

        return loanAmountOwed;
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
                ERC20(loanTokenAddress).balanceOf(address(this))
                .add(netCollateralAmount)
                .add(interestDepositRemaining)
                .mul(10**18)
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