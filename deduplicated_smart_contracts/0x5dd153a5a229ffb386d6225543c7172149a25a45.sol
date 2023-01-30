pragma solidity >=0.4.22 <0.6.0;

import './9mmToken.sol';

contract makeToken is NINECOIN {
    // initialSupply, tokenName, tokenSymbol
    string public constant name = "NineCoin";
    string public constant symbol = "9CO";
    uint256 public constant _totalSupply = 10000000000;
    uint public constant decimals = 18;
    uint public constant totalSupply = _totalSupply * 10**uint(decimals);
    
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    )
    NINECOIN(initialSupply, tokenName, tokenSymbol) public {
initialSupply = 0;
        tokenName = name;
        tokenSymbol = symbol;
        mintToken(msg.sender, totalSupply);
    }
}
