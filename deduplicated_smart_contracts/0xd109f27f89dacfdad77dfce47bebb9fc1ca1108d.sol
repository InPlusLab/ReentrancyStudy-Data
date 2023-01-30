/**
 *Submitted for verification at Etherscan.io on 2019-11-01
*/

/**
 *This is the only live Ace Wins Contract. The previous contract is not used any longer. ACW is the new ticker. The old ticker ACE is no longer in use.
*/

pragma solidity ^0.4.16;


contract Ownable {
    
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }
    

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}


contract AceWins is Ownable {
    
    uint256 public totalSupply;
    mapping(address => uint256) startBalances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => uint256) startBlocks;
    
    string public constant name = "Ace Wins";
    string public constant symbol = "ACW";
    uint32 public constant decimals = 10;
    uint256 public calc = 951839;

    function AceWins() public {
        totalSupply = 12500000 * 10**uint256(decimals);
        startBalances[owner] = totalSupply;
        startBlocks[owner] = block.number;
        Transfer(address(0), owner, totalSupply);
    }


    function fracExp(uint256 k, uint256 q, uint256 n, uint256 p) pure public returns (uint256) {
        uint256 s = 0;
        uint256 N = 1;
        uint256 B = 1;
        for (uint256 i = 0; i < p; ++i) {
            s += k * N / B / (q**i);
            N = N * (n-i);
            B = B * (i+1);
        }
        return s;
    }


    function compoundInterest(address tokenOwner) view public returns (uint256) {
        require(startBlocks[tokenOwner] > 0);
        uint256 start = startBlocks[tokenOwner];
        uint256 current = block.number;
        uint256 blockCount = current - start;
        uint256 balance = startBalances[tokenOwner];
        return fracExp(balance, calc, blockCount, 8) - balance;
    }


    function balanceOf(address tokenOwner) public constant returns (uint256 balance) {
        return startBalances[tokenOwner] + compoundInterest(tokenOwner);
    }

    

    function updateBalance(address tokenOwner) private {
        if (startBlocks[tokenOwner] == 0) {
            startBlocks[tokenOwner] = block.number;
        }
        uint256 ci = compoundInterest(tokenOwner);
        startBalances[tokenOwner] = startBalances[tokenOwner] + ci;
        totalSupply = totalSupply + ci;
        startBlocks[tokenOwner] = block.number;
    }
    

 
    function transfer(address to, uint256 tokens) public returns (bool) {
        updateBalance(msg.sender);
        updateBalance(to);
        require(tokens <= startBalances[msg.sender]);

        startBalances[msg.sender] = startBalances[msg.sender] - tokens;
        startBalances[to] = startBalances[to] + tokens;
        Transfer(msg.sender, to, tokens);
        return true;
    }



   
     function setCalc(uint256 _Calc) public {
      require(msg.sender==owner);
      calc = _Calc;
    }
    
     
    function approve(address spender, uint256 tokens) public returns (bool) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    } 
    

    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
   
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);
    
}