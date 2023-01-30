/**

 *Submitted for verification at Etherscan.io on 2019-01-20

*/



pragma solidity ^0.4.24;



contract RegistryICAPInterface{}

contract EToken2Interface{}

contract AssetInterface{}

contract ERC20Interface{}

contract AssetProxyInterface{}

contract Bytes32{}

contract ReturnData{}

contract CryptykToken is ERC20Interface, AssetProxyInterface, Bytes32, ReturnData{

    EToken2Interface public etoken2;

    function balanceOf(address _owner) constant returns(uint) {}

    function transfer(address _to, uint _value) returns(bool) {}

}



contract SwapContractCryptyktoPDATA {

    //storage

    address public owner;

    CryptykToken public company_token;



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

    constructor (CryptykToken _company_token) public {

        owner = msg.sender;

        PartnerAccount = 0xD99cc20B0699Ae9C8DA1640e03D05925ddD8acd2;

        company_token = _company_token;

        originalBalance = 8000000 * 10**8; // 8 000 000 Cryptyk Token

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