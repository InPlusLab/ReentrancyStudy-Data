pragma solidity ^0.5.7;

import "./timelocks.sol";
import "./ierc20.sol";
import "./safemath.sol";
import "./erc20.sol";
import "./burnable.sol";
import "./ownable.sol";

contract ContractFallbacks {
    function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;
	function onTokenTransfer(address from, uint256 amount, bytes memory data) public returns (bool success);
}

contract FortemCapital is IERC20, ERC20, ERC20Burnable, Ownable, Timelocks{
	using SafeMath for uint256;

	string public name;
	string public symbol;
	uint8 public decimals;

	/**
	*	@dev Token constructor
	*/
	constructor () public {
		name = "Fotrem Capital Token";	//nazwa tokena
		symbol = "FCQ";					//symbol tokena
		decimals = 0; 					//miejsc po przecinku

		owner = msg.sender;				//właścicel kontraktu
		emit OwnershipTransferred(address(0), owner);

		_mint(address(this), 210000000);	//ilosć tokenów
		uint locktime = now + 180 * 1 days; //blokady na pół roku

		_lock(locktime, 5250000, 0x8BD28e698ae9B94C4014e545788d823E2831E198);  	// 4*2.5% team tokens
		_lock(locktime, 5250000, 0x002D24862F0E075b987b22E98575f4Fe29F5e825);	//
		_lock(locktime, 5250000, 0xDec2Ced03dba3c7fa13bb1d9b1c4DC60c23fE09A);	//
		_lock(locktime, 5250000, 0x34B25D01aCc061f2aFA097F6c53D01892dB9e61f);	//
		_transfer(address(this), 0x2C44Cbb56e5Dc4A2C152BF91Cd35ca8481E9a614, totalSupply()-lockedBalance); // wszystkie pozostałe tokeny
	}

	/**
	 * @dev function that allow to approve for transfer and call contract in one transaction
	 * @param _spender contract address
	 * @param _amount amount of tokens
	 * @param _extraData optional encoded data to send to contract
	 * @return True if function call was succesfull
	 */
    function approveAndCall(address _spender, uint256 _amount, bytes calldata _extraData) external returns (bool success)
	{
        require(approve(_spender, _amount), "ERC20: Approve unsuccesfull");
        ContractFallbacks(_spender).receiveApproval(msg.sender, _amount, address(this), _extraData);
        return true;
    }

    /**
     * @dev function that transer tokens to diven address and call function on that address
     * @param _to address to send tokens and call
     * @param _value amount of tokens
     * @param _data optional extra data to process in calling contract
     * @return success True if all succedd
     */
	function transferAndCall(address _to, uint _value, bytes calldata _data) external returns (bool success)
  	{
  	    _transfer(msg.sender, _to, _value);
		ContractFallbacks(_to).onTokenTransfer(msg.sender, _value, _data);
		return true;
  	}

}
