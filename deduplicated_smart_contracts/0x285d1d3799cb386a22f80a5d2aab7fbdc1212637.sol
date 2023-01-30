/**
 *Submitted for verification at Etherscan.io on 2020-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

interface TokenInterface {
    function balanceOf(address) external view returns (uint);
    function delegates(address) external view returns (address);
    function getCurrentVotes(address) external view returns (uint96);
}


contract Resolver {
    struct Position {
        address token;
        address owner;
        uint balance;
        uint96 votes;
        address delegatee;
    }

    function getHoldersPosition(address token, address[] memory holders) public view returns (Position[] memory) {
        Position[] memory holdersData = new Position[](holders.length);
        TokenInterface tokenContract = TokenInterface(token);
        for (uint i = 0; i < holders.length; i++) {
            address holder = holders[i];
            holdersData[i] = Position({
                token: token,
                owner: holder,
                balance: tokenContract.balanceOf(holder),
                votes: tokenContract.getCurrentVotes(holder),
                delegatee: tokenContract.delegates(holder)
            });
        }
        return holdersData;
    }

    function getHolderPositions(address[] memory tokens, address holder) public view returns (Position[] memory) {
        Position[] memory holderPositions = new Position[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            TokenInterface tokenContract = TokenInterface(tokens[i]);
            holderPositions[i] = Position({
                token: tokens[i],
                owner: holder,
                balance: tokenContract.balanceOf(holder),
                votes: tokenContract.getCurrentVotes(holder),
                delegatee: tokenContract.delegates(holder)
            });
        }
        return holderPositions;
    }
}

contract AtlasHoldersResolver is Resolver {

    string public constant name = "Atlas-Holders-Resolver-v1.0";
    
}