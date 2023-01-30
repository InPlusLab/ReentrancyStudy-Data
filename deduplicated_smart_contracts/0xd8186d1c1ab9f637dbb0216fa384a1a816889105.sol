/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

// File: @openzeppelin/contracts/GSN/Context.sol


pragma solidity ^0.6.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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



// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


pragma solidity ^0.6.0;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
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
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
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
    function _mint(address account, uint256 amount) internal virtual {
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
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


// File: localhost/contracts/POLContract.sol

pragma solidity 0.6.12;



contract POLContract {

    event Received(address, uint);
    event onDeposit(address, uint256, uint256);
    event onWithdraw(address, uint256);

    using SafeMath for uint256;

    struct VestingPeriod {
        uint256 epoch;
        uint256 amount;
    }

    struct UserTokenInfo {
        uint256 deposited; // incremented on successful deposit
        uint256 withdrawn; // incremented on successful withdrawl
        VestingPeriod[] vestingPeriods; // added to on successful deposit
    }

    // map erc20 token to user address to release schedule
    mapping(address => mapping(address => UserTokenInfo)) tokenUserMap;

    struct LiquidityTokenomics {
        uint256[] epochs;
        mapping (uint256 => uint256) releaseMap; // map epoch -> amount withdrawable
    }

    // map erc20 token to release schedule
    mapping(address => LiquidityTokenomics) tokenEpochMap;


    // Fast mapping to prevent array iteration in solidity
    mapping(address => bool) public lockedTokenLookup;

    // A dynamically-sized array of currently locked tokens
    address[] public lockedTokens;

    // fee variables
    uint256 public feeNumerator;
    uint256 public feeDenominator;

    address public feeReserveAddress;
    address public owner;

    constructor() public {
        feeNumerator = 3;
        feeDenominator = 1000;
        feeReserveAddress = address(0xAA3d85aD9D128DFECb55424085754F6dFa643eb1);
        owner = address(0xfCdd591498e86876F086524C0b2E9Af41a0c9FCD);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function updateFee(uint256 numerator, uint256 denominator) onlyOwner public {
        feeNumerator = numerator;
        feeDenominator = denominator;
    }

    function calculateFee(uint256 amount) public view returns (uint256){
        require(amount >= feeDenominator, 'Deposit is too small');
        uint256 amountInLarge = amount.mul(feeDenominator.sub(feeNumerator));
        uint256 amountIn = amountInLarge.div(feeDenominator);
        uint256 fee = amount.sub(amountIn);
        return (fee);
    }

    function depositTokenMultipleEpochs(address token, uint256[] memory amounts, uint256[] memory dates) public payable {
        require(amounts.length == dates.length, 'Amount and date arrays have differing lengths');
        for (uint i=0; i<amounts.length; i++) {
            depositToken(token, amounts[i], dates[i]);
        }
    }

    function depositToken(address token, uint256 amount, uint256 unlock_date) public payable {
        require(unlock_date < 10000000000, 'Enter an unix timestamp in seconds, not miliseconds');
        require(amount > 0, 'Your attempting to trasfer 0 tokens');
        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        require(allowance >= amount, 'You need to set a higher allowance');
        // charge a fee
        uint256 fee = calculateFee(amount);
        uint256 amountIn = amount.sub(fee);
        require(IERC20(token).transferFrom(msg.sender, address(this), amountIn), 'Transfer failed');
        require(IERC20(token).transferFrom(msg.sender, address(feeReserveAddress), fee), 'Transfer failed');
        if (!lockedTokenLookup[token]) {
            lockedTokens.push(token);
            lockedTokenLookup[token] = true;
        }
        LiquidityTokenomics storage liquidityTokenomics = tokenEpochMap[token];
        // amount is required to be above 0 in the start of this block, therefore this works
        if (liquidityTokenomics.releaseMap[unlock_date] > 0) {
            liquidityTokenomics.releaseMap[unlock_date] = liquidityTokenomics.releaseMap[unlock_date].add(amountIn);
        } else {
            liquidityTokenomics.epochs.push(unlock_date);
            liquidityTokenomics.releaseMap[unlock_date] = amountIn;
        }
        UserTokenInfo storage uto = tokenUserMap[token][msg.sender];
        uto.deposited = uto.deposited.add(amountIn);
        VestingPeriod[] storage vp = uto.vestingPeriods;
        vp.push(VestingPeriod(unlock_date, amountIn));

        emit onDeposit(token, amount, unlock_date);
    }

    function withdrawToken(address token, uint256 amount) public {
        require(amount > 0, 'Your attempting to withdraw 0 tokens');
        uint256 withdrawable = getWithdrawableBalance(token, msg.sender);
        UserTokenInfo storage uto = tokenUserMap[token][msg.sender];
        uto.withdrawn = uto.withdrawn.add(amount);
        require(amount <= withdrawable, 'Your attempting to withdraw more than you have available');
        require(IERC20(token).transfer(msg.sender, amount), 'Transfer failed');
        emit onWithdraw(token, amount);
    }

    function getWithdrawableBalance(address token, address user) public view returns (uint256) {
        UserTokenInfo storage uto = tokenUserMap[token][address(user)];
        uint arrayLength = uto.vestingPeriods.length;
        uint256 withdrawable = 0;
        for (uint i=0; i<arrayLength; i++) {
            VestingPeriod storage vestingPeriod = uto.vestingPeriods[i];
            if (vestingPeriod.epoch < block.timestamp) {
                withdrawable = withdrawable.add(vestingPeriod.amount);
            }
        }
        withdrawable = withdrawable.sub(uto.withdrawn);
        return withdrawable;
    }

    function getUserTokenInfo (address token, address user) public view returns (uint256, uint256, uint256) {
        UserTokenInfo storage uto = tokenUserMap[address(token)][address(user)];
        uint256 deposited = uto.deposited;
        uint256 withdrawn = uto.withdrawn;
        uint256 length = uto.vestingPeriods.length;
        return (deposited, withdrawn, length);
    }

    function getUserVestingAtIndex (address token, address user, uint index) public view returns (uint256, uint256) {
        UserTokenInfo storage uto = tokenUserMap[address(token)][address(user)];
        VestingPeriod storage vp = uto.vestingPeriods[index];
        return (vp.epoch, vp.amount);
    }

    function getTokenReleaseLength (address token) public view returns (uint256) {
        LiquidityTokenomics storage liquidityTokenomics = tokenEpochMap[address(token)];
        return liquidityTokenomics.epochs.length;
    }

    function getTokenReleaseAtIndex (address token, uint index) public view returns (uint256, uint256) {
        LiquidityTokenomics storage liquidityTokenomics = tokenEpochMap[address(token)];
        uint256 epoch = liquidityTokenomics.epochs[index];
        uint256 amount = liquidityTokenomics.releaseMap[epoch];
        return (epoch, amount);
    }

    function lockedTokensLength() external view returns (uint) {
        return lockedTokens.length;
    }
}
// File: localhost/contracts/SpaceMineToken.sol


pragma solidity 0.6.12;





contract SpaceMineCore is ERC20("SpaceMineToken", "MINE"), Ownable {
    using SafeMath for uint256;

    address internal _taxer;
    address internal _taxDestination;
	uint256 internal _cap;
    uint internal _taxRate = 0;
    bool internal _lock = true;
    mapping (address => bool) internal _taxWhitelist;

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(msg.sender == owner() || !_lock, "Transfer is locking");

        uint256 taxAmount = amount.mul(_taxRate).div(100);
        if (_taxWhitelist[msg.sender] == true) {
            taxAmount = 0;
        }
        uint256 transferAmount = amount.sub(taxAmount);
        require(balanceOf(msg.sender) >= amount, "insufficient balance.");
        super.transfer(recipient, transferAmount);

        if (taxAmount != 0) {
            super.transfer(_taxDestination, taxAmount);
        }
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender == owner() || !_lock, "TransferFrom is locking");

        uint256 taxAmount = amount.mul(_taxRate).div(100);
        if (_taxWhitelist[sender] == true) {
            taxAmount = 0;
        }
        uint256 transferAmount = amount.sub(taxAmount);
        require(balanceOf(sender) >= amount, "insufficient balance.");
        super.transferFrom(sender, recipient, transferAmount);
        if (taxAmount != 0) {
            super.transferFrom(sender, _taxDestination, taxAmount);
        }
        return true;
    }

	function _mint(address account, uint256 value) override internal {
        require(totalSupply().add(value) <= _cap, "cap exceeded");
        super._mint(account, value);
    }
}

contract SpaceMineToken is SpaceMineCore {
    mapping (address => bool) public minters;

	uint256 public constant hard_cap = 96000 * 1e18;

    constructor() public {
        _taxer = owner();
        _taxDestination = owner();
		_cap = hard_cap;
    }

	function cap() public view returns (uint256) {
        return _cap;
    }

    function mint(address to, uint amount) public onlyMinter {
        _mint(to, amount);
		_moveDelegates(address(0), _delegates[to], amount);
    }

	/// @notice A record of each accounts delegate
	mapping (address => address) public _delegates;
	/// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "MINE:delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "MINE::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "MINE::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "MINE::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying MINE;
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld-amount;
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld+amount;
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "MINE::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }

    function burn(uint amount) public {
        require(amount > 0);
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
    }

    function addMinter(address account) public onlyOwner {
        minters[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Restricted to minters.");
        _;
    }

    modifier onlyTaxer() {
        require(msg.sender == _taxer, "Only for taxer.");
        _;
    }

    function setTaxer(address account) public onlyTaxer {
        _taxer = account;
    }

    function setTaxRate(uint256 rate) public onlyTaxer {
        _taxRate = rate;
    }

    function setTaxDestination(address account) public onlyTaxer {
        _taxDestination = account;
    }

    function addToWhitelist(address account) public onlyTaxer {
        _taxWhitelist[account] = true;
    }

    function removeFromWhitelist(address account) public onlyTaxer {
        _taxWhitelist[account] = false;
    }

    function taxer() public view returns(address) {
        return _taxer;
    }

    function taxDestination() public view returns(address) {
        return _taxDestination;
    }

    function taxRate() public view returns(uint256) {
        return _taxRate;
    }

    function isInWhitelist(address account) public view returns(bool) {
        return _taxWhitelist[account];
    }

    function unlock() public onlyOwner {
        _lock = false;
    }

    function getLockStatus() view public returns(bool) {
        return _lock;
    }
}
// File: localhost/contracts/uniswapv2/interfaces/IERC20.sol

pragma solidity >=0.5.0;

interface IERC20Uniswap {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: localhost/contracts/uniswapv2/interfaces/IWETH.sol

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// File: localhost/contracts/uniswapv2/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
// File: localhost/contracts/uniswapv2/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// File: localhost/contracts/uniswapv2/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

  /*
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
  */
}

// File: localhost/contracts/uniswapv2/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function migrator() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setMigrator(address) external;
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


pragma solidity ^0.6.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




// File: @openzeppelin/contracts/math/SafeMath.sol


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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/math/Math.sol


pragma solidity ^0.6.0;

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



// File: localhost/contracts/SpaceMinePresale.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;













contract SpaceMinePresale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IUniswapV2Router02 private uniswapRouterV2;
    IUniswapV2Factory private uniswapFactory;
    IUniswapV2Pair private pair;
    POLContract private pol;
    address public tokenUniswapPair;

    SpaceMineToken public mine;

    mapping (address => bool) public whitelist;
    mapping (address => uint) public ethSupply;
    address payable devAddress;
    uint public minePrice = 10;
    uint public buyLimit = 4 * 1e18;
    bool public presaleStart = false;
    bool public onlyWhitelist = true;
    uint public presaleLastSupply = 8000 * 1e18;
    uint public initialLiquidityMax = 1600 * 1e18;
    uint256 public contractStartTimestamp;
    uint256 public constant LOCK_PERIOD = 26 weeks;
    bool public LPGenerationCompleted;
    uint256 public totalLPTokensMinted;
    uint256 public totalPresaleContributed;

    address payable constant UNICRYPT_DEPLOYER = 0x60e2E1b2a317EdfC870b6Fc6886F69083FB2099a;
    address constant UNISWAP_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant UNISWAP_ROUTER_V2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant UNICRYPT_POL = 0x17e00383A843A9922bCA3B280C0ADE9f8BA48449;

    event BuyMineSuccess(address account, uint ethAmount, uint mineAmount);

    constructor(
        SpaceMineToken _mine
        
    ) public {
        mine = _mine;
        initWhitelist();
        pairSetup();
    }

    function pairSetup() internal {
        uniswapRouterV2 = IUniswapV2Router02(UNISWAP_ROUTER_V2); // For testing
        uniswapFactory = IUniswapV2Factory(UNISWAP_FACTORY); // For testing

        pol = POLContract(payable(UNICRYPT_POL)); // For testing;
        createUniswapPair();
    }

    function createUniswapPair() internal {
        require(tokenUniswapPair == address(0), "Token: pool already created");
        tokenUniswapPair = uniswapFactory.createPair(
            address(uniswapRouterV2.WETH()),
            address(mine)
        );
        pair = IUniswapV2Pair(tokenUniswapPair);
    }

    function addToWhitelist(address account) public onlyOwner {
        require(whitelist[account] == false, "This account is already in whitelist.");
        whitelist[account] = true;
    }

    function removeFromWhitelist(address account) public onlyOwner {
        require(whitelist[account], "This account is not in whitelist.");
        whitelist[account] = false;
    }

    function startPresale() public onlyOwner {
        presaleStart = true;
        contractStartTimestamp = block.timestamp;
        mine.mint(address(this), initialLiquidityMax);
    }

    function stopPresale() public onlyOwner {
        presaleStart = false;
    }

    function setDevAddress(address payable account) public onlyOwner {
        devAddress = account;
    }

    function setMinePrice(uint newPrice) public onlyOwner {
        minePrice = newPrice;
    }

    function setBuyLimit(uint newLimit) public onlyOwner {
        buyLimit = newLimit;
    }

    function changeToNotOnlyWhitelist() public onlyOwner {
        onlyWhitelist = false;
    }

    function checkpresaleLastSupply() public view returns(uint){
        return presaleLastSupply;
    }

    function burnLeftoverMine() public onlyOwner {
        // Only available 24 hours after presale ends (48 hours after presale starts)
        require(contractStartTimestamp.add(2 days) < block.timestamp, "Grace period is not over yet");
        mine.burn(mine.balanceOf(address(this)));
    }

    modifier needHaveLastSupply() {
        require(presaleLastSupply >= 0, "Oh you are too late, all mine are gone");
        _;
    }

    modifier presaleHasStarted() {
        require(presaleStart, "Presale has not been started, buckle up!");
        _;
    }

    receive() payable external presaleHasStarted needHaveLastSupply {
        if (onlyWhitelist) {
            require(whitelist[msg.sender], "Currently only people who are in whitelist can participate");
        }
        uint ethTotalAmount = ethSupply[msg.sender].add(msg.value);
        require(ethTotalAmount <= buyLimit, "Everyone should buy lesser than 4 eth.");
        uint mineAmount = msg.value.mul(minePrice);
        require(mineAmount <= presaleLastSupply, "sorry, insufficient presale supply");
        totalPresaleContributed.add(msg.value);
        presaleLastSupply = presaleLastSupply.sub(mineAmount);
        devAddress.transfer(msg.value.div(2));
        mine.mint(msg.sender, mineAmount);
        ethSupply[msg.sender] = ethTotalAmount;
        emit BuyMineSuccess(msg.sender, msg.value, mineAmount);
    }

    function liquidityGeneration() public {
        require(LPGenerationCompleted == false, "Liquidity generation already finished");
        uint256 initialETHLiquidity = address(this).balance;

        //Wrap eth
        address WETH = uniswapRouterV2.WETH();
        IWETH(WETH).deposit{value : initialETHLiquidity}();
        require(address(this).balance == 0 , "Transfer Failed");
        IWETH(WETH).transfer(address(pair),initialETHLiquidity);

        uint256 initialLiquidity = initialETHLiquidity.mul(4);
        require(initialLiquidity <= initialLiquidityMax, "Error amount");

        mine.transfer(address(pair), initialLiquidity);
        pair.mint(address(this));
        totalLPTokensMinted = pair.balanceOf(address(this));
        require(totalLPTokensMinted != 0 , "LP creation failed");
        LPGenerationCompleted = true;

        uint256 unlockTime = block.timestamp + LOCK_PERIOD;

        IERC20(address(pair)).approve(address(pol), totalLPTokensMinted);
        pol.depositToken(address(pair), totalLPTokensMinted, unlockTime);
        require(pair.balanceOf(address(pol)) != 0, "Auto lock failed");
    }
    
    function withdrawLiquidity() public onlyOwner {
        uint256 withdrawable = pol.getWithdrawableBalance(address(pair), address(this));
        pol.withdrawToken(address(pair), withdrawable);
        pair.transfer(msg.sender, pair.balanceOf(address(this)));
    }

    // Emergency drain in case of a bug in liquidity generation
    // Adds all funds to owner to refund people
    // Only available 24 hours after presale ends (48 hours after presale starts)
    function emergencyDrain() public onlyOwner {
        require(contractStartTimestamp.add(2 days) < block.timestamp, "Grace period is not over yet");
        uint256 initialLiquidity = address(this).balance.mul(4);
        mine.transfer(UNICRYPT_DEPLOYER, initialLiquidity);
        (bool success, ) = UNICRYPT_DEPLOYER.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function initWhitelist() internal {
        //add the original whitelist
        whitelist[0x04b936745C02E8Cb75cC68b93B4fb99b38939d5D] = true;
        whitelist[0xcC4fB675c46F3715c52307c4d2f8640c4EF7bb31] = true;
        whitelist[0xA734871BC0f9d069936db4fA44AeA6d4325F41e5] = true;
        whitelist[0x9A8ea427c5CF4490c07428b853A5577c9B7a2d14] = true;
        whitelist[0x9DC6A59a9Eee821cE178f0aaBE1880874d48eca1] = true;
        whitelist[0x7149De569464C1c90f9d70cAf03B25dc2766E936] = true;
        whitelist[0xf21cE4A93534E725215bfEc2A5e1aDD496E80469] = true;
        whitelist[0xB7A641f8aebf507E1Bbc85F8feeEa56F38DbeB24] = true;
        whitelist[0x9a0F4440086141b9a405675fC8f839144Dd63B8F] = true;
        whitelist[0xbE18f84532d8f7fb6d7919401C0096f3e257DB8b] = true;
        whitelist[0xB4E383BEc5c5312F2E823d0A9C9eb17882f2aaF9] = true;
        whitelist[0x5b85988F0032ee818f911ec969Dd9c649CAa0a14] = true;
        whitelist[0xA43c750d5dE3Bd88EE4F35DEF72Cf76afEbeC274] = true;
        whitelist[0xfc35497204dA2d9539b23FE0D71022e2523d99b1] = true;
        whitelist[0x870ABcf52d52ECb1Ed00270433138262300BCC6d] = true;
        whitelist[0x5D39036947e83862cE5f3DB351cC64E3D4592cD5] = true;
        whitelist[0x63c9a867D704dF159bbBB88EeEe1609196b1995E] = true;
        whitelist[0xC0375Db78aB51B82E9bE2E139348491259280343] = true;
        whitelist[0x13EAEced8317889e7A3452A3ecb474b7801F20d8] = true;
        whitelist[0x81409E4C1a55C034EC86F64A75d18D911A8B0071] = true;
        whitelist[0x6CF51FDeF74d02296017A1129086Ee9C3477DC01] = true;
        whitelist[0xD87dB443b01Cb8e453c11f9a26F48CD51c19842a] = true;
        whitelist[0x10F555120485f0E352c0F11A4aC6f4A420300092] = true;
        whitelist[0xBf26925f736E90E1715ce4E04cD9c289dD1bc002] = true;
        whitelist[0xd39E6aD9d32D6c71326b800EA883c8Edc0b7B5e4] = true;
        whitelist[0xF03336c8c2B040cF026af8774B67127dFF5413A5] = true;
        whitelist[0x6CAd957812F1bb9aB9364F20cfA15482BcE9DE77] = true;
        whitelist[0x64aaaBE41689B60ed969386b2D154e3887f628F6] = true;
        whitelist[0x635954403448b9f55655FD5dbcC9675e8a4b8109] = true;
        whitelist[0xfCE9f37F4F554419E9c370c9e6c67Bd0020BF577] = true;
        whitelist[0x26FA038d801970EE46d53b0056658B4e1a4458Db] = true;
        whitelist[0x8e9817f8f20F4B6156B4548144a2affde1890f08] = true;
        whitelist[0xD6F50F21038c5479b9cc663794E7b5Fc876b3C26] = true;
        whitelist[0x5984bb82F11171cb1DC2287E2A6935c44D491538] = true;
        whitelist[0x0d79cce030AE9654aA9488524F407ce464297722] = true;
        whitelist[0x0A4D7Bf0abc967d6204b83173A98B14603057C08] = true;
        whitelist[0x908A52B2a18C7Adf135A861DE80b4952fF03BEEa] = true;
        whitelist[0xB8dCE88744A07baf3904BAc6D9cEE3D1927BBb5e] = true;
        whitelist[0x156D2893955A52fF0796d2D88BF6Ab2e7663e3FC] = true;
        whitelist[0x8b584Cf38bFE7d50809bbC2A622C7Bd118a82577] = true;
        whitelist[0x5f4B42AE45C1681f5b24eB6aFBd1F0f95d7c8E25] = true;
        whitelist[0xA6a576527217e0194c8CDb5f15F21209FeAB5FB7] = true;
        whitelist[0x40a4fce89b26E924A3b5f13A91E78A5dc4944a45] = true;
        whitelist[0x7f62Fbb8a9E707e44A198584ae2e8Db67cEfC30a] = true;
        whitelist[0xC82b6f107fA7Baeb0809B2645cE8AAC4328Cb75A] = true;
        whitelist[0xeFAE1190444Aae8CFF4915eb7D5054BFcDfEDcE6] = true;
        whitelist[0x963D961b4F18dB19d285F44e6De8D77BD457D7D6] = true;
        whitelist[0x538fAaE7e0fD3aDC7C400b0A1CCA242095ebB554] = true;
        whitelist[0x3049c80BDD527128eb4E7886AB1Db1E8042a8EB7] = true;
        whitelist[0x08BeEabCa238deb5ee1016618BF80c40Ad221C98] = true;
        whitelist[0xcA7F8f6A21C6e0F3b0177207407Fc935429BdD27] = true;
        whitelist[0xD45FcAca001032bcB6DC509b4E0dc97A3351Ca88] = true;
        whitelist[0xA0dc2b64eb9c93334225032383344a9a62DA9Ef0] = true;
        whitelist[0x9e353fbdC3eC7290290BdA31a8001cb609858adf] = true;
        whitelist[0x465FE2dbE1F73FA4dB8b2a3b8A4aafcACb2Bf1AA] = true;
        whitelist[0x8468c6Efa8ca7ffccB2C31D112e5e9331A469867] = true;
        whitelist[0x04A0f10c0Dcfa5a4C060E5421f385c2A0E541a94] = true;
        whitelist[0x61412bB7b13c24C3A913639a22BE592D65e797b6] = true;
        whitelist[0x12429F85Fa35183Bc7cA6750303ee3f6AFE31d13] = true;
        whitelist[0xE349a754b82eFa0AB90C69BBc2Bcc7Cf17CC8650] = true;
        whitelist[0x6f158C7DdAeb8594d36C8869bee1B3080a6e5317] = true;
        whitelist[0x1e9b0e7D28bC135584EA1717065a6CcE3298a80D] = true;
        whitelist[0x98C744edfd71F95a63423bEe72eAE5cB78415067] = true;
        whitelist[0x921AC49968F27B7922B5aB1757ef30508e787580] = true;
        whitelist[0x294e20DA26e64730FadA867213d011B622aD0bb8] = true;
        whitelist[0xd2a4A34eF72F766f269409702A811eec8D55F2dE] = true;
        whitelist[0x7ae9185fc5fC77fdf2CaFCb0018a54C34E733fe7] = true;
        whitelist[0x44Acd0Ff3bE9Fdfb932453C82B5dF5739D28b276] = true;
        whitelist[0x0Ed67742bb18250F0e0CeD12B980668A32437915] = true;
        whitelist[0xaa126ef289c099D46a5a9484C95707E681D278DD] = true;
        whitelist[0xdd8D647b0133dEdC7907bbd2E303C029E2009d2a] = true;
        whitelist[0xd81a19b8b3BE4912018b32AD634C0CA873f45189] = true;
        whitelist[0x13adb88D0CE40651625b43B597019f9CE3D60bCC] = true;
        whitelist[0x9FBEacDf803004e8BEF3e5013faF0bF0090e6588] = true;
        whitelist[0xE792be33d36df027c6a5ad9bFe9F74bD40AD0F58] = true;
        whitelist[0x064a5d4359FFF916e59E0d68f6094729c4052B8b] = true;
        whitelist[0xBc159B71c296c21a1895a8dDf0aa45969c5F17c2] = true;
        whitelist[0xeC31a56b8323dd7289F5f69F99F8F8558faDBBc9] = true;
        whitelist[0xF9687743fb84966f63afB100B0F6be8E4aEc374e] = true;
        whitelist[0x21A56D488521C02644698Bf30dF4D7aC21B03ED4] = true;
        whitelist[0x83B045a90C8f67B7734D3b0417ed20eD5933E67D] = true;
        whitelist[0x89A5d9e66AA6439f9daBa379078193AbA58d949a] = true;
        whitelist[0xf062B3ab33A518Ef57e0039379A128CaF2e01AD8] = true;
        whitelist[0x71fE41C174277D4f6D52BfB10B7CE8cB55Bad9Fe] = true;
        whitelist[0x0388134B224Fc69B19f26c65581356B6eEA9aF81] = true;
        whitelist[0xf403ad7F9F36D0201d5AFe7331b40835E3CEd922] = true;
        whitelist[0x166B6770f7513ee4BE7a88f7C8d250E5E8BCbfAF] = true;
        whitelist[0x97ca6aE239E5476b546Fc873002BF117Cc52F6df] = true;
        whitelist[0x76AaD6e2165a469feA3A02F545D9f6e5E6AAd2d5] = true;
        whitelist[0xf4c7E60fC24Bd932b275cAa71C4Cf6642e49F5BD] = true;
        whitelist[0xe8C0C83C181AACdab4f48624B5574CC88aD8E840] = true;
        whitelist[0x0910AEd2f4a4b3E7F399F3d5Cf6EdacA132b83D0] = true;
        whitelist[0xD631A7500c39368F021109F497c4eD85B8a256EA] = true;
        whitelist[0x127563d0B37872e4956BF9B033e3cc03c6bF7E45] = true;
        whitelist[0x88d6F54C227A0483272f03435af70b4A864A0333] = true;
        whitelist[0xCdD607DECbe9b714F6E032bA478830a521753233] = true;
        whitelist[0x92353D9186a1d02bE280F55C8A563762A9Edc100] = true;
        whitelist[0x2B5b1Fffe86302F73e478a0E09d8Bf92eC75FFba] = true;
        whitelist[0x6f7d991841CeFF8cEdFF91CfFc913a2CB4560d71] = true;
        whitelist[0x585020d9C6b56874B78979F29d84E082D34f0B2a] = true;
        whitelist[0x93f5af632Ce523286e033f0510E9b3C9710F4489] = true;
        whitelist[0x3DdaEf422793e387bdD2aD26F5d511A949708B1A] = true;
        whitelist[0x07D7E180C0Bd4ee3d5e25006dB854D81f76Fe1Fb] = true;
        whitelist[0x129e81DAD8cFAEecEE130309b39B5F22215062ED] = true;
        whitelist[0xdB32722A9dc5da52273F4fB1F25a8c75176c9Db2] = true;
        whitelist[0x688c3689C5a3Fa844C1D186db2393d4590044178] = true;
        whitelist[0x51D2C8b408B264dA569f75eCE31172f50b27E838] = true;
        whitelist[0xcCEE65c43C62338f13A638bB98f18E36801B7450] = true;
        whitelist[0xbB02B1B914590f69e9f1942d205f77276b4B3CA9] = true;
        whitelist[0xba30963F47A2d33476E922Faa55bEc570C433dD0] = true;
        whitelist[0xaca3365a1A6DBA0839b3B56219Cf250eBB9F32f1] = true;
        whitelist[0x70e703ba15c43Aa6D043b8c29e60927E3b01df73] = true;
        whitelist[0x374D37AA9d27C8a03F0d34Db0a9D441aAc99F186] = true;
        whitelist[0x70b53C16852a2e341a31F0e884983DE58B937301] = true;
        whitelist[0xAbC3EF008F7693C5A87ba317AA370c102C1DD690] = true;
        whitelist[0xCc22DDc2e3B896Dd2b22A18590E73a2194B22c9C] = true;
        whitelist[0xB16E1101CbB48F631AB4dBd54c801Ecef9B47D2b] = true;
        whitelist[0x81D7D1dc2B8de78E68a082C858DAcB5ed3631133] = true;
        whitelist[0x7Bf7Dedb68CAC2cFD0d99DFdDb703c4CE9640941] = true;
        whitelist[0xA87fB81CDC6dfa965Bf8b7F43219BCc326A74Cfb] = true;
        whitelist[0xCB0B5c48E08dC20A7F535E106703f3172fBE3012] = true;
        whitelist[0xe15863985BE0c9Fb9D590E2d1D6486a551d63e06] = true;
        whitelist[0x506adE0A94949dB63047346D3796A01C09384198] = true;
        whitelist[0x61069795367ECC82167b8349BBb562449e452aac] = true;
        whitelist[0x6d55db28aAaD7Ad31b33BF48a0461e202BF18622] = true;
        whitelist[0x4d28975B4Ed2a1a9A00C657f28344DCe37EE0Ac6] = true;
        whitelist[0xF6196741d0896dc362788C1FDbDF91b544Ab7C1C] = true;
        whitelist[0x52d2D6E5A8b0a7594250D720b66a791fc8e71538] = true;
        whitelist[0x24ED3B0C0a1cb8fEce7E3A25A34e86613234dD04] = true;
        whitelist[0x3Bd8a3C2d90e1709259Cd271A8e8d2C5caDeBE82] = true;
        whitelist[0x46B8FfC41F26cd896E033942cAF999b78d10c277] = true;
        whitelist[0x25D1cbf24e549CcaD81c2A5cab9e62c6be208920] = true;
        whitelist[0xE139962e5d7B07A9378F159A4A1b7CABe9Df1d6E] = true;
        whitelist[0x03b76647464CF57255f20289D2501417A5eC457E] = true;
        whitelist[0x338bfa2c23Cc5Daf45208A2f23431d91e668515a] = true;
        whitelist[0x67C0fc4B0490ab7E76C08C2bbD30fAc0059bbc7A] = true;
        whitelist[0xE37689CFf507cB199f55eaA23338181C9a63a748] = true;
        whitelist[0xA37F6C27c603619B729adCe9849f2C4FcF79AD83] = true;
        whitelist[0xFD0d152BF613956B6929A7156fE75eEE2A20C3B6] = true;
        whitelist[0x25DbEB6565778B8570f8936165370348f16E7E88] = true;
        whitelist[0x467e20bD74Bbba59dc6C88B3A975fBC381FA2441] = true;
        whitelist[0xff4d2D37a08f1B0d40dda7eAd1D88Aa5ceEF7C66] = true;
        whitelist[0x4010a534B8Ab01945DEc322F4eecd6A4B4785277] = true;
        whitelist[0xD9D4e0F4C81d13EDF3eE8ceC6Ff026a06D418301] = true;
        whitelist[0xcbBC5D06BE48B9B1D90A8E787B4d42bc4A3B74a8] = true;
        whitelist[0x908A52B2a18C7Adf135A861DE80b4952fF03BEEa] = true;
        whitelist[0x0B431F91c54C303AE29E4023A70da6caDEB0D387] = true;
        whitelist[0xC2ea0584A6B5dF8Ad2C488A208B2f1ac25f4019f] = true;
        whitelist[0xf2306b7547b4E7C3d2B4F0864900414A91d5571f] = true;
        whitelist[0x387EAf27c966bB6dEE6A0E8bA45ba0854d01Ee32] = true;
        whitelist[0x291F8D2F3D94ef8731807883B452A92627714d03] = true;
        whitelist[0x74f90fC63084F5AC7546d105397034ac8A4a51F7] = true;
        whitelist[0x6B511F9919E0239d345E2F0f2688E11d168829D1] = true;
        whitelist[0x700bdccb187238bC4263C233bCBE48c3BcF7d32d] = true;
        whitelist[0xb06336f40e1dE49c9c2f35C5742d1923cB4A9E7D] = true;
        whitelist[0xc6fE56E09F826245304BA8210BAEcAC306e67357] = true;
        whitelist[0xA538311df7DC52bBE861F6e3EfDD749730503Cae] = true;
        whitelist[0x42147EE918238fdfF257a15fA758944D6b870B6A] = true;
        whitelist[0x5b049c3Bef543a181A720DcC6fEbc9afdab5D377] = true;
        whitelist[0xBacEcAc3EA45372e6a83C2B97032211e4758368a] = true;
        whitelist[0x9Fe686D6fAcBC5AE4433308B26e7c810ac43F3D4] = true;
        whitelist[0x85b25DF7991AfF597DCf936DdC66A41100A1DF38] = true;
        whitelist[0x51Bc4B6db5D958d066d3c6C11C4396e881961bca] = true;
        whitelist[0x5CbAfbE163BD766B5EEd26D81ECea0f41f232847] = true;
        whitelist[0x8e76Bcf139d65f9c160E8Ef0ED321d7049A3ee83] = true;
        whitelist[0xB80216042142Ef55F6d61FD5ae0F23B25D150178] = true;
        whitelist[0x8760E565273B47195F76A22455Ce0B68A11aF5B5] = true;
        whitelist[0x164D39D1DB5Ec3b4472a18F0E588F0C1F0D98d9E] = true;
        whitelist[0x404C4f2C30B70135964397eA658C26b6997bdeD5] = true;
        whitelist[0xE2BF97AdEcabf5bbd9C184b287Cd0a0490c259Be] = true;
        whitelist[0x7dD1a007Ff481FEa56F9F5B5832ec9f40c01172e] = true;
        whitelist[0xca1B8F95046506fdF2560880b2beB2950CC9aED6] = true;
        whitelist[0x75A4c4730e354e1097bf2f8D447Ae7751c20E480] = true;
        whitelist[0x3B1d9AF9fBe4DE15E4C320304204c623E6726358] = true;
        whitelist[0xbcf7564427Bfa1C2f305eD2352E3987f19b46608] = true;
        whitelist[0xebeA475d9453122fA1E87E79883893A20A12f3f9] = true;
        whitelist[0x2E2Aa9909361F5e1c9f2f8a85AFF7ee8194eCCe9] = true;
        whitelist[0x399b282c17F8ed9F542C2376917947d6B79E2Cc6] = true;
        whitelist[0xd63a8b9699fbe0b0B70C443CDA57CD667A77D1b2] = true;
        whitelist[0x76AaD6e2165a469feA3A02F545D9f6e5E6AAd2d5] = true;
        whitelist[0x8b09C4Fd7f3beAFc91bbcA198313CFD0D1a5ecbB] = true;
        whitelist[0xDb704Df06A7fA515fe77B30595451346198bC44C] = true;
        whitelist[0x576fe99A39fEC41fC644f193C8F539FaEb038241] = true;
        whitelist[0x0869fD08Ff42889e11E09A0c2B46Ce3d163a25D5] = true;
        whitelist[0xcD5d0593c17c40BD2BB857B2dc9F6A3771862D8d] = true;
        whitelist[0x7C1ec41944A9591f48e44A9d4e8eDC43B7D58948] = true;
        whitelist[0x04b936745C02E8Cb75cC68b93B4fb99b38939d5D] = true;
        whitelist[0x4670D6b9AEf53615382934A481B133B70a3B631a] = true;
        whitelist[0xD87dB443b01Cb8e453c11f9a26F48CD51c19842a] = true;
        whitelist[0xe1b6514df22AfCd09DE787FdA75d0834bF9c8DC1] = true;
        whitelist[0xA3fE401D499f306C49b54ee89b4160f4832Cbe6e] = true;
        whitelist[0x98b7C27df27C857536C61aDEa0D3C9C7E327432d] = true;
        whitelist[0xAFdfF5466Db276b274BAE48336D1B6f70F644065] = true;
        whitelist[0x80b3bdAD4bA4D26aAe097f742A97cd016aB46F86] = true;
        whitelist[0x72a5Ba942a401C4BD08a32963B75f971292213a8] = true;
        whitelist[0xe2438Db969db43314040e51F95D425c1fe1cc433] = true;
        whitelist[0x7f59fbfe6C2cBA95173d69B4B0B00E09c76501FC] = true;
        whitelist[0xd29979e7a3560C450Dd94333215D42898e1BbA72] = true;
        whitelist[0xdFA2ba1473d66e06b57278A058e411364caB1449] = true;
        whitelist[0xF4F98B4a1B0a0F46bA8856939bAC69A40b1F5f56] = true;
    }
    
    function testMint() public onlyOwner {
        mine.mint(address(this), 1);
    }
    
    function isInWhitelist(address account) public view returns(bool) {
        return whitelist[account];
    }

}