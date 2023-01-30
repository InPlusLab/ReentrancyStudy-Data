/**
 *Submitted for verification at Etherscan.io on 2020-07-16
*/

// File: @openzeppelin/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

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

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


pragma solidity ^0.6.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


pragma solidity ^0.6.0;

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

// File: contracts/ERC721Holder.sol


pragma solidity ^0.6.8;



contract ERC721Holder is IERC721Receiver {

    // Equal to: bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")).
    bytes4 internal constant NEW_ERC721_RECEIVED = 0x150b7a02;

    // Equal to: bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
    bytes4 internal constant OLD_ERC721_RECEIVED = 0xf0b9e5ba;

    /**
     * @dev implements old onERC721Received interface
     */
    function onERC721Received(address, uint256, bytes memory) public pure returns (bytes4) {
        return OLD_ERC721_RECEIVED;
    }

    /**
     * @dev The ERC721 smart contract calls this function on the recipient
     *  after a {IERC721-safeTransferFrom}.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    )
        public virtual override returns (bytes4)
    {
        return NEW_ERC721_RECEIVED;
    }
}

// File: contracts/ConverterManager.sol


pragma solidity ^0.6.8;



contract ConverterManager is Ownable {

    event SetConverter(address indexed converter);

    // configured fee converter
    address public converterAddress;

    /**
     * @param _converter address of collected fees burner implementation
     */
    function setConverter(address _converter) public virtual onlyOwner {
        converterAddress = _converter;
        emit SetConverter(_converter);
    }
}

// File: @openzeppelin/contracts/introspection/IERC165.sol


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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


pragma solidity ^0.6.2;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transfered from `from` to `to`.
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

// File: contracts/ITransferableRegistry.sol


pragma solidity ^0.6.8;


interface ITransferableRegistry is IERC721 {
    function transfer(address _to, uint256 _tokenId) external;
}

// File: contracts/dex/IConverter.sol


pragma solidity ^0.6.8;



interface IConverter {
    function getTrader() external view returns (address);
    function calcNeededTokensForEther(IERC20 _dstToken, uint256 _etherAmount) external view returns (uint256);
    function swapEtherToToken(IERC20 _dstToken) external payable returns (uint256);
    function swapTokenToEther(IERC20 _srcToken, uint256 _srcAmount, uint256 _maxDstAmount)
        external returns (uint256 dstAmount, uint256 srcRemainder);
}

// File: contracts/BuyAdapter.sol


pragma solidity ^0.6.8;










contract BuyAdapter is
    Ownable,
    ReentrancyGuard,
    ERC721Holder,
    ConverterManager
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event ExecutedOrder(
        address indexed registry,
        uint256 indexed tokenId,
        address indexed marketplace,
        uint256 orderValue,
        uint256 orderFees
    );

    event ExecutedOrder(
        address indexed marketplace,
        uint256 orderValue,
        uint256 orderFees,
        bytes marketplaceData
    );

    event MarketplaceAllowance(address indexed marketplace, bool value);
    event FeesCollectorChange(address indexed collector);
    event AdapterFeeChange(uint256 previousFee, uint256 newFee);

    // Allowed tranfer type enum
    enum TransferType { safeTransferFrom, transferFrom, transfer }

    // Order execution fee in a 0 - 1000000 basis
    uint256 public adapterTransactionFee;

    // Max allowed fee for the adapter
    uint256 public constant ADAPTER_FEE_MAX = 150000; // 15%
    uint256 public constant ADAPTER_FEE_PRECISION = 1000000;

    // MarketFeesCollector address
    address payable public adapterFeesCollector;

    /**
     * @dev constructor
     * @param _converter address for the IConverter
     * @param _collector address for the Fee Collector contract
     * @param _adapderFee initial adapter fee
     */
    constructor(
        address _converter,
        address payable _collector,
        uint256 _adapderFee
    )
        Ownable() public
    {
        setConverter(_converter);
        setFeesCollector(_collector);

        setAdapterFee(_adapderFee);
    }

    /**
     * @dev Sets fees collector for the adapter
     * @param _collector Address for the fees collector
     */
    function setFeesCollector(address payable _collector) public onlyOwner {
        adapterFeesCollector = _collector;
        emit FeesCollectorChange(_collector);
    }

    /**
     * @dev Sets the adapter fees taken from every relayed order
     * @param _transactionFee in a 0 - ADAPTER_FEE_MAX basis
     */
    function setAdapterFee(uint256 _transactionFee) public onlyOwner {
        require(
            ADAPTER_FEE_MAX >= _transactionFee,
            "BuyAdapter: Invalid transaction fee"
        );
        emit AdapterFeeChange(adapterTransactionFee, _transactionFee);
        adapterTransactionFee = _transactionFee;
    }

    /**
     * @dev Relays buy marketplace order. Uses the IConverter to
     *  swap erc20 tokens to ethers and call _buy() with the exact ether amount
     * @param _registry NFT registry address
     * @param _tokenId listed asset Id.
     * @param _marketplace marketplace listing the asset.
     * @param _encodedCallData forwarded to _marketplace.
     * @param _orderAmount (excluding fees) in ethers for the markeplace order
     * @param _paymentToken ERC20 address of the token used to pay
     * @param _maxPaymentTokenAmount max ERC20 token to use. Prevent high splippage.
     * @param _transferType choice for calling the ERC721 registry
     * @param _beneficiary where to send the ERC721 token
     */
    function buy(
        ITransferableRegistry _registry,
        uint256 _tokenId,
        address _marketplace,
        bytes memory _encodedCallData,
        uint256 _orderAmount,
        IERC20 _paymentToken,
        uint256 _maxPaymentTokenAmount,
        TransferType _transferType,
        address _beneficiary
    )
        public nonReentrant
    {
        IConverter converter = IConverter(converterAddress);

        // Calc total needed for this order + adapter fees
        uint256 orderFees = _calcOrderFees(_orderAmount);
        uint256 totalOrderAmount = _orderAmount.add(orderFees);

        // Get amount of srcTokens needed for the exchange
        uint256 paymentTokenAmount = converter.calcNeededTokensForEther(
            _paymentToken,
            totalOrderAmount
        );

        require(
            paymentTokenAmount > 0,
            "BuyAdapter: paymentTokenAmount invalid"
        );

        require(
            paymentTokenAmount <= _maxPaymentTokenAmount,
            "BuyAdapter: paymentTokenAmount > _maxPaymentTokenAmount"
        );

        // Get Tokens from sender
        _paymentToken.safeTransferFrom(
            msg.sender, address(this), paymentTokenAmount
        );

        // allow converter for this paymentTokenAmount transfer
        _paymentToken.safeApprove(converterAddress, paymentTokenAmount);

        // Get ethers from converter
        (uint256 convertedEth, uint256 remainderTokenAmount) = converter.swapTokenToEther(
            _paymentToken,
            paymentTokenAmount,
            totalOrderAmount
        );

        require(
            convertedEth == totalOrderAmount,
            "BuyAdapter: invalid ether amount after conversion"
        );

        if (remainderTokenAmount > 0) {
            _paymentToken.safeTransfer(msg.sender, remainderTokenAmount);
        }

        _buy(
            _registry,
            _tokenId,
            _marketplace,
            _encodedCallData,
            _orderAmount,
            orderFees,
            _transferType,
            _beneficiary
        );
    }

    /**
     * @dev Relays buy marketplace order taking the configured fees
     *  from message value.
     * @param _registry NFT registry address
     * @param _tokenId listed asset Id.
     * @param _marketplace marketplace listing the asset.
     * @param _encodedCallData forwarded to the _marketplace.
     * @param _orderAmount (excluding fees) in ethers for the markeplace order
     * @param _transferType choice for calling the ERC721 registry
     * @param _beneficiary where to send the ERC721 token
     */
    function buy(
        ITransferableRegistry _registry,
        uint256 _tokenId,
        address _marketplace,
        bytes memory _encodedCallData,
        uint256 _orderAmount,
        TransferType _transferType,
        address _beneficiary
    )
        public payable nonReentrant
    {
        // Calc total needed for this order + adapter fees
        uint256 orderFees = _calcOrderFees(_orderAmount);
        uint256 totalOrderAmount = _orderAmount.add(orderFees);

        // Check the order + fees
        require(
            msg.value == totalOrderAmount,
            "BuyAdapter: invalid msg.value != (order + fees)"
        );

        _buy(
            _registry,
            _tokenId,
            _marketplace,
            _encodedCallData,
            _orderAmount,
            orderFees,
            _transferType,
            _beneficiary
        );
    }

    /**
     * @dev Relays buy marketplace order taking the configured fees
     *  from message value.
     *  Notice that this method won't check what was bought. The calldata must have
     *  the desire beneficiry.
     * @param _marketplace marketplace listing the asset.
     * @param _encodedCallData forwarded to the _marketplace.
     * @param _orderAmount (excluding fees) in ethers for the markeplace order
     */
    function buy(
        address _marketplace,
        bytes memory _encodedCallData,
        uint256 _orderAmount
    )
        public payable nonReentrant
    {
        // Calc total needed for this order + adapter fees
        uint256 orderFees = _calcOrderFees(_orderAmount);
        uint256 totalOrderAmount = _orderAmount.add(orderFees);

        // Check the order + fees
        require(
            msg.value == totalOrderAmount,
            "BuyAdapter: invalid msg.value != (order + fees)"
        );

        _buy(
            _marketplace,
            _encodedCallData,
            _orderAmount,
            orderFees
        );
    }

    /**
     * @dev Relays buy marketplace order. Uses the IConverter to
     *  swap erc20 tokens to ethers and call _buy() with the exact ether amount.
     *  Notice that this method won't check what was bought. The calldata must have
     *  the desire beneficiry.
     * @param _marketplace marketplace listing the asset.
     * @param _encodedCallData forwarded to _marketplace.
     * @param _orderAmount (excluding fees) in ethers for the markeplace order
     * @param _paymentToken ERC20 address of the token used to pay
     * @param _maxPaymentTokenAmount max ERC20 token to use. Prevent high splippage.
     */
    function buy(
        address _marketplace,
        bytes memory _encodedCallData,
        uint256 _orderAmount,
        IERC20 _paymentToken,
        uint256 _maxPaymentTokenAmount
    )
        public nonReentrant
    {
        IConverter converter = IConverter(converterAddress);

        // Calc total needed for this order + adapter fees
        uint256 orderFees = _calcOrderFees(_orderAmount);
        uint256 totalOrderAmount = _orderAmount.add(orderFees);

        // Get amount of srcTokens needed for the exchange
        uint256 paymentTokenAmount = converter.calcNeededTokensForEther(
            _paymentToken,
            totalOrderAmount
        );

        require(
            paymentTokenAmount > 0,
            "BuyAdapter: paymentTokenAmount invalid"
        );

        require(
            paymentTokenAmount <= _maxPaymentTokenAmount,
            "BuyAdapter: paymentTokenAmount > _maxPaymentTokenAmount"
        );

        // Get Tokens from sender
        _paymentToken.safeTransferFrom(
            msg.sender, address(this), paymentTokenAmount
        );

        // allow converter for this paymentTokenAmount transfer
        _paymentToken.safeApprove(converterAddress, paymentTokenAmount);

        // Get ethers from converter
        (uint256 convertedEth, uint256 remainderTokenAmount) = converter.swapTokenToEther(
            _paymentToken,
            paymentTokenAmount,
            totalOrderAmount
        );

        require(
            convertedEth == totalOrderAmount,
            "BuyAdapter: invalid ether amount after conversion"
        );

        if (remainderTokenAmount > 0) {
            _paymentToken.safeTransfer(msg.sender, remainderTokenAmount);
        }

        _buy(
            _marketplace,
            _encodedCallData,
            _orderAmount,
            orderFees
        );
    }

    /**
     * @dev Internal call relays the order to a _marketplace.
     * @param _registry NFT registry address
     * @param _tokenId listed asset Id.
     * @param _marketplace marketplace listing the asset.
     * @param _encodedCallData forwarded to _marketplace.
     * @param _orderAmount (excluding fees) in ethers for the markeplace order
     * @param _feesAmount in ethers for the order
     * @param _transferType choice for calling the ERC721 registry
     * @param _beneficiary where to send the ERC721 token
     */
    function _buy(
        ITransferableRegistry _registry,
        uint256 _tokenId,
        address _marketplace,
        bytes memory _encodedCallData,
        uint256 _orderAmount,
        uint256 _feesAmount,
        TransferType _transferType,
        address _beneficiary
    )
        private
    {
        require(_orderAmount > 0, "BuyAdapter: invalid order value");
        require(adapterFeesCollector != address(0), "BuyAdapter: fees Collector must be set");

        // Save contract balance before call to marketplace
        uint256 preCallBalance = address(this).balance;

        // execute buy order in destination marketplace
        (bool success, ) = _marketplace.call{ value: _orderAmount }(
            _encodedCallData
        );

        require(
            success,
            "BuyAdapter: marketplace failed to execute buy order"
        );

        require(
            address(this).balance == preCallBalance.sub(_orderAmount),
            "BuyAdapter: postcall balance mismatch"
        );

        require(
            _registry.ownerOf(_tokenId) == address(this),
            "BuyAdapter: tokenId not transfered"
        );

        // Send balance to Collector. Reverts on failure
        require(
            adapterFeesCollector.send(address(this).balance),
            "BuyAdapter: error sending fees to collector"
        );

        // Transfer tokenId to caller
        _transferItem(
            _registry,
            _tokenId,
            _transferType,
            _beneficiary
        );

        // Log succesful executed order
        emit ExecutedOrder(
            address(_registry),
            _tokenId,
            _marketplace,
            _orderAmount,
            _feesAmount
        );
    }

    /**
     * @dev Internal call relays the order to a _marketplace.
     *  Notice that this method won't check what was bought. The calldata must have
     *  the desire beneficiry.
     * @param _marketplace marketplace listing the asset.
     * @param _encodedCallData forwarded to _marketplace.
     * @param _orderAmount (excluding fees) in ethers for the markeplace order
     * @param _feesAmount in ethers for the order
     */
    function _buy(
        address _marketplace,
        bytes memory _encodedCallData,
        uint256 _orderAmount,
        uint256 _feesAmount
    )
        private
    {
        require(_orderAmount > 0, "BuyAdapter: invalid order value");
        require(adapterFeesCollector != address(0), "BuyAdapter: fees Collector must be set");

        // Save contract balance before call to marketplace
        uint256 preCallBalance = address(this).balance;

        // execute buy order in destination marketplace
        (bool success, ) = _marketplace.call{ value: _orderAmount }(
            _encodedCallData
        );

        require(
            success,
            "BuyAdapter: marketplace failed to execute buy order"
        );

        require(
            address(this).balance == preCallBalance.sub(_orderAmount),
            "BuyAdapter: postcall balance mismatch"
        );

        // Send balance to Collector. Reverts on failure
        require(
            adapterFeesCollector.send(address(this).balance),
            "BuyAdapter: error sending fees to collector"
        );

        // Log succesful executed order
        emit ExecutedOrder(
            _marketplace,
            _orderAmount,
            _feesAmount,
            _encodedCallData
        );
    }

    /**
     * @dev Transfer the NFT to the final owner
     * @param _registry NFT registry address
     * @param _tokenId listed token Id.
     * @param _transferType choice for calling the ERC721 registry
     * @param _beneficiary where to send the ERC721 token
     */
    function _transferItem(
        ITransferableRegistry _registry,
        uint256 _tokenId,
        TransferType _transferType,
        address _beneficiary
    )
        private
    {
        require(_beneficiary != address(this), "BuyAdapter: invalid beneficiary");

        if (_transferType == TransferType.safeTransferFrom) {
            _registry.safeTransferFrom(address(this), _beneficiary, _tokenId);

        } else if (_transferType == TransferType.transferFrom) {
            _registry.transferFrom(
                address(this),
                _beneficiary,
                _tokenId
            );

        } else if (_transferType == TransferType.transfer) {
            _registry.transfer(
                _beneficiary,
                _tokenId
            );

        } else {
            revert('BuyAdapter: Unsopported transferType');
        }

        require(
            _registry.ownerOf(_tokenId) == _beneficiary,
            "BuyAdapter: error with asset transfer"
        );
    }

    /**
     * @param _orderAmount item value as in the NFT marketplace
     * @return adapter fees from total order value
     */
    function _calcOrderFees(uint256 _orderAmount) private view returns (uint256) {
        return _orderAmount
            .mul(adapterTransactionFee)
            .div(ADAPTER_FEE_PRECISION);
    }

    receive() external payable {
        require(msg.sender != tx.origin, "BuyAdapter: sender invalid");
    }
}