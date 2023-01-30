/**

 *Submitted for verification at Etherscan.io on 2018-10-20

*/



pragma solidity ^0.4.23;



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



contract ERC20 {

    function totalSupply() public constant returns (uint256);

    function balanceOf(address account) public constant returns (uint256 balance);

    function allowance(address account, address spender) public constant returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens) public returns (bool success);

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

    

    event Transfer(address indexed from, address indexed to, uint256 tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

}



contract Token is ERC20 {

    using SafeMath for uint256;

    

    bytes32 public name = "nBase CryptoGold";

    bytes32 public symbol = "NCG";

    uint8 public decimals = 18;

    

    uint256 public totalSupply;

    address public owner;

    

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    

    constructor() public {

        totalSupply = 100 * 10 ** uint256(decimals);

        owner = msg.sender;

        balances[owner] = totalSupply;

    }

    

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    

    function totalSupply() public constant returns (uint256) {

        return totalSupply;

    }

    

    function balanceOf(address accountAddress) public constant returns (uint256 balance) {

        return balances[accountAddress];

    }

    

    function allowance(address account, address spender) public constant returns (uint256 remaining) {

        return allowances[account][spender];

    }

    

    function transfer(address to, uint256 tokens) public returns (bool success) {

        _transfer(msg.sender, to, tokens);

        return true;

    }

    

    function _transfer(address from, address to, uint256 value) internal {

        // Prevent transfer to 0x0 address.

        require(to != 0x0);

        // Check if the sender has enough

        require(balances[from] >= value);

        // Check for overflows

        require(balances[to] + value > balances[to]);

        // Save this for an assertion in the future

        uint previousBalances = balances[from] + balances[to];

        // Subtract from the sender

        balances[from] -= value;

        // Add the same to the recipient

        balances[to] += value;

        emit Transfer(from, to, value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(balances[from] + balances[to] == previousBalances);

    }

    

    function approve(address spender, uint256 tokens) public returns (bool success) {

        allowances[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }

    

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {

        // Check if they have enough funds in their allowance.

        require(tokens <= allowances[from][msg.sender]);

        allowances[from][msg.sender] = allowances[from][msg.sender].sub(tokens);

        _transfer(from, to, tokens);

        

        return true;

    }

    

    function mintToken(address target, uint256 amount) onlyOwner public {

        balances[target] = balances[target].add(amount);

        totalSupply = totalSupply.add(amount);

        emit Transfer(0, owner, amount);

        emit Transfer(owner, target, amount);

    }

    

    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () public payable {

        revert();

    }

}