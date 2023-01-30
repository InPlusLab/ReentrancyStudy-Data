/**
 *Submitted for verification at Etherscan.io on 2020-12-20
*/

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





pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}





pragma solidity ^0.6.2;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}



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
}



// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.6.0;





contract GoaldProxy is ERC20 {
    /** 
     * @dev The minimum amount of tokens necessary to be eligible for a dividend. This is "one token", considering decimal places. We
     * are choosing six decimal places because we are targeting WBTC, which has 8. This way we can do a minimum dividend ratio of
     * 1 / 100 of a WBTC, relative to our token. So at $25,000 (2020 value), the minimum dividend would be $250.
     */
    uint256 private constant DIVIDEND_THRESHOLD = 10**6;

    /** @dev The current owner of the proxy. */
    address public _owner = msg.sender;

    /** @dev Which Uniswap router we're currently using for trades. */
    address public _uniswapRouterAddress;

    /** @dev The latest proxy address. This is private since Goald contracts use `getProxyAddress()` to determine the address. */
    address private _proxyAddress = msg.sender;

    /** @dev Which deployer is the most recent version. Only the latest version can create new Goald. See: `_proxyAddress`. */
    address private _latestDeployer;

    /** @dev Which ERC20 contract will be used for dividends (e.g., WBTC). */
    address _dividendContract;

    /** @dev How many holders are eligible for dividends. This is used to determine how much should be reserved. */
    uint256 private _dividendHolders;

    /** @dev How much of the current balance is reserved for dividends. */
    uint256 _reservedBalance;

    /** @dev How many holders have yet to withdraw a given dividend. */
    uint256[] _dividendHolderCounts;

    /** @dev The multipliers for each dividend. */
    uint256[] _dividendMultipliers;

    /** @dev The remaining reserves for a given dividend. */
    uint256[] _dividendReserves;

    /** @dev The minimum dividend index to check eligibility against for a given address. */
    mapping (address => uint256) _minimumDividendIndex;
    
    /** @dev The available dividend balance for a given address. */
    mapping (address => uint256) _dividendBalance;

    /**
     * @dev The stage of the governance token. Tokens can be issued based on deployments regardless of what stage we are in.
     *      0: Created, with no governance protocol initiated. The initial governance issuance can be claimed.
     *      1: Initial governance issuance has been claimed.
     *      2: The governance protocal has been initiated.
     *      3: All governance tokens have been issued.
     */
    uint256 private constant STAGE_INITIAL               = 0;
    uint256 private constant STAGE_ISSUANCE_CLAIMED      = 1;
    uint256 private constant STAGE_DAO_INITIATED         = 2;
    uint256 private constant STAGE_ALL_GOVERNANCE_ISSUED = 3;
    uint256 private _governanceStage;
    uint256 private _goaldsDeployed;

    // Reentrancy reversions are the only calls to revert (in this contract) that do not have reasons. We add a third state, 'frozen'
    // to allow for locking non-admin functions. The contract may be permanently frozen if it has been upgraded.
    uint256 private constant RE_NOT_ENTERED = 1;
    uint256 private constant RE_ENTERED     = 2;
    uint256 private constant RE_FROZEN      = 3;
    uint256 private _status;

    // Override decimal places to 6. See `DIVIDEND_THRESHOLD`.
    constructor() ERC20("Goald", "GOALD") public {
        _setupDecimals(6);
    }

    /// Events ///

    event DividendCreated(uint256 multiplier, string reason);

    /// Admin Functions ///

    function changeOwner(address newOwner) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");
        require(newOwner != address(0), "Can't be zero address");

        _owner = newOwner;
    }

    /**
     * Sets the latest deployer. No other Goald deployers can create a new Goald. We do not restrict the address since we need to be
     * able to freeze deployments in the event of a severe vulnerability.
     */
    function changeLatestDeployer(address newDeployer) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");

        _latestDeployer = newDeployer;
    }

    /** The proxy address is what the Goald deployers send their fees to. */
    function changeProxyAddress(address newAddress) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");
        require(newAddress != address(0), "Can't be zero address");

        _proxyAddress = newAddress;
    }

    /** The uniswap router for converting tokens within this proxys. */
    function changeUniswapRouterAddress(address newAddress) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");
        require(newAddress != address(0), "Can't be zero address");

        _uniswapRouterAddress = newAddress;
    }

    /** Freezes the proxy contract. Only admin functions can be called. */
    function freeze() external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _owner, "Not owner");

        _status = RE_FROZEN;
    }

    /** Unfreezes the proxy contract. Non-admin functions can again be called. */
    function unfreeze() external {
        // Reentrancy guard.
        require(_status == RE_FROZEN);
        require(msg.sender == _owner, "Not owner");

        _status = RE_NOT_ENTERED;
    }

    /// Goald Deployers ///

    /** Returns the current address that fees will be sent to. */
    function getProxyAddress() external view returns (address) {
        return _proxyAddress;
    }

    /** Returns the address of the deployer that is allowed to create new Goald. */
    function getLatestDeployerAddress() external view returns (address) {
        return _latestDeployer;
    }

    /** Returns the address of the uniswap router. */
    function getUniswapRouterAddress() external view returns (address) {
        return _uniswapRouterAddress;
    }

    /**
     * Called when a deployer deploys a new Goald. Currently we use this to distribute the governance token according to the
     * following schedule. An additional 11,000 tokens will be given to the deployer of this proxy. This will create a total supply of
     * 21,000 tokens. Once the governance protocal is set up, 10,000 tokens will be burned to initiate that mechanism. That will leave
     * ~9% ownership for the deployer of the contract, with the remaining 91% given to the community. No dividends can be paid out
     * before the governance protocal has been initiated.
     *
     *      # Goalds    # Tokens
     *       0 -  9       100
     *      10 - 19        90
     *      20 - 29        80
     *      30 - 39        70
     *      40 - 49        60
     *      50 - 59        50
     *      60 - 69        40
     *      70 - 79        30
     *      80 - 89        20
     *      90 - 99        10
     *       < 4600         1
     */
    function notifyGoaldCreated(address creator) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _latestDeployer, "Not latest deployer");

        // All governance tokens have been issued.
        if (_governanceStage == STAGE_ALL_GOVERNANCE_ISSUED) {
            _goaldsDeployed++;
            return;
        }

        // Calculate the amount of tokens issued based on the schedule.
        uint256 goaldsDeployed = _goaldsDeployed;
        uint256 amount;
        if        (goaldsDeployed <   10) {
            amount = 100;
        } else if (goaldsDeployed <   20) {
            amount =  90;
        } else if (goaldsDeployed <   30) {
            amount =  80;
        } else if (goaldsDeployed <   40) {
            amount =  70;
        } else if (goaldsDeployed <   50) {
            amount =  60;
        } else if (goaldsDeployed <   60) {
            amount =  50;
        } else if (goaldsDeployed <   70) {
            amount =  40;
        } else if (goaldsDeployed <   80) {
            amount =  30;
        } else if (goaldsDeployed <   90) {
            amount =  20;
        } else if (goaldsDeployed <  100) {
            amount =  10;
        } else if (goaldsDeployed < 4600) {
            amount =   1;
        }

        if (amount > 0) {
            // Update their dividend balance.
            _checkDividend(creator);

            // We are creating a new holder.
            if (balanceOf(creator) < DIVIDEND_THRESHOLD) {
                _dividendHolders ++;
            }

            // Give them the tokens.
            _mint(creator, amount * DIVIDEND_THRESHOLD);
        }

        // We are fully done.
        if (goaldsDeployed >= 4600 && _governanceStage == STAGE_DAO_INITIATED) {
            _governanceStage = STAGE_ALL_GOVERNANCE_ISSUED;
        }

        // Update the count.
        _goaldsDeployed = goaldsDeployed + 1;
    }

    /// Governance ///

    /** Changes which token will be the dividend token. This can only happen if there is no balance in reserve held for dividends. */
    function changeDividendContract(address newContract) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,                    "Not owner");
        require(newContract != address(0),               "Can't be zero address");
        require(newContract != address(this),            "Can't be this address");
        require(_governanceStage >= STAGE_DAO_INITIATED, "DAO not initiated");
        require(_reservedBalance == 0,                   "Have reserved balance");

        _dividendContract = newContract;
    }

    function claimIssuance() external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED || _status == RE_FROZEN);
        require(msg.sender == _owner,              "Not owner");
        require(_governanceStage == STAGE_INITIAL, "Already claimed");

        _mint(_owner, 11000 * DIVIDEND_THRESHOLD);

        _governanceStage = STAGE_ISSUANCE_CLAIMED;
    }

    /** Uses Uniswap to convert all held amount of a specific token into the dividend token, using the provided path. */
    function convertToken(address[] calldata path, uint256 deadline) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        require(msg.sender == _owner,                    "Not owner");
        require(_governanceStage >= STAGE_DAO_INITIATED, "DAO not initiated");
            
        // Make sure this contract actually has a balance.
        IERC20 tokenContract = IERC20(path[0]);
        uint256 amount = tokenContract.balanceOf(address(this));
        require(amount > 0, "No balance for token");

        // Swap the tokens.
        tokenContract.approve(_uniswapRouterAddress, amount);
        IUniswapV2Router02(_uniswapRouterAddress).swapExactTokensForTokens(amount, 1, path, address(this), deadline);

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;
    }

    /** Uses Uniswap to convert all held amount of specific tokens into the dividend token. The tokens must have a direct path. */
    function convertTokens(address[] calldata tokenAddresses, uint256 deadline) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        require(msg.sender == _owner, "Not owner");
        require(_governanceStage >= STAGE_DAO_INITIATED, "DAO not initiated");

        // The path between a given token and the dividend token within Uniswap.
        address[] memory path;
        path[1] = _dividendContract;
        IUniswapV2Router02 uniswap = IUniswapV2Router02(_uniswapRouterAddress);

        address tokenAddress;
        IERC20 tokenContract;
        
        uint256 amount;
        uint256 count = tokenAddresses.length;
        for (uint256 i; i < count; i ++) {
            // Validate the token.
            tokenAddress = tokenAddresses[i];
            require(tokenAddress != address(0),        "Can't be zero address");
            require(tokenAddress != address(this),     "Can't be this address");
            require(tokenAddress != _dividendContract, "Can't be target address");
            
            // Make sure this contract actually has a balance.
            tokenContract = IERC20(tokenAddress);
            amount = tokenContract.balanceOf(address(this));
            if (amount == 0) {
                continue;
            }

            // Swap the tokens.
            tokenContract.approve(_uniswapRouterAddress, amount);
            path[0] = tokenAddress;
            uniswap.swapExactTokensForTokens(amount, 1, path, address(this), deadline);
        }

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;
    }

    function initializeDAO() external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        require(msg.sender == _owner,                       "Not owner");
        require(_governanceStage == STAGE_ISSUANCE_CLAIMED, "Issuance unclaimed");

        _burn(_owner, 10000 * DIVIDEND_THRESHOLD);

        _governanceStage = STAGE_DAO_INITIATED;
    }

    /// Dividends ///

    /** Check which dividends a given address is eligible for, and update their current dividend balance to reflect that total. */
    function _checkDividend(address holder) internal {
        // There is no need for reentrancy since this only updates the `_dividendBalance` for a given holder according to the amounts
        // they are already owed according to the current state. If this is an unexpected reentrant call, then that holder gets the
        // benefit of this math without having to pay the gas.

        // The total number of dividends issued.
        uint256 count = _dividendMultipliers.length;

        // The holder has already claimed all dividends.
        uint256 currentMinimumIndex = _minimumDividendIndex[holder];
        if (currentMinimumIndex == count) {
            return;
        }

        // The holder is not eligible for a dividend according to their current balance.
        uint256 balance = balanceOf(holder);
        if (balance < DIVIDEND_THRESHOLD) {
            // Mark that they have been checked for all dividends.
            if (currentMinimumIndex < count) {
                _minimumDividendIndex[holder] = count;
            }

            return;
        }

        // Calculate the balance increase according to which dividends the holder has yet to claim. Also calculate the amount of the
        // reserve should be released if a given dividend has been fully collected by all holders.
        uint256 multiplier;
        uint256 reserveDecrease;
        for (; currentMinimumIndex < count; currentMinimumIndex ++) {
            // This can never overflow since a dividend can't be created unless there is enough reserve balance to cover its
            // multiplier, which already checks for overflows, likewise `multiplier * balance` can never overflow.
            multiplier += _dividendMultipliers[currentMinimumIndex];

            // Reduce the holder count and reserve for this dividend. If this is the last holder, we refund the remainder of the held
            // reserve back to the main pool. We don't need to worry about underflows here because these values never increase. They
            // are set once when the dividend is created, based on the total supply of the governance token at that time.
            if (_dividendHolderCounts[currentMinimumIndex] == 1) {
                reserveDecrease += _dividendReserves[currentMinimumIndex] - (multiplier * balance);
                _dividendHolderCounts[currentMinimumIndex] = 0;
                _dividendReserves[currentMinimumIndex] = 0;
            } else {
                _dividendHolderCounts[currentMinimumIndex]--;
                _dividendReserves[currentMinimumIndex] -= multiplier * balance;
            }
        }
        _minimumDividendIndex[holder] = count;

        // Update the balance.
        uint256 currentBalance = _dividendBalance[holder];
        require(currentBalance + (multiplier * balance) > currentBalance, "Balance overflow");
        _dividendBalance[holder] = currentBalance + (multiplier * balance);   

        // Update the reserve balance.
        if (reserveDecrease > 0) {
            _reservedBalance -= reserveDecrease;
        }
    }

    /**
     * Creates a new dividend. Dividends are only paid out to holders who have at least "one token" at time of creation. The dividend
     * is a multiplier, representing how many dividend tokens (e.g., WBTC) should be paid out for one governance token. Dividend
     * eligibility is only updated in state in two cases:
     *      1) When a dividend is being withdrawn (in which it is set to zero).
     *      2) When the governance token is transferred (balances are checked before the transfer, on both sender and recipient).
     */
    function createDividend(uint256 multiplier, string calldata reason) external {
        // Reentrancy guard.
        require(_status == RE_NOT_ENTERED);
        _status = RE_ENTERED;
        require(msg.sender == _owner,                    "Not owner");
        require(_governanceStage >= STAGE_DAO_INITIATED, "DAO not initiated");
        require(multiplier > 0,                          "Multiplier must be > 0");

        // Make sure we can actually create a dividend with that amount.
        uint256 currentBalance = IERC20(_dividendContract).balanceOf(address(this)) - _reservedBalance;
        uint256 holders = _dividendHolders;
        uint256 reserveIncrease = totalSupply() * multiplier;
        require(reserveIncrease > currentBalance, "Multiplier too large");

        // Increase the reserve.
        require(_reservedBalance + reserveIncrease > _reservedBalance, "Reserved overflow error");
        _reservedBalance += reserveIncrease;

        // Keep track of the holders, reserve, and multiplier for this dividend.
        _dividendHolderCounts.push(holders);
        _dividendMultipliers.push(multiplier);
        _dividendReserves.push(reserveIncrease);

        // Hello world!
        emit DividendCreated(multiplier, reason);

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;
    }

    /**
     * Withdraws the current dividend balance. The sender doesn't need to have any current balance of the governance token to
     * withdraw, so long as they have a preexisting outstanding balance. This has a provided recipient so that we can drain the
     * dividend pool as necessary (e.g., for changing the dividend token).
     */
    function withdrawDividend(address recipient) external {
        // Reentrancy guard. Allow owner to drain the pool even if frozen.
        require(_status == RE_NOT_ENTERED || (_status == RE_FROZEN && msg.sender == _owner));
        _status = RE_ENTERED;

        // Update their balance.
        _checkDividend(recipient);

        // Revert so gas estimators will show a failure.
        uint256 balance = _dividendBalance[recipient];
        require(balance > 0, "No dividend balance");

        // Wipe the balance.
        _dividendBalance[recipient] = 0;
        require(_reservedBalance - balance > 0, "Reserved balance underflow");
        _reservedBalance -= balance;

        // Give them their balance.
        IERC20(_dividendContract).transfer(recipient, balance);

        // By storing the original amount once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = RE_NOT_ENTERED;
    }

    /// ERC20 Overrides ///

    /** This is overridden so we can update the dividend balancees prior to the transfer completing. */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        // Update the dividend balances prior to the transfer for both sender and receiver.
        _checkDividend(msg.sender);
        _checkDividend(recipient);

        // Preserve the original balances so we know if we need to change `_dividendHolders`.
        uint256 senderBefore = balanceOf(msg.sender);
        uint256 recipientBefore = balanceOf(recipient);

        super.transfer(recipient, amount);

        // See if we need to change `_dividendHolders`.
        uint256 senderAfter = balanceOf(msg.sender);
        if (senderAfter >= DIVIDEND_THRESHOLD && senderBefore < DIVIDEND_THRESHOLD) {
            _dividendHolders ++;
        } else if (senderAfter < DIVIDEND_THRESHOLD && senderBefore >= DIVIDEND_THRESHOLD) {
            _dividendHolders --;
        }
        uint256 recipientAfter = balanceOf(recipient);
        if (recipientAfter >= DIVIDEND_THRESHOLD && recipientBefore < DIVIDEND_THRESHOLD) {
            _dividendHolders ++;
        } else if (recipientAfter < DIVIDEND_THRESHOLD && recipientBefore >= DIVIDEND_THRESHOLD) {
            _dividendHolders --;
        }

        return true;
    }

    /** This is overridden so we can update the dividend balancees prior to the transfer completing. */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        // Update the dividend balances prior to the transfer for both sender and receiver.
        _checkDividend(sender);
        _checkDividend(recipient);

        // Preserve the original balances so we know if we need to change `_dividendHolders`.
        uint256 senderBefore = balanceOf(sender);
        uint256 recipientBefore = balanceOf(recipient);

        super.transferFrom(sender, recipient, amount);

        // See if we need to change `_dividendHolders`.
        uint256 senderAfter = balanceOf(sender);
        if (senderAfter >= DIVIDEND_THRESHOLD && senderBefore < DIVIDEND_THRESHOLD) {
            _dividendHolders ++;
        } else if (senderAfter < DIVIDEND_THRESHOLD && senderBefore >= DIVIDEND_THRESHOLD) {
            _dividendHolders --;
        }
        uint256 recipientAfter = balanceOf(recipient);
        if (recipientAfter >= DIVIDEND_THRESHOLD && recipientBefore < DIVIDEND_THRESHOLD) {
            _dividendHolders ++;
        } else if (recipientAfter < DIVIDEND_THRESHOLD && recipientBefore >= DIVIDEND_THRESHOLD) {
            _dividendHolders --;
        }

        return true;
    }
}