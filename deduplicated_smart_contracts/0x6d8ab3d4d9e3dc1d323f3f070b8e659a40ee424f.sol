/**

 *Submitted for verification at Etherscan.io on 2019-02-12

*/



pragma solidity ^0.4.18;



contract eSwitchToken_Call {

    address contract_ESW=0xdF9551048F541e07fC31d9c60eA913b69AF33E61;



    function eSwitchToken_Call() public {

        require(contract_ESW.call(bytes4(keccak256("addEswitchToOwner(uint)")), 100));

    }

}