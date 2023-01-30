/**
 *Submitted for verification at Etherscan.io on 2019-10-18
*/

pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface UpgradeBeaconControllerInterface {
  function upgrade(address beacon, address implementation) external;
}


library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 *
 * In order to transfer ownership, a recipient must be specified, at which point
 * the specified recipient can call `acceptOwnership` and take ownership.
 */
contract TwoStepOwnable {
  address private _owner;

  address private _newPotentialOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initialize contract by setting transaction submitter as initial owner.
   */
  constructor() internal {
    _owner = tx.origin;
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
    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }

  /**
   * @dev Returns true if the caller is the current owner.
   */
  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows a new account (`newOwner`) to accept ownership.
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  /**
   * @dev Cancel a transfer of ownership to a new account.
   * Can only be called by the current owner.
   */
  function cancelOwnershipTransfer() public onlyOwner {
    _newPotentialOwner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to the caller.
   * Can only be called by a new potential owner set by the current owner.
   */
  function acceptOwnership() public {
    require(
      msg.sender != _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }
}


/**
 * @title Timelocker
 * @author 0age
 * @notice This contract allows contracts that inherit it to implement timelocks
 * on functions, where the `_setTimelock` internal function must first be called
 * and passed the target function selector and arguments. Then, a given time
 * interval must first fully transpire before the timelock functions can be
 * successfully called. Furthermore, once a timelock is complete, it will expire
 * after a period of time. It also includes a `modifyTimelockInterval` function
 * and a `modifyTimelockExpiration` function, both of which implement timelocks,
 * and that are given a function selector and a new timelock interval or default
 * expiration time for the specified function as arguments. IT IS IMPORTANT THAT
 * THESE FUNCTIONS ARE OVERRIDDEN IN WHATEVER CONTRACT INHERITS TIMELOCKER, as
 * they do not implement any access control since Timelocker is not an ownable.
 *
 * To make a function timelocked, use the `_enforceTimelock` internal function.
 * To set initial defult minimum timelock intervals and expirations, use the
 * `_setInitialTimelockInterval` and `_setInitialTimelockExpiration` internal
 * functions - they can only be used during contract creation. Finally, there
 * are three public getters: `getTimelock`, `getDefaultTimelockInterval`, and
 * `getDefaultTimelockExpiration`.
 */
contract Timelocker {
  using SafeMath for uint256;

  // Fire an event any time a timelock is initiated.
  event TimelockInitiated(
    bytes4 functionSelector, // selector of the function
    uint256 timeComplete,    // timestamp at which the function can be called
    bytes arguments,         // abi-encoded function arguments to call with
    uint256 timeExpired      // timestamp where function can no longer be called
  );

  // Fire an event any time a minimum timelock interval is modified.
  event TimelockIntervalModified(
    bytes4 functionSelector, // selector of the function
    uint256 oldInterval,     // old minimum timelock interval for the function
    uint256 newInterval      // new minimum timelock interval for the function
  );

  // Fire an event any time a default timelock expiration is modified.
  event TimelockExpirationModified(
    bytes4 functionSelector, // selector of the function
    uint256 oldExpiration,   // old default timelock expiration for the function
    uint256 newExpiration    // new default timelock expiration for the function
  );

  // Each timelock has timestamps for when it is complete and when it expires.
  struct Timelock {
    uint128 complete;
    uint128 expires;
  }

  // Functions have a timelock interval and time from completion to expiration.
  struct TimelockDefaults {
    uint128 interval;
    uint128 expiration;
  }

  // Implement a timelock for each function and set of arguments.
  mapping(bytes4 => mapping(bytes32 => Timelock)) private _timelocks;

  // Implement default timelock intervals and expirations for each function.
  mapping(bytes4 => TimelockDefaults) private _timelockDefaults;

  // Only allow one new interval or expiration change at a time per function.
  mapping(bytes4 => mapping(bytes4 => bytes32)) private _protectedTimelockIDs;

  // Store reused revert reasons as constants.
  string constant _SHOULD_OVERRIDE = (
    "This function should be overridden by the inheriting contract."
  );

  /**
   * @notice Public "stub" function for setting a new timelock interval. Be sure
   * to override the stub of this function with appropriate access controls, and
   * to call the corresponding internal function from within the overriding
   * function, in order to modify timelock intervals.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval the new minimum timelock interval to set for the
   * given function.
   */
  function modifyTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) public {
    revert(_SHOULD_OVERRIDE);
  }

  /**
   * @notice Public "stub" function for setting a new timelock expiration. Be
   * sure to override the stub of this function with appropriate access controls
   * in order to modify timelock expirations.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockExpiration the new default timelock expiration to set for
   * the given function.
   */
  function modifyTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) public {
    revert(_SHOULD_OVERRIDE);
  }

  /**
   * @notice View function to check if a timelock for the specified function and
   * arguments has completed.
   * @param functionSelector function to be called.
   * @param arguments The abi-encoded arguments of the function to be called.
   * @return A boolean indicating if the timelock exists or not and the time at
   * which the timelock completes if it does exist.
   */
  function getTimelock(
    bytes4 functionSelector, bytes memory arguments
  ) public view returns (
    bool exists,
    bool completed,
    bool expired,
    uint256 completionTime,
    uint256 expirationTime
  ) {
    // Get timelock ID using the supplied function arguments.
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    // Get information on the current timelock, if one exists.
    completionTime = uint256(_timelocks[functionSelector][timelockID].complete);
    exists = completionTime != 0;
    expirationTime = uint256(_timelocks[functionSelector][timelockID].expires);
    completed = exists && now > completionTime;
    expired = exists && now > expirationTime;
  }

  /**
   * @notice View function to check the current minimum timelock interval on a
   * given function.
   * @param functionSelector function to retrieve the timelock interval for.
   * @return The current minimum timelock interval for the given function.
   */
  function getDefaultTimelockInterval(
    bytes4 functionSelector
  ) public view returns (uint256 defaultTimelockInterval) {
    defaultTimelockInterval = uint256(
      _timelockDefaults[functionSelector].interval
    );
  }

  /**
   * @notice View function to check the current default timelock expiration on a
   * given function.
   * @param functionSelector function to retrieve the timelock expiration for.
   * @return The current default timelock expiration for the given function.
   */
  function getDefaultTimelockExpiration(
    bytes4 functionSelector
  ) public view returns (uint256 defaultTimelockExpiration) {
    defaultTimelockExpiration = uint256(
      _timelockDefaults[functionSelector].expiration
    );
  }

  /**
   * @notice Internal function that sets a timelock so that the specified
   * function can be called with the specified arguments. Note that existing
   * timelocks may be extended, but not shortened - this can also be used as a
   * method for "cancelling" a function call by extending the timelock to an
   * arbitrarily long duration. Keep in mind that new timelocks may be created
   * with a shorter duration on functions that already have other timelocks on
   * them, but only if they have different arguments.
   * @param functionSelector selector of the function to be called.
   * @param arguments The abi-encoded arguments of the function to be called.
   * @param extraTime Additional time in seconds to add to the minimum timelock
   * interval for the given function.
   */
  function _setTimelock(
    bytes4 functionSelector, bytes memory arguments, uint256 extraTime
  ) internal {
    // Get timelock ID using the supplied function arguments.
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    // For timelock interval or expiration changes, first drop any existing
    // timelock for the function being modified if the argument has changed.
    if (
      functionSelector == this.modifyTimelockInterval.selector ||
      functionSelector == this.modifyTimelockExpiration.selector
    ) {
      // Determine the function that will be modified by the timelock.
      (bytes4 modifiedFunction, uint256 duration) = abi.decode(
        arguments, (bytes4, uint256)
      );

      // Ensure that the new timelock duration will not cause an overflow error.
      require(
        duration < 365000000000000 days,
        "Specified default timelock duration to modify is too large."
      );

      // Determine the current timelockID, if any, for the modified function.
      bytes32 currentTimelockID = (
        _protectedTimelockIDs[functionSelector][modifiedFunction]
      );

      // Drop existing timelock if it exists and has a different timelockID.
      if (currentTimelockID != bytes32(0) && currentTimelockID != timelockID) {
        delete _timelocks[functionSelector][currentTimelockID];
      }

      // Register the current timelockID.
      _protectedTimelockIDs[functionSelector][modifiedFunction] = timelockID;
    }

    // Get timelock using current time, inverval for timelock ID, & extra time.
    uint256 timelock = uint256(
      _timelockDefaults[functionSelector].interval
    ).add(now).add(extraTime);

    // Get expiration time using timelock duration plus default expiration time.
    uint256 expiration = timelock.add(
      uint256(_timelockDefaults[functionSelector].expiration)
    );

    // Get the current timelock, if one exists.
    Timelock storage timelockStorage = _timelocks[functionSelector][timelockID];

    // Determine the duration of the current timelock.
    uint256 currentTimelock = uint256(timelockStorage.complete);

    // Ensure that the timelock duration does not decrease. Note that a new,
    // shorter timelock may still be set up on the same function in the event
    // that it is provided with different arguments. Also note that this can be
    // circumvented when modifying intervals or expirations by setting a new
    // timelock (removing the old one), then resetting the original timelock but
    // with a shorter duration.
    require(
      currentTimelock == 0 || timelock > currentTimelock,
      "Existing timelocks may only be extended."
    );

    // Set timelock completion and expiration using timelock ID and extra time.
    timelockStorage.complete = uint128(timelock);
    timelockStorage.expires = uint128(expiration);

    // Emit an event with all of the relevant information.
    emit TimelockInitiated(functionSelector, timelock, arguments, expiration);
  }

  /**
   * @notice Internal function for setting a new timelock interval for a given
   * function selector. The default for this function may also be modified, but
   * excessive values will cause the `modifyTimelockInterval` function to become
   * unusable.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval the new minimum timelock interval to set for the
   * given function.
   */
  function _modifyTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) internal {
    // Ensure that the timelock has been set and is completed.
    _enforceTimelock(
      this.modifyTimelockInterval.selector,
      abi.encode(functionSelector, newTimelockInterval)
    );

    // Set new timelock interval and emit a `TimelockIntervalModified` event.
    _setTimelockInterval(functionSelector, newTimelockInterval);
  }

  /**
   * @notice Internal function for setting a new timelock expiration for a given
   * function selector. Once the minimum interval has elapsed, the timelock will
   * expire once the specified expiration time has elapsed. Setting this value
   * too low will result in timelocks that are very difficult to execute
   * correctly. Be sure to override the public version of this function with
   * appropriate access controls.
   * @param functionSelector the selector of the function to set the timelock
   * expiration for.
   * @param newTimelockExpiration the new minimum timelock expiration to set for
   * the given function.
   */
  function _modifyTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) internal {
    // Ensure that the timelock has been set and is completed.
    _enforceTimelock(
      this.modifyTimelockExpiration.selector,
      abi.encode(functionSelector, newTimelockExpiration)
    );

    // Set new default expiration and emit a `TimelockExpirationModified` event.
    _setTimelockExpiration(functionSelector, newTimelockExpiration);
  }

  /**
   * @notice Internal function to set an initial timelock interval for a given
   * function selector. Only callable during contract creation.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval the new minimum timelock interval to set for the
   * given function.
   */
  function _setInitialTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) internal {
    // Ensure that this function is only callable during contract construction.
    assembly { if extcodesize(address) { revert(0, 0) } }

    // Set the timelock interval and emit a `TimelockIntervalModified` event.
    _setTimelockInterval(functionSelector, newTimelockInterval);
  }

  /**
   * @notice Internal function to set an initial timelock expiration for a given
   * function selector. Only callable during contract creation.
   * @param functionSelector the selector of the function to set the timelock
   * expiration for.
   * @param newTimelockExpiration the new minimum timelock expiration to set for
   * the given function.
   */
  function _setInitialTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) internal {
    // Ensure that this function is only callable during contract construction.
    assembly { if extcodesize(address) { revert(0, 0) } }

    // Set the timelock interval and emit a `TimelockExpirationModified` event.
    _setTimelockExpiration(functionSelector, newTimelockExpiration);
  }

  /**
   * @notice Internal function to ensure that a timelock is complete or expired
   * and to clear the existing timelock if it is complete so it cannot later be
   * reused.
   * @param functionSelector function to be called.
   * @param arguments The abi-encoded arguments of the function to be called.
   */
  function _enforceTimelock(
    bytes4 functionSelector, bytes memory arguments
  ) internal {
    // Get timelock ID using the supplied function arguments.
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    // Get the current timelock, if one exists.
    Timelock memory timelock = _timelocks[functionSelector][timelockID];

    uint256 currentTimelock = uint256(timelock.complete);
    uint256 expiration = uint256(timelock.expires);

    // Ensure that the timelock is set and has completed.
    require(
      currentTimelock != 0 && currentTimelock <= now, "Timelock is incomplete."
    );

    // Ensure that the timelock has not expired.
    require(expiration > now, "Timelock has expired.");

    // Clear out the existing timelock so that it cannot be reused.
    delete _timelocks[functionSelector][timelockID];
  }

  /**
   * @notice Private function for setting a new timelock interval for a given
   * function selector.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval the new minimum timelock interval to set for the
   * given function.
   */
  function _setTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) private {
    // Get the existing timelock interval, if any.
    uint256 oldTimelockInterval = uint256(
      _timelockDefaults[functionSelector].interval
    );

    // Update the timelock interval on the provided function.
    _timelockDefaults[functionSelector].interval = uint128(newTimelockInterval);

    // Emit a `TimelockIntervalModified` event with the appropriate arguments.
    emit TimelockIntervalModified(
      functionSelector, oldTimelockInterval, newTimelockInterval
    );
  }

  /**
   * @notice Private function for setting a new timelock expiration for a given
   * function selector.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockExpiration the new default timelock expiration to set for
   * the given function.
   */
  function _setTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) private {
    // Ensure that the new timelock expiration is not too short.
    require(
      newTimelockExpiration > 1 minutes,
      "New timelock expiration is too short."
    );

    // Get the existing timelock expiration, if any.
    uint256 oldTimelockExpiration = uint256(
      _timelockDefaults[functionSelector].expiration
    );

    // Update the timelock expiration on the provided function.
    _timelockDefaults[functionSelector].expiration = uint128(
      newTimelockExpiration
    );

    // Emit a `TimelockExpirationModified` event with the appropriate arguments.
    emit TimelockExpirationModified(
      functionSelector, oldTimelockExpiration, newTimelockExpiration
    );
  }
}


/**
 * @title DharmaUpgradeBeaconControllerManager
 * @author 0age
 * @notice This contract will be owned by DharmaUpgradeMultisig and will manage
 * upgrades to the global smart wallet and key ring implementation contracts via
 * dedicated control over the "upgrade beacon" controller contracts (and can
 * additionally be used to manage other upgrade beacon controllers). It contains
 * a set of timelocked functions, where the `setTimelock` function must first be
 * called, with the same arguments that the function will be supplied with.
 * Then, a given time interval must first fully transpire before the timelock
 * functions can be successfully called.
 *
 * The timelocked functions currently implemented include:
 *  upgrade(address controller, address implementation)
 *  transferControllerOwnership(address controller, address newOwner)
 *  modifyTimelockInterval(bytes4 functionSelector, uint256 newTimelockInterval)
 *  modifyTimelockExpiration(
 *    bytes4 functionSelector, uint256 newTimelockExpiration
 *  )
 *
 * It also specifies dedicated implementations for the Dharma Smart Wallet and
 * Dharma Key Ring upgrade beacons that can be triggered in an emergency or in
 * the event of an extended period of inactivity from Dharma. These contingency
 * implementations give the user the ability to withdraw any funds on their
 * smart wallet by submitting a transaction directly from the account of any of
 * their signing keys, but are otherwise kept as simple as possible.
 *
 * This contract can transfer ownership of any upgrade beacon controller it owns
 * (subject to the timelock on `transferControllerOwnership`), in order to
 * introduce new upgrade conditions or to otherwise alter the way that upgrades
 * are carried out.
 */
contract DharmaUpgradeBeaconControllerManager is TwoStepOwnable, Timelocker {
  using SafeMath for uint256;

  // Fire an event whenever the Adharma Contingency is activated or exited.
  event AdharmaContingencyActivated(address controller, address beacon);
  event AdharmaContingencyExited(address controller, address beacon);

  // Store timestamp and last implementation in case of Adharma Contingency.
  // Note that this is specific to a particular controller and beacon.
  struct AdharmaContingency {
    bool armed;
    bool activated;
    uint256 activationTime;
  }

  // Store the last implementation address for each controller + beacon pair.
  mapping(address => mapping (address => address)) private _lastImplementation;

  // Store information on contingency status of each controller + beacon pair.
  mapping(address => mapping (address => AdharmaContingency)) private _adharma;

  // New controller owners must accept ownership before a transfer can occur.
  mapping(address => mapping(address => bool)) private _willAcceptOwnership;

  // Track the last heartbeat timestamp as well as the current heartbeat address
  uint256 private _lastHeartbeat;
  address private _heartbeater;

  // Store the address of the Dharma Smart Wallet Upgrade Beacon as a constant.
  address private constant _DHARMA_SMART_WALLET_UPGRADE_BEACON = address(
    0x000000000026750c571ce882B17016557279ADaa
  );

  // Store the Adharma Smart Wallet Contingency implementation. Note that this
  // is specific to the smart wallet and will not be activated on other beacons.
  address private constant _ADHARMA_SMART_WALLET_IMPLEMENTATION = address(
    0x0000000053d300f11703dcDD1e90921Db83F0048
  );

  // Store the address of the Dharma Key Ring Upgrade Beacon as a constant.
  address private constant _DHARMA_KEY_RING_UPGRADE_BEACON = address(
    0x0000000000BDA2152794ac8c76B2dc86cbA57cad
  );

  // Store the Adharma Key Ring Contingency implementation. Note that this is
  // specific to the key ring and will not be activated on other beacons.
  address private constant _ADHARMA_KEY_RING_IMPLEMENTATION = address(
    0x00000000480003d5eE4F51134CE73Cc9AC00f693
  );

  /**
   * @notice In the constructor, set tx.origin as initial owner, the initial
   * minimum timelock interval and expiration values, and some initial variable
   * values.
   */
  constructor() public {
    // Ensure Adharma Smart Wallet implementation has the correct runtime code.
    bytes32 adharmaSmartWalletHash;
    bytes32 expectedAdharmaSmartWalletHash = bytes32(
      0x2534c2b555b9011741eabee1c96e1683bb4f58483d05d3e654f00fde85c2673c
    );
    address adharmaSmartWallet = _ADHARMA_SMART_WALLET_IMPLEMENTATION;
    assembly { adharmaSmartWalletHash := extcodehash(adharmaSmartWallet) }
    require(
      adharmaSmartWalletHash == expectedAdharmaSmartWalletHash,
      "Adharma Smart Wallet implementation runtime code hash is incorrect."
    );

    // Ensure Adharma Key Ring implementation has the correct runtime code.
    bytes32 adharmaKeyRingHash;
    bytes32 expectedAdharmaKeyRingHash = bytes32(
      0x72f85d929335f00aee7e110513479e43febf22b0ee7826ee4f8cfc767be6c001
    );
    address adharmaKeyRing = _ADHARMA_KEY_RING_IMPLEMENTATION;
    assembly { adharmaKeyRingHash := extcodehash(adharmaKeyRing) }
    require(
      adharmaKeyRingHash == expectedAdharmaKeyRingHash,
      "Adharma Key Ring implementation runtime code hash is incorrect."
    );

    // Set initial minimum timelock interval values.
    _setInitialTimelockInterval(
      this.transferControllerOwnership.selector, 4 weeks
    );
    _setInitialTimelockInterval(this.modifyTimelockInterval.selector, 4 weeks);
    _setInitialTimelockInterval(
      this.modifyTimelockExpiration.selector, 4 weeks
    );
    _setInitialTimelockInterval(this.upgrade.selector, 7 days);

    // Set initial default timelock expiration values.
    _setInitialTimelockExpiration(
      this.transferControllerOwnership.selector, 7 days
    );
    _setInitialTimelockExpiration(this.modifyTimelockInterval.selector, 7 days);
    _setInitialTimelockExpiration(
      this.modifyTimelockExpiration.selector, 7 days
    );
    _setInitialTimelockExpiration(this.upgrade.selector, 7 days);

    // Set the initial owner as the initial heartbeater.
    _heartbeater = tx.origin;
    _lastHeartbeat = now;
  }

  /**
   * @notice Initiates a timelocked upgrade process via a given controller and
   * upgrade beacon to a given implementation address. Only the owner may call
   * this function. Once the timelock period is complete (and before it has
   * expired) the owner may call `upgrade` to complete the process and trigger
   * the upgrade.
   * @param controller address of controller to call into that will trigger the
   * update to the specified upgrade beacon.
   * @param beacon address of upgrade beacon to set the new implementation on.
   * @param implementation the address of the new implementation.
   * @param extraTime Additional time in seconds to add to the timelock.
   */
  function initiateUpgrade(
    address controller,
    address beacon,
    address implementation,
    uint256 extraTime
  ) external onlyOwner {
    require(controller != address(0), "Must specify a controller address.");

    require(beacon != address(0), "Must specify a beacon address.");

    // Ensure that the implementaton contract is not the null address.
    require(
      implementation != address(0),
      "Implementation cannot be the null address."
    );

    // Ensure that the implementation contract has code via extcodesize.
    uint256 size;
    assembly {
      size := extcodesize(implementation)
    }
    require(size > 0, "Implementation must have contract code.");

    // Set the timelock and emit a `TimelockInitiated` event.
    _setTimelock(
      this.upgrade.selector,
      abi.encode(controller, beacon, implementation),
      extraTime
    );
  }

  /**
   * @notice Timelocked function to set a new implementation address on an
   * upgrade beacon contract. This function could optionally check the
   * runtime code of the specified upgrade beacon, but that step is not strictly
   * necessary.
   * @param controller address of controller to call into that will trigger the
   * update to the specified upgrade beacon.
   * @param beacon address of upgrade beacon to set the new implementation on.
   * @param implementation the address of the new implementation.
   */
  function upgrade(
    address controller, address beacon, address implementation
  ) external onlyOwner {
    // Ensure that the timelock has been set and is completed.
    _enforceTimelock(
      this.upgrade.selector, abi.encode(controller, beacon, implementation)
    );

    // Reset the heartbeat to the current time.
    _lastHeartbeat = now;

    // Call controller with beacon to upgrade and implementation to upgrade to.
    _upgrade(controller, beacon, implementation);
  }

  /**
   * @notice Allow a new potential owner of an upgrade beacon controller to
   * accept ownership of the controller.
   * @param controller address of controller to allow ownership transfer for.
   * @param willAcceptOwnership a boolean signifying if an ownership transfer to
   * the caller is acceptable.
   */
  function agreeToAcceptOwnership(
    address controller, bool willAcceptOwnership
  ) external {
    require(controller != address(0), "Must specify a controller address.");

    // Register whether or not the new owner is willing to accept ownership.
    _willAcceptOwnership[controller][msg.sender] = willAcceptOwnership;
  }

  /**
   * @notice Timelocked function to set a new owner on an upgrade beacon
   * controller that is owned by this contract.
   * @param controller address of controller to transfer ownership of.
   * @param newOwner address to assign ownership of the controller to.
   */
  function transferControllerOwnership(
    address controller, address newOwner
  ) external onlyOwner {
    // Ensure that the new owner has confirmed that it can accept ownership.
    require(
      _willAcceptOwnership[controller][newOwner],
      "New owner must agree to accept ownership of the given controller."
    );

    // Ensure that the timelock has been set and is completed.
    _enforceTimelock(
      this.transferControllerOwnership.selector,
      abi.encode(controller, newOwner)
    );

    // Transfer ownership of the controller to the new owner.
    TwoStepOwnable(controller).transferOwnership(newOwner);
  }

  /**
   * @notice Send a new heartbeat. If 90 days pass without a heartbeat, anyone
   * may trigger the Adharma Contingency and force an upgrade to any controlled
   * upgrade beacon.
   */
  function heartbeat() external {
    require(msg.sender == _heartbeater, "Must be called from the heartbeater.");
    _lastHeartbeat = now;
  }

  /**
   * @notice Set a new heartbeater.
   * @param heartbeater address to designate as the heartbeating address.
   */
  function newHeartbeater(address heartbeater) external onlyOwner {
    require(heartbeater != address(0), "Must specify a heartbeater address.");
    _heartbeater = heartbeater;
  }

  /**
   * @notice Arm the Adharma Contingency upgrade. This is required as an extra
   * safeguard against accidentally triggering the Adharma Contingency.
   * @param controller address of controller to arm.
   * @param beacon address of upgrade beacon to arm.
   * @param armed Boolean that signifies the desired armed status.
   */
  function armAdharmaContingency(
    address controller, address beacon, bool armed
  ) external {
    require(controller != address(0), "Must specify a controller address.");

    require(beacon != address(0), "Must specify a beacon address.");

    // Determine if 90 days have passed since the last heartbeat.
    (bool expired, ) = heartbeatStatus();
    require(
      isOwner() || expired,
      "Only callable by the owner or after 90 days without a heartbeat."
    );

    // Arm (or disarm) the Adharma Contingency.
    _adharma[controller][beacon].armed = armed;
  }

  /**
   * @notice Trigger the Adharma Contingency upgrade. This requires that the
   * owner first call `armAdharmaContingency` and set `armed` to `true`. This is
   * only to be invoked in cases of a time-sensitive emergency, or if the owner
   * has become inactive for over 90 days.
   * @param controller address of controller to call into that will trigger the
   * update to the Adharma contingency implementation on the specified upgrade
   * beacon.
   * @param beacon address of upgrade beacon to set the Adharma contingency
   * implementation on.
   */
  function activateAdharmaContingency(
    address controller, address beacon
  ) external {
    // Determine if 90 days have passed since the last heartbeat.
    (bool expired, ) = heartbeatStatus();
    require(
      isOwner() || expired,
      "Only callable by the owner or after 90 days without a heartbeat."
    );

    // Ensure that the Adharma Contingency has been armed.
    require(
      _adharma[controller][beacon].armed,
      "Adharma Contingency is not armed - are SURE you meant to call this?"
    );

    require(
      !_adharma[controller][beacon].activated,
      "Adharma Contingency is already activated on this controller + beacon."
    );

    // Mark the Adharma Contingency as having been activated.
    _adharma[controller][beacon] = AdharmaContingency({
      armed: false,
      activated: true,
      activationTime: now
    });

    // Trigger the upgrade to the correct Adharma implementation contract.
    if (beacon == _DHARMA_SMART_WALLET_UPGRADE_BEACON) {
      _upgrade(controller, beacon, _ADHARMA_SMART_WALLET_IMPLEMENTATION);
    } else if (beacon == _DHARMA_KEY_RING_UPGRADE_BEACON) {
      _upgrade(controller, beacon, _ADHARMA_KEY_RING_IMPLEMENTATION);
    } else {
      revert("Only the smart wallet or key ring contingency can be activated.");
    }

    // Emit an event to signal that the Adharma Contingency has been activated.
    emit AdharmaContingencyActivated(controller, beacon);
  }

  /**
   * @notice Roll back an upgrade to the last implementation and exit from
   * contingency status if one currently exists. Note that you can also roll
   * back a rollback to restore it back to the original implementation that was
   * just rolled back from.
   * @param controller address of controller to call into that will trigger the
   * rollback on the specified upgrade beacon.
   * @param beacon address of upgrade beacon to roll back to the last
   * implementation.
   */
  function rollback(address controller, address beacon) external onlyOwner {
    // Ensure that there is an implementation address to roll back to.
    require(
      _lastImplementation[controller][beacon] != address(0),
      "No prior implementation to roll back to."
    );

    // Exit the contingency state if there is currently one active.
    if (_adharma[controller][beacon].activated) {
      delete _adharma[controller][beacon];

      emit AdharmaContingencyExited(controller, beacon);
    }

    // Reset the heartbeat to the current time.
    _lastHeartbeat = now;

    // Upgrade to the last implementation contract.
    _upgrade(controller, beacon, _lastImplementation[controller][beacon]);
  }

  /**
   * @notice Exit the Adharma Contingency by upgrading to a new contract. This
   * requires that the contingency is currently activated and that at least 48
   * hours has elapsed since it was activated.
   * @param controller address of controller to call into that will trigger the
   * update to the Adharma contingency implementation on the specified upgrade
   * beacon.
   * @param beacon address of upgrade beacon to set the Adharma contingency
   * implementation on.
   * @param implementation the address of the new implementation.
   */
  function exitAdharmaContingency(
    address controller, address beacon, address implementation
  ) external onlyOwner {
    // Ensure that the Adharma Contingency is currently active.
    require(
      _adharma[controller][beacon].activated,
      "Adharma Contingency is not currently activated."
    );

    // Ensure that at least 48 hours has elapsed since the contingency commenced.
    require(
      now > _adharma[controller][beacon].activationTime + 48 hours,
      "Cannot exit contingency with a new upgrade until 48 hours have elapsed."
    );

    // Exit the contingency state.
    delete _adharma[controller][beacon];

    // Reset the heartbeat to the current time.
    _lastHeartbeat = now;

    // Call controller with beacon to upgrade and implementation to upgrade to.
    _upgrade(controller, beacon, implementation);

    // Emit an event to signal that the Adharma Contingency has been activated.
    emit AdharmaContingencyExited(controller, beacon);
  }

  /**
   * @notice Sets the timelock for a new timelock interval for a given function
   * selector. Only the owner may call this function.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval The new timelock interval to set for the given
   * function selector.
   * @param extraTime Additional time in seconds to add to the timelock.
   */
  function initiateModifyTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval, uint256 extraTime
  ) public onlyOwner {
    // Ensure that a function selector is specified (no 0x00000000 selector).
    require(
      functionSelector != bytes4(0),
      "Function selector cannot be empty."
    );

    // Ensure a timelock interval over eight weeks is not set on this function.
    if (functionSelector == this.modifyTimelockInterval.selector) {
      require(
        newTimelockInterval <= 8 weeks,
        "Timelock interval of modifyTimelockInterval cannot exceed eight weeks."
      );
    }

    // Set the timelock and emit a `TimelockInitiated` event.
    _setTimelock(
      this.modifyTimelockInterval.selector,
      abi.encode(functionSelector, newTimelockInterval),
      extraTime
    );
  }

  /**
   * @notice Sets a new timelock interval for a given function selector. The
   * default for this function may also be modified, but has a maximum allowable
   * value of eight weeks. Only the owner may call this function.
   * @param functionSelector the selector of the function to set the timelock
   * interval for.
   * @param newTimelockInterval The new timelock interval to set for the given
   * function selector.
   */
  function modifyTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) public onlyOwner {
    // Ensure that a function selector is specified (no 0x00000000 selector).
    require(
      functionSelector != bytes4(0),
      "Function selector cannot be empty."
    );

    // Continue via logic in the inherited `_modifyTimelockInterval` function.
    _modifyTimelockInterval(functionSelector, newTimelockInterval);
  }

  /**
   * @notice Sets a new timelock expiration for a given function selector. The
   * default Only the owner may call this function. New expiration durations may
   * not exceed one month.
   * @param functionSelector the selector of the function to set the timelock
   * expiration for.
   * @param newTimelockExpiration The new timelock expiration to set for the
   * given function selector.
   * @param extraTime Additional time in seconds to add to the timelock.
   */
  function initiateTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration, uint256 extraTime
  ) public onlyOwner {
    // Ensure that a function selector is specified (no 0x00000000 selector).
    require(
      functionSelector != bytes4(0),
      "Function selector cannot be empty."
    );

    // Ensure that the supplied default expiration does not exceed 1 month.
    require(
      newTimelockExpiration <= 30 days,
      "New timelock expiration cannot exceed one month."
    );

    // Ensure a timelock expiration under one hour is not set on this function.
    if (functionSelector == this.modifyTimelockExpiration.selector) {
      require(
        newTimelockExpiration >= 60 minutes,
        "Expiration of modifyTimelockExpiration must be at least an hour long."
      );
    }

    // Set the timelock and emit a `TimelockInitiated` event.
    _setTimelock(
      this.modifyTimelockExpiration.selector,
      abi.encode(functionSelector, newTimelockExpiration),
      extraTime
    );
  }

  /**
   * @notice Sets a new timelock expiration for a given function selector. The
   * default for this function may also be modified, but has a minimum allowable
   * value of one hour. Only the owner may call this function.
   * @param functionSelector the selector of the function to set the timelock
   * expiration for.
   * @param newTimelockExpiration The new timelock expiration to set for the
   * given function selector.
   */
  function modifyTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) public onlyOwner {
    // Ensure that a function selector is specified (no 0x00000000 selector).
    require(
      functionSelector != bytes4(0),
      "Function selector cannot be empty."
    );

    // Continue via logic in the inherited `_modifyTimelockExpiration` function.
    _modifyTimelockExpiration(
      functionSelector, newTimelockExpiration
    );
  }

  /**
   * @notice Determine if the deadman's switch has expired and get the time at
   * which it is set to expire (i.e. 90 days from the last heartbeat).
   */
  function heartbeatStatus() public view returns (
    bool expired, uint256 expirationTime
  ) {
    expirationTime = _lastHeartbeat + 90 days;
    expired = now > expirationTime;
  }

  /**
   * @notice Private function that sets a new implementation address on an
   * upgrade beacon contract.
   * @param controller address of controller to call into that will trigger the
   * update to the specified upgrade beacon.
   * @param beacon address of upgrade beacon to set the new implementation on.
   * @param implementation the address of the new implementation.
   */
  function _upgrade(
    address controller, address beacon, address implementation
  ) private {
    // Ensure that the implementaton contract is not the null address.
    require(
      implementation != address(0),
      "Implementation cannot be the null address."
    );

    // Ensure that the implementation contract has code via extcodesize.
    uint256 size;
    assembly {
      size := extcodesize(implementation)
    }
    require(size > 0, "Implementation must have contract code.");

    // Try to get current implementation contract, defaulting to null address.
    address currentImplementation;
    (bool ok, bytes memory returnData) = beacon.call("");
    if (ok && returnData.length == 32) {
      currentImplementation = abi.decode(returnData, (address));
    } else {
      currentImplementation = address(0);
    }

    // Record the last implementation in case it needs to be restored.
    _lastImplementation[controller][beacon] = currentImplementation;

    // Trigger the upgrade to the new implementation contract.
    UpgradeBeaconControllerInterface(controller).upgrade(
      beacon, implementation
    );
  }
}