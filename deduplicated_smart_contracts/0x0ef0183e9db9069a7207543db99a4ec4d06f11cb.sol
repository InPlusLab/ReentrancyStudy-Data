/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity 0.4.25;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

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

    assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

contract owned {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    

    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }

}



contract Pausable is owned {

  event Pause();

  event Unpause();



  bool public paused = false;



  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public {

    paused = false;

    emit Unpause();

  }

}



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

interface ERC20Token {



  



    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) view external returns (uint256 balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) external returns (bool success);



    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);



    



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    

}







contract StandardToken is ERC20Token, Pausable {

 using SafeMath for uint;

 

 /** 

 Mitigation for short address attack

 */

  modifier onlyPayloadSize(uint size) {

     assert(msg.data.length >= size.add(4));

     _;

   } 



/**

  * @dev Transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */



    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) whenNotPaused external returns (bool success) {

         require(_to != address(0));

         require(_value <= balances[msg.sender]);



         balances[msg.sender] = balances[msg.sender].sub(_value);

         balances[_to] = balances[_to].add(_value);

         emit Transfer(msg.sender, _to, _value);

         return true;

    }

 /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) whenNotPaused external returns (bool success) {

        require(_to != address(0));

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    function balanceOf(address _owner) view external returns (uint256 balance) {

        return balances[_owner];

    }

    

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of wei to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) whenNotPaused public returns (bool success) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        require(_value <= balances[msg.sender]);

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }





   

    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }



    /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(address _spender, uint256 _addedValue) whenNotPaused public returns (bool)

  {

    allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(address _spender,uint256 _subtractedValue) whenNotPaused public returns (bool)

  {

    uint256 oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowed;

    uint256 public _totalSupply;

}





//The Contract Name

contract TansalCoin is StandardToken{

 using SafeMath for uint;





    /* Public variables of the token */



    

    string public name;                   

    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.

    string public symbol;                 

    string public version = 'V1.0';       //Version 0.1 standard. Just an arbitrary versioning scheme.

    uint256 private fulltoken;

    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);





// ERC20Token



    constructor(

        ) public{

        fulltoken = 700000000;       

        decimals = 3;                            // Amount of decimals for display purposes

        _totalSupply = fulltoken.mul(10 ** uint256(decimals)); // Update total supply (100000 for example)

        balances[msg.sender] = _totalSupply;               // Give the creator all initial tokens (100000 for example)

        name = "Tansal Coin";                                   // Set the name for display purposes

        symbol = "TANSAL";                               // Set the symbol for display purposes

    }

     function() public {

         //not payable fallback function

          revert();

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

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

           }

    }

    

      /// @return total amount of tokens

    function totalSupply() public view returns (uint256 supply){

        

        return _totalSupply;

    }



    /**

     * Destroy tokens

     *

     * Remove `_value` tokens from the system irreversibly

     *

     * @param _value the amount of money to burn

     */

    function burn(uint256 _value) onlyOwner public returns (bool success) {

        require(balances[msg.sender] >= _value);   // Check if the sender has enough

        balances[msg.sender] = balances[msg.sender].sub(_value);            // Subtract from the sender

        _totalSupply = _totalSupply.sub(_value);                      // Updates totalSupply

        emit Burn(msg.sender, _value);

        emit Transfer(msg.sender, address(0), _value);

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

    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {

        require(balances[_from] >= _value);                // Check if the targeted balance is enough

        require(_value <= allowed[_from][msg.sender]);    // Check allowance

        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance

        _totalSupply = _totalSupply.sub(_value);                              // Update totalSupply

        emit Burn(_from, _value);

        emit Transfer(_from, address(0), _value);

        return true;

    }

     function onlyPayForFuel() public payable onlyOwner{

        // Owner will pay in contract to bear the gas price if transactions made from contract

        

    }

    function withdrawEtherFromcontract(uint _amountInwei) public onlyOwner{

        require(address(this).balance > _amountInwei);

      require(msg.sender == owner);

      owner.transfer(_amountInwei);

     

    }

	 function withdrawTokensFromContract(uint _amountOfTokens) public onlyOwner{

        require(balances[this] >= _amountOfTokens);

        require(msg.sender == owner);

	    balances[msg.sender] = balances[msg.sender].add(_amountOfTokens);                        // adds the amount to owner's balance

        balances[this] = balances[this].sub(_amountOfTokens);                  // subtracts the amount from contract balance

		emit Transfer(this, msg.sender, _amountOfTokens);               // execute an event reflecting the change

     

    }

     /* Get the contract constant _name */

    function name() public view returns (string _name) {

        return name;

    }



    /* Get the contract constant _symbol */

    function symbol() public view returns (string _symbol) {

        return symbol;

    }



    /* Get the contract constant _decimals */

    function decimals() public view returns (uint8 _decimals) {

        return decimals;

    }

      

}