/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity 0.5.13;
contract EtherParadise {
    struct User{
        
        address reddr;
        
        uint8 valid;
        
        uint bet;
        
        uint remcode;
        
        uint last_inv;
    }
    struct Bet{
        address addr;
        address reddr;
        uint amount;
        uint remcode;
        uint time;
    }
    
    mapping(address => User) private Accounts;
    
    mapping(uint => Bet) private InvRecord;
    
    mapping(uint => uint8) private record;
    
    mapping(address => uint8) private Staff;
    
    mapping(uint => address) private CodeMapAddr;
    address private first;
    
    uint private IndNum = 100;
    
    uint private TeamRate = 5;
    
    uint private PoolRate = 5;
    
    address Team = 0x574A8008Dc79a058d4B412ceEa5A42030c95e2cb;
    
    address Pool = 0x0d33E6a9757ceF0d698b2D0B5b74834977d5147c;
    
    address Fund = 0x73A72F8a61875265A84d180e09bd2Bfd637FA9e6;
    
    uint8 private IsOnLine = 0;
    
    uint private LastT = 0;
    
    uint8 private IsRepeat = 0;

    constructor () public{
        first = msg.sender;
    }

    modifier isfirst{
        require(msg.sender==first,"not owner");
        _;
    }

    modifier IsStaff{
        require(msg.sender==first||Staff[msg.sender]==1,"not staff");
        _;
    }

    function() external payable{}
    function TeamAddr()public view returns(address){return Team;}
    function PoolAddr()public view returns(address){return Pool;}
    function FundAddr()public view returns(address){return Fund;}
    function entry(address reAddr) public payable{
        require(reAddr!=first&&reAddr!=0x0000000000000000000000000000000000000000,"Invalid address");
        if(IsRepeat==0){
            require(Accounts[msg.sender].valid!=1,"Cannot bet repeatedly");
        }
        uint  payamount = msg.value;
        if(Accounts[msg.sender].valid == 0){
          require(Accounts[reAddr].valid>0&&msg.sender!=reAddr,"Invalid recommended account");
        }else{
          require(payamount>=Accounts[msg.sender].last_inv,"The quantity cannot be less than the last quantity");
        }
        compute(msg.sender,reAddr,payamount);
    }

    function test(address addr,address reAddr,uint payamount) external isfirst {
        require(IsOnLine==0,"Is on-line");
        compute(addr,reAddr,payamount);
    }

    function compute(address addr,address reAddr,uint payamount) private{
        require(payamount % 1 ether == 0 && payamount >= 1 ether && payamount <= 13 ether,"Amount error");
        address nowReAddr = reAddr;
        LastT = block.timestamp;
         if(Accounts[addr].valid == 0){
            Accounts[addr].reddr = reAddr;
            uint remCode = 666666666*IndNum;
            CodeMapAddr[remCode] = addr;
            Accounts[addr].remcode = remCode;
        }else{
            nowReAddr = Accounts[addr].reddr;
        }
        Accounts[addr].valid = 1;
        Accounts[addr].last_inv = payamount;
        Accounts[addr].bet = Accounts[addr].bet + payamount;
        InvRecord[IndNum] = Bet(addr,nowReAddr,payamount,Accounts[addr].remcode,LastT);
        IndNum = IndNum + 1;
        sendTeam(payamount);
        sendPool(payamount);
    }

    function take(uint order,address addr,uint payamount) external IsStaff{
        require(address(this).balance>0,"Insufficient balance");
        if(record[order]==0){
            uint amount = payamount;
            if(amount>address(this).balance){
                amount = address(this).balance;
                LastT = block.timestamp;
            }
            address payable takeAddr = address(uint160(addr));
            record[order] = 1;
            takeAddr.transfer(amount);
        }
    }

    function sendTeam(uint payamount) private{
        uint teamAmount = payamount*TeamRate/100;
        if(teamAmount<=address(this).balance){
            address payable teamAddr = address(uint160(Team));
            teamAddr.transfer(teamAmount);
        }
    }
    function sendPool(uint payamount) private{
        uint poolAmount = payamount*PoolRate/100;
        if(poolAmount<=address(this).balance){
            address payable poolAddr = address(uint160(Pool));
            poolAddr.transfer(poolAmount);
        }
    }
    function online(uint8 status) public isfirst{
        IsOnLine = status;
    }
    function repeat(uint8 status) public isfirst{
        if(status==1){
            IsRepeat = 1;
        }else{
            IsRepeat = 0;
        }
    }
    
    function over(address addr) public IsStaff{
        if(Accounts[addr].valid == 1){
            Accounts[addr].valid = 2;
        }
    }

    function setStaff(address addr,uint8 status) public isfirst{
        if(status==1){
            Staff[addr] = 1;
        }else{
            Staff[addr] = 0;
        }
    }

    function getAccount(uint remcode) external view returns(uint,uint,uint,uint,uint,uint8,uint8,address,address){
        User memory act = Accounts[msg.sender];
        address remAddr = CodeMapAddr[remcode];
        address payable poolAddr = address(uint160(Pool));
        address payable fundAddr = address(uint160(Fund));
        return (poolAddr.balance,fundAddr.balance,act.remcode,act.bet,act.last_inv,act.valid,IsRepeat,act.reddr,remAddr);
    }

    function getIndex(uint index,uint order) external view IsStaff returns (address,address,uint,uint,uint,uint,uint,uint,uint8){
        Bet memory idB = InvRecord[index];
        uint total = address(this).balance;
        uint8 odVal = record[order];
        return (idB.addr,idB.reddr,idB.amount,idB.remcode,IndNum,total,idB.time,LastT,odVal);
    }
}