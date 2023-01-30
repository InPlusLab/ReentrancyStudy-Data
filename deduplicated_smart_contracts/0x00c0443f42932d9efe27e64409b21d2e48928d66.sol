/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

/**
 *Submitted for verification at Etherscan.io on 2019-05-27
*/

pragma solidity ^0.5.8;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}


contract EIP20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract EIP20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}


contract JarvisExchange {
    using SafeMath for uint256;

    constructor(address _escrow) public {
        require(_escrow != address(0));
        escrow = _escrow;
        
        // init token
        // DAI
        TokenAddress[1] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    // escrow has exclusive priveleges to call administrative
    // functions on this contract.
    address public escrow;
    uint public minWithdraw = 1 * 10**16;
    uint public maxWithdraw = 1000000 * 10**18;
    
    // Token Address
    mapping(uint256 => address) public TokenAddress;


    /**
    * list setting function
    */
    mapping(address => bool) public isController;

    /**
     * List event
     */
    event Withdraw(address indexed user, uint amount, uint timeWithdraw, uint tokenIndex);

    modifier onlyEscrow() {
        require(msg.sender == escrow);
        _;
    }

    modifier onlyController {
        require(isController[msg.sender] == true);
        _;
    }

    
    /**
     * Admin function
     */
    function() external payable {}
    function changeEscrow(address _escrow) public
    onlyEscrow
    {
        require(_escrow != address(0));
        escrow = _escrow;
    }

    function changeMinWithdraw(uint _minWithdraw) public
    onlyEscrow
    {
        require(_minWithdraw != 0);
        minWithdraw = _minWithdraw;
    }

    function changeMaxWithdraw(uint _maxNac) public
    onlyEscrow
    {
        require(_maxNac != 0);
        maxWithdraw = _maxNac;
    }

    /// @dev withdraw ether, only escrow can call
    /// @param _amount value ether in wei to withdraw
    function withdrawEther(uint _amount, address payable _to) public
    onlyEscrow
    {
        require(_to != address(0x0));
        // Available at any phase.
        if (address(this).balance > 0) {
            _to.transfer(_amount);
        }
    }

    /**
     * make new controller
     * require input address is not a controller
     * execute any time in sc state
     */
    function setController(address _controller)
    public
    onlyEscrow
    {
        require(!isController[_controller]);
        isController[_controller] = true;
    }

    /**
     * remove controller
     * require input address is a controller
     * execute any time in sc state
     */
    function removeController(address _controller)
    public
    onlyEscrow
    {
        require(isController[_controller]);
        isController[_controller] = false;
    }
    
    /**
     * update token address
     */
    function updateTokenAddress(address payable _tokenAddress, uint _tokenIndex) public
    onlyEscrow
    {
        require(_tokenAddress != address(0));
        TokenAddress[_tokenIndex] = _tokenAddress;
    }


    function withdrawToken(address _account, uint _amount, uint _tokenIndex) public
    onlyController
    {
        require(_account != address(0x0) && _amount != 0);
        require(_amount >= minWithdraw && _amount <= maxWithdraw);
        
        // check valid token index
        require(TokenAddress[_tokenIndex] != address(0));
        EIP20 ERC20Token = EIP20(TokenAddress[_tokenIndex]);
        if (ERC20Token.balanceOf(address(this)) >= _amount) {
            ERC20Token.transfer(_account, _amount);
        } else {
            revert();
        }
        // emit event
        emit Withdraw(_account, _amount, now, _tokenIndex);
    }
}