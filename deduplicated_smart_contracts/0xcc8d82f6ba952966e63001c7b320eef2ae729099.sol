/**

 *Submitted for verification at Etherscan.io on 2019-07-12

*/



pragma solidity ^0.4.25;

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
 * @title Beneficiary
 * @notice A recipient of ethers and tokens
 */
contract Beneficiary {
    /// @notice Receive ethers to the given wallet's given balance type
    /// @param wallet The address of the concerned wallet
    /// @param balanceType The target balance type of the wallet
    function receiveEthersTo(address wallet, string balanceType)
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
    function receiveTokensTo(address wallet, string balanceType, int256 amount, address currencyCt,
        uint256 currencyId, string standard)
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
    address[] internal beneficiaries;
    mapping(address => uint256) internal beneficiaryIndexByAddress;

    //
    // Events
    // -----------------------------------------------------------------------------------------------------------------
    event RegisterBeneficiaryEvent(address beneficiary);
    event DeregisterBeneficiaryEvent(address beneficiary);

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    /// @notice Register the given beneficiary
    /// @param beneficiary Address of beneficiary to be registered
    function registerBeneficiary(address beneficiary)
    public
    onlyDeployer
    notNullAddress(beneficiary)
    returns (bool)
    {
        if (beneficiaryIndexByAddress[beneficiary] > 0)
            return false;

        beneficiaries.push(beneficiary);
        beneficiaryIndexByAddress[beneficiary] = beneficiaries.length;

        // Emit event
        emit RegisterBeneficiaryEvent(beneficiary);

        return true;
    }

    /// @notice Deregister the given beneficiary
    /// @param beneficiary Address of beneficiary to be deregistered
    function deregisterBeneficiary(address beneficiary)
    public
    onlyDeployer
    notNullAddress(beneficiary)
    returns (bool)
    {
        if (beneficiaryIndexByAddress[beneficiary] == 0)
            return false;

        uint256 idx = beneficiaryIndexByAddress[beneficiary] - 1;
        if (idx < beneficiaries.length - 1) {
            // Remap the last item in the array to this index
            beneficiaries[idx] = beneficiaries[beneficiaries.length - 1];
            beneficiaryIndexByAddress[beneficiaries[idx]] = idx + 1;
        }
        beneficiaries.length--;
        beneficiaryIndexByAddress[beneficiary] = 0;

        // Emit event
        emit DeregisterBeneficiaryEvent(beneficiary);

        return true;
    }

    /// @notice Gauge whether the given address is the one of a registered beneficiary
    /// @param beneficiary Address of beneficiary
    /// @return true if beneficiary is registered, else false
    function isRegisteredBeneficiary(address beneficiary)
    public
    view
    returns (bool)
    {
        return beneficiaryIndexByAddress[beneficiary] > 0;
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
    function enableServiceAction(address service, string action)
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
    function disableServiceAction(address service, string action)
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
    function isEnabledServiceAction(address service, string action)
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
    function hashString(string _string)
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

    modifier onlyEnabledServiceAction(string action) {
        require(isEnabledServiceAction(msg.sender, action));
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
    function authorizeRegisteredServiceAction(address service, string action)
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
    function unauthorizeRegisteredServiceAction(address service, string action)
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
    function isAuthorizedRegisteredServiceAction(address service, string action, address wallet)
    public
    view
    returns (bool)
    {
        bytes32 actionHash = hashString(action);

        return isEnabledServiceAction(service, action) &&
        (isInitialServiceAuthorizedForWallet(service, wallet) || serviceActionWalletAuthorizedMap[service][actionHash][wallet]);
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

    modifier onlyAuthorizedServiceAction(string action, address wallet) {
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
    mapping(bytes32 => address) registeredTransferControllers;
    mapping(address => CurrencyInfo) registeredCurrencies;

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
    function registerTransferController(string standard, address controller)
    external
    onlyDeployer
    notNullAddress(controller)
    {
        require(bytes(standard).length > 0);
        bytes32 standardHash = keccak256(abi.encodePacked(standard));

        require(registeredTransferControllers[standardHash] == address(0));

        registeredTransferControllers[standardHash] = controller;

        // Emit event
        emit RegisterTransferControllerEvent(standard, controller);
    }

    function reassociateTransferController(string oldStandard, string newStandard, address controller)
    external
    onlyDeployer
    notNullAddress(controller)
    {
        require(bytes(newStandard).length > 0);
        bytes32 oldStandardHash = keccak256(abi.encodePacked(oldStandard));
        bytes32 newStandardHash = keccak256(abi.encodePacked(newStandard));

        require(registeredTransferControllers[oldStandardHash] != address(0));
        require(registeredTransferControllers[newStandardHash] == address(0));

        registeredTransferControllers[newStandardHash] = registeredTransferControllers[oldStandardHash];
        registeredTransferControllers[oldStandardHash] = address(0);

        // Emit event
        emit ReassociateTransferControllerEvent(oldStandard, newStandard, controller);
    }

    function registerCurrency(address currencyCt, string standard)
    external
    onlyOperator
    notNullAddress(currencyCt)
    {
        require(bytes(standard).length > 0);
        bytes32 standardHash = keccak256(abi.encodePacked(standard));

        require(registeredCurrencies[currencyCt].standard == bytes32(0));

        registeredCurrencies[currencyCt].standard = standardHash;

        // Emit event
        emit RegisterCurrencyEvent(currencyCt, standard);
    }

    function deregisterCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != 0);

        registeredCurrencies[currencyCt].standard = bytes32(0);
        registeredCurrencies[currencyCt].blacklisted = false;

        // Emit event
        emit DeregisterCurrencyEvent(currencyCt);
    }

    function blacklistCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != bytes32(0));

        registeredCurrencies[currencyCt].blacklisted = true;

        // Emit event
        emit BlacklistCurrencyEvent(currencyCt);
    }

    function whitelistCurrency(address currencyCt)
    external
    onlyOperator
    {
        require(registeredCurrencies[currencyCt].standard != bytes32(0));

        registeredCurrencies[currencyCt].blacklisted = false;

        // Emit event
        emit WhitelistCurrencyEvent(currencyCt);
    }

    /**
    @notice The provided standard takes priority over assigned interface to currency
    */
    function transferController(address currencyCt, string standard)
    public
    view
    returns (TransferController)
    {
        if (bytes(standard).length > 0) {
            bytes32 standardHash = keccak256(abi.encodePacked(standard));

            require(registeredTransferControllers[standardHash] != address(0));
            return TransferController(registeredTransferControllers[standardHash]);
        }

        require(registeredCurrencies[currencyCt].standard != bytes32(0));
        require(!registeredCurrencies[currencyCt].blacklisted);

        address controllerAddress = registeredTransferControllers[registeredCurrencies[currencyCt].standard];
        require(controllerAddress != address(0));

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
    notNullAddress(newTransferControllerManager)
    notSameAddresses(newTransferControllerManager, transferControllerManager)
    {
        //set new currency manager
        TransferControllerManager oldTransferControllerManager = transferControllerManager;
        transferControllerManager = newTransferControllerManager;

        // Emit event
        emit SetTransferControllerManagerEvent(oldTransferControllerManager, newTransferControllerManager);
    }

    /// @notice Get the transfer controller of the given currency contract address and standard
    function transferController(address currencyCt, string standard)
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
        require(transferControllerManager != address(0));
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
        require(index < self.currencies.length);

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
    returns (MonetaryTypesLib.Currency)
    {
        require(index < self.currencies.length);
        return self.currencies[index];
    }

    function getByIndices(Currencies storage self, uint256 low, uint256 up)
    internal
    view
    returns (MonetaryTypesLib.Currency[])
    {
        require(0 < self.currencies.length);
        require(low <= up);

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
    returns (int256[])
    {
        return self.idsByCurrency[currencyCt][currencyId];
    }

    function getByIndices(Balance storage self, address currencyCt, uint256 currencyId, uint256 indexLow, uint256 indexUp)
    internal
    view
    returns (int256[])
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
    returns (int256[], uint256)
    {
        uint256 index = indexByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return 0 < index ? recordByIndex(self, currencyCt, currencyId, index - 1) : (new int256[](0), 0);
    }

    function recordByIndex(Balance storage self, address currencyCt, uint256 currencyId, uint256 index)
    internal
    view
    returns (int256[], uint256)
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
    returns (int256[], uint256)
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

    function set(Balance storage self, int256[] ids, address currencyCt, uint256 currencyId)
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
    returns (int256[])
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
    returns (int256[])
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
    function setIds(address wallet, bytes32 _type, int256[] ids, address currencyCt, uint256 currencyId)
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
    returns (int256[] ids, uint256 blockNumber)
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
    returns (int256[] ids, uint256 blockNumber)
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
    returns (int256[] ids, uint256 blockNumber)
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
    returns (bytes32[])
    {
        return _allBalanceTypes;
    }

    /// @notice Get the default set of active balance types
    /// @return The set of active balance types
    function activeBalanceTypes()
    public
    view
    returns (bytes32[])
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
    returns (address[])
    {
        require(0 < trackedWallets.length);
        require(low <= up);

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
    notNullAddress(newBalanceTracker)
    notSameAddresses(newBalanceTracker, balanceTracker)
    {
        // Require that this contract has not been frozen
        require(!balanceTrackerFrozen);

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
        require(balanceTracker != address(0));
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
        require(0 < transactionLogByWalletType[wallet][_type].records.length);
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
        require(0 < transactionLogByWalletType[wallet][_type].recordIndicesByCurrency[currencyCt][currencyId].length);
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
    notNullAddress(newTransactionTracker)
    notSameAddresses(newTransactionTracker, transactionTracker)
    {
        // Require that this contract has not been frozen
        require(!transactionTrackerFrozen);

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
        require(transactionTracker != address(0));
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
    returns (Entry)
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
    returns (Entry)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbUints storage self, uint256 blockNumber, uint256 value)
    internal
    {
        require(
            0 == self.entries.length ||
            blockNumber > self.entries[self.entries.length - 1].blockNumber
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
    returns (Entry[])
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbUints storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length);
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
    returns (Entry)
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
    returns (Entry)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addEntry(BlockNumbInts storage self, uint256 blockNumber, int256 value)
    internal
    {
        require(
            0 == self.entries.length ||
            blockNumber > self.entries[self.entries.length - 1].blockNumber
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
    returns (Entry[])
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbInts storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length);
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
    returns (Entry)
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
    returns (Entry)
    {
        return self.entries[indexByBlockNumber(self, _blockNumber)];
    }

    function addNominalEntry(BlockNumbDisdInts storage self, uint256 blockNumber, int256 nominal)
    internal
    {
        require(
            0 == self.entries.length ||
            blockNumber > self.entries[self.entries.length - 1].blockNumber
        );

        self.entries.length++;
        Entry storage entry = self.entries[self.entries.length - 1];

        entry.blockNumber = blockNumber;
        entry.nominal = nominal;
    }

    function addDiscountedEntry(BlockNumbDisdInts storage self, uint256 blockNumber, int256 nominal,
        int256[] discountTiers, int256[] discountValues)
    internal
    {
        require(discountTiers.length == discountValues.length);

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
    returns (Entry[])
    {
        return self.entries;
    }

    function indexByBlockNumber(BlockNumbDisdInts storage self, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entries.length);
        for (uint256 i = self.entries.length - 1; i >= 0; i--)
            if (blockNumber >= self.entries[i].blockNumber)
                return i;
        revert();
    }

    /// @dev The index returned here is 1-based
    function indexByTier(Discount[] discounts, int256 tier)
    internal
    pure
    returns (uint256)
    {
        require(0 < discounts.length);
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





library BlockNumbCurrenciesLib {
    //
    // Structures
    // -----------------------------------------------------------------------------------------------------------------
    struct Entry {
        uint256 blockNumber;
        MonetaryTypesLib.Currency currency;
    }

    struct BlockNumbCurrencies {
        mapping(address => mapping(uint256 => Entry[])) entriesByCurrency;
    }

    //
    // Functions
    // -----------------------------------------------------------------------------------------------------------------
    function currentCurrency(BlockNumbCurrencies storage self, MonetaryTypesLib.Currency referenceCurrency)
    internal
    view
    returns (MonetaryTypesLib.Currency storage)
    {
        return currencyAt(self, referenceCurrency, block.number);
    }

    function currentEntry(BlockNumbCurrencies storage self, MonetaryTypesLib.Currency referenceCurrency)
    internal
    view
    returns (Entry storage)
    {
        return entryAt(self, referenceCurrency, block.number);
    }

    function currencyAt(BlockNumbCurrencies storage self, MonetaryTypesLib.Currency referenceCurrency,
        uint256 _blockNumber)
    internal
    view
    returns (MonetaryTypesLib.Currency storage)
    {
        return entryAt(self, referenceCurrency, _blockNumber).currency;
    }

    function entryAt(BlockNumbCurrencies storage self, MonetaryTypesLib.Currency referenceCurrency,
        uint256 _blockNumber)
    internal
    view
    returns (Entry storage)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][indexByBlockNumber(self, referenceCurrency, _blockNumber)];
    }

    function addEntry(BlockNumbCurrencies storage self, uint256 blockNumber,
        MonetaryTypesLib.Currency referenceCurrency, MonetaryTypesLib.Currency currency)
    internal
    {
        require(
            0 == self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length ||
            blockNumber > self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id][self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length - 1].blockNumber
        );

        self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].push(Entry(blockNumber, currency));
    }

    function count(BlockNumbCurrencies storage self, MonetaryTypesLib.Currency referenceCurrency)
    internal
    view
    returns (uint256)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length;
    }

    function entriesByCurrency(BlockNumbCurrencies storage self, MonetaryTypesLib.Currency referenceCurrency)
    internal
    view
    returns (Entry[] storage)
    {
        return self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id];
    }

    function indexByBlockNumber(BlockNumbCurrencies storage self, MonetaryTypesLib.Currency referenceCurrency, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        require(0 < self.entriesByCurrency[referenceCurrency.ct][referenceCurrency.id].length);
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















/**
 * @title Configuration
 * @notice An oracle for configurations values
 */
contract Configuration is Modifiable, Ownable, Servable {
    using SafeMathIntLib for int256;
    using BlockNumbUintsLib for BlockNumbUintsLib.BlockNumbUints;
    using BlockNumbIntsLib for BlockNumbIntsLib.BlockNumbInts;
    using BlockNumbDisdIntsLib for BlockNumbDisdIntsLib.BlockNumbDisdInts;
    using BlockNumbCurrenciesLib for BlockNumbCurrenciesLib.BlockNumbCurrencies;

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

    BlockNumbCurrenciesLib.BlockNumbCurrencies private feeCurrencies;

    BlockNumbUintsLib.BlockNumbUints private walletLockTimeoutByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private cancelOrderChallengeTimeoutByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private settlementChallengeTimeoutByBlockNumber;

    BlockNumbUintsLib.BlockNumbUints private walletSettlementStakeFractionByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private operatorSettlementStakeFractionByBlockNumber;
    BlockNumbUintsLib.BlockNumbUints private fraudStakeFractionByBlockNumber;

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
    function setTradeMakerFee(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues)
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
    function setTradeTakerFee(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues)
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
    function setPaymentFee(uint256 fromBlockNumber, int256 nominal, int256[] discountTiers, int256[] discountValues)
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
        int256[] discountTiers, int256[] discountValues)
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
        return feeCurrencies.count(MonetaryTypesLib.Currency(currencyCt, currencyId));
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
        MonetaryTypesLib.Currency storage _feeCurrency = feeCurrencies.currencyAt(
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
        feeCurrencies.addEntry(
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

    /// @notice Set the block number of the earliest settlement initiation
    /// @param _earliestSettlementBlockNumber The block number of the earliest settlement
    function setEarliestSettlementBlockNumber(uint256 _earliestSettlementBlockNumber)
    public
    onlyOperator
    {
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
        blockNumber >= block.number + updateDelayBlocksByBlockNumber.currentValue()
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
    notNullAddress(newConfiguration)
    notSameAddresses(newConfiguration, configuration)
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
        require(configuration != address(0));
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
        uint256 unlockTime;
    }

    struct NonFungibleLock {
        address locker;
        address currencyCt;
        uint256 currencyId;
        int256[] ids;
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
        address currencyCt, uint256 currencyId);
    event LockNonFungibleByProxyEvent(address lockedWallet, address lockerWallet, int256[] ids,
        address currencyCt, uint256 currencyId);
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
    function lockFungibleByProxy(address lockedWallet, address lockerWallet, int256 amount,
        address currencyCt, uint256 currencyId)
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
        walletFungibleLocks[lockedWallet][lockIndex - 1].unlockTime =
        block.timestamp.add(configuration.walletLockTimeout());

        // Emit event
        emit LockFungibleByProxyEvent(lockedWallet, lockerWallet, amount, currencyCt, currencyId);
    }

    /// @notice Lock the given locked wallet's non-fungible IDs of currency on behalf of the given locker wallet
    /// @param lockedWallet The address of wallet that will be locked
    /// @param lockerWallet The address of wallet that locks
    /// @param ids The IDs to be locked
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    function lockNonFungibleByProxy(address lockedWallet, address lockerWallet, int256[] ids,
        address currencyCt, uint256 currencyId)
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
        walletNonFungibleLocks[lockedWallet][lockIndex - 1].unlockTime =
        block.timestamp.add(configuration.walletLockTimeout());

        // Emit event
        emit LockNonFungibleByProxyEvent(lockedWallet, lockerWallet, ids, currencyCt, currencyId);
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

        if (0 == lockIndex)
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

        if (0 == lockIndex)
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
    returns (int256[])
    {
        uint256 lockIndex = lockedCurrencyLockerNonFungibleLockIndex[lockedWallet][currencyCt][currencyId][lockerWallet];

        if (0 == lockIndex)
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
    returns (int256[])
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
    notNullAddress(newWalletLocker)
    notSameAddresses(newWalletLocker, walletLocker)
    {
        // Require that this contract has not been frozen
        require(!walletLockerFrozen);

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
        require(walletLocker != address(0));
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
    function closeAccrualPeriod(MonetaryTypesLib.Currency[])
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
        require(index < self.deposits.length);

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
        require(index < self.currencyDeposits[currencyCt][currencyId].length);

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
        require(index < self.withdrawals.length);

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
        require(index < self.currencyWithdrawals[currencyCt][currencyId].length);

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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
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
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
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
        require(!mintingDisabled);

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
        require(0 == value || 0 == allowance(msg.sender, spender));

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
        require(startBlock < endBlock);
        require(account != address(0));

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
    returns (address[])
    {
        require(low <= up);

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
        for (i = low; i <= up; i++)
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
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
    notNullOrThisAddress(_token)
    {
        // Require that the token has not previously been set
        require(address(token) == address(0));

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
    function defineReleases(uint256[] earliestReleaseTimes, uint256[] amounts, uint256[] releaseBlockNumbers)
    onlyOperator
    public
    {
        require(earliestReleaseTimes.length == amounts.length);
        require(earliestReleaseTimes.length >= releaseBlockNumbers.length);

        // Require that token address has been set
        require(address(token) != address(0));

        for (uint256 i = 0; i < earliestReleaseTimes.length; i++) {
            // Update the total amount locked by this contract
            totalLockedAmount += amounts[i];

            // Require that total amount locked is smaller than or equal to the token balance of
            // this contract
            require(token.balanceOf(address(this)) >= totalLockedAmount);

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
        require(!releases[index].done);

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
        require(0 < _release.amount);

        // Require that this release has not already been executed
        require(!_release.done);

        // Require that the current timestamp is beyond the nominal release time
        require(block.timestamp >= _release.earliestReleaseTime);

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
        require(msg.sender == beneficiary);
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
        require(startBlock < endBlock);

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
    mapping(address => mapping(uint256 => mapping(uint256 => int256))) aggregateAccrualAmountByCurrencyBlockNumber;

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
    notNullAddress(newRevenueTokenManager)
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
    function() public payable {
        receiveEthersTo(msg.sender, "");
    }

    /// @notice Receive ethers to
    /// @param wallet The concerned wallet address
    function receiveEthersTo(address wallet, string)
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
    function receiveTokens(string, int256 amount, address currencyCt, uint256 currencyId,
        string standard)
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
    function receiveTokensTo(address wallet, string, int256 amount, address currencyCt,
        uint256 currencyId, string standard)
    public
    {
        require(amount.isNonZeroPositiveInt256());

        // Execute transfer
        TransferController controller = transferController(currencyCt, standard);
        require(
            address(controller).delegatecall(
                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId
            )
        );

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
    returns (MonetaryTypesLib.Currency[])
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
    returns (MonetaryTypesLib.Currency[])
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
    function closeAccrualPeriod(MonetaryTypesLib.Currency[] currencies)
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
    function claimAndTransferToBeneficiary(Beneficiary beneficiary, address destWallet, string balanceType,
        address currencyCt, uint256 currencyId, string standard)
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
            require(
                address(controller).delegatecall(
                    controller.getApproveSignature(), beneficiary, uint256(claimedAmount), currencyCt, currencyId
                )
            );

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
    function withdraw(int256 amount, address currencyCt, uint256 currencyId, string standard)
    public
    {
        // Require that amount is strictly positive
        require(amount.isNonZeroPositiveInt256());

        // Clamp amount to the max given by staged balance
        amount = amount.clampMax(stagedByWallet[msg.sender].get(currencyCt, currencyId));

        // Subtract to per-wallet staged balance
        stagedByWallet[msg.sender].sub(amount, currencyCt, currencyId);

        // Execute transfer
        if (address(0) == currencyCt && 0 == currencyId)
            msg.sender.transfer(uint256(amount));

        else {
            TransferController controller = transferController(currencyCt, standard);
            require(
                address(controller).delegatecall(
                    controller.getDispatchSignature(), this, msg.sender, uint256(amount), currencyCt, currencyId
                )
            );
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
        require(0 < accrualBlockNumbersByCurrency[currencyCt][currencyId].length);

        // Calculate lower block number as last accrual block number claimed for currency c by wallet OR 0
        uint256[] storage claimedAccrualBlockNumbers = claimedAccrualBlockNumbersByWalletCurrency[wallet][currencyCt][currencyId];
        uint256 bnLow = (0 == claimedAccrualBlockNumbers.length ? 0 : claimedAccrualBlockNumbers[claimedAccrualBlockNumbers.length - 1]);

        // Set upper block number as last accrual block number
        uint256 bnUp = accrualBlockNumbersByCurrency[currencyCt][currencyId][accrualBlockNumbersByCurrency[currencyCt][currencyId].length - 1];

        // Require that lower block number is below upper block number
        require(bnLow < bnUp);

        // Calculate the amount that is claimable in the span between lower and upper block numbers
        int256 claimableAmount = aggregateAccrualAmountByCurrencyBlockNumber[currencyCt][currencyId][bnUp]
        - (0 == bnLow ? 0 : aggregateAccrualAmountByCurrencyBlockNumber[currencyCt][currencyId][bnLow]);

        // Require that claimable amount is strictly positive
        require(0 < claimableAmount);

        // Retrieve the balance blocks of wallet
        int256 walletBalanceBlocks = int256(
            RevenueToken(revenueTokenManager.token()).balanceBlocksIn(wallet, bnLow, bnUp)
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

    function _transferToBeneficiary(Beneficiary beneficiary, address destWallet, string balanceType,
        int256 amount, address currencyCt, uint256 currencyId, string standard)
    private
    {
        // Transfer ETH to the beneficiary
        if (address(0) == currencyCt && 0 == currencyId)
            beneficiary.receiveEthersTo.value(uint256(amount))(destWallet, balanceType);

        else {
            // Approve of beneficiary
            TransferController controller = transferController(currencyCt, standard);
            require(
                address(controller).delegatecall(
                    controller.getApproveSignature(), beneficiary, uint256(amount), currencyCt, currencyId
                )
            );

            // Transfer tokens to the beneficiary
            beneficiary.receiveTokensTo(destWallet, balanceType, amount, currencyCt, currencyId, standard);
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
 * @title Client fund
 * @notice Where clients�� crypto is deposited into, staged and withdrawn from.
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
    event StageEvent(address wallet, int256 value, address currencyCt, uint256 currencyId);
    event UnstageEvent(address wallet, int256 value, address currencyCt, uint256 currencyId);
    event UpdateSettledBalanceEvent(address wallet, int256 value, address currencyCt,
        uint256 currencyId);
    event StageToBeneficiaryEvent(address sourceWallet, address beneficiary, int256 value,
        address currencyCt, uint256 currencyId, string standard);
    event TransferToBeneficiaryEvent(address wallet, address beneficiary, int256 value,
        address currencyCt, uint256 currencyId);
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
    notNullAddress(newTokenHolderRevenueFund)
    notSameAddresses(newTokenHolderRevenueFund, tokenHolderRevenueFund)
    {
        // Set new token holder revenue fund
        TokenHolderRevenueFund oldTokenHolderRevenueFund = tokenHolderRevenueFund;
        tokenHolderRevenueFund = newTokenHolderRevenueFund;

        // Emit event
        emit SetTokenHolderRevenueFundEvent(oldTokenHolderRevenueFund, newTokenHolderRevenueFund);
    }

    /// @notice Fallback function that deposits ethers to msg.sender's deposited balance
    function()
    public
    payable
    {
        receiveEthersTo(msg.sender, balanceTracker.DEPOSITED_BALANCE_TYPE());
    }

    /// @notice Receive ethers to the given wallet's balance of the given type
    /// @param wallet The address of the concerned wallet
    /// @param balanceType The target balance type
    function receiveEthersTo(address wallet, string balanceType)
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
    function receiveTokens(string balanceType, int256 value, address currencyCt,
        uint256 currencyId, string standard)
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
    function receiveTokensTo(address wallet, string balanceType, int256 value, address currencyCt,
        uint256 currencyId, string standard)
    public
    {
        require(value.isNonZeroPositiveInt256());

        // Get transfer controller
        TransferController controller = transferController(currencyCt, standard);

        // Execute transfer
        require(
            address(controller).delegatecall(
                controller.getReceiveSignature(), msg.sender, this, uint256(value), currencyCt, currencyId
            )
        );

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
        string standard, uint256 blockNumber)
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
        string standard)
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
        emit StageEvent(wallet, value, currencyCt, currencyId);
    }

    /// @notice Unstage a staged value
    /// @param value The value (amount of fungible, id of non-fungible) to deposit
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function unstage(int256 value, address currencyCt, uint256 currencyId, string standard)
    public
    {
        require(value.isNonZeroPositiveInt256());

        // Deduce fungibility
        bool fungible = _isFungible(currencyCt, currencyId, standard);

        // Subtract unstage value from staged
        value = _subtractFromStaged(msg.sender, value, currencyCt, currencyId, fungible);

        balanceTracker.add(
            msg.sender, balanceTracker.depositedBalanceType(), value, currencyCt, currencyId, fungible
        );

        // Emit event
        emit UnstageEvent(msg.sender, value, currencyCt, currencyId);
    }

    /// @notice Stage the value from wallet to the given beneficiary and targeted to wallet
    /// @param wallet The address of the concerned wallet
    /// @param beneficiary The (address of) concerned beneficiary contract
    /// @param value The value (amount of fungible, id of non-fungible) to stage
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function stageToBeneficiary(address wallet, Beneficiary beneficiary, int256 value,
        address currencyCt, uint256 currencyId, string standard)
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
        address currencyCt, uint256 currencyId, string standard)
    public
    onlyAuthorizedService(wallet)
    {
        // Execute transfer
        _transferToBeneficiary(wallet, beneficiary, value, currencyCt, currencyId, standard);

        // Emit event
        emit TransferToBeneficiaryEvent(wallet, beneficiary, value, currencyCt, currencyId);
    }

    /// @notice Seize balances in the given currency of the given wallet, provided that the wallet
    /// is locked by the caller
    /// @param wallet The address of the concerned wallet whose balances are seized
    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)
    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)
    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")
    function seizeBalances(address wallet, address currencyCt, uint256 currencyId, string standard)
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
    function withdraw(int256 value, address currencyCt, uint256 currencyId, string standard)
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
    function claimRevenue(address claimer, string balanceType, address currencyCt,
        uint256 currencyId, string standard)
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
    function _receiveTo(address wallet, string balanceType, int256 value, address currencyCt,
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

    function _subtractSequentially(address wallet, bytes32[] balanceTypes, int256 value, address currencyCt,
        uint256 currencyId, bool fungible)
    private
    returns (int256)
    {
        if (fungible)
            return _subtractFungibleSequentially(wallet, balanceTypes, value, currencyCt, currencyId);
        else
            return _subtractNonFungibleSequentially(wallet, balanceTypes, value, currencyCt, currencyId);
    }

    function _subtractFungibleSequentially(address wallet, bytes32[] balanceTypes, int256 amount, address currencyCt, uint256 currencyId)
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

    function _subtractNonFungibleSequentially(address wallet, bytes32[] balanceTypes, int256 id, address currencyCt, uint256 currencyId)
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
        int256 value, address currencyCt, uint256 currencyId, string standard)
    private
    {
        require(value.isNonZeroPositiveInt256());
        require(isRegisteredBeneficiary(beneficiary));

        // Transfer funds to the beneficiary
        if (address(0) == currencyCt && 0 == currencyId)
            beneficiary.receiveEthersTo.value(uint256(value))(destWallet, "");

        else {
            // Approve of beneficiary
            TransferController controller = transferController(currencyCt, standard);
            require(
                address(controller).delegatecall(
                    controller.getApproveSignature(), beneficiary, uint256(value), currencyCt, currencyId
                )
            );

            // Transfer funds to the beneficiary
            beneficiary.receiveTokensTo(destWallet, "", value, currencyCt, currencyId, standard);
        }
    }

    function _transferToWallet(address wallet,
        int256 value, address currencyCt, uint256 currencyId, string standard)
    private
    {
        // Transfer ETH
        if (address(0) == currencyCt && 0 == currencyId)
            wallet.transfer(uint256(value));

        // Transfer token
        else {
            TransferController controller = transferController(currencyCt, standard);
            require(
                address(controller).delegatecall(
                    controller.getDispatchSignature(), this, wallet, uint256(value), currencyCt, currencyId
                )
            );
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

    function _isFungible(address currencyCt, uint256 currencyId, string standard)
    private
    view
    returns (bool)
    {
        return (address(0) == currencyCt && 0 == currencyId) || transferController(currencyCt, standard).isFungible();
    }
}