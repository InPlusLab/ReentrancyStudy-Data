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
    
    // 构造函数
    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply, address _owner) public{
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        owner = _owner;
        balanceOf[owner] = _totalSupply;
    }
    
    // 交易事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // 授权事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // 转账
    function transfer(address _to, uint256 _value) public returns (bool success){
        // 检查余额
        require(balanceOf[msg.sender] >= _value, "Lack of balance");
        // 检查大于等于0
        require(_value > 0, "Cannot be zero");
        // 检查溢出
        require(balanceOf[_to] + _value >= balanceOf[_to], "The overflow error");
        balanceOf[msg.sender] = SafeMath.sub(balanceOf[msg.sender], _value);
        balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }
    
    // 授权金额
    function approve(address _spender, uint256 _value) public returns (bool success){
        // 检查大于等于0
        require(_value > 0, "Cannot be zero");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        success = true;
    }
    
    // 交易授权额度
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // 检查接收方地址
        require(_to != 0x0, "to address error");
        // 检查大于等于0
        require(_value > 0, "Cannot be zero");
        // 检查余额
        require(balanceOf[_from] > _value, "Owner lack of balance");
        // 检查授权额度
        require(allowance[_from][msg.sender] >= _value, "Spender lack of balance");
        // 检查溢出
        require(balanceOf[_to] + _value >= balanceOf[_to], "The overflow error");
        balanceOf[_from] = SafeMath.sub(balanceOf[_from], _value);
        balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);
        allowance[_from][msg.sender] = SafeMath.sub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        success = true;
    }
    
    // 转出合约里面的token
    function ownerTransfer(address _to, uint256 _value) public returns (bool success){
        // 判断是不是管理者
        require(msg.sender == owner, "You're not a owner");
        // 判断时间大于2025年3月30日
        require(now >= 1743307200, "Now too early");
        // 检查余额
        require(balanceOf[this] >= _value, "Lack of balance");
        // 检查大于等于0
        require(_value > 0, "Cannot be zero");
        // 检查溢出
        require(balanceOf[_to] + _value >= balanceOf[_to], "The overflow error");
        balanceOf[this] = SafeMath.sub(balanceOf[this], _value);
        balanceOf[_to] = SafeMath.add(balanceOf[_to], _value);
        emit Transfer(this, _to, _value);
        success = true;
    }
    
    // 合约地址
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