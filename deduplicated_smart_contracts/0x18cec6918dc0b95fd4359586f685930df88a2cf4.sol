/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity 0.5.10;

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
  * @author @veronicaLC (Veronica Coutts) & @RyRy79261 (Ryan Nobel)
  * @title  The interface for the molecule vault
  */
interface IMoleculeVault {

    /**
      * @notice Allows an admin to add another admin.
      * @param  _moleculeAdmin: The address of the new admin.
      */
    function addAdmin(address _moleculeAdmin) external;
    
    /**
      * @notice Allows an admin to transfer colalteral out of the molecule
      *         vault and into another address.
      * @param  _to: The address that the collateral will be transfered to.
      * @param  _amount: The amount of collateral being transfered.
      */
    function transfer(address _to, uint256 _amount) external;

    /**
      * @notice Allows an admin to approve a spender of the molecule vault
      *         collateral.
      * @param  _spender: The address that will be aproved as a spender.
      * @param  _amount: The amount the spender will be approved to spend.
      */
    function approve(address _spender, uint256 _amount) external;

    /**
      * @notice Allows the admin to update the fee rate charged by the
      *         molecule vault.
      * @param  _newFeeRate : The new fee rate.
      * @return bool: If the update was successful
      */
    function updateFeeRate(uint256 _newFeeRate) external returns(bool);

    /**
      * @return address: The address of the collateral token.
      */
    function collateralToken() external view returns(address);

    /**
      * @return uint256 : The fee rate the molecule vault has.
      */
    function feeRate() external view returns(uint256);
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
  * @title  Storage and acess to the molecule fee.
  * @notice The vault will send the molecule vault its fee rate when a round of
  *         funding has been successfully filled.
  */
contract MoleculeVault is IMoleculeVault, ModifiedWhitelistAdminRole {
    // The collateral token being used by the vaults and markets
    IERC20 internal collateralToken_;
    // The fee rate of the molecule vault
    uint256 internal feeRate_ = 0;

    /**
      * @notice Setts the state variables for the contract.
      * @param  _collateralToken : The address of the collateral token (ERC20).
      * @param  _feeRate : The fee rate to be used by the vaults.
      */
    constructor(
        address _collateralToken,
        address _admin,
        uint256 _feeRate
    )
        public
        ModifiedWhitelistAdminRole()
    {
        // Ensures that the fee rate is correct
        require(_feeRate < 100, "Fee rate too high");
        // Checks the addresses cannot be 0
        require(
            address(_collateralToken) != address(0) &&
            address(_admin) != address(0),
            "Address(s) cannot be 0"
        );

        collateralToken_ = IERC20(_collateralToken);
        feeRate_ = _feeRate;
        super.addNewInitialAdmin(_admin);
        super.renounceWhitelistAdmin();
    }

    /**
      * @notice Allows an admin to add another admin.
      * @param  _moleculeAdmin: The address of the new admin.
      */
    function addAdmin(address _moleculeAdmin) external onlyWhitelistAdmin() {
        // Adding the Molecule admin address as an admin
        super.addWhitelistAdmin(_moleculeAdmin);
    }

    /**
      * @notice Allows an admin to transfer collateral out of the molecule
      *         vault and into another address.
      * @param  _to: The address that the collateral will be transferred to.
      * @param  _amount: The amount of collateral being transferred.
      */
    function transfer(
        address _to,
        uint256 _amount
    )
        public
        onlyWhitelistAdmin()
    {
        require(
            IERC20(collateralToken_).transfer(_to, _amount),
            "Transfer failed"
        );
    }

    /**
      * @notice Allows an admin to approve a spender of the molecule vault
      *         collateral.
      * @param  _spender: The address that will be approved as a spender.
      * @param  _amount: The amount the spender will be approved to spend.
      */
    function approve(
        address _spender,
        uint256 _amount
    )
        public
        onlyWhitelistAdmin()
    {
        require(
            IERC20(collateralToken_).approve(_spender, _amount),
            "Approve failed"
        );
    }

    /**
      * @notice Allows the admin to update the fee rate charged by the
      *         molecule vault. Any change to this fee rate will not affect
      *         future Markets. This was done to ensure transparency
      *         and trust in the fee rates.
      * @param  _newFeeRate : The new fee rate.
      * @return bool: If the update was successful
      */
    function updateFeeRate(
        uint256 _newFeeRate
    )
        external
        onlyWhitelistAdmin()
        returns(bool)
    {
        require(
            feeRate_ != _newFeeRate,
            "New fee rate cannot be the same as old fee rate"
        );
        // Ensures that the fee rate is correct
        require(_newFeeRate < 100, "Fee rate too high");

        feeRate_ = _newFeeRate;
        return true;
    }

    /**
      * @return address: The address of the collateral token.
      */
    function collateralToken() public view returns(address) {
        return address(collateralToken_);
    }

    /**
      * @return uint256 : The rate of fee
      */
    function feeRate() public view returns(uint256) {
        return feeRate_;
    }
}