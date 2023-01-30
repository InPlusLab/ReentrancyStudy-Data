/**
 *Submitted for verification at Etherscan.io on 2020-04-28
*/

pragma solidity ^0.4.8;

contract Lucky12{
    
    mapping (uint8 => address) playersByNumber ;
    uint8[12] public winners;
    uint8[12] public previouswinners;
    bool[26] public occupied;
    uint256 public price;
    uint256 public prize;
    uint8 public numberofplayers=0;
    enum LotteryState { Accepting, Finished }
    LotteryState public state; 
    address public owner;
    
    constructor(){
        owner = 0xbbFBF4336d645787D7eF31b6a606aa25537F9C13;
        state = LotteryState.Accepting;
        price=0.01 ether;
        prize=0.019 ether;
    }
 
    
    function setprice(uint256 newprice,uint256 newprize) public{
        require(msg.sender==owner);
        require(state==LotteryState.Finished,"Game is Running,Cannot change");
        price = newprice;
        prize = newprize;
    }
    
    function pause() public{
        require(msg.sender==owner);
        require(state==LotteryState.Accepting,"Game is already Paused!");
        state=LotteryState.Finished;
    }
    function resume() public{
        require(msg.sender==owner);
        require(state==LotteryState.Finished,"Game is already Running!");
        state=LotteryState.Accepting;
    }
     //withdraw balance
   function withdraw() public{
       require(msg.sender==owner);
       require(state==LotteryState.Finished,"Game is Running!");
       owner.transfer(this.balance);
   }
    
    function enter(uint8 number) public payable {
        require(occupied[number]==false,"Someone Purchased this number before you!");
        require(number<=25 && number>0);
        require(state == LotteryState.Accepting,"Game is Paused!");
        require(msg.value == price);
        
        //register user
        playersByNumber[number] = msg.sender;
        
        // sold number list
        occupied[number]=true;
        
        // increment participant
        numberofplayers=numberofplayers+1;
        
        if(numberofplayers==25){
            determineWinner();//finalize round
        }
    }
   
    
    function determineWinner() private {
        state = LotteryState.Finished;
        winnerlist(); // select random winners
        rewardwinner(); // reward winners
        clearDataAndStartAgain(); // restart new round
        //selfdestruct(owner);// transfer remaining fees to owner
    }
    

    function winnerlist() private{
        uint8 number=random();
        uint8 i=0;
        uint8 prev=0;
        uint8 next=1;
            if(number<6)
            {
                number=number+6;
            }
            else if(number>19)
            {
                number=number-6;
            }
        
        do{
           if(i%2==0){
               winners[i]=number+prev;
               prev++;
           }
           else{
               winners[i]=number-next;
               next++;
           }
            i++;
            
        }while(i!=12);
        
        return;
    }
    
    
    function rewardwinner() private{
        require(state==LotteryState.Finished);
        uint256 balanceToDistribute = prize;
        
        for (uint8 i=0;i<12;i++){
            playeraddress(winners[i]).transfer(balanceToDistribute);
        }
    }
    
    function clearDataAndStartAgain() private{
            numberofplayers=0;
        for(uint8 i=0;i<12;i++){
            previouswinners[i]=winners[i];
            winners[i]=0;
        }
        for(uint8 j=0;j<26;j++){
            occupied[j]=false;
        }
        for(uint8 k=0;k<26;k++){
            playersByNumber[k]=0x0000000000000000000000000000000000000000;
        }
            state = LotteryState.Accepting;
    }
    
    function playeraddress(uint8 player) public constant returns(address){
        return playersByNumber[player];
    }
  
    
    function random() public view returns (uint8) {
        uint8 randomHash = uint8(keccak256(block.difficulty, now));
        return randomHash % 25;
    }
    
    function getlist() public constant returns(bool[26]){
        return occupied;
    }
    
    function previouswinner() public constant returns(uint8[12]){
        return previouswinners;
    }
}