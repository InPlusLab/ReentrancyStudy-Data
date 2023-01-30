/**
 *Submitted for verification at Etherscan.io on 2019-07-21
*/

pragma solidity ^ 0.5 .1;

// ----------------------------------------------------------------------------
//'Butt Coin' contract, version 1.0
// Version 0.1 was a fart during a launch, with a confusing _totalSupply and the way Ethereum tracks the burning.
// This coin can be mined, and a _totalSupply is dynamic.
//
// Symbol      : BUTT
// Name        : Butt Coin
// Total supply: Dynamic
// Decimals    : 8
// Worty mention: 0XBitCoin
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------

library SafeMath {

  //addition
  function add(uint a, uint b) internal pure returns(uint c) {
    c = a + b;
    require(c >= a);
  }

  //subtraction
  function sub(uint a, uint b) internal pure returns(uint c) {
    require(b <= a);
    c = a - b;
  }

  //multiplication
  function mul(uint a, uint b) internal pure returns(uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }

  //division
  function div(uint a, uint b) internal pure returns(uint c) {
    require(b > 0);
    c = a / b;
  }

  //ceil
  function ceil(uint256 a, uint256 m) internal pure returns(uint256) {
    uint256 c = add(a, m);
    uint256 d = sub(c, 1);
    return mul(div(d, m), m);
  }

}

library ExtendedMath {
  //also known as the minimum
  function limitLessThan(uint a, uint b) internal pure returns(uint c) {
    if (a > b) return b;
    return a;
  }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------

contract ERC20Interface {
    
  function totalSupply() public view returns(uint);
  function burned() public view returns(uint);
  function minted() public view returns(uint);
  function mintingEpoch() public view returns(uint);
  function balanceOf(address tokenOwner) public view returns(uint balance);
  function allowance(address tokenOwner, address spender) public view returns(uint remaining);
  function transfer(address to, uint tokens) public returns(bool success);
  function approve(address spender, uint tokens) public returns(bool success);
  function transferFrom(address from, address to, uint tokens) public returns(bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------

contract Owned {
    
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------

contract BUTTv1 is ERC20Interface, Owned {

  using SafeMath for uint;
  using ExtendedMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint256 public _totalSupply;
  uint256 public _burned;
  uint256 public _mintingEpoch;
  uint public latestDifficultyPeriodStarted;

  uint public epochCount; //number of 'blocks' mined

  uint public _BLOCKS_PER_READJUSTMENT = 64;

  //a little number
  uint public _MINIMUM_TARGET = 2 ** 16;

  //a big number is easier ; just find a solution that is smaller
  uint public _MAXIMUM_TARGET = 2 ** 234;

  uint public miningTarget;
  bytes32 public challengeNumber; //generate a new one when a new reward is minted

  uint public rewardEra;
  uint public maxSupplyForEra;

  address public lastRewardTo;
  uint public lastRewardAmount;
  uint public lastRewardEthBlockNumber;


  mapping(bytes32 => bytes32) solutionForChallenge;
  uint public tokensMinted;

  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
  
  

  uint private basePercent;
  bool private locked = false;
  address private previousSender = address(0); //the previous user of a contract

  
  event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

  // ------------------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------------------

  constructor() public {
    if (locked) revert();
    
    symbol = "BUTT";
    name = "Butt Coin";
    decimals = 8;
    basePercent = 100;
    
    _totalSupply = 0; //initial amount before any tokens are minted
    uint toMint = 33554432 * 10 ** uint(decimals); 
    _mint(msg.sender, toMint);
    _mintingEpoch = 0;

    tokensMinted = toMint;
    _totalSupply = _totalSupply.add(toMint);
    rewardEra = 1;
    maxSupplyForEra = 2;
    miningTarget = _MAXIMUM_TARGET;
    latestDifficultyPeriodStarted = block.number;
    _startNewMiningEpoch();
    
    locked = true;
  }
  
  // ------------------------------------------------------------------------
  // The minting of tokens before the mining.
  // ------------------------------------------------------------------------
  function _mint(address account, uint256 amount) internal {
    if (locked) revert();
    require(amount != 0);
    balances[account] = balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  // ------------------------------------------------------------------------
  // The minting of tokens during the mining.
  // ------------------------------------------------------------------------
  function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {
      
      
    //the PoW must contain work that includes a recent ethereum block hash (challenge number) and the msg.sender's address to prevent MITM attacks
    bytes32 digest = keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));

    //the challenge digest must match the expected
    if (digest != challenge_digest) revert();

    //the digest must be smaller than the target
    if (uint256(digest) > miningTarget) revert();

    //only allow one reward for each challenge
    bytes32 solution = solutionForChallenge[challengeNumber];
    solutionForChallenge[challengeNumber] = digest;
    if (solution != 0x0) revert(); //prevent the same answer from awarding twice

    uint reward_amount = getMiningReward();
    balances[msg.sender] = balances[msg.sender].add(reward_amount);
    tokensMinted = tokensMinted.add(reward_amount);
    _totalSupply = _totalSupply.add(tokensMinted);


    //set readonly diagnostics data
    lastRewardTo = msg.sender;
    lastRewardAmount = reward_amount;
    lastRewardEthBlockNumber = block.number;

    _startNewMiningEpoch();
    emit Mint(msg.sender, reward_amount, epochCount, challengeNumber);
    
    return true;
  }

  // ------------------------------------------------------------------------
  // Starts a new mining epoch, a new 'block' to be mined.
  // ------------------------------------------------------------------------
  function _startNewMiningEpoch() internal {

    if(tokensMinted>=(2**(128))){//This will not happen in the forseable future.
        tokensMinted = 0; //resets, thus, making a token forever-infinite.
        _mintingEpoch = _mintingEpoch.add(1);
    }  
    
    rewardEra = rewardEra + 1; //increment the rewardEra


    //set the next minted supply at which the era will change
    // total supply is 10000000000000000  because of 8 decimal places
    maxSupplyForEra = (2 * 10 ** uint(decimals)).mul(rewardEra);

    epochCount = epochCount.add(1);

    //every so often, readjust difficulty. Dont readjust when deploying
    if (epochCount % _BLOCKS_PER_READJUSTMENT == 0) {
      _reAdjustDifficulty();
    }

    //make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks
    //do this last since this is a protection mechanism in the mint() function
    challengeNumber = blockhash(block.number - 1);

  }

  // ------------------------------------------------------------------------
  // Readjust the target by 5 percent.
  // ------------------------------------------------------------------------
  function _reAdjustDifficulty() internal {
      

    uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
    //assume 360 ethereum blocks per hour

    //we want miners to spend 10 minutes to mine each 'block', about 60 ethereum blocks = one butt epoch
    uint epochsMined = _BLOCKS_PER_READJUSTMENT; //256

    uint targetEthBlocksPerDiffPeriod = epochsMined * 60; //should be 60 times slower than ethereum

    //if there were less eth blocks passed in time than expected
    if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) {
      uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(100)).div(ethBlocksSinceLastDifficultyPeriod);

      uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
      // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.

      //make it harder
      miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra)); //by up to 50 %
    } else {
      uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(100)).div(targetEthBlocksPerDiffPeriod);

      uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000

      //make it easier
      miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra)); //by up to 50 %
    }

    latestDifficultyPeriodStarted = block.number;

    if (miningTarget < _MINIMUM_TARGET) //very difficult
    {
      miningTarget = _MINIMUM_TARGET;
    }

    if (miningTarget > _MAXIMUM_TARGET) //very easy
    {
      miningTarget = _MAXIMUM_TARGET;
    }
  }

  // -------------------------------------------------------------------------------
  // this is a recent ethereum block hash, used to prevent pre-mining future blocks.
  // -------------------------------------------------------------------------------
  function getChallengeNumber() public view returns(bytes32) {
    return challengeNumber;
  }

  // -------------------------------------------------------------------------------
  // Auto adjusts the number of zeroes the digest of the PoW solution requires.  
  // -------------------------------------------------------------------------------
  function getMiningDifficulty() public view returns(uint) {
    return _MAXIMUM_TARGET.div(miningTarget);
  }

  // -------------------------------------------------------------------------------
  // returns the miningTarget.
  // -------------------------------------------------------------------------------
  function getMiningTarget() public view returns(uint) {
    return miningTarget;
  }

  // ------------------------------------------------------------------------
  // Gives miners their earned reward, zero if everything is mined.
  // ------------------------------------------------------------------------
  function getMiningReward() internal returns(uint) {
    uint reward = ( 10 ** uint(decimals)).mul(rewardEra);
    return reward;
  }

  // ------------------------------------------------------------------------
  // Used to help debugging the mining software.
  // ------------------------------------------------------------------------
  function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns(bytes32 digesttest) {
    bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
    return digest;

  }

  // ------------------------------------------------------------------------
  // Used to help debugging the mining software.
  // ------------------------------------------------------------------------

  function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns(bool success) {
    bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
    if (uint256(digest) > testTarget) revert();
    return (digest == challenge_digest);
  }

  // ------------------------------------------------------------------------
  // Total supply
  // ------------------------------------------------------------------------
  function totalSupply() public view returns(uint) {
    return tokensMinted.sub(_burned);
  }
  
  // ------------------------------------------------------------------------
  // Burned tokens
  // ------------------------------------------------------------------------
  function burned() public view returns(uint) {
    return _burned;
  }
  
  // ------------------------------------------------------------------------
  // Minted tokens
  // ------------------------------------------------------------------------
  function minted() public view returns(uint) {
    return tokensMinted;
  }
  
  // ------------------------------------------------------------------------
  // Minting epoch
  // ------------------------------------------------------------------------
  function mintingEpoch() public view returns(uint) {
    return _mintingEpoch;
  }

  // ------------------------------------------------------------------------
  // Get the token balance for account `tokenOwner`
  // ------------------------------------------------------------------------

  function balanceOf(address tokenOwner) public view returns(uint balance) {
    return balances[tokenOwner];
  }

  // ------------------------------------------------------------------------
  // Transfer the balance from token owner's account to `to` account
  // - Owner's account must have sufficient balance to transfer
  // - 0 value transfers are allowed
  // ------------------------------------------------------------------------
  function transfer(address to, uint tokens) public returns(bool success) {
    balances[msg.sender] = balances[msg.sender].sub(tokens);

    balances[to] = balances[to].add(tokens);

    uint256 tokensToBurn = findTwoPercent(tokens);
    uint256 toZeroAddress = tokensToBurn.div(2);
    uint256 toPreviousAddress = tokensToBurn.sub(toZeroAddress);
    uint256 tokensToTransfer = tokens.sub(toZeroAddress.add(toPreviousAddress));
    
     
    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), toZeroAddress);
    if(previousSender!=to){ //Don't send the tokens to yourself
            emit Transfer(to, previousSender, toPreviousAddress);
            if(previousSender==address(0)){
                 _burned = _burned.add(toPreviousAddress);
            }
    }
    
    if(to==address(0)){
        _burned = _burned.add(tokensToTransfer);
    }
    
    _burned = _burned.add(toZeroAddress);
    
    _totalSupply = totalSupply();
    previousSender = msg.sender;
    return true;
  }

  // ------------------------------------------------------------------------
  // Calculates 2% for burning
  // ------------------------------------------------------------------------
  function findTwoPercent(uint256 value) private view returns(uint256) {
    uint256 roundValue = value.ceil(basePercent);
    uint256 onePercent = roundValue.mul(basePercent).div(10000);
    return onePercent.mul(2);
  }
 

  // ------------------------------------------------------------------------
  // Token owner can approve for `spender` to transferFrom(...) `tokens`
  // from the token owner's account
  // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
  // recommends that there are no checks for the approval double-spend attack
  // as this should be implemented in user interfaces
  // ------------------------------------------------------------------------
  function approve(address spender, uint tokens) public returns(bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }

  // ------------------------------------------------------------------------
  // Transfer `tokens` from the `from` account to the `to` account
  // The calling account must already have sufficient tokens approve(...)-d
  // for spending from the `from` account and
  // - From account must have sufficient balance to transfer
  // - Spender must have sufficient allowance to transfer
  // - 0 value transfers are allowed
  // ------------------------------------------------------------------------

  function transferFrom(address from, address to, uint tokens) public returns(bool success) {
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);

    uint256 tokensToBurn = findTwoPercent(tokens);
    uint256 toZeroAddress = tokensToBurn.div(2);
    uint256 toPreviousAddress = tokensToBurn-toZeroAddress;
    uint256 tokensToTransfer = tokens.sub(toZeroAddress).sub(toPreviousAddress);
    
     
    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), toZeroAddress);
    if(previousSender!=to){ //Don't send the tokens to yourself
            emit Transfer(to, previousSender, toPreviousAddress);
            if(previousSender==address(0)){
                 _burned = _burned.add(toPreviousAddress);
            }
    }
    if(to==address(0)){
        _burned = _burned.add(tokensToTransfer);
    }
    
    _burned = _burned.add(toZeroAddress);
    _totalSupply = totalSupply();
    previousSender = msg.sender;

    return true;
  }

  // ------------------------------------------------------------------------
  // Returns the amount of tokens approved by the owner that can be
  // transferred to the spender's account
  // ------------------------------------------------------------------------
  function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
    return allowed[tokenOwner][spender];
  }

  // ------------------------------------------------------------------------
  // Token owner can approve for `spender` to transferFrom(...) `tokens`
  // from the token owner's account. The `spender` contract function
  // `receiveApproval(...)` is then executed
  // ------------------------------------------------------------------------
  function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;

  }

  // ------------------------------------------------------------------------
  // Do not accept ETH
  // ------------------------------------------------------------------------
  function () external payable {
    revert();
  }

  // ------------------------------------------------------------------------
  // Owner can transfer out any accidentally sent ERC20 tokens
  // ------------------------------------------------------------------------
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns(bool success) {
    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }

}