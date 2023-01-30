/**
 *Submitted for verification at Etherscan.io on 2019-09-17
*/

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMathLibrary {
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
 * @title IERC20Token
 * @dev Standard ERC-20 interface used to interact with BIDL.
 */
interface IERC20Token {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title DistributionPool
 * @dev Contract used to lock investor's ETH and distribute the BIDL tokens.
 */
contract DistributionPool {
    
    using SafeMathLibrary for uint256;
    
    event WeiPerBIDL(uint256 value);
    event Activated();
    event Unlock(uint256 amountBIDL, uint256 amountWei);
    
    // Reference variable to a BIDL smart contract.
    IERC20Token private _bidlToken;
    
    // Pool participant address.
    address payable private _poolParticipant;
    
    // Authorized Blockbid adminisrator.
    address private _blockbidAdmin; //0x8bfbaf7F61946a847E8740970b93B95096F95867;
    
    // Amount of ETH that will be unlocked per each BIDL released.
    uint256 private _weiPerBidl = (100 * 1e18) / (1000000 * 1e2);
    
    // Maximum amount of staked ETH (in wei units).
    uint256 private _maxBalanceWei = 1000 ether;
    
    // Turns on the ability of the contract to unlock BIDL tokens and ETH.
    bool private _activated = false;
    
    modifier onlyBlockbidAdmin() {
        require(_blockbidAdmin == msg.sender);
        _;
    }
    
    modifier onlyWhenActivated() {
        require(_activated);
        _;
    }

    function bidlToken() public view returns (IERC20Token) {
        return _bidlToken;
    }

    function poolParticipant() public view returns (address) {
        return _poolParticipant;
    }

    function blockbidAdmin() public view returns (address) {
        return _blockbidAdmin;
    }

    function weiPerBidl() public view returns (uint256) {
        return _weiPerBidl;
    }

    function maxBalanceWei() public view returns (uint256) {
        return _maxBalanceWei;
    }

    function isActivated() public view returns (bool) {
        return _activated;
    }
    
    function setWeiPerBIDL(uint256 value) public onlyBlockbidAdmin {
        _weiPerBidl = value;  
        emit WeiPerBIDL(value);
    }

    // Used by Blockbid admin to calculate amount of BIDL to deposit in the contract.
    function admin_getBidlAmountToDeposit() public view returns (uint256) {
        uint256 weiBalance = address(this).balance;
        uint256 bidlAmountSupposedToLock = weiBalance / _weiPerBidl;
        uint256 bidlBalance = _bidlToken.balanceOf(address(this));
        if (bidlAmountSupposedToLock < bidlBalance) {
            return 0;
        }
        return bidlAmountSupposedToLock - bidlBalance;
    }
    
    // Called by Blockbid admin to release the ETH and part of the BIDL tokens.
    function admin_unlock(uint256 amountBIDL) public onlyBlockbidAdmin onlyWhenActivated {
        _bidlToken.transfer(_poolParticipant, amountBIDL);
        
        uint256 weiToUnlock = _weiPerBidl * amountBIDL;
        _poolParticipant.transfer(weiToUnlock);
        
        emit Unlock(amountBIDL, weiToUnlock);
    }
    
    // Prevent any further deposits and start distribution phase.
    function admin_activate() public onlyBlockbidAdmin {
        require(_poolParticipant != address(0));
        require(!_activated);
        _activated = true;
		emit Activated();
    }
    
    // Can be used by Blockbid admin to destroy the contract and return all funds to investors.
    function admin_destroy() public onlyBlockbidAdmin {
        // Drain all BIDL back into Blockbid's admin address.
        uint256 bidlBalance = _bidlToken.balanceOf(address(this));
        _bidlToken.transfer(_blockbidAdmin, bidlBalance);

        // Destroy the contract.
        selfdestruct(_poolParticipant);
    }
    
    // Process ETH coming from the pool participant address.
    function () external payable {
        // Do not allow changing participant address after it has been set.
        if (_poolParticipant != address(0) && _poolParticipant != msg.sender) {
            revert();
        }

        // Do not allow top-ups if the contract had been activated.
        if (_activated) {
            revert();
        }
		
		uint256 weiBalance = address(this).balance;
		
		// Refund excessive ETH.
		if (weiBalance > _maxBalanceWei) {
		    uint256 excessiveWei = weiBalance.sub(_maxBalanceWei);
		    msg.sender.transfer(excessiveWei);
		    weiBalance = _maxBalanceWei;
		}
		
		if (_poolParticipant != msg.sender) 
		    _poolParticipant = msg.sender;
    }
	
	constructor () public
	{
        _blockbidAdmin = 0x2B1c94b5d79a4445fE3BeF9Fd4d9Aae6A65f0F92;
		_bidlToken = IERC20Token(0x5C7Ec304a60ED545518085bb4aBa156E8a7596F6);
	}
}