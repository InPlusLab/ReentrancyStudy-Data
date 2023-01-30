/**

 *Submitted for verification at Etherscan.io on 2018-09-03

*/



pragma solidity 0.4.24;

pragma experimental "v0.5.0";

/******************************************************************************\

* Author: Nick Mudge, [email protected]

* Mokens

* Copyright (c) 2018

*

* Implements ERC165 Standard Interface Detection

/******************************************************************************/

///////////////////////////////////////////////////////////////////////////////////

//Storage contracts

////////////

//Some delegate contracts are listed with storage contracts they inherit.

///////////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////////

//Mokens

///////////////////////////////////////////////////////////////////////////////////

contract Storage0 {

    // funcId => delegate contract

    mapping(bytes4 => address) internal delegates;

}

///////////////////////////////////////////////////////////////////////////////////

//MokenUpdates

//MokenOwner

//QueryMokenDelegates

///////////////////////////////////////////////////////////////////////////////////

contract Storage1 is Storage0 {

    address internal contractOwner;

    bytes[] internal funcSignatures;

    // signature => index+1

    mapping(bytes => uint256) internal funcSignatureToIndex;

}

///////////////////////////////////////////////////////////////////////////////////

//MokensSupportsInterfaces

///////////////////////////////////////////////////////////////////////////////////

contract Storage2 is Storage1 {

    mapping(bytes4 => bool) internal supportedInterfaces;

}



contract MokensSupportsInterface is Storage2 {



    function addSupportedInterfaces(bytes4[] _interfaceIds) external {

        require(msg.sender == contractOwner, "Must own Mokens contract.");

        for(uint256 i = 0; i < _interfaceIds.length; i++) {

            supportedInterfaces[_interfaceIds[i]] = true;

        }

    }



    function removeSupportedInterfaces(bytes4[] _interfaceIds) external {

        require(msg.sender == contractOwner, "Must own Mokens contract.");

        for(uint256 i = 0; i < _interfaceIds.length; i++) {

            supportedInterfaces[_interfaceIds[i]] = false;

        }

    }



    function supportsInterface(bytes4 _interfaceId) external view returns (bool) {

        return supportedInterfaces[_interfaceId];

    }

}