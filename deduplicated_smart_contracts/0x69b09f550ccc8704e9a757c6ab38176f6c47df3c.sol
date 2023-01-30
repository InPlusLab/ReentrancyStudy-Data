/**
 *Submitted for verification at Etherscan.io on 2020-06-13
*/

pragma solidity >=0.4.21 <0.7.0;

/**
 *   @title SafeMath
 *   @dev Math operations with safety checks that throw on error
 */

library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns(uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal pure returns(uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns(uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 *   @dev ONGX token contract
 */

contract ONGX {

  using SafeMath for uint;

  address public owner;
  string public name = "ONGX";

  uint public totalSupply;

  mapping(address => uint) public balances;
  mapping(address => bool) public whitelist;
  mapping(address => mapping (address => uint)) allowed;

  // Allows execution by the owner only
  modifier onlyOwner{
    require(owner == msg.sender);
    _;
  }

  constructor(uint _initialSupply) public {
    owner = msg.sender;
    totalSupply = _initialSupply;
    balances[owner] = _initialSupply;
  }

  /**
    *   @dev Get balance of investor
    *   @param _tokenOwner   investor's address
    *   @return              balance of investor
    */

  function balanceOf(address _tokenOwner) public view returns (uint balance) {
    return balances[_tokenOwner];
  }

  /**
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.
    *
    *   @param _tokenOwner        the address which owns the funds
    *   @param _spender           the address which will spend the funds
    *
    *   @return                   the amount of tokens still avaible for the spender
    */
  function allowance(address _tokenOwner, address _spender) public view returns (uint){
    return allowed[_tokenOwner][_spender];
  }

  /**
    *   @return true if the transfer was successful
    */
  function transfer(address _to, uint _amount) public payable returns(bool){
    require(balances[msg.sender] >= _amount);

    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);

    emit Transfer(msg.sender, _to, _amount);
    return true;
  }

   /**
    *   @dev Allows another account/contract to spend some tokens on its behalf
    * approve has to be called twice in 2 separate transactions - once to
    *   change the allowance to 0 and secondly to change it to the new allowance value
    *   @param _spender      approved address
    *   @param _amount       allowance amount
    *
    *   @return true if the approval was successful
    */
  function approve(address _spender, uint _amount) public payable returns(bool){
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  /**
    *   @return true if the transfer was successful
    */
  function transferFrom(address _from, address _to, uint _amount) public payable returns (bool) {
    require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_from].add(_amount) >= balances[_from]);
  
    balances[_from] = balances[_from].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);

    emit Transfer(_from, _to, _amount);
    return true;
  }

  //    replenishment of funds
  function mintTokens(uint value) public payable onlyOwner {
    balances[owner] = balances[owner].add(value);
    totalSupply = totalSupply.add(value);
    emit IncreaseFunds(value);
  }

  //    burning of funds
  function burnFunds(uint value) public payable onlyOwner {
    balances[owner] = balances[owner].sub(value);
    totalSupply = totalSupply.sub(value);
    emit BurnFunds(value);
  }

  //    adding to whitelist
  function addToWhitelist(address user) public payable onlyOwner {
    whitelist[user] = true;
    emit AddedToWhitelist(user);
  }

  //    removing from whitelist
  function removeFromWhitelist(address user) public payable onlyOwner {
    whitelist[user] = false;
    emit RemovedFromWhitelist(user);
  }

  // Events Log

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

  event AddedToWhitelist(address indexed user);
  event RemovedFromWhitelist(address indexed user);

  event IncreaseFunds(uint value);
  event BurnFunds(uint value);
}