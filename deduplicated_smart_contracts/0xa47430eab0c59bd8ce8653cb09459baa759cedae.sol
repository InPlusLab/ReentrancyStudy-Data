// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./SafeMath.sol";
import "./Ownable.sol" ; 

//@title PRDX token contract interface
interface PRDX_token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success) ; 
}

//@title PRDX Staking contract
//@author Predix Network Team
contract PredixNetworkStaking is Ownable {
    using SafeMath for uint256 ; 
    
    //time variables
    uint public week = 604800 ; 
    
    //level definitions
    uint public _lvl1 = 50 * 1e18 ;  
    uint public _lvl2 = 500 * 1e18 ;  
    uint public _lvl3 = 5000 * 1e18 ; 
    
    //active staking coins
    uint public coins_staking ; 
    
    //Staking Defintions
    mapping (address => bool) public isStaking ; 
    mapping(address => uint256) public stakingAmount ;
    mapping(address => uint256) public stakingStart ;
    
    //contract addresses
    address public token_addr ; 
    
    PRDX_token token_contract = PRDX_token(token_addr) ;
    
    event staked(address staker, uint256 amount) ;
    event ended_stake(address staker, uint256 reward) ; 
    
    /**
     * @dev Set PRDX Token contract address
     * @param addr Address of PRDX Token contract
     */
    function set_token_address(address addr) public onlyOwner {
        token_addr = addr ; 
        token_contract = PRDX_token(addr) ;
    }
    
    /**
     * @dev Get staking amount of user, hook for other contracts
     * @param staker User address to get staking amount for
     * @return staking_amount Only zero if user is not staking
     */
    function get_staking_amount(address staker) public view returns (uint256 staking_amount) {
        if (isStaking[staker] == false) {
            return 0 ; 
        }
        return stakingAmount[staker] ; 
    }
    
    /**
     * @dev Get user staking status, hook for other contracts
     * @param user User address to get staking status for
     * @return is_staking Is false if user is not staking, true if staking
     */
    function get_is_staking(address user) public view returns (bool is_staking) {
     return isStaking[user] ;    
    }
    
    /**
     * @dev Stake tokens, should be called through main token contract. User must have approved 
     * staking contract, amount must be at least {_lvl1} and cannot be staking already. Extra 
     * check for staking timestamp performed to prevent timestamp errors and futuristic staking
     * @param   staker User address to stake tokens for
     *          amount Amount of tokens to stake
     * @return success Only false if transaction fails
     */
    function stake(address staker, uint256 amount) public payable returns (bool success) {
        require(amount >= _lvl1, "Not enough tokens to start staking") ; 
        require(isStaking[staker] == false, "Already staking") ;
        require(stakingStart[staker] <= block.timestamp, "Error getting staking timestamp") ; 
        require(token_contract.transferFrom(staker, address(this), amount), "Error transacting tokens to contract") ;
        
        isStaking[staker] = true ; 
        stakingAmount[staker] = amount ;  
        stakingStart[staker] = block.timestamp ; 
        coins_staking += amount ; 
        
        emit staked(staker, amount) ; 
        return true ; 
    }
    
    /**
     * @dev Stop staking currently staking tokens. Sender has to be staking
     */
    function stop_stake() public returns (bool success) {
        require(stakingStart[msg.sender] <= block.timestamp, "Staking timestamp error") ; 
        require(isStaking[msg.sender] == true, "User not staking") ; 

        uint256 reward = getStakingReward(msg.sender) + stakingAmount[msg.sender] ; 

        token_contract.transfer(msg.sender, reward) ; 
      
        coins_staking -= stakingAmount[msg.sender] ;
        stakingAmount[msg.sender] = 0 ; 
        isStaking[msg.sender] = false ;
         
        emit ended_stake(msg.sender, reward) ; 
        return true ; 
    }
    
    /**
     * @dev Calculate staking reward
     * @param staker Address to get the staking reward for
     */
    function getStakingReward(address staker) public view returns (uint256 __reward) {
        uint amount = stakingAmount[staker] ; 
        uint age = getCoinAge(staker) ; 
        
        if ((amount >= _lvl1) && (amount < _lvl2)) {
            return calc_lvl1(amount, age) ; 
        }
        
        if ((amount >= _lvl2) && (amount < _lvl3)) {
            return calc_lvl2(amount, age) ; 
        }
        
        if (amount >= _lvl3) {
            return calc_lvl3(amount, age) ;
        }
    }
    
    /**
     * @dev Calculate staking reward for level 1 staker
     * @param   amount Amount of PRDX tokens to calculate staking reward performed
     *          age Age of staked tokens
     */    
    function calc_lvl1(uint amount, uint age) public view returns (uint256 reward) {
        uint256 _weeks = age/week ;
        uint interest = amount ;
        
        for (uint i = 0; i < _weeks; i++) {
            interest += 25 * interest / 10000 ; 
        }
        
        return interest - amount ; 
    }

    /**
     * @dev Calculate staking reward for level 2 staker
     * @param   amount Amount of PRDX tokens to calculate staking reward performed
     *          age Age of staked tokens
     */    
    function calc_lvl2(uint amount, uint age) public view returns (uint256 reward) {
        uint256 _weeks = age/week ;
        uint interest = amount ;
        
        for (uint i = 0; i < _weeks; i++) {
            interest += 50 * interest / 10000 ; 
        }
        
        return interest - amount ; 
    }

    /**
     * @dev Calculate staking reward for level 3 staker
     * @param   amount Amount of PRDX tokens to calculate staking reward performed
     *          age Age of staked tokens
     */    
    function calc_lvl3(uint amount, uint age) public view returns (uint256 reward) {
        uint256 _weeks = age/week ;
        uint interest = amount ;
        
        for (uint i = 0; i < _weeks; i++) {
            interest += 85 * interest / 10000 ; 
        }
        
        return interest - amount ; 
    }
    
    /**
     * @dev Get coin age of staker. Returns zero if user not staking
     * @param staker Address to get the staking age for
     */
    function getCoinAge(address staker) public view returns(uint256 age) {
        if (isStaking[staker] == true){
            return (block.timestamp.sub(stakingStart[staker])) ;
        }
        else {
            return 0 ;
        }
    }
    
    /**
     * @dev Returns total amount of coins actively staking
     */
    function get_total_coins_staking() public view returns (uint256 amount) {
        return coins_staking ; 
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
