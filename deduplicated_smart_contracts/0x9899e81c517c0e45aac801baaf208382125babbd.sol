/**

 *Submitted for verification at Etherscan.io on 2019-02-04

*/



pragma solidity >=0.4.25 <0.6.0;



interface TokenWithBalance {

	function balanceOf(address tokenOwner) external view returns (uint balance);

}



interface TokenWithAllowance {

	function allowance(address tokenOwner, address spender) external view returns (uint remaining);

}



contract DolomiteTokenReader {



	function balancesOf(address owner, address[] memory tokens) public view returns (address[] memory, uint[] memory) {

		uint[] memory balances = new uint[](tokens.length);



    for (uint i = 0; i < tokens.length; i++) {

    	balances[i] = _balanceOf(owner, tokens[i]);

    }



    return (tokens, balances);

	}



	function balancesFor(address token, address[] memory owners) public view returns (address[] memory, uint[] memory) {

		uint[] memory balances = new uint[](owners.length);



		for (uint i = 0; i < owners.length; i++) {

			balances[i] = _balanceOf(owners[i], token);

		}



		return (owners, balances);

	}



	function allowances(address owner, address spender, address[] memory tokens) public view returns (address[] memory, uint[] memory) {

		uint[] memory allowances = new uint[](tokens.length);



		for (uint i = 0; i < tokens.length; i++) {

			allowances[i] = _allowance(owner, spender, tokens[i]);

		}



		return (tokens, allowances);

	}



	// ---------------------------------------------

	// Helpers



	function _balanceOf(address owner, address token) internal view returns (uint) {

		if (token == address(0)) return owner.balance;

		return TokenWithBalance(token).balanceOf(owner);

	}



	function _allowance(address owner, address spender, address token) internal view returns (uint) {

		if (token == address(0)) return 0;

		return TokenWithAllowance(token).allowance(owner, spender);

	}

}