/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

pragma experimental ABIEncoderV2;
// File: contracts/modules/common/Utils.sol
// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
// SPDX-License-Identifier: GPL-3.0-only
/**
 * @title Utils
 * @notice Common utility methods used by modules.
 */
library Utils {
    /**
    * @notice Helper method to recover the signer at a given position from a list of concatenated signatures.
    * @param _signedHash The signed hash
    * @param _signatures The concatenated signatures.
    * @param _index The index of the signature to recover.
    */
    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        // we jump 32 (0x20) as the first slot of bytes contains the length
        // we jump 65 (0x41) per signature
        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28);
        address recoveredAddress = ecrecover(_signedHash, v, r, s);
        require(recoveredAddress != address(0), "Utils: ecrecover returned 0");
        return recoveredAddress;
    }
    /**
    * @notice Helper method to parse data and extract the method signature.
    */
    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {
        require(_data.length >= 4, "RM: Invalid functionPrefix");
        // solhint-disable-next-line no-inline-assembly
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }
    /**
    * @notice Returns ceil(a / b).
    */
    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        if (a % b == 0) {
            return c;
        } else {
            return c + 1;
        }
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return a;
        }
        return b;
    }
}
// File: contracts/infrastructure/base/Owned.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
/**
 * @title Owned
 * @notice Basic contract to define an owner.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract Owned {
    // The owner
    address public owner;
    event OwnerChanged(address indexed _newOwner);
    /**
     * @notice Throws if the sender is not the owner.
     */
    modifier onlyOwner {
        require(msg.sender == owner, "Must be owner");
        _;
    }
    constructor() public {
        owner = msg.sender;
    }
    /**
     * @notice Lets the owner transfer ownership of the contract to a new owner.
     * @param _newOwner The new owner.
     */
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}
// File: contracts/infrastructure/storage/ITransferStorage.sol
// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
/**
 * @title ITransferStorage
 * @notice TransferStorage interface
 */
interface ITransferStorage {
    function setWhitelist(address _wallet, address _target, uint256 _value) external;
    function getWhitelist(address _wallet, address _target) external view returns (uint256);
}
// File: contracts/infrastructure/storage/IGuardianStorage.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
interface IGuardianStorage {
    /**
     * @notice Lets an authorised module add a guardian to a wallet.
     * @param _wallet The target wallet.
     * @param _guardian The guardian to add.
     */
    function addGuardian(address _wallet, address _guardian) external;
    /**
     * @notice Lets an authorised module revoke a guardian from a wallet.
     * @param _wallet The target wallet.
     * @param _guardian The guardian to revoke.
     */
    function revokeGuardian(address _wallet, address _guardian) external;
    /**
     * @notice Checks if an account is a guardian for a wallet.
     * @param _wallet The target wallet.
     * @param _guardian The account.
     * @return true if the account is a guardian for a wallet.
     */
    function isGuardian(address _wallet, address _guardian) external view returns (bool);
    function isLocked(address _wallet) external view returns (bool);
    function getLock(address _wallet) external view returns (uint256);
    function getLocker(address _wallet) external view returns (address);
    function setLock(address _wallet, uint256 _releaseAfter) external;
    function getGuardians(address _wallet) external view returns (address[] memory);
    function guardianCount(address _wallet) external view returns (uint256);
}
// File: contracts/modules/common/IModule.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
/**
 * @title IModule
 * @notice Interface for a module.
 * A module MUST implement the addModule() method to ensure that a wallet with at least one module
 * can never end up in a "frozen" state.
 * @author Julien Niset - <julien@argent.xyz>
 */
interface IModule {
    /**
     * @notice Inits a module for a wallet by e.g. setting some wallet specific parameters in storage.
     * @param _wallet The wallet.
     */
    function init(address _wallet) external;
    /**	
     * @notice Adds a module to a wallet. Cannot execute when wallet is locked (or under recovery)	
     * @param _wallet The target wallet.	
     * @param _module The modules to authorise.	
     */	
    function addModule(address _wallet, address _module) external;
}
// File: @openzeppelin/contracts/math/SafeMath.sol
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// File: contracts/wallet/IWallet.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
/**
 * @title IWallet
 * @notice Interface for the BaseWallet
 */
interface IWallet {
    /**
     * @notice Returns the wallet owner.
     * @return The wallet owner address.
     */
    function owner() external view returns (address);
    /**
     * @notice Returns the number of authorised modules.
     * @return The number of authorised modules.
     */
    function modules() external view returns (uint);
    /**
     * @notice Sets a new owner for the wallet.
     * @param _newOwner The new owner.
     */
    function setOwner(address _newOwner) external;
    /**
     * @notice Checks if a module is authorised on the wallet.
     * @param _module The module address to check.
     * @return `true` if the module is authorised, otherwise `false`.
     */
    function authorised(address _module) external view returns (bool);
    /**
     * @notice Returns the module responsible for a static call redirection.
     * @param _sig The signature of the static call.
     * @return the module doing the redirection
     */
    function enabled(bytes4 _sig) external view returns (address);
    /**
     * @notice Enables/Disables a module.
     * @param _module The target module.
     * @param _value Set to `true` to authorise the module.
     */
    function authoriseModule(address _module, bool _value) external;
    /**
    * @notice Enables a static method by specifying the target module to which the call must be delegated.
    * @param _module The target module.
    * @param _method The static method signature.
    */
    function enableStaticCall(address _module, bytes4 _method) external;
}
// File: contracts/infrastructure/IModuleRegistry.sol
// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
/**
 * @title IModuleRegistry
 * @notice Interface for the registry of authorised modules.
 */
interface IModuleRegistry {
    function registerModule(address _module, bytes32 _name) external;
    function deregisterModule(address _module) external;
    function registerUpgrader(address _upgrader, bytes32 _name) external;
    function deregisterUpgrader(address _upgrader) external;
    function recoverToken(address _token) external;
    function moduleInfo(address _module) external view returns (bytes32);
    function upgraderInfo(address _upgrader) external view returns (bytes32);
    function isRegisteredModule(address _module) external view returns (bool);
    function isRegisteredModule(address[] calldata _modules) external view returns (bool);
    function isRegisteredUpgrader(address _upgrader) external view returns (bool);
}
// File: contracts/infrastructure/storage/ILockStorage.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
interface ILockStorage {
    function isLocked(address _wallet) external view returns (bool);
    function getLock(address _wallet) external view returns (uint256);
    function getLocker(address _wallet) external view returns (address);
    function setLock(address _wallet, address _locker, uint256 _releaseAfter) external;
}
// File: contracts/modules/common/IFeature.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
/**
 * @title IFeature
 * @notice Interface for a Feature.
 * @author Julien Niset - <julien@argent.xyz>, Olivier VDB - <olivier@argent.xyz>
 */
interface IFeature {
    enum OwnerSignature {
        Anyone,             // Anyone
        Required,           // Owner required
        Optional,           // Owner and/or guardians
        Disallowed          // guardians only
    }
    /**
    * @notice Utility method to recover any ERC20 token that was sent to the Feature by mistake.
    * @param _token The token to recover.
    */
    function recoverToken(address _token) external;
    /**
     * @notice Inits a Feature for a wallet by e.g. setting some wallet specific parameters in storage.
     * @param _wallet The wallet.
     */
    function init(address _wallet) external;
    /**
     * @notice Helper method to check if an address is an authorised feature of a target wallet.
     * @param _wallet The target wallet.
     * @param _feature The address.
     */
    function isFeatureAuthorisedInVersionManager(address _wallet, address _feature) external view returns (bool);
    /**
    * @notice Gets the number of valid signatures that must be provided to execute a
    * specific relayed transaction.
    * @param _wallet The target wallet.
    * @param _data The data of the relayed transaction.
    * @return The number of required signatures and the wallet owner signature requirement.
    */
    function getRequiredSignatures(address _wallet, bytes calldata _data) external view returns (uint256, OwnerSignature);
    /**
    * @notice Gets the list of static call signatures that this feature responds to on behalf of wallets
    */
    function getStaticCallSignatures() external view returns (bytes4[] memory);
}
// File: lib/other/ERC20.sol
pragma solidity >=0.5.4 <0.7.0;
/**
 * ERC20 contract interface.
 */
interface ERC20 {
    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}
// File: contracts/infrastructure/storage/ILimitStorage.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
/**
 * @title ILimitStorage
 * @notice LimitStorage interface
 */
interface ILimitStorage {
    struct Limit {
        // the current limit
        uint128 current;
        // the pending limit if any
        uint128 pending;
        // when the pending limit becomes the current limit
        uint64 changeAfter;
    }
    struct DailySpent {
        // The amount already spent during the current period
        uint128 alreadySpent;
        // The end of the current period
        uint64 periodEnd;
    }
    function setLimit(address _wallet, Limit memory _limit) external;
    function getLimit(address _wallet) external view returns (Limit memory _limit);
    function setDailySpent(address _wallet, DailySpent memory _dailySpent) external;
    function getDailySpent(address _wallet) external view returns (DailySpent memory _dailySpent);
    function setLimitAndDailySpent(address _wallet, Limit memory _limit, DailySpent memory _dailySpent) external;
    function getLimitAndDailySpent(address _wallet) external view returns (Limit memory _limit, DailySpent memory _dailySpent);
}
// File: contracts/modules/common/IVersionManager.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
pragma solidity >=0.5.4 <0.7.0;
/**
 * @title IVersionManager
 * @notice Interface for the VersionManager module.
 * @author Olivier VDB - <olivier@argent.xyz>
 */
interface IVersionManager {
    /**
     * @notice Returns true if the feature is authorised for the wallet
     * @param _wallet The target wallet.
     * @param _feature The feature.
     */
    function isFeatureAuthorised(address _wallet, address _feature) external view returns (bool);
    /**
     * @notice Lets a feature (caller) invoke a wallet.
     * @param _wallet The target wallet.
     * @param _to The target address for the transaction.
     * @param _value The value of the transaction.
     * @param _data The data of the transaction.
     */
    function checkAuthorisedFeatureAndInvokeWallet(
        address _wallet,
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes memory _res);
    /* ******* Backward Compatibility with old Storages and BaseWallet *************** */
    /**
     * @notice Sets a new owner for the wallet.
     * @param _newOwner The new owner.
     */
    function setOwner(address _wallet, address _newOwner) external;
    /**
     * @notice Lets a feature write data to a storage contract.
     * @param _wallet The target wallet.
     * @param _storage The storage contract.
     * @param _data The data of the call
     */
    function invokeStorage(address _wallet, address _storage, bytes calldata _data) external;
    /**
     * @notice Upgrade a wallet to a new version.
     * @param _wallet the wallet to upgrade
     * @param _toVersion the new version
     */
    function upgradeWallet(address _wallet, uint256 _toVersion) external;
}
// File: contracts/modules/common/BaseFeature.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.s
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
/**
 * @title BaseFeature
 * @notice Base Feature contract that contains methods common to all Feature contracts.
 * @author Julien Niset - <julien@argent.xyz>, Olivier VDB - <olivier@argent.xyz>
 */
contract BaseFeature is IFeature {
    // Empty calldata
    bytes constant internal EMPTY_BYTES = "";
    // Mock token address for ETH
    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    // The address of the Lock storage
    ILockStorage internal lockStorage;
    // The address of the Version Manager
    IVersionManager internal versionManager;
    event FeatureCreated(bytes32 name);
    /**
     * @notice Throws if the wallet is locked.
     */
    modifier onlyWhenUnlocked(address _wallet) {
        require(!lockStorage.isLocked(_wallet), "BF: wallet locked");
        _;
    }
    /**
     * @notice Throws if the sender is not the VersionManager.
     */
    modifier onlyVersionManager() {
        require(msg.sender == address(versionManager), "BF: caller must be VersionManager");
        _;
    }
    /**
     * @notice Throws if the sender is not the owner of the target wallet.
     */
    modifier onlyWalletOwner(address _wallet) {
        require(isOwner(_wallet, msg.sender), "BF: must be wallet owner");
        _;
    }
    /**
     * @notice Throws if the sender is not an authorised feature of the target wallet.
     */
    modifier onlyWalletFeature(address _wallet) {
        require(versionManager.isFeatureAuthorised(_wallet, msg.sender), "BF: must be a wallet feature");
        _;
    }
    /**
     * @notice Throws if the sender is not the owner of the target wallet or the feature itself.
     */
    modifier onlyWalletOwnerOrFeature(address _wallet) {
        // Wrapping in an internal method reduces deployment cost by avoiding duplication of inlined code
        verifyOwnerOrAuthorisedFeature(_wallet, msg.sender);
        _;
    }
    constructor(
        ILockStorage _lockStorage,
        IVersionManager _versionManager,
        bytes32 _name
    ) public {
        lockStorage = _lockStorage;
        versionManager = _versionManager;
        emit FeatureCreated(_name);
    }
    /**
    * @inheritdoc IFeature
    */
    function recoverToken(address _token) external virtual override {
        uint total = ERC20(_token).balanceOf(address(this));
        _token.call(abi.encodeWithSelector(ERC20(_token).transfer.selector, address(versionManager), total));
    }
    /**
     * @notice Inits the feature for a wallet by doing nothing.
     * @dev !! Overriding methods need make sure `init()` can only be called by the VersionManager !!
     * @param _wallet The wallet.
     */
    function init(address _wallet) external virtual override  {}
    /**
     * @inheritdoc IFeature
     */
    function getRequiredSignatures(address, bytes calldata) external virtual view override returns (uint256, OwnerSignature) {
        revert("BF: disabled method");
    }
    /**
     * @inheritdoc IFeature
     */
    function getStaticCallSignatures() external virtual override view returns (bytes4[] memory _sigs) {}
    /**
     * @inheritdoc IFeature
     */
    function isFeatureAuthorisedInVersionManager(address _wallet, address _feature) public override view returns (bool) {
        return versionManager.isFeatureAuthorised(_wallet, _feature);
    }
    /**
    * @notice Checks that the wallet address provided as the first parameter of _data matches _wallet
    * @return false if the addresses are different.
    */
    function verifyData(address _wallet, bytes calldata _data) internal pure returns (bool) {
        require(_data.length >= 36, "RM: Invalid dataWallet");
        address dataWallet = abi.decode(_data[4:], (address));
        return dataWallet == _wallet;
    }
     /**
     * @notice Helper method to check if an address is the owner of a target wallet.
     * @param _wallet The target wallet.
     * @param _addr The address.
     */
    function isOwner(address _wallet, address _addr) internal view returns (bool) {
        return IWallet(_wallet).owner() == _addr;
    }
    /**
     * @notice Verify that the caller is an authorised feature or the wallet owner.
     * @param _wallet The target wallet.
     * @param _sender The caller.
     */
    function verifyOwnerOrAuthorisedFeature(address _wallet, address _sender) internal view {
        require(isFeatureAuthorisedInVersionManager(_wallet, _sender) || isOwner(_wallet, _sender), "BF: must be owner or feature");
    }
    /**
     * @notice Helper method to invoke a wallet.
     * @param _wallet The target wallet.
     * @param _to The target address for the transaction.
     * @param _value The value of the transaction.
     * @param _data The data of the transaction.
     */
    function invokeWallet(address _wallet, address _to, uint256 _value, bytes memory _data)
        internal
        returns (bytes memory _res) 
    {
        _res = versionManager.checkAuthorisedFeatureAndInvokeWallet(_wallet, _to, _value, _data);
    }
}
// File: modules/VersionManager.sol
// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
/**
 * @title VersionManager
 * @notice Intermediate contract between features and wallets. VersionManager checks that a calling feature is
 * authorised for the wallet and if so, forwards the call to it. Note that VersionManager is meant to be the only
 * module authorised on a wallet and because some of its methods need to be called by the RelayerManager feature,
 * the VersionManager is both a module AND a feature.
 * @author Olivier VDB <olivier@argent.xyz>
 */
contract VersionManager is IVersionManager, IModule, BaseFeature, Owned {
    bytes32 constant NAME = "VersionManager";
    bytes4 constant internal ADD_MODULE_PREFIX = bytes4(keccak256("addModule(address,address)"));
    bytes4 constant internal UPGRADE_WALLET_PREFIX = bytes4(keccak256("upgradeWallet(address,uint256)"));
    // Last bundle version
    uint256 public lastVersion;
    // Minimum allowed version
    uint256 public minVersion = 1;
    // Current bundle version for a wallet
    mapping(address => uint256) public walletVersions; // [wallet] => [version]
    // Features per version
    mapping(address => mapping(uint256 => bool)) public isFeatureInVersion; // [feature][version] => bool
    // Features requiring initialization for a wallet
    mapping(uint256 => address[]) public featuresToInit; // [version] => [features]
    // Supported static call signatures
    mapping(uint256 => bytes4[]) public staticCallSignatures; // [version] => [sigs]
    // Features executing static calls
    mapping(uint256 => mapping(bytes4 => address)) public staticCallExecutors; // [version][sig] => [feature]
    // Authorised Storages
    mapping(address => bool) public isStorage; // [storage] => bool
    event VersionAdded(uint256 _version, address[] _features);
    event WalletUpgraded(address indexed _wallet, uint256 _version);
    // The Module Registry
    IModuleRegistry private registry;
    /* ***************** Constructor ************************* */
    constructor(
        IModuleRegistry _registry,
        ILockStorage _lockStorage,
        IGuardianStorage _guardianStorage,
        ITransferStorage _transferStorage,
        ILimitStorage _limitStorage
    )
        BaseFeature(_lockStorage, IVersionManager(address(this)), NAME)
        public
    {
        registry = _registry;
        // Add initial storages
        if(address(_lockStorage) != address(0)) { 
            addStorage(address(_lockStorage));
        }
        if(address(_guardianStorage) != address(0)) { 
            addStorage(address(_guardianStorage));
        }
        if(address(_transferStorage) != address(0)) {
            addStorage(address(_transferStorage));
        }
        if(address(_limitStorage) != address(0)) {
            addStorage(address(_limitStorage));
        }
    }
    /* ***************** onlyOwner ************************* */
    /**
     * @inheritdoc IFeature
     */
    function recoverToken(address _token) external override onlyOwner {
        uint total = ERC20(_token).balanceOf(address(this));
        _token.call(abi.encodeWithSelector(ERC20(_token).transfer.selector, msg.sender, total));
    }
    /**
     * @notice Lets the owner change the minimum allowed version
     * @param _minVersion the minimum allowed version
     */
    function setMinVersion(uint256 _minVersion) external onlyOwner {
        require(_minVersion > 0 && _minVersion <= lastVersion, "VM: invalid _minVersion");
        minVersion = _minVersion;
    }
    /**
     * @notice Lets the owner add a new version, i.e. a new bundle of features.
     * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     * WARNING: if a feature was added to a version and later on removed from a subsequent version,
     * the feature may no longer be used in any future version without first being redeployed.
     * Otherwise, the feature could be initialized more than once.
     * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     * @param _features the list of features included in the new version
     * @param _featuresToInit the subset of features that need to be initialized for a wallet
     */
    function addVersion(address[] calldata _features, address[] calldata _featuresToInit) external onlyOwner {
        uint256 newVersion = ++lastVersion;
        for(uint256 i = 0; i < _features.length; i++) {
            isFeatureInVersion[_features[i]][newVersion] = true;
            // Store static call information to optimise its use by wallets
            bytes4[] memory sigs = IFeature(_features[i]).getStaticCallSignatures();
            for(uint256 j = 0; j < sigs.length; j++) {
                staticCallSignatures[newVersion].push(sigs[j]);
                staticCallExecutors[newVersion][sigs[j]] = _features[i];
            }
        }
        // Sanity check
        for(uint256 i = 0; i < _featuresToInit.length; i++) {
            require(isFeatureInVersion[_featuresToInit[i]][newVersion], "VM: invalid _featuresToInit");
        }
        featuresToInit[newVersion] = _featuresToInit;
        emit VersionAdded(newVersion, _features);
    }
    /**
     * @notice Lets the owner add a storage contract
     * @param _storage the storage contract to add
     */
    function addStorage(address _storage) public onlyOwner {
        require(!isStorage[_storage], "VM: storage already added");
        isStorage[_storage] = true;
    }
    /* ***************** View Methods ************************* */
    /**
     * @inheritdoc IVersionManager
     */
    function isFeatureAuthorised(address _wallet, address _feature) external view override returns (bool) {
        // Note that the VersionManager is the only feature that isn't stored in isFeatureInVersion
        return _isFeatureAuthorisedForWallet(_wallet, _feature) || _feature == address(this);
    }
    /**
     * @inheritdoc IFeature
     */
    function getRequiredSignatures(address /* _wallet */, bytes calldata _data) external view override returns (uint256, OwnerSignature) {
        bytes4 methodId = Utils.functionPrefix(_data);
        // This require ensures that the RelayerManager cannot be used to call a featureOnly VersionManager method
        // that calls a Storage or the BaseWallet for backward-compatibility reason
        require(methodId == UPGRADE_WALLET_PREFIX || methodId == ADD_MODULE_PREFIX, "VM: unknown method");     
        return (1, OwnerSignature.Required);
    }
    /* ***************** Static Call Delegation ************************* */
    /**
     * @notice This method is used by the VersionManager's fallback (via an internal call) to determine whether
     * the current transaction is a staticcall or not. The method succeeds if the current transaction is a static call, 
     * and reverts otherwise. 
     * @dev The use of an if/else allows to encapsulate the whole logic in a single function.
     */
    function verifyStaticCall() public {
        if(msg.sender != address(this)) { // first entry in the method (via an internal call)
            (bool success,) = address(this).call{gas: 3000}(abi.encodeWithSelector(VersionManager(0).verifyStaticCall.selector));
            require(!success, "VM: not in a staticcall");
        } else { // second entry in the method (via an external call)
            // solhint-disable-next-line no-inline-assembly
            assembly { log0(0, 0) }
        }
    }
    /**
     * @notice This method delegates the static call to a target feature
     */
    fallback() external {
        uint256 version = walletVersions[msg.sender];
        address feature = staticCallExecutors[version][msg.sig];
        require(feature != address(0), "VM: static call not supported for wallet version");
        verifyStaticCall();
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), feature, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }
    /* ***************** Wallet Upgrade ************************* */
    /**
     * @inheritdoc IFeature
     */
    function init(address _wallet) public override(IModule, BaseFeature) {}
    /**
     * @inheritdoc IVersionManager
     */
    function upgradeWallet(address _wallet, uint256 _toVersion) external override onlyWhenUnlocked(_wallet) {
        require(
            // Upgrade triggered by the RelayerManager (from version v>=1 to version v'>v)
            _isFeatureAuthorisedForWallet(_wallet, msg.sender) ||
            // Upgrade triggered by WalletFactory or UpgraderToVersionManager (from version v=0 to version v'>0)
            IWallet(_wallet).authorised(msg.sender) ||
            // Upgrade triggered directly by the owner (from version v>=1 to version v'>v)
            isOwner(_wallet, msg.sender), 
            "VM: sender may not upgrade wallet"
        );
        uint256 fromVersion = walletVersions[_wallet];
        uint256 minVersion_ = minVersion;
        uint256 toVersion;
        if(_toVersion < minVersion_ && fromVersion == 0 && IWallet(_wallet).modules() == 2) {
            // When the caller is the WalletFactory, we automatically change toVersion to minVersion if needed.
            // Note that when fromVersion == 0, the caller could be the WalletFactory or the UpgraderToVersionManager. 
            // The WalletFactory will be the only possible caller when the wallet has only 2 authorised modules 
            // (that number would be >= 3 for a call from the UpgraderToVersionManager)
            toVersion = minVersion_;
        } else {
            toVersion = _toVersion;
        }
        require(toVersion >= minVersion_ && toVersion <= lastVersion, "VM: invalid _toVersion");
        require(fromVersion < toVersion, "VM: already on new version");
        walletVersions[_wallet] = toVersion;
        // Setup static call redirection
        bytes4[] storage sigs = staticCallSignatures[toVersion];
        for(uint256 i = 0; i < sigs.length; i++) {
            bytes4 sig = sigs[i];
            if(IWallet(_wallet).enabled(sig) != address(this)) {
                IWallet(_wallet).enableStaticCall(address(this), sig);
            }
        }
        // Init features
        address[] storage featuresToInitInToVersion = featuresToInit[toVersion];
        for(uint256 i = 0; i < featuresToInitInToVersion.length; i++) {
            address feature = featuresToInitInToVersion[i];
            // We only initialize a feature that was not already initialized in the previous version
            if(fromVersion == 0 || !isFeatureInVersion[feature][fromVersion]) {
                IFeature(feature).init(_wallet);
            }
        }
        emit WalletUpgraded(_wallet, toVersion);
    }
    /**
     * @inheritdoc IModule
     */
    function addModule(address _wallet, address _module) external override onlyWalletOwnerOrFeature(_wallet) onlyWhenUnlocked(_wallet) {
        require(registry.isRegisteredModule(_module), "VM: module is not registered");
        IWallet(_wallet).authoriseModule(_module, true);
    }
    /* ******* Backward Compatibility with old Storages and BaseWallet *************** */
    /**
     * @inheritdoc IVersionManager
     */
    function checkAuthorisedFeatureAndInvokeWallet(
        address _wallet, 
        address _to, 
        uint256 _value, 
        bytes memory _data
    ) 
        external 
        override
        returns (bytes memory _res) 
    {
        require(_isFeatureAuthorisedForWallet(_wallet, msg.sender), "VM: sender may not invoke wallet");
        bool success;
        (success, _res) = _wallet.call(abi.encodeWithSignature("invoke(address,uint256,bytes)", _to, _value, _data));
        if (success && _res.length > 0) { //_res is empty if _wallet is an "old" BaseWallet that can't return output values
            (_res) = abi.decode(_res, (bytes));
        } else if (_res.length > 0) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        } else if (!success) {
            revert("VM: wallet invoke reverted");
        }
    }
    /**
     * @inheritdoc IVersionManager
     */
    function invokeStorage(address _wallet, address _storage, bytes calldata _data) external override {
        require(_isFeatureAuthorisedForWallet(_wallet, msg.sender), "VM: sender may not invoke storage");
        require(verifyData(_wallet, _data), "VM: target of _data != _wallet");
        require(isStorage[_storage], "VM: invalid storage invoked");
        (bool success,) = _storage.call(_data);
        require(success, "VM: _storage failed");
    }
    /**
     * @inheritdoc IVersionManager
     */
    function setOwner(address _wallet, address _newOwner) external override {
        require(_isFeatureAuthorisedForWallet(_wallet, msg.sender), "VM: sender should be authorized feature");
        IWallet(_wallet).setOwner(_newOwner);
    }
    /* ***************** Internal Methods ************************* */
    function _isFeatureAuthorisedForWallet(address _wallet, address _feature) private view returns (bool) {
        return isFeatureInVersion[_feature][walletVersions[_wallet]];
    }
}