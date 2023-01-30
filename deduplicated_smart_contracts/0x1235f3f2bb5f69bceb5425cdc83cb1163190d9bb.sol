/**
 *Submitted for verification at Etherscan.io on 2020-04-05
*/

/*

***The Shuffle Raffle v2***

https://shuffle-raffle.com/

The shuffle raffle is a game built on top of the Shuffle Monster token (https://shuffle.monster/).
Players can buy tickets with SHUF tokens. Each week a winner is randomly picked. 

*/

pragma solidity ^0.5.17;

contract ERC20Token {
  function totalSupply() public view returns(uint);
  function balanceOf(address tokenOwner) public view returns(uint balance);
  function allowance(address tokenOwner, address spender) public view returns(uint remaining);
  function transfer(address to, uint tokens) public returns(bool success);
  function approve(address spender, uint tokens) public returns(bool success);
  function transferFrom(address from, address to, uint tokens) public returns(bool success);
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
      owner = msg.sender;
    }
    
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0));
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
}

contract ShuffleRaffle_v2 is Ownable {
    using SafeMath for uint256;
    
    struct Order {
        uint48 position;
        uint48 size;
        address owner;
    }
    
    mapping(uint256 => Order[]) TicketBook;
    address private constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    address public constant shufAddress = 0x3A9FfF453d50D4Ac52A6890647b823379ba36B9E;
    ERC20Token public constant shuf = ERC20Token(shufAddress);
    UniswapExchangeInterface private constant UniShuf = UniswapExchangeInterface(0x536956Fab86774fb55CfaAcF496BC25E4d2B435C);
    UniswapFactoryInterface private constant UniFactory = UniswapFactoryInterface(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    Gastoken private constant gastoken = Gastoken(0x0000000000b3F879cb30FE243b4Dfee438691c04);
    uint256 public RaffleNo = 1;
    uint256 public NextRaffle = 1586112779;

    uint256 public TicketPrice = 5*10**18;
    uint256 public PickerReward = 10*10**18;
    uint256 public minTickets = 50;
    uint256 public RafflePerc = 15;
    uint256 public dappDivsPerc = 0;
    address public dappAddress;

    uint256 public nextTicketPrice = 5*10**18;
    uint256 public nextPickerReward = 10*10**18;
    uint256 public nextminTickets = 50;
    uint256 public nextRafflePerc = 15;
    uint256 public nextdappDivsPerc = 0;
    address public nextdappAddress;

    uint256 public random_seed = 0;
    bool    public raffle_closed = false;

    event Ticket(uint256 raffle, address indexed addr, uint256 amount);
    event Winner(uint256 raffle, address indexed addr, uint256 amount, uint256 win_ticket);
    event RaffleClosed(uint256 raffle, uint256 block_number);
    event TicketPriceChanged(uint256 previousticketprice, uint256 newticketprice);
    event PickerRewardChanged(uint256 previouspickerReward, uint256 newpickerreward);
    event minTicketsChanged(uint256 previousminTickets,uint256 newmintickets);
    event RafflePercChanged(uint256 previousRafflePerc, uint256 newRafflePerc);
    event dappDivsPercChanged(uint256 previousdappDivs,uint256 newdappDivs);
    event dappAddressChanged(address previousdappAddress, address newdappAddress);


    function TicketsOfAddress(address addr) public view returns (uint256 total_tickets) {
        uint256 _tt=0;
        for(uint256 i = 0; i<TicketBook[RaffleNo].length; i++){
            if (TicketBook[RaffleNo][i].owner == addr)
                _tt=_tt.add(TicketBook[RaffleNo][i].size);
        }
        return _tt;
    }

    function Stats() public view returns (uint256 raffle_number, uint48 total_tickets, uint256 balance, uint256 next_raffle, uint256 ticket_price, bool must_pick_winner, uint256 picker_reward, uint256 min_tickets,uint256 next_ticket_price,uint256 next_picker_reward,uint256 next_min_tickets, bool is_raffle_closed,uint256 raffle_perc,uint256 dapp_divs_perf ){
        bool mustPickWinner;
        uint48 TotalTickets= _find_curr_position();
        if (now>NextRaffle && TotalTickets>minTickets)
            mustPickWinner = true;
        else
            mustPickWinner = false;
        return (RaffleNo, TotalTickets, shuf.balanceOf(address(this)), NextRaffle, TicketPrice, mustPickWinner, PickerReward, minTickets, nextTicketPrice, nextPickerReward, nextminTickets, raffle_closed,RafflePerc,dappDivsPerc );
    }
    
    function BuyTicket(uint48 tickets) external returns(bool success){
        require(msg.sender == tx.origin, "Only hoomans");
        require(tickets > 0);
        uint256 bill = uint256(tickets).mul(TicketPrice);
        require(shuf.allowance(msg.sender, address(this))>=bill, "Contract not approved");
        require(shuf.balanceOf(msg.sender)>=bill, "Not enough SHUF balance.");
        uint48 TotalTickets = _find_curr_position();
        if (now>NextRaffle){
            //requires to pick a winner or extends duration if not enough participants
            require(TotalTickets<=minTickets,"A winner has to be picked first");
            NextRaffle = NextRaffle.add((((now.sub(NextRaffle)).div(5 days + 12 hours)).add(1)).mul(5 days + 12 hours));
        }
        
        require(shuf.transferFrom(msg.sender, address(this), bill));
        pushTickets(tickets, TotalTickets);
        return true;
    }
    
    
    function BuyTicketEth(uint48 tickets) external payable returns(bool success){
        require(msg.sender == tx.origin, "Only hoomans");
        require(tickets>0);
        uint256 bill = uint256(tickets).mul(TicketPrice).mul(100).div(98);
        uint256 ethBill = UniShuf.getEthToTokenOutputPrice(bill);
        require(msg.value>=ethBill, "Not enough eth.");
        uint48 TotalTickets = _find_curr_position();
        if (now>NextRaffle){
            //requires to pick a winner or extends duration if not enough participants
            require(TotalTickets<=minTickets,"A winner has to be picked first");
            NextRaffle = NextRaffle.add((((now.sub(NextRaffle)).div(5 days + 12 hours)).add(1)).mul(5 days + 12 hours));
        }
        require(UniShuf.ethToTokenTransferOutput.value(ethBill)(bill, now, address(this))==ethBill);
        if (msg.value>ethBill){
            msg.sender.transfer(msg.value-ethBill);
        }
        pushTickets(tickets, TotalTickets);
        return true;
    }
    
    function BuyTicketUniswap(uint48 tickets, address tokenAddress, uint256 maxtokens) external returns(bool success){
        require(msg.sender == tx.origin, "Only hoomans");
        require(tickets>0);
        ERC20Token token = ERC20Token(tokenAddress);
        address tokenExchange = UniFactory.getExchange(tokenAddress);
        require(tokenAddress != ZERO_ADDRESS, "Token not found");
        UniswapExchangeInterface UniToken = UniswapExchangeInterface(tokenExchange);
        uint256 bill = uint256(tickets).mul(TicketPrice).mul(100).div(98);

        uint256 ethBill = UniShuf.getEthToTokenOutputPrice(bill);
        uint256 tokenBill = UniToken.getTokenToEthOutputPrice(ethBill);
        require(tokenBill<=maxtokens);
        require(token.allowance(msg.sender,address(this))>=tokenBill, "Contract not approved");
        uint48 TotalTickets = _find_curr_position();
        if (now>NextRaffle){
            //requires to pick a winner or extends duration if not enough participants
            require(TotalTickets<=minTickets,"A winner has to be picked first");
            NextRaffle = NextRaffle.add((((now.sub(NextRaffle)).div(5 days + 12 hours)).add(1)).mul(5 days + 12 hours));
        }
        uint256 contract_shuf_balance = shuf.balanceOf(address(this));
        require(token.transferFrom(msg.sender, address(this), tokenBill));
        if (token.allowance(address(this), tokenExchange) < tokenBill) {
			token.approve(tokenExchange, uint256(-1));
		}
        require(UniToken.tokenToTokenTransferOutput(bill, tokenBill, ethBill, now, address(this), shufAddress) == tokenBill);
        require(shuf.balanceOf(address(this))>=contract_shuf_balance.add(bill.sub(divRound(bill,100).mul(2))));
        pushTickets(tickets, TotalTickets);
        return true;
    }
    
    function pushTickets(uint48 tickets,uint48 TotalTickets) internal returns(bool success){
        Order memory t;
        t.size=tickets;
        t.owner=msg.sender;
        t.position=TotalTickets+tickets;
        require(t.position>=TotalTickets);
        TicketBook[RaffleNo].push(t);
        emit Ticket(RaffleNo, msg.sender, tickets);
        return true;
    }
   
    function pickWinner() external returns(bool success) {
        uint256 gaslimit = gasleft();
        require(msg.sender == tx.origin, "Only hoomans");
        require(now>NextRaffle, "It's not time to pick a winner yet");
        uint256 Totaltickets =_find_curr_position();
        require(Totaltickets>minTickets,  "Not enough tickets to pick a winner");
        
        //Close the Raffle
        if (raffle_closed == false){
            raffle_closed = true;
            random_seed = block.number;
            emit RaffleClosed(RaffleNo, random_seed);
            shuf.transfer(msg.sender, PickerReward);
            gastoken.freeUpTo((gaslimit - gasleft() + 14154) / 41130);
            return true;
        }
        
        require(random_seed<block.number);
        uint256 winningticket = _random(Totaltickets);
        address winner = _find_winner(winningticket);
        
        //reset Raffle
        RaffleNo=RaffleNo.add(1);
        NextRaffle = NextRaffle.add((((now.sub(NextRaffle)).div(5 days + 12 hours)).add(1)).mul(5 days + 12 hours));
        raffle_closed = false;
        
        //reward caller
        shuf.transfer(msg.sender, PickerReward);

        //calculate reward
        uint256 reward = shuf.balanceOf(address(this));

        //send dapp divs
        if(dappDivsPerc>0){
            uint256 divs = reward.mul(dappDivsPerc).div(100);
            shuf.transfer(dappAddress, divs);
            reward = reward.sub(divs);
        }

        //reward winner
        reward = reward.sub(reward.mul(RafflePerc).div(100));
        shuf.transfer(winner,reward);
        emit Winner(RaffleNo, winner, reward, winningticket);

        
        //check for changes
        if(nextTicketPrice!=TicketPrice){
            uint256 oldticketPrice=TicketPrice;
            TicketPrice = nextTicketPrice;
            emit TicketPriceChanged(oldticketPrice, TicketPrice);
        }
        if(nextPickerReward!=PickerReward){
            uint256 oldpickerReward=PickerReward;
            PickerReward = nextPickerReward;
            emit PickerRewardChanged(oldpickerReward, PickerReward);
        }
        if(nextminTickets!=minTickets){
            uint256 oldminTickets=minTickets;
            minTickets = nextminTickets;
            emit minTicketsChanged(oldminTickets, minTickets);
        }
        if(nextRafflePerc!=RafflePerc){
            uint256 oldRafflePerc = RafflePerc;
            RafflePerc = nextRafflePerc;
            emit RafflePercChanged(oldRafflePerc, RafflePerc);
        }
        if(nextdappDivsPerc!=dappDivsPerc){
            uint256 olddappDivsPerc = dappDivsPerc;
            dappDivsPerc = nextdappDivsPerc;
            emit dappDivsPercChanged(olddappDivsPerc, dappDivsPerc);
        }
         if(dappAddress!=dappAddress){
            address olddappAddress = dappAddress;
            dappAddress = nextdappAddress;
            emit dappAddressChanged(olddappAddress, dappAddress);
        }
        gastoken.freeUpTo((gaslimit - gasleft() + 14154) / 41130);
        return true;
    }
    
    function _find_curr_position() internal view returns(uint48 curr_position){
        uint256 TotalOrders = TicketBook[RaffleNo].length;
        uint48 Totaltickets=(TotalOrders>0)?TicketBook[RaffleNo][TotalOrders.sub(1)].position:0;
        return Totaltickets;
    }
    
     function _find_winner(uint256 winning_ticket)  internal view returns(address winner){
    //search for the winner using binary search
        uint256 L=0;
        uint256 R=TicketBook[RaffleNo].length.sub(1);
        uint256 raffleno=RaffleNo;
        
        while(L <= R){
            uint256 m = (L.add(R)).div(2);
            Order memory Am = TicketBook[raffleno][m];
            if(Am.position<winning_ticket)
                L=m.add(1);
            else if(Am.position-Am.size>=winning_ticket)
                R=m.sub(1);
            else
                return Am.owner;
        }
        return address(this);
    }
    
    function setTicketPrice(uint256 newticketprice) external onlyOwner {
        nextTicketPrice= newticketprice;
    }
    
    function setPickerReward(uint256 newpickerreward) external onlyOwner {
        nextPickerReward = newpickerreward;
    }
    
    function setminTickets(uint256 newmintickets) external onlyOwner {
        nextminTickets = newmintickets;
    }

    function setRafflePerc(uint256 newRafflePerc) external onlyOwner {
        nextRafflePerc= newRafflePerc;
    }

    function setdappDivsPerc(uint256 newdappDivsPerc) external onlyOwner {
        nextdappDivsPerc= newdappDivsPerc;
    }

    function setdappAddress(address newdappAddress) external onlyOwner {
        nextdappAddress= newdappAddress;
    }
  
    function _random(uint256 Totaltickets) internal view returns (uint256) {
        return uint256(uint256(keccak256(abi.encodePacked(blockhash(random_seed), RaffleNo)))%Totaltickets).add(1);
    }

    function divRound(uint256 x, uint256 y) internal pure returns (uint256) {
        require(y != 0, "Div by zero");
        uint256 r = x / y;
        if (x % y != 0) {
            r = r + 1;
        }
        return r;
    }    
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

     function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
 
        return c;
    }
}

interface UniswapExchangeInterface {
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline,
    address recipient, address token_addr) external returns (uint256  tokens_sold);
}

contract UniswapFactoryInterface {
    function getExchange(address token) external view returns (address exchange);
}

interface Gastoken {
    function freeUpTo(uint256 value) external returns (uint256 freed);
}