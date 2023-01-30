pragma solidity >=0.4.22 <0.7.0;

import './erc20interface.sol';

contract ERC20 is ERC20Interface {


    string public  name;
    string public constant symbol = "HOFFE";
    uint8 public constant decimals = 0;  // 18 is the most common number of decimal places
    // 0.0000000000000000001  ������
    
     uint public totalSupply;
     
    // ���Զ����ɶ�Ӧ��balanceOf����
    mapping(address => uint256) internal _balances;

    // allowed����ÿ����ַ����һ��address�� ��Ȩ��������ַ(�ڶ���address)�Ķ�ȣ�uint256��
    mapping(address => mapping(address => uint256)) allowed;

    constructor(string memory _name) public {
       name = _name;  // "UpChain";
       totalSupply = 1000000;
       _balances[msg.sender] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }

  // ת��
  function transfer(address _to, uint256 _value)  public returns (bool success) {
      require(_to != address(0));
      require(_balances[msg.sender] >= _value);
      require(_balances[ _to] + _value >= _balances[ _to]);   // ��ֹ���


      _balances[msg.sender] -= _value;
      _balances[_to] += _value;

      // �����¼�
      emit Transfer(msg.sender, _to, _value);

      return true;
  }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      require(_to != address(0));
      require(allowed[_from][msg.sender] >= _value);
      require(_balances[_from] >= _value);
      require(_balances[ _to] + _value >= _balances[ _to]);

      _balances[_from] -= _value;
      _balances[_to] += _value;

      allowed[_from][msg.sender] -= _value;

      emit Transfer(msg.sender, _to, _value);
      return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;

      emit Approval(msg.sender, _spender, _value);
      return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

}
