/**
 *Submitted for verification at Etherscan.io on 2020-03-09
*/

pragma solidity 0.4.25;

// File: contracts/wallet_trading_limiter/interfaces/ITradingClasses.sol

/**
 * @title Trading Classes Interface.
 */
interface ITradingClasses {
    /**
     * @dev Get the complete info of a class.
     * @param _id The id of the class.
     * @return complete info of a class.
     */
    function getInfo(uint256 _id) external view returns (uint256, uint256, uint256);

    /**
     * @dev Get the action-role of a class.
     * @param _id The id of the class.
     * @return The action-role of the class.
     */
    function getActionRole(uint256 _id) external view returns (uint256);

    /**
     * @dev Get the sell limit of a class.
     * @param _id The id of the class.
     * @return The sell limit of the class.
     */
    function getSellLimit(uint256 _id) external view returns (uint256);

    /**
     * @dev Get the buy limit of a class.
     * @param _id The id of the class.
     * @return The buy limit of the class.
     */
    function getBuyLimit(uint256 _id) external view returns (uint256);
}

// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Ownable.sol

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

/**
 * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1
 */

/**
 * @title Trading Classes.
 */
contract TradingClasses is ITradingClasses, Claimable {
    string public constant VERSION = "2.0.0";

    uint256[] public array;

    struct Info {
        uint256 actionRole;
        uint256 buyLimit;
        uint256 sellLimit;
        uint256 index;
    }

    mapping(uint256 => Info) public table;

    enum Action {None, Insert, Update, Remove}

    event ActionCompleted(uint256 _id, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, Action _action);

    /**
     * @dev Get the complete info of a class.
     * @param _id The id of the class.
     * @return complete info of a class.
     */
    function getInfo(uint256 _id) external view returns (uint256, uint256, uint256) {
        Info memory info = table[_id];
        return (info.buyLimit, info.sellLimit, info.actionRole);
    }


    /**
     * @dev Get the action-role of a class.
     * @param _id The id of the class.
     * @return The action-role of the class.
     */
    function getActionRole(uint256 _id) external view returns (uint256) {
        return table[_id].actionRole;
    }

    /**
     * @dev Get the sell limit of a class.
     * @param _id The id of the class.
     * @return The sell limit of the class.
     */
    function getSellLimit(uint256 _id) external view returns (uint256) {
        return table[_id].sellLimit;
    }

    /**
     * @dev Get the buy limit of a class.
     * @param _id The id of the class.
     * @return The buy limit of the class.
     */
    function getBuyLimit(uint256 _id) external view returns (uint256) {
        return table[_id].buyLimit;
    }

    /**
     * @dev Set the limit of a class.
     * @param _id The id of the class.
     * @param _actionRole The action-role of the class.
     * @param _buyLimit The buy limit of the class.
     * @param _sellLimit The sell limit of the class.
     */
    function set(uint256 _id, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit) external onlyOwner {
        Info storage info = table[_id];
        Action action = getAction(info, _actionRole, _buyLimit, _sellLimit);
        if (action == Action.Insert) {
            info.index = array.length;
            info.actionRole = _actionRole;
            info.buyLimit = _buyLimit;
            info.sellLimit = _sellLimit;
            array.push(_id);
        }
        else if (action == Action.Update) {
            info.actionRole = _actionRole;
            info.buyLimit = _buyLimit;
            info.sellLimit = _sellLimit;
        }
        else if (action == Action.Remove) {
            // at this point we know that array.length > info.index >= 0
            uint256 last = array[array.length - 1];
            // will never underflow
            table[last].index = info.index;
            array[info.index] = last;
            array.length -= 1;
            // will never underflow
            delete table[_id];
        }
        emit ActionCompleted(_id, _actionRole, _buyLimit, _sellLimit, action);
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
     * @param _currentInfo The old limit.
     * @param _newActionRole The new action-role.
     * @param _newBuyLimit The new buy limit.
     * @param _newSellLimit The new sell limit.
     * @return The required action.
     */
    function getAction(Info _currentInfo, uint256 _newActionRole, uint256 _newBuyLimit, uint256 _newSellLimit) private pure returns (Action) {
        bool currentExists = _currentInfo.buyLimit != 0 || _currentInfo.sellLimit != 0 || _currentInfo.actionRole != 0;
        bool isRemoveRequired = _newActionRole == 0 && _newBuyLimit == 0 && _newSellLimit == 0;
        bool isUpdateRequired = _currentInfo.actionRole != _newActionRole || _currentInfo.buyLimit != _newBuyLimit || _currentInfo.sellLimit != _newSellLimit;
        if (!currentExists && !isRemoveRequired)
            return Action.Insert;
        if (currentExists && isRemoveRequired)
            return Action.Remove;
        if (isUpdateRequired)
            return Action.Update;
        return Action.None;
    }
}