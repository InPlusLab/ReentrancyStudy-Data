/**
 *Submitted for verification at Etherscan.io on 2020-06-13
*/

pragma solidity ^0.5.0;


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `+` operator.
	 *
	 * Requirements:
	 * - Addition cannot overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 * - Subtraction cannot overflow.
	 *
	 * _Available since v2.4.0._
	 */
	function sub(uint256 a, uint256 b, string memory errorMessage)
		internal
		pure
		returns (uint256)
	{
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `*` operator.
	 *
	 * Requirements:
	 * - Multiplication cannot overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	/**
	 * @dev Returns the integer division of two unsigned integers. Reverts on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	/**
	 * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 *
	 * _Available since v2.4.0._
	 */
	function div(uint256 a, uint256 b, string memory errorMessage)
		internal
		pure
		returns (uint256)
	{
		// Solidity only automatically asserts when dividing by 0
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * Reverts when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * Reverts with custom message when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 * - The divisor cannot be zero.
	 *
	 * _Available since v2.4.0._
	 */
	function mod(uint256 a, uint256 b, string memory errorMessage)
		internal
		pure
		returns (uint256)
	{
		require(b != 0, errorMessage);
		return a % b;
	}
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
	address private _owner;

	event OwnershipTransferred(
		address indexed previousOwner,
		address indexed newOwner
	);

	/**
	 * @dev Initializes the contract setting the deployer as the initial owner.
	 */
	constructor() internal {
		_owner = msg.sender;
		emit OwnershipTransferred(address(0), _owner);
	}

	/**
	 * @dev Returns the address of the current owner.
	 */
	function owner() public view returns (address) {
		return _owner;
	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(isOwner(), "Ownable: caller is not the owner");
		_;
	}

	/**
	 * @dev Returns true if the caller is the current owner.
	 */
	function isOwner() public view returns (bool) {
		return msg.sender == _owner;
	}

	/**
	 * @dev Leaves the contract without owner. It will not be possible to call
	 * `onlyOwner` functions anymore. Can only be called by the current owner.
	 *
	 * NOTE: Renouncing ownership will leave the contract without an owner,
	 * thereby removing any functionality that is only available to the owner.
	 */
	function renounceOwnership() public onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 * Can only be called by the current owner.
	 */
	function transferOwnership(address newOwner) public onlyOwner {
		_transferOwnership(newOwner);
	}

	/**
	 * @dev Transfers ownership of the contract to a new account (`newOwner`).
	 */
	function _transferOwnership(address newOwner) internal {
		require(
			newOwner != address(0),
			"Ownable: new owner is the zero address"
		);
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
	struct Role {
		mapping(address => bool) bearer;
	}

	/**
	 * @dev Give an account access to this role.
	 */
	function add(Role storage _role, address _account) internal {
		require(!has(_role, _account), "Roles: account already has role");
		_role.bearer[_account] = true;
	}

	/**
	 * @dev Remove an account's access to this role.
	 */
	function remove(Role storage _role, address _account) internal {
		require(has(_role, _account), "Roles: account does not have role");
		_role.bearer[_account] = false;
	}

	/**
	 * @dev Check if an account has this role.
	 * @return bool
	 */
	function has(Role storage _role, address _account)
		internal
		view
		returns (bool)
	{
		require(_account != address(0), "Roles: account is the zero address");
		return _role.bearer[_account];
	}
}

contract Operator is Ownable {
	using Roles for Roles.Role;

	Roles.Role private _operators;

	address[] private _operatorsListed;

	mapping(address => uint256) _operatorIndexs;

	event OperatorAdded(address indexed account);
	event OperatorRemoved(address indexed account);

	modifier onlyOperator() {
		require(
			isOperator(msg.sender),
			"caller does not have the Operator role"
		);
		_;
	}

	constructor() public {
		_addOperator(msg.sender);
	}

	function getAllOperators() public view returns(address[] memory operators) {
		operators = new address[](_operatorsListed.length);
		uint256 counter = 0;
		for (uint256 i = 0; i < _operatorsListed.length; i++) {
			if (isOperator(_operatorsListed[i])) {
				operators[counter] = _operatorsListed[i];
				counter++;
			}
		}
	  return operators;
	}

	function isOperator(address _account) public view returns (bool) {
		return _operators.has(_account);
	}

	function addOperator(address _account) public onlyOwner {
		_addOperator(_account);
	}

	function batchAddOperators(address[] memory _accounts) public onlyOwner {
		uint256 arrayLength = _accounts.length;
		for (uint256 i = 0; i < arrayLength; i++) {
			_addOperator(_accounts[i]);
		}
	}

	function removeOperator(address _account) public onlyOwner {
		_removeOperator(_account);
	}

	function batchRemoveOperators(address[] memory _accounts)
		public
		onlyOwner
	{
		uint256 arrayLength = _accounts.length;
		for (uint256 i = 0; i < arrayLength; i++) {
			_removeOperator(_accounts[i]);
		}
	}

	function renounceOperator() public {
		_removeOperator(msg.sender);
	}

	function _addOperator(address _account) internal {
		_operators.add(_account);
		if (_operatorIndexs[_account] == 0) {
		  _operatorsListed.push(_account);
		  _operatorIndexs[_account] = _operatorsListed.length;
		}
		emit OperatorAdded(_account);
	}

	function _removeOperator(address _account) internal {
		_operators.remove(_account);
		emit OperatorRemoved(_account);
	}
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
	/**
	 * @dev Returns the amount of tokens in existence.
	 */
	function totalSupply() external view returns (uint256);

	/**
	 * @dev Returns the amount of tokens owned by `account`.
	 */
	function balanceOf(address account) external view returns (uint256);

	/**
	 * @dev Moves `amount` tokens from the caller's account to `recipient`.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transfer(address recipient, uint256 amount)
		external
		returns (bool);

	/**
	 * @dev Returns the remaining number of tokens that `spender` will be
	 * allowed to spend on behalf of `owner` through {transferFrom}. This is
	 * zero by default.
	 *
	 * This value changes when {approve} or {transferFrom} are called.
	 */
	function allowance(address owner, address spender)
		external
		view
		returns (uint256);

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * IMPORTANT: Beware that changing an allowance with this method brings the risk
	 * that someone may use both the old and the new allowance by unfortunate
	 * transaction ordering. One possible solution to mitigate this race
	 * condition is to first reduce the spender's allowance to 0 and set the
	 * desired value afterwards:
	 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	 *
	 * Emits an {Approval} event.
	 */
	function approve(address spender, uint256 amount) external returns (bool);

	/**
	 * @dev Moves `amount` tokens from `sender` to `recipient` using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transferFrom(address sender, address recipient, uint256 amount)
		external
		returns (bool);

	/**
	 * @dev Emitted when `value` tokens are moved from one account (`from`) to
	 * another (`to`).
	 *
	 * Note that `value` may be zero.
	 */
	event Transfer(address indexed from, address indexed to, uint256 value);

	/**
	 * @dev Emitted when the allowance of a `spender` for an `owner` is set by
	 * a call to {approve}. `value` is the new allowance.
	 */
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conforms
 * the base architecture for crowdsales. It is *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale is Ownable {
	using SafeMath for uint256;

	// The token being sold
	IERC20 private _token;

	// Address where funds are collected
	address payable private _wallet;

	// How many token units a buyer gets per wei.
	// The rate is the conversion between wei and the smallest and indivisible token unit.
	// So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
	// 1 wei will give you 1 unit, or 0.001 TOK.
	uint256 private _rate;

	// Amount of wei raised
	uint256 private _tokenRaised;

	mapping (address => uint256) private _beneficiariesTokenRaised;

	/**
	 * @param rate Number of token units a buyer gets per wei
	 * @dev The rate is the conversion between wei and the smallest and indivisible
	 * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
	 * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
	 * @param wallet Address where collected funds will be forwarded to
	 * @param token Address of the token being sold
	 */
	constructor(uint256 rate, address payable wallet, IERC20 token) public {
		require(rate > 0, "Crowdsale: rate is 0");
		require(wallet != address(0), "Crowdsale: wallet is the zero address");
		require(
			address(token) != address(0),
			"Crowdsale: token is the zero address"
		);

		_rate = rate;
		_wallet = wallet;
		_token = token;
	}

	/**
	 * @return the token being sold.
	 */
	function token() public view returns (IERC20) {
		return _token;
	}

	/**
	 * @return the address where funds are collected.
	 */
	function wallet() public view returns (address payable) {
		return _wallet;
	}

	/**
	 * @return the number of token units a buyer gets per wei.
	 */
	function rate() public view returns (uint256) {
		return _rate;
	}

	/**
	 * @return the amount of token raised.
	 */
	function tokenRaised() public view returns (uint256) {
		return _tokenRaised;
	}

	/**
	 * @return the amount of token raised of beneficiary address
	 */
	function tokenRaisedOfBeneficiary(address beneficiary) public view returns (uint256) {
		return _beneficiariesTokenRaised[beneficiary];
	}

	/**
	 * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
	 * Use `super` in contracts that inherit from Crowdsale to extend their validations.
	 * Example from CappedCrowdsale.sol's _preValidatePurchase method:
	 *     super._preValidatePurchase(beneficiary, tokenAmount);
	 *     require(tokenRaised().add(tokenAmount) <= cap);
	 * @param beneficiary Address performing the token purchase
	 * @param tokenAmount Value in token involved in the purchase
	 */
	function _preValidatePurchase(address beneficiary, uint256 tokenAmount)
		internal
		view
	{
		require(
			beneficiary != address(0),
			"Crowdsale: beneficiary is the zero address"
		);
		require(tokenAmount != 0, "Crowdsale: tokenAmount is 0");
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
	}

	/**
	 * @dev Override for extensions that require an internal state to check for validity (current user contributions,
	 * etc.)
	 * @param beneficiary Address receiving the tokens
	 * @param tokenAmount Value in token involved in the purchase
	 */
	function _updatePurchasingState(address beneficiary, uint256 tokenAmount)
		internal
	{
		// solhint-disable-previous-line no-empty-blocks
		_tokenRaised = _tokenRaised.add(tokenAmount);
		_beneficiariesTokenRaised[beneficiary] = _beneficiariesTokenRaised[beneficiary].add(tokenAmount);
	}

	/**
	 * @dev set exchange rate to new rate
	 */
	function _setRate(uint256 _newRate) internal {
		require(_newRate != 0, "Crowdsale: Rate is 0.");
		_rate = _newRate;
	}
}

/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedCrowdsale is Crowdsale {
	using SafeMath for uint256;

	uint256 private _cap;

	/**
	 * @dev Constructor, takes maximum amount of tokens accepted in the crowdsale.
	 * @param cap Max amount of tokens to be contributed
	 */
	constructor(uint256 cap) public {
		require(cap > 0, "CappedCrowdsale: cap is 0");
		_cap = cap;
	}

	/**
	 * @return the cap of the crowdsale.
	 */
	function cap() public view returns (uint256) {
		return _cap;
	}

	/**
	 * @dev Checks whether the cap has been reached.
	 * @return Whether the cap was reached
	 */
	function capReached() public view returns (bool) {
		return tokenRaised() >= _cap;
	}

	/**
	 * @dev Extend parent behavior requiring purchase to respect the funding cap.
	 * @param beneficiary Token purchaser
	 * @param tokenAmount Amount of token contributed
	 */
	function _preValidatePurchase(address beneficiary, uint256 tokenAmount)
		internal
		view
	{
		super._preValidatePurchase(beneficiary, tokenAmount);
		require(
			tokenRaised().add(tokenAmount) <= _cap,
			"CappedCrowdsale: cap exceeded"
		);
	}
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Ownable {
	/**
	 * @dev Emitted when the pause is triggered by a pauser (`account`).
	 */
	event Paused(address account);

	/**
	 * @dev Emitted when the pause is lifted by a pauser (`account`).
	 */
	event Unpaused(address account);

	bool private _paused;

	/**
	 * @dev Initializes the contract in unpaused state. Assigns the Pauser role
	 * to the deployer.
	 */
	constructor() internal {
		_paused = false;
	}

	/**
	 * @dev Returns true if the contract is paused, and false otherwise.
	 */
	function paused() public view returns (bool) {
		return _paused;
	}

	/**
	 * @dev Modifier to make a function callable only when the contract is not paused.
	 */
	modifier whenNotPaused() {
		require(!_paused, "Pausable: paused");
		_;
	}

	/**
	 * @dev Modifier to make a function callable only when the contract is paused.
	 */
	modifier whenPaused() {
		require(_paused, "Pausable: not paused");
		_;
	}

	/**
	 * @dev Called by a pauser to pause, triggers stopped state.
	 */
	function pause() public onlyOwner whenNotPaused {
		_paused = true;
		emit Paused(msg.sender);
	}

	/**
	 * @dev Called by a pauser to unpause, returns to normal state.
	 */
	function unpause() public onlyOwner whenPaused {
		_paused = false;
		emit Unpaused(msg.sender);
	}
}

/**
 * @title PausableCrowdsale
 * @dev Extension of Crowdsale contract where purchases can be paused and unpaused by the pauser role.
 */
contract PausableCrowdsale is Crowdsale, Pausable {
	/**
	 * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
	 * Use super to concatenate validations.
	 * Adds the validation that the crowdsale must not be paused.
	 * @param _beneficiary Address performing the token purchase
	 * @param _tokenAmount Value in token involved in the purchase
	 */
	function _preValidatePurchase(address _beneficiary, uint256 _tokenAmount)
		internal
		view
		whenNotPaused
	{
		return super._preValidatePurchase(_beneficiary, _tokenAmount);
	}
}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
	using SafeMath for uint256;

	uint256 private _openingTime;
	uint256 private _closingTime;

	/**
	 * Event for crowdsale extending
	 * @param newClosingTime new closing time
	 * @param prevClosingTime old closing time
	 */
	event TimedCrowdsaleExtended(
		uint256 prevClosingTime,
		uint256 newClosingTime
	);

	/**
	 * @dev Reverts if not in crowdsale time range.
	 */
	modifier onlyWhileOpen {
		require(isOpen(), "TimedCrowdsale: not open");
		_;
	}

	/**
	 * @dev Constructor, takes crowdsale opening and closing times.
	 * @param openingTime Crowdsale opening time
	 * @param closingTime Crowdsale closing time
	 */
	constructor(uint256 openingTime, uint256 closingTime) public {
		// solhint-disable-next-line not-rely-on-time
		// require(
		// 	openingTime >= block.timestamp,
		// 	"TimedCrowdsale: opening time is before current time"
		// );
		// solhint-disable-next-line max-line-length
		require(
			closingTime > openingTime,
			"TimedCrowdsale: opening time is not before closing time"
		);

		_openingTime = openingTime;
		_closingTime = closingTime;
	}

	/**
	 * @return the crowdsale opening time.
	 */
	function openingTime() public view returns (uint256) {
		return _openingTime;
	}

	/**
	 * @return the crowdsale closing time.
	 */
	function closingTime() public view returns (uint256) {
		return _closingTime;
	}

	/**
	 * @return true if the crowdsale is open, false otherwise.
	 */
	function isOpen() public view returns (bool) {
		// solhint-disable-next-line not-rely-on-time
		return
			block.timestamp >= _openingTime && block.timestamp <= _closingTime;
	}

	/**
	 * @dev Checks whether the period in which the crowdsale is open has already opened.
	 * @return Whether crowdsale period has opened
	 */
	function hasOpened() public view returns (bool) {
		// solhint-disable-next-line not-rely-on-time
		return block.timestamp >= _openingTime;
	}

	/**
	 * @dev Checks whether the period in which the crowdsale is open has already elapsed.
	 * @return Whether crowdsale period has elapsed
	 */
	function hasClosed() public view returns (bool) {
		// solhint-disable-next-line not-rely-on-time
		return block.timestamp > _closingTime;
	}

	/**
	 * @dev Extend parent behavior requiring to be within contributing period.
	 * @param beneficiary Token purchaser
	 * @param tokenAmount Amount of token contributed
	 */
	function _preValidatePurchase(address beneficiary, uint256 tokenAmount)
		internal
		view
		onlyWhileOpen
	{
		super._preValidatePurchase(beneficiary, tokenAmount);
	}

	/**
	 * @dev reschedule crowdsale opening time.
	 * @param newOpeningTime Crowdsale opening time
	 */
	function _rescheduleOpeningTime(uint256 newOpeningTime) internal {
		require(!hasOpened(), "TimedCrowdsale: already opened");
		require(
			_closingTime > newOpeningTime,
			"TimedCrowdsale: new opening time is after current closing time"
		);
		_openingTime = newOpeningTime;
	}

	/**
	 * @dev Extend crowdsale.
	 * @param newClosingTime Crowdsale closing time
	 */
	function _rescheduleClosingTime(uint256 newClosingTime) internal {
		require(!hasClosed(), "TimedCrowdsale: already closed");
		// solhint-disable-next-line max-line-length
		require(
			newClosingTime > block.timestamp,
			"TimedCrowdsale: new closing time is before current time"
		);
		require(
			newClosingTime > _openingTime,
			"TimedCrowdsale: new closing time is before current closing time"
		);

		emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
		_closingTime = newClosingTime;
	}
}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of TimedCrowdsale with a one-off finalization action, where one
 * can do extra work after finishing.
 */
contract FinalizableCrowdsale is TimedCrowdsale {
	using SafeMath for uint256;

	bool private _finalized;

	event CrowdsaleFinalized();

	constructor() internal {
		_finalized = false;
	}

	/**
	 * @return true if the crowdsale is finalized, false otherwise.
	 */
	function finalized() public view returns (bool) {
		return _finalized;
	}

	/**
	 * @dev Must be called after crowdsale ends, to do some extra finalization
	 * work. Calls the contract's finalization function.
	 */
	function finalize() public {
		require(!_finalized, "FinalizableCrowdsale: already finalized");
		require(hasClosed(), "FinalizableCrowdsale: not closed");

		_finalized = true;

		_finalization();
		emit CrowdsaleFinalized();
	}

	/**
	 * @dev Can be overridden to add finalization logic. The overriding function
	 * should call super._finalization() to ensure the chain of finalization is
	 * executed entirely.
	 */
	function _finalization() internal {
		// solhint-disable-previous-line no-empty-blocks
	}
}

contract AdvanceCrowdsale is Operator, Crowdsale, CappedCrowdsale, TimedCrowdsale, PausableCrowdsale, FinalizableCrowdsale {
	uint256 private _tokenPriceInCents = 100; // default value 1 WDS = 100 (1 cent)

	uint256 private _bonusRate; // no bonus if value = 0

	// using for buyable token by btc
	// How many token units a buyer gets per satoshi.
	// The rate is the conversion between satoshi and the smallest and indivisible token unit.
	// So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
	// 1 satoshi will give you 1 unit, or 0.001 TOK.
	uint256 private _btcRate;

	address private _lockFactoryAddress;

	// satoshi to uint token
	uint256 public constant SATOSHI_CAST_UNIT = 10**10;

	uint256 public constant PRICE_COEFF = 100; // allow to set minimum token price is 0.001 USD

	uint256 public constant BONUS_COEFF = 1000; // Values should be 10x percents, value 1000 = 100%

	modifier onlyLockFactory() {
		require(msg.sender == _lockFactoryAddress, "AdvanceCrowsale: caller is not lock factory.");
		_;
	}

	constructor(uint256 _rate, uint256 _startBtcRate, address payable _wallet, IERC20 _token, uint256 _cap, uint256 _openingTime, uint256 _closingTime, address _lockFactory)
		public
		Crowdsale(_rate, _wallet, _token)
		CappedCrowdsale(_cap)
		TimedCrowdsale(_openingTime, _closingTime)
	{
		require(_startBtcRate != 0, "AdvanceCrowsale: BTC rate is 0.");
		require(_lockFactory != address(0), "AdvanceCrowsale: Lock factory is zero address.");
		_btcRate = _startBtcRate;
		_lockFactoryAddress = _lockFactory;
	}

	/**
	 * @return  number of token units a buyer gets per satoshi.
	 */
	function btcRate() public view returns (uint256) {
		return _btcRate;
	}

	/**
	 * @return the token price in cents
	 */
	function tokenPriceInCents() public view returns (uint256) {
		return _tokenPriceInCents;
	}

	/**
	 * @return the token bonus rate
	 */
	function bonusRate() public view returns (uint256) {
		return _bonusRate;
	}

	/**
	 * setRate set token price in cents, 1 WDS = ? cents
	 * @param _price new token price
	 */
	function setTokenPriceInCents(uint256 _price) public onlyOwner {
		require(_price > 0, "AdvanceCrowsale: price is zero");

		uint256 _oldPrice = _tokenPriceInCents;
		_tokenPriceInCents = _price;

		// update exchange rate in wei
		uint256 _newRate = rate().mul(_oldPrice).div(_tokenPriceInCents);
		super._setRate(_newRate);
		// update exchange rate in satoshi
		_btcRate = _btcRate.mul(_oldPrice).div(_tokenPriceInCents);
	}

	/**
	 * setRateByCents set new exchange rate by ETH/USD and BTC/USD rate
	 * @param _newRatePerCent new eth rate by 1 cent
	 * @param _newBtcRatePerCent new eth rate by 1 cent
	 */
	function setExchangeRateByCents(uint256 _newRatePerCent, uint256 _newBtcRatePerCent) public onlyOperator {
		require(_newRatePerCent > 0, "AdvanceCrowsale: rate is zero");
		require(_newBtcRatePerCent > 0, "AdvanceCrowsale: btc rate is zero");
		uint256 _newRate = _newRatePerCent.mul(PRICE_COEFF).div(_tokenPriceInCents);
		super._setRate(_newRate);
		_btcRate = _newBtcRatePerCent.mul(PRICE_COEFF).div(_tokenPriceInCents);
	}

	/**
	 * setBonusRate set new bonus rate
	 * @param _newBonusRate new bonus rate
	 */
	function setBonusRate(uint256 _newBonusRate) public onlyOwner {
		require(_newBonusRate <= BONUS_COEFF, "AdvanceCrowsale: Bonus exceeds the allowed limit");
		_bonusRate = _newBonusRate;
	}

	/**
	 * setOpeningTime change sale opening time
	 * can reschedule before sale start
	 * @param _openingTime new opening time
	 */
	function setOpeningTime(uint256 _openingTime) public onlyOwner {
		super._rescheduleOpeningTime(_openingTime);
	}

	/**
	 * setClosingTime extend sale closing time
	 * @param _closingTime new closing time
	 */
	function setClosingTime(uint256 _closingTime) public onlyOwner {
		super._rescheduleClosingTime(_closingTime);
	}

	/**
	 * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
	 * Use `super` in contracts that inherit from Crowdsale to extend their validations.
	 * Example from CappedCrowdsale.sol's _preValidatePurchase method:
	 *     super._preValidatePurchase(beneficiary, tokenAmount);
	 *     require(tokenRaised().add(tokenAmount) <= cap);
	 * @param _beneficiary Address performing the token purchase
	 * @param tokenAmount Value in token involved in the purchase
	 */
	function preValidatePurchase(address _beneficiary, uint256 tokenAmount) external view returns (bool) {
		bool success = tokenRaised().add(tokenAmount) <= cap();
		if (!success) {
			return false;
		}
		return true;
	}

	/**
	 * @dev Override for extensions that require an internal state to check for validity (current user contributions,
	 * etc.)
	 * @param beneficiary Address receiving the tokens
	 * @param tokenAmount Value in token involved in the purchase
	 */
	function updatePurchasingState(address beneficiary, uint256 tokenAmount) external onlyLockFactory returns (bool) {
		require(tokenAmount != 0, "AdvanceCrowsale: token amount is 0.");
		super._updatePurchasingState(beneficiary, tokenAmount);
		return true;
	}

	/**
	 * override _getTokenAmount
	 * get total token with bonus rate
	 */
	function estimateTokenAmountInWei(uint256 weiAmount) external view returns (uint256) {
		return weiAmount.mul(_computeEthExchangeRate());
	}

	/**
	 * _computeExchangeRate calculate new exchange rate with bonus tokens
	 * @return new exchange rate
	 */
	function _computeEthExchangeRate() internal view returns (uint256) {
		uint256 _currentRate = rate();
		if (_bonusRate == 0) {
			return _currentRate;
		}
		uint256 _extraRate = _currentRate.mul(_bonusRate).div(BONUS_COEFF);
		return _currentRate.add(_extraRate);
	}

	/**
	 * @dev Override to extend the way in which ether is converted to tokens.
	 * @param satoshiAmount Value in satoshi to be converted into tokens
	 * @return Number of tokens that can be purchased with the specified satoshiAmount
	 */
	function estimateTokenAmountInSatoshi(uint256 satoshiAmount) external view returns (uint256) {
		return satoshiAmount.mul(_computeBtcExchangeRate()).mul(SATOSHI_CAST_UNIT);
	}

	/**
	 * _computeExchangeRate calculate new exchange rate with bonus tokens
	 * @return new exchange rate
	 */
	function _computeBtcExchangeRate() internal view returns (uint256) {
		if (_bonusRate == 0) {
			return _btcRate;
		}
		uint256 _extraRate = _btcRate.mul(_bonusRate).div(BONUS_COEFF);
		return _btcRate.add(_extraRate);
	}
}

contract WindsCoinPresale1 is AdvanceCrowdsale {
	string public constant stage = "PresaleStage1";

	constructor(
		uint256 _rate,
		uint256 _startBtcRate,
		address payable _wallet,
		IERC20 _token,
		uint256 _cap,
		uint256 _openingTime,
		uint256 _closingTime,
		address _lockFactory
	)
		public
		AdvanceCrowdsale(
			_rate,
			_startBtcRate,
			_wallet,
			_token,
			_cap,
			_openingTime,
			_closingTime,
			_lockFactory
		)
	{}
}