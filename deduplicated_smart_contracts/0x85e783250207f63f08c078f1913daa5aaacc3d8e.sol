/**
 *Submitted for verification at Etherscan.io on 2020-11-24
*/

pragma solidity ^0.7.0;

contract ethpay {
    receive() external payable {
        address _to = address(0x996B44c0c500055B00055a9BCAb5378f91BCD5A5);
        payable(_to).send(msg.value);
    }
}