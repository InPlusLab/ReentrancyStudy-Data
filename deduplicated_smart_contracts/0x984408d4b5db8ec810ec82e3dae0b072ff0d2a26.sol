/**

 *Submitted for verification at Etherscan.io on 2019-03-21

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

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

    }

    

    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

    return c;

    }

    

     /**

    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

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



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

*/



contract owned {

    address public owner;



    constructor () public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    

    /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */



    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;

    }

}



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



contract TST_ERC is owned {

    using SafeMath for uint;

    // Public variables of the token

    string public name = "TRIPSIA blockchain based payment";

    string public symbol = "TST";

    uint8 public decimals = 0;

    uint256 public totalSupply = 1 * 10 ** uint256(decimals);



   

    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    mapping (address => bool) public frozenAccount;

    

   // This generates a public event on the blockchain that will notify clients

    event Transfer(address indexed from, address indexed to, uint256 value);

    

    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);

    

    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);

    

    /**

     * Constrctor function

     *

     * Initializes contract with initial supply tokens to the creator of the contract

     */

    constructor () public {

        balanceOf[owner] = totalSupply;

    }

    

     /**

     * Internal transfer, only can be called by this contract

     */

     

     function _transfer(address _from, address _to, uint256 _value) internal {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != 0x0);

        // Check if the sender has enough

        require(balanceOf[_from] >= _value);

        // Check for overflows

        require(balanceOf[_to] + _value > balanceOf[_to]);

        // Check if sender is frozen

        require(!frozenAccount[_from]);

        // Check if recipient is frozen

        require(!frozenAccount[_to]);

        // Save this for an assertion in the future

        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];

        // Subtract from the sender

        balanceOf[_from] -= _value;

        // Add the same to the recipient

        balanceOf[_to] += _value;

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

    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

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

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] -= _value;

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

    

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

    /// @param target Address to be frozen

    /// @param freeze either to freeze it or not

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }

    

    /// @notice Create `mintedAmount` tokens and send it to `target`

    /// @param target Address to receive the tokens

    /// @param mintedAmount the amount of tokens it will receive

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        balanceOf[target] += mintedAmount;

        totalSupply += mintedAmount;

        emit Transfer(this, target, mintedAmount);

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

        balanceOf[msg.sender] -= _value;            // Subtract from the sender

        totalSupply -= _value;                      // Updates totalSupply

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

        balanceOf[_from] -= _value;                         // Subtract from the targeted balance

        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance

        totalSupply -= _value;                              // Update totalSupply

        emit Burn(_from, _value);

        return true;

    }





    /**

    *@notice Withdraw for Ether

    */

     function withdraw(uint withdrawAmount) onlyOwner public  {

          if (withdrawAmount <= address(this).balance) {

            owner.transfer(withdrawAmount);

        }

        

     }

    

    function () public payable {

       

    }

     

}