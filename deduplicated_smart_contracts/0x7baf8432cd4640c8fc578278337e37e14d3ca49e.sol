/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

/**
 * This smart contract code is Copyright 2019 TokenMarket Ltd. For more information see https://tokenmarket.net
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 * NatSpec is used intentionally to cover also other than public functions
 */



interface KYCInterface {
  event AttributesSet(address indexed who, uint256 indexed flags);

  function getAttribute(address addr, uint8 attribute) external view returns (bool);
}




/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}



/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 *      Supports unlimited numbers of roles and addresses.
 *      See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 *  for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 *  to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * A constant role name for indicating admins.
   */
  string public constant ROLE_ADMIN = "admin";

  /**
   * @dev constructor. Sets msg.sender as admin by default
   */
  function RBAC()
    public
  {
    addRole(msg.sender, ROLE_ADMIN);
  }

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminAddRole(address addr, string roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminRemoveRole(address addr, string roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

  /**
   * @dev modifier to scope access to admins
   * // reverts
   */
  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param roleNames the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] roleNames) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < roleNames.length; i++) {
  //         if (hasRole(msg.sender, roleNames[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}


/**
 * @author TokenMarket /  Ville Sundell <ville at tokenmarket.net>
 */
contract BasicKYC is RBAC, KYCInterface {
  /** @dev This mapping contains signature hashes which have been already used: */
  mapping (bytes32 => bool) public hashes;
  /** @dev Mapping of all the attributes for all the users: */
  mapping (address => uint256) public attributes;

  /** @dev These can be used from other contracts to avoid typos with roles: */
  string public constant ROLE_SIGNER = "signer";
  string public constant ROLE_SETTER = "setter";

  /**
   * @dev Interal function for setting the attributes, and emmiting the event
   * @param user Address of the user whose attributes we would like to set
   * @param newAttributes Whole set of 256 attributes
   */
  function writeAttributes(address user, uint256 newAttributes) internal {
    attributes[user] = newAttributes;

    emit AttributesSet(user, attributes[user]);
  }

  /**
   * @dev Set all the attributes for a user all in once
   * @param user Address of the user whose attributes we would like to set
   * @param newAttributes Whole set of 256 attributes
   */
  function setAttributes(address user, uint256 newAttributes) external onlyRole(ROLE_SETTER) {
    writeAttributes(user, newAttributes);
  }

  /**
   * @dev Get a attribute for a user, return true or false
   * @param user Address of the user whose attribute we would like to have
   * @param attribute Attribute index from 0 to 255
   * @return Attribute status, set or unset
   */
  function getAttribute(address user, uint8 attribute) external view returns (bool) {
    return (attributes[user] & 2**attribute) > 0;
  }

  /**
   * @dev Set attributes an address. User can set their own attributes by using a
   *      signed message from server side.
   * @param signer Address of the server side signing key
   * @param newAttributes 256 bit integer for all the attributes for an address
   * @param nonce Value to prevent re-use of the server side signed data
   * @param v V of the server's key which was used to sign this transfer
   * @param r R of the server's key which was used to sign this transfer
   * @param s S of the server's key which was used to sign this transfer
   */
  function setMyAttributes(address signer, uint256 newAttributes, uint128 nonce, uint8 v, bytes32 r, bytes32 s) external {
    require(hasRole(signer, ROLE_SIGNER));

    bytes32 hash = keccak256(msg.sender, signer, newAttributes, nonce);
    require(hashes[hash] == false);
    require(ecrecover(hash, v, r, s) == signer);

    hashes[hash] = true;
    writeAttributes(msg.sender, newAttributes);
  }

}