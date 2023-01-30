/**
 *Submitted for verification at Etherscan.io on 2020-06-09
*/

pragma solidity 0.4.24;
          
          //------ busniness plan ------


        // Cyber trust.money business plan
        // Packages
        // S.No	Packages	Levels
        // 1	0.22 eth	 Pool-1
        // 2	0.50 eth	Pool-2
        // 3	1.00 eth	Pool-3
        // 4	3.00 eth	Pool-4
        // 5	5.00 eth	Pool-5
        
        // Pool-1
        // Level	Member	ETH	Income
        // 1	3	0.01	0.03
        // 2	9	0.01	0.09
        // 3	27	0.01	0.27
        // 4	81	0.01	0.81
        // 5	243	0.01	2.43
        // 6	729	0.01	7.29
        // 7	2187	0.01	21.87
        // 8	6567	0.01	65.61
        // 9	19683	0.01	196.83
        // 10	59049	0.01	590.49
        
        // Pool-2
        // Level	Member	ETH	Income
        // 1	3	0.03	0.9
        // 2	9	0.03	0.27
        // 3	27	0.03	0.81
        // 4	81	0.03	2.43
        // 5	243	0.03	7.29
        // 6	729	0.03	21.87
        // 7	2187	0.03	65.61
        // 8	6567	0.03	196.83
        // 9	19683	0.03	590.49
        // 10	59049	0.03	1771.47
        
        
        
        
        // Pool-3
        // Level	Member	ETH	Income
        // 1	3	0.06	0.18
        // 2	9	0.06	0.54
        // 3	27	0.06	1.62
        // 4	81	0.06	4.86
        // 5	243	0.06	14.58
        // 6	729	 0.06 43.74
        // 7	2187	0.06	131.22
        // 8	6567	0.06	393.66
        // 9	19683	0.06	1180.98
        // 10	59049	0.06	3542.94
        // Pool-4
        // Level	Member	ETH	Income
        // 1	3	0.18	0.54
        // 2	9	0.18	1.62
        // 3	27	0.18	4.86
        // 4	81	0.18	14.58
        // 5	243	0.18	43.74
        // 6	729	0.18	131.22
        // 7	2187	0.18	393.66
        // 8	6567	0.18	1180.98
        // 9	19683	0.18	3542.94
        // 10	59049	0.18	10628.82
        
        // Pool-5
        // Level	Member	ETH	Income
        // 1	3	0.30	0.9
        // 2	9	0.30	2.7
        // 3	27	0.30	8.1
        // 4	81	0.30	24.3
        // 5	243	0.30	72.9
        // 6	729	0.30	218.7
        // 7	2187	0.30	656.1
        // 8	6567	0.30	1968.3
        // 9	19683	0.30	5904.9
        // 10	59049	0.30	17714.7
        			
        
        
        // Direct sponcer income
        // Pool one sponser income 0.10
        // Pool Two sponcer income 0.15
        // Pool three sponcer income 0.30
        // Pool four sponser income 0.90
        // Pool five sponcer income 1.50
        // Company maintenance
        
        // Pool 1   0.02
        
        // Pool 2    0.05
        
        // Pool 3    0.10
        
        // Pool 4    0.30
        
        // Pool 5     0.50
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
contract CyberTrustMoney {
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