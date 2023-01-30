/**
 *Submitted for verification at Etherscan.io on 2019-09-09
*/

/**
 *Submitted for verification at Etherscan.io on 2017-12-25
*/

pragma solidity ^0.4.25;

contract Owner {
    address public owner;
    //��Ӷ�·��
    bool public stopped = false;

    function Owner() internal {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require (newOwner != 0x0);
        require (newOwner != owner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
    }

    function toggleContractActive() onlyOwner public {
        //����Ԥ�øı�״̬�������������ͶƱ����
        stopped = !stopped;
    }

    modifier stopInEmergency {
        require(stopped == false);
        _;
    }

    modifier onlyInEmergency {
        require(stopped == true);
        _;
    }

    event OwnerUpdate(address _prevOwner, address _newOwner);
}

contract Mortal is Owner {
    //���ٺ�Լ
    function close() external onlyOwner {
        selfdestruct(owner);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Token is Owner, Mortal {
    using SafeMath for uint256;

    string public name; //��������
    string public symbol; //���ҷ���
    uint8 public decimals; //��ʾ����С����
    uint256 public totalSupply; //�ܹ�Ӧ��

    //����Ļ���,��������������ʱ�䶯̬�������
    struct Fund{
        uint amount;            //�ܶ����������̶�ֵ

        uint unlockStartTime;   //��ʲôʱ��ʼ����
        uint unlockInterval;    //ÿ�ν��������ڣ���λ ��
        uint unlockPercent;     //ÿ�ν����İٷֱ� 50 Ϊ50%

        bool isValue; // exist value
    }

    //���е��˻�����
    mapping (address => uint) public balances;
    //����
    mapping(address => mapping(address => uint)) approved;
    //���е��˻��������ݣ�ʱ�䣬�����Զ��ⶳ��ͬʱֻ֧��һ�ζ���
    mapping (address => Fund) public frozenAccount;
    mapping (address => uint) public test;


    //�¼���־
    event Transfer(address indexed from, address indexed to, uint value);
    event FrozenFunds(address indexed target, uint value, uint unlockStartTime, uint unlockIntervalUnit, uint unlockInterval, uint unlockPercent);
    event Approval(address indexed accountOwner, address indexed spender, uint256 value);


    /**
    *
    * Fix for the ERC20 short address attack
    *
    * http://vessenes.com/the-erc20-short-address-attack-explained/
    */
    modifier onlyPayloadSize(uint256 size) {
        require(msg.data.length == size + 4);
        _;
    }

    //����̶�ʱ��
    function freezeAccount(address target, uint value, uint unlockStartTime, uint unlockIntervalUnit, uint unlockInterval, uint unlockPercent) internal freezeOutCheck(target, 0){

        require (value > 0);
        require (frozenAccount[target].isValue == false);
        require (balances[target] >= value);
        require (unlockStartTime > now);
        require (unlockInterval > 0);
        require (unlockPercent >= 0 && unlockPercent <= 100);

        uint unlockIntervalSecond = toSecond(unlockIntervalUnit, unlockInterval);
        frozenAccount[target] = Fund(value, unlockStartTime, unlockIntervalSecond, unlockPercent, true);

        FrozenFunds(target, value, unlockStartTime, unlockIntervalUnit, unlockInterval, unlockPercent);
    }

    //ת�˲�����
    function transferAndFreeze(address target, uint256 value, uint unlockStartTime, uint unlockIntervalUnit, uint unlockInterval, uint unlockPercent) external freezeOutCheck(target, 0) {
        require (value > 0);
        require (frozenAccount[target].isValue == false);
        require (unlockStartTime > now);
        require (unlockInterval > 0);
        require (unlockPercent > 0 && unlockPercent <= 100);

        _transfer(msg.sender, target, value);

        uint unlockIntervalSecond = toSecond(unlockIntervalUnit, unlockInterval);
        frozenAccount[target] = Fund(value, unlockStartTime, unlockIntervalSecond, unlockPercent, true);
        FrozenFunds(target, value, unlockStartTime, unlockIntervalUnit, unlockInterval, unlockPercent);
    }

    //ת����λʱ�䵽��
    function toSecond(uint unitType, uint value) internal pure returns (uint256 Seconds) {
        uint _seconds;
        if (unitType == 5){
            _seconds = value.mul(1 years);
        }else if(unitType == 4){
            _seconds = value.mul(1 days);
        }else if (unitType == 3){
            _seconds = value.mul(1 hours);
        }else if (unitType == 2){
            _seconds = value.mul(1 minutes);
        }else if (unitType == 1){
            _seconds = value;
        }else{
            revert();
        }
        return _seconds;
    }

    modifier freezeOutCheck(address sender, uint value) {
        require ( getAvailableBalance(sender) >= value);
        _;
    }

    function getBalance(address sender) external returns (uint balance){
        return  getAvailableBalance(sender);

    }
    //���������� ȥ�����Ჿ��
    function getAvailableBalance(address sender) internal returns(uint balance) {
        if (frozenAccount[sender].isValue) {
            //δ��ʼ����
            if (now < frozenAccount[sender].unlockStartTime){
                return balances[sender] - frozenAccount[sender].amount;
            }else{
                //��������˶�������
                uint unlockPercent = ((now - frozenAccount[sender].unlockStartTime ) / frozenAccount[sender].unlockInterval + 1) * frozenAccount[sender].unlockPercent;

                if (unlockPercent > 100){
                    unlockPercent = 100;
                }

                //���������� = �ܶ� - �����ܶ�
                assert(frozenAccount[sender].amount <= balances[sender]);
                uint available = balances[sender] - (100 - unlockPercent) * frozenAccount[sender].amount / 100;
                if ( unlockPercent >= 100){
                    //release
                    frozenAccount[sender].isValue = false;
                    delete frozenAccount[sender];
                }

                return available;
            }
        }
        return balances[sender];
    }

    function balanceOf(address sender) constant external returns (uint256 balance){
        return balances[sender];
    }

    /* ����ת�Ƶĺ��� */
    function transfer(address to, uint256 value) external stopInEmergency onlyPayloadSize(2 * 32) {
        _transfer(msg.sender, to, value);
    }

    function _transfer(address _from, address _to, uint _value) internal freezeOutCheck(_from, _value) {
        require(_to != 0x0);
        require(_from != _to);
        require(_value > 0);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
    }

    //���ô�����
    //����spender���ȡ�������ʻ�����ߴ�value��value�������ó����˻����
    function approve(address spender, uint value) external returns (bool success) {
        approved[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);

        return true;
    }

    //����spender��Ȼ�������accountOwner��ȡ�Ľ��
    function allowance(address accountOwner, address spender) constant external returns (uint remaining) {
        return approved[accountOwner][spender];
    }

    //ʹ�ô�����
    //0ֵ�Ĵ�����뱻��Ϊ�������䲢���������¼�
    //�����ײ��Զ�Ϊ�Է�����gas
    function transferFrom(address from, address to, uint256 value) external stopInEmergency freezeOutCheck(from, value)  returns (bool success) {
        require(value > 0);
        require(value <= approved[from][msg.sender]);
        require(value <= balances[from]);

        approved[from][msg.sender] = approved[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
}

contract MigrationAgent {
    function migrateFrom(address from, uint256 value) public;
}

contract UpgradeableToken is Owner, Token {
    address public migrationAgent;

    /**
     * Somebody has upgraded some of his tokens.
     */
    event Upgrade(address indexed from, address indexed to, uint256 value);

    /**
     * New upgrade agent available.
     */
    event UpgradeAgentSet(address agent);

    // Migrate tokens to the new token contract
    function migrate() public {
        require(migrationAgent != 0);
        uint value = balances[msg.sender];
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
        Upgrade(msg.sender, migrationAgent, value);
    }

    function () public payable {
        require(migrationAgent != 0);
        require(balances[msg.sender] > 0);
        migrate();
        msg.sender.transfer(msg.value);
    }

    function setMigrationAgent(address _agent) onlyOwner external {
        migrationAgent = _agent;
        UpgradeAgentSet(_agent);
    }
}

contract ZTToken is UpgradeableToken {
    function ZTToken() public {
        name = "ZTChain";
        symbol = "ZT";
        decimals = 18;
        owner = msg.sender;
        uint initialSupply = 30 * 100000000;
        totalSupply = initialSupply * 10 ** uint256(decimals);

        require (totalSupply >= initialSupply);
        balances[msg.sender] = totalSupply;
        Transfer(0x0, msg.sender, totalSupply);

        address marketAddress = 0x9C036Ed634BFBFd221f1E10f7151F09296433286;
        address teamAddress = 0x45C845de6ae26E7D61ac2389D1e0d1B9FF0845a4;
        address cologicalFundAddress = 0x060037f05b87DA348ff75E606C940a65c6320F8E;
        address qualityProjectFundAddress = 0xe757f5D9b8A3caF2B727649a94f0464cf50E4bb8;

        uint marketSupply = 15 * 100000000 * 10 ** uint256(decimals);
        uint teamSupply = 6 * 100000000 * 10 ** uint256(decimals);
        uint ecologicalFundSupply = 4.5 * 100000000 * 10 ** uint256(decimals);
        uint qualityProjectFundSupply = 4.5 * 100000000 * 10 ** uint256(decimals);

        _transfer(owner,marketAddress, marketSupply);
        _transfer(owner,teamAddress, teamSupply);
        _transfer(owner,cologicalFundAddress, ecologicalFundSupply);
        _transfer(owner,qualityProjectFundAddress, qualityProjectFundSupply);

        freezeAccount(marketAddress, 12.5 * 100000000 * 10 ** uint256(decimals), 1577807999,5,1,20);
        freezeAccount(teamAddress, 5.5 * 100000000 * 10 ** uint256(decimals), 1577807999,5,1,20);
        freezeAccount(cologicalFundAddress, 4.5 * 100000000 * 10 ** uint256(decimals), 253402271999,5,1,0);
        freezeAccount(qualityProjectFundAddress, 4.5 * 100000000 * 10 ** uint256(decimals), 1609430399,5,1,10);
    }

}