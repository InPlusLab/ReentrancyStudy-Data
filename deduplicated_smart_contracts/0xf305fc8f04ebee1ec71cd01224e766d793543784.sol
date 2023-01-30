/**
 *Submitted for verification at Etherscan.io on 2020-07-05
*/

pragma solidity 0.5.7;

// Arcane Crypto
//We support the financial system of the future

//https://www.arcane.no/
 
 
 
 

//We have followed general OpenZeppelin guidelines: functions revert instead
//of returning `false` on failure. This behavior is nonetheless conventional
//and does not conflict with the expectations of ERC20 applications.
 
 
 
 
 

contract ArcaneCrypto {
    // Track how many tokens are owned by each address.
    mapping (address => uint256) public balanceOf;

    // 
    string public name = "Arcane Crypto";
    string public symbol = "ARC";
    uint8 public decimals = 18;
    uint256 public totalSupply = 325000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        // 
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value);

        balanceOf[msg.sender] -= value;  // 
        balanceOf[to] += value;          // 
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