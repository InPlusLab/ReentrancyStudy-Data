/**

 *Submitted for verification at Etherscan.io on 2018-10-26

*/



pragma solidity ^0.4.25;



contract RockPaperScissors {



    //����٧ާ�اߧ�� �ӧ�ҧ��� �ڧԧ��ܧ�

    enum Choice { Null, Rock, Paper, Scissors }



    //���ԧ��, ���է�ѧ٧�ާ֧ӧѧ֧��� ���ݧ�ܧ� 2 ���ѧ��ߧڧܧ�

    struct Game {

        address owner;

        address opponent;

        

        Choice ownerChoice;

        Choice opponentChoice;

    }

    

    uint gamecounter = 0;

    mapping(uint => Game) games;

    

    //����ҧ��ڧ� �ߧ� ���٧էѧߧڧ� �ڧԧ��

    event NewGame(uint id);

    

    //����ݧ� �ڧԧ��ܧ� ��է֧ݧѧݧ� ��էڧߧѧܧ�ӧ�� �ӧ�ҧ��, ��� ���ѧҧѧ��ӧѧ֧� �էѧߧߧ�� ���ҧ��ڧ�,

    //���� ��٧ߧѧ�ѧ֧�, ���� �ڧԧ�� ��ҧ���֧ߧ�

    event Refresh(uint id);

    

    //����٧էѧߧڧ� �ڧԧ��. ���֧ݧ�ӧ֧�, �ܧ������ ���٧էѧ֧� �ڧԧ��, ���ѧ٧� ��ܧѧ٧�ӧѧ֧� ��ӧ�֧ԧ� �����ߧ֧ߧ�� 

    function newGame(address _opponent) external returns (uint) {

        uint gameid = gamecounter++;

        games[gameid] = Game(msg.sender, _opponent, Choice.Null, Choice.Null);

        

        emit NewGame(gameid);

        return gameid;

    }

    

    //������ާ��� �ڧԧ�� ��� ��ߧڧܧѧݧ�ߧ�ާ� �ߧ�ާ֧��

    function getGame(uint _id) external view returns (address, address, Choice, Choice){

        Game storage game = games[_id];

        return (

            game.owner,

            game.opponent,

            game.ownerChoice,

            game.opponentChoice

        );

    }

    

    //���է֧ݧѧ�� ��ӧ�� �ӧ�ҧ�� �� �٧ѧէѧߧߧ�� �ڧԧ��

    //����ݧ� �� ��ѧާܧѧ� �ڧԧ�� ���ѧ��ߧڧܧ� �է֧ݧѧ�� ��էڧߧѧܧ�ӧ�� �ӧ�ҧ��, 

    //��� �ڧԧ�� �ӧ�ҧ��� �ڧԧ��ܧ�� ��ҧ�ѧ��ӧѧ���� �ߧ� �ߧѧ�ѧݧ�ߧ�� ����ӧ֧ߧ�

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

    

    //������ާ��� ���ҧ֧էڧ�֧ݧ� �� �٧ѧէѧߧߧ�� �ڧԧ��

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