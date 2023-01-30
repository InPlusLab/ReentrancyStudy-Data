/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

pragma solidity 0.5.7;

// ----------------------------------------------------------------------------
//
// S.J.G.S.M. contract
//
// Symbol        : SJGSM
// Name          : S.J.G.S.M.
// Total supply  : 1962
// Decimals      : 18
//
// (c) S.J.G.S.M. 2021. MIT Licence. https://sjgsm.es
//
// ----------------------------------------------------------------------------

contract SimpleERC20Token {
    // Track how many tokens are owned by each address.
    mapping (address => uint256) public balanceOf;

    // Modify this section
    string public name = "S.J.G.S.M.";
    string public symbol = "SJGSM";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1962 * (uint256(10) ** decimals);
    

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        // Initially assign all tokens to the contract's creator.
        balanceOf[msg.sender] = 1962000000000000000000;
        emit Transfer(address(0), msg.sender,1962000000000000000000);
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