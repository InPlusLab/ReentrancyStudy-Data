/**
 *Submitted for verification at Etherscan.io on 2019-12-03
*/

// File: contracts\CreativesStorage.sol

pragma solidity ^0.4.21;

contract CreativesStorage {

	uint public constant ROLE_BIDDER = 1;
	uint public constant ROLE_ADVERTISER = 2;
	uint public constant ROLE_PUBLISHER = 3;
	uint public constant ROLE_VOTER = 4;

	address public CONTRACT_MEMBERS;
	address public CONTRACT_TOKEN;
	address public VOTER_POOL;

	uint public INITIAL_THRESHOLD = 50;
	uint public THRESHOLD_STEP = 10;
	uint public BLOCK_DEPOSIT = 10000000000000000; //0.01 ADT
	uint public MAJORITY = 666; // 0.666 considered as supermajority

	mapping (address => address) creativeOwner;
	mapping (address => address[]) creatives;
	mapping (address => uint) threshold;
	mapping (address => bool) blocked;
}

// File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol

pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: contracts\CreativesRegistry.sol

pragma solidity ^0.4.21;



contract CreativesRegistry is CreativesStorage, Ownable {

	address private CONTRACT_ADDRESS;

	function setContractAddress(address newContractAddress) public onlyOwner {
		CONTRACT_ADDRESS = newContractAddress;
	}

	function () payable public {
		address target = CONTRACT_ADDRESS;
		assembly {
			// Copy the data sent to the memory address starting free mem position
			let ptr := mload(0x40)
			calldatacopy(ptr, 0, calldatasize)
			// Proxy the call to the contract address with the provided gas and data
			let result := delegatecall(gas, target, ptr, calldatasize, 0, 0)
			// Copy the data returned by the proxied call to memory
			let size := returndatasize
			returndatacopy(ptr, 0, size)
			// Check what the result is, return and revert accordingly
			switch result
			case 0 { revert(ptr, size) }
			case 1 { return(ptr, size) }
		}
	}
}