pragma solidity ^0.4.21;

contract KKToken {
  
  //��ַ -> ��� ��ӳ��
  mapping (address => uint256) balances;
  //��ַ -> �������ת�Ƶĵ�ַ������ ��ӳ��
  mapping (address => mapping (address => uint256)) allowed;
  
  //��4��״̬�������Զ�������Ӧpublic����
  string public name = " Kunkun Token";
  string public symbol = "KKT";
  uint8 public decimals = 18;  //�����Ĭ��ֵ
  uint256 public totalSupply;

  uint256 public initialSupply = 100000000;

  //���ETH�����͵������Լ���ᱻ���ͻ�ȥ
  function (){
    throw;
  }

  //���캯����ֻ�ں�Լ����ʱִ��һ��
  function KKToken(){
    //ʵ���ܹ�Ӧ�� = ��������*10^����
    totalSupply = initialSupply * (10 ** uint256(decimals));
    //�����д��ҷ������Լ������
    balances[msg.sender] = totalSupply;
  }

  //��ѯĳ�˻���_owner�������
  function balanceOf(address _owner) view returns (uint256 balance){
    return balances[_owner];
  }

  //��ĳ����ַ��_to�����ͣ�_value��������
  //�����ߵ���
  function transfer(address _to, uint256 _value) returns (bool success){
    //��鷢�����Ƿ����㹻�Ĵ���
    if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else { 
      return false; 
    }
  }

  //��ĳ����ַ��_from����ĳ����ַ��_to�����ͣ�_value��������
  //�����ߵ���
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
    //��鷢�����Ƿ����㹻�Ĵ���
    //���������Ƿ����ߵ������ͷ�Χ�ڣ��ҷ�������Ҳ�ڶ�Ӧ������Χ��
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

  //����ĳ����ַ��_spender��������˻�ת�ƣ�_value��������
  function approve(address _spender, uint256 _value) returns (bool success){
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  //��ȡ��_owner������ĳ����ַ��_spender��������ת�ƶ��ٴ���
  function allowance(address _owner, address _spender) view returns (uint256 remaining){
    return allowed[_owner][_spender];
  }

  //transfer ������ʱ��֪ͨ�¼�
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  //approve ������ʱ��֪ͨ�¼�
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  
}