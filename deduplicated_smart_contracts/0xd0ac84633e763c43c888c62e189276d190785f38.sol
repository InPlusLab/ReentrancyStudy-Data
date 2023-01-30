/**

 *Submitted for verification at Etherscan.io on 2019-01-22

*/



pragma solidity ^0.4.24;



contract ERC20Basic {}

contract ERC20 is ERC20Basic {}

contract Ownable {}

contract BasicToken is ERC20Basic {}

contract StandardToken is ERC20, BasicToken {}

contract Pausable is Ownable {}

contract PausableToken is StandardToken, Pausable {}

contract MintableToken is StandardToken, Ownable {}



contract OpiriaToken is MintableToken, PausableToken {

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool);

  function balanceOf(address who) public view returns (uint256);

}



contract SwapContractPDATAtoCryptyk {

  //storage

  address public owner;

  OpiriaToken public company_token;



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

  constructor (OpiriaToken _company_token) public {

    owner = msg.sender;

    PartnerAccount = 0x23503f36dACE6f327223c4856a7311d71072A020;

    company_token = _company_token;

    originalBalance = 10000000 * 10**18; // 10 000 000 PDATA

    currentBalance = originalBalance;

    alreadyTransfered = 0;

    startDateOfPayments = 1564617600; //From 01 Aug 2019, 00:00:00

    endDateOfPayments = 1580515200; //To 01 Feb 2020, 00:00:00

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