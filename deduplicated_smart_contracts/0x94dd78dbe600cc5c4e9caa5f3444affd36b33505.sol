pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

//Submit ETH to show how big your "Eth penis" is. Each submission
//bigger than the prior is awarded 20% of the original added to
//their ETH amount. The biggest previous submitter gets 80% of
//their original submission back. The biggest ETH dick for 1 day
//wins the total accrued balance. During cashout the creator gets
//1% and the winner gets the rest. The winner can be paid and the
//game reset by calling "Withdraw()".
contract EthDickMeasuringGamev2 {
    address owner;
    address public largestPenisOwner;
    uint256 public largestPenis;
    uint256 public withdrawDate;

    function EthDickMeasuringGamev2() public{
        owner = msg.sender;
        largestPenisOwner = 0;
        largestPenis = 0;
    }

    function () public payable{
        require(largestPenis < msg.value);
        address prevOwner = largestPenisOwner;
        uint256 prevSize = largestPenis;
        
        largestPenisOwner = msg.sender;
        largestPenis = msg.value;
        withdrawDate = now;
        
        //Verify this isn&#39;t a new round. Then
        //send back eth to smaller penis submission
        if(prevOwner != 0x0)
            prevOwner.transfer(SafeMath.div(SafeMath.mul(prevSize, 80),100));

    }

    function withdraw() public{
        require(now >= withdrawDate);
        address roundWinner = largestPenisOwner;

        //Reset game
        largestPenis = 0;
        largestPenisOwner = 0;

        //Judging penises isn&#39;t a fun job
        //taking my 1% from the total prize.
        owner.transfer(SafeMath.div(SafeMath.mul(this.balance, 1),100));
        
        //Congratulation on your giant penis
        roundWinner.transfer(this.balance);
    }
}