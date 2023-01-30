/**

 *Submitted for verification at Etherscan.io on 2018-12-12

*/



pragma solidity ^0.4.25;

contract etherSinkhole{

    constructor() public{}

    function destroy() public{

        selfdestruct(msg.sender);

    }

}