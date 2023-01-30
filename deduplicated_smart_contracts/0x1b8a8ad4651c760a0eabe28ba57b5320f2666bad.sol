/**
 *Submitted for verification at Etherscan.io on 2019-10-12
*/

pragma solidity ^0.5.0;

// ----------------------------------------------------------------------------
// 'GLOT' token contract

// Symbol      : GLOT
// Name        : Global Lottery
// Total supply: 9.000.000.000
// Decimals    : 8
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address payable from, address to, uint256 tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
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
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract GlobalLottery is ERC20Interface, Owned {
    using SafeMath for uint256;
    string public symbol = "GLOT";
    string public  name = "GlobalLottery";
    uint256 public decimals = 8;
    uint256 _totalSupply = 9e9* 10 ** uint(decimals);
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    mapping(address => walletDetail) walletsAllocation;

    struct walletDetail{
        uint256 tokens;
        bool lock;
    }

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        owner = address(0x5CF70cBC21FE98B997013Ca31681C8d093F92e17);
        balances[address(this)] = totalSupply();
        emit Transfer(address(0),address(this), totalSupply());

        _makeAllocations();
    }

    function _makeAllocations() private{
        //Team Wallet(Locted 1 years)
        _transfer(0x1F4753Af0CFe2a4ebA516859A8F55982415c2984, 2e9 * 10 ** uint(decimals));
        walletsAllocation[0x1F4753Af0CFe2a4ebA516859A8F55982415c2984] = walletDetail(2e9 * 10 ** uint(decimals), false);
        //Airdrop & Marketing Wallet
        _transfer(0xF8d12cc1b6bdccf2d4E685aCB023D22ae09686B0, 4e9 * 10 ** uint(decimals));
        walletsAllocation[0xF8d12cc1b6bdccf2d4E685aCB023D22ae09686B0] = walletDetail(4e9 * 10 ** uint(decimals), false);
        //Development Wallet (Locked 1 years)
        _transfer(0x9cA93ce4Ae102c6846Ba56dEA92011BC39869CF8, 3e9 * 10 ** uint(decimals));
        walletsAllocation[0x9cA93ce4Ae102c6846Ba56dEA92011BC39869CF8] = walletDetail(3e9 * 10 ** uint(decimals), false);
    }
    
    /** ERC20Interface function's implementation **/
    
    function totalSupply() public view returns (uint256){
       return _totalSupply; 
    }
    
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public returns (bool success) {
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens );
        require(balances[to] + tokens >= balances[to]);

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) public returns (bool success){
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address payable from, address to, uint256 tokens) public returns (bool success){
        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens);

        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from,to,tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function transferFromContract(address to, uint256 tokens) public onlyOwner returns (bool success){
        _transfer(to,tokens);
        return true;
    }

    function _transfer(address to, uint256 tokens) internal {
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[address(this)] >= tokens );
        require(balances[to] + tokens >= balances[to]);
        
        balances[address(this)] = balances[address(this)].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(address(this),to,tokens);
    }

    function openLock(address _address) public onlyOwner{
        // open lock and transfer to respective address
        require(walletsAllocation[_address].lock);
        require(walletsAllocation[_address].tokens > 0);
        require(balances[_address] == 0);

        _transfer(_address, walletsAllocation[_address].tokens);
        walletsAllocation[_address].lock = false;
    }
    
    // ------------------------------------------------------------------------
    // Don't Accepts ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }
}