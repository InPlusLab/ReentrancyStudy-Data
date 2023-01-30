/**

 *Submitted for verification at Etherscan.io on 2018-09-09

*/



pragma solidity ^0.4.24;

//Spielleys Profit Allocation Share Module

//In an effort to crowdfund myself to go fulltime dapp development,

//I hereby created this contract to sell +/- 90% of future games dev fees 

// Future P3D contract games made will have a P3D masternode setup for the uint

// builder. Dev fee will consist of 1% of P3D divs gained in those contracts.

// contract will mint shares/tokens as you buy them

// Shares connot be destroyed, only traded.

// use function buyshares to buy Shares

// use function fetchdivs to get divs outstanding

// read dividendsOwing(your addres) to see how many divs you have outstanding

// Thank you for playing Spielleys contract creations.

// speilley is not liable for any contract bugs known and unknown.

//



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

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

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220;

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

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

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

//

// Borrowed from MiniMeToken

// ----------------------------------------------------------------------------

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}



// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and a

// fixed supply

// ----------------------------------------------------------------------------

contract FixedSupplyToken is ERC20Interface, Owned {

    using SafeMath for uint;



    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;





    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor() public {

        symbol = "SPASM";

        name = "Spielleys Profit Allocation Share Module";

        decimals = 0;

        _totalSupply = 1;

        balances[owner] = _totalSupply;

        emit Transfer(address(0),owner, _totalSupply);

        

    }





    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public view returns (uint) {

        return _totalSupply.sub(balances[address(0)]);

    }





    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) updateAccount(to) updateAccount(msg.sender) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

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

        emit Approval(msg.sender, spender, tokens);

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

    function transferFrom(address from, address to, uint tokens)updateAccount(to) updateAccount(from) public returns (bool success) {

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

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account. The `spender` contract function

    // `receiveApproval(...)` is then executed

    // ------------------------------------------------------------------------

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }











    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }



// divfunctions

//divsection

uint256 public pointMultiplier = 10e18;

struct Account {

  uint balance;

  uint lastDividendPoints;

}

mapping(address=>Account) accounts;

uint public ethtotalSupply;

uint public totalDividendPoints;

uint public unclaimedDividends;



function dividendsOwing(address account) public view returns(uint256) {

  uint256 newDividendPoints = totalDividendPoints.sub(accounts[account].lastDividendPoints);

  return (balances[account] * newDividendPoints) / pointMultiplier;

}

modifier updateAccount(address account) {

  uint256 owing = dividendsOwing(account);

  if(owing > 0) {

    unclaimedDividends = unclaimedDividends.sub(owing);

    

    account.transfer(owing);

  }

  accounts[account].lastDividendPoints = totalDividendPoints;

  _;

}

function () external payable{disburse();}

function fetchdivs() public updateAccount(msg.sender){}

function disburse() public  payable {

    uint256 amount = msg.value;

    

  totalDividendPoints = totalDividendPoints.add(amount.mul(pointMultiplier).div(_totalSupply));

  //ethtotalSupply = ethtotalSupply.add(amount);

 unclaimedDividends = unclaimedDividends.add(amount);

}

function buyshares() public updateAccount(msg.sender) updateAccount(owner)  payable{

    uint256 amount = msg.value;

    address sender = msg.sender;

    uint256 sup = _totalSupply;//totalSupply

    require(amount >= 10 finney);

    uint256 size = amount.div( 10 finney);

    balances[owner] = balances[owner].add(size);

     emit Transfer(0,owner, size);

    sup = sup.add(size);

     size = amount.div( 1 finney);

    balances[msg.sender] = balances[sender].add(size);

    emit Transfer(0,sender, size);

     _totalSupply =  sup.add(size);

     owner.transfer(amount);

}

}