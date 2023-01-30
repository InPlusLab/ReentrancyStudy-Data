/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity 0.5.10;

contract Ownable {

// A list of owners which will be saved as a list here, 
// and the values are the owner¡¯s names. 

  address newOwner; // temp for confirm;
  mapping (address=>bool) owners;
  address owner;

// all events will be saved as log files
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AddOwner(address newOwner,string name);
  event RemoveOwner(address owner);
  /**
   * @dev Ownable constructor , initializes sender¡¯s account and 
   * set as owner according to default value according to contract
   *
   */

   // this function will be executed during initial load and will keep the smart contract creator (msg.sender) as Owner
   // and also saved in Owners. This smart contract creator/owner is 
   // Mr. Samret Wajanasathian CTO of Shuttle One Pte Ltd (https://www.shuttle.one)

   constructor() public {
    owner = msg.sender;
    owners[msg.sender] = true;
  }

// function to check if the executor is the owner? This to ensure that only the person 
// who has right to execute/call the function has the permission to do so.
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }

// This function has only one Owner. The ownership can be transferrable and only
//  the current Owner will only be  able to execute this function.
//  Onwer can be Contract address
  function transferOwnership(address  _newOwner) public onlyOwner{
    emit OwnershipTransferred(owner,_newOwner);
    newOwner = _newOwner;

  }
  
  // Function to confirm New Owner can execute
  function newOwnerConfirm() public returns(bool){
        if(newOwner == msg.sender)
        {
            owner = newOwner;
            return true;
        }
        return false;
  }

// Function to check if the person is listed in a group of Owners and determine
// if the person has the any permissions in this smart contract such as Exec permission.
  
  modifier onlyOwners(){
    require(owners[msg.sender] == true);
    _;
  }

// Function to add Owner into a list. The person who wanted to add a new owner into this list but be an existing
// member of the Owners list. The log will be saved and can be traced / monitor who¡¯s called this function.
  
  function addOwner(address _newOwner,string memory newOwnerName) public onlyOwners{
    require(owners[_newOwner] == false);
    require(newOwner != msg.sender);
    owners[_newOwner] = true;
    emit AddOwner(_newOwner,newOwnerName);
  }

// Function to remove the Owner from the Owners list. The person who wanted to remove any owner from Owners
// List must be an existing member of the Owners List. The owner cannot evict himself from the Owners
// List by his own, this is to ensure that there is at least one Owner of this ShuttleOne Smart Contract.
// This ShuttleOne Smart Contract will become useless if there is no owner at all.

  function removeOwner(address _owner) public onlyOwners{
    require(_owner != msg.sender);  // can't remove your self
    owners[_owner] = false;
    emit RemoveOwner(_owner);
  }
// this function is to check of the given address is allowed to call/execute the particular function
// return true if the given address has right to execute the function.
// for transparency purpose, anyone can use this to trace/monitor the behaviors of this ShuttleOne smart contract.

  function isOwner(address _owner) public view returns(bool){
    return owners[_owner];
  }

}


contract ERC20 {
	   event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
}

contract WDAI is Ownable {
    string public name     = "Wrapped DAI";
    string public symbol   = "WDAI";
    uint8  public decimals = 18;
    string public company  = "ShuttleOne Pte Ltd";
    uint8  public version  = 2;

    event  Approval(address indexed _tokenOwner, address indexed _spender, uint256 _amount);
    event  Transfer(address indexed _from, address indexed _to, uint256 _amount);
    
    event  Deposit(address indexed _from, uint256 _amount);
    event  Withdraw(address indexed _to, uint256 _amount);

    mapping (address => uint256) public  balance;
    mapping (address => mapping (address => uint256))  public  allowed;

    mapping (address => bool)  public allowTransfer;

    ERC20  daiToken;
    
     constructor() public {
         daiToken = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); //Dai Stablecoin (DAI)
         
     }
     
    function deposit(address _from,uint256 amount) public returns (bool) {
        
        if(daiToken.transferFrom(_from,address(this),amount) == true){
            balance[_from] += amount;
            emit Deposit(_from,amount);
            emit Transfer(address(0),_from,amount);
        }
    }
    
    function withdraw(uint256 _amount) public {
        require(balance[msg.sender] >= _amount,"WDAI/ERROR-out-of-balance-withdraw");
        balance[msg.sender] -= _amount;
        daiToken.transfer(msg.sender,_amount);
        emit Withdraw(msg.sender, _amount);
        emit Transfer(msg.sender,address(0),_amount);
    }

    function balanceOf(address _addr) public view returns (uint256){
        return balance[_addr]; 
     }

    function totalSupply() public view returns (uint) {
        return daiToken.balanceOf(address(this));
    }

     function approve(address _spender, uint256 _amount) public returns (bool){
            allowed[msg.sender][_spender] = _amount;
            emit Approval(msg.sender, _spender, _amount);
            return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256){
          return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(balance[msg.sender] >= _amount,"WDAI/ERROR-out-of-balance-transfer");
        require(_to != address(0),"WDAI/ERROR-transfer-addr-0");
        require(allowTransfer[msg.sender],"WDAI/ERROR-transfer-not-allow");

        balance[msg.sender] -= _amount;
        balance[_to] += _amount;
        emit Transfer(msg.sender,_to,_amount);
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool)
    {
        require(balance[_from] >= _amount,"WDAI/ERROR-transFrom-out-of");
        require(allowed[_from][msg.sender] >= _amount,"WDAI/ERROR-spender-outouf"); 
        require(allowTransfer[msg.sender],"WDAI/ERROR-transfrom-not-allow");

        balance[_from] -= _amount;
        balance[_to] += _amount;
        allowed[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);

        return true;
    }
    
    function intTransfer(address _from, address _to, uint256 _amount) external onlyOwners returns(bool){
           require(balance[_from] >= _amount,"WDAI/ERROR-intran-outof");
           require(_to != address(0),"WDAI/ERROR-intran-addr0");
           
           balance[_from] -= _amount; 
           balance[_to] += _amount;
    
           emit Transfer(_from,_to,_amount);
           return true;
    }
     
    function intWithdraw(address _to,uint256 _amount) public onlyOwners returns(bool){
        require(balance[_to] >= _amount,"WDAI/ERROR-withdraw-outof");
        balance[_to] -= _amount;
        daiToken.transfer(_to,_amount);
        emit Withdraw(_to, _amount);
        emit Transfer(_to,address(0),_amount);
    } 
    
    function intWithdrawAndTran(address _from,address _to,uint256 _amount) public onlyOwners returns(bool){
         require(balance[_from] >= _amount,"WDAI/ERROR-withdraw-outof2");
         balance[_from] -= _amount;
         daiToken.transfer(_to,_amount);
         emit Withdraw(_from,_amount);
         emit Transfer(_to,address(0),_amount);
    }
    
    function setAllowTransfer(address _addr,bool _allow) public onlyOwners returns(bool){
        allowTransfer[_addr] = _allow;
    }
    
}