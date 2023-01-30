/**
 *Submitted for verification at Etherscan.io on 2019-12-03
*/

pragma solidity ^0.5.12;

contract HEX {
    function xfLobbyEnter(address referrerAddr)
    external
    payable;

    function xfLobbyExit(uint256 joinDay, uint256 count)
    external;

    function xfLobbyPendingDays(address memberAddr)
    external
    view
    returns (uint256[2] memory words);

    function balanceOf (address account)
    external
    view
    returns (uint256);

    function transfer (address recipient, uint256 amount)
    external
    returns (bool);

    function currentDay ()
    external
    view
    returns (uint256);
} // TODO: Windows file separator

contract StakeHexReferralSplitter {

    event DistributedShares(
        uint40 timestamp,
        address indexed memberAddress,
        uint256 amount
    );

    HEX internal hx = HEX(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39);

    address payable internal PHIL = 0x51CCf61AE6cD819B0AaA4283446A6a56aace2adD; // 10
    address payable internal KEVIN = 0x5a952b3501c827Ef96412C5CA61418DF93d955C4; // 15
    address payable internal NODE_NONCE = 0x072297fC12fca02f184e6bD7B99697b7490e5aBf; // 5
    address payable internal MICHAEL = 0xe551072153c02fa33d4903CAb0435Fb86F1a80cb; // 20
    address payable internal PAUL = 0x7f4F3E2c70D4FEE9cf9798F3d57629B5a1B5AF46; // 40
    address payable internal KYLE = 0xD30BC4859A79852157211E6db19dE159673a67E2; // 10

    function distribute ()
    public
    {
        uint256 balance = hx.balanceOf(address(this));
        uint256 fivePercent;
        if(balance > 99){
            fivePercent = balance / 20;
            hx.transfer(NODE_NONCE, fivePercent);
            hx.transfer(PHIL, 2*fivePercent);
            hx.transfer(KEVIN, 3*fivePercent);
            hx.transfer(MICHAEL, 4*fivePercent);
            hx.transfer(PAUL, 8*fivePercent);
            balance = balance - (18 * fivePercent);
            hx.transfer(KYLE, balance);
        }
    }

    function donate()
    external
    payable
    {}
}