/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.4.23;

contract Ownable {

    // public variables
    address public owner;

    // internal variables

    // events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // public functions
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // internal functions
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract ERC20Basic {
  // events
  event Transfer(address indexed from, address indexed to, uint256 value);

  // public functions
  function totalSupply() public view returns (uint256);
  function balanceOf(address addr) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}

contract BatchTransfer is Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    ERC20Basic public token;
    uint256 public decimal = 8;

    constructor() public {
        token = ERC20Basic(0x0f8c45b896784a1e408526b9300519ef8660209c);
    }
    
    function batchTransfer(address[] addrs, uint256[] amounts) public onlyOwner {
        require(addrs.length > 0 && addrs.length == amounts.length);
        
        uint256 total = token.balanceOf(this);
        require(total > 0);
        
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < addrs.length; i++) {
            require(!(addrs[i].isContract()));
            totalAmount = totalAmount.add(amounts[i] * 10 ** decimal);
        }
        require(totalAmount <= total);
        
        for (uint256 j = 0; j < addrs.length; j++) {
            token.transfer(addrs[j], amounts[j] * 10 ** decimal);
        }
    }
    
    function getBalance() public view returns(uint256) {
        return token.balanceOf(this);
    }
    
    function() public payable {
        revert();
    }
    
}