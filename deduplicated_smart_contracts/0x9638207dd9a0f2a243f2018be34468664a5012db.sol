pragma solidity ^0.4.19;

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

library SafeMath {
 function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
    }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

 function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
You should inherit from StandardToken or, for a token like you would want to
deploy in something like Mist, see HumanStandardToken.sol.
(This implements ONLY the standard functions and NOTHING else.
If you deploy this, you won&#39;t have anything useful.)

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
.*/

contract StandardToken is Token {
    using SafeMath for uint256;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
    } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
   }


    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardToken is StandardToken {

    function () public {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg YEE: a Token for Yee Ecosystem.
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 YEE = 980 base units. It&#39;s like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg YEE
    string public version = &#39;H0.1&#39;;       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken (
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) internal {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn&#39;t have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}

contract YEEToken is HumanStandardToken(10000000000000000000000000000,"Yee - A Blockchain-powered & Cloud-based Social Ecosystem",18,"YEE"){
 function () public {
        //if ether is sent to this address, send it back.
        throw;
    }
 
 function YEEToken () public {
  
    }
}

contract YeeLockerForYeeTeam {
    address public accountLocked;   //the acount been locked
    uint256 public timeLockedStart;      //locked time 
    uint256 public amountNeedToBeLock;  //total amount need lock
    uint256 public unlockPeriod;      //month, quarter or year 
    uint256 public unlockPeriodNum;   //number of period for unlock
    
    address  private yeeTokenAddress = 0x922105fAd8153F516bCfB829f56DC097a0E1D705;
    YEEToken private yeeToken = YEEToken(yeeTokenAddress);
    
    event EvtUnlock(address lockAccount, uint256 value);
    
    //unlock other token if any to accountLocked. in case of misoperation
    function _unlockOther(address otherTokenContract) public returns(bool result){
        if (otherTokenContract != yeeTokenAddress){
            StandardToken t = StandardToken(otherTokenContract);
            uint256 ava = t.balanceOf(this);
            if (ava <=0 ) return false;
            return t.transfer(accountLocked, ava);
        }
        return false;
    }
    
    function _balance() public view returns(uint256 amount){
        return yeeToken.balanceOf(this);
    }
    
    function unlockCurrentAvailableFunds() public returns(bool result){
        uint256 amount = getCurrentAvailableFunds();
        if ( amount == 0 ){
            return false;
        }
        else{
            bool ret = yeeToken.transfer(accountLocked, amount);
            EvtUnlock(accountLocked, amount);
            return ret;
        }
    }
    
    function getNeedLockFunds() public view returns(uint256 needLockFunds){
        uint256 count = (now - timeLockedStart)/unlockPeriod; //if first unlock is at period begin, then +1 here
        if ( count > unlockPeriodNum ){
            return 0;
        }
        else{
            uint256 needLock = amountNeedToBeLock / unlockPeriodNum * (unlockPeriodNum - count );
            return needLock;
        }
    }

    function getCurrentAvailableFunds() public view returns(uint256 availableFunds){
        uint256 balance = yeeToken.balanceOf(this);
        uint256 needLock = getNeedLockFunds();
        if ( balance > needLock ){
            return balance - needLock;
        }
        else{
            return 0;
        }
    }
    
    function getNeedLockFundsFromPeriod(uint256 endTime, uint256 startTime) public view returns(uint256 needLockFunds){
        uint256 count = (endTime - startTime)/unlockPeriod; //if first unlock is at period begin, then +1 here
        if ( count > unlockPeriodNum ){
            return 0;
        }
        else{
            uint256 needLock = amountNeedToBeLock / unlockPeriodNum * (unlockPeriodNum - count );
            return needLock;
        }
    }
    
    function YeeLockerForYeeTeam() public {
        //Total 1.5 billion YEE to be locked
        //Unlock 1/30 at end of every month
        accountLocked = msg.sender; 
        uint256 base = 1000000000000000000;
        amountNeedToBeLock = 1500000000 * base; //1.5 billion
        unlockPeriod = 30 days;
        unlockPeriodNum = 30;
        timeLockedStart = now;
    }
}