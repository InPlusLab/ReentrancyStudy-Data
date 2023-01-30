pragma solidity ^0.5.4;



import "./SafeMathLib.sol";



import "./FairPlayOptions.sol";



contract FairPlay {

    

    mapping (address => bool) private admins;

    mapping (address => uint) public balance;

    

    event Deposit(address walletAddress, uint amount, uint balance);

    event Withdraw(address walletAddress, uint amount, uint balance);

    event Error(string message);

    

    function deposit() public payable {

        balance[msg.sender] = balance[msg.sender].add(msg.value);

        emit Deposit(msg.sender, msg.value, balance[msg.sender]);

    }

    

    function withdraw(uint _amount) public {

        require(_amount <= balance[msg.sender],"Insufficient funds");

        balance[msg.sender] = balance[msg.sender].sub(_amount);

        msg.sender.transfer(_amount);

        emit Withdraw(msg.sender, _amount, balance[msg.sender]);

    }

    

    using SafeMathLib for uint256;



    event BetEventCreated(uint id);

    event BetPlaced(uint betEventId, uint betId, address user, uint optionId, uint amount);

    event BetClaimed(uint betId, address user, uint winnings);

    event WinningOptionAdded(uint betEventId, uint optionId, string result);



    enum BetEventStatus {ACTIVE, CANCELED}

    enum BetStatus {PENDING, CLAIMED}

    

    struct BetEvent {

        string title;

        string category;

        string subcategory;

        uint endDate;

        BetEventStatus status;

        address creator;

        uint winningOption;

        uint balance;

        string result;

        uint expirationDate;

    }

    

    struct Bet {

        uint betEventId;

        uint optionId;

        uint amount;

        uint date;

        address creator;

        BetStatus status;

    }



    uint[] public betEvents;

    mapping(address => uint[]) public userBets;

    

    uint betEventCounter;

    uint betCounter;



    mapping(uint => BetEvent) public betEventMap;

    mapping(uint => Bet) public betMap;

    

    mapping(uint => mapping(uint => uint)) public betEventOptionBalance;

    

    mapping(uint => uint[]) public betEventOptions;

    mapping(uint => uint[]) public betEventBets;

    

    mapping(uint => uint) public betEventMinBet;

    mapping(uint => uint) public betEventCommission;

    

    FairPlayOptions public options;

    

    modifier isAdmin(address _addr) {

        require(admins[_addr]);

        _;

    }

    

    function() external payable {}

    

    constructor() public {

        options = FairPlayOptions(0x404b47F5eD0c090044873BEbE7Ea53170AA2cb1C);

        admins[msg.sender] = true;

    }



    function getBetEvents() public view returns(uint[] memory) {return betEvents;}

    function getUserBets() public view returns(uint[] memory) { return userBets[msg.sender]; }

    function getBetEventOptions(uint id) public view returns(uint[] memory) { return betEventOptions[id];}

    function getBetEventBets(uint id) public view returns(uint[] memory) { return betEventBets[id];}



    function getOptions() public view returns(uint[] memory) {return options.getOptions();}

    

    function getOption(uint _id) public view returns(string memory) {return options.getOption(_id);}



    function createBetEvent(

        string memory title, 

        string memory category, 

        string memory subcategory, 

        uint endDate, 

        uint[] memory possibleOptions,

        uint expirationDate,

        uint minBet,

        uint commission) isAdmin(msg.sender) public {

        

        uint id = betEventCounter;

        betEventCounter = betEventCounter.add(1);

        

        BetEvent memory betEvent;

        

        betEvent.title = title;

        betEvent.category = category;

        betEvent.subcategory = subcategory;

        betEvent.endDate = endDate;

        betEvent.status = BetEventStatus.ACTIVE;

        betEvent.creator = msg.sender;

        betEvent.expirationDate = expirationDate;

        

        betEventOptions[id] = possibleOptions;

        betEventMinBet[id] = minBet;

        betEventCommission[id] = commission;

        

        betEventMap[id] = betEvent;

        betEvents.push(id);

        

        emit BetEventCreated(id);

    }



    function createBet(

        uint betEventId, 

        uint optionId, 

        uint amount) public {

        

        require(betEventMap[betEventId].endDate >= now, "Bet event has ended");

        require(balance[msg.sender] >= amount, "Balance too low");

        require(amount >= betEventMinBet[betEventId], "Min bet amount not reached");

        require(betEventMap[betEventId].winningOption == 0, "Bet event has ended");

        require(betEventMap[betEventId].status != BetEventStatus.CANCELED, "Bet event is canceled");

        

        balance[msg.sender] = balance[msg.sender].sub(amount);

        

        uint id = betCounter;

        betCounter = betCounter.add(1);

        

        Bet memory bet = Bet(betEventId, optionId, amount, now, msg.sender, BetStatus.PENDING);

        betEventOptionBalance[betEventId][optionId] = betEventOptionBalance[betEventId][optionId].add(amount);

        betEventMap[betEventId].balance = betEventMap[betEventId].balance.add(amount);

        betMap[id] = bet;

        betEventBets[betEventId].push(id);

        userBets[msg.sender].push(id);

        

        emit BetPlaced(betEventId, id, msg.sender, optionId, amount);

    }

    

    

    function setWinningOption(uint betEventId, uint optionId, string memory result) isAdmin(msg.sender) public {

        require(betEventMap[betEventId].winningOption == 0, "Winning Option already set");

        require(betEventMap[betEventId].status != BetEventStatus.CANCELED, "Bet event is canceled");

        

        betEventMap[betEventId].winningOption = optionId;

        betEventMap[betEventId].result = result;

        uint winningOptionSum = betEventOptionBalance[betEventId][betEventMap[betEventId].winningOption];



        if(winningOptionSum == 0) {

            betEventMap[betEventId].status = BetEventStatus.CANCELED;

            removeBetEventFromList(betEventId);

            return;

        }

        

        uint lostOptionsSum = betEventMap[betEventId].balance.sub(winningOptionSum);

        uint a = lostOptionsSum.mul(betEventCommission[betEventId]); 

        uint commission = a.div(100);

        

        betEventMap[betEventId].balance = betEventMap[betEventId].balance.sub(commission);

        balance[betEventMap[betEventId].creator] = balance[betEventMap[betEventId].creator].add(commission);

        

        removeBetEventFromList(betEventId);

        

        emit WinningOptionAdded(betEventId, optionId, result);

    }

    

    function setOptions(address _addr) public isAdmin(msg.sender) {

        options = FairPlayOptions(_addr);

    }

    

    

    function claim(uint betId) public {

        

        Bet memory bet = betMap[betId];

        

        if((betEventMap[bet.betEventId].status == BetEventStatus.CANCELED) || (betEventMap[bet.betEventId].expirationDate <= now)) {

            refund(betId);

            return;

        }

        

        require(bet.creator == msg.sender, "Cannot claim another player's bet");

        require(bet.optionId == betEventMap[bet.betEventId].winningOption, "Cannot claim a lost bet");

        require(bet.status != BetStatus.CLAIMED, "Bet is already claimed");



        betMap[betId].status = BetStatus.CLAIMED;



        uint winningOptionSum = betEventOptionBalance[bet.betEventId][betEventMap[bet.betEventId].winningOption];

        uint a = bet.amount.mul(betEventMap[bet.betEventId].balance);

        uint totalPlayerWinnings = a.div(winningOptionSum);



        balance[msg.sender] = balance[msg.sender].add(totalPlayerWinnings);

        

        emit BetClaimed(betId, msg.sender, totalPlayerWinnings);

    }

    

    function cancelBetEvent(uint _id) isAdmin(msg.sender) public {

        betEventMap[_id].status = BetEventStatus.CANCELED;

        removeBetEventFromList(_id);

    }

    

    function refund(uint betId) private {

        Bet memory bet = betMap[betId];

        

        require(bet.creator == msg.sender, "Cannot claim another player's bet");

        require(betEventMap[bet.betEventId].status == BetEventStatus.CANCELED, "Bet event is not canceled");

        require(bet.status != BetStatus.CLAIMED, "Bet is already claimed");



        betMap[betId].status = BetStatus.CLAIMED;



        balance[msg.sender] = balance[msg.sender].add(bet.amount);

        

        emit BetClaimed(betId, msg.sender, bet.amount);

    }

    

    function removeBetEventFromList(uint _id) private {

        uint index; bool found;

        for(uint i = 0; i < betEvents.length; i++) {

            if (betEvents[i] == _id) {

                found = true;

                index = i;

                break;

            }

        }

        

        if(found) {

            if(betEvents.length > 1) {

                betEvents[index] = betEvents[betEvents.length - 1];

                delete betEvents[betEvents.length - 1];

            }

            betEvents.length--;

        }

    }

    

    function estimateEarnings(uint betId) public view returns(uint) {

        Bet memory bet = betMap[betId];

        uint betEventId = bet.betEventId;

        

        uint winningOptionSum = betEventOptionBalance[betEventId][bet.optionId];

        

        uint aa = bet.amount.mul(betEventMap[betEventId].balance);

        return aa.div(winningOptionSum);

    }

    

    function gaddress() public view returns(address) { return address(this); }



    function setExpirationDate(uint id, uint _date) public isAdmin(msg.sender) {

        betEventMap[id].expirationDate = _date;

    }

    

    function setEndDate(uint id, uint _date) public isAdmin(msg.sender) {

        betEventMap[id].endDate = _date;

    }

    

    function getTime()public view returns(uint) {

        return now;

    }

    

}