/**

 *Submitted for verification at Etherscan.io on 2018-09-29

*/



pragma solidity ^0.4.7;



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



    function Owned() public {

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

        OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}





// ----------------------------------------------------------------------------

// Social Note

// ----------------------------------------------------------------------------

contract SocialNote is ERC20Interface, Owned, SafeMath {

    string public  name;

    string public symbol;

    uint8 public decimals;

    uint public _totalSupply;

    uint public _tokens;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



  	struct TokenLock {

      uint8 id;

      uint start;

      uint256 totalAmount;

      uint256 amountWithDrawn;

      uint duration;

      uint8 withdrawSteps;

    }



    TokenLock public futureLock = TokenLock({

        id: 1,

        start: now,

        totalAmount: 7000000000000000000000000000,

        amountWithDrawn: 0,

        duration: 90 days,

        withdrawSteps: 4

    });



    function SocialNote() public {

        symbol = "SON";

        name = "Social Note";

        decimals = 18;



        _totalSupply = 10000000000* 10**uint(decimals);



        balances[owner] = _totalSupply;

        Transfer(address(0), owner, _totalSupply);



        lockTokens(futureLock);

    }



    function lockTokens(TokenLock lock) internal {

        balances[owner] = safeSub(balances[owner], lock.totalAmount);

        balances[address(0)] = safeAdd(balances[address(0)], lock.totalAmount);

        Transfer(owner, address(0), lock.totalAmount);

    }



    function withdrawLockedTokens() external onlyOwner {

        if(unlockTokens(futureLock)){

          futureLock.start = now;

        }

    }



	  function unlockTokens(TokenLock lock) internal returns (bool) {

        uint lockReleaseTime = lock.start + lock.duration;



        if(lockReleaseTime < now && lock.amountWithDrawn < lock.totalAmount) {

            if(lock.withdrawSteps > 1){

                _tokens = safeDiv(lock.totalAmount, lock.withdrawSteps);

            }else{

                _tokens = safeSub(lock.totalAmount, lock.amountWithDrawn);

            }



            if(lock.id==1 && lock.amountWithDrawn < lock.totalAmount){

              futureLock.amountWithDrawn = safeAdd(futureLock.amountWithDrawn, _tokens);

            }



            balances[owner] = safeAdd(balances[owner], _tokens);

            balances[address(0)] = safeSub(balances[address(0)], _tokens);

            Transfer(address(0), owner, _tokens);



            return true;

        }

        return false;

    }



    // ------------------------------------------------------------------------

    // Batch token transfer

    // ------------------------------------------------------------------------

    function batchTransfer(address[] _recipients, uint p_tokens) public onlyOwner returns (bool) {

        require(_recipients.length > 0);

        p_tokens = p_tokens * 10**uint(decimals);

        require(p_tokens <= balances[msg.sender]);



        for(uint j = 0; j < _recipients.length; j++){



            balances[_recipients[j]] = safeAdd(balances[_recipients[j]], p_tokens);

            balances[owner] = safeSub(balances[owner], p_tokens);

            Transfer(owner, _recipients[j], p_tokens);

        }

        return true;

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

    function approve(address spender, uint tokens) public returns (bool success) {

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

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

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

        Approval(msg.sender, spender, tokens);

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