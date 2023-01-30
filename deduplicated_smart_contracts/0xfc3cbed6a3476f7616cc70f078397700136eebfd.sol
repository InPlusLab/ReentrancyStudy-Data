/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

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

// File: contracts/governance/Governor.sol

pragma solidity 0.5.11;
pragma experimental ABIEncoderV2;



/**
 * @title Governor
 * @dev The Governor holds the rights to stage and execute contract calls i.e. changing Livepeer protocol parameters.
 */
contract Governor {

    using SafeMath for uint256;

    address public owner;

    /// @dev mapping of updateHash (keccak256(update) => executeBlock (block.number + delay)
    mapping(bytes32 => uint256) public updates;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event UpdateStaged(Update update, uint256 delay);

    event UpdateExecuted(Update update);

    event UpdateCancelled(Update update);

    struct Update {
        address[] target;
        uint256[] value;
        bytes[] data;
        uint256 nonce;
    }

   /// @notice Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorized: msg.sender not owner");
        _;
    }


    /// @notice Throws if called by any account other than this contract.
    /// @dev Forces the `stage/execute` path to be used to call functions with this modifier instead of directly.
    modifier onlyThis() {
        require(msg.sender == address(this), "unauthorized: msg.sender not Governor");
        _;
    }


    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    constructor() public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }


    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @dev Can only be called through stage/execute, will revert if the caller is not this contract's address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyThis {
        require(newOwner != address(0), "newOwner is a null address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /// @notice Stage a batch of updates to be executed.
    /// @dev Reverts if the 'msg.sender' is not the 'owner'
    /// @dev Reverts if an update is already staged
    /// @param _update Update to be staged.
    /// @param _delay (uint256) Delay (in number of blocks) for the update.
    function stage(Update memory _update, uint256 _delay) public onlyOwner {
        bytes32 updateHash = keccak256(abi.encode(_update));

        require(updates[updateHash] == 0, "update already staged");

        updates[updateHash] = block.number.add(_delay);

        emit UpdateStaged(_update, _delay);
    }

    /// @notice Execute a staged update.
    /// @dev Updates are authorized during staging.
    /// @dev Reverts if a transaction can not be executed.
    /// @param _update  Update to be staged.
    function execute(Update memory _update) public payable {
        bytes32 updateHash = keccak256(abi.encode(_update));
        uint256 executeBlock = updates[updateHash];

        require(executeBlock != 0, "update is not staged");
        require(block.number >= executeBlock, "delay for update not expired");

        // prevent re-entry and replay
        delete updates[updateHash];
        for (uint256 i = 0; i < _update.target.length; i++) {
            /* solium-disable-next-line */
            (bool success, bytes memory returnData) = _update.target[i].call.value(_update.value[i])(_update.data[i]);
            require(success, string(returnData));
        }

        emit UpdateExecuted(_update);
    }

    /// @notice Cancel a staged update.
    /// @dev Reverts if an update does not exist.
    /// @dev Reverts if the 'msg.sender' is not the 'owner'
    /// @param _update Update to be cancelled.
    function cancel(Update memory _update) public onlyOwner {
        bytes32 updateHash = keccak256(abi.encode(_update));
        uint256 executeBlock = updates[updateHash];

        require(executeBlock != 0, "update is not staged");
        delete updates[updateHash];

        emit UpdateCancelled(_update);
    }
}