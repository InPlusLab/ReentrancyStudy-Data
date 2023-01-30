/**

 *Submitted for verification at Etherscan.io on 2019-05-23

*/



pragma solidity ^0.5.0;



library Hive1 {

    function func() public { }

}



library Hive2 {

    function func() public {

        Hive1.func();

    }

}



contract Bee {

    function func() public {

        Hive2.func();

    }



    function die() public {

        selfdestruct(msg.sender);

    }

}