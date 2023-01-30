pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract SATCoin is ERC20
{ using SafeMath for uint256;
    // Name of the token
    string public constant name = "SATCoin";

    // Symbol of token
    string public constant symbol = "SAT";
    uint8 public constant decimals = 8;
    uint public _totalsupply = 1000000000 * 10 ** 8; // 1 billion SAT Coins
    address public owner;
    uint256 public _price_tokn = 7000 ; // 1 Ether = 7000 coins
    uint256 no_of_tokens;
    uint256 bonus_token;
    uint256 total_token;
    bool stopped = false;
    uint256 public startdate;
    uint256 ico_first;
    uint256 ico_second;
    uint256 ico_third;
    uint256 ico_fourth;
    address central_account;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    
     enum Stages {
        NOTSTARTED,
        ICO,
        PAUSED,
        ENDED
    }
    Stages public stage;
    
    modifier atStage(Stages _stage) {
        if (stage != _stage)
            // Contract not in expected state
            revert();
        _;
    }
    
     modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
    modifier onlycentralAccount {
        require(msg.sender == central_account);
        _;
    }

    function SATCoin() public
    {
        owner = msg.sender;
        balances[owner] = 350000000 * 10 **8;
        balances[address(this)] = 650000000 *10**8;
        stage = Stages.NOTSTARTED;
        Transfer(0, owner, balances[owner]);
        Transfer(0, owner, balances[address(this)]);
    }
  
    function () public payable atStage(Stages.ICO)
    {
        require(!stopped && msg.sender != owner);
        require (now <= ico_fourth);
            if( now < ico_first )
            { 
                no_of_tokens =((msg.value).mul(_price_tokn)).div(10 **10);
               
                if(no_of_tokens >= (5000 * 10**8) && no_of_tokens <= 15000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(50)).div(100);  //50% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
                else if(no_of_tokens > (15000 * 10**8) && no_of_tokens <= 50000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(55)).div(100);  //55% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
               else if (no_of_tokens > (50000 * 10**8)){
                   
                  bonus_token = ((no_of_tokens).mul(60)).div(100); //60% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
                
                else{
                    bonus_token = ((no_of_tokens).mul(45)).div(100); // 45% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
               
            }
            else if(now >= ico_first && now < ico_second)
            {
             
                no_of_tokens =((msg.value).mul(_price_tokn)).div(10 **10);
               if(no_of_tokens >= (5000 * 10**8) && no_of_tokens <= 15000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(40)).div(100);  //40% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
                else if(no_of_tokens > (15000 * 10**8) && no_of_tokens <= 50000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(45)).div(100);  //45% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
               else if (no_of_tokens > (50000 * 10**8)){
                   
                  bonus_token = ((no_of_tokens).mul(50)).div(100); //50% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
                
                else{
                    bonus_token = ((no_of_tokens).mul(35)).div(100); // 35% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
               
            }
            else if(now >= ico_second && now < ico_third)
            {
                no_of_tokens =((msg.value).mul(_price_tokn)).div(10 **10);
                if(no_of_tokens >= (5000 * 10**8) && no_of_tokens <= 15000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(30)).div(100);  //30% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
                else if(no_of_tokens > (15000 * 10**8) && no_of_tokens <= 50000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(35)).div(100);  //35% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
               else if (no_of_tokens > (50000 * 10**8)){
                   
                  bonus_token = ((no_of_tokens).mul(40)).div(100); //40% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
                
                else{
                    bonus_token = ((no_of_tokens).mul(25)).div(100); // 25% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
               
            }
        
        else if(now >= ico_third && now < ico_fourth)
            {
                no_of_tokens =((msg.value).mul(_price_tokn)).div(10 **10);
                if(no_of_tokens >= (5000 * 10**8) && no_of_tokens <= 15000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(20)).div(100);  //20% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
                else if(no_of_tokens > (15000 * 10**8) && no_of_tokens <= 50000 * 10 **8)
                {
                    bonus_token = ((no_of_tokens).mul(25)).div(100);  //25% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
                }
               else if (no_of_tokens > (50000 * 10**8)){
                   
                  bonus_token = ((no_of_tokens).mul(30)).div(100); //30% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
                
                else{
                    bonus_token = ((no_of_tokens).mul(15)).div(100); // 15% bonus
                    total_token = no_of_tokens + bonus_token;
                    transferTokens(msg.sender,total_token);
               }
               
            }
        else{
            revert();
        }
    }
     function start_ICO() public onlyOwner atStage(Stages.NOTSTARTED)
      {
          stage = Stages.ICO;
          stopped = false;
          startdate = now;
          ico_first = now + 14 days;
          ico_second = ico_first + 14 days;
          ico_third = ico_second + 14 days;
          ico_fourth = ico_third + 14 days;
      }
    
    // called by the owner, pause ICO
    function StopICO() external onlyOwner atStage(Stages.ICO) {
        stopped = true;
        stage = Stages.PAUSED;
    }

    // called by the owner , resumes ICO
    function releaseICO() external onlyOwner atStage(Stages.PAUSED)
    {
        stopped = false;
        stage = Stages.ICO;
    }
    
     function end_ICO() external onlyOwner atStage(Stages.ICO)
     {
         require(now > ico_fourth);
         stage = Stages.ENDED;
         _totalsupply = (_totalsupply).sub(balances[address(this)]);
         balances[address(this)] = 0;
         Transfer(address(this), 0 , balances[address(this)]);
         
     }
     
     function set_centralAccount(address central_Acccount) external onlyOwner
    {
        central_account = central_Acccount;
    }



    // what is the total supply of the ech tokens
     function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalsupply;
     }
    
    // What is the balance of a particular account?
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }
    
    // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom( address _from, address _to, uint256 _amount )public returns (bool success) {
     require( _to != 0x0);
     require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balances[_from] = (balances[_from]).sub(_amount);
     allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
     balances[_to] = (balances[_to]).add(_amount);
     Transfer(_from, _to, _amount);
     return true;
         }
    
   // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount)public returns (bool success) {
         require( _spender != 0x0);
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
         require( _owner != 0x0 && _spender !=0x0);
         return allowed[_owner][_spender];
   }

     // Transfer the balance from owner&#39;s account to another account
     function transfer(address _to, uint256 _amount)public returns (bool success) {
        require( _to != 0x0);
        require(balances[msg.sender] >= _amount && _amount >= 0);
        balances[msg.sender] = (balances[msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(msg.sender, _to, _amount);
             return true;
         }
    
          // Transfer the balance from owner&#39;s account to another account
    function transferTokens(address _to, uint256 _amount) private returns(bool success) {
        require( _to != 0x0);       
        require(balances[address(this)] >= _amount && _amount > 0);
        balances[address(this)] = (balances[address(this)]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(address(this), _to, _amount);
        return true;
        }
    
    function transferby(address _from,address _to,uint256 _amount) external onlycentralAccount returns(bool success) {
        require( _to != 0x0); 
        require (balances[_from] >= _amount && _amount > 0);
        balances[_from] = (balances[_from]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }
    	//In case the ownership needs to be transferred
	function transferOwnership(address newOwner)public onlyOwner
	{
	    balances[newOwner] = (balances[newOwner]).add(balances[owner]);
	    balances[owner] = 0;
	    owner = newOwner;
	}

    
    function drain() external onlyOwner {
        owner.transfer(this.balance);
    }
    
}