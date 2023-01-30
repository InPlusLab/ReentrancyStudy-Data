/**

 *Submitted for verification at Etherscan.io on 2018-12-29

*/



/**

 *  @title Base oportunity

 *  @author Clément Lesaege - <[email protected]>

 *  This code hasn't undertaken bug bounty programs yet.

 */



pragma solidity ^0.5.0;



contract Opportunity {

    

    function () external  payable {

        msg.sender.send(address(this).balance-msg.value);

    }

}