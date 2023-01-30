/**
 *Submitted for verification at Etherscan.io on 2019-12-08
*/

pragma solidity ^0.5.0;

contract HTMLBodyColor {
    
    string private _body;
    
    constructor(string memory color) public {
        _body = string(abi.encodePacked("body{background-color:", color,";}"));
    }
    
    function read() public view returns(string memory) {
        return _body;
    }
}