/**

 *Submitted for verification at Etherscan.io on 2019-03-20

*/



pragma solidity ^0.5.0;



/*

	Basic ERC-223 declaration

*/

contract ERC223Interface {

	uint256 public totalSupply;

	function transfer(address to, uint256 value) public;

	function transfer(address to, uint256 value, bytes memory data) public;

	event Transfer(address indexed from, address indexed to, uint256 value, bytes data);



	mapping (address => uint256) public balanceOf;

}





/*

	provides the tokenFallback function

	as required in the ERC-223 standard

*/

contract ContractReceiver {



	struct TKN {

		address sender;

		uint value;

		bytes data;

		bytes4 sig;

	}





	function tokenFallback(address _from, uint _value, bytes memory _data) public pure {

		TKN memory tkn;

		tkn.sender = _from;

		tkn.value = _value;

		tkn.data = _data;

		uint32 u = uint32(bytes4(_data[3])) + (uint32(bytes4(_data[2]) << 8)) + (uint32(bytes4(_data[1]) << 16)) + (uint32(bytes4(_data[0])) << 24);

		tkn.sig = bytes4(u);

	}

}





contract owned {

	address public owner;



	constructor() public {

		owner = msg.sender;

	}



	modifier onlyOwner {

		require(msg.sender == owner);

		_;

	}



	function transferOwnership(address newOwner) onlyOwner public {

		owner = newOwner;

	}

}













interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }



contract J5Token is owned, ERC223Interface{





	// name of our token

	string public name = "J-Five Gold";

	// symbol

	string public symbol = "J5G";

	uint8 public decimals = 18;

	uint256 public totalSupply = 10**9 * 10 ** uint256(decimals);



	// mapping of the state of all accounts

	// false => not frozen

	// true => frozen

	mapping (address => bool) public frozen;



	// allowance set by the wallet owner

	// it allows a different wallet use part of

	// your resources

	mapping (address => mapping (address => uint256)) public allowance;



	// events emitted by our smart contract

	// self-explanatory

	// for the definition of attributes go to the function definitions

	event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);

	event Burn(address indexed from, uint256 value);

	event FrozenFunds(address target, bool frozen);

	event Approval(address indexed _owner, address indexed _spender, uint256 _value);



	constructor() public{

		// sends all initial coin to the wallet of the creator of the token

		balanceOf[msg.sender] = totalSupply;	

	}



	

	/*

		internal/private function 

		

		contains the logic of actually transfering money from account to account



		attributes:

			_from: address => address of the wallet from which the transfer occurs

			_to: address => address of the wallet to which the tokens will be transfered

			_value: uint => amount of tokens to be transfered 

			_data: bytes => arbitrary data to be transfered with the transaction

							modeled after tx.data

	*/

	function _transfer(address _from, address _to, uint _value, bytes memory _data) private{

        uint codeLength;



        assembly {

            codeLength := extcodesize(_to)

        }

		require(_to != address(0x0));

		require(!frozen[_from], "sender's account is frozen");

		require(!frozen[_to], "receiver's account to frozen");

		require(balanceOf[_from] >= _value, "not enough money in sender's wallet");

		require(balanceOf[_to] + _value >= balanceOf[_to], "too much money in receiver's wallet");



		if (msg.sender != _from){

			allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;	

		}



        balanceOf[_from] = balanceOf[_from] - _value; 

        balanceOf[_to] = balanceOf[_to] +_value;



        if(codeLength>0) {

            ContractReceiver receiver = ContractReceiver (_to);

            receiver.tokenFallback(_from, _value, _data);

        }

        emit Transfer(_from, _to, _value, _data);

	

	}





	/*

		public function 

		

		acts as intermediary between outside world and internal _transfer function



		attributes:

			_to: address => address of the wallet to which the tokens will be transfered

			_value: uint => amount of tokens to be transfered 

			_data: bytes => arbitrary data to be transfered with the transaction

							modeled after tx.data

	*/

	function transfer(address _to, uint _value, bytes memory _data)public {

		_transfer(msg.sender, _to, _value, _data);

    }

    



	/*

		public function 

		

		acts as intermediary between outside world and internal _transfer function

		provided for the token to be compatible with ERC-20 standard



		attributes:

			_to: address => address of the wallet to which the tokens will be transfered

			_value: uint => amount of tokens to be transfered 

	*/

    function transfer(address _to, uint _value) public{

		bytes memory empty;

		_transfer(msg.sender, _to, _value, empty);

    }





	/*

		public function 

		

		transfer the money using allowance on a different account



		attributes:

			_from: address => address of the wallet from which the transfer will occur

			_to: address => address of the wallet to which the tokens will be transfered

			_value: uint => amount of tokens to be transfered 

			_data: bytes => arbitrary data to be transfered with the transaction

							modeled after tx.data

	*/

	function transferFrom(address _from, address _to, uint _value, bytes memory _data)public {

		require(allowance[_from][msg.sender] >= _value, "you are not allowed to use this many tokens");	

		_transfer(_from, _to, _value, _data);

    }



    

	/*

		public function 

		

		transfer the money using allowance on a different account

		intermediary between outside world and another public function transferFrom

		provided for the token to be compatible with ERC-20 standard



		attributes:

			_from: address => address of the wallet from which the transfer will occur

			_to: address => address of the wallet to which the tokens will be transfered

			_value: uint => amount of tokens to be transfered 

	*/

    function transferFrom(address _from, address _to, uint _value) public{

		bytes memory empty;

		transferFrom(_from, _to, _value, empty);

    }





	/*

		public function 

		

		used to freeze resources on your account



		attributes:

			freeze: bool => (

								false => unfreeze account

								true  => freeze account

							)

	*/

	function freezeAccount(bool freeze) public{

		frozen[msg.sender] = freeze;	

		emit FrozenFunds(msg.sender, freeze);

	}





	/*

		public function 

		

		allow other wallet to use part of your resources



		attributes:

			_spender: address => account you want to entitle to some of your tokens

			_value: uint => how many tokens you want to make available

	*/

	function approve(address _spender, uint256 _value) public returns (bool success){

		allowance[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);

		return true;

	}



	function approveCall(address _spender, uint256 _val, bytes memory _data) public returns (bool success){

		tokenRecipient recp = tokenRecipient(_spender);

		if(approve(_spender, _val)){

			recp.receiveApproval(msg.sender, _val, address(this), _data);

			return true;

		}

	}



}