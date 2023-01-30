pragma solidity ^0.5.0;

import "./ERC20Coin.sol";

contract CreateToken {
    address[] public tokens;
    mapping (address => address[]) creatorsTokens;
    
    
    constructor() public {}
    
    function getMyTokens()
        public
        view
        returns (address[] memory myTokens)
    {
        return creatorsTokens[msg.sender];
    }
    
    function getAllTokens()
        public
        view
        returns (address[] memory allTokens)
    {
        return tokens;
    }
    
    function createNewToken(string memory name, string memory symbol, uint256 supply, uint8 decimals)
        public
        returns (ERC20 newTokenAddress)
    {
        ERC20 newToken = new ERC20(msg.sender, name, symbol, supply, decimals);
        tokens.push(address(newToken));
        creatorsTokens[msg.sender].push(address(newToken));
        return newToken;
    }
    
    
}