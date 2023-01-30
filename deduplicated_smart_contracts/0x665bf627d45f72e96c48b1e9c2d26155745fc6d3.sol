pragma solidity ^0.4.16;

/**
 * BittrexOpenSourceClone (BOSC) Crowd Sale
 */

interface token {
    function transfer(address receiver, uint amount);
}

contract BittrexOpenSourceCloneCrowdsale {
    address public beneficiary;
    uint public amountRaised;
    uint private currentBalance;
    uint public price;
    uint public initialTokenAmount;
    uint public currentTokenAmount;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function BittrexOpenSourceCloneCrowdsale(
        address sendTo,
        address addressOfTokenUsedAsReward
    ) {
        beneficiary = sendTo;
        /* 0.001 x 1 ether in wei */
        price = 1000000000000000;
        initialTokenAmount = 20000000;
        currentTokenAmount = 20000000;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable {
        uint amount = msg.value;
        if (amount > 0) {
            balanceOf[msg.sender] += amount;
            amountRaised += amount;
            currentBalance += amount;
            uint tokenAmount = amount / price;
            currentTokenAmount -= tokenAmount;
            tokenReward.transfer(msg.sender, tokenAmount * 1 ether);
        }
    }

    /**
     * Bank tokens
     *
     * Deposit token sale proceeds to BOSC Account
     */
    function bank() public {
        if (beneficiary == msg.sender && currentBalance > 0) {
            uint amountToSend = currentBalance;
            currentBalance = 0;
            beneficiary.send(amountToSend);
        }
    }
    
    /**
     * Withdraw unusold tokens
     *
     * Deposit unsold tokens to BOSC Account
     * 
     * Oops. Forgot to multiply currentTokenAmount * 1 ether
     * PTWO not sold in the crowdsale will be trapped in this contract
     */
    function returnUnsold() public {
        if (beneficiary == msg.sender) {
            tokenReward.transfer(beneficiary, currentTokenAmount * 1 ether);
        }
    }
    
    /**
     * Withdraw unusold tokens
     *
     * Deposit unsold tokens to BOSC Account 100k Safe
     * 
     * Oops. Forgot to multiply tokenAmount * 1 ether
     * PTWO not sold in the crowdsale will be trapped in this contract
     */
    function returnUnsoldSafe() public {
        if (beneficiary == msg.sender) {
            uint tokenAmount = 100000;
            tokenReward.transfer(beneficiary, tokenAmount * 1 ether);
        }
    }
}