/**
 *Submitted for verification at Etherscan.io on 2020-03-05
*/

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

// File: contracts/converter/interfaces/IBancorConverterRegistry.sol

pragma solidity 0.4.26;


interface IBancorConverterRegistry {
    function addConverter(IBancorConverter _converter) external;
    function removeConverter(IBancorConverter _converter) external;
    function getSmartTokenCount() external view returns (uint);
    function getSmartTokens() external view returns (address[]);
    function getSmartToken(uint _index) external view returns (address);
    function isSmartToken(address _value) external view returns (bool);
    function getLiquidityPoolCount() external view returns (uint);
    function getLiquidityPools() external view returns (address[]);
    function getLiquidityPool(uint _index) external view returns (address);
    function isLiquidityPool(address _value) external view returns (bool);
    function getConvertibleTokenCount() external view returns (uint);
    function getConvertibleTokens() external view returns (address[]);
    function getConvertibleToken(uint _index) external view returns (address);
    function isConvertibleToken(address _value) external view returns (bool);
    function getConvertibleTokenSmartTokenCount(address _convertibleToken) external view returns (uint);
    function getConvertibleTokenSmartTokens(address _convertibleToken) external view returns (address[]);
    function getConvertibleTokenSmartToken(address _convertibleToken, uint _index) external view returns (address);
    function isConvertibleTokenSmartToken(address _convertibleToken, address _value) external view returns (bool);
}

// File: contracts/converter/interfaces/IBancorConverterRegistryData.sol

pragma solidity 0.4.26;

interface IBancorConverterRegistryData {
    function addSmartToken(address _smartToken) external;
    function removeSmartToken(address _smartToken) external;
    function addLiquidityPool(address _liquidityPool) external;
    function removeLiquidityPool(address _liquidityPool) external;
    function addConvertibleToken(address _convertibleToken, address _smartToken) external;
    function removeConvertibleToken(address _convertibleToken, address _smartToken) external;
    function getSmartTokenCount() external view returns (uint);
    function getSmartTokens() external view returns (address[]);
    function getSmartToken(uint _index) external view returns (address);
    function isSmartToken(address _value) external view returns (bool);
    function getLiquidityPoolCount() external view returns (uint);
    function getLiquidityPools() external view returns (address[]);
    function getLiquidityPool(uint _index) external view returns (address);
    function isLiquidityPool(address _value) external view returns (bool);
    function getConvertibleTokenCount() external view returns (uint);
    function getConvertibleTokens() external view returns (address[]);
    function getConvertibleToken(uint _index) external view returns (address);
    function isConvertibleToken(address _value) external view returns (bool);
    function getConvertibleTokenSmartTokenCount(address _convertibleToken) external view returns (uint);
    function getConvertibleTokenSmartTokens(address _convertibleToken) external view returns (address[]);
    function getConvertibleTokenSmartToken(address _convertibleToken, uint _index) external view returns (address);
    function isConvertibleTokenSmartToken(address _convertibleToken, address _value) external view returns (bool);
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

// File: contracts/token/interfaces/ISmartTokenController.sol

pragma solidity 0.4.26;


/*
    Smart Token Controller interface
*/
contract ISmartTokenController {
    function claimTokens(address _from, uint256 _amount) public;
    function token() public view returns (ISmartToken) {this;}
}

// File: contracts/converter/BancorConverterRegistry.sol

pragma solidity 0.4.26;






/**
  * @dev The BancorConverterRegistry maintains a list of all active converters in the Bancor Network.
  *
  * Since converters can be upgraded and thus their address can change, the registry actually keeps smart tokens internally and not the converters themselves.
  * The active converter for each smart token can be easily accessed by querying the smart token owner.
  *
  * The registry exposes 3 differnet lists that can be accessed and iterated, based on the use-case of the caller:
  * - Smart tokens - can be used to get all the latest / historical data in the network
  * - Liquidity pools - can be used to get all liquidity pools for funding, liquidation etc.
  * - Convertible tokens - can be used to get all tokens that can be converted in the network (excluding pool
  *   tokens), and for each one - all smart tokens that hold it in their reserves
  *
  *
  * The contract fires events whenever one of the primitives is added to or removed from the registry
  *
  * The contract is upgradable.
*/
contract BancorConverterRegistry is IBancorConverterRegistry, ContractRegistryClient {
    /**
      * @dev triggered when a smart token is added to the registry
      * 
      * @param _smartToken smart token
    */
    event SmartTokenAdded(address indexed _smartToken);

    /**
      * @dev triggered when a smart token is removed from the registry
      * 
      * @param _smartToken smart token
    */
    event SmartTokenRemoved(address indexed _smartToken);

    /**
      * @dev triggered when a liquidity pool is added to the registry
      * 
      * @param _liquidityPool liquidity pool
    */
    event LiquidityPoolAdded(address indexed _liquidityPool);

    /**
      * @dev triggered when a liquidity pool is removed from the registry
      * 
      * @param _liquidityPool liquidity pool
    */
    event LiquidityPoolRemoved(address indexed _liquidityPool);

    /**
      * @dev triggered when a convertible token is added to the registry
      * 
      * @param _convertibleToken convertible token
      * @param _smartToken associated smart token
    */
    event ConvertibleTokenAdded(address indexed _convertibleToken, address indexed _smartToken);

    /**
      * @dev triggered when a convertible token is removed from the registry
      * 
      * @param _convertibleToken convertible token
      * @param _smartToken associated smart token
    */
    event ConvertibleTokenRemoved(address indexed _convertibleToken, address indexed _smartToken);

    /**
      * @dev initializes a new BancorConverterRegistry instance
      * 
      * @param _registry address of a contract registry contract
    */
    constructor(IContractRegistry _registry) ContractRegistryClient(_registry) public {
    }

    /**
      * @dev adds a converter to the registry
      * anyone can add a converter to the registry, as long as the converter is active and valid
      * note that a liquidity pool converter can only be added if there's no existing pool with the same reserve configuration
      * 
      * @param _converter converter
    */
    function addConverter(IBancorConverter _converter) external {
        // validate input
        require(isConverterValid(_converter) && getLiquidityPoolByReserveConfig(_converter) == ISmartToken(0));

        IBancorConverterRegistryData converterRegistryData = IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA));
        ISmartToken token = ISmartTokenController(_converter).token();
        uint reserveTokenCount = _converter.connectorTokenCount();

        // add the smart token
        addSmartToken(converterRegistryData, token);
        if (reserveTokenCount > 1)
            addLiquidityPool(converterRegistryData, token);
        else
            addConvertibleToken(converterRegistryData, token, token);

        // add all reserve tokens
        for (uint i = 0; i < reserveTokenCount; i++)
            addConvertibleToken(converterRegistryData, _converter.connectorTokens(i), token);
    }

    /**
      * @dev removes a converter from the registry
      * anyone can remove invalid or inactive converters from the registry
      * note that the owner can also remove valid converters
      * 
      * @param _converter converter
    */
    function removeConverter(IBancorConverter _converter) external {
      // validate input
        require(msg.sender == owner || !isConverterValid(_converter));

        IBancorConverterRegistryData converterRegistryData = IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA));
        ISmartToken token = ISmartTokenController(_converter).token();
        uint reserveTokenCount = _converter.connectorTokenCount();

        // remove the smart token
        removeSmartToken(converterRegistryData, token);
        if (reserveTokenCount > 1)
            removeLiquidityPool(converterRegistryData, token);
        else
            removeConvertibleToken(converterRegistryData, token, token);

        // remove all reserve tokens
        for (uint i = 0; i < reserveTokenCount; i++)
            removeConvertibleToken(converterRegistryData, _converter.connectorTokens(i), token);
    }

    /**
      * @dev returns the number of smart tokens in the registry
      * 
      * @return number of smart tokens
    */
    function getSmartTokenCount() external view returns (uint) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getSmartTokenCount();
    }

    /**
      * @dev returns the list of smart tokens in the registry
      * 
      * @return list of smart tokens
    */
    function getSmartTokens() external view returns (address[]) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getSmartTokens();
    }

    /**
      * @dev returns the smart token at a given index
      * 
      * @param _index index
      * @return smart token at the given index
    */
    function getSmartToken(uint _index) external view returns (address) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getSmartToken(_index);
    }

    /**
      * @dev checks whether or not a given value is a smart token
      * 
      * @param _value value
      * @return true if the given value is a smart token, false if not
    */
    function isSmartToken(address _value) external view returns (bool) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).isSmartToken(_value);
    }

    /**
      * @dev returns the number of liquidity pools in the registry
      * 
      * @return number of liquidity pools
    */
    function getLiquidityPoolCount() external view returns (uint) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getLiquidityPoolCount();
    }

    /**
      * @dev returns the list of liquidity pools in the registry
      * 
      * @return list of liquidity pools
    */
    function getLiquidityPools() external view returns (address[]) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getLiquidityPools();
    }

    /**
      * @dev returns the liquidity pool at a given index
      * 
      * @param _index index
      * @return liquidity pool at the given index
    */
    function getLiquidityPool(uint _index) external view returns (address) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getLiquidityPool(_index);
    }

    /**
      * @dev checks whether or not a given value is a liquidity pool
      * 
      * @param _value value
      * @return true if the given value is a liquidity pool, false if not
    */
    function isLiquidityPool(address _value) external view returns (bool) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).isLiquidityPool(_value);
    }

    /**
      * @dev returns the number of convertible tokens in the registry
      * 
      * @return number of convertible tokens
    */
    function getConvertibleTokenCount() external view returns (uint) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getConvertibleTokenCount();
    }

    /**
      * @dev returns the list of convertible tokens in the registry
      * 
      * @return list of convertible tokens
    */
    function getConvertibleTokens() external view returns (address[]) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getConvertibleTokens();
    }

    /**
      * @dev returns the convertible token at a given index
      * 
      * @param _index index
      * @return convertible token at the given index
    */
    function getConvertibleToken(uint _index) external view returns (address) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getConvertibleToken(_index);
    }

    /**
      * @dev checks whether or not a given value is a convertible token
      * 
      * @param _value value
      * @return true if the given value is a convertible token, false if not
    */
    function isConvertibleToken(address _value) external view returns (bool) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).isConvertibleToken(_value);
    }

    /**
      * @dev returns the number of smart tokens associated with a given convertible token
      * 
      * @param _convertibleToken convertible token
      * @return number of smart tokens associated with the given convertible token
    */
    function getConvertibleTokenSmartTokenCount(address _convertibleToken) external view returns (uint) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getConvertibleTokenSmartTokenCount(_convertibleToken);
    }

    /**
      * @dev returns the list of smart tokens associated with a given convertible token
      * 
      * @param _convertibleToken convertible token
      * @return list of smart tokens associated with the given convertible token
    */
    function getConvertibleTokenSmartTokens(address _convertibleToken) external view returns (address[]) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getConvertibleTokenSmartTokens(_convertibleToken);
    }

    /**
      * @dev returns the smart token associated with a given convertible token at a given index
      * 
      * @param _index index
      * @return smart token associated with the given convertible token at the given index
    */
    function getConvertibleTokenSmartToken(address _convertibleToken, uint _index) external view returns (address) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).getConvertibleTokenSmartToken(_convertibleToken, _index);
    }

    /**
      * @dev checks whether or not a given value is a smart token of a given convertible token
      * 
      * @param _convertibleToken convertible token
      * @param _value value
      * @return true if the given value is a smart token of the given convertible token, false if not
    */
    function isConvertibleTokenSmartToken(address _convertibleToken, address _value) external view returns (bool) {
        return IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA)).isConvertibleTokenSmartToken(_convertibleToken, _value);
    }

    /**
      * @dev returns a list of converters for a given list of smart tokens
      * this is a utility function that can be used to reduce the number of calls to the contract
      * 
      * @param _smartTokens list of smart tokens
      * @return list of converters
    */
    function getConvertersBySmartTokens(address[] _smartTokens) external view returns (address[]) {
        address[] memory converters = new address[](_smartTokens.length);

        for (uint i = 0; i < _smartTokens.length; i++)
            converters[i] = ISmartToken(_smartTokens[i]).owner();

        return converters;
    }

    /**
      * @dev checks whether or not a given converter is valid
      * 
      * @param _converter converter
      * @return true if the given converter is valid, false if not
    */
    function isConverterValid(IBancorConverter _converter) public view returns (bool) {
        // verify the the smart token has a supply and that the converter is active
        ISmartToken token = ISmartTokenController(_converter).token();
        if (token.totalSupply() == 0 || token.owner() != address(_converter))
            return false;

        // verify that the converter holds balance in each of its reserves
        uint reserveTokenCount = _converter.connectorTokenCount();
        for (uint i = 0; i < reserveTokenCount; i++) {
            if (_converter.connectorTokens(i).balanceOf(_converter) == 0)
                return false;
        }

        return true;
    }

    /**
      * @dev searches for a liquidity pool with specific reserve tokens/ratios
      * 
      * @param _converter converter with specific reserve tokens/ratios
      * @return the liquidity pool, or zero if no such liquidity pool exists
    */
    function getLiquidityPoolByReserveConfig(IBancorConverter _converter) public view returns (ISmartToken) {
        uint reserveTokenCount = _converter.connectorTokenCount();

        // verify that the converter holds a liquidity pool
        if (reserveTokenCount > 1) {
            address[] memory reserveTokens = new address[](reserveTokenCount);
            uint[] memory reserveRatios = new uint[](reserveTokenCount);

            // get the reserve-configuration of the converter
            for (uint n = 0; n < reserveTokenCount; n++) {
                IERC20Token reserveToken = _converter.connectorTokens(n);
                reserveTokens[n] = reserveToken;
                reserveRatios[n] = getReserveRatio(_converter, reserveToken);
            }

            // get the smart tokens of the least frequent token (optimization)
            address[] memory convertibleTokenSmartTokens = getLeastFrequentTokenSmartTokens(reserveTokens);

            // search for a converter with an identical reserve-configuration
            for (uint i = 0; i < convertibleTokenSmartTokens.length; i++) {
                ISmartToken smartToken = ISmartToken(convertibleTokenSmartTokens[i]);
                IBancorConverter converter = IBancorConverter(smartToken.owner());
                if (isConverterReserveConfigEqual(converter, reserveTokens, reserveRatios))
                    return smartToken;
            }
        }

        return ISmartToken(0);
    }

    /**
      * @dev adds a smart token to the registry
      * 
      * @param _smartToken smart token
    */
    function addSmartToken(IBancorConverterRegistryData _converterRegistryData, address _smartToken) internal {
        _converterRegistryData.addSmartToken(_smartToken);
        emit SmartTokenAdded(_smartToken);
    }

    /**
      * @dev removes a smart token from the registry
      * 
      * @param _smartToken smart token
    */
    function removeSmartToken(IBancorConverterRegistryData _converterRegistryData, address _smartToken) internal {
        _converterRegistryData.removeSmartToken(_smartToken);
        emit SmartTokenRemoved(_smartToken);
    }

    /**
      * @dev adds a liquidity pool to the registry
      * 
      * @param _liquidityPool liquidity pool
    */
    function addLiquidityPool(IBancorConverterRegistryData _converterRegistryData, address _liquidityPool) internal {
        _converterRegistryData.addLiquidityPool(_liquidityPool);
        emit LiquidityPoolAdded(_liquidityPool);
    }

    /**
      * @dev removes a liquidity pool from the registry
      * 
      * @param _liquidityPool liquidity pool
    */
    function removeLiquidityPool(IBancorConverterRegistryData _converterRegistryData, address _liquidityPool) internal {
        _converterRegistryData.removeLiquidityPool(_liquidityPool);
        emit LiquidityPoolRemoved(_liquidityPool);
    }

    /**
      * @dev adds a convertible token to the registry
      * 
      * @param _convertibleToken convertible token
      * @param _smartToken associated smart token
    */
    function addConvertibleToken(IBancorConverterRegistryData _converterRegistryData, address _convertibleToken, address _smartToken) internal {
        _converterRegistryData.addConvertibleToken(_convertibleToken, _smartToken);
        emit ConvertibleTokenAdded(_convertibleToken, _smartToken);
    }

    /**
      * @dev removes a convertible token from the registry
      * 
      * @param _convertibleToken convertible token
      * @param _smartToken associated smart token
    */
    function removeConvertibleToken(IBancorConverterRegistryData _converterRegistryData, address _convertibleToken, address _smartToken) internal {
        _converterRegistryData.removeConvertibleToken(_convertibleToken, _smartToken);
        emit ConvertibleTokenRemoved(_convertibleToken, _smartToken);
    }

    function getLeastFrequentTokenSmartTokens(address[] memory _tokens) private view returns (address[] memory) {
        IBancorConverterRegistryData bancorConverterRegistryData = IBancorConverterRegistryData(addressOf(BANCOR_CONVERTER_REGISTRY_DATA));

        // find the token that has the smallest number of smart tokens
        uint minSmartTokenCount = bancorConverterRegistryData.getConvertibleTokenSmartTokenCount(_tokens[0]);
        address[] memory smartTokens = bancorConverterRegistryData.getConvertibleTokenSmartTokens(_tokens[0]);
        for (uint i = 1; i < _tokens.length; i++) {
            uint convertibleTokenSmartTokenCount = bancorConverterRegistryData.getConvertibleTokenSmartTokenCount(_tokens[i]);
            if (minSmartTokenCount > convertibleTokenSmartTokenCount) {
                minSmartTokenCount = convertibleTokenSmartTokenCount;
                smartTokens = bancorConverterRegistryData.getConvertibleTokenSmartTokens(_tokens[i]);
            }
        }
        return smartTokens;
    }

    function isConverterReserveConfigEqual(IBancorConverter _converter, address[] memory _reserveTokens, uint[] memory _reserveRatios) private view returns (bool) {
        if (_reserveTokens.length != _converter.connectorTokenCount())
            return false;

        for (uint i = 0; i < _reserveTokens.length; i++) {
            if (_reserveRatios[i] != getReserveRatio(_converter, _reserveTokens[i]))
                return false;
        }

        return true;
    }

    bytes4 private constant CONNECTORS_FUNC_SELECTOR = bytes4(uint256(keccak256("connectors(address)") >> (256 - 4 * 8)));

    function getReserveRatio(address _converter, address _reserveToken) private view returns (uint256) {
        uint256[2] memory ret;
        bytes memory data = abi.encodeWithSelector(CONNECTORS_FUNC_SELECTOR, _reserveToken);

        assembly {
            let success := staticcall(
                gas,           // gas remaining
                _converter,    // destination address
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data),   // input length (loaded from the first 32 bytes in the `data` array)
                ret,           // output buffer
                64             // output length
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        return ret[1];
    }
}