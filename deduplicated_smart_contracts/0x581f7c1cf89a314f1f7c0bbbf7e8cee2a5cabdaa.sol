pragma solidity ^0.5.1;
import "./ERC20_Token.sol";

/**
 * 
 * @title Drops (DRP)
 * @dev Drops crypto currency smart contract based upon the ERC20 standart token 
 *
 * Drops (DRP) Smart Contract v1.0 08.09.2019  (c) Mark R Rogers, 2019.
 * 
 **/
contract Drops is ERC20_Token {                                                     // Build on ERC20 standard contract 
    // Initalise variables and data
    string constant TOKEN_NAME = "Drops";                                           // Token description
    string constant TOKEN_SYMBOL = "DRP";                                           // Token symbol
    uint8  constant TOKEN_DECIMALS = 8;                                             // Token decimals

    // Initial contract deployment setup
    // @notice only run when the contract is created
    // @param initialMint_ The amount of coins to create
    constructor(uint256 initialMint_) public {
        name = TOKEN_NAME;                                                          // Set description
        symbol = TOKEN_SYMBOL;                                                      // Set symbol
        decimals = TOKEN_DECIMALS;                                                  // Set decimals
        coinOwner = msg.sender;                                                     // Set coin owner identity
        coinSupply = initialMint_.toklets(TOKEN_DECIMALS);                          // Set total supply in droplets
        balances[msg.sender] = coinSupply;                                          // Set owners balance
    }
}