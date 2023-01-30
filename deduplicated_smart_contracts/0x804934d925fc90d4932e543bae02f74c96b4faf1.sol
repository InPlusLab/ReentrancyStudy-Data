/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity >=0.5.0 <0.7.0;

contract GK_BP_39759 {
    string public name;
    uint8 public decimals;
    string public symbol;
    // The keyword "public" makes variables
    // accessible from other contracts
    address public minter;
    mapping (address => uint) public balanceOf;

    // Events allow clients to react to specific
    // contract changes you declare
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Sent(address from, address to, uint amount);

    // Constructor code is only run when the contract
    // is created
    constructor() public {
        minter = msg.sender;
        name = "Garage Kit_Banpresto_39759";
        symbol = "GK_BP_39759"; 
        decimals = 3;
        balanceOf[msg.sender] = 101000000;
    }
    // Sends an amount of existing coins
    // from any caller to an address
    function send(address receiver, uint amount) public {
        require(amount <= balanceOf[msg.sender], "Insufficient balance.");
        balanceOf[msg.sender] -= amount;
        balanceOf[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
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
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
}