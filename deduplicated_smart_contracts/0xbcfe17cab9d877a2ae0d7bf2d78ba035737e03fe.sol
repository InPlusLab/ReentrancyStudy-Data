/**
 *Submitted for verification at Etherscan.io on 2020-01-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

pragma solidity >=0.4.22 <0.6.0;


contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    
    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
   
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

}

contract BaseToken is  SafeMath,Ownable{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public isFreeze;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenFunds(address target, bool frozen);
    
    
    constructor(uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        uint256 decimals
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = tokenName;                                  
        symbol = tokenSymbol;                              
    }

    modifier not_frozen(){
        require(isFreeze[msg.sender]==false);
        _;
    }
    function transfer(address _to, uint256 _value) public not_frozen returns (bool) {
        require(_to != address(0));
		require(_value > 0); 
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
		uint previousBalances = balanceOf[msg.sender] + balanceOf[_to];		
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
		assert(balanceOf[msg.sender]+balanceOf[_to]==previousBalances);
        return true;
    }

    function approve(address _spender, uint256 _value) public not_frozen returns (bool success) {
		require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public not_frozen returns (bool success) {
        require (_to != address(0));
		require (_value > 0); 
        require (balanceOf[_from] >= _value) ;
        require (balanceOf[_to] + _value > balanceOf[_to]);
        require (_value <= allowance[_from][msg.sender]);
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
      //冻结解冻
    function freezeOneAccount(address target, bool freeze) onlyOwner public {
        require(freeze!=isFreeze[target]); 
        isFreeze[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
    
    //批量冻结解冻
    function multiFreeze(address[] targets,bool freeze) onlyOwner {
        for(uint256 i = 0; i < targets.length ; i++){
            freezeOneAccount(targets[i],freeze);
        }
    }
    
}

contract MIUCoin is BaseToken
{
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        uint256 decimals
    )BaseToken(initialSupply, tokenName,tokenSymbol,decimals)public {}
    
    
    bool public isSendGiftOpen  = false;
    bool public auto_lock   = false;
    uint256 public init_lock_period  = 90 days ;
    uint256 public auto_send_amount;  
    mapping (address => uint) public lockedAmount;
    
    address[] public lockedAddress;
    mapping(address => bool) public isExsitLocked;
    uint256 public lockedAddressAmount;
    event LockToken(address target, uint256 amount);
    event OwnerUnlock(address from,uint256 amount);
    function sum(uint256[] data) public view returns (uint256) {
        uint256 S;
        for(uint i;i < data.length;i++) {
            S += data[i];
        }
        return S;
    }

    function setGiftSendFlag(bool openOrClose) public onlyOwner {
        require(openOrClose!=isSendGiftOpen);
        isSendGiftOpen=openOrClose;
    }

    function setAutoLockFlag(bool openOrClose) public onlyOwner {
        require(openOrClose!=auto_lock);
        auto_lock=openOrClose;
    }

    function setInitLockPeriod(uint newPeriod) public onlyOwner {
        init_lock_period=newPeriod;
    }

    //批量转账
    function SendGiftMultiAddress(address[] _recivers, uint256[] _values) public onlyOwner 
    {
        require (_recivers.length == _values.length);
        require(balanceOf[msg.sender]>=sum(_values));
        address receiver;
        uint256 value;

        for(uint256 i = 0; i < _recivers.length ; i++){
            receiver = _recivers[i];
            value = _values[i];
            transfer(receiver,value);
            emit Transfer(msg.sender,receiver,value);
            
            //自动锁仓
            if(auto_lock==true)
            {
                lockToken(receiver,value);
            }
        }
    }

      //锁仓
     function lockToken (address target,uint256 lockAmount) onlyOwner public returns(bool res)
    {
        require(target != address(0));
		require(lockAmount > 0); 
        require(balanceOf[target] >= lockAmount);
        uint previousBalances = balanceOf[target]+lockedAmount[target];
        balanceOf[target] -= lockAmount;
        lockedAmount[target] += lockAmount;
        if  (isExsitLocked[target]==false)
        {
            isExsitLocked[target]=true;
            lockedAddress.push(target);
            lockedAddressAmount+=1;
        }
        emit LockToken(target, lockAmount);
        assert(previousBalances==balanceOf[target]+lockedAmount[target]);
        return true;
    }
    
 //解锁
     function ownerUnlock (address target, uint256 amount) onlyOwner public returns(bool res) 
     {
        require(target != address(0));
        require(amount > 0); 
        require(lockedAmount[target] >= amount);
        uint previousBalances = balanceOf[target]+lockedAmount[target];
        balanceOf[target] += amount;
        lockedAmount[target] -= amount;
        emit OwnerUnlock(target,amount);
        assert(previousBalances==balanceOf[target]+lockedAmount[target]);
        return true;
    }

    function unlockAll(address target) onlyOwner public returns(bool res) 
    {
        require(target != address(0));
        ownerUnlock(target,lockedAmount[target]);
    }
}