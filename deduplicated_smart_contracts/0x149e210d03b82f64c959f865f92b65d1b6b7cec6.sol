/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract seaToken{
    string public name;  //代币名称 
    string public symbol;    //代币符号 
    uint256 public decimals;   //代币小数点位数 
    uint256 public totalSupply; //代币发行总量
    uint256 public rate; //转账手续费费率
    address private ownerAddress;   //持有者账号
    
    mapping (address => uint256) public balanceOf;    //存储用户余额
    mapping (address => mapping(address=>uint256)) public allowance;   //存储被授权者可操作授权者的金额
    
    event Transfer(address indexed from,address indexed to,uint256 value,uint256 fee);  //转账事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);   //授权事件
    event Rate(address indexed from, uint256 value);    //设置手续费事件
    
    constructor(string memory tokenName,string memory tokenSymbol,uint256 tokenDecimals,uint256 tokenTotalSupply)public{
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = tokenTotalSupply * 10 ** tokenDecimals;
        balanceOf[msg.sender] = totalSupply;
        rate = 1000;
        ownerAddress = msg.sender;
    }
    /**
     * 合约内部调用：执行转账方法
     */
    function _transfer(address _from,address _to, uint256 _value) internal{
        require(_to != address(0x0));
        uint fee;
        if(ownerAddress != _from){   //用户转账有手续费
            fee = _value / rate;
        }
        require(balanceOf[_from] >= (_value + fee));
        require(balanceOf[_to] + _value >= balanceOf[_to]); //防止转负数
        uint previousBalances = balanceOf[_from] + balanceOf[_to] - fee;
        balanceOf[_from] = balanceOf[_from] - _value - fee;
        balanceOf[_to] += _value;
        balanceOf[ownerAddress] += fee;
        emit Transfer(_from, _to, _value,fee);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    /*
    * 设置转账手续费率
    */
    function setRate(uint256 _value)public returns(bool success){
        require(msg.sender == ownerAddress);
        rate = _value;
        emit Rate(msg.sender,_value);
        return true;
    }
    
    /*
    *在总账户中给用户发币
    */
    function transfer(address _to,uint256 _value) public returns(bool success) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    /*
    *   用户之间转账，有手续费操作
    */
    function transferFrom(address _from,address _to,uint256 _value)public returns(bool success){
        require(msg.sender == _from || ownerAddress == msg.sender);
        _transfer(_from,_to,_value);
        return true;
    }
    /*
    *允许用户可花费的代币数
    */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /*
    *    *控制用户代币交易量
    */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    
    /*
    *   查询调用者的账户余额
    */
    function getBalance()public view returns(uint256 balance){
        return balanceOf[msg.sender];
    }
    
    /*
    *   合约销毁
    */
    function destroy()public{
        require(ownerAddress == msg.sender);
        selfdestruct(msg.sender);
    }
}