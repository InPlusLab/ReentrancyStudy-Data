pragma solidity ^0.4.24;

import 'StandardToken.sol';

contract TutorialToken is StandardToken {
    string public name = "Genetic Testing Engineering";
    string public symbol = 'GTE';
    uint8 public decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 370000000000000000000000000;
    address myaddress = 0x38dAC3d264e78646095115B7bc5c48b194b63416;

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[myaddress] = INITIAL_SUPPLY;
        emit Transfer(0x0, myaddress, INITIAL_SUPPLY);
        // balances[msg.sender] = INITIAL_SUPPLY;
         // emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}
