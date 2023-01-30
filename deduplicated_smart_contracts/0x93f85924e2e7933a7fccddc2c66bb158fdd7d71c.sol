/**

 *Submitted for verification at Etherscan.io on 2019-02-06

*/



pragma solidity ^0.5.3;







contract Ownable {

    

    address public _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = 0x7e826E85CbA4d3AAaa1B484f53BE01D10F527Fd6;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(msg.sender == _owner);

        _;

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}







/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    uint256 c = _a * _b;

    require(c / _a == _b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    require(_b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    require(_b <= _a);

    uint256 c = _a - _b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

    uint256 c = _a + _b;

    require(c >= _a);



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







contract ERC20_Interface {

    

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);   

    

}



library AddressMakePayable {

   function makePayable(address x) internal pure returns (address payable) {

      return address(uint160(x));

   }

}



contract PaidSelfDrop is Ownable {

    

    using SafeMath for uint;

    using AddressMakePayable for address;

    

    ERC20_Interface public constant SHNZ2 = ERC20_Interface(0x7c70c1093653Ca3aa47aC5D8F934125A0Aaa1645);

    

    uint public price = 17e13; 

    uint public dropAmount = 2000e18;

    



    

    function() external payable {

        require(msg.value >= price);

        if(msg.value > price) {

            msg.sender.transfer(msg.value.sub(price));

        }

        SHNZ2.transfer(msg.sender,dropAmount);

        address(_owner).makePayable().transfer(price);

    }

    

    function changePrice(uint _newPrice) public onlyOwner {

        require(_newPrice > 0 && _newPrice != price);

        price = _newPrice;

    }

    

    function withdrawSHNZ2(uint _amount) public onlyOwner {

        SHNZ2.transfer(owner(), _amount);

    }

}