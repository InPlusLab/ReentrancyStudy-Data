/**
 *Submitted for verification at Etherscan.io on 2020-04-29
*/

pragma solidity 0.6.6;


/**
 * @title Utils
 * @dev This contract is used to combine multiple web3 node calls into
 *      preferrably one single call.
 * @author Christian Engel - @chrsengel
 */
contract Utils {
  /**
   * @dev Get ERC20 balances of a list of tokens
   *
   * @param _tokens the tokens
   * @param _owner the owner address
   */
  function getERC20Balances(address[] memory _tokens, address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256[] memory balances = new uint256[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      balances[i] = MultiToken(_tokens[i]).balanceOf(_owner);
    }
    return balances;
  }

  /**
   * @dev Get balances of cTokens and balances of underlying assets
   *
   * @param _tokens the cTokens
   * @param _owner the owner address
   */
  function getCompoundBalances(address[] memory _tokens, address _owner)
    public
    view
    returns (uint256[] memory, uint256[] memory)
  {
    uint256[] memory balances = new uint256[](_tokens.length);
    uint256[] memory underlyings = new uint256[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      balances[i] = MultiToken(_tokens[i]).balanceOf(_owner);
      underlyings[i] = MultiToken(_tokens[i]).balanceOfUnderlying(_owner);
    }
    return (balances, underlyings);
  }

  /**
   * @dev Get the current supply rates of all cTokens.
   * This can be used to quickly calculate all APYs of all cTokens.
   * To get the APY in percent simply multiply the result by 2102400
   * and then divide by 1e18.
   *
   * APY = (SUPPLY_RATE * BLOCKS_PER_YEAR) / 1e18
   *
   * @param _tokens the cTokens
   */
  function getSupplyRates(address[] memory _tokens) public view returns (uint256[] memory) {
    uint256[] memory supplyRates = new uint256[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      supplyRates[i] = MultiToken(_tokens[i]).supplyRatePerBlock();
    }
    return supplyRates;
  }

  /**
   * @dev Get the current borrow rates of all cTokens.
   *
   * @param _tokens the cTokens
   */
  function getBupplyRates(address[] memory _tokens) public view returns (uint256[] memory) {
    uint256[] memory borrowRates = new uint256[](_tokens.length);
    for (uint256 i = 0; i < _tokens.length; i++) {
      borrowRates[i] = MultiToken(_tokens[i]).borrowRatePerBlock();
    }
    return borrowRates;
  }
}


/**
 + @title MultiToken
 * @dev Multi token interface that can be used to interact with cToken and
 *      other ERC20 contracts.
 */
interface MultiToken {
  function supplyRatePerBlock() external view returns (uint256);

  function borrowRatePerBlock() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function balanceOfUnderlying(address owner) external view returns (uint256);
}