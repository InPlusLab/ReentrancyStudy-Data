pragma solidity ^0.4.18;

contract EtherealFoundationOwned {
	address private Owner;
    
	function IsOwner(address addr) view public returns(bool)
	{
	    return Owner == addr;
	}
	
	function TransferOwner(address newOwner) public onlyOwner
	{
	    Owner = newOwner;
	}
	
	function EtherealFoundationOwned() public
	{
	    Owner = msg.sender;
	}
	
	function Terminate() public onlyOwner
	{
	    selfdestruct(Owner);
	}
	
	modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }
}
contract EtherealToken is EtherealFoundationOwned/*, MineableToken*/{
    string public constant CONTRACT_NAME = "EtherealToken";
    string public constant CONTRACT_VERSION = "A";
    
    string public constant name = "Test Token&#174;";//itCoin&#174; Limited
    string public constant symbol = "TMP";//ITLD
    uint256 public constant decimals = 0;  // 18 is the most common number of decimal places
    bool private tradeable;
    uint256 private currentSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address=> uint256)) private allowed;
    mapping(address => bool) private lockedAccounts;  
	
    
    function EtherealToken(
		uint256 initialTotalSupply, 
		address[] addresses, 
		uint256[] initialBalances, 
		bool initialBalancesLocked
		) public
    {
        require(addresses.length == initialBalances.length);
        
        currentSupply = initialTotalSupply * (10**decimals);
        uint256 totalCreated;
        for(uint8 i =0; i < addresses.length; i++)
        {
            if(initialBalancesLocked){
                lockedAccounts[addresses[i]] = true;
            }
            balances[addresses[i]] = initialBalances[i]* (10**decimals);
            totalCreated += initialBalances[i]* (10**decimals);
        }
        
        
        if(currentSupply < totalCreated)
        {
            selfdestruct(msg.sender);
        }
        else
        {
            balances[this] = currentSupply - totalCreated;
        }
    }
    
	
    event SoldToken(address _buyer, uint256 _value, string note);
    function BuyToken(address _buyer, uint256 _value, string note) public onlyOwner
    {
        SoldToken( _buyer,  _value,  note);
        balances[this] -= _value;
        balances[_buyer] += _value;
        Transfer(this, _buyer, _value);
    }
    
    function LockAccount(address toLock) public onlyOwner
    {
        lockedAccounts[toLock] = true;
    }
    function UnlockAccount(address toUnlock) public onlyOwner
    {
        delete lockedAccounts[toUnlock];
    }
    
    function SetTradeable(bool t) public onlyOwner
    {
        tradeable = t;
    }
    function IsTradeable() public view returns(bool)
    {
        return tradeable;
    }
    
    
    function totalSupply() constant public returns (uint)
    {
        return currentSupply;
    }
    function balanceOf(address _owner) constant public returns (uint balance)
    {
        return balances[_owner];
    }
    function transfer(address _to, uint _value) public notLocked returns (bool success) {
        require(tradeable);
         if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
             Transfer( msg.sender, _to,  _value);
             balances[msg.sender] -= _value;
             balances[_to] += _value;
             return true;
         } else {
             return false;
         }
     }
    function transferFrom(address _from, address _to, uint _value)public notLocked returns (bool success) {
        require(!lockedAccounts[_from] && !lockedAccounts[_to]);
		require(tradeable);
        if (balances[_from] >= _value
            && allowed[_from][msg.sender] >= _value
            && _value > 0
            && balances[_to] + _value > balances[_to]) {
                
            Transfer( _from, _to,  _value);
                
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            balances[_to] += _value;
            return true;
        } else {
            return false;
        }
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        Approval(msg.sender,  _spender, _value);
        allowed[msg.sender][_spender] = _value;
        return true;
    }
    function allowance(address _owner, address _spender) constant public returns (uint remaining){
        return allowed[_owner][_spender];
    }
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
   
   modifier notLocked(){
       require (!lockedAccounts[msg.sender]);
       _;
   }
} 
contract EtherealTipJar  is EtherealFoundationOwned{
    string public constant CONTRACT_NAME = "EtherealTipJar";
    string public constant CONTRACT_VERSION = "B";
    string public constant QUOTE = "&#39;The universe never did make sense; I suspect it was built on government contract.&#39; -Robert A. Heinlein";
    
    
    event RecievedTip(address indexed from, uint256 value);
	function () payable public {
		RecievedTip(msg.sender, msg.value);		
	}
	
	event TransferedEth(address indexed to, uint256 value);
	function TransferEth(address to, uint256 value) public onlyOwner{
	    require(this.balance >= value);
	    
        if(value > 0)
		{
			to.transfer(value);
			TransferedEth(to, value);
		}   
	}
    
    event TransferedERC20(address tokenContract, address indexed to, uint256 value);
	function TransferERC20(address tokenContract, address to, uint256 value) public onlyOwner{
	    
	    EtherealToken token = EtherealToken(tokenContract);
	    
        if(value > 0)
		{
			token.transfer(to, value);
			TransferedERC20(tokenContract,to, value);
		}   
	}
}