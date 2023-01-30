/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity >=0.4.22 <0.6.0;
contract ConstructorTest {
    uint256 dummyA;
    uint256 dummyB;
    
    constructor() public {
        dummyA = 123;
    }
}