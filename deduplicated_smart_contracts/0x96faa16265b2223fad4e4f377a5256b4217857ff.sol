/**
 *Submitted for verification at Etherscan.io on 2020-01-09
*/

/**
 * Source Code first verified at www.betbeb.com on Thursday, July 6, 2020
 (UTC) */

pragma solidity ^0.4.24;

/**
 * Math operations with safety checks
 */
 interface tokenTransfer {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value);
    function balanceOf(address receiver) returns(uint256);
}
interface tokenTransfers {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value);
    function balanceOf(address receiver) returns(uint256);
}
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
contract bitbeb is SafeMath{
    tokenTransfer public bebTokenTransfer; //BEB 1.0���� 
    tokenTransfers public bebTokenTransfers; //BEB 2.0���� 
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	address public owner;
	uint256 Destruction;//��������
	uint256 BEBPrice;//��ʼ�۸�0.00007142ETH
	uint256 RiseTime;//����ʱ��
	uint256 attenuation;//˥��
	uint256 exchangeRate;//����Ĭ��1:14000
	uint256 TotalMachine;//�������
	uint256 AccumulatedDays;//������������
	uint256 sumExbeb;//����ͨ
	uint256 BebAirdrop;//BEB��Ͷ
	uint256 AirdropSum;//��Ͷ��������
	uint256 TimeDay;
	address[] public Airdrops;
	struct MinUser{
         uint256 amount;//�ۼ�����
         uint256 MiningMachine;//���
         uint256 WithdrawalTime;//ȡ��ʱ��
         uint256 PendingRevenue;//������
         uint256 dayRevenue;//������
     }

    /* This creates an array with all balances */
    mapping (address=>MinUser) public MinUsers;
    mapping (address=>uint256) public locking;//����
    mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public freezeOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);
	
	/* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
	
	/* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function bitbeb(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address _tokenAddress
        ) {
        name = tokenName; // Set the name for display purposes
        symbol = tokenSymbol; // Set the symbol for display purposes
        decimals = decimalUnits;  
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[address(this)] = totalSupply;  // Amount of decimals for display purposes
		owner = msg.sender;
		bebTokenTransfer = tokenTransfer(_tokenAddress);
		RiseTime=1578725653;//BEB�۸��ʼ����ʼ����ʱ��
		BebAirdrop=388* 10 ** uint256(decimals);//��ʼ��Ͷ388BEB
		BEBPrice=166600000000000;//��ʼ�۸�0.0001666 ETH
		exchangeRate=6002;
		attenuation=5;
		TimeDay=86400;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
        if (_to == 0x0) throw;                               // Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) throw; 
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
		if (_value <= 0) throw; 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
        if (_to == 0x0) throw;                                // Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) throw; 
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;     // Check allowance
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }
	
	function freeze(uint256 _value) returns (bool success) {
	    require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
        if (balanceOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply
        Freeze(msg.sender, _value);
        return true;
    }
	
	function unfreeze(uint256 _value) returns (bool success) {
	    require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
        if (freezeOf[msg.sender] < _value) throw;            // Check if the sender has enough
		if (_value <= 0) throw; 
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        Unfreeze(msg.sender, _value);
        return true;
    }
    //�����ǿ������
    function IntoBebMiner(uint256 _value)public{
        if(_value<=0)throw;
        require(_value>=1 ether*exchangeRate,"BEB The sum is too small");
        MinUser storage _user=MinUsers[msg.sender];
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        uint256 _miner=SafeMath.safeDiv(_value,exchangeRate);
        balanceOf[msg.sender]=SafeMath.safeSub(balanceOf[msg.sender], _value);
        if(locking[msg.sender]>0){
           if(locking[msg.sender]==1){
            uint256 _shouyi=SafeMath.safeDiv(24000 ether,TotalMachine);
            uint256 _time=SafeMath.safeSub(now, _user.WithdrawalTime);//�����ʱ��
            uint256 _days=_time/TimeDay;
            if(_days>0){
                uint256 _sumshouyi=SafeMath.safeMul(1000000000000000000,_shouyi);
                uint256 _BEBsumshouyi=SafeMath.safeMul(_sumshouyi,_days);
                bebTokenTransfers.transfer(msg.sender,_BEBsumshouyi);
                sumExbeb=SafeMath.safeAdd(sumExbeb,_sumshouyi); 
            }
          }else{
            sumExbeb=SafeMath.safeAdd(sumExbeb,locking[msg.sender]); 
            //AirdropjieDong=SafeMath.safeAdd(AirdropjieDong,locking[msg.sender]);//��Ͷ�ⶳ
            locking[msg.sender]=0;
          }   
        }
         _user.MiningMachine=SafeMath.safeAdd(_user.MiningMachine,_miner);
        _user.WithdrawalTime=now;
        locking[msg.sender]=0;
        totalSupply=SafeMath.safeSub(totalSupply, _value);//����
        TotalMachine=SafeMath.safeAdd(TotalMachine,_miner);
        Destruction=SafeMath.safeAdd(Destruction, _value);//������������
        sumExbeb=SafeMath.safeSub(sumExbeb,_value);
        Burn(msg.sender, _value);   
    }
    function MinerToBeb()public{
        if(now-RiseTime>TimeDay){
            RiseTime=SafeMath.safeAdd(RiseTime,TimeDay);
            BEBPrice=SafeMath.safeAdd(BEBPrice,660000000000);//ÿ�չ̶�����0.00000066ETH
            AccumulatedDays+=1;//����BEB��ʼ����
            exchangeRate=SafeMath.safeDiv(1 ether,BEBPrice);
        }
        MinUser storage _user=MinUsers[msg.sender];
        if(_user.MiningMachine>1000000000000000000){
            if(locking[msg.sender]>1){
               sumExbeb=SafeMath.safeAdd(sumExbeb,locking[msg.sender]); 
               locking[msg.sender]=0;
            }
        }
        require(_user.MiningMachine>0,"You don't have a miner");
        require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
        //�ж��û��ǲ�����ѿ�����߿�Ͷ�û�������Ƿ��أ���Ҫ�����������
        uint256 _miners=_user.MiningMachine;
        uint256 _times=SafeMath.safeSub(now, _user.WithdrawalTime);
        require(_times>TimeDay,"No withdrawal for less than 24 hours");
        uint256 _days=SafeMath.safeDiv(_times,TimeDay);//����������
        uint256 _shouyi=SafeMath.safeDiv(240000 ether,TotalMachine);//����ÿ̨���ÿ������
        uint256 _dayshouyi=SafeMath.safeMul(_miners,_shouyi);
        //uint256 _daysumshouyi=SafeMath.safeDiv(_dayshouyi,1 ether);//�����û�ÿ��������
        uint256 _aaaa=SafeMath.safeMul(_dayshouyi,_days);
            uint256 _attenuation=_miners*5/1000*_days;//����ÿ��˥����
            bebTokenTransfers.transfer(msg.sender,_aaaa);
           _user.MiningMachine=SafeMath.safeSub( _user.MiningMachine,_attenuation);
           _user.WithdrawalTime=now;
           sumExbeb=SafeMath.safeAdd(sumExbeb,_aaaa);
           TotalMachine=SafeMath.safeSub(TotalMachine,_attenuation);
           _user.amount=SafeMath.safeAdd( _user.amount,_aaaa);
    }
    function FreeMiningMachine()public{
        if(now-RiseTime>TimeDay){
            RiseTime=SafeMath.safeAdd(RiseTime,TimeDay);
            BEBPrice=SafeMath.safeAdd(BEBPrice,660000000000);//ÿ�չ̶�����0.00000066ETH
            AccumulatedDays+=1;//����BEB��ʼ����
            exchangeRate=SafeMath.safeDiv(1 ether,BEBPrice);
        }
        require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
        MinUser storage _user=MinUsers[msg.sender];
        require(_user.MiningMachine==0,"I can't get it. You already have a miner");
        //uint256 _miner=1000000000000000000;//0.1ETH
        _user.MiningMachine=SafeMath.safeAdd(_user.MiningMachine,1000000000000000000);//����0.1̨���
        _user.WithdrawalTime=now;
        locking[msg.sender]=1;
    }
    //1.0 BEB�һ�POS���
    function OldBebToMiner(uint256 _value)public{
      if(now<1582591205)throw;
      uint256 _bebminer=SafeMath.safeDiv(_value,exchangeRate);
      if(_bebminer<=0)throw;
      MinUser storage _user=MinUsers[msg.sender];
        bebTokenTransfer.transferFrom(msg.sender,address(this),_value);  
        _user.MiningMachine=SafeMath.safeAdd(_user.MiningMachine,_bebminer);
        _user.WithdrawalTime=now;
        TotalMachine=SafeMath.safeAdd(TotalMachine,_bebminer);
    }
    //��BEB
    function buyBeb(address _addr) payable public {
        if(now-RiseTime>TimeDay){
            RiseTime=SafeMath.safeAdd(RiseTime,TimeDay);
            BEBPrice=SafeMath.safeAdd(BEBPrice,660000000000);//ÿ�չ̶�����0.00000066ETH
            AccumulatedDays+=1;//����BEB��ʼ����
            exchangeRate=SafeMath.safeDiv(1 ether,BEBPrice);
        }
        uint256 amount = msg.value;
        if(amount<=0)throw;
        uint256 bebamountub=SafeMath.safeMul(amount,exchangeRate);
        //require(bebamountub<=buyTota,"Exceeded the maximum quantity available for sale");
        uint256 _transfer=amount*2/100;
        uint256 _bebtoeth=amount*98/100;
       require(balanceOf[_addr]>=bebamountub,"Sorry, your credit is running low");
       bebTokenTransfers.transferFrom(_addr,msg.sender,bebamountub);
        owner.transfer(_transfer);//֧��2%�����Ѹ���Ŀ��
        _addr.transfer(_bebtoeth);
        //sellTota=SafeMath.safeAdd(sellTota,bebamountub);
       // buyTota=SafeMath.safeSub(buyTota,bebamountub);
    }
    // sellbeb-eth
    function sellBeb(uint256 _sellbeb)public {
        if(now-RiseTime>TimeDay){
            RiseTime=SafeMath.safeAdd(RiseTime,TimeDay);
            BEBPrice=SafeMath.safeAdd(BEBPrice,660000000000);//ÿ�չ̶�����0.00000066ETH
            AccumulatedDays+=1;//����BEB��ʼ����
            exchangeRate=SafeMath.safeDiv(1 ether,BEBPrice);
        }
         require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
         approve(address(this),_sellbeb);
    }
    //��ͶAirdrop
    function AirdropBeb()public{
        if(now-RiseTime>TimeDay){
            RiseTime=SafeMath.safeAdd(RiseTime,TimeDay);
            BEBPrice=SafeMath.safeAdd(BEBPrice,660000000000);//ÿ�չ̶�����0.00000066ETH
            AccumulatedDays+=1;//����BEB��ʼ����
            exchangeRate=SafeMath.safeDiv(1 ether,BEBPrice);
        }
        MinUser storage _user=MinUsers[msg.sender];
        require(_user.MiningMachine<=0);
        require(locking[msg.sender]==0,"Please activate on the website www.exbeb.com");
        uint256 _airbeb=SafeMath.safeMul(BebAirdrop,166600000000000);
        BebAirdrop=SafeMath.safeDiv(_airbeb,BEBPrice);
        bebTokenTransfers.transfer(msg.sender,BebAirdrop);//����BEB
        locking[msg.sender]=BebAirdrop;
        AirdropSum=SafeMath.safeAdd(AirdropSum,BebAirdrop);
    }
    function setAddress(address[] _addr)public{
        if(msg.sender != owner)throw;
        Airdrops=_addr;
    }
    //ִ�п�Ͷ
    function batchAirdrop()public{
        if(now<1586306405)throw;//2020��4��9��ǰ����ʹ�������Ͷ����
        if(msg.sender != owner)throw;
        for(uint i=0;i<Airdrops.length;i++){
            bebTokenTransfers.transfer(Airdrops[i],BebAirdrop);
            locking[Airdrops[i]]=BebAirdrop;
        }
    }
    //����BEB
    function AdditionalIssue(uint256 _value)public{
        if(msg.sender != owner)throw;
        totalSupply += _value * 10 ** uint256(decimals);
        balanceOf[address(this)] += _value * 10 ** uint256(decimals);
        
    }
    //��ʼ��������
    function setMiner(address _addr,uint256 _value)public{
        if(msg.sender != owner)throw;
        if(now>1580519056)throw;//2020��1��20��֮��������ܾͲ���ʹ����
        MinUser storage _user=MinUsers[_addr];
        _user.MiningMachine=_value;
        _user.WithdrawalTime=now;
        TotalMachine+=_value;
    }
    function setBebTokenTransfers(address _addr)public{
        if(msg.sender != owner)throw;
         if(now>1580519056)throw;//2020��1��20��֮��������ܾͲ���ʹ����
        bebTokenTransfers=tokenTransfers(_addr);
        
    }
    //���˲�ѯ�����棬���������ȡ��ʱ�䣬������
    function getUser(address _addr)public view returns(uint256,uint256,uint256,uint256,uint256){
            MinUser storage _user=MinUsers[_addr];
            uint256 edays=240000 ether / TotalMachine;
            uint256 _day=_user.MiningMachine*edays;
         return (_user.amount,_user.MiningMachine,_user.WithdrawalTime,_day,(now-_user.WithdrawalTime)/TimeDay*_day);
    }
    function getQuanju()public view returns(uint256,uint256,uint256,uint256,uint256,uint256){
        //uint256 Destruction;//��������
	    //uint256 BEBPrice;//��ʼ�۸�0.00007142ETH
	    //uint256 TotalMachine;//�������
	    //uint256 AccumulatedDays;//������������
	    //uint256 sumExbeb;//BEB����ͨ
	    //uint256 BebAirdrop;//BEBÿ�ο�Ͷ����
            
         return (TotalMachine,Destruction,sumExbeb,BEBPrice,AccumulatedDays,BebAirdrop);
    }
    function querBalance()public view returns(uint256){
         return this.balance;
     }
     //��Ŀ������
     function getowner()public view returns(uint256,uint256){ 
         MinUser storage _user=MinUsers[owner];
         return (_user.MiningMachine,balanceOf[owner]);
    }
    //�����ǿ������
	// can accept ether
	function() payable {
    }
}