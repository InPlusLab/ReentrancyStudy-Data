/**

 *Submitted for verification at Etherscan.io on 2019-03-22

*/



pragma solidity 0.5.3;





interface IOrbsValidatorsRegistry {

    event ValidatorLeft(address indexed validator);

    event ValidatorRegistered(address indexed validator);

    event ValidatorUpdated(address indexed validator);



    function register(

        string calldata name,

        bytes4 ipAddress,

        string calldata website,

        bytes20 orbsAddress

    )

        external;

    function update(

        string calldata name,

        bytes4 ipAddress,

        string calldata website,

        bytes20 orbsAddress

    )

        external;

    function leave() external;

    function getValidatorData(address validator)

        external

        view

        returns (

            string memory name,

            bytes4 ipAddress,

            string memory website,

            bytes20 orbsAddress

        );

    function reviewRegistration()

        external

        view

        returns (

            string memory name,

            bytes4 ipAddress,

            string memory website,

            bytes20 orbsAddress

        );

    function getRegistrationBlockNumber(address validator)

        external

        view

        returns (uint registeredOn, uint lastUpdatedOn);

    function isValidator(address validator) external view returns (bool);

    function getOrbsAddress(address validator)

        external

        view

        returns (bytes20 orbsAddress);

}





/// @title Orbs Validators Registry smart contract.

contract OrbsValidatorsRegistry is IOrbsValidatorsRegistry {



    // The validator registration data object.

    struct ValidatorData {

        string name;

        bytes4 ipAddress;

        string website;

        bytes20 orbsAddress;

        uint registeredOnBlock;

        uint lastUpdatedOnBlock;

    }



    // The version of the current validators data registration smart contract.

    uint public constant VERSION = 1;



    // A mapping from validator's Ethereum address to registration data.

    mapping(address => ValidatorData) internal validatorsData;



    // Lookups for IP Address & Orbs Address for uniqueness checks. Useful also be used for as a public lookup index.

    mapping(bytes4 => address) public lookupByIp;

    mapping(bytes20 => address) public lookupByOrbsAddr;



    /// @dev register a validator and provide registration data.

    /// the new validator entry will be owned and identified by msg.sender.

    /// if msg.sender is already registered as a validator in this registry the

    /// transaction will fail.

    /// @param name string The name of the validator

    /// @param ipAddress bytes4 The validator node ip address. If another validator previously registered this ipAddress the transaction will fail

    /// @param website string The website of the validator

    /// @param orbsAddress bytes20 The validator node orbs public address. If another validator previously registered this orbsAddress the transaction will fail

    function register(

        string memory name,

        bytes4 ipAddress,

        string memory website,

        bytes20 orbsAddress

    )

        public

    {

        require(bytes(name).length > 0, "Please provide a valid name");

        require(bytes(website).length > 0, "Please provide a valid website");

        require(!isValidator(msg.sender), "Validator already exists");

        require(ipAddress != bytes4(0), "Please pass a valid ip address represented as an array of exactly 4 bytes");

        require(orbsAddress != bytes20(0), "Please provide a valid Orbs Address");

        require(lookupByIp[ipAddress] == address(0), "IP address already in use");

        require(lookupByOrbsAddr[orbsAddress] == address(0), "Orbs Address is already in use by another validator");



        lookupByIp[ipAddress] = msg.sender;

        lookupByOrbsAddr[orbsAddress] = msg.sender;



        validatorsData[msg.sender] = ValidatorData(

            name,

            ipAddress,

            website,

            orbsAddress,

            block.number,

            block.number

        );



        emit ValidatorRegistered(msg.sender);

    }



    /// @dev update the validator registration data entry associated with msg.sender.

    /// msg.sender must be registered in this registry contract.

    /// @param name string The name of the validator

    /// @param ipAddress bytes4 The validator node ip address. If another validator previously registered this ipAddress the transaction will fail

    /// @param website string The website of the validator

    /// @param orbsAddress bytes20 The validator node orbs public address. If another validator previously registered this orbsAddress the transaction will fail

    function update(

        string memory name,

        bytes4 ipAddress,

        string memory website,

        bytes20 orbsAddress

    )

        public

    {

        require(bytes(name).length > 0, "Please provide a valid name");

        require(bytes(website).length > 0, "Please provide a valid website");

        require(isValidator(msg.sender), "Validator doesnt exist");

        require(ipAddress != bytes4(0), "Please pass a valid ip address represented as an array of exactly 4 bytes");

        require(orbsAddress != bytes20(0), "Please provide a valid Orbs Address");

        require(isUniqueIp(ipAddress), "IP Address is already in use by another validator");

        require(isUniqueOrbsAddress(orbsAddress), "Orbs Address is already in use by another validator");



        ValidatorData storage data = validatorsData[msg.sender];



        delete lookupByIp[data.ipAddress];

        delete lookupByOrbsAddr[data.orbsAddress];



        lookupByIp[ipAddress] = msg.sender;

        lookupByOrbsAddr[orbsAddress] = msg.sender;



        data.name = name;

        data.ipAddress = ipAddress;

        data.website = website;

        data.orbsAddress = orbsAddress;

        data.lastUpdatedOnBlock = block.number;



        emit ValidatorUpdated(msg.sender);

    }



    /// @dev deletes a validator registration entry associated with msg.sender.

    function leave() public {

        require(isValidator(msg.sender), "Sender is not a listed Validator");



        ValidatorData storage data = validatorsData[msg.sender];



        delete lookupByIp[data.ipAddress];

        delete lookupByOrbsAddr[data.orbsAddress];



        delete validatorsData[msg.sender];



        emit ValidatorLeft(msg.sender);

    }



    /// @dev returns validator registration data.

    /// @param validator address address of the validator.

    function getValidatorData(address validator)

        public

        view

        returns (

            string memory name,

            bytes4 ipAddress,

            string memory website,

            bytes20 orbsAddress

        )

    {

        require(isValidator(validator), "Unlisted Validator");



        ValidatorData storage entry = validatorsData[validator];

        return (

            entry.name,

            entry.ipAddress,

            entry.website,

            entry.orbsAddress

        );

    }



    /// @dev Convenience method to retrieve the registration data associated

    /// with msg.sender - typically for review after a successful registration.

    /// same as calling getValidatorData(msg.sender)

    function reviewRegistration()

        public

        view

        returns (

            string memory name,

            bytes4 ipAddress,

            string memory website,

            bytes20 orbsAddress

        )

    {

        return getValidatorData(msg.sender);

    }



    /// @dev returns the blocks in which a validator was registered and last updated.

    /// if validator does not designate a registered validator this method returns zero values.

    /// @param validator address of a validator

    function getRegistrationBlockNumber(address validator)

        external

        view

        returns (uint registeredOn, uint lastUpdatedOn)

    {

        require(isValidator(validator), "Unlisted Validator");



        ValidatorData storage entry = validatorsData[validator];

        return (

            entry.registeredOnBlock,

            entry.lastUpdatedOnBlock

        );

    }



    /// @dev returns the orbs node public address of a specific validator.

    /// @param validator address address of the validator

    /// @return an Orbs node address

    function getOrbsAddress(address validator)

        public

        view

        returns (bytes20)

    {

        require(isValidator(validator), "Unlisted Validator");



        return validatorsData[validator].orbsAddress;

    }



    /// @dev Checks if addr is currently registered as a validator.

    /// @param addr address address of the validator

    /// @return true iff addr belongs to a registered validator

    function isValidator(address addr) public view returns (bool) {

        return validatorsData[addr].registeredOnBlock > 0;

    }



    /// @dev INTERNAL. Checks if ipAddress is currently available to msg.sender.

    /// @param ipAddress bytes4 ip address to check for uniqueness

    /// @return true iff ipAddress is currently not registered for any validator other than msg.sender.

    function isUniqueIp(bytes4 ipAddress) internal view returns (bool) {

        return

            lookupByIp[ipAddress] == address(0) ||

            lookupByIp[ipAddress] == msg.sender;

    }



    /// @dev INTERNAL. Checks if orbsAddress is currently available to msg.sender.

    /// @param orbsAddress bytes20 ip address to check for uniqueness

    /// @return true iff orbsAddress is currently not registered for a validator other than msg.sender.

    function isUniqueOrbsAddress(bytes20 orbsAddress) internal view returns (bool) {

        return

            lookupByOrbsAddr[orbsAddress] == address(0) ||

            lookupByOrbsAddr[orbsAddress] == msg.sender;

    }



}