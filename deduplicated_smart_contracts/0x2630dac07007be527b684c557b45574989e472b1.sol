/**
 *Submitted for verification at Etherscan.io on 2019-07-22
*/

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// 'HACK' 'Hacker.Trade Token' contract
//
// Symbol      : HACK
// Name        : Hacker.Trade Token
// Total supply: 100,000,000.000000000000000000
// Decimals    : 18



// ----------------------------------------------------------------------------
// Wrappers over Solidity's arithmetic operations with added overflow checks.

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



// ----------------------------------------------------------------------------
// @dev Interface of the ERC20 standard as defined in the EIP. 

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



// ----------------------------------------------------------------------------
// @dev Implementation of the `IERC20` interface.

contract ERC20 is IERC20 {

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    // @dev See `IERC20.totalSupply`.
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // @dev See `IERC20.balanceOf`.
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // @dev See `IERC20.transfer`.
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // @dev See `IERC20.allowance`.
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    //  @dev See `IERC20.approve`.
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    // @dev See `IERC20.transferFrom`.
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    // @dev Atomically increases the allowance granted to `spender` by the caller.
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    // @dev Atomically decreases the allowance granted to `spender` by the caller.
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    // @dev Moves tokens `amount` from `sender` to `recipient`. 
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    // @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    // @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    // @dev Destroys `amount` tokens from `account`, reducing the total supply.
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance. 
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


// ----------------------------------------------------------------------------
/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    // @dev Give an account access to this role.
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    // @dev Remove an account's access to this role.
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    // @dev Check if an account has this role.
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 */

contract Pausable is PauserRole {

    // @dev Emitted when the pause is triggered by a pauser (`account`).
    event Paused(address account);

    // @dev Emitted when the pause is lifted by a pauser (`account`).
    event Unpaused(address account);
    bool private _paused;

    // @dev Initializes the contract in unpaused state. Assigns the Pauser role to the deployer.
    constructor () internal {
        _paused = false;
    }

    // @dev Returns true if the contract is paused, and false otherwise.
    function paused() public view returns (bool) {
        return _paused;
    }

    // @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    // @dev Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    // @dev Called by a pauser to pause, triggers stopped state.
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    // @dev Called by a pauser to unpause, returns to normal state.
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}



// ----------------------------------------------------------------------------
// @dev Optional functions from the ERC20 standard.

contract ERC20Detailed is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    // @dev Returns the name of the token.
    function name() public view returns (string memory) {
        return _name;
    }

    // @dev Returns the symbol of the token, usually shorter than the name.
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // @dev Returns the number of decimals used to get its user representation.
    function decimals() public view returns (uint8) {
        return _decimals;
    }

}



// ----------------------------------------------------------------------------
// @dev Issure the HACK token.

contract HACK is ERC20Detailed, Pausable {

    // @dev Constructor that gives msg.sender all of existing tokens.
    constructor () public ERC20Detailed("Hacker.Trade Token", "HACK", 18) {
        _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
    }


    // ----------------------------------------------------------------------------
    // @dev Burnable setting.

    // @dev Destroys `amount` tokens from the caller. See `ERC20._burn`.
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /** @dev See `ERC20._burnFrom`. 
     * Allows token holders to destroy tokens that they have an allowance for.
     */ 
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    } 


    // ----------------------------------------------------------------------------
    // @dev ERC20 with pausable transfers and allowances.

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
}