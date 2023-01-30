pragma solidity ^0.6.1;


import "./PaymentContract.sol";
import "./CreatorRole.sol";

// This is a test target for a Forwarder.
// It contains a public function with a side-effect.
contract PaymentCreator is CreatorRole {

  event NewPayment(address indexed paymentAddress);

  /**
   * Requirements:
   * - the caller must have the `CreatorRole`.
   *
   * return new payment address.
   */
  function createPayment(address payable recipient) public onlyCreator returns (address) {
    // create new stake
    PaymentContract payment = new PaymentContract(recipient);

    emit NewPayment(address(payment));

    return address(payment);
  }

}
