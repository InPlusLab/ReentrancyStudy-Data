/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity 0.5.2;

/***************
**            **
** INTERFACES **
**            **
***************/

/**
 * @dev Interface of OpenZeppelin's ERC20; For definitions / documentation, see below.
 */
interface IERC20 {

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

}

/****************************
**                         **
** OPEN ZEPPELIN CONTRACTS **
**                         **
****************************/

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
contract ERC20 is IERC20 {
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
        _transfer(msg.sender, recipient, amount);
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
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
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
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(value, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(account, address(0), value);
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
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

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
        _burn(msg.sender, amount);
    }

    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}

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

/*******************
**                **
** KONG CONTRACTS **
**                **
*******************/

/**
 * @title  Kong ERC20 Token Contract.
 *
 * @dev    Extends OpenZeppelin contracts `ERC20`, `ERC20Detailed`, and `ERC20Burnable`.
 *
 *         Main additions:
 *
 *         - `beginLockDrop()`: Function to deploy instances of `LockDrop` contracts. This function
 *         can be called periodically. The amount of new tokens minted is proportional to the
 *         existing supply of tokens.
 *
 *         - `mint()`: Function to mint new Kong token. Can only be called by addresses that have
 *         been added to `_minters` through `addMinter()` which is only accessible to `owner`.
 *         `mint()` is subject to restrictions concerning the mintable amount (see below).
 */
contract KongERC20 is ERC20, ERC20Burnable, ERC20Detailed {
    // Constants.
    uint256 constant ONE_YEAR = 365 * 24 * 60 * 60;
    uint256 constant ONE_MONTH = 30 * 24 * 60 * 60;
    uint256 constant MINTING_REWARD = 2 ** 8 * 10 ** 18;

    // Account with right to add to `minters`.
    address public _owner;

    // Total amount minted through `minters`; does not include Genesis Kong.
    uint256 public _totalMinted;

    // Timestamp of contract deployment; used to calculate number of years since launch.
    uint256 public _launchTimestamp;

    // Address and timestamp of last `LockDrop` deployment.
    address public _lastLockDropAddress;
    uint256 public _lastLockDropTimestamp;

    // Addresses allowed to mint new Kong.
    mapping (address => bool) public _minters;

    // Emits when new `LockDrop` is deployed.
    event LockDropCreation(
        address deployedBy,
        uint256 deployedTimestamp,
        uint256 deployedSize,
        address deployedAddress
    );

    // Emits when a new address is added to `minters`.
    event MinterAddition(
        address minter
    );

    /**
     * @dev The constructor sets the following variables:
     *
     *      - `_name`,
     *      - `_symbol`,
     *      - `_decimals`,
     *      - `_owner`, and
     *      - `_launchTimeStamp`.
     *
     *      It also mints Genesis tokens.
     */
    constructor() public ERC20Detailed('KONG', 'KONG', 18) {

        // Set _owner.
        _owner = 0xAB35D3476251C6b614dC2eb36380D7AF1232D822;

        // Store launch time.
        _launchTimestamp = block.timestamp;

        // Mint Genesis Kong.
        _mint(0xAB35D3476251C6b614dC2eb36380D7AF1232D822, 3 * 2 ** 20 * 10 ** 18);
        _mint(0x9699b500fD907636f10965d005813F0CE0986176, 2 ** 20 * 10 ** 18);
        _mint(0xdBa9A507aa0838370399FDE048752E91B5a27F06, 2 ** 20 * 10 ** 18);
        _mint(0xb2E0F4dee26CcCf1f3A267Ad185f212Dd3e7a6b1, 2 ** 20 * 10 ** 18);
        _mint(0xdB6e9FaAcE283e230939769A2DFa80BdcD7E1E43, 2 ** 20 * 10 ** 18);

    }

    /**
     * @dev Function to add a minter.
     */
    function addMinter(address minter) public {

      require(msg.sender == _owner, 'Can only be called by owner.');

      _minters[minter] = true;
      emit MinterAddition(minter);

    }

    /**
     * @dev Function to deploy a new `LockDrop` contract. The function can be called every 30 days,
     *      i.e., whenever 30 days have passed since the function was last called successfully.
     *      Mints approximately (1.01^(1/12) - 1) percent of the current total supply
     *      and transfers the new tokens to the deployed contract. Mints `MINTING_REWARD` tokens
     *      to whoever calls it successfully.
     */
    function beginLockDrop() public {

        // Verify that time to last `LockDrop` deployment exceeds 30 days.
        require(_lastLockDropTimestamp + ONE_MONTH <= block.timestamp, '30 day cooling period.');

        // Update timestamp of last `LockDrop` deployment.
        _lastLockDropTimestamp = block.timestamp;

        // Calculate size of lockdrop as 0.0008295381 (¡Ö 1.01 ^ (1/12) - 1) times the total supply.
        uint256 lockDropSize = totalSupply().mul(8295381).div(10 ** 10);

        // Deploy a new `LockDrop` contract.
        LockDrop lockDrop = new LockDrop(address(this));

        // Update address of last lock drop.
        _lastLockDropAddress = address(lockDrop);

        // Mint `lockDropSize` to deployed `LockDrop` contract.
        _mint(_lastLockDropAddress, lockDropSize);

        // Mint `MINTING_REWARD` to msg.sender.
        _mint(msg.sender, MINTING_REWARD);

        // Emit event.
        emit LockDropCreation(
            msg.sender,
            block.timestamp,
            lockDropSize,
            address(lockDrop)
        );

    }

    /**
     * @dev Helper function to calculate the maximal amount `minters` are capable of minting.
     */
    function getMintingLimit() public view returns(uint256) {

        // Calculate number of years since launch.
        uint256 y = (block.timestamp - _launchTimestamp) / uint(ONE_YEAR);

        // Determine maximally mintable amount.
        uint256 mintingLimit = 2 ** 25 * 10 ** 18;
        if (y > 0) {mintingLimit += 2 ** 24 * 10 ** 18;}
        if (y > 1) {mintingLimit += 2 ** 23 * 10 ** 18;}
        if (y > 2) {mintingLimit += 2 ** 22 * 10 ** 18;}

        // Return.
        return mintingLimit;

    }

    /**
     * @dev Mints new tokens conditional on not exceeding minting limits. Can only be called by
     *      valid `minters`.
     */
    function mint(uint256 mintedAmount, address recipient) public {

        require(_minters[msg.sender] == true, 'Can only be called by registered minter.');

        // Enforce global cap.
        require(_totalMinted.add(mintedAmount) <= getMintingLimit(), 'Exceeds global cap.');

        // Increase minted amount.
        _totalMinted += mintedAmount;

        // Mint.
        _mint(recipient, mintedAmount);

    }

}

/**
 * @title   Lock Drop Contract
 *
 * @dev     This contract implements a Kong Lock Drop.
 *
 *          Notes (check online sources for further details):
 *
 *          - `stakeETH()` can be called to participate in the lock drop by staking ETH. Individual
 *          stakes are immediately sent to separate instances of `LockETH` contracts that only the
 *          staker has access to.
 *
 *          - `claimKong()` can be called to claim Kong once the staking period is over.
 *
 *          - The contract is open for contributions for 30 days after its deployment.
 */
contract LockDrop {
    using SafeMath for uint256;

    // Timestamp for the end of staking.
    uint256 public _stakingEnd;

    // Sum of all contribution weights.
    uint256 public _weightsSum;

    // Address of the KONG ERC20 contract.
    address public _kongERC20Address;

    // Mapping from contributors to contribution weights.
    mapping(address => uint256) public _weights;

    // Mapping from contributors to locking period ends.
    mapping(address => uint256) public _lockingEnds;

    // Events for staking and claiming.
    event Staked(
        address indexed contributor,
        address lockETHAddress,
        uint256 ethStaked,
        uint256 endDate
    );
    event Claimed(
        address indexed claimant,
        uint256 ethStaked,
        uint256 kongClaim
    );

    constructor (address kongERC20Address) public {

        // Set the address of the ERC20 token.
        _kongERC20Address = kongERC20Address;

        // Set the end of the staking period to 30 days after deployment.
        _stakingEnd = block.timestamp + 30 days;

    }

    /**
     * @dev Function to stake ETH in this lock drop.
     *
     *      When called with positive `msg.value` and valid `stakingPeriod`, deploys instance of
     *      `LockETH` contract and transfers `msg.value` to it. Each `LockETH` contract is only
     *      accessible to the address that called `stakeETH()` to deploy the respective instance.
     *
     *      For valid stakes, calculates the variable `weight` as the product of total lockup time
     *      and `msg.value`. Stores `weight` in `_weights[msg.sender]` and adds it to `_weightsSum`.
     *
     *      Expects `block.timestamp` to be smaller than `_stakingEnd`. Does not allow for topping
     *      up of existing stakes. Restricts staking period to be between 90 and 365.
     *
     *      Emits `Staked` event.
     */
    function stakeETH(uint256 stakingPeriod) public payable {

        // Require positive msg.value.
        require(msg.value > 0, 'Msg value = 0.');

        // No topping up.
        require(_weights[msg.sender] == 0, 'No topping up.');

        // No contributions after _stakingEnd.
        require(block.timestamp <= _stakingEnd, 'Closed for contributions.');

        // Ensure the staking period is valid.
        require(stakingPeriod >= 30 && stakingPeriod <= 365, 'Staking period outside of allowed range.');

        // Calculate contribution weight as product of msg.value and total time the ETH is locked.
        uint256 totalTime = _stakingEnd + stakingPeriod * 1 days - block.timestamp;
        uint256 weight = totalTime.mul(msg.value);

        // Adjust contribution weights.
        _weightsSum = _weightsSum.add(weight);
        _weights[msg.sender] = weight;

        // Set end date for lock.
        _lockingEnds[msg.sender] = _stakingEnd + stakingPeriod * 1 days;

        // Deploy new lock contract.
        LockETH lockETH = (new LockETH).value(msg.value)(_lockingEnds[msg.sender], msg.sender);

        // Abort if the new contract's balance is lower than expected.
        require(address(lockETH).balance >= msg.value);

        // Emit event.
        emit Staked(msg.sender, address(lockETH), msg.value, _lockingEnds[msg.sender]);

    }

    /**
     * @dev Function to claim Kong.
     *
     *      Determines the ratio of the contribution by `msg.sender` to all contributions. Sends
     *      the product of this ratio and the contract's Kong balance to `msg.sender`. Sets the
     *      contribution of `msg.sender` to zero afterwards and subtracts it from the sum of all
     *      contributions.
     *
     *      Expects `block.timestamp` to be larger than `_lockingEnds[msg.sender]`. Throws if
     *      `_weights[msg.sender]` is zero. Emits `Claimed` event.
     *
     *      NOTE: Overflow protection in calculation of `kongClaim` prevents anyone staking massive
     *      amounts from ever claiming. Fine as long as product of weight and the contract's Kong
     *      balance is at most (2^256)-1.
     */
    function claimKong() external {

        // Verify that this `msg.sender` has contributed.
        require(_weights[msg.sender] > 0, 'Zero contribution.');

        // Verify that this `msg.sender` can claim.
        require(block.timestamp > _lockingEnds[msg.sender], 'Cannot claim yet.');

        // Calculate amount to return.
        uint256 weight = _weights[msg.sender];
        uint256 kongClaim = IERC20(_kongERC20Address).balanceOf(address(this)).mul(weight).div(_weightsSum);

        // Adjust stake and sum of stakes.
        _weights[msg.sender] = 0;
        _weightsSum = _weightsSum.sub(weight);

        // Send kong to `msg.sender`.
        IERC20(_kongERC20Address).transfer(msg.sender, kongClaim);

        // Emit event.
        emit Claimed(msg.sender, weight, kongClaim);

    }

}

/**
 * @title   LockETH contract.
 *
 * @dev     Escrows ETH until `_endOfLockUp`. Calling `unlockETH()` after `_endOfLockUp` sends ETH
 *          to `_contractOwner`.
 */
contract LockETH {

    uint256 public _endOfLockUp;
    address payable public _contractOwner;

    constructor (uint256 endOfLockUp, address payable contractOwner) public payable {

        _endOfLockUp = endOfLockUp;
        _contractOwner = contractOwner;

    }

    /**
     * @dev Send ETH owned by this contract to `_contractOwner`. Can be called by anyone but
     *      requires `block.timestamp` > `endOfLockUp`.
     */
    function unlockETH() external {

        // Verify end of lock-up period.
        require(block.timestamp > _endOfLockUp, 'Cannot claim yet.');

        // Send ETH balance to `_contractOwner`.
        _contractOwner.transfer(address(this).balance);

    }

}