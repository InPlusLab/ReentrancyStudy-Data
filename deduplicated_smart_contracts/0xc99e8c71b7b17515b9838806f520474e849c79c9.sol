/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.5;


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "add: +");

        return c;
    }
    function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "sub: -");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "mul: *");

        return c;
    }
    function mul(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "div: /");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

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
    function callOptionalReturn(IERC20 token, bytes memory data) private {
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IYearnVault {
    function getPricePerFullShare() external view returns (uint);
    function deposit(uint amount) external;
    function withdraw(uint amount) external;
    function token() external view returns (address);
}

contract Gauge is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    IERC20 public constant PICKLE = IERC20(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);
    address public constant TREASURY = address(0x066419EaEf5DE53cc5da0d8702b990c5bc7D1AB3);
    
    IERC20 public immutable TOKEN;
    IERC20 public immutable UNDERLYING;
    address public immutable DISTRIBUTION;
    uint256 public constant DURATION = 7 days;
    
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    
    uint public constant PERF = 3000;
    uint public constant BASE = 10000;
    
    
    modifier onlyDistribution() {
        require(msg.sender == DISTRIBUTION, "Caller is not RewardsDistribution contract");
        _;
    }
    
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => uint) private _base;
    
    uint public getPricePerFullShare;
    
    function update() public {
        IERC20 _token = TOKEN;
        uint _new = IYearnVault(address(_token)).getPricePerFullShare();
        if (_new > getPricePerFullShare) {
            uint _balance = _token.balanceOf(address(this));
            uint _yield = _new.sub(getPricePerFullShare);
            uint _profit = _balance.mul(_yield).mul(PERF).div(BASE).div(1e18);
            _token.safeTransfer(TREASURY, _profit);
            getPricePerFullShare = _new;
        }
    }
    
    constructor(address _token) {
        TOKEN = IERC20(_token);
        UNDERLYING = IERC20(IYearnVault(_token).token());
        DISTRIBUTION = msg.sender;
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(DURATION);
    }
    
    function depositUnderlyingAll() external {
        _depositUnderlying(UNDERLYING.balanceOf(msg.sender));
    }
    
    function depositUnderlying(uint amount) external {
        _depositUnderlying(amount);
    }
    
    function _depositUnderlying(uint amount) internal {
        IERC20 _underlying = UNDERLYING;
        _underlying.safeTransferFrom(msg.sender, address(this), amount);
        IERC20 _token = TOKEN;
        _underlying.safeApprove(address(_token), amount);
        uint _balance = _token.balanceOf(address(this));
        update();
        IYearnVault(address(_token)).deposit(amount);
        uint _received = _token.balanceOf(address(this)).sub(_balance);
        _deposit(_received, _balance);
    }
    
    function depositAll() external {
        uint _balance = TOKEN.balanceOf(msg.sender);
        _deposit(_balance, TOKEN.balanceOf(address(this)));
        update();
        TOKEN.safeTransferFrom(msg.sender, address(this), _balance);
    }
    
    function deposit(uint256 amount) external {
        _deposit(amount, TOKEN.balanceOf(address(this)));
        update();
        TOKEN.safeTransferFrom(msg.sender, address(this), amount);
    }
    
    function _deposit(uint amount, uint balance) internal nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        uint shares = 0;
        if (balance == 0) {
            shares = amount;
        } else {
            shares = (amount.mul(_totalSupply)).div(balance);
        }
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Staked(msg.sender, amount);
    }
    
    function withdrawUnderlyingAll() external {
        _withdrawUnderlying(_balances[msg.sender]);
    }
    
    function withdrawUnderlying(uint amount) external {
        _withdrawUnderlying(amount);
    }
    
    function _withdrawUnderlying(uint amount) internal {
        uint _r = _withdraw(amount);
        IERC20 _token = TOKEN;
        IERC20 _underlying = UNDERLYING;
        uint _balance = _underlying.balanceOf(address(this));
        IYearnVault(address(_token)).withdraw(_r);
        _balance = _underlying.balanceOf(address(this)).sub(_balance);
        _underlying.safeTransfer(msg.sender, _balance);
    }
    
    function withdrawAll() external {
        uint _amount = _balances[msg.sender];
        uint _r = _withdraw(_amount);
        TOKEN.safeTransfer(msg.sender, _r);
    }

    function withdraw(uint256 amount) external {
        uint _r = _withdraw(amount);
        TOKEN.safeTransfer(msg.sender, _r);
    }
    
    function _withdraw(uint amount) internal nonReentrant updateReward(msg.sender) returns (uint) {
        require(amount > 0, "Cannot withdraw 0");
        uint _r = (TOKEN.balanceOf(address(this)).mul(amount)).div(_totalSupply);
        _totalSupply = _totalSupply.sub(_r);
        _balances[msg.sender] = _balances[msg.sender].sub(_r);
        emit Withdrawn(msg.sender, _r);
        update();
        return _r;
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            PICKLE.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        uint _r = _withdraw(_balances[msg.sender]);
        TOKEN.safeTransfer(msg.sender, _r);
        getReward();
    }
    
    function notifyRewardAmount(uint256 reward) external onlyDistribution updateReward(address(0)) {
        PICKLE.safeTransferFrom(DISTRIBUTION, address(this), reward);
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(DURATION);
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint balance = PICKLE.balanceOf(address(this));
        require(rewardRate <= balance.div(DURATION), "Provided reward too high");

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
}

interface MasterChef {
    function deposit(uint, uint) external;
    function withdraw(uint, uint) external;
    function userInfo(uint, address) external view returns (uint, uint);
}

contract ProtocolGovernance {
    /// @notice governance address for the governance contract
    address public governance;
    address public pendingGovernance;
    
    /**
     * @notice Allows governance to change governance (for future upgradability)
     * @param _governance new governance address to set
     */
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "setGovernance: !gov");
        pendingGovernance = _governance;
    }

    /**
     * @notice Allows pendingGovernance to accept their role as governance (protection pattern)
     */
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "acceptGovernance: !pendingGov");
        governance = pendingGovernance;
    }
}

contract MasterDill {
    using SafeMath for uint;

    /// @notice EIP-20 token name for this token
    string public constant name = "Master DILL";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "mDILL";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Total number of tokens in circulation
    uint public totalSupply = 1e18;

    mapping (address => mapping (address => uint)) internal allowances;
    mapping (address => uint) internal balances;

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint amount);
    
    constructor() {
        balances[msg.sender] = 1e18;
        emit Transfer(address(0x0), msg.sender, 1e18);
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender) external view returns (uint) {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(address src, address dst, uint amount) external returns (bool) {
        address spender = msg.sender;
        uint spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != uint(-1)) {
            uint newAllowance = spenderAllowance.sub(amount, "transferFrom: exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        require(src != address(0), "_transferTokens: zero address");
        require(dst != address(0), "_transferTokens: zero address");

        balances[src] = balances[src].sub(amount, "_transferTokens: exceeds balance");
        balances[dst] = balances[dst].add(amount, "_transferTokens: overflows");
        emit Transfer(src, dst, amount);
    }
}

contract GaugeProxy is ProtocolGovernance {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    MasterChef public constant MASTER = MasterChef(0xbD17B1ce622d73bD438b9E658acA5996dc394b0d);
    IERC20 public constant DILL = IERC20(0xbBCf169eE191A1Ba7371F30A1C344bFC498b29Cf);
    IERC20 public constant PICKLE = IERC20(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);
    
    IERC20 public immutable TOKEN;
    
    uint public pid;
    uint public totalWeight;
    
    address[] internal _tokens;
    mapping(address => address) public gauges; // token => gauge
    mapping(address => uint) public weights; // token => weight
    mapping(address => uint) public votes; // msg.sender => votes
    mapping(address => address) public tokenVote;// g.sender => token
    
    function tokens() external view returns (address[] memory) {
        return _tokens;
    }
    
    function getGauge(address _token) external view returns (address) {
        return gauges[_token];
    }
    
    constructor() {
        TOKEN = IERC20(address(new MasterDill()));
        governance = msg.sender;
    }
    
    // Reset votes to 0
    function reset() public {
        address _token = tokenVote[msg.sender];
        uint _votes = votes[msg.sender];
        
        if (_votes > 0) {
            totalWeight = totalWeight.sub(_votes);
            weights[_token] = weights[_token].sub(_votes);
            
            tokenVote[msg.sender] = address(0x0);
            votes[msg.sender] = 0;
        }
    }
    
    
    // Vote with DILL on a gauge
    function vote(address _token) external {
        address _gauge = gauges[_token];
        if (_gauge != address(0x0)) {
            reset();
            
            uint _weight = DILL.balanceOf(msg.sender);
            totalWeight = totalWeight.add(_weight);
            weights[_token] = weights[_token].add(_weight);
            tokenVote[msg.sender] = _token;
            votes[msg.sender] = _weight;
        }
    }
    
    // Add new token gauge
    function addGauge(address _token) external {
        require(msg.sender == governance, "!gov");
        require(gauges[_token] == address(0x0), "exists");
        gauges[_token] = address(new Gauge(_token));
        _tokens.push(_token);
    }
    
    
    // Sets MasterChef PID
    function setPID(uint _pid) external {
        require(msg.sender == governance, "!gov");
        pid = _pid;
    }
    
    
    // Deposits mDILL into MasterChef
    function deposit() public {
        IERC20 _token = TOKEN;
        uint _balance = _token.balanceOf(address(this));
        _token.safeApprove(address(MASTER), _balance);
        MASTER.deposit(pid, _balance);
    }
    
    
    // Fetches Pickle
    function collect() public {
        (uint _locked,) = MASTER.userInfo(pid, address(this));
        MASTER.withdraw(pid, _locked);
        deposit();
    }
    
    function length() external view returns (uint) {
        return _tokens.length;
    }
    
    function distribute() external {
        collect();
        uint _balance = PICKLE.balanceOf(address(this));
        if (_balance > 0) {
            for (uint i = 0; i < _tokens.length; i++) {
                address _token = _tokens[i];
                address _gauge = gauges[_token];
                uint _reward = _balance.mul(weights[_token]).div(totalWeight);
                if (_reward > 0) {
                    PICKLE.safeApprove(_gauge, _reward);
                    Gauge(_gauge).notifyRewardAmount(_reward);
                }
            }
        }
    }
}