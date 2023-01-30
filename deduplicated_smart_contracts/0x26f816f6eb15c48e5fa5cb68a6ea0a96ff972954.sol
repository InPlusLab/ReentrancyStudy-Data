/**
 *Submitted for verification at Etherscan.io on 2020-02-22
*/

pragma solidity >=0.4.22 <0.6.0;

contract JUSToken {
/*********Token的属性说明************/
    address public owner = 0xBf8216Cdf1a4892d480BEAEDAC81c98D78979283;
    string public name = "JUS Token";
    string public symbol = "JUS";
    uint8 public decimals = 18;  // 18 是建议的默认值
    uint256 public totalSupply; // 发行量

    // 建立映射 地址对应了 uint' 便是他的余额
    mapping (address => uint256) public balanceOf;   
    // 地址对应余额
    mapping (address => mapping (address => uint256)) public allowance;

     // 事件，用来通知客户端Token交易发生
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // 这里是构造函数, 实例创建时候执行
    constructor (uint256 initialSupply) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // 这里确定了总发行量
        
        balanceOf[owner] = totalSupply;    // 这里就比较重要, 这里相当于实现了, 把token 全部给合约的Creator
    }

    // token的发送函数
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {

        require(_to != address(0x0));    // 不是零地址
        require(balanceOf[_from] >= _value);        // 有足够的余额来发送
        require(balanceOf[_to] + _value > balanceOf[_to]);  // 这里也有意思, 不能发送负数的值(hhhh)

        balanceOf[_from] -= _value; //发钱 不多说
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);   // 这里触发了转账的事件 , 见上event
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value); // 这里已经储存了 合约创建者的信息, 这个函数是只能被合约创建者使用
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // 这句很重要, 地址对应的合约地址(也就是token余额)
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;   // 这里是可花费总量
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

}