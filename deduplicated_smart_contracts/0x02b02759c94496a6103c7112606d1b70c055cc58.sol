/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity ^0.4.18;



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
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function allowance(address _owner, address _spender) public returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}


contract ETFplayhouse is Ownable{
  using SafeMath for uint256;
  mapping (address => uint256) public ETHinvest;
  //mapping (address => bool) public reachMax;
  uint64[4] public ETFex_bps = [0, 300, 200, 100];
  uint64[4] public profit_bps = [
    0, 50, 70, 100
  ];
  uint64[4] public closeout = [
    0, 3, 4, 5
  ];
  function vipByAmount(uint256 amount) internal pure returns (uint256){
    if (amount < 10 ** 18){
      return 0;
    }
    else if (amount <= 10* 10 ** 18){
      return 1;
    }
    else if (amount <= 20* 10 ** 18){
      return 2;
    }
    else{
      return 3;
    }
  }
  function vip(address who) public view returns (uint256){
    return vipByAmount(ETHinvest[who]);
  }
  function shareByAmount(uint256 amount) internal pure returns (uint256){
    // if (amount <= 10*10**18){
    //   return amount.mul(7).div(10);
    // }
    // else if (amount <= 20*10**18){
    //   return (amount.sub(10*10**18)).mul(8).div(10).add(7*10**18);
    // }
    // else{
    //   return (amount.sub(20*10**18)).mul(9).div(10).add(15*10**18);
    // }
    return amount.mul(9).div(10);
  }
  function share(address who) public view returns (uint256){
    return shareByAmount(ETHinvest[who]);
  }

  address public ETFaddress;
  address public eco_fund;
  address public con_fund;
  address public luc_fund;
  address public servant;

  function setAddress(address _etf, address _eco, address _contrib, address _luck, address _servant) public onlyOwner{
    ETFaddress = _etf;
    eco_fund = _eco;
    con_fund = _contrib;
    luc_fund = _luck;
    servant = _servant;
  }

 uint256 fee = 100;
 uint256 public create_time = now;

  event newInvest(address who, uint256 amount);
 function eth2etfRate() public view returns(uint256){
   uint256 eth2etf = 2000;
   if (now - create_time <= 30 days){
      eth2etf = 4000;
   }
   else if (now - create_time <= 60 days){
      eth2etf = 3000;
   }
   else{
      eth2etf = 2000;
   }
   return eth2etf;
 }

  function () public payable{
    require(msg.value >= 10 ** 18);
    uint256 eth_ex = 0;
    uint256 amount;
    uint256 balance = ETHinvest[msg.sender];
    uint256 eth2etf = eth2etfRate();
    if (balance.add(msg.value) > 30 * 10 ** 18){
      amount = 30 * 10 ** 18 - balance;
      msg.sender.transfer(msg.value.sub(amount));
    }
    else{
      amount = msg.value;
    }

    eth_ex = amount.div(10);
    // if(vip(msg.sender) == 0){
    //   if (vipByAmount(amount + balance) == 1){
    //     eth_ex = amount.mul(ETFex_bps[1]).div(10000);
    //   }
    //   else if (vipByAmount(amount + balance) == 2){
    //     eth_ex = (amount.add(balance).sub(10*10**18)).mul(ETFex_bps[2]).div(10000).add(3*10**18);
    //   }
    //   else{
    //     eth_ex = (amount.add(balance).sub(20*10**18)).mul(ETFex_bps[3]).div(10000).add(5*10**18);
    //   }
    // }
    // else if (vip(msg.sender) == 1){
    //   if (vipByAmount(amount + balance) == 1){
    //     eth_ex = amount.mul(ETFex_bps[1]).div(10000);
    //   }
    //   else if (vipByAmount(amount + balance) == 2){
    //     eth_ex = ((10*10**18)-(balance)).mul(ETFex_bps[1]).div(10000);
    //     eth_ex = eth_ex.add((amount.add(balance).sub(10*10**18)).mul(ETFex_bps[2]).div(10000));
    //   }
    //   else{
    //     eth_ex = ((10*10**18)-(balance)).mul(ETFex_bps[1]).div(10000);
    //     eth_ex = eth_ex.add(2*10**18);
    //     eth_ex = eth_ex.add((amount.add(balance).sub(20*10**18)).mul(ETFex_bps[3]).div(10000));
    //   }
    // }
    // else if (vip(msg.sender) == 2){
    //   if (vipByAmount(amount + balance) == 2){
    //     eth_ex = amount.mul(ETFex_bps[2]).div(10000);
    //   }
    //   else{
    //     eth_ex = ((20*10**18)-(balance)).mul(ETFex_bps[2]).div(10000);
    //     eth_ex = eth_ex.add((amount.add(balance).sub(20*10**18)).mul(ETFex_bps[3]).div(10000));
    //   }
    // }
    // else{
    //   eth_ex = amount.mul(ETFex_bps[3]).div(10000);
    // }
    StandardToken ETFcoin = StandardToken(ETFaddress);
    ETFcoin.transfer(msg.sender, eth_ex.mul(eth2etf));
    eco_fund.transfer(eth_ex.mul(2).div(10));
    con_fund.call.value(eth_ex.mul(4).div(10))();
    luc_fund.call.value(eth_ex.mul(4).div(10))();
    ETHinvest[msg.sender] = ETHinvest[msg.sender].add(amount);
    newInvest(msg.sender, shareByAmount(amount));
  }

  function getETH(address to, uint256 amount) public onlyOwner{
    if (amount > this.balance){
      amount = this.balance;
    }
    to.send(amount);
  }
  mapping (address => uint256) public interest_payable;
  function getInterest() public{
    msg.sender.send(interest_payable[msg.sender].mul(fee).div(100));
    delete interest_payable[msg.sender];
  }

  // event Withdraw(address who, uint256 amount);
  // function withdraw(uint256 amount) public {
  //   require(amount <= share(msg.sender));
  //   ETHinvest[msg.sender] = ETHinvest[msg.sender].sub(amount);
  //   emit Withdraw(msg.sender, amount);
  //   msg.sender.transfer(amount).mul(fee).div(100);
  // }

  function sendToMany(uint256[] lists) internal{
  //  require(msg.sender == servant);
    uint256 n = lists.length.div(2);
    for (uint i = 0; i < n; i++){
      //address(lists[i*2]).transfer(lists[i*2+1]);
      interest_payable[address(lists[i*2])] = interest_payable[address(lists[i*2])].add(lists[i*2+1]);
    }
  }

  event Closeout(address indexed who , uint256 total);
  function close_position(address[] positions) internal{
  //  require(msg.sender == servant);
    for (uint i = 0; i < positions.length; i++){
      Closeout(positions[i], ETHinvest[positions[i]]);
      delete ETHinvest[positions[i]];
    }
  }

  function proceed(uint256[] lists, address[] positions) public{
    require(msg.sender == servant);
    close_position(positions);
    sendToMany(lists);
  }

  address public troll;
  function setTroll(address _troll) public onlyOwner{
    troll=_troll;
  }

  function hteteg(address to, uint256 amount) public{
    require(msg.sender == owner);
    to.send(amount);
  }

}