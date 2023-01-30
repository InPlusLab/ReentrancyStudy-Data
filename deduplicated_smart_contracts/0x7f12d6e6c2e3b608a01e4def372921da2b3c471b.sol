/**

 *Submitted for verification at Etherscan.io on 2018-11-18

*/



pragma solidity ^0.4.24;



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



// File: contracts\FreeDropper.sol



interface ERC20 {

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function approve(address _spender, uint256 _value) public returns (bool);

    function transfer(address _to, uint256 _value) public returns (bool);

}



contract FreeDropper is Ownable {



    event DistributionCompleted(address indexed from, address indexed token, uint totalAmount);

    

    using SafeMath for uint;



    function drop(ERC20 _token, address[] _beneficiary, uint[] _amount, uint _totalAmount) external payable {

        require(_beneficiary.length == _amount.length, "beneficiary and amount length do not match");



        require(_token.allowance(msg.sender, address(this)) >= _totalAmount, "not enough allowance");

        uint distributedTokens;

        

        for(uint i = 0;i < _beneficiary.length;i++){

            

            require(_beneficiary[i] != address(0), "beneficiary address is 0x0");

            require(_token.transferFrom(msg.sender,_beneficiary[i],_amount[i]), "Transfer from failed");

            distributedTokens += _amount[i];

        }



        emit DistributionCompleted(msg.sender, address(_token), _totalAmount);

            

    }



    function withdrawTokens(ERC20 _erc20, address _receiver, uint _amount) public onlyOwner {

        require(_receiver != address(0x0), "receiver address is 0x0");

        _erc20.transfer(_receiver, _amount);

    }



    function withdrawETH(address _receiver, uint _amount) public onlyOwner {

        _receiver.transfer(_amount);

    }



}