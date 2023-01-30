/**
 *Submitted for verification at Etherscan.io on 2019-12-30
*/

// File: contracts/OpenZepplinOwnable.sol

pragma solidity ^0.5.0;

contract Context {
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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/OpenZepplinSafeMath.sol

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

// File: contracts/OpenZepplinIERC20.sol

pragma solidity ^0.5.0;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/OpenZepplinReentrancyGuard.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * _Since v2.5.0:_ this module is now much more gas efficient, given net gas
 * metering changes introduced in the Istanbul hardfork.
 */
contract ReentrancyGuard {
    bool private _notEntered;

    constructor () internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

// File: contracts/PoolsFYI_UniSwapPool_ETH_SAI.sol

pragma solidity ^0.5.0;






// Interface for ETH_SAI_Addliquidity
interface UniSwap_Zap_Contract{
    function LetsInvest() external payable;
}

// Objectives
// - ServiceProvider's users should be able to send ETH to the UniSwap_ZAP contracts and get the UniTokens and the residual ERC20 tokens
// - ServiceProvider should have the ability to charge a commission, should is choose to do so
// - ServiceProvider should be able to provide a commission rate in basis points
// - ServiceProvider WILL receive its commission from the incomimg UniTokens
// - ServiceProvider WILL have to withdraw its commission tokens separately 


contract ServiceProvider_UniSwap_Zap is Ownable, ReentrancyGuard {
    using SafeMath for uint;

    UniSwap_Zap_Contract public UniSwap_Zap_ContractAddress;
    IERC20 public SAI_TokenContractAddress;
    IERC20 public UniSwapSAIExchangeContractAddress;
    
    address internal ServiceProviderAddress;

    uint public balance = address(this).balance;
    uint private TotalServiceChargeTokens;
    uint private serviceChargeInBasisPoints = 0;
    
    event TransferredToUser_liquidityTokens_residualSAI(uint, uint);
    event ServiceChargeTokensTransferred(uint);

    constructor (
        UniSwap_Zap_Contract _UniSwap_Zap_ContractAddress, 
        IERC20 _SAI_TokenContractAddress, 
        IERC20 _UniSwapSAIExchangeContractAddress, 
        address _ServiceProviderAddress) 
        public {
        UniSwap_Zap_ContractAddress = _UniSwap_Zap_ContractAddress;
        SAI_TokenContractAddress = _SAI_TokenContractAddress;
        UniSwapSAIExchangeContractAddress = _UniSwapSAIExchangeContractAddress;
        ServiceProviderAddress = _ServiceProviderAddress;
    }

     // - in relation to the emergency functioning of this contract
    bool private stopped = false;

    // circuit breaker modifiers
    modifier stopInEmergency {if (!stopped) _;}
    
    
    function toggleContractActive() public onlyOwner {
    stopped = !stopped;
    }

    
    // should we ever want to change the address of ZapContractAddress
    function set_UniSwap_Zap_ContractAddress(UniSwap_Zap_Contract _new_UniSwap_Zap_ContractAddress) public onlyOwner  {
        UniSwap_Zap_ContractAddress = _new_UniSwap_Zap_ContractAddress;
    }
  
    // should we ever want to change the address of the SAI_TOKEN_ADDRESS Contract
    function set_SAI_TokenContractAddress (IERC20 _new_SAI_TokenContractAddress) public onlyOwner {
        SAI_TokenContractAddress = _new_SAI_TokenContractAddress;
    }

    // should we ever want to change the address of the _UniSwap SAIExchange Contract Address
    function set_UniSwapSAIExchangeContractAddress (IERC20 _new_UniSwapSAIExchangeContractAddress) public onlyOwner {
        UniSwapSAIExchangeContractAddress = _new_UniSwapSAIExchangeContractAddress;
    }

 
    // to get the ServiceProviderAddress, only the Owner can call this fx
    function get_ServiceProviderAddress() public view onlyOwner returns (address) {
        return ServiceProviderAddress;
    }
    
    // to set the ServiceProviderAddress, only the Owner can call this fx
    function set_ServiceProviderAddress (address _new_ServiceProviderAddress) public onlyOwner  {
        ServiceProviderAddress = _new_ServiceProviderAddress;
    }

    // to find out the serviceChargeRate, only the Owner can call this fx
    function get_serviceChargeRate () public view onlyOwner returns (uint) {
        return serviceChargeInBasisPoints;
    }
    
    // should the ServiceProvider ever want to change the Service Charge rate, only the Owner can call this fx
    function set_serviceChargeRate (uint _new_serviceChargeInBasisPoints) public onlyOwner {
        require (_new_serviceChargeInBasisPoints <= 10000, "Setting Service Charge more than 100%");
        serviceChargeInBasisPoints = _new_serviceChargeInBasisPoints;
    }


    function LetsInvest() public payable stopInEmergency nonReentrant returns (bool) {
        UniSwap_Zap_ContractAddress.LetsInvest.value(msg.value)();
        

        // finding out the UniTokens received and the residual SAI Tokens Received
        uint SAILiquidityTokens = UniSwapSAIExchangeContractAddress.balanceOf(address(this));
        uint residualSAIHoldings = SAI_TokenContractAddress.balanceOf(address(this));

        // Adjusting for ServiceCharge
        uint ServiceChargeTokens = SafeMath.div(SafeMath.mul(SAILiquidityTokens,serviceChargeInBasisPoints),10000);
        TotalServiceChargeTokens = TotalServiceChargeTokens + ServiceChargeTokens;
        

        // Sending Back the Balance LiquityTokens and residual SAI Tokens to user
        uint UserLiquidityTokens = SafeMath.sub(SAILiquidityTokens,ServiceChargeTokens);
        require(UniSwapSAIExchangeContractAddress.transfer(msg.sender, UserLiquidityTokens), "Failure to send Liquidity Tokens to User");
        require(SAI_TokenContractAddress.transfer(msg.sender, residualSAIHoldings), "Failure to send residual SAI holdings");
        emit TransferredToUser_liquidityTokens_residualSAI(UserLiquidityTokens, residualSAIHoldings);
        return true;
    }


    // to find out the totalServiceChargeTokens, only the Owner can call this fx
    function get_TotalServiceChargeTokens() public view onlyOwner returns (uint) {
        return TotalServiceChargeTokens;
    }
    
    
    function withdrawServiceChargeTokens(uint _amountInUnits) public onlyOwner {
        require(_amountInUnits <= TotalServiceChargeTokens, "You are asking for more than what you have earned");
        TotalServiceChargeTokens = SafeMath.sub(TotalServiceChargeTokens,_amountInUnits);
        require(UniSwapSAIExchangeContractAddress.transfer(ServiceProviderAddress, _amountInUnits), "Failure to send ServiceChargeTokens");
        emit ServiceChargeTokensTransferred(_amountInUnits);
    }


    // Should there be a need to withdraw any other ERC20 token
    function withdrawAnyOtherERC20Token(IERC20 _targetContractAddress) public onlyOwner {
        uint OtherTokenBalance = _targetContractAddress.balanceOf(address(this));
        _targetContractAddress.transfer(_owner, OtherTokenBalance);
    }
    

    // incase of half-way error
    function withdrawSAI() public onlyOwner {
        uint StuckSAIHoldings = SAI_TokenContractAddress.balanceOf(address(this));
        SAI_TokenContractAddress.transfer(_owner, StuckSAIHoldings);
    }
    
    function withdrawSAILiquityTokens() public onlyOwner {
        uint StuckSAILiquityTokens = UniSwapSAIExchangeContractAddress.balanceOf(address(this));
        UniSwapSAIExchangeContractAddress.transfer(_owner, StuckSAILiquityTokens);
    }

    
    // fx in relation to ETH held by the contract sent by the owner
    
    // - this function lets you deposit ETH into this wallet
    function depositETH() public payable onlyOwner {
        balance += msg.value;
    }
    
    // - fallback function let you / anyone send ETH to this wallet without the need to call any function
    function() external payable {
        if (msg.sender == _owner) {
            depositETH();
        } else {
            LetsInvest();
        }
    }
    
    // - to withdraw any ETH balance sitting in the contract
    function withdraw() public onlyOwner {
        _owner.transfer(address(this).balance);
    }


}