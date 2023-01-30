/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity ^0.4.26;


contract Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public owner;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    // ���캯��
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply, address _owner) public{
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        owner = _owner;
        balanceOf[owner] = _totalSupply;
    }
    
    // �����¼�
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // ��Ȩ�¼�
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // ת��
    function transfer(address _to, uint256 _value) public returns (bool success){
        // ������
        require(balanceOf[msg.sender] >= _value, "Lack of balance");
        // �����ڵ���0
        require(_value > 0, "Cannot be zero");
        // ������
        require(balanceOf[_to] + _value >= balanceOf[_to], "The overflow error");
        balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);
        balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }
    
    // ��Ȩ���
    function approve(address _spender, uint256 _value) public returns (bool success){
        // �����ڵ���0
        require(_value > 0, "Cannot be zero");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        success = true;
    }
    
    // ������Ȩ���
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // �����շ���ַ
        require(_to != 0x0, "to address error");
        // �����ڵ���0
        require(_value > 0, "Cannot be zero");
        // ������
        require(balanceOf[_from] > _value, "Owner lack of balance");
        // �����Ȩ���
        require(allowance[_from][msg.sender] >= _value, "Spender lack of balance");
        // ������
        require(balanceOf[_to] + _value >= balanceOf[_to], "The overflow error");
        balanceOf[_from] = SafeMath.sub(balanceOf[_from], _value);
        balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);
        allowance[_from][msg.sender] = SafeMath.sub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        success = true;
    }
    
    // ת����Լ�����token
    function ownerTransfer(address _to, uint256 _value) public returns (bool success){
        // �ж��ǲ��ǹ�����
        require(msg.sender == owner, "You're not a owner");
        // �ж�ʱ�����2025��3��30��
        require(now >= 1743307200, "Now too early");
        // ������
        require(balanceOf[this] >= _value, "Lack of balance");
        // �����ڵ���0
        require(_value > 0, "Cannot be zero");
        // ������
        require(balanceOf[_to] + _value >= balanceOf[_to], "The overflow error");
        balanceOf[this] = SafeMath.sub(balanceOf[this], _value);
        balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);
        emit Transfer(this, _to, _value);
        success = true;
    }
    
    // ��Լ��ַ
    function _address() public view returns (address){
         return this;
    }
    
}


library SafeMath {
     function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }
}