pragma solidity ^0.4.21;
/** ----------------------------------------------------------------------------------------------
 * ZJLTTokenVault by ZJLT Distributed Factoring Network Limited.
 * An ERC20 standard
 *
 * author: ZJLT Distributed Factoring Network Team
 */

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error.
 */
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
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract ERC20 {

    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);
    function approve(address spender, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);

}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

interface TokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

contract TokenERC20 is ERC20, Ownable{
    // Public variables of the token
    string public name;
    string public symbol;
    uint8  public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    using SafeMath for uint256;
    // Balances
    mapping (address => uint256) balances;
    // Allowances
    mapping (address => mapping (address => uint256)) allowances;


    // ----- Events -----
    event Burn(address indexed from, uint256 value);


    /**
     * Constructor function
     */
    function TokenERC20(uint256 _initialSupply, string _tokenName, string _tokenSymbol, uint8 _decimals) public {
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        decimals = _decimals;

        totalSupply = _initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balances[msg.sender] = totalSupply;                // Give the creator all initial tokens
    }

        /**
     * @dev Fix for the ERC20 short address attack.
     */
    modifier onlyPayloadSize(uint size) {
      if(msg.data.length < size + 4) {
        revert();
      }
      _;
    }
    

    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal returns(bool) {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);

        require(_value >= 0);
        // Save this for an assertion in the future
        uint previousBalances = balances[_from].add(balances[_to]);
         // SafeMath.sub will throw if there is not enough balance.
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalances);

        return true;
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        return _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value > 0);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        require((_value == 0) || (allowances[msg.sender][_spender] == 0));
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns(bool) {
        if (approve(_spender, _value)) {
            TokenRecipient spender = TokenRecipient(_spender);
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
        return false;
    }


  /**
   * @dev Transfer tokens to multiple addresses
   * @param _addresses The addresses that will receieve tokens
   * @param _amounts The quantity of tokens that will be transferred
   * @return True if the tokens are transferred correctly
   */
  function transferForMultiAddresses(address[] _addresses, uint256[] _amounts)  public returns (bool) {
    for (uint256 i = 0; i < _addresses.length; i++) {
      require(_addresses[i] != address(0));
      require(_amounts[i] <= balances[msg.sender]);
      require(_amounts[i] > 0);

      // SafeMath.sub will throw if there is not enough balance.
      balances[msg.sender] = balances[msg.sender].sub(_amounts[i]);
      balances[_addresses[i]] = balances[_addresses[i]].add(_amounts[i]);
      emit Transfer(msg.sender, _addresses[i], _amounts[i]);
    }
    return true;
  }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns(bool) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] = balances[msg.sender].sub(_value);            // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

        /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns(bool) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowances[_from][msg.sender]);    // Check allowance
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                                 // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }


    /**
     * approve should be called when allowances[_spender] == 0. To increment
     * allowances value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        // Check for overflows
        require(allowances[msg.sender][_spender].add(_addedValue) > allowances[msg.sender][_spender]);

        allowances[msg.sender][_spender] =allowances[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowances[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowances[msg.sender][_spender] = 0;
        } else {
            allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }


}

contract ZJLTToken is TokenERC20 {

    function ZJLTToken() TokenERC20(2500000000, "ZJLT Distributed Factoring Network", "ZJLT", 18) public {

    }
    
    function () payable public {
      //if ether is sent to this address, send it back.
      //throw;
      require(false);
    }
}

contract ZJLTTokenVault is Ownable {
    using SafeMath for uint256;
    address public teamWallet = 0x1fd4C9206715703c209651c215f506555a40b7C0;
    uint256 public startLockTime;
    uint256 public totalAlloc = 25 * 10 ** 18;
    uint256 public perValue = 20833333 * 10 ** 11;

    uint256 public timeLockPeriod = 30 days;
    uint256 public teamVestingStages = 12;
    uint256 public latestUnlockStage = 0;

    mapping (address => uint256) public lockBalance;
    ZJLTToken public token;
    bool public isExec;
    
    // envent
    event Alloc(address _wallet, uint256 _value);
    event Claim(address _wallet, uint256 _value);
    
    modifier unLocked {
        uint256 nextStage =  latestUnlockStage.add(1);
        require(startLockTime > 0 && now >= startLockTime.add(nextStage.mul(timeLockPeriod)));
        _;
    }
    
    modifier unExecd {
        require(isExec == false);
        _;
    }
    
    function ZJLTTokenVault(ERC20 _token) public {
        owner = msg.sender;
        token = ZJLTToken(_token);
    }
    
    function isUnlocked() public constant returns (bool) {
        uint256 nextStage =  latestUnlockStage.add(1);
        return startLockTime > 0 && now >= startLockTime.add(nextStage.mul(timeLockPeriod)) ;
    }
    
    function alloc() public onlyOwner unExecd{
        require(token.balanceOf(address(this)) >= totalAlloc);
        lockBalance[teamWallet] = totalAlloc;
        startLockTime = 1494432000 seconds;
        isExec = true;
        emit Alloc(teamWallet, totalAlloc);
    }
    
    function claim() public onlyOwner unLocked {
        require(lockBalance[teamWallet] > 0);
        if(latestUnlockStage == 11 && perValue != lockBalance[teamWallet] ){
            perValue = lockBalance[teamWallet];
        }
        lockBalance[teamWallet] = lockBalance[teamWallet].sub(perValue);
        require(token.transfer(teamWallet, perValue));
        latestUnlockStage = latestUnlockStage.add(1);
        emit Claim(teamWallet, perValue);
    }
}