/**

 *Submitted for verification at Etherscan.io on 2018-10-25

*/



pragma solidity ^ 0.4 .24;



contract Behavioral {

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract BAVC is Behavioral{

	using SafeMath

	for * ;

	

	string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    

    constructor()

	public {

        balanceOf[0x7b6141133745f26aE8061DF3F2f5d363c9d0b75d] = 1800000000000000000000000000;

        totalSupply = 1800000000000000000000000000;

        name = "BAVC";

        symbol = "BAVC";

        decimals = 18;

    }

    

    function transfer(address _to, uint256 _value) public{

    	require(_to != 0x0, "invalid addr");

    	require(_value > 0, "invalid value");

    	require(balanceOf[msg.sender] >= _value, "balance not enough");

    	require(balanceOf[_to] + _value > balanceOf[_to], "invalid value");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

    }

    

    function approve(address _spender, uint256 _value)

        public returns (bool success) {

        	require(_spender != 0x0, "invalid addr");

		require(_value > 0, "invalid value");

        allowance[msg.sender][_spender] = _value;

        return true;

    }

    

     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

     	require(_from != 0x0, "invalid addr");

        require(_to != 0x0, "invalid addr");

        require(_value > 0, "invalid value");

        require(balanceOf[_from] >= _value, "balance not enough");

    	require(balanceOf[_to] + _value > balanceOf[_to], "invalid value");

    	require(allowance[_from][msg.sender] >= _value, "allowance not enough");

    	

        balanceOf[_from] = balanceOf[_from].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }

    

}



library SafeMath {



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