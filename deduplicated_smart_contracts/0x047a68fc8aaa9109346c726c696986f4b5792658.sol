/**

 *Submitted for verification at Etherscan.io on 2018-08-23

*/



pragma solidity ^0.4.17;



contract BitrngDice {

  // Ownership.

  address public owner;

  address private nextOwner;



  // The address corresponding to a private key used to sign placeBet commits.

  address public secretSigner;



  // Minimum and maximum bets.

  uint constant MIN_AMOUNT = 0.01 ether;

  uint constant MAX_AMOUNT_BIG_SMALL = 1 ether;

  uint constant MAX_AMOUNT_SAME = 0.05 ether;

  uint constant MAX_AMOUNT_NUMBER = 0.1 ether;



  // EVM `BLOCKHASH` opcode can query no further than 256 blocks into the

  // past. Given that settleBet uses block hash of placeBet as one of

  // complementary entropy sources, we cannot process bets older than this

  // threshold. On rare occasions dice2.win croupier may fail to invoke

  // settleBet in this timespan due to technical issues or extreme Ethereum

  // congestion; such bets can be refunded via invoking refundBet.

  uint constant BET_EXPIRATION_BLOCKS = 250;



  // Max bets in one game.

  uint8 constant MAX_BET = 5;



  // Max bet types.

  uint8 constant BET_MASK_COUNT = 22;



  // Bet flags.

  uint24 constant BET_BIG = uint24(1 << 21);

  uint24 constant BET_SMALL = uint24(1 << 20);

  uint24 constant BET_SAME_1 = uint24(1 << 19);

  uint24 constant BET_SAME_2 = uint24(1 << 18);

  uint24 constant BET_SAME_3 = uint24(1 << 17);

  uint24 constant BET_SAME_4 = uint24(1 << 16);

  uint24 constant BET_SAME_5 = uint24(1 << 15);

  uint24 constant BET_SAME_6 = uint24(1 << 14);

  uint24 constant BET_4 = uint24(1 << 13);

  uint24 constant BET_5 = uint24(1 << 12);

  uint24 constant BET_6 = uint24(1 << 11);

  uint24 constant BET_7 = uint24(1 << 10);

  uint24 constant BET_8 = uint24(1 << 9);

  uint24 constant BET_9 = uint24(1 << 8);

  uint24 constant BET_10 = uint24(1 << 7);

  uint24 constant BET_11 = uint24(1 << 6);

  uint24 constant BET_12 = uint24(1 << 5);

  uint24 constant BET_13 = uint24(1 << 4);

  uint24 constant BET_14 = uint24(1 << 3);

  uint24 constant BET_15 = uint24(1 << 2);

  uint24 constant BET_16 = uint24(1 << 1);

  uint24 constant BET_17 = uint24(1);



  // Funds that are locked in potentially winning bets. Prevents contract from

  // committing to bets it cannot pay out.

  uint public lockedInBets;



  // Set false to disable betting.

  bool public enabled = true;



  // Some deliberately invalid address to initialize the secret signer with.

  // Forces maintainers to invoke setSecretSigner before processing any bets.

  address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;



  // The game struct, only supports 5 bet.

  struct Game{

    address gambler;

    uint40 placeBlockNumber; // block number contains place bet txn

    uint bet1Amount;

    uint bet2Amount;

    uint bet3Amount;

    uint bet4Amount;

    uint bet5Amount;

    uint24 mask; // bet flags ored together

  }



  // Mapping from commits to all currently active & processed bets.

  mapping (uint => Game) games;



  // Mapping for bet type to odds

  mapping (uint24 => uint8) odds;



  // Mapping for bet number results;

  mapping (uint24 => uint8) betNumberResults;



  // Mapdding for bet same number results

  mapping (uint24 => uint8) betSameResults;



  // Events that are issued to make statistic recovery easier.

  event FailedPayment(address indexed beneficiary, uint amount);

  event Payment(address indexed beneficiary, uint amount);



  constructor () public {

    owner = msg.sender;

    secretSigner = DUMMY_ADDRESS;



    // init odds

    odds[BET_SMALL] = 2;

    odds[BET_BIG] = 2;



    odds[BET_SAME_1] = 150;

    odds[BET_SAME_2] = 150;

    odds[BET_SAME_3] = 150;

    odds[BET_SAME_4] = 150;

    odds[BET_SAME_5] = 150;

    odds[BET_SAME_6] = 150;



    odds[BET_9] = 6;

    odds[BET_10] = 6;

    odds[BET_11] = 6;

    odds[BET_12] = 6;



    odds[BET_8] = 8;

    odds[BET_13] = 8;



    odds[BET_7] = 12;

    odds[BET_14] = 12;



    odds[BET_6] = 14;

    odds[BET_15] = 14;



    odds[BET_5] = 18;

    odds[BET_16] = 18;



    odds[BET_4] = 50;

    odds[BET_17] = 50;



    // init results

    betNumberResults[BET_9] = 9;

    betNumberResults[BET_10] = 10;

    betNumberResults[BET_11] = 11;

    betNumberResults[BET_12] = 12;



    betNumberResults[BET_8] = 8;

    betNumberResults[BET_13] = 13;



    betNumberResults[BET_7] = 7;

    betNumberResults[BET_14] = 14;



    betNumberResults[BET_6] = 6;

    betNumberResults[BET_15] = 15;



    betNumberResults[BET_5] = 5;

    betNumberResults[BET_16] = 16;



    betNumberResults[BET_4] = 4;

    betNumberResults[BET_17] = 17;



    betSameResults[BET_SAME_1] = 1;

    betSameResults[BET_SAME_2] = 2;

    betSameResults[BET_SAME_3] = 3;

    betSameResults[BET_SAME_4] = 4;

    betSameResults[BET_SAME_5] = 5;

    betSameResults[BET_SAME_6] = 6;



  }



  // Place game

  //

  // Betmask - flags for each bet, total 22 bits.

  // betAmount - 5 bet amounts in Wei

  // commitLastBlock -  block number when `commit` expires

  // commit -  sha3 of `reveal`

  // r, s - components of ECDSA signature of (commitLastBlock, commit).

  //        Used to check commit is generated by `secretSigner`

  //

  // Game states:

  //  amount == 0 && gambler == 0 - 'clean' (can place a bet)

  //  amount != 0 && gambler != 0 - 'active' (can be settled or refunded)

  //  amount == 0 && gambler != 0 - 'processed' (can clean storage)

  function placeGame(

    uint24 betMask,

    uint bet1Amount,

    uint bet2Amount,

    uint bet3Amount,

    uint bet4Amount,

    uint bet5Amount,

    uint commitLastBlock,

    uint commit,

    bytes32 r,

    bytes32 s

  ) external payable

  {

    // Is game enabled ?

    require (enabled, "Game is closed");

    // Check payed amount and sum of place amount are equal.

    require (bet1Amount + bet2Amount + bet3Amount + bet4Amount + bet5Amount == msg.value,

      "Place amount and payment should be equal.");



    // Check that the game is in 'clean' state.

    Game storage game = games[commit];

    require (game.gambler == address(0),

      "Game should be in a 'clean' state.");



    // Check that commit is valid. It has not expired and its signature is valid.

    // r = signature[0:64]

    // s = signature[64:128]

    // v = signature[128:130], always 27

    require (block.number <= commitLastBlock, "Commit has expired.");

    bytes32 signatureHash = keccak256(abi.encodePacked(uint40(commitLastBlock), commit));

    require (secretSigner == ecrecover(signatureHash, 27, r, s), "ECDSA signature is not valid.");



    // Try to lock amount.

    _lockOrUnlockAmount(

      betMask,

      bet1Amount,

      bet2Amount,

      bet3Amount,

      bet4Amount,

      bet5Amount,

      1

    );



    // Store game parameters on blockchain.

    game.placeBlockNumber = uint40(block.number);

    game.mask = uint24(betMask);

    game.gambler = msg.sender;

    game.bet1Amount = bet1Amount;

    game.bet2Amount = bet2Amount;

    game.bet3Amount = bet3Amount;

    game.bet4Amount = bet4Amount;

    game.bet5Amount = bet5Amount;

  }



  function settleGame(uint reveal, uint cleanCommit) external {

    // `commit` for bet settlement can only be obtained by hashing a `reveal`.

    uint commit = uint(keccak256(abi.encodePacked(reveal)));

    // Fetch bet parameters into local variables (to save gas).

    Game storage game = games[commit];

    uint bet1Amount = game.bet1Amount;

    uint bet2Amount = game.bet2Amount;

    uint bet3Amount = game.bet3Amount;

    uint bet4Amount = game.bet4Amount;

    uint bet5Amount = game.bet5Amount;

    uint placeBlockNumber = game.placeBlockNumber;

    address gambler = game.gambler;

    uint24 betMask = game.mask;



    // Check that bet is in 'active' state.

    require (

      bet1Amount != 0 ||

      bet2Amount != 0 ||

      bet3Amount != 0 ||

      bet4Amount != 0 ||

      bet5Amount != 0,

      "Bet should be in an 'active' state");



    // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).

    require (block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");

    require (block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");



    // Move bet into 'processed' state already.

    game.bet1Amount = 0;

    game.bet2Amount = 0;

    game.bet3Amount = 0;

    game.bet4Amount = 0;

    game.bet5Amount = 0;



    // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners

    // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256

    // preimage is intractable), and house is unable to alter the "reveal" after

    // placeBet have been mined (as Keccak256 collision finding is also intractable).

    uint entropy = uint(

      keccak256(abi.encodePacked(reveal, blockhash(placeBlockNumber)))

    );



    uint winAmount = _getWinAmount(

      uint8((entropy % 6) + 1),

      uint8(((entropy >> 10) % 6) + 1),

      uint8(((entropy >> 20) % 6) + 1),

      betMask,

      bet1Amount,

      bet2Amount,

      bet3Amount,

      bet4Amount,

      bet5Amount

    );



    // Unlock the bet amount, regardless of the outcome.

    _lockOrUnlockAmount(

      betMask,

      bet1Amount,

      bet2Amount,

      bet3Amount,

      bet4Amount,

      bet5Amount,

      0

    );



    // Send the funds to gambler.

    if(winAmount > 0){

      sendFunds(gambler, winAmount);

    }else{

      sendFunds(gambler, 1 wei);

    }



    // Clear storage of some previous bet.

    if (cleanCommit == 0) {

        return;

    }

    clearProcessedBet(cleanCommit);

  }



  // Refund transaction - return the bet amount of a roll that was not processed in a

  // due timeframe. Processing such blocks is not possible due to EVM limitations (see

  // BET_EXPIRATION_BLOCKS comment above for details). In case you ever find yourself

  // in a situation like this, just contact the dice2.win support, however nothing

  // precludes you from invoking this method yourself.

  function refundBet(uint commit) external {

    // Check that bet is in 'active' state.

    Game storage game = games[commit];

    uint bet1Amount = game.bet1Amount;

    uint bet2Amount = game.bet2Amount;

    uint bet3Amount = game.bet3Amount;

    uint bet4Amount = game.bet4Amount;

    uint bet5Amount = game.bet5Amount;



    // Check that bet is in 'active' state.

    require (

      bet1Amount != 0 ||

      bet2Amount != 0 ||

      bet3Amount != 0 ||

      bet4Amount != 0 ||

      bet5Amount != 0,

      "Bet should be in an 'active' state");



    // Check that bet has already expired.

    require (block.number > game.placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");



    // Move bet into 'processed' state already.

    game.bet1Amount = 0;

    game.bet2Amount = 0;

    game.bet3Amount = 0;

    game.bet4Amount = 0;

    game.bet5Amount = 0;



    // Unlock the bet amount.

    _lockOrUnlockAmount(

      game.mask,

      bet1Amount,

      bet2Amount,

      bet3Amount,

      bet4Amount,

      bet5Amount,

      0

    );



    // Send the refund.

    sendFunds(game.gambler, bet1Amount + bet2Amount + bet3Amount + bet4Amount + bet5Amount);

  }



  // Helper routine to move 'processed' bets into 'clean' state.

  function clearProcessedBet(uint commit) private {

      Game storage game = games[commit];



      // Do not overwrite active bets with zeros; additionally prevent cleanup of bets

      // for which commit signatures may have not expired yet (see whitepaper for details).

      if (

        game.bet1Amount != 0 ||

        game.bet2Amount != 0 ||

        game.bet3Amount != 0 ||

        game.bet4Amount != 0 ||

        game.bet5Amount != 0 ||

        block.number <= game.placeBlockNumber + BET_EXPIRATION_BLOCKS

      ) {

          return;

      }



      // Zero out the remaining storage (amount was zeroed before, delete would consume 5k

      // more gas).

      game.placeBlockNumber = 0;

      game.mask = 0;

      game.gambler = address(0);

  }



  // A helper routine to bulk clean the storage.

  function clearStorage(uint[] cleanCommits) external {

      uint length = cleanCommits.length;



      for (uint i = 0; i < length; i++) {

          clearProcessedBet(cleanCommits[i]);

      }

  }



  // Send funds.

  function sendFunds(address beneficiary, uint amount) private {

    if (beneficiary.send(amount)) {

      emit Payment(beneficiary, amount);

    } else {

      emit FailedPayment(beneficiary, amount);

    }

  }



  // Get actual win amount.

  // dice1, dice2, dice3 - dice from 1 to 6

  function _getWinAmount(

    uint8 dice1,

    uint8 dice2,

    uint8 dice3,

    uint24 betMask,

    uint bet1Amount,

    uint bet2Amount,

    uint bet3Amount,

    uint bet4Amount,

    uint bet5Amount

  )

  private view returns (uint winAmount)

  {

    uint8 betCount = 0;

    uint24 flag = 0;

    uint8 sum = dice1 + dice2 + dice3;

    uint8 i = 0;



    for (i = 0; i < BET_MASK_COUNT; i++) {

      flag = uint24(1) << i;

      if(uint24(betMask & flag) == 0){

        continue;

      }else{

        betCount += 1;

      }

      if(i < 14){

        if(sum == betNumberResults[flag]){

          winAmount += odds[flag] * _nextAmount(

            betCount,

            bet1Amount,

            bet2Amount,

            bet3Amount,

            bet4Amount,

            bet5Amount

          );

        }

        continue;

      }

      if(i >= 14 && i < 20){

        if(dice1 == betSameResults[flag] && dice1 == dice2 && dice1 == dice3){

          winAmount += odds[flag] * _nextAmount(

            betCount,

            bet1Amount,

            bet2Amount,

            bet3Amount,

            bet4Amount,

            bet5Amount

          );

        }

        continue;

      }

      if(

        i == 20 &&

        (sum >= 4 && sum <= 10)  &&

        (dice1 != dice2 || dice1 != dice3 || dice2 != dice3)

      ){

        winAmount += odds[flag] * _nextAmount(

          betCount,

          bet1Amount,

          bet2Amount,

          bet3Amount,

          bet4Amount,

          bet5Amount

        );

      }

      if(

        i == 21 &&

        (sum >= 11 && sum <= 17)  &&

        (dice1 != dice2 || dice1 != dice3 || dice2 != dice3)

      ){

        winAmount += odds[flag] * _nextAmount(

          betCount,

          bet1Amount,

          bet2Amount,

          bet3Amount,

          bet4Amount,

          bet5Amount

        );

      }

      if(betCount == MAX_BET){

        break;

      }

    }

  }



  // Choose next amount by bet count

  function _nextAmount(

    uint8 betCount,

    uint bet1Amount,

    uint bet2Amount,

    uint bet3Amount,

    uint bet4Amount,

    uint bet5Amount

  )

  private pure returns (uint amount)

  {

    if(betCount == 1){

      return bet1Amount;

    }

    if(betCount == 2){

      return bet2Amount;

    }

    if(betCount == 3){

      return bet3Amount;

    }

    if(betCount == 4){

      return bet4Amount;

    }

    if(betCount == 5){

      return bet5Amount;

    }

  }





  // lock = 1, lock

  // lock = 0, unlock

  function _lockOrUnlockAmount(

    uint24 betMask,

    uint bet1Amount,

    uint bet2Amount,

    uint bet3Amount,

    uint bet4Amount,

    uint bet5Amount,

    uint8 lock

  )

  private

  {

    uint8 betCount;

    uint possibleWinAmount;

    uint betBigSmallWinAmount = 0;

    uint betNumberWinAmount = 0;

    uint betSameWinAmount = 0;

    uint24 flag = 0;

    for (uint8 i = 0; i < BET_MASK_COUNT; i++) {

      flag = uint24(1) << i;

      if(uint24(betMask & flag) == 0){

        continue;

      }else{

        betCount += 1;

      }

      if(i < 14 ){

        betNumberWinAmount = _assertAmount(

          betCount,

          bet1Amount,

          bet2Amount,

          bet3Amount,

          bet4Amount,

          bet5Amount,

          MAX_AMOUNT_NUMBER,

          odds[flag],

          betNumberWinAmount

        );

        continue;

      }

      if(i >= 14 && i < 20){

        betSameWinAmount = _assertAmount(

          betCount,

          bet1Amount,

          bet2Amount,

          bet3Amount,

          bet4Amount,

          bet5Amount,

          MAX_AMOUNT_SAME,

          odds[flag],

          betSameWinAmount

        );

        continue;

      }

      if(i >= 20){

         betBigSmallWinAmount = _assertAmount(

          betCount,

          bet1Amount,

          bet2Amount,

          bet3Amount,

          bet4Amount,

          bet5Amount,

          MAX_AMOUNT_BIG_SMALL,

          odds[flag],

          betBigSmallWinAmount

        );

        continue;

      }

      if(betCount == MAX_BET){

        break;

      }

    }

    if(betSameWinAmount >= betBigSmallWinAmount){

      possibleWinAmount += betSameWinAmount;

    }else{

      possibleWinAmount += betBigSmallWinAmount;

    }

    possibleWinAmount += betNumberWinAmount;



    // Check that game has valid number of bets

    require (betCount > 0 && betCount <= MAX_BET,

      "Place bet count should be within range.");



    if(lock == 1){

      // Lock funds.

      lockedInBets += possibleWinAmount;

      // Check whether contract has enough funds to process this bet.

      require (lockedInBets <= address(this).balance,

        "Cannot afford to lose this bet.");

    }else{

      // Unlock funds.

      lockedInBets -= possibleWinAmount;

      require (lockedInBets >= 0,

        "Not enough locked in amount.");

    }

  }



  function _max(uint amount, uint8 odd, uint possibleWinAmount)

  private pure returns (uint newAmount)

  {

    uint winAmount = amount * odd;

    if( winAmount > possibleWinAmount){

      return winAmount;

    }else{

      return possibleWinAmount;

    }

  }



  function _assertAmount(

    uint8 betCount,

    uint amount1,

    uint amount2,

    uint amount3,

    uint amount4,

    uint amount5,

    uint maxAmount,

    uint8 odd,

    uint possibleWinAmount

  )

  private pure returns (uint amount)

  {

    string memory warnMsg = "Place bet amount should be within range.";

    if(betCount == 1){

      require (amount1 >= MIN_AMOUNT && amount1 <= maxAmount, warnMsg);

      return _max(amount1, odd, possibleWinAmount);

    }

    if(betCount == 2){

      require (amount2 >= MIN_AMOUNT && amount2 <= maxAmount, warnMsg);

      return _max(amount2, odd, possibleWinAmount);

    }

    if(betCount == 3){

      require (amount3 >= MIN_AMOUNT && amount3 <= maxAmount, warnMsg);

      return _max(amount3, odd, possibleWinAmount);

    }

    if(betCount == 4){

      require (amount4 >= MIN_AMOUNT && amount4 <= maxAmount, warnMsg);

      return _max(amount4, odd, possibleWinAmount);

    }

    if(betCount == 5){

      require (amount5 >= MIN_AMOUNT && amount5 <= maxAmount, warnMsg);

      return _max(amount5, odd, possibleWinAmount);

    }

  }



  // Standard modifier on methods invokable only by contract owner.

  modifier onlyOwner {

      require (msg.sender == owner, "OnlyOwner methods called by non-owner.");

      _;

  }



  // Standard contract ownership transfer implementation,

  function approveNextOwner(address _nextOwner) external onlyOwner {

    require (_nextOwner != owner, "Cannot approve current owner.");

    nextOwner = _nextOwner;

  }



  function acceptNextOwner() external {

    require (msg.sender == nextOwner, "Can only accept preapproved new owner.");

    owner = nextOwner;

  }



  // Fallback function deliberately left empty. It's primary use case

  // is to top up the bank roll.

  function () public payable {

  }



  // See comment for "secretSigner" variable.

  function setSecretSigner(address newSecretSigner) external onlyOwner {

    secretSigner = newSecretSigner;

  }



  // Funds withdrawal to cover team costs.

  function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {

    require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");

    require (lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");

    sendFunds(beneficiary, withdrawAmount);

  }



  // Contract may be destroyed only when there are no ongoing bets,

  // either settled or refunded. All funds are transferred to contract owner.

  function kill() external onlyOwner {

      require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");

      selfdestruct(owner);

  }



  // Close or open the game.

  function enable(bool _enabled) external onlyOwner{

    enabled = _enabled;

  }



}