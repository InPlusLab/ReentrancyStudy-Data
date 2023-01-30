/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity ^0.5.1;

/*********************************************************************************
 *********************************************************************************
 *
 * Name of the project: Token With A Message
 * Author: Juan Livingston 
 * TWM
 *
 *********************************************************************************
 ********************************************************************************/

contract ContractReceiver {   
    function tokenFallback(address _from, uint _value, bytes memory _data) public {
    }
}

 /* New ERC20 contract interface */

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) view public returns(uint256);
  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// The GXVC token ERC223

contract TWMToken {

    // Token public variables
    string public name;
    string public symbol;
    uint8 public decimals; 
    string public version = 'v1';
    uint256 public totalSupply;
    uint public price;
    bool locked;

    address rootAddress;
    address payable Owner;
    uint multiplier = 1; // For 0 decimals
    address swapperAddress; // Can bypass a lock

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) freezed;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Message(string _message);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Error(string _message);


    // Modifiers

    modifier onlyOwner() {
        if ( msg.sender != rootAddress && msg.sender != Owner ) revert();
        _;
    }

    modifier onlyRoot() {
        if ( msg.sender != rootAddress ) revert();
        _;
    }

    modifier isUnlocked() {
    	if ( locked && msg.sender != rootAddress && msg.sender != Owner ) revert();
		_;    	
    }

    modifier isUnfreezed(address _to) {
    	if ( freezed[msg.sender] || freezed[_to] ) revert();
    	_;
    }

    modifier validate(string memory _message , uint _value) {
        if ( _value < 1 ) {
            emit Error("Send some tokens");
            return;
        }
        if( bytes(_message).length == 0 ) {
            emit Error("Send your message?");
            return;
        }
        _;
    }

    // Safe math
    function safeAdd(uint x, uint y) internal returns (uint z) {
        require((z = x + y) >= x);
    }
    function safeSub(uint x, uint y) internal returns (uint z) {
        require((z = x - y) <= x);
    }


    // TWM Token constructor
    constructor() public {        
        locked = false;
        totalSupply = 1000000000 * multiplier; // 1,000,000 tokens
        name = 'Token With A Message'; 
        symbol = 'TWM'; 
        decimals = 0; 
        rootAddress = msg.sender;        
        Owner = msg.sender;
        price = 0.001 * 10 ** 18; // 0.001 ether
        balances[rootAddress] = totalSupply; 
        allowed[rootAddress][swapperAddress] = totalSupply;
    }


	// ERC223 Access functions



    // Only root function

    function changeRoot(address _newrootAddress) onlyRoot public returns(bool){
    		allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            rootAddress = _newrootAddress;
            return true;
    }


    // Only owner functions

    function changeOwner(address payable _newOwner) onlyOwner public returns(bool) {
            Owner = _newOwner;
            return true;
    }

    function changeSwapperAdd(address _newSwapper) onlyOwner public returns(bool) {
    		allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            swapperAddress = _newSwapper;
            return true;
    }
       
    function unlock() onlyOwner public returns(bool) {
        locked = false;
        return true;
    }

    function lock() onlyOwner public returns(bool) {
        locked = true;
        return true;
    }


    function burn(uint256 _value) onlyOwner public returns(bool) {
        if ( balances[msg.sender] < _value ) revert();
        balances[msg.sender] = safeSub( balances[msg.sender] , _value );
        totalSupply = safeSub( totalSupply,  _value );
        emit Transfer(msg.sender, address(0),_value);
        return true;
    }

// Payables

function() payable external  {
    uint tokensToSend = msg.value/price;
    require(tokensToSend > 0);
    uint surplus = safeSub(msg.value,tokensToSend*price);

    require(balances[rootAddress] >= tokensToSend);
    balances[rootAddress] = safeSub(balances[rootAddress], tokensToSend);
    balances[msg.sender] = safeAdd(balances[msg.sender], tokensToSend);
    emit Transfer(address(0),msg.sender,tokensToSend);
    emit Message("Welcome!");

    if (surplus > 0) msg.sender.send(surplus);
}

function sendToken(address _token,address _to , uint _value) onlyOwner public  returns(bool) {
    ERC20Basic Token = ERC20Basic(_token);
    return( Token.transfer(_to, _value) );
}

function flushEth() onlyOwner public {
    Owner.send(address(this).balance);
}


function getPrice() public returns(uint _price) {
    return price;
}

    // Public getters

    function isLocked() view  public returns(bool) {
        return locked;
    }



  // Standard function transfer similar to ERC20 transfer
  function transfer(address _to, uint _value, string memory _message) isUnlocked validate(_message , _value) public returns (bool success) {
    if (balances[msg.sender] < _value) return false;
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    emit Transfer(msg.sender,_to,_value);
    emit Message(_message);
    return true;
    }


    function transferFrom(address _from, address _to, uint256 _value, string memory _message) validate(_message , _value) public returns(bool) {

        if ( locked && msg.sender != swapperAddress ) return false; 
        if ( freezed[_from] || freezed[_to] ) return false; // Check if destination address is freezed
        if ( balances[_from] < _value ) return false; // Check if the sender has enough
    	if ( _value > allowed[_from][msg.sender] ) return false; // Check allowance

        balances[_from] = safeSub(balances[_from] , _value); // Subtract from the sender
        balances[_to] = safeAdd(balances[_to] , _value); // Add the same to the recipient

        allowed[_from][msg.sender] = safeSub( allowed[_from][msg.sender] , _value );

        emit Transfer(_from,_to,_value);
        emit Message(_message);
        return true;
    }


    function balanceOf(address _owner) view public returns(uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) view public  returns(uint256) {
        return allowed[_owner][_spender];
    }
}