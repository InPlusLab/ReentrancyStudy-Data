/**

 *Submitted for verification at Etherscan.io on 2019-02-10

*/



pragma solidity ^0.4.24;



contract EventFactory{



    bool isStopped = false;



    address public owner = msg.sender;



    mapping (address => bool) registerSite;



    address[] public events;



    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    function () public payable {

        revert();

    }



    function stopContract() onlyOwner public {

        isStopped = true;

    }



    function resumeContract() onlyOwner public {

        isStopped = false;

    }



    function emergencyWithdraw() onlyOwner public {

        require(isStopped == true);

        owner.transfer(address(this).balance);

    }



    function destroyContract() onlyOwner public {

        require(isStopped == true);

        selfdestruct(owner);

    }



    function createEvent(string _siteName, string _eventName, uint totalTickets, uint defaultPrice) public returns (address) {

        Event newEvent = new Event(msg.sender, _siteName, _eventName, totalTickets, defaultPrice);

        events.push(newEvent);

        return newEvent;

    }



    function getEvents() public view returns (address[]) {

        return events;

    }



    function registerEventSite(address siteAddr) onlyOwner public {

        registerSite[siteAddr] = true;

    }



    function deleteEventSite(address siteAddr) onlyOwner public {

        registerSite[siteAddr] = false;

    }



    function isValid(address _siteAddr) public view returns (bool){

        if(registerSite[_siteAddr])

            return registerSite[_siteAddr];

        else

            return false;

    }

}



contract Event{

    bool isStopped = false;



    enum EventState {

        READY, OPEN, CLOSED

    }



    enum TicketState {

        SELLING, OCCUPIED, RESELLING

    }



    EventState public eventState;



    struct Ticket {

        TicketState state;

        address owner;

        uint price;

    }



    mapping (uint => uint) public reSellPrice;

    mapping (uint => address) public reserved;



    /* ether to refund dedicated to the withdrawer's address */

    mapping (address => uint) public refundable;



    uint public totalTickets;

    uint public createtionTime = now;

    address public eventOwner;

    string public siteName;

    string public eventName;

    Ticket[] public tickets;

    uint public defaultPrice;



    constructor(

        address _eventOwner,

        string _siteName,

        string _eventName,

        uint _totalTickets,

        uint _defaultPrice

    ) public {

        eventOwner = _eventOwner;

        siteName = _siteName;

        eventName = _eventName;

        totalTickets = _totalTickets;

        defaultPrice = _defaultPrice;

        Ticket memory defaultTicket = Ticket(TicketState.SELLING, 0, defaultPrice);



        uint i = 0;

        while (i< totalTickets){

            tickets.push(defaultTicket);

            i++;

        }

    }



    /* modifiers */

    modifier onlyEventOwner() {

        require(msg.sender == eventOwner);

        _;

    }



    modifier onlyState(EventState _eventState) {

        require(eventState == _eventState);

        _;

    }



    function () public payable {

        revert();

    }



    /* ------------------- Event Owner Only functions -------------------*/

    function stopContract() onlyEventOwner public {

        isStopped = true;

    }



    function resumeContract() onlyEventOwner public {

        isStopped = false;

    }



    function emergencyWithdraw() onlyEventOwner public {

        require(isStopped == true);

        eventOwner.transfer(address(this).balance);

    }



    function destroyContract() onlyEventOwner public {

        require(isStopped == true);

        selfdestruct(eventOwner);

    }



    function updateEventInfo(uint _totalTickets) onlyEventOwner onlyState(EventState.READY) public {

        Ticket memory defaultTicket = Ticket(TicketState.SELLING, 0, defaultPrice);

        if (_totalTickets > totalTickets){

            uint i = totalTickets;

            while (i < _totalTickets){

                tickets.push(defaultTicket);

                i++;

            }

        }

        totalTickets = _totalTickets;

    }





    function updateTicketPrice(uint startTicketNo, uint endTicketNo, uint price) onlyEventOwner onlyState(EventState.READY) public {

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);

        for(uint i = startTicketNo; i <= endTicketNo; i++){

            tickets[i].price = price;

        }

    }



    function changeEventState (EventState es) onlyEventOwner public {

        require(es == EventState.OPEN || es == EventState.CLOSED);

        require(es > eventState);

        eventState = es;

    }



    /* ------------------- User functions -------------------*/



    // Use to buy tickets.

    // Ether is transter to the event owner from the caller.

    function buyTicket(uint startTicketNo, uint endTicketNo) onlyState(EventState.OPEN) public payable {

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);

        require(getTicketStateSum(startTicketNo, endTicketNo, TicketState.SELLING) ==  (endTicketNo - startTicketNo +1));



        uint priceSum = getPriceSum(startTicketNo, endTicketNo);

        require (priceSum <= msg.value);



        for(uint i = startTicketNo; i <= endTicketNo; i++){

            tickets[i].state = TicketState.OCCUPIED;

            tickets[i].owner = msg.sender;

        }



        refundable[eventOwner] += priceSum;

        refundable[msg.sender] += msg.value - priceSum;



        assert(getOwnerSum(startTicketNo, endTicketNo, msg.sender) == (endTicketNo - startTicketNo +1));

        assert(getTicketStateSum(startTicketNo, endTicketNo, TicketState.OCCUPIED) == (endTicketNo - startTicketNo +1) );

    }



    // Use to cancel occupied Tickets.

    // All selected ticket should be the same owner.

    // Ether is transter to the caller from the event owner.

    // Ether is not send rightly, that can be withdraw after cancel the ticket.

    function cancelTicket(uint startTicketNo, uint endTicketNo) onlyState(EventState.OPEN) public {

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);

        require(getOwnerSum(startTicketNo, endTicketNo, msg.sender) == (endTicketNo - startTicketNo +1));



        uint priceSum = getPriceSum(startTicketNo, endTicketNo);

        require(refundable[eventOwner] >= priceSum);



        for(uint i = startTicketNo; i <= endTicketNo; i++){

            tickets[i].state = TicketState.SELLING;

            tickets[i].owner = 0;

        }



        refundable[msg.sender] += priceSum;

        refundable[eventOwner] -= priceSum;



        assert(getOwnerSum(startTicketNo, endTicketNo, msg.sender) == 0);

        assert(getTicketStateSum(startTicketNo, endTicketNo, TicketState.SELLING) == (endTicketNo - startTicketNo +1));

    }



    // Use to buy reSelling Tickets

    // If someone reserve the ticket, only reserved account can buy the ticket.

    // This function may be use to send friends or someone to reserved in offline.

    function buyReSellTicket(uint startTicketNo, uint endTicketNo) onlyState(EventState.OPEN) public payable {

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);



        uint sum = 0;

        uint validCount = 0;

        address sellingOwner = tickets[startTicketNo].owner;

        uint expectedSellerBalance = 0;



        for(uint i = startTicketNo; i <= endTicketNo; i++){

            if(tickets[i].state == TicketState.RESELLING && sellingOwner == tickets[i].owner){

                if((reserved[i] == 0) || reserved[i] == msg.sender) {

                    validCount ++;

                    sum += reSellPrice[i];

                }

            }

            else break;

        }



        require(validCount == (endTicketNo - startTicketNo +1));

        require(sum <= msg.value);



        expectedSellerBalance = refundable[sellingOwner] + sum;



        for(i = startTicketNo; i <= endTicketNo; i++){

            tickets[i].state = TicketState.OCCUPIED;

            tickets[i].owner = msg.sender;

            reSellPrice[i] = 0;

            reserved[i] = 0;

        }



        refundable[msg.sender] += msg.value-sum;

        refundable[sellingOwner] += sum;



        assert(expectedSellerBalance == refundable[sellingOwner]);

        assert(getOwnerSum(startTicketNo, endTicketNo, msg.sender) == (endTicketNo - startTicketNo +1));

        assert(getTicketStateSum(startTicketNo, endTicketNo, TicketState.OCCUPIED) == (endTicketNo - startTicketNo +1));

    }



    function reSellTicket(uint startTicketNo, uint endTicketNo, uint price, address _receiver) onlyState(EventState.OPEN) public {

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);

        require(getOwnerSum(startTicketNo, endTicketNo, msg.sender) == (endTicketNo - startTicketNo +1));



        for(uint i = startTicketNo; i <= endTicketNo; i++){

            tickets[i].state = TicketState.RESELLING;

            reSellPrice[i] = price;

            reserved[i] = _receiver;

        }



        assert(getOwnerSum(startTicketNo, endTicketNo, msg.sender) == (endTicketNo - startTicketNo +1));

    }



    // user can withdraw wei at any state

    // in case of eventowner can withdraw after end of the Event.

    function withdraw() public{

        if(msg.sender == eventOwner) require(eventState == EventState.CLOSED);

        uint mount = refundable[msg.sender];

        require(mount > 0);

        refundable[msg.sender] = 0;

        msg.sender.transfer(mount);



        assert(refundable[msg.sender] == 0);

    }



    /* ------------------- get functions for Web -------------------*/



    function getEventData(address owner) public view returns(address, string, string, EventState, uint, uint){

        return (eventOwner, siteName, eventName, eventState, totalTickets, refundable[owner]);

    }



    function getTicketData(address currentAddr) public view returns (TicketState[], uint[], bool[], uint[], address[]){

        TicketState[] memory ts = new TicketState[](totalTickets);

        uint[] memory _price = new uint[](totalTickets);

        bool[] memory isOwner = new bool[](totalTickets);

        uint[] memory _reSellPrice = new uint[](totalTickets);

        address[] memory _reserved = new address[](totalTickets);

        uint i = 0;

        while (i < totalTickets){

            ts[i] = tickets[i].state;

            _price[i] = tickets[i].price;

            if(currentAddr == tickets[i].owner) isOwner[i]= true;

            if(ts[i] == TicketState.RESELLING) {

                _reSellPrice[i] = reSellPrice[i];

                _reserved[i] = reserved[i];

            }

            i++;

        }



        return (ts, _price, isOwner, _reSellPrice, _reserved);

    }



    /* ------------------- internal functions (private) -------------------*/

    function getPriceSum(uint startTicketNo, uint endTicketNo) private view returns (uint){

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);

        uint sum = 0;

        uint i = startTicketNo;

        while (i <= endTicketNo){

            sum += tickets[i].price;

            i++;

        }

        return sum;

    }



    function getOwnerSum(uint startTicketNo, uint endTicketNo, address owner) private view returns (uint) {

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);

        uint counter = 0;

        uint i = startTicketNo;

        while (i <= endTicketNo){

            if(tickets[i].owner == owner) counter++;

            i++;

        }

        return counter;

    }



    function getTicketStateSum(uint startTicketNo, uint endTicketNo, TicketState _state) private view returns (uint){

        require(endTicketNo >= startTicketNo && endTicketNo < totalTickets);

        uint counter = 0;

        uint i = startTicketNo;

        while (i <= endTicketNo){

            if(tickets[i].state == _state) counter++;

            i++;

        }

        return counter;

    }



}