pragma solidity ^0.4.24;

import './StandardToken.sol';
import './Ownable.sol';

contract DFINToken is StandardToken, Ownable {

    string public name = 'BLOCKLINK CAPITAL';
    string public symbol = 'DFIN';
    uint8 public decimals = 6;
    // A_total_of_100_million
    uint public INITIAL_SUPPLY = 100000000 * (10 ** uint(decimals));
   

    
    // 100% initial Address
    address public initialAddress = 0xe03D6b8dC25F248d93A623d11D31Da48D6095ee9;


    constructor() public {
        
        // totalSupply 100000000
        totalSupply_ = INITIAL_SUPPLY;
        // 100%_supply
        balances[initialAddress] = INITIAL_SUPPLY ;
        emit Transfer(0x0, initialAddress, INITIAL_SUPPLY );    
     }
    
 }