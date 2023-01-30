/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.4.25;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    string public name; // ERC20
    string public symbol; // ERC20
    uint8 public decimals = 18;  // ERC20 £¬decimals You can have the number of decimal points, the smallest token unit. 18 is the recommended default
    uint256 public totalSupply; // ERC20 Total supply

    // Using mapping to save the balance erc20 standard corresponding to each address
    mapping (address => uint256) public balanceOf;
    //Storage control of account erc20 standard
    mapping (address => mapping (address => uint256)) public allowance;

    // Event to notify the client of erc20
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Event to notify the client that the token is consumed by erc20 standard
    event Burn(address indexed from, uint256 value);

    /**
     * Initialize construction
     */
    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Share of supply, which is related to the smallest token unit, share = number of coins * 10 * * decimals.¡£
        balanceOf[msg.sender] = totalSupply;                // Creator owns all tokens
        name = tokenName;                                   // Token name
        symbol = tokenSymbol;                               // Token symbol
    }

    /**
     * Internal realization of token transaction transfer
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Make sure the destination address is not 0x0 because 0x0 addresses represent destruction
        require(_to != 0x0);
        // Check sender balance
        require(balanceOf[_from] >= _value);
        // Make sure the transfer is positive
        require(balanceOf[_to] + _value > balanceOf[_to]);

        // The following are used to check transactions,
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);

        // Use assert to check the code logic.
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     *  Token transaction transfer
     *  Send from your (create trader) account`_ Value token to`_ To account
     * ERC20 standard
     * @param _to Recipient address
     * @param _value Transfer amount
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer of token transactions between account numbers
     * ERC20
     * @param _from 
     * @param _to 
     * @param _value 
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set the number of tokens that an address (contract) can use to create a trader's name.
     *
     * Allow sender`_ Spender costs no more than`_ Value tokens
     * ERC20
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
    returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set the maximum number of tokens that an address (contract) can spend in my name (create trader).
     
     * @param _spender 
     * @param _value 
     * @param _extraData 
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
     * Destroy the tokens specified in my (create trader) account
     *-wrong ERC20
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy the specified token in the user account
     *-wrong ERC20 
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
        Burn(_from, _value);
        return true;
    }
}