/**

 *Submitted for verification at Etherscan.io on 2018-11-20

*/



pragma solidity ^0.4.18;



pragma solidity ^0.4.18;



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

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address private _owner;



  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() internal {

    _owner = msg.sender;

    emit OwnershipTransferred(address(0), _owner);

  }



  /**

   * @return the address of the owner.

   */

  function owner() public view returns(address) {

    return _owner;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(isOwner());

    _;

  }



  /**

   * @return true if `msg.sender` is the owner of the contract.

   */

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipTransferred(_owner, address(0));

    _owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));

    emit OwnershipTransferred(_owner, newOwner);

    _owner = newOwner;

  }

}



contract CSFToken is Ownable, ERC20Basic {

  using SafeMath for uint256;



  string public constant name     = "Crypto Service Fund Token";

  string public constant symbol   = "CSFT";

  uint8  public constant decimals = 18;



  bool public mintingFinished = false;



  mapping(address => uint256) public balances;

  address[] public holders;



  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  /**

  * @dev Function to mint tokens

  * @param _to The address that will receive the minted tokens.

  * @param _amount The amount of tokens to mint.

  * @return A boolean that indicates if the operation was successful.

  */

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    totalSupply = totalSupply.add(_amount);

    if (balances[_to] == 0) { 

      holders.push(_to);

    }

    balances[_to] = balances[_to].add(_amount);



    Mint(_to, _amount);

    Transfer(address(0), _to, _amount);

    return true;

  }



  /**

  * @dev Function to stop minting new tokens.

  * @return True if the operation was successful.

  */

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;

    MintFinished();

    return true;

  }



  /**

  * @dev Current token is not transferred.

  * After start official token sale CSFT, you can exchange your tokens

  */

  function transfer(address, uint256) public returns (bool) {

    revert();

    return false;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];

  }



  modifier canMint() {

    require(!mintingFinished);

    _;

  }

}



/**

 * @title Crowdsale CSFT token

 */



contract Crowdsale is Ownable {

  using SafeMath for uint256;



  uint256   public constant rate = 1000;                  // How many token units a buyer gets per wei

  uint256   public constant cap = 1000000 ether;          // Maximum amount of funds



  bool      public isFinalized = false;



  uint256   public endTime = 1548979199;                   // End timestamps where investments are allowed

                                                           // 31-Jan-19 23:59:59 UTC



  CSFToken     public token;                                // CSFT token itself

  address       public wallet;                              // Wallet of funds

  uint256       public weiRaised;                           // Amount of raised money in wei



  uint256   public firstBonus = 30;

  uint256   public secondBonus = 50;



  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  event Finalized();



  function Crowdsale (CSFToken _CSFT, address _wallet) public {

    assert(address(_CSFT) != address(0));

    assert(_wallet != address(0));

    assert(endTime > now);

    assert(rate > 0);

    assert(cap > 0);



    token = _CSFT;



    wallet = _wallet;

  }



  function () public payable {

    buyTokens(msg.sender);

  }



  function buyTokens(address beneficiary) public payable {

    require(beneficiary != address(0));

    require(validPurchase());



    uint256 weiAmount = msg.value;

    uint256 tokens = tokensForWei(weiAmount);

    

    weiRaised = weiRaised.add(weiAmount);



    token.mint(beneficiary, tokens);

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);



    forwardFunds();

  }



  function getBonus(uint256 _tokens, uint256 _weiAmount) public view returns (uint256) {

    if (_weiAmount >= 30 ether) {

      return _tokens.mul(secondBonus).div(100);

    }

    return _tokens.mul(firstBonus).div(100);

  }



  function setFirstBonus(uint256 _newBonus) onlyOwner public {

    firstBonus = _newBonus;

  }



  function setSecondBonus(uint256 _newBonus) onlyOwner public {

    secondBonus = _newBonus;

  }



  function changeEndTime(uint256 _endTime) onlyOwner public {

    require(_endTime >= now);

    endTime = _endTime;

  }

  

  /**

   * @dev Calls the contract's finalization function.

   */

  function finalize() onlyOwner public {

    require(!isFinalized);



    finalization();

    Finalized();



    isFinalized = true;

  }



  // send ether to the fund collection wallet

  // override to create custom fund forwarding mechanisms

  function forwardFunds() internal {

    wallet.transfer(msg.value);

  }



  // @return true if the transaction can buy tokens

  function validPurchase() internal view returns (bool) {

    bool tokenMintingFinished = token.mintingFinished();

    bool withinCap = token.totalSupply().add(tokensForWei(msg.value)) <= cap;

    bool withinPeriod = now <= endTime;

    bool nonZeroPurchase = msg.value != 0;

    bool moreThanMinimumPayment = msg.value >= 0.1 ether;



    return !tokenMintingFinished && withinCap && withinPeriod && nonZeroPurchase && moreThanMinimumPayment;

  }



  function tokensForWei(uint weiAmount) public view returns (uint tokens) {

    tokens = weiAmount.mul(rate);

    tokens = tokens.add(getBonus(tokens, weiAmount));

  }



  function finalization() internal {

    token.finishMinting();

    endTime = now;

  }



  // @return true if crowdsale event has ended

  function hasEnded() public view returns (bool) {

    return now > endTime;

  }



}