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
import './sbTokensInterface.sol';
import './sbControllerInterface.sol';
import './sbStrongPoolInterface.sol';
import './sbVotesInterface.sol';

contract sbCommunity {
  event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
  event NewAdmin(address oldAdmin, address newAdmin);
  event MinerRewardsPercentageUpdated(uint256 percentage);
  event RewardsReceived(uint256 indexed day, uint256 amount);
  event ETHMined(address indexed miner, uint256 amount, uint256 indexed day);
  event ETHUnmined(address indexed miner, uint256 amount, uint256 indexed day);
  event ERC20Mined(address indexed miner, address indexed token, uint256 amount, uint256 indexed day);
  event ERC20Unmined(address indexed miner, address indexed token, uint256 amount, uint256 indexed day);
  event Claimed(address indexed miner, uint256 amount, uint256 indexed day);
  event ServiceAdded(address indexed service, string tag);
  event TagAddedForService(address indexed service, string tag);

  using SafeMath for uint256;
  bool internal initDone;
  address internal constant ETH = address(0);
  string internal name;
  uint256 internal minerRewardPercentage;

  IERC20 internal strongToken;
  sbTokensInterface internal sbTokens;
  sbControllerInterface internal sbController;
  sbStrongPoolInterface internal sbStrongPool;
  sbVotesInterface internal sbVotes;
  address internal sbTimelock;
  address internal admin;
  address internal pendingAdmin;

  mapping(address => mapping(address => uint256[])) internal minerTokenDays;
  mapping(address => mapping(address => uint256[])) internal minerTokenAmounts;
  mapping(address => mapping(address => uint256[])) internal minerTokenMineSeconds;

  mapping(address => uint256[]) internal tokenDays;
  mapping(address => uint256[]) internal tokenAmounts;
  mapping(address => uint256[]) internal tokenMineSeconds;

  mapping(address => uint256) internal minerDayLastClaimedFor;
  mapping(uint256 => uint256) internal dayServiceRewards;

  address[] internal services;
  mapping(address => string[]) internal serviceTags;

  function init(
    address adminAddress,
    address sbControllerAddress,
    address strongTokenAddress,
    address sbTokensAddress,
    address sbStrongPoolAddress,
    address sbVotesAddress,
    address sbTimelockAddress,
    uint256 minerRewardPercent,
    string memory communityName
  ) public {
    require(!initDone, 'init done');
    strongToken = IERC20(strongTokenAddress);
    sbTokens = sbTokensInterface(sbTokensAddress);
    sbController = sbControllerInterface(sbControllerAddress);
    sbStrongPool = sbStrongPoolInterface(sbStrongPoolAddress);
    sbVotes = sbVotesInterface(sbVotesAddress);
    sbTimelock = sbTimelockAddress;
    minerRewardPercentage = minerRewardPercent;
    name = communityName;
    admin = adminAddress;

    initDone = true;
  }

  function updateMinerRewardPercentage(uint256 percentage) external {
    require(msg.sender == sbTimelock, 'not sbTimelock');
    require(percentage <= 100, 'greater than 100');
    minerRewardPercentage = percentage;
    emit MinerRewardsPercentageUpdated(percentage);
  }

  function getTokenData(address token, uint256 day)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    require(sbTokens.tokenAccepted(token), 'invalid token');
    require(day <= _getCurrentDay(), 'invalid day');
    return _getTokenData(token, day);
  }

  function serviceAccepted(address service) external view returns (bool) {
    return _serviceExists(service);
  }

  function receiveRewards(uint256 day, uint256 amount) external {
    require(amount > 0, 'zero');
    require(msg.sender == address(sbController), 'not sbController');
    strongToken.transferFrom(address(sbController), address(this), amount);
    uint256 oneHundred = 100;
    uint256 serviceReward = oneHundred.sub(minerRewardPercentage).mul(amount).div(oneHundred);
    (, , uint256 communityVoteSeconds) = sbVotes.getCommunityData(address(this), day);
    if (communityVoteSeconds != 0 && serviceReward != 0) {
      dayServiceRewards[day] = serviceReward;
      strongToken.approve(address(sbVotes), serviceReward);
      sbVotes.receiveServiceRewards(day, serviceReward);
    }
    emit RewardsReceived(day, amount.sub(serviceReward));
  }

  function getMinerRewardPercentage() external view returns (uint256) {
    return minerRewardPercentage;
  }

  function addService(address service, string memory tag) public {
    require(msg.sender == admin, 'not admin');
    require(
      sbStrongPool.serviceMinMined(service),
      'not min mined'
    );
    require(service != address(0), 'service not zero address');
    require(!_serviceExists(service), 'service exists');
    services.push(service);
    serviceTags[service].push(tag);
    emit ServiceAdded(service, tag);
  }

  function getServices() public view returns (address[] memory) {
    return services;
  }

  function getServiceTags(address service) public view returns (string[] memory) {
    require(_serviceExists(service), 'invalid service');
    return serviceTags[service];
  }

  function addTag(address service, string memory tag) public {
    require(msg.sender == admin, 'not admin');
    require(_serviceExists(service), 'invalid service');
    require(!_serviceTagExists(service, tag), 'tag exists');
    serviceTags[service].push(tag);
    emit TagAddedForService(service, tag);
  }

  function setPendingAdmin(address newPendingAdmin) public {
    require(msg.sender == admin, 'not admin');
    address oldPendingAdmin = pendingAdmin;
    pendingAdmin = newPendingAdmin;
    emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
  }

  function acceptAdmin() public {
    require(
      msg.sender == pendingAdmin && msg.sender != address(0),
      'not pendingAdmin'
    );
    address oldAdmin = admin;
    address oldPendingAdmin = pendingAdmin;
    admin = pendingAdmin;
    pendingAdmin = address(0);
    emit NewAdmin(oldAdmin, admin);
    emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
  }

  function getAdminAddressUsed() public view returns (address) {
    return admin;
  }

  function getPendingAdminAddressUsed() public view returns (address) {
    return pendingAdmin;
  }

  function getSbControllerAddressUsed() public view returns (address) {
    return address(sbController);
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

  function getSbTimelockAddressUsed() public view returns (address) {
    return sbTimelock;
  }

  function getDayServiceRewards(uint256 day) public view returns (uint256) {
    return dayServiceRewards[day];
  }

  function getName() public view returns (string memory) {
    return name;
  }

  function getCurrentDay() public view returns (uint256) {
    return _getCurrentDay();
  }

  function mineETH() public payable {
    require(msg.value > 0, 'zero');
    require(sbTokens.tokenAccepted(ETH), 'invalid token');
    uint256 currentDay = _getCurrentDay();
    uint256 startDay = sbController.getStartDay();
    uint256 MAX_YEARS = sbController.getMaxYears();
    uint256 year = _getYearDayIsIn(currentDay, startDay);
    require(year <= MAX_YEARS, 'invalid year');
    require(sbStrongPool.minerMinMined(msg.sender), 'not min mined');
    _updateMinerTokenData(msg.sender, ETH, msg.value, true, currentDay);
    _updateTokenData(ETH, msg.value, true, currentDay);
    emit ETHMined(msg.sender, msg.value, currentDay);
  }

  function mineERC20(address token, uint256 amount) public {
    require(amount > 0, 'zero');
    require(token != ETH, 'no mine ETH');
    require(sbTokens.tokenAccepted(token), 'invalid token');
    IERC20(token).transferFrom(msg.sender, address(this), amount);
    uint256 currentDay = _getCurrentDay();
    uint256 startDay = sbController.getStartDay();
    uint256 MAX_YEARS = sbController.getMaxYears();
    uint256 year = _getYearDayIsIn(currentDay, startDay);
    require(year <= MAX_YEARS, 'invalid year');
    require(sbStrongPool.minerMinMined(msg.sender), 'not min mined');
    _updateMinerTokenData(msg.sender, token, amount, true, currentDay);
    _updateTokenData(token, amount, true, currentDay);
    emit ERC20Mined(msg.sender, token, amount, currentDay);
  }

  function unmine(address token, uint256 amount) public {
    require(amount > 0, 'zero');
    require(sbTokens.tokenAccepted(token), 'invalid token');

    uint256 currentDay = _getCurrentDay();
    _updateMinerTokenData(msg.sender, token, amount, false, currentDay);
    _updateTokenData(token, amount, false, currentDay);

    if (token == ETH) {
      msg.sender.transfer(amount);
      emit ETHUnmined(msg.sender, amount, currentDay);
    } else {
      IERC20(token).transfer(msg.sender, amount);
      emit ERC20Unmined(msg.sender, token, amount, currentDay);
    }
  }

  function claimAll() public {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[msg.sender];
    require(currentDay > dayLastClaimedFor.add(1), 'already claimed');
    require(sbTokens.upToDate(), 'need token prices');
    require(sbController.upToDate(), 'need rewards released');
    _claim(currentDay, msg.sender, dayLastClaimedFor);
  }

  function claimUpTo(uint256 day) public {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[msg.sender];
    require(day > dayLastClaimedFor.add(1), 'already claimed');
    require(sbTokens.upToDate(), 'need token prices');
    require(sbController.upToDate(), 'need rewards released');
    _claim(day, msg.sender, dayLastClaimedFor);
  }

  function getRewardsDueAll(address miner) public view returns (uint256) {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[miner] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[miner];
    if (!(currentDay > dayLastClaimedFor.add(1))) {
      return 0;
    }
    require(sbTokens.upToDate(), 'need token prices');
    require(sbController.upToDate(), 'need rewards released');
    return _getRewardsDue(currentDay, miner, dayLastClaimedFor);
  }

  function getRewardsDueUpTo(uint256 day, address miner) public view returns (uint256) {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = minerDayLastClaimedFor[miner] == 0
      ? sbController.getStartDay().sub(1)
      : minerDayLastClaimedFor[miner];
    if (!(day > dayLastClaimedFor.add(1))) {
      return 0;
    }
    require(sbTokens.upToDate(), 'need token prices');
    require(sbController.upToDate(), 'need rewards released');
    return _getRewardsDue(day, miner, dayLastClaimedFor);
  }



  function getMinerDayLastClaimedFor(address miner) public view returns (uint256) {
    return minerDayLastClaimedFor[miner] == 0 ? sbController.getStartDay().sub(1) : minerDayLastClaimedFor[miner];
  }

  function getMinerTokenData(
    address miner,
    address token,
    uint256 day
  )
    public
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    require(sbTokens.tokenAccepted(token), 'invalid token');
    require(day <= _getCurrentDay(), 'invalid day');
    return _getMinerTokenData(miner, token, day);
  }

  function _getMinerTokenData(
    address miner,
    address token,
    uint256 day
  )
    public
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256[] memory _Days = minerTokenDays[miner][token];
    uint256[] memory _Amounts = minerTokenAmounts[miner][token];
    uint256[] memory _UnitSeconds = minerTokenMineSeconds[miner][token];
    return _get(_Days, _Amounts, _UnitSeconds, day);
  }

  function _getTokenData(address token, uint256 day)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256[] memory _Days = tokenDays[token];
    uint256[] memory _Amounts = tokenAmounts[token];
    uint256[] memory _UnitSeconds = tokenMineSeconds[token];
    return _get(_Days, _Amounts, _UnitSeconds, day);
  }

  function _updateMinerTokenData(
    address miner,
    address token,
    uint256 amount,
    bool adding,
    uint256 currentDay
  ) internal {
    uint256[] storage _Days = minerTokenDays[miner][token];
    uint256[] storage _Amounts = minerTokenAmounts[miner][token];
    uint256[] storage _UnitSeconds = minerTokenMineSeconds[miner][token];
    _update(_Days, _Amounts, _UnitSeconds, amount, adding, currentDay);
  }

  function _updateTokenData(
    address token,
    uint256 amount,
    bool adding,
    uint256 currentDay
  ) internal {
    uint256[] storage _Days = tokenDays[token];
    uint256[] storage _Amounts = tokenAmounts[token];
    uint256[] storage _UnitSeconds = tokenMineSeconds[token];
    _update(_Days, _Amounts, _UnitSeconds, amount, adding, currentDay);
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

  function _claim(
    uint256 upToDay,
    address miner,
    uint256 dayLastClaimedFor
  ) internal {
    uint256 rewards = _getRewardsDue(upToDay, miner, dayLastClaimedFor);
    require(rewards > 0, 'no rewards');
    minerDayLastClaimedFor[miner] = upToDay.sub(1);
    strongToken.approve(address(sbStrongPool), rewards);
    sbStrongPool.mineFor(miner, rewards);
    emit Claimed(miner, rewards, _getCurrentDay());
  }

  function _getRewardsDue(
    uint256 upToDay,
    address miner,
    uint256 dayLastClaimedFor
  ) internal view returns (uint256) {
    address[] memory tokens = sbTokens.getTokens();
    uint256 rewards;
    for (uint256 day = dayLastClaimedFor.add(1); day <= upToDay.sub(1); day++) {
      uint256 communityDayMineSecondsUSD = sbController.getCommunityDayMineSecondsUSD(address(this), day);
      if (communityDayMineSecondsUSD == 0) {
        continue;
      }
      uint256 minerDayMineSecondsUSD = 0;
      uint256[] memory tokenPrices = sbTokens.getTokenPrices(day);
      for (uint256 i = 0; i < tokens.length; i++) {
        address token = tokens[i];
        (, , uint256 minerMineSeconds) = _getMinerTokenData(miner, token, day);
        uint256 amount = minerMineSeconds.mul(tokenPrices[i]).div(1e18);
        minerDayMineSecondsUSD = minerDayMineSecondsUSD.add(amount);
      }
      uint256 communityDayRewards = sbController.getCommunityDayRewards(address(this), day).sub(dayServiceRewards[day]);
      uint256 amount = communityDayRewards.mul(minerDayMineSecondsUSD).div(communityDayMineSecondsUSD);
      rewards = rewards.add(amount);
    }
    return rewards;
  }

  function _serviceExists(address service) internal view returns (bool) {
    return serviceTags[service].length > 0;
  }

  function _serviceTagExists(address service, string memory tag) internal view returns (bool) {
    for (uint256 i = 0; i < serviceTags[service].length; i++) {
      if (keccak256(abi.encode(tag)) == keccak256(abi.encode(serviceTags[service][i]))) {
        return true;
      }
    }
    return false;
  }

  function _getYearDayIsIn(uint256 day, uint256 startDay) internal pure returns (uint256) {
    return day.sub(startDay).div(366).add(1); // dividing by 366 makes day 1 and 365 be in year 1
  }

  function _getCurrentDay() internal view returns (uint256) {
    return block.timestamp.div(1 days).add(1);
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

