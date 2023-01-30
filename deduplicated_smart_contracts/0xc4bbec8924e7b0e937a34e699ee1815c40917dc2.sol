// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract yGift is ERC721("yearn Gift NFT", "yGIFT") {
	using SafeERC20 for IERC20;
	using SafeMath for uint;

	struct Gift {
		address	token;
		uint amount;  // vested
		uint tipped;  // not vested
		uint start;
		uint duration;
		string name;
		string message;
		string url;
	}

	Gift[] public gifts;

	event GiftMinted(address indexed from, address indexed to, uint indexed tokenId, uint unlocksAt);
	event Tip(address indexed tipper, uint indexed tokenId, address token, uint amount, string message);
	event Collected(address indexed collector, uint indexed tokenId, address token, uint amount);

	/**
	 * @dev Mints a new Gift NFT and places it into the contract address for future collection
	 * _to: recipient of the gift
	 * _token: token address of the token to be gifted
	 * _amount: amount of _token to be gifted
	 * _name: name of the gift
	 * _msg: Tip message given by the original minter
	 * _url: URL link for the image attached to the nft
	 * _start: the amount of time the gift will be locked until the recipient can collect it   
	 * _duration: duration over which the amount linearly becomes available  *
	 *
	 * Emits a {Tip} event.
	 */
	function mint(
		address _to,
		address _token,
		uint _amount,
		string calldata _name,
		string calldata _msg,
		string calldata _url,
		uint _start,
		uint _duration)
	external {
		uint _id = gifts.length;
		gifts.push(Gift({
			token: _token,
			name: _name,
			message: _msg,
			url: _url,
			amount: _amount,
			tipped: 0,
			start: _start,
			duration: _duration
		}));
		_safeMint(_to, _id);
		IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
		emit GiftMinted(msg.sender, _to, _id, _start);
		emit Tip(msg.sender, _id, _token, _amount, _msg);
	}

	/**
	 * @dev Tip some tokens to Gift NFT 
	 * _tokenId: gift in which the function caller would like to tip
	 * _amount: amount of _token to be gifted
	 * _msg: Tip message given by the original minter
	 *
	 * Emits a {Tip} event.
	 */
	function tip(uint _tokenId, uint _amount, string calldata _msg) external {
		require(_tokenId < gifts.length, "yGift: Token ID does not exist.");
		Gift storage gift = gifts[_tokenId];
		gift.tipped = gift.tipped.add(_amount);
		IERC20(gift.token).safeTransferFrom(msg.sender, address(this), _amount);
		emit Tip(msg.sender, _tokenId, gift.token, _amount, _msg);
	}

	function min(uint a, uint b) internal pure returns (uint) {
		return a < b ? a : b;
	}

	/**
	 * @dev Returns the available amount of tokens based on vesting parametres
	 * _amount: amount of tokens in the gift
	 * _start: Time at which the cliff ends
	 * _duration: vesting period
	 */
	function available(uint _amount, uint _start, uint _duration) public view returns (uint) {
		if (_start > block.timestamp) return 0;
		if (_duration == 0) return _amount;
		return _amount * min(block.timestamp - _start, _duration) / _duration;
	}

	/**
	 * @dev Returns the maximum collectible amount of tokens for a given gift
	 * _tokenId: gift for which to calculate the collectibe amount
	 */
	function collectible(uint _tokenId) public view returns (uint) {
		Gift memory gift = gifts[_tokenId];
		return available(gift.amount, gift.start, gift.duration).add(gift.tipped);
	}

	/**
	 * @dev Allows the gift recipient to collect their tokens
	 * _tokenId: gift in which the function caller would like to tip
	 * _amount: amount of tokens the gift owner would like to collect
	 *
	 * requirement: caller must be the owner of the gift
	 */
	function collect(uint _tokenId, uint _amount) public {
		require(_isApprovedOrOwner(msg.sender, _tokenId), "yGift: You are not the NFT owner");
		
		Gift storage gift = gifts[_tokenId];
		
		require(block.timestamp >= gift.start, "yGift: Rewards still vesting");
		uint _vested = available(gift.amount, gift.start, gift.duration);
		uint _available = _vested.add(gift.tipped);
		_amount = min(_amount, _available);
		uint _tips = min(_amount, gift.tipped);
		gift.tipped = gift.tipped.sub(_tips);
		gift.amount = gift.amount.add(_tips).sub(_amount);

		IERC20(gift.token).safeTransfer(msg.sender, _amount);
		emit Collected(msg.sender, _tokenId, gift.token, _amount);
	}
}