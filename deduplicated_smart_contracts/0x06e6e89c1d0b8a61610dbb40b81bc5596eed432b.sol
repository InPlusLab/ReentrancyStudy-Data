/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma experimental ABIEncoderV2;

contract manyTests {
    uint256 a;
    string b = "I am view";
    uint256 c;
    
    function addSomeMoreRandomStuff(address[] memory tokens) public {
        c = c + 1;
    }
    
    function showMePure() pure public returns (string memory) {
        return "I am pure";
    }
    
    function showMeView() view public returns (string memory) {
        return b;
    }
}