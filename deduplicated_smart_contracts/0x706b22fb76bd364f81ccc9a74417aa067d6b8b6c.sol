/**
 *Submitted for verification at Etherscan.io on 2020-07-26
*/

pragma solidity 0.5.14;
          
          //------ busniness plan ------
        
            // www.theauriga.io package amount
        
                // 1)	0.05 eth
                // 2)	0.10 eth
                // 3)	0.20 eth
                // 4)	0.50 eth
                // 5)	1 eth
                // 6)	 2 eth
                // 7)	5 eth
                // 8)	10 eth
                // 9)	25 eth
                // 10)	 50 eth
                // 11)	 100 eth  
                
                
                // Direct income
                
                // 30% = 20%
                // 40% = 10%
                // 50%  after two sponsor user will get 
                // 50%  one step direct income if sponsor will not 
                // available in next plan maintenance fee 1% excluded
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
contract TheAuriga {
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