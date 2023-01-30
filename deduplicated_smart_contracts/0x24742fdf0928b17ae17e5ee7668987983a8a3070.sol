pragma solidity ^0.4.8;


library BobbySafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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


contract BobbyERC20Base {

    address public ceoAddress;
    address public cfoAddress;

    //�Ƿ���ͣ���ܺ�Լ������
    bool public paused = false;

    constructor(address cfoAddr) public {
        ceoAddress = msg.sender;
        cfoAddress = cfoAddr;
    }

    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    modifier allButCFO() {
        require(msg.sender != cfoAddress);
        _;
    }

    function setCFO(address _newCFO) public onlyCEO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() external onlyCEO whenNotPaused {
        paused = true;
    }

    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}

contract ERC20Interface {

    //ERC20ָ���ӿ�
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    //extend event
    event Grant(address indexed src, address indexed dst, uint wad);    //���Ŵ��ң��н����
    event Unlock(address indexed user, uint wad);                       //�������

    function name() public view returns (string n);
    function symbol() public view returns (string s);
    function decimals() public view returns (uint8 d);
    function totalSupply() public view returns (uint256 t);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
}

//Erc���ܺ�Լ
contract ERC20 is ERC20Interface, BobbyERC20Base {
    using BobbySafeMath for uint256;

    uint private _Thousand = 1000;
    uint private _Billion = _Thousand * _Thousand * _Thousand;

    //���һ�����Ϣ
    string private _name = "BOBBY";     //��������
    string private _symbol = "BOBBY";   //���ұ�ʶ
    uint8 private _decimals = 9;        //С�����λ��
    uint256 private _totalSupply = 10 * _Billion * (10 ** uint256(_decimals));

    //����û����ҽṹ
    struct UserToken {
        uint index;              //���������е��±�
        address addr;            //�û��˺�
        uint256 tokens;          //֤ͨ����

        uint256 unlockUnit;     // ÿ�ν�������
        uint256 unlockPeriod;   // ����ʱ����
        uint256 unlockLeft;     // δ����֤ͨ����
        uint256 unlockLastTime; // �ϴν���ʱ��
    }

    mapping(address=>UserToken) private _balancesMap;           //�û����ô���ӳ��
    address[] private _balancesArray;                           //�û����ô�������,from 1

    uint32 private actionTransfer = 0;
    uint32 private actionGrant = 1;
    uint32 private actionUnlock = 2;

    struct LogEntry {
        uint256 time;
        uint32  action;       // 0 ת�� 1 ���� 2 ����
        address from;
        address to;
        uint256 v1;
        uint256 v2;
        uint256 v3;
    }

    LogEntry[] private _logs;

    //���췽���������ҵĳ�ʼ�ܹ������������Լ�Ĳ����˻�����Լ�Ĺ��췽��ֻ�ں�Լ����ʱִ��һ��
    constructor(address cfoAddr) BobbyERC20Base(cfoAddr) public {

        //placeholder
        _balancesArray.push(address(0));

        //�˴���Ҫע�⣬��ʹ��CEO�ĵ�ַ,��Ϊ��ʼ���󣬽���ʹ�������ַ��ΪCEO��ַ
        //ע�⣬һ��Ҫʹ��memory���ͣ����򣬺���ĸ�ֵ��Ӱ��������Ա����
        UserToken memory userCFO;
        userCFO.index = _balancesArray.length;
        userCFO.addr = cfoAddr;
        userCFO.tokens = _totalSupply;
        userCFO.unlockUnit = 0;
        userCFO.unlockPeriod = 0;
        userCFO.unlockLeft = 0;
        userCFO.unlockLastTime = 0;
        _balancesArray.push(cfoAddr);
        _balancesMap[cfoAddr] = userCFO;
    }

    //���غ�Լ���ơ�view�ؼ��ӱ�ʾ����ֻ��ѯ״̬����������д��
    function name() public view returns (string n){
        n = _name;
    }

    //���غ�Լ��ʶ��
    function symbol() public view returns (string s){
        s = _symbol;
    }

    //���غ�ԼС��λ
    function decimals() public view returns (uint8 d){
        d = _decimals;
    }

    //���غ�Լ�ܹ�����
    function totalSupply() public view returns (uint256 t){
        t = _totalSupply;
    }

    //��ѯ�˻�_owner���˻����
    function balanceOf(address _owner) public view returns (uint256 balance){
        UserToken storage user = _balancesMap[_owner];
        balance = user.tokens.add(user.unlockLeft);
    }

    //�Ӵ��Һ�Լ�ĵ����ߵ�ַ��ת��_value������token���ĵ�ַ_to�����ұ��봥��Transfer�¼�
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(!paused);
        require(msg.sender != cfoAddress);
        require(msg.sender != _to);

        //���ж��Ƿ��п��Խ��
        if(_balancesMap[msg.sender].unlockLeft > 0){
            UserToken storage sender = _balancesMap[msg.sender];
            uint256 diff = now.sub(sender.unlockLastTime);
            uint256 round = diff.div(sender.unlockPeriod);
            if(round > 0) {
                uint256 unlocked = sender.unlockUnit.mul(round);
                if (unlocked > sender.unlockLeft) {
                    unlocked = sender.unlockLeft;
                }

                sender.unlockLeft = sender.unlockLeft.sub(unlocked);
                sender.tokens = sender.tokens.add(unlocked);
                sender.unlockLastTime = sender.unlockLastTime.add(sender.unlockPeriod.mul(round));

                emit Unlock(msg.sender, unlocked);
                log(actionUnlock, msg.sender, 0, unlocked, 0, 0);
            }
        }

        require(_balancesMap[msg.sender].tokens >= _value);
        _balancesMap[msg.sender].tokens = _balancesMap[msg.sender].tokens.sub(_value);

        uint index = _balancesMap[_to].index;
        if(index == 0){
            UserToken memory user;
            user.index = _balancesArray.length;
            user.addr = _to;
            user.tokens = _value;
            user.unlockUnit = 0;
            user.unlockPeriod = 0;
            user.unlockLeft = 0;
            user.unlockLastTime = 0;
            _balancesMap[_to] = user;
            _balancesArray.push(_to);
        }
        else{
            _balancesMap[_to].tokens = _balancesMap[_to].tokens.add(_value);
        }

        emit Transfer(msg.sender, _to, _value);
        log(actionTransfer, msg.sender, _to, _value, 0, 0);
        success = true;
    }

    function transferFrom(address, address, uint256) public returns (bool success){
        require(!paused);
        success = true;
    }

    function approve(address, uint256) public returns (bool success){
        require(!paused);
        success = true;
    }

    function allowance(address, address) public view returns (uint256 remaining){
        require(!paused);
        remaining = 0;
    }

    function grant(address _to, uint256 _value, uint256 _duration, uint256 _periods) public returns (bool success){
        require(msg.sender != _to);
        require(_balancesMap[msg.sender].tokens >= _value);
        require(_balancesMap[_to].unlockLastTime == 0);

        _balancesMap[msg.sender].tokens = _balancesMap[msg.sender].tokens.sub(_value);

        if(_balancesMap[_to].index == 0){
            UserToken memory user;
            user.index = _balancesArray.length;
            user.addr = _to;
            user.tokens = 0;
            user.unlockUnit = _value.div(_periods);
            user.unlockPeriod = _duration.mul(30).mul(1 days).div(_periods);
            /* user.unlockPeriod = _period; //for test */
            user.unlockLeft = _value;
            user.unlockLastTime = now;
            _balancesMap[_to] = user;
            _balancesArray.push(_to);
        }
        else{
            _balancesMap[_to].unlockUnit = _value.div(_periods);
            _balancesMap[_to].unlockPeriod = _duration.mul(30).mul(1 days).div(_periods);
            /* _balancesMap[_to].unlockPeriod = _period; //for test */
            _balancesMap[_to].unlockLeft = _value;
            _balancesMap[_to].unlockLastTime = now;
        }

        emit Grant(msg.sender, _to, _value);
        log(actionGrant, msg.sender, _to, _value, _duration, _periods);
        success = true;
    }

    function getBalanceAddr(uint256 _index) public view returns(address addr){
        require(_index < _balancesArray.length);
        require(_index >= 0);
        addr = _balancesArray[_index];
    }

    function getBalanceSize() public view returns(uint256 size){
        size = _balancesArray.length;
    }

    function getLockInfo(address addr) public view returns (uint256 unlocked, uint256 unit, uint256 period, uint256 last) {
        UserToken storage user = _balancesMap[addr];
        unlocked = user.unlockLeft;
        unit = user.unlockUnit;
        period = user.unlockPeriod;
        last = user.unlockLastTime;
    }

    function log(uint32 action, address from, address to, uint256 _v1, uint256 _v2, uint256 _v3) private {
        LogEntry memory entry;
        entry.action = action;
        entry.time = now;
        entry.from = from;
        entry.to = to;
        entry.v1 = _v1;
        entry.v2 = _v2;
        entry.v3 = _v3;
        _logs.push(entry);
    }

    function getLogSize() public view returns(uint256 size){
        size = _logs.length;
    }

    function getLog(uint256 _index) public view returns(uint time, uint32 action, address from, address to, uint256 _v1, uint256 _v2, uint256 _v3){
        require(_index < _logs.length);
        require(_index >= 0);
        LogEntry storage entry = _logs[_index];
        action = entry.action;
        time = entry.time;
        from = entry.from;
        to = entry.to;
        _v1 = entry.v1;
        _v2 = entry.v2;
        _v3 = entry.v3;
    }
}