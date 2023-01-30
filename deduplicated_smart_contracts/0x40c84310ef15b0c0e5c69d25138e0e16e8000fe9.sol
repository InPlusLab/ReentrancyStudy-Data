/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

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

pragma solidity ^0.5.4;

/**
 * @title Proxy
 * @dev Basic proxy that delegates all calls to a fixed implementing contract.
 * The implementing contract cannot be upgraded.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract Proxy {

    address implementation;

    event Received(uint indexed value, address indexed sender, bytes data);

    constructor(address _implementation) public {
        implementation = _implementation;
    }

    function() external payable {

        if (msg.data.length == 0 && msg.value > 0) {
            emit Received(msg.value, msg.sender, msg.data);
        } else {
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                let target := sload(0)
                calldatacopy(0, 0, calldatasize())
                let result := delegatecall(gas, target, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 {revert(0, returndatasize())}
                default {return (0, returndatasize())}
            }
        }
    }
}

/**
 * @title BaseWallet
 * @dev Simple modular wallet that authorises modules to call its invoke() method.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract BaseWallet {
    function init(address _owner, address[] calldata _modules) external;
    function authoriseModule(address _module, bool _value) external;
    function enableStaticCall(address _module, bytes4 _method) external;
    function setOwner(address _newOwner) external;
    function invoke(address _target, uint _value, bytes calldata _data) external returns (bytes memory _result);
    function() external payable;
}

/**
 * @title Owned
 * @dev Basic contract to define an owner.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract Owned {

    // The owner
    address public owner;

    event OwnerChanged(address indexed _newOwner);

    /**
     * @dev Throws if the sender is not the owner.
     */
    modifier onlyOwner {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Lets the owner transfer ownership of the contract to a new owner.
     * @param _newOwner The new owner.
     */
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

/**
 * @title Managed
 * @dev Basic contract that defines a set of managers. Only the owner can add/remove managers.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract Managed is Owned {

    // The managers
    mapping (address => bool) public managers;

    /**
     * @dev Throws if the sender is not a manager.
     */
    modifier onlyManager {
        require(managers[msg.sender] == true, "M: Must be manager");
        _;
    }

    event ManagerAdded(address indexed _manager);
    event ManagerRevoked(address indexed _manager);

    /**
    * @dev Adds a manager.
    * @param _manager The address of the manager.
    */
    function addManager(address _manager) external onlyOwner {
        require(_manager != address(0), "M: Address must not be null");
        if (managers[_manager] == false) {
            managers[_manager] = true;
            emit ManagerAdded(_manager);
        }
    }

    /**
    * @dev Revokes a manager.
    * @param _manager The address of the manager.
    */
    function revokeManager(address _manager) external onlyOwner {
        require(managers[_manager] == true, "M: Target must be an existing manager");
        delete managers[_manager];
        emit ManagerRevoked(_manager);
    }
}

/**
 * @dev Interface for an ENS Mananger.
 */
interface IENSManager {
    event RootnodeOwnerChange(bytes32 indexed _rootnode, address indexed _newOwner);
    event ENSResolverChanged(address addr);
    event Registered(address indexed _owner, string _ens);
    event Unregistered(string _ens);

    function changeRootnodeOwner(address _newOwner) external;
    function register(string calldata _label, address _owner) external;
    function isAvailable(bytes32 _subnode) external view returns(bool);
    function getENSReverseRegistrar() external view returns (address);
    function ensResolver() external view returns (address);
}

/**
 * @title ModuleRegistry
 * @dev Registry of authorised modules.
 * Modules must be registered before they can be authorised on a wallet.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract ModuleRegistry {
    function registerModule(address _module, bytes32 _name) external;
    function deregisterModule(address _module) external;
    function registerUpgrader(address _upgrader, bytes32 _name) external;
    function deregisterUpgrader(address _upgrader) external;
    function moduleInfo(address _module) external view returns (bytes32);
    function upgraderInfo(address _upgrader) external view returns (bytes32);
    function isRegisteredModule(address _module) external view returns (bool);
    function isRegisteredModule(address[] calldata _modules) external view returns (bool);
    function isRegisteredUpgrader(address _upgrader) external view returns (bool);
}

/**
 * @dev Interface for a contract storing guardian addresses.
 */
interface IGuardianStorage{
    function addGuardian(BaseWallet _wallet, address _guardian) external;
    function revokeGuardian(BaseWallet _wallet, address _guardian) external;
    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool);
}

/**
 * @title WalletFactory
 * @dev The WalletFactory contract creates and assigns wallets to accounts.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract WalletFactory is Owned, Managed {

    // The address of the module dregistry
    address public moduleRegistry;
    // The address of the base wallet implementation
    address public walletImplementation;
    // The address of the ENS manager
    address public ensManager;
    // The address of the GuardianStorage
    address public guardianStorage;

    // *************** Events *************************** //

    event ModuleRegistryChanged(address addr);
    event ENSManagerChanged(address addr);
    event GuardianStorageChanged(address addr);
    event WalletCreated(address indexed wallet, address indexed owner, address indexed guardian);

    // *************** Modifiers *************************** //

    /**
     * @dev Throws if the guardian storage address is not set.
     */
    modifier guardianStorageDefined {
        require(guardianStorage != address(0), "GuardianStorage address not defined");
        _;
    }

    // *************** Constructor ********************** //

    /**
     * @dev Default constructor.
     */
    constructor(address _moduleRegistry, address _walletImplementation, address _ensManager) public {
        moduleRegistry = _moduleRegistry;
        walletImplementation = _walletImplementation;
        ensManager = _ensManager;
    }

    // *************** External Functions ********************* //

    /**
     * @dev Lets the manager create a wallet for an owner account.
     * The wallet is initialised with a list of modules and an ENS..
     * The wallet is created using the CREATE opcode.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _label ENS label of the new wallet, e.g. franck.
     */
    function createWallet(
        address _owner,
        address[] calldata _modules,
        string calldata _label
    )
        external
        onlyManager
    {
        _createWallet(_owner, _modules, _label, address(0));
    }

    /**
     * @dev Lets the manager create a wallet for an owner account.
     * The wallet is initialised with a list of modules, a first guardian, and an ENS..
     * The wallet is created using the CREATE opcode.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _label ENS label of the new wallet, e.g. franck.
     * @param _guardian The guardian address.
     */
    function createWalletWithGuardian(
        address _owner,
        address[] calldata _modules,
        string calldata _label,
        address _guardian
    )
        external
        onlyManager
        guardianStorageDefined
    {
        require(_guardian != (address(0)), "WF: guardian cannot be null");
        _createWallet(_owner, _modules, _label, _guardian);
    }

    /**
     * @dev Lets the manager create a wallet for an owner account at a specific address.
     * The wallet is initialised with a list of modules and an ENS.
     * The wallet is created using the CREATE2 opcode.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _label ENS label of the new wallet, e.g. franck.
     * @param _salt The salt.
     */
    function createCounterfactualWallet(
        address _owner,
        address[] calldata _modules,
        string calldata _label,
        bytes32 _salt
    )
        external
        onlyManager
    {
        _createCounterfactualWallet(_owner, _modules, _label, address(0), _salt);
    }

    /**
     * @dev Lets the manager create a wallet for an owner account at a specific address.
     * The wallet is initialised with a list of modules, a first guardian, and an ENS.
     * The wallet is created using the CREATE2 opcode.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _label ENS label of the new wallet, e.g. franck.
     * @param _guardian The guardian address.
     * @param _salt The salt.
     */
    function createCounterfactualWalletWithGuardian(
        address _owner,
        address[] calldata _modules,
        string calldata _label,
        address _guardian,
        bytes32 _salt
    )
        external
        onlyManager
        guardianStorageDefined
    {
        require(_guardian != (address(0)), "WF: guardian cannot be null");
        _createCounterfactualWallet(_owner, _modules, _label, _guardian, _salt);
    }

    /**
     * @dev Gets the address of a counterfactual wallet.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _salt The salt.
     * @return the address that the wallet will have when created using CREATE2 and the same input parameters.
     */
    function getAddressForCounterfactualWallet(
        address _owner,
        address[] calldata _modules,
        bytes32 _salt
    )
        external
        view
        returns (address _wallet)
    {
        _wallet = _getAddressForCounterfactualWallet(_owner, _modules, address(0), _salt);
    }

    /**
     * @dev Gets the address of a counterfactual wallet with a first default guardian.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _guardian The guardian address.
     * @param _salt The salt.
     * @return the address that the wallet will have when created using CREATE2 and the same input parameters.
     */
    function getAddressForCounterfactualWalletWithGuardian(
        address _owner,
        address[] calldata _modules,
        address _guardian,
        bytes32 _salt
    )
        external
        view
        returns (address _wallet)
    {
        require(_guardian != (address(0)), "WF: guardian cannot be null");
        _wallet = _getAddressForCounterfactualWallet(_owner, _modules, _guardian, _salt);
    }

    /**
     * @dev Lets the owner change the address of the module registry contract.
     * @param _moduleRegistry The address of the module registry contract.
     */
    function changeModuleRegistry(address _moduleRegistry) external onlyOwner {
        require(_moduleRegistry != address(0), "WF: address cannot be null");
        moduleRegistry = _moduleRegistry;
        emit ModuleRegistryChanged(_moduleRegistry);
    }

    /**
     * @dev Lets the owner change the address of the ENS manager contract.
     * @param _ensManager The address of the ENS manager contract.
     */
    function changeENSManager(address _ensManager) external onlyOwner {
        require(_ensManager != address(0), "WF: address cannot be null");
        ensManager = _ensManager;
        emit ENSManagerChanged(_ensManager);
    }

    /**
     * @dev Lets the owner change the address of the GuardianStorage contract.
     * @param _guardianStorage The address of the GuardianStorage contract.
     */
    function changeGuardianStorage(address _guardianStorage) external onlyOwner {
        require(_guardianStorage != address(0), "WF: address cannot be null");
        guardianStorage = _guardianStorage;
        emit GuardianStorageChanged(_guardianStorage);
    }

    /**
     * @dev Inits the module for a wallet by logging an event.
     * The method can only be called by the wallet itself.
     * @param _wallet The wallet.
     */
    function init(BaseWallet _wallet) external pure { // solium-disable-line no-empty-blocks
        //do nothing
    }

    // *************** Internal Functions ********************* //

    /**
     * @dev Helper method to create a wallet for an owner account.
     * The wallet is initialised with a list of modules, a first guardian, and an ENS.
     * The wallet is created using the CREATE opcode.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _label ENS label of the new wallet, e.g. franck.
     * @param _guardian (Optional) The guardian address.
     */
    function _createWallet(address _owner, address[] memory _modules, string memory _label, address _guardian) internal {
        _validateInputs(_owner, _modules, _label);
        Proxy proxy = new Proxy(walletImplementation);
        address payable wallet = address(proxy);
        _configureWallet(BaseWallet(wallet), _owner, _modules, _label, _guardian);
    }

    /**
     * @dev Helper method to create a wallet for an owner account at a specific address.
     * The wallet is initialised with a list of modules, a first guardian, and an ENS.
     * The wallet is created using the CREATE2 opcode.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _label ENS label of the new wallet, e.g. franck.
     * @param _guardian The guardian address.
     * @param _salt The salt.
     */
    function _createCounterfactualWallet(
        address _owner,
        address[] memory _modules,
        string memory _label,
        address _guardian,
        bytes32 _salt
    )
        internal
    {
        _validateInputs(_owner, _modules, _label);
        bytes32 newsalt = _newSalt(_salt, _owner, _modules, _guardian);
        bytes memory code = abi.encodePacked(type(Proxy).creationCode, uint256(walletImplementation));
        address payable wallet;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            wallet := create2(0, add(code, 0x20), mload(code), newsalt)
            if iszero(extcodesize(wallet)) { revert(0, returndatasize) }
        }
        _configureWallet(BaseWallet(wallet), _owner, _modules, _label, _guardian);
    }

    /**
     * @dev Helper method to configure a wallet for a set of input parameters.
     * @param _wallet The target wallet
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _label ENS label of the new wallet, e.g. franck.
     * @param _guardian (Optional) The guardian address.
     */
    function _configureWallet(
        BaseWallet _wallet,
        address _owner,
        address[] memory _modules,
        string memory _label,
        address _guardian
    )
        internal
    {
        // add the factory to modules so it can claim the reverse ENS or add a guardian
        address[] memory extendedModules = new address[](_modules.length + 1);
        extendedModules[0] = address(this);
        for (uint i = 0; i < _modules.length; i++) {
            extendedModules[i + 1] = _modules[i];
        }
        // initialise the wallet with the owner and the extended modules
        _wallet.init(_owner, extendedModules);
        // add guardian if needed
        if (_guardian != address(0)) {
            IGuardianStorage(guardianStorage).addGuardian(_wallet, _guardian);
        }
        // register ENS
        _registerWalletENS(address(_wallet), _label);
        // remove the factory from the authorised modules
        _wallet.authoriseModule(address(this), false);
        // emit event
        emit WalletCreated(address(_wallet), _owner, _guardian);
    }

    /**
     * @dev Gets the address of a counterfactual wallet.
     * @param _owner The account address.
     * @param _modules The list of modules.
     * @param _salt The salt.
     * @param _guardian (Optional) The guardian address.
     * @return the address that the wallet will have when created using CREATE2 and the same input parameters.
     */
    function _getAddressForCounterfactualWallet(
        address _owner,
        address[] memory _modules,
        address _guardian,
        bytes32 _salt
    )
        internal
        view
        returns (address _wallet)
    {
        bytes32 newsalt = _newSalt(_salt, _owner, _modules, _guardian);
        bytes memory code = abi.encodePacked(type(Proxy).creationCode, uint256(walletImplementation));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), newsalt, keccak256(code)));
        _wallet = address(uint160(uint256(hash)));
    }

    /**
     * @dev Generates a new salt based on a provided salt, an owner, a list of modules and an optional guardian.
     * @param _salt The slat provided.
     * @param _owner The owner address.
     * @param _modules The list of modules.
     * @param _guardian The guardian address.
     */
    function _newSalt(bytes32 _salt, address _owner, address[] memory _modules, address _guardian) internal pure returns (bytes32) {
        if (_guardian == address(0)) {
            return keccak256(abi.encodePacked(_salt, _owner, _modules));
        } else {
            return keccak256(abi.encodePacked(_salt, _owner, _modules, _guardian));
        }
    }

    /**
     * @dev Throws if the owner and the modules are not valid.
     * @param _owner The owner address.
     * @param _modules The list of modules.
     */
    function _validateInputs(address _owner, address[] memory _modules, string memory _label) internal view {
        require(_owner != address(0), "WF: owner cannot be null");
        require(_modules.length > 0, "WF: cannot assign with less than 1 module");
        require(ModuleRegistry(moduleRegistry).isRegisteredModule(_modules), "WF: one or more modules are not registered");
        bytes memory labelBytes = bytes(_label);
        require(labelBytes.length != 0, "WF: ENS lable must be defined");
    }

    /**
     * @dev Register an ENS subname to a wallet.
     * @param _wallet The wallet address.
     * @param _label ENS label of the new wallet (e.g. franck).
     */
    function _registerWalletENS(address payable _wallet, string memory _label) internal {
        // claim reverse
        address ensResolver = IENSManager(ensManager).ensResolver();
        bytes memory methodData = abi.encodeWithSignature("claimWithResolver(address,address)", ensManager, ensResolver);
        address ensReverseRegistrar = IENSManager(ensManager).getENSReverseRegistrar();
        BaseWallet(_wallet).invoke(ensReverseRegistrar, 0, methodData);
        // register with ENS manager
        IENSManager(ensManager).register(_label, _wallet);
    }
}