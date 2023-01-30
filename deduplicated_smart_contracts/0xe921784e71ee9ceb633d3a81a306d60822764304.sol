/**
 *Submitted for verification at Etherscan.io on 2019-09-24
*/

pragma solidity ^0.4.24;



/**
 * @title ERC20 interface 
 * 
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

 

/**
 * @title OwnableWithAdmin 
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract OwnableWithAdmin {
  address public owner;
  address public adminOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
    adminOwner = msg.sender;
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Throws if called by any account other than the admin.
   */
  modifier onlyAdmin() {
    require(msg.sender == adminOwner);
    _;
  }

  /**
   * @dev Throws if called by any account other than the owner or admin.
   */
  modifier onlyOwnerOrAdmin() {
    require(msg.sender == adminOwner || msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current adminOwner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferAdminOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(adminOwner, newOwner);
    adminOwner = newOwner;
  }

}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
      // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
      // benefit is lost if 'b' is also tested.
      // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
      if (a == 0) {
          return 0;
      }

      uint256 c = a * b;
      require(c / a == b);

      return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // Solidity only automatically asserts when dividing by 0
      require(b > 0);
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold

      return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b <= a);
      uint256 c = a - b;

      return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c >= a);

      return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b != 0);
      return a % b;
  }
 

  function uint2str(uint i) internal pure returns (string){
      if (i == 0) return "0";
      uint j = i;
      uint length;
      while (j != 0){
          length++;
          j /= 10;
      }
      bytes memory bstr = new bytes(length);
      uint k = length - 1;
      while (i != 0){
          bstr[k--] = byte(48 + i % 10);
          i /= 10;
      }
      return string(bstr);
  }
 
  
}



/**
 * @title AirDrop Light Direct Airdrop
 * @notice Contract is not payable.
 * Owner or admin can allocate tokens.
 * Tokens will be released direct. 
 *
 *
 */
contract AirDropLight is OwnableWithAdmin {
  using SafeMath for uint256;

  event AirDropFailed(address recipient, uint256 amount);
  
  // Amount of tokens claimed
  uint256 public grandTotalClaimed = 0;

  // The token being sold
  ERC20 public token;

  // Max amount in one airdrop
  uint256  maxDirect = 1500 * (10**uint256(18));

  // Recipients
  mapping(address => bool) public recipients;

  // List of all addresses
  address[] public addresses;
   
  constructor(ERC20 _token) public {
     
    require(_token != address(0));

    token = _token;

  }

  
  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () public {
    //Not payable
  }


  /**
    * @dev Transfer tokens direct
    * @param _recipients Array of wallets
    * @param _tokenAmount Amount Allocated tokens + 18 decimals
    */
  function transferManyDirect (address[] _recipients, uint256 _tokenAmount) onlyOwnerOrAdmin  public{
    for (uint256 i = 0; i < _recipients.length; i++) {
      
      if(!recipients[_recipients[i]] && _tokenAmount < maxDirect){        
        transferDirect(_recipients[i],_tokenAmount);
      }else{
        emit AirDropFailed(_recipients[i], _tokenAmount);
      }
      
    }    
  }

        
  /**
    * @dev Transfer tokens direct to recipient without allocation. 
    * _recipient can only get one transaction and _tokenAmount can't be above maxDirect value
    *  
    */
  function transferDirect(address _recipient,uint256 _tokenAmount) public{

    // Check if contract has tokens
    require(token.balanceOf(this)>=_tokenAmount);
    
    // Check max value
    require(_tokenAmount < maxDirect );

    // Check if recipient already have received tokens
    // Only one airdrop per _recipient
    require(!recipients[_recipient]); 
    recipients[_recipient] = true;
  
    // Transfer tokens
    require(token.transfer(_recipient, _tokenAmount));

    // Add claimed tokens to grandTotalClaimed
    grandTotalClaimed = grandTotalClaimed.add(_tokenAmount);


    // Emit event success
    // emit AirDropSuccess(_recipient, _tokenAmount); 
     
  }
  

  // Allow transfer of tokens back to owner or reserve wallet
  function returnTokens() public onlyOwner {
    uint256 balance = token.balanceOf(this);
    require(token.transfer(owner, balance));
  }

  // Owner can transfer tokens that are sent here by mistake
  function refundTokens(address _recipient, ERC20 _token) public onlyOwner {
    uint256 balance = _token.balanceOf(this);
    require(_token.transfer(_recipient, balance));
  }

}



/**
 * @title BNXAirDropLight
 *  
 *
*/
contract BNXAirDropLight is AirDropLight {
  constructor(   
    ERC20 _token
  ) public AirDropLight(_token) {

     

  }
}