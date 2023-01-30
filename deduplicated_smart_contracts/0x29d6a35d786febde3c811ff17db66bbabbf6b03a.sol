/**
 *Submitted for verification at Etherscan.io on 2019-12-26
*/

contract shortContract2 {
    
    uint256 public x;
    uint256 public y;
    uint256 public z;
    
    function overload1(uint256 _x, uint256 _y, uint256 _z) public {
        x = _x;
        y = _y;
        z = _z;
    }
    
    function overload1(uint256 _x, uint256 _y) public {
        x = _x;
        y = _y;
    }
}