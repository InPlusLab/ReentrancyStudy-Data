/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity 0.4.24;

// File: @aragon/os/contracts/common/UnstructuredStorage.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





library UnstructuredStorage {

    function getStorageBool(bytes32 position) internal view returns (bool data) {

        assembly { data := sload(position) }

    }



    function getStorageAddress(bytes32 position) internal view returns (address data) {

        assembly { data := sload(position) }

    }



    function getStorageBytes32(bytes32 position) internal view returns (bytes32 data) {

        assembly { data := sload(position) }

    }



    function getStorageUint256(bytes32 position) internal view returns (uint256 data) {

        assembly { data := sload(position) }

    }



    function setStorageBool(bytes32 position, bool data) internal {

        assembly { sstore(position, data) }

    }



    function setStorageAddress(bytes32 position, address data) internal {

        assembly { sstore(position, data) }

    }



    function setStorageBytes32(bytes32 position, bytes32 data) internal {

        assembly { sstore(position, data) }

    }



    function setStorageUint256(bytes32 position, uint256 data) internal {

        assembly { sstore(position, data) }

    }

}

// File: @aragon/os/contracts/acl/IACL.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





interface IACL {

    function initialize(address permissionsCreator) external;



    // TODO: this should be external

    // See https://github.com/ethereum/solidity/issues/4832

    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);

}

// File: @aragon/os/contracts/common/IVaultRecoverable.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





interface IVaultRecoverable {

    function transferToVault(address token) external;



    function allowRecoverability(address token) external view returns (bool);

    function getRecoveryVault() external view returns (address);

}

// File: @aragon/os/contracts/kernel/IKernel.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;









// This should be an interface, but interfaces can't inherit yet :(

contract IKernel is IVaultRecoverable {

    event SetApp(bytes32 indexed namespace, bytes32 indexed appId, address app);



    function acl() public view returns (IACL);

    function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);



    function setApp(bytes32 namespace, bytes32 appId, address app) public;

    function getApp(bytes32 namespace, bytes32 appId) public view returns (address);

}

// File: @aragon/os/contracts/apps/AppStorage.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;









contract AppStorage {

    using UnstructuredStorage for bytes32;



    /* Hardcoded constants to save gas

    bytes32 internal constant KERNEL_POSITION = keccak256("aragonOS.appStorage.kernel");

    bytes32 internal constant APP_ID_POSITION = keccak256("aragonOS.appStorage.appId");

    */

    bytes32 internal constant KERNEL_POSITION = 0x4172f0f7d2289153072b0a6ca36959e0cbe2efc3afe50fc81636caa96338137b;

    bytes32 internal constant APP_ID_POSITION = 0xd625496217aa6a3453eecb9c3489dc5a53e6c67b444329ea2b2cbc9ff547639b;



    function kernel() public view returns (IKernel) {

        return IKernel(KERNEL_POSITION.getStorageAddress());

    }



    function appId() public view returns (bytes32) {

        return APP_ID_POSITION.getStorageBytes32();

    }



    function setKernel(IKernel _kernel) internal {

        KERNEL_POSITION.setStorageAddress(address(_kernel));

    }



    function setAppId(bytes32 _appId) internal {

        APP_ID_POSITION.setStorageBytes32(_appId);

    }

}

// File: @aragon/os/contracts/common/Uint256Helpers.sol

library Uint256Helpers {

    uint256 private constant MAX_UINT64 = uint64(-1);



    string private constant ERROR_NUMBER_TOO_BIG = "UINT64_NUMBER_TOO_BIG";



    function toUint64(uint256 a) internal pure returns (uint64) {

        require(a <= MAX_UINT64, ERROR_NUMBER_TOO_BIG);

        return uint64(a);

    }

}

// File: @aragon/os/contracts/common/TimeHelpers.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;







contract TimeHelpers {

    using Uint256Helpers for uint256;



    /**

    * @dev Returns the current block number.

    *      Using a function rather than `block.number` allows us to easily mock the block number in

    *      tests.

    */

    function getBlockNumber() internal view returns (uint256) {

        return block.number;

    }



    /**

    * @dev Returns the current block number, converted to uint64.

    *      Using a function rather than `block.number` allows us to easily mock the block number in

    *      tests.

    */

    function getBlockNumber64() internal view returns (uint64) {

        return getBlockNumber().toUint64();

    }



    /**

    * @dev Returns the current timestamp.

    *      Using a function rather than `block.timestamp` allows us to easily mock it in

    *      tests.

    */

    function getTimestamp() internal view returns (uint256) {

        return block.timestamp; // solium-disable-line security/no-block-members

    }



    /**

    * @dev Returns the current timestamp, converted to uint64.

    *      Using a function rather than `block.timestamp` allows us to easily mock it in

    *      tests.

    */

    function getTimestamp64() internal view returns (uint64) {

        return getTimestamp().toUint64();

    }

}

// File: @aragon/os/contracts/common/Initializable.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;









contract Initializable is TimeHelpers {

    using UnstructuredStorage for bytes32;



    // keccak256("aragonOS.initializable.initializationBlock")

    bytes32 internal constant INITIALIZATION_BLOCK_POSITION = 0xebb05b386a8d34882b8711d156f463690983dc47815980fb82aeeff1aa43579e;



    string private constant ERROR_ALREADY_INITIALIZED = "INIT_ALREADY_INITIALIZED";

    string private constant ERROR_NOT_INITIALIZED = "INIT_NOT_INITIALIZED";



    modifier onlyInit {

        require(getInitializationBlock() == 0, ERROR_ALREADY_INITIALIZED);

        _;

    }



    modifier isInitialized {

        require(hasInitialized(), ERROR_NOT_INITIALIZED);

        _;

    }



    /**

    * @return Block number in which the contract was initialized

    */

    function getInitializationBlock() public view returns (uint256) {

        return INITIALIZATION_BLOCK_POSITION.getStorageUint256();

    }



    /**

    * @return Whether the contract has been initialized by the time of the current block

    */

    function hasInitialized() public view returns (bool) {

        uint256 initializationBlock = getInitializationBlock();

        return initializationBlock != 0 && getBlockNumber() >= initializationBlock;

    }



    /**

    * @dev Function to be called by top level contract after initialization has finished.

    */

    function initialized() internal onlyInit {

        INITIALIZATION_BLOCK_POSITION.setStorageUint256(getBlockNumber());

    }



    /**

    * @dev Function to be called by top level contract after initialization to enable the contract

    *      at a future block number rather than immediately.

    */

    function initializedAt(uint256 _blockNumber) internal onlyInit {

        INITIALIZATION_BLOCK_POSITION.setStorageUint256(_blockNumber);

    }

}

// File: @aragon/os/contracts/common/Petrifiable.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;







contract Petrifiable is Initializable {

    // Use block UINT256_MAX (which should be never) as the initializable date

    uint256 internal constant PETRIFIED_BLOCK = uint256(-1);



    function isPetrified() public view returns (bool) {

        return getInitializationBlock() == PETRIFIED_BLOCK;

    }



    /**

    * @dev Function to be called by top level contract to prevent being initialized.

    *      Useful for freezing base contracts when they're used behind proxies.

    */

    function petrify() internal onlyInit {

        initializedAt(PETRIFIED_BLOCK);

    }

}

// File: @aragon/os/contracts/common/Autopetrified.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;







contract Autopetrified is Petrifiable {

    constructor() public {

        // Immediately petrify base (non-proxy) instances of inherited contracts on deploy.

        // This renders them uninitializable (and unusable without a proxy).

        petrify();

    }

}

// File: @aragon/os/contracts/lib/token/ERC20.sol

// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/a9f910d34f0ab33a1ae5e714f69f9596a02b4d91/contracts/token/ERC20/ERC20.sol



pragma solidity ^0.4.24;





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 {

    function totalSupply() public view returns (uint256);



    function balanceOf(address _who) public view returns (uint256);



    function allowance(address _owner, address _spender)

        public view returns (uint256);



    function transfer(address _to, uint256 _value) public returns (bool);



    function approve(address _spender, uint256 _value)

        public returns (bool);



    function transferFrom(address _from, address _to, uint256 _value)

        public returns (bool);



    event Transfer(

        address indexed from,

        address indexed to,

        uint256 value

    );



    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

}

// File: @aragon/os/contracts/common/EtherTokenConstant.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





// aragonOS and aragon-apps rely on address(0) to denote native ETH, in

// contracts where both tokens and ETH are accepted

contract EtherTokenConstant {

    address internal constant ETH = address(0);

}

// File: @aragon/os/contracts/common/IsContract.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





contract IsContract {

    /*

    * NOTE: this should NEVER be used for authentication

    * (see pitfalls: https://github.com/fergarrui/ethereum-security/tree/master/contracts/extcodesize).

    *

    * This is only intended to be used as a sanity check that an address is actually a contract,

    * RATHER THAN an address not being a contract.

    */

    function isContract(address _target) internal view returns (bool) {

        if (_target == address(0)) {

            return false;

        }



        uint256 size;

        assembly { size := extcodesize(_target) }

        return size > 0;

    }

}

// File: @aragon/os/contracts/common/VaultRecoverable.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;













contract VaultRecoverable is IVaultRecoverable, EtherTokenConstant, IsContract {

    string private constant ERROR_DISALLOWED = "RECOVER_DISALLOWED";

    string private constant ERROR_VAULT_NOT_CONTRACT = "RECOVER_VAULT_NOT_CONTRACT";



    /**

     * @notice Send funds to recovery Vault. This contract should never receive funds,

     *         but in case it does, this function allows one to recover them.

     * @param _token Token balance to be sent to recovery vault.

     */

    function transferToVault(address _token) external {

        require(allowRecoverability(_token), ERROR_DISALLOWED);

        address vault = getRecoveryVault();

        require(isContract(vault), ERROR_VAULT_NOT_CONTRACT);



        if (_token == ETH) {

            vault.transfer(address(this).balance);

        } else {

            uint256 amount = ERC20(_token).balanceOf(this);

            ERC20(_token).transfer(vault, amount);

        }

    }



    /**

    * @dev By default deriving from AragonApp makes it recoverable

    * @param token Token address that would be recovered

    * @return bool whether the app allows the recovery

    */

    function allowRecoverability(address token) public view returns (bool) {

        return true;

    }



    // Cast non-implemented interface to be public so we can use it internally

    function getRecoveryVault() public view returns (address);

}

// File: @aragon/os/contracts/evmscript/IEVMScriptExecutor.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





interface IEVMScriptExecutor {

    function execScript(bytes script, bytes input, address[] blacklist) external returns (bytes);

    function executorType() external pure returns (bytes32);

}

// File: @aragon/os/contracts/evmscript/IEVMScriptRegistry.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;







contract EVMScriptRegistryConstants {

    /* Hardcoded constants to save gas

    bytes32 internal constant EVMSCRIPT_REGISTRY_APP_ID = apmNamehash("evmreg");

    */

    bytes32 internal constant EVMSCRIPT_REGISTRY_APP_ID = 0xddbcfd564f642ab5627cf68b9b7d374fb4f8a36e941a75d89c87998cef03bd61;

}





interface IEVMScriptRegistry {

    function addScriptExecutor(IEVMScriptExecutor executor) external returns (uint id);

    function disableScriptExecutor(uint256 executorId) external;



    // TODO: this should be external

    // See https://github.com/ethereum/solidity/issues/4832

    function getScriptExecutor(bytes script) public view returns (IEVMScriptExecutor);

}

// File: @aragon/os/contracts/kernel/KernelConstants.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





contract KernelAppIds {

    /* Hardcoded constants to save gas

    bytes32 internal constant KERNEL_CORE_APP_ID = apmNamehash("kernel");

    bytes32 internal constant KERNEL_DEFAULT_ACL_APP_ID = apmNamehash("acl");

    bytes32 internal constant KERNEL_DEFAULT_VAULT_APP_ID = apmNamehash("vault");

    */

    bytes32 internal constant KERNEL_CORE_APP_ID = 0x3b4bf6bf3ad5000ecf0f989d5befde585c6860fea3e574a4fab4c49d1c177d9c;

    bytes32 internal constant KERNEL_DEFAULT_ACL_APP_ID = 0xe3262375f45a6e2026b7e7b18c2b807434f2508fe1a2a3dfb493c7df8f4aad6a;

    bytes32 internal constant KERNEL_DEFAULT_VAULT_APP_ID = 0x7e852e0fcfce6551c13800f1e7476f982525c2b5277ba14b24339c68416336d1;

}





contract KernelNamespaceConstants {

    /* Hardcoded constants to save gas

    bytes32 internal constant KERNEL_CORE_NAMESPACE = keccak256("core");

    bytes32 internal constant KERNEL_APP_BASES_NAMESPACE = keccak256("base");

    bytes32 internal constant KERNEL_APP_ADDR_NAMESPACE = keccak256("app");

    */

    bytes32 internal constant KERNEL_CORE_NAMESPACE = 0xc681a85306374a5ab27f0bbc385296a54bcd314a1948b6cf61c4ea1bc44bb9f8;

    bytes32 internal constant KERNEL_APP_BASES_NAMESPACE = 0xf1f3eb40f5bc1ad1344716ced8b8a0431d840b5783aea1fd01786bc26f35ac0f;

    bytes32 internal constant KERNEL_APP_ADDR_NAMESPACE = 0xd6f028ca0e8edb4a8c9757ca4fdccab25fa1e0317da1188108f7d2dee14902fb;

}

// File: @aragon/os/contracts/evmscript/EVMScriptRunner.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;















contract EVMScriptRunner is AppStorage, Initializable, EVMScriptRegistryConstants, KernelNamespaceConstants {

    string private constant ERROR_EXECUTOR_UNAVAILABLE = "EVMRUN_EXECUTOR_UNAVAILABLE";

    string private constant ERROR_EXECUTION_REVERTED = "EVMRUN_EXECUTION_REVERTED";

    string private constant ERROR_PROTECTED_STATE_MODIFIED = "EVMRUN_PROTECTED_STATE_MODIFIED";



    event ScriptResult(address indexed executor, bytes script, bytes input, bytes returnData);



    function getEVMScriptExecutor(bytes _script) public view returns (IEVMScriptExecutor) {

        return IEVMScriptExecutor(getEVMScriptRegistry().getScriptExecutor(_script));

    }



    function getEVMScriptRegistry() public view returns (IEVMScriptRegistry) {

        address registryAddr = kernel().getApp(KERNEL_APP_ADDR_NAMESPACE, EVMSCRIPT_REGISTRY_APP_ID);

        return IEVMScriptRegistry(registryAddr);

    }



    function runScript(bytes _script, bytes _input, address[] _blacklist)

        internal

        isInitialized

        protectState

        returns (bytes)

    {

        // TODO: Too much data flying around, maybe extracting spec id here is cheaper

        IEVMScriptExecutor executor = getEVMScriptExecutor(_script);

        require(address(executor) != address(0), ERROR_EXECUTOR_UNAVAILABLE);



        bytes4 sig = executor.execScript.selector;

        bytes memory data = abi.encodeWithSelector(sig, _script, _input, _blacklist);

        require(address(executor).delegatecall(data), ERROR_EXECUTION_REVERTED);



        bytes memory output = returnedDataDecoded();



        emit ScriptResult(address(executor), _script, _input, output);



        return output;

    }



    /**

    * @dev copies and returns last's call data. Needs to ABI decode first

    */

    function returnedDataDecoded() internal pure returns (bytes ret) {

        assembly {

            let size := returndatasize

            switch size

            case 0 {}

            default {

                ret := mload(0x40) // free mem ptr get

                mstore(0x40, add(ret, add(size, 0x20))) // free mem ptr set

                returndatacopy(ret, 0x20, sub(size, 0x20)) // copy return data

            }

        }

        return ret;

    }



    modifier protectState {

        address preKernel = address(kernel());

        bytes32 preAppId = appId();

        _; // exec

        require(address(kernel()) == preKernel, ERROR_PROTECTED_STATE_MODIFIED);

        require(appId() == preAppId, ERROR_PROTECTED_STATE_MODIFIED);

    }

}

// File: @aragon/os/contracts/acl/ACLSyntaxSugar.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





contract ACLSyntaxSugar {

    function arr() internal pure returns (uint256[]) {}



    function arr(bytes32 _a) internal pure returns (uint256[] r) {

        return arr(uint256(_a));

    }



    function arr(bytes32 _a, bytes32 _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));

    }



    function arr(address _a) internal pure returns (uint256[] r) {

        return arr(uint256(_a));

    }



    function arr(address _a, address _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));

    }



    function arr(address _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), _b, _c);

    }



    function arr(address _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {

        return arr(uint256(_a), _b, _c, _d);

    }



    function arr(address _a, uint256 _b) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b));

    }



    function arr(address _a, address _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), _c, _d, _e);

    }



    function arr(address _a, address _b, address _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), uint256(_c));

    }



    function arr(address _a, address _b, uint256 _c) internal pure returns (uint256[] r) {

        return arr(uint256(_a), uint256(_b), uint256(_c));

    }



    function arr(uint256 _a) internal pure returns (uint256[] r) {

        r = new uint256[](1);

        r[0] = _a;

    }



    function arr(uint256 _a, uint256 _b) internal pure returns (uint256[] r) {

        r = new uint256[](2);

        r[0] = _a;

        r[1] = _b;

    }



    function arr(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {

        r = new uint256[](3);

        r[0] = _a;

        r[1] = _b;

        r[2] = _c;

    }



    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {

        r = new uint256[](4);

        r[0] = _a;

        r[1] = _b;

        r[2] = _c;

        r[3] = _d;

    }



    function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {

        r = new uint256[](5);

        r[0] = _a;

        r[1] = _b;

        r[2] = _c;

        r[3] = _d;

        r[4] = _e;

    }

}





contract ACLHelpers {

    function decodeParamOp(uint256 _x) internal pure returns (uint8 b) {

        return uint8(_x >> (8 * 30));

    }



    function decodeParamId(uint256 _x) internal pure returns (uint8 b) {

        return uint8(_x >> (8 * 31));

    }



    function decodeParamsList(uint256 _x) internal pure returns (uint32 a, uint32 b, uint32 c) {

        a = uint32(_x);

        b = uint32(_x >> (8 * 4));

        c = uint32(_x >> (8 * 8));

    }

}

// File: @aragon/os/contracts/apps/AragonApp.sol

/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;















// Contracts inheriting from AragonApp are, by default, immediately petrified upon deployment so

// that they can never be initialized.

// Unless overriden, this behaviour enforces those contracts to be usable only behind an AppProxy.

// ACLSyntaxSugar and EVMScriptRunner are not directly used by this contract, but are included so

// that they are automatically usable by subclassing contracts

contract AragonApp is AppStorage, Autopetrified, VaultRecoverable, EVMScriptRunner, ACLSyntaxSugar {

    string private constant ERROR_AUTH_FAILED = "APP_AUTH_FAILED";



    modifier auth(bytes32 _role) {

        require(canPerform(msg.sender, _role, new uint256[](0)), ERROR_AUTH_FAILED);

        _;

    }



    modifier authP(bytes32 _role, uint256[] _params) {

        require(canPerform(msg.sender, _role, _params), ERROR_AUTH_FAILED);

        _;

    }



    /**

    * @dev Check whether an action can be performed by a sender for a particular role on this app

    * @param _sender Sender of the call

    * @param _role Role on this app

    * @param _params Permission params for the role

    * @return Boolean indicating whether the sender has the permissions to perform the action.

    *         Always returns false if the app hasn't been initialized yet.

    */

    function canPerform(address _sender, bytes32 _role, uint256[] _params) public view returns (bool) {

        if (!hasInitialized()) {

            return false;

        }



        IKernel linkedKernel = kernel();

        if (address(linkedKernel) == address(0)) {

            return false;

        }



        // Force cast the uint256[] into a bytes array, by overwriting its length

        // Note that the bytes array doesn't need to be initialized as we immediately overwrite it

        // with _params and a new length, and _params becomes invalid from this point forward

        bytes memory how;

        uint256 byteLength = _params.length * 32;

        assembly {

            how := _params

            mstore(how, byteLength)

        }

        return linkedKernel.hasPermission(_sender, address(this), _role, how);

    }



    /**

    * @dev Get the recovery vault for the app

    * @return Recovery vault address for the app

    */

    function getRecoveryVault() public view returns (address) {

        // Funds recovery via a vault is only available when used with a kernel

        return kernel().getRecoveryVault(); // if kernel is not set, it will revert

    }

}

// File: @aragon/os/contracts/lib/math/SafeMath.sol

// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/d51e38758e1d985661534534d5c61e27bece5042/contracts/math/SafeMath.sol

// Adapted to use pragma ^0.4.24 and satisfy our linter rules



pragma solidity ^0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";

    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";

    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";

    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";



    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (_a == 0) {

            return 0;

        }



        uint256 c = _a * _b;

        require(c / _a == _b, ERROR_MUL_OVERFLOW);



        return c;

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0

        uint256 c = _a / _b;

        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);

        uint256 c = _a - _b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;

        require(c >= _a, ERROR_ADD_OVERFLOW);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, ERROR_DIV_ZERO);

        return a % b;

    }

}

// File: @aragon/os/contracts/lib/math/SafeMath64.sol

// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/d51e38758e1d985661534534d5c61e27bece5042/contracts/math/SafeMath.sol

// Adapted for uint64, pragma ^0.4.24, and satisfying our linter rules

// Also optimized the mul() implementation, see https://github.com/aragon/aragonOS/pull/417



pragma solidity ^0.4.24;





/**

 * @title SafeMath64

 * @dev Math operations for uint64 with safety checks that revert on error

 */

library SafeMath64 {

    string private constant ERROR_ADD_OVERFLOW = "MATH64_ADD_OVERFLOW";

    string private constant ERROR_SUB_UNDERFLOW = "MATH64_SUB_UNDERFLOW";

    string private constant ERROR_MUL_OVERFLOW = "MATH64_MUL_OVERFLOW";

    string private constant ERROR_DIV_ZERO = "MATH64_DIV_ZERO";



    /**

    * @dev Multiplies two numbers, reverts on overflow.

    */

    function mul(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint256 c = uint256(_a) * uint256(_b);

        require(c < 0x010000000000000000, ERROR_MUL_OVERFLOW); // 2**64 (less gas this way)



        return uint64(c);

    }



    /**

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0

        uint64 c = _a / _b;

        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint64 _a, uint64 _b) internal pure returns (uint64) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);

        uint64 c = _a - _b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint64 _a, uint64 _b) internal pure returns (uint64) {

        uint64 c = _a + _b;

        require(c >= _a, ERROR_ADD_OVERFLOW);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, ERROR_DIV_ZERO);

        return a % b;

    }

}

// File: @aragon/os/contracts/common/DepositableStorage.sol

contract DepositableStorage {

    using UnstructuredStorage for bytes32;



    // keccak256("aragonOS.depositableStorage.depositable")

    bytes32 internal constant DEPOSITABLE_POSITION = 0x665fd576fbbe6f247aff98f5c94a561e3f71ec2d3c988d56f12d342396c50cea;



    function isDepositable() public view returns (bool) {

        return DEPOSITABLE_POSITION.getStorageBool();

    }



    function setDepositable(bool _depositable) internal {

        DEPOSITABLE_POSITION.setStorageBool(_depositable);

    }

}

// File: @aragon/apps-vault/contracts/Vault.sol

contract Vault is EtherTokenConstant, AragonApp, DepositableStorage {

    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");



    string private constant ERROR_DATA_NON_ZERO = "VAULT_DATA_NON_ZERO";

    string private constant ERROR_NOT_DEPOSITABLE = "VAULT_NOT_DEPOSITABLE";

    string private constant ERROR_DEPOSIT_VALUE_ZERO = "VAULT_DEPOSIT_VALUE_ZERO";

    string private constant ERROR_TRANSFER_VALUE_ZERO = "VAULT_TRANSFER_VALUE_ZERO";

    string private constant ERROR_SEND_REVERTED = "VAULT_SEND_REVERTED";

    string private constant ERROR_VALUE_MISMATCH = "VAULT_VALUE_MISMATCH";

    string private constant ERROR_TOKEN_TRANSFER_FROM_REVERTED = "VAULT_TOKEN_TRANSFER_FROM_REVERT";

    string private constant ERROR_TOKEN_TRANSFER_REVERTED = "VAULT_TOKEN_TRANSFER_REVERTED";



    event Transfer(address indexed token, address indexed to, uint256 amount);

    event Deposit(address indexed token, address indexed sender, uint256 amount);



    /**

    * @dev On a normal send() or transfer() this fallback is never executed as it will be

    *      intercepted by the Proxy (see aragonOS#281)

    */

    function () external payable isInitialized {

        require(msg.data.length == 0, ERROR_DATA_NON_ZERO);

        _deposit(ETH, msg.value);

    }



    /**

    * @notice Initialize Vault app

    * @dev As an AragonApp it needs to be initialized in order for roles (`auth` and `authP`) to work

    */

    function initialize() external onlyInit {

        initialized();

        setDepositable(true);

    }



    /**

    * @notice Deposit `_value` `_token` to the vault

    * @param _token Address of the token being transferred

    * @param _value Amount of tokens being transferred

    */

    function deposit(address _token, uint256 _value) external payable isInitialized {

        _deposit(_token, _value);

    }



    /**

    * @notice Transfer `_value` `_token` from the Vault to `_to`

    * @param _token Address of the token being transferred

    * @param _to Address of the recipient of tokens

    * @param _value Amount of tokens being transferred

    */

    /* solium-disable-next-line function-order */

    function transfer(address _token, address _to, uint256 _value)

        external

        authP(TRANSFER_ROLE, arr(_token, _to, _value))

    {

        require(_value > 0, ERROR_TRANSFER_VALUE_ZERO);



        if (_token == ETH) {

            require(_to.send(_value), ERROR_SEND_REVERTED);

        } else {

            require(ERC20(_token).transfer(_to, _value), ERROR_TOKEN_TRANSFER_REVERTED);

        }



        emit Transfer(_token, _to, _value);

    }



    function balance(address _token) public view returns (uint256) {

        if (_token == ETH) {

            return address(this).balance;

        } else {

            return ERC20(_token).balanceOf(this);

        }

    }



    /**

    * @dev Disable recovery escape hatch, as it could be used

    *      maliciously to transfer funds away from the vault

    */

    function allowRecoverability(address) public view returns (bool) {

        return false;

    }



    function _deposit(address _token, uint256 _value) internal {

        require(isDepositable(), ERROR_NOT_DEPOSITABLE);

        require(_value > 0, ERROR_DEPOSIT_VALUE_ZERO);



        if (_token == ETH) {

            // Deposit is implicit in this case

            require(msg.value == _value, ERROR_VALUE_MISMATCH);

        } else {

            require(ERC20(_token).transferFrom(msg.sender, this, _value), ERROR_TOKEN_TRANSFER_FROM_REVERTED);

        }



        emit Deposit(_token, msg.sender, _value);

    }

}

// File: contracts/Finance.sol

/*

 * SPDX-License-Identitifer:    GPL-3.0-or-later

 */



pragma solidity 0.4.24;



















contract Finance is EtherTokenConstant, IsContract, AragonApp {

    using SafeMath for uint256;

    using SafeMath64 for uint64;



    bytes32 public constant CREATE_PAYMENTS_ROLE = keccak256("CREATE_PAYMENTS_ROLE");

    bytes32 public constant CHANGE_PERIOD_ROLE = keccak256("CHANGE_PERIOD_ROLE");

    bytes32 public constant CHANGE_BUDGETS_ROLE = keccak256("CHANGE_BUDGETS_ROLE");

    bytes32 public constant EXECUTE_PAYMENTS_ROLE = keccak256("EXECUTE_PAYMENTS_ROLE");

    bytes32 public constant MANAGE_PAYMENTS_ROLE = keccak256("MANAGE_PAYMENTS_ROLE");



    uint256 internal constant NO_PAYMENT = 0;

    uint256 internal constant NO_TRANSACTION = 0;

    uint256 internal constant MAX_PAYMENTS_PER_TX = 20;

    uint256 internal constant MAX_UINT = uint256(-1);

    uint64 internal constant MAX_UINT64 = uint64(-1);



    string private constant ERROR_COMPLETE_TRANSITION = "FINANCE_COMPLETE_TRANSITION";

    string private constant ERROR_NO_PAYMENT = "FINANCE_NO_PAYMENT";

    string private constant ERROR_NO_TRANSACTION = "FINANCE_NO_TRANSACTION";

    string private constant ERROR_NO_PERIOD = "FINANCE_NO_PERIOD";

    string private constant ERROR_VAULT_NOT_CONTRACT = "FINANCE_VAULT_NOT_CONTRACT";

    string private constant ERROR_INIT_PERIOD_TOO_SHORT = "FINANCE_INIT_PERIOD_TOO_SHORT";

    string private constant ERROR_SET_PERIOD_TOO_SHORT = "FINANCE_SET_PERIOD_TOO_SHORT";

    string private constant ERROR_NEW_PAYMENT_AMOUNT_ZERO = "FINANCE_NEW_PAYMENT_AMOUNT_ZERO";

    string private constant ERROR_RECOVER_AMOUNT_ZERO = "FINANCE_RECOVER_AMOUNT_ZERO";

    string private constant ERROR_DEPOSIT_AMOUNT_ZERO = "FINANCE_DEPOSIT_AMOUNT_ZERO";

    string private constant ERROR_BUDGET = "FINANCE_BUDGET";

    string private constant ERROR_EXECUTE_PAYMENT_TIME = "FINANCE_EXECUTE_PAYMENT_TIME";

    string private constant ERROR_RECEIVER_EXECUTE_PAYMENT_TIME = "FINANCE_RCVR_EXEC_PAYMENT_TIME";

    string private constant ERROR_PAYMENT_RECEIVER = "FINANCE_PAYMENT_RECEIVER";

    string private constant ERROR_TOKEN_TRANSFER_FROM_REVERTED = "FINANCE_TKN_TRANSFER_FROM_REVERT";

    string private constant ERROR_VALUE_MISMATCH = "FINANCE_VALUE_MISMATCH";

    string private constant ERROR_PAYMENT_INACTIVE = "FINANCE_PAYMENT_INACTIVE";

    string private constant ERROR_REMAINING_BUDGET = "FINANCE_REMAINING_BUDGET";



    // Order optimized for storage

    struct Payment {

        address token;

        address receiver;

        address createdBy;

        bool inactive;

        uint256 amount;

        uint64 initialPaymentTime;

        uint64 interval;

        uint64 maxRepeats;

        uint64 repeats;

    }



    // Order optimized for storage

    struct Transaction {

        address token;

        address entity;

        bool isIncoming;

        uint256 amount;

        uint256 paymentId;

        uint64 paymentRepeatNumber;

        uint64 date;

        uint64 periodId;

    }



    struct TokenStatement {

        uint256 expenses;

        uint256 income;

    }



    struct Period {

        uint64 startTime;

        uint64 endTime;

        uint256 firstTransactionId;

        uint256 lastTransactionId;



        mapping (address => TokenStatement) tokenStatement;

    }



    struct Settings {

        uint64 periodDuration;

        mapping (address => uint256) budgets;

        mapping (address => bool) hasBudget;

    }



    Vault public vault;

    Settings internal settings;



    // We are mimicing arrays, we use mappings instead to make app upgrade more graceful

    mapping (uint256 => Payment) internal payments;

    // Payments start at index 1, to allow us to use payments[0] for transactions that are not

    // linked to a recurring payment

    uint256 public paymentsNextIndex;



    mapping (uint256 => Transaction) internal transactions;

    uint256 public transactionsNextIndex;



    mapping (uint64 => Period) internal periods;

    uint64 public periodsLength;



    event NewPeriod(uint64 indexed periodId, uint64 periodStarts, uint64 periodEnds);

    event SetBudget(address indexed token, uint256 amount, bool hasBudget);

    event NewPayment(uint256 indexed paymentId, address indexed recipient, uint64 maxRepeats, string reference);

    event NewTransaction(uint256 indexed transactionId, bool incoming, address indexed entity, uint256 amount, string reference);

    event ChangePaymentState(uint256 indexed paymentId, bool inactive);

    event ChangePeriodDuration(uint64 newDuration);

    event PaymentFailure(uint256 paymentId);



    // Modifier used by all methods that impact accounting to make sure accounting period

    // is changed before the operation if needed

    // NOTE: its use **MUST** be accompanied by an initialization check

    modifier transitionsPeriod {

        bool completeTransition = _tryTransitionAccountingPeriod(getMaxPeriodTransitions());

        require(completeTransition, ERROR_COMPLETE_TRANSITION);

        _;

    }



    modifier paymentExists(uint256 _paymentId) {

        require(_paymentId > 0 && _paymentId < paymentsNextIndex, ERROR_NO_PAYMENT);

        _;

    }



    modifier transactionExists(uint256 _transactionId) {

        require(_transactionId > 0 && _transactionId < transactionsNextIndex, ERROR_NO_TRANSACTION);

        _;

    }



    modifier periodExists(uint64 _periodId) {

        require(_periodId < periodsLength, ERROR_NO_PERIOD);

        _;

    }



    /**

     * @dev Sends ETH to Vault. Sends all the available balance.

     * @notice Deposit ETH to the Vault, to avoid locking them in this Finance app forever

     */

    function () external payable isInitialized transitionsPeriod {

        _deposit(

            ETH,

            msg.value,

            "Ether transfer to Finance app",

            msg.sender,

            true

        );

    }



    /**

    * @notice Initialize Finance app for Vault at `_vault` with period length of `@transformTime(_periodDuration)`

    * @param _vault Address of the vault Finance will rely on (non changeable)

    * @param _periodDuration Duration in seconds of each period

    */

    function initialize(Vault _vault, uint64 _periodDuration) external onlyInit {

        initialized();



        require(isContract(_vault), ERROR_VAULT_NOT_CONTRACT);

        vault = _vault;



        require(_periodDuration >= 1 days, ERROR_INIT_PERIOD_TOO_SHORT);

        settings.periodDuration = _periodDuration;



        // Reserve the first recurring payment index as an unused index for transactions not linked to a payment

        payments[0].inactive = true;

        paymentsNextIndex = 1;



        // Reserve the first transaction index as an unused index for periods with no transactions

        transactionsNextIndex = 1;



        // Start the first period

        _newPeriod(getTimestamp64());

    }



    /**

    * @dev Deposit for approved ERC20 tokens or ETH

    * @notice Deposit `@tokenAmount(_token, _amount)`

    * @param _token Address of deposited token

    * @param _amount Amount of tokens sent

    * @param _reference Reason for payment

    */

    function deposit(address _token, uint256 _amount, string _reference) external payable isInitialized transitionsPeriod {

        _deposit(

            _token,

            _amount,

            _reference,

            msg.sender,

            true

        );

    }



    /**

    * @notice Create a new payment of `@tokenAmount(_token, _amount)` to `_receiver``_maxRepeats > 0 ? ', executing ' + _maxRepeats + ' times at intervals of ' + @transformTime(_interval) : ''`

    * @param _token Address of token for payment

    * @param _receiver Address that will receive payment

    * @param _amount Tokens that are payed every time the payment is due

    * @param _initialPaymentTime Timestamp for when the first payment is done

    * @param _interval Number of seconds that need to pass between payment transactions

    * @param _maxRepeats Maximum instances a payment can be executed

    * @param _reference String detailing payment reason

    */

    function newPayment(

        address _token,

        address _receiver,

        uint256 _amount,

        uint64 _initialPaymentTime,

        uint64 _interval,

        uint64 _maxRepeats,

        string _reference

    )

        external

        authP(CREATE_PAYMENTS_ROLE, arr(_token, _receiver, _amount, _interval, _maxRepeats))

        transitionsPeriod

        returns (uint256 paymentId)

    {

        require(_amount > 0, ERROR_NEW_PAYMENT_AMOUNT_ZERO);



        // Avoid saving payment data for 1 time immediate payments

        if (_initialPaymentTime <= getTimestamp64() && _maxRepeats == 1) {

            _makePaymentTransaction(

                _token,

                _receiver,

                _amount,

                NO_PAYMENT,   // unrelated to any payment id; it isn't created

                0,   // also unrelated to any payment repeats

                _reference

            );

            return;

        }



        // Budget must allow at least one instance of this payment each period, or not be set at all

        require(settings.budgets[_token] >= _amount || !settings.hasBudget[_token], ERROR_BUDGET);



        paymentId = paymentsNextIndex++;

        emit NewPayment(paymentId, _receiver, _maxRepeats, _reference);



        Payment storage payment = payments[paymentId];

        payment.token = _token;

        payment.receiver = _receiver;

        payment.amount = _amount;

        payment.initialPaymentTime = _initialPaymentTime;

        payment.interval = _interval;

        payment.maxRepeats = _maxRepeats;

        payment.createdBy = msg.sender;



        if (nextPaymentTime(paymentId) <= getTimestamp64()) {

            _executePayment(paymentId);

        }

    }



    /**

    * @notice Change period duration to `@transformTime(_periodDuration)`, effective for next accounting period

    * @param _periodDuration Duration in seconds for accounting periods

    */

    function setPeriodDuration(uint64 _periodDuration)

        external

        authP(CHANGE_PERIOD_ROLE, arr(uint256(_periodDuration), uint256(settings.periodDuration)))

        transitionsPeriod

    {

        require(_periodDuration >= 1 days, ERROR_SET_PERIOD_TOO_SHORT);

        settings.periodDuration = _periodDuration;

        emit ChangePeriodDuration(_periodDuration);

    }



    /**

    * @notice Set budget for `_token.symbol(): string` to `@tokenAmount(_token, _amount, false)`, effective immediately

    * @param _token Address for token

    * @param _amount New budget amount

    */

    function setBudget(

        address _token,

        uint256 _amount

    )

        external

        authP(CHANGE_BUDGETS_ROLE, arr(_token, _amount, settings.budgets[_token], settings.hasBudget[_token] ? 1 : 0))

        transitionsPeriod

    {

        settings.budgets[_token] = _amount;

        if (!settings.hasBudget[_token]) {

            settings.hasBudget[_token] = true;

        }

        emit SetBudget(_token, _amount, true);

    }



    /**

    * @notice Remove spending limit for `_token.symbol(): string`, effective immediately

    * @param _token Address for token

    */

    function removeBudget(address _token)

        external

        authP(CHANGE_BUDGETS_ROLE, arr(_token, uint256(0), settings.budgets[_token], settings.hasBudget[_token] ? 1 : 0))

        transitionsPeriod

    {

        settings.budgets[_token] = 0;

        settings.hasBudget[_token] = false;

        emit SetBudget(_token, 0, false);

    }



    /**

    * @dev Executes any payment (requires role)

    * @notice Execute pending payment #`_paymentId`

    * @param _paymentId Identifier for payment

    */

    function executePayment(uint256 _paymentId)

        external

        authP(EXECUTE_PAYMENTS_ROLE, arr(_paymentId, payments[_paymentId].amount))

        paymentExists(_paymentId)

        transitionsPeriod

    {

        require(nextPaymentTime(_paymentId) <= getTimestamp64(), ERROR_EXECUTE_PAYMENT_TIME);



        _executePayment(_paymentId);

    }



    /**

    * @dev Always allows receiver of a payment to trigger execution

    * @notice Execute pending payment #`_paymentId`

    * @param _paymentId Identifier for payment

    */

    function receiverExecutePayment(uint256 _paymentId) external isInitialized paymentExists(_paymentId) transitionsPeriod {

        require(nextPaymentTime(_paymentId) <= getTimestamp64(), ERROR_RECEIVER_EXECUTE_PAYMENT_TIME);

        require(payments[_paymentId].receiver == msg.sender, ERROR_PAYMENT_RECEIVER);



        _executePayment(_paymentId);

    }



    /**

    * @notice `_active ? 'Activate' : 'Disable'` payment #`_paymentId`

    * @dev Note that we do not require this action to transition periods, as it doesn't directly

    *      impact any accounting periods.

    *      Not having to transition periods also makes disabling payments easier to prevent funds

    *      from being pulled out in the event of a breach.

    * @param _paymentId Identifier for payment

    * @param _active Whether it will be active or inactive

    */

    function setPaymentStatus(uint256 _paymentId, bool _active)

        external

        authP(MANAGE_PAYMENTS_ROLE, arr(_paymentId, uint256(_active ? 1 : 0)))

        paymentExists(_paymentId)

    {

        payments[_paymentId].inactive = !_active;

        emit ChangePaymentState(_paymentId, _active);

    }



    /**

     * @dev Allows making a simple payment from this contract to the Vault, to avoid locked tokens.

     *      This contract should never receive tokens with a simple transfer call, but in case it

     *      happens, this function allows for their recovery.

     * @notice Send tokens held in this contract to the Vault

     * @param _token Token whose balance is going to be transferred.

     */

    function recoverToVault(address _token) public isInitialized transitionsPeriod {

        uint256 amount = _token == ETH ? address(this).balance : ERC20(_token).balanceOf(this);

        require(amount > 0, ERROR_RECOVER_AMOUNT_ZERO);



        _deposit(

            _token,

            amount,

            "Recover to Vault",

            this,

            false

        );

    }



    /**

    * @dev Transitions accounting periods if needed. For preventing OOG attacks, a maxTransitions

    *      param is provided. If more than the specified number of periods need to be transitioned,

    *      it will return false.

    * @notice Transition accounting period if needed

    * @param _maxTransitions Maximum periods that can be transitioned

    * @return success Boolean indicating whether the accounting period is the correct one (if false,

    *                 maxTransitions was surpased and another call is needed)

    */

    function tryTransitionAccountingPeriod(uint64 _maxTransitions) public isInitialized returns (bool success) {

        return _tryTransitionAccountingPeriod(_maxTransitions);

    }



    // consts



    /**

    * @dev Disable recovery escape hatch if the app has been initialized, as it could be used

    *      maliciously to transfer funds in the Finance app to another Vault

    *      finance#recoverToVault() should be used to recover funds to the Finance's vault

    */

    function allowRecoverability(address) public view returns (bool) {

        return !hasInitialized();

    }



    function getPayment(uint256 _paymentId)

        public

        view

        paymentExists(_paymentId)

        returns (

            address token,

            address receiver,

            uint256 amount,

            uint64 initialPaymentTime,

            uint64 interval,

            uint64 maxRepeats,

            bool inactive,

            uint64 repeats,

            address createdBy

        )

    {

        Payment storage payment = payments[_paymentId];



        token = payment.token;

        receiver = payment.receiver;

        amount = payment.amount;

        initialPaymentTime = payment.initialPaymentTime;

        interval = payment.interval;

        maxRepeats = payment.maxRepeats;

        repeats = payment.repeats;

        inactive = payment.inactive;

        createdBy = payment.createdBy;

    }



    function getTransaction(uint256 _transactionId)

        public

        view

        transactionExists(_transactionId)

        returns (

            uint64 periodId,

            uint256 amount,

            uint256 paymentId,

            uint64 paymentRepeatNumber,

            address token,

            address entity,

            bool isIncoming,

            uint64 date

        )

    {

        Transaction storage transaction = transactions[_transactionId];



        token = transaction.token;

        entity = transaction.entity;

        isIncoming = transaction.isIncoming;

        date = transaction.date;

        periodId = transaction.periodId;

        amount = transaction.amount;

        paymentId = transaction.paymentId;

        paymentRepeatNumber = transaction.paymentRepeatNumber;

    }



    function getPeriod(uint64 _periodId)

        public

        view

        periodExists(_periodId)

        returns (

            bool isCurrent,

            uint64 startTime,

            uint64 endTime,

            uint256 firstTransactionId,

            uint256 lastTransactionId

        )

    {

        Period storage period = periods[_periodId];



        isCurrent = _currentPeriodId() == _periodId;



        startTime = period.startTime;

        endTime = period.endTime;

        firstTransactionId = period.firstTransactionId;

        lastTransactionId = period.lastTransactionId;

    }



    function getPeriodTokenStatement(uint64 _periodId, address _token)

        public

        view

        periodExists(_periodId)

        returns (uint256 expenses, uint256 income)

    {

        TokenStatement storage tokenStatement = periods[_periodId].tokenStatement[_token];

        expenses = tokenStatement.expenses;

        income = tokenStatement.income;

    }



    function nextPaymentTime(uint256 _paymentId) public view paymentExists(_paymentId) returns (uint64) {

        Payment memory payment = payments[_paymentId];



        if (payment.repeats >= payment.maxRepeats) {

            return MAX_UINT64; // re-executes in some billions of years time... should not need to worry

        }



        // Split in multiple lines to circunvent linter warning

        uint64 increase = payment.repeats.mul(payment.interval);

        uint64 nextPayment = payment.initialPaymentTime.add(increase);

        return nextPayment;

    }



    function getPeriodDuration() public view returns (uint64) {

        return settings.periodDuration;

    }



    function getBudget(address _token) public view returns (uint256 budget, bool hasBudget) {

        budget = settings.budgets[_token];

        hasBudget = settings.hasBudget[_token];

    }



    /**

    * @dev We have to check for initialization as periods are only valid after initializing

    */

    function getRemainingBudget(address _token) public view isInitialized returns (uint256) {

        return _getRemainingBudget(_token);

    }



    /**

    * @dev We have to check for initialization as periods are only valid after initializing

    */

    function currentPeriodId() public view isInitialized returns (uint64) {

        return _currentPeriodId();

    }



    // internal fns



    function _deposit(address _token, uint256 _amount, string _reference, address _sender, bool _isExternalDeposit) internal {

        require(_amount > 0, ERROR_DEPOSIT_AMOUNT_ZERO);

        _recordIncomingTransaction(

            _token,

            _sender,

            _amount,

            _reference

        );



        // If it is an external deposit, check that the assets are actually transferred

        // External deposit will be false when the assets were already in the Finance app

        // and just need to be transferred to the vault

        if (_isExternalDeposit) {

            if (_token != ETH) {

                // Get the tokens to Finance

                require(ERC20(_token).transferFrom(msg.sender, this, _amount), ERROR_TOKEN_TRANSFER_FROM_REVERTED);

            } else {

                // Ensure that the ETH sent with the transaction equals the amount in the deposit

                require(msg.value == _amount, ERROR_VALUE_MISMATCH);

            }

        }



        if (_token == ETH) {

            vault.deposit.value(_amount)(ETH, _amount);

        } else {

            ERC20(_token).approve(vault, _amount);

            // finally we can deposit them

            vault.deposit(_token, _amount);

        }

    }



    function _newPeriod(uint64 _startTime) internal returns (Period storage) {

        // There should be no way for this to overflow since each period is at least one day

        uint64 newPeriodId = periodsLength++;



        Period storage period = periods[newPeriodId];

        period.startTime = _startTime;



        // Be careful here to not overflow; if startTime + periodDuration overflows, we set endTime

        // to MAX_UINT64 (let's assume that's the end of time for now).

        uint64 endTime = _startTime + settings.periodDuration - 1;

        if (endTime < _startTime) { // overflowed

            endTime = MAX_UINT64;

        }

        period.endTime = endTime;



        emit NewPeriod(newPeriodId, period.startTime, period.endTime);



        return period;

    }



    function _executePayment(uint256 _paymentId) internal {

        Payment storage payment = payments[_paymentId];

        require(!payment.inactive, ERROR_PAYMENT_INACTIVE);



        uint64 payed = 0;

        while (nextPaymentTime(_paymentId) <= getTimestamp64() && payed < MAX_PAYMENTS_PER_TX) {

            if (!_canMakePayment(payment.token, payment.amount)) {

                emit PaymentFailure(_paymentId);

                return;

            }



            // The while() predicate prevents these two from ever overflowing

            payment.repeats += 1;

            payed += 1;



            _makePaymentTransaction(

                payment.token,

                payment.receiver,

                payment.amount,

                _paymentId,

                payment.repeats,

                ""

            );

        }

    }



    function _makePaymentTransaction(

        address _token,

        address _receiver,

        uint256 _amount,

        uint256 _paymentId,

        uint64 _paymentRepeatNumber,

        string _reference

    )

        internal

    {

        require(_getRemainingBudget(_token) >= _amount, ERROR_REMAINING_BUDGET);

        _recordTransaction(

            false,

            _token,

            _receiver,

            _amount,

            _paymentId,

            _paymentRepeatNumber,

            _reference

        );



        vault.transfer(_token, _receiver, _amount);

    }



    function _recordIncomingTransaction(

        address _token,

        address _sender,

        uint256 _amount,

        string _reference

    )

        internal

    {

        _recordTransaction(

            true, // incoming transaction

            _token,

            _sender,

            _amount,

            NO_PAYMENT, // unrelated to any existing payment

            0, // and no payment repeats

            _reference

        );

    }



    function _recordTransaction(

        bool _incoming,

        address _token,

        address _entity,

        uint256 _amount,

        uint256 _paymentId,

        uint64 _paymentRepeatNumber,

        string _reference

    )

        internal

    {

        uint64 periodId = _currentPeriodId();

        TokenStatement storage tokenStatement = periods[periodId].tokenStatement[_token];

        if (_incoming) {

            tokenStatement.income = tokenStatement.income.add(_amount);

        } else {

            tokenStatement.expenses = tokenStatement.expenses.add(_amount);

        }



        uint256 transactionId = transactionsNextIndex++;

        Transaction storage transaction = transactions[transactionId];

        transaction.token = _token;

        transaction.entity = _entity;

        transaction.isIncoming = _incoming;

        transaction.amount = _amount;

        transaction.paymentId = _paymentId;

        transaction.paymentRepeatNumber = _paymentRepeatNumber;

        transaction.date = getTimestamp64();

        transaction.periodId = periodId;



        Period storage period = periods[periodId];

        if (period.firstTransactionId == NO_TRANSACTION) {

            period.firstTransactionId = transactionId;

        }



        emit NewTransaction(transactionId, _incoming, _entity, _amount, _reference);

    }



    function _tryTransitionAccountingPeriod(uint256 _maxTransitions) internal returns (bool success) {

        Period storage currentPeriod = periods[_currentPeriodId()];

        uint64 timestamp = getTimestamp64();



        // Transition periods if necessary

        while (timestamp > currentPeriod.endTime) {

            if (_maxTransitions == 0) {

                // Required number of transitions is over allowed number, return false indicating

                // it didn't fully transition

                return false;

            }

            _maxTransitions = _maxTransitions.sub(1);



            // If there were any transactions in period, record which was the last

            // In case 0 transactions occured, first and last tx id will be 0

            if (currentPeriod.firstTransactionId != NO_TRANSACTION) {

                currentPeriod.lastTransactionId = transactionsNextIndex.sub(1);

            }



            // New period starts at end time + 1

            currentPeriod = _newPeriod(currentPeriod.endTime.add(1));

        }



        return true;

    }



    function _canMakePayment(address _token, uint256 _amount) internal view returns (bool) {

        return _getRemainingBudget(_token) >= _amount && vault.balance(_token) >= _amount;

    }



    function _getRemainingBudget(address _token) internal view returns (uint256) {

        if (!settings.hasBudget[_token]) {

            return MAX_UINT;

        }



        uint256 spent = periods[_currentPeriodId()].tokenStatement[_token].expenses;



        // A budget decrease can cause the spent amount to be greater than period budget

        // If so, return 0 to not allow more spending during period

        if (spent >= settings.budgets[_token]) {

            return 0;

        }



        return settings.budgets[_token].sub(spent);

    }



    function _currentPeriodId() internal view returns (uint64) {

        // There is no way for this to overflow if protected by an initialization check

        return periodsLength - 1;

    }



    // Must be view for mocking purposes

    function getMaxPeriodTransitions() internal view returns (uint64) { return MAX_UINT64; }

}