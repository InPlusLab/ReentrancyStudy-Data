pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}




/**
 * @title KYC
 * @dev KYC contract handles the white list for ASTCrowdsale contract
 * Only accounts registered in KYC contract can buy AST token.
 * Admins can register account, and the reason why
 */
contract KYC is Ownable {
  // check the address is registered for token sale
  // first boolean is true if presale else false
  // second boolean is true if registered else false
  mapping (address => mapping (bool => bool)) public registeredAddress;

  // check the address is admin of kyc contract
  mapping (address => bool) public admin;

  event Registered(address indexed _addr);
  event Unregistered(address indexed _addr);
  event SetAdmin(address indexed _addr);

  /**
   * @dev check whether the address is registered for token sale or not.
   * @param _addr address
   * @param _isPresale bool Whether the address is registered to presale or mainsale
   */
  modifier onlyRegistered(address _addr, bool _isPresale) {
    require(registeredAddress[_addr][_isPresale]);
    _;
  }

  /**
   * @dev check whether the msg.sender is admin or not
   */
  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }

  function KYC() public {
    admin[msg.sender] = true;
  }

  /**
   * @dev set new admin as admin of KYC contract
   * @param _addr address The address to set as admin of KYC contract
   */
  function setAdmin(address _addr, bool _value)
    public
    onlyOwner
    returns (bool)
  {
    require(_addr != address(0));
    require(admin[_addr] == !_value);

    admin[_addr] = _value;

    SetAdmin(_addr);

    return true;
  }

  /**
   * @dev check the address is register
   * @param _addr address The address to check
   * @param _isPresale bool Whether the address is registered to presale or mainsale
   */
  function isRegistered(address _addr, bool _isPresale)
    public
    view
    returns (bool)
  {
    return registeredAddress[_addr][_isPresale];
  }

  /**
   * @dev register the address for token sale
   * @param _addr address The address to register for token sale
   * @param _isPresale bool Whether register to presale or mainsale
   */
  function register(address _addr, bool _isPresale)
    public
    onlyAdmin
  {
    require(_addr != address(0) && registeredAddress[_addr][_isPresale] == false);

    registeredAddress[_addr][_isPresale] = true;

    Registered(_addr);
  }

  /**
   * @dev register the addresses for token sale
   * @param _addrs address[] The addresses to register for token sale
   * @param _isPresale bool Whether register to presale or mainsale
   */
  function registerByList(address[] _addrs, bool _isPresale)
    public
    onlyAdmin
  {
    for(uint256 i = 0; i < _addrs.length; i++) {
      register(_addrs[i], _isPresale);
    }
  }

  /**
   * @dev unregister the registered address
   * @param _addr address The address to unregister for token sale
   * @param _isPresale bool Whether unregister to presale or mainsale
   */
  function unregister(address _addr, bool _isPresale)
    public
    onlyAdmin
    onlyRegistered(_addr, _isPresale)
  {
    registeredAddress[_addr][_isPresale] = false;

    Unregistered(_addr);
  }

  /**
   * @dev unregister the registered addresses
   * @param _addrs address[] The addresses to unregister for token sale
   * @param _isPresale bool Whether unregister to presale or mainsale
   */
  function unregisterByList(address[] _addrs, bool _isPresale)
    public
    onlyAdmin
  {
    for(uint256 i = 0; i < _addrs.length; i++) {
      unregister(_addrs[i], _isPresale);
    }
  }
}