/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

pragma solidity 0.4.24;

contract Bank {
    
    mapping (address => bool) whitelist;
    mapping (address => uint256) allowance;
    uint256 amount;
    address owner;
    
    event Winner(address);
    
    constructor() public {
        owner = msg.sender;
        whitelist[msg.sender] = true;
        amount = 20 wei * (10**9);
    }
    
    function bet() public payable {
        require(msg.value == amount);
        require(whitelist[msg.sender]);
        if (uint256(blockhash(block.number)) % 2 == 0) {
            // the user wins, but we take 10 wei comission
            allowance[msg.sender] = allowance[msg.sender] + (msg.value + msg.value - 5 wei * (10**9));
            allowance[owner] = allowance[owner] + 5 wei * (10**9);
            emit Winner(msg.sender);
        } else {
            // no win balance stays in the contract, we still take comission
            allowance[owner] = allowance[owner] + 5 wei * (10**9);
        }
    }
    
    function withdraw() public {
        require(whitelist[msg.sender]);
        require(allowance[msg.sender] > 0);
        msg.sender.call.value(allowance[msg.sender]);
        allowance[msg.sender] = 0;
    }
    
    function withdrawByOwner() public {
        require(msg.sender == owner);
        msg.sender.call.value(allowance[msg.sender]);
        allowance[msg.sender] = 0;
    }
    
    function allow(address who) public {
        require(msg.sender == owner);
        whitelist[who] = true;
    }
    
    function disallow(address who) public {
        require(msg.sender == owner);
        whitelist[who] = false;
    }
    
    function() public payable {
    }
    
}