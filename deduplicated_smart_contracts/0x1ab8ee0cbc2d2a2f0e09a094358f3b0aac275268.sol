/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

// File: contracts/libraries/SafeMath.sol

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.7.0;

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

}

// File: contracts/ERC1822/Proxiable.sol

/**
* @title Proxiable
* @dev Etherland - EIP-1822 Proxiable contract implementation for ELAND ERC20
* @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1822.md
*/
contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }
    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

// File: contracts/LANDID/iLANDID.sol

/**
* @title Etherland ERC721 LANDID administrator access granting system
*/
interface iLANDID {
    function adminRightsOf(address _admin) external view returns(int16);
}

// File: contracts/Storage.sol

contract Storage {

    // 
    // Ownable.sol
    //
    /**
    * @dev Etherland owner address
    */
    address public owner;
    /**
    * @dev Generated random salt acting in the safecheck mechanism when renouncing contract ownership 
    */
    bytes32 internal relinquishmentToken;
    /**
    * @dev Standalone mode
    * @notice see renounceOwnership method's notice below
    */
    bool public standalone = false;

    //
    // ERC20.sol
    //
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    //
    // ERC20Capped.sol
    //
    uint256 internal _cap;
    // Instance of Etherland LANDID NFT Administrator rights verifier

    //
    // LandRegistry.sol
    //
    iLANDID landid;
    // address of Etherland LANDID NFT
    address public landidNftAddress;
    // address of the wallet dedicated to land registration
    address internal landRegistration;
    // Land registry can be opened or closed
    bool public landRegistryOpened = false;
    // Land registry rights offers
    uint[] public recordRightsOffers;
    // Schema defining a Right to register a new land
    struct RecordRight {
        // the block timestamp of the record request
        uint time;
        // the tokenId representing the resultant minted LANDID NFT token id
        uint tokenId;
        // The new land record right which was purchased in ELAND. Registration rights are considered available when the tokenId is LESS than 1
        uint right;
    }
    // Land registry record rights tracking
    mapping (address => RecordRight[]) public registryRecordRights;

    //
    // ERC20Mintable.sol
    //
    bool _mintingFinished = false;

    // 
    // Etherland.sol
    //
    /**
    * @dev Contact initialization state
    * initialized state is set upon construction
    * MUST be initialized to be valid
    */
    bool public initialized = false;
    /**
    * @dev Etherland Wallets
    */
    address public team;
    address public reserve;
}

// File: contracts/Context.sol

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
contract Context is Storage {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

// File: contracts/Ownable.sol

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable is Context {

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev Throws if called by any account other than the owner or if the contract has standalone state
    */
    modifier onlyOwner() {
        require(!standalone, 'denied : owner actions are locked when contract is running standalone');
        require(_msgSender() != address(0), "denied : zero address has no rights");
        require(_msgSender() == owner, "denied : method access is restricted to the contract owner");
        _;
    }

    function getRelinquishmentToken() public onlyOwner view returns (bytes32 _relinquishmentToken) {
        return relinquishmentToken;
    }

    /**
    * IRREVERSIBLE ACTION
    * @dev Allows the current owner to definitively and safely relinquish control of the contract.
    * @notice once owner renounces to its ownership, the contract runs in standalone mode meaning that : 
    *   - the contract is left without any owner
    *   - no other owner will ever be set for the remaining contract lifetime
    *   - no one will no longer ever have any access to owner-restricted methods
    */
    function renounceOwnership(bytes32 _relinquishmentToken) public onlyOwner {
        require(
            ((relinquishmentToken != bytes32(0)) && (relinquishmentToken == _relinquishmentToken)), 
            'denied : a relinquishment token must be pre-set calling the preRenounceOwnership method');
        // require(landRegistryOpened, 'Land registry must be opened to renounce ownership');
        emit OwnershipRenounced(owner);
        standalone = true;
        owner = address(0);
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @return _relinquishmentToken : auto generated bytes32 key 
    * @notice generating this key allows the contract owner to pass it to the renounceOwnership method in order to set the contract as standalone
    */
    function preRenounceOwnership() public onlyOwner returns(bytes32 _relinquishmentToken) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, uint8(_msgSender()))));
        bytes32 salt = bytes32(rand);
        relinquishmentToken = salt;
        _relinquishmentToken = salt;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "the new owner can't be the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// File: contracts/ERC20/IERC20.sol

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

// File: contracts/ERC20/ERC20.sol

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
contract ERC20 is Ownable, IERC20 {
    using SafeMath for uint256;

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
     * Requirements:
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
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: can't burn from the zero address");

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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { 
        bool hasFrom = from != address(0);
        bool hasTo = to != address(0);
        require((hasFrom || hasTo), 'Must provide at least one address to transfer');
        if(hasFrom && hasTo) {
            require(_balances[from] >= amount, 'not enough funds to transfer');
        }
        else if (!hasFrom) {
            // require(!mintingFinished, 'minting is finished');
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");

        }
        else if (!hasTo) {
            require(_balances[from] >= amount, 'not enough funds to burn');
        }
    }
}

// File: contracts/ERC20/ERC20Capped.sol

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
contract ERC20Capped is ERC20 {
    using SafeMath for uint256;

    // uint256 private _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    function setImmutableCap(uint256 cap_) internal {
        require(cap() == 0, 'cap value is immutable and is already set to 1 Billion ELAND');
        require(cap_ > 0, "cap must be higher than 0");
        _cap = cap_;
    }

    /**
    * @dev Cap that is set on the total token supply
    *   Represents the maximum amount of tokens the contract will ever mint 
    * @notice cap value is 1 000 000 000 (1 Billion) ELAND tokens and are all pre-minted upon contract construction
    */
    function cap() public view returns (uint256) {
        return _cap;
    }

}

// File: contracts/ERC20/ERC20Burnable.sol

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is ERC20Capped {
    using SafeMath for uint256;

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
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}

// File: contracts/ERC20/ERC20Mintable.sol

/**
* @title Mintable token
* @dev Simple ERC20 Token Mintable implementation
* @notice will be used only once on contrat construction, then minting MUST be automatically terminated 
*/
contract ERC20Mintable is ERC20Burnable {
    using SafeMath for uint256;

    /**
    * @dev Minting event for Etherland *MUST* fire only once by supply partition (see Etherland.sol `init` function called when migrating
    */
    event Mint(address indexed to, uint256 amount);

    function mintingFinished() public view returns(bool){
        return _mintingFinished;
    }

    /**
    * @dev Function to internally mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    * @notice this method is called only once in Etherland contract lifetime as minting is terminated upon initial contract migration on chain
    */
    function mint(
        address _to,
        uint256 _amount
    )
        internal
        returns (bool)
    {
        require(mintingFinished() == false, 'ERC20Mintable : Minting is finished');
        _mint(_to, _amount);
        Mint(_to, _amount);
        return true;
    }

}

// File: contracts/LANDID/LandRegistry.sol

/**
 * @title Land Registry
 *
 * @dev Etherland - Decentralized Land Registration Protocol
 *  Allows ELAND owners to register lands in the Etherland eco-system by minting Etherland ERC721 LANDID NFT
 *
 * @author Mathieu Lecoq
 *  december 20th 2020 
 *
 * @dev Property
 *  all rights are reserved to Etherland ltd
*/
contract LandRegistry is ERC20Mintable {

    modifier isNftAdmin() {
        landid = iLANDID(landidNftAddress);
        int16 adminRight = landid.adminRightsOf(_msgSender());
        require((adminRight > 0) && (adminRight < 3), 'denied : restricted to LANDID NFT admins');
        _;
    }

    /**
    * @dev Allow any NFT admin to set public prices for record rights
    * @param _indexedRecordOffers Array of indexed public ELAND prices of record rights
    * @return boolean indicating operation success/failure
    */
    function setRecordRightsOffers(uint[] memory _indexedRecordOffers) public isNftAdmin returns (bool) {
        recordRightsOffers = _indexedRecordOffers;
        return true;
    }

    /**
    * @dev Let owner open land registry to allow ELAND owners register new lands
    * @return boolean indicating operation success/failure
    */
    function openLandRegistry() public isNftAdmin returns (bool) {
        landRegistryOpened = true;
        return true;
    }

    /**
    * @dev Let owner close land registry to avoid ELAND owners register new lands
    * @return boolean indicating operation success/failure
    */
    function closeLandRegistry() public isNftAdmin returns (bool) {
        landRegistryOpened = false;
        return true;
    }

    /**
    * @dev Allow ELAND owners to mint LANDID automatically or not depending on current mode
    * @param recordIndex the index of record right offer to give corresponding to `recordRightsOffers` indexes
    * @return boolean indicating operation success/failure
    */
    function registerLand(uint recordIndex) public returns (bool) {
        require(landRegistryOpened && (landRegistration != address(0)), "denied : can't register new land for now");

        uint recordPrice = recordRightsOffers[recordIndex];
        require(recordPrice > 0, 'denied : no preset price for provided record right');

        bool transferred = transfer(landRegistration, recordPrice);
        require(transferred, 'denied : value corresponding to requested record right price has not been transferred');

        RecordRight memory recordRight;
        recordRight.time = block.timestamp;
        recordRight.right = recordIndex;

        // store record right
        registryRecordRights[_msgSender()].push(recordRight);

        return true;
    }

    /**
    * @dev Assert that a RecordRight is valid and can be consumed (has no attached tokenId and has a valid block.timestamp)
    * @param time a valid block.timestamp corresponding to the time of the record request
    * @param tokenId the LANDID NFT tokenId attached to the tested RecordRight 
    *       - 0 means available
    *       - any other value means that the right has already been consumed and that RecordRight is invalid
    * @return boolean indicating validity / availability of the record right
    */
    function validRecordRight(uint time, uint tokenId) internal pure returns(bool) {
        return(
            (time > 0)
            && (tokenId == 0)
        );
    }

    /**
    * @dev Allow LANDID NFT administrators to consume a registry record right of an owner indicating minting of the record request related NFT
    * @param _owner address of the RecordRight owner
    * @param recordIndex the index of record right offer that has been paid by _owner (must correspond to a `recordRightsOffers` index)
    * @param tokenId the LANDID NFT tokenId attached to attach to the first available/matching RecordRight 
    * @return boolean indicating if valid target right for `recordIndex` has been found and consumed
    */
    function consumeRecordRight(address _owner, uint recordIndex, uint tokenId) public isNftAdmin returns (bool) {
        RecordRight[] memory ownerRecordRights = registryRecordRights[_owner];
        require(ownerRecordRights.length > 0, 'denied : no record right found for provided address');

        bool consumed = false;

        for (uint i = 0; i < ownerRecordRights.length; i++) {
            RecordRight memory recordRight = ownerRecordRights[i];
            if (
                consumed == false
                && recordRight.right == recordIndex
                && validRecordRight(recordRight.time, recordRight.tokenId)
            ) {
                // consume right
                recordRight.tokenId = tokenId;
                registryRecordRights[_owner][i] = recordRight;
                consumed = true;
            }
        }

        if (consumed) return true;
        else revert('denied : no registry record right found for provided address');
    }

}

// File: contracts/Etherland.sol

/**
 * @title Etherland
 * @dev ERC-20 Compliant ELAND token
 * @author Mathieu Lecoq
 * december 20th 2020 
 *
 * @dev Property
 * all rights are reserved to Etherland ltd
 *
 * @dev deployed with solc 0.7.5
*/
contract Etherland is LandRegistry, Proxiable {
    using SafeMath for uint256;

    /**
    * @return amount representing _percent % of _amount
    */
    function percentOf(uint _total, uint _percent) internal pure returns(uint amount) {
        amount = ((_total * _percent) / 100);
    }

    /**
    * @dev Erc20 Etherland ELAND token constructor
    * @param _owner address of the contract owner to set when migrating this contract
    * @notice called only once in contract lifetime upon migration to chain
    */
    function init(
        string memory name_, 
        string memory symbol_, 
        uint8 decimals_, 
        address _owner, 
        address _reserve, 
        address _team
    ) public {
      
        if (initialized != true) {
            /* 
                initialize contract 
            */
            initialized = true;
            
            /* 
                give ownership of the contract to _owner 
            */
            _transferOwnership(_owner);

            /* 
                define maximum supply to 1 Billion tokens
            */
            uint maximumSupply = 1e9 * 10 ** decimals_;

            /* 
                definitively end minting of ELAND token by setting cap supply to maximum supply of 1 Billion.
                total and circulating supply will never ever be higher than the cap 
            */
            setImmutableCap(maximumSupply);
            
            /* 
                set contract identifiers 
            */
            _name = name_;
            _symbol = symbol_;
            _decimals = decimals_;
            
            /*
                set wallets for partionning
            */
            team = _team;
            reserve = _reserve;
            
            /* 
                partition the supply 
                    - 20 percent of the supply goes to the reserve wallet
                    - 10 percent of the supply goes to the team wallet
                    - 70 percent of the supply are kept by the owner
            */
            mint(_reserve, percentOf(maximumSupply, 20));
            mint(_team, percentOf(maximumSupply, 10));
            mint(_owner, percentOf(maximumSupply, 70));

            _mintingFinished = true;
            
        }
    }

    /**
    * @dev EIP-1822 feature
    * @dev Realize an update of the Etherland logic code 
    * @dev calls the proxy contract to update stored logic code contract address at keccak256("PROXIABLE")
    * @notice once owner renounce contract ownership and owner address is set to the zero address, 
    *         no one will be able to update the logic code (see renounceOwnership method)
    */
    function updateCode(address newCode) public onlyOwner {
        updateCodeAddress(newCode);
    }
    
    /**
    * @dev Total circulating supply
    * @return the number of circulating ELAND (totalSupply - team - reserve - owner)
    */
    function circulatingSupply() public view returns(uint) {
        return (totalSupply().sub(balanceOf(team)).sub(balanceOf(reserve)).sub(balanceOf(owner)));
    }

   /**
    * @dev Transfer ELAND value to multiple addresses
    * @param _to array of addresses to send value to
    * @param _value the ELAND value to transfer for each address
    * @return boolean indicating operation success
    */
    function batchTransfer(address[] memory _to, uint _value) public returns(bool) {
        uint ttlRecipients = _to.length;
        require(ttlRecipients > 0, 'at least on recipient must be defined');
        require(balanceOf(_msgSender()) >= (_value.mul(ttlRecipients)), 'batch transfer denied : unsufficient balance');
        for (uint i = 0; i < ttlRecipients; i++) {
            address recipient = _to[i];
            transfer(recipient, _value);
        }
        return true;
    }

    /**
    * @dev Set Etherland LANDID NFT contract address
    * @param _landidNftAddress the address of LANDID NFT Token
    * @return boolean indicating operation success
    */
    function setLandidNftAddress(address _landidNftAddress) public onlyOwner returns (bool) {
        landidNftAddress = _landidNftAddress;
        return true;
    }

    /**
    * @dev Set Land Registration Address
    * @param _landRegistration the address of the wallet dedicated to land registrations
    * @return boolean indicating operation success
    */
    function setLandRegistrationAddress(address _landRegistration) public onlyOwner returns(bool) {
        landRegistration = _landRegistration;
        return true;
    }
    

}