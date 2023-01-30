/**
 *Submitted for verification at Etherscan.io on 2019-12-20
*/

/**
 * @title Toft Standard Token (TST)
 * Version: 1.0
 */
 
pragma solidity 0.5.0;

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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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

     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
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
}

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

contract Pausable is Context, PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
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
}

contract ERC20Pausable is ERC20, Pausable {
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

interface ITST {
    /**
     * @dev sets existing feeAccount to `feeAccount` by the caller.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     * 
     * Emits an {FeeAccountUpdated} event indicating the new FeeAccount.
     */
    function setFeeAccount(address feeAccount) external returns (bool);
    
    /**
     * @dev sets existing maxTransferFee to `_maxTransferFee` by the caller.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     * 
     * Emits an {MaxTransferFeeUpdated} event indicating the new maximum transfer fee.
     */
    function setMaxTransferFee(uint256 maxTransferFee) external returns (bool);
    
    /**
     * @dev sets existing minTransferFee to `_minTransferFee` by the caller.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     * 
     * Emits an {MinTransferFeeUpdated} event indicating the new minimum transfer fee.
     */
    function setMinTransferFee(uint256 minTransferFee) external returns (bool);
    
    /**
     * @dev sets existing transferFeePercentage to `_transferFeePercentage` by the caller.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     * 
     * Emits an {TransferFeePercentageUpdated} event indicating the new percentange transfer fee.
     */
    function setTransferFeePercentage(uint256 transferFeePercentage) external returns (bool);
        
    /**
     * @dev calculate transfer fee aginst `weiAmount`.
     * @param weiAmount Value in wei to be to calculate fee.
     * @return Number of tokens in wei to paid for transfer fee.
     */
    function calculateTransferFee(uint256 weiAmount) external view returns(uint256) ;
    
    /**
     * @return the current fee account collector.
     */    
    function feeAccount() external view returns (address);
    
    /**
     * @return the current maximum transfer fee.
     */
    function maxTransferFee() external view returns (uint256);
    
    /**
     * @return the current minimum transfer fee.
     */
    function minTransferFee() external view returns (uint256);

    /**
     * @return the current percentange of transfer fee.
     */ 
    function transferFeePercentage() external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient` with a transaction note `message`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount, string calldata message) external returns (bool);
    
    /**
     * Event for FeeAccount update.
     * @param newFeeAccount new FeeAccount.
     * @param previousFeeAccount old FeeAccount.
     */
    event FeeAccountUpdated(address indexed previousFeeAccount, address indexed newFeeAccount);
    
    /**
     * Event for MaxTransferFee update.
     * @param newMaxTransferFee new maximum tranfer fee.
     * @param previousMaxTransferFee old maximum tranfer fee.
     */
    event MaxTransferFeeUpdated(uint256 previousMaxTransferFee, uint256 newMaxTransferFee);
    
    /**
     * Event for MinTransferFee update.
     * @param newMinTransferFee new minimum tranfer fee.
     * @param previousMinTransferFee old minimum tranfer fee.
     */
    event MinTransferFeeUpdated(uint256 previousMinTransferFee, uint256 newMinTransferFee);
    
    /**
     * Event for TransferFeePercentage update.
     * @param newTransferFeePercentage new percentange tranfer fee.
     * @param previousTransferFeePercentage old percentange tranfer fee.
     */
    event TransferFeePercentageUpdated(uint256 previousTransferFeePercentage, uint256 newTransferFeePercentage);
    
    /**
     * @dev emitted with token transfer is done.
     * @param from the account from which tokens are moved.
     * @param to the recipient of tokens.
     * @param value the amount to tokens moved.
     * @param fee the account to fee deducted from `from`.
     */
    event Transfer(address indexed from, address indexed to, uint256 value, uint256 fee, string description);
}

/*
 * TransferFee 
 * Base contract for trasfer fee specification.
 */
contract TransferFee is Ownable, ITST {

    address private _feeAccount;
    uint256 private _maxTransferFee;
    uint256 private _minTransferFee;
    uint256 private _transferFeePercentage;
    
    /**
     * @dev Constructor, _feeAccount that collects tranfer fee, fee percentange, maximum, minimum amount of wei for trasfer fee.
     * @param feeAccount account that collects fee.
     * @param minTransferFee Min amount of wei to be charged on trasfer.
     * @param minTransferFee Min amount of wei to be charged on trasfer.
     * @param transferFeePercentage Percent amount of wei to be charged on trasfer.
     */
    constructor (address feeAccount, uint256 maxTransferFee, uint256 minTransferFee, uint256 transferFeePercentage) public {
        require(feeAccount != address(0x0), "TransferFee: feeAccount is 0");
        require(minTransferFee > 0, "TransferFee: minTransferFee is 0");
        require(maxTransferFee > 0, "TransferFee: maxTransferFee is 0");
        require(transferFeePercentage > 0, "TransferFee: transferFeePercentage is 0");
        
        // this also handles "minTransferFee should be less than maxTransferFee"
        // solhint-disable-next-line max-line-length
        require(maxTransferFee > minTransferFee, "TransferFee: maxTransferFee should be greater than minTransferFee");

        _feeAccount = feeAccount;
        _maxTransferFee = maxTransferFee;
        _minTransferFee = minTransferFee;
        _transferFeePercentage = transferFeePercentage;
    }
    
    /**
     * See {ITrasnferFee-setFeeAccount}.
     * 
     * @dev sets `feeAccount` to `_feeAccount` by the caller.
     *
     * Requirements:
     *
     * - `feeAccount` cannot be the zero.
     */
    function setFeeAccount(address feeAccount) external onlyOwner returns (bool) {
        require(feeAccount != address(0x0), "TransferFee: feeAccount is 0");
        
        emit FeeAccountUpdated(_feeAccount, feeAccount);
        _feeAccount = feeAccount;
        return true;
    }
    
    /**
     * See {ITrasnferFee-setMaxTransferFee}.
     * 
     * @dev sets `maxTransferFee` to `_maxTransferFee` by the caller.
     * 
     * Requirements:
     *
     * - `maxTransferFee` cannot be the zero.
     * - `maxTransferFee` should be greater than minTransferFee.
     */
    function setMaxTransferFee(uint256 maxTransferFee) external onlyOwner returns (bool) {
        require(maxTransferFee > 0, "TransferFee: maxTransferFee is 0");
        // solhint-disable-next-line max-line-length
        require(maxTransferFee > _minTransferFee, "TransferFee: maxTransferFee should be greater than minTransferFee");
        
        emit MaxTransferFeeUpdated(_maxTransferFee, maxTransferFee);
        _maxTransferFee = maxTransferFee;
        return true;
    }

    /**
     * See {ITrasnferFee-setMinTransferFee}.
     * 
     * @dev sets `minTransferFee` to `_minTransferFee` by the caller.
     *
     * Requirements:
     *
     * - `minTransferFee` cannot be the zero.
     * - `minTransferFee` should be less than maxTransferFee.
     */
    function setMinTransferFee(uint256 minTransferFee) external onlyOwner returns (bool) {
        require(minTransferFee > 0, "TransferFee: minTransferFee is 0");
        // solhint-disable-next-line max-line-length
        require(minTransferFee < _maxTransferFee, "TransferFee: minTransferFee should be less than maxTransferFee");
        
        emit MaxTransferFeeUpdated(_minTransferFee, minTransferFee);
        _minTransferFee = minTransferFee;
        return true;
    }

    /**
     * See {ITrasnferFee-setTransferFeePercentage}.
     * 
     * @dev sets `transferFeePercentage` to `_transferFeePercentage` by the caller.
     *
     * Requirements:
     *
     * - `transferFeePercentage` cannot be the zero.
     * - `transferFeePercentage` should be less than maxTransferFee.
     */
    function setTransferFeePercentage(uint256 transferFeePercentage) external onlyOwner returns (bool) {
        require(transferFeePercentage > 0, "TransferFee: transferFeePercentage is 0");
        
        emit TransferFeePercentageUpdated(_transferFeePercentage, transferFeePercentage);
        _transferFeePercentage = transferFeePercentage;
        return true;
    }
    
    /**
     * @dev See {ITrasnferFee-feeAccount}.
     */    
    function feeAccount() public view returns (address) {
        return _feeAccount;
    }

    /**
     * See {ITrasnferFee-maxTransferFee}.
     */
    function maxTransferFee() public view returns (uint256) {
        return _maxTransferFee;
    }
    
    /**
     * See {ITrasnferFee-minTransferFee}.
     */
    function minTransferFee() public view returns (uint256) {
        return _minTransferFee;
    }

    /**
     * See {ITrasnferFee-transferFeePercentage}.
     */ 
    function transferFeePercentage() public view returns (uint256) {
        return _transferFeePercentage;
    }
}

/**
 * @title Toft Standard Token
 * @dev TST implementation.
 */
contract TST is Context, Ownable, ERC20, ERC20Detailed, ERC20Burnable, ERC20Mintable, ERC20Pausable, TransferFee  {
    
    // TOFT: EVENTS ADDED TO MAKE THIS CONTRACT COMPATIBLE WITH EXISTING APPS
 
    /**
     * @dev emitted with token transfer is done.
     * @param from the account from which tokens are moved.
     * @param to the recipient of tokens.
     * @param value the amount to tokens moved.
     * @param fee the account to fee deducted from `from`.
     * @param description a message for token transfer.
     * @param timestamp current block timestamp.
     */
    event Transfer(address indexed from, address indexed to, uint256 value, uint256 fee, string description, uint256 timestamp);

    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor (string memory name, string memory symbol, uint8 decimals, 
        address feeAccount, uint256 maxTransferFee, uint256 minTransferFee, uint8 transferFeePercentage) 
        public 
        ERC20Detailed(name, symbol, decimals) 
        TransferFee(feeAccount, maxTransferFee, minTransferFee, transferFeePercentage) {
        _mint(_msgSender(), 0);
    }
    
    /**
     * @dev calculate transfer fee aginst `weiAmount`.
     * @param weiAmount Value in wei to be to calculate fee.
     * @return Number of tokens in wei to paid for transfer fee.
     */
    function calculateTransferFee(uint256 weiAmount) public view returns(uint256) {
        uint256 divisor = uint256(100).mul((10**uint256(decimals())));
        uint256 _fee = (transferFeePercentage().mul(weiAmount)).div(divisor);

        if (_fee < minTransferFee()) {
            _fee = minTransferFee();   
        }

        else if (_fee > maxTransferFee()) {
            _fee = maxTransferFee();
        }
        
        return _fee;
    }

    /**
     * @dev override IERC20-transfer to deducted transfer fee from `amount`
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(this), "ERC20: transfer to the this contract");
        uint256 _fee = calculateTransferFee(amount);
        uint256 _amount = amount.sub(_fee);

        // calling ERC20 transfer function to transfer tokens
        super.transfer(recipient, _amount);
        
        // TST 
        super.transfer(feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(msg.sender, recipient, _amount, _fee, "", now);
        return true;
    }
    
    /**
     * @dev overriding version of ${transfer} that includes message in token transfer
     * 
     */
    function transfer(address recipient, uint256 amount, string calldata message) external returns (bool) {
        require(recipient != address(this), "ERC20: transfer to the this contract");
        uint256 _fee = calculateTransferFee(amount);
        uint256 _amount = amount.sub(_fee);

        // calling ERC20 transfer function to transfer tokens
        super.transfer(recipient, _amount);
        
        // TST 
        super.transfer(feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(msg.sender, recipient, _amount, _fee, message);
        return true;
    }
    
    /**
     * @dev Called by a pauser to unpause.
     * this function is override from ERC20Pausable to keep contract in paused state
     */
    function unpause() public onlyPauser whenPaused {
        require(false, "contract can't be unpaused");
    }
    
    /**
     * @dev overloading burn function to enable token burn from any account
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
    
    /**
     * @dev overridding mint function to enable token minting to only owner address.
     * @dev Mints `amount` tokens to the owner address.
     *
     * See {ERC20Mintable-mint}.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        require(account == owner(), "mint: tokens can be only minted on owner address");
        _mint(account, amount);
        return true;
    }
    
    /**
     * @dev See {IERC20-totalSupply}.
     * @return the current supply of tokens.
     *
     * Requirements:
     *
     * - the caller must have the {Owner}.
     */
    function totalSupply() public view onlyOwner returns (uint256) {
        return super.totalSupply();
    }
    
    // TOFT: THESE FUNCTIONS ARE ADDED TO MAKE THIS CONTRACT COMPATIBLE WITH EXISTING APPS
    
     /**
     * @dev legacy sendFunds function to make contract compatible with existing applications
     * 
     * @param from the sender of tokens
     * @param to the recipient of tokens.
     * @param value the amount to tokens moved.
     * @param description a message for token transfer.
     */
    function sendFunds(address from, address to, uint256 value, string memory description) public {
        require(to != address(this), "ERC20: transfer to the this contract");
        uint256 _fee = calculateTransferFee(value);
        uint256 _amount = value.sub(_fee);

        // calling ERC20 transfer function to transfer tokens
        super.transfer(to, _amount);
        
        // TST 
        super.transfer(feeAccount(), _fee); // transfering fee to fee account
        emit Transfer(from, to, _amount, _fee, description, now);
    }
    
    function increaseSupply(address target, uint256 amount) public {
        mint(target,amount);
    }

    function decreaseSupply(address target, uint256 amount) public {
        burn(target,amount);
    }
    
    function getOwner() public view returns (address) {
        return owner();
    }
    
    function getName() public view returns (string memory) {
        return name();
    }
    
    function getFeeAccount() public view returns (address) {
        return feeAccount();
    }
    
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }   
    
    function getMaxTransferFee() public view returns (uint256) {
        return maxTransferFee();
    }

    function getMinTransferFee() public view returns (uint256) {
        return minTransferFee();
    }
    
    function getTransferFeePercentage() public view returns (uint256) {
        return transferFeePercentage();
    }

    function getBalance(address balanceAddress) public view returns (uint256) {
        return balanceOf(balanceAddress);
    }
}