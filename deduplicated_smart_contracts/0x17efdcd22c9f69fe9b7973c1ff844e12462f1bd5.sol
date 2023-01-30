/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

pragma solidity 0.5.7;

// ----------------------------------------------------------------------------
// OLYMPIAKOI contract
//
// Symbol        : OLYMPIAKOI
// Name          : The Olympic Movement 
// Total supply  : 25000
// Decimals      : 18
// Owner Account : 0x88b8E203f8e80B1b349d05CC6A4CF149B959beF9
// Enjoy.
//
// (c) The Olympic Movement 2021. MIT Licence.
//
// Website: https://www.Olympiakoi.com
// ----------------------------------------------------------------------------

contract SimpleERC20Token {
    // Track how many tokens are owned by each address.
    mapping (address => uint256) public balanceOf;

    // Modify this section
    string public name = "The Olympic Movement";
    string public symbol = "OLYMPIAKOI";
    uint8 public decimals = 18;
    uint256 public totalSupply = 25000 * (uint256(10) ** decimals);
    

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        // Initially assign all tokens to the contract's creator.
        balanceOf[msg.sender] = 250000000000000000000;
        emit Transfer(address(0), msg.sender,250000000000000000000);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;  // deduct from sender's balance
        balanceOf[to] += value;          // add to recipient's balance
        emit Transfer(msg.sender, to, value);
        return true;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => mapping(address => uint256)) public allowance;

    function approve(address spender, uint256 value)
        public
        returns (bool success)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool success)
    {
        require(value <= balanceOf[from]);
        require(value <= allowance[from][msg.sender]);

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}