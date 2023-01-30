/**
 *Submitted for verification at Etherscan.io on 2019-09-14
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-16
*/

pragma solidity ^0.4.16;
contract Token{
    uint256 public totalSupply;

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function trashOf(address _owner) public constant returns (uint256 trash);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function inTrash(uint256 _value) internal returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event InTrash(address indexed _from, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event transferLogs(address,string,uint);
}

contract TTS is Token {
    // ===============
    // BASE 
    // ===============
    string public name;                 //名称
    string public symbol;               //token简称
    uint32 internal rate;               //门票汇率
    uint32 internal consume;            //门票消耗
    uint256 internal totalConsume;      //门票总消耗
    uint256 internal bigJackpot;        //大奖池 
    uint256 internal smallJackpot;      //小奖池
    uint256 public consumeRule;       //减半规则
    address internal owner;             //合约作者
  
    // ===============
    // INIT 
    // ===============
    modifier onlyOwner(){
        require (msg.sender==owner);
        _;
    }
    function () payable public {}
    
    // 构造器
    function TTS(uint256 _initialAmount, string _tokenName, uint32 _rate) public payable {
        owner = msg.sender;
        totalSupply = _initialAmount ;         // 设置初始总量
        balances[owner] = totalSupply; // 初始token数量给予消息发送者，因为是构造函数，所以这里也是合约的创建者
        name = _tokenName;            
        symbol = _tokenName;
        rate = _rate;
        consume = _rate/10;
        totalConsume = 0;
        consumeRule = 0;
        bigJackpot = 0;
        smallJackpot = 0;
    }  
    // ===============
    // CHECK 
    // ===============
    // 用户代币
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    // 用户代币消耗值
    function trashOf(address _owner) public constant returns (uint256 trashs) {
        return trash[_owner];
    }
    // 门票汇率
    function getRate() public constant returns(uint32 rates){
        return rate;
    }
    // 门票消耗
    function getConsume() public constant returns(uint32 consumes){
        return consume;
    }
    // 门票总消耗
    function getTotalConsume() public constant returns(uint256 totalConsumes){
        return totalConsume;
    }
    // 大奖池
    function getBigJackpot() public constant returns(uint256 bigJackpots){
        return bigJackpot;
    }
    // 小奖池
    function getSmallJackpot() public constant returns(uint256 smallJackpots){
        return smallJackpot;
    }
    // 获取合约账户余额
    function getBalance() public constant returns(uint){
        return address(this).balance;
    }
    
    // ===============
    // ETH 
    // ===============
    // 批量出账
    function sendAll(address[] _users,uint[] _prices,uint _allPrices) public onlyOwner{
        require(_users.length>0);
        require(_prices.length>0);
        require(address(this).balance>=_allPrices);
        for(uint32 i =0;i<_users.length;i++){
            require(_users[i]!=address(0));
            require(_prices[i]>0);
            _users[i].transfer(_prices[i]);  
            transferLogs(_users[i],'转账',_prices[i]);
        }
    }
    // 合约出账
    function sendTransfer(address _user,uint _price) public onlyOwner{
        if(address(this).balance>=_price){
            _user.transfer(_price);
            transferLogs(_user,'转账',_price);
        }
    }
    // 提币
    function getEth(uint _price) public onlyOwner{
        if(_price>0){
            if(address(this).balance>=_price){
                owner.transfer(_price);
            }
        }else{
           owner.transfer(address(this).balance); 
        }
    }
    
    // ===============
    // TICKET 
    // ===============
    // 设置门票兑换比例
   
    
    // 购买门票
    function tickets() public payable returns(bool success){
        require(msg.value % 1 ether == 0);
        uint e = msg.value / 1 ether;
        e=e*rate;
        require(balances[owner]>=e);
        balances[owner]-=e;
        balances[msg.sender]+=e;
        Transfer(owner, msg.sender, e);
        return true;
    }
    // 门票消耗
    function ticketConsume()public payable returns(bool success){
        require(msg.value % 1 ether == 0);
        uint e = msg.value / 1 ether * consume;
        
        require(balances[msg.sender]>=e); 
        balances[msg.sender]-=e;
        trash[msg.sender]+=e;
        totalConsume+=e;
        consumeRule+=e;
        if(consumeRule>=1000000){
            consumeRule-=1000000;
            rate = rate / 2;
            consume = consume / 2;
        }
        setJackpot(msg.value);
        return true;
    }

    // ===============
    // JACKPOT 
    // ===============
    // 累加奖池
    function setJackpot(uint256 _value) internal{
        uint256 jackpot = _value * 12 / 100;
        bigJackpot += jackpot * 7 / 10;
        smallJackpot += jackpot * 3 / 10;
    }
    // 小奖池出账
    function smallCheckOut(address[] _users) public onlyOwner{
        require(_users.length>0);
        require(address(this).balance>=smallJackpot);
        uint256 pricce = smallJackpot / _users.length;
        for(uint32 i =0;i<_users.length;i++){
            require(_users[i]!=address(0));
            require(pricce>0);
            _users[i].transfer(pricce);  
            transferLogs(_users[i],'转账',pricce);
        }
        smallJackpot=0;
    }
    // 大奖池出账
    function bigCheckOut(address[] _users) public onlyOwner{
        require(_users.length>0 && bigJackpot>=30000 ether&&address(this).balance>=bigJackpot);
        uint256 pricce = bigJackpot / _users.length;
        for(uint32 i =0;i<_users.length;i++){
            require(_users[i]!=address(0));
            require(pricce>0);
            _users[i].transfer(pricce);  
            transferLogs(_users[i],'转账',pricce);
        }
        bigJackpot = 0;
    }
    // ===============
    // TOKEN 
    // ===============
    function inTrash(uint256 _value) internal returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;//从消息发送者账户中减去token数量_value
        trash[msg.sender] += _value;//当前垃圾桶增加token数量_value
        totalConsume += _value;
        InTrash(msg.sender,  _value);//触发垃圾桶消耗事件
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //默认totalSupply 不会超过最大值 (2^256 - 1).
        //如果随着时间的推移将会有新的token生成，则可以用下面这句避免溢出的异常
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != 0x0);
        balances[msg.sender] -= _value;//从消息发送者账户中减去token数量_value
        balances[_to] += _value;//往接收账户增加token数量_value
        Transfer(msg.sender, _to, _value);//触发转币交易事件
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;//接收账户增加token数量_value
        balances[_from] -= _value; //支出账户_from减去token数量_value
        allowed[_from][msg.sender] -= _value;//消息发送者可以从账户_from中转出的数量减少_value
        Transfer(_from, _to, _value);//触发转币交易事件
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success)   { 
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];//允许_spender从_owner中转出的token数
    }
    
    mapping (address => uint256) trash;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}