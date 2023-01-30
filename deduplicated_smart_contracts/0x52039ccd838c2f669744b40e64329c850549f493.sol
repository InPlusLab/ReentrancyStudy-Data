/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

/**
 *Submitted for verification at Etherscan.io on 2020-03-07
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

contract BEBchain is Ownable{
     tokenTransfer public bebTokenTransfer; //代币USDT
    address oneaddress;//第一个管理员
     address twoaddress;//第一个管理员
     uint256 ethpoint;//ETH价格 
     uint256 BEBpoint;//ETH价格 
      uint256 BuyAmount;
     struct bebuser{
         address addr;
         uint256 amount;
         uint256 _lsh;
         uint256 _time;
         string bz;
     }
    mapping(address=>bool)public looks;
    mapping(uint256=>bebuser)public bebusers;
     function BEBchain(address _tokenAddress){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
     }
     function withdrawToEth(address _addr,uint256 _value)onlyOwner{
         require(looks[oneaddress] && looks[twoaddress]);
         _addr.transfer(_value);
         looks[oneaddress]=false;
         looks[twoaddress]=false;
     }
     function withdrawToUsdt(address _addr,uint256 _value)onlyOwner{
         require(looks[oneaddress] && looks[twoaddress]);
         bebTokenTransfer.transfer(_addr,_value);
         looks[oneaddress]=false;
         looks[twoaddress]=false;
     }
     function setAdmin(address _oneaddress,address _twoaddress)onlyOwner{
         twoaddress=_twoaddress;
         oneaddress=_oneaddress;
     }
     function setAdminOneaddress()public{
         require(oneaddress==msg.sender);
         looks[oneaddress]=true;
     }
     function setAdminTwoaddress()public{
         require(twoaddress==msg.sender);
         looks[twoaddress]=true;
     }
     function ethBuyBeb(uint256 _lsh)payable public{
         bebuser storage _user=bebusers[_lsh];
         uint256 _value=msg.value;
         require(_value>0 && _lsh>0);
         _user.amount =_value;//充值金额纪录
        _user._lsh=_lsh;//充值时间
        _user.addr=msg.sender;//充值地址
        _user.bz="ETH兑换BEB";//状态为用户充值
        _user._time=now;
         BuyAmount+=_value;
     }
    //后台输入充值流水号查询用户充值金额
    function getwater(uint256 _lsh) public view returns(address,uint256,uint256,uint256,string){
         bebuser storage _user=bebusers[_lsh];
         return (_user.addr,_user.amount,_user._time,_user._lsh,_user.bz);
    }
     function getadmin() public view returns(address,address,address){
         return (oneaddress,twoaddress,owner);
    }
    function getbuy() public view returns(uint256){
         return BuyAmount;
    }
    function getUSDT() public view returns(uint256){
         return bebTokenTransfer.balanceOf(this);
    }
    function ()payable{
        
    }
}