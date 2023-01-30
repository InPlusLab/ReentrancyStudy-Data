/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.4;

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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return b - a;
        }
        return a - b;
    }
}

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
    function decimals() external view returns (uint8);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
        assembly {
            size := extcodesize(account)
        }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
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
        _callOptionalReturn(
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
        _callOptionalReturn(
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
        _callOptionalReturn(
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
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
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

interface Executor {
    function execute(
        uint256,
        uint256,
        uint256,
        uint256
    ) external;
}

interface IMintable {
    function mint(address account, uint256 amount) external;
}

contract KunWrapper {
    using SafeMath for uint256;

    using SafeERC20 for IERC20;

    /// @notice ��������
    uint256 private _totalSupply;

    /// @notice �û�������
    mapping(address => uint256) private _balances;

    /// @notice kun ���ҵĵ�ַ
    address public kun;

    /// @notice ��������
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /// @notice �û�������
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /// @notice ��Ѻ
    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        IERC20(kun).safeTransferFrom(msg.sender, address(this), amount);
    }

    /// @notice �˳���Ѻ
    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        IERC20(kun).safeTransfer(msg.sender, amount);
    }
}

contract KunStakePool is KunWrapper, Initializable {
    using SafeERC20 for IERC20;

    using SafeMath for uint256;

    /// @notice ����Ա
    address public owner;

    /// @notice ���ʼʱ��
    uint256 public startTime;

    /// @notice ������¼�
    uint256 public periodFinish;

    /// @notice �ϴθ���ʱ��
    uint256 public lastUpdateTime;

    /// @notice ÿ��λ�� token ��õĽ���ֵ
    uint256 public rewardPerTokenStored;

    /// @notice ˫��ʱ��
    uint256 public DW_TIME;

    /// @notice ����ʱ��
    uint256 public DURATION;

    /// @notice �û�ÿ��λ�� token �ѻ�õĽ���ֵ
    mapping(address => uint256) public userRewardPerTokenPaid;

    /// @notice �û���õĽ���
    mapping(address => uint256) public rewards;

    /// @notice ���� => �᰸
    mapping(uint256 => Proposal) public proposals;

    /// @notice �û���ַ => ��ͶƱ����
    mapping(address => uint256) public votes;

    /// @notice �û���ַ => �Ƿ�ע��ͶƱ
    mapping(address => bool) public voters;

    /// @notice �û���ַ => �û��ֲ�����ʱ��
    mapping(address => uint256) public voteLock;

    /// @notice Ʊ������
    uint256 public totalVotes;

    /// @notice �᰸����
    uint256 public proposalCount;

    /// @notice ��Լ����
    bool public breaker;

    /// @notice ͶƱ��������
    uint256 public lock;

    /// @notice ͶƱ����ռ��
    uint256 public quorum;

    /// @notice �����᰸�����������С����
    uint256 public minimum;

    /// @notice �᰸����ʱ��
    uint256 public period; // voting period in blocks

    /// @notice ˫����Ϣ
    /// @param startTime ��ʼʱ��
    /// @param totalStake ����Ѻ��
    /// @param stakeTarget ��ѺĿ��
    /// @param totalReward �ܽ���
    /// @param rewardRate �����ַ�����
    struct DWInfo {
        uint256 startTime;
        uint256 totalStake;
        uint256 stakeTarget;
        uint256 totalReward;
        uint256 rewardRate;
    }

    /// @notice �᰸��Ϣ
    /// @param id �᰸id
    /// @param proposer ������
    /// @param forVotes �޳�Ʊ���û���ַ => ͶƱ����
    /// @param againstVotes ����Ʊ���û���ַ => ͶƱ����
    /// @param totalForVotes �޳�Ʊ����
    /// @param totalAgainstVotes ����Ʊ����
    /// @param start �᰸��ʼ����
    /// @param end �᰸��������
    /// @param executor ִ�к�Լ
    /// @param hash �᰸������Ϣ
    /// @param totalVotesAvailable Ʊ������
    /// @param quorum ͶƱ����ռ��
    /// @param quorumRequired �᰸ͨ�����������ռ��
    /// @param open �᰸�Ƿ���
    struct Proposal {
        uint256 id;
        address proposer;
        mapping(address => uint256) forVotes;
        mapping(address => uint256) againstVotes;
        uint256 totalForVotes;
        uint256 totalAgainstVotes;
        uint256 start; // block start;
        uint256 end; // start + period
        address executor;
        string hash;
        uint256 totalVotesAvailable;
        uint256 quorum;
        uint256 quorumRequired;
        bool open;
    }

    /// @notice ˫���� => ˫����Ϣ
    mapping(uint256 => DWInfo) public dwInfo;

    /// @dev ��ֹ����
    bool internal _notEntered;

    /// @notice �¼�������Աȡ�غ�Լ�е��������
    /// @param kun kun ���ҵ�ַ
    /// @param balance ���
    event ClaimTokens(address kun, uint256 balance);

    /// @notice �¼����û���Ѻ
    /// @param user �û���ַ
    /// @param amount ��Ѻ����
    event Staked(address indexed user, uint256 amount);

    /// @notice �¼����û�ȡ��һ����������Ѻ
    /// @param user �û���ַ
    /// @param amount ��Ѻ����
    event Withdrawn(address indexed user, uint256 amount);

    /// @notice �¼��������ַ�
    /// @param user �û���ַ
    /// @param reward �����ַ�����
    event RewardPaid(address indexed user, uint256 reward);

    /// @notice �¼������᰸
    /// @param id �᰸id
    /// @param creator ������
    /// @param start ��ʼ����
    /// @param duration ʱ��
    /// @param executor ִ�к�Լ
    event NewProposal(
        uint256 id,
        address creator,
        uint256 start,
        uint256 duration,
        address executor
    );

    /// @notice �¼������᰸
    /// @param voter ͶƱ��
    /// @param votes �û���ͶƱ����
    /// @param totalVotes ��Ʊ��
    event RegisterVoter(address voter, uint256 votes, uint256 totalVotes);

    /// @notice �¼�������ͶƱȨ��
    /// @param voter ͶƱ��
    /// @param votes �û���ͶƱ����
    /// @param totalVotes ��Ʊ��
    event RevokeVoter(address voter, uint256 votes, uint256 totalVotes);

    /// @notice �¼���ͶƱ
    /// @param id �᰸id
    /// @param voter ͶƱ��
    /// @param vote �Ƿ��޳�
    /// @param weight ͶƱȨ��
    event Vote(
        uint256 indexed id,
        address indexed voter,
        bool vote,
        uint256 weight
    );

    /// @notice �¼����᰸����
    /// @param id �᰸id
    /// @param _for ͬ������ռ��
    /// @param _against ��������ռ��
    /// @param quorumReached �Ƿ�ͨ��
    event ProposalFinished(
        uint256 indexed id,
        uint256 _for,
        uint256 _against,
        bool quorumReached
    );

    /// @notice ��ʼ������
    /// @param _owner ����Ա��ַ
    /// @param _kun kun ���ҵ�ַ
    /// @param _startTime ���ʼʱ��
    function initialize(
        address _owner,
        address _kun,
        uint256 _startTime
    ) public initializer {
        owner = _owner;
        kun = _kun;
        startTime = _startTime;
        periodFinish = startTime.add(DURATION);
        period = 17280; // voting period in blocks
        lock = 17280; // vote lock in block
        minimum = 1000000000000000000;
        quorum = 2000;
        breaker = false;
        _notEntered = true;
        DW_TIME = 14 days;
        DURATION = 672 days;
    }

    modifier checkStart() {
        require(block.timestamp > startTime, "not start");
        _;
    }

    modifier updateReward(address account) {
        if (block.timestamp >= startTime) {
            rewardPerTokenStored = rewardPerToken();
            lastUpdateTime = lastTimeRewardApplicable();
            if (account != address(0)) {
                rewards[account] = earned(account);
                userRewardPerTokenPaid[account] = rewardPerTokenStored;
            }
        }
        _;
    }

    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /// @notice ���ù���Ա
    /// @param _owner �¹���Ա
    function setOwner(address _owner) public onlyOwner {
        require(msg.sender == owner, "!owner");
        owner = _owner;
    }

    /// @notice ��ȡʱ��
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /// @notice ����ÿ�� token ���Ի�ý����������漰���������ݣ�
    function rewardPerToken() internal returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        uint256 res = rewardPerTokenStored;
        uint256 currentDWNumber = getDoubleWeekNumber(
            lastTimeRewardApplicable()
        );
        if (currentDWNumber == 1) {
            // ��һ��˫��
            res = res.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(dwInfo[1].rewardRate)
                    .mul(1e18)
                    .div(totalSupply()) //
            );
        } else {
            // ��ȡ�ϴβ�����˫����
            uint256 lastOpDWNumber = getDoubleWeekNumber(lastUpdateTime);
            if (lastOpDWNumber < currentDWNumber) {
                // ����ϴβ���ʱ���뱾�β���ʱ�䲻��ͬһ +˫��+ �ڣ���ô�����������
                // 1���ϴβ����� +˫��+ �� ���β����� +˫��+ ����
                // ���ϴβ������ڵ� n ��˫�ܣ��������ڵ� n + 1 ��˫��

                // �����Ǹ��µ� n ��˫��ʱ������ʱ���� n �Ľ���ʱ��� rewardPerToken
                res = res.add(
                    dwInfo[lastOpDWNumber + 1]
                        .startTime
                        .sub(lastUpdateTime)
                        .mul(dwInfo[lastOpDWNumber].rewardRate)
                        .mul(1e18)
                        .div(totalSupply())
                );
                dwInfo[lastOpDWNumber].totalStake = totalSupply();
                // 2���ϴβ����� +˫��+ �� ���β����� +˫��+ �м���� m �� +˫��+
                // ���ϴβ������ڵ� n ��˫�ܣ��������ڵ� n + m ��˫�ܣ�m > 1��

                // �����Ǹ��µ� n ��˫�ܺ�m ��˫�ܵ� rewardPerToken
                for (uint256 i = lastOpDWNumber + 1; i < currentDWNumber; ++i) {
                    DWInfo memory lastOpDWInfo = dwInfo[i - 1];
                    // DWInfo memory lastDWInfo = dwInfo[i];

                    uint256 lastRewardRate = (
                        lastOpDWInfo.totalStake >= lastOpDWInfo.stakeTarget
                            ? dwInfo[i].totalReward
                            : lastOpDWInfo
                                .totalStake
                                .mul(dwInfo[i].totalReward)
                                .div(lastOpDWInfo.stakeTarget)
                    ) / DW_TIME;

                    dwInfo[i].rewardRate = lastRewardRate;
                    dwInfo[i].totalStake = totalSupply();

                    res = res.add(
                        DW_TIME.mul(dwInfo[i].rewardRate).mul(1e18).div(
                            totalSupply()
                        )
                    );
                }
                lastUpdateTime = dwInfo[currentDWNumber].startTime;
                // �����Ǹ����ϸ� +˫��+ �����ݼ��㱾�� +˫��+ �� rewardRate
                DWInfo memory prevDWInfo = dwInfo[currentDWNumber - 1];
                uint256 currentRewardRate = (
                    prevDWInfo.totalStake >= prevDWInfo.stakeTarget
                        ? dwInfo[currentDWNumber].totalReward
                        : prevDWInfo
                            .totalStake
                            .mul(dwInfo[currentDWNumber].totalReward)
                            .div(prevDWInfo.stakeTarget)
                ) / DW_TIME;
                dwInfo[currentDWNumber].rewardRate = currentRewardRate;
            }
            // ���±���˫���ڣ��ϴθ���ʱ�䵽����ʱ��� rewardPerToken
            res = res.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(dwInfo[currentDWNumber].rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
        }
        return res;
    }

    /// @notice ����ÿ�� token ���Ի�ý������������������ݣ�������ʾ��
    function readRewardPerToken() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return 0;
        }
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        uint256 res = rewardPerTokenStored;
        uint256 currentDWNumber = getDoubleWeekNumber(
            lastTimeRewardApplicable()
        );

        DWInfo[] memory infos = new DWInfo[](currentDWNumber + 1);
        uint256 tmpLastUpdateTime = lastUpdateTime;

        if (currentDWNumber == 1) {
            // ��һ��˫��
            res = res.add(
                lastTimeRewardApplicable()
                    .sub(tmpLastUpdateTime)
                    .mul(dwInfo[1].rewardRate)
                    .mul(1e18)
                    .div(totalSupply()) //
            );
        } else {
            for (uint256 i = 1; i <= currentDWNumber; ++i) {
                infos[i] = dwInfo[i];
            }

            // ��ȡ�ϴβ�����˫����
            uint256 lastOpDWNumber = getDoubleWeekNumber(tmpLastUpdateTime);
            if (lastOpDWNumber < currentDWNumber) {
                // ����ϴβ���ʱ���뱾�β���ʱ�䲻��ͬһ +˫��+ �ڣ���ô�����������
                // 1���ϴβ����� +˫��+ �� ���β����� +˫��+ ����
                // ���ϴβ������ڵ� n ��˫�ܣ��������ڵ� n + 1 ��˫��

                // �����Ǹ��µ� n ��˫��ʱ������ʱ���� n �Ľ���ʱ��� rewardPerToken
                res = res.add(
                    infos[lastOpDWNumber + 1]
                        .startTime
                        .sub(tmpLastUpdateTime)
                        .mul(infos[lastOpDWNumber].rewardRate)
                        .mul(1e18)
                        .div(totalSupply())
                );
                infos[lastOpDWNumber].totalStake = totalSupply();
                // 2���ϴβ����� +˫��+ �� ���β����� +˫��+ �м���� m �� +˫��+
                // ���ϴβ������ڵ� n ��˫�ܣ��������ڵ� n + m ��˫�ܣ�m > 1��

                // �����Ǹ��µ� n ��˫�ܺ�m ��˫�ܵ� rewardPerToken
                for (uint256 i = lastOpDWNumber + 1; i < currentDWNumber; ++i) {
                    DWInfo memory lastOpDWInfo = infos[i - 1];
                    // DWInfo memory lastDWInfo = infos[i];

                    uint256 lastRewardRate = (
                        lastOpDWInfo.totalStake >= lastOpDWInfo.stakeTarget
                            ? infos[i].totalReward
                            : lastOpDWInfo
                                .totalStake
                                .mul(infos[i].totalReward)
                                .div(lastOpDWInfo.stakeTarget)
                    ) / DW_TIME;

                    infos[i].rewardRate = lastRewardRate;
                    infos[i].totalStake = totalSupply();

                    res = res.add(
                        DW_TIME.mul(infos[i].rewardRate).mul(1e18).div(
                            totalSupply()
                        )
                    );
                }
                tmpLastUpdateTime = infos[currentDWNumber].startTime;
                // �����Ǹ����ϸ� +˫��+ �����ݼ��㱾�� +˫��+ �� rewardRate
                DWInfo memory prevDWInfo = infos[currentDWNumber - 1];
                uint256 currentRewardRate = (
                    prevDWInfo.totalStake >= prevDWInfo.stakeTarget
                        ? dwInfo[currentDWNumber].totalReward
                        : prevDWInfo
                            .totalStake
                            .mul(dwInfo[currentDWNumber].totalReward)
                            .div(prevDWInfo.stakeTarget)
                ) / DW_TIME;
                infos[currentDWNumber].rewardRate = currentRewardRate;
            }
            // ���±���˫���ڣ��ϴθ���ʱ�䵽����ʱ��� rewardPerToken
            res = res.add(
                lastTimeRewardApplicable()
                    .sub(tmpLastUpdateTime)
                    .mul(infos[currentDWNumber].rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
        }
        return res;
    }

    /// @notice �����û����Ի�õĽ�������
    function earned(address account) internal returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    /// @notice �����û����Ի�õĽ�������������ҳ����ʾ��
    function readEarned(address account) public view returns (uint256) {
        if (block.timestamp < startTime) {
            return 0;
        }
        return
            balanceOf(account)
                .mul(readRewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    /// @notice ���ú�Լ����
    /// @param _breaker ��Լ����
    function setBreaker(bool _breaker) external onlyOwner {
        breaker = _breaker;
    }

    /// @notice ����ͶƱ����ռ��
    /// @param _quorum ��Լ����
    function setQuorum(uint256 _quorum) public onlyOwner {
        quorum = _quorum;
    }

    /// @notice �����᰸��С��������
    /// @param _minimum ��С��������
    function setMinimum(uint256 _minimum) public onlyOwner {
        minimum = _minimum;
    }

    /// @notice �����᰸����ʱ��
    /// @param _period �᰸����ʱ��
    function setPeriod(uint256 _period) public onlyOwner {
        period = _period;
    }

    /// @notice ����ͶƱ��������
    /// @param _lock ͶƱ��������
    function setLock(uint256 _lock) public onlyOwner {
        lock = _lock;
    }

    /// @notice �û�ע��ͶƱȨ��
    function register() public {
        require(voters[msg.sender] == false, "voter");
        voters[msg.sender] = true;
        votes[msg.sender] = balanceOf(msg.sender);
        totalVotes = totalVotes.add(votes[msg.sender]);
        emit RegisterVoter(msg.sender, votes[msg.sender], totalVotes);
    }

    /// @notice �û�����ͶƱȨ��
    function revoke() public {
        require(voters[msg.sender] == true, "!voter");
        voters[msg.sender] = false;
        if (totalVotes < votes[msg.sender]) {
            //edge case, should be impossible, but this is defi
            totalVotes = 0;
        } else {
            totalVotes = totalVotes.sub(votes[msg.sender]);
        }
        emit RevokeVoter(msg.sender, votes[msg.sender], totalVotes);
        votes[msg.sender] = 0;
    }

    /// @notice �����᰸
    /// @param executor ִ�к�Լ
    /// @param hash �᰸������Ϣ
    function propose(address executor, string memory hash) public {
        require(votesOf(msg.sender) > minimum, "<minimum");
        proposals[proposalCount++] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            totalForVotes: 0,
            totalAgainstVotes: 0,
            start: block.number,
            end: period.add(block.number),
            executor: executor,
            hash: hash,
            totalVotesAvailable: totalVotes,
            quorum: 0,
            quorumRequired: quorum,
            open: true
        });

        emit NewProposal(
            proposalCount,
            msg.sender,
            block.number,
            period,
            executor
        );
        voteLock[msg.sender] = lock.add(block.number);
    }

    /// @notice ִ���᰸
    /// @param id �᰸id
    function execute(uint256 id) public {
        (uint256 _for, uint256 _against, uint256 _quorum) = getStats(id);
        require(proposals[id].quorumRequired < _quorum, "!quorum");
        require(proposals[id].end < block.number, "!end");
        if (proposals[id].open == true) {
            tallyVotes(id);
        }
        Executor(proposals[id].executor).execute(id, _for, _against, _quorum);
    }

    /// @notice �û���ͶƱ����
    /// @param voter �û���ַ
    function votesOf(address voter) public view returns (uint256) {
        return votes[voter];
    }

    /// @notice ��ȡ�᰸��ͶƱ��Ϣ
    /// @param id �᰸id
    function getStats(uint256 id)
        public
        view
        returns (
            uint256 _for,
            uint256 _against,
            uint256 _quorum
        )
    {
        _for = proposals[id].totalForVotes;
        _against = proposals[id].totalAgainstVotes;

        uint256 _total = _for.add(_against);
        _for = _for.mul(10000).div(_total);
        _against = _against.mul(10000).div(_total);

        _quorum = _total.mul(10000).div(proposals[id].totalVotesAvailable);
    }

    /// @notice ��ȡ�û����᰸��ͶƱ��Ϣ
    /// @param id �᰸id
    /// @param voter ͶƱ��
    function getVoterStats(uint256 id, address voter)
        public
        view
        returns (uint256, uint256)
    {
        return (
            proposals[id].forVotes[voter],
            proposals[id].againstVotes[voter]
        );
    }

    /// @notice �᰸��ɣ�������Ϣ
    /// @param id �᰸id
    function tallyVotes(uint256 id) public {
        require(proposals[id].open == true, "!open");
        require(proposals[id].end < block.number, "!end");

        (uint256 _for, uint256 _against, ) = getStats(id);
        bool _quorum = false;
        if (proposals[id].quorum >= proposals[id].quorumRequired) {
            _quorum = true;
        }
        proposals[id].open = false;
        emit ProposalFinished(id, _for, _against, _quorum);
    }

    /// @notice �����û����Ի�õĽ�������������ҳ����ʾ��
    /// @param _startTime ���ÿ�ʼʱ��
    function setStartTime(uint256 _startTime) external onlyOwner {
        startTime = _startTime;
        periodFinish = startTime.add(DURATION);
    }

    /// @notice Ͷ�޳�Ʊ
    /// @param id �᰸id
    function voteFor(uint256 id) public {
        require(proposals[id].start < block.number, "<start");
        require(proposals[id].end > block.number, ">end");

        uint256 _against = proposals[id].againstVotes[msg.sender];
        if (_against > 0) {
            proposals[id].totalAgainstVotes = proposals[id]
                .totalAgainstVotes
                .sub(_against);
            proposals[id].againstVotes[msg.sender] = 0;
        }

        uint256 vote = votesOf(msg.sender).sub(
            proposals[id].forVotes[msg.sender]
        );
        proposals[id].totalForVotes = proposals[id].totalForVotes.add(vote);
        proposals[id].forVotes[msg.sender] = votesOf(msg.sender);

        proposals[id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[id].totalForVotes.add(
            proposals[id].totalAgainstVotes
        );
        proposals[id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[msg.sender] = lock.add(block.number);

        emit Vote(id, msg.sender, true, vote);
    }

    /// @notice Ͷ����Ʊ
    /// @param id �᰸id
    function voteAgainst(uint256 id) public {
        require(proposals[id].start < block.number, "<start");
        require(proposals[id].end > block.number, ">end");

        uint256 _for = proposals[id].forVotes[msg.sender];
        if (_for > 0) {
            proposals[id].totalForVotes = proposals[id].totalForVotes.sub(_for);
            proposals[id].forVotes[msg.sender] = 0;
        }

        uint256 vote = votesOf(msg.sender).sub(
            proposals[id].againstVotes[msg.sender]
        );
        proposals[id].totalAgainstVotes = proposals[id].totalAgainstVotes.add(
            vote
        );
        proposals[id].againstVotes[msg.sender] = votesOf(msg.sender);

        proposals[id].totalVotesAvailable = totalVotes;
        uint256 _votes = proposals[id].totalForVotes.add(
            proposals[id].totalAgainstVotes
        );
        proposals[id].quorum = _votes.mul(10000).div(totalVotes);

        voteLock[msg.sender] = lock.add(block.number);

        emit Vote(id, msg.sender, false, vote);
    }

    /// @notice �û���Ѻ
    /// @param amount ��Ѻ����
    function stake(uint256 amount)
        public
        override
        updateReward(msg.sender)
        nonReentrant
    {
        require(amount > 0, "Cannot stake 0");
        if (voters[msg.sender] == true) {
            votes[msg.sender] = votes[msg.sender].add(amount);
            totalVotes = totalVotes.add(amount);
        }
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    /// @notice �û�ȡ��һ����������Ѻ����
    /// @param amount ȡ������
    function withdraw(uint256 amount)
        public
        override
        updateReward(msg.sender)
        nonReentrant
    {
        require(amount > 0, "Cannot withdraw 0");
        if (voters[msg.sender] == true) {
            votes[msg.sender] = votes[msg.sender].sub(amount);
            totalVotes = totalVotes.sub(amount);
        }
        if (!breaker) {
            require(voteLock[msg.sender] < block.number, "!locked");
        }
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    /// @notice �û��˳����ȡ��������Ѻ�����뽱��
    function exit() external checkStart nonReentrant {
        if (voters[msg.sender] == true) {
            votes[msg.sender] = votes[msg.sender].sub(balanceOf(msg.sender));
            totalVotes = totalVotes.sub(balanceOf(msg.sender));
        }
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    /// @notice �û���ȡ��������
    function getReward()
        public
        updateReward(msg.sender)
        checkStart
        nonReentrant
    {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            IMintable(kun).mint(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /// @notice ����ʱ�����ȡ˫����
    /// @param timestamp ʱ���
    function getDoubleWeekNumber(uint256 timestamp)
        public
        view
        returns (uint256)
    {
        return (timestamp - startTime) / DW_TIME + 1;
    }

    /// @notice ���û��Ϣ
    /// @param dw ÿ��˫�ܵ����
    /// @param _startTime ÿ��˫�ܵĿ�ʼʱ��
    /// @param _stakeTarget ÿ��˫�ܵ���ѺĿ��
    /// @param _totalReward ÿ��˫�ܵĽ�������
    function setDWInfo(
        uint256[] calldata dw,
        uint256[] calldata _startTime,
        uint256[] calldata _stakeTarget,
        uint256[] calldata _totalReward
    ) external onlyOwner {
        uint256 length = dw.length;
        require(
            length == _startTime.length &&
                length == _stakeTarget.length &&
                length == _totalReward.length,
            "Invalid input"
        );
        for (uint256 i = 0; i < length; ++i) {
            dwInfo[dw[i]].startTime = _startTime[i];
            dwInfo[dw[i]].stakeTarget = _stakeTarget[i];
            dwInfo[dw[i]].totalReward = _totalReward[i];
        }
    }

    /// @notice ���õ�һ�ܵķַ�����
    function setFirstDWRewardRate() external onlyOwner {
        dwInfo[1].rewardRate = dwInfo[1].totalReward / DW_TIME;
        lastUpdateTime = dwInfo[1].startTime;
    }

    /// @notice ���� kun ���ҵ�ַ
    /// @param _kun kun ���ҵ�ַ
    function setKun(address _kun) external onlyOwner {
        kun = _kun;
    }

    function setDWTime(uint256 _dwTime) public onlyOwner {
        DW_TIME = _dwTime;
    }

    function setDuration(uint256 _duration) public onlyOwner {
        DURATION = _duration;
    }
}