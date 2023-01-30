/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
     
     /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
      /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    
    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public isOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract StandardToken {

    using SafeMath for uint256;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;
    
    /// @return total amount of tokens
    function totalSupply() public constant returns (uint256 supply) {
        return totalSupply;
    }
    
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
     /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     /// @param _from The address of the sender
     /// @param _to The address of the recipient
     /// @param _value The amount of token to be transferred
     /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] = balances[_to].add(_value);
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
      /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract ERC20Token is StandardToken, Ownable {

    using SafeMath for uint256;
    
    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;
    string public symbol;
    string public version = '1.0';
    uint256 public totalCoin;
    uint8 public decimals;
    uint256 public exchangeRate;

    event TokenNameChanged(string indexed previousName, string indexed newName);
    event TokenSymbolChanged(string indexed previousSymbol, string indexed newSymbol);
    event ExhangeRateChanged(uint256 indexed previousRate, uint256 indexed newRate);
     
      // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function ERC20Token() public {
        decimals        = 18;
        totalCoin       = 1000050000;                       // Total Supply of Coin
        totalSupply     = totalCoin * 10**uint(decimals); // Total Supply of Coin
        balances[owner] = totalSupply;                    // Total Supply sent to Owner's Address
        exchangeRate    = 12689;                            // 100 Coins per ETH   (changable)
        symbol          = "KIBL";                       // Your Ticker Symbol  (changable)
        name            = "KIBBLE Tokens";             // Your Coin Name      (changable)
    }

    function changeTokenName(string newName) public isOwner returns (bool success) {
        TokenNameChanged(name, newName);
        name = newName;
        return true;
    }

    function changeTokenSymbol(string newSymbol) public isOwner returns (bool success) {
        TokenSymbolChanged(symbol, newSymbol);
        symbol = newSymbol;
        return true;
    }

    function changeExhangeRate(uint256 newRate) public isOwner returns (bool success) {
        ExhangeRateChanged(exchangeRate, newRate);
        exchangeRate = newRate;
        return true;
    }

    function () public payable {
        fundTokens();
    }

    function fundTokens() public payable {
        require(msg.value > 0);
        uint256 tokens = msg.value.mul(exchangeRate);
        require(balances[owner].sub(tokens) > 0);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        balances[owner] = balances[owner].sub(tokens);
        Transfer(msg.sender, owner, msg.value);
        forwardFunds();
    }

    function forwardFunds() internal {
        owner.transfer(msg.value);
    }
    /* Approves and then calls the receiving contract */
    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes _extraData
    ) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(
            bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))),
            msg.sender,
            _value,
            this,
            _extraData
        )) { revert(); }
        return true;
    }

}