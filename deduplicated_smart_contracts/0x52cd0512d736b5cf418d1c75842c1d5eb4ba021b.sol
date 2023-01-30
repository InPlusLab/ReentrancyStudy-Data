/**
 *Submitted for verification at Etherscan.io on 2019-12-10
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

pragma solidity ^0.4.26;


contract UtilGameFair {
    uint ethWei = 1 ether;

    //根据投注金额查询会员等级
    function getLevel(uint value) public view returns (uint) {
        if (value >= 1 * ethWei && value <= 5 * ethWei) {//1-5=v1
            return 1;
        }
        if (value >= 6 * ethWei && value <= 10 * ethWei) {//6-10=v2
            return 2;
        }
        if (value >= 11 * ethWei && value <= 15 * ethWei) {//11-15=v3
            return 3;
        }
        return 0;
    }

    //获得返佣下线层级数,3无限
    function getLineLevel(uint value) public view returns (uint) {
        if (value >= 1 * ethWei && value <= 5 * ethWei) {//1-5=1代奖励
            return 1;
        }
        if (value >= 6 * ethWei && value <= 10 * ethWei) {//6-10=2代奖励
            return 2;
        }
        if (value >= 11 * ethWei) {//>=11=无限代奖励
            return 3;
        }
        return 0;
    }

    //根据会员等级查询分红系数
    function getScByLevel(uint level) public pure returns (uint) {
        if (level == 1) {//v1=50%
            return 5;
        }
        if (level == 2) {//v2=70%
            return 7;
        }
        if (level == 3) {//v3=100%
            return 10;
        }
        return 0;
    }

    //奖励烧伤等级系数
    function getFireScByLevel(uint level) public pure returns (uint) {
        if (level == 1) {//v1=30%
            return 3;
        }
        if (level == 2) {//v2=60%
            return 6;
        }
        if (level == 3) {//v3=100%
            return 10;
        }
        return 0;
    }

    //推荐人奖励系统
    function getRecommendScaleByLevelAndTim(uint level, uint times) public pure returns (uint){
        if (level == 1 && times == 1) {//v1,1代下级奖励50%
            return 50;
        }
        if (level == 2 && times == 1) {//v2,1代下级奖励70%
            return 70;
        }
        if (level == 2 && times == 2) {//v2,2代奖励50%
            return 50;
        }
        if (level == 3) {
            if (times == 1) {//v3,1代奖励100%
                return 100;
            }
            if (times == 2) {//v3,2代奖金70%
                return 70;
            }
            if (times == 3) {//v3,3代奖励50%
                return 50;
            }
            if (times >= 4 && times <= 10) {//v3,4-10代奖励10%
                return 10;
            }
            if (times >= 11 && times <= 20) {//v3,11-20代奖励5%
                return 5;
            }
            if (times >= 21) {//v3,21代以后奖励1%
                return 1;
            }
        }
        return 0;
    }

    //比较字符串是否相等
    function compareStr(string memory _str, string memory str) public pure returns (bool) {
        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
            return true;
        }
        return false;
    }
}

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}
    // solhint-disable-previous-line no-empty-blocks

    //返回合约调用人地址
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    //返回合约调用发送的数据
    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    //合约所有人
    address private _owner;

    //变更合约所有人事件
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        //合约创建时指定合约所有人为创建者
        _owner = _msgSender();
        //调用事件日志
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     * 返回当前合约所有人地址
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * 函数修改器，判断是否为合约所有人调用
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     * 返回合约调用者是否为合约所有人
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     * 放弃合约所有权
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * 转让合约所有权
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    //角色映射表
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     * 添加角色权限
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     * 删除角色权限
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     * 判断是否有角色权限
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 * 白名单管理员角色
 */
contract WhitelistAdminRole is Context, Ownable {
    using Roles for Roles.Role;

    //加入白名单事件
    event WhitelistAdminAdded(address indexed account);
    //移出白名单事件
    event WhitelistAdminRemoved(address indexed account);

    //白名单管理员集合
    Roles.Role private _whitelistAdmins;

    constructor () internal {
        //合约创建时将创建人加入白名单
        _addWhitelistAdmin(_msgSender());
    }

    //判断是否为白名单管理员的函数修改器
    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(_msgSender()) || isOwner(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    //判断是否为白名单管理员
    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    //添加白名单管理员
    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    //移出白名单管理员
    function removeWhitelistAdmin(address account) public onlyOwner {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    //放弃白名单管理员身份
    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(_msgSender());
    }

    //添加白名单管理员
    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    //称出白名单管理员
    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

//游戏类
contract GameFair is UtilGameFair, WhitelistAdminRole {

    using SafeMath for *;

    string constant private name = "GameFair Official";

    uint ethWei = 1 ether;

    //专项帐户
    address  private devAddr = address(0xb61f5A335acB482c23Af25e76D7c7b3FEA873059);

    //回合用户实体
    struct User {
        uint id;//用户id
        address userAddress;//用户钱包地址
        string inviteCode;//邀请码
        string referrer;//推荐人
        uint staticLevel;//静态等级
        uint dynamicLevel;//动态等级
        uint allInvest;//全部投注金额
        uint freezeAmount;//冻结金额
        uint unlockAmount;//解锁金额
        uint allStaticAmount;//全部分红收益金额
        uint allDynamicAmount;//全部节点奖励金额
        uint hisStaticAmount;//他的静态金额
        uint hisDynamicAmount;//他的动态金额
        Invest[] invests;//投注列表
        SeizeInvest[] seizesInvests;//抢注
        uint votes;//可用投票数
        uint staticFlag;//投注分红下标
    }

    //用户基础信息
    struct UserGlobal {
        uint id;//用户id
        address userAddress;//用户钱包地址
        string inviteCode;//邀请码
        string referrer;//推荐人
        uint inviteCount;//邀请人总数量
    }

    //投注
    struct Invest {
        address userAddress;//用户地址
        uint investAmount;//投注金额
        uint investTime;//投注时间
        uint times;//下线数量
    }

    //抢注
    struct SeizeInvest {
        uint rid;
        address userAddress;
        uint seizeAmount;
        uint seizeTime;
    }

    //系统码,没用到
    string constant systemCode = "99999999";
    //开始时间
    uint startTime;
    //总投注次数
    uint investCount = 0;
    //回合投注次数映射表
    mapping(uint => uint) rInvestCount;
    //总投注金额
    uint investMoney = 0;
    //回合投注金映射表
    mapping(uint => uint) rInvestMoney;
    //用户总资产
    uint userAssets = 0;

    //用户初始id
    uint uid = 0;
    //回合数
    uint rid = 1;
    //游戏结束后重启的时间
    uint period = 6 hours;

    //初始投票阀值80%，60%，40%，20%
    uint voteStartSc = 80;

    //游戏状态,1游戏中，2投票中
    uint gameStatus = 1;

    //游戏投票结束时间
    uint voteEndTime = 0;
    //抢注结束时间
    uint seizeEndTime = 0;

    //投票结果，重启/继续
    uint[] voteResult = [0, 0];
    //最后抢注地址
    mapping(uint => SeizeInvest) lastSeizeInvest;

    //用户回合映射
    mapping(uint => mapping(address => User)) userRoundMapping;
    //地址->用户映射
    mapping(address => UserGlobal) userMapping;
    //邀请码->地址映射
    mapping(string => address) addressMapping;
    //用户列表映射(有序)
    mapping(uint => address) public indexMapping;

    //是否人为操作，否则为合约调用
    modifier isHuman() {
        address addr = msg.sender;
        uint codeLength;

        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        require(tx.origin == msg.sender, "sorry, human only");
        _;
    }

    //投注事件
    event LogInvestIn(address indexed who, uint indexed uid, uint amount, uint time, string inviteCode, string referrer);
    //提取收益事件
    event LogWithdrawProfit(address indexed who, uint indexed uid, uint amount, uint time);
    //赎回事件
    event LogRedeem(address indexed who, uint indexed uid, uint amount, uint now);
    //开始投票事件
    event VoteStart(uint startTime, uint endTime);
    //抢注事件
    event SeizeInvestNow(address indexed who, uint indexed uid, uint amount, uint now);

    //发布合约初始化数据
    constructor () public {
        startTime = now;
    }

    function() external payable {
    }

    //游戏是否开始
    function gameStart() public view returns (bool) {
        return startTime != 0 && now > startTime && gameStatus == 1;
    }

    /**
    *投注，inviteCode 邀请码，referrer邀请人地址
    */
    function investIn(string memory inviteCode, string memory referrer) public isHuman() payable {
        //判断游戏是否开始
        require(now > startTime && gameStatus == 1, "invest is not allowed now");
        //判断投注金额是否合法
        require(msg.value >= 1 * ethWei && msg.value <= 15 * ethWei, "between 1 and 15");
        require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");

        UserGlobal storage userGlobal = userMapping[msg.sender];
        //获取投注User实体
        if (userGlobal.id == 0) {//如果未投注过
            //判断邀请码是否为空
            require(!compareStr(inviteCode, ""), "empty invite code");
            //邀请人地址
            address referrerAddr = getUserAddressByCode(referrer);
            //判断邀请人是否存在
            require(uint(referrerAddr) != 0, "referer not exist");
            //自己不能邀请自己
            require(referrerAddr != msg.sender, "referrer can't be self");
            //自己的邀请码是否重复
            require(!isUsed(inviteCode), "invite code is used");
            //新用户注册
            registerUser(msg.sender, inviteCode, referrer);
        }

        //当前回合数的用户映射
        User storage user = userRoundMapping[rid][msg.sender];
        if (uint(user.userAddress) != 0) {//当前回合非第一次投注
            //判断当前回合冻结金额+本次投注金额是否超过15eth
            require(user.freezeAmount.add(msg.value) <= 15 * ethWei, "can not beyond 15 eth");
            //累加当前回合投注
            user.allInvest = user.allInvest.add(msg.value);
            //累加当前回合冻结金额
            user.freezeAmount = user.freezeAmount.add(msg.value);
            //设置当前静态等级
            user.staticLevel = getLevel(user.freezeAmount);
            //设置当前动态等级
            user.dynamicLevel = getLineLevel(user.freezeAmount.add(user.unlockAmount));
        } else {//当前回合第一次投注
            user.id = userGlobal.id;
            user.userAddress = msg.sender;
            user.freezeAmount = msg.value;
            user.staticLevel = getLevel(msg.value);
            user.allInvest = msg.value;
            user.dynamicLevel = getLineLevel(msg.value);
            user.inviteCode = userGlobal.inviteCode;
            user.referrer = userGlobal.referrer;
        }

        //本轮投注实体
        Invest memory invest = Invest(msg.sender, msg.value, now, 0);
        //加入用户投注数组
        user.invests.push(invest);
        user.votes += (msg.value.div(ethWei));

        //累计总投注次数
        investCount = investCount.add(1);
        //累计总投注金额
        investMoney = investMoney.add(msg.value);
        //累计本轮投注次数
        rInvestCount[rid] = rInvestCount[rid].add(1);
        //累计本轮投注金额
        rInvestMoney[rid] = rInvestMoney[rid].add(msg.value);
        //累计用户总资产
        userAssets += msg.value;
        //向专项帐户打款4%
        sendFeetoAdmin(msg.value);
        //发布投注事件日志
        emit LogInvestIn(msg.sender, userGlobal.id, msg.value, now, userGlobal.inviteCode, userGlobal.referrer);
    }

    //投票期间抢注
    function seizeInvest(string memory inviteCode) public isHuman() payable {
        //判断抢注是否开始
        require(seizeEndTime > now, "seize invest not start");
        require(!compareStr(inviteCode, ""), "empty invite code");
        //判断抢注金额是否合法
        require(msg.value >= 1 * ethWei && msg.value <= 15 * ethWei, "between 1 and 15");
        require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");

        UserGlobal storage userGlobal = userMapping[msg.sender];
        //获取投注User实体
        if (userGlobal.id == 0) {//如果未投注过
            //自己的邀请码是否重复
            require(!isUsed(inviteCode), "invite code is used");
            //新用户注册
            registerUser(msg.sender, inviteCode, "");
        }
        User storage user = userRoundMapping[rid][msg.sender];
        SeizeInvest memory si = SeizeInvest(rid, msg.sender, msg.value, now);
        if (uint(user.userAddress) != 0) {//当前回合非第一次投注
            //将抢注金额放解冻金额
            user.unlockAmount = user.unlockAmount.add(msg.value);
            user.allInvest += msg.value;
        } else {//当前回合第一次投注
            user.id = userGlobal.id;
            user.userAddress = msg.sender;
            user.allInvest = msg.value;
            user.inviteCode = userGlobal.inviteCode;
            user.referrer = userGlobal.referrer;
            user.unlockAmount =msg.value;
        }
        user.seizesInvests.push(si);
        investMoney = investMoney.add(msg.value);
        userAssets += msg.value;
        lastSeizeInvest[rid] = si;
        emit SeizeInvestNow(msg.sender, userGlobal.id, msg.value, now);
    }

    //执行投票结果
    function voteComplete() external onlyWhitelistAdmin {
        require(gameStatus == 2,"game status error");
        if (voteResult[0] > voteResult[1]) {//游戏重启
            //游戏开始时间为6小时后
            startTime = now.add(period);
            //重置投票阀值
            voteStartSc = 80;
            //计算风险系数
            uint sc = address(this).balance.mul(100).div(userAssets);
            for (uint i = 1; i <= uid; i++) {
                address userAddr = indexMapping[i];
                User storage previousUser = userRoundMapping[rid][userAddr];
                User storage curUser = userRoundMapping[rid + 1][userAddr];
                curUser.id = previousUser.id;
                curUser.userAddress = previousUser.userAddress;
                curUser.inviteCode = previousUser.inviteCode;
                curUser.referrer = previousUser.referrer;
                curUser.allInvest = previousUser.allInvest;
                curUser.unlockAmount = previousUser.freezeAmount.add(previousUser.unlockAmount).mul(sc).div(100);
                curUser.freezeAmount = 0;
                curUser.allStaticAmount = previousUser.allStaticAmount.mul(sc).div(100);
                curUser.allDynamicAmount = previousUser.allDynamicAmount.mul(sc).div(100);
                curUser.votes = curUser.unlockAmount.div(ethWei);
                curUser.hisStaticAmount = previousUser.hisStaticAmount;
                curUser.hisDynamicAmount = previousUser.hisDynamicAmount;
                curUser.staticLevel = 0;
                curUser.dynamicLevel =getLineLevel(curUser.unlockAmount);
            }
            //回合数加1
            rid++;
        } else {//游戏继续
            for (i = 1; i <= uid; i++) {
                userAddr = indexMapping[i];
                curUser = userRoundMapping[rid][userAddr];
                curUser.votes = curUser.freezeAmount.add(curUser.unlockAmount).div(ethWei);
            }
            lastSeizeInvest[rid] = SeizeInvest(rid,0x00,0,0);
        }

        gameStatus = 1;
        //重置投票票数
        voteResult = [0, 0];
    }

    //收益提现
    function withdrawProfit()
    public
    isHuman() {
        //判断游戏是否开始
        require(now > startTime && gameStatus == 1, "now not withdrawal");
        //当前回合User
        User storage user = userRoundMapping[rid][msg.sender];
        //当前用户总余额
        uint sendMoney = user.allStaticAmount.add(user.allDynamicAmount);

        bool isEnough = false;
        uint resultMoney = 0;
        (isEnough, resultMoney) = isEnoughBalance(sendMoney);
        //判断合约内余额是否充足
        if (!isEnough) {//余额不够结束游戏
            endRound();
        }

        if (resultMoney > 0) {
            //给用户转帐
            sendMoneyToUser(msg.sender, resultMoney);
            //清空分红余额
            user.allStaticAmount = 0;
            //清空节点奖励余额
            user.allDynamicAmount = 0;
            //减去用户总资产
            userAssets -= resultMoney;
            //检查是否需要投票
            checkVote();
            //发送提现事件日志
            emit LogWithdrawProfit(msg.sender, user.id, resultMoney, now);
        }
    }

    //判断合约余额是否足够
    function isEnoughBalance(uint sendMoney) private view returns (bool, uint){
        if (sendMoney >= address(this).balance) {//合约余额小于等于发送的金额返回否&当前合约余额
            return (false, address(this).balance);
        } else {
            //合约余额大于发送的金额返回是&发送金额
            return (true, sendMoney);
        }
    }

    //给用户转帐
    function sendMoneyToUser(address userAddress, uint money) private {
        userAddress.transfer(money);
    }

    //计算分红
    function calStaticProfit(address userAddr) external onlyWhitelistAdmin returns (uint)
    {
        return calStaticProfitInner(userAddr);
    }

    function calStaticProfitInner(address userAddr) private returns (uint)
    {
        //当前回合User
        User storage user = userRoundMapping[rid][userAddr];
        if (user.id == 0) {//当前回合用户未投注
            return 0;
        }

        //获取分红百分比
        uint scale = getScByLevel(user.staticLevel);
        uint allStatic = 0;
        for (uint i = user.staticFlag; i < user.invests.length; i++) {//遍历当前回合所有投注金额
            //投注
            Invest storage invest = user.invests[i];
            //投注时间
            uint startDay = invest.investTime.sub(8 hours).div(1 days).mul(1 days);
            //已投注多少天
            uint staticGaps = now.sub(8 hours).sub(startDay).div(1 days);
            //投注解锁日期
            uint unlockDay = now.sub(invest.investTime).div(1 days);

            //判断是否超过5天
            if (staticGaps > 5) {
                staticGaps = 5;
            }
            if (staticGaps > invest.times) {
                allStatic += staticGaps.sub(invest.times).mul(scale).mul(invest.investAmount).div(1000);
                invest.times = staticGaps;
            }

            if (unlockDay >= 5) {
                user.staticFlag++;
                user.freezeAmount = user.freezeAmount.sub(invest.investAmount);
                user.unlockAmount = user.unlockAmount.add(invest.investAmount);
                user.staticLevel = getLevel(user.freezeAmount);
            }
        }
        allStatic = allStatic.mul(getCoefficientInner()).div(100);
        user.allStaticAmount = user.allStaticAmount.add(allStatic);
        user.hisStaticAmount = user.hisStaticAmount.add(allStatic);
        userRoundMapping[rid][userAddr] = user;
        userAssets += allStatic;
        return user.allStaticAmount;
    }

    //计算分红和节点奖励
    function calDynamicProfit(uint start, uint end) external onlyWhitelistAdmin {
        for (uint i = start; i <= end; i++) {
            address userAddr = indexMapping[i];
            User memory user = userRoundMapping[rid][userAddr];
            calStaticProfitInner(userAddr);
            if (user.freezeAmount >= 1 * ethWei) {
                uint scale = getScByLevel(user.staticLevel);
                calUserDynamicProfit(user.referrer, user.freezeAmount, scale);
            }
        }
        checkVote();
    }

    //外部注册用户
    function registerUserInfo(address user, string inviteCode, string referrer) external onlyOwner {
        registerUser(user, inviteCode, referrer);
    }

    //计算节点奖励
    function calUserDynamicProfit(string memory referrer, uint money, uint shareSc) internal {
        string memory tmpReferrer = referrer;
        for (uint i = 1; i <= 30; i++) {
            if (compareStr(tmpReferrer, "")) {
                break;
            }
            address tmpUserAddr = addressMapping[tmpReferrer];
            User storage calUser = userRoundMapping[rid][tmpUserAddr];

            uint fireSc = getFireScByLevel(calUser.staticLevel);
            uint recommendSc = getRecommendScaleByLevelAndTim(calUser.dynamicLevel, i);
            uint moneyResult = 0;
            if (money <= calUser.freezeAmount.add(calUser.unlockAmount)) {
                moneyResult = money;
            } else {
                moneyResult = calUser.freezeAmount.add(calUser.unlockAmount);
            }

            if (recommendSc != 0) {
                uint tmpDynamicAmount = moneyResult.mul(shareSc).mul(fireSc).mul(recommendSc);
                tmpDynamicAmount = tmpDynamicAmount.div(1000).div(10).div(100);

                tmpDynamicAmount = tmpDynamicAmount.mul(getCoefficientInner()).div(100);
                calUser.allDynamicAmount = calUser.allDynamicAmount.add(tmpDynamicAmount);
                calUser.hisDynamicAmount = calUser.hisDynamicAmount.add(tmpDynamicAmount);
                userAssets += tmpDynamicAmount;
            }

            tmpReferrer = calUser.referrer;
        }
    }

    //检查是否需要投票
    function checkVote() internal {
        uint thisBalance = address(this).balance;
        uint sc = thisBalance.mul(100).div(userAssets);
        if (sc < 80 && sc > 60 && voteStartSc == 80) {
            voteStart(60);
        } else if (sc < 60 && sc > 40 && voteStartSc == 60) {
            voteStart(40);
        } else if (sc < 40 && sc > 20 && voteStartSc == 40) {
            voteStart(20);
        } else if (sc < 20 && sc > 0 && voteStartSc == 20) {
            voteStart(0);
        }
    }

    //投票开始
    function voteStart(uint nextSc) internal {
        voteStartSc = nextSc;
        gameStatus = 2;
        voteEndTime = now.add(120 minutes);
        seizeEndTime = now.add(30 minutes);
        emit VoteStart(now, voteEndTime);
    }

    //赎回投注
    function redeem()
    public
    isHuman() {
        require(now > startTime && gameStatus == 1, "now not withdrawal");
        //当前回合用户
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user not exist");
        //记算分红
        calStaticProfitInner(msg.sender);

        //解冻的投注金额
        uint sendMoney = user.unlockAmount;
        bool isEnough = false;
        uint resultMoney = 0;

        (isEnough, resultMoney) = isEnoughBalance(sendMoney);

        if (!isEnough) {//余额不够结束游戏
            endRound();
        }

        if (resultMoney > 0) {
            //向用户转帐
            sendMoneyToUser(msg.sender, resultMoney);
            //清空解冻金额
            user.unlockAmount = 0;
            //重新记算用户分红等级
            user.staticLevel = getLevel(user.freezeAmount);
            //重新记算用户节点奖励等级
            user.dynamicLevel = getLineLevel(user.freezeAmount);
            //减去用户总资产
            userAssets -= resultMoney;
            //减去投票次数
            user.votes -= (resultMoney.div(ethWei));
            //检查是否需要投票
            checkVote();
            //赎回日志
            emit LogRedeem(msg.sender, user.id, resultMoney, now);
        }
    }

    //投票，voteCount投票数量，voteIntent投票意向，0重启,其它继续
    function vote(uint voteCount, uint voteIntent) public isHuman() {
        require(voteCount > 0, "vote count error");
        require(gameStatus == 2 && voteEndTime > now, "vote not start");
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.votes >= voteCount, "vote count error");
        if (voteIntent == 0) {
            voteResult[0] += voteCount;
        } else {
            voteResult[1] += voteCount;
        }
        user.votes -= voteCount;
    }

    //复投,单位:wei
    function reInvestIn(uint investAmount) public isHuman() {
        require(now > startTime && gameStatus == 1, "invest is not allowed now");
        require(investAmount == investAmount.div(ethWei).mul(ethWei), "invalid msg value");
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.unlockAmount >= investAmount && investAmount>0,"reinvest count error");
        uint allFreezeAmount = user.freezeAmount.add(investAmount);
        require(allFreezeAmount <= 15 * ethWei, "can not beyond 15 eth");
        user.unlockAmount = user.unlockAmount.sub(investAmount);
        user.freezeAmount = user.freezeAmount.add(investAmount);
        user.staticLevel = getLevel(user.freezeAmount);
        user.dynamicLevel = getLineLevel(user.freezeAmount.add(user.unlockAmount));

        //本轮投注实体
        Invest memory invest = Invest(msg.sender, investAmount, now, 0);
        //加入用户投注数组
        user.invests.push(invest);
        user.votes-=(investAmount.div(ethWei));
    }

    //获取风险收益倍数
    function getCoefficient() public view returns (uint) {
        return getCoefficientInner();
    }

    function getCoefficientInner() internal view returns (uint) {
        if (userAssets == 0) {
            return 100;
        }
        uint thisBalance = address(this).balance;
        uint coefficient = thisBalance.mul(100).div(userAssets);
        if (coefficient >= 80) {
            return 100;
        }
        if (coefficient >= 60) {
            return 125;
        }
        if (coefficient >= 40) {
            return 167;
        }
        if (coefficient >= 20) {
            return 250;
        }
        if (coefficient > 0) {
            return 300;
        }
        return 100;
    }

    //回合结束
    function endRound() private {
        //回合数累加
        rid++;
        gameStatus = 1;
        //清空所有用户资产
        userAssets = 0;
        //游戏重启后6小时后再开始
        startTime = now.add(period).div(1 hours).mul(1 hours);
        //重置票投信息
        voteStartSc = 80;
        voteResult = [0,0];
        voteEndTime = 0;
    }

    //判断邀请码是否已经使用
    function isUsed(string memory code) public view returns (bool) {
        address user = getUserAddressByCode(code);
        return uint(user) != 0;
    }

    //根据邀请码查询用户地址
    function getUserAddressByCode(string memory code) public view returns (address) {
        return addressMapping[code];
    }

    //给专向帐户转帐6%
    function sendFeetoAdmin(uint amount) private {
        devAddr.transfer(amount.div(16));
    }

    //获取游戏信息
    function getGameInfo() public isHuman() view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        uint coeff = getCoefficientInner();
        uint balance = address(this).balance;
        return (
        rid, //游戏回合
        uid, //最后一个用户id
        startTime, //游戏开始时间
        balance, //合约余额
        userAssets, //用户总权益
        investCount, //总投注次数
        investMoney, //总投注金额
        rInvestCount[rid], //本回合投注次数
        rInvestMoney[rid], //本回合投注金额
        coeff, //分红系数
        gameStatus,//游戏状态，1游戏中,2投票中
        voteStartSc //下一次投票阀值
        );
    }

    //获取抢注信息
    function getSeizeInfo(uint r) public isHuman() view returns (address, uint, uint) {
        uint thisBalance = address(this).balance;
        uint coefficient = thisBalance.mul(100).div(userAssets);
        uint mult = 0;
        if (coefficient > 60) {
            mult = 3;
        } else if (coefficient > 40) {
            mult = 4;
        } else if (coefficient > 20) {
            mult = 6;
        } else if (coefficient > 0) {
            mult = 8;
        } else {
            mult = 10;
        }
        return (
        lastSeizeInvest[r].userAddress, //抢注地址
        lastSeizeInvest[r].seizeAmount, //抢注金额
        mult //抢注奖励倍数
        );
    }

    //获取投票信息
    function getVoteResult() public isHuman view returns (uint, uint, uint, uint){
        return (
        seizeEndTime, //抢注结束时间戳
        voteEndTime, //投票结束时间戳
        voteResult[0], //同意重启票数
        voteResult[1]//不同意重启票数
        );
    }


    //获取用户信息
    function getUserInfo(address user, uint roundId) public isHuman() view returns (uint[11] memory ct, uint inviteCount, string memory inviteCode, string memory referrer) {
        if (roundId == 0) {
            roundId = rid;
        }

        User memory userInfo = userRoundMapping[roundId][user];
        ct[0] = userInfo.id;
        //userid
        ct[1] = userInfo.staticLevel;
        //用户等级
        ct[2] = userInfo.dynamicLevel;
        //用户可获得节点奖励级数
        ct[3] = userInfo.allInvest;
        //总投注金额
        ct[4] = userInfo.freezeAmount;
        //冻结本金
        ct[5] = userInfo.unlockAmount;
        //可赎回本金
        ct[6] = userInfo.allStaticAmount;
        //当前回合分红收益
        ct[7] = userInfo.allDynamicAmount;
        //当前回合节点收益
        ct[8] = userInfo.hisStaticAmount;
        //总分红收益
        ct[9] = userInfo.hisDynamicAmount;
        //总节点收益
        ct[10] = userInfo.votes;
        //可用投票数量
        UserGlobal storage userGlobal = userMapping[user];
        return (ct, userGlobal.id==0?0:userGlobal.inviteCount, userGlobal.inviteCode, userGlobal.referrer);
    }

    //获取最新可提现余额
    function getLatestUnlockAmount(address userAddr) public view returns (uint)
    {
        User memory user = userRoundMapping[rid][userAddr];
        uint allUnlock = user.unlockAmount;
        for (uint i = user.staticFlag; i < user.invests.length; i++) {
            Invest memory invest = user.invests[i];
            uint unlockDay = now.sub(invest.investTime).div(1 days);

            if (unlockDay >= 5) {
                allUnlock = allUnlock.add(invest.investAmount);
            }
        }
        return allUnlock;
    }

    //新用户注册
    function registerUser(address user, string memory inviteCode, string memory referrer) private {
        UserGlobal storage userGlobal = userMapping[user];
        uid++;
        userGlobal.id = uid;
        userGlobal.userAddress = user;
        userGlobal.inviteCode = inviteCode;
        userGlobal.referrer = referrer;
        userGlobal.inviteCount = 0;

        addressMapping[inviteCode] = user;
        indexMapping[uid] = user;

        address parentAddr = getUserAddressByCode(referrer);
        UserGlobal storage parent = userMapping[parentAddr];
        parent.inviteCount += 1;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul overflow");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div zero");
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "lower sub bigger");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "overflow");
        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "mod zero");
        return a % b;
    }
}