pragma solidity ^0.4.23;

import "baseerc20token.sol";

contract SeeMeLive is BaseERC20Token {
    address public owner = msg.sender;

    constructor(
        uint256 _totalSupply,
        uint8 _decimals,
        string _name,
        string _symbol
    ) BaseERC20Token(_totalSupply, _decimals, _name, _symbol) public
    {
    }

    function mint(address recipient, uint256 amount) public {
        require(msg.sender == owner);
        require(totalSupply + amount >= totalSupply); // Overflow check

        totalSupply += amount;
        balanceOf[recipient] += amount;
        emit Transfer(address(0), recipient, amount);
    }

    function burn(uint256 amount) public {
        require(amount <= balanceOf[msg.sender]);

        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function burnFrom(address from, uint256 amount) public {
        require(amount <= balanceOf[from]);
        require(amount <= allowance[from][msg.sender]);

        totalSupply -= amount;
        balanceOf[from] -= amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, address(0), amount);
    }
}