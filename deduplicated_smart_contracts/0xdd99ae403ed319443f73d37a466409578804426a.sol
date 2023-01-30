// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import './SafeMath.sol';
import './IERC20.sol';
import './sbTokensInterface.sol';
import './sbCommunityInterface.sol';
import './sbStrongPoolInterface.sol';
import './sbVotesInterface.sol';

contract sbController {
  event CommunityAdded(address indexed community);
  event RewardsReleased(address indexed receiver, uint256 amount, uint256 indexed day);

  using SafeMath for uint256;

  bool internal initDone;

  address internal sbTimelock;
  IERC20 internal strongToken;
  sbTokensInterface internal sbTokens;
  sbStrongPoolInterface internal sbStrongPool;
  sbVotesInterface internal sbVotes;
  uint256 internal startDay;

  mapping(uint256 => uint256) internal COMMUNITY_DAILY_REWARDS_BY_YEAR;
  mapping(uint256 => uint256) internal STRONGPOOL_DAILY_REWARDS_BY_YEAR;
  mapping(uint256 => uint256) internal VOTER_DAILY_REWARDS_BY_YEAR;
  uint256 internal MAX_YEARS;

  address[] internal communities;

  mapping(uint256 => uint256) internal dayMineSecondsUSDTotal;
  mapping(address => mapping(uint256 => uint256)) internal communityDayMineSecondsUSD;
  mapping(address => mapping(uint256 => uint256)) internal communityDayRewards;
  mapping(address => uint256) internal communityDayStart;
  uint256 internal dayLastReleasedRewardsFor;

  function init(
    address sbTimelockAddress,
    address strongTokenAddress,
    address sbTokensAddress,
    address sbStrongPoolAddress,
    address sbCommunityAddress,
    address sbVotesAddress
  ) public {
    require(!initDone, 'init done');
    uint256 currentDay = _getCurrentDay();
    sbTimelock = sbTimelockAddress;
    strongToken = IERC20(strongTokenAddress);
    sbTokens = sbTokensInterface(sbTokensAddress);
    sbStrongPool = sbStrongPoolInterface(sbStrongPoolAddress);
    sbVotes = sbVotesInterface(sbVotesAddress);
    startDay = currentDay;
    dayLastReleasedRewardsFor = currentDay.sub(1);

    communities.push(sbCommunityAddress);
    communityDayStart[sbCommunityAddress] = currentDay;

    MAX_YEARS = 4;
    COMMUNITY_DAILY_REWARDS_BY_YEAR[1] = 2888e18;
    COMMUNITY_DAILY_REWARDS_BY_YEAR[2] = 2088e18;
    COMMUNITY_DAILY_REWARDS_BY_YEAR[3] = 1288e18;
    COMMUNITY_DAILY_REWARDS_BY_YEAR[4] = 888e18;

    STRONGPOOL_DAILY_REWARDS_BY_YEAR[1] = 800e18;
    STRONGPOOL_DAILY_REWARDS_BY_YEAR[2] = 1000e18;
    STRONGPOOL_DAILY_REWARDS_BY_YEAR[3] = 1100e18;
    STRONGPOOL_DAILY_REWARDS_BY_YEAR[4] = 1200e18;

    VOTER_DAILY_REWARDS_BY_YEAR[1] = 88e18;
    VOTER_DAILY_REWARDS_BY_YEAR[2] = 88e18;
    VOTER_DAILY_REWARDS_BY_YEAR[3] = 88e18;
    VOTER_DAILY_REWARDS_BY_YEAR[4] = 88e18;

    initDone = true;
  }

  function upToDate() external view returns (bool) {
    return dayLastReleasedRewardsFor == _getCurrentDay().sub(1);
  }

  function addCommunity(address community) external {
    require(msg.sender == sbTimelock, 'not sbTimelock');
    require(community != address(0), 'community not zero address');
    require(!_communityExists(community), 'community exists');
    communities.push(community);
    communityDayStart[community] = _getCurrentDay();
    emit CommunityAdded(community);
  }

  function getCommunities() external view returns (address[] memory) {
    return communities;
  }

  function getDayMineSecondsUSDTotal(uint256 day) external view returns (uint256) {
    require(day >= startDay, '1: invalid day');
    require(day <= dayLastReleasedRewardsFor, '2: invalid day');
    return dayMineSecondsUSDTotal[day];
  }

  function getCommunityDayMineSecondsUSD(address community, uint256 day) external view returns (uint256) {
    require(_communityExists(community), 'invalid community');
    require(
      day >= communityDayStart[community],
      '1: invalid day'
    );
    require(day <= dayLastReleasedRewardsFor, '2: invalid day');
    return communityDayMineSecondsUSD[community][day];
  }

  function getCommunityDayRewards(address community, uint256 day) external view returns (uint256) {
    require(_communityExists(community), 'invalid community');
    require(
      day >= communityDayStart[community],
      '1: invalid day'
    );
    require(day <= dayLastReleasedRewardsFor, '2: invalid day');
    return communityDayRewards[community][day];
  }

  function getCommunityDailyRewards(uint256 day) external view returns (uint256) {
    require(day >= startDay, 'invalid day');
    uint256 year = _getYearDayIsIn(day);
    require(year <= MAX_YEARS, 'invalid year');
    return COMMUNITY_DAILY_REWARDS_BY_YEAR[year];
  }

  function getStrongPoolDailyRewards(uint256 day) external view returns (uint256) {
    require(day >= startDay, 'invalid day');
    uint256 year = _getYearDayIsIn(day);
    require(year <= MAX_YEARS, 'invalid year');
    return STRONGPOOL_DAILY_REWARDS_BY_YEAR[year];
  }

  function getVoterDailyRewards(uint256 day) external view returns (uint256) {
    require(day >= startDay, 'invalid day');
    uint256 year = _getYearDayIsIn(day);
    require(year <= MAX_YEARS, 'invalid year');
    return VOTER_DAILY_REWARDS_BY_YEAR[year];
  }

  function getStartDay() external view returns (uint256) {
    return startDay;
  }

  function communityAccepted(address community) external view returns (bool) {
    return _communityExists(community);
  }

  function getMaxYears() public view returns (uint256) {
    return MAX_YEARS;
  }

  function getCommunityDayStart(address community) public view returns (uint256) {
    require(_communityExists(community), 'invalid community');
    return communityDayStart[community];
  }

  function getSbTimelockAddressUsed() public view returns (address) {
    return sbTimelock;
  }

  function getStrongAddressUsed() public view returns (address) {
    return address(strongToken);
  }

  function getSbTokensAddressUsed() public view returns (address) {
    return address(sbTokens);
  }

  function getSbStrongPoolAddressUsed() public view returns (address) {
    return address(sbStrongPool);
  }

  function getSbVotesAddressUsed() public view returns (address) {
    return address(sbVotes);
  }

  function getCurrentYear() public view returns (uint256) {
    uint256 day = _getCurrentDay().sub(startDay);
    return _getYearDayIsIn(day == 0 ? startDay : day);
  }

  function getYearDayIsIn(uint256 day) public view returns (uint256) {
    require(day >= startDay, 'invalid day');
    return _getYearDayIsIn(day);
  }

  function getCurrentDay() public view returns (uint256) {
    return _getCurrentDay();
  }

  function getDayLastReleasedRewardsFor() public view returns (uint256) {
    return dayLastReleasedRewardsFor;
  }

  function releaseRewards() public {
    uint256 currentDay = _getCurrentDay();
    require(
      currentDay > dayLastReleasedRewardsFor.add(1),
      'already released'
    );
    require(sbTokens.upToDate(), 'need token prices');
    dayLastReleasedRewardsFor = dayLastReleasedRewardsFor.add(1);
    uint256 year = _getYearDayIsIn(dayLastReleasedRewardsFor);
    require(year <= MAX_YEARS, 'invalid year');
    address[] memory tokenAddresses = sbTokens.getTokens();
    uint256[] memory tokenPrices = sbTokens.getTokenPrices(dayLastReleasedRewardsFor);
    for (uint256 i = 0; i < communities.length; i++) {
      address community = communities[i];
      uint256 sum = 0;
      for (uint256 j = 0; j < tokenAddresses.length; j++) {
        address token = tokenAddresses[j];
        (, , uint256 minedSeconds) = sbCommunityInterface(community).getTokenData(token, dayLastReleasedRewardsFor);
        uint256 tokenPrice = tokenPrices[j];
        uint256 minedSecondsUSD = tokenPrice.mul(minedSeconds).div(1e18);
        sum = sum.add(minedSecondsUSD);
      }
      communityDayMineSecondsUSD[community][dayLastReleasedRewardsFor] = sum;
      dayMineSecondsUSDTotal[dayLastReleasedRewardsFor] = dayMineSecondsUSDTotal[dayLastReleasedRewardsFor].add(sum);
    }
    for (uint256 i = 0; i < communities.length; i++) {
      address community = communities[i];
      if (communityDayMineSecondsUSD[community][dayLastReleasedRewardsFor] == 0) {
        continue;
      }
      communityDayRewards[community][dayLastReleasedRewardsFor] = communityDayMineSecondsUSD[community][dayLastReleasedRewardsFor]
        .mul(COMMUNITY_DAILY_REWARDS_BY_YEAR[year])
        .div(dayMineSecondsUSDTotal[dayLastReleasedRewardsFor]);

      uint256 amount = communityDayRewards[community][dayLastReleasedRewardsFor];
      strongToken.approve(community, amount);
      sbCommunityInterface(community).receiveRewards(dayLastReleasedRewardsFor, amount);
      emit RewardsReleased(community, amount, currentDay);
    }
    (,, uint256 strongPoolMineSeconds) = sbStrongPool.getMineData(dayLastReleasedRewardsFor);
    if (strongPoolMineSeconds != 0) {
      strongToken.approve(address(sbStrongPool), STRONGPOOL_DAILY_REWARDS_BY_YEAR[year]);
      sbStrongPool.receiveRewards(dayLastReleasedRewardsFor, STRONGPOOL_DAILY_REWARDS_BY_YEAR[year]);
      emit RewardsReleased(address(sbStrongPool), STRONGPOOL_DAILY_REWARDS_BY_YEAR[year], currentDay);
    }
    bool hasVoteSeconds = false;
    for (uint256 i = 0; i < communities.length; i++) {
      address community = communities[i];
      (, , uint256 voteSeconds) = sbVotes.getCommunityData(community, dayLastReleasedRewardsFor);
      if (voteSeconds > 0) {
        hasVoteSeconds = true;
        break;
      }
    }
    if (hasVoteSeconds) {
      strongToken.approve(address(sbVotes), VOTER_DAILY_REWARDS_BY_YEAR[year]);
      sbVotes.receiveVoterRewards(dayLastReleasedRewardsFor, VOTER_DAILY_REWARDS_BY_YEAR[year]);
      emit RewardsReleased(address(sbVotes), VOTER_DAILY_REWARDS_BY_YEAR[year], currentDay);
    }
  }

  function _getCurrentDay() internal view returns (uint256) {
    return block.timestamp.div(1 days).add(1);
  }

  function _communityExists(address community) internal view returns (bool) {
    for (uint256 i = 0; i < communities.length; i++) {
      if (communities[i] == community) {
        return true;
      }
    }
    return false;
  }

  function _getYearDayIsIn(uint256 day) internal view returns (uint256) {
    return day.sub(startDay).div(366).add(1); // dividing by 366 makes day 1 and 365 be in year 1
  }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface sbVotesInterface {
  function getCommunityData(address community, uint256 day)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );

  function getPriorProposalVotes(address account, uint256 blockNumber) external view returns (uint96);

  function receiveServiceRewards(uint256 day, uint256 amount) external;

  function receiveVoterRewards(uint256 day, uint256 amount) external;

  function updateVotes(
    address staker,
    uint256 rawAmount,
    bool adding
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface sbTokensInterface {
  function getTokens() external view returns (address[] memory);

  function getTokenPrices(uint256 day) external view returns (uint256[] memory);

  function tokenAccepted(address token) external view returns (bool);

  function upToDate() external view returns (bool);

  function getTokenPrice(address token, uint256 day) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface sbStrongPoolInterface {
  function serviceMinMined(address miner) external view returns (bool);

  function minerMinMined(address miner) external view returns (bool);

  function mineFor(address miner, uint256 amount) external;

  function getMineData(uint256 day)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );

  function receiveRewards(uint256 day, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface sbCommunityInterface {
  function getTokenData(address token, uint256 day)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    );

  function receiveRewards(uint256 day, uint256 amount) external;

  function serviceAccepted(address service) external view returns (bool);

  function getMinerRewardPercentage() external view returns (uint256);
}

