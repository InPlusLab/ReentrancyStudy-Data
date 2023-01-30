/**
 *Submitted for verification at Etherscan.io on 2020-04-28
*/

pragma solidity ^0.4.10;

contract sko_ping {

    mapping(address => uint256) public ts;
    mapping(address => uint256) public rank;
    uint256 public n = 1;
    
    event REC(address a, uint256 t, uint256 r);
    
    constructor() public {}
    
    function ping() public {
        require (ts[msg.sender] == 0);
        ts[msg.sender] = now;
        rank[msg.sender] = n;
        emit REC(msg.sender, now, n);
        n = n+1;
    }

}