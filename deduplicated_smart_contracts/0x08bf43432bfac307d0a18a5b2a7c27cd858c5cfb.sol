/**

 *Submitted for verification at Etherscan.io on 2018-09-03

*/



pragma solidity ^0.4.13;



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

  function Ownable() {

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

  function transferOwnership(address newOwner) onlyOwner {

    require(newOwner != address(0));      

    OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}



/*

 * §¢§Ñ§Ù§à§Ó§í§Û §Ü§à§ß§ä§â§Ñ§Ü§ä, §Ü§à§ä§à§â§í§Û §á§à§Õ§Õ§Ö§â§Ø§Ú§Ó§Ñ§Ö§ä §à§ã§ä§Ñ§ß§à§Ó§Ü§å §á§â§à§Õ§Ñ§Ø

 */



contract Haltable is Ownable {

    bool public halted;



    modifier stopInEmergency {

        require(!halted);

        _;

    }



    /* §®§à§Õ§Ú§æ§Ú§Ü§Ñ§ä§à§â, §Ü§à§ä§à§â§í§Û §Ó§í§Ù§í§Ó§Ñ§Ö§ä§ã§ñ §Ó §á§à§ä§à§Þ§Ü§Ñ§ç */

    modifier onlyInEmergency {

        require(halted);

        _;

    }



    /* §£§í§Ù§à§Ó §æ§å§ß§Ü§è§Ú§Ú §á§â§Ö§â§Ó§Ö§ä §á§â§à§Õ§Ñ§Ø§Ú, §Ó§í§Ù§í§Ó§Ñ§ä§î §Þ§à§Ø§Ö§ä §ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è */

    function halt() external onlyOwner {

        halted = true;

    }



    /* §£§í§Ù§à§Ó §Ó§à§Ù§Ó§â§Ñ§ë§Ñ§Ö§ä §â§Ö§Ø§Ú§Þ §á§â§à§Õ§Ñ§Ø */

    function unhalt() external onlyOwner onlyInEmergency {

        halted = false;

    }



}



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

uint256 public totalSupply;

function balanceOf(address who) constant returns (uint256);

function transfer(address to, uint256 value) returns (bool);

event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * §ª§ß§ä§Ö§â§æ§Ö§Û§ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ §ä§à§Ü§Ö§ß§Ñ

 */



contract ImpToken is ERC20Basic {

    function decimals() public returns (uint) {}

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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



/* §¬§à§ß§ä§â§Ñ§Ü§ä §á§â§à§Õ§Ñ§Ø */



contract Sale is Haltable {

    using SafeMath for uint;



    /* §´§à§Ü§Ö§ß, §Ü§à§ä§à§â§í§Û §á§â§à§Õ§Ñ§Ö§Þ */

    ImpToken public impToken;



    /* §³§à§Ò§â§Ñ§ß§ß§í§Ö §ã§â§Ö§Õ§ã§ä§Ó§Ñ §Ò§å§Õ§å§ä §á§Ö§â§Ö§Ó§à§Õ§Ú§ä§î§ã§ñ §ã§ð§Õ§Ñ */

    address public destinationWallet;



    /*  §³§Ü§à§Ý§î§Ü§à §ã§Ö§Û§é§Ñ§ã §ã§ä§à§Ú§ä 1 IMP §Ó wei */

    uint public oneImpInWei;



    /*  §®§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§à§Ö §Þ§à§Ø§ß§à §á§â§à§Õ§Ñ§ä§î */

    uint public minBuyTokenAmount;



    /*  §®§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§à§Ö §Þ§à§Ø§ß§à §Ü§å§á§Ú§ä§î §Ù§Ñ 1 §â§Ñ§Ù */

    uint public maxBuyTokenAmount;



    /* §³§à§Ò§í§ä§Ú§Ö §á§à§Ü§å§á§Ü§Ú §ä§à§Ü§Ö§ß§Ñ */

    event Invested(address receiver, uint weiAmount, uint tokenAmount);



    /* §¬§à§ß§ã§ä§â§å§Ü§ä§à§â */

    function Sale(address _impTokenAddress, address _destinationWallet) {

        require(_impTokenAddress != 0);

        require(_destinationWallet != 0);



        impToken = ImpToken(_impTokenAddress);



        destinationWallet = _destinationWallet;

    }



    /**

     * Fallback §æ§å§ß§Ü§è§Ú§ñ §Ó§í§Ù§í§Ó§Ñ§ð§ë§Ñ§ñ§ã§ñ §á§â§Ú §á§Ö§â§Ö§Ó§à§Õ§Ö §ï§æ§Ú§â§Ñ

     */

    function() payable stopInEmergency {

        uint weiAmount = msg.value;

        address receiver = msg.sender;



        uint tokenMultiplier = 10 ** impToken.decimals();

        uint tokenAmount = weiAmount.mul(tokenMultiplier).div(oneImpInWei);



        require(tokenAmount > 0);



        require(tokenAmount >= minBuyTokenAmount && tokenAmount <= maxBuyTokenAmount);



        // §³§Ü§à§Ý§î§Ü§à §à§ã§ä§Ñ§Ý§à§ã§î §ä§à§Ü§Ö§ß§à§Ó §ß§Ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ö §á§â§à§Õ§Ñ§Ø

        uint tokensLeft = getTokensLeft();



        require(tokensLeft > 0);



        require(tokenAmount <= tokensLeft);



        // §±§Ö§â§Ö§Ó§à§Õ§Ú§Þ §ä§à§Ü§Ö§ß§í §Ú§ß§Ó§Ö§ã§ä§à§â§å

        assignTokens(receiver, tokenAmount);



        // §º§Ý§Ö§Þ §ß§Ñ §Ü§à§ê§Ö§Ý§×§Ü §ï§æ§Ú§â

        destinationWallet.transfer(weiAmount);



        // §£§í§Ù§í§Ó§Ñ§Ö§Þ §ã§à§Ò§í§ä§Ú§Ö

        Invested(receiver, weiAmount, tokenAmount);

    }



    /**

     * §¡§Õ§â§Ö§ã §Ü§à§ê§Ö§Ý§î§Ü§Ñ §Õ§Ý§ñ §ã§Ò§à§â§Ñ §ã§â§Ö§Õ§ã§ä§Ó

     */

    function setDestinationWallet(address destinationAddress) external onlyOwner {

        destinationWallet = destinationAddress;

    }



    /**

     *  §®§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§à§Ö §Þ§à§Ø§ß§à §á§â§à§Õ§Ñ§ä§î

     */

    function setMinBuyTokenAmount(uint value) external onlyOwner {

        minBuyTokenAmount = value;

    }



    /**

     *  §®§Ñ§Ü§ã§Ú§Þ§Ñ§Ý§î§ß§à§Ö §Ü§à§Ý-§Ó§à §ä§à§Ü§Ö§ß§à§Ó, §Ü§à§ä§à§â§à§Ö §Þ§à§Ø§ß§à §á§â§à§Õ§Ñ§ä§î

     */

    function setMaxBuyTokenAmount(uint value) external onlyOwner {

        maxBuyTokenAmount = value;

    }



    /**

     * §¶§å§ß§Ü§è§Ú§ñ, §Ü§à§ä§à§â§Ñ§ñ §Ù§Ñ§Õ§Ñ§Ö§ä §ä§Ö§Ü§å§ë§Ú§Û §Ü§å§â§ã ETH §Ó §è§Ö§ß§ä§Ñ§ç

     */

    function setOneImpInWei(uint value) external onlyOwner {

        require(value > 0);



        oneImpInWei = value;

    }



    /**

     * §±§Ö§â§Ö§Ó§à§Õ §ä§à§Ü§Ö§ß§à§Ó §á§à§Ü§å§á§Ñ§ä§Ö§Ý§ð

     */

    function assignTokens(address receiver, uint tokenAmount) private {

        impToken.transfer(receiver, tokenAmount);

    }



    /**

     * §£§à§Ù§Ó§â§Ñ§ë§Ñ§Ö§ä §Ü§à§Ý-§Ó§à §ß§Ö§â§Ñ§ã§á§â§à§Õ§Ñ§ß§ß§í§ç §ä§à§Ü§Ö§ß§à§Ó

     */

    function getTokensLeft() public constant returns (uint) {

        return impToken.balanceOf(address(this));

    }

}