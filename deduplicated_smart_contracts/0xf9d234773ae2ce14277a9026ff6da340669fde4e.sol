/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

// SPDX-License-Identifier: GPL-3.0-only

pragma solidity 0.7.4;

interface ITrollbox {
    function withdrawWinnings(uint voterId) external;
    function updateAccount(uint voterId, uint tournamentId, uint roundId) external;
    function isSynced(uint voterId, uint tournamentId, uint roundId) external view returns (bool);
    function roundAlreadyResolved(uint tournamentId, uint roundId) external view returns (bool);
}

contract TrollboxProxy {

    ITrollbox public trollbox;

    constructor(address box){
        trollbox = ITrollbox(box);
    }

    function updateAndWithdraw(uint[] memory voterIds, uint[] memory tournamentIds, uint[] memory roundIds, uint[] memory uniqueVoterIds) public {
        for (uint i = 0; i < voterIds.length; i++) {
            trollbox.updateAccount(voterIds[i], tournamentIds[i], roundIds[i]);
        }
        for (uint j = 0; j < uniqueVoterIds.length; j++) {
            trollbox.withdrawWinnings(uniqueVoterIds[j]);
        }
    }
}