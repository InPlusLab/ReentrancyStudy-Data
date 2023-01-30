/**

 *Submitted for verification at Etherscan.io on 2018-11-15

*/



/**

 * Copyright (c) 2018 blockimmo AG [email protected]

 * Non-Profit Open Software License 3.0 (NPOSL-3.0)

 * https://opensource.org/licenses/NPOSL-3.0

 */

 



pragma solidity 0.4.25; 





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





/**

 * @title SplitPayment

 * @dev Base contract that supports multiple payees claiming funds sent to this contract

 * according to the proportion they own.

 */

contract SplitPayment {

  using SafeMath for uint256;



  uint256 public totalShares = 0;

  uint256 public totalReleased = 0;



  mapping(address => uint256) public shares;

  mapping(address => uint256) public released;

  address[] public payees;



  /**

   * @dev Constructor

   */

  constructor(address[] _payees, uint256[] _shares) public payable {

    require(_payees.length == _shares.length);



    for (uint256 i = 0; i < _payees.length; i++) {

      addPayee(_payees[i], _shares[i]);

    }

  }



  /**

   * @dev payable fallback

   */

  function () external payable {}



  /**

   * @dev Claim your share of the balance.

   */

  function claim() public {

    address payee = msg.sender;



    require(shares[payee] > 0);



    uint256 totalReceived = address(this).balance.add(totalReleased);

    uint256 payment = totalReceived.mul(

      shares[payee]).div(

        totalShares).sub(

          released[payee]

    );



    require(payment != 0);

    require(address(this).balance >= payment);



    released[payee] = released[payee].add(payment);

    totalReleased = totalReleased.add(payment);



    payee.transfer(payment);

  }





  /**

   * @dev Add a new payee to the contract.

   * @param _payee The address of the payee to add.

   * @param _shares The number of shares owned by the payee.

   */

  function addPayee(address _payee, uint256 _shares) internal {

    require(_payee != address(0));

    require(_shares > 0);

    require(shares[_payee] == 0);



    payees.push(_payee);

    shares[_payee] = _shares;

    totalShares = totalShares.add(_shares);

  }

}





contract Payments is Ownable, SplitPayment {

  constructor() public SplitPayment(new address[](0), new uint256[](0)) { }



  function addPayment(address _payee, uint256 _amount) public onlyOwner {

    addPayee(_payee, _amount);

  }

}