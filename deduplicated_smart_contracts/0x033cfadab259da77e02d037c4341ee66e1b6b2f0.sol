/**
 *Submitted for verification at Etherscan.io on 2019-09-20
*/

pragma solidity ^0.5.7;

contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

contract GX_Team_Funds {
    address public gxt_address = 0x60c87297A1fEaDC3C25993FfcadC54e99971e307;
    string public gxt_allocation = "GXT Team Funds";
    
    constructor (address _controller) public {
        ERC20Interface token = ERC20Interface(gxt_address);
        token.approve(_controller, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

     function getBalance() public view returns(uint256 balance){
        ERC20Interface token = ERC20Interface(gxt_address);

        return token.balanceOf(address(this));
    }

}