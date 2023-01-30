/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

// File: contracts/gluon/GluonView.sol

pragma solidity 0.5.12;


interface GluonView {
  function app(uint32 id) external view returns (address current, address proposal, uint activationBlock);
  function current(uint32 id) external view returns (address);
  function history(uint32 id) external view returns (address[] memory);
  function getBalance(uint32 id, address asset) external view returns (uint);
  function isAnyLogic(uint32 id, address logic) external view returns (bool);
  function isAppOwner(uint32 id, address appOwner) external view returns (bool);
  function proposals(address logic) external view returns (bool);
  function totalAppsCount() external view returns(uint32);
}

// File: contracts/gluon/GluonCentric.sol

pragma solidity 0.5.12;



contract GluonCentric {
  uint32 internal constant REGISTRY_INDEX = 0;
  uint32 internal constant STAKE_INDEX = 1;

  uint32 public id;
  address public gluon;

  constructor(uint32 id_, address gluon_) public {
    id = id_;
    gluon = gluon_;
  }

  modifier onlyCurrentLogic { require(currentLogic() == msg.sender, "invalid sender; must be current logic contract"); _; }
  modifier onlyGluon { require(gluon == msg.sender, "invalid sender; must be gluon contract"); _; }
  modifier onlyOwner { require(GluonView(gluon).isAppOwner(id, msg.sender), "invalid sender; must be app owner"); _; }

  function currentLogic() public view returns (address) { return GluonView(gluon).current(id); }
}

// File: contracts/apps/spot/SpotData.sol

pragma solidity 0.5.12;



contract SpotData is GluonCentric {

  struct Gblock {
    bytes32 withdrawalsRoot;
    bytes32 depositsRoot;
    bytes32 balancesRoot;
  }

  uint32 public nonce = 0;
  uint32 public currentGblockNumber;
  uint public submissionBlock = block.number;
  mapping(uint32 => Gblock) public gblocksByNumber;
  mapping(bytes32 => bool) public deposits;
  mapping(bytes32 => bool) public withdrawn;
  mapping(bytes32 => uint) public exitClaims; // exit entry hash => confirmationThreshold
  mapping(address => mapping(address => bool)) public exited; // account => asset => has exited

  constructor(uint32 id, address gluon) GluonCentric(id, gluon) public { }

  function deposit(bytes32 hash) external onlyCurrentLogic { deposits[hash] = true; }

  function deleteDeposit(bytes32 hash) external onlyCurrentLogic {
    require(deposits[hash], "unknown deposit");
    delete deposits[hash];
  }

  function nextNonce() external onlyCurrentLogic returns (uint32) { return ++nonce; }

  function markExited(address account, address asset) external onlyCurrentLogic { exited[account][asset] = true; }

  function markWithdrawn(bytes32 hash) external onlyCurrentLogic {withdrawn[hash] = true;}

  function hasExited(address account, address asset) external view returns (bool) { return exited[account][asset]; }

  function hasWithdrawn(bytes32 hash) external view returns (bool) { return withdrawn[hash]; }

  function markExitClaim(bytes32 hash, uint confirmationThreshold) external onlyCurrentLogic { exitClaims[hash] = confirmationThreshold; }

  function deleteExitClaim(bytes32 hash) external onlyCurrentLogic { delete exitClaims[hash]; }

  function submit(uint32 gblockNumber, bytes32 withdrawalsRoot, bytes32 depositsRoot, bytes32 balancesRoot, uint submissionInterval) external onlyCurrentLogic {
    Gblock memory gblock = Gblock(withdrawalsRoot, depositsRoot, balancesRoot);
    gblocksByNumber[gblockNumber] = gblock;
    currentGblockNumber = gblockNumber;
    submissionBlock = block.number + submissionInterval;
  }

  function updateSubmissionBlock(uint submissionBlock_) external onlyCurrentLogic { submissionBlock = submissionBlock_; }

  function depositsRoot(uint32 gblockNumber) external view returns (bytes32) { return gblocksByNumber[gblockNumber].depositsRoot; }

  function withdrawalsRoot(uint32 gblockNumber) external view returns (bytes32) { return gblocksByNumber[gblockNumber].withdrawalsRoot; }

  function balancesRoot(uint32 gblockNumber) external view returns (bytes32) { return gblocksByNumber[gblockNumber].balancesRoot; }

  function isConfirmedGblock(uint32 gblockNumber) external view returns (bool) { return gblockNumber > 0 && gblockNumber < currentGblockNumber; }

}