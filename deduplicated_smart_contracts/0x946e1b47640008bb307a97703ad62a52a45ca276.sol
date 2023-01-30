/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.25;



// ----------------------------------------------------------------------------

// The Number Of The Beast @ 0x3dBe8229d5B350E8fc2bb020441696680C2097f2

//

// Block 6,666,666 @ Nov-08-2018 02:04:33 PM +UTC

//

// Come collect some INDULGENCE tokens. And save your soul

// ----------------------------------------------------------------------------



contract ERC20Fragment {

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function transfer(address to, uint tokens) public returns (bool success);

}



contract TheNumberOfTheBeast {

    address public owner;

    ERC20Fragment public INDULGENCE_TOKEN = ERC20Fragment(0xaB8957c8EB44057bA0669733211946f3692bbb64);

    

    uint private OFFERINGS = 100 * uint(10) ** 18;

    uint private COMMITSIN = 10 * uint(10) ** 18;

    

    constructor() public {

        owner = msg.sender;

    }

    

    function makeOffering() public payable {

        owner.transfer(address(this).balance);

        if (INDULGENCE_TOKEN.balanceOf(address(this)) >= OFFERINGS) {

            INDULGENCE_TOKEN.transfer(msg.sender, OFFERINGS);

        }

    }

    

    function commitSinAndReceiveBonusIndulgence() public {

        if (INDULGENCE_TOKEN.balanceOf(address(this)) >= COMMITSIN) {

            INDULGENCE_TOKEN.transfer(msg.sender, COMMITSIN);

        }

    }

}