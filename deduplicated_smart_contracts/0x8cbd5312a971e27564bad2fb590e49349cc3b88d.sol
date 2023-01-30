/**
 *Submitted for verification at Etherscan.io on 2019-07-19
*/

pragma solidity ^0.4.24;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract Alchemy {
    using SafeMath for uint256;

    // 代币的公共变量：名称、代号、小数点后面的位数、代币发行总量
    string public name;
    string public symbol;
    uint8 public decimals = 6; // 官方建议18位
    uint256 public totalSupply;
    address public owner;

    address[] public ownerContracts;// 允许调用的智能合约
    address public userPool;
    address public platformPool;
    address public smPool;

    // 代币余额的数据
    mapping (address => uint256) public balanceOf;
    // 代付金额限制
    // 比如map[A][B]=60，意思是用户B可以使用A的钱进行消费，使用上限是60，此条数据由A来设置，一般B可以使中间担保平台
    mapping (address => mapping (address => uint256)) public allowance;

    // 交易成功事件，会通知给客户端
    event Transfer(address indexed from, address indexed to, uint256 value);

     // 交易ETH成功事件，会通知给客户端
    event TransferETH(address indexed from, address indexed to, uint256 value);

    // 将销毁的代币量通知给客户端
    event Burn(address indexed from, uint256 value);

    /**
     * 构造函数
     * 初始化代币发行的参数
     */
    //990000000,"AlchemyChain","ALC"
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) payable public  {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // 计算发行量
        balanceOf[msg.sender] = totalSupply;                // 将发行的币给创建者
        name = tokenName;                                   // 设置代币名称
        symbol = tokenSymbol;                               // 设置代币符号
        owner = msg.sender;
    }

    // 修改器
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //查询当前的以以太余额
	function getETHBalance() view public returns(uint){
		return address(this).balance;
	}

	//批量平分以太余额
    function transferETH(address[] _tos) public onlyOwner returns (bool) {
        require(_tos.length > 0);
        require(address(this).balance > 0);
        for(uint32 i=0;i<_tos.length;i++){
           _tos[i].transfer(address(this).balance/_tos.length);
           emit TransferETH(owner, _tos[i], address(this).balance/_tos.length);
        }
        return true;
    }

    //直接转账指定数量
    function transferETH(address _to, uint256 _value) payable public onlyOwner returns (bool){
        require(_value > 0);
        require(address(this).balance >= _value);
        require(_to != address(0));
        _to.transfer(_value);
        emit TransferETH(owner, _to, _value);
        return true;
    }

    //直接转账全部数量
    function transferETH(address _to) payable public onlyOwner returns (bool){
        require(_to != address(0));
        require(address(this).balance > 0);
        _to.transfer(address(this).balance);
        emit TransferETH(owner, _to, address(this).balance);
        return true;
    }

    //直接转账全部数量
    function transferETH() payable public onlyOwner returns (bool){
        require(address(this).balance > 0);
        owner.transfer(address(this).balance);
        emit TransferETH(owner, owner, address(this).balance);
        return true;
    }

    // 接收以太
    function () payable public {
        // 其他逻
    }

    // 众筹
    function funding() payable public returns (bool) {
        require(msg.value <= balanceOf[owner]);
        // SafeMath.sub will throw if there is not enough balance.
        balanceOf[owner] = balanceOf[owner].sub(msg.value);
        balanceOf[tx.origin] = balanceOf[tx.origin].add(msg.value);
        emit Transfer(owner, tx.origin, msg.value);
        return true;
    }

    function _contains() internal view returns (bool) {
        for(uint i = 0; i < ownerContracts.length; i++){
            if(ownerContracts[i] == msg.sender){
                return true;
            }
        }
        return false;
    }

    function setOwnerContracts(address _adr) public onlyOwner {
        if(_adr != 0x0){
            ownerContracts.push(_adr);
        }
    }

     //修改管理帐号
    function transferOwnership(address _newOwner) public onlyOwner {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }

    /**
     * 内部转账，只能被本合约调用
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(userPool != 0x0);
        require(platformPool != 0x0);
        require(smPool != 0x0);
        // 检测是否空地址
        require(_to != 0x0);
        // 检测余额是否充足
        require(_value > 0);
        require(balanceOf[_from] >= _value);
        // 检测溢出
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // 保存一个临时变量，用于最后检测值是否溢出
        uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
        // 出账
        balanceOf[_from] = balanceOf[_from].sub(_value);
        uint256 burnTotal = 0;
        uint256 platformToal = 0;
        // 入账如果接受方是智能合约地址，则直接销毁
        if (this == _to) {
             //totalSupply -= _value;                      // 从发行的币中删除
             burnTotal = _value*3;
             platformToal = burnTotal.mul(15).div(100);
             require(balanceOf[owner] > (burnTotal + platformToal));
             balanceOf[userPool] = balanceOf[userPool].add(burnTotal);
             balanceOf[platformPool] = balanceOf[platformPool].add(platformToal);
             balanceOf[owner] -= (burnTotal + platformToal);
             emit Transfer(_from, _to, _value);
             emit Burn(_from, _value);
        } else if (smPool == _from) {//私募方代用户投入燃烧数量代币
             burnTotal = _value*3;
             platformToal = burnTotal.mul(15).div(100);
             require(balanceOf[owner] > (burnTotal + platformToal));
             balanceOf[userPool] = balanceOf[userPool].add(burnTotal);
             balanceOf[platformPool] = balanceOf[platformPool].add(platformToal);
             balanceOf[owner] -= (burnTotal + platformToal);
             emit Transfer(_to, this, _value);
             emit Burn(_to, _value);
        } else {
             balanceOf[_to] = balanceOf[_to].add(_value);
             emit Transfer(_from, _to, _value);
             // 检测值是否溢出，或者有数据计算错误
             assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
        }
    }

    /**
     * 代币转账
     * 从自己的账户上给别人转账
     * @param _to 转入账户
     * @param _value 转账金额
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * 代币转账
     * 从自己的账户上给别人转账
     * @param _to 转入账户
     * @param _value 转账金额
     */
    function transferTo(address _to, uint256 _value) public {
        require(_contains());
        _transfer(tx.origin, _to, _value);
    }

    /**
     * 从其他账户转账
     * 从其他的账户上给别人转账
     * @param _from 转出账户
     * @param _to 转入账户
     * @param _value 转账金额
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowance[_from][msg.sender]);     // 检查允许交易的金额
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * 设置代付金额限制
     * 允许消费者使用的代币金额
     * @param _spender 允许代付的账号
     * @param _value 允许代付的金额
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * 设置代付金额限制并通知对方（合约）
     * 设置代付金额限制
     * @param _spender 允许代付的账号
     * @param _value 允许代付的金额
     * @param _extraData 回执数据
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * 销毁自己的代币
     * 从系统中销毁代币
     * @param _value 销毁量
     */
    function burn(uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value);   // 检测余额是否充足
        balanceOf[msg.sender] -= _value;            // 销毁代币
        totalSupply -= _value;                      // 从发行的币中删除
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * 销毁别人的代币
     * 从系统中销毁代币
     * @param _from 销毁的地址
     * @param _value 销毁量
     */
    function burnFrom(address _from, uint256 _value) public returns (bool) {
        require(balanceOf[_from] >= _value);                // 检测余额是否充足
        require(_value <= allowance[_from][msg.sender]);    // 检测代付额度
        balanceOf[_from] -= _value;                         // 销毁代币
        allowance[_from][msg.sender] -= _value;             // 销毁额度
        totalSupply -= _value;                              // 从发行的币中删除
        emit Burn(_from, _value);
        return true;
    }

    /**
     * 批量转账
     * 从自己的账户上给别人转账
     * @param _to 转入账户
     * @param _value 转账金额
     */
    function transferArray(address[] _to, uint256[] _value) public {
        require(_to.length == _value.length);
        uint256 sum = 0;
        for(uint256 i = 0; i< _value.length; i++) {
            sum += _value[i];
        }
        require(balanceOf[msg.sender] >= sum);
        for(uint256 k = 0; k < _to.length; k++){
            _transfer(msg.sender, _to[k], _value[k]);
        }
    }

    /**
     * 设置炼金池，平台收益池地址
     */
    function setUserPoolAddress(address _userPoolAddress, address _platformPoolAddress, address _smPoolAddress) public onlyOwner {
         require(_userPoolAddress != 0x0);
         require(_platformPoolAddress != 0x0);
         require(_smPoolAddress != 0x0);
         userPool = _userPoolAddress;
         platformPool = _platformPoolAddress;
         smPool = _smPoolAddress;
     }

    /**
     * 私募转帐特殊处理
     */
    function smTransfer(address _to, uint256 _value) public returns (bool)  {
       require(smPool == msg.sender);
       _transfer(msg.sender, _to, _value);
       return true;
     }

}