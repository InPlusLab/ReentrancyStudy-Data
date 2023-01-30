/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.4.24;


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

contract Owned {
  constructor() public { owner = msg.sender; }

  address public owner;

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
}

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

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


contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) internal _balances;

  mapping (address => mapping (address => uint256)) internal _allowances;

  uint256 internal _totalSupply;

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


contract Wisdom is ERC20, Owned {

  string public constant name = "Wisdom";
  string public constant symbol = "WISDOM";
  uint8 public constant decimals = 2;

  mapping(address => bool) _admins;
  mapping(address => bool) _locked;

  /**
   * Adds somebody as an admin. This method is allowed by owner only.
   */
  function addAdmin(address somebody) public onlyOwner {
    _admins[somebody] = true;
  }

  /**
   * Removes somebody from admin. This method is allowed by owner only.
   */
  function removeAdmin(address somebody) public onlyOwner {
    _admins[somebody] = false;
  }

  /**
   * Returns true if somebody is admin. Owner is always an admin.
   */
  function isAdmin(address somebody) public view returns(bool) {
    return _admins[somebody] || somebody == owner;
  }

  /**
   * Locks an address. This method is allowed by admins.
   *
   * Locked addresses can not transfer or burn.
   */
  function lock(address account) public {
    require(isAdmin(msg.sender));
    _locked[account] = true;
  }

  /**
   * Unlocks an address. This method is allowed by admins.
   */
  function unlock(address account) public {
    require(isAdmin(msg.sender));
    _locked[account] = false;
  }

  /**
   * Returns true if somebody is locked.
   */
  function isLocked(address somebody) public view returns(bool) {
    return _locked[somebody];
  }

  /**
   * Issues new amount of tokens to account. This method is allowed by admins.
   */
  function mint(address account, uint256 amount) public {
    require(isAdmin(msg.sender));
    _mint(account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from sender.
   *
   * See `ERC20._burn`.
   */
  function burn(uint256 amount) public {
    require(!_locked[msg.sender]);
    _burn(msg.sender, amount);
  }

  /**
   * @dev See `ERC20._burnFrom`.
   */
  function burnFrom(address account, uint256 amount) public {
    require(!_locked[msg.sender]);
    require(!_locked[account]);
    _burnFrom(account, amount);
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
    require(!_locked[msg.sender]);
    _transfer(msg.sender, recipient, amount);
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
    require(!_locked[msg.sender]);
    require(!_locked[sender]);
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    return true;
  }
}