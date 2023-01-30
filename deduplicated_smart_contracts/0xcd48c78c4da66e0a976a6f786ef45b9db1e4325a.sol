/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

pragma solidity ^0.5.7;

// File: contracts/AllocationToken/IAllocationToken.sol

/**
@title IAllocationToken
@notice This contract provides an interface for AllocationToken
 */
contract IAllocationToken {
    /**
    @dev fired on exchange contract's updation
    @param exchangeContract the address of exchange contract
     */
    event ExchangeContractUpdated(address exchangeContract);

    /**
    @dev fired on investment contract's updation
    @param investmentContract the address of investment contract
     */
    event InvestmentContractUpdated(address investmentContract);

    /**
    @dev updates exchange contract's address
    @param _exchangeContract the address of updated exchange contract
     */
    function updateExchangeContract(address _exchangeContract) external;

    /**
    @dev updates the investment contract's address
    @param _investmentContract the address of updated innvestment contract
     */
    function updateInvestmentContract(address _investmentContract) external;

    /**
    @notice Allows to mint new AT tokens
    @dev Only owner or exchange contract can call this function
    @param _holder The address to mint the tokens to
    @param _tokens The amount of tokens to mint
     */
    function mint(address _holder, uint256 _tokens) public;

    /**
    @notice Allows to burn AT tokens
    @dev Only Investment contract contract can call this function
    @param _address The address to burn the tokens from
    @param _value The amount of tokens to burn
    */
    function burn(address _address, uint256 _value) public;
}

// File: contracts/Ownable/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
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
        return msg.sender == _owner;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
  * @dev Adds two numbers, throws on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts/KYC/IKYC.sol

/// @title IKYC
/// @notice This contract represents interface for KYC contract
contract IKYC {
    // Fired after the status for a manager is updated
    event ManagerStatusUpdated(address KYCManager, bool managerStatus);

    // Fired after the status for a user is updated
    event UserStatusUpdated(address user, bool status);

    /// @notice Sets status for a manager
    /// @param KYCManager The address of manager for which the status is to be updated
    /// @param managerStatus The status for the manager
    /// @return status of the transaction
    function setKYCManagerStatus(address KYCManager, bool managerStatus)
        public
        returns (bool);

    /// @notice Sets status for a user
    /// @param userAddress The address of user for which the status is to be updated
    /// @param passedKYC The status for the user
    /// @return status of the transaction
    function setUserAddressStatus(address userAddress, bool passedKYC)
        public
        returns (bool);

    /// @notice returns the status of a user
    /// @param userAddress The address of user for which the status is to be returned
    /// @return status of the user
    function getAddressStatus(address userAddress) public view returns (bool);

}

// File: contracts/ERC20/IERC20.sol

contract IERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner)
        public
        view
        returns (uint256 balance);
    function allowance(address tokenOwner, address spender)
        public
        view
        returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens)
        public
        returns (bool success);
    function transferFrom(address from, address to, uint256 tokens)
        public
        returns (bool success);
    function mint(address account, uint256 amount) public returns (bool);
    function burn(uint256 amount) public;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}

// File: contracts/Exchange/Exchange/IExchange.sol

/**
@title IExchange
@dev This contract represents an Interface to Exchange contract
 */
contract IExchange {
    /**
    @dev fired on allocationToken rate set
     */
    event AllocationTokenRateSet(uint256 rate);

    /**
    @dev fired on exchange state change
    */
    event StateChanged(uint256 state);

    /**
    @dev fired on exchange of tokenns
     */
    event TokensExchanged(
        uint256 _operationId,
        address userAddress,
        address erc20Token,
        address allocationToken,
        uint256 erc20Tokens,
        uint256 allocationTokens
    );

    /**
    @notice function exchanges chellecoin tokens to allocation tokens
    @param tokens the amount of chellecoin tokens to be exchanged for allocation tokens
     */
    function exchange(uint256 tokens) public returns (bool);

    /**
    @notice this function sets/changes state of this smart contract and only exchange manager/owner can call it
    @param state it can be either 0 (Inactive) or 1 (Active)
     */
    function setState(uint256 state) external;

    /**
    @dev it updates  update exchange rate of ERC-20 tokens to AT tokens
    @param  _allocationTokensPerErc20Token the exchange rate
    */
    function setExchangeRate(uint256 _allocationTokensPerErc20Token) external;

    /**
    @notice function to get the current state of the exchange contract
    @return current state
    */
    function getCurrentState() public view returns (uint256);

}

// File: contracts/Exchange/Exchange/Exchange.sol

/**
@notice Exchange smart contract for ChelleCoin to AllocationTokens
 */
contract Exchange is IExchange, Ownable {
    enum State {INACTIVE, ACTIVE}

    IERC20 public erc20Token; // address of ERC-20 token allowed to be exchanged.
    IAllocationToken public allocationToken; // address of Allocation Token Smart Contract.
    IKYC public kyc; // KYC contract

    uint256 public allocationTokensPerErc20Token; // exchange rate of ERC-20 tokens to AT tokens.

    State exchangeState; // current state of the exchange contract

    /**
    @dev constructor for the Exchange contract
    @param _erc20Token address of ERC-20 token allowed to be exchanged.
    @param _allocationToken address of Allocation Token Smart Contract.
    @param _allocationTokensPerErc20Token exchange rate of ERC-20 tokens to AT tokens.
     */
    constructor(
        IERC20 _erc20Token,
        IAllocationToken _allocationToken,
        IKYC _kyc,
        uint256 _allocationTokensPerErc20Token
    ) public {
        erc20Token = _erc20Token;
        allocationToken = _allocationToken;
        allocationTokensPerErc20Token = _allocationTokensPerErc20Token;
        kyc = _kyc;

        exchangeState = State.ACTIVE;

        emit AllocationTokenRateSet(allocationTokensPerErc20Token);
        emit StateChanged(uint256(exchangeState));
    }

    /**
    @notice call is only allowed to pass when exchange is in ACTIVE state
     */
    modifier isStateActive() {
        require(exchangeState == State.ACTIVE, "Exchange state is INACTIVE.");
        _;
    }

    /**
    @notice function exchanges chellecoin tokens to allocation tokens
    @param tokens the amount of chellecoin tokens to be exchanged for allocation tokens
     */
    function exchange(uint256 tokens) public isStateActive returns (bool) {
        require(tokens > 0, "tokens amount is not valid.");
        require(
            kyc.getAddressStatus(msg.sender),
            "msg.sender is not whiteliisted in KYC"
        );

        uint256 AT_tokens_to_mint = calculateAllocationTokens(tokens);

        require(
            erc20Token.transferFrom(msg.sender, address(0x0), tokens),
            "transferFrom failed."
        );
        allocationToken.mint(msg.sender, AT_tokens_to_mint);

        emit TokensExchanged(
            0,
            msg.sender,
            address(erc20Token),
            address(allocationToken),
            tokens,
            AT_tokens_to_mint
        );
    }

    /**
    @notice this function sets/changes state of this smart contract and only exchange manager/owner can call it
    @param state it can be either 0 (Inactive) or 1 (Active)
     */
    function setState(uint256 state) external onlyOwner {
        require(state == 0 || state == 1, "Provided state is invalid.");
        require(
            state != uint256(exchangeState),
            "Provided state is already set."
        );

        exchangeState = State(state);
        emit StateChanged(uint256(exchangeState));
    }

    /**
    @dev it updates  update exchange rate of ERC-20 tokens to AT tokens
    @param  _allocationTokensPerErc20Token the exchange rate
    */
    function setExchangeRate(uint256 _allocationTokensPerErc20Token)
        external
        onlyOwner
    {
        require(
            _allocationTokensPerErc20Token > 0,
            "_allocationTokensPerErc20Token should be greater than 0."
        );

        allocationTokensPerErc20Token = _allocationTokensPerErc20Token;
        emit AllocationTokenRateSet(allocationTokensPerErc20Token);
    }

    /**
    @notice function to get the current state of the exchange contract
    @return current state
    */
    function getCurrentState() public view returns (uint256) {
        return uint256(exchangeState);
    }

    /**
    @dev an internal function to calculate allocation rate
    @param tokens the amount of chellecoin tokens
     */
    function calculateAllocationTokens(uint256 tokens)
        internal
        view
        returns (uint256)
    {
        return tokens * allocationTokensPerErc20Token;
    }
}

// File: contracts/Exchange/ExchangeWithManualApproval/IExchangeWithManualApproval.sol

/**
@title IExchangeWithManualApproval
@dev This contract represents an Interface to ExchangeWithManualApproval contract
 */
contract IExchangeWithManualApproval {
    /**
    @notice fire when an approver's state is changed
     */
    event ApproverStateChanged(bool newState);

    /**
    @notice fired when an approval is requested
     */
    event ManualApprovalRequired(
        uint256 exchangeOperationId,
        uint256 tokensAmountToExchange
    );

    /**
    @notice fired when an exchange operation is approved
     */
    event ExchangeOperationApproved(uint256 exchangeOperationid, bool approved);

    /**
    @notice function is called to change the state of an approver
    @param approver the address of approver to which the state is changed
    @param newState the state of the approver
     */
    function changeApproverState(address approver, bool newState) external;

    function confirmExchangeOperation(
        uint256 exchangeOperationId,
        bool status,
        uint256 purchasedTokens,
        uint256 bountyTokens
    ) external;

    /**
    @notice get an exchange operation by its ID
    @param  exchangeOperationId the ID of exchange operation
    @return the address of receiver
    @return the amount of chelle tokens
    @return the amoount of AT tokens
    @return the state of this particular operation
     */
    function getExchangeOperationByID(uint256 exchangeOperationId)
        public
        view
        returns (address, uint256, uint256, uint8);
}

// File: contracts/Exchange/ExchangeWithManualApproval/ExchangeWithManualApproval.sol

/**
@notice Contract inherits the exchange contract and implements mannager functionality
 */
contract ExchangeWithManualApproval is IExchangeWithManualApproval, Exchange {
    mapping(address => bool) public approvers; // mapping is used to store managers addresses that are allowed to approve or decline exchange operation.

    uint256 public exchangeOperationsCount = 0; //number of exchange operations registered in contract.

    enum OperationState {PENDING, ACCEPTED, DISCARDED} // state of an operation

    struct ExchangeOperation {
        address receiver; // address who would be receiving the exchanged AT tokens
        uint256 chelleTokensAmount; // amount of chelle tokens that are up for exchange
        uint256 ATTokensAmount; // amount of AT tokens exchanged
        OperationState state; // state of the operation
    }

    mapping(uint256 => ExchangeOperation) exchangeOperations; // mapping is used to store exchange operation info.

    /**
    @notice constructor of the contract
     */
    constructor(
        IERC20 _erc20Token,
        IAllocationToken _allocationToken,
        IKYC _kyc,
        uint256 _allocationTokensPerErc20Token
    )
        public
        Exchange(
            _erc20Token,
            _allocationToken,
            _kyc,
            _allocationTokensPerErc20Token
        )
    {}

    /**
    @notice only approver should be able to pass this modifier
     */
    modifier onlyApprover() {
        require(
            approvers[msg.sender],
            "only an approver can call this function."
        );
        _;
    }

    /**
    @notice function is called to change the state of an approver
    @param approver the address of approver to which the state is changed
    @param newState the state of the approver
     */
    function changeApproverState(address approver, bool newState)
        external
        onlyOwner
    {
        require(approver != address(0), "approver address is not valid");
        require(
            approvers[approver] != newState,
            "the provided approver's state is already set"
        );

        approvers[approver] = newState;

        emit ApproverStateChanged(newState);
    }

    /**
    @notice function exchanges chellecoin tokens to allocation tokens
    @param tokens the amount of chellecoin tokens to be exchanged for allocation tokens
     */
    function exchange(uint256 tokens) public isStateActive returns (bool) {
        require(tokens > 0, "tokens amount is not valid.");
        require(
            kyc.getAddressStatus(msg.sender),
            "msg.sender is not whiteliisted in KYC"
        );

        require(
            erc20Token.transferFrom(msg.sender, address(this), tokens),
            "transferFrom failed"
        );

        ExchangeOperation memory new_op = ExchangeOperation(
            msg.sender,
            tokens,
            uint256(0),
            OperationState.PENDING
        );

        exchangeOperationsCount = exchangeOperationsCount + 1;

        exchangeOperations[exchangeOperationsCount] = new_op;

        emit ManualApprovalRequired(exchangeOperationsCount, tokens);
    }

    /**
    @notice fired when an exchange operation is approved
     */
    event ExchangeOperationApproved(uint256 exchangeOperationid, bool approved);

    function confirmExchangeOperation(
        uint256 exchangeOperationId,
        bool status,
        uint256 purchasedTokens,
        uint256 bountyTokens
    ) external onlyApprover {
        require(exchangeOperationId > 0, "operation Id is invalid");

        ExchangeOperation storage current_op = exchangeOperations[exchangeOperationId];
        require(
            current_op.state == OperationState.PENDING,
            "Operation is already completed"
        );

        uint256 tokens = current_op.chelleTokensAmount;
        address receiver = current_op.receiver;

        if (status) {
            uint256 AT_tokens_to_mint = calculateAllocationTokens(tokens);
            current_op.state = OperationState.ACCEPTED;
            current_op.ATTokensAmount = AT_tokens_to_mint;

            erc20Token.burn(tokens);
            allocationToken.mint(receiver, AT_tokens_to_mint);
        } else {
            current_op.state = OperationState.DISCARDED;

            require(
                erc20Token.transfer(receiver, tokens),
                "ERC20 transfer was not successfull"
            );
        }

        emit ExchangeOperationApproved(exchangeOperationId, status);
    }

    /**
    @notice get an exchange operation by its ID
    @param  exchangeOperationId the ID of exchange operation
    @return the address of receiver
    @return the amount of chelle tokens
    @return the amoount of AT tokens
    @return the state of this particular operation
     */
    function getExchangeOperationByID(uint256 exchangeOperationId)
        public
        view
        returns (address, uint256, uint256, uint8)
    {
        require(exchangeOperationId > 0, "operation Id is invalid");

        ExchangeOperation memory op = exchangeOperations[exchangeOperationId];

        return (
            op.receiver,
            op.chelleTokensAmount,
            op.ATTokensAmount,
            uint8(op.state)
        );
    }
}