/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.4.21;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

/// Contract for nonprofit tokens
contract Nonprofit {
    uint256 constant _decimals = 18;

    // Public variables of the token
    string public name;
    string public symbol;
    /// 18 decimals is the strongly suggested default, avoid changing it
    uint8 public decimals = uint8(_decimals);

    uint256 constant initialSupply = 10**24; // an arbitrary big number to represent infinity

    /// Does not include our "infinite" account
    uint256 public totalSupply;

    /// Total amount of Ether received
    uint256 public etherReceived;

    address owner; /// the creator of the contract, not public for more security

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);


    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with infinite supply tokens to the creator of the contract
     */
    function Nonprofit(
        string tokenName,
        string tokenSymbol
    ) public {
        owner = msg.sender;
        totalSupply = 0;  // Update total supply with the decimal amount
        balanceOf[owner] = initialSupply * 10**_decimals; // arbitrary septillion of the token
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

    /**
     * Change contract owner.
     */
    function setOwner(address _owner) public {
        require(msg.sender == owner);
        if(_owner == owner) return;
        totalSupply -= balanceOf[_owner];
        balanceOf[owner] = 0;
        balanceOf[_owner] = initialSupply * 10**_decimals;
        owner = _owner;
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
        if(_from != _to) {
            if(_from == owner) {
                uint256 newTotalSupply = totalSupply + _value;
                require(newTotalSupply >= totalSupply); // Check for overflows
                totalSupply = newTotalSupply;
            } else {
                balanceOf[_from] -= _value;
            }
            if(_to == owner) {
                assert(totalSupply >= _value);
                totalSupply -= _value;
            } else {
                uint256 newBalance = balanceOf[_to] + _value;
                require(newBalance >= balanceOf[_to]); // Check for overflows
                balanceOf[_to] = newBalance;
            }
        }
        emit Transfer(_from, _to, _value);
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
     * Send `_value` tokens to `_to` on behalf of `_from`
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
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success)
    {
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
        if(msg.sender == owner) return true; // ignore
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
        if(_from == owner) return true; // ignore
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }

    // Guards against integer overflows
//    function safeMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
//        if (a == 0) {
//            return 0;
//        } else {
//            uint256 c = a * b;
//            assert(c / a == b);
//            return c;
//        }
//    }

    // Receive Ether

    /**
     * Accept payments in Ether and send in exchange e^2/(T+e) tokens where
     * e is the amount of Ether received in this payment and T is the total
     * amount of Ether received to our token before this payment.
     */
    function() public payable {
        if(msg.value == 0) {
            emit Transfer(0x0, msg.sender, 0);
        } else {
            uint256 newEtherReceived = etherReceived + msg.value;
            assert(newEtherReceived >= etherReceived);
            uint256 numberOfTokens = msg.value * msg.value / newEtherReceived;
            _transfer(owner, msg.sender, numberOfTokens);
            etherReceived = newEtherReceived;
            totalSupply = totalSupply + numberOfTokens;

            emit Transfer(0x0, msg.sender, numberOfTokens);
        }
    }

    /**
     * Withdraw Ether for nonprofit use.
     *
     * @param _address the address of the recipient (0 to use the default wallet)
     * @param _amount the amount to send (in wei)
     */
    function withdrawEther(address _address, uint256 _amount) public {
        require(msg.sender == owner);
        if(_address == 0)
            msg.sender.transfer(_amount);
        else
            _address.transfer(_amount);
    }
}