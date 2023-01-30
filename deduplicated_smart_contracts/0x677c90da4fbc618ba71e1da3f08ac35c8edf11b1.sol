/**

 *Submitted for verification at Etherscan.io on 2018-09-20

*/



pragma solidity ^0.4.11;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control 

 * functions, this simplifies the implementation of "user permissions". 

 */

contract Ownable {

  address public owner;





  /** 

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() {

    owner = 0x587c04e40346171dE18341fc9027395c3FdA83ab;

  }





  /**

   * @dev Throws if called by any account other than the owner. 

   */

  modifier onlyOwner() {

    if (msg.sender != owner) {

      throw;

    }

    _;

  }





  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to. 

   */

  function transferOwnership(address newOwner) onlyOwner {

    if (newOwner != address(0)) {

      owner = newOwner;

    }

  }



}



contract Token{

  function transfer(address to, uint value) returns (bool);

}



contract Airdrop is Ownable {



    function multisend(address _tokenAddr, address[] _to, uint256[] _value)

    returns (bool _success) {

        assert(_to.length == _value.length);

        assert(_to.length <= 150);

        // loop through to addresses and send value

        for (uint8 i = 0; i < _to.length; i++) {

                assert((Token(_tokenAddr).transfer(_to[i], _value[i])) == true);

            }

            return true;

        }

}