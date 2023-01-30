/**
 *Submitted for verification at Etherscan.io on 2020-07-27
*/

// File: @openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.5.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
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
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

// File: contracts/PairedInvestments.sol

// "SPDX-License-Identifier: UNLICENSED"
pragma solidity >=0.4.21 <0.7.0;




contract PairedInvestments is Initializable, Ownable {
	using SafeMath for uint256;

    /*
     *  Storage
     */
	address public manager;

	uint256 public traderFeePercent; // trader fee percentage in unit of 100, i.e. 100 == 1% and 5 == 0.05% and 10000 == 100%
    uint256 public investorFeePercent; // investor fee percentage in unit of 100, i.e. 100 == 1% and 5 == 0.05% and 10000 == 100%
    uint256 public investorProfitPercent;

	mapping(uint256 => _Investment) public investments;
    uint256 public investmentCount;

    /*
     *  Structs
     */
    enum InvestmentState {
        Invested,
        Stopped,
        ExitRequestedInvestor,
        ExitRequestedTrader,
        Divested
    }

    struct _Investment {
        uint256 id;
        address trader;
        address investor;
        address token;
        uint256 amount;
        uint256 value;
        uint256 start;
        uint256 end;
        InvestmentState state;
    }

    /*
     *  Modifiers
     */
    modifier onlyManager() {
        require(manager == msg.sender);
        _;
    }

    /// @dev Initialize
    /// @param _traderFeePercent trader fee percentage in unit of 100, i.e. 100 == 1% and 5 == 0.05% and 10000 == 100%
    /// @param _investorFeePercent investor fee percentage
    /// @param _investorProfitPercent investor profit percentage
    function initialize(
	    	uint256 _traderFeePercent, 
	        uint256 _investorFeePercent, 
	        uint256 _investorProfitPercent) 
        public 
        initializer 
    {
    	Ownable.initialize(msg.sender);
    	traderFeePercent = _traderFeePercent;
        investorFeePercent = _investorFeePercent;
        investorProfitPercent = _investorProfitPercent;
    }

    /// @dev Set manager
    /// @param _manager manager address
    function setManager(address _manager) 
        public 
        onlyOwner 
    {
        manager = _manager;
    }

    /// @dev New investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _token token address
    /// @param _amount amount to invest
    /// @return investment id and start date
    function invest(address _traderAddress, address _investorAddress, address _token, uint256 _amount) 
        public 
        onlyManager 
        returns(uint256, uint256) 
    {
        
        uint256 start = now;
        investmentCount = investmentCount.add(1);
        investments[investmentCount] = _Investment({
                id: investmentCount,
                trader: _traderAddress,
                investor: _investorAddress,
                token: _token,
                amount: _amount,
                value: 0,
                start: start,
                end: 0,
                state: InvestmentState.Invested
            });

        return (investmentCount, start);
    }

    /// @dev Stop investment
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @return end date
    function stop(address _traderAddress, address _investorAddress, uint256 _investmentId) 
        public 
        onlyManager 
        returns (uint256)
    {
        uint256 end = now;
        _Investment storage _investment = investments[_investmentId];

        require(_investment.trader == _traderAddress);
        require(_investment.investor == _investorAddress);
        require(_investment.state == InvestmentState.Invested);

        _investment.end = end;
        _investment.state = InvestmentState.Stopped;

        return end;
    }

    /// @dev Investor requests investment exit
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    function requestExitInvestor(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value) 
        public  
    {
        _requestExit(_traderAddress, _investorAddress, _investmentId, _value, InvestmentState.ExitRequestedInvestor);
    }

    /// @dev Trader requests investment exit
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    /// @param _amount transaction amount
    function requestExitTrader(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value, uint256 _amount) 
        public 
    {
        _Investment memory _investment = investments[_investmentId];

        if (_value > _investment.amount) {

            (
                uint256 _traderFee,
                uint256 _investorFee,
                ,
                uint256 _investorProfit
            ) = calculateProfitsAndFees(
                _value, 
                _investment.amount, 
                traderFeePercent, 
                investorFeePercent, 
                investorProfitPercent
            );

            require(_investorProfit.add(_traderFee).add(_investorFee) == _amount);
            
        } else {

            uint256 _traderFee = (_investment.amount.sub(_value)).mul(traderFeePercent).div(10000);

            require(_traderFee == _amount);
        }

        _requestExit(_traderAddress, _investorAddress, _investmentId, _value, InvestmentState.ExitRequestedTrader);
    }

    /// @dev Request investment exit
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _value investment value
    /// @param _state new investment state
    function _requestExit(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _value, InvestmentState _state) 
        internal 
        onlyManager 
    {
        _Investment storage _investment = investments[_investmentId];

        require(_investment.trader == _traderAddress);
        require(_investment.investor == _investorAddress);
        require(_investment.state == InvestmentState.Stopped);

        _investment.value = _value;
        _investment.state = _state;
    }

    /// @dev Approve investment exit
    /// @param _traderAddress trader address
    /// @param _investorAddress investor address
    /// @param _investmentId investment id
    /// @param _amount transaction amount
    /// @return array with: trader payout, investor payout, fee payout, original investment amount
    function approveExit(address _traderAddress, address _investorAddress, uint256 _investmentId, uint256 _amount) 
        public 
        onlyManager 
        returns (uint256[4] memory result) 
    {
        _Investment storage _investment = investments[_investmentId];
        require(_investment.trader == _traderAddress);
        require(_investment.investor == _investorAddress);
        require(_investment.state == InvestmentState.ExitRequestedInvestor || 
                _investment.state == InvestmentState.ExitRequestedTrader);

        uint256 _expected = 0;

        if (_investment.value > _investment.amount) {

        	(
            	uint256 _traderFee,
            	uint256 _investorFee,
            	,
            	uint256 _investorProfit
            ) = calculateProfitsAndFees(
            	_investment.value, 
            	_investment.amount, 
            	traderFeePercent, 
            	investorFeePercent, 
            	investorProfitPercent
            );

            // if the investor requested the exit, the trader will have to pay the amount
            // if the trader requested the exit, they've already paid the amount
            if (_investment.state == InvestmentState.ExitRequestedInvestor) {
                _expected = _investorProfit.add(_traderFee).add(_investorFee);   
            }

            require(_expected == _amount);

            // investment amount plus profit (minus fee)
            result[1] = _investment.amount.add(_investorProfit);

            // pay trader and investor fee
            result[2] = _traderFee.add(_investorFee);
            
            
        } else {

        	uint256 _traderFee = (_investment.amount.sub(_investment.value)).mul(traderFeePercent).div(10000);

            // if the investor requested the exit, the trader will have to pay the amount
            // if the trader requested the exit, they've already paid the amount
            if (_investment.state == InvestmentState.ExitRequestedInvestor) {
        	   _expected =_traderFee;
            }

            require(_expected == _amount);

            // take losses away from investor
            result[1] = _investment.value;
            
            // add losses to trader balance
            result[0] = _investment.amount.sub(_investment.value);
            
            // trader fee
            result[2] = _traderFee;
        }

        _investment.state = InvestmentState.Divested;

        result[3] = _investment.amount;
    }

    /// @dev Reject an exit request
    /// @param _traderAddress trader address
    /// @param _investmentId investment id
    /// @param _value proposed investment value
    function rejectExit(address _traderAddress, uint256 _investmentId, uint256 _value) 
        public 
        onlyManager
    {
        
        _Investment storage _investment = investments[_investmentId];
        require(_investment.trader == _traderAddress);
        require(_investment.state == InvestmentState.ExitRequestedInvestor || 
                _investment.state == InvestmentState.ExitRequestedTrader);
        
        _investment.value = _value;
        _investment.state = InvestmentState.Stopped;
    }


    /// @dev Calculate investment profits and fees
    /// @param _value investment value
    /// @param _amount original investment amount
    /// @param _traderFeePercent trader fee percent
    /// @param _investorFeePercent investor fee percent
    /// @param _investorProfitPercent investor profit percent
    /// @return array with: trader fee, investor fee, trader profit, investor profit
    function calculateProfitsAndFees(
		uint256 _value,
		uint256 _amount,
		uint256 _traderFeePercent,
		uint256 _investorFeePercent,
		uint256 _investorProfitPercent
	) public pure returns (uint256, uint256, uint256, uint256) {
		
        if (_value > _amount) {
    		uint256 _profit = _value - _amount;
            uint256 _investorProfit = _profit.mul(_investorProfitPercent.sub(_investorFeePercent)).div(10000);
            uint256 _traderProfit = _profit.mul(uint256(10000).sub(_investorProfitPercent).sub(_traderFeePercent)).div(10000);
            uint256 _fee = _profit.sub(_investorProfit).sub(_traderProfit);
            uint256 _investorFee = _fee.div(2);
            uint256 _traderFee = _fee.sub(_investorFee);

            return (_traderFee, _investorFee, _traderProfit, _investorProfit);
        }

        uint _traderFee = (_amount.sub(_value)).mul(_traderFeePercent).div(10000);
        return (_traderFee, 0, 0, 0);
	}
}