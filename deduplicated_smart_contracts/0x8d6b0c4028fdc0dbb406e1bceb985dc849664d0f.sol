pragma solidity ^0.4.8;
/*
AvatarNetwork Copyright

https://avatarnetwork.io

*/

/* §²§à§Õ§Ú§ä§Ö§Ý§î§ã§Ü§Ú§Û §Ü§à§ß§ä§â§Ñ§Ü§ä */
contract Owned {

    /* §¡§Õ§â§Ö§ã §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ*/
    address owner;

    /* §¬§à§ß§ã§ä§â§å§Ü§ä§à§â §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ, §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §á§â§Ú §á§Ö§â§Ó§à§Þ §Ù§Ñ§á§å§ã§Ü§Ö */
    function Owned() {
        owner = msg.sender;
    }

        /* §ª§Ù§Þ§Ö§ß§Ú§ä§î §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ, newOwner - §Ñ§Õ§â§Ö§ã §ß§à§Ó§à§Ô§à §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ */
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }


    /* §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â §Õ§Ý§ñ §à§Ô§â§Ñ§ß§Ú§é§Ö§ß§Ú§ñ §Õ§à§ã§ä§å§á§Ñ §Ü §æ§å§ß§Ü§è§Ú§ñ§Þ §ä§à§Ý§î§Ü§à §Õ§Ý§ñ §Ó§Ý§Ñ§Õ§Ö§Ý§î§è§Ñ */
    modifier onlyowner() {
        if (msg.sender==owner) _;
    }
}

// §¡§Ò§ã§ä§â§Ñ§Ü§ä§ß§í§Û §Ü§à§ß§ä§â§Ñ§Ü§ä §Õ§Ý§ñ §ä§à§Ü§Ö§ß§Ñ §ã§ä§Ñ§ß§Õ§Ñ§â§ä§Ñ ERC 20
// https://github.com/ethereum/EIPs/issues/20
contract Token is Owned {

    /// §°§Ò§ë§Ö§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó
    uint256 public totalSupply;

    /// @param _owner §Ñ§Õ§â§Ö§ã, §ã §Ü§à§ä§à§â§à§Ô§à §Ò§å§Õ§Ö§ä §á§à§Ý§å§é§Ö§ß §Ò§Ñ§Ý§Ñ§ß§ã
    /// @return §¢§Ñ§Ý§Ñ§ß§ã
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice §°§ä§á§â§Ñ§Ó§Ú§ä§î §Ü§à§Ý-§Ó§à `_value` §ä§à§Ü§Ö§ß§à§Ó §ß§Ñ §Ñ§Õ§â§Ö§ã `_to` §ã §Ñ§Õ§â§Ö§ã§Ñ `msg.sender`
    /// @param _to §¡§Õ§â§Ö§ã §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ
    /// @param _value §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Õ§Ý§ñ §à§ä§á§â§Ñ§Ó§Ü§Ú
    /// @return §¢§í§Ý§Ñ §Ý§Ú §à§ä§á§â§Ñ§Ó§Ü§Ñ §å§ã§á§Ö§ê§ß§à§Û §Ú§Ý§Ú §ß§Ö§ä
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice §°§ä§á§â§Ñ§Ó§Ú§ä§î §Ü§à§Ý-§Ó§à `_value` §ä§à§Ü§Ö§ß§à§Ó §ß§Ñ §Ñ§Õ§â§Ö§ã `_to` §ã §Ñ§Õ§â§Ö§ã§Ñ `_from` §á§â§Ú §å§ã§Ý§à§Ó§Ú§Ú §é§ä§à §ï§ä§à §á§à§Õ§ä§Ó§Ö§â§Ø§Õ§Ö§ß§à §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§Ö§Þ `_from`
    /// @param _from §¡§Õ§â§Ö§ã §à§ä§á§â§Ñ§Ó§Ú§ä§Ö§Ý§ñ
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice §£§í§Ù§í§Ó§Ñ§ð§ë§Ú§Û §æ§å§ß§Ü§è§Ú§Ú `msg.sender` §á§à§Õ§ä§Ó§Ö§â§Ø§Õ§Ñ§Ö§ä §é§ä§à §ã §Ñ§Õ§â§Ö§ã§Ñ `_spender` §ã§á§Ú§ê§Ö§ä§ã§ñ `_value` §ä§à§Ü§Ö§ß§à§Ó
    /// @param _spender §¡§Õ§â§Ö§ã §Ñ§Ü§Ü§Ñ§å§ß§ä§Ñ, §ã §Ü§à§ä§à§â§à§Ô§à §Ó§à§Ù§Þ§à§Ø§ß§à §ã§á§Ú§ã§Ñ§ä§î §ä§à§Ü§Ö§ß§í
    /// @param _value §¬§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó §Ü §á§à§Õ§ä§Ó§Ö§â§Ø§Õ§Ö§ß§Ú§ð §Õ§Ý§ñ §à§ä§á§â§Ñ§Ó§Ü§Ú
    /// @return §¢§í§Ý§à §Ý§Ú §á§à§Õ§ä§Ó§Ö§â§Ø§Õ§Ö§ß§Ú§Ö §å§ã§á§Ö§ê§ß§í§Þ §Ú§Ý§Ú §ß§Ö§ä
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner §¡§Õ§â§Ö§ã §Ñ§Ü§Ü§Ñ§å§ß§ä§Ñ §Ó§Ý§Ñ§Õ§Ö§ð§ë§Ö§Ô§à §ä§à§Ü§Ö§ß§Ñ§Þ§Ú
    /// @param _spender §¡§Õ§â§Ö§ã §Ñ§Ü§Ü§Ñ§å§ß§ä§Ñ, §ã §Ü§à§ä§à§â§à§Ô§à §Ó§à§Ù§Þ§à§Ø§ß§à §ã§á§Ú§ã§Ñ§ä§î §ä§à§Ü§Ö§ß§í
    /// @return §¬§à§Ý-§Ó§à §à§ã§ä§Ñ§Ó§ê§Ú§ç§ã§ñ §ä§à§Ü§Ö§ß§à§Ó §â§Ñ§Ù§â§Ö§ê§×§ß§ß§í§ç §Õ§Ý§ñ §à§ä§á§â§Ñ§Ó§Ü§Ú
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
§¬§à§ß§ä§â§Ñ§Ü§ä §â§Ö§Ñ§Ý§Ú§Ù§å§Ö§ä ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20Token is Token
{

    function transfer(address _to, uint256 _value) returns (bool success)
    {
        //§±§à-§å§Þ§à§Ý§é§Ñ§ß§Ú§ð §á§â§Ö§Õ§á§à§Ý§Ñ§Ô§Ñ§Ö§ä§ã§ñ, §é§ä§à totalSupply §ß§Ö §Þ§à§Ø§Ö§ä §Ò§í§ä§î §Ò§à§Ý§î§ê§Ö (2^256 - 1).
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
    {
        //§±§à-§å§Þ§à§Ý§é§Ñ§ß§Ú§ð §á§â§Ö§Õ§á§à§Ý§Ñ§Ô§Ñ§Ö§ä§ã§ñ, §é§ä§à totalSupply §ß§Ö §Þ§à§Ø§Ö§ä §Ò§í§ä§î §Ò§à§Ý§î§ê§Ö (2^256 - 1).
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

/* §°§ã§ß§à§Ó§ß§à§Û §Ü§à§ß§ä§â§Ñ§Ü§ä §ä§à§Ü§Ö§ß§Ñ, §ß§Ñ§ã§Ý§Ö§Õ§å§Ö§ä ERC20Token */
contract ArmMoneyliFe is ERC20Token
{
    bool public isTokenSale = true;
    uint256 public price;
    uint256 public limit;

    address walletOut = 0xde8c00ae50b203ac1091266d5b207fbc59be5bc4;

    function getWalletOut() constant returns (address _to) {
        return walletOut;
    }

    function () external payable  {
        if (isTokenSale == false) {
            throw;
        }

        uint256 tokenAmount = (msg.value  * 1000000000000000000) / price;

        if (balances[owner] >= tokenAmount && balances[msg.sender] + tokenAmount > balances[msg.sender]) {
            if (balances[owner] - tokenAmount < limit) {
                throw;
            }
            balances[owner] -= tokenAmount;
            balances[msg.sender] += tokenAmount;
            Transfer(owner, msg.sender, tokenAmount);
        } else {
            throw;
        }
    }

    function stopSale() onlyowner {
        isTokenSale = false;
    }

    function startSale() onlyowner {
        isTokenSale = true;
    }

    function setPrice(uint256 newPrice) onlyowner {
        price = newPrice;
    }

    function setLimit(uint256 newLimit) onlyowner {
        limit = newLimit;
    }

    function setWallet(address _to) onlyowner {
        walletOut = _to;
    }

    function sendFund() onlyowner {
        walletOut.send(this.balance);
    }

    /* §±§å§Ò§Ý§Ú§é§ß§í§Ö §á§Ö§â§Ö§Þ§Ö§ß§ß§í§Ö §ä§à§Ü§Ö§ß§Ñ */
    string public name;                 // §¯§Ñ§Ù§Ó§Ñ§ß§Ú§Ö
    uint8 public decimals;              // §³§Ü§à§Ý§î§Ü§à §Õ§Ö§ã§ñ§ä§Ú§é§ß§í§ç §Ù§ß§Ñ§Ü§à§Ó
    string public symbol;               // §ª§Õ§Ö§ß§ä§Ú§æ§Ú§Ü§Ñ§ä§à§â (§ä§â§Ö§ç§Ò§å§Ü§Ó§Ö§ß§ß§í§Û §à§Ò§í§é§ß§à)
    string public version = '1.0';      // §£§Ö§â§ã§Ú§ñ

    function ArmMoneyliFe()
    {
        totalSupply = 1000000000000000000000000000;
        balances[msg.sender] = 1000000000000000000000000000;  // §±§Ö§â§Ö§Õ§Ñ§é§Ñ §ã§à§Ù§Õ§Ñ§ä§Ö§Ý§ð §Ó§ã§Ö§ç §Ó§í§á§å§ë§Ö§ß§ß§í§ç §Þ§à§ß§Ö§ä
        name = 'ArmMoneyliFe';
        decimals = 18;
        symbol = 'AMF';
        price = 2188183807439824;
        limit = 0;
    }

    
    /* §¥§à§Ò§Ñ§Ó§Ý§ñ§Ö§ä §ß§Ñ §ã§é§Ö§ä §ä§à§Ü§Ö§ß§à§Ó */
    function add(uint256 _value) onlyowner returns (bool success)
    {
        if (balances[msg.sender] + _value <= balances[msg.sender]) {
            return false;
        }
        totalSupply += _value;
        balances[msg.sender] += _value;
        return true;
    }


    
}