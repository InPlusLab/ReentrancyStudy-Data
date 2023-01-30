/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;

interface publicCalls {
  function setOwnerTokenService (  ) external;
  function tokenCreatedSet ( address _address, address _tokenCreated ) external;
  function tokenICOCreatedSet ( address _address, address _tokenICOCreated ) external;
  function amountOfMNEForToken (  ) external view returns ( uint256 );
  function amountOfMNEForTokenICO (  ) external view returns ( uint256 );
  function ethFeeForToken (  ) external view returns ( uint256 );
  function ethFeeForTokenICO (  ) external view returns ( uint256 );  
  function tokenWithoutICOCount (  ) external view returns ( uint256 );
  function tokenICOCount (  ) external view returns ( uint256 );  
  function tokenWithoutICOCountSet ( uint256 _tokenWithoutICOCount ) external;
  function tokenICOCountSet ( uint256 _tokenICOCount ) external;
}

interface genesis {
  function availableBalanceOf ( address _address ) external view returns ( uint256 Balance );  
}

contract tokenService
{
	
address public ownerMain = 0x0000000000000000000000000000000000000000;	
address public updaterAddress = 0x0000000000000000000000000000000000000000;
function setUpdater() public {if (updaterAddress == 0x0000000000000000000000000000000000000000) updaterAddress = msg.sender; else revert();}
function updaterSetOwnerMain(address _address) public {if (tx.origin == updaterAddress) ownerMain = _address; else revert();}

function setOwnerMain() public {
	if (tx.origin == updaterAddress)
		ownerMain = msg.sender;
	else
		revert();
}

modifier onlyOwner(){
    require(msg.sender == ownerMain);
     _;
}

publicCalls public pc;
genesis public gn;
	
constructor(address _publicCallsAddress, address _genesisAddress) public {
setUpdater();
pc = publicCalls(_publicCallsAddress);
pc.setOwnerTokenService();
gn = genesis(_genesisAddress);
}

function reloadGenesis(address _address) public
{
	if (msg.sender == updaterAddress)
	{
		gn = genesis(_address);		
	}
	else revert();
}

function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerTokenService();} else revert();}

event CreateTokenHistory(address indexed _owner, address indexed _address);
event CreateTokenICOHistory(address indexed _owner, address indexed _address);

function CreateToken(address _from, uint256 _msgvalue) public onlyOwner returns (uint256 _mneToBurn, address _address) {
	uint256 mneToBurn = pc.amountOfMNEForToken();
		
	if (!(gn.availableBalanceOf(_from) >= mneToBurn)) revert('(!(gn.availableBalanceOf(_from) >= mneToBurn))');	
	
	uint256 feesToPayToContract = pc.ethFeeForToken();
	uint256 feesToPayToSeller = 0;
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * 0;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	Token token = new Token(_from);
	pc.tokenCreatedSet(_from, address(token));
	emit CreateTokenHistory(_from, address(token));
	pc.tokenWithoutICOCountSet(pc.tokenWithoutICOCount() + 1);
	return (mneToBurn, address(token));
}

function CreateTokenICO(address _from, uint256 _msgvalue) public onlyOwner returns (uint256 _mneToBurn, address _address) {
	uint256 mneToBurn = pc.amountOfMNEForTokenICO();
	
	if (!(gn.availableBalanceOf(_from) >= mneToBurn)) revert('(!(gn.availableBalanceOf(_from) >= mneToBurn))');	
	
	uint256 feesToPayToContract = pc.ethFeeForTokenICO();
	uint256 feesToPayToSeller = 0;
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * 0;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	TokenICO token = new TokenICO(payable(_from));
	pc.tokenICOCreatedSet(_from, address(token));
	emit CreateTokenICOHistory(_from, address(token));
	pc.tokenICOCountSet(pc.tokenICOCount() + 1);
	return (mneToBurn, address(token));
}
}

contract Token {
    string public symbol = "";
    string public name = "";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 0;
    address owner = 0x0000000000000000000000000000000000000000;
    bool setupDone = false;
   
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
    mapping(address => uint256) balances;
 
    mapping(address => mapping (address => uint256)) allowed;
 
    constructor(address adr) public {
        owner = adr;        
    }
   
    function SetupToken(string memory tokenName, string memory tokenSymbol, uint256 tokenSupply) public
    {
        if (msg.sender == owner && setupDone == false)
        {
            symbol = tokenSymbol;
            name = tokenName;
            _totalSupply = tokenSupply * 1000000000000000000;
            balances[owner] = _totalSupply;
            setupDone = true;
        }
    }
 
    function totalSupply() public view returns (uint256 totalSupply) {        
        return _totalSupply;
    }
 
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )  public returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract TokenICO {
    string public symbol = "";
    string public name = "";
    uint8 public constant decimals = 18;
	string public constant ICOFactoryVersion = "1.0";
    uint256 _totalSupply = 0;
	uint256 _oneEtherEqualsInWei = 0;	
	uint256 _maxICOpublicSupply = 0;
	uint256 _ownerICOsupply = 0;
	uint256 _currentICOpublicSupply = 0;
	uint256 _blockICOdatetime = 0;
	address payable _ICOfundsReceiverAddress = 0x0000000000000000000000000000000000000000;
	address _remainingTokensReceiverAddress = 0x0000000000000000000000000000000000000000;
    address payable owner = 0x0000000000000000000000000000000000000000;	
    bool setupDone = false;
	bool isICOrunning = false;
	bool ICOstarted = false;
	uint256 ICOoverTimestamp = 0;
   
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event Burn(address indexed _owner, uint256 _value);
 
    mapping(address => uint256) balances;
 
    mapping(address => mapping (address => uint256)) allowed;
 
    constructor(address payable adr) public {
        owner = adr;        
    }
	
	receive() external payable
	{
		if ((isICOrunning && _blockICOdatetime == 0) || (isICOrunning && _blockICOdatetime > 0 && now <= _blockICOdatetime))
		{
			uint256 _amount = ((msg.value * _oneEtherEqualsInWei) / 1000000000000000000);
			
			if (((_currentICOpublicSupply + _amount) > _maxICOpublicSupply) && _maxICOpublicSupply > 0) revert();
			
			if(!_ICOfundsReceiverAddress.send(msg.value)) revert();					
			
			_currentICOpublicSupply += _amount;
			
			balances[msg.sender] += _amount;
			
			_totalSupply += _amount;			
			
			emit Transfer(address(this), msg.sender, _amount);
		}
		else
		{
			revert();
		}
	}
   
    function SetupToken(string memory tokenName, string memory tokenSymbol, uint256 oneEtherEqualsInWei, uint256 maxICOpublicSupply, uint256 ownerICOsupply, address remainingTokensReceiverAddress, address payable ICOfundsReceiverAddress, uint256 blockICOdatetime) public
    {
        if (msg.sender == owner && !setupDone)
        {
            symbol = tokenSymbol;
            name = tokenName;
			_oneEtherEqualsInWei = oneEtherEqualsInWei;
			_maxICOpublicSupply = maxICOpublicSupply * 1000000000000000000;									
			if (ownerICOsupply > 0)
			{
				_ownerICOsupply = ownerICOsupply * 1000000000000000000;
				_totalSupply = _ownerICOsupply;
				balances[owner] = _totalSupply;
				emit Transfer(address(this), owner, _totalSupply);
			}			
			_ICOfundsReceiverAddress = ICOfundsReceiverAddress;
			if (_ICOfundsReceiverAddress == 0x0000000000000000000000000000000000000000) _ICOfundsReceiverAddress = owner;
			_remainingTokensReceiverAddress = remainingTokensReceiverAddress;
			_blockICOdatetime = blockICOdatetime;			
            setupDone = true;
        }
    }
	
	function StartICO() public returns (bool success)
    {
        if (msg.sender == owner && !ICOstarted && setupDone)
        {
            ICOstarted = true;			
			isICOrunning = true;			
        }
		else
		{
			revert();
		}
		return true;
    }
	
	function StopICO() public returns (bool success)
    {
        if (msg.sender == owner && isICOrunning)
        {            
			if (_remainingTokensReceiverAddress != 0x0000000000000000000000000000000000000000 && _maxICOpublicSupply > 0)
			{
				uint256 _remainingAmount = _maxICOpublicSupply - _currentICOpublicSupply;
				if (_remainingAmount > 0)
				{
					balances[_remainingTokensReceiverAddress] += _remainingAmount;
					_totalSupply += _remainingAmount;
					emit Transfer(address(this), _remainingTokensReceiverAddress, _remainingAmount);	
				}
			}				
			isICOrunning = false;	
			ICOoverTimestamp = now;
        }
		else
		{
			revert();
		}
		return true;
    }
	
	function BurnTokens(uint256 amountInWei) public returns (bool success)
    {
		if (balances[msg.sender] >= amountInWei)
		{
			balances[msg.sender] -= amountInWei;
			_totalSupply -= amountInWei;
			emit Burn(msg.sender, amountInWei);
			emit Transfer(msg.sender, 0x0000000000000000000000000000000000000000, amountInWei);
		}
		else
		{
			revert();
		}
		return true;
    }
 
    function totalSupply() public view returns (uint256 totalSupplyValue) {        
        return _totalSupply;
    }
	
	function OneEtherEqualsInWei() public view returns (uint256 oneEtherEqualsInWei) {        
        return _oneEtherEqualsInWei;
    }
	
	function MaxICOpublicSupply() public view returns (uint256 maxICOpublicSupply) {        
        return _maxICOpublicSupply;
    }
	
	function OwnerICOsupply() public view returns (uint256 ownerICOsupply) {        
        return _ownerICOsupply;
    }
	
	function CurrentICOpublicSupply() public view returns (uint256 currentICOpublicSupply) {        
        return _currentICOpublicSupply;
    }
	
	function RemainingTokensReceiverAddress() public view returns (address remainingTokensReceiverAddress) {        
        return _remainingTokensReceiverAddress;
    }
	
	function ICOfundsReceiverAddress() public view returns (address ICOfundsReceiver) {        
        return _ICOfundsReceiverAddress;
    }
	
	function Owner() public view returns (address ownerAddress) {        
        return owner;
    }
	
	function SetupDone() public view returns (bool setupDoneFlag) {        
        return setupDone;
    }
    
	function IsICOrunning() public view returns (bool isICOrunningFalg) {        
        return isICOrunning;
    }
	
	function IsICOstarted() public view returns (bool isICOstartedFlag) {        
        return ICOstarted;
    }
	
	function ICOoverTimeStamp() public view returns (uint256 ICOoverTimestampCheck) {        
        return ICOoverTimestamp;
    }
	
	function BlockICOdatetime() public view returns (uint256 blockStopICOdate) {        
        return _blockICOdatetime;
    }
	
	function TimeNow() public view returns (uint256 timenow) {        
        return now;
    }
	 
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}