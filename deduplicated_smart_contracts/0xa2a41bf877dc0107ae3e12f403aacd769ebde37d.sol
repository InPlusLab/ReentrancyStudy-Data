/**
 *Submitted for verification at Etherscan.io on 2021-09-15
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: IController

interface IController {
    function mint(address, uint256) external;
    function withdraw(address, uint256) external;
    function withdrawVote(address, uint256) external;
    function deposit(address, uint256) external;
    function depositVote(address, uint256) external;
    function totalAssets(address) external view returns (uint256);
    function rewards() external view returns (address);
    function strategies(address) external view returns (address);
    function vaults(address) external view returns (address);
    function setHarvestInfo(address _token, uint256 _harvestReward) external;
}

// Part: IVote

interface IVote {
    function castVote(address _comp, uint256 _proposalId) external;
    function propose(address _comp, address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint256);
    function returnToken(address _comp, address _receiver) external returns (uint256 _amount);
    function proposalThreshold(address _comp) external view returns (uint256);
    function state(address _comp, uint256 _proposalId) external view returns (uint8);
    function proposals(address _comp, uint256 _proposalId) external view returns (uint256 _id, address _proposer,
        uint256 _eta, uint256 _startBlock, uint256 _endBlock, uint256 _forVotes, uint256 _againstVotes, uint256 _abstainVotes, bool _canceled, bool _executed);
}

// Part: OpenZeppelin/[email protected]/Address

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

// Part: OpenZeppelin/[email protected]/IERC20

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

// Part: OpenZeppelin/[email protected]/SafeMath

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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

// File: VoteController.sol

contract VoteController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public governance;
    address public pendingGovernance;
    address public controller;
    address public operator;

    mapping (address => address) public againsts;
    mapping (address => address) public fors;
    mapping (address => address) public abstains;
    mapping (address => address) public proposes;
    mapping (address => address) public governors;
    mapping (address => uint256) public proposalIds;
    mapping (address => uint256) public voteProposalIds;
    mapping (address => uint8) public types;

    constructor (address _controller, address _operator) public {
        governance = msg.sender;
        controller = _controller;
        operator =  _operator;
    }

    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "!pendingGovernance");
        governance = msg.sender;
        pendingGovernance = address(0);
    }
    function setPendingGovernance(address _pendingGovernance) external {
        require(msg.sender == governance, "!governance");
        pendingGovernance = _pendingGovernance;
    }
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
    function setOperator(address _operator) external {
        require(msg.sender == governance, "!governance");
        operator = _operator;
    }
    function setGovernor(address _comp, address _governor) external {
        require(msg.sender == governance, "!governance");
        governors[_comp] = _governor;
    }

    function setAgainst(address _comp, address _against) external {
        require(msg.sender == governance, "!governance");
        againsts[_comp] = _against;
    }
    function setFor(address _comp, address _for) external {
        require(msg.sender == governance, "!governance");
        fors[_comp] = _for;
    }
    function setAbstain(address _comp, address _abstain) external {
        require(msg.sender == governance, "!governance");
        abstains[_comp] = _abstain;
    }
    function setPropose(address _comp, address _propose) external {
        require(msg.sender == governance, "!governance");
        proposes[_comp] = _propose;
    }

    function prepareVote(address _comp, uint256 _proposalId, uint256 _against, uint256 _for, uint256 _abstain) external {
        require(msg.sender == operator || msg.sender == governance, "!operator");
        require(proposalIds[_comp] == 0, "!proposalId");
        // require(types[_comp] == 0, "!types");
        uint256 _amount = _for.add(_against).add(_abstain);
        require(_amount > 0, "!_amount");

        IController(controller).withdrawVote(_comp, _amount);
        proposalIds[_comp] = _proposalId;

        uint8 _type = 0;
        if (_against > 0) {
            address _vote = againsts[_comp];
            _tranferVote(_comp, _vote, _against);
            _type += 4;
        }
        if (_for > 0) {
            address _vote = fors[_comp];
            _tranferVote(_comp, _vote, _for);
            _type += 2;
        }
        if (_abstain > 0) {
            address _vote = abstains[_comp];
            _tranferVote(_comp, _vote, _abstain);
            _type += 1;
        }
        types[_comp] = _type;
    }

    function _tranferVote(address _comp, address _vote, uint256 _amount) internal {
        require(_vote != address(0), "address(0)");
        uint256 _balance = IERC20(_comp).balanceOf(address(this));
        if (_amount > _balance) {
            _amount = _balance;
        }
        IERC20(_comp).safeTransfer(_vote, _amount);
    }

    function returnToken(address _comp, uint256 _proposalId) external {
        require(msg.sender == operator || msg.sender == governance, "!operator");
        require(proposalIds[_comp] == _proposalId, "!proposalId");
        uint8 _type = types[_comp];
        require(_type > 0, "!type");

        proposalIds[_comp] = 0;
        voteProposalIds[_comp] = _proposalId;

        uint256 _totalAmount;
        if (_type >= 4) {
            address _vote = againsts[_comp];
            _totalAmount = IVote(_vote).returnToken(_comp, controller);
            _type -= 4;
        }
        if (_type >= 2) {
            address _vote = fors[_comp];
            uint256 _amount = IVote(_vote).returnToken(_comp, controller);
            _totalAmount = _totalAmount.add(_amount);
            _type -= 2;
        }
        if (_type >= 1) {
            address _vote = abstains[_comp];
            uint256 _amount = IVote(_vote).returnToken(_comp, controller);
            _totalAmount = _totalAmount.add(_amount);
        }

        IController(controller).depositVote(_comp, _totalAmount);
    }

    function castVote(address _comp, uint256 _proposalId) external {
        require(msg.sender == operator || msg.sender == governance, "!operator");
        require(voteProposalIds[_comp] == _proposalId, "!proposalId");
        uint8 _type = types[_comp];
        require(_type > 0, "!type");

        voteProposalIds[_comp] = 0;
        types[_comp] = 0;

        if (_type >= 4) {
            address _vote = againsts[_comp];
            IVote(_vote).castVote(_comp, _proposalId);
            _type -= 4;
        }
        if (_type >= 2) {
            address _vote = fors[_comp];
            IVote(_vote).castVote(_comp, _proposalId);
            _type -= 2;
        }
        if (_type >= 1) {
            address _vote = abstains[_comp];
            IVote(_vote).castVote(_comp, _proposalId);
        }
    }

    function totalAssets(address _token) external view returns (uint256) {
        return IController(controller).totalAssets(_token);
    }

    function state(address _comp, uint256 _proposalId) external view returns (uint8){
        address _vote = fors[_comp];
        return IVote(_vote).state(_comp, _proposalId);
    }

    function proposals(address _comp, uint256 _proposalId) external view returns (uint256 _id, address _proposer,
        uint256 _eta, uint256 _startBlock, uint256 _endBlock, uint256 _forVotes, uint256 _againstVotes, uint256 _abstainVotes, bool _canceled, bool _executed){
        address _vote = fors[_comp];
        return IVote(_vote).proposals(_comp, _proposalId);
    }

    function sweep(address _token) external {
        require(msg.sender == governance, "!governance");

        uint256 _balance = IERC20(_token).balanceOf(address(this));
        address _rewards = IController(controller).rewards();
        IERC20(_token).safeTransfer(_rewards, _balance);
    }

    function setProposalId(address _comp, uint256 _proposalId) external {
        require(msg.sender == governance, "!governance");
        proposalIds[_comp] = _proposalId;
    }

    function setType(address _comp, uint8 _type) external {
        require(msg.sender == governance, "!governance");
        types[_comp] = _type;
    }

    function prepareProposeByAdmin(address _comp) external {
        require(msg.sender == governance, "!governance");

        address _vote = proposes[_comp];
        uint256 _amount = IVote(_vote).proposalThreshold(_comp);
        IController(controller).withdrawVote(_comp, _amount);
        _tranferVote(_comp, _vote, _amount);
    }

    function proposeByAdmin(address _comp, address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description) external returns (uint256) {
        require(msg.sender == governance, "!operator");

        address _vote = proposes[_comp];
        return IVote(_vote).propose(_comp, targets, values, signatures, calldatas, description);
    }

    function returnProposeByAdmin(address _comp) external {
        require(msg.sender == governance, "!operator");

        address _vote = proposes[_comp];
        uint256 _amount = IVote(_vote).returnToken(_comp, controller);
        IController(controller).depositVote(_comp, _amount);
    }

    function prepareVoteByAdmin(address _comp, uint256 _against, uint256 _for, uint256 _abstain) external {
        require(msg.sender == governance, "!governance");

        uint256 _amount = _for.add(_against).add(_abstain);
        IController(controller).withdrawVote(_comp, _amount);

        if (_against > 0) {
            address _vote = againsts[_comp];
            _tranferVote(_comp, _vote, _against);
        }
        if (_for > 0) {
            address _vote = fors[_comp];
            _tranferVote(_comp, _vote, _for);
        }
        if (_abstain > 0) {
            address _vote = abstains[_comp];
            _tranferVote(_comp, _vote, _abstain);
        }
    }

    function returnTokenByAdmin(address _comp) external {
        require(msg.sender == governance, "!governance");

        address _vote = againsts[_comp];
        uint256 _totalAmount = IVote(_vote).returnToken(_comp, controller);

        _vote = fors[_comp];
        uint256 _amount = IVote(_vote).returnToken(_comp, controller);
        _totalAmount = _totalAmount.add(_amount);

        _vote = abstains[_comp];
        _amount = IVote(_vote).returnToken(_comp, controller);
        _totalAmount = _totalAmount.add(_amount);

        IController(controller).depositVote(_comp, _totalAmount);
    }

    function voteByAdmin(address _comp, uint256 _proposalId) external {
        require(msg.sender == governance, "!governance");

        address _vote = againsts[_comp];
        IVote(_vote).castVote(_comp, _proposalId);

        _vote = fors[_comp];
        IVote(_vote).castVote(_comp, _proposalId);

        _vote = abstains[_comp];
        IVote(_vote).castVote(_comp, _proposalId);
    }
}