/**

 *Submitted for verification at Etherscan.io on 2019-02-08

*/



pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;



interface IERC20 {

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



contract Bombastic {

  using SafeMath for uint256;

  

  IERC20 public BOMB = IERC20(0x1F4F33C3A163b9Ad84613C1c61337CbFD7C8839f);

  uint256 public START_PRICE = 21;

  uint256 public FEE = 2;

  uint256 public INTERVAL = 12 hours;

  uint256 public ids;



  struct Round {

    address starter;

    uint256 countdown;

    address [] tickets;

    address winner;

    uint256 winnings;

    uint256 started;

    uint256 ended;

  }



  mapping(uint256 => Round) rounds;



  modifier isHuman() {

    address _addr = msg.sender;

    require(_addr == tx.origin);

    uint256 _codeLength;



    assembly {_codeLength := extcodesize(_addr)}

    require(_codeLength == 0);

    _;

  }



  function start() external isHuman() {

    Round storage round = rounds[ids];



    // round must not have started

    require(round.countdown == 0);



    // start round

    round.countdown = now.add(INTERVAL);



    // add to pot

    require(BOMB.transferFrom(msg.sender, address(this), START_PRICE));



    // set round starter

    round.starter = msg.sender;



    // set start time

    round.started = now;



    // add a ticket

    round.tickets.push(msg.sender);

  }



  function buy() external isHuman() {

    Round storage round = rounds[ids];



    // round must have started

    require(round.countdown != 0);



    // round must not have finished

    require(now <= round.countdown);



    // add to countdown

    round.countdown = now.add(INTERVAL);



    // add to pot

    require(BOMB.transferFrom(msg.sender, address(this), FEE));



    // pay starter

    require(BOMB.transferFrom(msg.sender, round.starter, FEE));



    // add a ticket

    round.tickets.push(msg.sender);

  }



  function draw() external isHuman() {

    Round storage round = rounds[ids];



    // round must have started

    require(round.countdown != 0);



    // round must have finished

    require(now > round.countdown);



    // start next round

    ids = ids.add(1);



    // set end time

    round.ended = now;



    // get winner

    round.winner = round.tickets[_winner(round.tickets.length)];



    // update winnings

    round.winnings = BOMB.balanceOf(address(this));



    // transfer to winner

    require(BOMB.transfer(round.winner, round.winnings));

  }



  function _winner(uint256 length) internal view returns (uint256) {

    uint256 seed = uint256(keccak256(abi.encodePacked(

      (block.timestamp).add

      (block.difficulty).add

      ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add

      (block.gaslimit).add

      ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add

      (block.number)

    )));

    return seed % length;

  }



  function getCurrentRound() view external returns (Round memory, uint256, uint256) {

    return (rounds[ids], BOMB.balanceOf(address(this)), ids);

  }



  function getRound(uint256 _roundNum) view external returns (Round memory) {

    return rounds[_roundNum];

  }

}