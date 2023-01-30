/**
 *Submitted for verification at Etherscan.io on 2019-12-28
*/

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.6.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/IRelayRecipient.sol

pragma solidity ^0.5.0;

/**
 * @dev Base interface for a contract that will be called via the GSN from {IRelayHub}.
 *
 * TIP: You don't need to write an implementation yourself! Inherit from {GSNRecipient} instead.
 */
contract IRelayRecipient {
    /**
     * @dev Returns the address of the {IRelayHub} instance this recipient interacts with.
     */
    function getHubAddr() public view returns (address);

    /**
     * @dev Called by {IRelayHub} to validate if this recipient accepts being charged for a relayed call. Note that the
     * recipient will be charged regardless of the execution result of the relayed call (i.e. if it reverts or not).
     *
     * The relay request was originated by `from` and will be served by `relay`. `encodedFunction` is the relayed call
     * calldata, so its first four bytes are the function selector. The relayed call will be forwarded `gasLimit` gas,
     * and the transaction executed with a gas price of at least `gasPrice`. `relay`'s fee is `transactionFee`, and the
     * recipient will be charged at most `maxPossibleCharge` (in wei). `nonce` is the sender's (`from`) nonce for
     * replay attack protection in {IRelayHub}, and `approvalData` is a optional parameter that can be used to hold a signature
     * over all or some of the previous values.
     *
     * Returns a tuple, where the first value is used to indicate approval (0) or rejection (custom non-zero error code,
     * values 1 to 10 are reserved) and the second one is data to be passed to the other {IRelayRecipient} functions.
     *
     * {acceptRelayedCall} is called with 50k gas: if it runs out during execution, the request will be considered
     * rejected. A regular revert will also trigger a rejection.
     */
    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
        external
        view
        returns (uint256, bytes memory);

    /**
     * @dev Called by {IRelayHub} on approved relay call requests, before the relayed call is executed. This allows to e.g.
     * pre-charge the sender of the transaction.
     *
     * `context` is the second value returned in the tuple by {acceptRelayedCall}.
     *
     * Returns a value to be passed to {postRelayedCall}.
     *
     * {preRelayedCall} is called with 100k gas: if it runs out during exection or otherwise reverts, the relayed call
     * will not be executed, but the recipient will still be charged for the transaction's cost.
     */
    function preRelayedCall(bytes calldata context) external returns (bytes32);

    /**
     * @dev Called by {IRelayHub} on approved relay call requests, after the relayed call is executed. This allows to e.g.
     * charge the user for the relayed call costs, return any overcharges from {preRelayedCall}, or perform
     * contract-specific bookkeeping.
     *
     * `context` is the second value returned in the tuple by {acceptRelayedCall}. `success` is the execution status of
     * the relayed call. `actualCharge` is an estimate of how much the recipient will be charged for the transaction,
     * not including any gas used by {postRelayedCall} itself. `preRetVal` is {preRelayedCall}'s return value.
     *
     *
     * {postRelayedCall} is called with 100k gas: if it runs out during execution or otherwise reverts, the relayed call
     * and the call to {preRelayedCall} will be reverted retroactively, but the recipient will still be charged for the
     * transaction's cost.
     */
    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/IRelayHub.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface for `RelayHub`, the core contract of the GSN. Users should not need to interact with this contract
 * directly.
 *
 * See the https://github.com/OpenZeppelin/openzeppelin-gsn-helpers[OpenZeppelin GSN helpers] for more information on
 * how to deploy an instance of `RelayHub` on your local test network.
 */
contract IRelayHub {
    // Relay management

    /**
     * @dev Adds stake to a relay and sets its `unstakeDelay`. If the relay does not exist, it is created, and the caller
     * of this function becomes its owner. If the relay already exists, only the owner can call this function. A relay
     * cannot be its own owner.
     *
     * All Ether in this function call will be added to the relay's stake.
     * Its unstake delay will be assigned to `unstakeDelay`, but the new value must be greater or equal to the current one.
     *
     * Emits a {Staked} event.
     */
    function stake(address relayaddr, uint256 unstakeDelay) external payable;

    /**
     * @dev Emitted when a relay's stake or unstakeDelay are increased
     */
    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    /**
     * @dev Registers the caller as a relay.
     * The relay must be staked for, and not be a contract (i.e. this function must be called directly from an EOA).
     *
     * This function can be called multiple times, emitting new {RelayAdded} events. Note that the received
     * `transactionFee` is not enforced by {relayCall}.
     *
     * Emits a {RelayAdded} event.
     */
    function registerRelay(uint256 transactionFee, string memory url) public;

    /**
     * @dev Emitted when a relay is registered or re-registerd. Looking at these events (and filtering out
     * {RelayRemoved} events) lets a client discover the list of available relays.
     */
    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    /**
     * @dev Removes (deregisters) a relay. Unregistered (but staked for) relays can also be removed.
     *
     * Can only be called by the owner of the relay. After the relay's `unstakeDelay` has elapsed, {unstake} will be
     * callable.
     *
     * Emits a {RelayRemoved} event.
     */
    function removeRelayByOwner(address relay) public;

    /**
     * @dev Emitted when a relay is removed (deregistered). `unstakeTime` is the time when unstake will be callable.
     */
    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    /** Deletes the relay from the system, and gives back its stake to the owner.
     *
     * Can only be called by the relay owner, after `unstakeDelay` has elapsed since {removeRelayByOwner} was called.
     *
     * Emits an {Unstaked} event.
     */
    function unstake(address relay) public;

    /**
     * @dev Emitted when a relay is unstaked for, including the returned stake.
     */
    event Unstaked(address indexed relay, uint256 stake);

    // States a relay can be in
    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    /**
     * @dev Returns a relay's status. Note that relays can be deleted when unstaked or penalized, causing this function
     * to return an empty entry.
     */
    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);

    // Balance management

    /**
     * @dev Deposits Ether for a contract, so that it can receive (and pay for) relayed transactions.
     *
     * Unused balance can only be withdrawn by the contract itself, by calling {withdraw}.
     *
     * Emits a {Deposited} event.
     */
    function depositFor(address target) public payable;

    /**
     * @dev Emitted when {depositFor} is called, including the amount and account that was funded.
     */
    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    /**
     * @dev Returns an account's deposits. These can be either a contracts's funds, or a relay owner's revenue.
     */
    function balanceOf(address target) external view returns (uint256);

    /**
     * Withdraws from an account's balance, sending it back to it. Relay owners call this to retrieve their revenue, and
     * contracts can use it to reduce their funding.
     *
     * Emits a {Withdrawn} event.
     */
    function withdraw(uint256 amount, address payable dest) public;

    /**
     * @dev Emitted when an account withdraws funds from `RelayHub`.
     */
    event Withdrawn(address indexed account, address indexed dest, uint256 amount);

    // Relaying

    /**
     * @dev Checks if the `RelayHub` will accept a relayed operation.
     * Multiple things must be true for this to happen:
     *  - all arguments must be signed for by the sender (`from`)
     *  - the sender's nonce must be the current one
     *  - the recipient must accept this transaction (via {acceptRelayedCall})
     *
     * Returns a `PreconditionCheck` value (`OK` when the transaction can be relayed), or a recipient-specific error
     * code if it returns one in {acceptRelayedCall}.
     */
    function canRelay(
        address relay,
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public view returns (uint256 status, bytes memory recipientContext);

    // Preconditions for relaying, checked by canRelay and returned as the corresponding numeric values.
    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    /**
     * @dev Relays a transaction.
     *
     * For this to succeed, multiple conditions must be met:
     *  - {canRelay} must `return PreconditionCheck.OK`
     *  - the sender must be a registered relay
     *  - the transaction's gas price must be larger or equal to the one that was requested by the sender
     *  - the transaction must have enough gas to not run out of gas if all internal transactions (calls to the
     * recipient) use all gas available to them
     *  - the recipient must have enough balance to pay the relay for the worst-case scenario (i.e. when all gas is
     * spent)
     *
     * If all conditions are met, the call will be relayed and the recipient charged. {preRelayedCall}, the encoded
     * function and {postRelayedCall} will be called in that order.
     *
     * Parameters:
     *  - `from`: the client originating the request
     *  - `to`: the target {IRelayRecipient} contract
     *  - `encodedFunction`: the function call to relay, including data
     *  - `transactionFee`: fee (%) the relay takes over actual gas cost
     *  - `gasPrice`: gas price the client is willing to pay
     *  - `gasLimit`: gas to forward when calling the encoded function
     *  - `nonce`: client's nonce
     *  - `signature`: client's signature over all previous params, plus the relay and RelayHub addresses
     *  - `approvalData`: dapp-specific data forwared to {acceptRelayedCall}. This value is *not* verified by the
     * `RelayHub`, but it still can be used for e.g. a signature.
     *
     * Emits a {TransactionRelayed} event.
     */
    function relayCall(
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public;

    /**
     * @dev Emitted when an attempt to relay a call failed.
     *
     * This can happen due to incorrect {relayCall} arguments, or the recipient not accepting the relayed call. The
     * actual relayed call was not executed, and the recipient not charged.
     *
     * The `reason` parameter contains an error code: values 1-10 correspond to `PreconditionCheck` entries, and values
     * over 10 are custom recipient error codes returned from {acceptRelayedCall}.
     */
    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    /**
     * @dev Emitted when a transaction is relayed. 
     * Useful when monitoring a relay's operation and relayed calls to a contract
     *
     * Note that the actual encoded function might be reverted: this is indicated in the `status` parameter.
     *
     * `charge` is the Ether value deducted from the recipient's balance, paid to the relay's owner.
     */
    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    // Reason error codes for the TransactionRelayed event
    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    /**
     * @dev Returns how much gas should be forwarded to a call to {relayCall}, in order to relay a transaction that will
     * spend up to `relayedCallStipend` gas.
     */
    function requiredGas(uint256 relayedCallStipend) public view returns (uint256);

    /**
     * @dev Returns the maximum recipient charge, given the amount of gas forwarded, gas price and relay fee.
     */
    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) public view returns (uint256);

     // Relay penalization. 
     // Any account can penalize relays, removing them from the system immediately, and rewarding the
    // reporter with half of the relay's stake. The other half is burned so that, even if the relay penalizes itself, it
    // still loses half of its stake.

    /**
     * @dev Penalize a relay that signed two transactions using the same nonce (making only the first one valid) and
     * different data (gas price, gas limit, etc. may be different).
     *
     * The (unsigned) transaction data and signature for both transactions must be provided.
     */
    function penalizeRepeatedNonce(bytes memory unsignedTx1, bytes memory signature1, bytes memory unsignedTx2, bytes memory signature2) public;

    /**
     * @dev Penalize a relay that sent a transaction that didn't target `RelayHub`'s {registerRelay} or {relayCall}.
     */
    function penalizeIllegalTransaction(bytes memory unsignedTx, bytes memory signature) public;

    /**
     * @dev Emitted when a relay is penalized.
     */
    event Penalized(address indexed relay, address sender, uint256 amount);

    /**
     * @dev Returns an account's nonce in `RelayHub`.
     */
    function getNonce(address from) external view returns (uint256);
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.5.0;


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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/GSNRecipient.sol

pragma solidity ^0.5.0;





/**
 * @dev Base GSN recipient contract: includes the {IRelayRecipient} interface
 * and enables GSN support on all contracts in the inheritance tree.
 *
 * TIP: This contract is abstract. The functions {acceptRelayedCall},
 *  {_preRelayedCall}, and {_postRelayedCall} are not implemented and must be
 * provided by derived contracts. See the
 * xref:ROOT:gsn-strategies.adoc#gsn-strategies[GSN strategies] for more
 * information on how to use the pre-built {GSNRecipientSignature} and
 * {GSNRecipientERC20Fee}, or how to write your own.
 */
contract GSNRecipient is Initializable, IRelayRecipient, Context {
    function initialize() public initializer {
        if (_relayHub == address(0)) {
            setDefaultRelayHub();
        }
    }

    function setDefaultRelayHub() public {
        _upgradeRelayHub(0xD216153c06E857cD7f72665E0aF1d7D82172F494);
    }

    // Default RelayHub address, deployed on mainnet and all testnets at the same address
    address private _relayHub;

    uint256 constant private RELAYED_CALL_ACCEPTED = 0;
    uint256 constant private RELAYED_CALL_REJECTED = 11;

    // How much gas is forwarded to postRelayedCall
    uint256 constant internal POST_RELAYED_CALL_MAX_GAS = 100000;

    /**
     * @dev Emitted when a contract changes its {IRelayHub} contract to a new one.
     */
    event RelayHubChanged(address indexed oldRelayHub, address indexed newRelayHub);

    /**
     * @dev Returns the address of the {IRelayHub} contract for this recipient.
     */
    function getHubAddr() public view returns (address) {
        return _relayHub;
    }

    /**
     * @dev Switches to a new {IRelayHub} instance. This method is added for future-proofing: there's no reason to not
     * use the default instance.
     *
     * IMPORTANT: After upgrading, the {GSNRecipient} will no longer be able to receive relayed calls from the old
     * {IRelayHub} instance. Additionally, all funds should be previously withdrawn via {_withdrawDeposits}.
     */
    function _upgradeRelayHub(address newRelayHub) internal {
        address currentRelayHub = _relayHub;
        require(newRelayHub != address(0), "GSNRecipient: new RelayHub is the zero address");
        require(newRelayHub != currentRelayHub, "GSNRecipient: new RelayHub is the current one");

        emit RelayHubChanged(currentRelayHub, newRelayHub);

        _relayHub = newRelayHub;
    }

    /**
     * @dev Returns the version string of the {IRelayHub} for which this recipient implementation was built. If
     * {_upgradeRelayHub} is used, the new {IRelayHub} instance should be compatible with this version.
     */
    // This function is view for future-proofing, it may require reading from
    // storage in the future.
    function relayHubVersion() public view returns (string memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return "1.0.0";
    }

    /**
     * @dev Withdraws the recipient's deposits in `RelayHub`.
     *
     * Derived contracts should expose this in an external interface with proper access control.
     */
    function _withdrawDeposits(uint256 amount, address payable payee) internal {
        IRelayHub(_relayHub).withdraw(amount, payee);
    }

    // Overrides for Context's functions: when called from RelayHub, sender and
    // data require some pre-processing: the actual sender is stored at the end
    // of the call data, which in turns means it needs to be removed from it
    // when handling said data.

    /**
     * @dev Replacement for msg.sender. Returns the actual sender of a transaction: msg.sender for regular transactions,
     * and the end-user for GSN relayed calls (where msg.sender is actually `RelayHub`).
     *
     * IMPORTANT: Contracts derived from {GSNRecipient} should never use `msg.sender`, and use {_msgSender} instead.
     */
    function _msgSender() internal view returns (address payable) {
        if (msg.sender != _relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    /**
     * @dev Replacement for msg.data. Returns the actual calldata of a transaction: msg.data for regular transactions,
     * and a reduced version for GSN relayed calls (where msg.data contains additional information).
     *
     * IMPORTANT: Contracts derived from {GSNRecipient} should never use `msg.data`, and use {_msgData} instead.
     */
    function _msgData() internal view returns (bytes memory) {
        if (msg.sender != _relayHub) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }

    // Base implementations for pre and post relayedCall: only RelayHub can invoke them, and data is forwarded to the
    // internal hook.

    /**
     * @dev See `IRelayRecipient.preRelayedCall`.
     *
     * This function should not be overriden directly, use `_preRelayedCall` instead.
     *
     * * Requirements:
     *
     * - the caller must be the `RelayHub` contract.
     */
    function preRelayedCall(bytes calldata context) external returns (bytes32) {
        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        return _preRelayedCall(context);
    }

    /**
     * @dev See `IRelayRecipient.preRelayedCall`.
     *
     * Called by `GSNRecipient.preRelayedCall`, which asserts the caller is the `RelayHub` contract. Derived contracts
     * must implement this function with any relayed-call preprocessing they may wish to do.
     *
     */
    function _preRelayedCall(bytes memory context) internal returns (bytes32);

    /**
     * @dev See `IRelayRecipient.postRelayedCall`.
     *
     * This function should not be overriden directly, use `_postRelayedCall` instead.
     *
     * * Requirements:
     *
     * - the caller must be the `RelayHub` contract.
     */
    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external {
        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        _postRelayedCall(context, success, actualCharge, preRetVal);
    }

    /**
     * @dev See `IRelayRecipient.postRelayedCall`.
     *
     * Called by `GSNRecipient.postRelayedCall`, which asserts the caller is the `RelayHub` contract. Derived contracts
     * must implement this function with any relayed-call postprocessing they may wish to do.
     *
     */
    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal;

    /**
     * @dev Return this in acceptRelayedCall to proceed with the execution of a relayed call. Note that this contract
     * will be charged a fee by RelayHub
     */
    function _approveRelayedCall() internal pure returns (uint256, bytes memory) {
        return _approveRelayedCall("");
    }

    /**
     * @dev See `GSNRecipient._approveRelayedCall`.
     *
     * This overload forwards `context` to _preRelayedCall and _postRelayedCall.
     */
    function _approveRelayedCall(bytes memory context) internal pure returns (uint256, bytes memory) {
        return (RELAYED_CALL_ACCEPTED, context);
    }

    /**
     * @dev Return this in acceptRelayedCall to impede execution of a relayed call. No fees will be charged.
     */
    function _rejectRelayedCall(uint256 errorCode) internal pure returns (uint256, bytes memory) {
        return (RELAYED_CALL_REJECTED + errorCode, "");
    }

    /*
     * @dev Calculates how much RelayHub will charge a recipient for using `gas` at a `gasPrice`, given a relayer's
     * `serviceFee`.
     */
    function _computeCharge(uint256 gas, uint256 gasPrice, uint256 serviceFee) internal pure returns (uint256) {
        // The fee is expressed as a percentage. E.g. a value of 40 stands for a 40% fee, so the recipient will be
        // charged for 1.4 times the spent amount.
        return (gas * gasPrice * (100 + serviceFee)) / 100;
    }

    function _getRelayedCallSender() private pure returns (address payable result) {
        // We need to read 20 bytes (an address) located at array index msg.data.length - 20. In memory, the array
        // is prefixed with a 32-byte length value, so we first add 32 to get the memory read index. However, doing
        // so would leave the address in the upper 20 bytes of the 32-byte word, which is inconvenient and would
        // require bit shifting. We therefore subtract 12 from the read index so the address lands on the lower 20
        // bytes. This can always be done due to the 32-byte prefix.

        // The final memory read index is msg.data.length - 20 + 32 - 12 = msg.data.length. Using inline assembly is the
        // easiest/most-efficient way to perform this operation.

        // These fields are not accessible from assembly
        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
            result := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function _getRelayedCallData() private pure returns (bytes memory) {
        // RelayHub appends the sender address at the end of the calldata, so in order to retrieve the actual msg.data,
        // we must strip the last 20 bytes (length of an address type) from it.

        uint256 actualDataLength = msg.data.length - 20;
        bytes memory actualData = new bytes(actualDataLength);

        for (uint256 i = 0; i < actualDataLength; ++i) {
            actualData[i] = msg.data[i];
        }

        return actualData;
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

// File: contracts/IChai.sol

pragma solidity 0.5.12;

/**
 * @dev Chai interface
 */
interface IChai {
  // ERC20 functions
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  // Chai-specific functions
  function join(address dst, uint wad) external;
  function exit(address src, uint wad) external;
  function draw(address src, uint wad) external;
  function move(address src, address dst, uint wad) external returns (bool);
}

// File: contracts/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: contracts/ICERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev cToken Interface
 */
interface ICERC20 {
  // ========================================================================
  // =========================== cToken Interface ===========================
  // ========================================================================
  function totalSupply() external view returns (uint256);
  function transfer(address dst, uint amount) external returns (bool);
  function transferFrom(address src, address dst, uint amount) external returns (bool);
  function approve(address spender, uint amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint);
  function balanceOf(address owner) external view returns (uint);
  function balanceOfUnderlying(address owner) external returns (uint);
  function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);
  function borrowRatePerBlock() external view returns (uint);
  function supplyRatePerBlock() external view returns (uint);
  function totalBorrowsCurrent() external returns (uint);
  function borrowBalanceCurrent(address account) external returns (uint);
  function borrowBalanceStored(address account) external view returns (uint);
  function exchangeRateCurrent() external returns (uint);
  function exchangeRateStored() external view returns (uint);
  function getCash() external view returns (uint);
  function accrueInterest() external returns (uint);
  function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);
  function mint(uint mintAmount) external returns (uint);
  function redeem(uint redeemTokens) external returns (uint);
  function redeemUnderlying(uint redeemAmount) external returns (uint);
  function borrow(uint borrowAmount) external returns (uint);
  function repayBorrow(uint repayAmount) external returns (uint);
  function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
}

// File: contracts/Swapper.sol

pragma solidity 0.5.12;







/**
 * @notice The Swapper contract has a variety of functions that let
 * you do a few things via meta-transactions with the Gas Station
 * Network. These things are:
 *   1. Swap: swaps Chai for another token, e.g. Chai -> cDAI
 *   2. Anti-swap: undoes a swap, e.g. cDAI -> Chai (all swaps must
 *      have an anti-swap)
 *   3. Compose: Lets you combine an anti-swap and new swap in one
 *       transaction (e.g. cDAI > Chai > RAY)
 */
contract Swapper is Initializable, Ownable, GSNRecipient {

  /**
   * DEVELOPER NOTES
   *
   *   - IMPORTANT: Contracts derived from GSNRecipient should never
   *      use `msg.sender` or `msg.data`, and should use `_msgSender()`
   *      and `_msgData()` instead. Source:
   *      https://docs.openzeppelin.com/contracts/2.x/gsn#_msg_sender_and_msg_data
   *
   *   - GSNRecipientSignature was previously called GSNRecipientSignature,
   *     and is referred to by that name in the OpenZeppelin docs
   */

  mapping (address => bool) public isValidUser;
  IERC20 public daiContract;
  IChai public chaiContract;
  ICERC20 public cdaiContract;

  event DaiAddressChanged(address indexed previousAddress, address indexed newAddress);
  event ChaiAddressChanged(address indexed previousAddress, address indexed newAddress);
  event CdaiAddressChanged(address indexed previousAddress, address indexed newAddress);
  event AssertionError(string indexed message);

  /**
   * @notice Constructor, calls other constructors. Can only be called once
   * due to initializer modifier
   */
  function initialize() public initializer {
    // Call constructors of contracts we inherit from
    Ownable.initialize(_msgSender());
    GSNRecipient.initialize();

    // Set contract addresses and interfaces
    daiContract = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    chaiContract = IChai(0x06AF07097C9Eeb7fD685c692751D5C66dB49c215);
    cdaiContract = ICERC20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);

    // Approve contracts to spend this contract's Dai balance
    approveChaiToSpendDai();
    approveCdaiToSpendDai();
  }

  /**
   * @dev Defines valid IDs for tokens
   */
  modifier verifyId(uint256 _id) {
    require(
      _id == 0 ||
      _id == 1,
      "swapper/invalid-id-provided"
    );
    _;
  }

  /**
   * @notice Add address of a valid user to the mapping of valid users
   * @dev This is called by the Floatify server when a user registers
   * @param _address User address to add
   */
  function addUser(address _address) external onlyOwner {
    isValidUser[_address] = true;
  }


  // ===============================================================================================
  //                                    Token Approvals
  // ===============================================================================================

  /**
   * @notice Approve the Chai contract to spend our Dai
   */
  function approveChaiToSpendDai() private {
    bool result = daiContract.approve(address(chaiContract), uint256(-1));
    require(result, "swapper/approve-chai-to-spend-dai-failed");
  }

  /**
   * @notice Remove allowance of Chai contract to prevent it from spending Dai
   */
  function resetChaiAllowance() private {
    bool result = daiContract.approve(address(chaiContract), 0);
    require(result, "swapper/reset-chai-allowance-failed");
  }


  /**
   * @notice Approve the cDAI contract to spend our Dai
   */
  function approveCdaiToSpendDai() private {
    bool result = daiContract.approve(address(cdaiContract), uint256(-1));
    require(result, "swapper/approve-cdai-to-spend-dai-failed");
  }

  /**
   * @notice Remove allowance of cDAI contract to prevent it from spending Dai
   */
  function resetCdaiAllowance() private {
    bool result = daiContract.approve(address(cdaiContract), 0);
    require(result, "swapper/reset-cdai-allowance-failed");
  }


  // ===============================================================================================
  //                                    Updating Addresses
  // ===============================================================================================


  /**
   * @dev Allows the Dai contract address to be changed
   * @param _newAddress new address
   */
  function updateDaiAddress(address _newAddress) external onlyOwner {
    emit DaiAddressChanged(address(daiContract), _newAddress);
    daiContract = IERC20(_newAddress);
  }

  /**
   * @dev Allows the Chai contract address to be changed
   * @param _newAddress new address
   */
  function updateChaiAddress(address _newAddress) external onlyOwner {
    resetChaiAllowance();
    emit ChaiAddressChanged(address(chaiContract), _newAddress);
    chaiContract = IChai(_newAddress);
    approveChaiToSpendDai();
  }

  /**
   * @dev Allows the Chai contract address to be changed
   * @param _newAddress new address
   */
  function updateCdaiAddress(address _newAddress) external onlyOwner {
    resetCdaiAllowance();
    emit CdaiAddressChanged(address(cdaiContract), _newAddress);
    cdaiContract = ICERC20(_newAddress);
    approveCdaiToSpendDai();
  }


  // ===============================================================================================
  //                                        Swaps / Anti-swaps
  // ===============================================================================================

  /**
   * Swap Rules:
   *   - When going from any token to Dai, we must specify a Dai-denominated
   *     amount to swap
   *   - When going from Dai to any other token, we convert all Dai
   *   - When a Dai amount is required, we should be able to pass in
   *     uint256(-1) to convert all tokens
   *
   * Flows to support/test right now:
   *   1. Chai -> Dai -> Withdraw -- DONE
   *   2. Chai -> Dai -> cDAI
   *   3. cDAI -> Dai -> Chai
   *   4. cDAI -> Dai -> Withdraw
   *   5. Chai -> Transfer Chai
   *   6. cDAI -> Dai -> Chai -> Transfer Chai
   */

  //  ---------------------------------------- Chai <> Dai -----------------------------------------
  /**
   * @notice Swap Chai for Dai. Resulting Dai balance remains in this contract
   * @param _daiAmount Amount of Dai to swap
   */
  function swapChaiForDai(uint256 _daiAmount) private {
    address _user = _msgSender();
    if (_daiAmount == uint256(-1)) {
      // Withdraw all Chai, denominated in Chai
      uint256 _chaiBalance = chaiContract.balanceOf(_user);
      chaiContract.exit(_user, _chaiBalance);
    } else {
      // Withdraw portion of Chai, demoninated in Dai
      chaiContract.draw(_user, _daiAmount);
    }
  }

  /**
   * @notice Swap Dai for Chai, and send Chai to the selected recipient
   */
  function swapDaiForChai() private {
    uint256 _daiBalance = daiContract.balanceOf(address(this));
    chaiContract.join(_msgSender(), _daiBalance);
  }

  //  ---------------------------------------- cDAI <> Dai -----------------------------------------
  /**
   * @notice Swap cDAI for Dai. Resulting Dai balance remains in this contract
   * @param _daiAmount Amount of Dai to swap
   */
  function swapCdaiForDai(uint256 _daiAmount) private {
    address _user = _msgSender();
    if (_daiAmount == uint256(-1)) {
      uint256 _cdaiBalance = cdaiContract.balanceOf(address(this));
      require(cdaiContract.redeem(_cdaiBalance) == 0, "swapper/max-cdai-redemption-failed");
    } else {
      require(cdaiContract.redeemUnderlying(_daiAmount) == 0, "swapper/partial-cdai-redemption-failed");
    }
  }

  uint public test;
  uint public test2;
  uint public result;
  uint public test3;
  /**
   * @notice Swap Dai for cDAI, and send cDAI to the owner
   */
  function swapDaiForCdai() private {
    uint256 _daiBalance = daiContract.balanceOf(address(this));
    test = _daiBalance;
    result = cdaiContract.mint(_daiBalance);
    require(result == 0, "swapper/cdai-mint-failed");
    test2 = daiContract.balanceOf(address(this));
    test3 = cdaiContract.balanceOf(address(this));
    // uint256 _cdaiBalance = cdaiContract.balanceOf(address(this));
    // cdaiContract.transfer(_msgSender(), _cdaiBalance);
  }


  //  --------------------------------- Token => Different Token -----------------------------------


  /**
   * @notice Lets you combine two swaps in one transaction (e.g. Chai > Dai > cDAI)
   * @dev Source and destination IDs are as follows:
   *   ID     Token
   *    0     Chai
   *    1     cDAI
   * @param _srcId ID of the token to swap from
   * @param _destId ID of the token to swap to
   * @param _daiAmount amount in Dai to swap
   */
  function composeSwap(uint256 _srcId, uint256 _destId, uint256 _daiAmount) external
    verifyId(_srcId)
    verifyId(_destId)
  {
    // Swap from source to Dai
    if      (_srcId == 0) { swapChaiForDai(_daiAmount); }
    else if (_srcId == 1) { swapCdaiForDai(_daiAmount); }
    else    { emit AssertionError("Invalid _srcId got through"); }

    // Swap from Dai to dest
    if      (_destId == 0) { swapDaiForChai(); }
    else if (_destId == 1) { swapDaiForCdai(); }
    else    { emit AssertionError("Invalid _destId got through"); }
  }

  function composeSwap_chaiToDai(uint256 _srcId, uint256 _daiAmount) external verifyId(_srcId) {
    // Swap from source to Dai
    if      (_srcId == 0) { swapChaiForDai(_daiAmount); }
    else if (_srcId == 1) { swapCdaiForDai(_daiAmount); }
    else    { emit AssertionError("Invalid _srcId got through"); }
  }

  function composeSwap_daiToCdai(uint256 _destId) external verifyId(_destId) {
    // Swap from Dai to dest
    if      (_destId == 0) { swapDaiForChai(); }
    else if (_destId == 1) { swapDaiForCdai(); }
    else    { emit AssertionError("Invalid _destId got through"); }
  }


  //  ----------------------------------- Token => Withdraw Dai ------------------------------------

  /**
   * @notice Withdraw all Dai to the provided address
   * @param _destination Address to send the Dai to
   */
  function withdrawDai(address _destination) private {
    uint256 _daiBalance = daiContract.balanceOf(address(this));
    daiContract.transfer(_destination, _daiBalance);
  }

  // The functions below are primarily used for withdrawing a to a bank account by sending
  // Dai to a user's liquidation address (e.g. how Wyre works)

  /**
   * @notice Redeem Chai for Dai and send it to another address
   * @param _destination Address to send the Dai to
   * @param _daiAmount Amount of Dai to swap
   */
  function withdrawChaiAsDai(address _destination, uint256 _daiAmount) external {
    swapChaiForDai(_daiAmount);
    withdrawDai(_destination);
  }


  // ===============================================================================================
  //                                    Transfers
  // ===============================================================================================

  uint256 public count;
  function increaseCount() external {
    count += 1;
  }

  /**
   * @notice Send Chai to another user
   */
  function transferChai(address _recipient, uint256 _daiAmount) external {
    bool _result = chaiContract.move(_msgSender(), _recipient, _daiAmount);
    require(_result, "swapper/chai-transfer-failed");
  }

    // ===============================================================================================
  //                               Gas Station Network Functions
  // ===============================================================================================

  /**
   * @dev Determine if we should receive a relayed call.
   * There are multiple ways to make this work, including:
   *   - having a whitelist of trusted users
   *   - only accepting calls to an onboarding function
   *   - charging users in tokens (possibly issued by you)
   *   - delegating the acceptance logic off-chain
   * All relayed call requests can be rejected at no cost to the recipient.
   *
   * In this function, we return a number indicating whether we:
   *   - Accept the call: 0, signalled by the call to `_approveRelayedCall()`
   *   - Reject the call: Any other number, signalled by the call to `_rejectRelayedCall(uint256)`
   *
   * We can also return some arbitrary data that will get passed along
   * to the pre and post functions as an execution context.
   *
   * Source: https://docs.openzeppelin.com/contracts/2.x/gsn#_acceptrelayedcall
   */
  function acceptRelayedCall(
    address relay,
    address from,
    bytes calldata encodedFunction,
    uint256 transactionFee,
    uint256 gasPrice,
    uint256 gasLimit,
    uint256 nonce,
    bytes calldata approvalData,
    uint256 maxPossibleCharge
  ) external view returns (uint256, bytes memory) {
    // TODO improve logic
    // if (someCondition) {
    //   return _approveRelayedCall();
    // } else {
    //   _rejectRelayedCall(1); // error code 1
    // }

    // For now we accept all calls
    return _approveRelayedCall();
  }

  /**
   * @dev After call is accepted, but before it's executed, we can use
   * this function to charge the user for their call, perform some
   * bookeeping, etc.
   *
   * This function will inform us of the maximum cost the call may
   * have, and can be used to charge the user in advance. This is
   * useful if the user may spend their allowance as part of the call,
   * so we can lock some funds here.
   *
   * Source: https://docs.openzeppelin.com/contracts/2.x/gsn#_pre_and_postrelayedcall
   */
  function _preRelayedCall(bytes memory context) internal returns (bytes32) {
  }

  /**
   * @dev After call is accepted and executed, we can use this function
   * to charge the user for their call, perform some bookeeping, etc.
   *
   * This function will give us an accurate estimate of the transaction
   * cost, making it a natural place to charge users. It will also let
   * us know if the relayed call reverted or not. This allows us, for
   * instance, to not charge users for reverted calls - but remember
   * that we will be charged by the relayer nonetheless.
   *
   * Source: https://docs.openzeppelin.com/contracts/2.x/gsn#_pre_and_postrelayedcall
   */
  function _postRelayedCall(bytes memory context, bool, uint256 actualCharge, bytes32) internal {
  }

  function setRelayHubAddress() public {
    if(getHubAddr() == address(0)) {
      _upgradeRelayHub(0xD216153c06E857cD7f72665E0aF1d7D82172F494);
    }
  }

  function getRecipientBalance() public view returns (uint) {
    return IRelayHub(getHubAddr()).balanceOf(address(this));
  }
}