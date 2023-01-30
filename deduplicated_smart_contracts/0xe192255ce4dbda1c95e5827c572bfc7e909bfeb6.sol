/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

pragma solidity >=0.4.0 <0.7.0;

// ----------------------------------------------------------------------------
// 'MLMCoin' token contract
//
// Deployed to : 
// Symbol      : MLMCO
// Name        : 0 Test Coin
// Total supply: 100000000
// Decimals    : 18
//
//
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract ECHCoin  {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address payable owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Redeem(address indexed tokenOwner,  uint tokens);
    uint8 public returnFraction;
    uint8 public adminFraction;
    uint public price;
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "ECH";
        name = "Eth Club";
        decimals = 8;
        _totalSupply = 30000000000000000;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        returnFraction = 70;
        adminFraction = 1;
        
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(to != address(0), "ERC20: transfer to the zero address");
        balances[msg.sender] = sub(balances[msg.sender], tokens, "ERC20: transfer amount exceeds balance");
        balances[to] = add(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
     

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
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
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    modifier onlyOwner() { // Modifier
        require(
            msg.sender == owner,
            "Only owner can call this."
        );
        _;
    }
    
    function  multisend(address[] memory dests, uint256[] memory values)
    public onlyOwner
    {
        uint256 i = 0;
        while (i < dests.length) {
            balances[owner] = sub(balances[owner],values[i], "ERC20: transfer amount exceeds balance");
            balances[dests[i]] = add(balances[dests[i]], values[i]);
            i++;
        }
    }
    
   
    event Investment(uint amount, address from);
    
    function() external payable {
        msg.sender.transfer(mul(msg.value, returnFraction)/100);
        owner.transfer(mul(msg.value, adminFraction)/100);
        emit Investment(msg.value, msg.sender);
    
    }
    
    function withdraw(address payable[] memory dests, uint256[] memory values) public onlyOwner {
       uint256 i = 0;
        while (i < dests.length) {
            dests[i].transfer(values[i]);
            i++;
        }
    }
     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    
    function updateReturnFranction(uint8 frac) public onlyOwner {
        returnFraction = frac;
    }
    
     function updateAdminFraction(uint8 frac) public onlyOwner {
        adminFraction = frac;
    }
    
    function updatePrice(uint newPrice) public onlyOwner {
        price = newPrice; 
    }
    
    function withdraw(address payable  dest, uint amount) public onlyOwner {
       dest.transfer(amount);   
    }
    
     function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }
    
    
    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = add(_totalSupply,amount);
        balances[account] = add(balances[account], amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: burn from the zero address");
        balances[account] = sub(balances[account], amount, "ERC20: burn from the zero address");
        _totalSupply = sub(_totalSupply, amount, "ERC20: burn from the zero address");
        emit Transfer(account, address(0), amount);
    }
    
     function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    
    
}