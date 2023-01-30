/**
 *Submitted for verification at Etherscan.io on 2019-07-13
*/

/*

    Copyright 2019 dYdX Trading Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/external/0x/v2/libs/LibOrder.sol

contract LibOrder
{
    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's state is unaffected by external factors, like account balances.
    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FULLY_FILLED,                // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }
}

// File: contracts/external/0x/v2/libs/LibFillResults.sol

contract LibFillResults
{
    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    struct MatchedFillResults {
        FillResults left;                    // Amounts filled and fees paid of left order.
        FillResults right;                   // Amounts filled and fees paid of right order.
        uint256 leftMakerAssetSpreadAmount;  // Spread between price of left and right order, denominated in the left order's makerAsset, paid to taker.
    }
}

// File: contracts/external/0x/v2/interfaces/IExchangeCore.sol

contract IExchangeCore {

    /// @dev Cancels all orders created by makerAddress with a salt less than or equal to the targetOrderEpoch
    ///      and senderAddress equal to msg.sender (or null address if msg.sender == makerAddress).
    /// @param targetOrderEpoch Orders created with a salt less or equal to this value will be cancelled.
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external;

    /// @dev Fills the input order.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev After calling, the order can not be filled anymore.
    /// @param order Order struct containing order specifications.
    function cancelOrder(LibOrder.Order memory order)
        public;

    /// @dev Gets information about an order: status, hash, and amount filled.
    /// @param order Order to gather information on.
    /// @return OrderInfo Information about the order and its state.
    ///                   See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);
}

// File: contracts/external/0x/v2/interfaces/IMatchOrders.sol

contract IMatchOrders {

    /// @dev Match two complementary orders that have a profitable spread.
    ///      Each order is filled at their respective price point. However, the calculations are
    ///      carried out as though the orders are both being filled at the right order's price point.
    ///      The profit made by the left order goes to the taker (who matched the two orders).
    /// @param leftOrder First order to match.
    /// @param rightOrder Second order to match.
    /// @param leftSignature Proof that order was created by the left maker.
    /// @param rightSignature Proof that order was created by the right maker.
    /// @return matchedFillResults Amounts filled and fees paid by maker and taker of matched orders.
    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);
}

// File: contracts/external/0x/v2/interfaces/ISignatureValidator.sol

contract ISignatureValidator {

    /// @dev Approves a hash on-chain using any valid signature type.
    ///      After presigning a hash, the preSign signature type will become valid for that hash and signer.
    /// @param signerAddress Address that should have signed the given hash.
    /// @param signature Proof that the hash has been signed by signer.
    function preSign(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature
    )
        external;

    /// @dev Approves/unnapproves a Validator contract to verify signatures on signer's behalf.
    /// @param validatorAddress Address of Validator contract.
    /// @param approval Approval or disapproval of  Validator contract.
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external;

    /// @dev Verifies that a signature is valid.
    /// @param hash Message hash that is signed.
    /// @param signerAddress Address of signer.
    /// @param signature Proof of signing.
    /// @return Validity of order signature.
    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);
}

// File: contracts/external/0x/v2/interfaces/ITransactions.sol

contract ITransactions {

    /// @dev Executes an exchange method call in the context of signer.
    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.
    /// @param signerAddress Address of transaction signer.
    /// @param data AbiV2 encoded calldata.
    /// @param signature Proof of signer transaction by signer.
    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes calldata data,
        bytes calldata signature
    )
        external;
}

// File: contracts/external/0x/v2/interfaces/IAssetProxyDispatcher.sol

contract IAssetProxyDispatcher {

    /// @dev Registers an asset proxy to its asset proxy id.
    ///      Once an asset proxy is registered, it cannot be unregistered.
    /// @param assetProxy Address of new asset proxy to register.
    function registerAssetProxy(address assetProxy)
        external;

    /// @dev Gets an asset proxy.
    /// @param assetProxyId Id of the asset proxy.
    /// @return The asset proxy registered to assetProxyId. Returns 0x0 if no proxy is registered.
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);
}

// File: contracts/external/0x/v2/interfaces/IWrapperFunctions.sol

contract IWrapperFunctions {

    /// @dev Fills the input order. Reverts if exact takerAssetFillAmount not filled.
    /// @param order LibOrder.Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev Fills an order with specified parameters and ECDSA signature.
    ///      Returns false if the transaction would otherwise revert.
    /// @param order LibOrder.Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev Synchronously executes multiple calls of fillOrder.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrKill.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Fills an order with specified parameters and ECDSA signature.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketSellOrders(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of makerAsset is bought by taker.
    /// @param orders Array of order specifications.
    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketBuyOrders(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple fill orders in a single transaction until total amount is bought by taker.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously cancels multiple orders in a single transaction.
    /// @param orders Array of order specifications.
    function batchCancelOrders(LibOrder.Order[] memory orders)
        public;

    /// @dev Fetches information for all passed in orders
    /// @param orders Array of order specifications.
    /// @return Array of OrderInfo instances that correspond to each order.
    function getOrdersInfo(LibOrder.Order[] memory orders)
        public
        view
        returns (LibOrder.OrderInfo[] memory);
}

// File: contracts/external/0x/v2/interfaces/IExchange.sol

// solhint-disable no-empty-blocks
contract IExchange is
    IExchangeCore,
    IMatchOrders,
    ISignatureValidator,
    ITransactions,
    IAssetProxyDispatcher,
    IWrapperFunctions
{}

// File: contracts/interfaces/ExchangeWrapper.sol

/**
 * @title ExchangeWrapper
 * @author dYdX
 *
 * Contract interface that Exchange Wrapper smart contracts must implement in order to interface
 * with other smart contracts through a common interface.
 */
interface ExchangeWrapper {

    // ============ Public Functions ============

    /**
     * Exchange some amount of takerToken for makerToken.
     *
     * @param  tradeOriginator      Address of the initiator of the trade (however, this value
     *                              cannot always be trusted as it is set at the discretion of the
     *                              msg.sender)
     * @param  receiver             Address to set allowance on once the trade has completed
     * @param  makerToken           Address of makerToken, the token to receive
     * @param  takerToken           Address of takerToken, the token to pay
     * @param  requestedFillAmount  Amount of takerToken being paid
     * @param  orderData            Arbitrary bytes data for any information to pass to the exchange
     * @return                      The amount of makerToken received
     */
    function exchange(
        address tradeOriginator,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256);

    /**
     * Get amount of takerToken required to buy a certain amount of makerToken for a given trade.
     * Should match the takerToken amount used in exchangeForAmount. If the order cannot provide
     * exactly desiredMakerToken, then it must return the price to buy the minimum amount greater
     * than desiredMakerToken
     *
     * @param  makerToken         Address of makerToken, the token to receive
     * @param  takerToken         Address of takerToken, the token to pay
     * @param  desiredMakerToken  Amount of makerToken requested
     * @param  orderData          Arbitrary bytes data for any information to pass to the exchange
     * @return                    Amount of takerToken the needed to complete the transaction
     */
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256);
}

// File: contracts/lib/MathHelpers.sol

/**
 * @title MathHelpers
 * @author dYdX
 *
 * This library helps with common math functions in Solidity
 */
library MathHelpers {
    using SafeMath for uint256;

    /**
     * Calculates partial value given a numerator and denominator.
     *
     * @param  numerator    Numerator
     * @param  denominator  Denominator
     * @param  target       Value to calculate partial of
     * @return              target * numerator / denominator
     */
    function getPartialAmount(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {
        return numerator.mul(target).div(denominator);
    }

    /**
     * Calculates partial value given a numerator and denominator, rounded up.
     *
     * @param  numerator    Numerator
     * @param  denominator  Denominator
     * @param  target       Value to calculate partial of
     * @return              Rounded-up result of target * numerator / denominator
     */
    function getPartialAmountRoundedUp(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {
        return divisionRoundedUp(numerator.mul(target), denominator);
    }

    /**
     * Calculates division given a numerator and denominator, rounded up.
     *
     * @param  numerator    Numerator.
     * @param  denominator  Denominator.
     * @return              Rounded-up result of numerator / denominator
     */
    function divisionRoundedUp(
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {
        assert(denominator != 0); // coverage-enable-line
        if (numerator == 0) {
            return 0;
        }
        return numerator.sub(1).div(denominator).add(1);
    }

    /**
     * Calculates and returns the maximum value for a uint256 in solidity
     *
     * @return  The maximum value for uint256
     */
    function maxUint256(
    )
        internal
        pure
        returns (uint256)
    {
        return 2 ** 256 - 1;
    }

    /**
     * Calculates and returns the maximum value for a uint256 in solidity
     *
     * @return  The maximum value for uint256
     */
    function maxUint32(
    )
        internal
        pure
        returns (uint32)
    {
        return 2 ** 32 - 1;
    }

    /**
     * Returns the number of bits in a uint256. That is, the lowest number, x, such that n >> x == 0
     *
     * @param  n  The uint256 to get the number of bits in
     * @return    The number of bits in n
     */
    function getNumBits(
        uint256 n
    )
        internal
        pure
        returns (uint256)
    {
        uint256 first = 0;
        uint256 last = 256;
        while (first < last) {
            uint256 check = (first + last) / 2;
            if ((n >> check) == 0) {
                last = check;
            } else {
                first = check + 1;
            }
        }
        assert(first <= 256);
        return first;
    }
}

// File: contracts/lib/GeneralERC20.sol

/**
 * @title GeneralERC20
 * @author dYdX
 *
 * Interface for using ERC20 Tokens. We have to use a special interface to call ERC20 functions so
 * that we dont automatically revert when calling non-compliant tokens that have no return value for
 * transfer(), transferFrom(), or approve().
 */
interface GeneralERC20 {
    function totalSupply(
    )
        external
        view
        returns (uint256);

    function balanceOf(
        address who
    )
        external
        view
        returns (uint256);

    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns (uint256);

    function transfer(
        address to,
        uint256 value
    )
        external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external;

    function approve(
        address spender,
        uint256 value
    )
        external;
}

// File: contracts/lib/TokenInteract.sol

/**
 * @title TokenInteract
 * @author dYdX
 *
 * This library contains basic functions for interacting with ERC20 tokens
 */
library TokenInteract {
    function balanceOf(
        address token,
        address owner
    )
        internal
        view
        returns (uint256)
    {
        return GeneralERC20(token).balanceOf(owner);
    }

    function allowance(
        address token,
        address owner,
        address spender
    )
        internal
        view
        returns (uint256)
    {
        return GeneralERC20(token).allowance(owner, spender);
    }

    function approve(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        GeneralERC20(token).approve(spender, amount);

        require(
            checkSuccess(),
            "TokenInteract#approve: Approval failed"
        );
    }

    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {
        address from = address(this);
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transfer(to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transfer: Transfer failed"
        );
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        if (
            amount == 0
            || from == to
        ) {
            return;
        }

        GeneralERC20(token).transferFrom(from, to, amount);

        require(
            checkSuccess(),
            "TokenInteract#transferFrom: TransferFrom failed"
        );
    }

    // ============ Private Helper-Functions ============

    /**
     * Checks the return value of the previous function up to 32 bytes. Returns true if the previous
     * function returned 0 bytes or 32 bytes that are not all-zero.
     */
    function checkSuccess(
    )
        private
        pure
        returns (bool)
    {
        uint256 returnValue = 0;

        /* solium-disable-next-line security/no-inline-assembly */
        assembly {
            // check number of bytes returned from last function call
            switch returndatasize

            // no bytes returned: assume success
            case 0x0 {
                returnValue := 1
            }

            // 32 bytes returned: check if non-zero
            case 0x20 {
                // copy 32 bytes into scratch space
                returndatacopy(0x0, 0x0, 0x20)

                // load those bytes into returnValue
                returnValue := mload(0x0)
            }

            // not sure what was returned: dont mark as success
            default { }
        }

        return returnValue != 0;
    }
}

// File: contracts/lib/AdvancedTokenInteract.sol

/**
 * @title AdvancedTokenInteract
 * @author dYdX
 *
 * This library contains advanced functions for interacting with ERC20 tokens
 */
library AdvancedTokenInteract {
    using TokenInteract for address;

    /**
     * Checks if the spender has some amount of allowance. If it doesn't, then set allowance at
     * the maximum value.
     *
     * @param  token    Address of the ERC20 token
     * @param  spender  Argument of the allowance function
     * @param  amount   The minimum amount of allownce the the spender should be guaranteed
     */
    function ensureAllowance(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {
        if (token.allowance(address(this), spender) < amount) {
            token.approve(spender, MathHelpers.maxUint256());
        }
    }
}

// File: contracts/exchange-wrappers/ZeroExV2MultiOrderExchangeWrapper.sol

/**
 * @title ZeroExV2MultiOrderExchangeWrapper
 * @author dYdX
 *
 * dYdX ExchangeWrapper to interface with 0x Version 2. Sends multiple orders at once. Assumes no
 * ZRX fees.
 */
contract ZeroExV2MultiOrderExchangeWrapper is
    LibFillResults,
    LibOrder,
    ExchangeWrapper
{
    using SafeMath for uint256;
    using TokenInteract for address;
    using AdvancedTokenInteract for address;

    // ============ Constants ============

    // number of bytes in the maxPrice data
    uint256 constant PRICE_DATA_LENGTH = 64;

    // number of bytes per (order + signature)
    uint256 constant ORDER_DATA_LENGTH = 322;

    // ============ Structs ============

    struct TokenAmounts {
        uint256 takerAmount;
        uint256 makerAmount;
    }

    struct TokenBalance {
        address owner;
        uint256 balance;
    }

    // ============ State Variables ============

    // address of the ZeroEx V2 Exchange
    address public ZERO_EX_EXCHANGE;

    // address of the ZeroEx V2 ERC20Proxy
    address public ZERO_EX_TOKEN_PROXY;

    // ============ Constructor ============

    constructor(
        address zeroExExchange,
        address zeroExProxy
    )
        public
    {
        ZERO_EX_EXCHANGE = zeroExExchange;
        ZERO_EX_TOKEN_PROXY = zeroExProxy;
    }

    // ============ Public Functions ============

    /**
     * Exchange some amount of takerToken for makerToken.
     *
     * @param  receiver             Address to set allowance on once the trade has completed
     * @param  makerToken           Address of makerToken, the token to receive
     * @param  takerToken           Address of takerToken, the token to pay
     * @param  requestedFillAmount  Amount of takerToken being paid
     * @param  orderData            Arbitrary bytes data for any information to pass to the exchange
     * @return                      The amount of makerToken received
     */
    function exchange(
        address /* tradeOriginator */,
        address receiver,
        address makerToken,
        address takerToken,
        uint256 requestedFillAmount,
        bytes calldata orderData
    )
        external
        returns (uint256)
    {
        // parse all order data
        validateOrderData(orderData);
        TokenAmounts memory priceRatio = parseMaxPriceRatio(orderData);
        Order[] memory orders = parseOrders(orderData, makerToken, takerToken);
        bytes[] memory signatures = parseSignatures(orderData);

        // ensure that the exchange can take the takerTokens from this contract
        takerToken.ensureAllowance(ZERO_EX_TOKEN_PROXY, requestedFillAmount);

        // do the exchange
        FillResults memory totalFillResults = IExchange(ZERO_EX_EXCHANGE).marketSellOrdersNoThrow(
            orders,
            requestedFillAmount,
            signatures
        );

        // validate that all taker tokens were sold
        require(
            totalFillResults.takerAssetFilledAmount == requestedFillAmount,
            "ZeroExV2MultiOrderExchangeWrapper#exchange: Cannot sell enough taker token"
        );

        // validate that max price is not violated
        validateTradePrice(
            priceRatio,
            totalFillResults.takerAssetFilledAmount,
            totalFillResults.makerAssetFilledAmount
        );

        // ensure that the caller can take the makerTokens from this contract
        makerToken.ensureAllowance(receiver, totalFillResults.makerAssetFilledAmount);

        return totalFillResults.makerAssetFilledAmount;
    }

    /**
     * Get amount of takerToken required to buy a certain amount of makerToken for a given trade.
     * Should match the takerToken amount used in exchangeForAmount. If the order cannot provide
     * exactly desiredMakerToken, then it must return the price to buy the minimum amount greater
     * than desiredMakerToken
     *
     * @param  makerToken         Address of makerToken, the token to receive
     * @param  takerToken         Address of takerToken, the token to pay
     * @param  desiredMakerToken  Amount of makerToken requested
     * @param  orderData          Arbitrary bytes data for any information to pass to the exchange
     * @return                    Amount of takerToken the needed to complete the transaction
     */
    function getExchangeCost(
        address makerToken,
        address takerToken,
        uint256 desiredMakerToken,
        bytes calldata orderData
    )
        external
        view
        returns (uint256)
    {
        // parse all orders
        validateOrderData(orderData);
        TokenAmounts memory priceRatio = parseMaxPriceRatio(orderData);
        Order[] memory orders = parseOrders(orderData, makerToken, takerToken);

        // keep running count of how much takerToken is needed until desiredMakerToken is acquired
        TokenAmounts memory total;
        total.takerAmount = 0;
        total.makerAmount = desiredMakerToken;

        // gets the exchange cost. modifies total
        uint256 takerCost = getExchangeCostInternal(
            makerToken,
            orders,
            total
        );

        // validate that max price will not be violated
        validateTradePrice(priceRatio, takerCost, desiredMakerToken);

        // return the amount of taker token needed
        return takerCost;
    }

    // ============ Private Functions ============

    /**
     * Gets the amount of takerToken required to fill the amount of total.makerToken.
     * Does not return a value, only modifies the values inside total.
     */
    function getExchangeCostInternal(
        address makerToken,
        Order[] memory orders,
        TokenAmounts memory total
    )
        private
        view
        returns (uint256)
    {
        // read exchange address from storage
        IExchange zeroExExchange = IExchange(ZERO_EX_EXCHANGE);

        // cache balances for makers
        TokenBalance[] memory balances = new TokenBalance[](orders.length);

        // for all orders
        for (uint256 i = 0; i < orders.length && total.makerAmount != 0; i++) {
            Order memory order = orders[i];

            // get order info
            OrderInfo memory info = zeroExExchange.getOrderInfo(order);

            // ignore unfillable orders
            if (info.orderStatus != uint8(OrderStatus.FILLABLE)) {
                continue;
            }

            // calculate the remaining available taker and maker amounts in the order
            TokenAmounts memory available;
            available.takerAmount = order.takerAssetAmount.sub(info.orderTakerAssetFilledAmount);
            available.makerAmount = MathHelpers.getPartialAmount(
                available.takerAmount,
                order.takerAssetAmount,
                order.makerAssetAmount
            );

            // bound the remaining available amounts by the maker amount still needed
            if (available.makerAmount > total.makerAmount) {
                available.makerAmount = total.makerAmount;
                available.takerAmount = MathHelpers.getPartialAmountRoundedUp(
                    order.takerAssetAmount,
                    order.makerAssetAmount,
                    available.makerAmount
                );
            }

            // ignore orders that the maker will not be able to fill
            if (!makerHasEnoughTokens(
                makerToken,
                balances,
                order.makerAddress,
                available.makerAmount)
            ) {
                continue;
            }

            // update the running tallies
            total.takerAmount = total.takerAmount.add(available.takerAmount);
            total.makerAmount = total.makerAmount.sub(available.makerAmount);
        }

        // require that entire amount was bought
        require(
            total.makerAmount == 0,
            "ZeroExV2MultiOrderExchangeWrapper#getExchangeCostInternal: Cannot buy enough maker token"
        );

        return total.takerAmount;
    }

    /**
     * Checks and modifies balances to keep track of the expected balance of the maker after filling
     * each order. Returns true if the maker has enough makerToken left to transfer amount.
     */
    function makerHasEnoughTokens(
        address makerToken,
        TokenBalance[] memory balances,
        address makerAddress,
        uint256 amount
    )
        private
        view
        returns (bool)
    {
        // find the maker's balance in the cache or the first non-populated balance in the cache
        TokenBalance memory current;
        uint256 i;
        for (i = 0; i < balances.length; i++) {
            current = balances[i];
            if (
                current.owner == address(0)
                || current.owner == makerAddress
            ) {
                break;
            }
        }

        // if the maker is already in the cache
        if (current.owner == makerAddress) {
            if (current.balance >= amount) {
                current.balance = current.balance.sub(amount);
                return true;
            } else {
                return false;
            }
        }

        // if the maker is not already in the cache
        else {
            uint256 startingBalance = makerToken.balanceOf(makerAddress);
            if (startingBalance >= amount) {
                balances[i] = TokenBalance({
                    owner: makerAddress,
                    balance: startingBalance.sub(amount)
                });
                return true;
            } else {
                balances[i] = TokenBalance({
                    owner: makerAddress,
                    balance: startingBalance
                });
                return false;
            }
        }
    }

    /**
     * Validates that a certain takerAmount and makerAmount are within the maxPrice bounds
     */
    function validateTradePrice(
        TokenAmounts memory priceRatio,
        uint256 takerAmount,
        uint256 makerAmount
    )
        private
        pure
    {
        require(
            priceRatio.makerAmount == 0 ||
            takerAmount.mul(priceRatio.makerAmount) <= makerAmount.mul(priceRatio.takerAmount),
            "ZeroExV2MultiOrderExchangeWrapper#validateTradePrice: Price greater than maxPrice"
        );
    }

    /**
     * Validates that there is at least one order in orderData and that the length is correct
     */
    function validateOrderData(
        bytes memory orderData
    )
        private
        pure
    {
        require(
            orderData.length >= PRICE_DATA_LENGTH + ORDER_DATA_LENGTH
            && orderData.length.sub(PRICE_DATA_LENGTH) % ORDER_DATA_LENGTH == 0,
            "ZeroExV2MultiOrderExchangeWrapper#validateOrderData: Invalid orderData length"
        );
    }

    /**
     * Returns the number of orders given in the orderData
     */
    function parseNumOrders(
        bytes memory orderData
    )
        private
        pure
        returns (uint256)
    {
        return orderData.length.sub(PRICE_DATA_LENGTH).div(ORDER_DATA_LENGTH);
    }

    /**
     * Gets the bit-offset of the index'th order in orderData
     */
    function getOrderDataOffset(
        uint256 index
    )
        private
        pure
        returns (uint256)
    {
        return PRICE_DATA_LENGTH.add(index.mul(ORDER_DATA_LENGTH));
    }

    /**
     * Parses the maximum price from orderData
     */
    function parseMaxPriceRatio(
        bytes memory orderData
    )
        private
        pure
        returns (TokenAmounts memory)
    {
        uint256 takerAmountRatio = 0;
        uint256 makerAmountRatio = 0;

        /* solium-disable-next-line security/no-inline-assembly */
        assembly {
            takerAmountRatio := mload(add(orderData, 32))
            makerAmountRatio := mload(add(orderData, 64))
        }

        // require numbers to fit within 128 bits to prevent overflow when checking bounds
        require(
            uint128(takerAmountRatio) == takerAmountRatio,
            "ZeroExV2MultiOrderExchangeWrapper#parseMaxPriceRatio: takerAmountRatio > 128 bits"
        );
        require(
            uint128(makerAmountRatio) == makerAmountRatio,
            "ZeroExV2MultiOrderExchangeWrapper#parseMaxPriceRatio: makerAmountRatio > 128 bits"
        );

        return TokenAmounts({
            takerAmount: takerAmountRatio,
            makerAmount: makerAmountRatio
        });
    }

    /**
     * Parses all signatures from orderData
     */
    function parseSignatures(
        bytes memory orderData
    )
        private
        pure
        returns (bytes[] memory)
    {
        uint256 numOrders = parseNumOrders(orderData);
        bytes[] memory signatures = new bytes[](numOrders);

        for (uint256 i = 0; i < numOrders; i++) {
            // allocate new memory and cache pointer to it
            signatures[i] = new bytes(66);
            bytes memory signature = signatures[i];

            uint256 dataOffset = getOrderDataOffset(i);

            /* solium-disable-next-line security/no-inline-assembly */
            assembly {
                mstore(add(signature, 32), mload(add(add(orderData, 288), dataOffset))) // first 32 bytes of sig
                mstore(add(signature, 64), mload(add(add(orderData, 320), dataOffset))) // next 32 bytes of sig
                mstore(add(signature, 66), mload(add(add(orderData, 322), dataOffset))) // last 2 bytes of sig
            }
        }

        return signatures;
    }

    /**
     * Parses all orders from orderData
     */
    function parseOrders(
        bytes memory orderData,
        address makerToken,
        address takerToken
    )
        private
        pure
        returns (Order[] memory)
    {
        uint256 numOrders = parseNumOrders(orderData);
        Order[] memory orders = new Order[](numOrders);

        bytes memory makerAssetData = tokenAddressToAssetData(makerToken);
        bytes memory takerAssetData = tokenAddressToAssetData(takerToken);

        for (uint256 i = 0; i < numOrders; i++) {
            // store pointer to order memory
            Order memory order = orders[i];

            order.makerFee = 0;
            order.takerFee = 0;
            order.makerAssetData = makerAssetData;
            order.takerAssetData = takerAssetData;

            uint256 dataOffset = getOrderDataOffset(i);

            /* solium-disable-next-line security/no-inline-assembly */
            assembly {
                mstore(order,           mload(add(add(orderData, 32), dataOffset)))  // makerAddress
                mstore(add(order, 32),  mload(add(add(orderData, 64), dataOffset)))  // takerAddress
                mstore(add(order, 64),  mload(add(add(orderData, 96), dataOffset)))  // feeRecipientAddress
                mstore(add(order, 96),  mload(add(add(orderData, 128), dataOffset))) // senderAddress
                mstore(add(order, 128), mload(add(add(orderData, 160), dataOffset))) // makerAssetAmount
                mstore(add(order, 160), mload(add(add(orderData, 192), dataOffset))) // takerAssetAmount
                mstore(add(order, 256), mload(add(add(orderData, 224), dataOffset))) // expirationTimeSeconds
                mstore(add(order, 288), mload(add(add(orderData, 256), dataOffset))) // salt
            }
        }

        return orders;
    }

    /**
     * Converts a token address to 0xV2 assetData
     */
    function tokenAddressToAssetData(
        address tokenAddress
    )
        private
        pure
        returns (bytes memory)
    {
        bytes memory result = new bytes(36);

        // padded version of bytes4(keccak256("ERC20Token(address)"));
        bytes32 selector = 0xf47261b000000000000000000000000000000000000000000000000000000000;

        /* solium-disable-next-line security/no-inline-assembly */
        assembly {
            // Store the selector and address in the asset data
            // The first 32 bytes of an array are the length (already set above)
            mstore(add(result, 32), selector)
            mstore(add(result, 36), tokenAddress)
        }

        return result;
    }
}