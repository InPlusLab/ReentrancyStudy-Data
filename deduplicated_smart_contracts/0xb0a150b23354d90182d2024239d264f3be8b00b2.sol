/**
 *Submitted for verification at Etherscan.io on 2020-10-21
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

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
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "::SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "::SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint a, uint b) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "::SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "::SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;
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
    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "::SafeMath: modulo by zero");
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
     */
    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface Governance {
    function proposeJob(address job) external returns (uint);
}

interface WETH9 {
    function deposit() external payable;
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
}

interface Uniswap {
    function factory() external pure returns (address);
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
}

interface UniswapPair {
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function totalSupply() external view returns (uint);
}

interface Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface Keep3rHelper {
    function getQuoteLimit(uint gasUsed) external view returns (uint);
}

interface ERC20 {
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract Keep3r {
    using SafeMath for uint;

    /// @notice Keep3r Helper to set max prices for the ecosystem
    Keep3rHelper public KPRH;

    /// @notice EIP-20 token name for this token
    string public constant name = "Keep3r";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "KPR";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Total number of tokens in circulation
    uint public totalSupply = 0; // Initial 0

    /// @notice A record of each accounts delegate
    mapping (address => address) public delegates;

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    mapping (address => mapping (address => uint)) internal allowances;
    mapping (address => uint) internal balances;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint nonce,uint expiry)");

    /// @notice The EIP-712 typehash for the permit struct used by the contract
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint value,uint nonce,uint deadline)");


    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

    /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint votes;
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegatee The address to delegate votes to
     */
    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), _getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "::delegateBySig: invalid nonce");
        require(now <= expiry, "::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber) public view returns (uint) {
        require(blockNumber < block.number, "::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint delegatorBalance = bonds[delegator][address(this)];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint srcRepNew = srcRepOld.sub(amount, "::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint oldVotes, uint newVotes) internal {
      uint32 blockNumber = safe32(block.number, "::_writeCheckpoint: block number exceeds 32 bits");

      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
      } else {
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          numCheckpoints[delegatee] = nCheckpoints + 1;
      }

      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint amount);

    /// @notice The standard EIP-20 approval event
    event Approval(address indexed owner, address indexed spender, uint amount);

    /// @notice Submit a job
    event SubmitJob(address indexed job, address indexed provider, uint block, uint credit);

    /// @notice Apply credit to a job
    event ApplyCredit(address indexed job, address indexed provider, uint block, uint credit);

    /// @notice Remove credit for a job
    event RemoveJob(address indexed job, address indexed provider, uint block, uint credit);

    /// @notice Unbond credit for a job
    event UnbondJob(address indexed job, address indexed provider, uint block, uint credit);

    /// @notice Added a Job
    event JobAdded(address indexed job, uint block, address governance);

    /// @notice Removed a job
    event JobRemoved(address indexed job, uint block, address governance);

    /// @notice Worked a job
    event KeeperWorked(address indexed credit, address indexed job, address indexed keeper, uint block);

    /// @notice Keeper bonding
    event KeeperBonding(address indexed keeper, uint block, uint active, uint bond);

    /// @notice Keeper bonded
    event KeeperBonded(address indexed keeper, uint block, uint activated, uint bond);

    /// @notice Keeper unbonding
    event KeeperUnbonding(address indexed keeper, uint block, uint deactive, uint bond);

    /// @notice Keeper unbound
    event KeeperUnbound(address indexed keeper, uint block, uint deactivated, uint bond);

    /// @notice Keeper slashed
    event KeeperSlashed(address indexed keeper, address indexed slasher, uint block, uint slash);

    /// @notice Keeper disputed
    event KeeperDispute(address indexed keeper, uint block);

    /// @notice Keeper resolved
    event KeeperResolved(address indexed keeper, uint block);

    event AddCredit(address indexed credit, address indexed job, address indexed creditor, uint block, uint amount);

    /// @notice 1 day to bond to become a keeper
    uint constant public BOND = 3 days;
    /// @notice 14 days to unbond to remove funds from being a keeper
    uint constant public UNBOND = 14 days;
    /// @notice 7 days maximum downtime before being slashed
    uint constant public DOWNTIME = 7 days;
    /// @notice 3 days till liquidity can be bound
    uint constant public LIQUIDITYBOND = 3 days;

    /// @notice 5% of funds slashed for downtime
    uint constant public DOWNTIMESLASH = 500;
    uint constant public BASE = 10000;

    /// @notice address used for ETH transfers
    address constant public ETH = address(0xE);

    /// @notice tracks all current bondings (time)
    mapping(address => mapping(address => uint)) public bondings;
    /// @notice tracks all current unbondings (time)
    mapping(address => mapping(address => uint)) public unbondings;
    /// @notice allows for partial unbonding
    mapping(address => mapping(address => uint)) public partialUnbonding;
    /// @notice tracks all current pending bonds (amount)
    mapping(address => mapping(address => uint)) public pendingbonds;
    /// @notice tracks how much a keeper has bonded
    mapping(address => mapping(address => uint)) public bonds;

    /// @notice total bonded (totalSupply for bonds)
    uint public totalBonded = 0;
    /// @notice tracks when a keeper was first registered
    mapping(address => uint) public firstSeen;

    /// @notice tracks if a keeper has a pending dispute
    mapping(address => bool) public disputes;

    /// @notice tracks last job performed for a keeper
    mapping(address => uint) public lastJob;
    /// @notice tracks the amount of job executions for a keeper
    mapping(address => uint) public work;
    /// @notice tracks the total job executions for a keeper
    mapping(address => uint) public workCompleted;
    /// @notice list of all jobs registered for the keeper system
    mapping(address => bool) public jobs;
    /// @notice the current credit available for a job
    mapping(address => mapping(address => uint)) public credits;
    /// @notice the balances for the liquidity providers
    mapping(address => mapping(address => mapping(address => uint))) public liquidityProvided;
    /// @notice liquidity unbonding days
    mapping(address => mapping(address => mapping(address => uint))) public liquidityUnbonding;
    /// @notice liquidity unbonding amounts
    mapping(address => mapping(address => mapping(address => uint))) public liquidityAmountsUnbonding;
    /// @notice job proposal delay
    mapping(address => uint) public jobProposalDelay;
    /// @notice liquidity apply date
    mapping(address => mapping(address => mapping(address => uint))) public liquidityApplied;
    /// @notice liquidity amount to apply
    mapping(address => mapping(address => mapping(address => uint))) public liquidityAmount;

    /// @notice list of all current keepers
    mapping(address => bool) public keepers;
    /// @notice blacklist of keepers not allowed to participate
    mapping(address => bool) public blacklist;

    /// @notice traversable array of keepers to make external management easier
    address[] public keeperList;
    /// @notice traversable array of jobs to make external management easier
    address[] public jobList;

    /// @notice governance address for the governance contract
    address public governance;
    address public pendingGovernance;

    /// @notice the liquidity token supplied by users paying for jobs
    mapping(address => bool) public liquidityAccepted;

    address[] public liquidityPairs;

    uint internal _gasUsed;

    constructor() public {
        // Set governance for this token
        governance = msg.sender;
        _mint(msg.sender, 10000e18);
    }

    /**
     * @notice Add ETH credit to a job to be paid out for work
     * @param job the job being credited
     */
    function addCreditETH(address job) external payable {
        require(jobs[job], "::addCreditETH: not a valid job");
        credits[job][ETH] = credits[job][ETH].add(msg.value);

        emit AddCredit(ETH, job, msg.sender, block.number, msg.value);
    }

    /**
     * @notice Add credit to a job to be paid out for work
     * @param credit the credit being assigned to the job
     * @param job the job being credited
     * @param amount the amount of credit being added to the job
     */
    function addCredit(address credit, address job, uint amount) external {
        require(jobs[job], "::addCreditETH: not a valid job");
        uint _before = ERC20(credit).balanceOf(address(this));
        ERC20(credit).transferFrom(msg.sender, address(this), amount);
        uint _after = ERC20(credit).balanceOf(address(this));
        credits[job][credit] = credits[job][credit].add(_after.sub(_before));

        emit AddCredit(credit, job, msg.sender, block.number, _after.sub(_before));
    }

    /**
     * @notice Approve a liquidity pair for being accepted in future
     * @param liquidity the liquidity no longer accepted
     */
    function approveLiquidity(address liquidity) external {
        require(msg.sender == governance, "::approveLiquidity: governance only");
        require(!liquidityAccepted[liquidity], "::approveLiquidity: existing liquidity pair");
        liquidityAccepted[liquidity] = true;
        liquidityPairs.push(liquidity);
    }

    /**
     * @notice Revoke a liquidity pair from being accepted in future
     * @param liquidity the liquidity no longer accepted
     */
    function revokeLiquidity(address liquidity) external {
        require(msg.sender == governance, "::revokeLiquidity: governance only");
        liquidityAccepted[liquidity] = false;
    }

    /**
     * @notice Displays all accepted liquidity pairs
     */
    function pairs() external view returns (address[] memory) {
        return liquidityPairs;
    }

    /**
     * @notice Allows liquidity providers to submit jobs
     * @param liquidity the liquidity being added
     * @param job the job to assign credit to
     * @param amount the amount of liquidity tokens to use
     */
    function addLiquidityToJob(address liquidity, address job, uint amount) external {
        require(liquidityAccepted[liquidity], "::addLiquidityToJob: asset not accepted as liquidity");
        UniswapPair(liquidity).transferFrom(msg.sender, address(this), amount);
        liquidityProvided[msg.sender][liquidity][job] = liquidityProvided[msg.sender][liquidity][job].add(amount);

        liquidityApplied[msg.sender][liquidity][job] = now.add(LIQUIDITYBOND);
        liquidityAmount[msg.sender][liquidity][job] = liquidityAmount[msg.sender][liquidity][job].add(amount);

        if (!jobs[job] && jobProposalDelay[job] < now) {
            Governance(governance).proposeJob(job);
            jobProposalDelay[job] = now.add(UNBOND);
        }
        emit SubmitJob(job, msg.sender, block.number, amount);
    }

    /**
     * @notice Applies the credit provided in addLiquidityToJob to the job
     * @param provider the liquidity provider
     * @param liquidity the pair being added as liquidity
     * @param job the job that is receiving the credit
     */
    function applyCreditToJob(address provider, address liquidity, address job) external {
        require(liquidityAccepted[liquidity], "::addLiquidityToJob: asset not accepted as liquidity");
        require(liquidityApplied[provider][liquidity][job] != 0, "::credit: submitJob first");
        require(liquidityApplied[provider][liquidity][job] < now, "::credit: still bonding");
        uint _liquidity = balances[address(liquidity)];
        uint _credit = _liquidity.mul(liquidityAmount[msg.sender][liquidity][job]).div(UniswapPair(liquidity).totalSupply());
        _mint(address(this), _credit);
        credits[job][address(this)] = credits[job][address(this)].add(_credit);
        liquidityAmount[msg.sender][liquidity][job] = 0;

        emit ApplyCredit(job, msg.sender, block.number, _credit);
    }

    /**
     * @notice Unbond liquidity for a job
     * @param liquidity the pair being unbound
     * @param job the job being unbound from
     * @param amount the amount of liquidity being removed
     */
    function unbondLiquidityFromJob(address liquidity, address job, uint amount) external {
        require(liquidityAmount[msg.sender][liquidity][job] == 0, "::credit: pending credit, settle first");
        liquidityUnbonding[msg.sender][liquidity][job] = now.add(UNBOND);
        liquidityAmountsUnbonding[msg.sender][liquidity][job] = liquidityAmountsUnbonding[msg.sender][liquidity][job].add(amount);
        require(liquidityAmountsUnbonding[msg.sender][liquidity][job] <= liquidityProvided[msg.sender][liquidity][job], "::unbondLiquidityFromJob: insufficient funds");

        uint _liquidity = balances[address(liquidity)];
        uint _credit = _liquidity.mul(amount).div(UniswapPair(liquidity).totalSupply());
        if (_credit > credits[job][address(this)]) {
            _burn(address(this), credits[job][address(this)]);
            credits[job][address(this)] = 0;
        } else {
            _burn(address(this), _credit);
            credits[job][address(this)].sub(_credit);
        }

        emit UnbondJob(job, msg.sender, block.number, liquidityProvided[msg.sender][liquidity][job]);
    }

    /**
     * @notice Allows liquidity providers to remove liquidity
     * @param liquidity the pair being unbound
     * @param job the job being unbound from
     */
    function removeLiquidityFromJob(address liquidity, address job) external {
        require(liquidityUnbonding[msg.sender][liquidity][job] != 0, "::removeJob: unbond first");
        require(liquidityUnbonding[msg.sender][liquidity][job] < now, "::removeJob: still unbonding");
        uint _amount = liquidityAmountsUnbonding[msg.sender][liquidity][job];
        liquidityProvided[msg.sender][liquidity][job] = liquidityProvided[msg.sender][liquidity][job].sub(_amount);
        liquidityAmountsUnbonding[msg.sender][liquidity][job] = 0;
        UniswapPair(liquidity).transfer(msg.sender, _amount);

        emit RemoveJob(job, msg.sender, block.number, _amount);
    }

    /**
     * @notice Allows governance to mint new tokens to treasury
     * @param amount the amount of tokens to mint to treasury
     */
    function mint(uint amount) external {
        require(msg.sender == governance, "::mint: governance only");
        _mint(governance, amount);
    }

    /**
     * @notice burn owned tokens
     * @param amount the amount of tokens to burn
     */
    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }

    function _mint(address dst, uint amount) internal {
        // mint the amount
        totalSupply = totalSupply.add(amount);
        // transfer the amount to the recipient
        balances[dst] = balances[dst].add(amount);
        emit Transfer(address(0), dst, amount);
    }

    function _burn(address dst, uint amount) internal {
        require(dst != address(0), "::_burn: burn from the zero address");
        balances[dst] = balances[dst].sub(amount, "::_burn: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(dst, address(0), amount);
    }
    
    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param keeper address of the keeper that performed the work
     */
    function worked(address keeper) external {
        workReceipt(keeper, KPRH.getQuoteLimit(_gasUsed.sub(gasleft())));
    }

    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param keeper address of the keeper that performed the work
     * @param amount the reward that should be allocated
     */
    function workReceipt(address keeper, uint amount) public {
        require(jobs[msg.sender], "::workReceipt: only jobs can approve work");
        require(amount <= KPRH.getQuoteLimit(_gasUsed.sub(gasleft())), "::workReceipt: spending over max limit");
        credits[msg.sender][address(this)] = credits[msg.sender][address(this)].sub(amount, "::workReceipt: insuffient funds to pay keeper");
        lastJob[keeper] = now;
        _bond(address(this), keeper, amount);
        workCompleted[keeper] = workCompleted[keeper].add(amount);
        emit KeeperWorked(address(this), msg.sender, keeper, block.number);
    }

    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param credit the asset being awarded to the keeper
     * @param keeper address of the keeper that performed the work
     * @param amount the reward that should be allocated
     */
    function receipt(address credit, address keeper, uint amount) external {
        require(jobs[msg.sender], "::receipt: only jobs can approve work");
        credits[msg.sender][credit] = credits[msg.sender][credit].sub(amount, "::workReceipt: insuffient funds to pay keeper");
        lastJob[keeper] = now;
        ERC20(credit).transfer(msg.sender, amount);
        emit KeeperWorked(credit, msg.sender, keeper, block.number);
    }

    /**
     * @notice Implemented by jobs to show that a keeper performed work
     * @param keeper address of the keeper that performed the work
     * @param amount the amount of ETH sent to the keeper
     */
    function receiptETH(address keeper, uint amount) external {
        require(jobs[msg.sender], "::receipt: only jobs can approve work");
        credits[msg.sender][ETH] = credits[msg.sender][ETH].sub(amount, "::workReceipt: insuffient funds to pay keeper");
        lastJob[keeper] = now;
        payable(keeper).transfer(amount);
        emit KeeperWorked(ETH, msg.sender, keeper, block.number);
    }

    function _bond(address bonding, address _from, uint _amount) internal {
        bonds[_from][bonding] = bonds[_from][bonding].add(_amount);
        totalBonded = totalBonded.add(_amount);
        if (_from == address(this)) {
            _moveDelegates(address(0), delegates[_from], _amount);
        }
    }

    function _unbond(address bonding, address _from, uint _amount) internal {
        bonds[_from][bonding] = bonds[_from][bonding].sub(_amount);
        totalBonded = totalBonded.sub(_amount);
        if (bonding == address(this)) {
            _moveDelegates(delegates[_from], address(0), _amount);
        }

    }

    /**
     * @notice Allows governance to add new job systems
     * @param job address of the contract for which work should be performed
     */
    function addJob(address job) external {
        require(msg.sender == governance, "::addJob: only governance can add jobs");
        require(!jobs[job], "::addJob: job already known");
        jobs[job] = true;
        jobList.push(job);
        emit JobAdded(job, block.number, msg.sender);
    }

    /**
     * @notice Full listing of all jobs ever added
     * @return array blob
     */
    function getJobs() external view returns (address[] memory) {
        return jobList;
    }

    /**
     * @notice Allows governance to remove a job from the systems
     * @param job address of the contract for which work should be performed
     */
    function removeJob(address job) external {
        require(msg.sender == governance, "::removeJob: only governance can remove jobs");
        jobs[job] = false;
        emit JobRemoved(job, block.number, msg.sender);
    }

    /**
     * @notice Allows governance to change the Keep3rHelper for max spend
     * @param _kprh new helper address to set
     */
    function setKeep3rHelper(Keep3rHelper _kprh) external {
        require(msg.sender == governance, "::setKeep3rHelper: only governance can set");
        KPRH = _kprh;
    }

    /**
     * @notice Allows governance to change governance (for future upgradability)
     * @param _governance new governance address to set
     */
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "::setGovernance: only governance can set");
        pendingGovernance = _governance;
    }

    /**
     * @notice Allows pendingGovernance to accept their role as governance (protection pattern)
     */
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance, "::acceptGovernance: only pendingGovernance can accept");
        governance = pendingGovernance;
    }

    /**
     * @notice confirms if the current keeper is registered, can be used for general (non critical) functions
     * @param keeper the keeper being investigated
     * @return true/false if the address is a keeper
     */
    function isKeeper(address keeper) external returns (bool) {
        _gasUsed = gasleft();
        return keepers[keeper];
    }

    /**
     * @notice confirms if the current keeper is registered and has a minimum bond, should be used for protected functions
     * @param keeper the keeper being investigated
     * @param minBond the minimum requirement for the asset provided in bond
     * @param earned the total funds earned in the keepers lifetime
     * @param age the age of the keeper in the system
     * @return true/false if the address is a keeper and has more than the bond
     */
    function isMinKeeper(address keeper, uint minBond, uint earned, uint age) external returns (bool) {
        _gasUsed = gasleft();
        return keepers[keeper]
                && bonds[keeper][address(this)] >= minBond
                && workCompleted[keeper] >= earned
                && now.sub(firstSeen[keeper]) >= age;
    }

    /**
     * @notice confirms if the current keeper is registered and has a minimum bond, should be used for protected functions
     * @param keeper the keeper being investigated
     * @param bond the bound asset being evaluated
     * @param minBond the minimum requirement for the asset provided in bond
     * @param earned the total funds earned in the keepers lifetime
     * @param age the age of the keeper in the system
     * @return true/false if the address is a keeper and has more than the bond
     */
    function isBondedKeeper(address keeper, address bond, uint minBond, uint earned, uint age) external returns (bool) {
        _gasUsed = gasleft();
        return keepers[keeper]
                && bonds[keeper][bond] >= minBond
                && workCompleted[keeper] >= earned
                && now.sub(firstSeen[keeper]) >= age;
    }

    /**
     * @notice begin the bonding process for a new keeper
     * @param bonding the asset being bound
     * @param amount the amount of bonding asset being bound
     */
    function bond(address bonding, uint amount) external {
        require(pendingbonds[msg.sender][bonding] == 0, "::bond: current pending bond");
        require(!blacklist[msg.sender], "::bond: keeper is blacklisted");
        bondings[msg.sender][bonding] = now.add(BOND);
        if (bonding == address(this)) {
            _transferTokens(msg.sender, address(this), amount);
        } else {
            ERC20(bonding).transferFrom(msg.sender, address(this), amount);
        }
        pendingbonds[msg.sender][bonding] = pendingbonds[msg.sender][bonding].add(amount);
        emit KeeperBonding(msg.sender, block.number, bondings[msg.sender][bonding], amount);
    }

    /**
     * @notice get full list of keepers in the system
     */
    function getKeepers() external view returns (address[] memory) {
        return keeperList;
    }

    /**
     * @notice allows a keeper to activate/register themselves after bonding
     * @param bonding the asset being activated as bond collateral
     */
    function activate(address bonding) external {
        require(!blacklist[msg.sender], "::activate: keeper is blacklisted");
        require(bondings[msg.sender][bonding] != 0 && bondings[msg.sender][bonding] < now, "::activate: still bonding");
        if (firstSeen[msg.sender] == 0) {
          firstSeen[msg.sender] = now;
          keeperList.push(msg.sender);
          lastJob[msg.sender] = now;
        }
        keepers[msg.sender] = true;
        _bond(bonding, msg.sender, pendingbonds[msg.sender][bonding]);
        pendingbonds[msg.sender][bonding] = 0;
        emit KeeperBonded(msg.sender, block.number, block.timestamp, bonds[msg.sender][bonding]);
    }

    /**
     * @notice begin the unbonding process to stop being a keeper
     * @param bonding the asset being unbound
     * @param amount allows for partial unbonding
     */
    function unbond(address bonding, uint amount) external {
        unbondings[msg.sender][bonding] = now.add(UNBOND);
        _unbond(bonding, msg.sender, amount);
        partialUnbonding[msg.sender][bonding] = partialUnbonding[msg.sender][bonding].add(amount);
        emit KeeperUnbonding(msg.sender, block.number, unbondings[msg.sender][bonding], amount);
    }

    /**
     * @notice withdraw funds after unbonding has finished
     * @param bonding the asset to withdraw from the bonding pool
     */
    function withdraw(address bonding) external {
        require(unbondings[msg.sender][bonding] != 0 && unbondings[msg.sender][bonding] < now, "::withdraw: still unbonding");
        require(!disputes[msg.sender], "::withdraw: pending disputes");

        if (bonding == address(this)) {
            _transferTokens(address(this), msg.sender, partialUnbonding[msg.sender][bonding]);
        } else {
            ERC20(bonding).transfer(msg.sender, partialUnbonding[msg.sender][bonding]);
        }
        emit KeeperUnbound(msg.sender, block.number, block.timestamp, partialUnbonding[msg.sender][bonding]);
        partialUnbonding[msg.sender][bonding] = 0;
    }

    /**
     * @notice slash a keeper for downtime
     * @param keeper the address being slashed
     */
    function down(address keeper) external {
        require(keepers[msg.sender], "::down: not a keeper");
        require(keepers[keeper], "::down: keeper not registered");
        require(lastJob[keeper].add(DOWNTIME) < now, "::down: keeper safe");
        uint _slash = bonds[keeper][address(this)].mul(DOWNTIMESLASH).div(BASE);

        _unbond(address(this), keeper, _slash);
        _bond(address(this), msg.sender, _slash);

        lastJob[keeper] = now;
        lastJob[msg.sender] = now;
        emit KeeperSlashed(keeper, msg.sender, block.number, _slash);
    }

    /**
     * @notice allows governance to create a dispute for a given keeper
     * @param keeper the address in dispute
     */
    function dispute(address keeper) external returns (uint) {
        require(msg.sender == governance, "::dispute: only governance can dispute");
        disputes[keeper] = true;
        emit KeeperDispute(keeper, block.number);
    }

    /**
     * @notice allows governance to slash a keeper based on a dispute
     * @param bonded the asset being slashed
     * @param keeper the address being slashed
     * @param amount the amount being slashed
     */
    function slash(address bonded, address keeper, uint amount) public {
        require(msg.sender == governance, "::slash: only governance can resolve");
        if (bonded == address(this)) {
            _transferTokens(address(this), governance, amount);
        } else {
            ERC20(bonded).transfer(governance, amount);
        }
        _unbond(bonded, keeper, amount);
        disputes[keeper] = false;
        emit KeeperSlashed(keeper, msg.sender, block.number, amount);
    }

    /**
     * @notice blacklists a keeper from participating in the network
     * @param keeper the address being slashed
     */
    function revoke(address keeper) external {
        require(msg.sender == governance, "::slash: only governance can resolve");
        keepers[keeper] = false;
        blacklist[keeper] = true;
        slash(address(this), keeper, bonds[keeper][address(this)]);
    }

    /**
     * @notice allows governance to resolve a dispute on a keeper
     * @param keeper the address cleared
     */
    function resolve(address keeper) external {
        require(msg.sender == governance, "::resolve: only governance can resolve");
        disputes[keeper] = false;
        emit KeeperResolved(keeper, block.number);
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
    function approve(address spender, uint amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Triggers an approval from owner to spends
     * @param owner The address to approve from
     * @param spender The address to be approved
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @param deadline The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), _getChainId(), address(this)));
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "::permit: invalid signature");
        require(signatory == owner, "::permit: unauthorized");
        require(now <= deadline, "::permit: signature expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
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
    function transfer(address dst, uint amount) public returns (bool) {
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
            uint newAllowance = spenderAllowance.sub(amount, "::transferFrom: transfer amount exceeds spender allowance");
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        require(src != address(0), "::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "::_transferTokens: cannot transfer to the zero address");

        balances[src] = balances[src].sub(amount, "::_transferTokens: transfer amount exceeds balance");
        balances[dst] = balances[dst].add(amount, "::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);
    }

    function _getChainId() internal pure returns (uint) {
        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}