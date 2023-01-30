/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma experimental ABIEncoderV2;

contract TestThis {
    bool[2][][] public test2;
    bool[3][] public test3;
    bool[][][] public test4;
    
    
    
    function addArrayManual(bool[][] memory _a) public {
        test4.push(_a);
    }
    
    function addArrayManual3(bool[3] memory _a) public {
        test3.push(_a);   
    }
    
    function addWeirdStuff(bool[][][] memory _a) public {
        
    }
}