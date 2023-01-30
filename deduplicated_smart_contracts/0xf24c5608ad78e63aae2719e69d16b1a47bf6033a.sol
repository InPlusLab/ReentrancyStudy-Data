/**

 *Submitted for verification at Etherscan.io on 2018-11-05

*/



pragma solidity 0.4.25;



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

// ERC Token Standard #20 Interface

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

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



}



/**

 * @title MapCoin 

 */

contract MapCoin is ERC20Interface, Owned {

  using SafeMath for uint256;

  string  public symbol; 

  string  public name;

  uint8   public decimals;

  uint    internal _totalSupply;

  

  mapping(address => uint) balances;

  mapping(address => mapping(address => uint)) allowed;

  

    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor (address _owner) public {

        symbol = "MAP";

        name = "MapCoin";

        decimals = 18;

        owner = _owner;

        _totalSupply = 1e9; // 1 billion

        balances[owner] = totalSupply();

        emit Transfer(address(0),owner, totalSupply());

    }

    

    // donot accept any ethers

    function () external payable {

        revert();

    }



    /* ERC20Interface function's implementation */

    function totalSupply() public constant returns (uint){

       return _totalSupply* 10**uint(decimals);

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

        // prevent transfer to 0x0, use burn instead

        require(to != 0x0);

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

    function approve(address spender, uint tokens) public returns (bool success){

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

    function transferFrom(address from, address to, uint tokens) public returns (bool success){

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

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }



}