/**

 *Submitted for verification at Etherscan.io on 2019-03-07

*/



pragma solidity 0.5.5;



contract IERC20 {

    function transfer(address to, uint256 value) public returns (bool) {}

}



contract Auction {



  uint256 public REWARD_PER_WIN = 625000000;

  uint256 public CREATOR_REWARD = 6250000;

  address public CREATOR_ADDRESS;

  address public GTT_ADDRESS;



  address public currWinner;   // winner

  uint256 public currHighest;  // highest bet

  uint256 public lastHighest;  // last highest bet

  uint256 public lastAuctionStart;



  constructor() public {

    CREATOR_ADDRESS = msg.sender;

    lastAuctionStart = block.number;

    currWinner = address(this);

  }



  // can only be called once

  function setTokenAddress(address _gttAddress) public {

    if (GTT_ADDRESS == address(0)) {

      GTT_ADDRESS = _gttAddress;

    }

  }



  function play() public payable {

    uint256 currentBlock = block.number;



    // pay out last block's winnings

    if (lastAuctionStart < currentBlock - 50) {

      payOut();



      // reset state for new auction

      lastAuctionStart = currentBlock;

      currWinner = address(this);

      lastHighest = currHighest;

      currHighest = 0;

    }



    // log winning tx

    if (msg.sender.balance > currHighest) {

      currHighest = msg.sender.balance;

      currWinner = msg.sender;

    }

  }



  function payOut() internal {

    IERC20(GTT_ADDRESS).transfer(currWinner, REWARD_PER_WIN);

    IERC20(GTT_ADDRESS).transfer(CREATOR_ADDRESS, CREATOR_REWARD);

  }

}