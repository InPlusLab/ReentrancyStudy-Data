/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity 0.4.24;

pragma experimental "v0.5.0";

/******************************************************************************\

* Author: Nick Mudge, [email protected]

* Mokens

* Copyright (c) 2018

*

* Implements ERC998ERC721TopDownBatch

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



contract RootOwnerOfHelper is Storage3 {



    bytes32 constant ERC998_MAGIC_VALUE = 0xcd740db5;



    // Use Cases handled:

    // Case 1: Token owner is this contract and token

    // Case 2: Token owner is this contract and top-down composable.

    // Case 3: Token owner is top-down composable

    // Case 4: Token owner is an unknown contract

    // Case 5: Token owner is a user

    // Case 6: Token owner is a bottom-up composable

    // Case 7: Token owner is ERC721 token owned by top-down token

    // Case 8: Token owner is ERC721 token owned by unknown contract

    // Case 9: Token owner is ERC721 token owned by user

    function rootOwnerOf_(uint256 _tokenId) internal view returns (bytes32 rootOwner) {

        address rootOwnerAddress = address(mokens[_tokenId].data);

        require(rootOwnerAddress != address(0), "tokenId not found.");

        uint256 parentTokenId;

        bool isParent;



        while (rootOwnerAddress == address(this)) {

            parentTokenId = mokens[_tokenId].parentTokenId;

            isParent = parentTokenId > 0;

            if (isParent) {

                // Case 1: Token owner is this contract and token

                _tokenId = parentTokenId - 1;

            }

            else {

                // Case 2: Token owner is this contract and top-down composable.

                _tokenId = childTokenOwner[rootOwnerAddress][_tokenId] - 1;

            }

            rootOwnerAddress = address(mokens[_tokenId].data);

        }



        parentTokenId = mokens[_tokenId].parentTokenId;

        isParent = parentTokenId > 0;

        if (isParent) {

            parentTokenId--;

        }



        bytes memory calldata;

        bool callSuccess;



        if (isParent == false) {



            // success if this token is owned by a top-down token

            // 0xed81cdda == rootOwnerOfChild(address,uint256)

            calldata = abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);

            assembly {

                callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)

                if callSuccess {

                    rootOwner := mload(calldata)

                }

            }

            if (callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {

                // Case 3: Token owner is top-down composable

                return rootOwner;

            }

            else {

                // Case 4: Token owner is an unknown contract

                // Or

                // Case 5: Token owner is a user

                return ERC998_MAGIC_VALUE << 224 | bytes32(rootOwnerAddress);

            }

        }

        else {



            // 0x43a61a8e == rootOwnerOf(uint256)

            calldata = abi.encodeWithSelector(0x43a61a8e, parentTokenId);

            assembly {

                callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)

                if callSuccess {

                    rootOwner := mload(calldata)

                }

            }

            if (callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {

                // Case 6: Token owner is a bottom-up composable

                // Or

                // Case 2: Token owner is top-down composable

                return rootOwner;

            }

            else {

                // token owner is ERC721

                address childContract = rootOwnerAddress;

                //0x6352211e == "ownerOf(uint256)"

                calldata = abi.encodeWithSelector(0x6352211e, parentTokenId);

                assembly {

                    callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)

                    if callSuccess {

                        rootOwnerAddress := mload(calldata)

                    }

                }

                require(callSuccess, "Call to ownerOf failed");



                // 0xed81cdda == rootOwnerOfChild(address,uint256)

                calldata = abi.encodeWithSelector(0xed81cdda, childContract, parentTokenId);

                assembly {

                    callSuccess := staticcall(gas, rootOwnerAddress, add(calldata, 0x20), mload(calldata), calldata, 0x20)

                    if callSuccess {

                        rootOwner := mload(calldata)

                    }

                }

                if (callSuccess == true && rootOwner >> 224 == ERC998_MAGIC_VALUE) {

                    // Case 7: Token owner is ERC721 token owned by top-down token

                    return rootOwner;

                }

                else {

                    // Case 8: Token owner is ERC721 token owned by unknown contract

                    // Or

                    // Case 9: Token owner is ERC721 token owned by user

                    return ERC998_MAGIC_VALUE << 224 | bytes32(rootOwnerAddress);

                }

            }

        }

    }

}



contract MokenHelpers is Storage4, RootOwnerOfHelper {



    bytes4 constant ERC721_RECEIVED_NEW = 0x150b7a02;



    uint256 constant UINT16_MASK = 0x000000000000000000000000000000000000000000000000000000000000ffff;

    uint256 constant MAX_OWNER_MOKENS = 65536;



    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed tokenOwner, address indexed approved, uint256 indexed tokenId);



    function childApproved(address _from, uint256 _tokenId) internal {

        address approvedAddress = rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];

        if(msg.sender != _from) {

            bytes32 tokenOwner;

            bool callSuccess;

            // 0xeadb80b8 == ownerOfChild(address,uint256)

            bytes memory calldata = abi.encodeWithSelector(0xed81cdda, address(this), _tokenId);

            assembly {

                callSuccess := staticcall(gas, _from, add(calldata, 0x20), mload(calldata), calldata, 0x20)

                if callSuccess {

                    tokenOwner := mload(calldata)

                }

            }

            if(callSuccess == true) {

                require(tokenOwner >> 224 != ERC998_MAGIC_VALUE, "Token is child of top down composable");

            }

            require(tokenOwnerToOperators[_from][msg.sender] || approvedAddress == msg.sender, "msg.sender not _from/operator/approved.");

        }

        if (approvedAddress != address(0)) {

            delete rootOwnerAndTokenIdToApprovedAddress[_from][_tokenId];

            emit Approval(_from, address(0), _tokenId);

        }

    }



    function _transferFrom(uint256 data, address _to, uint256 _tokenId) internal {

        address _from = address(data);

        //removing the tokenId

        // 1. We replace _tokenId in ownedTokens[_from] with the last token id

        //    in ownedTokens[_from]

        uint256 lastTokenIndex = ownedTokens[_from].length - 1;

        uint256 lastTokenId = ownedTokens[_from][lastTokenIndex];

        if (lastTokenId != _tokenId) {

            uint256 tokenIndex = data >> 160 & UINT16_MASK;

            ownedTokens[_from][tokenIndex] = uint32(lastTokenId);

            // 2. We set lastTokeId to point to its new position in ownedTokens[_from]

            mokens[lastTokenId].data = mokens[lastTokenId].data & 0xffffffffffffffffffff0000ffffffffffffffffffffffffffffffffffffffff | tokenIndex << 160;

        }

        // 3. We remove lastTokenId from the end of ownedTokens[_from]

        ownedTokens[_from].length--;



        //adding the tokenId

        uint256 ownedTokensIndex = ownedTokens[_to].length;

        // prevents 16 bit overflow

        require(ownedTokensIndex < MAX_OWNER_MOKENS, "A token owner address cannot possess more than 65,536 mokens.");

        mokens[_tokenId].data = data & 0xffffffffffffffffffff00000000000000000000000000000000000000000000 | ownedTokensIndex << 160 | uint256(_to);

        ownedTokens[_to].push(uint32(_tokenId));



        emit Transfer(_from, _to, _tokenId);

    }



    function isContract(address addr) internal view returns (bool) {

        uint256 size;

        assembly {size := extcodesize(addr)}

        return size > 0;

    }

}



interface ERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed tokenOwner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed tokenOwner, address indexed operator, bool approved);



    function balanceOf(address _tokenOwner) external view returns (uint256 _balance);

    function ownerOf(uint256 _tokenId) external view returns (address _tokenOwner);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    function approve(address _to, uint256 _tokenId) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address _operator);

    function isApprovedForAll(address _tokenOwner, address _operator) external view returns (bool);

}



interface ERC998ERC721BottomUp {

    function transferToParent(address _from, address _toContract, uint256 _toTokenId, uint256 _tokenId, bytes _data) external;

}



contract MokenERC998ERC721TopDownBatch is Storage5, RootOwnerOfHelper {



    event ReceivedChild(address indexed from, uint256 indexed tokenId, address indexed childContract, uint256 childTokenId);

    event TransferChild(uint256 indexed tokenId, address indexed to, address indexed childContract, uint256 childTokenId);



    function removeChild(uint256 _fromTokenId, address _childContract, uint256 _childTokenId) internal {

        // remove child token

        uint256 lastTokenIndex = childTokens[_fromTokenId][_childContract].length - 1;

        uint256 lastToken = childTokens[_fromTokenId][_childContract][lastTokenIndex];

        if (_childTokenId != lastToken) {

            uint256 tokenIndex = childTokenIndex[_fromTokenId][_childContract][_childTokenId];

            childTokens[_fromTokenId][_childContract][tokenIndex] = lastToken;

            childTokenIndex[_fromTokenId][_childContract][lastToken] = tokenIndex;

        }

        childTokens[_fromTokenId][_childContract].length--;

        delete childTokenIndex[_fromTokenId][_childContract][_childTokenId];

        delete childTokenOwner[_childContract][_childTokenId];



        // remove contract

        if (lastTokenIndex == 0) {

            uint256 lastContractIndex = childContracts[_fromTokenId].length - 1;

            address lastContract = childContracts[_fromTokenId][lastContractIndex];

            if (_childContract != lastContract) {

                uint256 contractIndex = childContractIndex[_fromTokenId][_childContract];

                childContracts[_fromTokenId][contractIndex] = lastContract;

                childContractIndex[_fromTokenId][lastContract] = contractIndex;

            }

            childContracts[_fromTokenId].length--;

            delete childContractIndex[_fromTokenId][_childContract];

        }

    }



    function safeBatchTransferChild(uint256 _fromTokenId, address _to, address _childContract, uint256[] _childTokenIds) external {

        uint256 childTokenId;

        require(_to != address(0), "_to cannot be 0 address.");

        address rootOwner = address(rootOwnerOf_(_fromTokenId));

        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||

        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");

        for (uint256 i; i < _childTokenIds.length; i++) {

            childTokenId = _childTokenIds[i];

            uint256 tokenId = childTokenOwner[_childContract][childTokenId];

            require(tokenId != 0, "Child token does not exist");

            require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");

            removeChild(_fromTokenId, _childContract, childTokenId);

            ERC721(_childContract).safeTransferFrom(this, _to, childTokenId);

            emit TransferChild(_fromTokenId, _to, _childContract, childTokenId);

        }

    }



    function safeBatchTransferChild(uint256 _fromTokenId, address _to, address _childContract, uint256[] _childTokenIds, bytes _data) external {

        uint256 childTokenId;

        require(_to != address(0), "_to cannot be 0 address.");

        address rootOwner = address(rootOwnerOf_(_fromTokenId));

        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||

        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");

        for (uint256 i; i < _childTokenIds.length; i++) {

            childTokenId = _childTokenIds[i];

            uint256 tokenId = childTokenOwner[_childContract][childTokenId];

            require(tokenId != 0, "Child token does not exist");

            require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");

            removeChild(_fromTokenId, _childContract, childTokenId);

            ERC721(_childContract).safeTransferFrom(this, _to, childTokenId, _data);

            emit TransferChild(_fromTokenId, _to, _childContract, childTokenId);

        }

    }



    function batchTransferChild(uint256 _fromTokenId, address _to, address _childContract, uint256[] _childTokenIds) external {

        uint256 childTokenId;

        bytes memory calldata;

        require(_to != address(0), "_to cannot be 0 address.");

        address rootOwner = address(rootOwnerOf_(_fromTokenId));

        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||

        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");

        for (uint256 i; i < _childTokenIds.length; i++) {

            childTokenId = _childTokenIds[i];

            uint256 tokenId = childTokenOwner[_childContract][childTokenId];

            require(tokenId != 0, "Child token does not exist");

            require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");

            removeChild(_fromTokenId, _childContract, childTokenId);

            //this is here to be compatible with cryptokitties and other old contracts that require being owner and approved

            // before transferring.

            //It is not required by current standard , so we let it fail if it fails

            //0x095ea7b3 == "approve(address,uint256)"

            calldata = abi.encodeWithSelector(0x095ea7b3, this, childTokenId);

            assembly {

                let success := call(gas, _childContract, 0, add(calldata, 0x20), mload(calldata), calldata, 0)

            }

            ERC721(_childContract).transferFrom(this, _to, childTokenId);

            emit TransferChild(_fromTokenId, _to, _childContract, childTokenId);

        }

    }



    function transferChildToParent(uint256 _fromTokenId, address _toContract, uint256 _toTokenId, address _childContract, uint256[] _childTokenIds, bytes _data) external {

        uint256 childTokenId;

        require(_toContract != address(0), "_toContract cannot be 0 address.");

        address rootOwner = address(rootOwnerOf_(_fromTokenId));

        require(rootOwner == msg.sender || tokenOwnerToOperators[rootOwner][msg.sender] ||

        rootOwnerAndTokenIdToApprovedAddress[rootOwner][_fromTokenId] == msg.sender, "msg.sender not rootOwner/operator/approved.");

        for (uint256 i; i < _childTokenIds.length; i++) {

            childTokenId = _childTokenIds[i];

            uint256 tokenId = childTokenOwner[_childContract][childTokenId];

            require(tokenId != 0, "Child token does not exist");

            require(_fromTokenId == tokenId - 1, "_fromTokenId does not own the child token.");

            removeChild(_fromTokenId, _childContract, childTokenId);

            ERC998ERC721BottomUp(_childContract).transferToParent(address(this), _toContract, _toTokenId, childTokenId, _data);

            emit TransferChild(_fromTokenId, _toContract, _childContract, childTokenId);

        }

    }

}