pragma solidity ^0.4.16;
// SecureBuy contract based on the full ERC20 Token standard
// https://github.com/ethereum/EIPs/issues/20
// Smartcontract for SecureBuy.
// Verified Status: ERC20 Verified Token
// SecureBuy Symbol: BUY


contract SecureBuyToken { 

    /// total amount of tokens
    uint256 public totalSupply;
    

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * SecureBuy Token Math operations with safety checks to avoid unnecessary conflicts
 */

library ABCMaths {
// Saftey Checks for Multiplication Tasks
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
// Saftey Checks for Divison Tasks
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
// Saftey Checks for Subtraction Tasks
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
// Saftey Checks for Addition Tasks
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Ownable {
    address public owner;
    address public newOwner;

    /** 
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

   // validates an address - currently only checks that it isn&#39;t null
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }

    function acceptOwnership() {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    event OwnershipTransferred(address indexed _from, address indexed _to);
}


contract BUYStandardToken is SecureBuyToken, Ownable {
    
    using ABCMaths for uint256;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
     
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (balances[msg.sender] >= _value) // Check if the sender has enough
            && (_value > 0) // Don&#39;t allow 0value transfer
            && (_to != address(0)) // Prevent transfer to 0x0 address
            && (balances[_to].add(_value) >= balances[_to]) // Check for overflows
            && (msg.data.length >= (2 * 32) + 4)); //mitigates the ERC20 short address attack
            //most of these things are not necesary

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[msg.sender]) return false;
        require(
            (allowed[_from][msg.sender] >= _value) // Check allowance
            && (balances[_from] >= _value) // Check if the sender has enough
            && (_value > 0) // Don&#39;t allow 0value transfer
            && (_to != address(0)) // Prevent transfer to 0x0 address
            && (balances[_to].add(_value) >= balances[_to]) // Check for overflows
            && (msg.data.length >= (2 * 32) + 4) //mitigates the ERC20 short address attack
            //most of these things are not necesary
        );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        /* To change the approve amount you first have to reduce the addresses`
         * allowance to zero by calling `approve(_spender, 0)` if it is not
         * already 0 to mitigate the race condition described here:
         * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 */
        
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;

        // Notify anyone listening that this approval done
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
  
}
contract SecureBuy is BUYStandardToken {

    
    uint256 constant public decimals = 8;
    uint256 public totalSupply = 20 * (10**7) * 10**8 ; // 200 million tokens, 8 decimal places
    string constant public name = "SecureBuy";
    string constant public symbol = "BUY";
    
    function SecureBuy(){
        balances[msg.sender] = totalSupply;               // Give the creator all initial tokens
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn&#39;t have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}