/**
 *Submitted for verification at Etherscan.io on 2020-12-04
*/

// To be fair, you have to have a very high IQ to understand Rick and Morty. The humour is extremely subtle, and without a solid grasp of theoretical physics
// most of the jokes will go over a typical viewer's head. There's also Rick's nihilistic outlook, which is deftly woven into his characterisation- his personal
// philosophy draws heavily from Narodyna Volya literature, for instance. The fans understand this stuff; They have the intellectual capacity to truly appreciate
// the depths of these jokes, to realise that they're not just funny- they say something deep about LIFE. As a consequence people who dislike Rick & Morty truly
// are idiots- of course they wouldn't appreciate, for instance, the humour in Rick's existential catchphrase "Wubba Lubba Dub Dub," which itself is a cryptic 
// reference to Turgenev's Russian epic Fathers and Sons. I'm smirking right now just imagining one of those addlepated simpletons scratching their heads in 
// confusion as Dan Harmon's genius wit unfolds itself on their television screens. What fools.. how i pity them
// And yes, by the way i DO have a Rick & Morty tattoo. And no, you cannot see it. It's for the ladies' eyes only- and even they have to demonstrate that
// they're within 5 IQ points of my own (preferably lower) beforehand. Nothin personal kid.

// However, this contract is for Morty Token, not Rick or schmeckles. This seems like a good time for a drink, and a cold calculated speech with sinister
// overtones. A speech about politics, about order, brotherhood, power. But speeches are for campaigning. Now is the time for action - Evil Morty.

// The time of de Morty multiverse takeover is now. All Jerry's shall be exterminated and Rick's shall be used to farm schmeckles for the cause.
// aka schemeckles because MORTYTOKEN has many schemes lying ahead. Enjoy de farms and games.

pragma solidity ^0.4.24;




// ---------------------------------------------------------------------------------------------------------------------------
// Lib: Safe Math
// ---------------------------------------------------------------------------------------------------------------------------
contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


/**
ERC Token Standard #20 Interface

*/
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/**
Contract function to receive approval and execute function in one call
*/
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

/**
ERC20 Token, with the addition of symbol, name and decimals and assisted token transfers
*/
contract MORTYTOKEN is ERC20Interface, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "MORTY";
        name = "MORTYTOKEN";
        decimals = 18;
        _totalSupply = 500000 * 10 ** 18;
        balances[0x246e6fd15EbB6db65FFD4Fe01A4CdE10801b5e9A] = _totalSupply;
        emit Transfer(address(0), 0x246e6fd15EbB6db65FFD4Fe01A4CdE10801b5e9A, _totalSupply);
      
    }


    // ------------------------------------------------------------------------
    // Total supply / Max Supply / Non-Mintable
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed 
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH to contract
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}

// Symbol        : MORTY
// Name          : MORTYTOKEN
// Total supply  : 500000
// Decimals      : 18
// Owner Account : 0x246e6fd15EbB6db65FFD4Fe01A4CdE10801b5e9A
// rickandmortyfinance.com
// t.me/rickandmortyfinance
// As follows - 300,000 sent to ICO contract - 50,000 remains in wallet as dev fund unless further decided otherwise - 150,000 initial liquidity