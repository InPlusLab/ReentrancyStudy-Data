/**

 *Submitted for verification at Etherscan.io on 2019-01-03

*/



pragma solidity ^0.5.2;



contract IsItConstantinopleYet {

    

    function isItConstantinopleYet() external view returns(bool) {

        return block.number >= 7080000 ? true : false;

    }

    

}