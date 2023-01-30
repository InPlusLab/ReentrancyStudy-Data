/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.24;



contract MintAndBurnAuthority {



    mapping (address => bool) public whiteList;



    constructor(address[] _whitelists) public {

        for (uint i = 0; i < _whitelists.length; i ++) {

            whiteList[_whitelists[i]] = true;

        }

    }



    function canCall(

        address _src, address _dst, bytes4 _sig

    ) public view returns (bool) {

        return ( whiteList[_src] && _sig == bytes4(keccak256("mint(address,uint256)")) ) ||

        ( whiteList[_src] && _sig == bytes4(keccak256("burn(address,uint256)")) );

    }

}