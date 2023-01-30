/**
 *Submitted for verification at Etherscan.io on 2019-09-09
*/

pragma solidity ^0.4.24;

contract  UtilEtherTest  {



    function getRecommendScaleBylevelandTim(uint level,uint times) public view returns(uint);
    function compareStr (string _str,string str) public view returns(bool);
    function getLineLevel(uint value) public view returns(uint);
    function getScBylevel(uint level) public view returns(uint);
    function getFireScBylevel(uint level) public view returns(uint);
    function getlevel(uint value) public view returns(uint);
}
contract EtherTest {



    uint ethWei = 0.001 ether;
    uint allCount = 0;
    uint oneDayCount = 0;
    uint totalMoney = 0;
    uint totalCount = 0;
	uint private beginTime = 1;
    uint lineCountTimes = 1;
	uint private currentIndex = 0;
	address private owner;
	uint private actStu = 0;

	constructor () public {
        owner = msg.sender;
    }
	struct User{

        address ethAddress;//用户地址
        uint freeAmount;
        uint freezeAmount;//冻结金额
        uint rechargeAmount;//充值金额
        uint withdrawlsAmount;//提现金额
        uint inviteAmonut;
        uint bonusAmount;//奖金
        uint dayInviteAmonut;
        uint dayBonusAmount;
        uint level;//级别
        uint resTime;//恢复时间
        uint lineAmount;//在线金额
        uint lineLevel;//在线级别
        string inviteCode;//邀请码
        string beInvitedCode;
		uint isline;
		uint status; //状态
		bool isVaild;//是否有效
    }

    struct BonusGame{//投资

        address ethAddress;//地址
        uint inputAmount;//数量
        uint resTime;//时间
        string inviteCode;//邀请码
        string beInvitedCode;//被邀请码
		uint isline;
		uint status;
		uint times;
    }

    mapping (address => User) userMapping;
    mapping (string => address) addressMapping;
    mapping (uint => address) indexMapping;

    BonusGame[] game;
    UtilEtherTest  util = UtilEtherTest(0x0ED5Cc0231dDc04545A57430152D1e9E91e111e4);

    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    function () public payable {
    }

     function invest(address ethAddress ,uint inputAmount,string  inviteCode,string  beInvitedCode) public payable{

        ethAddress = msg.sender;
  		inputAmount = msg.value;
        uint lineAmount = inputAmount;

        if(!getUserByinviteCode(beInvitedCode)){
            ethAddress.transfer(msg.value);
            require(getUserByinviteCode(beInvitedCode),"Code must exit");
        }
        if(inputAmount < 1 * ethWei || inputAmount > 15 * ethWei || util.compareStr(inviteCode,"")){
             ethAddress.transfer(msg.value);
                require(inputAmount >= 1* ethWei && inputAmount <= 15* ethWei && !util.compareStr(inviteCode,""), "between 1 and 15");
        }
        User storage userTest = userMapping[ethAddress];
        if(userTest.isVaild && userTest.status != 2){
            if((userTest.lineAmount + userTest.freezeAmount + lineAmount)> (15 * ethWei)){
                ethAddress.transfer(msg.value);
                require((userTest.lineAmount + userTest.freezeAmount + lineAmount) <= 15 * ethWei,"can not beyond 15 eth");
                return;
            }
        }
       totalMoney = totalMoney + inputAmount;
        totalCount = totalCount + 1;
        bool isLine = false;

        uint level =util.getlevel(inputAmount);
        uint lineLevel = util.getLineLevel(lineAmount);
        if(beginTime==1){
            lineAmount = 0;
            oneDayCount = oneDayCount + inputAmount;
            BonusGame memory invest = BonusGame(ethAddress,inputAmount,now, inviteCode, beInvitedCode ,1,1,0);
            game.push(invest);
            sendFeetoAdmin(inputAmount);
			sendFeetoLuckdraw(inputAmount);
        }else{
            allCount = allCount + inputAmount;
            isLine = true;
            invest = BonusGame(ethAddress,inputAmount,now, inviteCode, beInvitedCode ,0,1,0);
            inputAmount = 0;
            game.push(invest);
        }
          User memory user = userMapping[ethAddress];
            if(user.isVaild && user.status == 1){
                user.freezeAmount = user.freezeAmount + inputAmount;
                user.rechargeAmount = user.rechargeAmount + inputAmount;
                user.lineAmount = user.lineAmount + lineAmount;
                level =util.getlevel(user.freezeAmount);
                lineLevel = util.getLineLevel(user.freezeAmount + user.freeAmount +user.lineAmount);
                user.level = level;
                user.lineLevel = lineLevel;
                userMapping[ethAddress] = user;

            }else{
                if(isLine){
                    level = 0;
                }
                if(user.isVaild){
                   inviteCode = user.inviteCode;
                   beInvitedCode = user.beInvitedCode;
                }
                user = User(ethAddress,0,inputAmount,inputAmount,0,0,0,0,0,level,now,lineAmount,lineLevel,inviteCode, beInvitedCode ,1,1,true);
                userMapping[ethAddress] = user;

                indexMapping[currentIndex] = ethAddress;
                currentIndex = currentIndex + 1;
            }
            address  ethAddressCode = addressMapping[inviteCode];
            if(ethAddressCode == 0x0000000000000000000000000000000000000000){
                addressMapping[inviteCode] = ethAddress;
            }

    }

      function remedy(address ethAddress ,uint freezeAmount,string  inviteCode,string  beInvitedCode ,uint freeAmount,uint times) public {
        require(actStu == 0,"this action was closed");
        freezeAmount = freezeAmount * ethWei;
        freeAmount = freeAmount * ethWei;
        uint level =util.getlevel(freezeAmount);
        uint lineLevel = util.getLineLevel(freezeAmount + freeAmount);
        if(beginTime==1 && freezeAmount > 0){
            BonusGame memory invest = BonusGame(ethAddress,freezeAmount,now, inviteCode, beInvitedCode ,1,1,times);
            game.push(invest);
        }
          User memory user = userMapping[ethAddress];
            if(user.isVaild){
                user.freeAmount = user.freeAmount + freeAmount;
                user.freezeAmount = user.freezeAmount +  freezeAmount;
                user.rechargeAmount = user.rechargeAmount + freezeAmount +freezeAmount;
                user.level =util.getlevel(user.freezeAmount);
                user.lineLevel = util.getLineLevel(user.freezeAmount + user.freeAmount +user.lineAmount);
                userMapping[ethAddress] = user;
            }else{
                user = User(ethAddress,freeAmount,freezeAmount,freeAmount+freezeAmount,0,0,0,0,0,level,now,0,lineLevel,inviteCode, beInvitedCode ,1,1,true);
                userMapping[ethAddress] = user;

                indexMapping[currentIndex] = ethAddress;
                currentIndex = currentIndex + 1;
            }
            address  ethAddressCode = addressMapping[inviteCode];
            if(ethAddressCode == 0x0000000000000000000000000000000000000000){
                addressMapping[inviteCode] = ethAddress;
            }

    }
     //用户提币
    function ethWithDraw(address ethAddress) public{
        bool success = false;
        require (msg.sender == ethAddress, "account diffrent");

         User memory user = userMapping[ethAddress];
         uint sendMoney  = user.freeAmount;

        bool isEnough = false ;
        uint resultMoney = 0;
        (isEnough,resultMoney) = isEnoughBalance(sendMoney);

            user.withdrawlsAmount =user.withdrawlsAmount + resultMoney;
            user.freeAmount = user.freeAmount - resultMoney;
            user.level = util.getlevel(user.freezeAmount);
            user.lineLevel = util.getLineLevel(user.freezeAmount + user.freeAmount);
            userMapping[ethAddress] = user;
            if(resultMoney > 0 ){
                ethAddress.transfer(resultMoney);
            }
    }

    //计算数量和奖励
    function countShareAndRecommendedAward(uint startLength ,uint endLength,uint times) external onlyOwner {

        for(uint i = startLength; i < endLength; i++) {
            BonusGame memory invest = game[i];
             address  ethAddressCode = addressMapping[invest.inviteCode];
            User memory user = userMapping[ethAddressCode];
            if(invest.isline==1 && invest.status == 1 && now < (invest.resTime + 5 days) && invest.times <5){
             game[i].times = invest.times + 1;
               uint scale = util.getScBylevel(user.level);
                user.dayBonusAmount =user.dayBonusAmount + scale*invest.inputAmount/1000;
                user.bonusAmount = user.bonusAmount + scale*invest.inputAmount/1000;
                userMapping[ethAddressCode] = user;

            }else if(invest.isline==1 && invest.status == 1 && ( now >= (invest.resTime + 5 days) || invest.times >= 5 )){
                game[i].status = 2;
                user.freezeAmount = user.freezeAmount - invest.inputAmount;
                user.freeAmount = user.freeAmount + invest.inputAmount;
                user.level = util.getlevel(user.freezeAmount);
                userMapping[ethAddressCode] = user;
            }
        }
    }

    function countRecommend(uint startLength ,uint endLength,uint times) public {//推荐数量计算
        require ((msg.sender == owner), "");
         for(uint i = startLength; i <= endLength; i++) {

            address ethAddress = indexMapping[i];
            if(ethAddress != 0x0000000000000000000000000000000000000000){

                User memory user =  userMapping[ethAddress];
                if(user.status == 1 && user.freezeAmount >= 1 * ethWei){
                    uint scale = util.getScBylevel(user.level);
                    execute(user.beInvitedCode,1,user.freezeAmount,scale);
                }
            }
        }
    }


    function execute(string inviteCode,uint runtimes,uint money,uint shareSc) private  returns(string,uint,uint,uint) {

        string memory codeOne = "null";

        address  ethAddressCode = addressMapping[inviteCode];
        User memory user = userMapping[ethAddressCode];

        if (user.isVaild && runtimes <= 25){
            codeOne = user.beInvitedCode;
              if(user.status == 1){

                  uint fireSc = util.getFireScBylevel(user.lineLevel);
                  uint recommendSc = util.getRecommendScaleBylevelandTim(user.lineLevel,runtimes);
                  uint moneyResult = 0;

                  if(money <= (user.freezeAmount+user.lineAmount+user.freeAmount)){
                      moneyResult = money;
                  }else{
                      moneyResult = user.freezeAmount+user.lineAmount+user.freeAmount;
                  }

                  if(recommendSc != 0){
                      user.dayInviteAmonut =user.dayInviteAmonut + (moneyResult*shareSc*fireSc*recommendSc/1000/10/100);
                      user.inviteAmonut = user.inviteAmonut + (moneyResult*shareSc*fireSc*recommendSc/1000/10/100);
                      userMapping[ethAddressCode] = user;
                  }
              }
              return execute(codeOne,runtimes+1,money,shareSc);
        }
        return (codeOne,0,0,0);

    }

    function sendMoneyToUser(address ethAddress, uint money) private {
        address send_to_address = ethAddress;
        uint256 _eth = money;
        send_to_address.transfer(_eth);

    }

    function sendAward(uint startLength ,uint endLength,uint times)  external onlyOwner  {

         for(uint i = startLength; i <= endLength; i++) {

            address ethAddress = indexMapping[i];
            if(ethAddress != 0x0000000000000000000000000000000000000000){

                User memory user =  userMapping[ethAddress];
                if(user.status == 1){
                    uint sendMoney =user.dayInviteAmonut + user.dayBonusAmount;

                    if(sendMoney >= (ethWei/10)){
                         sendMoney = sendMoney - (ethWei/1000);
                        bool isEnough = false ;
                        uint resultMoney = 0;
                        (isEnough,resultMoney) = isEnoughBalance(sendMoney);
                        if(isEnough){
                            sendMoneyToUser(user.ethAddress,resultMoney);
                            //
                            user.dayInviteAmonut = 0;
                            user.dayBonusAmount = 0;
                            userMapping[ethAddress] = user;
                        }else{
                            userMapping[ethAddress] = user;
                            if(sendMoney > 0 ){
                                sendMoneyToUser(user.ethAddress,resultMoney);
                                user.dayInviteAmonut = 0;
                                user.dayBonusAmount = 0;
                                userMapping[ethAddress] = user;
                            }
                        }
                    }
                }
            }
        }
    }

    function isEnoughBalance(uint sendMoney) private view returns (bool,uint){

        if(this.balance > 0 ){
             if(sendMoney >= this.balance){
                if((this.balance ) > 0){
                    return (false,this.balance);
                }else{
                    return (false,0);
                }
            }else{
                 return (true,sendMoney);
            }
        }else{
             return (false,0);
        }
    }

    function getUserByAddress(address ethAddress) public view returns(uint,uint,uint,uint,uint,uint,uint,uint,uint,string,string,uint){

            User memory user = userMapping[ethAddress];
            return (user.lineAmount,user.freeAmount,user.freezeAmount,user.inviteAmonut,
            user.bonusAmount,user.lineLevel,user.status,user.dayInviteAmonut,user.dayBonusAmount,user.inviteCode,user.beInvitedCode,user.level);
    }
    function getUserByinviteCode(string inviteCode) public view returns (bool){

        address  ethAddressCode = addressMapping[inviteCode];
        User memory user = userMapping[ethAddressCode];
      if (user.isVaild){
            return true;
      }
        return false;
    }
    function getSomeInfo() public view returns(uint,uint,uint){
        return(totalMoney,totalCount,beginTime);
    }
    function test() public view returns(uint,uint,uint){
        return (game.length,currentIndex,actStu);
    }
     function sendFeetoAdmin(uint amount) private {
        address adminAddress = 0x0ED5Cc0231dDc04545A57430152D1e9E91e111e4;
        adminAddress.transfer(amount/25);
    }
	 function sendFeetoLuckdraw(uint amount) private {
	        address LuckdrawAddress = 0xb6334EC4C7d77174d7d6405eB10D2f23DB94DD97;
	        LuckdrawAddress.transfer(amount/100);
	    }
    function closeAct()  external onlyOwner {
        actStu = 1;
    }
}