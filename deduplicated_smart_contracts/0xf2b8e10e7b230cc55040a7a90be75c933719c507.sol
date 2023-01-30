pragma solidity ^0.4.6;

contract token { function transferFrom(address sender, address receiver, uint amount) returns(bool success){  } }

contract Crowdsale {
    /* if successful, the funds will be retrievable by this address */
    address public beneficiary = 0x003230bbe64eccd66f62913679c8966cf9f41166; 
    /* if the funding goal is not reached, investors may withdraw their funds */
    uint public fundingGoal = 50000000;
    /* the maximum amount of tokens to be sold */
    uint public maxGoal = 394240000; 
    /* how much has been raised by crowdale (in ETH) */
    uint public amountRaised; 
    /* the start date of the crowdsale */
    uint public start = 1487257200; 
    /* the number of tokens already sold */
    uint public tokensSold; 
    /* there are different prices in different time intervals */
    uint[4] public deadlines = [1487260800, 1487865600, 1488470400,1489075200];
    uint[4] public prices = [833333333333333, 909090909090909,952380952380952, 1000000000000000];
    /* the address of the token contract */
    token public tokenReward;
    /* the balances (in ETH) of all investors */
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    /* notifying transfers and the success of the crowdsale*/
    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    

    /*  initialization, set the token address */
    function Crowdsale( ) {
        tokenReward = token(0xc378b7e2f88f945be121d80edcbc31bc7259a983);
    }

    /* whenever anyone sends funds to a contract, the corresponding amount of tokens is transfered if the crowdsale started and hasn&#39;t been
        closed already and the maxGoal wasn&#39;t reached yet.*/
    function () payable{
        uint amount = msg.value;
        uint numTokens = amount / getPrice();
        if (crowdsaleClosed||now<start||tokensSold+numTokens>maxGoal) throw;
        balanceOf[msg.sender] = amount;
        amountRaised += amount;
        tokensSold+=numTokens;
        if(!tokenReward.transferFrom(beneficiary, msg.sender, numTokens)) throw;
        FundTransfer(msg.sender, amount, true);
    }
    
    /* looks up the current token price */
    function getPrice() constant returns (uint256 price){
        for(var i = 0; i < deadlines.length; i++)
            if(now<deadlines[i])
                return prices[i];
        return prices[prices.length-1];//should never be returned, but to be sure to not divide by 0
    }

    modifier afterDeadline() { if (now >= deadlines[deadlines.length-1]) _; }

    /* checks if the goal or time limit has been reached and ends the campaign */
    function checkGoalReached() afterDeadline {
        if (tokensSold >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    /* allows the beneficiary and/or the funders to withdraw their funds */
    function safeWithdrawal() afterDeadline {
        // if the goal hasn&#39;t been reached, investors may withdraw their funds
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
        //if the goal has benn reached and the beneficiary himself is the sender, he may withdraw everything
        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }
}