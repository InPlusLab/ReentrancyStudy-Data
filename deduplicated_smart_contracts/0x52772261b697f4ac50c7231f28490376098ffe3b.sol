/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

pragma solidity >=0.4.22 <0.6.0;

contract Hold
{
    uint256 public time;
    address payable public owner;
    
    constructor () public {
        
        owner = msg.sender;
        time = now + 5 minutes;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    modifier checkTime(uint256 _time) {
        require(time <= _time);
        _;
    }
    
    function setTime(uint256 _time) public checkTime(_time) onlyOwner {
        
        time = _time;
    }
    
    function getEthereum() public checkTime(now) onlyOwner {
        
        owner.transfer(address(this).balance);
        
    }
    
    function () payable external {
        
    }
}