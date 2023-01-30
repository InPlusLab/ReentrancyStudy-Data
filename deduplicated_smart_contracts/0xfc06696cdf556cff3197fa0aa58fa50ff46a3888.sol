/**

 *Submitted for verification at Etherscan.io on 2018-08-19

*/



pragma solidity ^0.4.12;





/* JetQe  */







contract IMigrationContract {

    function migrate(address addr, uint256 nas) returns (bool success);

}

 

/* safe computing */

contract SafeMath {

 

 

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {

        uint256 z = x + y;

        assert((z >= x) && (z >= y));

        return z;

    }

 

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {

        assert(x >= y);

        uint256 z = x - y;

        return z;

    }

 

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {

        uint256 z = x * y;

        assert((x == 0)||(z/x == y));

        return z;

    }

 

}

 

contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

 

 

/*  ERC 20 token */

contract StandardToken is Token {

 

    function transfer(address _to, uint256 _value) returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } else {

            return false;

        }

    }

 

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;

        } else {

            return false;

        }

    }

 

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }

 

    function approve(address _spender, uint256 _value) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }

 

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

 

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}

 

contract DEJToken is StandardToken, SafeMath {

 

    // metadata

    string  public constant name = "De Home";

    string  public constant symbol = "DEJ";

    uint256 public constant decimals = 18;

    string  public version = "1.0";

 

    // contracts

    address public ethFundDeposit;          // ETH��ŵ�ַ

    address public newContractAddr;         // token���µ�ַ

 

    // crowdsale parameters

    bool    public isFunding;                // ״̬�л���true

    uint256 public fundingStartBlock;

    uint256 public fundingStopBlock;

 

    uint256 public currentSupply;           // ���������е�tokens����

    uint256 public tokenRaised = 0;         // �ܵ���������token

    uint256 public tokenMigrated = 0;     // �ܵ��Ѿ����׵� token

 

    // events



    event IncreaseSupply(uint256 _value);

    event DecreaseSupply(uint256 _value);

 

    // transfer

    function formatDecimals(uint256 _value) internal returns (uint256 ) {

        return _value * 10 ** decimals;

    }

 

    // constructor

    function DEJToken()

    {

        ethFundDeposit  = 0x697e6C6845212AE294E55E0adB13977de0F0BD37;

 

        isFunding = false;                           //ͨ������ԤCrowdS ale״̬

        fundingStartBlock = 0;

        fundingStopBlock = 0;

 

        currentSupply = formatDecimals(1000000000);

        totalSupply = formatDecimals(1000000000);

        balances[msg.sender] = totalSupply;

        if(currentSupply > totalSupply) throw;

    }

 

    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

    



 

    /// @dev ����token����

    function increaseSupply (uint256 _value) isOwner external {

        uint256 value = formatDecimals(_value);

        if (value + currentSupply > totalSupply) throw;

        currentSupply = safeAdd(currentSupply, value);

        IncreaseSupply(value);

    }

 

    /// @dev ����token����

    function decreaseSupply (uint256 _value) isOwner external {

        uint256 value = formatDecimals(_value);

        if (value + tokenRaised > currentSupply) throw;

 

        currentSupply = safeSubtract(currentSupply, value);

        DecreaseSupply(value);

    }

 

    ///  ���������� �쳣�Ĵ���

    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {

        if (isFunding) throw;

        if (_fundingStartBlock >= _fundingStopBlock) throw;

        if (block.number >= _fundingStartBlock) throw;

 

        fundingStartBlock = _fundingStartBlock;

        fundingStopBlock = _fundingStopBlock;

        isFunding = true;

    }

 

    ///  �ر������쳣����

    function stopFunding() isOwner external {

        if (!isFunding) throw;

        isFunding = false;

    }

 



 

    /// ת��ETH ��Exin

    function transferETH() isOwner external {

        if (this.balance == 0) throw;

        if (!ethFundDeposit.send(this.balance)) throw;

    }

}