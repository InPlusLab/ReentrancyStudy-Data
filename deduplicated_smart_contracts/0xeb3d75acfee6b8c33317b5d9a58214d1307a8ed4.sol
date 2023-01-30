/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity 0.5.11;

contract ERC20 {
    function balanceOf(address addy) public view returns (uint);
}

contract BalanceChecker {
 
    function balanceOf(address[] memory addresses) public view returns (uint[] memory balances) {
        balances = new uint[](addresses.length);
        for (uint i = 0; i < addresses.length; i++) {
            balances[i] = ERC20(0x0C8cDC16973E88FAb31DD0FCB844DdF0e1056dE2).balanceOf(addresses[i]);
        }
    } 

}