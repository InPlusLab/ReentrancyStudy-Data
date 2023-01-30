/**

 *Submitted for verification at Etherscan.io on 2018-12-04

*/



pragma solidity 0.4.25;



contract ErrorReporter {

    function revertTx(string reason) public pure {

        revert(reason);

    }

}