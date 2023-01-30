/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

// File: contracts/utils/LoggingErrors.sol

pragma solidity ^0.4.11;

/**
 * @title Log Various Error Types
 * @author Adam Lemmon <adam@oraclize.it>
 * @dev Inherit this contract and your may now log errors easily
 * To support various error types, params, etc.
 */
contract LoggingErrors {
  /**
  * Events
  */
  event LogErrorString(string errorString);

  /**
  * Error cases
  */

  /**
   * @dev Default error to simply log the error message and return
   * @param _errorMessage The error message to log
   * @return ALWAYS false
   */
  function error(string _errorMessage) internal returns(bool) {
    emit LogErrorString(_errorMessage);
    return false;
  }
}

// File: contracts/wallet/WalletConnector.sol

pragma solidity ^0.4.15;


/**
 * @title Wallet Connector
 * @dev Connect the wallet contract to the correct Wallet Logic version
 */
contract WalletConnector is LoggingErrors {
  /**
   * Storage
   */
  address public owner_;
  address public latestLogic_;
  uint256 public latestVersion_;
  mapping(uint256 => address) public logicVersions_;
  uint256 public birthBlock_;

  /**
   * Events
   */
  event LogLogicVersionAdded(uint256 version);
  event LogLogicVersionRemoved(uint256 version);

  /**
   * @dev Constructor to set the latest logic address
   * @param _latestVersion Latest version of the wallet logic
   * @param _latestLogic Latest address of the wallet logic contract
   */
  function WalletConnector (
    uint256 _latestVersion,
    address _latestLogic
  ) public {
    owner_ = msg.sender;
    latestLogic_ = _latestLogic;
    latestVersion_ = _latestVersion;
    logicVersions_[_latestVersion] = _latestLogic;
    birthBlock_ = block.number;
  }

  /**
   * Add a new version of the logic contract
   * @param _version The version to be associated with the new contract.
   * @param _logic New logic contract.
   * @return Success of the transaction.
   */
  function addLogicVersion (
    uint256 _version,
    address _logic
  ) external
    returns(bool)
  {
    if (msg.sender != owner_)
      return error('msg.sender != owner, WalletConnector.addLogicVersion()');

    if (logicVersions_[_version] != 0)
      return error('Version already exists, WalletConnector.addLogicVersion()');

    // Update latest if this is the latest version
    if (_version > latestVersion_) {
      latestLogic_ = _logic;
      latestVersion_ = _version;
    }

    logicVersions_[_version] = _logic;
    LogLogicVersionAdded(_version);

    return true;
  }

  /**
   * @dev Remove a version. Cannot remove the latest version.
   * @param  _version The version to remove.
   */
  function removeLogicVersion(uint256 _version) external {
    require(msg.sender == owner_);
    require(_version != latestVersion_);
    delete logicVersions_[_version];
    LogLogicVersionRemoved(_version);
  }

  /**
   * Constants
   */

  /**
   * Called from user wallets in order to upgrade their logic.
   * @param _version The version to upgrade to. NOTE pass in 0 to upgrade to latest.
   * @return The address of the logic contract to upgrade to.
   */
  function getLogic(uint256 _version)
    external
    constant
    returns(address)
  {
    if (_version == 0)
      return latestLogic_;
    else
      return logicVersions_[_version];
  }
}