/**
 *Submitted for verification at Etherscan.io on 2019-10-12
*/

/*
|| DIGITAL DOLLAR RETAINER REGISTRY (DDRR) ||

DEAR MSG.SENDER(S):

/ DDRR is a project in beta.
// Please audit and use at your own risk.
/// Entry into DDRR shall not create an attorney/client relationship.
//// Likewise, DDRR should not be construed as legal advice or replacement for professional counsel.

///// STEAL THIS C0D3SL4W ( . . . But tipping is also cool! See tip0E function below ;-0)

|| Open, ESQ LLC/DAO ||
*/

pragma solidity 0.5.9;

/***************
DDRR CONTRACT
***************/

contract DigitalDollarRetainerRegistry {
    
	mapping (uint256 => DDR) public rddr; // **mapping registered rddr call numbers**

	struct DDR {
        	address client; // **client ethereum address**
        	address provider; // **ethereum address that receives payments in exchange for goods or services**
        	ERC20 ddrToken; // **ERC-20 digital token address used to transfer value on ethereum under rddr / e.g., DAI 'digital dollar' - 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359**
        	string deliverable; // **goods or services (deliverable) retained for benefit of ethereum payments**
        	string governingLawForum; // **choice of law and forum for retainer relationship (or similar legal description)**
        	uint256 ddrNumber; // **rddr number generated on registration / identifies rddr for payDDR calls**
        	uint256 timeStamp; // **block.timestamp of registration used to calculate retainerTermination UnixTime**
        	uint256 retainerDuration; // **duration of rddr in seconds**
        	uint256 retainerTermination; // **termination date of rddr in UnixTime**
        	uint256 deliverableRate; // **rate for rddr deliverables in digital dollar wei amount / 1 = 1000000000000000000**
        	uint256 paid; // **tracking amount of designated ERC-20 paid under rddr in wei amount**
        	uint256 payCap; // **cap in wei amount to limit payments under rddr**;
    	}

	// **template legal wrapper stating general human-readable DDR terms for rddr to inherit**
	string public ddrTerms = "|| Establishing a digital retainer hereby as [[ddrNumber]] and acknowledging mutual consideration and agreement, Client, identified by ethereum address 0x[[client]], commits to perform under this digital payment transactional script capped at $[[payCap]] digital dollar value denominated in 0x[[ddrToken]] for benefit of Provider, identified by ethereum address 0x[[provider]], in exchange for prompt satisfaction of the following, [[deliverable]], to Client by Provider upon scripted payments set at the rate of $[[deliverableRate]] per deliverable, with such retainer relationship not to exceed [[retainerDuration]] seconds and to be governed by choice of [[governingLawForum]] law and 'either/or' arbitration rules in [[governingLawForum]]. ||";
	uint256 public RDDR; // **number of DDRs registered hereby**

	event Registered(address indexed client, address indexed provider); // **triggered on successful registration**
	event Paid(uint256 ratePaid, uint256 totalPaid, address indexed client); // **triggered on successful rddr payments**

	function registerDDR(
    	address client,
    	address provider,
    	ERC20 ddrToken,
    	string memory deliverable,
    	string memory governingLawForum,
    	uint256 retainerDuration,
    	uint256 deliverableRate,
    	uint256 payCap) public {
        	require(deliverableRate <= payCap, "constructor: deliverableRate cannot exceed payCap"); // **program safety check / economics**
        	uint256 ddrNumber = RDDR + 1; // **reflects new rddr value for tracking payments**
        	uint256 paid = 0; // **initial zero value for rddr** 
        	uint256 timeStamp = now; // **block.timestamp of rddr**
        	uint256 retainerTermination = timeStamp + retainerDuration; // **rddr termination date in UnixTime**
    
        	RDDR = RDDR + 1; // counts new entry to RDDR
    
        	rddr[ddrNumber] = DDR( // populate rddr data 
                	client,
                	provider,
                	ddrToken,
                	deliverable,
                	governingLawForum,
                	ddrNumber,
                	timeStamp,
                	retainerDuration,
                	retainerTermination,
                	deliverableRate,
                	paid,
                	payCap);
        	 
            	emit Registered(client, provider); 
        	}

	function payDDR(uint256 ddrNumber) public { // **forwards approved ddrToken deliverableRate amount to provider ethereum address**
    	DDR storage ddr = rddr[ddrNumber]; // **retrieve rddr data**
    	require (now <= ddr.retainerTermination); // **program safety check / time**
    	require(address(msg.sender) == ddr.client); // program safety check / authorization
    	require(ddr.paid + ddr.deliverableRate <= ddr.payCap, "payDAI: payCap exceeded"); // **program safety check / economics**
    	ddr.ddrToken.transferFrom(msg.sender, ddr.provider, ddr.deliverableRate); // **executes ERC-20 transfer**
    	ddr.paid = ddr.paid + ddr.deliverableRate; // **tracks amount paid under rddr**
        	emit Paid(ddr.deliverableRate, ddr.paid, msg.sender); 
    	}
   	 
	function tipOpenESQ() public payable { // **tip Open, ESQ LLC/DAO ether (¦®) value for legal engineering R+D / LEETH**
    	0xBBE222Ef97076b786f661246232E41BE0DFf6cc4.transfer(msg.value); // forwards value to OE-DAO ethereum address
    	}
}

/***************
ERC-20 CONTRACT - DDRR REFERENCE ATTACHMENT
***************/

/**
* @title ERC-20 Contract
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 {
	uint256 public totalSupply;

	function balanceOf(address who) public view returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);

	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Transfer(address indexed from, address indexed to, uint256 value);
}