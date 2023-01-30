/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

// File: @openzeppelin/contracts-ethereum-package/contracts/Initializable.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.24 <0.7.0;


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

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: contracts/token/Ownable.sol

pragma solidity ^0.6.0;


/**
 * @title Ownable
 */
contract Ownable is Initializable {
    address private _owner;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "not called by owner");
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     * @param newOwner Address of new owner.
     */
    function __Ownable_init(address newOwner) internal initializer {
        _owner = newOwner;
    }

    // reserved storage slots
    uint256[50] private __gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/token/ERC20.sol

pragma solidity ^0.6.0;




// import "openzeppelin-eth/contracts/token/ERC20/IERC20.sol";
// import "openzeppelin-eth/contracts/math/SafeMath.sol";

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is Initializable, IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public override view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer tokens to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value)
        public
        virtual
        override
        returns (bool)
    {
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
    function approve(address spender, uint256 value)
        public
        virtual
        override
        returns (bool)
    {
        require(spender != address(0), "spender must not be 0x0");

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
    ) public virtual override returns (bool) {
        require(
            value <= _allowed[from][msg.sender],
            "allowance is smaller than the value to transfer"
        );

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        require(spender != address(0), "spender must not be 0x0");

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        require(spender != address(0), "spender must not be 0x0");

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Transfer tokens between specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(value <= _balances[from], "balance is smaller than value");
        require(from != address(0), "from must not be 0x0");
        require(to != address(0), "to must not be 0x0");

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
        require(account != address(0), "account must not be 0x0");
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
        require(account != address(0), "account must not be 0x0");
        require(
            amount <= _balances[account],
            "balance is smaller than the amount to burn"
        );

        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    // reserved storage slots
    uint256[50] private ______gap;
}

// File: contracts/token/ERC20WithFees.sol

pragma solidity ^0.6.0;



/**
 * @title ERC20WithFees
 */
contract ERC20WithFees is Ownable, ERC20 {
    struct Fee {
        uint256 numerator;
        uint256 denominator;
    }

    address public transferFeeReceiver;
    Fee private _transferFee;
    mapping(address => Fee) _individualTransferFee;

    event SetTransferFeeReceiver(address transferFeeReceiver);
    event SetTransferFee(uint256 numerator, uint256 denominator);
    event SetIndividualTransferFee(
        address addr,
        uint256 numerator,
        uint256 denominator
    );

    function __ERC20WithFees_init(address _transferFeeReceiver)
        internal
        initializer
    {
        require(
            _transferFeeReceiver != address(0),
            "_transferFeeReceiver is zero"
        );

        transferFeeReceiver = _transferFeeReceiver;
    }

    /**
     * @dev Sets transferFeeReceiver.
     */
    function setTransferFeeReceiver(address receiver) public onlyOwner {
        require(receiver != address(0), "receiver is zero");
        transferFeeReceiver = receiver;
        emit SetTransferFeeReceiver(receiver);
    }

    /**
     * @return Numerator of transferFee.
     */
    function transferFeeNumerator() public view returns (uint256) {
        return _transferFee.numerator;
    }

    /**
     * @return Denominator of transferFee.
     */
    function transferFeeDenominator() public view returns (uint256) {
        return _transferFee.denominator;
    }

    /**
     * @dev Sets transferFee.
     */
    function setTransferFee(uint256 numerator, uint256 denominator)
        public
        onlyOwner
    {
        require(
            numerator < denominator,
            "numerator is equal to or greater than denominator"
        );
        _transferFee = Fee(numerator, denominator);
        emit SetTransferFee(numerator, denominator);
    }

    /**
     * @return Numerator of addr's transferFee.
     */
    function individualTransferFeeNumerator(address addr)
        public
        view
        returns (uint256)
    {
        return _individualTransferFee[addr].numerator;
    }

    /**
     * @return Denominator of addr's transferFee.
     */
    function individualTransferFeeDenominator(address addr)
        public
        view
        returns (uint256)
    {
        return _individualTransferFee[addr].denominator;
    }

    /**
     * @dev Sets individual's transferFeeNumerator and transferFeeDenominator. Its precedence is higher than global transfer fee.
     */
    function setIndividualTransferFee(
        address addr,
        uint256 numerator,
        uint256 denominator
    ) public onlyOwner {
        require(
            numerator < denominator,
            "numerator is equal to or greater than denominator"
        );
        _individualTransferFee[addr].numerator = numerator;
        _individualTransferFee[addr].denominator = denominator;
        emit SetIndividualTransferFee(addr, numerator, denominator);
    }

    /**
     * @return Calculated transfer fee for the given value.
     */
    function calculateTransferFee(address sender, uint256 value)
        public
        view
        returns (uint256)
    {
        if (_individualTransferFee[sender].denominator > 0) {
            return
                value.mul(_individualTransferFee[sender].numerator).div(
                    _individualTransferFee[sender].denominator
                );
        } else {
            if (_transferFee.denominator > 0) {
                return
                    value.mul(_transferFee.numerator).div(
                        _transferFee.denominator
                    );
            } else {
                return 0;
            }
        }
    }

    // reserved storage slots
    uint256[50] private ______gap;
}

// File: contracts/token/ERC20WithBlacklist.sol

pragma solidity ^0.6.0;



/**
 * @title ERC20WithBlacklist
 */
contract ERC20WithBlacklist is Ownable, ERC20 {
    address[] private _blacklist;
    mapping(address => bool) private _blacklistMap;

    event AddedToBlacklist(address addr);
    event RemovedFromBlacklist(address addr);

    /**
     * @dev Throws if addr is blacklisted.
     */
    modifier notBlacklisted(address addr) {
        require(!_blacklistMap[addr], "addr is blacklisted");
        _;
    }

    /**
     * @param addr The address to check if blacklisted
     * @return true if addr is blacklisted, false otherwise
     */
    function isBlacklisted(address addr) public view returns (bool) {
        return _blacklistMap[addr];
    }

    /**
     * @dev Function to add an address to the blacklist
     * @param addr The address to add to the blacklist
     * @return A boolean that indicates if the operation was successful.
     */
    function addToBlacklist(address addr) public onlyOwner returns (bool) {
        require(!_blacklistMap[addr], "addr is already blacklisted");
        _blacklistMap[addr] = true;
        _blacklist.push(addr);
        emit AddedToBlacklist(addr);
        return true;
    }

    /**
     * @dev Function to remove an address from the blacklist
     * @param addr The address to remove from the blacklist
     * @return A boolean that indicates if the operation was successful.
     */
    function removeFromBlacklist(address addr) public onlyOwner returns (bool) {
        require(_blacklistMap[addr], "addr is not blacklisted");
        _blacklistMap[addr] = false;
        for (uint256 i = 0; i < _blacklist.length; i++) {
            if (_blacklist[i] == addr) {
                _blacklist[i] = _blacklist[_blacklist.length - 1];
                _blacklist.pop();
                break;
            }
        }
        emit RemovedFromBlacklist(addr);
        return true;
    }

    /**
     * @return Length of the blacklist
     */
    function getBlacklistLength() public view returns (uint256) {
        return _blacklist.length;
    }

    /**
     * @return Blacklisted address at index
     */
    function getBlacklist(uint256 index) public view returns (address) {
        require(index < _blacklist.length, "index out of range");
        return _blacklist[index];
    }

    // reserved storage slots
    uint256[50] private ______gap;
}

// File: contracts/token/PausableERC20.sol

pragma solidity ^0.6.0;



/**
 * @title PausableERC20
 */
contract PausableERC20 is Ownable, ERC20 {
    event Paused();
    event Unpaused();

    bool private _paused;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "not paused");
        _;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Called by the owner to pause, triggers stopped state
     * @return A boolean that indicates if the operation was successful.
     */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        _paused = true;
        emit Paused();
        return true;
    }

    /**
     * @dev Called by the owner to unpause, returns to normal state
     * @return A boolean that indicates if the operation was successful.
     */
    function unpause() public onlyOwner whenPaused returns (bool) {
        _paused = false;
        emit Unpaused();
        return true;
    }

    // reserved storage slots
    uint256[50] private ______gap;
}

// File: contracts/token/BurnableERC20.sol

pragma solidity ^0.6.0;



/**
 * @title BurnableERC20
 */
contract BurnableERC20 is Ownable, ERC20 {
    uint256 public burnMin;
    uint256 public burnMax;

    event Burned(address from, uint256 amount);
    event SetBurnBounds(uint256 min, uint256 max);

    /**
     * @dev Burns a specific amount of tokens from the owner account
     * @param amount uint256 The amount of token to be burned
     * @return A boolean that indicates if the operation was successful.
     */
    function burn(uint256 amount) public virtual onlyOwner returns (bool) {
        require(amount >= burnMin, "amount to burn is smaller than burnMin");
        require(
            burnMax == 0 || amount <= burnMax,
            "amount to burn is greater than burnMax"
        );
        _burn(owner(), amount);
        emit Burned(owner(), amount);
        return true;
    }

    /**
     * @dev Set boundaries for the minimum and maximum amount of tokens. Set both values to ZERO to not set boundary.
     * @param min uint256 Minimum amount of tokens that can be burnt
     * @param max uint256 Maximum amount of tokens that can be burnt
     */
    function setBurnBounds(uint256 min, uint256 max) public onlyOwner {
        require(min <= max, "min must be at most max");
        burnMin = min;
        burnMax = max;
        emit SetBurnBounds(min, max);
    }

    // reserved storage slots
    uint256[50] private ______gap;
}

// File: contracts/token/MintableERC20.sol

pragma solidity ^0.6.0;



/**
 * @title MintableERC20
 */
contract MintableERC20 is Ownable, ERC20 {
    uint256 public mintMin;
    uint256 public mintMax;

    event Minted(address to, uint256 amount);
    event SetMintBounds(uint256 min, uint256 max);

    address[] private _mintWhitelist;
    mapping(address => bool) private _mintWhitelistMap;

    event AddedToMintWhitelist(address addr);
    event RemovedFromMintWhitelist(address addr);

    /**
     * @dev Throws if addr is not mint-whitelisted.
     */
    modifier mintWhitelisted(address addr) {
        require(_mintWhitelistMap[addr], "addr is not mint-whitelisted");
        _;
    }

    /**
     * @param addr The address to check if mint-whitelisted
     * @return true if addr is mint-whitelisted, false otherwise
     */
    function isMintWhitelisted(address addr) public view returns (bool) {
        return _mintWhitelistMap[addr];
    }

    /**
     * @dev Function to add an address to the mint-whitelist
     * @param addr The address to add to the mint-whitelist
     * @return A boolean that indicates if the operation was successful.
     */
    function addToMintWhitelist(address addr) public onlyOwner returns (bool) {
        require(!_mintWhitelistMap[addr], "addr is already mint-whitelisted");
        _mintWhitelistMap[addr] = true;
        _mintWhitelist.push(addr);
        emit AddedToMintWhitelist(addr);
        return true;
    }

    /**
     * @dev Function to remove an address from the mint-whitelist
     * @param addr The address to remove from the mint-whitelist
     * @return A boolean that indicates if the operation was successful.
     */
    function removeFromMintWhitelist(address addr)
        public
        onlyOwner
        returns (bool)
    {
        require(_mintWhitelistMap[addr], "addr is not mint-whitelisted");
        _mintWhitelistMap[addr] = false;
        for (uint256 i = 0; i < _mintWhitelist.length; i++) {
            if (_mintWhitelist[i] == addr) {
                _mintWhitelist[i] = _mintWhitelist[_mintWhitelist.length - 1];
                _mintWhitelist.pop();
                break;
            }
        }
        emit RemovedFromMintWhitelist(addr);
        return true;
    }

    /**
     * @return Length of the mint-whitelist
     */
    function getMintWhitelistLength() public view returns (uint256) {
        return _mintWhitelist.length;
    }

    /**
     * @return MintWhitelisted address at index
     */
    function getMintWhitelist(uint256 index) public view returns (address) {
        require(index < _mintWhitelist.length, "index out of range");
        return _mintWhitelist[index];
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 amount)
        public
        virtual
        onlyOwner
        mintWhitelisted(to)
        returns (bool)
    {
        require(amount >= mintMin, "amount to mint is smaller than mintMin");
        require(
            mintMax == 0 || amount <= mintMax,
            "amount to mint is greater than mintMax"
        );
        _mint(to, amount);
        emit Minted(to, amount);
        return true;
    }

    /**
     * @dev Set boundaries for the minimum and maximum amount of tokens. Set both values to ZERO to not set boundary.
     * @param min uint256 Minimum amount of tokens that can be minted
     * @param max uint256 Maximum amount of tokens that can be minted
     */
    function setMintBounds(uint256 min, uint256 max) public onlyOwner {
        require(min <= max, "min must be at most max");
        mintMin = min;
        mintMax = max;
        emit SetMintBounds(min, max);
    }

    // reserved storage slots
    uint256[50] private ______gap;
}

// File: contracts/token/BKRW.sol

pragma solidity ^0.6.0;








/**
 * @title BKRW is a stable token backed 100% by KRW. 1-to-1 ratio of BKRW to KRW sitting in a transparent and audited Korean bank account.
 */
contract BKRW is
    Ownable,
    ERC20,
    ERC20WithFees,
    ERC20WithBlacklist,
    PausableERC20,
    BurnableERC20,
    MintableERC20
{
    using SafeMath for uint256;

    /**
     * @param initialOwner The address who can control the token.
     */
    function initialize(address initialOwner) public initializer {
        require(initialOwner != address(0), "owner is zero");

        Ownable.__Ownable_init(initialOwner);
        ERC20.__ERC20_init("BKRW Token", "BKRW", 2);
        ERC20WithFees.__ERC20WithFees_init(initialOwner);
    }

    /**
     * @dev Transfer tokens to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value)
        public
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        returns (bool)
    {
        bool transferred = super.transfer(to, value);
        if (transferred) {
            uint256 transferFee = calculateTransferFee(msg.sender, value);
            if (transferFee > 0) {
                _transfer(to, transferFeeReceiver, transferFee);
            }
        }
        return transferred;
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
    function approve(address spender, uint256 value)
        public
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        returns (bool)
    {
        return super.approve(spender, value);
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
    ) public override whenNotPaused notBlacklisted(msg.sender) notBlacklisted(from) returns (bool) {
        bool transferred = super.transferFrom(from, to, value);
        if (transferred) {
            uint256 transferFee = calculateTransferFee(from, value);
            if (transferFee > 0) {
                _transfer(to, transferFeeReceiver, transferFee);
            }
        }
        return transferred;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        returns (bool)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        whenNotPaused
        notBlacklisted(msg.sender)
        returns (bool)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 amount)
        public
        override
        whenNotPaused
        returns (bool)
    {
        return super.mint(to, amount);
    }

    /**
     * @dev Burns a specific amount of tokens from the owner account
     * @param amount uint256 The amount of tokens to be burned
     * @return A boolean that indicates if the operation was successful.
     */
    function burn(uint256 amount) public override whenNotPaused returns (bool) {
        return super.burn(amount);
    }

    // reserved storage slots
    uint256[50] private ______gap;
}