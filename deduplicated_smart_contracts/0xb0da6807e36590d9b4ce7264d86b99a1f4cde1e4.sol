/**

 *Submitted for verification at Etherscan.io on 2018-12-21

*/



pragma solidity ^0.4.13;



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



library SafeERC20 {



  using SafeMath for uint256;



  function safeTransfer(

    IERC20 token,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transfer(to, value));

  }



  function safeTransferFrom(

    IERC20 token,

    address from,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transferFrom(from, to, value));

  }



  function safeApprove(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    // safeApprove should only be called when setting an initial allowance, 

    // or when resetting it to zero. To increase and decrease it, use 

    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'

    require((value == 0) || (token.allowance(msg.sender, spender) == 0));

    require(token.approve(spender, value));

  }



  function safeIncreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).add(value);

    require(token.approve(spender, newAllowance));

  }



  function safeDecreaseAllowance(

    IERC20 token,

    address spender,

    uint256 value

  )

    internal

  {

    uint256 newAllowance = token.allowance(address(this), spender).sub(value);

    require(token.approve(spender, newAllowance));

  }

}



contract TokenTimelock {

  using SafeERC20 for IERC20;



  // ERC20 basic token contract being held

  IERC20 private _token;



  // beneficiary of tokens after they are released

  address private _beneficiary;



  // timestamp when token release is enabled

  uint256 private _releaseTime;



  constructor(

    IERC20 token,

    address beneficiary,

    uint256 releaseTime

  )

    public

  {

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



contract LoomTimelockFactory {



    IERC20 loom;

    event LoomTimeLockCreated(address validatorEthAddress, address timelockContractAddress, string validatorName, string validatorPublicKey, uint256 _amount, uint256 _releaseTime);



    constructor(IERC20 _loom) public { loom = _loom; }



    function deployTimeLock(address validatorEthAddress, string validatorName, string validatorPublicKey, uint256 amount, uint256 duration) public {

        // Deploy timelock

        TokenTimelock timelock = new TokenTimelock(loom, validatorEthAddress, block.timestamp + duration);



        // Ensure it got an address

        require(address(timelock) != address(0x0));



        // Send funds to timelock. -- MUST APPROVE FIRST

        loom.transferFrom(msg.sender, address(timelock), amount);



        emit LoomTimeLockCreated(validatorEthAddress, address(timelock), validatorName, validatorPublicKey, amount, block.timestamp + duration);

    }

}