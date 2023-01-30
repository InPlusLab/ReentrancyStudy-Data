/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

contract TestThis {
    bool[2][] public test2;
    bool[3][] public test3;
    
    function addArray() public {
        test2.push([true, true]);
    }
    
    function addArray3() public {
        test3.push([true, true, true]);
    }
}