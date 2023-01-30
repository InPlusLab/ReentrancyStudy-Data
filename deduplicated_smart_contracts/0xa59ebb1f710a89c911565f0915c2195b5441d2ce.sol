/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity >=0.4.0 <0.7.0;



contract SimpleWallet {
    uint storedData;
    

    function set(uint x) public {
        storedData = x;
    }

    function get() public view returns (uint) {
        return storedData;
    }
}