/**
 *Submitted for verification at Etherscan.io on 2019-11-15
*/

pragma solidity ^0.4.24;

  contract ERC20 {
      function balanceOf( address who ) constant returns (uint value);
      function allowance( address owner, address spender ) constant returns (uint _allowance);

      function transfer( address to, uint value) returns (bool ok);
      function transferFrom( address from, address to, uint value) returns (bool ok);
      function approve( address spender, uint value ) returns (bool ok);

      event Transfer( address indexed from, address indexed to, uint value);
      event Approval( address indexed owner, address indexed spender, uint value);
  }

  contract SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
      if (a == 0) {
        return 0;
      }
      c = a * b;
      assert(c / a == b);
      return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      return a / b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
      c = a + b;
      assert(c >= a);
      return c;
    }
  }



  contract TestToken is ERC20, SafeMath {
    //����һ��״̬�����������ͽ�һЩaddressӳ�䵽�޷�������uint256��
    mapping(address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;


    //function transfer(address to, uint value) returns (bool ok);
    function transfer(address _to, uint _value) returns (bool success) {
      //����Ϣ�������˻��м�ȥtoken����_value
      balances[msg.sender] = sub(balances[msg.sender], _value);
      //�������˻�����token����_value
      balances[_to] = add(balances[_to], _value);
      //����ת�ҽ����¼�
      Transfer(msg.sender, _to, _value);
      return true;
    }
    //function transferFrom(address from, address to, uint value) returns (bool ok);
    function transferFrom(address _from, address _to, uint _value)  returns (bool success) {
      var _allowance = allowed[_from][msg.sender];
      //�����˻�����token����_value
      balances[_to] = add(balances[_to], _value);
      //֧���˻�_from��ȥtoken����_value
      balances[_from] = sub(balances[_from], _value);
      //��Ϣ�����߿��Դ��˻�_from��ת������������_value
      allowed[_from][msg.sender] = sub(_allowance, _value);
      //����ת�ҽ����¼�
      Transfer(_from, _to, _value);
      return true;
    }
    //function balanceOf( address who ) constant returns (uint value);
    function balanceOf(address _owner) constant returns (uint balance) {
      return balances[_owner];
    }
    //function approve( address spender, uint value ) returns (bool ok);
    function approve(address _spender, uint _value) returns (bool success) {
      if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
    }
    //function allowance( address owner, address spender ) constant returns (uint _allowance);
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
      //����_spender��_owner��ת����token��
      return allowed[_owner][_spender];
    }

  }

  /**
   * ����Ethereum token.
   *
   * ����token�����������owner.
   * owner֮����԰�token�����������
   * owner��������token
   *
   */

     contract CBToken is TestToken{

    string public name;  // Token����
    string public symbol;  // Token��ʶ
    uint8 public decimals = 18;  // ����С��λ��18�ǽ����Ĭ��ֵ
    uint256 public totalSupply;
    function CBToken(address _owner, string _name, string _symbol, uint _totalSupply, uint8 _decimals) {
      name = _name;
      symbol = _symbol;
      totalSupply = _totalSupply * 10 ** uint256(_decimals);
      decimals = _decimals;

      // �Ѵ���token�����������owner
      balances[_owner] = totalSupply;
    }
  }