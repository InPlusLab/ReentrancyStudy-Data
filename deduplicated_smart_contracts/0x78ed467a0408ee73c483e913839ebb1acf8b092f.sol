/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity ^0.5.4;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

contract LandRegistry is Ownable {
  mapping(string => address) private landRegistry;

  event Tokenized(string eGrid, address indexed property);
  event Untokenized(string eGrid, address indexed property);

  /**
   * this function's abi should never change and always maintain backwards compatibility
   */
  function getProperty(string memory _eGrid) public view returns (address property) {
    property = landRegistry[_eGrid];
  }

  function tokenizeProperty(string memory _eGrid, address _property) public onlyOwner {
    require(bytes(_eGrid).length > 0, "eGrid must be non-empty string");
    require(_property != address(0), "property address must be non-null");
    require(landRegistry[_eGrid] == address(0), "property must not already exist in land registry");

    landRegistry[_eGrid] = _property;
    emit Tokenized(_eGrid, _property);
  }

  function untokenizeProperty(string memory _eGrid) public onlyOwner {
    address property = getProperty(_eGrid);
    require(property != address(0), "property must exist in land registry");

    landRegistry[_eGrid] = address(0);
    emit Untokenized(_eGrid, property);
  }
}