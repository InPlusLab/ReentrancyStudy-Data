/**
 *Submitted for verification at Etherscan.io on 2019-10-16
*/

pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg


interface DharmaKeyRegistryInterface {
  event NewGlobalKey(address oldGlobalKey, address newGlobalKey);

  function setGlobalKey(address globalKey, bytes calldata signature) external;
  function setSpecificKey(address account, address specificKey) external;
  function getKey() external view returns (address key);
  function getKeyForUser(address account) external view returns (address key);
  function getGlobalKey() external view returns (address globalKey);
  function getSpecificKey(address account) external view returns (address specificKey);
}


library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
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
 * @title DharmaKeyRegistryV2
 * @author 0age
 * @notice The Dharma Key Registry is an owned contract that holds the public
 * user signing keys that will be used by the Dharma Smart Wallet. Each time a
 * particular Dharma Smart Wallet instance needs to validate a signature, it
 * will first retrieve the public address for the secondary signing key
 * associated with that wallet from the Dharma Key Registry. If a specific key
 * has not been set for that smart wallet, it will return the global public key.
 * Otherwise, it will return the specific signing key. Additional view functions
 * are also provided for retrieving public keys directly. Only the owner may
 * update these keys. Also, note that the V2 key registry includes an additional
 * mapping to track all global keys that have been used, and only allows a given
 * global key to be set one time.
 */
contract DharmaKeyRegistryV2 is TwoStepOwnable, DharmaKeyRegistryInterface {
  using ECDSA for bytes32;

  // The global public key serves as the default signing key.
  address private _globalKey;

  // Specific keys may also be set on a per-caller basis.
  mapping (address => address) private _specificKeys;

  // Maintain a mapping of all used global keys (to prevent reuse).
  mapping (address => bool) private _usedGlobalKeys;

  /**
   * @notice In the constructor, set the initial global key and the initial
   * owner to tx.origin.
   */
  constructor() public {
    // Initially set the global key to the account of the transaction submitter.
    _registerGlobalKey(tx.origin);
  }

  /**
   * @notice Set a new global key. This method may only be called by the owner,
   * and a signature must also be provided in order to verify that the provided
   * global public key has a corresponding private key that can be used to sign
   * messages.
   * @param globalKey address The new global public key.
   * @param signature bytes A signature of a message hash containing the address
   * of this contract, the new global key, and a specific message, that must
   * resolve to the supplied global key.
   */
  function setGlobalKey(
    address globalKey,
    bytes calldata signature
  ) external onlyOwner {
    // Ensure that the provided global key is not the null address.
    require(globalKey != address(0), "A global key must be supplied.");

    // Message hash constructed according to EIP-191-0x45 to prevent replays.
    bytes32 messageHash = keccak256(
      abi.encodePacked(
        address(this),
        globalKey,
        "This signature demonstrates that the supplied signing key is valid."
      )
    );

    // Recover the signer of the message hash using the provided signature.
    address signer = messageHash.toEthSignedMessageHash().recover(signature);

    // Ensure that the provided signature resolves to the provided global key.
    require(globalKey == signer, "Invalid signature for supplied global key.");

    // Update global key to the provided global key and prevent future reuse.
    _registerGlobalKey(globalKey);
  }

  /**
   * @notice Set a new specific key for a particular account. This method may
   * only be called by the owner. Signatures are not required in order to make
   * setting specific keys more efficient at scale. Providing the null address
   * for the specific key will remove a specific key from the given account.
   * @param account address The account to set the new specific public key for.
   * @param specificKey address The new specific public key.
   */
  function setSpecificKey(
    address account,
    address specificKey
  ) external onlyOwner {
    // Update specific key for provided account to the provided specific key.
    _specificKeys[account] = specificKey;
  }

  /**
   * @notice Get the public key associated with the caller of this function. If
   * a specific key is set for the caller, it will be returned; otherwise, the
   * global key will be returned.
   * @return The public key to use for the caller.
   */
  function getKey() external view returns (address key) {
    // Retrieve the specific key, if any, for the caller.
    key = _specificKeys[msg.sender];

    // Fall back to the global key in the event that no specific key is set.
    if (key == address(0)) {
      key = _globalKey;
    }
  }

  /**
   * @notice Get the public key associated with a particular account. If a
   * specific key is set for the account, it will be returned; otherwise, the
   * global key will be returned.
   * @param account address The account to find the public key for.
   * @return The public key to use for the provided account.
   */
  function getKeyForUser(address account) external view returns (address key) {
    // Retrieve the specific key, if any, for the specified account.
    key = _specificKeys[account];

    // Fall back to the global key in the event that no specific key is set.
    if (key == address(0)) {
      key = _globalKey;
    }
  }

  /**
   * @notice Get the global public key.
   * @return The global public key.
   */
  function getGlobalKey() external view returns (address globalKey) {
    // Retrieve and return the global key.
    globalKey = _globalKey;
  }

  /**
   * @notice Get the specific public key associated with the supplied account.
   * The call will revert if a specific public key is not set for the account.
   * @param account address The account to find the specific public key for.
   * @return The specific public key set on the provided account, if one exists.
   */
  function getSpecificKey(
    address account
  ) external view returns (address specificKey) {
    // Retrieve the specific key, if any, for the account.
    specificKey = _specificKeys[account];

    // Revert in the event that there is no specific key set.
    require(
      specificKey != address(0),
      "No specific key set for the provided account."
    );
  }

  /**
   * @notice Internal function to set a new global key once contract ownership
   * and signature validity have both been checked, or during contract creation.
   * The provided global key must not have been used previously, and once set it
   * will be registered as having been used.
   * @param globalKey address The new global public key.
   */
  function _registerGlobalKey(address globalKey) internal {
    // Ensure that the global key has not been used previously.
    require(!_usedGlobalKeys[globalKey], "Key has been used previously.");

    // Emit an event signifying that the global key has been modified.
    emit NewGlobalKey(_globalKey, globalKey);

    // Update the global key to the provided global key.
    _globalKey = globalKey;

    // Mark the key as having been used previously.
    _usedGlobalKeys[globalKey] = true;
  }
}