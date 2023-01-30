/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity >0.4.99 <0.6.0;

contract PostLike {
  mapping(uint256 => uint256) public postLikeCount;
  mapping(address => mapping(uint256 => bool)) public liked;
}

contract GetPostLike {
  PostLike postLikeContract = PostLike(0x2E8c1E33e82E2A5b93076f32Aa5EFE3dFaAa1676);
  function get(uint256[] memory postIdxList, address user) public view returns (uint256[] memory) {
    uint256[] memory results = new uint256[](postIdxList.length * 2);
    for (uint256 i = 0; i < postIdxList.length; i++) {
        results[i] = postLikeContract.postLikeCount(postIdxList[i]);
        results[i + postIdxList.length] = postLikeContract.liked(user, postIdxList[i]) ? 1 : 0;
    }
    return results;
  }
}