pragma solidity >= 0.6.12;
pragma experimental ABIEncoderV2;

import "./utils/AccessControl.sol";
import "./utils/Pausable.sol";
import "./utils/SafeMath.sol";
import "./utils/SafeCast.sol";
import "./interfaces/IDepositExecute.sol";
import "./interfaces/ILiquidityPool.sol";
import "./interfaces/IERCHandler.sol";
import "./interfaces/IGenericHandler.sol";

/**
    @title Facilitates deposits, creation and voting of deposit proposals, and deposit executions.
    @author ChainSafe Systems.
 */
contract Bridge is Pausable, AccessControl, SafeMath {
    using SafeCast for *;

    // Limit relayers number because proposal can fit only so much votes
    uint256 constant public MAX_RELAYERS = 200;

    uint8   public _chainID;
    uint8   public _relayerThreshold;
    uint128 public _baseFee;
    uint64  public _transferFeeMultiplier;
    uint64  public _exchangeFeeMultiplier;
    uint40  public _expiry;
    bool    public _whitelistEnabled = false;

    enum ProposalStatus {Inactive, Active, Passed, Executed, Cancelled}

    struct Proposal {
        ProposalStatus _status;
        uint200 _yesVotes;      // bitmap, 200 maximum votes
        uint8   _yesVotesTotal;
        uint40  _proposedBlock; // 1099511627775 maximum block
    }

    // destinationChainID => number of deposits
    mapping(uint8 => uint64) public _depositCounts;
    // resourceID => handler address
    mapping(bytes32 => address) public _resourceIDToHandlerAddress;
    // destinationChainID + depositNonce => dataHash => Proposal
    mapping(uint72 => mapping(bytes32 => Proposal)) private _proposals;
    // whitelistedAddress => access status
    mapping(address => bool) public _whitelist;

    event RelayerThresholdChanged(uint256 newThreshold);
    event RelayerAdded(address relayer);
    event RelayerRemoved(address relayer);
    event Deposit(
        uint8   destinationChainID,
        bytes32 resourceID,
        uint64  depositNonce
    );
    event ProposalEvent(
        uint8          originChainID,
        uint64         depositNonce,
        ProposalStatus status,
        bytes32 dataHash
    );
    event ProposalVote(
        uint8   originChainID,
        uint64  depositNonce,
        ProposalStatus status,
        bytes32 dataHash
    );
    event Stake(
        address staker,
        uint256 amount,
        address pool
    );

    event Unstake(
        address unstaker,
        uint256 amount,
        address pool
    );

    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");


    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    modifier onlyAdminOrRelayer() {
        _onlyAdminOrRelayer();
        _;
    }

    modifier onlyRelayers() {
        _onlyRelayers();
        _;
    }

    modifier isWhitelisted() {
        if(_whitelistEnabled){
            require(_whitelist[msg.sender]);
        }
        _;
    }

    modifier isWhitelistEnabled() {
        require(_whitelistEnabled);
        _;
    }

    receive() external payable {
    }

    function _onlyAdminOrRelayer() private view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(RELAYER_ROLE, msg.sender),
            "sender is not relayer or admin");
    }

    function _onlyAdmin() private view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "sender doesn't have admin role");
    }

    function _onlyRelayers() private view {
        require(hasRole(RELAYER_ROLE, msg.sender), "sender doesn't have relayer role");
    }

    function _relayerBit(address relayer) private view returns(uint) {
        return uint(1) << sub(AccessControl.getRoleMemberIndex(RELAYER_ROLE, relayer), 1);
    }

    function _hasVoted(Proposal memory proposal, address relayer) private view returns(bool) {
        return (_relayerBit(relayer) & uint(proposal._yesVotes)) > 0;
    }

    /**
        @notice Initializes Bridge, creates and grants {msg.sender} the admin role,
        creates and grants {initialRelayers} the relayer role.
        @param chainID ID of chain the Bridge contract exists on.
        @param initialRelayers Addresses that should be initially granted the relayer role.
        @param initialRelayerThreshold Number of votes needed for a deposit proposal to be considered passed.
     */
    constructor (uint8 chainID, address[] memory initialRelayers, uint256 initialRelayerThreshold, uint256 baseFee, uint256 expiry) public {
        _chainID = chainID;
        _relayerThreshold = initialRelayerThreshold.toUint8();
        _baseFee = baseFee.toUint128();
        _transferFeeMultiplier = 2;
        _exchangeFeeMultiplier = 11;
        _expiry = expiry.toUint40();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        uint256 initialRelayerCount = initialRelayers.length;
        for (uint256 i; i < initialRelayerCount; i++) {
            grantRole(RELAYER_ROLE, initialRelayers[i]);
        }
    }

    // ADDRESS WHITELIST HANDLERS
    /**
    * @dev Adds single address to _whitelist.
    * @param _beneficiary Address to be added to the _whitelist
    */
    function addToWhitelist(address _beneficiary) external onlyAdmin isWhitelistEnabled {
        _whitelist[_beneficiary] = true;
    }

    /**
    * @dev Adds list of addresses to _whitelist. Not overloaded due to limitations with truffle testing.
    * @param _beneficiaries Addresses to be added to the _whitelist
    */
    function addManyToWhitelist(address[] calldata _beneficiaries) external onlyAdmin isWhitelistEnabled {
        uint256 _length = _beneficiaries.length; 
        for (uint256 i = 0; i < _length; i++) {
        _whitelist[_beneficiaries[i]] = true;
        }
    }

    /**
    * @dev Removes single address from _whitelist.
    * @param _beneficiary Address to be removed to the _whitelist
    */
    function removeFromWhitelist(address _beneficiary) external onlyAdmin isWhitelistEnabled {
        _whitelist[_beneficiary] = false;
    }

    /**
    * @dev Disables whitelisting process.
    */
    function disableWhitelisting() external onlyAdmin {
        _whitelistEnabled = false;
    }

    /**
    * @dev Enables whitelisting process.
    */
    function enableWhitelisting() external onlyAdmin {
        _whitelistEnabled = true;
    }

    /**
        @notice Returns true if {relayer} has voted on {destNonce} {dataHash} proposal.
        @notice Naming left unchanged for backward compatibility.
        @param destNonce destinationChainID + depositNonce of the proposal.
        @param dataHash Hash of data to be provided when deposit proposal is executed.
        @param relayer Address to check.
     */
    function _hasVotedOnProposal(uint72 destNonce, bytes32 dataHash, address relayer) public view returns(bool) {
        return _hasVoted(_proposals[destNonce][dataHash], relayer);
    }

    /**
        @notice Returns true if {relayer} has the relayer role.
        @param relayer Address to check.
     */
    function isRelayer(address relayer) external view returns (bool) {
        return hasRole(RELAYER_ROLE, relayer);
    }

    /**
        @notice Removes admin role from {msg.sender} and grants it to {newAdmin}.
        @notice Only callable by an address that currently has the admin role.
        @param newAdmin Address that admin role will be granted to.
     */
    function renounceAdmin(address newAdmin) external onlyAdmin {
        require(msg.sender != newAdmin, 'Cannot renounce oneself');
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
        @notice Pauses deposits, proposal creation and voting, and deposit executions.
        @notice Only callable by an address that currently has the admin role.
     */
    function adminPauseTransfers() external onlyAdmin {
        _pause();
    }

    /**
        @notice Unpauses deposits, proposal creation and voting, and deposit executions.
        @notice Only callable by an address that currently has the admin role.
     */
    function adminUnpauseTransfers() external onlyAdmin {
        _unpause();
    }

    /**
        @notice Modifies the number of votes required for a proposal to be considered passed.
        @notice Only callable by an address that currently has the admin role.
        @param newThreshold Value {_relayerThreshold} will be changed to.
        @notice Emits {RelayerThresholdChanged} event.
     */
    function adminChangeRelayerThreshold(uint256 newThreshold) external onlyAdmin {
        _relayerThreshold = newThreshold.toUint8();
        emit RelayerThresholdChanged(newThreshold);
    }

    /**
        @notice Grants {relayerAddress} the relayer role.
        @notice Only callable by an address that currently has the admin role, which is
                checked in grantRole().
        @param relayerAddress Address of relayer to be added.
        @notice Emits {RelayerAdded} event.
     */
    function adminAddRelayer(address relayerAddress) external {
        require(!hasRole(RELAYER_ROLE, relayerAddress), "addr already has relayer role!");
        require(_totalRelayers() < MAX_RELAYERS, "relayers limit reached");
        grantRole(RELAYER_ROLE, relayerAddress);
        emit RelayerAdded(relayerAddress);
    }

    /**
        @notice Removes relayer role for {relayerAddress}.
        @notice Only callable by an address that currently has the admin role, which is
                checked in revokeRole().
        @param relayerAddress Address of relayer to be removed.
        @notice Emits {RelayerRemoved} event.
     */
    function adminRemoveRelayer(address relayerAddress) external {
        require(hasRole(RELAYER_ROLE, relayerAddress), "addr doesn't have relayer role!");
        revokeRole(RELAYER_ROLE, relayerAddress);
        emit RelayerRemoved(relayerAddress);
    }

    /**
        @notice Sets a new resource for handler contracts that use the IERCHandler interface,
        and maps the {handlerAddress} to {resourceID} in {_resourceIDToHandlerAddress}.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param resourceID ResourceID to be used when making deposits.
        @param tokenAddress Address of contract to be called when a deposit is made and a deposited is executed.
     */
    function adminSetResource(address handlerAddress, bytes32 resourceID, address tokenAddress) external onlyAdmin {
        _resourceIDToHandlerAddress[resourceID] = handlerAddress;
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setResource(resourceID, tokenAddress);
    }

    function adminSetOneSplitAddress(address handlerAddress, address contractAddress) external onlyAdmin {
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setOneSplitAddress(contractAddress);
    }

    /**
        @notice Creates new liquidity pool
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param tokenAddress Address of token for which pool needs to be created.
     */

    function adminSetLiquidityPool(
        string memory name, 
        string memory symbol,
        uint8 decimals,
        address handlerAddress,
        address tokenAddress,
        address lpAddress
    ) external onlyAdmin {
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setLiquidityPool(name, symbol, decimals, tokenAddress, lpAddress);
    }

    function adminSetLiquidityPoolOwner(address handlerAddress, address newOwner, address tokenAddress, address lpAddress) external onlyAdmin {
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setLiquidityPoolOwner(newOwner, tokenAddress, lpAddress);
    }

    /**
        @notice Sets a new resource for handler contracts that use the IGenericHandler interface,
        and maps the {handlerAddress} to {resourceID} in {_resourceIDToHandlerAddress}.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param resourceID ResourceID to be used when making deposits.
        @param contractAddress Address of contract to be called when a deposit is made and a deposited is executed.
     */
    function adminSetGenericResource(
        address handlerAddress,
        bytes32 resourceID,
        address contractAddress,
        bytes4 depositFunctionSig,
        uint256 depositFunctionDepositerOffset,
        bytes4 executeFunctionSig
    ) external onlyAdmin {
        _resourceIDToHandlerAddress[resourceID] = handlerAddress;
        IGenericHandler handler = IGenericHandler(handlerAddress);
        handler.setResource(resourceID, contractAddress, depositFunctionSig, depositFunctionDepositerOffset, executeFunctionSig);
    }

    /**
        @notice Sets a resource as burnable for handler contracts that use the IERCHandler interface.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param tokenAddress Address of contract to be called when a deposit is made and a deposited is executed.
     */
    function adminSetBurnable(address handlerAddress, address tokenAddress) external onlyAdmin {
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setBurnable(tokenAddress);
    }

    /**
        @notice Returns a proposal.
        @param originChainID Chain ID deposit originated from.
        @param depositNonce ID of proposal generated by proposal's origin Bridge contract.
        @param dataHash Hash of data to be provided when deposit proposal is executed.
        @return Proposal which consists of:
        - _dataHash Hash of data to be provided when deposit proposal is executed.
        - _yesVotes Number of votes in favor of proposal.
        - _noVotes Number of votes against proposal.
        - _status Current status of proposal.
     */
    function getProposal(uint8 originChainID, uint64 depositNonce, bytes32 dataHash) external view returns (Proposal memory) {
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint8(originChainID);
        return _proposals[nonceAndID][dataHash];
    }

    /**
        @notice Returns total relayers number.
        @notice Added for backwards compatibility.
     */
    function _totalRelayers() public view returns (uint) {
        return AccessControl.getRoleMemberCount(RELAYER_ROLE);
    }



    /**
        @notice Used to set deposit fee.
        @notice Only callable by admin.
        @param  baseFee Value {_baseFee} will be updated to.
        @param  transferFeeMultiplier Value {_transferFeeMultiplier} will be updated to.
        @param  exchangeFeeMultiplier Value {_exchangeFeeMultiplier} will be updated to.
     */
    function adminSetFee(uint256 baseFee, uint64 transferFeeMultiplier, uint64 exchangeFeeMultiplier) external onlyAdmin {
        _baseFee = baseFee.toUint128();
        _transferFeeMultiplier = transferFeeMultiplier;
        _exchangeFeeMultiplier = exchangeFeeMultiplier;
    }

    function getFee() public view returns (uint128, uint64, uint64) {
        return (_baseFee, _transferFeeMultiplier, _exchangeFeeMultiplier);
    }


    /**
        @notice Used to manually withdraw funds from ERC safes.
        @param handlerAddress Address of handler to withdraw from.
        @param tokenAddress Address of token to withdraw.
        @param recipient Address to withdraw tokens to.
        @param amountOrTokenID Either the amount of ERC20 tokens or the ERC721 token ID to withdraw.
     */
    function adminWithdraw(
        address handlerAddress,
        address tokenAddress,
        address recipient,
        uint256 amountOrTokenID
    ) external onlyAdmin {
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.withdraw(tokenAddress, recipient, amountOrTokenID);
    }

    /**
        @notice Initiates a transfer using a specified handler contract.
        @notice Only callable when Bridge is not paused.
        @param destinationChainID ID of chain deposit will be bridged to.
        @param resourceID ResourceID used to find address of handler to be used for deposit.
        @param data Additional data to be passed to specified handler.
        @notice Emits {Deposit} event.
     */
        
    function deposit(
        uint8 destinationChainID, 
        bytes32 resourceID, 
        bytes calldata data, 
        uint256[] memory distribution, 
        uint256[] memory flags,
        address[] memory path
    ) external payable whenNotPaused isWhitelisted {
        IDepositExecute.SwapInfo memory swapDetails;

        swapDetails.distribution = distribution;
        swapDetails.flags = flags;
        swapDetails.path = path;
        swapDetails.providedFee = msg.value;
        swapDetails.baseFee = _baseFee;
        swapDetails.transferFeeMultiplier = _transferFeeMultiplier;
        swapDetails.exchangeFeeMultiplier = _exchangeFeeMultiplier;

        swapDetails.handler = _resourceIDToHandlerAddress[resourceID];
        require(swapDetails.handler != address(0), "resourceID not mapped to handler");

        swapDetails.depositNonce = ++_depositCounts[destinationChainID];

        IDepositExecute depositHandler = IDepositExecute(swapDetails.handler);
        address(uint160(swapDetails.handler)).transfer(msg.value);
        depositHandler.deposit(
            resourceID,
            destinationChainID,
            swapDetails.depositNonce,
            msg.sender,
            data,
            swapDetails
        );

        emit Deposit(destinationChainID, resourceID, swapDetails.depositNonce);
    }

    /**
        @notice Allows unstaking from liquidity pools.
        @notice Only callable when Bridge is not paused.
        @param handler Address of handler in which pool is deployed.
        @param tokenAddress Asset which needs to be staked.
        @param amount Amount that needs to be staked.
        @notice Emits {Stake} event.
     */
    function stake(address handler, address tokenAddress, uint256 amount) external payable whenNotPaused {
        ILiquidityPool depositHandler = ILiquidityPool(handler);
        IERCHandler ercHandler = IERCHandler(handler);

        if(tokenAddress == ercHandler.getWETHAddress()) {
            address(uint160(handler)).transfer(amount);
        }
        depositHandler.stake(msg.sender, tokenAddress, amount);
        emit Stake(msg.sender, amount, tokenAddress);
    }

    /**
        @notice Allows unstaking from liquidity pools.
        @notice Only callable when Bridge is not paused.
        @param handler Address of handler in which pool is deployed.
        @param tokenAddress Asset which needs to be unstaked.
        @param amount Amount that needs to be unstaked.
        @notice Emits {Unstake} event.
     */
    function unstake(address handler, address tokenAddress, uint256 amount) external whenNotPaused {
        ILiquidityPool depositHandler = ILiquidityPool(handler);
        depositHandler.unstake(msg.sender, tokenAddress, amount);
        emit Unstake(msg.sender, amount, tokenAddress);
    }

    /**
        @notice When called, {msg.sender} will be marked as voting in favor of proposal.
        @notice Only callable by relayers when Bridge is not paused.
        @param chainID ID of chain deposit originated from.
        @param depositNonce ID of deposited generated by origin Bridge contract.
        @param dataHash Hash of data provided when deposit was made.
        @notice Proposal must not have already been passed or executed.
        @notice {msg.sender} must not have already voted on proposal.
        @notice Emits {ProposalEvent} event with status indicating the proposal status.
        @notice Emits {ProposalVote} event.
     */
    function voteProposal(uint8 chainID, uint64 depositNonce, bytes32 resourceID, bytes32 dataHash) external onlyRelayers whenNotPaused {

        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint8(chainID);
        Proposal memory proposal = _proposals[nonceAndID][dataHash];

        require(_resourceIDToHandlerAddress[resourceID] != address(0), "no handler for resourceID");
        require(uint(proposal._status) <= 1, "proposal already passed/executed/cancelled");
        require(!_hasVoted(proposal, msg.sender), "relayer already voted");

        if (proposal._status == ProposalStatus.Inactive) {
            proposal = Proposal({
                _status : ProposalStatus.Active,
                _yesVotes : 0,
                _yesVotesTotal : 0,
                _proposedBlock : uint40(block.number) // Overflow is desired.
            });

            emit ProposalEvent(chainID, depositNonce, ProposalStatus.Active, dataHash);
        } else if (uint40(sub(block.number, proposal._proposedBlock)) > _expiry) {
            // if the number of blocks that has passed since this proposal was
            // submitted exceeds the expiry threshold set, cancel the proposal
            proposal._status = ProposalStatus.Cancelled;

            emit ProposalEvent(chainID, depositNonce, ProposalStatus.Cancelled, dataHash);
        }

        if (proposal._status != ProposalStatus.Cancelled) {
            proposal._yesVotes = (proposal._yesVotes | _relayerBit(msg.sender)).toUint200();
            proposal._yesVotesTotal++; // TODO: check if bit counting is cheaper.

            emit ProposalVote(chainID, depositNonce, proposal._status, dataHash);

            // Finalize if _relayerThreshold has been reached
            if (proposal._yesVotesTotal >= _relayerThreshold) {
                proposal._status = ProposalStatus.Passed;

                emit ProposalEvent(chainID, depositNonce, ProposalStatus.Passed, dataHash);
            }
        }
        _proposals[nonceAndID][dataHash] = proposal;
    }

    /**
        @notice Cancels a deposit proposal that has not been executed yet.
        @notice Only callable by relayers when Bridge is not paused.
        @param chainID ID of chain deposit originated from.
        @param depositNonce ID of deposited generated by origin Bridge contract.
        @param dataHash Hash of data originally provided when deposit was made.
        @notice Proposal must be past expiry threshold.
        @notice Emits {ProposalEvent} event with status {Cancelled}.
     */
    function cancelProposal(uint8 chainID, uint64 depositNonce, bytes32 dataHash) public onlyAdminOrRelayer {
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint8(chainID);
        Proposal memory proposal = _proposals[nonceAndID][dataHash];
        ProposalStatus currentStatus = proposal._status;

        require(currentStatus == ProposalStatus.Active || currentStatus == ProposalStatus.Passed,
            "Proposal cannot be cancelled");
        require(uint40(sub(block.number, proposal._proposedBlock)) > _expiry, "Proposal not at expiry threshold");

        proposal._status = ProposalStatus.Cancelled;
        _proposals[nonceAndID][dataHash] = proposal;

        emit ProposalEvent(chainID, depositNonce, ProposalStatus.Cancelled, dataHash);
    }

    /**
        @notice Executes a deposit proposal that is considered passed using a specified handler contract.
        @notice Only callable by relayers when Bridge is not paused.
        @param chainID ID of chain deposit originated from.
        @param resourceID ResourceID to be used when making deposits.
        @param depositNonce ID of deposited generated by origin Bridge contract.
        @param data Data originally provided when deposit was made.
        @notice Proposal must have Passed status.
        @notice Hash of {data} must equal proposal's {dataHash}.
        @notice Emits {ProposalEvent} event with status {Executed}.
     */
    function executeProposal(
        uint8 chainID, 
        uint64 depositNonce, 
        bytes calldata data, 
        bytes32 resourceID, 
        uint256[] memory distribution, 
        uint256[] memory flags,
        address[] memory path
    ) external onlyRelayers whenNotPaused {
        IDepositExecute.SwapInfo memory swapDetails;
        swapDetails.distribution = distribution;
        swapDetails.flags = flags;
        swapDetails.path = path;

        address handler = _resourceIDToHandlerAddress[resourceID];
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint8(chainID);
        bytes32 dataHash = keccak256(abi.encodePacked(handler, data));
        Proposal storage proposal = _proposals[nonceAndID][dataHash];

        require(proposal._status == ProposalStatus.Passed, "Proposal must have Passed status");

        require(uint40(sub(block.number, proposal._proposedBlock)) <= _expiry, "Proposal is not within expiry threshold");
        proposal._status = ProposalStatus.Executed;

        IDepositExecute depositHandler = IDepositExecute(handler);
        depositHandler.executeProposal(resourceID, data, swapDetails);

        emit ProposalEvent(chainID, depositNonce, ProposalStatus.Executed, dataHash);
    }

    /**
        @notice Transfers eth in the contract to the specified addresses. The parameters addrs and amounts are mapped 1-1.
        This means that the address at index 0 for addrs will receive the amount (in WEI) from amounts at index 0.
        @param addrs Array of addresses to transfer {amounts} to.
        @param amounts Array of amonuts to transfer to {addrs}.
     */
    function transferFunds(address payable[] calldata addrs, uint[] calldata amounts) external onlyAdmin {
        require(addrs.length == amounts.length, "addrs and amounts len mismatch");
        uint256 addrCount = addrs.length;
        for (uint256 i = 0; i < addrCount; i++) {
            addrs[i].transfer(amounts[i]);
        }
    }

}

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
    @title Interface for handler contracts that support deposits and deposit executions.
    @author ChainSafe Systems.
 */
interface IDepositExecute {

    struct SwapInfo {
        uint64 transferFeeMultiplier;
        uint64 exchangeFeeMultiplier;
        uint128 baseFee;
        uint256 providedFee;

        uint64  depositNonce;
        uint    index;
        uint256 returnAmount;
        bytes   recipient;

        address stableTokenAddress;
        address handler;

        uint256        srcTokenAmount;
        uint256        srcStableTokenAmount;
        uint256        destStableTokenAmount;
        uint256        destTokenAmount;

        uint256        lenRecipientAddress;
        uint256        lenSrcTokenAddress;
        uint256        lenDestTokenAddress;
        uint256        lenDestStableTokenAddress;

        bytes20        srcTokenAddress;
        address        srcStableTokenAddress;
        bytes20        destTokenAddress;
        address        destStableTokenAddress;


        uint256[] distribution;
        uint256[] flags;
        address[] path;

    }
    /**
        @notice It is intended that deposit are made using the Bridge contract.
        @param destinationChainID Chain ID deposit is expected to be bridged to.
        @param depositNonce This value is generated as an ID by the Bridge contract.
        @param depositer Address of account making the deposit in the Bridge contract.
        @param data Consists of additional data needed for a specific deposit.
        @param swapDetails Swap details

     */
    function deposit(
        bytes32 resourceID,
        uint8 destinationChainID,
        uint64 depositNonce,
        address depositer,
        bytes calldata data,
        SwapInfo calldata swapDetails
    ) external;

    /**
        @notice It is intended that proposals are executed by the Bridge contract.
        @param data Consists of additional data needed for a specific deposit execution.
     */
    function executeProposal(
        bytes32 resourceID, 
        bytes calldata data, 
        SwapInfo calldata swapDetails
    ) external;
}

pragma solidity >= 0.6.12;

/**
    @title Interface to be used with handlers that support ERC20s and ERC721s.
    @author ChainSafe Systems.
 */
interface IERCHandler {

    function getWETHAddress() external view  returns (address);

    /**
        @notice Correlates {resourceID} with {contractAddress}.
        @param resourceID ResourceID to be used when making deposits.
        @param contractAddress Address of contract to be called when a deposit is made and a deposited is executed.
     */
    function setResource(bytes32 resourceID, address contractAddress) external;

    /**
        @notice Sets oneSplitAddress for the handler
        @param contractAddress Address of oneSplit contract
     */
    function setOneSplitAddress(address contractAddress) external;

    /**
        @notice Correlates {resourceID} with {contractAddress}.
        @param contractAddress Address of contract for qhich liquidity pool needs to be created.
     */
    function setLiquidityPool(string memory name, string memory symbol, uint8 decimals, address contractAddress, address lpAddress) external;

    function setLiquidityPoolOwner(address newOwner, address tokenAddress, address lpAddress) external;


    /**
        @notice Marks {contractAddress} as mintable/burnable.
        @param contractAddress Address of contract to be used when making or executing deposits.
     */
    function setBurnable(address contractAddress) external;
    /**
        @notice Used to manually release funds from ERC safes.
        @param tokenAddress Address of token contract to release.
        @param recipient Address to release tokens to.
        @param amountOrTokenID Either the amount of ERC20 tokens or the ERC721 token ID to release.
     */
    function withdraw(address tokenAddress, address recipient, uint256 amountOrTokenID) external;


}

pragma solidity 0.6.12;

/**
    @title Interface for handler that handles generic deposits and deposit executions.
    @author ChainSafe Systems.
 */
interface IGenericHandler {
    /**
        @notice Correlates {resourceID} with {contractAddress}, {depositFunctionSig}, and {executeFunctionSig}.
        @param resourceID ResourceID to be used when making deposits.
        @param contractAddress Address of contract to be called when a deposit is made and a deposited is executed.
        @param depositFunctionSig Function signature of method to be called in {contractAddress} when a deposit is made.
        @param depositFunctionDepositerOffset Depositer address position offset in the metadata, in bytes.
        @param executeFunctionSig Function signature of method to be called in {contractAddress} when a deposit is executed.
     */
    function setResource(
        bytes32 resourceID,
        address contractAddress,
        bytes4 depositFunctionSig,
        uint depositFunctionDepositerOffset,
        bytes4 executeFunctionSig) external;
}

pragma solidity >= 0.6.12;

/**
    @title Interface for handler contracts that support deposits and deposit executions.
    @author ChainSafe Systems.
 */
interface ILiquidityPool {
    /**
        @notice Staking should be done by using bridge contract.
        @param depositor stakes liquidity in the pool .
        @param tokenAddress staking token for which liquidity needs to be added.
        @param amount Amount that needs to be staked.
     */
    function stake(address depositor, address tokenAddress, uint256 amount) external;
    /**
        @notice Staking should be done by using bridge contract.
        @param unstaker removes liquidity from the pool.
        @param tokenAddress staking token of which liquidity needs to be removed.
        @param amount Amount that needs to be unstaked.
     */
    function unstake(address unstaker, address tokenAddress, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

// This is adapted from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/access/AccessControl.sol
// The only difference is added getRoleMemberIndex(bytes32 role, address account) function.

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/GSN/Context.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms.
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
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    /**
     * @dev Returns the index of the account that have `role`.
     */
    function getRoleMemberIndex(bytes32 role, address account) public view returns (uint256) {
        return _roles[role].members._inner._indexes[bytes32(uint256(account))];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
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
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

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
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

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
    function renounceRole(bytes32 role, address account) public virtual {
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
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This is a stripped down version of Open zeppelin's Pausable contract.
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol
 *
 */
contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _whenNotPaused();
        _;
    }

    function _whenNotPaused() private view {
        require(!_paused, "Pausable: paused");
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenPaused() {
        _whenPaused();
        _;
    }

    function _whenPaused() private view {
        require(_paused, "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


library SafeCast {
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value < 2**200, "value does not fit in 200 bits");
        return uint200(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "value does not fit in 128 bits");
        return uint128(value);
    }

    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value < 2**40, "value does not fit in 40 bits");
        return uint40(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "value does not fit in 8 bits");
        return uint8(value);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * note that this is a stripped down version of open zeppelin's safemath
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
 */

contract SafeMath {

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
        return _sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function _sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

{
  "remappings": [],
  "optimizer": {
    "enabled": true,
    "runs": 1000000
  },
  "evmVersion": "istanbul",
  "libraries": {},
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  }
}