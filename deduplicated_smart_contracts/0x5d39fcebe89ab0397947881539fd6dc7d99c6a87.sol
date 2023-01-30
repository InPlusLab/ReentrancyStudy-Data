pragma solidity ^0.4.6;

// Presale Smart Contract
//
// **** START:  PARANOIA DISCLAIMER ****
// A carefull reader will find here some unnecessary checks and excessive code consuming some extra valueable gas. It is intentionally. 
// Even contract will works without these parts, they make the code more secure in production as well for future refactorings.
// Additionally it shows more clearly what we have took care of.
// You are welcome to discuss that places.
// **** END OF: PARANOIA DISCLAIMER *****
//
// @author ethernian
//

contract Presale {

	function cleanUp() onlyOwner {
		selfdestruct(OWNER);
	}

    string public constant VERSION = "0.1.3-[min1,max5]";

	/* ====== configuration START ====== */
    uint public constant MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH = 1;
    uint public constant MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH = 5;
    uint public constant MIN_ACCEPTED_AMOUNT_FINNEY = 1;
	uint public constant PRESALE_START = 3044444;
	uint public constant PRESALE_END = 3044555;
	uint public constant WITHDRAWAL_END = 3044666;
	address public constant OWNER = 0xF55DFd2B02Cf3282680C94BD01E9Da044044E6A2;
    /* ====== configuration END ====== */
	
    string[5] private stateNames = ["BEFORE_START",  "PRESALE_RUNNING", "WITHDRAWAL_RUNNING", "REFUND_RUNNING", "CLOSED" ];
    enum State { BEFORE_START,  PRESALE_RUNNING, WITHDRAWAL_RUNNING, REFUND_RUNNING, CLOSED }

    uint public total_received_amount;
	mapping (address => uint) public balances;
	
    uint private constant MIN_TOTAL_AMOUNT_TO_RECEIVE = MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;
    uint private constant MAX_TOTAL_AMOUNT_TO_RECEIVE = MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;
    uint private constant MIN_ACCEPTED_AMOUNT = MIN_ACCEPTED_AMOUNT_FINNEY * 1 finney;
	

    //constructor
    function Presale () validSetupOnly() { }

    //
    // ======= interface methods =======
    //

    //accept payments here
    function ()
    payable
    noReentrancy
    {
        State state = currentState();
        if (state == State.PRESALE_RUNNING) {
            receiveFunds();
        } else if (state == State.REFUND_RUNNING) {
            // any entring call in Refund Phase will cause full refund
            sendRefund();
        } else {
            throw;
        }
    }

    function refund() external
    inState(State.REFUND_RUNNING)
    noReentrancy
    {
        sendRefund();
    }


    function withdrawFunds() external
    inState(State.WITHDRAWAL_RUNNING)
    onlyOwner
    noReentrancy
    {
        // transfer funds to owner if any
        if (this.balance > 0) {
            if (!OWNER.send(this.balance)) throw;
        }
    }


    //displays current contract state in human readable form
    function state()  external constant
    returns (string)
    {
        return stateNames[ uint(currentState()) ];
    }


    //
    // ======= implementation methods =======
    //

    function sendRefund() private tokenHoldersOnly {
        // load balance to refund plus amount currently sent
        var amount_to_refund = balances[msg.sender] + msg.value;
        // reset balance
        balances[msg.sender] = 0;
        // send refund back to sender
        if (!msg.sender.send(amount_to_refund)) throw;
    }


    function receiveFunds() private notTooSmallAmountOnly {
      // no overflow is possible here: nobody have soo much money to spend.
      if (total_received_amount + msg.value > MAX_TOTAL_AMOUNT_TO_RECEIVE) {
          // accept amount only and return change
          var change_to_return = total_received_amount + msg.value - MAX_TOTAL_AMOUNT_TO_RECEIVE;
          if (!msg.sender.send(change_to_return)) throw;

          var acceptable_remainder = MAX_TOTAL_AMOUNT_TO_RECEIVE - total_received_amount;
          balances[msg.sender] += acceptable_remainder;
          total_received_amount += acceptable_remainder;
      } else {
          // accept full amount
          balances[msg.sender] += msg.value;
          total_received_amount += msg.value;
      }
    }


    function currentState() private constant returns (State) {
        if (block.number < PRESALE_START) {
            return State.BEFORE_START;
        } else if (block.number <= PRESALE_END && total_received_amount < MAX_TOTAL_AMOUNT_TO_RECEIVE) {
            return State.PRESALE_RUNNING;
        } else if (block.number <= WITHDRAWAL_END && total_received_amount >= MIN_TOTAL_AMOUNT_TO_RECEIVE) {
            return State.WITHDRAWAL_RUNNING;
        } else if (this.balance > 0){
            return State.REFUND_RUNNING;
        } else {
            return State.CLOSED;		
		} 
    }

    //
    // ============ modifiers ============
    //

    //fails if state dosn&#39;t match
    modifier inState(State state) {
        if (state != currentState()) throw;
        _;
    }


    //fails if something in setup is looking weird
    modifier validSetupOnly() {
        if ( OWNER == 0x0 
            || PRESALE_START == 0 
            || PRESALE_END == 0 
            || WITHDRAWAL_END ==0
            || PRESALE_START <= block.number
            || PRESALE_START >= PRESALE_END
            || PRESALE_END   >= WITHDRAWAL_END
            || MIN_TOTAL_AMOUNT_TO_RECEIVE > MAX_TOTAL_AMOUNT_TO_RECEIVE )
				throw;
        _;
    }


    //accepts calls from owner only
    modifier onlyOwner(){
    	if (msg.sender != OWNER)  throw;
    	_;
    }


    //accepts calls from token holders only
    modifier tokenHoldersOnly(){
        if (balances[msg.sender] == 0) throw;
        _;
    }


    // don`t accept transactions with value less than allowed minimum
    modifier notTooSmallAmountOnly(){	
        if (msg.value < MIN_ACCEPTED_AMOUNT) throw;
        _;
    }


    //prevents reentrancy attacs
    bool private locked = false;
    modifier noReentrancy() {
        if (locked) throw;
        locked = true;
        _;
        locked = false;
    }
}//contract