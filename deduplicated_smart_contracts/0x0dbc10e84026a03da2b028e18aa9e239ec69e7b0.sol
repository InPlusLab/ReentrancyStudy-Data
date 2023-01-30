/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

// File: zos-lib/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: openzeppelin-eth/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.4.24;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.4.24;




/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is Initializable, IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  function initialize(string name, string symbol, uint8 decimals) public initializer {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }

  uint256[50] private ______gap;
}

// File: contracts/elizabeth/Administrators.sol

pragma solidity ^0.4.24;

contract Administrators {
    mapping (address => bool) public isAdministrator;

    event AdministratorChanged(address user, bool isAdministrator);

    constructor() public {
        isAdministrator[msg.sender] = true;
    }

    modifier onlyAdministrators() {
        require(isAdministrator[msg.sender]);
        _;
    }

    function setAdministrator(address user, bool _isAdministrator) public onlyAdministrators {
        require(user != msg.sender);
        require(isAdministrator[user] != _isAdministrator);
        isAdministrator[user] = _isAdministrator;
        emit AdministratorChanged(user, _isAdministrator);
    }
}

// File: openzeppelin-eth/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: openzeppelin-eth/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;





/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is Initializable, IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param amount The amount that will be created.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != 0);
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 amount) internal {
    require(amount <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }

  uint256[50] private ______gap;
}

// File: contracts/lib/IERC1594.sol

pragma solidity ^0.4.24;

/**
 * @title Standard Interface of ERC1594
 */
interface IERC1594 {

    // Transfers
    function transferWithData(address _to, uint256 _value, bytes _data) public;
    function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) public;

    // Token Issuance
    function isIssuable() external view returns (bool);
    function issue(address _tokenHolder, uint256 _value, bytes _data) external;

    // Token Redemption
    function redeem(uint256 _value, bytes _data) external;
    function redeemFrom(address _tokenHolder, uint256 _value, bytes _data) external;

    // Transfer Validity
    function canTransfer(address _to, uint256 _value, bytes _data) external view returns (byte, bytes32);
    function canTransferFrom(address _from, address _to, uint256 _value, bytes _data) external view returns (byte, bytes32);

    // Issuance / Redemption Events
    event Issued(address indexed _operator, address indexed _to, uint256 _value, bytes _data);
    event Redeemed(address indexed _operator, address indexed _from, uint256 _value, bytes _data);
}

// File: contracts/lib/IERC1644.sol

/// @title IERC1644 Controller Token Operation (part of the ERC1400 Security Token Standards)
/// @dev See https://github.com/SecurityTokenStandard/EIP-Spec

interface IERC1644 {

    // Controller Operation
    function isControllable() external view returns (bool);
    function controllerTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) external;
    function controllerRedeem(address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) external;

    // Controller Events
    event ControllerTransfer(
        address _controller,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event ControllerRedemption(
        address _controller,
        address indexed _tokenHolder,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );
}

// File: openzeppelin-eth/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function initialize(address sender) public initializer {
    _owner = sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[50] private ______gap;
}

// File: contracts/Whitelist.sol

pragma solidity ^0.4.25;



contract Whitelist is Initializable, Ownable {

  mapping(address => bool) private whitelist;
  bool public debugMode;

  function initialize() initializer public {
    Ownable.initialize(msg.sender);
    debugMode = true;
  }

  function isWhitelisted(address user) public view returns (bool) {
    return debugMode || whitelist[user];
  }

  function setWhitelisted(address user, bool _isWhitelisted) onlyOwner public {
    whitelist[user] = _isWhitelisted;
  }

  function toggleDebugMode() public onlyOwner {
    debugMode = !debugMode;
  }
}

// File: contracts/elizabeth/SecurityToken.sol

pragma solidity ^0.4.24;






contract SecurityToken is IERC1594, IERC1644, ERC20, Administrators {
    // Uses status codes from ERC-1066
    byte private constant STATUS_DISALLOWED = 0x10;
    byte private constant STATUS_ALLOWED = 0x11;

    Whitelist public whitelist;

    constructor(address _whitelist) internal {
        whitelist = Whitelist(_whitelist);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(whitelist.isWhitelisted(to), "transfer must be allowed");
        return ERC20.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(whitelist.isWhitelisted(to), "transfer must be allowed");
        return ERC20.transferFrom(from, to, value);
    }

    function transferWithData(address _to, uint256 _value, bytes) public {
        transfer(_to, _value);
    }

    function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) public {
        transferFrom(_from, _to, _value);
    }

    function isControllable() external view returns (bool) {
        return true;
    }

    function controllerTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) onlyAdministrators external {
        ERC20._transfer(_from, _to, _value);
        emit ControllerTransfer(msg.sender, _from, _to, _value, _data, _operatorData);
    }

    function controllerRedeem(address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) onlyAdministrators external {
        revert("Redeeming is not enabled");
    }


    // Token Issuance
    function isIssuable() external view returns (bool) {
        return false;
    }
    function issue(address _tokenHolder, uint256 _value, bytes _data) external {
        revert("Issuing is not enabled");
    }

    // Token Redemption
    function redeem(uint256 _value, bytes _data) external {
        revert("Redeeming is not enabled");
    }
    function redeemFrom(address _tokenHolder, uint256 _value, bytes _data) external {
        revert("Redeeming is not enabled");
    }

    // Transfer Validity
    function canTransfer(address _to, uint256 _value, bytes) external view returns (byte, bytes32) {
        byte status = whitelist.isWhitelisted(_to) ? STATUS_ALLOWED : STATUS_DISALLOWED;
        return (status, 0x0);
    }
    function canTransferFrom(address _from, address _to, uint256 _value, bytes) external view returns (byte, bytes32) {
        byte status = whitelist.isWhitelisted(_to)  ? STATUS_ALLOWED : STATUS_DISALLOWED;
        return (status, 0x0);
    }
}

// File: contracts/elizabeth/Dividends.sol

pragma solidity ^0.4.24;





contract Dividends is SecurityToken {
    using SafeMath for uint256;

    uint256 private scaledDividendPerToken = 0;
    uint256 private scaledRemainder = 0;
    mapping(address => uint256) private scaledDividendBalanceOf;
    mapping(address => uint256) private scaledDividendCreditedTo;
    mapping(address => uint256) public userLastActive;

    uint256 constant RECOVERY_TIMEOUT = 180 days;
    uint256 constant SCALING = uint256(10) ** 8;

    IERC20 private _dividendToken;

    event DividendDistributed(uint totalAmount, address depositor);
    event DividendWithdrawl(address holder, uint amount);
    event DividendTokenChanged(address newToken);
    event DividendRecovered(address holder, address administrator, uint amountRecovered, uint inactivityPeriod);

    constructor(address newDividendToken) public {
        _dividendToken = IERC20(newDividendToken);
        require(_dividendToken.balanceOf(address(this)) == 0, "Requires valid ERC20 dividend token");
        emit DividendTokenChanged(_dividendToken);
    }

    function dividendToken() public view returns (address) {
        return _dividendToken;
    }

    function dividendPerToken() public view returns (uint) {
        return scaledDividendPerToken / SCALING;
    }

    function dividendBalanceOf(address account) public view returns (uint) {
        uint owed = scaledDividendPerToken.sub(scaledDividendCreditedTo[account]);
        uint scaledBalance = scaledDividendBalanceOf[account].add(balanceOf(account).mul(owed));
        return scaledBalance.div(SCALING);
    }

    function minimumDeposit() public view returns (uint256) {
        return totalSupply().div(SCALING);
    }

    function deposit(uint amount) public {
        require(amount >= minimumDeposit(), "Deposit is less than minimum deposit");
        require(_dividendToken.allowance(msg.sender, address(this)) >= amount);
        _dividendToken.transferFrom(msg.sender, address(this), amount);
        uint256 available = amount.mul(SCALING).add(scaledRemainder);
        scaledDividendPerToken = scaledDividendPerToken.add(available.div(totalSupply()));
        scaledRemainder = available % totalSupply();
        emit DividendDistributed(amount, msg.sender);
    }

    function depositPartial(uint amount) public {
        require(amount >= minimumDeposit(), "Deposit is less than minimum deposit");
        require(_dividendToken.allowance(msg.sender, address(this)) >= amount);
        _dividendToken.transferFrom(msg.sender, address(this), amount);

        // Calculate new balances, omitting sender's share
        uint totalSupplyWithoutSender = totalSupply().sub(balanceOf(msg.sender));
        uint256 available = amount.mul(SCALING).add(scaledRemainder);
        uint scaledDividendIncrease = available.div(totalSupplyWithoutSender);
        scaledDividendPerToken = scaledDividendPerToken.add(scaledDividendIncrease);
        scaledRemainder = available.mod(totalSupplyWithoutSender);

        // Update for sender
        scaledDividendCreditedTo[msg.sender] = scaledDividendCreditedTo[msg.sender].add(scaledDividendIncrease);
        userLastActive[msg.sender] = now;

        // Emit event with simulated amount
        uint totalAmount = amount.add(scaledDividendIncrease.mul(balanceOf(msg.sender)) / SCALING);
        emit DividendDistributed(totalAmount, msg.sender);
    }

    function withdraw() public {
        update(msg.sender);
        uint256 amount = scaledDividendBalanceOf[msg.sender] / SCALING;
        scaledDividendBalanceOf[msg.sender] %= SCALING;
        _dividendToken.transfer(msg.sender, amount);
        emit DividendWithdrawl(msg.sender, amount);
    }


    function changeDividendToken(address newToken) public onlyAdministrators {
        IERC20 _oldToken = _dividendToken;
        IERC20 _newToken = IERC20(newToken);
        uint dividendBalance = _oldToken.balanceOf(address(this));

        _dividendToken = _newToken;
        if (dividendBalance > 0) {
            require(_newToken.allowance(msg.sender, address(this)) >= dividendBalance);

            _newToken.transferFrom(msg.sender, address(this), dividendBalance);
            _oldToken.transfer(msg.sender, dividendBalance);
        }

        emit DividendTokenChanged(newToken);
    }

    function recoverDividend(address user) public onlyAdministrators {
        uint inactivityPeriod = now - userLastActive[user];
        require(inactivityPeriod > RECOVERY_TIMEOUT, "User is active");
        uint amount = scaledDividendBalanceOf[user] / SCALING;
        scaledDividendBalanceOf[user] %= SCALING;
        _dividendToken.transfer(msg.sender, amount);
        emit DividendRecovered(user, msg.sender, amount, inactivityPeriod);
    }


    function transfer(address to, uint256 value) public returns (bool) {
        update(msg.sender);
        update(to);

        return SecurityToken.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        update(from);
        update(to);

        return SecurityToken.transferFrom(from, to, value);
    }

    function transferWithData(address _to, uint256 _value, bytes _data) public {
        update(msg.sender);
        update(_to);

        SecurityToken.transferWithData(_to, _value, _data);
    }

    function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) public {
        update(_from);
        update(_to);

        SecurityToken.transferFromWithData(_from, _to, _value, _data);
    }

    function update(address account) internal {
        uint256 owed = scaledDividendPerToken - scaledDividendCreditedTo[account];
        scaledDividendBalanceOf[account] = scaledDividendBalanceOf[account].add(balanceOf(account).mul(owed));
        scaledDividendCreditedTo[account] = scaledDividendPerToken;
        userLastActive[account] = now;
    }
}

// File: contracts/lib/IERC1643.sol

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/1643
 */
interface IERC1643 {
    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);

    function getDocument(bytes32 _name) external view returns (string, bytes32, uint256);
    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;
    function getAllDocuments() external view returns (bytes32[]);
}

// File: contracts/elizabeth/Utils.sol

pragma solidity ^0.4.24;

library Utils {
    function removeElement(bytes32[] storage list, bytes32 element) internal {
        for (uint i = 0; i < list.length; i++) {
            if (list[i] == element) {
                list[i] = list[list.length - 1];
                delete list[list.length - 1];
                list.length--;
            }
        }
    }
}

// File: contracts/elizabeth/Documents.sol

pragma solidity ^0.4.24;




contract Documents is Administrators, IERC1643 {

    struct Document {
        string uri;
        bytes32 documentHash;
        uint256 lastModified;
    }

    mapping (bytes32 => Document) private documents;
    bytes32[] private names;

    function getDocument(bytes32 _name) external view returns (string, bytes32, uint256) {
        return (documents[_name].uri, documents[_name].documentHash, documents[_name].lastModified);
    }

    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external onlyAdministrators {
        require(_name.length > 0, "name of the document must not be empty");
        require(bytes(_uri).length > 0, "external URI to the document must not be empty");
        require(_documentHash.length > 0, "content hash is required, use SHA-256 when in doubt");

        if (documents[_name].lastModified == 0) {
            names.push(_name);
        }
        documents[_name] = Document(_uri, _documentHash, now);
        emit DocumentUpdated(_name, _uri, _documentHash);
    }

    function removeDocument(bytes32 _name) external onlyAdministrators {
        string memory uri = documents[_name].uri;
        bytes32 documentHash = documents[_name].documentHash;

        Utils.removeElement(names, _name);
        delete documents[_name];

        emit DocumentRemoved(_name, uri, documentHash);
    }

    function getAllDocuments() external view returns (bytes32[]) {
        return names;
    }
}

// File: contracts/elizabeth/Metadata.sol

pragma solidity ^0.4.24;



contract Metadata is Administrators {
    mapping (bytes32 => string) private metadata;
    bytes32[] private names;

    event MetadataChanged(bytes32 name, string value);

    function getMetadata(bytes32 name) external view returns (string) {
        return metadata[name];
    }

    function setMetadata(bytes32 name, string value) external onlyAdministrators {
        if (bytes(metadata[name]).length == 0) {
            names.push(name);
        }
        if (bytes(value).length == 0) {
            Utils.removeElement(names, name);
        }

        metadata[name] = value;
        emit MetadataChanged(name, value);
    }

    function getAllMetadata() external view returns (bytes32[]) {
        return names;
    }
}

// File: contracts/elizabeth/IPropertyToken.sol

pragma solidity ^0.4.24;


contract IPropertyToken is IERC20 {
    function canTransfer(address _to, uint256 _value, bytes) external view returns (byte, bytes32);
    function canTransferFrom(address _from, address _to, uint256 _value, bytes) external view returns (byte, bytes32);

    function dividendToken() public view returns (address);
    function dividendPerToken() public view returns (uint);
    function dividendBalanceOf(address account) public view returns (uint);
    function deposit(uint amount) public;
    function depositPartial(uint amount) public;
    function withdraw() public;
    function changeDividendToken(address newToken) public;
    function recoverDividend(address user) public;

    function getDocument(bytes32 _name) external view returns (string, bytes32, uint256);
    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;
    function getAllDocuments() external view returns (bytes32[]);

    function getMetadata(bytes32 name) external view returns (string);
    function setMetadata(bytes32 name, string value) external;
    function getAllMetadata() external view returns (bytes32[]);
}

// File: contracts/elizabeth/PropertyToken.sol

pragma solidity ^0.4.24;








/**
 * @title PropertyTOken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract PropertyToken is IPropertyToken, ERC20Detailed, SecurityToken, Dividends, Documents, Metadata {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor (string name, string symbol, uint supply, address whitelist, address dividendToken)
            public SecurityToken(whitelist) Dividends(dividendToken) {
        ERC20Detailed.initialize(name, symbol, 18);
        _mint(msg.sender, supply);
    }
}