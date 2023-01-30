/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

/**
 * Do not send tokens to this contract directly!
 * 
 * Allows EDG token holders to lend the Edgeless Casino tokens for the bankroll.
 * Users may pay in their tokens at any time, but they will only be used for the bankroll
 * begining from the next cycle. When the cycle is closed, they may
 * withdraw their stake of the bankroll. The casino may decide to limit the number of tokens
 * used for the bankroll.
 * Non-withdrawn tokens after cycle is finished is not automaticaly staked for the next round,
 * but they can be withdrawn by staker in any time.
 * author: Rytis Grincevicius <rytis@edgeless.io>
 * */

pragma solidity ^0.5.10;

contract Token {
  function transfer(address receiver, uint amount) public returns(bool);
  function transferFrom(address sender, address receiver, uint amount) public returns(bool);
  function balanceOf(address holder) public view returns(uint);
}

contract Casino {
  mapping(address => bool) public authorized;
}

contract Owned {
  address public owner;
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address newOwner) onlyOwner public {
    owner = newOwner;
  }
}

contract SafeMath {

	function safeSub(uint a, uint b) pure internal returns(uint) {
		assert(b <= a);
		return a - b;
	}

	function safeAdd(uint a, uint b) pure internal returns(uint) {
		uint c = a + b;
		assert(c >= a && c >= b);
		return c;
	}

	function safeMul(uint a, uint b) pure internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
}

contract BankrollLending is Owned, SafeMath {
  struct CycleData {
      /** How musch stakers we got in this cycle */
      uint numHolders;
      /** Total staked amount */
      uint initialStakes;
      /** Amount received from bankroll (staked + 40% of bankroll surpluss) */
      uint finalStakes;
      /** Amount distributed to stakers for withdrawals. It decreases when user withdraws. */
      uint totalStakes;
      /** Last staker wallet index that had his share distributed */
      uint lastUpdateIndex;
      /** Amount of balance to return to bankroll. (If all stakers are ranked VIP then this amount should be 0) */
      uint returnToBankroll;
      /** Allows withdrawals when set to true */
      bool sharesDistributed;
      /** Stakers address to Staker struct */
      mapping(address => Staker) addressToStaker;
      /** staker address to available staker balance */
      mapping(address => uint) addressToBalance;
      /** Index to staker address */
      address[] indexToAddress;
  }
  struct Staker {
    /** Index of staker */
    uint stakeIndex;
    /** Staker rank */
    StakingRank rank;
    /** How much staked for this stake round */
    uint staked;
    /** How much staker payout was for stake round */
    uint payout;
  }
  /** The set of lending contracts state phases **/
  enum StakingPhases { deposit, bankroll }
  /** The set of staking ranks **/
  enum StakingRank { vip, gold, silver }
  /** The number of the current cycle. Increases by 1 each round.**/
  uint public cycle;
  /** Cycle data */
  mapping(uint => CycleData) public cycleToData;
  /** Phase of current round */
  StakingPhases public phase; 
  /** The address of the casino contract.**/
  Casino public casino;
  /** The Edgeless casino token contract **/
  Token public token;
  /** Previuos staking contract **/
  address public predecessor;
  /** Wallet to return bankroll surplus share of stakers who doesnt get all 100% */
  address public returnBankrollTo;
  /** The minimum staking amount required **/
  uint public minStakingAmount;
  /** The maximum number of addresses to process in one batch of stake updates **/
  uint public maxUpdates; 
  /** Marks contract as paused. */
  bool public paused;
  /** Share of vip rank */
  uint vipRankShare;
  /** Share of gold rank */
  uint goldRankShare;
  /** Share of silver rank */
  uint silverRankShare;
  
  /** notifies listeners about a stake update **/
  event StakeUpdate(address holder, uint stake);

  /**
   * Constructor.
   * @param tokenAddr the address of the edgeless token contract
   *        casinoAddr the address of the edgeless casino contract
   *        predecessorAdr the address of the previous bankroll lending contract.
   * */
  constructor(address tokenAddr, address casinoAddr, address predecessorAdr) public {
    token = Token(tokenAddr);
    casino = Casino(casinoAddr);
    predecessor = predecessorAdr;
    returnBankrollTo = casinoAddr;
    maxUpdates = 200;
    cycle = 10;
    
    vipRankShare = 1000;
    goldRankShare = 500;
    silverRankShare = 125;
  }
  
  /**
   * Changes share of specified ranks that would be assigned from bankroll surpluss.
   * @param _rank   staking rank (0 - vip, 1 - gold, 2 - silver)
   * @param _share  share 0 - 1000, 1000 is 100%.
   */
  function setStakingRankShare(StakingRank _rank, uint _share) public onlyOwner {
    if (_rank == StakingRank.vip) {
        vipRankShare = _share;
    } else if (_rank == StakingRank.gold) {
        goldRankShare = _share;
    } else if (_rank == StakingRank.silver) {
        silverRankShare = _share;
    }
  }
  
  /**
   * Get share of staking rank.
   * @param _rank staking rank  (0 - vip, 1 - gold, 2 - silver)
   * @return share 0 - 1000, 1000 is 100%
   */
  function getStakingRankShare(StakingRank _rank) public view returns (uint) {
   if (_rank == StakingRank.vip) {
       return vipRankShare;
    } else if (_rank == StakingRank.gold) {
       return goldRankShare;
    } else if (_rank == StakingRank.silver) {
       return silverRankShare;
    }
    return 0;
  }
  
  /**
   * Allows authorized wallet to change stakers VIP ranking for current round.
   * @param _address stakers wallet address
   * @param _rank new vip rank of staker. (0 - vip, 1 - gold, 2 - silver)
   */
  function setStakerRank(address _address, StakingRank _rank) public onlyAuthorized {
      Staker storage _staker = cycleToData[cycle].addressToStaker[_address];
      require(_staker.staked > 0, "Staker not staked.");
      _staker.rank = _rank;
  }
  
  /**
   * Allows owner to change returnBankrollTo address
   * @param _address address to send tokens to
   */
  function setReturnBankrollTo(address _address) public onlyOwner {
      returnBankrollTo = _address;
  }
  
  /**
   * Pause contract so it would not allow to make new deposits.
   */
  function setPaused() public onlyOwner onlyActive {
      paused = true;
  }
  
  /**
   * Enable deposits.
   */ 
  function setActive() public onlyOwner onlyPaused {
      paused = false;
  }
  
  /**
   * Allows staker to withdraw staked amount + bankroll share of previous round.
   * @param _receiver address withdraw tokens to
   */
  function withdraw(address _receiver) public {
      makeWithdrawal(msg.sender, _receiver, safeSub(cycle, 1));
  }
  
  /**
   * Allows staker to withdraw staked amount + bankroll share of previous round.
   * @param _cycle cycle index from which to withdraw.
   * @param _receiver address withdraw tokens to
   */
  function withdraw(address _receiver, uint _cycle) public {
      makeWithdrawal(msg.sender, _receiver, _cycle);
  }
  
  /**
   * Allow authorized wallet to withdraw stakers balance back to stakers wallet.
   * @param _address    staker address
   * @param _cycle      cycle index from which to withdraw.
   */
  function withdrawFor(address _address, uint _cycle) public onlyAuthorized {
      makeWithdrawal(_address, _address, _cycle);
  }
  
  /**
   * Send collected stakes to casino contract and advance staking to bankroll phase.
   */
  function useAsBankroll() public onlyAuthorized depositPhase {
      CycleData storage _cycle = cycleToData[cycle];
      _cycle.initialStakes = _cycle.totalStakes;
      _cycle.totalStakes = 0;
      assert(token.transfer(address(casino), _cycle.initialStakes));
      phase = StakingPhases.bankroll;
  }
  
  /**
   * Closes staking round with amount to distribute and creates new round with deposit phase.
   * @param _finalStakes    Token amount (0 decimals) of amount to be distributed for stakers. (Staked amount + 40% casino surpluss)
   */
  function closeCycle(uint _finalStakes) public onlyAuthorized bankrollPhase {
      CycleData storage _cycle = cycleToData[cycle];
      _cycle.finalStakes = _finalStakes;
      cycle = safeAdd(cycle, 1);
      phase = StakingPhases.deposit;
  }
  
  /**
   * Distributes user shares for previous round.
   */
  function updateUserShares() public onlyAuthorized {
      _updateUserShares(cycle - 1);
  }

  /**
   * Distributes user shares for selected finished round.
   * @param _cycleIndex Index of cycle to update shares.
   */
  function updateUserShares(uint _cycleIndex) public onlyAuthorized {
      _updateUserShares(_cycleIndex);
  }
  
  /**
   * Allows to deposit tokens to staking. Wallet must approve staking contract to transfer its tokens.
   * Transfaction must be signed by authorized wallet to confirm rank and allowance.
   */
  function deposit(uint _value, StakingRank _rank, uint _allowedMax, uint8 v, bytes32 r, bytes32 s) public depositPhase onlyActive {
      require(verifySignature(msg.sender, _allowedMax, _rank, v, r, s));
      makeDeposit(msg.sender, _value, _rank, _allowedMax);
  }
  
  /**
   * Allow authorized wallet to deposit on wallet behalft. Wallet must approve staking contract to transfer its tokens.
   */
  function depositFor(address _address, uint _value, StakingRank _rank, uint _allowedMax) public depositPhase onlyActive onlyAuthorized {
      makeDeposit(_address, _value, _rank, _allowedMax);
  }
  
  /**
   * Holders of current staking round.
   */
  function numHolders() public view returns (uint) {
      return cycleToData[cycle].numHolders;
  }
  
  /**
   * Get holder address by index.
   * @param _index staker index in array.
   */ 
  function stakeholders(uint _index) public view returns (address) {
      return stakeholders(cycle, _index);
  }
  
  /**
   * Get holder balance by address.
   * @param _address staker address.
   */ 
  function stakes(address _address) public view returns (uint) {
      return stakes(cycle, _address);
  }
  
  /**
   * Get holder information by address.
   * @param _address staker address.
   */ 
  function staker(address _address) public view returns (uint stakeIndex, StakingRank rank, uint staked, uint payout) {
      return staker(cycle, _address);
  }
  
  /**
   * Returns token amount staked to contract
   */
  function totalStakes() public view returns (uint) {
      return totalStakes(cycle);
  }
  
  /**
   * Returns token amount of initial stakes
   */
  function initialStakes() public view returns (uint) {
      return initialStakes(cycle);
  }
  
   /**
   * Get holder address by cycle and index.
   * @param _cycle cycle to look
   * @param _index staker index in array.
   */ 
  function stakeholders(uint _cycle, uint _index) public view returns (address) {
      return cycleToData[_cycle].indexToAddress[_index];
  }
  
  /**
   * Returns available EDG balance of staker.
   * @param _cycle cycle index to look
   * @param _address staker address
   */
  function stakes(uint _cycle, address _address) public view returns (uint) {
      return cycleToData[_cycle].addressToBalance[_address];
  }

  /**
   * Returns info about staker in round. 
   * @param _cycle cycle index to look
   * @param _address staker address
   */
  function staker(uint _cycle, address _address) public view returns (uint stakeIndex, StakingRank rank, uint staked, uint payout ) {
      Staker memory _s = cycleToData[_cycle].addressToStaker[_address];
      return (_s.stakeIndex, _s.rank, _s.staked, _s.payout);
  }
  
  /**
   * Returns token amount staked to contract
   * @param _cycle cycle index to look
   */
  function totalStakes(uint _cycle) public view returns (uint) {
      return cycleToData[_cycle].totalStakes;
  }
  
  /**
   * Returns token amount of initial stakes
   * @param _cycle cycle index to look
   */
  function initialStakes(uint _cycle) public view returns (uint) {
      return cycleToData[_cycle].initialStakes;
  }
  
  /**
   * Returns token amount of final stakes
   * @param _cycle cycle index to look
   */
  function finalStakes(uint _cycle) public view returns (uint) {
      return cycleToData[_cycle].finalStakes;
  }

  /**
   * Sets the casino contract address.
   * @param casinoAddr the new casino contract address
   * */
  function setCasinoAddress(address casinoAddr) public onlyOwner {
    casino = Casino(casinoAddr);
  }
  
  /**
   * Sets the maximum number of user stakes to update at once
   * @param newMax the new maximum
   * */
  function setMaxUpdates(uint newMax) public onlyAuthorized {
    maxUpdates = newMax;
  }
  
  /**
   * Sets the minimum amount of user stakes
   * @param amount the new minimum
   * */
  function setMinStakingAmount(uint amount) public onlyAuthorized {
    minStakingAmount = amount;
  }

  /**
  * Closes the contract in state of emergency or on contract update.
  * Transfers all tokens held by the contract to the owner before doing so.
  **/
  function kill() public onlyOwner {
    assert(token.transfer(owner, tokenBalance()));
    selfdestruct(address(uint160(owner)));
  }

  /**
  * @return the current token balance of the contract.
  * */
  function tokenBalance() public view returns(uint) {
    return token.balanceOf(address(this));
  }
  
  /**
   * Withdrawal logic. Withdraws all balance from stakers staking contract and transfers to his deposit wallet.
   * @param _address    staker address for which to withdraw
   * @param _receiver   address withdraw to.
   * @param _cycle      cycle index from which to withdraw.
   */
  function makeWithdrawal(address _address, address _receiver, uint _cycle) internal {
      require(_cycle < cycle, "Withdrawal possible only for finished rounds.");
      CycleData storage _cycleData = cycleToData[_cycle];
      require(_cycleData.sharesDistributed == true, "All user shares must be distributed to stakeholders first.");
      uint _balance = _cycleData.addressToBalance[_address];
      require(_balance > 0, "Staker doesn't have balance.");
      _cycleData.addressToBalance[_address] = 0;
      _cycleData.totalStakes = safeSub(_cycleData.totalStakes, _balance);
      emit StakeUpdate(_address, 0);
      assert(token.transfer(_receiver, _balance));
  }
  
  
  /**
   * Calculates and distributes shares for stakers.
   * When all staker shares distributed it sets cycleToData[cycle].sharesDistributed to true and unlocks withdrawals.
   * @param _cycleIndex round index for which calculations should be made.
   */
  function _updateUserShares(uint _cycleIndex) internal {
      require(cycle > 0 && cycle > _cycleIndex, "You can't distribute shares of previous cycle when there isn't any.");
      CycleData storage _cycle = cycleToData[_cycleIndex];
      require(_cycle.sharesDistributed == false, "Shares already distributed.");
      uint limit = safeAdd(_cycle.lastUpdateIndex, maxUpdates);
      if (limit >= _cycle.numHolders) {
          limit = _cycle.numHolders;
      }
      address _address;
      uint _payout;
      uint _totalStakes = _cycle.totalStakes;
      for (uint i = _cycle.lastUpdateIndex; i < limit; i++) {
          _address = _cycle.indexToAddress[i];
          Staker storage _staker = _cycle.addressToStaker[_address];
          _payout = computeFinalStake(_staker.staked, _staker.rank, _cycle);
          _staker.payout = _payout;
          _cycle.addressToBalance[_address] = _payout;
          _totalStakes = safeAdd(_totalStakes, _payout);
          emit StakeUpdate(_address, _payout);
      }
      _cycle.totalStakes = _totalStakes;
      _cycle.lastUpdateIndex = limit;
      if (limit >= _cycle.numHolders) {
          if (_cycle.finalStakes > _cycle.totalStakes) {
            _cycle.returnToBankroll = safeSub(_cycle.finalStakes, _cycle.totalStakes);
            if (_cycle.returnToBankroll > 0) {
                assert(token.transfer(returnBankrollTo, _cycle.returnToBankroll));
            }
          }
          _cycle.sharesDistributed = true;
      }
  }
  
   /**
    * Calculates stakers profit / loss.
    * @param _initialStake how much holder initialy staked for the round
    * @param _vipRank vip rank of the holder
    * @param _cycleData data of the cycle
    */
   function computeFinalStake(uint _initialStake, StakingRank _vipRank, CycleData storage _cycleData) internal view returns(uint) {
       if (_cycleData.finalStakes >= _cycleData.initialStakes) {
        uint profit = ((_initialStake * _cycleData.finalStakes / _cycleData.initialStakes) - _initialStake) * getStakingRankShare(_vipRank) / 1000;
        return _initialStake + profit;
      } else {
        uint loss = (_initialStake - (_initialStake * _cycleData.finalStakes / _cycleData.initialStakes));
        return _initialStake - loss;
      }
    }
    
   /**
    * Deposit logic.
    * @param _address holder address
    * @param _value how much to deposit
    * @param _rank vip rank to set for holder
    * @param _allowedMax what is maximum total deposit for the holder
    */
   function makeDeposit(address _address, uint _value, StakingRank _rank, uint _allowedMax) internal {
       require(_value > 0);
       CycleData storage _cycle = cycleToData[cycle];
       uint _balance = _cycle.addressToBalance[_address];
       uint newStake = safeAdd(_balance, _value);
       require(newStake >= minStakingAmount);
       if(_allowedMax > 0){ //if allowedMax > 0 the caller is the user himself
           require(newStake <= _allowedMax);
           assert(token.transferFrom(_address, address(this), _value));
       }
       Staker storage _staker = _cycle.addressToStaker[_address];
       
       if (_cycle.addressToBalance[_address] == 0) {
           uint _numHolders = _cycle.indexToAddress.push(_address);
           _cycle.numHolders = _numHolders;
           _staker.stakeIndex = safeSub(_numHolders, 1);
       }
       
       _cycle.addressToBalance[_address] = newStake;
       _staker.staked = newStake;
       _staker.rank = _rank;
       
       _cycle.totalStakes = safeAdd(_cycle.totalStakes, _value);
       
       emit StakeUpdate(_address, newStake);
   }

  /**
   * verifies if the withdrawal request was signed by an authorized wallet
   * @param to      the receiver address
   *        value   the number of tokens
   *        rank    the vip rank
   *        v, r, s the signature of an authorized wallet
   * */
  function verifySignature(address to, uint value, StakingRank rank, uint8 v, bytes32 r, bytes32 s) internal view returns(bool) {
    address signer = ecrecover(keccak256(abi.encodePacked(to, value, rank, cycle)), v, r, s);
    return casino.authorized(signer);
  }
  
  //check if the sender is an authorized casino wallet
  modifier onlyAuthorized {
    require(casino.authorized(msg.sender), "Only authorized wallet can request this method.");
    _;
  }

  modifier depositPhase {
    require(phase == StakingPhases.deposit, "Method can be run only in deposit phase.");
    _;
  }

  modifier bankrollPhase {
    require(phase == StakingPhases.bankroll, "Method can be run only in bankroll phase.");
    _;
  }
  
  modifier onlyActive() {
    require(paused == false, "Contract is paused.");
    _;
  }
  
  modifier onlyPaused() {
    require(paused == true, "Contract is not paused.");
    _;
  }

}