/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity ^0.4.21;



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



contract CryptoQuantumTradingFund is ERC20Interface {

	

	

	// ERC20 //////////////



	event Burn(address indexed from, uint256 value);



    /**

     * Destroy tokens

     */

    function burn(uint256 _value) public returns (bool success) {

	if (msg.sender != owner) 

	{

		    revert();

	}

	if(_value <= 0 || _totalBalance < _value){

	    revert();

	}

        balances[owner] -= _value;

        _totalBalance -= _value;
	totalCQTFSupply -= _value;



        emit Burn(msg.sender, _value);

        emit Transfer(msg.sender, address(0), _value);

        return true;

    }





	function totalSupply()public constant returns (uint) {

		return totalCQTFSupply;

	}

	

	function balanceOf(address tokenOwner)public constant returns (uint balance) {

		return balances[tokenOwner];

	}



	function transfer(address to, uint tokens)public returns (bool success) {

		if (balances[msg.sender] >= tokens && tokens > 0 && balances[to] + tokens > balances[to]) {

            if(lockedUsers[msg.sender].lockedTokens > 0){

                TryUnLockBalance(msg.sender);

                if(balances[msg.sender] - tokens < lockedUsers[msg.sender].lockedTokens)

                {

                    return false;

                }

            }

            

			balances[msg.sender] -= tokens;

			balances[to] += tokens;

			emit Transfer(msg.sender, to, tokens);

			return true;

		} else {

			return false;

		}

	}

	



	function transferFrom(address from, address to, uint tokens)public returns (bool success) {

		if (balances[from] >= tokens && allowed[from][msg.sender] >= tokens && tokens > 0 && balances[to] + tokens > balances[to]) {

            if(lockedUsers[from].lockedTokens > 0)

            {

                TryUnLockBalance(from);

                if(balances[from] - tokens < lockedUsers[from].lockedTokens)

                {

                    return false;

                }

            }

            

			balances[from] -= tokens;

			allowed[from][msg.sender] -= tokens;

			balances[to] += tokens;

			emit Transfer(from, to, tokens);

			return true;

		} else {

			return false;

		}

	}

	

	

	function approve(address spender, uint tokens)public returns (bool success) {

		allowed[msg.sender][spender] = tokens;

		emit Approval(msg.sender, spender, tokens);

		return true;

	}

	

	function allowance(address tokenOwner, address spender)public constant returns (uint remaining) {

		return allowed[tokenOwner][spender];

	}

	

	event Transfer(address indexed from, address indexed to, uint tokens);//transfer方法调用时的通知事件

	event Approval(address indexed tokenOwner, address indexed spender, uint tokens); //approve方法调用时的通知事件

	

	// ERC20 //////////////

		

    	string public name = "CryptoQuantumTradingFund";

    	string public symbol = "CQTF";

    	uint8 public decimals = 18;

	uint256 private totalCQTFSupply = 100000000000000000000000000;

	uint256 private _totalBalance = totalCQTFSupply;

	

	struct LockUser{

	    uint256 lockedTokens;

	    uint lockedTime;

	    uint lockedIdx;

	}

	

	

	address public owner = 0x0;

	

    	mapping (address => uint256) balances;

    	mapping(address => mapping (address => uint256)) allowed;



	mapping(address => LockUser) lockedUsers;

	

	

	uint  constant    private ONE_DAY_TIME_LEN =     86400; //一天的秒数

	uint  constant    private ONE_YEAR_TIME_LEN = 31536000; //一年的秒数

	uint  constant    private THREE_MONTH_LEN =    7776000; //三个月秒数

	// uint  constant    private ONE_DAY_TIME_LEN = 1; //一天的秒数 测试

	// uint  constant    private ONE_YEAR_TIME_LEN = 10; //一年的秒数 测试

	uint32 private constant MAX_UINT32 = 0xFFFFFFFF;

	



	uint256   public creatorsTotalBalance =    8000000000000000000000000;//创世团队当前锁定额度

	



	

	event SendTo(uint32 indexed _idx, uint8 indexed _type, address _from, address _to, uint256 _value);

	

	uint32 sendToIdx = 0;

	

	function safeToNextIdx() internal{

        if (sendToIdx >= MAX_UINT32){

			sendToIdx = 1;

		}

        else{

			sendToIdx += 1;

		}

    }



    function CryptoQuantumTradingFund() public {

	

		owner = msg.sender;

		balances[owner] = _totalBalance;

    }

	

	



	

	//解锁

	function TryUnLockBalance(address target) public {

	    if(target == 0x0)

	    {

	        revert();

	    }

	    LockUser storage user = lockedUsers[target];

	    if(user.lockedIdx > 0 && user.lockedTokens > 0)

	    {

	        if(block.timestamp >= user.lockedTime)

	        {

	            if(user.lockedIdx == 1)

	            {

	                user.lockedIdx = 0;

	                user.lockedTokens = 0;

	            }

	            else

	            {

	                uint256 append = user.lockedTokens/user.lockedIdx;

	                user.lockedTokens -= append;

        			user.lockedIdx--;

        			user.lockedTime = block.timestamp + ONE_YEAR_TIME_LEN;

        			lockedUsers[target] = user;

	            }

	        }

	    }

		

	}

	

	



	

	//创始团队

	function sendCreatorByOwner(address _to, uint256 _value) public {

		if (msg.sender != owner) 

		{

		    revert();

		}

		

		if(_to == 0x0){

			revert();

		}

		

		if(_value > creatorsTotalBalance){

			revert();

		}

		

		

		creatorsTotalBalance -= _value;

		balances[owner] -= _value;

		_totalBalance -= _value;

		balances[_to] += _value;

		LockUser storage lockUser = lockedUsers[_to];

		lockUser.lockedTime = block.timestamp + ONE_YEAR_TIME_LEN;

		lockUser.lockedTokens += _value;

		lockUser.lockedIdx = 1;



                lockedUsers[_to] = lockUser;

		

		emit Transfer(owner, _to, _value);

		

		safeToNextIdx();

		emit SendTo(sendToIdx, 4, 0x0, _to, _value);

	}





       

	

	

	

	function changeOwner(address newOwner) public {

		if (msg.sender != owner) 

		{

		    revert();

		}

		else

		{

			balances[newOwner] = balances[owner];

			balances[owner] = 0x0;

			owner = newOwner;

			

		}

    }

	

	function destruct() public {

		if (msg.sender != owner) 

		{

		    revert();

		}

		else

		{

			selfdestruct(owner);

		}

    }

	

	

}