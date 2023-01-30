/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.4.26;

// ----------------------------------------------------------------------------
// OxHKT Smart Contract
//
// Deployed to : 0x4734972cef6824B7C13C174Fd31108BFa47f6dF3
// Symbol      : OxHKT
// Total Supply: 1,963,993,042,780.251
// Decimals    : 3
//
// Whitepaper:
// https://0xdealer.com/project/OXHKT/whitepaper.pdf
//
// MMMMMMMMMMMMMWNX0kxdoooooooooodxOKXWWMMMMMMMMMMMMM
// MMMMMMMMMMWXOdollloodxxkkkkxxdoolllox0XWMMMMMMMMMM
// MMMMMMMWNOollodkO0OOOOO0O0OOO0000Okdllld0NWMMMMMMM
// MMMMMWXklcoxOOO0OkxkOOOO000O0OxxkOO00OxlclONWMMMMM
// MMMMNOlcokO000Odc:lk0OO0000O0Okl;cxOOO0Oko:l0NMMMM
// MMWXd:lkOO00Od;.'oO0OO00O00000OOl..:xOOO0Okl:xXWMM
// MWKo:dOO00OOl. .dO00O00OOOO00O0OOo. .oOOOOOOo:dXWM
// WKl:xO00OO0x'  .dOOkoc:::;::cokOOo.  ,k0OOO0Od:dXW
// Xd:dOOO0OO0k,   .',,;cloodol:,,,..   :k0OOOO0Oo:xN
// O:cO0OO00O00x:.   ,dO00OO00OOOo'   .:kO00OO000kccK
// d:d00OOkoc::::,. 'x0OO0OOOOOO00d. .;:::clokOOOOo:k
// l:x00Ox,         'xOO0OOO00OO0Od.         ;k0O0d:d
// l:k0OOkc'.'',,:'.'lodOOO00OOOdlc..,:,,'.',lO000x:o
// o:x000OOOOOOOO0x,';..cO0OO0k:..;';k0OOOOOOOO000d:d
// k:oO0OOOOO0OOOOOc.   .d0O00o.   .lOOOOO000OOOOOl:O
// Kl:k0OO0OOO0OOO0d.   .lOO0Oc    'x0OOOOO00OOO0x:oX
// WO:lO0O0OOOOOOO0k,   .lOO0Oc    ;O0OOOO0OOO00kcc0W
// MNx:lOOOOOOOOOO0O:  .cdddddo:.  cOOO0OO0OOO0kc:kNM
// MMNk:ckOOOOOOOOOOc.'lo:.  .coc..lOO00OOOOOOxccONMM
// MMMN0l:oO0OOOOOOOd,'cl:....cl:',x0O0OO000ko:oKWMMM
// MMMMWXkccokOOOOO0Oxl:c:;;;;:c:lkOOO0OOOkoclkNWMMMM
// MMMMMMWXklcldkO000OOOkkxxxxkOO0O0OOOkdlcoOXWMMMMMM
// MMMMMMMMWN0xlllodkOOOO00OOO000OOxdolllxKNWMMMMMMMM
// MMMMMMMMMMMWNKOdolllllllooolllllloxOXNWMMMMMMMMMMM
// MMMMMMMMMMMMMMMWNX0OxdollllodxOKXNWMMMMMMMMMMMMMMM
// 
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
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


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
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


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract OxHKT is ERC20Interface, Owned, SafeMath {
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
        symbol = "OxHKT";
        name = "OxHKT";
        decimals = 3;
        _totalSupply = 1963993042780251;
        balances[0x4734972cef6824B7C13C174Fd31108BFa47f6dF3] = _totalSupply;
        emit Transfer(0x4734972cef6824B7C13C174Fd31108BFa47f6dF3, 0x4734972cef6824B7C13C174Fd31108BFa47f6dF3, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
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
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
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
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}