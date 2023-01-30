/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.12;

/****
 * TurnCoinERC20SecurityToken contract will be upgraded post soft-launch of the  
 * SportXchange Platform and App to include; monthly TurnCoin yield payouts and 
 * leak-out & lockdown provisions, as required by regulatory authorities in the
 * jurisdictions in which TurnCoin will be sold.
 ****/
contract TurnCoinERC20SecurityToken {
    // Track how many tokens are owned by each address.
    mapping (address => uint256) public balanceOf;

    string public name = "TurnCoin";
    string public symbol = "X";
    uint8 public decimals = 18;

    uint256 public totalSupply = 1000000000 * (uint256(10) ** decimals);

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public {
        // Initially assign 400 million tokens to the contract's creator.
        balanceOf[msg.sender] = 400000000;
        
        // Holder - 500 million TurnCoins Permanently Locked.
        balanceOf[address(0xf52e105b0cE497Cf461e11cdafa18e08bFffa8E5)] = 500000000;
        
        // Holder - 100 million TurnCoins Permanently Locked.
        balanceOf[address(0x7D990EA14D0Afb22e2367c77A7475A8E5928dED2)]  = 100000000;
        
        emit Transfer(address(0), msg.sender, totalSupply);
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