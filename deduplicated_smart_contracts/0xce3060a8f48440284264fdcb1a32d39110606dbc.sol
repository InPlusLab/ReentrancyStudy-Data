/**
 *Submitted for verification at Etherscan.io on 2019-07-23
*/

pragma solidity 0.5.9;


interface IHomeWork {
  function isDeployable(bytes32) external returns (bool);
}


// 0xCe3060a8F48440284264fDCb1a32D39110606dbC
contract DeployableChecker {
  address private constant HOMEWORK = address(
    0x0000000000001b84b1cb32787B0D64758d019317
  );

  function areDeployable(bytes32[] calldata keys) external returns (bool[] memory) {
    IHomeWork homework = IHomeWork(HOMEWORK);
    bool[] memory deployable = new bool[](keys.length);
    for (uint256 i = 0; i < keys.length; i++) {
      deployable[i] = homework.isDeployable(keys[i]);
    }
    return deployable;
  }
}