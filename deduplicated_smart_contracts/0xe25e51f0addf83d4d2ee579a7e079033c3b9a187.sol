/**

 *Submitted for verification at Etherscan.io on 2019-05-28

*/



pragma solidity ^0.5.4;

 

contract IMigrationContract {

    function migrate(address addr, uint256 nas) public returns (bool success);

}

 

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {

        uint256 z = x + y;

        assert((z >= x) && (z >= y));

        return z;

    }

 

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {

        assert(x >= y);

        uint256 z = x - y;

        return z;

    }

 

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {

        uint256 z = x * y;

        assert((x == 0)||(z/x == y));

        return z;

    }

 

}

 

contract Token is SafeMath {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

 

 

/*  ERC 20 token */

contract StandardToken is Token {

 

    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {

			if ((balances[_to] + _value) <= balances[_to]) {

				return false;

			} else {

				balances[msg.sender] = safeSubtract(balances[msg.sender], _value);

				balances[_to] = safeAdd(balances[_to], _value);

				emit Transfer(msg.sender, _to, _value);

				return true;

			}

        } else {

            return false;

        }

    }

 

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

		if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && (balances[_to] + _value) > balances[_to]) {

            balances[_to] = safeAdd(_value, balances[_to]);

            balances[_from] = safeSubtract(balances[_from], _value);

            allowed[_from][msg.sender] = safeSubtract(allowed[_from][msg.sender], _value);

            emit Transfer(_from, _to, _value);

            return true;

        } else {

            return false;

        }

    }

 

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];

    }

 

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

 

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }

 

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract OBNToken is StandardToken {

 

    // metadata 

    string  public constant name = "Optimal Bargain Nebulae";

    string  public constant symbol = "OBN";

    uint256 public constant decimals = 18;

    string  public version = "1.0";

 

    // contracts

    address payable public ethFundDeposit;  // Address to withdraw ETH to

    address public newContractAddr;         // New address for updated contract

       

    uint256 public tokenMigrated = 0;     // total number of migrated token

 

    // events

    event IncreaseSupply(uint256 _value);

    event DecreaseSupply(uint256 _value);

    event Migrate(address indexed _to, uint256 _value);

 

    // transfer token with coin

    function formatDecimals(uint256 _value) internal returns (uint256 ) {

		uint256 value = safeMult(_value, 10 ** decimals);

        return value;

    }

 

    // constructor

     constructor(

        address payable _ethFundDeposit,

		uint256 _totalCoin) public 

    {

        ethFundDeposit = _ethFundDeposit;             

		

        totalSupply = formatDecimals(_totalCoin);

		balances[ethFundDeposit] = totalSupply;

    }



    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

 

    /// Token overshoot

    function increaseSupply (uint256 _value) isOwner external {

		require(_value > 0);

        uint256 value = formatDecimals(_value);

		require(totalSupply + value > totalSupply);

        totalSupply = safeAdd(totalSupply, value);

		balances[ethFundDeposit] = safeAdd(balances[ethFundDeposit], value);

        emit IncreaseSupply(_value);

    }

 

    /// decrease TotalSupply from owner

    function decreaseSupply (uint256 _value) isOwner external {

		require(_value > 0);

        uint256 value = formatDecimals(_value);

		require(value <= balances[ethFundDeposit]);

        require(value  <= totalSupply);

		

		totalSupply = safeSubtract(totalSupply, value);

		balances[ethFundDeposit] = safeSubtract(balances[ethFundDeposit], value);

		

        emit DecreaseSupply(_value);

    }

 

    /// Store the new address of the contract

    function setMigrateContract(address _newContractAddr) isOwner external {

        require(_newContractAddr != newContractAddr);

        newContractAddr = _newContractAddr;

    }

	

	/// Migrate contract to given address

    function migrate() external {

        require(newContractAddr != address(0x0));

 

        uint256 tokens = balances[msg.sender];

        require(tokens != 0);

 

        balances[msg.sender] = 0;

        tokenMigrated = safeAdd(tokenMigrated, tokens);

 

        IMigrationContract newContract = IMigrationContract(newContractAddr);

        if(!newContract.migrate(msg.sender, tokens))

			revert("New contract migrates failed."); 

        emit Migrate(msg.sender, tokens);               // log it

    }

 

    /// Set new owner's address

    function changeOwner(address payable _newFundDeposit) isOwner external {

        require(_newFundDeposit != address(0x0));

        ethFundDeposit = _newFundDeposit;

    }

	

	/// transfer balance to owner

	function withdrawEther() isOwner external returns (bool success){

		require(address(this).balance != 0);

        return ethFundDeposit.send(address(this).balance);

	}

	

	/// can accept ether

	function() payable external{

    }

}