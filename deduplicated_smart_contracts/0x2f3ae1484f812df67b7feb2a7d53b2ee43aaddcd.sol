/**

 *Submitted for verification at Etherscan.io on 2018-10-29

*/



pragma solidity ^0.4.24;



contract RINGAuthority {



    address public ringOwner;



    constructor(address _ringOwner) public {

        ringOwner = _ringOwner;

    }



    function canCall(

        address _src, address _dst, bytes4 _sig

    ) public view returns (bool) {

        return ( ringOwner == _src );

    }

}