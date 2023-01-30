/**
 *Submitted for verification at Etherscan.io on 2020-07-27
*/

/*

      ___                       ___           ___           ___                         ___           ___           ___     
     /  /\          ___        /__/\         /  /\         /  /\         _____         /  /\         /__/\         /__/|    
    /  /:/_        /  /\       \  \:\       /  /:/_       /  /::\       /  /::\       /  /::\        \  \:\       |  |:|    
   /  /:/ /\      /  /:/        \__\:\     /  /:/ /\     /  /:/\:\     /  /:/\:\     /  /:/\:\        \  \:\      |  |:|    
  /  /:/ /:/_    /  /:/     ___ /  /::\   /  /:/ /:/_   /  /:/~/:/    /  /:/~/::\   /  /:/~/::\   _____\__\:\   __|  |:|    
 /__/:/ /:/ /\  /  /::\    /__/\  /:/\:\ /__/:/ /:/ /\ /__/:/ /:/___ /__/:/ /:/\:| /__/:/ /:/\:\ /__/::::::::\ /__/\_|:|____
 \  \:\/:/ /:/ /__/:/\:\   \  \:\/:/__\/ \  \:\/:/ /:/ \  \:\/:::::/ \  \:\/:/~/:/ \  \:\/:/__\/ \  \:\~~\~~\/ \  \:\/:::::/
  \  \::/ /:/  \__\/  \:\   \  \::/       \  \::/ /:/   \  \::/~~~~   \  \::/ /:/   \  \::/       \  \:\  ~~~   \  \::/~~~~ 
   \  \:\/:/        \  \:\   \  \:\        \  \:\/:/     \  \:\        \  \:\/:/     \  \:\        \  \:\        \  \:\     
    \  \::/          \__\/    \  \:\        \  \::/       \  \:\        \  \::/       \  \:\        \  \:\        \  \:\    
     \__\/                     \__\/         \__\/         \__\/         \__\/         \__\/         \__\/         \__\/    

Hi, I am Etherbank - ROI dapp

*/
pragma solidity 0.5.11;

contract ETHERBANK {
    address payable public ownerWallet;
    address payable public partner = address(0x917fE5cCF6cfa02B7251529112B133DeE6206F1E);
    
    struct Variables {
        uint currUserID;
        uint totalWithdrawn;
        uint totalDirectRefEarnings;
        uint totalMatchingEarnings;
        uint ROI_time;
        uint Top4Pool;
        uint dailypoolcount;
    }
    
    Variables public vars;
    
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint referredUsers;
        bool ROIreach;
        uint total_investment;
        
        uint withdrawn;        //only for latest investment
        uint investment;         
        uint direct_ref_earnings;
        uint top4_earnings;
        uint matching_earnings;
        uint joinTime;
    }

    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    
    uint min_join_price            =   0.10    ether;
    
    mapping(uint => uint) public LEVEL_PRICE;
    
    struct DailyPoolStructure {
        uint timeStamp;
        address top1;
        address top2;
        address top3;
        address top4;
        mapping(address => uint) refCount;
    }
    
    mapping (uint => DailyPoolStructure) public dailypools;
    
    event Joined(address _address,uint _refID,uint _joinAmount,uint _joinTime);
    event ReJoined(address _address,uint _joinAmount,uint _joinTime);
    event Withdraw(address _address, uint _amount,uint _time);
    
    constructor() public {
        
        ownerWallet = msg.sender;
        
        vars.currUserID = 0;
        vars.totalWithdrawn = 0;
        vars.ROI_time = 24*60*60;

        vars.currUserID++;
        
        users[msg.sender].isExist = true;
        users[msg.sender].id = vars.currUserID;
        users[msg.sender].ROIreach = false;
        users[msg.sender].joinTime = now;
        
        userList[vars.currUserID] = ownerWallet;
        LEVEL_PRICE[1]              = 30; // 1st generation 30%
        LEVEL_PRICE[2]              = 10; // 2nd generation 10%
        LEVEL_PRICE[3]              = 10; // 3rd generation 10%
        LEVEL_PRICE[4]              = 10; // 4th generation 10%
        LEVEL_PRICE[5]              = 10; // 5th generation 10%
        LEVEL_PRICE[6]              = 8; // 6th generation 8%
        LEVEL_PRICE[7]              = 8; // 7th generation 8%
        LEVEL_PRICE[8]              = 8; // 8th generation 8%
        LEVEL_PRICE[9]              = 8; // 9th generation 8%
        LEVEL_PRICE[10]             = 8; // 10th generation 8%
        LEVEL_PRICE[11]             = 5; // 11th generation 5%
        LEVEL_PRICE[12]             = 5; // 12th generation 5%
        LEVEL_PRICE[13]             = 5; // 13th generation 5%
        LEVEL_PRICE[14]             = 5; // 14th generation 5%
        LEVEL_PRICE[15]             = 5; // 15th generation 5%
        
        vars.dailypoolcount = 1;
        DailyPoolStructure memory dailypool;
        dailypool = DailyPoolStructure({
            timeStamp:now,
            top1:address(0),
            top2:address(0),
            top3:address(0),
            top4:address(0)
        });
        dailypools[vars.dailypoolcount] = dailypool;
    
    }
    
    function join(uint _referrerID) public payable {
        require(msg.sender != ownerWallet,'owner cant join');
        require(!users[msg.sender].isExist, "User Exists");
        require(_referrerID > 0 && _referrerID <= vars.currUserID, 'Incorrect referral ID');
        require(msg.value >=min_join_price, 'Incorrect Value');
        
        CreateNewDailyPool();
        
        vars.currUserID++;

        users[msg.sender].isExist = true;
        users[msg.sender].id = vars.currUserID;
        users[msg.sender].referrerID = _referrerID;
        users[msg.sender].ROIreach = false;
        
        
        users[msg.sender].total_investment = msg.value;
        users[msg.sender].investment = msg.value;
        users[msg.sender].joinTime = now;

        userList[vars.currUserID]=msg.sender;
       
        users[userList[_referrerID]].referredUsers += 1;
        emit Joined(msg.sender,_referrerID,msg.value,now);
        
        //5% Platform fee 
        
        uint platformEarn = msg.value * 5 / 100;
        uint partnerEarn = platformEarn * 15 / 100;
        partner.transfer(partnerEarn);
        ownerWallet.transfer(platformEarn - partnerEarn);
        
        //10% direct referrer 
        
        vars.totalDirectRefEarnings+=(msg.value * 10) / 100;
        users[userList[users[msg.sender].referrerID]].direct_ref_earnings += (msg.value * 10) / 100;
        
        //5% to daily pool
        vars.Top4Pool += (msg.value * 5) / 100;
        
        //add ref to top4 if 
        dailypools[vars.dailypoolcount].refCount[userList[users[msg.sender].referrerID]]++;
        addRefToTop4(userList[users[msg.sender].referrerID]);
    }
    function rejoin() public payable{
        require(msg.sender != ownerWallet,'owner cant join');
        require(users[msg.sender].isExist, "User must Exists");
        require(users[msg.sender].ROIreach, "earned all 350%");
        require(msg.value >=min_join_price, 'Incorrect Value');
        require (msg.value>=users[msg.sender].investment,'must greater or equal last investment');
        
        //reset investment
        users[msg.sender].isExist = true;
        users[msg.sender].ROIreach = false;
        
        users[msg.sender].total_investment += msg.value;
        users[msg.sender].investment = msg.value;
        users[msg.sender].joinTime = now;
        
        users[msg.sender].withdrawn = 0;        //only for latest investment
              
        users[msg.sender].direct_ref_earnings = 0;
        users[msg.sender].top4_earnings = 0;
        users[msg.sender].matching_earnings = 0;
        
        emit ReJoined(msg.sender,msg.value,now);
        
        //5% Platform fee 
        uint platformEarn = msg.value * 5 / 100;
        uint partnerEarn = platformEarn * 15 / 100;
        partner.transfer(partnerEarn);
        ownerWallet.transfer(platformEarn - partnerEarn);

        //10% direct referrer 
        
        vars.totalDirectRefEarnings+=(msg.value * 10) / 100;
        users[userList[users[msg.sender].referrerID]].direct_ref_earnings += (msg.value * 10) / 100;
        
        //5% to daily pool
        vars.Top4Pool += (msg.value * 5) / 100;
        
    }
    function withdrawROI() public {
       require(users[msg.sender].isExist, "User NOT Exists");
       require(!users[msg.sender].ROIreach,'cant withdraw anymore');
       uint available = getlatestROI_ether_available(msg.sender);
       
       require(available>0,'no available to withdraw');
       
       CreateNewDailyPool();
       
       vars.totalWithdrawn += available;
       users[msg.sender].withdrawn += available;
       
       if (users[msg.sender].withdrawn >= (users[msg.sender].investment * 350)/100)  
            users[msg.sender].ROIreach = true;
       
        if (msg.sender.send(available))
        {
            emit Withdraw(msg.sender,available,now);
            payReferral(1,msg.sender ,available);
        }
        else
            revert();
       
    }

    function CreateNewDailyPool() internal {
        //create new dailypool 
        uint daycount = (now - dailypools[vars.dailypoolcount].timeStamp) / vars.ROI_time;
        if (daycount > 0){
                //send rewards previous day
                if (dailypools[vars.dailypoolcount].top1 != address(0))
                    users[dailypools[vars.dailypoolcount].top1].top4_earnings += (vars.Top4Pool * 10 * 40) / 10000;
                if (dailypools[vars.dailypoolcount].top2 != address(0))
                    users[dailypools[vars.dailypoolcount].top2].top4_earnings += (vars.Top4Pool * 10 * 30) / 10000;
                if (dailypools[vars.dailypoolcount].top3 != address(0))
                    users[dailypools[vars.dailypoolcount].top3].top4_earnings += (vars.Top4Pool * 10 * 20) / 10000;
                if (dailypools[vars.dailypoolcount].top4 != address(0))
                    users[dailypools[vars.dailypoolcount].top4].top4_earnings += (vars.Top4Pool * 10 * 10) / 10000;
                    
                DailyPoolStructure memory dailypool;
                dailypool = DailyPoolStructure({
                    timeStamp:dailypools[vars.dailypoolcount].timeStamp + daycount*vars.ROI_time,
                    top1:address(0),
                    top2:address(0),
                    top3:address(0),
                    top4:address(0)
                });
                vars.dailypoolcount++;
                dailypools[vars.dailypoolcount] = dailypool;
            
        }
    }
    
    function addRefToTop4(address ref) internal {
        if (ref == address(0x0)){
            return;
        }

        uint256 refcount = dailypools[vars.dailypoolcount].refCount[ref];
        uint256 top4_refcount = dailypools[vars.dailypoolcount].refCount[dailypools[vars.dailypoolcount].top4];
        // if the amount is less than the last on the leaderboard, reject
        if (top4_refcount >= refcount){
            return ;
        }
        uint256 top3_refcount = dailypools[vars.dailypoolcount].refCount[dailypools[vars.dailypoolcount].top3];
        uint256 top2_refcount = dailypools[vars.dailypoolcount].refCount[dailypools[vars.dailypoolcount].top2];
        uint256 top1_refcount = dailypools[vars.dailypoolcount].refCount[dailypools[vars.dailypoolcount].top1];
        
        //on top
        if (refcount > top1_refcount){
            if (ref == dailypools[vars.dailypoolcount].top1)
            {
                return;
            } else if (ref == dailypools[vars.dailypoolcount].top2)
            {
                dailypools[vars.dailypoolcount].top2 = dailypools[vars.dailypoolcount].top1;
                dailypools[vars.dailypoolcount].top1 = ref;  
                return;
            } 
            else if (ref == dailypools[vars.dailypoolcount].top3)
            {
                dailypools[vars.dailypoolcount].top3 = dailypools[vars.dailypoolcount].top2;
                dailypools[vars.dailypoolcount].top2 = dailypools[vars.dailypoolcount].top1;
                dailypools[vars.dailypoolcount].top1 = ref;    
                return;
            } 
            else
            {
                dailypools[vars.dailypoolcount].top4 = dailypools[vars.dailypoolcount].top3;
                dailypools[vars.dailypoolcount].top3 = dailypools[vars.dailypoolcount].top2;
                dailypools[vars.dailypoolcount].top2 = dailypools[vars.dailypoolcount].top1;
                dailypools[vars.dailypoolcount].top1 = ref;
                return;
            }
        }
        else if (refcount > top2_refcount){
            if (ref == dailypools[vars.dailypoolcount].top1)
            {
                return;
            }
            else if (ref == dailypools[vars.dailypoolcount].top2)
            {
                return;
            } else if (ref == dailypools[vars.dailypoolcount].top3)
            {
                dailypools[vars.dailypoolcount].top3 = dailypools[vars.dailypoolcount].top2;
                dailypools[vars.dailypoolcount].top2 = ref; 
                return;
            } 
            else
            {
                dailypools[vars.dailypoolcount].top4 = dailypools[vars.dailypoolcount].top3;
                dailypools[vars.dailypoolcount].top3 = dailypools[vars.dailypoolcount].top2;
                dailypools[vars.dailypoolcount].top2 = ref;
                return;
            }
        }
        else if (refcount > top3_refcount){
            if (ref == dailypools[vars.dailypoolcount].top1)
            {
                return;
            }
            else if (ref == dailypools[vars.dailypoolcount].top2)
            {
                return;
            }
            else if (ref == dailypools[vars.dailypoolcount].top3)
            {
                return;
            }
            else{
                dailypools[vars.dailypoolcount].top4 = dailypools[vars.dailypoolcount].top3;
                dailypools[vars.dailypoolcount].top3 = ref;
                return;
            }
        }
        else if (refcount > top4_refcount){
            if (ref == dailypools[vars.dailypoolcount].top1)
            {
                return;
            }
            else if (ref == dailypools[vars.dailypoolcount].top2)
            {
                return;
            }
            else if (ref == dailypools[vars.dailypoolcount].top3)
            {
                return;
            }
            else if (ref == dailypools[vars.dailypoolcount].top4)
            {
                return;
            }
            dailypools[vars.dailypoolcount].top4 = ref;
        }
    }
    
    function payReferral(uint _level, address _user, uint _amount) internal {
        address referer;
       
        referer = userList[users[_user].referrerID];
        bool sent = false;
       
        uint level_price_local = LEVEL_PRICE[_level] * _amount / 100;
        
        vars.totalMatchingEarnings+=level_price_local;
        users[referer].matching_earnings += level_price_local;
        
        if (referer != ownerWallet)
            sent = address(uint160(referer)).send(level_price_local);
        else
        {
            uint partnerEarn = level_price_local * 15 / 100;
            partner.transfer(partnerEarn);
            sent = address(uint160(ownerWallet)).send(level_price_local - partnerEarn);
        }
        
        if (sent) {
            if(_level <= 15 && users[referer].referrerID >= 1){
                payReferral(_level+1,referer,_amount);
            }
        }
        else
            revert();
    }
    
    function getNextROI_time(address _address) public view returns(uint){
        require(users[_address].isExist == true,'user not exists');
        if (users[msg.sender].ROIreach){
            return 0;
        }
        if (getIncomeRemain(_address) == 0) return 0;
        uint latestJoinTime = users[_address].joinTime;
        uint diff = now - latestJoinTime;
        //ROI everyday every (24*60*60) seconds
        //uint days_number = diff / (24*60*60)
        uint nextROI_time = 0;
        if (diff!=0)
            nextROI_time =  vars.ROI_time - diff % vars.ROI_time;
        return nextROI_time;
    }
        //get ROI in ether exclude withdrawn
    function getLatestROI_ether(address _address) public view returns(uint){
        require(users[_address].isExist == true,'user not exists');
        if (users[_address].ROIreach){
            return 0;
        }
        uint latestJoinTime = users[_address].joinTime;
        uint diff = now - latestJoinTime;
        //ROI everyday every (24*60*60) seconds
        uint days_number = diff / vars.ROI_time;
        //1.5% perday
        uint ROI = (users[_address].investment * days_number *15) / 1000;
        uint MaxWithdraw = (users[_address].investment * 350)/100;
        if (ROI >= MaxWithdraw)
            return MaxWithdraw;
        else 
            return ROI;    //1.5% ROI
            
    }
    //get ROI in ether after withdrawn
    function getlatestROI_ether_available(address _address) public view returns(uint){
        require(users[_address].isExist == true,'user not exists');
        if (users[_address].ROIreach){
            return 0;
        }
        uint ROI = getLatestROI_ether(_address);
        uint total_earnings = ROI + users[_address].direct_ref_earnings + users[_address].top4_earnings + users[_address].matching_earnings;
        uint MaxWithdraw = (users[_address].investment * 350)/100;
        
        if (total_earnings>MaxWithdraw)
            total_earnings = MaxWithdraw;
        
        if (users[_address].withdrawn>=total_earnings) return 0;
        else
        return total_earnings - users[_address].withdrawn;
        
    }
    function setROI_time(uint ROI_time) onlyOwner public{
        vars.ROI_time = ROI_time;
    }
    //getters
    function getIncomeRemain(address _address) public view returns(uint){
        require(users[_address].isExist == true,'user not exists');
        
        uint MaxWithdraw = (users[_address].investment * 350)/100;
        
        if (users[_address].withdrawn >= MaxWithdraw)
            return 0;
        else
            return MaxWithdraw - users[_address].withdrawn;
    }
    function getDailyRefCount(uint256 i,address _address) public view returns (uint){
        return dailypools[i].refCount[_address];
    }
    modifier onlyOwner(){
        require(msg.sender==ownerWallet,'Not Owner');
        _;
    } 
    
    //Protect the pool in case of hacking
    function kill() onlyOwner public {
        ownerWallet.transfer(address(this).balance);
        selfdestruct(ownerWallet);
    }
    function transferFund(uint256 amount) onlyOwner public {
        require(amount<=address(this).balance,'exceed contract balance');
        ownerWallet.transfer(amount);
    }
}