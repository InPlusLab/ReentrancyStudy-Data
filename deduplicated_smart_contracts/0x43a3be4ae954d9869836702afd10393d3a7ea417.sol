// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ENS.sol";
import "./OwnableMerkleTree.sol";
import "./ITornadoTrees.sol";
import "./IHasher.sol";

contract TornadoTrees is ITornadoTrees, EnsResolve {
  OwnableMerkleTree public immutable depositTree;
  OwnableMerkleTree public immutable withdrawalTree;
  IHasher public immutable hasher;
  address public immutable tornadoProxy;

  bytes32[] public deposits;
  uint256 public lastProcessedDepositLeaf;

  bytes32[] public withdrawals;
  uint256 public lastProcessedWithdrawalLeaf;

  event DepositData(address instance, bytes32 indexed hash, uint256 block, uint256 index);
  event WithdrawalData(address instance, bytes32 indexed hash, uint256 block, uint256 index);

  struct TreeLeaf {
    address instance;
    bytes32 hash;
    uint256 block;
  }

  modifier onlyTornadoProxy {
    require(msg.sender == tornadoProxy, "Not authorized");
    _;
  }

  constructor(
    bytes32 _tornadoProxy,
    bytes32 _hasher2,
    bytes32 _hasher3,
    uint32 _levels
  ) public {
    tornadoProxy = resolve(_tornadoProxy);
    hasher = IHasher(resolve(_hasher3));
    depositTree = new OwnableMerkleTree(_levels, IHasher(resolve(_hasher2)));
    withdrawalTree = new OwnableMerkleTree(_levels, IHasher(resolve(_hasher2)));
  }

  function registerDeposit(address _instance, bytes32 _commitment) external override onlyTornadoProxy {
    deposits.push(keccak256(abi.encode(_instance, _commitment, blockNumber())));
  }

  function registerWithdrawal(address _instance, bytes32 _nullifier) external override onlyTornadoProxy {
    withdrawals.push(keccak256(abi.encode(_instance, _nullifier, blockNumber())));
  }

  function updateRoots(TreeLeaf[] calldata _deposits, TreeLeaf[] calldata _withdrawals) external {
    if (_deposits.length > 0) updateDepositTree(_deposits);
    if (_withdrawals.length > 0) updateWithdrawalTree(_withdrawals);
  }

  function updateDepositTree(TreeLeaf[] calldata _deposits) public {
    bytes32[] memory leaves = new bytes32[](_deposits.length);
    uint256 offset = lastProcessedDepositLeaf;

    for (uint256 i = 0; i < _deposits.length; i++) {
      TreeLeaf memory deposit = _deposits[i];
      bytes32 leafHash = keccak256(abi.encode(deposit.instance, deposit.hash, deposit.block));
      require(deposits[offset + i] == leafHash, "Incorrect deposit");

      leaves[i] = hasher.poseidon([bytes32(uint256(deposit.instance)), deposit.hash, bytes32(deposit.block)]);
      delete deposits[offset + i];

      emit DepositData(deposit.instance, deposit.hash, deposit.block, offset + i);
    }

    lastProcessedDepositLeaf = offset + _deposits.length;
    depositTree.bulkInsert(leaves);
  }

  function updateWithdrawalTree(TreeLeaf[] calldata _withdrawals) public {
    bytes32[] memory leaves = new bytes32[](_withdrawals.length);
    uint256 offset = lastProcessedWithdrawalLeaf;

    for (uint256 i = 0; i < _withdrawals.length; i++) {
      TreeLeaf memory withdrawal = _withdrawals[i];
      bytes32 leafHash = keccak256(abi.encode(withdrawal.instance, withdrawal.hash, withdrawal.block));
      require(withdrawals[offset + i] == leafHash, "Incorrect withdrawal");

      leaves[i] = hasher.poseidon([bytes32(uint256(withdrawal.instance)), withdrawal.hash, bytes32(withdrawal.block)]);
      delete withdrawals[offset + i];

      emit WithdrawalData(withdrawal.instance, withdrawal.hash, withdrawal.block, offset + i);
    }

    lastProcessedWithdrawalLeaf = offset + _withdrawals.length;
    withdrawalTree.bulkInsert(leaves);
  }

  function validateRoots(bytes32 _depositRoot, bytes32 _withdrawalRoot) public view {
    require(depositTree.isKnownRoot(_depositRoot), "Incorrect deposit tree root");
    require(withdrawalTree.isKnownRoot(_withdrawalRoot), "Incorrect withdrawal tree root");
  }

  function depositRoot() external view returns (bytes32) {
    return depositTree.getLastRoot();
  }

  function withdrawalRoot() external view returns (bytes32) {
    return withdrawalTree.getLastRoot();
  }

  function getRegisteredDeposits() external view returns (bytes32[] memory _deposits) {
    uint256 count = deposits.length - lastProcessedDepositLeaf;
    _deposits = new bytes32[](count);
    for (uint256 i = 0; i < count; i++) {
      _deposits[i] = deposits[lastProcessedDepositLeaf + i];
    }
  }

  function getRegisteredWithdrawals() external view returns (bytes32[] memory _withdrawals) {
    uint256 count = withdrawals.length - lastProcessedWithdrawalLeaf;
    _withdrawals = new bytes32[](count);
    for (uint256 i = 0; i < count; i++) {
      _withdrawals[i] = withdrawals[lastProcessedWithdrawalLeaf + i];
    }
  }

  function blockNumber() public view virtual returns (uint256) {
    return block.number;
  }
}