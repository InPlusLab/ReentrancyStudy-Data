/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

pragma solidity 0.4.26;

// File: contracts/converter/interfaces/IBancorConverterRegistry.sol

contract IBancorConverterRegistry {
    function tokens(uint256 _index) public view returns (address) { _index; }
    function tokenCount() public view returns (uint256);
    function converterCount(address _token) public view returns (uint256);
    function converterAddress(address _token, uint32 _index) public view returns (address);
    function latestConverterAddress(address _token) public view returns (address);
    function tokenAddress(address _converter) public view returns (address);
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

// File: contracts/utility/Owned.sol

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

// File: contracts\converter\BancorConverterRegistry.sol

/**
  * @dev Bancor Converter Registry
  * 
  * The Bancor Converter Registry keeps converter addresses by token addresses and vice versa. The owner can update converter addresses so that the token address always points to the updated list of converters for each token. 
  * 
  * The contract is also able to iterate through all the tokens in the network. 
  * 
  * Note that converter addresses for each token are returned in ascending order (from oldest to newest).
  * 
*/
contract BancorConverterRegistry is IBancorConverterRegistry, Owned, Utils {
    mapping (address => address[]) private tokensToConverters;  // token address -> converter addresses
    mapping (address => address) private convertersToTokens;    // converter address -> token address
    address[] public tokens;                                    // list of all token addresses

    struct TokenInfo {
        bool valid;
        uint256 index;
    }

    mapping(address => TokenInfo) public tokenTable;

    /**
      * @dev triggered when a token is added to the registry
      * 
      * @param _token   token
    */
    event TokenAddition(address indexed _token);

    /**
      * @dev triggered when a token is removed from the registry
      * 
      * @param _token   token
    */
    event TokenRemoval(address indexed _token);

    /**
      * @dev triggered when a converter is added to the registry
      * 
      * @param _token   token
      * @param _address converter
    */
    event ConverterAddition(address indexed _token, address _address);

    /**
      * @dev triggered when a converter is removed from the registry
      * 
      * @param _token   token
      * @param _address converter
    */
    event ConverterRemoval(address indexed _token, address _address);

    /**
      * @dev initializes a new BancorConverterRegistry instance
    */
    constructor() public {
    }

    /**
      * @dev returns the number of tokens in the registry
      * 
      * @return number of tokens
    */
    function tokenCount() public view returns (uint256) {
        return tokens.length;
    }

    /**
      * @dev returns the number of converters associated with the given token
      * or 0 if the token isn't registered
      * 
      * @param _token   token address
      * 
      * @return number of converters
    */
    function converterCount(address _token) public view returns (uint256) {
        return tokensToConverters[_token].length;
    }

    /**
      * @dev returns the converter address associated with the given token
      * or zero address if no such converter exists
      * 
      * @param _token   token address
      * @param _index   converter index
      * 
      * @return converter address
    */
    function converterAddress(address _token, uint32 _index) public view returns (address) {
        if (tokensToConverters[_token].length > _index)
            return tokensToConverters[_token][_index];

        return address(0);
    }

    /**
      * @dev returns the latest converter address associated with the given token
      * or zero address if no such converter exists
      * 
      * @param _token   token address
      * 
      * @return latest converter address
    */
    function latestConverterAddress(address _token) public view returns (address) {
        if (tokensToConverters[_token].length > 0)
            return tokensToConverters[_token][tokensToConverters[_token].length - 1];

        return address(0);
    }

    /**
      * @dev returns the token address associated with the given converter
      * or zero address if no such converter exists
      * 
      * @param _converter   converter address
      * 
      * @return token address
    */
    function tokenAddress(address _converter) public view returns (address) {
        return convertersToTokens[_converter];
    }

    /**
      * @dev adds a new converter address for a given token to the registry
      * throws if the converter is already registered
      * 
      * @param _token       token address
      * @param _converter   converter address
    */
    function registerConverter(address _token, address _converter)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_converter)
    {
        require(convertersToTokens[_converter] == address(0));

        // add the token to the list of tokens if needed
        TokenInfo storage tokenInfo = tokenTable[_token];
        if (tokenInfo.valid == false) {
            tokenInfo.valid = true;
            tokenInfo.index = tokens.push(_token) - 1;
            emit TokenAddition(_token);
        }

        tokensToConverters[_token].push(_converter);
        convertersToTokens[_converter] = _token;

        // dispatch the converter addition event
        emit ConverterAddition(_token, _converter);
    }

    /**
      * @dev removes an existing converter from the registry
      * note that the function doesn't scale and might be needed to be called
      * multiple times when removing an older converter from a large converter list
      * 
      * @param _token   token address
      * @param _index   converter index
    */
    function unregisterConverter(address _token, uint32 _index)
        public
        ownerOnly
        validAddress(_token)
    {
        require(_index < tokensToConverters[_token].length);

        address converter = tokensToConverters[_token][_index];

        // move all newer converters 1 position lower
        for (uint32 i = _index + 1; i < tokensToConverters[_token].length; i++) {
            tokensToConverters[_token][i - 1] = tokensToConverters[_token][i];
        }

        // decrease the number of converters defined for the token by 1
        tokensToConverters[_token].length--;

        // remove the token from the list of tokens if needed
        if (tokensToConverters[_token].length == 0) {
            TokenInfo storage tokenInfo = tokenTable[_token];
            assert(tokens.length > tokenInfo.index);
            assert(_token == tokens[tokenInfo.index]);
            address lastToken = tokens[tokens.length - 1];
            tokenTable[lastToken].index = tokenInfo.index;
            tokens[tokenInfo.index] = lastToken;
            tokens.length--;
            delete tokenTable[_token];
            emit TokenRemoval(_token);
        }

        // remove the converter from the converters -> tokens list
        delete convertersToTokens[converter];

        // dispatch the converter removal event
        emit ConverterRemoval(_token, converter);
    }
}