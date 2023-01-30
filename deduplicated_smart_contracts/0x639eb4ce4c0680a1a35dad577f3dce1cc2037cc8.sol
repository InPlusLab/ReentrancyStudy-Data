/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

pragma solidity ^0.5.12;
/*Math operations with safety checks */
contract SafeMath { 
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;  
    }
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {	
    return a/b;  
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
  function safePower(uint a, uint b) internal pure returns (uint256) {
      uint256 c = a**b;
      return c;  
    }
}

contract SEET is SafeMath{
    string public name;    
    string public symbol;    
    uint8 public decimals;    
    uint256 public totalSupply;  
    address payable public owner;
    mapping (address => uint256) public balanceOf;/* This creates an array with all balances */
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);/* This generates a public event on the blockchain that will notify clients */
    event Burn(address indexed from, uint256 value);  /* This notifies clients about the amount burnt */
    event Approval(address indexed owner, address indexed spender, uint256 value);  
    event SetOwner(address add);
    
    constructor (/* Initializes contract with initial supply tokens to the creator of the contract */
        uint256 initialSupply,string memory tokenName,string memory tokenSymbol) public{
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = 18;                                      // Amount of decimals for display purposes
        owner = msg.sender;
    }
    
    function transfer(address _to, uint256 _value) public  returns (bool success){/* Send coins */
        require (_to != address(0x0));                        // Prevent transfer to 0x0 address. 
        require (_value >= 0) ;																	
        require (balanceOf[msg.sender] >= _value) ;           // Check if the sender has enough
        require (safeAdd(balanceOf[_to] , _value) >= balanceOf[_to]) ; // Check for overflows
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value); // Subtract from the sender
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);               // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }
 
    function approve(address _spender, uint256 _value) public returns (bool success) {/* Allow another contract to spend some tokens in your behalf */
        allowance[msg.sender][_spender] = _value;	
        emit Approval(msg.sender, _spender, _value);
        return true;    
    }
    
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool success) {/* A contract attempts to get the coins */
        require (_to != address(0x0)) ;                                // Prevent transfer to 0x0 address. Use burn() instead
        require (_value >= 0) ;													
        require (balanceOf[_from] >= _value) ;                 // Check if the sender has enough
        require (safeAdd(balanceOf[_to] , _value) >= balanceOf[_to]) ;  // Check for overflows
        require (_value <= allowance[_from][msg.sender]) ;     // Check allowance
        balanceOf[_from] = safeSub(balanceOf[_from], _value);                           // Subtract from the sender
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true; 
      }

    function burn(uint256 _value) public returns (bool success) {
        require (balanceOf[msg.sender] >= _value) ;            // Check if the sender has enough
        require (_value > 0) ; 
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);            // Subtract from the sender
        totalSupply = safeSub(totalSupply,_value);                                // Updates totalSupply
        emit Burn(msg.sender, _value);			
        emit Transfer(msg.sender, address(0), _value);
        return true;
    } 
    
    function setSymbol(string memory _symbol)public   {        
        require (msg.sender == owner) ; 
        symbol = _symbol;    
    } 

    function setName(string memory _name)public {        
        require (msg.sender == owner) ; 
        name = _name;    
    } 

    function setOwner(address payable _add)public{
        require (msg.sender == owner && _add != address(0x0)) ;
        owner = _add ;						 
        emit SetOwner(_add);
    }
}