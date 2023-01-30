/**

 *Submitted for verification at Etherscan.io on 2019-04-05

*/



pragma solidity ^0.5.1;



contract LockRequestable {



        // MEMBERS

        /// @notice  the count of all invocations of `generateLockId`.

        uint256 public lockRequestCount;



        constructor() public {

                lockRequestCount = 0;

        }



        // FUNCTIONS

        /** @notice  Returns a fresh unique identifier.

            *

            * @dev the generation scheme uses three components.

            * First, the blockhash of the previous block.

            * Second, the deployed address.

            * Third, the next value of the counter.

            * This ensure that identifiers are unique across all contracts

            * following this scheme, and that future identifiers are

            * unpredictable.

            *

            * @return a 32-byte unique identifier.

            */

        function generateLockId() internal returns (bytes32 lockId) {

                return keccak256(

                abi.encodePacked(blockhash(block.number - 1), address(this), ++lockRequestCount)

                );

        }

}



contract CustodianUpgradeable is LockRequestable {



        // TYPES

        /// @dev  The struct type for pending custodian changes.

        struct CustodianChangeRequest {

                address proposedNew;

        }



        // MEMBERS

        /// @dev  The address of the account or contract that acts as the custodian.

        address public custodian;



        /// @dev  The map of lock ids to pending custodian changes.

        mapping (bytes32 => CustodianChangeRequest) public custodianChangeReqs;



        constructor(address _custodian) public LockRequestable() {

                custodian = _custodian;

        }



        // MODIFIERS

        modifier onlyCustodian {

                require(msg.sender == custodian);

                _;

        }



        /** @notice  Requests a change of the custodian associated with this contract.

            *

            * @dev  Returns a unique lock id associated with the request.

            * Anyone can call this function, but confirming the request is authorized

            * by the custodian.

            *

            * @param  _proposedCustodian  The address of the new custodian.

            * @return  lockId  A unique identifier for this request.

            */

        function requestCustodianChange(address _proposedCustodian) public returns (bytes32 lockId) {

                require(_proposedCustodian != address(0));



                lockId = generateLockId();



                custodianChangeReqs[lockId] = CustodianChangeRequest({

                        proposedNew: _proposedCustodian

                });



                emit CustodianChangeRequested(lockId, msg.sender, _proposedCustodian);

        }



        /** @notice  Confirms a pending change of the custodian associated with this contract.

            *

            * @dev  When called by the current custodian with a lock id associated with a

            * pending custodian change, the `address custodian` member will be updated with the

            * requested address.

            *

            * @param  _lockId  The identifier of a pending change request.

            */

        function confirmCustodianChange(bytes32 _lockId) public onlyCustodian {

                custodian = getCustodianChangeReq(_lockId);



                delete custodianChangeReqs[_lockId];



                emit CustodianChangeConfirmed(_lockId, custodian);

        }



        // PRIVATE FUNCTIONS

        function getCustodianChangeReq(bytes32 _lockId) private view returns (address _proposedNew) {

                CustodianChangeRequest storage changeRequest = custodianChangeReqs[_lockId];



                // reject ¡®null¡¯ results from the map lookup

                // this can only be the case if an unknown `_lockId` is received

                require(changeRequest.proposedNew != address(0));



                return changeRequest.proposedNew;

        }



        /// @dev  Emitted by successful `requestCustodianChange` calls.

        event CustodianChangeRequested(

                bytes32 _lockId,

                address _msgSender,

                address _proposedCustodian

        );



        /// @dev Emitted by successful `confirmCustodianChange` calls.

        event CustodianChangeConfirmed(bytes32 _lockId, address _newCustodian);

}



interface ServiceRegistry {

    function getService(string calldata _name) external view returns (address);

}



contract ServiceDiscovery {

    ServiceRegistry internal services;



    constructor(ServiceRegistry _services) public {

        services = ServiceRegistry(_services);

    }

}



contract KnowYourCustomer is CustodianUpgradeable {



    enum Status {

        none,

        passed,

        suspended

    }



    struct Customer {

        Status status;

        mapping(string => string) fields;

    }

    

    event ProviderAuthorized(address indexed _provider, string _name);

    event ProviderRemoved(address indexed _provider, string _name);

    event CustomerApproved(address indexed _customer, address indexed _provider);

    event CustomerSuspended(address indexed _customer, address indexed _provider);

    event CustomerFieldSet(address indexed _customer, address indexed _field, string _name);



    mapping(address => bool) private providers;

    mapping(address => Customer) private customers;



    constructor(address _custodian) public CustodianUpgradeable(_custodian) {

        customers[_custodian].status = Status.passed;

        customers[_custodian].fields["type"] = "custodian";

        emit CustomerApproved(_custodian, msg.sender);

        emit CustomerFieldSet(_custodian, msg.sender, "type");

    }



    function providerAuthorize(address _provider, string calldata name) external onlyCustodian {

        require(providers[_provider] == false, "provider must not exist");

        providers[_provider] = true;

        // cc:II. Manage Providers#2;Provider becomes authorized in contract;1;

        emit ProviderAuthorized(_provider, name);

    }



    function providerRemove(address _provider, string calldata name) external onlyCustodian {

        require(providers[_provider] == true, "provider must exist");

        delete providers[_provider];

        emit ProviderRemoved(_provider, name);

    }



    function hasWritePermissions(address _provider) external view returns (bool) {

        return _provider == custodian || providers[_provider] == true;

    }



    function getCustomerStatus(address _customer) external view returns (Status) {

        return customers[_customer].status;

    }



    function getCustomerField(address _customer, string calldata _field) external view returns (string memory) {

        return customers[_customer].fields[_field];

    }



    function approveCustomer(address _customer) external onlyAuthorized {

        Status status = customers[_customer].status;

        require(status != Status.passed, "customer must not be approved before");

        customers[_customer].status = Status.passed;

        // cc:III. Manage Customers#2;Customer becomes approved in contract;1;

        emit CustomerApproved(_customer, msg.sender);

    }



    function setCustomerField(address _customer, string calldata _field, string calldata _value) external onlyAuthorized {

        Status status = customers[_customer].status;

        require(status != Status.none, "customer must have a set status");

        customers[_customer].fields[_field] = _value;

        emit CustomerFieldSet(_customer, msg.sender, _field);

    }



    function suspendCustomer(address _customer) external onlyAuthorized {

        Status status = customers[_customer].status;

        require(status != Status.suspended, "customer must be not suspended");

        customers[_customer].status = Status.suspended;

        emit CustomerSuspended(_customer, msg.sender);

    }



    modifier onlyAuthorized() {

        require(msg.sender == custodian || providers[msg.sender] == true);

        _;

    }

}



contract TokenSettingsInterface {



    // METHODS

    function getTradeAllowed() public view returns (bool);

    function getMintAllowed() public view returns (bool);

    function getBurnAllowed() public view returns (bool);

    

    // EVENTS

    event TradeAllowedLocked(bytes32 _lockId, bool _newValue);

    event TradeAllowedConfirmed(bytes32 _lockId, bool _newValue);

    event MintAllowedLocked(bytes32 _lockId, bool _newValue);

    event MintAllowedConfirmed(bytes32 _lockId, bool _newValue);

    event BurnAllowedLocked(bytes32 _lockId, bool _newValue);

    event BurnAllowedConfirmed(bytes32 _lockId, bool _newValue);



    // MODIFIERS

    modifier onlyCustodian {

        _;

    }

}





contract _BurnAllowed is TokenSettingsInterface, LockRequestable {

    // cc:IV. BurnAllowed Setting#2;Burn Allowed Switch;1;

    //

    // SETTING: Burn Allowed Switch (bool)

    // Boundary: true or false

    //

    // Enables or disables token minting ability globally (even for custodian).

    //

    bool private burnAllowed = false;



    function getBurnAllowed() public view returns (bool) {

        return burnAllowed;

    }



    // SETTING MANAGEMENT



    struct PendingBurnAllowed {

        bool burnAllowed;

        bool set;

    }



    mapping (bytes32 => PendingBurnAllowed) public pendingBurnAllowedMap;



    function requestBurnAllowedChange(bool _burnAllowed) public returns (bytes32 lockId) {

       require(_burnAllowed != burnAllowed);

       

       lockId = generateLockId();

       pendingBurnAllowedMap[lockId] = PendingBurnAllowed({

           burnAllowed: _burnAllowed,

           set: true

       });



       emit BurnAllowedLocked(lockId, _burnAllowed);

    }



    function confirmBurnAllowedChange(bytes32 _lockId) public onlyCustodian {

        PendingBurnAllowed storage value = pendingBurnAllowedMap[_lockId];

        require(value.set == true);

        burnAllowed = value.burnAllowed;

        emit BurnAllowedConfirmed(_lockId, value.burnAllowed);

        delete pendingBurnAllowedMap[_lockId];

    }

}





contract _MintAllowed is TokenSettingsInterface, LockRequestable {

    // cc:III. MintAllowed Setting#2;Mint Allowed Switch;1;

    //

    // SETTING: Mint Allowed Switch (bool)

    // Boundary: true or false

    //

    // Enables or disables token minting ability globally (even for custodian).

    //

    bool private mintAllowed = false;



    function getMintAllowed() public view returns (bool) {

        return mintAllowed;

    }



    // SETTING MANAGEMENT



    struct PendingMintAllowed {

        bool mintAllowed;

        bool set;

    }



    mapping (bytes32 => PendingMintAllowed) public pendingMintAllowedMap;



    function requestMintAllowedChange(bool _mintAllowed) public returns (bytes32 lockId) {

       require(_mintAllowed != mintAllowed);

       

       lockId = generateLockId();

       pendingMintAllowedMap[lockId] = PendingMintAllowed({

           mintAllowed: _mintAllowed,

           set: true

       });



       emit MintAllowedLocked(lockId, _mintAllowed);

    }



    function confirmMintAllowedChange(bytes32 _lockId) public onlyCustodian {

        PendingMintAllowed storage value = pendingMintAllowedMap[_lockId];

        require(value.set == true);

        mintAllowed = value.mintAllowed;

        emit MintAllowedConfirmed(_lockId, value.mintAllowed);

        delete pendingMintAllowedMap[_lockId];

    }

}





contract _TradeAllowed is TokenSettingsInterface, LockRequestable {

    // cc:II. TradeAllowed Setting#2;Trade Allowed Switch;1;

    //

    // SETTING: Trade Allowed Switch (bool)

    // Boundary: true or false

    //

    // Enables or disables all token transfers, between any recipients, except mint and burn operations.

    //

    bool private tradeAllowed = false;



    function getTradeAllowed() public view returns (bool) {

        return tradeAllowed;

    }



    // SETTING MANAGEMENT



    struct PendingTradeAllowed {

        bool tradeAllowed;

        bool set;

    }



    mapping (bytes32 => PendingTradeAllowed) public pendingTradeAllowedMap;



    function requestTradeAllowedChange(bool _tradeAllowed) public returns (bytes32 lockId) {

       require(_tradeAllowed != tradeAllowed);

       

       lockId = generateLockId();

       pendingTradeAllowedMap[lockId] = PendingTradeAllowed({

           tradeAllowed: _tradeAllowed,

           set: true

       });



       emit TradeAllowedLocked(lockId, _tradeAllowed);

    }



    function confirmTradeAllowedChange(bytes32 _lockId) public onlyCustodian {

        PendingTradeAllowed storage value = pendingTradeAllowedMap[_lockId];

        require(value.set == true);

        tradeAllowed = value.tradeAllowed;

        emit TradeAllowedConfirmed(_lockId, value.tradeAllowed);

        delete pendingTradeAllowedMap[_lockId];

    }

}



contract TokenSettings is TokenSettingsInterface, CustodianUpgradeable,

_TradeAllowed,

_MintAllowed,

_BurnAllowed

    {

    constructor(address _custodian) public CustodianUpgradeable(_custodian) {

    }

}





/**

 * @title TokenController implements restriction logic for BaseSecurityToken.

 * @dev see https://eips.ethereum.org/EIPS/eip-1462

 */

contract TokenController is CustodianUpgradeable, ServiceDiscovery {

    constructor(address _custodian, ServiceRegistry _services) public

    CustodianUpgradeable(_custodian) ServiceDiscovery(_services) {

    }



    // Use status codes from:

    // https://eips.ethereum.org/EIPS/eip-1066

    byte private constant STATUS_ALLOWED = 0x11;



    function checkTransferAllowed(address _from, address _to, uint256) public view returns (byte) {

        require(_settings().getTradeAllowed(), "global trade must be allowed");

        require(_kyc().getCustomerStatus(_from) == KnowYourCustomer.Status.passed, "sender does not have valid KYC status");

        require(_kyc().getCustomerStatus(_to) == KnowYourCustomer.Status.passed, "recipient does not have valid KYC status");



        // TODO:

        // Check user's region

        // Check amount for transfer limits



        return STATUS_ALLOWED;

    }

   

    function checkTransferFromAllowed(address _from, address _to, uint256 _amount) external view returns (byte) {

        return checkTransferAllowed(_from, _to, _amount);

    }

   

    function checkMintAllowed(address _from, uint256) external view returns (byte) {

        require(_settings().getMintAllowed(), "global mint must be allowed");

        require(_kyc().getCustomerStatus(_from) == KnowYourCustomer.Status.passed, "recipient does not have valid KYC status");

        

        return STATUS_ALLOWED;

    }

   

    function checkBurnAllowed(address _from, uint256) external view returns (byte) {

        require(_settings().getBurnAllowed(), "global burn must be allowed");

        require(_kyc().getCustomerStatus(_from) == KnowYourCustomer.Status.passed, "sender does not have valid KYC status");



        return STATUS_ALLOWED;

    }



    function _settings() private view returns (TokenSettings) {

        return TokenSettings(services.getService("token/settings"));

    }



    function _kyc() private view returns (KnowYourCustomer) {

        return KnowYourCustomer(services.getService("validators/kyc"));

    }

}