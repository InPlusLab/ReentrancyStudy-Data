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
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./Ownable.sol" ;

//@title PRDX Token contract interface
interface PRDX_token {                                     
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

//@title PRDX Initial Distribution Contract
//@author Predix Network Team
contract PRDXDistr is Ownable{
    uint256 public PRDXPrice ;
    
    address public token_addr ; 
    PRDX_token token_contract = PRDX_token(token_addr) ;
    
    event sold(address seller, uint256 amount) ;
    event bought(address buyer, uint256 amount) ;
    event priceAdjusted(uint256 oldPrice, uint256 newPrice) ; 

    constructor(uint256 PRDXperETH) {
        PRDXPrice = PRDXperETH ; 
    }

    /**
     * @dev Multiply two integers with extra checking the result
     * @param   a Integer 1 
     *          b Integer 2
     */
    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0 ;
        } else {
            uint256 c = a * b ;
            assert(c / a == b) ;
            return c ;
        }
    }
    
    /**
     * @dev Divide two integers with checking b is positive
     * @param   a Integer 1 
     *          b Integer 2
     */
    function safeDivide(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); 
        uint256 c = a / b;

        return c;
    }
    
    /**
     * @dev Set PRDX Token contract address
     * @param addr Address of PRDX Token contract
     */
    function set_token_contract(address addr) public onlyOwner {
        token_addr = addr ;
        token_contract = PRDX_token(token_addr) ;
    }
    
    /**
     * @dev Sell PRDX tokens through Predix Network token contract
     * @param   seller Account to sell PRDX tokens from
     *          amount Amount of PRDX to sell
     */
    function sell_PRDX(address payable seller, uint256 amount) public returns (bool success) {
        require(token_contract.transferFrom(seller, address(this), amount), "Error transacting tokens to contract") ;
        
        uint256 a = safeDivide(amount, PRDXPrice) ; 
        
        seller.transfer(a) ; 
        
        emit sold(seller, a) ; 
        
        return true ; 
    }

    /**
     * @dev Buy PRDX tokens directly from the contract
     */
    function buy_PRDX() public payable returns (bool success) {
        require(msg.value > 0) ; 
        uint256 scaledAmount = safeMultiply(msg.value, PRDXPrice) ;
        require(token_contract.balanceOf(address(this)) >= scaledAmount) ;

        token_contract.transfer(msg.sender, scaledAmount) ;
        
        emit bought(msg.sender, scaledAmount) ; 
    
        return true ; 
    }
    
    /**
     * @dev Fallback function for when a user sends ether to the contract
     * directly instead of calling the function
     */
    receive() external payable {
        buy_PRDX() ; 
    }

    /**
     * @dev Adjust the PRDX token price
     * @param   PRDXperETH the amount of PRDX a user receives for 1 ETH
     */
    function adjustPrice(uint PRDXperETH) public onlyOwner {
        emit priceAdjusted(PRDXPrice, PRDXperETH) ; 
        
        PRDXPrice = PRDXperETH ; 
        
    }

    /**
     * @dev End the PRDX token distribution by sending all leftover tokens and ether to the contract owner
     */
    function endPRDXDistr() public onlyOwner {             
        require(token_contract.transfer(owner(), token_contract.balanceOf(address(this)))) ;

        msg.sender.transfer(address(this).balance) ;
    }
}
