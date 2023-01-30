/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

//copyright Flisko https://github.com/flisko
//SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/math/Math.sol

pragma solidity ^0.6.12;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

// File: @openzeppelin/contracts/math/SafeMath.sol



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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.6.12;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.6.12;

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
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = _msgSender();
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.12;

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

    function mint(address account, uint256 amount) external;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.12;

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
        // This method relies on extcodesize, which returns 0 for contracts in
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.6.12;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

contract QRXLottery is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256[] denominations = [
        0.1 ether,
        0.2 ether,
        0.3 ether,
        0.4 ether,
        0.5 ether,
        0.6 ether,
        0.7 ether,
        0.8 ether,
        0.9 ether,
        1 ether
    ];

    address[] public weeklyDrawAddress;
    uint256 public periodStart = 0;
    uint256 public periodDelay = 7 days; //
    uint256 public currentPeriod = 1;
    uint256 public qrxFee = 1000 ether;
    address private operator;
    address private immutable collector = 0x4B8d43576aB86Bf008ECFADfeEAF9793B603EC15; // 0x4B8d43576aB86Bf008ECFADfeEAF9793B603EC15    test 
    IERC20 qrx;
    struct User {
        address userAddress;
        uint256 depositedAmount;
    }

    mapping(address => User) public _weeklyDraw1;
    mapping(address => User) public _weeklyDraw2;
    mapping(address => User) public _weeklyDraw3;
    mapping(address => User) public _weeklyDraw4;
    mapping(address => User) public _weeklyDraw5;

    event Deposited(
        address indexed user,
        uint256 amount,
        address indexed referral,
        uint256 period
    );
    event Drawn(uint256 period, address indexed winner, address[] addresses);
    event TransferedReferralReward(address indexed user, uint256 amount);
    event calculatedPoints(User user);

   constructor(address _qrxAddress, uint256 _start, address _operator) public {
        qrx = IERC20(_qrxAddress);
        periodStart = 1605812400; // Thursday, November 19, 2020 8:00:00 PM GMT+01:00
        operator = _operator;
    }
    
   /*  constructor() public {
        periodStart = block.timestamp; //testing
    }*/
    
    modifier onlyOwnerOperator(){
        require(msg.sender == owner() || msg.sender == operator,"Not owner or operator.");
        _;
    }
    
    function setOperatorAddress(address _address) public onlyOwnerOperator{
        operator = _address;
    }
    
    function getWeeklyDrawAddressLength() public view returns (uint256){
        return weeklyDrawAddress.length;
    }
    
    function getWeeklyDrawAddress() public view returns ( address[] memory){
        return weeklyDrawAddress;
    }

    function setQRXfee(uint256 _fee) public onlyOwner {
        require(_fee > 0, "amount is 0");
        qrxFee = _fee;
    }
    
        function withdrawEther() public onlyOwnerOperator{ //drain ether from contract
       msg.sender.transfer(address(this).balance);
    }
    
    function relayEther() internal { //called every time someone deposits
         payable(collector).transfer(address(this).balance);
    }
    
      function drainTokens(address _addy) public onlyOwnerOperator { //drains contract of erc20 tokens
        IERC20 token = IERC20(_addy);
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function deposit(address _referral) public payable { //main deposit function
        require(
            checkDepositValue(msg.value),
            "Deposited value is not an allowed denomination."
        ); //check msg.value if its an allowed denomination

        if (currentPeriod == 1) { //first period
            User storage user = _weeklyDraw1[msg.sender];
            if (
                user.depositedAmount > 1 ether ||
                user.depositedAmount.add(msg.value) > 1 ether
            ) {
                //check if users deposit amount is higher than 1 ether
                revert("Can't deposited more than 1 ether");
            }
            bool exists = false;
            if (user.depositedAmount != 0) { //checks if user already deposited 
                exists = true;
            }
            updateAccount(msg.value, _referral, exists); //updates accounting and send QRX if he referred someone.
            relayEther(); //relays ether to collector address
            emit Deposited(msg.sender,msg.value,_referral,currentPeriod);
        } else if (currentPeriod == 2) {
            User storage user = _weeklyDraw2[msg.sender];
            if (
                user.depositedAmount > 1 ether ||
                user.depositedAmount.add(msg.value) > 1 ether
            ) {
                //check if users deposit amount is higher than 1 ether
                revert("Can't deposited more than 1 ether");
            }
            bool exists = false;
            if (user.depositedAmount != 0) {
                exists = true;
            }
            updateAccount(msg.value, _referral, exists);
             relayEther();
             emit Deposited(msg.sender,msg.value,_referral,currentPeriod);
        } else if (currentPeriod == 3) {
            User storage user = _weeklyDraw3[msg.sender];
            if (
                user.depositedAmount > 1 ether ||
                user.depositedAmount.add(msg.value) > 1 ether
            ) {
                //check if users deposit amount is higher than 1 ether
                revert("Can't deposited more than 1 ether");
            }
            bool exists = false;
            if (user.depositedAmount != 0) {
                exists = true;
            }
            updateAccount(msg.value, _referral, exists);
             relayEther();
             emit Deposited(msg.sender,msg.value,_referral,currentPeriod);
        } else if (currentPeriod == 4) {
            User storage user = _weeklyDraw4[msg.sender];
            if (
                user.depositedAmount > 1 ether ||
                user.depositedAmount.add(msg.value) > 1 ether
            ) {
                //check if users deposit amount is higher than 1 ether
                revert("Can't deposited more than 1 ether");
            }
            bool exists = false;
            if (user.depositedAmount != 0) {
                exists = true;
            }
            updateAccount(msg.value, _referral, exists);
             relayEther();
             emit Deposited(msg.sender,msg.value,_referral,currentPeriod);
        } else if (currentPeriod == 5) {
            User storage user = _weeklyDraw5[msg.sender];
            if (
                user.depositedAmount > 1 ether ||
                user.depositedAmount.add(msg.value) > 1 ether
            ) {
                //check if users deposit amount is higher than 1 ether
                revert("Can't deposited more than 1 ether");
            }
            bool exists = false;
            if (user.depositedAmount != 0) {
                exists = true;
            }
            updateAccount(msg.value, _referral, exists);
             relayEther();
             emit Deposited(msg.sender,msg.value,_referral,currentPeriod);
        } else {
            revert("All periods are over.");
        }
    }

    function kindaRandom() public view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        weeklyDrawAddress
                    )
                )
            );
    }
    
    function returnIndex() public view returns(uint256){ //returns random index
        return kindaRandom() % weeklyDrawAddress.length; //get random index
    }

    function drawWinner() public onlyOwnerOperator returns (address) {
        require(
            block.timestamp > periodStart.add(periodDelay),
            "Cant call yet, 1 week hasnt passed yet"
        );
        uint256 index = kindaRandom() % weeklyDrawAddress.length; //get random index
        address winner = weeklyDrawAddress[index]; //save winner to variable
        emit Drawn(currentPeriod, winner, weeklyDrawAddress); //emit event
        delete weeklyDrawAddress; //empty weekly array
        currentPeriod = currentPeriod.add(1); //increase period
        periodStart = block.timestamp; //set period start
        return winner; //return winners address
    }

    function checkDepositValue(uint256 _value) internal view returns (bool) { //checks if the value is one of the denominations
        for (uint256 i = 0; i < denominations.length; i++) {
            if (_value == denominations[i]) {
                return true;
            }
        }
        return false;
    }

    function updateAccount(
        uint256 _amount,
        address _referral,
        bool _exists
    ) private {
        if (currentPeriod == 1) {
            User storage user = _weeklyDraw1[msg.sender];
            user.depositedAmount = user.depositedAmount.add(_amount);
            user.userAddress = msg.sender;
            if (_referral != address(0)) {
              //  qrx.safeTransfer(msg.sender, qrxFee);
                emit TransferedReferralReward(msg.sender, qrxFee);
                //send 1000QRX
            }
            if (!_exists) {
                weeklyDrawAddress.push(msg.sender);
            }

            emit calculatedPoints(user);
        } else if (currentPeriod == 2) {
            User storage user = _weeklyDraw2[msg.sender];
            user.depositedAmount = user.depositedAmount.add(_amount);
            user.userAddress = msg.sender;
            if (_referral != address(0)) {
               // qrx.safeTransfer(msg.sender, qrxFee);
                emit TransferedReferralReward(msg.sender, qrxFee);
                //send 1000qrx
            }
            if (!_exists) {
                weeklyDrawAddress.push(msg.sender);
            }

            // _weeklyUser2[msg.sender]= _weeklyUser2[msg.sender].add(points);
            emit calculatedPoints(user);
        } else if (currentPeriod == 3) {
            User storage user = _weeklyDraw3[msg.sender];
            user.depositedAmount = user.depositedAmount.add(_amount);
            user.userAddress = msg.sender;
            if (_referral != address(0)) {
               // qrx.safeTransfer(msg.sender, qrxFee);
                emit TransferedReferralReward(msg.sender, qrxFee);
                //send 1000qrx
            }
            if (!_exists) {
                weeklyDrawAddress.push(msg.sender);
            }
            //_weeklyUser3[msg.sender]=_weeklyUser3[msg.sender].add(points);
            emit calculatedPoints(user);
        } else if (currentPeriod == 4) {
            User storage user = _weeklyDraw4[msg.sender];
            user.depositedAmount = user.depositedAmount.add(_amount);
            user.userAddress = msg.sender;
            if (_referral != address(0)) {
               // qrx.safeTransfer(msg.sender, qrxFee);
                emit TransferedReferralReward(msg.sender, qrxFee);
                //send 1000 qrx
            }
            if (!_exists) {
                weeklyDrawAddress.push(msg.sender);
            }
            //  _weeklyUser4[msg.sender]=_weeklyUser4[msg.sender].add(points);
            emit calculatedPoints(user);
        } else if (currentPeriod == 5) {
            User storage user = _weeklyDraw5[msg.sender];
            user.depositedAmount = user.depositedAmount.add(_amount);
            user.userAddress = msg.sender;
            if (_referral != address(0)) {
             //   qrx.safeTransfer(msg.sender, qrxFee);
                emit TransferedReferralReward(msg.sender, qrxFee);
                //send 1000 qrx
            }
            if (!_exists) {
                weeklyDrawAddress.push(msg.sender);
            }
            emit calculatedPoints(user);
        }
    }
}