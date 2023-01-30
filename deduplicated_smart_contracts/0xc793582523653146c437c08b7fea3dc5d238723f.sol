/**

 *Submitted for verification at Etherscan.io on 2019-05-13

*/



pragma solidity >=0.4.22 <0.6.0;



contract owned {

    address public owner;



    constructor(address _owner) public {

        owner = _owner;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner; 

    } 

}





contract MHPERC20 {

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 0;

    // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public totalSupply;



    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

   

    // This generates a public event on the blockchain that will notify clients

    event Transfer(address indexed from, address indexed to, uint256 value);

    



    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);



    /**

     * Constrctor function

     *

     * Initializes contract with initial supply tokens to the creator of the contract

     */

    constructor(

        uint256 initialSupply,

        string memory tokenName,

        string memory tokenSymbol,

        address _owner

    ) public {

        totalSupply = initialSupply;  // Update total supply with the decimal amount

        balanceOf[_owner] = totalSupply;                    // Give the creator all initial tokens

        name = tokenName;                                       // Set the name for display purposes

        symbol = tokenSymbol;                                   // Set the symbol for display purposes

    }



    /**

     * Internal transfer, only can be called by this contract

     */

    function _transfer(address _from, address _to, uint _value) internal {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != address(0x0));

        // Check if the sender has enough

        require(balanceOf[_from] >= _value);

        // Check for overflows

        require(balanceOf[_to] + _value > balanceOf[_to]);

        // Save this for an assertion in the future

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

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

    function transfer(address _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);

        return true;

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



  

}



/******************************************/

/*       ADVANCED TOKEN STARTS HERE       */

/******************************************/



contract MHPToken is owned, MHPERC20 {



  

    mapping (address => bool) public frozenAccount;



    mapping (address => uint256) public frozenOf;



    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);



    event Frozen(address target, uint256 value);



    event UnFrozen(address target, uint256 value);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor(

        uint256 initialSupply,

        string memory tokenName,

        string memory tokenSymbol,

        address _owner

     ) owned(_owner) MHPERC20(initialSupply, tokenName, tokenSymbol,_owner) public {}



    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint _value) internal {

        require (_to != address(0x0));                          // Prevent transfer to 0x0 address. Use burn() instead

        require (balanceOf[_from] >= _value);                   // Check if the sender has enough

        require (balanceOf[_to] + _value >= balanceOf[_to]);    // Check for overflows

        require(!frozenAccount[_from]);                         // Check if sender is frozen

        require(!frozenAccount[_to]);                           // Check if recipient is frozen

        balanceOf[_from] -= _value;                             // Subtract from the sender

        balanceOf[_to] += _value;                               // Add the same to the recipient

        emit Transfer(_from, _to, _value);

    }



    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

    /// @param target Address to be frozen 

    /// @param freeze either to freeze it or not

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }



    modifier  freezeCondition(address target){

        require (target != address(0x0));  

	require(!frozenAccount[target]);

        _;

    }



    function freeze(address target, uint256 _value) freezeCondition(target) onlyOwner public {

        require (balanceOf[target] >= _value); 

	require (frozenOf[target] + _value >= frozenOf[target]); 

	balanceOf[target] -= _value;                          

        frozenOf[target] += _value; 



        emit Frozen(target, _value);

    }



    function unfreeze(address target, uint256 _value)  freezeCondition(target)  onlyOwner public {

	require (frozenOf[target] >= _value); 

	require (balanceOf[target] + _value >= balanceOf[target]); 

	frozenOf[target] -= _value;                          

        balanceOf[target] += _value; 

        emit UnFrozen(target, _value);

    }

 

}