pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

// ----------------------------------------------------------------------------
// 'Sports Betting Marketplace' token contract

// Symbol      : SBX
// Name        : Sports Betting Marketplace
// Total supply: 200,000,000 (200 million) (30 million locked, 100K released weekly)
// Decimals    : 18
// ----------------------------------------------------------------------------

import './SafeMath.sol';
import './ERC20contract.sol';
import './Owned.sol';

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract SBX_TOKEN is ERC20Interface, Owned {
    using SafeMath for uint256;
    string public symbol = "SBX";
    string public  name = "Sports Betting Marketplace";
    uint256 public decimals = 18;
    uint256 _totalSupply = 2e8* 10 ** (decimals);  // 200 million

    uint256 public lockedTokens;
    uint256 _contractStartTime;
    uint256 _lastUpdated;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        owner = 0xe93ae81fe7Fa777DE976876BC276218e0C292d48;
        balances[owner] = totalSupply();
        
        lockedTokens = 3e7 * 10 ** (decimals); // 30 million
        _contractStartTime = now;
        
        emit Transfer(address(0),address(owner), totalSupply());
    }
    
    /** ERC20Interface function's implementation **/
    
    // ------------------------------------------------------------------------
    // Get the total supply of the tokens
    // ------------------------------------------------------------------------
    function totalSupply() public override view returns (uint256){
       return _totalSupply; 
    }
    
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public override returns (bool success) {
        // unlock tokens update
        unlockTokens();
        
        // prevent transfer to 0x0, use burn instead
        require(address(to) != address(0));
        require(balances[msg.sender] >= tokens);
        require(balances[to] + tokens >= balances[to]);
        if(msg.sender == owner){
            require(balances[msg.sender].sub(tokens) >= lockedTokens);
        }
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        
        emit Transfer(msg.sender,to,tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens) public override returns (bool success){
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
    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success){
        // unlock tokens update
        unlockTokens();
        
        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens);
        if(from == owner){
            require(balances[msg.sender].sub(tokens) >= lockedTokens);
        }
            
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
    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
    
    // ------------------------------------------------------------------------
    // Helper function to unlock tokens if applicable
    // ------------------------------------------------------------------------
    function unlockTokens() internal{
        // release tokens from lock, depending on current time
        uint256 timeFrame = 7 days; // 1 week
        uint256 relativeTimeDifference = (now.sub(_contractStartTime)).div(timeFrame);
        if(relativeTimeDifference > _lastUpdated){
            uint256 tokensToRelease = (relativeTimeDifference.sub(_lastUpdated)).mul(1e5 * 10 ** (decimals)); // 100K released per week
            lockedTokens = lockedTokens.sub(tokensToRelease);
            _lastUpdated = relativeTimeDifference;
        }
        
    }
}
// "SPDX-License-Identifier: UNLICENSED "
pragma solidity ^0.6.0;
// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}
// "SPDX-License-Identifier: UNLICENSED "
pragma solidity ^0.6.0;
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}
// "SPDX-License-Identifier: UNLICENSED "
pragma solidity ^0.6.0;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}
