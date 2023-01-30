/**
 *Submitted for verification at Etherscan.io on 2020-04-24
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

// File: contracts/converter/interfaces/IBancorFormula.sol

pragma solidity 0.4.26;

/*
    Bancor Formula interface
*/
contract IBancorFormula {
    function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public view returns (uint256);
    function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public view returns (uint256);
    function calculateCrossReserveReturn(uint256 _fromReserveBalance, uint32 _fromReserveRatio, uint256 _toReserveBalance, uint32 _toReserveRatio, uint256 _amount) public view returns (uint256);
    function calculateFundCost(uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount) public view returns (uint256);
    function calculateLiquidateReturn(uint256 _supply, uint256 _reserveBalance, uint32 _totalRatio, uint256 _amount) public view returns (uint256);
    // deprecated, backward compatibility
    function calculateCrossConnectorReturn(uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount) public view returns (uint256);
}

// File: contracts/IBancorNetwork.sol

pragma solidity 0.4.26;


/*
    Bancor Network interface
*/
contract IBancorNetwork {
    function convert2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);

    function claimAndConvert2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public returns (uint256);

    function convertFor2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);

    function claimAndConvertFor2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public returns (uint256);

    // deprecated, backward compatibility
    function convert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public payable returns (uint256);

    // deprecated, backward compatibility
    function claimAndConvert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public returns (uint256);

    // deprecated, backward compatibility
    function convertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public payable returns (uint256);

    // deprecated, backward compatibility
    function claimAndConvertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public returns (uint256);

    // deprecated, backward compatibility
    function convertForPrioritized4(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256[] memory _signature,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);

    // deprecated, backward compatibility
    function convertForPrioritized3(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _customVal,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);

    // deprecated, backward compatibility
    function convertForPrioritized2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);

    // deprecated, backward compatibility
    function convertForPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);
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

// File: contracts/utility/SafeMath.sol

pragma solidity 0.4.26;

/**
  * @dev Library for basic math operations with overflow/underflow protection
*/
library SafeMath {
    /**
      * @dev returns the sum of _x and _y, reverts if the calculation overflows
      *
      * @param _x   value 1
      * @param _y   value 2
      *
      * @return sum
    */
    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        require(z >= _x);
        return z;
    }

    /**
      * @dev returns the difference of _x minus _y, reverts if the calculation underflows
      *
      * @param _x   minuend
      * @param _y   subtrahend
      *
      * @return difference
    */
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_x >= _y);
        return _x - _y;
    }

    /**
      * @dev returns the product of multiplying _x by _y, reverts if the calculation overflows
      *
      * @param _x   factor 1
      * @param _y   factor 2
      *
      * @return product
    */
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        // gas optimization
        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y);
        return z;
    }

      /**
        * ev Integer division of two numbers truncating the quotient, reverts on division by zero.
        *
        * aram _x   dividend
        * aram _y   divisor
        *
        * eturn quotient
    */
    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_y > 0);
        uint256 c = _x / _y;

        return c;
    }
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

    // RAY contracts
    bytes32 internal constant RAY_PORTFOLIO_MANAGER = keccak256('PortfolioManagerContract');
    bytes32 internal constant RAY_NAV_CALCULATOR= keccak256('NAVCalculatorContract');

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

// File: contracts/utility/interfaces/ITokenHolder.sol

pragma solidity 0.4.26;



/*
    Token Holder interface
*/
contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}

// File: contracts/token/interfaces/INonStandardERC20.sol

pragma solidity 0.4.26;

/*
    ERC20 Standard Token interface which doesn't return true/false for transfer, transferFrom and approve
*/
contract INonStandardERC20 {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {this;}
    function symbol() public view returns (string) {this;}
    function decimals() public view returns (uint8) {this;}
    function totalSupply() public view returns (uint256) {this;}
    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}
    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}

    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public;
    function approve(address _spender, uint256 _value) public;
}

// File: contracts/utility/TokenHolder.sol

pragma solidity 0.4.26;






/**
  * @dev We consider every contract to be a 'token holder' since it's currently not possible
  * for a contract to deny receiving tokens.
  *
  * The TokenHolder's contract sole purpose is to provide a safety mechanism that allows
  * the owner to send tokens that were sent to the contract by mistake back to their sender.
  *
  * Note that we use the non standard ERC-20 interface which has no return value for transfer
  * in order to support both non standard as well as standard token contracts.
  * see https://github.com/ethereum/solidity/issues/4116
*/
contract TokenHolder is ITokenHolder, Owned, Utils {
    /**
      * @dev initializes a new TokenHolder instance
    */
    constructor() public {
    }

    /**
      * @dev withdraws tokens held by the contract and sends them to an account
      * can only be called by the owner
      *
      * @param _token   ERC20 token contract address
      * @param _to      account to receive the new amount
      * @param _amount  amount to withdraw
    */
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        INonStandardERC20(_token).transfer(_to, _amount);
    }
}

// File: contracts/token/SmartTokenController.sol

pragma solidity 0.4.26;




/**
  * @dev The smart token controller is an upgradable part of the smart token that allows
  * more functionality as well as fixes for bugs/exploits.
  * Once it accepts ownership of the token, it becomes the token's sole controller
  * that can execute any of its functions.
  *
  * To upgrade the controller, ownership must be transferred to a new controller, along with
  * any relevant data.
  *
  * The smart token must be set on construction and cannot be changed afterwards.
  * Wrappers are provided (as opposed to a single 'execute' function) for each of the token's functions, for easier access.
  *
  * Note that the controller can transfer token ownership to a new controller that
  * doesn't allow executing any function on the token, for a trustless solution.
  * Doing that will also remove the owner's ability to upgrade the controller.
*/
contract SmartTokenController is ISmartTokenController, TokenHolder {
    ISmartToken public token;   // Smart Token contract
    address public bancorX;     // BancorX contract

    /**
      * @dev initializes a new SmartTokenController instance
      *
      * @param  _token      smart token governed by the controller
    */
    constructor(ISmartToken _token)
        public
        validAddress(_token)
    {
        token = _token;
    }

    // ensures that the controller is the token's owner
    modifier active() {
        require(token.owner() == address(this));
        _;
    }

    // ensures that the controller is not the token's owner
    modifier inactive() {
        require(token.owner() != address(this));
        _;
    }

    /**
      * @dev allows transferring the token ownership
      * the new owner needs to accept the transfer
      * can only be called by the contract owner
      *
      * @param _newOwner    new token owner
    */
    function transferTokenOwnership(address _newOwner) public ownerOnly {
        token.transferOwnership(_newOwner);
    }

    /**
      * @dev used by a new owner to accept a token ownership transfer
      * can only be called by the contract owner
    */
    function acceptTokenOwnership() public ownerOnly {
        token.acceptOwnership();
    }

    /**
      * @dev withdraws tokens held by the controller and sends them to an account
      * can only be called by the owner
      *
      * @param _token   ERC20 token contract address
      * @param _to      account to receive the new amount
      * @param _amount  amount to withdraw
    */
    function withdrawFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        ITokenHolder(token).withdrawTokens(_token, _to, _amount);
    }

    /**
      * @dev allows the associated BancorX contract to claim tokens from any address (so that users
      * dont have to first give allowance when calling BancorX)
      *
      * @param _from      address to claim the tokens from
      * @param _amount    the amount of tokens to claim
     */
    function claimTokens(address _from, uint256 _amount) public {
        // only the associated BancorX contract may call this method
        require(msg.sender == bancorX);

        // destroy the tokens belonging to _from, and issue the same amount to bancorX
        token.destroy(_from, _amount);
        token.issue(msg.sender, _amount);
    }

    /**
      * @dev allows the owner to set the associated BancorX contract
      * @param _bancorX    BancorX contract
     */
    function setBancorX(address _bancorX) public ownerOnly {
        bancorX = _bancorX;
    }
}

// File: contracts/token/interfaces/IEtherToken.sol

pragma solidity 0.4.26;


/*
    Ether Token interface
*/
contract IEtherToken is IERC20Token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function depositTo(address _to) public payable;
    function withdrawTo(address _to, uint256 _amount) public;
}

// File: contracts/bancorx/interfaces/IBancorX.sol

pragma solidity 0.4.26;

contract IBancorX {
    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;
    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);
}

// File: contracts/converter/BancorConverter.sol

pragma solidity 0.4.26;














/**
  * @dev Bancor Converter
  *
  * The Bancor converter allows for conversions between a Smart Token and other ERC20 tokens and between different ERC20 tokens and themselves.
  *
  * This mechanism opens the possibility to create different financial tools (for example, lower slippage in conversions).
  *
  * The converter is upgradable (just like any SmartTokenController) and all upgrades are opt-in.
  *
  * WARNING: It is NOT RECOMMENDED to use the converter with Smart Tokens that have less than 8 decimal digits or with very small numbers because of precision loss
  *
  * Open issues:
  * - Front-running attacks are currently mitigated by providing the minimum return argument for each conversion
  *   Other potential solutions might include a commit/reveal based schemes
*/
contract BancorConverter is IBancorConverter, SmartTokenController, ContractRegistryClient, FeatureIds {
    using SafeMath for uint256;

    uint32 private constant RATIO_RESOLUTION = 1000000;
    uint64 private constant CONVERSION_FEE_RESOLUTION = 1000000;

    struct Reserve {
        uint256 virtualBalance;         // reserve virtual balance
        uint32 ratio;                   // reserve ratio, represented in ppm, 1-1000000
        bool isVirtualBalanceEnabled;   // true if virtual balance is enabled, false if not
        bool isSaleEnabled;             // is sale of the reserve token enabled, can be set by the owner
        bool isSet;                     // used to tell if the mapping element is defined
    }

    /**
      * @dev version number
    */
    uint16 public version = 26;

    IWhitelist public conversionWhitelist;          // whitelist contract with list of addresses that are allowed to use the converter
    IERC20Token[] public reserveTokens;             // ERC20 standard token addresses (prior version 17, use 'connectorTokens' instead)
    mapping (address => Reserve) public reserves;   // reserve token addresses -> reserve data (prior version 17, use 'connectors' instead)
    uint32 public totalReserveRatio = 0;            // total ratio of all reservces, also used to efficiently prevent increasing
                                                    // the total reserve ratio above 100%
    uint32 public maxConversionFee = 0;             // maximum conversion fee for the lifetime of the contract,
                                                    // represented in ppm, 0...1000000 (0 = no fee, 100 = 0.01%, 1000000 = 100%)
    uint32 public conversionFee = 0;                // current conversion fee, represented in ppm, 0...maxConversionFee
    bool public conversionsEnabled = true;          // deprecated, backward compatibility

    /**
      * @dev triggered when a conversion between two tokens occurs
      *
      * @param _fromToken       ERC20 token converted from
      * @param _toToken         ERC20 token converted to
      * @param _trader          wallet that initiated the trade
      * @param _amount          amount converted, in fromToken
      * @param _return          amount returned, minus conversion fee
      * @param _conversionFee   conversion fee
    */
    event Conversion(
        address indexed _fromToken,
        address indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    /**
      * @dev triggered after a conversion with new price data
      *
      * @param  _connectorToken     reserve token
      * @param  _tokenSupply        smart token supply
      * @param  _connectorBalance   reserve balance
      * @param  _connectorWeight    reserve ratio
    */
    event PriceDataUpdate(
        address indexed _connectorToken,
        uint256 _tokenSupply,
        uint256 _connectorBalance,
        uint32 _connectorWeight
    );

    /**
      * @dev triggered when the conversion fee is updated
      *
      * @param  _prevFee    previous fee percentage, represented in ppm
      * @param  _newFee     new fee percentage, represented in ppm
    */
    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);

    /**
      * @dev initializes a new BancorConverter instance
      *
      * @param  _token              smart token governed by the converter
      * @param  _registry           address of a contract registry contract
      * @param  _maxConversionFee   maximum conversion fee, represented in ppm
      * @param  _reserveToken       optional, initial reserve, allows defining the first reserve at deployment time
      * @param  _reserveRatio       optional, ratio for the initial reserve
    */
    constructor(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _reserveToken,
        uint32 _reserveRatio
    )   ContractRegistryClient(_registry)
        public
        SmartTokenController(_token)
        validConversionFee(_maxConversionFee)
    {
        IContractFeatures features = IContractFeatures(addressOf(CONTRACT_FEATURES));

        // initialize supported features
        if (features != address(0))
            features.enableFeatures(FeatureIds.CONVERTER_CONVERSION_WHITELIST, true);

        maxConversionFee = _maxConversionFee;

        if (_reserveToken != address(0))
            addReserve(_reserveToken, _reserveRatio);
    }

    // validates a reserve token address - verifies that the address belongs to one of the reserve tokens
    modifier validReserve(IERC20Token _address) {
        require(reserves[_address].isSet);
        _;
    }

    // validates conversion fee
    modifier validConversionFee(uint32 _conversionFee) {
        require(_conversionFee >= 0 && _conversionFee <= CONVERSION_FEE_RESOLUTION);
        _;
    }

    // validates reserve ratio
    modifier validReserveRatio(uint32 _ratio) {
        require(_ratio > 0 && _ratio <= RATIO_RESOLUTION);
        _;
    }

    // allows execution only if the total-supply of the token is greater than zero
    modifier totalSupplyGreaterThanZeroOnly {
        require(token.totalSupply() > 0);
        _;
    }

    // allows execution only on a multiple-reserve converter
    modifier multipleReservesOnly {
        require(reserveTokens.length > 1);
        _;
    }

    /**
      * @dev returns the number of reserve tokens defined
      * note that prior to version 17, you should use 'connectorTokenCount' instead
      *
      * @return number of reserve tokens
    */
    function reserveTokenCount() public view returns (uint16) {
        return uint16(reserveTokens.length);
    }

    /**
      * @dev allows the owner to update & enable the conversion whitelist contract address
      * when set, only addresses that are whitelisted are actually allowed to use the converter
      * note that the whitelist check is actually done by the BancorNetwork contract
      *
      * @param _whitelist    address of a whitelist contract
    */
    function setConversionWhitelist(IWhitelist _whitelist)
        public
        ownerOnly
        notThis(_whitelist)
    {
        conversionWhitelist = _whitelist;
    }

    /**
      * @dev allows transferring the token ownership
      * the new owner needs to accept the transfer
      * can only be called by the contract owner
      * note that token ownership can only be transferred while the owner is the converter upgrader contract
      *
      * @param _newOwner    new token owner
    */
    function transferTokenOwnership(address _newOwner)
        public
        ownerOnly
        only(BANCOR_CONVERTER_UPGRADER)
    {
        super.transferTokenOwnership(_newOwner);
    }

    /**
      * @dev used by a new owner to accept a token ownership transfer
      * can only be called by the contract owner
      * note that token ownership can only be accepted if its total-supply is greater than zero
    */
    function acceptTokenOwnership()
        public
        ownerOnly
        totalSupplyGreaterThanZeroOnly
    {
        super.acceptTokenOwnership();
    }

    /**
      * @dev updates the current conversion fee
      * can only be called by the contract owner
      *
      * @param _conversionFee new conversion fee, represented in ppm
    */
    function setConversionFee(uint32 _conversionFee)
        public
        ownerOnly
    {
        require(_conversionFee >= 0 && _conversionFee <= maxConversionFee);
        emit ConversionFeeUpdate(conversionFee, _conversionFee);
        conversionFee = _conversionFee;
    }

    /**
      * @dev given a return amount, returns the amount minus the conversion fee
      *
      * @param _amount      return amount
      * @param _magnitude   1 for standard conversion, 2 for cross reserve conversion
      *
      * @return return amount minus conversion fee
    */
    function getFinalAmount(uint256 _amount, uint8 _magnitude) public view returns (uint256) {
        return _amount.mul((CONVERSION_FEE_RESOLUTION - conversionFee) ** _magnitude).div(CONVERSION_FEE_RESOLUTION ** _magnitude);
    }

    /**
      * @dev replaces simple 'transfer' functionality for a converter when it's being
      * set-up. In case it has specific integration actions it wishes to take.
      *
      * note this function will transfer funds in from the caller, then execute
      * an inherited custom action, if eligible.
      *
      * @param _reserveToken          address of the reserve token
      * @param _depositAmount         the amount in base units of the underlying token
    */
    function depositTokens(
      IERC20Token _reserveToken,
      uint256 _depositAmount
    )
      public
      ownerOnly
      inactive
    {
      // transfer funds from the caller in the reserve token to this contract
      ensureTransferFrom(_reserveToken, msg.sender, this, _depositAmount);

      onBuy(_reserveToken, _depositAmount);
    }

    /**
      * @dev withdraws tokens held by the converter and sends them to an account
      * can only be called by the owner
      * note that reserve tokens can only be withdrawn by the owner while the converter is inactive
      * unless the owner is the converter upgrader contract
      *
      * @param _token   ERC20 token contract address
      * @param _to      account to receive the new amount
      * @param _amount  amount to withdraw
    */
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public {
        address converterUpgrader = addressOf(BANCOR_CONVERTER_UPGRADER);

        // if the token is not a reserve token, allow withdrawal
        // otherwise verify that the converter is inactive or that the owner is the upgrader contract
        require(!reserves[_token].isSet || token.owner() != address(this) || owner == converterUpgrader);
        super.withdrawTokens(_token, _to, _amount);
    }

    /**
      * @dev upgrades the converter to the latest version
      * can only be called by the owner
      * note that the owner needs to call acceptOwnership on the new converter after the upgrade
    */
    function upgrade() public ownerOnly {
        IBancorConverterUpgrader converterUpgrader = IBancorConverterUpgrader(addressOf(BANCOR_CONVERTER_UPGRADER));

        transferOwnership(converterUpgrader);
        converterUpgrader.upgrade(version);
        acceptOwnership();
    }

    /**
      * @dev defines a new reserve for the token
      * can only be called by the owner while the converter is inactive
      * note that prior to version 17, you should use 'addConnector' instead
      *
      * @param _token                  address of the reserve token
      * @param _ratio                  constant reserve ratio, represented in ppm, 1-1000000
    */
    function addReserve(IERC20Token _token, uint32 _ratio)
        public
        ownerOnly
        inactive
        validAddress(_token)
        notThis(_token)
        validReserveRatio(_ratio)
    {
        require(_token != token && !reserves[_token].isSet && totalReserveRatio + _ratio <= RATIO_RESOLUTION); // validate input

        reserves[_token].ratio = _ratio;
        reserves[_token].isVirtualBalanceEnabled = false;
        reserves[_token].virtualBalance = 0;
        reserves[_token].isSaleEnabled = true;
        reserves[_token].isSet = true;
        reserveTokens.push(_token);
        totalReserveRatio += _ratio;
    }

    /**
      * @dev updates a reserve's virtual balance
      * only used during an upgrade process
      * can only be called by the contract owner while the owner is the converter upgrader contract
      * note that prior to version 17, you should use 'updateConnector' instead
      *
      * @param _reserveToken    address of the reserve token
      * @param _virtualBalance  new reserve virtual balance, or 0 to disable virtual balance
    */
    function updateReserveVirtualBalance(IERC20Token _reserveToken, uint256 _virtualBalance)
        public
        ownerOnly
        only(BANCOR_CONVERTER_UPGRADER)
        validReserve(_reserveToken)
    {
        Reserve storage reserve = reserves[_reserveToken];
        reserve.isVirtualBalanceEnabled = _virtualBalance != 0;
        reserve.virtualBalance = _virtualBalance;
    }

    /**
      * @dev returns the reserve's ratio
      * added in version 22
      *
      * @param _reserveToken    reserve token contract address
      *
      * @return reserve ratio
    */
    function getReserveRatio(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {
        return reserves[_reserveToken].ratio;
    }

    /**
      * @dev returns the reserve's balance
      * note that prior to version 17, you should use 'getConnectorBalance' instead
      *
      * @param _reserveToken    reserve token contract address
      *
      * @return reserve balance
    */
    function getReserveBalance(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {
        return _reserveToken.balanceOf(this);
    }

    /**
      * @dev returns the reserve's balance
      * note that prior to version 17, you should use 'getConnectorBalance' instead
      * note this replaces where [_]reserveToken.balanceOf() was used in-line in
      * this contract previously.
      *
      * @param _reserveToken    reserve token contract address
      *
      * @return reserve balance
    */
    function _getReserveBalance(IERC20Token _reserveToken)
        internal
        view
        returns (uint256)
    {
        return _reserveToken.balanceOf(this);
    }

    /**
      * @dev calculates the expected return of converting a given amount of tokens
      *
      * @param _fromToken  contract address of the token to convert from
      * @param _toToken    contract address of the token to convert to
      * @param _amount     amount of tokens received from the user
      *
      * @return amount of tokens that the user will receive
      * @return amount of tokens that the user will pay as fee
    */
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256) {
        require(_fromToken != _toToken); // validate input

        // conversion between the token and one of its reserves
        if (_toToken == token)
            return getPurchaseReturn(_fromToken, _amount);
        else if (_fromToken == token)
            return getSaleReturn(_toToken, _amount);

        // conversion between 2 reserves
        return getCrossReserveReturn(_fromToken, _toToken, _amount);
    }

    /**
      * @dev calculates the expected return of buying with a given amount of tokens
      *
      * @param _reserveToken    contract address of the reserve token
      * @param _depositAmount   amount of reserve-tokens received from the user
      *
      * @return amount of supply-tokens that the user will receive
      * @return amount of supply-tokens that the user will pay as fee
    */
    function getPurchaseReturn(IERC20Token _reserveToken, uint256 _depositAmount)
        public
        view
        active
        validReserve(_reserveToken)
        returns (uint256, uint256)
    {
        Reserve storage reserve = reserves[_reserveToken];

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = _getReserveBalance(_reserveToken);
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = formula.calculatePurchaseReturn(tokenSupply, reserveBalance, reserve.ratio, _depositAmount);
        uint256 finalAmount = getFinalAmount(amount, 1);

        // return the amount minus the conversion fee and the conversion fee
        return (finalAmount, amount - finalAmount);
    }

    /**
      * @dev calculates the expected return of selling a given amount of tokens
      *
      * @param _reserveToken    contract address of the reserve token
      * @param _sellAmount      amount of supply-tokens received from the user
      *
      * @return amount of reserve-tokens that the user will receive
      * @return amount of reserve-tokens that the user will pay as fee
    */
    function getSaleReturn(IERC20Token _reserveToken, uint256 _sellAmount)
        public
        view
        active
        validReserve(_reserveToken)
        returns (uint256, uint256)
    {
        Reserve storage reserve = reserves[_reserveToken];
        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = _getReserveBalance(_reserveToken);
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = formula.calculateSaleReturn(tokenSupply, reserveBalance, reserve.ratio, _sellAmount);
        uint256 finalAmount = getFinalAmount(amount, 1);

        // return the amount minus the conversion fee and the conversion fee
        return (finalAmount, amount - finalAmount);
    }

    /**
      * @dev calculates the expected return of converting a given amount from one reserve to another
      * note that prior to version 17, you should use 'getCrossConnectorReturn' instead
      *
      * @param _fromReserveToken    contract address of the reserve token to convert from
      * @param _toReserveToken      contract address of the reserve token to convert to
      * @param _amount              amount of tokens received from the user
      *
      * @return amount of tokens that the user will receive
      * @return amount of tokens that the user will pay as fee
    */
    function getCrossReserveReturn(IERC20Token _fromReserveToken, IERC20Token _toReserveToken, uint256 _amount)
        public
        view
        active
        validReserve(_fromReserveToken)
        validReserve(_toReserveToken)
        returns (uint256, uint256)
    {
        Reserve storage fromReserve = reserves[_fromReserveToken];
        Reserve storage toReserve = reserves[_toReserveToken];

        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = formula.calculateCrossReserveReturn(
            getReserveBalance(_fromReserveToken),
            fromReserve.ratio,
            getReserveBalance(_toReserveToken),
            toReserve.ratio,
            _amount);
        uint256 finalAmount = getFinalAmount(amount, 2);

        // return the amount minus the conversion fee and the conversion fee
        // the fee is higher (magnitude = 2) since cross reserve conversion equals 2 conversions (from / to the smart token)
        return (finalAmount, amount - finalAmount);
    }

    /**
      * @dev converts a specific amount of _fromToken to _toToken
      * can only be called by the bancor network contract
      *
      * @param _fromToken  ERC20 token to convert from
      * @param _toToken    ERC20 token to convert to
      * @param _amount     amount to convert, in fromToken
      * @param _minReturn  if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      *
      * @return conversion return amount
    */
    function convertInternal(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn)
        public
        only(BANCOR_NETWORK)
        greaterThanZero(_minReturn)
        returns (uint256)
    {
        require(_fromToken != _toToken); // validate input

        // conversion between the token and one of its reserves
        if (_toToken == token)
            return buy(_fromToken, _amount, _minReturn);
        else if (_fromToken == token)
            return sell(_toToken, _amount, _minReturn);

        uint256 amount;
        uint256 feeAmount;

        // conversion between 2 reserves
        (amount, feeAmount) = getCrossReserveReturn(_fromToken, _toToken, _amount);
        // ensure the trade gives something in return and meets the minimum requested amount
        require(amount != 0 && amount >= _minReturn);

        Reserve storage fromReserve = reserves[_fromToken];
        Reserve storage toReserve = reserves[_toToken];

        // ensure that the trade won't deplete the reserve balance
        uint256 toReserveBalance = getReserveBalance(_toToken);
        assert(amount < toReserveBalance);

        // transfer funds from the caller in the from reserve token
        ensureTransferFrom(_fromToken, msg.sender, this, _amount);
        // if not overridden, this call does nothing
        onBuy(_fromToken, _amount);
        // if not overridden, this call does nothing
        onSale(_toToken, amount);
        // transfer funds to the caller in the to reserve token
        ensureTransferFrom(_toToken, this, msg.sender, amount);

        // dispatch the conversion event
        // the fee is higher (magnitude = 2) since cross reserve conversion equals 2 conversions (from / to the smart token)
        dispatchConversionEvent(_fromToken, _toToken, _amount, amount, feeAmount);

        // dispatch price data updates for the smart token / both reserves
        emit PriceDataUpdate(_fromToken, token.totalSupply(), _fromToken.balanceOf(this), fromReserve.ratio);
        emit PriceDataUpdate(_toToken, token.totalSupply(), _toToken.balanceOf(this), toReserve.ratio);
        return amount;
    }

    /**
      * @dev buys the token by depositing one of its reserve tokens
      *
      * @param _reserveToken    reserve token contract address
      * @param _depositAmount   amount to deposit (in the reserve token)
      * @param _minReturn       if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      *
      * @return buy return amount
    */
    function buy(IERC20Token _reserveToken, uint256 _depositAmount, uint256 _minReturn) internal returns (uint256) {
        uint256 amount;
        uint256 feeAmount;
        (amount, feeAmount) = getPurchaseReturn(_reserveToken, _depositAmount);
        // ensure the trade gives something in return and meets the minimum requested amount
        require(amount != 0 && amount >= _minReturn);

        Reserve storage reserve = reserves[_reserveToken];

        // transfer funds from the caller in the reserve token
        ensureTransferFrom(_reserveToken, msg.sender, this, _depositAmount);
        // issue new funds to the caller in the smart token
        token.issue(msg.sender, amount);

        // if not overridden, this call does nothing
        onBuy(_reserveToken, _depositAmount);

        // dispatch the conversion event
        dispatchConversionEvent(_reserveToken, token, _depositAmount, amount, feeAmount);

        // dispatch price data update for the smart token/reserve
        emit PriceDataUpdate(_reserveToken, token.totalSupply(), _getReserveBalance(_reserveToken), reserve.ratio);
        return amount;
    }

    /**
      * @dev sells the token by withdrawing from one of its reserve tokens
      *
      * @param _reserveToken    reserve token contract address
      * @param _sellAmount      amount to sell (in the smart token)
      * @param _minReturn       if the conversion results in an amount smaller the minimum return - it is cancelled, must be nonzero
      *
      * @return sell return amount
    */
    function sell(IERC20Token _reserveToken, uint256 _sellAmount, uint256 _minReturn) internal returns (uint256) {
        require(_sellAmount <= token.balanceOf(msg.sender)); // validate input
        uint256 amount;
        uint256 feeAmount;
        (amount, feeAmount) = getSaleReturn(_reserveToken, _sellAmount);
        // ensure the trade gives something in return and meets the minimum requested amount
        require(amount != 0 && amount >= _minReturn);

        // ensure that the trade will only deplete the reserve balance if the total supply is depleted as well
        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance =  _getReserveBalance(_reserveToken);
        assert(amount < reserveBalance || (amount == reserveBalance && _sellAmount == tokenSupply));

        Reserve storage reserve = reserves[_reserveToken];

        // if not overridden, this call does nothing
        onSale(_reserveToken, amount);

        // destroy _sellAmount from the caller's balance in the smart token
        token.destroy(msg.sender, _sellAmount);
        // transfer funds to the caller in the reserve token
        ensureTransferFrom(_reserveToken, this, msg.sender, amount);

        // dispatch the conversion event
        dispatchConversionEvent(token, _reserveToken, _sellAmount, amount, feeAmount);

        // dispatch price data update for the smart token/reserve
        emit PriceDataUpdate(_reserveToken, token.totalSupply(), _getReserveBalance(_reserveToken), reserve.ratio);
        return amount;
    }

    /**
      * @dev converts a specific amount of _fromToken to _toToken
      * note that prior to version 16, you should use 'convert' instead
      *
      * @param _fromToken           ERC20 token to convert from
      * @param _toToken             ERC20 token to convert to
      * @param _amount              amount to convert, in fromToken
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      *
      * @return conversion return amount
    */
    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256) {
        IERC20Token[] memory path = new IERC20Token[](3);
        (path[0], path[1], path[2]) = (_fromToken, token, _toToken);
        return quickConvert2(path, _amount, _minReturn, _affiliateAccount, _affiliateFee);
    }

    /**
      * @dev converts the token to any other token in the bancor network by following a predefined conversion path
      * note that when converting from an ERC20 token (as opposed to a smart token), allowance must be set beforehand
      * note that prior to version 16, you should use 'quickConvert' instead
      *
      * @param _path                conversion path, see conversion path format in the BancorNetwork contract
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      *
      * @return tokens issued in return
    */
    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee)
        public
        payable
        returns (uint256)
    {
        IBancorNetwork bancorNetwork = IBancorNetwork(addressOf(BANCOR_NETWORK));

        // we need to transfer the source tokens from the caller to the BancorNetwork contract,
        // so it can execute the conversion on behalf of the caller
        if (msg.value == 0) {
            // not ETH, send the source tokens to the BancorNetwork contract
            // if the token is the smart token, no allowance is required - destroy the tokens
            // from the caller and issue them to the BancorNetwork contract
            if (_path[0] == token) {
                token.destroy(msg.sender, _amount); // destroy _amount tokens from the caller's balance in the smart token
                token.issue(bancorNetwork, _amount); // issue _amount new tokens to the BancorNetwork contract
            } else {
                // otherwise, we assume we already have allowance, transfer the tokens directly to the BancorNetwork contract
                ensureTransferFrom(_path[0], msg.sender, bancorNetwork, _amount);
            }
        }

        // execute the conversion and pass on the ETH with the call
        return bancorNetwork.convertFor2.value(msg.value)(_path, _amount, _minReturn, msg.sender, _affiliateAccount, _affiliateFee);
    }

    /**
      * @dev allows a user to convert BNT that was sent from another blockchain into any other
      * token on the BancorNetwork without specifying the amount of BNT to be converted, but
      * rather by providing the xTransferId which allows us to get the amount from BancorX.
      * note that prior to version 16, you should use 'completeXConversion' instead
      *
      * @param _path            conversion path, see conversion path format in the BancorNetwork contract
      * @param _minReturn       if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _conversionId    pre-determined unique (if non zero) id which refers to this transaction
      *
      * @return tokens issued in return
    */
    function completeXConversion2(
        IERC20Token[] _path,
        uint256 _minReturn,
        uint256 _conversionId
    )
        public
        returns (uint256)
    {
        IBancorX bancorX = IBancorX(addressOf(BANCOR_X));
        IBancorNetwork bancorNetwork = IBancorNetwork(addressOf(BANCOR_NETWORK));

        // verify that the first token in the path is BNT
        require(_path[0] == addressOf(BNT_TOKEN));

        // get conversion amount from BancorX contract
        uint256 amount = bancorX.getXTransferAmount(_conversionId, msg.sender);

        // send BNT from msg.sender to the BancorNetwork contract
        token.destroy(msg.sender, amount);
        token.issue(bancorNetwork, amount);

        return bancorNetwork.convertFor2(_path, amount, _minReturn, msg.sender, address(0), 0);
    }

    /**
      * @dev ensures transfer of tokens, taking into account that some ERC-20 implementations don't return
      * true on success but revert on failure instead
      *
      * @param _token     the token to transfer
      * @param _from      the address to transfer the tokens from
      * @param _to        the address to transfer the tokens to
      * @param _amount    the amount to transfer
    */
    function ensureTransferFrom(IERC20Token _token, address _from, address _to, uint256 _amount) internal {
        // We must assume that functions `transfer` and `transferFrom` do not return anything,
        // because not all tokens abide the requirement of the ERC20 standard to return success or failure.
        // This is because in the current compiler version, the calling contract can handle more returned data than expected but not less.
        // This may change in the future, so that the calling contract will revert if the size of the data is not exactly what it expects.
        uint256 prevBalance = _token.balanceOf(_to);
        if (_from == address(this))
            INonStandardERC20(_token).transfer(_to, _amount);
        else
            INonStandardERC20(_token).transferFrom(_from, _to, _amount);
        uint256 postBalance = _token.balanceOf(_to);
        require(postBalance > prevBalance);
    }

    /**
      * @dev buys the token with all reserve tokens using the same percentage
      * for example, if the caller increases the supply by 10%,
      * then it will cost an amount equal to 10% of each reserve token balance
      * note that the function can be called only when conversions are enabled
      *
      * @param _amount  amount to increase the supply by (in the smart token)
    */
    function fund(uint256 _amount)
        public
        multipleReservesOnly
    {
        uint256 supply = token.totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));

        // iterate through the reserve tokens and transfer a percentage equal to the ratio between _amount
        // and the total supply in each reserve from the caller to the converter
        IERC20Token reserveToken;
        uint256 reserveBalance;
        uint256 reserveAmount;
        for (uint16 i = 0; i < reserveTokens.length; i++) {
            reserveToken = reserveTokens[i];
            reserveBalance = _getReserveBalance(reserveToken);
            reserveAmount = formula.calculateFundCost(supply, reserveBalance, totalReserveRatio, _amount);

            Reserve storage reserve = reserves[reserveToken];

            // transfer funds from the caller in the reserve token
            ensureTransferFrom(reserveToken, msg.sender, this, reserveAmount);

            // if not overridden, this call does nothing
            onBuy(reserveToken, reserveAmount);

            // dispatch price data update for the smart token/reserve
            emit PriceDataUpdate(reserveToken, supply + _amount, reserveBalance + reserveAmount, reserve.ratio);
        }

        // issue new funds to the caller in the smart token
        token.issue(msg.sender, _amount);
    }

    /**
      * @dev sells the token for all reserve tokens using the same percentage
      * for example, if the holder sells 10% of the supply,
      * then they will receive 10% of each reserve token balance in return
      * note that the function can be called also when conversions are disabled
      *
      * @param _amount  amount to liquidate (in the smart token)
    */
    function liquidate(uint256 _amount)
        public
        multipleReservesOnly
    {
        uint256 supply = token.totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));

        // destroy _amount from the caller's balance in the smart token
        token.destroy(msg.sender, _amount);

        // iterate through the reserve tokens and send a percentage equal to the ratio between _amount
        // and the total supply from each reserve balance to the caller
        IERC20Token reserveToken;
        uint256 reserveBalance;
        uint256 reserveAmount;
        for (uint16 i = 0; i < reserveTokens.length; i++) {
            reserveToken = reserveTokens[i];
            reserveBalance = _getReserveBalance(reserveToken);
            reserveAmount = formula.calculateLiquidateReturn(supply, reserveBalance, totalReserveRatio, _amount);

            Reserve storage reserve = reserves[reserveToken];

            uint256 localBalance = reserveToken.balanceOf(this);

            // if the local balance is greater or equal to the requested amount,
            // don't need to withdraw funds from the custom action
            // funds may be in converter for different reasons
            if (reserveAmount > localBalance) {
              // can't underflow due to this if()
              // only need to withdraw this amount from custom action
              uint256 onSaleAmount = reserveAmount - localBalance;

              // if not overridden, this call does nothing
              onSale(reserveToken, onSaleAmount);
            }

            // transfer funds to the caller in the reserve token
            ensureTransferFrom(reserveToken, this, msg.sender, reserveAmount);

            // dispatch price data update for the smart token/reserve
            emit PriceDataUpdate(reserveToken, supply - _amount, reserveBalance - reserveAmount, reserve.ratio);
        }
    }

    /**
      * @dev helper, dispatches the Conversion event
      *
      * @notice - changed visibility from private to internal so inherited contract
      * RAYBancorConverter could access this function definition. Seeking
      * confirmation this is fine.
      *
      * @param _fromToken       ERC20 token to convert from
      * @param _toToken         ERC20 token to convert to
      * @param _amount          amount purchased/sold (in the source token)
      * @param _returnAmount    amount returned (in the target token)
    */
    function dispatchConversionEvent(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _returnAmount, uint256 _feeAmount) internal {
        // fee amount is converted to 255 bits -
        // negative amount means the fee is taken from the source token, positive amount means its taken from the target token
        // currently the fee is always taken from the target token
        // since we convert it to a signed number, we first ensure that it's capped at 255 bits to prevent overflow
        assert(_feeAmount < 2 ** 255);
        emit Conversion(_fromToken, _toToken, msg.sender, _amount, _returnAmount, int256(_feeAmount));
    }

    /**
      * @dev can be overridden to add custom functionality for handling funds deposited
      * to the BancorConverter.
      * note - can make this an abstract function, but requires another contract to
      * inherit and override this to be able to deploy
      *
      * @param _reserveToken  the underlying token to use
      * @param _amount  the amount in base units of the underlying token
    */
    function onBuy(IERC20Token _reserveToken, uint256 _amount) internal {
      return;
    }

    /**
      * @dev can be overridden to add custom functionality for handling withdrawing funds
      * for the BancorConverter.
      * note - can make this an abstract function, but requires another contract to
      * inherit and override this to be able to deploy
      *
      * @param _reserveToken  the underlying token to use
      * @param _amount  the amount in base units of the underlying token
    */
    function onSale(IERC20Token _reserveToken, uint256 _amount) internal {
      return;
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        return convertInternal(_fromToken, _toToken, _amount, _minReturn);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        return convert2(_fromToken, _toToken, _amount, _minReturn, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256) {
        return quickConvert2(_path, _amount, _minReturn, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function quickConvertPrioritized2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, uint256[] memory, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256) {
        return quickConvert2(_path, _amount, _minReturn, _affiliateAccount, _affiliateFee);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function quickConvertPrioritized(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, uint256, uint8, bytes32, bytes32) public payable returns (uint256) {
        return quickConvert2(_path, _amount, _minReturn, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function completeXConversion(IERC20Token[] _path, uint256 _minReturn, uint256 _conversionId, uint256, uint8, bytes32, bytes32) public returns (uint256) {
        return completeXConversion2(_path, _minReturn, _conversionId);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) {
        Reserve storage reserve = reserves[_address];
        return(reserve.virtualBalance, reserve.ratio, reserve.isVirtualBalanceEnabled, reserve.isSaleEnabled, reserve.isSet);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function connectorTokens(uint256 _index) public view returns (IERC20Token) {
        return BancorConverter.reserveTokens[_index];
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function connectorTokenCount() public view returns (uint16) {
        return reserveTokenCount();
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function addConnector(IERC20Token _token, uint32 _weight, bool /*_enableVirtualBalance*/) public {
        addReserve(_token, _weight);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function updateConnector(IERC20Token _connectorToken, uint32 /*_weight*/, bool /*_enableVirtualBalance*/, uint256 _virtualBalance) public {
        updateReserveVirtualBalance(_connectorToken, _virtualBalance);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256) {
        return getReserveBalance(_connectorToken);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function getCrossConnectorReturn(IERC20Token _fromConnectorToken, IERC20Token _toConnectorToken, uint256 _amount) public view returns (uint256, uint256) {
        return getCrossReserveReturn(_fromConnectorToken, _toConnectorToken, _amount);
    }
}

// File: contracts/ray/interfaces/IRAY.sol

/**

    The software and documentation available in this repository (the "Software") is
    protected by copyright law and accessible pursuant to the license set forth below.

    Copyright © 2020 Staked Securely, Inc. All rights reserved.

    Permission is hereby granted, free of charge, to any person or organization
    obtaining the Software (the “Licensee”) to privately study, review, and analyze
    the Software. Licensee shall not use the Software for any other purpose. Licensee
    shall not modify, transfer, assign, share, or sub-license the Software or any
    derivative works of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
    PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT
    HOLDERS BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT,
    OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE.

*/

pragma solidity 0.4.26;

interface IRAY {


  /// @notice  Mints a RAY token of the associated basket of opportunities to the portfolioId
  ///
  /// @param   portfolioId - the id of the portfolio to associate the RAY token with
  /// @param   beneficiary - the owner and beneficiary of the RAY token
  /// @param   value - the amount in the smallest units in-kind to deposit into RAY
  ///
  /// @return  the unique RAY token id, used to reference anything in the RAY system
  function mint(bytes32 portfolioId, address beneficiary, uint value) external payable returns(bytes32);


  /// @notice  Deposits assets into an existing RAY token
  ///
  /// @dev     Anybody can deposit into a RAY token, not just the owner
  ///
  /// @param   tokenId - the id of the RAY token to add value too
  /// @param   value - the amount in the smallest units in-kind to deposit into the RAY
  function deposit(bytes32 tokenId, uint value) external payable;


  /// @notice  Redeems a RAY token for the underlying value
  ///
  /// @dev     Can partially or fully redeem the RAY token
  ///
  ///          Only the owner of the RAY token can call this, or the Staked
  ///          'GasFunder' smart contract
  ///
  /// @param   tokenId - the id of the RAY token to redeem value from
  /// @param   valueToWithdraw - the amount in the smallest units in-kind to redeem from the RAY
  /// @param   originalCaller - only relevant for our `GasFunder` smart contract,
  ///                           for everyone else, can be set to anything
  ///
  /// @return  the amount transferred to the owner of the RAY token after fees
  function redeem(bytes32 tokenId, uint valueToWithdraw, address originalCaller) external returns (uint);


  /// @notice  Get the underlying value of a RAY token (principal + yield earnt)
  ///
  /// @dev     The implementation of this function exists in NAVCalculator
  ///
  /// @param   portfolioId - the id of the portfolio associated with the RAY token
  /// @param   tokenId - the id of the RAY token to get the value of
  ///
  /// @return  an array of two, the first value is the current token value, the
  ///          second value is the NAV of the portfolio
  function getTokenValue(bytes32 portfolioId, bytes32 tokenId) external view returns (uint, uint);

}

// File: contracts/ray/interfaces/IRAYStorage.sol

/**

    The software and documentation available in this repository (the "Software") is
    protected by copyright law and accessible pursuant to the license set forth below.

    Copyright © 2020 Staked Securely, Inc. All rights reserved.

    Permission is hereby granted, free of charge, to any person or organization
    obtaining the Software (the “Licensee”) to privately study, review, and analyze
    the Software. Licensee shall not use the Software for any other purpose. Licensee
    shall not modify, transfer, assign, share, or sub-license the Software or any
    derivative works of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
    PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT
    HOLDERS BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT,
    OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE.

*/

pragma solidity 0.4.26;

interface IRAYStorage {

  /// @notice  get the address of the corresponding named contract from RAY storage
  ///          or null address if the contract name isn't in the registry.
  ///
  /// @param   contractId - the name of the contract
  ///
  /// @return  ethereum address of the corresponding named contract
  function getContractAddress(bytes32 contractId) external view returns (address);

  /// @notice  get the token address of the corresponding RAY portfolioId
  ///
  /// @param   rayPortfolioId - the identifier of the RAY portfolio
  ///
  /// @return  ethereum address of the corresponding token contract
  function getPrincipalAddress(bytes32 rayPortfolioId) external view returns (address);

}

// File: contracts/ray/interfaces/IERC20.sol

pragma solidity 0.4.26;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/ray/interfaces/IERC721Receiver.sol

/// This contract is subject to the MIT License (MIT)
///
/// Copyright (c) 2016-2019 zOS Global Limited
///
/// Permission is hereby granted, free of charge, to any person obtaining
/// a copy of this software and associated documentation files (the
/// "Software"), to deal in the Software without restriction, including
/// without limitation the rights to use, copy, modify, merge, publish,
/// distribute, sublicense, and/or sell copies of the Software, and to
/// permit persons to whom the Software is furnished to do so, subject to
/// the following conditions:
///
/// The above copyright notice and this permission notice shall be included
/// in all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
/// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
/// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
/// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
/// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
/// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
/// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


pragma solidity 0.4.26;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes data) public returns (bytes4);
}

// File: contracts/ray/RAYBancorConverter.sol

pragma solidity 0.4.26;

// internal


// external






/**
  * @dev RAY Bancor Converter
  *
  * This converter wraps reserves into RAY tokens, to achieve optimal yield as well
  * as liquidity supply fees.
  *
  * Inherit's from the base BancorConverter
*/
contract RAYBancorConverter is BancorConverter, IERC721Receiver  {
    using SafeMath for uint256;

     // used to check validity of a RAY portfolioId/tokenId
    bytes32 internal constant NULL_BYTES = bytes32(0);
    // references to dependency RAY contracts
    bytes32 internal constant RAY_PORTFOLIO_MANAGER = keccak256('PortfolioManagerContract');
    bytes32 internal constant RAY_NAV_CALCULATOR = keccak256('NAVCalculatorContract');

    // mapping of _reserveToken's to RAY tokenId's
    mapping (address => bytes32) internal rayTokens;
    // mapping of_reserveToken's to corresponding RAY portfolioId's
    mapping (address => bytes32) internal rayPortfolioIds;

    address internal rayStorage;

    /**
      * @dev initializes a new RAYBancorConverter instance.
      *
      * Note, the first reserve added should be RAY compatible, else the current
      * impl. will fail since it'll call `_addRAYReserve` with null bytes which
      * isn't a valid portfolioId. Easy to fix this behaviour if it's too inflexible
      *
      * @param  _token              smart token governed by the converter
      * @param  _registry           address of a contract registry contract
      * @param  _maxConversionFee   maximum conversion fee, represented in ppm
      * @param  _reserveToken       optional, initial reserve, allows defining the first reserve at deployment time
      * @param  _reserveRatio       optional, ratio for the initial reserve
      * @param  _rayStorage         address of the RAY registry contract
      * @param  _rayPortfolioId     identifier of the RAY type to deposit into
    */
    constructor(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _reserveToken,
        uint32 _reserveRatio,
        address _rayStorage,
        bytes32 _rayPortfolioId
    )
        BancorConverter(_token, _registry, _maxConversionFee, _reserveToken, _reserveRatio)
        public
    {
        rayStorage = _rayStorage;

        // 'addReserve' already called in parent constructor for BancorConverter,
        // which is why we don't call 'addRAYReserve' here.
        _addRAYReserve(_reserveToken, _rayPortfolioId);
    }

    /**
      * @dev defines a new reserve for the token with consideration for RAY
      * can only be called by the owner while the converter is inactive
      * note that prior to version 17, you should use 'addConnector' instead
      *
      * note that if one wishes to add a reserve without adding configuration for
      * a RAY token they should call 'addReserve' directly. If they attempt to
      * use null bytes as the RAY portfolioId here, the call will fail
      *
      * @param _token                  address of the reserve token
      * @param _ratio                  constant reserve ratio, represented in ppm, 1-1000000
      * @param _rayPortfolioId         identifier of the RAY type to deposit into
    */
    function addRAYReserve(IERC20Token _token, uint32 _ratio, bytes32 _rayPortfolioId)
        public
    {

        // this call performs validation on the caller, the time of the call, and
        // the input - if anything is invalid, it will fail the transaction. This
        // is why it's fine to leave this function public with no validation.
        super.addReserve(_token, _ratio);

        _addRAYReserve(_token, _rayPortfolioId);
    }

    /**
      * @dev defines the RAY portfolioId to use for a reserve token
      *
      * @param _token                  address of the reserve token
      * @param _rayPortfolioId         identifier of the RAY type to deposit into
    */
    function _addRAYReserve(IERC20Token _token, bytes32 _rayPortfolioId) internal {

      // verify the entered RAY portfolioId is valid, as well as valid for this token
      // If it isn't valid at all, this function will return address(0), if it's
      // valid, but not for this token, _token won't equal the returned address

      // Note, this assumes _token for a Bancor reserve is equivalent to the true
      // contract address of the ERC20 token. This also isn't valid for ETH, but
      // that's fine because we're not supporting ETH until ERC20 RAY impl.
      require(
        IRAYStorage(rayStorage).getPrincipalAddress(_rayPortfolioId) == address(_token),
        "#addRAYReserve modifier: This is not a valid RAY portfolio for this token"
      );

      rayPortfolioIds[_token] = _rayPortfolioId;

    }

    /**
      * Overridden to only fail because this implementation doesn't support upgrades.
      *
      * @dev upgrades the converter to the latest version
      * can only be called by the owner
      * note that the owner needs to call acceptOwnership on the new converter after the upgrade
    */
    function upgrade() public ownerOnly {
      revert("No upgrade functionality for this converter implementation.");
    }

    /**
      * Overridden to add consideration for the reserve's RAY balance
      *
      * @dev returns the reserve's balance
      * note that prior to version 17, you should use 'getConnectorBalance' instead
      *
      * @param _reserveToken    reserve token contract address
      *
      * @return reserve balance
    */
    function getReserveBalance(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {
        return _reserveToken.balanceOf(this) + getReserveRAYBalance(_reserveToken);
    }

    /**
      * Overridden to add consideration for the reserve's RAY balance
      *
      * @dev returns the reserve's balance
      * note that prior to version 17, you should use 'getConnectorBalance' instead
      *
      * @param _reserveToken    reserve token contract address
      *
      * @return reserve balance
    */
    function _getReserveBalance(IERC20Token _reserveToken)
        internal
        view
        returns (uint256)
    {
        return _reserveToken.balanceOf(this) + getReserveRAYBalance(_reserveToken);
    }

    /**
      * @dev returns the reserve's total RAY balance (principal + interest earnt)
      * note that this gets the complete, accurate token value
      *
      * @param _reserveToken    reserve token contract address
      *
      * @return reserve RAY balance in smallest units of the token
    */
    function getReserveRAYBalance(IERC20Token _reserveToken)
        internal
        view
        returns (uint256)
    {

      bytes32 rayTokenId = rayTokens[_reserveToken];

      // if no RAY token is owned, then the RAY balance will be zero
      if (rayTokenId == NULL_BYTES) {
        return 0;
      }

      // could read this from RAY storage using rayTokenId but that costs more gas
      // (calling an external contract) than a local storage read, especially since
      // we already have this stored for separate reasons
      bytes32 rayPortfolioId = rayPortfolioIds[_reserveToken];

      // eventually want to use addressOf() that leverages Bancor ContractRegistry
      // details to be discussed on that
      address rayNavCalculator = IRAYStorage(rayStorage).getContractAddress(RAY_NAV_CALCULATOR);

      uint256 tokenValue;
      uint256 nav;

      (tokenValue, nav) = IRAY(rayNavCalculator).getTokenValue(rayPortfolioId, rayTokenId);

      return tokenValue;

    }

    /* -------------------- RAY INTERGRATION FUNCTIONS -------------------- */

    /**
      * @dev implemented to receive ERC721 tokens. Regarding RAY, to receive
      * RAY tokens.
      *
      * note must return hash of the function signature for txn to be valid.
    */
   function onERC721Received
   (
       address /*operator*/,
       address /*from*/,
       uint256 /*tokenId*/,
       bytes /*data*/
   )
       public
       returns(bytes4)
   {
     // equal to - return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)");
     return this.onERC721Received.selector;
   }

    /**
      * Overridden to deposit funds into RAY
      *
      * @dev checks to see if a deposit to RAY is valid, if so, executes a mint
      * if a RAY token isn't owned yet, else a deposit to the existing one.
      *
      * @param _reserveToken  the underlying token to try depositing to RAY
      * @param _amount  the amount in base units of the underlying token
    */
    function onBuy(IERC20Token _reserveToken, uint256 _amount) internal {

      // grab the associated RAY portfolioId for this reserveToken
      bytes32 rayPortfolioId = rayPortfolioIds[_reserveToken];

      // if a portfolioId is NULL_BYTES, then the _reserveToken isn't eligible for
      // being being wrapped into RAY.
      // This means, we need to remember to manually add support in the
      // rayPortfolioId mapping when supporting a RAY configuration.
      if (rayPortfolioId != NULL_BYTES) {

        // grab the associated RAY token for this reserveToken
        bytes32 rayTokenId = rayTokens[_reserveToken];
        // grab the current RAY contract
        address rayContract = IRAYStorage(rayStorage).getContractAddress(RAY_PORTFOLIO_MANAGER);

        // approve the RAY contract to take these ERC20 assets.
        // This assumes it's always an ERC20 and not ETH, etc. which is currently
        // the case.
        // We can do a single max. approval upon 'addRAYReserve()', but if the RAY
        // contract address changes, it will then fail as the new address doesn't
        // have approval. We wish to avoid admin. functionality after a reserve is
        // active, so for now go for the less gas optimal approval per deposit.
        // This assumes this _reserveToken correctly follows the ERC20 standard
        // and returns true/false. If it doesn't and the approval fails, the deposit
        // attempt will fail anyway, just slightly harder to debug.
        require(
          IERC20(_reserveToken).approve(rayContract, _amount),
          "#RAYBancorConverter onBuy(): Approval of ERC20 Token failed"
        );

        // if a tokenId is NULL_BYTES, then the _reserveToken hasn't minted a RAY
        // yet.
        // else, we already minted a RAY position, and need to deposit to it -
        // we only want one RAY token per _reserveToken
        if (rayTokenId == NULL_BYTES) {
          // mint new RAY token and deposit transferred funds, call fails if no
          // RAY token is minted
          bytes32 newRayTokenId = mintRAYToken(rayContract, rayPortfolioId, _amount);
          // associate the newly minted RAY token with this reserve
          rayTokens[_reserveToken] = newRayTokenId;
        } else {
          // deposit funds to the existing RAY token
          depositToRAY(rayContract, rayTokenId, _amount);
        }

      }

    }

    /**
      * Overridden to withdraw funds from RAY
      *
      * @dev checks to see if a withdrawal from RAY is valid, if so, executes it.
      *
      * @param _reserveToken  the underlying token to try withdrawing from RAY
      * @param _amount  the amount in base units of the underlying token
    */
    function onSale(IERC20Token _reserveToken, uint256 _amount) internal {

      // grab the associated RAY token for this reserveToken
      bytes32 rayTokenId = rayTokens[_reserveToken];

      // if a tokenId is null, then the _reserveToken isn't eligible for being
      // being unwrapped from a RAY - it doesn't own a RAY token.
      if (rayTokenId != NULL_BYTES) {
        // withdraw funds from RAY
        withdrawFromRAY(rayTokenId, _amount);
      }

    }

    /**
      * @dev mints a RAY token then deposits the _reserveToken in _amount to the
      * new token, owned by the instance of this contract. Fails upon error.
      *
      * note - assumes ERC20 approval given to the RAY contract already, need to
      * decide if we wish to do this once (max. approval), etc.
      *
      * Example: Mint and deposit 10 DAI: (rayTokenId, this address, 1e19)
      *
      * @param rayContract  the current RAY contract address to interact with
      * @param rayPortfolioId  the RAY portfolio to mint and deposit to
      * @param _amount  the amount in base units of the underlying token
      *
      * @return tokenId of RAY minted
    */
    function mintRAYToken(address rayContract, bytes32 rayPortfolioId, uint256 _amount) internal returns (bytes32) {

      // mint RAY token to this contract address with a value of _amount
      bytes32 rayTokenId = IRAY(rayContract).mint(rayPortfolioId, this, _amount);

      return rayTokenId;

    }

    /**
      * @dev deposits the _reserveToken in _amount to the corresponding RAY
      * token owned by the instance of this contract. Fails upon error.
      *
      * note - assumes ERC20 approval given to the RAY contract already, need to
      * decide if we wish to do this once (max. approval), etc.
      *
      * Example: Deposit 10 DAI: (rayTokenId, 1e19)
      *
      * @param rayContract  the current RAY contract address to interact with
      * @param rayTokenId  tthe RAY tokenId to deposit to
      * @param _amount  the amount in base units of the underlying token
    */
    function depositToRAY(address rayContract, bytes32 rayTokenId, uint256 _amount) internal {

      IRAY(rayContract).deposit(rayTokenId, _amount); // deposit _amount to the RAY token specified

    }

    /**
      * @dev withdraws the _reserveToken in _amount from the corresponding RAY
      * token owned by the instance of this contract. Fails upon error.
      *
      * Example: Withdraw 10 DAI: (rayTokenId, 1e19, this)
      *
      * @param rayTokenId  the RAY tokenId to withdraw from
      * @param _amount  the amount in base units of the underlying token
    */
    function withdrawFromRAY(bytes32 rayTokenId, uint256 _amount) internal {

      // eventually want to use addressOf() that leverages Bancor ContractRegistry
      // details to be discussed on that
      address rayPortfolioManager = IRAYStorage(rayStorage).getContractAddress(RAY_PORTFOLIO_MANAGER);

      IRAY(rayPortfolioManager).redeem(rayTokenId, _amount, this); // withdraw _amount from the RAY token specified

    }

}