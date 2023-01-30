// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

// The ATTRToken is the Attrace utility token.
// More info: https://attrace.com
//
// We keep the contract upgradeable during development to make sure we can evolve and implement gas optimizations later on.
//
// Upgrade strategy towards DAO:
// -  Pre-DAO: the token is managed and improved by the Attrace project.
// -  When DAO is achieved: the token will become owned by the DAO contracts, or if the DAO decides to lock the token, then it can do so by transferring ownership to a contract which can't be upgraded.
contract ATTRToken is ERC20Upgradeable {
  // Accounts which can transfer out in the pre-listing period
  mapping(address => bool) private _preListingAddrWL;

  // Timestamp when rules are disabled, once this time is reached, this is irreversible
  uint64 private _wlDisabledAt;

  // Who can modify _preListingAddrWL and _wlDisabledAt (team doing the listing).
  address private _wlController;

  // Account time lock & vesting rules
  mapping(address => TransferRule) public transferRules;

  // Emitted whenever a transfer rule is configured
  event TransferRuleConfigured(address addr, TransferRule rule);  

  function initialize(address preListWlController) public initializer {
    __ERC20_init("Attrace", "ATTR");
    _mint(msg.sender, 10 ** 27); // 1000000000000000000000000000 aces, 1,000,000,000 ATTR
    _wlController = address(preListWlController);
    _wlDisabledAt = 1624399200; // June 23 2021
  }

  // Hook into openzeppelin's ERC20Upgradeable flow to support golive requirements
  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);

    // When not yet released, verify that the sender is white-listed.
    if(_wlDisabledAt > block.timestamp) {
      require(_preListingAddrWL[from] == true, "not yet tradeable");
    }

    // If we reach this, the token is already released and we verify the transfer rules which enforce locking and vesting.
    if(transferRules[from].tokens > 0) {
      uint lockedTokens = calcBalanceLocked(from);
      uint balanceUnlocked = super.balanceOf(from) - lockedTokens;
      require(amount <= balanceUnlocked, "transfer rule violation");
    }

    // If we reach this, the transfer is successful.
    // Check if we should lock/vest the recipient of the tokens.
    if(transferRules[from].outboundVestingMonths > 0 || transferRules[from].outboundTimeLockMonths > 0) {
      // We don't support multiple rules, so recipient should not have vesting rules yet.
      require(transferRules[to].tokens == 0, "unsupported");
      transferRules[to].timeLockMonths = transferRules[from].outboundTimeLockMonths;
      transferRules[to].vestingMonths = transferRules[from].outboundVestingMonths;
      transferRules[to].tokens = uint96(amount);
      transferRules[to].activationTime = uint40(block.timestamp);
    }
  }

  // To support listing some addresses can be allowed transfers pre-listing.
  function setPreReleaseAddressStatus(address addr, bool status) public {
    require(_wlController == msg.sender);
    _preListingAddrWL[addr] = status;
  }

  // Once pre-release rules are disabled, rules remain disabled
  // While not expected to be used, in case of need (to support optimal listing), the team can control the time the token becomes tradeable.
  function setNoRulesTime(uint64 disableTime) public {
    require(_wlController == msg.sender); // Only controller can 
    require(_wlDisabledAt > uint64(block.timestamp)); // Can not be set anymore when rules are already disabled
    require(disableTime > uint64(block.timestamp)); // Has to be in the future
    _wlDisabledAt = disableTime;
  }

  // ---- LOCKING & VESTING RULES

  // The contract embeds transfer rules for project go-live and vesting.
  // Vesting rule describes the vesting rule a set of tokens is under since a relative time.
  // This is gas-optimized and doesn't require the user to do any form of release() calls. 
  // When the periods expire, tokens will become tradeable.
  struct TransferRule {
    // The number of 30-day periods timelock this rule enforces.
    // This timelock starts from the rule activation time.
    uint16 timeLockMonths; // 2

    // The number of 30-day periods vesting this rule enforces.
    // This period starts after the timelock period has expired.
    // The number of tokens released in every cycle equals rule.tokens/vestingMonths.
    uint16 vestingMonths; // 2

    // The number of tokens managed by the rule
    // Eg: when ecosystem adoption sends N ATTR to an exchange, then this will have 1000 tokens.
    uint96 tokens; // 12

    // Time when the rule went into effect
    // When the rule is 0, then the _wlDisabledAt time is used (time of listing).
    // Eg: when ecosystem adoption wallet does a transfer to an exchange, the rule will receive block.timestamp.
    uint40 activationTime; // 5

    // Rules to apply to outbound transfers.
    // Eg: ecosystem adoption wallet can do transfers, but all received assets will be under locked rules.
    // When the recipient already has a vesting rule, the transfer will fail.
    // rule.activationTime and rule.tokens will be set by the transfer caller.
    uint16 outboundTimeLockMonths; // 2
    uint16 outboundVestingMonths; // 2
  }

  // Calculate how many tokens are still locked for a holder 
  function calcBalanceLocked(address from) private view returns (uint) {
    // When no activation time is defined, the moment of listing is used.
    uint activationTime = (transferRules[from].activationTime == 0 ? _wlDisabledAt : transferRules[from].activationTime);

    // First check the time lock
    uint secondsLocked;
    if(transferRules[from].timeLockMonths > 0) {
      secondsLocked = (transferRules[from].timeLockMonths * (30 days));
      if(activationTime+secondsLocked >= block.timestamp) {
        // All tokens are still locked
        return transferRules[from].tokens;
      }
    }

    // If no time lock, then calculate how much is unlocked according to the vesting rules.
    if(transferRules[from].vestingMonths > 0) {
      uint vestingStart = activationTime + secondsLocked;
      uint unlockedSlices = 0;
      for(uint i = 0; i < transferRules[from].vestingMonths; i++) {
        if(block.timestamp >= (vestingStart + (i * 30 days))) {
          unlockedSlices++;
        }
      }
      // If all months are vested, return 0 to ensure all tokens are sent back
      if(transferRules[from].vestingMonths == unlockedSlices) {
        return 0;
      }

      // Send back the amount of locked tokens
      return (transferRules[from].tokens - ((transferRules[from].tokens / transferRules[from].vestingMonths) * unlockedSlices));
    }

    // No tokens are locked
    return 0;
  }

  // The contract enforces all vesting and locking rules as desribed on https://attrace.com/community/attr-token/#distribution
  // We don't lock tokens into another contract, we keep them allocated to the respective account, but with a locking rule on top of it.
  // When the last vesting rule expires, checking the vesting rules is ignored automatically and overall gas off the transfers lowers with an SLOAD cost.
  function setTransferRule(address addr, TransferRule calldata rule) public {
    require(_wlDisabledAt > uint64(block.timestamp)); // Can only be set before listing
    require(_wlController == msg.sender); // Only the whitelist controller can set rules before listing

    // Validate the rule
    require(
      // Either a rule has a token vesting/lock
      (rule.tokens > 0 && (rule.vestingMonths > 0 || rule.timeLockMonths > 0))
      // And/or it has an outbound rule
      || (rule.outboundTimeLockMonths > 0 || rule.outboundVestingMonths > 0), 
      "invalid rule");

    // Store the rule
    // Rules are allowed to have an empty activationTime, then listing moment will be used as activation time.
    transferRules[addr] = rule;

    // Emit event that a rule was set
    emit TransferRuleConfigured(addr, rule);
  }

  function getLockedTokens(address addr) public view returns (uint256) {
    return calcBalanceLocked(addr);
  }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
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
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

{
  "metadata": {
    "useLiteralContent": true
  },
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
  }
}