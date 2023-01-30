/**
 *Submitted for verification at Etherscan.io on 2020-03-29
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

contract S1ERC20 {
	   event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
       
       function intTransfer(address _from, address _to, uint256 _amount) external returns(bool);
}

contract ShuttleOne_InternalTran is Ownable {
    
    S1ERC20  public wdai;
    S1ERC20  public szo;
    address public feeAddr;
    address public feeSZOAddr;
    constructor() public {
         wdai = S1ERC20(0x76eA49614b6c34194e441Fd8027c93e71AFB199a); // wdai address
     }
     
     function setSZOAddr(address _addr) public onlyOwners returns (bool){
         szo = S1ERC20(_addr);
     }
     
     function setFeeAddr(address _addr) public onlyOwners returns (bool){
         feeAddr = _addr;
         return true;
     }
     
     function setSZOFeeAddr(address _addr) public onlyOwners returns (bool){
         feeSZOAddr = _addr;
     }
     
   function transferWithFee(address _from, address _to, uint256 _value,uint256 _fee) external onlyOwners returns(bool){
        wdai.intTransfer(_from,_to,_value - _fee);
        wdai.intTransfer(_from,feeAddr,_fee);
        return true;
   }   
   
   function transferFeeWithSZO(address _from, address _to, uint256 _value,uint256 _fee) external onlyOwners returns(bool){
        wdai.intTransfer(_from,_to,_value);
        szo.intTransfer(_from,feeSZOAddr,_fee);
        return true;
   }   
}