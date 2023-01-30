/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity ^ 0.4 .24;

contract TurboContract {
	event Consume(
		uint256 value
	);
	event Supercharge(
		uint256 indexed index,
		address indexed addr,
		uint256 value
	);
	event Raise(
		uint256 indexed index,
		address indexed addr,
		uint256 value
	);
	event AirdDrop(
		address indexed addr,
		uint256 value
	);
	event Popularize(
		address indexed addr,
		uint256 value
	);
	event Develop(
		address indexed addr,
		uint256 value
	);
	
}

contract BaseContract is TurboContract {
	using SafeMath
	for * ;

	address public manager; //初始管理员

	mapping(uint256 => uint256) public superchargeTotal; //增压数量

	mapping(uint256 => uint256) public raiseTotal; //认筹数量

	uint256 public airDropTotal; //空投数量

	uint256 public popularizeTotal; //推广数量

	uint256 public developTotal; //发展数量

	uint256 public consumeTotal; //销毁数量

	TurboInterface constant private turboToken = TurboInterface(0x414310e2d38306d9b861f1646356f70c74ada812);

	function BaseContract() {
		manager = msg.sender;
	}

	function consume(uint256 value_)
	isManager()
	public {
		//cfg代币余额不足的不能续约
		require(turboToken.balanceOf(msg.sender) >= value_, "You don't have enough Turbo.");
		if(!turboToken.consume(msg.sender, value_)) {
			require(false, "error");
		}
		consumeTotal = consumeTotal.add(value_);
		emit Consume(
			value_
		);
	}

	function supercharge(uint256 index_, uint256 value_, address addr_)
	isManager()
	public {
		superchargeTotal[index_] = superchargeTotal[index_].add(value_);
		emit Supercharge(
			index_,
			addr_,
			value_
		);
	}

	function raise(uint256 index_, uint256 value_, address addr_)
	isManager()
	public {
		raiseTotal[index_] = raiseTotal[index_].add(value_);
		emit Raise(
			index_,
			addr_,
			value_
		);
	}

	function airdDrop(uint256 value_, address addr_)
	isManager()
	public {
		airDropTotal = airDropTotal.add(value_);
		emit AirdDrop(
			addr_,
			value_
		);
	}

	function popularize(uint256 value_, address addr_)
	isManager()
	public {
		popularizeTotal = popularizeTotal.add(value_);
		emit Popularize(
			addr_,
			value_
		);
	}

	function develop(uint256 value_, address addr_)
	isManager()
	public {
		developTotal = developTotal.add(value_);
		emit Develop(
			addr_,
			value_
		);
	}

	function kill()
	isManager()
	public {
		selfdestruct(msg.sender);
	}

	modifier isManager() {
		require(msg.sender == manager, "Not the manager");
		_;
	}

}

interface TurboInterface {

	function balanceOf(address _addr) returns(uint256);

	function transfer(address _to, uint256 _value) returns(bool);

	function approve(address _spender, uint256 _value) returns(bool);

	function transferFrom(address _from, address _to, uint256 _value) returns(bool success);

	function consume(address _from, uint256 _value) returns(bool success);
}

library SafeMath {

	function mul(uint256 a, uint256 b)
	internal
	pure
	returns(uint256 c) {
		if(a == 0) {
			return 0;
		}
		c = a * b;
		require(c / a == b, "mul failed");
		return c;
	}

	function sub(uint256 a, uint256 b)
	internal
	pure
	returns(uint256 c) {
		require(b <= a, "sub failed");
		c = a - b;
		require(c <= a, "sub failed");
		return c;
	}

	function add(uint256 a, uint256 b)
	internal
	pure
	returns(uint256 c) {
		c = a + b;
		require(c >= a, "add failed");
		return c;
	}

}