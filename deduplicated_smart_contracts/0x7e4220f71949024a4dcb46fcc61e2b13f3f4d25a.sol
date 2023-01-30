pragma solidity ^0.4.24;
contract Token{
    // token������Ĭ�ϻ�Ϊpublic��������һ��getter�����ӿڣ�����ΪtotalSupply().
    uint256 public constant _totalSupply=1000000000 ether;
    uint256 public currentTotalAirDrop=0;
    uint256 public totalAirDrop;
    uint256 public airdropNum=1000 ether;

    /// ��ȡ�˻�_ownerӵ��token������ 
    function balanceOf(address _owner) constant returns (uint256 balance);

    //����Ϣ�������˻�����_to�˻�ת����Ϊ_value��token
    function transfer(address _to, uint256 _value) returns (bool success);

    //���˻�_from�����˻�_toת����Ϊ_value��token����approve�������ʹ��
    function transferFrom(address _from, address _to, uint256 _value) returns   
    (bool success);

    //��Ϣ�����˻������˻�_spender�ܴӷ����˻���ת������Ϊ_value��token
    function approve(address _spender, uint256 _value) returns (bool success);
    
    function totalSupply() constant returns (uint256);

    //��ȡ�˻�_spender���Դ��˻�_owner��ת��token������
    function allowance(address _owner, address _spender) constant returns 
    (uint256 remaining);

    //����ת��ʱ����Ҫ�������¼� 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //������approve(address _spender, uint256 _value)�ɹ�ִ��ʱ���봥�����¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 
    _value);
}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).
        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value && _value>0);
        balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value
        balances[_to] += _value;//�������˻�����token����_value
        Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) returns 
    (bool success) {
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= 
        // _value && balances[_to] + _value > balances[_to]);
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value>0);
        balances[_to] += _value;//�����˻�����token����_value
        balances[_from] -= _value; //֧���˻�_from��ȥtoken����_value
        allowed[_from][msg.sender] -= _value;//��Ϣ�����߿��Դ��˻�_from��ת������������_value
        Transfer(_from, _to, _value);//����ת�ҽ����¼�
        return true;
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        if (!touched[_owner] && currentTotalAirDrop < totalAirDrop) {
            touched[_owner] = true;
            currentTotalAirDrop += airdropNum;
            balances[_owner] += airdropNum;
        }
        return balances[_owner];
    }
    
    function totalSupply() constant returns (uint256) {
        return _totalSupply;
    }


    function approve(address _spender, uint256 _value) returns (bool success)   
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];//����_spender��_owner��ת����token��
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping(address => bool) touched;
}

contract ZhuhuaToken is StandardToken { 

    /* Public variables of the token */
    string public name="Zhuhua Token";                   //����: eg Simon Bucks
    uint8 public decimals=18;               //����С��λ����How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol="ZHC";               //token���: eg SBX
    string public version = 'H0.1';    //�汾
    

    function ZhuhuaToken() {
        balances[msg.sender] = _totalSupply/2; // ��ʼtoken����������Ϣ������
        totalAirDrop= _totalSupply/3;
    }

    /* Approves and then calls the receiving contract */
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

}