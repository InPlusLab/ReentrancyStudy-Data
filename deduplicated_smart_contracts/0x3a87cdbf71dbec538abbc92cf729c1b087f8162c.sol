pragma solidity ^0.5.7;



import './IERC20.sol';

import './SafeMath.sol';



contract Pure24KGoldWave is IERC20 {

    using SafeMath for uint;

    

    string public constant name = 'Pure 24K Gold Wave';

    string public constant symbol = 'GWC';

    uint8 public constant decimals = 18;

    

    uint public _totalSupply = 0;

    uint public constant maxSupply = 25000000 * (10 ** uint256(decimals));

    

    // 1 ETH = 7 GWC and 1 GWC = 0.12 ETH

    uint public constant RATE = 7;

    

    address payable public owner;

    

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    

    constructor() public {

        owner = msg.sender;

    }

    

    function () external payable {

        createTokens();

    }

    

    function createTokens() public payable {

        require(msg.value > 0 && _totalSupply < maxSupply);

        

        uint requestedTokens = msg.value.mul(RATE);

        uint tokens = requestedTokens;

        uint newTokensCount = _totalSupply.add(requestedTokens);

        

        if (newTokensCount > maxSupply) {

            tokens = maxSupply - _totalSupply;

        }

        

        if (tokens > 0) {

            balances[msg.sender] = balances[msg.sender].add(tokens);

            _totalSupply = _totalSupply.add(tokens);

            

            owner.transfer(msg.value);

        }

    }

    

    function totalSupply() public view returns(uint) {

        return _totalSupply;

    }

    

    function balanceOf(address tokenOwner) public view returns (uint currentBalance) {

        return balances[tokenOwner];

    }

    

    function transfer(address to, uint tokens) public returns (bool success) {

        require(

            msg.data.length >= (2 * 32) + 4 &&

            tokens > 0 &&

            balances[msg.sender] >= tokens

        );

        

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        

        emit Transfer(msg.sender, to, tokens);



        return true;

    }

    

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        require(

            msg.data.length >= (3 * 32) + 4 &&

            tokens > 0 &&

            balances[from] >= tokens &&

            allowed[from][msg.sender] >= tokens

        );

        

        balances[from] = balances[from].sub(tokens);

        balances[to] = balances[to].add(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);



        emit Transfer(from, to, tokens);



        return true;

    }

    

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }

    

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }

    

    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}