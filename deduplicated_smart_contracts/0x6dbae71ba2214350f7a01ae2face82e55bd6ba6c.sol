/**
 *Submitted for verification at Etherscan.io on 2020-03-06
*/

/**
 *Submitted for verification at Etherscan.io on 2020-03-04
*/

pragma solidity ^0.5.12;

contract ERC20 {
  function balanceOf(address who) public view returns (uint256);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Multisig {
    function executeChange(uint256 tid) public view returns (bool);
    function executeAdminChange(uint256 tid, address newowner) public returns (bool);
    function requestOwnerChange(address owner, address newowner) public returns (uint256);
    function vestingTransaction(address owner, address holderaddress, uint256 vestAmount) public returns (uint256);
    function mintTransaction(address owner, uint256 amount, uint256 time) public returns (uint256);
}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract AssetfinX is ERC20 {
    
    uint256 constant TOTALSUPPLY = 50000000;

    using SafeMath for uint256;
    
    string public name = "AssetfinX";
    string public symbol = "AFX";
    uint8 public decimals = 18;
    uint256 public totalSupply = TOTALSUPPLY*10**uint256(decimals);
	address public owner;
	uint256 public circulatingSupply;
	bool public contractStatus;
	address public multisigAddress;
	uint256 public minfreezeTime;

    mapping (address => uint256) public balances;
	mapping (address => uint256[2]) public freezeOf;
	mapping (address => uint256) public lockOf;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => mapping (uint256 => mapping(uint256 => uint256))) public mintTransaction;
    mapping (address => mapping (address => uint256)) public ownerTransaction;
    mapping (address => mapping (address => mapping(uint256 => uint256))) public vestTransaction;

	event Freeze(address indexed from, uint256 value, uint256 freezetime);
	event Unfreeze(address indexed from, uint256 value, uint256 unfreezetime);
	event Lock(address indexed from, uint256 amount, uint256 locktime);
    event Release(address indexed from, uint256 amount, uint256 releasetime);

    constructor(uint256 _initialSupply, bool _status, address _multisigAddress) public  {
        balances[msg.sender] = _initialSupply;   
		circulatingSupply = _initialSupply;           
		owner = msg.sender;
		contractStatus = _status;
		multisigAddress = _multisigAddress;
        emit Transfer(address(0), owner, _initialSupply);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier contractActive(){
        require(contractStatus, "Contract is inactive");
        _;
    }
    
    modifier multisigCheck(uint256 _id){
        require(Multisig(multisigAddress).executeChange(_id), "Not confirmed");
        _;
    }
    
    modifier multisigAdminCheck(uint256 _id, address _newaddress){
        require(Multisig(multisigAddress).executeAdminChange(_id, _newaddress), "Not confirmed");
        _;
    }
    
    /** 
     * @dev Set Minimum time for freeze
     * @param _time Minimum time
     */ 
    function setminimumFreezetime(uint256 _time) public contractActive onlyOwner returns (bool) {
        require(_time > 0, "Invalid time");
        minfreezeTime = _time;
        return true;
    }

    /**
     * @dev Request Multisig contract to change admin 
     * @param _newAdmin New admin address 
     */ 
    function requestchangeAdmin(address _newAdmin) public contractActive onlyOwner returns (bool) {
        ownerTransaction[msg.sender][_newAdmin] = Multisig(multisigAddress).requestOwnerChange(owner, _newAdmin);
        return true;
    }
    
    /**
     * @dev Change admin 
     * @param _address New owner address
     */ 
    function changeAdmin(address _address) public contractActive onlyOwner multisigAdminCheck(ownerTransaction[owner][_address], _address) returns (bool) {
        owner = _address;
        return true;
    }
    
    /**
     * @dev Request Multisig contract for vesting
     * @param _address Token holder address
     * @param _amount Amount to be vested
     */ 
    function vestRequest(address _address, uint256 _amount) public contractActive onlyOwner returns (bool) {
       vestTransaction[owner][_address][_amount] = Multisig(multisigAddress).vestingTransaction(owner, _address, _amount);
       return true;
    }
    
    /**
     * @dev Request Multisig contract for Mint 
     * @param _amount Amount to be Minted
     * @param _time Current time
     */ 
    function mintRequest(uint256 _amount, uint256 _time) public contractActive onlyOwner returns (bool) {
       mintTransaction[owner][_amount][_time] = Multisig(multisigAddress).mintTransaction(owner, _amount, _time);
       return true;
    }

    /**
     * @dev Check balance of the holder
     * @param tokenOwner Token holder address
     */ 
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    /**
     * @dev Transfer token to specified address
     * @param _to Receiver address
     * @param _value Amount of the tokens
     */
    function transfer(address _to, uint256 _value) public contractActive returns (bool) {
        require(_to != address(0), "Null address");                                         
		require(_value > 0, "Invalid Value"); 
        require(balances[msg.sender] >= _value, "Insufficient balance");                           
        _transfer(msg.sender, _to, _value); 
        return true;
    }
 
    /**
     * @dev Approve respective tokens for spender
     * @param _spender Spender address
     * @param _value The amount of tokens to be allowed
     */
    function approve(address _spender, uint256 _value) public contractActive returns (bool) {
        require(_spender != address(0), "Null address");
        require(_value >= 0, "Invalid value");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev To view approved balance
     * @param holder The holder address
     * @param delegate The spender address
     */ 
    function allowance(address holder, address delegate) public view returns (uint256) {
        return allowed[holder][delegate];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from  The holder address
     * @param _to  The Receiver address
     * @param _value  the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public contractActive returns (bool) {
        require( _to != address(0), "Null address");
        require(_from != address(0), "Null address");
        require( _value > 0 , "Invalid value"); 
        require( _value <= balances[_from] , "Insufficient balance");
        require( _value <= allowed[_from][msg.sender] , "Insufficient allowance");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
    
    /**
     * @dev Internal Transfer function
     * @param _from  The holder address
     * @param _to  The Receiver address
     * @param _value  the amount of tokens to be transferred
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value); 
    }
    
    /**
     * @dev Freeze tokens - User can freeze again only after UnFreezeing the previous one.
     * @param _value  The amount of tokens to be freeze
     * @param _time  Timeperiod for freezing in seconds
     */
	function freeze(uint256 _value, uint256 _time) public contractActive returns (bool) {
        require(_value > 0, "Invalid Value");
        require(freezeOf[msg.sender][0] == 0, "Tokens already frozen");
        require( _value <= balances[msg.sender], "Insufficient balance"); 
        require(_time >= minfreezeTime, "Invalid time");
        balances[msg.sender] = balances[msg.sender].sub(_value); 
        freezeOf[msg.sender][0] = _value; 
        freezeOf[msg.sender][1] = now.add(_time);
        emit Transfer(msg.sender, address(this), _value);
        emit Freeze(msg.sender, _value, now);
        return true;
    }
	
	/**
     * @dev UnFreeze tokens
     */
	function unfreeze() public contractActive returns (bool) {
        require(freezeOf[msg.sender][0] != 0, "Sender has no tokens to unfreeze");
		require(now >= freezeOf[msg.sender][1], "Invalid time");
		balances[msg.sender] = balances[msg.sender].add(freezeOf[msg.sender][0]);
		emit Transfer(address(this), msg.sender, freezeOf[msg.sender][0]);
        emit Unfreeze(msg.sender, freezeOf[msg.sender][0], now);
        freezeOf[msg.sender][0] = 0;
        return true;
    }
    
    /**
     * @dev Mint tokens to increase the circulating supply
     * @param _amount The amount of tokens to be Minted
     * @param _reqestedTime  Request submitted time
     */
    function mint(uint256 _amount, uint256 _reqestedTime) public contractActive onlyOwner multisigCheck(mintTransaction[owner][_amount][_reqestedTime]) returns (bool) {
        require( _amount > 0, "Invalid amount");
        require(circulatingSupply.add(_amount) <= totalSupply, "Supply exceeds limit");
        
        circulatingSupply = circulatingSupply.add(_amount);
        balances[owner] = balances[owner].add(_amount);
        
        emit Transfer(address(0), owner, _amount);
        return true;
    }
    
    /**
     * @dev Vesting lock tokens
     * @param _address Holder address
     * @param _amount Amount of token to be locked
     */
    function vestLock(address _address, uint256 _amount) public contractActive onlyOwner multisigCheck(vestTransaction[owner][_address][_amount]) returns (bool) {
       require(_amount > 0, "Invalid Amount");
       require(balances[_address] >= _amount, "Invalid balance");
       
       balances[_address] = balances[_address].sub(_amount);
       lockOf[_address] = lockOf[_address].add(_amount);
       emit Transfer(_address,address(this),_amount);
       emit Lock(_address,_amount,now);
       return true;
    }
    
    /**
     * @dev Vesting Release token
     * @param _address Holder address 
     * @param _amount Amount of token to be released
     */ 
    function vestRelease(address _address, uint256 _amount) public contractActive onlyOwner multisigCheck(vestTransaction[owner][_address][_amount]) returns (bool) {
       require(_amount > 0, "Invalid Amount");
       require(lockOf[_address] >= _amount, "Insufficient Amount");
       
       lockOf[_address] = lockOf[_address].sub(_amount);
       balances[_address] = balances[_address].add(_amount);
       emit Transfer(address(this), _address, _amount);
       emit Release(_address, _amount,now);
       return true;
    }
    
    /**
     * @dev updatecontractStatus to change the status of the contract from active to inactive
     * @param _status status of the contract
     */
    function updatecontractStatus(bool _status) public onlyOwner returns(bool) {
        require(contractStatus != _status, "Invalid status");
        contractStatus = _status;
        return true;
    }
    
    /**
     * dev Update Multisig Contract address 
     * @param _address New contract address 
     */ 
    function updateMultisigAddress(address _address) public contractActive onlyOwner returns(bool) {
        require(_address != address(0), "Null Address");
        multisigAddress = _address;
        return true;
    }
    
}