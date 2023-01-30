pragma solidity ^0.5.0;

import './SafeMathLib.sol';

contract HipToken {
    using SafeMathLib for uint;

    mapping (address => uint) public balances;
    mapping (address => uint) public frozenBalances;
    mapping (address => mapping (address => uint)) public allowed;
    mapping (uint => FrozenTokens) public frozenTokensMap;

    event Transfer(address indexed sender, address indexed receiver, uint value);
    event Approval(address approver, address spender, uint value);
    event TokensFrozen(address indexed freezer, uint amount, uint id, uint lengthFreezeDays);
    event TokensUnfrozen(address indexed unfreezer, uint amount, uint id);
    event TokensBurned(address burner, uint amount);

    uint constant public decimals = 18;
    uint public totalSupply;
    uint public numCoinsFrozen;
    uint numFrozenStructs;

    struct FrozenTokens {
        uint id;
        uint dateFrozen;
        uint lengthFreezeDays;
        uint amount;
        bool frozen;
        address owner;
    }

    constructor(address bank, uint initialBalance) public {
        balances[bank] = initialBalance;
        totalSupply = initialBalance;
    }

    function freeze(uint amount, uint freezeDays) public {
        balances[msg.sender] = balances[msg.sender].minus(amount);
        frozenBalances[msg.sender] = frozenBalances[msg.sender].plus(amount);
        numFrozenStructs = numFrozenStructs.plus(1);
        numCoinsFrozen = numCoinsFrozen.plus(amount);
        frozenTokensMap[numFrozenStructs] = FrozenTokens(numFrozenStructs, now, freezeDays, amount, true, msg.sender);
        emit TokensFrozen(msg.sender, amount, numFrozenStructs, freezeDays);
    }

    function unFreeze(uint id) public {
        FrozenTokens storage f = frozenTokensMap[id];
        require(f.dateFrozen + (f.lengthFreezeDays * 1 days) < now, 'May not unfreeze until freeze time is up');
        require(f.frozen, 'Can only unfreeze frozen tokens');
        f.frozen = false;
        frozenBalances[f.owner] = frozenBalances[f.owner].minus(f.amount);
        balances[f.owner] = balances[f.owner].plus(f.amount);
        numCoinsFrozen = numCoinsFrozen.minus(f.amount);
        emit TokensUnfrozen(f.owner, f.amount, id);
    }

    function burn(uint amount) public {
        balances[msg.sender] = balances[msg.sender].minus(amount);
        totalSupply = totalSupply.minus(amount);
        emit TokensBurned(msg.sender, amount);
    }

    function transfer(address to, uint value) public returns (bool success)
    {
        // deduct
        balances[msg.sender] = balances[msg.sender].minus(value);
        // add
        balances[to] = balances[to].plus(value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool success)
    {
        uint allowance = allowed[from][msg.sender];

        // deduct
        balances[from] = balances[from].minus(value);

        // add
        balances[to] = balances[to].plus(value);

        // adjust allowance
        allowed[from][msg.sender] = allowance.minus(value);

        emit Transfer(from, to, value);
        return true;
    }

    function balanceOf(address owner) public view returns (uint balance) {
        return balances[owner];
    }

    function frozenBalanceOf(address owner) public view returns (uint balance) {
        return frozenBalances[owner];
    }

    function approve(address spender, uint value) public returns (bool success)
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint remaining) {
        return allowed[owner][spender];
    }

}
