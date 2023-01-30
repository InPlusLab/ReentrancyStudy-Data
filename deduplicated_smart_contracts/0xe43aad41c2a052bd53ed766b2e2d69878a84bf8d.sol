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
        uint8 c = a - b;
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

contract DoubleChanceDice is gameContract {
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    using SafeMath for uint256;
    using SafeMath8 for uint8;

    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin) {
        require(getBitCount(betMask) == 1);

        maxWin = betAmount * 18;
    }

    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns (uint winAmount, uint256[10] result) {

        require(getBitCount(betMask) == 1);

        uint256[2] memory dice;
        dice[0] = uint256(entropy).mod(6);
        dice[1] = uint256(keccak256(abi.encodePacked(entropy))).mod(6);


        uint8 hit = 0;
        for (uint8 i = 0; i < 2; i++){
            if((2 ** dice[i]) & betMask !=0) {
                hit++;
            }
        }

        if (hit == 2) {
            winAmount = betAmount.mul(18);
        } else if(hit == 1) {
            winAmount = betAmount.div(10).mul(18);
        } else {
            winAmount = 0;
        }

        result[0] = dice[0];
        result[1] = dice[1];
    }
    function getBitCount(uint betMask) public pure returns(uint bitCount) {
        bitCount = (betMask.mul(POPCNT_MULT) & POPCNT_MASK).mod(POPCNT_MODULO);
    }
}