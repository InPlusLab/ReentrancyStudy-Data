/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.10;

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

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
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
}

contract Owned {
    address public owner;
    address public newOwner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        owner = newOwner;
    }
}

contract GMAMICO is Owned {
    using SafeMath for uint256;
    
    constructor() public {
        owner = 0xb636a5A167b603d4f75E485E4657e1dD5C2372aa;
        contractAddress = address(this);
    }
    
    address internal contractAddress;
    
    // Token Addresses'
    address public GMAMAddress = 0x1e22C2bb045e032833D6EC3c7f3CAf5a8D74f137;
    uint256 public GMAMDecimals = 5;
    address public DAIAddress = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    address public TUSDAddress = 0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;

    // If ICO is on
    bool public ICOActive;
    
    // Set ICO status
    function setICOActve(bool _status) public onlyOwner {
        ICOActive = _status;
    }
    
    // Cost per token
    uint256 public etherCost;
    uint256 public stablecoinCost;
    
    // Update token Cost
    function setCost(uint256 _etherCost, uint256 _stablecoinCost) public onlyOwner {
        require(_stablecoinCost > 0 && _etherCost > 0);
        etherCost = _etherCost;
        stablecoinCost = _stablecoinCost;
    }
    
    // Pay With Ether, uses fallback function
    function () external payable {
        require(ICOActive == true);
        uint256 amount = msg.value.mul(10 ** GMAMDecimals).div(etherCost); 
        require(amount <= IERC20(GMAMAddress).allowance(owner, contractAddress));
        IERC20(GMAMAddress).transferFrom(owner, contractAddress, amount);
        IERC20(GMAMAddress).transfer(msg.sender, amount);
    }
    
    // Pay With stablecoin
    function payWithStablecoin(uint256 amountOfStablecoin, bool trueDaiFalseTUSD) public {
        require(ICOActive == true);
        uint256 amount = amountOfStablecoin.mul(10 ** GMAMDecimals).div(stablecoinCost);
        require(amount <= IERC20(GMAMAddress).allowance(owner, address(this)));
        address stablecoinAddress;
        if (trueDaiFalseTUSD == true) {
            stablecoinAddress = DAIAddress;
        } else {
            stablecoinAddress = TUSDAddress;
        }
        require(amountOfStablecoin <= IERC20(stablecoinAddress).allowance(msg.sender, address(this)));
        IERC20(stablecoinAddress).transferFrom(msg.sender, address(this), amountOfStablecoin);
        IERC20(stablecoinAddress).transfer(owner, amountOfStablecoin);
        IERC20(GMAMAddress).transferFrom(owner, address(this), amount);
        IERC20(GMAMAddress).transfer(msg.sender, amount);
    }
    
}