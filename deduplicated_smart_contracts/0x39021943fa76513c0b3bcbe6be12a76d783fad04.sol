/**

 *Submitted for verification at Etherscan.io on 2018-11-28

*/



pragma solidity ^0.4.24;



contract Token {}

contract SafeMath {}

contract AbstractToken is Token, SafeMath {}



contract EstateToken is AbstractToken {

  mapping (address => uint256) internal accounts;

  function transfer (address _to, uint256 _value) public returns (bool);

  function balanceOf (address _owner) public view returns (uint256 balance);

}



contract SwapContractEstatetoPDATA {

  //storage

  address public owner;

  EstateToken public company_token;



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

  constructor (EstateToken _company_token) public {

    owner = msg.sender;

    PartnerAccount = 0xD99cc20B0699Ae9C8DA1640e03D05925ddD8acd2;

    company_token = _company_token;

    originalBalance = 5000000 * 10**8; // 5 000 000 EstateToken

    currentBalance = originalBalance;

    alreadyTransfered = 0;

    startDateOfPayments = 1559340000; //From 01 Jun 2019, 00:00:00

    endDateOfPayments = 1575154800; //From 01 Dec 2019, 00:00:00

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