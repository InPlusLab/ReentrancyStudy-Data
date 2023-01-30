//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract implements a DAO, it's been loosely based on Compound's
GovernorAlpha. It supports multiple options per proposal and multiple actions
per option. It leverages the `Voters` contract for snapshots of voting power.
It supports gasless voting with voteBySig / EIP-712.
*/

import './interfaces/IVoters.sol';

contract DAO {
    struct Proposal {
        uint id;
        address proposer;
        string title;
        string description;
        string[] optionsNames;
        bytes[][] optionsActions;
        uint[] optionsVotes;
        uint startAt;
        uint endAt;
        uint executableAt;
        uint executedAt;
        uint snapshotId;
        uint votersSupply;
        bool cancelled;
    }

    event Proposed(uint indexed proposalId);
    event Voted(uint indexed proposalId, address indexed voter, uint optionId);
    event Executed(address indexed to, uint value, bytes data);
    event ExecutedProposal(uint indexed proposalId, uint optionId, address executer);

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,uint optionId)");
    uint public minBalanceToPropose;
    uint public minPercentQuorum;
    uint public minVotingTime;
    uint public minExecutionDelay;
    IVoters public voters;
    uint public proposalsCount;
    mapping(uint => Proposal) private proposals;
    mapping(uint => mapping(address => uint)) public proposalVotes;
    mapping (address => uint) private latestProposalIds;

    constructor(
      address _voters,
      uint _minBalanceToPropose,
      uint _minPercentQuorum,
      uint _minVotingTime,
      uint _minExecutionDelay
    ) {
        voters = IVoters(_voters);
        minBalanceToPropose = _minBalanceToPropose;
        minPercentQuorum = _minPercentQuorum;
        minVotingTime = _minVotingTime;
        minExecutionDelay = _minExecutionDelay;
    }

    function proposal(uint index) public view returns (uint, address, string memory, uint, uint, uint, uint, bool) {
        Proposal storage p = proposals[index];
        return (
          p.id,
          p.proposer,
          p.title,
          p.startAt,
          p.endAt,
          p.executableAt,
          p.executedAt,
          p.cancelled
        );
    }

    function proposalDetails(uint index) public view returns (string memory, uint, uint, string[] memory, bytes[][] memory, uint[] memory) {
        return (
          proposals[index].description,
          proposals[index].snapshotId,
          proposals[index].votersSupply,
          proposals[index].optionsNames,
          proposals[index].optionsActions,
          proposals[index].optionsVotes
        );
    }

    function propose(string calldata title, string calldata description, uint votingTime, uint executionDelay, string[] calldata optionNames, bytes[][] memory optionActions) external returns (uint) {
        uint snapshotId = voters.snapshot();
        require(voters.votesAt(msg.sender, snapshotId) >= minBalanceToPropose, "<balance");
        require(optionNames.length == optionActions.length && optionNames.length > 0 && optionNames.length <= 100, "option len match or count");
        require(optionActions[optionActions.length - 1].length == 0, "last option, no action");
        require(votingTime >= minVotingTime, "<voting time");
        require(executionDelay >= minExecutionDelay, "<exec delay");

        // Check the proposing address doesn't have an other active proposal
        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            require(block.timestamp > proposals[latestProposalId].endAt, "1 live proposal max");
        }

        // Add new proposal
        proposalsCount += 1;
        Proposal storage newProposal = proposals[proposalsCount];
        newProposal.id = proposalsCount;
        newProposal.proposer = msg.sender;
        newProposal.title = title;
        newProposal.description = description;
        newProposal.startAt = block.timestamp;
        newProposal.endAt = block.timestamp + votingTime;
        newProposal.executableAt = block.timestamp + votingTime + executionDelay;
        newProposal.snapshotId = snapshotId;
        newProposal.votersSupply = voters.totalSupplyAt(snapshotId);
        newProposal.optionsNames = new string[](optionNames.length);
        newProposal.optionsVotes = new uint[](optionNames.length);
        newProposal.optionsActions = optionActions;

        for (uint i = 0; i < optionNames.length; i++) {
            require(optionActions[i].length <= 10, "actions length > 10");
            newProposal.optionsNames[i] = optionNames[i];
        }

        latestProposalIds[msg.sender] = newProposal.id;
        emit Proposed(newProposal.id);
        return newProposal.id;
    }

    function proposeCancel(uint proposalId, string memory title, string memory description) external returns (uint) {
        uint snapshotId = voters.snapshot();
        require(voters.votesAt(msg.sender, snapshotId) >= minBalanceToPropose, "<balance");

        // Check the proposing address doesn't have an other active proposal
        uint latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            require(block.timestamp > proposals[latestProposalId].endAt, "1 live proposal max");
        }

        // Add new proposal
        proposalsCount += 1;
        Proposal storage newProposal = proposals[proposalsCount];
        newProposal.id = proposalsCount;
        newProposal.proposer = msg.sender;
        newProposal.title = title;
        newProposal.description = description;
        newProposal.startAt = block.timestamp;
        newProposal.endAt = block.timestamp + 86400; // 24 hours
        newProposal.executableAt = block.timestamp + 86400; // Executable immediately
        newProposal.snapshotId = snapshotId;
        newProposal.votersSupply = voters.totalSupplyAt(snapshotId);
        newProposal.optionsNames = new string[](2);
        newProposal.optionsVotes = new uint[](2);
        newProposal.optionsActions = new bytes[][](2);

        newProposal.optionsNames[0] = "Cancel Proposal";
        newProposal.optionsNames[1] = "Do Nothing";
        newProposal.optionsActions[0] = new bytes[](1);
        newProposal.optionsActions[1] = new bytes[](0);
        newProposal.optionsActions[0][0] = abi.encode(
            address(this), 0,
            abi.encodeWithSignature("cancel(uint256)", proposalId)
        );

        latestProposalIds[msg.sender] = newProposal.id;
        emit Proposed(newProposal.id);
        return newProposal.id;
    }

    function vote(uint proposalId, uint optionId) external {
        _vote(msg.sender, proposalId, optionId);
    }

    function voteBySig(uint proposalId, uint optionId, uint8 v, bytes32 r, bytes32 s) external {
        uint chainId;
        assembly { chainId := chainid() }
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("Thorstarter DAO")), chainId, address(this)));
        bytes32 structHash = keccak256(abi.encode(BALLOT_TYPEHASH, proposalId, optionId));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address voter = ecrecover(digest, v, r, s);
        require(voter != address(0), "invalid signature");
        _vote(voter, proposalId, optionId);
    }

    function _vote(address voter, uint proposalId, uint optionId) private {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp < p.endAt, "voting ended");
        require(proposalVotes[proposalId][voter] == 0, "already voted");
        p.optionsVotes[optionId] = p.optionsVotes[optionId] + voters.votesAt(voter, p.snapshotId);
        proposalVotes[proposalId][voter] = optionId + 1;
        emit Voted(proposalId, voter, optionId);
    }

    // Executes an un-executed, with quorum, ready to be executed proposal
    // If the pre-conditions are met, anybody can call this
    // Part of this is establishing which option "won" and if quorum was reached
    function execute(uint proposalId) external {
        Proposal storage p = proposals[proposalId];
        require(p.executedAt == 0, "already executed");
        require(block.timestamp > p.executableAt, "not yet executable");
        require(!p.cancelled, "proposal cancelled");
        require(p.optionsVotes.length >= 2, "not a proposal");
        p.executedAt = block.timestamp; // Mark as executed now to prevent re-entrancy

        // Pick the winning option (the one with the most votes, defaulting to the "Against" (last) option
        uint votesTotal;
        uint winningOptionIndex = p.optionsNames.length - 1; // Default to "Against"
        uint winningOptionVotes = 0;
        for (int i = int(p.optionsVotes.length) - 1; i >= 0; i--) {
            uint votes = p.optionsVotes[uint(i)];
            votesTotal = votesTotal + votes;
            // Use greater than (not equal) to avoid a proposal with 0 votes
            // to default to the 1st option
            if (votes > winningOptionVotes) {
                winningOptionIndex = uint(i);
                winningOptionVotes = votes;
            }
        }

        require((votesTotal * 1e12) / p.votersSupply > minPercentQuorum, "not at quorum");

        // Run all actions attached to the winning option
        for (uint i = 0; i < p.optionsActions[winningOptionIndex].length; i++) {
            (address to, uint value, bytes memory data) = abi.decode(
              p.optionsActions[winningOptionIndex][i],
              (address, uint, bytes)
            );
            (bool success,) = to.call{value: value}(data);
            require(success, "action reverted");
            emit Executed(to, value, data);
        }

        emit ExecutedProposal(proposalId, winningOptionIndex, msg.sender);
    }

    function setMinBalanceToPropose(uint value) external {
        require(msg.sender == address(this), "!DAO");
        minBalanceToPropose = value;
    }

    function setMinPercentQuorum(uint value) external {
        require(msg.sender == address(this), "!DAO");
        minPercentQuorum = value;
    }

    function setMinVotingTime(uint value) external {
        require(msg.sender == address(this), "!DAO");
        minVotingTime = value;
    }

    function setMinExecutionDelay(uint value) external {
        require(msg.sender == address(this), "!DAO");
        minExecutionDelay = value;
    }

    function setVoters(address newVoters) external {
        require(msg.sender == address(this), "!DAO");
        voters = IVoters(newVoters);
    }

    function cancel(uint proposalId) external {
        require(msg.sender == address(this), "!DAO");
        Proposal storage p = proposals[proposalId];
        require(p.executedAt == 0 && !p.cancelled, "already executed or cancelled");
        p.cancelled = true;
    }

    fallback() external payable { }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IVoters {
  function snapshot() external returns (uint);
  function totalSupplyAt(uint snapshotId) external view returns (uint);
  function votesAt(address account, uint snapshotId) external view returns (uint);
  function balanceOf(address account) external view returns (uint);
  function balanceOfAt(address account, uint snapshotId) external view returns (uint);
  function donate(uint amount) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract receives XRUNE tokens via the `deposit` method from the
`LpTokenVestingKeeper` contract and let's investors part of a given
snapshot (of the vXRUNE/Voters contract) claim their share of that XRUNE.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IDAO.sol';
import './interfaces/IVoters.sol';

contract VotersInvestmentDispenser {
    using SafeERC20 for IERC20;

    IERC20 public xruneToken;
    IDAO public dao;
    mapping(uint => uint) public snapshotAmounts;
    mapping(uint => uint) public claimedAmountsTotals;
    mapping(uint => mapping(address => uint)) public claimedAmounts;

    event Claim(uint snapshotId, address user, uint amount);
    event Deposit(uint snapshotId, uint amount);

    constructor(address _xruneToken, address _dao) {
        xruneToken = IERC20(_xruneToken);
        dao = IDAO(_dao);
    }

    // Calculated based on % of total vote supply at snapshotId, multiplied by amount available, minus claimed
    function claimable(uint snapshotId, address user) public view returns (uint) {
        IVoters voters = IVoters(dao.voters());
        uint total = snapshotAmounts[snapshotId];
        uint totalSupply = voters.totalSupplyAt(snapshotId);
        uint balance = voters.balanceOfAt(user, snapshotId);
        return ((total * balance) / totalSupply) - claimedAmounts[snapshotId][user];
    }

    function claim(uint snapshotId) public {
        uint amount = claimable(snapshotId, msg.sender);
        if (amount > 0) {
            claimedAmounts[snapshotId][msg.sender] += amount;
            claimedAmountsTotals[snapshotId] += amount;
            xruneToken.safeTransfer(msg.sender, amount);
            emit Claim(snapshotId, msg.sender, amount);
        }
    }

    // Used by LpTokenVestingKeeper
    function deposit(uint snapshotId, uint amount) public {
        xruneToken.safeTransferFrom(msg.sender, address(this), amount);
        snapshotAmounts[snapshotId] += amount;
        emit Deposit(snapshotId, amount);
    }

    // Allow DAO to get tokens out and migrate to a different contract
    function withdraw(address token, uint amount) public {
        require(msg.sender == address(dao), '!DAO');
        IERC20(token).safeTransfer(address(dao), amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IDAO {
    function voters() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract claims amm lp shares from multiple `LpTokenVesting` contracts,
removes liquidity, sells the non-XRUNE token, and distributes it's resulting
XRUNE balance to an `VotersInvestmentDispenser` contract, a `Voters` contract,
the grants multisig and the DAO.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IUniswapV2Router.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IDAO.sol';
import './interfaces/IVoters.sol';
import './interfaces/ILpTokenVesting.sol';
import './interfaces/IVotersInvestmentDispenser.sol';

contract LpTokenVestingKeeper {
  using SafeERC20 for IERC20;

  IVotersInvestmentDispenser public votersInvestmentDispenser;
  IUniswapV2Router public sushiRouter;
  IERC20 public xruneToken;
  IDAO public dao;
  address public grants;
  address public owner;
  uint public lpVestersCount;
  mapping(uint => address) public lpVesters;
  mapping(uint => uint) public lpVestersSnapshotIds;
  uint lastRun;

  event AddLpVester(address vester, uint snapshotId);
  event Claim(address vester, uint snapshotId, uint amount);

  constructor(address _votersInvestmentDispenser, address _sushiRouter, address _xruneToken, address _dao, address _grants, address _owner) {
    votersInvestmentDispenser = IVotersInvestmentDispenser(_votersInvestmentDispenser);
    sushiRouter = IUniswapV2Router(_sushiRouter);
    xruneToken = IERC20(_xruneToken);
    dao = IDAO(_dao);
    grants = _grants;
    owner = _owner;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "!owner");
    _;
  }

  function addLpVester(address vester, uint snapshotId) public onlyOwner {
    lpVesters[lpVestersCount] = vester;
    lpVestersSnapshotIds[lpVestersCount] = snapshotId;
    lpVestersCount++;
    emit AddLpVester(vester, snapshotId);
  }

  function setVotersInvestmentDispenser(address value) public onlyOwner {
    votersInvestmentDispenser = IVotersInvestmentDispenser(value);
  }

  function setDao(address value) public onlyOwner {
    dao = IDAO(value);
  }

  function setGrants(address value) public onlyOwner {
    grants = value;
  }

  function setOwner(address value) public onlyOwner {
    owner = value;
  }
  
  function shouldRun() public view returns (bool) {
    return block.timestamp > lastRun + 82800; // 23 hours
  }

  function run() external {
    require(shouldRun(), "should not run");
    lastRun = block.timestamp;
    for (uint i = 0; i < lpVestersCount; i++) {
      ILpTokenVesting vester = ILpTokenVesting(lpVesters[i]);
      uint claimable = vester.claimable(0);
      if (claimable > 0) {
        vester.claim(0);
        address token0 = address(vester.token0());
        address token1 = address(vester.token1());
        IERC20 lpToken = IERC20(pair(token0, token1));
        uint lpTokenAmount = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(sushiRouter), lpTokenAmount);
        (uint amount0, uint amount1) = sushiRouter.removeLiquidity(
          token0, token1,
          lpTokenAmount, 0, 0,
          address(this), type(uint).max
        );
        {
          address[] memory path = new address[](2);
          path[0] = address(xruneToken) == token0 ? token1 : token0;
          path[1] = address(xruneToken);
          uint amountToSwap = address(xruneToken) == token0 ? amount1 : amount0;
          IERC20(path[0]).safeApprove(address(sushiRouter), amountToSwap);
          sushiRouter.swapExactTokensForTokens(
            amountToSwap, 0,
            path, address(this), type(uint).max
          );
        }
        uint amount = xruneToken.balanceOf(address(this));

        xruneToken.safeApprove(address(votersInvestmentDispenser), (amount * 35) / 100);
        votersInvestmentDispenser.deposit(lpVestersSnapshotIds[i], (amount * 35) / 100);

        xruneToken.safeApprove(dao.voters(), (amount * 35) / 100);
        IVoters(dao.voters()).donate((amount * 35) / 100);

        xruneToken.safeTransfer(grants, (amount * 5) / 100);

        // Send the leftover 25% to the DAO
        xruneToken.transfer(address(dao), xruneToken.balanceOf(address(this)));
        emit Claim(lpVesters[i], lpVestersSnapshotIds[i], amount);
      }
    }
  }

  function pair(address token0, address token1) public view returns (address) {
    return IUniswapV2Factory(sushiRouter.factory()).getPair(token0, token1);
  }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface IUniswapV2Router {
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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface ILpTokenVesting {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function claimable(uint party) external view returns (uint);
  function claim(uint party) external returns (uint);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IVotersInvestmentDispenser {
  function deposit(uint snapshotId, uint amount) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenPriceHelper { 
    address weth9;
    address dai;
    IUniswapV2Factory factory;

    constructor(address _weth9, address _dai, address _factory) {
        weth9 = _weth9;
        dai = _dai;
        factory = IUniswapV2Factory(_factory);
    }

    function price(address token) public view returns (uint) {
        uint ethPrice = 0;
        IUniswapV2Pair ethPair = IUniswapV2Pair(factory.getPair(weth9, dai));
        (uint balance0, uint balance1,) = ethPair.getReserves();
        if (ethPair.token0() == weth9) {
            ethPrice = (balance1 * 1e18) / balance0;
        } else {
            ethPrice = (balance0 * 1e18) / balance1;
        }

        IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(weth9, token));
        if (address(pair) == address(0)) {
            return 0;
        }

        (balance0, balance1,) = pair.getReserves();
        if (pair.token0() == weth9) {
            return balance0 * ethPrice / balance1;
        } else {
            return balance1 * ethPrice / balance0;
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface IUniswapV2Pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract allows the sale of an "offering" token in exchange for a "payment"
token.
It let's investors buy tokens at an initial price that increases with every
deposit.
The sale stops once the amount of offered tokens run out or after a specified
block passes.
The speed / curve along which the price increases is specified upfront.
Investors can only participate once and will receive their tokens after the sale
ends (more specifically, after tokensBlock).
*/

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IVoters.sol';

contract SaleFloating is ReentrancyGuard {
  using SafeERC20 for IERC20;

  // Information of each user's participation
  struct UserInfo {
      // How many tokens the user has provided
      uint amount;
      // What price this user secured
      uint price;
      // Wether this user has already claimed their share of tokens, defaults to false
      bool claimedTokens;
  }

  // Owner address, has access to withdrawing funds after the sale
  address public owner;
  // Keeper address, has access to tweaking sake parameters
  address public keeper;
  // The raising token
  IERC20 public paymentToken;
  // The offering token
  IERC20 public offeringToken;
  // The block number when sale starts
  uint public startBlock;
  // The block number when sale ends
  uint public endBlock;
  // The block number when tokens are redeemable
  uint public tokensBlock;
  // Price to start the sale at (offeringToken per 1e18 of paymentToken)
  uint public startPrice;
  // Rate at which to increase the price (as amount per 1e18 of token invested)
  uint public priceVelocity;
  // Amount of tokens offered for sale
  uint public offeringAmount;
  // Maximum a user can contribute
  uint public perUserCap;
  // Voting token minimum balance to participate
  uint public votingMinimum;
  // Voting token address
  IVoters public votingToken;
  // Voting token snapshot id to use for balances (optional)
  uint public votingSnapshotId;
  // Wether deposits are paused
  bool public paused;
  // Total amount of raising tokens that have already been raised
  uint public totalAmount;
  // Total amount of offering tokens sold
  uint public totalOfferingAmount;
  // User's participation info
  mapping(address => UserInfo) public userInfo;
  // Participants list
  address[] public addressList;


  event Deposit(address indexed user, uint amount, uint price);
  event HarvestTokens(address indexed user, uint amount);

  constructor(
      IERC20 _paymentToken,
      IERC20 _offeringToken,
      uint _startBlock,
      uint _endBlock,
      uint _tokensBlock,
      uint _startPrice,
      uint _priceVelocity,
      uint _offeringAmount,
      uint _perUserCap,
      address _owner,
      address _keeper
  ) {
      paymentToken = _paymentToken;
      offeringToken = _offeringToken;
      startBlock = _startBlock;
      endBlock = _endBlock;
      tokensBlock = _tokensBlock;
      startPrice = _startPrice;
      priceVelocity = _priceVelocity;
      offeringAmount = _offeringAmount;
      perUserCap = _perUserCap;
      owner = _owner;
      keeper = _keeper;
      _validateBlockParams();
      require(_paymentToken != _offeringToken, 'payment != offering');
      require(_priceVelocity > 0, 'price velocity > 0');
      require(_offeringAmount > 0, 'offering amount > 0');
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "!owner");
    _;
  }

  modifier onlyOwnerOrKeeper() {
    require(msg.sender == owner || msg.sender == keeper, "!owner or keeper");
    _;
  }

  function _validateBlockParams() private view {
    require(startBlock > block.number, 'start > now');
    require(endBlock >= startBlock, 'end > start');
    require(endBlock - startBlock <= 172800, 'end < 1 month after start');
    require(tokensBlock - endBlock <= 172800, 'tokens < 1 month after end');
  }

  function setOfferingAmount(uint _offerAmount) public onlyOwnerOrKeeper {
    require (block.number < startBlock, 'sale started');
    offeringAmount = _offerAmount;
  }

  function setStartPrice(uint _startPrice) public onlyOwnerOrKeeper {
    require (block.number < startBlock, 'sale started');
    startPrice = _startPrice;
  }

  function setPriceVelocity(uint _priceVelocity) public onlyOwnerOrKeeper {
    require (block.number < startBlock, 'sale started');
    priceVelocity = _priceVelocity;
  }

  function setStartBlock(uint _block) public onlyOwnerOrKeeper {
    startBlock = _block;
    _validateBlockParams();
  }

  function setEndBlock(uint _block) public onlyOwnerOrKeeper {
    endBlock = _block;
    _validateBlockParams();
  }

  function setTokensBlock(uint _block) public onlyOwnerOrKeeper {
    tokensBlock = _block;
    _validateBlockParams();
  }

  function configureVotingToken(uint minimum, address token, uint snapshotId) public onlyOwnerOrKeeper {
    votingMinimum = minimum;
    votingToken = IVoters(token);
    votingSnapshotId = snapshotId;
  }

  function togglePaused() public onlyOwnerOrKeeper {
    paused = !paused;
  }

  function deposit(uint _amount) public {
    require(!paused, 'paused');
    require(block.number > startBlock && block.number < endBlock, 'sale not active');
    require(_amount > 0, 'need amount > 0');
    require(perUserCap == 0 || _amount <= perUserCap, 'over per user cap');
    require(userInfo[msg.sender].amount == 0, 'already participated');
    require(totalOfferingAmount <= offeringAmount, 'sold out');

    if (votingMinimum > 0) {
      if (votingSnapshotId == 0) {
        require(votingToken.balanceOf(msg.sender) >= votingMinimum, "under minimum locked");
      } else {
        require(votingToken.balanceOfAt(msg.sender, votingSnapshotId) >= votingMinimum, "under minimum locked");
      }
    }

    paymentToken.safeTransferFrom(address(msg.sender), address(this), _amount);
    addressList.push(address(msg.sender));
    userInfo[msg.sender].amount = _amount;
    totalAmount += _amount;
    uint price = startPrice + ((totalAmount * priceVelocity) / 1e18);
    userInfo[msg.sender].price = price;
    totalOfferingAmount += getOfferingAmount(msg.sender);
    emit Deposit(msg.sender, _amount, price);
  }

  function harvestTokens() public nonReentrant {
    require(!paused, 'paused');
    require (block.number > tokensBlock, 'not harvest time');
    require (userInfo[msg.sender].amount > 0, 'have you participated?');
    require (!userInfo[msg.sender].claimedTokens, 'nothing to harvest');
    uint amount = getOfferingAmount(msg.sender);
    if (amount > 0) {
      offeringToken.safeTransfer(address(msg.sender), amount);
    }
    userInfo[msg.sender].claimedTokens = true;
    emit HarvestTokens(msg.sender, amount);
  }

  function hasHarvestedTokens(address _user) external view returns (bool) {
      return userInfo[_user].claimedTokens;
  }

  // Amount of offering token a user will receive
  function getOfferingAmount(address _user) public view returns (uint) {
      return (userInfo[_user].amount * 1e18) / userInfo[_user].price;
  }

  function getAddressListLength() external view returns (uint) {
      return addressList.length;
  }

  function getParams() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint) {
    return (startBlock, endBlock, tokensBlock, startPrice, priceVelocity, offeringAmount, perUserCap, totalAmount, totalOfferingAmount);
  }

  function finalWithdraw(uint _paymentAmount, uint _offeringAmount) public onlyOwner {
    require (_paymentAmount <= paymentToken.balanceOf(address(this)), 'not enough payment token');
    require (_offeringAmount <= offeringToken.balanceOf(address(this)), 'not enough offerring token');
    if (_paymentAmount > 0) {
      paymentToken.safeTransfer(address(msg.sender), _paymentAmount);
    }
    if (_offeringAmount > 0) {
      offeringToken.safeTransfer(address(msg.sender), _offeringAmount);
    }
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

    constructor() {
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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IVoters.sol";
import "./interfaces/IERC677Receiver.sol";

contract SaleDutch is ReentrancyGuard, IERC677Receiver {
    using SafeERC20 for IERC20;

    // Information of each user's participation
    struct UserInfo {
        // How many tokens the user has provided
        uint amount;
        // Wether this user has already claimed their share of tokens, defaults to false
        bool claimedTokens;
    }

    // Owner address, has access to withdrawing funds after the sale
    address public owner;
    // The raising token
    IERC20 public paymentToken;
    // The offering token
    IERC20 public offeringToken;
    // The time (unix seconds) when sale starts
    uint public startTime;
    // The time (unix security) when sale ends
    uint public endTime;
    // Price to start the sale at (offeringToken per 1e18 of paymentToken)
    uint public startPrice;
    // Reserve price (as amount per 1e18 of token invested)
    uint public endPrice;
    // Amount of tokens offered for sale
    uint public offeringAmount;
    // Maximum a user can contribute
    uint public perUserCap;
    // Voting token minimum balance to participate
    uint public votingMinimum;
    // Voting token address
    IVoters public votingToken;
    // Voting token snapshot id to use for balances (optional)
    uint public votingSnapshotId;
    // Wether deposits are paused
    bool public paused;
    // Wether the sale is finalized
    bool public finalized;
    // Total amount of raising tokens that have already been raised
    uint public totalAmount;
    // User's participation info
    mapping(address => UserInfo) public userInfo;
    // Participants list
    address[] public addressList;


    event Deposit(address indexed user, uint amount);
    event HarvestTokens(address indexed user, uint amount);
    event HarvestRefund(address indexed user, uint amount);

    constructor(
        address _paymentToken,
        address _offeringToken,
        uint _startTime,
        uint _endTime,
        uint _startPrice,
        uint _endPrice,
        uint _offeringAmount,
        uint _perUserCap,
        address _owner
    ) {
        paymentToken = IERC20(_paymentToken);
        offeringToken = IERC20(_offeringToken);
        startTime = _startTime;
        endTime = _endTime;
        startPrice = _startPrice;
        endPrice = _endPrice;
        offeringAmount = _offeringAmount;
        perUserCap = _perUserCap;
        owner = _owner;
        require(_paymentToken != _offeringToken, 'payment != offering');
        require(startTime > block.timestamp, 'start > now');
        require(startTime < endTime, 'start < end');
        require(startTime < 10000000000, 'start time not unix');
        require(endTime < 10000000000, 'start time not unix');
        require(_startPrice > 0, 'start price > 0');
        require(_offeringAmount > 0, 'offering amount > 0');
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function finalize() public {
        require(msg.sender == owner || block.timestamp > endTime + 7 days, 'no allowed');
        finalized = true;
    }

    function getAddressListLength() external view returns (uint) {
        return addressList.length;
    }

    function getParams() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, bool, bool) {
        return (startTime, endTime, startPrice, endPrice,
                offeringAmount, perUserCap, totalAmount, currentPrice(), clearingPrice(), paused, finalized);
    }

    function priceChange() public view returns (uint) {
        return (startPrice - endPrice) / (endTime - startTime);
    }

    function currentPrice() public view returns (uint) {
        if (block.timestamp <= startTime) return startPrice;
        if (block.timestamp >= endTime) return endPrice;
        return startPrice - ((block.timestamp - startTime) * priceChange());
    }

    function tokenPrice() public view returns (uint) {
        return (totalAmount * 1e18) / offeringAmount;
    }

    function clearingPrice() public view returns (uint) {
        if (tokenPrice() > currentPrice()) return tokenPrice();
        return currentPrice();
    }

    function saleSuccessful() public view returns (bool) {
        return tokenPrice() >= clearingPrice();
    }

    function commitmentSize(uint amount) public view returns (uint) {
      uint max = (offeringAmount * clearingPrice()) / 1e18;
      if (totalAmount + amount > max) {
        return max - totalAmount;
      }
      return amount;
    }

    function _deposit(address user, uint amount) private nonReentrant {
      require(!paused, 'paused');
      require(block.timestamp > startTime && block.timestamp < endTime, 'sale not active');
      require(amount > 0, 'need amount > 0');
      require(perUserCap == 0 || amount <= perUserCap, 'over per user cap');
      require(userInfo[user].amount == 0, 'already participated');

      if (votingMinimum > 0) {
          if (votingSnapshotId == 0) {
              require(votingToken.balanceOf(user) >= votingMinimum, "under minimum locked");
          } else {
              require(votingToken.balanceOfAt(user, votingSnapshotId) >= votingMinimum, "under minimum locked");
          }
      }

      uint cappedAmount = commitmentSize(amount);
      require(cappedAmount > 0, 'sale fully commited');

      // Refund user's overpayment
      if (amount - cappedAmount > 0) {
          paymentToken.transfer(user, amount - cappedAmount);
      }

      addressList.push(user);
      userInfo[user].amount = cappedAmount;
      totalAmount += cappedAmount;
      emit Deposit(user, cappedAmount);
    }

    function deposit(uint amount) external {
        _transferFrom(msg.sender, amount);
        _deposit(msg.sender, amount);
    }

    function onTokenTransfer(address user, uint amount, bytes calldata _data) external override {
        require(msg.sender == address(paymentToken), "onTokenTransfer: not paymentToken");
        _deposit(user, amount);
    }

    function harvestTokens() public nonReentrant {
      require(!paused, 'paused');

      if (saleSuccessful()) {
          require(finalized, 'not finalized');
          require(userInfo[msg.sender].amount > 0, 'have you participated?');
          require(!userInfo[msg.sender].claimedTokens, 'already claimed');

          uint amount = getOfferingAmount(msg.sender);
          require(amount > 0, 'nothing to claim');
          offeringToken.safeTransfer(msg.sender, amount);
          userInfo[msg.sender].claimedTokens = true;
          emit HarvestTokens(msg.sender, amount);
      } else {
          require(block.timestamp > endTime, 'sale not ended');
          uint amount = userInfo[msg.sender].amount;
          userInfo[msg.sender].amount = 0;
          paymentToken.safeTransfer(msg.sender, amount);
          emit HarvestRefund(msg.sender, amount);
      }
    }

    // Amount of offering token a user will receive
    function getOfferingAmount(address _user) public view returns (uint) {
        return (userInfo[_user].amount * offeringAmount) / totalAmount;
    }

    function hasHarvestedTokens(address _user) external view returns (bool) {
        return userInfo[_user].claimedTokens;
    }

    function withdrawToken(address token, uint amount) public onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function _transferFrom(address from, uint amount) private {
        uint balanceBefore = paymentToken.balanceOf(address(this));
        paymentToken.safeTransferFrom(from, address(this), amount);
        uint balanceAfter = paymentToken.balanceOf(address(this));
        require(balanceAfter - balanceBefore == amount, "_transferFrom: balance change does not match amount");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC677Receiver {
  function onTokenTransfer(address _sender, uint _value, bytes calldata _data) external;
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract allows XRUNE holders and LPs to lock some of their tokens up for
vXRUNE, the Thorstarter DAO's voting token. It's an ERC20 but without the
transfer methods.
It supports snapshoting and delegation of voting power.
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IVoters.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC677Receiver.sol";

contract Voters is IVoters, IERC677Receiver, AccessControl { 
    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint lastFeeGrowth;
        uint lockedToken;
        uint lockedSsLpValue;
        uint lockedSsLpAmount;
        uint lockedTcLpValue;
        uint lockedTcLpAmount;
        address delegate;
    }
    struct Snapshots {
        uint[] ids;
        uint[] values;
    }

    event Transfer(address indexed from, address indexed to, uint value);
    event Snapshot(uint id);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    string public constant name = "Thorstarter Voting Token";
    string public constant symbol = "vXRUNE";
    uint8 public constant decimals = 18;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER");
    bytes32 public constant SNAPSHOTTER_ROLE = keccak256("SNAPSHOTTER");
    IERC20 public token;
    IERC20 public sushiLpToken;
    uint public lastFeeGrowth;
    uint public totalSupply;
    mapping(address => UserInfo) private _userInfos;
    uint public currentSnapshotId;
    Snapshots private _totalSupplySnapshots;
    mapping(address => Snapshots) private _balancesSnapshots;
    mapping(address => uint) private _votes;
    mapping(address => Snapshots) private _votesSnapshots;
    mapping(address => bool) public historicalTcLps;
    address[] private _historicalTcLpsList;
    mapping(address => uint) public lastLockBlock;

    constructor(address _owner, address _token, address _sushiLpToken) {
        _setRoleAdmin(KEEPER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(SNAPSHOTTER_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _owner);
        _setupRole(KEEPER_ROLE, _owner);
        _setupRole(SNAPSHOTTER_ROLE, _owner);
        token = IERC20(_token);
        sushiLpToken = IERC20(_sushiLpToken);
        currentSnapshotId = 1;
    }

    function userInfo(address user) external view returns (uint, uint, uint, uint, uint, uint, address) {
      UserInfo storage userInfo = _userInfos[user];
      return (
        userInfo.lastFeeGrowth,
        userInfo.lockedToken,
        userInfo.lockedSsLpValue,
        userInfo.lockedSsLpAmount,
        userInfo.lockedTcLpValue,
        userInfo.lockedTcLpAmount,
        userInfo.delegate
      );
    }

    function balanceOf(address user) override public view returns (uint) {
        UserInfo storage userInfo = _userInfos[user];
        return _userInfoTotal(userInfo);
    }

    function balanceOfAt(address user, uint snapshotId) override external view returns (uint) {
        (bool snapshotted, uint value) = _valueAt(_balancesSnapshots[user], snapshotId);
        return snapshotted ? value : balanceOf(user);
    }

    function votes(address user) public view returns (uint) {
        return _votes[user];
    }

    function votesAt(address user, uint snapshotId) override external view returns (uint) {
        (bool snapshotted, uint value) = _valueAt(_votesSnapshots[user], snapshotId);
        return snapshotted ? value : votes(user);
    }

    function totalSupplyAt(uint snapshotId) override external view returns (uint) {
        (bool snapshotted, uint value) = _valueAt(_totalSupplySnapshots, snapshotId);
        return snapshotted ? value : totalSupply;
    }

    function approve(address spender, uint amount) external returns (bool) {
        revert("not implemented");
    }

    function transfer(address to, uint amount) external returns (bool) {
        revert("not implemented");
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {
        revert("not implemented");
    }

    function snapshot() override external onlyRole(SNAPSHOTTER_ROLE) returns (uint) {
        currentSnapshotId += 1;
        emit Snapshot(currentSnapshotId);
        return currentSnapshotId;
    }

    function _valueAt(Snapshots storage snapshots, uint snapshotId) private view returns (bool, uint) {
        if (snapshots.ids.length == 0) {
            return (false, 0);
        }
        uint lower = 0;
        uint upper = snapshots.ids.length;
        while (lower < upper) {
            uint mid = (lower & upper) + (lower ^ upper) / 2;
            if (snapshots.ids[mid] > snapshotId) {
                upper = mid;
            } else {
                lower = mid + 1;
            }
        }

        uint index = lower;
        if (lower > 0 && snapshots.ids[lower - 1] == snapshotId) {
          index = lower -1;
        }

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateSnapshot(Snapshots storage snapshots, uint value) private {
        uint currentId = currentSnapshotId;
        uint lastSnapshotId = 0;
        if (snapshots.ids.length > 0) {
            lastSnapshotId = snapshots.ids[snapshots.ids.length - 1];
        }
        if (lastSnapshotId < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(value);
        }
    }

    function delegate(address delegatee) external {
        require(delegatee != address(0), "zero address provided");
        UserInfo storage userInfo = _userInfos[msg.sender];
        address currentDelegate = userInfo.delegate;
        userInfo.delegate = delegatee;

        _updateSnapshot(_votesSnapshots[currentDelegate], votes(currentDelegate));
        _updateSnapshot(_votesSnapshots[delegatee], votes(delegatee));
        uint amount = balanceOf(msg.sender);
        _votes[currentDelegate] -= amount;
        _votes[delegatee] += amount;

        emit DelegateChanged(msg.sender, currentDelegate, delegatee);
    }

    function _lock(address user, uint amount) private {
        require(amount > 0, "!zero");
        UserInfo storage userInfo = _userInfo(user);

        // track last time a user called the lock method to prevent flash loan attacks
        lastLockBlock[user] = block.number;

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[user], balanceOf(user));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        totalSupply += amount;
        userInfo.lockedToken += amount;
        _votes[userInfo.delegate] += amount;
        emit Transfer(address(0), user, amount);
    }

    function lock(uint amount) external {
        _transferFrom(token, msg.sender, amount);
        _lock(msg.sender, amount);
    }

    function onTokenTransfer(address user, uint amount, bytes calldata _data) external override {
        require(msg.sender == address(token), "onTokenTransfer: not xrune");
        _lock(user, amount);
    }

    function unlock(uint amount) external {
        require(block.number > lastLockBlock[msg.sender], "no lock-unlock in same tx");

        UserInfo storage userInfo = _userInfo(msg.sender);
        require(amount <= userInfo.lockedToken, "locked balance too low");

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[msg.sender], balanceOf(msg.sender));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        totalSupply -= amount;
        userInfo.lockedToken -= amount;
        _votes[userInfo.delegate] -= amount;
        emit Transfer(msg.sender, address(0), amount);

        if (amount > 0) {
            token.safeTransfer(msg.sender, amount);
        }
    }

    function lockSslp(uint lpAmount) external {
        UserInfo storage userInfo = _userInfo(msg.sender);
        require(lpAmount > 0, "!zero");
        _transferFrom(sushiLpToken, msg.sender, lpAmount);

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[msg.sender], balanceOf(msg.sender));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        // Subtract current LP value
        uint previousValue = userInfo.lockedSsLpValue;
        totalSupply -= userInfo.lockedSsLpValue;
        _votes[userInfo.delegate] -= userInfo.lockedSsLpValue;

        // Increment LP amount
        userInfo.lockedSsLpAmount += lpAmount;

        // Calculated updated *full* LP amount value and set (not increment)
        // We do it like this and not based on just amount added so that unlock
        // knows that the lockedSsLpValue is based on one rate and not multiple adds
        uint lpTokenSupply = sushiLpToken.totalSupply();
        uint lpTokenReserve = token.balanceOf(address(sushiLpToken));
        require(lpTokenSupply > 0, "lp token supply can not be zero");
        uint amount = (2 * userInfo.lockedSsLpAmount * lpTokenReserve) / lpTokenSupply;
        totalSupply += amount; // Increment as we decremented
        _votes[userInfo.delegate] += amount; // Increment as we decremented
        userInfo.lockedSsLpValue = amount; // Set a we didn't ajust and amount is full value
        if (previousValue < userInfo.lockedSsLpValue) {
            emit Transfer(address(0), msg.sender, userInfo.lockedSsLpValue - previousValue);
        } else if (previousValue > userInfo.lockedSsLpValue) {
            emit Transfer(msg.sender, address(0), previousValue - userInfo.lockedSsLpValue);
        }
    }

    function unlockSslp(uint lpAmount) external {
        UserInfo storage userInfo = _userInfo(msg.sender);
        require(lpAmount > 0, "amount can't be 0");
        require(lpAmount <= userInfo.lockedSsLpAmount, "locked balance too low");

        _updateSnapshot(_totalSupplySnapshots, totalSupply);
        _updateSnapshot(_balancesSnapshots[msg.sender], balanceOf(msg.sender));
        _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

        // Proportionally decrement lockedSsLpValue & supply & delegated votes
        uint amount = lpAmount * userInfo.lockedSsLpValue / userInfo.lockedSsLpAmount;
        totalSupply -= amount;
        userInfo.lockedSsLpValue -= amount;
        userInfo.lockedSsLpAmount -= lpAmount;
        _votes[userInfo.delegate] -= amount;
        emit Transfer(msg.sender, address(0), amount);

        sushiLpToken.safeTransfer(msg.sender, lpAmount);
    }

    function updateTclp(address[] calldata users, uint[] calldata amounts, uint[] calldata values) external onlyRole(KEEPER_ROLE) {
        require(users.length == amounts.length && users.length == values.length, "length");
        for (uint i = 0; i < users.length; i++) {
            address user = users[i];
            UserInfo storage userInfo = _userInfo(user);
            _updateSnapshot(_totalSupplySnapshots, totalSupply);
            _updateSnapshot(_balancesSnapshots[user], balanceOf(user));
            _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

            uint previousValue = userInfo.lockedTcLpValue;
            totalSupply = totalSupply - previousValue + values[i];
            _votes[userInfo.delegate] = _votes[userInfo.delegate] - previousValue + values[i];
            userInfo.lockedTcLpValue = values[i];
            userInfo.lockedTcLpAmount = amounts[i];
            if (previousValue < values[i]) {
                emit Transfer(address(0), user, values[i] - previousValue);
            } else if (previousValue > values[i]) {
                emit Transfer(user, address(0), previousValue - values[i]);
            }

            // Add to historicalTcLpsList for keepers to use
            if (!historicalTcLps[user]) {
              historicalTcLps[user] = true;
              _historicalTcLpsList.push(user);
            }
        }
    }

    function historicalTcLpsList(uint page, uint pageSize) external view returns (address[] memory) {
      address[] memory list = new address[](pageSize);
      for (uint i = page * pageSize; i < (page + 1) * pageSize && i < _historicalTcLpsList.length; i++) {
        list[i-(page*pageSize)] = _historicalTcLpsList[i];
      }
      return list;
    }

    function donate(uint amount) override external {
        _transferFrom(token, msg.sender, amount);
        lastFeeGrowth += (amount * 1e12) / totalSupply;
    }

    function _userInfo(address user) private returns (UserInfo storage) {
        require(user != address(0), "zero address provided");
        UserInfo storage userInfo = _userInfos[user];
        if (userInfo.delegate == address(0)) {
            userInfo.delegate = user;
        }
        if (userInfo.lastFeeGrowth == 0 && lastFeeGrowth != 0) {
            userInfo.lastFeeGrowth = lastFeeGrowth;
        } else {
            uint fees = (_userInfoTotal(userInfo) * (lastFeeGrowth - userInfo.lastFeeGrowth)) / 1e12;
            if (fees > 0) {
                _updateSnapshot(_totalSupplySnapshots, totalSupply);
                _updateSnapshot(_balancesSnapshots[user], balanceOf(user));
                _updateSnapshot(_votesSnapshots[userInfo.delegate], votes(userInfo.delegate));

                totalSupply += fees;
                userInfo.lockedToken += fees;
                userInfo.lastFeeGrowth = lastFeeGrowth;
                _votes[userInfo.delegate] += fees;
                emit Transfer(address(0), user, fees);
            }
        }
        return userInfo;
    }

    function _userInfoTotal(UserInfo storage userInfo) private view returns (uint) {
        return userInfo.lockedToken + userInfo.lockedSsLpValue + userInfo.lockedTcLpValue;
    }

    function _transferFrom(IERC20 token, address from, uint amount) private {
        uint balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(from, address(this), amount);
        uint balanceAfter = token.balanceOf(address(this));
        require(balanceAfter - balanceBefore == amount, "_transferFrom: balance change does not match amount");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

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
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

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
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
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
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

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

// SPDX-License-Identifier: MIT

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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract receives XRUNE from the Thorstarter grants multisig and some
project tokens, then, when ready, an owner calls the `lock` method and both
tokens are paired in an AMM and the LP tokens are locked in this contract.
Over time, each party can claim their vested tokens. Each party is owed an
equal share of the initial amount of LP tokens. If a pool already exist, we
attempt to swap some amount of tokens to bring the price in line with the target
price.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IUniswapV2Router.sol';
import './interfaces/IUniswapV2Factory.sol';

contract LpTokenVesting {
    using SafeERC20 for IERC20;

    struct Party {
      uint claimedAmount;
      mapping(address => bool) owners;
    }

    IERC20 public token0;
    IERC20 public token1;
    IUniswapV2Router public sushiRouter;
    uint public vestingCliff;
    uint public vestingLength;

    uint public partyCount;
    mapping(uint => Party) public parties;
    mapping(address => bool) public owners;
    uint public initialLpShareAmount;
    uint public vestingStart;

    event Claimed(uint party, uint amount);
    event Locked(uint time, uint amount, uint balance0, uint balance1);

    constructor(address _token0, address _token1, address _sushiRouter, uint _vestingCliff, uint _vestingLength, address[] memory _owners) {
        (_token0, _token1) = _token0 < _token1 ? (_token0, _token1) : (_token1, _token0);
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        sushiRouter = IUniswapV2Router(_sushiRouter);
        vestingCliff = _vestingCliff;
        vestingLength = _vestingLength;
        partyCount = _owners.length;
        for (uint i = 0; i < _owners.length; i++) {
            Party storage p = parties[i];
            p.owners[_owners[i]] = true;
            owners[_owners[i]] = true;
        }
    }

    modifier onlyOwner {
        require(owners[msg.sender], "not an owner");
        _;
    }

    function toggleOwner(uint party, address owner) public {
        Party storage p = parties[party];
        require(p.owners[msg.sender], "not an owner of this party");
        p.owners[owner] = !p.owners[owner];
        owners[owner] = p.owners[owner];
    }

    function partyClaimedAmount(uint party) public view returns (uint) {
        return parties[party].claimedAmount;
    }

    function partyOwner(uint party, address owner) public view returns (bool) {
        return parties[party].owners[owner];
    }

    function pair() public view returns (address) {
        return IUniswapV2Factory(sushiRouter.factory()).getPair(address(token0), address(token1));
    }
    
    function claimable(uint party) public view returns (uint) {
        if (vestingStart == 0 || party >= partyCount) {
            return 0;
        }
        Party storage p = parties[party];
        uint percentVested = (block.timestamp - _min(block.timestamp, vestingStart + vestingCliff)) * 1e6 / vestingLength;
        if (percentVested > 1e6) {
            percentVested = 1e6;
        }
        return ((initialLpShareAmount * percentVested) / 1e6 / partyCount) - p.claimedAmount;
    }
    
    function claim(uint party) public returns (uint) {
        Party storage p = parties[party];
        require(p.owners[msg.sender], "not an owner of this party");
        uint amount = claimable(party);
        if (amount > 0) {
            p.claimedAmount += amount;
            IERC20(pair()).safeTransfer(msg.sender, amount);
            emit Claimed(party, amount);
        }
        return amount;
    }

    function lock() public onlyOwner {
        require(vestingStart == 0, "vesting already started");

        uint token0Balance = token0.balanceOf(address(this));
        uint token1Balance = token1.balanceOf(address(this));
        address pairAddress = pair();

        // If there's already a pair, we'll need to do a swap in order get the price in the right place
        if (pairAddress != address(0)) {
            IUniswapV2Pair pool = IUniswapV2Pair(pairAddress);
            uint targetPrice = (token0Balance * 1e6) / token1Balance;
            (uint112 reserve0, uint112 reserve1,) = pool.getReserves();
            uint currentPrice = (reserve0 * 1e6) / reserve1;
            uint difference = (currentPrice * 1e6) / targetPrice;
            if (difference < 995000) {
                // Current price is smaller than target (>0.5%), swap token1 for token0
                // We divide the amount of reserve1 to send that would balance the price
                // in two because an ammout of reserve0 is going to come out
                address[] memory path = new address[](2);
                path[0] = address(token0);
                path[1] = address(token1);
                // Multiply amount by 0.6 because swapping 100% of the difference would remove the
                // the equivalent amount from the opposite reserves (we're aiming for half that impact)
                uint amount = (reserve0 * (1e6 - difference) * 60) / 1e6 / 100;
                token0.safeApprove(address(sushiRouter), amount);
                sushiRouter.swapExactTokensForTokens(amount, 0, path, address(this), type(uint).max);
            }
            if (difference > 10050000) {
                // Current price is greater than target (>0.5%), swap token0 for token1
                address[] memory path = new address[](2);
                path[0] = address(token1);
                path[1] = address(token0);
                uint amount = (reserve1 * (difference - 1e6)) / 1e6 / 2;
                token1.safeApprove(address(sushiRouter), amount);
                sushiRouter.swapExactTokensForTokens(amount, 0, path, address(this), type(uint).max);
            }

            (reserve0, reserve1,) = pool.getReserves();
        }

        // Update balances in case we did a swap to adjust price
        token0Balance = token0.balanceOf(address(this));
        token1Balance = token1.balanceOf(address(this));
        token0.safeApprove(address(sushiRouter), token0Balance);
        token1.safeApprove(address(sushiRouter), token1Balance);
        sushiRouter.addLiquidity(
            address(token0), address(token1),
            token0Balance, token1Balance,
            (token0Balance * 9850) / 10000, (token1Balance * 9850) / 10000,
            address(this), type(uint).max
        );

        pairAddress = pair();
        initialLpShareAmount = IERC20(pairAddress).balanceOf(address(this));
        vestingStart = block.timestamp;
        emit Locked(vestingStart, initialLpShareAmount, token0Balance, token1Balance);
    }

    function withdraw(address token, uint amount) public onlyOwner {
       require(token == address(token0) || token == address(token1), "can only withdraw token{0,1}");
       IERC20(token).safeTransfer(msg.sender, amount);
    }

    function _min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address owner) {
        _owner = owner;
        emit OwnershipTransferred(address(0), owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ERC677.sol";
import "./ERC777Permit.sol";
import "./Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

contract XRUNE is ERC777, ERC777Permit, ERC677, Ownable {
    uint256 public constant ERA_SECONDS = 86400;
    uint256 public constant MAX_SUPPLY = 1000000000 ether;
    uint256 public nextEra = 1622433600; // 2021-05-31
    uint256 public curve = 1024;
    bool public emitting = false;
    address public reserve = address(0);

    event NewEra(uint256 time, uint256 emission);

    constructor(address owner)
        public
        ERC777("XRUNE Token", "XRUNE", new address[](0))
        ERC777Permit("XRUNE")
        Ownable(owner)
    {
        _mint(owner, MAX_SUPPLY / 2, "", "");
    }

    function setCurve(uint256 _curve) public onlyOwner {
        require(
            _curve > 0 && _curve < 10000,
            "curve needs to be between 0 and 10000"
        );
        curve = _curve;
    }

    function toggleEmitting() public onlyOwner {
        emitting = !emitting;
    }

    function setReserve(address _reserve) public onlyOwner {
        reserve = _reserve;
    }

    function setNextEra(uint256 next) public onlyOwner {
        // solhint-disable-next-line not-rely-on-time
        require(
            next > nextEra && next > block.timestamp,
            "next era needs to be in the future"
        );
        nextEra = next;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, amount);
        require(to != address(this), "!self");
        dailyEmit();
    }

    function dailyEmit() public {
        // solhint-disable-next-line not-rely-on-time
        if ((block.timestamp >= nextEra) && emitting && reserve != address(0)) {
            uint256 _emission = dailyEmission();
            emit NewEra(nextEra, _emission);
            nextEra = nextEra + ERA_SECONDS;
            _mint(reserve, _emission, "", "");
        }
    }

    function dailyEmission() public view returns (uint256) {
        return (MAX_SUPPLY - totalSupply()) / curve;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC677.sol";
import "./interfaces/IERC677Receiver.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";

abstract contract ERC677 is ERC777, IERC677 {
  /**
  * @dev transfer token to a contract address with additional data if the recipient is a contact.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  * @param _data The extra data to be passed to the receiving contract.
  */
  function transferAndCall(address _to, uint _value, bytes calldata _data)
    public
    override
    returns (bool success)
  {
    super.transfer(_to, _value);
    emit TransferWithData(msg.sender, _to, _value, _data);
    if (isContract(_to)) {
      contractFallback(_to, _value, _data);
    }
    return true;
  }

  function contractFallback(address _to, uint _value, bytes calldata _data)
    private
  {
    IERC677Receiver receiver = IERC677Receiver(_to);
    receiver.onTokenTransfer(msg.sender, _value, _data);
  }

  function isContract(address _addr)
    private
    view
    returns (bool hasCode)
  {
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/draft-ERC20Permit.sol

import "./interfaces/IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * _Available since v3.4._
 */
abstract contract ERC777Permit is ERC777, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    /**
     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `"1"`.
     *
     * It's a good idea to use the same `name` that is defined as the ERC20 token name.
     */
    constructor(string memory name) EIP712(name, "1") {
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC777.sol";
import "./IERC777Recipient.sol";
import "./IERC777Sender.sol";
import "../ERC20/IERC20.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/IERC1820Registry.sol";

/**
 * @dev Implementation of the {IERC777} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * Support for ERC20 is included in this contract, as specified by the EIP: both
 * the ERC777 and ERC20 interfaces can be safely used when interacting with it.
 * Both {IERC777-Sent} and {IERC20-Transfer} events are emitted on token
 * movements.
 *
 * Additionally, the {IERC777-granularity} value is hard-coded to `1`, meaning that there
 * are no special restrictions in the amount of tokens that created, moved, or
 * destroyed. This makes integration with ERC20 applications seamless.
 */
contract ERC777 is Context, IERC777, IERC20 {
    using Address for address;

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");

    // This isn't ever read from - it's only used to respond to the defaultOperators query.
    address[] private _defaultOperatorsArray;

    // Immutable, but accounts may revoke them (tracked in __revokedDefaultOperators).
    mapping(address => bool) private _defaultOperators;

    // For each account, a mapping of its operators and revoked default operators.
    mapping(address => mapping(address => bool)) private _operators;
    mapping(address => mapping(address => bool)) private _revokedDefaultOperators;

    // ERC20-allowances
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev `defaultOperators` may be an empty array.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) {
        _name = name_;
        _symbol = symbol_;

        _defaultOperatorsArray = defaultOperators_;
        for (uint256 i = 0; i < defaultOperators_.length; i++) {
            _defaultOperators[defaultOperators_[i]] = true;
        }

        // register interfaces
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));
    }

    /**
     * @dev See {IERC777-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC777-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {ERC20-decimals}.
     *
     * Always returns 18, as per the
     * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
     */
    function decimals() public pure virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC777-granularity}.
     *
     * This implementation always returns `1`.
     */
    function granularity() public view virtual override returns (uint256) {
        return 1;
    }

    /**
     * @dev See {IERC777-totalSupply}.
     */
    function totalSupply() public view virtual override(IERC20, IERC777) returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of tokens owned by an account (`tokenHolder`).
     */
    function balanceOf(address tokenHolder) public view virtual override(IERC20, IERC777) returns (uint256) {
        return _balances[tokenHolder];
    }

    /**
     * @dev See {IERC777-send}.
     *
     * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        _send(_msgSender(), recipient, amount, data, "", true);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient}
     * interface if it is a contract.
     *
     * Also emits a {Sent} event.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");

        address from = _msgSender();

        _callTokensToSend(from, from, recipient, amount, "", "");

        _move(from, from, recipient, amount, "", "");

        _callTokensReceived(from, from, recipient, amount, "", "", false);

        return true;
    }

    /**
     * @dev See {IERC777-burn}.
     *
     * Also emits a {IERC20-Transfer} event for ERC20 compatibility.
     */
    function burn(uint256 amount, bytes memory data) public virtual override {
        _burn(_msgSender(), amount, data, "");
    }

    /**
     * @dev See {IERC777-isOperatorFor}.
     */
    function isOperatorFor(address operator, address tokenHolder) public view virtual override returns (bool) {
        return
            operator == tokenHolder ||
            (_defaultOperators[operator] && !_revokedDefaultOperators[tokenHolder][operator]) ||
            _operators[tokenHolder][operator];
    }

    /**
     * @dev See {IERC777-authorizeOperator}.
     */
    function authorizeOperator(address operator) public virtual override {
        require(_msgSender() != operator, "ERC777: authorizing self as operator");

        if (_defaultOperators[operator]) {
            delete _revokedDefaultOperators[_msgSender()][operator];
        } else {
            _operators[_msgSender()][operator] = true;
        }

        emit AuthorizedOperator(operator, _msgSender());
    }

    /**
     * @dev See {IERC777-revokeOperator}.
     */
    function revokeOperator(address operator) public virtual override {
        require(operator != _msgSender(), "ERC777: revoking self as operator");

        if (_defaultOperators[operator]) {
            _revokedDefaultOperators[_msgSender()][operator] = true;
        } else {
            delete _operators[_msgSender()][operator];
        }

        emit RevokedOperator(operator, _msgSender());
    }

    /**
     * @dev See {IERC777-defaultOperators}.
     */
    function defaultOperators() public view virtual override returns (address[] memory) {
        return _defaultOperatorsArray;
    }

    /**
     * @dev See {IERC777-operatorSend}.
     *
     * Emits {Sent} and {IERC20-Transfer} events.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(sender, recipient, amount, data, operatorData, true);
    }

    /**
     * @dev See {IERC777-operatorBurn}.
     *
     * Emits {Burned} and {IERC20-Transfer} events.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(account, amount, data, operatorData);
    }

    /**
     * @dev See {IERC20-allowance}.
     *
     * Note that operator and allowance concepts are orthogonal: operators may
     * not have allowance, and accounts with allowance may not be operators
     * themselves.
     */
    function allowance(address holder, address spender) public view virtual override returns (uint256) {
        return _allowances[holder][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Note that accounts cannot have allowance issued by their operators.
     */
    function approve(address spender, uint256 value) public virtual override returns (bool) {
        address holder = _msgSender();
        _approve(holder, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Note that operator and allowance concepts are orthogonal: operators cannot
     * call `transferFrom` (unless they have allowance), and accounts with
     * allowance cannot call `operatorSend` (unless they are operators).
     *
     * Emits {Sent}, {IERC20-Transfer} and {IERC20-Approval} events.
     */
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");

        address spender = _msgSender();

        _callTokensToSend(spender, holder, recipient, amount, "", "");

        _move(spender, holder, recipient, amount, "", "");

        uint256 currentAllowance = _allowances[holder][spender];
        require(currentAllowance >= amount, "ERC777: transfer amount exceeds allowance");
        _approve(holder, spender, currentAllowance - amount);

        _callTokensReceived(spender, holder, recipient, amount, "", "", false);

        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `operator`, `data` and `operatorData`.
     *
     * See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits {Minted} and {IERC20-Transfer} events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) internal virtual {
        _mint(account, amount, userData, operatorData, true);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * If `requireReceptionAck` is set to true, and if a send hook is
     * registered for `account`, the corresponding function will be called with
     * `operator`, `data` and `operatorData`.
     *
     * See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits {Minted} and {IERC20-Transfer} events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        // Update state variables
        _totalSupply += amount;
        _balances[account] += amount;

        _callTokensReceived(operator, address(0), account, amount, userData, operatorData, requireReceptionAck);

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Send tokens
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _send(
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, to, amount, userData, operatorData);

        _move(operator, from, to, amount, userData, operatorData);

        _callTokensReceived(operator, from, to, amount, userData, operatorData, requireReceptionAck);
    }

    /**
     * @dev Burn tokens
     * @param from address token holder address
     * @param amount uint256 amount of tokens to burn
     * @param data bytes extra information provided by the token holder
     * @param operatorData bytes extra information provided by the operator (if any)
     */
    function _burn(
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {
        require(from != address(0), "ERC777: burn from the zero address");

        address operator = _msgSender();

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _beforeTokenTransfer(operator, from, address(0), amount);

        // Update state variables
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: burn amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _totalSupply -= amount;

        emit Burned(operator, from, amount, data, operatorData);
        emit Transfer(from, address(0), amount);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        _beforeTokenTransfer(operator, from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC777: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Sent(operator, from, to, amount, userData, operatorData);
        emit Transfer(from, to, amount);
    }

    /**
     * @dev See {ERC20-_approve}.
     *
     * Note that accounts cannot have allowance issued by their operators.
     */
    function _approve(
        address holder,
        address spender,
        uint256 value
    ) internal {
        require(holder != address(0), "ERC777: approve from the zero address");
        require(spender != address(0), "ERC777: approve to the zero address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    /**
     * @dev Call from.tokensToSend() if the interface is registered
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     */
    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    /**
     * @dev Call to.tokensReceived() if the interface is registered. Reverts if the recipient is a contract but
     * tokensReceived() was not registered for the recipient
     * @param operator address operator requesting the transfer
     * @param from address token holder address
     * @param to address recipient address
     * @param amount uint256 amount of tokens to transfer
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @param requireReceptionAck if true, contract recipients are required to implement ERC777TokensRecipient
     */
    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, userData, operatorData);
        } else if (requireReceptionAck) {
            require(!to.isContract(), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes
     * calls to {send}, {transfer}, {operatorSend}, minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC677 {
  function transferAndCall(address to, uint value, bytes calldata data) external returns (bool success);

  event TransferWithData(address indexed from, address indexed to, uint value, bytes data);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777TokensRecipient standard as defined in the EIP.
 *
 * Accounts can be notified of {IERC777} tokens being sent to them by having a
 * contract implement this interface (contract holders can be their own
 * implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777Recipient {
    /**
     * @dev Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777TokensSender standard as defined in the EIP.
 *
 * {IERC777} Token holders can be notified of operations performed on their
 * tokens by having a contract implement this interface (contract holders can be
 * their own implementer) and registering it on the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 global registry].
 *
 * See {IERC1820Registry} and {ERC1820Implementer}.
 */
interface IERC777Sender {
    /**
     * @dev Called by an {IERC777} token contract whenever a registered holder's
     * (`from`) tokens are about to be moved or destroyed. The type of operation
     * is conveyed by `to` being the zero address or not.
     *
     * This call occurs _before_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the pre-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the global ERC1820 Registry, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1820[EIP]. Accounts may register
 * implementers for interfaces in this registry, as well as query support.
 *
 * Implementers may be shared by multiple accounts, and can also implement more
 * than a single interface for each account. Contracts can implement interfaces
 * for themselves, but externally-owned accounts (EOA) must delegate this to a
 * contract.
 *
 * {IERC165} interfaces can also be queried via the registry.
 *
 * For an in-depth explanation and source code analysis, see the EIP text.
 */
interface IERC1820Registry {
    /**
     * @dev Sets `newManager` as the manager for `account`. A manager of an
     * account is able to set interface implementers for it.
     *
     * By default, each account is its own manager. Passing a value of `0x0` in
     * `newManager` will reset the manager to this initial state.
     *
     * Emits a {ManagerChanged} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     */
    function setManager(address account, address newManager) external;

    /**
     * @dev Returns the manager for `account`.
     *
     * See {setManager}.
     */
    function getManager(address account) external view returns (address);

    /**
     * @dev Sets the `implementer` contract as ``account``'s implementer for
     * `interfaceHash`.
     *
     * `account` being the zero address is an alias for the caller's address.
     * The zero address can also be used in `implementer` to remove an old one.
     *
     * See {interfaceHash} to learn how these are created.
     *
     * Emits an {InterfaceImplementerSet} event.
     *
     * Requirements:
     *
     * - the caller must be the current manager for `account`.
     * - `interfaceHash` must not be an {IERC165} interface id (i.e. it must not
     * end in 28 zeroes).
     * - `implementer` must implement {IERC1820Implementer} and return true when
     * queried for support, unless `implementer` is the caller. See
     * {IERC1820Implementer-canImplementInterfaceForAddress}.
     */
    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;

    /**
     * @dev Returns the implementer of `interfaceHash` for `account`. If no such
     * implementer is registered, returns the zero address.
     *
     * If `interfaceHash` is an {IERC165} interface id (i.e. it ends with 28
     * zeroes), `account` will be queried for support of it.
     *
     * `account` being the zero address is an alias for the caller's address.
     */
    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);

    /**
     * @dev Returns the interface hash for an `interfaceName`, as defined in the
     * corresponding
     * https://eips.ethereum.org/EIPS/eip-1820#interface-name[section of the EIP].
     */
    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);

    /**
     * @notice Updates the cache with whether the contract implements an ERC165 interface or not.
     * @param account Address of the contract for which to update the cache.
     * @param interfaceId ERC165 interface for which to update the cache.
     */
    function updateERC165Cache(address account, bytes4 interfaceId) external;

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not.
     * If the result is not cached a direct lookup on the contract address is performed.
     * If the result is not cached or the cached value is out-of-date, the cache MUST be updated manually by calling
     * {updateERC165Cache} with the contract address.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);

    /**
     * @notice Checks whether a contract implements an ERC165 interface or not without using nor updating the cache.
     * @param account Address of the contract to check.
     * @param interfaceId ERC165 interface to check.
     * @return True if `account` implements `interfaceId`, false otherwise.
     */
    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);

    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/draft-IERC20Permit.sol

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`, `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "../ERC677.sol";

contract MockToken is ERC677 {
    constructor() ERC777("MockToken", "MTOK", new address[](0)) {
        _mint(msg.sender, 500000000e18, "", "");
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract receives XRUNE from the `EmissionsSplitter` contract and allows
private investors to claim their share of vested tokens. If they need to update
their address the owner can do so for them.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract EmissionsPrivateDispenser is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public token;
    uint public totalReceived;
    mapping(address => uint) public investorsPercentages; // 1e12 = 100%
    mapping(address => uint) public investorsClaimedAmount;

    event ConfigureInvestor(address investor, uint percentage);
    event Claim(address user, uint amount);
    event Deposit(uint amount);

    constructor(address _token, address[] memory investors, uint[] memory percentages) {
        token = IERC20(_token);
        require(investors.length == percentages.length);
        for (uint i = 0; i < investors.length; i++) {
          investorsPercentages[investors[i]] = percentages[i];
          emit ConfigureInvestor(investors[i], percentages[i]);
        }
    }

    function updateInvestorAddress(address oldAddress, address newAddress) public onlyOwner {
        require(investorsPercentages[oldAddress] > 0, "not an investor");
        investorsPercentages[newAddress] = investorsPercentages[oldAddress];
        investorsPercentages[oldAddress] = 0;
        investorsClaimedAmount[newAddress] = investorsClaimedAmount[oldAddress];
        investorsClaimedAmount[oldAddress] = 0;
        emit ConfigureInvestor(newAddress, investorsPercentages[newAddress]);
    }
    
    function claimable(address user) public view returns (uint) {
        return ((totalReceived * investorsPercentages[user]) / 1e12) - investorsClaimedAmount[user];
    }

    function claim() public {
        uint amount = claimable(msg.sender);
        require(amount > 0, "nothing to claim");
        investorsClaimedAmount[msg.sender] += amount;
        token.safeTransfer(msg.sender, amount);
        emit Claim(msg.sender, amount);
    }

    function deposit(uint amount) public {
        token.safeTransferFrom(msg.sender, address(this), amount);
        totalReceived += amount;
        emit Deposit(amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import '../Voters.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

contract VotersLockUnlock {
    using SafeERC20 for IERC20;

    function run(address voters, uint amount) public {
        Voters v = Voters(voters);
        IERC20(v.token()).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(v.token()).approve(voters, amount);
        v.lock(amount);
        v.unlock(amount);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract allows the sale of an "offering" token in exchange for a "payment"
token.
It let's investors buy tokens at a fixed price but depending on the amount of
interest investors will get a variable allocation size (also called batch auction).
The sale is configured with an target amount of payment token to raise and set
amount of offering tokens to sell. Investors can participate multiple times.
Once the sale ends, investors get to claim their tokens and possibly their
payment token refund (for the execess amount that wasn't used to purchase tokens).
*/

import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import './interfaces/IVoters.sol';

contract Sale is ReentrancyGuard {
  using SafeERC20 for IERC20;

  // Information of each user's participation
  struct UserInfo {
      // How many tokens the user has provided
      uint amount;
      // Wether this user has already claimed their refund, defaults to false
      bool claimedRefund;
      // Wether this user has already claimed their share of tokens, defaults to false
      bool claimedTokens;
  }

  // Owner address, has access to withdrawing funds after the sale
  address public owner;
  // Keeper address, has access to tweaking sake parameters
  address public keeper;
  // The raising token
  IERC20 public paymentToken;
  // The offering token
  IERC20 public offeringToken;
  // The block number when sale starts
  uint public startBlock;
  // The block number when sale ends
  uint public endBlock;
  // The block number when tokens are redeemable
  uint public tokensBlock;
  // Total amount of raising tokens that need to be raised
  uint public raisingAmount;
  // Total amount of offeringToken that will be offered
  uint public offeringAmount;
  // Maximum a user can contribute
  uint public perUserCap;
  // Voting token minimum balance to participate
  uint public votingMinimum;
  // Voting token address
  IVoters public votingToken;
  // Voting token snapshot id to use for balances (optional)
  uint public votingSnapshotId;
  // Wether deposits are paused
  bool public paused;
  // Total amount of raising tokens that have already been raised
  uint public totalAmount;
  // Total amount payment token withdrawn by project
  uint public totalAmountWithdrawn;
  // User's participation info
  mapping(address => UserInfo) public userInfo;
  // Participants list
  address[] public addressList;


  event Deposit(address indexed user, uint amount);
  event HarvestRefund(address indexed user, uint amount);
  event HarvestTokens(address indexed user, uint amount);

  constructor(
      IERC20 _paymentToken,
      IERC20 _offeringToken,
      uint _startBlock,
      uint _endBlock,
      uint _tokensBlock,
      uint _offeringAmount,
      uint _raisingAmount,
      uint _perUserCap,
      address _owner,
      address _keeper
  ) {
      paymentToken = _paymentToken;
      offeringToken = _offeringToken;
      startBlock = _startBlock;
      endBlock = _endBlock;
      tokensBlock = _tokensBlock;
      offeringAmount = _offeringAmount;
      raisingAmount = _raisingAmount;
      perUserCap = _perUserCap;
      totalAmount = 0;
      owner = _owner;
      keeper = _keeper;
      _validateBlockParams();
      require(_paymentToken != _offeringToken, 'payment != offering');
      require(_offeringAmount > 0, 'offering > 0');
      require(_raisingAmount > 0, 'raising > 0');
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "!owner");
    _;
  }

  modifier onlyOwnerOrKeeper() {
    require(msg.sender == owner || msg.sender == keeper, "!owner or keeper");
    _;
  }

  function _validateBlockParams() private view {
    require(startBlock > block.number, 'start > now');
    require(endBlock >= startBlock, 'end > start');
    require(endBlock - startBlock <= 172800, 'end < 1 month after start');
    require(tokensBlock - endBlock <= 172800, 'tokens < 1 month after end');
  }

  function setOfferingAmount(uint _offerAmount) public onlyOwnerOrKeeper {
    require (block.number < startBlock, 'sale started');
    offeringAmount = _offerAmount;
  }

  function setRaisingAmount(uint _raisingAmount) public onlyOwnerOrKeeper {
    require (block.number < startBlock, 'sale started');
    raisingAmount = _raisingAmount;
  }

  function setStartBlock(uint _block) public onlyOwnerOrKeeper {
    startBlock = _block;
    _validateBlockParams();
  }

  function setEndBlock(uint _block) public onlyOwnerOrKeeper {
    endBlock = _block;
    _validateBlockParams();
  }

  function setTokensBlock(uint _block) public onlyOwnerOrKeeper {
    tokensBlock = _block;
    _validateBlockParams();
  }

  function configureVotingToken(uint minimum, address token, uint snapshotId) public onlyOwnerOrKeeper {
    votingMinimum = minimum;
    votingToken = IVoters(token);
    votingSnapshotId = snapshotId;
  }

  function togglePaused() public onlyOwnerOrKeeper {
    paused = !paused;
  }

  function deposit(uint _amount) public {
    require(!paused, 'paused');
    require(block.number > startBlock && block.number < endBlock, 'sale not active');
    require(_amount > 0, 'need amount > 0');

    if (votingMinimum > 0) {
      if (votingSnapshotId == 0) {
        require(votingToken.balanceOf(msg.sender) >= votingMinimum, "under minimum locked");
      } else {
        require(votingToken.balanceOfAt(msg.sender, votingSnapshotId) >= votingMinimum, "under minimum locked");
      }
    }

    paymentToken.safeTransferFrom(address(msg.sender), address(this), _amount);
    if (userInfo[msg.sender].amount == 0) {
      addressList.push(address(msg.sender));
    }
    userInfo[msg.sender].amount = userInfo[msg.sender].amount + _amount;
    totalAmount = totalAmount + _amount;
    require(perUserCap == 0 || userInfo[msg.sender].amount <= perUserCap, 'over per user cap');
    emit Deposit(msg.sender, _amount);
  }

  function harvestRefund() public nonReentrant {
    require (block.number > endBlock, 'not harvest time');
    require (userInfo[msg.sender].amount > 0, 'have you participated?');
    require (!userInfo[msg.sender].claimedRefund, 'nothing to harvest');
    uint amount = getRefundingAmount(msg.sender);
    if (amount > 0) {
      paymentToken.safeTransfer(address(msg.sender), amount);
    }
    userInfo[msg.sender].claimedRefund = true;
    emit HarvestRefund(msg.sender, amount);
  }

  function harvestTokens() public nonReentrant {
    require (block.number > tokensBlock, 'not harvest time');
    require (userInfo[msg.sender].amount > 0, 'have you participated?');
    require (!userInfo[msg.sender].claimedTokens, 'nothing to harvest');
    uint amount = getOfferingAmount(msg.sender);
    if (amount > 0) {
      offeringToken.safeTransfer(address(msg.sender), amount);
    }
    userInfo[msg.sender].claimedTokens = true;
    emit HarvestTokens(msg.sender, amount);
  }

  function harvestAll() public {
    harvestRefund();
    harvestTokens();
  }

  function hasHarvestedRefund(address _user) external view returns (bool) {
      return userInfo[_user].claimedRefund;
  }

  function hasHarvestedTokens(address _user) external view returns (bool) {
      return userInfo[_user].claimedTokens;
  }

  // Allocation in percent, 1 means 0.000001(0.0001%), 1000000 means 1(100%)
  function getUserAllocation(address _user) public view returns (uint) {
    return (userInfo[_user].amount * 1e12) / totalAmount / 1e6;
  }

  // Amount of offering token a user will receive
  function getOfferingAmount(address _user) public view returns (uint) {
    if (totalAmount > raisingAmount) {
      uint allocation = getUserAllocation(_user);
      return (offeringAmount * allocation) / 1e6;
    } else {
      return (userInfo[_user].amount * offeringAmount) / raisingAmount;
    }
  }

  // Amount of the offering token a user will be refunded
  function getRefundingAmount(address _user) public view returns (uint) {
    if (totalAmount <= raisingAmount) {
      return 0;
    }
    uint allocation = getUserAllocation(_user);
    uint payAmount = (raisingAmount * allocation) / 1e6;
    return userInfo[_user].amount - payAmount;
  }

  function getAddressListLength() external view returns (uint) {
    return addressList.length;
  }

  function getParams() external view returns (uint, uint, uint, uint, uint, uint, uint, uint) {
    return (startBlock, endBlock, tokensBlock, offeringAmount, raisingAmount, perUserCap, totalAmount, addressList.length);
  }

  function finalWithdraw(uint _paymentAmount, uint _offeringAmount) public onlyOwner {
    require (_paymentAmount <= paymentToken.balanceOf(address(this)), 'not enough payment token');
    require (_offeringAmount <= offeringToken.balanceOf(address(this)), 'not enough offerring token');
    if (_paymentAmount > 0) {
      paymentToken.safeTransfer(address(msg.sender), _paymentAmount);
      totalAmountWithdrawn += _paymentAmount;
      require(totalAmountWithdrawn <= raisingAmount, 'can only widthdraw what is owed');
    }
    if (_offeringAmount > 0) {
      offeringToken.safeTransfer(address(msg.sender), _offeringAmount);
    }
  }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/*
This contract receives XRUNE token emissions, approximately once a day. It
them allows it's `run` method to be called wich will split up it's current
balance between the private investors, tema, dao and ecosystem
contracts/addresses following their respective vesting curves.
*/

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

interface IEmissionsPrivateDispenser {
    function deposit(uint amount) external;
}

contract EmissionsSplitter {
    using SafeERC20 for IERC20;

    uint public constant ONE_YEAR = 31536000;
    uint public constant INVESTORS_EMISSIONS_HALF1 = 45000000e18;
    uint public constant INVESTORS_EMISSIONS_HALF2 = 30000000e18;
    uint public constant TEAM_EMISSIONS_HALF1 = 66000000e18;
    uint public constant TEAM_EMISSIONS_HALF2 = 44000000e18;
    uint public constant ECOSYSTEM_EMISSIONS = 250000000e18;

    IERC20 public token;
    uint public emissionsStart;
    address public dao; // DAO contract address
    address public ecosystem; // Coucil Gnosis Safe address
    address public team; // Team Gnosis Safe address
    address public investors; // EmissionsPrivateDispenser address

    uint public sentToTeam;
    uint public sentToInvestors;
    uint public sentToEcosystem;

    event Split(uint amount, uint dao, uint team, uint investors, uint ecosystem);

    constructor(address _token, uint _emissionsStart, address _dao, address _team, address _investors, address _ecosystem) {
        token = IERC20(_token);
        emissionsStart = _emissionsStart;
        dao = _dao;
        team = _team;
        investors = _investors;
        ecosystem = _ecosystem;
    }
    
    function shouldRun() public view returns (bool) {
        return token.balanceOf(address(this)) > 0;
    }

    function run() public {
        uint initialAmount = token.balanceOf(address(this));
        uint amount = initialAmount;
        require(amount > 0, "no balance to split");

        uint sentToInvestorsNow = 0;
        {
            // Investors get 45M tokens linearly over the first year
            uint investorsProgress = _min(((block.timestamp - emissionsStart) * 1e12) / ONE_YEAR, 1e12);
            uint investorsUnlocked = (investorsProgress * INVESTORS_EMISSIONS_HALF1) / 1e12;
            uint investorsAmount = _min(investorsUnlocked - sentToInvestors, amount);
            if (investorsAmount > 0) {
                sentToInvestorsNow += investorsAmount;
                sentToInvestors += investorsAmount;
                amount -= investorsAmount;
                token.safeApprove(investors, investorsAmount);
                IEmissionsPrivateDispenser(investors).deposit(investorsAmount);
            }
        }
        {
            // Investors get their remaining 30M tokens linearly over the second year
            uint elapsed = block.timestamp - emissionsStart;
            elapsed -= _min(elapsed, ONE_YEAR);
            uint investorsProgress = _min((elapsed * 1e12) / ONE_YEAR, 1e12);
            uint investorsUnlocked = (investorsProgress * INVESTORS_EMISSIONS_HALF2) / 1e12;
            uint investorsAmount = _min(investorsUnlocked - _min(investorsUnlocked, sentToInvestors), amount);
            if (investorsAmount > 0) {
                sentToInvestorsNow += investorsAmount;
                sentToInvestors += investorsAmount;
                amount -= investorsAmount;
                token.safeApprove(investors, investorsAmount);
                IEmissionsPrivateDispenser(investors).deposit(investorsAmount);
            }
        }
        
        uint sentToTeamNow = 0;
        {
            // Team get 66M tokens linearly over the first 2 years
            uint teamProgress = _min(((block.timestamp - emissionsStart) * 1e12) / (2 * ONE_YEAR), 1e12);
            uint teamUnlocked = (teamProgress * TEAM_EMISSIONS_HALF1) / 1e12;
            uint teamAmount = _min(teamUnlocked - sentToTeam, amount);
            if (teamAmount > 0) {
                sentToTeamNow += teamAmount;
                sentToTeam += teamAmount;
                amount -= teamAmount;
                token.safeTransfer(team, teamAmount);
            }
        }
        {
            // Team get their remaining 44M tokens linearly over the next 2 years
            uint elapsed = block.timestamp - emissionsStart;
            elapsed -= _min(elapsed, 2 * ONE_YEAR);
            uint teamProgress = _min((elapsed * 1e12) / (2 * ONE_YEAR), 1e12);
            uint teamUnlocked = (teamProgress * TEAM_EMISSIONS_HALF1) / 1e12;
            uint teamAmount = _min(teamUnlocked - _min(teamUnlocked, sentToTeam), amount);
            if (teamAmount > 0) {
                sentToTeamNow += teamAmount;
                sentToTeam += teamAmount;
                amount -= teamAmount;
                token.safeTransfer(team, teamAmount);
            }
        }

        uint ecosystemProgress = _min(((block.timestamp - emissionsStart) * 1e12) / (10 * ONE_YEAR), 1e12);
        uint ecosystemUnlocked = (ecosystemProgress * ECOSYSTEM_EMISSIONS) / 1e12;
        uint ecosystemAmount = _min(ecosystemUnlocked - sentToEcosystem, amount);
        if (ecosystemAmount > 0) {
            sentToEcosystem += ecosystemAmount;
            amount -= ecosystemAmount;
            token.safeTransfer(ecosystem, ecosystemAmount);
        }

        if (amount > 0) {
            token.safeTransfer(dao, amount);
        }

        emit Split(initialAmount, amount, sentToTeamNow, sentToInvestorsNow, ecosystemAmount);
    }

    function _min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}

{
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  },
  "libraries": {}
}