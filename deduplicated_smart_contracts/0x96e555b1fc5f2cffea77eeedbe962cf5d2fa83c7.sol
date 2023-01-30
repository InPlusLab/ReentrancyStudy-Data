/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.8;

contract GoncaloColorTeam {
    // this is ETHBerlin's donation address as per https://ethberlinzwei.com/
    address payable public beneficiary = 0x82338B1b27cfC0C27D79c3738B748f951Ab1a7A0;

    uint256 public amountContributedForBlueTeam;
    uint256 public amountContributedForRedTeam;
    
    // send the donations to the benficiary
    function claimDonation() public {
        beneficiary.transfer(address(this).balance);
    }

    function contributeBlue() public payable {
        amountContributedForBlueTeam += msg.value;
    }

    function contributeRed() public payable {
        amountContributedForRedTeam += msg.value;
    }
    
    function() external payable {
        if(msg.value % 2 == 0) {
            amountContributedForRedTeam += msg.value;
        } else {
            amountContributedForBlueTeam += msg.value;
        }
    }
    
    // returns 0 for "Tie", 1 for "Blue", 2 for "Red"
    function whoIsWinning() public view returns (uint256) {
        if(amountContributedForBlueTeam > amountContributedForRedTeam) {
            return 1;
        } else if (amountContributedForBlueTeam < amountContributedForRedTeam) {
            return 2;
        }
        
        return 0;
    }
}