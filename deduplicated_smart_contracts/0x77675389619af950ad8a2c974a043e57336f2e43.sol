/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.8;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


contract IssuerRole {
    using Roles for Roles.Role;

    event IssuerAdded(address indexed account);
    event IssuerRemoved(address indexed account);

    Roles.Role private _issuers;

    constructor () internal {
        _addIssuer(msg.sender);
    }

    modifier onlyIssuer() {
        require(isIssuer(msg.sender));
        _;
    }

    function isIssuer(address account) public view returns (bool) {
        return _issuers.has(account);
    }

    function addIssuer(address account) public onlyIssuer {
        _addIssuer(account);
    }

    function renounceIssuer() public {
        _removeIssuer(msg.sender);
    }

    function _addIssuer(address account) internal {
        _issuers.add(account);
        emit IssuerAdded(account);
    }

    function _removeIssuer(address account) internal {
        _issuers.remove(account);
        emit IssuerRemoved(account);
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title interface for unsafe ERC20
 * @dev Unsafe ERC20 does not return when transfer, approve, transferFrom
 */
interface IUnsafeERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external;

  function approve(address spender, uint256 value) external;

  function transferFrom(address from, address to, uint256 value) external;
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}


/**
 * @title Token bank
 */
contract TokenBank is IssuerRole, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // this token bank contract will use this binded ERC20 token
    IERC20 public bindedToken;

    // use deposited[user] to get the deposited ERC20 tokens
    mapping(address => uint256) public deposited;

    event Deposited(
        address indexed depositor,
        address indexed receiver,
        uint256 amount,
        uint256 balance
    );

    event Withdrawn(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 balance
    );

    event InterestIssued(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /**
     * @param token binded ERC20 token
     */
    constructor(address token) public {
        bindedToken = IERC20(token);
    }

    /**
     * @notice deposit ERC20 token to receiver address
     * @param receiver address of who will receive the deposited tokens
     * @param amount amount of ERC20 token to deposit
     */
    function depositTo(address receiver, uint256 amount) external {
        deposited[receiver] = deposited[receiver].add(amount);
        emit Deposited(msg.sender, receiver, amount, deposited[receiver]);
        bindedToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @notice withdraw tokens from token bank to specific receiver
     * @param to withdrawn token transfer to this address
     * @param amount amount of ERC20 token to withdraw
     */
    function withdrawTo(address to, uint256 amount) external {
        deposited[msg.sender] = deposited[msg.sender].sub(amount);
        emit Withdrawn(msg.sender, to, amount, deposited[msg.sender]);
        bindedToken.safeTransfer(to, amount);
    }

    /**
     * @notice bulk issue interests to users
     * @dev addrs[0] receives nums[0] as its interest
     * @param safe whether the paid token is a safe ERC20
     * @param paidToken use the ERC20 token to pay interests
     * @param fromWallet interests will pay from this wallet account
     * @param interests an array of interests
     * @param receivers an array of interest receivers
     */
    function bulkIssueInterests(
        bool safe,
        address paidToken,
        address fromWallet,
        uint256[] calldata interests,
        address[] calldata receivers
    )
        external
        onlyIssuer
    {
        require(
            interests.length == receivers.length,
            "Failed to bulk issue interests due to illegal arguments."
        );

        if (safe) {
            IERC20 token = IERC20(paidToken);
            // issue interests to all receivers
            for (uint256 i = 0; i < receivers.length; i = i.add(1)) {
                emit InterestIssued(
                    paidToken,
                    fromWallet,
                    receivers[i],
                    interests[i]
                );
                token.safeTransferFrom(fromWallet, receivers[i], interests[i]);
            }
        } else {
            IUnsafeERC20 token = IUnsafeERC20(paidToken);
            // issue interests to all receivers
            for (uint256 i = 0; i < receivers.length; i = i.add(1)) {
                emit InterestIssued(
                    paidToken,
                    fromWallet,
                    receivers[i],
                    interests[i]
                );
                token.transferFrom(fromWallet, receivers[i], interests[i]);
            }
        }
    }
}