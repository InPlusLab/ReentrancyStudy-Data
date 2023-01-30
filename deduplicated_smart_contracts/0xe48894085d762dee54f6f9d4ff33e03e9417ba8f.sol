pragma solidity ^0.4.16;

contract Token{

    uint256 public totalSupply;



    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns   

    (bool success);



    function approve(address _spender, uint256 _value) public returns (bool success);



    function allowance(address _owner, address _spender) public constant returns 

    (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 

    _value);

}



contract TTNCoin is Token {



    string public constant name = "TTN";                   

    uint8 public constant decimals = 2; 

    string public constant symbol = "TTN";



    function TTNCoin(uint256 _initialAmount) public {

        totalSupply = _initialAmount * 10 ** uint256(decimals);         // 设置初始总量

        balances[msg.sender] = totalSupply; // 初始token数量给予消息发送者，因为是构造函数，所以这里也是合约的创建者

    }



    function transfer(address _to, uint256 _value) public returns (bool success) {

        //默认totalSupply 不会超过最大值 (2^256 - 1).

        //如果随着时间的推移将会有新的token生成，则可以用下面这句避免溢出的异常

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(_to != 0x0);

        balances[msg.sender] -= _value;//从消息发送者账户中减去token数量_value

        balances[_to] += _value;//往接收账户增加token数量_value

        Transfer(msg.sender, _to, _value);//触发转币交易事件

        return true;

    }





    function transferFrom(address _from, address _to, uint256 _value) public returns 

    (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;//接收账户增加token数量_value

        balances[_from] -= _value; //支出账户_from减去token数量_value

        allowed[_from][msg.sender] -= _value;//消息发送者可以从账户_from中转出的数量减少_value

        Transfer(_from, _to, _value);//触发转币交易事件

        return true;

    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];

    }





    function approve(address _spender, uint256 _value) public returns (bool success)   

    { 

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];//允许_spender从_owner中转出的token数

    }

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}