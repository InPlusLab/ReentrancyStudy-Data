/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
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
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interfaces/ISRC20.sol

pragma solidity ^0.5.0;

/**
 * @title SRC20 public interface
 */
interface ISRC20 {

    event RestrictionsAndRulesUpdated(address restrictions, address rules);

    function transferToken(address to, uint256 value, uint256 nonce, uint256 expirationTime,
        bytes32 msgHash, bytes calldata signature) external returns (bool);
    function transferTokenFrom(address from, address to, uint256 value, uint256 nonce,
        uint256 expirationTime, bytes32 hash, bytes calldata signature) external returns (bool);
    function getTransferNonce() external view returns (uint256);
    function getTransferNonce(address account) external view returns (uint256);
    function executeTransfer(address from, address to, uint256 value) external returns (bool);
    function updateRestrictionsAndRules(address restrictions, address rules) external returns (bool);

    // ERC20 part-like interface
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function increaseAllowance(address spender, uint256 value) external returns (bool);
    function decreaseAllowance(address spender, uint256 value) external returns (bool);
}

// File: contracts/interfaces/ISRC20Managed.sol

pragma solidity ^0.5.0;

/**
    @title SRC20 interface for managers
 */
interface ISRC20Managed {
    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    function burn(address account, uint256 value) external returns (bool);
    function mint(address account, uint256 value) external returns (bool);
}

// File: contracts/interfaces/ISRC20Roles.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which allows children to implement access managements
 * with multiple roles.
 *
 * `Authority` the one how is authorized by token owner/issuer to authorize transfers
 * either on-chain or off-chain.
 *
 * `Delegate` the person who person responsible for updating KYA document
 *
 * `Manager` the person who is responsible for minting and burning the tokens. It should be
 * be registry contract where staking->minting is executed.
 */
contract ISRC20Roles {
    function isAuthority(address account) external view returns (bool);
    function removeAuthority(address account) external returns (bool);
    function addAuthority(address account) external returns (bool);

    function isDelegate(address account) external view returns (bool);
    function addDelegate(address account) external returns (bool);
    function removeDelegate(address account) external returns (bool);

    function manager() external view returns (address);
    function isManager(address account) external view returns (bool);
    function transferManagement(address newManager) external returns (bool);
    function renounceManagement() external returns (bool);
}

// File: contracts/interfaces/IManager.sol

pragma solidity ^0.5.0;

/**
 * @dev Manager handles SRC20 burn/mint in relation to
 * SWM token staking.
 */
interface IManager {
 
    event SRC20SupplyMinted(address src20, address swmAccount, uint256 swmValue, uint256 src20Value);
    event SRC20StakeIncreased(address src20, address swmAccount, uint256 swmValue);
    event SRC20StakeDecreased(address src20, address swmAccount, uint256 swmValue);

    function mintSupply(address src20, address swmAccount, uint256 swmValue, uint256 src20Value) external returns (bool);
    function increaseSupply(address src20, address swmAccount, uint256 srcValue) external returns (bool);
    function decreaseSupply(address src20, address swmAccount, uint256 srcValue) external returns (bool);
    function renounceManagement(address src20) external returns (bool);
    function transferManagement(address src20, address newManager) external returns (bool);
    function calcTokens(address src20, uint256 swmValue) external view returns (uint256);

    function getStake(address src20) external view returns (uint256);
    function swmNeeded(address src20, uint256 srcValue) external view returns (uint256);
    function getSrc20toSwmRatio(address src20) external returns (uint256);
    function getTokenOwner(address src20) external view returns (address);
}

// File: contracts/factories/Manager.sol

pragma solidity ^0.5.0;









/**
 * @dev Manager handles SRC20 burn/mint in relation to
 * SWM token staking.
 */
contract Manager is IManager, Ownable {
    using SafeMath for uint256;

    event SRC20SupplyMinted(address src20, address swmAccount, uint256 swmValue, uint256 src20Value);
    event SRC20SupplyIncreased(address src20, address swmAccount, uint256 srcValue);
    event SRC20SupplyDecreased(address src20, address swmAccount, uint256 srcValue);

    mapping (address => SRC20) internal _registry;

    struct SRC20 {
        address owner;
        address roles;
        uint256 stake;
        address minter;
    }

    IERC20 private _swmERC20;

    constructor(address swmERC20) public {
        require(swmERC20 != address(0), 'SWM ERC20 is zero address');

        _swmERC20 = IERC20(swmERC20);
    }

    modifier onlyTokenOwner(address src20) {
        require(_isTokenOwner(src20), "Caller not token owner.");
        _;
    }

    // Note that, similarly to the role of token owner, there is only one manager per src20 token contract.
    // Only one address can have this role.
    modifier onlyMinter(address src20) {
        require(msg.sender == _registry[src20].minter, "Caller not token minter.");
        _;
    }

    /**
     * @dev Mint additional supply of SRC20 tokens based on SWN token stake.
     * Can be used for initial supply and subsequent minting of new SRC20 tokens.
     * When used, Manager will update SWM/SRC20 values in this call and use it
     * for token owner's incStake/decStake calls, minting/burning SRC20 based on
     * current SWM/SRC20 ratio.
     * Only owner of this contract can invoke this method. Owner is SWARM controlled
     * address.
     * Emits SRC20SupplyMinted event.
     *
     * @param src20 SRC20 token address.
     * @param swmAccount SWM ERC20 account holding enough SWM tokens (>= swmValue)
     * with manager contract address approved to transferFrom.
     * @param swmValue SWM stake value.
     * @param src20Value SRC20 tokens to mint
     * @return true on success.
     */
    function mintSupply(address src20, address swmAccount, uint256 swmValue, uint256 src20Value)
        onlyMinter(src20)
        external
        returns (bool)
    {
        require(swmAccount != address(0), "SWM account is zero");
        require(swmValue != 0, "SWM value is zero");
        require(src20Value != 0, "SRC20 value is zero");
        require(_registry[src20].owner != address(0), "SRC20 token contract not registered");

        _registry[src20].stake = _registry[src20].stake.add(swmValue);

        require(_swmERC20.transferFrom(swmAccount, address(this), swmValue));
        require(ISRC20Managed(src20).mint(_registry[src20].owner, src20Value));

        emit SRC20SupplyMinted(src20, swmAccount, swmValue, src20Value);

        return true;
    }

    /**
     * @dev This is function token issuer can call in order to increase his SRC20 supply this
     * and stake his tokens.
     *
     * @param src20 Address of src20 token contract
     * @param swmAccount Account from which stake tokens are going to be deducted
     * @param srcValue Value of desired SRC20 token value
     * @return true if success
     */
    function increaseSupply(address src20, address swmAccount, uint256 srcValue)
        external
        onlyTokenOwner(src20)
        returns (bool)
    {
        require(swmAccount != address(0), "SWM account is zero");
        require(srcValue != 0, "SWM value is zero");
        require(_registry[src20].owner != address(0), "SRC20 token contract not registered");

        uint256 swmValue = _swmNeeded(src20, srcValue);

        require(_swmERC20.transferFrom(swmAccount, address(this), swmValue));
        require(ISRC20Managed(src20).mint(_registry[src20].owner, srcValue));

        _registry[src20].stake = _registry[src20].stake.add(swmValue);
        emit SRC20SupplyIncreased(src20, swmAccount, swmValue);

        return true;
    }

    /**
     * @dev This is function token issuer can call in order to decrease his SRC20 supply
     * and his stake back
     *
     * @param src20 Address of src20 token contract
     * @param swmAccount Account to which stake tokens will be returned
     * @param srcValue Value of desired SRC20 token value
     * @return true if success
     */
    function decreaseSupply(address src20, address swmAccount, uint256 srcValue)
        external
        onlyTokenOwner(src20)
        returns (bool)
    {
        require(swmAccount != address(0), "SWM account is zero");
        require(srcValue != 0, "SWM value is zero");
        require(_registry[src20].owner != address(0), "SRC20 token contract not registered");

        uint256 swmValue = _swmNeeded(src20, srcValue);

        require(_swmERC20.transfer(swmAccount, swmValue));
        require(ISRC20Managed(src20).burn(_registry[src20].owner, srcValue));

        _registry[src20].stake = _registry[src20].stake.sub(swmValue);
        emit SRC20SupplyDecreased(src20, swmAccount, srcValue);

        return true;
    }

    /**
     * @dev Allows manager to renounce management.
     *
     * @param src20 SRC20 token address.
     * @return true on success.
     */
    function renounceManagement(address src20)
        external
        onlyOwner
        returns (bool)
    {
        require(_registry[src20].owner != address(0), "SRC20 token contract not registered");

        require(ISRC20Roles(_registry[src20].roles).renounceManagement());

        return true;
    }

    /**
     * @dev Allows manager to transfer management to another address.
     *
     * @param src20 SRC20 token address.
     * @param newManager New manager address.
     * @return true on success.
     */
    function transferManagement(address src20, address newManager)
        public
        onlyOwner
        returns (bool)
    {
        require(_registry[src20].owner != address(0), "SRC20 token contract not registered");
        require(newManager != address(0), "newManager address is zero");

        require(ISRC20Roles(_registry[src20].roles).transferManagement(newManager));

        return true;
    }

    /**
     * @dev External function allowing consumers to check corresponding SRC20 amount
     * to supplied SWM amount.
     *
     * @param src20 SRC20 token to check for.this
     * @param swmValue SWM value.
     * @return Amount of SRC20 tokens.
     */
    function calcTokens(address src20, uint256 swmValue) external view returns (uint256) {
        return _calcTokens(src20, swmValue);
    }

    /**
     * @dev External view function for calculating SWM tokens needed for increasing/decreasing
     * src20 token supply.
     *
     * @param src20 Address of src20 contract
     * @param srcValue Amount of src20 tokens.this
     * @return Amount of SWM tokens
     */
    function swmNeeded(address src20, uint256 srcValue) external view returns (uint256) {
        return _swmNeeded(src20, srcValue);
    }

    /**
     * @dev External function for calculating how much SWM tokens are needed to be staked
     * in order to get 1 SRC20 token
     *
     * @param src20 Address of src20 token contract
     * @return Amount of SWM tokens
     */
    function getSrc20toSwmRatio(address src20) external returns (uint256) {
        uint256 totalSupply = ISRC20(src20).totalSupply();
        return totalSupply.mul(10 ** 18).div(_registry[src20].stake);
    }

    /**
     * @dev External view function to get current SWM stake
     *
     * @param src20 Address of SRC20 token contract
     * @return Current stake in wei SWM tokens
     */
    function getStake(address src20) external view returns (uint256) {
        return _registry[src20].stake;
    }

    /**
     * @dev Get address of token owner
     *
     * @param src20 Address of SRC20 token contract
     * @return Address of token owner
     */
    function getTokenOwner(address src20) external view returns (address) {
        return _registry[src20].owner;
    }

    /**
     * @dev Internal function calculating new SRC20 values based on minted ones. On every
     * new minting of supply new SWM and SRC20 values are saved for further calculations.
     *
     * @param src20 SRC20 token address.
     * @param swmValue SWM stake value.
     * @return Amount of SRC20 tokens.
     */
    function _calcTokens(address src20, uint256 swmValue) internal view returns (uint256) {
        require(src20 != address(0), "Token address is zero");
        require(swmValue != 0, "SWM value is zero");
        require(_registry[src20].owner != address(0), "SRC20 token contract not registered");

        uint256 totalSupply = ISRC20(src20).totalSupply();

        return swmValue.mul(totalSupply).div(_registry[src20].stake);
    }

    function _swmNeeded(address src20, uint256 srcValue) internal view returns (uint256) {
        uint256 totalSupply = ISRC20(src20).totalSupply();

        return srcValue.mul(_registry[src20].stake).div(totalSupply);
    }

    /**
     * @return true if `msg.sender` is the token owner of the registered SRC20 contract.
     */
    function _isTokenOwner(address src20) internal view returns (bool) {
        return msg.sender == _registry[src20].owner;
    }
}

// File: contracts/interfaces/ISRC20Registry.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface for SRC20 Registry contract
 */
contract ISRC20Registry {
    event FactoryAdded(address account);
    event FactoryRemoved(address account);
    event SRC20Registered(address token, address tokenOwner);
    event SRC20Removed(address token);
    event MinterAdded(address minter);
    event MinterRemoved(address minter);

    function put(address token, address roles, address tokenOwner, address minter) external returns (bool);
    function remove(address token) external returns (bool);
    function contains(address token) external view returns (bool);

    function addMinter(address minter) external returns (bool);
    function getMinter(address src20) external view returns (address);
    function removeMinter(address minter) external returns (bool);

    function addFactory(address account) external returns (bool);
    function removeFactory(address account) external returns (bool);
}

// File: contracts/factories/SRC20Registry.sol

pragma solidity ^0.5.0;






/**
 * @dev SRC20 registry contains the address of every created 
 * SRC20 token. Registered factories can add addresses of
 * new tokens, public can query tokens.
 */
contract SRC20Registry is ISRC20Registry, Manager {
    using Roles for Roles.Role;

    Roles.Role private _factories;
    mapping (address => bool) _authorizedMinters;

    /**
     * @dev constructor requiring SWM ERC20 contract address.
     */
    constructor(address swmERC20)
        Manager(swmERC20)
        public
    {
    }

    /**
     * @dev Adds new factory that can register token.
     * Emits FactoryAdded event.
     *
     * @param account The factory contract address.
     * @return True on success.
     */
    function addFactory(address account) external onlyOwner returns (bool) {
        require(account != address(0), "account is zero address");

        _factories.add(account);

        emit FactoryAdded(account);

        return true;
    }

    /**
     * @dev Removes factory that can register token.
     * Emits FactoryRemoved event.
     *
     * @param account The factory contract address.
     * @return True on success.
     */
    function removeFactory(address account) external onlyOwner returns (bool) {
        require(account != address(0), "account is zero address");

        _factories.remove(account);

        emit FactoryRemoved(account);

        return true;
    }

    /**
     * @dev Adds token to registry. Only factories can add.
     * Emits SRC20Registered event.
     *
     * @param token The token address.
     * @param roles roles SRC20Roles contract address.
     * @param tokenOwner Owner of the token.
     * @return True on success.
     */
    function put(address token, address roles, address tokenOwner, address minter) external returns (bool) {
        require(token != address(0), "token is zero address");
        require(roles != address(0), "roles is zero address");
        require(tokenOwner != address(0), "tokenOwner is zero address");
        require(_factories.has(msg.sender), "factory not registered");
        require(_authorizedMinters[minter] == true, 'minter not authorized');

        _registry[token].owner = tokenOwner;
        _registry[token].roles = roles;
        _registry[token].minter = minter;

        emit SRC20Registered(token, tokenOwner);

        return true;
    }

    /**
     * @dev Removes token from registry.
     * Emits SRC20Removed event.
     *
     * @param token The token address.
     * @return True on success.
     */
    function remove(address token) external onlyOwner returns (bool) {
        require(token != address(0), "token is zero address");
        require(_registry[token].owner != address(0), "token not registered");

        delete _registry[token];

        emit SRC20Removed(token);

        return true;
    }

    /**
     * @dev Checks if registry contains token.
     *
     * @param token The token address.
     * @return True if registry contains token.
     */
    function contains(address token) external view returns (bool) {
        return _registry[token].owner != address(0);
    }

    /**
     *  This proxy function adds a contract to the list of authorized minters
     *
     *  @param minter The address of the minter contract to add to the list of authorized minters
     *  @return true on success
     */
    function addMinter(address minter) external onlyOwner returns (bool) {
        require(minter != address(0), "minter is zero address");

        _authorizedMinters[minter] = true;

        emit MinterAdded(minter);

        return true;
    }

    /**
     *  With this function you can fetch address of authorized minter for SRC20.
     *
     *  @param src20 Address of SRC20 token we want to check minters for.
     *  @return address of authorized minter.
     */
    function getMinter(address src20) external view returns (address) {
        return _registry[src20].minter;
    }

    /**
     *  This proxy function removes a contract from the list of authorized minters
     *
     *  @param minter The address of the minter contract to remove from the list of authorized minters
     *  @return true on success
     */
    function removeMinter(address minter) external onlyOwner returns (bool) {
        require(minter != address(0), "minter is zero address");

        _authorizedMinters[minter] = false;

        emit MinterRemoved(minter);

        return true;
    }
}