/**
 *Submitted for verification at Etherscan.io on 2020-10-19
*/

pragma solidity ^0.4.24;

contract EIP20Interface{
    //��ȡ_owner��ַ�����
    function balanceOf(address _owner) public view returns (uint256 balance);
    //ת��:���Լ��˻���_to��ַת��_value��Token
    function transfer(address _to, uint256 _value)public returns (bool success);
    //ת��:��_from��_toת_value��Token
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    //����_spender���Լ�(���÷�)�˻�ת��_value��Token
    function approve(address _spender, uint256 _value) returns (bool success);
    //�Լ�_owner��ѯ__spender��ַ����ת���Լ����ٸ�Token
    function allowance(address _owner, address _spender) view returns (uint256 remaining);
    //ת�˵�ʱ�����Ҫ���õ�ʱ�䣬����Tranfer,TransferFrom
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //�ɹ�ִ��approve��������õ��¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract YJCToken is EIP20Interface {
    //1.��ȡtoken���֣�����"YaJing Coin"
    string public name;
     //2.��ȡToken���,����"YJC"
    string public symbol;
    //3.��ȡС��λ��������̫����decimalsΪ18
    uint8 public decimals;
     //4.��ȡtoken����������������HT 5��
    uint256 public totalSupply;

    mapping(address=>uint256) balances ;
    mapping(address=>mapping(address=>uint256)) allowances;
    function YJCToken(string _name,string _symbol, uint8 _decimals,uint256 _totalSupply) public{       
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply = _totalSupply;
    balances[msg.sender] = _totalSupply;
    }

    //��ȡ_owner��ַ�����
    function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[_owner];
    }
    //ת��:���Լ��˻���_to��ַת��_value��Token
    function transfer(address _to, uint256 _value)public  returns (bool success){
        require(_value >0 && balances[_to] + _value > balances[_to] && balances[msg.sender] > _value);
        balances[_to] += _value;
        balances[msg.sender] -= _value;
        Transfer(msg.sender, _to,_value);

        return true;
    }

    //ת��:��_from��_toת_value��Token
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
        uint256 allowan = allowances[_from][_to];
        require(allowan > _value && balances[_from] >= _value && _to == msg.sender && balances[_to] + _value>balances[_to]);
        allowances[_from][_to] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(_from,_to,_value);
        return true;
    }
    //����_spender���Լ�(���÷�)�˻�ת��_value��Token
    function approve(address _spender, uint256 _value) returns (bool success){
        require(_value >0 && balances[msg.sender] > _value);
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender,_spender,_value);
                return true;
    }
    //�Լ�_owner��ѯ_spender��ַ����ת���Լ����ٸ�Token
    function allowance(address _owner, address _spender) view returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

}