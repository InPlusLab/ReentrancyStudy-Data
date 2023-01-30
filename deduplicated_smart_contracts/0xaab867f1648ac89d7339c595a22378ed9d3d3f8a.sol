/**
 *Submitted for verification at Etherscan.io on 2019-12-27
*/

// File: contracts/lib/Ownable.sol

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

// File: contracts/lib/Claimable.sol

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

// File: contracts/iface/IDelayedTransaction.sol

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


/// @title IDelayedTransaction
/// @author Brecht Devos - <brecht@loopring.org>
contract IDelayedTransaction
{
    event TransactionDelayed(
        uint    id,
        uint    timestamp,
        address to,
        uint    value,
        bytes   data,
        uint    delay
    );

    event TransactionCancelled(
        uint    id,
        uint    timestamp,
        address to,
        uint    value,
        bytes   data
    );

    event TransactionExecuted(
        uint    timestamp,
        address to,
        uint    value,
        bytes   data
    );

    event PendingTransactionExecuted(
        uint    id,
        uint    timestamp,
        address to,
        uint    value,
        bytes   data
    );

    struct Transaction
    {
        uint    id;
        uint    timestamp;
        address to;
        uint    value;
        bytes   data;
    }

    struct DelayedFunction
    {
        address to;
        bytes4  functionSelector;
        uint    delay;
    }

    // The maximum amount of time (in seconds) a pending transaction can be executed
    // (so the amount of time than can pass after the mandatory function specific delay).
    // If the transaction hasn't been executed before then it can be cancelled so it is removed
    // from the pending transaction list.
    uint public timeToLive;

    // Active list of delayed functions (delay > 0)
    DelayedFunction[] public delayedFunctions;

    // Active list of pending transactions
    Transaction[] public pendingTransactions;

    /// @dev Executes a pending transaction.
    /// @param to The contract address to call
    /// @param data The call data
    function transact(
        address to,
        bytes   calldata data
        )
        external
        payable;

    /// @dev Executes a pending transaction.
    /// @param transactionId The id of the pending transaction.
    function executeTransaction(
        uint transactionId
        )
        external;

    /// @dev Cancels a pending transaction.
    /// @param transactionId The id of the pending transaction.
    function cancelTransaction(
        uint transactionId
        )
        external;

    /// @dev Cancels all pending transactions.
    function cancelAllTransactions()
        external;

    /// @dev Gets the delay for the given function
    /// @param functionSelector The function selector.
    /// @return The delay of the function.
    function getFunctionDelay(
        address to,
        bytes4  functionSelector
        )
        public
        view
        returns (uint);

    /// @dev Gets the number of pending transactions.
    /// @return The number of pending transactions.
    function getNumPendingTransactions()
        external
        view
        returns (uint);

    /// @dev Gets the number of functions that have a delay.
    /// @return The number of delayed functions.
    function getNumDelayedFunctions()
        external
        view
        returns (uint);
}

// File: contracts/lib/AddressUtil.sol

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


/// @title Utility Functions for addresses
/// @author Daniel Wang - <daniel@loopring.org>
/// @author Brecht Devos - <brecht@loopring.org>
library AddressUtil
{
    using AddressUtil for *;

    function isContract(
        address addr
        )
        internal
        view
        returns (bool)
    {
        uint32 size;
        assembly { size := extcodesize(addr) }
        return (size > 0);
    }

    function toPayable(
        address addr
        )
        internal
        pure
        returns (address payable)
    {
        return address(uint160(addr));
    }

    // Works like address.send but with a customizable gas limit
    // Make sure your code is safe for reentrancy when using this function!
    function sendETH(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {
        if (amount == 0) {
            return true;
        }
        address payable recipient = to.toPayable();
        /* solium-disable-next-line */
        (success, ) = recipient.call.value(amount).gas(gasLimit)("");
    }

    // Works like address.transfer but with a customizable gas limit
    // Make sure your code is safe for reentrancy when using this function!
    function sendETHAndVerify(
        address to,
        uint    amount,
        uint    gasLimit
        )
        internal
        returns (bool success)
    {
        success = to.sendETH(amount, gasLimit);
        require(success, "TRANSFER_FAILURE");
    }
}

// File: contracts/lib/BytesUtil.sol

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


/// @title Utility Functions for bytes
/// @author Daniel Wang - <daniel@loopring.org>
library BytesUtil
{
    function bytesToBytes32(
        bytes memory b,
        uint  offset
        )
        internal
        pure
        returns (bytes32)
    {
        return bytes32(bytesToUintX(b, offset, 32));
    }

    function bytesToUint(
        bytes memory b,
        uint  offset
        )
        internal
        pure
        returns (uint)
    {
        return bytesToUintX(b, offset, 32);
    }

    function bytesToAddress(
        bytes memory b,
        uint  offset
        )
        internal
        pure
        returns (address)
    {
        return address(bytesToUintX(b, offset, 20) & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function bytesToUint16(
        bytes memory b,
        uint  offset
        )
        internal
        pure
        returns (uint16)
    {
        return uint16(bytesToUintX(b, offset, 2) & 0xFFFF);
    }

    function bytesToBytes4(
        bytes memory b,
        uint  offset
        )
        internal
        pure
        returns (bytes4 data)
    {
        return bytes4(bytesToBytesX(b, offset, 4) & 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000);
    }

    function bytesToBytesX(
        bytes memory b,
        uint  offset,
        uint  numBytes
        )
        private
        pure
        returns (bytes32 data)
    {
        require(b.length >= offset + numBytes, "INVALID_SIZE");
        assembly {
            data := mload(add(b, add(32, offset)))
        }
    }

    function bytesToUintX(
        bytes memory b,
        uint  offset,
        uint  numBytes
        )
        private
        pure
        returns (uint data)
    {
        require(b.length >= offset + numBytes, "INVALID_SIZE");
        assembly {
            data := mload(add(add(b, numBytes), offset))
        }
    }

    function subBytes(
        bytes memory b,
        uint  offset
        )
        internal
        pure
        returns (bytes memory data)
    {
        require(b.length >= offset + 32, "INVALID_SIZE");
        assembly {
            data := add(add(b, 32), offset)
        }
    }

    function fastSHA256(
        bytes memory data
        )
        internal
        view
        returns (bytes32)
    {
        bytes32[] memory result = new bytes32[](1);
        bool success;
        assembly {
             let ptr := add(data, 32)
             success := staticcall(sub(gas, 2000), 2, ptr, mload(data), add(result, 32), 32)
        }
        require(success, "SHA256_FAILED");
        return result[0];
    }
}

// File: contracts/lib/MathUint.sol

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


/// @title Utility Functions for uint
/// @author Daniel Wang - <daniel@loopring.org>
library MathUint
{
    function mul(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {
        c = a * b;
        require(a == 0 || c / a == b, "MUL_OVERFLOW");
    }

    function sub(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint)
    {
        require(b <= a, "SUB_UNDERFLOW");
        return a - b;
    }

    function add(
        uint a,
        uint b
        )
        internal
        pure
        returns (uint c)
    {
        c = a + b;
        require(c >= a, "ADD_OVERFLOW");
    }

    function decodeFloat(
        uint f
        )
        internal
        pure
        returns (uint value)
    {
        uint numBitsMantissa = 23;
        uint exponent = f >> numBitsMantissa;
        uint mantissa = f & ((1 << numBitsMantissa) - 1);
        value = mantissa * (10 ** exponent);
    }
}

// File: contracts/impl/DelayedTransaction.sol

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






/// @title DelayedOwner
/// @author Brecht Devos - <brecht@loopring.org>
/// @dev Base class for an Owner contract where certain functions have
///      a mandatory delay for security purposes.
contract DelayedTransaction is IDelayedTransaction
{
    using AddressUtil for address payable;
    using BytesUtil   for bytes;
    using MathUint    for uint;

    // Map from address and function to the functions's location+1 in the `delayedFunctions` array.
    mapping (address => mapping (bytes4 => uint)) private delayedFunctionMap;

    // Map from transaction ID to the transaction's location+1 in the `pendingTransactions` array.
    mapping (uint => uint) private pendingTransactionMap;

    // Used to generate a unique identifier for a delayed transaction
    uint private totalNumDelayedTransactions = 0;

    modifier onlyAuthorized
    {
        require(isAuthorizedForTransactions(msg.sender), "UNAUTHORIZED");
        _;
    }

    constructor(
        uint    _timeToLive
        )
        public
    {
        timeToLive = _timeToLive;
    }

    // If the function that is called has no delay the function is called immediately,
    // otherwise the function call is stored on-chain and can be executed later using
    // `executeTransaction` when the necessary time has passed.
    function transact(
        address to,
        bytes   calldata data
        )
        external
        payable
        onlyAuthorized
    {
        transactInternal(to, msg.value, data);
    }

    function executeTransaction(
        uint transactionId
        )
        external
        onlyAuthorized
    {
        Transaction memory transaction = getTransaction(transactionId);

        // Make sure the delay is respected
        bytes4 functionSelector = transaction.data.bytesToBytes4(0);
        uint delay = getFunctionDelay(transaction.to, functionSelector);
        require(now >= transaction.timestamp.add(delay), "TOO_EARLY");
        require(now <= transaction.timestamp.add(delay).add(timeToLive), "TOO_LATE");

        // Remove the transaction
        removeTransaction(transaction.id);

        // Exectute the transaction
        (bool success, bytes memory returnData) = exectuteTransaction(transaction);

        emit PendingTransactionExecuted(
            transaction.id,
            transaction.timestamp,
            transaction.to,
            transaction.value,
            transaction.data
        );

        // Return the same data the original transaction would
        // (this will return the data even though this function doesn't have a return value in solidity)
        assembly {
            switch success
            case 0 { revert(add(returnData, 32), mload(returnData)) }
            default { return(add(returnData, 32), mload(returnData)) }
        }
    }

    function cancelTransaction(
        uint transactionId
        )
        external
        onlyAuthorized
    {
        cancelTransactionInternal(transactionId);
    }

    function cancelAllTransactions()
        external
        onlyAuthorized
    {
        // First cache all transactions ids of the transactions we will remove
        uint[] memory transactionIds = new uint[](pendingTransactions.length);
        for(uint i = 0; i < pendingTransactions.length; i++) {
            transactionIds[i] = pendingTransactions[i].id;
        }
        // Now remove all delayed transactions
        for(uint i = 0; i < transactionIds.length; i++) {
            cancelTransactionInternal(transactionIds[i]);
        }
    }

    function getFunctionDelay(
        address to,
        bytes4  functionSelector
        )
        public
        view
        returns (uint)
    {
        uint pos = delayedFunctionMap[to][functionSelector];
        if (pos == 0) {
            return 0;
        } else {
            return delayedFunctions[pos - 1].delay;
        }
    }

    function getNumPendingTransactions()
        external
        view
        returns (uint)
    {
        return pendingTransactions.length;
    }

    function getNumDelayedFunctions()
        external
        view
        returns (uint)
    {
        return delayedFunctions.length;
    }

    // == Internal Functions ==

    function transactInternal(
        address to,
        uint    value,
        bytes   memory data
        )
        internal
    {
        Transaction memory transaction = Transaction(
            totalNumDelayedTransactions,
            now,
            to,
            value,
            data
        );

        bytes4 functionSelector = transaction.data.bytesToBytes4(0);
        uint delay = getFunctionDelay(transaction.to, functionSelector);
        if (delay == 0) {
            (bool success, bytes memory returnData) = exectuteTransaction(transaction);
            emit TransactionExecuted(
                transaction.timestamp,
                transaction.to,
                transaction.value,
                transaction.data
            );
            // Return the same data the original transaction would
            // (this will return the data even though this function doesn't have a return value in solidity)
            assembly {
                switch success
                case 0 { revert(add(returnData, 32), mload(returnData)) }
                default { return(add(returnData, 32), mload(returnData)) }
            }
        } else {
            pendingTransactions.push(transaction);
            pendingTransactionMap[transaction.id] = pendingTransactions.length;
            emit TransactionDelayed(
                transaction.id,
                transaction.timestamp,
                transaction.to,
                transaction.value,
                transaction.data,
                delay
            );
            totalNumDelayedTransactions++;
        }
    }

    function setFunctionDelay(
        address to,
        bytes4  functionSelector,
        uint    delay
        )
        internal
    {
        // Check if the function already has a delay
        uint pos = delayedFunctionMap[to][functionSelector];
        if (pos > 0) {
            if (delay > 0) {
                // Just update the delay
                delayedFunctions[pos - 1].delay = delay;
            } else {
                // Remove the delayed function
                uint size = delayedFunctions.length;
                if (pos != size) {
                    DelayedFunction memory lastOne = delayedFunctions[size - 1];
                    delayedFunctions[pos - 1] = lastOne;
                    delayedFunctionMap[lastOne.to][lastOne.functionSelector] = pos;
                }
                delayedFunctions.length -= 1;
                delete delayedFunctionMap[to][functionSelector];
            }
        } else if (delay > 0) {
            // Add the new delayed function
            DelayedFunction memory delayedFunction = DelayedFunction(
                to,
                functionSelector,
                delay
            );
            delayedFunctions.push(delayedFunction);
            delayedFunctionMap[to][functionSelector] = delayedFunctions.length;
        }
    }

    function exectuteTransaction(
        Transaction memory transaction
        )
        internal
        returns (bool success, bytes memory returnData)
    {
        // solium-disable-next-line security/no-call-value
        (success, returnData) = transaction.to.call.value(transaction.value)(transaction.data);
    }

    function cancelTransactionInternal(
        uint transactionId
        )
        internal
    {
        Transaction memory transaction = getTransaction(transactionId);

        // Remove the transaction
        removeTransaction(transaction.id);

        emit TransactionCancelled(
            transaction.id,
            transaction.timestamp,
            transaction.to,
            transaction.value,
            transaction.data
        );

        // Return the transaction value (if there is any)
        uint value = transaction.value;
        if (value > 0) {
            msg.sender.sendETHAndVerify(value, gasleft());
        }
    }

    function getTransaction(
        uint transactionId
        )
        internal
        view
        returns (Transaction storage transaction)
    {
        uint pos = pendingTransactionMap[transactionId];
        require(pos != 0, "TRANSACTION_NOT_FOUND");
        transaction = pendingTransactions[pos - 1];
    }

    function removeTransaction(
        uint transactionId
        )
        internal
    {
        uint pos = pendingTransactionMap[transactionId];
        require(pos != 0, "TRANSACTION_NOT_FOUND");

        uint size = pendingTransactions.length;
        if (pos != size) {
            Transaction memory lastOne = pendingTransactions[size - 1];
            pendingTransactions[pos - 1] = lastOne;
            pendingTransactionMap[lastOne.id] = pos;
        }

        pendingTransactions.length -= 1;
        delete pendingTransactionMap[transactionId];
    }

    function isAuthorizedForTransactions(address sender)
        internal
        view
        returns (bool);
}

// File: contracts/impl/owners/DelayedOwner.sol

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




/// @title  DelayedOwner
/// @author Brecht Devos - <brecht@loopring.org>
contract DelayedOwner is DelayedTransaction, Claimable
{
    address public defaultContract;

    constructor(
        address _defaultContract,
        uint    _timeToLive
        )
        DelayedTransaction(_timeToLive)
        public
    {
        defaultContract = _defaultContract;
    }

    function()
        external
        payable
    {
        // Don't do anything if msg.sender isn't the owner (e.g. when receiving ETH)
        if (msg.sender != owner) {
            return;
        }
        transactInternal(defaultContract, msg.value, msg.data);
    }

    function isAuthorizedForTransactions(address sender)
        internal
        view
        returns (bool)
    {
        return sender == owner;
    }

    function setFunctionDelay(
        bytes4  functionSelector,
        uint    delay
        )
        internal
    {
        setFunctionDelay(defaultContract, functionSelector, delay);
    }
}

// File: contracts/lib/ReentrancyGuard.sol

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

// File: contracts/iface/IImplementationManager.sol

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
}

// File: contracts/impl/owners/ImplementationManagerOwner.sol

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




/// @title ImplementationManagerOwner
/// @author Brecht Devos - <brecht@loopring.org>
contract ImplementationManagerOwner is DelayedOwner
{
    constructor(
        IImplementationManager implementationManager
        )
        DelayedOwner(address(implementationManager), 3 days)
        public
    {
        setFunctionDelay(implementationManager.transferOwnership.selector, 7 days);
        setFunctionDelay(implementationManager.register.selector, 1 days);
        setFunctionDelay(implementationManager.setDefault.selector, 7 days);
        setFunctionDelay(implementationManager.enable.selector, 7 days);
        setFunctionDelay(implementationManager.disable.selector, 1 days);
    }
}