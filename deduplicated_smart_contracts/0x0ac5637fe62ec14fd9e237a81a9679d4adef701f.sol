/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity 0.4.24;

pragma experimental "v0.5.0";

/******************************************************************************\

* Author: Nick Mudge, [email protected]

* Copyright (c) 2018

* Mokens

*

* The MokenUpdates contract adds/updates/removes functions. This is how the

* Mokens contract is updated

*

* Function changes emit the FunctionUpdate and CommitMessage events.

* Monitor changes to the Mokens contract by watching/filtering the

* FunctionUpdate and CommitMessage events.

*

* Functions and delegate contracts can be queried by using functions from the

* QueryMokenDelegates contract.

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



interface ERC1538 {

    event CommitMessage(string message);

    event FunctionUpdate(bytes4 indexed functionId, address indexed oldDelegate, address indexed newDelegate, string functionSignature);

    function updateContract(address _delegate, string _functionSignatures, string commitMessage) external;

}



contract MokenUpdates is Storage1, ERC1538 {



    function updateContract(address _delegate, string _functionSignatures, string commitMessage) external {

        require(msg.sender == contractOwner, "Must own the contract.");

        // pos is first used to check the size of the delegate contract.

        // After that pos is the current memory location of _functionSignatures.

        // It is used to move through the characters of _functionSignatures

        uint256 pos;

        if(_delegate != address(0)) {

            assembly {

                pos := extcodesize(_delegate)

            }

            require(pos > 0, "_delegate address is not a contract and is not address(0)");

        }

        // creates a bytes vesion of _functionSignatures

        bytes memory signatures = bytes(_functionSignatures);

        // stores the position in memory where _functionSignatures ends.

        uint256 signaturesEnd;

        // stores the starting position of a function signature in _functionSignatures

        uint256 start;

        assembly {

            pos := add(signatures,32)

            start := pos

            signaturesEnd := add(pos,mload(signatures))

        }

        // the function id of the current function signature

        bytes4 funcId;

        // the delegate address that is being replaced or address(0) if removing functions

        address oldDelegate;

        // the length of the current function signature in _functionSignatures

        uint256 num;

        // the current character in _functionSignatures

        uint256 char;

        // the position of the current function signature in the funcSignatures array

        uint256 index;

        // the last position in the funcSignatures array

        uint256 lastIndex;

        // parse the _functionSignatures string and handle each function

        for (; pos < signaturesEnd; pos++) {

            assembly {char := byte(0,mload(pos))}

            // 0x29 == )

            if (char == 0x29) {

                pos++;

                num = (pos - start);

                start = pos;

                assembly {

                    mstore(signatures,num)

                }

                funcId = bytes4(keccak256(signatures));

                oldDelegate = delegates[funcId];

                if(_delegate == address(0)) {

                    index = funcSignatureToIndex[signatures];

                    require(index != 0, "Function does not exist.");

                    index--;

                    lastIndex = funcSignatures.length - 1;

                    if (index != lastIndex) {

                        funcSignatures[index] = funcSignatures[lastIndex];

                        funcSignatureToIndex[funcSignatures[lastIndex]] = index + 1;

                    }

                    funcSignatures.length--;

                    delete funcSignatureToIndex[signatures];

                    delete delegates[funcId];

                    emit FunctionUpdate(funcId, oldDelegate, address(0), string(signatures));

                }

                else if (funcSignatureToIndex[signatures] == 0) {

                    require(oldDelegate == address(0), "FuncId clash.");

                    delegates[funcId] = _delegate;

                    funcSignatures.push(signatures);

                    funcSignatureToIndex[signatures] = funcSignatures.length;

                    emit FunctionUpdate(funcId, address(0), _delegate, string(signatures));

                }

                else if (delegates[funcId] != _delegate) {

                    delegates[funcId] = _delegate;

                    emit FunctionUpdate(funcId, oldDelegate, _delegate, string(signatures));



                }

                assembly {signatures := add(signatures,num)}

            }

        }

        emit CommitMessage(commitMessage);

    }

}