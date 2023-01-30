/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity 0.4.21;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {



    address public owner;

    

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

    * @dev Throws if called by any account other than the owner.

    */

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    /**

    * @dev Allows the current owner to transfer control of the contract to a newOwner.

    * @param newOwner The address to transfer ownership to.

    */

    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }



}

/**

 * @title ECOREAL

 * @dev ECOREAL Token contract's interface.

 */

contract ECOREAL {

    function transfer(address to, uint value) public returns(bool ok);

}

/**

 * @title ECOREALOwner

 * @dev Main contract, using for controlling ECOREAL Token.

 */

contract ECOREALOwner is Ownable {



	bool public exchangeEnabled = true;  // default as true.

	address public constant ECOREALTOKEN = 0xb052F8A33D8bb068414EaDE06AF6955199f9f010;  // address of ECOREAL token contract.



	event ExchangeEnabledStatus(bool enabled);

	event WithdrawETH(uint256 amount);

	/**

    * @dev Constructor

    * @param _owner owner of this contract who can get this contract's token and ETH.

    */	

	function ECOREALOwner(address _owner) public {

		owner = _owner;

	}

	/**

    * @dev Set flag which means enable exchange or not

    * @param _enabled true:enabled, false:disabled

    */

	function setExchangeEnabled(bool _enabled) public onlyOwner {

		exchangeEnabled = _enabled;

		emit ExchangeEnabledStatus(_enabled);

	}

	/**

    * @dev Owner can get this contract's ECOREAL token.

    * @param amount amount of ECOREAL token which will be transferred from contract to owner.

    */

	function withdrawECOREAL(uint256 amount) public onlyOwner{

		require(ECOREAL(ECOREALTOKEN).transfer(owner,amount));

	}

	/**

    * @dev Owner withdraw all ETH of this contract

    */

	function withdrawETH() public onlyOwner {

		uint256 amount = address(this).balance;  // get ETH amount of this contract.

		require(amount > 0);  // if amount == 0, will throw and end function calling. 

		owner.transfer(amount);  // send to owner 

		emit WithdrawETH(amount);  // trigger event

	}



	function() external payable {

		require(exchangeEnabled);  // when swapTokens was called, use this check to accept or to deny transaction.

	}

}