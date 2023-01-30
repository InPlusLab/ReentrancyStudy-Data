/**

 *Submitted for verification at Etherscan.io on 2019-04-13

*/



// File: contracts/TestContract.sol

pragma solidity >=0.4.21 <0.6.0;

contract TestContract {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
}