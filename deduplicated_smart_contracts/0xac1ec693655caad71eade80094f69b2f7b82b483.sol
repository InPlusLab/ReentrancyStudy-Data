pragma solidity ^0.4.16;


contract EBLCreation {

    //private variable
    address creater;

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    // mapping (address => uint256) public futureBalanceOf;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */

    function EBLCreation(uint256 initialSupply,string tokenName,string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                    // Give the creator all initial tokens
        name = tokenName;                                       // Set the name for display purposes
        symbol = tokenSymbol;                                   // Set the symbol for display purposes
        creater = msg.sender;                             
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
        Transfer(_from, _to, _value);
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
     * adds token to initial supply
     *
     * @param _value the amount of money to be add
     */

    function addInInitialSupply(uint256 _value) public onlyCreater returns (bool success) {
        totalSupply += _value;
        balanceOf[msg.sender] += _value;
        return true;
    }

    /**
     *  removes token from initial supply
     *
     * @param _value the amount of money to be remove
     */

    function removeFromInitialSupply(uint256 _value) public onlyCreater returns (bool success) {
        totalSupply -= _value;
        balanceOf[msg.sender] -= _value;
        return true;
    }

    function tokenBalance() public constant returns (uint256) {
        return (balanceOf[msg.sender]);
    }


    modifier onlyCreater() {
        require(msg.sender == creater);
        _;
    }
}