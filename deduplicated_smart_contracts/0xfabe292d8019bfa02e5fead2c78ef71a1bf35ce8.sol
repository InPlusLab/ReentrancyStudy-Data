pragma solidity ^0.4.4;


contract TestNetworkToken {

    // Token metadata
    string public constant name = "Test Network Token";
    string public constant symbol = "TNT";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH.

    uint256 public constant tokenCreationRate = 1000;

    // The current total token supply
    uint256 totalTokens;
    
    mapping (address => uint256) balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

    // ERC20 interface implementation

    // Empty implementation, so that no tokens can be moved
    function transfer(address _to, uint256 _value) returns (bool) {
        return false;
    }

    function totalSupply() external constant returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }

    // External interface similar to the crowdfunding one

    function create() payable external {
        // Do not allow creating 0 tokens.
        if (msg.value == 0) throw;

        var numTokens = msg.value * tokenCreationRate;

        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[msg.sender] += numTokens;

        // Log token creation event
        Transfer(0x0, msg.sender, numTokens);
    }

    function refund() external {
        var tokenValue = balances[msg.sender];
        if (tokenValue == 0) throw;
        balances[msg.sender] = 0;
        totalTokens -= tokenValue;

        var ethValue = tokenValue / tokenCreationRate;
        Refund(msg.sender, ethValue);

        if (!msg.sender.send(ethValue)) throw;
    }

    // This is a test contract, so kill can be used once it is not needed
    
    function kill() {
        if(totalTokens > 0) throw;

        selfdestruct(msg.sender);
    }
}