pragma solidity ^0.5.0;
import './SafeMathLib.sol';


contract HipToken {
    using SafeMathLib for uint;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    mapping (uint => FrozenTokens) public frozenTokensMap;

    event Transfer(address indexed sender, address indexed receiver, uint value);
    event Approval(address approver, address spender, uint value);
    event TokensFrozen(address indexed freezer, uint amount, uint id, uint lengthFreezeDays);
    event TokensUnfrozen(address indexed unfreezer, uint amount, uint id);
    event TokensBurned(address burner, uint amount);

    uint8 constant public decimals = 18;
    string constant public symbol = "HIP";
    string constant public name = "HiP Token";
    uint public totalSupply;
    uint numFrozenStructs;

    struct FrozenTokens {
        uint id;
        uint dateFrozen;
        uint lengthFreezeDays;
        uint amount;
        bool frozen;
        address owner;
    }

    // simple initialization, giving complete token supply to one address
    constructor(address bank, uint initialBalance) public {
        require(bank != address(0), 'Must initialize with nonzero address');
        balances[bank] = initialBalance;
        totalSupply = initialBalance;
        emit Transfer(address(0), bank, initialBalance);
    }

    // freeze tokens for a certain number of days
    function freeze(uint amount, uint freezeDays) public {
        require(amount > 0, 'Cannot freeze 0 tokens');
        // move tokens into this contract's address from sender
        balances[msg.sender] = balances[msg.sender].minus(amount);
        balances[address(this)] = balances[address(this)].plus(amount);
        numFrozenStructs = numFrozenStructs.plus(1);
        frozenTokensMap[numFrozenStructs] = FrozenTokens(numFrozenStructs, now, freezeDays, amount, true, msg.sender);
        emit Transfer(msg.sender, address(this), amount);
        emit TokensFrozen(msg.sender, amount, numFrozenStructs, freezeDays);
    }

    // unfreeze frozen tokens
    function unFreeze(uint id) public {
        FrozenTokens storage f = frozenTokensMap[id];
        require(f.dateFrozen + (f.lengthFreezeDays * 1 days) < now, 'May not unfreeze until freeze time is up');
        require(f.frozen, 'Can only unfreeze frozen tokens');
        f.frozen = false;
        // move tokens back into owner's address from this contract's address
        balances[f.owner] = balances[f.owner].plus(f.amount);
        balances[address(this)] = balances[address(this)].minus(f.amount);
        emit Transfer(address(this), msg.sender, f.amount);
        emit TokensUnfrozen(f.owner, f.amount, id);
    }

    // burn tokens, taking them out of supply
    function burn(uint amount) public {
        balances[msg.sender] = balances[msg.sender].minus(amount);
        totalSupply = totalSupply.minus(amount);
        emit Transfer(msg.sender, address(0), amount);
        emit TokensBurned(msg.sender, amount);
    }

    // transfer tokens
    function transfer(address to, uint value) public returns (bool success)
    {
        require(to != address(0), 'Cannot send to zero address, please use burn function if that is your intention');
        // deduct
        balances[msg.sender] = balances[msg.sender].minus(value);
        // add
        balances[to] = balances[to].plus(value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    // transfer someone else's tokens, subject to approval
    function transferFrom(address from, address to, uint value) public returns (bool success)
    {
        require(to != address(0), 'Cannot send to zero address, please use burn function if that is your intention');
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

    // retrieve the balance of address
    function balanceOf(address owner) public view returns (uint balance) {
        return balances[owner];
    }

    // approve another address to transfer a specific amount of tokens
    function approve(address spender, uint value) public returns (bool success) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // incrementally increase approval, see https://github.com/ethereum/EIPs/issues/738
    function increaseApproval(address spender, uint value) public returns (bool success) {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].plus(value);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    // incrementally decrease approval, see https://github.com/ethereum/EIPs/issues/738
    function decreaseApproval(address spender, uint decreaseValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][spender];
        // allow decreasing too much, to prevent griefing via front-running
        if (decreaseValue >= oldValue) {
            allowed[msg.sender][spender] = 0;
        } else {
            allowed[msg.sender][spender] = oldValue.minus(decreaseValue);
        }
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    // retrieve allowance for a given owner, spender pair of addresses
    function allowance(address owner, address spender) public view returns (uint remaining) {
        return allowed[owner][spender];
    }

    function numCoinsFrozen() public view returns (uint) {
        return balances[address(this)];
    }
}
