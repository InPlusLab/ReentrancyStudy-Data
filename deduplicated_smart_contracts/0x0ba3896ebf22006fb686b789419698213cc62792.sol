/**

 *Submitted for verification at Etherscan.io on 2019-04-12

*/



/*

file:       token

version:    4.6.9

The Greatest Tao is formless

-----------------------------------------------------------------

*/



pragma solidity ^0.4.24;



///

//Math operations with safety checks

///

contract SafeMath {

  function safeMul(uint256 a, uint256 b) internal pure returns (uint256)  {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b > 0);

    uint256 c = a / b;

    assert(a == b * c + a % b);

    return c;

  }



  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c>=a && c>=b);

    return c;

  }



}

///

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





///

// ERC Token Standard #20 Interface

///

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }





///

contract TokenERC20 is SafeMath{

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 18;

    uint256 public _totalSupply;



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

    constructor(uint256 initialSupply,string tokenName,string tokenSymbol) public {

        _totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount

        balanceOf[msg.sender] = _totalSupply;                // Give the creator all initial tokens

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

        uint256 mbalanceofto = SafeMath.safeAdd(balanceOf[_to], _value);

        require(mbalanceofto > balanceOf[_to]);

        // Save this for an assertion in the future

        uint previousBalances = SafeMath.safeAdd(balanceOf[_from],balanceOf[_to]);

        // Subtract from the sender

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from],_value);

        // Add the same to the recipient

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to],_value);

        //

        uint currentBalances = SafeMath.safeAdd(balanceOf[_from],balanceOf[_to]);

        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(currentBalances == previousBalances);

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

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);

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

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);            // Subtract from the sender

        _totalSupply = SafeMath.safeSub(_totalSupply, _value);                      // Updates totalSupply

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

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                         // Subtract from the targeted balance

        // Subtract from the sender's allowance

        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);             

        _totalSupply = SafeMath.safeSub(_totalSupply,_value);                              // Update totalSupply

        emit Burn(_from, _value);

        return true;

    }

}



/******************************************/

/*       ADVANCED TOKEN STARTS HERE       */

/******************************************/



contract BOSCToken is owned, TokenERC20 {



    uint256 public buyPrice=2000;   

    uint256 public sellPrice=2500;     

    uint public minBalanceForAccounts;

    uint256 linitialSupply=428679360;

    string ltokenName="BOSC";

    string ltokenSymbol="BOSC";

    



    mapping (address => bool) public frozenAccount;



    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor() TokenERC20(linitialSupply, ltokenName, ltokenSymbol) public {

    }



    /*Get total Token Supply*/

    function totalSupply() public constant returns (uint totalsupply) {

        totalsupply = _totalSupply ;

    }



      

    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint _value) internal {

        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead

        require (balanceOf[_from] >= _value);               // Check if the sender has enough

        require (SafeMath.safeAdd(balanceOf[_to],_value) >= balanceOf[_to]); // Check for overflows

        require(!frozenAccount[_from]);                     // Check if sender is frozen

        require(!frozenAccount[_to]);                       // Check if recipient is frozen

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                         // Subtract from the sender

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);  // Add the same to the recipient

        emit Transfer(_from, _to, _value);

    }





    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }





    ///default function

    function () public payable {

    }

}