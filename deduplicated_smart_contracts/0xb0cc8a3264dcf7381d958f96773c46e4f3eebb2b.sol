/**
 *Submitted for verification at Etherscan.io on 2020-03-11
*/

pragma solidity ^0.4.24;


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
contract IConvertPortal {
  function isConvertibleToCOT(address _token, uint256 _amount)
  public
  view
  returns(uint256);

  function isConvertibleToETH(address _token, uint256 _amount)
  public
  view
  returns(uint256);

  function convertTokentoCOT(address _token, uint256 _amount)
  public
  payable
  returns (uint256 cotAmount);

  function convertTokentoCOTviaETH(address _token, uint256 _amount)
  public
  returns (uint256 cotAmount);
}
contract IStake {
  function addReserve(uint256 _amount) public;
}
/**
* This contract get 10% from CoTrader managers profit and then distributes assets
*
* 50% convert to COT and burn
* 25% convert to COT and send to stake reserve
* 25% to owner of this contract (CoTrader team)
*
* NOTE: 51% CoTrader token holders can change owner of this contract
*/









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


contract CoTraderDAOWallet is Ownable{
  using SafeMath for uint256;
  // COT address
  ERC20 public COT;
  // exchange portal for convert tokens to COT
  IConvertPortal public convertPortal;
  // stake contract
  IStake public stake;
  // array of voters
  address[] public voters;
  // voter => candidate
  mapping(address => address) public candidatesMap;
  // voter => register status
  mapping(address => bool) public votersMap;
  // this contract recognize ETH by this address
  ERC20 constant private ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
  // burn address
  address public deadAddress = address(0x000000000000000000000000000000000000dEaD);


  /**
  * @dev contructor
  *
  * @param _COT                           address of CoTrader ERC20
  * @param _stake                         address of Stake contract
  * @param _convertPortal                 address of exchange contract
  */
  constructor(address _COT, address _stake, address _convertPortal) public {
    COT = ERC20(_COT);
    stake = IStake(_stake);
    convertPortal = IConvertPortal(_convertPortal);
  }

  // send assets to burn address
  function _burn(ERC20 _token, uint256 _amount) private {
    uint256 cotAmount = (_token == COT)
    ? _amount
    : convertTokenToCOT(_token, _amount);
    if(cotAmount > 0)
      COT.transfer(deadAddress, cotAmount);
  }

  // send assets to stake contract
  function _stake(ERC20 _token, uint256 _amount) private {
    uint256 cotAmount = (_token == COT)
    ? _amount
    : convertTokenToCOT(_token, _amount);

    if(cotAmount > 0){
      COT.approve(address(stake), cotAmount);
      stake.addReserve(cotAmount);
    }
  }

  // send assets to owner
  function _withdraw(ERC20 _token, uint256 _amount) private {
    if(_amount > 0)
      if(_token == ETH_TOKEN_ADDRESS){
        address(owner).transfer(_amount);
      }else{
        _token.transfer(owner, _amount);
      }
  }

  /**
  * @dev destribute assest from this contract to stake, burn, and owner of this contract
  *
  * @param tokens                          array of token addresses for destribute
  */
  function destribute(ERC20[] tokens) {
   for(uint i = 0; i < tokens.length; i++){
      // get current token balance
      uint256 curentTokenTotalBalance = getTokenBalance(tokens[i]);
      // get 50% of balance
      uint256 burnAmount = curentTokenTotalBalance.div(2);
      // get 25% of balance
      uint256 stakeAndWithdrawAmount = burnAmount.div(2);

      // 50 burn
      _burn(tokens[i], burnAmount);
      // 25% stake
      _stake(tokens[i], stakeAndWithdrawAmount);
      // 25% to owner address
      _withdraw(tokens[i], stakeAndWithdrawAmount);
    }
  }

  // return balance of ERC20 or ETH for this contract
  function getTokenBalance(ERC20 _token) public view returns(uint256){
    if(_token == ETH_TOKEN_ADDRESS){
      return address(this).balance;
    }else{
      return _token.balanceOf(address(this));
    }
  }

  /**
  * @dev Owner can withdraw non convertible token if this token,
  * can't be converted to COT directly or to COT via ETH
  *
  *
  * @param _token                          address of token
  * @param _amount                         amount of token
  */
  function withdrawNonConvertibleERC(ERC20 _token, uint256 _amount) public onlyOwner {
    uint256 cotReturnAmount = convertPortal.isConvertibleToCOT(_token, _amount);
    uint256 ethReturnAmount = convertPortal.isConvertibleToETH(_token, _amount);

    require(_token != ETH_TOKEN_ADDRESS, "token can not be a ETH");
    require(cotReturnAmount == 0, "token can not be converted to COT");
    require(ethReturnAmount == 0, "token can not be converted to ETH");

    _token.transfer(owner, _amount);
  }


  /**
  * @dev this function try convert token to COT via DEXs which has COT in circulation
  * if there are no such pair on this COT supporting DEXs, function try convert to COT on another DEXs
  * via convert ERC20 input to ETH, and then ETH to COT on COT supporting DEXs.
  * If such a conversion is not possible return 0 for cotAmount
  *
  *
  * @param _token                          address of token
  * @param _amount                         amount of token
  */
  function convertTokenToCOT(address _token, uint256 _amount)
  private
  returns(uint256 cotAmount)
  {
    // try convert current token to COT
    uint256 cotReturnAmount = convertPortal.isConvertibleToCOT(_token, _amount);
    if(cotReturnAmount > 0) {
      if(ERC20(_token) == ETH_TOKEN_ADDRESS){
        cotAmount = convertPortal.convertTokentoCOT.value(_amount)(_token, _amount);
      }
      else{
        ERC20(_token).approve(address(convertPortal), _amount);
        cotAmount = convertPortal.convertTokentoCOT(_token, _amount);
      }
    }
    // try convert current token to COT via ETH
    else {
      uint256 ethReturnAmount = convertPortal.isConvertibleToETH(_token, _amount);
      if(ethReturnAmount > 0) {
        ERC20(_token).approve(address(convertPortal), _amount);
        cotAmount = convertPortal.convertTokentoCOTviaETH(_token, _amount);
      }
      // there are no way convert token to COT
      else{
        cotAmount = 0;
      }
    }
  }

  // owner can change version of exchange portal contract
  function changeConvertPortal(address _newConvertPortal)
  public
  onlyOwner
  {
    convertPortal = IConvertPortal(_newConvertPortal);
  }

  // any user can donate to stake reserve from msg.sender balance
  function addStakeReserveFromSender(uint256 _amount) public {
    require(COT.transferFrom(msg.sender, address(this), _amount));
    COT.approve(address(stake), _amount);
    stake.addReserve(_amount);
  }


  /*
  ** VOTE LOGIC
  *
  *  users can change owner if total COT balance of all voters for a certain candidate
  *  more than 50% of COT total supply
  *
  */

  // register a new vote wallet
  function voterRegister() public {
    require(!votersMap[msg.sender], "not allowed register the same wallet twice");
    // register a new wallet
    voters.push(msg.sender);
    votersMap[msg.sender] = true;
  }

  // vote for a certain candidate address
  function vote(address _candidate) public {
    require(votersMap[msg.sender], "wallet must be registered to vote");
    // vote for a certain candidate
    candidatesMap[msg.sender] = _candidate;
  }

  // return half of (total supply - burned balance)
  function calculateCOTHalfSupply() public view returns(uint256){
    uint256 supply = COT.totalSupply();
    uint256 burned = COT.balanceOf(deadAddress);
    return supply.sub(burned).div(2);
  }

  // calculate all vote subscribers for a certain candidate
  // return balance of COT of all voters of a certain candidate
  function calculateVoters(address _candidate)public view returns(uint256){
    uint256 count;
    for(uint i = 0; i<voters.length; i++){
      // take into account current voter balance
      // if this user voted for current candidate
      if(_candidate == candidatesMap[voters[i]]){
          count = count.add(COT.balanceOf(voters[i]));
      }
    }
    return count;
  }

  // Any user can change owner with a certain candidate
  // if this candidate address have 51% voters
  function changeOwner(address _newOwner) public {
    // get vote data
    uint256 totalVotersBalance = calculateVoters(_newOwner);
    // get half of COT supply in market circulation
    uint256 totalCOT = calculateCOTHalfSupply();
    // require 51% COT on voters balance
    require(totalVotersBalance > totalCOT);
    // change owner
    super._transferOwnership(_newOwner);
  }

  // fallback payable function to receive ether from other contract addresses
  function() public payable {}
}