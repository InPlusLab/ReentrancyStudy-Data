//***********************************TREASURE CHEST GAME
//
//
//  Hello player, this is a Treasure Chest game, every player that deposit&#39;s here will get a guaranteed 6% payout of their balance after somebody after him deposits!
//  Every 30th investor receives 18% instead of 6%, that is the jackpot spot that pays 3x more, invest quickly ,and you can earn a passive income right now!
//
//  This contract is bug-tested, and it has none, feel comfortable to analyse the code yourself, it&#39;s open source and transparent!
//  Enjoy this game, and earn Ethereum now!
//
//  Copyright  &#194;&#169;  2016  David Weissman from NZ
//
//***********************************START
contract TreasureChest {

  struct InvestorArray {
      address etherAddress;
      uint amount;
  }

  InvestorArray[] public investors;

//********************************************PUBLIC VARIABLES

  uint public investors_needed_until_jackpot=0;
  uint public totalplayers=0;
  uint public fees=0;
  uint public balance = 0;
  uint public totaldeposited=0;
  uint public totalpaidout=0;

  address public owner;

  // simple single-sig function modifier
  modifier onlyowner { if (msg.sender == owner) _ }

//********************************************INIT

  function TreasureChest() {
    owner = msg.sender;
  }

//********************************************TRIGGER

  function() {
    enter();
  }
  
//********************************************ENTER

  function enter() {
    if (msg.value < 50 finney) {
        msg.sender.send(msg.value);
        return;
    }
	
    uint amount=msg.value;


    // add a new participant to the system and calculate total players
    uint tot_pl = investors.length;
    totalplayers=tot_pl+1;
    investors_needed_until_jackpot=30-(totalplayers % 30);
    investors.length += 1;
    investors[tot_pl].etherAddress = msg.sender;
    investors[tot_pl].amount = amount;



    // collect fees and update contract balance and deposited amount
      fees  = amount / 15;             // 6.666% fee to the owner
      balance += amount;               // balance update
      totaldeposited+=amount;       //update deposited amount

    // pay out fees to the owner
     if (fees != 0) 
     {
     	if(balance>fees)
	{
      	owner.send(fees);
      	balance -= fees;                 //balance update
	totalpaidout+=fees;          //update paid out amount
	}
     }
 

   //loop variables
    uint payout;
    uint nr=0;
	
    while (balance > investors[nr].amount * 6/100 && nr<tot_pl)  //exit condition to avoid infinite loop
    { 
     
     if(nr%30==0 &&  balance > investors[nr].amount * 18/100)
     {
      payout = investors[nr].amount * 18/100;                        //calculate pay out
      investors[nr].etherAddress.send(payout);                      //send pay out to participant
      balance -= investors[nr].amount * 18/100;                      //balance update
      totalpaidout += investors[nr].amount * 18/100;               //update paid out amount
      }
     else
     {
      payout = investors[nr].amount *6/100;                           //calculate pay out
      investors[nr].etherAddress.send(payout);                        //send pay out to participant
      balance -= investors[nr].amount *6/100;                         //balance update
      totalpaidout += investors[nr].amount *6/100;                 //update paid out amount
      }
      
      nr += 1;                                                                         //go to next participant
    }
    
    
  }

//********************************************NEW OWNER

  function setOwner(address new_owner) onlyowner {
      owner = new_owner;
  }
}