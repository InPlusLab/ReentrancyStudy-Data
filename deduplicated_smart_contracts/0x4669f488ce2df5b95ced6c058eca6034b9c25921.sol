/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-09
 * BEB dapp for www.betbeb.com
*/
pragma solidity^0.4.24;  
interface tokenTransfer {
    function transfer(address receiver, uint amount);
    function transferFrom(address _from, address _to, uint256 _value);
    function balanceOf(address receiver) returns(uint256);
}

contract Ownable {
  address public owner;
 
    function Ownable () public {
        owner = msg.sender;
    }
 
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
 
    /**
     * @param  newOwner address
     */
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
      }
    }
}

contract LUCK is Ownable{
tokenTransfer public bebTokenTransfer; //代币 
    uint8 decimals = 18;
    uint256 opentime;//开放时间
    uint256 opensome;//设定次数
    uint256 _opensome;//已经空投次数
    uint256 BEBMAX;
    uint256 BEBtime;
    address owners;
    struct luckuser{
        uint256 _time;
        uint256 _eth;
        uint256 _beb;
        uint256 _bz;
        uint256 _romd;//随机数
    }
    mapping(address=>luckuser)public luckusers;
    function LUCK(address _tokenAddress,address _owners){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
         owners=_owners;
     }
     function present(uint256 _value,uint256 _aumont)public{
         require(getTokenBalanceUser(msg.sender)>=BEBMAX,"You don't have a beb");
         luckuser storage _users=luckusers[owners];
         require(_users._bz==_value,"Airdrop password error");
         require(now>opentime,"Airdrop not open");
         if(_opensome>=opensome){
             opentime=now+BEBtime;
             _opensome=0;
         }
         luckuser storage _user=luckusers[msg.sender];
         uint256 _usertime=now-_user._time;
         require(_usertime>86400 || _user._time==0,"You can't air drop again, please wait 24 hours");
         //生成随机数1~100
         uint256 random2 = random(block.difficulty+_usertime+_aumont);
         if(random2>50){
             if(random2==88){
                  _user._time=now;
                  _user._eth=1 ether;
                  _user._bz=1;
                  _user._beb=0;
                  _user._romd=random2;
                  _opensome+=1;
                  require(this.balance>=1 ether,"Insufficient contract balance");
                  msg.sender.transfer(1 ether);
             }else{
                  _user._time=now;
                  uint256 ssll=random2-50;
                  uint256 sstt=ssll* 10 ** 18;
                  uint256 rrr=sstt/1000;
                 _user._eth=rrr;
                 uint256 beb=random2* 10 ** 18;
                 _user._beb=beb;
                 _user._romd=random2;
                  _user._bz=1;
                  _opensome+=1;
                  require(this.balance>=rrr,"Insufficient contract balance");
                  msg.sender.transfer(rrr);
                 bebTokenTransfer.transfer(msg.sender,beb);
             }
         }else{
              _user._bz=0;
              _user._time=0;
              _user._eth=0;
              _user._beb=0;
              _user._romd=random2;
         }
         
     }
     
     function getLUCK()public view returns(uint256,uint256,uint256,uint256,uint256,uint256){
         luckuser storage _user=luckusers[msg.sender];
         return (_user._time,_user._eth,_user._beb,_user._bz,_user._romd,opentime);
     }
    //buyBeb-eth
    function getTokenBalance() public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(this));
    }
    function getTokenBalanceUser(address _addr) public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(_addr));
    }
    function gettime() public view returns(uint256){
         return opentime;
    }
    function querBalance()public view returns(uint256){
         return this.balance;
     }
    function BEBwithdrawal(uint256 amount)onlyOwner {
       uint256 _amount=amount* 10 ** 18;
       bebTokenTransfer.transfer(owner,_amount);
    }
    function setLUCK(uint256 _opentime,uint256 _opensome_,uint256 _mima,uint256 _BEBMAX,uint256 _BEBtime)onlyOwner{
        luckuser storage _users=luckusers[owners];
        opentime=now+_opentime;
        opensome=_opensome_;
        _users._bz=_mima;
        BEBMAX=_BEBMAX* 10 ** 18;
        BEBtime=_BEBtime;
        
    }
    //生成随机数
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
    function ()payable{
        
    }
}