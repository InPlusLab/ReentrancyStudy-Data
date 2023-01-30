/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity 0.5.4;



contract Bank {

	address owner;

	uint256 public minDeposit = 1 ether;

	mapping (address => uint256) public balances;

	Logger private TrustLog;



	constructor(address _logger) payable public {

		owner = msg.sender;

		TrustLog = Logger(_logger);

	}



	function deposit() public payable {

		if (msg.value >= minDeposit) {

			balances[msg.sender]+=msg.value;

			TrustLog.LogTransfer(msg.sender,msg.value,"deposit");

		} else {

			TrustLog.LogTransfer(msg.sender,msg.value,"depositFailed");

		}

	}



	function withdraw(uint256 _amount) public {

		if(_amount <= balances[msg.sender]) {

		    (bool success, ) = msg.sender.call.value(_amount)("");

			if(success) {

				balances[msg.sender] -= _amount;

				TrustLog.LogTransfer(msg.sender, _amount, "withdraw");

			} else {

				TrustLog.LogTransfer(msg.sender, _amount, "withdrawFailed");

			}

		}

	}



	function checkBalance(address _addr) public view returns (uint256) {

		return balances[_addr];

	}

}



contract Logger {

	struct Message {

		address sender;

		uint256 amount;

		string note;

	}



	Message[] History;

	Message public LastLine;



	function LogTransfer(address _sender, uint256 _amount, string memory _note) public {

		LastLine.sender = _sender;

		LastLine.amount = _amount;

 		LastLine.note = _note;

		History.push(LastLine);

	}

}