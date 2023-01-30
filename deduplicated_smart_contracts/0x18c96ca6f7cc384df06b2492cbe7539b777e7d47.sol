/**
 *Submitted for verification at Etherscan.io on 2020-11-15
*/

pragma solidity 0.6.11;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


interface IERC20 {
    function transfer(address, uint) external returns (bool);
}
interface LegacyIERC20 {
    function transfer(address, uint) external;
}

contract SwissLock is Ownable {
    using SafeMath for uint;

    // ------- Contract Variables -------


    // Swiss Token Address Here
    address public constant SWISS_TOKEN_ADDRESS = 0x692eb773E0b5B7A79EFac5A015C8b36A2577F65c;

    uint public constant ONE_DAY = 1 minutes;

    uint public constant ONE_WEEK = 1 weeks;

    // If there are any SWISS Tokens left in the contract
    // After this below time, admin can claim them.
    uint public constant ADMIN_CAN_CLAIM_AFTER = 6 * ONE_WEEK;

    address public constant organisation_wallet =  0x973878Fa3A9439DFB27F7DD1C107Fd6D581bB2f2; // Organisation wallet
    address public constant admin_wallet_1      =  0x0C6F8C0F523A9AA348fE99a7f740ED0aE171D7C2; // Team number 1
    address public constant admin_wallet_2      =  0x496079588149b6B019B36d1aCEf3b8FEE3C1613A; // Team number 2
    address public constant admin_wallet_3      =  0x7B45ec5d1501a2e2aca6c40E99f04729C7EdA633; // Team number 3
    address public constant admin_wallet_4      =  0x224F7803F9975c3a3bd64829db9908784fe52399; // Team number 4
    address public constant admin_wallet_5      =  0x5F459581D117be275dA8408942a9C92F22d98b39; // Team number 5
    address public constant admin_wallet_6      =  0x38cFfff72DcF64C3Fdbb66E23f7185Fb4769e01B; // Team number 6
    address public constant admin_wallet_7      =  0xfe5408a38F0Afba44Fd5Ed77E34D0943E354264a; // Team number 7
    address public constant admin_wallet_8      =  0xc17F69891407f3FD666E27c635F5d970a77b4A9F; // Team number 8


    // ------- END Contract Variables -------

    IERC20 public constant swissToken = IERC20(SWISS_TOKEN_ADDRESS);
    uint public rewardTimes = 0;

    uint public contractStartTime;
    uint public lastClaimTime;
    constructor() public {
        contractStartTime = now;
        lastClaimTime = contractStartTime;
    }

    function distributeAdminRewards() public {
        require(rewardTimes < 5, "distributeAdminRewards has already been called 5 times!");

        if (rewardTimes == 0) {
            require(now > lastClaimTime.add(ONE_DAY));
        } else {
            require(now > lastClaimTime.add(ONE_WEEK));
        }

        if (rewardTimes == 0) {

            require(swissToken.transfer(organisation_wallet, 200e18), "Could not transfer to organisation_wallet!");

        } else if (rewardTimes == 1) {

            require(swissToken.transfer(organisation_wallet, 70e18), "Could not transfer to organisation_wallet!");
            require(swissToken.transfer(admin_wallet_1,     180e18), "Could not transfer to admin_wallet_1!");
            require(swissToken.transfer(admin_wallet_2,     180e18), "Could not transfer to admin_wallet_2!");
            require(swissToken.transfer(admin_wallet_3,      30e18), "Could not transfer to admin_wallet_3!");
            require(swissToken.transfer(admin_wallet_4,      30e18), "Could not transfer to admin_wallet_4!");
            require(swissToken.transfer(admin_wallet_5,      25e18), "Could not transfer to admin_wallet_5!");
            require(swissToken.transfer(admin_wallet_6,       3e18), "Could not transfer to admin_wallet_6!");
            require(swissToken.transfer(admin_wallet_7,      65e18), "Could not transfer to admin_wallet_7!");
            require(swissToken.transfer(admin_wallet_8,      65e18), "Could not transfer to admin_wallet_8!");

        } else if (rewardTimes == 2) {

            require(swissToken.transfer(organisation_wallet, 50e18), "Could not transfer to organisation_wallet!");
            require(swissToken.transfer(admin_wallet_1,     180e18), "Could not transfer to admin_wallet_1!");
            require(swissToken.transfer(admin_wallet_2,     180e18), "Could not transfer to admin_wallet_2!");
            require(swissToken.transfer(admin_wallet_3,      30e18), "Could not transfer to admin_wallet_3!");
            require(swissToken.transfer(admin_wallet_4,      30e18), "Could not transfer to admin_wallet_4!");
            require(swissToken.transfer(admin_wallet_5,      25e18), "Could not transfer to admin_wallet_5!");
            require(swissToken.transfer(admin_wallet_6,       3e18), "Could not transfer to admin_wallet_6!");
            require(swissToken.transfer(admin_wallet_7,      65e18), "Could not transfer to admin_wallet_7!");
            require(swissToken.transfer(admin_wallet_8,      65e18), "Could not transfer to admin_wallet_8!");

        } else if (rewardTimes == 3) {

            require(swissToken.transfer(organisation_wallet, 50e18), "Could not transfer to organisation_wallet!");
            require(swissToken.transfer(admin_wallet_1,     160e18), "Could not transfer to admin_wallet_1!");
            require(swissToken.transfer(admin_wallet_2,     160e18), "Could not transfer to admin_wallet_2!");
            require(swissToken.transfer(admin_wallet_3,      25e18), "Could not transfer to admin_wallet_3!");
            require(swissToken.transfer(admin_wallet_4,      25e18), "Could not transfer to admin_wallet_4!");
            require(swissToken.transfer(admin_wallet_5,      20e18), "Could not transfer to admin_wallet_5!");
            require(swissToken.transfer(admin_wallet_6,       2e18), "Could not transfer to admin_wallet_6!");
            require(swissToken.transfer(admin_wallet_7,      55e18), "Could not transfer to admin_wallet_7!");
            require(swissToken.transfer(admin_wallet_8,      55e18), "Could not transfer to admin_wallet_8!");

        } else if (rewardTimes == 4) {

            require(swissToken.transfer(organisation_wallet, 40e18), "Could not transfer to organisation_wallet!");
            require(swissToken.transfer(admin_wallet_1,     150e18), "Could not transfer to admin_wallet_1!");
            require(swissToken.transfer(admin_wallet_2,     150e18), "Could not transfer to admin_wallet_2!");
            require(swissToken.transfer(admin_wallet_3,      20e18), "Could not transfer to admin_wallet_3!");
            require(swissToken.transfer(admin_wallet_4,      20e18), "Could not transfer to admin_wallet_4!");
            require(swissToken.transfer(admin_wallet_5,      10e18), "Could not transfer to admin_wallet_5!");
            require(swissToken.transfer(admin_wallet_6,       2e18), "Could not transfer to admin_wallet_6!");
            require(swissToken.transfer(admin_wallet_7,      40e18), "Could not transfer to admin_wallet_7!");
            require(swissToken.transfer(admin_wallet_8,      40e18), "Could not transfer to admin_wallet_8!");

        }

        lastClaimTime = now;
        rewardTimes = rewardTimes.add(1);
    }

    function transferAnyERC20Token(address _tokenAddress, address _to, uint _amount) public onlyOwner {
        require(_tokenAddress != SWISS_TOKEN_ADDRESS || now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Cannot Transfer out SWISS Tokens yet!");
        require(IERC20(_tokenAddress).transfer(_to, _amount), "Could not transfer Tokens!");
    }
    function transferAnyOldERC20Token(address _tokenAddress, address _to, uint _amount) public onlyOwner {
        require(_tokenAddress != SWISS_TOKEN_ADDRESS || now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Cannot Transfer out SWISS Tokens yet!");
        LegacyIERC20(_tokenAddress).transfer(_to, _amount);
    }
}