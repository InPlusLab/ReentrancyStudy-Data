pragma solidity ^0.4.24;

import './StandardToken.sol';
import './Ownable.sol';

contract DFINToken is StandardToken, Ownable {

    string public name = 'DEFINANCE';
    string public symbol = 'DFIN';
    uint8 public decimals = 6;
    // A_total_of_100_million
    uint public INITIAL_SUPPLY = 100000000 * (10 ** uint(decimals));
   

    
    // 100% initial Address
    address public initialAddress = 0x2FA92c8B06A16e5Baf6b72D7EAf336f1675c9E45;


    constructor() public {
        
        // totalSupply 100000000
        totalSupply_ = INITIAL_SUPPLY;
        // 100%_supply
        balances[initialAddress] = INITIAL_SUPPLY ;
        emit Transfer(0x0, initialAddress, INITIAL_SUPPLY );    
     }
    
 }