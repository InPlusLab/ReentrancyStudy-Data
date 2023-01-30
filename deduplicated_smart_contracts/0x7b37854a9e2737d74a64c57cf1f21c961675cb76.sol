pragma solidity ^0.5.12;

import "./TokenEscrow.sol";

contract TcjXraTest is TokenEscrow(
    0xC9d32Ab70a7781a128692e9B4FecEBcA6C1Bcce4,
    0x98719cFC0AeE5De1fF30bB5f22Ae3c2Ce45e43F7,
    0x44744e3e608D1243F55008b328fE1b09bd42E4Cc,
    0x7025baB2EC90410de37F488d1298204cd4D6b29d,
    10000000000000000000,
    10000000000000000000,
    1572393600,
    1572451200) {
    constructor() public{

    }
}
