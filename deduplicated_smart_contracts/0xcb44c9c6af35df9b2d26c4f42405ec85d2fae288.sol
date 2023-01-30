/**

 *Submitted for verification at Etherscan.io on 2019-02-20

*/



pragma solidity ^0.5.4;





contract Test3{

    function getDifficulty() view public returns(uint){

        return block.difficulty;

    }

}