/**
 *Submitted for verification at Etherscan.io on 2020-12-12
*/

pragma solidity ^0.4.25;

// In honor of the world's first AMM

contract SquidFarmer{
    uint256 constant STARTING_SQUID = 1 hours * 1 hours;
    uint256 constant STARTING_FEE = 100e18;
    uint256 constant PSN = 8192;
    uint256 constant PSNH = 4096;
    ERC20 constant token = ERC20(0x0E29e5AbbB5FD88e28b2d355774e73BD47dE3bcd);
    address constant bankAddress = address(0x83D0D842e6DB3B020f384a2af11bD14787BEC8E7);

    uint256 public marketEggs;
    bool public initialized;
    mapping (address => uint256) public hatcherySquid;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;

    function hatchEggs(address ref) public {
        require(initialized);
        if (ref != address(0)) referrals[msg.sender] = ref;
        uint256 eggsUsed = getMyEggs(msg.sender);
        hatcherySquid[msg.sender] = SafeMath.add(hatcherySquid[msg.sender], eggsUsed);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        
        //send referral eggs
        claimedEggs[referrals[msg.sender]] = SafeMath.add(claimedEggs[referrals[msg.sender]], SafeMath.div(eggsUsed, 15));
        
        //boost market to nerf squid hoarding
        marketEggs = SafeMath.add(marketEggs,SafeMath.div(eggsUsed, 10));
    }

    function sellEggs() public {
        require(initialized);
        uint256 eggsSold = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(eggsSold);
        uint256 fee = devFee(eggValue);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = now;
        marketEggs = SafeMath.add(marketEggs, eggsSold);
        require(bankAddress.call.value(fee)());
        require(msg.sender.call.value(SafeMath.sub(eggValue, fee))());
    }

    function buyEggs() public payable {
        require(initialized);
        require(hatcherySquid[msg.sender] > 0);
        uint256 eggsBought = calculateEggBuy(msg.value, SafeMath.sub(getBalance(), msg.value));
        eggsBought = SafeMath.sub(eggsBought,devFee(eggsBought));
        require(bankAddress.call.value(devFee(msg.value))());
        claimedEggs[msg.sender] = SafeMath.add(claimedEggs[msg.sender], eggsBought);
    }

    function () public payable {
        buyEggs();
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public pure returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs,marketEggs, getBalance());
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth,contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, getBalance());
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return SafeMath.div(amount, 20);
    }

    function seedMarket(uint256 eggs) public payable {
        require(marketEggs == 0);
        initialized = true;
        marketEggs = eggs;
    }

    function getFirstSquid() public {
        require(initialized);
        require(hatcherySquid[msg.sender] == 0);
        require(token.transferFrom(msg.sender, bankAddress, STARTING_FEE));
        lastHatch[msg.sender] = now;
        hatcherySquid[msg.sender] = STARTING_SQUID;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMySquid(address adr) public view returns (uint256) {
        return hatcherySquid[adr];
    }

    function getMyEggs(address adr) public view returns (uint256) {
        return SafeMath.add(claimedEggs[adr], getEggsSinceLastHatch(adr));
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 quadraticSquid = SafeMath.sqrt(hatcherySquid[adr]);
        uint256 secondsPassed = min(quadraticSquid, SafeMath.sub(now, lastHatch[adr]));
        return SafeMath.mul(secondsPassed, quadraticSquid);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}

library SafeMath {

    function sqrt(uint256 x) internal pure returns (uint256) {
        uint256 z = add(x >> 1, 1);
        uint256 y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z), z)) / 2);
        }
        return y;
    }

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        return a / b;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}