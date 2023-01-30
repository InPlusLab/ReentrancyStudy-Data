/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

/**
 *Submitted for verification at Etherscan.io on 2019-01-22
*/

pragma solidity ^0.4.24;

contract Owned {}
contract ERC20Interface {}
contract DataeumToken is Owned, ERC20Interface{}
contract XDT is DataeumToken {
  mapping(address => uint256) balances;
  function transfer(address destination, uint256 amount) public returns (bool success);
  function balanceOf(address tokenOwner) public view returns (uint balance);
}


contract SwapContractDateumtoPDATA {
  //storage
  address public owner;
  XDT public company_token;

  address public PartnerAccount;
  uint public originalBalance;
  uint public currentBalance;
  uint public alreadyTransfered;
  uint public startDateOfPayments;
  uint public endDateOfPayments;
  uint public periodOfOnePayments;
  uint public limitPerPeriod;
  uint public daysOfPayments;

  //modifiers
  modifier onlyOwner
  {
    require(owner == msg.sender);
    _;
  }
  
  
  //Events
  event Transfer(address indexed to, uint indexed value);
  event OwnerChanged(address indexed owner);


  //constructor
  constructor (XDT _company_token) public {
    owner = msg.sender;
    PartnerAccount = 0xD99cc20B0699Ae9C8DA1640e03D05925ddD8acd2;
    company_token = _company_token;
    originalBalance = 10000000   * 10**18; // 10 000 000   XDT
    currentBalance = originalBalance;
    alreadyTransfered = 0;
    startDateOfPayments = 1577840400; //From 01 January 2020, 01:00:00 GMT
    endDateOfPayments = 1593565200; //To 01 July 2020, 01:00:00 GMT
    periodOfOnePayments = 24 * 60 * 60; // 1 day in seconds
    daysOfPayments = (endDateOfPayments - startDateOfPayments) / periodOfOnePayments; // 184 days
    limitPerPeriod = originalBalance / daysOfPayments;
  }


  /// @dev Fallback function: don't accept ETH
  function()
    public
    payable
  {
    revert();
  }


  /// @dev Get current balance of the contract
  function getBalance()
    constant
    public
    returns(uint)
  {
    return company_token.balanceOf(this);
  }


  function setOwner(address _owner) 
    public 
    onlyOwner 
  {
    require(_owner != 0);
     
    owner = _owner;
    emit OwnerChanged(owner);
  }
  
  function sendCurrentPayment() public {
    if (now > startDateOfPayments) {
      uint currentPeriod = (now - startDateOfPayments) / periodOfOnePayments;
      uint currentLimit = currentPeriod * limitPerPeriod;
      uint unsealedAmount = currentLimit - alreadyTransfered;
      if (unsealedAmount > 0) {
        if (currentBalance >= unsealedAmount) {
          company_token.transfer(PartnerAccount, unsealedAmount);
          alreadyTransfered += unsealedAmount;
          currentBalance -= unsealedAmount;
          emit Transfer(PartnerAccount, unsealedAmount);
        } else {
          company_token.transfer(PartnerAccount, currentBalance);
          alreadyTransfered += currentBalance;
          currentBalance -= currentBalance;
          emit Transfer(PartnerAccount, currentBalance);
        }
      }
	  }
  }
}