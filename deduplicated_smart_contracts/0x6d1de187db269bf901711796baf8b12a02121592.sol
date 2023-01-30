/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

pragma solidity ^0.6.3;
contract eerminer {
    function checklasttwentyblock() view public returns(bool, uint256) {
        if(uint256(blockhash(block.number-1)) % 5200 == 1){
            return (true, block.number-1);
        }else if(uint256(blockhash(block.number-2)) % 5200 == 1){
            return (true, block.number-2);
        } else if(uint256(blockhash(block.number-3)) % 5200 == 1){
            return (true, block.number-3);
        }else if(uint256(blockhash(block.number-4)) % 5200 == 1){
            return (true, block.number-4);
        }else if(uint256(blockhash(block.number-5)) % 5200 == 1){
            return (true, block.number-5);
        } else if(uint256(blockhash(block.number-6)) % 5200 == 1){
            return (true,block.number-6);
        } else if(uint256(blockhash(block.number-7)) % 5200 == 1){
            return (true, block.number-7);
        } else if(uint256(blockhash(block.number-8)) % 5200 == 1){
            return (true, block.number-8);
        } else if(uint256(blockhash(block.number-9)) % 5200 == 1){
            return (true,block.number-9);
        } else if(uint256(blockhash(block.number-10)) % 5200 == 1){
            return (true, block.number-10);
        } else if(uint256(blockhash(block.number-11)) % 5200 == 1){
            return (true,block.number-11);
        } else if(uint256(blockhash(block.number-12)) % 5200 == 1){
            return (true,block.number-12);
        } else if(uint256(blockhash(block.number-13)) % 5200 == 1){
            return (true,block.number-13);
        } else if(uint256(blockhash(block.number-14)) % 5200 == 1){
            return (true,block.number-14);
        } else if(uint256(blockhash(block.number-15)) % 5200 == 1){
            return (true,block.number-15);
        } else if(uint256(blockhash(block.number-16)) % 5200 == 1){
            return (true, block.number-16);
        } else if(uint256(blockhash(block.number-17)) % 5200 == 1){
            return (true,block.number-17);
        } else if(uint256(blockhash(block.number-18)) % 5200 == 1){
            return (true,block.number-18);
        } else if(uint256(blockhash(block.number-19)) % 5200 == 1){
            return (true,block.number-19);
        } else if(uint256(blockhash(block.number-20)) % 5200 == 1){
            return (true, block.number-20);
        }else {
            return (false,block.number-1);
        }
    }
}