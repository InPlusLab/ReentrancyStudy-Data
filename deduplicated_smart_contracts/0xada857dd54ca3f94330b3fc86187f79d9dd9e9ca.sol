/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity >=0.4.25 <0.6.0;

pragma experimental ABIEncoderV2;

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Modifiable
 * @notice A contract with basic modifiers
 */
contract Modifiable {
    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier notNullAddress(address _address) {
        require(_address != address(0));
        _;
    }

    modifier notThisAddress(address _address) {
        require(_address != address(this));
        _;
    }

    modifier notNullOrThisAddress(address _address) {
        require(_address != address(0));
        require(_address != address(this));
        _;
    }

    modifier notSameAddresses(address _address1, address _address2) {
        if (_address1 != _address2)
            _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title SelfDestructible
 * @notice Contract that allows for self-destruction
 */
contract SelfDestructible {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    bool public selfDestructionDisabled;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SelfDestructionDisabledEvent(address wallet);
    event TriggerSelfDestructionEvent(address wallet);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Get the address of the destructor role
    function destructor()
    public
    view
    returns (address);

    /// @notice Disable self-destruction of this contract
    /// @dev This operation can not be undone
    function disableSelfDestruction()
    public
    {
        // Require that sender is the assigned destructor
        require(destructor() == msg.sender);

        // Disable self-destruction
        selfDestructionDisabled = true;

        // Emit event
        emit SelfDestructionDisabledEvent(msg.sender);
    }

    /// @notice Destroy this contract
    function triggerSelfDestruction()
    public
    {
        // Require that sender is the assigned destructor
        require(destructor() == msg.sender);

        // Require that self-destruction has not been disabled
        require(!selfDestructionDisabled);

        // Emit event
        emit TriggerSelfDestructionEvent(msg.sender);

        // Self-destruct and reward destructor
        selfdestruct(msg.sender);
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Ownable
 * @notice A modifiable that has ownership roles
 */
contract Ownable is Modifiable, SelfDestructible {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    address public deployer;
    address public operator;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetDeployerEvent(address oldDeployer, address newDeployer);
    event SetOperatorEvent(address oldOperator, address newOperator);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address _deployer) internal notNullOrThisAddress(_deployer) {
        deployer = _deployer;
        operator = _deployer;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Return the address that is able to initiate self-destruction
    function destructor()
    public
    view
    returns (address)
    {
        return deployer;
    }

    /// @notice Set the deployer of this contract
    /// @param newDeployer The address of the new deployer
    function setDeployer(address newDeployer)
    public
    onlyDeployer
    notNullOrThisAddress(newDeployer)
    {
        if (newDeployer != deployer) {
            // Set new deployer
            address oldDeployer = deployer;
            deployer = newDeployer;

            // Emit event
            emit SetDeployerEvent(oldDeployer, newDeployer);
        }
    }

    /// @notice Set the operator of this contract
    /// @param newOperator The address of the new operator
    function setOperator(address newOperator)
    public
    onlyOperator
    notNullOrThisAddress(newOperator)
    {
        if (newOperator != operator) {
            // Set new operator
            address oldOperator = operator;
            operator = newOperator;

            // Emit event
            emit SetOperatorEvent(oldOperator, newOperator);
        }
    }

    /// @notice Gauge whether message sender is deployer or not
    /// @return true if msg.sender is deployer, else false
    function isDeployer()
    internal
    view
    returns (bool)
    {
        return msg.sender == deployer;
    }

    /// @notice Gauge whether message sender is operator or not
    /// @return true if msg.sender is operator, else false
    function isOperator()
    internal
    view
    returns (bool)
    {
        return msg.sender == operator;
    }

    /// @notice Gauge whether message sender is operator or deployer on the one hand, or none of these on these on
    /// on the other hand
    /// @return true if msg.sender is operator, else false
    function isDeployerOrOperator()
    internal
    view
    returns (bool)
    {
        return isDeployer() || isOperator();
    }

    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier onlyDeployer() {
        require(isDeployer());
        _;
    }

    modifier notDeployer() {
        require(!isDeployer());
        _;
    }

    modifier onlyOperator() {
        require(isOperator());
        _;
    }

    modifier notOperator() {
        require(!isOperator());
        _;
    }

    modifier onlyDeployerOrOperator() {
        require(isDeployerOrOperator());
        _;
    }

    modifier notDeployerOrOperator() {
        require(!isDeployerOrOperator());
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Servable
 * @notice An ownable that contains registered services and their actions
 */
contract Servable is Ownable {
    //
    // Types
    // -----------------------------------------------------------------------------------------------------------------
    struct ServiceInfo {
        bool registered;
        uint256 activationTimestamp;
        mapping(bytes32 => bool) actionsEnabledMap;
        bytes32[] actionsList;
    }

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    mapping(address => ServiceInfo) internal registeredServicesMap;
    uint256 public serviceActivationTimeout;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event ServiceActivationTimeoutEvent(uint256 timeoutInSeconds);
    event RegisterServiceEvent(address service);
    event RegisterServiceDeferredEvent(address service, uint256 timeout);
    event DeregisterServiceEvent(address service);
    event EnableServiceActionEvent(address service, string action);
    event DisableServiceActionEvent(address service, string action);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the service activation timeout
    /// @param timeoutInSeconds The set timeout in unit of seconds
    function setServiceActivationTimeout(uint256 timeoutInSeconds)
    public
    onlyDeployer
    {
        serviceActivationTimeout = timeoutInSeconds;

        // Emit event
        emit ServiceActivationTimeoutEvent(timeoutInSeconds);
    }

    /// @notice Register a service contract whose activation is immediate
    /// @param service The address of the service contract to be registered
    function registerService(address service)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        _registerService(service, 0);

        // Emit event
        emit RegisterServiceEvent(service);
    }

    /// @notice Register a service contract whose activation is deferred by the service activation timeout
    /// @param service The address of the service contract to be registered
    function registerServiceDeferred(address service)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        _registerService(service, serviceActivationTimeout);

        // Emit event
        emit RegisterServiceDeferredEvent(service, serviceActivationTimeout);
    }

    /// @notice Deregister a service contract
    /// @param service The address of the service contract to be deregistered
    function deregisterService(address service)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        require(registeredServicesMap[service].registered);

        registeredServicesMap[service].registered = false;

        // Emit event
        emit DeregisterServiceEvent(service);
    }

    /// @notice Enable a named action in an already registered service contract
    /// @param service The address of the registered service contract
    /// @param action The name of the action to be enabled
    function enableServiceAction(address service, string memory action)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        require(registeredServicesMap[service].registered);

        bytes32 actionHash = hashString(action);

        require(!registeredServicesMap[service].actionsEnabledMap[actionHash]);

        registeredServicesMap[service].actionsEnabledMap[actionHash] = true;
        registeredServicesMap[service].actionsList.push(actionHash);

        // Emit event
        emit EnableServiceActionEvent(service, action);
    }

    /// @notice Enable a named action in a service contract
    /// @param service The address of the service contract
    /// @param action The name of the action to be disabled
    function disableServiceAction(address service, string memory action)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        bytes32 actionHash = hashString(action);

        require(registeredServicesMap[service].actionsEnabledMap[actionHash]);

        registeredServicesMap[service].actionsEnabledMap[actionHash] = false;

        // Emit event
        emit DisableServiceActionEvent(service, action);
    }

    /// @notice Gauge whether a service contract is registered
    /// @param service The address of the service contract
    /// @return true if service is registered, else false
    function isRegisteredService(address service)
    public
    view
    returns (bool)
    {
        return registeredServicesMap[service].registered;
    }

    /// @notice Gauge whether a service contract is registered and active
    /// @param service The address of the service contract
    /// @return true if service is registered and activate, else false
    function isRegisteredActiveService(address service)
    public
    view
    returns (bool)
    {
        return isRegisteredService(service) && block.timestamp >= registeredServicesMap[service].activationTimestamp;
    }

    /// @notice Gauge whether a service contract action is enabled which implies also registered and active
    /// @param service The address of the service contract
    /// @param action The name of action
    function isEnabledServiceAction(address service, string memory action)
    public
    view
    returns (bool)
    {
        bytes32 actionHash = hashString(action);
        return isRegisteredActiveService(service) && registeredServicesMap[service].actionsEnabledMap[actionHash];
    }

    //
    // Internal functions
    // -----------------------------------------------------------------------------------------------------------------
    function hashString(string memory _string)
    internal
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_string));
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _registerService(address service, uint256 timeout)
    private
    {
        if (!registeredServicesMap[service].registered) {
            registeredServicesMap[service].registered = true;
            registeredServicesMap[service].activationTimestamp = block.timestamp + timeout;
        }
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier onlyActiveService() {
        require(isRegisteredActiveService(msg.sender));
        _;
    }

    modifier onlyEnabledServiceAction(string memory action) {
        require(isEnabledServiceAction(msg.sender, action));
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS based on Open-Zeppelin's SafeMath library
 */

/**
 * @title     SafeMathIntLib
 * @dev       Math operations with safety checks that throw on error
 */
library SafeMathIntLib {
    int256 constant INT256_MIN = int256((uint256(1) << 255));
    int256 constant INT256_MAX = int256(~((uint256(1) << 255)));

    //
    //Functions below accept positive and negative integers and result must not overflow.
    //
    function div(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a != INT256_MIN || b != - 1);
        return a / b;
    }

    function mul(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a != - 1 || b != INT256_MIN);
        // overflow
        require(b != - 1 || a != INT256_MIN);
        // overflow
        int256 c = a * b;
        require((b == 0) || (c / b == a));
        return c;
    }

    function sub(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
        return a - b;
    }

    function add(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    //
    //Functions below only accept positive integers and result must be greater or equal to zero too.
    //
    function div_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b > 0);
        return a / b;
    }

    function mul_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0);
        int256 c = a * b;
        require(a == 0 || c / a == b);
        require(c >= 0);
        return c;
    }

    function sub_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0 && b <= a);
        return a - b;
    }

    function add_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0);
        int256 c = a + b;
        require(c >= a);
        return c;
    }

    //
    //Conversion and validation functions.
    //
    function abs(int256 a)
    public
    pure
    returns (int256)
    {
        return a < 0 ? neg(a) : a;
    }

    function neg(int256 a)
    public
    pure
    returns (int256)
    {
        return mul(a, - 1);
    }

    function toNonZeroInt256(uint256 a)
    public
    pure
    returns (int256)
    {
        require(a > 0 && a < (uint256(1) << 255));
        return int256(a);
    }

    function toInt256(uint256 a)
    public
    pure
    returns (int256)
    {
        require(a >= 0 && a < (uint256(1) << 255));
        return int256(a);
    }

    function toUInt256(int256 a)
    public
    pure
    returns (uint256)
    {
        require(a >= 0);
        return uint256(a);
    }

    function isNonZeroPositiveInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a > 0);
    }

    function isPositiveInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a >= 0);
    }

    function isNonZeroNegativeInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a < 0);
    }

    function isNegativeInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a <= 0);
    }

    //
    //Clamping functions.
    //
    function clamp(int256 a, int256 min, int256 max)
    public
    pure
    returns (int256)
    {
        if (a < min)
            return min;
        return (a > max) ? max : a;
    }

    function clampMin(int256 a, int256 min)
    public
    pure
    returns (int256)
    {
        return (a < min) ? min : a;
    }

    function clampMax(int256 a, int256 max)
    public
    pure
    returns (int256)
    {
        return (a > max) ? max : a;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library BlockNumbUintsLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Entry {
        uint256 blockNumber;
        uint256 value;
    }

    struct BlockNumbUints {
        Entry[] entries;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function currentValue(BlockNumbUints storage self)
    internal
    view
    returns (uint256)
    {
        return valueAt(self, block.number);
    }

    function currentEntry(BlockNumbUints storage self)
    internal
    view
    returns (Entry memory)
    {
        return entryAt(self, block.number);
    }

    function valueAt(BlockNumbUints storage self, uint256 _blockNumber)
    internal
    view
    returns (uint256)
    {
        return entryAt(self, _blockNumber).value;
    }

    function entryAt(BlockNumbUints storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry memory)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbUints storage self, uint256 blockNumber, uint256 value)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbUintsLib.sol:62]"
        );

        self.entries.push(Entry(blockNumber, value));
    }

    function count(BlockNumbUints storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbUints storage self)
    internal
    view
    returns (Entry[] memory)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbUints storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbUintsLib.sol:92]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library BlockNumbIntsLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Entry {
        uint256 blockNumber;
        int256 value;
    }

    struct BlockNumbInts {
        Entry[] entries;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function currentValue(BlockNumbInts storage self)
    internal
    view
    returns (int256)
    {
        return valueAt(self, block.number);
    }

    function currentEntry(BlockNumbInts storage self)
    internal
    view
    returns (Entry memory)
    {
        return entryAt(self, block.number);
    }

    function valueAt(BlockNumbInts storage self, uint256 _blockNumber)
    internal
    view
    returns (int256)
    {
        return entryAt(self, _blockNumber).value;
    }

    function entryAt(BlockNumbInts storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry memory)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbInts storage self, uint256 blockNumber, int256 value)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbIntsLib.sol:62]"
        );

        self.entries.push(Entry(blockNumber, value));
    }

    function count(BlockNumbInts storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbInts storage self)
    internal
    view
    returns (Entry[] memory)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbInts storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbIntsLib.sol:92]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library ConstantsLib {
    // Get the fraction that represents the entirety, equivalent of 100%
    function PARTS_PER()
    public
    pure
    returns (int256)
    {
        return 1e18;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library BlockNumbDisdIntsLib {
    using SafeMathIntLib for int256;

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Discount {
        int256 tier;
        int256 value;
    }

    struct Entry {
        uint256 blockNumber;
        int256 nominal;
        Discount[] discounts;
    }

    struct BlockNumbDisdInts {
        Entry[] entries;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function currentNominalValue(BlockNumbDisdInts storage self)
    internal
    view
    returns (int256)
    {
        return nominalValueAt(self, block.number);
    }

    function currentDiscountedValue(BlockNumbDisdInts storage self, int256 tier)
    internal
    view
    returns (int256)
    {
        return discountedValueAt(self, block.number, tier);
    }

    function currentEntry(BlockNumbDisdInts storage self)
    internal
    view
    returns (Entry memory)
    {
        return entryAt(self, block.number);
    }

    function nominalValueAt(BlockNumbDisdInts storage self, uint256 _blockNumber)
    internal
    view
    returns (int256)
    {
        return entryAt(self, _blockNumber).nominal;
    }

    function discountedValueAt(BlockNumbDisdInts storage self, uint256 _blockNumber, int256 tier)
    internal
    view
    returns (int256)
    {
        Entry memory entry = entryAt(self, _blockNumber);
        if (0 < entry.discounts.length) {
            uint256 index = indexByTier(entry.discounts, tier);
            if (0 < index)
                return entry.nominal.mul(
                    ConstantsLib.PARTS_PER().sub(entry.discounts[index - 1].value)
                ).div(
                    ConstantsLib.PARTS_PER()
                );
            else
                return entry.nominal;
        } else
            return entry.nominal;
    }

    function entryAt(BlockNumbDisdInts storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry memory)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addNominalEntry(BlockNumbDisdInts storage self, uint256 blockNumber, int256 nominal)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbDisdIntsLib.sol:101]"
        );

        self.entries.length++;
        Entry storage entry = self.entries[self.entries.length - 1];

        entry.blockNumber = blockNumber;
        entry.nominal = nominal;
    }

    function addDiscountedEntry(BlockNumbDisdInts storage self, uint256 blockNumber, int256 nominal,
        int256[] memory discountTiers, int256[] memory discountValues)
    internal
    {
        require(discountTiers.length == discountValues.length, "Parameter array lengths mismatch [BlockNumbDisdIntsLib.sol:118]");

        addNominalEntry(self, blockNumber, nominal);

        Entry storage entry = self.entries[self.entries.length - 1];
        for (uint256 i = 0; i < discountTiers.length; i++)
            entry.discounts.push(Discount(discountTiers[i], discountValues[i]));
    }

    function count(BlockNumbDisdInts storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbDisdInts storage self)
    internal
    view
    returns (Entry[] memory)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbDisdInts storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbDisdIntsLib.sol:148]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }

    /// @dev The index returned here is 1-based
    function indexByTier(Discount[] memory discounts, int256 tier)
    internal
    pure
    returns (uint256)
    {
        require(0 < discounts.length, "No discounts found [BlockNumbDisdIntsLib.sol:161]");
        for (uint256 i = discounts.length; i > 0; i--)
            if (tier >= discounts[i - 1].tier)
                return i;
        return 0;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title     MonetaryTypesLib
 * @dev       Monetary data types
 */
library MonetaryTypesLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Currency {
        address ct;
        uint256 id;
    }

    struct Figure {
        int256 amount;
        Currency currency;
    }

    struct NoncedAmount {
        uint256 nonce;
        int256 amount;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library BlockNumbReferenceCurrenciesLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Entry {
        uint256 blockNumber;
        MonetaryTypesLib.Currency currency;
    }

    struct BlockNumbReferenceCurrencies {
        mapping(address => mapping(uint256 => Entry[])) entriesByCurrency;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function currentCurrency(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (MonetaryTypesLib.Currency storage)
    {
        return currencyAt(self, referenceCurrency, block.number);
    }

    function currentEntry(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (Entry storage)
    {
        return entryAt(self, referenceCurrency, block.number);
    }

    function currencyAt(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency,
        uint256 _blockNumber)
    internal
    view
    returns (MonetaryTypesLib.Currency storage)
    {
        return entryAt(self, referenceCurrency, _blockNumber).currency;
    }

    function entryAt(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency,
        uint256 _blockNumber)
    internal
    view
    returns (Entry storage)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][indexByBlockNumber(self, referenceCurrency, _blockNumber)];
    }

    function addEntry(BlockNumbReferenceCurrencies storage self, uint256 blockNumber,
        MonetaryTypesLib.Currency memory referenceCurrency, MonetaryTypesLib.Currency memory currency)
    internal
    {
        require(
            0 == self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length ||
        blockNumber > self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length - 1].blockNumber,
            "Later entry found for currency [BlockNumbReferenceCurrenciesLib.sol:67]"
        );

        self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].push(Entry(blockNumber, currency));
    }

    function count(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (uint256)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length;
    }

    function entriesByCurrency(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency)
    internal
    view
    returns (Entry[] storage)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id];
    }

    function indexByBlockNumber(BlockNumbReferenceCurrencies storage self, MonetaryTypesLib.Currency memory referenceCurrency, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length, "No entries found for currency [BlockNumbReferenceCurrenciesLib.sol:97]");
        for (uint256 i = self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length - 1; i >= 0; i--)
            if (blockNumber >= self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][i].blockNumber)
                return i;
        revert();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library BlockNumbFiguresLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Entry {
        uint256 blockNumber;
        MonetaryTypesLib.Figure value;
    }

    struct BlockNumbFigures {
        Entry[] entries;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function currentValue(BlockNumbFigures storage self)
    internal
    view
    returns (MonetaryTypesLib.Figure storage)
    {
        return valueAt(self, block.number);
    }

    function currentEntry(BlockNumbFigures storage self)
    internal
    view
    returns (Entry storage)
    {
        return entryAt(self, block.number);
    }

    function valueAt(BlockNumbFigures storage self, uint256 _blockNumber)
    internal
    view
    returns (MonetaryTypesLib.Figure storage)
    {
        return entryAt(self, _blockNumber).value;
    }

    function entryAt(BlockNumbFigures storage self, uint256 _blockNumber)
    internal
    view
    returns (Entry storage)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbFigures storage self, uint256 blockNumber, MonetaryTypesLib.Figure memory value)
    internal
    {
        require(
            0 == self.entries.length ||
        blockNumber > self.entries[self.entries.length - 1].blockNumber,
            "Later entry found [BlockNumbFiguresLib.sol:65]"
        );

        self.entries.push(Entry(blockNumber, value));
    }

    function count(BlockNumbFigures storage self)
    internal
    view
    returns (uint256)
    {
        return self.entries.length;
    }

    function entries(BlockNumbFigures storage self)
    internal
    view
    returns (Entry[] storage)
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbFigures storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length, "No entries found [BlockNumbFiguresLib.sol:95]");
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Configuration
 * @notice An oracle for configurations values
 */
contract Configuration is Modifiable, Ownable, Servable {
    using SafeMathIntLib for int256;
    using BlockNumbUintsLib for BlockNumbUintsLib.BlockNumbUints;
    using BlockNumbIntsLib for BlockNumbIntsLib.BlockNumbInts;
    using BlockNumbDisdIntsLib for BlockNumbDisdIntsLib.BlockNumbDisdInts;
    using BlockNumbReferenceCurrenciesLib for BlockNumbReferenceCurrenciesLib.BlockNumbReferenceCurrencies;
    using BlockNumbFiguresLib for BlockNumbFiguresLib.BlockNumbFigures;

    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    string constant public OPERATIONAL_MODE_ACTION = "operational_mode";

    //
    // Enums
    // -----------------------------------------------------------------------------------------------------------------
    enum OperationalMode {Normal, Exit}

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    OperationalMode public operationalMode = OperationalMode.Normal;

    BlockNumbUintsLib.BlockNumbUints private updateDelayBlocksByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private confirmationBlocksByBlockNumber;

    BlockNumbDisdIntsLib.BlockNumbDisdInts private tradeMakerFeeByBlockNumber;
    BlockNumbDisdIntsLib.BlockNumbDisdInts private tradeTakerFeeByBlockNumber;
    BlockNumbDisdIntsLib.BlockNumbDisdInts private paymentFeeByBlockNumber;
    mapping(address => mapping(uint256 => BlockNumbDisdIntsLib.BlockNumbDisdInts)) private currencyPaymentFeeByBlockNumber;

    BlockNumbIntsLib.BlockNumbInts private tradeMakerMinimumFeeByBlockNumber;
    BlockNumbIntsLib.BlockNumbInts private tradeTakerMinimumFeeByBlockNumber;
    BlockNumbIntsLib.BlockNumbInts private paymentMinimumFeeByBlockNumber;
    mapping(address => mapping(uint256 => BlockNumbIntsLib.BlockNumbInts)) private currencyPaymentMinimumFeeByBlockNumber;

    BlockNumbReferenceCurrenciesLib.BlockNumbReferenceCurrencies private feeCurrencyByCurrencyBlockNumber;

    BlockNumbUintsLib.BlockNumbUints private walletLockTimeoutByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private cancelOrderChallengeTimeoutByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private settlementChallengeTimeoutByBlockNumber;

    BlockNumbUintsLib.BlockNumbUints private fraudStakeFractionByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private walletSettlementStakeFractionByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private operatorSettlementStakeFractionByBlockNumber;

    BlockNumbFiguresLib.BlockNumbFigures private operatorSettlementStakeByBlockNumber;

    uint256 public earliestSettlementBlockNumber;
    bool public earliestSettlementBlockNumberUpdateDisabled;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetOperationalModeExitEvent();
    event SetUpdateDelayBlocksEvent(uint256 fromBlockNumber, uint256 newBlocks);
    event SetConfirmationBlocksEvent(uint256 fromBlockNumber, uint256 newBlocks);
    event SetTradeMakerFeeEvent(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues);
    event SetTradeTakerFeeEvent(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues);
    event SetPaymentFeeEvent(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues);
    event SetCurrencyPaymentFeeEvent(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal,
        int256[] discountTiers, int256[] discountValues);
    event SetTradeMakerMinimumFeeEvent(uint256 fromBlockNumber, int256 nominal);
    event SetTradeTakerMinimumFeeEvent(uint256 fromBlockNumber, int256 nominal);
    event SetPaymentMinimumFeeEvent(uint256 fromBlockNumber, int256 nominal);
    event SetCurrencyPaymentMinimumFeeEvent(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal);
    event SetFeeCurrencyEvent(uint256 fromBlockNumber, address referenceCurrencyCt, uint256 referenceCurrencyId,
        address feeCurrencyCt, uint256 feeCurrencyId);
    event SetWalletLockTimeoutEvent(uint256 fromBlockNumber, uint256 timeoutInSeconds);
    event SetCancelOrderChallengeTimeoutEvent(uint256 fromBlockNumber, uint256 timeoutInSeconds);
    event SetSettlementChallengeTimeoutEvent(uint256 fromBlockNumber, uint256 timeoutInSeconds);
    event SetWalletSettlementStakeFractionEvent(uint256 fromBlockNumber, uint256 stakeFraction);
    event SetOperatorSettlementStakeFractionEvent(uint256 fromBlockNumber, uint256 stakeFraction);
    event SetOperatorSettlementStakeEvent(uint256 fromBlockNumber, int256 stakeAmount, address stakeCurrencyCt,
        uint256 stakeCurrencyId);
    event SetFraudStakeFractionEvent(uint256 fromBlockNumber, uint256 stakeFraction);
    event SetEarliestSettlementBlockNumberEvent(uint256 earliestSettlementBlockNumber);
    event DisableEarliestSettlementBlockNumberUpdateEvent();

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
        updateDelayBlocksByBlockNumber.addEntry(block.number, 0);
    }

    //
    // Public functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set operational mode to Exit
    /// @dev Once operational mode is set to Exit it may not be set back to Normal
    function setOperationalModeExit()
    public
    onlyEnabledServiceAction(OPERATIONAL_MODE_ACTION)
    {
        operationalMode = OperationalMode.Exit;
        emit SetOperationalModeExitEvent();
    }

    /// @notice Return true if operational mode is Normal
    function isOperationalModeNormal()
    public
    view
    returns (bool)
    {
        return OperationalMode.Normal == operationalMode;
    }

    /// @notice Return true if operational mode is Exit
    function isOperationalModeExit()
    public
    view
    returns (bool)
    {
        return OperationalMode.Exit == operationalMode;
    }

    /// @notice Get the current value of update delay blocks
    /// @return The value of update delay blocks
    function updateDelayBlocks()
    public
    view
    returns (uint256)
    {
        return updateDelayBlocksByBlockNumber.currentValue();
    }

    /// @notice Get the count of update delay blocks values
    /// @return The count of update delay blocks values
    function updateDelayBlocksCount()
    public
    view
    returns (uint256)
    {
        return updateDelayBlocksByBlockNumber.count();
    }

    /// @notice Set the number of update delay blocks
    /// @param fromBlockNumber Block number from which the update applies
    /// @param newUpdateDelayBlocks The new update delay blocks value
    function setUpdateDelayBlocks(uint256 fromBlockNumber, uint256 newUpdateDelayBlocks)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        updateDelayBlocksByBlockNumber.addEntry(fromBlockNumber, newUpdateDelayBlocks);
        emit SetUpdateDelayBlocksEvent(fromBlockNumber, newUpdateDelayBlocks);
    }

    /// @notice Get the current value of confirmation blocks
    /// @return The value of confirmation blocks
    function confirmationBlocks()
    public
    view
    returns (uint256)
    {
        return confirmationBlocksByBlockNumber.currentValue();
    }

    /// @notice Get the count of confirmation blocks values
    /// @return The count of confirmation blocks values
    function confirmationBlocksCount()
    public
    view
    returns (uint256)
    {
        return confirmationBlocksByBlockNumber.count();
    }

    /// @notice Set the number of confirmation blocks
    /// @param fromBlockNumber Block number from which the update applies
    /// @param newConfirmationBlocks The new confirmation blocks value
    function setConfirmationBlocks(uint256 fromBlockNumber, uint256 newConfirmationBlocks)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        confirmationBlocksByBlockNumber.addEntry(fromBlockNumber, newConfirmationBlocks);
        emit SetConfirmationBlocksEvent(fromBlockNumber, newConfirmationBlocks);
    }

    /// @notice Get number of trade maker fee block number tiers
    function tradeMakerFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeMakerFeeByBlockNumber.count();
    }

    /// @notice Get trade maker relative fee at given block number, possibly discounted by discount tier value
    /// @param blockNumber The concerned block number
    /// @param discountTier The concerned discount tier
    function tradeMakerFee(uint256 blockNumber, int256 discountTier)
    public
    view
    returns (int256)
    {
        return tradeMakerFeeByBlockNumber.discountedValueAt(blockNumber, discountTier);
    }

    /// @notice Set trade maker nominal relative fee and discount tiers and values at given block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param nominal Nominal relative fee
    /// @param nominal Discount tier levels
    /// @param nominal Discount values
    function setTradeMakerFee(uint256 fromBlockNumber, int256 nominal, int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeMakerFeeByBlockNumber.addDiscountedEntry(fromBlockNumber, nominal, discountTiers, discountValues);
        emit SetTradeMakerFeeEvent(fromBlockNumber, nominal, discountTiers, discountValues);
    }

    /// @notice Get number of trade taker fee block number tiers
    function tradeTakerFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeTakerFeeByBlockNumber.count();
    }

    /// @notice Get trade taker relative fee at given block number, possibly discounted by discount tier value
    /// @param blockNumber The concerned block number
    /// @param discountTier The concerned discount tier
    function tradeTakerFee(uint256 blockNumber, int256 discountTier)
    public
    view
    returns (int256)
    {
        return tradeTakerFeeByBlockNumber.discountedValueAt(blockNumber, discountTier);
    }

    /// @notice Set trade taker nominal relative fee and discount tiers and values at given block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param nominal Nominal relative fee
    /// @param nominal Discount tier levels
    /// @param nominal Discount values
    function setTradeTakerFee(uint256 fromBlockNumber, int256 nominal, int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeTakerFeeByBlockNumber.addDiscountedEntry(fromBlockNumber, nominal, discountTiers, discountValues);
        emit SetTradeTakerFeeEvent(fromBlockNumber, nominal, discountTiers, discountValues);
    }

    /// @notice Get number of payment fee block number tiers
    function paymentFeesCount()
    public
    view
    returns (uint256)
    {
        return paymentFeeByBlockNumber.count();
    }

    /// @notice Get payment relative fee at given block number, possibly discounted by discount tier value
    /// @param blockNumber The concerned block number
    /// @param discountTier The concerned discount tier
    function paymentFee(uint256 blockNumber, int256 discountTier)
    public
    view
    returns (int256)
    {
        return paymentFeeByBlockNumber.discountedValueAt(blockNumber, discountTier);
    }

    /// @notice Set payment nominal relative fee and discount tiers and values at given block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param nominal Nominal relative fee
    /// @param nominal Discount tier levels
    /// @param nominal Discount values
    function setPaymentFee(uint256 fromBlockNumber, int256 nominal, int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        paymentFeeByBlockNumber.addDiscountedEntry(fromBlockNumber, nominal, discountTiers, discountValues);
        emit SetPaymentFeeEvent(fromBlockNumber, nominal, discountTiers, discountValues);
    }

    /// @notice Get number of payment fee block number tiers of given currency
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function currencyPaymentFeesCount(address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return currencyPaymentFeeByBlockNumber[currencyCt][currencyId].count();
    }

    /// @notice Get payment relative fee for given currency at given block number, possibly discounted by
    /// discount tier value
    /// @param blockNumber The concerned block number
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param discountTier The concerned discount tier
    function currencyPaymentFee(uint256 blockNumber, address currencyCt, uint256 currencyId, int256 discountTier)
    public
    view
    returns (int256)
    {
        if (0 < currencyPaymentFeeByBlockNumber[currencyCt][currencyId].count())
            return currencyPaymentFeeByBlockNumber[currencyCt][currencyId].discountedValueAt(
                blockNumber, discountTier
            );
        else
            return paymentFee(blockNumber, discountTier);
    }

    /// @notice Set payment nominal relative fee and discount tiers and values for given currency at given
    /// block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param nominal Nominal relative fee
    /// @param nominal Discount tier levels
    /// @param nominal Discount values
    function setCurrencyPaymentFee(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal,
        int256[] memory discountTiers, int256[] memory discountValues)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        currencyPaymentFeeByBlockNumber[currencyCt][currencyId].addDiscountedEntry(
            fromBlockNumber, nominal, discountTiers, discountValues
        );
        emit SetCurrencyPaymentFeeEvent(
            fromBlockNumber, currencyCt, currencyId, nominal, discountTiers, discountValues
        );
    }

    /// @notice Get number of minimum trade maker fee block number tiers
    function tradeMakerMinimumFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeMakerMinimumFeeByBlockNumber.count();
    }

    /// @notice Get trade maker minimum relative fee at given block number
    /// @param blockNumber The concerned block number
    function tradeMakerMinimumFee(uint256 blockNumber)
    public
    view
    returns (int256)
    {
        return tradeMakerMinimumFeeByBlockNumber.valueAt(blockNumber);
    }

    /// @notice Set trade maker minimum relative fee at given block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param nominal Minimum relative fee
    function setTradeMakerMinimumFee(uint256 fromBlockNumber, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeMakerMinimumFeeByBlockNumber.addEntry(fromBlockNumber, nominal);
        emit SetTradeMakerMinimumFeeEvent(fromBlockNumber, nominal);
    }

    /// @notice Get number of minimum trade taker fee block number tiers
    function tradeTakerMinimumFeesCount()
    public
    view
    returns (uint256)
    {
        return tradeTakerMinimumFeeByBlockNumber.count();
    }

    /// @notice Get trade taker minimum relative fee at given block number
    /// @param blockNumber The concerned block number
    function tradeTakerMinimumFee(uint256 blockNumber)
    public
    view
    returns (int256)
    {
        return tradeTakerMinimumFeeByBlockNumber.valueAt(blockNumber);
    }

    /// @notice Set trade taker minimum relative fee at given block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param nominal Minimum relative fee
    function setTradeTakerMinimumFee(uint256 fromBlockNumber, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        tradeTakerMinimumFeeByBlockNumber.addEntry(fromBlockNumber, nominal);
        emit SetTradeTakerMinimumFeeEvent(fromBlockNumber, nominal);
    }

    /// @notice Get number of minimum payment fee block number tiers
    function paymentMinimumFeesCount()
    public
    view
    returns (uint256)
    {
        return paymentMinimumFeeByBlockNumber.count();
    }

    /// @notice Get payment minimum relative fee at given block number
    /// @param blockNumber The concerned block number
    function paymentMinimumFee(uint256 blockNumber)
    public
    view
    returns (int256)
    {
        return paymentMinimumFeeByBlockNumber.valueAt(blockNumber);
    }

    /// @notice Set payment minimum relative fee at given block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param nominal Minimum relative fee
    function setPaymentMinimumFee(uint256 fromBlockNumber, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        paymentMinimumFeeByBlockNumber.addEntry(fromBlockNumber, nominal);
        emit SetPaymentMinimumFeeEvent(fromBlockNumber, nominal);
    }

    /// @notice Get number of minimum payment fee block number tiers for given currency
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function currencyPaymentMinimumFeesCount(address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].count();
    }

    /// @notice Get payment minimum relative fee for given currency at given block number
    /// @param blockNumber The concerned block number
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function currencyPaymentMinimumFee(uint256 blockNumber, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        if (0 < currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].count())
            return currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].valueAt(blockNumber);
        else
            return paymentMinimumFee(blockNumber);
    }

    /// @notice Set payment minimum relative fee for given currency at given block number tier
    /// @param fromBlockNumber Block number from which the update applies
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param nominal Minimum relative fee
    function setCurrencyPaymentMinimumFee(uint256 fromBlockNumber, address currencyCt, uint256 currencyId, int256 nominal)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        currencyPaymentMinimumFeeByBlockNumber[currencyCt][currencyId].addEntry(fromBlockNumber, nominal);
        emit SetCurrencyPaymentMinimumFeeEvent(fromBlockNumber, currencyCt, currencyId, nominal);
    }

    /// @notice Get number of fee currencies for the given reference currency
    /// @param currencyCt The address of the concerned reference currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned reference currency (0 for ETH and ERC20)
    function feeCurrenciesCount(address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return feeCurrencyByCurrencyBlockNumber.count(MonetaryTypesLib.Currency(currencyCt, currencyId));
    }

    /// @notice Get the fee currency for the given reference currency at given block number
    /// @param blockNumber The concerned block number
    /// @param currencyCt The address of the concerned reference currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned reference currency (0 for ETH and ERC20)
    function feeCurrency(uint256 blockNumber, address currencyCt, uint256 currencyId)
    public
    view
    returns (address ct, uint256 id)
    {
        MonetaryTypesLib.Currency storage _feeCurrency = feeCurrencyByCurrencyBlockNumber.currencyAt(
            MonetaryTypesLib.Currency(currencyCt, currencyId), blockNumber
        );
        ct = _feeCurrency.ct;
        id = _feeCurrency.id;
    }

    /// @notice Set the fee currency for the given reference currency at given block number
    /// @param fromBlockNumber Block number from which the update applies
    /// @param referenceCurrencyCt The address of the concerned reference currency contract (address(0) == ETH)
    /// @param referenceCurrencyId The ID of the concerned reference currency (0 for ETH and ERC20)
    /// @param feeCurrencyCt The address of the concerned fee currency contract (address(0) == ETH)
    /// @param feeCurrencyId The ID of the concerned fee currency (0 for ETH and ERC20)
    function setFeeCurrency(uint256 fromBlockNumber, address referenceCurrencyCt, uint256 referenceCurrencyId,
        address feeCurrencyCt, uint256 feeCurrencyId)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        feeCurrencyByCurrencyBlockNumber.addEntry(
            fromBlockNumber,
            MonetaryTypesLib.Currency(referenceCurrencyCt, referenceCurrencyId),
            MonetaryTypesLib.Currency(feeCurrencyCt, feeCurrencyId)
        );
        emit SetFeeCurrencyEvent(fromBlockNumber, referenceCurrencyCt, referenceCurrencyId,
            feeCurrencyCt, feeCurrencyId);
    }

    /// @notice Get the current value of wallet lock timeout
    /// @return The value of wallet lock timeout
    function walletLockTimeout()
    public
    view
    returns (uint256)
    {
        return walletLockTimeoutByBlockNumber.currentValue();
    }

    /// @notice Set timeout of wallet lock
    /// @param fromBlockNumber Block number from which the update applies
    /// @param timeoutInSeconds Timeout duration in seconds
    function setWalletLockTimeout(uint256 fromBlockNumber, uint256 timeoutInSeconds)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        walletLockTimeoutByBlockNumber.addEntry(fromBlockNumber, timeoutInSeconds);
        emit SetWalletLockTimeoutEvent(fromBlockNumber, timeoutInSeconds);
    }

    /// @notice Get the current value of cancel order challenge timeout
    /// @return The value of cancel order challenge timeout
    function cancelOrderChallengeTimeout()
    public
    view
    returns (uint256)
    {
        return cancelOrderChallengeTimeoutByBlockNumber.currentValue();
    }

    /// @notice Set timeout of cancel order challenge
    /// @param fromBlockNumber Block number from which the update applies
    /// @param timeoutInSeconds Timeout duration in seconds
    function setCancelOrderChallengeTimeout(uint256 fromBlockNumber, uint256 timeoutInSeconds)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        cancelOrderChallengeTimeoutByBlockNumber.addEntry(fromBlockNumber, timeoutInSeconds);
        emit SetCancelOrderChallengeTimeoutEvent(fromBlockNumber, timeoutInSeconds);
    }

    /// @notice Get the current value of settlement challenge timeout
    /// @return The value of settlement challenge timeout
    function settlementChallengeTimeout()
    public
    view
    returns (uint256)
    {
        return settlementChallengeTimeoutByBlockNumber.currentValue();
    }

    /// @notice Set timeout of settlement challenges
    /// @param fromBlockNumber Block number from which the update applies
    /// @param timeoutInSeconds Timeout duration in seconds
    function setSettlementChallengeTimeout(uint256 fromBlockNumber, uint256 timeoutInSeconds)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        settlementChallengeTimeoutByBlockNumber.addEntry(fromBlockNumber, timeoutInSeconds);
        emit SetSettlementChallengeTimeoutEvent(fromBlockNumber, timeoutInSeconds);
    }

    /// @notice Get the current value of fraud stake fraction
    /// @return The value of fraud stake fraction
    function fraudStakeFraction()
    public
    view
    returns (uint256)
    {
        return fraudStakeFractionByBlockNumber.currentValue();
    }

    /// @notice Set fraction of security bond that will be gained from successfully challenging
    /// in fraud challenge
    /// @param fromBlockNumber Block number from which the update applies
    /// @param stakeFraction The fraction gained
    function setFraudStakeFraction(uint256 fromBlockNumber, uint256 stakeFraction)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        fraudStakeFractionByBlockNumber.addEntry(fromBlockNumber, stakeFraction);
        emit SetFraudStakeFractionEvent(fromBlockNumber, stakeFraction);
    }

    /// @notice Get the current value of wallet settlement stake fraction
    /// @return The value of wallet settlement stake fraction
    function walletSettlementStakeFraction()
    public
    view
    returns (uint256)
    {
        return walletSettlementStakeFractionByBlockNumber.currentValue();
    }

    /// @notice Set fraction of security bond that will be gained from successfully challenging
    /// in settlement challenge triggered by wallet
    /// @param fromBlockNumber Block number from which the update applies
    /// @param stakeFraction The fraction gained
    function setWalletSettlementStakeFraction(uint256 fromBlockNumber, uint256 stakeFraction)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        walletSettlementStakeFractionByBlockNumber.addEntry(fromBlockNumber, stakeFraction);
        emit SetWalletSettlementStakeFractionEvent(fromBlockNumber, stakeFraction);
    }

    /// @notice Get the current value of operator settlement stake fraction
    /// @return The value of operator settlement stake fraction
    function operatorSettlementStakeFraction()
    public
    view
    returns (uint256)
    {
        return operatorSettlementStakeFractionByBlockNumber.currentValue();
    }

    /// @notice Set fraction of security bond that will be gained from successfully challenging
    /// in settlement challenge triggered by operator
    /// @param fromBlockNumber Block number from which the update applies
    /// @param stakeFraction The fraction gained
    function setOperatorSettlementStakeFraction(uint256 fromBlockNumber, uint256 stakeFraction)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        operatorSettlementStakeFractionByBlockNumber.addEntry(fromBlockNumber, stakeFraction);
        emit SetOperatorSettlementStakeFractionEvent(fromBlockNumber, stakeFraction);
    }

    /// @notice Get the current value of operator settlement stake
    /// @return The value of operator settlement stake
    function operatorSettlementStake()
    public
    view
    returns (int256 amount, address currencyCt, uint256 currencyId)
    {
        MonetaryTypesLib.Figure storage stake = operatorSettlementStakeByBlockNumber.currentValue();
        amount = stake.amount;
        currencyCt = stake.currency.ct;
        currencyId = stake.currency.id;
    }

    /// @notice Set figure of security bond that will be gained from successfully challenging
    /// in settlement challenge triggered by operator
    /// @param fromBlockNumber Block number from which the update applies
    /// @param stakeAmount The amount gained
    /// @param stakeCurrencyCt The address of currency gained
    /// @param stakeCurrencyId The ID of currency gained
    function setOperatorSettlementStake(uint256 fromBlockNumber, int256 stakeAmount,
        address stakeCurrencyCt, uint256 stakeCurrencyId)
    public
    onlyOperator
    onlyDelayedBlockNumber(fromBlockNumber)
    {
        MonetaryTypesLib.Figure memory stake = MonetaryTypesLib.Figure(stakeAmount, MonetaryTypesLib.Currency(stakeCurrencyCt, stakeCurrencyId));
        operatorSettlementStakeByBlockNumber.addEntry(fromBlockNumber, stake);
        emit SetOperatorSettlementStakeEvent(fromBlockNumber, stakeAmount, stakeCurrencyCt, stakeCurrencyId);
    }

    /// @notice Set the block number of the earliest settlement initiation
    /// @param _earliestSettlementBlockNumber The block number of the earliest settlement
    function setEarliestSettlementBlockNumber(uint256 _earliestSettlementBlockNumber)
    public
    onlyOperator
    {
        require(!earliestSettlementBlockNumberUpdateDisabled, "Earliest settlement block number update disabled [Configuration.sol:715]");

        earliestSettlementBlockNumber = _earliestSettlementBlockNumber;
        emit SetEarliestSettlementBlockNumberEvent(earliestSettlementBlockNumber);
    }

    /// @notice Disable further updates to the earliest settlement block number
    /// @dev This operation can not be undone
    function disableEarliestSettlementBlockNumberUpdate()
    public
    onlyOperator
    {
        earliestSettlementBlockNumberUpdateDisabled = true;
        emit DisableEarliestSettlementBlockNumberUpdateEvent();
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier onlyDelayedBlockNumber(uint256 blockNumber) {
        require(
            0 == updateDelayBlocksByBlockNumber.count() ||
        blockNumber >= block.number + updateDelayBlocksByBlockNumber.currentValue(),
            "Block number not sufficiently delayed [Configuration.sol:735]"
        );
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Benefactor
 * @notice An ownable that has a client fund property
 */
contract Configurable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    Configuration public configuration;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetConfigurationEvent(Configuration oldConfiguration, Configuration newConfiguration);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the configuration contract
    /// @param newConfiguration The (address of) Configuration contract instance
    function setConfiguration(Configuration newConfiguration)
    public
    onlyDeployer
    notNullAddress(address(newConfiguration))
    notSameAddresses(address(newConfiguration), address(configuration))
    {
        // Set new configuration
        Configuration oldConfiguration = configuration;
        configuration = newConfiguration;

        // Emit event
        emit SetConfigurationEvent(oldConfiguration, newConfiguration);
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier configurationInitialized() {
        require(address(configuration) != address(0), "Configuration not initialized [Configurable.sol:52]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS based on Open-Zeppelin's SafeMath library
 */

/**
 * @title     SafeMathUintLib
 * @dev       Math operations with safety checks that throw on error
 */
library SafeMathUintLib {
    function mul(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    //
    //Clamping functions.
    //
    function clamp(uint256 a, uint256 min, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : ((a < min) ? min : a);
    }

    function clampMin(uint256 a, uint256 min)
    public
    pure
    returns (uint256)
    {
        return (a < min) ? min : a;
    }

    function clampMax(uint256 a, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : a;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title     NahmiiTypesLib
 * @dev       Data types of general nahmii character
 */
library NahmiiTypesLib {
    //
    // Enums
    // -----------------------------------------------------------------------------------------------------------------
    enum ChallengePhase {Dispute, Closed}

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct OriginFigure {
        uint256 originId;
        MonetaryTypesLib.Figure figure;
    }

    struct IntendedConjugateCurrency {
        MonetaryTypesLib.Currency intended;
        MonetaryTypesLib.Currency conjugate;
    }

    struct SingleFigureTotalOriginFigures {
        MonetaryTypesLib.Figure single;
        OriginFigure[] total;
    }

    struct TotalOriginFigures {
        OriginFigure[] total;
    }

    struct CurrentPreviousInt256 {
        int256 current;
        int256 previous;
    }

    struct SingleTotalInt256 {
        int256 single;
        int256 total;
    }

    struct IntendedConjugateCurrentPreviousInt256 {
        CurrentPreviousInt256 intended;
        CurrentPreviousInt256 conjugate;
    }

    struct IntendedConjugateSingleTotalInt256 {
        SingleTotalInt256 intended;
        SingleTotalInt256 conjugate;
    }

    struct WalletOperatorHashes {
        bytes32 wallet;
        bytes32 operator;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    struct Seal {
        bytes32 hash;
        Signature signature;
    }

    struct WalletOperatorSeal {
        Seal wallet;
        Seal operator;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title     PaymentTypesLib
 * @dev       Data types centered around payment
 */
library PaymentTypesLib {
    //
    // Enums
    // -----------------------------------------------------------------------------------------------------------------
    enum PaymentPartyRole {Sender, Recipient}

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct PaymentSenderParty {
        uint256 nonce;
        address wallet;

        NahmiiTypesLib.CurrentPreviousInt256 balances;

        NahmiiTypesLib.SingleFigureTotalOriginFigures fees;

        string data;
    }

    struct PaymentRecipientParty {
        uint256 nonce;
        address wallet;

        NahmiiTypesLib.CurrentPreviousInt256 balances;

        NahmiiTypesLib.TotalOriginFigures fees;
    }

    struct Operator {
        uint256 id;
        string data;
    }

    struct Payment {
        int256 amount;
        MonetaryTypesLib.Currency currency;

        PaymentSenderParty sender;
        PaymentRecipientParty recipient;

        // Positive transfer is always in direction from sender to recipient
        NahmiiTypesLib.SingleTotalInt256 transfers;

        NahmiiTypesLib.WalletOperatorSeal seals;
        uint256 blockNumber;

        Operator operator;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function PAYMENT_KIND()
    public
    pure
    returns (string memory)
    {
        return "payment";
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title PaymentHasher
 * @notice Contract that hashes types related to payment
 */
contract PaymentHasher is Ownable {
    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function hashPaymentAsWallet(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bytes32)
    {
        bytes32 amountCurrencyHash = hashPaymentAmountCurrency(payment);
        bytes32 senderHash = hashPaymentSenderPartyAsWallet(payment.sender);
        bytes32 recipientHash = hashAddress(payment.recipient.wallet);

        return keccak256(abi.encodePacked(amountCurrencyHash, senderHash, recipientHash));
    }

    function hashPaymentAsOperator(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bytes32)
    {
        bytes32 walletSignatureHash = hashSignature(payment.seals.wallet.signature);
        bytes32 senderHash = hashPaymentSenderPartyAsOperator(payment.sender);
        bytes32 recipientHash = hashPaymentRecipientPartyAsOperator(payment.recipient);
        bytes32 transfersHash = hashSingleTotalInt256(payment.transfers);
        bytes32 operatorHash = hashString(payment.operator.data);

        return keccak256(abi.encodePacked(
                walletSignatureHash, senderHash, recipientHash, transfersHash, operatorHash
            ));
    }

    function hashPaymentAmountCurrency(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                payment.amount,
                payment.currency.ct,
                payment.currency.id
            ));
    }

    function hashPaymentSenderPartyAsWallet(
        PaymentTypesLib.PaymentSenderParty memory paymentSenderParty)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                paymentSenderParty.wallet,
                paymentSenderParty.data
            ));
    }

    function hashPaymentSenderPartyAsOperator(
        PaymentTypesLib.PaymentSenderParty memory paymentSenderParty)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashUint256(paymentSenderParty.nonce);
        bytes32 balancesHash = hashCurrentPreviousInt256(paymentSenderParty.balances);
        bytes32 singleFeeHash = hashFigure(paymentSenderParty.fees.single);
        bytes32 totalFeesHash = hashOriginFigures(paymentSenderParty.fees.total);

        return keccak256(abi.encodePacked(
                rootHash, balancesHash, singleFeeHash, totalFeesHash
            ));
    }

    function hashPaymentRecipientPartyAsOperator(
        PaymentTypesLib.PaymentRecipientParty memory paymentRecipientParty)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashUint256(paymentRecipientParty.nonce);
        bytes32 balancesHash = hashCurrentPreviousInt256(paymentRecipientParty.balances);
        bytes32 totalFeesHash = hashOriginFigures(paymentRecipientParty.fees.total);

        return keccak256(abi.encodePacked(
                rootHash, balancesHash, totalFeesHash
            ));
    }

    function hashCurrentPreviousInt256(
        NahmiiTypesLib.CurrentPreviousInt256 memory currentPreviousInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                currentPreviousInt256.current,
                currentPreviousInt256.previous
            ));
    }

    function hashSingleTotalInt256(
        NahmiiTypesLib.SingleTotalInt256 memory singleTotalInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                singleTotalInt256.single,
                singleTotalInt256.total
            ));
    }

    function hashFigure(MonetaryTypesLib.Figure memory figure)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                figure.amount,
                figure.currency.ct,
                figure.currency.id
            ));
    }

    function hashOriginFigures(NahmiiTypesLib.OriginFigure[] memory originFigures)
    public
    pure
    returns (bytes32)
    {
        bytes32 hash;
        for (uint256 i = 0; i < originFigures.length; i++) {
            hash = keccak256(abi.encodePacked(
                    hash,
                    originFigures[i].originId,
                    originFigures[i].figure.amount,
                    originFigures[i].figure.currency.ct,
                    originFigures[i].figure.currency.id
                )
            );
        }
        return hash;
    }

    function hashUint256(uint256 _uint256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_uint256));
    }

    function hashString(string memory _string)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_string));
    }

    function hashAddress(address _address)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_address));
    }

    function hashSignature(NahmiiTypesLib.Signature memory signature)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                signature.v,
                signature.r,
                signature.s
            ));
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title PaymentHashable
 * @notice An ownable that has a payment hasher property
 */
contract PaymentHashable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    PaymentHasher public paymentHasher;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetPaymentHasherEvent(PaymentHasher oldPaymentHasher, PaymentHasher newPaymentHasher);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the payment hasher contract
    /// @param newPaymentHasher The (address of) PaymentHasher contract instance
    function setPaymentHasher(PaymentHasher newPaymentHasher)
    public
    onlyDeployer
    notNullAddress(address(newPaymentHasher))
    notSameAddresses(address(newPaymentHasher), address(paymentHasher))
    {
        // Set new payment hasher
        PaymentHasher oldPaymentHasher = paymentHasher;
        paymentHasher = newPaymentHasher;

        // Emit event
        emit SetPaymentHasherEvent(oldPaymentHasher, newPaymentHasher);
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier paymentHasherInitialized() {
        require(address(paymentHasher) != address(0), "Payment hasher not initialized [PaymentHashable.sol:52]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title SignerManager
 * @notice A contract to control who can execute some specific actions
 */
contract SignerManager is Ownable {
    using SafeMathUintLib for uint256;

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    mapping(address => uint256) public signerIndicesMap; // 1 based internally
    address[] public signers;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event RegisterSignerEvent(address signer);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
        registerSigner(deployer);
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Gauge whether an address is registered signer
    /// @param _address The concerned address
    /// @return true if address is registered signer, else false
    function isSigner(address _address)
    public
    view
    returns (bool)
    {
        return 0 < signerIndicesMap[_address];
    }

    /// @notice Get the count of registered signers
    /// @return The count of registered signers
    function signersCount()
    public
    view
    returns (uint256)
    {
        return signers.length;
    }

    /// @notice Get the 0 based index of the given address in the list of signers
    /// @param _address The concerned address
    /// @return The index of the signer address
    function signerIndex(address _address)
    public
    view
    returns (uint256)
    {
        require(isSigner(_address), "Address not signer [SignerManager.sol:71]");
        return signerIndicesMap[_address] - 1;
    }

    /// @notice Registers a signer
    /// @param newSigner The address of the signer to register
    function registerSigner(address newSigner)
    public
    onlyOperator
    notNullOrThisAddress(newSigner)
    {
        if (0 == signerIndicesMap[newSigner]) {
            // Set new operator
            signers.push(newSigner);
            signerIndicesMap[newSigner] = signers.length;

            // Emit event
            emit RegisterSignerEvent(newSigner);
        }
    }

    /// @notice Get the subset of registered signers in the given 0 based index range
    /// @param low The lower inclusive index
    /// @param up The upper inclusive index
    /// @return The subset of registered signers
    function signersByIndices(uint256 low, uint256 up)
    public
    view
    returns (address[] memory)
    {
        require(0 < signers.length, "No signers found [SignerManager.sol:101]");
        require(low <= up, "Bounds parameters mismatch [SignerManager.sol:102]");

        up = up.clampMax(signers.length - 1);
        address[] memory _signers = new address[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _signers[i - low] = signers[i];

        return _signers;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title SignerManageable
 * @notice A contract to interface ACL
 */
contract SignerManageable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    SignerManager public signerManager;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetSignerManagerEvent(address oldSignerManager, address newSignerManager);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address manager) public notNullAddress(manager) {
        signerManager = SignerManager(manager);
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the signer manager of this contract
    /// @param newSignerManager The address of the new signer
    function setSignerManager(address newSignerManager)
    public
    onlyDeployer
    notNullOrThisAddress(newSignerManager)
    {
        if (newSignerManager != address(signerManager)) {
            //set new signer
            address oldSignerManager = address(signerManager);
            signerManager = SignerManager(newSignerManager);

            // Emit event
            emit SetSignerManagerEvent(oldSignerManager, newSignerManager);
        }
    }

    /// @notice Prefix input hash and do ecrecover on prefixed hash
    /// @param hash The hash message that was signed
    /// @param v The v property of the ECDSA signature
    /// @param r The r property of the ECDSA signature
    /// @param s The s property of the ECDSA signature
    /// @return The address recovered
    function ethrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
    public
    pure
    returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s);
    }

    /// @notice Gauge whether a signature of a hash has been signed by a registered signer
    /// @param hash The hash message that was signed
    /// @param v The v property of the ECDSA signature
    /// @param r The r property of the ECDSA signature
    /// @param s The s property of the ECDSA signature
    /// @return true if the recovered signer is one of the registered signers, else false
    function isSignedByRegisteredSigner(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
    public
    view
    returns (bool)
    {
        return signerManager.isSigner(ethrecover(hash, v, r, s));
    }

    /// @notice Gauge whether a signature of a hash has been signed by the claimed signer
    /// @param hash The hash message that was signed
    /// @param v The v property of the ECDSA signature
    /// @param r The r property of the ECDSA signature
    /// @param s The s property of the ECDSA signature
    /// @param signer The claimed signer
    /// @return true if the recovered signer equals the input signer, else false
    function isSignedBy(bytes32 hash, uint8 v, bytes32 r, bytes32 s, address signer)
    public
    pure
    returns (bool)
    {
        return signer == ethrecover(hash, v, r, s);
    }

    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier signerManagerInitialized() {
        require(address(signerManager) != address(0), "Signer manager not initialized [SignerManageable.sol:105]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Validator
 * @notice An ownable that validates valuable types (e.g. payment)
 */
contract Validator is Ownable, SignerManageable, Configurable, PaymentHashable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer, address signerManager) Ownable(deployer) SignerManageable(signerManager) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function isGenuineOperatorSignature(bytes32 hash, NahmiiTypesLib.Signature memory signature)
    public
    view
    returns (bool)
    {
        return isSignedByRegisteredSigner(hash, signature.v, signature.r, signature.s);
    }

    function isGenuineWalletSignature(bytes32 hash, NahmiiTypesLib.Signature memory signature, address wallet)
    public
    pure
    returns (bool)
    {
        return isSignedBy(hash, signature.v, signature.r, signature.s, wallet);
    }

    function isGenuinePaymentWalletHash(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return paymentHasher.hashPaymentAsWallet(payment) == payment.seals.wallet.hash;
    }

    function isGenuinePaymentOperatorHash(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return paymentHasher.hashPaymentAsOperator(payment) == payment.seals.operator.hash;
    }

    function isGenuinePaymentWalletSeal(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return isGenuinePaymentWalletHash(payment)
        && isGenuineWalletSignature(payment.seals.wallet.hash, payment.seals.wallet.signature, payment.sender.wallet);
    }

    function isGenuinePaymentOperatorSeal(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return isGenuinePaymentOperatorHash(payment)
        && isGenuineOperatorSignature(payment.seals.operator.hash, payment.seals.operator.signature);
    }

    function isGenuinePaymentSeals(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return isGenuinePaymentWalletSeal(payment) && isGenuinePaymentOperatorSeal(payment);
    }

    /// @dev Logics of this function only applies to FT
    function isGenuinePaymentFeeOfFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        int256 feePartsPer = int256(ConstantsLib.PARTS_PER());

        int256 feeAmount = payment.amount
        .mul(
            configuration.currencyPaymentFee(
                payment.blockNumber, payment.currency.ct, payment.currency.id, payment.amount
            )
        ).div(feePartsPer);

        if (1 > feeAmount)
            feeAmount = 1;

        return (payment.sender.fees.single.amount == feeAmount);
    }

    /// @dev Logics of this function only applies to NFT
    function isGenuinePaymentFeeOfNonFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        (address feeCurrencyCt, uint256 feeCurrencyId) = configuration.feeCurrency(
            payment.blockNumber, payment.currency.ct, payment.currency.id
        );

        return feeCurrencyCt == payment.sender.fees.single.currency.ct
        && feeCurrencyId == payment.sender.fees.single.currency.id;
    }

    /// @dev Logics of this function only applies to FT
    function isGenuinePaymentSenderOfFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet)
        && (!signerManager.isSigner(payment.sender.wallet))
        && (payment.sender.balances.current == payment.sender.balances.previous.sub(payment.transfers.single).sub(payment.sender.fees.single.amount));
    }

    /// @dev Logics of this function only applies to FT
    function isGenuinePaymentRecipientOfFungible(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet)
        && (payment.recipient.balances.current == payment.recipient.balances.previous.add(payment.transfers.single));
    }

    /// @dev Logics of this function only applies to NFT
    function isGenuinePaymentSenderOfNonFungible(PaymentTypesLib.Payment memory payment)
    public
    view
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet)
        && (!signerManager.isSigner(payment.sender.wallet));
    }

    /// @dev Logics of this function only applies to NFT
    function isGenuinePaymentRecipientOfNonFungible(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bool)
    {
        return (payment.sender.wallet != payment.recipient.wallet);
    }

    function isSuccessivePaymentsPartyNonces(
        PaymentTypesLib.Payment memory firstPayment,
        PaymentTypesLib.PaymentPartyRole firstPaymentPartyRole,
        PaymentTypesLib.Payment memory lastPayment,
        PaymentTypesLib.PaymentPartyRole lastPaymentPartyRole
    )
    public
    pure
    returns (bool)
    {
        uint256 firstNonce = (PaymentTypesLib.PaymentPartyRole.Sender == firstPaymentPartyRole ? firstPayment.sender.nonce : firstPayment.recipient.nonce);
        uint256 lastNonce = (PaymentTypesLib.PaymentPartyRole.Sender == lastPaymentPartyRole ? lastPayment.sender.nonce : lastPayment.recipient.nonce);
        return lastNonce == firstNonce.add(1);
    }

    function isGenuineSuccessivePaymentsBalances(
        PaymentTypesLib.Payment memory firstPayment,
        PaymentTypesLib.PaymentPartyRole firstPaymentPartyRole,
        PaymentTypesLib.Payment memory lastPayment,
        PaymentTypesLib.PaymentPartyRole lastPaymentPartyRole,
        int256 delta
    )
    public
    pure
    returns (bool)
    {
        NahmiiTypesLib.CurrentPreviousInt256 memory firstCurrentPreviousBalances = (PaymentTypesLib.PaymentPartyRole.Sender == firstPaymentPartyRole ? firstPayment.sender.balances : firstPayment.recipient.balances);
        NahmiiTypesLib.CurrentPreviousInt256 memory lastCurrentPreviousBalances = (PaymentTypesLib.PaymentPartyRole.Sender == lastPaymentPartyRole ? lastPayment.sender.balances : lastPayment.recipient.balances);

        return lastCurrentPreviousBalances.previous == firstCurrentPreviousBalances.current.add(delta);
    }

    function isGenuineSuccessivePaymentsTotalFees(
        PaymentTypesLib.Payment memory firstPayment,
        PaymentTypesLib.Payment memory lastPayment
    )
    public
    pure
    returns (bool)
    {
        MonetaryTypesLib.Figure memory firstTotalFee = getProtocolFigureByCurrency(firstPayment.sender.fees.total, lastPayment.sender.fees.single.currency);
        MonetaryTypesLib.Figure memory lastTotalFee = getProtocolFigureByCurrency(lastPayment.sender.fees.total, lastPayment.sender.fees.single.currency);
        return lastTotalFee.amount == firstTotalFee.amount.add(lastPayment.sender.fees.single.amount);
    }

    function isPaymentParty(PaymentTypesLib.Payment memory payment, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == payment.sender.wallet || wallet == payment.recipient.wallet;
    }

    function isPaymentSender(PaymentTypesLib.Payment memory payment, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == payment.sender.wallet;
    }

    function isPaymentRecipient(PaymentTypesLib.Payment memory payment, address wallet)
    public
    pure
    returns (bool)
    {
        return wallet == payment.recipient.wallet;
    }

    function isPaymentCurrency(PaymentTypesLib.Payment memory payment, MonetaryTypesLib.Currency memory currency)
    public
    pure
    returns (bool)
    {
        return currency.ct == payment.currency.ct && currency.id == payment.currency.id;
    }

    function isPaymentCurrencyNonFungible(PaymentTypesLib.Payment memory payment)
    public
    pure
    returns (bool)
    {
        return payment.currency.ct != payment.sender.fees.single.currency.ct
        || payment.currency.id != payment.sender.fees.single.currency.id;
    }

    //
    // Private unctions
    // -----------------------------------------------------------------------------------------------------------------
    function getProtocolFigureByCurrency(NahmiiTypesLib.OriginFigure[] memory originFigures, MonetaryTypesLib.Currency memory currency)
    private
    pure
    returns (MonetaryTypesLib.Figure memory) {
        for (uint256 i = 0; i < originFigures.length; i++)
            if (originFigures[i].figure.currency.ct == currency.ct && originFigures[i].figure.currency.id == currency.id
            && originFigures[i].originId == 0)
                return originFigures[i].figure;
        return MonetaryTypesLib.Figure(0, currency);
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title     TradeTypesLib
 * @dev       Data types centered around trade
 */
library TradeTypesLib {
    //
    // Enums
    // -----------------------------------------------------------------------------------------------------------------
    enum CurrencyRole {Intended, Conjugate}
    enum LiquidityRole {Maker, Taker}
    enum Intention {Buy, Sell}
    enum TradePartyRole {Buyer, Seller}

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct OrderPlacement {
        Intention intention;

        int256 amount;
        NahmiiTypesLib.IntendedConjugateCurrency currencies;
        int256 rate;

        NahmiiTypesLib.CurrentPreviousInt256 residuals;
    }

    struct Order {
        uint256 nonce;
        address wallet;

        OrderPlacement placement;

        NahmiiTypesLib.WalletOperatorSeal seals;
        uint256 blockNumber;
        uint256 operatorId;
    }

    struct TradeOrder {
        int256 amount;
        NahmiiTypesLib.WalletOperatorHashes hashes;
        NahmiiTypesLib.CurrentPreviousInt256 residuals;
    }

    struct TradeParty {
        uint256 nonce;
        address wallet;

        uint256 rollingVolume;

        LiquidityRole liquidityRole;

        TradeOrder order;

        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 balances;

        NahmiiTypesLib.SingleFigureTotalOriginFigures fees;
    }

    struct Trade {
        uint256 nonce;

        int256 amount;
        NahmiiTypesLib.IntendedConjugateCurrency currencies;
        int256 rate;

        TradeParty buyer;
        TradeParty seller;

        // Positive intended transfer is always in direction from seller to buyer
        // Positive conjugate transfer is always in direction from buyer to seller
        NahmiiTypesLib.IntendedConjugateSingleTotalInt256 transfers;

        NahmiiTypesLib.Seal seal;
        uint256 blockNumber;
        uint256 operatorId;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function TRADE_KIND()
    public
    pure
    returns (string memory)
    {
        return "trade";
    }

    function ORDER_KIND()
    public
    pure
    returns (string memory)
    {
        return "order";
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Validatable
 * @notice An ownable that has a validator property
 */
contract Validatable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    Validator public validator;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetValidatorEvent(Validator oldValidator, Validator newValidator);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the validator contract
    /// @param newValidator The (address of) Validator contract instance
    function setValidator(Validator newValidator)
    public
    onlyDeployer
    notNullAddress(address(newValidator))
    notSameAddresses(address(newValidator), address(validator))
    {
        //set new validator
        Validator oldValidator = validator;
        validator = newValidator;

        // Emit event
        emit SetValidatorEvent(oldValidator, newValidator);
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier validatorInitialized() {
        require(address(validator) != address(0), "Validator not initialized [Validatable.sol:55]");
        _;
    }

    modifier onlyOperatorSealedPayment(PaymentTypesLib.Payment memory payment) {
        require(validator.isGenuinePaymentOperatorSeal(payment), "Payment operator seal not genuine [Validatable.sol:60]");
        _;
    }

    modifier onlySealedPayment(PaymentTypesLib.Payment memory payment) {
        require(validator.isGenuinePaymentSeals(payment), "Payment seals not genuine [Validatable.sol:65]");
        _;
    }

    modifier onlyPaymentParty(PaymentTypesLib.Payment memory payment, address wallet) {
        require(validator.isPaymentParty(payment, wallet), "Wallet not payment party [Validatable.sol:70]");
        _;
    }

    modifier onlyPaymentSender(PaymentTypesLib.Payment memory payment, address wallet) {
        require(validator.isPaymentSender(payment, wallet), "Wallet not payment sender [Validatable.sol:75]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Beneficiary
 * @notice A recipient of ethers and tokens
 */
contract Beneficiary {
    /// @notice Receive ethers to the given wallet's given balance type
    /// @param wallet The address of the concerned wallet
    /// @param balanceType The target balance type of the wallet
    function receiveEthersTo(address wallet, string memory balanceType)
    public
    payable;

    /// @notice Receive token to the given wallet's given balance type
    /// @dev The wallet must approve of the token transfer prior to calling this function
    /// @param wallet The address of the concerned wallet
    /// @param balanceType The target balance type of the wallet
    /// @param amount The amount to deposit
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function receiveTokensTo(address wallet, string memory balanceType, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public;
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Benefactor
 * @notice An ownable that contains registered beneficiaries
 */
contract Benefactor is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    Beneficiary[] public beneficiaries;
    mapping(address => uint256) public beneficiaryIndexByAddress;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event RegisterBeneficiaryEvent(Beneficiary beneficiary);
    event DeregisterBeneficiaryEvent(Beneficiary beneficiary);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Register the given beneficiary
    /// @param beneficiary Address of beneficiary to be registered
    function registerBeneficiary(Beneficiary beneficiary)
    public
    onlyDeployer
    notNullAddress(address(beneficiary))
    returns (bool)
    {
        address _beneficiary = address(beneficiary);

        if (beneficiaryIndexByAddress[_beneficiary] > 0)
            return false;

        beneficiaries.push(beneficiary);
        beneficiaryIndexByAddress[_beneficiary] = beneficiaries.length;

        // Emit event
        emit RegisterBeneficiaryEvent(beneficiary);

        return true;
    }

    /// @notice Deregister the given beneficiary
    /// @param beneficiary Address of beneficiary to be deregistered
    function deregisterBeneficiary(Beneficiary beneficiary)
    public
    onlyDeployer
    notNullAddress(address(beneficiary))
    returns (bool)
    {
        address _beneficiary = address(beneficiary);

        if (beneficiaryIndexByAddress[_beneficiary] == 0)
            return false;

        uint256 idx = beneficiaryIndexByAddress[_beneficiary] - 1;
        if (idx < beneficiaries.length - 1) {
            // Remap the last item in the array to this index
            beneficiaries[idx] = beneficiaries[beneficiaries.length - 1];
            beneficiaryIndexByAddress[address(beneficiaries[idx])] = idx + 1;
        }
        beneficiaries.length--;
        beneficiaryIndexByAddress[_beneficiary] = 0;

        // Emit event
        emit DeregisterBeneficiaryEvent(beneficiary);

        return true;
    }

    /// @notice Gauge whether the given address is the one of a registered beneficiary
    /// @param beneficiary Address of beneficiary
    /// @return true if beneficiary is registered, else false
    function isRegisteredBeneficiary(Beneficiary beneficiary)
    public
    view
    returns (bool)
    {
        return beneficiaryIndexByAddress[address(beneficiary)] > 0;
    }

    /// @notice Get the count of registered beneficiaries
    /// @return The count of registered beneficiaries
    function registeredBeneficiariesCount()
    public
    view
    returns (uint256)
    {
        return beneficiaries.length;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title AuthorizableServable
 * @notice A servable that may be authorized and unauthorized
 */
contract AuthorizableServable is Servable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    bool public initialServiceAuthorizationDisabled;

    mapping(address => bool) public initialServiceAuthorizedMap;
    mapping(address => mapping(address => bool)) public initialServiceWalletUnauthorizedMap;

    mapping(address => mapping(address => bool)) public serviceWalletAuthorizedMap;

    mapping(address => mapping(bytes32 => mapping(address => bool))) public serviceActionWalletAuthorizedMap;
    mapping(address => mapping(bytes32 => mapping(address => bool))) public serviceActionWalletTouchedMap;
    mapping(address => mapping(address => bytes32[])) public serviceWalletActionList;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event AuthorizeInitialServiceEvent(address wallet, address service);
    event AuthorizeRegisteredServiceEvent(address wallet, address service);
    event AuthorizeRegisteredServiceActionEvent(address wallet, address service, string action);
    event UnauthorizeRegisteredServiceEvent(address wallet, address service);
    event UnauthorizeRegisteredServiceActionEvent(address wallet, address service, string action);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Add service to initial whitelist of services
    /// @dev The service must be registered already
    /// @param service The address of the concerned registered service
    function authorizeInitialService(address service)
    public
    onlyDeployer
    notNullOrThisAddress(service)
    {
        require(!initialServiceAuthorizationDisabled);
        require(msg.sender != service);

        // Ensure service is registered
        require(registeredServicesMap[service].registered);

        // Enable all actions for given wallet
        initialServiceAuthorizedMap[service] = true;

        // Emit event
        emit AuthorizeInitialServiceEvent(msg.sender, service);
    }

    /// @notice Disable further initial authorization of services
    /// @dev This operation can not be undone
    function disableInitialServiceAuthorization()
    public
    onlyDeployer
    {
        initialServiceAuthorizationDisabled = true;
    }

    /// @notice Authorize the given registered service by enabling all of actions
    /// @dev The service must be registered already
    /// @param service The address of the concerned registered service
    function authorizeRegisteredService(address service)
    public
    notNullOrThisAddress(service)
    {
        require(msg.sender != service);

        // Ensure service is registered
        require(registeredServicesMap[service].registered);

        // Ensure service is not initial. Initial services are not authorized per action.
        require(!initialServiceAuthorizedMap[service]);

        // Enable all actions for given wallet
        serviceWalletAuthorizedMap[service][msg.sender] = true;

        // Emit event
        emit AuthorizeRegisteredServiceEvent(msg.sender, service);
    }

    /// @notice Unauthorize the given registered service by enabling all of actions
    /// @dev The service must be registered already
    /// @param service The address of the concerned registered service
    function unauthorizeRegisteredService(address service)
    public
    notNullOrThisAddress(service)
    {
        require(msg.sender != service);

        // Ensure service is registered
        require(registeredServicesMap[service].registered);

        // If initial service then disable it
        if (initialServiceAuthorizedMap[service])
            initialServiceWalletUnauthorizedMap[service][msg.sender] = true;

        // Else disable all actions for given wallet
        else {
            serviceWalletAuthorizedMap[service][msg.sender] = false;
            for (uint256 i = 0; i < serviceWalletActionList[service][msg.sender].length; i++)
                serviceActionWalletAuthorizedMap[service][serviceWalletActionList[service][msg.sender][i]][msg.sender] = true;
        }

        // Emit event
        emit UnauthorizeRegisteredServiceEvent(msg.sender, service);
    }

    /// @notice Gauge whether the given service is authorized for the given wallet
    /// @param service The address of the concerned registered service
    /// @param wallet The address of the concerned wallet
    /// @return true if service is authorized for the given wallet, else false
    function isAuthorizedRegisteredService(address service, address wallet)
    public
    view
    returns (bool)
    {
        return isRegisteredActiveService(service) &&
        (isInitialServiceAuthorizedForWallet(service, wallet) || serviceWalletAuthorizedMap[service][wallet]);
    }

    /// @notice Authorize the given registered service action
    /// @dev The service must be registered already
    /// @param service The address of the concerned registered service
    /// @param action The concerned service action
    function authorizeRegisteredServiceAction(address service, string memory action)
    public
    notNullOrThisAddress(service)
    {
        require(msg.sender != service);

        bytes32 actionHash = hashString(action);

        // Ensure service action is registered
        require(registeredServicesMap[service].registered && registeredServicesMap[service].actionsEnabledMap[actionHash]);

        // Ensure service is not initial
        require(!initialServiceAuthorizedMap[service]);

        // Enable service action for given wallet
        serviceWalletAuthorizedMap[service][msg.sender] = false;
        serviceActionWalletAuthorizedMap[service][actionHash][msg.sender] = true;
        if (!serviceActionWalletTouchedMap[service][actionHash][msg.sender]) {
            serviceActionWalletTouchedMap[service][actionHash][msg.sender] = true;
            serviceWalletActionList[service][msg.sender].push(actionHash);
        }

        // Emit event
        emit AuthorizeRegisteredServiceActionEvent(msg.sender, service, action);
    }

    /// @notice Unauthorize the given registered service action
    /// @dev The service must be registered already
    /// @param service The address of the concerned registered service
    /// @param action The concerned service action
    function unauthorizeRegisteredServiceAction(address service, string memory action)
    public
    notNullOrThisAddress(service)
    {
        require(msg.sender != service);

        bytes32 actionHash = hashString(action);

        // Ensure service is registered and action enabled
        require(registeredServicesMap[service].registered && registeredServicesMap[service].actionsEnabledMap[actionHash]);

        // Ensure service is not initial as it can not be unauthorized per action
        require(!initialServiceAuthorizedMap[service]);

        // Disable service action for given wallet
        serviceActionWalletAuthorizedMap[service][actionHash][msg.sender] = false;

        // Emit event
        emit UnauthorizeRegisteredServiceActionEvent(msg.sender, service, action);
    }

    /// @notice Gauge whether the given service action is authorized for the given wallet
    /// @param service The address of the concerned registered service
    /// @param action The concerned service action
    /// @param wallet The address of the concerned wallet
    /// @return true if service action is authorized for the given wallet, else false
    function isAuthorizedRegisteredServiceAction(address service, string memory action, address wallet)
    public
    view
    returns (bool)
    {
        bytes32 actionHash = hashString(action);

        return isEnabledServiceAction(service, action) &&
        (
        isInitialServiceAuthorizedForWallet(service, wallet) ||
        serviceWalletAuthorizedMap[service][wallet] ||
        serviceActionWalletAuthorizedMap[service][actionHash][wallet]
        );
    }

    function isInitialServiceAuthorizedForWallet(address service, address wallet)
    private
    view
    returns (bool)
    {
        return initialServiceAuthorizedMap[service] ? !initialServiceWalletUnauthorizedMap[service][wallet] : false;
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier onlyAuthorizedService(address wallet) {
        require(isAuthorizedRegisteredService(msg.sender, wallet));
        _;
    }

    modifier onlyAuthorizedServiceAction(string memory action, address wallet) {
        require(isAuthorizedRegisteredServiceAction(msg.sender, action, wallet));
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title TransferController
 * @notice A base contract to handle transfers of different currency types
 */
contract TransferController {
    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event CurrencyTransferred(address from, address to, uint256 value,
        address currencyCt, uint256 currencyId);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function isFungible()
    public
    view
    returns (bool);

    function standard()
    public
    view
    returns (string memory);

    /// @notice MUST be called with DELEGATECALL
    function receive(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    /// @notice MUST be called with DELEGATECALL
    function approve(address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    /// @notice MUST be called with DELEGATECALL
    function dispatch(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    //----------------------------------------

    function getReceiveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("receive(address,address,uint256,address,uint256)"));
    }

    function getApproveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("approve(address,uint256,address,uint256)"));
    }

    function getDispatchSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("dispatch(address,address,uint256,address,uint256)"));
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title TransferControllerManager
 * @notice Handles the management of transfer controllers
 */
contract TransferControllerManager is Ownable {
    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    struct CurrencyInfo {
        bytes32 standard;
        bool blacklisted;
    }

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    mapping(bytes32 => address) public registeredTransferControllers;
    mapping(address => CurrencyInfo) public registeredCurrencies;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event RegisterTransferControllerEvent(string standard, address controller);
    event ReassociateTransferControllerEvent(string oldStandard, string newStandard, address controller);

    event RegisterCurrencyEvent(address currencyCt, string standard);
    event DeregisterCurrencyEvent(address currencyCt);
    event BlacklistCurrencyEvent(address currencyCt);
    event WhitelistCurrencyEvent(address currencyCt);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function registerTransferController(string calldata standard, address controller)
    external
    onlyDeployer
    notNullAddress(controller)
    {
        require(bytes(standard).length > 0, "Empty standard not supported [TransferControllerManager.sol:58]");
        bytes32 standardHash = keccak256(abi.encodePacked(standard));

        registeredTransferControllers[standardHash] = controller;

        // Emit event
        emit RegisterTransferControllerEvent(standard, controller);
    }

    function reassociateTransferController(string calldata oldStandard, string calldata newStandard, address controller)
    external
    onlyDeployer
    notNullAddress(controller)
    {
        require(bytes(newStandard).length > 0, "Empty new standard not supported [TransferControllerManager.sol:72]");
        bytes32 oldStandardHash = keccak256(abi.encodePacked(oldStandard));
        bytes32 newStandardHash = keccak256(abi.encodePacked(newStandard));

        require(registeredTransferControllers[oldStandardHash] != address(0), "Old standard not registered [TransferControllerManager.sol:76]");
        require(registeredTransferControllers[newStandardHash] == address(0), "New standard previously registered [TransferControllerManager.sol:77]");

        registeredTransferControllers[newStandardHash] = registeredTransferControllers[oldStandardHash];
        registeredTransferControllers[oldStandardHash] = address(0);

        // Emit event
        emit ReassociateTransferControllerEvent(oldStandard, newStandard, controller);
    }

    function registerCurrency(address currencyCt, string calldata standard)
    external
    onlyOperator
    notNullAddress(currencyCt)
    {
        require(bytes(standard).length > 0, "Empty standard not supported [TransferControllerManager.sol:91]");
        bytes32 standardHash = keccak256(abi.encodePacked(standard));

        require(registeredCurrencies[currencyCt].standard == bytes32(0), "Currency previously registered [TransferControllerManager.sol:94]");

        registeredCurrencies[currencyCt].standard = standardHash;

        // Emit event
        emit RegisterCurrencyEvent(currencyCt, standard);
    }

    function deregisterCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != 0, "Currency not registered [TransferControllerManager.sol:106]");

        registeredCurrencies[currencyCt].standard = bytes32(0);
        registeredCurrencies[currencyCt].blacklisted = false;

        // Emit event
        emit DeregisterCurrencyEvent(currencyCt);
    }

    function blacklistCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != bytes32(0), "Currency not registered [TransferControllerManager.sol:119]");

        registeredCurrencies[currencyCt].blacklisted = true;

        // Emit event
        emit BlacklistCurrencyEvent(currencyCt);
    }

    function whitelistCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != bytes32(0), "Currency not registered [TransferControllerManager.sol:131]");

        registeredCurrencies[currencyCt].blacklisted = false;

        // Emit event
        emit WhitelistCurrencyEvent(currencyCt);
    }

    /**
    @notice The provided standard takes priority over assigned interface to currency
    */
    function transferController(address currencyCt, string memory standard)
    public
    view
    returns (TransferController)
    {
        if (bytes(standard).length > 0) {
            bytes32 standardHash = keccak256(abi.encodePacked(standard));

            require(registeredTransferControllers[standardHash] != address(0), "Standard not registered [TransferControllerManager.sol:150]");
            return TransferController(registeredTransferControllers[standardHash]);
        }

        require(registeredCurrencies[currencyCt].standard != bytes32(0), "Currency not registered [TransferControllerManager.sol:154]");
        require(!registeredCurrencies[currencyCt].blacklisted, "Currency blacklisted [TransferControllerManager.sol:155]");

        address controllerAddress = registeredTransferControllers[registeredCurrencies[currencyCt].standard];
        require(controllerAddress != address(0), "No matching transfer controller [TransferControllerManager.sol:158]");

        return TransferController(controllerAddress);
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title TransferControllerManageable
 * @notice An ownable with a transfer controller manager
 */
contract TransferControllerManageable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    TransferControllerManager public transferControllerManager;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetTransferControllerManagerEvent(TransferControllerManager oldTransferControllerManager,
        TransferControllerManager newTransferControllerManager);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the currency manager contract
    /// @param newTransferControllerManager The (address of) TransferControllerManager contract instance
    function setTransferControllerManager(TransferControllerManager newTransferControllerManager)
    public
    onlyDeployer
    notNullAddress(address(newTransferControllerManager))
    notSameAddresses(address(newTransferControllerManager), address(transferControllerManager))
    {
        //set new currency manager
        TransferControllerManager oldTransferControllerManager = transferControllerManager;
        transferControllerManager = newTransferControllerManager;

        // Emit event
        emit SetTransferControllerManagerEvent(oldTransferControllerManager, newTransferControllerManager);
    }

    /// @notice Get the transfer controller of the given currency contract address and standard
    function transferController(address currencyCt, string memory standard)
    internal
    view
    returns (TransferController)
    {
        return transferControllerManager.transferController(currencyCt, standard);
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier transferControllerManagerInitialized() {
        require(address(transferControllerManager) != address(0), "Transfer controller manager not initialized [TransferControllerManageable.sol:63]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library CurrenciesLib {
    using SafeMathUintLib for uint256;

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Currencies {
        MonetaryTypesLib.Currency[] currencies;
        mapping(address => mapping(uint256 => uint256)) indexByCurrency;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function add(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    {
        // Index is 1-based
        if (0 == self.indexByCurrency[currencyCt][currencyId]) {
            self.currencies.push(MonetaryTypesLib.Currency(currencyCt, currencyId));
            self.indexByCurrency[currencyCt][currencyId] = self.currencies.length;
        }
    }

    function removeByCurrency(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    {
        // Index is 1-based
        uint256 index = self.indexByCurrency[currencyCt][currencyId];
        if (0 < index)
            removeByIndex(self, index - 1);
    }

    function removeByIndex(Currencies storage self, uint256 index)
    internal
    {
        require(index < self.currencies.length, "Index out of bounds [CurrenciesLib.sol:51]");

        address currencyCt = self.currencies[index].ct;
        uint256 currencyId = self.currencies[index].id;

        if (index < self.currencies.length - 1) {
            self.currencies[index] = self.currencies[self.currencies.length - 1];
            self.indexByCurrency[self.currencies[index].ct][self.currencies[index].id] = index + 1;
        }
        self.currencies.length--;
        self.indexByCurrency[currencyCt][currencyId] = 0;
    }

    function count(Currencies storage self)
    internal
    view
    returns (uint256)
    {
        return self.currencies.length;
    }

    function has(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return 0 != self.indexByCurrency[currencyCt][currencyId];
    }

    function getByIndex(Currencies storage self, uint256 index)
    internal
    view
    returns (MonetaryTypesLib.Currency memory)
    {
        require(index < self.currencies.length, "Index out of bounds [CurrenciesLib.sol:85]");
        return self.currencies[index];
    }

    function getByIndices(Currencies storage self, uint256 low, uint256 up)
    internal
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        require(0 < self.currencies.length, "No currencies found [CurrenciesLib.sol:94]");
        require(low <= up, "Bounds parameters mismatch [CurrenciesLib.sol:95]");

        up = up.clampMax(self.currencies.length - 1);
        MonetaryTypesLib.Currency[] memory _currencies = new MonetaryTypesLib.Currency[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _currencies[i - low] = self.currencies[i];

        return _currencies;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library FungibleBalanceLib {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using CurrenciesLib for CurrenciesLib.Currencies;

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Record {
        int256 amount;
        uint256 blockNumber;
    }

    struct Balance {
        mapping(address => mapping(uint256 => int256)) amountByCurrency;
        mapping(address => mapping(uint256 => Record[])) recordsByCurrency;

        CurrenciesLib.Currencies inUseCurrencies;
        CurrenciesLib.Currencies everUsedCurrencies;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function get(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256)
    {
        return self.amountByCurrency[currencyCt][currencyId];
    }

    function getByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (int256)
    {
        (int256 amount,) = recordByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return amount;
    }

    function set(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = amount;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function add(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].add(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function sub(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].sub(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function transfer(Balance storage _from, Balance storage _to, int256 amount,
        address currencyCt, uint256 currencyId)
    internal
    {
        sub(_from, amount, currencyCt, currencyId);
        add(_to, amount, currencyCt, currencyId);
    }

    function add_nn(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].add_nn(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function sub_nn(Balance storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        self.amountByCurrency[currencyCt][currencyId] = self.amountByCurrency[currencyCt][currencyId].sub_nn(amount);

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.amountByCurrency[currencyCt][currencyId], block.number)
        );

        updateCurrencies(self, currencyCt, currencyId);
    }

    function transfer_nn(Balance storage _from, Balance storage _to, int256 amount,
        address currencyCt, uint256 currencyId)
    internal
    {
        sub_nn(_from, amount, currencyCt, currencyId);
        add_nn(_to, amount, currencyCt, currencyId);
    }

    function recordsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.recordsByCurrency[currencyCt][currencyId].length;
    }

    function recordByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (int256, uint256)
    {
        uint256 index = indexByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return 0 < index ? recordByIndex(self, currencyCt, currencyId, index - 1) : (0, 0);
    }

    function recordByIndex(Balance storage self, address currencyCt, uint256 currencyId, uint256 index)
    internal
    view
    returns (int256, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (0, 0);

        index = index.clampMax(self.recordsByCurrency[currencyCt][currencyId].length - 1);
        Record storage record = self.recordsByCurrency[currencyCt][currencyId][index];
        return (record.amount, record.blockNumber);
    }

    function lastRecord(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (0, 0);

        Record storage record = self.recordsByCurrency[currencyCt][currencyId][self.recordsByCurrency[currencyCt][currencyId].length - 1];
        return (record.amount, record.blockNumber);
    }

    function hasInUseCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.inUseCurrencies.has(currencyCt, currencyId);
    }

    function hasEverUsedCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.everUsedCurrencies.has(currencyCt, currencyId);
    }

    function updateCurrencies(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        if (0 == self.amountByCurrency[currencyCt][currencyId] && self.inUseCurrencies.has(currencyCt, currencyId))
            self.inUseCurrencies.removeByCurrency(currencyCt, currencyId);
        else if (!self.inUseCurrencies.has(currencyCt, currencyId)) {
            self.inUseCurrencies.add(currencyCt, currencyId);
            self.everUsedCurrencies.add(currencyCt, currencyId);
        }
    }

    function indexByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return 0;
        for (uint256 i = self.recordsByCurrency[currencyCt][currencyId].length; i > 0; i--)
            if (self.recordsByCurrency[currencyCt][currencyId][i - 1].blockNumber <= blockNumber)
                return i;
        return 0;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library NonFungibleBalanceLib {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using CurrenciesLib for CurrenciesLib.Currencies;

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Record {
        int256[] ids;
        uint256 blockNumber;
    }

    struct Balance {
        mapping(address => mapping(uint256 => int256[])) idsByCurrency;
        mapping(address => mapping(uint256 => mapping(int256 => uint256))) idIndexById;
        mapping(address => mapping(uint256 => Record[])) recordsByCurrency;

        CurrenciesLib.Currencies inUseCurrencies;
        CurrenciesLib.Currencies everUsedCurrencies;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function get(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256[] memory)
    {
        return self.idsByCurrency[currencyCt][currencyId];
    }

    function getByIndices(Balance storage self, address currencyCt, uint256 currencyId, uint256 indexLow, uint256 indexUp)
    internal
    view
    returns (int256[] memory)
    {
        if (0 == self.idsByCurrency[currencyCt][currencyId].length)
            return new int256[](0);

        indexUp = indexUp.clampMax(self.idsByCurrency[currencyCt][currencyId].length - 1);

        int256[] memory idsByCurrency = new int256[](indexUp - indexLow + 1);
        for (uint256 i = indexLow; i < indexUp; i++)
            idsByCurrency[i - indexLow] = self.idsByCurrency[currencyCt][currencyId][i];

        return idsByCurrency;
    }

    function idsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.idsByCurrency[currencyCt][currencyId].length;
    }

    function hasId(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return 0 < self.idIndexById[currencyCt][currencyId][id];
    }

    function recordByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (int256[] memory, uint256)
    {
        uint256 index = indexByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return 0 < index ? recordByIndex(self, currencyCt, currencyId, index - 1) : (new int256[](0), 0);
    }

    function recordByIndex(Balance storage self, address currencyCt, uint256 currencyId, uint256 index)
    internal
    view
    returns (int256[] memory, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (new int256[](0), 0);

        index = index.clampMax(self.recordsByCurrency[currencyCt][currencyId].length - 1);
        Record storage record = self.recordsByCurrency[currencyCt][currencyId][index];
        return (record.ids, record.blockNumber);
    }

    function lastRecord(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256[] memory, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (new int256[](0), 0);

        Record storage record = self.recordsByCurrency[currencyCt][currencyId][self.recordsByCurrency[currencyCt][currencyId].length - 1];
        return (record.ids, record.blockNumber);
    }

    function recordsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.recordsByCurrency[currencyCt][currencyId].length;
    }

    function set(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    {
        int256[] memory ids = new int256[](1);
        ids[0] = id;
        set(self, ids, currencyCt, currencyId);
    }

    function set(Balance storage self, int256[] memory ids, address currencyCt, uint256 currencyId)
    internal
    {
        uint256 i;
        for (i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = 0;

        self.idsByCurrency[currencyCt][currencyId] = ids;

        for (i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = i + 1;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);
    }

    function reset(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        for (uint256 i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = 0;

        self.idsByCurrency[currencyCt][currencyId].length = 0;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);
    }

    function add(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        if (0 < self.idIndexById[currencyCt][currencyId][id])
            return false;

        self.idsByCurrency[currencyCt][currencyId].push(id);

        self.idIndexById[currencyCt][currencyId][id] = self.idsByCurrency[currencyCt][currencyId].length;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);

        return true;
    }

    function sub(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        uint256 index = self.idIndexById[currencyCt][currencyId][id];

        if (0 == index)
            return false;

        if (index < self.idsByCurrency[currencyCt][currencyId].length) {
            self.idsByCurrency[currencyCt][currencyId][index - 1] = self.idsByCurrency[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId].length - 1];
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][index - 1]] = index;
        }
        self.idsByCurrency[currencyCt][currencyId].length--;
        self.idIndexById[currencyCt][currencyId][id] = 0;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);

        return true;
    }

    function transfer(Balance storage _from, Balance storage _to, int256 id,
        address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        return sub(_from, id, currencyCt, currencyId) && add(_to, id, currencyCt, currencyId);
    }

    function hasInUseCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.inUseCurrencies.has(currencyCt, currencyId);
    }

    function hasEverUsedCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.everUsedCurrencies.has(currencyCt, currencyId);
    }

    function updateInUseCurrencies(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        if (0 == self.idsByCurrency[currencyCt][currencyId].length && self.inUseCurrencies.has(currencyCt, currencyId))
            self.inUseCurrencies.removeByCurrency(currencyCt, currencyId);
        else if (!self.inUseCurrencies.has(currencyCt, currencyId)) {
            self.inUseCurrencies.add(currencyCt, currencyId);
            self.everUsedCurrencies.add(currencyCt, currencyId);
        }
    }

    function indexByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return 0;
        for (uint256 i = self.recordsByCurrency[currencyCt][currencyId].length; i > 0; i--)
            if (self.recordsByCurrency[currencyCt][currencyId][i - 1].blockNumber <= blockNumber)
                return i;
        return 0;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Balance tracker
 * @notice An ownable to track balances of generic types
 */
contract BalanceTracker is Ownable, Servable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using FungibleBalanceLib for FungibleBalanceLib.Balance;
    using NonFungibleBalanceLib for NonFungibleBalanceLib.Balance;

    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    string constant public DEPOSITED_BALANCE_TYPE = "deposited";
    string constant public SETTLED_BALANCE_TYPE = "settled";
    string constant public STAGED_BALANCE_TYPE = "staged";

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Wallet {
        mapping(bytes32 => FungibleBalanceLib.Balance) fungibleBalanceByType;
        mapping(bytes32 => NonFungibleBalanceLib.Balance) nonFungibleBalanceByType;
    }

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    bytes32 public depositedBalanceType;
    bytes32 public settledBalanceType;
    bytes32 public stagedBalanceType;

    bytes32[] public _allBalanceTypes;
    bytes32[] public _activeBalanceTypes;

    bytes32[] public trackedBalanceTypes;
    mapping(bytes32 => bool) public trackedBalanceTypeMap;

    mapping(address => Wallet) private walletMap;

    address[] public trackedWallets;
    mapping(address => uint256) public trackedWalletIndexByWallet;

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer)
    public
    {
        depositedBalanceType = keccak256(abi.encodePacked(DEPOSITED_BALANCE_TYPE));
        settledBalanceType = keccak256(abi.encodePacked(SETTLED_BALANCE_TYPE));
        stagedBalanceType = keccak256(abi.encodePacked(STAGED_BALANCE_TYPE));

        _allBalanceTypes.push(settledBalanceType);
        _allBalanceTypes.push(depositedBalanceType);
        _allBalanceTypes.push(stagedBalanceType);

        _activeBalanceTypes.push(settledBalanceType);
        _activeBalanceTypes.push(depositedBalanceType);
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Get the fungible balance (amount) of the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The stored balance
    function get(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].get(currencyCt, currencyId);
    }

    /// @notice Get the non-fungible balance (IDs) of the given wallet, type, currency and index range
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param indexLow The lower index of IDs
    /// @param indexUp The upper index of IDs
    /// @return The stored balance
    function getByIndices(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 indexLow, uint256 indexUp)
    public
    view
    returns (int256[] memory)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].getByIndices(
            currencyCt, currencyId, indexLow, indexUp
        );
    }

    /// @notice Get all the non-fungible balance (IDs) of the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The stored balance
    function getAll(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256[] memory)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].get(
            currencyCt, currencyId
        );
    }

    /// @notice Get the count of non-fungible IDs of the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The count of IDs
    function idsCount(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].idsCount(
            currencyCt, currencyId
        );
    }

    /// @notice Gauge whether the ID is included in the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param id The ID of the concerned unit
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return true if ID is included, else false
    function hasId(address wallet, bytes32 _type, int256 id, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].hasId(
            id, currencyCt, currencyId
        );
    }

    /// @notice Set the balance of the given wallet, type and currency to the given value
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param value The value (amount of fungible, id of non-fungible) to set
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param fungible True if setting fungible balance, else false
    function set(address wallet, bytes32 _type, int256 value, address currencyCt, uint256 currencyId, bool fungible)
    public
    onlyActiveService
    {
        // Update the balance
        if (fungible)
            walletMap[wallet].fungibleBalanceByType[_type].set(
                value, currencyCt, currencyId
            );

        else
            walletMap[wallet].nonFungibleBalanceByType[_type].set(
                value, currencyCt, currencyId
            );

        // Update balance type hashes
        _updateTrackedBalanceTypes(_type);

        // Update tracked wallets
        _updateTrackedWallets(wallet);
    }

    /// @notice Set the non-fungible balance IDs of the given wallet, type and currency to the given value
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param ids The ids of non-fungible) to set
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function setIds(address wallet, bytes32 _type, int256[] memory ids, address currencyCt, uint256 currencyId)
    public
    onlyActiveService
    {
        // Update the balance
        walletMap[wallet].nonFungibleBalanceByType[_type].set(
            ids, currencyCt, currencyId
        );

        // Update balance type hashes
        _updateTrackedBalanceTypes(_type);

        // Update tracked wallets
        _updateTrackedWallets(wallet);
    }

    /// @notice Add the given value to the balance of the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param value The value (amount of fungible, id of non-fungible) to add
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param fungible True if adding fungible balance, else false
    function add(address wallet, bytes32 _type, int256 value, address currencyCt, uint256 currencyId,
        bool fungible)
    public
    onlyActiveService
    {
        // Update the balance
        if (fungible)
            walletMap[wallet].fungibleBalanceByType[_type].add(
                value, currencyCt, currencyId
            );
        else
            walletMap[wallet].nonFungibleBalanceByType[_type].add(
                value, currencyCt, currencyId
            );

        // Update balance type hashes
        _updateTrackedBalanceTypes(_type);

        // Update tracked wallets
        _updateTrackedWallets(wallet);
    }

    /// @notice Subtract the given value from the balance of the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param value The value (amount of fungible, id of non-fungible) to subtract
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param fungible True if subtracting fungible balance, else false
    function sub(address wallet, bytes32 _type, int256 value, address currencyCt, uint256 currencyId,
        bool fungible)
    public
    onlyActiveService
    {
        // Update the balance
        if (fungible)
            walletMap[wallet].fungibleBalanceByType[_type].sub(
                value, currencyCt, currencyId
            );
        else
            walletMap[wallet].nonFungibleBalanceByType[_type].sub(
                value, currencyCt, currencyId
            );

        // Update tracked wallets
        _updateTrackedWallets(wallet);
    }

    /// @notice Gauge whether this tracker has in-use data for the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return true if data is stored, else false
    function hasInUseCurrency(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].hasInUseCurrency(currencyCt, currencyId)
        || walletMap[wallet].nonFungibleBalanceByType[_type].hasInUseCurrency(currencyCt, currencyId);
    }

    /// @notice Gauge whether this tracker has ever-used data for the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return true if data is stored, else false
    function hasEverUsedCurrency(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].hasEverUsedCurrency(currencyCt, currencyId)
        || walletMap[wallet].nonFungibleBalanceByType[_type].hasEverUsedCurrency(currencyCt, currencyId);
    }

    /// @notice Get the count of fungible balance records for the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The count of balance log entries
    function fungibleRecordsCount(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].recordsCount(currencyCt, currencyId);
    }

    /// @notice Get the fungible balance record for the given wallet, type, currency
    /// log entry index
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param index The concerned record index
    /// @return The balance record
    function fungibleRecordByIndex(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 index)
    public
    view
    returns (int256 amount, uint256 blockNumber)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].recordByIndex(currencyCt, currencyId, index);
    }

    /// @notice Get the non-fungible balance record for the given wallet, type, currency
    /// block number
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param _blockNumber The concerned block number
    /// @return The balance record
    function fungibleRecordByBlockNumber(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 _blockNumber)
    public
    view
    returns (int256 amount, uint256 blockNumber)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].recordByBlockNumber(currencyCt, currencyId, _blockNumber);
    }

    /// @notice Get the last (most recent) non-fungible balance record for the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The last log entry
    function lastFungibleRecord(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256 amount, uint256 blockNumber)
    {
        return walletMap[wallet].fungibleBalanceByType[_type].lastRecord(currencyCt, currencyId);
    }

    /// @notice Get the count of non-fungible balance records for the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The count of balance log entries
    function nonFungibleRecordsCount(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].recordsCount(currencyCt, currencyId);
    }

    /// @notice Get the non-fungible balance record for the given wallet, type, currency
    /// and record index
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param index The concerned record index
    /// @return The balance record
    function nonFungibleRecordByIndex(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 index)
    public
    view
    returns (int256[] memory ids, uint256 blockNumber)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].recordByIndex(currencyCt, currencyId, index);
    }

    /// @notice Get the non-fungible balance record for the given wallet, type, currency
    /// and block number
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param _blockNumber The concerned block number
    /// @return The balance record
    function nonFungibleRecordByBlockNumber(address wallet, bytes32 _type, address currencyCt, uint256 currencyId,
        uint256 _blockNumber)
    public
    view
    returns (int256[] memory ids, uint256 blockNumber)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].recordByBlockNumber(currencyCt, currencyId, _blockNumber);
    }

    /// @notice Get the last (most recent) non-fungible balance record for the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The last log entry
    function lastNonFungibleRecord(address wallet, bytes32 _type, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256[] memory ids, uint256 blockNumber)
    {
        return walletMap[wallet].nonFungibleBalanceByType[_type].lastRecord(currencyCt, currencyId);
    }

    /// @notice Get the count of tracked balance types
    /// @return The count of tracked balance types
    function trackedBalanceTypesCount()
    public
    view
    returns (uint256)
    {
        return trackedBalanceTypes.length;
    }

    /// @notice Get the count of tracked wallets
    /// @return The count of tracked wallets
    function trackedWalletsCount()
    public
    view
    returns (uint256)
    {
        return trackedWallets.length;
    }

    /// @notice Get the default full set of balance types
    /// @return The set of all balance types
    function allBalanceTypes()
    public
    view
    returns (bytes32[] memory)
    {
        return _allBalanceTypes;
    }

    /// @notice Get the default set of active balance types
    /// @return The set of active balance types
    function activeBalanceTypes()
    public
    view
    returns (bytes32[] memory)
    {
        return _activeBalanceTypes;
    }

    /// @notice Get the subset of tracked wallets in the given index range
    /// @param low The lower index
    /// @param up The upper index
    /// @return The subset of tracked wallets
    function trackedWalletsByIndices(uint256 low, uint256 up)
    public
    view
    returns (address[] memory)
    {
        require(0 < trackedWallets.length, "No tracked wallets found [BalanceTracker.sol:473]");
        require(low <= up, "Bounds parameters mismatch [BalanceTracker.sol:474]");

        up = up.clampMax(trackedWallets.length - 1);
        address[] memory _trackedWallets = new address[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _trackedWallets[i - low] = trackedWallets[i];

        return _trackedWallets;
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _updateTrackedBalanceTypes(bytes32 _type)
    private
    {
        if (!trackedBalanceTypeMap[_type]) {
            trackedBalanceTypeMap[_type] = true;
            trackedBalanceTypes.push(_type);
        }
    }

    function _updateTrackedWallets(address wallet)
    private
    {
        if (0 == trackedWalletIndexByWallet[wallet]) {
            trackedWallets.push(wallet);
            trackedWalletIndexByWallet[wallet] = trackedWallets.length;
        }
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title BalanceTrackable
 * @notice An ownable that has a balance tracker property
 */
contract BalanceTrackable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    BalanceTracker public balanceTracker;
    bool public balanceTrackerFrozen;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetBalanceTrackerEvent(BalanceTracker oldBalanceTracker, BalanceTracker newBalanceTracker);
    event FreezeBalanceTrackerEvent();

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the balance tracker contract
    /// @param newBalanceTracker The (address of) BalanceTracker contract instance
    function setBalanceTracker(BalanceTracker newBalanceTracker)
    public
    onlyDeployer
    notNullAddress(address(newBalanceTracker))
    notSameAddresses(address(newBalanceTracker), address(balanceTracker))
    {
        // Require that this contract has not been frozen
        require(!balanceTrackerFrozen, "Balance tracker frozen [BalanceTrackable.sol:43]");

        // Update fields
        BalanceTracker oldBalanceTracker = balanceTracker;
        balanceTracker = newBalanceTracker;

        // Emit event
        emit SetBalanceTrackerEvent(oldBalanceTracker, newBalanceTracker);
    }

    /// @notice Freeze the balance tracker from further updates
    /// @dev This operation can not be undone
    function freezeBalanceTracker()
    public
    onlyDeployer
    {
        balanceTrackerFrozen = true;

        // Emit event
        emit FreezeBalanceTrackerEvent();
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier balanceTrackerInitialized() {
        require(address(balanceTracker) != address(0), "Balance tracker not initialized [BalanceTrackable.sol:69]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Transaction tracker
 * @notice An ownable to track transactions of generic types
 */
contract TransactionTracker is Ownable, Servable {

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct TransactionRecord {
        int256 value;
        uint256 blockNumber;
        address currencyCt;
        uint256 currencyId;
    }

    struct TransactionLog {
        TransactionRecord[] records;
        mapping(address => mapping(uint256 => uint256[])) recordIndicesByCurrency;
    }

    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    string constant public DEPOSIT_TRANSACTION_TYPE = "deposit";
    string constant public WITHDRAWAL_TRANSACTION_TYPE = "withdrawal";

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    bytes32 public depositTransactionType;
    bytes32 public withdrawalTransactionType;

    mapping(address => mapping(bytes32 => TransactionLog)) private transactionLogByWalletType;

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer)
    public
    {
        depositTransactionType = keccak256(abi.encodePacked(DEPOSIT_TRANSACTION_TYPE));
        withdrawalTransactionType = keccak256(abi.encodePacked(WITHDRAWAL_TRANSACTION_TYPE));
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Add a transaction record of the given wallet, type, value and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The transaction type
    /// @param value The concerned value (amount of fungible, id of non-fungible)
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function add(address wallet, bytes32 _type, int256 value, address currencyCt,
        uint256 currencyId)
    public
    onlyActiveService
    {
        transactionLogByWalletType[wallet][_type].records.length++;

        uint256 index = transactionLogByWalletType[wallet][_type].records.length - 1;

        transactionLogByWalletType[wallet][_type].records[index].value = value;
        transactionLogByWalletType[wallet][_type].records[index].blockNumber = block.number;
        transactionLogByWalletType[wallet][_type].records[index].currencyCt = currencyCt;
        transactionLogByWalletType[wallet][_type].records[index].currencyId = currencyId;

        transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].push(index);
    }

    /// @notice Get the number of transaction records for the given wallet and type
    /// @param wallet The address of the concerned wallet
    /// @param _type The transaction type
    /// @return The count of transaction records
    function count(address wallet, bytes32 _type)
    public
    view
    returns (uint256)
    {
        return transactionLogByWalletType[wallet][_type].records.length;
    }

    /// @notice Get the transaction record for the given wallet and type by the given index
    /// @param wallet The address of the concerned wallet
    /// @param _type The transaction type
    /// @param index The concerned log index
    /// @return The transaction record
    function getByIndex(address wallet, bytes32 _type, uint256 index)
    public
    view
    returns (int256 value, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        TransactionRecord storage entry = transactionLogByWalletType[wallet][_type].records[index];
        value = entry.value;
        blockNumber = entry.blockNumber;
        currencyCt = entry.currencyCt;
        currencyId = entry.currencyId;
    }

    /// @notice Get the transaction record for the given wallet and type by the given block number
    /// @param wallet The address of the concerned wallet
    /// @param _type The transaction type
    /// @param _blockNumber The concerned block number
    /// @return The transaction record
    function getByBlockNumber(address wallet, bytes32 _type, uint256 _blockNumber)
    public
    view
    returns (int256 value, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        return getByIndex(wallet, _type, _indexByBlockNumber(wallet, _type, _blockNumber));
    }

    /// @notice Get the number of transaction records for the given wallet, type and currency
    /// @param wallet The address of the concerned wallet
    /// @param _type The transaction type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The count of transaction records
    function countByCurrency(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId)
    public
    view
    returns (uint256)
    {
        return transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].length;
    }

    /// @notice Get the transaction record for the given wallet, type and currency by the given index
    /// @param wallet The address of the concerned wallet
    /// @param _type The transaction type
    /// @param index The concerned log index
    /// @return The transaction record
    function getByCurrencyIndex(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId, uint256 index)
    public
    view
    returns (int256 value, uint256 blockNumber)
    {
        uint256 entryIndex = transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId][index];

        TransactionRecord storage entry = transactionLogByWalletType[wallet][_type].records[entryIndex];
        value = entry.value;
        blockNumber = entry.blockNumber;
    }

    /// @notice Get the transaction record for the given wallet, type and currency by the given block number
    /// @param wallet The address of the concerned wallet
    /// @param _type The transaction type
    /// @param _blockNumber The concerned block number
    /// @return The transaction record
    function getByCurrencyBlockNumber(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId, uint256 _blockNumber)
    public
    view
    returns (int256 value, uint256 blockNumber)
    {
        return getByCurrencyIndex(
            wallet, _type, currencyCt, currencyId,
            _indexByCurrencyBlockNumber(
                wallet, _type, currencyCt, currencyId, _blockNumber
            )
        );
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _indexByBlockNumber(address wallet, bytes32 _type, uint256 blockNumber)
    private
    view
    returns (uint256)
    {
        require(
            0 < transactionLogByWalletType[wallet][_type].records.length,
            "No transactions found for wallet and type [TransactionTracker.sol:187]"
        );
        for (uint256 i = transactionLogByWalletType[wallet][_type].records.length - 1; i >= 0; i--)
            if (blockNumber >= transactionLogByWalletType[wallet][_type].records[i].blockNumber)
                return i;
        revert();
    }

    function _indexByCurrencyBlockNumber(address wallet, bytes32 _type, address currencyCt,
        uint256 currencyId, uint256 blockNumber)
    private
    view
    returns (uint256)
    {
        require(
            0 < transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].length,
            "No transactions found for wallet, type and currency [TransactionTracker.sol:203]"
        );
        for (uint256 i = transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].length - 1; i >= 0; i--) {
            uint256 j = transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId][i];
            if (blockNumber >= transactionLogByWalletType[wallet][_type].records[j].blockNumber)
                return j;
        }
        revert();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title TransactionTrackable
 * @notice An ownable that has a transaction tracker property
 */
contract TransactionTrackable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    TransactionTracker public transactionTracker;
    bool public transactionTrackerFrozen;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetTransactionTrackerEvent(TransactionTracker oldTransactionTracker, TransactionTracker newTransactionTracker);
    event FreezeTransactionTrackerEvent();

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the transaction tracker contract
    /// @param newTransactionTracker The (address of) TransactionTracker contract instance
    function setTransactionTracker(TransactionTracker newTransactionTracker)
    public
    onlyDeployer
    notNullAddress(address(newTransactionTracker))
    notSameAddresses(address(newTransactionTracker), address(transactionTracker))
    {
        // Require that this contract has not been frozen
        require(!transactionTrackerFrozen, "Transaction tracker frozen [TransactionTrackable.sol:43]");

        // Update fields
        TransactionTracker oldTransactionTracker = transactionTracker;
        transactionTracker = newTransactionTracker;

        // Emit event
        emit SetTransactionTrackerEvent(oldTransactionTracker, newTransactionTracker);
    }

    /// @notice Freeze the transaction tracker from further updates
    /// @dev This operation can not be undone
    function freezeTransactionTracker()
    public
    onlyDeployer
    {
        transactionTrackerFrozen = true;

        // Emit event
        emit FreezeTransactionTrackerEvent();
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier transactionTrackerInitialized() {
        require(address(transactionTracker) != address(0), "Transaction track not initialized [TransactionTrackable.sol:69]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Wallet locker
 * @notice An ownable to lock and unlock wallets' balance holdings of specific currency(ies)
 */
contract WalletLocker is Ownable, Configurable, AuthorizableServable {
    using SafeMathUintLib for uint256;

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct FungibleLock {
        address locker;
        address currencyCt;
        uint256 currencyId;
        int256 amount;
        uint256 visibleTime;
        uint256 unlockTime;
    }

    struct NonFungibleLock {
        address locker;
        address currencyCt;
        uint256 currencyId;
        int256[] ids;
        uint256 visibleTime;
        uint256 unlockTime;
    }

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    mapping(address => FungibleLock[]) public walletFungibleLocks;
    mapping(address => mapping(address => mapping(uint256 => mapping(address => uint256)))) public lockedCurrencyLockerFungibleLockIndex;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public walletCurrencyFungibleLockCount;

    mapping(address => NonFungibleLock[]) public walletNonFungibleLocks;
    mapping(address => mapping(address => mapping(uint256 => mapping(address => uint256)))) public lockedCurrencyLockerNonFungibleLockIndex;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public walletCurrencyNonFungibleLockCount;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event LockFungibleByProxyEvent(address lockedWallet, address lockerWallet, int256 amount,
        address currencyCt, uint256 currencyId, uint256 visibleTimeoutInSeconds);
    event LockNonFungibleByProxyEvent(address lockedWallet, address lockerWallet, int256[] ids,
        address currencyCt, uint256 currencyId, uint256 visibleTimeoutInSeconds);
    event UnlockFungibleEvent(address lockedWallet, address lockerWallet, int256 amount, address currencyCt,
        uint256 currencyId);
    event UnlockFungibleByProxyEvent(address lockedWallet, address lockerWallet, int256 amount, address currencyCt,
        uint256 currencyId);
    event UnlockNonFungibleEvent(address lockedWallet, address lockerWallet, int256[] ids, address currencyCt,
        uint256 currencyId);
    event UnlockNonFungibleByProxyEvent(address lockedWallet, address lockerWallet, int256[] ids, address currencyCt,
        uint256 currencyId);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer)
    public
    {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Lock the given locked wallet's fungible amount of currency on behalf of the given locker wallet
    /// @param lockedWallet The address of wallet that will be locked
    /// @param lockerWallet The address of wallet that locks
    /// @param amount The amount to be locked
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param visibleTimeoutInSeconds The number of seconds until the locked amount is visible, a.o. for seizure
    function lockFungibleByProxy(address lockedWallet, address lockerWallet, int256 amount,
        address currencyCt, uint256 currencyId, uint256 visibleTimeoutInSeconds)
    public
    onlyAuthorizedService(lockedWallet)
    {
        // Require that locked and locker wallets are not identical
        require(lockedWallet != lockerWallet);

        // Get index of lock
        uint256 lockIndex = lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockedWallet];

        // Require that there is no existing conflicting lock
        require(
            (0 == lockIndex) ||
            (block.timestamp >= walletFungibleLocks[lockedWallet][lockIndex - 1].unlockTime)
        );

        // Add lock object for this triplet of locked wallet, currency and locker wallet if it does not exist
        if (0 == lockIndex) {
            lockIndex = ++(walletFungibleLocks[lockedWallet].length);
            lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet] = lockIndex;
            walletCurrencyFungibleLockCount[lockedWallet][currencyCt][currencyId]++;
        }

        // Update lock parameters
        walletFungibleLocks[lockedWallet][lockIndex - 1].locker = lockerWallet;
        walletFungibleLocks[lockedWallet][lockIndex - 1].amount = amount;
        walletFungibleLocks[lockedWallet][lockIndex - 1].currencyCt = currencyCt;
        walletFungibleLocks[lockedWallet][lockIndex - 1].currencyId = currencyId;
        walletFungibleLocks[lockedWallet][lockIndex - 1].visibleTime =
        block.timestamp.add(visibleTimeoutInSeconds);
        walletFungibleLocks[lockedWallet][lockIndex - 1].unlockTime =
        block.timestamp.add(configuration.walletLockTimeout());

        // Emit event
        emit LockFungibleByProxyEvent(lockedWallet, lockerWallet, amount, currencyCt, currencyId, visibleTimeoutInSeconds);
    }

    /// @notice Lock the given locked wallet's non-fungible IDs of currency on behalf of the given locker wallet
    /// @param lockedWallet The address of wallet that will be locked
    /// @param lockerWallet The address of wallet that locks
    /// @param ids The IDs to be locked
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param visibleTimeoutInSeconds The number of seconds until the locked ids are visible, a.o. for seizure
    function lockNonFungibleByProxy(address lockedWallet, address lockerWallet, int256[] memory ids,
        address currencyCt, uint256 currencyId, uint256 visibleTimeoutInSeconds)
    public
    onlyAuthorizedService(lockedWallet)
    {
        // Require that locked and locker wallets are not identical
        require(lockedWallet != lockerWallet);

        // Get index of lock
        uint256 lockIndex = lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockedWallet];

        // Require that there is no existing conflicting lock
        require(
            (0 == lockIndex) ||
            (block.timestamp >= walletNonFungibleLocks[lockedWallet][lockIndex - 1].unlockTime)
        );

        // Add lock object for this triplet of locked wallet, currency and locker wallet if it does not exist
        if (0 == lockIndex) {
            lockIndex = ++(walletNonFungibleLocks[lockedWallet].length);
            lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet] = lockIndex;
            walletCurrencyNonFungibleLockCount[lockedWallet][currencyCt][currencyId]++;
        }

        // Update lock parameters
        walletNonFungibleLocks[lockedWallet][lockIndex - 1].locker = lockerWallet;
        walletNonFungibleLocks[lockedWallet][lockIndex - 1].ids = ids;
        walletNonFungibleLocks[lockedWallet][lockIndex - 1].currencyCt = currencyCt;
        walletNonFungibleLocks[lockedWallet][lockIndex - 1].currencyId = currencyId;
        walletNonFungibleLocks[lockedWallet][lockIndex - 1].visibleTime =
        block.timestamp.add(visibleTimeoutInSeconds);
        walletNonFungibleLocks[lockedWallet][lockIndex - 1].unlockTime =
        block.timestamp.add(configuration.walletLockTimeout());

        // Emit event
        emit LockNonFungibleByProxyEvent(lockedWallet, lockerWallet, ids, currencyCt, currencyId, visibleTimeoutInSeconds);
    }

    /// @notice Unlock the given locked wallet's fungible amount of currency previously
    /// locked by the given locker wallet
    /// @param lockedWallet The address of the locked wallet
    /// @param lockerWallet The address of the locker wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function unlockFungible(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId)
    public
    {
        // Get index of lock
        uint256 lockIndex = lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        // Return if no lock exists
        if (0 == lockIndex)
            return;

        // Require that unlock timeout has expired
        require(
            block.timestamp >= walletFungibleLocks[lockedWallet][lockIndex - 1].unlockTime
        );

        // Unlock
        int256 amount = _unlockFungible(lockedWallet, lockerWallet, currencyCt, currencyId, lockIndex);

        // Emit event
        emit UnlockFungibleEvent(lockedWallet, lockerWallet, amount, currencyCt, currencyId);
    }

    /// @notice Unlock by proxy the given locked wallet's fungible amount of currency previously
    /// locked by the given locker wallet
    /// @param lockedWallet The address of the locked wallet
    /// @param lockerWallet The address of the locker wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function unlockFungibleByProxy(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId)
    public
    onlyAuthorizedService(lockedWallet)
    {
        // Get index of lock
        uint256 lockIndex = lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        // Return if no lock exists
        if (0 == lockIndex)
            return;

        // Unlock
        int256 amount = _unlockFungible(lockedWallet, lockerWallet, currencyCt, currencyId, lockIndex);

        // Emit event
        emit UnlockFungibleByProxyEvent(lockedWallet, lockerWallet, amount, currencyCt, currencyId);
    }

    /// @notice Unlock the given locked wallet's non-fungible IDs of currency previously
    /// locked by the given locker wallet
    /// @param lockedWallet The address of the locked wallet
    /// @param lockerWallet The address of the locker wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function unlockNonFungible(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId)
    public
    {
        // Get index of lock
        uint256 lockIndex = lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        // Return if no lock exists
        if (0 == lockIndex)
            return;

        // Require that unlock timeout has expired
        require(
            block.timestamp >= walletNonFungibleLocks[lockedWallet][lockIndex - 1].unlockTime
        );

        // Unlock
        int256[] memory ids = _unlockNonFungible(lockedWallet, lockerWallet, currencyCt, currencyId, lockIndex);

        // Emit event
        emit UnlockNonFungibleEvent(lockedWallet, lockerWallet, ids, currencyCt, currencyId);
    }

    /// @notice Unlock by proxy the given locked wallet's non-fungible IDs of currency previously
    /// locked by the given locker wallet
    /// @param lockedWallet The address of the locked wallet
    /// @param lockerWallet The address of the locker wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function unlockNonFungibleByProxy(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId)
    public
    onlyAuthorizedService(lockedWallet)
    {
        // Get index of lock
        uint256 lockIndex = lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        // Return if no lock exists
        if (0 == lockIndex)
            return;

        // Unlock
        int256[] memory ids = _unlockNonFungible(lockedWallet, lockerWallet, currencyCt, currencyId, lockIndex);

        // Emit event
        emit UnlockNonFungibleByProxyEvent(lockedWallet, lockerWallet, ids, currencyCt, currencyId);
    }

    /// @notice Get the number of fungible locks for the given wallet
    /// @param wallet The address of the locked wallet
    /// @return The number of fungible locks
    function fungibleLocksCount(address wallet)
    public
    view
    returns (uint256)
    {
        return walletFungibleLocks[wallet].length;
    }

    /// @notice Get the number of non-fungible locks for the given wallet
    /// @param wallet The address of the locked wallet
    /// @return The number of non-fungible locks
    function nonFungibleLocksCount(address wallet)
    public
    view
    returns (uint256)
    {
        return walletNonFungibleLocks[wallet].length;
    }

    /// @notice Get the fungible amount of the given currency held by locked wallet that is
    /// locked by locker wallet
    /// @param lockedWallet The address of the locked wallet
    /// @param lockerWallet The address of the locker wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function lockedAmount(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        uint256 lockIndex = lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        if (0 == lockIndex || block.timestamp < walletFungibleLocks[lockedWallet][lockIndex - 1].visibleTime)
            return 0;

        return walletFungibleLocks[lockedWallet][lockIndex - 1].amount;
    }

    /// @notice Get the count of non-fungible IDs of the given currency held by locked wallet that is
    /// locked by locker wallet
    /// @param lockedWallet The address of the locked wallet
    /// @param lockerWallet The address of the locker wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function lockedIdsCount(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (uint256)
    {
        uint256 lockIndex = lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        if (0 == lockIndex || block.timestamp < walletNonFungibleLocks[lockedWallet][lockIndex - 1].visibleTime)
            return 0;

        return walletNonFungibleLocks[lockedWallet][lockIndex - 1].ids.length;
    }

    /// @notice Get the set of non-fungible IDs of the given currency held by locked wallet that is
    /// locked by locker wallet and whose indices are in the given range of indices
    /// @param lockedWallet The address of the locked wallet
    /// @param lockerWallet The address of the locker wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param low The lower ID index
    /// @param up The upper ID index
    function lockedIdsByIndices(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId,
        uint256 low, uint256 up)
    public
    view
    returns (int256[] memory)
    {
        uint256 lockIndex = lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        if (0 == lockIndex || block.timestamp < walletNonFungibleLocks[lockedWallet][lockIndex - 1].visibleTime)
            return new int256[](0);

        NonFungibleLock storage lock = walletNonFungibleLocks[lockedWallet][lockIndex - 1];

        if (0 == lock.ids.length)
            return new int256[](0);

        up = up.clampMax(lock.ids.length - 1);
        int256[] memory _ids = new int256[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _ids[i - low] = lock.ids[i];

        return _ids;
    }

    /// @notice Gauge whether the given wallet is locked
    /// @param wallet The address of the concerned wallet
    /// @return true if wallet is locked, else false
    function isLocked(address wallet)
    public
    view
    returns (bool)
    {
        return 0 < walletFungibleLocks[wallet].length ||
        0 < walletNonFungibleLocks[wallet].length;
    }

    /// @notice Gauge whether the given wallet and currency is locked
    /// @param wallet The address of the concerned wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return true if wallet/currency pair is locked, else false
    function isLocked(address wallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return 0 < walletCurrencyFungibleLockCount[wallet][currencyCt][currencyId] ||
        0 < walletCurrencyNonFungibleLockCount[wallet][currencyCt][currencyId];
    }

    /// @notice Gauge whether the given locked wallet and currency is locked by the given locker wallet
    /// @param lockedWallet The address of the concerned locked wallet
    /// @param lockerWallet The address of the concerned locker wallet
    /// @return true if lockedWallet is locked by lockerWallet, else false
    function isLocked(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (bool)
    {
        return 0 < lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet] ||
        0 < lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];
    }

    //
    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _unlockFungible(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId, uint256 lockIndex)
    private
    returns (int256)
    {
        int256 amount = walletFungibleLocks[lockedWallet][lockIndex - 1].amount;

        if (lockIndex < walletFungibleLocks[lockedWallet].length) {
            walletFungibleLocks[lockedWallet][lockIndex - 1] =
            walletFungibleLocks[lockedWallet][walletFungibleLocks[lockedWallet].length - 1];

            lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][walletFungibleLocks[lockedWallet][lockIndex - 1].locker] = lockIndex;
        }
        walletFungibleLocks[lockedWallet].length--;

        lockedCurrencyLockerFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet] = 0;

        walletCurrencyFungibleLockCount[lockedWallet][currencyCt][currencyId]--;

        return amount;
    }

    function _unlockNonFungible(address lockedWallet, address lockerWallet, address currencyCt, uint256 currencyId, uint256 lockIndex)
    private
    returns (int256[] memory)
    {
        int256[] memory ids = walletNonFungibleLocks[lockedWallet][lockIndex - 1].ids;

        if (lockIndex < walletNonFungibleLocks[lockedWallet].length) {
            walletNonFungibleLocks[lockedWallet][lockIndex - 1] =
            walletNonFungibleLocks[lockedWallet][walletNonFungibleLocks[lockedWallet].length - 1];

            lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][walletNonFungibleLocks[lockedWallet][lockIndex - 1].locker] = lockIndex;
        }
        walletNonFungibleLocks[lockedWallet].length--;

        lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet] = 0;

        walletCurrencyNonFungibleLockCount[lockedWallet][currencyCt][currencyId]--;

        return ids;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title WalletLockable
 * @notice An ownable that has a wallet locker property
 */
contract WalletLockable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    WalletLocker public walletLocker;
    bool public walletLockerFrozen;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetWalletLockerEvent(WalletLocker oldWalletLocker, WalletLocker newWalletLocker);
    event FreezeWalletLockerEvent();

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the wallet locker contract
    /// @param newWalletLocker The (address of) WalletLocker contract instance
    function setWalletLocker(WalletLocker newWalletLocker)
    public
    onlyDeployer
    notNullAddress(address(newWalletLocker))
    notSameAddresses(address(newWalletLocker), address(walletLocker))
    {
        // Require that this contract has not been frozen
        require(!walletLockerFrozen, "Wallet locker frozen [WalletLockable.sol:43]");

        // Update fields
        WalletLocker oldWalletLocker = walletLocker;
        walletLocker = newWalletLocker;

        // Emit event
        emit SetWalletLockerEvent(oldWalletLocker, newWalletLocker);
    }

    /// @notice Freeze the balance tracker from further updates
    /// @dev This operation can not be undone
    function freezeWalletLocker()
    public
    onlyDeployer
    {
        walletLockerFrozen = true;

        // Emit event
        emit FreezeWalletLockerEvent();
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier walletLockerInitialized() {
        require(address(walletLocker) != address(0), "Wallet locker not initialized [WalletLockable.sol:69]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title AccrualBeneficiary
 * @notice A beneficiary of accruals
 */
contract AccrualBeneficiary is Beneficiary {
    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    event CloseAccrualPeriodEvent();

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function closeAccrualPeriod(MonetaryTypesLib.Currency[] memory)
    public
    {
        emit CloseAccrualPeriodEvent();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

library TxHistoryLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct AssetEntry {
        int256 amount;
        uint256 blockNumber;
        address currencyCt;      //0 for ethers
        uint256 currencyId;
    }

    struct TxHistory {
        AssetEntry[] deposits;
        mapping(address => mapping(uint256 => AssetEntry[])) currencyDeposits;

        AssetEntry[] withdrawals;
        mapping(address => mapping(uint256 => AssetEntry[])) currencyWithdrawals;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function addDeposit(TxHistory storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        AssetEntry memory deposit = AssetEntry(amount, block.number, currencyCt, currencyId);
        self.deposits.push(deposit);
        self.currencyDeposits[currencyCt][currencyId].push(deposit);
    }

    function addWithdrawal(TxHistory storage self, int256 amount, address currencyCt, uint256 currencyId)
    internal
    {
        AssetEntry memory withdrawal = AssetEntry(amount, block.number, currencyCt, currencyId);
        self.withdrawals.push(withdrawal);
        self.currencyWithdrawals[currencyCt][currencyId].push(withdrawal);
    }

    //----

    function deposit(TxHistory storage self, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        require(index < self.deposits.length, "Index ouf of bounds [TxHistoryLib.sol:56]");

        amount = self.deposits[index].amount;
        blockNumber = self.deposits[index].blockNumber;
        currencyCt = self.deposits[index].currencyCt;
        currencyId = self.deposits[index].currencyId;
    }

    function depositsCount(TxHistory storage self)
    internal
    view
    returns (uint256)
    {
        return self.deposits.length;
    }

    function currencyDeposit(TxHistory storage self, address currencyCt, uint256 currencyId, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber)
    {
        require(index < self.currencyDeposits[currencyCt][currencyId].length, "Index out of bounds [TxHistoryLib.sol:77]");

        amount = self.currencyDeposits[currencyCt][currencyId][index].amount;
        blockNumber = self.currencyDeposits[currencyCt][currencyId][index].blockNumber;
    }

    function currencyDepositsCount(TxHistory storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.currencyDeposits[currencyCt][currencyId].length;
    }

    //----

    function withdrawal(TxHistory storage self, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        require(index < self.withdrawals.length, "Index out of bounds [TxHistoryLib.sol:98]");

        amount = self.withdrawals[index].amount;
        blockNumber = self.withdrawals[index].blockNumber;
        currencyCt = self.withdrawals[index].currencyCt;
        currencyId = self.withdrawals[index].currencyId;
    }

    function withdrawalsCount(TxHistory storage self)
    internal
    view
    returns (uint256)
    {
        return self.withdrawals.length;
    }

    function currencyWithdrawal(TxHistory storage self, address currencyCt, uint256 currencyId, uint index)
    internal
    view
    returns (int256 amount, uint256 blockNumber)
    {
        require(index < self.currencyWithdrawals[currencyCt][currencyId].length, "Index out of bounds [TxHistoryLib.sol:119]");

        amount = self.currencyWithdrawals[currencyCt][currencyId][index].amount;
        blockNumber = self.currencyWithdrawals[currencyCt][currencyId][index].blockNumber;
    }

    function currencyWithdrawalsCount(TxHistory storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.currencyWithdrawals[currencyCt][currencyId].length;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

/**
 * @dev Extension of `ERC20` that adds a set of accounts with the `MinterRole`,
 * which have permission to mint (create) new tokens as they see fit.
 *
 * At construction, the deployer of the contract is the only minter.
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev See `ERC20._mint`.
     *
     * Requirements:
     *
     * - the caller must have the `MinterRole`.
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title RevenueToken
 * @dev Implementation of the EIP20 standard token (also known as ERC20 token) with added
 * calculation of balance blocks at every transfer.
 */
contract RevenueToken is ERC20Mintable {
    using SafeMath for uint256;

    bool public mintingDisabled;

    address[] public holders;

    mapping(address => bool) public holdersMap;

    mapping(address => uint256[]) public balances;

    mapping(address => uint256[]) public balanceBlocks;

    mapping(address => uint256[]) public balanceBlockNumbers;

    event DisableMinting();

    /**
     * @notice Disable further minting
     * @dev This operation can not be undone
     */
    function disableMinting()
    public
    onlyMinter
    {
        mintingDisabled = true;

        emit DisableMinting();
    }

    /**
     * @notice Mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value)
    public
    onlyMinter
    returns (bool)
    {
        require(!mintingDisabled, "Minting disabled [RevenueToken.sol:60]");

        // Call super's mint, including event emission
        bool minted = super.mint(to, value);

        if (minted) {
            // Adjust balance blocks
            addBalanceBlocks(to);

            // Add to the token holders list
            if (!holdersMap[to]) {
                holdersMap[to] = true;
                holders.push(to);
            }
        }

        return minted;
    }

    /**
     * @notice Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return A boolean that indicates if the operation was successful.
     */
    function transfer(address to, uint256 value)
    public
    returns (bool)
    {
        // Call super's transfer, including event emission
        bool transferred = super.transfer(to, value);

        if (transferred) {
            // Adjust balance blocks
            addBalanceBlocks(msg.sender);
            addBalanceBlocks(to);

            // Add to the token holders list
            if (!holdersMap[to]) {
                holdersMap[to] = true;
                holders.push(to);
            }
        }

        return transferred;
    }

    /**
     * @notice Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @dev Beware that to change the approve amount you first have to reduce the addresses'
     * allowance to zero by calling `approve(spender, 0)` if it is not already 0 to mitigate the race
     * condition described here:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value)
    public
    returns (bool)
    {
        // Prevent the update of non-zero allowance
        require(
            0 == value || 0 == allowance(msg.sender, spender),
            "Value or allowance non-zero [RevenueToken.sol:121]"
        );

        // Call super's approve, including event emission
        return super.approve(spender, value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     * @return A boolean that indicates if the operation was successful.
     */
    function transferFrom(address from, address to, uint256 value)
    public
    returns (bool)
    {
        // Call super's transferFrom, including event emission
        bool transferred = super.transferFrom(from, to, value);

        if (transferred) {
            // Adjust balance blocks
            addBalanceBlocks(from);
            addBalanceBlocks(to);

            // Add to the token holders list
            if (!holdersMap[to]) {
                holdersMap[to] = true;
                holders.push(to);
            }
        }

        return transferred;
    }

    /**
     * @notice Calculate the amount of balance blocks, i.e. the area under the curve (AUC) of
     * balance as function of block number
     * @dev The AUC is used as weight for the share of revenue that a token holder may claim
     * @param account The account address for which calculation is done
     * @param startBlock The start block number considered
     * @param endBlock The end block number considered
     * @return The calculated AUC
     */
    function balanceBlocksIn(address account, uint256 startBlock, uint256 endBlock)
    public
    view
    returns (uint256)
    {
        require(startBlock < endBlock, "Bounds parameters mismatch [RevenueToken.sol:173]");
        require(account != address(0), "Account is null address [RevenueToken.sol:174]");

        if (balanceBlockNumbers[account].length == 0 || endBlock < balanceBlockNumbers[account][0])
            return 0;

        uint256 i = 0;
        while (i < balanceBlockNumbers[account].length && balanceBlockNumbers[account][i] < startBlock)
            i++;

        uint256 r;
        if (i >= balanceBlockNumbers[account].length)
            r = balances[account][balanceBlockNumbers[account].length - 1].mul(endBlock.sub(startBlock));

        else {
            uint256 l = (i == 0) ? startBlock : balanceBlockNumbers[account][i - 1];

            uint256 h = balanceBlockNumbers[account][i];
            if (h > endBlock)
                h = endBlock;

            h = h.sub(startBlock);
            r = (h == 0) ? 0 : balanceBlocks[account][i].mul(h).div(balanceBlockNumbers[account][i].sub(l));
            i++;

            while (i < balanceBlockNumbers[account].length && balanceBlockNumbers[account][i] < endBlock) {
                r = r.add(balanceBlocks[account][i]);
                i++;
            }

            if (i >= balanceBlockNumbers[account].length)
                r = r.add(
                    balances[account][balanceBlockNumbers[account].length - 1].mul(
                        endBlock.sub(balanceBlockNumbers[account][balanceBlockNumbers[account].length - 1])
                    )
                );

            else if (balanceBlockNumbers[account][i - 1] < endBlock)
                r = r.add(
                    balanceBlocks[account][i].mul(
                        endBlock.sub(balanceBlockNumbers[account][i - 1])
                    ).div(
                        balanceBlockNumbers[account][i].sub(balanceBlockNumbers[account][i - 1])
                    )
                );
        }

        return r;
    }

    /**
     * @notice Get the count of balance updates for the given account
     * @return The count of balance updates
     */
    function balanceUpdatesCount(address account)
    public
    view
    returns (uint256)
    {
        return balanceBlocks[account].length;
    }

    /**
     * @notice Get the count of holders
     * @return The count of holders
     */
    function holdersCount()
    public
    view
    returns (uint256)
    {
        return holders.length;
    }

    /**
     * @notice Get the subset of holders (optionally with positive balance only) in the given 0 based index range
     * @param low The lower inclusive index
     * @param up The upper inclusive index
     * @param posOnly List only positive balance holders
     * @return The subset of positive balance registered holders in the given range
     */
    function holdersByIndices(uint256 low, uint256 up, bool posOnly)
    public
    view
    returns (address[] memory)
    {
        require(low <= up, "Bounds parameters mismatch [RevenueToken.sol:259]");

        up = up > holders.length - 1 ? holders.length - 1 : up;

        uint256 length = 0;
        if (posOnly) {
            for (uint256 i = low; i <= up; i++)
                if (0 < balanceOf(holders[i]))
                    length++;
        } else
            length = up - low + 1;

        address[] memory _holders = new address[](length);

        uint256 j = 0;
        for (uint256 i = low; i <= up; i++)
            if (!posOnly || 0 < balanceOf(holders[i]))
                _holders[j++] = holders[i];

        return _holders;
    }

    function addBalanceBlocks(address account)
    private
    {
        uint256 length = balanceBlockNumbers[account].length;
        balances[account].push(balanceOf(account));
        if (0 < length)
            balanceBlocks[account].push(
                balances[account][length - 1].mul(
                    block.number.sub(balanceBlockNumbers[account][length - 1])
                )
            );
        else
            balanceBlocks[account].push(0);
        balanceBlockNumbers[account].push(block.number);
    }
}

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Balance tracker
 * @notice An ownable that allows a beneficiary to extract tokens in
 *   a number of batches each a given release time
 */
contract TokenMultiTimelock is Ownable {
    using SafeERC20 for IERC20;

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Release {
        uint256 earliestReleaseTime;
        uint256 amount;
        uint256 blockNumber;
        bool done;
    }

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    IERC20 public token;
    address public beneficiary;

    Release[] public releases;
    uint256 public totalLockedAmount;
    uint256 public executedReleasesCount;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetTokenEvent(IERC20 token);
    event SetBeneficiaryEvent(address beneficiary);
    event DefineReleaseEvent(uint256 earliestReleaseTime, uint256 amount, uint256 blockNumber);
    event SetReleaseBlockNumberEvent(uint256 index, uint256 blockNumber);
    event ReleaseEvent(uint256 index, uint256 blockNumber, uint256 earliestReleaseTime,
        uint256 actualReleaseTime, uint256 amount);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer)
    Ownable(deployer)
    public
    {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the address of token
    /// @param _token The address of token
    function setToken(IERC20 _token)
    public
    onlyOperator
    notNullOrThisAddress(address(_token))
    {
        // Require that the token has not previously been set
        require(address(token) == address(0), "Token previously set [TokenMultiTimelock.sol:73]");

        // Update beneficiary
        token = _token;

        // Emit event
        emit SetTokenEvent(token);
    }

    /// @notice Set the address of beneficiary
    /// @param _beneficiary The new address of beneficiary
    function setBeneficiary(address _beneficiary)
    public
    onlyOperator
    notNullAddress(_beneficiary)
    {
        // Update beneficiary
        beneficiary = _beneficiary;

        // Emit event
        emit SetBeneficiaryEvent(beneficiary);
    }

    /// @notice Define a set of new releases
    /// @param earliestReleaseTimes The timestamp after which the corresponding amount may be released
    /// @param amounts The amounts to be released
    /// @param releaseBlockNumbers The set release block numbers for releases whose earliest release time
    /// is in the past
    function defineReleases(uint256[] memory earliestReleaseTimes, uint256[] memory amounts, uint256[] memory releaseBlockNumbers)
    onlyOperator
    public
    {
        require(
            earliestReleaseTimes.length == amounts.length,
            "Earliest release times and amounts lengths mismatch [TokenMultiTimelock.sol:105]"
        );
        require(
            earliestReleaseTimes.length >= releaseBlockNumbers.length,
            "Earliest release times and release block numbers lengths mismatch [TokenMultiTimelock.sol:109]"
        );

        // Require that token address has been set
        require(address(token) != address(0), "Token not initialized [TokenMultiTimelock.sol:115]");

        for (uint256 i = 0; i < earliestReleaseTimes.length; i++) {
            // Update the total amount locked by this contract
            totalLockedAmount += amounts[i];

            // Require that total amount locked is less than or equal to the token balance of
            // this contract
            require(token.balanceOf(address(this)) >= totalLockedAmount, "Total locked amount overrun [TokenMultiTimelock.sol:123]");

            // Retrieve early block number where available
            uint256 blockNumber = i < releaseBlockNumbers.length ? releaseBlockNumbers[i] : 0;

            // Add release
            releases.push(Release(earliestReleaseTimes[i], amounts[i], blockNumber, false));

            // Emit event
            emit DefineReleaseEvent(earliestReleaseTimes[i], amounts[i], blockNumber);
        }
    }

    /// @notice Get the count of releases
    /// @return The number of defined releases
    function releasesCount()
    public
    view
    returns (uint256)
    {
        return releases.length;
    }

    /// @notice Set the block number of a release that is not done
    /// @param index The index of the release
    /// @param blockNumber The updated block number
    function setReleaseBlockNumber(uint256 index, uint256 blockNumber)
    public
    onlyBeneficiary
    {
        // Require that the release is not done
        require(!releases[index].done, "Release previously done [TokenMultiTimelock.sol:154]");

        // Update the release block number
        releases[index].blockNumber = blockNumber;

        // Emit event
        emit SetReleaseBlockNumberEvent(index, blockNumber);
    }

    /// @notice Transfers tokens held in the indicated release to beneficiary.
    /// @param index The index of the release
    function release(uint256 index)
    public
    onlyBeneficiary
    {
        // Get the release object
        Release storage _release = releases[index];

        // Require that this release has been properly defined by having non-zero amount
        require(0 < _release.amount, "Release amount not strictly positive [TokenMultiTimelock.sol:173]");

        // Require that this release has not already been executed
        require(!_release.done, "Release previously done [TokenMultiTimelock.sol:176]");

        // Require that the current timestamp is beyond the nominal release time
        require(block.timestamp >= _release.earliestReleaseTime, "Block time stamp less than earliest release time [TokenMultiTimelock.sol:179]");

        // Set release done
        _release.done = true;

        // Set release block number if not previously set
        if (0 == _release.blockNumber)
            _release.blockNumber = block.number;

        // Bump number of executed releases
        executedReleasesCount++;

        // Decrement the total locked amount
        totalLockedAmount -= _release.amount;

        // Execute transfer
        token.safeTransfer(beneficiary, _release.amount);

        // Emit event
        emit ReleaseEvent(index, _release.blockNumber, _release.earliestReleaseTime, block.timestamp, _release.amount);
    }

    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Message sender not beneficiary [TokenMultiTimelock.sol:204]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

contract RevenueTokenManager is TokenMultiTimelock {
    using SafeMathUintLib for uint256;

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    uint256[] public totalReleasedAmounts;
    uint256[] public totalReleasedAmountBlocks;

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer)
    public
    TokenMultiTimelock(deployer)
    {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Transfers tokens held in the indicated release to beneficiary
    /// and update amount blocks
    /// @param index The index of the release
    function release(uint256 index)
    public
    onlyBeneficiary
    {
        // Call release of multi timelock
        super.release(index);

        // Add amount blocks
        _addAmountBlocks(index);
    }

    /// @notice Calculate the released amount blocks, i.e. the area under the curve (AUC) of
    /// release amount as function of block number
    /// @param startBlock The start block number considered
    /// @param endBlock The end block number considered
    /// @return The calculated AUC
    function releasedAmountBlocksIn(uint256 startBlock, uint256 endBlock)
    public
    view
    returns (uint256)
    {
        require(startBlock < endBlock, "Bounds parameters mismatch [RevenueTokenManager.sol:60]");

        if (executedReleasesCount == 0 || endBlock < releases[0].blockNumber)
            return 0;

        uint256 i = 0;
        while (i < executedReleasesCount && releases[i].blockNumber < startBlock)
            i++;

        uint256 r;
        if (i >= executedReleasesCount)
            r = totalReleasedAmounts[executedReleasesCount - 1].mul(endBlock.sub(startBlock));

        else {
            uint256 l = (i == 0) ? startBlock : releases[i - 1].blockNumber;

            uint256 h = releases[i].blockNumber;
            if (h > endBlock)
                h = endBlock;

            h = h.sub(startBlock);
            r = (h == 0) ? 0 : totalReleasedAmountBlocks[i].mul(h).div(releases[i].blockNumber.sub(l));
            i++;

            while (i < executedReleasesCount && releases[i].blockNumber < endBlock) {
                r = r.add(totalReleasedAmountBlocks[i]);
                i++;
            }

            if (i >= executedReleasesCount)
                r = r.add(
                    totalReleasedAmounts[executedReleasesCount - 1].mul(
                        endBlock.sub(releases[executedReleasesCount - 1].blockNumber)
                    )
                );

            else if (releases[i - 1].blockNumber < endBlock)
                r = r.add(
                    totalReleasedAmountBlocks[i].mul(
                        endBlock.sub(releases[i - 1].blockNumber)
                    ).div(
                        releases[i].blockNumber.sub(releases[i - 1].blockNumber)
                    )
                );
        }

        return r;
    }

    /// @notice Get the block number of the release
    /// @param index The index of the release
    /// @return The block number of the release;
    function releaseBlockNumbers(uint256 index)
    public
    view
    returns (uint256)
    {
        return releases[index].blockNumber;
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _addAmountBlocks(uint256 index)
    private
    {
        // Push total amount released and total released amount blocks
        if (0 < index) {
            totalReleasedAmounts.push(
                totalReleasedAmounts[index - 1] + releases[index].amount
            );
            totalReleasedAmountBlocks.push(
                totalReleasedAmounts[index - 1].mul(
                    releases[index].blockNumber.sub(releases[index - 1].blockNumber)
                )
            );

        } else {
            totalReleasedAmounts.push(releases[index].amount);
            totalReleasedAmountBlocks.push(0);
        }
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title TokenHolderRevenueFund
 * @notice Fund that manages the revenue earned by revenue token holders.
 */
contract TokenHolderRevenueFund is Ownable, AccrualBeneficiary, Servable, TransferControllerManageable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using FungibleBalanceLib for FungibleBalanceLib.Balance;
    using TxHistoryLib for TxHistoryLib.TxHistory;
    using CurrenciesLib for CurrenciesLib.Currencies;

    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    string constant public CLOSE_ACCRUAL_PERIOD_ACTION = "close_accrual_period";

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    RevenueTokenManager public revenueTokenManager;

    FungibleBalanceLib.Balance private periodAccrual;
    CurrenciesLib.Currencies private periodCurrencies;

    FungibleBalanceLib.Balance private aggregateAccrual;
    CurrenciesLib.Currencies private aggregateCurrencies;

    TxHistoryLib.TxHistory private txHistory;

    mapping(address => mapping(address => mapping(uint256 => uint256[]))) public claimedAccrualBlockNumbersByWalletCurrency;

    mapping(address => mapping(uint256 => uint256[])) public accrualBlockNumbersByCurrency;
    mapping(address => mapping(uint256 => mapping(uint256 => int256))) public aggregateAccrualAmountByCurrencyBlockNumber;

    mapping(address => FungibleBalanceLib.Balance) private stagedByWallet;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetRevenueTokenManagerEvent(RevenueTokenManager oldRevenueTokenManager,
        RevenueTokenManager newRevenueTokenManager);
    event ReceiveEvent(address wallet, int256 amount, address currencyCt,
        uint256 currencyId);
    event WithdrawEvent(address to, int256 amount, address currencyCt, uint256 currencyId);
    event CloseAccrualPeriodEvent(int256 periodAmount, int256 aggregateAmount, address currencyCt,
        uint256 currencyId);
    event ClaimAndTransferToBeneficiaryEvent(address wallet, string balanceType, int256 amount,
        address currencyCt, uint256 currencyId, string standard);
    event ClaimAndTransferToBeneficiaryByProxyEvent(address wallet, string balanceType, int256 amount,
        address currencyCt, uint256 currencyId, string standard);
    event ClaimAndStageEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event WithdrawEvent(address from, int256 amount, address currencyCt, uint256 currencyId,
        string standard);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the revenue token manager contract
    /// @param newRevenueTokenManager The (address of) RevenueTokenManager contract instance
    function setRevenueTokenManager(RevenueTokenManager newRevenueTokenManager)
    public
    onlyDeployer
    notNullAddress(address(newRevenueTokenManager))
    {
        if (newRevenueTokenManager != revenueTokenManager) {
            // Set new revenue token
            RevenueTokenManager oldRevenueTokenManager = revenueTokenManager;
            revenueTokenManager = newRevenueTokenManager;

            // Emit event
            emit SetRevenueTokenManagerEvent(oldRevenueTokenManager, newRevenueTokenManager);
        }
    }

    /// @notice Fallback function that deposits ethers
    function() external payable {
        receiveEthersTo(msg.sender, "");
    }

    /// @notice Receive ethers to
    /// @param wallet The concerned wallet address
    function receiveEthersTo(address wallet, string memory)
    public
    payable
    {
        int256 amount = SafeMathIntLib.toNonZeroInt256(msg.value);

        // Add to balances
        periodAccrual.add(amount, address(0), 0);
        aggregateAccrual.add(amount, address(0), 0);

        // Add currency to in-use lists
        periodCurrencies.add(address(0), 0);
        aggregateCurrencies.add(address(0), 0);

        // Add to transaction history
        txHistory.addDeposit(amount, address(0), 0);

        // Emit event
        emit ReceiveEvent(wallet, amount, address(0), 0);
    }

    /// @notice Receive tokens
    /// @param amount The concerned amount
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of token ("ERC20", "ERC721")
    function receiveTokens(string memory, int256 amount, address currencyCt, uint256 currencyId,
        string memory standard)
    public
    {
        receiveTokensTo(msg.sender, "", amount, currencyCt, currencyId, standard);
    }

    /// @notice Receive tokens to
    /// @param wallet The address of the concerned wallet
    /// @param amount The concerned amount
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of token ("ERC20", "ERC721")
    function receiveTokensTo(address wallet, string memory, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        require(amount.isNonZeroPositiveInt256(), "Amount not strictly positive [TokenHolderRevenueFund.sol:157]");

        // Execute transfer
        TransferController controller = transferController(currencyCt, standard);
        (bool success,) = address(controller).delegatecall(
            abi.encodeWithSelector(
                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId
            )
        );
        require(success, "Reception by controller failed [TokenHolderRevenueFund.sol:166]");

        // Add to balances
        periodAccrual.add(amount, currencyCt, currencyId);
        aggregateAccrual.add(amount, currencyCt, currencyId);

        // Add currency to in-use lists
        periodCurrencies.add(currencyCt, currencyId);
        aggregateCurrencies.add(currencyCt, currencyId);

        // Add to transaction history
        txHistory.addDeposit(amount, currencyCt, currencyId);

        // Emit event
        emit ReceiveEvent(wallet, amount, currencyCt, currencyId);
    }

    /// @notice Get the period accrual balance of the given currency
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The current period's accrual balance
    function periodAccrualBalance(address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return periodAccrual.get(currencyCt, currencyId);
    }

    /// @notice Get the aggregate accrual balance of the given currency, including contribution from the
    /// current accrual period
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The aggregate accrual balance
    function aggregateAccrualBalance(address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return aggregateAccrual.get(currencyCt, currencyId);
    }

    /// @notice Get the count of currencies recorded in the accrual period
    /// @return The number of currencies in the current accrual period
    function periodCurrenciesCount()
    public
    view
    returns (uint256)
    {
        return periodCurrencies.count();
    }

    /// @notice Get the currencies with indices in the given range that have been recorded in the current accrual period
    /// @param low The lower currency index
    /// @param up The upper currency index
    /// @return The currencies of the given index range in the current accrual period
    function periodCurrenciesByIndices(uint256 low, uint256 up)
    public
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        return periodCurrencies.getByIndices(low, up);
    }

    /// @notice Get the count of currencies ever recorded
    /// @return The number of currencies ever recorded
    function aggregateCurrenciesCount()
    public
    view
    returns (uint256)
    {
        return aggregateCurrencies.count();
    }

    /// @notice Get the currencies with indices in the given range that have ever been recorded
    /// @param low The lower currency index
    /// @param up The upper currency index
    /// @return The currencies of the given index range ever recorded
    function aggregateCurrenciesByIndices(uint256 low, uint256 up)
    public
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        return aggregateCurrencies.getByIndices(low, up);
    }

    /// @notice Get the count of deposits
    /// @return The count of deposits
    function depositsCount()
    public
    view
    returns (uint256)
    {
        return txHistory.depositsCount();
    }

    /// @notice Get the deposit at the given index
    /// @return The deposit at the given index
    function deposit(uint index)
    public
    view
    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        return txHistory.deposit(index);
    }

    /// @notice Get the staged balance of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The staged balance
    function stagedBalance(address wallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return stagedByWallet[wallet].get(currencyCt, currencyId);
    }

    /// @notice Close the current accrual period of the given currencies
    /// @param currencies The concerned currencies
    function closeAccrualPeriod(MonetaryTypesLib.Currency[] memory currencies)
    public
    onlyEnabledServiceAction(CLOSE_ACCRUAL_PERIOD_ACTION)
    {
        // Clear period accrual stats
        for (uint256 i = 0; i < currencies.length; i++) {
            MonetaryTypesLib.Currency memory currency = currencies[i];

            // Get the amount of the accrual period
            int256 periodAmount = periodAccrual.get(currency.ct, currency.id);

            // Register this block number as accrual block number of currency
            accrualBlockNumbersByCurrency[currency.ct][currency.id].push(block.number);

            // Store the aggregate accrual balance of currency at this block number
            aggregateAccrualAmountByCurrencyBlockNumber[currency.ct][currency.id][block.number] = aggregateAccrualBalance(
                currency.ct, currency.id
            );

            if (periodAmount > 0) {
                // Reset period accrual of currency
                periodAccrual.set(0, currency.ct, currency.id);

                // Remove currency from period in-use list
                periodCurrencies.removeByCurrency(currency.ct, currency.id);
            }

            // Emit event
            emit CloseAccrualPeriodEvent(
                periodAmount,
                aggregateAccrualAmountByCurrencyBlockNumber[currency.ct][currency.id][block.number],
                currency.ct, currency.id
            );
        }
    }

    /// @notice Claim accrual and transfer to beneficiary
    /// @param beneficiary The concerned beneficiary
    /// @param destWallet The concerned destination wallet of the transfer
    /// @param balanceType The target balance type
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function claimAndTransferToBeneficiary(Beneficiary beneficiary, address destWallet, string memory balanceType,
        address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        // Claim accrual and obtain the claimed amount
        int256 claimedAmount = _claim(msg.sender, currencyCt, currencyId);

        // Transfer ETH to the beneficiary
        if (address(0) == currencyCt && 0 == currencyId)
            beneficiary.receiveEthersTo.value(uint256(claimedAmount))(destWallet, balanceType);

        else {
            // Approve of beneficiary
            TransferController controller = transferController(currencyCt, standard);
            (bool success,) = address(controller).delegatecall(
                abi.encodeWithSelector(
                    controller.getApproveSignature(), address(beneficiary), uint256(claimedAmount), currencyCt, currencyId
                )
            );
            require(success, "Approval by controller failed [TokenHolderRevenueFund.sol:349]");

            // Transfer tokens to the beneficiary
            beneficiary.receiveTokensTo(destWallet, balanceType, claimedAmount, currencyCt, currencyId, standard);
        }

        // Emit event
        emit ClaimAndTransferToBeneficiaryEvent(msg.sender, balanceType, claimedAmount, currencyCt, currencyId, standard);
    }

    /// @notice Claim accrual and stage for later withdrawal
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function claimAndStage(address currencyCt, uint256 currencyId)
    public
    {
        // Claim accrual and obtain the claimed amount
        int256 claimedAmount = _claim(msg.sender, currencyCt, currencyId);

        // Update staged balance
        stagedByWallet[msg.sender].add(claimedAmount, currencyCt, currencyId);

        // Emit event
        emit ClaimAndStageEvent(msg.sender, claimedAmount, currencyCt, currencyId);
    }

    /// @notice Withdraw from staged balance of msg.sender
    /// @param amount The concerned amount
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function withdraw(int256 amount, address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        // Require that amount is strictly positive
        require(amount.isNonZeroPositiveInt256(), "Amount not strictly positive [TokenHolderRevenueFund.sol:384]");

        // Clamp amount to the max given by staged balance
        amount = amount.clampMax(stagedByWallet[msg.sender].get(currencyCt, currencyId));

        // Subtract to per-wallet staged balance
        stagedByWallet[msg.sender].sub(amount, currencyCt, currencyId);

        // Execute transfer
        if (address(0) == currencyCt && 0 == currencyId)
            msg.sender.transfer(uint256(amount));

        else {
            TransferController controller = transferController(currencyCt, standard);
            (bool success,) = address(controller).delegatecall(
                abi.encodeWithSelector(
                    controller.getDispatchSignature(), address(this), msg.sender, uint256(amount), currencyCt, currencyId
                )
            );
            require(success, "Dispatch by controller failed [TokenHolderRevenueFund.sol:403]");
        }

        // Emit event
        emit WithdrawEvent(msg.sender, amount, currencyCt, currencyId, standard);
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _claim(address wallet, address currencyCt, uint256 currencyId)
    private
    returns (int256)
    {
        // Require that at least one accrual period has terminated
        require(0 < accrualBlockNumbersByCurrency[currencyCt][currencyId].length, "No terminated accrual period found [TokenHolderRevenueFund.sol:418]");

        // Calculate lower block number as last accrual block number claimed for currency c by wallet OR 0
        uint256[] storage claimedAccrualBlockNumbers = claimedAccrualBlockNumbersByWalletCurrency[wallet][currencyCt][currencyId];
        uint256 bnLow = (0 == claimedAccrualBlockNumbers.length ? 0 : claimedAccrualBlockNumbers[claimedAccrualBlockNumbers.length - 1]);

        // Set upper block number as last accrual block number
        uint256 bnUp = accrualBlockNumbersByCurrency[currencyCt][currencyId][accrualBlockNumbersByCurrency[currencyCt][currencyId].length - 1];

        // Require that lower block number is below upper block number
        require(bnLow < bnUp, "Bounds parameters mismatch [TokenHolderRevenueFund.sol:428]");

        // Calculate the amount that is claimable in the span between lower and upper block numbers
        int256 claimableAmount = aggregateAccrualAmountByCurrencyBlockNumber[currencyCt][currencyId][bnUp]
        - (0 == bnLow ? 0 : aggregateAccrualAmountByCurrencyBlockNumber[currencyCt][currencyId][bnLow]);

        // Require that claimable amount is strictly positive
        require(claimableAmount.isNonZeroPositiveInt256(), "Claimable amount not strictly positive [TokenHolderRevenueFund.sol:435]");

        // Retrieve the balance blocks of wallet
        int256 walletBalanceBlocks = int256(
            RevenueToken(address(revenueTokenManager.token())).balanceBlocksIn(wallet, bnLow, bnUp)
        );

        // Retrieve the released amount blocks
        int256 releasedAmountBlocks = int256(
            revenueTokenManager.releasedAmountBlocksIn(bnLow, bnUp)
        );

        // Calculate the claimed amount
        int256 claimedAmount = walletBalanceBlocks.mul_nn(claimableAmount).mul_nn(1e18).div_nn(releasedAmountBlocks.mul_nn(1e18));

        // Store upper bound as the last claimed accrual block number for currency
        claimedAccrualBlockNumbers.push(bnUp);

        // Return the claimed amount
        return claimedAmount;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Client fund
 * @notice Where clients¡¯ crypto is deposited into, staged and withdrawn from.
 */
contract ClientFund is Ownable, Beneficiary, Benefactor, AuthorizableServable, TransferControllerManageable,
BalanceTrackable, TransactionTrackable, WalletLockable {
    using SafeMathIntLib for int256;

    address[] public seizedWallets;
    mapping(address => bool) public seizedByWallet;

    TokenHolderRevenueFund public tokenHolderRevenueFund;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetTokenHolderRevenueFundEvent(TokenHolderRevenueFund oldTokenHolderRevenueFund,
        TokenHolderRevenueFund newTokenHolderRevenueFund);
    event ReceiveEvent(address wallet, string balanceType, int256 value, address currencyCt,
        uint256 currencyId, string standard);
    event WithdrawEvent(address wallet, int256 value, address currencyCt, uint256 currencyId,
        string standard);
    event StageEvent(address wallet, int256 value, address currencyCt, uint256 currencyId,
        string standard);
    event UnstageEvent(address wallet, int256 value, address currencyCt, uint256 currencyId,
        string standard);
    event UpdateSettledBalanceEvent(address wallet, int256 value, address currencyCt,
        uint256 currencyId);
    event StageToBeneficiaryEvent(address sourceWallet, Beneficiary beneficiary, int256 value,
        address currencyCt, uint256 currencyId, string standard);
    event TransferToBeneficiaryEvent(address wallet, Beneficiary beneficiary, int256 value,
        address currencyCt, uint256 currencyId, string standard);
    event SeizeBalancesEvent(address seizedWallet, address seizerWallet, int256 value,
        address currencyCt, uint256 currencyId);
    event ClaimRevenueEvent(address claimer, string balanceType, address currencyCt,
        uint256 currencyId, string standard);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) Beneficiary() Benefactor()
    public
    {
        serviceActivationTimeout = 1 weeks;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the token holder revenue fund contract
    /// @param newTokenHolderRevenueFund The (address of) TokenHolderRevenueFund contract instance
    function setTokenHolderRevenueFund(TokenHolderRevenueFund newTokenHolderRevenueFund)
    public
    onlyDeployer
    notNullAddress(address(newTokenHolderRevenueFund))
    notSameAddresses(address(newTokenHolderRevenueFund), address(tokenHolderRevenueFund))
    {
        // Set new token holder revenue fund
        TokenHolderRevenueFund oldTokenHolderRevenueFund = tokenHolderRevenueFund;
        tokenHolderRevenueFund = newTokenHolderRevenueFund;

        // Emit event
        emit SetTokenHolderRevenueFundEvent(oldTokenHolderRevenueFund, newTokenHolderRevenueFund);
    }

    /// @notice Fallback function that deposits ethers to msg.sender's deposited balance
    function()
    external
    payable
    {
        receiveEthersTo(msg.sender, balanceTracker.DEPOSITED_BALANCE_TYPE());
    }

    /// @notice Receive ethers to the given wallet's balance of the given type
    /// @param wallet The address of the concerned wallet
    /// @param balanceType The target balance type
    function receiveEthersTo(address wallet, string memory balanceType)
    public
    payable
    {
        int256 value = SafeMathIntLib.toNonZeroInt256(msg.value);

        // Register reception
        _receiveTo(wallet, balanceType, value, address(0), 0, true);

        // Emit event
        emit ReceiveEvent(wallet, balanceType, value, address(0), 0, "");
    }

    /// @notice Receive token to msg.sender's balance of the given type
    /// @dev The wallet must approve of this ClientFund's transfer prior to calling this function
    /// @param balanceType The target balance type
    /// @param value The value (amount of fungible, id of non-fungible) to receive
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function receiveTokens(string memory balanceType, int256 value, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        receiveTokensTo(msg.sender, balanceType, value, currencyCt, currencyId, standard);
    }

    /// @notice Receive token to the given wallet's balance of the given type
    /// @dev The wallet must approve of this ClientFund's transfer prior to calling this function
    /// @param wallet The address of the concerned wallet
    /// @param balanceType The target balance type
    /// @param value The value (amount of fungible, id of non-fungible) to receive
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function receiveTokensTo(address wallet, string memory balanceType, int256 value, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        require(value.isNonZeroPositiveInt256());

        // Get transfer controller
        TransferController controller = transferController(currencyCt, standard);

        // Execute transfer
        (bool success,) = address(controller).delegatecall(
            abi.encodeWithSelector(
                controller.getReceiveSignature(), msg.sender, this, uint256(value), currencyCt, currencyId
            )
        );
        require(success);

        // Register reception
        _receiveTo(wallet, balanceType, value, currencyCt, currencyId, controller.isFungible());

        // Emit event
        emit ReceiveEvent(wallet, balanceType, value, currencyCt, currencyId, standard);
    }

    /// @notice Update the settled balance by the difference between provided off-chain balance amount
    /// and deposited on-chain balance, where deposited balance is resolved at the given block number
    /// @param wallet The address of the concerned wallet
    /// @param value The target balance value (amount of fungible, id of non-fungible), i.e. off-chain balance
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    /// @param blockNumber The block number to which the settled balance is updated
    function updateSettledBalance(address wallet, int256 value, address currencyCt, uint256 currencyId,
        string memory standard, uint256 blockNumber)
    public
    onlyAuthorizedService(wallet)
    notNullAddress(wallet)
    {
        require(value.isPositiveInt256());

        if (_isFungible(currencyCt, currencyId, standard)) {
            (int256 depositedValue,) = balanceTracker.fungibleRecordByBlockNumber(
                wallet, balanceTracker.depositedBalanceType(), currencyCt, currencyId, blockNumber
            );
            balanceTracker.set(
                wallet, balanceTracker.settledBalanceType(), value.sub(depositedValue),
                currencyCt, currencyId, true
            );

        } else {
            balanceTracker.sub(
                wallet, balanceTracker.depositedBalanceType(), value, currencyCt, currencyId, false
            );
            balanceTracker.add(
                wallet, balanceTracker.settledBalanceType(), value, currencyCt, currencyId, false
            );
        }

        // Emit event
        emit UpdateSettledBalanceEvent(wallet, value, currencyCt, currencyId);
    }

    /// @notice Stage a value for subsequent withdrawal
    /// @param wallet The address of the concerned wallet
    /// @param value The value (amount of fungible, id of non-fungible) to deposit
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function stage(address wallet, int256 value, address currencyCt, uint256 currencyId,
        string memory standard)
    public
    onlyAuthorizedService(wallet)
    {
        require(value.isNonZeroPositiveInt256());

        // Deduce fungibility
        bool fungible = _isFungible(currencyCt, currencyId, standard);

        // Subtract stage value from settled, possibly also from deposited
        value = _subtractSequentially(wallet, balanceTracker.activeBalanceTypes(), value, currencyCt, currencyId, fungible);

        // Add to staged
        balanceTracker.add(
            wallet, balanceTracker.stagedBalanceType(), value, currencyCt, currencyId, fungible
        );

        // Emit event
        emit StageEvent(wallet, value, currencyCt, currencyId, standard);
    }

    /// @notice Unstage a staged value
    /// @param value The value (amount of fungible, id of non-fungible) to deposit
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function unstage(int256 value, address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        require(value.isNonZeroPositiveInt256());

        // Deduce fungibility
        bool fungible = _isFungible(currencyCt, currencyId, standard);

        // Subtract unstage value from staged
        value = _subtractFromStaged(msg.sender, value, currencyCt, currencyId, fungible);

        // Add to deposited
        balanceTracker.add(
            msg.sender, balanceTracker.depositedBalanceType(), value, currencyCt, currencyId, fungible
        );

        // Emit event
        emit UnstageEvent(msg.sender, value, currencyCt, currencyId, standard);
    }

    /// @notice Stage the value from wallet to the given beneficiary and targeted to wallet
    /// @param wallet The address of the concerned wallet
    /// @param beneficiary The (address of) concerned beneficiary contract
    /// @param value The value (amount of fungible, id of non-fungible) to stage
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function stageToBeneficiary(address wallet, Beneficiary beneficiary, int256 value,
        address currencyCt, uint256 currencyId, string memory standard)
    public
    onlyAuthorizedService(wallet)
    {
        // Deduce fungibility
        bool fungible = _isFungible(currencyCt, currencyId, standard);

        // Subtract stage value from settled, possibly also from deposited
        value = _subtractSequentially(wallet, balanceTracker.activeBalanceTypes(), value, currencyCt, currencyId, fungible);

        // Execute transfer
        _transferToBeneficiary(wallet, beneficiary, value, currencyCt, currencyId, standard);

        // Emit event
        emit StageToBeneficiaryEvent(wallet, beneficiary, value, currencyCt, currencyId, standard);
    }

    /// @notice Transfer the given value of currency to the given beneficiary without target wallet
    /// @param wallet The address of the concerned wallet
    /// @param beneficiary The (address of) concerned beneficiary contract
    /// @param value The value (amount of fungible, id of non-fungible) to transfer
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function transferToBeneficiary(address wallet, Beneficiary beneficiary, int256 value,
        address currencyCt, uint256 currencyId, string memory standard)
    public
    onlyAuthorizedService(wallet)
    {
        // Execute transfer
        _transferToBeneficiary(wallet, beneficiary, value, currencyCt, currencyId, standard);

        // Emit event
        emit TransferToBeneficiaryEvent(wallet, beneficiary, value, currencyCt, currencyId, standard);
    }

    /// @notice Seize balances in the given currency of the given wallet, provided that the wallet
    /// is locked by the caller
    /// @param wallet The address of the concerned wallet whose balances are seized
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function seizeBalances(address wallet, address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        if (_isFungible(currencyCt, currencyId, standard))
            _seizeFungibleBalances(wallet, msg.sender, currencyCt, currencyId);

        else
            _seizeNonFungibleBalances(wallet, msg.sender, currencyCt, currencyId);

        // Add to the store of seized wallets
        if (!seizedByWallet[wallet]) {
            seizedByWallet[wallet] = true;
            seizedWallets.push(wallet);
        }
    }

    /// @notice Withdraw the given amount from staged balance
    /// @param value The value (amount of fungible, id of non-fungible) to withdraw
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function withdraw(int256 value, address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        require(value.isNonZeroPositiveInt256());

        // Require that msg.sender and currency is not locked
        require(!walletLocker.isLocked(msg.sender, currencyCt, currencyId));

        // Deduce fungibility
        bool fungible = _isFungible(currencyCt, currencyId, standard);

        // Subtract unstage value from staged
        value = _subtractFromStaged(msg.sender, value, currencyCt, currencyId, fungible);

        // Log record of this transaction
        transactionTracker.add(
            msg.sender, transactionTracker.withdrawalTransactionType(), value, currencyCt, currencyId
        );

        // Execute transfer
        _transferToWallet(msg.sender, value, currencyCt, currencyId, standard);

        // Emit event
        emit WithdrawEvent(msg.sender, value, currencyCt, currencyId, standard);
    }

    /// @notice Get the seized status of given wallet
    /// @param wallet The address of the concerned wallet
    /// @return true if wallet is seized, false otherwise
    function isSeizedWallet(address wallet)
    public
    view
    returns (bool)
    {
        return seizedByWallet[wallet];
    }

    /// @notice Get the number of wallets whose funds have been seized
    /// @return Number of wallets
    function seizedWalletsCount()
    public
    view
    returns (uint256)
    {
        return seizedWallets.length;
    }

    /// @notice Claim revenue from token holder revenue fund based on this contract's holdings of the
    /// revenue token, this so that revenue may be shared amongst revenue token holders in nahmii
    /// @param claimer The concerned address of claimer that will subsequently distribute revenue in nahmii
    /// @param balanceType The target balance type for the reception in this contract
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function claimRevenue(address claimer, string memory balanceType, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    onlyOperator
    {
        tokenHolderRevenueFund.claimAndTransferToBeneficiary(
            this, claimer, balanceType,
            currencyCt, currencyId, standard
        );

        emit ClaimRevenueEvent(claimer, balanceType, currencyCt, currencyId, standard);
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _receiveTo(address wallet, string memory balanceType, int256 value, address currencyCt,
        uint256 currencyId, bool fungible)
    private
    {
        bytes32 balanceHash = 0 < bytes(balanceType).length ?
        keccak256(abi.encodePacked(balanceType)) :
        balanceTracker.depositedBalanceType();

        // Add to per-wallet staged balance
        if (balanceTracker.stagedBalanceType() == balanceHash)
            balanceTracker.add(
                wallet, balanceTracker.stagedBalanceType(), value, currencyCt, currencyId, fungible
            );

        // Add to per-wallet deposited balance
        else if (balanceTracker.depositedBalanceType() == balanceHash) {
            balanceTracker.add(
                wallet, balanceTracker.depositedBalanceType(), value, currencyCt, currencyId, fungible
            );

            // Log record of this transaction
            transactionTracker.add(
                wallet, transactionTracker.depositTransactionType(), value, currencyCt, currencyId
            );
        }

        else
            revert();
    }

    function _subtractSequentially(address wallet, bytes32[] memory balanceTypes, int256 value, address currencyCt,
        uint256 currencyId, bool fungible)
    private
    returns (int256)
    {
        if (fungible)
            return _subtractFungibleSequentially(wallet, balanceTypes, value, currencyCt, currencyId);
        else
            return _subtractNonFungibleSequentially(wallet, balanceTypes, value, currencyCt, currencyId);
    }

    function _subtractFungibleSequentially(address wallet, bytes32[] memory balanceTypes, int256 amount, address currencyCt, uint256 currencyId)
    private
    returns (int256)
    {
        // Require positive amount
        require(0 <= amount);

        uint256 i;
        int256 totalBalanceAmount = 0;
        for (i = 0; i < balanceTypes.length; i++)
            totalBalanceAmount = totalBalanceAmount.add(
                balanceTracker.get(
                    wallet, balanceTypes[i], currencyCt, currencyId
                )
            );

        // Clamp amount to stage
        amount = amount.clampMax(totalBalanceAmount);

        int256 _amount = amount;
        for (i = 0; i < balanceTypes.length; i++) {
            int256 typeAmount = balanceTracker.get(
                wallet, balanceTypes[i], currencyCt, currencyId
            );

            if (typeAmount >= _amount) {
                balanceTracker.sub(
                    wallet, balanceTypes[i], _amount, currencyCt, currencyId, true
                );
                break;

            } else {
                balanceTracker.set(
                    wallet, balanceTypes[i], 0, currencyCt, currencyId, true
                );
                _amount = _amount.sub(typeAmount);
            }
        }

        return amount;
    }

    function _subtractNonFungibleSequentially(address wallet, bytes32[] memory balanceTypes, int256 id, address currencyCt, uint256 currencyId)
    private
    returns (int256)
    {
        for (uint256 i = 0; i < balanceTypes.length; i++)
            if (balanceTracker.hasId(wallet, balanceTypes[i], id, currencyCt, currencyId)) {
                balanceTracker.sub(wallet, balanceTypes[i], id, currencyCt, currencyId, false);
                break;
            }

        return id;
    }

    function _subtractFromStaged(address wallet, int256 value, address currencyCt, uint256 currencyId, bool fungible)
    private
    returns (int256)
    {
        if (fungible) {
            // Clamp value to unstage
            value = value.clampMax(
                balanceTracker.get(wallet, balanceTracker.stagedBalanceType(), currencyCt, currencyId)
            );

            // Require positive value
            require(0 <= value);

        } else {
            // Require that value is included in staged balance
            require(balanceTracker.hasId(wallet, balanceTracker.stagedBalanceType(), value, currencyCt, currencyId));
        }

        // Subtract from deposited balance
        balanceTracker.sub(wallet, balanceTracker.stagedBalanceType(), value, currencyCt, currencyId, fungible);

        return value;
    }

    function _transferToBeneficiary(address destWallet, Beneficiary beneficiary,
        int256 value, address currencyCt, uint256 currencyId, string memory standard)
    private
    {
        require(value.isNonZeroPositiveInt256());
        require(isRegisteredBeneficiary(beneficiary));

        // Transfer funds to the beneficiary
        if (address(0) == currencyCt && 0 == currencyId)
            beneficiary.receiveEthersTo.value(uint256(value))(destWallet, "");

        else {
            // Get transfer controller
            TransferController controller = transferController(currencyCt, standard);

            // Approve of beneficiary
            (bool success,) = address(controller).delegatecall(
                abi.encodeWithSelector(
                    controller.getApproveSignature(), address(beneficiary), uint256(value), currencyCt, currencyId
                )
            );
            require(success);

            // Transfer funds to the beneficiary
            beneficiary.receiveTokensTo(destWallet, "", value, currencyCt, currencyId, controller.standard());
        }
    }

    function _transferToWallet(address payable wallet,
        int256 value, address currencyCt, uint256 currencyId, string memory standard)
    private
    {
        // Transfer ETH
        if (address(0) == currencyCt && 0 == currencyId)
            wallet.transfer(uint256(value));

        else {
            // Get transfer controller
            TransferController controller = transferController(currencyCt, standard);

            // Transfer token
            (bool success,) = address(controller).delegatecall(
                abi.encodeWithSelector(
                    controller.getDispatchSignature(), address(this), wallet, uint256(value), currencyCt, currencyId
                )
            );
            require(success);
        }
    }

    function _seizeFungibleBalances(address lockedWallet, address lockerWallet, address currencyCt,
        uint256 currencyId)
    private
    {
        // Get the locked amount
        int256 amount = walletLocker.lockedAmount(lockedWallet, lockerWallet, currencyCt, currencyId);

        // Require that locked amount is strictly positive
        require(amount > 0);

        // Subtract stage value from settled, possibly also from deposited
        _subtractFungibleSequentially(lockedWallet, balanceTracker.allBalanceTypes(), amount, currencyCt, currencyId);

        // Add to staged balance of sender
        balanceTracker.add(
            lockerWallet, balanceTracker.stagedBalanceType(), amount, currencyCt, currencyId, true
        );

        // Emit event
        emit SeizeBalancesEvent(lockedWallet, lockerWallet, amount, currencyCt, currencyId);
    }

    function _seizeNonFungibleBalances(address lockedWallet, address lockerWallet, address currencyCt,
        uint256 currencyId)
    private
    {
        // Require that locked ids has entries
        uint256 lockedIdsCount = walletLocker.lockedIdsCount(lockedWallet, lockerWallet, currencyCt, currencyId);
        require(0 < lockedIdsCount);

        // Get the locked amount
        int256[] memory ids = walletLocker.lockedIdsByIndices(
            lockedWallet, lockerWallet, currencyCt, currencyId, 0, lockedIdsCount - 1
        );

        for (uint256 i = 0; i < ids.length; i++) {
            // Subtract from settled, possibly also from deposited
            _subtractNonFungibleSequentially(lockedWallet, balanceTracker.allBalanceTypes(), ids[i], currencyCt, currencyId);

            // Add to staged balance of sender
            balanceTracker.add(
                lockerWallet, balanceTracker.stagedBalanceType(), ids[i], currencyCt, currencyId, false
            );

            // Emit event
            emit SeizeBalancesEvent(lockedWallet, lockerWallet, ids[i], currencyCt, currencyId);
        }
    }

    function _isFungible(address currencyCt, uint256 currencyId, string memory standard)
    private
    view
    returns (bool)
    {
        return (address(0) == currencyCt && 0 == currencyId) || transferController(currencyCt, standard).isFungible();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title ClientFundable
 * @notice An ownable that has a client fund property
 */
contract ClientFundable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    ClientFund public clientFund;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetClientFundEvent(ClientFund oldClientFund, ClientFund newClientFund);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the client fund contract
    /// @param newClientFund The (address of) ClientFund contract instance
    function setClientFund(ClientFund newClientFund) public
    onlyDeployer
    notNullAddress(address(newClientFund))
    notSameAddresses(address(newClientFund), address(clientFund))
    {
        // Update field
        ClientFund oldClientFund = clientFund;
        clientFund = newClientFund;

        // Emit event
        emit SetClientFundEvent(oldClientFund, newClientFund);
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier clientFundInitialized() {
        require(address(clientFund) != address(0), "Client fund not initialized [ClientFundable.sol:51]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title Community vote
 * @notice An oracle for relevant decisions made by the community.
 */
contract CommunityVote is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    mapping(address => bool) doubleSpenderByWallet;
    uint256 maxDriipNonce;
    uint256 maxNullNonce;
    bool dataAvailable;

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
        dataAvailable = true;
    }

    //
    // Results functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Get the double spender status of given wallet
    /// @param wallet The wallet address for which to check double spender status
    /// @return true if wallet is double spender, false otherwise
    function isDoubleSpenderWallet(address wallet)
    public
    view
    returns (bool)
    {
        return doubleSpenderByWallet[wallet];
    }

    /// @notice Get the max driip nonce to be accepted in settlements
    /// @return the max driip nonce
    function getMaxDriipNonce()
    public
    view
    returns (uint256)
    {
        return maxDriipNonce;
    }

    /// @notice Get the max null settlement nonce to be accepted in settlements
    /// @return the max driip nonce
    function getMaxNullNonce()
    public
    view
    returns (uint256)
    {
        return maxNullNonce;
    }

    /// @notice Get the data availability status
    /// @return true if data is available
    function isDataAvailable()
    public
    view
    returns (bool)
    {
        return dataAvailable;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title CommunityVotable
 * @notice An ownable that has a community vote property
 */
contract CommunityVotable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    CommunityVote public communityVote;
    bool public communityVoteFrozen;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetCommunityVoteEvent(CommunityVote oldCommunityVote, CommunityVote newCommunityVote);
    event FreezeCommunityVoteEvent();

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the community vote contract
    /// @param newCommunityVote The (address of) CommunityVote contract instance
    function setCommunityVote(CommunityVote newCommunityVote) 
    public 
    onlyDeployer
    notNullAddress(address(newCommunityVote))
    notSameAddresses(address(newCommunityVote), address(communityVote))
    {
        require(!communityVoteFrozen, "Community vote frozen [CommunityVotable.sol:41]");

        // Set new community vote
        CommunityVote oldCommunityVote = communityVote;
        communityVote = newCommunityVote;

        // Emit event
        emit SetCommunityVoteEvent(oldCommunityVote, newCommunityVote);
    }

    /// @notice Freeze the community vote from further updates
    /// @dev This operation can not be undone
    function freezeCommunityVote()
    public
    onlyDeployer
    {
        communityVoteFrozen = true;

        // Emit event
        emit FreezeCommunityVoteEvent();
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier communityVoteInitialized() {
        require(address(communityVote) != address(0), "Community vote not initialized [CommunityVotable.sol:67]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title FraudChallenge
 * @notice Where fraud challenge results are found
 */
contract FraudChallenge is Ownable, Servable {
    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    string constant public ADD_SEIZED_WALLET_ACTION = "add_seized_wallet";
    string constant public ADD_DOUBLE_SPENDER_WALLET_ACTION = "add_double_spender_wallet";
    string constant public ADD_FRAUDULENT_ORDER_ACTION = "add_fraudulent_order";
    string constant public ADD_FRAUDULENT_TRADE_ACTION = "add_fraudulent_trade";
    string constant public ADD_FRAUDULENT_PAYMENT_ACTION = "add_fraudulent_payment";

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    address[] public doubleSpenderWallets;
    mapping(address => bool) public doubleSpenderByWallet;

    bytes32[] public fraudulentOrderHashes;
    mapping(bytes32 => bool) public fraudulentByOrderHash;

    bytes32[] public fraudulentTradeHashes;
    mapping(bytes32 => bool) public fraudulentByTradeHash;

    bytes32[] public fraudulentPaymentHashes;
    mapping(bytes32 => bool) public fraudulentByPaymentHash;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event AddDoubleSpenderWalletEvent(address wallet);
    event AddFraudulentOrderHashEvent(bytes32 hash);
    event AddFraudulentTradeHashEvent(bytes32 hash);
    event AddFraudulentPaymentHashEvent(bytes32 hash);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Get the double spender status of given wallet
    /// @param wallet The wallet address for which to check double spender status
    /// @return true if wallet is double spender, false otherwise
    function isDoubleSpenderWallet(address wallet)
    public
    view
    returns (bool)
    {
        return doubleSpenderByWallet[wallet];
    }

    /// @notice Get the number of wallets tagged as double spenders
    /// @return Number of double spender wallets
    function doubleSpenderWalletsCount()
    public
    view
    returns (uint256)
    {
        return doubleSpenderWallets.length;
    }

    /// @notice Add given wallets to store of double spender wallets if not already present
    /// @param wallet The first wallet to add
    function addDoubleSpenderWallet(address wallet)
    public
    onlyEnabledServiceAction(ADD_DOUBLE_SPENDER_WALLET_ACTION) {
        if (!doubleSpenderByWallet[wallet]) {
            doubleSpenderWallets.push(wallet);
            doubleSpenderByWallet[wallet] = true;
            emit AddDoubleSpenderWalletEvent(wallet);
        }
    }

    /// @notice Get the number of fraudulent order hashes
    function fraudulentOrderHashesCount()
    public
    view
    returns (uint256)
    {
        return fraudulentOrderHashes.length;
    }

    /// @notice Get the state about whether the given hash equals the hash of a fraudulent order
    /// @param hash The hash to be tested
    function isFraudulentOrderHash(bytes32 hash)
    public
    view returns (bool) {
        return fraudulentByOrderHash[hash];
    }

    /// @notice Add given order hash to store of fraudulent order hashes if not already present
    function addFraudulentOrderHash(bytes32 hash)
    public
    onlyEnabledServiceAction(ADD_FRAUDULENT_ORDER_ACTION)
    {
        if (!fraudulentByOrderHash[hash]) {
            fraudulentByOrderHash[hash] = true;
            fraudulentOrderHashes.push(hash);
            emit AddFraudulentOrderHashEvent(hash);
        }
    }

    /// @notice Get the number of fraudulent trade hashes
    function fraudulentTradeHashesCount()
    public
    view
    returns (uint256)
    {
        return fraudulentTradeHashes.length;
    }

    /// @notice Get the state about whether the given hash equals the hash of a fraudulent trade
    /// @param hash The hash to be tested
    /// @return true if hash is the one of a fraudulent trade, else false
    function isFraudulentTradeHash(bytes32 hash)
    public
    view
    returns (bool)
    {
        return fraudulentByTradeHash[hash];
    }

    /// @notice Add given trade hash to store of fraudulent trade hashes if not already present
    function addFraudulentTradeHash(bytes32 hash)
    public
    onlyEnabledServiceAction(ADD_FRAUDULENT_TRADE_ACTION)
    {
        if (!fraudulentByTradeHash[hash]) {
            fraudulentByTradeHash[hash] = true;
            fraudulentTradeHashes.push(hash);
            emit AddFraudulentTradeHashEvent(hash);
        }
    }

    /// @notice Get the number of fraudulent payment hashes
    function fraudulentPaymentHashesCount()
    public
    view
    returns (uint256)
    {
        return fraudulentPaymentHashes.length;
    }

    /// @notice Get the state about whether the given hash equals the hash of a fraudulent payment
    /// @param hash The hash to be tested
    /// @return true if hash is the one of a fraudulent payment, else null
    function isFraudulentPaymentHash(bytes32 hash)
    public
    view
    returns (bool)
    {
        return fraudulentByPaymentHash[hash];
    }

    /// @notice Add given payment hash to store of fraudulent payment hashes if not already present
    function addFraudulentPaymentHash(bytes32 hash)
    public
    onlyEnabledServiceAction(ADD_FRAUDULENT_PAYMENT_ACTION)
    {
        if (!fraudulentByPaymentHash[hash]) {
            fraudulentByPaymentHash[hash] = true;
            fraudulentPaymentHashes.push(hash);
            emit AddFraudulentPaymentHashEvent(hash);
        }
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title FraudChallengable
 * @notice An ownable that has a fraud challenge property
 */
contract FraudChallengable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    FraudChallenge public fraudChallenge;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetFraudChallengeEvent(FraudChallenge oldFraudChallenge, FraudChallenge newFraudChallenge);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the fraud challenge contract
    /// @param newFraudChallenge The (address of) FraudChallenge contract instance
    function setFraudChallenge(FraudChallenge newFraudChallenge)
    public
    onlyDeployer
    notNullAddress(address(newFraudChallenge))
    notSameAddresses(address(newFraudChallenge), address(fraudChallenge))
    {
        // Set new fraud challenge
        FraudChallenge oldFraudChallenge = fraudChallenge;
        fraudChallenge = newFraudChallenge;

        // Emit event
        emit SetFraudChallengeEvent(oldFraudChallenge, newFraudChallenge);
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier fraudChallengeInitialized() {
        require(address(fraudChallenge) != address(0), "Fraud challenge not initialized [FraudChallengable.sol:52]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title PartnerBenefactor
 * @notice A benefactor/manager of registered partners
 */
contract PartnerBenefactor is Ownable, Benefactor {
    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) Benefactor()
    public
    {
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title PartnerBenefactorable
 * @notice An ownable that has a partner benefactor property
 */
contract PartnerBenefactorable is Ownable {
    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    PartnerBenefactor public partnerBenefactor;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SetPartnerBenefactorEvent(PartnerBenefactor oldPartnerBenefactor, PartnerBenefactor newPartnerBenefactor);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the partner benefactor contract
    /// @param newPartnerBenefactor The (address of) PartnerBenefactor contract instance
    function setPartnerBenefactor(PartnerBenefactor newPartnerBenefactor)
    public
    onlyDeployer
    notNullAddress(address(newPartnerBenefactor))
    notSameAddresses(address(newPartnerBenefactor), address(partnerBenefactor))
    {
        // Set new partner benefactor
        PartnerBenefactor oldPartnerBenefactor = partnerBenefactor;
        partnerBenefactor = newPartnerBenefactor;

        // Emit event
        emit SetPartnerBenefactorEvent(oldPartnerBenefactor, newPartnerBenefactor);
    }

    //
    // Modifiers
    // -----------------------------------------------------------------------------------------------------------------
    modifier partnerBenefactorInitialized() {
        require(address(partnerBenefactor) != address(0), "Partner benefactor not initialized [PartnerBenefactorable.sol:52]");
        _;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title AccrualBenefactor
 * @notice A benefactor whose registered beneficiaries obtain a predefined fraction of total amount
 */
contract AccrualBenefactor is Benefactor {
    using SafeMathIntLib for int256;

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    mapping(address => int256) private _beneficiaryFractionMap;
    int256 public totalBeneficiaryFraction;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event RegisterAccrualBeneficiaryEvent(Beneficiary beneficiary, int256 fraction);
    event DeregisterAccrualBeneficiaryEvent(Beneficiary beneficiary);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Register the given accrual beneficiary for the entirety fraction
    /// @param beneficiary Address of accrual beneficiary to be registered
    function registerBeneficiary(Beneficiary beneficiary)
    public
    onlyDeployer
    notNullAddress(address(beneficiary))
    returns (bool)
    {
        return registerFractionalBeneficiary(AccrualBeneficiary(address(beneficiary)), ConstantsLib.PARTS_PER());
    }

    /// @notice Register the given accrual beneficiary for the given fraction
    /// @param beneficiary Address of accrual beneficiary to be registered
    /// @param fraction Fraction of benefits to be given
    function registerFractionalBeneficiary(AccrualBeneficiary beneficiary, int256 fraction)
    public
    onlyDeployer
    notNullAddress(address(beneficiary))
    returns (bool)
    {
        require(fraction > 0, "Fraction not strictly positive [AccrualBenefactor.sol:59]");
        require(
            totalBeneficiaryFraction.add(fraction) <= ConstantsLib.PARTS_PER(),
            "Total beneficiary fraction out of bounds [AccrualBenefactor.sol:60]"
        );

        if (!super.registerBeneficiary(beneficiary))
            return false;

        _beneficiaryFractionMap[address(beneficiary)] = fraction;
        totalBeneficiaryFraction = totalBeneficiaryFraction.add(fraction);

        // Emit event
        emit RegisterAccrualBeneficiaryEvent(beneficiary, fraction);

        return true;
    }

    /// @notice Deregister the given accrual beneficiary
    /// @param beneficiary Address of accrual beneficiary to be deregistered
    function deregisterBeneficiary(Beneficiary beneficiary)
    public
    onlyDeployer
    notNullAddress(address(beneficiary))
    returns (bool)
    {
        if (!super.deregisterBeneficiary(beneficiary))
            return false;

        address _beneficiary = address(beneficiary);

        totalBeneficiaryFraction = totalBeneficiaryFraction.sub(_beneficiaryFractionMap[_beneficiary]);
        _beneficiaryFractionMap[_beneficiary] = 0;

        // Emit event
        emit DeregisterAccrualBeneficiaryEvent(beneficiary);

        return true;
    }

    /// @notice Get the fraction of benefits that is granted the given accrual beneficiary
    /// @param beneficiary Address of accrual beneficiary
    /// @return The beneficiary's fraction
    function beneficiaryFraction(AccrualBeneficiary beneficiary)
    public
    view
    returns (int256)
    {
        return _beneficiaryFractionMap[address(beneficiary)];
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title RevenueFund
 * @notice The target of all revenue earned in driip settlements and from which accrued revenue is split amongst
 *   accrual beneficiaries.
 */
contract RevenueFund is Ownable, AccrualBeneficiary, AccrualBenefactor, TransferControllerManageable {
    using FungibleBalanceLib for FungibleBalanceLib.Balance;
    using TxHistoryLib for TxHistoryLib.TxHistory;
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using CurrenciesLib for CurrenciesLib.Currencies;

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    FungibleBalanceLib.Balance periodAccrual;
    CurrenciesLib.Currencies periodCurrencies;

    FungibleBalanceLib.Balance aggregateAccrual;
    CurrenciesLib.Currencies aggregateCurrencies;

    TxHistoryLib.TxHistory private txHistory;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event ReceiveEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event CloseAccrualPeriodEvent();
    event RegisterServiceEvent(address service);
    event DeregisterServiceEvent(address service);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Fallback function that deposits ethers
    function() external payable {
        receiveEthersTo(msg.sender, "");
    }

    /// @notice Receive ethers to
    /// @param wallet The concerned wallet address
    function receiveEthersTo(address wallet, string memory)
    public
    payable
    {
        int256 amount = SafeMathIntLib.toNonZeroInt256(msg.value);

        // Add to balances
        periodAccrual.add(amount, address(0), 0);
        aggregateAccrual.add(amount, address(0), 0);

        // Add currency to stores of currencies
        periodCurrencies.add(address(0), 0);
        aggregateCurrencies.add(address(0), 0);

        // Add to transaction history
        txHistory.addDeposit(amount, address(0), 0);

        // Emit event
        emit ReceiveEvent(wallet, amount, address(0), 0);
    }

    /// @notice Receive tokens
    /// @param amount The concerned amount
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of token ("ERC20", "ERC721")
    function receiveTokens(string memory balanceType, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        receiveTokensTo(msg.sender, balanceType, amount, currencyCt, currencyId, standard);
    }

    /// @notice Receive tokens to
    /// @param wallet The address of the concerned wallet
    /// @param amount The concerned amount
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of token ("ERC20", "ERC721")
    function receiveTokensTo(address wallet, string memory, int256 amount,
        address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        require(amount.isNonZeroPositiveInt256(), "Amount not strictly positive [RevenueFund.sol:115]");

        // Execute transfer
        TransferController controller = transferController(currencyCt, standard);
        (bool success,) = address(controller).delegatecall(
            abi.encodeWithSelector(
                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId
            )
        );
        require(success, "Reception by controller failed [RevenueFund.sol:124]");

        // Add to balances
        periodAccrual.add(amount, currencyCt, currencyId);
        aggregateAccrual.add(amount, currencyCt, currencyId);

        // Add currency to stores of currencies
        periodCurrencies.add(currencyCt, currencyId);
        aggregateCurrencies.add(currencyCt, currencyId);

        // Add to transaction history
        txHistory.addDeposit(amount, currencyCt, currencyId);

        // Emit event
        emit ReceiveEvent(wallet, amount, currencyCt, currencyId);
    }

    /// @notice Get the period accrual balance of the given currency
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The current period's accrual balance
    function periodAccrualBalance(address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return periodAccrual.get(currencyCt, currencyId);
    }

    /// @notice Get the aggregate accrual balance of the given currency, including contribution from the
    /// current accrual period
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @return The aggregate accrual balance
    function aggregateAccrualBalance(address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        return aggregateAccrual.get(currencyCt, currencyId);
    }

    /// @notice Get the count of currencies recorded in the accrual period
    /// @return The number of currencies in the current accrual period
    function periodCurrenciesCount()
    public
    view
    returns (uint256)
    {
        return periodCurrencies.count();
    }

    /// @notice Get the currencies with indices in the given range that have been recorded in the current accrual period
    /// @param low The lower currency index
    /// @param up The upper currency index
    /// @return The currencies of the given index range in the current accrual period
    function periodCurrenciesByIndices(uint256 low, uint256 up)
    public
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        return periodCurrencies.getByIndices(low, up);
    }

    /// @notice Get the count of currencies ever recorded
    /// @return The number of currencies ever recorded
    function aggregateCurrenciesCount()
    public
    view
    returns (uint256)
    {
        return aggregateCurrencies.count();
    }

    /// @notice Get the currencies with indices in the given range that have ever been recorded
    /// @param low The lower currency index
    /// @param up The upper currency index
    /// @return The currencies of the given index range ever recorded
    function aggregateCurrenciesByIndices(uint256 low, uint256 up)
    public
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        return aggregateCurrencies.getByIndices(low, up);
    }

    /// @notice Get the count of deposits
    /// @return The count of deposits
    function depositsCount()
    public
    view
    returns (uint256)
    {
        return txHistory.depositsCount();
    }

    /// @notice Get the deposit at the given index
    /// @return The deposit at the given index
    function deposit(uint index)
    public
    view
    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        return txHistory.deposit(index);
    }

    /// @notice Close the current accrual period of the given currencies
    /// @param currencies The concerned currencies
    function closeAccrualPeriod(MonetaryTypesLib.Currency[] memory currencies)
    public
    onlyOperator
    {
        require(
            ConstantsLib.PARTS_PER() == totalBeneficiaryFraction,
            "Total beneficiary fraction out of bounds [RevenueFund.sol:236]"
        );

        // Execute transfer
        for (uint256 i = 0; i < currencies.length; i++) {
            MonetaryTypesLib.Currency memory currency = currencies[i];

            int256 remaining = periodAccrual.get(currency.ct, currency.id);

            if (0 >= remaining)
                continue;

            for (uint256 j = 0; j < beneficiaries.length; j++) {
                AccrualBeneficiary beneficiary = AccrualBeneficiary(address(beneficiaries[j]));

                if (beneficiaryFraction(beneficiary) > 0) {
                    int256 transferable = periodAccrual.get(currency.ct, currency.id)
                    .mul(beneficiaryFraction(beneficiary))
                    .div(ConstantsLib.PARTS_PER());

                    if (transferable > remaining)
                        transferable = remaining;

                    if (transferable > 0) {
                        // Transfer ETH to the beneficiary
                        if (currency.ct == address(0))
                            beneficiary.receiveEthersTo.value(uint256(transferable))(address(0), "");

                        // Transfer token to the beneficiary
                        else {
                            TransferController controller = transferController(currency.ct, "");
                            (bool success,) = address(controller).delegatecall(
                                abi.encodeWithSelector(
                                    controller.getApproveSignature(), address(beneficiary), uint256(transferable), currency.ct, currency.id
                                )
                            );
                            require(success, "Approval by controller failed [RevenueFund.sol:274]");

                            beneficiary.receiveTokensTo(address(0), "", transferable, currency.ct, currency.id, "");
                        }

                        remaining = remaining.sub(transferable);
                    }
                }
            }

            // Roll over remaining to next accrual period
            periodAccrual.set(remaining, currency.ct, currency.id);
        }

        // Close accrual period of accrual beneficiaries
        for (uint256 j = 0; j < beneficiaries.length; j++) {
            AccrualBeneficiary beneficiary = AccrualBeneficiary(address(beneficiaries[j]));

            // Require that beneficiary fraction is strictly positive
            if (0 >= beneficiaryFraction(beneficiary))
                continue;

            // Close accrual period
            beneficiary.closeAccrualPeriod(currencies);
        }

        // Emit event
        emit CloseAccrualPeriodEvent();
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title     SettlementChallengeTypesLib
 * @dev       Types for settlement challenges
 */
library SettlementChallengeTypesLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    enum Status {Qualified, Disqualified}

    struct Proposal {
        address wallet;
        uint256 nonce;
        uint256 referenceBlockNumber;
        uint256 definitionBlockNumber;

        uint256 expirationTime;

        // Status
        Status status;

        // Amounts
        Amounts amounts;

        // Currency
        MonetaryTypesLib.Currency currency;

        // Info on challenged driip
        Driip challenged;

        // True is equivalent to reward coming from wallet's balance
        bool walletInitiated;

        // True if proposal has been terminated
        bool terminated;

        // Disqualification
        Disqualification disqualification;
    }

    struct Amounts {
        // Cumulative (relative) transfer info
        int256 cumulativeTransfer;

        // Stage info
        int256 stage;

        // Balances after amounts have been staged
        int256 targetBalance;
    }

    struct Driip {
        // Kind ("payment", "trade", ...)
        string kind;

        // Hash (of operator)
        bytes32 hash;
    }

    struct Disqualification {
        // Challenger
        address challenger;
        uint256 nonce;
        uint256 blockNumber;

        // Info on candidate driip
        Driip candidate;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title DriipSettlementChallengeState
 * @notice Where driip settlement challenge state is managed
 */
contract DriipSettlementChallengeState is Ownable, Servable, Configurable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;

    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    string constant public INITIATE_PROPOSAL_ACTION = "initiate_proposal";
    string constant public TERMINATE_PROPOSAL_ACTION = "terminate_proposal";
    string constant public REMOVE_PROPOSAL_ACTION = "remove_proposal";
    string constant public DISQUALIFY_PROPOSAL_ACTION = "disqualify_proposal";
    string constant public QUALIFY_PROPOSAL_ACTION = "qualify_proposal";

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    SettlementChallengeTypesLib.Proposal[] public proposals;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public proposalIndexByWalletCurrency;
    mapping(address => mapping(uint256 => mapping(address => mapping(uint256 => uint256)))) public proposalIndexByWalletNonceCurrency;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event InitiateProposalEvent(address wallet, uint256 nonce, int256 cumulativeTransferAmount, int256 stageAmount,
        int256 targetBalanceAmount, MonetaryTypesLib.Currency currency, uint256 blockNumber, bool walletInitiated,
        bytes32 challengedHash, string challengedKind);
    event TerminateProposalEvent(address wallet, uint256 nonce, int256 cumulativeTransferAmount, int256 stageAmount,
        int256 targetBalanceAmount, MonetaryTypesLib.Currency currency, uint256 blockNumber, bool walletInitiated,
        bytes32 challengedHash, string challengedKind);
    event RemoveProposalEvent(address wallet, uint256 nonce, int256 cumulativeTransferAmount, int256 stageAmount,
        int256 targetBalanceAmount, MonetaryTypesLib.Currency currency, uint256 blockNumber, bool walletInitiated,
        bytes32 challengedHash, string challengedKind);
    event DisqualifyProposalEvent(address challengedWallet, uint256 challengedNonce, int256 cumulativeTransferAmount,
        int256 stageAmount, int256 targetBalanceAmount, MonetaryTypesLib.Currency currency, uint256 blockNumber,
        bool walletInitiated, address challengerWallet, uint256 candidateNonce, bytes32 candidateHash,
        string candidateKind);
    event QualifyProposalEvent(address challengedWallet, uint256 challengedNonce, int256 cumulativeTransferAmount,
        int256 stageAmount, int256 targetBalanceAmount, MonetaryTypesLib.Currency currency, uint256 blockNumber,
        bool walletInitiated, address challengerWallet, uint256 candidateNonce, bytes32 candidateHash,
        string candidateKind);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Get the number of proposals
    /// @return The number of proposals
    function proposalsCount()
    public
    view
    returns (uint256)
    {
        return proposals.length;
    }

    /// @notice Initiate proposal
    /// @param wallet The address of the concerned challenged wallet
    /// @param nonce The wallet nonce
    /// @param cumulativeTransferAmount The proposal cumulative transfer amount
    /// @param stageAmount The proposal stage amount
    /// @param targetBalanceAmount The proposal target balance amount
    /// @param currency The concerned currency
    /// @param blockNumber The proposal block number
    /// @param walletInitiated True if reward from candidate balance
    /// @param challengedHash The candidate driip hash
    /// @param challengedKind The candidate driip kind
    function initiateProposal(address wallet, uint256 nonce, int256 cumulativeTransferAmount, int256 stageAmount,
        int256 targetBalanceAmount, MonetaryTypesLib.Currency memory currency, uint256 blockNumber, bool walletInitiated,
        bytes32 challengedHash, string memory challengedKind)
    public
    onlyEnabledServiceAction(INITIATE_PROPOSAL_ACTION)
    {
        // Initiate proposal
        _initiateProposal(
            wallet, nonce, cumulativeTransferAmount, stageAmount, targetBalanceAmount,
            currency, blockNumber, walletInitiated, challengedHash, challengedKind
        );

        // Emit event
        emit InitiateProposalEvent(
            wallet, nonce, cumulativeTransferAmount, stageAmount, targetBalanceAmount, currency,
            blockNumber, walletInitiated, challengedHash, challengedKind
        );
    }

    /// @notice Terminate a proposal
    /// @param wallet The address of the concerned challenged wallet
    /// @param currency The concerned currency
    function terminateProposal(address wallet, MonetaryTypesLib.Currency memory currency, bool clearNonce)
    public
    onlyEnabledServiceAction(TERMINATE_PROPOSAL_ACTION)
    {
        // Get the proposal index
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];

        // Return gracefully if there is no proposal to terminate
        if (0 == index)
            return;

        // Clear wallet-nonce-currency triplet entry, which enables reinitiation of proposal for that triplet
        if (clearNonce)
            proposalIndexByWalletNonceCurrency[wallet][proposals[index - 1].nonce][currency.ct][currency.id] = 0;

        // Terminate proposal
        proposals[index - 1].terminated = true;

        // Emit event
        emit TerminateProposalEvent(
            wallet, proposals[index - 1].nonce, proposals[index - 1].amounts.cumulativeTransfer,
            proposals[index - 1].amounts.stage, proposals[index - 1].amounts.targetBalance, currency,
            proposals[index - 1].referenceBlockNumber, proposals[index - 1].walletInitiated,
            proposals[index - 1].challenged.hash, proposals[index - 1].challenged.kind
        );
    }

    /// @notice Terminate a proposal
    /// @param wallet The address of the concerned challenged wallet
    /// @param currency The concerned currency
    /// @param clearNonce Clear wallet-nonce-currency triplet entry
    /// @param walletTerminated True if wallet terminated
    function terminateProposal(address wallet, MonetaryTypesLib.Currency memory currency, bool clearNonce,
        bool walletTerminated)
    public
    onlyEnabledServiceAction(TERMINATE_PROPOSAL_ACTION)
    {
        // Get the proposal index
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];

        // Return gracefully if there is no proposal to terminate
        if (0 == index)
            return;

        // Require that role that initialized (wallet or operator) can only cancel its own proposal
        require(walletTerminated == proposals[index - 1].walletInitiated, "Wallet initiation and termination mismatch [DriipSettlementChallengeState.sol:163]");

        // Clear wallet-nonce-currency triplet entry, which enables reinitiation of proposal for that triplet
        if (clearNonce)
            proposalIndexByWalletNonceCurrency[wallet][proposals[index - 1].nonce][currency.ct][currency.id] = 0;

        // Terminate proposal
        proposals[index - 1].terminated = true;

        // Emit event
        emit TerminateProposalEvent(
            wallet, proposals[index - 1].nonce, proposals[index - 1].amounts.cumulativeTransfer,
            proposals[index - 1].amounts.stage, proposals[index - 1].amounts.targetBalance, currency,
            proposals[index - 1].referenceBlockNumber, proposals[index - 1].walletInitiated,
            proposals[index - 1].challenged.hash, proposals[index - 1].challenged.kind
        );
    }

    /// @notice Remove a proposal
    /// @param wallet The address of the concerned challenged wallet
    /// @param currency The concerned currency
    function removeProposal(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    onlyEnabledServiceAction(REMOVE_PROPOSAL_ACTION)
    {
        // Get the proposal index
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];

        // Return gracefully if there is no proposal to remove
        if (0 == index)
            return;

        // Emit event
        emit RemoveProposalEvent(
            wallet, proposals[index - 1].nonce, proposals[index - 1].amounts.cumulativeTransfer,
            proposals[index - 1].amounts.stage, proposals[index - 1].amounts.targetBalance, currency,
            proposals[index - 1].referenceBlockNumber, proposals[index - 1].walletInitiated,
            proposals[index - 1].challenged.hash, proposals[index - 1].challenged.kind
        );

        // Remove proposal
        _removeProposal(index);
    }

    /// @notice Remove a proposal
    /// @param wallet The address of the concerned challenged wallet
    /// @param currency The concerned currency
    /// @param walletTerminated True if wallet terminated
    function removeProposal(address wallet, MonetaryTypesLib.Currency memory currency, bool walletTerminated)
    public
    onlyEnabledServiceAction(REMOVE_PROPOSAL_ACTION)
    {
        // Get the proposal index
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];

        // Return gracefully if there is no proposal to remove
        if (0 == index)
            return;

        // Require that role that initialized (wallet or operator) can only cancel its own proposal
        require(walletTerminated == proposals[index - 1].walletInitiated, "Wallet initiation and termination mismatch [DriipSettlementChallengeState.sol:223]");

        // Emit event
        emit RemoveProposalEvent(
            wallet, proposals[index - 1].nonce, proposals[index - 1].amounts.cumulativeTransfer,
            proposals[index - 1].amounts.stage, proposals[index - 1].amounts.targetBalance, currency,
            proposals[index - 1].referenceBlockNumber, proposals[index - 1].walletInitiated,
            proposals[index - 1].challenged.hash, proposals[index - 1].challenged.kind
        );

        // Remove proposal
        _removeProposal(index);
    }

    /// @notice Disqualify a proposal
    /// @dev A call to this function will intentionally override previous disqualifications if existent
    /// @param challengedWallet The address of the concerned challenged wallet
    /// @param currency The concerned currency
    /// @param challengerWallet The address of the concerned challenger wallet
    /// @param blockNumber The disqualification block number
    /// @param candidateNonce The candidate nonce
    /// @param candidateHash The candidate hash
    /// @param candidateKind The candidate kind
    function disqualifyProposal(address challengedWallet, MonetaryTypesLib.Currency memory currency, address challengerWallet,
        uint256 blockNumber, uint256 candidateNonce, bytes32 candidateHash, string memory candidateKind)
    public
    onlyEnabledServiceAction(DISQUALIFY_PROPOSAL_ACTION)
    {
        // Get the proposal index
        uint256 index = proposalIndexByWalletCurrency[challengedWallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:253]");

        // Update proposal
        proposals[index - 1].status = SettlementChallengeTypesLib.Status.Disqualified;
        proposals[index - 1].expirationTime = block.timestamp.add(configuration.settlementChallengeTimeout());
        proposals[index - 1].disqualification.challenger = challengerWallet;
        proposals[index - 1].disqualification.nonce = candidateNonce;
        proposals[index - 1].disqualification.blockNumber = blockNumber;
        proposals[index - 1].disqualification.candidate.hash = candidateHash;
        proposals[index - 1].disqualification.candidate.kind = candidateKind;

        // Emit event
        emit DisqualifyProposalEvent(
            challengedWallet, proposals[index - 1].nonce, proposals[index - 1].amounts.cumulativeTransfer,
            proposals[index - 1].amounts.stage, proposals[index - 1].amounts.targetBalance,
            currency, proposals[index - 1].referenceBlockNumber, proposals[index - 1].walletInitiated,
            challengerWallet, candidateNonce, candidateHash, candidateKind
        );
    }

    /// @notice (Re)Qualify a proposal
    /// @param wallet The address of the concerned challenged wallet
    /// @param currency The concerned currency
    function qualifyProposal(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    onlyEnabledServiceAction(QUALIFY_PROPOSAL_ACTION)
    {
        // Get the proposal index
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:282]");

        // Emit event
        emit QualifyProposalEvent(
            wallet, proposals[index - 1].nonce, proposals[index - 1].amounts.cumulativeTransfer,
            proposals[index - 1].amounts.stage, proposals[index - 1].amounts.targetBalance, currency,
            proposals[index - 1].referenceBlockNumber, proposals[index - 1].walletInitiated,
            proposals[index - 1].disqualification.challenger,
            proposals[index - 1].disqualification.nonce,
            proposals[index - 1].disqualification.candidate.hash,
            proposals[index - 1].disqualification.candidate.kind
        );

        // Update proposal
        proposals[index - 1].status = SettlementChallengeTypesLib.Status.Qualified;
        proposals[index - 1].expirationTime = block.timestamp.add(configuration.settlementChallengeTimeout());
        delete proposals[index - 1].disqualification;
    }

    /// @notice Gauge whether a driip settlement challenge for the given wallet-nonce-currency
    /// triplet has been proposed and not later removed
    /// @param wallet The address of the concerned wallet
    /// @param nonce The wallet nonce
    /// @param currency The concerned currency
    /// @return true if driip settlement challenge has been, else false
    function hasProposal(address wallet, uint256 nonce, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (bool)
    {
        // 1-based index
        return 0 != proposalIndexByWalletNonceCurrency[wallet][nonce][currency.ct][currency.id];
    }

    /// @notice Gauge whether the proposal for the given wallet and currency has expired
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return true if proposal has expired, else false
    function hasProposal(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (bool)
    {
        // 1-based index
        return 0 != proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
    }

    /// @notice Gauge whether the proposal for the given wallet and currency has terminated
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return true if proposal has terminated, else false
    function hasProposalTerminated(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (bool)
    {
        // 1-based index
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:340]");
        return proposals[index - 1].terminated;
    }

    /// @notice Gauge whether the proposal for the given wallet and currency has expired
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return true if proposal has expired, else false
    function hasProposalExpired(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (bool)
    {
        // 1-based index
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:355]");
        return block.timestamp >= proposals[index - 1].expirationTime;
    }

    /// @notice Get the proposal nonce of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal nonce
    function proposalNonce(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:369]");
        return proposals[index - 1].nonce;
    }

    /// @notice Get the proposal reference block number of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal reference block number
    function proposalReferenceBlockNumber(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:383]");
        return proposals[index - 1].referenceBlockNumber;
    }

    /// @notice Get the proposal definition block number of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal definition block number
    function proposalDefinitionBlockNumber(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:397]");
        return proposals[index - 1].definitionBlockNumber;
    }

    /// @notice Get the proposal expiration time of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal expiration time
    function proposalExpirationTime(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:411]");
        return proposals[index - 1].expirationTime;
    }

    /// @notice Get the proposal status of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal status
    function proposalStatus(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (SettlementChallengeTypesLib.Status)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:425]");
        return proposals[index - 1].status;
    }

    /// @notice Get the proposal cumulative transfer amount of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal cumulative transfer amount
    function proposalCumulativeTransferAmount(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (int256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:439]");
        return proposals[index - 1].amounts.cumulativeTransfer;
    }

    /// @notice Get the proposal stage amount of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal stage amount
    function proposalStageAmount(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (int256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:453]");
        return proposals[index - 1].amounts.stage;
    }

    /// @notice Get the proposal target balance amount of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal target balance amount
    function proposalTargetBalanceAmount(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (int256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:467]");
        return proposals[index - 1].amounts.targetBalance;
    }

    /// @notice Get the proposal challenged hash of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal challenged hash
    function proposalChallengedHash(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (bytes32)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:481]");
        return proposals[index - 1].challenged.hash;
    }

    /// @notice Get the proposal challenged kind of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal challenged kind
    function proposalChallengedKind(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (string memory)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:495]");
        return proposals[index - 1].challenged.kind;
    }

    /// @notice Get the proposal balance reward of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal balance reward
    function proposalWalletInitiated(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (bool)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:509]");
        return proposals[index - 1].walletInitiated;
    }

    /// @notice Get the proposal disqualification challenger of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal disqualification challenger
    function proposalDisqualificationChallenger(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (address)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:523]");
        return proposals[index - 1].disqualification.challenger;
    }

    /// @notice Get the proposal disqualification nonce of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal disqualification nonce
    function proposalDisqualificationNonce(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:537]");
        return proposals[index - 1].disqualification.nonce;
    }

    /// @notice Get the proposal disqualification block number of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal disqualification block number
    function proposalDisqualificationBlockNumber(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:551]");
        return proposals[index - 1].disqualification.blockNumber;
    }

    /// @notice Get the proposal disqualification candidate hash of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal disqualification candidate hash
    function proposalDisqualificationCandidateHash(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (bytes32)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:565]");
        return proposals[index - 1].disqualification.candidate.hash;
    }

    /// @notice Get the proposal disqualification candidate kind of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The settlement proposal disqualification candidate kind
    function proposalDisqualificationCandidateKind(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (string memory)
    {
        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];
        require(0 != index, "No proposal found for wallet and currency [DriipSettlementChallengeState.sol:579]");
        return proposals[index - 1].disqualification.candidate.kind;
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _initiateProposal(address wallet, uint256 nonce, int256 cumulativeTransferAmount, int256 stageAmount,
        int256 targetBalanceAmount, MonetaryTypesLib.Currency memory currency, uint256 referenceBlockNumber, bool walletInitiated,
        bytes32 challengedHash, string memory challengedKind)
    private
    {
        // Require that there is no other proposal on the given wallet-nonce-currency triplet
        require(
            0 == proposalIndexByWalletNonceCurrency[wallet][nonce][currency.ct][currency.id],
            "Existing proposal found for wallet, nonce and currency [DriipSettlementChallengeState.sol:592]"
        );

        // Require that stage and target balance amounts are positive
        require(stageAmount.isPositiveInt256(), "Stage amount not positive [DriipSettlementChallengeState.sol:598]");
        require(targetBalanceAmount.isPositiveInt256(), "Target balance amount not positive [DriipSettlementChallengeState.sol:599]");

        uint256 index = proposalIndexByWalletCurrency[wallet][currency.ct][currency.id];

        // Create proposal if needed
        if (0 == index) {
            index = ++(proposals.length);
            proposalIndexByWalletCurrency[wallet][currency.ct][currency.id] = index;
        }

        // Populate proposal
        proposals[index - 1].wallet = wallet;
        proposals[index - 1].nonce = nonce;
        proposals[index - 1].referenceBlockNumber = referenceBlockNumber;
        proposals[index - 1].definitionBlockNumber = block.number;
        proposals[index - 1].expirationTime = block.timestamp.add(configuration.settlementChallengeTimeout());
        proposals[index - 1].status = SettlementChallengeTypesLib.Status.Qualified;
        proposals[index - 1].currency = currency;
        proposals[index - 1].amounts.cumulativeTransfer = cumulativeTransferAmount;
        proposals[index - 1].amounts.stage = stageAmount;
        proposals[index - 1].amounts.targetBalance = targetBalanceAmount;
        proposals[index - 1].walletInitiated = walletInitiated;
        proposals[index - 1].terminated = false;
        proposals[index - 1].challenged.hash = challengedHash;
        proposals[index - 1].challenged.kind = challengedKind;

        // Update index of wallet-nonce-currency triplet
        proposalIndexByWalletNonceCurrency[wallet][nonce][currency.ct][currency.id] = index;
    }

    function _removeProposal(uint256 index)
    private
    {
        // Remove the proposal and clear references to it
        proposalIndexByWalletCurrency[proposals[index - 1].wallet][proposals[index - 1].currency.ct][proposals[index - 1].currency.id] = 0;
        proposalIndexByWalletNonceCurrency[proposals[index - 1].wallet][proposals[index - 1].nonce][proposals[index - 1].currency.ct][proposals[index - 1].currency.id] = 0;
        if (index < proposals.length) {
            proposals[index - 1] = proposals[proposals.length - 1];
            proposalIndexByWalletCurrency[proposals[index - 1].wallet][proposals[index - 1].currency.ct][proposals[index - 1].currency.id] = index;
            proposalIndexByWalletNonceCurrency[proposals[index - 1].wallet][proposals[index - 1].nonce][proposals[index - 1].currency.ct][proposals[index - 1].currency.id] = index;
        }
        proposals.length--;
    }
}

/**
 * Strings Library
 * 
 * In summary this is a simple library of string functions which make simple 
 * string operations less tedious in solidity.
 * 
 * Please be aware these functions can be quite gas heavy so use them only when
 * necessary not to clog the blockchain with expensive transactions.
 * 
 * @author James Lockhart <james@n3tw0rk.co.uk>
 */
library Strings {

    /**
     * Concat (High gas cost)
     * 
     * Appends two strings together and returns a new value
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string which will be the concatenated
     *              prefix
     * @param _value The value to be the concatenated suffix
     * @return string The resulting string from combinging the base and value
     */
    function concat(string memory _base, string memory _value)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length > 0);

        string memory _tmpValue = new string(_baseBytes.length +
            _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function indexOf(string memory _base, string memory _value)
        internal
        pure
        returns (int) {
        return _indexOf(_base, _value, 0);
    }

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string starting
     * from a defined offset
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @param _offset The starting point to start searching from which can start
     *                from 0, but must not exceed the length of the string
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function _indexOf(string memory _base, string memory _value, uint _offset)
        internal
        pure
        returns (int) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int(i);
            }
        }

        return -1;
    }

    /**
     * Length
     * 
     * Returns the length of the specified string
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string to be measured
     * @return uint The length of the passed string
     */
    function length(string memory _base)
        internal
        pure
        returns (uint) {
        bytes memory _baseBytes = bytes(_base);
        return _baseBytes.length;
    }

    /**
     * Sub String
     * 
     * Extracts the beginning part of a string based on the desired length
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string that will be used for 
     *              extracting the sub string from
     * @param _length The length of the sub string to be extracted from the base
     * @return string The extracted sub string
     */
    function substring(string memory _base, int _length)
        internal
        pure
        returns (string memory) {
        return _substring(_base, _length, 0);
    }

    /**
     * Sub String
     * 
     * Extracts the part of a string based on the desired length and offset. The
     * offset and length must not exceed the lenth of the base string.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string that will be used for 
     *              extracting the sub string from
     * @param _length The length of the sub string to be extracted from the base
     * @param _offset The starting point to extract the sub string from
     * @return string The extracted sub string
     */
    function _substring(string memory _base, int _length, int _offset)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);

        assert(uint(_offset + _length) <= _baseBytes.length);

        string memory _tmp = new string(uint(_length));
        bytes memory _tmpBytes = bytes(_tmp);

        uint j = 0;
        for (uint i = uint(_offset); i < uint(_offset + _length); i++) {
            _tmpBytes[j++] = _baseBytes[i];
        }

        return string(_tmpBytes);
    }

    /**
     * String Split (Very high gas cost)
     *
     * Splits a string into an array of strings based off the delimiter value.
     * Please note this can be quite a gas expensive function due to the use of
     * storage so only use if really required.
     *
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string value to be split.
     * @param _value The delimiter to split the string on which must be a single
     *               character
     * @return string[] An array of values split based off the delimiter, but
     *                  do not container the delimiter.
     */
    function split(string memory _base, string memory _value)
        internal
        pure
        returns (string[] memory splitArr) {
        bytes memory _baseBytes = bytes(_base);

        uint _offset = 0;
        uint _splitsCount = 1;
        while (_offset < _baseBytes.length - 1) {
            int _limit = _indexOf(_base, _value, _offset);
            if (_limit == -1)
                break;
            else {
                _splitsCount++;
                _offset = uint(_limit) + 1;
            }
        }

        splitArr = new string[](_splitsCount);

        _offset = 0;
        _splitsCount = 0;
        while (_offset < _baseBytes.length - 1) {

            int _limit = _indexOf(_base, _value, _offset);
            if (_limit == - 1) {
                _limit = int(_baseBytes.length);
            }

            string memory _tmp = new string(uint(_limit) - _offset);
            bytes memory _tmpBytes = bytes(_tmp);

            uint j = 0;
            for (uint i = _offset; i < uint(_limit); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            _offset = uint(_limit) + 1;
            splitArr[_splitsCount++] = string(_tmpBytes);
        }
        return splitArr;
    }

    /**
     * Compare To
     * 
     * Compares the characters of two strings, to ensure that they have an 
     * identical footprint
     * 
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent
     */
    function compareTo(string memory _base, string memory _value)
        internal
        pure
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for (uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i]) {
                return false;
            }
        }

        return true;
    }

    /**
     * Compare To Ignore Case (High gas cost)
     * 
     * Compares the characters of two strings, converting them to the same case
     * where applicable to alphabetic characters to distinguish if the values
     * match.
     * 
     * @param _base When being used for a data type this is the extended object
     *               otherwise this is the string base to compare against
     * @param _value The string the base is being compared to
     * @return bool Simply notates if the two string have an equivalent value
     *              discarding case
     */
    function compareToIgnoreCase(string memory _base, string memory _value)
        internal
        pure
        returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        if (_baseBytes.length != _valueBytes.length) {
            return false;
        }

        for (uint i = 0; i < _baseBytes.length; i++) {
            if (_baseBytes[i] != _valueBytes[i] &&
            _upper(_baseBytes[i]) != _upper(_valueBytes[i])) {
                return false;
            }
        }

        return true;
    }

    /**
     * Upper
     * 
     * Converts all the values of a string to their corresponding upper case
     * value.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string base to convert to upper case
     * @return string 
     */
    function upper(string memory _base)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _upper(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    /**
     * Lower
     * 
     * Converts all the values of a string to their corresponding lower case
     * value.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string base to convert to lower case
     * @return string 
     */
    function lower(string memory _base)
        internal
        pure
        returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    /**
     * Upper
     * 
     * Convert an alphabetic character to upper case and return the original
     * value when not alphabetic
     * 
     * @param _b1 The byte to be converted to upper case
     * @return bytes1 The converted value if the passed value was alphabetic
     *                and in a lower case otherwise returns the original value
     */
    function _upper(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x61 && _b1 <= 0x7A) {
            return bytes1(uint8(_b1) - 32);
        }

        return _b1;
    }

    /**
     * Lower
     * 
     * Convert an alphabetic character to lower case and return the original
     * value when not alphabetic
     * 
     * @param _b1 The byte to be converted to lower case
     * @return bytes1 The converted value if the passed value was alphabetic
     *                and in a upper case otherwise returns the original value
     */
    function _lower(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title PartnerFund
 * @notice Where partners¡¯ fees are managed
 */
contract PartnerFund is Ownable, Beneficiary, TransferControllerManageable {
    using FungibleBalanceLib for FungibleBalanceLib.Balance;
    using TxHistoryLib for TxHistoryLib.TxHistory;
    using SafeMathIntLib for int256;
    using Strings for string;

    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Partner {
        bytes32 nameHash;

        uint256 fee;
        address wallet;
        uint256 index;

        bool operatorCanUpdate;
        bool partnerCanUpdate;

        FungibleBalanceLib.Balance active;
        FungibleBalanceLib.Balance staged;

        TxHistoryLib.TxHistory txHistory;
        FullBalanceHistory[] fullBalanceHistory;
    }

    struct FullBalanceHistory {
        uint256 listIndex;
        int256 balance;
        uint256 blockNumber;
    }

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    Partner[] private partners;

    mapping(bytes32 => uint256) private _indexByNameHash;
    mapping(address => uint256) private _indexByWallet;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event ReceiveEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event RegisterPartnerByNameEvent(string name, uint256 fee, address wallet);
    event RegisterPartnerByNameHashEvent(bytes32 nameHash, uint256 fee, address wallet);
    event SetFeeByIndexEvent(uint256 index, uint256 oldFee, uint256 newFee);
    event SetFeeByNameEvent(string name, uint256 oldFee, uint256 newFee);
    event SetFeeByNameHashEvent(bytes32 nameHash, uint256 oldFee, uint256 newFee);
    event SetFeeByWalletEvent(address wallet, uint256 oldFee, uint256 newFee);
    event SetPartnerWalletByIndexEvent(uint256 index, address oldWallet, address newWallet);
    event SetPartnerWalletByNameEvent(string name, address oldWallet, address newWallet);
    event SetPartnerWalletByNameHashEvent(bytes32 nameHash, address oldWallet, address newWallet);
    event SetPartnerWalletByWalletEvent(address oldWallet, address newWallet);
    event StageEvent(address from, int256 amount, address currencyCt, uint256 currencyId);
    event WithdrawEvent(address to, int256 amount, address currencyCt, uint256 currencyId);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Fallback function that deposits ethers
    function() external payable {
        _receiveEthersTo(
            indexByWallet(msg.sender) - 1, SafeMathIntLib.toNonZeroInt256(msg.value)
        );
    }

    /// @notice Receive ethers to
    /// @param tag The tag of the concerned partner
    function receiveEthersTo(address tag, string memory)
    public
    payable
    {
        _receiveEthersTo(
            uint256(tag) - 1, SafeMathIntLib.toNonZeroInt256(msg.value)
        );
    }

    /// @notice Receive tokens
    /// @param amount The concerned amount
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of token ("ERC20", "ERC721")
    function receiveTokens(string memory, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        _receiveTokensTo(
            indexByWallet(msg.sender) - 1, amount, currencyCt, currencyId, standard
        );
    }

    /// @notice Receive tokens to
    /// @param tag The tag of the concerned partner
    /// @param amount The concerned amount
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of token ("ERC20", "ERC721")
    function receiveTokensTo(address tag, string memory, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    public
    {
        _receiveTokensTo(
            uint256(tag) - 1, amount, currencyCt, currencyId, standard
        );
    }

    /// @notice Hash name
    /// @param name The name to be hashed
    /// @return The hash value
    function hashName(string memory name)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(name.upper()));
    }

    /// @notice Get deposit by partner and deposit indices
    /// @param partnerIndex The index of the concerned partner
    /// @param depositIndex The index of the concerned deposit
    /// return The deposit parameters
    function depositByIndices(uint256 partnerIndex, uint256 depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        // Require partner index is one of registered partner
        require(0 < partnerIndex && partnerIndex <= partners.length, "Some error message when require fails [PartnerFund.sol:160]");

        return _depositByIndices(partnerIndex - 1, depositIndex);
    }

    /// @notice Get deposit by partner name and deposit indices
    /// @param name The name of the concerned partner
    /// @param depositIndex The index of the concerned deposit
    /// return The deposit parameters
    function depositByName(string memory name, uint depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        // Implicitly require that partner name is registered
        return _depositByIndices(indexByName(name) - 1, depositIndex);
    }

    /// @notice Get deposit by partner name hash and deposit indices
    /// @param nameHash The hashed name of the concerned partner
    /// @param depositIndex The index of the concerned deposit
    /// return The deposit parameters
    function depositByNameHash(bytes32 nameHash, uint depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        // Implicitly require that partner name hash is registered
        return _depositByIndices(indexByNameHash(nameHash) - 1, depositIndex);
    }

    /// @notice Get deposit by partner wallet and deposit indices
    /// @param wallet The wallet of the concerned partner
    /// @param depositIndex The index of the concerned deposit
    /// return The deposit parameters
    function depositByWallet(address wallet, uint depositIndex)
    public
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        // Implicitly require that partner wallet is registered
        return _depositByIndices(indexByWallet(wallet) - 1, depositIndex);
    }

    /// @notice Get deposits count by partner index
    /// @param index The index of the concerned partner
    /// return The deposits count
    function depositsCountByIndex(uint256 index)
    public
    view
    returns (uint256)
    {
        // Require partner index is one of registered partner
        require(0 < index && index <= partners.length, "Some error message when require fails [PartnerFund.sol:213]");

        return _depositsCountByIndex(index - 1);
    }

    /// @notice Get deposits count by partner name
    /// @param name The name of the concerned partner
    /// return The deposits count
    function depositsCountByName(string memory name)
    public
    view
    returns (uint256)
    {
        // Implicitly require that partner name is registered
        return _depositsCountByIndex(indexByName(name) - 1);
    }

    /// @notice Get deposits count by partner name hash
    /// @param nameHash The hashed name of the concerned partner
    /// return The deposits count
    function depositsCountByNameHash(bytes32 nameHash)
    public
    view
    returns (uint256)
    {
        // Implicitly require that partner name hash is registered
        return _depositsCountByIndex(indexByNameHash(nameHash) - 1);
    }

    /// @notice Get deposits count by partner wallet
    /// @param wallet The wallet of the concerned partner
    /// return The deposits count
    function depositsCountByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        // Implicitly require that partner wallet is registered
        return _depositsCountByIndex(indexByWallet(wallet) - 1);
    }

    /// @notice Get active balance by partner index and currency
    /// @param index The index of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The active balance
    function activeBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Require partner index is one of registered partner
        require(0 < index && index <= partners.length, "Some error message when require fails [PartnerFund.sol:265]");

        return _activeBalanceByIndex(index - 1, currencyCt, currencyId);
    }

    /// @notice Get active balance by partner name and currency
    /// @param name The name of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The active balance
    function activeBalanceByName(string memory name, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Implicitly require that partner name is registered
        return _activeBalanceByIndex(indexByName(name) - 1, currencyCt, currencyId);
    }

    /// @notice Get active balance by partner name hash and currency
    /// @param nameHash The hashed name of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The active balance
    function activeBalanceByNameHash(bytes32 nameHash, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Implicitly require that partner name hash is registered
        return _activeBalanceByIndex(indexByNameHash(nameHash) - 1, currencyCt, currencyId);
    }

    /// @notice Get active balance by partner wallet and currency
    /// @param wallet The wallet of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The active balance
    function activeBalanceByWallet(address wallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Implicitly require that partner wallet is registered
        return _activeBalanceByIndex(indexByWallet(wallet) - 1, currencyCt, currencyId);
    }

    /// @notice Get staged balance by partner index and currency
    /// @param index The index of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The staged balance
    function stagedBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Require partner index is one of registered partner
        require(0 < index && index <= partners.length, "Some error message when require fails [PartnerFund.sol:323]");

        return _stagedBalanceByIndex(index - 1, currencyCt, currencyId);
    }

    /// @notice Get staged balance by partner name and currency
    /// @param name The name of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The staged balance
    function stagedBalanceByName(string memory name, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Implicitly require that partner name is registered
        return _stagedBalanceByIndex(indexByName(name) - 1, currencyCt, currencyId);
    }

    /// @notice Get staged balance by partner name hash and currency
    /// @param nameHash The hashed name of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The staged balance
    function stagedBalanceByNameHash(bytes32 nameHash, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Implicitly require that partner name is registered
        return _stagedBalanceByIndex(indexByNameHash(nameHash) - 1, currencyCt, currencyId);
    }

    /// @notice Get staged balance by partner wallet and currency
    /// @param wallet The wallet of the concerned partner
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// return The staged balance
    function stagedBalanceByWallet(address wallet, address currencyCt, uint256 currencyId)
    public
    view
    returns (int256)
    {
        // Implicitly require that partner wallet is registered
        return _stagedBalanceByIndex(indexByWallet(wallet) - 1, currencyCt, currencyId);
    }

    /// @notice Get the number of partners
    /// @return The number of partners
    function partnersCount()
    public
    view
    returns (uint256)
    {
        return partners.length;
    }

    /// @notice Register a partner by name
    /// @param name The name of the concerned partner
    /// @param fee The partner's fee fraction
    /// @param wallet The partner's wallet
    /// @param partnerCanUpdate Indicator of whether partner can update fee and wallet
    /// @param operatorCanUpdate Indicator of whether operator can update fee and wallet
    function registerByName(string memory name, uint256 fee, address wallet,
        bool partnerCanUpdate, bool operatorCanUpdate)
    public
    onlyOperator
    {
        // Require not empty name string
        require(bytes(name).length > 0, "Some error message when require fails [PartnerFund.sol:392]");

        // Hash name
        bytes32 nameHash = hashName(name);

        // Register partner
        _registerPartnerByNameHash(nameHash, fee, wallet, partnerCanUpdate, operatorCanUpdate);

        // Emit event
        emit RegisterPartnerByNameEvent(name, fee, wallet);
    }

    /// @notice Register a partner by name hash
    /// @param nameHash The hashed name of the concerned partner
    /// @param fee The partner's fee fraction
    /// @param wallet The partner's wallet
    /// @param partnerCanUpdate Indicator of whether partner can update fee and wallet
    /// @param operatorCanUpdate Indicator of whether operator can update fee and wallet
    function registerByNameHash(bytes32 nameHash, uint256 fee, address wallet,
        bool partnerCanUpdate, bool operatorCanUpdate)
    public
    onlyOperator
    {
        // Register partner
        _registerPartnerByNameHash(nameHash, fee, wallet, partnerCanUpdate, operatorCanUpdate);

        // Emit event
        emit RegisterPartnerByNameHashEvent(nameHash, fee, wallet);
    }

    /// @notice Gets the 1-based index of partner by its name
    /// @dev Reverts if name does not correspond to registered partner
    /// @return Index of partner by given name
    function indexByNameHash(bytes32 nameHash)
    public
    view
    returns (uint256)
    {
        uint256 index = _indexByNameHash[nameHash];
        require(0 < index, "Some error message when require fails [PartnerFund.sol:431]");
        return index;
    }

    /// @notice Gets the 1-based index of partner by its name
    /// @dev Reverts if name does not correspond to registered partner
    /// @return Index of partner by given name
    function indexByName(string memory name)
    public
    view
    returns (uint256)
    {
        return indexByNameHash(hashName(name));
    }

    /// @notice Gets the 1-based index of partner by its wallet
    /// @dev Reverts if wallet does not correspond to registered partner
    /// @return Index of partner by given wallet
    function indexByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        uint256 index = _indexByWallet[wallet];
        require(0 < index, "Some error message when require fails [PartnerFund.sol:455]");
        return index;
    }

    /// @notice Gauge whether a partner by the given name is registered
    /// @param name The name of the concerned partner
    /// @return true if partner is registered, else false
    function isRegisteredByName(string memory name)
    public
    view
    returns (bool)
    {
        return (0 < _indexByNameHash[hashName(name)]);
    }

    /// @notice Gauge whether a partner by the given name hash is registered
    /// @param nameHash The hashed name of the concerned partner
    /// @return true if partner is registered, else false
    function isRegisteredByNameHash(bytes32 nameHash)
    public
    view
    returns (bool)
    {
        return (0 < _indexByNameHash[nameHash]);
    }

    /// @notice Gauge whether a partner by the given wallet is registered
    /// @param wallet The wallet of the concerned partner
    /// @return true if partner is registered, else false
    function isRegisteredByWallet(address wallet)
    public
    view
    returns (bool)
    {
        return (0 < _indexByWallet[wallet]);
    }

    /// @notice Get the partner fee fraction by the given partner index
    /// @param index The index of the concerned partner
    /// @return The fee fraction
    function feeByIndex(uint256 index)
    public
    view
    returns (uint256)
    {
        // Require partner index is one of registered partner
        require(0 < index && index <= partners.length, "Some error message when require fails [PartnerFund.sol:501]");

        return _partnerFeeByIndex(index - 1);
    }

    /// @notice Get the partner fee fraction by the given partner name
    /// @param name The name of the concerned partner
    /// @return The fee fraction
    function feeByName(string memory name)
    public
    view
    returns (uint256)
    {
        // Get fee, implicitly requiring that partner name is registered
        return _partnerFeeByIndex(indexByName(name) - 1);
    }

    /// @notice Get the partner fee fraction by the given partner name hash
    /// @param nameHash The hashed name of the concerned partner
    /// @return The fee fraction
    function feeByNameHash(bytes32 nameHash)
    public
    view
    returns (uint256)
    {
        // Get fee, implicitly requiring that partner name hash is registered
        return _partnerFeeByIndex(indexByNameHash(nameHash) - 1);
    }

    /// @notice Get the partner fee fraction by the given partner wallet
    /// @param wallet The wallet of the concerned partner
    /// @return The fee fraction
    function feeByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        // Get fee, implicitly requiring that partner wallet is registered
        return _partnerFeeByIndex(indexByWallet(wallet) - 1);
    }

    /// @notice Set the partner fee fraction by the given partner index
    /// @param index The index of the concerned partner
    /// @param newFee The partner's fee fraction
    function setFeeByIndex(uint256 index, uint256 newFee)
    public
    {
        // Require partner index is one of registered partner
        require(0 < index && index <= partners.length, "Some error message when require fails [PartnerFund.sol:549]");

        // Update fee
        uint256 oldFee = _setPartnerFeeByIndex(index - 1, newFee);

        // Emit event
        emit SetFeeByIndexEvent(index, oldFee, newFee);
    }

    /// @notice Set the partner fee fraction by the given partner name
    /// @param name The name of the concerned partner
    /// @param newFee The partner's fee fraction
    function setFeeByName(string memory name, uint256 newFee)
    public
    {
        // Update fee, implicitly requiring that partner name is registered
        uint256 oldFee = _setPartnerFeeByIndex(indexByName(name) - 1, newFee);

        // Emit event
        emit SetFeeByNameEvent(name, oldFee, newFee);
    }

    /// @notice Set the partner fee fraction by the given partner name hash
    /// @param nameHash The hashed name of the concerned partner
    /// @param newFee The partner's fee fraction
    function setFeeByNameHash(bytes32 nameHash, uint256 newFee)
    public
    {
        // Update fee, implicitly requiring that partner name hash is registered
        uint256 oldFee = _setPartnerFeeByIndex(indexByNameHash(nameHash) - 1, newFee);

        // Emit event
        emit SetFeeByNameHashEvent(nameHash, oldFee, newFee);
    }

    /// @notice Set the partner fee fraction by the given partner wallet
    /// @param wallet The wallet of the concerned partner
    /// @param newFee The partner's fee fraction
    function setFeeByWallet(address wallet, uint256 newFee)
    public
    {
        // Update fee, implicitly requiring that partner wallet is registered
        uint256 oldFee = _setPartnerFeeByIndex(indexByWallet(wallet) - 1, newFee);

        // Emit event
        emit SetFeeByWalletEvent(wallet, oldFee, newFee);
    }

    /// @notice Get the partner wallet by the given partner index
    /// @param index The index of the concerned partner
    /// @return The wallet
    function walletByIndex(uint256 index)
    public
    view
    returns (address)
    {
        // Require partner index is one of registered partner
        require(0 < index && index <= partners.length, "Some error message when require fails [PartnerFund.sol:606]");

        return partners[index - 1].wallet;
    }

    /// @notice Get the partner wallet by the given partner name
    /// @param name The name of the concerned partner
    /// @return The wallet
    function walletByName(string memory name)
    public
    view
    returns (address)
    {
        // Get wallet, implicitly requiring that partner name is registered
        return partners[indexByName(name) - 1].wallet;
    }

    /// @notice Get the partner wallet by the given partner name hash
    /// @param nameHash The hashed name of the concerned partner
    /// @return The wallet
    function walletByNameHash(bytes32 nameHash)
    public
    view
    returns (address)
    {
        // Get wallet, implicitly requiring that partner name hash is registered
        return partners[indexByNameHash(nameHash) - 1].wallet;
    }

    /// @notice Set the partner wallet by the given partner index
    /// @param index The index of the concerned partner
    /// @return newWallet The partner's wallet
    function setWalletByIndex(uint256 index, address newWallet)
    public
    {
        // Require partner index is one of registered partner
        require(0 < index && index <= partners.length, "Some error message when require fails [PartnerFund.sol:642]");

        // Update wallet
        address oldWallet = _setPartnerWalletByIndex(index - 1, newWallet);

        // Emit event
        emit SetPartnerWalletByIndexEvent(index, oldWallet, newWallet);
    }

    /// @notice Set the partner wallet by the given partner name
    /// @param name The name of the concerned partner
    /// @return newWallet The partner's wallet
    function setWalletByName(string memory name, address newWallet)
    public
    {
        // Update wallet
        address oldWallet = _setPartnerWalletByIndex(indexByName(name) - 1, newWallet);

        // Emit event
        emit SetPartnerWalletByNameEvent(name, oldWallet, newWallet);
    }

    /// @notice Set the partner wallet by the given partner name hash
    /// @param nameHash The hashed name of the concerned partner
    /// @return newWallet The partner's wallet
    function setWalletByNameHash(bytes32 nameHash, address newWallet)
    public
    {
        // Update wallet
        address oldWallet = _setPartnerWalletByIndex(indexByNameHash(nameHash) - 1, newWallet);

        // Emit event
        emit SetPartnerWalletByNameHashEvent(nameHash, oldWallet, newWallet);
    }

    /// @notice Set the new partner wallet by the given old partner wallet
    /// @param oldWallet The old wallet of the concerned partner
    /// @return newWallet The partner's new wallet
    function setWalletByWallet(address oldWallet, address newWallet)
    public
    {
        // Update wallet
        _setPartnerWalletByIndex(indexByWallet(oldWallet) - 1, newWallet);

        // Emit event
        emit SetPartnerWalletByWalletEvent(oldWallet, newWallet);
    }

    /// @notice Stage the amount for subsequent withdrawal
    /// @param amount The concerned amount to stage
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function stage(int256 amount, address currencyCt, uint256 currencyId)
    public
    {
        // Get index, implicitly requiring that msg.sender is wallet of registered partner
        uint256 index = indexByWallet(msg.sender);

        // Require positive amount
        require(amount.isPositiveInt256(), "Some error message when require fails [PartnerFund.sol:701]");

        // Clamp amount to move
        amount = amount.clampMax(partners[index - 1].active.get(currencyCt, currencyId));

        partners[index - 1].active.sub(amount, currencyCt, currencyId);
        partners[index - 1].staged.add(amount, currencyCt, currencyId);

        partners[index - 1].txHistory.addDeposit(amount, currencyCt, currencyId);

        // Add to full deposit history
        partners[index - 1].fullBalanceHistory.push(
            FullBalanceHistory(
                partners[index - 1].txHistory.depositsCount() - 1,
                partners[index - 1].active.get(currencyCt, currencyId),
                block.number
            )
        );

        // Emit event
        emit StageEvent(msg.sender, amount, currencyCt, currencyId);
    }

    /// @notice Withdraw the given amount from staged balance
    /// @param amount The concerned amount to withdraw
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function withdraw(int256 amount, address currencyCt, uint256 currencyId, string memory standard)
    public
    {
        // Get index, implicitly requiring that msg.sender is wallet of registered partner
        uint256 index = indexByWallet(msg.sender);

        // Require positive amount
        require(amount.isPositiveInt256(), "Some error message when require fails [PartnerFund.sol:736]");

        // Clamp amount to move
        amount = amount.clampMax(partners[index - 1].staged.get(currencyCt, currencyId));

        partners[index - 1].staged.sub(amount, currencyCt, currencyId);

        // Execute transfer
        if (address(0) == currencyCt && 0 == currencyId)
            msg.sender.transfer(uint256(amount));

        else {
            TransferController controller = transferController(currencyCt, standard);
            (bool success,) = address(controller).delegatecall(
                abi.encodeWithSelector(
                    controller.getDispatchSignature(), address(this), msg.sender, uint256(amount), currencyCt, currencyId
                )
            );
            require(success, "Some error message when require fails [PartnerFund.sol:754]");
        }

        // Emit event
        emit WithdrawEvent(msg.sender, amount, currencyCt, currencyId);
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @dev index is 0-based
    function _receiveEthersTo(uint256 index, int256 amount)
    private
    {
        // Require that index is within bounds
        require(index < partners.length, "Some error message when require fails [PartnerFund.sol:769]");

        // Add to active
        partners[index].active.add(amount, address(0), 0);
        partners[index].txHistory.addDeposit(amount, address(0), 0);

        // Add to full deposit history
        partners[index].fullBalanceHistory.push(
            FullBalanceHistory(
                partners[index].txHistory.depositsCount() - 1,
                partners[index].active.get(address(0), 0),
                block.number
            )
        );

        // Emit event
        emit ReceiveEvent(msg.sender, amount, address(0), 0);
    }

    /// @dev index is 0-based
    function _receiveTokensTo(uint256 index, int256 amount, address currencyCt,
        uint256 currencyId, string memory standard)
    private
    {
        // Require that index is within bounds
        require(index < partners.length, "Some error message when require fails [PartnerFund.sol:794]");

        require(amount.isNonZeroPositiveInt256(), "Some error message when require fails [PartnerFund.sol:796]");

        // Execute transfer
        TransferController controller = transferController(currencyCt, standard);
        (bool success,) = address(controller).delegatecall(
            abi.encodeWithSelector(
                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId
            )
        );
        require(success, "Some error message when require fails [PartnerFund.sol:805]");

        // Add to active
        partners[index].active.add(amount, currencyCt, currencyId);
        partners[index].txHistory.addDeposit(amount, currencyCt, currencyId);

        // Add to full deposit history
        partners[index].fullBalanceHistory.push(
            FullBalanceHistory(
                partners[index].txHistory.depositsCount() - 1,
                partners[index].active.get(currencyCt, currencyId),
                block.number
            )
        );

        // Emit event
        emit ReceiveEvent(msg.sender, amount, currencyCt, currencyId);
    }

    /// @dev partnerIndex is 0-based
    function _depositByIndices(uint256 partnerIndex, uint256 depositIndex)
    private
    view
    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)
    {
        require(depositIndex < partners[partnerIndex].fullBalanceHistory.length, "Some error message when require fails [PartnerFund.sol:830]");

        FullBalanceHistory storage entry = partners[partnerIndex].fullBalanceHistory[depositIndex];
        (,, currencyCt, currencyId) = partners[partnerIndex].txHistory.deposit(entry.listIndex);

        balance = entry.balance;
        blockNumber = entry.blockNumber;
    }

    /// @dev index is 0-based
    function _depositsCountByIndex(uint256 index)
    private
    view
    returns (uint256)
    {
        return partners[index].fullBalanceHistory.length;
    }

    /// @dev index is 0-based
    function _activeBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    private
    view
    returns (int256)
    {
        return partners[index].active.get(currencyCt, currencyId);
    }

    /// @dev index is 0-based
    function _stagedBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)
    private
    view
    returns (int256)
    {
        return partners[index].staged.get(currencyCt, currencyId);
    }

    function _registerPartnerByNameHash(bytes32 nameHash, uint256 fee, address wallet,
        bool partnerCanUpdate, bool operatorCanUpdate)
    private
    {
        // Require that the name is not previously registered
        require(0 == _indexByNameHash[nameHash], "Some error message when require fails [PartnerFund.sol:871]");

        // Require possibility to update
        require(partnerCanUpdate || operatorCanUpdate, "Some error message when require fails [PartnerFund.sol:874]");

        // Add new partner
        partners.length++;

        // Reference by 1-based index
        uint256 index = partners.length;

        // Update partner map
        partners[index - 1].nameHash = nameHash;
        partners[index - 1].fee = fee;
        partners[index - 1].wallet = wallet;
        partners[index - 1].partnerCanUpdate = partnerCanUpdate;
        partners[index - 1].operatorCanUpdate = operatorCanUpdate;
        partners[index - 1].index = index;

        // Update name hash to index map
        _indexByNameHash[nameHash] = index;

        // Update wallet to index map
        _indexByWallet[wallet] = index;
    }

    /// @dev index is 0-based
    function _setPartnerFeeByIndex(uint256 index, uint256 fee)
    private
    returns (uint256)
    {
        uint256 oldFee = partners[index].fee;

        // If operator tries to change verify that operator has access
        if (isOperator())
            require(partners[index].operatorCanUpdate, "Some error message when require fails [PartnerFund.sol:906]");

        else {
            // Require that msg.sender is partner
            require(msg.sender == partners[index].wallet, "Some error message when require fails [PartnerFund.sol:910]");

            // If partner tries to change verify that partner has access
            require(partners[index].partnerCanUpdate, "Some error message when require fails [PartnerFund.sol:913]");
        }

        // Update stored fee
        partners[index].fee = fee;

        return oldFee;
    }

    // @dev index is 0-based
    function _setPartnerWalletByIndex(uint256 index, address newWallet)
    private
    returns (address)
    {
        address oldWallet = partners[index].wallet;

        // If address has not been set operator is the only allowed to change it
        if (oldWallet == address(0))
            require(isOperator(), "Some error message when require fails [PartnerFund.sol:931]");

        // Else if operator tries to change verify that operator has access
        else if (isOperator())
            require(partners[index].operatorCanUpdate, "Some error message when require fails [PartnerFund.sol:935]");

        else {
            // Require that msg.sender is partner
            require(msg.sender == oldWallet, "Some error message when require fails [PartnerFund.sol:939]");

            // If partner tries to change verify that partner has access
            require(partners[index].partnerCanUpdate, "Some error message when require fails [PartnerFund.sol:942]");

            // Require that new wallet is not zero-address if it can not be changed by operator
            require(partners[index].operatorCanUpdate || newWallet != address(0), "Some error message when require fails [PartnerFund.sol:945]");
        }

        // Update stored wallet
        partners[index].wallet = newWallet;

        // Update address to tag map
        if (oldWallet != address(0))
            _indexByWallet[oldWallet] = 0;
        if (newWallet != address(0))
            _indexByWallet[newWallet] = index;

        return oldWallet;
    }

    // @dev index is 0-based
    function _partnerFeeByIndex(uint256 index)
    private
    view
    returns (uint256)
    {
        return partners[index].fee;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title     DriipSettlementTypesLib
 * @dev       Types for driip settlements
 */
library DriipSettlementTypesLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    enum SettlementRole {Origin, Target}

    struct SettlementParty {
        uint256 nonce;
        address wallet;
        bool done;
        uint256 doneBlockNumber;
    }

    struct Settlement {
        string settledKind;
        bytes32 settledHash;
        SettlementParty origin;
        SettlementParty target;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title DriipSettlementState
 * @notice Where driip settlement state is managed
 */
contract DriipSettlementState is Ownable, Servable, CommunityVotable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;

    //
    // Constants
    // -----------------------------------------------------------------------------------------------------------------
    string constant public INIT_SETTLEMENT_ACTION = "init_settlement";
    string constant public SET_SETTLEMENT_ROLE_DONE_ACTION = "set_settlement_role_done";
    string constant public SET_MAX_NONCE_ACTION = "set_max_nonce";
    string constant public SET_FEE_TOTAL_ACTION = "set_fee_total";

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    uint256 public maxDriipNonce;

    DriipSettlementTypesLib.Settlement[] public settlements;
    mapping(address => uint256[]) public walletSettlementIndices;
    mapping(address => mapping(uint256 => uint256)) public walletNonceSettlementIndex;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public walletCurrencyMaxNonce;

    mapping(address => mapping(address => mapping(address => mapping(address => mapping(uint256 => MonetaryTypesLib.NoncedAmount))))) public totalFeesMap;

    bool public upgradesFrozen;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event InitSettlementEvent(DriipSettlementTypesLib.Settlement settlement);
    event CompleteSettlementPartyEvent(address wallet, uint256 nonce, DriipSettlementTypesLib.SettlementRole settlementRole,
        bool done, uint256 doneBlockNumber);
    event SetMaxNonceByWalletAndCurrencyEvent(address wallet, MonetaryTypesLib.Currency currency,
        uint256 maxNonce);
    event SetMaxDriipNonceEvent(uint256 maxDriipNonce);
    event UpdateMaxDriipNonceFromCommunityVoteEvent(uint256 maxDriipNonce);
    event SetTotalFeeEvent(address wallet, Beneficiary beneficiary, address destination,
        MonetaryTypesLib.Currency currency, MonetaryTypesLib.NoncedAmount totalFee);
    event FreezeUpgradesEvent();
    event UpgradeSettlementEvent(DriipSettlementTypesLib.Settlement settlement);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Get the count of settlements
    function settlementsCount()
    public
    view
    returns (uint256)
    {
        return settlements.length;
    }

    /// @notice Get the count of settlements for given wallet
    /// @param wallet The address for which to return settlement count
    /// @return count of settlements for the provided wallet
    function settlementsCountByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        return walletSettlementIndices[wallet].length;
    }

    /// @notice Get settlement of given wallet and index
    /// @param wallet The address for which to return settlement
    /// @param index The wallet's settlement index
    /// @return settlement for the provided wallet and index
    function settlementByWalletAndIndex(address wallet, uint256 index)
    public
    view
    returns (DriipSettlementTypesLib.Settlement memory)
    {
        require(walletSettlementIndices[wallet].length > index, "Index out of bounds [DriipSettlementState.sol:107]");
        return settlements[walletSettlementIndices[wallet][index] - 1];
    }

    /// @notice Get settlement of given wallet and wallet nonce
    /// @param wallet The address for which to return settlement
    /// @param nonce The wallet's nonce
    /// @return settlement for the provided wallet and index
    function settlementByWalletAndNonce(address wallet, uint256 nonce)
    public
    view
    returns (DriipSettlementTypesLib.Settlement memory)
    {
        require(0 != walletNonceSettlementIndex[wallet][nonce], "No settlement found for wallet and nonce [DriipSettlementState.sol:120]");
        return settlements[walletNonceSettlementIndex[wallet][nonce] - 1];
    }

    /// @notice Initialize settlement, i.e. create one if no such settlement exists
    /// for the double pair of wallets and nonces
    /// @param settledKind The kind of driip of the settlement
    /// @param settledHash The hash of driip of the settlement
    /// @param originWallet The address of the origin wallet
    /// @param originNonce The wallet nonce of the origin wallet
    /// @param targetWallet The address of the target wallet
    /// @param targetNonce The wallet nonce of the target wallet
    function initSettlement(string memory settledKind, bytes32 settledHash, address originWallet,
        uint256 originNonce, address targetWallet, uint256 targetNonce)
    public
    onlyEnabledServiceAction(INIT_SETTLEMENT_ACTION)
    {
        if (
            0 == walletNonceSettlementIndex[originWallet][originNonce] &&
            0 == walletNonceSettlementIndex[targetWallet][targetNonce]
        ) {
            // Create new settlement
            settlements.length++;

            // Get the 0-based index
            uint256 index = settlements.length - 1;

            // Update settlement
            settlements[index].settledKind = settledKind;
            settlements[index].settledHash = settledHash;
            settlements[index].origin.nonce = originNonce;
            settlements[index].origin.wallet = originWallet;
            settlements[index].target.nonce = targetNonce;
            settlements[index].target.wallet = targetWallet;

            // Emit event
            emit InitSettlementEvent(settlements[index]);

            // Store 1-based index value
            index++;
            walletSettlementIndices[originWallet].push(index);
            walletSettlementIndices[targetWallet].push(index);
            walletNonceSettlementIndex[originWallet][originNonce] = index;
            walletNonceSettlementIndex[targetWallet][targetNonce] = index;
        }
    }

    /// @notice Set the done of the given settlement role in the given settlement
    /// @param wallet The address of the concerned wallet
    /// @param nonce The nonce of the concerned wallet
    /// @param settlementRole The settlement role
    /// @param done The done flag
    function completeSettlementParty(address wallet, uint256 nonce,
        DriipSettlementTypesLib.SettlementRole settlementRole, bool done)
    public
    onlyEnabledServiceAction(SET_SETTLEMENT_ROLE_DONE_ACTION)
    {
        // Get the 1-based index of the settlement
        uint256 index = walletNonceSettlementIndex[wallet][nonce];

        // Require the existence of settlement
        require(0 != index, "No settlement found for wallet and nonce [DriipSettlementState.sol:181]");

        // Get the settlement party
        DriipSettlementTypesLib.SettlementParty storage party =
        DriipSettlementTypesLib.SettlementRole.Origin == settlementRole ?
        settlements[index - 1].origin :
        settlements[index - 1].target;

        // Update party done and done block number properties
        party.done = done;
        party.doneBlockNumber = done ? block.number : 0;

        // Emit event
        emit CompleteSettlementPartyEvent(wallet, nonce, settlementRole, done, party.doneBlockNumber);
    }

    /// @notice Gauge whether the settlement is done wrt the given wallet and nonce
    /// @param wallet The address of the concerned wallet
    /// @param nonce The nonce of the concerned wallet
    /// @return True if settlement is done for role, else false
    function isSettlementPartyDone(address wallet, uint256 nonce)
    public
    view
    returns (bool)
    {
        // Get the 1-based index of the settlement
        uint256 index = walletNonceSettlementIndex[wallet][nonce];

        // Return false if settlement does not exist
        if (0 == index)
            return false;

        // Return done
        return (
        wallet == settlements[index - 1].origin.wallet ?
        settlements[index - 1].origin.done :
        settlements[index - 1].target.done
        );
    }

    /// @notice Gauge whether the settlement is done wrt the given wallet, nonce
    /// and settlement role
    /// @param wallet The address of the concerned wallet
    /// @param nonce The nonce of the concerned wallet
    /// @param settlementRole The settlement role
    /// @return True if settlement is done for role, else false
    function isSettlementPartyDone(address wallet, uint256 nonce,
        DriipSettlementTypesLib.SettlementRole settlementRole)
    public
    view
    returns (bool)
    {
        // Get the 1-based index of the settlement
        uint256 index = walletNonceSettlementIndex[wallet][nonce];

        // Return false if settlement does not exist
        if (0 == index)
            return false;

        // Get the settlement party
        DriipSettlementTypesLib.SettlementParty storage settlementParty =
        DriipSettlementTypesLib.SettlementRole.Origin == settlementRole ?
        settlements[index - 1].origin : settlements[index - 1].target;

        // Require that wallet is party of the right role
        require(wallet == settlementParty.wallet, "Wallet has wrong settlement role [DriipSettlementState.sol:246]");

        // Return done
        return settlementParty.done;
    }

    /// @notice Get the done block number of the settlement party with the given wallet and nonce
    /// @param wallet The address of the concerned wallet
    /// @param nonce The nonce of the concerned wallet
    /// @return The done block number of the settlement wrt the given settlement role
    function settlementPartyDoneBlockNumber(address wallet, uint256 nonce)
    public
    view
    returns (uint256)
    {
        // Get the 1-based index of the settlement
        uint256 index = walletNonceSettlementIndex[wallet][nonce];

        // Require the existence of settlement
        require(0 != index, "No settlement found for wallet and nonce [DriipSettlementState.sol:265]");

        // Return done block number
        return (
        wallet == settlements[index - 1].origin.wallet ?
        settlements[index - 1].origin.doneBlockNumber :
        settlements[index - 1].target.doneBlockNumber
        );
    }

    /// @notice Get the done block number of the settlement party with the given wallet, nonce and settlement role
    /// @param wallet The address of the concerned wallet
    /// @param nonce The nonce of the concerned wallet
    /// @param settlementRole The settlement role
    /// @return The done block number of the settlement wrt the given settlement role
    function settlementPartyDoneBlockNumber(address wallet, uint256 nonce,
        DriipSettlementTypesLib.SettlementRole settlementRole)
    public
    view
    returns (uint256)
    {
        // Get the 1-based index of the settlement
        uint256 index = walletNonceSettlementIndex[wallet][nonce];

        // Require the existence of settlement
        require(0 != index, "No settlement found for wallet and nonce [DriipSettlementState.sol:290]");

        // Get the settlement party
        DriipSettlementTypesLib.SettlementParty storage settlementParty =
        DriipSettlementTypesLib.SettlementRole.Origin == settlementRole ?
        settlements[index - 1].origin : settlements[index - 1].target;

        // Require that wallet is party of the right role
        require(wallet == settlementParty.wallet, "Wallet has wrong settlement role [DriipSettlementState.sol:298]");

        // Return done block number
        return settlementParty.doneBlockNumber;
    }

    /// @notice Set the max (driip) nonce
    /// @param _maxDriipNonce The max nonce
    function setMaxDriipNonce(uint256 _maxDriipNonce)
    public
    onlyEnabledServiceAction(SET_MAX_NONCE_ACTION)
    {
        maxDriipNonce = _maxDriipNonce;

        // Emit event
        emit SetMaxDriipNonceEvent(maxDriipNonce);
    }

    /// @notice Update the max driip nonce property from CommunityVote contract
    function updateMaxDriipNonceFromCommunityVote()
    public
    {
        uint256 _maxDriipNonce = communityVote.getMaxDriipNonce();
        if (0 == _maxDriipNonce)
            return;

        maxDriipNonce = _maxDriipNonce;

        // Emit event
        emit UpdateMaxDriipNonceFromCommunityVoteEvent(maxDriipNonce);
    }

    /// @notice Get the max nonce of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @return The max nonce
    function maxNonceByWalletAndCurrency(address wallet, MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (uint256)
    {
        return walletCurrencyMaxNonce[wallet][currency.ct][currency.id];
    }

    /// @notice Set the max nonce of the given wallet and currency
    /// @param wallet The address of the concerned wallet
    /// @param currency The concerned currency
    /// @param maxNonce The max nonce
    function setMaxNonceByWalletAndCurrency(address wallet, MonetaryTypesLib.Currency memory currency,
        uint256 maxNonce)
    public
    onlyEnabledServiceAction(SET_MAX_NONCE_ACTION)
    {
        // Update max nonce value
        walletCurrencyMaxNonce[wallet][currency.ct][currency.id] = maxNonce;

        // Emit event
        emit SetMaxNonceByWalletAndCurrencyEvent(wallet, currency, maxNonce);
    }

    /// @notice Get the total fee payed by the given wallet to the given beneficiary and destination
    /// in the given currency
    /// @param wallet The address of the concerned wallet
    /// @param beneficiary The concerned beneficiary
    /// @param destination The concerned destination
    /// @param currency The concerned currency
    /// @return The total fee
    function totalFee(address wallet, Beneficiary beneficiary, address destination,
        MonetaryTypesLib.Currency memory currency)
    public
    view
    returns (MonetaryTypesLib.NoncedAmount memory)
    {
        return totalFeesMap[wallet][address(beneficiary)][destination][currency.ct][currency.id];
    }

    /// @notice Set the total fee payed by the given wallet to the given beneficiary and destination
    /// in the given currency
    /// @param wallet The address of the concerned wallet
    /// @param beneficiary The concerned beneficiary
    /// @param destination The concerned destination
    /// @param _totalFee The total fee
    function setTotalFee(address wallet, Beneficiary beneficiary, address destination,
        MonetaryTypesLib.Currency memory currency, MonetaryTypesLib.NoncedAmount memory _totalFee)
    public
    onlyEnabledServiceAction(SET_FEE_TOTAL_ACTION)
    {
        // Update total fees value
        totalFeesMap[wallet][address(beneficiary)][destination][currency.ct][currency.id] = _totalFee;

        // Emit event
        emit SetTotalFeeEvent(wallet, beneficiary, destination, currency, _totalFee);
    }

    /// @notice Freeze all future settlement upgrades
    /// @dev This operation can not be undone
    function freezeUpgrades()
    public
    onlyDeployer
    {
        // Freeze upgrade
        upgradesFrozen = true;

        // Emit event
        emit FreezeUpgradesEvent();
    }

    /// @notice Upgrade settlement from other driip settlement state instance
    function upgradeSettlement(string memory settledKind, bytes32 settledHash,
        address originWallet, uint256 originNonce, bool originDone, uint256 originDoneBlockNumber,
        address targetWallet, uint256 targetNonce, bool targetDone, uint256 targetDoneBlockNumber)
    public
    onlyDeployer
    {
        // Require that upgrades have not been frozen
        require(!upgradesFrozen, "Upgrades have been frozen [DriipSettlementState.sol:413]");

        // Require that settlement has not been initialized/upgraded already
        require(0 == walletNonceSettlementIndex[originWallet][originNonce], "Settlement exists for origin wallet and nonce [DriipSettlementState.sol:416]");
        require(0 == walletNonceSettlementIndex[targetWallet][targetNonce], "Settlement exists for target wallet and nonce [DriipSettlementState.sol:417]");

        // Create new settlement
        settlements.length++;

        // Get the 0-based index
        uint256 index = settlements.length - 1;

        // Update settlement
        settlements[index].settledKind = settledKind;
        settlements[index].settledHash = settledHash;
        settlements[index].origin.nonce = originNonce;
        settlements[index].origin.wallet = originWallet;
        settlements[index].origin.done = originDone;
        settlements[index].origin.doneBlockNumber = originDoneBlockNumber;
        settlements[index].target.nonce = targetNonce;
        settlements[index].target.wallet = targetWallet;
        settlements[index].target.done = targetDone;
        settlements[index].target.doneBlockNumber = targetDoneBlockNumber;

        // Emit event
        emit UpgradeSettlementEvent(settlements[index]);

        // Store 1-based index value
        index++;
        walletSettlementIndices[originWallet].push(index);
        walletSettlementIndices[targetWallet].push(index);
        walletNonceSettlementIndex[originWallet][originNonce] = index;
        walletNonceSettlementIndex[targetWallet][targetNonce] = index;
    }
}

/*
 * Hubii Nahmii
 *
 * Compliant with the Hubii Nahmii specification v0.12.
 *
 * Copyright (C) 2017-2018 Hubii AS
 */

/**
 * @title DriipSettlementByPayment
 * @notice Where driip settlements pertaining to payment are finalized
 */
contract DriipSettlementByPayment is Ownable, Configurable, Validatable, ClientFundable, CommunityVotable,
FraudChallengable, WalletLockable, PartnerBenefactorable {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;

    //
    // Variables
    // -----------------------------------------------------------------------------------------------------------------
    DriipSettlementChallengeState public driipSettlementChallengeState;
    DriipSettlementState public driipSettlementState;
    RevenueFund public revenueFund;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event SettlePaymentEvent(address wallet, PaymentTypesLib.Payment payment, string standard);
    event SettlePaymentByProxyEvent(address proxy, address wallet, PaymentTypesLib.Payment payment, string standard);
    event SetDriipSettlementChallengeStateEvent(DriipSettlementChallengeState oldDriipSettlementChallengeState,
        DriipSettlementChallengeState newDriipSettlementChallengeState);
    event SetDriipSettlementStateEvent(DriipSettlementState oldDriipSettlementState,
        DriipSettlementState newDriipSettlementState);
    event SetRevenueFundEvent(RevenueFund oldRevenueFund, RevenueFund newRevenueFund);
    event StageFeesEvent(address wallet, int256 deltaAmount, int256 cumulativeAmount,
        address currencyCt, uint256 currencyId);

    //
    // Constructor
    // -----------------------------------------------------------------------------------------------------------------
    constructor(address deployer) Ownable(deployer) public {
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Set the driip settlement challenge state contract
    /// @param newDriipSettlementChallengeState The (address of) DriipSettlementChallengeState contract instance
    function setDriipSettlementChallengeState(DriipSettlementChallengeState newDriipSettlementChallengeState)
    public
    onlyDeployer
    notNullAddress(address(newDriipSettlementChallengeState))
    {
        DriipSettlementChallengeState oldDriipSettlementChallengeState = driipSettlementChallengeState;
        driipSettlementChallengeState = newDriipSettlementChallengeState;
        emit SetDriipSettlementChallengeStateEvent(oldDriipSettlementChallengeState, driipSettlementChallengeState);
    }

    /// @notice Set the driip settlement state contract
    /// @param newDriipSettlementState The (address of) DriipSettlementState contract instance
    function setDriipSettlementState(DriipSettlementState newDriipSettlementState)
    public
    onlyDeployer
    notNullAddress(address(newDriipSettlementState))
    {
        DriipSettlementState oldDriipSettlementState = driipSettlementState;
        driipSettlementState = newDriipSettlementState;
        emit SetDriipSettlementStateEvent(oldDriipSettlementState, driipSettlementState);
    }

    /// @notice Set the revenue fund contract
    /// @param newRevenueFund The (address of) RevenueFund contract instance
    function setRevenueFund(RevenueFund newRevenueFund)
    public
    onlyDeployer
    notNullAddress(address(newRevenueFund))
    {
        RevenueFund oldRevenueFund = revenueFund;
        revenueFund = newRevenueFund;
        emit SetRevenueFundEvent(oldRevenueFund, revenueFund);
    }

    /// @notice Get the count of settlements
    function settlementsCount()
    public
    view
    returns (uint256)
    {
        return driipSettlementState.settlementsCount();
    }

    /// @notice Get the count of settlements for given wallet
    /// @param wallet The address for which to return settlement count
    /// @return count of settlements for the provided wallet
    function settlementsCountByWallet(address wallet)
    public
    view
    returns (uint256)
    {
        return driipSettlementState.settlementsCountByWallet(wallet);
    }

    /// @notice Get settlement of given wallet and index
    /// @param wallet The address for which to return settlement
    /// @param index The wallet's settlement index
    /// @return settlement for the provided wallet and index
    function settlementByWalletAndIndex(address wallet, uint256 index)
    public
    view
    returns (DriipSettlementTypesLib.Settlement memory)
    {
        return driipSettlementState.settlementByWalletAndIndex(wallet, index);
    }

    /// @notice Get settlement of given wallet and wallet nonce
    /// @param wallet The address for which to return settlement
    /// @param nonce The wallet's nonce
    /// @return settlement for the provided wallet and index
    function settlementByWalletAndNonce(address wallet, uint256 nonce)
    public
    view
    returns (DriipSettlementTypesLib.Settlement memory)
    {
        return driipSettlementState.settlementByWalletAndNonce(wallet, nonce);
    }

    /// @notice Settle driip that is a payment
    /// @param payment The payment to be settled
    /// @param standard The standard of the token to be settled (discarded if settling ETH)
    function settlePayment(PaymentTypesLib.Payment memory payment, string memory standard)
    public
    {
        // Settle payment
        _settlePayment(msg.sender, payment, standard);

        // Emit event
        emit SettlePaymentEvent(msg.sender, payment, standard);
    }

    /// @notice Settle driip that is a payment
    /// @param wallet The wallet whose side of the payment is to be settled
    /// @param payment The payment to be settled
    /// @param standard The standard of the token to be settled (discarded if settling ETH)
    function settlePaymentByProxy(address wallet, PaymentTypesLib.Payment memory payment, string memory standard)
    public
    onlyOperator
    {
        // Settle payment for wallet
        _settlePayment(wallet, payment, standard);

        // Emit event
        emit SettlePaymentByProxyEvent(msg.sender, wallet, payment, standard);
    }

    //
    // Private functions
    // -----------------------------------------------------------------------------------------------------------------
    function _settlePayment(address wallet, PaymentTypesLib.Payment memory payment, string memory standard)
    private
    onlySealedPayment(payment)
    onlyPaymentParty(payment, wallet)
    {
        require(!fraudChallenge.isFraudulentPaymentHash(payment.seals.operator.hash), "Payment deemed fraudulent [DriipSettlementByPayment.sol:186]");
        require(!communityVote.isDoubleSpenderWallet(wallet), "Wallet deemed double spender [DriipSettlementByPayment.sol:187]");

        // Require that wallet is not locked
        require(!walletLocker.isLocked(wallet), "Wallet found locked [DriipSettlementByPayment.sol:190]");

        // Require that the wallet's current driip settlement challenge proposal is defined wrt this payment
        require(payment.seals.operator.hash == driipSettlementChallengeState.proposalChallengedHash(
            wallet, payment.currency
        ), "Payment not challenged [DriipSettlementByPayment.sol:193]");

        // Extract properties depending on settlement role
        (
        DriipSettlementTypesLib.SettlementRole settlementRole, uint256 nonce,
        NahmiiTypesLib.OriginFigure[] memory totalFees, int256 currentBalance
        ) = _getRoleProperties(payment, wallet);

        // Require that driip settlement challenge proposal has been initiated
        require(driipSettlementChallengeState.hasProposal(wallet, nonce, payment.currency), "No proposal found [DriipSettlementByPayment.sol:204]");

        // Require that driip settlement challenge proposal has not been terminated already
        require(!driipSettlementChallengeState.hasProposalTerminated(wallet, payment.currency), "Proposal found terminated [DriipSettlementByPayment.sol:207]");

        // Require that driip settlement challenge proposal has expired
        require(driipSettlementChallengeState.hasProposalExpired(wallet, payment.currency), "Proposal found not expired [DriipSettlementByPayment.sol:210]");

        // Require that driip settlement challenge proposal qualified
        require(SettlementChallengeTypesLib.Status.Qualified == driipSettlementChallengeState.proposalStatus(
            wallet, payment.currency
        ), "Proposal found not qualified [DriipSettlementByPayment.sol:213]");

        // Require that operational mode is normal and data is available
        require(configuration.isOperationalModeNormal(), "Not normal operational mode [DriipSettlementByPayment.sol:218]");
        require(communityVote.isDataAvailable(), "Data not available [DriipSettlementByPayment.sol:219]");

        // Init settlement, i.e. create one if no such settlement exists for the double pair of wallets and nonces
        driipSettlementState.initSettlement(
            PaymentTypesLib.PAYMENT_KIND(), payment.seals.operator.hash,
            payment.sender.wallet, payment.sender.nonce,
            payment.recipient.wallet, payment.recipient.nonce
        );

        // If exists settlement of nonce then require that wallet has not already settled
        require(!driipSettlementState.isSettlementPartyDone(
            wallet, nonce, settlementRole
        ), "Settlement party already done [DriipSettlementByPayment.sol:229]");

        // Set address of origin or target to prevent the same settlement from being resettled by this wallet
        driipSettlementState.completeSettlementParty(
            wallet, nonce, settlementRole, true
        );

        // If wallet has previously settled balance of the concerned currency with higher wallet nonce, then don't
        // settle balance again
        if (driipSettlementState.maxNonceByWalletAndCurrency(wallet, payment.currency) < nonce) {
            // Update settled nonce of wallet and currency
            driipSettlementState.setMaxNonceByWalletAndCurrency(wallet, payment.currency, nonce);

            // Update settled balance
            clientFund.updateSettledBalance(
                wallet, currentBalance, payment.currency.ct, payment.currency.id, standard, payment.blockNumber
            );

            // Stage (stage function assures positive amount only)
            clientFund.stage(
                wallet, driipSettlementChallengeState.proposalStageAmount(wallet, payment.currency),
                payment.currency.ct, payment.currency.id, standard
            );

            // Stage fees to revenue fund
            if (address(0) != address(revenueFund))
                _stageFees(wallet, totalFees, revenueFund, nonce, standard);
        }

        // Remove driip settlement challenge proposal
        driipSettlementChallengeState.terminateProposal(wallet, payment.currency, false);
    }

    function _getRoleProperties(PaymentTypesLib.Payment memory payment, address wallet)
    private
    view
    returns (
        DriipSettlementTypesLib.SettlementRole settlementRole, uint256 walletNonce,
        NahmiiTypesLib.OriginFigure[] memory totalFees, int256 currentBalance
    )
    {
        if (validator.isPaymentSender(payment, wallet)) {
            settlementRole = DriipSettlementTypesLib.SettlementRole.Origin;
            walletNonce = payment.sender.nonce;
            totalFees = payment.sender.fees.total;
            currentBalance = payment.sender.balances.current;

        } else {
            settlementRole = DriipSettlementTypesLib.SettlementRole.Target;
            walletNonce = payment.recipient.nonce;
            totalFees = payment.recipient.fees.total;
            currentBalance = payment.recipient.balances.current;
        }
    }

    function _stageFees(address wallet, NahmiiTypesLib.OriginFigure[] memory fees,
        Beneficiary protocolBeneficiary, uint256 nonce, string memory standard)
    private
    {
        // For each origin figure...
        for (uint256 i = 0; i < fees.length; i++) {
            // Based on originId determine the fee beneficiary
            Beneficiary beneficiary;
            if (0 == fees[i].originId)
                beneficiary = protocolBeneficiary;
            else if (
                0 < partnerBenefactor.registeredBeneficiariesCount() &&
                fees[i].originId <= partnerBenefactor.registeredBeneficiariesCount()
            )
                beneficiary = partnerBenefactor.beneficiaries(fees[i].originId - 1);

            // Continue if there is no beneficiary corresponding to the origin ID
            if (address(0) == address(beneficiary))
                continue;

            // Define destination from origin ID
            address destination = address(fees[i].originId);

            if (driipSettlementState.totalFee(wallet, beneficiary, destination, fees[i].figure.currency).nonce < nonce) {
                // Get the amount previously staged
                int256 deltaAmount = fees[i].figure.amount - driipSettlementState.totalFee(wallet, beneficiary, destination, fees[i].figure.currency).amount;

                // Update fee total
                driipSettlementState.setTotalFee(wallet, beneficiary, destination, fees[i].figure.currency, MonetaryTypesLib.NoncedAmount(nonce, fees[i].figure.amount));

                // Stage to beneficiary
                clientFund.transferToBeneficiary(
                    wallet, beneficiary, deltaAmount, fees[i].figure.currency.ct, fees[i].figure.currency.id, standard
                );

                // Emit event
                emit StageFeesEvent(
                    wallet, deltaAmount, fees[i].figure.amount, fees[i].figure.currency.ct, fees[i].figure.currency.id
                );
            }
        }
    }
}