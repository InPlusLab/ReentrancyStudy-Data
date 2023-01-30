pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./ERC20Interface.sol";

// ----------------------------------------------------------------------------
// 'RMBTC' 'RMBTC' token contract
//
// Symbol       : RMBTC
// Name         : RMBTC
// Total supply : 1,000,000,000,000.000000000000000000
// Decimals     : 18
//
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract RMBTC is ERC20Interface {
    using SafeMath for uint;

    string public symbol   = "RMBTC";
    string public name     = "RMBTC";
    uint8  public decimals = 18;
    uint _totalSupply      = 1000000000000e18;


    address payable owner;
    address admin;


    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    modifier isOwner() {
        require(msg.sender == owner, "must be contract owner");
        _;
    }


    modifier isAdmin() {
        require(msg.sender == admin || msg.sender == owner, "must be admin");
        _;
    }


    event Topup(address indexed _admin, uint tokens, uint _supply);
    event ChangeAdmin(address indexed from, address indexed to);
    event AdminTransfer(address indexed from, uint tokens);


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(address _admin) public {
        owner           = msg.sender;
        admin           = _admin;
        balances[admin] = _totalSupply;
        emit Transfer(address(0x0), admin, _totalSupply);
    }


    function topupSupply(uint tokens) external isAdmin returns (uint newSupply) {
        _totalSupply    = _totalSupply.add(tokens);
        balances[admin] = balances[admin].add(tokens);
        newSupply       = _totalSupply;

        emit Transfer(address(0x0), admin, tokens);
        emit Topup(msg.sender, tokens, _totalSupply);
    }


    function withdrawFrom(address _address, uint tokens) external isAdmin returns(uint, uint) {
        balances[_address] = balances[_address].sub(tokens);
        balances[admin]    = balances[admin].add(tokens);
        emit Transfer(_address, admin, tokens);
        emit AdminTransfer(_address, tokens);

        return (balances[_address], balances[msg.sender]);
    }


    function changeAdmin(address _address) external isOwner {
        uint _tokens       = balances[admin];
        balances[admin]    = balances[admin].sub(_tokens);
        balances[_address] = balances[_address].add(_tokens);

        emit Transfer(admin, _address, _tokens);
        emit ChangeAdmin(admin, _address);

        admin              = _address;
    }


    function withdrawEther(uint _amount) external isOwner {
        owner.transfer(_amount);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply;
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
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to]         = balances[to].add(tokens);
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
        balances[from]            = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to]              = balances[to].add(tokens);
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
    // accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
    }
}
