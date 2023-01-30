/**

 *Submitted for verification at Etherscan.io on 2018-11-20

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

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



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

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





interface AddressRegistry {

    function getAddr(string name) external view returns(address);

}



interface Kyber {

    function trade(

        address src,

        uint srcAmount,

        address dest,

        address destAddress,

        uint maxDestAmount,

        uint minConversionRate,

        address walletId

    ) external payable returns (uint);



    function getExpectedRate(

        address src,

        address dest,

        uint srcQty

    ) external view returns (uint, uint);

}





contract Registry {

    address public addressRegistry;

    modifier onlyAdmin() {

        require(

            msg.sender == getAddress("admin"),

            "Permission Denied"

        );

        _;

    }

    function getAddress(string name) internal view returns(address) {

        AddressRegistry addrReg = AddressRegistry(addressRegistry);

        return addrReg.getAddr(name);

    }



}





contract Trade is Registry {



    using SafeMath for uint;

    using SafeMath for uint256;



    event KyberTrade(

        address src,

        uint srcAmt,

        address dest,

        uint destAmt,

        address beneficiary,

        uint minConversionRate,

        address affiliate

    );



    function executeTrade(

        address src,

        address dest,

        uint srcAmt,

        uint minConversionRate

    ) public payable returns (uint destAmt)

    {

        address protocolAdmin = getAddress("admin");

        uint ethQty;



        // fetch token & deduct fees

        IERC20 tokenFunctions = IERC20(src);

        if (src == getAddress("eth")) {

            require(msg.value == srcAmt, "Invalid Operation");

            ethQty = srcAmt;

        } else {

            tokenFunctions.transferFrom(msg.sender, address(this), srcAmt);

        }



        Kyber kyberFunctions = Kyber(getAddress("kyber"));

        destAmt = kyberFunctions.trade.value(ethQty)(

            src,

            srcAmt,

            dest,

            msg.sender,

            2**256 - 1,

            minConversionRate,

            protocolAdmin

        );



        emit KyberTrade(

            src,

            srcAmt,

            dest,

            destAmt,

            msg.sender,

            minConversionRate,

            protocolAdmin

        );



    }



    function getExpectedPrice(

        address src,

        address dest,

        uint srcAmt

    ) public view returns (uint, uint) 

    {

        Kyber kyberFunctions = Kyber(getAddress("kyber"));

        return kyberFunctions.getExpectedRate(

            src,

            dest,

            srcAmt

        );

    }



    function approveKyber(address[] tokenArr) public {

        for (uint i = 0; i < tokenArr.length; i++) {

            IERC20 tokenFunctions = IERC20(tokenArr[i]);

            tokenFunctions.approve(getAddress("kyber"), 2**256 - 1);

        }

    }



}





contract MoatKyber is Trade {



    event AssetsCollected(address name, uint addr);



    constructor(address rAddr) public {

        addressRegistry = rAddr;

    }



    function () public payable {}



    function collectAsset(address tokenAddress, uint amount) public onlyAdmin {

        if (tokenAddress == getAddress("eth")) {

            msg.sender.transfer(amount);

        } else {

            IERC20 tokenFunctions = IERC20(tokenAddress);

            tokenFunctions.transfer(msg.sender, amount);

        }

        emit AssetsCollected(tokenAddress, amount);

    }



}