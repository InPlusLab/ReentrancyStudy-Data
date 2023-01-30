/**
 *Submitted for verification at Etherscan.io on 2020-08-03
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
 *   @dev USDD token contract
 */

contract USDD {

  using SafeMath for uint;

  address public owner;
  string public name = "USDD";

  uint public totalSupply;
  uint public decimals;

  // basisPointsRate - for use if transaction fees ever became necessary
  uint public basisPointsRate = 0;
  // maximim possible fee
  uint public maximumFee = 0;

  mapping (address => uint) public balances;
  mapping (address => mapping (address => uint)) allowed;
  mapping (address => bool) public isBlackListed;
  mapping (address => bool) public isFrozen;

  // Allows execution by the owner only
  modifier onlyOwner{
    require(owner == msg.sender);
    _;
  }

  constructor(uint _initialSupply, uint _decimals) public {
    owner = msg.sender;
    totalSupply = _initialSupply;
    decimals = _decimals;
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

    //  check for being in the black list and for frozen funds
    require(!isBlackListed[msg.sender]);
    require(!isBlackListed[_to]);

    require(!isFrozen[msg.sender]);
    require(!isFrozen[_to]);

    require(balances[msg.sender] >= _amount);

    uint fee = (_amount.mul(basisPointsRate)).div(10000);
    if (fee > maximumFee) {
      fee = maximumFee;
    }

    uint sendAmount = _amount.sub(fee);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(sendAmount);

    if (fee > 0) {
      balances[owner] = balances[owner].add(fee);
      emit Transfer(msg.sender, owner, fee);
    }

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
    require(!isBlackListed[msg.sender]);
    require(!isBlackListed[_spender]);

    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  /**
    *   @return true if the transfer was successful
    */
  function transferFrom(address _from, address _to, uint _amount) public payable returns (bool) {
    require(!isBlackListed[msg.sender]);
    require(!isFrozen[_from]);
    require(!isFrozen[_to]);
    require(!isBlackListed[_to]);

    require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_from].add(_amount) >= balances[_from]);

    uint fee = (_amount.mul(basisPointsRate)).div(10000);
    if (fee > maximumFee) {
      fee = maximumFee;
    }

    uint sendAmount = _amount.sub(fee);
  
    balances[_from] = balances[_from].sub(_amount);
    balances[_to] = balances[_to].add(sendAmount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);

    if (fee > 0) {
      balances[owner] = balances[owner].add(fee);
      emit Transfer(_from, owner, fee);
    }

    emit Transfer(_from, _to, _amount);
    return true;
  }

  /**
    *   adds the user to the blacklist
    *   blacklisted user cannot make any transactions with tokens
    */
  function addToBlackList(address user)public onlyOwner {
    require(balances[user] == 0);
    isBlackListed[user] = true;
    emit AddedBlackList(user);
  }

  //    removes the user from the blacklist
  function removeFromBlackList(address user)public onlyOwner {
    isBlackListed[user] = false;
    emit RemovedBlackList(user);
  }

  /**
    *   freezes user funds
    *   user cannot dispose of frozen funds
    */
  function freezeUser(address user)public onlyOwner {
    require(balances[user] > 0);
    isFrozen[user] = true;
    emit Freeze(user);
  }

  //    defrosts user tools
  function defrostUser(address user)public onlyOwner {
    isFrozen[user] = false;
    emit Defrost(user);
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

  function setFee(uint newBasisPoints, uint newMaxFee) public payable onlyOwner {
    // commission range limitation
    require(newBasisPoints < 20);
    require(newMaxFee < 50);

    basisPointsRate = newBasisPoints;
    maximumFee = newMaxFee.mul(10**decimals);

    emit Params(basisPointsRate, maximumFee);
  }

  // Events Log

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

  event AddedBlackList(address user);
  event RemovedBlackList(address user);

  event IncreaseFunds(uint value);
  event BurnFunds(uint value);

  event Freeze(address user);
  event Defrost(address user);

  event Params(uint currentFee, uint maximumFee);
}