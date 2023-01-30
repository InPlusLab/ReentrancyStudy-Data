/**

 *Submitted for verification at Etherscan.io on 2018-10-23

*/



pragma solidity ^0.4.24;



contract Enum {

    enum Operation {

        Call,

        DelegateCall,

        Create

    }

}



contract EtherPaymentFallback {



    /// @dev Fallback function accepts Ether transactions.

    function ()

        external

        payable

    {



    }

}



contract Executor is EtherPaymentFallback {



    event ContractCreation(address newContract);



    function execute(address to, uint256 value, bytes data, Enum.Operation operation, uint256 txGas)

        internal

        returns (bool success)

    {

        if (operation == Enum.Operation.Call)

            success = executeCall(to, value, data, txGas);

        else if (operation == Enum.Operation.DelegateCall)

            success = executeDelegateCall(to, data, txGas);

        else {

            address newContract = executeCreate(data);

            success = newContract != 0;

            emit ContractCreation(newContract);

        }

    }



    function executeCall(address to, uint256 value, bytes data, uint256 txGas)

        internal

        returns (bool success)

    {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)

        }

    }



    function executeDelegateCall(address to, bytes data, uint256 txGas)

        internal

        returns (bool success)

    {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)

        }

    }



    function executeCreate(bytes data)

        internal

        returns (address newContract)

    {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            newContract := create(0, add(data, 0x20), mload(data))

        }

    }

}



contract SelfAuthorized {

    modifier authorized() {

        require(msg.sender == address(this), "Method can only be called from this contract");

        _;

    }

}



contract ModuleManager is SelfAuthorized, Executor {



    event EnabledModule(Module module);

    event DisabledModule(Module module);



    address public constant SENTINEL_MODULES = address(0x1);



    mapping (address => address) internal modules;

    

    function setupModules(address to, bytes data)

        internal

    {

        require(modules[SENTINEL_MODULES] == 0, "Modules have already been initialized");

        modules[SENTINEL_MODULES] = SENTINEL_MODULES;

        if (to != 0)

            // Setup has to complete successfully or transaction fails.

            require(executeDelegateCall(to, data, gasleft()), "Could not finish initialization");

    }



    /// @dev Allows to add a module to the whitelist.

    ///      This can only be done via a Safe transaction.

    /// @param module Module to be whitelisted.

    function enableModule(Module module)

        public

        authorized

    {

        // Module address cannot be null or sentinel.

        require(address(module) != 0 && address(module) != SENTINEL_MODULES, "Invalid module address provided");

        // Module cannot be added twice.

        require(modules[module] == 0, "Module has already been added");

        modules[module] = modules[SENTINEL_MODULES];

        modules[SENTINEL_MODULES] = module;

        emit EnabledModule(module);

    }



    /// @dev Allows to remove a module from the whitelist.

    ///      This can only be done via a Safe transaction.

    /// @param prevModule Module that pointed to the module to be removed in the linked list

    /// @param module Module to be removed.

    function disableModule(Module prevModule, Module module)

        public

        authorized

    {

        // Validate module address and check that it corresponds to module index.

        require(address(module) != 0 && address(module) != SENTINEL_MODULES, "Invalid module address provided");

        require(modules[prevModule] == address(module), "Invalid prevModule, module pair provided");

        modules[prevModule] = modules[module];

        modules[module] = 0;

        emit DisabledModule(module);

    }



    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.

    /// @param to Destination address of module transaction.

    /// @param value Ether value of module transaction.

    /// @param data Data payload of module transaction.

    /// @param operation Operation type of module transaction.

    function execTransactionFromModule(address to, uint256 value, bytes data, Enum.Operation operation)

        public

        returns (bool success)

    {

        // Only whitelisted modules are allowed.

        require(modules[msg.sender] != 0, "Method can only be called from an enabled module");

        // Execute transaction without further confirmations.

        success = execute(to, value, data, operation, gasleft());

    }



    /// @dev Returns array of modules.

    /// @return Array of modules.

    function getModules()

        public

        view

        returns (address[])

    {

        // Calculate module count

        uint256 moduleCount = 0;

        address currentModule = modules[SENTINEL_MODULES];

        while(currentModule != SENTINEL_MODULES) {

            currentModule = modules[currentModule];

            moduleCount ++;

        }

        address[] memory array = new address[](moduleCount);



        // populate return array

        moduleCount = 0;

        currentModule = modules[SENTINEL_MODULES];

        while(currentModule != SENTINEL_MODULES) {

            array[moduleCount] = currentModule;

            currentModule = modules[currentModule];

            moduleCount ++;

        }

        return array;

    }

}



contract OwnerManager is SelfAuthorized {



    event AddedOwner(address owner);

    event RemovedOwner(address owner);

    event ChangedThreshold(uint256 threshold);



    address public constant SENTINEL_OWNERS = address(0x1);



    mapping(address => address) internal owners;

    uint256 ownerCount;

    uint256 internal threshold;



    /// @dev Setup function sets initial storage of contract.

    /// @param _owners List of Safe owners.

    /// @param _threshold Number of required confirmations for a Safe transaction.

    function setupOwners(address[] _owners, uint256 _threshold)

        internal

    {

        // Threshold can only be 0 at initialization.

        // Check ensures that setup function can only be called once.

        require(threshold == 0, "Owners have already been setup");

        // Validate that threshold is smaller than number of added owners.

        require(_threshold <= _owners.length, "Threshold cannot exceed owner count");

        // There has to be at least one Safe owner.

        require(_threshold >= 1, "Threshold needs to be greater than 0");

        // Initializing Safe owners.

        address currentOwner = SENTINEL_OWNERS;

        for (uint256 i = 0; i < _owners.length; i++) {

            // Owner address cannot be null.

            address owner = _owners[i];

            require(owner != 0 && owner != SENTINEL_OWNERS, "Invalid owner address provided");

            // No duplicate owners allowed.

            require(owners[owner] == 0, "Duplicate owner address provided");

            owners[currentOwner] = owner;

            currentOwner = owner;

        }

        owners[currentOwner] = SENTINEL_OWNERS;

        ownerCount = _owners.length;

        threshold = _threshold;

    }



    /// @dev Allows to add a new owner to the Safe and update the threshold at the same time.

    ///      This can only be done via a Safe transaction.

    /// @param owner New owner address.

    /// @param _threshold New threshold.

    function addOwnerWithThreshold(address owner, uint256 _threshold)

        public

        authorized

    {

        // Owner address cannot be null.

        require(owner != 0 && owner != SENTINEL_OWNERS, "Invalid owner address provided");

        // No duplicate owners allowed.

        require(owners[owner] == 0, "Address is already an owner");

        owners[owner] = owners[SENTINEL_OWNERS];

        owners[SENTINEL_OWNERS] = owner;

        ownerCount++;

        emit AddedOwner(owner);

        // Change threshold if threshold was changed.

        if (threshold != _threshold)

            changeThreshold(_threshold);

    }



    /// @dev Allows to remove an owner from the Safe and update the threshold at the same time.

    ///      This can only be done via a Safe transaction.

    /// @param prevOwner Owner that pointed to the owner to be removed in the linked list

    /// @param owner Owner address to be removed.

    /// @param _threshold New threshold.

    function removeOwner(address prevOwner, address owner, uint256 _threshold)

        public

        authorized

    {

        // Only allow to remove an owner, if threshold can still be reached.

        require(ownerCount - 1 >= _threshold, "New owner count needs to be larger than new threshold");

        // Validate owner address and check that it corresponds to owner index.

        require(owner != 0 && owner != SENTINEL_OWNERS, "Invalid owner address provided");

        require(owners[prevOwner] == owner, "Invalid prevOwner, owner pair provided");

        owners[prevOwner] = owners[owner];

        owners[owner] = 0;

        ownerCount--;

        emit RemovedOwner(owner);

        // Change threshold if threshold was changed.

        if (threshold != _threshold)

            changeThreshold(_threshold);

    }



    /// @dev Allows to swap/replace an owner from the Safe with another address.

    ///      This can only be done via a Safe transaction.

    /// @param prevOwner Owner that pointed to the owner to be replaced in the linked list

    /// @param oldOwner Owner address to be replaced.

    /// @param newOwner New owner address.

    function swapOwner(address prevOwner, address oldOwner, address newOwner)

        public

        authorized

    {

        // Owner address cannot be null.

        require(newOwner != 0 && newOwner != SENTINEL_OWNERS, "Invalid owner address provided");

        // No duplicate owners allowed.

        require(owners[newOwner] == 0, "Address is already an owner");

        // Validate oldOwner address and check that it corresponds to owner index.

        require(oldOwner != 0 && oldOwner != SENTINEL_OWNERS, "Invalid owner address provided");

        require(owners[prevOwner] == oldOwner, "Invalid prevOwner, owner pair provided");

        owners[newOwner] = owners[oldOwner];

        owners[prevOwner] = newOwner;

        owners[oldOwner] = 0;

        emit RemovedOwner(oldOwner);

        emit AddedOwner(newOwner);

    }



    /// @dev Allows to update the number of required confirmations by Safe owners.

    ///      This can only be done via a Safe transaction.

    /// @param _threshold New threshold.

    function changeThreshold(uint256 _threshold)

        public

        authorized

    {

        // Validate that threshold is smaller than number of owners.

        require(_threshold <= ownerCount, "Threshold cannot exceed owner count");

        // There has to be at least one Safe owner.

        require(_threshold >= 1, "Threshold needs to be greater than 0");

        threshold = _threshold;

        emit ChangedThreshold(threshold);

    }



    function getThreshold()

        public

        view

        returns (uint256)

    {

        return threshold;

    }



    function isOwner(address owner)

        public

        view

        returns (bool)

    {

        return owners[owner] != 0;

    }



    /// @dev Returns array of owners.

    /// @return Array of Safe owners.

    function getOwners()

        public

        view

        returns (address[])

    {

        address[] memory array = new address[](ownerCount);



        // populate return array

        uint256 index = 0;

        address currentOwner = owners[SENTINEL_OWNERS];

        while(currentOwner != SENTINEL_OWNERS) {

            array[index] = currentOwner;

            currentOwner = owners[currentOwner];

            index ++;

        }

        return array;

    }

}



contract MasterCopy is SelfAuthorized {

  // masterCopy always needs to be first declared variable, to ensure that it is at the same location as in the Proxy contract.

  // It should also always be ensured that the address is stored alone (uses a full word)

    address masterCopy;



  /// @dev Allows to upgrade the contract. This can only be done via a Safe transaction.

  /// @param _masterCopy New contract address.

    function changeMasterCopy(address _masterCopy)

        public

        authorized

    {

        // Master copy address cannot be null.

        require(_masterCopy != 0, "Invalid master copy address provided");

        masterCopy = _masterCopy;

    }

}



contract Module is MasterCopy {



    ModuleManager public manager;



    modifier authorized() {

        require(msg.sender == address(manager), "Method can only be called from manager");

        _;

    }



    function setManager()

        internal

    {

        // manager can only be 0 at initalization of contract.

        // Check ensures that setup function can only be called once.

        require(address(manager) == 0, "Manager has already been set");

        manager = ModuleManager(msg.sender);

    }

}



contract WhitelistModule is Module {



    string public constant NAME = "Whitelist Module";

    string public constant VERSION = "0.0.2";



    // isWhitelisted mapping maps destination address to boolean.

    mapping (address => bool) public isWhitelisted;



    /// @dev Setup function sets initial storage of contract.

    /// @param accounts List of whitelisted accounts.

    function setup(address[] accounts)

        public

    {

        setManager();

        for (uint256 i = 0; i < accounts.length; i++) {

            address account = accounts[i];

            require(account != 0, "Invalid account provided");

            isWhitelisted[account] = true;

        }

    }



    /// @dev Allows to add destination to whitelist. This can only be done via a Safe transaction.

    /// @param account Destination address.

    function addToWhitelist(address account)

        public

        authorized

    {

        require(account != 0, "Invalid account provided");

        require(!isWhitelisted[account], "Account is already whitelisted");

        isWhitelisted[account] = true;

    }



    /// @dev Allows to remove destination from whitelist. This can only be done via a Safe transaction.

    /// @param account Destination address.

    function removeFromWhitelist(address account)

        public

        authorized

    {

        require(isWhitelisted[account], "Account is not whitelisted");

        isWhitelisted[account] = false;

    }



    /// @dev Returns if Safe transaction is to a whitelisted destination.

    /// @param to Whitelisted destination address.

    /// @param value Not checked.

    /// @param data Not checked.

    /// @return Returns if transaction can be executed.

    function executeWhitelisted(address to, uint256 value, bytes data)

        public

        returns (bool)

    {

        // Only Safe owners are allowed to execute transactions to whitelisted accounts.

        require(OwnerManager(manager).isOwner(msg.sender), "Method can only be called by an owner");

        require(isWhitelisted[to], "Target account is not whitelisted");

        require(manager.execTransactionFromModule(to, value, data, Enum.Operation.Call), "Could not execute transaction");

    }

}