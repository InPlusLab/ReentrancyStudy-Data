/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity  ^0.4.19;

contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}



contract CREDITS is Ownable{
    string public name = 'tomatolol';
    string public symbol = 'lololol';
    uint8 public constant decials = 8;//18
    uint256 public totalSupply = (30 * (10**uint(decials))-1);

    
    address private _beneficiary;
    uint256 private _lockTime;
    uint256 private _lockDelay;
    bool private _releaseRequested;
    uint256 private _totalBurned;
    
    //ALL Lock -> true
    //All UnLock -> false
    bool public Lock = true;
    bool public CanChange = true;
    
    address public Admin;
    address public AddressForReturn;
    address[] Accounts;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) public AccountIsLock;
    mapping(address => bool) public AccountIsNotLock;
    mapping(address => bool) public AccountIsNotLockForReturn;
    mapping(address => uint) public AccountIsLockByDate;
    
    mapping (address => bool) public isHolder;
    mapping (address => bool) public isArrAccountIsLock;
    mapping (address => bool) public isArrAccountIsNotLock;
    mapping (address => bool) public isArrAccountIsNotLockForReturn;
    mapping (address => bool) public isArrAccountIsLockByDate;
    mapping (address => uint) balances;
    
    address [] public Arrholders;
    address [] public ArrAccountIsLock;
    address [] public ArrAccountIsNotLock;
    address [] public ArrAccountIsLockForReturn;
    address [] public ArrAccountIsLockByDate;

    event Transfer(address indexed from, address indexed to,uint256 value);
    event Burn(address indexed from, uint256 value);
    event Add(address indexed from, uint256 value);
    event ReleaseRequested(address account);
 
     /* Send coins */
    function transfer(address _to, uint256 _value) public  {
        require(((!Lock&&AccountIsLock[msg.sender]!=true)||((Lock)&&AccountIsNotLock[msg.sender]==true)||(AccountIsNotLockForReturn[msg.sender]==true
        &&_to==AddressForReturn))&&now>AccountIsLockByDate[msg.sender]);
        require(balanceOf[msg.sender] >= _value);                                   // Check if the sender has enough
        require (balanceOf[_to] + _value >= balanceOf[_to]);                        // Check for overflows
        balanceOf[msg.sender] -= _value;                                            // Subtract from the sender
        balanceOf[_to] += _value;                                                   // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                                          // Notify anyone listening that this transfer took place
        if (isHolder[_to] != true) 
        {
        Arrholders[Arrholders.length++] = _to;
        isHolder[_to] = true;
        }
        
    }
    
  

  modifier IsNotLock{
      require(((!Lock&&AccountIsLock[msg.sender]!=true)||((Lock)&&AccountIsNotLock[msg.sender]==true))&&now>AccountIsLockByDate[msg.sender]);
      _;
     }
    modifier isCanChange{
        require((msg.sender==owner||msg.sender==Admin)&&CanChange==true);
        _;
    }
    
    function CREDITS() public {
        balanceOf[msg.sender] = totalSupply;
        Arrholders[Arrholders.length++]=msg.sender;
        Admin=msg.sender;
    }
    
     function setAdmin(address _address) public onlyOwner{
        require(CanChange);
        Admin=_address;
    }
    
    function setLock(bool _Lock)public isCanChange{
        require(CanChange);
        Lock=_Lock;
    }
    
    function setCanChange(bool _canChange) public onlyOwner{
        require(CanChange);
        CanChange = _canChange;
    }
    
    function setAccountIsLock(address _address, bool _IsLock) public onlyOwner{
        AccountIsLock[_address] = _IsLock;
        if(isArrAccountIsLock[_address] != true){
            ArrAccountIsLock[ArrAccountIsLock.length++] = _address;
            isArrAccountIsLock[_address] = true;
        }
    }

    function setAccountIsNotLock(address _address, bool _IsLock) public onlyOwner{
        AccountIsNotLock[_address] = _IsLock;
        if(isArrAccountIsNotLock[_address] != true){
            ArrAccountIsNotLock[ArrAccountIsNotLock.length++] = _address;
            isArrAccountIsNotLock[_address] = true;
        }
    }
    
    function burn(uint256 _value) public IsNotLock  returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;                      
        Burn(msg.sender, _value);
        return true;
    }
    function add(uint256 _value) public IsNotLock  returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] += _value;            
        totalSupply += _value;                      
        Add(msg.sender, _value);
        return true;
    }
    
    function setSymbol(string _symbol) public onlyOwner{
        require(CanChange);
        symbol = _symbol;
    }
    function setName(string _name) public onlyOwner{
        require(CanChange);
        name = _name;
    }

    function () public payable{
    revert();
    }
   
}