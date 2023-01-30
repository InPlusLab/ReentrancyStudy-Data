/**

 *Submitted for verification at Etherscan.io on 2019-03-05

*/



pragma solidity ^0.4.18;



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

contract SafeMath {

    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {

        c = a + b;

        require(c >= a);

    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {

        require(b <= a);

        c = a - b;

    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {

        require(b > 0);

        c = a / b;

    }

}





// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public constant returns (uint256);

    function balanceOf(address tokenOwner) public constant returns (uint256 balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens) public returns (bool success);

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint256 tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

}





// ----------------------------------------------------------------------------

// Contract function to receive approval and execute function in one call

//

// Borrowed from MiniMeToken

// ----------------------------------------------------------------------------

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    //address public newOwner;



    //event OwnershipTransferred(address indexed _from, address indexed _to);

    //event OwnershipTransferInitiated(address indexed _to);



    function Owned() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    

/*

    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

        OwnershipTransferInitiated(_newOwner);

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        owner = newOwner;

        OwnershipTransferred(owner, newOwner);

        newOwner = address(0);

    }

    function resetOwner() public onlyOwner{

        newOwner = address(0);

    }

    */

}





// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and assisted

// token transfers

// ----------------------------------------------------------------------------

contract Coin4Cast is ERC20Interface, Owned, SafeMath {

    string public symbol;

    string public  name;

    uint8 public decimals;

    uint256 public _totalSupply;



    mapping(address => uint256) internal balances;

	mapping (address => uint256) internal freezeOf;

    mapping(address => mapping(address => uint256)) internal allowed;





    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    function Coin4Cast() public {

        symbol = 'C4C';

        name = 'Coin4Cast';

        decimals = 10;

        _totalSupply = 1000000000000000000;

        balances[msg.sender] = _totalSupply;

        Transfer(address(0), msg.sender, _totalSupply);

    }





    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public constant returns (uint256) {

        return _totalSupply  - balances[address(0)];

    }





    // ------------------------------------------------------------------------

    // Get the token balance for account tokenOwner

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public constant returns (uint256 balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to to account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint256 tokens) public returns (bool success) {

        if (to == 0x0) revert();                               // Prevent transfer to 0x0 address. Use burn() instead

		if (tokens <= 0) revert(); 

		require(msg.sender != address(0) && msg.sender != to);

	    require(to != address(0));

        if (balances[msg.sender] < tokens) revert();           // Check if the sender has enough

        if (balances[to] + tokens < balances[to]) revert(); // Check for overflows

        balances[msg.sender] = safeSub(balances[msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        Transfer(msg.sender, to, tokens);

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

    function approve(address spender, uint256 tokens) public returns (bool success) {

        require(tokens > 0); 

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

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

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {

        if (to == 0x0) revert();                                // Prevent transfer to 0x0 address. Use burn() instead

		if (tokens <= 0) revert(); 

        if (balances[from] < tokens) revert();                 // Check if the sender has enough

        if (balances[to] + tokens < balances[to]) revert();  // Check for overflows

        if (tokens > allowed[from][msg.sender]) revert();     // Check allowance

        balances[from] = safeSub(balances[from], tokens);

        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        Transfer(from, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {

        return allowed[tokenOwner][spender];

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for spender to transferFrom(...) tokens

    // from the token owner's account. The spender contract function

    // receiveApproval(...) is then executed

    // ------------------------------------------------------------------------

    function approveAndCall(address spender, uint256 tokens, bytes data) public returns (bool success) {

        require(tokens > 0);

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }





	// can accept ether

	function() public payable {

	    //revert(); //disable receive ether

    }



	// transfer balance to owner

	/*

	function withdrawEther(uint256 amount)  public onlyOwner returns (bool success){

		owner.transfer(amount);

		return true;

	}*/



    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}