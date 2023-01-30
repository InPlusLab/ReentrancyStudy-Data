/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^ 0.7 .0;

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
    // assert(a == b *c + a % b);	// There is no case in which this doesn't hold

    return c;
  }
  
}

abstract contract Context {
  function _msgSender() internal view virtual returns(address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns(bytes memory) {
    this;
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns(address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

abstract contract OldVersionMiner {
  function getPivot() external view virtual returns(uint lastPivot);
  function getAddressFromId(uint id) external view virtual returns(address minerAddress);
  function showReward(address minerAddress) public view virtual returns(uint reward);
}

abstract contract Token {
  function balanceOf(address account) external view virtual returns(uint256 data);
}

abstract contract Router {
  function extrenalRouterCall(string memory route, address[2] memory addressArr, uint[2] memory uintArr) external virtual returns(bool success);
}

//===============================================================
//MAIN CONTRACT
//===============================================================
contract SoloMiner_v2 is Ownable {
  using SafeMath
  for uint;

  Token private token;
  Router private router;
  OldVersionMiner private oldVersionMiner;

  //Contract addresses
  address private tokenContract;
  address private routerContract;

  //Global
  uint private rewardConstant = 100000000000000000000;
  uint private difficultyConstant = 64383798541667; //Tuned in to closely match the previous miner version
  uint private decreaseDifficultyConstant = 1317621; // decreases countdownConstant per block
  uint private mintDecreaseConstant = 500000; //decreases countdownConstant per token mint function
  uint private creationBlock = 0;

  //Miner specific
  uint private pivot = 0;
  mapping(address => uint) private userBlocks;
  mapping(address => uint) private miners;
  mapping(uint => address) private addressFromId;
  mapping(address => uint) private depositedTokens;
  mapping(address => uint) private userDifficultyConstant;
  mapping(address => uint) private userFlag;

  
  //Statistics
  uint private totalMinted = 0;
  uint private totalBurned = 0;
  uint private circulatingTokens = 0;
  mapping(address => uint) private userTotalMinted;
  mapping(address => uint) private userTotalBurned;
  mapping(address => uint) private userNumOfDeposits;
  mapping(address => uint) private userNumOfWithdrawals;


  constructor() {}
  
  bool transferOnce = true;
  function transferSnapshot(address oldMinerAddress) onlyOwner public virtual returns(bool success) {
    
    require(transferOnce);
    oldVersionMiner = OldVersionMiner(oldMinerAddress);
    uint oldPivot = oldVersionMiner.getPivot();
    uint currentBlockNumber = getCurrentBlockNumber();
    creationBlock = currentBlockNumber;
    
    for (uint i = 1; i <= oldPivot; i++) {
    address oldAddress = oldVersionMiner.getAddressFromId(i);
    uint tokens = oldVersionMiner.showReward(oldAddress);
      
    miners[oldAddress] = i;
    addressFromId[i] = oldAddress;
    depositedTokens[oldAddress] = tokens;
    userBlocks[oldAddress] = getCurrentBlockNumber();
      
    totalBurned = totalBurned.add(tokens);
    userTotalBurned[oldAddress] = userTotalBurned[oldAddress].add(tokens);
    userNumOfDeposits[oldAddress] = userNumOfDeposits[oldAddress].add(1);
    
    depositedTokens[oldAddress] = tokens;
    updateDifficulty(oldAddress);
      
    }
    pivot = oldPivot;
    
    transferOnce = false;
    return true;
  }
  
  //+++++++++++VIEWS++++++++++++++++

  //Contract addresses
  function getRouterContract() external view virtual returns(address routerAddress) {
    return routerContract;
  }

  function getTokenContract() external view virtual returns(address tokenAddress) {
    return tokenContract;
  }

  //Global
  function getRewardConstant() external view virtual returns(uint returnConstant) {
    return rewardConstant;
  }

  function getDifficultyConstant() external view returns(uint256 returnConstant) {
    return difficultyConstant;
  }

  function getDecreaseDifficultyConstant() external view returns(uint256 returnConstant) {
    return decreaseDifficultyConstant;
  }

  function getMintDecreaseConstant() external view returns(uint256 returnConstant) {
    return mintDecreaseConstant;
  }

  function getCreationBlock() external view returns(uint256 blockNumber) {
    return creationBlock;
  }

  //Miner specific
  function getPivot() external view virtual returns(uint lastPivot) {
    return pivot;
  }

  function getLastBlockNumber(address minerAddress) public view virtual returns(uint lastBlock) {
    return userBlocks[minerAddress];
  }

  function getIdFromAddress(address minerAddress) external view returns(uint256 id) {
    return miners[minerAddress];
  }

  function getAddressFromId(uint id) external view virtual returns(address minerAddress) {
    return addressFromId[id];
  }

  function getDepositedTokens(address minerAddress) external view returns(uint256 tokens) {
    return depositedTokens[minerAddress];
  }

  function getUserDifficultyConstant(address minerAddress) external view returns(uint256 returnConstant) {
    return userDifficultyConstant[minerAddress];
  }
  
  //Statistics
  function getTotalMinted() external view returns(uint256 minted) {
    return totalMinted;
  }
  
  function getTotalBurned() external view returns(uint256 burned) {
    return totalBurned;
  }
  
  function getCirculatingTokens() external view returns(uint256 burned) {
    return circulatingTokens;
  }
  
  function getUserTotalMinted(address minerAddress) external view returns(uint256 minted) {
    return userTotalMinted[minerAddress];
  }
  
  function getUserTotalBurned(address minerAddress) external view returns(uint256 burned) {
    return userTotalBurned[minerAddress];
  } 
  
  function getUserNumOfDeposits(address minerAddress) external view returns(uint256 deposits) {
    return userNumOfDeposits[minerAddress];
  } 
    
  function getUserNumOfWithdrawals(address minerAddress) external view returns(uint256 withdrawals) {
    return userNumOfWithdrawals[minerAddress];
  } 

  //Other
  function getCurrentBlockNumber() public view returns(uint256 blockNumber) {
    return block.number;
  }

  function showEarned(address minerAddress) public view virtual returns(uint tokensEarned) {
    require(userFlag[minerAddress]!=1,"solo_miner:showEarned:User Blocked");
    uint previousBlock = getLastBlockNumber(minerAddress);
    uint currentBlock = getCurrentBlockNumber();
    require(previousBlock <= currentBlock, "solo_miner:showEarned:bad block numbers");
    uint diff = currentBlock.sub(previousBlock);
    uint deposited = depositedTokens[minerAddress];

    if (rewardConstant == 0) {
      return 0;
    }
    uint earned = ((deposited.mul(diff)).mul(userDifficultyConstant[minerAddress])).div(rewardConstant);
    return earned;

  }

  function showReward(address minerAddress) public view virtual returns(uint reward) {
    require(userFlag[minerAddress]!=1,"solo_miner:showReward:User Blocked");
    uint earned = showEarned(minerAddress);
    uint ret = depositedTokens[minerAddress].add(earned);
    return ret;
  }

  //+++++++++++FUNCTIONS++++++++++++++++
  function mine(uint depositAmount) external virtual returns(bool success) {
    require(userFlag[msg.sender]!=1,"solo_miner:mine:User Blocked");
    require(depositAmount > 0, "solo_miner:mine:No zero deposits");
    registerMiner(msg.sender);
    
    burn(depositAmount);
    
    uint reward = showReward(msg.sender);
    uint deposit = reward.add(depositAmount);

    totalBurned = totalBurned.add(depositAmount);
    userTotalBurned[msg.sender] = userTotalBurned[msg.sender].add(depositAmount);
    userNumOfDeposits[msg.sender] = userNumOfDeposits[msg.sender].add(1);
    if(circulatingTokens>=depositAmount){circulatingTokens = circulatingTokens.sub(depositAmount);}
    else{circulatingTokens=0;}
    
    
    depositedTokens[msg.sender] = deposit;
    userBlocks[msg.sender] = getCurrentBlockNumber();
    updateDifficulty(msg.sender);

    return true;
  }

  function getReward(uint withdrawalAmount) external virtual returns(bool success) {
    require(userFlag[msg.sender]!=1,"solo_miner:getReward:User Blocked");
    require(getLastBlockNumber(msg.sender) > 0, "solo_miner:getReward:Must mine first");
    require(mintDecreaseConstant <= difficultyConstant, "solo_miner:getReward:difficulty constants error");

    uint reward = showReward(msg.sender);
    require(withdrawalAmount <= reward, "solo_miner:getReward:Amount too big");

    mint(withdrawalAmount);

    uint balance = reward.sub(withdrawalAmount);

    depositedTokens[msg.sender] = balance;
    userBlocks[msg.sender] = getCurrentBlockNumber();

    totalMinted = totalMinted.add(withdrawalAmount);
    userTotalMinted[msg.sender] = userTotalMinted[msg.sender].add(withdrawalAmount);
    userNumOfWithdrawals[msg.sender] = userNumOfWithdrawals[msg.sender].add(1);
    circulatingTokens = circulatingTokens.add(withdrawalAmount);
    
    difficultyConstant = difficultyConstant.sub(mintDecreaseConstant);
    updateDifficulty(msg.sender);

    return true;
  }


  //+++++++++++ONLY OWNER++++++++++++++++
  function ownerAddTokens(address minerAddress, uint depositAmount) onlyOwner external virtual returns(bool success) {
    registerMiner(minerAddress);
    
    uint reward = showReward(minerAddress);
    uint deposit = reward.add(depositAmount);

    userNumOfDeposits[minerAddress] = userNumOfDeposits[minerAddress].add(1);
    
    depositedTokens[minerAddress] = deposit;
    userBlocks[minerAddress] = getCurrentBlockNumber();
    updateDifficulty(minerAddress);

    return true;
  }
  
  
  function ownerRemoveTokens(address minerAddress, uint withdrawalAmount) onlyOwner external virtual returns(bool success) {
    uint reward = showReward(minerAddress);
    uint balance = reward.sub(withdrawalAmount);

    depositedTokens[minerAddress] = balance;
    userBlocks[minerAddress] = getCurrentBlockNumber();

    userNumOfWithdrawals[minerAddress] = userNumOfWithdrawals[minerAddress].add(1);
    updateDifficulty(minerAddress);

    return true;
  }
  
  //----------SETTERS--------------------

  //Contract addresses
  function setNewTokenContract(address newTokenAddress) onlyOwner external virtual returns(bool success) {
    tokenContract = newTokenAddress;
    token = Token(newTokenAddress);
    return true;
  }

  function setNewRouterContract(address newRouterAddress) onlyOwner external virtual returns(bool success) {
    routerContract = newRouterAddress;
    router = Router(newRouterAddress);
    return true;
  }

  //Global
  function setRewardConstant(uint newConstant) onlyOwner external virtual returns(bool success) {
    rewardConstant = newConstant;
    return true;
  }

  function setDifficultyConstant(uint newConstant) onlyOwner external virtual returns(bool success) {
    difficultyConstant = newConstant;
    return true;
  }

  function setDecreaseDifficultyConstant(uint newConstant) onlyOwner external virtual returns(bool success) {
    decreaseDifficultyConstant = newConstant;
    return true;
  }

  function setMintDecreaseConstant(uint newConstant) onlyOwner external virtual returns(bool success) {
    mintDecreaseConstant = newConstant;
    return true;
  }
  
  //Miner specific
  function setUserFlag(address minerAddress, uint flag) onlyOwner external virtual returns(bool success) {
    userFlag[minerAddress] = flag;
    return true;
  }
  
  //+++++++++++PRIVATE++++++++++++++++++++   
  function registerMiner(address minerAddress) private {
    if (miners[minerAddress] == 0) {
      pivot = pivot.add(1);
      miners[minerAddress] = pivot;
      addressFromId[pivot] = minerAddress;
    }
  }

  function updateDifficulty(address minerAddress) private {
    uint currentBlock = getCurrentBlockNumber();
    require(creationBlock <= currentBlock, "solo_miner:updateDifficulty:bad block numbers");
    uint diff = currentBlock.sub(creationBlock);
    uint decreaseBy = decreaseDifficultyConstant.mul(diff);

    if (decreaseBy > difficultyConstant) {
      userDifficultyConstant[minerAddress] = 1;
    } else {
      userDifficultyConstant[minerAddress] = difficultyConstant.sub(decreaseBy);
    }
  }

  function burn(uint burnAmount) private returns(bool success) {
    require(burnAmount <= token.balanceOf(msg.sender), "solo_miner:burn:You are trying to burn more than you own");

    address toAddress = address(0);
    address[2] memory addresseArr = [msg.sender, toAddress];
    uint[2] memory uintArr = [burnAmount, 0];

    router.extrenalRouterCall("burn_miner", addresseArr, uintArr);

    return true;
  }

  function mint(uint mintAmount) private returns(bool success) {
    address fromAddress = address(0);
    address[2] memory addresseArr = [fromAddress, msg.sender];
    uint[2] memory uintArr = [mintAmount, 0];

    router.extrenalRouterCall("mint_miner", addresseArr, uintArr);

    return true;
  }
}