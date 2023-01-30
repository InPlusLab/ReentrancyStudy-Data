/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// File: @openzeppelin/contracts/math/SafeMath.sol

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.5.5;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol

pragma solidity ^0.5.0;




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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: contracts/protocol/interfaces/InterestRateInterface.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

interface InterestRateInterface {

    /**
      * @dev Returns the current interest rate for the given DMMA and corresponding total supply & active supply
      *
      * @param dmmTokenId The DMMA whose interest should be retrieved
      * @param totalSupply The total supply fot he DMM token
      * @param activeSupply The supply that's currently being lent by users
      * @return The interest rate in APY, which is a number with 18 decimals
      */
    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint);

}

// File: contracts/protocol/interfaces/IUnderlyingTokenValuator.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

interface IUnderlyingTokenValuator {

    /**
      * @dev Gets the tokens value in terms of USD.
      *
      * @return The value of the `amount` of `token`, as a number with the same number of decimals as `amount` passed
      *         in to this function.
      */
    function getTokenValue(address token, uint amount) external view returns (uint);

}

// File: @openzeppelin/contracts/GSN/Context.sol

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

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/utils/Blacklistable.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;


/**
 * @dev Allows accounts to be blacklisted by the owner of the contract.
 *
 *  Taken from USDC's contract for blacklisting certain addresses from owning and interacting with the token.
 */
contract Blacklistable is Ownable {

    string public constant BLACKLISTED = "BLACKLISTED";

    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    /**
     * @dev Throws if called by any account other than the creator of this contract
    */
    modifier onlyBlacklister() {
        require(msg.sender == owner(), "MUST_BE_BLACKLISTER");
        _;
    }

    /**
     * @dev Throws if `account` is blacklisted
     *
     * @param account The address to check
    */
    modifier notBlacklisted(address account) {
        require(blacklisted[account] == false, BLACKLISTED);
        _;
    }

    /**
     * @dev Checks if `account` is blacklisted. Reverts with `BLACKLISTED` if blacklisted.
    */
    function checkNotBlacklisted(address account) public view {
        require(!blacklisted[account], BLACKLISTED);
    }

    /**
     * @dev Checks if `account` is blacklisted
     *
     * @param account The address to check
    */
    function isBlacklisted(address account) public view returns (bool) {
        return blacklisted[account];
    }

    /**
     * @dev Adds `account` to blacklist
     *
     * @param account The address to blacklist
    */
    function blacklist(address account) public onlyBlacklister {
        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @dev Removes account from blacklist
     *
     * @param account The address to remove from the blacklist
    */
    function unBlacklist(address account) public onlyBlacklister {
        blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

}

// File: contracts/protocol/interfaces/IDmmController.sol

pragma solidity ^0.5.0;




interface IDmmController {

    event TotalSupplyIncreased(uint oldTotalSupply, uint newTotalSupply);
    event TotalSupplyDecreased(uint oldTotalSupply, uint newTotalSupply);

    event AdminDeposit(address indexed sender, uint amount);
    event AdminWithdraw(address indexed receiver, uint amount);

    /**
     * @dev Creates a new mToken using the provided data.
     *
     * @param underlyingToken   The token that should be wrapped to create a new DMMA
     * @param symbol            The symbol of the new DMMA, IE mDAI or mUSDC
     * @param name              The name of this token, IE `DMM: DAI`
     * @param decimals          The number of decimals of the underlying token, and therefore the number for this DMMA
     * @param minMintAmount     The minimum amount that can be minted for any given transaction.
     * @param minRedeemAmount   The minimum amount that can be redeemed any given transaction.
     * @param totalSupply       The initial total supply for this market.
     */
    function addMarket(
        address underlyingToken,
        string calldata symbol,
        string calldata name,
        uint8 decimals,
        uint minMintAmount,
        uint minRedeemAmount,
        uint totalSupply
    ) external;

    /**
     * @dev Creates a new mToken using the already-existing token.
     *
     * @param dmmToken          The token that should be added to this controller.
     * @param underlyingToken   The token that should be wrapped to create a new DMMA.
     */
    function addMarketFromExistingDmmToken(
        address dmmToken,
        address underlyingToken
    ) external;

    /**
     * @param newController The new controller who should receive ownership of the provided DMM token IDs.
     */
    function transferOwnershipToNewController(
        address newController
    ) external;

    /**
     * @dev Enables the corresponding DMMA to allow minting new tokens.
     *
     * @param dmmTokenId  The DMMA that should be enabled.
     */
    function enableMarket(uint dmmTokenId) external;

    /**
     * @dev Disables the corresponding DMMA from minting new tokens. This allows the market to close over time, since
     *      users are only able to redeem tokens.
     *
     * @param dmmTokenId  The DMMA that should be disabled.
     */
    function disableMarket(uint dmmTokenId) external;

    /**
     * @dev Sets the new address that will serve as the guardian for this controller.
     *
     * @param newGuardian   The new address that will serve as the guardian for this controller.
     */
    function setGuardian(address newGuardian) external;

    /**
     * @dev Sets a new contract that implements the `DmmTokenFactory` interface.
     *
     * @param newDmmTokenFactory  The new contract that implements the `DmmTokenFactory` interface.
     */
    function setDmmTokenFactory(address newDmmTokenFactory) external;

    /**
     * @dev Sets a new contract that implements the `DmmEtherFactory` interface.
     *
     * @param newDmmEtherFactory  The new contract that implements the `DmmEtherFactory` interface.
     */
    function setDmmEtherFactory(address newDmmEtherFactory) external;

    /**
     * @dev Sets a new contract that implements the `InterestRate` interface.
     *
     * @param newInterestRateInterface  The new contract that implements the `InterestRateInterface` interface.
     */
    function setInterestRateInterface(address newInterestRateInterface) external;

    /**
     * @dev Sets a new contract that implements the `IOffChainAssetValuator` interface.
     *
     * @param newOffChainAssetValuator The new contract that implements the `IOffChainAssetValuator` interface.
     */
    function setOffChainAssetValuator(address newOffChainAssetValuator) external;

    /**
     * @dev Sets a new contract that implements the `IOffChainAssetValuator` interface.
     *
     * @param newOffChainCurrencyValuator The new contract that implements the `IOffChainAssetValuator` interface.
     */
    function setOffChainCurrencyValuator(address newOffChainCurrencyValuator) external;

    /**
     * @dev Sets a new contract that implements the `UnderlyingTokenValuator` interface
     *
     * @param newUnderlyingTokenValuator The new contract that implements the `UnderlyingTokenValuator` interface
     */
    function setUnderlyingTokenValuator(address newUnderlyingTokenValuator) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to withdraw funds from a DMMA. These withdrawn funds are then
     *      allocated to real-world assets that will be used to pay interest into the DMMA.
     *
     * @param newMinCollateralization   The new min collateralization (with 18 decimals) at which the DMME must be in
     *                                  order to add to the total supply of DMM.
     */
    function setMinCollateralization(uint newMinCollateralization) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to withdraw funds from a DMMA. These withdrawn funds are then
     *      allocated to real-world assets that will be used to pay interest into the DMMA.
     *
     * @param newMinReserveRatio   The new ratio (with 18 decimals) that is used to enforce a certain percentage of assets
     *                          are kept in each DMMA.
     */
    function setMinReserveRatio(uint newMinReserveRatio) external;

    /**
     * @dev Increases the max supply for the provided `dmmTokenId` by `amount`. This call reverts with
     *      INSUFFICIENT_COLLATERAL if there isn't enough collateral in the Chainlink contract to cover the controller's
     *      requirements for minimum collateral.
     */
    function increaseTotalSupply(uint dmmTokenId, uint amount) external;

    /**
     * @dev Increases the max supply for the provided `dmmTokenId` by `amount`.
     */
    function decreaseTotalSupply(uint dmmTokenId, uint amount) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to withdraw funds from a DMMA. These withdrawn funds are then
     *      allocated to real-world assets that will be used to pay interest into the DMMA.
     *
     * @param dmmTokenId        The ID of the DMM token whose underlying will be funded.
     * @param underlyingAmount  The amount underlying the DMM token that will be deposited into the DMMA.
     */
    function adminWithdrawFunds(uint dmmTokenId, uint underlyingAmount) external;

    /**
     * @dev Allows the owners of the DMM Ecosystem to deposit funds into a DMMA. These funds are used to disburse
     *      interest payments and add more liquidity to the specific market.
     *
     * @param dmmTokenId        The ID of the DMM token whose underlying will be funded.
     * @param underlyingAmount  The amount underlying the DMM token that will be deposited into the DMMA.
     */
    function adminDepositFunds(uint dmmTokenId, uint underlyingAmount) external;

    /**
     * @return  All of the DMM token IDs that are currently in the ecosystem. NOTE: this is an unfiltered list.
     */
    function getDmmTokenIds() external view returns (uint[] memory);

    /**
     * @dev Gets the collateralization of the system assuming 1-year's worth of interest payments are due by dividing
     *      the total value of all the collateralized assets plus the value of the underlying tokens in each DMMA by the
     *      aggregate interest owed (plus the principal), assuming each DMMA was at maximum usage.
     *
     * @return  The 1-year collateralization of the system, as a number with 18 decimals. For example
     *          `1010000000000000000` is 101% or 1.01.
     */
    function getTotalCollateralization() external view returns (uint);

    /**
     * @dev Gets the current collateralization of the system assuming by dividing the total value of all the
     *      collateralized assets plus the value of the underlying tokens in each DMMA by the aggregate interest owed
     *      (plus the principal), using the current usage of each DMMA.
     *
     * @return  The active collateralization of the system, as a number with 18 decimals. For example
     *          `1010000000000000000` is 101% or 1.01.
     */
    function getActiveCollateralization() external view returns (uint);

    /**
     * @dev Gets the interest rate from the underlying token, IE DAI or USDC.
     *
     * @return  The current interest rate, represented using 18 decimals. Meaning `65000000000000000` is 6.5% APY or
     *          0.065.
     */
    function getInterestRateByUnderlyingTokenAddress(address underlyingToken) external view returns (uint);

    /**
     * @dev Gets the interest rate from the DMM token, IE DMM: DAI or DMM: USDC.
     *
     * @return  The current interest rate, represented using 18 decimals. Meaning, `65000000000000000` is 6.5% APY or
     *          0.065.
     */
    function getInterestRateByDmmTokenId(uint dmmTokenId) external view returns (uint);

    /**
     * @dev Gets the interest rate from the DMM token, IE DMM: DAI or DMM: USDC.
     *
     * @return  The current interest rate, represented using 18 decimals. Meaning, `65000000000000000` is 6.5% APY or
     *          0.065.
     */
    function getInterestRateByDmmTokenAddress(address dmmToken) external view returns (uint);

    /**
     * @dev Gets the exchange rate from the underlying to the DMM token, such that
     *      `DMM: Token = underlying / exchangeRate`
     *
     * @return  The current exchange rate, represented using 18 decimals. Meaning, `200000000000000000` is 0.2.
     */
    function getExchangeRateByUnderlying(address underlyingToken) external view returns (uint);

    /**
     * @dev Gets the exchange rate from the underlying to the DMM token, such that
     *      `DMM: Token = underlying / exchangeRate`
     *
     * @return  The current exchange rate, represented using 18 decimals. Meaning, `200000000000000000` is 0.2.
     */
    function getExchangeRate(address dmmToken) external view returns (uint);

    /**
     * @dev Gets the DMM token for the provided underlying token. For example, sending DAI returns DMM: DAI.
     */
    function getDmmTokenForUnderlying(address underlyingToken) external view returns (address);

    /**
     * @dev Gets the underlying token for the provided DMM token. For example, sending DMM: DAI returns DAI.
     */
    function getUnderlyingTokenForDmm(address dmmToken) external view returns (address);

    /**
     * @return True if the market is enabled for this DMMA or false if it is not enabled.
     */
    function isMarketEnabledByDmmTokenId(uint dmmTokenId) external view returns (bool);

    /**
     * @return True if the market is enabled for this DMM token (IE DMM: DAI) or false if it is not enabled.
     */
    function isMarketEnabledByDmmTokenAddress(address dmmToken) external view returns (bool);

    /**
     * @return True if the market is enabled for this underlying token (IE DAI) or false if it is not enabled.
     */
    function getTokenIdFromDmmTokenAddress(address dmmTokenAddress) external view returns (uint);

    /**
     * @dev Gets the DMM token contract address for the provided DMM token ID. For example, `1` returns the mToken
     *      contract address for that token ID.
     */
    function getDmmTokenAddressByDmmTokenId(uint dmmTokenId) external view returns (address);

    function blacklistable() external view returns (Blacklistable);

    function underlyingTokenValuator() external view returns (IUnderlyingTokenValuator);

}

// File: contracts/utils/IERC20WithDecimals.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;

interface IERC20WithDecimals {

    function decimals() external view returns (uint8);

}

// File: contracts/external/asset_introducers/interfaces/IERC721TokenReceiver.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity ^0.5.0;

interface IERC721TokenReceiver {

    /**
     * @notice  Handles the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient after a `transfer`. This function MAY throw
     *      to revert and reject the transfer. Return of other than the magic value MUST result in the transaction
     *      being reverted. Note: the contract address is always the message sender.
     *
     * @param _operator The address which called `safeTransferFrom` function
     * @param _from     The address which previously owned the token
     * @param _tokenId  The NFT identifier which is being transferred
     * @param _data     Additional data with no specified format
     * @return          `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))` unless a reversion
     *                  occurs.
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);

}

// File: contracts/external/asset_introducers/interfaces/IERC721.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity >=0.5.0;

/**
 * @dev ERC-721 non-fungible token standard. See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */
interface IERC721 {

    /**
     * @dev Emits when ownership of any NFT changes by any mechanism. This event emits when NFTs are
     * created (`from` == 0) and destroyed (`to` == 0). Exception: during contract creation, any
     * number of NFTs may be created and assigned without emitting Transfer. At the time of any
     * transfer, the approved address for that NFT (if any) is reset to none.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev This emits when the approved address for an NFT is changed or reaffirmed. The zero
     * address indicates there is no approved address. When a Transfer event emits, this also
     * indicates that the approved address for that NFT (if any) is reset to none.
     */
    event Approval(
        address indexed owner,
        address indexed operator,
        uint256 indexed tokenId
    );

    /**
     * @dev This emits when an operator is enabled or disabled for an owner. The operator can manage
     * all NFTs of the owner.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Transfers the ownership of an NFT from one address to another address.
     * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
     * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
     * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
     * function checks if `_to` is a smart contract (code size > 0). If so, it calls
     * `onERC721Received` on `_to` and throws if the return value is not
     * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     * @param _data Additional data with no specified format, sent in call to `_to`.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
    external;

    /**
     * @dev Transfers the ownership of an NFT from one address to another address.
     * @notice This works identically to the other function with an extra data parameter, except this
     * function just sets data to ""
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external;

    /**
     * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
     * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
     * address. Throws if `_tokenId` is not a valid NFT.
     * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
     * they mayb be permanently lost.
     * @param _from The current owner of the NFT.
     * @param _to The new owner.
     * @param _tokenId The NFT to transfer.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external;

    /**
     * @dev Set or reaffirm the approved address for an NFT.
     * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
     * the current NFT owner, or an authorized operator of the current owner.
     * @param _approved The new approved NFT controller.
     * @param _tokenId The NFT to approve.
     */
    function approve(
        address _approved,
        uint256 _tokenId
    )
    external;

    /**
     * @dev Enables or disables approval for a third party ("operator") to manage all of
     * `msg.sender`'s assets. It also emits the ApprovalForAll event.
     * @notice The contract MUST allow multiple operators per owner.
     * @param _operator Address to add to the set of authorized operators.
     * @param _approved True if the operators is approved, false to revoke approval.
     */
    function setApprovalForAll(
        address _operator,
        bool _approved
    )
    external;

    /**
     * @dev Returns the number of NFTs owned by `_owner`. NFTs assigned to the zero address are
     * considered invalid, and this function throws for queries about the zero address.
     * @param _owner Address for whom to query the balance.
     * @return Balance of _owner.
     */
    function balanceOf(
        address _owner
    )
    external
    view
    returns (uint256);

    /**
     * @dev Returns the address of the owner of the NFT. NFTs assigned to zero address are considered
     * invalid, and queries about them do throw.
     * @param _tokenId The identifier for an NFT.
     * @return Address of _tokenId owner.
     */
    function ownerOf(
        uint256 _tokenId
    )
    external
    view
    returns (address);

    /**
     * @dev Get the approved address for a single NFT.
     * @notice Throws if `_tokenId` is not a valid NFT.
     * @param _tokenId The NFT to find the approved address for.
     * @return Address that _tokenId is approved for.
     */
    function getApproved(
        uint256 _tokenId
    )
    external
    view
    returns (address);

    /**
     * @dev Returns true if `_operator` is an approved operator for `_owner`, false otherwise.
     * @param _owner The address that owns the NFTs.
     * @param _operator The address that acts on behalf of the owner.
     * @return True if approved for all, false otherwise.
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
    external
    view
    returns (bool);

}

// File: contracts/external/asset_introducers/v1/IAssetIntroducerStakingV1Initializable.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface IAssetIntroducerStakingV1Initializable {

    function initialize(
        address owner,
        address guardian,
        address assetIntroducerProxy,
        address dmgIncentivesPool
    ) external;

    function initializeOwnables(
        address owner,
        address guardian
    ) external;

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

// File: contracts/protocol/interfaces/IOwnableOrGuardian.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;


/**
 * NOTE:    THE STATE VARIABLES IN THIS CONTRACT CANNOT CHANGE NAME OR POSITION BECAUSE THIS CONTRACT IS USED IN
 *          UPGRADEABLE CONTRACTS.
 */
contract IOwnableOrGuardian is Initializable {

    // *************************
    // ***** Events
    // *************************

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GuardianTransferred(address indexed previousGuardian, address indexed newGuardian);

    // *************************
    // ***** Modifiers
    // *************************

    modifier onlyOwnerOrGuardian {
        require(
            msg.sender == _owner || msg.sender == _guardian,
            "OwnableOrGuardian: UNAUTHORIZED_OWNER_OR_GUARDIAN"
        );
        _;
    }

    modifier onlyOwner {
        require(
            msg.sender == _owner,
            "OwnableOrGuardian: UNAUTHORIZED"
        );
        _;
    }
    // *********************************************
    // ***** State Variables DO NOT CHANGE OR MOVE
    // *********************************************

    // ******************************
    // ***** DO NOT CHANGE OR MOVE
    // ******************************
    address internal _owner;
    address internal _guardian;
    // ******************************
    // ***** DO NOT CHANGE OR MOVE
    // ******************************

    // ******************************
    // ***** Misc Functions
    // ******************************

    function owner() external view returns (address) {
        return _owner;
    }

    function guardian() external view returns (address) {
        return _guardian;
    }

    // ******************************
    // ***** Admin Functions
    // ******************************

    function initialize(
        address __owner,
        address __guardian
    )
    public
    initializer {
        _transferOwnership(__owner);
        _transferGuardian(__guardian);
    }

    function transferOwnership(
        address __owner
    )
    public
    onlyOwner {
        require(
            __owner != address(0),
            "OwnableOrGuardian::transferOwnership: INVALID_OWNER"
        );
        _transferOwnership(__owner);
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    function transferGuardian(
        address __guardian
    )
    public
    onlyOwner {
        require(
            __guardian != address(0),
            "OwnableOrGuardian::transferGuardian: INVALID_OWNER"
        );
        _transferGuardian(__guardian);
    }

    function renounceGuardian() public onlyOwnerOrGuardian {
        _transferGuardian(address(0));
    }

    // ******************************
    // ***** Internal Functions
    // ******************************

    function _transferOwnership(
        address __owner
    )
    internal {
        address previousOwner = _owner;
        _owner = __owner;
        emit OwnershipTransferred(previousOwner, __owner);
    }

    function _transferGuardian(
        address __guardian
    )
    internal {
        address previousGuardian = _guardian;
        _guardian = __guardian;
        emit GuardianTransferred(previousGuardian, __guardian);
    }

}

// File: contracts/governance/dmg/IDMGToken.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.13;

interface IDMGToken {

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    // *************************
    // ***** Functions
    // *************************

    function getPriorVotes(address account, uint blockNumber) external view returns (uint128);

    function getCurrentVotes(address account) external view returns (uint128);

    function delegates(address delegator) external view returns (address);

    function burn(uint amount) external returns (bool);

    function approveBySig(
        address spender,
        uint rawAmount,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

// File: contracts/external/asset_introducers/AssetIntroducerData.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;




contract AssetIntroducerData is Initializable, IOwnableOrGuardian {

    // *************************
    // ***** Constants
    // *************************

    // *************************
    // ***** V1 State Variables
    // *************************

    /// For preventing reentrancy attacks
    uint64 internal _guardCounter;

    AssetIntroducerStateV1 internal _assetIntroducerStateV1;

    ERC721StateV1 internal _erc721StateV1;

    VoteStateV1 internal _voteStateV1;

    // *************************
    // ***** Data Structures
    // *************************

    enum AssetIntroducerType {
        PRINCIPAL, AFFILIATE
    }

    struct AssetIntroducerStateV1 {
        /// The timestamp at which this contract was initialized
        uint64 initTimestamp;

        /// True if the DMM Foundation purchased its token for the bootstrapped pool, false otherwise.
        bool isDmmFoundationSetup;

        /// Total amount of DMG locked in this contract
        uint128 totalDmgLocked;

        /// For calculating the results of off-chain signature requests
        bytes32 domainSeparator;

        /// Address of the DMG token
        address dmg;

        /// Address of the DMM Controller
        address dmmController;

        /// Address of the DMM token valuator, which gets the USD value of a token
        address underlyingTokenValuator;

        /// Address of the implementation for the discount
        address assetIntroducerDiscount;

        /// Address of the implementation for the staking purchaser contract. Used to buy NFTs at a steep discount by
        /// staking mTokens.
        address stakingPurchaser;

        /// Mapping from NFT ID to the asset introducer struct.
        mapping(uint => AssetIntroducer) idToAssetIntroducer;

        /// Mapping from country code to asset introducer type to token IDs
        mapping(bytes3 => mapping(uint8 => uint[])) countryCodeToAssetIntroducerTypeToTokenIdsMap;

        /// A mapping from the country code to asset introducer type to the cost needed to buy one. The cost is represented
        /// in USD (with 18 decimals) and is purchased using DMG, so a conversion is needed using Chainlink.
        mapping(bytes3 => mapping(uint8 => uint96)) countryCodeToAssetIntroducerTypeToPriceUsd;

        /// The dollar amount that has actually been deployed by the asset introducer
        mapping(uint => mapping(address => uint)) tokenIdToUnderlyingTokenToWithdrawnAmount;

        /// Mapping for the count of each user's off-chain signed messages. 0-indexed.
        mapping(address => uint) ownerToNonceMap;
    }

    struct ERC721StateV1 {
        /// Total number of NFTs created
        uint64 totalSupply;

        /// The proxy address created by OpenSea, which is used to enable a smoother trading experience
        address openSeaProxyRegistry;

        /// The last token ID in the linked list.
        uint lastTokenId;

        /// The base URI for getting NFT information by token ID.
        string baseURI;

        /// Mapping of all token IDs. Works as a linked list such that previous key --> next value. The 0th key in the
        /// list is LINKED_LIST_GUARD.
        mapping(uint => uint) allTokens;

        /// Mapping from NFT ID to owner address.
        mapping(uint256 => address) idToOwnerMap;

        /// Mapping from NFT ID to approved address.
        mapping(uint256 => address) idToSpenderMap;

        /// Mapping from owner to an operator that can spend all of owner's NFTs.
        mapping(address => mapping(address => bool)) ownerToOperatorToIsApprovedMap;

        /// Mapping from owner address to all owned token IDs. Works as a linked list such that previous key --> next value.
        /// The 0th key in the list is LINKED_LIST_GUARD.
        mapping(address => mapping(uint => uint)) ownerToTokenIds;

        /// Mapping from owner address to a count of all owned NFTs.
        mapping(address => uint32) ownerToTokenCount;

        /// Mapping from an interface to whether or not it's supported.
        mapping(bytes4 => bool) interfaceIdToIsSupportedMap;
    }

    /// Used for storing information about voting
    struct VoteStateV1 {
        /// Taken from the DMG token implementation
        mapping(address => mapping(uint64 => Checkpoint)) ownerToCheckpointIndexToCheckpointMap;
        /// Taken from the DMG token implementation
        mapping(address => uint64) ownerToCheckpointCountMap;
    }

    /// Tightly-packed, this data structure is 2 slots; 64 bytes
    struct AssetIntroducer {
        bytes3 countryCode;
        AssetIntroducerType introducerType;
        /// True if the asset introducer has been purchased yet, false if it hasn't and is thus
        bool isOnSecondaryMarket;
        /// True if the asset introducer can withdraw tokens from mToken deposits, false if it cannot yet. This value
        /// must only be changed to `true` via governance vote
        bool isAllowedToWithdrawFunds;
        /// 1-based index at which the asset introducer was created. Used for optics
        uint16 serialNumber;
        uint96 dmgLocked;
        /// How much this asset introducer can manage
        uint96 dollarAmountToManage;
        uint tokenId;
    }

    /// Used for tracking delegation and number of votes each user has at a given block height.
    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    /// Used to prevent the "stack too deep" error and make code more readable
    struct DmgApprovalStruct {
        address spender;
        uint rawAmount;
        uint nonce;
        uint expiry;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct DiscountStruct {
        uint64 initTimestamp;
    }

    // *************************
    // ***** Modifiers
    // *************************

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;

        _;

        require(
            localCounter == _guardCounter,
            "AssetIntroducerData: REENTRANCY"
        );
    }

    /// Enforces that an NFT has NOT been sold to a user yet
    modifier requireIsPrimaryMarketNft(uint __tokenId) {
        require(
            !_assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_SECONDARY_MARKET"
        );

        _;
    }

    /// Enforces that an NFT has been sold to a user
    modifier requireIsSecondaryMarketNft(uint __tokenId) {
        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_PRIMARY_MARKET"
        );

        _;
    }

    modifier requireIsValidNft(uint __tokenId) {
        require(
            _erc721StateV1.idToOwnerMap[__tokenId] != address(0),
            "AssetIntroducerData: INVALID_NFT"
        );

        _;
    }

    modifier requireIsNftOwner(uint __tokenId) {
        require(
            _erc721StateV1.idToOwnerMap[__tokenId] == msg.sender,
            "AssetIntroducerData: INVALID_NFT_OWNER"
        );

        _;
    }

    modifier requireCanWithdrawFunds(uint __tokenId) {
        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isAllowedToWithdrawFunds,
            "AssetIntroducerData: NFT_NOT_ACTIVATED"
        );

        _;
    }

    modifier requireIsStakingPurchaser() {
        require(
            _assetIntroducerStateV1.stakingPurchaser != address(0),
            "AssetIntroducerData: STAKING_PURCHASER_NOT_SETUP"
        );

        require(
            _assetIntroducerStateV1.stakingPurchaser == msg.sender,
            "AssetIntroducerData: INVALID_SENDER_FOR_STAKING"
        );
        _;
    }

}

// File: contracts/external/asset_introducers/v1/IAssetIntroducerV1.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;


interface IAssetIntroducerV1 {

    // *************************
    // ***** Events
    // *************************

    event AssetIntroducerBought(uint indexed tokenId, address indexed buyer, address indexed recipient, uint dmgAmount);
    event AssetIntroducerActivationChanged(uint indexed tokenId, bool isActivated);
    event AssetIntroducerCreated(uint indexed tokenId, string countryCode, AssetIntroducerData.AssetIntroducerType introducerType, uint serialNumber);
    event AssetIntroducerDiscountChanged(address indexed oldAssetIntroducerDiscount, address indexed newAssetIntroducerDiscount);
    event AssetIntroducerDollarAmountToManageChange(uint indexed tokenId, uint oldDollarAmountToManage, uint newDollarAmountToManage);
    event AssetIntroducerPriceChanged(string indexed countryCode, AssetIntroducerData.AssetIntroducerType indexed introducerType, uint oldPriceUsd, uint newPriceUsd);
    event BaseURIChanged(string newBaseURI);
    event CapitalDeposited(uint indexed tokenId, address indexed token, uint amount);
    event CapitalWithdrawn(uint indexed tokenId, address indexed token, uint amount);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    event InterestPaid(uint indexed tokenId, address indexed token, uint amount);
    event SignatureValidated(address indexed signer, uint nonce);
    event StakingPurchaserChanged(address indexed oldStakingPurchaser, address indexed newStakingPurchaser);

    // *************************
    // ***** Admin Functions
    // *************************

    function createAssetIntroducersForPrimaryMarket(
        string[] calldata countryCode,
        AssetIntroducerData.AssetIntroducerType[] calldata introducerType
    ) external returns (uint[] memory);

    function setDollarAmountToManageByTokenId(
        uint tokenId,
        uint dollarAmountToManage
    ) external;

    function setDollarAmountToManageByCountryCodeAndIntroducerType(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType,
        uint dollarAmountToManage
    ) external;

    function setAssetIntroducerDiscount(
        address assetIntroducerDiscount
    ) external;

    function setAssetIntroducerPrice(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType,
        uint priceUsd
    ) external;

    function activateAssetIntroducerByTokenId(
        uint tokenId
    ) external;

    function setStakingPurchaser(
        address stakingPurchaser
    ) external;

    // *************************
    // ***** Misc Functions
    // *************************

    /**
     * @return  The timestamp at which this contract was created
     */
    function initTimestamp() external view returns (uint64);

    function stakingPurchaser() external view returns (address);

    function openSeaProxyRegistry() external view returns (address);

    /**
     * @return  The domain separator used in off-chain signatures. See EIP 712 for more:
     *          https://eips.ethereum.org/EIPS/eip-712
     */
    function domainSeparator() external view returns (bytes32);

    /**
     * @return  The address of the DMG token
     */
    function dmg() external view returns (address);

    function dmmController() external view returns (address);

    function underlyingTokenValuator() external view returns (address);

    function assetIntroducerDiscount() external view returns (address);

    /**
     * @return  The discount applied to the price of the asset introducer for being an early purchaser. Represented as
     *          a number with 18 decimals, such that 0.1 * 1e18 == 10%
     */
    function getAssetIntroducerDiscount() external view returns (uint);

    /**
     * @return  The price of the asset introducer, represented in USD
     */
    function getAssetIntroducerPriceUsdByTokenId(
        uint tokenId
    ) external view returns (uint);

    /**
     * @return  The price of the asset introducer, represented in DMG. DMG is the needed currency to purchase an asset
     *          introducer NFT.
     */
    function getAssetIntroducerPriceDmgByTokenId(
        uint tokenId
    ) external view returns (uint);

    function getAssetIntroducerPriceUsdByCountryCodeAndIntroducerType(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType
    )
    external view returns (uint);

    function getAssetIntroducerPriceDmgByCountryCodeAndIntroducerType(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType
    )
    external view returns (uint);

    /**
     * @return  The total amount of DMG locked in the asset introducer reserves
     */
    function getTotalDmgLocked() external view returns (uint);

    /**
     * @return  The amount that this asset introducer can manager, represented in wei format (a number with 18
     *          decimals). Meaning, 10,000.25 * 1e18 == $10,000.25
     */
    function getDollarAmountToManageByTokenId(
        uint tokenId
    ) external view returns (uint);

    /**
     * @return  The amount of DMG that this asset introducer has locked in order to maintain a valid status as an asset
     *          introducer.
     */
    function getDmgLockedByTokenId(
        uint tokenId
    ) external view returns (uint);

    function getAssetIntroducerByTokenId(
        uint tokenId
    ) external view returns (AssetIntroducerData.AssetIntroducer memory);

    function getAssetIntroducersByCountryCode(
        string calldata countryCode
    ) external view returns (AssetIntroducerData.AssetIntroducer[] memory);

    function getAllAssetIntroducers() external view returns (AssetIntroducerData.AssetIntroducer[] memory);

    function getPrimaryMarketAssetIntroducers() external view returns (AssetIntroducerData.AssetIntroducer[] memory);

    function getSecondaryMarketAssetIntroducers() external view returns (AssetIntroducerData.AssetIntroducer[] memory);

    // *************************
    // ***** User Functions
    // *************************

    function getNonceByUser(
        address user
    ) external view returns (uint);

    function getNextAssetIntroducerTokenId(
        string calldata __countryCode,
        AssetIntroducerData.AssetIntroducerType __introducerType
    ) external view returns (uint);

    /**
     * Buys the slot for the appropriate amount of DMG, by attempting to transfer the DMG from `msg.sender` to this
     * contract
     */
    function buyAssetIntroducerSlot(
        uint tokenId
    ) external returns (bool);

    /**
     * Buys the slot for the appropriate amount of DMG, by attempting to transfer the DMG from `msg.sender` to this
     * contract. The additional discount is added to the existing one
     */
    function buyAssetIntroducerSlotViaStaking(
        uint tokenId,
        uint additionalDiscount
    ) external returns (bool);

    function nonceOf(
        address user
    ) external view returns (uint);

    function buyAssetIntroducerSlotBySig(
        uint tokenId,
        address recipient,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);

    function buyAssetIntroducerSlotBySigWithDmgPermit(
        uint __tokenId,
        address __recipient,
        uint __nonce,
        uint __expiry,
        uint8 __v,
        bytes32 __r,
        bytes32 __s,
        AssetIntroducerData.DmgApprovalStruct calldata dmgApprovalStruct
    ) external returns (bool);

    function getPriorVotes(
        address user,
        uint blockNumber
    ) external view returns (uint128);

    function getCurrentVotes(
        address user
    ) external view returns (uint);

    function getDmgLockedByUser(
        address user
    ) external view returns (uint);

    /**
     * @return  The amount of capital that has been withdrawn by this asset introducer, denominated in USD with 18
     *          decimals
     */
    function getDeployedCapitalUsdByTokenId(
        uint tokenId
    ) external view returns (uint);

    function getWithdrawnAmountByTokenIdAndUnderlyingToken(
        uint tokenId,
        address underlyingToken
    ) external view returns (uint);

    /**
     * @dev Deactivates the specified asset introducer from being able to withdraw funds. Doing so enables it to
     *      be transferred. NOTE: NFTs can only be deactivated once all deployed capital is returned.
     */
    function deactivateAssetIntroducerByTokenId(
        uint tokenId
    ) external;

    function withdrawCapitalByTokenIdAndToken(
        uint tokenId,
        address token,
        uint amount
    ) external;

    function depositCapitalByTokenIdAndToken(
        uint tokenId,
        address token,
        uint amount
    ) external;

    function payInterestByTokenIdAndToken(
        uint tokenId,
        address token,
        uint amount
    ) external;

    // *************************
    // ***** Other Functions
    // *************************

    /**
     * @dev Used by the DMMF to buy its token and initialize it based upon its usage of the protocol prior to the NFT
     *      system having been created. We are passing through the USDC token specifically, because it was drawn down
     *      by 300,000 early in the system's maturity to run a full cycle of the system and do a small allocation to
     *      the bootstrapped asset pool.
     */
    function buyDmmFoundationToken(
        uint tokenId,
        address usdcToken
    ) external returns (bool);

    function isDmmFoundationSetup() external view returns (bool);

}

// File: contracts/external/asset_introducers/AssetIntroducerStakingData.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;



contract AssetIntroducerStakingData is IOwnableOrGuardian {

    /// For preventing reentrancy attacks
    uint64 internal _guardCounter;

    address internal _assetIntroducerProxy;
    address internal _dmgIncentivesPool;
    mapping(address => UserStake[]) internal _userToStakesMap;
    bool internal _isOwnableInitialized;

    enum StakingDuration {
        TWELVE_MONTHS, EIGHTEEN_MONTHS
    }

    struct UserStake {
        bool isWithdrawn;
        uint64 unlockTimestamp;
        address mToken;
        uint amount;
        uint tokenId;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;

        _;

        require(
            localCounter == _guardCounter,
            "AssetIntroducerData: REENTRANCY"
        );
    }


}

// File: contracts/external/asset_introducers/v1/IAssetIntroducerStakingV1.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;



interface IAssetIntroducerStakingV1 {

    // *************************
    // ***** Events
    // *************************

    event UserBeginStaking(address indexed user, uint indexed tokenId, address dmmToken, uint amount, uint unlockTimestamp);
    event UserEndStaking(address indexed user, uint indexed tokenId, address dmmToken, uint amount);
    event IncentiveDmgUsed(uint indexed tokenId, address indexed buyer, uint amount);

    // *************************
    // ***** Misc Functions
    // *************************

    function assetIntroducerProxy() external view returns (address);

    function dmg() external view returns (address);

    function dmgIncentivesPool() external view returns (address);

    function isReady() external view returns (bool);

    /// The total discount received by the user by staking their mTokens.
    function getTotalDiscountByStakingDuration(
        AssetIntroducerStakingData.StakingDuration duration
    ) external view returns (uint);

    /// Returns the DMG price and the additional discount to be forwarded to the asset introducer proxy
    function getAssetIntroducerPriceDmgByTokenIdAndStakingDuration(
        uint tokenId,
        AssetIntroducerStakingData.StakingDuration duration
    ) external view returns (uint, uint);

    // *************************
    // ***** User Functions
    // *************************

    function buyAssetIntroducerSlot(
        uint tokenId,
        uint dmmTokenId,
        AssetIntroducerStakingData.StakingDuration duration
    ) external returns (bool);

    function withdrawStake() external;

    function getUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory);

    function getActiveUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory);

    function balanceOf(
        address user,
        address mToken
    ) external view returns (uint);

    function getStakeAmountByTokenIdAndDmmTokenId(
        uint tokenId,
        uint dmmTokenId
    ) external view returns (uint);

    function getStakeAmountByCountryCodeAndIntroducerTypeAndDmmTokenId(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType,
        uint dmmTokenId
    ) external view returns (uint);

    function mapDurationEnumToSeconds(
        AssetIntroducerStakingData.StakingDuration duration
    ) external pure returns (uint64);

}

// File: contracts/external/asset_introducers/v1/AssetIntroducerStakingV1.sol

/*
 * Copyright 2020 DMM Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


pragma solidity ^0.5.0;











contract AssetIntroducerStakingV1 is IAssetIntroducerStakingV1Initializable, IAssetIntroducerStakingV1, IERC721TokenReceiver, AssetIntroducerStakingData {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    uint constant internal ONE_ETH = 1 ether;

    function initialize(
        address __owner,
        address __guardian,
        address __assetIntroducerProxy,
        address __dmgIncentivesPool
    ) public initializer {
        IOwnableOrGuardian.initialize(__owner, __guardian);
        _assetIntroducerProxy = __assetIntroducerProxy;
        _dmgIncentivesPool = __dmgIncentivesPool;
        _guardCounter = 1;
    }

    function initializeOwnables(
        address __owner,
        address __guardian
    ) external {
        require(
            !_isOwnableInitialized,
            "AssetIntroducerStakingV1::initializeOwnables: ALREADY_INITIALIZED"
        );
        _transferOwnership(__owner);
        _transferGuardian(__guardian);
    }

    function assetIntroducerProxy() external view returns (address) {
        return _assetIntroducerProxy;
    }

    function dmg() public view returns (address) {
        return IAssetIntroducerV1(_assetIntroducerProxy).dmg();
    }

    function dmgIncentivesPool() external view returns (address) {
        return _dmgIncentivesPool;
    }

    function buyAssetIntroducerSlot(
        uint __tokenId,
        uint __dmmTokenId,
        StakingDuration __duration
    )
    external
    nonReentrant
    returns (bool) {
        IAssetIntroducerV1 __assetIntroducerProxy = IAssetIntroducerV1(_assetIntroducerProxy);
        (uint fullPriceDmg, uint additionalDiscount) = getAssetIntroducerPriceDmgByTokenIdAndStakingDuration(__tokenId, __duration);
        uint userPriceDmg = fullPriceDmg / 2;

        address __dmg = dmg();
        address __dmgIncentivesPool = _dmgIncentivesPool;

        require(
            IERC20(__dmg).balanceOf(__dmgIncentivesPool) >= fullPriceDmg.sub(userPriceDmg),
            "AssetIntroducerBuyerRouter::buyAssetIntroducerSlot: INSUFFICIENT_INCENTIVES"
        );
        IERC20(__dmg).safeTransferFrom(__dmgIncentivesPool, address(this), fullPriceDmg.sub(userPriceDmg));
        IERC20(__dmg).safeTransferFrom(msg.sender, address(this), userPriceDmg);

        _performStakingForToken(__tokenId, __dmmTokenId, __duration, __assetIntroducerProxy);

        IERC20(__dmg).safeApprove(address(__assetIntroducerProxy), fullPriceDmg);
        __assetIntroducerProxy.buyAssetIntroducerSlotViaStaking(__tokenId, additionalDiscount);

        // Forward the NFT to the purchaser
        IERC721(address(__assetIntroducerProxy)).safeTransferFrom(address(this), msg.sender, __tokenId);

        emit IncentiveDmgUsed(__tokenId, msg.sender, fullPriceDmg.sub(userPriceDmg));

        return true;
    }

    function withdrawStake() external nonReentrant {
        UserStake[] memory userStakes = _userToStakesMap[msg.sender];
        for (uint i = 0; i < userStakes.length; i++) {
            if (!userStakes[i].isWithdrawn && block.timestamp > userStakes[i].unlockTimestamp) {
                _userToStakesMap[msg.sender][i].isWithdrawn = true;
                IERC20(userStakes[i].mToken).safeTransfer(msg.sender, userStakes[i].amount);
                emit UserEndStaking(msg.sender, userStakes[i].tokenId, userStakes[i].mToken, userStakes[i].amount);
            }
        }
    }

    function getUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory) {
        return _userToStakesMap[user];
    }

    function getActiveUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory) {
        AssetIntroducerStakingData.UserStake[] memory allStakes = _userToStakesMap[user];

        uint count = 0;
        for (uint i = 0; i < allStakes.length; i++) {
            if (!allStakes[i].isWithdrawn) {
                count += 1;
            }
        }

        AssetIntroducerStakingData.UserStake[] memory activeStakes = new AssetIntroducerStakingData.UserStake[](count);
        count = 0;
        for (uint i = 0; i < allStakes.length; i++) {
            if (!allStakes[i].isWithdrawn) {
                activeStakes[count++] = allStakes[i];
            }
        }
        return activeStakes;
    }

    function balanceOf(
        address user,
        address mToken
    ) external view returns (uint) {
        uint balance = 0;
        AssetIntroducerStakingData.UserStake[] memory allStakes = _userToStakesMap[user];
        for (uint i = 0; i < allStakes.length; i++) {
            if (!allStakes[i].isWithdrawn && allStakes[i].mToken == mToken) {
                balance += allStakes[i].amount;
            }
        }
        return balance;
    }

    function getStakeAmountByTokenIdAndDmmTokenId(
        uint __tokenId,
        uint __dmmTokenId
    ) public view returns (uint) {
        uint priceUsd = IAssetIntroducerV1(_assetIntroducerProxy).getAssetIntroducerPriceUsdByTokenId(__tokenId);
        return _getStakeAmountByDmmTokenId(__dmmTokenId, priceUsd);
    }

    function getStakeAmountByCountryCodeAndIntroducerTypeAndDmmTokenId(
        string calldata __countryCode,
        AssetIntroducerData.AssetIntroducerType __introducerType,
        uint __dmmTokenId
    ) external view returns (uint) {
        uint priceUsd = IAssetIntroducerV1(_assetIntroducerProxy).getAssetIntroducerPriceUsdByCountryCodeAndIntroducerType(__countryCode, __introducerType);
        return _getStakeAmountByDmmTokenId(__dmmTokenId, priceUsd);
    }

    function mapDurationEnumToSeconds(
        StakingDuration __duration
    ) public pure returns (uint64) {
        if (__duration == StakingDuration.TWELVE_MONTHS) {
            return 86400 * 30 * 12;
        } else if (__duration == StakingDuration.EIGHTEEN_MONTHS) {
            return 86400 * 30 * 18;
        } else {
            revert("AssetIntroducerStakingV1::mapDurationEnumToSeconds: INVALID_DURATION");
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function isReady() public view returns (bool) {
        return IERC20(dmg()).allowance(_dmgIncentivesPool, address(this)) > 0 &&
        IAssetIntroducerV1(_assetIntroducerProxy).stakingPurchaser() == address(this);
    }

    function getAssetIntroducerPriceDmgByTokenIdAndStakingDuration(
        uint __tokenId,
        StakingDuration __duration
    ) public view returns (uint, uint) {
        IAssetIntroducerV1 __assetIntroducerProxy = IAssetIntroducerV1(_assetIntroducerProxy);
        uint nonStakingDiscount = __assetIntroducerProxy.getAssetIntroducerDiscount();
        uint totalDiscount = getTotalDiscountByStakingDuration(__duration);
        uint additionalDiscount = totalDiscount.sub(nonStakingDiscount);

        uint fullPriceDmg = __assetIntroducerProxy.getAssetIntroducerPriceDmgByTokenId(__tokenId);
        uint originalPriceDmg = fullPriceDmg.mul(ONE_ETH).div(ONE_ETH.sub(nonStakingDiscount));

        return (originalPriceDmg.mul(ONE_ETH.sub(totalDiscount)).div(ONE_ETH), additionalDiscount);
    }

    function getTotalDiscountByStakingDuration(
        StakingDuration duration
    ) public view returns (uint) {
        uint baseDiscount;
        uint originalDiscount;
        // The discount expired
        if (duration == StakingDuration.TWELVE_MONTHS) {
            // Discount is 95% at t=0 and decays to 25% at t=18_months; delta of 70%
            originalDiscount = 0.7 ether;
            baseDiscount = 0.25 ether;
        } else if (duration == StakingDuration.EIGHTEEN_MONTHS) {
            // Discount is 99% at t=0 and decays to 50% at t=18_months; delta of 49%
            originalDiscount = 0.49 ether;
            baseDiscount = 0.50 ether;
        } else {
            revert("AssetIntroducerStakingV1::getTotalDiscountByStakingDuration: INVALID_DURATION");
        }

        uint elapsedTime = block.timestamp.sub(IAssetIntroducerV1(_assetIntroducerProxy).initTimestamp());
        // 18 months or 540 days
        uint discountDurationInSeconds = 86400 * 30 * 18;
        if (elapsedTime > discountDurationInSeconds) {
            return baseDiscount;
        } else {
            return (originalDiscount.mul(discountDurationInSeconds.sub(elapsedTime)).div(discountDurationInSeconds)).add(baseDiscount);
        }
    }

    // *************************
    // ***** Internal Functions
    // *************************

    function _performStakingForToken(
        uint __tokenId,
        uint __dmmTokenId,
        StakingDuration __duration,
        IAssetIntroducerV1 __assetIntroducerProxy
    ) internal {
        uint stakeAmount = getStakeAmountByTokenIdAndDmmTokenId(__tokenId, __dmmTokenId);
        address mToken = IDmmController(__assetIntroducerProxy.dmmController()).getDmmTokenAddressByDmmTokenId(__dmmTokenId);
        IERC20(mToken).safeTransferFrom(msg.sender, address(this), stakeAmount);
        uint64 unlockTimestamp = uint64(block.timestamp) + mapDurationEnumToSeconds(__duration);
        _userToStakesMap[msg.sender].push(UserStake({
        isWithdrawn : false,
        unlockTimestamp : unlockTimestamp,
        mToken : mToken,
        amount : stakeAmount,
        tokenId : __tokenId
        }));
        emit UserBeginStaking(msg.sender, __tokenId, mToken, stakeAmount, unlockTimestamp);
    }

    function _getStakeAmountByDmmTokenId(
        uint __dmmTokenId,
        uint __priceUsd
    ) internal view returns (uint) {
        IDmmController controller = IDmmController(IAssetIntroducerV1(_assetIntroducerProxy).dmmController());
        address dmmToken = controller.getDmmTokenAddressByDmmTokenId(__dmmTokenId);
        address underlyingToken = controller.getUnderlyingTokenForDmm(dmmToken);
        uint usdPricePerToken = controller.underlyingTokenValuator().getTokenValue(underlyingToken, ONE_ETH);
        uint numberOfDmmTokensStandardized = __priceUsd.mul(ONE_ETH).div(usdPricePerToken).mul(ONE_ETH).div(controller.getExchangeRate(dmmToken));
        uint8 decimals = IERC20WithDecimals(dmmToken).decimals();
        if (decimals > 18) {
            return numberOfDmmTokensStandardized.mul(10 ** uint(decimals - 18));
        } else if (decimals < 18) {
            return numberOfDmmTokensStandardized.div(10 ** uint(18 - decimals));
        } else {
            return numberOfDmmTokensStandardized;
        }
    }

}