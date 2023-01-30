/**

 *Submitted for verification at Etherscan.io on 2018-08-16

*/



contract GetsBurned {



    function () payable {

    }



    function BurnMe () {

        // Selfdestruct and send eth to self, 

        selfdestruct(address(this));

    }

}