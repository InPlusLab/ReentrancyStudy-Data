/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity ^0.4.24;





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



/**

 * @title TokenTimelock

 * @dev TokenTimelock is a token holder contract that will allow a

 * beneficiary to extract the tokens after a given release time

 */

contract TokenTimelock {

  



  // ERC20 basic token contract being held

  IERC20 private _token;



  // beneficiary of tokens after they are released

  address private _beneficiary;



  // timestamp when token release is enabled

  uint256 private _releaseTime;



  constructor()

    public

  {

    // solium-disable-next-line security/no-block-members

    _releaseTime = now + 365 days; 

    require(_releaseTime > block.timestamp);

    _token = IERC20(0x378725A3FB8458E9d39F097A83614E22f9a830F6);

    _beneficiary = 0x2dFe8bCAc2b8eF5dD60d02eDa4859a592C3bDdb2;

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



    _token.transferFrom(address(this), _beneficiary, amount);

  }

}