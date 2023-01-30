/**
 *Submitted for verification at Etherscan.io on 2019-07-27
*/

pragma solidity ^0.5.10;

interface Token {
  /// @return total amount of tokens
  function totalSupply() external view returns (uint256 supply);

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) external view returns (uint256 balance);

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) external returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

  /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of wei to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) external returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) external view returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

library SafeMath {
    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function safeDiv(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
}

contract ERC20 is Token {
    using SafeMath for uint256;
    
    mapping (address => uint256) public balance;

    mapping (address => mapping (address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event TransferFrom(address indexed spender, address indexed from, address indexed to, uint256 _value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 constant private MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Can't send to null");

        balance[msg.sender] = balance[msg.sender].safeSub(_value);
        balance[_to] = balance[_to].safeAdd(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Can't send to null");
        require(_to != address(this), "Can't send to contract");
        
        uint256 allowance = allowed[_from][msg.sender];
        require(_value <= allowance || _from == msg.sender, "Not allowed to send that much");

        balance[_to] = balance[_to].safeAdd(_value);
        balance[_from] = balance[_from].safeSub(_value);

        if (allowed[_from][msg.sender] != MAX_UINT256 && _from != msg.sender) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].safeSub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @notice `msg.sender` approves `_spender` to spend `_value` tokens
    *
    * @param _spender The address of the account able to transfer the tokens
    * @param _value The amount of tokens to be approved for transfer
    * @return Whether the approval was successful or not
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "spender can't be null");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    } 

    function totalSupply() public view returns (uint256 supply) {
        return 0;
    }

    function balanceOf(address _owner) public view returns (uint256 ownerBalance) {
        return balance[_owner];
    }
}

contract Ownable {
    address payable public admin;

  /**
   * @dev The Ownable constructor sets the original `admin` of the contract to the sender
   * account.
   */
    constructor() public {
        admin = msg.sender;
    }

  /**
   * @dev Throws if called by any account other than the admin.
   */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Function reserved to admin");
        _;
    }

  /**
   * @dev Allows the current admin to transfer control of the contract to a new admin.
   * @param _newAdmin The address to transfer ownership to.
   */

    function transferOwnership(address payable _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "New admin can't be null");
        admin = _newAdmin;
    }

    function destroy() public onlyAdmin {
        selfdestruct(admin);
    }

    function destroyAndSend(address payable _recipient) public onlyAdmin {
        selfdestruct(_recipient);
    }
}

contract NotTransferable is ERC20, Ownable {
    /// @notice Enables token holders to transfer their tokens freely if true
   /// @param _enabledTransfer True if transfers are allowed in the clone
    bool public enabledTransfer = false;

    function enableTransfers(bool _enabledTransfer) public onlyAdmin {
        enabledTransfer = _enabledTransfer;
    }

    function transferFromContract(address _to, uint256 _value) public onlyAdmin returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(enabledTransfer, "Transfers are not allowed yet");
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(enabledTransfer, "Transfers are not allowed yet");
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(enabledTransfer, "Transfers are not allowed yet");
        return super.approve(_spender, _value);
    }
}

contract Coinstantine is NotTransferable {

    string constant public Name = "Coinstantine";

    string constant public Symbol = "CSN";

    uint8 constant public Decimals = 18;

    uint256 public TotalSupply = 10 ** (8 + 18); // 100_000_000

    constructor() public {
        enabledTransfer = true;
        balance[msg.sender] = TotalSupply;
    }

    function totalSupply() public view returns (uint256 supply) {
        return TotalSupply;
    }
}