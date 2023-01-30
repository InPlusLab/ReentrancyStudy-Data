/**

 *Submitted for verification at Etherscan.io on 2018-10-24

*/



pragma solidity 0.4.24;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

  function totalSupply() external view returns (uint256);



  function balanceOf(address who) external view returns (uint256);



  function allowance(address owner, address spender) external view returns (uint256);



  function transfer(address to, uint256 value) external returns (bool);



  function approve(address spender, uint256 value) external returns (bool);



  function transferFrom(address from, address to, uint256 value) external returns (bool);



  event Transfer(address indexed from, address indexed to, uint256 value);



  event Approval(address indexed owner, address indexed spender, uint256 value);

}



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

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(IERC20 token, address to, uint256 value) internal {

    require(token.transfer(to, value));

  }



  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

    require(token.transferFrom(from, to, value));

  }



  function safeApprove(IERC20 token, address spender, uint256 value) internal {

    require(token.approve(spender, value));

  }

}



/**

 * @title TokenTimelock

 * @dev TokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract TokenTimelock {

  using SafeERC20 for IERC20;



  // ERC20 basic token contract being held

  IERC20 private _token;



  // beneficiary of tokens after they are released

  address private _beneficiary;



  // timestamp when token release is enabled

  uint256 private _releaseTime;



  constructor(IERC20 token, address beneficiary, uint256 releaseTime) public {

    // solium-disable-next-line security/no-block-members

    require(releaseTime > block.timestamp);

    _token = token;

    _beneficiary = beneficiary;

    _releaseTime = releaseTime;

  }



  /**

   * @return the token being held.

   */

  function token() public view returns(IERC20) {

    return _token;

  }



  /**

   * @return the beneficiary of the tokens.

   */

  function beneficiary() public view returns(address) {

    return _beneficiary;

  }



  /**

   * @return the time when the tokens are released.

   */

  function releaseTime() public view returns(uint256) {

    return _releaseTime;

  }



  /**

   * @notice Transfers tokens held by timelock to beneficiary.

   */

  function release() public {

    // solium-disable-next-line security/no-block-members

    require(block.timestamp >= _releaseTime);



    uint256 amount = _token.balanceOf(address(this));

    require(amount > 0);



    _token.safeTransfer(_beneficiary, amount);

  }

}