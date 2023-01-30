pragma solidity >=0.4.24 <0.6.0;
import "./UrgencyPause.sol";
import "./SafeMath.sol";
import "./IERC20Token.sol";
import "./Ownable.sol";

contract Omg is Ownable, UrgencyPause {
    using SafeMath for uint256;

    uint256 private _startTime = 1567213749;  //解仓时间s 2019/9/1 9:00:00 - 1
    uint256 constant UNLOCK_DURATION = 100;
    uint256 constant DAY_UINT = 1*24*60*60;  //换算成天数
    address[] private _investors;
    mapping (address=>Investor) _mapInvestors;

    IERC20Token private _xlToken;
     //投资者结构体
     struct Investor {
         address account;
         uint256 lockXLs;
         uint256 unlockXLs;
     }

     event TokenChanged(address indexed token,uint256 indexed time);
     event LockXLEvent(address indexed acc,uint256 indexed lockXLs);
     event StartTimeUnlock(address indexed account,uint256 indexed startTime);
     event UnlockXLEvent(address indexed acc,uint256 indexed unlockXLs);
     constructor(IERC20Token token) public {
         _xlToken = IERC20Token(token);
     }

     function () external {
         if(super.isManager(msg.sender)){
             unlockBatch(); //管理者批量发送
         }else{
             unlockAccount(msg.sender);  //单个拉取
         }
     }
     
     //当前天数 1-100
     function curDays() public view returns(uint256) {
         uint256 curSeconds = now.sub(_startTime);
         uint256 curDay = curSeconds.div(DAY_UINT);
         return curDay;
     }
     
     //是否完成释放
     function isFinished() public view returns(bool) {
         return curDays() >= UNLOCK_DURATION;
     }


     //设置解仓时间
      function setStartTimeUnLock(uint256 _time) public onlyOwner {
          _startTime = _time;
          emit StartTimeUnlock(msg.sender,_time);
      }
    
    function setToken(IERC20Token _token) public onlyOwner {
        _xlToken = IERC20Token(_token);
        emit TokenChanged(address(_token),now);
    }

    //投资者数量
    function investors() public view returns(uint256 count) {
        return _investors.length;
    }

    //添加用户锁仓记录
    function addInvestor(address _acc,uint256 _lockXLs) public notPaused onlyOwner {
        require(_acc != address(0),"无地址");
        uint256 lockXLs = _lockXLs;//.div(10**18); //除去精度
        require(_mapInvestors[_acc].account == address(0),"该投资者已存在!!");
        _investors.push(_acc);
        _mapInvestors[_acc] = Investor({account:_acc,lockXLs:lockXLs,unlockXLs:0});
        emit LockXLEvent(_acc,lockXLs);
    }

    //删除用户记录
    function removeInvestorAtIndex(uint256  index) public onlyOwner {
        if(index < _investors.length) {
            address acc = _investors[index];
            _mapInvestors[acc] = Investor(address(0),0,0);
            delete _investors[index];
            //填上删除的空白
            _investors[index] = _investors[_investors.length - 1];
        }
    }

    function investorAtAccount(address acc) public view returns(address account,
         uint256 lockXLs,
         uint256 unlockXLs) {
        Investor storage inv = _mapInvestors[acc];
             account = inv.account;
             lockXLs = inv.lockXLs;
             unlockXLs = inv.unlockXLs;
    }

    function appendLocksXLs(address acc,uint256 lockXls) public onlyManager {
        require(acc != address(0),"0地址");
        if(_mapInvestors[acc].account == address(0)){//新增
            addInvestor(acc,lockXls);
        }else{ //追加
            Investor storage inv = _mapInvestors[acc];
            inv.lockXLs = inv.lockXLs.add(lockXls);
        }
    }

   //解锁某个账户
    function unlockAccount(address acc) internal {
        Investor storage inv = _mapInvestors[acc];
             if(inv.account == address(0)){
                 return;
             }
              uint curDay = curDays();
              //1%,100天
              uint256 totalUnlock = inv.lockXLs.mul(curDay).div(UNLOCK_DURATION);

              //当前总释放量 - 已经释放的量
              uint256 unlocking = totalUnlock.sub(inv.unlockXLs);
              if(unlocking <= 0){ //等零则已经释放过
                  return;
              }
              inv.unlockXLs = totalUnlock;
              _mapInvestors[acc].unlockXLs = totalUnlock;
              _xlToken.transfer(inv.account,unlocking);
              emit UnlockXLEvent(inv.account,unlocking);
    }
    //批量释放
    function unlockBatch() public notPaused onlyManager {
       // require(isFinished() == false,"释放时间已到");
        //当前释放量 = 锁仓总量*curDay/100 - 已经释放量
        uint curDay = curDays();
        require(curDay <= UNLOCK_DURATION,"释放周期完成!");
        for (uint256 i = 0; i < _investors.length; ++i){
             address acc = _investors[i];
             if(acc == address(0)){
                 continue;
             }
             unlockAccount(acc);
        }
    }

    function balanceAt(address acc) public view returns(uint256 balance){
        require(acc != address(0),"地址无效!");
        balance = _xlToken.balanceOf(acc);
    }
}
