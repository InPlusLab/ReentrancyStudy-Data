/**

 *Submitted for verification at Etherscan.io on 2019-03-13

*/



pragma solidity ^0.4.12;

 

contract IMigrationContract {

    function migrate(address addr, uint256 nas) returns (bool success);

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

 

contract OBTToken is StandardToken {

 

    // metadata

    string  public constant name = "OBT";

    string  public constant symbol = "OBT";

    uint256 public constant decimals = 18;

    string  public version = "2.0";

 

    // contracts

    address public ethFundDeposit;          // ETH存放地址

    address public newContractAddr;         // token更新地址

 

    // crowdsale parameters

    bool    public isFunding;                // 状态切换到true

    uint256 public fundingStartBlock;

    uint256 public fundingStopBlock;

 

    uint256 public currentSupply;           // 正在售卖中的tokens数量

    uint256 public tokenRaised = 0;         // 总的售卖数量token

    uint256 public tokenMigrated = 0;     // 总的已经交易的 token

    uint256 public tokenExchangeRate = 625;             // 625 BILIBILI 兑换 1 ETH

 

    // events

    event AllocateToken(address indexed _to, uint256 _value);   // 分配的私有交易token;

    event IssueToken(address indexed _to, uint256 _value);      // 公开发行售卖的token;

    event IncreaseSupply(uint256 _value);

    event DecreaseSupply(uint256 _value);

    event Migrate(address indexed _to, uint256 _value);

 

    // 转换

    function formatDecimals(uint256 _value) internal returns (uint256 ) {

        return _value * 10 ** decimals;

    }

 

    // constructor

    function OBTToken(

        address _ethFundDeposit,

        uint256 _currentSupply)

    {

        ethFundDeposit = _ethFundDeposit;

 

        isFunding = false;                           //通过控制预CrowdS ale状态

        fundingStartBlock = 0;

        fundingStopBlock = 0;

 

        currentSupply = formatDecimals(_currentSupply);

        totalSupply = formatDecimals(10000000);

        balances[msg.sender] = totalSupply;

        if(currentSupply > totalSupply) throw;

    }

 

    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

 



    //  启动区块检测 异常的处理

    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {

        if (isFunding) throw;

        if (_fundingStartBlock >= _fundingStopBlock) throw;

        if (block.number >= _fundingStartBlock) throw;

 

        fundingStartBlock = _fundingStartBlock;

        fundingStopBlock = _fundingStopBlock;

        isFunding = true;

    }

 

    // 关闭区块异常处理

    function stopFunding() isOwner external {

        if (!isFunding) throw;

        isFunding = false;

    }

 



 

    // 设置新的所有者地址

    function changeOwner(address _newFundDeposit) isOwner() external {

        if (_newFundDeposit == address(0x0)) throw;

        ethFundDeposit = _newFundDeposit;

    }







}