/**
 *Submitted for verification at Etherscan.io on 2020-07-15
*/

pragma solidity 0.5.14;
          
          //------ busniness plan ------
        
            //      Startup-0.1 eth
           
            // växalium v3/ växalium v4                
            // 1 - 0.05              1 - 0.05
            // 2 - 0.1                2 - 0.1
            // 3 - 0.2           3 - 0.2
            // 4 - 0.4          4 - 0.4
            // 5 - 0.8           5 - 0.8
            // 6 - 1.6           6 - 1.6
            // 7 - 3.2            7 - 3.2
            // 8 - 6.4             8 - 6.4
            // 9 - 12.4            9 - 12.4
            // 10 - 25.6         10 - 25.6
            // Maintenance charge :- 10%
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
contract Vaxalium {
    event Multisended(uint256 value , address sender);
    using SafeMath for uint256;

    function multisendEther(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
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