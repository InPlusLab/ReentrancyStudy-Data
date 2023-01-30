/**

 *Submitted for verification at Etherscan.io on 2018-12-13

*/



pragma solidity ^0.4.19;



contract Erabet {

   address public owner;

   uint256 public minimumBet = 0;

   uint256 public totalBet = 0;

   uint256 public maxAmountOfBets = 1000;

   uint256 public numberOfBets = 0;

   uint256 public numberWinner=0;

   address[] public players;

   uint256 winnerEtherAmount=0 ether;

   uint256 winnerteambet=0;

   uint256 factor=0;

   uint256 teambet=0;





    struct Player

	{

      uint256 amountBet;

      uint256 numberSelected;

    }





/*numberSelected can be only 3.

1 - A team wins toss

2 - B team wins toss



*/

    mapping(address => Player) public playerInfo;



    function Erabet() public

	{

      owner = msg.sender;

    }



    function transfer_ownership(address o) public{

        require(msg.sender==owner); 

         owner = o;

    }





   function checkPlayerExists(address player) public constant returns(bool)

   {

      for(uint256 i = 0; i < players.length; i++)

	  {

           if(players[i] == player) return true;

      }

      return false;

    }









    function bet(uint256 numberSelected) public payable

	{

      require(!checkPlayerExists(msg.sender));

      require(msg.value >= minimumBet);

      playerInfo[msg.sender].amountBet = msg.value;

      playerInfo[msg.sender].numberSelected = numberSelected;

      numberOfBets++;

      players.push(msg.sender);

      totalBet = totalBet + msg.value;

      address(this).transfer(msg.value);

    }



   function() public payable {}                                          /*fallback function*/







    function multiply_factor() public constant returns(uint)             /*used to check value of factor, not of use can be removed*/

	{

        return factor;

    }







    function totalbal() public constant returns(uint256){                /*used to check total balance of in contract, not of use can be removed*/

        return address(this).balance;

    }







	function totalteambet(uint256 num)view public returns(uint256)       /*function to count totalbet placed in a team */

	{

	for(uint256 i = 0; i < players.length; i++)

	  {

            address playerAddress = players[i];

              if(playerInfo[playerAddress].numberSelected == num)

			 {  teambet =teambet + playerInfo[playerAddress].amountBet;



             }



      }

	 return teambet;

	}







    function distributePrizes(uint256 temp) public payable

	{

     require(msg.sender == owner);

     address[8] memory winners;                                          /*This is the count for the array of winners*/

     numberWinner = temp;

     /*We have to create a temporary in memory array with fixed size*/

     uint256 count = 0;

     for(uint256 i = 0; i < players.length; i++)

	  {

            address playerAddress = players[i];

              if(playerInfo[playerAddress].numberSelected == numberWinner)

			 {   winnerteambet= winnerteambet + playerInfo[playerAddress].amountBet;

                 winners[count] = playerAddress;

                 count++;

             }



      }

      uint256 dev = address(this).balance/50;

      owner.transfer(dev);

      uint256 _numerator  = address(this).balance * (10 ** 18);

      factor =  ((_numerator / winnerteambet) + 5) / 10;

      for(uint256 j = 0; j < count; j++)

	  {

          if(winners[j] != address(0))                                  /* Check that the address in this fixed array is not empty */

           {

            address temp_player=winners[j];

            uint256 betvalue= playerInfo[temp_player].amountBet;

            winnerEtherAmount=betvalue*factor;

            uint256 money = (winnerEtherAmount)/(10 ** 17);

            winners[j].transfer(money);

           }

      }

      //    delete playerInfo[playerAddress];                            /* Delete wwec all the players */

    }



	                                                                   /*Delete playerinfo after bet is over*/

	function del()public

    {

     require(msg.sender == owner);

     for(uint256 i = 0; i < players.length; i++)

	  {

	      address playerAddress = players[i];

	      delete playerInfo[playerAddress];                            /* Delete wwec all the players */



	  }

    }





			                                                             /*refund*/

	function ref() public payable

	{

	 require(msg.sender == owner);

     //uint256 dev = this.balance/50;

     //owner.transfer(dev);

	 for(uint256 i = 0; i < players.length; i++)

	  {

            address playerAddress = players[i];

            uint256 refundamt = playerInfo[playerAddress].amountBet;

			players[i].transfer(refundamt);





      }

	}



}