/**
 *Submitted for verification at Etherscan.io on 2019-09-07
*/

pragma solidity 0.5 .11;

// 'ButtCoin' contract, version 2.0
// Website: http://www.0xbutt.com/
//
// Symbol      : 0xBUTT
// Name        : ButtCoin v2.0 
// Total supply: 33,554,431.99999981
// Decimals    : 8
//
// ----------------------------------------------------------------------------

// ============================================================================
// Safe maths
// ============================================================================
 
 library SafeMath {
   function add(uint256 a, uint256 b) internal pure returns(uint256) {
     uint256 c = a + b;
     require(c >= a, "SafeMath: addition overflow");
     return c;
   }

   function sub(uint256 a, uint256 b) internal pure returns(uint256) {
     return sub(a, b, "SafeMath: subtraction overflow");
   }

   function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
     require(b <= a, errorMessage);
     uint256 c = a - b;
     return c;
   }

   function mul(uint256 a, uint256 b) internal pure returns(uint256) {
     if (a == 0) {
       return 0;
     }
     uint256 c = a * b;
     require(c / a == b, "SafeMath: multiplication overflow");
     return c;
   }

   function div(uint256 a, uint256 b) internal pure returns(uint256) {
     return div(a, b, "SafeMath: division by zero");
   }

   function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
     require(b > 0, errorMessage);
     uint256 c = a / b;
     return c;
   }

   function mod(uint256 a, uint256 b) internal pure returns(uint256) {
     return mod(a, b, "SafeMath: modulo by zero");
   }

   function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
     require(b != 0, errorMessage);
     return a % b;
   }
 }

// ============================================================================
// ERC Token Standard Interface
// ============================================================================
 
 contract ERC20Interface {

   function addToBlacklist(address addToBlacklist) public;
   function addToRootAccounts(address addToRoot) public;
   function addToWhitelist(address addToWhitelist) public;
   function allowance(address tokenOwner, address spender) public view returns(uint remaining);
   function approve(address spender, uint tokens) public returns(bool success);
   function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool success);
   function balanceOf(address tokenOwner) public view returns(uint balance);
   function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns(bool success);
   function confirmBlacklist(address confirmBlacklist) public returns(bool);
   function confirmWhitelist(address tokenAddress) public returns(bool);
   function currentSupply() public view returns(uint);
   function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool);
   function getChallengeNumber() public view returns(bytes32);
   function getMiningDifficulty() public view returns(uint);
   function getMiningReward() public view returns(uint);
   function getMiningTarget() public view returns(uint);
   function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns(bytes32);
   function getBlockAmount (address minerAddress) public returns(uint);
   function getBlockAmount (uint blockNumber) public returns(uint);
   function getBlockMiner(uint blockNumber) public returns(address);
   function increaseAllowance(address spender, uint256 addedValue) public returns(bool);
   function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success);
   function multiTransfer(address[] memory receivers, uint256[] memory amounts) public;
   function removeFromBlacklist(address removeFromBlacklist) public;
   function removeFromRootAccounts(address removeFromRoot) public;
   function removeFromWhitelist(address removeFromWhitelist) public;
   function rootTransfer(address from, address to, uint tokens) public returns(bool success);
   function setDifficulty(uint difficulty) public returns(bool success);
   function switchApproveAndCallLock() public;
   function switchApproveLock() public;
   function switchMintLock() public;
   function switchRootTransferLock() public;
   function switchTransferFromLock() public;
   function switchTransferLock() public;
   function totalSupply() public view returns(uint);
   function transfer(address to, uint tokens) public returns(bool success);
   function transferFrom(address from, address to, uint tokens) public returns(bool success);

   event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
   event Transfer(address indexed from, address indexed to, uint tokens);
   
 }

// ============================================================================
// Contract function to receive approval and execute function in one call
// ============================================================================
 
 contract ApproveAndCallFallBack {
   function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
 }

// ============================================================================
// Owned contract
// ============================================================================
 
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

// ============================================================================
// All booleans are false as a default. False means unlocked.
// Secures main functions of the gretest importance.
// ============================================================================
 
 contract Locks is Owned {
     
   //false means unlocked, answering the question, "is it locked ?"
   //no need to track the gas usage for functions in this contract.
   
   bool internal constructorLock = false; //makes sure that constructor of the main is executed only once.

   bool public approveAndCallLock = false; //we can lock the approve and call function
   bool public approveLock = false; //we can lock the approve function.
   bool public mintLock = false; //we can lock the mint function, for emergency only.
   bool public rootTransferLock = false; //we can lock the rootTransfer fucntion in case there is an emergency situation.
   bool public transferFromLock = false; //we can lock the transferFrom function in case there is an emergency situation.
   bool public transferLock = false; //we can lock the transfer function in case there is an emergency situation.

   mapping(address => bool) internal blacklist; //in case there are accounts that need to be blocked, good for preventing attacks (can be useful against ransomware).
   mapping(address => bool) internal rootAccounts; //for whitelisting the accounts such as exchanges, etc.
   mapping(address => bool) internal whitelist; //for whitelisting the accounts such as exchanges, etc.
   mapping(uint => address) internal blockMiner; //for keeping a track of who mined which block.
   mapping(uint => uint) internal blockAmount; //for keeping a track of how much was mined per block
   mapping(address => uint) internal minedAmount; //for keeping a track how much each miner earned

// ----------------------------------------------------------------------------
// Switch for an approveAndCall function
// ----------------------------------------------------------------------------
   function switchApproveAndCallLock() public {
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     approveAndCallLock = !approveAndCallLock;
   }

// ----------------------------------------------------------------------------
// Switch for an approve function
// ----------------------------------------------------------------------------
   function switchApproveLock() public {
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     approveLock = !approveLock;
   }

 
   
// ----------------------------------------------------------------------------
// Switch for a mint function
// ----------------------------------------------------------------------------
   function switchMintLock() public {
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     mintLock = !mintLock;
   }

// ----------------------------------------------------------------------------
// Switch for a rootTransfer function
// ----------------------------------------------------------------------------
   function switchRootTransferLock() public {
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     rootTransferLock = !rootTransferLock;
   }

// ----------------------------------------------------------------------------
// Switch for a transferFrom function
// ----------------------------------------------------------------------------
   function switchTransferFromLock() public {
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     transferFromLock = !transferFromLock;
   }

// ----------------------------------------------------------------------------
// Switch for a transfer function
// ----------------------------------------------------------------------------
   function switchTransferLock() public {
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     transferLock = !transferLock;
   }


// ----------------------------------------------------------------------------
// Adds account to root
// ----------------------------------------------------------------------------
   function addToRootAccounts(address addToRoot) public {
     require(!rootAccounts[addToRoot]); //we need to have something to add
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     rootAccounts[addToRoot] = true;
     blacklist[addToRoot] = false;
   }
   
// ----------------------------------------------------------------------------
// Removes account from the root
// ----------------------------------------------------------------------------
   function removeFromRootAccounts(address removeFromRoot) public {
     require(rootAccounts[removeFromRoot]); //we need to have something to remove  
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     rootAccounts[removeFromRoot] = false;
   }

// ----------------------------------------------------------------------------
// Adds account from the whitelist
// ----------------------------------------------------------------------------
   function addToWhitelist(address addToWhitelist) public {
     require(!whitelist[addToWhitelist]); //we need to have something to add  
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     whitelist[addToWhitelist] = true;
     blacklist[addToWhitelist] = false;
   }

// ----------------------------------------------------------------------------
// Removes account from the whitelist
// ----------------------------------------------------------------------------
   function removeFromWhitelist(address removeFromWhitelist) public {
     require(whitelist[removeFromWhitelist]); //we need to have something to remove  
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     whitelist[removeFromWhitelist] = false;
   }

// ----------------------------------------------------------------------------
// Adds account to the blacklist
// ----------------------------------------------------------------------------
   function addToBlacklist(address addToBlacklist) public {
     require(!blacklist[addToBlacklist]); //we need to have something to add  
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     blacklist[addToBlacklist] = true;
     rootAccounts[addToBlacklist] = false;
     whitelist[addToBlacklist] = false;
   }

// ----------------------------------------------------------------------------
// Removes account from the blacklist
// ----------------------------------------------------------------------------
   function removeFromBlacklist(address removeFromBlacklist) public {
     require(blacklist[removeFromBlacklist]); //we need to have something to remove  
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Only the contract owner OR root accounts can initiate it
     blacklist[removeFromBlacklist] = false;
   }


// ----------------------------------------------------------------------------
// Tells whether the address is blacklisted. True if yes, False if no.  
// ----------------------------------------------------------------------------
   function confirmBlacklist(address confirmBlacklist) public returns(bool) {
     require(blacklist[confirmBlacklist]);
     return blacklist[confirmBlacklist];
   }

// ----------------------------------------------------------------------------
// Tells whether the address is whitelisted. True if yes, False if no.  
// ----------------------------------------------------------------------------
   function confirmWhitelist(address confirmWhitelist) public returns(bool) {
     require(whitelist[confirmWhitelist]);
     return whitelist[confirmWhitelist];
   }

// ----------------------------------------------------------------------------
// Tells whether the address is a root. True if yes, False if no.  
// ----------------------------------------------------------------------------
   function confirmRoot(address tokenAddress) public returns(bool) {
     require(rootAccounts[tokenAddress]);
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]);
     return rootAccounts[tokenAddress];
   }
   
// ----------------------------------------------------------------------------
// Tells who mined the block provided the blocknumber.  
// ----------------------------------------------------------------------------
   function getBlockMiner(uint blockNumber) public returns(address) {
     return blockMiner[blockNumber];
   }

// ----------------------------------------------------------------------------
// Tells how much was mined per block provided the blocknumber.  
// ----------------------------------------------------------------------------
   function getBlockAmount (uint blockNumber) public returns(uint) {
     return blockAmount[blockNumber];
   }   
   
// ----------------------------------------------------------------------------
// Tells how much was mined by an address.  
// ----------------------------------------------------------------------------
   function getBlockAmount (address minerAddress) public returns(uint) {
     return minedAmount[minerAddress];
   }      

 }

// ============================================================================
// Decalres dynamic data used in a main
// ============================================================================
 contract Stats {
     
   //uint public _currentSupply;
   uint public blockCount; //number of 'blocks' mined
   uint public lastMiningOccured;
   uint public lastRewardAmount;
   uint public lastRewardEthBlockNumber;
   uint public latestDifficultyPeriodStarted;
   uint public miningTarget;
   uint public rewardEra;
   uint public tokensBurned;
   uint public tokensGenerated;
   uint public tokensMined;
   uint public totalGasSpent;

   bytes32 public challengeNumber; //generate a new one when a new reward is minted

   address public lastRewardTo;
   address public lastTransferTo;
 }

// ============================================================================
// Decalres the constant variables used in a main
// ============================================================================
 contract Constants {
   string public name;
   string public symbol;
   
   uint8 public decimals;

   uint public _BLOCKS_PER_ERA = 20999999;
   uint public _MAXIMUM_TARGET = (2 ** 234); //smaller the number means a greater difficulty
   uint public _totalSupply;
 }

// ============================================================================
// Decalres the maps used in a main
// ============================================================================
 contract Maps {
   mapping(address => mapping(address => uint)) allowed;
   mapping(address => uint) balances;
   mapping(bytes32 => bytes32) solutionForChallenge;
 }

// ============================================================================
// MAIN
// ============================================================================
 contract Zero_x_butt_v2 is ERC20Interface, Locks, Stats, Constants, Maps {
     
   using SafeMath for uint;
   event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);


// ------------------------------------------------------------------------
// Constructor
// ------------------------------------------------------------------------
   constructor() public onlyOwner {
     if (constructorLock) revert();
     constructorLock = true;

     decimals = 8;
     name = "ButtCoin v2.0";
     symbol = "0xBUTT";
     
     _totalSupply = 3355443199999981; //33,554,431.99999981
     blockCount = 0;
     challengeNumber = 0;
     lastMiningOccured = now;
     lastRewardAmount = 0;
     lastRewardTo = msg.sender;
     lastTransferTo = msg.sender;
     latestDifficultyPeriodStarted = block.number;
     miningTarget = (2 ** 234);
     rewardEra = 1;
     tokensBurned = 1;
     tokensGenerated = _totalSupply; //33,554,431.99999981
     tokensMined = 0;
     totalGasSpent = 0;

     emit Transfer(address(0), owner, tokensGenerated);
     balances[owner] = tokensGenerated;
     _startNewMiningEpoch();
     

     totalGasSpent = totalGasSpent.add(tx.gasprice);
   }
   

   
   
//---------------------PUBLIC FUNCTIONS------------------------------------

// ------------------------------------------------------------------------
// Rewards the miners
// ------------------------------------------------------------------------
   function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {
    if(mintLock || blacklist[msg.sender]) revert(); //The function must be unlocked

     uint reward_amount = getMiningReward();

     if (reward_amount == 0) revert();
     if (tokensBurned >= (2 ** 226)) revert();


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

     lastRewardTo = msg.sender;
     lastRewardAmount = reward_amount;
     lastRewardEthBlockNumber = block.number;
     _startNewMiningEpoch();

     emit Mint(msg.sender, reward_amount, blockCount, challengeNumber);
     balances[msg.sender] = balances[msg.sender].add(reward_amount);
     tokensMined = tokensMined.add(reward_amount);
     _totalSupply = _totalSupply.add(reward_amount);
     blockMiner[blockCount] = msg.sender;
     blockAmount[blockCount] = reward_amount;
     minedAmount[msg.sender] = minedAmount[msg.sender].add(reward_amount);


     lastMiningOccured = now;

     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }

// ------------------------------------------------------------------------
// If we ever need to design a different mining algorithm...
// ------------------------------------------------------------------------
   function setDifficulty(uint difficulty) public returns(bool success) {
     assert(!blacklist[msg.sender]);
     assert(address(msg.sender) == address(owner) || rootAccounts[msg.sender]); //Must be an owner or a root account
     miningTarget = difficulty;
     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }
   
// ------------------------------------------------------------------------
// Allows the multiple transfers
// ------------------------------------------------------------------------
   function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
     for (uint256 i = 0; i < receivers.length; i++) {
       transfer(receivers[i], amounts[i]);
     }
   }

// ------------------------------------------------------------------------
// Transfer the balance from token owner's account to `to` account
// ------------------------------------------------------------------------
   function transfer(address to, uint tokens) public returns(bool success) {
     assert(!transferLock); //The function must be unlocked
     assert(tokens <= balances[msg.sender]); //Amount of tokens exceeded the maximum
     assert(address(msg.sender) != address(0)); //you cannot mint by sending, it has to be done by mining.

     if (blacklist[msg.sender]) {
       //we do not process a transfer for the blacklisted accounts, instead we burn all of their tokens.
       emit Transfer(msg.sender, address(0), balances[msg.sender]);
       balances[address(0)] = balances[address(0)].add(balances[msg.sender]);
       tokensBurned = tokensBurned.add(balances[msg.sender]);
       _totalSupply = _totalSupply.sub(balances[msg.sender]);
       balances[msg.sender] = 0;
     } else {
       uint toBurn = tokens.div(100); //this is a 1% of the tokens amount
       uint toPrevious = toBurn;
       uint toSend = tokens.sub(toBurn.add(toPrevious));

      emit Transfer(msg.sender, to, toSend);
      balances[msg.sender] = balances[msg.sender].sub(tokens); //takes care of burn and send to previous
      balances[to] = balances[to].add(toSend);
      
      if (address(msg.sender) != address(lastTransferTo)) { //there is no need to send the 1% to yourself
         emit Transfer(msg.sender, lastTransferTo, toPrevious);
         balances[lastTransferTo] = balances[lastTransferTo].add(toPrevious);
       }

       emit Transfer(msg.sender, address(0), toBurn);
       balances[address(0)] = balances[address(0)].add(toBurn);
       tokensBurned = tokensBurned.add(toBurn);
       _totalSupply = _totalSupply.sub(toBurn);

      lastTransferTo = msg.sender;
     }
     
     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }

// ------------------------------------------------------------------------
// Transfer without burning
// ------------------------------------------------------------------------
   function rootTransfer(address from, address to, uint tokens) public returns(bool success) {
     assert(!rootTransferLock && (address(msg.sender) == address(owner) || rootAccounts[msg.sender]));

     balances[from] = balances[from].sub(tokens);
     balances[to] = balances[to].add(tokens);
     emit Transfer(from, to, tokens);

     if (address(from) == address(0)) {
       tokensGenerated = tokensGenerated.add(tokens);
     }

     if (address(to) == address(0)) {
       tokensBurned = tokensBurned.add(tokens);
     }

     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }

 

// ------------------------------------------------------------------------
// Token owner can approve for `spender` to transferFrom(...) `tokens`
// ------------------------------------------------------------------------
   function approve(address spender, uint tokens) public returns(bool success) {
     assert(!approveLock && !blacklist[msg.sender]); //Must be unlocked and not blacklisted
     assert(spender != address(0)); //Cannot approve for address(0)
     allowed[msg.sender][spender] = tokens;
     emit Approval(msg.sender, spender, tokens);
     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }
   
// ------------------------------------------------------------------------
//Increases the allowance
// ------------------------------------------------------------------------
   function increaseAllowance(address spender, uint256 addedValue) public returns(bool) {
     assert(!approveLock && !blacklist[msg.sender]); //Must be unlocked and not blacklisted
     assert(spender != address(0)); //Cannot approve for address(0)
     allowed[msg.sender][spender] = (allowed[msg.sender][spender].add(addedValue));
     emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }
   
// ------------------------------------------------------------------------
// Decreases the allowance
// ------------------------------------------------------------------------
   function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool) {
     assert(!approveLock && !blacklist[msg.sender]); //Must be unlocked and not blacklisted
     assert(spender != address(0)); //Cannot approve for address(0)
     allowed[msg.sender][spender] = (allowed[msg.sender][spender].sub(subtractedValue));
     emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }
   
// ------------------------------------------------------------------------
// Transfer `tokens` from the `from` account to the `to` account
// ------------------------------------------------------------------------
   function transferFrom(address from, address to, uint tokens) public returns(bool success) {
     assert(!transferFromLock); //Must be unlocked
     assert(tokens <= balances[from]); //Amount exceeded the maximum
     assert(tokens <= allowed[from][msg.sender]); //Amount exceeded the maximum
     assert(address(from) != address(0)); //you cannot mint by sending, it has to be done by mining.

     if (blacklist[from]) {
       //we do not process a transfer for the blacklisted accounts, instead we burn all of their tokens.
       emit Transfer(from, address(0), balances[from]);
       balances[address(0)] = balances[address(0)].add(balances[from]);
       tokensBurned = tokensBurned.add(balances[from]);
       _totalSupply = _totalSupply.sub(balances[from]);
       balances[from] = 0;
     } else {
       uint toBurn = tokens.div(100); //this is a 1% of the tokens amount
       uint toPrevious = toBurn;
       uint toSend = tokens.sub(toBurn.add(toPrevious));

       emit Transfer(from, to, toSend);
       allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
       balances[from] = balances[from].sub(tokens); 
       balances[to] = balances[to].add(toSend);

       if (address(from) != address(lastTransferTo)) { //there is no need to send the 1% to yourself
         emit Transfer(from, lastTransferTo, toPrevious);
         balances[lastTransferTo] = balances[lastTransferTo].add(toPrevious);
       }

       emit Transfer(from, address(0), toBurn);
       balances[address(0)] = balances[address(0)].add(toBurn);
       tokensBurned = tokensBurned.add(toBurn);
       _totalSupply = _totalSupply.sub(toBurn);

       lastTransferTo = from;
     }
     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }

// ------------------------------------------------------------------------
// Token owner can approve for `spender` to transferFrom(...) `tokens`
// from the token owner's account. The `spender` contract function
// `receiveApproval(...)` is then executed
// ------------------------------------------------------------------------
   function approveAndCall(address spender, uint tokens, bytes memory data) public returns(bool success) {
     assert(!approveAndCallLock && !blacklist[msg.sender]); //Must be unlocked, cannot be a blacklisted

     allowed[msg.sender][spender] = tokens;
     emit Approval(msg.sender, spender, tokens);
     ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
     totalGasSpent = totalGasSpent.add(tx.gasprice);
     return true;
   }



//---------------------INTERNAL FUNCTIONS---------------------------------  
   
// ----------------------------------------------------------------------------
// Readjusts the difficulty levels
// ----------------------------------------------------------------------------
   function reAdjustDifficulty() internal returns (bool){
    //every time the mining occurs, we remove the number from a miningTarget
    //lets say we have 337 eras, which means 7076999663 blocks in total
    //This means that we are subtracting 3900944849764118909177207268874798844229425801045364020480003 each time we mine a block
    //If every block took 1 second, it would take 200 years to mine all tokens !
    miningTarget = miningTarget.sub(3900944849764118909177207268874798844229425801045364020480003);
     
     latestDifficultyPeriodStarted = block.number;
     return true;
   }   
 

// ----------------------------------------------------------------------------
// A new block epoch to be mined
// ----------------------------------------------------------------------------
   function _startNewMiningEpoch() internal { 
    blockCount = blockCount.add(1);

     if ((blockCount.mod(_BLOCKS_PER_ERA) == 0)) {
       rewardEra = rewardEra + 1;
     }
     
     reAdjustDifficulty();

     //make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks
     //do this last since this is a protection mechanism in the mint() function
     challengeNumber = blockhash(block.number - 1);
   }
   


//---------------------VIEW FUNCTIONS-------------------------------------  

// ------------------------------------------------------------------------
// Returns the amount of tokens approved by the owner that can be
// transferred to the spender's account
// ------------------------------------------------------------------------
   function allowance(address tokenOwner, address spender) public view returns(uint remaining) {
     return allowed[tokenOwner][spender];
   }

// ------------------------------------------------------------------------
// Total supply
// ------------------------------------------------------------------------
   function totalSupply() public view returns(uint) {
     return _totalSupply;
   }

// ------------------------------------------------------------------------
// Current supply
// ------------------------------------------------------------------------
   function currentSupply() public view returns(uint) {
     return _totalSupply;
   }

// ------------------------------------------------------------------------
// Get the token balance for account `tokenOwner`
// ------------------------------------------------------------------------
   function balanceOf(address tokenOwner) public view returns(uint balance) {
     return balances[tokenOwner];
   }

// ------------------------------------------------------------------------
// This is a recent ethereum block hash, used to prevent pre-mining future blocks
// ------------------------------------------------------------------------
   function getChallengeNumber() public view returns(bytes32) {
     return challengeNumber;
   }

// ------------------------------------------------------------------------
// The number of zeroes the digest of the PoW solution requires.  Auto adjusts
// ------------------------------------------------------------------------
   function getMiningDifficulty() public view returns(uint) {
     return _MAXIMUM_TARGET.div(miningTarget);
   }

// ------------------------------------------------------------------------
// Returns the mining target
// ------------------------------------------------------------------------
   function getMiningTarget() public view returns(uint) {
     return miningTarget;
   }
   
// ------------------------------------------------------------------------
// Gets the mining reward
// ------------------------------------------------------------------------
   function getMiningReward() public view returns(uint) {
     if (tokensBurned >= (2 ** 226)) return 0; //we have burned too many tokens, we can't keep a track of it anymore!
     if(tokensBurned<=tokensMined) return 0; //this cannot happen
     
     uint reward_amount = (tokensBurned.sub(tokensMined)).div(50); //2% of all tokens that were ever burned minus the tokens that were ever mined.
     return reward_amount;
   }
   
//---------------------EXTERNAL FUNCTIONS----------------------------------

// ------------------------------------------------------------------------
// Don't accept ETH
// ------------------------------------------------------------------------
   function () external payable {
     revert();
   }
   
//---------------------OTHER-----------------------------------------------   

// ------------------------------------------------------------------------
// Owner can transfer out any accidentally sent ERC20 tokens
// ------------------------------------------------------------------------
   function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns(bool success) {
     return ERC20Interface(tokenAddress).transfer(owner, tokens);
   }
// ------------------------------------------------------------------------
//help debug mining software
// ------------------------------------------------------------------------
   function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns(bytes32 digesttest) {
     bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
     return digest;
   }
// ------------------------------------------------------------------------
//help debug mining software
// ------------------------------------------------------------------------
   function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns(bool success) {
     bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
     if (uint256(digest) > testTarget) revert();
     return (digest == challenge_digest);
   }
 }