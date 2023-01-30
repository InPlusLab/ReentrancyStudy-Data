// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./Ownable.sol" ;

//@title PRDX Token contract interface
interface PRDX_token {                                     
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function _approve(address owner, address spender, uint256 amount) external ; 
}

//@title PRDX Team Tokens Lock Contract
//@author Predix Network Team
contract PRDXTeamLock is Ownable {
    
    address public token_addr ; 
    PRDX_token token_contract = PRDX_token(token_addr) ;

    uint256 public PERC_per_MONTH = 10 ; 
    uint256 public last_claim ; 
    uint256 public start_lock ;
    
    uint256 public MONTH = 2628000 ; 
    
    uint256 public locked ; 

    /**
     * @dev Lock tokens by approving the contract to take them.
     * @param   value Amount of tokens you want to lock in the contract
     */
    function lock_tokens(uint256 value) public payable onlyOwner {
        token_contract.transferFrom(msg.sender, address(this), value) ; 
    
        locked += value ;
        start_lock = block.timestamp ; 
    }

    /**
     * @dev Withdraw function for the team to withdraw locked up tokens each month starting one month after lockup
     */
    function withdraw() public onlyOwner {
        require(block.timestamp >= start_lock + MONTH, "Cannot be claimed in first month") ;
        require(block.timestamp - last_claim >= MONTH, "Cannot claim twice per month") ; 
        last_claim = block.timestamp ; 
        
        token_contract.transfer(msg.sender, locked * PERC_per_MONTH/100) ; 
    }

    /**
     * @dev Set PRDX Token contract address
     * @param addr Address of PRDX Token contract
     */
    function set_token_contract(address addr) public onlyOwner {
        token_addr = addr ;
        token_contract = PRDX_token(token_addr) ;
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

