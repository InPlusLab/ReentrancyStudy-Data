/**

 *Submitted for verification at Etherscan.io on 2019-02-22

*/



pragma solidity ^0.4.25;



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



contract ICO{

    

    using SafeMath for uint256;

    

    mapping(address=>uint256) depositRecord;

    

    event collectionRecords(

        address indexed addr,

        uint256 amount

    );



    event refundRecords(

        address indexed addr,

        uint256 amount

    );

    

    uint256 public  total;//Total fundraising.

    uint256 public  goalOne;//After the goal is reached, the project starts.

    uint256 public  goalTwo;//End this fundraising after reaching this goal.

    

    address public  owner;//Contract manager.



    constructor() public{

      goalOne = 10000 ether;

      goalTwo = 40000 ether;

      owner = msg.sender;

    }

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }



    function() payable public{



      //Not less than 0.1 ether.

      require (msg.value >= 100 finney);

      

      //No longer receive new investment after completing the second goal.

      require (goalTwo > total);

      

      depositRecord[msg.sender] = depositRecord[msg.sender].add(msg.value);

      total = total.add(msg.value);

      emit collectionRecords(msg.sender, msg.value);

    }



    //Allow investment to be returned before the first goal is reached.

    function refund() public {

      

      require (depositRecord[msg.sender] > 0);



      require (goalOne > total);



      uint256 amount = depositRecord[msg.sender];

      depositRecord[msg.sender] = 0;

      total = total.sub(amount);



      emit refundRecords(msg.sender, amount);

      msg.sender.transfer(amount);

    }

    

    function withdrawBalance() public onlyOwner {

      require (goalOne <= total);

      owner.transfer(address(this).balance);

    }



    function getBalance(address addr) public view returns(uint256) {

      return depositRecord[addr];

    }

    

}