/**

 *Submitted for verification at Etherscan.io on 2018-10-12

*/



pragma solidity ^0.4.23;

contract Token{

    // token������Ĭ�ϻ�Ϊpublic��������һ��getter�����ӿڣ�����ΪtotalSupply().

    uint256 public totalSupply;



    /// ��ȡ�˻�_ownerӵ��token������ 

    function balanceOf(address _owner) constant returns (uint256 balance);



    //����Ϣ�������˻�����_to�˻�ת����Ϊ_value��token

    function transfer(address _to, uint256 _value) returns (bool success);



    //���˻�_from�����˻�_toת����Ϊ_value��token����approve�������ʹ��

    function transferFrom(address _from, address _to, uint256 _value) returns   

    (bool success);



    //��Ϣ�����˻������˻�_spender�ܴӷ����˻���ת������Ϊ_value��token

    function approve(address _spender, uint256 _value) returns (bool success);



    //��ȡ�˻�_spender���Դ��˻�_owner��ת��token������ 

    function allowance(address _owner, address _spender) constant returns 

    (uint256 remaining);



    //����ת��ʱ����Ҫ�������¼� 

    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    //������approve(address _spender, uint256 _value)�ɹ�ִ��ʱ���봥�����¼�

    event Approval(address indexed _owner, address indexed _spender, uint256 

    _value);

}



library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



contract StandardToken is Token {

    using SafeMath for uint256;

    function transfer(address _to, uint256 _value) returns (bool success) {

        require(_to != address(0));

        require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);//����Ϣ�������˻��м�ȥtoken����_value

        balances[_to] = balances[_to].add(_value);//�������˻�����token����_value

        Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�

        return true;

    }





    function transferFrom(address _from, address _to, uint256 _value) returns 

    (bool success) {

        require(_to != address(0));

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] = balances[_to].add(_value);//�����˻�����token����_value

        balances[_from] = balances[_from].sub(_value); //֧���˻�_from��ȥtoken����_value

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);//��Ϣ�����߿��Դ��˻�_from��ת������������_value

        Transfer(_from, _to, _value);//����ת�ҽ����¼�

        return true;

    }

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }





    function approve(address _spender, uint256 _value) returns (bool success)   

    {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }





    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];//����_spender��_owner��ת����token��

    }

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract HumanStandardToken is StandardToken { 



    /* Public variables of the token */

    string public name;                   //����: eg Simon Bucks

    uint8 public decimals;               //����С��λ����How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.

    string public symbol;               //token���: eg SBX

    string public version = 'H0.1';    //�汾



    function HumanStandardToken(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) {

        balances[msg.sender] = _initialAmount; // ��ʼtoken����������Ϣ������

        totalSupply = _initialAmount;         // ���ó�ʼ����

        name = _tokenName;                   // token����

        decimals = _decimalUnits;           // С��λ��

        symbol = _tokenSymbol;             // token���

    }



    /* Approves and then calls the receiving contract */

    

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.

        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)

        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.

        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));

        return true;

    }



}