/**
 *Submitted for verification at Etherscan.io on 2021-09-10
*/

// SPDX-License-Identifier: -- 🎲 --

pragma solidity > 0.6.1 < 0.7.0;
pragma experimental ABIEncoderV2;

interface IApeBetPool {
    function depositUserETH() external payable;

    function depositETH(address _sender, uint256 amount) external payable;

    function depositBetToken(address _sender, uint256 amount) external;

    function sendRewards(address payable account, uint256 amount) external;
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract ApeBetBookMaker is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct SportEvent {
        bytes16 event_id;
        uint256 event_status;
        uint256 winner;
        string name_home;
        string name_away;
        uint256 score_home;
        uint256 score_away;
        int256 moneyline_home;
        int256 moneyline_away;
        int256 moneyline_draw;
        string event_date;
    }

    struct Bet {
        bytes16 eventInfo;
        uint256 bet_winner;
        int256 bet_moneyline;
        uint256 bet_amount;
        uint256 bet_reserved;
        uint256 bet_payout;
        uint256 bet_timestamp;
        bool bet_claimed;
    }

    IApeBetPool private betPool;
    address payable public betPoolAddress;
    uint256 public affiliate_id;
    uint256 public maxPoolPayout;

    mapping(bytes16 => mapping(uint256 => SportEvent)) public events;
    bytes16[] public availableEvents;

    mapping(bytes16 => Bet) public idToBet;
    mapping(bytes16 => mapping(uint256 => mapping(address => bytes16[])))
        public bets;
    mapping(bytes16 => mapping(uint256 => address[])) private bet_addresses;
    mapping(bytes16 => mapping(uint256 => mapping(address => bool))) private bet_addresses_claimed;
    mapping(address => bytes16[]) public userBetData;
    mapping(bytes16 => mapping(uint256 => mapping(uint256 => uint256))) public teamReserved;

    modifier onlyPoolOwner() {
        require(msg.sender == betPoolAddress, "You have no permission");
        _;
    }

    modifier betsValidation(
        bytes16[] memory _bet_event_ids,
        uint256[] memory winners,
        uint256[] memory amounts
    ) {
        // Check if pool has enough eth to give payouts to users
        uint256 maxPayout = 0;
        for (uint256 i = 0; i < _bet_event_ids.length; i++) {
            maxPayout = maxPayout
                .add(getPayoutEst(_bet_event_ids[i], winners[i], amounts[i]))
                .sub(amounts[i]);

            require(
                events[_bet_event_ids[i]][affiliate_id].event_status == 1,
                "Event is not available."
            );
        }
        require(maxPayout < maxPoolPayout, "Not enough eth to payout your bet");
        _;
    }

    constructor() public {
        affiliate_id = 0;
        maxPoolPayout = 0;
    }

    function changeAffiliate(uint256 _affiliate_id) external onlyOwner {
        affiliate_id = _affiliate_id;
    }

    function getBetId(bytes16 _event_id, address _account)
        internal
        view
        returns (bytes16 betId)
    {
        betId = bytes16(
            keccak256(
                abi.encodePacked(
                    _event_id,
                    affiliate_id,
                    _account,
                    block.timestamp
                )
            )
        );
    }

    function changeBetPool(address payable _betPoolAddress) external onlyOwner {
        betPool = IApeBetPool(_betPoolAddress);
        betPoolAddress = _betPoolAddress;
        maxPoolPayout = address(betPool).balance;
    }

    function getUserBetHistory(address user)
        external
        view
        returns (Bet[] memory userBets, SportEvent[] memory userEvents)
    {
        userBets = new Bet[](userBetData[user].length);
        userEvents = new SportEvent[](userBetData[user].length);
        for (uint256 i = 0; i < userBetData[user].length; i++) {
            userBets[i] = idToBet[userBetData[user][i]];
            userEvents[i] = events[userBets[i].eventInfo][affiliate_id];
        }
        return (userBets, userEvents);
    }

    function getCollectableRewards(address user)
        external
        view
        returns (uint256 totalPayouts)
    {
        totalPayouts = 0;
        for (uint256 i = 0; i < userBetData[user].length; i++) {
            Bet storage bet = idToBet[userBetData[user][i]];
            SportEvent memory ev = events[bet.eventInfo][affiliate_id];

            if (
                ev.event_status == 2 &&
                ev.winner == bet.bet_winner &&
                bet.bet_claimed == false
            ) {
                totalPayouts = totalPayouts.add(
                    bet
                        .bet_amount
                        .mul(convertOddsFormat(bet.bet_moneyline))
                        .div(1e4)
                );
            }
        }
        return totalPayouts;
    }

    function collectRewards() external {
        uint256 totalPayouts = 0;
        for (uint256 i = 0; i < userBetData[msg.sender].length; i++) {
            Bet storage bet = idToBet[userBetData[msg.sender][i]];
            if (
                events[bet.eventInfo][affiliate_id].event_status == 2 &&
                events[bet.eventInfo][affiliate_id].winner == bet.bet_winner
            ) {
                bet.bet_payout = bet
                    .bet_amount
                    .mul(convertOddsFormat(bet.bet_moneyline))
                    .div(1e4);
                bet.bet_claimed = true;
                totalPayouts = totalPayouts.add(bet.bet_payout);
            }
        }

        betPool.sendRewards(msg.sender, totalPayouts);
    }

    // This function is used for converting only American format to European format
    function convertOddsFormat(int256 odds) internal pure returns (uint256) {
        uint256 payout = 0;
        uint256 bet = 0;
        if (odds < 0) {
            payout = uint256(100 - odds);
            bet = uint256(-odds);
        } else {
            payout = uint256(100 + odds);
            bet = 100;
        }

        return payout.mul(1e4).div(bet);
    }

    // for temporary use till chainlink is available to use
    function updateEvents(
        bytes16[] memory _event_ids,
        uint256[] memory _event_statuss,
        uint256[] memory _winners,
        string[] memory _name_homes,
        string[] memory _name_aways,
        uint256[] memory _score_aways,
        uint256[] memory _score_homes,
        int256[] memory _moneyline_homes,
        int256[] memory _moneyline_aways,
        int256[] memory _moneyline_draws,
        string[] memory _dates
    ) external {
        for (uint256 i = 0; i < _event_ids.length; i++) {
            if (events[_event_ids[i]][affiliate_id].event_status == 0) {
                availableEvents.push(_event_ids[i]);
            }
            
            if (events[_event_ids[i]][affiliate_id].event_status == 2) continue;
            
            if (events[_event_ids[i]][affiliate_id].event_status == _event_statuss[i]) {
                events[_event_ids[i]][affiliate_id].moneyline_home = _moneyline_homes[i];
                events[_event_ids[i]][affiliate_id].moneyline_away = _moneyline_aways[i];
            } else {
                events[_event_ids[i]][affiliate_id] = SportEvent({
                    event_id: _event_ids[i],
                    event_status: _event_statuss[i],
                    winner: _winners[i],
                    name_away: _name_aways[i],
                    name_home: _name_homes[i],
                    score_away: _score_aways[i],
                    score_home: _score_homes[i],
                    moneyline_home: _moneyline_homes[i],
                    moneyline_away: _moneyline_aways[i],
                    moneyline_draw: _moneyline_draws[i],
                    event_date: _dates[i]
                });   
            }

            if (events[_event_ids[i]][affiliate_id].event_status == 2) {
                bytes16 event_id = _event_ids[i];
                uint256 paidForEvt = 0;
                for (
                    uint256 j = 0;
                    j < bet_addresses[event_id][affiliate_id].length;
                    j++
                ) {
                    address account = bet_addresses[event_id][affiliate_id][j];
                    for (
                        uint256 k = 0;
                        k < bets[event_id][affiliate_id][account].length;
                        k++
                    ) {
                        if (
                            idToBet[bets[event_id][affiliate_id][account][k]].bet_winner != events[event_id][affiliate_id].winner
                        ) {
                            maxPoolPayout = maxPoolPayout.add(
                                idToBet[
                                    bets[event_id][affiliate_id][account][k]
                                ]
                                    .bet_amount
                            );
                        } else {
                            paidForEvt = paidForEvt.add(idToBet[bets[event_id][affiliate_id][account][k]].bet_reserved.sub(idToBet[bets[event_id][affiliate_id][account][k]].bet_amount));
                        }
                    }
                }
                if (teamReserved[event_id][affiliate_id][1] > teamReserved[event_id][affiliate_id][2]) {
                    maxPoolPayout = maxPoolPayout.add(teamReserved[event_id][affiliate_id][1].sub(paidForEvt));
                } else {
                    maxPoolPayout = maxPoolPayout.add(teamReserved[event_id][affiliate_id][2].sub(paidForEvt));
                }
            }
        }
    }

    function getAvailableEvents()
        external
        view
        returns (SportEvent[] memory evts)
    {
        evts = new SportEvent[](availableEvents.length);
        uint256 idx = 0;
        for (uint256 i = 0; i < availableEvents.length; i++) {
            if (events[availableEvents[i]][affiliate_id].event_status == 1)
                evts[idx++] = events[availableEvents[i]][affiliate_id];
        }
        return evts;
    }

    function getPayoutEst(
        bytes16 _bet_event_id,
        uint256 winner,
        uint256 amount
    ) public view returns (uint256) {
        uint256 maxPayout;

        // winner: 1 (home),  winner: 2(away),   winner: 3(draw)

        SportEvent memory ev = events[_bet_event_id][affiliate_id];
        if (winner == 1) {
            maxPayout = convertOddsFormat(ev.moneyline_home).mul(amount).div(
                1e4
            );
        } else if (winner == 2) {
            maxPayout = convertOddsFormat(ev.moneyline_away).mul(amount).div(
                1e4
            );
        } else {
            maxPayout = convertOddsFormat(ev.moneyline_draw).mul(amount).div(
                1e4
            );
        }
        return maxPayout;
    }

    receive() external payable {}

    function updateMaxPoolPayout(uint256 addAmount, uint256 removeAmount)
        external
        onlyPoolOwner
    {
        if (addAmount > 0) maxPoolPayout = maxPoolPayout.add(addAmount);
        else maxPoolPayout = maxPoolPayout.sub(removeAmount);
    }

    function createBets(
        bytes16[] memory _bet_event_ids,
        uint256[] memory _bet_winners,
        uint256[] memory _bet_amounts
    )
        external
        payable
        nonReentrant
        betsValidation(_bet_event_ids, _bet_winners, _bet_amounts)
    {
        for (uint256 i = 0; i < _bet_event_ids.length; i++) {
            bytes16 bet_id = getBetId(_bet_event_ids[i], msg.sender);
            uint256 estPayout =
                getPayoutEst(
                    _bet_event_ids[i],
                    _bet_winners[i],
                    _bet_amounts[i]
                );
            bets[_bet_event_ids[i]][affiliate_id][msg.sender].push(bet_id);

            idToBet[bet_id] = Bet({
                eventInfo: _bet_event_ids[i],
                bet_winner: _bet_winners[i],
                bet_amount: _bet_amounts[i],
                bet_timestamp: block.timestamp,
                bet_moneyline: _bet_winners[i] == 1
                    ? events[_bet_event_ids[i]][affiliate_id].moneyline_home
                    : events[_bet_event_ids[i]][affiliate_id].moneyline_away,
                bet_payout: 0,
                bet_reserved: estPayout,
                bet_claimed: false
            });

            if (bet_addresses_claimed[_bet_event_ids[i]][affiliate_id][msg.sender] != true) {
                bet_addresses[_bet_event_ids[i]][affiliate_id].push(msg.sender);
                bet_addresses_claimed[_bet_event_ids[i]][affiliate_id][msg.sender] = true;
            }

            userBetData[msg.sender].push(bet_id);

            uint256 reservedAmount = estPayout.sub(_bet_amounts[i]);
            if (teamReserved[_bet_event_ids[i]][affiliate_id][1] > teamReserved[_bet_event_ids[i]][affiliate_id][2])
                maxPoolPayout = maxPoolPayout.add(teamReserved[_bet_event_ids[i]][affiliate_id][1]);
            else
                maxPoolPayout = maxPoolPayout.add(teamReserved[_bet_event_ids[i]][affiliate_id][2]);
            
            teamReserved[_bet_event_ids[i]][affiliate_id][_bet_winners[i]] = teamReserved[_bet_event_ids[i]][affiliate_id][_bet_winners[i]].add(reservedAmount);

            if (teamReserved[_bet_event_ids[i]][affiliate_id][1] > teamReserved[_bet_event_ids[i]][affiliate_id][2])
                maxPoolPayout = maxPoolPayout.sub(teamReserved[_bet_event_ids[i]][affiliate_id][1]);
            else
                maxPoolPayout = maxPoolPayout.sub(teamReserved[_bet_event_ids[i]][affiliate_id][2]);
            require(maxPoolPayout >= 0, "Exceeded reserved amount.");
        }

        betPool.depositUserETH{value: msg.value}();
    }
}