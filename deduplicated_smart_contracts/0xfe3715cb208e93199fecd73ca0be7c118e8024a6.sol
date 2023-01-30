/**
 *Submitted for verification at Etherscan.io on 2020-10-24
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

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

// File: @openzeppelin/contracts/math/SafeMath.sol



pragma solidity ^0.6.0;

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

// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity ^0.6.2;

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
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
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
}

// File: @openzeppelin/contracts-ethereum-package/contracts/Initializable.sol

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

pragma solidity ^0.6.0;


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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

// File: contracts/v612/ERC95.sol


// COPYRIGHT cVault.finance TEAM
// NO COPY
// COPY = BAD
// This code is provided with no assurances or guarantees of any kind. Use at your own responsibility.

pragma experimental ABIEncoderV2;
// # ERC95 technical documentation 

// tl;dr - ERC95 is a wrap for one or more underlying tokens.
// It can be eg. cYFI or 25% cYFI 10% AMPL 50% X
// This balances are unchangeable.
// Name of this token should be standardised

// cX for X coin
// For partial coins eg.
// 25cX+25cY+50cZ
// Tokens should be able to be multiwrappable, into any derivatives.

// special carveout for LP tokens naming should be
// 50lpX+25lpY+25lpZ


// special carveout for leveraged multiplier tokens
// x25Y+x50Z

// All prefixes are lowercase :

// c for CORE wrap
// x for times ( leverage ) - not clear how this would work right now but its on the goal list
// lp for Liquidity pool token.


// Short term goal for ERC95 is to start few LGEs and lock liquidity in pairs with them
// Long term goal is to pay out everyones fees and let anyone create a pair with CORE with any wrap or derivative they want. And pay out fees on that pair to them, in a permisionless way
// That benefits CORE/LP holders by a part of the fees from those and all other pairs.
// This will be ensured in CoreVault but I outlined it here so the goal of this is clear.

// ## Token wrap token

// A token wrapping standard.
// Recieves token, issues cToken
// eg. YFI -> cYFI
// Unwrapping and wrapping should be fee-less and permissionless the same principles as WETH.

// Note : This might need to be 20 decimals. Because of change of holding multiple tokens under one.
// I'm not sure about support for this everywhere. - will it break websites?





// import "@openzeppelin/contracts/GSN/Context.sol";

contract ERC95 is ContextUpgradeSafe, IERC20 {     // XXXXX Ownable is new
    using SafeMath for uint256;
    using SafeMath for uint8;


    /// XXXXX ERC95 Specific functions




        // Events
        event Wrapped(address indexed from, address indexed to, uint256 amount);
        event Unwrapped(address indexed from, address indexed to, uint256 amount);

        uint8 public _numTokensWrapped;
        WrappedToken[] public _wrappedTokens;

        // Structs
        struct WrappedToken {
            address _address;
            uint256 _reserve;
            uint256 _amountWrapperPerUnit;
        }

        function _setName(string memory name) internal {
            _name = name;
        }

        function __ERC95_init(string memory name, string memory symbol, address[] memory _addresses, uint8[] memory _percent, uint8[] memory tokenDecimals) public initializer {
            ContextUpgradeSafe.__Context_init_unchained();
            // We check if numbers are supplied 1:1
            // And get the total number of them.
            require(_addresses.length == _percent.length, "ERC95 : Mismatch num tokens");
            uint8 decimalsMax;
            uint percentTotal; // To make sure they add up to 100
            uint8 numTokensWrapped = 0;
            for (uint256 loop = 0; loop < _addresses.length; loop++) {
                // 0 % tokens cannnot be permitted
                require(_percent[loop] > 0 ,"ERC95 : All wrapped tokens have to have at least 1% of total");

                // we check the decimals of current token
                // decimals is not part of erc20 standard, and is safer to provide in the caller
                // tokenDecimals[loop] = IERC20(_addresses[loop]).decimals();
                decimalsMax = tokenDecimals[loop] > decimalsMax ? tokenDecimals[loop] : decimalsMax; // pick max
                
                percentTotal += _percent[loop]; // further for checking everything adds up
                //_numTokensWrapped++; // we might just assign this
                numTokensWrapped++;
            }
            
            require(percentTotal == 100, "ERC95 : Percent of all wrapped tokens should equal 100");
            require(numTokensWrapped == _addresses.length, "ERC95 : Length mismatch sanity check fail"); // Is this sanity check needed? // No, but let's leave it anyway in case it becomes needed later
            _numTokensWrapped = numTokensWrapped;

            // Loop over all tokens against to populate the structs
            for (uint256 loop = 0; loop < numTokensWrapped; loop++) {

                // We get the difference between decimals because 6 decimal token should have 1000000000000000000 in 18 decimal token per unit
                uint256 decimalDifference = decimalsMax - tokenDecimals[loop]; // 10 ** 0 is 1 so good
                    // cast to safemath
                uint256 pAmountWrapperPerUnit = numTokensWrapped > 1 ? (10**decimalDifference).mul(_percent[loop]) : 1;
                _wrappedTokens.push(
                    WrappedToken({
                        _address: _addresses[loop],
                        _reserve: 0, /* TODO: I don't know what reserve does here so just stick 0 in it */
                        _amountWrapperPerUnit : pAmountWrapperPerUnit // if its one token then we can have the same decimals
                        /// 10*0 = 1 * 1 = 1
                        /// 10*0 = 1 * 50 = 50 this means half because +2 decimals
                     })
                );
            }

            _name = name;
            _symbol = symbol;                                                    // we dont need more decimals if its 1 token wraped
            _decimals = numTokensWrapped > 1 ? decimalsMax + 2 : decimalsMax; //  2 more decimals to support percentage wraps we support up to 1%-100% in integers
        }                                                      


        // returns info for a token with x id in the loop
        function getTokenInfo(uint _id) public view returns (address, uint256, uint256) {
            WrappedToken memory wt = _wrappedTokens[_id];
            return (wt._address, wt._reserve, wt._amountWrapperPerUnit);
        }

        // Mints the ERC20 during a wrap
        function _mintWrap(address to, uint256 amt) internal {
            _mint(to, amt);
             emit Wrapped(msg.sender, to, amt);
        }

        // burns the erc and sends underlying tokens 
        function _unwrap(address from, address to, uint256 amt) internal {
            _burn(from, amt);
            sendUnderlyingTokens(to, amt);
            emit Unwrapped(from, to, amt);
        }

        /// public function to unwrap
        function unwrap(uint256 amt) public {
            _unwrap(msg.sender, msg.sender, amt);
        }

        function unwrapAll() public {
            unwrap(_balances[msg.sender]);
        }

        // TODO: Unit test with USDT
        // TODO: use the safetransfer shit from uinswap
        // TODO: Account for decimals in transfer amt (EtherDelta and IDEX would have this logic already)
        // TODO: Land-mine testing of USDT
        function sendUnderlyingTokens(address to, uint256 amt) internal {
            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken storage currentToken = _wrappedTokens[loop];
                uint256 amtToSend = amt.mul(currentToken._amountWrapperPerUnit);
                safeTransfer(currentToken._address, to, amtToSend);
                currentToken._reserve = currentToken._reserve.sub(amtToSend);
            }
        }

        function safeTransfer(address token, address to, uint256 value) internal {
            // bytes4(keccak256(bytes('transfer(address,uint256)')));
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'ERC95: TRANSFER_FAILED');
        }

        function safeTransferFrom(address token, address from, address to, uint256 value) internal {
            // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'ERC95: TRANSFER_FROM_FAILED');
        }
        
        // You can unwrap if you have allowance to erc20 wrap
        function unwrapFor(address spender, uint256 amt) public {
            require(_allowances[spender][msg.sender] >= amt, "ERC95 allowance exceded");
            _unwrap(spender, msg.sender, amt);
            _allowances[spender][msg.sender] = _allowances[spender][msg.sender].sub(amt);
        }

        // Loops over all tokens in the wrap and deposits them with allowance
        function _depositUnderlying(uint256 amt) internal {
            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken memory currentToken = _wrappedTokens[loop];
                // req successful transfer
                uint256 amtToSend = amt.mul(currentToken._amountWrapperPerUnit);
                safeTransferFrom(currentToken._address, msg.sender, address(this), amtToSend);
                // Transfer went OK this means we can add this balance we just took.
                _wrappedTokens[loop]._reserve = currentToken._reserve.add(amtToSend);
            }
        }

        // Deposits by checking against reserves
        function wrapAtomic(address to) noNullAddress(to) public {
            uint256 amt = _updateReserves();
            _mintWrap(to, amt);
        }

        // public function to call the deposit with allowance and mint
        function wrap(address to, uint256 amt) noNullAddress(to) public { // works as wrap for
            _depositUnderlying(amt);
            _mintWrap(to, amt); // No need to check underlying?
        }

        // safety for front end bugs
        modifier noNullAddress(address to) {
            require(to != address(0), "ERC95 : null address safety check");
            _;
        }

        
        function _updateReserves() internal returns (uint256 qtyOfNewTokens) {
            // Loop through all tokens wrapped, and find the maximum quantity of wrapped tokens that can be created, given the balance delta for this block
            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken memory currentToken = _wrappedTokens[loop];
                uint256 currentTokenBal = IERC20(currentToken._address).balanceOf(address(this));
                // TODO: update to not use percentages
                uint256 amtCurrent = currentTokenBal.sub(currentToken._reserve).div(currentToken._amountWrapperPerUnit); // math check pls
                qtyOfNewTokens = qtyOfNewTokens > amtCurrent ? amtCurrent : qtyOfNewTokens; // logic check // pick lowest amount so dust attack doesn't work 
                                                           // can't skim in txs or they have non-deterministic gas price
                if(loop == 0) {
                    qtyOfNewTokens = amtCurrent;
                }
            }
            // second loop makes reserve numbers match from computed amount
            for (uint256 loop2 = 0; loop2 < _numTokensWrapped; loop2++) {
                WrappedToken memory currentToken = _wrappedTokens[loop2];

                uint256 amtDelta = qtyOfNewTokens.mul(currentToken._amountWrapperPerUnit);// math check pls
                _wrappedTokens[loop2]._reserve = currentToken._reserve.add(amtDelta);// math check pls
            }   
        }

        // Force to match reserves by transfering out to anyone the excess
        function skim(address to) public {
            for (uint256 loop = 0; loop < _numTokensWrapped; loop++) {
                WrappedToken memory currentToken = _wrappedTokens[loop];
                uint256 currentTokenBal = IERC20(currentToken._address).balanceOf(address(this));
                uint256 excessTokensQuantity = currentTokenBal.sub(currentToken._reserve);
                if(excessTokensQuantity > 0) {
                    safeTransfer(currentToken._address , to, excessTokensQuantity);
                }
            }
        }

    /// END ERC95 SPECIFIC FUNCTIONS START ERC20 
    // we propably should inherit ERC20 somehow

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;



    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }




}

// File: @openzeppelin/contracts-ethereum-package/contracts/access/Ownable.sol

pragma solidity ^0.6.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}

// File: contracts/v612/cBTC.sol

pragma solidity 0.6.12;


interface ICOREGlobals {
    function TransferHandler() external returns (address);
}
interface ICORETransferHandler{
    function handleTransfer(address, address, uint256) external;
}

contract cBTC is OwnableUpgradeSafe, ERC95 {

    bool paused = true; // Once only unpause
    address LGEAddress;
    ICOREGlobals coreGlobals;

    function initialize(address[] memory _addresses, uint8[] memory _percent, uint8[] memory tokenDecimals,  address _coreGlobals) public initializer {
        require(tx.origin == address(0x5A16552f59ea34E44ec81E58b3817833E9fD5436));
        OwnableUpgradeSafe.__Ownable_init();
        ERC95.__ERC95_init("cVault.finance/cBTC", "cBTC", _addresses, _percent, tokenDecimals);
        coreGlobals = ICOREGlobals(_coreGlobals);
    }

    function changeWrapTokenName(string memory name) public onlyOwner {
        _setName(name);
    }

    // Changing it after does nothing, all this can do is unpause once.
    function setLGEAddress(address _LGEAddress) public onlyOwner {
        LGEAddress = _LGEAddress;
    }

    // Unpauses transfers of this once
    // This is needed so people don't wrap before LGE isover and screw liquidity adds
    function unpauseTransfers() public onlyLGEContract {
        paused = false;
    }

    // Checks if contract is LGE address
    modifier onlyLGEContract {
        require(LGEAddress != address(0), "Address not set");
        require(msg.sender == LGEAddress, "Not LGE address");
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal  virtual override {
        require(paused == false, "Transfers paused until LGE is over");
        ICORETransferHandler(coreGlobals.TransferHandler()).handleTransfer(from, to, amount);
    }

}