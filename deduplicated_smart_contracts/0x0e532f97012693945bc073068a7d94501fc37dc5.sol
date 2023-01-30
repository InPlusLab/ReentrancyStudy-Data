/**

 *Submitted for verification at Etherscan.io on 2019-05-27

*/



contract GetsBurned {



    function () payable {

    }



    function BurnMe () {

        // Selfdestruct and send eth to self, 

        selfdestruct(address(this));

    }

}