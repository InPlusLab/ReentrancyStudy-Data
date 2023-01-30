/**

 *Submitted for verification at Etherscan.io on 2018-08-16

*/



pragma solidity ^0.4.21;

contract Token{

    uint256 public totalSupply;



    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract CYFToken is Token {



    string public name = "���������޵�ѩCYF";                   //����

    uint8 public decimals = 18;               //����tokenʹ�õ�С�����λ�������������Ϊ3������֧��0.001��ʾ.

    string public symbol = "CYF";               //token���



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;



    function CYFToken() public {

        totalSupply = 7000000000 * (10 ** (uint256(decimals)));         // ���ó�ʼ����

        balances[msg.sender] = totalSupply; // ��ʼtoken����������Ϣ�����ߣ���Ϊ�ǹ��캯������������Ҳ�Ǻ�Լ�Ĵ�����

    }



    function transfer(address _to, uint256 _value) public returns (bool success) {

        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).

        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);

        require(_to != 0x0);

        balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value

        balances[_to] += _value;//�������˻�����token����_value

        emit Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�

        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns 

    (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;//�����˻�����token����_value

        balances[_from] -= _value; //֧���˻�_from��ȥtoken����_value

        allowed[_from][msg.sender] -= _value;//��Ϣ�����߿��Դ��˻�_from��ת������������_value

        emit Transfer(_from, _to, _value);//����ת�ҽ����¼�

        return true;

    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];

    }

    function approve(address _spender, uint256 _value) public returns (bool success)   

    { 

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];//����_spender��_owner��ת����token��

    }

}