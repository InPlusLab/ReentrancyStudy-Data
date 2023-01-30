/**

 *Submitted for verification at Etherscan.io on 2019-03-08

*/



pragma solidity 0.4.24;

pragma experimental "v0.5.0";

/******************************************************************************\

* Author: Nick Mudge, [email protected]

* Mokens

* Copyright (c) 2018

*

* Permissions using bits from a uint256

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

///////////////////////////////////////////////////////////////////////////////////

//MokenERC998ERC20TopDown

//MokenStateChange

///////////////////////////////////////////////////////////////////////////////////

contract Storage6 is Storage5 {

    // tokenId => token contract

    mapping(uint256 => address[]) internal erc20Contracts;

    // tokenId => (token contract => token contract index)

    mapping(uint256 => mapping(address => uint256)) erc20ContractIndex;

    // tokenId => (token contract => balance)

    mapping(uint256 => mapping(address => uint256)) internal erc20Balances;

}

///////////////////////////////////////////////////////////////////////////////////

//MokenERC998ERC721BottomUp

//MokenERC998ERC721BottomUpBatch

///////////////////////////////////////////////////////////////////////////////////

contract Storage7 is Storage6 {

    // parent address => (parent tokenId => array of child tokenIds)

    mapping(address => mapping(uint256 => uint32[])) internal parentToChildTokenIds;

    // tokenId => position in childTokens array

    mapping(uint256 => uint256) internal tokenIdToChildTokenIdsIndex;

}

///////////////////////////////////////////////////////////////////////////////////

//MokenMinting

//MokenMintContractManagement

//MokenEras

//QueryMokenData

///////////////////////////////////////////////////////////////////////////////////

contract Storage8 is Storage7 {

    // index => category

    mapping(uint256 => bytes32) internal categories;

    uint256 internal categoryLength;

    // category => index+1

    mapping(bytes32 => uint256) internal categoryIndex;

    uint256 internal mintPriceOffset; // = 0 szabo;

    uint256 internal mintStepPrice; // = 500 szabo;

    uint256 internal mintPriceBuffer; // = 5000 szabo;

    address[] internal permissionsList;

    // Order is from right to left

    // 0 bit is permission to give permission

    // 1 bit is permission to mint

    mapping(address => uint256) internal permissions;

    //moken name => tokenId+1

    mapping(string => uint256) internal tokenByName_;

}



///////////////////////////////////////////////////////////////////////////////////

// MokenCredit

///////////////////////////////////////////////////////////////////////////////////

contract Storage9 is Storage8 {

    // molder => wei

    mapping(address => uint256) internal credit;



    // categoryIndex >> mint price

    mapping(uint256 => uint256) internal categoryMintPrice;

}



contract MokenPermissions is Storage9 {



    function addPermission(address _address, uint256 _position) external {

        if(msg.sender != contractOwner) {

            require(permissions[msg.sender] & 1 == 1, "Not contract owner and does not have permission.");

        }

        require(_position < 256, "_position greater than 255");

        uint256 addressPermissions = permissions[_address];

        permissions[_address] = addressPermissions | (1 << _position);

        if(addressPermissions == 0) {

            permissionsList.push(_address);

        }

    }



    function setPermissions(address _address, uint256 _newPermissions) external {

        if(msg.sender != contractOwner) {

            require(permissions[msg.sender] & 1 == 1, "Not contract owner and does not have permission.");

        }

        uint256 oldPermissions = permissions[_address];

        permissions[_address] = _newPermissions;

        if(oldPermissions == 0) {

            if(_newPermissions > 0) {

                permissionsList.push(_address);

            }

        }

        else if(_newPermissions == 0) {

            removeAddressIfNoPermissions(_address);

        }

    }



    function getPermissions(address _address) external view returns (uint256){

        return permissions[_address];

    }



    function getPermissionAddresses() external view returns (address[]) {

        return permissionsList;

    }



    function removePermission(address _address, uint256 _position) external {

        if(msg.sender != contractOwner) {

            require(permissions[msg.sender] & 1 == 1, "Not contract owner and does not have permission.");

        }

        require(_position < 256, "_position greater than 255");

        uint256 addressPermissions = permissions[_address];

        if(addressPermissions == 0) {

            return;

        }

        addressPermissions = addressPermissions & ~(1 << _position);

        permissions[_address] = addressPermissions;

        if(addressPermissions == 0) {

            removeAddressIfNoPermissions(_address);

        }

    }



    function removeAddressIfNoPermissions(address _address) internal {

        uint256 length = permissionsList.length;

        for(uint256 i; i < length; i++) {

            if(permissionsList[i] == _address) {

                permissionsList[i] = permissionsList[length-1];

                permissionsList.length--;

                return;

            }

        }

    }

}