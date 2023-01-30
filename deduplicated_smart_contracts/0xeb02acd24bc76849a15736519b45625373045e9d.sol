/**
 *Submitted for verification at Etherscan.io on 2019-12-06
*/

/**
 * Copyright 2017-2019, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.8;


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

contract ENSLoanRepayStorage is Ownable {
    uint256 internal constant MAX_UINT = 2**256 - 1;

    address public bZxContract;
    address public bZxVault;
    address public loanTokenLender;
    address public loanTokenAddress;
    address public wethContract;

    address public ensLoanOwner;

    address public userContractRegistry;
}

interface IBZx {
    function paybackLoanAndClose(
        bytes32 loanOrderHash,
        address borrower,
        address payer,
        address receiver,
        uint256 closeAmount)
        external
        returns (
            uint256 actualCloseAmount,
            uint256 collateralCloseAmount,
            address collateralTokenAddress
        );
}

interface ILoanToken {
    function loanOrderHashes(
        uint256 leverageAmount)
        external
        view
        returns (bytes32 loanOrderHash);
}

interface iBasicToken {
    function transfer(
        address to,
        uint256 value)
        external
        returns (bool);

    function approve(
        address spender,
        uint256 value)
        external
        returns (bool);

    function balanceOf(
        address user)
        external
        view
        returns (uint256 balance);

    function allowance(
        address owner,
        address spender)
        external
        view
        returns (uint256 value);
}

interface IWethHelper {
    function claimEther(
        address receiver,
        uint256 amount)
        external
        returns (uint256 claimAmount);
}

interface iUserContract {
    function transferAsset(
        address asset,
        address payable to,
        uint256 amount)
        external
        returns (uint256 transferAmount);
}

interface iUserContractRegistry {
    function userContracts(
        address user)
        external
        view
        returns (iUserContract);
}

contract ENSLoanRepayLogic is ENSLoanRepayStorage {
    using SafeMath for uint256;

    function()
        external
        payable
    {
        if (msg.sender == wethContract) {
            return;
        }
        require(msg.value == 0, "no eth allowed");

        iUserContract userContract = iUserContractRegistry(userContractRegistry).userContracts(msg.sender);
        require(address(userContract) != address(0), "contract not found");

        uint256 beforeBalance = iBasicToken(loanTokenAddress).balanceOf(address(this));

        uint256 transferAmount = userContract.transferAsset(
            loanTokenAddress,
            address(uint256(address(this))),
            0
        );
        //require(transferAmount != 0, "no deposit"); <-- allow no deposit

        bytes32 loanOrderHash = ILoanToken(loanTokenLender).loanOrderHashes(
            26985473425953342135791518606717287597326611559540027600454822645050577529548 // uint256(keccak256(abi.encodePacked(2 ether, wethContract)))
        );
        require(loanOrderHash != 0, "invalid hash");

        (uint256 actualCloseAmount, uint256 collateralCloseAmount, address collateralTokenAddress) = IBZx(bZxContract).paybackLoanAndClose(
            loanOrderHash,
            msg.sender,        // borrower
            address(this),     // payer
            address(this),     // receiver
            transferAmount     // closeAmount
        );
        require(actualCloseAmount != 0, "loan not closed");

        if (collateralCloseAmount != 0) {
            if (collateralTokenAddress == wethContract) {
                IWethHelper wethHelper = IWethHelper(0x3b5bDCCDFA2a0a1911984F203C19628EeB6036e0);

                iBasicToken(collateralTokenAddress).transfer(
                    address(wethHelper),
                    collateralCloseAmount
                );

                require(collateralCloseAmount == wethHelper.claimEther(msg.sender, collateralCloseAmount),
                    "eth transfer failed"
                );
            } else {
                iBasicToken(collateralTokenAddress).transfer(
                    msg.sender,
                    collateralCloseAmount
                );
            }
        }

        uint256 afterBalance = iBasicToken(loanTokenAddress).balanceOf(address(this));

        if (afterBalance > beforeBalance) {
            iBasicToken(loanTokenAddress).transfer(
                msg.sender,
                afterBalance - beforeBalance
            );
        } else if (afterBalance < beforeBalance) {
            revert("too much spent");
        }

        assembly {
            mstore(0, actualCloseAmount)
            return(0, 32)
        }
    }

    function initialize(
        address _bZxContract,
        address _bZxVault,
        address _loanTokenLender,
        address _loanTokenAddress,
        address _userContractRegistry,
        address _wethContract,
        address _ensLoanOwner)
        public
        onlyOwner
    {
        bZxContract = _bZxContract;
        bZxVault = _bZxVault;
        loanTokenLender = _loanTokenLender;
        loanTokenAddress = _loanTokenAddress;
        userContractRegistry = _userContractRegistry;
        wethContract = _wethContract;
        ensLoanOwner = _ensLoanOwner;

        iBasicToken token = iBasicToken(loanTokenAddress);
        uint256 tempAllowance = token.allowance(address(this), bZxVault);
        if (tempAllowance != MAX_UINT) {
            if (tempAllowance != 0) {
                // reset approval to 0
                require(token.approve(bZxVault, 0), "token approval reset failed");
            }

            require(token.approve(bZxVault, MAX_UINT), "token approval failed");
        }
    }

    function recoverEther(
        address receiver,
        uint256 amount)
        public
        onlyOwner
    {
        uint256 balance = address(this).balance;
        if (balance < amount)
            amount = balance;

        (bool success, ) = receiver.call.value(amount)("");
        require(success, "transfer failed");
    }

    function recoverToken(
        address tokenAddress,
        address receiver,
        uint256 amount)
        public
        onlyOwner
    {
        iBasicToken token = iBasicToken(tokenAddress);

        uint256 balance = token.balanceOf(address(this));
        if (balance < amount)
            amount = balance;

        require(token.transfer(
            receiver,
            amount),
            "transfer failed"
        );
    }
}