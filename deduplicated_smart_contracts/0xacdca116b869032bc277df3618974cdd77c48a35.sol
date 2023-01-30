/**
 *Submitted for verification at Etherscan.io on 2020-07-04
*/

pragma solidity ^0.4.25;
//version:5

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract PaymentSystem is Ownable {

    struct order {
        address payer;
        uint256 value;
        bool revert;
    }

    //§Ò§Ñ§Ù§Ñ §à§â§Õ§Ö§â§à§Ó
    mapping(uint256 => order) public orders;

    //§Ó§à§Ù§Ó§â§Ñ§ä §Õ§Ö§ß§Ö§Ô §á§â§Ú §á§à§á§í§ä§Ü§Ö §à§ä§á§â§Ñ§Ó§Ú§ä§î §Õ§Ö§ß§î§Ô§Ú §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä
    function () public payable {
        revert();
    }

    event PaymentOrder(uint256 indexed id, address payer, uint256 value);

    //§à§á§İ§Ñ§ä§Ñ §à§â§Õ§Ö§â§Ñ
    function paymentOrder(uint256 _id) public payable returns(bool) {
        require(orders[_id].value==0, "id used");
        require(msg.value>0, "no money");

        orders[_id].payer=msg.sender;
        orders[_id].value=msg.value;
        orders[_id].revert=false;

        //§ã§à§Ù§Õ§Ñ§ä§î §Ö§Ó§Ö§ß§ä
        emit PaymentOrder(_id, msg.sender, msg.value);

        return true;
    }

    event RevertOrder(uint256 indexed id, address payer, uint256 value);

    //§Ó§à§Ù§Ó§â§Ñ§ä §á§İ§Ñ§ä§Ö§Ø§Ñ
    function revertOrder(uint256 _id) public onlyOwner returns(bool)  {
        require(orders[_id].value>0, "order not used"); 
        require(orders[_id].revert==false, "order revert");

        orders[_id].revert=true;
        address(orders[_id].payer).transfer(orders[_id].value);
        
        //§ã§à§Ù§Õ§Ñ§ä§î §Ö§Ó§Ö§ß§ä
        emit RevertOrder(_id, orders[_id].payer, orders[_id].value);

        return true;
    }

    //§Ó§í§Ó§à§Õ §Õ§Ö§ß§Ö§Ô §Ñ§Õ§Ş§Ú§ß§Ú§ã§ä§â§Ñ§ä§à§â§à§Ş
    function outputMoney(address _from, uint256 _value) public onlyOwner returns(bool) {
        require(address(this).balance>=_value);

        address(_from).transfer(_value);

        return true;
    }

}