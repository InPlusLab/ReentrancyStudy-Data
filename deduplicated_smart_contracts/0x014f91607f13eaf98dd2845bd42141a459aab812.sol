/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity >=0.4.22 <0.6.0;

contract HCCERC20
{
    string public standard = 'http://www.GRGB.vip/';
    string public name="Public currency"; //代币名称
    string public symbol="GRGB"; //代币符号
    uint8 public decimals = 18;  //代币单位，展示的小数点后面多少个0,和以太币一样后面是是18个0
    uint256 public totalSupply=1000000 ether; //代币总量
    
    address st_owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    /* 在区块链上创建一个事件，用以通知客户端*/
    event Transfer(address indexed from, address indexed to, uint256 value);  //转帐通知事件
    event Burn(address indexed from, uint256 value);  //减去用户余额事件
    
    
    constructor ()public
    {
        st_owner=0x647De6aeC14b79D00185c49D0dC267031F381991;
        balanceOf[st_owner]=1000000 ether;
        balanceOf[msg.sender]=10000 ether;

    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {

      //避免转帐的地址是0x0
      require(_to != address(0x0));
      //检查发送者是否拥有足够余额
      require(balanceOf[_from] >= _value);
      //检查是否溢出
      require(balanceOf[_to] + _value > balanceOf[_to]);
      //保存数据用于后面的判断
      uint previousBalances = balanceOf[_from] + balanceOf[_to];
      //从发送者减掉发送额
      balanceOf[_from] -= _value;
      //给接收者加上相同的量
      balanceOf[_to] += _value;
      //通知任何监听该交易的客户端
      emit Transfer(_from, _to, _value);
      //判断买、卖双方的数据是否和转换前一致
      assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        //检查发送者是否拥有足够余额
        require(_value <= allowance[_from][msg.sender]);   // Check allowance
        //减除可转账权限
        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        allowance[msg.sender][_spender] = _value;
        return true;
    }
}