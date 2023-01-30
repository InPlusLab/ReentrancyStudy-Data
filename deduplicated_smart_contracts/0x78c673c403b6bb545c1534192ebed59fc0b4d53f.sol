pragma solidity ^0.5.0;



import "./ERC20.sol";

import "./Owned.sol";

import "./ERC20Detailed.sol";



contract BWA is ERC20, Owned, ERC20Detailed("BWAcoin", "BWA", 18) {

	/**

	* @dev Destroys `amount` tokens from the caller.

	*

	* See `ERC20._burn`.

	*/

	function burn(uint256 amount) public onlyOwner returns (bool) {

		_burn(msg.sender, amount);

		return true;

	}



	/**

	* @dev See `ERC20._mint`.

	*

	* Requirements:

	*

	* - the caller must be the `Owner`.

	*/

	function mint(address account, uint256 amount) public onlyOwner returns (bool) {

		_mint(account, amount);

		return true;

	}



	/**

	* @dev See `ERC20._mint`.

	*

	* Requirements:

	*

	* - the caller must be the `Owner`.

	*/

	function mint(uint256 amount) public onlyOwner returns (bool) {

		_mint(msg.sender, amount);

		return true;

	}



	/**

	* @dev Owner can transfer out any accidentally sent ERC20 tokens.

	*/

	function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool) {

		return ERC20(tokenAddress).transfer(owner, tokens);

	}

}