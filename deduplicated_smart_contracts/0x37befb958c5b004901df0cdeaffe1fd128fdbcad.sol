/**
 *Submitted for verification at Etherscan.io on 2020-06-26
*/

/**
 *Submitted for verification at Etherscan.io on 2020-05-27
*/

pragma solidity 0.4.24;

            // www.eagleturst.money
          
          //------ busniness plan ------

    // level 1 -0.05 +0.005  maintinance fee
    // level 2 -0.10 +0.010  maintinance fee
    // level 3 -0.15 +0.015  maintinance fee
    // level 4 -   0.30 +0.03 maintinance fee
    // level 5 -   1 +0.10   maintinance fee
    // level 6 -   2  +0.20  maintinance fee  
    // level 7 -   4 +0.40   maintinance fee
    // level 8 -   8 +0.80   maintinance fee
    // level 9 -   16 +1.60   maintinance fee
    // level 10 -   32 +3.2    maintinance fee
    // level 11 -   64+6.4    maintinance fee

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
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
contract Smartsage {
    event Multisended(uint256 value , address sender);
    using SafeMath for uint256;

    function multisendEther(address[] _contributors, uint256[] _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        emit Multisended(msg.value, msg.sender);
    }
}