/**
 *Submitted for verification at Etherscan.io on 2019-10-23
*/

pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


interface token {
    function transfer(address, uint) external returns (bool);
    function allowance(address, address) external returns (uint);
    function transferFrom(address, address, uint) external returns (bool);
}

contract SubmitTokens is Ownable {
    
    using SafeMath for uint;
    
    event SubmittedTokens(address, uint, string);
    
    // JDXU Address Here
    address public constant jdxuAddress = 0xc85D9309a26b6a4A49eb895eCc34FFCB9698aE11;
    
    mapping (address => uint) public bals;
    mapping (address => string) public addrs;
    mapping (address => uint) public indexOfAddr;
    mapping (uint => address) public addrOfIndex;
    mapping (address => bool) public isAdded;
    
    uint public lastIndex = 0;
    
    function submitBnbAddress(string memory bnbAddr) public {
        uint allowance = token(jdxuAddress).allowance(msg.sender, address(this));
        require(allowance > 0 && 
            token(jdxuAddress).transferFrom(msg.sender, address(this), allowance));
            
        if (!isAdded[msg.sender]) {
            lastIndex = lastIndex.add(1);
            isAdded[msg.sender] = true;
            addrOfIndex[lastIndex] = msg.sender;
            indexOfAddr[msg.sender] = lastIndex;
        }
        
        bals[msg.sender] = bals[msg.sender].add(allowance);
        addrs[msg.sender] = bnbAddr;
        emit SubmittedTokens(msg.sender, allowance, bnbAddr);
    }
    
    function getAddrs(uint startIndex, uint endIndex) public view returns (address[] memory,uint[] memory, string[] memory) {
        require (endIndex > startIndex && endIndex <= lastIndex);
        address[] memory tempEthAddrs = new address[](endIndex - startIndex + 1);
        uint[] memory tempBals = new uint[](endIndex - startIndex + 1);
        string[] memory tempBnbAddrs = new string[](endIndex - startIndex + 1);
        for (uint i = startIndex; i <= endIndex; i++) {
            tempEthAddrs[i-startIndex] = addrOfIndex[i];
            tempBnbAddrs[i-startIndex] = addrs[addrOfIndex[i]];
            tempBals[i-startIndex] = bals[addrOfIndex[i]];
        }
        
        return (tempEthAddrs, tempBals, tempBnbAddrs);
    }
    
    function withdrawTokens(address tokenAddr, address to, uint tokenAmount) public onlyOwner {
        token(tokenAddr).transfer(to, tokenAmount);
    }
}