/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

/**
 * @title 凌霄之光 v0.1.0
 * @author http://www.jsq.ink
 * @developoer 微信：dappai 
**/

pragma solidity ^0.5.0;

interface tokenTransfer {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value) external;
    function balanceOf(address receiver) external returns(uint256);
}

contract UtilLXZG {
    uint ethWei = 1 ether;

    function getLevel(uint value) internal view returns(uint) {
        if (value >= 1*ethWei && value <= 5*ethWei) {
            return 1;
        }
        if (value >= 6*ethWei && value <= 10*ethWei) {
            return 2;
        }
        if (value >= 11*ethWei && value <= 15*ethWei) {
            return 3;
        }
        return 0;
    }

    function getLineLevel(uint value) internal view returns(uint) {
        if (value >= 1*ethWei && value <= 5*ethWei) {
            return 1;
        }
        if (value >= 6*ethWei && value <= 10*ethWei) {
            return 2;
        }
        if (value >= 11*ethWei) {
            return 3;
        }
        return 0;
    }

    function getScByLevel(uint level) internal pure returns(uint) {
        if (level == 1) {
            return 5;
        }
        if (level == 2) {
            return 7;
        }
        if (level == 3) {
            return 10;
        }
        return 0;
    }
    
    function getRecommendScaleByLevelAndTim(uint performance,uint times) internal view returns(uint){
        if (times == 1) {
            return 10;
        }
        if(performance >= 1000*ethWei && performance <= 3000*ethWei){
            if(times >= 2 && times <= 4){
                return 4;
            }
        }
        if(performance > 3000*ethWei && performance <= 6000*ethWei){
            if(times >= 2 && times <= 4){
                return 4;
            }
            if(times >= 5 && times <= 10){
                return 3;
            }
        }
        if(performance > 6000*ethWei && performance <= 10000*ethWei){
            if(times >= 2 && times <= 4){
                return 4;
            }
            if(times >= 5 && times <= 10){
                return 3;
            }
            if(times >= 11 && times <= 15){
                return 1;
            }
        }
        if(performance >= 10000*ethWei){
            if(times >= 2 && times <= 4){
                return 4;
            }
            if(times >= 5 && times <= 10){
                return 3;
            }
            if(times >= 11 && times <= 20){
                return 1;
            }
        }
        return 0;
    }

    function compareStr(string memory _str, string memory str) internal pure returns(bool) {
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

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
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
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
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
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole is Context, Ownable {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(_msgSender()) || isOwner(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function removeWhitelistAdmin(address account) public onlyOwner {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

contract LXZG is UtilLXZG, WhitelistAdminRole {

    using SafeMath for *;

    string constant private name = "lxzg foundation";

    uint ethWei = 1 ether;
    
    tokenTransfer zxlContract = tokenTransfer(address(0xfb3B4D413Fb8dF96C6336E8DD103f8af38B48F87));
    tokenTransfer fzcContract = tokenTransfer(address(0x04423d360B5F2A65266a150AC109534c47830E66));

    struct User{
        uint id;
        address userAddress;
        string inviteCode;
        string referrer;
        uint staticLevel;
        uint dynamicLevel;
        uint allInvest;
        uint freezeAmount;
        uint allStaticAmount;
        uint allDynamicAmount;
        uint hisStaticAmount;
        uint hisDynamicAmount;
        uint inviteAmount;
        uint performance;
        uint reInvestCount;
        uint lastReInvestTime;
        uint seedFreezeAmount;
        uint seedAllStaticAmount;
        uint seedHisStaticAmount;
        uint seedUnlockAmount;
        SeedInvest[] seedInvests;
        Invest[] invests;
        uint staticFlag;
        uint seedStaticFlag;
    }

    struct GameInfo {
        uint luckPort;
        address[] specialUsers;
    }

    struct UserGlobal {
        uint id;
        address userAddress;
        string inviteCode;
        string referrer;
    }

    struct Invest{
        address userAddress;
        uint investAmount;
        uint limitAmount;
        uint earnAmount;
        uint investTime;
    }
    
    struct SeedInvest{
        address userAddress;
        uint investAmount;
        uint earnAmount;
        uint investTime;
        uint releaseTime;
        uint times;
    }

    uint startTime;
    uint endTime;
    uint investCount = 0;
    mapping(uint => uint) rInvestCount;
    uint investMoney = 0;
    mapping(uint => uint) rInvestMoney;
    mapping(uint => GameInfo) rInfo;
    uint uid = 0;
    uint rid = 1;
    uint period = 3 days;
    uint dividendRate = 3;
    uint statisticsDay = 0;
    mapping (uint => mapping(address => User)) userRoundMapping;
    mapping(address => UserGlobal) userMapping;
    mapping (string => address) addressMapping;
    mapping (uint => address) public indexMapping;

    /**
     * @dev Just a simply check to prevent contract
     * @dev this by calling method in constructor.
     */
    modifier isHuman() {
        address addr = msg.sender;
        uint codeLength;

        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        require(tx.origin == msg.sender, "sorry, human only");
        _;
    }

    event LogInvestIn(address indexed who, uint indexed uid, uint amount, uint time, string inviteCode, string referrer, uint typeFlag);
    event LogWithdrawProfit(address indexed who, uint indexed uid, uint amount, uint time);
    event LogRedeem(address indexed who, uint indexed uid, uint amount, uint now,string tokenType);

    //==============================================================================
    // Constructor
    //==============================================================================
    constructor () public {
    }

    function () external payable {
    }
    
    function investIn(string memory inviteCode, string memory referrer,uint256 value)
        public
        isHuman()
        payable
    {
        require(value >= 10*ethWei && value <= 20000 * ethWei, "between 10 and 20000 fzc");
        require(value == value.div(ethWei).mul(ethWei), "invalid msg value");
        
        //gas 10%
        uint256 gas = value.div(10);
        
        //transferFrom
        zxlContract.transferFrom(msg.sender,address(this),gas);
        fzcContract.transferFrom(msg.sender,address(this),value);
        zxlContract.transfer(address(0x1111111111111111111111111111111111111111),gas);
        
        //30 and 70
        uint256 seedValue = value.mul(30).div(100);
        uint256 walletValue = value.mul(70).div(100);

        UserGlobal storage userGlobal = userMapping[msg.sender];
        if (userGlobal.id == 0) {
            require(!compareStr(inviteCode, ""), "empty invite code");
            address referrerAddr = getUserAddressByCode(referrer);
            require(uint(referrerAddr) != 0, "referer not exist");
            require(referrerAddr != msg.sender, "referrer can't be self");
            require(!isUsed(inviteCode), "invite code is used");

            registerUser(msg.sender, inviteCode, referrer);
        }

        User storage user = userRoundMapping[rid][msg.sender];
        if (uint(user.userAddress) != 0) {
            require(user.freezeAmount.add(user.seedFreezeAmount).add(value) <= 20000*ethWei, "can not beyond 20000 fzc");
            user.allInvest = user.allInvest.add(value);
            user.freezeAmount = user.freezeAmount.add(walletValue);
            user.seedFreezeAmount = user.seedFreezeAmount.add(seedValue);
            user.staticLevel = getLevel(user.freezeAmount);
            user.dynamicLevel = getLineLevel(user.freezeAmount);
            
            if (!compareStr(userGlobal.referrer, "")) {
                address referrerAddr = getUserAddressByCode(userGlobal.referrer);
                userRoundMapping[rid][referrerAddr].performance = userRoundMapping[rid][referrerAddr].performance.add(value);
            }
        } else {
            user.id = userGlobal.id;
            user.userAddress = msg.sender;
            user.freezeAmount = walletValue;
            user.seedFreezeAmount = seedValue;
            user.staticLevel = getLevel(walletValue);
            user.dynamicLevel = getLineLevel(walletValue);
            user.allInvest = value;
            user.inviteCode = userGlobal.inviteCode;
            user.referrer = userGlobal.referrer;
            
            if (!compareStr(userGlobal.referrer, "")) {
                address referrerAddr = getUserAddressByCode(userGlobal.referrer);
                userRoundMapping[rid][referrerAddr].inviteAmount++;
                userRoundMapping[rid][referrerAddr].performance = userRoundMapping[rid][referrerAddr].performance.add(value);
            }
        }
        
        //钱包账户放大三倍
        uint limitAmount = walletValue.mul(3);
        Invest memory invest = Invest(msg.sender, walletValue, limitAmount,0,now);
        user.invests.push(invest);
        
        //种子钱包
        uint releaseTime = now.add(5184000);
        SeedInvest memory seedInvest = SeedInvest(msg.sender, seedValue, 0,now,releaseTime, 0);
        user.seedInvests.push(seedInvest);

        investCount = investCount.add(1);
        investMoney = investMoney.add(value);
        statisticsDay = statisticsDay.add(value);
        
        //Partner
        sendMoneyToPartner(value);
        
        //DynamicProfit
        calUserDynamicProfit(userGlobal.referrer,walletValue);
        
        //Statistics
        endStatistics();
        
        emit LogInvestIn(msg.sender, userGlobal.id, value, now, userGlobal.inviteCode, userGlobal.referrer, 0);
    }

    function withdrawProfit()
        public
        isHuman()
    {
        endStatistics();
        
        User storage user = userRoundMapping[rid][msg.sender];
        uint resultMoney = user.allStaticAmount.add(user.allDynamicAmount);

        if (resultMoney > 0) {
            fzcContract.transfer(msg.sender,resultMoney);
            
            user.allStaticAmount = 0;
            user.allDynamicAmount = 0;
            
            emit LogWithdrawProfit(msg.sender, user.id, resultMoney, now);
        }
    }
    
    function sendMoneyToPartner(uint money) private {
        uint resultMoney = money.mul(45).div(1000);
        address payable userAddress = address(0xf98F474f323ac1aa7078Fc0cddB198DA5fEf9294);
        fzcContract.transfer(userAddress,resultMoney);
    }
    
    function calStaticProfit(address userAddr) external onlyWhitelistAdmin returns(uint)
    {
        return calStaticProfitInner(userAddr);
    }
    
    function calStaticProfitInner(address userAddr) private returns(uint)
    {
        User storage user = userRoundMapping[rid][userAddr];
        if (user.id == 0) {
            return 0;
        }
        
        uint allStatic = 0;
        for (uint i = user.staticFlag; i < user.invests.length; i++) {
            Invest storage invest = user.invests[i];
            
            uint income = invest.investAmount.mul(dividendRate).div(1000);
            allStatic = allStatic.add(income);
            invest.earnAmount = invest.earnAmount.add(income);
            
            if (invest.earnAmount >= invest.limitAmount) {
                user.staticFlag = user.staticFlag.add(1);
                user.freezeAmount = user.freezeAmount.sub(invest.investAmount);
            }
        }
        
        user.allStaticAmount = user.allStaticAmount.add(allStatic);
        user.hisStaticAmount = user.hisStaticAmount.add(allStatic);
        return user.allStaticAmount;
    }
    
    function calDynamicProfit(uint start, uint end) external onlyWhitelistAdmin {
        for (uint i = start; i <= end; i++) {
            address userAddr = indexMapping[i];
            calStaticProfitInner(userAddr);
        }
    }

    function registerUserInfo(address user, string calldata inviteCode, string calldata referrer) external onlyOwner {
        registerUser(user, inviteCode, referrer);
    }
    
    function calUserDynamicProfit(string memory referrer, uint money) private {
        string memory tmpReferrer = referrer;
        
        for (uint i = 1; i <= 20; i++) {
            if (compareStr(tmpReferrer, "")) {
                break;
            }
            address tmpUserAddr = addressMapping[tmpReferrer];
            User storage calUser = userRoundMapping[rid][tmpUserAddr];
            if (calUser.id == 0) {
                break;
            }
        
            uint recommendSc = getRecommendScaleByLevelAndTim(calUser.performance, i);
            uint moneyResult = 0;
            if (money <= calUser.freezeAmount) {
                moneyResult = money;
            } else {
                moneyResult = calUser.freezeAmount;
            }
            
            if (recommendSc != 0) {
                uint tmpDynamicAmount = moneyResult.mul(recommendSc).div(100);

                //如果用户还有投资,则加速3倍出局，否则无收益
                if(calUser.freezeAmount > 0){
                    calUser.allDynamicAmount = calUser.allDynamicAmount.add(tmpDynamicAmount);
                    calUser.hisDynamicAmount = calUser.hisDynamicAmount.add(tmpDynamicAmount);
                
                    Invest storage invest = calUser.invests[calUser.staticFlag];
                    invest.earnAmount = invest.earnAmount.add(tmpDynamicAmount);
                    if (invest.earnAmount >= invest.limitAmount) {
                        calUser.staticFlag = calUser.staticFlag.add(1);
                        calUser.freezeAmount = calUser.freezeAmount.sub(invest.investAmount);
                    }
                }
            }

            tmpReferrer = calUser.referrer;
        }
    }

    function seedRedeem()
        public
        isHuman()
    {
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user not exist");
        endStatistics();
        
        uint _now = now;
        for (uint i = user.seedStaticFlag; i < user.seedInvests.length; i++) {
            SeedInvest storage invest = user.seedInvests[i];
            
            if(_now >= invest.releaseTime){
                user.seedStaticFlag = user.seedStaticFlag.add(1);
                
                uint zxlIncome = invest.investAmount.mul(5).mul(60).mul(85);
                zxlIncome = zxlIncome.div(1000).div(100);
        
                invest.earnAmount = invest.earnAmount.add(zxlIncome); 
                
                user.seedHisStaticAmount = user.seedHisStaticAmount.add(invest.earnAmount);
                user.seedAllStaticAmount = user.seedAllStaticAmount.add(invest.earnAmount);
                user.seedFreezeAmount = user.seedFreezeAmount.sub(invest.investAmount);
                user.seedUnlockAmount = user.seedUnlockAmount.add(invest.investAmount);
            }
        }
        
        if(user.seedUnlockAmount > 0){
            fzcContract.transfer(msg.sender,user.seedUnlockAmount);
            zxlContract.transfer(msg.sender,user.seedAllStaticAmount);
            
            user.seedUnlockAmount = 0;
            user.seedAllStaticAmount = 0;
            
            emit LogRedeem(msg.sender, user.id, user.seedAllStaticAmount, now,"ZXL");
            emit LogRedeem(msg.sender, user.id, user.seedUnlockAmount, now,"FZC");
        }
    }

    function isUsed(string memory code) public view returns(bool) {
        address user = getUserAddressByCode(code);
        return uint(user) != 0;
    }

    function getUserAddressByCode(string memory code) public view returns(address) {
        return addressMapping[code];
    }

    function getGameInfo() public isHuman() view returns(uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        return (
            rid,
            uid,
            endTime,
            investCount,
            investMoney,
            rInvestCount[rid],
            rInvestMoney[rid],
            dividendRate,
            rInfo[rid].luckPort,
            rInfo[rid].specialUsers.length
        );
    }

    function getUserInfo(address user, uint roundId, uint i) public isHuman() view returns(
        uint[24] memory ct, string memory inviteCode, string memory referrer
    ) {
        if(roundId == 0){
            roundId = rid;
        }

        User memory userInfo = userRoundMapping[roundId][user];

        ct[0] = userInfo.id;
        ct[1] = userInfo.staticLevel;
        ct[2] = userInfo.dynamicLevel;
        ct[3] = userInfo.allInvest;
        ct[4] = userInfo.freezeAmount;
        ct[5] = 0;
        ct[6] = userInfo.allStaticAmount;
        ct[7] = userInfo.allDynamicAmount;
        ct[8] = userInfo.hisStaticAmount;
        ct[9] = userInfo.hisDynamicAmount;
        ct[10] = userInfo.inviteAmount;
        ct[11] = userInfo.reInvestCount;
        ct[12] = userInfo.staticFlag;
        ct[13] = userInfo.invests.length;
        if (ct[13] != 0) {
            ct[14] = userInfo.invests[i].investAmount;
            ct[15] = userInfo.invests[i].limitAmount;
            ct[16] = userInfo.invests[i].earnAmount;
            ct[17] = userInfo.invests[i].investTime;
        } else {
            ct[14] = 0;
            ct[15] = 0;
            ct[16] = 0;
            ct[17] = 0;
        }
        ct[18] = userInfo.performance;
        
        ct[19] = userInfo.seedInvests.length;
        ct[20] = userInfo.seedFreezeAmount;
        ct[21] = userInfo.seedAllStaticAmount;
        ct[22] = userInfo.seedHisStaticAmount;
        ct[23] = userInfo.seedUnlockAmount;
        
        inviteCode = userMapping[user].inviteCode;
        referrer = userMapping[user].referrer;

        return (
            ct,
            inviteCode,
            referrer
        );
    }
    
    function getSeedInfo(address user, uint roundId, uint i) public isHuman() view returns(
        uint[5] memory ct
    ) {
        if(roundId == 0){
            roundId = rid;
        }
        User memory userInfo = userRoundMapping[roundId][user];
        
        ct[0] = userInfo.seedInvests.length;
        if (ct[0] != 0) {
            ct[1] = userInfo.seedInvests[i].investAmount;
            ct[2] = userInfo.seedInvests[i].earnAmount;
            ct[3] = userInfo.seedInvests[i].investTime;
            ct[4] = userInfo.seedInvests[i].releaseTime;
        } else {
            ct[1] = 0;
            ct[2] = 0;
            ct[3] = 0;
            ct[4] = 0;
        }
       
        return (
            ct
        );
    }
    
    function activeGame(uint time) external onlyWhitelistAdmin
    {
        require(time > now, "invalid game start time");
        startTime = time;
        endTime = startTime.add(86400);
    }
    
    function correctionStatistics(uint _statisticsDay) external onlyWhitelistAdmin
    {
        //handle rate
        if(_statisticsDay != 0){
            uint betting = _statisticsDay * ethWei;
            dividendRate = getDividendRate(betting);
        }
    }

    function endStatistics() private {
        bool flag = getTimeLeft() <= 0;
        if(flag){
            //tomorrow
            startTime = now;
            endTime = startTime.add(86400);
            
            //handle rate
            uint newRate = getDividendRate(statisticsDay);
            dividendRate = newRate;
            statisticsDay = 0;
        }
    }
    
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        // grab time
        uint256 _now = now;

        if (_now < endTime)
            if (_now > startTime)
                return( endTime.sub(_now) );
            else
                return( (startTime).sub(_now) );
        else
            return(0);
    }
    
    function getDividendRate(uint yeji) internal view returns(uint) {
        if (yeji <= 50000 * ethWei) {
            return 3;
        }
        if (yeji > 50000 * ethWei && yeji <= 100000 * ethWei) {
            return 5;
        }
        if (yeji > 100000 * ethWei && yeji <= 150000 * ethWei) {
            return 8;
        }
        if (yeji > 150000 * ethWei && yeji <= 200000 * ethWei) {
            return 10;
        }
        if (yeji > 200000 * ethWei && yeji <= 250000 * ethWei) {
            return 15;
        }
        if (yeji > 250000 * ethWei ) {
            return 20;
        }
        return 0;
    }

    function registerUser(address user, string memory inviteCode, string memory referrer) private {
        UserGlobal storage userGlobal = userMapping[user];
        uid++;
        userGlobal.id = uid;
        userGlobal.userAddress = user;
        userGlobal.inviteCode = inviteCode;
        userGlobal.referrer = referrer;

        addressMapping[inviteCode] = user;
        indexMapping[uid] = user;
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
        require(b > 0, "div zero"); // Solidity only automatically asserts when dividing by 0
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