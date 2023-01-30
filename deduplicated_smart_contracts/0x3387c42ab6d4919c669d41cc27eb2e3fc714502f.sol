/**

 *Submitted for verification at Etherscan.io on 2019-02-21

*/



pragma solidity 0.4.23;



/**

 * @title Now

 *

 * @notice Helper smart contract, provides current unix timestamp

 *

 * @author Basil Gorin

 */

contract Now {

  /**

   * @notice provides current unix timestamp

   * @return current time as a unix timestamp

   */

  function getNow() public constant returns(uint256) {

    // just return the built-in constant

    return now;

  }

}