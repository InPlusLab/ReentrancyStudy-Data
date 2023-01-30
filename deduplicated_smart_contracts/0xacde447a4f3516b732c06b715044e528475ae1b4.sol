/**
 *Submitted for verification at Etherscan.io on 2020-03-09
*/

pragma solidity 0.4.25;

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

// File: contracts/utils/Adminable.sol

/**
 * @title Adminable.
 */
contract Adminable is Claimable {
    address[] public adminArray;

    struct AdminInfo {
        bool valid;
        uint256 index;
    }

    mapping(address => AdminInfo) public adminTable;

    event AdminAccepted(address indexed _admin);
    event AdminRejected(address indexed _admin);

    /**
     * @dev Reverts if called by any account other than one of the administrators.
     */
    modifier onlyAdmin() {
        require(adminTable[msg.sender].valid, "caller is illegal");
        _;
    }

    /**
     * @dev Accept a new administrator.
     * @param _admin The administrator's address.
     */
    function accept(address _admin) external onlyOwner {
        require(_admin != address(0), "administrator is illegal");
        AdminInfo storage adminInfo = adminTable[_admin];
        require(!adminInfo.valid, "administrator is already accepted");
        adminInfo.valid = true;
        adminInfo.index = adminArray.length;
        adminArray.push(_admin);
        emit AdminAccepted(_admin);
    }

    /**
     * @dev Reject an existing administrator.
     * @param _admin The administrator's address.
     */
    function reject(address _admin) external onlyOwner {
        AdminInfo storage adminInfo = adminTable[_admin];
        require(adminArray.length > adminInfo.index, "administrator is already rejected");
        require(_admin == adminArray[adminInfo.index], "administrator is already rejected");
        // at this point we know that adminArray.length > adminInfo.index >= 0
        address lastAdmin = adminArray[adminArray.length - 1]; // will never underflow
        adminTable[lastAdmin].index = adminInfo.index;
        adminArray[adminInfo.index] = lastAdmin;
        adminArray.length -= 1; // will never underflow
        delete adminTable[_admin];
        emit AdminRejected(_admin);
    }

    /**
     * @dev Get an array of all the administrators.
     * @return An array of all the administrators.
     */
    function getAdminArray() external view returns (address[] memory) {
        return adminArray;
    }

    /**
     * @dev Get the total number of administrators.
     * @return The total number of administrators.
     */
    function getAdminCount() external view returns (uint256) {
        return adminArray.length;
    }
}

// File: contracts/authorization/interfaces/IAuthorizationDataSource.sol

/**
 * @title Authorization Data Source Interface.
 */
interface IAuthorizationDataSource {
    /**
     * @dev Get the authorized action-role of a wallet.
     * @param _wallet The address of the wallet.
     * @return The authorized action-role of the wallet.
     */
    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);

    /**
     * @dev Get the authorized action-role and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The authorized action-role and class of the wallet.
     */
    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256);

    /**
     * @dev Get all the trade-limits and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The trade-limits and trade-class of the wallet.
     */
    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256);


    /**
     * @dev Get the buy trade-limit and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The buy trade-limit and trade-class of the wallet.
     */
    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);

    /**
     * @dev Get the sell trade-limit and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The sell trade-limit and trade-class of the wallet.
     */
    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);
}

// File: contracts/authorization/AuthorizationDataSource.sol

/**
 * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1
 */

/**
 * @title Authorization Data Source.
 */
contract AuthorizationDataSource is IAuthorizationDataSource, Adminable {
    string public constant VERSION = "2.0.0";

    uint256 public walletCount;

    struct WalletInfo {
        uint256 sequenceNum;
        bool isWhitelisted;
        uint256 actionRole;
        uint256 buyLimit;
        uint256 sellLimit;
        uint256 tradeClass;
    }

    mapping(address => WalletInfo) public walletTable;

    event WalletSaved(address indexed _wallet);
    event WalletDeleted(address indexed _wallet);
    event WalletNotSaved(address indexed _wallet);
    event WalletNotDeleted(address indexed _wallet);

    /**
     * @dev Get the authorized action-role of a wallet.
     * @param _wallet The address of the wallet.
     * @return The authorized action-role of the wallet.
     */
    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256) {
        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.isWhitelisted, walletInfo.actionRole);
    }

    /**
     * @dev Get the authorized action-role and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The authorized action-role and class of the wallet.
     */
    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256) {
        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.isWhitelisted, walletInfo.actionRole, walletInfo.tradeClass);
    }

    /**
     * @dev Get all the trade-limits and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The trade-limits and trade-class of the wallet.
     */
    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256) {
        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.buyLimit, walletInfo.sellLimit, walletInfo.tradeClass);
    }

    /**
     * @dev Get the buy trade-limit and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The buy trade-limit and trade-class of the wallet.
     */
    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256) {
        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.buyLimit, walletInfo.tradeClass);
    }

    /**
     * @dev Get the sell trade-limit and trade-class of a wallet.
     * @param _wallet The address of the wallet.
     * @return The sell trade-limit and trade-class of the wallet.
     */
    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256) {
        WalletInfo storage walletInfo = walletTable[_wallet];
        return (walletInfo.sellLimit, walletInfo.tradeClass);
    }

    /**
     * @dev Insert or update a wallet.
     * @param _wallet The address of the wallet.
     * @param _sequenceNum The sequence-number of the operation.
     * @param _isWhitelisted The authorization of the wallet.
     * @param _actionRole The action-role of the wallet.
     * @param _buyLimit The buy trade-limit of the wallet.
     * @param _sellLimit The sell trade-limit of the wallet.
     * @param _tradeClass The trade-class of the wallet.
     */
    function upsertOne(address _wallet, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) external onlyAdmin {
        _upsert(_wallet, _sequenceNum, _isWhitelisted, _actionRole, _buyLimit, _sellLimit, _tradeClass);
    }

    /**
     * @dev Remove a wallet.
     * @param _wallet The address of the wallet.
     */
    function removeOne(address _wallet) external onlyAdmin {
        _remove(_wallet);
    }

    /**
     * @dev Insert or update a list of wallets with the same params.
     * @param _wallets The addresses of the wallets.
     * @param _sequenceNum The sequence-number of the operation.
     * @param _isWhitelisted The authorization of all the wallets.
     * @param _actionRole The action-role of all the the wallets.
     * @param _buyLimit The buy trade-limit of all the wallets.
     * @param _sellLimit The sell trade-limit of all the wallets.
     * @param _tradeClass The trade-class of all the wallets.
     */
    function upsertAll(address[] _wallets, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) external onlyAdmin {
        for (uint256 i = 0; i < _wallets.length; i++)
            _upsert(_wallets[i], _sequenceNum, _isWhitelisted, _actionRole, _buyLimit, _sellLimit, _tradeClass);
    }

    /**
     * @dev Remove a list of wallets.
     * @param _wallets The addresses of the wallets.
     */
    function removeAll(address[] _wallets) external onlyAdmin {
        for (uint256 i = 0; i < _wallets.length; i++)
            _remove(_wallets[i]);
    }

    /**
     * @dev Insert or update a wallet.
     * @param _wallet The address of the wallet.
     * @param _sequenceNum The sequence-number of the operation.
     * @param _isWhitelisted The authorization of the wallet.
     * @param _actionRole The action-role of the wallet.
     * @param _buyLimit The buy trade-limit of the wallet.
     * @param _sellLimit The sell trade-limit of the wallet.
     * @param _tradeClass The trade-class of the wallet.
     */
    function _upsert(address _wallet, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) private {
        require(_wallet != address(0), "wallet is illegal");
        WalletInfo storage walletInfo = walletTable[_wallet];
        if (walletInfo.sequenceNum < _sequenceNum) {
            if (walletInfo.sequenceNum == 0) // increment the wallet-count only when a new wallet is inserted
                walletCount += 1; // will never overflow because the number of different wallets = 2^160 < 2^256
            walletInfo.sequenceNum = _sequenceNum;
            walletInfo.isWhitelisted = _isWhitelisted;
            walletInfo.actionRole = _actionRole;
            walletInfo.buyLimit = _buyLimit;
            walletInfo.sellLimit = _sellLimit;
            walletInfo.tradeClass = _tradeClass;
            emit WalletSaved(_wallet);
        }
        else {
            emit WalletNotSaved(_wallet);
        }
    }

    /**
     * @dev Remove a wallet.
     * @param _wallet The address of the wallet.
     */
    function _remove(address _wallet) private {
        require(_wallet != address(0), "wallet is illegal");
        WalletInfo storage walletInfo = walletTable[_wallet];
        if (walletInfo.sequenceNum > 0) { // decrement the wallet-count only when an existing wallet is removed
            walletCount -= 1; // will never underflow because every decrement follows a corresponding increment
            delete walletTable[_wallet];
            emit WalletDeleted(_wallet);
        }
        else {
            emit WalletNotDeleted(_wallet);
        }
    }
}