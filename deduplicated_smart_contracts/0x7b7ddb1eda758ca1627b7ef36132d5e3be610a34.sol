/**
 *Submitted for verification at Etherscan.io on 2020-04-01
*/

pragma solidity >=0.4.21 <0.6.0;

contract owned {

    address public owner;
    address[] public admins;
    mapping (address => bool) public isAdmin;

    constructor() public {
        owner = msg.sender;
        isAdmin[msg.sender] = true;
        admins.push(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not owner.");
        _;
    }

    modifier onlyAdmin {
        require(isAdmin[msg.sender], "You are not administrator.");
        _;
    }

    function addAdmin(address user) public onlyOwner {
        require(!isAdmin[user], "This user is already an administrator.");
        isAdmin[user] = true;
        admins.push(user);
    }

    function removeAdmin(address user) public onlyOwner {
        require(isAdmin[user], "User is not an administrator.");
        isAdmin[user] = false;
        for (uint i = 0; i < admins.length - 1; i++)
            if (admins[i] == user) {
                admins[i] = admins[admins.length - 1];
                break;
            }
        admins.length -= 1;
    }

    function replaceAdmin(address oldAdmin, address newAdmin) public onlyOwner {
        require(isAdmin[oldAdmin], "oldAdmin is not an administrator.");
        require(!isAdmin[newAdmin], "newAdmin is already an administrator.");
        for (uint i = 0; i < admins.length; i++)
            if (admins[i] == oldAdmin) {
                admins[i] = newAdmin;
                break;
            }
        isAdmin[oldAdmin] = false;
        isAdmin[newAdmin] = true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function getAdmins() public view returns (address[] memory) {
        return admins;
    }

}


interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}


contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
     constructor(
        uint256 initialSupply,
        address initTarget,
        string memory tokenName,
        string memory tokenSymbol
     ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[initTarget] = totalSupply;                    // Give the target address all initial tokens
        name = tokenName;                                       // Set the name for display purposes
        symbol = tokenSymbol;                                   // Set the symbol for display purposes
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0), "Cannot tranfer to 0x0.");
        // Check if the sender has enough
        require(balanceOf[_from] >= _value, "Insufficient balance.");
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to], "Invalid transfer amount.");
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
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance.");     // Check allowance
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
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
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
        require(balanceOf[msg.sender] >= _value, "Insufficient sender balance.");   // Check if the sender has enough
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
        require(balanceOf[_from] >= _value, "Insufficient target balance."); // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance.");    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}


contract WecreateToken is owned, TokenERC20 {

    mapping (address => bool) public frozenAccount;

    event FrozenFunds(address target, bool frozen);
    event Issue(uint256 amount);

    /* Initializes contract with initial supply tokens to the target address */
     constructor(
        uint256 initialSupply,
        address initTarget,
        string memory tokenName,
        string memory tokenSymbol
     ) TokenERC20(initialSupply, initTarget, tokenName, tokenSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != address(0), "Cannot tranfer to 0x0.");     // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value, "Insufficient sender balance."); // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to], "Invalid transfer amount."); // Check for overflows
        require(!frozenAccount[_from], "Sender is frozen.");  // Check if sender is frozen
        require(!frozenAccount[_to], "Receiver is frozen.");  // Check if recipient is frozen
        balanceOf[_from] -= _value;                           // Subtract from the sender
        balanceOf[_to] += _value;                             // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /* issue `amount` tokens to `owner` */
    function issue(uint256 amount) public onlyOwner  {
        require(totalSupply + amount > totalSupply, "Invalid issue amount.");
        require(balanceOf[owner] + amount > balanceOf[owner], "Invalid issue amount.");
        balanceOf[owner] += amount;
        totalSupply += amount;
        emit Issue(amount);
    }

    /* `freeze? Prevent | Allow` `target` from sending & receiving tokens */
    function freezeAccount(address target, bool freeze) public onlyAdmin {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    function changeName(string memory _name) public onlyOwner {
        name = _name;
    }

    function changeSymbol(string memory _symbol) public onlyOwner {
        symbol = _symbol;
    }

}