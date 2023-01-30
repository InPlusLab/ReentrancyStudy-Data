/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

pragma solidity ^0.5.4;

contract Jeton {
    string  public name = "Hega Geoffroy";
    string  public symbol = "JEFF";
    uint256 public totalSupply = 10000000000000000000000; 
    uint8   public decimals = 18;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}

pragma solidity ^0.5.4;

contract Exchange {
	string public name = "Instant Exchange Cryptocurrency";
	Jeton public token; 
	uint public rate = 10; 

	event TokenPurchased(
		address account,
		address token, 
		uint amount, 
		uint rate
	);

	event TokenSold(
		address account,
		address token, 
		uint amount, 
		uint rate
	);

	constructor(Jeton _token) public {
		token = _token; 
	}

	function buyTokens() public payable {

		uint tokenAmount = msg.value * rate;

		require(token.balanceOf(address(this)) >= tokenAmount); 

		token.transfer(msg.sender, tokenAmount);

		emit TokenPurchased(msg.sender, address(token), tokenAmount, rate); 
	}

	function sellTokens(uint _amount) public payable {

		require(token.balanceOf(msg.sender) <= _amount);

		uint etherAmount = _amount / rate ;

		token.transferFrom(msg.sender, address(this), _amount);

		msg.sender.transfer(etherAmount);

		emit TokenSold(msg.sender, address(token), _amount, rate); 

	}

}