pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

struct VestingWallet {
    address wallet;
    uint256 totalAmount;
    uint256 dayAmount;
    uint256 startDay;
    uint256 afterDays;
    bool nonlinear;
    bool advisory;
}

/**
 * dailyRate:       the daily amount of tokens to give access to,
 *                  this is a percentage * 1000000000000000000
 *                  this value is ignored if nonlinear is true
 * afterDays:       vesting cliff, dont allow any withdrawal before these days expired
 * nonlinear:       non linear vesting, used for PRIVATE/FOUNDATION/STRATEGIC sales
 **/

struct VestingType {
    uint256 dailyRate;
    uint256 afterDays;
    bool nonlinear;
    bool advisory;
}
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PNLToken is Ownable, ERC20Burnable {
    using SafeMath for uint256;

    mapping(address => VestingWallet) public vestingWallets;
    VestingType[] public vestingTypes;

    mapping(address => bool) public freezeList;

    uint256 public constant PRECISION = 1e18;
    uint256 public constant ONE_HUNDRED_PERCENT = PRECISION * 100;

    // Non linear unlocks [i,j] j% per day for i days
    uint256[][] public nonLinearUnlock = [
        [10000000000000000000, 1], //10% during the first day
        [1000000000000000000, 40], //1% for the next 40 days
        [250000000000000000, 200] // then 0.25% per 200 days
    ];

    uint256[][] public advisoryNonLinearUnlock = [
        [uint256(20000000000000000000), 1], //20% during the first day
        [uint256(666666666666666666), 121] //0,66% daily after
    ];

    /**
     * Setup the initial supply and types of vesting schemas
     **/

    constructor() ERC20("PNLToken", "PNL") {
        // 0: TEAM, 2.7% monthly (0.09% daily) 1 year after TGE.
        vestingTypes.push(
            VestingType(92592592000000000, 360 days, false, false)
        );

        // 1: MARKETING, 3% monthly (0.1% daily) after TGE.
        vestingTypes.push(VestingType(100000000000000000, 0, false, false));

        // 2: SEED/PRIVATE/STRATEGIC NONLINEAR 10% at TGE, then 1% daily over 40 days, then 0.25% for 200 days.
        vestingTypes.push(VestingType(0, 0, true, false));

        // 3: ADVISORY. 20% at TGE, then 0,67% daily over 120 days
        vestingTypes.push(VestingType(0, 0, true, true));

        // 4: Immediate unlock
        vestingTypes.push(VestingType(100000000000000000000, 0, false, false));

        // 5: FOUNDATION. 5% monthly (0.166% daily) 1 year after TGE.
        vestingTypes.push(
            VestingType(166666666666666666, 360 days, false, false)
        );

        // 6: STACKING. 4.17% monthly (0.139% daily) after TGE
        vestingTypes.push(VestingType(138888888888888888, 0, false, false));

        // Release BEFORE token start, tokens for liquidity
        _mint(address(0xB1537209C77C42d5fe33B56FD2bA3a7434c5Acb8), 1500000e18);

        // and public sale
        _mint(address(0xB1537209C77C42d5fe33B56FD2bA3a7434c5Acb8), 3400000e18);
    }

    // Vested tokens wont be available before the listing time
    function getListingTime() public pure returns (uint256) {
        return 1621357200;
    }

    function getMaxTotalSupply() public pure returns (uint256) {
        return PRECISION * 1e8; // 100 million tokens with 18 decimals
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 z
    ) private pure returns (uint256) {
        return x.mul(y).div(z);
    }

    function freeze(address user) external onlyOwner {
        freezeList[user] = true;
    }

    function unfreeze(address user) external onlyOwner {
        freezeList[user] = false;
    }

    function addAllocations(
        address[] memory addresses,
        uint256[] memory totalAmounts,
        uint256 vestingTypeIndex
    ) external onlyOwner returns (bool) {
        require(
            addresses.length == totalAmounts.length,
            "Address and totalAmounts length must be same"
        );
        require(
            vestingTypeIndex < vestingTypes.length,
            "Vesting type isnt found"
        );

        VestingType memory vestingType = vestingTypes[vestingTypeIndex];
        uint256 addressesLength = addresses.length;

        for (uint256 i = 0; i < addressesLength; i++) {
            address _address = addresses[i];
            uint256 totalAmount = totalAmounts[i];
            // We add 1 to round up, this prevents small amounts from never vesting
            uint256 dayAmount =
                mulDiv(
                    totalAmounts[i],
                    vestingType.dailyRate,
                    ONE_HUNDRED_PERCENT
                );
            uint256 afterDay = vestingType.afterDays;
            bool nonlinear = vestingType.nonlinear;
            bool advisory = vestingType.advisory;

            addVestingWallet(
                _address,
                totalAmount,
                dayAmount,
                afterDay,
                nonlinear,
                advisory
            );
        }

        return true;
    }

    function _mint(address account, uint256 amount) internal override {
        uint256 totalSupply = super.totalSupply();
        require(
            getMaxTotalSupply() >= totalSupply.add(amount),
            "Maximum supply exceeded!"
        );
        super._mint(account, amount);
    }

    function addVestingWallet(
        address wallet,
        uint256 totalAmount,
        uint256 dayAmount,
        uint256 afterDays,
        bool nonlinear,
        bool advisory
    ) internal {
        require(
            vestingWallets[wallet].totalAmount == 0,
            "Vesting wallet already created for this address"
        );

        uint256 releaseTime = getListingTime();

        // Create vesting wallets
        VestingWallet memory vestingWallet =
            VestingWallet(
                wallet,
                totalAmount,
                dayAmount,
                releaseTime.add(afterDays),
                afterDays,
                nonlinear,
                advisory
            );

        vestingWallets[wallet] = vestingWallet;
        _mint(wallet, totalAmount);
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    /**
     * Returns the amount of days passed with vesting
     */

    function getDays(uint256 afterDays) public view returns (uint256) {
        uint256 releaseTime = getListingTime();
        uint256 time = releaseTime.add(afterDays);

        if (block.timestamp < time) {
            return 0;
        }

        uint256 diff = block.timestamp.sub(time);
        uint256 ds = diff.div(1 days).add(1);

        return ds;
    }

    function isStarted(uint256 startDay) public view returns (bool) {
        uint256 releaseTime = getListingTime();

        if (block.timestamp < releaseTime || block.timestamp < startDay) {
            return false;
        }

        return true;
    }

    // Calculate the amount of unlocked tokens after X days for a given amount, nonlinear
    function calculateNonLinear(uint256 _days, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (_days > 360) {
            return amount;
        }

        uint256 unlocked = 0;
        uint256 _days_remainder = 0;

        for (uint256 i = 0; i < nonLinearUnlock.length; i++) {
            if (_days <= _days_remainder) break;

            if (_days.sub(_days_remainder) >= nonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(amount, nonLinearUnlock[i][0], ONE_HUNDRED_PERCENT)
                        .mul(nonLinearUnlock[i][1])
                );
            }

            if (_days.sub(_days_remainder) < nonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(amount, nonLinearUnlock[i][0], ONE_HUNDRED_PERCENT)
                        .mul(_days.sub(_days_remainder))
                );
            }

            _days_remainder += nonLinearUnlock[i][1];
        }

        if (unlocked > amount) {
            unlocked = amount;
        }

        return unlocked;
    }

    function calculateNonLinearAdvisory(uint256 _days, uint256 amount)
        public
        view
        returns (uint256)
    {
        if (_days > 360) {
            return amount;
        }

        uint256 unlocked = 0;
        uint256 _days_remainder = 0;

        for (uint256 i = 0; i < advisoryNonLinearUnlock.length; i++) {
            if (_days <= _days_remainder) break;

            if (_days.sub(_days_remainder) >= advisoryNonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(
                        amount,
                        advisoryNonLinearUnlock[i][0],
                        ONE_HUNDRED_PERCENT
                    )
                        .mul(advisoryNonLinearUnlock[i][1])
                );
            }

            if (_days.sub(_days_remainder) < advisoryNonLinearUnlock[i][1]) {
                unlocked = unlocked.add(
                    mulDiv(
                        amount,
                        advisoryNonLinearUnlock[i][0],
                        ONE_HUNDRED_PERCENT
                    )
                        .mul(_days.sub(_days_remainder))
                );
            }

            _days_remainder += advisoryNonLinearUnlock[i][1];
        }

        if (unlocked > amount) {
            unlocked = amount;
        }

        return unlocked;
    }

    // Returns the amount of tokens unlocked by vesting so far
    function getUnlockedVestingAmount(address sender)
        public
        view
        returns (uint256)
    {
        if (vestingWallets[sender].totalAmount == 0) {
            return 0;
        }

        if (!isStarted(0)) {
            return 0;
        }

        uint256 dailyTransferableAmount = 0;
        uint256 trueDays = getDays(vestingWallets[sender].afterDays);

        if (vestingWallets[sender].nonlinear == true) {
            if (vestingWallets[sender].advisory == false) {
                dailyTransferableAmount = calculateNonLinear(
                    trueDays,
                    vestingWallets[sender].totalAmount
                );
            } else {
                dailyTransferableAmount = calculateNonLinearAdvisory(
                    trueDays,
                    vestingWallets[sender].totalAmount
                );
            }
        } else {
            dailyTransferableAmount = vestingWallets[sender].dayAmount.mul(
                trueDays
            );
        }

        if (dailyTransferableAmount > vestingWallets[sender].totalAmount) {
            return vestingWallets[sender].totalAmount;
        }

        return dailyTransferableAmount;
    }

    // Returns the amount of vesting tokens still locked
    function getRestAmount(address sender) public view returns (uint256) {
        uint256 transferableAmount = getUnlockedVestingAmount(sender);
        uint256 restAmount =
            vestingWallets[sender].totalAmount.sub(transferableAmount);

        return restAmount;
    }

    function isFrozen(address sender) public view returns (bool) {
        if (freezeList[sender] == true) return false;
        return true;
    }

    // Transfer control
    function canTransfer(address sender, uint256 amount)
        public
        view
        returns (bool)
    {
        // Treat as a normal coin if this is not a vested wallet
        if (vestingWallets[sender].totalAmount == 0) {
            return true;
        }

        uint256 balance = balanceOf(sender);
        uint256 restAmount = getRestAmount(sender);

        // Account for sending received tokens outside of the vesting schedule
        if (
            balance > vestingWallets[sender].totalAmount &&
            balance.sub(vestingWallets[sender].totalAmount) >= amount
        ) {
            return true;
        }

        // Don't allow vesting if the period has not started yet or if you are below allowance
        if (
            !isStarted(vestingWallets[sender].startDay) ||
            balance.sub(amount) < restAmount
        ) {
            return false;
        }

        return true;
    }

    // @override
    function _beforeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override(ERC20) {
        // Reject any transfers that are not allowed
        require(isFrozen(sender), "The account is frozen");
        require(
            canTransfer(sender, amount),
            "Unable to transfer, not unlocked yet."
        );
        super._beforeTokenTransfer(sender, recipient, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "../../utils/Context.sol";

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
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}