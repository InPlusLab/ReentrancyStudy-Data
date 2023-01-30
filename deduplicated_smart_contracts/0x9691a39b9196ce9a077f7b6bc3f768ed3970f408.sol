/**
 *Submitted for verification at Etherscan.io on 2019-10-12
*/

pragma solidity ^0.5.11; 

contract ERC20 {
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
}

contract HydraVesting {
    
    address payable public owner;
    address public tokenAddress = 0xD99b3a47115F595517efA80A8158a4A9B620Cc40;
    uint256 public totalYears = 4;
    uint256 public timeLock = 365 days;
    uint256 public creationTime;
    uint256 public nextUnlock;
    string public ownerName;
    
    constructor(address payable _owner, string memory _ownerName) public {
        
        owner = _owner;
        creationTime = now;
        ownerName = _ownerName;
        nextUnlock = creationTime + timeLock;
        
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function() payable external {
    }
    
    function unlockTokens() external onlyOwner {
        require(now > nextUnlock);
        
        nextUnlock = nextUnlock + timeLock;
        totalYears = totalYears - 1;
        
        if (totalYears > 0) {

            uint256 withdrawBalance = ERC20(tokenAddress).balanceOf(address(this));
            uint256 yearlyAllowance = withdrawBalance * 2500 / 10000;
            ERC20(tokenAddress).transfer(owner, yearlyAllowance);
            
        } else {
            
            uint256 remainingBalance = ERC20(tokenAddress).balanceOf(address(this));
            ERC20(tokenAddress).transfer(owner, remainingBalance);
            
        }
    }
    
    function canUnlock() public view returns (bool) {
        return now > nextUnlock;
    }
    
}