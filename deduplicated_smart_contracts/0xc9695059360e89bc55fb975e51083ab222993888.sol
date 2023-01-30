pragma solidity ^0.4.25;

import "./ERC20Mintable.sol";

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */

contract ERC20Detailed is ERC20Mintable {
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  bool public mintable;
  bool public burnable;

  constructor(string name, string symbol, uint8 decimals, uint256 initialSupply, bool _mintable, bool _burnable) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
    _totalSupply = initialSupply;
    _balances[msg.sender] = initialSupply;
    mintable = _mintable;
    burnable = _burnable;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }

  /**
   * @dev mint function, checks if the contract is allowed to mint
   * @param _to the receiver of the tokens when mint funtion is successful
   * @param _value the amount of tokens to mint
   */
  function mint(address _to, uint256 _value) public returns (bool)  {
    require(mintable, "Token is not mintable");
    super.mint(_to, _value);
  }

  /**
   * @dev burn function, checks if the contract is allowed to burn, then burns from sender's account
   * @param _value the amount of tokens to burn
   */
  function burn(uint256 _value) public returns (bool)  {
    require(burnable, "Token is not burnable");
    super.burn(_value);
  }
}
