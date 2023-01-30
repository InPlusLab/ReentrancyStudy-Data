// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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
     *
     * _Available since v2.4.0._
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
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

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
contract Context {
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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
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
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
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
}

// File: contracts/lib/DSMath.sol

// https://github.com/dapphub/ds-math/blob/de45767/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >0.4.13;

contract DSMath {
  function add(uint x, uint y) internal pure returns (uint z) {
    require((z = x + y) >= x, "ds-math-add-overflow");
  }
  function sub(uint x, uint y) internal pure returns (uint z) {
    require((z = x - y) <= x, "ds-math-sub-underflow");
  }
  function mul(uint x, uint y) internal pure returns (uint z) {
    require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
  }

  function min(uint x, uint y) internal pure returns (uint z) {
    return x <= y ? x : y;
  }
  function max(uint x, uint y) internal pure returns (uint z) {
    return x >= y ? x : y;
  }
  function imin(int x, int y) internal pure returns (int z) {
    return x <= y ? x : y;
  }
  function imax(int x, int y) internal pure returns (int z) {
    return x >= y ? x : y;
  }

  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, y), WAD / 2) / WAD;
  }
  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, y), RAY / 2) / RAY;
  }
  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, WAD), y / 2) / y;
  }
  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = add(mul(x, RAY), y / 2) / y;
  }

  // This famous algorithm is called "exponentiation by squaring"
  // and calculates x^n with x as fixed-point and n as regular unsigned.
  //
  // It's O(log n), instead of O(n) for naive repeated multiplication.
  //
  // These facts are why it works:
  //
  //  If n is even, then x^n = (x^2)^(n/2).
  //  If n is odd,  then x^n = x * x^(n-1),
  //   and applying the equation for even x gives
  //  x^n = x * (x^2)^((n-1) / 2).
  //
  //  Also, EVM division is flooring and
  //  floor[(n-1) / 2] = floor[n / 2].
  //
  function wpow(uint x, uint n) internal pure returns (uint z) {
    z = n % 2 != 0 ? x : WAD;

    for (n /= 2; n != 0; n /= 2) {
      x = wmul(x, x);

      if (n % 2 != 0) {
        z = wmul(z, x);
      }
    }
  }

  function rpow(uint x, uint n) internal pure returns (uint z) {
    z = n % 2 != 0 ? x : RAY;

    for (n /= 2; n != 0; n /= 2) {
      x = rmul(x, x);

      if (n % 2 != 0) {
        z = rmul(z, x);
      }
    }
  }
}

// File: contracts/AutoIncrementCoinage.sol

// based on ERC20 implementation of openzeppelin-solidity: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7552af95e4ec6fccd64a95b206f59a1b4ff91517/contracts/token/ERC20/ERC20.sol
pragma solidity ^0.5.12;








/**
 * @dev Implementation of coin age token based on ERC20 of openzeppelin-solidity
 *
 * AutoIncrementCoinage stores `_totalSupply` and `_balances` as RAY BASED value,
 * `_allowances` as RAY FACTORED value.
 *
 * This takes public function (including _approve) parameters as RAY FACTORED value
 * and internal function (including approve) parameters as RAY BASED value, and emits event in RAY FACTORED value.
 *
 * `RAY BASED` = `RAY FACTORED`  / factor
 *
 *  factor increases exponentially for each block mined.
 */
contract AutoIncrementCoinage is Context, IERC20, DSMath, Ownable, ERC20Detailed {
  using SafeMath for uint256;

  mapping (address => uint256) internal _balances;

  mapping (address => mapping (address => uint256)) internal _allowances;

  uint256 internal _totalSupply;

  uint256 internal _factor;

  uint256 internal _factorIncrement;

  uint256 internal _lastBlock;

  bool internal _transfersEnabled;

  event FactorIncreased(uint256 factor);

  modifier increaseFactor() {
    _increaseFactor();
    _;
  }

  modifier onlyTransfersEnabled() {
    require(msg.sender == owner() || _transfersEnabled, "AutoIncrementCoinage: transfer not allowed");
    _;
  }

  constructor (
    string memory name,
    string memory symbol,
    uint256 factor,
    uint256 factorIncrement,
    bool transfersEnabled
  )
    public
    ERC20Detailed(name, symbol, 27)
  {
    _factor = factor;
    _factorIncrement = factorIncrement;
    _lastBlock = block.number;
    _transfersEnabled = transfersEnabled;
  }

  function factor() public view returns (uint256) {
    return _applyFactor(_factor);
  }

  function factorIncrement() public view returns (uint256) {
    return _factorIncrement;
  }

  function lastBlock() public view returns (uint256) {
    return _lastBlock;
  }

  function transfersEnabled() public view returns (bool) {
    return _transfersEnabled;
  }

  function enableTransfers(bool v) public onlyOwner {
    _transfersEnabled = v;
  }

  /**
    * @dev See {IERC20-totalSupply}.
    */
  function totalSupply() public view returns (uint256) {
    // return _toRAYFactored(_totalSupply);
    return _applyFactor(_totalSupply);
  }


  /**
    * @dev See {IERC20-balanceOf}.
    */
  function balanceOf(address account) public view returns (uint256) {
    // return _toRAYFactored(_balances[account]);
    return _applyFactor(_balances[account]);
  }

  /**
    * @dev See {IERC20-transfer}.
    *
    * Requirements:
    *
    * - `recipient` cannot be the zero address.
    * - the caller must have a balance of at least `amount`.
    */
  function transfer(address recipient, uint256 amount) public onlyTransfersEnabled returns (bool) {
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
  function transferFrom(address sender, address recipient, uint256 amount) public onlyTransfersEnabled returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "AutoIncrementCoinage: transfer amount exceeds allowance"));
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
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "AutoIncrementCoinage: decreased allowance below zero"));
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
  function _transfer(address sender, address recipient, uint256 amount) internal increaseFactor {
    require(sender != address(0), "AutoIncrementCoinage: transfer from the zero address");
    require(recipient != address(0), "AutoIncrementCoinage: transfer to the zero address");

    uint256 rbAmount = _toRAYBased(amount);

    _balances[sender] = _balances[sender].sub(rbAmount, "AutoIncrementCoinage: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(rbAmount);
    emit Transfer(sender, recipient, _toRAYFactored(rbAmount));
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
  // function _mint(address account, uint256 amount) internal {
  function _mint(address account, uint256 amount) internal increaseFactor {
    require(account != address(0), "AutoIncrementCoinage: mint to the zero address");

    uint256 rbAmount = _toRAYBased(amount);

    _totalSupply = _totalSupply.add(rbAmount);
    _balances[account] = _balances[account].add(rbAmount);
    emit Transfer(address(0), account, _toRAYFactored(rbAmount));
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
  function _burn(address account, uint256 amount) internal increaseFactor {
    require(account != address(0), "AutoIncrementCoinage: burn from the zero address");

    uint256 rbAmount = _toRAYBased(amount);

    _balances[account] = _balances[account].sub(rbAmount, "AutoIncrementCoinage: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(rbAmount);
    emit Transfer(account, address(0), _toRAYFactored(rbAmount));
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
  function _approve(address owner, address spender, uint256 amount) internal increaseFactor {
    require(owner != address(0), "AutoIncrementCoinage: approve from the zero address");
    require(spender != address(0), "AutoIncrementCoinage: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
    * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
    * from the caller's allowance if caller is not owner.
    * If caller is owner, just burn tokens from `account`
    *
    * See {_burn} and {_approve}.
    */
  function _burnFrom(address account, uint256 amount) internal increaseFactor {
    _burn(account, amount);
    if (!isOwner()) {
      _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "AutoIncrementCoinage: burn amount exceeds allowance"));
    }
  }

  // helpers

  function _increaseFactor() internal {
    uint256 n = block.number - _lastBlock;

    if (n > 0) {
      _factor = _calculateFactor(n);
      _lastBlock = block.number;

      emit FactorIncreased(_factor);
    }
  }

  /**
   * @param v the value to be factored
   */
  function _applyFactor(uint256 v) internal view returns (uint256) {
    if (v == 0) {
      return 0;
    }

    uint256 n = block.number - _lastBlock;

    if (n == 0) {
      return rmul(v, _factor);
    }

    return rmul(v, _calculateFactor(n));
  }

  /**
   * @dev Override _calculateFactor to change factor calculation.
   */
  function _calculateFactor(uint256 n) internal view returns (uint256) {
    return rmul(_factor, rpow(_factorIncrement, n));
  }

  /**
   * @dev Calculate RAY BASED from RAY FACTORED
   */
  function _toRAYBased(uint256 rf) internal view returns (uint256 rb) {
    return rdiv(rf, _factor);
  }

  /**
   * @dev Calculate RAY FACTORED from RAY BASED
   */
  function _toRAYFactored(uint256 rb) internal view returns (uint256 rf) {
    return rmul(rb, _factor);
  }
}

// File: contracts/lib/minime/Controlled.sol

pragma solidity ^0.5.12;

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address payable public controller;

    constructor () public { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address payable _newController) public onlyController {
        controller = _newController;
    }
}

// File: contracts/lib/minime/TokenController.sol

pragma solidity ^0.5.12;

/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

// File: contracts/AutoIncrementCoinageSnapshot.sol

// based on MiniMeToken implementation of giveth: https://github.com/Giveth/minime/blob/ea04d95/contracts/MiniMeToken.sol
pragma solidity ^0.5.12;

/*
  Copyright 2016, Jordi Baylina

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title AutoIncrementCoinageSnapshot Contract
/// @author Jordi Baylina
/// @dev This token contract's goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.






/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract AutoIncrementCoinageSnapshot is IERC20, DSMath, Controlled {

  uint public constant defaultFactor = 10 ** 18;
  uint8 public constant decimals = 18;        // Number of decimals of the smallest unit
  string public name;                         // The Token's name: e.g. DigixDAO Tokens
  string public symbol;                       // An identifier: e.g. REP
  string public version = 'C_MMT_0.1';        // An arbitrary versioning scheme


  /// @dev `Checkpoint` is the structure that attaches a block number to a
  ///  given value, the block number attached is the one that last changed the
  ///  value
  struct  Checkpoint {

    // `fromBlock` is the block number that the value was generated from
    uint128 fromBlock;

    // `value` is the amount of tokens at a specific block number
    uint128 value;
  }

  // `parentToken` is the Token address that was cloned to produce this token;
  //  it will be 0x0 for a token that was not cloned
  AutoIncrementCoinageSnapshot public parentToken;

  // `parentSnapShotBlock` is the block number from the Parent Token that was
  //  used to determine the initial distribution of the Clone Token
  uint public parentSnapShotBlock;

  // `creationBlock` is the block number that the Clone Token was created
  uint public creationBlock;

  // `balances` is the map that tracks the balance of each address, in this
  //  contract when the balance changes the block number that the change
  //  occurred is also included in the map
  mapping (address => Checkpoint[]) balances;

  // `allowed` tracks any extra transfer rights as in all ERC20 tokens
  mapping (address => mapping (address => uint256)) allowed;

  // Tracks the history of the `totalSupply` of the token
  Checkpoint[] totalSupplyHistory;

  // Flag that determines if the token is transferable or not.
  bool public transfersEnabled;

  // The factory used to create new clone tokens
  AutoIncrementCoinageSnapshotFactory public tokenFactory;

  Checkpoint[] factorHistory;

  uint256 public factorIncrement;


////////////////
// Constructor
////////////////

  /// @notice Constructor to create a AutoIncrementCoinageSnapshot
  /// @param _tokenFactory The address of the AutoIncrementCoinageSnapshotFactory contract that
  ///  will create the Clone token contracts, the token factory needs to be
  ///  deployed first
  /// @param _parentToken Address of the parent token, set to 0x0 if it is a
  ///  new token
  /// @param _parentSnapShotBlock Block of the parent token that will
  ///  determine the initial distribution of the clone token, set to 0 if it
  ///  is a new token
  /// @param _tokenName Name of the new token
  /// @param _tokenSymbol Token Symbol for the new token
  /// @param _transfersEnabled If true, tokens will be able to be transferred
  constructor (
    address payable _tokenFactory,
    address payable _parentToken,
    uint _parentSnapShotBlock,
    string memory _tokenName,
    string memory _tokenSymbol,
    uint _factor,
    uint _factorIncrement,
    bool _transfersEnabled
  ) public {
    tokenFactory = AutoIncrementCoinageSnapshotFactory(_tokenFactory);
    name = _tokenName;                  // Set the name
    symbol = _tokenSymbol;              // Set the symbol
    parentToken = AutoIncrementCoinageSnapshot(_parentToken);
    parentSnapShotBlock = _parentSnapShotBlock;
    factorIncrement = _factorIncrement;
    transfersEnabled = _transfersEnabled;
    creationBlock = block.number;

    uint factor = _factor;

    if (isContract(address(parentToken))) {
      factor = parentToken.factorAt(parentSnapShotBlock);
    }

    factorHistory.push(Checkpoint({
      fromBlock: uint128(block.number),
      value: uint128(factor == 0 ? defaultFactor : factor)
    }));
  }


///////////////////
// ERC20 Methods
///////////////////

  /// @notice Send `_amount` tokens to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _amount The amount of tokens to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    require(transfersEnabled);
    doTransfer(msg.sender, _to, _amount);
    return true;
  }

  /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
  ///  is approved by `_from`
  /// @param _from The address holding the tokens being transferred
  /// @param _to The address of the recipient
  /// @param _amount The amount of tokens to be transferred
  /// @return True if the transfer was successful
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {

    // The controller of this contract can move tokens around at will,
    //  this is important to recognize! Confirm that you trust the
    //  controller of this contract, which in most situations should be
    //  another open source smart contract or 0x0
    if (msg.sender != controller) {
      require(transfersEnabled);

      // The standard ERC 20 transferFrom functionality
      require(allowed[_from][msg.sender] >= _amount, "AutoIncrementCoinageSnapshot: transfer amount exceeds allowance");
      allowed[_from][msg.sender] -= _amount;
      emit Approval(_from, msg.sender, allowed[_from][msg.sender]);
    }
    doTransfer(_from, _to, _amount);
    return true;
  }

  /// @dev This is the actual transfer function in the token contract, it can
  ///  only be called by other functions in this contract.
  /// @param _from The address holding the tokens being transferred
  /// @param _to The address of the recipient
  /// @param _amount The amount of tokens in WAD FACTORED to be transferred
  /// @return True if the transfer was successful
  function doTransfer(address _from, address _to, uint _amount) internal increaseFactor {

       if (_amount == 0) {
         emit Transfer(_from, _to, _amount);  // Follow the spec to louch the event when transfer 0
         return;
       }

       require(parentSnapShotBlock < block.number, "T?");

       // Do not allow transfer to 0x0 or the token contract itself
       require(_to != address(0), "AutoIncrementCoinageSnapshot: transfer to the zero address");
       require(_to != address(this), "AutoIncrementCoinageSnapshot: transfer to the token");

       // If the amount being transfered is more than the balance of the
       //  account the transfer throws
       uint previousBalanceFrom = basedBalanceOfAt(_from, block.number);
       uint wbAmount = _toWADBased(_amount, block.number);

       require(previousBalanceFrom >= wbAmount, "AutoIncrementCoinageSnapshot: transfer amount exceeds balance");
       // Alerts the token controller of the transfer
       if (isContract(controller)) {
         require(TokenController(controller).onTransfer(_from, _to, _toWADFactored(wbAmount, block.number)));
       }

       // First update the balance array with the new value for the address
       //  sending the tokens
       updateValueAtNow(balances[_from], previousBalanceFrom - wbAmount);

       // Then update the balance array with the new value for the address
       //  receiving the tokens
       uint previousBalanceTo = basedBalanceOfAt(_to, block.number);
       require(uint128(previousBalanceTo + wbAmount) >= previousBalanceTo); // Check for overflow
       updateValueAtNow(balances[_to], previousBalanceTo + wbAmount);

       // An event to make the transfer easy to find on the blockchain
       emit Transfer(_from, _to, _toWADFactored(wbAmount, block.number));

  }

  /// @param _owner The address that's balance is being requested
  /// @return The balance of `_owner` at the current block
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balanceOfAt(_owner, block.number);
  }

  /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
  ///  its behalf. This is a modified version of the ERC20 approve function
  ///  to be a little bit safer
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _amount The amount of tokens to be approved for transfer
  /// @return True if the approval was successful
  function approve(address _spender, uint256 _amount) public returns (bool success) {
    require(transfersEnabled);

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender,0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0), "AutoIncrementCoinageSnapshot: invalid approve amount");

    // Alerts the token controller of the approve function call
    if (isContract(controller)) {
      require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
    }

    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  /// @dev This function makes it easy to read the `allowed[]` map
  /// @param _owner The address of the account that owns the token
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens of _owner that _spender is allowed
  ///  to spend
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
  ///  its behalf, and then a function is triggered in the contract that is
  ///  being approved, `_spender`. This allows users to use their tokens to
  ///  interact with contracts in one function call instead of two
  /// @param _spender The address of the contract able to transfer the tokens
  /// @param _amount The amount of tokens to be approved for transfer
  /// @return True if the function call was successful
  function approveAndCall(address _spender, uint256 _amount, bytes memory _extraData) public returns (bool success) {
    require(approve(_spender, _amount));

    ApproveAndCallFallBack(_spender).receiveApproval(
      msg.sender,
      _amount,
      address(this),
      _extraData
    );

    return true;
  }

  /// @dev This function makes it easy to get the total number of tokens
  /// @return The total number of tokens
  function totalSupply() public view returns (uint) {
    return totalSupplyAt(block.number);
  }

  /// @dev This function makes it easy to get factor
  /// @return The factor
  function factor() public view returns (uint) {
    return factorAt(block.number);
  }


////////////////
// Query balance and totalSupply in History
////////////////

  /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
  /// @param _owner The address from which the balance will be retrieved
  /// @param _blockNumber The block number when the balance is queried
  /// @return The balance at `_blockNumber` in WAS FACTORED
  function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint) {
    return _applyFactorAt(basedBalanceOfAt(_owner, _blockNumber), _blockNumber);
  }

  /// @dev Queries the balance of `_owner` at a specific `_blockNumber` in WAD BASED
  /// @param _owner The address from which the balance will be retrieved
  /// @param _blockNumber The block number when the balance is queried
  /// @return The balance at `_blockNumber` in WAD BASED
  function basedBalanceOfAt(address _owner, uint _blockNumber) public view returns (uint) {
    // These next few lines are used when the balance of the token is
    //  requested before a check point was ever created for this token, it
    //  requires that the `parentToken.balanceOfAt` be queried at the
    //  genesis block for that token as this contains initial balance of
    //  this token
    if ((balances[_owner].length == 0)
      || (balances[_owner][0].fromBlock > _blockNumber)) {
      if (address(parentToken) != address(0)) {
        uint bn = min(_blockNumber, parentSnapShotBlock);
        return _toWADBased(parentToken.balanceOfAt(_owner, bn), bn);
      } else {
        // Has no parent
        return 0;
      }

    // This will return the expected balance during normal situations
    } else {
      return getValueAt(balances[_owner], _blockNumber);
    }
  }

  /// @notice Total amount of tokens at a specific `_blockNumber`.
  /// @param _blockNumber The block number when the totalSupply is queried
  /// @return The total amount of tokens at `_blockNumber` in WAS FACTORED
  function totalSupplyAt(uint _blockNumber) public view returns (uint) {
    return _applyFactorAt(basedTotalSupplyAt(_blockNumber), _blockNumber);
  }

  /// @notice Total amount of tokens at a specific `_blockNumber`.
  /// @param _blockNumber The block number when the totalSupply is queried
  /// @return The total amount of tokens at `_blockNumber` in WAS BASED
  function basedTotalSupplyAt(uint _blockNumber) public view returns (uint) {

    // These next few lines are used when the totalSupply of the token is
    //  requested before a check point was ever created for this token, it
    //  requires that the `parentToken.totalSupplyAt` be queried at the
    //  genesis block for this token as that contains totalSupply of this
    //  token at this block number.
    if ((totalSupplyHistory.length == 0)
      || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
      if (address(parentToken) != address(0)) {
        uint bn = min(_blockNumber, parentSnapShotBlock);
        return _toWADBased(parentToken.totalSupplyAt(bn), bn);
      } else {
        return 0;
      }

    // This will return the expected totalSupply during normal situations
    } else {
      return getValueAt(totalSupplyHistory, _blockNumber);
    }
  }

  /// @notice Factor at a specific `_blockNumber`.
  /// @param _blockNumber The block number when the factor is queried
  /// @return The factor value at `_blockNumber`
  function factorAt(uint _blockNumber) public view returns(uint) {

    if (factorHistory[0].fromBlock > _blockNumber) {
      return wdiv(
        factorHistory[0].value,
        wpow(factorIncrement, uint256(factorHistory[0].fromBlock - _blockNumber))
      );

    // This will return the expected totalSupply during normal situations
    } else {
      (uint f, uint b) = getValueAtWithBlcokNumber(factorHistory, _blockNumber);
      return wmul(f, wpow(factorIncrement, sub(_blockNumber, b)));
    }
  }

////////////////
// Clone Token Method
////////////////

    function createCloneToken(
      string memory _cloneTokenName,
      string memory _cloneTokenSymbol,
      uint _factor,
      uint _factorIncrement,
      uint _snapshotBlock,
      bool _transfersEnabled
    ) public returns(address) {
      if (_snapshotBlock == 0) _snapshotBlock = block.number;

      AutoIncrementCoinageSnapshot cloneToken = tokenFactory.createCloneToken(
        address(uint160(address(this))),
        _snapshotBlock,
        _cloneTokenName,
        _cloneTokenSymbol,
        _factor,
        _factorIncrement,
        _transfersEnabled
      );

      cloneToken.changeController(msg.sender);

      // An event to make the token easy to find on the blockchain
      emit NewCloneToken(address(cloneToken), _snapshotBlock);
      return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////

  /// @notice Generates `_amount` tokens that are assigned to `_owner`
  /// @param _owner The address that will be assigned the new tokens
  /// @param _amount The quantity of tokens generated
  /// @return True if the tokens are generated correctly
  function generateTokens(address _owner, uint _amount)
    public
    onlyController
    increaseFactor
    returns (bool)
  {
    uint wbAmount = _toWADBased(_amount, block.number);
    uint curTotalSupply = basedTotalSupplyAt(block.number);
    require(uint128(curTotalSupply + wbAmount) >= curTotalSupply); // Check for overflow
    uint previousBalanceTo = basedBalanceOfAt(_owner, block.number);
    require(uint128(previousBalanceTo + wbAmount) >= previousBalanceTo); // Check for overflow
    updateValueAtNow(totalSupplyHistory, curTotalSupply + wbAmount);
    updateValueAtNow(balances[_owner], previousBalanceTo + wbAmount);
    emit Transfer(address(0), _owner, _toWADFactored(wbAmount, block.number));
    return true;
  }


  /// @notice Burns `_amount` tokens from `_owner`
  /// @param _owner The address that will lose the tokens
  /// @param _amount The quantity of tokens to burn
  /// @return True if the tokens are burned correctly
  function destroyTokens(address _owner, uint _amount)
    onlyController
    increaseFactor
    public
    returns (bool)
  {
    uint wbAmount = _toWADBased(_amount, block.number);
    uint curTotalSupply = basedTotalSupplyAt(block.number);
    require(curTotalSupply >= wbAmount);
    uint previousBalanceFrom = basedBalanceOfAt(_owner, block.number);
    require(previousBalanceFrom >= wbAmount);
    updateValueAtNow(totalSupplyHistory, curTotalSupply - wbAmount);
    updateValueAtNow(balances[_owner], previousBalanceFrom - wbAmount);
    emit Transfer(_owner, address(0), _toWADFactored(wbAmount, block.number));
    return true;
  }

////////////////
// Enable tokens transfers
////////////////


  /// @notice Enables token holders to transfer their tokens freely if true
  /// @param _transfersEnabled True if transfers are allowed in the clone
  function enableTransfers(bool _transfersEnabled) public onlyController {
    transfersEnabled = _transfersEnabled;
  }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

  /// @dev `getValueAt` retrieves the number of tokens at a given block number
  /// @param checkpoints The history of values being queried
  /// @param _block The block number to retrieve the value at
  /// @return The number of tokens being queried
  function getValueAt(Checkpoint[] storage checkpoints, uint _block) view internal returns (uint) {
    (uint v, uint _) = getValueAtWithBlcokNumber(checkpoints, _block);
    return v;
  }

  /// @dev `getValueAt` retrieves the number of tokens at a given block number
  /// @param checkpoints The history of values being queried
  /// @param _block The block number to retrieve the value at
  /// @return The number of tokens being queried
  function getValueAtWithBlcokNumber(Checkpoint[] storage checkpoints, uint _block) view internal returns (uint, uint) {
    if (checkpoints.length == 0) return (0, 0);

    // Shortcut for the actual value
    if (_block >= checkpoints[checkpoints.length-1].fromBlock)
      return (checkpoints[checkpoints.length-1].value, checkpoints[checkpoints.length-1].fromBlock);
    if (_block < checkpoints[0].fromBlock) return (0, checkpoints[0].fromBlock);

    // Binary search of the value in the array
    uint min = 0;
    uint max = checkpoints.length-1;
    while (max > min) {
      uint mid = (max + min + 1)/ 2;
      if (checkpoints[mid].fromBlock<=_block) {
        min = mid;
      } else {
        max = mid-1;
      }
    }
    return (checkpoints[min].value, checkpoints[min].fromBlock);
  }

  /// @dev `updateValueAtNow` used to update the `balances` map and the
  ///  `totalSupplyHistory`
  /// @param checkpoints The history of data being updated
  /// @param _value The new number of tokens
  function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal  {
    require(_value == uint(uint128(_value)));
    if ((checkpoints.length == 0)
    || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
         Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
         newCheckPoint.fromBlock =  uint128(block.number);
         newCheckPoint.value = uint128(_value);
       } else {
         Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
         oldCheckPoint.value = uint128(_value);
       }
  }

  /// @dev Internal function to determine if an address is a contract
  /// @param _addr The address being queried
  /// @return True if `_addr` is a contract
  function isContract(address _addr) view internal returns(bool) {
    uint size;
    if (_addr == address(0)) return false;
    assembly {
      size := extcodesize(_addr)
    }
    return size>0;
  }

  /// @dev Helper function to return a min betwen the two uints
  function min(uint a, uint b) pure internal returns (uint) {
    return a < b ? a : b;
  }

  /// @notice The fallback function: If the contract's controller has not been
  ///  set to 0, then the `proxyPayment` method is called which relays the
  ///  ether and creates tokens as described in the token controller contract
  function () external payable {
    require(isContract(controller));
    require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
  }

//////////
// Safety Methods
//////////

  /// @notice This method can be used by the controller to extract mistakenly
  ///  sent tokens to this contract.
  /// @param _token The address of the token contract that you want to recover
  ///  set to 0 in case you want to extract ether.
  function claimTokens(address payable _token) public onlyController {
    if (_token == address(0)) {
      controller.transfer(address(this).balance);
      return;
    }

    AutoIncrementCoinageSnapshot token = AutoIncrementCoinageSnapshot(_token);
    uint balance = token.balanceOf(address(this));
    token.transfer(controller, balance);
    emit ClaimedTokens(_token, controller, balance);
  }

////////////////
// Internal helper functions for factor computation
////////////////
  /**
   * @dev Calculate WAD BASED from WAD FACTORED
   */
  function _toWADBased(uint256 wf, uint256 blockNumber) internal view returns (uint256 wb) {
    return wdiv(wf, factorAt(blockNumber));
  }

  /**
   * @dev Calculate WAD FACTORED from WAD BASED
   */
  function _toWADFactored(uint256 wb, uint256 blockNumber) internal view returns (uint256 wf) {
    return wmul(wb, factorAt(blockNumber));
  }

  /**
   * @param v the value to be factored
   */
  function _applyFactor(uint256 v) internal view returns (uint256) {
    return _applyFactorAt(v, block.number);
  }

  /**
   * @dev apply factor to {v} at a specific block
   */
  function _applyFactorAt(uint256 v, uint256 blockNumber) internal view returns (uint256) {
    return wmul(v, factorAt(blockNumber));
  }

////////////////
// Modifiers
////////////////
  modifier increaseFactor() {
    Checkpoint storage fh = factorHistory[factorHistory.length - 1];
    uint256 f = fh.value;
    uint256 n = block.number - fh.fromBlock;

    if (n > 0) {
      f = wmul(f, wpow(factorIncrement, n));

      updateValueAtNow(factorHistory, f);

      emit FactorIncreased(f);
    }

    _;
  }

////////////////
// Events
////////////////
  event ClaimedTokens(address indexed token, address indexed controller, uint value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event NewCloneToken(address indexed cloneToken, uint snapshotBlock);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  event FactorIncreased(uint256 factor);
}


////////////////
// AutoIncrementCoinageSnapshotFactory
////////////////

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract AutoIncrementCoinageSnapshotFactory {

  /// @notice Update the DApp by creating a new token with new functionalities
  ///  the msg.sender becomes the controller of this clone token
  /// @param _parentToken Address of the token being cloned
  /// @param _snapshotBlock Block of the parent token that will
  ///  determine the initial distribution of the clone token
  /// @param _tokenName Name of the new token
  /// @param _tokenSymbol Token Symbol for the new token
  /// @param _transfersEnabled If true, tokens will be able to be transferred
  /// @return The address of the new token contract
  function createCloneToken(
    address payable _parentToken,
    uint _snapshotBlock,
    string memory _tokenName,
    string memory _tokenSymbol,
    uint _factor,
    uint _factorIncrement,
    bool _transfersEnabled
  ) public returns (AutoIncrementCoinageSnapshot) {
    AutoIncrementCoinageSnapshot newToken = new AutoIncrementCoinageSnapshot(
      address(uint160(address(this))),
      _parentToken,
      _snapshotBlock,
      _tokenName,
      _tokenSymbol,
      _factor,
      _factorIncrement,
      _transfersEnabled
      );

    newToken.changeController(msg.sender);
    return newToken;
  }
}

// File: contracts/CustomIncrementCoinage.sol

pragma solidity ^0.5.12;



/**
 * @dev FixedIncrementCoinage increases balance and total supply by fixed amount per block.
 */
contract CustomIncrementCoinage is AutoIncrementCoinage {
  event FactorSet(uint256 previous, uint256 current);

  constructor (
    string memory name,
    string memory symbol,
    uint256 factor,
    bool transfersEnabled
  )
    public
    AutoIncrementCoinage(name, symbol, factor, 0, transfersEnabled)
  {}

  /**
   * @dev set new factor for all users.
   */
  function setFactor(uint256 factor) external onlyOwner returns (bool) {
    uint256 previous = _factor;
    _factor = factor;
    emit FactorSet(previous, factor);
  }

////////////////////
// Getters
////////////////////
  function factor() public view returns (uint256) {
    return _factor;
  }

////////////////////
// Helpers
////////////////////
  function _calculateFactor(uint256 n) internal view returns (uint256) {
    return _factor;
  }
}

// File: contracts/FixedIncrementCoinage.sol

pragma solidity ^0.5.12;



/**
 * @dev FixedIncrementCoinage increases balance and total supply by fixed amount per block.
 */
contract FixedIncrementCoinage is AutoIncrementCoinage {
  uint256 internal _seigPerBlock;

  constructor (
    string memory name,
    string memory symbol,
    uint256 factor,
    uint256 seigPerBlock,
    bool transfersEnabled
  )
    public
    AutoIncrementCoinage(name, symbol, factor, 0, transfersEnabled)
  {
    require(seigPerBlock != 0, "FixedIncrementCoinage: seignorage must not be zero");
    _seigPerBlock = seigPerBlock;
  }

////////////////////
// Getters
////////////////////

  function seigPerBlock() public view returns (uint256) {
    return _seigPerBlock;
  }

////////////////////
// Helpers
////////////////////

  /**
   * @dev Returns new factor for fixed increment per block.
   */
  function _calculateFactor(uint256 n) internal view returns (uint256) {
    if (_totalSupply == 0) return _factor;

    uint256 prevTotalSupply = rmul(_totalSupply, _factor);
    uint256 nextTotalSupply = add(prevTotalSupply, mul(_seigPerBlock, n));

    return rdiv(rmul(_factor, nextTotalSupply), prevTotalSupply);
  }
}

// File: contracts/lib/minime/MiniMeToken.sol

pragma solidity ^0.5.12;

/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract's goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.



contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;
}

/// @dev The actual token contract, the default controller is the msg.sender
///  that deploys the contract, so usually this token will be deployed by a
///  token controller contract, which Giveth will call a "Campaign"
contract MiniMeToken is Controlled {

    string public name;                //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals;             //Number of decimals of the smallest unit
    string public symbol;              //An identifier: e.g. REP
    string public version = 'C_MMT_0.1'; //An arbitrary versioning scheme


    /// @dev `Checkpoint` is the structure that attaches a block number to a
    ///  given value, the block number attached is the one that last changed the
    ///  value
    struct  Checkpoint {

        // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }

    // `parentToken` is the Token address that was cloned to produce this token;
    //  it will be 0x0 for a token that was not cloned
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` is the block number from the Parent Token that was
    //  used to determine the initial distribution of the Clone Token
    uint public parentSnapShotBlock;

    // `creationBlock` is the block number that the Clone Token was created
    uint public creationBlock;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) allowed;

    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] totalSupplyHistory;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

    // The factory used to create new clone tokens
    MiniMeTokenFactory public tokenFactory;

////////////////
// Constructor
////////////////

    /// @notice Constructor to create a MiniMeToken
    /// @param _tokenFactory The address of the MiniMeTokenFactory contract that
    ///  will create the Clone token contracts, the token factory needs to be
    ///  deployed first
    /// @param _parentToken Address of the parent token, set to 0x0 if it is a
    ///  new token
    /// @param _parentSnapShotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token, set to 0 if it
    ///  is a new token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    constructor (
        address payable _tokenFactory,
        address payable _parentToken,
        uint _parentSnapShotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // Set the name
        decimals = _decimalUnits;                          // Set the decimals
        symbol = _tokenSymbol;                             // Set the symbol
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }


///////////////////
// ERC20 Methods
///////////////////

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

        // The controller of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  controller of this contract, which in most situations should be
        //  another open source smart contract or 0x0
        if (msg.sender != controller) {
            require(transfersEnabled);

            // The standard ERC 20 transferFrom functionality
            require(allowed[_from][msg.sender] >= _amount);
            allowed[_from][msg.sender] -= _amount;
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               emit Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
               return;
           }

           require(parentSnapShotBlock < block.number);

           // Do not allow transfer to 0x0 or the token contract itself
           require((_to != address(0)) && (_to != address(this)));

           // If the amount being transfered is more than the balance of the
           //  account the transfer throws
           uint previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

           // Alerts the token controller of the transfer
           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           // First update the balance array with the new value for the address
           //  sending the tokens
           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           // Then update the balance array with the new value for the address
           //  receiving the tokens
           uint previousBalanceTo = balanceOfAt(_to, block.number);
           require(uint128(previousBalanceTo + _amount) >= previousBalanceTo); // Check for overflow
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           // An event to make the transfer easy to find on the blockchain
           emit Transfer(_from, _to, _amount);

    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        // Alerts the token controller of the approve function call
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address _spender, uint256 _amount, bytes memory _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            address(this),
            _extraData
        );

        return true;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply() public view returns (uint) {
        return totalSupplyAt(block.number);
    }


////////////////
// Query balance and totalSupply in History
////////////////

    /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
    /// @param _owner The address from which the balance will be retrieved
    /// @param _blockNumber The block number when the balance is queried
    /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint _blockNumber) public view
        returns (uint) {

        // These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.balanceOfAt` be queried at the
        //  genesis block for that token as this contains initial balance of
        //  this token
        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // Has no parent
                return 0;
            }

        // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /// @notice Total amount of tokens at a specific `_blockNumber`.
    /// @param _blockNumber The block number when the totalSupply is queried
    /// @return The total amount of tokens at `_blockNumber`
    function totalSupplyAt(uint _blockNumber) public view returns(uint) {

        // These next few lines are used when the totalSupply of the token is
        //  requested before a check point was ever created for this token, it
        //  requires that the `parentToken.totalSupplyAt` be queried at the
        //  genesis block for this token as that contains totalSupply of this
        //  token at this block number.
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != address(0)) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }

        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

////////////////
// Clone Token Method
////////////////

    /// @notice Creates a new clone token with the initial distribution being
    ///  this token at `_snapshotBlock`
    /// @param _cloneTokenName Name of the clone token
    /// @param _cloneDecimalUnits Number of decimals of the smallest unit
    /// @param _cloneTokenSymbol Symbol of the clone token
    /// @param _snapshotBlock Block when the distribution of the parent token is
    ///  copied to set the initial distribution of the new clone token;
    ///  if the block is zero than the actual block, the current block is used
    /// @param _transfersEnabled True if transfers are allowed in the clone
    /// @return The address of the new MiniMeToken Contract
    function createCloneToken(
        string memory _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string memory _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            address(uint160(address(this))),
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        // An event to make the token easy to find on the blockchain
        emit NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

////////////////
// Generate and destroy tokens
////////////////

    /// @notice Generates `_amount` tokens that are assigned to `_owner`
    /// @param _owner The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @return True if the tokens are generated correctly
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(uint128(curTotalSupply + _amount) >= curTotalSupply); // Check for overflow
        uint previousBalanceTo = balanceOf(_owner);
        require(uint128(previousBalanceTo + _amount) >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        emit Transfer(address(0), _owner, _amount);
        return true;
    }


    /// @notice Burns `_amount` tokens from `_owner`
    /// @param _owner The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    /// @return True if the tokens are burned correctly
    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        emit Transfer(_owner, address(0), _amount);
        return true;
    }

////////////////
// Enable tokens transfers
////////////////


    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

////////////////
// Internal helper functions to query and set a value in a snapshot array
////////////////

    /// @dev `getValueAt` retrieves the number of tokens at a given block number
    /// @param checkpoints The history of values being queried
    /// @param _block The block number to retrieve the value at
    /// @return The number of tokens being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) view internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /// @dev `updateValueAtNow` used to update the `balances` map and the
    ///  `totalSupplyHistory`
    /// @param checkpoints The history of data being updated
    /// @param _value The new number of tokens
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        require(_value == uint(uint128(_value)));
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) view internal returns(bool) {
        uint size;
        if (_addr == address(0)) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    /// @dev Helper function to return a min betwen the two uints
    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    /// @notice The fallback function: If the contract's controller has not been
    ///  set to 0, then the `proxyPayment` method is called which relays the
    ///  ether and creates tokens as described in the token controller contract
    function () external payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

//////////
// Safety Methods
//////////

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address payable _token) public onlyController {
        if (_token == address(0)) {
            controller.transfer(address(this).balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
    }

////////////////
// Events
////////////////
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}


////////////////
// MiniMeTokenFactory
////////////////

/// @dev This contract is used to generate clone contracts from a contract.
///  In solidity this is the way to create a contract from a contract of the
///  same class
contract MiniMeTokenFactory {

    /// @notice Update the DApp by creating a new token with new functionalities
    ///  the msg.sender becomes the controller of this clone token
    /// @param _parentToken Address of the token being cloned
    /// @param _snapshotBlock Block of the parent token that will
    ///  determine the initial distribution of the clone token
    /// @param _tokenName Name of the new token
    /// @param _decimalUnits Number of decimals of the new token
    /// @param _tokenSymbol Token Symbol for the new token
    /// @param _transfersEnabled If true, tokens will be able to be transferred
    /// @return The address of the new token contract
    function createCloneToken(
        address payable _parentToken,
        uint _snapshotBlock,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            address(uint160(address(this))),
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
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
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

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
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;



contract MinterRole is Context {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {
        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.0;



/**
 * @dev Extension of {ERC20} that adds a set of accounts with the {MinterRole},
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the {MinterRole}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol

pragma solidity ^0.5.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is Context, ERC20 {
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
}

// File: contracts/mock/AutoIncrementCoinageMock.sol

pragma solidity ^0.5.12;




contract AutoIncrementCoinageMock is ERC20Mintable, ERC20Burnable, AutoIncrementCoinage {
  constructor (
    string memory name,
    string memory symbol,
    uint256 factor,
    uint256 factorIncrement,
    bool transfersEnabled
  )
    public
    AutoIncrementCoinage(name, symbol, factor, factorIncrement, transfersEnabled)
  {}
}

// File: contracts/mock/CustomIncrementCoinageMock.sol

pragma solidity ^0.5.12;




contract CustomIncrementCoinageMock is ERC20Mintable, ERC20Burnable, CustomIncrementCoinage {
  constructor (
    string memory name,
    string memory symbol,
    uint256 factor,
    bool transfersEnabled
  )
    public
    CustomIncrementCoinage(name, symbol, factor, transfersEnabled)
  {}
}

// File: contracts/mock/FixedIncrementCoinageMock.sol

pragma solidity ^0.5.12;




contract FixedIncrementCoinageMock is ERC20Mintable, ERC20Burnable, FixedIncrementCoinage {
  constructor (
    string memory name,
    string memory symbol,
    uint256 factor,
    uint256 seigPerBlock,
    bool transfersEnabled
  )
    public
    FixedIncrementCoinage(name, symbol, factor, seigPerBlock, transfersEnabled)
  {}
}

// File: contracts/DelegateProxy.sol

// source code from https://github.com/aragon/aragonOS/blob/next/contracts
pragma solidity ^0.5.12;

// https://github.com/aragon/aragonOS/blob/07d309f5e81c768269dfc49373d41fac4528ebd2/contracts/common/IsContract.sol
contract IsContract {
  /*
  * NOTE: this should NEVER be used for authentication
  * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).
  *
  * This is only intended to be used as a sanity check that an address is actually a contract,
  * RATHER THAN an address not being a contract.
  */
  function isContract(address _target) internal view returns (bool) {
    if (_target == address(0)) {
      return false;
    }

    uint256 size;
    assembly { size := extcodesize(_target) }
    return size > 0;
  }
}


// https://github.com/aragon/aragonOS/blob/07d309f5e81c768269dfc49373d41fac4528ebd2/contracts/lib/misc/ERCProxy.sol
contract ERCProxy {
  uint256 internal constant FORWARDING = 1;
  uint256 internal constant UPGRADEABLE = 2;

  function proxyType() public pure returns (uint256 proxyTypeId);
  function implementation() public view returns (address codeAddr);
}


// https://github.com/aragon/aragonOS/blob/07d309f5e81c768269dfc49373d41fac4528ebd2/contracts/common/DelegateProxy.sol
contract DelegateProxy is ERCProxy, IsContract {
  uint256 internal constant FWD_GAS_LIMIT = 10000;

  /**
   * @dev Performs a delegatecall and returns whatever the delegatecall returned (entire  context execution will return!)
   * @param _dst Destination address to perform the delegatecall
   * @param _calldata Calldata for the delegatecall
   */
  function delegatedFwd(address _dst, bytes memory _calldata) internal {
    require(isContract(_dst));
    uint256 fwdGasLimit = FWD_GAS_LIMIT;

    assembly {
      let result := delegatecall(sub(gas, fwdGasLimit), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
      let size := returndatasize
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)

      // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.
      // if the call returned error data, forward it
      switch result case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}

// File: contracts/Migrations.sol

pragma solidity >=0.4.21 <0.7.0;

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}