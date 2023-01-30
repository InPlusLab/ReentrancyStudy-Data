/**
 *Submitted for verification at Etherscan.io on 2020-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

contract Splitter {
    
    address payable[] private targets;
    
    constructor() public {
        targets.push(0xACE5BeedDDc24dec659eeEcb21A3C21F5576e3C9);
        targets.push(0xba5e44BCa8FB64BFF682E1F774850B1CA598fF11);
        targets.push(0xB01D1EcadB6b24D809386af88551c35Bd12e82dA);
        targets.push(0xCafe59428b2946FBc128fd6C36cb1Ec1443AeD6C);
        targets.push(0xD1CEbD1Ad772c8A6dD05eCdFA0ae776a9266032c);
        targets.push(0xea5e37c75383331a1de5b7f7f1a93Ef080b319Be);
        targets.push(0xFADE7bB65A1e06D11B3F099b225ddC7C8Ae65967);
        targets.push(0xFEED4873Ab0D642dD4b694EdA6FF90cD732fE4C9);
        targets.push(0xce1179C2e69edBaCaB52485a75C0Ae4a979b0919);
        targets.push(0xC0DE642aEfD2c8fbEaB09bbA9474461080b715f9);
        targets.push(0xface14522b18BE412e9DB0E1570Be94Cb9af0A88);
        targets.push(0xC0015CfE8C0e00423E2D84853E5A9052EdcdF8b2);
    }
    
    receive() external payable {
        if (msg.sender == tx.origin) {
            process();
        }
    }
    
    function process() public {
        uint256 _balance = address(this).balance;
        if (_balance > 0) {
            uint256 _count = targets.length;
            for (uint256 i = 0; i < _count; i++) {
                targets[i].transfer(_balance / _count);
            }
        }
    }
}