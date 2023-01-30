/**
 *Submitted for verification at Etherscan.io on 2019-10-26
*/

// File: contracts/openzeppelin-contracts/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/openzeppelin-contracts/contracts/access/Roles.sol

pragma solidity ^0.5.0;

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

// File: contracts/openzeppelin-contracts/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;



contract PauserRole is Context {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {
        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(_msgSender());
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

// File: contracts/openzeppelin-contracts/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context, PauserRole {
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
        emit Paused(_msgSender());
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: contracts/openzeppelin-contracts/contracts/access/roles/WhitelistAdminRole.sol

pragma solidity ^0.5.0;



/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole is Context {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(_msgSender()), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: contracts/SmartFly.sol

pragma solidity ^0.5.0;



contract SmartFly is WhitelistAdminRole, Pausable {

  mapping(bytes32 => Insurance[]) private insuranceList;

  enum InsuranceStatus {
    NONE,
    Active,
    FlightOnTime,
    CustomerCompensationPaid,
    CustomerCompensationWaiting
  }


  struct Insurance {
    bytes32          insuranceId;
    uint256          customerId;
    uint256          plannedDepartureTime;
    uint256          actualDepartureTime;
    InsuranceStatus  status;
  }


  event InsuranceCreation(
    bytes32         indexed flightId,
    bytes32         indexed insuranceId,
    uint256         indexed customerId,
    uint256                 plannedDepartureTime,
    uint256                 actualDepartureTime,
    InsuranceStatus         status
  );


  event InsuranceUpdate(
    bytes32         indexed flightId,
    bytes32                 insuranceId,
    uint256         indexed customerId,
    uint256                 plannedDepartureTime,
    uint256                 actualDepartureTime,
    InsuranceStatus indexed status
  );

  function getInsurancesCount (bytes32 flightId) public view onlyWhitelistAdmin whenNotPaused
    returns (uint256)
  {
    return insuranceList[flightId].length;
  }


  function addNewInsurance(
    bytes32          flightId,
    bytes32          insuranceId,
    uint256          customerId,
    uint256          plannedDepartureTime,
    uint256          actualDepartureTime
  ) public onlyWhitelistAdmin whenNotPaused {

    _addNewInsurance(flightId, insuranceId, customerId, plannedDepartureTime, actualDepartureTime, InsuranceStatus.Active);
  }


  function _addNewInsurance (
    bytes32          flightId,
    bytes32          insuranceId,
    uint256          customerId,
    uint256          plannedDepartureTime,
    uint256          actualDepartureTime,
    InsuranceStatus  status
  ) internal onlyWhitelistAdmin whenNotPaused {

    Insurance memory newInsurance;
    newInsurance.insuranceId = insuranceId;
    newInsurance.customerId = customerId;
    newInsurance.plannedDepartureTime = plannedDepartureTime;
    newInsurance.actualDepartureTime = actualDepartureTime;
    newInsurance.status = status;

    insuranceList[flightId].push(newInsurance);
    emit InsuranceCreation(flightId, insuranceId, customerId, plannedDepartureTime, actualDepartureTime, status);
  }


  function getInsuranceDetails(bytes32 flightId, uint index) public view onlyWhitelistAdmin whenNotPaused
    returns(
      bytes32          insuranceId,
      uint256          customerId,
      uint256          plannedDepartureTime,
      uint256          actualDepartureTime,
      InsuranceStatus  status)
  {

    require(insuranceList[flightId].length > 0 && (insuranceList[flightId].length - 1) >= index, "There's no Insurance on this flightId.");

    insuranceId = insuranceList[flightId][index].insuranceId;
    customerId = insuranceList[flightId][index].customerId;
    plannedDepartureTime = insuranceList[flightId][index].plannedDepartureTime;
    actualDepartureTime = insuranceList[flightId][index].actualDepartureTime;
    status = insuranceList[flightId][index].status;
  }


  function updateInsurance(
    bytes32 flightId,
    uint    index,
    bytes32 insuranceId,
    uint256 customerId,
    uint256 plannedDepartureTime,
    uint256 actualDepartureTime,
    InsuranceStatus status
  ) public onlyWhitelistAdmin whenNotPaused
    returns (bool)
  {
    require(insuranceList[flightId].length > 0 && (insuranceList[flightId].length - 1) >= index, "There's no Insurance on this flightId.");

    insuranceList[flightId][index].insuranceId = insuranceId;
    insuranceList[flightId][index].customerId = customerId;
    insuranceList[flightId][index].plannedDepartureTime = plannedDepartureTime;
    insuranceList[flightId][index].actualDepartureTime = actualDepartureTime;
    insuranceList[flightId][index].status = status;

    emit InsuranceUpdate(flightId, insuranceId, customerId, plannedDepartureTime, actualDepartureTime, status);

    return true;
  }

}