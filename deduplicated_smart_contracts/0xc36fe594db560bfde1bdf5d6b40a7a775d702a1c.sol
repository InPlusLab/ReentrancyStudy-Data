/**
 *Submitted for verification at Etherscan.io on 2019-12-07
*/

// File: contracts/Ownable.sol

pragma solidity >0.4.0 <0.6.0;

contract Ownable {

  address payable public owner;

  constructor () public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  
  function transferOwnership(address payable newOwner) external onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

// File: contracts/ReentrancyGuard.sol

pragma solidity ^0.5.0;

contract ReentrancyGuard {
    // counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// File: contracts/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: contracts/EthMaximalist.sol

pragma solidity ^0.5.0;





interface Invest2Fulcrum1xShortBTC {
    function LetsInvest2Fulcrum1xShortBTC(address _towhomtoissue) external payable;
}

interface Invest2Fulcrum {
    function LetsInvest2Fulcrum(address _towhomtoissue) external payable;
}


// through this contract we are putting 90% allocation to cDAI and 10% to 2xLongETH
contract ETHMaximalist is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    
    // state variables
    
    
    // - variables in relation to the percentages
    uint public ShortBTCAllocation = 50;
    Invest2Fulcrum public Invest2FulcrumContract = Invest2Fulcrum(0xAB58BBF6B6ca1B064aa59113AeA204F554E8fBAe);
    Invest2Fulcrum1xShortBTC public Invest2Fulcrum1xShortBTCContract = Invest2Fulcrum1xShortBTC(0xa2C3e380E6c082A003819a2a69086748fe3D15Dd);

    
    
    // - in relation to the ETH held by this contract
    uint public balance = address(this).balance;
    
    // - in relation to the emergency functioning of this contract
    bool private stopped = false;

    
    // circuit breaker modifiers
    modifier stopInEmergency {if (!stopped) _;}
    modifier onlyInEmergency {if (stopped) _;}

    constructor () public {
    }
    
    function toggleContractActive() onlyOwner public {
    stopped = !stopped;
    }
    
    function change_cDAIAllocation(uint _numberPercentageValue) public onlyOwner {
        require(_numberPercentageValue > 1 && _numberPercentageValue < 100);
        ShortBTCAllocation = _numberPercentageValue;
    }
    
    
    // this function lets you deposit ETH into this wallet 
    function ETHMaximalistZAP() stopInEmergency payable public returns (bool) {
        require(msg.value>10000000000000);
        uint investment_amt = msg.value;
        uint investAmt2ShortBTC = SafeMath.div(SafeMath.mul(investment_amt,ShortBTCAllocation), 100);
        uint investAmt2c1xLongETH = SafeMath.sub(investment_amt, investAmt2ShortBTC);
        require (SafeMath.sub(investment_amt,SafeMath.add(investAmt2ShortBTC, investAmt2c1xLongETH)) == 0);
        Invest2Fulcrum1xShortBTCContract.LetsInvest2Fulcrum1xShortBTC.value(investAmt2ShortBTC)(msg.sender);
        Invest2FulcrumContract.LetsInvest2Fulcrum.value(investAmt2c1xLongETH)(msg.sender);
        
    }
    // - this function lets you deposit ETH into this wallet
    function depositETH() payable public onlyOwner returns (uint) {
        balance += msg.value;
    }
    
    // - fallback function let you / anyone send ETH to this wallet without the need to call any function
    function() external payable {
        if (msg.sender == owner) {
            depositETH();
        } else {
            ETHMaximalistZAP();
        }
    }
    
    // - to withdraw any ETH balance sitting in the contract
    function withdraw() onlyOwner public{
        owner.transfer(address(this).balance);
    }
    

}