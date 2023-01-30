/**
 *Submitted for verification at Etherscan.io on 2020-04-29
*/

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
* Logic: Permitetd addresses can write to this contract types of converted tokens
*
* Motivation:
* Due fact tokens can be different like Uniswap/Bancor pool, Synthetix, Compound ect
* we need a certain method for convert a certain token.
* so we mark type for new token once after success convert
*/



contract TokensTypeStorage is Ownable {
  // check if token alredy registred
  mapping(address => bool) public isRegistred;
  // tokens types
  mapping(address => bytes32) public getType;
  // addresses which can write to this contract
  mapping(address => bool) public isPermittedAddress;

  // all available types
  string[] public allTypes;

  modifier onlyPermitted() {
    require(isPermittedAddress[msg.sender], "Sender not have permition for edit this contract");
    _;
  }

  // allow add new token type from trade portals
  function addNewTokenType(address _token, string _type) public onlyPermitted {
    // Don't add if alredy registred
    if(isRegistred[_token])
      return;

    // Add
    getType[_token] = stringToBytes32(_type);
    isRegistred[_token] = true;
    allTypes.push(_type);
  }


  // allow update token type from owner wallet
  function setTokenTypeAsOwner(address _token, string _type) public onlyOwner{
    // get previos type
    bytes32 prevType = getType[_token];

    // Update type
    getType[_token] = stringToBytes32(_type);
    isRegistred[_token] = true;

    // if new type unique add it to the list
    if(stringToBytes32(_type) != prevType)
       allTypes.push(_type);
  }

  function addNewPermittedAddress(address _permitted) public onlyOwner {
    isPermittedAddress[_permitted] = true;
  }

  function removePermittedAddress(address _permitted) public onlyOwner {
    isPermittedAddress[_permitted] = false;
  }

  // helper for convert dynamic string size to fixed bytes32 size
  function stringToBytes32(string memory source) private pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
   }
}