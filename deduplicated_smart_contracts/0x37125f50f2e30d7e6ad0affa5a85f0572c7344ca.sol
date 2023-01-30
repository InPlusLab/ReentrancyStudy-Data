pragma solidity ^ 0.4 .24;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
	function add(uint a, uint b) internal pure returns(uint c) {
		c = a + b;
		require(c >= a);
	}

	function sub(uint a, uint b) internal pure returns(uint c) {
		require(b <= a);
		c = a - b;
	}

	function mul(uint a, uint b) internal pure returns(uint c) {
		c = a * b;
		require(a == 0 || c / a == b);
	}

	function div(uint a, uint b) internal pure returns(uint c) {
		require(b > 0);
		c = a / b;
	}
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
	function totalSupply() public constant returns(uint);

	function balanceOf(address tokenOwner) public constant returns(uint balance);

	function allowance(address tokenOwner, address spender) public constant returns(uint remaining);

	function transfer(address to, uint tokens) public returns(bool success);

	function approve(address spender, uint tokens) public returns(bool success);

	function transferFrom(address from, address to, uint tokens) public returns(bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
	function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed _from, address indexed _to);

	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address _newOwner) public onlyOwner {
		newOwner = _newOwner;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner);
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
		newOwner = address(0);
	}
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract BTYCToken is ERC20Interface, Owned {
	using SafeMath
	for uint;

	string public symbol;
	string public name;
	uint8 public decimals;
	uint _totalSupply;

	uint public sellPrice; //���ۼ۸� 1ö���һ�������̫ /1000
	uint public buyPrice; //����۸� ������̫�ɹ���1ö���� /1000
	uint public sysPrice; //�ڿ�ĺ���ֵ
	uint8 public sysPer; //�ڿ�������ٷֱ� /100
	uint public givecandyto; //�������� 
	uint public givecandyfrom; //�����Ƽ���
	uint public candyper; //ת�˶��ٸ�����
	//uint sysPricetrue;

	uint public onceOuttime; //������ʱ�� ����  
	uint public onceAddTime; //�ڿ��ʱ�� ����

	mapping(address => uint) balances;
	mapping(address => uint) used;
	mapping(address => mapping(address => uint)) allowed;

	/* �����˻� */
	mapping(address => bool) public frozenAccount;
	// ��¼�����˻��Ķ�����Ŀ
	//mapping(address => uint256) public freezeOf;
	// ��¼�����˻��Ŀ�����Ŀ
	//mapping(address => uint256) public canOf;
	/*
	struct roundsOwn {
		uint256 addtime; // ���ʱ��
		uint256 addmoney; // ���
	}*/
	//�ͷ� 
	mapping(address => uint[]) public mycantime;
	mapping(address => uint[]) public mycanmoney;
	
	mapping(address => address) public fromaddr;
    //mapping(address => uint256) public tradenum;
	// ��¼�����˻����ͷ�ʱ��
	//mapping(address => uint) public cronoutOf;
	// ��¼�����˻�������ʱ��
	mapping(address => uint) public cronaddOf;

	/* ֪ͨ */
	event FrozenFunds(address target, bool frozen);
	// ------------------------------------------------------------------------
	// Constructor
	// ------------------------------------------------------------------------
	constructor() public {

		symbol = "BTYC";
		name = "BTYC Coin";
		decimals = 18;
		_totalSupply = 86400000 ether;

		sellPrice = 510 szabo; //���ۼ۸� 1ö���һ�������̫ /1000000
		buyPrice = 526 szabo; //����۸� ������̫�ɹ���1ö���� /1000000
		sysPrice = 766 ether; //�ڿ�ĺ���ֵ
		sysPer = 225; //�ڿ�������ٷֱ� /100
		candyper = 1 ether;
		givecandyfrom = 10 ether;
		givecandyto = 40 ether;

		onceOuttime = 1 days; //������ʱ�� ��ʽ 
		onceAddTime = 10 days; //�ڿ��ʱ�� ��ʽ

		//onceOuttime = 10 seconds; //������ʱ�� ����  
		//onceAddTime = 20 seconds; //�ڿ��ʱ�� ����
		balances[owner] = _totalSupply;
		emit Transfer(address(0), owner, _totalSupply);

	}

	// ------------------------------------------------------------------------
	// Get the token balance for account `tokenOwner`
	// ------------------------------------------------------------------------

	function balanceOf(address tokenOwner) public view returns(uint balance) {
		return balances[tokenOwner];
	}

	function addmoney(address _addr, uint256 _money) private{
	    uint256 _now = now;
	    mycanmoney[_addr].push(_money);
	    mycantime[_addr].push(_now);
	    /*
	    roundsOwn storage stateVar;
	    uint256 _now = now;
	    stateVar.addtime = _now;
	    stateVar.addmoney = _money;
		mycan[_addr].push(stateVar);*/
		if(balances[_addr] >= sysPrice && cronaddOf[_addr] < 1) {
			cronaddOf[_addr] = now + onceAddTime;
		}
		//tradenum[_addr] = tradenum[_addr] + 1;
	}
	function reducemoney(address _addr, uint256 _money) private{
	    used[_addr] += _money;
	    if(balances[_addr] < sysPrice){
	        cronaddOf[_addr] = 0;
	    }
	}
    function getaddtime(address _addr) public view returns(uint) {
        if(cronaddOf[_addr] < 1) {
			return(now + onceAddTime);
		}
		return(cronaddOf[_addr]);
    }

	function getcanuse(address tokenOwner) public view returns(uint balance) {
	    uint256 _now = now;
	    uint256 _left = 0;
	    for(uint256 i = 0; i < mycantime[tokenOwner].length; i++) {
	        //roundsOwn mydata = mycan[tokenOwner][i];
	        uint256 stime = mycantime[tokenOwner][i];
	        uint256 smoney = mycanmoney[tokenOwner][i];
	        uint256 lefttimes = _now - stime;
	        if(lefttimes >= onceOuttime) {
	            uint256 leftpers = lefttimes / onceOuttime;
	            if(leftpers > 100){
	                leftpers = 100;
	            }
	            _left = smoney*leftpers/100 + _left;
	        }
	    }
	    _left = _left - used[tokenOwner];
	    if(_left < 0){
	        return(0);
	    }
	    if(_left > balances[tokenOwner]){
	        return(balances[tokenOwner]);
	    }
	    return(_left);
	}

	// ------------------------------------------------------------------------
	// Transfer the balance from token owner's account to `to` account
	// - Owner's account must have sufficient balance to transfer
	// - 0 value transfers are allowed
	// ------------------------------------------------------------------------
	function transfer(address to, uint tokens) public returns(bool success) {
		require(!frozenAccount[msg.sender]);
		require(!frozenAccount[to]);
		uint256 canuse = getcanuse(msg.sender);
		require(canuse >= tokens);

		if(fromaddr[to] == address(0)){
		    fromaddr[to] = msg.sender;
		    
    		if(tokens >= candyper) {
    		    if(givecandyfrom > 0) {
    		        balances[msg.sender] = balances[msg.sender].sub(tokens).add(givecandyfrom);
    		        reducemoney(msg.sender, tokens);
    		        addmoney(msg.sender, givecandyfrom);
    		    }
    		    if(givecandyto > 0) {
    		        tokens += givecandyto;
    		    }
    		}else{
    		    reducemoney(msg.sender, tokens);
    		    balances[msg.sender] = balances[msg.sender].sub(tokens);
    		}
    		balances[to] = balances[to].add(tokens);
    		addmoney(to, tokens);
		    //tokens = candyuser(msg.sender, to, tokens);
		}else{
		    reducemoney(msg.sender, tokens);
    		balances[msg.sender] = balances[msg.sender].sub(tokens);
    		balances[to] = balances[to].add(tokens);
    		addmoney(to, tokens);
		}
		emit Transfer(msg.sender, to, tokens);
		return true;
	}
	/*
	function candyuser(address from, address to, uint tokens) private returns(uint money){
	     money = tokens;
	    if(tokens >= candyper) {
		        if(givecandyto > 0) {
    		        balances[to] = balances[to].add(givecandyto);
    		        addmoney(to, givecandyto);
    		        money = tokens + givecandyto;
    		    }
    		    if(givecandyfrom > 0) {
    		        balances[from] = balances[from].add(givecandyfrom);
    		        addmoney(from, givecandyfrom);
    		    }
		    }
	}*/
	function getnum(uint num) public view returns(uint){
	    return(num* 10 ** uint(decimals));
	}
	function getfrom(address _addr) public view returns(address) {
	    return(fromaddr[_addr]);
	    //return(address(0));
	}
	/*
	function buytoken(address user, uint256 amount) public{
	    balances[user] = balances[user].sub(amount);
	    //buyeth(amount);
	    emit Transfer(address(0), user, amount);
	}*/

	// ------------------------------------------------------------------------
	// Token owner can approve for `spender` to transferFrom(...) `tokens`
	// from the token owner's account
	//
	// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
	// recommends that there are no checks for the approval double-spend attack
	// as this should be implemented in user interfaces 
	// ------------------------------------------------------------------------
	function approve(address spender, uint tokens) public returns(bool success) {
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		return true;
	}

	// ------------------------------------------------------------------------
	// Transfer `tokens` from the `from` account to the `to` account
	// 
	// The calling account must already have sufficient tokens approve(...)-d
	// for spending from the `from` account and
	// - From account must have sufficient balance to transfer
	// - Spender must have sufficient allowance to transfer
	// - 0 value transfers are allowed
	// ------------------------------------------------------------------------
	function transferFrom(address from, address to, uint tokens) public returns(bool success) {
		balances[from] = balances[from].sub(tokens);
		reducemoney(from, tokens);
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
		balances[to] = balances[to].add(tokens);
		addmoney(to, tokens);
		emit Transfer(from, to, tokens);
		return true;
	}

	// ------------------------------------------------------------------------
	// Returns the amount of tokens approved by the owner that can be
	// transferred to the spender's account
	// ------------------------------------------------------------------------
	function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
		return allowed[tokenOwner][spender];
	}

	// ------------------------------------------------------------------------
	// ��Ȩ
	// ------------------------------------------------------------------------
	function approveAndCall(address spender, uint tokens, bytes data) public returns(bool success) {
		allowed[msg.sender][spender] = tokens;
		emit Approval(msg.sender, spender, tokens);
		ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
		return true;
	}

	/// ���� or �ⶳ�˻�
	function freezeAccount(address target, bool freeze) onlyOwner public {
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}
	// �������۹���۸�
	function setPrices(uint newBuyPrice, uint newSellPrice, uint systyPrice, uint8 sysPermit, uint sysgivefrom, uint sysgiveto, uint sysgiveper) onlyOwner public {
		buyPrice = newBuyPrice;
		sellPrice = newSellPrice;
		sysPrice = systyPrice;
		sysPer = sysPermit;
		givecandyfrom = sysgivefrom;
		givecandyto = sysgiveto;
		candyper = sysgiveper;
	}
	// ��ȡ�۸� 
	function getprice() public view returns(uint bprice, uint spice, uint sprice, uint8 sper, uint givefrom, uint giveto, uint giveper) {
		bprice = buyPrice;
		spice = sellPrice;
		sprice = sysPrice;
		sper = sysPer;
		givefrom = givecandyfrom;
		giveto = givecandyto;
		giveper = candyper;
	}

	// ------------------------------------------------------------------------
	// Total supply
	// ------------------------------------------------------------------------
	function totalSupply() public view returns(uint) {
		return _totalSupply.sub(balances[address(0)]);
	}
	/// ��ָ���˻������ʽ�
	function mintToken(address target, uint256 mintedAmount) onlyOwner public {
		require(!frozenAccount[target]);
        
		balances[target] += mintedAmount;
		//_totalSupply -= mintedAmount;
		addmoney(target, mintedAmount);
		//emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);

	}
	//�û�ÿ��10���ڿ�һ��
	function mint() public {
		require(!frozenAccount[msg.sender]);
		require(cronaddOf[msg.sender] > 0);
		require(now > cronaddOf[msg.sender]);
		require(balances[msg.sender] >= getnum(sysPrice));
		uint256 mintAmount = balances[msg.sender] * sysPer / 10000;
		balances[msg.sender] += mintAmount;
		//_totalSupply -= mintAmount;
		cronaddOf[msg.sender] = now + onceAddTime;
		addmoney(msg.sender, mintAmount);
		//emit Transfer(0, this, mintAmount);
		emit Transfer(this, msg.sender, mintAmount);

	}
    
	function buy() public payable returns(uint256 amount) {
		require(!frozenAccount[msg.sender]);
		require(msg.value > 0);
		amount = msg.value * buyPrice;
		require(balances[owner] > amount);
		balances[msg.sender] += amount;
		balances[owner] -= amount;  
		//_totalSupply -= amount;
		addmoney(msg.sender, amount);
		owner.transfer(msg.value);
		emit Transfer(owner, msg.sender, amount); 
		return(amount);
	}

	function() payable public {
		buy();
	}
	
    function withdrawEther(address _to) public  onlyOwner {
        _to.transfer(address(this).balance);
    }
	function sell(uint256 amount) public returns(bool success) {
		//address user = msg.sender;
		//canOf[msg.sender] = myuseOf(msg.sender);
		//require(!frozenAccount[msg.sender]);
		uint256 canuse = getcanuse(msg.sender);
		require(canuse >= amount);
		require(balances[msg.sender] > amount);
		uint moneys = amount / sellPrice;
		require(msg.sender.send(moneys));
		reducemoney(msg.sender, amount);
		balances[msg.sender] -= amount;
		balances[owner] += amount;
		//_totalSupply += amount;
		//canOf[msg.sender] -= amount;
		
		//this.transfer(moneys);Transfer(this, msg.sender, revenue);  
		emit Transfer(owner, msg.sender, moneys);
		//canOf[user] -= amount;
		return(true);
	}

}