  pragma solidity ^0.4.24;

import "./MintableToken.sol";
import "./StandardToken.sol";
import "./BurnableToken.sol";

contract ERC20Token is StandardToken ,MintableToken,BurnableToken {
    string public name = "GAIA token"; //Token Name
    string public symbol = "GAIA"; //Token Symbol
    uint public decimals = 4; //Token Decimals
    uint public INITIAL_SUPPLY = 10000000000 * (10 ** decimals); //Token Total Supply
 
    
    function ERC20Token () public {
        balances[msg.sender] = INITIAL_SUPPLY;
        totalSupply_=INITIAL_SUPPLY;
    }
}
