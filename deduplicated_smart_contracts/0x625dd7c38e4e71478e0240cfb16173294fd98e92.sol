/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity 0.5.10;

/**
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  The interface for the curve registry.
  */
interface ICurveRegistry {
	// Emitted when a curve is registered
    event CurveRegisterd(
        uint256 index,
        address indexed libraryAddress,
        string curveFunction
    );
	// Emitted when a curve is registered
    event CurveActivated(uint256 index, address indexed libraryAddress);
	// Emitted when a curve is deactivated
    event CurveDeactivated(uint256 index, address indexed libraryAddress);

    /**
      * @dev    Logs the market into the registery.
      * @param  _libraryAddress: Address of the library.
      * @param  _curveFunction: Curve title/statement.
      * @return uint256: Returns the index of market for looking up
      */
    function registerCurve(
        address _libraryAddress,
        string calldata _curveFunction)
        external
        returns(uint256);

    /**
      * @notice Allows an dmin to set a curves state to inactive. This function
      *         is for the case of an incorect curve module, or vunrability.
      * @param  _index: The index of the curve to be set as inactive.
      */
    function deactivateCurve(uint256 _index) external;

    /**
      * @notice Allows an admin to set a curves state to active.
      * @param  _index: The index of the curve to be set as active.
      */
    function reactivateCurve(uint256 _index) external;

    /**
      * @dev    Fetches all data and contract addresses of deployed curves by
      *         index, kept as interface for later intergration.
      * @param  _index: Index of the curve library
      * @return address: The address of the curve
      */
    function getCurveAddress(uint256 _index)
        external
        view
        returns(address);

    /**
      * @dev    Fetches all data and contract addresses of deployed curves by
      *         index, kept as interface for later intergration.
      * @param  _index: Index of the curve library.
      * @return address: The address of the math library.
      * @return string: The function of the curve.
      * @return bool: The curves active state.
      */
    function getCurveData(uint256 _index)
        external
        view
        returns(
            address,
            string memory,
            bool
        );

    /**
      * @dev    Fetchs the current number of curves infering maximum callable
      *         index.
      * @return uint256: Returns the total number of curves registered.
      */
    function getIndex()
        external
        view
        returns(uint256);

    /**
      * @dev    In order to look up logs efficently, the published block is
      *         available.
      * @return uint256: The block when the contract was published
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
  * @title  Storage of curves and active deployers.
  */
contract CurveRegistry is ICurveRegistry, ModifiedWhitelistAdminRole {
    // The total number of curves
    uint256 internal numberOfCurves_ = 0;
    // The block number when this contract was published
    uint256 internal publishedBlocknumber_;
    // The init function can only be called once 
    bool internal isInitialized_  = false;

    // Mapping of all the curves deployed by their index
    mapping(uint256 => CurveOption) internal curveContracts_;

    // The information stored about each curve
    struct CurveOption{
        address libraryAddress;
        string curveFunction;
        bool active;
    }

    /**
      * @notice The deployer of this contract will be the admin.
      */
    constructor() public ModifiedWhitelistAdminRole() {
        publishedBlocknumber_ = block.number;
    }

    function init(address _admin) public onlyWhitelistAdmin() {
        require(!isInitialized_, "Contract is initialized");
        super.addNewInitialAdmin(_admin);
        super.renounceWhitelistAdmin();
        isInitialized_ = true;
    }

    /**
      * @dev    Logs the market into the registery.
      * @param  _libraryAddress: Address of the library.
      * @param  _curveFunction: Curve title/statement.
      * @return uint256: Returns the index of market for looking up
      */
    function registerCurve(
        address _libraryAddress,
        string calldata _curveFunction)
        external
        onlyWhitelistAdmin()
        returns(uint256)
    {
        require(
            address(_libraryAddress) != address(0),
            "Address cannot be 0"
        );
        
        uint256 index = numberOfCurves_;
        numberOfCurves_ = numberOfCurves_ + 1;

        curveContracts_[index].libraryAddress = _libraryAddress;
        curveContracts_[index].curveFunction = _curveFunction;
        curveContracts_[index].active = true;

        emit CurveRegisterd(
            index,
            _libraryAddress,
            _curveFunction
        );

        return index;
    }

    /**
      * @notice Allows an dmin to set a curves state to inactive. This function
      *         is for the case of an incorect curve module, or vunrability.
      * @param  _index: The index of the curve to be set as inactive.
      */
    function deactivateCurve(uint256 _index) external onlyWhitelistAdmin() {
        require(
            curveContracts_[_index].active == true,
            "Curve already deactivated"
        );
        require(
            curveContracts_[_index].libraryAddress != address(0),
            "Curve not registered"
        );

        curveContracts_[_index].active = false;

        emit CurveDeactivated(_index, curveContracts_[_index].libraryAddress);
    }

    /**
      * @notice Allows an admin to set a curves state to active.
      * @param  _index: The index of the curve to be set as active.
      */
    function reactivateCurve(uint256 _index) external onlyWhitelistAdmin() {
        require(
            curveContracts_[_index].active == false,
            "Curve already activated"
        );
        require(
            curveContracts_[_index].libraryAddress != address(0),
            "Curve not registered"
        );
        
        curveContracts_[_index].active = true;
        
        emit CurveActivated(_index, curveContracts_[_index].libraryAddress);
    }

    /**
      * @dev    Fetches all data and contract addresses of deployed curves by
      *         index, kept as interface for later intergration.
      * @param  _index: Index of the curve library
      * @return address: The address of the curve
      */
    function getCurveAddress(uint256 _index)
        external
        view
        returns(address)
    {
        return curveContracts_[_index].libraryAddress;
    }

    /**
      * @dev    Fetches all data and contract addresses of deployed curves by
      *         index, kept as interface for later intergration.
      * @param  _index: Index of the curve library.
      * @return address: The address of the math library.
      * @return string: The function of the curve.
      * @return bool: The curves active state.
      */
    function getCurveData(uint256 _index)
        external
        view
        returns(
            address,
            string memory,
            bool
        )
    {
        return (
            curveContracts_[_index].libraryAddress,
            curveContracts_[_index].curveFunction,
            curveContracts_[_index].active
        );
    }

    /**
      * @dev    Fetchs the current number of curves infering maximum callable
      *         index.
      * @return uint256: Returns the total number of curves registered.
      */
    function getIndex()
        external
        view
        returns(uint256)
    {
        return numberOfCurves_;
    }

    /**
      * @dev    In order to look up logs efficently, the published block is
      *         available.
      * @return uint256: The block when the contract was published
      */
    function publishedBlocknumber() external view returns(uint256) {
        return publishedBlocknumber_;
    }
}