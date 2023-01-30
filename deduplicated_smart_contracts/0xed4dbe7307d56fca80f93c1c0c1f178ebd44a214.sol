/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-11
*/

pragma solidity ^0.5.10;
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic 
{
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath 
{
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c  / a == b);
        return c;
    }
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return a  / b;
    }
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) 
    {
        c = a + b;
        assert(c >= a);
        return c;
    }
}
pragma solidity ^0.5.10;
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic 
{
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Owner
{
    address internal owner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function changeOwner(address newOwner) public onlyOwner returns(bool)
    {
        owner = newOwner;
        return true;
    }
}

pragma solidity ^0.5.10;
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Owner
{
    using SafeMath for uint256;
    uint256 internal totalSupply_;
    mapping (address => bool) internal locked;
	mapping(address => uint256) internal balances;
    /**
    * alan: lock or unlock account
    */
    function lockAccount(address _addr) public onlyOwner returns (bool)
    {
        require(_addr != address(0));
        locked[_addr] = true;
        return true;
    }
    function unlockAccount(address _addr) public onlyOwner returns (bool)
    {
        require(_addr != address(0));
        locked[_addr] = false;
        return true;
    }
    /**
    * alan: get lock status
    */
    function isLocked(address addr) public view returns(bool) 
    {
        return locked[addr];
    }
    bool internal stopped = false;
    modifier running {
        assert (!stopped);
        _;
    }
    function stop() public onlyOwner 
    {
        stopped = true;
    }
    function start() public onlyOwner 
    {
        stopped = false;
    }
    function isStopped() public view returns(bool)
    {
        return stopped;
    }
    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) 
    {
        return totalSupply_;
    }
    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public running returns (bool) 
    {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require( locked[msg.sender] != true);
        require( locked[_to] != true);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) 
    {
        return balances[_owner];
    }
}
pragma solidity ^0.5.10;
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken 
{
    mapping (address => mapping (address => uint256)) internal allowed;
    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public running returns (bool) 
    {
        require(_to != address(0));
        require( locked[_from] != true && locked[_to] != true);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the
    old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public running returns (bool) 
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256) 
    {
        return allowed[_owner][_spender];
    }
}

contract NNDToken is StandardToken
{
    function additional(uint amount) public onlyOwner running returns(bool)
    {
        totalSupply_ = totalSupply_.add(amount);
        balances[owner] = balances[owner].add(amount);
        return true;
    }
    event Burn(address indexed from, uint256 value);
    /**
    * Destroy tokens
    * Remove `_value` tokens from the system irreversibly
    * @param _value the amount of money to burn
    */
    function burn(uint256 _value) public onlyOwner running returns (bool success) 
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }
    /**
    * Destroy tokens from other account
    *
    * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
    *
    * @param _from the address of the senderT
    * @param _value the amount of money to burn
    */
    function burnFrom(address _from, uint256 _value) public onlyOwner returns (bool success) 
    {
        require(balances[_from] >= _value);
        if (_value <= allowed[_from][msg.sender]) {
            allowed[_from][msg.sender] -= _value;
        }
        else {
            allowed[_from][msg.sender] = 0;
        }
        balances[_from] -= _value;
        totalSupply_ -= _value;
        emit Burn(_from, _value);
        return true;
    }
}

pragma solidity ^0.5.10;
contract NND is NNDToken 
{
    string public constant name = "NND";
    string public constant symbol = "NND";
    uint8 public constant decimals = 18;
    uint256 private constant INITIAL_SUPPLY = 990000000 * (10 ** uint256(decimals));

    constructor(uint totalSupply) public 
    {
        owner = msg.sender;
        totalSupply_ = totalSupply > 0 ? totalSupply : INITIAL_SUPPLY;
        balances[owner] = totalSupply_;
    }
}