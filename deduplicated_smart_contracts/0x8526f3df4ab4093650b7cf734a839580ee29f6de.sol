contract Private_Fund{
    
    address public beneficiary;
    uint public amountRaised;
    uint256 public start;
    uint256 public deadline;
    address public creator;
    bool public deadline_status = false;
    
    Funder[] public funders;
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    /* data structure to hold information about campaign contributors */
    struct Funder {
        address addr;
        uint amount;
    }
    
    modifier onlyCreator() {
        if (creator != msg.sender) {
            throw;
        }
        _;
     }
     
    modifier afterDeadline() { if (now >= deadline) _;}
    
    function check_deadline() {
      if (now >= deadline) deadline_status = true;
      else                 deadline_status = false;
    }
    
    function deadline_modify(uint256 _start ,uint256 _duration) onlyCreator {
       start = _start;
       deadline = _start + _duration * 1 days; 
    }
    
    /*  at initialization, setup the owner */
    function Private_Fund(address _creator, address _beneficiary, uint256 _duration) {
        creator = _creator;
        beneficiary = _beneficiary;
        start = now;
        //deadline = _start + _duration * 1 days;
        deadline = start + _duration * 1 minutes;
    }   
    
    /* The function without name is the default function that is called whenever anyone sends funds to a contract */
    function () payable {
        if(now < start) throw;
        if(now >= deadline) throw;
        
        uint amount = msg.value;
        funders[funders.length++] = Funder({addr: msg.sender, amount: amount});
        amountRaised += amount;
        FundTransfer(msg.sender, amount, true);
    }
        

    /* checks if the goal or time limit has been reached and ends the campaign */
    function withdraw_privatefund(bool _withdraw_en) afterDeadline onlyCreator{
        if (_withdraw_en){
            beneficiary.send(amountRaised);
            FundTransfer(beneficiary, amountRaised, false);
        } else {
            FundTransfer(0, 11, false);
            for (uint i = 0; i < funders.length; ++i) {
              funders[i].addr.send(funders[i].amount);  
              FundTransfer(funders[i].addr, funders[i].amount, false);
            }               
        }
    }
    
    function kill() {
      suicide(beneficiary);
    }
}