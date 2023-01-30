/**
 *Submitted for verification at Etherscan.io on 2019-10-23
*/

// File: contracts/common/upgradeability/Delegatable.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;


/// @title Delegatable
/// @notice Implements delegation of calls to other contracts, with proper
/// 	forwarding of return values and bubbling of failures.
contract Delegatable {

    /// @dev Delegates execution to an implementation contract.
    /// 	This is a low level function that doesn't return to its internal call site.
    /// 	It will return to the external caller whatever the implementation returns.
    /// @param implementation Address to delegate.
    function _delegate(address implementation) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }
}

// File: contracts/common/upgradeability/Proxy.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;



/// @title Proxy
/// @notice Implements delegation of calls to other contracts, with proper
/// 	forwarding of return values and bubbling of failures.
/// 	It defines a fallback function that delegates all calls to the address
/// 	returned by the abstract _implementation() internal function.
contract Proxy is Delegatable {

    /// @notice Fallback function.
    /// Implemented entirely in `_fallback`.
    function () external payable {
        _fallback();
    }

    /// @return The Address of the implementation.
    function _implementation() internal view returns (address);

    /// @dev Function that is run as the first thing in the fallback function.
    /// 	Can be redefined in derived contracts to add functionality.
    /// 	Redefinitions must call super._willFallback().
    function _willFallback() internal {
    }

    /// @dev fallback implementation.
    /// 	Extracted to enable manual triggering.
    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

// File: contracts/libs/Address.sol

pragma solidity ^0.4.25;

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */
library LaborxAddressLib {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: contracts/common/upgradeability/BaseUpgradeabilityProxy.sol

/**
 * Copyright 2017每2019, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.25;




/// @title BaseUpgradeabilityProxy
/// @notice This contract implements a proxy that allows to change the
/// implementation address to which it will delegate.
/// Such a change is called an implementation upgrade.
contract BaseUpgradeabilityProxy is Proxy {

    /// @dev Emitted when the implementation is upgraded.
    /// @param implementation Address of the new implementation.
    event Upgraded(address indexed implementation);

    /// @dev Storage slot with the address of the current implementation.
    /// This is the keccak-256 hash of "io.laborx.proxy.implementation", and is
    /// validated in the constructor.
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x00dce392765b11486902ac3a76afbfed3e68464872bbbc647d8773854f05fedb;

    /// @dev Returns the current implementation.
    /// @return Address of the current implementation
    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    /// @dev Upgrades the proxy to a new implementation.
    /// @param newImplementation Address of the new implementation.
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /// @dev Sets the implementation address of the proxy.
    /// @param newImplementation Address of the new implementation.
    function _setImplementation(address newImplementation) internal {
        require(LaborxAddressLib.isContract(newImplementation), "PROXY_CANNOT_SET_NON_CONTRACT");

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }
}

// File: contracts/common/upgradeability/UpgradeabilityProxy.sol

/**
* Copyright 2017每2019, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.25;



/// @title UpgradeabilityProxy
/// @dev Extends BaseUpgradeabilityProxy with a constructor for initializing
///     implementation and init data.
contract UpgradeabilityProxy is BaseUpgradeabilityProxy {

    /// @dev Contract constructor.
    /// @param _logic Address of the initial implementation.
    /// @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
    ///
    /// It should include the signature and the parameters of the function to be called, as described in
    /// https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
    /// This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
    constructor(address _logic, bytes memory _data) public payable {
        assert(IMPLEMENTATION_SLOT == keccak256("io.laborx.proxy.implementation"));

        _setImplementation(_logic);

        if (_data.length > 0) {
            (bool success,) = _logic.delegatecall(_data);
            require(success, "PROXY_INIT_FAILED");
        }
    }
}

// File: contracts/common/upgradeability/OwnedUpgradeabilityProxy.sol

/**
* Copyright 2017每2019, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.25;



/// @title OwnedUpgradeabilityProxy
/// @dev This contract combines an upgradeability proxy with basic authorization control functionalities
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    /// @dev Event to show ownership has been transferred
    /// @param previousOwner representing the address of the previous owner
    /// @param newOwner representing the address of the new owner
    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    /// @dev Storage slot of the owner of the contract
    /// This is the keccak-256 hash of "io.laborx.proxy.implementation"
    bytes32 private constant PROXY_OWNER_SLOT = 0x9f0cb10b07044a26ed5e46aa863117e6277a419ad770761a6659221f518998bd;

    /// @dev the constructor sets the original owner of the contract to the sender account.
    constructor(address _logic, bytes memory _data) public UpgradeabilityProxy(_logic, _data) {
        _setUpgradeabilityOwner(msg.sender);
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner(), "PROXY_OWNER_ONLY");
        _;
    }

    /// @notice Tells the address of the owner
    /// @return the address of the owner
    function proxyOwner() public view returns (address owner) {
        bytes32 slot = PROXY_OWNER_SLOT;
        assembly {
            owner := sload(slot)
        }
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferProxyOwnership(address newOwner) external onlyProxyOwner {
        require(newOwner != address(0), "PROXY_INVALID_NEW_OWNER");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        _setUpgradeabilityOwner(newOwner);
    }

    /// @notice Allows the proxy owner to upgrade the current version of the proxy.
    /// @param implementation representing the address of the new implementation to be set.
    function upgradeTo(address implementation) public onlyProxyOwner {
        _upgradeTo(implementation);
    }

    /// @notice Allows the proxy owner to upgrade the current version of the proxy and call the new implementation
    ///     to initialize whatever is needed through a low level call.
    /// @param implementation representing the address of the new implementation to be set.
    /// @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
    ///     signature of the implementation to be called with the needed payload
    function upgradeToAndCall(address implementation, bytes data) external payable onlyProxyOwner {
        upgradeTo(implementation);
        require(this.call.value(msg.value)(data), "PROXY_FAILED_CALL");
    }

    /// @dev Sets the address of the owner
    function _setUpgradeabilityOwner(address newProxyOwner) internal {
        bytes32 slot = PROXY_OWNER_SLOT;
        assembly {
            sstore(slot, newProxyOwner)
        }
    }
}