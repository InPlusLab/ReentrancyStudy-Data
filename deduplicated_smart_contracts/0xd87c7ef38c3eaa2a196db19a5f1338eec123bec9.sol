pragma solidity >=0.4.21 <0.6.0;

import "./SafeMath.sol";
import "./Earnings.sol";
import "./TeamRewards.sol";
import "./Terminator.sol";
import "./Recommend.sol";

import "./ResonanceF.sol";

contract Resonance is ResonanceF {
    using SafeMath for uint256;

    uint256     public totalSupply = 0;
    uint256     constant internal bonusPrice = 0.0000001 ether; // init price
    uint256     constant internal priceIncremental = 0.00000001 ether; // increase price
    uint256     constant internal magnitude = 2 ** 64;
    uint256     public perBonusDivide = 0; //per Profit divide
    uint256     public  systemRetain = 0;
    uint256     public terminatorPoolAmount; //terminator award Pool Amount
    uint256     public activateSystem = 20;
    uint256     public activateGlobal = 20;

    mapping(address => User) public userInfo; // user define all user's information
    mapping(address => address[]) public straightInviteAddress; // user  effective straight invite address, sort reward
    mapping(address => int256) internal payoutsTo; // record
    mapping(address => uint256[11]) public userSubordinateCount;
    mapping(address => uint256) public whitelistPerformance;
    mapping(address => UserReinvest) public userReinvest;
    mapping(address => uint256) public lastStraightLength;

    uint8   constant internal remain = 20;       // Static and dynamic rewards returns remain at 20 percent
    uint32  constant internal ratio = 1000;      // eth to erc20 token ratio
    uint32  constant internal blockNumber = 40000; // straight sort reward block number
    uint256 public   currentBlockNumber;
    uint256 public   straightSortRewards = 0;
    uint256  public initAddressAmount = 0;   // The first 100 addresses and enough to 1 eth, 100 -500 enough to 5 eth, 500 addresses later cancel limit
    uint256 public totalEthAmount = 0; // all user total buy eth amount
    uint8 constant public percent = 100;

    address  public eggAddress = address(0x12d4fEcccc3cbD5F7A2C9b88D709317e0E616691);   // total eth 1 percent to  egg address
    address  public systemAddress = address(0x6074510054e37D921882B05Ab40537Ce3887F3AD);
    address  public nodeAddressReward = address(0xB351d5030603E8e89e1925f6d6F50CDa4D6754A6);
    address  public globalAddressReward = address(0x49eec1928b457d1f26a2466c8bd9eC1318EcB68f);
    address [10] public straightSort; // straight reward

    Earnings internal earningsInstance;
    TeamRewards internal teamRewardInstance;
    Terminator internal terminatorInstance;
    Recommend internal recommendInstance;

    struct User {
        address userAddress;  // user address
        uint256 ethAmount;    // user buy eth amount
        uint256 profitAmount; // user profit amount
        uint256 tokenAmount;  // user get token amount
        uint256 tokenProfit;  // profit by profitAmount
        uint256 straightEth;  // user straight eth
        uint256 lockStraight;
        uint256 teamEth;      // team eth reward
        bool staticTimeout;      // static timeout, 3 days
        uint256 staticTime;     // record static out time
        uint8 level;        // user team level
        address straightAddress;
        uint256 refeTopAmount; // subordinate address topmost eth amount
        address refeTopAddress; // subordinate address topmost eth address
    }

    struct UserReinvest {
//        uint256 nodeReinvest;
        uint256 staticReinvest;
        bool    isPush;
    }

    uint8[7] internal rewardRatio;  // [0] means market support rewards         10%
    // [1] means static rewards                 30%
    // [2] means straight rewards               30%
    // [3] means team rewards                   29%
    // [4] means terminator rewards             5%
    // [5] means straight sort rewards          5%
    // [6] means egg rewards                    1%

    uint8[11] internal teamRatio; // team reward ratio

    modifier mustAdmin (address adminAddress){
        require(adminAddress != address(0));
        require(adminAddress == admin[0] || adminAddress == admin[1] || adminAddress == admin[2] || adminAddress == admin[3] || adminAddress == admin[4]);
        _;
    }

    modifier mustReferralAddress (address referralAddress) {
        require(msg.sender != admin[0] || msg.sender != admin[1] || msg.sender != admin[2] || msg.sender != admin[3] || msg.sender != admin[4]);
        if (teamRewardInstance.isWhitelistAddress(msg.sender)) {
            require(referralAddress == admin[0] || referralAddress == admin[1] || referralAddress == admin[2] || referralAddress == admin[3] || referralAddress == admin[4]);
        }
        _;
    }

    modifier limitInvestmentCondition(uint256 ethAmount){
         if (initAddressAmount <= 50) {
            require(ethAmount <= 5 ether);
            _;
        } else {
            _;
        }
    }

    modifier limitAddressReinvest() {
        if (initAddressAmount <= 50 && userInfo[msg.sender].ethAmount > 0) {
            require(msg.value <= userInfo[msg.sender].ethAmount.mul(3));
        }
        _;
    }
    // -------------------- modifier ------------------------ //

    // --------------------- event -------------------------- //
    event WithdrawStaticProfits(address indexed user, uint256 ethAmount);
    event Buy(address indexed user, uint256 ethAmount, uint256 buyTime);
    event Withdraw(address indexed user, uint256 ethAmount, uint8 indexed value, uint256 buyTime);
    event Reinvest(address indexed user, uint256 indexed ethAmount, uint8 indexed value, uint256 buyTime);
    event SupportSubordinateAddress(uint256 indexed index, address indexed subordinate, address indexed refeAddress, bool supported);
    // --------------------- event -------------------------- //

    constructor(
        address _erc20Address,
        address _earningsAddress,
        address _teamRewardsAddress,
        address _terminatorAddress,
        address _recommendAddress
    )
    public
    {
        earningsInstance = Earnings(_earningsAddress);
        teamRewardInstance = TeamRewards(_teamRewardsAddress);
        terminatorInstance = Terminator(_terminatorAddress);
        kocInstance = KOCToken(_erc20Address);
        recommendInstance = Recommend(_recommendAddress);
        rewardRatio = [10, 30, 30, 29, 5, 5, 1];
        teamRatio = [6, 5, 4, 3, 3, 2, 2, 1, 1, 1, 1];
        currentBlockNumber = block.number;
    }

    // -------------------- user api ----------------//
    function buy(address referralAddress)
    public
    mustReferralAddress(referralAddress)
    limitInvestmentCondition(msg.value)
    payable
    {
        require(!teamRewardInstance.getWhitelistTime());
        uint256 ethAmount = msg.value;
        address userAddress = msg.sender;
        User storage _user = userInfo[userAddress];

        _user.userAddress = userAddress;

        if (_user.ethAmount == 0 && !teamRewardInstance.isWhitelistAddress(userAddress)) {
            teamRewardInstance.referralPeople(userAddress, referralAddress);
            _user.straightAddress = referralAddress;
        } else {
            referralAddress == teamRewardInstance.getUserreferralAddress(userAddress);
        }

        address straightAddress;
        address whiteAddress;
        address adminAddress;
        bool whitelist;
        (straightAddress, whiteAddress, adminAddress, whitelist) = teamRewardInstance.getUserSystemInfo(userAddress);
        require(adminAddress == admin[0] || adminAddress == admin[1] || adminAddress == admin[2] || adminAddress == admin[3] || adminAddress == admin[4]);

        if (userInfo[referralAddress].userAddress == address(0)) {
            userInfo[referralAddress].userAddress = referralAddress;
        }

        if (userInfo[userAddress].straightAddress == address(0)) {
            userInfo[userAddress].straightAddress = straightAddress;
        }

        // uint256 _withdrawStatic;
        uint256 _lockEth;
        uint256 _withdrawTeam;
        (, _lockEth, _withdrawTeam) = earningsInstance.getStaticAfterFoundsTeam(userAddress);

        if (ethAmount >= _lockEth) {
            ethAmount = ethAmount.add(_lockEth);
            if (userInfo[userAddress].staticTimeout && userInfo[userAddress].staticTime + 3 days < block.timestamp) {
                address(uint160(systemAddress)).transfer(userInfo[userAddress].teamEth.sub(_withdrawTeam.mul(100).div(80)));
                userInfo[userAddress].teamEth = 0;
                earningsInstance.changeWithdrawTeamZero(userAddress);
            }
            userInfo[userAddress].staticTimeout = false;
            userInfo[userAddress].staticTime = block.timestamp;
        } else {
            _lockEth = ethAmount;
            ethAmount = ethAmount.mul(2);
        }

        earningsInstance.addActivateEth(userAddress, _lockEth);
        if (initAddressAmount <= 50 && userInfo[userAddress].ethAmount > 0) {
            require(userInfo[userAddress].profitAmount == 0);
        }

        if (ethAmount >= 1 ether && _user.ethAmount == 0) {// when initAddressAmount <= 500, address can only invest once before out of static
            initAddressAmount++;
        }

        calculateBuy(_user, ethAmount, straightAddress, whiteAddress, adminAddress, userAddress);

        straightReferralReward(_user, ethAmount);
        // calculate straight referral reward

        uint256 topProfits = whetherTheCap();
        require(earningsInstance.getWithdrawStatic(msg.sender).mul(100).div(80) <= topProfits);

        emit Buy(userAddress, ethAmount, block.timestamp);
    }

    // contains some methods for buy or reinvest
    function calculateBuy(
        User storage user,
        uint256 ethAmount,
        address straightAddress,
        address whiteAddress,
        address adminAddress,
        address users
    )
    internal
    {
        require(ethAmount > 0);
        user.ethAmount = teamRewardInstance.isWhitelistAddress(user.userAddress) ? (ethAmount.mul(110).div(100)).add(user.ethAmount) : ethAmount.add(user.ethAmount);

        if (user.ethAmount > user.refeTopAmount.mul(60).div(100)) {
            user.straightEth += user.lockStraight;
            user.lockStraight = 0;
        }
        if (user.ethAmount >= 1 ether && !userReinvest[user.userAddress].isPush && !teamRewardInstance.isWhitelistAddress(user.userAddress)) {
                straightInviteAddress[straightAddress].push(user.userAddress);
                userReinvest[user.userAddress].isPush = true;
                // record straight address
            if (straightInviteAddress[straightAddress].length.sub(lastStraightLength[straightAddress]) > straightInviteAddress[straightSort[9]].length.sub(lastStraightLength[straightSort[9]])) {
                    bool has = false;
                    //search this address
                    for (uint i = 0; i < 10; i++) {
                        if (straightSort[i] == straightAddress) {
                            has = true;
                        }
                    }
                    if (!has) {
                        //search this address if not in this array,go sort after cover last
                        straightSort[9] = straightAddress;
                    }
                    // sort referral address
                    quickSort(straightSort, int(0), int(9));
                    // straightSortAddress(straightAddress);
                }
//            }

        }

        address(uint160(eggAddress)).transfer(ethAmount.mul(rewardRatio[6]).div(100));
        // transfer to eggAddress 1% eth

        straightSortRewards += ethAmount.mul(rewardRatio[5]).div(100);
        // straight sort rewards, 5% eth

        teamReferralReward(ethAmount, straightAddress);
        // issue team reward

        terminatorPoolAmount += ethAmount.mul(rewardRatio[4]).div(100);
        // issue terminator reward

        calculateToken(user, ethAmount);
        // calculate and transfer KOC token

        calculateProfit(user, ethAmount, users);
        // calculate user earn profit

        updateTeamLevel(straightAddress);
        // update team level

        totalEthAmount += ethAmount;

        whitelistPerformance[whiteAddress] += ethAmount;
        whitelistPerformance[adminAddress] += ethAmount;

        addTerminator(user.userAddress);
    }

    // contains five kinds of reinvest, 1 means reinvest static rewards, 2 means recommend rewards
    //                                  3 means team rewards,  4 means terminators rewards, 5 means node rewards
    function reinvest(uint256 amount, uint8 value)
    public
    payable
    {
        address reinvestAddress = msg.sender;

        address straightAddress;
        address whiteAddress;
        address adminAddress;
        (straightAddress, whiteAddress, adminAddress,) = teamRewardInstance.getUserSystemInfo(msg.sender);

        require(value == 1 || value == 2 || value == 3 || value == 4, "resonance 303");

        uint256 earningsProfits = 0;

        if (value == 1) {
            earningsProfits = whetherTheCap();
            uint256 _withdrawStatic;
            uint256 _afterFounds;
            uint256 _withdrawTeam;
            (_withdrawStatic, _afterFounds, _withdrawTeam) = earningsInstance.getStaticAfterFoundsTeam(reinvestAddress);

            _withdrawStatic = _withdrawStatic.mul(100).div(80);
            require(_withdrawStatic.add(userReinvest[reinvestAddress].staticReinvest).add(amount) <= earningsProfits);

            if (amount >= _afterFounds) {
                if (userInfo[reinvestAddress].staticTimeout && userInfo[reinvestAddress].staticTime + 3 days < block.timestamp) {
                    address(uint160(systemAddress)).transfer(userInfo[reinvestAddress].teamEth.sub(_withdrawTeam.mul(100).div(80)));
                    userInfo[reinvestAddress].teamEth = 0;
                    earningsInstance.changeWithdrawTeamZero(reinvestAddress);
                }
                userInfo[reinvestAddress].staticTimeout = false;
                userInfo[reinvestAddress].staticTime = block.timestamp;
            }
            userReinvest[reinvestAddress].staticReinvest += amount;
        } else if (value == 2) {
            //¸´Í¶Ö±ÍÆ
            require(userInfo[reinvestAddress].straightEth >= amount);
            userInfo[reinvestAddress].straightEth = userInfo[reinvestAddress].straightEth.sub(amount);

            earningsProfits = userInfo[reinvestAddress].straightEth;
        } else if (value == 3) {
            require(userInfo[reinvestAddress].teamEth >= amount);
            userInfo[reinvestAddress].teamEth = userInfo[reinvestAddress].teamEth.sub(amount);

            earningsProfits = userInfo[reinvestAddress].teamEth;
        } else if (value == 4) {
            terminatorInstance.reInvestTerminatorReward(reinvestAddress, amount);
        }

        amount = earningsInstance.calculateReinvestAmount(msg.sender, amount, earningsProfits, value);

        calculateBuy(userInfo[reinvestAddress], amount, straightAddress, whiteAddress, adminAddress, reinvestAddress);

        straightReferralReward(userInfo[reinvestAddress], amount);

        emit Reinvest(reinvestAddress, amount, value, block.timestamp);
    }

    // contains five kinds of withdraw, 1 means withdraw static rewards, 2 means recommend rewards
    //                                  3 means team rewards,  4 means terminators rewards, 5 means node rewards
    function withdraw(uint256 amount, uint8 value)
    public
    {
        address withdrawAddress = msg.sender;
        require(value == 1 || value == 2 || value == 3 || value == 4);

        uint256 _lockProfits = 0;
        uint256 _userRouteEth = 0;
        uint256 transValue = amount.mul(80).div(100);

        if (value == 1) {
            _userRouteEth = whetherTheCap();
            _lockProfits = SafeMath.mul(amount, remain).div(100);
        } else if (value == 2) {
            _userRouteEth = userInfo[withdrawAddress].straightEth;
        } else if (value == 3) {
            if (userInfo[withdrawAddress].staticTimeout) {
                require(userInfo[withdrawAddress].staticTime + 3 days >= block.timestamp);
            }
            _userRouteEth = userInfo[withdrawAddress].teamEth;
        } else if (value == 4) {
            _userRouteEth = amount.mul(80).div(100);
            terminatorInstance.modifyTerminatorReward(withdrawAddress, _userRouteEth);
        }

        earningsInstance.routeAddLockEth(withdrawAddress, amount, _lockProfits, _userRouteEth, value);

        address(uint160(withdrawAddress)).transfer(transValue);

        emit Withdraw(withdrawAddress, amount, value, block.timestamp);
    }

    // referral address support subordinate, 10%
    function supportSubordinateAddress(uint256 index, address subordinate)
    public
    payable
    {
        User storage _user = userInfo[msg.sender];

        require(_user.ethAmount.sub(_user.tokenProfit.mul(100).div(120)) >= _user.refeTopAmount.mul(60).div(100));

        uint256 straightTime;
        address refeAddress;
        uint256 ethAmount;
        bool supported;
        (straightTime, refeAddress, ethAmount, supported) = recommendInstance.getRecommendByIndex(index, _user.userAddress);
        require(!supported);

        require(straightTime.add(3 days) >= block.timestamp && refeAddress == subordinate && msg.value >= ethAmount.div(10));

        if (_user.ethAmount.add(msg.value) >= _user.refeTopAmount.mul(60).div(100)) {
            _user.straightEth += ethAmount.mul(rewardRatio[2]).div(100);
        } else {
            _user.lockStraight += ethAmount.mul(rewardRatio[2]).div(100);
        }

        address straightAddress;
        address whiteAddress;
        address adminAddress;
        (straightAddress, whiteAddress, adminAddress,) = teamRewardInstance.getUserSystemInfo(subordinate);
        calculateBuy(userInfo[subordinate], msg.value, straightAddress, whiteAddress, adminAddress, subordinate);

        recommendInstance.setSupported(index, _user.userAddress, true);

        emit SupportSubordinateAddress(index, subordinate, refeAddress, supported);
    }

    // -------------------- internal function ----------------//
    // calculate team reward and issue reward
    //teamRatio = [6, 5, 4, 3, 3, 2, 2, 1, 1, 1, 1];
    function teamReferralReward(uint256 ethAmount, address referralStraightAddress)
    internal
    {
        if (teamRewardInstance.isWhitelistAddress(msg.sender)) {
            uint256 _systemRetain = ethAmount.mul(rewardRatio[3]).div(100);
            uint256 _nodeReward = _systemRetain.mul(activateSystem).div(100);
            systemRetain += _nodeReward;
            address(uint160(nodeAddressReward)).transfer(_nodeReward.mul(100 - activateGlobal).div(100));
            address(uint160(globalAddressReward)).transfer(_nodeReward.mul(activateGlobal).div(100));
            address(uint160(systemAddress)).transfer(_systemRetain.mul(100 - activateSystem).div(100));
        } else {
            uint256 _refeReward = ethAmount.mul(rewardRatio[3]).div(100);

            //system residue eth
            uint256 residueAmount = _refeReward;

            //user straight address
            User memory currentUser = userInfo[referralStraightAddress];

            //issue team reward
            for (uint8 i = 2; i <= 12; i++) {//i start at 2, end at 12
                //get straight user
                address straightAddress = currentUser.straightAddress;

                User storage currentUserStraight = userInfo[straightAddress];
                //if straight user meet requirements
                if (currentUserStraight.level >= i) {
                    uint256 currentReward = _refeReward.mul(teamRatio[i - 2]).div(29);
                    currentUserStraight.teamEth = currentUserStraight.teamEth.add(currentReward);
                    //sub reward amount
                    residueAmount = residueAmount.sub(currentReward);
                }

                currentUser = userInfo[straightAddress];
            }

            uint256 _nodeReward = residueAmount.mul(activateSystem).div(100);
            systemRetain = systemRetain.add(_nodeReward);
            address(uint160(systemAddress)).transfer(residueAmount.mul(100 - activateSystem).div(100));

            address(uint160(nodeAddressReward)).transfer(_nodeReward.mul(100 - activateGlobal).div(100));
            address(uint160(globalAddressReward)).transfer(_nodeReward.mul(activateGlobal).div(100));
        }
    }

    function updateTeamLevel(address refferAddress)
    internal
    {
        User memory currentUserStraight = userInfo[refferAddress];

        uint8 levelUpCount = 0;

        uint256 currentInviteCount = straightInviteAddress[refferAddress].length;
        if (currentInviteCount >= 2) {
            levelUpCount = 2;
        }

        if (currentInviteCount > 12) {
            currentInviteCount = 12;
        }

        uint256 lackCount = 0;
        for (uint8 j = 2; j < currentInviteCount; j++) {
            if (userSubordinateCount[refferAddress][j - 1] >= 1 + lackCount) {
                levelUpCount = j + 1;
                lackCount = 0;
            } else {
                lackCount++;
            }
        }

        if (levelUpCount > currentUserStraight.level) {
            uint8 oldLevel = userInfo[refferAddress].level;
            userInfo[refferAddress].level = levelUpCount;

            if (currentUserStraight.straightAddress != address(0)) {
                if (oldLevel > 0) {
                    if (userSubordinateCount[currentUserStraight.straightAddress][oldLevel - 1] > 0) {
                        userSubordinateCount[currentUserStraight.straightAddress][oldLevel - 1] = userSubordinateCount[currentUserStraight.straightAddress][oldLevel - 1] - 1;
                    }
                }

                userSubordinateCount[currentUserStraight.straightAddress][levelUpCount - 1] = userSubordinateCount[currentUserStraight.straightAddress][levelUpCount - 1] + 1;
                updateTeamLevel(currentUserStraight.straightAddress);
            }
        }
    }

    // calculate bonus profit
    function calculateProfit(User storage user, uint256 ethAmount, address users)
    internal
    {
        if (teamRewardInstance.isWhitelistAddress(user.userAddress)) {
            ethAmount = ethAmount.mul(110).div(100);
        }

        uint256 userBonus = ethToBonus(ethAmount);
        require(userBonus >= 0 && SafeMath.add(userBonus, totalSupply) >= totalSupply);
        totalSupply += userBonus;
        uint256 tokenDivided = SafeMath.mul(ethAmount, rewardRatio[1]).div(100);
        getPerBonusDivide(tokenDivided, userBonus, users);
        user.profitAmount += userBonus;
    }

    // get user bonus information for calculate static rewards
    function getPerBonusDivide(uint256 tokenDivided, uint256 userBonus, address users)
    public
    {
        uint256 fee = tokenDivided * magnitude;
        perBonusDivide += SafeMath.div(SafeMath.mul(tokenDivided, magnitude), totalSupply);
        //calculate every bonus earnings eth
        fee = fee - (fee - (userBonus * (tokenDivided * magnitude / (totalSupply))));

        int256 updatedPayouts = (int256) ((perBonusDivide * userBonus) - fee);

        payoutsTo[users] += updatedPayouts;
    }

    // calculate and transfer KOC token
    function calculateToken(User storage user, uint256 ethAmount)
    internal
    {
        kocInstance.transfer(user.userAddress, ethAmount.mul(ratio));
        user.tokenAmount += ethAmount.mul(ratio);
    }

    // calculate straight reward and record referral address recommendRecord
    function straightReferralReward(User memory user, uint256 ethAmount)
    internal
    {
        address _referralAddresses = user.straightAddress;
        userInfo[_referralAddresses].refeTopAmount = (userInfo[_referralAddresses].refeTopAmount > user.ethAmount) ? userInfo[_referralAddresses].refeTopAmount : user.ethAmount;
        userInfo[_referralAddresses].refeTopAddress = (userInfo[_referralAddresses].refeTopAmount > user.ethAmount) ? userInfo[_referralAddresses].refeTopAddress : user.userAddress;

        recommendInstance.pushRecommend(_referralAddresses, user.userAddress, ethAmount);

        if (teamRewardInstance.isWhitelistAddress(user.userAddress)) {
            uint256 _systemRetain = ethAmount.mul(rewardRatio[2]).div(100);

            uint256 _nodeReward = _systemRetain.mul(activateSystem).div(100);
            systemRetain += _nodeReward;
            address(uint160(systemAddress)).transfer(_systemRetain.mul(100 - activateSystem).div(100));

            address(uint160(globalAddressReward)).transfer(_nodeReward.mul(activateGlobal).div(100));
            address(uint160(nodeAddressReward)).transfer(_nodeReward.mul(100 - activateGlobal).div(100));
        }
    }

    // sort straight address, 10
    function straightSortAddress(address referralAddress)
    internal
    {
        for (uint8 i = 0; i < 10; i++) {
            if (straightInviteAddress[straightSort[i]].length.sub(lastStraightLength[straightSort[i]]) < straightInviteAddress[referralAddress].length.sub(lastStraightLength[referralAddress])) {
                address  [] memory temp;
                for (uint j = i; j < 10; j++) {
                    temp[j] = straightSort[j];
                }
                straightSort[i] = referralAddress;
                for (uint k = i; k < 9; k++) {
                    straightSort[k + 1] = temp[k];
                }
            }
        }
    }

    //sort straight address, 10
    function quickSort(address  [10] storage arr, int left, int right) internal {
        int i = left;
        int j = right;
        if (i == j) return;
        uint pivot = straightInviteAddress[arr[uint(left + (right - left) / 2)]].length.sub(lastStraightLength[arr[uint(left + (right - left) / 2)]]);
        while (i <= j) {
            while (straightInviteAddress[arr[uint(i)]].length.sub(lastStraightLength[arr[uint(i)]]) > pivot) i++;
            while (pivot > straightInviteAddress[arr[uint(j)]].length.sub(lastStraightLength[arr[uint(j)]])) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    // settle straight rewards
    function settleStraightRewards()
    internal
    {
        uint256 addressAmount;
        for (uint8 i = 0; i < 10; i++) {
            addressAmount += straightInviteAddress[straightSort[i]].length - lastStraightLength[straightSort[i]];
        }

        uint256 _straightSortRewards = SafeMath.div(straightSortRewards, 2);
        uint256 perAddressReward = SafeMath.div(_straightSortRewards, addressAmount);
        for (uint8 j = 0; j < 10; j++) {
            address(uint160(straightSort[j])).transfer(SafeMath.mul(straightInviteAddress[straightSort[j]].length.sub(lastStraightLength[straightSort[j]]), perAddressReward));
            straightSortRewards = SafeMath.sub(straightSortRewards, SafeMath.mul(straightInviteAddress[straightSort[j]].length.sub(lastStraightLength[straightSort[j]]), perAddressReward));
            lastStraightLength[straightSort[j]] = straightInviteAddress[straightSort[j]].length;
        }
        delete (straightSort);
        currentBlockNumber = block.number;
    }

    // calculate bonus
    function ethToBonus(uint256 ethereum)
    internal
    view
    returns (uint256)
    {
        uint256 _price = bonusPrice * 1e18;
        // calculate by wei
        uint256 _tokensReceived =
        (
        (
        SafeMath.sub(
            (sqrt
        (
            (_price ** 2)
            +
            (2 * (priceIncremental * 1e18) * (ethereum * 1e18))
            +
            (((priceIncremental) ** 2) * (totalSupply ** 2))
            +
            (2 * (priceIncremental) * _price * totalSupply)
        )
            ), _price
        )
        ) / (priceIncremental)
        ) - (totalSupply);

        return _tokensReceived;
    }

    // utils for calculate bonus
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // get user bonus profits
    function myBonusProfits(address user)
    view
    public
    returns (uint256)
    {
        return (uint256) ((int256)(perBonusDivide.mul(userInfo[user].profitAmount)) - payoutsTo[user]).div(magnitude);
    }

    function whetherTheCap()
    internal
    returns (uint256)
    {
        require(userInfo[msg.sender].ethAmount.mul(120).div(100) >= userInfo[msg.sender].tokenProfit);
        uint256 _currentAmount = userInfo[msg.sender].ethAmount.sub(userInfo[msg.sender].tokenProfit.mul(100).div(120));
        uint256 topProfits = _currentAmount.mul(remain + 100).div(100);
        uint256 userProfits = myBonusProfits(msg.sender);

        if (userProfits > topProfits) {
            userInfo[msg.sender].profitAmount = 0;
            payoutsTo[msg.sender] = 0;
            userInfo[msg.sender].tokenProfit += topProfits;
            userInfo[msg.sender].staticTime = block.timestamp;
            userInfo[msg.sender].staticTimeout = true;
        }

        if (topProfits == 0) {
            topProfits = userInfo[msg.sender].tokenProfit;
        } else {
            topProfits = (userProfits >= topProfits) ? topProfits : userProfits.add(userInfo[msg.sender].tokenProfit); // not add again
        }

        return topProfits;
    }

    // -------------------- set api ---------------- //
    function setStraightSortRewards()
    public
    onlyAdmin()
    returns (bool)
    {
        require(currentBlockNumber + blockNumber < block.number);
        settleStraightRewards();
        return true;
    }

    // -------------------- get api ---------------- //
    // get straight sort list, 10 addresses
    function getStraightSortList()
    public
    view
    returns (address[10] memory)
    {
        return straightSort;
    }

    // get effective straight addresses current step
    function getStraightInviteAddress()
    public
    view
    returns (address[] memory)
    {
        return straightInviteAddress[msg.sender];
    }

    // get currentBlockNumber
    function getcurrentBlockNumber()
    public
    view
    returns (uint256){
        return currentBlockNumber;
    }

    function getPurchaseTasksInfo()
    public
    view
    returns (
        uint256 ethAmount,
        uint256 refeTopAmount,
        address refeTopAddress,
        uint256 lockStraight
    )
    {
        User memory getUser = userInfo[msg.sender];
        ethAmount = getUser.ethAmount.sub(getUser.tokenProfit.mul(100).div(120));
        refeTopAmount = getUser.refeTopAmount;
        refeTopAddress = getUser.refeTopAddress;
        lockStraight = getUser.lockStraight;
    }

    function getPersonalStatistics()
    public
    view
    returns (
        uint256 holdings,
        uint256 dividends,
        uint256 invites,
        uint8 level,
        uint256 afterFounds,
        uint256 referralRewards,
        uint256 teamRewards,
        uint256 nodeRewards
    )
    {
        User memory getUser = userInfo[msg.sender];

        uint256 _withdrawStatic;
        (_withdrawStatic, afterFounds) = earningsInstance.getStaticAfterFounds(getUser.userAddress);

        holdings = getUser.ethAmount.sub(getUser.tokenProfit.mul(100).div(120));
        dividends = (myBonusProfits(msg.sender) >= holdings.mul(120).div(100)) ? holdings.mul(120).div(100) : myBonusProfits(msg.sender);
        invites = straightInviteAddress[msg.sender].length;
        level = getUser.level;
        referralRewards = getUser.straightEth;
        teamRewards = getUser.teamEth;
        uint256 _nodeRewards = (totalEthAmount == 0) ? 0 : whitelistPerformance[msg.sender].mul(systemRetain).div(totalEthAmount);
        nodeRewards = (whitelistPerformance[msg.sender] < 500 ether) ? 0 : _nodeRewards;
    }

    function getUserBalance()
    public
    view
    returns (
        uint256 staticBalance,
        uint256 recommendBalance,
        uint256 teamBalance,
        uint256 terminatorBalance,
        uint256 nodeBalance,
        uint256 totalInvest,
        uint256 totalDivided,
        uint256 withdrawDivided
    )
    {
        User memory getUser = userInfo[msg.sender];
        uint256 _currentEth = getUser.ethAmount.sub(getUser.tokenProfit.mul(100).div(120));

        uint256 withdrawStraight;
        uint256 withdrawTeam;
        uint256 withdrawStatic;
        uint256 withdrawNode;
        (withdrawStraight, withdrawTeam, withdrawStatic, withdrawNode) = earningsInstance.getUserWithdrawInfo(getUser.userAddress);

//        uint256 _staticReward = getUser.ethAmount.mul(120).div(100).sub(withdrawStatic.mul(100).div(80));
        uint256 _staticReward = (getUser.ethAmount.mul(120).div(100) > withdrawStatic.mul(100).div(80)) ? getUser.ethAmount.mul(120).div(100).sub(withdrawStatic.mul(100).div(80)) : 0;

        uint256 _staticBonus = (withdrawStatic.mul(100).div(80) < myBonusProfits(msg.sender).add(getUser.tokenProfit)) ? myBonusProfits(msg.sender).add(getUser.tokenProfit).sub(withdrawStatic.mul(100).div(80)) : 0;

        staticBalance = (myBonusProfits(getUser.userAddress) >= _currentEth.mul(remain + 100).div(100)) ? _staticReward.sub(userReinvest[getUser.userAddress].staticReinvest) : _staticBonus.sub(userReinvest[getUser.userAddress].staticReinvest);

        recommendBalance = getUser.straightEth.sub(withdrawStraight.mul(100).div(80));
        teamBalance = getUser.teamEth.sub(withdrawTeam.mul(100).div(80));
        terminatorBalance = terminatorInstance.getTerminatorRewardAmount(getUser.userAddress);
        nodeBalance = 0;
        totalInvest = getUser.ethAmount;
        totalDivided = getUser.tokenProfit.add(myBonusProfits(getUser.userAddress));
        withdrawDivided = earningsInstance.getWithdrawStatic(getUser.userAddress).mul(100).div(80);
    }

    // returns contract statistics
    function contractStatistics()
    public
    view
    returns (
        uint256 recommendRankPool,
        uint256 terminatorPool
    )
    {
        recommendRankPool = straightSortRewards;
        terminatorPool = getCurrentTerminatorAmountPool();
    }

    function listNodeBonus(address node)
    public
    view
    returns (
        address nodeAddress,
        uint256 performance
    )
    {
        nodeAddress = node;
        performance = whitelistPerformance[node];
    }

    function listRankOfRecommend()
    public
    view
    returns (
        address[10] memory _straightSort,
        uint256[10] memory _inviteNumber
    )
    {
        for (uint8 i = 0; i < 10; i++) {
            if (straightSort[i] == address(0)){
                break;
            }
            _inviteNumber[i] = straightInviteAddress[straightSort[i]].length.sub(lastStraightLength[straightSort[i]]);
        }
        _straightSort = straightSort;
    }

    // return current effective user for initAddressAmount
    function getCurrentEffectiveUser()
    public
    view
    returns (uint256)
    {
        return initAddressAmount;
    }
    function addTerminator(address addr)
    internal
    {
        uint256 allInvestAmount = userInfo[addr].ethAmount.sub(userInfo[addr].tokenProfit.mul(100).div(120));
        uint256 withdrawAmount = terminatorInstance.checkBlockWithdrawAmount(block.number);
        terminatorInstance.addTerminator(addr, allInvestAmount, block.number, (terminatorPoolAmount - withdrawAmount).div(2));
    }

    function isLockWithdraw()
    public
    view
    returns (
        bool isLock,
        uint256 lockTime
    )
    {
        isLock = userInfo[msg.sender].staticTimeout;
        lockTime = userInfo[msg.sender].staticTime;
    }

    function modifyActivateSystem(uint256 value)
    mustAdmin(msg.sender)
    public
    {
        activateSystem = value;
    }

    function modifyActivateGlobal(uint256 value)
    mustAdmin(msg.sender)
    public
    {
        activateGlobal = value;
    }

    //return Current Terminator reward pool amount
    function getCurrentTerminatorAmountPool()
    view public
    returns(uint256 amount)
    {
        return terminatorPoolAmount-terminatorInstance.checkBlockWithdrawAmount(block.number);
    }
}
