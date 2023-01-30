/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity 0.5.10;

/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  The interface for the market registry.
  */
interface IMarketRegistry {
	// Emitted when a market is created
    event MarketCreated(
		uint256 index,
		address indexed marketAddress,
		address indexed vault,
		address indexed creator
    );
	// Emitted when a deployer is added
    event DeployerAdded(address deployer, string version);
    // Emitted when a deployer is removed
	event DeployerRemoved(address deployer, string reason);

    /**
      * @dev    Adds a new market deployer to the registry.
      * @param  _newDeployer: Address of the new market deployer.
      * @param  _version: string - Log text for tracking purposes.
      */
    function addMarketDeployer(
      address _newDeployer,
      string calldata _version
    ) external;

    /**
      * @dev    Removes a market deployer from the registry.
      * @param  _deployerToRemove: Address of the market deployer to remove.
      * @param  _reason: Log text for tracking purposes.
      */
    function removeMarketDeployer(
      address _deployerToRemove,
      string calldata _reason
    ) external;

    /**
      * @dev    Logs the market into the registery.
      * @param  _vault: Address of the vault.
      * @param  _creator: Creator of the market.
      * @return uint256: Returns the index of market for looking up.
      */
    function registerMarket(
        address _marketAddress,
        address _vault,
        address _creator
    )
        external
        returns(uint256);

    /**
      * @dev    Fetches all data and contract addresses of deployed
      *         markets by index, kept as interface for later
      *         intergration.
      * @param  _index: Index of the market.
      * @return address: The address of the market.
	  * @return	address: The address of the vault.
	  * @return	address: The address of the creator.
      */
    function getMarket(uint256 _index)
        external
        view
        returns(
            address,
            address,
            address
        );

	/**
	  * @dev	Fetchs the current number of markets infering maximum
	  *			callable index.
	  * @return	uint256: The number of markets that have been deployed.
	  */
    function getIndex() external view returns(uint256);

	/**
	  * @dev	Used to check if the deployer is registered.
      * @param  _deployer: The address of the deployer
	  * @return	bool: A simple bool to indicate state.
	  */
    function isMarketDeployer(address _deployer) external view returns(bool);

	/**
	  * @dev	In order to look up logs efficently, the published block is
	  *			available.
	  * @return	uint256: The block when the contract was published.
	  */
    function publishedBlocknumber() external view returns(uint256);
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


/**
  * @title  ModifiedWhitelistAdminRole
  * @dev    WhitelistAdmins are responsible for assigning and removing 
  *         Whitelisted accounts.
  */
contract ModifiedWhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;
    // this is a uint8 rather than a 256 for storage. 
    uint8 internal noOfAdmins_;
    // Initial admin address 
    address internal initialAdmin_;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
        initialAdmin_ = msg.sender;
    }

    modifier onlyWhitelistAdmin() {
        require(
            isWhitelistAdmin(msg.sender), 
            "ModifiedWhitelistAdminRole: caller does not have the WhitelistAdmin role"
        );
        _;
    }

    /**
      * @dev    This allows for the initial admin added to have additional admin
      *         rights, such as removing another admin. 
      */
    modifier onlyInitialAdmin() {
        require(
            msg.sender == initialAdmin_,
            "Only initial admin may remove another admin"
        );
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin() {
        _addWhitelistAdmin(account);
    }

    /**
      * @dev    This allows the initial admin to replace themselves as the super
      *         admin.
      * @param  account: The address of the new super admin
      */
    function addNewInitialAdmin(address account) public onlyInitialAdmin() {
        if(!isWhitelistAdmin(account)) {
            _addWhitelistAdmin(account);
        }
        initialAdmin_ = account;
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    /**
      * @dev    Allows the super admin to remover other admins
      * @param  account: The address of the admin to be removed
      */
    function removeWhitelistAdmin(address account) public onlyInitialAdmin() {
        _removeWhitelistAdmin(account);
    }

    function _addWhitelistAdmin(address account) internal {
        if(!isWhitelistAdmin(account)) {
            noOfAdmins_ += 1;
        }
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        noOfAdmins_ -= 1;
        require(noOfAdmins_ >= 1, "Cannot remove all admins");
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    function getAdminCount() public view returns(uint8) {
        return noOfAdmins_;
    }
}



/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  Storage of markets (vaults and markets) as well as deployers.
  */
contract MarketRegistry is IMarketRegistry, ModifiedWhitelistAdminRole {
    // The total number of markets
    uint256 internal numberOfMarkets_ = 0;
    // The block number when this contract was published
    uint256 internal publishedBlocknumber_;
    // The init function can only be called once 
    bool internal isInitialized_  = false;

    // Mapping of all the markets deployed to their index
    mapping(uint256 => Market) internal markets_;
    // Mapping of all deployers
    mapping(address => bool) internal deployer_;

    // The information stored about each market
    struct Market {
        address marketAddress;
        address vault;
        address creator;
    }

    /**
      * @notice The deployer of this contract will be the admin.
      */
    constructor() public ModifiedWhitelistAdminRole() {
        publishedBlocknumber_ = block.number;
    }

    modifier isRegisteredDeployer() {
        require(deployer_[msg.sender], "Deployer not registered");
        _;
    }

    function init(address _admin) public onlyWhitelistAdmin() {
        require(!isInitialized_, "Contract is initialized");
        super.addNewInitialAdmin(_admin);
        super.renounceWhitelistAdmin();
        isInitialized_ = true;
    }

    /**
      * @dev    Adds a new market deployer to the registry.
      * @param  _newDeployer: Address of the new market deployer.
      * @param  _version: string - Log text for tracking purposes.
      */
    function addMarketDeployer(
        address _newDeployer,
        string calldata _version
    )
        external
        onlyWhitelistAdmin()
    {
        require(deployer_[_newDeployer] != true, "Already approved");
        deployer_[_newDeployer] = true;
        emit DeployerAdded(_newDeployer, _version);
    }

    /**
      * @dev    Removes a market deployer from the registry.
      * @param  _deployerToRemove: Address of the market deployer to remove.
      * @param  _reason: Log text for tracking purposes.
      */
    function removeMarketDeployer(
        address _deployerToRemove,
        string calldata _reason
    )
        external
        onlyWhitelistAdmin()
    {
        require(deployer_[_deployerToRemove] != false, "Already inactive");
        deployer_[_deployerToRemove] = false;
        emit DeployerRemoved(_deployerToRemove, _reason);
    }

    /**
      * @dev    Logs the market into the registery.
      * @param  _vault: Address of the vault.
      * @param  _creator: Creator of the market.
      * @return uint256: Returns the index of market for looking up.
      */
    function registerMarket(
        address _marketAddress,
        address _vault,
        address _creator)
        external
        isRegisteredDeployer()
        returns(uint256)
    {
        // Checks that none of the addresses are 0
        require(
            address(_marketAddress) != address(0) &&
            address(_vault) != address(0) &&
            address(_creator) != address(0),
            "Address(s) cannot be 0"
        );

        uint256 index = numberOfMarkets_;
        numberOfMarkets_ = numberOfMarkets_ + 1;

        markets_[index].marketAddress = _marketAddress;
        markets_[index].vault = _vault;
        markets_[index].creator = _creator;

        emit MarketCreated(
            index,
            _marketAddress,
            _vault,
            _creator
        );

        return index;
    }

    /**
      * @dev    Fetches all data and contract addresses of deployed
      *         markets by index, kept as interface for later
      *         intergration.
      * @param  _index: Index of the market.
      * @return address: The address of the market.
	  * @return	address: The address of the vault.
	  * @return	address: The address of the creator.
      */
    function getMarket(uint256 _index)
        external
        view
        returns(
            address,
            address,
            address
        )
    {
        return (
            markets_[_index].marketAddress,
            markets_[_index].vault,
            markets_[_index].creator
        );
    }

    /**
	  * @dev	Fetchs the current number of markets infering maximum
	  *			callable index.
	  * @return	uint256: The number of markets that have been deployed.
	  */
    function getIndex()
        external
        view
        returns(uint256)
    {
        return numberOfMarkets_;
    }

    /**
	  * @dev	Used to check if the deployer is registered.
      * @param  _deployer: The address of the deployer
	  * @return	bool: A simple bool to indicate state.
	  */
    function isMarketDeployer(
        address _deployer
    )
        external
        view
        returns(bool)
    {
        return deployer_[_deployer];
    }

    /**
	  * @dev	In order to look up logs efficently, the published block is
	  *			available.
	  * @return	uint256: The block when the contract was published.
	  */
    function publishedBlocknumber() external view returns(uint256) {
        return publishedBlocknumber_;
    }
}