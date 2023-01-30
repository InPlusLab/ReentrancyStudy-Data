/**

 *Submitted for verification at Etherscan.io on 2019-03-28

*/



pragma solidity ^0.5.0;



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



    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)

        internal

        returns (bool success)

    {

        if (operation == Enum.Operation.Call)

            success = executeCall(to, value, data, txGas);

        else if (operation == Enum.Operation.DelegateCall)

            success = executeDelegateCall(to, data, txGas);

        else {

            address newContract = executeCreate(data);

            success = newContract != address(0);

            emit ContractCreation(newContract);

        }

    }



    function executeCall(address to, uint256 value, bytes memory data, uint256 txGas)

        internal

        returns (bool success)

    {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)

        }

    }



    function executeDelegateCall(address to, bytes memory data, uint256 txGas)

        internal

        returns (bool success)

    {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)

        }

    }



    function executeCreate(bytes memory data)

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

    

    function setupModules(address to, bytes memory data)

        internal

    {

        require(modules[SENTINEL_MODULES] == address(0), "Modules have already been initialized");

        modules[SENTINEL_MODULES] = SENTINEL_MODULES;

        if (to != address(0))

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

        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");

        // Module cannot be added twice.

        require(modules[address(module)] == address(0), "Module has already been added");

        modules[address(module)] = modules[SENTINEL_MODULES];

        modules[SENTINEL_MODULES] = address(module);

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

        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");

        require(modules[address(prevModule)] == address(module), "Invalid prevModule, module pair provided");

        modules[address(prevModule)] = modules[address(module)];

        modules[address(module)] = address(0);

        emit DisabledModule(module);

    }



    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.

    /// @param to Destination address of module transaction.

    /// @param value Ether value of module transaction.

    /// @param data Data payload of module transaction.

    /// @param operation Operation type of module transaction.

    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)

        public

        returns (bool success)

    {

        // Only whitelisted modules are allowed.

        require(msg.sender != SENTINEL_MODULES && modules[msg.sender] != address(0), "Method can only be called from an enabled module");

        // Execute transaction without further confirmations.

        success = execute(to, value, data, operation, gasleft());

    }



    /// @dev Returns array of modules.

    /// @return Array of modules.

    function getModules()

        public

        view

        returns (address[] memory)

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

        require(_masterCopy != address(0), "Invalid master copy address provided");

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

        require(address(manager) == address(0), "Manager has already been set");

        manager = ModuleManager(msg.sender);

    }

}



contract CreateAndAddModules {



    /// @dev Function required to compile contract. Gnosis Safe function is called instead.

    /// @param module Not used.

    function enableModule(Module module)

        public

    {

        revert();

    }



    /// @dev Allows to create and add multiple module in one transaction.

    /// @param proxyFactory Module proxy factory contract.

    /// @param data Modules constructor payload. This is the data for each proxy factory call concatinated. (e.g. <byte_array_len_1><byte_array_data_1><byte_array_len_2><byte_array_data_2>)

    function createAndAddModules(address proxyFactory, bytes memory data)

        public

    {

        uint256 length = data.length;

        Module module;

        uint256 i = 0;

        while (i < length) {

            // solium-disable-next-line security/no-inline-assembly

            assembly {

                let createBytesLength := mload(add(0x20, add(data, i)))

                let createBytes := add(0x40, add(data, i))



                let output := mload(0x40)

                if eq(delegatecall(gas, proxyFactory, createBytes, createBytesLength, output, 0x20), 0) { revert(0, 0) }

                module := and(mload(output), 0xffffffffffffffffffffffffffffffffffffffff)



                // Data is always padded to 32 bytes

                i := add(i, add(0x20, mul(div(add(createBytesLength, 0x1f), 0x20), 0x20)))

            }

            this.enableModule(module);

        }

    }

}