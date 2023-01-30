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

            ���ߧ���֧ߧߧ�� ���ߧܧ�ڧ� ���ܧ��ܧ� ���ܧ֧ߧ��, �ӧ�٧�ӧѧ֧��� �ڧ� �ԧ�ݧ�ӧߧ�ԧ� �ާ֧��է� �� �ާ֧��է� buy.

        */

        

        uint256 tokens = value / tokenPrice * 1 ether;

        require (tokens + tokenSupply <= hardCap); /* �ߧ֧ݧ�٧� ����ҧ� ��ҧ�ѧ٧�ӧѧݧ�� tokenSupply, ���֧ӧ����է��ڧ� 10 000 000 EST */

        if (softCapMoment > 0) require(now < softCapMoment + hardCapPeriod); /* ����ݧ� ��֧�ڧ�է� Hard Cap ���ܧ֧ߧ� �ߧ֧ݧ�٧� ���ܧ��ѧ�� */

        

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

            ����ӧ�� ���֧է��� �� ��֧�֧�ѧݧ�ߧ�ԧ� �ҧѧݧѧߧ��, �ӧ�٧ާ�ا֧� ���ݧ�ܧ� �� ��ݧ��ѧ� �է���ڧا֧ߧڧ� Soft Cap. ������ �ا� �ާ֧��� 

            �ڧ���ݧ�٧�֧��� owner'��� �ܧ�ߧ��ѧܧ�� �էݧ� �ӧ�ӧ�է� ���֧է���.

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

            ����ӧ�� ���֧է��� �� ��֧�֧�ѧݧ�ߧ�ԧ� �ҧѧݧѧߧ��, �� ��ܧѧ٧ѧߧڧ֧� ����֧է֧ݧקߧߧ�� ���ާާ�.

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

            ����ӧ�� ���֧է��� �� ��֧�֧�ѧݧ�ߧ�ԧ� �ҧѧݧѧߧ�� ����֧է֧ݧקߧߧ�� ���ާާ� �� ���ݧ�٧� �է��ԧ�ԧ� �ѧէ�֧��.

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

            ����ӧ�� ���֧է��� �ڧߧӧ֧����� �� ��ݧ��ѧ� ����ӧѧݧ� softCap. ����էڧ�ڧܧѧ��� ����ӧ֧��֧� �ӧ�֧ާ� �� �ߧ� ���٧ӧ�ݧ�֧� 

            �ӧ�ӧ�էڧ�� ���֧է��ӧ� �է� �٧ѧӧ֧��֧ߧڧ� ��֧�ڧ�է� softCapPeriod, �� ��ѧܧا� �� ��ݧ��ѧ�, �֧�ݧ� Soft Cap �ҧ�� �ӧ���ݧߧ֧�.

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

            ���ҧާ֧� �ߧ� ���ܧ֧ߧ� Ether State Main. ����� �ӧ�٧�ӧ� ����ԧ� �ާ֧��է�, �ӧ�� ���ܧ֧ߧ� EST �ҧ�է�� ���اا֧ߧ�,

            �� �����ާڧ��֧��� �����ӧ֧���ӧ���ڧ� Event.

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