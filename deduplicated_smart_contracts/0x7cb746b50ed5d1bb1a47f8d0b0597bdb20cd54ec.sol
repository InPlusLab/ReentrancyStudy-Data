/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma experimental ABIEncoderV2;

contract manyTests {
    uint256 a;
    string b = "I am view";
    
    function addSomeRandomStuff(address[][] memory tokens) public {
         a = a + 1;
    }
    
    function showMePure() pure public returns (string memory) {
        return "I am pure";
    }
    
    function showMeView() view public returns (string memory) {
        return b;
    }
}