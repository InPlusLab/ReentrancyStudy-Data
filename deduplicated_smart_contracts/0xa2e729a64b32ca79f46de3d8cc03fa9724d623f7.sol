/**

 *Submitted for verification at Etherscan.io on 2018-11-12

*/



pragma solidity ^0.4.24;



// File: contracts/user/UserRolesAuthority.sol



contract UserRolesAuthority {

    mapping (address => bool) public whiteList;



    constructor(address[] _whitelists) public {

        for (uint i = 0; i < _whitelists.length; i ++) {

            whiteList[_whitelists[i]] = true;

        }

    }



    function canCall(

        address _src, address _dst, bytes4 _sig

    ) public view returns (bool) {

        return ( whiteList[_src] && _sig == bytes4(keccak256("addAddressToTester(address)")));

    }

}