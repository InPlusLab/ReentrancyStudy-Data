// SPDX-License-Identifier: MIT

pragma solidity >=0.4.25 <0.7.0;

/** OpenZeppelin Dependencies */
// import "@openzeppelin/contracts-upgradeable/contracts/proxy/Initializable.sol";
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol';
/** Uniswap */
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
/** Local Interfaces */
import './interfaces/IToken.sol';
import './interfaces/IAuction.sol';
import './interfaces/IStaking.sol';
import './interfaces/IAuctionV1.sol';

contract Auction is IAuction, Initializable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;

    event Bid(
        address indexed account,
        uint256 value,
        uint256 indexed auctionId,
        uint256 time
    );

    event VentureBid(
        address indexed account,
        uint256 ethBid,
        uint256 indexed auctionId,
        uint256 time,
        address[] coins,
        uint256[] amountBought
    );

    event Withdraval(
        address indexed account,
        uint256 value,
        uint256 indexed auctionId,
        uint256 time,
        uint256 stakeDays
    );

    event AuctionIsOver(uint256 eth, uint256 token, uint256 indexed auctionId);

    struct AuctionReserves {
        uint256 eth;
        uint256 token;
        uint256 uniswapLastPrice;
        uint256 uniswapMiddlePrice;
    }

    struct UserBid {
        uint256 eth;
        address ref;
        bool withdrawn;
    }

    struct Addresses {
        address mainToken;
        address staking;
        address payable uniswap;
        address payable recipient;
    }

    struct Options {
        uint256 autoStakeDays;
        uint256 referrerPercent;
        uint256 referredPercent;
        bool referralsOn;
        uint256 discountPercent;
        uint256 premiumPercent;
    }

    /** Roles */
    bytes32 public constant MIGRATOR_ROLE = keccak256('MIGRATOR_ROLE');
    bytes32 public constant MANAGER_ROLE = keccak256('MANAGER_ROLE');
    bytes32 public constant CALLER_ROLE = keccak256('CALLER_ROLE');

    /** Mapping */
    mapping(uint256 => AuctionReserves) public reservesOf;
    mapping(address => uint256[]) public auctionsOf;
    mapping(uint256 => mapping(address => UserBid)) public auctionBidOf;
    mapping(uint256 => mapping(address => bool)) public existAuctionsOf;

    /** Simple types */
    uint256 public lastAuctionEventId;
    uint256 public lastAuctionEventIdV1;
    uint256 public start;
    uint256 public stepTimestamp;

    Options public options;
    Addresses public addresses;
    IAuctionV1 public auctionV1;

    bool public init_;

    mapping(uint256 => mapping(address => uint256)) public autoStakeDaysOf; // NOT USED

    uint256 public middlePriceDays;

    struct VentureToken {
        // total bit 256
        address coin; // 160 bits
        uint96 percentage; // 96 bits
    }

    struct AuctionData {
        uint8 mode;
        VentureToken[] tokens;
    }

    AuctionData[7] internal auctions;
    uint8 internal ventureAutoStakeDays;

    /* New variables must go below here. */

    /** modifiers */
    modifier onlyCaller() {
        require(
            hasRole(CALLER_ROLE, _msgSender()),
            'Caller is not a caller role'
        );
        _;
    }

    modifier onlyManager() {
        require(
            hasRole(MANAGER_ROLE, _msgSender()),
            'Caller is not a manager role'
        );
        _;
    }

    modifier onlyMigrator() {
        require(
            hasRole(MIGRATOR_ROLE, _msgSender()),
            'Caller is not a migrator'
        );
        _;
    }

    function _updatePrice() internal {
        uint256 stepsFromStart = calculateStepsFromStart();

        reservesOf[stepsFromStart].uniswapLastPrice = getUniswapLastPrice();

        reservesOf[stepsFromStart]
            .uniswapMiddlePrice = getUniswapMiddlePriceForDays();
    }

    function _swapEthForToken(
        address tokenAddress,
        uint256 amountOutMin,
        uint256 amount,
        uint256 deadline
    ) private returns (uint256) {
        address[] memory path = new address[](2);

        path[0] = IUniswapV2Router02(addresses.uniswap).WETH();
        path[1] = tokenAddress;

        return
            IUniswapV2Router02(addresses.uniswap).swapExactETHForTokens{
                value: amount
            }(amountOutMin, path, addresses.staking, deadline)[1];
    }

    function bid(
        uint256[] calldata amountOutMin,
        uint256 deadline,
        address ref
    ) external payable {
        uint256 currentDay = getCurrentDay();
        uint8 auctionMode = auctions[currentDay].mode;

        if (auctionMode == 0) {
            bidInternal(amountOutMin[0], deadline, ref);
        } else if (auctionMode == 1) {
            ventureBid(amountOutMin, deadline, currentDay);
        }
    }

    function bidInternal(
        uint256 amountOutMin,
        uint256 deadline,
        address ref
    ) internal {
        _saveAuctionData();
        _updatePrice();

        require(_msgSender() != ref, 'msg.sender == ref');

        (uint256 toRecipient, uint256 toUniswap) =
            _calculateRecipientAndUniswapAmountsToSend();

        _swapEthForToken(
            addresses.mainToken,
            amountOutMin,
            toUniswap,
            deadline
        );

        uint256 stepsFromStart = calculateStepsFromStart();

        /** If referralsOn is true allow to set ref */
        if (options.referralsOn == true) {
            auctionBidOf[stepsFromStart][_msgSender()].ref = ref;
        }

        bidCommon(stepsFromStart);

        addresses.recipient.transfer(toRecipient);

        emit Bid(msg.sender, msg.value, stepsFromStart, now);
    }

    function ventureBid(
        uint256[] memory amountOutMin,
        uint256 deadline,
        uint256 currentDay
    ) internal {
        _saveAuctionData();
        _updatePrice();

        VentureToken[] storage tokens = auctions[currentDay].tokens;

        address[] memory coinsBought = new address[](tokens.length);
        uint256[] memory amountsBought = new uint256[](tokens.length);

        for (uint8 i = 0; i < tokens.length; i++) {
            uint256 amountBought;

            uint256 amountToBuy = msg.value.mul(tokens[i].percentage).div(100);

            if (
                tokens[i].coin !=
                address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF)
            ) {
                amountBought = _swapEthForToken(
                    tokens[i].coin,
                    amountOutMin[i],
                    amountToBuy,
                    deadline
                );

                IStaking(addresses.staking).updateTokenPricePerShare(
                    msg.sender,
                    addresses.recipient,
                    tokens[i].coin,
                    amountBought
                );
            } else {
                amountBought = amountToBuy;

                IStaking(addresses.staking).updateTokenPricePerShare{
                    value: amountToBuy
                }(msg.sender, addresses.recipient, tokens[i].coin, amountToBuy);
            }

            coinsBought[i] = tokens[i].coin;
            amountsBought[i] = amountBought;
        }

        uint256 stepsFromStart = calculateStepsFromStart();
        bidCommon(stepsFromStart);

        emit VentureBid(
            msg.sender,
            msg.value,
            stepsFromStart,
            now,
            coinsBought,
            amountsBought
        );
    }

    function bidCommon(uint256 stepsFromStart) internal {
        auctionBidOf[stepsFromStart][_msgSender()].eth = auctionBidOf[
            stepsFromStart
        ][_msgSender()]
            .eth
            .add(msg.value);

        if (!existAuctionsOf[stepsFromStart][_msgSender()]) {
            auctionsOf[_msgSender()].push(stepsFromStart);
            existAuctionsOf[stepsFromStart][_msgSender()] = true;
        }

        reservesOf[stepsFromStart].eth = reservesOf[stepsFromStart].eth.add(
            msg.value
        );
    }

    function getUniswapLastPrice() internal view returns (uint256) {
        address[] memory path = new address[](2);

        path[0] = IUniswapV2Router02(addresses.uniswap).WETH();
        path[1] = addresses.mainToken;

        uint256 price =
            IUniswapV2Router02(addresses.uniswap).getAmountsOut(1e18, path)[1];

        return price;
    }

    function getUniswapMiddlePriceForDays() internal view returns (uint256) {
        uint256 stepsFromStart = calculateStepsFromStart();

        uint256 index = stepsFromStart;
        uint256 sum;
        uint256 points;

        while (points != middlePriceDays) {
            if (reservesOf[index].uniswapLastPrice != 0) {
                sum = sum.add(reservesOf[index].uniswapLastPrice);
                points = points.add(1);
            }

            if (index == 0) break;

            index = index.sub(1);
        }

        if (sum == 0) return getUniswapLastPrice();
        else return sum.div(points);
    }

    function withdraw(uint256 auctionId, uint256 stakeDays) external {
        _saveAuctionData();
        _updatePrice();

        uint8 auctionMode = auctions[auctionId.mod(7)].mode;

        if (auctionMode == 0) {
            require(
                stakeDays >= options.autoStakeDays,
                'Auction: stakeDays < minimum days'
            );
        } else if (auctionMode == 1) {
            require(
                stakeDays >= ventureAutoStakeDays,
                'Auction: stakeDays < minimum days'
            );
        }

        require(stakeDays <= 5555, 'Auction: stakeDays > 5555');

        uint256 stepsFromStart = calculateStepsFromStart();

        UserBid storage userBid = auctionBidOf[auctionId][_msgSender()];

        require(stepsFromStart > auctionId, 'Auction: Auction is active');
        require(
            userBid.eth > 0 && userBid.withdrawn == false,
            'Auction: Zero bid or withdrawn'
        );

        userBid.withdrawn = true;

        withdrawInternal(
            userBid.ref,
            userBid.eth,
            auctionId,
            stepsFromStart,
            stakeDays
        );
    }

    function withdrawV1(uint256 auctionId, uint256 stakeDays) external {
        _saveAuctionData();
        _updatePrice();

        // CHECK LAST ID HERE
        require(
            auctionId <= lastAuctionEventIdV1,
            'Auction: Invalid auction id'
        );

        require(
            stakeDays >= options.autoStakeDays,
            'Auction: stakeDays < minimum days'
        );
        require(stakeDays <= 5555, 'Auction: stakeDays > 5555');

        uint256 stepsFromStart = calculateStepsFromStart();
        require(stepsFromStart > auctionId, 'Auction: Auction is active');

        /** This stops a user from using WithdrawV1 twice, since the bid is put into memory at the end */
        UserBid storage userBid = auctionBidOf[auctionId][_msgSender()];
        require(
            userBid.eth == 0 && userBid.withdrawn == false,
            'Auction: Invalid auction ID'
        );

        (uint256 eth, address ref) =
            auctionV1.auctionBetOf(auctionId, _msgSender());
        require(eth > 0, 'Auction: Zero balance in auction/invalid auction ID');

        withdrawInternal(ref, eth, auctionId, stepsFromStart, stakeDays);

        auctionBidOf[auctionId][_msgSender()] = UserBid({
            eth: eth,
            ref: ref,
            withdrawn: true
        });

        auctionsOf[_msgSender()].push(auctionId);
    }

    function withdrawInternal(
        address ref,
        uint256 eth,
        uint256 auctionId,
        uint256 stepsFromStart,
        uint256 stakeDays
    ) internal {
        uint256 payout = _calculatePayout(auctionId, eth);

        uint256 uniswapPayoutWithPercent =
            _calculatePayoutWithUniswap(auctionId, eth, payout);

        if (payout > uniswapPayoutWithPercent) {
            uint256 nextWeeklyAuction = calculateNearestWeeklyAuction();

            reservesOf[nextWeeklyAuction].token = reservesOf[nextWeeklyAuction]
                .token
                .add(payout.sub(uniswapPayoutWithPercent));

            payout = uniswapPayoutWithPercent;
        }

        if (address(ref) == address(0)) {
            IToken(addresses.mainToken).burn(address(this), payout);

            IStaking(addresses.staking).externalStake(
                payout,
                stakeDays,
                _msgSender()
            );

            emit Withdraval(msg.sender, payout, stepsFromStart, now, stakeDays);
        } else {
            IToken(addresses.mainToken).burn(address(this), payout);

            (uint256 toRefMintAmount, uint256 toUserMintAmount) =
                _calculateRefAndUserAmountsToMint(payout);

            payout = payout.add(toUserMintAmount);

            IStaking(addresses.staking).externalStake(
                payout,
                stakeDays,
                _msgSender()
            );

            emit Withdraval(msg.sender, payout, stepsFromStart, now, stakeDays);

            IStaking(addresses.staking).externalStake(toRefMintAmount, 14, ref);
        }
    }

    /** External Contract Caller functions */
    function callIncomeDailyTokensTrigger(uint256 amount)
        external
        override
        onlyCaller
    {
        // Adds a specified amount of axion to tomorrows auction
        uint256 stepsFromStart = calculateStepsFromStart();
        uint256 nextAuctionId = stepsFromStart + 1;

        reservesOf[nextAuctionId].token = reservesOf[nextAuctionId].token.add(
            amount
        );
    }

    function addReservesToAuction(uint256 daysInFuture, uint256 amount)
        external
        override
        onlyCaller
        returns (uint256)
    {
        // Adds a specified amount of axion to a future auction
        require(
            daysInFuture <= 365,
            'AUCTION: Days in future can not be greater then 365'
        );

        uint256 stepsFromStart = calculateStepsFromStart();
        uint256 auctionId = stepsFromStart + daysInFuture;

        reservesOf[auctionId].token = reservesOf[auctionId].token.add(amount);

        return auctionId;
    }

    function callIncomeWeeklyTokensTrigger(uint256 amount)
        external
        override
        onlyCaller
    {
        // Adds a specified amount of axion to the next nearest weekly auction
        uint256 nearestWeeklyAuction = calculateNearestWeeklyAuction();

        reservesOf[nearestWeeklyAuction].token = reservesOf[
            nearestWeeklyAuction
        ]
            .token
            .add(amount);
    }

    /** Calculate functions */
    function calculateNearestWeeklyAuction() public view returns (uint256) {
        uint256 stepsFromStart = calculateStepsFromStart();
        return stepsFromStart.add(uint256(7).sub(stepsFromStart.mod(7)));
    }

    /**
     * @dev
     * friday = 0, saturday = 1, sunday = 2 etc...
     */
    function getCurrentDay() internal view returns (uint256) {
        uint256 stepsFromStart = calculateStepsFromStart();
        return stepsFromStart.mod(7);
    }

    function calculateStepsFromStart() public view returns (uint256) {
        return now.sub(start).div(stepTimestamp);
    }

    function _calculatePayoutWithUniswap(
        uint256 auctionId,
        uint256 amount,
        uint256 payout
    ) internal view returns (uint256) {
        uint256 uniswapPayout =
            reservesOf[auctionId].uniswapMiddlePrice.mul(amount).div(1e18);

        uint256 uniswapPayoutWithPercent =
            uniswapPayout
                .add(uniswapPayout.mul(options.discountPercent).div(100))
                .sub(uniswapPayout.mul(options.premiumPercent).div(100));

        if (payout > uniswapPayoutWithPercent) {
            return uniswapPayoutWithPercent;
        } else {
            return payout;
        }
    }

    function _calculatePayout(uint256 auctionId, uint256 amount)
        internal
        view
        returns (uint256)
    {
        return
            amount.mul(reservesOf[auctionId].token).div(
                reservesOf[auctionId].eth
            );
    }

    function _calculateRecipientAndUniswapAmountsToSend()
        private
        returns (uint256, uint256)
    {
        uint256 toRecipient = msg.value.mul(20).div(100);
        uint256 toUniswap = msg.value.sub(toRecipient);

        return (toRecipient, toUniswap);
    }

    function _calculateRefAndUserAmountsToMint(uint256 amount)
        private
        view
        returns (uint256, uint256)
    {
        uint256 toRefMintAmount = amount.mul(options.referrerPercent).div(100);
        uint256 toUserMintAmount = amount.mul(options.referredPercent).div(100);

        return (toRefMintAmount, toUserMintAmount);
    }

    /** Storage Functions */
    function _saveAuctionData() internal {
        uint256 stepsFromStart = calculateStepsFromStart();
        AuctionReserves memory reserves = reservesOf[lastAuctionEventId];

        if (lastAuctionEventId < stepsFromStart) {
            emit AuctionIsOver(
                reserves.eth,
                reserves.token,
                lastAuctionEventId
            );
            lastAuctionEventId = stepsFromStart;
        }
    }

    function initialize(address _manager, address _migrator)
        public
        initializer
    {
        _setupRole(MANAGER_ROLE, _manager);
        _setupRole(MIGRATOR_ROLE, _migrator);
        init_ = false;
    }

    /** Public Setter Functions */
    function setReferrerPercentage(uint256 percent) external onlyManager {
        options.referrerPercent = percent;
    }

    function setReferredPercentage(uint256 percent) external onlyManager {
        options.referredPercent = percent;
    }

    function setReferralsOn(bool _referralsOn) external onlyManager {
        options.referralsOn = _referralsOn;
    }

    function setAutoStakeDays(uint256 _autoStakeDays) external onlyManager {
        options.autoStakeDays = _autoStakeDays;
    }

    function setVentureAutoStakeDays(uint8 _autoStakeDays)
        external
        onlyManager
    {
        ventureAutoStakeDays = _autoStakeDays;
    }

    function setDiscountPercent(uint256 percent) external onlyManager {
        options.discountPercent = percent;
    }

    function setPremiumPercent(uint256 percent) external onlyManager {
        options.premiumPercent = percent;
    }

    function setMiddlePriceDays(uint256 _middleDays) external onlyManager {
        middlePriceDays = _middleDays;
    }

    /** Roles management - only for multi sig address */
    function setupRole(bytes32 role, address account) external onlyManager {
        _setupRole(role, account);
    }

    function setAuctionMode(uint8 _day, uint8 _mode) external onlyManager {
        auctions[_day].mode = _mode;
    }

    function setTokensOfDay(
        uint8 day,
        address[] calldata coins,
        uint8[] calldata percentages
    ) external onlyManager {
        AuctionData storage auction = auctions[day];

        auction.mode = 1;

        delete auction.tokens;

        uint8 percent = 0;
        for (uint8 i; i < coins.length; i++) {
            auction.tokens.push(VentureToken(coins[i], percentages[i]));

            percent = percentages[i] + percent;

            IStaking(addresses.staking).addDivToken(coins[i]);
        }

        require(
            percent == 100,
            'AUCTION: Percentage for venture day must equal 100'
        );
    }

    /** Getter functions */
    function auctionsOf_(address account)
        external
        view
        returns (uint256[] memory)
    {
        return auctionsOf[account];
    }

    function getAuctionModes() external view returns (uint8[7] memory) {
        uint8[7] memory auctionModes;

        for (uint8 i; i < auctions.length; i++) {
            auctionModes[i] = auctions[i].mode;
        }

        return auctionModes;
    }

    function getTokensOfDay(uint8 _day)
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        VentureToken[] memory ventureTokens = auctions[_day].tokens;

        address[] memory tokens = new address[](ventureTokens.length);
        uint256[] memory percentages = new uint256[](ventureTokens.length);

        for (uint8 i; i < ventureTokens.length; i++) {
            tokens[i] = ventureTokens[i].coin;
            percentages[i] = ventureTokens[i].percentage;
        }

        return (tokens, percentages);
    }

    function getVentureAutoStakeDays() external view returns (uint8) {
        return ventureAutoStakeDays;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/EnumerableSetUpgradeable.sol";
import "../utils/AddressUpgradeable.sol";
import "../GSN/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
library SafeMathUpgradeable {
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IToken {
    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IAuction {
    function callIncomeDailyTokensTrigger(uint256 amount) external;

    function callIncomeWeeklyTokensTrigger(uint256 amount) external;

    function addReservesToAuction(uint256 daysInFuture, uint256 amount) external returns(uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IStaking {
    function externalStake(
        uint256 amount,
        uint256 stakingDays,
        address staker
    ) external;

    function updateTokenPricePerShare(
        address payable bidderAddress,
        address payable originAddress,
        address tokenAddress,
        uint256 amountBought
    ) external payable;

    function addDivToken(address tokenAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface IAuctionV1 {
    function auctionBetOf(uint256, address) 
        external returns (uint256, address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}