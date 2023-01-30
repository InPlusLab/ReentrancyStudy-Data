/**

 *Submitted for verification at Etherscan.io on 2018-11-04

*/



pragma solidity 0.4.21;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



contract Globalnetworktoken is Ownable {

  address destinationAddress;

  event LogForwarded(address indexed sender, uint amount);

  event LogFlushed(address indexed sender, uint amount);



  function Globalnetworktoken() public {

    destinationAddress = msg.sender;

  }



  function() payable public {

    emit LogForwarded(msg.sender, msg.value);

    destinationAddress.transfer(msg.value);

  }



  function flush() public {

    emit LogFlushed(destinationAddress, address(this).balance);

    destinationAddress.transfer(address(this).balance);

  }



}