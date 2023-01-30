/**

 *Submitted for verification at Etherscan.io on 2018-09-30

*/



pragma solidity ^0.4.25;

// sol token

// 

// Professor Rui-Shan Lu Team

// Rs Lu  <[email protected]>

// Lursun <[email protected]>

// reference https://ethereum.org/token



contract Owned {

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



contract TokenERC20 is Owned {

    address public deployer;

    // Public variables of the token

    string public name ="AiToken for NewtonXchange";

    string public symbol = "ATN";

    uint8 public decimals = 18;

    // 18 decimals is the strongly suggested default, avoid changing it

    uint256 public totalSupply;



    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    event Approval(address indexed owner, address indexed spender, uint value);



    // This generates a public event on the blockchain that will notify clients

    event Transfer(address indexed from, address indexed to, uint256 value);



    // This notifies clients about the amount burnt

    event Burn(address indexed from, uint256 value);



    /**

     * Constrctor function

     *

     * Initializes contract with initial supply tokens to the creator of the contract

     */

    constructor() public {

        deployer = msg.sender;

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

        require(balanceOf[_to] + _value >= balanceOf[_to]);

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

        require(allowance[_from][msg.sender] >= _value);     // Check allowance

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

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

     * Destroy tokens

     *

     * Remove `_value` tokens from the system irreversibly

     *

     * @param _value the amount of money to burn

     */

    function burn(uint256 _value) onlyOwner public returns (bool success) {

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



contract MyAdvancedToken is TokenERC20 {

    mapping (address => bool) public frozenAccount;



    /* This generates a public event on the blockchain that will notify clients */

    event FrozenFunds(address target, bool frozen);



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor() TokenERC20() public {}



    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint _value) internal {

        require(!frozenAccount[_from]);                     // Check if sender is frozen

        require(!frozenAccount[_to]);                       // Check if recipient is frozen

        super._transfer(_from, _to, _value);

    }



    /// @notice Create `mintedAmount` tokens and send it to `target`

    /// @param target Address to receive the tokens

    /// @param mintedAmount the amount of tokens it will receive

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {

        uint tempSupply = totalSupply;

        balanceOf[target] += mintedAmount;

        totalSupply += mintedAmount;

        require(totalSupply >= tempSupply);

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



    function () payable public {

        require(false);

    }



}



contract ATN is MyAdvancedToken {

    mapping(address => uint) public lockdate;

    mapping(address => uint) public lockTokenBalance;



    event LockToken(address account, uint amount, uint unixtime);



    constructor() MyAdvancedToken() public {}

    function getLockBalance(address account) internal returns(uint) {

        if(now >= lockdate[account]) {

            lockdate[account] = 0;

            lockTokenBalance[account] = 0;

        }

        return lockTokenBalance[account];

    }



    /* Internal transfer, only can be called by this contract */

    function _transfer(address _from, address _to, uint _value) internal {

        uint usableBalance = balanceOf[_from] - getLockBalance(_from);

        require(balanceOf[_from] >= usableBalance);

        require(usableBalance >= _value);                   // Check if the sender has enough

        super._transfer(_from, _to, _value);

    }





    function lockTokenToDate(address account, uint amount, uint unixtime) onlyOwner public {

        require(unixtime >= lockdate[account]);

        require(unixtime >= now);

        require(balanceOf[account] >= amount);

        lockdate[account] = unixtime;

        lockTokenBalance[account] = amount;

        emit LockToken(account, amount, unixtime);

    }



    function lockTokenDays(address account, uint amount, uint _days) public {

        uint unixtime = _days * 1 days + now;

        lockTokenToDate(account, amount, unixtime);

    }



     /**

     * Destroy tokens

     *

     * Remove `_value` tokens from the system irreversibly

     *

     * @param _value the amount of money to burn

     */

    function burn(uint256 _value) onlyOwner public returns (bool success) {

        uint usableBalance = balanceOf[msg.sender] - getLockBalance(msg.sender);

        require(balanceOf[msg.sender] >= usableBalance);

        require(usableBalance >= _value);           // Check if the sender has enough

        return super.burn(_value);

    }

}