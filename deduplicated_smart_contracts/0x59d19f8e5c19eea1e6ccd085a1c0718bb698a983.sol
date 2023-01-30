pragma solidity ^0.6.1;

import "./IERC20.sol";

/**
 * Contract that will forward any incoming Ether to the recipient
 */
contract PaymentContract {

  // Address to which any funds sent to this contract will be forwarded to
  address payable private _recipient;

  event ForwarderDeposited(address from, uint256 value, bytes data);
  event TokensFlushed(address receiveAddress, uint256 value, address tokenContractAddress);

  /**
   * Create the contract, and sets the destination address to that of the creator
   */
  constructor(address payable recipient) public payable {
    _recipient = recipient;
  }

  /**
   * Modifier that will execute internal code block only if the sender is the recipient address
   */
  modifier onlyReceipent {
    require(msg.sender == _recipient, "Sender is not the recipient address");
    _;
  }

  receive() external payable {
    // throws on failure
    _recipient.transfer(msg.value);

    // Fire off the deposited event if we can forward it
    emit ForwarderDeposited(msg.sender, msg.value, msg.data);
  }

  /**
   * Default function; Gets called when Ether is deposited, and forwards it to the recipient address
   */
  // fallback() external payable {
  //   // throws on failure
  //   _recipient.transfer(msg.value);

  //   // Fire off the deposited event if we can forward it
  //   emit ForwarderDeposited(msg.sender, msg.value, msg.data);
  // }

  function changeReceipent(address payable newReceipent) public onlyReceipent {
      _recipient = newReceipent;
  }

  /**
   * Execute a token transfer of the full balance from the forwarder token to the recipient address
   * @param tokenContractAddress the address of the erc20 token contract
   */
  function flushTokens(address tokenContractAddress) public {
    IERC20 instance = IERC20(tokenContractAddress);
    uint256 balance = instance.balanceOf(address(this));

    require(balance > 0, "Token balance is zero");

    require(instance.transfer(_recipient, balance), "Transfer token failed");

    // fire of an event just for the record!
    emit TokensFlushed(_recipient, balance, tokenContractAddress);
  }
}

