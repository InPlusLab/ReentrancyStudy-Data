/**

 *Submitted for verification at Etherscan.io on 2018-10-24

*/



pragma solidity ^0.4.25;



library SafeMath {

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {

            return 0;

        }

        uint256 c = _a * _b;

        require(c / _a == _b);

        return c;

    }



    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0);

        uint256 c = _a / _b;

        return c;

    }



    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a);

        uint256 c = _a - _b;

        return c;

    }



    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;

        require(c >= _a);

        return c;

    }



    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

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



interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



contract TokenERC20 {



    using SafeMath for uint256;

    // Public variables of the token

    string public name;

    string public symbol;

    uint8 public decimals = 11;

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

}





contract MedallionChainToken is owned, TokenERC20 {

    

    uint256 public buyPrice;

    address public wallet;

    bool public openToSales = false;

   



    mapping (address => bool) public frozenAccount;



    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);

    

    event FundTransfer(address backer, uint256 amount);

    

    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor(

        uint256 initialSupply,

        string tokenName,

        string tokenSymbol,uint256 _buyPrice

    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {

        buyPrice = _buyPrice; 

        wallet = msg.sender;

    }



    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint256 _value) internal {

        

        uint256 value = _value* 10 ** uint256(decimals);

        require (_to != address(0));                         // Prevent transfer to 0x0 address. Use burn() instead

        require (balanceOf[_from] >= value);               // Check if the sender has enough

        require ((balanceOf[_to]).add(value) >= balanceOf[_to]); // Check for overflows

        require(!frozenAccount[_from]);                     // Check if sender is frozen

        require(!frozenAccount[_to]);                       // Check if recipient is frozen

        balanceOf[_from] =  balanceOf[_from].sub(value);                         // Subtract from the sender

        balanceOf[_to] = balanceOf[_to].add(value);                           // Add the same to the recipient

        emit Transfer(_from, _to,( value));

    }



    /// @notice Create `mintedAmount` tokens and send it to `target`

    /// @param target Address to receive the tokens

    /// @param mintedAmount the amount of tokens it will receive

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        balanceOf[target] += mintedAmount;

        totalSupply += mintedAmount;

        emit Transfer(0, this, mintedAmount);

        emit Transfer(this, target, mintedAmount);

    }



    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens

    /// @param target Address to be frozen

    /// @param freeze either to freeze it or not

    function freezeAccount(address target, bool freeze) onlyOwner public {

        frozenAccount[target] = freeze;

        emit FrozenFunds(target, freeze);

    }



    /// @notice Allow users to buy tokens for `newBuyPrice` eth 

    /// @param newBuyPrice Price users can buy from the contract

    /// @param _openToSales activates the contract for local sales

    function setPrices( uint256 newBuyPrice, bool _openToSales) onlyOwner public {

        buyPrice = newBuyPrice; 

        openToSales = _openToSales;

    }

    function() public payable {

        buy();

    }

    

    modifier IsOpenToSales() { if (openToSales) _; }



    /// @notice Buy tokens from contract by sending ether

    function buy() IsOpenToSales  payable public {

       

        _transfer(wallet, msg.sender, msg.value.mul(buyPrice).div(1 ether));              // makes the transfers

    }



    

    function getTokenBalance(address _address) public view returns (uint256){

        return balanceOf[_address];

    }

    

     /**

     * Withdraw the funds

     *

     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,

     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw

     * the amount they contributed.

     */

    function safeWithdrawal() onlyOwner public  {

       address beneficiary  = msg.sender;

       uint256 tokenValue =address(this).balance;



            if (beneficiary.send(tokenValue)) {

               emit FundTransfer(beneficiary, tokenValue);

            } 

    }

}