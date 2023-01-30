/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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
pragma solidity ^0.5.11;


/// @title ReentrancyGuard
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Exposes a modifier that guards a function against reentrancy
///      Changing the value of the same storage value multiple times in a transaction
///      is cheap (starting from Istanbul) so there is no need to minimize
///      the number of times the value is changed
contract ReentrancyGuard
{
    //The default value must be 0 in order to work behind a proxy.
    uint private _guardValue;

    // Use this modifier on a function to prevent reentrancy
    modifier nonReentrant()
    {
        // Check if the guard value has its original value
        require(_guardValue == 0, "REENTRANCY");

        // Set the value to something else
        _guardValue = 1;

        // Function body
        _;

        // Set the value back
        _guardValue = 0;
    }
}
/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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



/// @title Ownable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".
contract Ownable
{
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @dev The Ownable constructor sets the original `owner` of the contract
    ///      to the sender.
    constructor()
        public
    {
        owner = msg.sender;
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner()
    {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    /// @dev Allows the current owner to transfer control of the contract to a
    ///      new owner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        public
        onlyOwner
    {
        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership()
        public
        onlyOwner
    {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}



/// @title Claimable
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Extension for the Ownable contract, where the ownership needs
///      to be claimed. This allows the new owner to accept the transfer.
contract Claimable is Ownable
{
    address public pendingOwner;

    /// @dev Modifier throws if called by any account other than the pendingOwner.
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    /// @dev Allows the current owner to set the pendingOwner address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        public
        onlyOwner
    {
        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    /// @dev Allows the pendingOwner address to finalize the transfer.
    function claimOwnership()
        public
        onlyPendingOwner
    {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}
/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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






/// @title IUniversalRegistry
/// @dev This contract manages all registered ILoopring versions and all Loopring
///      based exchanges.
///
/// @author Daniel Wang  - <daniel@loopring.org>
contract IUniversalRegistry is Claimable, ReentrancyGuard
{
    enum ForgeMode {
        AUTO_UPGRADABLE,
        MANUAL_UPGRADABLE,
        PROXIED,
        NATIVE
    }

    /// === Events ===

    event ProtocolRegistered (
        address indexed protocol,
        address indexed implementationManager,
        string          version
    );

    event ProtocolEnabled (
        address indexed protocol
    );

    event ProtocolDisabled (
        address indexed protocol
    );

    event DefaultProtocolChanged (
        address indexed oldDefault,
        address indexed newDefault
    );

    event ExchangeForged (
        address indexed protocol,
        address indexed implementation,
        address indexed exchangeAddress,
        address         owner,
        ForgeMode       forgeMode,
        bool            onchainDataAvailability,
        uint            exchangeId,
        uint            amountLRCBurned
    );

    /// === Data ===

    address   public lrcAddress;
    address[] public exchanges;
    address[] public protocols;

    // IProtocol.version => IProtocol address
    mapping (string => address) public versionMap;

    /// === Functions ===

    /// @dev Registers a new protocol.
    /// @param protocol The address of the new protocol.
    /// @param implementation The new protocol's default implementation.
    /// @return implManager A new implementation manager to manage the protocol's implementations.
    function registerProtocol(
        address protocol,
        address implementation
        )
        external
        returns (address implManager);

    /// @dev Sets the default protocol.
    /// @param protocol The new default protocol.
    function setDefaultProtocol(
        address protocol
        )
        external;

    /// @dev Enables a protocol.
    /// @param protocol The address of the protocol.
    function enableProtocol(
        address protocol
        )
        external;

    /// @dev Disables a protocol.
    /// @param protocol The address of the protocol.
    function disableProtocol(
        address protocol
        )
        external;

    /// @dev Creates a new exchange using a specific protocol with msg.sender
    ///      as owner and operator.
    /// @param forgeMode The forge mode.
    /// @param onchainDataAvailability IF the on-chain DA is on
    /// @param protocol The protocol address, use 0x0 for default.
    /// @param implementation The implementation to use, use 0x0 for default.
    /// @return exchangeAddress The new exchange's address
    /// @return exchangeId The new exchange's ID.
    function forgeExchange(
        ForgeMode forgeMode,
        bool      onchainDataAvailability,
        address   protocol,
        address   implementation
        )
        external
        returns (
            address exchangeAddress,
            uint    exchangeId
        );

    /// @dev Returns information regarding the default protocol.
    /// @return protocol The address of the default protocol.
    /// @return implManager The address of the default protocol's implementation manager.
    /// @return defaultImpl The default protocol's default implementation address.
    /// @return defaultImplVersion The version of the default implementation.
    function defaultProtocol()
        public
        view
        returns (
            address protocol,
            address versionmanager,
            address defaultImpl,
            string  memory protocolVersion,
            string  memory defaultImplVersion
        );

    /// @dev Checks if a protocol has been registered.
    /// @param protocol The address of the protocol.
    /// @return registered True if the prococol is registered.
    function isProtocolRegistered(
        address protocol
        )
        public
        view
        returns (bool registered);

    /// @dev Checks if a protocol has been enabled.
    /// @param protocol The address of the protocol.
    /// @return enabled True if the prococol is registered and enabled.
    function isProtocolEnabled(
        address protocol
        )
        public
        view
        returns (bool enabled);

    /// @dev Checks if the addres is a registered Loopring exchange.
    /// @return registered True if the address is a registered exchange.
    function isExchangeRegistered(
        address exchange
        )
        public
        view
        returns (bool registered);

    /// @dev Checks if the given protocol and implementation are both registered and enabled.
    /// @param protocol The address of the protocol.
    /// @param implementation The address of the implementation.
    /// @return enabled True if both the protocol and the implementation are registered and enabled.
    function isProtocolAndImplementationEnabled(
        address protocol,
        address implementation
        )
        public
        view
        returns (bool enabled);

    /// @dev Returns the protocol associated with an exchange.
    /// @param exchangeAddress The address of the exchange.
    /// @return protocol The protocol address.
    /// @return implementation The protocol's implementation.
    /// @return enabled Whether the protocol is enabled.
    function getExchangeProtocol(
        address exchangeAddress
        )
        public
        view
        returns (
            address protocol,
            address implementation
        );
}/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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






/// @title IImplementationManager
/// @dev This contract manages implementation versions for a specific ILoopring
///      contract. The ILoopring contract can be considered as the "major" version
///      of a Loopring protocol and each IExchange implementation can be considered
///      as a "minor" version. Multiple IExchange contracts can use the same
///      ILoopring contracts.
///
/// @author Daniel Wang  - <daniel@loopring.org>
contract IImplementationManager is Claimable, ReentrancyGuard
{
    /// === Events ===

    event DefaultChanged (
        address indexed oldDefault,
        address indexed newDefault
    );

    event Registered (
        address indexed implementation,
        string          version
    );

    event Enabled (
        address indexed implementation
    );

    event Disabled (
        address indexed implementation
    );

    /// === Data ===

    address   public protocol;
    address   public defaultImpl;
    address[] public implementations;

    // version strings => IExchange addresses
    mapping (string => address) public versionMap;

    /// === Functions ===

    /// @dev Registers a new implementation.
    /// @param implementation The implemenation to add.
    function register(
        address implementation
        )
        external;

    /// @dev Sets the default implemenation.
    /// @param implementation The new default implementation.
    function setDefault(
        address implementation
        )
        external;

    /// @dev Enables an implemenation.
    /// @param implementation The implementation to be enabled.
    function enable(
        address implementation
        )
        external;

    /// @dev Disables an implemenation.
    /// @param implementation The implementation to be disabled.
    function disable(
        address implementation
        )
        external;

    /// @dev Returns version information.
    /// @return protocolVersion The protocol's version.
    /// @return defaultImplVersion The default implementation's version.
    function version()
        public
        view
        returns (
            string  memory protocolVersion,
            string  memory defaultImplVersion
        );

    /// @dev Returns the latest implemenation added.
    /// @param implementation The latest implemenation added.
    function latest()
        public
        view
        returns (address implementation);

    /// @dev Returns if an implementation has been registered.
    /// @param registered True if the implementation is registered.
    function isRegistered(
        address implementation
        )
        public
        view
        returns (bool registered);

    /// @dev Returns if an implementation has been registered and enabled.
    /// @param enabled True if the implementation is registered and enabled.
    function isEnabled(
        address implementation
        )
        public
        view
        returns (bool enabled);
}/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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


/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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


// This code is taken from https://github.com/OpenZeppelin/openzeppelin-labs
// with minor modifications.




/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
  function implementation() public view returns (address);

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable external {
    address _impl = implementation();
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}





/// @title IExchangeProxy
/// @author Daniel Wang  - <daniel@loopring.org>
contract IExchangeProxy is Proxy
{
    bytes32 private constant registryPosition = keccak256(
        "org.loopring.protocol.v3.registry"
    );

    constructor(address _registry)
        public
    {
        setRegistry(_registry);
    }

    /// @dev Returns the exchange's registry address.
    function registry()
        public
        view
        returns (address registryAddress)
    {
        bytes32 position = registryPosition;
        assembly { registryAddress := sload(position) }
    }

    /// @dev Returns the exchange's protocol address.
    function protocol()
        public
        view
        returns (address protocolAddress)
    {
        IUniversalRegistry r = IUniversalRegistry(registry());
        (protocolAddress, ) = r.getExchangeProtocol(address(this));
    }

    function setRegistry(address _registry)
        private
    {
        require(_registry != address(0), "ZERO_ADDRESS");
        bytes32 position = registryPosition;
        assembly { sstore(position, _registry) }
    }
}




/// @title AutoUpgradabilityProxy
/// @dev This proxy is designed to support automatic upgradability.
/// @author Daniel Wang  - <daniel@loopring.org>
contract AutoUpgradabilityProxy is IExchangeProxy
{
    constructor(address _registry) public IExchangeProxy(_registry) {}

    function implementation()
        public
        view
        returns (address)
    {
        IUniversalRegistry r = IUniversalRegistry(registry());
        (, address managerAddr) = r.getExchangeProtocol(address(this));
        return IImplementationManager(managerAddr).defaultImpl();
    }
}