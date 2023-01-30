/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.24;



library SafeCast {

    /**

     * Cast unsigned a to signed a.

     */

    function castToInt(uint a) internal pure returns(int) {

        assert(a < (1 << 255));

        return int(a);

    }



    /**

     * Cast signed a to unsigned a.

     */

    function castToUint(int a) internal pure returns(uint) {

        assert(a >= 0);

        return uint(a);

    }

}



library SafeMath {



    /**

    * @dev Multiplies two unsigned integers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

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

    * @dev Multiplies two signed integers, throws on overflow.

    */

    function mul(int256 a, int256 b) internal pure returns (int256) {

        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }

        int256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two unsigned integers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return a / b;

    }



    /**

    * @dev Integer division of two signed integers, truncating the quotient.

    */

    function div(int256 a, int256 b) internal pure returns (int256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        // Overflow only happens when the smallest negative int is multiplied by -1.

        int256 INT256_MIN = int256((uint256(1) << 255));

        assert(a != INT256_MIN || b != - 1);

        return a / b;

    }



    /**

    * @dev Subtracts two unsigned integers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Subtracts two signed integers, throws on overflow.

    */

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;

        assert((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;

    }



    /**

    * @dev Adds two unsigned integers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;

        assert(c >= a);

        return c;

    }



    /**

    * @dev Adds two signed integers, throws on overflow.

    */

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;

        assert((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;

    }

}



interface GameInterface {

    function maxBet(uint _num, uint _bankRoll) external view returns(uint);



    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _num) external view returns(uint);



    function userProfit(uint _num, uint _betValue, uint _resultNum) external view returns(int);



    function maxUserProfit(uint _num, uint _betValue) external view returns(int);

}



contract Utilities {

    using SafeCast for int;

    using SafeCast for uint;

    using SafeMath for int;

    using SafeMath for uint;



    uint constant public PROBABILITY_DIVISOR = 10000;

    uint constant public HOUSE_EDGE = 150;

    uint constant public HOUSE_EDGE_DIVISOR = 10000;



    /**

     * @dev Calc max bet we allow

     * We definitely do not allow bets greater than kelly criterion would allow.

     * => The max bet is limited to the max profit of houseEdge * bankroll.

     * => maxBet = houseEdge / (1/p * (1 - houseEdge) - 1) * bankroll, with p is win probability.

     * The max bet can be further restricted on backend.

     * @param _winProbability winProbability.

     * @return max allowed bet.

     */

    function maxBetFromProbability(uint _winProbability, uint _bankRoll) public pure returns(uint) {

        assert(0 < _winProbability && _winProbability < PROBABILITY_DIVISOR);



        uint tmp1 = PROBABILITY_DIVISOR.mul(HOUSE_EDGE_DIVISOR).div(_winProbability);

        uint tmp2 = PROBABILITY_DIVISOR.mul(HOUSE_EDGE).div(_winProbability);



        uint enumerator = HOUSE_EDGE.mul(_bankRoll);

        uint denominator = tmp1.sub(tmp2).sub(HOUSE_EDGE_DIVISOR);

        return enumerator.div(denominator);

    }



    /**

     * Calculate user profit from total won.

     * @param _totalWon user winnings.

     * @param _betValue bet value.

     * @return user profit.

     */

    function calcProfitFromTotalWon(uint _totalWon, uint _betValue) public pure returns(int) {

        uint houseEdgeValue = _totalWon.mul(HOUSE_EDGE).div(HOUSE_EDGE_DIVISOR);



        return _totalWon.castToInt().sub(houseEdgeValue.castToInt()).sub(_betValue.castToInt());

    }



    /**

     * @dev Generates a 256 bit random number by combining server and user seed.

     * @param _serverSeed server seed.

     * @param _userSeed user seed.

     * @return random number generated by combining server and user seed.

     */

    function generateRandomNumber(bytes32 _serverSeed, bytes32 _userSeed) public pure returns(uint) {

        bytes32 combinedHash = keccak256(abi.encodePacked(_serverSeed, _userSeed));

        return uint(combinedHash);

    }

}



contract FlipACoin is GameInterface, Utilities {

    using SafeCast for uint;

    using SafeMath for uint;



    uint private RANGE = 2;



    modifier onlyValidNum(uint _betNum) {

        require(_betNum >= 0 && _betNum <= 1, "Invalid num");

        _;

    }



    function maxBet(uint _betNum, uint _bankRoll) external onlyValidNum(_betNum) view returns(uint) {

        uint probability = Utilities.PROBABILITY_DIVISOR / RANGE;

        return Utilities.maxBetFromProbability(probability, _bankRoll);

    }



    function resultNumber(bytes32 _serverSeed, bytes32 _userSeed, uint _betNum) external onlyValidNum(_betNum) view returns(uint) {

        uint randNum = Utilities.generateRandomNumber(_serverSeed, _userSeed);

        return randNum % RANGE;

    }



    function userProfit(uint _betNum, uint _betValue, uint _resultNum)

        external

        onlyValidNum(_betNum)

        onlyValidNum(_resultNum)

        view

        returns(int)

    {

        bool won = _resultNum == _betNum;

        if (won) {

            uint totalWon = _betValue.mul(RANGE);

            return Utilities.calcProfitFromTotalWon(totalWon, _betValue);

        } else {

            return -_betValue.castToInt();

        }

    }



    function maxUserProfit(uint _betNum, uint _betValue) external onlyValidNum(_betNum) view returns(int) {

        uint totalWon = _betValue.mul(RANGE);

        return Utilities.calcProfitFromTotalWon(totalWon, _betValue);

    }

}