/**
 *Submitted for verification at Etherscan.io on 2020-11-04
*/

// File: contracts/spec_interfaces/IGuardiansRegistration.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/// @title Guardian registration contract interface
interface IGuardiansRegistration {
	event GuardianRegistered(address indexed guardian);
	event GuardianUnregistered(address indexed guardian);
	event GuardianDataUpdated(address indexed guardian, bool isRegistered, bytes4 ip, address orbsAddr, string name, string website, uint256 registrationTime);
	event GuardianMetadataChanged(address indexed guardian, string key, string newValue, string oldValue);

	/*
     * External methods
     */

    /// Registers a new guardian
    /// @dev called using the guardian's address that holds the guardian self-stake and used for delegation
    /// @param ip is the guardian's node ipv4 address as a 32b number 
    /// @param orbsAddr is the guardian's Orbs node address 
    /// @param name is the guardian's name as a string
    /// @param website is the guardian's website as a string, publishing a name and website provide information for delegators
	function registerGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website) external;

    /// Updates a registered guardian data
    /// @dev may be called only by a registered guardian
    /// @param ip is the guardian's node ipv4 address as a 32b number 
    /// @param orbsAddr is the guardian's Orbs node address 
    /// @param name is the guardian's name as a string
    /// @param website is the guardian's website as a string, publishing a name and website provide information for delegators
	function updateGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website) external;

    /// Updates a registered guardian ip address
    /// @dev may be called only by a registered guardian
    /// @dev may be called with either the guardian address or the guardian's orbs address
    /// @param ip is the guardian's node ipv4 address as a 32b number 
	function updateGuardianIp(bytes4 ip) external /* onlyWhenActive */;

    /// Updates a guardian's metadata property
    /// @dev called using the guardian's address
    /// @dev any key may be updated to be used by Orbs platform and tools
    /// @param key is the name of the property to update
    /// @param value is the value of the property to update in a string format
    function setMetadata(string calldata key, string calldata value) external;

    /// Returns a guardian's metadata property
    /// @dev a property that wasn't set returns an empty string
    /// @param guardian is the guardian to query
    /// @param key is the name of the metadata property to query
    /// @return value is the value of the queried property in a string format
    function getMetadata(address guardian, string calldata key) external view returns (string memory);

    /// Unregisters a guardian
    /// @dev may be called only by a registered guardian
    /// @dev unregistering does not clear the guardian's metadata properties
	function unregisterGuardian() external;

    /// Returns a guardian's data
    /// @param guardian is the guardian to query
    /// @param ip is the guardian's node ipv4 address as a 32b number 
    /// @param orbsAddr is the guardian's Orbs node address 
    /// @param name is the guardian's name as a string
    /// @param website is the guardian's website as a string
    /// @param registrationTime is the timestamp of the guardian's registration
    /// @param lastUpdateTime is the timestamp of the guardian's last update
	function getGuardianData(address guardian) external view returns (bytes4 ip, address orbsAddr, string memory name, string memory website, uint registrationTime, uint lastUpdateTime);

    /// Returns the Orbs addresses of a list of guardians
    /// @dev an unregistered guardian returns address(0) Orbs address
    /// @param guardianAddrs is a list of guardians' addresses to query
    /// @return orbsAddrs is a list of the guardians' Orbs addresses 
	function getGuardiansOrbsAddress(address[] calldata guardianAddrs) external view returns (address[] memory orbsAddrs);

    /// Returns a guardian's ip
    /// @dev an unregistered guardian returns 0 ip address
    /// @param guardian is the guardian to query
    /// @return ip is the guardian's node ipv4 address as a 32b number 
	function getGuardianIp(address guardian) external view returns (bytes4 ip);

    /// Returns the ip of a list of guardians
    /// @dev an unregistered guardian returns 0 ip address
    /// @param guardianAddrs is a list of guardians' addresses to query
    /// @param ips is a list of the guardians' node ipv4 addresses as a 32b numbers
	function getGuardianIps(address[] calldata guardianAddrs) external view returns (bytes4[] memory ips);

    /// Checks if a guardian is registered
    /// @param guardian is the guardian to query
    /// @return registered is a bool indicating a guardian address is registered
	function isRegistered(address guardian) external view returns (bool);

    /// Translates a list guardians Orbs addresses to guardian addresses
    /// @dev an Orbs address that does not correspond to any registered guardian returns address(0)
    /// @param orbsAddrs is a list of the guardians' Orbs addresses to query
    /// @return guardianAddrs is a list of guardians' addresses that matches the Orbs addresses
	function getGuardianAddresses(address[] calldata orbsAddrs) external view returns (address[] memory guardianAddrs);

    /// Resolves the guardian address for a guardian, given a Guardian/Orbs address
    /// @dev revert if the address does not correspond to a registered guardian address or Orbs address
    /// @dev designed to be used for contracts calls, validating a registered guardian
    /// @dev should be used with caution when called by tools as the call may revert
    /// @dev in case of a conflict matching both guardian and Orbs address, the Guardian address takes precedence
    /// @param guardianOrOrbsAddress is the address to query representing a guardian address or Orbs address
    /// @return guardianAddress is the guardian address that matches the queried address
	function resolveGuardianAddress(address guardianOrOrbsAddress) external view returns (address guardianAddress);

	/*
	 * Governance functions
	 */

    /// Migrates a list of guardians from a previous guardians registration contract
    /// @dev governance function called only by the initialization admin
    /// @dev reads the migrated guardians data by calling getGuardianData in the previous contract
    /// @dev imports also the guardians' registration time and last update
    /// @dev emits a GuardianDataUpdated for each guardian to allow tracking by tools
    /// @param guardiansToMigrate is a list of guardians' addresses to migrate
    /// @param previousContract is the previous registration contract address
	function migrateGuardians(address[] calldata guardiansToMigrate, IGuardiansRegistration previousContract) external /* onlyInitializationAdmin */;

}

// File: contracts/spec_interfaces/IElections.sol

pragma solidity 0.6.12;

/// @title Elections contract interface
interface IElections {
	
	// Election state change events
	event StakeChanged(address indexed addr, uint256 selfDelegatedStake, uint256 delegatedStake, uint256 effectiveStake);
	event GuardianStatusUpdated(address indexed guardian, bool readyToSync, bool readyForCommittee);

	// Vote out / Vote unready
	event GuardianVotedUnready(address indexed guardian);
	event VoteUnreadyCasted(address indexed voter, address indexed subject, uint256 expiration);
	event GuardianVotedOut(address indexed guardian);
	event VoteOutCasted(address indexed voter, address indexed subject);

	/*
	 * External functions
	 */

    /// Notifies that the guardian is ready to sync with other nodes
    /// @dev may be called with either the guardian address or the guardian's orbs address
    /// @dev ready to sync state is not managed in the contract that only emits an event
    /// @dev readyToSync clears the readyForCommittee state
	function readyToSync() external;

    /// Notifies that the guardian is ready to join the committee
    /// @dev may be called with either the guardian address or the guardian's orbs address
    /// @dev a qualified guardian calling readyForCommittee is added to the committee
	function readyForCommittee() external;

    /// Checks if a guardian is qualified to join the committee
    /// @dev when true, calling readyForCommittee() will result in adding the guardian to the committee
    /// @dev called periodically by guardians to check if they are qualified to join the committee
    /// @param guardian is the guardian to check
    /// @return canJoin indicating that the guardian can join the current committee
	function canJoinCommittee(address guardian) external view returns (bool);

    /// Returns an address effective stake
    /// The effective stake is derived from a guardian delegate stake and selfs stake  
    /// @return effectiveStake is the guardian's effective stake
	function getEffectiveStake(address guardian) external view returns (uint effectiveStake);

    /// Returns the current committee along with the guardians' Orbs address and IP
    /// @return committee is a list of the committee members' guardian addresses
    /// @return weights is a list of the committee members' weight (effective stake)
    /// @return orbsAddrs is a list of the committee members' orbs address
    /// @return certification is a list of bool indicating the committee members certification
    /// @return ips is a list of the committee members' ip
	function getCommittee() external view returns (address[] memory committee, uint256[] memory weights, address[] memory orbsAddrs, bool[] memory certification, bytes4[] memory ips);

	// Vote-unready

    /// Casts an unready vote on a subject guardian
    /// @dev Called by a guardian as part of the automatic vote-unready flow
    /// @dev The transaction may be sent from the guardian or orbs address.
    /// @param subject is the subject guardian to vote out
    /// @param voteExpiration is the expiration time of the vote unready to prevent counting of a vote that is already irrelevant.
	function voteUnready(address subject, uint voteExpiration) external;

    /// Returns the current vote unready vote for a voter and a subject pair
    /// @param voter is the voting guardian address
    /// @param subject is the subject guardian address
    /// @return valid indicates whether there is a valid vote
    /// @return expiration returns the votes expiration time
	function getVoteUnreadyVote(address voter, address subject) external view returns (bool valid, uint256 expiration);

    /// Returns the current vote-unready status of a subject guardian.
    /// @dev the committee and certification data is used to check the certified and committee threshold
    /// @param subject is the subject guardian address
    /// @return committee is a list of the current committee members
    /// @return weights is a list of the current committee members weight
    /// @return certification is a list of bool indicating the committee members certification
    /// @return votes is a list of bool indicating the members that votes the subject unready
    /// @return subjectInCommittee indicates that the subject is in the committee
    /// @return subjectInCertifiedCommittee indicates that the subject is in the certified committee
	function getVoteUnreadyStatus(address subject) external view returns (
		address[] memory committee,
		uint256[] memory weights,
		bool[] memory certification,
		bool[] memory votes,
		bool subjectInCommittee,
		bool subjectInCertifiedCommittee
	);

	// Vote-out

    /// Casts a voteOut vote by the sender to the given address
    /// @dev the transaction is sent from the guardian address
    /// @param subject is the subject guardian address
	function voteOut(address subject) external;

    /// Returns the subject address the addr has voted-out against
    /// @param voter is the voting guardian address
    /// @return subject is the subject the voter has voted out
	function getVoteOutVote(address voter) external view returns (address);

    /// Returns the governance voteOut status of a guardian.
    /// @dev A guardian is voted out if votedStake / totalDelegatedStake (in percent mille) > threshold
    /// @param subject is the subject guardian address
    /// @return votedOut indicates whether the subject was voted out
    /// @return votedStake is the total stake voting against the subject
    /// @return totalDelegatedStake is the total delegated stake
	function getVoteOutStatus(address subject) external view returns (bool votedOut, uint votedStake, uint totalDelegatedStake);

	/*
	 * Notification functions from other PoS contracts
	 */

    /// Notifies a delegated stake change event
    /// @dev Called by: delegation contract
    /// @param delegate is the delegate to update
    /// @param selfDelegatedStake is the delegate self stake (0 if not self-delegating)
    /// @param delegatedStake is the delegate delegated stake (0 if not self-delegating)
    /// @param totalDelegatedStake is the total delegated stake
	function delegatedStakeChange(address delegate, uint256 selfDelegatedStake, uint256 delegatedStake, uint256 totalDelegatedStake) external /* onlyDelegationsContract onlyWhenActive */;

    /// Notifies a new guardian was unregistered
    /// @dev Called by: guardian registration contract
    /// @dev when a guardian unregisters its status is updated to not ready to sync and is removed from the committee
    /// @param guardian is the address of the guardian that unregistered
	function guardianUnregistered(address guardian) external /* onlyGuardiansRegistrationContract */;

    /// Notifies on a guardian certification change
    /// @dev Called by: guardian registration contract
    /// @param guardian is the address of the guardian to update
    /// @param isCertified indicates whether the guardian is certified
	function guardianCertificationChanged(address guardian, bool isCertified) external /* onlyCertificationContract */;


	/*
     * Governance functions
	 */

	event VoteUnreadyTimeoutSecondsChanged(uint32 newValue, uint32 oldValue);
	event VoteOutPercentMilleThresholdChanged(uint32 newValue, uint32 oldValue);
	event VoteUnreadyPercentMilleThresholdChanged(uint32 newValue, uint32 oldValue);
	event MinSelfStakePercentMilleChanged(uint32 newValue, uint32 oldValue);

    /// Sets the minimum self stake requirement for the effective stake
    /// @dev governance function called only by the functional manager
    /// @param minSelfStakePercentMille is the minimum self stake in percent-mille (0-100,000) 
	function setMinSelfStakePercentMille(uint32 minSelfStakePercentMille) external /* onlyFunctionalManager */;

    /// Returns the minimum self-stake required for the effective stake
    /// @return minSelfStakePercentMille is the minimum self stake in percent-mille 
	function getMinSelfStakePercentMille() external view returns (uint32);

    /// Sets the vote-out threshold
    /// @dev governance function called only by the functional manager
    /// @param voteOutPercentMilleThreshold is the minimum threshold in percent-mille (0-100,000)
	function setVoteOutPercentMilleThreshold(uint32 voteOutPercentMilleThreshold) external /* onlyFunctionalManager */;

    /// Returns the vote-out threshold
    /// @return voteOutPercentMilleThreshold is the minimum threshold in percent-mille
	function getVoteOutPercentMilleThreshold() external view returns (uint32);

    /// Sets the vote-unready threshold
    /// @dev governance function called only by the functional manager
    /// @param voteUnreadyPercentMilleThreshold is the minimum threshold in percent-mille (0-100,000)
	function setVoteUnreadyPercentMilleThreshold(uint32 voteUnreadyPercentMilleThreshold) external /* onlyFunctionalManager */;

    /// Returns the vote-unready threshold
    /// @return voteUnreadyPercentMilleThreshold is the minimum threshold in percent-mille
	function getVoteUnreadyPercentMilleThreshold() external view returns (uint32);

    /// Returns the contract's settings 
    /// @return minSelfStakePercentMille is the minimum self stake in percent-mille
    /// @return voteUnreadyPercentMilleThreshold is the minimum threshold in percent-mille
    /// @return voteOutPercentMilleThreshold is the minimum threshold in percent-mille
	function getSettings() external view returns (
		uint32 minSelfStakePercentMille,
		uint32 voteUnreadyPercentMilleThreshold,
		uint32 voteOutPercentMilleThreshold
	);

    /// Initializes the ready for committee notification for the committee guardians
    /// @dev governance function called only by the initialization admin during migration 
    /// @dev identical behaviour as if each guardian sent readyForCommittee() 
    /// @param guardians a list of guardians addresses to update
	function initReadyForCommittee(address[] calldata guardians) external /* onlyInitializationAdmin */;

}

// File: contracts/spec_interfaces/IManagedContract.sol

pragma solidity 0.6.12;

/// @title managed contract interface, used by the contracts registry to notify the contract on updates
interface IManagedContract /* is ILockable, IContractRegistryAccessor, Initializable */ {

    /// Refreshes the address of the other contracts the contract interacts with
    /// @dev called by the registry contract upon an update of a contract in the registry
    function refreshContracts() external;

}

// File: contracts/spec_interfaces/IContractRegistry.sol

pragma solidity 0.6.12;

/// @title Contract registry contract interface
/// @dev The contract registry holds Orbs PoS contracts and managers lists
/// @dev The contract registry updates the managed contracts on changes in the contract list
/// @dev Governance functions restricted to managers access the registry to retrieve the manager address 
/// @dev The contract registry represents the source of truth for Orbs Ethereum contracts 
/// @dev By tracking the registry events or query before interaction, one can access the up to date contracts 
interface IContractRegistry {

	event ContractAddressUpdated(string contractName, address addr, bool managedContract);
	event ManagerChanged(string role, address newManager);
	event ContractRegistryUpdated(address newContractRegistry);

	/*
	* External functions
	*/

    /// Updates the contracts address and emits a corresponding event
    /// @dev governance function called only by the migrationManager or registryAdmin
    /// @param contractName is the contract name, used to identify it
    /// @param addr is the contract updated address
    /// @param managedContract indicates whether the contract is managed by the registry and notified on changes
	function setContract(string calldata contractName, address addr, bool managedContract) external /* onlyAdminOrMigrationManager */;

    /// Returns the current address of the given contracts
    /// @param contractName is the contract name, used to identify it
    /// @return addr is the contract updated address
	function getContract(string calldata contractName) external view returns (address);

    /// Returns the list of contract addresses managed by the registry
    /// @dev Managed contracts are updated on changes in the registry contracts addresses 
    /// @return addrs is the list of managed contracts
	function getManagedContracts() external view returns (address[] memory);

    /// Locks all the managed contracts 
    /// @dev governance function called only by the migrationManager or registryAdmin
    /// @dev When set all onlyWhenActive functions will revert
	function lockContracts() external /* onlyAdminOrMigrationManager */;

    /// Unlocks all the managed contracts 
    /// @dev governance function called only by the migrationManager or registryAdmin
	function unlockContracts() external /* onlyAdminOrMigrationManager */;
	
    /// Updates a manager address and emits a corresponding event
    /// @dev governance function called only by the registryAdmin
    /// @dev the managers list is a flexible list of role to the manager's address
    /// @param role is the managers' role name, for example "functionalManager"
    /// @param manager is the manager updated address
	function setManager(string calldata role, address manager) external /* onlyAdmin */;

    /// Returns the current address of the given manager
    /// @param role is the manager name, used to identify it
    /// @return addr is the manager updated address
	function getManager(string calldata role) external view returns (address);

    /// Sets a new contract registry to migrate to
    /// @dev governance function called only by the registryAdmin
    /// @dev updates the registry address record in all the managed contracts
    /// @dev by tracking the emitted ContractRegistryUpdated, tools can track the up to date contracts
    /// @param newRegistry is the new registry contract 
	function setNewContractRegistry(IContractRegistry newRegistry) external /* onlyAdmin */;

    /// Returns the previous contract registry address 
    /// @dev used when the setting the contract as a new registry to assure a valid registry
    /// @return previousContractRegistry is the previous contract registry
	function getPreviousContractRegistry() external view returns (address);
}

// File: contracts/spec_interfaces/IContractRegistryAccessor.sol

pragma solidity 0.6.12;


interface IContractRegistryAccessor {

    /// Sets the contract registry address
    /// @dev governance function called only by an admin
    /// @param newRegistry is the new registry contract 
    function setContractRegistry(IContractRegistry newRegistry) external /* onlyAdmin */;

    /// Returns the contract registry address
    /// @return contractRegistry is the contract registry address
    function getContractRegistry() external view returns (IContractRegistry contractRegistry);

    function setRegistryAdmin(address _registryAdmin) external /* onlyInitializationAdmin */;

}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/WithClaimableRegistryManagement.sol

pragma solidity 0.6.12;


/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract WithClaimableRegistryManagement is Context {
    address private _registryAdmin;
    address private _pendingRegistryAdmin;

    event RegistryManagementTransferred(address indexed previousRegistryAdmin, address indexed newRegistryAdmin);

    /**
     * @dev Initializes the contract setting the deployer as the initial registryRegistryAdmin.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _registryAdmin = msgSender;
        emit RegistryManagementTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current registryAdmin.
     */
    function registryAdmin() public view returns (address) {
        return _registryAdmin;
    }

    /**
     * @dev Throws if called by any account other than the registryAdmin.
     */
    modifier onlyRegistryAdmin() {
        require(isRegistryAdmin(), "WithClaimableRegistryManagement: caller is not the registryAdmin");
        _;
    }

    /**
     * @dev Returns true if the caller is the current registryAdmin.
     */
    function isRegistryAdmin() public view returns (bool) {
        return _msgSender() == _registryAdmin;
    }

    /**
     * @dev Leaves the contract without registryAdmin. It will not be possible to call
     * `onlyManager` functions anymore. Can only be called by the current registryAdmin.
     *
     * NOTE: Renouncing registryManagement will leave the contract without an registryAdmin,
     * thereby removing any functionality that is only available to the registryAdmin.
     */
    function renounceRegistryManagement() public onlyRegistryAdmin {
        emit RegistryManagementTransferred(_registryAdmin, address(0));
        _registryAdmin = address(0);
    }

    /**
     * @dev Transfers registryManagement of the contract to a new account (`newManager`).
     */
    function _transferRegistryManagement(address newRegistryAdmin) internal {
        require(newRegistryAdmin != address(0), "RegistryAdmin: new registryAdmin is the zero address");
        emit RegistryManagementTransferred(_registryAdmin, newRegistryAdmin);
        _registryAdmin = newRegistryAdmin;
    }

    /**
     * @dev Modifier throws if called by any account other than the pendingManager.
     */
    modifier onlyPendingRegistryAdmin() {
        require(msg.sender == _pendingRegistryAdmin, "Caller is not the pending registryAdmin");
        _;
    }
    /**
     * @dev Allows the current registryAdmin to set the pendingManager address.
     * @param newRegistryAdmin The address to transfer registryManagement to.
     */
    function transferRegistryManagement(address newRegistryAdmin) public onlyRegistryAdmin {
        _pendingRegistryAdmin = newRegistryAdmin;
    }

    /**
     * @dev Allows the _pendingRegistryAdmin address to finalize the transfer.
     */
    function claimRegistryManagement() external onlyPendingRegistryAdmin {
        _transferRegistryManagement(_pendingRegistryAdmin);
        _pendingRegistryAdmin = address(0);
    }

    /**
     * @dev Returns the current pendingRegistryAdmin
    */
    function pendingRegistryAdmin() public view returns (address) {
       return _pendingRegistryAdmin;  
    }
}

// File: contracts/Initializable.sol

pragma solidity 0.6.12;

contract Initializable {

    address private _initializationAdmin;

    event InitializationComplete();

    /// Constructor
    /// Sets the initializationAdmin to the contract deployer
    /// The initialization admin may call any manager only function until initializationComplete
    constructor() public{
        _initializationAdmin = msg.sender;
    }

    modifier onlyInitializationAdmin() {
        require(msg.sender == initializationAdmin(), "sender is not the initialization admin");

        _;
    }

    /*
    * External functions
    */

    /// Returns the initializationAdmin address
    function initializationAdmin() public view returns (address) {
        return _initializationAdmin;
    }

    /// Finalizes the initialization and revokes the initializationAdmin role 
    function initializationComplete() external onlyInitializationAdmin {
        _initializationAdmin = address(0);
        emit InitializationComplete();
    }

    /// Checks if the initialization was completed
    function isInitializationComplete() public view returns (bool) {
        return _initializationAdmin == address(0);
    }

}

// File: contracts/ContractRegistryAccessor.sol

pragma solidity 0.6.12;





contract ContractRegistryAccessor is IContractRegistryAccessor, WithClaimableRegistryManagement, Initializable {

    IContractRegistry private contractRegistry;

    /// Constructor
    /// @param _contractRegistry is the contract registry address
    /// @param _registryAdmin is the registry admin address
    constructor(IContractRegistry _contractRegistry, address _registryAdmin) public {
        require(address(_contractRegistry) != address(0), "_contractRegistry cannot be 0");
        setContractRegistry(_contractRegistry);
        _transferRegistryManagement(_registryAdmin);
    }

    modifier onlyAdmin {
        require(isAdmin(), "sender is not an admin (registryManger or initializationAdmin)");

        _;
    }

    modifier onlyMigrationManager {
        require(isMigrationManager(), "sender is not the migration manager");

        _;
    }

    modifier onlyFunctionalManager {
        require(isFunctionalManager(), "sender is not the functional manager");

        _;
    }

    /// Checks whether the caller is Admin: either the contract registry, the registry admin, or the initialization admin
    function isAdmin() internal view returns (bool) {
        return msg.sender == address(contractRegistry) || msg.sender == registryAdmin() || msg.sender == initializationAdmin();
    }

    /// Checks whether the caller is a specific manager role or and Admin
    /// @dev queries the registry contract for the up to date manager assignment
    function isManager(string memory role) internal view returns (bool) {
        IContractRegistry _contractRegistry = contractRegistry;
        return isAdmin() || _contractRegistry != IContractRegistry(0) && contractRegistry.getManager(role) == msg.sender;
    }

    /// Checks whether the caller is the migration manager
    function isMigrationManager() internal view returns (bool) {
        return isManager('migrationManager');
    }

    /// Checks whether the caller is the functional manager
    function isFunctionalManager() internal view returns (bool) {
        return isManager('functionalManager');
    }

    /* 
     * Contract getters, return the address of a contract by calling the contract registry 
     */ 

    function getProtocolContract() internal view returns (address) {
        return contractRegistry.getContract("protocol");
    }

    function getStakingRewardsContract() internal view returns (address) {
        return contractRegistry.getContract("stakingRewards");
    }

    function getFeesAndBootstrapRewardsContract() internal view returns (address) {
        return contractRegistry.getContract("feesAndBootstrapRewards");
    }

    function getCommitteeContract() internal view returns (address) {
        return contractRegistry.getContract("committee");
    }

    function getElectionsContract() internal view returns (address) {
        return contractRegistry.getContract("elections");
    }

    function getDelegationsContract() internal view returns (address) {
        return contractRegistry.getContract("delegations");
    }

    function getGuardiansRegistrationContract() internal view returns (address) {
        return contractRegistry.getContract("guardiansRegistration");
    }

    function getCertificationContract() internal view returns (address) {
        return contractRegistry.getContract("certification");
    }

    function getStakingContract() internal view returns (address) {
        return contractRegistry.getContract("staking");
    }

    function getSubscriptionsContract() internal view returns (address) {
        return contractRegistry.getContract("subscriptions");
    }

    function getStakingRewardsWallet() internal view returns (address) {
        return contractRegistry.getContract("stakingRewardsWallet");
    }

    function getBootstrapRewardsWallet() internal view returns (address) {
        return contractRegistry.getContract("bootstrapRewardsWallet");
    }

    function getGeneralFeesWallet() internal view returns (address) {
        return contractRegistry.getContract("generalFeesWallet");
    }

    function getCertifiedFeesWallet() internal view returns (address) {
        return contractRegistry.getContract("certifiedFeesWallet");
    }

    function getStakingContractHandler() internal view returns (address) {
        return contractRegistry.getContract("stakingContractHandler");
    }

    /*
    * Governance functions
    */

    event ContractRegistryAddressUpdated(address addr);

    /// Sets the contract registry address
    /// @dev governance function called only by an admin
    /// @param newContractRegistry is the new registry contract 
    function setContractRegistry(IContractRegistry newContractRegistry) public override onlyAdmin {
        require(newContractRegistry.getPreviousContractRegistry() == address(contractRegistry), "new contract registry must provide the previous contract registry");
        contractRegistry = newContractRegistry;
        emit ContractRegistryAddressUpdated(address(newContractRegistry));
    }

    /// Returns the contract registry that the contract is set to use
    /// @return contractRegistry is the registry contract address
    function getContractRegistry() public override view returns (IContractRegistry) {
        return contractRegistry;
    }

    function setRegistryAdmin(address _registryAdmin) external override onlyInitializationAdmin {
        _transferRegistryManagement(_registryAdmin);
    }

}

// File: contracts/spec_interfaces/ILockable.sol

pragma solidity 0.6.12;

/// @title lockable contract interface, allows to lock a contract
interface ILockable {

    event Locked();
    event Unlocked();

    /// Locks the contract to external non-governance function calls
    /// @dev governance function called only by the migration manager or an admin
    /// @dev typically called by the registry contract upon locking all managed contracts
    /// @dev getters and migration functions remain active also for locked contracts
    /// @dev checked by the onlyWhenActive modifier
    function lock() external /* onlyMigrationManager */;

    /// Unlocks the contract 
    /// @dev governance function called only by the migration manager or an admin
    /// @dev typically called by the registry contract upon unlocking all managed contracts
    function unlock() external /* onlyMigrationManager */;

    /// Returns the contract locking status
    /// @return isLocked is a bool indicating the contract is locked 
    function isLocked() view external returns (bool);

}

// File: contracts/Lockable.sol

pragma solidity 0.6.12;



/// @title lockable contract
contract Lockable is ILockable, ContractRegistryAccessor {

    bool public locked;

    /// Constructor
    /// @param _contractRegistry is the contract registry address
    /// @param _registryAdmin is the registry admin address
    constructor(IContractRegistry _contractRegistry, address _registryAdmin) ContractRegistryAccessor(_contractRegistry, _registryAdmin) public {}

    /// Locks the contract to external non-governance function calls
    /// @dev governance function called only by the migration manager or an admin
    /// @dev typically called by the registry contract upon locking all managed contracts
    /// @dev getters and migration functions remain active also for locked contracts
    /// @dev checked by the onlyWhenActive modifier
    function lock() external override onlyMigrationManager {
        locked = true;
        emit Locked();
    }

    /// Unlocks the contract 
    /// @dev governance function called only by the migration manager or an admin
    /// @dev typically called by the registry contract upon unlocking all managed contracts
    function unlock() external override onlyMigrationManager {
        locked = false;
        emit Unlocked();
    }

    /// Returns the contract locking status
    /// @return isLocked is a bool indicating the contract is locked 
    function isLocked() external override view returns (bool) {
        return locked;
    }

    modifier onlyWhenActive() {
        require(!locked, "contract is locked for this operation");

        _;
    }
}

// File: contracts/ManagedContract.sol

pragma solidity 0.6.12;



/// @title managed contract
contract ManagedContract is IManagedContract, Lockable {

    /// @param _contractRegistry is the contract registry address
    /// @param _registryAdmin is the registry admin address
    constructor(IContractRegistry _contractRegistry, address _registryAdmin) Lockable(_contractRegistry, _registryAdmin) public {}

    /// Refreshes the address of the other contracts the contract interacts with
    /// @dev called by the registry contract upon an update of a contract in the registry
    function refreshContracts() virtual override external {}

}

// File: contracts/GuardiansRegistration.sol

pragma solidity 0.6.12;




contract GuardiansRegistration is IGuardiansRegistration, ManagedContract {

	struct Guardian {
		address orbsAddr;
		bytes4 ip;
		uint32 registrationTime;
		uint32 lastUpdateTime;
		string name;
		string website;
	}
	mapping(address => Guardian) guardians;
	mapping(address => address) orbsAddressToGuardianAddress;
	mapping(bytes4 => address) public ipToGuardian;
	mapping(address => mapping(string => string)) guardianMetadata;

    /// Constructor
    /// @param _contractRegistry is the contract registry address
    /// @param _registryAdmin is the registry admin address
	constructor(IContractRegistry _contractRegistry, address _registryAdmin) ManagedContract(_contractRegistry, _registryAdmin) public {}

	modifier onlyRegisteredGuardian {
		require(isRegistered(msg.sender), "Guardian is not registered");

		_;
	}

	/*
     * External methods
     */

    /// Registers a new guardian
    /// @dev called using the guardian's address that holds the guardian self-stake and used for delegation
    /// @param ip is the guardian's node ipv4 address as a 32b number 
    /// @param orbsAddr is the guardian's Orbs node address 
    /// @param name is the guardian's name as a string
    /// @param website is the guardian's website as a string, publishing a name and website provide information for delegators
	function registerGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website) external override onlyWhenActive {
		require(!isRegistered(msg.sender), "registerGuardian: Guardian is already registered");

		guardians[msg.sender].registrationTime = uint32(block.timestamp);
		emit GuardianRegistered(msg.sender);

		_updateGuardian(msg.sender, ip, orbsAddr, name, website);
	}

    /// Updates a registered guardian data
    /// @dev may be called only by a registered guardian
    /// @param ip is the guardian's node ipv4 address as a 32b number 
    /// @param orbsAddr is the guardian's Orbs node address 
    /// @param name is the guardian's name as a string
    /// @param website is the guardian's website as a string, publishing a name and website provide information for delegators
	function updateGuardian(bytes4 ip, address orbsAddr, string calldata name, string calldata website) external override onlyRegisteredGuardian onlyWhenActive {
		_updateGuardian(msg.sender, ip, orbsAddr, name, website);
	}

    /// Updates a registered guardian ip address
    /// @dev may be called only by a registered guardian
    /// @dev may be called with either the guardian address or the guardian's orbs address
    /// @param ip is the guardian's node ipv4 address as a 32b number 
	function updateGuardianIp(bytes4 ip) external override onlyWhenActive {
		address guardianAddr = resolveGuardianAddress(msg.sender);
		Guardian memory data = guardians[guardianAddr];
		_updateGuardian(guardianAddr, ip, data.orbsAddr, data.name, data.website);
	}

    /// Updates a guardian's metadata property
    /// @dev called using the guardian's address
    /// @dev any key may be updated to be used by Orbs platform and tools
    /// @param key is the name of the property to update
    /// @param value is the value of the property to update in a string format
	function setMetadata(string calldata key, string calldata value) external override onlyRegisteredGuardian onlyWhenActive {
		_setMetadata(msg.sender, key, value);
	}

    /// Returns a guardian's metadata property
    /// @dev a property that wasn't set returns an empty string
    /// @param guardian is the guardian to query
    /// @param key is the name of the metadata property to query
    /// @return value is the value of the queried property in a string format
	function getMetadata(address guardian, string calldata key) external override view returns (string memory) {
		return guardianMetadata[guardian][key];
	}

    /// Unregisters a guardian
    /// @dev may be called only by a registered guardian
    /// @dev unregistering does not clear the guardian's metadata properties
	function unregisterGuardian() external override onlyRegisteredGuardian onlyWhenActive {
		delete orbsAddressToGuardianAddress[guardians[msg.sender].orbsAddr];
		delete ipToGuardian[guardians[msg.sender].ip];
		Guardian memory guardian = guardians[msg.sender];
		delete guardians[msg.sender];

		electionsContract.guardianUnregistered(msg.sender);
		emit GuardianDataUpdated(msg.sender, false, guardian.ip, guardian.orbsAddr, guardian.name, guardian.website, guardian.registrationTime);
		emit GuardianUnregistered(msg.sender);
	}

    /// Returns a guardian's data
    /// @param guardian is the guardian to query
    /// @param ip is the guardian's node ipv4 address as a 32b number 
    /// @param orbsAddr is the guardian's Orbs node address 
    /// @param name is the guardian's name as a string
    /// @param website is the guardian's website as a string
    /// @param registrationTime is the timestamp of the guardian's registration
    /// @param lastUpdateTime is the timestamp of the guardian's last update
	function getGuardianData(address guardian) external override view returns (bytes4 ip, address orbsAddr, string memory name, string memory website, uint registrationTime, uint lastUpdateTime) {
		Guardian memory v = guardians[guardian];
		return (v.ip, v.orbsAddr, v.name, v.website, v.registrationTime, v.lastUpdateTime);
	}

    /// Returns the Orbs addresses of a list of guardians
    /// @dev an unregistered guardian returns address(0) Orbs address
    /// @param guardianAddrs is a list of guardians' addresses to query
    /// @return orbsAddrs is a list of the guardians' Orbs addresses 
	function getGuardiansOrbsAddress(address[] calldata guardianAddrs) external override view returns (address[] memory orbsAddrs) {
		orbsAddrs = new address[](guardianAddrs.length);
		for (uint i = 0; i < guardianAddrs.length; i++) {
			orbsAddrs[i] = guardians[guardianAddrs[i]].orbsAddr;
		}
	}

    /// Returns a guardian's ip
    /// @dev an unregistered guardian returns 0 ip address
    /// @param guardian is the guardian to query
    /// @return ip is the guardian's node ipv4 address as a 32b number 
	function getGuardianIp(address guardian) external override view returns (bytes4 ip) {
		return guardians[guardian].ip;
	}

    /// Returns the ip of a list of guardians
    /// @dev an unregistered guardian returns 0 ip address
    /// @param guardianAddrs is a list of guardians' addresses to query
    /// @return ips is a list of the guardians' node ipv4 addresses as a 32b numbers
	function getGuardianIps(address[] calldata guardianAddrs) external override view returns (bytes4[] memory ips) {
		ips = new bytes4[](guardianAddrs.length);
		for (uint i = 0; i < guardianAddrs.length; i++) {
			ips[i] = guardians[guardianAddrs[i]].ip;
		}
	}

    /// Checks if a guardian is registered
    /// @param guardian is the guardian to query
    /// @return registered is a bool indicating a guardian address is registered
	function isRegistered(address guardian) public override view returns (bool) {
		return guardians[guardian].registrationTime != 0;
	}

    /// Translates a list guardians Orbs addresses to guardian addresses
    /// @dev an Orbs address that does not correspond to any registered guardian returns address(0)
    /// @param orbsAddrs is a list of the guardians' Orbs addresses to query
    /// @return guardianAddrs is a list of guardians' addresses that matches the Orbs addresses
	function getGuardianAddresses(address[] calldata orbsAddrs) external override view returns (address[] memory guardianAddrs) {
		guardianAddrs = new address[](orbsAddrs.length);
		for (uint i = 0; i < orbsAddrs.length; i++) {
			guardianAddrs[i] = orbsAddressToGuardianAddress[orbsAddrs[i]];
		}
	}

    /// Resolves the guardian address for a guardian, given a Guardian/Orbs address
    /// @dev revert if the address does not correspond to a registered guardian address or Orbs address
    /// @dev designed to be used for contracts calls, validating a registered guardian
    /// @dev should be used with caution when called by tools as the call may revert
    /// @dev in case of a conflict matching both guardian and Orbs address, the Guardian address takes precedence
    /// @param guardianOrOrbsAddress is the address to query representing a guardian address or Orbs address
    /// @return guardianAddress is the guardian address that matches the queried address
	function resolveGuardianAddress(address guardianOrOrbsAddress) public override view returns (address guardianAddress) {
		if (isRegistered(guardianOrOrbsAddress)) {
			guardianAddress = guardianOrOrbsAddress;
		} else {
			guardianAddress = orbsAddressToGuardianAddress[guardianOrOrbsAddress];
		}

		require(guardianAddress != address(0), "Cannot resolve address");
	}

	/*
	 * Governance
	 */

    /// Migrates a list of guardians from a previous guardians registration contract
    /// @dev governance function called only by the initialization admin
    /// @dev reads the migrated guardians data by calling getGuardianData in the previous contract
    /// @dev imports also the guardians' registration time and last update
    /// @dev emits a GuardianDataUpdated for each guardian to allow tracking by tools
    /// @param guardiansToMigrate is a list of guardians' addresses to migrate
    /// @param previousContract is the previous registration contract address
	function migrateGuardians(address[] calldata guardiansToMigrate, IGuardiansRegistration previousContract) external override onlyInitializationAdmin {
		require(previousContract != IGuardiansRegistration(0), "previousContract must not be the zero address");

		for (uint i = 0; i < guardiansToMigrate.length; i++) {
			require(guardiansToMigrate[i] != address(0), "guardian must not be the zero address");
			migrateGuardianData(previousContract, guardiansToMigrate[i]);
			migrateGuardianMetadata(previousContract, guardiansToMigrate[i]);
		}
	}

	/*
	 * Private methods
	 */

    /// Updates a registered guardian data
    /// @dev used by external functions that register a guardian or update its data
    /// @dev emits a GuardianDataUpdated event on any update to the registration  
    /// @param guardianAddr is the address of the guardian to update
    /// @param ip is the guardian's node ipv4 address as a 32b number 
    /// @param orbsAddr is the guardian's Orbs node address 
    /// @param name is the guardian's name as a string
    /// @param website is the guardian's website as a string, publishing a name and website provide information for delegators
	function _updateGuardian(address guardianAddr, bytes4 ip, address orbsAddr, string memory name, string memory website) private {
		require(orbsAddr != address(0), "orbs address must be non zero");
		require(orbsAddr != guardianAddr, "orbs address must be different than the guardian address");
		require(!isRegistered(orbsAddr), "orbs address must not be a guardian address of a registered guardian");
		require(bytes(name).length != 0, "name must be given");

		Guardian memory guardian = guardians[guardianAddr];

		delete ipToGuardian[guardian.ip];
		require(ipToGuardian[ip] == address(0), "ip is already in use");
		ipToGuardian[ip] = guardianAddr;

		delete orbsAddressToGuardianAddress[guardian.orbsAddr];
		require(orbsAddressToGuardianAddress[orbsAddr] == address(0), "orbs address is already in use");
		orbsAddressToGuardianAddress[orbsAddr] = guardianAddr;

		guardian.orbsAddr = orbsAddr;
		guardian.ip = ip;
		guardian.name = name;
		guardian.website = website;
		guardian.lastUpdateTime = uint32(block.timestamp);

		guardians[guardianAddr] = guardian;

        emit GuardianDataUpdated(guardianAddr, true, ip, orbsAddr, name, website, guardian.registrationTime);
    }

    /// Updates a guardian's metadata property
    /// @dev used by setMetadata and migration functions
    /// @dev any key may be updated to be used by Orbs platform and tools
    /// @param key is the name of the property to update
    /// @param value is the value of the property to update in a string format
	function _setMetadata(address guardian, string memory key, string memory value) private {
		string memory oldValue = guardianMetadata[guardian][key];
		guardianMetadata[guardian][key] = value;
		emit GuardianMetadataChanged(guardian, key, value, oldValue);
	}

    /// Migrates a guardian data from a previous guardians registration contract
    /// @dev used by migrateGuardians
    /// @dev reads the migrated guardians data by calling getGuardianData in the previous contract
    /// @dev imports also the guardians' registration time and last update
    /// @dev emits a GuardianDataUpdated
    /// @param previousContract is the previous registration contract address
    /// @param guardianAddress is the address of the guardians to migrate
	function migrateGuardianData(IGuardiansRegistration previousContract, address guardianAddress) private {
		(bytes4 ip, address orbsAddr, string memory name, string memory website, uint registrationTime, uint lastUpdateTime) = previousContract.getGuardianData(guardianAddress);
		guardians[guardianAddress] = Guardian({
			orbsAddr: orbsAddr,
			ip: ip,
			name: name,
			website: website,
			registrationTime: uint32(registrationTime),
			lastUpdateTime: uint32(lastUpdateTime)
		});
		orbsAddressToGuardianAddress[orbsAddr] = guardianAddress;
		ipToGuardian[ip] = guardianAddress;

		emit GuardianRegistered(guardianAddress);
		emit GuardianDataUpdated(guardianAddress, true, ip, orbsAddr, name, website, registrationTime);
	}

	string public constant ID_FORM_URL_METADATA_KEY = "ID_FORM_URL";

    /// Migrates a guardian metadata keys in use from a previous guardians registration contract
    /// @dev the metadata used by the contract are hard-coded in the function
    /// @dev used by migrateGuardians
    /// @dev reads the migrated guardians metadata by calling getMetadata in the previous contract
    /// @dev emits a GuardianMetadataChanged
    /// @param previousContract is the previous registration contract address
    /// @param guardianAddress is the address of the guardians to migrate	
	function migrateGuardianMetadata(IGuardiansRegistration previousContract, address guardianAddress) private {
		string memory rewardsFreqMetadata = previousContract.getMetadata(guardianAddress, ID_FORM_URL_METADATA_KEY);
		if (bytes(rewardsFreqMetadata).length > 0) {
			_setMetadata(guardianAddress, ID_FORM_URL_METADATA_KEY, rewardsFreqMetadata);
		}
	}

	/*
     * Contracts topology / registry interface
     */

	IElections electionsContract;

    /// Refreshes the address of the other contracts the contract interacts with
    /// @dev called by the registry contract upon an update of a contract in the registry
	function refreshContracts() external override {
		electionsContract = IElections(getElectionsContract());
	}

}