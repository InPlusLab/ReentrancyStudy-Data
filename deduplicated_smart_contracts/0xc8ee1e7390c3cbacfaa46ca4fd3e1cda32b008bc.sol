/**
 *Submitted for verification at Etherscan.io on 2019-09-05
*/

// File: contracts/wallet_trading_limiter/interfaces/ITradingClasses.sol

pragma solidity 0.4.25;

/**
 * @title Trading Classes Interface.
 */
interface ITradingClasses {
    /**
     * @dev Get the limit of a class.
     * @param _id The id of the class.
     * @return The limit of the class.
     */
    function getLimit(uint256 _id) external view returns (uint256);
}

// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Claimable.sol

pragma solidity ^0.4.24;



/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: contracts/wallet_trading_limiter/TradingClasses.sol

pragma solidity 0.4.25;



/**
 * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1
 */

/**
 * @title Trading Classes.
 */
contract TradingClasses is ITradingClasses, Claimable {
    string public constant VERSION = "1.0.0";

    uint256[] public array;

    struct Info {
        uint256 limit;
        uint256 index;
    }

    mapping(uint256 => Info) public table;

    enum Action {None, Insert, Update, Remove}

    event ActionCompleted(uint256 _id, uint256 _limit, Action _action);

    /**
     * @dev Get the limit of a class.
     * @param _id The id of the class.
     * @return The limit of the class.
     */
    function getLimit(uint256 _id) external view returns (uint256) {
        return table[_id].limit;
    }

    /**
     * @dev Set the limit of a class.
     * @param _id The id of the class.
     * @param _limit The limit of the class.
     */
    function setLimit(uint256 _id, uint256 _limit) external onlyOwner {
        Info storage info = table[_id];
        Action action = getAction(info.limit, _limit);
        if (action == Action.Insert) {
            info.index = array.length;
            info.limit = _limit;
            array.push(_id);
        }
        else if (action == Action.Update) {
            info.limit = _limit;
        }
        else if (action == Action.Remove) {
            // at this point we know that array.length > info.index >= 0
            uint256 last = array[array.length - 1]; // will never underflow
            table[last].index = info.index;
            array[info.index] = last;
            array.length -= 1; // will never underflow
            delete table[_id];
        }
        emit ActionCompleted(_id, _limit, action);
    }

    /**
     * @dev Get an array of all the classes.
     * @return An array of all the classes.
     */
    function getArray() external view returns (uint256[] memory) {
        return array;
    }

    /**
     * @dev Get the total number of classes.
     * @return The total number of classes.
     */
    function getCount() external view returns (uint256) {
        return array.length;
    }

    /**
     * @dev Get the required action.
     * @param _prev The old limit.
     * @param _next The new limit.
     * @return The required action.
     */
    function getAction(uint256 _prev, uint256 _next) private pure returns (Action) {
        if (_prev == 0 && _next != 0)
            return Action.Insert;
        if (_prev != 0 && _next == 0)
            return Action.Remove;
        if (_prev != _next)
            return Action.Update;
        return Action.None;
    }
}