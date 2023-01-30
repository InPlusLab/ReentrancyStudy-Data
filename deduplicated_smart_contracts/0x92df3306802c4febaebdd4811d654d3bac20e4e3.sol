/**

 *Submitted for verification at Etherscan.io on 2019-02-19

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(

    ERC20Basic _token,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transfer(_to, _value));

  }



  function safeTransferFrom(

    ERC20 _token,

    address _from,

    address _to,

    uint256 _value

  )

    internal

  {

    require(_token.transferFrom(_from, _to, _value));

  }



  function safeApprove(

    ERC20 _token,

    address _spender,

    uint256 _value

  )

    internal

  {

    require(_token.approve(_spender, _value));

  }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

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

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



// File: eth-token-recover/contracts/TokenRecover.sol



/**

 * @title TokenRecover

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Allow to recover any ERC20 sent into the contract for error

 */

contract TokenRecover is Ownable {



  /**

   * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.

   * @param _tokenAddress address The token contract address

   * @param _tokens Number of tokens to be sent

   * @return bool

   */

  function recoverERC20(

    address _tokenAddress,

    uint256 _tokens

  )

  public

  onlyOwner

  returns (bool success)

  {

    return ERC20Basic(_tokenAddress).transfer(owner, _tokens);

  }

}



// File: contracts/token/GroupForkTimelock.sol



/**

 * @title GroupForkTimelock

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev GroupForkTimelock is a token holder contract that will allow a

 * group of beneficiaries to extract the tokens after a given release time

 */

contract GroupForkTimelock is TokenRecover {

  using SafeMath for uint256;

  using SafeERC20 for ERC20Basic;



  // ERC20 basic token contract being held

  ERC20Basic public token;



  // number of totals locked tokens

  uint256 public lockedTokens;



  // beneficiaries of tokens after they are released

  address[] public accounts;



  // amounts of tokens for each beneficiary

  mapping(address => uint256) public reservedTokens;



  // map of address and received token amount

  mapping (address => uint256) public receivedTokens;



  // timestamp when token release is enabled

  uint256 public releaseTime;



  constructor(

    ERC20Basic _token,

    address[] _accounts,

    uint256[] _amounts,

    uint256 _releaseTime

  )

    public

  {

    // solium-disable-next-line security/no-block-members

    require(_releaseTime > block.timestamp);

    require(_accounts.length > 0);

    require(_amounts.length > 0);

    require(_accounts.length == _amounts.length);



    token = _token;

    accounts = _accounts;

    releaseTime = _releaseTime;



    for (uint i = 0; i < accounts.length; i++) {

      address account = accounts[i];

      uint256 amount = _amounts[i];



      reservedTokens[account] = amount;

      lockedTokens = lockedTokens.add(amount);

    }

  }



  /**

   * @notice Transfers tokens held by timelock to beneficiaries.

   */

  function release() public {

    // solium-disable-next-line security/no-block-members

    require(block.timestamp >= releaseTime);



    uint256 balance = token.balanceOf(address(this));

    require(balance == lockedTokens);



    for (uint i = 0; i < accounts.length; i++) {

      address account = accounts[i];

      uint256 amount = reservedTokens[account];



      if (receivedTokens[account] == 0) {

        receivedTokens[account] = receivedTokens[account].add(amount);

        token.safeTransfer(account, amount);

      }

    }

  }

}