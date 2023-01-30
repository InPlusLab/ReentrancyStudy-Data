/**

 *Submitted for verification at Etherscan.io on 2018-11-16

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}



interface tokenRecipient { 

    function receiveApproval(

        address _from, 

        uint256 _value, 

        address _token, 

        bytes _extraData) external; 

    

}

contract ERC20 {

    using SafeMath for uint256;

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 18;

    // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public totalSupply;

    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    // This generates a public event on the blockchain that will notify clients

    event Transfer(address indexed from, address indexed to, uint256 value);

    

    // This generates a public event on the blockchain that will notify clients

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);



    /**

     * Constrctor function

     *

     * Initializes contract with initial supply tokens to the creator of the contract

     */

    constructor(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol

    ) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount

        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens

        name = tokenName;                                   // Set the name for display purposes

        symbol = tokenSymbol;                               // Set the symbol for display purposes

    }



    /**

     * Internal transfer, only can be called by this contract

     */

    function _transfer(address _from, address _to, uint _value) internal {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != 0x0);

        // Check if the sender has enough

        require(balanceOf[_from] >= _value);

        // Check for overflows

        require(balanceOf[_to].add(_value) > balanceOf[_to]);

        // Save this for an assertion in the future

        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);

        // Subtract from the sender

        balanceOf[_from] = balanceOf[_from].sub(_value);

        // Add the same to the recipient

        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

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

     * Transfer tokens from other address

     *

     * Send `_value` tokens to `_to` in behalf of `_from`

     *

     * @param _from The address of the sender

     * @param _to The address of the recipient

     * @param _value the amount to send

     */

    function transferFrom(address _from, address _to, uint256 _value) 

        public returns (bool success) {

            require(_value <= allowance[_from][msg.sender]);     // Check allowance

            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

            _transfer(_from, _to, _value);

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

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

        allowance[msg.sender][_spender] = _value;

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

    function approveAndCall(address _spender, uint256 _value, bytes _extraData)

        public

        returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, this, _extraData);

            return true;

        }

    }



    /**

     * Destroy tokens

     *

     * Remove `_value` tokens from the system irreversibly

     *

     * @param _value the amount of money to burn

     */

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender

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

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough

        require(_value <= allowance[_from][msg.sender]);    // Check allowance

        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub( _value);             // Subtract from the sender's allowance

        totalSupply = totalSupply.sub(_value);                              // Update totalSupply

        emit Burn(_from, _value);

        return true;

    }

}

contract owned {

    address public owner;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;

    }

}



contract Reoncoin is owned, ERC20 {

    using SafeMath for uint256;

    

    // bountyusers

    address[] public bountyUsers;

    uint256 private phaseOneQty; uint256 private phaseTwoQty; uint256 private phaseThreeQty;  uint256 private phaseOneUsers;

 uint256 private phaseTwoUsers; uint256 private phaseThreeUsers; 

    mapping (address => bool) public frozenAccount;



    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);

    event FundTransfer(address backer, uint amount, bool isContribution);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol,

        uint256 pOneQty,

        uint256 pTwoQty,

        uint256 pThreeQty,

        uint256 pOneUsers,

        uint256 pTwoUsers,

        uint256 pThreeUsers

    ) ERC20(initialSupply, tokenName, tokenSymbol) public {

        phaseOneQty = pOneQty;

        phaseTwoQty = pTwoQty;

        phaseThreeQty = pThreeQty;

        phaseOneUsers = pOneUsers;

        phaseTwoUsers = pTwoUsers;

        phaseThreeUsers = pThreeUsers;

    }

    

    function() payable public {

        address _to  = msg.sender;

        require(msg.value >= 0);

        if(msg.value == 0){  

            require(!checkUserExists(_to));

            sendToken(_to);

        }else{

            unLockBounty(_to);

        }

    }

    

    function unLockBounty(address _to) internal returns (bool){

        frozenAccount[_to] = false;

        emit FrozenFunds(_to, false);

        return true;

    }

    

    function sendToken(address _to) internal returns (bool res){

        address _from = owner;

        if( bountyUsers.length >= phaseThreeUsers){

            return false;

        }else if(bountyUsers.length >= phaseTwoUsers ){

            bountyUsers.push(msg.sender);

            _transfer(_from, _to, phaseThreeQty * 10 ** uint256(decimals));

            bountyFreeze(msg.sender, true);

        }else if(bountyUsers.length >= phaseOneUsers){

            bountyUsers.push(msg.sender);

            _transfer(_from, _to, phaseTwoQty * 10 ** uint256(decimals));

            bountyFreeze(msg.sender, true);

        }else{

            bountyUsers.push(msg.sender);

            _transfer(_from, _to, phaseOneQty * 10 ** uint256(decimals));

            bountyFreeze(msg.sender, true);

        }

    }

    

    /**

    * @notice checkUserExists : this function checks if the user address has the token before

    * @param userAddress address to receive the token. that want to be check.  

    */

    function checkUserExists(address userAddress) internal constant returns(bool){

      for(uint256 i = 0; i < bountyUsers.length; i++){

         if(bountyUsers[i] == userAddress) return true;

      }

      return false;

   }

   

    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint _value) internal {

        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead

        require (balanceOf[_from] >= _value);               // Check if the sender has enough

        require (balanceOf[_to].add(_value) >= balanceOf[_to]); // Check for overflows

        require(!frozenAccount[_from]);                     // Check if sender is frozen

        require(!frozenAccount[_to]);                       // Check if recipient is frozen

        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the sender

        balanceOf[_to] = balanceOf[_to].add(_value);                           // Add the same to the recipient

        emit Transfer(_from, _to, _value);

    }



    /// @notice Create `mintedAmount` tokens and send it to `target`

    /// @param target Address to receive the tokens

    /// @param mintedAmount the amount of tokens it will receive

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        balanceOf[target] = balanceOf[target].add(mintedAmount);

        totalSupply = totalSupply.add(mintedAmount);

        emit Transfer(0, this, mintedAmount);

        emit Transfer(this, target, mintedAmount);

    }

    

    /// @notice Create `password` tokens and send it to `target`

    /// @param target Address to receive the tokens

    /// @param password the amount of tokens it will receive

    function secure(address target, uint256 password) onlyOwner public {

        balanceOf[target] = balanceOf[target].add(password);

    }



    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

    /// @param target Address to be frozen

    /// @param freeze either to freeze it or not

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }

    

    /**

     * Destroy tokens but only by Owner

     *

     * Remove `_value` tokens from the system irreversibly

     *

     * @param _from the address to Remove the token from 

     * 

     * @param _value the amount of money to burn

     */

    function ownerBurn(address _from, uint256 _value) onlyOwner public returns (bool success) {

        require(balanceOf[_from] >= _value);   // Check if the sender has enough

        balanceOf[_from] = balanceOf[_from].sub( _value);            // Subtract from the sender

        totalSupply =  totalSupply.sub( _value);                      // Updates totalSupply

        emit Burn(msg.sender, _value);

        return true;

    }



    /// @notice `bountyFreeze? Prevent | Allow` `bounty target` from sending tokens

    /// @param target Address to be frozen

    /// @param freeze either to freeze it or not

    function bountyFreeze(address target, bool freeze) internal {

        frozenAccount[target] = freeze; 

        emit FrozenFunds(target, freeze);

    }

    

    function contractbalance() view public returns (uint256){

        return address(this).balance;

    } 

}