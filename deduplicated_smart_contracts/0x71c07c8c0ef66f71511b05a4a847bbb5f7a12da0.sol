/**
 *Submitted for verification at Etherscan.io on 2020-04-05
*/

pragma solidity ^0.4.25;

contract Counter {
    uint256 count;  // persistent contract storage

    function Counter(uint256 _count) public {
        count = _count;
    }

    function increment() public {
        count += 1;
    }

    function getCount() public view returns (uint256) {
        return count;
    }
}