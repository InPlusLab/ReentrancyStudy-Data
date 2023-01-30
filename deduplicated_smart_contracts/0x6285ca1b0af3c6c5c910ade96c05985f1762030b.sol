/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

// File: contracts/contracts/math/Math.sol

pragma solidity ^0.5.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
    /**
     * @dev Returns the amount of tokens in existence.
     */

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;


/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 9;
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
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
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

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

// File: contracts/contracts/ownership/MultOwnable.sol

pragma solidity ^0.5.0;


contract MultOwnable {
  address[] private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() internal {
    _owner.push(msg.sender);
    emit OwnershipTransferred(address(0), _owner[0]);
  }

  function checkOwner() private view returns (bool) {
    for (uint8 i = 0; i < _owner.length; i++) {
      if (_owner[i] == msg.sender) {
        return true;
      }
    }
    return false;
  }

  function checkNewOwner(address _address) private view returns (bool) {
    for (uint8 i = 0; i < _owner.length; i++) {
      if (_owner[i] == _address) {
        return false;
      }
    }
    return true;
  }

  modifier isAnOwner() {
    require(checkOwner(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public isAnOwner {
    for (uint8 i = 0; i < _owner.length; i++) {
      if (_owner[i] == msg.sender) {
        _owner[i] = address(0);
        emit OwnershipTransferred(_owner[i], msg.sender);
      }
    }
  }

  function getOwners() public view returns (address[] memory) {
    return _owner;
  }

  function addOwnerShip(address newOwner) public isAnOwner {
    _addOwnerShip(newOwner);
  }

  function _addOwnerShip(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    require(checkNewOwner(newOwner), "Owner already exists");
    _owner.push(newOwner);
    emit OwnershipTransferred(_owner[_owner.length - 1], newOwner);
  }
}

// File: contracts/TulipToken.sol

pragma solidity ^0.5.16;



contract TulipToken is MultOwnable, ERC20{
    constructor (string memory name, string memory symbol) public ERC20(name, symbol) MultOwnable(){
    }

    function contractMint(address account, uint256 amount) external isAnOwner{
        _mint(account, amount);
    }

    function contractBurn(address account, uint256 amount) external isAnOwner{
        _burn(account, amount);
    }


     /* ========== RESTRICTED FUNCTIONS ========== */
    function addOwner(address _newOwner) external isAnOwner {
        addOwnerShip(_newOwner);
    }

    function getOwner() external view isAnOwner{
        getOwners();
    }

    function renounceOwner() external isAnOwner {
        renounceOwnership();
    }
}

// File: contracts/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: contracts/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
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
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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
}

// File: contracts/GardenContractV2.sol

pragma solidity ^0.5.16;






contract GardenContractV2 is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for TulipToken;
  using SafeERC20 for IERC20;

  /* ========== STATE VARIABLES ========== */
  address internal _benefitiaryAddress = 0x68c1A22aD90f168aa19F800bFB115fB4D52F4AD9; //Founder Address

  uint256 internal _epochBlockStart = 1600610400;

  uint256 internal _timeScale = (1 days);

  //uint8 private _pinkTulipDivider = 100;

  uint256 private _decimalConverter = 10**9;

  uint256[3] internal _totalGrowing;

  uint256[3] internal _totalGrown; /* REMEMBER THE DIFFERENCE */

  uint256[3] internal _totalBurnt;

  uint256[2] internal _totalDecomposed;

  TulipToken[3] private _token;

  uint256[3] private _totalSupply;

  struct  tulipToken{
      mapping(address => bool)      forSeeds;
      mapping(address => uint256)   planted;
      mapping(address => uint256)   periodFinish; //combine with decomposing
      mapping(address => bool)      isDecomposing;
  }

  tulipToken[10][3] private _tulipToken;


  /* ========== CONSTRUCTOR ========== */

  constructor(address _seedToken, address _basicTulipToken, address _advTulipToken) public Ownable() {
    _token[0] = TulipToken(_seedToken);
    _token[1] = TulipToken(_basicTulipToken);
    _token[2] = TulipToken(_advTulipToken);
  }

  /* ========== VIEWS ========== */

    /* ========== internal ========== */

  function totalGardenSupply(string calldata name) external view returns (uint256) {
    uint8 i = tulipType(name);

    return _totalSupply[i] ;
  }

  function totalBedSupply(string calldata name, uint8 garden) external view returns (uint256, bool, bool) {
    uint8 i = tulipType(name);  

    return (_tulipToken[i][garden].planted[msg.sender], _tulipToken[i][garden].isDecomposing[msg.sender], _tulipToken[i][garden].forSeeds[msg.sender]);
  }


  function totalTLPGrowing(string calldata name) external view returns (uint256) {
    uint8 i = tulipType(name);  

    return _totalGrowing[i];
  }

  function totalTLPDecomposed(string calldata name) external view returns (uint256) {
    uint8 i = tulipType(name) - 1;  
    return _totalDecomposed[i];
  }

  function totalTLPGrown(string calldata name) external view returns (uint256) {
    uint8 i = tulipType(name);  

    return _totalGrown[i];
  }

  function totalTLPBurnt(string calldata name) external view returns (uint256) {
    uint8 i = tulipType(name);  

    return _totalBurnt[i];
  }

  function growthRemaining(address account, string calldata name, uint8 garden) external view returns (uint256) {
    uint8 i = tulipType(name);
    return _tulipToken[i][garden].periodFinish[account].sub(now);
  }

  function timeUntilNextTLP(string calldata name, uint8 garden) external view returns (uint256) {
    uint256 plantTimeSeconds = _tulipToken[tulipType(name)][garden].periodFinish[msg.sender].sub(7 * _timeScale);
    uint256 secondsDifference = now - plantTimeSeconds;
    uint256 weeksSincePlanting = (secondsDifference).div(60).div(60).div(24).div(7);
    //uint256 weeksSincePlanting = (secondsDifference).div(7);

    if((((secondsDifference).div(60).div(60).div(24)) % 7) > 0){
      //if((((secondsDifference)) % 7) > 0){
      weeksSincePlanting = weeksSincePlanting.add(1);
      
      return plantTimeSeconds.add(weeksSincePlanting.mul(7 * _timeScale)).sub(secondsDifference);
    }
    else{
      return 0;
    }
  }

  function balanceOf(address account, string calldata name) external view returns (uint256)
  {
    uint8 i = tulipType(name);
    uint256 total;

    for(uint8 k; k < _tulipToken[0].length; k++){
      total = total + _tulipToken[i][k].planted[account];
    }

    return total;
  }


  function getTotalrTLPHarvest(uint8 garden) external view returns (uint256){
    uint256 total;
    if(garden > 10){
      for(uint8 k; k < _tulipToken[0].length; k++){
        total = total + redTulipRewardAmount(k);
      }
    }
    else{
      total = redTulipRewardAmount(garden);
    }
    
    return total;
  }

  function getTotalpTLPHarvest(uint8 garden) external view returns (uint256[2] memory){
    uint256[2] memory total;
      if(_tulipToken[1][garden].forSeeds[msg.sender]){
        total[1] = pinkTulipRewardAmount(garden);
      }
      else{
        total[0] = _tulipToken[1][garden].planted[msg.sender];
      }
   
    return total;
  }

  function getTotalsTLPHarvest(uint8 garden) external view returns (uint256){
    uint256 total;
      total = _tulipToken[0][garden].planted[msg.sender];
    return total;
  } 

  /* ========== MUTATIVE FUNCTIONS ========== */

    /* ========== internal garden ========== */

  function plant(uint256 amount, string calldata name, uint8 garden, bool forSeeds) external { 
    uint8 i = tulipType(name);
    //require(amount >= 1, "199");//Cannot stake less than 1
    require(_tulipToken[i][garden].planted[msg.sender] == 0 && now > _tulipToken[i][garden].periodFinish[msg.sender], 
    "201");//You must withdraw or harvest the previous crop
    if(i == 1 && !forSeeds){
      require((amount % 100) == 0, "203");//Has to be multiple of 100
    }
    
    _token[i].safeTransferFrom(msg.sender, address(this), amount.mul(_decimalConverter));
    _totalSupply[i] = _totalSupply[i].add(amount);
    _tulipToken[i][garden].planted[msg.sender] = _tulipToken[i][garden].planted[msg.sender].add(amount);

    _totalGrowing[i] = _totalGrowing[i] + amount;

    if(forSeeds && i != 0){
      _tulipToken[i][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
      _tulipToken[i][garden].forSeeds[msg.sender] = true;
    }
    else{
      setTimeStamp(i, garden);
    }

    emit Staked(msg.sender, amount);
  }


  function withdraw(string memory name, uint8 garden) public {
    uint8 i = tulipType(name);
    require(!_tulipToken[i][garden].isDecomposing[msg.sender], "226");//Cannot withdraw a decomposing bed
    
    if(now > _tulipToken[i][garden].periodFinish[msg.sender] && _tulipToken[i][garden].periodFinish[msg.sender] > 0 && _tulipToken[i][garden].forSeeds[msg.sender]){
        harvestHelper(name, garden, true);
    }
    else{
        _totalGrowing[i] = _totalGrowing[i].sub(_tulipToken[i][garden].planted[msg.sender]);
    }

    _token[i].safeTransfer(msg.sender, _tulipToken[i][garden].planted[msg.sender].mul(_decimalConverter));

    _tulipToken[i][garden].forSeeds[msg.sender] = false;

    emit Withdrawn(msg.sender, _tulipToken[i][garden].planted[msg.sender]);

    zeroHoldings(i, garden);
  }

  function harvest(string memory name, uint8 garden) public {
    require(!_tulipToken[tulipType(name)][garden].isDecomposing[msg.sender], "245");//Cannot withdraw a decomposing bed

    harvestHelper(name, garden, false);
  }


  function harvestAllBeds(string memory name) public {
    uint8 i;
    uint256[6] memory amount;

    i = tulipType(name);      
    amount = utilityBedHarvest(i);
    for(i = 0; i < 3; i++){
      if(amount[i] > 0){
          _token[i].contractMint(msg.sender, amount[i].mul(_decimalConverter));
          
          _totalGrown[i] = _totalGrown[i].add(amount[i]);
          
          emit RewardPaid(msg.sender, amount[i]);
      }
      if(amount[i + 3] > 0){
          _token[i].contractBurn(address(this), amount[i + 3].mul(_decimalConverter));
          _totalGrowing[i] = _totalGrowing[i].sub(amount[i + 3]);
          _totalBurnt[i] = _totalBurnt[i].add(amount[i + 3]);
      }
    }
  }


 function decompose(string memory name, uint8 garden, uint256 amount) public {
    uint8 i = tulipType(name);
    //require(amount >= 1, "291");//Cannot stake less than 1
    require(_tulipToken[i][garden].planted[msg.sender] == 0 && (_tulipToken[i][garden].periodFinish[msg.sender] == 0 || now > _tulipToken[i][garden].periodFinish[msg.sender]), 
    "293");//Claim your last decomposing reward!
    require(i > 0, "310");//Cannot decompose a seed!

    _token[i].safeTransferFrom(msg.sender, address(this), amount.mul(_decimalConverter));
    _totalSupply[i] = _totalSupply[i].add(amount);
    _tulipToken[i][garden].planted[msg.sender] = amount;
    _tulipToken[i][garden].periodFinish[msg.sender] = now.add(1 * _timeScale);
  
    _tulipToken[i][garden].isDecomposing[msg.sender] = true;

    emit Decomposing(msg.sender, amount);
  }

  // test morning
  function claimDecompose(string memory name, uint8 garden) public {
    uint8 i = tulipType(name);
    require(_tulipToken[i][garden].isDecomposing[msg.sender], "308");//This token is not decomposing
    require(i > 0, "310");//Cannot decompose a seed! //redundant
    //require(_tulipToken[i][garden].planted[msg.sender] > 0, "311");//Cannot decompose 0
    require(now > _tulipToken[i][garden].periodFinish[msg.sender], "312");//Cannot claim decomposition!

    uint256 amount = _tulipToken[i][garden].planted[msg.sender].mul(_decimalConverter);
    uint256 subAmount;
    uint8 scalingCoef;
    // Checks if token is pink (i = 1) or reds
    if(i == 1){
      subAmount = (amount * 4).div(5);
      scalingCoef = 1;
    }
    else{
      subAmount = (amount * 9).div(10);
      scalingCoef = 100;
    }

    // Burns 80% or 90% + (50% * leftovers (this is gone forever from ecosystem)) 
    _token[i].contractBurn(address(this), subAmount + (amount - subAmount).div(2));
    _totalDecomposed[i - 1] = _totalDecomposed[i - 1].add(amount.div(_decimalConverter));

    // Mints the new amount of seeds to owners account
    _token[0].contractMint(msg.sender, subAmount.mul(scalingCoef));
    _totalGrown[0] = _totalGrown[0].add(amount.div(_decimalConverter).mul(scalingCoef));

    // Transfers the remainder to us
    _token[i].safeTransfer(_benefitiaryAddress, (amount - subAmount).div(2));
    

    _tulipToken[i][garden].planted[msg.sender] = 0;
    _totalSupply[i] = _totalSupply[i].sub(amount.div(_decimalConverter));

    _tulipToken[i][garden].isDecomposing[msg.sender] = false;

    emit ClaimedDecomposing(msg.sender, subAmount);
  }

  /* ========== RESTRICTED FUNCTIONS ========== */

      /* ========== internal functions ========== */

  function addTokenOwner(address _tokenAddress, address _newOwner) external onlyOwner
  {
    //require(now > _epochBlockStart.add(30 * _timeScale), "351");//timelocked" //No need anymore since community trust is made

    TulipToken tempToken = TulipToken(_tokenAddress);
    tempToken.addOwner(_newOwner);
  }

  function renounceTokenOwner(address _tokenAddress) external onlyOwner
  {
    //require(now > _epochBlockStart.add(30 * _timeScale), "359");//timelocked" //No need anymore since community trust is made

    TulipToken tempToken = TulipToken(_tokenAddress);
    tempToken.renounceOwner();
  }

  function changeOwner(address _newOwner) external onlyOwner {
    transferOwnership(_newOwner);
  }

  function changeBenefitiary(address _newOwner) external onlyOwner
  {
    //require(now > _epochBlockStart.add(30 * _timeScale), "371");//timelocked" //No need anymore since community trust is made

    _benefitiaryAddress = _newOwner;
  }


  /* ========== HELPER FUNCTIONS ========== */

  function tulipType(string memory name) internal pure returns (uint8) {
    if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("sTLP"))) {
      return 0;
    }
    if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("pTLP"))) {
      return 1;
    }
    if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("rTLP"))) {
      return 2;
    } else {
      return 99;
    }
  }


  function setTimeStamp(uint8 i, uint8 garden) internal{
    if (i == 0) {
      setRewardDurationSeeds(garden);
    }
    if (i == 1) {
      _tulipToken[1][garden].periodFinish[msg.sender] = now.add(30 * _timeScale);
    }
    if (i == 2) {
      _tulipToken[2][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
    }
  }


  function zeroHoldings(uint8 i, uint8 garden) internal{
    _totalSupply[i] = _totalSupply[i] - _tulipToken[i][garden].planted[msg.sender];
    _tulipToken[i][garden].planted[msg.sender] = 0;
    _tulipToken[i][garden].periodFinish[msg.sender] = 0;
  }


  function operationBurnMint(uint8 token, uint8 garden, uint256 amount) internal{
      _token[token].contractBurn(address(this), _tulipToken[token][garden].planted[msg.sender].mul(_decimalConverter));
      _totalBurnt[token] = _totalBurnt[token].add(_tulipToken[token][garden].planted[msg.sender]);
      _totalGrowing[token] = _totalGrowing[token].sub(_tulipToken[token][garden].planted[msg.sender]);

      _token[token + 1].contractMint(msg.sender, amount.mul(_decimalConverter));
      _totalGrown[token + 1] = _totalGrown[token + 1].add(amount);
  }


  function utilityBedHarvest(uint8 token) internal returns(uint256[6] memory){
    uint256[6] memory amount;

     for(uint8 k; k < _tulipToken[0].length; k++){   
       if(!_tulipToken[token][k].isDecomposing[msg.sender]) {
        if (_tulipToken[token][k].planted[msg.sender] > 0 && now > _tulipToken[token][k].periodFinish[msg.sender]){
              /* rTLP harvest condition */
            if (token == 2) {
              amount[0] = amount[0] + redTulipRewardAmount(k).div(_decimalConverter);
              _tulipToken[token][k].periodFinish[msg.sender] = now.add(7 * _timeScale);
            } 
            else {
              /* pTLP harvest condition */
              if(token == 1){
                if(_tulipToken[token][k].forSeeds[msg.sender]){
                  amount[0] = amount[0] + pinkTulipRewardAmount(k).div(_decimalConverter);
                  _tulipToken[token][k].periodFinish[msg.sender] = now.add(7 * _timeScale);
                }
                else{
                  amount[token + 1] = amount[token + 1] + _tulipToken[token][k].planted[msg.sender].div(100);
                  amount[token + 3] = amount[token + 3] + _tulipToken[token][k].planted[msg.sender];
                  zeroHoldings(token, k);
                }
              }
              /* sTLP harvest condition */
              else{
                amount[token + 1] = amount[token + 1] + _tulipToken[token][k].planted[msg.sender];
                amount[token + 3] = amount[token + 3] + _tulipToken[token][k].planted[msg.sender];
                zeroHoldings(token, k);
              }   
            }
        }
          }     
        }
        return(amount);
  }


  function harvestHelper(string memory name, uint8 garden, bool withdrawing) internal {
    uint8 i = tulipType(name);
    if(!withdrawing){
      require(_tulipToken[i][garden].planted[msg.sender] > 0, "464"); //Cannot harvest 0
      require(now > _tulipToken[i][garden].periodFinish[msg.sender], "465");//Cannot harvest until bloomed!
    }

    uint256 tempAmount;

    /* rTLP harvest condition */
    if (i == 2) {
      tempAmount = redTulipRewardAmount(garden);
      _token[0].contractMint(msg.sender, tempAmount);
      _tulipToken[i][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
    } 
    else {
      /* pTLP harvest condition */
      if(i == 1){
        if(_tulipToken[i][garden].forSeeds[msg.sender]){
          tempAmount = pinkTulipRewardAmount(garden);
          _token[0].contractMint(msg.sender, tempAmount);
          _tulipToken[i][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
        }
        else{
          tempAmount = _tulipToken[i][garden].planted[msg.sender].div(100);
          operationBurnMint(i, garden, tempAmount);
          zeroHoldings(i, garden);
        }
      }
      /* sTLP harvest condition */
      else{
        tempAmount = _tulipToken[i][garden].planted[msg.sender];
        operationBurnMint(i, garden, tempAmount);
        zeroHoldings(i, garden);
      }   
    }
 
    _totalGrowing[i] = _totalGrowing[i].sub(_tulipToken[i][garden].planted[msg.sender]);

    emit RewardPaid(msg.sender, tempAmount);
  }
  /* ========== REAL FUNCTIONS ========== */
  
  function setRewardDurationSeeds(uint8 garden) internal returns (bool) {
    uint256 timeSinceEpoch = ((now - _epochBlockStart) / 60 / 60 / 24 / 30) + 1;

    if (timeSinceEpoch >= 7) {
      _tulipToken[0][garden].periodFinish[msg.sender] = now.add(7 * _timeScale);
      return true;
    } else {
      _tulipToken[0][garden].periodFinish[msg.sender] = now.add(
        timeSinceEpoch.mul(1 * _timeScale)
      );
      return true;
    }
  }


  function redTulipRewardAmount(uint8 garden) internal view returns (uint256) {
    //ISSUE WAS HERE {}
    uint256 timeSinceEpoch = (now - _tulipToken[2][garden].periodFinish[msg.sender].sub(7 * _timeScale)).div(60).div(60).div(24);
    //uint256 timeSinceEpoch = (now - _tulipToken[2][garden].periodFinish[msg.sender].sub(7 * _timeScale));
    uint256 amountWeeks = timeSinceEpoch.div(7);
    uint256 value;

    for (uint256 i = amountWeeks; i != 0; i--) {
      uint256 tokens = 10;
      value = value.add(tokens.mul(_decimalConverter));
    }
    
    return value * _tulipToken[2][garden].planted[msg.sender];
  }

  /***************************ONLY WHEN forSeeds is TRUE*****************************8*/
  function pinkTulipRewardAmount(uint8 garden) internal view returns (uint256) {
    uint256 timeSinceEpoch = (now - _tulipToken[1][garden].periodFinish[msg.sender].sub(7 * _timeScale)).div(60).div(60).div(24);
    //uint256 timeSinceEpoch = (now - _tulipToken[1][garden].periodFinish[msg.sender].sub(7 * _timeScale));
    uint256 amountWeeks = timeSinceEpoch.div(7);
    uint256 value;

    for (uint256 i = amountWeeks; i != 0; i--) {
      uint256 tokens = 10;

      value = value.add(tokens.mul(_decimalConverter).div(500));
    }
    
    return value * _tulipToken[1][garden].planted[msg.sender];
  }

  /* ========== EVENTS ========== */
  event Staked(address indexed user, uint256 amount); //add timestamps
  event Withdrawn(address indexed user, uint256 amount);
  event RewardPaid(address indexed user, uint256 reward);
  event Decomposing(address indexed user, uint256 amount);
  event ClaimedDecomposing(address indexed user, uint256 reward);
}