/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-09
 * BEB dapp for www.betbeb.com www.bitbeb.com
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

contract BebPos is Ownable{
tokenTransfer public bebTokenTransfer; //代币 
    uint8 decimals = 18;
   struct BebUser {
        address customerAddr;
        uint256 amount; 
        uint256 bebtime;
        uint256 interest;
    }
    //ETH miner
    struct miner{
        uint256 mining;
        uint256 _mining;
        uint256 lastDate;
        uint256 ethbomus;
        uint256 amountTotal;
        uint256 sumdays;
    }
    mapping(address=>miner)public miners;
    address[]public minersArray;
    uint256 ethExchuangeRate=190;//eth-usd
    uint256 bebethexchuang=30000;//beb-eth
    uint256 bebethex=27700;//eth-beb
    uint256 bounstotal;
    uint256 TotalInvestment;
    uint256 sumethbos;
    address minter;
    uint256 depreciationTime= 86400;
    uint256 SellBeb=100000000000000000000000;//SellBeb MAX 10000BEB
    uint256 BuyBeb=1000000000000000000000000;//BuyBeb MAX 100000BEB
    event bomus(address to,uint256 amountBouns);
    function BebPos(address _tokenAddress,address _minter){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
         minter=_minter;
     }
    //BUY minter
    function BebTomining(uint256 _value,uint usdt,address _addr)public{
         miner storage user=miners[_addr];
        if(user.lastDate!=0){
            uint256 _datetime=user.lastDate/depreciationTime;
            require(_datetime < 5,"请先结算旧矿机！");
        }
        require(_value>0);
        uint _udst=usdt* 10 ** 18;
        bebTokenTransfer.transferFrom(_addr,address(this),_value * 10 ** 18);
        TotalInvestment+=_udst;
        user.mining+=_udst;
        user._mining+=_udst;
        user.lastDate=now;
        addTominersArray(_addr);
    }
    function addTominersArray(address _Miner)internal{
        bool HasAdd=false;
        for(uint i=0;i<minersArray.length;i++){
            if(minersArray[i]==_Miner){
                HasAdd=true;
                break;
            }
        }
        if(!HasAdd){
            minersArray.push(_Miner);
        }
        
    }
    function freeSettlement()public{
        miner storage user=miners[msg.sender];
        uint256 amuont=user._mining;
        uint256 _ethbomus=user.ethbomus;
        uint256 _lastDate=user.lastDate;
        uint256 _ethbos=0;
        uint256 depreciation=(now-_lastDate)/depreciationTime;
        require(depreciation>0,"Less than 1 day of earnings");
        if(user.sumdays > 100){
           for(uint m=0;m<depreciation;m++){
              amuont=amuont*99/100;
              uint256 Bebday=amuont/100;
              _ethbos+=Bebday;
            }   
        }else{
           for(uint h=0;h<depreciation;h++){
              Bebday=amuont/100;
              _ethbos+=Bebday;
            }
             
        }
        user.sumdays+=depreciation;
        user._mining=amuont;
        user.lastDate=now;
        user.ethbomus+=_ethbos;
        user.amountTotal+=_ethbos;
            
        uint256 profit=_ethbos/ethExchuangeRate;
        require(profit>0,"Mining amount 0");
        require(this.balance>profit,"Insufficient contract balance");
        bounstotal+=profit;
        user.ethbomus=0;
        sumethbos=0;
        msg.sender.transfer(profit);
        
    }
     function querBalance()public view returns(uint256){
         return this.balance;
     }
    function querYrevenue()public view returns(uint256,uint256,uint256,uint256,uint256){
        miner storage user=miners[msg.sender];
        sumethbos=0;
        uint256 amuont=user._mining;
        uint256 _amuont=user.mining;
        uint256 percentage=amuont*100/_amuont;
        uint256 _lastDate=user.lastDate;
        uint256 dayzmount=amuont/100;
        uint256 depreciation=(now-_lastDate)/depreciationTime;
        require(depreciation>0,"Less than 1 day of earnings");
        if(user.sumdays > 100){
           for(uint m=0;m<depreciation;m++){
              amuont=amuont*99/100;
              uint256 Bebday=amuont/100;
              sumethbos+=Bebday;
            }   
        }else{
           for(uint h=0;h<depreciation;h++){
              Bebday=amuont/100;
              sumethbos+=Bebday;
            }
             
        }
        uint256 profit=sumethbos/ethExchuangeRate;
        return (percentage,dayzmount/ethExchuangeRate,profit,user.amountTotal/ethExchuangeRate,user.lastDate);
    }
    function ModifyexchangeRate(uint256 sellbeb,uint256 buybeb,uint256 _ethExchuangeRate,uint256 maxsell,uint256 maxbuy) public{
        require(msg.sender ==minter,"Insufficient"); 
        ethExchuangeRate=_ethExchuangeRate;
        bebethexchuang=sellbeb;
        bebethex=buybeb;
        SellBeb=maxsell* 10 ** 18;
        BuyBeb=maxbuy* 10 ** 18;
        
    }
    function sendEth()payable onlyOwner{
        
    }
    // sellbeb-eth
    function sellBeb(uint256 _sellbeb)public {
        uint256 _sellbebt=_sellbeb* 10 ** 18;
         require(_sellbeb>0,"The exchange amount must be greater than 0");
         require(_sellbeb<SellBeb,"More than the daily redemption limit");
         uint256 bebex=_sellbebt/bebethexchuang;
         require(this.balance>bebex,"Insufficient contract balance");
         bebTokenTransfer.transferFrom(msg.sender,address(this),_sellbebt);
         msg.sender.transfer(bebex);
    }
    //buyBeb-eth
    function buyBeb() payable public {
        uint256 amount = msg.value;
        uint256 bebamountub=amount*bebethex;
        require(getTokenBalance()>bebamountub);
        bebTokenTransfer.transfer(msg.sender,bebamountub);  
    }
    function queryRate() public view returns(uint256,uint256,uint256,uint256,uint256){
        return (ethExchuangeRate,bebethexchuang,bebethex,SellBeb,BuyBeb);
    }
    function TotalRevenue()public view returns(uint256,uint256) {
     return (bounstotal,TotalInvestment/ethExchuangeRate);
    }
    event messageBetsGame(address sender,bool isScuccess,string message);
    function getTokenBalance() public view returns(uint256){
         return bebTokenTransfer.balanceOf(address(this));
    }
    function withdrawAmount(uint256 amount) onlyOwner {
        uint256 _amountbeb=amount* 10 ** 18;
        require(getTokenBalance()>_amountbeb,"Insufficient contract balance");
       bebTokenTransfer.transfer(owner,_amountbeb);
    } 
    function ETHwithdrawal(uint256 amount) payable  onlyOwner {
       uint256 _amount=amount* 10 ** 18;
       require(this.balance>_amount,"Insufficient contract balance");
      owner.transfer(_amount);
    }
    function ()payable{
        
    }
}