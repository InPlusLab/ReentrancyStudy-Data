pragma solidity ^0.4.24;

contract AutoChainTokenCandyInface{

    function name() public constant returns (string );
    function  symbol() public constant returns (string );
    function  decimals()  public constant returns (uint8 );
    // ����token����������ΪtotalSupply().
    function  totalSupply()  public constant returns (uint256 );

    /// ��ȡ�˻�_ownerӵ��token������ 
    function  balanceOf(address _owner)  public constant returns (uint256 );

    //����Ϣ�������˻�����_to�˻�ת����Ϊ_value��token
    function  transfer(address _to, uint256 _value) public returns (bool );

    //���˻�_from�����˻�_toת����Ϊ_value��token����approve�������ʹ��
    function  transferFrom(address _from, address _to, uint256 _value) public returns   
    (bool );

    //��Ϣ�����˻������˻�_spender�ܴӷ����˻���ת������Ϊ_value��token
    function  approve(address _spender, uint256 _value) public returns (bool );

    //��ȡ�˻�_spender���Դ��˻�_owner��ת��token������
    function  allowance(address _owner, address _spender) public constant returns 
    (uint256 );

    //����ת��ʱ����Ҫ�������¼� 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //������approve(address _spender, uint256 _value)�ɹ�ִ��ʱ���봥�����¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 
    _value);
}

contract AutoChainTokenCandy is AutoChainTokenCandyInface {

    /* private variables of the token */
    uint256 private _localtotalSupply;		//����
    string private _localname;                   //����: eg Simon Bucks
    uint8 private _localdecimals;               //����С��λ����How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string private _localsymbol;               //token���: eg SBX
    string private _localversion = '0.01';    //�汾

    address private _localowner; //�洢��Լowner

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;

    function  AutoChainTokenCandy() public {
        _localowner=msg.sender;		//�����Լ��owner
        balances[msg.sender] = 50000000000; // ��ʼtoken����������Ϣ������,��Ҫ����С������λ��
        _localtotalSupply = 50000000000;         // ���ó�ʼ����,��Ҫ����С������λ��
        _localname = 'AutoChainTokenCandy';                   // token����
        _localdecimals = 4;           // С��λ��
        _localsymbol = 'ATCx';             // token���
        
    }

    function getOwner() constant public returns (address ){
        return _localowner;
    }

    function  name() constant public returns (string ){
    	return _localname;
    }
    function  decimals() public constant returns (uint8 ){
    	return _localdecimals;
    }
    function  symbol() public constant returns (string ){
    	return _localsymbol;
    }
    function  version() public constant returns (string ){
    	return _localversion;
    }
    function  totalSupply() public constant returns (uint256 ){
    	return _localtotalSupply;
    }
    function  transfer(address _to, uint256 _value) public returns (bool ) {
        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).
        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value
        balances[_to] += _value;//�������˻�����token����_value
        emit Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�
        return true;
    }
    function  transferFrom(address _from, address _to, uint256 _value) public returns 
    (bool ) {
        require(balances[_from] >= _value &&  balances[_to] + _value > balances[_to] && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;//�����˻�����token����_value
        balances[_from] -= _value; //֧���˻�_from��ȥtoken����_value
        allowed[_from][msg.sender] -= _value;//��Ϣ�����߿��Դ��˻�_from��ת������������_value
        emit Transfer(_from, _to, _value);//����ת�ҽ����¼�
        return true;
    }
    function  balanceOf(address _owner) public constant returns (uint256 ) {
        return balances[_owner];
    }
    function  approve(address _spender, uint256 _value) public returns (bool )   
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function  allowance(address _owner, address _spender) public constant returns (uint256 ) {
        return allowed[_owner][_spender];//����_spender��_owner��ת����token��
    }
}