/**

 *Submitted for verification at Etherscan.io on 2018-12-01

*/



pragma solidity 0.4.23;

contract AbstractToken {

	function balanceOf(address owner) public view returns (uint256 balance);

	function transfer(address to, uint256 value) public returns (bool success);

	function transferFrom(address from, address to, uint256 value) public returns (bool success);

	function approve(address spender, uint256 value) public returns (bool success);

	function allowance(address owner, address spender) public view returns (uint256 remaining);



	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract Owned {



	address public owner = msg.sender;

	address public potentialOwner;



	modifier onlyOwner {

		require(msg.sender == owner);

		_;

	}



	modifier onlyPotentialOwner {

		require(msg.sender == potentialOwner);

		_;

	}



	event NewOwner(address old, address current);

	event NewPotentialOwner(address old, address potential);



	function setOwner(address _new)

		public

		onlyOwner

	{

		emit NewPotentialOwner(owner, _new);

		potentialOwner = _new;

	}



	function confirmOwnership()

		public

		onlyPotentialOwner

	{

		emit NewOwner(owner, potentialOwner);

		owner = potentialOwner;

		potentialOwner = address(0);

	}

}



contract SafeMath {

	/**

	* @dev Multiplies two numbers, throws on overflow.

	*/

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {

		if (a == 0) {

			return 0;

		}

		uint256 c = a * b;

		assert(c / a == b);

		return c;

	}



	/**

	* @dev Integer division of two numbers, truncating the quotient.

	*/

	function div(uint256 a, uint256 b) internal pure returns (uint256) {

		return a / b;

	}



	/**

	* @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

	*/

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {

		assert(b <= a);

		return a - b;

	}



	/**

	* @dev Adds two numbers, throws on overflow.

	*/

	function add(uint256 a, uint256 b) internal pure returns (uint256) {

		uint256 c = a + b;

		assert(c >= a);

		return c;

	}



	/**

	* @dev Raises `a` to the `b`th power, throws on overflow.

	*/

	function pow(uint256 a, uint256 b) internal pure returns (uint256) {

		uint256 c = a ** b;

		assert(c >= a);

		return c;

	}

}



/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20

contract StandardToken is AbstractToken, Owned, SafeMath {



	/*

	 *  Data structures

	 */

	mapping (address => uint256) internal balances;

	mapping (address => mapping (address => uint256)) internal allowed;

	uint256 public totalSupply;



	/*

	 *  Read and write storage functions

	 */

	/// @dev Transfers sender's tokens to a given address. Returns success.

	/// @param _to Address of token receiver.

	/// @param _value Number of tokens to transfer.

	function transfer(address _to, uint256 _value) public returns (bool success) {

		return _transfer(msg.sender, _to, _value);

	}



	/// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.

	/// @param _from Address from where tokens are withdrawn.

	/// @param _to Address to where tokens are sent.

	/// @param _value Number of tokens to transfer.

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

		require(allowed[_from][msg.sender] >= _value);

		allowed[_from][msg.sender] -= _value;



		return _transfer(_from, _to, _value);

	}



	/// @dev Returns number of tokens owned by given address.

	/// @param _owner Address of token owner.

	function balanceOf(address _owner) public view returns (uint256 balance) {

		return balances[_owner];

	}



	/// @dev Sets approved amount of tokens for spender. Returns success.

	/// @param _spender Address of allowed account.

	/// @param _value Number of approved tokens.

	function approve(address _spender, uint256 _value) public returns (bool success) {

		allowed[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);

		return true;

	}



	/*

	 * Read storage functions

	 */

	/// @dev Returns number of allowed tokens for given address.

	/// @param _owner Address of token owner.

	/// @param _spender Address of token spender.

	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

		return allowed[_owner][_spender];

	}



	/**

	* @dev Private transfer, can only be called by this contract.

	* @param _from The address of the sender.

	* @param _to The address of the recipient.

	* @param _value The amount to send.

	* @return success True if the transfer was successful, or throws.

	*/

	function _transfer(address _from, address _to, uint256 _value) private returns (bool success) {

		require(_to != address(0));

		require(balances[_from] >= _value);

		balances[_from] -= _value;

		balances[_to] = add(balances[_to], _value);

		emit Transfer(_from, _to, _value);

		return true;

	}

}



/// @title Token contract - Implements Standard ERC20 with additional features.

contract Token is StandardToken {



	// Time of the contract creation

	uint256 public creationTime;



	function Token() public {

		/* solium-disable-next-line security/no-block-members */

		creationTime = now;

	}



	/// @dev Owner can transfer out any accidentally sent ERC20 tokens

	function transferERC20Token(AbstractToken _token, address _to, uint256 _value)

		public

		onlyOwner

		returns (bool success)

	{

		require(_token.balanceOf(address(this)) >= _value);

		uint256 receiverBalance = _token.balanceOf(_to);

		require(_token.transfer(_to, _value));



		uint256 receiverNewBalance = _token.balanceOf(_to);

		assert(receiverNewBalance == add(receiverBalance, _value));



		return true;

	}



	/// @dev Increases approved amount of tokens for spender. Returns success.

	function increaseApproval(address _spender, uint256 _value) public returns (bool success) {

		allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _value);

		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

		return true;

	}



	/// @dev Decreases approved amount of tokens for spender. Returns success.

	function decreaseApproval(address _spender, uint256 _value) public returns (bool success) {

		uint256 oldValue = allowed[msg.sender][_spender];

		if (_value > oldValue) {

			allowed[msg.sender][_spender] = 0;

		} else {

			allowed[msg.sender][_spender] = sub(oldValue, _value);

		}

		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

		return true;

	}

}



// @title Token contract - Implements Standard ERC20 Token for StartChain project.



contract StartChain is Token {



	/// TOKEN META DATA

	string constant public name = 'StartChain';

	string constant public symbol = 'STC';

	uint8  constant public decimals = 18;





	/// ALOCATIONS

	// To calculate vesting periods we assume that 1 month is always equal to 30 days





	/*** Initial Investors' tokens ***/



	// 6,000,000,000 (60%) tokens are distributed among initial investors

	// These tokens will be distributed without vesting



	address public investorsAllocation = address(0xE871aA22167E4849832c9C2b806143632ad940ba);

	uint256 public investorsTotal = 6000000000e18;





	/*** Overdraft Reserves ***/



	// 20,00,000,000 (20%) tokens will be eventually available for overdraft

	// These tokens will be distributed monthly with a 4 month cliff within a year

	// 666,666,666 tokens will be unlocked every 4 month after the cliff

	// 2 tokens will be unlocked without vesting to ensure that total amount sums up to 2,00,000,000.



	address public overdraftAllocation = address(0x760D4BE51091CC448DF51F79910523245BeE49ac);

	uint256 public overdraftTotal = 2000000000e18;

	uint256 public overdraftPeriodAmount = 666666666e18;

	uint256 public overdraftUnvested = 2e18;

	uint256 public overdraftCliff = 4 * 30 days;

	uint256 public overdraftPeriodLength = 30 days;

	uint8   public overdraftPeriodsNumber = 3;





	/*** Tokens reserved for Founders and Team ***/



	// 1,125,000,000 (11.25%) tokens will be eventually available for the team

	// These tokens will be distributed every 3 month without a cliff within 4 years

	// 7,031,250 tokens will be unlocked every 3 month



	address public teamAllocation  = address(0x61956ff0C6aa8C8082973c77FF52f3AA60f658cC);

	uint256 public teamTotal = 1125000000e18;

	uint256 public teamPeriodAmount = 7031250e18;

	uint256 public teamUnvested = 0;

	uint256 public teamCliff = 0;

	uint256 public teamPeriodLength = 3 * 30 days;

	uint8   public teamPeriodsNumber = 16;







	/*** Tokens reserved for Community Building and Airdrop Campaigns ***/



	// 600,000,000 (6%) tokens will be eventually available for the community

	// 100,000,020 tokens will be available instantly without vesting

	// 499,999,980 tokens will be distributed every 3 month without a cliff within 18 months

	// 83,333,330 tokens will be unlocked every 3 month





	address public communityAllocation  = address(0x229095b414dC136746565C8c29374e0F6AB111C4);

	uint256 public communityTotal = 600000000e18;

	uint256 public communityPeriodAmount = 83333333e18;

	uint256 public communityUnvested = 100000020e18;

	uint256 public communityCliff = 0;

	uint256 public communityPeriodLength = 3 * 30 days;

	uint8   public communityPeriodsNumber = 6;







	/*** Tokens reserved for Advisors, Legal and PR ***/



	// 275,000,000 (2.75%) tokens will be eventually available for advisers

	// 155.000,000 tokens will be available instantly without vesting

	// 120 000 000 tokens will be distributed monthly without a cliff within 6 months

	// 20,000,000 tokens will be unlocked every month



	address public advisersAllocation  = address(0x46bf8A9227AC50Aa321b32AfBA83f90e9AC61ACd);

	uint256 public advisersTotal = 275000000e18;

	uint256 public advisersPeriodAmount = 20000000e18;

	uint256 public advisersUnvested = 155000000e18;

	uint256 public advisersCliff = 0;

	uint256 public advisersPeriodLength = 30 days;

	uint8   public advisersPeriodsNumber = 6;





	/// CONSTRUCTOR



	function StartChain() public {

		//  Overall, 10,000,000,000 tokens exist

		totalSupply = 10000000000e18;



		balances[investorsAllocation] = investorsTotal;

		balances[overdraftAllocation] = overdraftTotal;

		balances[teamAllocation] = teamTotal;

		balances[communityAllocation] = communityTotal;

		balances[advisersAllocation] = advisersTotal;



		// Unlock some tokens without vesting

		allowed[investorsAllocation][msg.sender] = investorsTotal;

		allowed[overdraftAllocation][msg.sender] = overdraftUnvested;

		allowed[communityAllocation][msg.sender] = communityUnvested;

		allowed[advisersAllocation][msg.sender] = advisersUnvested;

	}



	/// DISTRIBUTION



	function distributeInvestorsTokens(address _to, uint256 _amountWithDecimals)

		public

		onlyOwner

	{

		require(transferFrom(investorsAllocation, _to, _amountWithDecimals));

	}



	/// VESTING



	function withdrawOverdraftTokens(address _to, uint256 _amountWithDecimals)

		public

		onlyOwner

	{

		allowed[overdraftAllocation][msg.sender] = allowance(overdraftAllocation, msg.sender);

		require(transferFrom(overdraftAllocation, _to, _amountWithDecimals));

	}



	function withdrawTeamTokens(address _to, uint256 _amountWithDecimals)

		public

		onlyOwner 

	{

		allowed[teamAllocation][msg.sender] = allowance(teamAllocation, msg.sender);

		require(transferFrom(teamAllocation, _to, _amountWithDecimals));

	}



	function withdrawCommunityTokens(address _to, uint256 _amountWithDecimals)

		public

		onlyOwner 

	{

		allowed[communityAllocation][msg.sender] = allowance(communityAllocation, msg.sender);

		require(transferFrom(communityAllocation, _to, _amountWithDecimals));

	}



	function withdrawAdvisersTokens(address _to, uint256 _amountWithDecimals)

		public

		onlyOwner 

	{

		allowed[advisersAllocation][msg.sender] = allowance(advisersAllocation, msg.sender);

		require(transferFrom(advisersAllocation, _to, _amountWithDecimals));

	}



	/// @dev Overrides StandardToken.sol function

	function allowance(address _owner, address _spender)

		public

		view

		returns (uint256 remaining)

	{   

		if (_spender != owner) {

			return allowed[_owner][_spender];

		}



		uint256 unlockedTokens;

		uint256 spentTokens;



		if (_owner == overdraftAllocation) {

			unlockedTokens = _calculateUnlockedTokens(

				overdraftCliff,

				overdraftPeriodLength,

				overdraftPeriodAmount,

				overdraftPeriodsNumber,

				overdraftUnvested

			);

			spentTokens = sub(overdraftTotal, balanceOf(overdraftAllocation));

		} else if (_owner == teamAllocation) {

			unlockedTokens = _calculateUnlockedTokens(

				teamCliff,

				teamPeriodLength,

				teamPeriodAmount,

				teamPeriodsNumber,

				teamUnvested

			);

			spentTokens = sub(teamTotal, balanceOf(teamAllocation));

		} else if (_owner == communityAllocation) {

			unlockedTokens = _calculateUnlockedTokens(

				communityCliff,

				communityPeriodLength,

				communityPeriodAmount,

				communityPeriodsNumber,

				communityUnvested

			);

			spentTokens = sub(communityTotal, balanceOf(communityAllocation));

		} else if (_owner == advisersAllocation) {

			unlockedTokens = _calculateUnlockedTokens(

				advisersCliff,

				advisersPeriodLength,

				advisersPeriodAmount,

				advisersPeriodsNumber,

				advisersUnvested

			);

			spentTokens = sub(advisersTotal, balanceOf(advisersAllocation));

		} else {

			return allowed[_owner][_spender];

		}



		return sub(unlockedTokens, spentTokens);

	}



	/// @dev Overrides Owned.sol function

	function confirmOwnership()

		public

		onlyPotentialOwner

	{   

		// Forbid the old owner to distribute investors' tokens

		allowed[investorsAllocation][owner] = 0;



		// Allow the new owner to distribute investors' tokens

		allowed[investorsAllocation][msg.sender] = balanceOf(investorsAllocation);



		// Forbid the old owner to withdraw any tokens from the reserves

		allowed[overdraftAllocation][owner] = 0;

		allowed[teamAllocation][owner] = 0;

		allowed[communityAllocation][owner] = 0;

		allowed[advisersAllocation][owner] = 0;



		super.confirmOwnership();

	}



	function _calculateUnlockedTokens(

		uint256 _cliff,

		uint256 _periodLength,

		uint256 _periodAmount,

		uint8 _periodsNumber,

		uint256 _unvestedAmount

	)

		private

		view

		returns (uint256) 

	{

		/* solium-disable-next-line security/no-block-members */

		if (now < add(creationTime, _cliff)) {

			return _unvestedAmount;

		}

		/* solium-disable-next-line security/no-block-members */

		uint256 periods = div(sub(now, add(creationTime, _cliff)), _periodLength);

		periods = periods > _periodsNumber ? _periodsNumber : periods;

		return add(_unvestedAmount, mul(periods, _periodAmount));

	}

}