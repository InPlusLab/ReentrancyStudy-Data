/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

// File: contracts/src/Math/SafeMath.sol

pragma solidity ^0.5.16;

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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: contracts/src/GCC/Oracle/GCCOracleInterface.sol

pragma solidity ^0.5.16;

contract GCCOracleInterface {

    function testConnection() public pure returns (bool);

    function getAddress() public view returns (address);

    function getFilterLength() public view returns (uint256);

    function getFilter(uint256 index) public view returns (string memory, string memory, string memory, uint256);

    function nowFilter() public view returns (string memory, string memory, string memory, uint256);

    function addProof(address addr, bytes32 txid, uint64 coin) public returns (bool);

    function addProofs(address[] memory addrList, bytes32[] memory txidList, uint64[] memory coinList) public returns (bool);

    function getProof(address addr, bytes32 txid) public view returns (address, bytes32, uint64);

    function getProofs(address addr) public view returns (address[] memory, bytes32[] memory, uint64[] memory);

    function getProofs(address addr, uint cursor, uint limit) public view returns (address[] memory, bytes32[] memory, uint64[] memory);
}

// File: contracts/src/Base/Initializable.sol

pragma solidity ^0.5.16;

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

  //uint256[50] private ______gap;
}

// File: contracts/src/Base/Context.sol

pragma solidity ^0.5.16;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/src/Access/Ownable.sol

pragma solidity ^0.5.16;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/GCC/Oracle/GCCOracleReader.sol

pragma solidity ^0.5.16;



contract GCCOracleReader is Ownable {

    address internal oracleAddr = address(0);
    GCCOracleInterface internal oracle = GCCOracleInterface(oracleAddr);

    function initialize(address sender) public initializer {
        Ownable.initialize(sender);
    }

    /**
     * @dev Sets the address of the oracle contract to use
     *
     * @return true if connection to the new oracle address was successful
     */
    function setOracleAddress(address _oracleAddress) public onlyOwner returns (bool) {
        oracleAddr = _oracleAddress;
        oracle = GCCOracleInterface(oracleAddr);
        return oracle.testConnection();
    }

    /**
     * @dev Returns the address of the boxing oracle being used
     */
    function getOracleAddress() public view returns (address) {
        return oracleAddr;
    }

    /**
     * @dev Tests that the boxing oracle is callable
     */
    function testOracleConnection() public view returns (bool) {
        return oracle.testConnection();
    }

    /**
     * @dev Returns length of added computation proofs
     */
    function getFilterLength() public view returns (uint256) {
        return oracle.getFilterLength();
    }

    /**
     * @dev Returns computation strategy by index.
     */
    function getFilter(uint256 index) public view returns (string memory, string memory, string memory, uint256) {
        return oracle.getFilter(index);
    }

    /**
     * @dev Returns newest computation strategy.
     */
    function nowFilter() public view returns (string memory, string memory, string memory, uint256) {
        return oracle.nowFilter();
    }

    /**
     * @dev Returns existing proof by given address and txid
     */
    function getProof(address addr, bytes32 txid) public view returns (address, bytes32, uint64) {
        return oracle.getProof(addr, txid);
    }

    /**
     * @dev Returns list of all proofs belonging to specified address
     */
    function getProofs(address addr) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {
        return oracle.getProofs(addr);
    }

    /**
     * @dev Returns list of paged proofs belonging to specified address contrainted by cursor and limit
     */
    function getProofs(address addr, uint cursor, uint limit) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {
        return oracle.getProofs(addr, cursor, limit);
    }
}

// File: contracts/src/GCC/Oracle/GCCOracleProofConsumer.sol

pragma solidity ^0.5.16;



contract GCCOracleProofConsumer is GCCOracleReader {
    using SafeMath for uint256;

    uint256 internal _fullAmount;
    uint256 internal _usedAmount;
    mapping(address => uint256) internal _consumedProofs;

    function initialize(address sender, uint256 maxAmount) public initializer {
        _fullAmount = maxAmount;
        GCCOracleReader.initialize(sender);
    }

    /**
     * @dev Proves amount for given address with all accessible proofs.
     */
    function consumeProofs(address addr) public returns (bool) {
        _consumeProofs(addr, 1000);
        return true;
    }

    /**
     * @dev Proves amount for given address with a limit of newly processed proofs.
     */
    function consumeLimitedProofs(address addr, uint256 limit) public returns (bool) {
        _consumeProofs(addr, limit);
        return true;
    }

    /**
     * @dev Returns full consumable amount.
     */
    function getConsumableFullAmount() public view returns (uint256) {
        return _fullAmount;
    }

    /**
     * @dev Returns already used consumable amount.
     */
    function getConsumableUsedAmount() public view returns (uint256) {
        return _usedAmount;
    }

    /**
     * @dev Returns list of all already consumed proofs
     */
    function getConsumedProofs(address addr) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {
        uint256 consumedLimit = _consumedProofs[addr];
        return oracle.getProofs(addr, 0, consumedLimit);
    }

    /**
     * @dev Returns list of few already consumed proofs constrained by cursor and limit
     */
    function fewConsumedProofs(address addr, uint cursor, uint limit) public view returns (address[] memory, bytes32[] memory, uint64[] memory) {
        uint256 consumedLimit = _consumedProofs[addr].sub(cursor) < limit ? _consumedProofs[addr].sub(cursor) : limit;
        return oracle.getProofs(addr, cursor, consumedLimit);
    }

    /**
     * @dev Internal function for proving amount(s)
     */
    function _consumeProofs(address addr, uint256 limit) internal {
        require(getOracleAddress() != address(0), "GCCOracleProofConsumer: Cannot provably mint tokens while there is no oracle!");

        uint256 prevCursor = _consumedProofs[addr];

        address[] memory addrList;
        bytes32[] memory txidList;
        uint64 [] memory coinList;

        (addrList, txidList, coinList) = getProofs(addr, prevCursor, limit);
        uint256 size = addrList.length;
        if (size == 0) return;

        uint256 nextCursor = prevCursor.add(size);
        uint256 mintAmount = 0;

        for (uint256 i=0; i<size; i++) {
            mintAmount = mintAmount.add(coinList[i]);
        }

        uint256 freeAmount = _fullAmount.sub(_usedAmount);
        require(mintAmount <= freeAmount, "GCCOracleProofConsumer: Cannot mint more tokens, limit exhausted!");

        _usedAmount = _usedAmount.add(mintAmount);
        _consumedProofs[addr] = nextCursor;
        _afterConsumeProofs(addr, mintAmount);
    }

    /**
     * @dev Hook to execute when proving amount
     */
    function _afterConsumeProofs(address account, uint256 amount) internal {
    }
}

// File: contracts/src/ERC20/IERC20.sol

pragma solidity ^0.5.16;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: contracts/src/ERC20/ERC20.sol

pragma solidity ^0.5.16;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * We have followed general guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Initializable, Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of `from`'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.16;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is ERC20 {

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    function initialize(string memory name, string memory symbol, uint8 decimals) public initializer {
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
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/ERC20/ERC20Burnable.sol

pragma solidity ^0.5.16;


/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/ERC20/ERC20StakableDiscreetly.sol

pragma solidity ^0.5.16;



/**
 * @dev Extension of {ERC20} that adds staking mechanism.
 */
contract ERC20StakableDiscreetly is ERC20, Ownable {

    uint256 internal _minTotalSupply;
    uint256 internal _maxTotalSupply;

    uint256 internal _stakeStartCheck; //stake start time
    uint256 internal _stakeMinAge; // (3 days) minimum age for coin age: 3D
    uint256 internal _stakeMaxAge; // (90 days) stake age of full weight: 90D
    uint256 internal _stakeMinAmount; // (10**18) 1 token
    uint8 internal _stakePrecision; // (10**18)

    uint256 internal _stakeCheckpoint; // current checkpoint
    uint256 internal _stakeInterval; // interval between checkpoints

    struct stakeStruct {
        uint256 amount; // staked amount
        uint256 minCheckpoint; // timestamp of min checkpoint stakes qualifies for
        uint256 maxCheckpoint; // timestamp of max checkpoint stakes qualifies for
    }

    uint256 internal _stakeSumReward;
    uint256[] internal _stakeRewardAmountVals;
    uint256[] internal _stakeRewardTimestamps;

    mapping(address => stakeStruct) internal _stakes; // stakes
    mapping(uint256 => mapping(uint256 => uint256)) internal _history; // historical stakes per checkpoint

    uint256[] internal _tierThresholds; // thresholds between tiers
    uint256[] internal _tierShares; // shares of reward per tier

    event Stake(address indexed from, address indexed to, uint256 value);
    event Checkpoint(uint256 timestamp, uint256 minted);

    modifier activeStake() {
        require(_stakeStartCheck > 0, "ERC20: Staking has not started yet!");
        _tick();
        _;
    }

    function initialize(
        address sender, uint256 minTotalSupply, uint256 maxTotalSupply, uint8 stakePrecision
    ) public initializer
    {
        Ownable.initialize(sender);

        _minTotalSupply = minTotalSupply;
        _maxTotalSupply = maxTotalSupply;
        _mint(sender, minTotalSupply);

        _stakePrecision = stakePrecision;
        _stakeMinAmount = 10**(uint256(_stakePrecision)); // def is 1

        _tierThresholds.push(10**(uint256(_stakePrecision)+6));
        _tierThresholds.push(0);

        _tierShares.push(20); // 20%
        _tierShares.push(80); // 80%
    }

    /**
     * @dev Set staking open timer and additional params.
     */
    function open(
        uint256 stakeMinAmount, uint64 stakeMinAge, uint64 stakeMaxAge, uint64 stakeStart, uint64 stakeInterval
    ) public onlyOwner returns (bool) {
        require(_stakeStartCheck == 0, "ERC20: Contract has been already opened!");
        _stakeInterval = uint256(stakeInterval);
        _stakeStartCheck = uint256(stakeStart);
        _stakeCheckpoint = uint256(stakeStart);
        _stakeMinAge = uint256(stakeMinAge);
        _stakeMaxAge = uint256(stakeMaxAge);
        _stakeMinAmount = stakeMinAmount;
        return true;
    }

    /**
    * @dev Sets reward by timestamp
    */
    function setReward(uint256 timestamp, uint256 amount) public onlyOwner returns (bool) {
        _setReward(timestamp, amount);
        return true;
    }

    /**
     * @dev Gets reward by timestamp
     */
    function getReward(uint256 timestamp) public view returns (uint256) {
        return _getReward(timestamp);
    }

    /**
     * @dev Returns number of coins staked by `account`
     */
    function stakeOf(address account) public view returns (uint256) {
        return _stakeOf(account);
    }

    /**
     * @dev Returns number of valid coins staked by `account`
     */
    function activeStakeOf(address account) public view returns (uint256) {
        return _stakeOf(account, _nextCheckpoint());
    }

    /**
     * @dev Stakes all of user tokens and reward if possible.
     *
     * Emits {Stake} event indicating amount of tokens staked.
     */
    function restake() public activeStake returns (bool) {
        _restake(_msgSender(), _nextCheckpoint());
        return true;
    }

    /**
     * @dev Stakes specified `amount` of user tokens.
     *
     * Emits {Stake} event indicating amount of tokens staked.
     */
    function stake(uint256 amount) public activeStake returns (bool) {
        _stake(_msgSender(), amount, _nextCheckpoint());
        return true;
    }

    /**
     * @dev Stake all of user tokens.
     *
     * Emits {Stake} event indicating amount of tokens staked.
     */
    function stakeAll() public activeStake returns (bool) {
        _stake(_msgSender(), balanceOf(_msgSender()),  _nextCheckpoint());
        return true;
    }

    /**
     * @dev Stakes specified `amount` of user tokens.
     *
     * Emits {Stake} event indicating amount of tokens staked.
     */
    function unstake(uint256 amount) public activeStake returns (bool) {
        _unstake(_msgSender(), amount, _nextCheckpoint());
        return true;
    }

    /**
     * @dev Unstakes all of user tokens.
     *
     * Emits {Stake} event indicating amount of tokens unstaked.
     */
    function unstakeAll() public activeStake returns (bool) {
        _unstake(_msgSender(), stakeOf(_msgSender()), _nextCheckpoint());
        return true;
    }

    /**
     * @dev Withdraw user's reward for staking his tokens.
     *
     * Emits {Transfer} event.
     * Emits {Stake} event.
     */
    function withdrawReward() public activeStake returns (bool) {
        _mintReward(_msgSender(), _nextCheckpoint());
        return true;
    }

    /**
     * @dev Returns the potential reward that user can get for his/her staked coins if he/she was to withdraw it.
     */
    function estimateReward() public view returns (uint256) {
        return _calcReward(_msgSender(), _nextCheckpoint());
    }

    /**
     * @dev Returns upcoming checkpoint timeout
     */
    function nextCheckpoint() public view returns (uint256) {
        return _nextCheckpoint();
    }

    /**
     * @dev Returns previous checkpoint
     */
    function lastCheckpoint() public view returns (uint256) {
        return _lastCheckpoint();
    }

    /**
     * @dev Owner's method to manually update checkpoints.
     */
    function tick(uint256 repeats) public onlyOwner returns (bool) {
        _tick(repeats);
        return true;
    }

    /**
     * @dev Owner's method to manually tick next checkpoint.
     */
    function tickNext() public onlyOwner returns (bool) {
        return _tickNext();
    }

    /**
     * @dev Reward user.
     */
    function rewardStaker(address account) public onlyOwner activeStake returns (bool) {
        _mintReward(account, _nextCheckpoint());
        return true;
    }

    /**
     * @dev Returns number of coins staked by `account`.
     *
     * This function returns number of all coins staked regardless of the time range.
     */
    function _stakeOf(address account) internal view returns (uint256) {
        return _stakes[account].amount;
    }

    /**
     * @dev Returns number of coins staked by `account`
     *
     * This function returns number of only valid staked coins.
     */
    function _stakeOf(address account, uint256 checkpoint) internal view returns (uint256) {
        if (_stakes[account].minCheckpoint <= checkpoint && _stakes[account].maxCheckpoint > checkpoint) {
            return _stakes[account].amount;
        }
        return 0;
    }

    /**
     * @dev Returns upcoming checkpoint timeout
     */
    function _nextCheckpoint() internal view returns (uint256) {
        return _stakeCheckpoint;
    }

    /**
     * @dev Returns previous checkpoint
     */
    function _lastCheckpoint() internal view returns (uint256) {
        return _stakeCheckpoint.sub(_stakeInterval);
    }

    /**
     * @dev Stakes given amount of coins belonging to user, with addition of any possible reward.
     *
     * Emits {Stake} event indicating amount of tokens staked.
     *
     * Requirements
     * - `sender` cannot be the zero address
     */
    function _restake(address _sender, uint256 _nxtCheckpoint) internal {
        _unstake(_sender, stakeOf(_sender), _nxtCheckpoint);
        _stake(_sender, balanceOf(_sender), _nxtCheckpoint);
    }

    /**
     * @dev Stakes given amount of coins belonging to user. New stake is always added to the old one, not replaced.
     *
     * Emits {Stake} event indicating amount of tokens staked.
     *
     * Requirements
     * - `sender` cannot be the zero address
     * - `amount` cannot be lesser than `_stakeMinAmount`
     */
    function _stake(address _sender, uint256 _amount, uint256 _nxtCheckpoint) internal {
        require(_sender != address(0), "ERC20Stakable: stake from the zero address!");
        require(_amount >= _stakeMinAmount, "ERC20Stakable: stake amount is too low!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        stakeStruct memory prevStake = _stakes[_sender];
        uint256 _prevAmount = prevStake.amount;
        uint256 _nextAmount = _prevAmount.add(_amount);
        if (_nextAmount == 0) return;

        _unstake(_sender, _prevAmount, _nxtCheckpoint);

        uint256 _minCheckpoint = _nxtCheckpoint.add(_stakeMinAge).sub(_stakeInterval);
        uint256 _maxCheckpoint = _minCheckpoint.add(_stakeMaxAge);

        uint256 _tierNext = _tierOf(_nextAmount);

        uint256 _tmpCheckpoint = _minCheckpoint;
        uint size = _maxCheckpoint.sub(_minCheckpoint).div(_stakeInterval);

        for (uint i = 0; i < size; i++) {
            _history[_tmpCheckpoint][_tierNext] = _history[_tmpCheckpoint][_tierNext].add(_nextAmount);
            _tmpCheckpoint = _tmpCheckpoint.add(_stakeInterval);
        }

        stakeStruct memory nextStake = stakeStruct(_nextAmount, _minCheckpoint, _maxCheckpoint);

        _decreaseBalance(_sender, _nextAmount);
        _stakes[_sender] = nextStake;

        emit Stake(address(0), _sender, _nextAmount);
    }

    /**
     * @dev Unstakes all of the coins staked by the user and put them back into his/her balance.
     *
     * Requirements
     * - `sender` cannot be the zero address
     */
    function _unstake(address _sender, uint256 _amount, uint256 _nxtCheckpoint) internal {
        require(_sender != address(0), "ERC20Stakable: unstake from the zero address!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        _mintReward(_sender, _nxtCheckpoint);

        stakeStruct memory prevStake = _stakes[_sender];
        uint256 _prevAmount = prevStake.amount;
        if (_prevAmount == 0) return;
        uint256 _nextAmount = _prevAmount.sub(_amount);

        uint256 _minCheckpoint = _nxtCheckpoint > prevStake.minCheckpoint ? _nxtCheckpoint : prevStake.minCheckpoint;
        uint256 _maxCheckpoint = prevStake.maxCheckpoint;
        if (_minCheckpoint > _maxCheckpoint) _minCheckpoint = _maxCheckpoint;

        uint256 _tierPrev = _tierOf(_prevAmount);
        uint256 _tierNext = _tierOf(_nextAmount);

        uint256 _tmpCheckpoint = _minCheckpoint;
        uint size = _maxCheckpoint.sub(_minCheckpoint).div(_stakeInterval);

        for (uint i = 0; i < size; i++) {
            _history[_tmpCheckpoint][_tierPrev] = _history[_tmpCheckpoint][_tierPrev].sub(_prevAmount);
            _history[_tmpCheckpoint][_tierNext] = _history[_tmpCheckpoint][_tierNext].add(_nextAmount);
            _tmpCheckpoint = _tmpCheckpoint.add(_stakeInterval);
        }

        stakeStruct memory nextStake = stakeStruct(_nextAmount, prevStake.minCheckpoint, prevStake.maxCheckpoint);

        _stakes[_sender] = nextStake;
        _increaseBalance(_sender, _amount);

        emit Stake(_sender, address(0), _amount);
    }

    /**
     * @dev Mints the reward to which `_address` is entitled to, adds this reward to his/her balance, and restakes his/her
     * staked coins with resetted coinAge.
     *
     * Emits a {Transfer} event indicating the reward received by the user.
     *
     * Requirements
     * - `_address` cannot be the zero address
     */
    function _mintReward(address _address, uint256 _nxtCheckpoint) internal {
        require(_address != address(0), "ERC20Stakable: withdraw from the zero address!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        stakeStruct memory prevStake = _stakes[_address];
        uint256 _prevAmount = prevStake.amount;
        if (_prevAmount == 0) return;

        uint256 _minCheckpoint = prevStake.minCheckpoint;
        uint256 _maxCheckpoint = _nxtCheckpoint < prevStake.maxCheckpoint ? _nxtCheckpoint : prevStake.maxCheckpoint;
        if (_minCheckpoint >= _maxCheckpoint) return;

        uint256 rewardAmount = _getProofOfStakeReward(_address, _minCheckpoint, _maxCheckpoint);
        uint256 remainAmount = _maxTotalSupply.sub(_jointSupply());
        if (rewardAmount > remainAmount) {
            rewardAmount = remainAmount;
        }

        stakeStruct memory nextStake = stakeStruct(_prevAmount, _maxCheckpoint, prevStake.maxCheckpoint);

        _stakes[_address] = nextStake;
        _mint(_address, rewardAmount);
    }

    /**
     * @dev Returns the potential reward that user can get for his/her staked coins if he/she was to withdraw it.
     */
    function _calcReward(address _address, uint256 _nxtCheckpoint) internal view returns (uint256) {
        require(_address != address(0), "ERC20Stakable: calculate reward from the zero address!");
        require(_nxtCheckpoint >= _stakeStartCheck && _stakeStartCheck > 0, "ERC20Stakable: staking has not started yet!");

        stakeStruct memory prevStake = _stakes[_address];
        uint256 _minCheckpoint = prevStake.minCheckpoint;
        uint256 _maxCheckpoint = _nxtCheckpoint < prevStake.maxCheckpoint ? _nxtCheckpoint : prevStake.maxCheckpoint;
        if (_minCheckpoint >= _maxCheckpoint) return 0;
        return _getProofOfStakeReward(_address, _minCheckpoint, _maxCheckpoint);
    }

    /**
     * @dev Returns Proof of Stake Reward for given checkpoint
     */
    function _getProofOfStakeReward(address _address, uint256 _minCheckpoint, uint256 _maxCheckpoint) internal view returns (uint256) {
        if (_minCheckpoint == 0 || _maxCheckpoint == 0) return 0;
        uint256 _curReward = 0;
        uint256 _tmpCheckpoint = _minCheckpoint;
        uint size = _maxCheckpoint.sub(_minCheckpoint).div(_stakeInterval);

        for (uint i = 0; i < size; i++) {
            _curReward = _curReward.add(_getCheckpointReward(_address, _tmpCheckpoint));
            _tmpCheckpoint = _tmpCheckpoint.add(_stakeInterval);
        }
        return _curReward;
    }

    /**
     * @dev Returns reward that owner of _address is entitled to for staking his coins.
     *
     * Requirements:
     * - `_stakeStartCheck` must be lesser or equal to now time and different than zero.
     */
    function _getCheckpointReward(address _address, uint256 _checkpoint) internal view returns (uint256) {
        if (_checkpoint < _stakeStartCheck || _stakeStartCheck <= 0) return 0;
        uint256 maxReward = _getReward(_checkpoint);
        uint256 userStake = _stakeOf(_address);
        uint256 tier = _tierOf(userStake);
        uint256 tierStake = _history[_checkpoint][tier];
        if (tierStake == 0) return 0;
        return maxReward.mul(_tierShares[tier]).div(100).mul(userStake).div(tierStake);
    }

    /**
     * @dev Increases balance of tokens belonging to one user without increasing total supply!
     *
     * This is internal function designed to use when _balances variable is not the only one containing user overall
     * balance. This method changes state of only that variable, so it needs to be used with caution. Make sure to use it
     * properly and to not introduce state inconsistencies!!!
     *
     * Requirements:
     * - `account` cannot be the zero address
     * - `account` must have free space for balance of at least `amount`
     */
    function _increaseBalance(address account, uint256 amount) internal {
        require(account != address(0), "ERC20Stakable: balance increase from the zero address!");
        _balances[account] = _balances[account].add(amount);
    }

    /**
     * @dev Decreases balance of tokens belonging to one user without increasing total supply!
     *
     * This is internal function designed to use when _balances variable is not the only one containing user overall
     * balance. This method changes state of only that variable, so it needs to be used with caution. Make sure to use it
     * properly and to not introduce state inconsistencies!!!
     *
     * Requirements:
     * - `account` cannot be the zero address
     * - `account` must have a balance of at least `amount`
     */
    function _decreaseBalance(address account, uint256 amount) internal {
        require(account != address(0), "ERC20Stakable: balance decrease from the zero address!");
        _balances[account] = _balances[account].sub(amount, "ERC20Stakable: balance decrease amount exceeds balance!");
    }

    /**
     * @dev Returns initial balance with addition to all potential rewards received.
     */
    function _jointSupply() internal view returns (uint256) {
        return _minTotalSupply.add(_stakeSumReward);
    }

    /**
     * @dev Updates checkpoint to the newest one.
     */
    function _tick() internal {
        while (_tickNext()) {}
    }

    /**
     * @dev Updates checkpoint to the newest one with circuit breaker.
     */
    function _tick(uint256 limit) internal {
        for (uint256 max = limit; _tickNext() && max > 0; max--) {}
    }

    /**
     * @dev Updates checkpoint to the next one.
     */
    function _tickNext() internal returns (bool) {
        uint256 _now = uint256(now);
        if (_now >= _stakeCheckpoint && _stakeCheckpoint > 0) {
            _tickCheckpoint(_stakeCheckpoint, _stakeCheckpoint.add(_stakeInterval));
            return true;
        }
        return false;
    }

    /**
     * @dev Updates checkpoint to the next one.
     */
    function _tickCheckpoint(uint256 _prvCheckpoint, uint256 _newCheckpoint) internal {
        uint256 _maxReward = (_prvCheckpoint == _stakeStartCheck) ? 0 :_getReward(_prvCheckpoint);

        _stakeCheckpoint = _newCheckpoint;
        _stakeSumReward = _stakeSumReward.add(_maxReward);

        emit Checkpoint(_prvCheckpoint, _maxReward);
    }

    /**
     * @dev Returns tier of an amount.
     */
    function _tierOf(uint256 _amount) internal view returns (uint256) {
        uint256 tier = 0;
        uint256 tlen = _tierThresholds.length;
        for (uint i = 0; i < tlen; i++) {
            if (tier == i && _tierThresholds[i] != 0 && _tierThresholds[i] <= _amount) tier++;
        }
        return tier;
    }

    /**
    * @dev Sets reward by timestamp
    */
    function _setReward(uint256 timestamp, uint256 amount) internal {
        uint256 _newestLen = _stakeRewardTimestamps.length;
        uint256 _newestTimestamp = _newestLen == 0 ? 0 : _stakeRewardTimestamps[_newestLen-1];
        require(amount >= 0, "ERC20Stakable: future reward set too low");
        require(timestamp >= _newestTimestamp, "ERC20Stakable: future timestamp cannot be set before current timestamp");
        _stakeRewardTimestamps.push(timestamp);
        _stakeRewardAmountVals.push(amount);
    }

    /**
     * @dev Gets reward by timestamp
     */
    function _getReward(uint256 timestamp) internal view returns (uint256) {
        uint256 _currentTimestamp = 0;
        uint256 _currentRewardVal = 0;
        uint256 _rewardLen = _stakeRewardTimestamps.length;
        for (uint256 i=0; i<_rewardLen; i++) {
            if (timestamp >= _stakeRewardTimestamps[i]) {
                _currentTimestamp = _stakeRewardTimestamps[i];
                _currentRewardVal = _stakeRewardAmountVals[i];
            }
        }
        return _currentRewardVal;
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/Role/Roles.sol

pragma solidity ^0.5.16;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: contracts/src/Role/PauserRole.sol

pragma solidity ^0.5.16;




contract PauserRole is Initializable, Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    function initialize(address sender) public initializer {
        if (!isPauser(sender)) {
            _addPauser(sender);
        }
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/Access/Pausable.sol

pragma solidity ^0.5.16;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool internal _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    function initialize(address sender) public initializer {
        PauserRole.initialize(sender);

        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/GCC/GCCDiscreteToken.sol

pragma solidity ^0.5.16;







contract GCCDiscreteToken is GCCOracleProofConsumer, ERC20Detailed, ERC20Burnable, ERC20StakableDiscreetly, Pausable {

    function initialize(
        address sender, string memory name, string memory symbol, uint8 decimals, uint256 minTotalSupply, uint256 maxTotalSupply,
        uint256 provableSupply
    ) public initializer {
        GCCOracleProofConsumer.initialize(sender, provableSupply);
        ERC20Detailed.initialize(name, symbol, decimals);
        ERC20StakableDiscreetly.initialize(sender, minTotalSupply, maxTotalSupply, decimals);
        Pausable.initialize(sender);
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function restake() public whenNotPaused returns (bool) {
        return super.restake();
    }

    function stake(uint256 amount) public whenNotPaused returns (bool) {
        return super.stake(amount);
    }

    function stakeAll() public whenNotPaused returns (bool) {
        return super.stakeAll();
    }

    function unstake(uint256 amount) public whenNotPaused returns (bool) {
        return super.unstake(amount);
    }

    function unstakeAll() public whenNotPaused returns (bool) {
        return super.unstakeAll();
    }

    function withdrawReward() public whenNotPaused returns (bool) {
        return super.withdrawReward();
    }

    function estimateReward() public view whenNotPaused returns (uint256) {
        return super.estimateReward();
    }

    /**
     * @dev Hook to execute when proving amount
     */
    function _afterConsumeProofs(address account, uint256 amount) internal {
        _mint(account, amount);
    }

    //uint256[50] private ______gap;
}

// File: contracts/src/GCCDiscrete.sol

pragma solidity ^0.5.16;


contract GCCDiscrete is GCCDiscreteToken {

    constructor(
        string memory name, string memory symbol, uint8 decimals, uint256 minTotalSupply, uint256 maxTotalSupply,
        uint256 provableSupply
    ) public {
        GCCDiscreteToken.initialize(_msgSender(), name, symbol, decimals, minTotalSupply, maxTotalSupply, provableSupply);
    }
}