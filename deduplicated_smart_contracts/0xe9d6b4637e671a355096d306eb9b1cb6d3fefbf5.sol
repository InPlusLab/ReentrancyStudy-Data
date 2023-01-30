/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

// File: contracts/VeloxTransferHelper.sol

// SPDX-FileCopyrightText: © 2020 Velox <[email protected]>
// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library VeloxTransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        require(token != address(0), 'VeloxTransferHelper: ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        require(token != address(0), 'VeloxTransferHelper: ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        require(token != address(0), 'VeloxTransferHelper: TOKEN_ZERO_ADDRESS');
        require(from != address(0), 'VeloxTransferHelper: FROM_ZERO_ADDRESS');
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');

        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VeloxTransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        require(to != address(0), 'VeloxTransferHelper: TO_ZERO_ADDRESS');
        
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// File: contracts/interfaces/IERC20.sol

pragma solidity >=0.8.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: contracts/interfaces/IERC20NONStandard.sol

pragma solidity >=0.8.0;

/**
 * @dev Version of ERC20 with no return values for `transfer` and `transferFrom`
 * See https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
 */
abstract contract IERC20NONStandard {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */

    uint256 public totalSupply;
    function balanceOf(address owner) virtual public view returns (uint256 balance);

    /// !!! NOTICE !!! `transfer` does not return a value, in violation of the ERC20 specification
    /// will return Whether the transfer was successful or not
    function transfer(address to, uint256 value) virtual public;

    /// !!! NOTICE !!! `transferFrom` does not return a value, in violation of the ERC20 specification
    /// will return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint256 value) virtual public;


    function approve(address spender, uint256 value) virtual public returns (bool success);
    function allowance(address owner, address spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/SwapExceptions.sol

pragma solidity >=0.8.0;

contract SwapExceptions {

    event SwapException(uint exception, uint info, uint detail);

    enum Exception {
        NO_ERROR,
        GENERIC_ERROR,
        UNAUTHORIZED,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,
        DIVISION_BY_ZERO,
        BAD_INPUT,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_TRANSFER_FAILED,
        MARKET_NOT_SUPPORTED,
        SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_RATE_CALCULATION_FAILED,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_OUT_FAILED,
        INSUFFICIENT_LIQUIDITY,
        INSUFFICIENT_BALANCE,
        INVALID_COLLATERAL_RATIO,
        MISSING_ASSET_PRICE,
        EQUITY_INSUFFICIENT_BALANCE,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        ASSET_NOT_PRICED,
        INVALID_LIQUIDATION_DISCOUNT,
        INVALID_COMBINED_RISK_PARAMETERS,
        ZERO_ORACLE_ADDRESS,
        CONTRACT_PAUSED
    }

    /*
     * Note: Reason (but not Exception) is kept in alphabetical order
     *       This is because Reason grows significantly faster, and
     *       the order of Exception has some meaning, while the order of Reason
     *       is arbitrary.
     */
    enum Reason {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        BORROW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        BORROW_ACCOUNT_SHORTFALL_PRESENT,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_AMOUNT_LIQUIDITY_SHORTFALL,
        BORROW_AMOUNT_VALUE_CALCULATION_FAILED,
        BORROW_CONTRACT_PAUSED,
        BORROW_MARKET_NOT_SUPPORTED,
        BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        BORROW_ORIGINATION_FEE_CALCULATION_FAILED,
        BORROW_TRANSFER_OUT_FAILED,
        EQUITY_WITHDRAWAL_AMOUNT_VALIDATION,
        EQUITY_WITHDRAWAL_CALCULATE_EQUITY,
        EQUITY_WITHDRAWAL_MODEL_OWNER_CHECK,
        EQUITY_WITHDRAWAL_TRANSFER_OUT_FAILED,
        LIQUIDATE_ACCUMULATED_BORROW_BALANCE_CALCULATION_FAILED,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_AMOUNT_SEIZE_CALCULATION_FAILED,
        LIQUIDATE_BORROW_DENOMINATED_COLLATERAL_CALCULATION_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_TOO_HIGH,
        LIQUIDATE_CONTRACT_PAUSED,
        LIQUIDATE_DISCOUNTED_REPAY_TO_EVEN_AMOUNT_CALCULATION_FAILED,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_BORROW_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_SUPPLY_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_BORROW_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_CASH_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_FETCH_ASSET_PRICE_FAILED,
        LIQUIDATE_TRANSFER_IN_FAILED,
        LIQUIDATE_TRANSFER_IN_NOT_POSSIBLE,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_CONTRACT_PAUSED,
        REPAY_BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_ASSET_PRICE_CHECK_ORACLE,
        SET_MARKET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_ORACLE_OWNER_CHECK,
        SET_ORIGINATION_FEE_OWNER_CHECK,
        SET_PAUSED_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RISK_PARAMETERS_OWNER_CHECK,
        SET_RISK_PARAMETERS_VALIDATION,
        SUPPLY_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        SUPPLY_CONTRACT_PAUSED,
        SUPPLY_MARKET_NOT_SUPPORTED,
        SUPPLY_NEW_BORROW_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_BORROW_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_CASH_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        SUPPLY_TRANSFER_IN_FAILED,
        SUPPLY_TRANSFER_IN_NOT_POSSIBLE,
        SUPPORT_MARKET_FETCH_PRICE_FAILED,
        SUPPORT_MARKET_OWNER_CHECK,
        SUPPORT_MARKET_PRICE_CHECK,
        SUSPEND_MARKET_OWNER_CHECK,
        WITHDRAW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        WITHDRAW_ACCOUNT_SHORTFALL_PRESENT,
        WITHDRAW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        WITHDRAW_AMOUNT_LIQUIDITY_SHORTFALL,
        WITHDRAW_AMOUNT_VALUE_CALCULATION_FAILED,
        WITHDRAW_CAPACITY_CALCULATION_FAILED,
        WITHDRAW_CONTRACT_PAUSED,
        WITHDRAW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_BORROW_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        WITHDRAW_TRANSFER_OUT_FAILED,
        WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE
    }

    /**
      * @dev report a known exception
      */
    function raiseException(Exception exception, Reason reason) internal returns (uint) {
        emit SwapException(uint(exception), uint(reason), 0);
        return uint(exception);
    }

    /**
      * @dev report an opaque error from an upgradeable collaborator contract
      */
    function raiseGenericException(Reason reason, uint genericException) internal returns (uint) {
        emit SwapException(uint(Exception.GENERIC_ERROR), uint(reason), genericException);
        return uint(Exception.GENERIC_ERROR);
    }

}

// File: contracts/Swappable.sol

pragma solidity 0.8.0;




/**
  * @title Swappable Interface
  */
contract Swappable is SwapExceptions {
    /**
      * @dev Checks whether or not there is sufficient allowance for this contract to move amount from `from` and
      *      whether or not `from` has a balance of at least `amount`. Does NOT do a transfer.
      */
    function checkTransferIn(address asset, address from, uint amount) internal view returns (Exception) {

        IERC20 token = IERC20(asset);

        if (token.allowance(from, address(this)) < amount) {
            return Exception.TOKEN_INSUFFICIENT_ALLOWANCE;
        }

        if (token.balanceOf(from) < amount) {
            return Exception.TOKEN_INSUFFICIENT_BALANCE;
        }

        return Exception.NO_ERROR;
    }

    /**
      *  @dev This wrapper safely handles non-standard ERC-20 tokens that do not return a value.
      *  See here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
      */
    function doTransferIn(address asset, address from, uint amount) internal returns (Exception) {
        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        // Should we use Helper.safeTransferFrom?
        require(token.allowance(from, address(this)) >= amount, 'Not enough allowance from client');
        token.transferFrom(from, address(this), amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_FAILED;
        }

        return Exception.NO_ERROR;
    }

    /**
      * @dev Checks balance of this contract in asset
      */
    function getCash(address asset) internal view returns (uint) {
        IERC20 token = IERC20(asset);
        return token.balanceOf(address(this));
    }

    /**
      * @dev Checks balance of `from` in `asset`
      */
    function getBalanceOf(address asset, address from) internal view returns (uint) {
        IERC20 token = IERC20(asset);
        return token.balanceOf(from);
    }

    /**
      * @dev Similar to EIP20 transfer, except it handles a False result from `transfer` and returns an explanatory
      *      error code rather than reverting. If caller has not called checked protocol's balance, this may revert due to
      *      insufficient cash held in this contract. If caller has checked protocol's balance prior to this call, and verified
      *      it is >= amount, this should not revert in normal conditions.
      *
      *      Note: This wrapper safely handles non-standard ERC-20 tokens that do not return a value.
      *            See here: https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca
      */
    function doTransferOut(address asset, address to, uint amount) internal returns (Exception) {
        IERC20NONStandard token = IERC20NONStandard(asset);
        bool result;
        token.transfer(to, amount);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        if (!result) {
            return Exception.TOKEN_TRANSFER_OUT_FAILED;
        }

        return Exception.NO_ERROR;
    }
}

// File: contracts/Context.sol

pragma solidity 0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/Ownable.sol

pragma solidity >=0.8.0;

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
}

// File: contracts/interfaces/IVeloxSwapV3.sol

pragma solidity >=0.8.0;

interface IVeloxSwapV3 {

    function withdrawToken(address token, uint256 amount) external;
    
    function withdrawETH(uint256 amount) external;

    function sellExactTokensForTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline) external returns (uint256 amountOut);

    function sellExactTokensForTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost) external returns (uint256 amountOut);

    function sellTokensForExactTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline) external returns (uint256 amountIn);

    function sellTokensForExactTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost) external returns (uint256 amountIn);

    function fundGasCost(uint256  strategyId, address seller, bytes32 txHash, uint256 wethAmount) external;

}

// File: contracts/BackingStore.sol

pragma solidity >=0.8.0;

abstract contract BackingStore {
    address public MAIN_CONTRACT;
    address public UNISWAP_FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public ADMIN_ADDRESS;
}

// File: contracts/lib/IERC165.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts/lib/ERC165.sol

pragma solidity ^0.8.0;


/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// File: contracts/lib/AccessControl.sol

pragma solidity ^0.8.0;



/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// File: contracts/AccessManager.sol

pragma solidity 0.8.0;


contract AccessManager is AccessControl{

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    /**
        * @dev Throws if called by any account other than the admin.
    */
    modifier hasAdminRole() {
        require(hasRole(ADMIN_ROLE, _msgSender()), "VELOXSWAP: NOT_ADMIN");
        _;
    } 
    
}

// File: contracts/VeloxSwapV3.sol

pragma solidity 0.8.0;








/**
* @title VeloxSwap based on algorithmic conditional trading exeuctions
*/
abstract contract VeloxSwapV3 is BackingStore, Ownable, Swappable, IVeloxSwapV3, AccessManager {
    function setUpAdminRole(address _c) public onlyOwner returns (bool succeeded) {
        require(_c != owner(), "VELOXPROXY_ADMIN_OWNER");
        _setupRole(ADMIN_ROLE, _c);
        return true;
    }
    function setRootRole() public onlyOwner returns (bool succeeded) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        return true;
    }
    function grantAdminRole(address _c) public onlyOwner returns (bool succeeded) {
        require(_c != owner(), "VELOXPROXY_ADMIN_OWNER");
        grantRole(ADMIN_ROLE, _c);
        return true;
    }
    function revokeAdminRole(address _c) public onlyOwner returns (bool succeeded) {
        require(_c != owner(), "VELOXPROXY_ADMIN_OWNER");
        revokeRole(ADMIN_ROLE, _c);
        return true;
    }

    struct SwapInput {
        address seller;
        address tokenInAddress;
        address tokenOutAddress;
        uint256 tokenInAmount;
        uint256 tokenOutAmount;
        uint16 feeFactor;
        bool takeFeeFromInput;
        uint256 deadline;
    }

    address private gasFundingTokenAddress;

    uint constant FEE_SCALE = 10000;
    uint constant GAS_FUNDING_ESTIMATED_GAS = 26233;

    event ValueSwapped(uint256 indexed strategyId, address indexed seller, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    event GasFunded(uint256 indexed strategyId, address indexed seller, bytes32 indexed txHash, uint256 gasCost);
    event GasFundingTokenChanged(address oldValue, address newValue);
    event ExchangeRegistered(string indexed exchange, address indexed routerAddress);

    function setGasFundingTokenAddress(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "VELOXSWAP: ZERO_GAS_FUNDING_TOKEN_ADDRESS");

        address oldValue = gasFundingTokenAddress;

        gasFundingTokenAddress = tokenAddress;

        emit GasFundingTokenChanged(oldValue, gasFundingTokenAddress);
    }

    function getGasFundingTokenAddress() public view returns (address) {
        return gasFundingTokenAddress;
    }

    function setKnownExchange(string calldata exchangeName, address routerAddress) onlyOwner external virtual {
        require(routerAddress != address(0), "VELOXSWAP: INVALID_ROUTER_ZERO_ADDRESS");

        _setKnownExchange(exchangeName, routerAddress);
        
        emit ExchangeRegistered(exchangeName, routerAddress);
    }

    function withdrawToken(address token, uint256 amount) onlyOwner override external {
        VeloxTransferHelper.safeTransfer(token, msg.sender, amount);
    }

    function withdrawETH(uint256 amount) onlyOwner override external {
        VeloxTransferHelper.safeTransferETH(msg.sender, amount);
    }

    function fundGasCost(uint256 strategyId, address seller, bytes32 txHash, uint256 wethAmount) hasAdminRole override external {
        require(txHash.length > 0, "VELOXSWAP: INVALID_TX_HASH");

        _fundGasCost(strategyId, seller, txHash, wethAmount);
    }

    function _fundGasCost(uint256 strategyId, address seller, bytes32 txHash, uint256 wethAmount) private {
        VeloxTransferHelper.safeTransferFrom(gasFundingTokenAddress, seller, _msgSender(), wethAmount);
        
        emit GasFunded(strategyId, seller, txHash, wethAmount);
    }

    /**
    *   @dev This function should ONLY be executed when algorithmic conditons are met
    *   function sellExactTokensForTokens
    *   @param exchange             string name of a existing exchange in routersByName
    *   @param strategyId           uint256 - strategy ID
    *   @param seller               address
    *   @param tokenInAddress       address
    *   @param tokenOutAddress      address
    *   @param tokenInAmount        uint256
    *   @param minTokenOutAmount    uint256
    *   @param feeFactor            uint - 1/10000 fraction of the amount, i.e. feeFactor of 1 means 0.01% fee
    *   @param takeFeeFromInput     bool
    *   @param deadline             uint256 - UNIX timestamp
    *   @param estimatedGasFundingCost uint - estimated gas for gas funding transaction
    */
    function sellExactTokensForTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost
    ) override hasAdminRole public returns (uint256 amountOut) {
        uint256 initialGas = gasleft();

        SwapInput memory input = SwapInput({ 
            seller: seller, tokenInAddress: tokenInAddress,
            tokenOutAddress: tokenOutAddress,
            tokenInAmount: tokenInAmount,
            tokenOutAmount: minTokenOutAmount,
            feeFactor: feeFactor,
            takeFeeFromInput: takeFeeFromInput,
            deadline: deadline });
        
        ( , amountOut) = swapTokens(exchange, strategyId, input, true);

        // Not sure if it should be 0 or just minus something
        if (isTakingOutputFeeInGasToken(input)) {
            estimatedGasFundingCost = 0;
        }
        
        uint256 gasCost = (initialGas - gasleft() + estimatedGasFundingCost) * tx.gasprice;

        bytes32 txHash;
        _fundGasCost(strategyId, seller, txHash, gasCost);
    }

    /**
    *   @dev This function should ONLY be executed when algorithmic conditons are met
    *   function sellExactTokensForTokens
    *   @param exchange             string name of a existing exchange in routersByName
    *   @param strategyId           uint256 - strategy ID
    *   @param seller               address
    *   @param tokenInAddress       address
    *   @param tokenOutAddress      address
    *   @param tokenInAmount        uint256
    *   @param minTokenOutAmount    uint256
    *   @param feeFactor            uint - 1/10000 fraction of the amount, i.e. feeFactor of 1 means 0.01% fee
    *   @param takeFeeFromInput     bool
    *   @param deadline             uint256 - UNIX timestamp
    */
    function sellExactTokensForTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 tokenInAmount,
        uint256 minTokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline
    ) override hasAdminRole public returns (uint256 amountOut) {
        amountOut = sellExactTokensForTokens(exchange, strategyId, seller, tokenInAddress, tokenOutAddress, tokenInAmount, minTokenOutAmount, feeFactor, takeFeeFromInput, deadline, GAS_FUNDING_ESTIMATED_GAS);
    }

    /**
    *   @dev This function should ONLY be executed when algorithmic conditons are met
    *   function sellTokensForExactTokens
    *   @param exchange             string name of a existing exchange in routersByName
    *   @param strategyId           uint256 - strategy ID
    *   @param seller               address
    *   @param tokenInAddress       address
    *   @param tokenOutAddress      address
    *   @param maxTokenInAmount     uint256
    *   @param tokenOutAmount       uint256
    *   @param feeFactor            uint - 1/10000 fraction of the amount, i.e. feeFactor of 1 means 0.01% fee
    *   @param takeFeeFromInput     bool
    *   @param deadline             uint256 - UNIX timestamp
    *   @param estimatedGasFundingCost uint - estimated gas for gas funding transaction
    */
    function sellTokensForExactTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline,
        uint estimatedGasFundingCost) override hasAdminRole public returns (uint256 amountIn) {

        uint256 initialGas = gasleft();

        SwapInput memory input = SwapInput({ 
            seller: seller, tokenInAddress: tokenInAddress,
            tokenOutAddress: tokenOutAddress,
            tokenInAmount: maxTokenInAmount,
            tokenOutAmount: tokenOutAmount,
            feeFactor: feeFactor,
            takeFeeFromInput: takeFeeFromInput,
            deadline: deadline });
        
        (amountIn, ) = swapTokens(exchange, strategyId, input, false);

        // Not sure if it should be 0 or just minus something
        if (isTakingOutputFeeInGasToken(input)) {
            estimatedGasFundingCost = 0;
        }
        
        uint256 gasCost = (initialGas - gasleft() + estimatedGasFundingCost) * tx.gasprice;

        bytes32 txHash;
        _fundGasCost(strategyId, seller, txHash, gasCost);
    }

    /**
    *   @dev This function should ONLY be executed when algorithmic conditons are met
    *   function sellTokensForExactTokens
    *   @param exchange             string name of a existing exchange in routersByName
    *   @param strategyId           uint256 - strategy ID
    *   @param seller               address
    *   @param tokenInAddress       address
    *   @param tokenOutAddress      address
    *   @param maxTokenInAmount     uint256
    *   @param tokenOutAmount       uint256
    *   @param feeFactor            uint - 1/10000 fraction of the amount, i.e. feeFactor of 1 means 0.01% fee
    *   @param takeFeeFromInput     bool
    *   @param deadline             uint256 - UNIX timestamp
    */
    function sellTokensForExactTokens(
        string calldata exchange,
        uint256 strategyId,
        address seller,
        address tokenInAddress,
        address tokenOutAddress,
        uint256 maxTokenInAmount,
        uint256 tokenOutAmount,
        uint16 feeFactor,
        bool takeFeeFromInput,
        uint256 deadline) override hasAdminRole public returns (uint256 amountIn) {
        amountIn = sellTokensForExactTokens(exchange, strategyId, seller, tokenInAddress, tokenOutAddress, maxTokenInAmount, tokenOutAmount, feeFactor, takeFeeFromInput, deadline, GAS_FUNDING_ESTIMATED_GAS);
    }
    
    function swapTokens(string calldata exchange, uint256 strategyId, SwapInput memory input, bool exactIn) private returns (uint256 amountIn, uint256 amountOut) {
        uint256 amountInForSwap;
        uint256 amountOutForSwap;
        address swapTargetAddress;

        (amountInForSwap, amountOutForSwap, swapTargetAddress) 
            = prepareSwap(exchange, input);

        uint actualAmountOut;

        // Execute the swap
        (amountIn, actualAmountOut) = doSwap(exchange, input.tokenInAddress, input.tokenOutAddress, amountInForSwap, amountOutForSwap, swapTargetAddress, input.deadline, exactIn);

        // Take the fee from the output if not taken from the input
        if (!input.takeFeeFromInput) {
            amountOut = takeOutputFee(actualAmountOut, input.feeFactor, input.tokenOutAddress, input.seller);
        }

        emit ValueSwapped(strategyId, input.seller, input.tokenInAddress, input.tokenOutAddress, input.tokenInAmount, amountOut);
    }

    function prepareSwap(string calldata exchange, SwapInput memory input) private returns (uint256 amountInForSwap, uint256 amountOurForSwap, address targetAddress) {

        // Sanity checks
        validateInput(input.seller, input.tokenInAddress, input.tokenOutAddress, input.tokenInAmount, input.tokenOutAmount, input.feeFactor, input.deadline);

        // Be 100% sure there's available allowance in this token contract
        Exception exception = doTransferIn(input.tokenInAddress, input.seller, input.tokenInAmount);
        require(exception == Exception.NO_ERROR, 'VELOXSWAP: ALLOWANCE_TOO_LOW');

        // Checking In/Out reserves
        checkLiquidity(exchange, input.tokenInAddress, input.tokenOutAddress, input.tokenOutAmount);

        // Fee
        (amountInForSwap, amountOurForSwap, targetAddress) = adjustInputBasedOnFee(input.takeFeeFromInput, input.feeFactor, input.tokenInAmount, input.tokenOutAmount, input.seller);
    }

    function validateInput(address seller, address tokenInAddress, address tokenOutAddress, uint256 tokenInAmount, uint256 tokenOutAmount, uint16 feeFactor, uint256 deadline) private view {
        require(deadline >= block.timestamp, 'VELOXSWAP: EXPIRED');
        require(feeFactor <= 30, 'VELOXSWAP: FEE_OVER_03_PERCENT');

        require(gasFundingTokenAddress != address(0), 'VELOXSWAP: GAS_FUNDING_ADDRESS_NOT_FOUND');

        require (seller != address(0) &&
                tokenInAddress != address(0) &&
                tokenOutAddress != address(0) &&
                tokenInAmount > 0 &&
                tokenOutAmount > 0,
        'VELOXSWAP: ZERO_DETECTED');
    }

    /**
    *   @dev Adjust input values based on the fee strategy
    *   @param takeFeeFromInput     bool
    *   @param feeFactor            uint - 1/10000 fraction of the amount, i.e. feeFactor of 1 means 0.01% fee
    *   @param amountIn             uint256
    *   @param amountOut            uint256
    *   @param sellerAddress        address
    */
    function adjustInputBasedOnFee(bool takeFeeFromInput, uint16 feeFactor, uint256 amountIn, uint256 amountOut, address sellerAddress) private view
        returns (uint256 amountInForSwap, uint256 amountOurForSwap, address targetAddress) {
        // Take fee from input
        if (takeFeeFromInput) {
            // Use less tokens for swap so we can keep the difference and make one less transfer
            amountInForSwap = deductFee(amountIn, feeFactor);
            amountOurForSwap = deductFee(amountOut, feeFactor);

        // If we took fee from the input, transfer the result directly to client,
        // otherwise, transfer to contract address so we can take fee from output
            targetAddress = sellerAddress;
        } else {
            amountInForSwap = amountIn;
            amountOurForSwap = amountOut;
            targetAddress = address(this);
        }
    }

    function doSwap(string calldata exchange, address tokenInAddress, address tokenOutAddress, uint256 tokenInAmount, uint256 minTokenOutAmount, address targetAddress, uint256 deadline, bool exactIn) private returns (uint amountIn, uint amountOut) {
        // Safely Approve UNISWAP V2 Router for token amount
        safeApproveExchangeRouter(exchange, tokenInAddress, tokenInAmount);

        // Path
        address[] memory path = new address[](2);
        path[0] = tokenInAddress;
        path[1] = tokenOutAddress;

        uint[] memory amounts;

        if (exactIn) {
            amounts = swapExactTokensForTokens(
                exchange,
                tokenInAmount,
                minTokenOutAmount,
                path,
                targetAddress,
                deadline
            );
        } else {
            amounts = swapTokensForExactTokens(
                exchange,
                tokenInAmount,
                minTokenOutAmount,
                path,
                targetAddress,
                deadline
            );
        }

        amountIn = amounts[0];
        amountOut = amounts[amounts.length - 1];
    }

    function checkLiquidity(string calldata exchange, address tokenInAddress, address tokenOutAddress, uint256 minTokenOutAmount) private view {
        (uint reserveIn, uint reserveOut) = getLiquidityForPair(exchange, tokenInAddress, tokenOutAddress);

        require(reserveIn > 0 && reserveOut > 0, 'VELOXSWAP: ZERO_RESERVE_DETECTED');
        require(reserveOut > minTokenOutAmount, 'VELOXSWAP: NOT_ENOUGH_LIQUIDITY');
    }

    function takeOutputFee(uint256 amountOut, uint16 feeFactor, address tokenOutAddress,
                           address from) private returns (uint256 transferredAmount) {

        // Transfer to client address the value of amountOut - fee and keep difference in contract address
        transferredAmount = deductFee(amountOut, feeFactor);
        Exception exception = doTransferOut(tokenOutAddress, from, transferredAmount);
        require (exception == Exception.NO_ERROR, 'VELOXSWAP: ERROR_GETTING_OUTPUT_FEE');
    }

    function deductFee(uint256 amount, uint16 feeFactor) private pure returns (uint256 deductedAmount) {
        deductedAmount = (amount * (FEE_SCALE - feeFactor)) / FEE_SCALE;
    }
    
    function isTakingOutputFeeInGasToken(SwapInput memory input) private view returns (bool) {
        return !input.takeFeeFromInput && input.tokenOutAddress == gasFundingTokenAddress;
    }

    /**
    ABSTRACT METHODS
     */

    function _setKnownExchange(string calldata exchangeName, address routerAddress) internal virtual;

    function safeApproveExchangeRouter(string calldata exchange, address tokenInAddress, uint256 tokenInAmount) internal virtual;

    function getLiquidityForPair(string calldata exchange, address tokenInAddress, address tokenOutAddress) view internal virtual returns (uint reserveIn, uint reserveOut);

    function swapExactTokensForTokens(
        string calldata exchange,
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) internal virtual returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        string calldata exchange,
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) internal virtual returns (uint[] memory amounts);
}

// File: contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.8.0;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.8.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: contracts/EthereumVeloxSwapV3.sol

pragma solidity 0.8.0;






/**
* @title VeloxSwap based on algorithmic conditional trading exeuctions
*/
contract EthereumVeloxSwapV3 is VeloxSwapV3 {

    mapping (string=>IUniswapV2Router02) routersByName;

    function _setKnownExchange(string calldata exchangeName, address uniswapLikeRouterAddress) onlyOwner override internal {
        require(uniswapLikeRouterAddress != address(0), "VELOXSWAP: INVALID_ROUTER_ADDRESS");

        // Check how to validate this
        IUniswapV2Router02 newRouter = IUniswapV2Router02(uniswapLikeRouterAddress);

        require(address(newRouter.factory()) != address(0), "VELOXSWAP: INVALID_ROUTER");

        routersByName[exchangeName] = newRouter;
    }

    function safeApproveExchangeRouter(string calldata exchange, address tokenInAddress, uint256 tokenInAmount) override internal {
        IUniswapV2Router02 router = getRouter(exchange);

        VeloxTransferHelper.safeApprove(tokenInAddress, address(router), tokenInAmount);
    }

    function getLiquidityForPair(string calldata exchange, address tokenInAddress, address tokenOutAddress) view internal override returns (uint reserveIn, uint reserveOut) {
        IUniswapV2Router02 router = getRouter(exchange);
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());

        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(tokenInAddress, tokenOutAddress));
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();

        if (pair.token0() == tokenOutAddress) {
            reserveIn = reserve1;
            reserveOut = reserve0;
        } else {
            reserveIn = reserve0;
            reserveOut = reserve1;
        }
    }

    function getRouter(string memory exchange) private view returns (IUniswapV2Router02 router) {
        router = routersByName[exchange];

        require(address(router) != address(0), "VELOXSWAP: UNKNOWN_EXCHANGE");
    }

    function swapExactTokensForTokens(
        string calldata exchange,
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) override internal virtual returns (uint[] memory amounts) {
        IUniswapV2Router02 router = getRouter(exchange);
        
        amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    function swapTokensForExactTokens(
        string calldata exchange,
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) override internal virtual returns (uint[] memory amounts) {
        IUniswapV2Router02 router = getRouter(exchange);
        
        amounts = router.swapTokensForExactTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }
}