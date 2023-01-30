pragma solidity 0.5.4;

import "./SafeMath.sol";
import "./Owned.sol";


contract MANAToken {
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function transfer(address _to, uint256 _value) public returns (bool);
  function balanceOf(address owner) public view returns (uint256);
}

contract MANAry is Owned{
    using SafeMath for uint256;

    MANAToken token;
   
    constructor() public {
    token = MANAToken(0x0F5D2fB29fb7d3CFeE444a200298f468908cC942);
    }
    
    struct tickets {address _owner; uint numOfTickets;}
    mapping (address => mapping (uint => tickets)) ownerOfTickets;
    
    address [] playerAddress;
    address [] entries;
    address [] winner;
    
    uint public players=0;
    uint public potTotal = 0;
    uint public roundNumber = 0;
    uint public numOfTicketsSold = 0;
    uint public cap = 100;
    
    uint unlockTime = now + 7 days + 30 minutes;
    
    function buyTickets(uint amount) public payable onlyWhenTimeIsLeft{
        require(amount > 0);
        
        uint ticket = 0;
        ticket = amount.div(100000000000000000000);
        
        require((ownerOfTickets[msg.sender][roundNumber].numOfTickets+ticket)<=15);
        require((numOfTicketsSold+ticket) <= cap);
        if((numOfTicketsSold+ticket) >= cap){
            unlockTime=0;
        }
        
        if (ticket > 0){
        require(token.transferFrom(msg.sender, address(this), amount));
        players++;
        playerAddress.push(msg.sender);
        potTotal = token.balanceOf(address(this));
        
        if (ownerOfTickets[msg.sender][roundNumber].numOfTickets == 0)
        {
        ownerOfTickets[msg.sender][roundNumber] = tickets(msg.sender, ticket);
        for(uint i=0; ticket > i; i++){
            entries.push(msg.sender);
            numOfTicketsSold++;
        }
        }
        else
        {
        ownerOfTickets[msg.sender][roundNumber].numOfTickets += ticket;
        
        for(uint j=0; ticket > j; j++){
            entries.push(msg.sender);
            numOfTicketsSold++;
            
        }
        }
        }
        
        else{
        require(token.transferFrom(msg.sender, owner, amount));
        }
    }
    
    function distributePrize() public payable onlyWhenTimeIsUpOrAllTicketsSold{      
        if (numOfTicketsSold > 0){
        uint randomNumber = uint(keccak256(abi.encodePacked(now, msg.sender))).mod(numOfTicketsSold);
        winner.push(entries[randomNumber]);
        address winnerAddress = winner[roundNumber];
        uint ownerShare = potTotal.mul(5).div(100);
        uint potShare = potTotal.mul(10).div(100);
        uint winnerShare = potTotal.sub(ownerShare.add(potShare));
        require(token.transfer(owner, ownerShare));
        require(token.transfer(winnerAddress, winnerShare));
        potTotal=potShare;
        }
 
        else{
        winner.push(address(0));
        }

	    delete entries;
        roundNumber++;
        numOfTicketsSold = 0;
        players=0;
        unlockTime= now + 7 days;
    }
    
    function terminateContract() public payable onlyOwner{
        for(uint k=0; players > k; k++)
        {
        uint refund = ownerOfTickets[playerAddress[k]][roundNumber].numOfTickets;
        require(token.transfer(playerAddress[k], refund.mul(100000000000000000000)));
        }
        potTotal = token.balanceOf(address(this));
        require(token.transfer(owner, potTotal));
        selfdestruct(owner);
    }
    
    function getLastWinner() public view returns (address){
        if(roundNumber == 0){
        return winner[roundNumber];
        }
        else{
            return winner[roundNumber.sub(1)];
        }
    }
    
    function getTicketNum(address ticketHolder) public view returns(uint) {
        return ownerOfTickets[ticketHolder][roundNumber].numOfTickets;
        
    }
    
    function timeLeft() public view returns(uint) {
        if (unlockTime >= now) {
            return unlockTime.sub(now);
        }
        else {
            return 0;
        }
    }
    
    modifier onlyWhenTimeIsUpOrAllTicketsSold{
        require (unlockTime < now);
        _;
    }
    
    modifier onlyWhenTimeIsLeft{
        require (unlockTime > now);
        _;
    }
    
}

