/**
 *Submitted for verification at Etherscan.io on 2019-10-13
*/

pragma solidity ^0.5.0;

interface Poap
{
	function tokenEvent(uint256 tokenId) external view returns (uint256);
}

library Set
{
	struct set
	{
		uint256[] members;
		mapping(uint256 => uint256) indexes;
	}

	function length(set storage _list)
	internal view returns (uint256)
	{
		return _list.members.length;
	}

	function at(set storage _list, uint256 _index)
	internal view returns (uint256)
	{
		return _list.members[_index - 1];
	}

	function indexOf(set storage _list, uint256 _value)
	internal view returns (uint256)
	{
		return _list.indexes[_value];
	}

	function contains(set storage _list, uint256 _value)
	internal view returns (bool)
	{
		return indexOf(_list, _value) != 0;
	}

	function content(set storage _list)
	internal view returns (uint256[] memory)
	{
		return _list.members;
	}

	function add(set storage _list, uint256 _value)
	internal returns (bool)
	{
		if (contains(_list, _value))
		{
			return false;
		}
		_list.indexes[_value] = _list.members.push(_value);
		return true;
	}

	function remove(set storage _list, uint256 _value)
	internal returns (bool)
	{
		if (!contains(_list, _value))
		{
			return false;
		}

		uint256 i    = indexOf(_list, _value);
		uint256 last = length(_list);

		if (i != last)
		{
			uint256 swapValue = _list.members[last - 1];
			_list.members[i - 1] = swapValue;
			_list.indexes[swapValue] = i;
		}

		delete _list.indexes[_value];
		--_list.members.length;

		return true;
	}
}

contract PoapIndex
{
	using Set for Set.set;

	// Poap token address
	Poap public poap;

	// event to tokens
	mapping(uint256 => Set.set) private m_tokensEvent;

	event TokenAdded(uint256 indexed tokenId, uint256 indexed eventId);

	constructor(Poap _poap)
	public
	{
		poap = _poap;
	}

	function addToken(uint256 _tokenId) external
	{
		_addToken(_tokenId);
	}

	function addTokens(uint256[] calldata _tokenIds) external
	{
		for (uint256 i = 0; i < _tokenIds.length; ++i)
		{
			_addToken(_tokenIds[i]);
		}
	}

	function _addToken(uint256 _tokenId) internal
	{
		uint256 eventId = poap.tokenEvent(_tokenId);
		if (eventId != 0 && m_tokensEvent[eventId].add(_tokenId))
		{
			emit TokenAdded(_tokenId, eventId);
		}
	}

	function viewTokens(uint256 _eventId) external view returns (uint256[] memory)
	{
		return m_tokensEvent[_eventId].content();
	}
}