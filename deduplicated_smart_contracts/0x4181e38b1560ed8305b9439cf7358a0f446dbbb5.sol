/**
 *Submitted for verification at Etherscan.io on 2020-02-23
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
}

// File: contracts/bot/Owned.sol

pragma solidity 0.4.26;

contract Owned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address _prevOwner, address _newOwner);

    constructor () public { owner = msg.sender; }

    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner) public ownerOnly {
        require(_newOwner != owner && _newOwner != address(0), "Unauthorized");
        emit OwnerUpdate(owner, _newOwner);
        owner = _newOwner;
        newOwner = address(0);
    }

    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner, "Invalid");
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner, "Unauthorized");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

// File: solidity/contracts/bot/ArbBot.sol

pragma solidity 0.4.26;





contract ArbBot is Owned {
    
    IERC20Token public tokenBNT;
    IERC20Token public tokenUSDB;
    IERC20Token public tokenSAI;
    IERC20Token public tokenPEGUSD;

    ISmartToken public relayUSDB;
    ISmartToken public relaySAI;
    ISmartToken public relayPEGUSD;

    uint256 public tradeValue = 200 ether;
    uint256 public threshold = 0;

    constructor (
        IERC20Token _tokenBNT,
        IERC20Token _tokenSAI,
        IERC20Token _tokenUSDB,
        IERC20Token _tokenPEGUSD,
        ISmartToken _relayUSDB,
        ISmartToken _relaySAI,
        ISmartToken _relayPEGUSD
    ) public {
        tokenBNT = _tokenBNT;
        tokenSAI = _tokenSAI;
        tokenUSDB = _tokenUSDB;
        tokenPEGUSD = _tokenPEGUSD;

        relayUSDB = _relayUSDB;
        relaySAI = _relaySAI;
        relayPEGUSD = _relayPEGUSD;
    }

    function getReturnSAI (bool _fromUSDB) public view returns(uint256) {
        IERC20Token tokenUSD = (_fromUSDB == true) ? tokenUSDB : tokenPEGUSD;
        ISmartToken relayUSD = (_fromUSDB == true) ? relayUSDB : relayPEGUSD;
        IBancorConverter converterSAI = IBancorConverter(relaySAI.owner());
        uint256 returnBNT;
        IBancorConverter converterUSDB = IBancorConverter(relayUSD.owner());
        (returnBNT, ) = converterUSDB.getReturn(tokenUSD, tokenBNT, tradeValue);
        uint256 returnSAI;
        (returnSAI, ) = converterSAI.getReturn(tokenBNT, tokenSAI, returnBNT);
        return returnSAI;
    }

    function getReturnUSD (bool _fromUSDB) public view returns(uint256) {
        IERC20Token tokenUSD = (_fromUSDB == true) ? tokenUSDB : tokenPEGUSD;
        ISmartToken relayUSD = (_fromUSDB == true) ? relayUSDB : relayPEGUSD;
        IBancorConverter converterSAI = IBancorConverter(relaySAI.owner());
        uint256 returnBNT;
        (returnBNT, ) = converterSAI.getReturn(tokenSAI, tokenBNT, tradeValue);
        uint256 returnUSD;
        IBancorConverter converterUSDB = IBancorConverter(relayUSD.owner());
        (returnUSD, ) = converterUSDB.getReturn(tokenBNT, tokenUSD, returnBNT);
        return returnUSD;
    }

    function isReadyToTrade(bool _fromUSDB) public view returns(bool) {
        uint256 returnUSD = getReturnUSD(_fromUSDB);
        uint256 returnSAI = getReturnSAI(_fromUSDB);
        if(returnSAI > tradeValue) {
            return ((returnSAI - tradeValue) >= threshold);
        } else {
            if(returnUSD > tradeValue)
                return ((returnUSD - tradeValue) >= threshold);
            else
                return false;
        }
    }

    function trade(bool _fromUSDB) public returns(bool) {
        IERC20Token tokenUSD = (_fromUSDB == true) ? tokenUSDB : tokenPEGUSD;
        ISmartToken relayUSD = (_fromUSDB == true) ? relayUSDB : relayPEGUSD;
        IBancorConverter converterUSD = (_fromUSDB == true) ? IBancorConverter(relayUSD.owner()) : IBancorConverter(relayUSD.owner());
        IBancorConverter converterSAI = IBancorConverter(relaySAI.owner());

        uint256 returnUSD = getReturnUSD(_fromUSDB);
        uint256 returnSAI = getReturnSAI(_fromUSDB);
        IERC20Token[] memory path = new IERC20Token[](5);
        if(returnSAI > tradeValue) {
            require((returnSAI - tradeValue) >= threshold, 'Trade not yet available.');
            require(tokenUSD.balanceOf(address(this)) >= tradeValue, 'Insufficient USD balance.');
            // [tokenUSD, relayUSD, tokenBNT, relaySAI, tokenSAI];
            path[0] = tokenUSD;
            path[1] = IERC20Token(relayUSD);
            path[2] = tokenBNT;
            path[3] = IERC20Token(relaySAI);
            path[4] = tokenSAI;
            converterUSD.quickConvert(path, tradeValue, tradeValue);
        } else {
            require(returnUSD > tradeValue, 'Trade not yet available.');
            require((returnUSD - tradeValue) >= threshold, 'Trade not yet available.');
            require(tokenSAI.balanceOf(address(this)) >= tradeValue, 'Insufficient SAI balance.');
            // [tokenSAI, relaySAI, tokenBNT, relayUSD, tokenUSD];
            path[0] = tokenSAI;
            path[1] = IERC20Token(relaySAI);
            path[2] = tokenBNT;
            path[3] = IERC20Token(relayUSD);
            path[4] = tokenUSD;
            converterSAI.quickConvert(path, tradeValue, tradeValue);
        }
        return true;
    }

    function unlockTokens() public {
        tokenUSDB.approve(address(relayUSDB.owner()), 0);
        tokenUSDB.approve(address(relayUSDB.owner()), 1000000 ether);

        tokenSAI.approve(address(relaySAI.owner()), 0);
        tokenSAI.approve(address(relaySAI.owner()), 1000000 ether);

        tokenPEGUSD.approve(address(relayPEGUSD.owner()), 0);
        tokenPEGUSD.approve(address(relayPEGUSD.owner()), 1000000 ether);
    }

    function updateTradeValue(uint256 _tradeValue) public ownerOnly {
        tradeValue = _tradeValue;
    }

    function updateThreshold(uint256 _threshold) public ownerOnly {
        threshold = _threshold;
    }

    function updateTokens(
        IERC20Token _tokenBNT,
        IERC20Token _tokenSAI,
        IERC20Token _tokenUSDB,
        IERC20Token _tokenPEGUSD
    ) public ownerOnly {
        tokenBNT = _tokenBNT;
        tokenSAI = _tokenSAI;
        tokenUSDB = _tokenUSDB;
        tokenPEGUSD = _tokenPEGUSD;
    }

    function updateRelays(
        ISmartToken _relayUSDB,
        ISmartToken _relaySAI,
        ISmartToken _relayPEGUSD
    ) public ownerOnly {
        relayUSDB = _relayUSDB;
        relaySAI = _relaySAI;
        relayPEGUSD = _relayPEGUSD;
    }

    function transferERC20Token(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {
        _token.transfer(_to, _amount);
    }

    function() public payable {}
    
}