/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

contract TestThis {
    bool[2][][] public test2;
    bool[3][] public test3;
    
    
    function addArray3() public {
        test3.push([true, true, true]);
    }
    
    function addArrayManual(bool[2][] memory _a) public {
        test2.push(_a);
    }
    
    function addArrayManual3(bool[3] memory _a) public {
        test3.push(_a);   
    }
}