contract Ethereum_doubler
{

string[8] hexComparison;							//declares global variables
string hexcomparisonchr;
string A;
uint8 i;
uint8 lotteryticket;
address creator;
int lastgainloss;
string lastresult;
uint lastblocknumberused;
bytes32 lastblockhashused;
uint8 hashLastNumber;
address player;
uint8 result; 
uint128 wager; 
uint8 lowOrHigh; // 0=low, 2=high, 4=kill, 6=n.a.
uint8 HashtoLowOrHigh;//hash modified to low or high 0=low, 2=high, 7= 0 or F
 

   function  Ethereum_doubler() private 
    { 
        creator = msg.sender; 								
    }

  function Set_your_game_number(string Set_your_game_number_L_or_H)			//sets game number
 {	result=0;
    	A=Set_your_game_number_L_or_H ;
     	uint128 wager = uint128(msg.value); 
	comparisonchr(A);
	inputToDigit(i);
	checkHash();
	changeHashtoLowOrHigh(hashLastNumber);
 	checkBet();
	returnmoneycreator(result,wager);
}

 

    function comparisonchr(string A) private					//changes string input to uint
    {    hexComparison= ["L", "l", "H", "h", "K","N.A.","dummy","0 or F"];
	for (i = 0; i < 6; i ++) 
{

	hexcomparisonchr=hexComparison[i];

    

	bytes memory a = bytes(hexcomparisonchr);
 	bytes memory b = bytes(A);
        
          
        
          if (a[0]==b[0])
              return ;

}}

function inputToDigit(uint i) private
{
if(i==0 || i==1)
{lowOrHigh=0;
return;}
else if (i==2 ||i==3)
{lowOrHigh=2;
return;}
else if (i==4)
{lowOrHigh=4;
return;}
else if (i==6)
{lowOrHigh=6;}
return;}

	function checkHash() private
{
   	lastblocknumberused = (block.number-1)  ;				//Last available blockhash is in the previous block
    	lastblockhashused = block.blockhash(lastblocknumberused);		//Cheks the last available blockhash

    	
    	hashLastNumber=uint8(lastblockhashused & 0xf);				//Changes blockhash&#39;s last number to base ten
}

	function changeHashtoLowOrHigh(uint  hashLastNumber) private
{
	if (hashLastNumber>0 && hashLastNumber<8)
	{HashtoLowOrHigh=0;
	return;}
	else if (hashLastNumber>7 && hashLastNumber<15)
	{HashtoLowOrHigh=2;
	return;}
	else
	{HashtoLowOrHigh=7;
	lastresult = "0 or F, house wins";
	return;}//result= 0 or F, house wins
	
 
	 
}

 

	function checkBet() private

 { 
	lotteryticket=lowOrHigh;
	player=msg.sender;
        
                
    
  		  
    	if(msg.value > (this.balance/4))					// maximum bet is game balance/4
    	{
    		lastresult = "Bet is too large. Maximum bet is the game balance/4.";
    		lastgainloss = 0;
    		msg.sender.send(msg.value); // return bet
    		return;
    	}
	else if(msg.value <100000000000000000)					// minimum bet is 0.1 eth
    	{
    		lastresult = "Minimum bet is 0.1 eth";
    		lastgainloss = 0;
    		msg.sender.send(msg.value); // return bet
    		return;

	}
    	else if (msg.value == 0)
    	{
    		lastresult = "Bet was zero";
    		lastgainloss = 0;
    		// nothing wagered, nothing returned
    		return;
    	}
    		
    	uint128 wager = uint128(msg.value);          				// limiting to uint128 guarantees that conversion to int256 will stay positive
    	
 

   	 if(lotteryticket==6)							//Checks that input is L or H 
	{
	lastresult = "give a character L or H ";
	msg.sender.send(msg.value);
	lastgainloss=0;
	
	return;
	}

	else if (lotteryticket==4 && msg.sender == creator)			//Creator can kill contract. Contract does not hold players money.
	{
		suicide(creator);} 

	else if(lotteryticket != HashtoLowOrHigh)
	{
	    	lastgainloss = int(wager) * -1;
	    	lastresult = "Loss";
	    	result=1;
	    									// Player lost. Return nothing.
	    	return;
	}
	    else if(lotteryticket==HashtoLowOrHigh)
	{
	    	lastgainloss =(2*wager);
	    	lastresult = "Win!";
	    	msg.sender.send(wager * 2); 
		return;			 					// Player won. Return bet and winnings.
	} 	
    }

	function returnmoneycreator(uint8 result,uint128 wager) private		//If game has over 50 eth, contract will send all additional eth to owner
	{
	if (result==1&&this.balance>50000000000000000000)
	{creator.send(wager);
	return; 
	}
 
	else if
	(
	result==1&&this.balance>20000000000000000000)				//If game has over 20 eth, contract will send œ of any additional eth to owner
	{creator.send(wager/2);
	return; }
	}
 
/**********
functions below give information about the game in Ethereum Wallet
 **********/
 
 	function Results_of_the_last_round() constant returns (string last_result,string Last_player_s_lottery_ticket,address last_player,string The_right_lottery_number,int Player_s_gain_or_Loss_in_Wei,string info)
    { 
   	last_player=player;	
	Last_player_s_lottery_ticket=hexcomparisonchr;
	The_right_lottery_number=hexComparison[HashtoLowOrHigh];
	last_result=lastresult;
	Player_s_gain_or_Loss_in_Wei=lastgainloss;
	info = "The right lottery number is decided by the last character of the most recent blockhash available during the game. 1-7 =Low, 8-e =High. One Eth is 10**18 Wei.";
	
 
    }

 	function Last_block_number_and_blockhash_used() constant returns (uint last_blocknumber_used,bytes32 last_blockhash_used)
    {
        last_blocknumber_used=lastblocknumberused;
	last_blockhash_used=lastblockhashused;


    }
    
   
	function Game_balance_in_Ethers() constant returns (uint balance, string info)
    { 
        info = "Game balance is shown in full Ethers";
    	balance=(this.balance/10**18);

    }
    
   
}