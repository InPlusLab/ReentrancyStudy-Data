// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";
import "./interfaces/ISmartWalletImplementation.sol";
import "./SmartWalletStorage.sol";
import "./swap/ISwap.sol";
import "./lending/ILending.sol";

contract SmartWalletImplementation is SmartWalletStorage, ISmartWalletImplementation {
    using SafeERC20 for IERC20Ext;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    event ApprovedAllowances(IERC20Ext[] tokens, address[] spenders, bool isReset);
    event ClaimedPlatformFees(address[] wallets, IERC20Ext[] tokens, address claimer);

    constructor(address _admin) SmartWalletStorage(_admin) {}

    receive() external payable {}

    /// Claim fee to platform wallets
    function claimPlatformFees(address[] calldata platformWallets, IERC20Ext[] calldata tokens)
        external
        override
        nonReentrant
    {
        for (uint256 i = 0; i < platformWallets.length; i++) {
            for (uint256 j = 0; j < tokens.length; j++) {
                uint256 fee = platformWalletFees[platformWallets[i]][tokens[j]];
                if (fee > 1) {
                    // fee set to 1 to avoid the SSTORE initial gas cost
                    platformWalletFees[platformWallets[i]][tokens[j]] = 1;
                    transferToken(payable(platformWallets[i]), tokens[j], fee - 1);
                }
            }
        }
        emit ClaimedPlatformFees(platformWallets, tokens, msg.sender);
    }

    /// @dev approve/unapprove LPs usage on the particular tokens
    function approveAllowances(
        IERC20Ext[] calldata tokens,
        address[] calldata spenders,
        bool isReset
    ) external onlyAdmin {
        uint256 allowance = isReset ? 0 : MAX_ALLOWANCE;
        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = 0; j < spenders.length; j++) {
                tokens[i].safeApprove(spenders[j], allowance);
            }
            getSetDecimals(tokens[i]);
        }

        emit ApprovedAllowances(tokens, spenders, isReset);
    }

    /// @dev get expected return including the fee
    /// @return destAmount expected dest amount
    /// @return expectedRate expected swap rate
    function getExpectedReturn(ISmartWalletImplementation.GetExpectedReturnParams calldata params)
        external
        view
        override
        returns (uint256 destAmount, uint256 expectedRate)
    {
        if (params.feeBps >= BPS) return (0, 0); // platform fee is too high

        uint256 actualSrc = (params.feeMode == FeeMode.FROM_SOURCE)
            ? (params.srcAmount * (BPS - params.feeBps)) / BPS
            : params.srcAmount;

        destAmount = ISwap(params.swapContract).getExpectedReturn(
            ISwap.GetExpectedReturnParams({
                srcAmount: actualSrc,
                tradePath: params.tradePath,
                feeBps: params.feeMode == FeeMode.BY_PROTOCOL ? params.feeBps : 0,
                extraArgs: params.extraArgs
            })
        );

        if (params.feeMode == FeeMode.FROM_DEST) {
            destAmount = (destAmount * (BPS - params.feeBps)) / BPS;
        }

        expectedRate = calcRateFromQty(
            params.srcAmount,
            destAmount,
            getDecimals(IERC20Ext(params.tradePath[0])),
            getDecimals(IERC20Ext(params.tradePath[params.tradePath.length - 1]))
        );
    }

    /// @dev get expected in amount including the fee
    /// @return srcAmount expected aource amount
    /// @return expectedRate expected swap rate
    function getExpectedIn(ISmartWalletImplementation.GetExpectedInParams calldata params)
        external
        view
        override
        returns (uint256 srcAmount, uint256 expectedRate)
    {
        if (params.feeBps >= BPS) return (0, 0); // platform fee is too high

        uint256 actualDest = (params.feeMode == FeeMode.FROM_DEST)
            ? (params.destAmount * (BPS + params.feeBps)) / BPS
            : params.destAmount;

        try
            ISwap(params.swapContract).getExpectedIn(
                ISwap.GetExpectedInParams({
                    destAmount: actualDest,
                    tradePath: params.tradePath,
                    feeBps: params.feeMode == FeeMode.BY_PROTOCOL ? params.feeBps : 0,
                    extraArgs: params.extraArgs
                })
            )
        returns (uint256 newSrcAmount) {
            srcAmount = newSrcAmount;
        } catch Error(string memory reason) {
            require(compareStrings(reason, "getExpectedIn_notSupported"), reason);
            srcAmount = defaultGetExpectedIn(
                params.swapContract,
                ISwap.GetExpectedInParams({
                    destAmount: actualDest,
                    tradePath: params.tradePath,
                    feeBps: params.feeMode == FeeMode.BY_PROTOCOL ? params.feeBps : 0,
                    extraArgs: params.extraArgs
                })
            );
        }

        if (params.feeMode == FeeMode.FROM_SOURCE) {
            srcAmount = (srcAmount * (BPS + params.feeBps)) / BPS;
        }

        expectedRate = calcRateFromQty(
            srcAmount,
            params.destAmount,
            getDecimals(IERC20Ext(params.tradePath[0])),
            getDecimals(IERC20Ext(params.tradePath[params.tradePath.length - 1]))
        );
    }

    function defaultGetExpectedIn(address swapContract, ISwap.GetExpectedInParams memory params)
        private
        view
        returns (uint256 srcAmount)
    {
        uint8 srcDecimal = 18;
        if (params.tradePath[0] != address(ETH_TOKEN_ADDRESS)) {
            srcDecimal = IERC20Ext(params.tradePath[0]).decimals();
        }
        if (srcDecimal > 3) {
            srcDecimal = srcDecimal - 3;
        }
        srcAmount = 1 * (10**srcDecimal); // Use a 0.001 as base
        uint256 lastGoodSrcAmount = 0;
        for (uint256 i = 0; i < 10; i++) {
            try
                ISwap(swapContract).getExpectedReturn(
                    ISwap.GetExpectedReturnParams({
                        srcAmount: srcAmount,
                        tradePath: params.tradePath,
                        feeBps: params.feeBps,
                        extraArgs: params.extraArgs
                    })
                )
            returns (uint256 newDestAmount) {
                if (newDestAmount != 0) {
                    (lastGoodSrcAmount, srcAmount) = (
                        srcAmount,
                        (srcAmount * params.destAmount) / newDestAmount
                    );
                    continue;
                }
            } catch {}
            // If there's an error or newDestAmount == 0, try something closer to lastGoodSrcAmount
            srcAmount = (srcAmount + lastGoodSrcAmount) / 2;
        }

        // Precision check
        uint256 destAmount = ISwap(swapContract).getExpectedReturn(
            ISwap.GetExpectedReturnParams({
                srcAmount: srcAmount,
                tradePath: params.tradePath,
                feeBps: params.feeBps,
                extraArgs: params.extraArgs
            })
        );
        uint256 diff;
        if (destAmount > params.destAmount) {
            diff = destAmount - params.destAmount;
        } else {
            diff = params.destAmount - destAmount;
        }

        // Telerate a 5% difference
        require(diff < params.destAmount / 20, "getExpectedIn_noResult");
    }

    /// @dev swap using particular swap contract
    /// @return destAmount actual dest amount
    function swap(ISmartWalletImplementation.SwapParams calldata params)
        external
        payable
        override
        nonReentrant
        returns (uint256 destAmount)
    {
        destAmount = swapInternal(
            params.swapContract,
            params.srcAmount,
            params.minDestAmount,
            params.tradePath,
            msg.sender,
            params.feeMode,
            params.feeBps,
            params.platformWallet,
            params.extraArgs
        );

        emit Swap(
            msg.sender,
            params.swapContract,
            params.tradePath,
            params.srcAmount,
            destAmount,
            params.feeMode,
            params.feeBps,
            params.platformWallet
        );
    }

    /// @dev swap then deposit to platform
    ///     if tradePath has only 1 token, don't need to do swap
    /// @return destAmount actual dest amount
    function swapAndDeposit(ISmartWalletImplementation.SwapAndDepositParams calldata params)
        external
        payable
        override
        nonReentrant
        returns (uint256 destAmount)
    {
        require(params.tradePath.length >= 1, "invalid tradePath");
        require(supportedLendings.contains(params.lendingContract), "unsupported lending");

        if (params.tradePath.length == 1) {
            // just collect src token, no need to swap
            validateSourceAmount(params.tradePath[0], params.srcAmount);
            destAmount = safeTransferWithFee(
                msg.sender,
                params.lendingContract,
                params.tradePath[0],
                params.srcAmount,
                // Not taking lending fee
                0,
                params.platformWallet
            );
        } else {
            destAmount = swapInternal(
                params.swapContract,
                params.srcAmount,
                params.minDestAmount,
                params.tradePath,
                params.lendingContract,
                params.feeMode,
                params.feeBps,
                params.platformWallet,
                params.extraArgs
            );
        }

        // eth or token already transferred to the address
        ILending(params.lendingContract).depositTo(
            msg.sender,
            IERC20Ext(params.tradePath[params.tradePath.length - 1]),
            destAmount
        );

        emit SwapAndDeposit(
            msg.sender,
            params.swapContract,
            params.lendingContract,
            params.tradePath,
            params.srcAmount,
            destAmount,
            params.feeMode,
            params.feeBps,
            params.platformWallet
        );
    }

    /// @dev withdraw token from Lending platforms (AAVE, COMPOUND)
    /// @return returnedAmount returns the amount withdrawn to the user
    function withdrawFromLendingPlatform(
        ISmartWalletImplementation.WithdrawFromLendingPlatformParams calldata params
    ) external override nonReentrant returns (uint256 returnedAmount) {
        require(supportedLendings.contains(params.lendingContract), "unsupported lending");

        IERC20Ext lendingToken = IERC20Ext(
            ILending(params.lendingContract).getLendingToken(params.token)
        );
        require(lendingToken != IERC20Ext(0), "unsupported token");

        // AAVE aToken's transfer logic could have rounding errors
        uint256 tokenBalanceBefore = lendingToken.balanceOf(params.lendingContract);
        lendingToken.safeTransferFrom(msg.sender, params.lendingContract, params.amount);
        uint256 tokenBalanceAfter = lendingToken.balanceOf(params.lendingContract);

        returnedAmount = ILending(params.lendingContract).withdrawFrom(
            msg.sender,
            params.token,
            tokenBalanceAfter.sub(tokenBalanceBefore),
            params.minReturn
        );

        require(returnedAmount >= params.minReturn, "low returned amount");

        emit WithdrawFromLending(
            msg.sender,
            params.lendingContract,
            params.token,
            params.amount,
            params.minReturn,
            returnedAmount
        );
    }

    /// @dev swap and repay borrow for sender
    function swapAndRepay(ISmartWalletImplementation.SwapAndRepayParams calldata params)
        external
        payable
        override
        nonReentrant
        returns (uint256 destAmount)
    {
        require(params.tradePath.length >= 1, "invalid tradePath");
        require(supportedLendings.contains(params.lendingContract), "unsupported lending");

        // use user debt value if debt is <= payAmount
        // user can pay all debt by putting really high payAmount as param
        uint256 debt = ILending(params.lendingContract).getUserDebtCurrent(
            params.tradePath[params.tradePath.length - 1],
            msg.sender
        );
        uint256 actualPayAmount = debt >= params.payAmount ? params.payAmount : debt;

        if (params.tradePath.length == 1) {
            // just collect src token, no need to swap
            validateSourceAmount(params.tradePath[0], params.srcAmount);
            destAmount = safeTransferWithFee(
                msg.sender,
                params.lendingContract,
                params.tradePath[0],
                params.srcAmount,
                // Not taking repay fee
                0,
                params.platformWallet
            );
        } else {
            destAmount = swapInternal(
                params.swapContract,
                params.srcAmount,
                actualPayAmount,
                params.tradePath,
                params.lendingContract,
                params.feeMode,
                params.feeBps,
                params.platformWallet,
                params.extraArgs
            );
        }
        ILending(params.lendingContract).repayBorrowTo(
            msg.sender,
            IERC20Ext(params.tradePath[params.tradePath.length - 1]),
            destAmount,
            actualPayAmount,
            abi.encodePacked(params.rateMode)
        );

        uint256 actualDebtPaid = debt.sub(
            ILending(params.lendingContract).getUserDebtCurrent(
                params.tradePath[params.tradePath.length - 1],
                msg.sender
            )
        );
        require(actualDebtPaid >= actualPayAmount, "low paid amount");

        emit SwapAndRepay(
            msg.sender,
            params.swapContract,
            params.lendingContract,
            params.tradePath,
            params.srcAmount,
            destAmount,
            actualPayAmount,
            params.feeMode,
            params.feeBps,
            params.platformWallet
        );
    }

    function swapInternal(
        address payable swapContract,
        uint256 srcAmount,
        uint256 minDestAmount,
        address[] calldata tradePath,
        address payable recipient,
        FeeMode feeMode,
        uint256 platformFee,
        address payable platformWallet,
        bytes calldata extraArgs
    ) internal returns (uint256 destAmount) {
        require(supportedSwaps.contains(swapContract), "unsupported swap");
        require(tradePath.length >= 2, "invalid tradePath");
        require(platformFee < BPS, "high platform fee");

        validateSourceAmount(tradePath[0], srcAmount);

        uint256 actualSrcAmount = safeTransferWithFee(
            msg.sender,
            swapContract,
            tradePath[0],
            srcAmount,
            feeMode == FeeMode.FROM_SOURCE ? platformFee : 0,
            platformWallet
        );

        {
            // to avoid stack too deep
            // who will receive the swapped token
            address _recipient = feeMode == FeeMode.FROM_DEST ? address(this) : recipient;
            destAmount = ISwap(swapContract).swap(
                ISwap.SwapParams({
                    srcAmount: actualSrcAmount,
                    minDestAmount: minDestAmount,
                    tradePath: tradePath,
                    recipient: _recipient,
                    feeBps: feeMode == FeeMode.BY_PROTOCOL ? platformFee : 0,
                    feeReceiver: platformWallet,
                    extraArgs: extraArgs
                })
            );
        }

        if (feeMode == FeeMode.FROM_DEST) {
            destAmount = safeTransferWithFee(
                address(this),
                recipient,
                tradePath[tradePath.length - 1],
                destAmount,
                platformFee,
                platformWallet
            );
        }

        require(destAmount >= minDestAmount, "low return");
    }

    function validateSourceAmount(address srcToken, uint256 srcAmount) internal {
        if (srcToken == address(ETH_TOKEN_ADDRESS)) {
            require(msg.value == srcAmount, "wrong msg value");
        } else {
            require(msg.value == 0, "bad msg value");
        }
    }

    function transferToken(
        address payable to,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (amount == 0) return;
        if (token == ETH_TOKEN_ADDRESS) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "transfer failed");
        } else {
            token.safeTransfer(to, amount);
        }
    }

    function safeTransferWithFee(
        address payable from,
        address payable to,
        address token,
        uint256 amount,
        uint256 platformFeeBps,
        address payable platformWallet
    ) internal returns (uint256 amountTransferred) {
        uint256 fee = amount.mul(platformFeeBps).div(BPS);
        uint256 amountAfterFee = amount.sub(fee);
        IERC20Ext tokenErc = IERC20Ext(token);

        if (tokenErc == ETH_TOKEN_ADDRESS) {
            (bool success, ) = to.call{value: amountAfterFee}("");
            require(success, "transfer failed");
            amountTransferred = amountAfterFee;
        } else {
            uint256 balanceBefore = tokenErc.balanceOf(to);
            if (from != address(this)) {
                // case transfer from another address, need to transfer fee to this proxy contract
                tokenErc.safeTransferFrom(from, to, amountAfterFee);
                tokenErc.safeTransferFrom(from, address(this), fee);
            } else {
                tokenErc.safeTransfer(to, amountAfterFee);
            }
            amountTransferred = tokenErc.balanceOf(to).sub(balanceBefore);
        }

        addFeeToPlatform(platformWallet, tokenErc, fee);
    }

    function addFeeToPlatform(
        address payable platformWallet,
        IERC20Ext token,
        uint256 amount
    ) internal {
        if (amount > 0) {
            require(supportedPlatformWallets.contains(platformWallet), "unsupported platform");
            platformWalletFees[platformWallet][token] = platformWalletFees[platformWallet][token]
            .add(amount);
        }
    }

    function compareStrings(string memory a, string memory b) private view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
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

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
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
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
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
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
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
        return address(uint160(uint256(_at(set._inner, index))));
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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/**
 * @dev Interface extending ERC20 standard to include decimals() as
 *      it is optional in the OpenZeppelin IERC20 interface.
 */
interface IERC20Ext is IERC20 {
    /**
     * @dev This function is required as Kyber requires to interact
     *      with token.decimals() with many of its operations.
     */
    function decimals() external view returns (uint8 digits);
}

pragma solidity 0.7.6;
pragma abicoder v2;

import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";

interface ISmartWalletImplementation {
    enum FeeMode {
        FROM_SOURCE,
        FROM_DEST,
        BY_PROTOCOL
    }

    event Swap(
        address indexed trader,
        address indexed swapContract,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        FeeMode feeMode,
        uint256 feeBps,
        address platformWallet
    );

    event SwapAndDeposit(
        address indexed trader,
        address indexed swapContract,
        address indexed lendingContract,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        FeeMode feeMode,
        uint256 feeBps,
        address platformWallet
    );

    event WithdrawFromLending(
        address indexed trader,
        address indexed lendingContract,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn,
        uint256 actualReturnAmount
    );

    event SwapAndRepay(
        address indexed trader,
        address indexed swapContract,
        address indexed lendingContract,
        address[] tradePath,
        uint256 srcAmount,
        uint256 destAmount,
        uint256 payAmount,
        FeeMode feeMode,
        uint256 feeBps,
        address platformWallet
    );

    /// @param swapContract swap contract
    /// @param srcAmount amount of src token
    /// @param tradePath path of the trade on Uniswap
    /// @param platformFee fee if swapping feeMode = platformFee / BPS, feeBps = platformFee % BPS
    /// @param extraArgs extra data needed for swap on particular platforms
    struct GetExpectedReturnParams {
        address payable swapContract;
        uint256 srcAmount;
        address[] tradePath;
        FeeMode feeMode;
        uint256 feeBps;
        bytes extraArgs;
    }

    function getExpectedReturn(GetExpectedReturnParams calldata params)
        external
        view
        returns (uint256 destAmount, uint256 expectedRate);

    struct GetExpectedInParams {
        address payable swapContract;
        uint256 destAmount;
        address[] tradePath;
        FeeMode feeMode;
        uint256 feeBps;
        bytes extraArgs;
    }

    function getExpectedIn(GetExpectedInParams calldata params)
        external
        view
        returns (uint256 srcAmount, uint256 expectedRate);

    /// @param swapContract swap contract
    /// @param srcAmount amount of src token
    /// @param minDestAmount minimal accepted dest amount
    /// @param tradePath path of the trade on Uniswap
    /// @param feeMode fee mode
    /// @param feeBps fee bps
    /// @param platformWallet wallet to receive fee
    /// @param extraArgs extra data needed for swap on particular platforms
    struct SwapParams {
        address payable swapContract;
        uint256 srcAmount;
        uint256 minDestAmount;
        address[] tradePath;
        FeeMode feeMode;
        uint256 feeBps;
        address payable platformWallet;
        bytes extraArgs;
    }

    function swap(SwapParams calldata params) external payable returns (uint256 destAmount);

    /// @param swapContract swap contract
    /// @param lendingContract lending contract
    /// @param srcAmount amount of src token
    /// @param minDestAmount minimal accepted dest amount
    /// @param tradePath path of the trade on Uniswap
    /// @param feeMode fee mode
    /// @param feeBps fee bps
    /// @param platformWallet wallet to receive fee
    /// @param extraArgs extra data needed for swap on particular platforms
    struct SwapAndDepositParams {
        address payable swapContract;
        address payable lendingContract;
        uint256 srcAmount;
        uint256 minDestAmount;
        address[] tradePath;
        FeeMode feeMode;
        uint256 feeBps;
        address payable platformWallet;
        bytes extraArgs;
    }

    function swapAndDeposit(SwapAndDepositParams calldata params)
        external
        payable
        returns (uint256 destAmount);

    /// @param lendingContract lending contract to withdraw token
    /// @param token underlying token to withdraw, e.g ETH, USDT, DAI
    /// @param amount amount of cToken (COMPOUND) or aToken (AAVE) to withdraw
    /// @param minReturn minimum amount of underlying tokens to return
    struct WithdrawFromLendingPlatformParams {
        address payable lendingContract;
        IERC20Ext token;
        uint256 amount;
        uint256 minReturn;
    }

    function withdrawFromLendingPlatform(WithdrawFromLendingPlatformParams calldata params)
        external
        returns (uint256 returnedAmount);

    /// @param swapContract swap contract
    /// @param lendingContract lending contract
    /// @param srcAmount amount of src token
    /// @param payAmount: amount that user wants to pay, if the dest amount (after swap) is higher,
    ///     the remain amount will be sent back to user's wallet
    /// @param tradePath path of the trade on Uniswap
    /// @param rateMode rate mode for aave v2
    /// @param feeMode fee mode
    /// @param feeBps fee bps
    /// @param platformWallet wallet to receive fee
    /// @param extraArgs extra data needed for swap on particular platforms
    struct SwapAndRepayParams {
        address payable swapContract;
        address payable lendingContract;
        uint256 srcAmount;
        uint256 payAmount;
        address[] tradePath;
        uint256 rateMode; // for aave v2
        FeeMode feeMode;
        uint256 feeBps;
        address payable platformWallet;
        bytes extraArgs;
    }

    function swapAndRepay(SwapAndRepayParams calldata params)
        external
        payable
        returns (uint256 destAmount);

    function claimPlatformFees(address[] calldata platformWallets, IERC20Ext[] calldata tokens)
        external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;

import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";
import "@kyber.network/utils-sc/contracts/Utils.sol";
import "@kyber.network/utils-sc/contracts/Withdrawable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";

contract SmartWalletStorage is Utils, Withdrawable, ReentrancyGuard {
    uint256 internal constant MAX_AMOUNT = type(uint256).max;

    mapping(address => mapping(IERC20Ext => uint256)) public platformWalletFees;

    EnumerableSet.AddressSet internal supportedPlatformWallets;
    
    EnumerableSet.AddressSet internal supportedSwaps;

    EnumerableSet.AddressSet internal supportedLendings;

    // [EIP-1967] bytes32(uint256(keccak256("SmartWalletImplementation")) - 1)
    bytes32 internal constant IMPLEMENTATION =
        0x7cf58d76330f82325c2a503c72b55abca3eb533fadde43d95e3c0cceb1583e99;

    constructor(address _admin) Withdrawable(_admin) {}
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma abicoder v2;

interface ISwap {
    struct GetExpectedReturnParams {
        uint256 srcAmount;
        address[] tradePath;
        uint256 feeBps;
        bytes extraArgs;
    }

    function getExpectedReturn(GetExpectedReturnParams calldata params)
        external
        view
        returns (uint256 destAmount);

    struct GetExpectedInParams {
        uint256 destAmount;
        address[] tradePath;
        uint256 feeBps;
        bytes extraArgs;
    }

    function getExpectedIn(GetExpectedInParams calldata params)
        external
        view
        returns (uint256 srcAmount);

    struct SwapParams {
        uint256 srcAmount;
        // min return for uni, min conversionrate for kyber, etc.
        uint256 minDestAmount;
        address[] tradePath;
        address recipient;
        uint256 feeBps;
        address payable feeReceiver;
        bytes extraArgs;
    }

    function swap(SwapParams calldata params) external payable returns (uint256 destAmount);
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "@kyber.network/utils-sc/contracts/IERC20Ext.sol";

interface ILending {
    function depositTo(
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount
    ) external;

    function withdrawFrom(
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 minReturn
    ) external returns (uint256 returnedAmount);

    function repayBorrowTo(
        address payable onBehalfOf,
        IERC20Ext token,
        uint256 amount,
        uint256 payAmount,
        bytes calldata extraArgs // for extra data .i.e aave rateMode
    ) external;

    function getUserDebtCurrent(address _reserve, address _user) external returns (uint256 debt);

    function getLendingToken(IERC20Ext token) external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IERC20Ext.sol";


/**
 * @title Kyber utility file
 * mostly shared constants and rate calculation helpers
 * inherited by most of kyber contracts.
 * previous utils implementations are for previous solidity versions.
 */
abstract contract Utils {
    // Declared constants below to be used in tandem with
    // getDecimalsConstant(), for gas optimization purposes
    // which return decimals from a constant list of popular
    // tokens.
    IERC20Ext internal constant ETH_TOKEN_ADDRESS = IERC20Ext(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    IERC20Ext internal constant USDT_TOKEN_ADDRESS = IERC20Ext(
        0xdAC17F958D2ee523a2206206994597C13D831ec7
    );
    IERC20Ext internal constant DAI_TOKEN_ADDRESS = IERC20Ext(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
    IERC20Ext internal constant USDC_TOKEN_ADDRESS = IERC20Ext(
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
    );
    IERC20Ext internal constant WBTC_TOKEN_ADDRESS = IERC20Ext(
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
    );
    IERC20Ext internal constant KNC_TOKEN_ADDRESS = IERC20Ext(
        0xdd974D5C2e2928deA5F71b9825b8b646686BD200
    );
    uint256 public constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20Ext => uint256) internal decimals;

    /// @dev Sets the decimals of a token to storage if not already set, and returns
    ///      the decimals value of the token. Prefer using this function over
    ///      getDecimals(), to avoid forgetting to set decimals in local storage.
    /// @param token The token type
    /// @return tokenDecimals The decimals of the token
    function getSetDecimals(IERC20Ext token) internal returns (uint256 tokenDecimals) {
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }
    }

    /// @dev Get the balance of a user
    /// @param token The token type
    /// @param user The user's address
    /// @return The balance
    function getBalance(IERC20Ext token, address user) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    /// @dev Get the decimals of a token, read from the constant list, storage,
    ///      or from token.decimals(). Prefer using getSetDecimals when possible.
    /// @param token The token type
    /// @return tokenDecimals The decimals of the token
    function getDecimals(IERC20Ext token) internal view returns (uint256 tokenDecimals) {
        // return token decimals if has constant value
        tokenDecimals = getDecimalsConstant(token);
        if (tokenDecimals > 0) return tokenDecimals;

        // handle case where token decimals is not a declared decimal constant
        tokenDecimals = decimals[token];
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        return (tokenDecimals > 0) ? tokenDecimals : token.decimals();
    }

    function calcDestAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20Ext src,
        IERC20Ext dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        //source quantity is rounded up. to avoid dest quantity being too low.
        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    /// @dev save storage access by declaring token decimal constants
    /// @param token The token type
    /// @return token decimals
    function getDecimalsConstant(IERC20Ext token) internal pure returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return ETH_DECIMALS;
        } else if (token == USDT_TOKEN_ADDRESS) {
            return 6;
        } else if (token == DAI_TOKEN_ADDRESS) {
            return 18;
        } else if (token == USDC_TOKEN_ADDRESS) {
            return 6;
        } else if (token == WBTC_TOKEN_ADDRESS) {
            return 8;
        } else if (token == KNC_TOKEN_ADDRESS) {
            return 18;
        } else {
            return 0;
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./IERC20Ext.sol";
import "./PermissionAdmin.sol";


abstract contract Withdrawable is PermissionAdmin {
    using SafeERC20 for IERC20Ext;

    event TokenWithdraw(IERC20Ext token, uint256 amount, address sendTo);
    event EtherWithdraw(uint256 amount, address sendTo);

    constructor(address _admin) PermissionAdmin(_admin) {}

    /**
     * @dev Withdraw all IERC20Ext compatible tokens
     * @param token IERC20Ext The address of the token contract
     */
    function withdrawToken(
        IERC20Ext token,
        uint256 amount,
        address sendTo
    ) external onlyAdmin {
        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    /**
     * @dev Withdraw Ethers
     */
    function withdrawEther(uint256 amount, address payable sendTo) external onlyAdmin {
        (bool success, ) = sendTo.call{value: amount}("");
        require(success, "withdraw failed");
        emit EtherWithdraw(amount, sendTo);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract ReentrancyGuard {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;


abstract contract PermissionAdmin {
    address public admin;
    address public pendingAdmin;

    event AdminClaimed(address newAdmin, address previousAdmin);

    event TransferAdminPending(address pendingAdmin);

    constructor(address _admin) {
        require(_admin != address(0), "admin 0");
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "new admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    /**
     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }
}

{
  "optimizer": {
    "enabled": true,
    "runs": 780
  },
  "metadata": {
    "bytecodeHash": "none"
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