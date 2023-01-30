/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

pragma solidity 0.4.26;

// File: contracts/ContractIds.sol

/**
  * @dev Id definitions for bancor contracts
  * 
  * Can be used in conjunction with the contract registry to get contract addresses
*/
contract ContractIds {
    // generic
    bytes32 public constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 public constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 public constant NON_STANDARD_TOKEN_REGISTRY = "NonStandardTokenRegistry";

    // bancor logic
    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 public constant BANCOR_FORMULA = "BancorFormula";
    bytes32 public constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 public constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 public constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";

    // BNT core
    bytes32 public constant BNT_TOKEN = "BNTToken";
    bytes32 public constant BNT_CONVERTER = "BNTConverter";

    // BancorX
    bytes32 public constant BANCOR_X = "BancorX";
    bytes32 public constant BANCOR_X_UPGRADER = "BancorXUpgrader";
}

// File: contracts/utility/Utils.sol

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

/*
    Contract Registry interface
*/
contract IContractRegistry {
    function addressOf(bytes32 _contractName) public view returns (address);

    // deprecated, backward compatibility
    function getAddress(bytes32 _contractName) public view returns (address);
}

// File: contracts/converter/interfaces/IBancorConverterRegistry.sol

contract IBancorConverterRegistry {
    function tokens(uint256 _index) public view returns (address) { _index; }
    function tokenCount() public view returns (uint256);
    function converterCount(address _token) public view returns (uint256);
    function converterAddress(address _token, uint32 _index) public view returns (address);
    function latestConverterAddress(address _token) public view returns (address);
    function tokenAddress(address _converter) public view returns (address);
}

// File: contracts/token/interfaces/IERC20Token.sol

/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {}
    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}
    function totalSupply() public view returns (uint256) {}
    function balanceOf(address _owner) public view returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

// File: contracts/utility/interfaces/IWhitelist.sol

/*
    Whitelist interface
*/
contract IWhitelist {
    function isWhitelisted(address _address) public view returns (bool);
}

// File: contracts/converter/interfaces/IBancorConverter.sol

/*
    Bancor Converter interface
*/
contract IBancorConverter {
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256);
    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256);
    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256);
    function conversionWhitelist() public view returns (IWhitelist) {}
    function conversionFee() public view returns (uint32) {}
    function reserves(address _address) public view returns (uint256, uint32, bool, bool, bool) { _address; }
    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);
    function reserveTokens(uint256 _index) public view returns (IERC20Token) { _index; }
    // deprecated, backward compatibility
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
    function connectorTokens(uint256 _index) public view returns (IERC20Token);
}

// File: contracts/utility/interfaces/IOwned.sol

/*
    Owned contract interface
*/
contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function owner() public view returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

// File: contracts/token/interfaces/ISmartToken.sol

/*
    Smart Token interface
*/
contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}

// File: contracts/token/interfaces/ISmartTokenController.sol

/*
    Smart Token Controller interface
*/
contract ISmartTokenController {
    function claimTokens(address _from, uint256 _amount) public;
    function token() public view returns (ISmartToken) {}
}

// File: contracts/BancorNetworkPathFinder.sol

/**
  * @dev The BancorNetworkPathFinder contract allows for retrieving the conversion path between any pair of tokens in the Bancor Network.
  * This conversion path can then be used in various functions on the BancorNetwork contract (see this contract for more details on conversion paths).
*/
contract BancorNetworkPathFinder is ContractIds, Utils {
    IContractRegistry public contractRegistry;
    address public anchorToken;

    bytes4 private constant CONNECTOR_TOKEN_COUNT = bytes4(uint256(keccak256("connectorTokenCount()") >> (256 - 4 * 8)));
    bytes4 private constant RESERVE_TOKEN_COUNT   = bytes4(uint256(keccak256("reserveTokenCount()"  ) >> (256 - 4 * 8)));

    /**
      * @dev initializes a new BancorNetworkPathFinder instance
      * 
      * @param _contractRegistry    address of a contract registry contract
    */
    constructor(IContractRegistry _contractRegistry) public validAddress(_contractRegistry) {
        contractRegistry = _contractRegistry;
        anchorToken = contractRegistry.addressOf(BNT_TOKEN);
    }

    /**
      * @dev updates the anchor token to point to the most recent BNT token deployed
      * 
      * Note that this function needs to be called only when the BNT token has been redeployed
    */
    function updateAnchorToken() external {
        address bntToken = contractRegistry.addressOf(BNT_TOKEN);
        require(anchorToken != bntToken);
        anchorToken = bntToken;
    }

    /**
      * @dev retrieves the conversion path between a given pair of tokens in the Bancor Network
      * 
      * @param _sourceToken         address of the source token
      * @param _targetToken         address of the target token
      * @param _converterRegistries array of converter registries depicting some part of the network
      * 
      * @return path from the source token to the target token
    */
    function get(address _sourceToken, address _targetToken, IBancorConverterRegistry[] memory _converterRegistries) public view returns (address[] memory) {
        assert(anchorToken == contractRegistry.addressOf(BNT_TOKEN));
        address[] memory sourcePath = getPath(_sourceToken, _converterRegistries);
        address[] memory targetPath = getPath(_targetToken, _converterRegistries);
        return getShortestPath(sourcePath, targetPath);
    }

    /**
      * @dev retrieves the conversion path between a given token and the anchor token
      * 
      * @param _token               address of the token
      * @param _converterRegistries array of converter registries depicting some part of the network
      * 
      * @return path from the input token to the anchor token
    */
    function getPath(address _token, IBancorConverterRegistry[] memory _converterRegistries) private view returns (address[] memory) {
        if (_token == anchorToken) {
            address[] memory initialPath = new address[](1);
            initialPath[0] = _token;
            return initialPath;
        }

        uint256 tokenCount;
        uint256 i;
        address token;
        address[] memory path;

        for (uint256 n = 0; n < _converterRegistries.length; n++) {
            IBancorConverter converter = IBancorConverter(_converterRegistries[n].latestConverterAddress(_token));
            tokenCount = getTokenCount(converter, CONNECTOR_TOKEN_COUNT);
            for (i = 0; i < tokenCount; i++) {
                token = converter.connectorTokens(i);
                if (token != _token) {
                    path = getPath(token, _converterRegistries);
                    if (path.length > 0)
                        return getNewPath(path, _token, converter);
                }
            }
            tokenCount = getTokenCount(converter, RESERVE_TOKEN_COUNT);
            for (i = 0; i < tokenCount; i++) {
                token = converter.reserveTokens(i);
                if (token != _token) {
                    path = getPath(token, _converterRegistries);
                    if (path.length > 0)
                        return getNewPath(path, _token, converter);
                }
            }
        }

        return new address[](0);
    }

    /**
      * @dev invokes a function which takes no input arguments and returns a 'uint256' value
      * 
      * @param _dest            address of the contract which implements the function
      * @param _funcSelector    first 4 bytes in the hash of the function signature
      * 
      * @return value returned from calling the input function on the input contract
    */
    function getTokenCount(address _dest, bytes4 _funcSelector) private view returns (uint256) {
        uint256[1] memory ret;
        bytes memory data = abi.encodeWithSelector(_funcSelector);

        assembly {
            pop(staticcall(
                gas,           // gas remaining
                _dest,         // destination address
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data),   // input length (loaded from the first 32 bytes in the `data` array)
                ret,           // output buffer
                32             // output length
            ))
        }

        return ret[0];
    }

    /**
      * @dev prepends two tokens to the beginning of a given path
      * 
      * @param _token       address of the first token
      * @param _converter   converter of the second token
      * 
      * @return extended path
    */
    function getNewPath(address[] memory _path, address _token, IBancorConverter _converter) private view returns (address[] memory) {
        address[] memory newPath = new address[](2 + _path.length);
        newPath[0] = _token;
        newPath[1] = ISmartTokenController(_converter).token();
        for (uint256 k = 0; k < _path.length; k++)
            newPath[2 + k] = _path[k];
        return newPath;
    }

    /**
      * @dev merges two paths with a common suffix into one
      * 
      * @param _sourcePath  address of the source path
      * @param _targetPath  address of the target path
      * 
      * @return merged path
    */
    function getShortestPath(address[] memory _sourcePath, address[] memory _targetPath) private pure returns (address[] memory) {
        if (_sourcePath.length > 0 && _targetPath.length > 0) {
            uint256 i = _sourcePath.length;
            uint256 j = _targetPath.length;
            while (i > 0 && j > 0 && _sourcePath[i - 1] == _targetPath[j - 1]) {
                i--;
                j--;
            }

            address[] memory path = new address[](i + j + 1);
            for (uint256 m = 0; m <= i; m++)
                path[m] = _sourcePath[m];
            for (uint256 n = j; n > 0; n--)
                path[path.length - n] = _targetPath[n - 1];
            return path;
        }

        return new address[](0);
    }
}