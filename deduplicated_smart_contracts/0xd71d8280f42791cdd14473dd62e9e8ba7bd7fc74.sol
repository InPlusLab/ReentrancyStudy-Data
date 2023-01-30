/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

pragma solidity ^0.6.1;

contract SimpleStorage {

    uint256 storedData001 = 299792456211;

    function setData001(uint256 x001) public {
        storedData001 = x001;
    }

    function getData001() public view returns (uint256) {
        return storedData001;
    }
    uint256 storedData002 = 299792456211;

    function setData002(uint256 x002) public {
        storedData002 = x002;
    }

    function getData002() public view returns (uint256) {
        return storedData002;
    }
}