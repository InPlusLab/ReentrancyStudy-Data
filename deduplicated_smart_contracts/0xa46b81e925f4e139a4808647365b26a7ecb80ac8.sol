/**

 *Submitted for verification at Etherscan.io on 2018-10-26

*/



pragma solidity ^0.4.25;



contract RockPaperScissors {



    //§£§à§Ù§Þ§à§Ø§ß§í§Ö §Ó§í§Ò§à§â§í §Ú§Ô§â§à§Ü§Ñ

    enum Choice { Null, Rock, Paper, Scissors }



    //§ª§Ô§â§Ñ, §á§à§Õ§â§Ñ§Ù§å§Þ§Ö§Ó§Ñ§Ö§ä§ã§ñ §ä§à§Ý§î§Ü§à 2 §å§é§Ñ§ã§ä§ß§Ú§Ü§Ñ

    struct Game {

        address owner;

        address opponent;

        

        Choice ownerChoice;

        Choice opponentChoice;

    }

    

    uint gamecounter = 0;

    mapping(uint => Game) games;

    

    //§³§à§Ò§í§ä§Ú§Ö §ß§Ñ §ã§à§Ù§Õ§Ñ§ß§Ú§Ö §Ú§Ô§â§í

    event NewGame(uint id);

    

    //§¦§ã§Ý§Ú §Ú§Ô§â§à§Ü§Ú §ã§Õ§Ö§Ý§Ñ§Ý§Ú §à§Õ§Ú§ß§Ñ§Ü§à§Ó§í§Û §Ó§í§Ò§à§â, §ä§à §ã§â§Ñ§Ò§Ñ§ä§í§Ó§Ñ§Ö§ä §Õ§Ñ§ß§ß§à§Ö §ã§à§Ò§í§ä§Ú§Ö,

    //§é§ä§à §à§Ù§ß§Ñ§é§Ñ§Ö§ä, §é§ä§à §Ú§Ô§â§Ñ §ã§Ò§â§à§ê§Ö§ß§Ñ

    event Refresh(uint id);

    

    //§³§à§Ù§Õ§Ñ§ß§Ú§Ö §Ú§Ô§â§í. §¹§Ö§Ý§à§Ó§Ö§Ü, §Ü§à§ä§à§â§í§Û §ã§à§Ù§Õ§Ñ§Ö§ä §Ú§Ô§â§å, §ã§â§Ñ§Ù§å §å§Ü§Ñ§Ù§í§Ó§Ñ§Ö§ä §ã§Ó§à§Ö§Ô§à §à§á§á§à§ß§Ö§ß§ä§Ñ 

    function newGame(address _opponent) external returns (uint) {

        uint gameid = gamecounter++;

        games[gameid] = Game(msg.sender, _opponent, Choice.Null, Choice.Null);

        

        emit NewGame(gameid);

        return gameid;

    }

    

    //§±§â§à§ã§Þ§à§ä§â §Ú§Ô§â§í §á§à §å§ß§Ú§Ü§Ñ§Ý§î§ß§à§Þ§å §ß§à§Þ§Ö§â§å

    function getGame(uint _id) external view returns (address, address, Choice, Choice){

        Game storage game = games[_id];

        return (

            game.owner,

            game.opponent,

            game.ownerChoice,

            game.opponentChoice

        );

    }

    

    //§³§Õ§Ö§Ý§Ñ§ä§î §ã§Ó§à§Û §Ó§í§Ò§à§â §Ó §Ù§Ñ§Õ§Ñ§ß§ß§à§Û §Ú§Ô§â§Ö

    //§¦§ã§Ý§Ú §Ó §â§Ñ§Þ§Ü§Ñ§ç §Ú§Ô§â§í §å§é§Ñ§ã§ä§ß§Ú§Ü§Ú §Õ§Ö§Ý§Ñ§ð§ä §à§Õ§Ú§ß§Ñ§Ü§à§Ó§í§Û §Ó§í§Ò§à§â, 

    //§ä§à §Ú§Ô§â§Ñ §Ó§í§Ò§à§â§í §Ú§Ô§â§à§Ü§à§Ó §ã§Ò§â§Ñ§ã§í§Ó§Ñ§ð§ä§ã§ñ §ß§Ñ §ß§Ñ§é§Ñ§Ý§î§ß§í§Û §å§â§à§Ó§Ö§ß§î

    function move(uint _gameid, Choice _choice) external {

        Game storage game = games[_gameid];

        

        require(game.owner == msg.sender || game.opponent == msg.sender);

        

        if(msg.sender == game.owner){

            require(game.ownerChoice == Choice.Null);

            game.ownerChoice = _choice;

        }

        

        if(msg.sender == game.opponent){

            require(game.opponentChoice == Choice.Null);

            game.opponentChoice = _choice;

        }

        

        if(game.opponentChoice == game.ownerChoice){

            game.opponentChoice = Choice.Null;

            game.ownerChoice = Choice.Null;

            emit Refresh(_gameid);

        }

    }

    

    //§±§â§à§ã§Þ§à§ä§â §á§à§Ò§Ö§Õ§Ú§ä§Ö§Ý§ñ §Ó §Ù§Ñ§Õ§Ñ§ß§ß§à§Û §Ú§Ô§â§Ö

    function getWinner(uint _gameid) external view returns (address) {

       Game storage game = games[_gameid];

       

       if(game.ownerChoice == Choice.Null || game.opponentChoice == Choice.Null){

           return address(0);

       }

       

       if(game.ownerChoice == Choice.Rock){

           if(game.opponentChoice == Choice.Paper){

               return game.opponent;

           }

           if(game.opponentChoice == Choice.Scissors){

               return game.owner;

           }

       }

       

       if(game.ownerChoice == Choice.Paper){

           if(game.opponentChoice == Choice.Rock){

               return game.owner;

           }

           if(game.opponentChoice == Choice.Scissors){

               return game.opponent;

           }

       }

       

       if(game.ownerChoice == Choice.Scissors){

           if(game.opponentChoice == Choice.Rock){

               return game.opponent;

           }

           if(game.opponentChoice == Choice.Paper){

               return game.owner;

           }

       }

       

       return address(0);

    }

}