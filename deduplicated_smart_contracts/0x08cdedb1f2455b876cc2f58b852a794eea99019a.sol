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
    string public name;                 //����
    string public symbol;               //token���
    uint32 internal rate;               //��Ʊ����
    uint32 internal consume;            //��Ʊ����
    uint256 internal totalConsume;      //��Ʊ������
    uint256 internal bigJackpot;        //�󽱳� 
    uint256 internal smallJackpot;      //С����
    uint256 public consumeRule;       //�������
    address internal owner;             //��Լ����
  
    // ===============
    // INIT 
    // ===============
    modifier onlyOwner(){
        require (msg.sender==owner);
        _;
    }
    function () payable public {}
    
    // ������
    function TTS(uint256 _initialAmount, string _tokenName, uint32 _rate) public payable {
        owner = msg.sender;
        totalSupply = _initialAmount ;         // ���ó�ʼ����
        balances[owner] = totalSupply; // ��ʼtoken����������Ϣ�����ߣ���Ϊ�ǹ��캯������������Ҳ�Ǻ�Լ�Ĵ�����
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
    // �û�����
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    // �û���������ֵ
    function trashOf(address _owner) public constant returns (uint256 trashs) {
        return trash[_owner];
    }
    // ��Ʊ����
    function getRate() public constant returns(uint32 rates){
        return rate;
    }
    // ��Ʊ����
    function getConsume() public constant returns(uint32 consumes){
        return consume;
    }
    // ��Ʊ������
    function getTotalConsume() public constant returns(uint256 totalConsumes){
        return totalConsume;
    }
    // �󽱳�
    function getBigJackpot() public constant returns(uint256 bigJackpots){
        return bigJackpot;
    }
    // С����
    function getSmallJackpot() public constant returns(uint256 smallJackpots){
        return smallJackpot;
    }
    // ��ȡ��Լ�˻����
    function getBalance() public constant returns(uint){
        return address(this).balance;
    }
    
    // ===============
    // ETH 
    // ===============
    // ��������
    function sendAll(address[] _users,uint[] _prices,uint _allPrices) public onlyOwner{
        require(_users.length>0);
        require(_prices.length>0);
        require(address(this).balance>=_allPrices);
        for(uint32 i =0;i<_users.length;i++){
            require(_users[i]!=address(0));
            require(_prices[i]>0);
            _users[i].transfer(_prices[i]);  
            transferLogs(_users[i],'ת��',_prices[i]);
        }
    }
    // ��Լ����
    function sendTransfer(address _user,uint _price) public onlyOwner{
        if(address(this).balance>=_price){
            _user.transfer(_price);
            transferLogs(_user,'ת��',_price);
        }
    }
    // ���
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
    // ������Ʊ�һ�����
   
    
    // ������Ʊ
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
    // ��Ʊ����
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
    // �ۼӽ���
    function setJackpot(uint256 _value) internal{
        uint256 jackpot = _value * 12 / 100;
        bigJackpot += jackpot * 7 / 10;
        smallJackpot += jackpot * 3 / 10;
    }
    // С���س���
    function smallCheckOut(address[] _users) public onlyOwner{
        require(_users.length>0);
        require(address(this).balance>=smallJackpot);
        uint256 pricce = smallJackpot / _users.length;
        for(uint32 i =0;i<_users.length;i++){
            require(_users[i]!=address(0));
            require(pricce>0);
            _users[i].transfer(pricce);  
            transferLogs(_users[i],'ת��',pricce);
        }
        smallJackpot=0;
    }
    // �󽱳س���
    function bigCheckOut(address[] _users) public onlyOwner{
        require(_users.length>0 && bigJackpot>=30000 ether&&address(this).balance>=bigJackpot);
        uint256 pricce = bigJackpot / _users.length;
        for(uint32 i =0;i<_users.length;i++){
            require(_users[i]!=address(0));
            require(pricce>0);
            _users[i].transfer(pricce);  
            transferLogs(_users[i],'ת��',pricce);
        }
        bigJackpot = 0;
    }
    // ===============
    // TOKEN 
    // ===============
    function inTrash(uint256 _value) internal returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value
        trash[msg.sender] += _value;//��ǰ����Ͱ����token����_value
        totalConsume += _value;
        InTrash(msg.sender,  _value);//��������Ͱ�����¼�
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Ĭ��totalSupply ���ᳬ�����ֵ (2^256 - 1).
        //�������ʱ������ƽ������µ�token���ɣ������������������������쳣
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != 0x0);
        balances[msg.sender] -= _value;//����Ϣ�������˻��м�ȥtoken����_value
        balances[_to] += _value;//�������˻�����token����_value
        Transfer(msg.sender, _to, _value);//����ת�ҽ����¼�
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;//�����˻�����token����_value
        balances[_from] -= _value; //֧���˻�_from��ȥtoken����_value
        allowed[_from][msg.sender] -= _value;//��Ϣ�����߿��Դ��˻�_from��ת������������_value
        Transfer(_from, _to, _value);//����ת�ҽ����¼�
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success)   { 
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];//����_spender��_owner��ת����token��
    }
    
    mapping (address => uint256) trash;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}