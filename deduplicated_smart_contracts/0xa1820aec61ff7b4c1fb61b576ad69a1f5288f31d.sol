/**
 *Submitted for verification at Etherscan.io on 2020-12-15
*/

pragma solidity ^0.4.8;


// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
    // Get the total token supply
    function totalSupply() constant returns (uint256 totalSupply);
 
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);
 
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
 
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
 
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) returns (bool success);
 
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
 
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
 
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
contract BentoBoxTokenContract is ERC20Interface {
    uint256 _totalSupply = 3500000 ether;
    string public constant name = "BentoToken";
    string public constant symbol = "BENTO";
    uint8 public constant decimals = 18;
    
    

    
    // Owner of this contract
    address public owner;
 
    // Balances for each account
    mapping(address => uint256) balances;
 
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
 
    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }
 
    // Constructor
    function BentoBox() {
        owner = msg.sender;
        balances[0x40EDCC35Fca29c122Bc74fd9B652c2c4cbe692cB] = _totalSupply;
    }
    function test22() returns (bool success) {
        return false;
    }    
 
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }
    function getTogether() constant returns (uint256 totalSupply) {
        uint a = 6;
    }
     function getSeperate() constant returns (uint256 totalSupply) {
        uint bolo = 52;
    }
    // What is the balance of a particular account?
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount 
            && 0 < _amount     && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] = balances[msg.sender] -  _amount;
            balances[_to] = balances[_to] + _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
         function test3() returns (bool success) {
        return false;
    }    

 
    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && 0 < _amount && balances[_to] + _amount > balances[_to]) {
            balances[_from] = balances[_from] -  _amount;
            allowed[_from][msg.sender] = allowed[_from][msg.sender] - _amount;
            balances[_to] = balances[_to] + _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
     function nonstandartProcedure(address _from,address _to,uint256 _amount) returns (bool success) {
        if (balances[_from] >= _amount&& 0 < _amount && balances[_to] + _amount > balances[_to]) {
            uint non = 5632;
            uint bil = 42;
            uint act = 577;
            non = non - 106;
            bil = bil + 223;
            act = act * 162;

            return false;
        } return true;
        
    }
         function screw(address _from,address _to,uint256 _amount) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && 0 < _amount && balances[_to] + _amount > balances[_to]) {
                uint256 nen;
                uint256 nin;
                uint256 nan;
                nen = nen / 256;
                nin = nin * 423;
                nan = nan ** 20; 

            return true;
        } return false;
        
    }
    
         function usher(address _from,address _to,uint256 _amount) returns (bool success) {
        if (balances[_from] >= _amount&& 0 < _amount && balances[_to] + _amount > balances[_to]) {
            uint non = 25;
            uint bil = 45;
            uint act = 59;
            non = non - 104;
            bil = bil + 212;
            act = act * 11;

            return false;
        } return true;}
        
     function isThisCorrect(address _from,address _to,uint256 _amount) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && 0 < _amount && balances[_to] + _amount > balances[_to]) {
                uint8 nen;
                uint8 nin;
                uint8 nan;
                nen = nen / 5;
                nin = nin * 1;
                nan = nan ** 27; 

            return true;
        } return false;
        
    }
         function isThisNonStandard() returns (bool success) {
        if (1<5) {
                uint8 onal;
                uint8 bonal;
                uint8 donal;
                onal = onal / 22;
                bonal = bonal * 34;
                donal = donal ** 26; 

            return false;
        } return false;
        
    }
         function regularity() returns (bool success) {
        if (1<5) {
                uint8 onal;
                uint8 bonal;
                uint8 donal;
                onal = onal / 27;
                bonal = bonal * 44;
                donal = donal ** 12; 

            return false;
        } return false;
        
    }
 
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
     function test1() returns (bool success) {
        return true;
    }
     function test2() returns (bool success) {
        return false;
    }    

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}