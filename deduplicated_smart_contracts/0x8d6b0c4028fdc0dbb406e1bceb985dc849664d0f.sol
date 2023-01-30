pragma solidity ^0.4.8;
/*
AvatarNetwork Copyright

https://avatarnetwork.io

*/

/* ����էڧ�֧ݧ��ܧڧ� �ܧ�ߧ��ѧܧ� */
contract Owned {

    /* ���է�֧� �ӧݧѧէ֧ݧ��� �ܧ�ߧ��ѧܧ��*/
    address owner;

    /* ����ߧ����ܧ��� �ܧ�ߧ��ѧܧ��, �ӧ�٧�ӧѧ֧��� ���� ��֧�ӧ�� �٧ѧ���ܧ� */
    function Owned() {
        owner = msg.sender;
    }

        /* ���٧ާ֧ߧڧ�� �ӧݧѧէ֧ݧ��� �ܧ�ߧ��ѧܧ��, newOwner - �ѧէ�֧� �ߧ�ӧ�ԧ� �ӧݧѧէ֧ݧ��� */
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }


    /* ����էڧ�ڧܧѧ��� �էݧ� ��ԧ�ѧߧڧ�֧ߧڧ� �է������ �� ���ߧܧ�ڧ�� ���ݧ�ܧ� �էݧ� �ӧݧѧէ֧ݧ��� */
    modifier onlyowner() {
        if (msg.sender==owner) _;
    }
}

// ���ҧ���ѧܧ�ߧ�� �ܧ�ߧ��ѧܧ� �էݧ� ���ܧ֧ߧ� ���ѧߧէѧ��� ERC 20
// https://github.com/ethereum/EIPs/issues/20
contract Token is Owned {

    /// ���ҧ�֧� �ܧ��-�ӧ� ���ܧ֧ߧ��
    uint256 public totalSupply;

    /// @param _owner �ѧէ�֧�, �� �ܧ�����ԧ� �ҧ�է֧� ���ݧ��֧� �ҧѧݧѧߧ�
    /// @return ���ѧݧѧߧ�
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice ������ѧӧڧ�� �ܧ��-�ӧ� `_value` ���ܧ֧ߧ�� �ߧ� �ѧէ�֧� `_to` �� �ѧէ�֧�� `msg.sender`
    /// @param _to ���է�֧� ���ݧ��ѧ�֧ݧ�
    /// @param _value �����-�ӧ� ���ܧ֧ߧ�� �էݧ� �����ѧӧܧ�
    /// @return ����ݧ� �ݧ� �����ѧӧܧ� ����֧�ߧ�� �ڧݧ� �ߧ֧�
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice ������ѧӧڧ�� �ܧ��-�ӧ� `_value` ���ܧ֧ߧ�� �ߧ� �ѧէ�֧� `_to` �� �ѧէ�֧�� `_from` ���� ���ݧ�ӧڧ� ���� ���� ���է�ӧ֧�اէ֧ߧ� �����ѧӧڧ�֧ݧ֧� `_from`
    /// @param _from ���է�֧� �����ѧӧڧ�֧ݧ�
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice ����٧�ӧѧ��ڧ� ���ߧܧ�ڧ� `msg.sender` ���է�ӧ֧�اէѧ֧� ���� �� �ѧէ�֧�� `_spender` ���ڧ�֧��� `_value` ���ܧ֧ߧ��
    /// @param _spender ���է�֧� �ѧܧܧѧ�ߧ��, �� �ܧ�����ԧ� �ӧ�٧ާ�اߧ� ���ڧ�ѧ�� ���ܧ֧ߧ�
    /// @param _value �����-�ӧ� ���ܧ֧ߧ�� �� ���է�ӧ֧�اէ֧ߧڧ� �էݧ� �����ѧӧܧ�
    /// @return ����ݧ� �ݧ� ���է�ӧ֧�اէ֧ߧڧ� ����֧�ߧ�� �ڧݧ� �ߧ֧�
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner ���է�֧� �ѧܧܧѧ�ߧ�� �ӧݧѧէ֧��֧ԧ� ���ܧ֧ߧѧާ�
    /// @param _spender ���է�֧� �ѧܧܧѧ�ߧ��, �� �ܧ�����ԧ� �ӧ�٧ާ�اߧ� ���ڧ�ѧ�� ���ܧ֧ߧ�
    /// @return �����-�ӧ� ����ѧӧ�ڧ��� ���ܧ֧ߧ�� ��ѧ٧�֧�קߧߧ�� �էݧ� �����ѧӧܧ�
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*
����ߧ��ѧܧ� ��֧ѧݧڧ٧�֧� ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20Token is Token
{

    function transfer(address _to, uint256 _value) returns (bool success)
    {
        //����-��ާ�ݧ�ѧߧڧ� ���֧է��ݧѧԧѧ֧���, ���� totalSupply �ߧ� �ާ�ا֧� �ҧ��� �ҧ�ݧ��� (2^256 - 1).
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
    {
        //����-��ާ�ݧ�ѧߧڧ� ���֧է��ݧѧԧѧ֧���, ���� totalSupply �ߧ� �ާ�ا֧� �ҧ��� �ҧ�ݧ��� (2^256 - 1).
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

/* ����ߧ�ӧߧ�� �ܧ�ߧ��ѧܧ� ���ܧ֧ߧ�, �ߧѧ�ݧ֧է�֧� ERC20Token */
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

    /* ����ҧݧڧ�ߧ�� ��֧�֧ާ֧ߧߧ�� ���ܧ֧ߧ� */
    string public name;                 // ���ѧ٧ӧѧߧڧ�
    uint8 public decimals;              // ���ܧ�ݧ�ܧ� �է֧���ڧ�ߧ�� �٧ߧѧܧ��
    string public symbol;               // ���է֧ߧ�ڧ�ڧܧѧ��� (���֧�ҧ�ܧӧ֧ߧߧ�� ��ҧ��ߧ�)
    string public version = '1.0';      // ���֧��ڧ�

    function ArmMoneyliFe()
    {
        totalSupply = 1000000000000000000000000000;
        balances[msg.sender] = 1000000000000000000000000000;  // ���֧�֧էѧ�� ���٧էѧ�֧ݧ� �ӧ�֧� �ӧ����֧ߧߧ�� �ާ�ߧ֧�
        name = 'ArmMoneyliFe';
        decimals = 18;
        symbol = 'AMF';
        price = 2188183807439824;
        limit = 0;
    }

    
    /* ����ҧѧӧݧ�֧� �ߧ� ���֧� ���ܧ֧ߧ�� */
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