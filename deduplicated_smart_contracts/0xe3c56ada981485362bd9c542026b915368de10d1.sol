/**
 *Submitted for verification at Etherscan.io on 2020-03-09
*/

pragma solidity 0.4.25;

// File: contracts/saga/interfaces/ISGAAuthorizationManager.sol

/**
 * @title SGA Authorization Manager Interface.
 */
interface ISGAAuthorizationManager {
    /**
     * @dev Determine whether or not a user is authorized to buy SGA.
     * @param _sender The address of the user.
     * @return Authorization status.
     */
    function isAuthorizedToBuy(address _sender) external view returns (bool);

    /**
     * @dev Determine whether or not a user is authorized to sell SGA.
     * @param _sender The address of the user.
     * @return Authorization status.
     */
    function isAuthorizedToSell(address _sender) external view returns (bool);

    /**
     * @dev Determine whether or not a user is authorized to transfer SGA to another user.
     * @param _sender The address of the source user.
     * @param _target The address of the target user.
     * @return Authorization status.
     */
    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool);

    /**
     * @dev Determine whether or not a user is authorized to transfer SGA from one user to another user.
     * @param _sender The address of the custodian user.
     * @param _source The address of the source user.
     * @param _target The address of the target user.
     * @return Authorization status.
     */
    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool);

    /**
     * @dev Determine whether or not a user is authorized for public operation.
     * @param _sender The address of the user.
     * @return Authorization status.
     */
    function isAuthorizedForPublicOperation(address _sender) external view returns (bool);
}

// File: contracts/contract_address_locator/interfaces/IContractAddressLocator.sol

/**
 * @title Contract Address Locator Interface.
 */
interface IContractAddressLocator {
    /**
     * @dev Get the contract address mapped to a given identifier.
     * @param _identifier The identifier.
     * @return The contract address.
     */
    function getContractAddress(bytes32 _identifier) external view returns (address);

    /**
     * @dev Determine whether or not a contract address relates to one of the identifiers.
     * @param _contractAddress The contract address to look for.
     * @param _identifiers The identifiers.
     * @return A boolean indicating if the contract address relates to one of the identifiers.
     */
    function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);
}

// File: contracts/contract_address_locator/ContractAddressLocatorHolder.sol

/**
 * @title Contract Address Locator Holder.
 * @dev Hold a contract address locator, which maps a unique identifier to every contract address in the system.
 * @dev Any contract which inherits from this contract can retrieve the address of any contract in the system.
 * @dev Thus, any contract can remain "oblivious" to the replacement of any other contract in the system.
 * @dev In addition to that, any function in any contract can be restricted to a specific caller.
 */
contract ContractAddressLocatorHolder {
    bytes32 internal constant _IAuthorizationDataSource_ = "IAuthorizationDataSource";
    bytes32 internal constant _ISGNConversionManager_    = "ISGNConversionManager"      ;
    bytes32 internal constant _IModelDataSource_         = "IModelDataSource"        ;
    bytes32 internal constant _IPaymentHandler_          = "IPaymentHandler"            ;
    bytes32 internal constant _IPaymentManager_          = "IPaymentManager"            ;
    bytes32 internal constant _IPaymentQueue_            = "IPaymentQueue"              ;
    bytes32 internal constant _IReconciliationAdjuster_  = "IReconciliationAdjuster"      ;
    bytes32 internal constant _IIntervalIterator_        = "IIntervalIterator"       ;
    bytes32 internal constant _IMintHandler_             = "IMintHandler"            ;
    bytes32 internal constant _IMintListener_            = "IMintListener"           ;
    bytes32 internal constant _IMintManager_             = "IMintManager"            ;
    bytes32 internal constant _IPriceBandCalculator_     = "IPriceBandCalculator"       ;
    bytes32 internal constant _IModelCalculator_         = "IModelCalculator"        ;
    bytes32 internal constant _IRedButton_               = "IRedButton"              ;
    bytes32 internal constant _IReserveManager_          = "IReserveManager"         ;
    bytes32 internal constant _ISagaExchanger_           = "ISagaExchanger"          ;
    bytes32 internal constant _IMonetaryModel_               = "IMonetaryModel"              ;
    bytes32 internal constant _IMonetaryModelState_          = "IMonetaryModelState"         ;
    bytes32 internal constant _ISGAAuthorizationManager_ = "ISGAAuthorizationManager";
    bytes32 internal constant _ISGAToken_                = "ISGAToken"               ;
    bytes32 internal constant _ISGATokenManager_         = "ISGATokenManager"        ;
    bytes32 internal constant _ISGNAuthorizationManager_ = "ISGNAuthorizationManager";
    bytes32 internal constant _ISGNToken_                = "ISGNToken"               ;
    bytes32 internal constant _ISGNTokenManager_         = "ISGNTokenManager"        ;
    bytes32 internal constant _IMintingPointTimersManager_             = "IMintingPointTimersManager"            ;
    bytes32 internal constant _ITradingClasses_          = "ITradingClasses"         ;
    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = "IWalletsTLValueConverter"       ;
    bytes32 internal constant _BuyWalletsTradingDataSource_       = "BuyWalletsTradingDataSource"      ;
    bytes32 internal constant _SellWalletsTradingDataSource_       = "SellWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _BuyWalletsTradingLimiter_SGATokenManager_          = "BuyWalletsTLSGATokenManager"         ;
    bytes32 internal constant _SellWalletsTradingLimiter_SGATokenManager_          = "SellWalletsTLSGATokenManager"         ;
    bytes32 internal constant _IETHConverter_             = "IETHConverter"   ;
    bytes32 internal constant _ITransactionLimiter_      = "ITransactionLimiter"     ;
    bytes32 internal constant _ITransactionManager_      = "ITransactionManager"     ;
    bytes32 internal constant _IRateApprover_      = "IRateApprover"     ;

    IContractAddressLocator private contractAddressLocator;

    /**
     * @dev Create the contract.
     * @param _contractAddressLocator The contract address locator.
     */
    constructor(IContractAddressLocator _contractAddressLocator) internal {
        require(_contractAddressLocator != address(0), "locator is illegal");
        contractAddressLocator = _contractAddressLocator;
    }

    /**
     * @dev Get the contract address locator.
     * @return The contract address locator.
     */
    function getContractAddressLocator() external view returns (IContractAddressLocator) {
        return contractAddressLocator;
    }

    /**
     * @dev Get the contract address mapped to a given identifier.
     * @param _identifier The identifier.
     * @return The contract address.
     */
    function getContractAddress(bytes32 _identifier) internal view returns (address) {
        return contractAddressLocator.getContractAddress(_identifier);
    }



    /**
     * @dev Determine whether or not the sender relates to one of the identifiers.
     * @param _identifiers The identifiers.
     * @return A boolean indicating if the sender relates to one of the identifiers.
     */
    function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {
        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);
    }

    /**
     * @dev Verify that the caller is mapped to a given identifier.
     * @param _identifier The identifier.
     */
    modifier only(bytes32 _identifier) {
        require(msg.sender == getContractAddress(_identifier), "caller is illegal");
        _;
    }

}

// File: contracts/authorization/AuthorizationActionRoles.sol

/**
 * @title Authorization Action Roles.
 */
library AuthorizationActionRoles {
    string public constant VERSION = "1.1.0";

    enum Flag {
        BuySga         ,
        SellSga        ,
        SellSgn        ,
        ReceiveSgn     ,
        TransferSgn    ,
        TransferFromSgn
    }

    function isAuthorizedToBuySga         (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.BuySga         );}
    function isAuthorizedToSellSga        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSga        );}
    function isAuthorizedToSellSgn        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSgn        );}
    function isAuthorizedToReceiveSgn     (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.ReceiveSgn     );}
    function isAuthorizedToTransferSgn    (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferSgn    );}
    function isAuthorizedToTransferFromSgn(uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferFromSgn);}
    function isAuthorized(uint256 _flags, Flag _flag) private pure returns (bool) {return ((_flags >> uint256(_flag)) & 1) == 1;}
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

// File: contracts/saga/SGAAuthorizationManager.sol

/**
 * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1
 */

/**
 * @title SGA Authorization Manager.
 */
contract SGAAuthorizationManager is ISGAAuthorizationManager, ContractAddressLocatorHolder {
    string public constant VERSION = "1.1.0";

    using AuthorizationActionRoles for uint256;

    /**
     * @dev Create the contract.
     * @param _contractAddressLocator The contract address locator.
     */
    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    /**
     * @dev Return the contract which implements the IAuthorizationDataSource interface.
     */
    function getAuthorizationDataSource() public view returns (IAuthorizationDataSource) {
        return IAuthorizationDataSource(getContractAddress(_IAuthorizationDataSource_));
    }

    /**
    * @dev Return the contract which implements the ITradingClasses interface.
    */
    function getTradingClasses() public view returns (ITradingClasses) {
        return ITradingClasses(getContractAddress(_ITradingClasses_));
    }

    /**
     * @dev Determine whether or not a user is authorized to buy SGA.
     * @param _sender The address of the user.
     * @return Authorization status.
     */
    function isAuthorizedToBuy(address _sender) external view returns (bool) {
        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 tradeClassId) = getAuthorizationDataSource().getAuthorizedActionRoleAndClass(_sender);

        return senderIsWhitelisted && getActionRole(senderActionRole, tradeClassId).isAuthorizedToBuySga();
    }

    /**
     * @dev Determine whether or not a user is authorized to sell SGA.
     * @param _sender The address of the user.
     * @return Authorization status.
     */
    function isAuthorizedToSell(address _sender) external view returns (bool) {
        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 tradeClassId) = getAuthorizationDataSource().getAuthorizedActionRoleAndClass(_sender);

        return senderIsWhitelisted && getActionRole(senderActionRole, tradeClassId).isAuthorizedToSellSga();
    }

    /**
     * @dev User is always authorized to transfer SGA to another user.
     * @param _sender The address of the source user.
     * @param _target The address of the target user.
     * @return Authorization status.
     */
    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool) {
        _sender;
        _target;
        return true;
    }

    /**
     * @dev User is always authorized to transfer SGA from one user to another user.
     * @param _sender The address of the custodian user.
     * @param _source The address of the source user.
     * @param _target The address of the target user.
     * @return Authorization status.
     */
    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool) {
        _sender;
        _source;
        _target;
        return true;
    }

    /**
     * @dev Determine whether or not a user is authorized for public operation.
     * @param _sender The address of the user.
     * @return Authorization status.
     */
    function isAuthorizedForPublicOperation(address _sender) external view returns (bool) {
        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();
        (bool senderIsWhitelisted,) = authorizationDataSource.getAuthorizedActionRole(_sender);
        return senderIsWhitelisted;
    }

    /**
     * @dev Get the relevant action-role.
     * @return The relevant action-role.
     */
    function getActionRole(uint256 _actionRole, uint256 _tradeClassId) private view returns (uint256) {
        return  _actionRole > 0 ? _actionRole : getTradingClasses().getActionRole(_tradeClassId);
    }
}