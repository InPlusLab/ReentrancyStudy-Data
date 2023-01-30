/**
 *Submitted for verification at Etherscan.io on 2020-03-27
*/

// File: @openzeppelin/contracts/GSN/Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: contracts/IRealitio.sol

pragma solidity >=0.5.16;

interface IRealitio {
    /// @notice Set a fee for asking a question with us as the arbitrator
    /// @dev Default is no fee. Unlike the dispute fee, 0 is an acceptable setting.
    /// You could set an impossibly high fee if you want to prevent us being used as arbitrator unless we submit the question.
    /// (Submitting the question ourselves is not implemented here.)
    /// This fee can be used as a revenue source, an anti-spam measure, or both.
    /// @param fee The fee amount
    function setQuestionFee(uint256 fee) external;

    /// @notice Notify the contract that the arbitrator has been paid for a question, freezing it pending their decision.
    /// @dev The arbitrator contract is trusted to only call this if they've been paid, and tell us who paid them.
    /// @param questionId The ID of the question
    /// @param requester The account that requested arbitration
    /// @param maxPrevious If specified, reverts if a bond higher than this was submitted after you sent your transaction.
    function notifyOfArbitrationRequest(
        bytes32 questionId,
        address requester,
        uint256 maxPrevious
    ) external;

    /// @notice Submit the answer for a question, for use by the arbitrator.
    /// @dev Doesn't require (or allow) a bond.
    /// If the current final answer is correct, the account should be whoever submitted it.
    /// If the current final answer is wrong, the account should be whoever paid for arbitration.
    /// However, the answerer stipulations are not enforced by the contract.
    /// @param questionId The ID of the question
    /// @param answer The answer, encoded into bytes32
    /// @param answerer The account credited with this answer for the purpose of bond claims
    function submitAnswerByArbitrator(
        bytes32 questionId,
        bytes32 answer,
        address answerer
    ) external;

    /// @notice Report whether the answer to the specified question is finalized
    /// @param questionId The ID of the question
    /// @return Return true if finalized
    function isFinalized(bytes32 questionId) external view returns (bool);

    function withdraw() external;
}

// File: contracts/Arbitrator.sol

pragma solidity >=0.5.16;




contract Arbitrator is Ownable {

    IRealitio public realitio;

    mapping(bytes32 => uint256) public arbitration_bounties;

    uint256 disputeFee;
    mapping(bytes32 => uint256) customDisputeFees;

    string public metadata;

    event LogRequestArbitration(
        bytes32 indexed questionId,
        uint256 feePaid,
        address requester,
        uint256 remaining
    );

    event LogSetRealitio(
        address realitio
    );

    event LogSetQuestionFee(
        uint256 fee
    );


    event LogSetDisputeFee(
        uint256 fee
    );

    event LogSetCustomDisputeFee(
        bytes32 indexed questionId,
        uint256 fee
    );

    /// @notice Returns the IRealitio contract address - deprecated in favour of realitio()
    function realitycheck() external view returns (IRealitio) {
        return realitio;
    }

    /// @notice Set the Reality Check contract address
    /// @param addr The address of the Reality Check contract
    function setRealitio(address addr)
        external
        onlyOwner
    {
        realitio = IRealitio(addr);
        emit LogSetRealitio(addr);
    }

    /// @notice Set the default fee
    /// @param fee The default fee amount
    function setDisputeFee(uint256 fee)
        external
        onlyOwner
    {
        disputeFee = fee;
        emit LogSetDisputeFee(fee);
    }

    /// @notice Set a custom fee for this particular question
    /// @param questionId The question in question
    /// @param fee The fee amount
    function setCustomDisputeFee(bytes32 questionId, uint256 fee)
        external
        onlyOwner
    {
        customDisputeFees[questionId] = fee;
        emit LogSetCustomDisputeFee(questionId, fee);
    }

    /// @notice Return the dispute fee for the specified question. 0 indicates that we won't arbitrate it.
    /// @param questionId The question in question
    /// @dev Uses a general default, but can be over-ridden on a question-by-question basis.
    function getDisputeFee(bytes32 questionId)
        public
        view
        returns (uint256)
    {
        return (customDisputeFees[questionId] > 0) ? customDisputeFees[questionId] : disputeFee;
    }

    /// @notice Set a fee for asking a question with us as the arbitrator
    /// @param fee The fee amount
    /// @dev Default is no fee. Unlike the dispute fee, 0 is an acceptable setting.
    /// You could set an impossibly high fee if you want to prevent us being used as arbitrator unless we submit the question.
    /// (Submitting the question ourselves is not implemented here.)
    /// This fee can be used as a revenue source, an anti-spam measure, or both.
    function setQuestionFee(uint256 fee)
        external
        onlyOwner
    {
        realitio.setQuestionFee(fee);
        emit LogSetQuestionFee(fee);
    }

    /// @notice Submit the arbitrator's answer to a question.
    /// @param questionId The question in question
    /// @param answer The answer
    /// @param answerer The answerer. If arbitration changed the answer, it should be the payer. If not, the old answerer.
    function submitAnswerByArbitrator(bytes32 questionId, bytes32 answer, address answerer)
        external
        onlyOwner
    {
        delete arbitration_bounties[questionId];
        realitio.submitAnswerByArbitrator(questionId, answer, answerer);
    }

    /// @notice Request arbitration, freezing the question until we send submitAnswerByArbitrator
    /// @dev The bounty can be paid only in part, in which case the last person to pay will be considered the payer
    /// Will trigger an error if the notification fails, eg because the question has already been finalized
    /// @param questionId The question in question
    /// @param maxPrevious If specified, reverts if a bond higher than this was submitted after you sent your transaction.
    function requestArbitration(bytes32 questionId, uint256 maxPrevious)
        external
        payable
        returns (bool)
    {
        uint256 arbitrationFee = getDisputeFee(questionId);
        require(arbitrationFee > 0, "The arbitrator must have set a non-zero fee for the question");

        arbitration_bounties[questionId] += msg.value;
        uint256 paid = arbitration_bounties[questionId];

        if (paid >= arbitrationFee) {
            realitio.notifyOfArbitrationRequest(questionId, msg.sender, maxPrevious);
            emit LogRequestArbitration(questionId, msg.value, msg.sender, 0);
            return true;
        } else {
            require(!realitio.isFinalized(questionId), "The question must not have been finalized");
            emit LogRequestArbitration(questionId, msg.value, msg.sender, arbitrationFee - paid);
            return false;
        }
    }

    /// @notice Withdraw any accumulated ETH fees to the specified address
    /// @param recipient The address to which the balance should be sent
    function withdraw(address payable recipient)
        external
        onlyOwner
    {
        recipient.transfer(address(this).balance);
    }

    /// @notice Withdraw any accumulated token fees to the specified address
    /// @param recipient The address to which the balance should be sent
    /// @dev Only needed if the IRealitio contract used is using an ERC20 token
    /// @dev Also only normally useful if a per-question fee is set, otherwise we only have ETH.
    function withdrawERC20(IERC20 token, address recipient)
        external
        onlyOwner
    {
        require(
            IERC20(token).transfer(recipient, token.balanceOf(address(this))),
            "withdrawing ERC-20 failed"
        );
    }

    function () external payable {}

    /// @notice Withdraw any accumulated question fees from the specified address into this contract
    /// @dev Funds can then be liberated from this contract with our withdraw() function
    /// @dev This works in the same way whether the realitio contract is using ETH or an ERC20 token
    function callWithdraw()
        external
        onlyOwner
    {
        realitio.withdraw();
    }

    /// @notice Set a metadata string, expected to be JSON, containing things like arbitrator TOS address
    function setMetaData(string calldata _metadata)
        external
        onlyOwner
    {
        metadata = _metadata;
    }
}