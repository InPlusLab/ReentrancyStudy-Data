/**
 *Submitted for verification at Etherscan.io on 2019-06-30
*/

pragma solidity ^0.5.0;

	/* contract can send to others - we verify there is not a contract
	at address we are sending to. This prevents security issues
	*/
	
contract TriviaChain {

	/* Owner of the contract -- this is US */
	address payable public owner;
	
	/* Unix timestamp of when contract is valid from */
	uint256 public startdate = 1560737700;	
	
	/* Unix timestamp of when contract is valid until */
	uint256 public enddate = 1560737758;


	/* this is the question ID - needs to match with database question ID */
	int constant question_id = 18;

	/* Answer Hash to verify the user put in the correct answer - sha256
		It is the hash of the correct answer
	*/
	bytes correctAnswerHash = bytes('0x1670F2E42FEFA5044D59A65349E47C566009488FC57D7B4376DD5787B59E3C57'); //need to verify that same as toHEx

	
	/* constructor called whenever we initialize a contract sender will be us */
	constructor() public {owner = msg.sender; }

	/* standard modifier to only allow owner */
	modifier onlyOwner {
	require (msg.sender == owner);
	_;
	}

	
	/* fallback function so contract can recieve ether */
	
	function() external payable { }
	
	/* function to check there is no code at site we are sending funds to 
	   The contract holds the funds so users can see the pot payout and then 
	   the value after payout
	*/
	function checkAnswer(string memory answer) private view returns (bool) {
	
	bytes32 answerHash = sha256(abi.encodePacked(answer));
	
	/* this will cost gas on the blockchain 
	
	if(keccak256(answerHash) == keccak256(correctAnswerHash)) {
	this.correctAnswer = true;
	}
	
	*/
	
	if(keccak256(abi.encode(answerHash)) == keccak256(abi.encode(correctAnswerHash)))  {
	return true;
	}
	
	return false;
	
	}
	
	/* functinon to pay the correct recipients requires the owner to send*/
	
	function sendEtherToWinner(address payable recipient, uint amount) public payable onlyOwner() {
		recipient.transfer(amount);
	}
	
	/* gets the start time*/
	function get_startdate() public view  returns (uint256) {
        return startdate;
    }
	
	/* gets the time end*/
	function get_enddate() public view  returns (uint256) {
        return enddate;
    }
	
	/* gets the question id */
	
	function get_Id() public pure  returns (int) {
        return question_id;
    }
	
	function get_answer_hash() public view  returns (string memory) {
        return string(correctAnswerHash);
    }
	
	function getSha256(string memory input) public pure returns (bytes32) {

        bytes32 hash = sha256(abi.encodePacked(input));

        return (hash);
    }
	
}