/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity 0.5.11;

// ----------------------------------------------------------------------------
// 'MES' token contract

// Symbol      : MES
// Name        : MesChain
// Total supply: 7.000.000.000
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
contract MesChain is ERC20Interface, Owned {
    using SafeMath for uint256;
    string public symbol = "MES";
    string public  name = "MesChain";
    uint256 public decimals = 8;
    uint256 _totalSupply = 7e9* 10 ** uint(decimals);
    
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
        owner = address(0x51a8d35f1eF9835950D0EA0e1151203BfD537d26);
        balances[address(this)] = totalSupply();
        emit Transfer(address(0),address(this), totalSupply());

        _makeAllocations();
    }

    function _makeAllocations() private{
        // ICO Wallet 
        _transfer(0xe7DfFc4B83e4F70A28eC4eFB36c4e2703Abcf6d0, 1e9 * 10 ** uint(decimals));
        walletsAllocation[0xe7DfFc4B83e4F70A28eC4eFB36c4e2703Abcf6d0] = walletDetail(1e9 * 10 ** uint(decimals), false);
        //IEO Wallet
        _transfer(0x932A34B04712F8B2eEC3818754413262d19d2deA, 1e9 * 10 ** uint(decimals));
        walletsAllocation[0x932A34B04712F8B2eEC3818754413262d19d2deA] = walletDetail(1e9 * 10 ** uint(decimals), false);
        //Team Wallet
        walletsAllocation[0x9f83a70b2F40c5fC3068bb4d6F72B36aCEb7EAFE] = walletDetail(1e9 * 10 ** uint(decimals), true);
        //Project Development Wallet
        walletsAllocation[0x9E79CA12AA7EfBF7DA72fE4177e00f6154Ce1849] = walletDetail(1e9 * 10 ** uint(decimals), true);
        //Stock Market and Promotion Wallet
        walletsAllocation[0x7498fFa99dD8eEe28946985757dAac366BC1A0A2] = walletDetail(13e8 * 10 ** uint(decimals), true);
        //Agents Wallet
        walletsAllocation[0x7a2A0Be3352ca8D9d0EbB3Bdc1e73bBB504e195A] = walletDetail(5e8 * 10 ** uint(decimals), true);
        //Marketing Wallet
        _transfer(0xE60B984Aa73f92D0c687Cff7Ed4869ca871Af04E, 5e8 * 10 ** uint(decimals));
        walletsAllocation[0xE60B984Aa73f92D0c687Cff7Ed4869ca871Af04E] = walletDetail(5e8 * 10 ** uint(decimals), false);
        //Award Distribution Wallet
        _transfer(0x569D39944c179F5c82914a0BAd2c684A8090f063, 35e7 * 10 ** uint(decimals));
        walletsAllocation[0x569D39944c179F5c82914a0BAd2c684A8090f063] = walletDetail(35e7 * 10 ** uint(decimals), false);
        //Stake Wallet
        _transfer(0x23dC2A8EaEba7711A613E0F06a409dBC30eCAdb5, 35e7 * 10 ** uint(decimals));
        walletsAllocation[0x23dC2A8EaEba7711A613E0F06a409dBC30eCAdb5] = walletDetail(35e7 * 10 ** uint(decimals), false);
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