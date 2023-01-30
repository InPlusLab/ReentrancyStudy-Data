/**

 *Submitted for verification at Etherscan.io on 2019-01-29

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



contract SwapContractPDATAtoURUN {

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

    PartnerAccount = 0x09162Bd9C5BfB9e39E87Ce3e39B558a5546710b8;

    company_token = _company_token;

    originalBalance = 10000000 * 10**18; // 10 000 000 PDATA

    currentBalance = originalBalance;

    alreadyTransfered = 0;

    startDateOfPayments = 1556661600; //From 01 May 2019, 00:00:00

    endDateOfPayments = 1572562800; //From 01 Nov 2019, 00:00:00

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