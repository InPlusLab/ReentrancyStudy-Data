/**
 *Submitted for verification at Etherscan.io on 2020-11-28
*/

// File: contracts\ProposalData.sol

// SPDX-License-Identifier: BSD-2
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

struct ProposalData {
    address proxy;
    string codeName;
    bool emergency;
    address sourceLocation;
    uint256 sourceLocationId;
    address location;
    bool submitable;
    string methodSignature;
    string returnAbiParametersArray;
    bool isInternal;
    bool needsSender;
    string replaces;
    uint256 surveyEndBlock;
    address proposer;
    address getItemProposalWeightFunctionalityAddress;
    address dfoItemCollectionAddress;
    address emergencyTokenAddress;
    uint256 votesHardCap;
}

// File: contracts\interfaces\IMVDFunctionalityProposal.sol

// SPDX_License_Identifier: BSD-2
pragma solidity ^0.7.0;


interface IMVDFunctionalityProposal {

    function init(ProposalData calldata proposalData) external returns(address);

    function getProposalData() external view returns(ProposalData memory);
    function getVote(address addr) external view returns(uint256 accept, uint256 refuse);
    function getVotes() external view returns(uint256, uint256);
    function start() external;
    function disable() external;
    function isVotesHardCapReached() external view returns(bool);
    function isDisabled() external view returns(bool);
    function isTerminated() external view returns(bool);
    function batchRetireAccept(uint256[] calldata amounts, uint256[] calldata objectIds) external;
    function moveToAccept(uint256 amount, uint256 objectId) external;
    function batchRetireRefuse(uint256[] calldata amounts, uint256[] calldata objectIds) external;
    function moveToRefuse(uint256 amount, uint256 objectId) external;
    function retireAll(uint256[] calldata objectIds) external;
    function withdraw() external;
    function terminate() external;
    function set() external;

    event Accept(address indexed voter, uint256 amount);
    event RetireAccept(address indexed voter, uint256 amount);
    event MoveToAccept(address indexed voter, uint256 amount);
    event Refuse(address indexed voter, uint256 amount);
    event RetireRefuse(address indexed voter, uint256 amount);
    event MoveToRefuse(address indexed voter, uint256 amount);
    event RetireAll(address indexed voter, uint256 amount);
}

// File: contracts\interfaces\IERC1155Receiver.sol

// SPDX_License_Identifier: BSD-2
pragma solidity ^0.7.0;

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

// File: contracts\interfaces\IERC1155.sol

// SPDX_License_Identifier: BSD-2
pragma solidity ^0.7.0;


/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// File: contracts\MVDFunctionalityProposal.sol

// SPDX_License_Identifier: BSD-2
pragma solidity ^0.7.0;




contract MVDFunctionalityProposal is IMVDFunctionalityProposal, IERC1155Receiver {

    // Core proposal data as struct
    ProposalData private _proposalData;

    // Mapping for address => objectid => weighted accept votes
    mapping(address => mapping(uint256 => uint256)) private _accept;
    // Mapping for address => objectid => weighted refuse votes
    mapping(address => mapping(uint256 => uint256)) private _refuse;
    // Total number of accept and refuse votes
    uint256 private _totalAccept;
    uint256 private _totalRefuse;
    // If the address has withdrawed or not the given objectId
    mapping(address => mapping(uint256 => bool)) private _withdrawed;
    // Mapping for list of "used" objectId for a given address
    mapping(address => uint256[]) private _userObjectIds;
    // Check if the user has voted or not with the given objectId
    mapping(address => mapping(uint256 => bool)) private _hasVotedWith;

    // Proposal survey duration
    uint256 private _surveyDuration;
    // If the proposal is terminated
    bool private _terminated;
    // If the proposal is disabled
    bool private _disabled;
    // If the votes hard cap has been reached
    bool private _votesHardCapReached;

    constructor(ProposalData memory proposalData) {
        init(proposalData);
    }

    function init(ProposalData memory proposalData) public override returns(address) {
        require(_proposalData.proxy == address(0), "Already initialized!");
        require(proposalData.proxy != address(0), "Invalid proxy address");
        _proposalData = proposalData;
        //_surveyDuration = toUint256(IMVDProxy(_proposalData.proxy).read((_proposalData.emergency) ? "getMinimumBlockNumberForEmergencySurvey" : "getMinimumBlockNumberForSurvey", bytes("")));
        return address(this);
    }

    function start() public override {
        require(msg.sender == _proposalData.proxy, "Only Proxy can call this function!");
        require(_proposalData.surveyEndBlock == 0, "Already started!");
        require(!_disabled, "Already disabled!");
        _proposalData.surveyEndBlock = block.number + _surveyDuration;
    }

    function disable() public override {
        require(msg.sender == _proposalData.proxy, "Only Proxy can call this function!");
        require(_proposalData.surveyEndBlock == 0, "Already started!");
        _disabled = true;
        _terminated = true;
    }

    modifier duringSurvey() {
        require(!_disabled, "Survey disabled!");
        require(!_terminated, "Survey Terminated!");
        require(!_votesHardCapReached, "Votes Hard Cap reached!");
        require(_proposalData.surveyEndBlock > 0, "Survey Not Started!");
        require(block.number < _proposalData.surveyEndBlock, "Survey ended!");
        _;
    }

    modifier onSurveyEnd() {
        require(!_disabled, "Survey disabled!");
        require(_proposalData.surveyEndBlock > 0, "Survey Not Started!");
        if (!_votesHardCapReached) {
            require(block.number >= _proposalData.surveyEndBlock, "Survey is still running!");
        }
        _;
    }

    function _checkVotesHardCap() private {
        if (_proposalData.votesHardCap == 0 || (_totalAccept < _proposalData.votesHardCap && _totalRefuse < _proposalData.votesHardCap)) {
            return;
        }
        _votesHardCapReached = true;
        terminate();
    }

    /** @dev Allows a user to batch retire the given amounts of objectIds from the accept votes.
      * @param amounts array containing all the amounts.
      * @param objectIds array containing all the ETHItem object ids.
     */
    function batchRetireAccept(uint256[] memory amounts, uint256[] memory objectIds) public override duringSurvey {
        IGetItemProposalWeightFunctionality functionality = IGetItemProposalWeightFunctionality(_proposalData.getItemProposalWeightFunctionalityAddress);
        uint256[] memory weightedAmounts = new uint256[](amounts.length);
        for (uint256 i = 0; i < objectIds.length; i++) {
            uint256 tokenWeight = functionality.getItemProposalWeight(objectIds[i]);
            uint256 weightedAmount = amounts[i] * tokenWeight;
            require(_accept[msg.sender][objectIds[i]] >= weightedAmount, "Insufficient funds!");
            weightedAmounts[i] = weightedAmount;
        }
        IEthItemCollection(_proposalData.dfoItemCollectionAddress).safeBatchTransferFrom(address(this), msg.sender, amounts, objectIds, "");
        for (uint256 i = 0; i < objectIds.length; i++) {
            uint256 vote = _accept[msg.sender][objectIds[i]];
            vote -= weightedAmounts[i];
            _accept[msg.sender][objectIds[i]] = vote;
            _totalAccept -= weightedAmounts[i];
        }
    }

    /** @dev Allows a user to batch retire the given amounts of objectIds from the refuse votes.
      * @param amounts array containing all the amounts.
      * @param objectIds array containing all the ETHItem object ids.
     */
    function batchRetireRefuse(uint256[] memory amounts, uint256[] memory objectIds) public override duringSurvey {
        IGetItemProposalWeightFunctionality functionality = IGetItemProposalWeightFunctionality(_proposalData.getItemProposalWeightFunctionalityAddress);
        uint256[] memory weightedAmounts = new uint256[](amounts.length);
        for (uint256 i = 0; i < objectIds.length; i++) {
            uint256 tokenWeight = functionality.getItemProposalWeight(objectIds[i]);
            uint256 weightedAmount = amounts[i] * tokenWeight;
            require(_refuse[msg.sender][objectIds[i]] >= weightedAmount, "Insufficient funds!");
            weightedAmounts[i] = weightedAmount;
        }
        IEthItemCollection(_proposalData.dfoItemCollectionAddress).safeBatchTransferFrom(address(this), msg.sender, amounts, objectIds, "");
        // TODO batchSafeTransferFrom
        for (uint256 i = 0; i < objectIds.length; i++) {
            uint256 vote = _refuse[msg.sender][objectIds[i]];
            vote -= weightedAmounts[i];
            _refuse[msg.sender][objectIds[i]] = vote;
            _totalRefuse -= weightedAmounts[i];
        }
    }

    /** @dev Allows the sender to retire all the tokens used for voting in this proposal.
      * @param objectIds array containing all the ETHItem object ids.
     */
    function retireAll(uint256[] memory objectIds) public override duringSurvey {
        IGetItemProposalWeightFunctionality functionality = IGetItemProposalWeightFunctionality(_proposalData.getItemProposalWeightFunctionalityAddress);
        uint256 total = 0;
        uint256[] memory amounts = new uint256[](objectIds.length);
        for (uint256 i = 0; i < objectIds.length; i++) {
            require(_accept[msg.sender][objectIds[i]] + _refuse[msg.sender][objectIds[i]] > 0, "No votes for the object id!");
        }
        for (uint256 i = 0; i < objectIds.length; i++) {
            uint256 tokenWeight = functionality.getItemProposalWeight(objectIds[i]);
            if (tokenWeight > 0) {
                uint256 acpt = _accept[msg.sender][objectIds[i]];
                uint256 rfs = _refuse[msg.sender][objectIds[i]];
                uint256 wAcpt = acpt / tokenWeight;
                uint256 wRfs = rfs / tokenWeight;
                amounts[i] = wAcpt + wRfs;
                _accept[msg.sender][objectIds[i]] = 0;
                _refuse[msg.sender][objectIds[i]] = 0;
                _totalAccept -= acpt;
                _totalRefuse -= rfs;
                total += (acpt + rfs);
            } else {
                amounts[i] = 0;
            }
        }
        IEthItemCollection(_proposalData.dfoItemCollectionAddress).safeBatchTransferFrom(address(this), msg.sender, amounts, objectIds, "");
        // TODO safeBatchTransferFrom
        emit RetireAll(msg.sender, total);
    }

    /** @dev Moves the given amount of the token with the given object id to the accept count.
      * @param amount total amount of tokens to use for the vote.
      * @param objectId ETHItem ERC-1155 object id.
     */
    function moveToAccept(uint256 amount, uint256 objectId) public override duringSurvey {
        require(_refuse[msg.sender][objectId] >= amount, "Insufficient funds!");
        uint256 vote = _refuse[msg.sender][objectId];
        vote -= amount;
        _refuse[msg.sender][objectId] = vote;
        _totalRefuse -= amount;

        vote = _accept[msg.sender][objectId];
        vote += amount;
        _accept[msg.sender][objectId] = vote;
        _totalAccept += amount;
        emit MoveToAccept(msg.sender, amount);
        _checkVotesHardCap();
    }

    /** @dev Moves the given amount of the token with the given object id to the refuse count.
      * @param amount total amount of tokens to use for the vote.
      * @param objectId ETHItem ERC-1155 object id.
     */
    function moveToRefuse(uint256 amount, uint256 objectId) public override duringSurvey {
        require(_accept[msg.sender][objectId] >= amount, "Insufficient funds!");
        uint256 vote = _accept[msg.sender][objectId];
        vote -= amount;
        _accept[msg.sender][objectId] = vote;
        _totalAccept -= amount;

        vote = _refuse[msg.sender][objectId];
        vote += amount;
        _refuse[msg.sender][objectId] = vote;
        _totalRefuse += amount;
        emit MoveToRefuse(msg.sender, amount);
        _checkVotesHardCap();
    }

    /** @dev Allows the sender to withdraw all the tokens inside the proposal.
     */
    function withdraw() public override onSurveyEnd {
        // Check if the proposal is not terminated nor disabled
        if (!_terminated && !_disabled) {
            terminate();
            return;
        }
        // Withdraw all the tokens
        _withdraw(true);
    }

    /** @dev Allows the sender to terminate the proposal (only on survey end).
     */
    function terminate() public override onSurveyEnd {
        require(!_terminated, "Already terminated!");
        IMVDProxy(_proposalData.proxy).setProposal();
        _withdraw(false);
    }

    /** @dev Private function used for token withdrawal.
      * @param launchError ??
     */
    function _withdraw(bool launchError) private {
        IGetItemProposalWeightFunctionality functionality = IGetItemProposalWeightFunctionality(_proposalData.getItemProposalWeightFunctionalityAddress);
        uint256[] memory amounts = new uint256[](_userObjectIds[msg.sender].length);
        for (uint256 i = 0; i < _userObjectIds[msg.sender].length; i++) {
            require(!launchError || _accept[msg.sender][_userObjectIds[msg.sender][i]] + _refuse[msg.sender][_userObjectIds[msg.sender][i]] > 0, "Nothing to Withdraw!");
            require(!launchError || !_withdrawed[msg.sender][_userObjectIds[msg.sender][i]], "Already Withdrawed!");
            if (_accept[msg.sender][_userObjectIds[msg.sender][i]] + _refuse[msg.sender][_userObjectIds[msg.sender][i]] > 0 && !_withdrawed[msg.sender][_userObjectIds[msg.sender][i]]) {
                uint256 tokenWeight = functionality.getItemProposalWeight(_userObjectIds[msg.sender][i]);
                if (tokenWeight > 0) {
                    uint256 wAccept = _accept[msg.sender][_userObjectIds[msg.sender][i]] / tokenWeight;
                    uint256 wRefuse = _refuse[msg.sender][_userObjectIds[msg.sender][i]] / tokenWeight;
                    amounts[i] = wAccept + wRefuse;
                } else {
                    amounts[i] = 0;
                }
                _withdrawed[msg.sender][_userObjectIds[msg.sender][i]] = true;
            }
        }
        IEthItemCollection(_proposalData.dfoItemCollectionAddress).safeBatchTransferFrom(address(this), msg.sender, amounts, _userObjectIds[msg.sender], "");
    }

    /** @dev Allows the proxy to terminate this proposal.
     */
    function set() public override onSurveyEnd {
        require(msg.sender == _proposalData.proxy, "Unauthorized Access!");
        require(!_terminated, "Already terminated!");
        _terminated = true;
    }

    /** @dev Returns the proposal data struct.
      * @return proposal data struct.
      */
    function getProposalData() public override view returns(ProposalData memory) {
        return _proposalData;
    }

    /** @dev Returns all the votes for the given address. It calculates the values
      * by iterating on all the tokens that the address used.
      * @param addr address votes.
      * @return addrAccept accept amount of votes for the accept.
      * @return addrRefuse refuse amount of votes for the refuse.
     */
    function getVote(address addr) public override view returns(uint256 addrAccept, uint256 addrRefuse) {
        for (uint256 i = 0; i < _userObjectIds[addr].length; i++) {
            addrAccept += _accept[addr][_userObjectIds[addr][i]];
            addrRefuse += _refuse[addr][_userObjectIds[addr][i]];
        }
    }

    function getVotes() public override view returns(uint256, uint256) {
        return (_totalAccept, _totalRefuse);
    }

    function isTerminated() public override view returns(bool) {
        return _terminated;
    }

    function isDisabled() public override view returns(bool) {
        return _disabled;
    }

    function isVotesHardCapReached() public override view returns(bool) {
        return _votesHardCapReached;
    }

    function toUint256(bytes memory bs) public pure returns(uint256 x) {
        if (bs.length >= 32) {
            assembly {
                x := mload(add(bs, add(0x20, 0)))
            }
        }
    }

    /** @dev Function called after a ERC1155 has been received by this contract.
      * @return 0xf23a6e61.
      */
    function onERC1155Received(address operator, address from, uint256 objectId, uint256 amount, bytes memory data) public override returns(bytes4) {
        require(operator == _proposalData.dfoItemCollectionAddress, "Invalid operator");
        bool isAccept = _compareStrings(string(data), "accept");
        require(isAccept || _compareStrings(string(data), "refuse"), "Invalid type");
        IGetItemProposalWeightFunctionality functionality = IGetItemProposalWeightFunctionality(_proposalData.getItemProposalWeightFunctionalityAddress);
        uint256 tokenWeight = functionality.getItemProposalWeight(objectId);
        uint256 objectIdVotes = isAccept ? _accept[from][objectId] :  _refuse[from][objectId];
        uint256 weightedAmount = amount * tokenWeight;
        if (weightedAmount > 0) {
            if (!_hasVotedWith[from][objectId]) {
                _hasVotedWith[from][objectId] = true;
                _userObjectIds[from].push(objectId);
            }
            objectIdVotes += weightedAmount;
            isAccept ? _accept[from][objectId] = objectIdVotes : _refuse[from][objectId] = objectIdVotes;
            isAccept ? _totalAccept += weightedAmount : _totalRefuse += weightedAmount;
            if (isAccept) {
                emit Accept(from, weightedAmount);
            } else {
                emit Refuse(from, weightedAmount);
            }
            _checkVotesHardCap();
        }
        return 0xf23a6e61;
    }
    
    /** @dev Function called after a batch of ERC1155 has been received by this contract.
      * @return 0xbc197c81.
      */
    function onERC1155BatchReceived(address operator, address from, uint256[] memory objectIds, uint256[] memory amounts, bytes memory data) public override returns (bytes4) {
        require(operator == _proposalData.dfoItemCollectionAddress, "Invalid operator");
        bool isAccept = _compareStrings(string(data), "accept");
        require(isAccept || _compareStrings(string(data), "refuse"), "Invalid type");
        IGetItemProposalWeightFunctionality functionality = IGetItemProposalWeightFunctionality(_proposalData.getItemProposalWeightFunctionalityAddress);
        for (uint256 i = 0; i < objectIds.length; i++) {
            uint256 currentTokenVote = isAccept ? _accept[from][objectIds[i]] : _refuse[from][objectIds[i]];
            uint256 currentTokenWeight = functionality.getItemProposalWeight(objectIds[i]);
            uint256 currentTokenWeightedAmount = amounts[i] * currentTokenWeight;
            require(currentTokenWeightedAmount > 0, "Token weight must not be 0 in batch vote!");
            if (!_hasVotedWith[from][objectIds[i]]) {
                _hasVotedWith[from][objectIds[i]] = true;
                _userObjectIds[from].push(objectIds[i]);
            }
            currentTokenVote += currentTokenWeightedAmount;
            isAccept ? _accept[from][objectIds[i]] = currentTokenVote : _refuse[from][objectIds[i]] = currentTokenVote;
            isAccept ? _totalAccept += currentTokenWeightedAmount : _totalRefuse += currentTokenWeightedAmount;
        }
        _checkVotesHardCap();
        return 0xbc197c81;
    }

    function _compareStrings(string memory a, string memory b) private pure returns(bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}

interface IEthItemCollection {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

interface IGetItemProposalWeightFunctionality {
    function getItemProposalWeight(uint256 itemAddress) external returns (uint256);
}

interface IMVDProxy {
    function setProposal() external;
    function read(string calldata codeName, bytes calldata data) external view returns(bytes memory returnData);
    function getMVDFunctionalitiesManagerAddress() external view returns(address);
}