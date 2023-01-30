/**
 *Submitted for verification at Etherscan.io on 2021-07-09
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    // function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
    //     require(address(this).balance >= value, "Address: insufficient balance for call");
    //     return _functionCallWithValue(target, data, value, errorMessage);
    // }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

  /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.3._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

interface IOwnable {
  function policy() external view returns (address);

  function renounceManagement() external;
  
  function pushManagement( address newOwner_ ) external;
  
  function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function policy() public view override returns (address) {
        return _owner;
    }

    modifier onlyPolicy() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyPolicy() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyPolicy() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }
    
    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}

interface ILendingPool {
    function deposit( address asset, uint256 amount, address onBehalfOf, uint16 referralCode ) external;
    function withdraw( address asset, uint256 amount, address to ) external returns (uint256);
}

interface IStakedTokenIncentivesController {
    function claimRewards( address[] memory assets, uint256 amount, address to ) external;
    function claimRewardsOnBehalf(address[] memory assets, uint256 amount, address user, address to) external;
    function getRewardsBalance(address[] memory assets, address user) external view returns (uint256);
    function getClaimer(address user) external view returns (address);
}

interface ITreasury {
    function deposit( uint _amount, address _token, uint _profit ) external returns ( uint send_ );
    function manage( address _token, uint _amount ) external;
    function valueOf( address _token, uint _amount ) external view returns ( uint value_ );
}

/**
 *  Contract deploys reserves from treasury into the Aave lending pool,
 *  earning interest and $stkAAVE.
 */

contract AaveAllocator is Ownable {

    /* ======== DEPENDENCIES ======== */

    using SafeERC20 for IERC20;
    using SafeMath for uint;



    /* ======== STATE VARIABLES ======== */

    IStakedTokenIncentivesController immutable incentives; // stkAave incentive controller
    ILendingPool immutable lendingPool; // Aave Lending Pool
    ITreasury immutable treasury; // Olympus Treasury

    address[] public aTokens; // all relevant aTokens
    mapping( address => address ) public aTokenRegistry; // corresponding aTokens for tokens

    uint public totalValueDeployed; // total RFV deployed into lending pool
    mapping( address => uint ) public deployedFor; // amount of token deployed into pool
    mapping( address => uint ) public deployLimitFor; // max token can be deployed into pool

    uint public immutable timelockInBlocks; // timelock to raise deployment limit
    mapping( address => uint ) public raiseLimitTimelockEnd; // block when new max can be set
    mapping( address => uint ) public newLimit; // pending new deployment limits for tokens
    
    uint16 public referralCode; // rebates portion of lending pool fees

    // deposit aDAI into treasury or hold in allocator.
    bool public depositToTreasury; // contigent on claimOnBehalfOf permission


    /* ======== CONSTRUCTOR ======== */

    constructor ( 
        address _treasury,
        address _lendingPool, 
        address _incentives,
        uint _timelockInBlocks,
        uint16 _referralCode
    ) {
        require( _treasury != address(0) );
        treasury = ITreasury( _treasury );

        require( _lendingPool != address(0) );
        lendingPool = ILendingPool( _lendingPool );

        require( _incentives != address(0) );
        incentives = IStakedTokenIncentivesController( _incentives );

        timelockInBlocks = _timelockInBlocks;
        referralCode = _referralCode;
    }



    /* ======== OPEN FUNCTIONS ======== */

    /**
     *  @notice claims accrued stkAave rewards for all added aTokens in treasury
     */
    function harvest() public {
        address _treasury = address( treasury );
        if( depositToTreasury ) {
            incentives.claimRewardsOnBehalf( aTokens, rewardsPending( _treasury ), _treasury, _treasury );
        } else {
            incentives.claimRewards( aTokens, rewardsPending( address( this ) ), _treasury );
        }
    }

    /**
     *  @notice claims accrued stkAave rewards for given aTokens in treasury
     *  @param tokens address[] memory
     */
    function harvestFor( address[] calldata tokens ) external {
        address _treasury = address( treasury );
        if( depositToTreasury ) {
            incentives.claimRewardsOnBehalf( tokens, rewardsPending( _treasury ), _treasury, _treasury );
        } else {
            incentives.claimRewards( tokens, rewardsPending( address( this ) ), _treasury );
        }
    }




    /* ======== POLICY FUNCTIONS ======== */

    /**
     *  @notice withdraws asset from treasury, deposits asset into lending pool, then deposits aToken into treasury
     *  @param token address
     *  @param amount uint
     */
    function deposit( address token, uint amount ) public onlyPolicy() {
        require( !exceedsLimit( token, amount ) ); // ensure deposit is within bounds

        treasury.manage( token, amount ); // retrieve amount of asset from treasury

        IERC20( token ).approve( address( lendingPool ), amount ); // approve to deposit into lending pool
        lendingPool.deposit( token, amount, address(this), referralCode ); // deposit, returning aToken

        uint value = treasury.valueOf( token, amount ); // treasury RFV calculator
        accountingFor( token, amount, value, true ); // account for deposit
        
        if ( depositToTreasury ) { // if aTokens are being deposited into treasury
            address aToken = aTokenRegistry[ token ]; // address of aToken
            uint aBalance = IERC20( aToken ).balanceOf( address(this) ); // balance of aToken received

            IERC20( aToken ).approve( address( treasury ), aBalance ); // approve to deposit aToken into treasury
            treasury.deposit( aBalance, aToken, value ); // deposit using value as profit so no OHM is minted
        }
    }

    /**
     *  @notice withdraws aToken from treasury, withdraws from lending pool, and deposits asset into treasury
     *  @param token address
     *  @param amount uint
     */
    function withdraw( address token, uint amount ) public onlyPolicy() {
        address aToken = aTokenRegistry[ token ]; // aToken to withdraw

        if ( depositToTreasury ) { // if aTokens are being deposited into treasury
            treasury.manage( aToken, amount ); // retrieve aToken from treasury
        }

        IERC20( aToken ).approve( address( lendingPool ), amount ); // approve to withdraw from lending pool
        lendingPool.withdraw( aToken, amount, address(this) ); // withdraw from lending pool, returning asset
        
        uint balance = IERC20( token ).balanceOf( address(this) ); // balance of asset received from lending pool
        uint value = ITreasury( treasury ).valueOf( token, balance ); // treasury RFV calculator
        
        accountingFor( token, balance, value, false ); // account for withdrawal

        IERC20( token ).approve( address( treasury ), balance ); // approve to deposit asset into treasury
        treasury.deposit( balance, token, value ); // deposit using value as profit so no OHM is minted
    }

    /**
     *  @notice adds asset and corresponding aToken to mapping
     *  @param token address
     *  @param aToken address
     */
    function addToken( address token, address aToken, uint max ) external onlyPolicy() {
        require( token != address(0) );
        require( aToken != address(0) );
        require( aTokenRegistry[ token ] == address(0) ); // cannot add token twice

        aTokenRegistry[ token ] = aToken;
        aTokens.push( aToken );
        deployLimitFor[ token ] = max;
    }

    /**
     *  @notice lowers max can be deployed for asset (no timelock)
     *  @param token address
     *  @param newMax uint
     */
    function lowerLimit( address token, uint newMax ) external onlyPolicy() {
        require( newMax < deployLimitFor[ token ] );
        require( newMax > deployedFor[ token ] );
        deployLimitFor[ token ] = newMax;
    }
    
    /**
     *  @notice starts timelock to raise max allocation for asset
     *  @param token address
     *  @param newMax uint
     */
    function queueRaiseLimit( address token, uint newMax ) external onlyPolicy() {
        raiseLimitTimelockEnd[ token ] = block.number.add( timelockInBlocks );
        newLimit[ token ] = newMax;
    }

    /**
     *  @notice changes max allocation for asset when timelock elapsed
     *  @param token address
     */
    function raiseLimit( address token ) external onlyPolicy() {
        require( block.number >= raiseLimitTimelockEnd[ token ], "Timelock not expired" );

        deployLimitFor[ token ] = newLimit[ token ];
        newLimit[ token ] = 0;
        raiseLimitTimelockEnd[ token ] = 0;
    }
    
    /**
     *  @notice set referral code for rebate on fees
     *  @param code uint16
     */
    function setReferralCode( uint16 code ) external onlyPolicy() {
        referralCode = code;
    }

    /**
     *  @notice deposit aTokens into treasury and begin claiming rewards on behalf of
     */
    function enableDepositToTreasury() external onlyPolicy() {
        require( incentives.getClaimer( address( treasury ) ) == address(this), "Contract not approved to claim rewards" );
        require( !depositToTreasury, "Already enabled" );

        harvest();

        for ( uint i = 0; i < aTokens.length; i++ ) {
            address aToken = aTokens[i];
            uint balance = IERC20( aToken ).balanceOf( address(this) );
            if ( balance > 0 ) {
                uint value = treasury.valueOf( aToken, balance );
                IERC20( aToken ).approve( address( treasury ), balance ); // approve to deposit asset into treasury
                treasury.deposit( balance, aToken, value ); // deposit using value as profit so no OHM is minted
            }
        }
        depositToTreasury = true;
    }

    /**
     *  @notice revert enabling aToken treasury deposits
     */
    function revertDepositToTreasury() external onlyPolicy() {
        depositToTreasury = false;
    }



    /* ======== INTERNAL FUNCTIONS ======== */

    /**
     *  @notice accounting of deposits/withdrawals of assets
     *  @param token address
     *  @param amount uint
     *  @param value uint
     *  @param add bool
     */
    function accountingFor( address token, uint amount, uint value, bool add ) internal {
        if( add ) {
            deployedFor[ token ] = deployedFor[ token ].add( amount ); // track amount allocated into pool
        
            totalValueDeployed = totalValueDeployed.add( value ); // track total value allocated into pools
            
        } else {
            // track amount allocated into pool
            if ( amount < deployedFor[ token ] ) {
                deployedFor[ token ] = deployedFor[ token ].sub( amount ); 
            } else {
                deployedFor[ token ] = 0;
            }
            
            // track total value allocated into pools
            if ( value < totalValueDeployed ) {
                totalValueDeployed = totalValueDeployed.sub( value );
            } else {
                totalValueDeployed = 0;
            }
        }
    }


    /* ======== VIEW FUNCTIONS ======== */

    /**
     *  @notice query all pending rewards
     *  @return uint
     */
    function rewardsPending( address user ) public view returns ( uint ) {
        return incentives.getRewardsBalance( aTokens, user );
    }

    /**
     *  @notice query pending rewards for provided aTokens
     *  @param tokens address[]
     *  @return uint
     */
    function rewardsPendingFor( address[] calldata tokens, address user ) public view returns ( uint ) {
        return incentives.getRewardsBalance( tokens, user );
    }

    /**
     *  @notice checks to ensure deposit does not exceed max allocation for asset
     *  @param token address
     *  @param amount uint
     */
    function exceedsLimit( address token, uint amount ) public view returns ( bool ) {
        uint alreadyDeployed = deployedFor[ token ];
        uint willBeDeployed = alreadyDeployed.add( amount );

        return ( willBeDeployed > deployLimitFor[ token ] );
    }
}