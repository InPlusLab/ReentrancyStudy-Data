/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^ 0.5 .1;

// ----------------------------------------------------------------------------
//'ButtCoin' contract, version 2.1
// See: https://github.com/butttcoin/0xBUTT
// Symbol      : 0xBUTT
// Name        : ButtCoin
// Total supply: Dynamic
// Decimals    : 8
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
  function ceil(uint a, uint m) internal pure returns(uint) {
    uint c = add(a, m);
    uint d = sub(c, 1);
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

contract ZERO_X_BUTTv3 is ERC20Interface, Owned {

  using SafeMath for uint;
  using ExtendedMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint256 public _totalSupply;
  uint256 public _burned;

  //a big number is easier ; just find a solution that is smaller
  uint private n = 212; //the maxiumum target exponent
  uint private nFutureTime = now + 1097 days; // about 3 years in future
  
  uint public _MAXIMUM_TARGET = 2 ** n;

  bytes32 public challengeNumber; //generate a new one when a new reward is minted

  uint public rewardEra;

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

  uint private miningTarget;
  uint private _mintingEpoch;

  event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

  // ------------------------------------------------------------------------
  // Constructor
  // ------------------------------------------------------------------------

  constructor() public {
    if (locked) revert();

    symbol = "0xBUTT";
    name = "ButtCoin";
    decimals = 8;
    basePercent = 100;

    uint toMint = 33554432 * 10 ** uint(decimals); //This is an assumption and a kick-start, which resets when 75% is burned.
    _mint(msg.sender, toMint);

    tokensMinted = toMint;
    _totalSupply = _totalSupply.add(toMint);
    rewardEra = 22;
    miningTarget = _MAXIMUM_TARGET;
    _startNewMiningEpoch();

    _mintingEpoch = 0;

    locked = true;
  }

  // ------------------------------------------------------------------------
  // Minting tokens before the mining.
  // ------------------------------------------------------------------------
  function _mint(address account, uint256 amount) internal {
    if (locked) revert();
    require(amount != 0);
    balances[account] = balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  // ------------------------------------------------------------------------
  // Minting of tokens during the mining.
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
    emit Mint(msg.sender, reward_amount, rewardEra, challengeNumber);

    return true;
  }

  // ------------------------------------------------------------------------
  // Starts a new mining epoch, a new 'block' to be mined.
  // ------------------------------------------------------------------------
  function _startNewMiningEpoch() internal {
    rewardEra = rewardEra + 1; //increment the rewardEra
    checkMintedNumber();
    _reAdjustDifficulty();
    challengeNumber = blockhash(block.number - 1);
  }

  //checks if the minted number is too high, reduces a tracking number if it is
  function checkMintedNumber() internal {
    if (tokensMinted >= (2 ** (230))) { //This will not happen in the forseable future.
        
        //50 is neither too low or too high, we'd need additional tracking to get overall totals after this.
        tokensMinted = tokensMinted.div(2 ** (50));
        _burned = _burned.div(2 ** (50));
         
      _mintingEpoch = _mintingEpoch + 1;
    }
  }

  // ------------------------------------------------------------------------
  // Readjust difficulty
  // ------------------------------------------------------------------------
  function _reAdjustDifficulty() internal {
    n = n - 1;
    miningTarget = (2 ** n);
    nFutureTime = now + 1097 days;
    
    //if difficulty level became too much for the miners and coins are running out of a supply, we need to lower a difficulty to mint new coins...
    //this way, the coin does not become store of a value. Nevertheless, it may be required for the miners to do some extra work to lower a difficulty.
    uint treshold = (tokensMinted.mul(95)).div(100);
    if(_burned>=treshold){
        //lower difficulty to significant levels
        n = (n.mul(105)).div(100);
        if(n > 213){n = 213;}
        miningTarget = (2 ** n);
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
    uint reward = ((234 - n) ** 3) * 10 ** uint(decimals);
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


  function pulseCheck() internal{
   //if either the coin is dead or the mining is stuck  
    if(nFutureTime<=now){
      n = (n.mul(150)).div(100); 
      miningTarget = (2 ** n);
      _startNewMiningEpoch();
    }  
      
  }

  // ------------------------------------------------------------------------
  // Transfer the balance from token owner's account to `to` account
  // - Owner's account must have sufficient balance to transfer
  // - 0 value transfers are allowed
  // ------------------------------------------------------------------------
 

  //Otherwise, it is a bug
  function sendTo(address to, uint tokens) public returns(bool success) {
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
  }
 

  function transfer(address to, uint tokens) public returns(bool success) {
      
    pulseCheck(); 

    balances[msg.sender] = balances[msg.sender].sub(tokens);

    balances[to] = balances[to].add(tokens);

    uint256 tokensToBurn = findTwoPercent(tokens);
    uint256 toZeroAddress = tokensToBurn.div(2);
    uint256 toPreviousAddress = tokensToBurn.sub(toZeroAddress);
    uint256 tokensToTransfer = tokens.sub(toZeroAddress.add(toPreviousAddress));

     sendTo(msg.sender, to, tokensToTransfer);
     sendTo(msg.sender, address(0), toZeroAddress);
    if (previousSender != to) { //Don't send the tokens to yourself
     sendTo(to, previousSender, toPreviousAddress);
      if (previousSender == address(0)) {
        _burned = _burned.add(toPreviousAddress);
      }
    }

    if (to == address(0)) {
      _burned = _burned.add(tokensToTransfer);
    }

    _burned = _burned.add(toZeroAddress);

    _totalSupply = totalSupply();
    previousSender = msg.sender;
    return true;
  }

  // ------------------------------------------------------------------------
  // Transfers to multiple accounts
  // ------------------------------------------------------------------------
  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
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

  //otherwise, it is a bug
    function sendTo(address from, address to, uint tokens) public returns(bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

  function transferFrom(address from, address to, uint tokens) public returns(bool success) {
    
    pulseCheck();
    
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);

    uint256 tokensToBurn = findTwoPercent(tokens);
    uint256 toZeroAddress = tokensToBurn.div(2);
    uint256 toPreviousAddress = tokensToBurn - toZeroAddress;
    uint256 tokensToTransfer = tokens.sub(toZeroAddress).sub(toPreviousAddress);

    sendTo(msg.sender, to, tokensToTransfer);
    sendTo(msg.sender, address(0), toZeroAddress);
    if (previousSender != to) { //Don't send tokens to yourself
      sendTo(to, previousSender, toPreviousAddress);
      if (previousSender == address(0)) {
        _burned = _burned.add(toPreviousAddress);
      }
    }
    if (to == address(0)) {
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