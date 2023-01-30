/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity ^0.4.24;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMath8 {
    function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
    uint8 c = a * b;
    assert(c / a == b);
    return c;
    }
    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a / b;
        return c;
    }
    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        assert(b <= a);
        uint8 c = a- b;
        return c;
    }
    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        assert(c >= a);
        return c;
    }
    function mod(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b != 0);
        return a % b;
    }
}

contract gameContract {
    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns(uint winAmount, uint256[10] result);
    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin);
}

contract Baccarat is gameContract {

    using SafeMath for uint256;
    using SafeMath8 for uint8;

    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin) {
        if(betMask == 1) {
            maxWin = betAmount.add(2);
        } else if(betMask == 2) {
            maxWin = betAmount.div(100).mul(195);
        } else if(betMask == 4) {
            maxWin = betAmount.mul(8);
        }
    }

    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns (uint winAmount, uint256[10] result) {
        uint8 outcome;
        uint8[3] memory player_hand;
        uint8[3] memory banker_hand;
        uint8 player_point;
        uint8 banker_point;
        uint8[52] memory resultdeck;
        resultdeck = shuffleDeck(initDeck(), uint(entropy));
        (outcome, player_hand, banker_hand, player_point, banker_point) = baccarat(resultdeck);

        if(outcome == 1 && betMask == 1) {
            winAmount = betAmount.mul(2);
        } else if(outcome == 2 && betMask == 2) {
            winAmount = betAmount.div(100).mul(195);

        } else if(outcome == 4) {
            if (betMask == 4){
                winAmount = betAmount.mul(8);
            } else {
                winAmount = betAmount;
            }

        }

        result[0] = outcome;
        result[1] = player_hand[0];
        result[2] = banker_hand[0];
        result[3] = player_hand[1];
        result[4] = banker_hand[1];
        result[5] = player_hand[2];
        result[6] = banker_hand[2];
        result[7] = player_point;
        result[8] = banker_point;
    }

    function baccarat(uint8[52] memory deck) public pure returns (uint8 outcome, uint8[3] player_hand, uint8[3] banker_hand, uint8 player_point, uint8 banker_point){
        uint8[14][10] memory hit_stand_array;
        hit_stand_array = [
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1,1,0,1,1,1,1,1],
            [1,0,1,1,1,1,1,1,0,0,0,0,0,0],
            [1,0,0,0,1,1,1,1,0,0,0,0,0,0],
            [0,0,0,0,0,0,1,1,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0]]
        ;

        uint8 _player_point = 0;
        uint8 _banker_point = 0;

        player_hand[0] = deck[0];
        banker_hand[0] = deck[1];
        player_hand[1] = deck[2];
        banker_hand[1] = deck[3];
        uint8 next_index = 4;   //next draw

        _player_point = getPoint(player_hand[0]).add(getPoint(player_hand[1])).mod(10);
        _banker_point = getPoint(banker_hand[0]).add(getPoint(banker_hand[1])).mod(10);

        outcome = 0;//0 processing, 1 player win, 2 banker win, 4 tie

        if(_player_point > 7 || _banker_point > 7 || (_player_point > 5 && _banker_point > 5)) {
            outcome = getOutcome(_player_point, _banker_point);
        }

        if(outcome == 0) {
            if (_player_point < 6) {
                player_hand[2] = deck[next_index];
                _player_point = _player_point.add(getPoint(player_hand[2])).mod(10);
                next_index ++ ;
            }

            uint8 player_third_rank = player_hand[2].mod(13);
            if(hit_stand_array[_banker_point][player_third_rank] == 1) {
                banker_hand[2] = deck[next_index];
                _banker_point = _banker_point.add(getPoint(banker_hand[2])).mod(10);
            }

            outcome = getOutcome(_player_point, _banker_point);
        }

        return (outcome, player_hand, banker_hand, _player_point, _banker_point);
    }

    function getOutcome(uint8 player_point, uint8 banker_point) public pure returns (uint8 outcome){
        if(player_point > banker_point) {
            outcome = 1;
        } else if (player_point < banker_point) {
            outcome = 2;
        } else {
            outcome = 4;
        }
    }

    function getPoint(uint8 hand) public pure returns (uint8 point) {
        if (hand == 0) {
            return 0;//No hand
        }
        uint8 rank = hand.sub(1).mod(13);  //get card rank(0-12 as 1-10,J,Q,K)
        if (rank  > 8 ) {
            point = 0;  //10,J,Q,K are 0 point
        } else {
            point = rank.add(1);//1-9 has point of its rank
        }
        return point;
    }

    function initDeck() public pure returns(uint8[52] memory deck) {
        for (uint8 i = 0 ; i < 52 ; i ++) {
            deck[i] = i.add(1);
        }
    }

    function shuffleDeck(uint8[52] memory deck, uint256 _seed) public pure returns (uint8[52] shuffled){
        uint8 CARD_NUM = 52;
        for (uint8 i = 0; i < 6; i++ ) {
            _seed = uint256(keccak256(abi.encodePacked(_seed)));
            uint8 modulo = CARD_NUM.sub(i) ;
            uint256 rnd = _seed.mod(modulo); //This is not uniform random number.
            uint8 tmp = deck[i];
            deck[i] = deck[rnd];
            deck[rnd] = tmp;
        }
        //return Deck(deck.body, 0);
        shuffled = deck;
    }


    event GameEnd(string result);

}