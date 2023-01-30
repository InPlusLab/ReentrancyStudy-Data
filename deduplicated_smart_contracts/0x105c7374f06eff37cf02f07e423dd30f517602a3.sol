/**
 *Submitted for verification at Etherscan.io on 2020-03-31
*/

pragma solidity 0.5.0;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
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

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    
///    event Approval(address indexed owner, address indexed spender, uint256 value);

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * Further developments for the Restricted ERC-1404 is based on ERC-20 to reflect Restrictions required by the US Securities and Exchange
 * Commission (SEC). Developments are done by ELektrikka Inc. (https://elektrikka.net) and ElektrikCar LLC.
 * https://elektrikcar.com
 * Dev 2019-2020
 */


contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

///    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;
    
    mapping (address => uint256) private blacklist;
    mapping (address => uint256) private  waitlist;
    address private initiator;

    constructor () public {
         initiator = msg.sender;
        _mint(msg.sender,350000000);
    }


    
    function addRestriction (address _user) public returns (bool)  {
	require(msg.sender == initiator, "Only Admin can Restrict Token");
        blacklist[_user] = 1;
        return true ;
    }

    function removeRestriction (address _user) public returns (bool) {
	require(msg.sender == initiator, "Only Admin can remove token Restriction");
        blacklist[_user] = 0;
        return true ;
    }

    function isUserRestricted (address _user) public view returns (string memory) {
        
        if (blacklist[_user] == 0) {
            return "No, User is Not Restricted for Transfer";
        }
        
        if (blacklist[_user] == 1) {
            return "Yes, User is Restricted for Transfer";
        }
        
    }

    function addToWaitlist (address _user) public returns (string memory) {
        waitlist[_user] = 1;  
        return "User is Waitlisted";
    }
    
    function removeFromWaitlist (address _user) public returns (string memory) {
        waitlist[_user] = 0; 
        return "User Waitlist is Removed";
    }

    function isUserWaitlisted(address _user) public view returns (string memory) {
        
            if (waitlist[_user] == 0) {
            return "No, User is NOT Waitlisted";
        }
        
            if (waitlist[_user] == 1) {
            return "Yes, User is Waitlisted";
        }

    }

    function detectTransferRestriction (address from, address to)
        public view returns (string memory) {

        if (to == address(0)) {
            return "Address(0x0) is not Allowed";   
        }
        if (blacklist[from] == 1) {
            return "Sender Restriction Period is Less Than One Year";
        }
        if (waitlist[to] == 0) {
            return "Recipient is Not Waitlisted (Should be Waitlisted)";
        }
        if (blacklist[from] == 0 && to != address(0)  ) {
            return "Sender is Not Restricted for Transfer";
        }
    }
    
    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }
   

    /**
      * @dev Burn token at specified address
      * @param to THe address to be burnt
      * @param value The amount to be burnt
      */
    
    function buyBack(address to, uint256 value) public returns (bool) {
       require(msg.sender == initiator, "Only Admin can Buy Back Tokens");       
        _burn(to, value);
	    return true;
    }


    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require (blacklist[msg.sender] == 0, "Owner is still Restricted (less than one year)") ;
        require (waitlist[to] == 1, "Recipient should be Waitlisted");
        _transfer(msg.sender, to, value);  
        return true;
    }


    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require (blacklist[msg.sender] == 0, "Owner is still Restricted (less than one year)") ;
        _transfer(from, to, value);         
        return true;
    }


    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
     function _transfer(address from, address to, uint256 value) internal {
         require(to != address(0));
         require(msg.sender == from, "Only Token Owner can Transfer Token" );
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }


    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));
///        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        _balances[initiator] = _balances[initiator].add(value);
        emit Transfer(account, initiator , value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
///    function _approve(address owner, address spender, uint256 value) internal {
///        require(spender != address(0));
///        require(owner != address(0));
///        _allowed[owner][spender] = value;
///        emit Approval(owner, spender, value);
///    }

}


contract Elektrikka is ERC20 {

    string public name = "Elektrikka ElektrikCar";
    string public symbol = "FCEV1";
    uint public decimal = 18;

    function transfer (address to, uint256 value)
        public returns (bool)
    {
        return super.transfer(to, value);
    }


    function transferFrom (address from, address to, uint256 value)
        public returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

}