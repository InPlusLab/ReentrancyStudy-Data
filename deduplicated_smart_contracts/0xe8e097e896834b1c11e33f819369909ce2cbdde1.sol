/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

/**
 *Submitted for verification at Etherscan.io on 2019-06-28
*/

pragma solidity 0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract ERC20Interface {
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);
}

contract MpctLockupTeam is Ownable {
    using SafeMath for uint256;
    ERC20Interface token;

    address public constant tokenAddress = 0x7700d7594c5d033d5d5b0aFDaD89C15c0Be4bD22;
    address public wallet = 0xd9c272dA74143Bd07e30C64FfA483142BF5316C0;
    uint256 public lockupDate = 1624147200;
    uint256 public initLockupAmt = 200000000e18;

    function MpctLockupTeam () public {
        token = ERC20Interface(tokenAddress);
    }

    function setLockupAmt(uint256 _amt) public onlyOwner {
        initLockupAmt = _amt;
    }

    function setLockupDate(uint _date) public onlyOwner {
        lockupDate = _date;
    }

    function setWallet(address _dest) public onlyOwner {
        wallet = _dest;
    }

    function withdraw() onlyOwner public {
        uint256 currBalance = token.balanceOf(this);
        uint256 currLocking = getCurrLocking();

        require(currBalance > currLocking);

        token.transfer(wallet, currBalance-currLocking);
    }

    function getCurrLocking()
        public
		view
        returns (uint256)
	{
	    if (lockupDate >= now)
	        return initLockupAmt;
	    
        uint256 diff = (now - lockupDate) / 2592000; // month diff
        uint256 partition = 10;
    
        if (diff >= partition) 
            return 0;
        else
            return initLockupAmt.mul(partition-diff).div(partition);
    }
}