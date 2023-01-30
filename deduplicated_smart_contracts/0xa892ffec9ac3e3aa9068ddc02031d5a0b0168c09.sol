/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.5.8;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        
	    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface token {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address owner, address buyer, uint numTokens) external;
    function approve(address delegate, uint numTokens) external;
}

contract Crowdsale {
    using SafeMath for uint256;
    
    
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
    // public
    address payable public ownerWallet;
    mapping(address => uint256) public balanceOf;
    token public reward;
    
    
    // protected
    uint256 internal stage_ = 0;
    mapping (uint256 => uint256) internal totalHolders;
    mapping (uint256 => uint256) internal totalSold;
    mapping (uint256 => uint256) internal totalEth;
    
    
    // vars
    uint256 price_ = 1 szabo;
    uint256 MAX_UINT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    
    
    /**
     * Internal setters
     */
     
    // Setter for token reward
    function setReward(address tokenAddress) internal
    {
        require(msg.sender == ownerWallet);
        
        reward = token(tokenAddress);
    }
    
    // Setting counters for stage
    function setCounters(uint256 holders, uint256 sold, uint256 eth) internal
    {
        totalHolders[stage_] = holders;
        totalSold[stage_] = sold;
        totalEth[stage_] = eth;
    }
    

    /**
     * Public setters
     */
     
    // Price setter for owner only
    function setPrice(uint256 price) public
    {
        require(msg.sender == ownerWallet);
        require(price > 0);
        require(price <= MAX_UINT);
        
        price_ = price * 1 szabo;
    }

    // Next stage trigger for owner only
    function nextStage() public
    {
        require(msg.sender == ownerWallet);
        
        stage_ = SafeMath.add(stage_, 1);
        
        // Reset counters
        setCounters(0, 0, 0);
    }
    
    
    /**
     * Internal array getters
     */
     
    function getSoldArray() internal view returns (uint256[] memory)
    {
        uint256[] memory memoryArray = new uint256[](stage_);
        for(uint256 i = 0; i < stage_; i++) {
            memoryArray[i] = totalSold[i+1];
        }
        return memoryArray;
    }
    
    function getEthArray() internal view returns (uint256[] memory)
    {
        uint256[] memory memoryArray = new uint256[](stage_);
        for(uint256 i = 0; i < stage_; i++) {
            memoryArray[i] = totalEth[i+1];
        }
        return memoryArray;
    }
    
    function getHoldersArray() internal view returns (uint256[] memory)
    {
        uint256[] memory memoryArray = new uint256[](stage_);
        for(uint256 i = 0; i < stage_; i++) {
            memoryArray[i] = totalHolders[i+1];
        }
        return memoryArray;
    }
    
    
    /**
     * Public views
     */
     
    // Public price getter
    function price() public view returns (uint256)
    {
        return price_;
    }
    
    // Public counter getter
    function getCounters() public view returns (uint256[] memory, uint256[] memory, uint256[] memory)  {
        return (getSoldArray(), getEthArray(), getHoldersArray());
    }

    /**
     * Constructor function
     */
    constructor(
        address payable ownerAddress,
        uint256 startPrice,
        address tokenAddress
    ) public {
        // Require owner address and startPrice
        require(startPrice > 0);
        // Set owner
        ownerWallet = ownerAddress;
        // Set token reward
        setReward(tokenAddress);
        // Set start price
        setPrice(startPrice);
        
        // Starting stage
        nextStage();
    }


    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () external payable {
        require (msg.value < MAX_UINT);
        require (msg.value >= price_);
        
        uint amount = msg.value;
        // Calculate token amount
        uint tokenAmount = SafeMath.div(amount, price_);
        
        // Modify counters
        if (balanceOf[msg.sender] == 0) {
            totalHolders[stage_] = SafeMath.add(totalHolders[stage_], 1);
        }
        totalSold[stage_] = SafeMath.add(totalSold[stage_], tokenAmount);
        totalEth[stage_] = SafeMath.add(totalEth[stage_], amount);
        
        balanceOf[msg.sender] = balanceOf[msg.sender] + amount;
        emit FundTransfer(msg.sender, amount, true);
        
        ownerWallet.transfer(amount);
        reward.transferFrom(ownerWallet, msg.sender, tokenAmount);
    }
}