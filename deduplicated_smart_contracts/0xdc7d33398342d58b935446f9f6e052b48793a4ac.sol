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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

import "./SafeMath.sol";
import "./Owned.sol";
import "./WhiteList.sol";

interface IParams {
    function isLiquidation(uint256 price) external view returns (bool);
}

interface IEsm {
    function shutdown() external;

    function isClosed() external view returns (bool);
}

contract Oracle is Owned, WhiteList {
    using SafeMath for uint256;

    /// @notice Token-usdt price
    uint256 public val;
    /// @notice Price update date(s)
    uint256 public time;

    /// @notice Oracle Name
    bytes32 name;

    /// @notice Oracle update success event
    event OracleUpdate(uint256 val, uint256 time);

    /// @notice Dparam address
    IParams public params;

    /// @notice Esm address
    IEsm public esm;

    /**
     * @notice Construct a new Oracle
     * @param _params Dynamic parameter contract address
     * @param _esm Esm parameter contract address
     */
    constructor(address _params, address _esm) public Owned(msg.sender) {
        params = IParams(_params);
        esm = IEsm(_esm);
        name = "OIN-USDT";
    }

    /**
     * @notice Chain-off push price to chain-on
     * @param price Token-usdt price decimals is same as token
     */
    function poke(uint256 price) public onlyWhiter {
        require(!esm.isClosed(), "System closed yet.");

        val = price;
        time = block.timestamp;

        if (params.isLiquidation(price)) {
            esm.shutdown();
        } else {
            emit OracleUpdate(val, time);
        }
    }

    /**
     * @notice Anybody can read the oracle price
     */
    function peek() public view returns (uint256) {
        return val;
    }
}

pragma solidity ^0.5.16;

// https://docs.synthetix.io/contracts/Owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(
            msg.sender == nominatedOwner,
            "You must be nominated before you can accept ownership"
        );
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only the contract owner may perform this action"
        );
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

import "./Owned.sol";

contract WhiteList is Owned {
    /// @notice Users with permissions
    mapping(address => uint256) public whiter;

    /// @notice Append address into whiteList successevent
    event AppendWhiter(address adder);

    /// @notice Remove address into whiteList successevent
    event RemoveWhiter(address remover);

    /**
     * @notice Construct a new WhiteList, default owner in whiteList
     */
    constructor() internal {
        appendWhiter(owner);
    }

    modifier onlyWhiter() {
        require(isWhiter(), "WhiteList: msg.sender not in whilteList.");
        _;
    }

    /**
     * @notice Only onwer can append address into whitelist
     * @param account The address not added, can added to the whitelist
     */
    function appendWhiter(address account) public onlyOwner {
        require(account != address(0), "WhiteList: address not zero");
        require(
            !isWhiter(account),
            "WhiteListe: the account exsit whilteList yet"
        );
        whiter[account] = 1;
        emit AppendWhiter(account);
    }

    /**
     * @notice Only onwer can remove address into whitelist
     * @param account The address in whitelist yet
     */
    function removeWhiter(address account) public onlyOwner {
        require(
            isWhiter(account),
            "WhiteListe: the account not exist whilteList"
        );
        delete whiter[account];
        emit RemoveWhiter(account);
    }

    /**
     * @notice Check whether acccount in whitelist
     * @param account Any address
     */
    function isWhiter(address account) public view returns (bool) {
        return whiter[account] == 1;
    }

    /**
     * @notice Check whether msg.sender in whitelist overrides.
     */
    function isWhiter() public view returns (bool) {
        return isWhiter(msg.sender);
    }
}

