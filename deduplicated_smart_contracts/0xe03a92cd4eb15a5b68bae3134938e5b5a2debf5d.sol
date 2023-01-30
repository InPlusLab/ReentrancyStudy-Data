// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*                                                *\
 *                ,.-"""-.,                       *
 *               /   ===   \                      *
 *              /  =======  \                     *
 *           __|  (o)   (0)  |__                  *
 *          / _|    .---.    |_ \                 *
 *         | /.----/ O O \----.\ |                *
 *          \/     |     |     \/                 *
 *          |                   |                 *
 *          |                   |                 *
 *          |                   |                 *
 *          _\   -.,_____,.-   /_                 *
 *      ,.-"  "-.,_________,.-"  "-.,             *
 *     /          |       |  ╭-╮     \            *
 *    |           l.     .l  ┃ ┃      |           *
 *    |            |     |   ┃ ╰━━╮   |           *
 *    l.           |     |   ┃ ╭╮ ┃  .l           *
 *     |           l.   .l   ┃ ┃┃ ┃  | \,         *
 *     l.           |   |    ╰-╯╰-╯ .l   \,       *
 *      |           |   |           |      \,     *
 *      l.          |   |          .l        |    *
 *       |          |   |          |         |    *
 *       |          |---|          |         |    *
 *       |          |   |          |         |    *
 *       /"-.,__,.-"\   /"-.,__,.-"\"-.,_,.-"\    *
 *      |            \ /            |         |   *
 *      |             |             |         |   *
 *       \__|__|__|__/ \__|__|__|__/ \_|__|__/    *
\*                                                 */

contract ForexVesting is Ownable {
    using SafeERC20 for IERC20;

    /** @dev Canonical FOREX token address */
    address public immutable FOREX;
    /** @dev The vesting period in seconds at which the FOREX supply for each
             participant is accrued as claimable each second according to their
             vested value */
    uint256 public immutable vestingPeriod;
    /** @dev Minimum delay (in seconds) between user claims. */
    uint256 public immutable minimumClaimDelay;
    /** @dev Date from which participants can claim their immediate value, and
             from which the vested value starts accruing as claimable */
    uint256 public claimStartDate;
    /** @dev Mapping of (participant address => participant vesting data) */
    mapping(address => Participant) public participants;
    /** @dev Total funds required by contract. Used for asserting the contract
             has been correctly funded after deployment */
    uint256 public immutable forexSupply;

    /** @dev Vesting data for participant */
    struct Participant {
        /* Amount initially claimable at any time from the claimStartDate */
        uint256 claimable;
        /* Total vested amount released in equal amounts throughout the
                 vesting period. */
        uint256 vestedValue;
        /* Date at which the participant last claimed FOREX */
        uint256 lastClaimDate;
    }

    event ParticipantAddressChanged(
        address indexed previous,
        address indexed current
    );

    constructor(
        address _FOREX,
        uint256 _vestingPeriod,
        uint256 _minimumClaimDelay,
        address[] memory participantAddresses,
        uint256[] memory initiallyClaimable,
        uint256[] memory vestedValues
    ) {
        // Assert that the minimum claim delay is greater than zero seconds.
        assert(_minimumClaimDelay > 0);
        // Assert that the vesting period is a multiple of the minimum delay.
        assert(_vestingPeriod % _minimumClaimDelay == 0);
        // Assert all array lengths match.
        uint256 length = participantAddresses.length;
        assert(length == initiallyClaimable.length);
        assert(length == vestedValues.length);
        // Initialise immutable variables.
        FOREX = _FOREX;
        vestingPeriod = _vestingPeriod;
        minimumClaimDelay = _minimumClaimDelay;
        uint256 _forexSupply = 0;
        // Initialise participants mapping.
        for (uint256 i = 0; i < length; i++) {
            participants[participantAddresses[i]] = Participant({
                claimable: initiallyClaimable[i],
                vestedValue: vestedValues[i],
                lastClaimDate: 0
            });
            _forexSupply += initiallyClaimable[i] + vestedValues[i];
        }
        forexSupply = _forexSupply;
    }

    /**
     * @dev Transfers claimable FOREX to participant.
     */
    function claim() external {
        require(isClaimable(), "Funds not yet claimable");
        Participant storage participant = participants[msg.sender];
        require(
            block.timestamp >= participant.lastClaimDate + minimumClaimDelay,
            "Must wait before next claim"
        );
        uint256 cutoffTime = getLastCutoffTime(msg.sender);
        uint256 claimable = _balanceOf(msg.sender, cutoffTime);
        if (claimable == 0) return;
        // Reset vesting period for accruing new FOREX.
        // This starts at the claim date and then is incremented in
        // a value multiple of minimumClaimDelay.
        participant.lastClaimDate = cutoffTime;
        // Clear initial claimable amount if claiming for the first time.
        if (participant.claimable > 0) participant.claimable = 0;
        // Transfer tokens.
        IERC20(FOREX).safeTransfer(msg.sender, claimable);
    }

    /**
     * @dev Returns the last valid claim date for a participant.
     *      The difference between this value and the participant's
     *      last claim date is the actual claimable amount that
     *      can be transferred so that the minimum delay also enforces
     *      a minimum FOREX claim granularity.
     * @param account The participant account to fetch the cutoff time for.
     */
    function getLastCutoffTime(address account) public view returns (uint256) {
        Participant storage participant = participants[account];
        uint256 lastClaimDate = getParticipantLastClaimDate(participant);
        uint256 elapsed = block.timestamp - lastClaimDate;
        uint256 remainder = elapsed % minimumClaimDelay;
        if (elapsed > remainder) {
            // At least one cutoff time has passed.
            return lastClaimDate + elapsed - remainder;
        } else {
            // Next cutoff time not yet reached.
            return lastClaimDate;
        }
    }

    /**
     * @dev Returns the parsed last claim date for a participant.
     *      Instead of returning the default date of zero, it returns
     *      the claim start date.
     * @param participant The storage pointer to a participant.
     */
    function getParticipantLastClaimDate(Participant storage participant)
        private
        view
        returns (uint256)
    {
        return
            participant.lastClaimDate > claimStartDate
                ? participant.lastClaimDate
                : claimStartDate;
    }

    /**
     * @dev Returns the accrued FOREX balance for an participant.
     *      This amount may not be fully claimable yet.
     * @param account The participant to fetch the balance for.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balanceOf(account, block.timestamp);
    }

    /**
     * @dev Returns the claimable FOREX balance for an participant.
     * @param account The participant to fetch the balance for.
     * @param cutoffTime The time to fetch the balance from.
     */
    function _balanceOf(address account, uint256 cutoffTime)
        public
        view
        returns (uint256)
    {
        if (!isClaimable()) return 0;
        Participant storage participant = participants[account];
        uint256 lastClaimed = getParticipantLastClaimDate(participant);
        uint256 vestingCompleteDate = claimStartDate + vestingPeriod;
        // Prevent elapsed from passing the vestingPeriod value.
        uint256 elapsed = cutoffTime > vestingCompleteDate
            ? vestingCompleteDate - lastClaimed
            : cutoffTime - lastClaimed;
        uint256 accrued = (participant.vestedValue * elapsed) / vestingPeriod;
        return participant.claimable + accrued;
    }

    /**
     * @dev Withdraws FOREX for the contract owner.
     * @param amount The amount of FOREX to withdraw.
     */
    function withdrawForex(uint256 amount) external onlyOwner {
        IERC20(FOREX).safeTransfer(msg.sender, amount);
    }

    /**
     * @dev Changes the address for a participant. The new address
     *      will be eligible to claim the currently claimable funds
     *      from the previous address, plus all the accrued funds
     *      until the end of the vesting period.
     * @param previous The previous participant address to be changed.
     * @param current The current participant address to be eligible for claims.
     */
    function changeParticipantAddress(address previous, address current)
        external
        onlyOwner
    {
        require(current != address(0), "Current address cannot be zero");
        require(previous != current, "Addresses are the same");
        Participant storage previousParticipant = participants[previous];
        require(
            doesParticipantExist(previousParticipant),
            "Previous participant does not exist"
        );
        Participant storage currentParticipant = participants[current];
        require(
            !doesParticipantExist(currentParticipant),
            "Next participant already exists"
        );
        currentParticipant.claimable = previousParticipant.claimable;
        currentParticipant.vestedValue = previousParticipant.vestedValue;
        currentParticipant.lastClaimDate = previousParticipant.lastClaimDate;
        delete participants[previous];
        emit ParticipantAddressChanged(previous, current);
    }

    /**
     * @dev Returns whether the participant exists.
     * @param participant Pointer to the participant object.
     */
    function doesParticipantExist(Participant storage participant)
        private
        view
        returns (bool)
    {
        return participant.claimable > 0 || participant.vestedValue > 0;
    }

    /**
     * @dev Enables FOREX claiming from the next block.
     *      Can only be called once.
     */
    function enableForexClaims() public onlyOwner {
        assert(claimStartDate == 0);
        claimStartDate = block.timestamp + 1;
    }

    /**
     * Returns whether the contract is currently claimable.
     */
    function isClaimable() private view returns (bool) {
        return claimStartDate != 0 && block.timestamp >= claimStartDate;
    }
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
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

{
  "optimizer": {
    "enabled": false,
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