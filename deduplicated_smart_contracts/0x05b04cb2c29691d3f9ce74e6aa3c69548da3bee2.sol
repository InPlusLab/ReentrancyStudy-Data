/**

 *Submitted for verification at Etherscan.io on 2019-03-13

*/



pragma solidity ^0.4.25;



contract EtherStateEquivalentToken {

    address public owner;

    mapping (address => uint256) public tokenBalance;

    mapping (address => uint256) public refBalance;

    

    uint256 public tokenPrice = 0.0004 ether; 

    uint256 public tokenSupply = 0;

    uint256 constant public softCap =  2500000 ether;

    uint256 constant public hardCap = 10000000 ether;

    uint256 public start;

    uint256 public softCapMoment = 0;

    uint256 public softCapPeriod = 1483300; //17 * 24 * 60 * 60;

    uint256 public hardCapPeriod = softCapPeriod;

    uint256 public investedTotal = 0;

    

    bool public softCapReached = false;

    

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    

    modifier softCapFailed {

        require(now > start + softCapPeriod && !softCapReached);

        _;

    }

    

    constructor() public {

        owner = msg.sender;

        start = now;

    }

    

    function() public payable {

        invest(msg.sender, msg.value, 0x0, 0x0);

    }

    

    function buy(address ref1, address ref2) public payable {

        /* 

            Function Enhamster

        */

        

        require(msg.value > 0);

        

        invest(msg.sender, msg.value, ref1, ref2);

    }

    

    function invest(address investor, uint256 value, address ref1, address ref2) internal {

        /* 

            §£§ß§å§ä§â§Ö§ß§ß§ñ§ñ §æ§å§ß§Ü§è§Ú§ñ §á§à§Ü§å§á§Ü§Ú §ä§à§Ü§Ö§ß§à§Ó, §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §Ú§Ù §Ô§à§Ý§à§Ó§ß§à§Ô§à §Þ§Ö§ä§à§Õ§Ñ §Ú §Þ§Ö§ä§à§Õ§Ñ buy.

        */

        

        uint256 tokens = value / tokenPrice * 1 ether;

        require (tokens + tokenSupply <= hardCap); /* §ß§Ö§Ý§î§Ù§ñ §é§ä§à§Ò§í §à§Ò§â§Ñ§Ù§à§Ó§Ñ§Ý§ã§ñ tokenSupply, §á§â§Ö§Ó§à§ã§ç§à§Õ§ñ§ë§Ú§Û 10 000 000 EST */

        if (softCapMoment > 0) require(now < softCapMoment + hardCapPeriod); /* §á§à§ã§Ý§Ö §á§Ö§â§Ú§à§Õ§Ñ Hard Cap §ä§à§Ü§Ö§ß§í §ß§Ö§Ý§î§Ù§ñ §á§à§Ü§å§á§Ñ§ä§î */

        

        tokenBalance[investor] += tokens;

        tokenSupply += tokens;

        

        if (tokenSupply >= softCap) {

            softCapReached = true;

            softCapMoment = now;

        }

        

        uint256 ref1Money = value * 6 / 100;

        uint256 ref2Money = value * 3 / 100;

        uint256 ownerMoney = value - ref1Money - ref2Money;

        

        if (ref1 != 0x0 && tokenBalance[ref1] >= 125 ether) {

            refBalance[ref1] += ref1Money;

        } else {

            refBalance[owner] += ref1Money;

        }

        if (ref2 != 0x0 && tokenBalance[ref2] >= 125 ether) {

            refBalance[ref2] += ref2Money;

        } else {

            refBalance[owner] += ref2Money;

        }

        refBalance[owner] += ownerMoney;

        

        investedTotal += value;

         

        emit OnInvest(investor, value, tokens, ref1, ref2, now);

    }

    

    function withdraw() public {

        /* 

            §£§í§Ó§à§Õ §ã§â§Ö§Õ§ã§ä§Ó §ã §â§Ö§æ§Ö§â§Ñ§Ý§î§ß§à§Ô§à §Ò§Ñ§Ý§Ñ§ß§ã§Ñ, §Ó§à§Ù§Þ§à§Ø§Ö§ß §ä§à§Ý§î§Ü§à §Ó §ã§Ý§å§é§Ñ§Ö §Õ§à§ã§ä§Ú§Ø§Ö§ß§Ú§ñ Soft Cap. §¿§ä§à§ä §Ø§Ö §Þ§Ö§ä§à§Õ 

            §Ú§ã§á§à§Ý§î§Ù§å§Ö§ä§ã§ñ owner'§à§Þ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §Õ§Ý§ñ §Ó§í§Ó§à§Õ§Ñ §ã§â§Ö§Õ§ã§ä§Ó.

        */

        

        require(softCapReached);

        uint256 value = refBalance[msg.sender];

        require(value > 0);

        

        refBalance[msg.sender] = 0;

        

        msg.sender.transfer(value);

        emit OnWithdraw(msg.sender, value, now);

    }

    

    function withdrawAmount(uint256 amount) public {

        /* 

            §£§í§Ó§à§Õ §ã§â§Ö§Õ§ã§ä§Ó §ã §â§Ö§æ§Ö§â§Ñ§Ý§î§ß§à§Ô§à §Ò§Ñ§Ý§Ñ§ß§ã§Ñ, §ã §å§Ü§Ñ§Ù§Ñ§ß§Ú§Ö§Þ §à§á§â§Ö§Õ§Ö§Ý§×§ß§ß§à§Û §ã§å§Þ§Þ§í.

        */

        require(amount > 0);

        require(softCapReached);

        uint256 value = refBalance[msg.sender];

        require(value >= amount);

        

        refBalance[msg.sender] = value-amount;

        

        msg.sender.transfer(amount);

        emit OnWithdraw(msg.sender, amount, now);

    }

    

    function withdrawAmountTo(uint256 amount, address receiver) public {

        /* 

            §£§í§Ó§à§Õ §ã§â§Ö§Õ§ã§ä§Ó §ã §â§Ö§æ§Ö§â§Ñ§Ý§î§ß§à§Ô§à §Ò§Ñ§Ý§Ñ§ß§ã§Ñ §à§á§â§Ö§Õ§Ö§Ý§×§ß§ß§à§Û §ã§å§Þ§Þ§í §Ó §á§à§Ý§î§Ù§å §Õ§â§å§Ô§à§Ô§à §Ñ§Õ§â§Ö§ã§Ñ.

        */

        require(amount > 0);

        require(softCapReached);

        uint256 value = refBalance[msg.sender];

        require(value >= amount);

        

        refBalance[msg.sender] = value-amount;

        

        receiver.transfer(amount);

        emit OnWithdrawTo(msg.sender, receiver, amount, now);

    }

    

    function deinvest() public softCapFailed {

        /* 

            §£§í§Ó§à§Õ §ã§â§Ö§Õ§ã§ä§Ó §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ §Ó §ã§Ý§å§é§Ñ§Ö §á§â§à§Ó§Ñ§Ý§Ñ softCap. §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â §á§â§à§Ó§Ö§â§ñ§Ö§ä §Ó§â§Ö§Þ§ñ §Ú §ß§Ö §á§à§Ù§Ó§à§Ý§ñ§Ö§ä 

            §Ó§í§Ó§à§Õ§Ú§ä§î §ã§â§Ö§Õ§ã§ä§Ó§Ñ §Õ§à §Ù§Ñ§Ó§Ö§â§ê§Ö§ß§Ú§ñ §á§Ö§â§Ú§à§Õ§Ñ softCapPeriod, §Ñ §ä§Ñ§Ü§Ø§Ö §Ó §ã§Ý§å§é§Ñ§Ö, §Ö§ã§Ý§Ú Soft Cap §Ò§í§Ý §Ó§í§á§à§Ý§ß§Ö§ß.

        */

            

        uint256 tokens = tokenBalance[msg.sender];

        require(tokens > 0);

        

        tokenBalance[msg.sender] = 0;

        tokenSupply -= tokens;

        uint256 money = tokens * tokenPrice / 1e18;

        msg.sender.transfer(money);

        emit OnDeinvest(msg.sender, tokens, money, now);

    }

    

    function goESM() public { 

        /*  

            §°§Ò§Þ§Ö§ß §ß§Ñ §ä§à§Ü§Ö§ß§í Ether State Main. §±§â§Ú §Ó§í§Ù§à§Ó§Ö §ï§ä§à§Ô§à §Þ§Ö§ä§à§Õ§Ñ, §Ó§ã§Ö §ä§à§Ü§Ö§ß§í EST §Ò§å§Õ§å§ä §ã§à§Ø§Ø§Ö§ß§í,

            §Ú §ã§æ§à§â§Þ§Ú§â§å§Ö§ä§ã§ñ §ã§à§à§ä§Ó§Ö§ä§ã§ä§Ó§å§ð§ë§Ú§Û Event.

        */

       

        require(softCapReached);

        uint256 tokens = tokenBalance[msg.sender];

        require(tokens > 0);

        

        tokenBalance[msg.sender] = 0;

        tokenSupply -= tokens;

        emit OnExchangeForESM(msg.sender, tokens, now);

    }



    function transfer(address receiver) public {

        uint256 tokens = tokenBalance[msg.sender];

        require(tokens > 0);



        tokenBalance[msg.sender] = 0;

        tokenBalance[receiver] += tokens;



        emit OnTransfer(msg.sender, receiver, tokens, now);

    }

    

    event OnInvest (

        address investor,

        uint256 value,

        uint256 tokensGranted,

        address ref1,

        address ref2,

        uint256 timestamp

    );

    

    event OnWithdraw (

        address indexed investor,

        uint256 value,

        uint256 timestamp

    );



    event OnWithdrawTo (

        address indexed investor,

        address indexed receiver,

        uint256 value,

        uint256 timestamp

    );

    

    event OnDeinvest (

        address indexed investor,

        uint256 tokensBurned,

        uint256 value,

        uint256 timestamp

    );

    

    event OnExchangeForESM (

        address indexed investor,

        uint256 tokensBurned,

        uint256 timestamp

    );



    event OnTransfer (

        address investorA,

        address investorB,

        uint256 tokens,

        uint256 timestamp

    );

}