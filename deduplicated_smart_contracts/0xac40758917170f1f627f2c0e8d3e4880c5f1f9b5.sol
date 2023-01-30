/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

// File: localhost/game_coinflip/node_modules/openzeppelin-solidity/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



// File: localhost/game_coinflip/node_modules/openzeppelin-solidity/contracts/access/Ownable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File: localhost/game_coinflip/node_modules/openzeppelin-solidity/contracts/utils/Pausable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: localhost/game_coinflip/contracts/GameRaffle.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;



abstract contract GameRaffle is Ownable {
  using SafeMath for uint256;

  struct RaffleResult {
    address winner;
    uint256 prize;
    uint256 time;
  }
  
  mapping(address => uint256) public rafflePrizePendingForAddress;
  uint256 public ongoinRafflePrize;
  uint256 public rafflePrizesWonTotal;

  uint256 public raffleActivationParticipantsAmount = 200;  //  1 game has 2 participants
  address[] public raffleParticipants;  //  the more you play, the more times added
  RaffleResult[] public raffleResults;


  event CF_RafflePlayed(address indexed winner, uint256 indexed prize);
  event CF_RafflePrizeWithdrawn(address indexed winner, uint256 indexed prize);


  /**
   * @dev Gets raffle participants.
   * @return Participants count.
   * TESTED
   */
  function getRaffleParticipants() public view returns (address[] memory) {
    return raffleParticipants;
  }
  
  /**
   * @dev Updates raffle minimum participants count to activate.
   * @param _amount Amount to be set.
   * TESTED
   */
  function updateRaffleActivationParticipantsCount(uint256 _amount) external onlyOwner {
    require(_amount > 0, "Should be > 0");
    raffleActivationParticipantsAmount = _amount;
  }

  /**
   * @dev Gets past raffle results count.
   * @return Results count.
   * TESTED
   */
  function getRaffleResultCount() external view returns (uint256) {
    return raffleResults.length;
  }

  /**
   * @dev Checks if raffle is activated.
   * @return Wether raffle is activated.
   * TESTED
   */
  function raffleActivated() public view returns(bool) {
    return (raffleParticipants.length >= raffleActivationParticipantsAmount && ongoinRafflePrize > 0);
  }

  /**
   * @dev Runs the raffle.
   * TESTED
   */
  function runRaffle() external {
    require(raffleActivated(), "Raffle != activated");

    uint256 winnerIdx = rand();
    rafflePrizePendingForAddress[raffleParticipants[winnerIdx]] = rafflePrizePendingForAddress[raffleParticipants[winnerIdx]].add(ongoinRafflePrize);
    rafflePrizesWonTotal = rafflePrizesWonTotal.add(ongoinRafflePrize);
    raffleResults.push(RaffleResult(raffleParticipants[winnerIdx], ongoinRafflePrize, now));

    emit CF_RafflePlayed(raffleParticipants[winnerIdx], ongoinRafflePrize);

    delete ongoinRafflePrize;
    delete raffleParticipants;
  }

  /**
   * @dev Generates random number
   * TESTED
   */
  function rand() public view returns(uint256) {
    require(raffleParticipants.length > 0, "No participants");
    return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, ongoinRafflePrize, raffleParticipants.length))) % raffleParticipants.length;
  }

  /**
   * @dev Withdraw prizes for all won raffles.
   */
  function withdrawRafflePrizes() external virtual;
}

// File: localhost/game_coinflip/node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: localhost/game_coinflip/contracts/Partnership.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;



/**
 * @dev Contract module which provides a basic fu=nctionality for donates to partner address.
 */
contract Partnership is Ownable {
  using SafeMath for uint256;
  
  address payable public partner;
  
  uint256 public partnerFeeTransferThreshold;
  uint256 public partnerFeePending;
  uint256 public partnerFeeTotalUsed;

  event CF_PartnerFeeTransferred(address from, address indexed to, uint256 indexed amount);

  /**
   * @dev Initializes the contract.
   * @param _partnerAddress Partner address.
   * @param _transferThreshold Fee amount, that should trigger transfer.
   * TESTED
   */
  constructor(address payable _partnerAddress, uint256 _transferThreshold) public {
    updatePartner(_partnerAddress);
    updatePartnerTransferThreshold(_transferThreshold);
  }

  /**
   * @dev Updates partner address.
   * @param _partnerAddress Address for partner.
   * TESTED
   */
  function updatePartner(address payable _partnerAddress) public onlyOwner {
    require(_partnerAddress != address(0), "Cannt be 0x0");
    partner = _partnerAddress;
  }

  /**
   * @dev Updates partner fee transfer threshold limit, when fee should be transferred to address.
   * @notice In wei.
   * @param _transferThreshold Fee amount, that should trigger transfer.
   * TESTED
   */
  function updatePartnerTransferThreshold(uint256 _transferThreshold) public onlyOwner {
    require(_transferThreshold > 0, "threshold must be > 0");
    partnerFeeTransferThreshold = _transferThreshold;
  }

  /**
   * @dev Transfers partner fee to partner address if threshold was reached.
   * TESTED
   */
  function transferPartnerFee() internal {
    if (partnerFeePending >= partnerFeeTransferThreshold) {
      uint256 partnerFeePendingTmp = partnerFeePending;
      delete partnerFeePending;

      partnerFeeTotalUsed = partnerFeeTotalUsed.add(partnerFeePendingTmp);
      partner.transfer(partnerFeePendingTmp);
      emit CF_PartnerFeeTransferred(address(this), partner, partnerFeePendingTmp);
    }
  }
}

// File: localhost/game_coinflip/contracts/CoinFlipGame.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;




/**
  * @notice IMPORTANT: owner should create first game.
  * @notice CoinFlipGame can be created by creator and run by joined playr. Creator is not required to be online or perform any actions for game to be played.
  */

/**
  * Testing:
  *    update suspendedTimeDuration to 1 minute
  */

contract CoinFlipGame is Pausable, Partnership, GameRaffle {
  struct Game {
    uint8 creatorGuessCoinSide;
    uint256 id;
    uint256 bet;
    address payable creator;
    address payable opponent;
    address payable winner;
    address creatorReferral;
    address opponentReferral;
  }

  uint256 private constant FEE_PERCENT = 1;

  uint256 public minBet = 10 finney;
  uint256 public suspendedTimeDuration = 1 hours;

  uint256[5] public topGames;

  uint256 public gamesCreatedAmount;
  uint256 public gamesCompletedAmount; //  played, quitted, move expired

  mapping(uint256 => Game) public games;
  mapping(address => uint256) public ongoingGameIdxForCreator;
  mapping(address => uint256[]) private participatedGameIdxsForPlayer;
  mapping(address => uint256[]) public gamesWithPendingPrizeWithdrawalForAddress; //  for both won & draw

  mapping(address => uint256) public addressBetTotal;
  mapping(address => uint256) public addressPrizeTotal;

  mapping(address => uint256) public referralFeesPending;
  mapping(address => uint256) public referralFeesWithdrawn;

  mapping(address => uint256) public lastPlayTimestamp;

  uint256 public devFeePending;

  uint256 public totalUsedReferralFees;
  uint256 public totalUsedInGame;

  event CF_GameCreated(uint256 indexed id, address indexed creator, uint256 indexed bet);
  event CF_GamePlayed(uint256 indexed id, address indexed creator, address indexed opponent, address winner, uint256 bet);
  event CF_GamePrizesWithdrawn(address indexed player);
  event CF_GameAddedToTop(uint256 indexed id, address indexed creator);
  event CF_GameReferralWithdrawn(address indexed referral);
  event CF_GameUpdated(uint256 indexed id, address indexed creator);
 

  modifier onlyCorrectBet() {
    require(msg.value >= minBet, "Wrong bet");
    _;
  }

  modifier onlySingleGameCreated() {
    require(ongoingGameIdxForCreator[msg.sender] == 0, "No more creating");
    _;
  }

  modifier onlyAllowedToPlay() {
    require(allowedToPlay(), "Suspended to play");
    _;
  }

  modifier onlyCreator(uint256 _id) {
    require(games[_id].creator == msg.sender, "Not creator");
    _;
  }

  modifier onlyNotCreator(uint256 _id) {
    require(games[_id].creator != msg.sender, "Is creator");
    _;
  }


  /**
    * @dev Contract constructor.
    * @param _partner Address for partner.
    * TESTED
    */
  constructor(address payable _partner) Partnership (_partner, 1 ether) public {
    updatePartner(_partner);
  }

  /**
    * @dev Destroyes the contract.
    * TESTED
    */
  function kill() external onlyOwner {
    address payable addr = msg.sender;
    selfdestruct(addr);
  }
  
  /**
   * Pausable.sol
   * TESTED
   */
  /**
   * @dev Triggers stopped state.
   * TESTED
   */
  function pause() external onlyOwner {
    Pausable._pause();
  }

  /**
    * GAMEPLAY
    */

  /**
    * @dev Creates new game.
    * @param _guessCoinSide §³oin side (0 or 1).
    * @param _referral Address for referral.
    * TESTED
    */
  function createGame(uint8 _guessCoinSide, address _referral) external payable whenNotPaused onlySingleGameCreated onlyCorrectBet {
    require(_guessCoinSide < 2, "Wrong guess coin side");
    require(_referral != msg.sender, "Wrong referral");

    addressBetTotal[msg.sender] = addressBetTotal[msg.sender].add(msg.value);

    games[gamesCreatedAmount].id = gamesCreatedAmount;
    games[gamesCreatedAmount].creator = msg.sender;
    games[gamesCreatedAmount].bet = msg.value;
    games[gamesCreatedAmount].creatorGuessCoinSide = _guessCoinSide;
    if (_referral != address(0)) {
      games[gamesCreatedAmount].creatorReferral = _referral;
    }

    ongoingGameIdxForCreator[msg.sender] = gamesCreatedAmount;
    participatedGameIdxsForPlayer[msg.sender].push(gamesCreatedAmount);

    totalUsedInGame = totalUsedInGame.add(msg.value);

    emit CF_GameCreated(gamesCreatedAmount, msg.sender, msg.value);

    gamesCreatedAmount = gamesCreatedAmount.add(1);
  }

  /**
    * @dev Joins and plays game.
    * @param _id Game id to join.
    * @param _referral Address for referral.
    * TESTED
    */
  function joinAndPlayGame(uint256 _id, address _referral) external payable onlyNotCreator(_id) onlyAllowedToPlay {
    Game storage game = games[_id];
    require(game.creator != address(0), "No game with such id");
    require(game.winner == address(0), "Game has winner");
    require(game.bet == msg.value, "Wrong bet");
    require(_referral != msg.sender, "Wrong referral");

    addressBetTotal[msg.sender] = addressBetTotal[msg.sender].add(msg.value);

    game.opponent = msg.sender;
    if (_referral != address(0)) {
      game.opponentReferral = _referral;
    }

    //  play
    uint8 coinSide = uint8(uint256(keccak256(abi.encodePacked(now, msg.sender, gamesCreatedAmount, totalUsedInGame,devFeePending))) %2);
    game.winner = (coinSide == game.creatorGuessCoinSide) ? game.creator : game.opponent;

    gamesWithPendingPrizeWithdrawalForAddress[game.winner].push(_id);

    raffleParticipants.push(game.creator);
    raffleParticipants.push(game.opponent);
    lastPlayTimestamp[msg.sender] = now;
    gamesCompletedAmount = gamesCompletedAmount.add(1);
    totalUsedInGame = totalUsedInGame.add(msg.value);
    participatedGameIdxsForPlayer[msg.sender].push(_id);
    delete ongoingGameIdxForCreator[game.creator];

    if (isTopGame(_id)) {
      removeTopGame(game.id);
    }

    emit CF_GamePlayed(_id, game.creator, game.opponent, game.winner, game.bet);
  }

  /**
    * WITHDRAW
    */

  /**
    * @dev Withdraws prize for won game.
    * @param _maxLoop max loop.
    * TESTED
    */
  function withdrawGamePrizes(uint256 _maxLoop) external {
    require(_maxLoop > 0, "_maxLoop == 0");
    
    uint256[] storage pendingGames = gamesWithPendingPrizeWithdrawalForAddress[msg.sender];
    require(pendingGames.length > 0, "no pending");
    require(_maxLoop <= pendingGames.length, "wrong _maxLoop");
    
    uint256 prizeTotal;
    for (uint256 i = 0; i < _maxLoop; i ++) {
      uint256 gameId = pendingGames[pendingGames.length.sub(1)];
      Game storage game = games[gameId];

      uint256 gamePrize = game.bet.mul(2);

      //  referral
      address winnerReferral = (msg.sender == game.creator) ? game.creatorReferral : game.opponentReferral;
      if (winnerReferral == address(0)) {
        winnerReferral = owner();
      }
      uint256 referralFee = gamePrize.mul(FEE_PERCENT).div(100);
      referralFeesPending[winnerReferral] = referralFeesPending[winnerReferral].add(referralFee);
      totalUsedReferralFees = totalUsedReferralFees.add(referralFee);
      
      prizeTotal += gamePrize;
      pendingGames.pop();
    }

    addressPrizeTotal[msg.sender] = addressPrizeTotal[msg.sender].add(prizeTotal);
    
    uint256 singleFee = prizeTotal.mul(FEE_PERCENT).div(100);
    partnerFeePending = partnerFeePending.add(singleFee);
    ongoinRafflePrize = ongoinRafflePrize.add(singleFee);
    devFeePending = devFeePending.add(singleFee.mul(2));

    prizeTotal = prizeTotal.sub(singleFee.mul(5));
    msg.sender.transfer(prizeTotal);

    //  partner transfer
    transferPartnerFee();

    emit CF_GamePrizesWithdrawn(msg.sender);
  }

  /**
    * @dev Withdraws referral fees.
    * TESTED
    */
  function withdrawReferralFees() external {
    uint256 feeTmp = referralFeesPending[msg.sender];
    require(feeTmp > 0, "No referral fee");

    delete referralFeesPending[msg.sender];
    referralFeesWithdrawn[msg.sender] = referralFeesWithdrawn[msg.sender].add(feeTmp);

    msg.sender.transfer(feeTmp);
    emit CF_GameReferralWithdrawn(msg.sender);
  }

  /**
    * @dev Withdraws developer fees.
    * TESTED
    */
  function withdrawDevFee() external onlyOwner {
    require(devFeePending > 0, "No dev fee");

    uint256 fee = devFeePending;
    delete devFeePending;

    msg.sender.transfer(fee);
  }

  /**
   * GameRaffle
   * TESTED
   */
  function withdrawRafflePrizes() external override {
    require(rafflePrizePendingForAddress[msg.sender] > 0, "No raffle prize");

    uint256 prize = rafflePrizePendingForAddress[msg.sender];
    delete rafflePrizePendingForAddress[msg.sender];
    
    addressPrizeTotal[msg.sender] = addressPrizeTotal[msg.sender].add(prize);

    uint256 singleFee = prize.mul(FEE_PERCENT).div(100);
    partnerFeePending = partnerFeePending.add(singleFee);
    devFeePending = devFeePending.add(singleFee.mul(2));

    //  transfer prize
    prize = prize.sub(singleFee.mul(3));
    msg.sender.transfer(prize);

    //  partner transfer
    transferPartnerFee();

    emit CF_RafflePrizeWithdrawn(msg.sender, prize);
  }

  /**
    * OTHER
    */

  /**
    * @dev Checks if player is allowed to play since last game played time.
    * @return Returns weather player is allowed to play.
    * TESTED
    */
  function allowedToPlay() public view returns (bool) {
    return now.sub(lastPlayTimestamp[msg.sender]) > suspendedTimeDuration;
  }

  /**
    * @dev Adds game idx to the beginning of topGames.
    * @param _id Game idx to be added.
    * TESTED
    */
  function addTopGame(uint256 _id) external payable onlyCreator(_id) {
    require(msg.value == minBet, "Wrong fee");
    require(topGames[0] != _id, "Top in TopGames");
        
    uint256[5] memory topGamesTmp = [_id, 0, 0, 0, 0];
    bool isIdPresent;
    for (uint8 i = 0; i < 4; i ++) {
      if (topGames[i] == _id && !isIdPresent) {
        isIdPresent = true;
      }
      topGamesTmp[i+1] = (isIdPresent) ? topGames[i+1] : topGames[i];
    }
    topGames = topGamesTmp;
    devFeePending = devFeePending.add(msg.value);
    totalUsedInGame = totalUsedInGame.add(msg.value);

    emit CF_GameAddedToTop(_id, msg.sender);
  }

  /**
    * @dev Removes game idx from topGames.
    * @param _id Game idx to be removed.
    * TESTED
    */
  function removeTopGame(uint256 _id) private {
    uint256[5] memory tmpArr;
    bool found;
    
    for(uint256 i = 0; i < 5; i ++) {
      if(topGames[i] == _id) {
        found = true;
      } else {
        if (found) {
          tmpArr[i-1] = topGames[i];
        } else {
          tmpArr[i] = topGames[i];
        }
      }
    }

    require(found, "Not TopGame");
    topGames = tmpArr;
  }

  /**
    * @dev Gets top games.
    * @return Returns list of top games.
    * TESTED
    */
  function getTopGames() external view returns (uint256[5] memory) {
    return topGames;
  }

  /**
    * @dev Checks if game id is in top games.
    * @param _id Game id to check.
    * @return Whether game id is in top games.
    * TESTED
    */
  function isTopGame(uint256 _id) public view returns (bool) {
    for (uint8 i = 0; i < 5; i++) {
      if (topGames[i] == _id) {
          return true;
      }
    }
    return false;
  }

  /**
    * @dev Returns game ids with pending withdrawal for address.
    * @param _address Player address.
    * @return ids Game ids.
    * TESTED
    */
  function getGamesWithPendingPrizeWithdrawalForAddress(address _address) external view returns (uint256[] memory ids) {
    ids =  gamesWithPendingPrizeWithdrawalForAddress[_address];
  }

  /**
   * @dev Updates bet for game.
   * @param _id Game index.
   * TESTED
   */
  function increaseBetForGameBy(uint256 _id) whenNotPaused onlyCreator(_id) external payable {
    require(msg.value > 0, "increase must be > 0");

    addressBetTotal[msg.sender] = addressBetTotal[msg.sender].add(msg.value);
    
    games[_id].bet = games[_id].bet.add(msg.value);
    totalUsedInGame = totalUsedInGame.add(msg.value);
    emit CF_GameUpdated(_id, msg.sender);
  }

  /**
    * @dev Updates minimum bet value. Can be 0 if no restrictions.
    * @param _minBet Min bet value.
    * TESTED
    */
  function updateMinBet(uint256 _minBet) external onlyOwner {
    require(_minBet > 0, "Wrong bet");
    minBet = _minBet;
  }

  /**
    * @dev Updates spended time duration.
    * @param _duration time duration value.
    * TESTED
    */
  function updateSuspendedTimeDuration(uint256 _duration) external onlyOwner {
    require(_duration > 0, "Wrong duration");
    suspendedTimeDuration = _duration;
  }

  /**
    * @dev Gets game indexes where player participated. Created and joined
    * @param _address Player address.
    * @return List of indexes.
    * TESTED
    */
  function getParticipatedGameIdxsForPlayer(address _address) external view returns (uint256[] memory) {
    require(_address != address(0), "Cannt be 0x0");
    return participatedGameIdxsForPlayer[_address];
  }
}