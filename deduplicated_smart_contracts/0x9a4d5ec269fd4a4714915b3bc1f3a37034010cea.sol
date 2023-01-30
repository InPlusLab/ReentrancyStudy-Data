/**
 *Submitted for verification at Etherscan.io on 2019-07-23
*/

pragma solidity >0.4.99 <0.6.0;

contract PostLike {
  mapping(uint256 => uint256) public postLikeCount;
}

contract GetMultiPostLikeCount {
  PostLike postLikeContract = PostLike(0x2E8c1E33e82E2A5b93076f32Aa5EFE3dFaAa1676);
  function Get(uint256[] memory postIdxList) public view returns (uint256[] memory counts) {
    uint256[] memory results = new uint256[](postIdxList.length);
    for (uint256 i = 0; i < results.length; i++) {
        results[i] = postLikeContract.postLikeCount(postIdxList[i]);
    }
    return results;
  }
}