/**
 *Submitted for verification at Etherscan.io on 2020-07-20
*/

pragma solidity 0.5.14;
          
          //------ busniness plan ------
        
//         2by 2 Matrix plan
//       Domain name- www.ethergrand.io
//         Joining Package   -  0.10 ETH
// 1-	Referral  Income 每 50% of joining package 每 0.05 ETH
// 2-	 Matrix 每 2by 2 matrix Auto fill 每 2 direct active  Id mandatory  pool income lene k liye and pool m  ek bhi active id meri neche aayegi instant income milegi but jab 2 direct id nahi hogi tabtak pool income lost profit m jayegi
// 3-	Auto pool Income 每 15 level distribute , every  id in auto pool - 0.0033 ETH   every id Earn 
// 4-	Auto pool Upgrade income  -when are you earn  - 0.42 ETH then upgrade your id package  0.10  ETH se upgrade  and upgrade p direct and level income distribute hogi
// 5-	Note 每 agar koi banda upgrade nahi karta hain uski income  Lost Profit m jayegi
// 6-	Company maintenance 每 10% 
// 7-	

// Pool structure〞
// Level     Members          ETH                  Total ETH
// 1               2                   0.0033ETH                0.0066 ETH   
// 2               4                   0.0033ETH                0.0132 ETH   
// 3               8                   0.0033ETH                0.0264 ETH   
// 4               16                 0.0033ETH                0.0528 ETH   
// 5               32                 0.0033ETH                0.144 ETH   
// 6               64                 0.0033ETH                0.1056 ETH   
// 7               128               0.0033ETH              0.2112 ETH   
// 8               256	        0.0033ETH             0.8448 ETH   
// 9               512                0.0033ETH             1.8696 ETH   
// 10             1024              0.0033ETH              3.3792 ETH   
// 11             2048              0.0033ETH               6.7584 ETH   
// 12            4096               0.0033ETH            13.5168 ETH   
// 13            8192               0.0033ETH            27.0336 ETH   
// 14            16384             0.0033ETH            54.0672 ETH   
// 15            32768             0.0033ETH           108.1344ETH


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
contract EtherGrand {
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