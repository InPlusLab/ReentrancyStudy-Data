/**

 *Submitted for verification at Etherscan.io on 2019-03-11

*/



pragma solidity ^0.5.1;



contract SocialBetDonations {



	address public owner;





	uint public balance;

	mapping (address => uint) public donations;

	uint public m_nbDonations;



	event LogDonation(address indexed donator, uint amount, uint donationId);

	event OwnerChanged(address indexed owner, address indexed newOwner);

	event ContractDestroyed(address indexed contractAddress);



  	constructor () public {

  		owner = msg.sender;

  		balance = 0;

  	}



	modifier isOwner () {

		require(owner == msg.sender);

		_;

	}



	function deposit() public payable {



		require(msg.value > 0);



		m_nbDonations = add(m_nbDonations, 1);



		uint _curBalance = donations[msg.sender];

		uint _newBalance = add(_curBalance, msg.value);

		donations[msg.sender] = _newBalance;



		balance = add(balance, msg.value);



		emit LogDonation(msg.sender, msg.value, m_nbDonations);

	}



	function withdraw() isOwner public {

        msg.sender.transfer(address(this).balance);

        balance = 0;

    }





	function transferOwner(address newOwner) isOwner public returns (bool) {

		emit OwnerChanged(owner, newOwner);

		owner = newOwner;

	}



	function kill() public payable isOwner {

		emit ContractDestroyed(address(this));

		selfdestruct(msg.sender);

	}



	function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

		assert(_b <= _a);

		return _a - _b;

	}



	function add(uint256 a, uint256 b) internal pure returns (uint256) {

		uint256 c = a + b;

		assert(c >= a);

		return c;

	}

}