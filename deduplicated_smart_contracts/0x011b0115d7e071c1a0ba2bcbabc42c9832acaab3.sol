/**
 *Submitted for verification at Etherscan.io on 2019-10-27
*/

pragma solidity ^0.5.10;

/**
 * PIEXGO TEAM
 */


/**
 * Math operations with safety checks that throw on error
 */
library SafeMath {

	/**
	 * Adds two numbers, throws on overflow.
	 */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
	
	/**
	 * Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
	 */	
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
	
	/**
	 * Multiplies two numbers, throws on overflow.
	 */	
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
	
	/**
	 * Integer division of two numbers, truncating the quotient.
	 */	
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract Owned {
    address public owner;

    /**
     * Constructor function
     *
     * Set the original `owner` of the contract to the sender account.
     */	
    constructor() public {
        owner = msg.sender;
    }	

    /**
    * Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Allows the current owner to transfer control of the contract to a newOwner.
	 *
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

/**
 * ERC20 interface
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
  
    // This generates a public event on the blockchain that will notify clients 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);	  
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	// This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public;
}
	

contract PIEXGOToken is ERC20Basic, Owned {
    using SafeMath for uint256;

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;  // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        symbol = "PXG";
        name = "PIEXGO";
        decimals = 18;
        _totalSupply = 10000000000 * (10**uint256(decimals));
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    /**
     * @dev total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }	
	
    /**
     * Gets the balance of the specified address.
	 *
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }	
	
	/**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
		require(_to != address(0));
        // Save this for an assertion in the future
        uint256 previousBalances = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] = balances[_from].sub(_value);		
        // Add the same to the recipient
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from].add(balances[_to]) == previousBalances);
    }
	
    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
		return true;
    }

    /**
     * Function to check the amount of tokens that an owner allowed to a spender.
	 *
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }
	
    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);     // Check allowance
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
	
    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
        return true;
    }
 
    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        ApproveAndCallFallBack spender = ApproveAndCallFallBack(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
		return false;
    }
	
    function () external payable {
        revert();
    }

}