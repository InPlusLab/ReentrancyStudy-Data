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

 * ���ѧ٧�ӧ�� �ܧ�ߧ��ѧܧ�, �ܧ������ ���էէ֧�اڧӧѧ֧� ����ѧߧ�ӧܧ� ����էѧ�

 */



contract Haltable is Ownable {

    bool public halted;



    modifier stopInEmergency {

        require(!halted);

        _;

    }



    /* ����էڧ�ڧܧѧ���, �ܧ������ �ӧ�٧�ӧѧ֧��� �� �����ާܧѧ� */

    modifier onlyInEmergency {

        require(halted);

        _;

    }



    /* ����٧�� ���ߧܧ�ڧ� ���֧�ӧ֧� ����էѧا�, �ӧ�٧�ӧѧ�� �ާ�ا֧� ���ݧ�ܧ� �ӧݧѧէ֧ݧ֧� */

    function halt() external onlyOwner {

        halted = true;

    }



    /* ����٧�� �ӧ�٧ӧ�ѧ�ѧ֧� ��֧اڧ� ����էѧ� */

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

 * ���ߧ�֧��֧ۧ� �ܧ�ߧ��ѧܧ�� ���ܧ֧ߧ�

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



/* ����ߧ��ѧܧ� ����էѧ� */



contract Sale is Haltable {

    using SafeMath for uint;



    /* ����ܧ֧�, �ܧ������ ����էѧ֧� */

    ImpToken public impToken;



    /* ����ҧ�ѧߧߧ�� ���֧է��ӧ� �ҧ�է�� ��֧�֧ӧ�էڧ���� ���է� */

    address public destinationWallet;



    /*  ���ܧ�ݧ�ܧ� ��֧ۧ�ѧ� ����ڧ� 1 IMP �� wei */

    uint public oneImpInWei;



    /*  ���ڧߧڧާѧݧ�ߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ��, �ܧ������ �ާ�اߧ� ����էѧ�� */

    uint public minBuyTokenAmount;



    /*  ���ѧܧ�ڧާѧݧ�ߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ��, �ܧ������ �ާ�اߧ� �ܧ��ڧ�� �٧� 1 ��ѧ� */

    uint public maxBuyTokenAmount;



    /* ����ҧ��ڧ� ���ܧ��ܧ� ���ܧ֧ߧ� */

    event Invested(address receiver, uint weiAmount, uint tokenAmount);



    /* ����ߧ����ܧ��� */

    function Sale(address _impTokenAddress, address _destinationWallet) {

        require(_impTokenAddress != 0);

        require(_destinationWallet != 0);



        impToken = ImpToken(_impTokenAddress);



        destinationWallet = _destinationWallet;

    }



    /**

     * Fallback ���ߧܧ�ڧ� �ӧ�٧�ӧѧ��ѧ��� ���� ��֧�֧ӧ�է� ���ڧ��

     */

    function() payable stopInEmergency {

        uint weiAmount = msg.value;

        address receiver = msg.sender;



        uint tokenMultiplier = 10 ** impToken.decimals();

        uint tokenAmount = weiAmount.mul(tokenMultiplier).div(oneImpInWei);



        require(tokenAmount > 0);



        require(tokenAmount >= minBuyTokenAmount && tokenAmount <= maxBuyTokenAmount);



        // ���ܧ�ݧ�ܧ� ����ѧݧ��� ���ܧ֧ߧ�� �ߧ� �ܧ�ߧ��ѧܧ�� ����էѧ�

        uint tokensLeft = getTokensLeft();



        require(tokensLeft > 0);



        require(tokenAmount <= tokensLeft);



        // ���֧�֧ӧ�էڧ� ���ܧ֧ߧ� �ڧߧӧ֧�����

        assignTokens(receiver, tokenAmount);



        // ���ݧ֧� �ߧ� �ܧ��֧ݧק� ���ڧ�

        destinationWallet.transfer(weiAmount);



        // ����٧�ӧѧ֧� ���ҧ��ڧ�

        Invested(receiver, weiAmount, tokenAmount);

    }



    /**

     * ���է�֧� �ܧ��֧ݧ�ܧ� �էݧ� ��ҧ��� ���֧է���

     */

    function setDestinationWallet(address destinationAddress) external onlyOwner {

        destinationWallet = destinationAddress;

    }



    /**

     *  ���ڧߧڧާѧݧ�ߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ��, �ܧ������ �ާ�اߧ� ����էѧ��

     */

    function setMinBuyTokenAmount(uint value) external onlyOwner {

        minBuyTokenAmount = value;

    }



    /**

     *  ���ѧܧ�ڧާѧݧ�ߧ�� �ܧ��-�ӧ� ���ܧ֧ߧ��, �ܧ������ �ާ�اߧ� ����էѧ��

     */

    function setMaxBuyTokenAmount(uint value) external onlyOwner {

        maxBuyTokenAmount = value;

    }



    /**

     * ����ߧܧ�ڧ�, �ܧ����ѧ� �٧ѧէѧ֧� ��֧ܧ��ڧ� �ܧ��� ETH �� ��֧ߧ�ѧ�

     */

    function setOneImpInWei(uint value) external onlyOwner {

        require(value > 0);



        oneImpInWei = value;

    }



    /**

     * ���֧�֧ӧ�� ���ܧ֧ߧ�� ���ܧ��ѧ�֧ݧ�

     */

    function assignTokens(address receiver, uint tokenAmount) private {

        impToken.transfer(receiver, tokenAmount);

    }



    /**

     * ����٧ӧ�ѧ�ѧ֧� �ܧ��-�ӧ� �ߧ֧�ѧ����էѧߧߧ�� ���ܧ֧ߧ��

     */

    function getTokensLeft() public constant returns (uint) {

        return impToken.balanceOf(address(this));

    }

}