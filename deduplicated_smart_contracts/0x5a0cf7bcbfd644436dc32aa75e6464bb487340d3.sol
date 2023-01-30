pragma solidity ^0.4.21;


import "./PausableToken.sol";


/**
 * @title WitnessNetwork
 */
contract WitnessNetwork is PausableToken {

	function () {
      //if ether is sent to this address, send it back.
        revert();
    }

    
    string public name = "WitnessNetwork";
    uint8 public decimals = 8;
    string public symbol = "WNET";
    string public version = '1.0.0';
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

    
    function WitnessNetwork() public {
        balances[msg.sender] = INITIAL_SUPPLY;    // Give the creator all initial tokens
        totalSupply_ = INITIAL_SUPPLY;
    }
}
