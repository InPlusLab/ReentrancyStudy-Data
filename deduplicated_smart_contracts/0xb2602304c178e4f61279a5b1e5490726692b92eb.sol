/**
 *Submitted for verification at Etherscan.io on 2019-12-03
*/

pragma solidity 0.5.12;

contract TestERC223 {
    event Log(address from, uint value, bytes data);
    
    function tokenFallback(address from, uint value, bytes memory data) public {
        emit Log(from, value, data);
    }
}