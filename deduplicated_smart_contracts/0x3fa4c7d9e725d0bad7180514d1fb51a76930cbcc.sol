/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.5.4;



interface IERC20 {

  function balanceOf(address who) external view returns (uint256);



  function allowance(address owner, address spender)

    external view returns (uint256);

    

  function transferFrom(address from, address to, uint256 value)

    external returns (bool);

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

}



contract Owned {

    address payable public owner;

    address payable public newOwner;

    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

    function transferOwnership(address payable _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        owner = newOwner;

    }

}



contract VeganCrowdsale is Owned {

    using SafeMath for uint256;

    

    // Sets the owner

    constructor() public {

        owner = 0xc0Eda767a948f22c9a2f14570aCFeb1397cab6Be;

    }

    

    // Contract Variables

    address public tokenAddress = 0xFADe17a07ba3B480aA1714c3724a52D4C57d410E;     // Contract address for token

    uint256 public tokenDecimals = 8;

    uint256 public tokenPrice = 0;      // Price in WEI per token

    uint256 public endOfStage = 0;      // If greater than present then is active

    uint256 public currentBonus = 0;    // Amount in percent

    uint256 public stageAmount = 0;     // Maximum amount of tokens to be sold in stage

    

    // Set token Price

    function setTokenPrice(uint256 PriceInWei) public onlyOwner {

        tokenPrice = PriceInWei;

    }

    

    // Create Selling Stage

    function setSellingStage(uint256 bonus, uint256 amount, uint256 endTimestamp) public onlyOwner {

        currentBonus = bonus;

        stageAmount = amount * 10 ** tokenDecimals;

        endOfStage = endTimestamp;

    }

    

    // End Stage

    function endSelling() public onlyOwner {

        endOfStage = 0;

    }

    

    // Fallback function for purchasing token

    function () external payable {

        require(stageAmount > 0 || endOfStage > now);

        uint256 affordAmount = msg.value.div(tokenPrice);

        uint256 affordWithBonus = (affordAmount.mul(100 + currentBonus)).div(100);

        if (affordWithBonus <= stageAmount && affordWithBonus.mul(10 ** tokenDecimals) <= IERC20(tokenAddress).balanceOf(owner) && affordWithBonus.mul(10 ** tokenDecimals) <= IERC20(tokenAddress).allowance(owner, address(this))) {

            stageAmount.sub(affordWithBonus);

            IERC20(tokenAddress).transferFrom(owner, msg.sender, affordWithBonus.mul(10 ** tokenDecimals));

            owner.transfer(msg.value);

        } else {

            revert();

        }

    }

}