/**

 *Submitted for verification at Etherscan.io on 2018-10-15

*/



pragma solidity ^0.4.25;



///////////////////////////////////////////////////////////

//

// The Train That Never Stops

//

// https://thetrainthatneverstops.blogspot.com/

//

// Catch the train now and become a passenger for ever!

//

// This train size: L

// Seat cost: 1 ether

// Jackpots: 1, 10 and 100 ether

//

// Send EXACTLY 1 ether to the contract address (other amounts are rejected)

// Set gas limit to 300'000

//

// 20% (.2 ether) goes immediately to a random selected passenger

// 20% (.2 ether) goes to Jackpot 1

// 20% (.2 ether) goes to Jackpot 2

// 20% (.2 ether) goes to Jackpot 3

// 20% (.2 ether) goes to the train driver (reinvested in marketing)

//

// Every 5 passenger Jackpot 1 (1 ether) goes to a random selected passenger

// Every 50 passenger Jackpot 2 (10 ether) goes to a random selected passenger

// Every 500 passenger Jackpot 3 (100 ether) goes to a random selected passenger

// 

// ==> Invite others to join! The more passengers, the more you win! <==

//

//////////////////////////////////////////////////////////



contract TheTrainL {

    // Creator of the contract

    address traindriver;                   

    // The actual number of passengers

    uint256 public numbofpassengers = 0;    

    // Winnig seat and (pseudo)random used to select the winning passengers

    uint256 winseat = 0;

    uint256 randomhash;

    // The amount of the 3 Jackpots

    uint256 public jackpot1 = 0;

    uint256 public jackpot2 = 0;

    uint256 public jackpot3 = 0;

    // Modulo is used to detect when Jackpots are to be paid

    uint256 modulo = 0;

    // The exact cost to become a passenger

    uint256 seatprice = 1 ether; // Seat price for Small train

    // The percentage to distribute (20%)

    uint256 percent = seatprice / 10 * 2;

    

    // Recording passenger address and it's gain

    struct Passenger{

        address passengeraddress;

        uint gain;

    }

    

    // The list of all passengers

    Passenger[] passengers;

    

    // Contract constructor

    constructor() public {

        traindriver = msg.sender; // Train driver is the contract creator

    }

    

    function() external payable{

        

        if (msg.value != seatprice) revert(); // Exact seat price or stop

        

        // Add passenger to the list

        passengers.push(Passenger({

            passengeraddress: msg.sender, // Record passenger address

            gain: 0

        }));

        

        numbofpassengers++; // One more passenger welcome

        

        // send part to train driver

        traindriver.transfer(percent);

        

        // take random number to select a winning passenger

        randomhash = uint256(blockhash(block.number -1)) + numbofpassengers;

        winseat = randomhash % numbofpassengers; // can be any seat

        

        // send part to winning passenger

        passengers[winseat].passengeraddress.transfer(percent);

         

        // Jackpot 1

        jackpot1 += percent; // Add value to Jackpot 1

        modulo = numbofpassengers % 5; // Every 5 passenger

        if (modulo == 0) // It's time to pay Jackpot 1

        {

            randomhash = uint256(blockhash(block.number -2));

            winseat = randomhash % numbofpassengers; // can be any seat

            passengers[winseat].passengeraddress.transfer(jackpot1);

            jackpot1 = 0; // reset Jackpot

        }

        

        // Jackpot 2

        jackpot2 += percent;

        modulo = numbofpassengers % 50; // Every 50 passenger

        if (modulo == 0) // It's time to pay Jackpot 2

        {

            randomhash = uint256(blockhash(block.number -3));

            winseat = randomhash % numbofpassengers; // can be any seat

            passengers[winseat].passengeraddress.transfer(jackpot2);

            jackpot2 = 0; // reset Jackpot

        }

        

        // Jackpot 3

        jackpot3 += percent;

        modulo = numbofpassengers % 500; // Every 500 passenger

        if (modulo == 0) // It's time to pay Jackpot 3

        {

            randomhash = uint256(blockhash(block.number -4));

            winseat = randomhash % numbofpassengers; // can be any seat

            passengers[winseat].passengeraddress.transfer(jackpot3);

            jackpot3 = 0; // reset Jackpot

        }

    }

}