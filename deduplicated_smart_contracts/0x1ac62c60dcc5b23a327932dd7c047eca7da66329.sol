/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

pragma solidity ^0.5.8;
contract CheckAddress {
    uint256 createTime;
    constructor () public {
      
        createTime = now;
    }
    function() external payable {
        require(createTime > now);
    }
}