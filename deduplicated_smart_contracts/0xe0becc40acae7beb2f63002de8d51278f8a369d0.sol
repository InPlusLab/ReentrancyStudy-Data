/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity ^0.4.18;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
      OwnershipTransferred(owner, newOwner);
      owner = newOwner;
  }

}
contract StandardToken {
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address _owner, address _spender) public view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
}

contract ETFloft is Ownable{
  using SafeMath for uint256;
  mapping (address => uint256) public reward_payable;
  mapping (address => uint256) public reward_payable_ETF;

  address public servant;
  address public ETFaddress;
  address public eco_fund;
  address public collector;

  function setAddress(address _etf,address _servant, address _ecofund, address _collector) public onlyOwner{
    servant = _servant;
    ETFaddress = _etf;
    eco_fund = _ecofund;
    collector = _collector;
  }


   function getReward() public{
    msg.sender.transfer(reward_payable[msg.sender]);
    delete reward_payable[msg.sender];
  }
   function getRewardETF() public{
      StandardToken ETFcoin = StandardToken(ETFaddress);
      ETFcoin.transfer(msg.sender, reward_payable_ETF[msg.sender]);
      delete reward_payable_ETF[msg.sender];
    }


  struct loft{
    uint32 number;
    address owner;
  }
  loft[] public lofts;
  function inResults(uint32 n, uint32 result) public pure returns(uint){
       uint32 r;
    if (result != 0){
          r = n & result;
    }
    else{
         r = n;
    }
   uint a;
    for(uint i;i<32;i++){
      if( (r & (uint32(1)<< i)  >0 )  ){
        a += 1;
      }
    }
    return a;
  }
  uint256 public round;
  event newLoft(uint32 n, address indexed owner, uint256 indexed r);
  function buyLoft(uint256[5] numbers) public{
    require(tx.origin ==msg.sender);
    StandardToken ETFcoin = StandardToken(ETFaddress);
    require(ETFcoin.allowance(msg.sender, this) >= 100*10**18);
    require(ETFcoin.transferFrom(msg.sender, this, 100*10**18));
    uint32 n;
    for(uint i;i<5;i++){
      n+= (uint32(1) << (numbers[i]-1));
    }
    require(inResults(n,0) == 5);
    lofts.push(loft(n, msg.sender));
    newLoft(n, msg.sender, round);
  }
  function test() public{
    balance += 100 *10**18;
  }
  uint256 public balance;

  event LoftResult(uint32 n, uint256 round);
  function openLoft(uint256 seed) public{
    require(msg.sender == servant);
    uint32 n;
    uint32 j;
    uint i;
    if(seed == 0){
      for(i=0;i<5;i++){
        j = uint32(1) << (uint256(sha256(now))%32);
        while(inResults(n+j, 0)!= (i+1)){
          j = uint32(1) << (uint256(sha256(now))%32);
        }
        n+=j;
     }
    }
    else{
      n = uint32(seed);
    }
    address[] winner1;
    address[] winner2;
    address[] winner3;
    address[] winner4;
    address[] winner5;

    uint256 total;
    uint256 pay;
    uint a;
    StandardToken ETFcoin = StandardToken(ETFaddress);
    LoftResult(n, round);
    round +=1;
    for(i=0;i<lofts.length;i++){
      a = inResults(lofts[i].number, n);
      if (a==1){
        winner5.push(lofts[i].owner);
      }
      else if  (a==2){
        winner4.push(lofts[i].owner);
      }
      else if  (a==3){
        winner3.push(lofts[i].owner);
      }
      else if  (a==4){
        winner2.push(lofts[i].owner);
      }
      else if  (a==5){
        winner1.push(lofts[i].owner);
      }
      else{
        1;
      }
    }
    delete lofts;


    total = balance.mul(50).div(100).div(2);
    for(i=0;i<winner1.length; i++){
      reward_payable[winner1[i]] += ( total.div(winner1.length) );
      pay += ( total.div(winner1.length) );
      //winner[0][i].send( total.div(winner[0].length) -1);
    }
    total = balance.mul(30).div(100).div(2);
    for( i=0;i<winner2.length; i++){
      reward_payable[winner2[i]] += ( total.div(winner2.length) );
      pay += ( total.div(winner2.length) );
      //winner[1][i].send( total.div(winner[1].length) -1);
    }
    total = balance.mul(20).div(100).div(2);
    for( i=0;i<winner3.length; i++){
      reward_payable[winner3[i]] += ( total.div(winner3.length) );
      pay += ( total.div(winner3.length) );
      //winner[2][i].send( total.div(winner[2].length) -1);
    }
    for( i=0;i<winner4.length; i++){
      //reward_payable_ETF[winner4[i]] += 500 * 10 **18;
      //ETFcoin.transfer(winner[3][i], 100 * 10 **18);
    }
    for( i=0;i<winner5.length; i++){
      //reward_payable_ETF[winner5[i]] += 200 * 10 **18;
      //ETFcoin.transfer(winner[4][i], 100 * 10 **18);
    }
    balance -= pay;
  }

    address[] public winner1;
    address[] public winner2;
    address[] public winner3;
    address[] public winner4;
    address[] public winner5;

 uint256 public fee = 10;

function openLoft2(uint256 seed) public {
    require(msg.sender == servant);
    uint32 n;
    uint32 j;
    uint i;
    if(seed == 0){
      for(i=0;i<5;i++){
        j = uint32(1) << (uint256(sha256(now))%32);
        while(inResults(n+j, 0)!= (i+1)){
          j = uint32(1) << (uint256(sha256(now))%32);
        }
        n+=j;
     }
    }
    else{
      n = uint32(seed);
    }


    uint256 total;
    uint256 pay;
    uint256 fees;
    uint a;
    //StandardToken ETFcoin = StandardToken(ETFaddress);
    LoftResult(n, round);
    round +=1;
    for(i=0;i<lofts.length;i++){
      a = inResults(lofts[i].number, n);
      if (a==1){
        winner5.push(lofts[i].owner);
      }
      else if  (a==2){
        winner4.push(lofts[i].owner);
      }
      else if  (a==3){
        winner3.push(lofts[i].owner);
      }
      else if  (a==4){
        winner2.push(lofts[i].owner);
      }
      else if  (a==5){
        winner1.push(lofts[i].owner);
      }
      else{
        1;
      }
    }
    delete lofts;
    total = balance.mul(50).div(100).div(2);
    for(i=0;i<winner1.length; i++){
      reward_payable[winner1[i]] += ( total.div(winner1.length) * 90 / 100);
      pay += ( total.div(winner1.length) * 90 / 100);
      fees +=  ( total.div(winner1.length) * 10 / 100);
      //winner[0][i].send( total.div(winner[0].length) -1);
    }
    total = balance.mul(30).div(100).div(2);
    for( i=0;i<winner2.length; i++){
      reward_payable[winner2[i]] += ( total.div(winner2.length) * 90 / 100);
      pay += ( total.div(winner2.length) * 90 / 100);
      fees +=  ( total.div(winner2.length) * 10 / 100);
      //winner[1][i].send( total.div(winner[1].length) -1);
    }
    total = balance.mul(20).div(100).div(2);
    for( i=0;i<winner3.length; i++){
      reward_payable[winner3[i]] += ( total.div(winner3.length) * 90 / 100);
      pay += ( total.div(winner3.length) * 90 / 100);
      fees +=  ( total.div(winner3.length) * 10 / 100);
      //winner[2][i].send( total.div(winner[2].length) -1);
    }
    for( i=0;i<winner4.length; i++){
      reward_payable_ETF[winner4[i]] += 500 * 10 **18;
      //ETFcoin.transfer(winner[3][i], 100 * 10 **18);
    }
    for( i=0;i<winner5.length; i++){
      reward_payable_ETF[winner5[i]] += 200 * 10 **18;
      //ETFcoin.transfer(winner[4][i], 100 * 10 **18);
    }
    balance -= pay;
    delete winner1;
    delete winner2;

delete winner3;
delete winner4;
delete winner5;
collector.send(fees);

  }
  function () payable public {
    balance += msg.value;
    if (balance >= 100000*10**18){
        uint256 _amount;
      _amount = (balance - 100000*10**18) * 3 / 10;
      eco_fund.send(_amount);
    }
  }
}