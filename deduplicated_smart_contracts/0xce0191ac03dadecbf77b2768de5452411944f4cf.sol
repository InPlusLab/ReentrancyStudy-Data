pragma solidity ^0.4.23;


import "./LockableToken.sol";


/**
 * @title dAegisToken
 * @dev dAegis extended version of ERC20 Token, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract DAE is LockableToken {

  string public constant name = "dAegis Token"; // solium-disable-line uppercase
  string public constant symbol = "DAE"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 700000000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[0x861B1F03190957A723A2911998244766D6699D1a] = INITIAL_SUPPLY;
    emit Transfer(0x0, 0x861B1F03190957A723A2911998244766D6699D1a, INITIAL_SUPPLY);
  }

}
