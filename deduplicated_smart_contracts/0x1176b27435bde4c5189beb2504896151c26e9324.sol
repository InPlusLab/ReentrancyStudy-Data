pragma solidity ^0.4.11;
contract ERC20Standard {
	
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint)) allowed;

	//Fix for short address attack against ERC20
	modifier onlyPayloadSize(uint size) {
		assert(msg.data.length == size + 4);
		_;
	} 

	function balanceOf(address _owner) public constant returns (uint balance) {
	    return balances[_owner];
	}

	function transfer(address _recipient, uint _value) onlyPayloadSize(2*32) public {
		require(balances[msg.sender] >= _value && _value > 0);
	    balances[msg.sender] -= _value;
	    balances[_recipient] += _value;
	    Transfer(msg.sender, _recipient, _value);        
    }

	function transferFrom(address _from, address _to, uint _value) public {
		require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
    }

	function approve(address _spender, uint _value) public {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
	}

	function allowance(address _spender, address _owner) public constant returns (uint balance) {
		return allowed[_owner][_spender];
	}

	//Event which is triggered to log all transfers to this contract's event log
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
		);
		
	//Event is triggered whenever an owner approves a new allowance for a spender.
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint _value
		);

}

contract USBcoin is ERC20Standard {
	string public name = "USBcoin";
	uint8 public decimals = 8;
	string public symbol = "USB";
	uint public totalSupply = 1000000000000000000;
	    
	function USBcoin() {
	    balances[msg.sender] = totalSupply;
	}
	
	function safeSub(uint a, uint b) internal returns(uint) {
		assert(b <= a);
		return a - b;
    }
    
    function burn(uint value, address from) public returns (bool) {
        balances[from] = safeSub(balances[from], value);
        totalSupply = safeSub(totalSupply, value);  
        Transfer(from, 0, value);
        return true;
    }
}