/**
 *Submitted for verification at Etherscan.io on 2019-08-31
*/

/**
 * @author BruceChar
 * @time 2019-7-15
 */

pragma solidity ^0.5.0;



contract owned {
    address payable internal owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Limited authority!");
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public {
        owner = newOwner;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/******************************************/
/*      TOKEN INSTANCE STARTS HERE       */
/******************************************/

contract TokenFactory is owned, ERC20Interface {
    
    using SafeMath for uint256;
    //variables of the token
    string public name;
    string public symbol;
    uint8 public decimals;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 private _initSupply;
    uint256 private ethRate;   

    uint256 private sellPrice;
    uint256 private buyPrice;
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    mapping (address => bool) private frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);
    event BurnTokens(address target, uint256 tokens);
    event MultiTransferFail(address target, uint256 tokens);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor (address payable _owner)
        public
    {
        name = "Transparent Value Broadcasting Token";
        symbol = "TVB";
        decimals = 8;
        _initSupply = uint256(1000000000).mul(uint(10) ** decimals);
        owner = _owner;
        ethRate = uint(18).sub(decimals);
        sellPrice = 500000; //1eth == 20000 token
        buyPrice = 500000; //1eth == 20000 token
        balances[owner] = _initSupply;
        emit Transfer(address(0), owner, _initSupply);
    }
    
    /* override the ERC20Interface methods */
    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _initSupply.sub(balances[address(0)]);
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
        _transfer(msg.sender, to, tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function multiTransfer(address[] memory tos, uint[] memory tokens) public returns(bool) {
        require(tos.length == tokens.length, "Number of address doesn't match the tokens!");
        for (uint i = 0; i < tos.length; i++) {
            bool flag = transfer(tos[i], tokens[i]);
            if (!flag) {
                emit MultiTransferFail(tos[i], tokens[i]);
                continue;
            }
        }
        
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
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
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
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != address(0x0));  // Prevent transfer to 0x0 address. Use burn() instead
        require(_from != _to, "The target account cannot be same with the source account!");
        require (balances[_from] >= _value, "No enough balance to transfer!");               // Check if the sender has enough
        require (balances[_to] + _value >= balances[_to], "Overflows!"); // Check for overflows
        require(!frozenAccount[_from], "Account is frozen!");                     // Check if sender is frozen
        require(!frozenAccount[_to], "Account is frozen!");                       // Check if recipient is frozen
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the sender
        balances[_to] = balances[_to].add(_value);                           // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = balances[target].add(mintedAmount);
        _initSupply = _initSupply.add(mintedAmount);
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        require(target != owner, "Cannot freeze owner account!");
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        
        require(msg.value > 0 && buyPrice > 0, "Cannot buy with 0 ethers, or buyPrice hasn't been set!");
        uint amount = msg.value.div(buyPrice);               // calculates the amount
        _transfer(owner, msg.sender, amount);              // makes the transfers
        owner.transfer(msg.value);
        
    }

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    // todo: cannot sell 
    function sell(uint256 amount) public {
        require(sellPrice > 0, "The sellPrice is not set yet!");
        require(amount > 0, "Amount cannot be 0!");
        require (owner.balance >= amount * sellPrice, "No enough balance to sell!");      // checks if the contract has enough ether to buy
        _transfer(msg.sender, owner, amount);              // makes the transfers
        msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
    
    function burn(address account, uint256 tokens) onlyOwner public {
        uint256 bal = balances[account];
        require(bal > 0 && tokens <= bal, "No enough balance to burn!");
        require(!frozenAccount[account], "Account is frozen!");
        balances[account] = bal.sub(tokens);
        emit BurnTokens(account, tokens);
    }
    
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    // ------------------------------------------------------------------------
    // fallback function: Don't accept ETH
    // ------------------------------------------------------------------------
    function ICO() external payable {
        /**
         * if we want to set the price linely
         */
        
        //rate adjustment
        uint tokens = msg.value.div(10 ** ethRate).mul(20000); // 1eth == 20000 token
        _transfer(owner, msg.sender, tokens);
        emit Transfer(owner, msg.sender, tokens);
        owner.transfer(msg.value);
        
        // revert();
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 sum) {
        sum = a + b;
        require(sum >= a, "SafeMath: addition overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256 division) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        division = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256 modulo) {
        require(b != 0, "SafeMath: modulo by zero");
        modulo = a % b;
    }
}



// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}