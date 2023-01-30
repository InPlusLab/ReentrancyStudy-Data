/**
 *Submitted for verification at Etherscan.io on 2019-12-10
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

pragma solidity ^0.4.26;


contract UtilGameFair {
    uint ethWei = 1 ether;

    //����Ͷע����ѯ��Ա�ȼ�
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

    //��÷�Ӷ���߲㼶��,3����
    function getLineLevel(uint value) public view returns (uint) {
        if (value >= 1 * ethWei && value <= 5 * ethWei) {//1-5=1������
            return 1;
        }
        if (value >= 6 * ethWei && value <= 10 * ethWei) {//6-10=2������
            return 2;
        }
        if (value >= 11 * ethWei) {//>=11=���޴�����
            return 3;
        }
        return 0;
    }

    //���ݻ�Ա�ȼ���ѯ�ֺ�ϵ��
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

    //�������˵ȼ�ϵ��
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

    //�Ƽ��˽���ϵͳ
    function getRecommendScaleByLevelAndTim(uint level, uint times) public pure returns (uint){
        if (level == 1 && times == 1) {//v1,1���¼�����50%
            return 50;
        }
        if (level == 2 && times == 1) {//v2,1���¼�����70%
            return 70;
        }
        if (level == 2 && times == 2) {//v2,2������50%
            return 50;
        }
        if (level == 3) {
            if (times == 1) {//v3,1������100%
                return 100;
            }
            if (times == 2) {//v3,2������70%
                return 70;
            }
            if (times == 3) {//v3,3������50%
                return 50;
            }
            if (times >= 4 && times <= 10) {//v3,4-10������10%
                return 10;
            }
            if (times >= 11 && times <= 20) {//v3,11-20������5%
                return 5;
            }
            if (times >= 21) {//v3,21���Ժ���1%
                return 1;
            }
        }
        return 0;
    }

    //�Ƚ��ַ����Ƿ����
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

    //���غ�Լ�����˵�ַ
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    //���غ�Լ���÷��͵�����
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
    //��Լ������
    address private _owner;

    //�����Լ�������¼�
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        //��Լ����ʱָ����Լ������Ϊ������
        _owner = _msgSender();
        //�����¼���־
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     * ���ص�ǰ��Լ�����˵�ַ
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * �����޸������ж��Ƿ�Ϊ��Լ�����˵���
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     * ���غ�Լ�������Ƿ�Ϊ��Լ������
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
     * ������Լ����Ȩ
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * ת�ú�Լ����Ȩ
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
    //��ɫӳ���
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     * ��ӽ�ɫȨ��
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     * ɾ����ɫȨ��
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     * �ж��Ƿ��н�ɫȨ��
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 * ����������Ա��ɫ
 */
contract WhitelistAdminRole is Context, Ownable {
    using Roles for Roles.Role;

    //����������¼�
    event WhitelistAdminAdded(address indexed account);
    //�Ƴ��������¼�
    event WhitelistAdminRemoved(address indexed account);

    //����������Ա����
    Roles.Role private _whitelistAdmins;

    constructor () internal {
        //��Լ����ʱ�������˼��������
        _addWhitelistAdmin(_msgSender());
    }

    //�ж��Ƿ�Ϊ����������Ա�ĺ����޸���
    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(_msgSender()) || isOwner(), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    //�ж��Ƿ�Ϊ����������Ա
    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    //��Ӱ���������Ա
    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    //�Ƴ�����������Ա
    function removeWhitelistAdmin(address account) public onlyOwner {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }

    //��������������Ա���
    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(_msgSender());
    }

    //��Ӱ���������Ա
    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    //�Ƴ�����������Ա
    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

//��Ϸ��
contract GameFair is UtilGameFair, WhitelistAdminRole {

    using SafeMath for *;

    string constant private name = "GameFair Official";

    uint ethWei = 1 ether;

    //ר���ʻ�
    address  private devAddr = address(0xb61f5A335acB482c23Af25e76D7c7b3FEA873059);

    //�غ��û�ʵ��
    struct User {
        uint id;//�û�id
        address userAddress;//�û�Ǯ����ַ
        string inviteCode;//������
        string referrer;//�Ƽ���
        uint staticLevel;//��̬�ȼ�
        uint dynamicLevel;//��̬�ȼ�
        uint allInvest;//ȫ��Ͷע���
        uint freezeAmount;//������
        uint unlockAmount;//�������
        uint allStaticAmount;//ȫ���ֺ�������
        uint allDynamicAmount;//ȫ���ڵ㽱�����
        uint hisStaticAmount;//���ľ�̬���
        uint hisDynamicAmount;//���Ķ�̬���
        Invest[] invests;//Ͷע�б�
        SeizeInvest[] seizesInvests;//��ע
        uint votes;//����ͶƱ��
        uint staticFlag;//Ͷע�ֺ��±�
    }

    //�û�������Ϣ
    struct UserGlobal {
        uint id;//�û�id
        address userAddress;//�û�Ǯ����ַ
        string inviteCode;//������
        string referrer;//�Ƽ���
        uint inviteCount;//������������
    }

    //Ͷע
    struct Invest {
        address userAddress;//�û���ַ
        uint investAmount;//Ͷע���
        uint investTime;//Ͷעʱ��
        uint times;//��������
    }

    //��ע
    struct SeizeInvest {
        uint rid;
        address userAddress;
        uint seizeAmount;
        uint seizeTime;
    }

    //ϵͳ��,û�õ�
    string constant systemCode = "99999999";
    //��ʼʱ��
    uint startTime;
    //��Ͷע����
    uint investCount = 0;
    //�غ�Ͷע����ӳ���
    mapping(uint => uint) rInvestCount;
    //��Ͷע���
    uint investMoney = 0;
    //�غ�Ͷע��ӳ���
    mapping(uint => uint) rInvestMoney;
    //�û����ʲ�
    uint userAssets = 0;

    //�û���ʼid
    uint uid = 0;
    //�غ���
    uint rid = 1;
    //��Ϸ������������ʱ��
    uint period = 6 hours;

    //��ʼͶƱ��ֵ80%��60%��40%��20%
    uint voteStartSc = 80;

    //��Ϸ״̬,1��Ϸ�У�2ͶƱ��
    uint gameStatus = 1;

    //��ϷͶƱ����ʱ��
    uint voteEndTime = 0;
    //��ע����ʱ��
    uint seizeEndTime = 0;

    //ͶƱ���������/����
    uint[] voteResult = [0, 0];
    //�����ע��ַ
    mapping(uint => SeizeInvest) lastSeizeInvest;

    //�û��غ�ӳ��
    mapping(uint => mapping(address => User)) userRoundMapping;
    //��ַ->�û�ӳ��
    mapping(address => UserGlobal) userMapping;
    //������->��ַӳ��
    mapping(string => address) addressMapping;
    //�û��б�ӳ��(����)
    mapping(uint => address) public indexMapping;

    //�Ƿ���Ϊ����������Ϊ��Լ����
    modifier isHuman() {
        address addr = msg.sender;
        uint codeLength;

        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        require(tx.origin == msg.sender, "sorry, human only");
        _;
    }

    //Ͷע�¼�
    event LogInvestIn(address indexed who, uint indexed uid, uint amount, uint time, string inviteCode, string referrer);
    //��ȡ�����¼�
    event LogWithdrawProfit(address indexed who, uint indexed uid, uint amount, uint time);
    //����¼�
    event LogRedeem(address indexed who, uint indexed uid, uint amount, uint now);
    //��ʼͶƱ�¼�
    event VoteStart(uint startTime, uint endTime);
    //��ע�¼�
    event SeizeInvestNow(address indexed who, uint indexed uid, uint amount, uint now);

    //������Լ��ʼ������
    constructor () public {
        startTime = now;
    }

    function() external payable {
    }

    //��Ϸ�Ƿ�ʼ
    function gameStart() public view returns (bool) {
        return startTime != 0 && now > startTime && gameStatus == 1;
    }

    /**
    *Ͷע��inviteCode �����룬referrer�����˵�ַ
    */
    function investIn(string memory inviteCode, string memory referrer) public isHuman() payable {
        //�ж���Ϸ�Ƿ�ʼ
        require(now > startTime && gameStatus == 1, "invest is not allowed now");
        //�ж�Ͷע����Ƿ�Ϸ�
        require(msg.value >= 1 * ethWei && msg.value <= 15 * ethWei, "between 1 and 15");
        require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");

        UserGlobal storage userGlobal = userMapping[msg.sender];
        //��ȡͶעUserʵ��
        if (userGlobal.id == 0) {//���δͶע��
            //�ж��������Ƿ�Ϊ��
            require(!compareStr(inviteCode, ""), "empty invite code");
            //�����˵�ַ
            address referrerAddr = getUserAddressByCode(referrer);
            //�ж��������Ƿ����
            require(uint(referrerAddr) != 0, "referer not exist");
            //�Լ����������Լ�
            require(referrerAddr != msg.sender, "referrer can't be self");
            //�Լ����������Ƿ��ظ�
            require(!isUsed(inviteCode), "invite code is used");
            //���û�ע��
            registerUser(msg.sender, inviteCode, referrer);
        }

        //��ǰ�غ������û�ӳ��
        User storage user = userRoundMapping[rid][msg.sender];
        if (uint(user.userAddress) != 0) {//��ǰ�غϷǵ�һ��Ͷע
            //�жϵ�ǰ�غ϶�����+����Ͷע����Ƿ񳬹�15eth
            require(user.freezeAmount.add(msg.value) <= 15 * ethWei, "can not beyond 15 eth");
            //�ۼӵ�ǰ�غ�Ͷע
            user.allInvest = user.allInvest.add(msg.value);
            //�ۼӵ�ǰ�غ϶�����
            user.freezeAmount = user.freezeAmount.add(msg.value);
            //���õ�ǰ��̬�ȼ�
            user.staticLevel = getLevel(user.freezeAmount);
            //���õ�ǰ��̬�ȼ�
            user.dynamicLevel = getLineLevel(user.freezeAmount.add(user.unlockAmount));
        } else {//��ǰ�غϵ�һ��Ͷע
            user.id = userGlobal.id;
            user.userAddress = msg.sender;
            user.freezeAmount = msg.value;
            user.staticLevel = getLevel(msg.value);
            user.allInvest = msg.value;
            user.dynamicLevel = getLineLevel(msg.value);
            user.inviteCode = userGlobal.inviteCode;
            user.referrer = userGlobal.referrer;
        }

        //����Ͷעʵ��
        Invest memory invest = Invest(msg.sender, msg.value, now, 0);
        //�����û�Ͷע����
        user.invests.push(invest);
        user.votes += (msg.value.div(ethWei));

        //�ۼ���Ͷע����
        investCount = investCount.add(1);
        //�ۼ���Ͷע���
        investMoney = investMoney.add(msg.value);
        //�ۼƱ���Ͷע����
        rInvestCount[rid] = rInvestCount[rid].add(1);
        //�ۼƱ���Ͷע���
        rInvestMoney[rid] = rInvestMoney[rid].add(msg.value);
        //�ۼ��û����ʲ�
        userAssets += msg.value;
        //��ר���ʻ����4%
        sendFeetoAdmin(msg.value);
        //����Ͷע�¼���־
        emit LogInvestIn(msg.sender, userGlobal.id, msg.value, now, userGlobal.inviteCode, userGlobal.referrer);
    }

    //ͶƱ�ڼ���ע
    function seizeInvest(string memory inviteCode) public isHuman() payable {
        //�ж���ע�Ƿ�ʼ
        require(seizeEndTime > now, "seize invest not start");
        require(!compareStr(inviteCode, ""), "empty invite code");
        //�ж���ע����Ƿ�Ϸ�
        require(msg.value >= 1 * ethWei && msg.value <= 15 * ethWei, "between 1 and 15");
        require(msg.value == msg.value.div(ethWei).mul(ethWei), "invalid msg value");

        UserGlobal storage userGlobal = userMapping[msg.sender];
        //��ȡͶעUserʵ��
        if (userGlobal.id == 0) {//���δͶע��
            //�Լ����������Ƿ��ظ�
            require(!isUsed(inviteCode), "invite code is used");
            //���û�ע��
            registerUser(msg.sender, inviteCode, "");
        }
        User storage user = userRoundMapping[rid][msg.sender];
        SeizeInvest memory si = SeizeInvest(rid, msg.sender, msg.value, now);
        if (uint(user.userAddress) != 0) {//��ǰ�غϷǵ�һ��Ͷע
            //����ע���Žⶳ���
            user.unlockAmount = user.unlockAmount.add(msg.value);
            user.allInvest += msg.value;
        } else {//��ǰ�غϵ�һ��Ͷע
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

    //ִ��ͶƱ���
    function voteComplete() external onlyWhitelistAdmin {
        require(gameStatus == 2,"game status error");
        if (voteResult[0] > voteResult[1]) {//��Ϸ����
            //��Ϸ��ʼʱ��Ϊ6Сʱ��
            startTime = now.add(period);
            //����ͶƱ��ֵ
            voteStartSc = 80;
            //�������ϵ��
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
            //�غ�����1
            rid++;
        } else {//��Ϸ����
            for (i = 1; i <= uid; i++) {
                userAddr = indexMapping[i];
                curUser = userRoundMapping[rid][userAddr];
                curUser.votes = curUser.freezeAmount.add(curUser.unlockAmount).div(ethWei);
            }
            lastSeizeInvest[rid] = SeizeInvest(rid,0x00,0,0);
        }

        gameStatus = 1;
        //����ͶƱƱ��
        voteResult = [0, 0];
    }

    //��������
    function withdrawProfit()
    public
    isHuman() {
        //�ж���Ϸ�Ƿ�ʼ
        require(now > startTime && gameStatus == 1, "now not withdrawal");
        //��ǰ�غ�User
        User storage user = userRoundMapping[rid][msg.sender];
        //��ǰ�û������
        uint sendMoney = user.allStaticAmount.add(user.allDynamicAmount);

        bool isEnough = false;
        uint resultMoney = 0;
        (isEnough, resultMoney) = isEnoughBalance(sendMoney);
        //�жϺ�Լ������Ƿ����
        if (!isEnough) {//����������Ϸ
            endRound();
        }

        if (resultMoney > 0) {
            //���û�ת��
            sendMoneyToUser(msg.sender, resultMoney);
            //��շֺ����
            user.allStaticAmount = 0;
            //��սڵ㽱�����
            user.allDynamicAmount = 0;
            //��ȥ�û����ʲ�
            userAssets -= resultMoney;
            //����Ƿ���ҪͶƱ
            checkVote();
            //���������¼���־
            emit LogWithdrawProfit(msg.sender, user.id, resultMoney, now);
        }
    }

    //�жϺ�Լ����Ƿ��㹻
    function isEnoughBalance(uint sendMoney) private view returns (bool, uint){
        if (sendMoney >= address(this).balance) {//��Լ���С�ڵ��ڷ��͵Ľ��ط�&��ǰ��Լ���
            return (false, address(this).balance);
        } else {
            //��Լ�����ڷ��͵Ľ�����&���ͽ��
            return (true, sendMoney);
        }
    }

    //���û�ת��
    function sendMoneyToUser(address userAddress, uint money) private {
        userAddress.transfer(money);
    }

    //����ֺ�
    function calStaticProfit(address userAddr) external onlyWhitelistAdmin returns (uint)
    {
        return calStaticProfitInner(userAddr);
    }

    function calStaticProfitInner(address userAddr) private returns (uint)
    {
        //��ǰ�غ�User
        User storage user = userRoundMapping[rid][userAddr];
        if (user.id == 0) {//��ǰ�غ��û�δͶע
            return 0;
        }

        //��ȡ�ֺ�ٷֱ�
        uint scale = getScByLevel(user.staticLevel);
        uint allStatic = 0;
        for (uint i = user.staticFlag; i < user.invests.length; i++) {//������ǰ�غ�����Ͷע���
            //Ͷע
            Invest storage invest = user.invests[i];
            //Ͷעʱ��
            uint startDay = invest.investTime.sub(8 hours).div(1 days).mul(1 days);
            //��Ͷע������
            uint staticGaps = now.sub(8 hours).sub(startDay).div(1 days);
            //Ͷע��������
            uint unlockDay = now.sub(invest.investTime).div(1 days);

            //�ж��Ƿ񳬹�5��
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

    //����ֺ�ͽڵ㽱��
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

    //�ⲿע���û�
    function registerUserInfo(address user, string inviteCode, string referrer) external onlyOwner {
        registerUser(user, inviteCode, referrer);
    }

    //����ڵ㽱��
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

    //����Ƿ���ҪͶƱ
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

    //ͶƱ��ʼ
    function voteStart(uint nextSc) internal {
        voteStartSc = nextSc;
        gameStatus = 2;
        voteEndTime = now.add(120 minutes);
        seizeEndTime = now.add(30 minutes);
        emit VoteStart(now, voteEndTime);
    }

    //���Ͷע
    function redeem()
    public
    isHuman() {
        require(now > startTime && gameStatus == 1, "now not withdrawal");
        //��ǰ�غ��û�
        User storage user = userRoundMapping[rid][msg.sender];
        require(user.id > 0, "user not exist");
        //����ֺ�
        calStaticProfitInner(msg.sender);

        //�ⶳ��Ͷע���
        uint sendMoney = user.unlockAmount;
        bool isEnough = false;
        uint resultMoney = 0;

        (isEnough, resultMoney) = isEnoughBalance(sendMoney);

        if (!isEnough) {//����������Ϸ
            endRound();
        }

        if (resultMoney > 0) {
            //���û�ת��
            sendMoneyToUser(msg.sender, resultMoney);
            //��սⶳ���
            user.unlockAmount = 0;
            //���¼����û��ֺ�ȼ�
            user.staticLevel = getLevel(user.freezeAmount);
            //���¼����û��ڵ㽱���ȼ�
            user.dynamicLevel = getLineLevel(user.freezeAmount);
            //��ȥ�û����ʲ�
            userAssets -= resultMoney;
            //��ȥͶƱ����
            user.votes -= (resultMoney.div(ethWei));
            //����Ƿ���ҪͶƱ
            checkVote();
            //�����־
            emit LogRedeem(msg.sender, user.id, resultMoney, now);
        }
    }

    //ͶƱ��voteCountͶƱ������voteIntentͶƱ����0����,��������
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

    //��Ͷ,��λ:wei
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

        //����Ͷעʵ��
        Invest memory invest = Invest(msg.sender, investAmount, now, 0);
        //�����û�Ͷע����
        user.invests.push(invest);
        user.votes-=(investAmount.div(ethWei));
    }

    //��ȡ�������汶��
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

    //�غϽ���
    function endRound() private {
        //�غ����ۼ�
        rid++;
        gameStatus = 1;
        //��������û��ʲ�
        userAssets = 0;
        //��Ϸ������6Сʱ���ٿ�ʼ
        startTime = now.add(period).div(1 hours).mul(1 hours);
        //����ƱͶ��Ϣ
        voteStartSc = 80;
        voteResult = [0,0];
        voteEndTime = 0;
    }

    //�ж��������Ƿ��Ѿ�ʹ��
    function isUsed(string memory code) public view returns (bool) {
        address user = getUserAddressByCode(code);
        return uint(user) != 0;
    }

    //�����������ѯ�û���ַ
    function getUserAddressByCode(string memory code) public view returns (address) {
        return addressMapping[code];
    }

    //��ר���ʻ�ת��6%
    function sendFeetoAdmin(uint amount) private {
        devAddr.transfer(amount.div(16));
    }

    //��ȡ��Ϸ��Ϣ
    function getGameInfo() public isHuman() view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        uint coeff = getCoefficientInner();
        uint balance = address(this).balance;
        return (
        rid, //��Ϸ�غ�
        uid, //���һ���û�id
        startTime, //��Ϸ��ʼʱ��
        balance, //��Լ���
        userAssets, //�û���Ȩ��
        investCount, //��Ͷע����
        investMoney, //��Ͷע���
        rInvestCount[rid], //���غ�Ͷע����
        rInvestMoney[rid], //���غ�Ͷע���
        coeff, //�ֺ�ϵ��
        gameStatus,//��Ϸ״̬��1��Ϸ��,2ͶƱ��
        voteStartSc //��һ��ͶƱ��ֵ
        );
    }

    //��ȡ��ע��Ϣ
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
        lastSeizeInvest[r].userAddress, //��ע��ַ
        lastSeizeInvest[r].seizeAmount, //��ע���
        mult //��ע��������
        );
    }

    //��ȡͶƱ��Ϣ
    function getVoteResult() public isHuman view returns (uint, uint, uint, uint){
        return (
        seizeEndTime, //��ע����ʱ���
        voteEndTime, //ͶƱ����ʱ���
        voteResult[0], //ͬ������Ʊ��
        voteResult[1]//��ͬ������Ʊ��
        );
    }


    //��ȡ�û���Ϣ
    function getUserInfo(address user, uint roundId) public isHuman() view returns (uint[11] memory ct, uint inviteCount, string memory inviteCode, string memory referrer) {
        if (roundId == 0) {
            roundId = rid;
        }

        User memory userInfo = userRoundMapping[roundId][user];
        ct[0] = userInfo.id;
        //userid
        ct[1] = userInfo.staticLevel;
        //�û��ȼ�
        ct[2] = userInfo.dynamicLevel;
        //�û��ɻ�ýڵ㽱������
        ct[3] = userInfo.allInvest;
        //��Ͷע���
        ct[4] = userInfo.freezeAmount;
        //���᱾��
        ct[5] = userInfo.unlockAmount;
        //����ر���
        ct[6] = userInfo.allStaticAmount;
        //��ǰ�غϷֺ�����
        ct[7] = userInfo.allDynamicAmount;
        //��ǰ�غϽڵ�����
        ct[8] = userInfo.hisStaticAmount;
        //�ֺܷ�����
        ct[9] = userInfo.hisDynamicAmount;
        //�ܽڵ�����
        ct[10] = userInfo.votes;
        //����ͶƱ����
        UserGlobal storage userGlobal = userMapping[user];
        return (ct, userGlobal.id==0?0:userGlobal.inviteCount, userGlobal.inviteCode, userGlobal.referrer);
    }

    //��ȡ���¿��������
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

    //���û�ע��
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