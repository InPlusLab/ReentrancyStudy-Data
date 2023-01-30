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

import './SafeMath.sol';
import './IERC20.sol';
import './sbControllerInterface.sol';
import './sbStrongPoolInterface.sol';
import './sbCommunityInterface.sol';

contract sbVotes {
  event VotesUpdated(address indexed voter, uint256 amount, bool indexed adding);
  event RewardsReceivedForCommunity(address indexed community, uint256 indexed day, uint256 amount);
  event RewardsReceivedForVoters(uint256 indexed day, uint256 amount);
  event Voted(address indexed voter, address community, address indexed service, uint256 amount, uint256 indexed day);
  event VoteRecalled(
    address indexed voter,
    address community,
    address indexed service,
    uint256 amount,
    uint256 indexed day
  );
  event ServiceDropped(address indexed voter, address community, address indexed service, uint256 indexed day);
  event Claimed(address indexed service, uint256 amount, uint256 indexed day);

  using SafeMath for uint256;

  bool internal initDone;

  sbControllerInterface internal sbController;
  sbStrongPoolInterface internal sbStrongPool;
  IERC20 internal strongToken;

  mapping(address => uint96) internal balances;
  mapping(address => address) public delegates;

  struct Checkpoint {
    uint32 fromBlock;
    uint96 votes;
  }
  mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;
  mapping(address => uint32) public numCheckpoints;

  event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
  event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
  event AddVotes(address indexed staker, uint256 amount);
  event SubVotes(address indexed staker, uint256 amount);

  mapping(address => mapping(address => address[])) internal voterCommunityServices;
  mapping(address => mapping(address => mapping(address => uint256[]))) internal voterCommunityServiceDays;
  mapping(address => mapping(address => mapping(address => uint256[]))) internal voterCommunityServiceAmounts;
  mapping(address => mapping(address => mapping(address => uint256[]))) internal voterCommunityServiceVoteSeconds;
  mapping(address => uint256) internal voterDayLastClaimedFor;
  mapping(address => uint256) internal voterVotesOut;
  mapping(uint256 => uint256) internal dayVoterRewards;

  mapping(address => mapping(address => uint256[])) internal serviceCommunityDays;
  mapping(address => mapping(address => uint256[])) internal serviceCommunityAmounts;
  mapping(address => mapping(address => uint256[])) internal serviceCommunityVoteSeconds;
  mapping(address => uint256) internal serviceDayLastClaimedFor;

  mapping(address => uint256[]) internal communityDays;
  mapping(address => uint256[]) internal communityAmounts;
  mapping(address => uint256[]) internal communityVoteSeconds;

  mapping(address => mapping(uint256 => uint256)) internal communityDayRewards;

  function init(
    address sbControllerAddress,
    address sbStrongPoolAddress,
    address strongTokenAddress
  ) public {
    require(!initDone, 'init done');
    sbController = sbControllerInterface(sbControllerAddress);
    sbStrongPool = sbStrongPoolInterface(sbStrongPoolAddress);
    strongToken = IERC20(strongTokenAddress);
    initDone = true;
  }

  function updateVotes(
    address voter,
    uint256 rawAmount,
    bool adding
  ) external {
    require(msg.sender == address(sbStrongPool), 'not sbStrongPool');
    uint96 amount = _safe96(rawAmount, 'amount exceeds 96 bits');
    if (adding) {
      _addVotes(voter, amount);
    } else {
      require(voter == delegates[voter], 'must delegate to self');
      require(_getAvailableServiceVotes(voter) >= amount, 'must recall votes');
      _subVotes(voter, amount);
    }
    emit VotesUpdated(voter, amount, adding);
  }

  function getCurrentProposalVotes(address account) external view returns (uint96) {
    return _getCurrentProposalVotes(account);
  }

  function getPriorProposalVotes(address account, uint256 blockNumber) external view returns (uint96) {
    require(blockNumber < block.number, 'not yet determined');
    uint32 nCheckpoints = numCheckpoints[account];
    if (nCheckpoints == 0) {
      return 0;
    }
    if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
      return checkpoints[account][nCheckpoints - 1].votes;
    }
    if (checkpoints[account][0].fromBlock > blockNumber) {
      return 0;
    }
    uint32 lower = 0;
    uint32 upper = nCheckpoints - 1;
    while (upper > lower) {
      uint32 center = upper - (upper - lower) / 2;
      Checkpoint memory cp = checkpoints[account][center];
      if (cp.fromBlock == blockNumber) {
        return cp.votes;
      } else if (cp.fromBlock < blockNumber) {
        lower = center;
      } else {
        upper = center - 1;
      }
    }
    return checkpoints[account][lower].votes;
  }

  function getCommunityData(address community, uint256 day)
    external
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    require(sbController.communityAccepted(community), 'invalid community');
    require(day <= _getCurrentDay(), 'invalid day');
    return _getCommunityData(community, day);
  }

  function receiveServiceRewards(uint256 day, uint256 amount) external {
    require(amount > 0, 'zero');
    require(sbController.communityAccepted(msg.sender), 'invalid community');
    strongToken.transferFrom(msg.sender, address(this), amount);
    communityDayRewards[msg.sender][day] = communityDayRewards[msg.sender][day].add(amount);
    emit RewardsReceivedForCommunity(msg.sender, day, amount);
  }

  function receiveVoterRewards(uint256 day, uint256 amount) external {
    require(amount > 0, 'zero');
    require(msg.sender == address(sbController), 'not sbController');
    strongToken.transferFrom(msg.sender, address(this), amount);
    dayVoterRewards[day] = dayVoterRewards[day].add(amount);
    emit RewardsReceivedForVoters(day, amount);
  }

  function getServiceDayLastClaimedFor(address service) public view returns (uint256) {
    return
      serviceDayLastClaimedFor[service] == 0 ? sbController.getStartDay().sub(1) : serviceDayLastClaimedFor[service];
  }

  function getVoterDayLastClaimedFor(address voter) public view returns (uint256) {
    return voterDayLastClaimedFor[voter] == 0 ? sbController.getStartDay().sub(1) : voterDayLastClaimedFor[voter];
  }

  function getSbControllerAddressUsed() public view returns (address) {
    return address(sbController);
  }

  function getSbStrongPoolAddressUsed() public view returns (address) {
    return address(sbStrongPool);
  }

  function getStrongAddressUsed() public view returns (address) {
    return address(strongToken);
  }

  function getCommunityDayRewards(address community, uint256 day) public view returns (uint256) {
    require(sbController.communityAccepted(community), 'invalid community');
    require(day <= _getCurrentDay(), 'invalid day');
    return communityDayRewards[community][day];
  }

  function getDayVoterRewards(uint256 day) public view returns (uint256) {
    require(day <= _getCurrentDay(), 'invalid day');
    return dayVoterRewards[day];
  }

  function recallAllVotes() public {
    require(voterVotesOut[msg.sender] > 0, 'no votes out');
    _recallAllVotes((msg.sender));
  }

  function delegate(address delegatee) public {
    address currentDelegate = delegates[msg.sender];
    if (currentDelegate != delegatee && voterVotesOut[currentDelegate] > 0) {
      _recallAllVotes(currentDelegate);
    }
    _delegate(msg.sender, delegatee);
  }

  function getDelegate(address delegator) public view returns (address) {
    return delegates[delegator];
  }

  function getAvailableServiceVotes(address account) public view returns (uint96) {
    return _getAvailableServiceVotes(account);
  }

  function getVoterCommunityServices(address voter, address community) public view returns (address[] memory) {
    require(sbController.communityAccepted(community), 'invalid community');
    return voterCommunityServices[voter][community];
  }

  function vote(
    address community,
    address service,
    uint256 amount
  ) public {
    require(amount > 0, '1: zero');
    require(sbController.communityAccepted(community), 'invalid community');
    require(100 - sbCommunityInterface(community).getMinerRewardPercentage() != 0, '2: zero.');
    require(sbCommunityInterface(community).serviceAccepted(service), 'invalid service');
    require(sbStrongPool.serviceMinMined(service), 'not min mined');
    require(voterCommunityServices[msg.sender][community].length < 10, 'limit met');
    require(uint256(_getAvailableServiceVotes(msg.sender)) >= amount, 'not enough votes');
    if (!_voterCommunityServiceExists(msg.sender, community, service)) {
      voterCommunityServices[msg.sender][community].push(service);
    }
    uint256 currentDay = _getCurrentDay();
    _updateVoterCommunityServiceData(msg.sender, community, service, amount, true, currentDay);
    _updateServiceCommunityData(service, community, amount, true, currentDay);
    _updateCommunityData(community, amount, true, currentDay);
    voterVotesOut[msg.sender] = voterVotesOut[msg.sender].add(amount);
    emit Voted(msg.sender, community, service, amount, currentDay);
  }

  function recallVote(
    address community,
    address service,
    uint256 amount
  ) public {
    require(amount > 0, 'zero');
    require(sbController.communityAccepted(community), 'invalid community');
    require(sbCommunityInterface(community).serviceAccepted(service), 'invalid service');
    require(_voterCommunityServiceExists(msg.sender, community, service), 'not found');
    uint256 currentDay = _getCurrentDay();
    (, uint256 votes, ) = _getVoterCommunityServiceData(msg.sender, community, service, currentDay);
    require(votes >= amount, 'not enough votes');
    _updateVoterCommunityServiceData(msg.sender, community, service, amount, false, currentDay);
    _updateServiceCommunityData(service, community, amount, false, currentDay);
    _updateCommunityData(community, amount, false, currentDay);
    voterVotesOut[msg.sender] = voterVotesOut[msg.sender].sub(amount);
    emit VoteRecalled(msg.sender, community, service, amount, currentDay);
  }

  function dropService(address community, address service) public {
    require(sbController.communityAccepted(community), 'invalid community');
    require(sbCommunityInterface(community).serviceAccepted(service), 'invalid service');
    require(_voterCommunityServiceExists(msg.sender, community, service), 'not found');
    uint256 currentDay = _getCurrentDay();
    (, uint256 votes, ) = _getVoterCommunityServiceData(msg.sender, community, service, currentDay);
    _updateVoterCommunityServiceData(msg.sender, community, service, votes, false, currentDay);
    _updateServiceCommunityData(service, community, votes, false, currentDay);
    _updateCommunityData(community, votes, false, currentDay);
    voterVotesOut[msg.sender] = voterVotesOut[msg.sender].sub(votes);
    uint256 index = _findIndexOfAddress(voterCommunityServices[msg.sender][community], service);
    _deleteArrayElement(index, voterCommunityServices[msg.sender][community]);
    emit ServiceDropped(msg.sender, community, service, currentDay);
  }

  function serviceClaimAll() public {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = serviceDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : serviceDayLastClaimedFor[msg.sender];
    require(currentDay > dayLastClaimedFor.add(7), 'already claimed');
    require(sbController.upToDate(), 'need rewards released');
    require(sbStrongPool.serviceMinMined(msg.sender), 'not min mined');
    _serviceClaim(currentDay, msg.sender, dayLastClaimedFor);
  }

  function serviceClaimUpTo(uint256 day) public {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = serviceDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : serviceDayLastClaimedFor[msg.sender];
    require(day > dayLastClaimedFor.add(7), 'already claimed');
    require(sbController.upToDate(), 'need rewards released');
    require(sbStrongPool.serviceMinMined(msg.sender), 'not min mined');
    _serviceClaim(day, msg.sender, dayLastClaimedFor);
  }

  function voterClaimAll() public {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = voterDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : voterDayLastClaimedFor[msg.sender];
    require(currentDay > dayLastClaimedFor.add(7), 'already claimed');
    require(sbController.upToDate(), 'need rewards released');
    _voterClaim(currentDay, msg.sender, dayLastClaimedFor);
  }

  function voterClaimUpTo(uint256 day) public {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = voterDayLastClaimedFor[msg.sender] == 0
      ? sbController.getStartDay().sub(1)
      : voterDayLastClaimedFor[msg.sender];
    require(day > dayLastClaimedFor.add(7), 'already claimed');
    require(sbController.upToDate(), 'need rewards released');
    _voterClaim(day, msg.sender, dayLastClaimedFor);
  }

  function getServiceRewardsDueAll(address service) public view returns (uint256) {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = serviceDayLastClaimedFor[service] == 0
      ? sbController.getStartDay().sub(1)
      : serviceDayLastClaimedFor[service];
    if (!(currentDay > dayLastClaimedFor.add(7))) {
      return 0;
    }
    require(sbController.upToDate(), 'need rewards released');
    return _getServiceRewardsDue(currentDay, service, dayLastClaimedFor);
  }

  function getServiceRewardsDueUpTo(uint256 day, address service) public view returns (uint256) {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = serviceDayLastClaimedFor[service] == 0
      ? sbController.getStartDay().sub(1)
      : serviceDayLastClaimedFor[service];
    if (!(day > dayLastClaimedFor.add(7))) {
      return 0;
    }
    require(sbController.upToDate(), 'need rewards released');
    return _getServiceRewardsDue(day, service, dayLastClaimedFor);
  }

  function getVoterRewardsDueAll(address voter) public view returns (uint256) {
    uint256 currentDay = _getCurrentDay();
    uint256 dayLastClaimedFor = voterDayLastClaimedFor[voter] == 0
      ? sbController.getStartDay().sub(1)
      : voterDayLastClaimedFor[voter];
    if (!(currentDay > dayLastClaimedFor.add(7))) {
      return 0;
    }
    require(sbController.upToDate(), 'need rewards released');
    return _getVoterRewardsDue(currentDay, voter, dayLastClaimedFor);
  }

  function getVoterRewardsDueUpTo(uint256 day, address voter) public view returns (uint256) {
    require(day <= _getCurrentDay(), 'invalid day');
    uint256 dayLastClaimedFor = voterDayLastClaimedFor[voter] == 0
      ? sbController.getStartDay().sub(1)
      : voterDayLastClaimedFor[voter];
    if (!(day > dayLastClaimedFor.add(7))) {
      return 0;
    }
    require(sbController.upToDate(), 'need rewards released');
    return _getVoterRewardsDue(day, voter, dayLastClaimedFor);
  }

  function getVoterCommunityServiceData(
    address voter,
    address community,
    address service,
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
    require(sbController.communityAccepted(community), 'invalid community');
    require(sbCommunityInterface(community).serviceAccepted(service), 'invalid service');
    if (!_voterCommunityServiceExists(voter, community, service)) {
      return (day, 0, 0);
    }
    require(day <= _getCurrentDay(), 'invalid day');
    return _getVoterCommunityServiceData(voter, community, service, day);
  }

  function getServiceCommunityData(
    address service,
    address community,
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
    require(sbController.communityAccepted(community), 'invalid community');
    require(sbCommunityInterface(community).serviceAccepted(service), 'invalid service');
    require(day <= _getCurrentDay(), 'invalid day');
    return _getServiceCommunityData(service, community, day);
  }

  function _getVoterCommunityServiceData(
    address voter,
    address community,
    address service,
    uint256 day
  )
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256[] memory _Days = voterCommunityServiceDays[voter][community][service];
    uint256[] memory _Amounts = voterCommunityServiceAmounts[voter][community][service];
    uint256[] memory _UnitSeconds = voterCommunityServiceVoteSeconds[voter][community][service];
    return _get(_Days, _Amounts, _UnitSeconds, day);
  }

  function _getServiceCommunityData(
    address service,
    address community,
    uint256 day
  )
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256[] memory _Days = serviceCommunityDays[service][community];
    uint256[] memory _Amounts = serviceCommunityAmounts[service][community];
    uint256[] memory _UnitSeconds = serviceCommunityVoteSeconds[service][community];
    return _get(_Days, _Amounts, _UnitSeconds, day);
  }

  function _getCommunityData(address community, uint256 day)
    internal
    view
    returns (
      uint256,
      uint256,
      uint256
    )
  {
    uint256[] memory _Days = communityDays[community];
    uint256[] memory _Amounts = communityAmounts[community];
    uint256[] memory _UnitSeconds = communityVoteSeconds[community];
    return _get(_Days, _Amounts, _UnitSeconds, day);
  }

  function _updateVoterCommunityServiceData(
    address voter,
    address community,
    address service,
    uint256 amount,
    bool adding,
    uint256 currentDay
  ) internal {
    uint256[] storage _Days = voterCommunityServiceDays[voter][community][service];
    uint256[] storage _Amounts = voterCommunityServiceAmounts[voter][community][service];
    uint256[] storage _UnitSeconds = voterCommunityServiceVoteSeconds[voter][community][service];
    _update(_Days, _Amounts, _UnitSeconds, amount, adding, currentDay);
  }

  function _updateServiceCommunityData(
    address service,
    address community,
    uint256 amount,
    bool adding,
    uint256 currentDay
  ) internal {
    uint256[] storage _Days = serviceCommunityDays[service][community];
    uint256[] storage _Amounts = serviceCommunityAmounts[service][community];
    uint256[] storage _UnitSeconds = serviceCommunityVoteSeconds[service][community];
    _update(_Days, _Amounts, _UnitSeconds, amount, adding, currentDay);
  }

  function _updateCommunityData(
    address community,
    uint256 amount,
    bool adding,
    uint256 currentDay
  ) internal {
    uint256[] storage _Days = communityDays[community];
    uint256[] storage _Amounts = communityAmounts[community];
    uint256[] storage _UnitSeconds = communityVoteSeconds[community];
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

  function _addVotes(address voter, uint96 amount) internal {
    require(voter != address(0), 'zero address');
    balances[voter] = _add96(balances[voter], amount, 'vote amount overflows');
    _addDelegates(voter, amount);
    emit AddVotes(voter, amount);
  }

  function _subVotes(address voter, uint96 amount) internal {
    balances[voter] = _sub96(balances[voter], amount, 'vote amount exceeds balance');
    _subtactDelegates(voter, amount);
    emit SubVotes(voter, amount);
  }

  function _addDelegates(address staker, uint96 amount) internal {
    if (delegates[staker] == address(0)) {
      delegates[staker] = staker;
    }
    address currentDelegate = delegates[staker];
    _moveDelegates(address(0), currentDelegate, amount);
  }

  function _subtactDelegates(address staker, uint96 amount) internal {
    address currentDelegate = delegates[staker];
    _moveDelegates(currentDelegate, address(0), amount);
  }

  function _delegate(address delegator, address delegatee) internal {
    address currentDelegate = delegates[delegator];
    uint96 delegatorBalance = balances[delegator];
    delegates[delegator] = delegatee;
    emit DelegateChanged(delegator, currentDelegate, delegatee);
    _moveDelegates(currentDelegate, delegatee, delegatorBalance);
  }

  function _moveDelegates(
    address srcRep,
    address dstRep,
    uint96 amount
  ) internal {
    if (srcRep != dstRep && amount > 0) {
      if (srcRep != address(0)) {
        uint32 srcRepNum = numCheckpoints[srcRep];
        uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
        uint96 srcRepNew = _sub96(srcRepOld, amount, 'vote amount underflows');
        _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
      }
      if (dstRep != address(0)) {
        uint32 dstRepNum = numCheckpoints[dstRep];
        uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
        uint96 dstRepNew = _add96(dstRepOld, amount, 'vote amount overflows');
        _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
      }
    }
  }

  function _writeCheckpoint(
    address delegatee,
    uint32 nCheckpoints,
    uint96 oldVotes,
    uint96 newVotes
  ) internal {
    uint32 blockNumber = _safe32(block.number, 'block number exceeds 32 bits');
    if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
      checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
    } else {
      checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
      numCheckpoints[delegatee] = nCheckpoints + 1;
    }

    emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
  }

  function _safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {
    require(n < 2**32, errorMessage);
    return uint32(n);
  }

  function _safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {
    require(n < 2**96, errorMessage);
    return uint96(n);
  }

  function _add96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {
    uint96 c = a + b;
    require(c >= a, errorMessage);
    return c;
  }

  function _sub96(
    uint96 a,
    uint96 b,
    string memory errorMessage
  ) internal pure returns (uint96) {
    require(b <= a, errorMessage);
    return a - b;
  }

  function _getCurrentProposalVotes(address account) internal view returns (uint96) {
    uint32 nCheckpoints = numCheckpoints[account];
    return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
  }

  function _getAvailableServiceVotes(address account) internal view returns (uint96) {
    uint96 proposalVotes = _getCurrentProposalVotes(account);
    return
      proposalVotes == 0
        ? 0
        : proposalVotes -
          _safe96(voterVotesOut[account], 'voterVotesOut exceeds 96 bits');
  }

  function _voterCommunityServiceExists(
    address voter,
    address community,
    address service
  ) internal view returns (bool) {
    for (uint256 i = 0; i < voterCommunityServices[voter][community].length; i++) {
      if (voterCommunityServices[voter][community][i] == service) {
        return true;
      }
    }
    return false;
  }

  function _recallAllVotes(address voter) internal {
    uint256 currentDay = _getCurrentDay();
    address[] memory communities = sbController.getCommunities();
    for (uint256 i = 0; i < communities.length; i++) {
      address community = communities[i];
      address[] memory services = voterCommunityServices[voter][community];
      for (uint256 j = 0; j < services.length; j++) {
        address service = services[j];
        (, uint256 amount, ) = _getVoterCommunityServiceData(voter, community, service, currentDay);
        _updateVoterCommunityServiceData(msg.sender, community, service, amount, false, currentDay);
        _updateServiceCommunityData(service, community, amount, false, currentDay);
        _updateCommunityData(community, amount, false, currentDay);
        voterVotesOut[msg.sender] = voterVotesOut[msg.sender].sub(amount);
      }
    }
  }

  function _serviceClaim(
    uint256 upToDay,
    address service,
    uint256 dayLastClaimedFor
  ) internal {
    uint256 rewards = _getServiceRewardsDue(upToDay, service, dayLastClaimedFor);
    require(rewards > 0, 'no rewards');
    serviceDayLastClaimedFor[service] = upToDay.sub(7);
    strongToken.approve(address(sbStrongPool), rewards);
    sbStrongPool.mineFor(service, rewards);
    emit Claimed(service, rewards, _getCurrentDay());
  }

  function _getServiceRewardsDue(
    uint256 upToDay,
    address service,
    uint256 dayLastClaimedFor
  ) internal view returns (uint256) {
    uint256 rewards;
    for (uint256 day = dayLastClaimedFor.add(1); day <= upToDay.sub(7); day++) {
      address[] memory communities = sbController.getCommunities();
      for (uint256 i = 0; i < communities.length; i++) {
        address community = communities[i];
        (, , uint256 communityVoteSecondsForDay) = _getCommunityData(community, day);
        if (communityVoteSecondsForDay == 0) {
          continue;
        }
        (, , uint256 serviceVoteSeconds) = _getServiceCommunityData(service, community, day);
        uint256 availableRewards = communityDayRewards[community][day];
        uint256 amount = availableRewards.mul(serviceVoteSeconds).div(communityVoteSecondsForDay);
        rewards = rewards.add(amount);
      }
    }
    return rewards;
  }

  function _voterClaim(
    uint256 upToDay,
    address voter,
    uint256 dayLastClaimedFor
  ) internal {
    uint256 rewards = _getVoterRewardsDue(upToDay, voter, dayLastClaimedFor);
    require(rewards > 0, 'no rewards');
    voterDayLastClaimedFor[voter] = upToDay.sub(7);
    strongToken.approve(address(sbStrongPool), rewards);
    sbStrongPool.mineFor(voter, rewards);
    emit Claimed(voter, rewards, _getCurrentDay());
  }

  function _getVoterRewardsDue(
    uint256 upToDay,
    address voter,
    uint256 dayLastClaimedFor
  ) internal view returns (uint256) {
    uint256 rewards;
    for (uint256 day = dayLastClaimedFor.add(1); day <= upToDay.sub(7); day++) {
      address[] memory communities = sbController.getCommunities();
      for (uint256 i = 0; i < communities.length; i++) {
        address community = communities[i];
        (, , uint256 communityVoteSecondsForDay) = _getCommunityData(community, day);
        if (communityVoteSecondsForDay == 0) {
          continue;
        }
        address[] memory services = voterCommunityServices[voter][community];
        uint256 voterCommunityVoteSeconds;
        for (uint256 j = 0; j < services.length; j++) {
          address service = services[j];
          (, , uint256 voterVoteSeconds) = _getVoterCommunityServiceData(voter, community, service, day);
          voterCommunityVoteSeconds = voterCommunityVoteSeconds.add(voterVoteSeconds);
        }
        uint256 availableRewards = dayVoterRewards[day];
        uint256 amount = availableRewards.mul(voterCommunityVoteSeconds).div(communityVoteSecondsForDay);
        rewards = rewards.add(amount);
      }
    }
    return rewards;
  }

  function _getCurrentDay() internal view returns (uint256) {
    return block.timestamp.div(1 days).add(1);
  }

  function _deleteArrayElement(uint256 index, address[] storage array) internal {
    if (index == array.length.sub(1)) {
      array.pop();
    } else {
      array[index] = array[array.length.sub(1)];
      delete array[array.length.sub(1)];
      array.pop();
    }
  }

  function _findIndexOfAddress(address[] memory array, address element) internal pure returns (uint256) {
    uint256 index;
    for (uint256 i = 0; i < array.length; i++) {
      if (array[i] == element) {
        index = i;
      }
    }
    return index;
  }
}

