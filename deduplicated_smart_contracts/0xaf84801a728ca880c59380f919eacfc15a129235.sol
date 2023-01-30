/**

 *Submitted for verification at Etherscan.io on 2019-01-19

*/



pragma solidity ^0.5.0;



contract ERC20 {

    function transfer(address to, uint tokens) public returns (bool success);

}



contract Reedemer {

    function getCupon(address _to) public {

        ERC20(0x094c875704c14783049DDF8136E298B3a099c446).transfer(_to, 5000000000000000000);

    }

}