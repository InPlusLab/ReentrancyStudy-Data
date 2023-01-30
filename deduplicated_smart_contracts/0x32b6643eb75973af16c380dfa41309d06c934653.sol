/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

pragma solidity ^0.4.8;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

 interface tokenTransfer {
    function transfer(address receiver, uint amount);
}
interface tokenTransferUSDT {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value);
    function balances(address receiver) returns(uint256);
}
contract B11 is SafeMath,owned{

   tokenTransfer public b11TokenTransfer; 
   
  tokenTransferUSDT public bebTokenTransferUSDT;

    
    string public constant name = 'B11 Coin';
    string public constant symbol = 'B11';
    uint256 public constant decimals = 18;
    uint256 public constant totalSupply = 500 * 1000 * 10 ** decimals;

    uint256 public constant USDTPRICE = 7;
    uint256 public constant ACOPY = 100 * 10 ** decimals;

    uint256 public constant FounderAllocation = 500 * 10000 * 10 ** decimals;
    uint256 public constant FounderLockupAmount = 300 * 10000 * 10 ** decimals;
    uint256 public constant FounderLockupCliff = 180 days;
    uint256 public constant FounderReleaseInterval = 30 days;
    uint256 public constant FounderReleaseAmount = 50 * 10000 * 10 ** decimals;

    address public founder = address(0);
    uint256 public founderLockupStartTime = 0;
    uint256 public founderReleasedAmount = 0;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed to, uint256 value);
    event ChangeFounder(address indexed previousFounder, address indexed newFounder);
    event SetMinter(address indexed minter);
 uint256 yuerbaoAmount;
    uint256 dingqibaoAmount;
   uint256 bebjiage;
    uint256 bebtime;
    uint256 usdtex;
        struct useryuerbao{
        uint256 amount;
        uint256 lixishouyi;
        uint256 cunkuantime;
        bool vote;
    }
    struct userDingqi{
        uint256 amount;
        uint256 lixishouyi;
        uint256 cunkuantime;
        uint256 yuefen;
        bool vote;
    }
    mapping(address=>useryuerbao)public users;
    mapping(address=>userDingqi)public userDingqis;
    
   function B11(address _tokenAddress,address _tokenUsdtAddress) {
		b11TokenTransfer=tokenTransfer(_tokenAddress);
		 bebTokenTransferUSDT =tokenTransferUSDT(_tokenUsdtAddress);

    }
    function setUSDT(uint256 _value) public{
         require(_value>=10000000);
         uint256 _valueToBEB=SafeMath.safeDiv(_value,1000000);
         uint256 _valueToBEBs=_valueToBEB*10**18;
         uint256 _usdts=SafeMath.safeMul(_value,120);//100;
         uint256 _usdt=SafeMath.safeDiv(_usdts,100);//100;
         uint256 _bebex=SafeMath.safeMul(bebjiage,usdtex);
         uint256 _usdtexs=SafeMath.safeDiv(1000000000000000000,_bebex);
         uint256 _usdtex=SafeMath.safeMul(_usdtexs,bebjiage);
     }
    function release() public {
        uint256 currentTime = block.timestamp;
        uint256 cliffTime = SafeMath.safeAdd(founderLockupStartTime,FounderLockupCliff);
        if (currentTime < cliffTime) return;
        if (founderReleasedAmount >= FounderLockupAmount) return;
        uint256 month = SafeMath.safeSub(currentTime,cliffTime);
        uint256 releaseAmount = SafeMath.safeMul(month,FounderReleaseAmount);
        if (releaseAmount > FounderLockupAmount) releaseAmount = FounderLockupAmount;
        if (releaseAmount <= founderReleasedAmount) return;
        uint256 amount = SafeMath.safeSub(releaseAmount,founderReleasedAmount);
    }
     function yuerbaoCunkuan()payable public{
        require(tx.origin == msg.sender);
        useryuerbao storage _user=users[msg.sender];
        require(!_user.vote,"Please withdraw money first.£¡");
        _user.amount=msg.value;
        _user.cunkuantime=now;
        _user.vote=true;
        yuerbaoAmount+=msg.value;
    }
    function yuerbaoQukuan() public{
        require(tx.origin == msg.sender);
        useryuerbao storage _users=users[msg.sender];
        require(_users.vote,"You have no deposit£¡");
        uint256 _amount=_users.amount;
        uint256 lixieth=_amount*bebjiage/100;
        uint256 minteeth=lixieth/365/1440;
        uint256 _minte=(now-_users.cunkuantime)/60;
        require(_minte>=1,"Must be greater than one minute ");
        uint256 _shouyieth=minteeth*_minte;
        uint256 _sumshouyis=_amount+_shouyieth;
        require(this.balance>=_sumshouyis,"Sorry, your credit is running low£¡");
        msg.sender.transfer(_sumshouyis);
        _users.amount=0;
        _users.cunkuantime=0;
        _users.vote=false;
        _users.lixishouyi+=_shouyieth;
    }
    function withdrawToken(address _toAddress,uint256 amount) public onlyOwner {
         b11TokenTransfer.transfer(_toAddress,amount);
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function changeFounder(address _founder) public onlyOwner {
        require(_founder != address(0), "TristersLightCoin: founder is the zero address");

        emit ChangeFounder(founder, _founder);
        founder = _founder;
    }
     function ()payable{
        
    }
     function DayQuKuan(uint256 amount) public onlyOwner{
        msg.sender.transfer(amount);
   }
    function random(uint256 randomyType)  internal returns(uint256 num){
        uint256 random = uint256(keccak256(randomyType,now));
         uint256 randomNum = random%101;
         if(randomNum<1){
             randomNum=1;
         }
         if(randomNum>100){
            randomNum=100; 
         }
         
         return randomNum;
    }
}