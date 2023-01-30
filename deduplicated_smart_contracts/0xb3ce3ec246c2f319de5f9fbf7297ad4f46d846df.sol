/**

 *Submitted for verification at Etherscan.io on 2019-01-20

*/



pragma solidity ^0.4.19;



/* 

	Utility contract for Arby and it's various exchanges

	Some of these functions originated from (and then improved upon) DeltaBalances.github.io 

	Check balances for multiple ERC20 tokens for multiple users in 1 batched call

	Check exchange rates for many Bancor contracts in one batched call

*/



// EtherDelta interface

contract EtherDelta {

    function balanceOf(address tokenAddress, address userAddress) public view returns (uint);

}



// WETH interface for 0x

contract WETH_0x {

    // function balanceOf(address /*user*/) public view returns (uint);

    function balanceOf(address userAddress) public view returns (uint);

}



// ERC20 interface

contract Token {

    // function balanceOf(address /*tokenOwner*/) public view returns (uint /*balance*/);

    // function transfer(address /*to*/, uint /*tokens*/) public returns (bool /*success*/);

    function balanceOf(address tokenOwner) public view returns (uint /*balance*/);

    function transfer(address toAddress, uint tokens) public returns (bool /*success*/);

}



// Bancor's interface

contract BancorConverter {

    function getReturn(address fromToken, address toToken, uint amount) public constant returns (uint /*expectedReturn*/);

}



contract BalanceChecker {

	

	address public admin; 



	function BalanceChecker() public {

        admin = 0x00cdE0b7CfC51041FE62B08E6C45c59aE5109650; // in case of deploy using MEW with no arguments

	}



	//default function, don't accept any ETH

	function() public payable {

		revert();

	}

	

	//limit address to the creating address

    modifier isAdmin() {

        require(msg.sender == admin);

	     _;

    }

    

	// selfdestruct for cleanup

	function destruct() public isAdmin {

		selfdestruct(admin);

	}



	// backup withdraw, if somehow ETH gets in here

	function withdraw() public isAdmin {

    	admin.transfer(this.balance);

	}



	// backup withdraw, if somehow ERC20 tokens get in here

	function withdrawToken(address token, uint amount) public isAdmin {

    	require(token != address(0x0)); //use withdraw for ETH

    	require(Token(token).transfer(msg.sender, amount));

	}

  

	/* Get multiple token balances on EtherDelta (or similar exchange)

	   Possible error throws:

	       - invalid exchange contract 

	       - using an extremely large array (gas cost too high?)

	       

	   Returns array of token balances in wei units. */

	function deltaBalances(address exchange, address user,  address[] tokens) public view returns (uint[]) {

		EtherDelta ex = EtherDelta(exchange);

	    uint[] memory balances = new uint[](tokens.length);

	    

		for(uint i = 0; i< tokens.length; i++){

			balances[i] = ex.balanceOf(tokens[i], user);

		}	

		return balances;

	}

	

	/* Get multiple token balances on EtherDelta (or similar exchange)

	   Possible error throws:

	       - invalid exchange contract 

	       - using extremely large arrays (gas cost too high?)

	       

	   Returns array of token balances in wei units.

	   Balances in token-first order [token0ex0, token0ex1, token0ex2, token1ex0, token1ex1 ...] */

	function multiDeltaBalances(address[] exchanges, address user,  address[] tokens) public view returns (uint[]) {

	    uint[] memory balances = new uint[](tokens.length * exchanges.length);

	    

	    for(uint i = 0; i < exchanges.length; i++){

			EtherDelta ex = EtherDelta(exchanges[i]);

			

    		for(uint j = 0; j< tokens.length; j++){

    		    

    			balances[(j * exchanges.length) + i] = ex.balanceOf(tokens[j], user);

    		}

	    }

		return balances;

	}

  

  /* Check the token balance of a wallet in a token contract

     Avoids possible errors:

        - returns 0 on invalid exchange contract 

        - return 0 on non-contract address 

       

     Mainly for internal use, but public for anyone who thinks it is useful    */

   function tokenBalance(address user, address token) public view returns (uint) {

       //  check if token is actually a contract

        uint256 tokenCode;

        assembly { tokenCode := extcodesize(token) } // contract code size

        if(tokenCode > 0)

        {

            Token tok = Token(token);

            //  check if balanceOf succeeds

            if(tok.call(bytes4(keccak256("balanceOf(address)")), user)) {

                return tok.balanceOf(user);

            } else {

                  return 0; // not a valid balanceOf, return 0 instead of error

            }

        } else {

            return 0; // not a contract, return 0 instead of error

        }

   }

  

    /* Check the token balances of a wallet for multiple tokens

       Uses tokenBalance() to be able to return, even if a token isn't valid 

	   Possible error throws:

	       - extremely large arrays (gas cost too high) 

	       

	   Returns array of token balances in wei units. */

	function walletBalances(address user,  address[] tokens) public view returns (uint[]) {

	    require(tokens.length > 0);

		uint[] memory balances = new uint[](tokens.length);

		

		for(uint i = 0; i< tokens.length; i++){

			if( tokens[i] != address(0x0) ) { // ETH address in Etherdelta config

			    balances[i] = tokenBalance(user, tokens[i]);

			}

			else {

			   balances[i] = user.balance; // eth balance	

			}

		}	

		return balances;

	}

	

	 /* Combine walletBalances() and deltaBalances() to get both exchange and wallet balances for multiple tokens.

	   Possible error throws:

	       - extremely large arrays (gas cost too high) 

	       

	   Returns array of token balances in wei units, 2* input length.

	   even index [0] is exchange balance, odd [1] is wallet balance

	   [tok0ex, tok0, tok1ex, tok1, .. ] */

	function allBalances(address exchange, address user,  address[] tokens) public view returns (uint[]) {

		EtherDelta ex = EtherDelta(exchange);

		uint[] memory balances = new uint[](tokens.length * 2);

		

		for(uint i = 0; i< tokens.length; i++){

		    uint j = i * 2;

			balances[j] = ex.balanceOf(tokens[i], user);

			if( tokens[i] != address(0x0) ) { // ETH address in Etherdelta config

			    balances[j + 1] = tokenBalance(user, tokens[i]);

			} else {

			   balances[j + 1] = user.balance; // eth balance	

			}

		}

		return balances; 

	}



	/* Similar to allBalances, with the addition of supporting multiple users

	   When calling this funtion through Infura, it handles a large number of users/tokens before it

	   fails and returns 0x0 as the result. So there is some max number of arguements you can send...

	   */

	function allBalancesForManyAccounts(

	    address exchange, 

	    address[] users,  

	    address[] tokens

	) public view returns (uint[]) {

		EtherDelta ex = EtherDelta(exchange);

		uint usersDataSize = tokens.length * 2;

		uint[] memory balances = new uint[](usersDataSize * users.length);

		

		for(uint k = 0; k < users.length; k++){

    		for(uint i = 0; i < tokens.length; i++){

    		    uint j = i * 2;

    			balances[(k * usersDataSize) + j] = ex.balanceOf(tokens[i], users[k]);

    			if( tokens[i] != address(0x0) ) { // ETH address in Etherdelta config

    			    balances[(k * usersDataSize) + j + 1] = tokenBalance(users[k], tokens[i]);

    			} else {

    			   balances[(k * usersDataSize) + j + 1] = users[k].balance; // eth balance	

    			}

    		}

		}

		return balances; 

	}

	

	/* Check the balances of many address' WETH (which is a 0x ETH wrapper for 0x exchanges)

	   */

	function allWETHbalances(

	    address wethAddress, 

	    address[] users

    ) public view returns (uint[]) {

		WETH_0x weth = WETH_0x(wethAddress);

		uint[] memory balances = new uint[](users.length);

		for(uint k = 0; k < users.length; k++){

    		balances[k] = weth.balanceOf(users[k]);

		}

		return balances; 

	}

	

	/* Make calls to many BancorConverter contracts to get expectedReturns based on current market rate

	    */

   function getManyReturnsForManyConverters_Bancor(

        address[] bancorConverterContracts,

        address[] fromTokens,

        address[] toTokens,

        uint[] amounts

   ) public view returns (uint[]) {

        // Ensure all array params are of the same length

        require(amounts.length == toTokens.length && 

            toTokens.length == fromTokens.length && 

            fromTokens.length == bancorConverterContracts.length);



        uint[] memory expectedReturns = new uint[](amounts.length);

		for(uint k = 0; k < amounts.length; k++){

		    BancorConverter bancor = BancorConverter(bancorConverterContracts[k]);

    		expectedReturns[k] = bancor.getReturn(fromTokens[k], toTokens[k], amounts[k]);

		}

		return expectedReturns; 

   }

   

   /* Make calls to one BancorConverter contract to get expectedReturns based on current market rate

	    */

   function getManyReturns_Bancor(

        address bancorConverterContract,

        address fromToken,

        address toToken,

        uint[] amounts

   ) public view returns (uint[]) {

        BancorConverter bancor = BancorConverter(bancorConverterContract);

        uint[] memory expectedReturns = new uint[](amounts.length);

		for(uint k = 0; k < amounts.length; k++){

    		expectedReturns[k] = bancor.getReturn(fromToken, toToken, amounts[k]);

		}

		return expectedReturns; 

   }

	    

}