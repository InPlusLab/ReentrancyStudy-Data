/**
 *Submitted for verification at Etherscan.io on 2020-07-06
*/

pragma solidity ^0.5.1;
//区块链技术服务+手机号/微信：19933104907
contract ERC20Standard {
    using SafeMath for uint256;
	uint256 public totalSupply;
	string public name;
	uint8 public decimals;
	string public symbol;
	address public owner;

	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;

	//Event which is triggered to log all transfers to this contract's event log
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint256 _value
		);
		
	//Event which is triggered whenever an owner approves a new allowance for a spender.
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint256 _value
		);
		
   constructor(uint256 _totalSupply, string memory _symbol, string memory _name, uint8 _decimals) public {
		symbol = _symbol;
		name = _name;
        decimals = _decimals;
		owner = msg.sender;
        totalSupply = SafeMath.mul(_totalSupply ,(10 ** uint256(decimals)));
        balances[owner] = totalSupply;
  }

	function balanceOf(address _owner) view public returns (uint256) {
		return balances[_owner];
	}

	function transfer(address _recipient, uint256 _value)public returns(bool){
	    require(_recipient!=address(0));
		require(balances[msg.sender] >= _value && _value >= 0);
	    require(balances[_recipient].add(_value)>= balances[_recipient]);
	    balances[msg.sender] = balances[msg.sender].sub(_value) ;
	    balances[_recipient] = balances[_recipient].add(_value) ;
	    emit Transfer(msg.sender, _recipient, _value);  
	    return true;
    }

	function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
	    require(_to!=address(0));
		require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value >= 0);
		require(balances[_to].add(_value) >= balances[_to]);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value) ;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value) ;
        emit Transfer(_from, _to, _value);
        return true;
    }

	function approve(address _spender, uint256 _value) public returns(bool){
	    require((_value==0)||(allowed[msg.sender][_spender]==0));
    	allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) view public returns (uint256) {
		return allowed[_owner][_spender];
	}


}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;} uint256 c = a * b; assert(c / a == b); return c;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a / b; return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {assert(b <= a); return a - b;}
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b; assert(c >= a); return c;}
}