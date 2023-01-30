/**

 *Submitted for verification at Etherscan.io on 2018-10-05

*/



pragma solidity ^0.4.7;



/* */

contract FootballMatches {

    

    /* */

    struct FootballMatch {



		//       sender              team    amount

	    mapping (address => mapping (uint => uint)) bets;

	    

	    uint    totalAmount;

	    uint    claimedAmount;

	    uint[3] pools;			// draw; 1st wins; 2nd wins

	    uint    startTime;

	    

	    uint winner;			// 0 - draw; 1 - 1st team; 2 - 2nd team

	    bool isWinnerSet;

	    bool ownerHasClaimed;   

    }    



	/* constants */    

    uint constant private FEE_PERCENTAGE = 2;

    

    /* variables */

    address         private owner;

    FootballMatch[] private matches;

    

    /* events */

    event Bet(

        address indexed from, 

        uint    indexed matchId,

        uint            team, 

        uint    indexed value

    );

    

    event Claim(

        address indexed from, 

        uint    indexed matchId, 

        uint            value

    );    

    

    /* modifiers */

    

    /* */

	modifier ownerOnly() {

	    require(msg.sender == owner);

	    _;

	}

	

	/* */

	modifier winnerSet(uint matchId) {

		require(matches[matchId].isWinnerSet == true);

		_;

	}	

	

	/* */

	modifier matchValid(uint matchId) {

		require(matchId >= 0 && matchId < matches.length);

		_;

	}

	

	/* */

	modifier teamValid(uint team) {

		require(team == 0 || team == 1 || team == 2);

		_;

	}	

	

	/* */

	modifier afterStartTime(uint matchId) {

	    require(now >= matches[matchId].startTime);

	    _;

	}	

	

	/* */

	modifier beforeStartTime(uint matchId) {

	    require(now < matches[matchId].startTime);

	    _;

	}	

    

	/* */    

    constructor() public {

        

        owner = msg.sender;

        

        uint startTime1 = 1540313700;

        uint startTime2 = 1540321200;

        uint startTime3 = 1540400100;

        uint startTime4 = 1540407600;

        

        newFootballMatch(startTime1); // "AEK",              "Bayern"

        newFootballMatch(startTime1); // "Young Boys",       "Valencia"

        newFootballMatch(startTime2); // "Ajax",             "Benfica"

        newFootballMatch(startTime2); // "Shakhtar Donetsk", "Man. City"

        newFootballMatch(startTime2); // "Hoffenheim",       "Lyon"

        newFootballMatch(startTime2); // "Real Madrid",      "Plze��"

        newFootballMatch(startTime2); // "Roma",             "CSKA Moskva"

        newFootballMatch(startTime2); // "Man. United",      "Juventus"

        

        newFootballMatch(startTime3); // "Club Brugge",      "Monaco"

        newFootballMatch(startTime3); // "PSV",              "Tottenham"

        newFootballMatch(startTime4); // "Dortmund",         "Atl��tico"

        newFootballMatch(startTime4); // "Barcelona",        "Internazionale"

        newFootballMatch(startTime4); // "Liverpool",        "Crvena zvezda"

        newFootballMatch(startTime4); // "Paris",            "Napoli"

        newFootballMatch(startTime4); // "Galatasaray",      "Schalke"

        newFootballMatch(startTime4); // "Lokomotiv Moskva", "Porto"

    }

    

    /* */

    function newFootballMatch(uint startTime) private ownerOnly {



		uint matchId = matches.length;

		matches.length += 1;

		

		matches[matchId].startTime = startTime;        

    }    

    

	/* */

	function calculateFee(uint value) private pure returns (uint) {

	    return SafeMath.div(SafeMath.mul(value, FEE_PERCENTAGE), 100);

	}

	

	/* */

	function getOwnerPayout(uint matchId) private 

		winnerSet(matchId) ownerOnly returns (uint) {

	

		if (matches[matchId].ownerHasClaimed) {

			return 0;

		}

		

		uint payout = 0;

		if (matches[matchId].pools[matches[matchId].winner] != 0) {

			// we have at least one bet on a winning result

			payout = calculateFee(matches[matchId].totalAmount);

		} else {

			// we have no bets on a winning result

			payout = matches[matchId].totalAmount;

		}

		

		matches[matchId].ownerHasClaimed = true;

		return payout;

	}

	

	/* */

	function getNormalPayout(uint matchId) private 

		winnerSet(matchId) returns (uint) {

	

		uint bet = matches[matchId].bets[msg.sender][matches[matchId].winner];

		if (bet == 0) {

			return 0;

		}

    

        uint fee        = calculateFee(matches[matchId].totalAmount);

        uint taxedTotal = SafeMath.sub(matches[matchId].totalAmount, fee);

        uint total      = matches[matchId].pools[matches[matchId].winner];

        

        uint payout = SafeMath.div(SafeMath.mul(taxedTotal, bet), total);

        

        matches[matchId].bets[msg.sender][matches[matchId].winner] = 0;

        return payout;

	}

	

	/* */

	function getTotalAmount(uint matchId) public 

		matchValid(matchId) view returns (uint) {

		    

        return matches[matchId].totalAmount;

    }

    

	/* */

	function getClaimedAmount(uint matchId) public 

		matchValid(matchId) ownerOnly view returns (uint) {

		    

        return matches[matchId].claimedAmount;

    }     

    

    /* */

    function setWinner(uint matchId, uint team) external 

    	matchValid(matchId) teamValid(team) afterStartTime(matchId) ownerOnly {

    	    

        matches[matchId].winner      = team;

        matches[matchId].isWinnerSet = true;

    }    

    

	/* */

    function bet(uint matchId, uint team) external payable 

    	matchValid(matchId) teamValid(team) beforeStartTime(matchId) {

    	    

        require(msg.value > 0);

        

        matches[matchId].totalAmount = 

        	SafeMath.add(matches[matchId].totalAmount, msg.value);

        matches[matchId].pools[team] = 

        	SafeMath.add(matches[matchId].pools[team], msg.value);

        matches[matchId].bets[msg.sender][team] = 

        	SafeMath.add(matches[matchId].bets[msg.sender][team], msg.value);

        

        emit Bet(msg.sender, matchId, team, msg.value);

    }

    

    /* */

    function claim(uint matchId) external 

    	matchValid(matchId) winnerSet(matchId) {

    

    	uint payout = 0;

    	

    	if (msg.sender == owner) {

    		payout = getOwnerPayout(matchId); 

    	}

    	

    	// owner can bet too

    	payout = SafeMath.add(payout, getNormalPayout(matchId));

    	require(payout > 0);

    	

    	matches[matchId].claimedAmount = 

    		SafeMath.add(matches[matchId].claimedAmount, payout);

        msg.sender.transfer(payout);

        

        emit Claim(msg.sender, matchId, payout);

    }     



    /**********

     Standard kill() function to recover funds 

     **********/

	/*    

    function kill() {

        if (msg.sender == owner) {

            suicide(owner); // kills this contract and sends remaining funds back to creator

        }

    }

    */

}



/*****************************************************************************/



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

    /**

     * @dev Multiplies two numbers, throws on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c){

        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }

        c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

     * @dev Integer division of two numbers, truncating the quotient.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256){

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return a / b;

    }



    /**

     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256){

        assert(b <= a);

        return a - b;

    }



    /**

     * @dev Adds two numbers, throws on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256 c){

        c = a + b;

        assert(c >= a);

        return c;

    }

}