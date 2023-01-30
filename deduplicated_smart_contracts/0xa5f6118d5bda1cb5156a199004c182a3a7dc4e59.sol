// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./Upgradeable.sol";
import "./Address.sol";


/**
* @notice ERC897 - ERC DelegateProxy
*/
interface ERCProxy {
    function proxyType() external pure returns (uint256);
    function implementation() external view returns (address);
}


/**
* @notice Proxying requests to other contracts.
* Client should use ABI of real contract and address of this contract
*/
contract Dispatcher is Upgradeable, ERCProxy {
    using Address for address;

    event Upgraded(address indexed from, address indexed to, address owner);
    event RolledBack(address indexed from, address indexed to, address owner);

    /**
    * @dev Set upgrading status before and after operations
    */
    modifier upgrading()
    {
        isUpgrade = UPGRADE_TRUE;
        _;
        isUpgrade = UPGRADE_FALSE;
    }

    /**
    * @param _target Target contract address
    */
    constructor(address _target) upgrading {
        require(_target.isContract());
        // Checks that target contract inherits Dispatcher state
        verifyState(_target);
        // `verifyState` must work with its contract
        verifyUpgradeableState(_target, _target);
        target = _target;
        finishUpgrade();
        emit Upgraded(address(0), _target, msg.sender);
    }

    //------------------------ERC897------------------------
    /**
     * @notice ERC897, whether it is a forwarding (1) or an upgradeable (2) proxy
     */
    function proxyType() external pure override returns (uint256) {
        return 2;
    }

    /**
     * @notice ERC897, gets the address of the implementation where every call will be delegated
     */
    function implementation() external view override returns (address) {
        return target;
    }
    //------------------------------------------------------------

    /**
    * @notice Verify new contract storage and upgrade target
    * @param _target New target contract address
    */
    function upgrade(address _target) public onlyOwner upgrading {
        require(_target.isContract());
        // Checks that target contract has "correct" (as much as possible) state layout
        verifyState(_target);
        //`verifyState` must work with its contract
        verifyUpgradeableState(_target, _target);
        if (target.isContract()) {
            verifyUpgradeableState(target, _target);
        }
        previousTarget = target;
        target = _target;
        finishUpgrade();
        emit Upgraded(previousTarget, _target, msg.sender);
    }

    /**
    * @notice Rollback to previous target
    * @dev Test storage carefully before upgrade again after rollback
    */
    function rollback() public onlyOwner upgrading {
        require(previousTarget.isContract());
        emit RolledBack(target, previousTarget, msg.sender);
        // should be always true because layout previousTarget -> target was already checked
        // but `verifyState` is not 100% accurate so check again
        verifyState(previousTarget);
        if (target.isContract()) {
            verifyUpgradeableState(previousTarget, target);
        }
        target = previousTarget;
        previousTarget = address(0);
        finishUpgrade();
    }

    /**
    * @dev Call verifyState method for Upgradeable contract
    */
    function verifyUpgradeableState(address _from, address _to) private {
        (bool callSuccess,) = _from.delegatecall(abi.encodeWithSelector(this.verifyState.selector, _to));
        require(callSuccess);
    }

    /**
    * @dev Call finishUpgrade method from the Upgradeable contract
    */
    function finishUpgrade() private {
        (bool callSuccess,) = target.delegatecall(abi.encodeWithSelector(this.finishUpgrade.selector, target));
        require(callSuccess);
    }

    function verifyState(address _testTarget) public override onlyWhileUpgrading {
        //checks equivalence accessing state through new contract and current storage
        require(address(uint160(delegateGet(_testTarget, this.owner.selector))) == owner());
        require(address(uint160(delegateGet(_testTarget, this.target.selector))) == target);
        require(address(uint160(delegateGet(_testTarget, this.previousTarget.selector))) == previousTarget);
        require(uint8(delegateGet(_testTarget, this.isUpgrade.selector)) == isUpgrade);
    }

    /**
    * @dev Override function using empty code because no reason to call this function in Dispatcher
    */
    function finishUpgrade(address) public override {}

    /**
    * @dev Receive function sends empty request to the target contract
    */
    receive() external payable {
        assert(target.isContract());
        // execute receive function from target contract using storage of the dispatcher
        (bool callSuccess,) = target.delegatecall("");
        if (!callSuccess) {
            revert();
        }
    }

    /**
    * @dev Fallback function sends all requests to the target contract
    */
    fallback() external payable {
        assert(target.isContract());
        // execute requested function from target contract using storage of the dispatcher
        (bool callSuccess,) = target.delegatecall(msg.data);
        if (callSuccess) {
            // copy result of the request to the return data
            // we can use the second return value from `delegatecall` (bytes memory)
            // but it will consume a little more gas
            assembly {
                returndatacopy(0x0, 0x0, returndatasize())
                return(0x0, returndatasize())
            }
        } else {
            revert();
        }
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "./SafeMath.sol";


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public override returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(value == 0 || _allowed[msg.sender][spender] == 0);

        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }

}


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;


import "./ERC20.sol";
import "./SafeMath.sol";


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

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;


/**
 * @title Math
 * @dev Assorted math operations
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
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


/**
 * @title Snapshot
 * @notice Manages snapshots of size 128 bits (32 bits for timestamp, 96 bits for value)
 * 96 bits is enough for storing NU token values, and 32 bits should be OK for block numbers
 * @dev Since each storage slot can hold two snapshots, new slots are allocated every other TX. Thus, gas cost of adding snapshots is 51400 and 36400 gas, alternately.
 * Based on Aragon's Checkpointing (https://https://github.com/aragonone/voting-connectors/blob/master/shared/contract-utils/contracts/Checkpointing.sol)
 * On average, adding snapshots spends ~6500 less gas than the 256-bit checkpoints of Aragon's Checkpointing
 */
library Snapshot {

    function encodeSnapshot(uint32 _time, uint96 _value) internal pure returns(uint128) {
        return uint128(uint256(_time) << 96 | uint256(_value));
    }

    function decodeSnapshot(uint128 _snapshot) internal pure returns(uint32 time, uint96 value){
        time = uint32(bytes4(bytes16(_snapshot)));
        value = uint96(_snapshot);
    }

    function addSnapshot(uint128[] storage _self, uint256 _value) internal {
        addSnapshot(_self, block.number, _value);
    }

    function addSnapshot(uint128[] storage _self, uint256 _time, uint256 _value) internal {
        uint256 length = _self.length;
        if (length != 0) {
            (uint32 currentTime, ) = decodeSnapshot(_self[length - 1]);
            if (uint32(_time) == currentTime) {
                _self[length - 1] = encodeSnapshot(uint32(_time), uint96(_value));
                return;
            } else if (uint32(_time) < currentTime){
                revert();
            }
        }
        _self.push(encodeSnapshot(uint32(_time), uint96(_value)));
    }

    function lastSnapshot(uint128[] storage _self) internal view returns (uint32, uint96) {
        uint256 length = _self.length;
        if (length > 0) {
            return decodeSnapshot(_self[length - 1]);
        }

        return (0, 0);
    }

    function lastValue(uint128[] storage _self) internal view returns (uint96) {
        (, uint96 value) = lastSnapshot(_self);
        return value;
    }

    function getValueAt(uint128[] storage _self, uint256 _time256) internal view returns (uint96) {
        uint32 _time = uint32(_time256);
        uint256 length = _self.length;

        // Short circuit if there's no checkpoints yet
        // Note that this also lets us avoid using SafeMath later on, as we've established that
        // there must be at least one checkpoint
        if (length == 0) {
            return 0;
        }

        // Check last checkpoint
        uint256 lastIndex = length - 1;
        (uint32 snapshotTime, uint96 snapshotValue) = decodeSnapshot(_self[length - 1]);
        if (_time >= snapshotTime) {
            return snapshotValue;
        }

        // Check first checkpoint (if not already checked with the above check on last)
        (snapshotTime, snapshotValue) = decodeSnapshot(_self[0]);
        if (length == 1 || _time < snapshotTime) {
            return 0;
        }

        // Do binary search
        // As we've already checked both ends, we don't need to check the last checkpoint again
        uint256 low = 0;
        uint256 high = lastIndex - 1;
        uint32 midTime;
        uint96 midValue;

        while (high > low) {
            uint256 mid = (high + low + 1) / 2; // average, ceil round
            (midTime, midValue) = decodeSnapshot(_self[mid]);

            if (_time > midTime) {
                low = mid;
            } else if (_time < midTime) {
                // Note that we don't need SafeMath here because mid must always be greater than 0
                // from the while condition
                high = mid - 1;
            } else {
                // _time == midTime
                return midValue;
            }
        }

        (, snapshotValue) = decodeSnapshot(_self[low]);
        return snapshotValue;
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./ERC20.sol";


/**
* @title NuCypher token
* @notice ERC20 token
* @dev Optional approveAndCall() functionality to notify a contract if an approve() has occurred.
*/
contract NuCypherToken is ERC20, ERC20Detailed('NuCypher', 'NU', 18) {

    /**
    * @notice Set amount of tokens
    * @param _totalSupplyOfTokens Total number of tokens
    */
    constructor (uint256 _totalSupplyOfTokens) {
        _mint(msg.sender, _totalSupplyOfTokens);
    }

    /**
    * @notice Approves and then calls the receiving contract
    *
    * @dev call the receiveApproval function on the contract you want to be notified.
    * receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
    */
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData)
        external returns (bool success)
    {
        approve(_spender, _value);
        TokenRecipient(_spender).receiveApproval(msg.sender, _value, address(this), _extraData);
        return true;
    }

}


/**
* @dev Interface to use the receiveApproval method
*/
interface TokenRecipient {

    /**
    * @notice Receives a notification of approval of the transfer
    * @param _from Sender of approval
    * @param _value  The amount of tokens to be spent
    * @param _tokenContract Address of the token contract
    * @param _extraData Extra data
    */
    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes calldata _extraData) external;

}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Math.sol";
import "./Address.sol";
import "./AdditionalMath.sol";
import "./SignatureVerifier.sol";
import "./StakingEscrow.sol";
import "./NuCypherToken.sol";
import "./Upgradeable.sol";


/**
* @notice Contract holds policy data and locks accrued policy fees
* @dev |v6.1.2|
*/
contract PolicyManager is Upgradeable {
    using SafeERC20 for NuCypherToken;
    using SafeMath for uint256;
    using AdditionalMath for uint256;
    using AdditionalMath for int256;
    using AdditionalMath for uint16;
    using Address for address payable;

    event PolicyCreated(
        bytes16 indexed policyId,
        address indexed sponsor,
        address indexed owner,
        uint256 feeRate,
        uint64 startTimestamp,
        uint64 endTimestamp,
        uint256 numberOfNodes
    );
    event ArrangementRevoked(
        bytes16 indexed policyId,
        address indexed sender,
        address indexed node,
        uint256 value
    );
    event RefundForArrangement(
        bytes16 indexed policyId,
        address indexed sender,
        address indexed node,
        uint256 value
    );
    event PolicyRevoked(bytes16 indexed policyId, address indexed sender, uint256 value);
    event RefundForPolicy(bytes16 indexed policyId, address indexed sender, uint256 value);
    event NodeBrokenState(address indexed node, uint16 period);
    event MinFeeRateSet(address indexed node, uint256 value);
    // TODO #1501
    // Range range
    event FeeRateRangeSet(address indexed sender, uint256 min, uint256 defaultValue, uint256 max);
    event Withdrawn(address indexed node, address indexed recipient, uint256 value);

    struct ArrangementInfo {
        address node;
        uint256 indexOfDowntimePeriods;
        uint16 lastRefundedPeriod;
    }

    struct Policy {
        bool disabled;
        address payable sponsor;
        address owner;

        uint128 feeRate;
        uint64 startTimestamp;
        uint64 endTimestamp;

        uint256 reservedSlot1;
        uint256 reservedSlot2;
        uint256 reservedSlot3;
        uint256 reservedSlot4;
        uint256 reservedSlot5;

        ArrangementInfo[] arrangements;
    }

    struct NodeInfo {
        uint128 fee;
        uint16 previousFeePeriod;
        uint256 feeRate;
        uint256 minFeeRate;
        mapping (uint16 => int256) feeDelta;
    }

    // TODO used only for `delegateGetNodeInfo`, probably will be removed after #1512
    struct MemoryNodeInfo {
        uint128 fee;
        uint16 previousFeePeriod;
        uint256 feeRate;
        uint256 minFeeRate;
    }

    struct Range {
        uint128 min;
        uint128 defaultValue;
        uint128 max;
    }

    bytes16 internal constant RESERVED_POLICY_ID = bytes16(0);
    address internal constant RESERVED_NODE = address(0);
    uint256 internal constant MAX_BALANCE = uint256(uint128(0) - 1);
    // controlled overflow to get max int256
    int256 public constant DEFAULT_FEE_DELTA = int256((uint256(0) - 1) >> 1);

    StakingEscrow public immutable escrow;
    uint32 public immutable secondsPerPeriod;

    mapping (bytes16 => Policy) public policies;
    mapping (address => NodeInfo) public nodes;
    Range public feeRateRange;

    /**
    * @notice Constructor sets address of the escrow contract
    * @param _escrow Escrow contract
    */
    constructor(StakingEscrow _escrow) {
        // if the input address is not the StakingEscrow then calling `secondsPerPeriod` will throw error
        uint32 localSecondsPerPeriod = _escrow.secondsPerPeriod();
        require(localSecondsPerPeriod > 0);
        secondsPerPeriod = localSecondsPerPeriod;
        escrow = _escrow;
    }

    /**
    * @dev Checks that sender is the StakingEscrow contract
    */
    modifier onlyEscrowContract()
    {
        require(msg.sender == address(escrow));
        _;
    }

    /**
    * @return Number of current period
    */
    function getCurrentPeriod() public view returns (uint16) {
        return uint16(block.timestamp / secondsPerPeriod);
    }

    /**
    * @notice Register a node
    * @param _node Node address
    * @param _period Initial period
    */
    function register(address _node, uint16 _period) external onlyEscrowContract {
        NodeInfo storage nodeInfo = nodes[_node];
        require(nodeInfo.previousFeePeriod == 0 && _period < getCurrentPeriod());
        nodeInfo.previousFeePeriod = _period;
    }

    /**
    * @notice Set minimum, default & maximum fee rate for all stakers and all policies ('global fee range')
    */
    // TODO # 1501
    // function setFeeRateRange(Range calldata _range) external onlyOwner {
    function setFeeRateRange(uint128 _min, uint128 _default, uint128 _max) external onlyOwner {
        require(_min <= _default && _default <= _max);
        feeRateRange = Range(_min, _default, _max);
        emit FeeRateRangeSet(msg.sender, _min, _default, _max);
    }

    /**
    * @notice Set the minimum acceptable fee rate (set by staker for their associated worker)
    * @dev Input value must fall within `feeRateRange` (global fee range)
    */
    function setMinFeeRate(uint256 _minFeeRate) external {
        require(_minFeeRate >= feeRateRange.min &&
            _minFeeRate <= feeRateRange.max,
            "The staker's min fee rate must fall within the global fee range");
        NodeInfo storage nodeInfo = nodes[msg.sender];
        if (nodeInfo.minFeeRate == _minFeeRate) {
            return;
        }
        nodeInfo.minFeeRate = _minFeeRate;
        emit MinFeeRateSet(msg.sender, _minFeeRate);
    }

    /**
    * @notice Get the minimum acceptable fee rate (set by staker for their associated worker)
    */
    function getMinFeeRate(NodeInfo storage _nodeInfo) internal view returns (uint256) {
        // if minFeeRate has not been set or chosen value falls outside the global fee range
        // a default value is returned instead
        if (_nodeInfo.minFeeRate == 0 ||
            _nodeInfo.minFeeRate < feeRateRange.min ||
            _nodeInfo.minFeeRate > feeRateRange.max) {
            return feeRateRange.defaultValue;
        } else {
            return _nodeInfo.minFeeRate;
        }
    }

    /**
    * @notice Get the minimum acceptable fee rate (set by staker for their associated worker)
    */
    function getMinFeeRate(address _node) public view returns (uint256) {
        NodeInfo storage nodeInfo = nodes[_node];
        return getMinFeeRate(nodeInfo);
    }

    /**
    * @notice Create policy
    * @dev Generate policy id before creation
    * @param _policyId Policy id
    * @param _policyOwner Policy owner. Zero address means sender is owner
    * @param _endTimestamp End timestamp of the policy in seconds
    * @param _nodes Nodes that will handle policy
    */
    function createPolicy(
        bytes16 _policyId,
        address _policyOwner,
        uint64 _endTimestamp,
        address[] calldata _nodes
    )
        external payable
    {
        Policy storage policy = policies[_policyId];
        require(
            _policyId != RESERVED_POLICY_ID &&
            policy.feeRate == 0 &&
            !policy.disabled &&
            _endTimestamp > block.timestamp &&
            msg.value > 0
        );
        require(address(this).balance <= MAX_BALANCE);
        uint16 currentPeriod = getCurrentPeriod();
        uint16 endPeriod = uint16(_endTimestamp / secondsPerPeriod) + 1;
        uint256 numberOfPeriods = endPeriod - currentPeriod;

        policy.sponsor = msg.sender;
        policy.startTimestamp = uint64(block.timestamp);
        policy.endTimestamp = _endTimestamp;
        policy.feeRate = uint128(msg.value.div(_nodes.length) / numberOfPeriods);
        require(policy.feeRate > 0 && policy.feeRate * numberOfPeriods * _nodes.length  == msg.value);
        if (_policyOwner != msg.sender && _policyOwner != address(0)) {
            policy.owner = _policyOwner;
        }

        for (uint256 i = 0; i < _nodes.length; i++) {
            address node = _nodes[i];
            require(node != RESERVED_NODE);
            NodeInfo storage nodeInfo = nodes[node];
            require(nodeInfo.previousFeePeriod != 0 &&
                nodeInfo.previousFeePeriod < currentPeriod &&
                policy.feeRate >= getMinFeeRate(nodeInfo));
            // Check default value for feeDelta
            if (nodeInfo.feeDelta[currentPeriod] == DEFAULT_FEE_DELTA) {
                nodeInfo.feeDelta[currentPeriod] = int256(policy.feeRate);
            } else {
                // Overflow protection removed, because ETH total supply less than uint255/int256
                nodeInfo.feeDelta[currentPeriod] += int256(policy.feeRate);
            }
            if (nodeInfo.feeDelta[endPeriod] == DEFAULT_FEE_DELTA) {
                nodeInfo.feeDelta[endPeriod] = -int256(policy.feeRate);
            } else {
                nodeInfo.feeDelta[endPeriod] -= int256(policy.feeRate);
            }
            // Reset to default value if needed
            if (nodeInfo.feeDelta[currentPeriod] == 0) {
                nodeInfo.feeDelta[currentPeriod] = DEFAULT_FEE_DELTA;
            }
            if (nodeInfo.feeDelta[endPeriod] == 0) {
                nodeInfo.feeDelta[endPeriod] = DEFAULT_FEE_DELTA;
            }
            policy.arrangements.push(ArrangementInfo(node, 0, 0));
        }

        emit PolicyCreated(
            _policyId,
            msg.sender,
            _policyOwner == address(0) ? msg.sender : _policyOwner,
            policy.feeRate,
            policy.startTimestamp,
            policy.endTimestamp,
            _nodes.length
        );
    }

    /**
    * @notice Get policy owner
    */
    function getPolicyOwner(bytes16 _policyId) public view returns (address) {
        Policy storage policy = policies[_policyId];
        return policy.owner == address(0) ? policy.sponsor : policy.owner;
    }

    /**
    * @notice Set default `feeDelta` value for specified period
    * @dev This method increases gas cost for node in trade of decreasing cost for policy sponsor
    * @param _node Node address
    * @param _period Period to set
    */
    function setDefaultFeeDelta(address _node, uint16 _period) external onlyEscrowContract {
        NodeInfo storage node = nodes[_node];
        if (node.feeDelta[_period] == 0) {
            node.feeDelta[_period] = DEFAULT_FEE_DELTA;
        }
    }

    /**
    * @notice Update node fee
    * @param _node Node address
    * @param _period Processed period
    */
    function updateFee(address _node, uint16 _period) external onlyEscrowContract {
        NodeInfo storage node = nodes[_node];
        if (node.previousFeePeriod == 0 || _period <= node.previousFeePeriod) {
            return;
        }
        for (uint16 i = node.previousFeePeriod + 1; i <= _period; i++) {
            int256 delta = node.feeDelta[i];
            if (delta == DEFAULT_FEE_DELTA) {
                // gas refund
                node.feeDelta[i] = 0;
                continue;
            }

            // broken state
            if (delta < 0 && uint256(-delta) > node.feeRate) {
                node.feeDelta[i] += int256(node.feeRate);
                node.feeRate = 0;
                emit NodeBrokenState(_node, _period);
            // good state
            } else {
                node.feeRate = node.feeRate.addSigned(delta);
                // gas refund
                node.feeDelta[i] = 0;
            }
        }
        node.previousFeePeriod = _period;
        node.fee += uint128(node.feeRate);
    }

    /**
    * @notice Withdraw fee by node
    */
    function withdraw() external returns (uint256) {
        return withdraw(msg.sender);
    }

    /**
    * @notice Withdraw fee by node
    * @param _recipient Recipient of the fee
    */
    function withdraw(address payable _recipient) public returns (uint256) {
        NodeInfo storage node = nodes[msg.sender];
        uint256 fee = node.fee;
        require(fee != 0);
        node.fee = 0;
        _recipient.sendValue(fee);
        emit Withdrawn(msg.sender, _recipient, fee);
        return fee;
    }

    /**
    * @notice Calculate amount of refund
    * @param _policy Policy
    * @param _arrangement Arrangement
    */
    function calculateRefundValue(Policy storage _policy, ArrangementInfo storage _arrangement)
        internal view returns (uint256 refundValue, uint256 indexOfDowntimePeriods, uint16 lastRefundedPeriod)
    {
        uint16 policyStartPeriod = uint16(_policy.startTimestamp / secondsPerPeriod);
        uint16 maxPeriod = AdditionalMath.min16(getCurrentPeriod(), uint16(_policy.endTimestamp / secondsPerPeriod));
        uint16 minPeriod = AdditionalMath.max16(policyStartPeriod, _arrangement.lastRefundedPeriod);
        uint16 downtimePeriods = 0;
        uint256 length = escrow.getPastDowntimeLength(_arrangement.node);
        uint256 initialIndexOfDowntimePeriods;
        if (_arrangement.lastRefundedPeriod == 0) {
            initialIndexOfDowntimePeriods = escrow.findIndexOfPastDowntime(_arrangement.node, policyStartPeriod);
        } else {
            initialIndexOfDowntimePeriods = _arrangement.indexOfDowntimePeriods;
        }

        for (indexOfDowntimePeriods = initialIndexOfDowntimePeriods;
             indexOfDowntimePeriods < length;
             indexOfDowntimePeriods++)
        {
            (uint16 startPeriod, uint16 endPeriod) =
                escrow.getPastDowntime(_arrangement.node, indexOfDowntimePeriods);
            if (startPeriod > maxPeriod) {
                break;
            } else if (endPeriod < minPeriod) {
                continue;
            }
            downtimePeriods += AdditionalMath.min16(maxPeriod, endPeriod)
                .sub16(AdditionalMath.max16(minPeriod, startPeriod)) + 1;
            if (maxPeriod <= endPeriod) {
                break;
            }
        }

        uint16 lastCommittedPeriod = escrow.getLastCommittedPeriod(_arrangement.node);
        if (indexOfDowntimePeriods == length && lastCommittedPeriod < maxPeriod) {
            // Overflow protection removed:
            // lastCommittedPeriod < maxPeriod and minPeriod <= maxPeriod + 1
            downtimePeriods += maxPeriod - AdditionalMath.max16(minPeriod - 1, lastCommittedPeriod);
        }

        refundValue = _policy.feeRate * downtimePeriods;
        lastRefundedPeriod = maxPeriod + 1;
    }

    /**
    * @notice Revoke/refund arrangement/policy by the sponsor
    * @param _policyId Policy id
    * @param _node Node that will be excluded or RESERVED_NODE if full policy should be used
    ( @param _forceRevoke Force revoke arrangement/policy
    */
    function refundInternal(bytes16 _policyId, address _node, bool _forceRevoke)
        internal returns (uint256 refundValue)
    {
        refundValue = 0;
        Policy storage policy = policies[_policyId];
        require(!policy.disabled);
        uint16 endPeriod = uint16(policy.endTimestamp / secondsPerPeriod) + 1;
        uint256 numberOfActive = policy.arrangements.length;
        uint256 i = 0;
        for (; i < policy.arrangements.length; i++) {
            ArrangementInfo storage arrangement = policy.arrangements[i];
            address node = arrangement.node;
            if (node == RESERVED_NODE || _node != RESERVED_NODE && _node != node) {
                numberOfActive--;
                continue;
            }
            uint256 nodeRefundValue;
            (nodeRefundValue, arrangement.indexOfDowntimePeriods, arrangement.lastRefundedPeriod) =
                calculateRefundValue(policy, arrangement);
            if (_forceRevoke) {
                NodeInfo storage nodeInfo = nodes[node];

                // Check default value for feeDelta
                uint16 lastRefundedPeriod = arrangement.lastRefundedPeriod;
                if (nodeInfo.feeDelta[lastRefundedPeriod] == DEFAULT_FEE_DELTA) {
                    nodeInfo.feeDelta[lastRefundedPeriod] = -int256(policy.feeRate);
                } else {
                    nodeInfo.feeDelta[lastRefundedPeriod] -= int256(policy.feeRate);
                }
                if (nodeInfo.feeDelta[endPeriod] == DEFAULT_FEE_DELTA) {
                    nodeInfo.feeDelta[endPeriod] = -int256(policy.feeRate);
                } else {
                    nodeInfo.feeDelta[endPeriod] += int256(policy.feeRate);
                }

                // Reset to default value if needed
                if (nodeInfo.feeDelta[lastRefundedPeriod] == 0) {
                    nodeInfo.feeDelta[lastRefundedPeriod] = DEFAULT_FEE_DELTA;
                }
                if (nodeInfo.feeDelta[endPeriod] == 0) {
                    nodeInfo.feeDelta[endPeriod] = DEFAULT_FEE_DELTA;
                }
                nodeRefundValue += uint256(endPeriod - lastRefundedPeriod) * policy.feeRate;
            }
            if (_forceRevoke || arrangement.lastRefundedPeriod >= endPeriod) {
                arrangement.node = RESERVED_NODE;
                arrangement.indexOfDowntimePeriods = 0;
                arrangement.lastRefundedPeriod = 0;
                numberOfActive--;
                emit ArrangementRevoked(_policyId, msg.sender, node, nodeRefundValue);
            } else {
                emit RefundForArrangement(_policyId, msg.sender, node, nodeRefundValue);
            }

            refundValue += nodeRefundValue;
            if (_node != RESERVED_NODE) {
               break;
            }
        }
        address payable policySponsor = policy.sponsor;
        if (_node == RESERVED_NODE) {
            if (numberOfActive == 0) {
                policy.disabled = true;
                // gas refund
                policy.sponsor = address(0);
                policy.owner = address(0);
                policy.feeRate = 0;
                policy.startTimestamp = 0;
                policy.endTimestamp = 0;
                emit PolicyRevoked(_policyId, msg.sender, refundValue);
            } else {
                emit RefundForPolicy(_policyId, msg.sender, refundValue);
            }
        } else {
            // arrangement not found
            require(i < policy.arrangements.length);
        }
        if (refundValue > 0) {
            policySponsor.sendValue(refundValue);
        }
    }

    /**
    * @notice Calculate amount of refund
    * @param _policyId Policy id
    * @param _node Node or RESERVED_NODE if all nodes should be used
    */
    function calculateRefundValueInternal(bytes16 _policyId, address _node)
        internal view returns (uint256 refundValue)
    {
        refundValue = 0;
        Policy storage policy = policies[_policyId];
        require((policy.owner == msg.sender || policy.sponsor == msg.sender) && !policy.disabled);
        uint256 i = 0;
        for (; i < policy.arrangements.length; i++) {
            ArrangementInfo storage arrangement = policy.arrangements[i];
            if (arrangement.node == RESERVED_NODE || _node != RESERVED_NODE && _node != arrangement.node) {
                continue;
            }
            (uint256 nodeRefundValue,,) = calculateRefundValue(policy, arrangement);
            refundValue += nodeRefundValue;
            if (_node != RESERVED_NODE) {
               break;
            }
        }
        if (_node != RESERVED_NODE) {
            // arrangement not found
            require(i < policy.arrangements.length);
        }
    }

    /**
    * @notice Revoke policy by the sponsor
    * @param _policyId Policy id
    */
    function revokePolicy(bytes16 _policyId) external returns (uint256 refundValue) {
        require(getPolicyOwner(_policyId) == msg.sender);
        return refundInternal(_policyId, RESERVED_NODE, true);
    }

    /**
    * @notice Revoke arrangement by the sponsor
    * @param _policyId Policy id
    * @param _node Node that will be excluded
    */
    function revokeArrangement(bytes16 _policyId, address _node)
        external returns (uint256 refundValue)
    {
        require(_node != RESERVED_NODE);
        require(getPolicyOwner(_policyId) == msg.sender);
        return refundInternal(_policyId, _node, true);
    }

    /**
    * @notice Get unsigned hash for revocation
    * @param _policyId Policy id
    * @param _node Node that will be excluded
    * @return Revocation hash, EIP191 version 0x45 ('E')
    */
    function getRevocationHash(bytes16 _policyId, address _node) public view returns (bytes32) {
        return SignatureVerifier.hashEIP191(abi.encodePacked(_policyId, _node), byte(0x45));
    }

    /**
    * @notice Check correctness of signature
    * @param _policyId Policy id
    * @param _node Node that will be excluded, zero address if whole policy will be revoked
    * @param _signature Signature of owner
    */
    function checkOwnerSignature(bytes16 _policyId, address _node, bytes memory _signature) internal view {
        bytes32 hash = getRevocationHash(_policyId, _node);
        address recovered = SignatureVerifier.recover(hash, _signature);
        require(getPolicyOwner(_policyId) == recovered);
    }

    /**
    * @notice Revoke policy or arrangement using owner's signature
    * @param _policyId Policy id
    * @param _node Node that will be excluded, zero address if whole policy will be revoked
    * @param _signature Signature of owner, EIP191 version 0x45 ('E')
    */
    function revoke(bytes16 _policyId, address _node, bytes calldata _signature)
        external returns (uint256 refundValue)
    {
        checkOwnerSignature(_policyId, _node, _signature);
        return refundInternal(_policyId, _node, true);
    }

    /**
    * @notice Refund part of fee by the sponsor
    * @param _policyId Policy id
    */
    function refund(bytes16 _policyId) external {
        Policy storage policy = policies[_policyId];
        require(policy.owner == msg.sender || policy.sponsor == msg.sender);
        refundInternal(_policyId, RESERVED_NODE, false);
    }

    /**
    * @notice Refund part of one node's fee by the sponsor
    * @param _policyId Policy id
    * @param _node Node address
    */
    function refund(bytes16 _policyId, address _node)
        external returns (uint256 refundValue)
    {
        require(_node != RESERVED_NODE);
        Policy storage policy = policies[_policyId];
        require(policy.owner == msg.sender || policy.sponsor == msg.sender);
        return refundInternal(_policyId, _node, false);
    }

    /**
    * @notice Calculate amount of refund
    * @param _policyId Policy id
    */
    function calculateRefundValue(bytes16 _policyId)
        external view returns (uint256 refundValue)
    {
        return calculateRefundValueInternal(_policyId, RESERVED_NODE);
    }

    /**
    * @notice Calculate amount of refund
    * @param _policyId Policy id
    * @param _node Node
    */
    function calculateRefundValue(bytes16 _policyId, address _node)
        external view returns (uint256 refundValue)
    {
        require(_node != RESERVED_NODE);
        return calculateRefundValueInternal(_policyId, _node);
    }

    /**
    * @notice Get number of arrangements in the policy
    * @param _policyId Policy id
    */
    function getArrangementsLength(bytes16 _policyId) external view returns (uint256) {
        return policies[_policyId].arrangements.length;
    }

    /**
    * @notice Get information about staker's fee rate
    * @param _node Address of staker
    * @param _period Period to get fee delta
    */
    function getNodeFeeDelta(address _node, uint16 _period)
        // TODO "virtual" only for tests, probably will be removed after #1512
        external view virtual returns (int256)
    {
        return nodes[_node].feeDelta[_period];
    }

    /**
    * @notice Return the information about arrangement
    */
    function getArrangementInfo(bytes16 _policyId, uint256 _index)
    // TODO change to structure when ABIEncoderV2 is released (#1501)
//        public view returns (ArrangementInfo)
        external view returns (address node, uint256 indexOfDowntimePeriods, uint16 lastRefundedPeriod)
    {
        ArrangementInfo storage info = policies[_policyId].arrangements[_index];
        node = info.node;
        indexOfDowntimePeriods = info.indexOfDowntimePeriods;
        lastRefundedPeriod = info.lastRefundedPeriod;
    }


    /**
    * @dev Get Policy structure by delegatecall
    */
    function delegateGetPolicy(address _target, bytes16 _policyId)
        internal returns (Policy memory result)
    {
        bytes32 memoryAddress = delegateGetData(_target, this.policies.selector, 1, bytes32(_policyId), 0);
        assembly {
            result := memoryAddress
        }
    }

    /**
    * @dev Get ArrangementInfo structure by delegatecall
    */
    function delegateGetArrangementInfo(address _target, bytes16 _policyId, uint256 _index)
        internal returns (ArrangementInfo memory result)
    {
        bytes32 memoryAddress = delegateGetData(
            _target, this.getArrangementInfo.selector, 2, bytes32(_policyId), bytes32(_index));
        assembly {
            result := memoryAddress
        }
    }

    /**
    * @dev Get NodeInfo structure by delegatecall
    */
    function delegateGetNodeInfo(address _target, address _node)
        internal returns (MemoryNodeInfo memory result)
    {
        bytes32 memoryAddress = delegateGetData(_target, this.nodes.selector, 1, bytes32(uint256(_node)), 0);
        assembly {
            result := memoryAddress
        }
    }

    /**
    * @dev Get feeRateRange structure by delegatecall
    */
    function delegateGetFeeRateRange(address _target) internal returns (Range memory result) {
        bytes32 memoryAddress = delegateGetData(_target, this.feeRateRange.selector, 0, 0, 0);
        assembly {
            result := memoryAddress
        }
    }

    /// @dev the `onlyWhileUpgrading` modifier works through a call to the parent `verifyState`
    function verifyState(address _testTarget) public override virtual {
        super.verifyState(_testTarget);
        Range memory rangeToCheck = delegateGetFeeRateRange(_testTarget);
        require(feeRateRange.min == rangeToCheck.min &&
            feeRateRange.defaultValue == rangeToCheck.defaultValue &&
            feeRateRange.max == rangeToCheck.max);
        Policy storage policy = policies[RESERVED_POLICY_ID];
        Policy memory policyToCheck = delegateGetPolicy(_testTarget, RESERVED_POLICY_ID);
        require(policyToCheck.sponsor == policy.sponsor &&
            policyToCheck.owner == policy.owner &&
            policyToCheck.feeRate == policy.feeRate &&
            policyToCheck.startTimestamp == policy.startTimestamp &&
            policyToCheck.endTimestamp == policy.endTimestamp &&
            policyToCheck.disabled == policy.disabled);

        require(delegateGet(_testTarget, this.getArrangementsLength.selector, RESERVED_POLICY_ID) ==
            policy.arrangements.length);
        if (policy.arrangements.length > 0) {
            ArrangementInfo storage arrangement = policy.arrangements[0];
            ArrangementInfo memory arrangementToCheck = delegateGetArrangementInfo(
                _testTarget, RESERVED_POLICY_ID, 0);
            require(arrangementToCheck.node == arrangement.node &&
                arrangementToCheck.indexOfDowntimePeriods == arrangement.indexOfDowntimePeriods &&
                arrangementToCheck.lastRefundedPeriod == arrangement.lastRefundedPeriod);
        }

        NodeInfo storage nodeInfo = nodes[RESERVED_NODE];
        MemoryNodeInfo memory nodeInfoToCheck = delegateGetNodeInfo(_testTarget, RESERVED_NODE);
        require(nodeInfoToCheck.fee == nodeInfo.fee &&
            nodeInfoToCheck.feeRate == nodeInfo.feeRate &&
            nodeInfoToCheck.previousFeePeriod == nodeInfo.previousFeePeriod &&
            nodeInfoToCheck.minFeeRate == nodeInfo.minFeeRate);

        require(int256(delegateGet(_testTarget, this.getNodeFeeDelta.selector,
            bytes32(bytes20(RESERVED_NODE)), bytes32(uint256(11)))) == nodeInfo.feeDelta[11]);
    }

    /// @dev the `onlyWhileUpgrading` modifier works through a call to the parent `finishUpgrade`
    function finishUpgrade(address _target) public override virtual {
        super.finishUpgrade(_target);
        // Create fake Policy and NodeInfo to use them in verifyState(address)
        Policy storage policy = policies[RESERVED_POLICY_ID];
        policy.sponsor = msg.sender;
        policy.owner = address(this);
        policy.startTimestamp = 1;
        policy.endTimestamp = 2;
        policy.feeRate = 3;
        policy.disabled = true;
        policy.arrangements.push(ArrangementInfo(RESERVED_NODE, 11, 22));
        NodeInfo storage nodeInfo = nodes[RESERVED_NODE];
        nodeInfo.fee = 100;
        nodeInfo.feeRate = 33;
        nodeInfo.previousFeePeriod = 44;
        nodeInfo.feeDelta[11] = 55;
        nodeInfo.minFeeRate = 777;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.7.0;


// Minimum interface to interact with Aragon's Aggregator
interface IERC900History {
    function totalStakedForAt(address addr, uint256 blockNumber) external view returns (uint256);
    function totalStakedAt(uint256 blockNumber) external view returns (uint256);
    function supportsHistory() external pure returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;


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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


/**
* @notice Library to recover address and verify signatures
* @dev Simple wrapper for `ecrecover`
*/
library SignatureVerifier {

    enum HashAlgorithm {KECCAK256, SHA256, RIPEMD160}

    // Header for Version E as defined by EIP191. First byte ('E') is also the version
    bytes25 constant EIP191_VERSION_E_HEADER = "Ethereum Signed Message:\n";

    /**
    * @notice Recover signer address from hash and signature
    * @param _hash 32 bytes message hash
    * @param _signature Signature of hash - 32 bytes r + 32 bytes s + 1 byte v (could be 0, 1, 27, 28)
    */
    function recover(bytes32 _hash, bytes memory _signature)
        internal
        pure
        returns (address)
    {
        require(_signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);
        return ecrecover(_hash, v, r, s);
    }

    /**
    * @notice Transform public key to address
    * @param _publicKey secp256k1 public key
    */
    function toAddress(bytes memory _publicKey) internal pure returns (address) {
        return address(uint160(uint256(keccak256(_publicKey))));
    }

    /**
    * @notice Hash using one of pre built hashing algorithm
    * @param _message Signed message
    * @param _algorithm Hashing algorithm
    */
    function hash(bytes memory _message, HashAlgorithm _algorithm)
        internal
        pure
        returns (bytes32 result)
    {
        if (_algorithm == HashAlgorithm.KECCAK256) {
            result = keccak256(_message);
        } else if (_algorithm == HashAlgorithm.SHA256) {
            result = sha256(_message);
        } else {
            result = ripemd160(_message);
        }
    }

    /**
    * @notice Verify ECDSA signature
    * @dev Uses one of pre built hashing algorithm
    * @param _message Signed message
    * @param _signature Signature of message hash
    * @param _publicKey secp256k1 public key in uncompressed format without prefix byte (64 bytes)
    * @param _algorithm Hashing algorithm
    */
    function verify(
        bytes memory _message,
        bytes memory _signature,
        bytes memory _publicKey,
        HashAlgorithm _algorithm
    )
        internal
        pure
        returns (bool)
    {
        require(_publicKey.length == 64);
        return toAddress(_publicKey) == recover(hash(_message, _algorithm), _signature);
    }

    /**
    * @notice Hash message according to EIP191 signature specification
    * @dev It always assumes Keccak256 is used as hashing algorithm
    * @dev Only supports version 0 and version E (0x45)
    * @param _message Message to sign
    * @param _version EIP191 version to use
    */
    function hashEIP191(
        bytes memory _message,
        byte _version
    )
        internal
        view
        returns (bytes32 result)
    {
        if(_version == byte(0x00)){  // Version 0: Data with intended validator
            address validator = address(this);
            return keccak256(abi.encodePacked(byte(0x19), byte(0x00), validator, _message));
        } else if (_version == byte(0x45)){  // Version E: personal_sign messages
            uint256 length = _message.length;
            require(length > 0, "Empty message not allowed for version E");

            // Compute text-encoded length of message
            uint256 digits = 0;
            while (length != 0) {
                digits++;
                length /= 10;
            }
            bytes memory lengthAsText = new bytes(digits);
            length = _message.length;
            uint256 index = digits - 1;
            while (length != 0) {
                lengthAsText[index--] = byte(uint8(48 + length % 10));
                length /= 10;
            }

            return keccak256(abi.encodePacked(byte(0x19), EIP191_VERSION_E_HEADER, lengthAsText, _message));
        } else {
            revert("Unsupported EIP191 version");
        }
    }

    /**
    * @notice Verify EIP191 signature
    * @dev It always assumes Keccak256 is used as hashing algorithm
    * @dev Only supports version 0 and version E (0x45)
    * @param _message Signed message
    * @param _signature Signature of message hash
    * @param _publicKey secp256k1 public key in uncompressed format without prefix byte (64 bytes)
    * @param _version EIP191 version to use
    */
    function verifyEIP191(
        bytes memory _message,
        bytes memory _signature,
        bytes memory _publicKey,
        byte _version
    )
        internal
        view
        returns (bool)
    {
        require(_publicKey.length == 64);
        return toAddress(_publicKey) == recover(hashEIP191(_message, _version), _signature);
    }

}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;

/**
* @dev Taken from https://github.com/ethereum/solidity-examples/blob/master/src/bits/Bits.sol
*/
library Bits {

    uint256 internal constant ONE = uint256(1);

    /**
    * @notice Sets the bit at the given 'index' in 'self' to:
    *  '1' - if the bit is '0'
    *  '0' - if the bit is '1'
    * @return The modified value
    */
    function toggleBit(uint256 self, uint8 index) internal pure returns (uint256) {
        return self ^ ONE << index;
    }

    /**
    * @notice Get the value of the bit at the given 'index' in 'self'.
    */
    function bit(uint256 self, uint8 index) internal pure returns (uint8) {
        return uint8(self >> index & 1);
    }

    /**
    * @notice Check if the bit at the given 'index' in 'self' is set.
    * @return  'true' - if the value of the bit is '1',
    *          'false' - if the value of the bit is '0'
    */
    function bitSet(uint256 self, uint8 index) internal pure returns (bool) {
        return self >> index & 1 == 1;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () {
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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./Ownable.sol";


/**
* @notice Base contract for upgradeable contract
* @dev Inherited contract should implement verifyState(address) method by checking storage variables
* (see verifyState(address) in Dispatcher). Also contract should implement finishUpgrade(address)
* if it is using constructor parameters by coping this parameters to the dispatcher storage
*/
abstract contract Upgradeable is Ownable {

    event StateVerified(address indexed testTarget, address sender);
    event UpgradeFinished(address indexed target, address sender);

    /**
    * @dev Contracts at the target must reserve the same location in storage for this address as in Dispatcher
    * Stored data actually lives in the Dispatcher
    * However the storage layout is specified here in the implementing contracts
    */
    address public target;

    /**
    * @dev Previous contract address (if available). Used for rollback
    */
    address public previousTarget;

    /**
    * @dev Upgrade status. Explicit `uint8` type is used instead of `bool` to save gas by excluding 0 value
    */
    uint8 public isUpgrade;

    /**
    * @dev Guarantees that next slot will be separated from the previous
    */
    uint256 stubSlot;

    /**
    * @dev Constants for `isUpgrade` field
    */
    uint8 constant UPGRADE_FALSE = 1;
    uint8 constant UPGRADE_TRUE = 2;

    /**
    * @dev Checks that function executed while upgrading
    * Recommended to add to `verifyState` and `finishUpgrade` methods
    */
    modifier onlyWhileUpgrading()
    {
        require(isUpgrade == UPGRADE_TRUE);
        _;
    }

    /**
    * @dev Method for verifying storage state.
    * Should check that new target contract returns right storage value
    */
    function verifyState(address _testTarget) public virtual onlyWhileUpgrading {
        emit StateVerified(_testTarget, msg.sender);
    }

    /**
    * @dev Copy values from the new target to the current storage
    * @param _target New target contract address
    */
    function finishUpgrade(address _target) public virtual onlyWhileUpgrading {
        emit UpgradeFinished(_target, msg.sender);
    }

    /**
    * @dev Base method to get data
    * @param _target Target to call
    * @param _selector Method selector
    * @param _numberOfArguments Number of used arguments
    * @param _argument1 First method argument
    * @param _argument2 Second method argument
    * @return memoryAddress Address in memory where the data is located
    */
    function delegateGetData(
        address _target,
        bytes4 _selector,
        uint8 _numberOfArguments,
        bytes32 _argument1,
        bytes32 _argument2
    )
        internal returns (bytes32 memoryAddress)
    {
        assembly {
            memoryAddress := mload(0x40)
            mstore(memoryAddress, _selector)
            if gt(_numberOfArguments, 0) {
                mstore(add(memoryAddress, 0x04), _argument1)
            }
            if gt(_numberOfArguments, 1) {
                mstore(add(memoryAddress, 0x24), _argument2)
            }
            switch delegatecall(gas(), _target, memoryAddress, add(0x04, mul(0x20, _numberOfArguments)), 0, 0)
                case 0 {
                    revert(memoryAddress, 0)
                }
                default {
                    returndatacopy(memoryAddress, 0x0, returndatasize())
                }
        }
    }

    /**
    * @dev Call "getter" without parameters.
    * Result should not exceed 32 bytes
    */
    function delegateGet(address _target, bytes4 _selector)
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 0, 0, 0);
        assembly {
            result := mload(memoryAddress)
        }
    }

    /**
    * @dev Call "getter" with one parameter.
    * Result should not exceed 32 bytes
    */
    function delegateGet(address _target, bytes4 _selector, bytes32 _argument)
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 1, _argument, 0);
        assembly {
            result := mload(memoryAddress)
        }
    }

    /**
    * @dev Call "getter" with two parameters.
    * Result should not exceed 32 bytes
    */
    function delegateGet(
        address _target,
        bytes4 _selector,
        bytes32 _argument1,
        bytes32 _argument2
    )
        internal returns (uint256 result)
    {
        bytes32 memoryAddress = delegateGetData(_target, _selector, 2, _argument1, _argument2);
        assembly {
            result := mload(memoryAddress)
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./IERC900History.sol";
import "./Issuer.sol";
import "./Bits.sol";
import "./Snapshot.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";


/**
* @notice PolicyManager interface
*/
interface PolicyManagerInterface {
    function register(address _node, uint16 _period) external;
    function updateFee(address _node, uint16 _period) external;
    function escrow() external view returns (address);
    function setDefaultFeeDelta(address _node, uint16 _period) external;
}


/**
* @notice Adjudicator interface
*/
interface AdjudicatorInterface {
    function escrow() external view returns (address);
}


/**
* @notice WorkLock interface
*/
interface WorkLockInterface {
    function escrow() external view returns (address);
}


/**
* @notice Contract holds and locks stakers tokens.
* Each staker that locks their tokens will receive some compensation
* @dev |v5.3.1|
*/
contract StakingEscrow is Issuer, IERC900History {

    using AdditionalMath for uint256;
    using AdditionalMath for uint16;
    using Bits for uint256;
    using SafeMath for uint256;
    using Snapshot for uint128[];
    using SafeERC20 for NuCypherToken;

    event Deposited(address indexed staker, uint256 value, uint16 periods);
    event Locked(address indexed staker, uint256 value, uint16 firstPeriod, uint16 periods);
    event Divided(
        address indexed staker,
        uint256 oldValue,
        uint16 lastPeriod,
        uint256 newValue,
        uint16 periods
    );
    event Merged(address indexed staker, uint256 value1, uint256 value2, uint16 lastPeriod);
    event Prolonged(address indexed staker, uint256 value, uint16 lastPeriod, uint16 periods);
    event Withdrawn(address indexed staker, uint256 value);
    event CommitmentMade(address indexed staker, uint16 indexed period, uint256 value);
    event Minted(address indexed staker, uint16 indexed period, uint256 value);
    event Slashed(address indexed staker, uint256 penalty, address indexed investigator, uint256 reward);
    event ReStakeSet(address indexed staker, bool reStake);
    event ReStakeLocked(address indexed staker, uint16 lockUntilPeriod);
    event WorkerBonded(address indexed staker, address indexed worker, uint16 indexed startPeriod);
    event WorkMeasurementSet(address indexed staker, bool measureWork);
    event WindDownSet(address indexed staker, bool windDown);
    event SnapshotSet(address indexed staker, bool snapshotsEnabled);

    struct SubStakeInfo {
        uint16 firstPeriod;
        uint16 lastPeriod;
        uint16 periods;
        uint128 lockedValue;
    }

    struct Downtime {
        uint16 startPeriod;
        uint16 endPeriod;
    }

    struct StakerInfo {
        uint256 value;
        /*
        * Stores periods that are committed but not yet rewarded.
        * In order to optimize storage, only two values are used instead of an array.
        * commitToNextPeriod() method invokes mint() method so there can only be two committed
        * periods that are not yet rewarded: the current and the next periods.
        */
        uint16 currentCommittedPeriod;
        uint16 nextCommittedPeriod;
        uint16 lastCommittedPeriod;
        uint16 lockReStakeUntilPeriod;
        uint256 completedWork;
        uint16 workerStartPeriod; // period when worker was bonded
        address worker;
        uint256 flags; // uint256 to acquire whole slot and minimize operations on it

        uint256 reservedSlot1;
        uint256 reservedSlot2;
        uint256 reservedSlot3;
        uint256 reservedSlot4;
        uint256 reservedSlot5;

        Downtime[] pastDowntime;
        SubStakeInfo[] subStakes;
        uint128[] history;

    }

    // used only for upgrading
    uint16 internal constant RESERVED_PERIOD = 0;
    uint16 internal constant MAX_CHECKED_VALUES = 5;
    // to prevent high gas consumption in loops for slashing
    uint16 public constant MAX_SUB_STAKES = 30;
    uint16 internal constant MAX_UINT16 = 65535;

    // indices for flags
    uint8 internal constant RE_STAKE_DISABLED_INDEX = 0;
    uint8 internal constant WIND_DOWN_INDEX = 1;
    uint8 internal constant MEASURE_WORK_INDEX = 2;
    uint8 internal constant SNAPSHOTS_DISABLED_INDEX = 3;

    uint16 public immutable minLockedPeriods;
    uint16 public immutable minWorkerPeriods;
    uint256 public immutable minAllowableLockedTokens;
    uint256 public immutable maxAllowableLockedTokens;
    bool public immutable isTestContract;

    mapping (address => StakerInfo) public stakerInfo;
    address[] public stakers;
    mapping (address => address) public stakerFromWorker;

    mapping (uint16 => uint256) public lockedPerPeriod;
    uint128[] public balanceHistory;

    PolicyManagerInterface public policyManager;
    AdjudicatorInterface public adjudicator;
    WorkLockInterface public workLock;

    /**
    * @notice Constructor sets address of token contract and coefficients for minting
    * @param _token Token contract
    * @param _hoursPerPeriod Size of period in hours
    * @param _issuanceDecayCoefficient (d) Coefficient which modifies the rate at which the maximum issuance decays,
    * only applicable to Phase 2. d = 365 * half-life / LOG2 where default half-life = 2.
    * See Equation 10 in Staking Protocol & Economics paper
    * @param _lockDurationCoefficient1 (k1) Numerator of the coefficient which modifies the extent
    * to which a stake's lock duration affects the subsidy it receives. Affects stakers differently.
    * Applicable to Phase 1 and Phase 2. k1 = k2 * small_stake_multiplier where default small_stake_multiplier = 0.5.
    * See Equation 8 in Staking Protocol & Economics paper.
    * @param _lockDurationCoefficient2 (k2) Denominator of the coefficient which modifies the extent
    * to which a stake's lock duration affects the subsidy it receives. Affects stakers differently.
    * Applicable to Phase 1 and Phase 2. k2 = maximum_rewarded_periods / (1 - small_stake_multiplier)
    * where default maximum_rewarded_periods = 365 and default small_stake_multiplier = 0.5.
    * See Equation 8 in Staking Protocol & Economics paper.
    * @param _maximumRewardedPeriods (kmax) Number of periods beyond which a stake's lock duration
    * no longer increases the subsidy it receives. kmax = reward_saturation * 365 where default reward_saturation = 1.
    * See Equation 8 in Staking Protocol & Economics paper.
    * @param _firstPhaseTotalSupply Total supply for the first phase
    * @param _firstPhaseMaxIssuance (Imax) Maximum number of new tokens minted per period during Phase 1.
    * See Equation 7 in Staking Protocol & Economics paper.
    * @param _minLockedPeriods Min amount of periods during which tokens can be locked
    * @param _minAllowableLockedTokens Min amount of tokens that can be locked
    * @param _maxAllowableLockedTokens Max amount of tokens that can be locked
    * @param _minWorkerPeriods Min amount of periods while a worker can't be changed
    * @param _isTestContract True if contract is only for tests
    */
    constructor(
        NuCypherToken _token,
        uint32 _hoursPerPeriod,
        uint256 _issuanceDecayCoefficient,
        uint256 _lockDurationCoefficient1,
        uint256 _lockDurationCoefficient2,
        uint16 _maximumRewardedPeriods,
        uint256 _firstPhaseTotalSupply,
        uint256 _firstPhaseMaxIssuance,
        uint16 _minLockedPeriods,
        uint256 _minAllowableLockedTokens,
        uint256 _maxAllowableLockedTokens,
        uint16 _minWorkerPeriods,
        bool _isTestContract
    )
        Issuer(
            _token,
            _hoursPerPeriod,
            _issuanceDecayCoefficient,
            _lockDurationCoefficient1,
            _lockDurationCoefficient2,
            _maximumRewardedPeriods,
            _firstPhaseTotalSupply,
            _firstPhaseMaxIssuance
        )
    {
        // constant `1` in the expression `_minLockedPeriods > 1` uses to simplify the `lock` method
        require(_minLockedPeriods > 1 && _maxAllowableLockedTokens != 0);
        minLockedPeriods = _minLockedPeriods;
        minAllowableLockedTokens = _minAllowableLockedTokens;
        maxAllowableLockedTokens = _maxAllowableLockedTokens;
        minWorkerPeriods = _minWorkerPeriods;
        isTestContract = _isTestContract;
    }

    /**
    * @dev Checks the existence of a staker in the contract
    */
    modifier onlyStaker()
    {
        StakerInfo storage info = stakerInfo[msg.sender];
        require(info.value > 0 || info.nextCommittedPeriod != 0);
        _;
    }

    //------------------------Initialization------------------------
    /**
    * @notice Set policy manager address
    */
    function setPolicyManager(PolicyManagerInterface _policyManager) external onlyOwner {
        // Policy manager can be set only once
        require(address(policyManager) == address(0));
        // This escrow must be the escrow for the new policy manager
        require(_policyManager.escrow() == address(this));
        policyManager = _policyManager;
    }

    /**
    * @notice Set adjudicator address
    */
    function setAdjudicator(AdjudicatorInterface _adjudicator) external onlyOwner {
        // Adjudicator can be set only once
        require(address(adjudicator) == address(0));
        // This escrow must be the escrow for the new adjudicator
        require(_adjudicator.escrow() == address(this));
        adjudicator = _adjudicator;
    }

    /**
    * @notice Set worklock address
    */
    function setWorkLock(WorkLockInterface _workLock) external onlyOwner {
        // WorkLock can be set only once
        require(address(workLock) == address(0) || isTestContract);
        // This escrow must be the escrow for the new worklock
        require(_workLock.escrow() == address(this));
        workLock = _workLock;
    }

    //------------------------Main getters------------------------
    /**
    * @notice Get all tokens belonging to the staker
    */
    function getAllTokens(address _staker) external view returns (uint256) {
        return stakerInfo[_staker].value;
    }

    /**
    * @notice Get all flags for the staker
    */
    function getFlags(address _staker)
        external view returns (
            bool windDown,
            bool reStake,
            bool measureWork,
            bool snapshots
        )
    {
        StakerInfo storage info = stakerInfo[_staker];
        windDown = info.flags.bitSet(WIND_DOWN_INDEX);
        reStake = !info.flags.bitSet(RE_STAKE_DISABLED_INDEX);
        measureWork = info.flags.bitSet(MEASURE_WORK_INDEX);
        snapshots = !info.flags.bitSet(SNAPSHOTS_DISABLED_INDEX);
    }

    /**
    * @notice Get the start period. Use in the calculation of the last period of the sub stake
    * @param _info Staker structure
    * @param _currentPeriod Current period
    */
    function getStartPeriod(StakerInfo storage _info, uint16 _currentPeriod)
        internal view returns (uint16)
    {
        // if the next period (after current) is committed
        if (_info.flags.bitSet(WIND_DOWN_INDEX) && _info.nextCommittedPeriod > _currentPeriod) {
            return _currentPeriod + 1;
        }
        return _currentPeriod;
    }

    /**
    * @notice Get the last period of the sub stake
    * @param _subStake Sub stake structure
    * @param _startPeriod Pre-calculated start period
    */
    function getLastPeriodOfSubStake(SubStakeInfo storage _subStake, uint16 _startPeriod)
        internal view returns (uint16)
    {
        if (_subStake.lastPeriod != 0) {
            return _subStake.lastPeriod;
        }
        uint32 lastPeriod = uint32(_startPeriod) + _subStake.periods;
        if (lastPeriod > uint32(MAX_UINT16)) {
            return MAX_UINT16;
        }
        return uint16(lastPeriod);
    }

    /**
    * @notice Get the last period of the sub stake
    * @param _staker Staker
    * @param _index Stake index
    */
    function getLastPeriodOfSubStake(address _staker, uint256 _index)
        public view returns (uint16)
    {
        StakerInfo storage info = stakerInfo[_staker];
        SubStakeInfo storage subStake = info.subStakes[_index];
        uint16 startPeriod = getStartPeriod(info, getCurrentPeriod());
        return getLastPeriodOfSubStake(subStake, startPeriod);
    }


    /**
    * @notice Get the value of locked tokens for a staker in a specified period
    * @dev Information may be incorrect for rewarded or not committed surpassed period
    * @param _info Staker structure
    * @param _currentPeriod Current period
    * @param _period Next period
    */
    function getLockedTokens(StakerInfo storage _info, uint16 _currentPeriod, uint16 _period)
        internal view returns (uint256 lockedValue)
    {
        lockedValue = 0;
        uint16 startPeriod = getStartPeriod(_info, _currentPeriod);
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            if (subStake.firstPeriod <= _period &&
                getLastPeriodOfSubStake(subStake, startPeriod) >= _period) {
                lockedValue += subStake.lockedValue;
            }
        }
    }

    /**
    * @notice Get the value of locked tokens for a staker in a future period
    * @dev This function is used by PreallocationEscrow so its signature can't be updated.
    * @param _staker Staker
    * @param _periods Amount of periods that will be added to the current period
    */
    function getLockedTokens(address _staker, uint16 _periods)
        external view returns (uint256 lockedValue)
    {
        StakerInfo storage info = stakerInfo[_staker];
        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod.add16(_periods);
        return getLockedTokens(info, currentPeriod, nextPeriod);
    }

    /**
    * @notice Get the last committed staker's period
    * @param _staker Staker
    */
    function getLastCommittedPeriod(address _staker) public view returns (uint16) {
        StakerInfo storage info = stakerInfo[_staker];
        return info.nextCommittedPeriod != 0 ? info.nextCommittedPeriod : info.lastCommittedPeriod;
    }

    /**
    * @notice Get the value of locked tokens for active stakers in (getCurrentPeriod() + _periods) period
    * as well as stakers and their locked tokens
    * @param _periods Amount of periods for locked tokens calculation
    * @param _startIndex Start index for looking in stakers array
    * @param _maxStakers Max stakers for looking, if set 0 then all will be used
    * @return allLockedTokens Sum of locked tokens for active stakers
    * @return activeStakers Array of stakers and their locked tokens. Stakers addresses stored as uint256
    * @dev Note that activeStakers[0] in an array of uint256, but you want addresses. Careful when used directly!
    */
    function getActiveStakers(uint16 _periods, uint256 _startIndex, uint256 _maxStakers)
        external view returns (uint256 allLockedTokens, uint256[2][] memory activeStakers)
    {
        require(_periods > 0);

        uint256 endIndex = stakers.length;
        require(_startIndex < endIndex);
        if (_maxStakers != 0 && _startIndex + _maxStakers < endIndex) {
            endIndex = _startIndex + _maxStakers;
        }
        activeStakers = new uint256[2][](endIndex - _startIndex);
        allLockedTokens = 0;

        uint256 resultIndex = 0;
        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod.add16(_periods);

        for (uint256 i = _startIndex; i < endIndex; i++) {
            address staker = stakers[i];
            StakerInfo storage info = stakerInfo[staker];
            if (info.currentCommittedPeriod != currentPeriod &&
                info.nextCommittedPeriod != currentPeriod) {
                continue;
            }
            uint256 lockedTokens = getLockedTokens(info, currentPeriod, nextPeriod);
            if (lockedTokens != 0) {
                activeStakers[resultIndex][0] = uint256(staker);
                activeStakers[resultIndex++][1] = lockedTokens;
                allLockedTokens += lockedTokens;
            }
        }
        assembly {
            mstore(activeStakers, resultIndex)
        }
    }

    /**
    * @notice Checks if `reStake` parameter is available for changing
    * @param _staker Staker
    */
    function isReStakeLocked(address _staker) public view returns (bool) {
        return getCurrentPeriod() < stakerInfo[_staker].lockReStakeUntilPeriod;
    }

    /**
    * @notice Get worker using staker's address
    */
    function getWorkerFromStaker(address _staker) external view returns (address) {
        return stakerInfo[_staker].worker;
    }

    /**
    * @notice Get work that completed by the staker
    */
    function getCompletedWork(address _staker) external view returns (uint256) {
        return stakerInfo[_staker].completedWork;
    }

    /**
    * @notice Find index of downtime structure that includes specified period
    * @dev If specified period is outside all downtime periods, the length of the array will be returned
    * @param _staker Staker
    * @param _period Specified period number
    */
    function findIndexOfPastDowntime(address _staker, uint16 _period) external view returns (uint256 index) {
        StakerInfo storage info = stakerInfo[_staker];
        for (index = 0; index < info.pastDowntime.length; index++) {
            if (_period <= info.pastDowntime[index].endPeriod) {
                return index;
            }
        }
    }

    //------------------------Main methods------------------------
    /**
    * @notice Start or stop measuring the work of a staker
    * @param _staker Staker
    * @param _measureWork Value for `measureWork` parameter
    * @return Work that was previously done
    */
    function setWorkMeasurement(address _staker, bool _measureWork) external returns (uint256) {
        require(msg.sender == address(workLock));
        StakerInfo storage info = stakerInfo[_staker];
        if (info.flags.bitSet(MEASURE_WORK_INDEX) == _measureWork) {
            return info.completedWork;
        }
        info.flags = info.flags.toggleBit(MEASURE_WORK_INDEX);
        emit WorkMeasurementSet(_staker, _measureWork);
        return info.completedWork;
    }

    /**
    * @notice Bond worker
    * @param _worker Worker address. Must be a real address, not a contract
    */
    function bondWorker(address _worker) external onlyStaker {
        StakerInfo storage info = stakerInfo[msg.sender];
        // Specified worker is already bonded with this staker
        require(_worker != info.worker);
        uint16 currentPeriod = getCurrentPeriod();
        if (info.worker != address(0)) { // If this staker had a worker ...
            // Check that enough time has passed to change it
            require(currentPeriod >= info.workerStartPeriod.add16(minWorkerPeriods));
            // Remove the old relation "worker->staker"
            stakerFromWorker[info.worker] = address(0);
        }

        if (_worker != address(0)) {
            // Specified worker is already in use
            require(stakerFromWorker[_worker] == address(0));
            // Specified worker is a staker
            require(stakerInfo[_worker].subStakes.length == 0 || _worker == msg.sender);
            // Set new worker->staker relation
            stakerFromWorker[_worker] = msg.sender;
        }

        // Bond new worker (or unbond if _worker == address(0))
        info.worker = _worker;
        info.workerStartPeriod = currentPeriod;
        emit WorkerBonded(msg.sender, _worker, currentPeriod);
    }

    /**
    * @notice Set `reStake` parameter. If true then all staking rewards will be added to locked stake
    * Only if this parameter is not locked
    * @param _reStake Value for parameter
    */
    function setReStake(bool _reStake) external {
        require(!isReStakeLocked(msg.sender));
        StakerInfo storage info = stakerInfo[msg.sender];
        if (info.flags.bitSet(RE_STAKE_DISABLED_INDEX) == !_reStake) {
            return;
        }
        info.flags = info.flags.toggleBit(RE_STAKE_DISABLED_INDEX);
        emit ReStakeSet(msg.sender, _reStake);
    }

    /**
    * @notice Lock `reStake` parameter. Only if this parameter is not locked
    * @param _lockReStakeUntilPeriod Can't change `reStake` value until this period
    */
    function lockReStake(uint16 _lockReStakeUntilPeriod) external {
        require(!isReStakeLocked(msg.sender) &&
            _lockReStakeUntilPeriod > getCurrentPeriod());
        stakerInfo[msg.sender].lockReStakeUntilPeriod = _lockReStakeUntilPeriod;
        emit ReStakeLocked(msg.sender, _lockReStakeUntilPeriod);
    }

    /**
    * @notice Enable `reStake` and lock this parameter even if parameter is locked
    * @param _staker Staker address
    * @param _info Staker structure
    * @param _lockReStakeUntilPeriod Can't change `reStake` value until this period
    */
    function forceLockReStake(
        address _staker,
        StakerInfo storage _info,
        uint16 _lockReStakeUntilPeriod
    )
        internal
    {
        // reset bit when `reStake` is already disabled
        if (_info.flags.bitSet(RE_STAKE_DISABLED_INDEX) == true) {
            _info.flags = _info.flags.toggleBit(RE_STAKE_DISABLED_INDEX);
            emit ReStakeSet(_staker, true);
        }
        // lock `reStake` parameter if it's not locked or locked for too short duration
        if (_lockReStakeUntilPeriod > _info.lockReStakeUntilPeriod) {
            _info.lockReStakeUntilPeriod = _lockReStakeUntilPeriod;
            emit ReStakeLocked(_staker, _lockReStakeUntilPeriod);
        }
    }

    /**
    * @notice Deposit tokens and lock `reStake` parameter from WorkLock contract
    * @param _staker Staker address
    * @param _value Amount of tokens to deposit
    * @param _periods Amount of periods during which tokens will be locked
    * and number of period after which `reStake` can be changed
    */
    function depositFromWorkLock(
        address _staker,
        uint256 _value,
        uint16 _periods
    )
        external
    {
        require(msg.sender == address(workLock));
        deposit(_staker, msg.sender, MAX_SUB_STAKES, _value, _periods);
        StakerInfo storage info = stakerInfo[_staker];
        uint16 lockReStakeUntilPeriod = getCurrentPeriod().add16(_periods).add16(1);
        forceLockReStake(_staker, info, lockReStakeUntilPeriod);
    }

    /**
    * @notice Set `windDown` parameter.
    * If true then stake's duration will be decreasing in each period with `commitToNextPeriod()`
    * @param _windDown Value for parameter
    */
    function setWindDown(bool _windDown) external onlyStaker {
        StakerInfo storage info = stakerInfo[msg.sender];
        if (info.flags.bitSet(WIND_DOWN_INDEX) == _windDown) {
            return;
        }
        info.flags = info.flags.toggleBit(WIND_DOWN_INDEX);

        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        emit WindDownSet(msg.sender, _windDown);

        // duration adjustment if next period is committed
        if (info.nextCommittedPeriod != nextPeriod) {
           return;
        }

        // adjust sub-stakes duration for the new value of winding down parameter
        for (uint256 index = 0; index < info.subStakes.length; index++) {
            SubStakeInfo storage subStake = info.subStakes[index];
            // sub-stake does not have fixed last period when winding down is disabled
            if (!_windDown && subStake.lastPeriod == nextPeriod) {
                subStake.lastPeriod = 0;
                subStake.periods = 1;
                continue;
            }
            // this sub-stake is no longer affected by winding down parameter
            if (subStake.lastPeriod != 0 || subStake.periods == 0) {
                continue;
            }

            subStake.periods = _windDown ? subStake.periods - 1 : subStake.periods + 1;
            if (subStake.periods == 0) {
                subStake.lastPeriod = nextPeriod;
            }
        }
    }

    /**
    * @notice Activate/deactivate taking snapshots of balances
    * @param _enableSnapshots True to activate snapshots, False to deactivate
    */
    function setSnapshots(bool _enableSnapshots) external {
        StakerInfo storage info = stakerInfo[msg.sender];
        if (info.flags.bitSet(SNAPSHOTS_DISABLED_INDEX) == !_enableSnapshots) {
            return;
        }

        uint256 lastGlobalBalance = uint256(balanceHistory.lastValue());
        if(_enableSnapshots){
            info.history.addSnapshot(info.value);
            balanceHistory.addSnapshot(lastGlobalBalance + info.value);
        } else {
            info.history.addSnapshot(0);
            balanceHistory.addSnapshot(lastGlobalBalance - info.value);
        }
        info.flags = info.flags.toggleBit(SNAPSHOTS_DISABLED_INDEX);

        emit SnapshotSet(msg.sender, _enableSnapshots);
    }

    /**
    * @notice Adds a new snapshot to both the staker and global balance histories,
    * assuming the staker's balance was already changed
    * @param _info Reference to affected staker's struct
    * @param _addition Variance in balance. It can be positive or negative.
    */
    function addSnapshot(StakerInfo storage _info, int256 _addition) internal {
        if(!_info.flags.bitSet(SNAPSHOTS_DISABLED_INDEX)){
            _info.history.addSnapshot(_info.value);
            uint256 lastGlobalBalance = uint256(balanceHistory.lastValue());
            balanceHistory.addSnapshot(lastGlobalBalance.addSigned(_addition));
        }
    }


    /**
    * @notice Batch deposit. Allowed only initial deposit for each staker
    * @param _stakers Stakers
    * @param _numberOfSubStakes Number of sub-stakes which belong to staker in _values and _periods arrays
    * @param _values Amount of tokens to deposit for each staker
    * @param _periods Amount of periods during which tokens will be locked for each staker
    * @param _lockReStakeUntilPeriod Can't change `reStake` value until this period. Zero value will disable locking
    */
    function batchDeposit(
        address[] calldata _stakers,
        uint256[] calldata _numberOfSubStakes,
        uint256[] calldata _values,
        uint16[] calldata _periods,
        uint16 _lockReStakeUntilPeriod
    )
        // `onlyOwner` modifier is for prevent malicious using of `forceLockReStake`
        // remove `onlyOwner` if `forceLockReStake` will be removed
        external onlyOwner
    {
        uint256 subStakesLength = _values.length;
        require(_stakers.length != 0 &&
            _stakers.length == _numberOfSubStakes.length &&
            subStakesLength >= _stakers.length &&
            _periods.length == subStakesLength);
        uint16 previousPeriod = getCurrentPeriod() - 1;
        uint16 nextPeriod = previousPeriod + 2;
        uint256 sumValue = 0;

        uint256 j = 0;
        for (uint256 i = 0; i < _stakers.length; i++) {
            address staker = _stakers[i];
            uint256 numberOfSubStakes = _numberOfSubStakes[i];
            uint256 endIndex = j + numberOfSubStakes;
            require(numberOfSubStakes > 0 && subStakesLength >= endIndex);
            StakerInfo storage info = stakerInfo[staker];
            require(info.subStakes.length == 0);
            // A staker can't be a worker for another staker
            require(stakerFromWorker[staker] == address(0));
            stakers.push(staker);
            policyManager.register(staker, previousPeriod);

            for (; j < endIndex; j++) {
                uint256 value =  _values[j];
                uint16 periods = _periods[j];
                require(value >= minAllowableLockedTokens && periods >= minLockedPeriods);
                info.value = info.value.add(value);
                info.subStakes.push(SubStakeInfo(nextPeriod, 0, periods, uint128(value)));
                sumValue = sumValue.add(value);
                emit Deposited(staker, value, periods);
                emit Locked(staker, value, nextPeriod, periods);
            }
            require(info.value <= maxAllowableLockedTokens);
            info.history.addSnapshot(info.value);

            if (_lockReStakeUntilPeriod >= nextPeriod) {
                forceLockReStake(staker, info, _lockReStakeUntilPeriod);
            }
        }
        require(j == subStakesLength);
        uint256 lastGlobalBalance = uint256(balanceHistory.lastValue());
        balanceHistory.addSnapshot(lastGlobalBalance + sumValue);
        token.safeTransferFrom(msg.sender, address(this), sumValue);
    }

    /**
    * @notice Implementation of the receiveApproval(address,uint256,address,bytes) method
    * (see NuCypherToken contract). Deposit all tokens that were approved to transfer
    * @param _from Staker
    * @param _value Amount of tokens to deposit
    * @param _tokenContract Token contract address
    * @notice (param _extraData) Amount of periods during which tokens will be locked
    */
    function receiveApproval(
        address _from,
        uint256 _value,
        address _tokenContract,
        bytes calldata /* _extraData */
    )
        external
    {
        require(_tokenContract == address(token) && msg.sender == address(token));

        // Copy first 32 bytes from _extraData, according to calldata memory layout:
        //
        // 0x00: method signature      4 bytes
        // 0x04: _from                 32 bytes after encoding
        // 0x24: _value                32 bytes after encoding
        // 0x44: _tokenContract        32 bytes after encoding
        // 0x64: _extraData pointer    32 bytes. Value must be 0x80 (offset of _extraData wrt to 1st parameter)
        // 0x84: _extraData length     32 bytes
        // 0xA4: _extraData data       Length determined by previous variable
        //
        // See https://solidity.readthedocs.io/en/latest/abi-spec.html#examples

        uint256 payloadSize;
        uint256 payload;
        assembly {
            payloadSize := calldataload(0x84)
            payload := calldataload(0xA4)
        }
        payload = payload >> 8*(32 - payloadSize);
        deposit(_from, _from, MAX_SUB_STAKES, _value, uint16(payload));
    }

    /**
    * @notice Deposit tokens and create new sub-stake. Use this method to become a staker
    * @param _staker Staker
    * @param _value Amount of tokens to deposit
    * @param _periods Amount of periods during which tokens will be locked
    */
    function deposit(address _staker, uint256 _value, uint16 _periods) external {
        deposit(_staker, msg.sender, MAX_SUB_STAKES, _value, _periods);
    }

    /**
    * @notice Deposit tokens and increase lock amount of an existing sub-stake
    * @dev This is preferable way to stake tokens because will be fewer active sub-stakes in the result
    * @param _index Index of the sub stake
    * @param _value Amount of tokens which will be locked
    */
    function depositAndIncrease(uint256 _index, uint256 _value) external onlyStaker {
        require(_index < MAX_SUB_STAKES);
        deposit(msg.sender, msg.sender, _index, _value, 0);
    }

    /**
    * @notice Deposit tokens
    * @dev Specify either index and zero periods (for an existing sub-stake)
    * or index >= MAX_SUB_STAKES and real value for periods (for a new sub-stake), not both
    * @param _staker Staker
    * @param _payer Owner of tokens
    * @param _index Index of the sub stake
    * @param _value Amount of tokens to deposit
    * @param _periods Amount of periods during which tokens will be locked
    */
    function deposit(address _staker, address _payer, uint256 _index, uint256 _value, uint16 _periods) internal {
        require(_value != 0);
        StakerInfo storage info = stakerInfo[_staker];
        // A staker can't be a worker for another staker
        require(stakerFromWorker[_staker] == address(0) || stakerFromWorker[_staker] == info.worker);
        // initial stake of the staker
        if (info.subStakes.length == 0) {
            stakers.push(_staker);
            policyManager.register(_staker, getCurrentPeriod() - 1);
        }
        token.safeTransferFrom(_payer, address(this), _value);
        info.value += _value;
        lock(_staker, _index, _value, _periods);

        addSnapshot(info, int256(_value));
        if (_index >= MAX_SUB_STAKES) {
            emit Deposited(_staker, _value, _periods);
        } else {
            uint16 lastPeriod = getLastPeriodOfSubStake(_staker, _index);
            emit Deposited(_staker, _value, lastPeriod - getCurrentPeriod());
        }
    }

    /**
    * @notice Lock some tokens as a new sub-stake
    * @param _value Amount of tokens which will be locked
    * @param _periods Amount of periods during which tokens will be locked
    */
    function lockAndCreate(uint256 _value, uint16 _periods) external onlyStaker {
        lock(msg.sender, MAX_SUB_STAKES, _value, _periods);
    }

    /**
    * @notice Increase lock amount of an existing sub-stake
    * @param _index Index of the sub-stake
    * @param _value Amount of tokens which will be locked
    */
    function lockAndIncrease(uint256 _index, uint256 _value) external onlyStaker {
        require(_index < MAX_SUB_STAKES);
        lock(msg.sender, _index, _value, 0);
    }

    /**
    * @notice Lock some tokens as a stake
    * @dev Specify either index and zero periods (for an existing sub-stake)
    * or index >= MAX_SUB_STAKES and real value for periods (for a new sub-stake), not both
    * @param _staker Staker
    * @param _index Index of the sub stake
    * @param _value Amount of tokens which will be locked
    * @param _periods Amount of periods during which tokens will be locked
    */
    function lock(address _staker, uint256 _index, uint256 _value, uint16 _periods) internal {
        if (_index < MAX_SUB_STAKES) {
            require(_value > 0);
        } else {
            require(_value >= minAllowableLockedTokens && _periods >= minLockedPeriods);
        }

        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        StakerInfo storage info = stakerInfo[_staker];
        uint256 lockedTokens = getLockedTokens(info, currentPeriod, nextPeriod);
        uint256 requestedLockedTokens = _value.add(lockedTokens);
        require(requestedLockedTokens <= info.value && requestedLockedTokens <= maxAllowableLockedTokens);

        // next period is committed
        if (info.nextCommittedPeriod == nextPeriod) {
            lockedPerPeriod[nextPeriod] += _value;
            emit CommitmentMade(_staker, nextPeriod, _value);
        }

        // if index was provided then increase existing sub-stake
        if (_index < MAX_SUB_STAKES) {
            lockAndIncrease(info, currentPeriod, nextPeriod, _staker, _index, _value);
        // otherwise create new
        } else {
            lockAndCreate(info, nextPeriod, _staker, _value, _periods);
        }
    }

    /**
    * @notice Lock some tokens as a new sub-stake
    * @param _info Staker structure
    * @param _nextPeriod Next period
    * @param _staker Staker
    * @param _value Amount of tokens which will be locked
    * @param _periods Amount of periods during which tokens will be locked
    */
    function lockAndCreate(
        StakerInfo storage _info,
        uint16 _nextPeriod,
        address _staker,
        uint256 _value,
        uint16 _periods
    )
        internal
    {
        uint16 duration = _periods;
        // if winding down is enabled and next period is committed
        // then sub-stakes duration were decreased
        if (_info.nextCommittedPeriod == _nextPeriod && _info.flags.bitSet(WIND_DOWN_INDEX)) {
            duration -= 1;
        }
        saveSubStake(_info, _nextPeriod, 0, duration, _value);

        emit Locked(_staker, _value, _nextPeriod, _periods);
    }

    /**
    * @notice Increase lock amount of an existing sub-stake
    * @dev Probably will be created a new sub-stake but it will be active only one period
    * @param _info Staker structure
    * @param _currentPeriod Current period
    * @param _nextPeriod Next period
    * @param _staker Staker
    * @param _index Index of the sub-stake
    * @param _value Amount of tokens which will be locked
    */
    function lockAndIncrease(
        StakerInfo storage _info,
        uint16 _currentPeriod,
        uint16 _nextPeriod,
        address _staker,
        uint256 _index,
        uint256 _value
    )
        internal
    {
        SubStakeInfo storage subStake = _info.subStakes[_index];
        (, uint16 lastPeriod) = checkLastPeriodOfSubStake(_info, subStake, _currentPeriod);

        // create temporary sub-stake for current or previous committed periods
        // to leave locked amount in this period unchanged
        if (_info.currentCommittedPeriod != 0 &&
            _info.currentCommittedPeriod <= _currentPeriod ||
            _info.nextCommittedPeriod != 0 &&
            _info.nextCommittedPeriod <= _currentPeriod)
        {
            saveSubStake(_info, subStake.firstPeriod, _currentPeriod, 0, subStake.lockedValue);
        }

        subStake.lockedValue += uint128(_value);
        // all new locks should start from the next period
        subStake.firstPeriod = _nextPeriod;

        emit Locked(_staker, _value, _nextPeriod, lastPeriod - _currentPeriod);
    }

    /**
    * @notice Checks that last period of sub-stake is greater than the current period
    * @param _info Staker structure
    * @param _subStake Sub-stake structure
    * @param _currentPeriod Current period
    * @return startPeriod Start period. Use in the calculation of the last period of the sub stake
    * @return lastPeriod Last period of the sub stake
    */
    function checkLastPeriodOfSubStake(
        StakerInfo storage _info,
        SubStakeInfo storage _subStake,
        uint16 _currentPeriod
    )
        internal view returns (uint16 startPeriod, uint16 lastPeriod)
    {
        startPeriod = getStartPeriod(_info, _currentPeriod);
        lastPeriod = getLastPeriodOfSubStake(_subStake, startPeriod);
        // The sub stake must be active at least in the next period
        require(lastPeriod > _currentPeriod);
    }

    /**
    * @notice Save sub stake. First tries to override inactive sub stake
    * @dev Inactive sub stake means that last period of sub stake has been surpassed and already rewarded
    * @param _info Staker structure
    * @param _firstPeriod First period of the sub stake
    * @param _lastPeriod Last period of the sub stake
    * @param _periods Duration of the sub stake in periods
    * @param _lockedValue Amount of locked tokens
    */
    function saveSubStake(
        StakerInfo storage _info,
        uint16 _firstPeriod,
        uint16 _lastPeriod,
        uint16 _periods,
        uint256 _lockedValue
    )
        internal
    {
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            if (subStake.lastPeriod != 0 &&
                (_info.currentCommittedPeriod == 0 ||
                subStake.lastPeriod < _info.currentCommittedPeriod) &&
                (_info.nextCommittedPeriod == 0 ||
                subStake.lastPeriod < _info.nextCommittedPeriod))
            {
                subStake.firstPeriod = _firstPeriod;
                subStake.lastPeriod = _lastPeriod;
                subStake.periods = _periods;
                subStake.lockedValue = uint128(_lockedValue);
                return;
            }
        }
        require(_info.subStakes.length < MAX_SUB_STAKES);
        _info.subStakes.push(SubStakeInfo(_firstPeriod, _lastPeriod, _periods, uint128(_lockedValue)));
    }

    /**
    * @notice Divide sub stake into two parts
    * @param _index Index of the sub stake
    * @param _newValue New sub stake value
    * @param _periods Amount of periods for extending sub stake
    */
    function divideStake(uint256 _index, uint256 _newValue, uint16 _periods) external onlyStaker {
        StakerInfo storage info = stakerInfo[msg.sender];
        require(_newValue >= minAllowableLockedTokens && _periods > 0);
        SubStakeInfo storage subStake = info.subStakes[_index];
        uint16 currentPeriod = getCurrentPeriod();
        (, uint16 lastPeriod) = checkLastPeriodOfSubStake(info, subStake, currentPeriod);

        uint256 oldValue = subStake.lockedValue;
        subStake.lockedValue = uint128(oldValue.sub(_newValue));
        require(subStake.lockedValue >= minAllowableLockedTokens);
        uint16 requestedPeriods = subStake.periods.add16(_periods);
        saveSubStake(info, subStake.firstPeriod, 0, requestedPeriods, _newValue);
        emit Divided(msg.sender, oldValue, lastPeriod, _newValue, _periods);
        emit Locked(msg.sender, _newValue, subStake.firstPeriod, requestedPeriods);
    }

    /**
    * @notice Prolong active sub stake
    * @param _index Index of the sub stake
    * @param _periods Amount of periods for extending sub stake
    */
    function prolongStake(uint256 _index, uint16 _periods) external onlyStaker {
        StakerInfo storage info = stakerInfo[msg.sender];
        // Incorrect parameters
        require(_periods > 0);
        SubStakeInfo storage subStake = info.subStakes[_index];
        uint16 currentPeriod = getCurrentPeriod();
        (uint16 startPeriod, uint16 lastPeriod) = checkLastPeriodOfSubStake(info, subStake, currentPeriod);

        subStake.periods = subStake.periods.add16(_periods);
        // if the sub stake ends in the next committed period then reset the `lastPeriod` field
        if (lastPeriod == startPeriod) {
            subStake.lastPeriod = 0;
        }
        // The extended sub stake must not be less than the minimum value
        require(uint32(lastPeriod - currentPeriod) + _periods >= minLockedPeriods);
        emit Locked(msg.sender, subStake.lockedValue, lastPeriod + 1, _periods);
        emit Prolonged(msg.sender, subStake.lockedValue, lastPeriod, _periods);
    }

    /**
    * @notice Merge two sub-stakes into one if their last periods are equal
    * @dev It's possible that both sub-stakes will be active after this transaction.
    * But only one of them will be active until next call `commitToNextPeriod` (in the next period)
    * @param _index1 Index of the first sub-stake
    * @param _index2 Index of the second sub-stake
    */
    function mergeStake(uint256 _index1, uint256 _index2) external onlyStaker {
        require(_index1 != _index2); // must be different sub-stakes

        StakerInfo storage info = stakerInfo[msg.sender];
        SubStakeInfo storage subStake1 = info.subStakes[_index1];
        SubStakeInfo storage subStake2 = info.subStakes[_index2];
        uint16 currentPeriod = getCurrentPeriod();

        (, uint16 lastPeriod1) = checkLastPeriodOfSubStake(info, subStake1, currentPeriod);
        (, uint16 lastPeriod2) = checkLastPeriodOfSubStake(info, subStake2, currentPeriod);
        // both sub-stakes must have equal last period to be mergeable
        require(lastPeriod1 == lastPeriod2);
        emit Merged(msg.sender, subStake1.lockedValue, subStake2.lockedValue, lastPeriod1);

        if (subStake1.firstPeriod == subStake2.firstPeriod) {
            subStake1.lockedValue += subStake2.lockedValue;
            subStake2.lastPeriod = 1;
            subStake2.periods = 0;
        } else if (subStake1.firstPeriod > subStake2.firstPeriod) {
            subStake1.lockedValue += subStake2.lockedValue;
            subStake2.lastPeriod = subStake1.firstPeriod - 1;
            subStake2.periods = 0;
        } else {
            subStake2.lockedValue += subStake1.lockedValue;
            subStake1.lastPeriod = subStake2.firstPeriod - 1;
            subStake1.periods = 0;
        }
    }

    /**
    * @notice Withdraw available amount of tokens to staker
    * @param _value Amount of tokens to withdraw
    */
    function withdraw(uint256 _value) external onlyStaker {
        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        StakerInfo storage info = stakerInfo[msg.sender];
        // the max locked tokens in most cases will be in the current period
        // but when the staker locks more then we should use the next period
        uint256 lockedTokens = Math.max(getLockedTokens(info, currentPeriod, nextPeriod),
            getLockedTokens(info, currentPeriod, currentPeriod));
        require(_value <= info.value.sub(lockedTokens));
        info.value -= _value;

        addSnapshot(info, - int256(_value));
        token.safeTransfer(msg.sender, _value);
        emit Withdrawn(msg.sender, _value);

        // unbond worker if staker withdraws last portion of NU
        if (info.value == 0 &&
            info.nextCommittedPeriod == 0 &&
            info.worker != address(0))
        {
            stakerFromWorker[info.worker] = address(0);
            info.worker = address(0);
            emit WorkerBonded(msg.sender, address(0), currentPeriod);
        }
    }

    /**
    * @notice Make a commitment to the next period and mint for the previous period
    */
    function commitToNextPeriod() external isInitialized {
        address staker = stakerFromWorker[msg.sender];
        StakerInfo storage info = stakerInfo[staker];
        // Staker must have a stake to make a commitment
        require(info.value > 0);
        // Only worker with real address can make a commitment
        require(msg.sender == tx.origin);

        uint16 lastCommittedPeriod = getLastCommittedPeriod(staker);
        mint(staker);
        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;

        // the period has already been committed
        if (info.nextCommittedPeriod == nextPeriod) {
            return;
        }

        uint256 lockedTokens = getLockedTokens(info, currentPeriod, nextPeriod);
        require(lockedTokens > 0);
        lockedPerPeriod[nextPeriod] += lockedTokens;

        info.currentCommittedPeriod = info.nextCommittedPeriod;
        info.nextCommittedPeriod = nextPeriod;

        decreaseSubStakesDuration(info, nextPeriod);

        // staker was inactive for several periods
        if (lastCommittedPeriod < currentPeriod) {
            info.pastDowntime.push(Downtime(lastCommittedPeriod + 1, currentPeriod));
        }
        policyManager.setDefaultFeeDelta(staker, nextPeriod);
        emit CommitmentMade(staker, nextPeriod, lockedTokens);
    }

    /**
    * @notice Decrease sub-stakes duration if `windDown` is enabled
    */
    function decreaseSubStakesDuration(StakerInfo storage _info, uint16 _nextPeriod) internal {
        if (!_info.flags.bitSet(WIND_DOWN_INDEX)) {
            return;
        }
        for (uint256 index = 0; index < _info.subStakes.length; index++) {
            SubStakeInfo storage subStake = _info.subStakes[index];
            if (subStake.lastPeriod != 0 || subStake.periods == 0) {
                continue;
            }
            subStake.periods--;
            if (subStake.periods == 0) {
                subStake.lastPeriod = _nextPeriod;
            }
        }
    }

    /**
    * @notice Mint tokens for previous periods if staker locked their tokens and made a commitment
    */
    function mint() external onlyStaker {
        // save last committed period to the storage if both periods will be empty after minting
        // because we won't be able to calculate last committed period
        // see getLastCommittedPeriod(address)
        StakerInfo storage info = stakerInfo[msg.sender];
        uint16 previousPeriod = getCurrentPeriod() - 1;
        if (info.nextCommittedPeriod <= previousPeriod && info.nextCommittedPeriod != 0) {
            info.lastCommittedPeriod = info.nextCommittedPeriod;
        }
        mint(msg.sender);
    }

    /**
    * @notice Mint tokens for previous periods if staker locked their tokens and made a commitment
    * @param _staker Staker
    */
    function mint(address _staker) internal {
        uint16 currentPeriod = getCurrentPeriod();
        uint16 previousPeriod = currentPeriod  - 1;
        StakerInfo storage info = stakerInfo[_staker];

        if (info.nextCommittedPeriod == 0 ||
            info.currentCommittedPeriod == 0 &&
            info.nextCommittedPeriod > previousPeriod ||
            info.currentCommittedPeriod > previousPeriod) {
            return;
        }

        uint16 startPeriod = getStartPeriod(info, currentPeriod);
        uint256 reward = 0;
        bool reStake = !info.flags.bitSet(RE_STAKE_DISABLED_INDEX);
        if (info.currentCommittedPeriod != 0) {
            reward = mint(_staker, info, info.currentCommittedPeriod, currentPeriod, startPeriod, reStake);
            info.currentCommittedPeriod = 0;
            if (reStake) {
                lockedPerPeriod[info.nextCommittedPeriod] += reward;
            }
        }
        if (info.nextCommittedPeriod <= previousPeriod) {
            reward += mint(_staker, info, info.nextCommittedPeriod, currentPeriod, startPeriod, reStake);
            info.nextCommittedPeriod = 0;
        }

        info.value += reward;
        if (info.flags.bitSet(MEASURE_WORK_INDEX)) {
            info.completedWork += reward;
        }

        addSnapshot(info, int256(reward));
        emit Minted(_staker, previousPeriod, reward);
    }

    /**
    * @notice Calculate reward for one period
    * @param _staker Staker's address
    * @param _info Staker structure
    * @param _mintingPeriod Period for minting calculation
    * @param _currentPeriod Current period
    * @param _startPeriod Pre-calculated start period
    */
    function mint(
        address _staker,
        StakerInfo storage _info,
        uint16 _mintingPeriod,
        uint16 _currentPeriod,
        uint16 _startPeriod,
        bool _reStake
    )
        internal returns (uint256 reward)
    {
        reward = 0;
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake =  _info.subStakes[i];
            uint16 lastPeriod = getLastPeriodOfSubStake(subStake, _startPeriod);
            if (subStake.firstPeriod <= _mintingPeriod && lastPeriod >= _mintingPeriod) {
                uint256 subStakeReward = mint(
                    _currentPeriod,
                    subStake.lockedValue,
                    lockedPerPeriod[_mintingPeriod],
                    lastPeriod.sub16(_mintingPeriod));
                reward += subStakeReward;
                if (_reStake) {
                    subStake.lockedValue += uint128(subStakeReward);
                }
            }
        }
        policyManager.updateFee(_staker, _mintingPeriod);
        return reward;
    }

    //-------------------------Slashing-------------------------
    /**
    * @notice Slash the staker's stake and reward the investigator
    * @param _staker Staker's address
    * @param _penalty Penalty
    * @param _investigator Investigator
    * @param _reward Reward for the investigator
    */
    function slashStaker(
        address _staker,
        uint256 _penalty,
        address _investigator,
        uint256 _reward
    )
        public isInitialized
    {
        require(msg.sender == address(adjudicator));
        require(_penalty > 0);
        StakerInfo storage info = stakerInfo[_staker];
        if (info.value <= _penalty) {
            _penalty = info.value;
        }
        info.value -= _penalty;
        if (_reward > _penalty) {
            _reward = _penalty;
        }

        uint16 currentPeriod = getCurrentPeriod();
        uint16 nextPeriod = currentPeriod + 1;
        uint16 startPeriod = getStartPeriod(info, currentPeriod);

        (uint256 currentLock, uint256 nextLock, uint256 currentAndNextLock, uint256 shortestSubStakeIndex) =
            getLockedTokensAndShortestSubStake(info, currentPeriod, nextPeriod, startPeriod);

        // Decrease the stake if amount of locked tokens in the current period more than staker has
        uint256 lockedTokens = currentLock + currentAndNextLock;
        if (info.value < lockedTokens) {
           decreaseSubStakes(info, lockedTokens - info.value, currentPeriod, startPeriod, shortestSubStakeIndex);
        }
        // Decrease the stake if amount of locked tokens in the next period more than staker has
        if (nextLock > 0) {
            lockedTokens = nextLock + currentAndNextLock -
                (currentAndNextLock > info.value ? currentAndNextLock - info.value : 0);
            if (info.value < lockedTokens) {
               decreaseSubStakes(info, lockedTokens - info.value, nextPeriod, startPeriod, MAX_SUB_STAKES);
            }
        }

        emit Slashed(_staker, _penalty, _investigator, _reward);
        if (_penalty > _reward) {
            unMint(_penalty - _reward);
        }
        // TODO change to withdrawal pattern (#1499)
        if (_reward > 0) {
            token.safeTransfer(_investigator, _reward);
        }

        addSnapshot(info, - int256(_penalty));

    }

    /**
    * @notice Get the value of locked tokens for a staker in the current and the next period
    * and find the shortest sub stake
    * @param _info Staker structure
    * @param _currentPeriod Current period
    * @param _nextPeriod Next period
    * @param _startPeriod Pre-calculated start period
    * @return currentLock Amount of tokens that locked in the current period and unlocked in the next period
    * @return nextLock Amount of tokens that locked in the next period and not locked in the current period
    * @return currentAndNextLock Amount of tokens that locked in the current period and in the next period
    * @return shortestSubStakeIndex Index of the shortest sub stake
    */
    function getLockedTokensAndShortestSubStake(
        StakerInfo storage _info,
        uint16 _currentPeriod,
        uint16 _nextPeriod,
        uint16 _startPeriod
    )
        internal view returns (
            uint256 currentLock,
            uint256 nextLock,
            uint256 currentAndNextLock,
            uint256 shortestSubStakeIndex
        )
    {
        uint16 minDuration = MAX_UINT16;
        uint16 minLastPeriod = MAX_UINT16;
        shortestSubStakeIndex = MAX_SUB_STAKES;
        currentLock = 0;
        nextLock = 0;
        currentAndNextLock = 0;

        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            uint16 lastPeriod = getLastPeriodOfSubStake(subStake, _startPeriod);
            if (lastPeriod < subStake.firstPeriod) {
                continue;
            }
            if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _nextPeriod) {
                currentAndNextLock += subStake.lockedValue;
            } else if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _currentPeriod) {
                currentLock += subStake.lockedValue;
            } else if (subStake.firstPeriod <= _nextPeriod &&
                lastPeriod >= _nextPeriod) {
                nextLock += subStake.lockedValue;
            }
            uint16 duration = lastPeriod - subStake.firstPeriod;
            if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _currentPeriod &&
                (lastPeriod < minLastPeriod ||
                lastPeriod == minLastPeriod && duration < minDuration))
            {
                shortestSubStakeIndex = i;
                minDuration = duration;
                minLastPeriod = lastPeriod;
            }
        }
    }

    /**
    * @notice Decrease short sub stakes
    * @param _info Staker structure
    * @param _penalty Penalty rate
    * @param _decreasePeriod The period when the decrease begins
    * @param _startPeriod Pre-calculated start period
    * @param _shortestSubStakeIndex Index of the shortest period
    */
    function decreaseSubStakes(
        StakerInfo storage _info,
        uint256 _penalty,
        uint16 _decreasePeriod,
        uint16 _startPeriod,
        uint256 _shortestSubStakeIndex
    )
        internal
    {
        SubStakeInfo storage shortestSubStake = _info.subStakes[0];
        uint16 minSubStakeLastPeriod = MAX_UINT16;
        uint16 minSubStakeDuration = MAX_UINT16;
        while(_penalty > 0) {
            if (_shortestSubStakeIndex < MAX_SUB_STAKES) {
                shortestSubStake = _info.subStakes[_shortestSubStakeIndex];
                minSubStakeLastPeriod = getLastPeriodOfSubStake(shortestSubStake, _startPeriod);
                minSubStakeDuration = minSubStakeLastPeriod - shortestSubStake.firstPeriod;
                _shortestSubStakeIndex = MAX_SUB_STAKES;
            } else {
                (shortestSubStake, minSubStakeDuration, minSubStakeLastPeriod) =
                    getShortestSubStake(_info, _decreasePeriod, _startPeriod);
            }
            if (minSubStakeDuration == MAX_UINT16) {
                break;
            }
            uint256 appliedPenalty = _penalty;
            if (_penalty < shortestSubStake.lockedValue) {
                shortestSubStake.lockedValue -= uint128(_penalty);
                saveOldSubStake(_info, shortestSubStake.firstPeriod, _penalty, _decreasePeriod);
                _penalty = 0;
            } else {
                shortestSubStake.lastPeriod = _decreasePeriod - 1;
                _penalty -= shortestSubStake.lockedValue;
                appliedPenalty = shortestSubStake.lockedValue;
            }
            if (_info.currentCommittedPeriod >= _decreasePeriod &&
                _info.currentCommittedPeriod <= minSubStakeLastPeriod)
            {
                lockedPerPeriod[_info.currentCommittedPeriod] -= appliedPenalty;
            }
            if (_info.nextCommittedPeriod >= _decreasePeriod &&
                _info.nextCommittedPeriod <= minSubStakeLastPeriod)
            {
                lockedPerPeriod[_info.nextCommittedPeriod] -= appliedPenalty;
            }
        }
    }

    /**
    * @notice Get the shortest sub stake
    * @param _info Staker structure
    * @param _currentPeriod Current period
    * @param _startPeriod Pre-calculated start period
    * @return shortestSubStake The shortest sub stake
    * @return minSubStakeDuration Duration of the shortest sub stake
    * @return minSubStakeLastPeriod Last period of the shortest sub stake
    */
    function getShortestSubStake(
        StakerInfo storage _info,
        uint16 _currentPeriod,
        uint16 _startPeriod
    )
        internal view returns (
            SubStakeInfo storage shortestSubStake,
            uint16 minSubStakeDuration,
            uint16 minSubStakeLastPeriod
        )
    {
        shortestSubStake = shortestSubStake;
        minSubStakeDuration = MAX_UINT16;
        minSubStakeLastPeriod = MAX_UINT16;
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            uint16 lastPeriod = getLastPeriodOfSubStake(subStake, _startPeriod);
            if (lastPeriod < subStake.firstPeriod) {
                continue;
            }
            uint16 duration = lastPeriod - subStake.firstPeriod;
            if (subStake.firstPeriod <= _currentPeriod &&
                lastPeriod >= _currentPeriod &&
                (lastPeriod < minSubStakeLastPeriod ||
                lastPeriod == minSubStakeLastPeriod && duration < minSubStakeDuration))
            {
                shortestSubStake = subStake;
                minSubStakeDuration = duration;
                minSubStakeLastPeriod = lastPeriod;
            }
        }
    }

    /**
    * @notice Save the old sub stake values to prevent decreasing reward for the previous period
    * @dev Saving happens only if the previous period is committed
    * @param _info Staker structure
    * @param _firstPeriod First period of the old sub stake
    * @param _lockedValue Locked value of the old sub stake
    * @param _currentPeriod Current period, when the old sub stake is already unlocked
    */
    function saveOldSubStake(
        StakerInfo storage _info,
        uint16 _firstPeriod,
        uint256 _lockedValue,
        uint16 _currentPeriod
    )
        internal
    {
        // Check that the old sub stake should be saved
        bool oldCurrentCommittedPeriod = _info.currentCommittedPeriod != 0 &&
            _info.currentCommittedPeriod < _currentPeriod;
        bool oldnextCommittedPeriod = _info.nextCommittedPeriod != 0 &&
            _info.nextCommittedPeriod < _currentPeriod;
        bool crosscurrentCommittedPeriod = oldCurrentCommittedPeriod && _info.currentCommittedPeriod >= _firstPeriod;
        bool crossnextCommittedPeriod = oldnextCommittedPeriod && _info.nextCommittedPeriod >= _firstPeriod;
        if (!crosscurrentCommittedPeriod && !crossnextCommittedPeriod) {
            return;
        }
        // Try to find already existent proper old sub stake
        uint16 previousPeriod = _currentPeriod - 1;
        for (uint256 i = 0; i < _info.subStakes.length; i++) {
            SubStakeInfo storage subStake = _info.subStakes[i];
            if (subStake.lastPeriod == previousPeriod &&
                ((crosscurrentCommittedPeriod ==
                (oldCurrentCommittedPeriod && _info.currentCommittedPeriod >= subStake.firstPeriod)) &&
                (crossnextCommittedPeriod ==
                (oldnextCommittedPeriod && _info.nextCommittedPeriod >= subStake.firstPeriod))))
            {
                subStake.lockedValue += uint128(_lockedValue);
                return;
            }
        }
        saveSubStake(_info, _firstPeriod, previousPeriod, 0, _lockedValue);
    }

    //-------------Additional getters for stakers info-------------
    /**
    * @notice Return the length of the array of stakers
    */
    function getStakersLength() external view returns (uint256) {
        return stakers.length;
    }

    /**
    * @notice Return the length of the array of sub stakes
    */
    function getSubStakesLength(address _staker) external view returns (uint256) {
        return stakerInfo[_staker].subStakes.length;
    }

    /**
    * @notice Return the information about sub stake
    */
    function getSubStakeInfo(address _staker, uint256 _index)
    // TODO change to structure when ABIEncoderV2 is released (#1501)
//        public view returns (SubStakeInfo)
        // TODO "virtual" only for tests, probably will be removed after #1512
        external view virtual returns (uint16 firstPeriod, uint16 lastPeriod, uint16 periods, uint128 lockedValue)
    {
        SubStakeInfo storage info = stakerInfo[_staker].subStakes[_index];
        firstPeriod = info.firstPeriod;
        lastPeriod = info.lastPeriod;
        periods = info.periods;
        lockedValue = info.lockedValue;
    }

    /**
    * @notice Return the length of the array of past downtime
    */
    function getPastDowntimeLength(address _staker) external view returns (uint256) {
        return stakerInfo[_staker].pastDowntime.length;
    }

    /**
    * @notice Return the information about past downtime
    */
    function  getPastDowntime(address _staker, uint256 _index)
    // TODO change to structure when ABIEncoderV2 is released (#1501)
//        public view returns (Downtime)
        external view returns (uint16 startPeriod, uint16 endPeriod)
    {
        Downtime storage downtime = stakerInfo[_staker].pastDowntime[_index];
        startPeriod = downtime.startPeriod;
        endPeriod = downtime.endPeriod;
    }

    //------------------ ERC900 connectors ----------------------

    function totalStakedForAt(address _owner, uint256 _blockNumber) public view override returns (uint256){
        return stakerInfo[_owner].history.getValueAt(_blockNumber);
    }

    function totalStakedAt(uint256 _blockNumber) public view override returns (uint256){
        return balanceHistory.getValueAt(_blockNumber);
    }

    function supportsHistory() external pure override returns (bool){
        return true;
    }

    //------------------------Upgradeable------------------------
    /**
    * @dev Get StakerInfo structure by delegatecall
    */
    function delegateGetStakerInfo(address _target, bytes32 _staker)
        internal returns (StakerInfo memory result)
    {
        bytes32 memoryAddress = delegateGetData(_target, this.stakerInfo.selector, 1, _staker, 0);
        assembly {
            result := memoryAddress
        }
    }

    /**
    * @dev Get SubStakeInfo structure by delegatecall
    */
    function delegateGetSubStakeInfo(address _target, bytes32 _staker, uint256 _index)
        internal returns (SubStakeInfo memory result)
    {
        bytes32 memoryAddress = delegateGetData(
            _target, this.getSubStakeInfo.selector, 2, _staker, bytes32(_index));
        assembly {
            result := memoryAddress
        }
    }

    /**
    * @dev Get Downtime structure by delegatecall
    */
    function delegateGetPastDowntime(address _target, bytes32 _staker, uint256 _index)
        internal returns (Downtime memory result)
    {
        bytes32 memoryAddress = delegateGetData(
            _target, this.getPastDowntime.selector, 2, _staker, bytes32(_index));
        assembly {
            result := memoryAddress
        }
    }

    /// @dev the `onlyWhileUpgrading` modifier works through a call to the parent `verifyState`
    function verifyState(address _testTarget) public override virtual {
        super.verifyState(_testTarget);
        require(address(delegateGet(_testTarget, this.policyManager.selector)) == address(policyManager));
        require(address(delegateGet(_testTarget, this.adjudicator.selector)) == address(adjudicator));
        require(address(delegateGet(_testTarget, this.workLock.selector)) == address(workLock));
        require(delegateGet(_testTarget, this.lockedPerPeriod.selector,
            bytes32(bytes2(RESERVED_PERIOD))) == lockedPerPeriod[RESERVED_PERIOD]);
        require(address(delegateGet(_testTarget, this.stakerFromWorker.selector, bytes32(0))) ==
            stakerFromWorker[address(0)]);

        require(delegateGet(_testTarget, this.getStakersLength.selector) == stakers.length);
        if (stakers.length == 0) {
            return;
        }
        address stakerAddress = stakers[0];
        require(address(uint160(delegateGet(_testTarget, this.stakers.selector, 0))) == stakerAddress);
        StakerInfo storage info = stakerInfo[stakerAddress];
        bytes32 staker = bytes32(uint256(stakerAddress));
        StakerInfo memory infoToCheck = delegateGetStakerInfo(_testTarget, staker);
        require(infoToCheck.value == info.value &&
            infoToCheck.currentCommittedPeriod == info.currentCommittedPeriod &&
            infoToCheck.nextCommittedPeriod == info.nextCommittedPeriod &&
            infoToCheck.flags == info.flags &&
            infoToCheck.lockReStakeUntilPeriod == info.lockReStakeUntilPeriod &&
            infoToCheck.lastCommittedPeriod == info.lastCommittedPeriod &&
            infoToCheck.completedWork == info.completedWork &&
            infoToCheck.worker == info.worker &&
            infoToCheck.workerStartPeriod == info.workerStartPeriod);

        require(delegateGet(_testTarget, this.getPastDowntimeLength.selector, staker) ==
            info.pastDowntime.length);
        for (uint256 i = 0; i < info.pastDowntime.length && i < MAX_CHECKED_VALUES; i++) {
            Downtime storage downtime = info.pastDowntime[i];
            Downtime memory downtimeToCheck = delegateGetPastDowntime(_testTarget, staker, i);
            require(downtimeToCheck.startPeriod == downtime.startPeriod &&
                downtimeToCheck.endPeriod == downtime.endPeriod);
        }

        require(delegateGet(_testTarget, this.getSubStakesLength.selector, staker) == info.subStakes.length);
        for (uint256 i = 0; i < info.subStakes.length && i < MAX_CHECKED_VALUES; i++) {
            SubStakeInfo storage subStakeInfo = info.subStakes[i];
            SubStakeInfo memory subStakeInfoToCheck = delegateGetSubStakeInfo(_testTarget, staker, i);
            require(subStakeInfoToCheck.firstPeriod == subStakeInfo.firstPeriod &&
                subStakeInfoToCheck.lastPeriod == subStakeInfo.lastPeriod &&
                subStakeInfoToCheck.periods == subStakeInfo.periods &&
                subStakeInfoToCheck.lockedValue == subStakeInfo.lockedValue);
        }

        // it's not perfect because checks not only slot value but also decoding
        // at least without additional functions
        require(delegateGet(_testTarget, this.totalStakedForAt.selector, staker, bytes32(block.number)) ==
            totalStakedForAt(stakerAddress, block.number));
        require(delegateGet(_testTarget, this.totalStakedAt.selector, bytes32(block.number)) ==
            totalStakedAt(block.number));

        if (info.worker != address(0)) {
            require(address(delegateGet(_testTarget, this.stakerFromWorker.selector, bytes32(uint256(info.worker)))) ==
                stakerFromWorker[info.worker]);
        }
    }

    /// @dev the `onlyWhileUpgrading` modifier works through a call to the parent `finishUpgrade`
    function finishUpgrade(address _target) public override virtual {
        super.finishUpgrade(_target);
        // Create fake period
        lockedPerPeriod[RESERVED_PERIOD] = 111;

        // Create fake worker
        stakerFromWorker[address(0)] = address(this);
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./SafeMath.sol";


/**
* @notice Additional math operations
*/
library AdditionalMath {
    using SafeMath for uint256;

    function max16(uint16 a, uint16 b) internal pure returns (uint16) {
        return a >= b ? a : b;
    }

    function min16(uint16 a, uint16 b) internal pure returns (uint16) {
        return a < b ? a : b;
    }

    /**
    * @notice Division and ceil
    */
    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a.add(b) - 1) / b;
    }

    /**
    * @dev Adds signed value to unsigned value, throws on overflow.
    */
    function addSigned(uint256 a, int256 b) internal pure returns (uint256) {
        if (b >= 0) {
            return a.add(uint256(b));
        } else {
            return a.sub(uint256(-b));
        }
    }

    /**
    * @dev Subtracts signed value from unsigned value, throws on overflow.
    */
    function subSigned(uint256 a, int256 b) internal pure returns (uint256) {
        if (b >= 0) {
            return a.sub(uint256(b));
        } else {
            return a.add(uint256(-b));
        }
    }

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul32(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add16(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub16(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds signed value to unsigned value, throws on overflow.
    */
    function addSigned16(uint16 a, int16 b) internal pure returns (uint16) {
        if (b >= 0) {
            return add16(a, uint16(b));
        } else {
            return sub16(a, uint16(-b));
        }
    }

    /**
    * @dev Subtracts signed value from unsigned value, throws on overflow.
    */
    function subSigned16(uint16 a, int16 b) internal pure returns (uint16) {
        if (b >= 0) {
            return sub16(a, uint16(b));
        } else {
            return add16(a, uint16(-b));
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.7.0;


import "./NuCypherToken.sol";
import "./Math.sol";
import "./Upgradeable.sol";
import "./AdditionalMath.sol";
import "./SafeERC20.sol";


/**
* @notice Contract for calculation of issued tokens
* @dev |v3.3.1|
*/
abstract contract Issuer is Upgradeable {
    using SafeERC20 for NuCypherToken;
    using AdditionalMath for uint32;

    event Donated(address indexed sender, uint256 value);
    /// Issuer is initialized with a reserved reward
    event Initialized(uint256 reservedReward);

    uint128 constant MAX_UINT128 = uint128(0) - 1;

    NuCypherToken public immutable token;
    uint128 public immutable totalSupply;

    // d * k2
    uint256 public immutable mintingCoefficient;
    // k1
    uint256 public immutable lockDurationCoefficient1;
    // k2
    uint256 public immutable lockDurationCoefficient2;
    uint32 public immutable secondsPerPeriod;
    // kmax
    uint16 public immutable maximumRewardedPeriods;

    uint256 public immutable firstPhaseMaxIssuance;
    uint256 public immutable firstPhaseTotalSupply;

    /**
    * Current supply is used in the minting formula and is stored to prevent different calculation
    * for stakers which get reward in the same period. There are two values -
    * supply for previous period (used in formula) and supply for current period which accumulates value
    * before end of period.
    */
    uint128 public previousPeriodSupply;
    uint128 public currentPeriodSupply;
    uint16 public currentMintingPeriod;

    /**
    * @notice Constructor sets address of token contract and coefficients for minting
    * @dev Minting formula for one sub-stake in one period for the first phase
    firstPhaseMaxIssuance * (lockedValue / totalLockedValue) * (k1 + min(allLockedPeriods, kmax)) / k2
    * @dev Minting formula for one sub-stake in one period for the second phase
    (totalSupply - currentSupply) / d * (lockedValue / totalLockedValue) * (k1 + min(allLockedPeriods, kmax)) / k2
    if allLockedPeriods > maximumRewardedPeriods then allLockedPeriods = maximumRewardedPeriods
    * @param _token Token contract
    * @param _hoursPerPeriod Size of period in hours
    * @param _issuanceDecayCoefficient (d) Coefficient which modifies the rate at which the maximum issuance decays,
    * only applicable to Phase 2. d = 365 * half-life / LOG2 where default half-life = 2.
    * See Equation 10 in Staking Protocol & Economics paper
    * @param _lockDurationCoefficient1 (k1) Numerator of the coefficient which modifies the extent 
    * to which a stake's lock duration affects the subsidy it receives. Affects stakers differently. 
    * Applicable to Phase 1 and Phase 2. k1 = k2 * small_stake_multiplier where default small_stake_multiplier = 0.5.  
    * See Equation 8 in Staking Protocol & Economics paper.
    * @param _lockDurationCoefficient2 (k2) Denominator of the coefficient which modifies the extent
    * to which a stake's lock duration affects the subsidy it receives. Affects stakers differently.
    * Applicable to Phase 1 and Phase 2. k2 = maximum_rewarded_periods / (1 - small_stake_multiplier)
    * where default maximum_rewarded_periods = 365 and default small_stake_multiplier = 0.5.
    * See Equation 8 in Staking Protocol & Economics paper.
    * @param _maximumRewardedPeriods (kmax) Number of periods beyond which a stake's lock duration
    * no longer increases the subsidy it receives. kmax = reward_saturation * 365 where default reward_saturation = 1.
    * See Equation 8 in Staking Protocol & Economics paper.
    * @param _firstPhaseTotalSupply Total supply for the first phase
    * @param _firstPhaseMaxIssuance (Imax) Maximum number of new tokens minted per period during Phase 1.
    * See Equation 7 in Staking Protocol & Economics paper.
    */
    constructor(
        NuCypherToken _token,
        uint32 _hoursPerPeriod,
        uint256 _issuanceDecayCoefficient,
        uint256 _lockDurationCoefficient1,
        uint256 _lockDurationCoefficient2,
        uint16 _maximumRewardedPeriods,
        uint256 _firstPhaseTotalSupply,
        uint256 _firstPhaseMaxIssuance
    ) {
        uint256 localTotalSupply = _token.totalSupply();
        require(localTotalSupply > 0 &&
            _issuanceDecayCoefficient != 0 &&
            _hoursPerPeriod != 0 &&
            _lockDurationCoefficient1 != 0 &&
            _lockDurationCoefficient2 != 0 &&
            _maximumRewardedPeriods != 0);
        require(localTotalSupply <= uint256(MAX_UINT128), "Token contract has supply more than supported");

        uint256 maxLockDurationCoefficient = _maximumRewardedPeriods + _lockDurationCoefficient1;
        uint256 localMintingCoefficient = _issuanceDecayCoefficient * _lockDurationCoefficient2;
        require(maxLockDurationCoefficient > _maximumRewardedPeriods &&
            localMintingCoefficient / _issuanceDecayCoefficient ==  _lockDurationCoefficient2 &&
            // worst case for `totalLockedValue * d * k2`, when totalLockedValue == totalSupply
            localTotalSupply * localMintingCoefficient / localTotalSupply == localMintingCoefficient &&
            // worst case for `(totalSupply - currentSupply) * lockedValue * (k1 + min(allLockedPeriods, kmax))`,
            // when currentSupply == 0, lockedValue == totalSupply
            localTotalSupply * localTotalSupply * maxLockDurationCoefficient / localTotalSupply / localTotalSupply ==
                maxLockDurationCoefficient,
            "Specified parameters cause overflow");

        require(maxLockDurationCoefficient <= _lockDurationCoefficient2,
            "Resulting locking duration coefficient must be less than 1");
        require(_firstPhaseTotalSupply <= localTotalSupply, "Too many tokens for the first phase");
        require(_firstPhaseMaxIssuance <= _firstPhaseTotalSupply, "Reward for the first phase is too high");

        token = _token;
        secondsPerPeriod = _hoursPerPeriod.mul32(1 hours);
        lockDurationCoefficient1 = _lockDurationCoefficient1;
        lockDurationCoefficient2 = _lockDurationCoefficient2;
        maximumRewardedPeriods = _maximumRewardedPeriods;
        firstPhaseTotalSupply = _firstPhaseTotalSupply;
        firstPhaseMaxIssuance = _firstPhaseMaxIssuance;
        totalSupply = uint128(localTotalSupply);
        mintingCoefficient = localMintingCoefficient;
    }

    /**
    * @dev Checks contract initialization
    */
    modifier isInitialized()
    {
        require(currentMintingPeriod != 0);
        _;
    }

    /**
    * @return Number of current period
    */
    function getCurrentPeriod() public view returns (uint16) {
        return uint16(block.timestamp / secondsPerPeriod);
    }

    /**
    * @notice Initialize reserved tokens for reward
    */
    function initialize(uint256 _reservedReward, address _sourceOfFunds) external onlyOwner {
        require(currentMintingPeriod == 0);
        // Reserved reward must be sufficient for at least one period of the first phase
        require(firstPhaseMaxIssuance <= _reservedReward);
        currentMintingPeriod = getCurrentPeriod();
        currentPeriodSupply = totalSupply - uint128(_reservedReward);
        previousPeriodSupply = currentPeriodSupply;
        token.safeTransferFrom(_sourceOfFunds, address(this), _reservedReward);
        emit Initialized(_reservedReward);
    }

    /**
    * @notice Function to mint tokens for one period.
    * @param _currentPeriod Current period number.
    * @param _lockedValue The amount of tokens that were locked by user in specified period.
    * @param _totalLockedValue The amount of tokens that were locked by all users in specified period.
    * @param _allLockedPeriods The max amount of periods during which tokens will be locked after specified period.
    * @return amount Amount of minted tokens.
    */
    function mint(
        uint16 _currentPeriod,
        uint256 _lockedValue,
        uint256 _totalLockedValue,
        uint16 _allLockedPeriods
    )
        internal returns (uint256 amount)
    {
        if (currentPeriodSupply == totalSupply) {
            return 0;
        }

        if (_currentPeriod > currentMintingPeriod) {
            previousPeriodSupply = currentPeriodSupply;
            currentMintingPeriod = _currentPeriod;
        }

        uint256 currentReward;
        uint256 coefficient;

        // first phase
        // firstPhaseMaxIssuance * lockedValue * (k1 + min(allLockedPeriods, kmax)) / (totalLockedValue * k2)
        if (previousPeriodSupply + firstPhaseMaxIssuance <= firstPhaseTotalSupply) {
            currentReward = firstPhaseMaxIssuance;
            coefficient = lockDurationCoefficient2;
        // second phase
        // (totalSupply - currentSupply) * lockedValue * (k1 + min(allLockedPeriods, kmax)) / (totalLockedValue * d * k2)
        } else {
            currentReward = totalSupply - previousPeriodSupply;
            coefficient = mintingCoefficient;
        }

        uint256 allLockedPeriods =
            AdditionalMath.min16(_allLockedPeriods, maximumRewardedPeriods) + lockDurationCoefficient1;
        amount = (uint256(currentReward) * _lockedValue * allLockedPeriods) /
            (_totalLockedValue * coefficient);

        // rounding the last reward
        uint256 maxReward = getReservedReward();
        if (amount == 0) {
            amount = 1;
        } else if (amount > maxReward) {
            amount = maxReward;
        }

        currentPeriodSupply += uint128(amount);
    }

    /**
    * @notice Return tokens for future minting
    * @param _amount Amount of tokens
    */
    function unMint(uint256 _amount) internal {
        previousPeriodSupply -= uint128(_amount);
        currentPeriodSupply -= uint128(_amount);
    }

    /**
    * @notice Donate sender's tokens. Amount of tokens will be returned for future minting
    * @param _value Amount to donate
    */
    function donate(uint256 _value) external isInitialized {
        token.safeTransferFrom(msg.sender, address(this), _value);
        unMint(_value);
        emit Donated(msg.sender, _value);
    }

    /**
    * @notice Returns the number of tokens that can be minted
    */
    function getReservedReward() public view returns (uint256) {
        return totalSupply - currentPeriodSupply;
    }

    /// @dev the `onlyWhileUpgrading` modifier works through a call to the parent `verifyState`
    function verifyState(address _testTarget) public override virtual {
        super.verifyState(_testTarget);
        require(uint16(delegateGet(_testTarget, this.currentMintingPeriod.selector)) == currentMintingPeriod);
        require(uint128(delegateGet(_testTarget, this.previousPeriodSupply.selector)) == previousPeriodSupply);
        require(uint128(delegateGet(_testTarget, this.currentPeriodSupply.selector)) == currentPeriodSupply);
    }

}

