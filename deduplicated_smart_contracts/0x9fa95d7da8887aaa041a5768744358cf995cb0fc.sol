/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * 

Ownable contract  comes from

https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol

and is Licensed under MIT license 



All other contracts are Created by 

Łukasz Grynasz https://www.linkedin.com/in/%C5%82ukasz-grynasz-aba24b55/

Adam Skrodzki https://www.linkedin.com/in/adam-skrodzki-521051b/



as a part of https://pway.io project



 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

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

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



// File: contracts\PwayContract.sol



contract PwayContract is Ownable {



    modifier onlyHuman(address addr){

        uint size;

        assembly { size := extcodesize(addr) } // solium-disable-line

        if(size == 0){

            _;

        }else{

            revert("Provided address is a contract");

        }

    }

    

}



// File: contracts\NameRegistry.sol



contract NameRegistry is PwayContract {



    event EntrySet(string entry,address adr);



    mapping(string => address) names;

  

    function hasAddress(string name) public view returns(bool) {

        return names[name] != address(0);

    }

    

    function getAddress(string name) public view returns(address) {

        require(names[name] != address(0), "Address could not be 0x0");

        return names[name];

    }

    

    function setAddress(string name, address _adr) public {

        require(_adr != address(0), "Address could not be 0x0");



        bytes memory nameBytes = bytes(name);

        require(nameBytes.length > 0, "Name could not be empty");



        bool isEmpty = names[name] == address(0);



        //can be initialized by everyone , but only change by itself

        require(isEmpty || names[name] == msg.sender);



        names[name] = _adr;

        emit EntrySet(name, names[name]);

    } 

  

}