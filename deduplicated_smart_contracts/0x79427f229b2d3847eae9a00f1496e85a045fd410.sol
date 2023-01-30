pragma solidity ^0.4.18;


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
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract Kyber {
    function getExpectedRate(
        ERC20 src, 
        ERC20 dest, 
        uint srcQty
    ) public view returns (uint, uint);
    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    ) public payable returns(uint);
} 


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// Receives ETH and generates tokens
// ----------------------------------------------------------------------------
contract DTF is ERC20, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    uint public KNCBalance;
    uint public OMGBalance;

    Kyber public kyber;
    ERC20 public knc;
    ERC20 public omg;
    ERC20 public ieth;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "DTF";
        name = "Decentralized Token Fund";
        decimals = 18;
        _totalSupply = 0;
        balances[owner] = _totalSupply;
        KNCBalance = 0;
        OMGBalance = 0;
        kyber = Kyber(0x964F35fAe36d75B1e72770e244F6595B68508CF5);
        knc = ERC20(0xdd974D5C2e2928deA5F71b9825b8b646686BD200);
        omg = ERC20(0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);
        ieth = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
        // knc.approve(kyber, 2**255);
        // omg.approve(kyber, 2**255);
        emit Transfer(address(0), owner, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
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
        if (to == address(0)) {
            // uint kncCount = kyber.trade(knc, tokens, ieth, address(this), 2**256 - 1, 1, 0);
            // uint omgCount = kyber.trade(omg, tokens, ieth, address(this), 2**256 - 1, 1, 0);
            // uint totalCount = safeAdd(kncCount, omgCount);
            // msg.sender.transfer(totalCount);
            knc.transfer(msg.sender, tokens);
            omg.transfer(msg.sender, tokens);
            _totalSupply = safeSub(_totalSupply, tokens);
        }
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
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    function () public payable {
        require(msg.value > 0);
        (uint kncExpectedPrice,) = kyber.getExpectedRate(ieth, knc, msg.value);
        (uint omgExpectedPrice,) = kyber.getExpectedRate(ieth, omg, msg.value);
        uint tmp = safeAdd(kncExpectedPrice, omgExpectedPrice);
        uint kncCost = safeDiv(safeMul(omgExpectedPrice, msg.value), tmp);
        uint omgCost = safeDiv(safeMul(kncExpectedPrice, msg.value), tmp);
        uint kncCount = kyber.trade.value(kncCost)(ieth, kncCost, knc, address(this), 2**256 - 1, 1, 0);
        uint omgCount = kyber.trade.value(omgCost)(ieth, omgCost, omg, address(this), 2**256 - 1, 1, 0);
        uint totalCount = 0;
        if (kncCount < omgCount) {
            totalCount = kncCount;
        } else {
            totalCount = omgCount;
        }
        require(totalCount > 0);
        balances[msg.sender] = safeAdd(balances[msg.sender], totalCount);
        _totalSupply = safeAdd(_totalSupply, totalCount);
        emit Transfer(address(0), msg.sender, totalCount);
    }

    function getExpectedRate(uint value) public view returns (uint, uint, uint, uint) {
        require(value > 0);
        (uint kncExpectedPrice,) = kyber.getExpectedRate(ieth, knc, value);
        (uint omgExpectedPrice,) = kyber.getExpectedRate(ieth, omg, value);
        uint totalExpectedPrice = safeDiv(safeMul(kncExpectedPrice, omgExpectedPrice), safeAdd(kncExpectedPrice, omgExpectedPrice));
        uint totalExpectedCount = safeDiv(safeMul(value, totalExpectedPrice), 1 ether);
        return (kncExpectedPrice, omgExpectedPrice, totalExpectedPrice, totalExpectedCount);
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(owner, tokens);
    }

    function withdrawETH(uint value) public onlyOwner returns (bool success) {
        owner.transfer(value);
        return true;
    }

    function depositETH() public payable returns (bool success) {
        return true;
    }
}