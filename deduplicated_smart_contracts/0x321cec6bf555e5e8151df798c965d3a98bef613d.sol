/**
 *Submitted for verification at Etherscan.io on 2020-01-16
*/

pragma solidity >= 0.5.0 < 0.6.0;

contract  niguezRandomityEngine {

  function ra() external view returns (uint256);
	function rb() external view returns (uint256);
	function rc() external view returns (uint256);
	function rd() external view returns (uint256);
	function re() external view returns (uint256);
	function rf() external view returns (uint256);
	function rg() external view returns (uint256);
	function rh() external view returns (uint256);
	function ri() external view returns (uint256);
	function rj() external view returns (uint256);
	function rk() external view returns (uint256);
	function rl() external view returns (uint256);
	function rm() external view returns (uint256);
	function rn() external view returns (uint256);
	function ro() external view returns (uint256);
	function rp() external view returns (uint256);
	function rq() external view returns (uint256);
	function rr() external view returns (uint256);
	function rs() external view returns (uint256);
	function rt() external view returns (uint256);
	function ru() external view returns (uint256);
	function rv() external view returns (uint256);
	function rw() external view returns (uint256);
	function rx() external view returns (uint256);
}

contract usingNRE {

    niguezRandomityEngine internal nre = niguezRandomityEngine(0x031eaE8a8105217ab64359D4361022d0947f4572);
    
    function ra() internal view returns (uint256) {
        return nre.ra();
    }
	
	function rb() internal view returns (uint256) {
        return nre.rb();
    }
	
	function rc() internal view returns (uint256) {
        return nre.rc();
    }
	
	function rd() internal view returns (uint256) {
        return nre.rd();
    }
	
	function re() internal view returns (uint256) {
        return nre.re();
    }
	
	function rf() internal view returns (uint256) {
        return nre.rf();
    }
	
	function rg() internal view returns (uint256) {
        return nre.rg();
    }
	
	function rh() internal view returns (uint256) {
        return nre.rh();
    }
	
	function ri() internal view returns (uint256) {
        return nre.ri();
    }
	
	function rj() internal view returns (uint256) {
        return nre.rj();
    }
	
	function rk() internal view returns (uint256) {
        return nre.rk();
    }
	
	function rl() internal view returns (uint256) {
        return nre.rl();
    }
	
	function rm() internal view returns (uint256) {
        return nre.rm();
    }
	
	function rn() internal view returns (uint256) {
        return nre.rn();
    }
	
	function ro() internal view returns (uint256) {
        return nre.ro();
    }
	
	function rp() internal view returns (uint256) {
        return nre.rp();
    }
	
	function rq() internal view returns (uint256) {
        return nre.rq();
    }
	
	function rr() internal view returns (uint256) {
        return nre.rr();
    }
	
	function rs() internal view returns (uint256) {
        return nre.rs();
    }
	
	function rt() internal view returns (uint256) {
        return nre.rt();
    }
	
	function ru() internal view returns (uint256) {
        return nre.ru();
    }
	
	function rv() internal view returns (uint256) {
        return nre.rv();
    }
	
	function rw() internal view returns (uint256) {
        return nre.rw();
    }
	
	function rx() internal view returns (uint256) {
        return nre.rx();
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract LuckyNumbers is usingNRE {
    
    address _hex = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
    address _dev = 0xDcD44e713bdc830B72e9F90df96aF97Ee6CA64fb;
    uint _hexDecimal = 100000000;
    
    mapping(address => uint) public unclaimedPrizes;
    
    // the prize pool in HEX
    uint public pot = 0;
    uint nextRound = 0;
    uint constant public cost = 10000;
    uint public luckyNumber;
    uint public max = 1000;
    uint _devBalance = 0;
    bool gamesStarted = false;
    uint8 random = 0;
    
    event NewTry(
        address participant,
        uint luckyNumber,
        uint timestamp
    );
    
    event PotWon(
        address winner,
        uint amount,
        uint timestamp
    );
    
    event jackpotClaimed(
        address winner,
        uint amount,
        uint timestamp
    );
    
    constructor(uint __luckyNumber, uint __max) public  {
        require(luckyNumber <= __max);
        require(__max > 0);
        max = __max;
        luckyNumber = __luckyNumber;
        
        //Random number using niguezrandomityengine 
        uint x = (((rf()%10)*100)+((rx()%10)*10)+(rm()%10)+(rg()%10));
        // random number between 0 and 24
        uint z = uint(keccak256(abi.encodePacked(x, rb(), msg.sender, now)));
        random = uint8(z % 24);
    }
    
    function getRand(uint8 pos) private view returns (uint256 r) {
        require(pos <= 23);
        if (pos == 0) return ra();
        if (pos == 1) return rb();
        if (pos == 2) return rc();
        if (pos == 3) return rd();
        if (pos == 4) return re();
        if (pos == 5) return rf();
        if (pos == 6) return rg();
        if (pos == 7) return rh();
        if (pos == 8) return ri();
        if (pos == 9) return rj();
        if (pos == 10) return rk();
        if (pos == 11) return rl();
        if (pos == 12) return rm();
        if (pos == 13) return rn();
        if (pos == 14) return ro();
        if (pos == 15) return rp();
        if (pos == 16) return rq();
        if (pos == 17) return rr();
        if (pos == 18) return rs();
        if (pos == 19) return rt();
        if (pos == 20) return ru();
        if (pos == 21) return rv();
        if (pos == 22) return rw();
        if (pos == 23) return rx();
    }
    
    bool locked = false;
    bool potWon = false;
    uint lastNumber = 0;
    
    function tryWin() public payable {

        //need to at least have enough HEX
        require(ERC20(_hex).balanceOf(msg.sender) >= (cost * _hexDecimal), "you don't have enough HEX");
        
        //need to be approved to take the tokens from sender
        require(ERC20(_hex).allowance(msg.sender, address(this)) >= (cost * _hexDecimal), "you have not approved enough HEX");
        
        //game must be started
        require(gamesStarted == true, "Game has not started Yet");
        
        //must not be locked.
        require(!locked);
        
        //pot must not already be Won
        require(!potWon);
        
        // must be from the origin
        require(msg.sender == tx.origin);
        
        locked = true;
        
         //take fee
        uint fee = 1000;
        _devBalance = SafeMath.add(_devBalance, fee);
        
        // add to pot
        uint costsubFee = SafeMath.sub(cost, fee);
        uint third = SafeMath.div(costsubFee, 3);
        pot = SafeMath.add(pot, third);
        nextRound = SafeMath.add(nextRound, SafeMath.mul(third, 2));
        
        //Random number using niguezrandomityengine 
        uint x = SafeMath.add(SafeMath.add(SafeMath.mul((rf()%10),100),((rx()%10)*10)),(rm()%10));
        uint z = uint(keccak256(abi.encodePacked(x, now, getRand(random), msg.sender)));
        uint y = z % SafeMath.add(max, 1);
        random = uint8(z % 24);
        require(y != lastNumber);
        lastNumber = y;
        
        // was it the lucky Number??
        if (y == luckyNumber) {
            potWon = true;
            
            // winner
            uint currentWinnings = 0;
            if (unclaimedPrizes[msg.sender] > 0) currentWinnings = unclaimedPrizes[msg.sender];
            unclaimedPrizes[msg.sender] = SafeMath.add(pot, currentWinnings);
        }
        
        // transfer
        bool transfer = ERC20(_hex).transferFrom(msg.sender, address(this), SafeMath.mul(cost, _hexDecimal));
        require(transfer);
        
        // fire event: New entry
        emit NewTry(msg.sender, y, now);
        // Fire event: Pot Won!
        if (potWon) {
            emit PotWon(msg.sender, pot, now);
            // Reset the pot
            uint halfOfNextPot = SafeMath.div(nextRound, 2);
            pot = halfOfNextPot;
            nextRound = halfOfNextPot;
            potWon = false;
        }
        locked = false;
    }
    
    function claim() public payable {
        require(unclaimedPrizes[msg.sender] > 0);
        require(ERC20(_hex).balanceOf(address(this)) >= unclaimedPrizes[msg.sender]);
        
        uint prizeHex = unclaimedPrizes[msg.sender];
        // Fire event: A jackpot was claimed!
        emit jackpotClaimed(msg.sender, prizeHex, now);
        unclaimedPrizes[msg.sender] = 0;
        ERC20(_hex).transfer(msg.sender, SafeMath.mul(prizeHex, _hexDecimal));
    }
    
    function flushDevFees() public payable {
        require(_devBalance > 0);
        require(ERC20(_hex).balanceOf(address(this)) >= _devBalance);
        
        uint toTransfer = SafeMath.mul(_devBalance, _hexDecimal);
        _devBalance = 0;
        ERC20(_hex).transfer(_dev, toTransfer);
    }
    
    function start(uint lcPot, uint lcNextRound) public {
        require(msg.sender == _dev, "Only the dev can start the game");
        require(!gamesStarted, "Game is already started!");
        
        gamesStarted = true;
        pot = lcPot;
        nextRound = lcNextRound;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}