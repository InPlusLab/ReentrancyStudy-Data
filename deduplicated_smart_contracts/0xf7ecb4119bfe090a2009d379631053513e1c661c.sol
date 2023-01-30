/**

 *Submitted for verification at Etherscan.io on 2019-03-07

*/



pragma solidity 0.4.24;

pragma experimental "v0.5.0";

/******************************************************************************\

* Author: Nick Mudge, [email protected]

* Mokens

* Copyright (c) 2018

*

* This delegate contract contains functions related to moken categories.

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

    address[] internal mintContracts;

    mapping(address => uint256) internal mintContractIndex;

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



contract MokenCategories is Storage9 {



    event NewCategory(

        uint256 index,

        bytes32 name,

        uint256 mintPrice

    );



    function addCategory(bytes32 _categoryName, uint256 _mintPrice) external returns (uint256 index) {

        require(msg.sender == contractOwner, "Must own Mokens contract.");

        index = categoryLength++;

        categories[index] = _categoryName;

        categoryIndex[_categoryName] = index + 1;

        categoryMintPrice[index] = _mintPrice;

        emit NewCategory(index, _categoryName, _mintPrice);

    }



    function setCategoryMintPrice(uint256 _index, uint256 _mintPrice) external  {

        require(msg.sender == contractOwner, "Must own Mokens contract.");

        categoryMintPrice[_index] = _mintPrice;

    }



    function categoryByIndex(uint256 _index) external view returns (bytes32 category) {

        require(_index < categoryLength, "No category at this index.");

        category = categories[_index];

    }



    function categoryByName(bytes32 _categoryName) external view returns (uint256 indexOfCategory) {

        uint256 index = categoryIndex[_categoryName];

        require(index != 0, "No era exists with this name.");

        indexOfCategory = index - 1;

    }



    function categoryExists(bytes32 _categoryName) external view returns (bool) {

        return categoryIndex[_categoryName] != 0;

    }



    function categoryMintPriceByIndex(uint256 _categoryIndex) external view returns (uint256){

        require(_categoryIndex < categoryLength, "No category at this index.");

        return categoryMintPrice[_categoryIndex];

    }



    function categoryNames() external view returns (bytes32[] memory names){

        uint256 categoryLength_ = categoryLength;

        names = new bytes32[](categoryLength_);

        for(uint256 i; i < categoryLength_; i++) {

            names[i] = categories[i];

        }

    }



    function categoryMintPrices() external view returns (uint256[] memory prices){

        uint256 categoryLength_ = categoryLength;

        prices = new uint256[](categoryLength_);

        for(uint256 i; i < categoryLength_; i++) {

            prices[i] = categoryMintPrice[i];

        }

    }



    function totalCategories() external view returns (uint256) {

        return categoryLength;

    }

}