/**

 *Submitted for verification at Etherscan.io on 2019-03-12

*/



pragma solidity ^0.4.24;



contract ERC20Basic {}

contract ERC20 is ERC20Basic {}

contract BasicToken is ERC20Basic {}

contract StandardToken is ERC20, BasicToken {}

contract Ownable {}

contract CouponTokenConfig {}

contract CouponToken is StandardToken, Ownable, CouponTokenConfig {

    mapping(address => uint256) balances;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

}



contract SwapContractCCTtoPDATA {

    //storage

    address public owner;

    CouponToken public company_token;



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

    constructor (CouponToken _company_token) public {

        owner = msg.sender;

        PartnerAccount = 0xD99cc20B0699Ae9C8DA1640e03D05925ddD8acd2;

        company_token = _company_token;

        originalBalance = 11111111 * 10 ** 18; // 11 111 111 CCT Token

        currentBalance = originalBalance;

        alreadyTransfered = 0;

        startDateOfPayments = 1569888001; //From 01 Oct 2019, 00:00:01

        endDateOfPayments = 1590969601; //To 01 Apr 2020, 00:00:01

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