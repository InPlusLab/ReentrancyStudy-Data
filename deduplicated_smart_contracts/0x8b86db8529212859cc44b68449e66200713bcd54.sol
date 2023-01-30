/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity ^0.4.11;



contract Token 

{



    function totalSupply() constant returns (uint256 supply) {}

	

    function balanceOf(address _owner) constant returns (uint256 balance) {}

	

    function transfer(address _to, uint256 _value) returns (bool success) {}

	

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

	

    function approve(address _spender, uint256 _value) returns (bool success) {}

	

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

	

	event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



}





contract StandardToken is Token

{



    function transfer(address _to, uint256 _value) returns (bool success) 

	{

        

        

		

        if (balances[msg.sender] >= _value && _value > 0) 

		{

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } 

		else 

		{ 

		return false; 

		}

    }

	

	function transferFrom(address _from, address _to, uint256 _value) returns (bool success) 

	{

        

        

		

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) 

		{

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            Transfer(_from, _to, _value);

            return true;

        } 

		else 

		{ 

		return false; 

		}

    }

	

	function balanceOf(address _owner) constant returns (uint256 balance) 

	{

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) returns (bool success) 

	{

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant returns (uint256 remaining) 

	{

      return allowed[_owner][_spender];

    }



    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;

}



contract Midelcoin is StandardToken 

{



	/* Public variables of the token */



    /*

    NOTE:

    The following variables are OPTIONAL vanities. One does not have to include them.

    They allow one to customize the token contract & in no way influences the core functionality.

    Some wallets/interfaces might not even bother to look at this information.

    */

	

	string public name;                   // Token Name can be seen by the public

    uint8 public decimals;                // How many decimals to show. Standard compliant 18 is used.

    string public symbol;                 // The token symbol.

    string public version = 'H1.0'; 	  //human 1.0 standard. Just an arbitrary version scheme.

    uint256 public unitsOneEthCanBuy;     // Setting the ICO price.

    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  

    address public fundsWallet;           // Where the ETH raised is transferred?

	uint256 public startDate;

    uint256 public bonusEnds;

    uint256 public endDate;

    uint256 public tokens;

	

	// This is a constructor function 

 

    function Midelcoin() {

        balances[msg.sender] = 100000000000000000000000000;             // 100000000 ( Tokens) * 1000000000000000000 (18 decimals).

        totalSupply = 100000000000000000000000000;                      // 100000000MDL total supply.

        name = "Midelcoin";                                   			 	// The token name is Midelcoin. 

        decimals = 18;                                               	// Amount of decimals for display purposes

        symbol = "MDL";                                             	// Symbol for display purposes

        unitsOneEthCanBuy = 24400;                                      // The price fixed at ETH = $122 at the rate of $0.005/MDL

        fundsWallet = msg.sender;                                    	// The owner of the contract gets ETH

		

		bonusEnds = now + 4 weeks;                                      // Bonus ends exactly a month after the contract launch

        endDate = now + 10 weeks;                                       // Sale ends exactly two months after the launch

    }

	

	function () public payable {



        require(now >= startDate && now <= endDate);

        

        if (balances[fundsWallet] >= 25000000)

        {

            if (now <= bonusEnds) 

			{



				tokens = msg.value * 26000;



			} 

        

			else

			{



				tokens = msg.value * 24400;



			}

        }

		

		else 

		{

			tokens = msg.value * 0; 

		}



        balances[fundsWallet] = balances[fundsWallet] - tokens;

        balances[msg.sender] = balances[msg.sender] + tokens;



        Transfer(fundsWallet, msg.sender, tokens); // Broadcast a message to the blockchain



        //Transfer ether to fundsWallet

        fundsWallet.transfer(msg.value);  



    }

	

	/* Approves and then calls the receiving contract */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);



        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }

        return true;

    }

}