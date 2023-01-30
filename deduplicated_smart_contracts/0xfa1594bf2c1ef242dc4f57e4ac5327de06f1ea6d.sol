/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

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

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.6.0;

/** A homogeneous, unrestricted, unmanaged vault that targets ERC-721 conforming contracts. */
contract VaultOUU is ERC20, IERC721Receiver {
    // The address of the user that is wrapping / unwrapping tokens. This will not be persisted, to reduce gas usage.
    address _depositor;

    // The contract we are wrapping around.
    address public _coreAddress;
    IERC721 private _coreContract;

    // The amount of mintable / burnable ERC-20 tokens for each action.
    uint256 private _baseWrappedAmount;

    // The tokens stored in the vault.
    uint256[] private _tokenIds;

    // The mapping of token ids to their index, 1-based.
    mapping(uint256 => uint256) private _indices;

    // We include this here instead of the `nonReentrant` modifier to reduce gas costs. See OpenZeppelin - ReentrancyGuard for more.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

	constructor () ERC20("NFTWrapper Vault - Avastar", "WAVASTAR") public {
        // Set the token ratio, defaulting to 10^18.
        _baseWrappedAmount = uint256(10) ** decimals();

        // These cannot be changed once the vault is created.
        _coreAddress = 0xF3E778F839934fC819cFA1040AabaCeCBA01e049;
        _coreContract = IERC721(_coreAddress);

        // Set us up for reentrancy guarding.
        _status = _NOT_ENTERED;
    }

    /// Events ///

    /** Fired when a token is deposited. */
    event TokenDeposited(uint256 tokenId);

    /** Fired when a token is withdrawn. */
    event TokenWithdrawn(uint256 tokenId);

    /// Status ///

    /** Check if a token can be withdrawn by its id. */
    function canWithdrawToken(uint256 tokenId) external view returns (bool) {
        return _indices[tokenId] != 0;
    }

    function size() external view returns (uint256) {
        return _tokenIds.length;
    }

    /// ERC-721 ///

    /**
     * Called when an ERC-721 compliant contract is targeting this contract as the receiver in a `safeTransferFrom()` call. This
     * checks to make sure we are expecting a token to be transferred. This should only be called as a result of `deposit()` or
     * `swapParityToken()`.
     *
     * @param operator Who (from the perspective of the ERC-721 contract) called `safeTransferFrom()`. This must always be this Vault.
     * @param from Who is the owner of the ERC-721 token.
     * @dev Unused parameter: tokenId - The id of the token being transferred.
     * @dev Unused parameter: data - Optional data sent from the ERC-721 contract.
     */
    function onERC721Received(address operator, address from, uint256, bytes calldata) override external returns (bytes4) {
        // We must be in the middle of a deposit. If this function is called as a side-effect of a withdrawal / parity swap, this will
        // have a false-negative. However, that is only the case if the underlying contract is not valid / malicious.
        require(_status == _ENTERED, "Reentrancy: non-reentrant call");

        require(operator == address(this), "Cannot call directly");
        require(from != address(0), "Zero address not allowed");
        require(from == _depositor, "Depositor mismatch");
        require(msg.sender == _coreAddress, "Token not allowed in vault");

        // Accept this transfer.
        return IERC721Receiver.onERC721Received.selector;
    }

    /// Vault Parity ///

    /** This is called by `swapParityToken()` to ensure the targeted vault can accept specific ERC-721 tokens. */
    function acceptsTokenContract(address contractAddress) external view returns (bool) {
        return _coreAddress == contractAddress;
    }

    function getBaseWrappedAmount() external view returns (uint256) {
        return _baseWrappedAmount;
    }

    /**
     * This allows users to trade the parity tokens of two vaults that target the same contract. This gives all tokens parity with
     * each other, so long as they're targeting the same vault. There are two vaults: the originator and the destination. Restricted
     * vaults cannot be the destination unless this vault is whitelisted as an allowed depositor.
     *
     * There is a potential issue if the destination contract is malicious. If that contract allows deposits and does not allow
     * withdrawals, then the user's parity token is now worthless. As with all transactions, care must be taken that the target
     * contract is what you think it is.
     *
     * @param destination The address of the Vault contract that will receive any swapped ERC-721 tokens, while issuing its own ERC-20
     *      tokens as appropriate.
     * @param count The number of ERC-721 tokens to swap. This can't be larger than the vault size, but the call will not revert if
     *     that's the case.
     */
    function swapParityToken(address destination, uint256 count) external {
        // Reentrancy guard.
        require(_status != _ENTERED, "Reentrancy: reentrant call");
        _status = _ENTERED;

        // Validate the destination address.
        require(destination != address(0), "Zero address not allowed");
        require(destination != address(this), "Vault contract not allowed");
        require(destination != _coreAddress, "Token contract not allowed");
        require(destination != msg.sender, "Target cannot be you");

        // Make sure it's a fully constructed contract. See OpenZeppelin.utils.Address for complete list of caveats.
        uint256 codeSize;
        assembly { codeSize := extcodesize(destination) }
        require(codeSize > 0, "Target not a contract");
        
        // Make sure the vault contract matches. There is already a certain amount of trust required when choosing the targeted vault,
        // so indirect comparison isn't a dealbreaker. It also allows for swaps with vaults of dissimilar heterogeneity.
        VaultOUU destinationContract = VaultOUU(destination);
        require(destinationContract.acceptsTokenContract(_coreAddress), "Target refuses tokens");

        // We don't want to keep reading the length from storage.
        uint256 _length = _tokenIds.length;

        // Make sure we have at least one to swap.
        if (count > _length) {
            count = _length;
        }
        require(count > 0, "No tokens to swap");

        // We burn here so the user doesn't spend gas unnecessarily if they can't afford the swap.
        _burn(msg.sender, count * _baseWrappedAmount);

        // Remove the last X tokens from the vault.
        uint256 tokenId;
        uint256[] memory tokens = new uint256[](count);
        uint256 i;
        for (i; i < count; i ++) {
            tokenId = _tokenIds[--_length];
            tokens[i] = tokenId;
            _tokenIds.pop();
            _indices[tokenId] = 0;

            // Approve the target contract so it can withdraw the token. We do not blindly send.
            _coreContract.approve(destination, tokenId);
        }

        // We will be checking to make sure that the new tokens are minted (as far as we can), so get the starting value.
        uint256 startingBalance = destinationContract.balanceOf(msg.sender);

        // Deposit all the tokens in the target contract.
        destinationContract.deposit(msg.sender, tokens);

        // Verify that the target contract now owns all the tokens.
        for (i = 0; i < count; i ++) {
            require(_coreContract.ownerOf(tokens[i]) == destination, "Token not transferred");
        }

        // Verify the ending token count. If the destination vault is faulty / malicious then this will fail. Even if this passes,
        // this isn't a guarantee that the exchanged tokens can be used to withdraw from the target vault. That is up to the user to
        // check before initiating a parity swap. A valid implementation of `getBaseWrappedAmount()` is required as well.
        uint256 endingBalance = destinationContract.balanceOf(msg.sender);
        require(endingBalance > startingBalance, "Parity token did not increase");
        require(startingBalance + (count * destinationContract.getBaseWrappedAmount()) == endingBalance, "Parity token mismatch");

        // At this point we've guaranteed that:
        //  - The destination contract is a vault for the same core contract (or is pretending to be).
        //  - The tokens are no longer stored in this vault.
        //  - The destination contract is the owner of the transferred tokens.
        //  - The user has the correct amount of parity tokens, both of this vault's and the target vault's.
        //
        // So long as the destination contract is able to receive tokens in this way, then it doesn't matter who created the vault,
        // or how its features differ from this vault's.

        // By storing the original value once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = _NOT_ENTERED;
    }

    /// Vault ///

    /**
     * Deposit any number of tokens into the vault, receiving ERC-20 wrapped tokens in response. Users can deposit tokens on behalf
     * of a third party (the one who would receive the parity tokens), so long as they are the owners of the token.
     *
     * @param depositor Who will be receiving the ERC-20 parity tokens.
     * @param tokenIds The ids of the tokens that will be deposited. All tokens must be approved for transfer first.
     */
    function deposit(address depositor, uint256[] calldata tokenIds) external {
        // Reentrancy guard.
        require(_status != _ENTERED, "Reentrancy: reentrant call");
        _status = _ENTERED;

        // We need to know who will be receiving the parity tokens.
        require(depositor != address(0), "Zero address not allowed");
        require(depositor != address(this), "This address not allowed");
        require(depositor != _coreAddress, "Token contract not allowed");

        // We don't want to keep reading the length from storage.
        uint256 _length = _tokenIds.length;

        // We can't allow overflows, but we're not going to get fancier than this. Not like anyone has that much memory anyway.
        uint256 count = tokenIds.length;
        require(count > 0, "No tokens to deposit");
        require(_length + count > _length, "Vault full");

        // Preserve the user so we know who to receive tokens from.
        _depositor = msg.sender;

        // Try and deposit everything.
        uint256 tokenId;
        for (uint256 i; i < count; i ++) {
            // Store it in the vault.
            tokenId = tokenIds[i];
            _tokenIds.push(tokenId);
            _indices[tokenId] = ++_length;

            // Attempt to transfer the token. If the sender hasn't approved this contract for this specific token then it will fail.
            // We have to check for ownership here to prevent a third party from forcing a deposit. If this vault already owns the
            // token then this will also fail. This way we can avoid a self-check on existence (since it's not a guaranteed O(1)).
            require(_coreContract.ownerOf(tokenId) == msg.sender, "You are not the owner");
            _coreContract.safeTransferFrom(msg.sender, address(this), tokenId);
        
            // Hello world!
            emit TokenDeposited(tokenId);
        }

        // Give them the wrapped ERC-20 token.
        _mint(depositor, count * _baseWrappedAmount);

        // By storing the original value once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _depositor = address(0);
        _status = _NOT_ENTERED;
    }

    /**
     * Withdraw any number of tokens from the vault.
     *
     * @param destination Who will receive the ERC-721 tokens.
     * @param count How many tokens to withdraw.
     */
    function withdrawAny(address destination, uint256 count) external {
        // Reentrancy guard.
        require(_status != _ENTERED, "Reentrancy: reentrant call");
        _status = _ENTERED;

        // Validate the destination address.
        require(destination != address(0), "Zero address not allowed");
        require(destination != address(this), "Vault address not allowed");
        require(destination != _coreAddress, "Token contract not allowed");

        // We don't want to keep reading the length from storage.
        uint256 _length = _tokenIds.length;

        // They can only withdraw as many tokens as there are stored.
        if (count > _length) {
            count = _length;
        }
        require(count > 0, "No tokens to withdraw");

        // We burn here so the user doesn't spend gas unnecessarily if they can't afford the withdrawal.
        _burn(msg.sender, count * _baseWrappedAmount);

        // We remove from the tail so we don't need to shift anything.
        uint256 tokenId;
        for (uint256 i; i < count; i ++) {
            // Remove it from the vault.
            tokenId = _tokenIds[--_length];
            _tokenIds.pop();
            _indices[tokenId] = 0;

            // Attempt to transfer the token.
            _coreContract.safeTransferFrom(address(this), destination, tokenId);
        
            // Hello world!
            emit TokenWithdrawn(tokenId);
        }

        // By storing the original value once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * Attempts to withdraw the tokens with the specified ids.
     *
     * @param destination Who will receive the ERC-721 tokens.
     * @param tokenIds The ids of the tokens that will be withdrawn. Only the stored tokens will be withdrawn.
     */
    function withdrawTokens(address destination, uint256[] calldata tokenIds) external {
        // Reentrancy guard.
        require(_status != _ENTERED, "Reentrancy: reentrant call");
        _status = _ENTERED;

        // Validate the destination address.
        require(destination != address(0), "Zero address not allowed");
        require(destination != address(this), "Vault address not allowed");
        require(destination != _coreAddress, "Token contract not allowed");

        // We don't want to keep reading the length from storage.
        uint256 _length = _tokenIds.length;
        require(_length > 0, "No tokens to withdraw");

        // We don't want to revert if this vault doesn't contain some of the tokens, so we are checking for existence and only
        // transferring those that this vault owns. Because of this, we can't burn the parity token up front since there's no way to
        // know how many will actually be transferred.
        uint256 count = tokenIds.length;
        uint256 index;
        uint256 tokenId;
        uint256 tailTokenId;
        uint256 withdrawnCount;
        for (uint256 i; i < count; i ++) {
            // If we can't find it, we'll skip it. Index is off by 1 so that 0 = nonexistent.
            tokenId = tokenIds[i];
            index = _indices[tokenId];
            if (index != 0 && _tokenIds[index - 1] == tokenId) {
                // Swap and pop.
                tailTokenId = _tokenIds[--_length];
                _tokenIds[index - 1] == tailTokenId;
                _tokenIds.pop();
                _indices[tailTokenId] = index;
                _indices[tokenId] = 0;

                // Attempt to transfer the token.
                _coreContract.safeTransferFrom(address(this), destination, tokenId);

                withdrawnCount++;
            
                // Hello world!
                emit TokenWithdrawn(tokenId);
            }
        }

        // Take the wrapped ERC-20 tokens.
        _burn(msg.sender, withdrawnCount * _baseWrappedAmount);

        // By storing the original value once again, a refund is triggered (see https://eips.ethereum.org/EIPS/eip-2200).
        _status = _NOT_ENTERED;
    }
}