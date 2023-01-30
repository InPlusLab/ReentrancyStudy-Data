pragma solidity ^0.4.8;

library BobbySafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a==0) {
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

  //����ִ����ͣ������Ȩ��
  address public ceoAddress;

  //�Ƿ���ͣ���ܺ�Լ������
  bool public paused = false;

  constructor()  {
    ceoAddress = msg.sender;
  }

  modifier onlyCEO() {
     require(msg.sender == ceoAddress);
    _;
  }

 function setCEO(address _newCEO) public onlyCEO {
      require(_newCEO != address(0));
      ceoAddress = _newCEO;
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

  function name() public view returns (string name);
  function symbol() public view returns (string symbol);
  function decimals() public view returns (uint8 decimals);
  function totalSupply() public view returns (uint256 totalSupply);
  function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  //��չ�ӿ�
  function getBalanceAddr(uint256 _index) public view returns(address addr);
  function getBalance(uint256 _index) public view returns(uint256 tokens);
  function getBalanceSize() public view returns(uint256 size);
}

//Erc���ܺ�Լ
contract ERC20 is ERC20Interface, BobbyERC20Base {

  using BobbySafeMath for uint256;

  //��������
  uint private  _Wei = 1;
  uint private  _Kwei = 1000 * _Wei;
  uint private  _Mwei = 1000 * _Kwei;
  uint private  _Gwei = 1000 * _Mwei;
  uint private  _Bobby = 1000 * 1000 * 1000 * _Gwei;
  uint private  _CurrentBob = 165442393 * _Mwei;

  uint private _Hundred = 100;
  uint private _Thousand = 1000;
  uint private _Billion = _Thousand * _Thousand * _Thousand;

  //���һ�����Ϣ
  string private _name = "OtvCloud Token Bobby";     //��������
  string private _symbol = "BOBBY";   //���ұ�ʶ
  uint8 private _decimals = 9;        //С�����λ��
  uint256 private _totalSupply = 10 * _Billion * (10 ** uint256(_decimals));

  //����û����ҽṹ
  struct userToken {
    uint _index;             //���������е��±�
    address _addr;          //�û��˺�
    uint256 _tokens;        //֤ͨ����
  }
  mapping(address=>userToken) private _balancesMap;           //�û����ô���ӳ��
  address[] _balancesArray;                                   //�û������������,from 1

  struct logEntry {
    uint time;
    address from;
    address to;
    uint256 value;
  }
  logEntry[] _logs;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);       //����ת���¼�
  event Approval(address indexed _owner, address indexed _spender, uint256 _value); //�������¼�

  //���췽���������ҵĳ�ʼ�ܹ������������Լ�Ĳ����˻�����Լ�Ĺ��췽��ֻ�ں�Լ����ʱִ��һ��
  constructor() {
    _balancesArray.push(address(0));

    //�˴���Ҫע�⣬��ʹ��CEO�ĵ�ַ,��Ϊ��ʼ���󣬽���ʹ�������ַ��ΪCEO��ַ
    //ע�⣬һ��Ҫʹ��memory���ͣ����򣬺���ĸ�ֵ��Ӱ��������Ա����
    userToken memory userCEO;
    userCEO._index = _balancesArray.length;
    userCEO._addr = msg.sender;
    userCEO._tokens = _totalSupply;
    _balancesArray.push(msg.sender);
    _balancesMap[msg.sender] = userCEO;
  }

  //���غ�Լ���ơ�view�ؼ��ӱ�ʾ����ֻ��ѯ״̬����������д��
  function name() public view returns (string name){
    name = _name;
  }

  //���غ�Լ��ʶ��
  function symbol() public view returns (string symbol){
    symbol = _symbol;
  }

  //���غ�ԼС��λ
  function decimals() public view returns (uint8 decimals){
    decimals = _decimals;
  }

  //���غ�Լ�ܹ�����
  function totalSupply() public view returns (uint256 totalSupply){
    totalSupply = _totalSupply;
  }

  function getBalanceAddr(uint256 _index) public view returns(address addr){
    require(_index < _balancesArray.length);
    require(_index >= 0);
    addr = _balancesArray[_index];
  }

  function getBalance(uint256 _index) public view returns(uint256 tokens){
    require(_index < _balancesArray.length);
    require(_index >= 0);
    tokens = _balancesMap[_balancesArray[_index]]._tokens;
  }

  function getBalanceSize() public view returns(uint256 size){
    size = _balancesArray.length;
  }

  function log(address from, address to, uint256 value) public {
    logEntry memory entry;
    entry.time = now;
    entry.from = from;
    entry.to = to;
    entry.value = value;
    _logs.push(entry);
  }

  function getLogSize() public view returns(uint256 size){
    size = _logs.length;
  }

  function getLog(uint256 _index) public view returns(uint time, address from, address to, uint256 value){
    require(_index < _logs.length);
    require(_index >= 0);
    logEntry entry = _logs[_index];
    time = entry.time;
    from = entry.from;
    to = entry.to;
    value = entry.value;
  }

  //��ѯ�˻�_owner���˻����
  function balanceOf(address _owner) public view returns (uint256 balance){
    balance = _balancesMap[_owner]._tokens;
  }

  function addBalance(address _addr, uint256 _value) private{
    _balancesMap[_addr]._tokens = _balancesMap[_addr]._tokens.add(_value);
  }

  function subBalance(address _addr, uint256 _value) private{
    _balancesMap[_addr]._tokens = _balancesMap[_addr]._tokens.sub(_value);
  }

  //�Ӵ��Һ�Լ�ĵ����ߵ�ַ��ת��_value������token���ĵ�ַ_to�����ұ��봥��Transfer�¼�
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool success){
    require(_balancesMap[msg.sender]._tokens >= _value);
    subBalance(msg.sender, _value);

    uint index = _balancesMap[_to]._index;
    if(index == 0){
      userToken memory user;
      user._index = _balancesArray.length;
      user._addr = _to;
      user._tokens = _value;
      _balancesMap[_to] = user;
      _balancesArray.push(_to);
    }
    else{
      addBalance(_to, _value);
    }

    Transfer(msg.sender, _to, _value);
    log(msg.sender, _to, _value);
    success = true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success){
    success = true;
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success){
    success = true;
  }

  function allowance(address _owner, address _spender) public view whenNotPaused returns (uint256 remaining){
    remaining = 0;
  }
}