/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity 0.4.21;

/******************************************/
/*             TickerCash                 */
/*      https://www.tickercash.com/       */
/*     World's first AR Beauty SNS with   */
/*      Live Streaming and Video Call     */
/******************************************/


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract owned {
    address public owner;

    function owned() public {
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

contract TokenERC20 is owned {
    using SafeMath for uint256;
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Mint(address indexed from, uint256 value);
    event Burn(address indexed from, uint256 value);
    event BurnFrom(address indexed from, uint256 value);
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
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
     * Mintable, Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
     
    function mint(uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] += _value;            // Subtract from the sender
        totalSupply += _value;                      // Updates totalSupply
        emit Mint(msg.sender, _value);
        return true;
    } 
    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
    
    function burnfrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[_from] >= _value);   // Check if the sender has enough
        balanceOf[_from] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit BurnFrom(_from, _value);
        return true;
    }

    /**
     * Airdrop tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount with decimals(18)
     *
     */
    mapping (address => uint256) public airDropHistory;
    event AirDrop(address _receiver, uint256 _amount);

  function dropToken(address[] memory receivers, uint256[] memory values) onlyOwner public {
    require(receivers.length != 0);
    require(receivers.length == values.length);

    for (uint256 i = 0; i < receivers.length; i++) {
      address receiver = receivers[i];
      uint256 amount = values[i];

      transfer(receiver, amount);
      airDropHistory[receiver] += amount;

      emit AirDrop(receiver, amount);
    }
  }
    


}

/******************************************/
/*           TickerCash TOKEN             */
/******************************************/
contract TickerCash is owned, TokenERC20 {

    mapping (address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);
    event TransferEnabled (bool);
    event TransferDisabled (bool);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function TickerCash(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20 (initialSupply, tokenName, tokenSymbol) public {
        TransferAllowed = true;
    }
    
    

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);               // Check if the sender has enough
        require (balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        require (TransferAllowed);                          // Check if transfer is enabled
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// Set whether transfer is enabled or disabled
    
    bool public TransferAllowed;

    function enableTokenTransfer() onlyOwner public {
        TransferAllowed = true;
        emit TransferEnabled (true);
    }

    function disableTokenTransfer() onlyOwner public {
        TransferAllowed = false;
        emit TransferDisabled (false);
    }


}