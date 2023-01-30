/**

 *Submitted for verification at Etherscan.io on 2018-11-23

*/



pragma solidity 0.4.24;

pragma experimental "v0.5.0";

/******************************************************************************\

* Author: Nick Mudge, [email protected]

* Mokens

* Copyright (c) 2018

*

* Queries child contract info.

* Does not implement ERC998. Adds convenient query functions.

* These functions lighten the load on client software.

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

///////////////////////////////////////////////////////////////////////////////////

//MokenRootOwnerOf

//MokenERC721Metadata

///////////////////////////////////////////////////////////////////////////////////

contract Storage3 is Storage2 {

    struct Moken {

        string name;

        uint256 data;

        uint256 parentTokenId;

    }

    //tokenId => moken

    mapping(uint256 => Moken) internal mokens;

    uint256 internal mokensLength;

    // child address => child tokenId => tokenId+1

    mapping(address => mapping(uint256 => uint256)) internal childTokenOwner;

}

///////////////////////////////////////////////////////////////////////////////////

//MokenERC721Enumerable

//MokenLinkHash

///////////////////////////////////////////////////////////////////////////////////

contract Storage4 is Storage3 {

    // root token owner address => (tokenId => approved address)

    mapping(address => mapping(uint256 => address)) internal rootOwnerAndTokenIdToApprovedAddress;

    // token owner => (operator address => bool)

    mapping(address => mapping(address => bool)) internal tokenOwnerToOperators;

    // Mapping from owner to list of owned token IDs

    mapping(address => uint32[]) internal ownedTokens;

}

///////////////////////////////////////////////////////////////////////////////////

//MokenERC998ERC721TopDown

//MokenERC998ERC721TopDownBatch

//MokenERC721

//MokenERC721Batch

///////////////////////////////////////////////////////////////////////////////////

contract Storage5 is Storage4 {

    // tokenId => (child address => array of child tokens)

    mapping(uint256 => mapping(address => uint256[])) internal childTokens;

    // tokenId => (child address => (child token => child index)

    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) internal childTokenIndex;

    // tokenId => (child address => contract index)

    mapping(uint256 => mapping(address => uint256)) internal childContractIndex;

    // tokenId => child contract

    mapping(uint256 => address[]) internal childContracts;

}



contract MokenERC998ERC721TopDownBatchQuery is Storage5 {



    function allChildContracts(uint256 _tokenId) external view returns (address[]) {

        return childContracts[_tokenId];

    }



    function allChildContractTokens(uint256 _tokenId, address _childContract) external view returns (uint256[]) {

        return childTokens[_tokenId][_childContract];

    }

}