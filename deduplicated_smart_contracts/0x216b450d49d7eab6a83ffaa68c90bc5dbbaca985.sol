/**

 *Submitted for verification at Etherscan.io on 2019-05-21

*/



pragma solidity ^0.5.2;



contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function transfer(address to, uint tokens) public returns (bool success);



    

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    

    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}



contract SALIToken is ERC20Interface{

    string public name = "SALI Sample";

    string public symbol = "SLI";

    uint public decimals = 0;

    

    uint public supply;

    address public founder;

    

    mapping(address => uint) public balances;

    

    mapping(address => mapping(address => uint)) allowed;

    

    //allowed[0x1111....][0x22222...] = 100;

    

    

    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);





    constructor() public{

        supply = 100000000;

        founder = msg.sender;

        balances[founder] = supply;

    }

    // ALLOWANCE()

    function allowance(address tokenOwner, address spender) view public returns(uint){

        return allowed[tokenOwner][spender];

    }

    

    //APPROVE ()

        function approve(address spender, uint tokens) public returns(bool){

        require(balances[msg.sender] >= tokens);

        require(tokens > 0);

        

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }

    //TRANSFERFROM()

    //transfer tokens from the  owner account to the account that calls the function

    function transferFrom(address from, address to, uint tokens) public returns(bool){

        require(allowed[from][to] >= tokens);

        require(balances[from] >= tokens);

        

        balances[from] -= tokens;

        balances[to] += tokens;

        

        

        allowed[from][to] -= tokens;

        

        return true;

    }

    

    function totalSupply() public view returns (uint){

        return supply;

    }

    

    function balanceOf(address tokenOwner) public view returns (uint balance){

         return balances[tokenOwner];

     }

     //TRANSFER()

    function transfer(address to, uint tokens) public returns (bool success){

         require(balances[msg.sender] >= tokens && tokens > 0);

         

         balances[to] += tokens;

         balances[msg.sender] -= tokens;

         emit Transfer(msg.sender, to, tokens);

         return true;

     }

}



contract SaliICO is SALIToken{

    address public admin;

    

    

    address payable public deposit;

    

    //token price in wei: 1SALI = 0.004 ETHER, 1 ETHER = 250 SALI

    uint tokenPrice = 4000000000000000;

    

    //3000 Ether in wei as HARDCAP

    uint public hardCap = 3000000000000000000000;

    

    uint public raisedAmount;

    

    uint public saleStart = now;

    uint public saleEnd = now + 7884000; //ICO will run in 3 months

    uint public coinTradeStart = saleEnd + 2628000; //transferable in a month after salesEnd

    

    uint public maxInvestment = 10500000000000000000; // 10.5 ETH AS MAX INVESTMENT

    uint public minInvestment = 100000000000000000; // 0.1 ETH AS MINIMUM INVESTMENT

    

    enum State { beforeStart, running, afterEnd, halted}

    State public icoState;

    

    

    modifier onlyAdmin(){

        require(msg.sender == admin);

        _;

    }

    

    event Invest(address investor, uint value, uint tokens);

    

    

    constructor(address payable _deposit) public{

        deposit = _deposit;

        admin = msg.sender;

        icoState = State.beforeStart;

    }

    

    //emergency stop

    function halt() public onlyAdmin{

        icoState = State.halted;

    }

    

    //restart 

    function unhalt() public onlyAdmin{

        icoState = State.running;

    }

    

    

    //only the admin can change the deposit address

    function changeDepositAddress(address payable newDeposit) public onlyAdmin{

        deposit = newDeposit;

    }

    

    

    //returns ico state

    function getCurrentState() public view returns(State){

        if(icoState == State.halted){

            return State.halted;

        }else if(block.timestamp < saleStart){

            return State.beforeStart;

        }else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){

            return State.running;

        }else{

            return State.afterEnd;

        }

    }

    

    

    function invest() payable public returns(bool){

        //invest only in running

        icoState = getCurrentState();

        require(icoState == State.running);

        

        require(msg.value >= minInvestment && msg.value <= maxInvestment);

        

        uint tokens = msg.value / tokenPrice;

        

        //hardCap not reached

        require(raisedAmount + msg.value <= hardCap);

        

        raisedAmount += msg.value;

        

        //add tokens to investor balance from founder balance

        balances[msg.sender] += tokens;

        balances[founder] -= tokens;

        

        deposit.transfer(msg.value);//transfer eth to the deposit address

        

        //emit event

        emit Invest(msg.sender, msg.value, tokens);

        

        return true;

        



    }

    

    function () payable external{

        invest();

    }

    

    

    

    function burn() public returns(bool){

        icoState = getCurrentState();

        require(icoState == State.afterEnd);

        balances[founder] = 0;

        

    }

    

    

    function transfer(address to, uint value) public returns(bool){

        require(block.timestamp > coinTradeStart);

        super.transfer(to, value);

    }

    

    function transferFrom(address _from, address _to, uint _value) public returns(bool){

        require(block.timestamp > coinTradeStart);

        super.transferFrom(_from, _to, _value);

    }

    

}