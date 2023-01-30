/**
 *Submitted for verification at Etherscan.io on 2019-10-23
*/

pragma solidity >0.4.99 <0.6.0;
contract miner{
    address payable sylvain;
    address payable jerome;
    
    constructor () public {
        sylvain = 0x6120932248DaFbDDb7e97279e10F9348b0E0242c;
        jerome = 0xAC9ba72fb61aA7c31A95df0A8b6ebA6f41EF875e;
    }
    
    function () external payable {}
    
    function withdraw() public {
        uint256 share = address(this).balance/5;
        address(jerome).transfer(share);
        address(sylvain).transfer(address(this).balance);
    }
}