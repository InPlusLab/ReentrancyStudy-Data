/**
 *Submitted for verification at Etherscan.io on 2020-01-10
*/

pragma solidity 0.5.8;

interface ERC20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address who) external view returns (uint256);
	function transfer(address to, uint256 value) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function transferFrom(address from, address to, uint256 value) external returns (bool);
	function approve(address spender, uint256 value) external returns (bool);
}

contract ERC20HTLC {
	struct Swap {
		uint256 outAmount; //The ERC20 Pra amount to swap out
		uint256 expireHeight; //The height of blocks to wait before the asset can be returned to sender
		bytes32 randomNumberHash;
		uint64 timestamp;
		address senderAddr; //The swap creator address
		uint256 senderChainType;
		uint256 receiverChainType;
		address recipientAddr; //The ethereum address to lock swapped assets, counter-party of senderAddr
		string receiverAddr; //The PRA address (DID) to swap out
	}

	enum States {INVALID, OPEN, COMPLETED, EXPIRED}

	enum ChainTypes {ETH, PRA}

	// Events
	event HTLC(
		address indexed _msgSender,
		address indexed _recipientAddr,
		bytes32 indexed _swapID,
		bytes32 _randomNumberHash,
		uint64 _timestamp,
		uint256 _expireHeight,
		uint256 _outAmount,
		uint256 _praAmount,
		string _receiverAddr
	);
	event Claimed(
		address indexed _msgSender,
		address indexed _recipientAddr,
		bytes32 indexed _swapID,
		bytes32 _randomNumber,
		string _receiverAddr
	);
	event Refunded(
		address indexed _msgSender,
		address indexed _recipientAddr,
		bytes32 indexed _swapID,
		bytes32 _randomNumberHash,
		string _receiverAddr
	);

	// Storage, key: swapID
	mapping(bytes32 => Swap) private swaps;
	mapping(bytes32 => States) private swapStates;

	address public praContractAddr;
	address public owner;
	address public admin;

	// whether the contract is paused
    bool public paused = false;

	/// @notice Throws if the swap is not open.
	modifier onlyOpenSwaps(bytes32 _swapID) {
		require(swapStates[_swapID] == States.OPEN, "swap is not opened");
		_;
	}

	/// @notice Throws if the swap is already expired.
	modifier onlyAfterExpireHeight(bytes32 _swapID) {
		require(block.number >= swaps[_swapID].expireHeight, "swap is not expired");
		_;
	}

	/// @notice Throws if the expireHeight is reached
	modifier onlyBeforeExpireHeight(bytes32 _swapID) {
		require(block.number < swaps[_swapID].expireHeight, "swap is already expired");
		_;
	}

	/// @notice Throws if the random number is not valid.
	modifier onlyWithRandomNumber(bytes32 _swapID, bytes32 _randomNumber) {
		require(
			swaps[_swapID].randomNumberHash == sha256(abi.encodePacked(_randomNumber, swaps[_swapID].timestamp)),
			"invalid randomNumber"
		);
		_;
	}

	/// @param _praContract The PRA contract address
	constructor(address _praContract) public {
		praContractAddr = _praContract;
		owner = msg.sender;
	}

	/// @notice Throws if the msg.sender is not admin or owner.
	modifier onlyAdmin() {
		require(msg.sender == admin || msg.sender == owner);
		_;
	}

	/// @notice Modifier to allow actions only when the contract IS NOT paused
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	/// @notice Modifier to allow actions only when the contract IS paused
	modifier whenPaused {
		require(paused);
		_;
	}

	/// @notice to pause the contract.
	function pause() public onlyAdmin whenNotPaused {
		paused = true;
	}

	/// @notice to unpause the contract.
	function unpause() public onlyAdmin whenPaused {
		paused = false;
	}

	/// @notice setAdmin set new admin address.
	///
	/// @param _new_admin The new admin address.
	function setAdmin(address _new_admin) public onlyAdmin {
		require(_new_admin != address(0));
		admin = _new_admin;
	}

	/// @notice setPraAddress set new PRA-ERC20 contract address.
	///
	/// @param _praContract The new PRA-ERC20 contract address.
	function setPraAddress(address _praContract) public onlyAdmin {
		praContractAddr = _praContract;
	}

	// swap may only be built through the htlc function
	function() external payable { revert();	}

	//TODO: init set recipientAddr

	/// @notice htlt locks asset to contract address and create an atomic swap.
	///
	/// @param _randomNumberHash The hash of the random number and timestamp
	/// @param _timestamp Counted by second
	/// @param _heightSpan The number of blocks to wait before the asset can be returned to sender
	/// @param _recipientAddr The ethereum address to lock swapped assets.
	/// @param _outAmount PRA ERC20 asset to swap out, precision is 18
	/// @param _praAmount PRA asset to swap in, precision is 18
	/// @param _receiverAddr PRA DID to swap in.
	function htlc(
		bytes32 _randomNumberHash,
		uint64 _timestamp,
		uint256 _heightSpan,
		address _recipientAddr,
		uint256 _outAmount,
		uint256 _praAmount,
		string memory _receiverAddr
	) public whenNotPaused returns (bool) {
		bytes32 swapID = calSwapID(_randomNumberHash, _receiverAddr);
		require(swapStates[swapID] == States.INVALID, "swap is opened previously");
		// Assume average block time interval is 3 second
		// The heightSpan period should be more than 5 minutes and less than one week
		require(_heightSpan >= 60 && _heightSpan <= 60480, "_heightSpan should be in [60, 60480]");
		require(_recipientAddr != address(0), "_recipientAddr should not be zero");
		require(_outAmount >= 10000000, "_outAmount must be more than 0.1");
		require(
			_timestamp > now - 1800 && _timestamp < now + 900,
			"Timestamp can neither be 15 minutes ahead of the current time, nor 30 minutes later"
		);
		require(_outAmount == _praAmount, "_outAmount must be equal _praAmount");
		//TODO: check _receiverAddr is valid
		//TODO: check _recipientAddr's auth

		// Store the details of the swap.
		Swap memory swap = Swap({
			outAmount: _outAmount,
			expireHeight: _heightSpan + block.number,
			randomNumberHash: _randomNumberHash,
			timestamp: _timestamp,
			senderAddr: msg.sender,
			senderChainType: uint256(ChainTypes.ETH),
			receiverAddr: _receiverAddr,
			receiverChainType: uint256(ChainTypes.PRA),
			recipientAddr: _recipientAddr
		});

		swaps[swapID] = swap;
		swapStates[swapID] = States.OPEN;

		// Transfer pra token to the swap contract
		require(
			ERC20(praContractAddr).transferFrom(msg.sender, address(this), _outAmount),
			"failed to transfer client asset to swap contract"
		);

		// Emit initialization event
		emit HTLC(
			msg.sender,
			_recipientAddr,
			swapID,
			_randomNumberHash,
			_timestamp,
			swap.expireHeight,
			_outAmount,
			_praAmount,
			_receiverAddr
		);

		return true;
	}

	/// @notice claim claims the previously locked asset.
	///
	/// @param _swapID The hash of randomNumberHash, swap creator and swap recipient
	/// @param _randomNumber The random number
	function claim(bytes32 _swapID, bytes32 _randomNumber)
		external
		onlyOpenSwaps(_swapID)
		onlyBeforeExpireHeight(_swapID)
		onlyWithRandomNumber(_swapID, _randomNumber)
		whenNotPaused
		returns (bool)
	{
		// Complete the swap.
		swapStates[_swapID] = States.COMPLETED;

		address recipientAddr = swaps[_swapID].recipientAddr;
		string memory receiverAddr = swaps[_swapID].receiverAddr;
		//uint256 receiverChainType = swaps[_swapID].receiverChainType;
		//uint256 senderChainType = swaps[_swapID].senderChainType;
		uint256 outAmount = swaps[_swapID].outAmount;
		//bytes32 randomNumberHash = swaps[_swapID].randomNumberHash;

		// Pay erc20 token to recipient
		require(
			ERC20(praContractAddr).transfer(recipientAddr, outAmount),
			"Failed to transfer locked asset to recipient"
		);

		// delete closed swap
		delete swaps[_swapID];

		// Emit completion event
		emit Claimed(msg.sender, recipientAddr, _swapID, _randomNumber, receiverAddr);

		return true;
	}

	/// @notice refund refunds the previously locked asset.
	///
	/// @param _swapID The hash of randomNumberHash, swap creator and swap recipient
	function refund(bytes32 _swapID) external onlyOpenSwaps(_swapID) onlyAfterExpireHeight(_swapID) returns (bool) {
		// Expire the swap.
		swapStates[_swapID] = States.EXPIRED;

		address swapSender = swaps[_swapID].senderAddr;
		string memory receiverAddr = swaps[_swapID].receiverAddr;
		uint256 outAmount = swaps[_swapID].outAmount;
		bytes32 randomNumberHash = swaps[_swapID].randomNumberHash;
		address recipientAddr = swaps[_swapID].recipientAddr;

		// refund erc20 token to swap creator
		require(
			ERC20(praContractAddr).transfer(swapSender, outAmount),
			"Failed to transfer locked asset back to swap creator"
		);

		// delete closed swap
		delete swaps[_swapID];

		// Emit expire event
		emit Refunded(msg.sender, recipientAddr, _swapID, randomNumberHash, receiverAddr);

		return true;
	}

	/// @notice query an atomic swap by randomNumberHash
	///
	/// @param _swapID The hash of randomNumberHash, swap creator and swap recipient
	function queryOpenSwap(bytes32 _swapID)
		external
		view
		returns (
			bytes32 _randomNumberHash,
			uint64 _timestamp,
			uint256 _expireHeight,
			uint256 _outAmount,
			address _sender,
			address _recipient
		)
	{
		Swap memory swap = swaps[_swapID];
		return (
			swap.randomNumberHash,
			swap.timestamp,
			swap.expireHeight,
			swap.outAmount,
			swap.senderAddr,
			swap.recipientAddr
		);
	}

	/// @notice Checks whether a swap with specified swapID exist
	///
	/// @param _swapID The hash of randomNumberHash, swap creator and swap recipient
	function isSwapExist(bytes32 _swapID) external view returns (bool) {
		return (swapStates[_swapID] != States.INVALID);
	}

	/// @notice Checks whether a swap is refundable or not.
	///
	/// @param _swapID The hash of randomNumberHash, swap creator and swap recipient
	function refundable(bytes32 _swapID) external view returns (bool) {
		return (block.number >= swaps[_swapID].expireHeight && swapStates[_swapID] == States.OPEN);
	}

	/// @notice Checks whether a swap is claimable or not.
	///
	/// @param _swapID The hash of randomNumberHash, swap creator and swap recipient
	function claimable(bytes32 _swapID) external view returns (bool) {
		return (block.number < swaps[_swapID].expireHeight && swapStates[_swapID] == States.OPEN);
	}

	/// @notice Calculate the swapID from randomNumberHash and swapCreator
	///
	/// @param _randomNumberHash The hash of random number and timestamp.
	/// @param receiverAddr The PRA address (DID) to swap out
	function calSwapID(bytes32 _randomNumberHash, string memory receiverAddr) public pure returns (bytes32) {
		return sha256(abi.encodePacked(_randomNumberHash, receiverAddr));
	}
}