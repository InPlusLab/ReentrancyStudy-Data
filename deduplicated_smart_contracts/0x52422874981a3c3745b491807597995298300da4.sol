/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

pragma solidity 0.5.13;

contract AP3 {

	uint256 constant private TOKEN_PRECISION = 1e18;
	
	uint256 constant private initial_supply = 777 * TOKEN_PRECISION;

	string constant public name = "AP3 M4DN3SS";
	string constant public symbol = "AP3";
	uint8 constant public decimals = 18;

	uint8 constant public burn_rate = 7;
	
	struct User {
		uint256 balance;
		mapping(address => uint256) allowance;
	}

	struct Info {
		uint256 totalSupply;
		mapping(address => User) users;
		address admin;
		bool maddness;
	}
	Info private info;


	event Transfer(address indexed from, address indexed to, uint256 tokens);
	event Approval(address indexed owner, address indexed spender, uint256 tokens);

	constructor() public {
	    info.maddness = false;
	    info.admin = msg.sender;
		info.totalSupply = initial_supply;
		info.users[msg.sender].balance = initial_supply;
		emit Transfer(address(0x0), msg.sender, initial_supply);
	}


    function start_maddness () public {
        require(msg.sender == info.admin);
        require(!info.maddness);
        info.maddness = true;
    }
    
	function transfer(address _to, uint256 _tokens) external returns (bool) {
		_transfer(msg.sender, _to, _tokens);
		return true;
	}
	
	function balanceOf(address _user) public view returns (uint256) {
		return info.users[_user].balance;
	}

	function approve(address _spender, uint256 _tokens) external returns (bool) {
		info.users[msg.sender].allowance[_spender] = _tokens;
		emit Approval(msg.sender, _spender, _tokens);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _tokens) external returns (bool) {
		require(info.users[_from].allowance[msg.sender] >= _tokens);
		info.users[_from].allowance[msg.sender] -= _tokens;
		_transfer(_from, _to, _tokens);
		return true;
	}

	function totalSupply() public view returns (uint256) {
		return info.totalSupply;
	}

	function allowance(address _user, address _spender) public view returns (uint256) {
		return info.users[_user].allowance[_spender];
	}

	function _transfer(address _from, address _to, uint256 _tokens) internal returns (uint256) {
		require(balanceOf(_from) >= _tokens);
		
		info.users[_from].balance -= _tokens;
		uint256 _transferred = 0;
		
		if(info.maddness){
		    uint256 _burnedAmount = _tokens * burn_rate / 100;
    		_transferred = _tokens - _burnedAmount;
    		info.users[_to].balance += _transferred;
    		info.totalSupply -= _burnedAmount;
            emit Transfer(_from, address(0x0), _burnedAmount);
		}
		else
		{
    		_transferred = _tokens;
    		info.users[_to].balance += _transferred;
		}
        
		emit Transfer(_from, _to, _transferred);

		return _transferred;
	}
}