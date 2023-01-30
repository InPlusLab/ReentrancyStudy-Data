/**

 *Submitted for verification at Etherscan.io on 2019-08-19

*/



/**

 *Submitted for verification at Etherscan.io on 2019-07-31

*/



pragma solidity ^0.5.1;



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



contract PauserRole {

    using Roles for Roles.Role;



    event PauserAdded(address indexed account);

    event PauserRemoved(address indexed account);



    Roles.Role private _pausers;



    constructor () internal {

        _addPauser(msg.sender);

    }



    modifier onlyPauser() {

        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");

        _;

    }



    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);

    }



    function addPauser(address account) public onlyPauser {

        _addPauser(account);

    }



    function renouncePauser() public {

        _removePauser(msg.sender);

    }



    function _addPauser(address account) internal {

        _pausers.add(account);

        emit PauserAdded(account);

    }



    function _removePauser(address account) internal {

        _pausers.remove(account);

        emit PauserRemoved(account);

    }

}



/**

 * @dev Contract module which allows children to implement an emergency stop

 * mechanism that can be triggered by an authorized account.

 *

 * This module is used through inheritance. It will make available the

 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to

 * the functions of your contract. Note that they will not be pausable by

 * simply including this module, only once the modifiers are put in place.

 */

contract Pausable is PauserRole {

    /**

     * @dev Emitted when the pause is triggered by a pauser (`account`).

     */

    event Paused(address account);



    /**

     * @dev Emitted when the pause is lifted by a pauser (`account`).

     */

    event Unpaused(address account);



    bool private _paused;



    /**

     * @dev Initializes the contract in unpaused state. Assigns the Pauser role

     * to the deployer.

     */

    constructor () internal {

        _paused = false;

    }



    /**

     * @dev Returns true if the contract is paused, and false otherwise.

     */

    function paused() public view returns (bool) {

        return _paused;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is not paused.

     */

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");

        _;

    }



    /**

     * @dev Modifier to make a function callable only when the contract is paused.

     */

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");

        _;

    }



    /**

     * @dev Called by a pauser to pause, triggers stopped state.

     */

    function pause() public onlyPauser whenNotPaused {

        _paused = true;

        emit Paused(msg.sender);

    }



    /**

     * @dev Called by a pauser to unpause, returns to normal state.

     */

    function unpause() public onlyPauser whenPaused {

        _paused = false;

        emit Unpaused(msg.sender);

    }

}



contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");

        _;

    }



    /**

     * @dev Returns true if the caller is the current owner.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract BitGemCheckIn is Ownable, Pausable {

    mapping (address => mapping(uint => uint)) private checkins;

    bool private isDev = false;



    // constructor() public Ownable() PauserRole() { }



    function enableDev(bool dev) public onlyOwner {

        isDev = dev;

    }



    function checkIn() public whenNotPaused returns (bool) {

        uint day = block.timestamp / 1 days;

        checkins[msg.sender][day / 256] |= (1 << (day % 256));

        return true;

    }





    function checkInDev(uint timestamp) public whenNotPaused returns (bool) {

        require(isDev, "require dev");

        uint day = timestamp / 1 days;

        checkins[msg.sender][day / 256] |= (1 << (day % 256));

        return true;

    }



    function getCheckIn(uint timestamp) public view returns (bool) {

        uint day = timestamp / 1 days;

        return checkins[msg.sender][day / 256] & ( 1 << (day % 256)) != 0;

    }

}