pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

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
     using SafeMath for uint;
    /*
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;*/

    uint256 public sellPrice; //���ۼ۸� 1ö���һ�������̫ /1000
	uint256 public buyPrice; //����۸� ������̫�ɹ���1ö���� /1000
	uint256 public sysPrice; //�ڿ�ĺ���ֵ
	uint256 public sysPer; //�ڿ�������ٷֱ� /100
	
	uint256 public onceOuttime; //������ʱ�� ����  
	uint256 public onceAddTime; //�ڿ��ʱ�� ����
	uint256 public onceoutTimePer; //�����İٷֱ� ����
	
	
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    /* �����˻� */
	mapping(address => bool) public frozenAccount;
	// ��¼�����˻��Ķ�����Ŀ
	//mapping(address => uint256) public freezeOf;
	// ��¼�����˻��Ŀ�����Ŀ
	mapping(address => uint256) public canOf;
	// ��¼�����˻����ͷ�ʱ��
	mapping(address => uint) public cronoutOf;
	// ��¼�����˻�������ʱ��
	mapping(address => uint) public cronaddOf;
	
	 /* ֪ͨ */
	event FrozenFunds(address target, bool frozen);
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public{
       
        
        sellPrice = 510; //���ۼ۸� 1ö���һ�������̫ /1000000
    	buyPrice =  526; //����۸� ������̫�ɹ���1ö���� /1000000
    	sysPrice = 766; //�ڿ�ĺ���ֵ
    	sysPer = 225; //�ڿ�������ٷֱ� /100
    	
    	onceOuttime = 86400; //������ʱ�� ��ʽ 
    	onceAddTime = 864000; //�ڿ��ʱ�� ��ʽ
    	onceoutTimePer = 8640000; //�����İٷֱ� ��ʽ
    	
    	//onceOuttime = 600; //������ʱ�� ����  
    	//onceAddTime = 1800; //�ڿ��ʱ�� ����
    	//onceoutTimePer = 60000; //�����İٷֱ� ����
	
	
        
       
    }



    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function canuseOf(address tokenOwner) public view returns (uint balance) {
        return canOf[tokenOwner];
    }
    function myuseOf(address tokenOwner) public returns (uint balance) {
        //return balances[tokenOwner];
        if(cronoutOf[tokenOwner] < 1) {
			return 0;
		}else{
		    uint lefttimes = now - cronoutOf[tokenOwner];
    		if(lefttimes >= onceOuttime) {
    			uint leftpers = lefttimes / onceoutTimePer;
    			if(leftpers > 1) {
    				leftpers = 1;
    			}
    			canOf[tokenOwner] = balances[tokenOwner] * leftpers;
    			return canOf[tokenOwner];
    		}else{
    		    return canOf[tokenOwner];
    		}
		}
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[to]);
        canOf[msg.sender] = myuseOf(msg.sender);
        canOf[msg.sender] = canOf[msg.sender].sub(tokens);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
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
    function approve(address spender, uint tokens) public returns (bool success) {
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
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    /// ��ָ���˻������ʽ�
	function mintToken(address target, uint256 mintedAmount) onlyOwner public {
		require(!frozenAccount[target]);
		if(cronoutOf[target] < 1) {
		    cronoutOf[target] = now + onceOuttime;
		}
		if(cronaddOf[target] < 1) {
		    cronaddOf[target] = now + onceAddTime;
		}

		balances[target] += mintedAmount;
		uint256 amounts = mintedAmount / 100;
		canOf[target] += amounts;
		//emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);

	}
	//�û�ÿ��10���ڿ�һ��
	function mint() public {
		require(!frozenAccount[msg.sender]);
		require(cronaddOf[msg.sender] > 0 && now > cronaddOf[msg.sender]);
		uint256 mintAmount = balances[msg.sender] * sysPer / 10000;
		balances[msg.sender] += mintAmount;
		cronaddOf[msg.sender] = now + onceAddTime;
		//emit Transfer(0, this, mintAmount);
		emit Transfer(this, msg.sender, mintAmount);

	}
    
	/// ���� or �ⶳ�˻�
	function freezeAccount(address target, bool freeze) onlyOwner public {
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}
	// �������۹���۸�
	function setPrices( uint256 newBuyPrice, uint256 newSellPrice, uint256 systyPrice, uint256 sysPermit) onlyOwner public {
		buyPrice = newBuyPrice;
		sellPrice = newSellPrice;
		sysPrice = systyPrice;
		sysPer = sysPermit;
	}
	// ��ȡ�۸� 
	function getprice()  public view returns (uint256 bprice,uint256 spice,uint256 sprice,uint256 sper) {
          bprice = buyPrice;
          spice = sellPrice;
          sprice = sysPrice;
          sper = sysPer;
   }
   


    
}
contract BTYC is BTYCToken{
  string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public{
        symbol = "BTYC";
        name = "BTYC Coin";
        decimals = 18;
        _totalSupply = 86400000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
    /*
    function buy(uint money) public payable {
        require(!frozenAccount[msg.sender]);
        uint amount = money * buyPrice;
        balances[msg.sender] += amount;
        //msg.sender.transfer(money);
        emit Transfer(this, msg.sender, amount);
    }
    function () payable public {
        buy(msg.value);
    }
    /*
    function selleth(uint amount) public payable {
        //address user = msg.sender;
        //canOf[user] = myuseOf(user);
        //require(balances[user] >= amount );
        //uint money = amount * sellPrice;
       // balances[msg.sender] += money;
        owner.transfer(amount);
    }*/
    /*
    function sell(uint amount)  public returns (bool success){
        //address user = msg.sender;
        //canOf[msg.sender] = myuseOf(msg.sender);
        //require(!frozenAccount[msg.sender]);
        require(canOf[msg.sender] >= amount ); 
        balances[msg.sender] -= amount;
        canOf[msg.sender] -= amount;
        uint moneys = amount / sellPrice;
        msg.sender.transfer(moneys);
        //canOf[user] -= amount;
        return true;              
    }*/
    

  
}