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

import './SafeMath.sol';
import './IERC20.sol';
import './sbControllerInterface.sol';
import './sbVotesInterface.sol';

contract sbStrongPool {
  event ServiceMinMineUpdated(uint256 amount);
  event MinerMinMineUpdated(uint256 amount);
  event MinedFor(address indexed miner, address indexed receiver, uint256 amount, uint256 indexed day);
  event RewardsReceived(uint256 indexed day, uint256 amount);
  event Mined(address indexed miner, uint256 amount, uint256 indexed day);
  event Unmined(address indexed miner, uint256 amount, uint256 indexed day);
  event MinedForVotesOnly(address indexed miner, uint256 amount, uint256 indexed day);
  event UnminedForVotesOnly(address indexed miner, uint256 amount, uint256 indexed day);
  event Claimed(address indexed miner, uint256 amount, uint256 indexed day);

  using SafeMath for uint256;

  bool internal initDone;

  IERC20 internal strongToken;
  sbControllerInterface internal sbController;
  sbVotesInterface internal sbVotes;
  address internal sbTimelock;

  uint256 internal serviceMinMine;
  uint256 internal minerMinMine;

  mapping(address => uint256[]) internal minerMineDays;
  mapping(address => uint256[]) internal minerMineAmounts;
  mapping(address => uint256[]) internal minerMineMineSeconds;

  uint256[] internal mineDays;
  uint256[] internal mineAmounts;
  uint256[] internal mineMineSeconds;

  mapping(address => uint256) internal minerDayLastClaimedFor;
  mapping(uint256 => uint256) internal dayRewards;

  mapping(address => uint256) internal mineForVotes;

  function init(
    address sbControllerAddress,
    address strongTokenAddress,
    address sbVotesAddress,
    address sbTimelockAddress,
    uint256 serviceMinMineAmount,
    uint256 minerMinMineAmount
  ) public {
    require(!initDone, 'init done');
    require(serviceMinMineAmount > 0, '1: zero');
    require(minerMinMineAmount > 0, '2: zero');
    sbController = sbControllerInterface(sbControllerAddress);
    strongToken = IERC20(strongTokenAddress);
    sbVotes = sbVotesInterface(sbVotesAddress);
    sbTimelock = sbTimelockAddress;
    serviceMinMine = serviceMinMineAmount;
    minerMinMine = minerMinMineAmount;
    initDone = true;
  }

  function serviceMinMined(address miner) external view returns (bool) {
    uint256 currentDay = _getCurrentDay();
    (, uint256 twoDaysAgoMine, ) = _getMinerMineData(miner, currentDay.sub(2));
    (, uint256 oneDayAgoMine, ) = _getMinerMineData(miner, currentDay.sub(1));
    (, uint256 todayMine, ) = _getMinerMineData(miner, currentDay);
    return twoDaysAgoMine >= serviceMinMine && oneDayAgoMine >= serviceMinMine && todayMine >= serviceMinMine;
  }

  function minerMinMined(address miner) external view returns (bool) {
    (, uint256 todayMine, ) = _getMinerMineData(miner, _getCurrentDay());
    return todayMine >= minerMinMine;
  }

  function updateServiceMinMine(uint256 serviceMinMineAmount) external {
    require(serviceMinMineAmount > 0, 'zero');
    require(
      msg.sender == sbTimelock,
      'not sbTimelock'
    );
    serviceMinMine = serviceMinMineAmount;
    emit ServiceMinMineUpdated(serviceMinMineAmount);
  }

  function updateMinerMinMine(uint256 minerMinMineAmount) external {
    require(minerMinMineAmount > 0, 'zero');
    require(
      msg.sender == sbTimelock,
      'not sbTimelock'
    );
    minerMinMine = minerMinMineAmount;
    emit MinerMinMineUpdated(minerMinMineAmount);
  }

  function mineFor(address miner, uint256 amount) external {
    require(amount > 0, 'zero');
    require(miner != address(0), 'zero address');
    if (msg.sender != address(this)) {
      strongToken.transferFrom(msg.sender, address(this), amount);
    }
    uint256 currentDay = _getCurrentDay();
    uint256 startDay = sbController.getStartDay();
    uint256 MAX_YEARS = sbController.getMaxYears();
    uint256 year = _getYearDayIsIn(currentDay, startDay);
    require(year <= MAX_YEARS, 'year limit met');
    _update(minerMineDays[miner], minerMineAmounts[miner], minerMineMineSeconds[miner], amount, true, currentDay);
    _update(mineDays, mineAmounts, mineMineSeconds, amount, true, currentDay);
    sbVotes.updateVotes(miner, amount, true);
    emit MinedFor(msg.sender, miner, amount, currentDay);
  }

  function getMineData(uint256 day)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    return _getMineData(day);
  }

  function receiveRewards(uint256 day, uint256 amount) external {
    require(amount > 0, 'zero');
    require(
      msg.sender == address(sbController),
      'not sbController'
    );
    strongToken.transferFrom(address(sbController), address(this), amount);
    dayRewards[day] = dayRewards[day].add(amount);
    emit RewardsReceived(day, amount);
  }

  function getDayRewards(uint256 day) public view returns (uint256) {
    require(day <= _getCurrentDay(), 'invalid day');
    return dayRewards[day];
  }

  function mine(uint256 amount) public {
    require(amount > 0, 'zero');
    strongToken.transferFrom(msg.sender, address(this), amount);
    uint256 currentDay = _getCurrentDay();
    uint256 startDay = sbController.getStartDay();
    uint256 MAX_YEARS = sbController.getMaxYears();
    uint256 year = _getYearDayIsIn(currentDay, startDay);
    require(year <= MAX_YEARS, 'year limit met');
    _update(
      minerMineDays[msg.sender],
      minerMineAmounts[msg.sender],
      minerMineMineSeconds[msg.sender],
      amount,
      true,
      currentDay
    );
    _update(mineDays, mineAmounts, mineMineSeconds, amount, true, currentDay);
    sbVotes.updateVotes(msg.sender, amount, true);
    emit Mined(msg.sender, amount, currentDay);
  }

  function unmine(uint256 amount) public {
    require(amount > 0, 'zero');
    uint256 currentDay = _getCurrentDay();
    _update(
      minerMineDays[msg.sender],
      minerMineAmounts[msg.sender],
      minerMineMineSeconds[msg.sender],
      amount,
      false,
      currentDay
    );
    _update(mineDays, mineAmounts, mineMineSeconds, amount, false, currentDay);
    sbVotes.updateVotes(msg.sender, amount, false);
    strongToken.transfer(msg.sender, amount);
    emit Unmined(msg.sender, amount, currentDay);
  }

  function mineForVotesOnly(uint256 amount) public {
    require(amount > 0, 'zero');
    strongToken.transferFrom(msg.sender, address(this), amount);
    uint256 currentDay = _getCurrentDay();
    uint256 startDay = sbController.getStartDay();
    uint256 MAX_YEARS = sbController.getMaxYears();
    uint256 year = _getYearDayIsIn(currentDay, startDay);
    require(year <= MAX_YEARS, 'year limit met');
    mineForVotes[msg.sender] = mineForVotes[msg.sender].add(amount);
    sbVotes.updateVotes(msg.sender, amount, true);
    emit MinedForVotesOnly(msg.sender, amount, currentDay);
  }

  function unmineForVotesOnly(uint256 amount) public {
    require(amount > 0, 'zero');
    require(mineForVotes[msg.sender] >= amount, 'not enough mine');
    mineForVotes[msg.sender] = mineForVotes[msg.sender].sub(amount);
    sbVotes.updateVotes(msg.sender, amount, false);
    strongToken.transfer(msg.sender, amount);
    emit UnminedForVotesOnly(msg.sender, amount, _getCurrentDay());
  }

  function getMineForVotesOnly(address miner) public view returns (uint256) {
    return mineForVotes[miner];
  }

  function getServiceMinMineAmount() public view returns (uint256) {
    return serviceMinMine;
  }

  function getMinerMinMineAmount() public view returns (uint256) {
    return minerMinMine;
  }

  function getSbControllerAddressUsed() public view returns (address) {
    return address(sbController);
  }

  function getStrongAddressUsed() public view returns (address) {
    return address(strongToken);
  }

  function getSbVotesAddressUsed() public view returns (address) {
    return address(sbVotes);
  }

  function getSbTimelockAddressUsed() public view returns (address) {
    return sbTimelock;
  }

  function getMinerDayLastClaimedFor(address miner) public view returns (uint256) {
    return minerDayLastClaimedFor[miner] == 0 ? sbController.getStartDay().sub(1) : minerDayLastClaimedFor[miner];
  }

  function claimAll() public {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[msg.sender];
    require(currentDay > dayLastClaimedFor.add(7), 'already claimed');
    require(sbController.upToDate(), 'need rewards released');
    _claim(currentDay, msg.sender, dayLastClaimedFor);
  }

  function claimUpTo(uint256 day) public {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[msg.sender];
    require(day > dayLastClaimedFor.add(7), 'already claimed');
    require(sbController.upToDate(), 'need rewards released');
    _claim(day, msg.sender, dayLastClaimedFor);
  }

  function getRewardsDueAll(address miner) public view returns (uint256) {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[miner] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[miner];
    if (!(currentDay > dayLastClaimedFor.add(7))) {
      return 0;
    }
    require(sbController.upToDate(), 'need rewards released');
    return _getRewardsDue(currentDay, miner, dayLastClaimedFor);
  }

  function getRewardsDueUpTo(uint256 day, address miner) public view returns (uint256) {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[miner] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[miner];
    if (!(day > dayLastClaimedFor.add(7))) {
      return 0;
    }
    require(sbController.upToDate(), 'need rewards released');
    return _getRewardsDue(day, miner, dayLastClaimedFor);
  }

  function getMinerMineData(address miner, uint256 day)
    public
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    return _getMinerMineData(miner, day);
  }

  function _getMineData(uint256 day)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    return _get(mineDays, mineAmounts, mineMineSeconds, day);
  }

  function _getMinerMineData(address miner, uint256 day)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256[] memory _Days = minerMineDays[miner];
    uint256[] memory _Amounts = minerMineAmounts[miner];
    uint256[] memory _UnitSeconds = minerMineMineSeconds[miner];
    return _get(_Days, _Amounts, _UnitSeconds, day);
  }

  function _get(
    uint256[] memory _Days,
    uint256[] memory _Amounts,
    uint256[] memory _UnitSeconds,
    uint256 day
  )
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256 len = _Days.length;
    if (len == 0) {
      return (day, 0, 0);
    }
    if (day < _Days[0]) {
      return (day, 0, 0);
    }
    uint256 lastIndex = len.sub(1);
    uint256 lastMinedDay = _Days[lastIndex];
    if (day == lastMinedDay) {
      return (day, _Amounts[lastIndex], _UnitSeconds[lastIndex]);
    } else if (day > lastMinedDay) {
      return (day, _Amounts[lastIndex], _Amounts[lastIndex].mul(1 days));
    }
    return _find(_Days, _Amounts, _UnitSeconds, day);
  }

  function _find(
    uint256[] memory _Days,
    uint256[] memory _Amounts,
    uint256[] memory _UnitSeconds,
    uint256 day
  )
    internal
    pure
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256 left = 0;
    uint256 right = _Days.length.sub(1);
    uint256 middle = right.add(left).div(2);
    while (left < right) {
      if (_Days[middle] == day) {
        return (day, _Amounts[middle], _UnitSeconds[middle]);
      } else if (_Days[middle] > day) {
        if (middle > 0 && _Days[middle.sub(1)] < day) {
          return (day, _Amounts[middle.sub(1)], _Amounts[middle.sub(1)].mul(1 days));
        }
        if (middle == 0) {
          return (day, 0, 0);
        }
        right = middle.sub(1);
      } else if (_Days[middle] < day) {
        if (middle < _Days.length.sub(1) && _Days[middle.add(1)] > day) {
          return (day, _Amounts[middle], _Amounts[middle].mul(1 days));
        }
        left = middle.add(1);
      }
      middle = right.add(left).div(2);
    }
    if (_Days[middle] != day) {
      return (day, 0, 0);
    } else {
      return (day, _Amounts[middle], _UnitSeconds[middle]);
    }
  }

  function _update(
    uint256[] storage _Days,
    uint256[] storage _Amounts,
    uint256[] storage _UnitSeconds,
    uint256 amount,
    bool adding,
    uint256 currentDay
  ) internal {
    uint256 len = _Days.length;
    uint256 secondsInADay = 1 days;
    uint256 secondsSinceStartOfDay = block.timestamp % secondsInADay;
    uint256 secondsUntilEndOfDay = secondsInADay.sub(secondsSinceStartOfDay);

    if (len == 0) {
      if (adding) {
        _Days.push(currentDay);
        _Amounts.push(amount);
        _UnitSeconds.push(amount.mul(secondsUntilEndOfDay));
      } else {
        require(false, '1: not enough mine');
      }
    } else {
      uint256 lastIndex = len.sub(1);
      uint256 lastMinedDay = _Days[lastIndex];
      uint256 lastMinedAmount = _Amounts[lastIndex];
      uint256 lastUnitSeconds = _UnitSeconds[lastIndex];

      uint256 newAmount;
      uint256 newUnitSeconds;

      if (lastMinedDay == currentDay) {
        if (adding) {
          newAmount = lastMinedAmount.add(amount);
          newUnitSeconds = lastUnitSeconds.add(amount.mul(secondsUntilEndOfDay));
        } else {
          require(lastMinedAmount >= amount, '2: not enough mine');
          newAmount = lastMinedAmount.sub(amount);
          newUnitSeconds = lastUnitSeconds.sub(amount.mul(secondsUntilEndOfDay));
        }
        _Amounts[lastIndex] = newAmount;
        _UnitSeconds[lastIndex] = newUnitSeconds;
      } else {
        if (adding) {
          newAmount = lastMinedAmount.add(amount);
          newUnitSeconds = lastMinedAmount.mul(1 days).add(amount.mul(secondsUntilEndOfDay));
        } else {
          require(lastMinedAmount >= amount, '3: not enough mine');
          newAmount = lastMinedAmount.sub(amount);
          newUnitSeconds = lastMinedAmount.mul(1 days).sub(amount.mul(secondsUntilEndOfDay));
        }
        _Days.push(currentDay);
        _Amounts.push(newAmount);
        _UnitSeconds.push(newUnitSeconds);
      }
    }
  }

  function _getCurrentDay() internal view returns (uint256) {
    return block.timestamp.div(1 days).add(1);
  }

  function _claim(
    uint256 upToDay,
    address miner,
    uint256 dayLastClaimedFor
  ) internal {
    uint256 rewards = _getRewardsDue(upToDay, miner, dayLastClaimedFor);
    require(rewards > 0, 'no rewards');
    minerDayLastClaimedFor[miner] = upToDay.sub(7);
    this.mineFor(miner, rewards);
    emit Claimed(miner, rewards, _getCurrentDay());
  }

  function _getRewardsDue(
    uint256 upToDay,
    address miner,
    uint256 dayLastClaimedFor
  ) internal view returns (uint256) {
    uint256 rewards;
    for (uint256 day = dayLastClaimedFor.add(1); day <= upToDay.sub(7); day++) {
      (, , uint256 minerMineSecondsForDay) = _getMinerMineData(miner, day);
      (, , uint256 mineSecondsForDay) = _getMineData(day);
      if (mineSecondsForDay == 0) {
        continue;
      }
      uint256 strongPoolDayRewards = dayRewards[day];
      uint256 amount = strongPoolDayRewards.mul(minerMineSecondsForDay).div(mineSecondsForDay);
      rewards = rewards.add(amount);
    }
    return rewards;
  }

  function _getYearDayIsIn(uint256 day, uint256 startDay) internal pure returns (uint256) {
    return day.sub(startDay).div(366).add(1); // dividing by 366 makes day 1 and 365 be in year 1
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface sbControllerInterface {
  function getDayMineSecondsUSDTotal(uint256 day) external view returns (uint256);

  function getCommunityDayMineSecondsUSD(address community, uint256 day) external view returns (uint256);

  function getCommunityDayRewards(address community, uint256 day) external view returns (uint256);

  function getStartDay() external view returns (uint256);

  function getMaxYears() external view returns (uint256);

  function getStrongPoolDailyRewards(uint256 day) external view returns (uint256);

  function communityAccepted(address community) external view returns (bool);

  function getCommunities() external view returns (address[] memory);

  function upToDate() external view returns (bool);
}

