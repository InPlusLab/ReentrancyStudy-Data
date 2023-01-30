/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

pragma solidity ^0.5.1;

contract ERC20 {
  function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}
/**
 * Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint256 a, uint256 b) pure internal returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) pure internal returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) pure internal returns (uint256) {
        uint256 c = a + b;
        require(c>=a && c>=b);
        return c;
    }
}

contract tokenRecipientInterface {
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public;
}

contract TZVC is Ownable, SafeMath, Pausable{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public tokenLeft;
    address public tokenAddress;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // ZVC to TZVC
    event Mapping(address _from, uint256 _value, bytes _extraData);
    
    event Burn(address _from, uint256 _value, string _zvAddr);




    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(address _tokenAddress) public payable  {
        tokenLeft = 90000000000000000;              // Give the creator all initial tokens
        totalSupply = 90000000000000000;                        // Update total supply
        name = "TZVC";                                   // Set the name for display purposes
        symbol = "TZVC";                               // Set the symbol for display purposes
        decimals = 9;                            // Amount of decimals for display purposes
        tokenAddress = _tokenAddress;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool success){
        require(_to != address(0x0));                               // Prevent transfer to 0x0 address. Use burn() instead
        require(_value > 0);
        require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }


    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) whenNotPaused public returns (bool success) {
        require(_value > 0);
        allowance[msg.sender][_spender] = _value;
        return true;
    }


    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool success) {
        require (_to != address(0x0));                                // Prevent transfer to 0x0 address. Use burn() instead
        require (_value > 0);
        require (balanceOf[_from] >= _value);                 // Check if the sender has enough
        require (_value <= allowance[_from][msg.sender]);     // Check allowance
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) whenNotPaused public returns (bool success) {
        tokenRecipientInterface spender = tokenRecipientInterface(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
        return false;
    }
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public {
        require(_token == tokenAddress);
        require(_value > 0);
        require(_value <= tokenLeft);
        ERC20 token = ERC20(_token);
        if (token.transferFrom(_from, address(this), _value)) {
            balanceOf[_from] = SafeMath.safeAdd(balanceOf[_from], _value);
            tokenLeft = SafeMath.safeSub(tokenLeft, _value);
            emit Mapping(_from, _value, _extraData);
        }
    }
    
    function burn(uint256 _value, string memory _zvAddr) public {
        require(_value > 0);
        require(balanceOf[msg.sender] >= _value); // Check if the sender has enough
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);// Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply, _value);
        emit Burn(msg.sender, _value, _zvAddr);// Notify
    }

    function () external payable {
    }

    // transfer balance to owner
    function withdrawEther(uint256 _amount) public onlyOwner{
        msg.sender.transfer(_amount);
    }
}