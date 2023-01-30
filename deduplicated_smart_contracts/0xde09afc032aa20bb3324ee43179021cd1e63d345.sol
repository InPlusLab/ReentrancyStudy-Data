pragma solidity ^0.5;

import './ERC20.sol';
import './ERC20Detailed.sol';

contract ShadowPayment is ERC20Detailed, ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _amount)
    ERC20Detailed(_name, _symbol, _decimals)
    public {
        uint256 initialSupply = _amount.mul(10 ** uint256(_decimals));
        _mint(msg.sender, initialSupply);
    }
}
