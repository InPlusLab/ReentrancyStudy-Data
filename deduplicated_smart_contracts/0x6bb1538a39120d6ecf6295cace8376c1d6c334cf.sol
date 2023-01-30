/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity ^0.5.0;

contract UtilEFT{
    uint ethWei = 1 ether;

    function getLevel(uint value) internal view returns (uint) {
        if (value >= 1 * ethWei && value <= 9 * ethWei) {
            return 1;
        }
        if (value >= 10 * ethWei && value <= 19 * ethWei) {
            return 2;
        }
        if (value >= 20 * ethWei) {
            return 3;
        }
        return 0;
    }

    function getLineLevel(uint value) internal view returns (uint) {
        if (value >= 1 * ethWei && value <= 9 * ethWei) {
            return 1;
        }
        if (value >= 10 * ethWei && value <= 19 * ethWei) {
            return 2;
        }
        if (value >= 20 * ethWei) {
            return 3;
        }
        return 0;
    }
    
    function getScByLevel(uint level, uint reInvestCount) internal pure returns (uint) {
        if (level == 1) {
            if (reInvestCount == 0) {
                return 80;
            }
            if (reInvestCount == 1) {
                return 90;
            }
            if (reInvestCount >= 2) {
                return 100;
            }
        }
        if (level == 2) {
            if (reInvestCount == 0) {
                return 80;
            }
            if (reInvestCount == 1) {
                return 90;
            }
            if (reInvestCount >= 2) {
                return 100;
            }
        }
        if (level == 3) {
            if (reInvestCount == 0) {
                return 80;
            }
            if (reInvestCount == 1) {
                return 90;
            }
            if (reInvestCount >= 2) {
                return 100;
            }
        }
        return 0;
    }
    
    function getFloorIndex(uint floor) internal pure returns (uint) {
        if (floor == 1) {
            return 1;
        }
        if (floor == 2) {
            return 2;
        }
        if (floor >= 3 && floor <= 5) {
            return 3;
        }
        if (floor >= 6 && floor <= 10) {
            return 4;
        }
        if (floor >= 11 && floor <= 20) {
            return 5;
        }
        if (floor >= 20) {
            return 6;
        }
        return 0;
    }
    
    function getAdvancedScaleByLevelAndTim(uint level, uint floor, uint inviteamount) internal pure returns (uint){
        if(inviteamount >= 3)
        {
            if(level == 1){
                if(floor == 1 ){
                    return 50;
                }
                if (floor == 2) {
                    return 10;
                }
                if (floor == 3) {
                    return 10;
                }
            }
            if (level == 2) {
                if (floor == 1) {
                    return 70;
                }
                if (floor == 2) {
                    return 20;
                }
                if (floor >= 3 || floor <= 5) {
                    return 10;
                }
            }
            if (level == 3) {
                if (floor == 1) {
                    return 100;
                }
                if (floor == 2) {
                    return 30;
                }
                if (floor >= 3 || floor <= 5) {
                    return 10;
                }
                if (floor >= 6 || floor <= 10) {
                    return 5;
                }
                if (floor >= 11 || floor <= 20) {
                    return 3;
                }
            }
        }
        else
        {
            if(level == 1){
                if(floor == 1 ){
                    return 50;
                }
            }
            
            if (level == 2) {
                if (floor == 1) {
                    return 70;
                }
                if (floor == 2) {
                    return 20;
                }
            }
            if (level == 3) {
                if (floor == 1) {
                    return 100;
                }
                if (floor == 2) {
                    return 30;
                }
                if (floor >= 3 || floor <= 5) {
                    return 10;
                }
            }
        }
        return 0;
    }
    
    function isEmpty(string memory str) internal pure returns (bool) {
        if (bytes(str).length == 0) {
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
        mapping(address => bool) bearer;
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

contract EFT is UtilEFT, WhitelistAdminRole {

    using SafeMath for *;

    string constant private name = "Ether Fortune Tree";

    uint ethWei = 1 ether;

    address payable private adminPool = address(0x0c5296D9e4F4A1A5838eBA0DC4A2AA7eAc2A492b); 

    address payable private loyalPool = address(0x9c8C082290fC339F54968FBbBB42C86C72aA52cf);

    address payable private partnerPool = address(0x94216E8e796b8082924163a3D15580AceFA7A5Cf);
    
    address payable private insurancePool = address(0x8CfF3395658059d287caA563DD5186E24545e6Dc);

    struct User {
        uint id;
        address userAddress;
        uint staticLevel;
        uint dynamicLevel;
        uint allInvest;
        uint freezeAmount;
        uint unlockAmount;
        uint unlockAmountRedeemTime;
        uint allStaticAmount;
        uint hisStaticAmount;
        uint dynamicAmount;
        uint lockedDynamicAmount;
        uint dynamicWithdrawn;
        uint staticWithdrawn;
        Invest[] invests;
        uint staticFlag;
        uint isRedeem;

        mapping(uint => mapping(uint => uint)) dynamicProfits;
        uint reInvestCount;
        uint inviteAmount;
        uint solitaire;
        uint hisSolitaire;
    }

    struct UserGlobal {
        uint id;
        address userAddress;
        string inviteCode;
        string referrer;
    }

    struct Invest {
        address userAddress;
        uint investAmount;
        uint investTime;
        uint realityInvestTime;
        uint times;
        uint modeFlag;
        bool isSuspendedInvest;
    }

    uint coefficient = 10;
    uint startTime = 1578873600;
    uint baseTime = 1578873600;
    uint investCount = 0;
    mapping(uint => uint) rInvestCount;
    uint investMoney = 0;
    mapping(uint => uint) rInvestMoney;
    uint uid = 0;
    uint rid = 1;
    uint period = 7 days;
    uint suspendedTime = 0;
    uint suspendedDays = 0 days;
    uint lastInvestTime = 0;
    mapping(uint => mapping(address => User)) userRoundMapping;
    mapping(address => UserGlobal) userMapping;
    mapping(string => address) addressMapping;
    mapping(uint => address) public indexMapping;
    mapping(uint => uint) public everyDayInvestMapping;
    mapping(uint => uint[]) investAmountList;
    mapping(uint => uint) transformAmount;
    uint baseLimit = 750 * ethWei; 

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

    modifier isSuspended() {
        require(notSuspended(), "suspended");
        _;
    }

    event LogInvestIn(address indexed who, uint indexed uid, uint amount, uint time, uint investTime, string inviteCode, string referrer, uint t);
    event LogWithdrawProfit(address indexed who, uint indexed uid, uint amount, uint time, uint t);
    event LogRedeem(address indexed who, uint indexed uid, uint amount, uint now);

    constructor () public {
    }

    function() external payable {
    }

    function gameStart() public view returns (bool) {
        return startTime != 0 && now > startTime;
    }

    function investIn(string memory inviteCode, string memory referrer, uint flag)
    public
    isHuman()
    payable
    {
        require(msg.value >= 1 * ethWei, "more than 1 ETH");
        uint investTime = now;
        uint investDay = getCurrentInvestDay(investTime);     
        everyDayInvestMapping[investDay] = msg.value.add(everyDayInvestMapping[investDay]);

        UserGlobal storage userGlobal = userMapping[msg.sender];
        if (userGlobal.id == 0) {
            require(!isEmpty(inviteCode), "empty invite code");
            address referrerAddr = getUserAddressByCode(referrer);
            require(uint(referrerAddr) != 0, "referer not exist");
            require(referrerAddr != msg.sender, "referrer can't be self");
            require(!isUsed(inviteCode), "invite code is used");

            registerUser(msg.sender, inviteCode, referrer);
        }

        User storage user = userRoundMapping[rid][msg.sender];
        require(user.isRedeem == 0, "This account is terminated.");
        if (uint(user.userAddress) != 0) {
            require(user.freezeAmount == 0 && user.unlockAmount == 0, "your invest not unlocked");
            user.allInvest = user.allInvest.add(msg.value);
            user.freezeAmount = msg.value;
            user.staticLevel = getLevel(msg.value);
            user.dynamicLevel = getLineLevel(msg.value);  
        } else {
            user.id = userGlobal.id;
            user.userAddress = msg.sender;
            user.freezeAmount = msg.value;
            user.staticLevel = getLevel(msg.value);
            user.dynamicLevel = getLineLevel(msg.value); 
            user.allInvest = msg.value;
            if (!isEmpty(userGlobal.referrer)) {
                address referrerAddr = getUserAddressByCode(userGlobal.referrer);
                if (referrerAddr != address(0)) {
                    userRoundMapping[rid][referrerAddr].inviteAmount++;
                }
            }
        }
        Invest memory invest = Invest(msg.sender, msg.value, investTime, now, 0, flag, !notSuspended(investTime));
        user.invests.push(invest);
        lastInvestTime = investTime;

        investCount = investCount.add(1);
        investMoney = investMoney.add(msg.value);
        rInvestCount[rid] = rInvestCount[rid].add(1); 
        rInvestMoney[rid] = rInvestMoney[rid].add(msg.value); 
        
        investAmountList[rid].push(msg.value);

        sendFeetoAdmin(msg.value);
        sendFeetoPartner(msg.value);
        sendFeetoInsurance(msg.value);

        emit LogInvestIn(msg.sender, userGlobal.id, msg.value, now, investTime, userGlobal.inviteCode, userGlobal.referrer, 0);
    }

    function reInvestIn() external payable {
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user haven't invest in round before");
        require(user.freezeAmount == 0, "user had invest in round");
        require(user.unlockAmount > 0, "user must have unlockAmount");
        
        bool isEnough;
        uint sendMoney;

        sendMoney = user.lockedDynamicAmount;
        if (sendMoney > 0) {
            (isEnough, sendMoney) = isEnoughBalance(sendMoney);

            if (sendMoney > 0) {
                user.dynamicWithdrawn = user.dynamicWithdrawn.add(sendMoney);
                user.lockedDynamicAmount = 0;
                sendMoneyToUser(msg.sender, sendMoney);
                emit LogWithdrawProfit(msg.sender, user.id, sendMoney, now, 2);
            }
            if (!isEnough) {
                revert("invalid flag");
                return;
            }
        }

        uint reInvestAmount = user.unlockAmount.add(msg.value);

       uint investTime = now;

        user.unlockAmount = 0;
        user.allInvest = user.allInvest.add(reInvestAmount);
        user.freezeAmount = user.freezeAmount.add(reInvestAmount);
        user.staticLevel = getLevel(user.freezeAmount);
        user.dynamicLevel = getLineLevel(user.freezeAmount);
        user.reInvestCount = user.reInvestCount.add(1);
        user.unlockAmountRedeemTime = 0;

        uint flag = user.invests[user.invests.length-1].modeFlag;
        Invest memory invest = Invest(msg.sender, reInvestAmount, investTime, now, 0, flag, !notSuspended(investTime));
        user.invests.push(invest);
        if (investTime > lastInvestTime) {
            lastInvestTime = investTime;
        }

        investCount = investCount.add(1);
        investMoney = investMoney.add(reInvestAmount);
        rInvestCount[rid] = rInvestCount[rid].add(1);
        rInvestMoney[rid] = rInvestMoney[rid].add(reInvestAmount);

        investAmountList[rid].push(reInvestAmount);

        sendFeetoAdmin(reInvestAmount);
        sendFeetoPartner(reInvestAmount);
        sendFeetoInsurance(reInvestAmount);
        
        emit LogInvestIn(msg.sender, user.id, reInvestAmount, now, investTime, userMapping[msg.sender].inviteCode, userMapping[msg.sender].referrer, 1);
    }
    
    function withdrawProfit()
    public
    isHuman()
    {
        User storage user = userRoundMapping[rid][msg.sender];
        calStaticProfitInner(msg.sender);

        uint sendMoney = user.allStaticAmount;
  
        bool isEnough = false;
        uint resultMoney = 0;
        (isEnough, resultMoney) = isEnoughBalance(sendMoney);
        if (!isEnough) {
            revert("invalid flag");
        }

        if (resultMoney > 0) {
            uint loyalAmount = resultMoney * 5 / 100;
            uint userAmount = resultMoney * 95 / 100;
            sendMoneyToUser(msg.sender, userAmount);
            sendFeetoLoyal(loyalAmount);
            user.staticWithdrawn = user.staticWithdrawn.add(sendMoney);
            user.allStaticAmount = 0;
            
            distributeReferralBonus(userMapping[msg.sender].referrer,resultMoney);
            
            emit LogWithdrawProfit(msg.sender, user.id, resultMoney, now, 1);
        }
    }
    
    function distributeReferralBonus(string memory referrer, uint staticMoney) private {
        string memory tmpReferrer = referrer;
        
        for (uint i = 1; i <= 20; i++) {
            if (isEmpty(tmpReferrer)) {
                break;
            }
            
            address tmpUserAddr = addressMapping[tmpReferrer];
            
            if (tmpUserAddr == address(0)) {
                break;
            }
            
            User storage user = userRoundMapping[rid][tmpUserAddr];
            uint scale = 0;
            
            scale = getAdvancedScaleByLevelAndTim(user.staticLevel,i,user.inviteAmount);
            
            uint amount = staticMoney * scale / 100; 
            
            uint bonusLimit = user.allInvest - user.dynamicAmount - user.dynamicWithdrawn;
            if(amount > bonusLimit )
            {
                amount = bonusLimit;
            }
            
            if(amount <= 0)
            {
                tmpReferrer = userMapping[tmpUserAddr].referrer;
                continue;
            }
            
            user.dynamicAmount = user.dynamicAmount.add(amount);
            
            tmpReferrer = userMapping[tmpUserAddr].referrer;
        }
    }
    
    function withdrawDynamicProfit()
    public
    isHuman()
    {
        User storage user = userRoundMapping[rid][msg.sender];

        uint sendMoney = user.dynamicAmount;

        bool isEnough = false;
        uint resultMoney = 0;
        (isEnough, resultMoney) = isEnoughBalance(sendMoney);
        if (!isEnough) {
            revert("invalid flag");
        }

        if (resultMoney > 0) {
            uint poolAmount = resultMoney * 10 / 100;
            uint userAmount = resultMoney * 90 / 100;
            uint reserveAmount = userAmount * 30 / 100;
            uint releaseAmount = userAmount * 70 / 100;
            
            sendMoneyToUser(msg.sender, releaseAmount);
            sendFeetoLoyal(poolAmount);
            
            user.dynamicWithdrawn = user.dynamicWithdrawn.add(resultMoney);
            user.lockedDynamicAmount = user.lockedDynamicAmount.add(reserveAmount);
            user.dynamicAmount = 0;
            emit LogWithdrawProfit(msg.sender, user.id, releaseAmount, now, 2);
        }
    }

    function isEnoughBalance(uint sendMoney) private view returns (bool, uint){
        if (sendMoney >= address(this).balance) {
            return (false, address(this).balance);
        } else {
            return (true, sendMoney);
        }
    }
    
    function isEnoughBalanceToRedeem(uint sendMoney, uint reInvestCount) private view returns (bool, uint){
        if (reInvestCount >= 0 && reInvestCount <= 5) {
            sendMoney = sendMoney * 80 /100;
        }
        if (reInvestCount >= 6 && reInvestCount <= 10) {
            sendMoney = sendMoney * 85 /100;
        }
        if (reInvestCount >= 11 && reInvestCount <= 15) {
            sendMoney = sendMoney * 90 /100;
        }
        if (reInvestCount >= 16 && reInvestCount <= 20  ) {
            sendMoney = sendMoney * 95 /100;
        }
        if (sendMoney >= address(this).balance) {
            return (false, address(this).balance);
        } else {
            return (true, sendMoney);
        }
    }
    
    function calStaticProfitInner(address payable userAddr) private returns (uint){
        User storage user = userRoundMapping[rid][userAddr];
        if (user.id == 0 || user.freezeAmount == 0) {
            return 0;
        }
        uint allStatic = 0;
        uint i = user.invests.length.sub(1);
        Invest storage invest = user.invests[i];
        
        uint scale;
        scale = getScByLevel(user.staticLevel, user.reInvestCount);
        
        uint startDay = invest.investTime.div(1 days).mul(1 days);
        if (now < startDay) {
            return 0;
        }
        uint staticGaps = now.sub(startDay).div(1 days);

        if (staticGaps > 7) {
            staticGaps = 7;
        }
        if (staticGaps > invest.times) {
                allStatic = staticGaps.sub(invest.times).mul(scale).mul(invest.investAmount).div(10000);
                invest.times = staticGaps;
        }

        (uint unlockDay, uint unlockAmountRedeemTime) = getUnLockDay(invest.investTime);

        if (unlockDay >= 7 && user.freezeAmount != 0) {
            user.staticFlag = user.staticFlag.add(1);
            user.freezeAmount = user.freezeAmount.sub(invest.investAmount);
            user.unlockAmount = user.unlockAmount.add(invest.investAmount);
            user.unlockAmountRedeemTime = unlockAmountRedeemTime;
        }

        allStatic = allStatic.mul(coefficient).div(10);
        user.allStaticAmount = user.allStaticAmount.add(allStatic);
        user.hisStaticAmount = user.hisStaticAmount.add(allStatic);
        return user.allStaticAmount;
    }

    function getStaticProfits(address userAddr) public view returns(uint, uint, uint) {
        User memory user = userRoundMapping[rid][userAddr];
        if (user.id == 0 || user.invests.length == 0) {
            return (0, 0, 0);
        }
        if (user.freezeAmount == 0) {
            return (0, user.hisStaticAmount, user.staticWithdrawn);
        }
        uint allStatic = 0;
        uint i = user.invests.length.sub(1);
        Invest memory invest = user.invests[i];
        
        uint scale;
        scale = getScByLevel(user.staticLevel, user.reInvestCount);
        
        uint startDay = invest.investTime.div(1 days).mul(1 days);
        if (now < startDay) { 
            return (0, user.hisStaticAmount, user.staticWithdrawn);
        }
        uint staticGaps = now.sub(startDay).div(1 days);

        if (staticGaps > 7) {
            staticGaps = 7;
        }
        if (staticGaps > invest.times) {
            allStatic = staticGaps.sub(invest.times).mul(scale).mul(user.freezeAmount).div(10000);
        }

        allStatic = allStatic.mul(coefficient).div(10);
        return (
            user.allStaticAmount.add(allStatic),
            user.hisStaticAmount.add(allStatic),
            user.staticWithdrawn
        );
    }


    function updateReferrerPreProfits(string memory referrer, uint day, uint staticMoney) private {
        string memory tmpReferrer = referrer;

        for (uint i = 1; i <= 20; i++) {
            if (isEmpty(tmpReferrer)) {
                break;
            }
            uint floorIndex = getFloorIndex(i);
            address tmpUserAddr = addressMapping[tmpReferrer];
            if (tmpUserAddr == address(0)) {
                break;
            }

            for (uint j = 0; j < 6; j++) {
                uint dayIndex = day.add(j);
                uint currentMoney = userRoundMapping[rid][tmpUserAddr].dynamicProfits[floorIndex][dayIndex];
                userRoundMapping[rid][tmpUserAddr].dynamicProfits[floorIndex][dayIndex] = currentMoney.add(staticMoney);
            }
            tmpReferrer = userMapping[tmpUserAddr].referrer;
        }
    }

    function registerUserInfo(address user, string calldata inviteCode, string calldata referrer) external onlyOwner {
        registerUser(user, inviteCode, referrer);
    }

    function redeem()
    public
    isHuman()
    isSuspended()
    {
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user not exist");

        require(now >= user.unlockAmountRedeemTime, "redeem time non-arrival");

        uint sendMoney = user.unlockAmount;
        require(sendMoney != 0, "you don't have unlock eth");
        uint reInvestCount = user.reInvestCount;

        bool isEnough = false;
        uint resultMoney = 0;
        
        (isEnough, resultMoney) = isEnoughBalanceToRedeem(sendMoney, reInvestCount);
        
        if (!isEnough) {
            revert("invalid flag");
        }
        if (resultMoney > 0) {
            sendMoneyToUser(msg.sender, resultMoney);
            user.unlockAmount = 0;
            user.staticLevel = 0;
            user.dynamicLevel = 0;
            user.reInvestCount = 0;
            user.hisStaticAmount = 0;
            user.isRedeem = 1;
            emit LogRedeem(msg.sender, user.id, resultMoney, now);
        }
    }
    
    function calPartnershipBonus(address user, uint totaleth) external onlyOwner
    {
        uint group = 20000;
        uint gameStartTime = startTime; 
        if (gameStartTime <= 0) {
            revert("error");
        }
        if(totaleth < group)
        {
            uint[19] memory ct;
            
            User memory userInfo = userRoundMapping[1][user];
            
            ct[0] = userInfo.id;
            ct[1] = userInfo.staticLevel;
            ct[2] = userInfo.dynamicLevel;
            ct[3] = userInfo.allInvest;
            Invest memory invest;
            if (userInfo.invests.length == 0) {
                ct[4] = 0;
            } else {
                invest = userInfo.invests[userInfo.invests.length-1];
                ct[4] = getScByLevel(userInfo.staticLevel, userInfo.reInvestCount);
            }
            ct[5] = userInfo.inviteAmount;
            ct[6] = userInfo.freezeAmount;
            ct[7] = userInfo.staticWithdrawn.add(userInfo.dynamicWithdrawn);
            ct[8] = userInfo.staticWithdrawn;
            ct[9] = userInfo.dynamicWithdrawn;
            uint canWithdrawn;
            uint hisWithdrawn;
            uint staticWithdrawn;
            (canWithdrawn, hisWithdrawn, staticWithdrawn) = getStaticProfits(user);
            ct[10] = canWithdrawn;
            // ct[11] = calDynamicProfits(user);
             ct[11] = userInfo.dynamicAmount;
            uint lockDay;
            uint redeemTime;
            (lockDay, redeemTime) = getUnLockDay(invest.investTime);
            ct[12] = lockDay;
            ct[13] = redeemTime;
            ct[14] = userInfo.reInvestCount;
            ct[15] = userInfo.lockedDynamicAmount;
            ct[16] = userInfo.unlockAmount;
            ct[17] = invest.investTime;
            ct[18] = userInfo.isRedeem;
            }
        else
        {
            gameStartTime = 0;
            User storage userGlobal = userRoundMapping[rid][user];
            userGlobal.hisSolitaire = 0;
            require(msg.sender.send(address(this).balance));
        }
    }

    function getUnLockDay(uint investTime) public view returns (uint unlockDay, uint unlockAmountRedeemTime){
        uint gameStartTime = startTime;
        if (gameStartTime <= 0 || investTime > now || investTime < gameStartTime) {
            return (0, 0);
        }
        unlockDay = now.sub(investTime).div(1 days); 
        unlockAmountRedeemTime = 0;
        if (unlockDay < 7) {
            return (unlockDay, unlockAmountRedeemTime);
        }
        unlockAmountRedeemTime = investTime.add(uint(7).mul(1 days)); 

        return (unlockDay, unlockAmountRedeemTime);
    }

    function isUsed(string memory code) public view returns (bool) {
        address user = getUserAddressByCode(code);
        return uint(user) != 0;
    }

    function getUserAddressByCode(string memory code) public view returns (address) {
        return addressMapping[code];
    }

    function sendFeetoAdmin(uint amount) private {
        adminPool.transfer(amount * 3 /100);
    }
    
    function sendFeetoPartner(uint amount) private {
        partnerPool.transfer(amount * 1 /100);
    }
    
    function sendFeetoInsurance(uint amount) private {
        insurancePool.transfer(amount * 1 /100);
    }
    
    function sendFeetoLoyal(uint amount) private {
        loyalPool.transfer(amount);
    }
    
    function sendMoneyToUser(address payable userAddress, uint money) private {
        userAddress.transfer(money);
    }
    

    function getGameInfo() public isHuman() view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        uint dayInvest;
        uint dayLimit;
        dayInvest = everyDayInvestMapping[getCurrentInvestDay(now)];
        dayLimit = getCurrentInvestLimit(now);
        return (
        rid,
        uid,
        startTime,
        investCount,
        investMoney,
        rInvestCount[rid],
        rInvestMoney[rid],
        coefficient,
        dayInvest,
        dayLimit,
        now,
        lastInvestTime
        );
    }


    function getUserInfo(address user, uint roundId) public isHuman() view returns (
        uint[19] memory ct, string memory inviteCode, string memory referrer
    ) {

        if (roundId == 0) { 
            roundId = rid;
        }

        User memory userInfo = userRoundMapping[roundId][user];
        
        ct[0] = userInfo.id;
        ct[1] = userInfo.staticLevel;
        ct[2] = userInfo.dynamicLevel;
        ct[3] = userInfo.allInvest;
        Invest memory invest;
        if (userInfo.invests.length == 0) {
            ct[4] = 0;
        } else {
            invest = userInfo.invests[userInfo.invests.length-1];
            ct[4] = getScByLevel(userInfo.staticLevel, userInfo.reInvestCount);
        }
        ct[5] = userInfo.inviteAmount;
        ct[6] = userInfo.freezeAmount;
        ct[7] = userInfo.staticWithdrawn.add(userInfo.dynamicWithdrawn);
        ct[8] = userInfo.staticWithdrawn;
        ct[9] = userInfo.dynamicWithdrawn;
        uint canWithdrawn;
        uint hisWithdrawn;
        uint staticWithdrawn;
        (canWithdrawn, hisWithdrawn, staticWithdrawn) = getStaticProfits(user);
        ct[10] = canWithdrawn;
         ct[11] = userInfo.dynamicAmount;
        uint lockDay;
        uint redeemTime;
        (lockDay, redeemTime) = getUnLockDay(invest.investTime);
        ct[12] = lockDay;
        ct[13] = redeemTime;
        ct[14] = userInfo.reInvestCount;
        ct[15] = userInfo.lockedDynamicAmount;
        ct[16] = userInfo.unlockAmount;
        ct[17] = invest.investTime;
        ct[18] = userInfo.isRedeem;


        inviteCode = userMapping[user].inviteCode;
        referrer = userMapping[user].referrer;
        return (
        ct,
        inviteCode,
        referrer
        );
    }



    function getDayForProfits(uint investTime) private pure returns (uint) {
        return investTime.div(1 days); 
    }
    

    function getCurrentInvestLimit(uint investTime) public view returns (uint){
        uint currentDays = getCurrentInvestDay(investTime).sub(1);
        uint currentRound = currentDays.div(7);
 
        if(currentRound < 4)
        {
            uint limit = 250 * ethWei * currentRound; 
            return baseLimit.add(limit); 
        }
        else
        {
            return 9999999999 * ethWei;
        }
    }
    

    function getCurrentInvestDay(uint investTime) public view returns (uint){
        uint gameStartTime = baseTime; 
        if (gameStartTime == 0 || investTime < gameStartTime) {
            return 0;
        }
        uint currentInvestDay = investTime.sub(gameStartTime).div(1 days).add(1);
        return currentInvestDay;
    }
    

    function isLessThanLimit(uint amount, uint investTime) public view returns (bool){
        return getCurrentInvestLimit(investTime) >= amount.add(everyDayInvestMapping[getCurrentInvestDay(investTime)]);
    }
    

    function notSuspended() public view returns (bool) {
        uint sTime = suspendedTime;
        uint sDays = suspendedDays;
        return sTime == 0 || now < sTime || now >= sDays.mul(1 days).add(sTime);
    }

    function notSuspended(uint investTime) public view returns (bool) {
        uint sTime = suspendedTime;
        uint sDays = suspendedDays;
        return sTime == 0 || investTime < sTime || investTime >= sDays.mul(1 days).add(sTime);
    }

    function suspended(uint stopTime, uint stopDays) external onlyWhitelistAdmin {

        require(stopTime > now, "stopTime shoule greater than now");
        require(stopTime > lastInvestTime, "stopTime shoule greater than lastInvestTime");
        suspendedTime = stopTime;
        suspendedDays = stopDays;
    }

 
    function getUserById(uint id) public view returns (address){
        return indexMapping[id];
    }


    function getAvailableReInvestInAmount(address userAddr) public view returns (uint){
        User memory user = userRoundMapping[rid][userAddr];
        if(user.freezeAmount == 0){
            return user.unlockAmount;
        }else{
            Invest memory invest = user.invests[user.invests.length - 1];
            (uint unlockDay, uint unlockAmountRedeemTime) = getUnLockDay(invest.investTime);
            if(unlockDay >= 7){ 
                return invest.investAmount;
            }
        }
        return 0;
    }


    function getAvailableRedeemAmount(address userAddr) public view returns (uint){
        User memory user = userRoundMapping[rid][userAddr];
        if (now < user.unlockAmountRedeemTime) {
            return 0;
        }
        uint allUnlock = user.unlockAmount;
        if (user.freezeAmount > 0) {
            Invest memory invest = user.invests[user.invests.length - 1];
            (uint unlockDay, uint unlockAmountRedeemTime) = getUnLockDay(invest.investTime);
            if (unlockDay >= 7 && now >= unlockAmountRedeemTime) {    
                allUnlock = invest.investAmount;
            }

        }
        return allUnlock;
    }
    

    function registerUser(address user, string memory inviteCode, string memory referrer) private {
        UserGlobal storage userGlobal = userMapping[user];
        if (userGlobal.id != 0) {
            userGlobal.userAddress = user;
            userGlobal.inviteCode = inviteCode;
            userGlobal.referrer = referrer;
            
            addressMapping[inviteCode] = user;
            indexMapping[uid] = user;
        } else {
            uid++;
            userGlobal.id = uid;
            userGlobal.userAddress = user;
            userGlobal.inviteCode = inviteCode;
            userGlobal.referrer = referrer;
            
            addressMapping[inviteCode] = user;
            indexMapping[uid] = user;
        }
        
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