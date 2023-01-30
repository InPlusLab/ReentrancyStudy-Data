/**
 *Submitted for verification at Etherscan.io on 2020-01-14
*/

pragma solidity >= 0.5.0 < 0.6.0;

contract niguezRandomityEngine {

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
    uint public startedAt;
    uint public luckyNumber;
    uint public max = 1000;
    uint _devBalance = 0;
    bool gamesStarted = false;
    
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
    }
    
    function tryWin() public payable returns (uint n) {

        //need to at least have enough HEX
        require(ERC20(_hex).balanceOf(msg.sender) >= (cost * _hexDecimal), "you don't have enough HEX");
        
        //need to be approved to take the tokens from sender
        require(ERC20(_hex).allowance(msg.sender, address(this)) >= (cost * _hexDecimal), "you have not approved enough HEX");
        
        //game must be started
        require(gamesStarted == true, "Game has not started Yet");
        
         //take fee
        uint fee = 1000;
        _devBalance += fee;
        
        // add to pot
        uint costsubFee = (cost - fee);
        uint third = costsubFee / 3;
        pot += third;
        nextRound += (third * 2);
        
        //Random number using niguezrandomityengine 
        uint x = (((rf()%10)*100)+((rx()%10)*10)+(rm()%10));
        
        // random number between 0 and max
        uint z = uint(keccak256(abi.encodePacked(x)));
        uint y = z % (max + 1);
        
        // fire event: New entry
        emit NewTry(msg.sender, y, now);
        
        // was it the lucky Number??
        if (y == luckyNumber) {
            
            // winner
            uint currentWinnings = 0;
            if (unclaimedPrizes[msg.sender] > 0) currentWinnings = unclaimedPrizes[msg.sender];
            unclaimedPrizes[msg.sender] = pot + currentWinnings;
            
            // Fire event: Pot Won!
            emit PotWon(msg.sender, pot, now);

            // Reset the pot
            uint halfOfNextPot = (nextRound / 2);
            
            pot = halfOfNextPot;
            nextRound = halfOfNextPot;
        }
        
        //deal with transfers at the end to avoid reentrancy attacks.
        bool transfer = ERC20(_hex).transferFrom(msg.sender, address(this), (cost * _hexDecimal));
        require(transfer);
        return y;
    }
    
    function claim() public payable {
        
        require(unclaimedPrizes[msg.sender] > 0);
        require(ERC20(_hex).balanceOf(address(this)) >= unclaimedPrizes[msg.sender]);
        
        uint prizeHex = unclaimedPrizes[msg.sender];
        // Fire event: A jackpot was claimed!
        emit jackpotClaimed(msg.sender, prizeHex, now);
        unclaimedPrizes[msg.sender] = 0;
        ERC20(_hex).transfer(msg.sender, (prizeHex * _hexDecimal));
    }
    
    function flushDevFees() public payable {
        require(_devBalance > 0);
        require(ERC20(_hex).balanceOf(address(this)) >= _devBalance);
        
        uint toTransfer = (_devBalance * _hexDecimal);
        _devBalance = 0;
        ERC20(_hex).transfer(_dev, toTransfer);
    }
    
    function start(uint lcPot, uint lcNextRound) public {
        require(msg.sender == _dev);
        
        gamesStarted = true;
        pot = lcPot;
        nextRound = lcNextRound;
        startedAt = now;
    }
}