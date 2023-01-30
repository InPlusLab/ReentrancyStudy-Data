/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

// File: contracts/token/interfaces/IERC20Token.sol

pragma solidity 0.4.26;

/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {this;}
    function symbol() public view returns (string) {this;}
    function decimals() public view returns (uint8) {this;}
    function totalSupply() public view returns (uint256) {this;}
    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}
    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

// File: contracts/utility/interfaces/IWhitelist.sol

pragma solidity 0.4.26;

/*
    Whitelist interface
*/
contract IWhitelist {
    function isWhitelisted(address _address) public view returns (bool);
}

// File: contracts/converter/interfaces/IBancorConverter.sol

pragma solidity 0.4.26;



/*
    Bancor Converter interface
*/
contract IBancorConverter {
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256);
    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256);
    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256);
    function conversionWhitelist() public view returns (IWhitelist) {this;}
    function conversionFee() public view returns (uint32) {this;}
    function reserves(address _address) public view returns (uint256, uint32, bool, bool, bool) {_address; this;}
    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);
    function reserveTokens(uint256 _index) public view returns (IERC20Token) {_index; this;}

    // deprecated, backward compatibility
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
    function connectorTokens(uint256 _index) public view returns (IERC20Token);
    function connectorTokenCount() public view returns (uint16);
}

// File: contracts/converter/interfaces/IBancorConverterUpgrader.sol

pragma solidity 0.4.26;


/*
    Bancor Converter Upgrader interface
*/
contract IBancorConverterUpgrader {
    function upgrade(bytes32 _version) public;
    function upgrade(uint16 _version) public;
}

// File: contracts/utility/interfaces/IOwned.sol

pragma solidity 0.4.26;

/*
    Owned contract interface
*/
contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function owner() public view returns (address) {this;}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

// File: contracts/token/interfaces/ISmartToken.sol

pragma solidity 0.4.26;



/*
    Smart Token interface
*/
contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}

// File: contracts/utility/interfaces/IContractRegistry.sol

pragma solidity 0.4.26;

/*
    Contract Registry interface
*/
contract IContractRegistry {
    function addressOf(bytes32 _contractName) public view returns (address);

    // deprecated, backward compatibility
    function getAddress(bytes32 _contractName) public view returns (address);
}

// File: contracts/converter/interfaces/IBancorConverterFactory.sol

pragma solidity 0.4.26;




/*
    Bancor Converter Factory interface
*/
contract IBancorConverterFactory {
    function createConverter(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _reserveToken,
        uint32 _reserveRatio
    )
    public returns (address);
}

// File: contracts/utility/Owned.sol

pragma solidity 0.4.26;


/**
  * @dev Provides support and utilities for contract ownership
*/
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    /**
      * @dev triggered when the owner is updated
      * 
      * @param _prevOwner previous owner
      * @param _newOwner  new owner
    */
    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
      * @dev initializes a new Owned instance
    */
    constructor() public {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    /**
      * @dev allows transferring the contract ownership
      * the new owner still needs to accept the transfer
      * can only be called by the contract owner
      * 
      * @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
      * @dev used by a new owner to accept an ownership transfer
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// File: contracts/utility/Utils.sol

pragma solidity 0.4.26;

/**
  * @dev Utilities & Common Modifiers
*/
contract Utils {
    /**
      * constructor
    */
    constructor() public {
    }

    // verifies that an amount is greater than zero
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

}

// File: contracts/utility/ContractRegistryClient.sol

pragma solidity 0.4.26;




/**
  * @dev Base contract for ContractRegistry clients
*/
contract ContractRegistryClient is Owned, Utils {
    bytes32 internal constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 internal constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";
    bytes32 internal constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";

    IContractRegistry public registry;      // address of the current contract-registry
    IContractRegistry public prevRegistry;  // address of the previous contract-registry
    bool public onlyOwnerCanUpdateRegistry; // only an owner can update the contract-registry

    /**
      * @dev verifies that the caller is mapped to the given contract name
      * 
      * @param _contractName    contract name
    */
    modifier only(bytes32 _contractName) {
        require(msg.sender == addressOf(_contractName));
        _;
    }

    /**
      * @dev initializes a new ContractRegistryClient instance
      * 
      * @param  _registry   address of a contract-registry contract
    */
    constructor(IContractRegistry _registry) internal validAddress(_registry) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    /**
      * @dev updates to the new contract-registry
     */
    function updateRegistry() public {
        // verify that this function is permitted
        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry);

        // get the new contract-registry
        address newRegistry = addressOf(CONTRACT_REGISTRY);

        // verify that the new contract-registry is different and not zero
        require(newRegistry != address(registry) && newRegistry != address(0));

        // verify that the new contract-registry is pointing to a non-zero contract-registry
        require(IContractRegistry(newRegistry).addressOf(CONTRACT_REGISTRY) != address(0));

        // save a backup of the current contract-registry before replacing it
        prevRegistry = registry;

        // replace the current contract-registry with the new contract-registry
        registry = IContractRegistry(newRegistry);
    }

    /**
      * @dev restores the previous contract-registry
    */
    function restoreRegistry() public ownerOnly {
        // restore the previous contract-registry
        registry = prevRegistry;
    }

    /**
      * @dev restricts the permission to update the contract-registry
      * 
      * @param _onlyOwnerCanUpdateRegistry  indicates whether or not permission is restricted to owner only
    */
    function restrictRegistryUpdate(bool _onlyOwnerCanUpdateRegistry) ownerOnly public {
        // change the permission to update the contract-registry
        onlyOwnerCanUpdateRegistry = _onlyOwnerCanUpdateRegistry;
    }

    /**
      * @dev returns the address associated with the given contract name
      * 
      * @param _contractName    contract name
      * 
      * @return contract address
    */
    function addressOf(bytes32 _contractName) internal view returns (address) {
        return registry.addressOf(_contractName);
    }
}

// File: contracts/utility/interfaces/IContractFeatures.sol

pragma solidity 0.4.26;

/*
    Contract Features interface
*/
contract IContractFeatures {
    function isSupported(address _contract, uint256 _features) public view returns (bool);
    function enableFeatures(uint256 _features, bool _enable) public;
}

// File: contracts/FeatureIds.sol

pragma solidity 0.4.26;

/**
  * @dev Id definitions for bancor contract features
  * 
  * Can be used to query the ContractFeatures contract to check whether a certain feature is supported by a contract
*/
contract FeatureIds {
    // converter features
    uint256 public constant CONVERTER_CONVERSION_WHITELIST = 1 << 0;
}

// File: contracts/converter/BancorConverterUpgrader.sol

pragma solidity 0.4.26;








/*
    Bancor converter dedicated interface
*/
contract IBancorConverterExtended is IBancorConverter, IOwned {
    function token() public view returns (ISmartToken) {this;}
    function maxConversionFee() public view returns (uint32) {this;}
    function conversionFee() public view returns (uint32) {this;}
    function connectorTokenCount() public view returns (uint16);
    function reserveTokenCount() public view returns (uint16);
    function connectorTokens(uint256 _index) public view returns (IERC20Token) {_index; this;}
    function reserveTokens(uint256 _index) public view returns (IERC20Token) {_index; this;}
    function setConversionWhitelist(IWhitelist _whitelist) public;
    function transferTokenOwnership(address _newOwner) public;
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
    function acceptTokenOwnership() public;
    function setConversionFee(uint32 _conversionFee) public;
    function addConnector(IERC20Token _token, uint32 _weight, bool _enableVirtualBalance) public;
    function updateConnector(IERC20Token _connectorToken, uint32 _weight, bool _enableVirtualBalance, uint256 _virtualBalance) public;
}

/**
  * @dev Bancor Converter Upgrader
  * 
  * The Bancor converter upgrader contract allows upgrading an older Bancor converter contract (0.4 and up)
  * to the latest version.
  * To begin the upgrade process, simply execute the 'upgrade' function.
  * At the end of the process, the ownership of the newly upgraded converter will be transferred
  * back to the original owner and the original owner will need to execute the 'acceptOwnership' function.
  * 
  * The address of the new converter is available in the ConverterUpgrade event.
  * 
  * Note that for older converters that don't yet have the 'upgrade' function, ownership should first
  * be transferred manually to the ConverterUpgrader contract using the 'transferOwnership' function
  * and then the upgrader 'upgrade' function should be executed directly.
*/
contract BancorConverterUpgrader is IBancorConverterUpgrader, ContractRegistryClient, FeatureIds {
    string public version = '0.3';

    /**
      * @dev triggered when the contract accept a converter ownership
      * 
      * @param _converter   converter address
      * @param _owner       new owner - local upgrader address
    */
    event ConverterOwned(address indexed _converter, address indexed _owner);

    /**
      * @dev triggered when the upgrading process is done
      * 
      * @param _oldConverter    old converter address
      * @param _newConverter    new converter address
    */
    event ConverterUpgrade(address indexed _oldConverter, address indexed _newConverter);

    /**
      * @dev initializes a new BancorConverterUpgrader instance
      * 
      * @param _registry    address of a contract registry contract
    */
    constructor(IContractRegistry _registry) ContractRegistryClient(_registry) public {
    }

    /**
      * @dev upgrades an old converter to the latest version
      * will throw if ownership wasn't transferred to the upgrader before calling this function.
      * ownership of the new converter will be transferred back to the original owner.
      * fires the ConverterUpgrade event upon success.
      * can only be called by a converter
      * 
      * @param _version old converter version
    */
    function upgrade(bytes32 _version) public {
        upgradeOld(IBancorConverter(msg.sender), _version);
    }

    /**
      * @dev upgrades an old converter to the latest version
      * will throw if ownership wasn't transferred to the upgrader before calling this function.
      * ownership of the new converter will be transferred back to the original owner.
      * fires the ConverterUpgrade event upon success.
      * can only be called by a converter
      * 
      * @param _version old converter version
    */
    function upgrade(uint16 _version) public {
        upgradeOld(IBancorConverter(msg.sender), bytes32(_version));
    }

    /**
      * @dev upgrades an old converter to the latest version
      * will throw if ownership wasn't transferred to the upgrader before calling this function.
      * ownership of the new converter will be transferred back to the original owner.
      * fires the ConverterUpgrade event upon success.
      * 
      * @param _converter   old converter contract address
      * @param _version     old converter version
    */
    function upgradeOld(IBancorConverter _converter, bytes32 _version) public {
        _version;
        IBancorConverterExtended converter = IBancorConverterExtended(_converter);
        address prevOwner = converter.owner();
        acceptConverterOwnership(converter);
        IBancorConverterExtended newConverter = createConverter(converter);
        copyConnectors(converter, newConverter);
        copyConversionFee(converter, newConverter);
        transferConnectorsBalances(converter, newConverter);                
        ISmartToken token = converter.token();

        if (token.owner() == address(converter)) {
            converter.transferTokenOwnership(newConverter);
            newConverter.acceptTokenOwnership();
        }

        converter.transferOwnership(prevOwner);
        newConverter.transferOwnership(prevOwner);

        emit ConverterUpgrade(address(converter), address(newConverter));
    }

    /**
      * @dev the first step when upgrading a converter is to transfer the ownership to the local contract.
      * the upgrader contract then needs to accept the ownership transfer before initiating
      * the upgrade process.
      * fires the ConverterOwned event upon success
      * 
      * @param _oldConverter       converter to accept ownership of
    */
    function acceptConverterOwnership(IBancorConverterExtended _oldConverter) private {
        _oldConverter.acceptOwnership();
        emit ConverterOwned(_oldConverter, this);
    }

    /**
      * @dev creates a new converter with same basic data as the original old converter
      * the newly created converter will have no connectors at this step.
      * 
      * @param _oldConverter    old converter contract address
      * 
      * @return the new converter  new converter contract address
    */
    function createConverter(IBancorConverterExtended _oldConverter) private returns(IBancorConverterExtended) {
        IWhitelist whitelist;
        ISmartToken token = _oldConverter.token();
        uint32 maxConversionFee = _oldConverter.maxConversionFee();

        IBancorConverterFactory converterFactory = IBancorConverterFactory(addressOf(BANCOR_CONVERTER_FACTORY));
        address converterAddress = converterFactory.createConverter(
            token,
            registry,
            maxConversionFee,
            IERC20Token(address(0)),
            0
        );

        IBancorConverterExtended converter = IBancorConverterExtended(converterAddress);
        converter.acceptOwnership();

        // get the contract features address from the registry
        IContractFeatures features = IContractFeatures(addressOf(CONTRACT_FEATURES));

        if (features.isSupported(_oldConverter, FeatureIds.CONVERTER_CONVERSION_WHITELIST)) {
            whitelist = _oldConverter.conversionWhitelist();
            if (whitelist != address(0))
                converter.setConversionWhitelist(whitelist);
        }

        return converter;
    }

    /**
      * @dev copies the connectors from the old converter to the new one.
      * note that this will not work for an unlimited number of connectors due to block gas limit constraints.
      * 
      * @param _oldConverter    old converter contract address
      * @param _newConverter    new converter contract address
    */
    function copyConnectors(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter)
        private
    {
        uint256 virtualBalance;
        uint32 weight;
        bool isVirtualBalanceEnabled;
        uint16 connectorTokenCount = _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < connectorTokenCount; i++) {
            address connectorAddress = _oldConverter.connectorTokens(i);
            (virtualBalance, weight, isVirtualBalanceEnabled, , ) = _oldConverter.connectors(connectorAddress);

            IERC20Token connectorToken = IERC20Token(connectorAddress);
            _newConverter.addConnector(connectorToken, weight, isVirtualBalanceEnabled);

            if (isVirtualBalanceEnabled)
                _newConverter.updateConnector(connectorToken, weight, isVirtualBalanceEnabled, virtualBalance);
        }
    }

    /**
      * @dev copies the conversion fee from the old converter to the new one
      * 
      * @param _oldConverter    old converter contract address
      * @param _newConverter    new converter contract address
    */
    function copyConversionFee(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter) private {
        uint32 conversionFee = _oldConverter.conversionFee();
        _newConverter.setConversionFee(conversionFee);
    }

    /**
      * @dev transfers the balance of each connector in the old converter to the new one.
      * note that the function assumes that the new converter already has the exact same number of
      * also, this will not work for an unlimited number of connectors due to block gas limit constraints.
      * 
      * @param _oldConverter    old converter contract address
      * @param _newConverter    new converter contract address
    */
    function transferConnectorsBalances(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter)
        private
    {
        uint256 connectorBalance;
        uint16 connectorTokenCount = _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < connectorTokenCount; i++) {
            address connectorAddress = _oldConverter.connectorTokens(i);
            IERC20Token connector = IERC20Token(connectorAddress);
            connectorBalance = connector.balanceOf(_oldConverter);
            _oldConverter.withdrawTokens(connector, address(_newConverter), connectorBalance);
        }
    }
}