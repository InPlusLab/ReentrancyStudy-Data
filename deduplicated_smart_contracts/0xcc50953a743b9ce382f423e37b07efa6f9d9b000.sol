/**
 *Submitted for verification at Etherscan.io on 2020-11-15
*/

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

// File: @openzeppelin/contracts/utils/EnumerableSet.sol

pragma solidity ^0.6.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
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

// SPDX-License-Identifier: MIT

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

// File: contracts/lib/HitchensList.sol

pragma solidity ^0.6.0;

/* 
Hitchens Order Statistics Tree v0.98

A Solidity Red-Black Tree library to store and maintain a sorted data
structure in a Red-Black binary search tree, with O(log 2n) insert, remove
and search time (and gas, approximately)

https://github.com/rob-Hitchens/OrderStatisticsTree

Copyright (c) Rob Hitchens. the MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Significant portions from BokkyPooBahsRedBlackTreeLibrary, 
https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary

THIS SOFTWARE IS NOT TESTED OR AUDITED. DO NOT USE FOR PRODUCTION.
*/

library HitchensList {
    uint private constant EMPTY = 0;
    struct Node {
        uint parent;
        uint left;
        uint right;
        bool red;
        bytes32[] keys;
        mapping(bytes32 => uint) keyMap;
        uint count;
    }
    struct Tree {
        uint root;
        mapping(uint => Node) nodes;
    }
    function first(Tree storage self) internal view returns (uint _value) {
        _value = self.root;
        if(_value == EMPTY) return 0;
        while (self.nodes[_value].left != EMPTY) {
            _value = self.nodes[_value].left;
        }
    }
    function last(Tree storage self) internal view returns (uint _value) {
        _value = self.root;
        if(_value == EMPTY) return 0;
        while (self.nodes[_value].right != EMPTY) {
            _value = self.nodes[_value].right;
        }
    }
    function next(Tree storage self, uint value) internal view returns (uint _cursor) {
        require(value != EMPTY, "OrderStatisticsTree(401) - Starting value cannot be zero");
        if (self.nodes[value].right != EMPTY) {
            _cursor = treeMinimum(self, self.nodes[value].right);
        } else {
            _cursor = self.nodes[value].parent;
            while (_cursor != EMPTY && value == self.nodes[_cursor].right) {
                value = _cursor;
                _cursor = self.nodes[_cursor].parent;
            }
        }
    }
    function prev(Tree storage self, uint value) internal view returns (uint _cursor) {
        require(value != EMPTY, "OrderStatisticsTree(402) - Starting value cannot be zero");
        if (self.nodes[value].left != EMPTY) {
            _cursor = treeMaximum(self, self.nodes[value].left);
        } else {
            _cursor = self.nodes[value].parent;
            while (_cursor != EMPTY && value == self.nodes[_cursor].left) {
                value = _cursor;
                _cursor = self.nodes[_cursor].parent;
            }
        }
    }
    function exists(Tree storage self, uint value) internal view returns (bool _exists) {
        if(value == EMPTY) return false;
        if(value == self.root) return true;
        if(self.nodes[value].parent != EMPTY) return true;
        return false;       
    }
    function keyExists(Tree storage self, bytes32 key, uint value) internal view returns (bool _exists) {
        if(!exists(self, value)) return false;
        return self.nodes[value].keys[self.nodes[value].keyMap[key]] == key;
    } 
    function getNode(Tree storage self, uint value) internal view returns (uint _parent, uint _left, uint _right, bool _red, uint keyCount, uint count) {
        require(exists(self,value), "OrderStatisticsTree(403) - Value does not exist.");
        Node storage gn = self.nodes[value];
        return(gn.parent, gn.left, gn.right, gn.red, gn.keys.length, gn.keys.length+gn.count);
    }
    function getNodeCount(Tree storage self, uint value) internal view returns(uint count) {
        Node storage gn = self.nodes[value];
        return gn.keys.length+gn.count;
    }
    function valueKeyAtIndex(Tree storage self, uint value, uint index) internal view returns(bytes32 _key) {
        require(exists(self,value), "OrderStatisticsTree(404) - Value does not exist.");
        return self.nodes[value].keys[index];
    }
    function count(Tree storage self) internal view returns(uint _count) {
        return getNodeCount(self,self.root);
    }
    function percentile(Tree storage self, uint value) internal view returns(uint _percentile) {
        uint denominator = count(self);
        uint numerator = rank(self, value);
        _percentile = ((uint(1000) * numerator)/denominator+(uint(5)))/uint(10);
    }
    function permil(Tree storage self, uint value) internal view returns(uint _permil) {
        uint denominator = count(self);
        uint numerator = rank(self, value);
        _permil = ((uint(10000) * numerator)/denominator+(uint(5)))/uint(10);
    }
    function atPercentile(Tree storage self, uint _percentile) internal view returns(uint _value) {
        uint findRank = (((_percentile * count(self))/uint(10)) + uint(5)) / uint(10);
        return atRank(self,findRank);
    }
    function atPermil(Tree storage self, uint _permil) internal view returns(uint _value) {
        uint findRank = (((_permil * count(self))/uint(100)) + uint(5)) / uint(10);
        return atRank(self,findRank);
    }    
    function median(Tree storage self) internal view returns(uint value) {
        return atPercentile(self,50);
    }
    function below(Tree storage self, uint value) public view returns(uint _below) {
        if(count(self) > 0 && value > 0) _below = rank(self,value)-uint(1);
    }
    function above(Tree storage self, uint value) public view returns(uint _above) {
        if(count(self) > 0) _above = count(self)-rank(self,value);
    } 
    function rank(Tree storage self, uint value) internal view returns(uint _rank) {
        if(count(self) > 0) {
            bool finished;
            uint cursor = self.root;
            Node storage c = self.nodes[cursor];
            uint smaller = getNodeCount(self,c.left);
            while (!finished) {
                uint keyCount = c.keys.length;
                if(cursor == value) {
                    finished = true;
                } else {
                    if(cursor < value) {
                        cursor = c.right;
                        c = self.nodes[cursor];
                        smaller += keyCount + getNodeCount(self,c.left);
                    } else {
                        cursor = c.left;
                        c = self.nodes[cursor];
                        smaller -= (keyCount + getNodeCount(self,c.right));
                    }
                }
                if (!exists(self,cursor)) {
                    finished = true;
                }
            }
            return smaller + 1;
        }
    }
    function atRank(Tree storage self, uint _rank) internal view returns(uint _value) {
        bool finished;
        uint cursor = self.root;
        Node storage c = self.nodes[cursor];
        uint smaller = getNodeCount(self,c.left);
        while (!finished) {
            _value = cursor;
            c = self.nodes[cursor];
            uint keyCount = c.keys.length;
            if(smaller + 1 >= _rank && smaller + keyCount <= _rank) {
                _value = cursor;
                finished = true;
            } else {
                if(smaller + keyCount <= _rank) {
                    cursor = c.right;
                    c = self.nodes[cursor];
                    smaller += keyCount + getNodeCount(self,c.left);
                } else {
                    cursor = c.left;
                    c = self.nodes[cursor];
                    smaller -= (keyCount + getNodeCount(self,c.right));
                }
            }
            if (!exists(self,cursor)) {
                finished = true;
            }
        }
    }
    function insert(Tree storage self, bytes32 key, uint value) internal {
        require(value != EMPTY, "OrderStatisticsTree(405) - Value to insert cannot be zero");
        require(!keyExists(self,key,value), "OrderStatisticsTree(406) - Value and Key pair exists. Cannot be inserted again.");
        uint cursor;
        uint probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (value < probe) {
                probe = self.nodes[probe].left;
            } else if (value > probe) {
                probe = self.nodes[probe].right;
            } else if (value == probe) {
                self.nodes[probe].keys.push(key);
                self.nodes[probe].keyMap[key] = self.nodes[probe].keys.length - uint(1);
                return;
            }
            self.nodes[cursor].count++;
        }
        Node storage nValue = self.nodes[value];
        nValue.parent = cursor;
        nValue.left = EMPTY;
        nValue.right = EMPTY;
        nValue.red = true;
        nValue.keys.push(key);
        nValue.keyMap[key] = nValue.keys.length - uint256(1);
        if (cursor == EMPTY) {
            self.root = value;
        } else if (value < cursor) {
            self.nodes[cursor].left = value;
        } else {
            self.nodes[cursor].right = value;
        }
        insertFixup(self, value);
    }
    function remove(Tree storage self, bytes32 key, uint value) internal {
        require(value != EMPTY, "OrderStatisticsTree(407) - Value to delete cannot be zero");
        require(keyExists(self,key,value), "OrderStatisticsTree(408) - Value to delete does not exist.");
        Node storage nValue = self.nodes[value];
        uint rowToDelete = nValue.keyMap[key];
        nValue.keys[rowToDelete] = nValue.keys[nValue.keys.length - uint(1)];
        nValue.keyMap[key]=rowToDelete;
        nValue.keys.pop();
        uint probe;
        uint cursor;
        if(nValue.keys.length == 0) {
            if (self.nodes[value].left == EMPTY || self.nodes[value].right == EMPTY) {
                cursor = value;
            } else {
                cursor = self.nodes[value].right;
                while (self.nodes[cursor].left != EMPTY) { 
                    cursor = self.nodes[cursor].left;
                }
            } 
            if (self.nodes[cursor].left != EMPTY) {
                probe = self.nodes[cursor].left; 
            } else {
                probe = self.nodes[cursor].right; 
            }
            uint cursorParent = self.nodes[cursor].parent;
            self.nodes[probe].parent = cursorParent;
            if (cursorParent != EMPTY) {
                if (cursor == self.nodes[cursorParent].left) {
                    self.nodes[cursorParent].left = probe;
                } else {
                    self.nodes[cursorParent].right = probe;
                }
            } else {
                self.root = probe;
            }
            bool doFixup = !self.nodes[cursor].red;
            if (cursor != value) {
                replaceParent(self, cursor, value); 
                self.nodes[cursor].left = self.nodes[value].left;
                self.nodes[self.nodes[cursor].left].parent = cursor;
                self.nodes[cursor].right = self.nodes[value].right;
                self.nodes[self.nodes[cursor].right].parent = cursor;
                self.nodes[cursor].red = self.nodes[value].red;
                (cursor, value) = (value, cursor);
                fixCountRecurse(self, value);
            }
            if (doFixup) {
                removeFixup(self, probe);
            }
            fixCountRecurse(self,cursorParent);
            delete self.nodes[cursor];
        }
    }
    function fixCountRecurse(Tree storage self, uint value) private {
        while (value != EMPTY) {
           self.nodes[value].count = getNodeCount(self,self.nodes[value].left) + getNodeCount(self,self.nodes[value].right);
           value = self.nodes[value].parent;
        }
    }
    function treeMinimum(Tree storage self, uint value) private view returns (uint) {
        while (self.nodes[value].left != EMPTY) {
            value = self.nodes[value].left;
        }
        return value;
    }
    function treeMaximum(Tree storage self, uint value) private view returns (uint) {
        while (self.nodes[value].right != EMPTY) {
            value = self.nodes[value].right;
        }
        return value;
    }
    function rotateLeft(Tree storage self, uint value) private {
        uint cursor = self.nodes[value].right;
        uint parent = self.nodes[value].parent;
        uint cursorLeft = self.nodes[cursor].left;
        self.nodes[value].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].left) {
            self.nodes[parent].left = cursor;
        } else {
            self.nodes[parent].right = cursor;
        }
        self.nodes[cursor].left = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count = getNodeCount(self,self.nodes[value].left) + getNodeCount(self,self.nodes[value].right);
        self.nodes[cursor].count = getNodeCount(self,self.nodes[cursor].left) + getNodeCount(self,self.nodes[cursor].right);
    }
    function rotateRight(Tree storage self, uint value) private {
        uint cursor = self.nodes[value].left;
        uint parent = self.nodes[value].parent;
        uint cursorRight = self.nodes[cursor].right;
        self.nodes[value].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].right) {
            self.nodes[parent].right = cursor;
        } else {
            self.nodes[parent].left = cursor;
        }
        self.nodes[cursor].right = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count = getNodeCount(self,self.nodes[value].left) + getNodeCount(self,self.nodes[value].right);
        self.nodes[cursor].count = getNodeCount(self,self.nodes[cursor].left) + getNodeCount(self,self.nodes[cursor].right);
    }
    function insertFixup(Tree storage self, uint value) private {
        uint cursor;
        while (value != self.root && self.nodes[self.nodes[value].parent].red) {
            uint valueParent = self.nodes[value].parent;
            if (valueParent == self.nodes[self.nodes[valueParent].parent].left) {
                cursor = self.nodes[self.nodes[valueParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].right) {
                      value = valueParent;
                      rotateLeft(self, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    rotateRight(self, self.nodes[valueParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[valueParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].left) {
                      value = valueParent;
                      rotateRight(self, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    rotateLeft(self, self.nodes[valueParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
    }
    function replaceParent(Tree storage self, uint a, uint b) private {
        uint bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }
    function removeFixup(Tree storage self, uint value) private {
        uint cursor;
        while (value != self.root && !self.nodes[value].red) {
            uint valueParent = self.nodes[value].parent;
            if (value == self.nodes[valueParent].left) {
                cursor = self.nodes[valueParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    rotateLeft(self, valueParent);
                    cursor = self.nodes[valueParent].right;
                }
                if (!self.nodes[self.nodes[cursor].left].red && !self.nodes[self.nodes[cursor].right].red) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor);
                        cursor = self.nodes[valueParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, valueParent);
                    value = self.root;
                }
            } else {
                cursor = self.nodes[valueParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    rotateRight(self, valueParent);
                    cursor = self.nodes[valueParent].left;
                }
                if (!self.nodes[self.nodes[cursor].right].red && !self.nodes[self.nodes[cursor].left].red) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor);
                        cursor = self.nodes[valueParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, valueParent);
                    value = self.root;
                }
            }
        }
        self.nodes[value].red = false;
    }
}

// File: contracts/ichiFarm.sol

pragma solidity 0.6.12;







interface IUniswapOracle {
    function changeInterval(uint256 seconds_) external;
    function update() external;
    function consult(address token, uint amountIn) external view returns (uint amountOut);
}

interface IFactor {
    function getFactorList(uint256 key) external view returns (uint256[] memory);       // get factor list
    function populateFactors(uint256 startingKey, uint256 endingKey) external;          // add new factors
}

// deposit ichiLP tokens to farm ICHI
contract ichiFarm is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using HitchensList for HitchensList.Tree;

    //   pending reward = (user.amount * pool.accIchiPerShare) - user.rewardDebt
    //   Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
    //   1. The pool's `accIchiPerShare` (and `lastRewardBlock`) gets updated.
    //   2. User receives the pending reward sent to his/her address.
    //   3. User's `amount` gets updated.
    //   4. User's `rewardDebt` gets updated.

    struct UserInfo {
        uint256 amount;                                                 // How many LP tokens the user has provided.
        uint256 rewardDebt;                                             // Reward debt. See explanation below.
        uint256 bonusReward;                                            // Bonous Reward Tokens
    }
                                                                        // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;                                                 // Address of LP token contract.
        uint256 allocPoint;                                             // How many allocation points assigned to this pool. ICHIs to distribute per block.
        uint256 lastRewardBlock;                                        // Last block number that ICHIs distribution occurs.
        uint256 lastRewardBonusBlock;                                   // Last bonus number block
        uint256 accIchiPerShare;                                        // Accumulated ICHIs per share, times 10 ** 9. See below.
        uint256 startBlock;                                             // start block for rewards
        uint256 endBlock;                                               // end block for rewards
        uint256 bonusToRealRatio;                                       // ranges from 0 to 100. 0 = 0% of bonus tokens distributed, 100 = 100% of tokens distributed to bonus
                                                                        // initial val = 50 (50% goes to regular, 50% goes to bonus)

        uint256 maxWinnersPerBlock;                                     // maximum winners per block
        uint256 maxTransactionLoop;                                     // maximimze winners per tx
                                                                        // if miners > this value, increase the 3 variables above
        uint256 gasTank;                                                // amount of ichi in the gas tank (10 ** 9)

        HitchensList.Tree blockRank;                                    // sorted list data structure (red black tree)
    }

    IERC20 public ichi;
    uint256 public ichiPerBlock;                                        // ICHI tokens created per block.

    PoolInfo[] internal poolInfo;                                       // Info of each pool (must be internal for blockRank data structure)
    mapping (uint256 => mapping (address => UserInfo)) public userInfo; // Info of each user that stakes LP tokens.

    uint256 public totalAllocPoint;                                     // Total allocation points. Must be the sum of all allocation points in all pools.

    address public oneFactorContract;                                   // contract address uses to add new factor and get existing factor

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event NewMaxBlock(uint256 maxLoops);
    
    bool nonReentrant;
    event LogTree(string action, uint256 indexed pid, bytes32 key, uint256 value);

    address public ichiEthOracle;
    address public wethAddress;

    event LogGas(uint256 index, uint256 gasPrice, uint256 gasLimit, uint256 gasUsed);
    event LogIchiPerWinner(uint256 blockNumber, uint256 winners, uint256 ichiPaid);

    // ============================================================================
    // all initial ICHI circulation initially will be deposited into this ichiFarm contract

    constructor (
        IERC20 _ichi,
        uint256 _ichiPerBlock,
        address _oneFactorContract,
        address _ichiEthOracle,
        address _wethAddress
    )  
        public
    {
        ichi = _ichi;
        ichiEthOracle = _ichiEthOracle;
        wethAddress = _wethAddress;
        ichiPerBlock = _ichiPerBlock; // 5 => 5*2 = 5,000,000 coins
        totalAllocPoint = 0;
        oneFactorContract = _oneFactorContract;
    }

    function setMaxWinnersPerBlock(uint256 _poolID, uint256 _val) external onlyOwner {
        poolInfo[_poolID].maxWinnersPerBlock = _val;
    }

    function setMaxTransactionLoop(uint256 _poolID, uint256 _val) external onlyOwner {
        poolInfo[_poolID].maxTransactionLoop = _val;
    }

    function setIchiEthOracle(address address_) external onlyOwner {
        ichiEthOracle = address_;
    }

    function setWethAddress(address address_) external onlyOwner {
        wethAddress = address_;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setNonReentrant(bool _val) external onlyOwner returns (bool) {
        nonReentrant = _val;
        return nonReentrant;
    }

    function gasTank(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].gasTank;
    }

    function getMaxTransactionLoop(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].maxTransactionLoop;
    }

    function getMaxWinnersPerBlock(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].maxWinnersPerBlock;
    }

    function getBonusToRealRatio(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].bonusToRealRatio;
    }

    function setBonusToRealRatio(uint256 _poolID, uint256 _val) external returns (uint256) {
        require(_val <= 100, "must not exceed 100%");
        require(_val >= 0, "must be at least 0%");

        poolInfo[_poolID].bonusToRealRatio = _val;
    }

    function lastRewardsBlock(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].lastRewardBlock;
    }

    function lastRewardsBonusBlock(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].lastRewardBonusBlock;
    }

    function startBlock(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].startBlock;
    }


    function getPoolToken(uint256 _poolID) external view returns (address) {
        return address(poolInfo[_poolID].lpToken);
    }

    function getAllocPoint(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].allocPoint;
    }

    function getAllocPerShare(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].accIchiPerShare;
    }

    function ichiReward(uint256 _poolID) external view returns (uint256) {
        return (ichiPerBlock * 10 ** 9).mul(poolInfo[_poolID].allocPoint).div(totalAllocPoint);
    }

    function getLPSupply(uint256 _poolID) external view returns (uint256) {
        uint256 lpSupply = poolInfo[_poolID].lpToken.balanceOf(address(this));
        return lpSupply;
    }

    function endBlock(uint256 _poolID) external view returns (uint256) {
        return poolInfo[_poolID].endBlock;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256 _startBlock, uint256 _endBlock)
        public
        onlyOwner
    {
        if (_withUpdate) {
            massUpdatePools();
        }

        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        HitchensList.Tree storage blockRankObject;

        // create pool info
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: _startBlock,
            lastRewardBonusBlock: _startBlock,
            startBlock: _startBlock,
            endBlock: _endBlock,
            bonusToRealRatio: 50,       // 1-1 split of 2 ichi reward per block
            accIchiPerShare: 0,
            maxWinnersPerBlock: 8,      // for good luck
            maxTransactionLoop: 100,    // 100 total winners per update bonus reward
            gasTank: 0,
            blockRank: blockRankObject
        }));
    }

    // Update the given pool's ICHI allocation point. Can only be called by the owner.
    function set(uint256 _poolID, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_poolID].allocPoint).add(_allocPoint);
        poolInfo[_poolID].allocPoint = _allocPoint;
    }

    // View function to see pending ICHIs on frontend.
    function pendingIchi(uint256 _poolID, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_poolID];
        UserInfo storage user = userInfo[_poolID][_user];
        uint256 accIchiPerShare = pool.accIchiPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 latestBlock = block.number <= pool.endBlock ? block.number : pool.endBlock;
            uint256 blocks = latestBlock.sub(pool.lastRewardBlock);
            uint256 ichiRewardAmount = blocks.mul(ichiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accIchiPerShare = accIchiPerShare.add(ichiRewardAmount.mul(10 ** 18).div(lpSupply)); // 10 ** 18 to match the LP supply
        }
        return user.amount.mul(accIchiPerShare).div(10 ** 9).sub(user.rewardDebt);
    }

    // View bonus Ichi
    function pendingBonusIchi(uint256 _poolID, address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_poolID][_user];
        return user.bonusReward;
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    // also run bonus rewards calculations
    function updatePool(uint256 _poolID) public {
        PoolInfo storage pool = poolInfo[_poolID];

        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 blocks = block.number.sub(pool.lastRewardBlock);

        // must be within end block
        if (block.number <= pool.endBlock) {
            uint256 bonusToRealRatio = pool.bonusToRealRatio;
            uint256 ichiRewardAmount = blocks.mul(ichiPerBlock).mul(pool.allocPoint).div(totalAllocPoint).mul(uint256(100).sub(bonusToRealRatio)).div(50);
            pool.accIchiPerShare = pool.accIchiPerShare.add(ichiRewardAmount.mul(10 ** 18).div(lpSupply)); // 10 ** 18 to match LP supply
            pool.lastRewardBlock = block.number;
        }
    }

    function setFactorContract(address contract_) external onlyOwner {
        oneFactorContract = contract_;
    }

    // separate function to call by the public
    function updateBonusRewards(uint256 _poolID)
        public
    {
        require(!nonReentrant, "ichiFarm::nonReentrant - try again");
        nonReentrant = true;
        updatePool(_poolID);
        uint256 startGas = gasleft();

        if (address(ichiEthOracle) != address(0)) IUniswapOracle(ichiEthOracle).update();

        PoolInfo storage pool = poolInfo[_poolID];

        if (block.number <= pool.lastRewardBonusBlock || block.number < pool.startBlock || block.number > pool.endBlock) {
            nonReentrant = false;
            return;
        }

        uint256 lastRewardBlock = pool.lastRewardBonusBlock;

        // run bonus rewards calculations
        uint256 totalMinersInPool = valueKeyCount(_poolID);

        // increment this to see if it hits the max
        uint256 totalWinnersPerTX = 0;
        for (uint256 blockIter = lastRewardBlock; blockIter < block.number; ++blockIter) { // block.number

            uint256 cutoff = findBlockNumberCutoff(totalMinersInPool, blockIter);

            // add factor list if not found
            if (IFactor(oneFactorContract).getFactorList(cutoff).length == 0) {
                IFactor(oneFactorContract).populateFactors(cutoff, cutoff.add(1));  
            }

            // rank factors in the block number
            uint256[] memory factors = IFactor(oneFactorContract).getFactorList(cutoff);
            uint256 extraFactors = ((totalMinersInPool.sub(totalMinersInPool.mod(cutoff))).div(cutoff));
            extraFactors = extraFactors != 0 ? extraFactors.sub(1) : 0;

            uint256 currentBlockWinners = factors.length.add(extraFactors);                         // total winners
            uint256 rewardPerWinner = uint256(ichiPerBlock * 10 ** 9).div(currentBlockWinners);     // assume 10 ** 9 = 1 ICHI token

            // keep winners payout to less than the max transaction loop size
            if (totalWinnersPerTX.add(currentBlockWinners) > pool.maxTransactionLoop) {
                uint256 unpaidBlocks = block.number.sub(blockIter);                                 // pay gasTank for unpaid blocks
                pool.gasTank = pool.gasTank.add((ichiPerBlock * 10 ** 9).mul(unpaidBlocks.mul(pool.allocPoint).div(totalAllocPoint)));                // ICHI!
                break;
            }

            // save to gasTank
            if (currentBlockWinners > pool.maxWinnersPerBlock) {
                pool.gasTank = pool.gasTank.add((ichiPerBlock * 10 ** 9).mul(pool.allocPoint).div(totalAllocPoint)); // ICHI!
                totalWinnersPerTX = totalWinnersPerTX.add(1);
            } else {
                updateBonusRewardsHelper(factors, _poolID, rewardPerWinner, cutoff, totalMinersInPool, extraFactors);
                totalWinnersPerTX = totalWinnersPerTX.add(currentBlockWinners); // add winners
            }
        }

        // update new variables based on the number of farmers paid
        if (totalWinnersPerTX > pool.maxTransactionLoop) {
            if (pool.maxWinnersPerBlock > 2) pool.maxWinnersPerBlock = pool.maxWinnersPerBlock.sub(1);
        } else if (totalWinnersPerTX < 25) {
            if (pool.maxWinnersPerBlock < 25) pool.maxWinnersPerBlock = pool.maxWinnersPerBlock.add(1);
        }

        uint256 gasPrice = tx.gasprice;
        uint256 gasUsed = (startGas - gasleft()).mul(gasPrice); // gets gas used in wei
        uint256 ichiPayment = address(ichiEthOracle) != address(0) ? IUniswapOracle(ichiEthOracle).consult(wethAddress, gasUsed) : totalWinnersPerTX.mul(10 ** 8); // default is 0.1 Ichi per winner
        ichiPayment = ichiPayment.add(ichiPayment.div(10));    // add 10%
        uint256 ichiToPayCaller = ichiPayment <= pool.gasTank ? ichiPayment : pool.gasTank;

        // minimum pay 3 users
        if (ichiToPayCaller != 0 && totalWinnersPerTX >= 3 && block.number <= pool.endBlock) {
            safeIchiTransfer(msg.sender, ichiToPayCaller);              // send ichi to caller
            pool.gasTank = pool.gasTank.sub(ichiToPayCaller);           // update gas tank
            emit LogIchiPerWinner(block.number, totalWinnersPerTX, ichiToPayCaller);
        }

        emit LogGas(0, gasPrice, startGas - gasleft(), gasUsed);

        // update the last block.number for bonus
        pool.lastRewardBonusBlock = block.number;
        nonReentrant = false;
    }

    // loop through winners and update their keys
    function updateBonusRewardsHelper(
        uint256[] memory factors,
        uint256 _poolID,
        uint256 rewardPerWinner,
        uint256 cutoff,
        uint256 totalMinersInPool,
        uint256 extraFactors
    ) private {
        uint256 bonusToRealRatio = poolInfo[_poolID].bonusToRealRatio;

        // loop through factors and factors2 and add `rewardPerWinner` to each
        for (uint256 i = 0; i < factors.length; ++i) {
            // factor cannot be last node
            if (factors[i] != totalMinersInPool || totalMinersInPool == 1) {
                uint256 value = valueAtRankReverse(_poolID, factors[i]);
                address key = getValueKey(_poolID, value, 0);
                userInfo[_poolID][key].bonusReward = userInfo[_poolID][key].bonusReward.add(rewardPerWinner.mul(bonusToRealRatio).div(50));
            }
        }

        // increment to next
        uint256 startingCutoff = cutoff;

        for (uint256 j = 1; j <= extraFactors; ++j) {
            uint256 value = valueAtRankReverse(_poolID, startingCutoff.mul(j));
            address key = getValueKey(_poolID, value, 0);
            userInfo[_poolID][key].bonusReward = userInfo[_poolID][key].bonusReward.add(rewardPerWinner.mul(bonusToRealRatio).div(50));
        }
    }

    // Deposit LP tokens to ichiFarm for ICHI allocation.
    // call ichiFactor function (add if not enough)
    function deposit(uint256 _poolID, uint256 _amount) public {
        require(!nonReentrant, "ichiFarm::nonReentrant - try again");
        nonReentrant = true;

        PoolInfo storage pool = poolInfo[_poolID];
        UserInfo storage user = userInfo[_poolID][msg.sender];

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accIchiPerShare).div(10 ** 9).sub(user.rewardDebt);

            if (pending > 0) {
                safeIchiTransfer(msg.sender, pending);
            }

            if (user.bonusReward > 0) {
                safeIchiTransfer(msg.sender, user.bonusReward);
            }
        }

        if (_amount > 0) {
            // if key exists, remove and re add
            require(!valueExists(_poolID, user.amount.add(_amount)), "ichiFarm::LP collision - please try a different LP amount");
            require(pool.lpToken.balanceOf(msg.sender) >= _amount, "insufficient LP balance");

            if (keyValueExists(_poolID, bytes32(uint256(msg.sender)), user.amount)) {
                removeKeyValue(_poolID, bytes32(uint256(msg.sender)), user.amount);
            }

            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            user.amount = user.amount.add(_amount);

            insertKeyValue(_poolID, bytes32(uint256(msg.sender)), user.amount);
        }

        // calculate the new total miners after this deposit
        uint256 totalMinersInPool = valueKeyCount(_poolID);

        // add factor list if not found
        if (IFactor(oneFactorContract).getFactorList(totalMinersInPool).length == 0) {
            IFactor(oneFactorContract).populateFactors(totalMinersInPool, totalMinersInPool.add(1));  
        }

        updatePool(_poolID);

        user.rewardDebt = user.amount.mul(pool.accIchiPerShare).div(10 ** 9);
        emit Deposit(msg.sender, _poolID, _amount);
        nonReentrant = false;
    }

    // Withdraw from ichiFarm
    function withdraw(uint256 _poolID) public {
        require(!nonReentrant, "ichiFarm::nonReentrant - try again");
        nonReentrant = true;

        PoolInfo storage pool = poolInfo[_poolID];
        UserInfo storage user = userInfo[_poolID][msg.sender];
        uint256 bonusToRealRatio = pool.bonusToRealRatio;

        updatePool(_poolID);

        uint256 pending = user.amount.mul(pool.accIchiPerShare).div(10 ** 9).sub(user.rewardDebt);
        if (pending > 0) {
            safeIchiTransfer(msg.sender, pending.mul(uint256(100).sub(bonusToRealRatio)).div(50));
        }
        if (user.bonusReward > 0) {
            safeIchiTransfer(msg.sender, uint256(user.bonusReward).mul(bonusToRealRatio).div(50));
            user.bonusReward = 0;
        }

        removeKeyValue(_poolID, bytes32(uint256(msg.sender)), user.amount); // remove current key

        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit Withdraw(msg.sender, _poolID, user.amount);
        user.amount = 0;

        user.rewardDebt = user.amount.mul(pool.accIchiPerShare).div(10 ** 9);
        nonReentrant = false;
    }

    // get rewards but no LP
    function claimRewards(uint256 _poolID) public {
        require(!nonReentrant, "ichiFarm::nonReentrant - try again");
        nonReentrant = true;

        PoolInfo storage pool = poolInfo[_poolID];
        UserInfo storage user = userInfo[_poolID][msg.sender];
        uint256 bonusToRealRatio = pool.bonusToRealRatio;

        updatePool(_poolID);

        uint256 pending = user.amount.mul(pool.accIchiPerShare).div(10 ** 9).sub(user.rewardDebt);
        if (pending > 0) {
            safeIchiTransfer(msg.sender, pending.mul(uint256(100).sub(bonusToRealRatio)).div(50));
        }
        if (user.bonusReward > 0) {
            safeIchiTransfer(msg.sender, uint256(user.bonusReward).mul(bonusToRealRatio).div(50));
            user.bonusReward = 0;
        }

        user.rewardDebt = user.amount.mul(pool.accIchiPerShare).div(10 ** 9);
        nonReentrant = false;
    }

    // Withdraw without caring about rewards.
    function emergencyWithdraw(uint256 _poolID) public {
        PoolInfo storage pool = poolInfo[_poolID];
        UserInfo storage user = userInfo[_poolID][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _poolID, user.amount);

        removeKeyValue(_poolID, bytes32(uint256(msg.sender)), user.amount); // remove current key
        user.amount = 0;
        user.rewardDebt = 0;
        user.bonusReward = 0;
    }

    // Safe ichi transfer function, just in case if rounding error causes pool to not have enough ICHIs.
    function safeIchiTransfer(address _to, uint256 _amount) internal {
        uint256 ichiBal = ichi.balanceOf(address(this));
        if (_amount > ichiBal) {
            ichi.transfer(_to, ichiBal);
        } else {
            ichi.transfer(_to, _amount);
        }
    }

    // finds the smallest block number cutoff that is <= total ranks in a given pool
    function findBlockNumberCutoff(uint256 _totalRanks, uint256 _currentBlockNumber) public pure returns (uint256) {
        uint256 modulo = 1000000;
        uint256 potentialCutoff = _currentBlockNumber % modulo;

        while (potentialCutoff > _totalRanks) {
            modulo = modulo.div(10);
            potentialCutoff = _currentBlockNumber % modulo;
        }

        return potentialCutoff == 0 ? 1 : potentialCutoff;
    }

    // internal functions to call our sorted list
    function treeRootNode(uint256 _poolID) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.root;
    }
    function firstValue(uint256 _poolID) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.first();
    }
    function lastValue(uint256 _poolID) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.last();
    }
    function nextValue(uint256 _poolID, uint value) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.next(value);
    }
    function prevValue(uint256 _poolID, uint value) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.prev(value);
    }
    function valueExists(uint256 _poolID, uint value) public view returns (bool _exists) {
        _exists = poolInfo[_poolID].blockRank.exists(value);
    }
    function keyValueExists(uint256 _poolID, bytes32 key, uint value) public view returns (bool _exists) {
        _exists = poolInfo[_poolID].blockRank.keyExists(key, value);
    }
    function getNode(uint256 _poolID, uint value) public view returns (uint _parent, uint _left, uint _right, bool _red, uint _keyCount, uint _count) {
        (_parent, _left, _right, _red, _keyCount, _count) = poolInfo[_poolID].blockRank.getNode(value);
    }
    function getValueKey(uint256 _poolID, uint value, uint row) public view returns (address _key) {
        _key = address(uint160(uint256(poolInfo[_poolID].blockRank.valueKeyAtIndex(value,row))));
    }
    function getValueKeyRaw(uint256 _poolID, uint256 value, uint256 row) public view returns (bytes32) {
        return poolInfo[_poolID].blockRank.valueKeyAtIndex(value,row);
    }
    function valueKeyCount(uint256 _poolID) public view returns (uint _count) {
        _count = poolInfo[_poolID].blockRank.count();
    } 
    function valuePercentile(uint256 _poolID, uint value) public view returns (uint _percentile) {
        _percentile = poolInfo[_poolID].blockRank.percentile(value);
    }
    function valuePermil(uint256 _poolID, uint value) public view returns (uint _permil) {
        _permil = poolInfo[_poolID].blockRank.permil(value);
    }  
    function valueAtPercentile(uint256 _poolID, uint _percentile) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.atPercentile(_percentile);
    }
    function valueAtPermil(uint256 _poolID, uint value) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.atPermil(value);
    }
    function medianValue(uint256 _poolID) public view returns (uint _value) {
        return poolInfo[_poolID].blockRank.median();
    }
    function valueRank(uint256 _poolID, uint value) public view returns (uint _rank) {
        _rank = poolInfo[_poolID].blockRank.rank(value);
    }
    function valuesBelow(uint256 _poolID, uint value) public view returns (uint _below) {
        _below = poolInfo[_poolID].blockRank.below(value);
    }
    function valuesAbove(uint256 _poolID, uint value) public view returns (uint _above) {
        _above = poolInfo[_poolID].blockRank.above(value);
    }    
    function valueAtRank(uint256 _poolID, uint _rank) public view returns (uint _value) {
        _value = poolInfo[_poolID].blockRank.atRank(_rank);
    }
    function valueAtRankReverse(uint256 _poolID, uint256 _rank) public view returns (uint256) {
        if (poolInfo[_poolID].blockRank.count() == 1) return poolInfo[_poolID].blockRank.atRank(2);

        return poolInfo[_poolID].blockRank.atRank(poolInfo[_poolID].blockRank.count() - (_rank - 1));
    }
    function valueRankReverse(uint256 _poolID, uint256 value) public view returns (uint256) {
        return poolInfo[_poolID].blockRank.count() - (poolInfo[_poolID].blockRank.rank(value) - 1);
    }
    function insertKeyValue(uint256 _poolID, bytes32 key, uint value) private {
        emit LogTree("insert", _poolID, key, value);
        poolInfo[_poolID].blockRank.insert(key, value);
    }
    function removeKeyValue(uint256 _poolID, bytes32 key, uint value) private {
        emit LogTree("delete", _poolID, key, value);
        poolInfo[_poolID].blockRank.remove(key, value);
    }
}