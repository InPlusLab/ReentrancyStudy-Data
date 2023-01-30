/**
 *Submitted for verification at Etherscan.io on 2020-01-09
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

// File: contracts/converter/interfaces/IBancorGasPriceLimit.sol

pragma solidity 0.4.26;

/*
    Bancor Gas Price Limit interface
*/
contract IBancorGasPriceLimit {
    function gasPrice() public view returns (uint256) {this;}
    function validateGasPrice(uint256) public view;
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
    bytes32 internal constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 internal constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";
    bytes32 internal constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";

    IContractRegistry public registry;      // address of the current contract-registry
    IContractRegistry public prevRegistry;  // address of the previous contract-registry
    bool public adminOnly;                  // only an administrator can update the contract-registry

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
        require(!adminOnly || isAdmin());

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
    function restoreRegistry() public {
        // verify that this function is permitted
        require(isAdmin());

        // restore the previous contract-registry
        registry = prevRegistry;
    }

    /**
      * @dev restricts the permission to update the contract-registry
      * 
      * @param _adminOnly    indicates whether or not permission is restricted to administrator only
    */
    function restrictRegistryUpdate(bool _adminOnly) public {
        // verify that this function is permitted
        require(adminOnly != _adminOnly && isAdmin());

        // change the permission to update the contract-registry
        adminOnly = _adminOnly;
    }

    /**
      * @dev returns whether or not the caller is an administrator
     */
    function isAdmin() internal view returns (bool) {
        return msg.sender == owner;
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

// File: contracts/utility/interfaces/IAddressList.sol

pragma solidity 0.4.26;

/*
    Address list interface
*/
contract IAddressList {
    mapping (address => bool) public listedAddresses;
}

// File: contracts/token/interfaces/IEtherToken.sol

pragma solidity 0.4.26;



/*
    Ether Token interface
*/
contract IEtherToken is ITokenHolder, IERC20Token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function withdrawTo(address _to, uint256 _amount) public;
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

// File: contracts/bancorx/interfaces/IBancorX.sol

pragma solidity 0.4.26;

contract IBancorX {
    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;
    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);
}

// File: contracts/BancorNetwork.sol

pragma solidity 0.4.26;
















/**
  * @dev The BancorNetwork contract is the main entry point for Bancor token conversions.
  * It also allows for the conversion of any token in the Bancor Network to any other token in a single transaction by providing a conversion path.
  * 
  * A note on Conversion Path: Conversion path is a data structure that is used when converting a token to another token in the Bancor Network,
  * when the conversion cannot necessarily be done by a single converter and might require multiple 'hops'.
  * The path defines which converters should be used and what kind of conversion should be done in each step.
  * 
  * The path format doesn't include complex structure; instead, it is represented by a single array in which each 'hop' is represented by a 2-tuple - smart token & to token.
  * In addition, the first element is always the source token.
  * The smart token is only used as a pointer to a converter (since converter addresses are more likely to change as opposed to smart token addresses).
  * 
  * Format:
  * [source token, smart token, to token, smart token, to token...]
*/
contract BancorNetwork is IBancorNetwork, TokenHolder, ContractRegistryClient, FeatureIds {
    using SafeMath for uint256;

    uint256 private constant CONVERSION_FEE_RESOLUTION = 1000000;
    uint256 private constant AFFILIATE_FEE_RESOLUTION = 1000000;

    uint256 public maxAffiliateFee = 30000;     // maximum affiliate-fee
    address public signerAddress = 0x0;         // verified address that allows conversions with higher gas price

    mapping (address => bool) public etherTokens;       // list of all supported ether tokens
    mapping (bytes32 => bool) public conversionHashes;  // list of conversion hashes, to prevent re-use of the same hash

    /**
      * @dev triggered when a conversion between two tokens occurs
      * 
      * @param _smartToken      smart token governed by the converter
      * @param _fromToken       ERC20 token converted from
      * @param _toToken         ERC20 token converted to
      * @param _fromAmount      amount converted, in fromToken
      * @param _toAmount        amount returned, minus conversion fee
      * @param _trader          wallet that initiated the trade
    */
    event Conversion(
        address indexed _smartToken,
        address indexed _fromToken,
        address indexed _toToken,
        uint256 _fromAmount,
        uint256 _toAmount,
        address _trader
    );

    /**
      * @dev initializes a new BancorNetwork instance
      * 
      * @param _registry    address of a contract registry contract
    */
    constructor(IContractRegistry _registry) ContractRegistryClient(_registry) public {
    }

    /**
      * @dev allows the owner to update the maximum affiliate-fee
      * 
      * @param _maxAffiliateFee   maximum affiliate-fee
    */
    function setMaxAffiliateFee(uint256 _maxAffiliateFee)
        public
        ownerOnly
    {
        require(_maxAffiliateFee <= AFFILIATE_FEE_RESOLUTION);
        maxAffiliateFee = _maxAffiliateFee;
    }

    /**
      * @dev allows the owner to update the signer address
      * 
      * @param _signerAddress    new signer address
    */
    function setSignerAddress(address _signerAddress)
        public
        ownerOnly
        validAddress(_signerAddress)
        notThis(_signerAddress)
    {
        signerAddress = _signerAddress;
    }

    /**
      * @dev allows the owner to register/unregister ether tokens
      * 
      * @param _token       ether token contract address
      * @param _register    true to register, false to unregister
    */
    function registerEtherToken(IEtherToken _token, bool _register)
        public
        ownerOnly
        validAddress(_token)
        notThis(_token)
    {
        etherTokens[_token] = _register;
    }

    /**
      * @dev verifies that the signer address is the one associated with the public key from a given elliptic curve signature
      * note that the signature is valid only for one conversion, and that it expires after the give block
    */
    function verifyTrustedSender(IERC20Token[] _path, address _addr, uint256[] memory _signature) private {
        uint256 blockNumber = _signature[1];

        // check that the current block number doesn't exceeded the maximum allowed with the current signature
        require(block.number <= blockNumber);

        // create the hash of the given signature
        bytes32 hash = keccak256(abi.encodePacked(blockNumber, tx.gasprice, _addr, msg.sender, _signature[0], _path));

        // check that it is the first conversion with the given signature
        require(!conversionHashes[hash]);

        // verify that the signing address is identical to the trusted signer address in the contract
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        require(ecrecover(prefixedHash, uint8(_signature[2]), bytes32(_signature[3]), bytes32(_signature[4])) == signerAddress);

        // mark the hash so that it can't be used multiple times
        conversionHashes[hash] = true;
    }

    /**
      * @dev converts the token to any other token in the bancor network by following
      * a predefined conversion path and transfers the result tokens to a target account
      * note that the network should already own the source tokens
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _for                 account that will receive the conversion result
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return tokens issued in return
    */
    function convertFor2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256) {
        return convertForPrioritized4(_path, _amount, _minReturn, _for, getSignature(0x0, 0x0, 0x0, 0x0, 0x0), _affiliateAccount, _affiliateFee);
    }

    /**
      * @dev converts the token to any other token in the bancor network
      * by following a predefined conversion path and transfers the result
      * tokens to a target account.
      * this version of the function also allows the verified signer
      * to bypass the universal gas price limit.
      * note that the network should already own the source tokens
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _for                 account that will receive the conversion result
      * @param _signature           an array of the following elements:
      *     [0] uint256             custom value that was signed for prioritized conversion
      *     [1] uint256             if the current block exceeded the given parameter - it is cancelled
      *     [2] uint8               (signature[128:130]) associated with the signer address and helps to validate if the signature is legit
      *     [3] bytes32             (signature[0:64]) associated with the signer address and helps to validate if the signature is legit
      *     [4] bytes32             (signature[64:128]) associated with the signer address and helps to validate if the signature is legit
      * if the array is empty (length == 0), then the gas-price limit is verified instead of the signature
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return tokens issued in return
    */
    function convertForPrioritized4(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256[] memory _signature,
        address _affiliateAccount,
        uint256 _affiliateFee
    )
        public
        payable
        returns (uint256)
    {
        // verify that the conversion parameters are legal
        verifyConversionParams(_path, _for, _for, _signature);

        // handle msg.value
        handleValue(_path[0], _amount, false);

        // convert and get the resulting amount
        uint256 amount = convertByPath(_path, _amount, _minReturn, _affiliateAccount, _affiliateFee);

        // finished the conversion, transfer the funds to the target account
        // if the target token is an ether token, withdraw the tokens and send them as ETH
        // otherwise, transfer the tokens as is
        IERC20Token toToken = _path[_path.length - 1];
        if (etherTokens[toToken])
            IEtherToken(toToken).withdrawTo(_for, amount);
        else
            ensureTransferFrom(toToken, this, _for, amount);

        return amount;
    }

    /**
      * @dev converts any other token to BNT in the bancor network
      * by following a predefined conversion path and transfers the resulting
      * tokens to BancorX.
      * note that the network should already have been given allowance of the source token (if not ETH)
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _toBlockchain        blockchain BNT will be issued on
      * @param _to                  address/account on _toBlockchain to send the BNT to
      * @param _conversionId        pre-determined unique (if non zero) id which refers to this transaction 
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return the amount of BNT received from this conversion
    */
    function xConvert2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        bytes32 _toBlockchain,
        bytes32 _to,
        uint256 _conversionId,
        address _affiliateAccount,
        uint256 _affiliateFee
    )
        public
        payable
        returns (uint256)
    {
        return xConvertPrioritized3(_path, _amount, _minReturn, _toBlockchain, _to, _conversionId, getSignature(0x0, 0x0, 0x0, 0x0, 0x0), _affiliateAccount, _affiliateFee);
    }

    /**
      * @dev converts any other token to BNT in the bancor network
      * by following a predefined conversion path and transfers the resulting
      * tokens to BancorX.
      * this version of the function also allows the verified signer
      * to bypass the universal gas price limit.
      * note that the network should already have been given allowance of the source token (if not ETH)
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _toBlockchain        blockchain BNT will be issued on
      * @param _to                  address/account on _toBlockchain to send the BNT to
      * @param _conversionId        pre-determined unique (if non zero) id which refers to this transaction 
      * @param _signature           an array of the following elements:
      *     [0] uint256             custom value that was signed for prioritized conversion; must be equal to _amount
      *     [1] uint256             if the current block exceeded the given parameter - it is cancelled
      *     [2] uint8               (signature[128:130]) associated with the signer address and helps to validate if the signature is legit
      *     [3] bytes32             (signature[0:64]) associated with the signer address and helps to validate if the signature is legit
      *     [4] bytes32             (signature[64:128]) associated with the signer address and helps to validate if the signature is legit
      * if the array is empty (length == 0), then the gas-price limit is verified instead of the signature
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return the amount of BNT received from this conversion
    */
    function xConvertPrioritized3(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        bytes32 _toBlockchain,
        bytes32 _to,
        uint256 _conversionId,
        uint256[] memory _signature,
        address _affiliateAccount,
        uint256 _affiliateFee
    )
        public
        payable
        returns (uint256)
    {
        // verify that the custom value (if valid) is equal to _amount
        require(_signature.length == 0 || _signature[0] == _amount);

        // verify that the conversion parameters are legal
        verifyConversionParams(_path, msg.sender, this, _signature);

        // verify that the destination token is BNT
        require(_path[_path.length - 1] == addressOf(BNT_TOKEN));

        // handle msg.value
        handleValue(_path[0], _amount, true);

        // convert and get the resulting amount
        uint256 amount = convertByPath(_path, _amount, _minReturn, _affiliateAccount, _affiliateFee);

        // transfer the resulting amount to BancorX
        IBancorX(addressOf(BANCOR_X)).xTransfer(_toBlockchain, _to, amount, _conversionId);

        return amount;
    }

    /**
      * @dev executes the actual conversion by following the conversion path
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return amount of tokens issued
    */
    function convertByPath(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) private returns (uint256) {
        uint256 toAmount;
        uint256 fromAmount = _amount;
        uint256 lastIndex = _path.length - 1;

        address bntToken;
        if (address(_affiliateAccount) == 0) {
            require(_affiliateFee == 0);
            bntToken = address(0);
        }
        else {
            require(0 < _affiliateFee && _affiliateFee <= maxAffiliateFee);
            bntToken = addressOf(BNT_TOKEN);
        }

        // iterate over the conversion path
        for (uint256 i = 2; i <= lastIndex; i += 2) {
            IBancorConverter converter = IBancorConverter(ISmartToken(_path[i - 1]).owner());

            // if the smart token isn't the source (from token), the converter doesn't have control over it and thus we need to approve the request
            if (_path[i - 1] != _path[i - 2])
                ensureAllowance(_path[i - 2], converter, fromAmount);

            // make the conversion - if it's the last one, also provide the minimum return value
            toAmount = converter.change(_path[i - 2], _path[i], fromAmount, i == lastIndex ? _minReturn : 1);

            // pay affiliate-fee if needed
            if (address(_path[i]) == bntToken) {
                uint256 affiliateAmount = toAmount.mul(_affiliateFee).div(AFFILIATE_FEE_RESOLUTION);
                require(_path[i].transfer(_affiliateAccount, affiliateAmount));
                toAmount -= affiliateAmount;
                bntToken = address(0);
            }

            emit Conversion(_path[i - 1], _path[i - 2], _path[i], fromAmount, toAmount, msg.sender);
            fromAmount = toAmount;
        }

        return toAmount;
    }

    bytes4 private constant GET_RETURN_FUNC_SELECTOR = bytes4(uint256(keccak256("getReturn(address,address,uint256)") >> (256 - 4 * 8)));

    function getReturn(address _dest, address _fromToken, address _toToken, uint256 _amount) internal view returns (uint256, uint256) {
        uint256[2] memory ret;
        bytes memory data = abi.encodeWithSelector(GET_RETURN_FUNC_SELECTOR, _fromToken, _toToken, _amount);

        assembly {
            let success := staticcall(
                gas,           // gas remaining
                _dest,         // destination address
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data),   // input length (loaded from the first 32 bytes in the `data` array)
                ret,           // output buffer
                64             // output length
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        return (ret[0], ret[1]);
    }

    /**
      * @dev calculates the expected return of converting a given amount on a given path
      * note that there is no support for circular paths
      * 
      * @param _path        conversion path (see conversion path format above)
      * @param _amount      amount of _path[0] tokens received from the user
      * 
      * @return amount of _path[_path.length - 1] tokens that the user will receive
      * @return amount of _path[_path.length - 1] tokens that the user will pay as fee
    */
    function getReturnByPath(IERC20Token[] _path, uint256 _amount) public view returns (uint256, uint256) {
        uint256 amount;
        uint256 fee;
        uint256 supply;
        uint256 balance;
        uint32 ratio;
        IBancorConverter converter;
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));

        amount = _amount;

        // verify that the number of elements is larger than 2 and odd
        require(_path.length > 2 && _path.length % 2 == 1);

        // iterate over the conversion path
        for (uint256 i = 2; i < _path.length; i += 2) {
            IERC20Token fromToken = _path[i - 2];
            IERC20Token smartToken = _path[i - 1];
            IERC20Token toToken = _path[i];

            if (toToken == smartToken) { // buy the smart token
                // check if the current smart token has changed
                if (i < 3 || smartToken != _path[i - 3]) {
                    supply = smartToken.totalSupply();
                    converter = IBancorConverter(ISmartToken(smartToken).owner());
                }

                // calculate the amount & the conversion fee
                balance = converter.getConnectorBalance(fromToken);
                (, ratio, , , ) = converter.connectors(fromToken);
                amount = formula.calculatePurchaseReturn(supply, balance, ratio, amount);
                fee = amount.mul(converter.conversionFee()).div(CONVERSION_FEE_RESOLUTION);
                amount -= fee;

                // update the smart token supply for the next iteration
                supply += amount;
            }
            else if (fromToken == smartToken) { // sell the smart token
                // check if the current smart token has changed
                if (i < 3 || smartToken != _path[i - 3]) {
                    supply = smartToken.totalSupply();
                    converter = IBancorConverter(ISmartToken(smartToken).owner());
                }

                // calculate the amount & the conversion fee
                balance = converter.getConnectorBalance(toToken);
                (, ratio, , , ) = converter.connectors(toToken);
                amount = formula.calculateSaleReturn(supply, balance, ratio, amount);
                fee = amount.mul(converter.conversionFee()).div(CONVERSION_FEE_RESOLUTION);
                amount -= fee;

                // update the smart token supply for the next iteration
                supply -= amount;
            }
            else { // cross reserve conversion
                // check if the current smart token has changed
                if (i < 3 || smartToken != _path[i - 3]) {
                    converter = IBancorConverter(ISmartToken(smartToken).owner());
                }

                (amount, fee) = getReturn(converter, fromToken, toToken, amount);
            }
        }

        return (amount, fee);
    }

    /**
      * @dev claims the caller's tokens, converts them to any other token in the bancor network
      * by following a predefined conversion path and transfers the result tokens to a target account
      * note that allowance must be set beforehand
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _for                 account that will receive the conversion result
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return tokens issued in return
    */
    function claimAndConvertFor2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256) {
        // we need to transfer the tokens from the caller to the network before we follow
        // the conversion path, to allow it to execute the conversion on behalf of the caller
        // note: we assume we already have allowance
        IERC20Token fromToken = _path[0];
        ensureTransferFrom(fromToken, msg.sender, this, _amount);
        return convertFor2(_path, _amount, _minReturn, _for, _affiliateAccount, _affiliateFee);
    }

    /**
      * @dev converts the token to any other token in the bancor network by following
      * a predefined conversion path and transfers the result tokens back to the sender
      * note that the network should already own the source tokens
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return tokens issued in return
    */
    function convert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256) {
        return convertFor2(_path, _amount, _minReturn, msg.sender, _affiliateAccount, _affiliateFee);
    }

    /**
      * @dev claims the caller's tokens, converts them to any other token in the bancor network
      * by following a predefined conversion path and transfers the result tokens back to the sender
      * note that allowance must be set beforehand
      * 
      * @param _path                conversion path, see conversion path format above
      * @param _amount              amount to convert from (in the initial source token)
      * @param _minReturn           if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
      * @param _affiliateAccount    affiliate account
      * @param _affiliateFee        affiliate fee in PPM
      * 
      * @return tokens issued in return
    */
    function claimAndConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256) {
        return claimAndConvertFor2(_path, _amount, _minReturn, msg.sender, _affiliateAccount, _affiliateFee);
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
    function ensureTransferFrom(IERC20Token _token, address _from, address _to, uint256 _amount) private {
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
      * @dev utility, checks whether allowance for the given spender exists and approves one if it doesn't.
      * Note that we use the non standard erc-20 interface in which `approve` has no return value so that
      * this function will work for both standard and non standard tokens
      * 
      * @param _token   token to check the allowance in
      * @param _spender approved address
      * @param _value   allowance amount
    */
    function ensureAllowance(IERC20Token _token, address _spender, uint256 _value) private {
        uint256 allowance = _token.allowance(this, _spender);
        if (allowance < _value) {
            if (allowance > 0)
                INonStandardERC20(_token).approve(_spender, 0);
            INonStandardERC20(_token).approve(_spender, _value);
        }
    }

    function getSignature(
        uint256 _customVal,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (uint256[] memory) {
        if (_v == 0x0 && _r == 0x0 && _s == 0x0)
            return new uint256[](0);
        uint256[] memory signature = new uint256[](5);
        signature[0] = _customVal;
        signature[1] = _block;
        signature[2] = uint256(_v);
        signature[3] = uint256(_r);
        signature[4] = uint256(_s);
        return signature;
    }

    function verifyConversionParams(
        IERC20Token[] _path,
        address _sender,
        address _receiver,
        uint256[] memory _signature
    )
        private
    {
        // verify that the number of elements is odd and that maximum number of 'hops' is 10
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);

        // verify that the account which should receive the conversion result is whitelisted
        IContractFeatures features = IContractFeatures(addressOf(CONTRACT_FEATURES));
        for (uint256 i = 1; i < _path.length; i += 2) {
            IBancorConverter converter = IBancorConverter(ISmartToken(_path[i]).owner());
            if (features.isSupported(converter, FeatureIds.CONVERTER_CONVERSION_WHITELIST)) {
                IWhitelist whitelist = converter.conversionWhitelist();
                require(whitelist == address(0) || whitelist.isWhitelisted(_receiver));
            }
        }

        if (_signature.length >= 5) {
            // verify signature
            verifyTrustedSender(_path, _sender, _signature);
        }
        else {
            // verify gas price limit
            IBancorGasPriceLimit gasPriceLimit = IBancorGasPriceLimit(addressOf(BANCOR_GAS_PRICE_LIMIT));
            gasPriceLimit.validateGasPrice(tx.gasprice);
        }
    }

    function handleValue(IERC20Token _token, uint256 _amount, bool _claim) private {
        // if ETH is provided, ensure that the amount is identical to _amount, verify that the source token is an ether token and deposit the ETH in it
        if (msg.value > 0) {
            require(_amount == msg.value && etherTokens[_token]);
            IEtherToken(_token).deposit.value(msg.value)();
        }
        // Otherwise, claim the tokens from the sender if needed
        else if (_claim) {
            ensureTransferFrom(_token, msg.sender, this, _amount);
        }
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function convert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public payable returns (uint256)
    {
        return convert2(_path, _amount, _minReturn, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function claimAndConvert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public returns (uint256)
    {
        return claimAndConvert2(_path, _amount, _minReturn, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function convertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public payable returns (uint256)
    {
        return convertFor2(_path, _amount, _minReturn, _for, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function claimAndConvertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public returns (uint256)
    {
        return claimAndConvertFor2(_path, _amount, _minReturn, _for, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function xConvert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        bytes32 _toBlockchain,
        bytes32 _to,
        uint256 _conversionId
    )
        public
        payable
        returns (uint256)
    {
        return xConvert2(_path, _amount, _minReturn, _toBlockchain, _to, _conversionId, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function xConvertPrioritized2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        bytes32 _toBlockchain,
        bytes32 _to,
        uint256 _conversionId,
        uint256[] memory _signature
    )
        public
        payable
        returns (uint256)
    {
        return xConvertPrioritized3(_path, _amount, _minReturn, _toBlockchain, _to, _conversionId, _signature, address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function xConvertPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        bytes32 _toBlockchain,
        bytes32 _to,
        uint256 _conversionId,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        // workaround the 'stack too deep' compilation error
        uint256[] memory signature = getSignature(_amount, _block, _v, _r, _s);
        return xConvertPrioritized3(_path, _amount, _minReturn, _toBlockchain, _to, _conversionId, signature, address(0), 0);
        // return xConvertPrioritized3(_path, _amount, _minReturn, _toBlockchain, _to, _conversionId, getSignature(_amount, _block, _v, _r, _s), address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
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
    )
        public
        payable
        returns (uint256)
    {
        return convertForPrioritized4(_path, _amount, _minReturn, _for, getSignature(_customVal, _block, _v, _r, _s), address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function convertForPrioritized2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        return convertForPrioritized4(_path, _amount, _minReturn, _for, getSignature(_amount, _block, _v, _r, _s), address(0), 0);
    }

    /**
      * @dev deprecated, backward compatibility
    */
    function convertForPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s)
        public payable returns (uint256)
    {
        _nonce;
        return convertForPrioritized4(_path, _amount, _minReturn, _for, getSignature(_amount, _block, _v, _r, _s), address(0), 0);
    }
}