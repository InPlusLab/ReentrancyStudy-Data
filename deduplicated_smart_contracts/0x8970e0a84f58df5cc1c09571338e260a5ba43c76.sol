/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.5.12;

contract TigReceiver {
    function tokenFallback(address from, uint tokens, bytes32 data) public view;
}

contract Tig {

    // ERC223 Token, with the addition of symbol, name and decimals and a
    // fixed supply

    string public constant symbol       = 'TIG';
    string public constant name         = 'TIG';
    uint8 public constant decimals      = 18;
    uint public constant _totalSupply   = 50000000 * 10**uint(decimals);
    address public owner;
    string public webAddress;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping(address => uint256)) allowed;

    constructor() public {
        balances[msg.sender]    = _totalSupply;
        owner                   = msg.sender;
        webAddress              = "https://hellotig.com";
    }

    // Get token total supply
    function totalSupply() public pure returns (uint) {
        return _totalSupply;
    }

    // Get the token balance for account { tokenOwner }
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    // Check if {to} is a ordinary address or a contract address { ERC223 standard }
    function isContractAdrs(address to) private view returns (bool is_contract_adrs) {
        uint length;
        assembly {
            length := extcodesize(to)
        }
        return (length > 0);
    } 
    
    // Called when a user or another contract wants to transfer funds { ERC223 standard }
    function transfer(address to, uint tokens, bytes32 data) public returns (bool success) {
        if(isContractAdrs(to)) {
            return transferToContract(to, tokens, data);
        } else {
            return transferToAddress(to, tokens);
        }
    }
    
    // Transfer the balance from owner's account to another account { backward compatability to ERC20 }
    function transfer(address to, uint tokens) public returns (bool success) {
        bytes32 empty;
        if(isContractAdrs(to)) {
            return transferToContract(to, tokens, empty);
        } else {
            return transferToAddress(to, tokens);
        }
    }
    
    // Function that is called when transaction target is a contract
    function transferToContract(address to, uint tokens, bytes32 data) private returns (bool success) {
        require( balances[msg.sender] >= tokens && tokens > 0 );
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        TigReceiver receiver = TigReceiver(to);
        receiver.tokenFallback(msg.sender, tokens, data);
        emit Transfer(msg.sender, to, tokens, data);
        return true;
    }
    
    // Function that is called when transaction target is an address
    function transferToAddress(address to, uint tokens) private returns (bool success) {
        require( balances[msg.sender] >= tokens && tokens > 0 );
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // Send {tokens} amount of tokens from address {from} to address {to}
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require( allowed[from][msg.sender] >= tokens && balances[from] >= tokens && tokens > 0 );
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    // Allow {spender} to withdraw from your account, multiple times, up to the {tokens} amount.
    function approve(address sender, uint256 tokens) public returns (bool success) {
        allowed[msg.sender][sender] = tokens;
        emit Approval(msg.sender, sender, tokens);
        return true;
    }

    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    
    // { ERC223 standard }
    event Transfer(address indexed _from, address indexed _to, uint256 _amount, bytes32 data);
    // { backward compatability to ERC20 }
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _to, uint256 _amount);
}