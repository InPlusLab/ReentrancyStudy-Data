/**
 *Submitted for verification at Etherscan.io on 2020-12-12
*/

pragma solidity ^0.4.22;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable {
   address internal admin;
   address internal owner;

  constructor() internal {
    owner = msg.sender;
    admin = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Ownable: msg.sender not owner");
    _;
  }


 
}

contract BronPresale is Ownable {
 //variables
 //storing contract_amount collected for the event
 address public owner;
 uint256 public _bank = 0; 

 using SafeMath for uint256;


  constructor() public {
  owner = msg.sender;
  }

  event invest(address indexed _from,uint256 amount);

  //register a user in the event
 function () payable external {
    _bank = _bank.add(msg.value);
     emit invest(msg.sender,msg.value); 
 }




   function transferBank() external payable onlyOwner {

    
    msg.sender.transfer(_bank);
    
    _bank =0;
   

  }



  }