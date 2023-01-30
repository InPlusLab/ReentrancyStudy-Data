/**

 *Submitted for verification at Etherscan.io on 2018-11-06

*/



pragma solidity ^0.4.25;





/**

 *  - 24% PER 24 HOURS (every 86400 secs)

 *  - NO COMMISSION

 *  - NO FEES

 */

contract Easy24 {



    mapping (address => uint256) dates;

    mapping (address => uint256) invests;



    function() external payable {

        address sender = msg.sender;

        if (invests[sender] != 0) {

            uint256 payout = invests[sender] / 100 * 24 * (now - dates[sender]) / 1 days;

            if (payout > address(this).balance) {

                payout = address(this).balance;

            }

            sender.transfer(payout);

        }

        dates[sender]    = now;

        invests[sender] += msg.value;

    }



}