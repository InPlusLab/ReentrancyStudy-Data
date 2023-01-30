/**
 *Submitted for verification at Etherscan.io on 2019-09-09
*/

pragma solidity >=0.4.24  <0.6.0;
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20Token{
// these functions aren't abstract since the compiler emits automatically generated getter functions as external
function name() public view returns(string memory);
function symbol() public view returns(string memory);
function decimals() public view returns(uint256);
function totalSupply() public view returns (uint256);
function balanceOf(address _owner) public view returns (uint256);
function allowance(address _owner, address _spender) public view returns (uint256);

function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
 event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

}


/*
    Library for basic math operations with overflow/underflow protection
*/
library SafeMath {
    /**
        @dev returns the sum of _x and _y, reverts if the calculation overflows

        @param _x   value 1
        @param _y   value 2

        @return sum
    */
    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        require(z >= _x,"SafeMath->mul got a exception");
        return z;
    }

    /**
        @dev returns the difference of _x minus _y, reverts if the calculation underflows

        @param _x   minuend
        @param _y   subtrahend

        @return difference
    */
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_x >= _y,"SafeMath->sub got a exception");
        return _x - _y;
    }

    /**
        @dev returns the product of multiplying _x by _y, reverts if the calculation overflows

        @param _x   factor 1
        @param _y   factor 2

        @return product
    */
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        // gas optimization
        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y,"SafeMath->mul got a exception");
        return z;
    }

      /**
        @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

        @param _x   dividend
        @param _y   divisor

        @return quotient
    */
    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_y > 0,"SafeMath->div got a exception");
        uint256 c = _x / _y;

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library ConvertLib {
    function convert(uint amount,uint conversionRate) public pure returns (uint convertedAmount) {
        return amount * conversionRate;
    }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20Token is IERC20Token {
  using SafeMath for uint256;

  mapping (address => uint256) _balances;

  mapping (address => mapping (address => uint256)) _allowed;

  uint256 _totalSupply;
  string private _name;
  string private _symbol;
  uint256 private _decimals;

   event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  constructor(string memory name, string memory symbol,uint256 total, uint256 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
    _totalSupply = total.mul(10**decimals);
    _balances[msg.sender] = _totalSupply;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string memory) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string memory) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint) {
    return _decimals;
  }

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _balances[msg.sender],"not enough balance!!");
    require(to != address(0),"params can't be empty(0)");

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0),"approve address can't be empty(0)!!!");

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _balances[from],"balance not enough!!");
    require(value <= _allowed[from][msg.sender],"allow not enough");
    require(to != address(0),"target address can't be empty(0)");

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }
}

/*
*lock/unlock tokens
*/
contract LockXL{
    using SafeMath for uint256;
    uint256 constant UNLOCK_DURATION = 100 * 24 * 60 * 60; //100 days, 100 * 24 * 60 * 60
    uint256 constant DAY_UINT = 1*24*60*60;//1day,24 * 60 * 60;
    uint256 private _unlockStartTime;

    struct LockBody{
        address account;
        uint256 lockXLs;
        uint256 unlockXLs; //remainXLs = lockXLs - unlockXLs
        bool unlockDone; //remainXLs == 0
    }

    mapping (address=>LockBody) _lockBodies;

    event LockBodyInputLog(address indexed account,uint256 indexed lockXLs);

    constructor(uint256 unlockDurationTime) public {
        _unlockStartTime = now.add(unlockDurationTime);
    }

    function transferable(uint256 amount,uint256 balance) internal  returns(bool){
        if(_lockBodies[msg.sender].account == address(0)) return true; //it is not lock sender
        LockBody storage lb = _lockBodies[msg.sender];
        //current unlock progress
        uint256 curProgress = now.sub(_unlockStartTime);
        uint256 timeStamp = curProgress.div(DAY_UINT); //turn to day
        lb.unlockDone = timeStamp >= UNLOCK_DURATION;
        if(lb.unlockDone) return true; //unlock finished

        uint256 unlockXLsPart = lb.lockXLs.mul(timeStamp).div(UNLOCK_DURATION);
        lb.unlockXLs = unlockXLsPart;
        if(balance.add(unlockXLsPart).sub(lb.lockXLs) > amount) return true;
        return false;
    }

    /**
     *get the current
     */
     function LockInfo(address _acc) public view returns(address account,uint256 unlockStartTime,
      uint256 curUnlockProgess,uint256 unlockDuration,
      uint256 lockXLs,uint256 unlockXLs,uint256 remainlockXLs){
        account = _acc;
        unlockStartTime = _unlockStartTime;
        LockBody memory lb = _lockBodies[_acc];
        //current unlock progress
        uint256 curProgress = now.sub(_unlockStartTime);
        curUnlockProgess = curProgress.div(DAY_UINT);
        lockXLs = lb.lockXLs;
        if(curUnlockProgess >= UNLOCK_DURATION){
            curUnlockProgess = UNLOCK_DURATION;
        }
        unlockXLs = lb.lockXLs.mul(curUnlockProgess).div(UNLOCK_DURATION);
        remainlockXLs = lb.lockXLs.sub(unlockXLs);
        unlockDuration = UNLOCK_DURATION;
     }


    /*
    *
    *
    */
    function inputLockBody(uint256 _XLs) public {
        require(_XLs > 0,"xl amount == 0");
        address _account = address(tx.origin); //origin
        LockBody storage lb = _lockBodies[_account];
        if(lb.account != address(0)){
            lb.lockXLs = lb.lockXLs.add(_XLs);
        }else{
            _lockBodies[_account] = LockBody({account:_account,lockXLs:_XLs,unlockXLs:0,unlockDone:false});
        }
        emit LockBodyInputLog(_account,_XLs);
    }

}

contract Ownable{
    address private _owner;
    event OwnershipTransferred(address indexed prevOwner,address indexed newOwner);
    event WithdrawEtherEvent(address indexed receiver,uint256 indexed amount,uint256 indexed atime);
    //modifier
    modifier onlyOwner{
        require(msg.sender == _owner, "sender not eq owner");
        _;
    }
    constructor() internal{
        _owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "newOwner can't be empty!");
        address prevOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(prevOwner,newOwner);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * @param tokenAddr ERC20 The address of the ERC20 token contract
     * @param receiver The address of the receiver
     * @param amount uint256
     */
    function rescueTokens(IERC20Token tokenAddr, address receiver, uint256 amount) external onlyOwner {
        IERC20Token _token = IERC20Token(tokenAddr);
        require(receiver != address(0),"receiver can't be empty!");
        uint256 balance = _token.balanceOf(address(this));
        require(balance >= amount,"balance is not enough!");
        require(_token.transfer(receiver, amount),"transfer failed!!");
    }

    /**
     * @dev Withdraw ether
     */
    function withdrawEther(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0),"address can't be empty");
        uint256 balance = address(this).balance;
        require(balance >= amount,"this balance is not enough!");
        to.transfer(amount);
       emit WithdrawEtherEvent(to,amount,now);
    }


}

/*
*紧急情况下暂停转账
*
*/

contract UrgencyPause is Ownable{
    bool private _paused;
    mapping (address=>bool) private _manager;
    event Paused(address indexed account,bool indexed state);
    event ChangeManagerState(address indexed account,bool indexed state);
    //modifer
    modifier isManager(){
        require(_manager[msg.sender]==true,"not manager!!");
        _;
    }
    
    modifier notPaused(){
        require(!_paused,"the state is paused!");
        _;
    }
    constructor() public{
        _paused = false;
        _manager[msg.sender] = true;
    }

    function changeManagerState(address account,bool state) public onlyOwner {
        require(account != address(0),"null address!!");
        _manager[account] = state;
        emit ChangeManagerState(account,state);
    }

    function paused() public view returns(bool) {
        return _paused;
    }

    function setPaused(bool state) public isManager {
            _paused = state;
            emit Paused(msg.sender,_paused);
    }

}

contract XLand is ERC20Token,UrgencyPause,LockXL{
    using SafeMath for uint256;
    mapping(address=>bool) private _freezes;  //accounts were freezed
    //events
    event FreezeAccountStateChange(address indexed account, bool indexed isFreeze);
    //modifier
    modifier notFreeze(){
      require(_freezes[msg.sender]==false,"The account was freezed!!");
      _;
    }

    modifier transferableXLs(uint256 amount){
      require(super.transferable(amount,_balances[msg.sender]),"lock,can't be transfer!!");
      _;
    }
    
    constructor(string memory name, string memory symbol,uint256 total, uint8 decimals,uint256 unLockStatTime)
    public
    ERC20Token(name,symbol,total,decimals)
    LockXL(unLockStatTime){

    }

    function transfer(address to, uint256 value) public notPaused notFreeze transferableXLs(value) returns (bool){
        return super.transfer(to,value);
    }

    function approve(address spender, uint256 value) public notPaused notFreeze transferableXLs(value) returns (bool){
        return super.approve(spender,value);
    }

    function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public notPaused notFreeze
    returns (bool){
        return super.transferFrom(from,to,value);
    }

    function inputLockBody(uint256 amount) public {
        super.inputLockBody(amount);
    }
    /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public notPaused notFreeze
    returns (bool)
  {
    require(spender != address(0),"spender can't be empty(0)!!!");

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public notPaused notFreeze
    returns (bool)
  {
    require(spender != address(0),"spender can't be empty(0)!!!");

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param amount The amount that will be created.
   */
   //can't mint
  // function mint(uint256 amount) public onlyOwner {
  //   _totalSupply = _totalSupply.add(amount);
  //   _balances[msg.sender] = _balances[msg.sender].add(amount);
  //   emit Transfer(address(0), msg.sender, amount);
  // }

  /**
   * @dev Internal function that burns an amount of the token of a given
   *
   * @param amount The amount that will be burnt.
   */
  function burn(uint256 amount) public onlyOwner {
    require(amount <= _balances[msg.sender],"balance not enough!!!");
    _totalSupply = _totalSupply.sub(amount);
    _balances[msg.sender] = _balances[msg.sender].sub(amount);
    emit Transfer(msg.sender, address(0), amount);
  }

  /**
  *add  freeze/unfreeze account
  *account
  */
  function changeFreezeAccountState(address account,bool isFreeze) public onlyOwner{
    require(account != address(0),"account can't be empty!!");
    _freezes[account] = isFreeze;
    emit FreezeAccountStateChange(account,isFreeze);
  }

}