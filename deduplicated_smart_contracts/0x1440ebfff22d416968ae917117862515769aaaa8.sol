/**

 *Submitted for verification at Etherscan.io on 2019-06-11

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

 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>

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



        balances[_who] = normalize(whoBalance.sub(_tokenAmount));

        if (balances[_who] <= 10 || balanceOf(_who) <= 10) { // we can't leave such small balance quantities

            _tokenAmount = _tokenAmount.add(denormalize(balances[_who]));

            balances[_who] = 0;

        }



        totalSupply_ = normalize(denormalize(totalSupply_).sub(_tokenAmount));

        if (totalSupply() == 0) {

            totalSupply_ = 0;

            balances[_who] = 0;

        }



        emit Burn(_who, _tokenAmount, _assetAmount, _price);

        emit Transfer(_who, address(0), _tokenAmount);

    }

}



interface IBZx {

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



    function updateLoanAsLender(

        bytes32 loanOrderHash,

        uint256 increaseAmountForLoan,

        uint256 newInterestRate,

        uint256 newExpirationTimestamp)

        external

        returns (bool);



    function takeLoanOrderOnChainAsTraderByDelegate(

        address trader,

        bytes32 loanOrderHash,

        address collateralTokenFilled,

        uint256 loanTokenAmountFilled,

        address tradeTokenToFillAddress,

        bool withdrawOnOpen)

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



    function depositPosition(

        bytes32 loanOrderHash,

        address depositTokenAddress,

        uint256 depositAmount)

        external

        returns (bool);



    function closeLoanPartially(

        bytes32 loanOrderHash,

        uint256 closeAmount)

        external

        returns (uint256 actualCloseAmount);



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



    function shouldLiquidate(

        bytes32 loanOrderHash,

        address trader)

        external

        view

        returns (bool);



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



    function interestFeePercent()

        external

        view

        returns (uint256);

}



interface ILoanToken {

    function getMaxEscrowAmount(

        uint256 leverageAmount)

        external

        view

        returns (uint256);

}



contract PositionTokenLogic is SplittableToken {

    using SafeMath for uint256;





    function()

        external

        payable

    {}





    /* Public functions */



    // returns the amount of token minted

    function mintWithEther(

        address receiver)

        external

        payable

        nonReentrant

        returns (uint256)

    {

        require (msg.value > 0, "msg.value == 0");



        uint256 currentPrice = tokenPrice();



        WETHInterface(wethContract).deposit.value(msg.value)();



        return _mintWithToken(

            receiver,

            wethContract,

            msg.value,

            currentPrice

        );

    }



    // returns the amount of token minted

    function mintWithToken(

        address receiver,

        address depositTokenAddress,

        uint256 depositAmount)

        external

        nonReentrant

        returns (uint256)

    {

        require (depositAmount > 0, "depositAmount == 0");



        uint256 currentPrice = tokenPrice();



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

        uint256 burnAmount)

        external

        nonReentrant

        returns (uint256)

    {

        uint256 loanAmountOwed = _burnToken(burnAmount);

        if (loanAmountOwed > 0) {

            if (wethContract != loanTokenAddress) {

                address oracle = IBZx(bZxContract).oracleAddresses(bZxOracle);

                uint256 tempAllowance = ERC20(loanTokenAddress).allowance(address(this), oracle);

                if (tempAllowance < loanAmountOwed) {

                    if (tempAllowance > 0) {

                        // reset approval to 0

                        require(ERC20(loanTokenAddress).approve(oracle, 0), "token approval reset failed");

                    }



                    require(ERC20(loanTokenAddress).approve(oracle, MAX_UINT), "token approval failed");

                }



                (uint256 destTokenAmountReceived,) = IBZxOracle(oracle).tradeUserAsset(

                    loanTokenAddress,

                    address(0), // Ether

                    receiver, // receiverAddress

                    receiver, // returnToSenderAddress

                    loanAmountOwed,

                    MAX_UINT,

                    0 // minConversionRate

                );



                loanAmountOwed = destTokenAmountReceived;

            } else {

                WETHInterface(wethContract).withdraw(loanAmountOwed);

                require(receiver.send(loanAmountOwed), "transfer of ETH failed");

            }

        }



        return loanAmountOwed;

    }



    function burnToToken(

        address receiver,

        address burnTokenAddress,

        uint256 burnAmount)

        external

        nonReentrant

        returns (uint256)

    {

        uint256 loanAmountOwed = _burnToken(burnAmount);

        if (loanAmountOwed > 0) {

            if (burnTokenAddress != loanTokenAddress) {

                address oracle = IBZx(bZxContract).oracleAddresses(bZxOracle);

                uint256 tempAllowance = ERC20(loanTokenAddress).allowance(address(this), oracle);

                if (tempAllowance < loanAmountOwed) {

                    if (tempAllowance > 0) {

                        // reset approval to 0

                        require(ERC20(loanTokenAddress).approve(oracle, 0), "token approval reset failed");

                    }



                    require(ERC20(loanTokenAddress).approve(oracle, MAX_UINT), "token approval failed");

                }



                (uint256 destTokenAmountReceived,) = IBZxOracle(oracle).tradeUserAsset(

                    loanTokenAddress,

                    burnTokenAddress,

                    receiver, // receiverAddress

                    receiver, // returnToSenderAddress

                    loanAmountOwed,

                    MAX_UINT,

                    0 // minConversionRate

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



    function triggerPosition()

        external

        nonReentrant

    {

        require(_triggerPosition(), "triggerPosition failed");

    }



    function wrapEther()

        external

        nonReentrant

    {

        if (address(this).balance > 0) {

            WETHInterface(wethContract).deposit.value(address(this).balance)();

        }

    }



    // Sends non-LoanToken assets to the Oracle fund

    // These are assets that would otherwise be "stuck" due to a user accidently sending them to the contract

    function donateAsset(

        address tokenAddress)

        external

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

        if (balanceOf(_from) > 0) {

            checkpointPrices_[_from] = currentPrice;

        } else {

            checkpointPrices_[_from] = 0;

        }

        if (balanceOf(_to) > 0) {

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

        if (balanceOf(msg.sender) > 0) {

            checkpointPrices_[msg.sender] = currentPrice;

        } else {

            checkpointPrices_[msg.sender] = 0;

        }

        if (balanceOf(_to) > 0) {

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

        uint256 netCollateralAmount = 0;

        uint256 interestDepositRemaining = 0;

        if (totalSupply() > 0) {

            (netCollateralAmount, interestDepositRemaining,) = IBZx(bZxContract).getTotalEscrow(

                loanOrderHash,

                address(this));

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



    function marketLiquidityForAsset()

        public

        view

        returns (uint256)

    {

        return ILoanToken(loanTokenLender).getMaxEscrowAmount(leverageAmount);

    }



    function marketLiquidityForToken()

        public

        view

        returns (uint256)

    {

        return ILoanToken(loanTokenLender).getMaxEscrowAmount(leverageAmount)

            .mul(10**18)

            .div(tokenPrice());

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



    // returns the amount of token minted

    function _mintWithToken(

        address receiver,

        address depositTokenAddress,

        uint256 depositAmount,

        uint256 currentPrice)

        internal

        returns (uint256)

    {

        uint256 liquidityAmount = marketLiquidityForAsset();

        require(liquidityAmount > 0, "marketLiquidity == 0");



        uint256 refundAmount;

        if (depositTokenAddress != loanTokenAddress) {

            address oracle = IBZx(bZxContract).oracleAddresses(bZxOracle);

            uint256 tempAllowance = ERC20(depositTokenAddress).allowance(address(this), oracle);

            if (tempAllowance < depositAmount) {

                if (tempAllowance > 0) {

                    // reset approval to 0

                    require(ERC20(depositTokenAddress).approve(oracle, 0), "token approval reset failed");

                }



                require(ERC20(depositTokenAddress).approve(oracle, MAX_UINT), "token approval failed");

            }



            (uint256 destTokenAmountReceived, uint256 depositAmountUsed) = IBZxOracle(oracle).tradeUserAsset(

                depositTokenAddress,

                loanTokenAddress,

                address(this), // receiverAddress

                address(this), // returnToSenderAddress

                depositAmount,

                MAX_UINT,

                0 // minConversionRate

            );



            require(destTokenAmountReceived <= liquidityAmount, "market liquidity insufficient");



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

        } else if (depositAmount > liquidityAmount) {

            refundAmount = depositAmount-liquidityAmount;

            if (msg.value == 0) {

                require(ERC20(loanTokenAddress).transfer(

                    msg.sender,

                    refundAmount

                ), "transfer of token failed");

            } else {

                WETHInterface(wethContract).withdraw(refundAmount);

                require(msg.sender.send(refundAmount), "transfer of ETH failed");

            }

            depositAmount = liquidityAmount;

        }



        // depositAmount must be >= 0.001 loanToken units

        require(depositAmount >= (10**15 * 10**uint256(decimals) / 10**18), "depositAmount too low");



        require(_triggerPosition(), "triggerPosition failed");



        // check slippage for user

        uint256 totalSupplyBackup = totalSupply_;



        uint256 mintAmount = depositAmount

            .mul(10**18)

           .div(currentPrice);

        totalSupply_ = normalize(denormalize(totalSupply_).add(mintAmount));



        uint256 slippagePrice = tokenPrice();   // price with slipapge

        totalSupply_ = totalSupplyBackup;       // reset totalSupply



        if (slippagePrice != currentPrice) {

            mintAmount = slippagePrice

                .mul(mintAmount)

                .div(currentPrice);

        }



        require(mintAmount > 0 && depositAmount > 0, "market liquidity insufficient");

        _mint(receiver, mintAmount, depositAmount, currentPrice);



        checkpointPrices_[receiver] = denormalize(currentPrice);



        return mintAmount;

    }



    function _burnToken(

        uint256 burnAmount)

        internal

        returns (uint256)

    {

        require(burnAmount > 0, "burnAmount == 0");



        if (burnAmount > balanceOf(msg.sender)) {

            burnAmount = balanceOf(msg.sender);

        }



        (uint256 netCollateralAmount, uint256 interestDepositRemaining, uint256 loanTokenAmountBorrowed) = IBZx(bZxContract).getTotalEscrow(

            loanOrderHash,

            address(this));

        uint256 currentPrice = _tokenPrice(netCollateralAmount, interestDepositRemaining);



        uint256 loanAmountOwed = burnAmount

            .mul(currentPrice)

            .div(10**18);



        uint256 loanAmountAvailableInContract = ERC20(loanTokenAddress).balanceOf(address(this));



        if (loanAmountAvailableInContract < loanAmountOwed) {

            loanAmountAvailableInContract = loanAmountAvailableInContract.add(

                IBZx(bZxContract).withdrawCollateral(

                    loanOrderHash,

                    loanAmountOwed.sub(loanAmountAvailableInContract)

                )

            );

        }



        if (loanAmountAvailableInContract < loanAmountOwed) {

            uint256 closeAmount;

            if (burnAmount < totalSupply()) {

                closeAmount = loanAmountOwed

                    .sub(loanAmountAvailableInContract)

                    .mul(loanTokenAmountBorrowed)

                    .div(netCollateralAmount

                        .add(interestDepositRemaining));

            } else {

                // close entire loan

                closeAmount = MAX_UINT;

            }



            IBZx(bZxContract).closeLoanPartially(

                loanOrderHash,

                closeAmount

            );



            loanAmountAvailableInContract = ERC20(loanTokenAddress).balanceOf(address(this));

            if (loanAmountAvailableInContract < loanAmountOwed) {

                if (loanAmountOwed-loanAmountAvailableInContract > 100) {

                    // If the loan isn't being fully closed and some locked collateral is still held,

                    // possibly due to a liquidation requirement, than we reduce the amount of token

                    // being burnt.

                    if (closeAmount < MAX_UINT) {

                        burnAmount = loanAmountAvailableInContract

                            .mul(10**18)

                            .div(currentPrice);

                    }

                }



                loanAmountOwed = loanAmountAvailableInContract;

            }

        }



        require(burnAmount > 0 && loanAmountOwed > 0, "market liquidity insufficient");



        // unless burning the full balance, loanAmountOwed must be >= 0.001 loanToken units

        require(burnAmount == balanceOf(msg.sender) || loanAmountOwed >= (10**15 * 10**uint256(decimals) / 10**18), "burnAmount too low");



        _burn(msg.sender, burnAmount, loanAmountOwed, currentPrice);



        if (totalSupply() == 0 || tokenPrice() == 0) {

            splitFactor = 10**18;

            currentPrice = initialPrice;

        }



        if (balanceOf(msg.sender) > 0) {

            checkpointPrices_[msg.sender] = denormalize(currentPrice);

        } else {

            checkpointPrices_[msg.sender] = 0;

        }



        return loanAmountOwed;

    }



    function _triggerPosition()

        internal

        returns (bool)

    {

        uint256 assetBalance = ERC20(loanTokenAddress).balanceOf(address(this));

        if (assetBalance > 0) {

            uint256 tempAllowance = ERC20(loanTokenAddress).allowance(address(this), bZxVault);

            if (tempAllowance < assetBalance) {

                if (tempAllowance > 0) {

                    // reset approval to 0

                    require(ERC20(loanTokenAddress).approve(bZxVault, 0), "token approval reset failed");

                }



                require(ERC20(loanTokenAddress).approve(bZxVault, MAX_UINT), "token approval failed");

            }



            (bool result,) = loanTokenLender.call.gas(gasleft())(

                abi.encodeWithSignature(

                    "borrowTokenFromEscrow(uint256,uint256,address,bool)",

                    assetBalance,

                    leverageAmount,

                    tradeTokenAddress,

                    false

                )

            );

            return result;

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

        return totalSupply_ > 0 ?

            normalize(

                ERC20(loanTokenAddress).balanceOf(address(this))

                .add(netCollateralAmount)

                .add(interestDepositRemaining)

                .mul(10**18)

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



    function setWETHContract(

        address _addr)

        public

        onlyOwner

    {

        wethContract = _addr;

    }



    function setLoanTokenAddress(

        address _addr)

        public

        onlyOwner

    {

        loanTokenAddress = _addr;

    }



    function setTradeTokenAddress(

        address _addr)

        public

        onlyOwner

    {

        tradeTokenAddress = _addr;

    }



    function setInitialPrice(

        uint256 _value)

        public

        onlyOwner

    {

        require(_value > 0, "value can't be 0");

        initialPrice = _value;

    }



    function setSplitValue(

        uint256 _value)

        public

        onlyOwner

    {

        require(_value > 0, "value can't be 0");

        splitFactor = _value;

    }



    function handleSplit()

        public

        onlyOwner

    {

        if (totalSupply() > 0) {

            splitFactor = splitFactor

                .mul(initialPrice)

                .div(

                    tokenPrice()

                );

        } else {

            splitFactor = 10**18;

        }

    }



    // depositTokenAddress is swapped to loanTokenAddress if needed in the protocol

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

            if (tempAllowance > 0) {

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



    // depositTokenAddress is swapped to tradeTokenAddress if needed in the protocol

    // this is callable by anyone that wants to top up the position

    function depositPositionToLoan(

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

            if (tempAllowance > 0) {

                // reset approval to 0

                require(ERC20(depositTokenAddress).approve(bZxVault, 0), "token approval reset failed");

            }



            require(ERC20(depositTokenAddress).approve(bZxVault, MAX_UINT), "token approval failed");

        }



        require(IBZx(bZxContract).depositPosition(

            loanOrderHash,

            depositTokenAddress,

            depositAmount

        ), "deposit failed");

    }



    function initialize(

        address _bZxContract,

        address _bZxVault,

        address _bZxOracle,

        address _wethContract,

        address _loanTokenAddress,

        address _tradeTokenAddress,

        address _lender,

        uint256 _leverageAmount,

        bytes32 _loanOrderHash,

        string memory _name,

        string memory _symbol)

        public

        onlyOwner

    {

        require (!isInitialized_, "already initialized");



        bZxContract = _bZxContract;

        bZxVault = _bZxVault;

        bZxOracle = _bZxOracle;

        wethContract = _wethContract;

        loanTokenAddress = _loanTokenAddress;

        tradeTokenAddress = _tradeTokenAddress;

        loanTokenLender = _lender;



        loanOrderHash = _loanOrderHash;

        leverageAmount = _leverageAmount;



        name = _name;

        symbol = _symbol;

        decimals = EIP20(loanTokenAddress).decimals();



        initialPrice = 10**21; // starting price of 1,000



        // set the BZxVault spend approval

        require(ERC20(_loanTokenAddress).approve(_bZxVault, MAX_UINT), "approval of loan token failed");



        isInitialized_ = true;

    }

}