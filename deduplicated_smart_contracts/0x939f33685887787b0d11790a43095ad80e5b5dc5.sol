/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.10;

/**
 * Will miners include a 0 gwei transaction if they are rewarded by funds held in a smart contract?
 * Let's find out.
 *
 * The first miner to process the 0 gwei rewardMiner() transaction sent from the contract creator's account gets 0.069 ETH.
 * This assumes a miner can know the current block's coinbase at execution.
 * This also assumes miners pay attention to this sort of stuff.
 *
 * If this works, it opens up the possibilies for a "shadow" fee market where certain transactions can be mined from accounts with 0 balance.
 */

contract FreeEthForMiners {

	address public creator;

	constructor() payable public {
		creator = msg.sender;
		require(msg.value == 0.069 ether);
	}

	function rewardMiner() external {
		if (tx.gasprice == 0 && msg.sender == creator) {
			block.coinbase.transfer(address(this).balance);
		}
	}

}