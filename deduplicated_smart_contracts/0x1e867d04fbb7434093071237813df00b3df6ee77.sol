/**

 *Submitted for verification at Etherscan.io on 2018-10-03

*/



/*03 October 2018 v4.0



                         -+/-           +oo/                             .ooo`

                        -NNNN.          hNNy                             :NNN.

                         +ss/           hNNy                             :NNN.

  `:+o+/.`//-  .//.`:+o. ://:    `:+o+/.hNNy     -/+o+/-  `///.    ://:  :NNN-:+o+/.       -/+++:`

`omNNNNNNmNNs  +NNdmNNN: hNNy   omNNNNNNNNNy   +dNNNNNNN+ .NNN:    hNNs  :NNNNNNNNNNy.   omNNmdmNms`

yNNm/. .+NNNs  +NNNy:..` hNNy  sNNm+. .+mNNy  sNNm+.``-:  .NNN:    hNNs  :NNNy-``:dNNd` yNNd-``.yNNy

NNNo     yNNs  +NNN      hNNy  mNNs     yNNy  mNNs        .NNN:    dNNs  :NNm     :NNN- mNNNNNNNNNNN

yNNm/` .+NNNs  +NNN      hNNy  sNNm/` `/mNNy  sNNm+. `.-  `mNNh:.-oNNNs  :NNNs. `:hNNd` yNNd:`  `/.

`sNNNNNNNNNNs  +NNN      hNNy   omNNNNNNmNNy   +mNNNNNNN+  -dNNNNNNmNNs  :NNmNNNNNNNy.   omNNNmmNNd`

  `:+o+/-mNN+  -++/      :++:    `:+oo/-`++:     -/+o+/-     -/oo+-`++:  .++-`/+o+/.       -/++++:`

  smyoooymNNh`

  .oydmNNmds:





https://gridcube.com has a unique approach to deploying Blockchain technology. Instead of focusing on the blockchain itself,

our breakthrough was discovering that the underlying infrastructure is just as important. Therefore,

we developed a ��Smart Cloud Manager��, a middleware software capable of deploying a blockchain network efficiently,

fast, and optimized for cost. Gridcube Platform Token (GPT) Enables "Coding is Mining" Loyalty and Reward Program

https://ito.gridcube.com. Also works as a way of Payment for Gridcube Services.



03 October 2018 v4.0*/



pragma solidity ^0.4.18;



// ----------------------------------------------------------------------------

// 'Gridcube' token contract

//

// Deployed to : 0X1E867D04FBB7434093071237813DF00B3DF6EE77

// Symbol      : GPT

// Name        : Gridcube Platform Token

// Total supply: 30 000 000

// Decimals    : 18

//

//

//

// ----------------------------------------------------------------------------





// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

contract SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function safeMul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function safeDiv(uint a, uint b) internal pure returns (uint c) {

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

    function currentSupply() public constant returns (uint);

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

// ERC20 Token, with the addition of symbol, name and decimals and assisted

// token transfers

// ----------------------------------------------------------------------------

contract GridcubePlatformToken is ERC20Interface, Owned, SafeMath {

    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;

    uint public _currentSupply;

    uint public startDate;

    uint public bonusEnds;

    uint public endDate;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;





    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    function GridcubePlatformToken() public {

        symbol = "GPT";

        name = "Gridcube Platform Token";

        decimals = 18;

        bonusEnds = now + 2 weeks;

        endDate = now + 12 weeks;

        _totalSupply = 30000000000000000000000000;

        address OwnerAdd = 0xb917cd85b61813ac1cd29ba0a8c37e0cd9f11162;

        uint256 CommunityTokens = 10000000000000000000000000;

        uint256 ProjectTokens = 10000000000000000000000000;

        uint256 HoldTokens = CommunityTokens + ProjectTokens;

        uint256 SaleTokens = safeSub(_totalSupply, HoldTokens);

        balances[OwnerAdd] = HoldTokens;

        Transfer(address(0), OwnerAdd, HoldTokens);

        _currentSupply = SaleTokens;



      }





    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public constant returns (uint) {

        return _totalSupply;

    }



    // ------------------------------------------------------------------------

    // Current supply

    // ------------------------------------------------------------------------

    function currentSupply() public constant returns (uint) {

        return _currentSupply  - balances[address(0)];

    }



    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

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

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

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

    // Transfer `tokens` from the `from` account to the `to` account

    //

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the `from` account and

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

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account. The `spender` contract function

    // `receiveApproval(...)` is then executed

    // ------------------------------------------------------------------------

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }



    // ------------------------------------------------------------------------

    // 180 GRIDCUBE Tokens per 1 ETH

    // ------------------------------------------------------------------------

    function () public payable {

        require(now >= startDate && now <= endDate);

        uint tokens;

        if (now <= bonusEnds) {

            tokens = msg.value * 200;

        } else {

            tokens = msg.value * 180;

        }

        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);

        _currentSupply = safeSub(_currentSupply, tokens);

        Transfer(address(0), msg.sender, tokens);

        owner.transfer(msg.value);

    }







    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}