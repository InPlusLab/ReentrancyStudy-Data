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

    //�ҧѧ٧� ���է֧���
    mapping(uint256 => order) public orders;

    //�ӧ�٧ӧ�ѧ� �է֧ߧ֧� ���� ������ܧ� �����ѧӧڧ�� �է֧ߧ�ԧ� �ߧ� �ܧ�ߧ��ѧܧ�
    function () public payable {
        revert();
    }

    event PaymentOrder(uint256 indexed id, address payer, uint256 value);

    //���ݧѧ�� ���է֧��
    function paymentOrder(uint256 _id) public payable returns(bool) {
        require(orders[_id].value==0, "id used");
        require(msg.value>0, "no money");

        orders[_id].payer=msg.sender;
        orders[_id].value=msg.value;
        orders[_id].revert=false;

        //���٧էѧ�� �֧ӧ֧ߧ�
        emit PaymentOrder(_id, msg.sender, msg.value);

        return true;
    }

    event RevertOrder(uint256 indexed id, address payer, uint256 value);

    //�ӧ�٧ӧ�ѧ� ��ݧѧ�֧ا�
    function revertOrder(uint256 _id) public onlyOwner returns(bool)  {
        require(orders[_id].value>0, "order not used"); 
        require(orders[_id].revert==false, "order revert");

        orders[_id].revert=true;
        address(orders[_id].payer).transfer(orders[_id].value);
        
        //���٧էѧ�� �֧ӧ֧ߧ�
        emit RevertOrder(_id, orders[_id].payer, orders[_id].value);

        return true;
    }

    //�ӧ�ӧ�� �է֧ߧ֧� �ѧէާڧߧڧ���ѧ�����
    function outputMoney(address _from, uint256 _value) public onlyOwner returns(bool) {
        require(address(this).balance>=_value);

        address(_from).transfer(_value);

        return true;
    }

}