/**

 *Submitted for verification at Etherscan.io on 2019-04-22

*/



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}





/**

 * @title Roles

 * @author Francisco Giordano (@frangio)

 * @dev Library for managing addresses assigned to a Role.

 * See RBAC.sol for example usage.

 */

library Roles {

    struct Role {

        mapping (address => bool) bearer;

    }



    /**

     * @dev give an address access to this role

     */

    function add(Role storage _role, address _addr) internal {

        _role.bearer[_addr] = true;

    }



    /**

     * @dev remove an address' access to this role

     */

    function remove(Role storage _role, address _addr) internal {

        _role.bearer[_addr] = false;

    }



    /**

     * @dev check if an address has this role

     * // reverts

     */

    function check(Role storage _role, address _addr) internal view {

        require(has(_role, _addr));

    }



    /**

     * @dev check if an address has this role

     * @return bool

     */

    function has(Role storage _role, address _addr) internal view returns (bool) {

        return _role.bearer[_addr];

    }

}





/**

 * @title RBAC (Role-Based Access Control)

 * @author Matt Condon (@Shrugs)

 * @dev Stores and provides setters and getters for roles and addresses.

 * Supports unlimited numbers of roles and addresses.

 * See //contracts/mocks/RBACMock.sol for an example of usage.

 * This RBAC method uses strings to key roles. It may be beneficial

 * for you to write your own implementation of this interface using Enums or similar.

 */

contract RBAC {

    using Roles for Roles.Role;



    mapping (string => Roles.Role) private roles;



    event RoleAdded(address indexed operator, string role);

    event RoleRemoved(address indexed operator, string role);



    /**

     * @dev reverts if addr does not have role

     * @param _operator address

     * @param _role the name of the role

     * // reverts

     */

    function checkRole(address _operator, string _role)

        public

        view

    {

        roles[_role].check(_operator);

    }



    /**

     * @dev determine if addr has role

     * @param _operator address

     * @param _role the name of the role

     * @return bool

     */

    function hasRole(address _operator, string _role)

        public

        view

        returns (bool)

    {

        return roles[_role].has(_operator);

    }



    /**

     * @dev add a role to an address

     * @param _operator address

     * @param _role the name of the role

     */

    function addRole(address _operator, string _role) internal {

        roles[_role].add(_operator);

        emit RoleAdded(_operator, _role);

    }



    /**

     * @dev remove a role from an address

     * @param _operator address

     * @param _role the name of the role

     */

    function removeRole(address _operator, string _role) internal {

        roles[_role].remove(_operator);

        emit RoleRemoved(_operator, _role);

    }



    /**

     * @dev modifier to scope access to a single role (uses msg.sender as addr)

     * @param _role the name of the role

     * // reverts

     */

    modifier onlyRole(string _role) {

        checkRole(msg.sender, _role);

        _;

    }



}





/**

 * @title Whitelist

 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.

 * This simplifies the implementation of "user permissions".

 */

contract Whitelist is Ownable, RBAC {

    string public constant ROLE_WHITELISTED = "whitelist";



    /**

     * @dev Throws if operator is not whitelisted.

     * @param _operator address

     */

    modifier onlyIfWhitelisted(address _operator) {

        checkRole(_operator, ROLE_WHITELISTED);

        _;

    }



    /**

     * @dev add an address to the whitelist

     * @param _operator address

     * @return true if the address was added to the whitelist, false if the address was already in the whitelist

     */

    function addAddressToWhitelist(address _operator)

        public

        onlyOwner

    {

        addRole(_operator, ROLE_WHITELISTED);

    }



    /**

     * @dev getter to determine if address is in whitelist

     */

    function whitelist(address _operator)

        public

        view

        returns (bool)

    {

        return hasRole(_operator, ROLE_WHITELISTED);

    }



    /**

     * @dev add addresses to the whitelist

     * @param _operators addresses

     * @return true if at least one address was added to the whitelist,

     * false if all addresses were already in the whitelist

     */

    function addAddressesToWhitelist(address[] _operators)

        public

        onlyOwner

    {

        for (uint256 i = 0; i < _operators.length; i++) {

            addAddressToWhitelist(_operators[i]);

        }

    }



    /**

     * @dev remove an address from the whitelist

     * @param _operator address

     * @return true if the address was removed from the whitelist,

     * false if the address wasn't in the whitelist in the first place

     */

    function removeAddressFromWhitelist(address _operator)

        public

        onlyOwner

    {

        removeRole(_operator, ROLE_WHITELISTED);

    }



    /**

     * @dev remove addresses from the whitelist

     * @param _operators addresses

     * @return true if at least one address was removed from the whitelist,

     * false if all addresses weren't in the whitelist in the first place

     */

    function removeAddressesFromWhitelist(address[] _operators)

        public

        onlyOwner

    {

        for (uint256 i = 0; i < _operators.length; i++) {

            removeAddressFromWhitelist(_operators[i]);

        }

    }

}