/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.10;

// GOA TOKEN 

/* 

Deflationary token to be used in the Eggoa game (name TBD) to be released on Ethereum by mid-2020.

When the Eggoa game releases, token holders will be able to mint unique NFTs by destroying Goa tokens.
(1 GOA = 1 NFT)
Additionally, Goa tokens may be used as voting rights, as well as other game advantages.

Goa tokens can be bought directly from the contract, for a rising price proportional to the number of tokens sold.
Each Goa token costs +0.000001 ETH.
Token #2000 will cost 0.002 ETH, token #5000 will cost 0.005 ETH, token #18000 will cost 0.018 ETH, and so on.
Contract only sells tokens as integers, but tokens can be traded as decimals.

----------------------------------------------------------------------------
Goa Token URL = https://eggforce.github.io/goatoken (subject to change)
Discord link = https://discord.gg/JU8P4Ru (probably permanent)
Tweet @ me and take credit for being the one guy who reads smart contracts = @eskaroy
----------------------------------------------------------------------------

*/

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------

contract ERC20Interface {

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
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------

contract Owned {

    address payable public owner;
    address payable public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "must be owner");
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner, "must be new owner");
        
        owner = newOwner;
        newOwner = address(0);

        emit OwnershipTransferred(owner, newOwner);
    }
}

// ----------------------------------------------------------------------------
// Standard ERC20 Token contract, with extra functions for minting new tokens
// ----------------------------------------------------------------------------

contract GoaToken is ERC20Interface, Owned {

    using SafeMath for uint;

    string constant public symbol       = "GOA";
    string constant public name         = "Goa Token";
    uint constant public decimals       = 18;
    uint constant public MAX_SUPPLY     = 200000 * 10 ** decimals;
    uint constant public ETH_PER_TOKEN  = 0.000001 ether;
    
    uint public totalSupply; //initially set to 0, tokens are minted through buying from the contract
	uint public mintSupply; //tracks minted tokens, not affected by burns
	
	bool public contractActive; //tokens can only be minted when this is true

    mapping(address => uint) public balanceOf; // token balance
    mapping(address => mapping(address => uint)) public allowance;
    
    event Minted(address indexed newHolder, uint eth, uint tokens);
    event Burned(address indexed burner, uint tokens);

    //-- constructor
    constructor() public {
		contractActive = true;
    }

    //-- transfer
    // Transfer "tokens" from token owner's account to "to" account
    // Owner's account must have sufficient balance to transfer
    // 0 value transfers are allowed

    function transfer(address to, uint tokens) public returns (bool success) {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(tokens);
        balanceOf[to] = balanceOf[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    //-- approve
    // Token owner can approve for "spender" to transferFrom(...) or burn(...) "tokens"
    // from the token owner's account
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces

    function approve(address spender, uint tokens) public returns (bool success) {
        allowance[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    //-- transferFrom
    // Transfer "tokens" tokens from the "from" account to the "to" account
    // From account must have sufficient balance to transfer
    // Spender must have sufficient allowance to transfer
    // 0 value transfers are allowed

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balanceOf[from] = balanceOf[from].sub(tokens);
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(tokens);
        balanceOf[to] = balanceOf[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;
    }

    //-- approveAndCall
    // Token owner can approve for "spender" to transferFrom(...) "tokens" tokens
    // from the token owner's account. The "spender" contract function
    // "receiveApproval(...)"" is then executed

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowance[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);

        return true;
    }

    //-- mint
    // Transfer ETH to receive a given amount of tokens in exchange
    // Token amount must be integers, no decimals
    // Current token cost is determined through computeCost, frontend sets the proper ETH amount to send

    function mint(uint fullToken) public payable {
        require(contractActive == true, "token emission has been disabled");
        
        uint _token = fullToken.mul(10 ** decimals);
        uint _newSupply = mintSupply.add(_token);
        require(_newSupply <= MAX_SUPPLY, "no more than 200 000 GOA can be minted");

        uint _ethCost = computeCost(fullToken);
        require(msg.value == _ethCost, "wrong ETH amount for tokens");
        
        owner.transfer(msg.value);
        totalSupply = totalSupply.add(_token);
		mintSupply = _newSupply;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_token);
        
        emit Minted(msg.sender, msg.value, fullToken);
    }
    
	//-- burn
	// Remove fullToken from sender
	// Lower totalSupply accordingly
	
	function burn(uint fullToken) public returns (bool success) {
		uint _token = fullToken.mul(10 ** decimals);
		require(balanceOf[msg.sender] >= _token, "not enough tokens to burn");
		
	    totalSupply = totalSupply.sub(_token);	
		balanceOf[msg.sender] = balanceOf[msg.sender].sub(_token);
		
		emit Burned(msg.sender, fullToken);
		
		return true;
    }
    
    //-- burnFrom
    // Remove fullToken from account
    // Sender must have fullToken * decimals allowance from account
    // Lower totalSupply accordingly
    
    function burnFrom(address _from, uint fullToken) public returns (bool success) {
        uint _token = fullToken.mul(10 ** decimals);
        require(allowance[_from][msg.sender] >= _token, "allowance too low to burn this many tokens");
        require(balanceOf[_from] >= _token, "not enough tokens to burn");
        
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_token);
        balanceOf[_from] = balanceOf[_from].sub(_token);
        totalSupply = totalSupply.sub(_token);
        
        emit Burned(_from, fullToken);
        
        return true;
    }
	
	//-- stopEmission
	// Blocks new tokens from being minted
	
	function stopEmission() public onlyOwner returns (bool success) {
		contractActive = false;
		
		return true;
	}
	
    //-- computeSum
    // Return (n * n+1) / 2 sum starting at a and ending at b, excluding a
    
    function computeSum(uint256 a, uint256 b) public pure returns(uint256) {
        uint256 _sumA = a.mul(a.add(1)).div(2);
        uint256 _sumB = b.mul(b.add(1)).div(2);
        return _sumB.sub(_sumA);
    }
    
    //-- computeCost
    // Return ETH cost to buy given amount of full tokens (no decimals)
    
    function computeCost(uint256 fullToken) public view returns(uint256) {
        uint256 _intSupply = mintSupply.div(10 ** decimals);
        uint256 _current = fullToken.add(_intSupply);
        uint256 _sum = computeSum(_intSupply, _current);
        return ETH_PER_TOKEN.mul(_sum);
    }
        
    //-- transferAnyERC20Token
    // Owner can transfer out any accidentally sent ERC20 tokens

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}