pragma solidity 0.4.19;



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;



  /**

  * @dev total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



    // SafeMath.sub will throw if there is not enough balance.

    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];

  }



}

contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   *

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   *

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}

contract Ownable {

  address public owner;



  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() public {

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

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));

    OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}

contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();



  bool public mintingFinished = false;





  modifier canMint() {

    require(!mintingFinished);

    _;

  }



  /**

   * @dev Function to mint tokens

   * @param _to The address that will receive the minted tokens.

   * @param _amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    totalSupply_ = totalSupply_.add(_amount);

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

}



contract CappedToken is MintableToken {



  uint256 public cap;



  function CappedToken(uint256 _cap) public {

    require(_cap > 0);

    cap = _cap;

  }



  /**

   * @dev Function to mint tokens

   * @param _to The address that will receive the minted tokens.

   * @param _amount The amount of tokens to mint.

   * @return A boolean that indicates if the operation was successful.

   */

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    require(totalSupply_.add(_amount) <= cap);



    return super.mint(_to, _amount);

  }



}

contract TokenTimelock {

  using SafeERC20 for ERC20Basic;



  // ERC20 basic token contract being held

  ERC20Basic public token;



  // beneficiary of tokens after they are released

  address public beneficiary;



  // timestamp when token release is enabled

  uint256 public releaseTime;



  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {

    require(_releaseTime > now);

    token = _token;

    beneficiary = _beneficiary;

    releaseTime = _releaseTime;

  }



  /**

   * @notice Transfers tokens held by timelock to beneficiary.

   */

  function release() public {

    require(now >= releaseTime);



    uint256 amount = token.balanceOf(this);

    require(amount > 0);



    token.safeTransfer(beneficiary, amount);

  }

}

contract TokenVesting is Ownable {

  using SafeMath for uint256;

  using SafeERC20 for ERC20Basic;



  event Released(uint256 amount);

  event Revoked();



  // beneficiary of tokens after they are released

  address public beneficiary;



  uint256 public cliff;

  uint256 public start;

  uint256 public duration;



  bool public revocable;



  mapping (address => uint256) public released;

  mapping (address => bool) public revoked;



  /**

   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the

   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all

   * of the balance will have vested.

   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred

   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest

   * @param _duration duration in seconds of the period in which the tokens will vest

   * @param _revocable whether the vesting is revocable or not

   */

  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {

    require(_beneficiary != address(0));

    require(_cliff <= _duration);



    beneficiary = _beneficiary;

    revocable = _revocable;

    duration = _duration;

    cliff = _start.add(_cliff);

    start = _start;

  }



  /**

   * @notice Transfers vested tokens to beneficiary.

   * @param token ERC20 token which is being vested

   */

  function release(ERC20Basic token) public {

    uint256 unreleased = releasableAmount(token);



    require(unreleased > 0);



    released[token] = released[token].add(unreleased);



    token.safeTransfer(beneficiary, unreleased);



    Released(unreleased);

  }



  /**

   * @notice Allows the owner to revoke the vesting. Tokens already vested

   * remain in the contract, the rest are returned to the owner.

   * @param token ERC20 token which is being vested

   */

  function revoke(ERC20Basic token) public onlyOwner {

    require(revocable);

    require(!revoked[token]);



    uint256 balance = token.balanceOf(this);



    uint256 unreleased = releasableAmount(token);

    uint256 refund = balance.sub(unreleased);



    revoked[token] = true;



    token.safeTransfer(owner, refund);



    Revoked();

  }



  /**

   * @dev Calculates the amount that has already vested but hasn't been released yet.

   * @param token ERC20 token which is being vested

   */

  function releasableAmount(ERC20Basic token) public view returns (uint256) {

    return vestedAmount(token).sub(released[token]);

  }



  /**

   * @dev Calculates the amount that has already vested.

   * @param token ERC20 token which is being vested

   */

  function vestedAmount(ERC20Basic token) public view returns (uint256) {

    uint256 currentBalance = token.balanceOf(this);

    uint256 totalBalance = currentBalance.add(released[token]);



    if (now < cliff) {

      return 0;

    } else if (now >= start.add(duration) || revoked[token]) {

      return totalBalance;

    } else {

      return totalBalance.mul(now.sub(start)).div(duration);

    }

  }

}

contract NebulaToken is CappedToken{

    using SafeMath for uint256;

    string public constant name = "Nebula AI Token";

    string public constant symbol = "NBAI";

    uint8 public constant decimals = 18;



    bool public pvt_plmt_set;

    uint256 public pvt_plmt_max_in_Wei;

    uint256 public pvt_plmt_remaining_in_Wei;

    uint256 public pvt_plmt_token_generated;



    TokenVesting public foundation_vesting_contract;

    uint256 public token_unlock_time = 1524887999; //April 27th 2018 23:59:59 GMT-4:00, 7 days after completion



    mapping(address => TokenTimelock[]) public time_locked_reclaim_addresses;



    //vesting starts on April 21th 2018 00:00 GMT-4:00

    //vesting duration is 3 years

    function NebulaToken() CappedToken(6700000000 * 1 ether) public{

        uint256 foundation_held = cap.mul(55).div(100);//55% fixed for early investors, partners, nebula internal and foundation

        address foundation_beneficiary_wallet = 0xD86FCe1890bf98fC086b264a66cA96C7E3B03B40;//multisig wallet

        foundation_vesting_contract = new TokenVesting(foundation_beneficiary_wallet, 1524283200, 0, 3 years, false);

        assert(mint(foundation_vesting_contract, foundation_held));

        FoundationTokenGenerated(foundation_vesting_contract, foundation_beneficiary_wallet, foundation_held);

    }



    //Crowdsale contract mints and stores tokens in time locked contracts during crowdsale.

    //Ownership is transferred back to the owner of crowdsale contract once crowdsale is finished(finalize())

    function create_public_sale_token(address _beneficiary, uint256 _token_amount) external onlyOwner returns(bool){

        assert(mint_time_locked_token(_beneficiary, _token_amount) != address(0));

        return true;

    }



    //@dev Can only set once

    function set_private_sale_total(uint256 _pvt_plmt_max_in_Wei) external onlyOwner returns(bool){

        require(!pvt_plmt_set && _pvt_plmt_max_in_Wei >= 5000 ether);//_pvt_plmt_max_in_wei is minimum the soft cap

        pvt_plmt_set = true;

        pvt_plmt_max_in_Wei = _pvt_plmt_max_in_Wei;

        pvt_plmt_remaining_in_Wei = pvt_plmt_max_in_Wei;

        PrivateSalePlacementLimitSet(pvt_plmt_max_in_Wei);

    }

    /**

     * Private sale distributor

     * private sale total is set once, irreversible and not modifiable

     * Once this amount in wei is reduced to 0, no more token can be generated as private sale!

     * Maximum token generated by private sale is pvt_plmt_max_in_Wei * 125000 (discount upper limit)

     * Note 1, Private sale limit is the balance of private sale fond wallet balance as of 23:59 UTC March 29th 2019

     * Note 2, no ether is transferred to neither the crowdsale contract nor this one for private sale

     * totalSupply_ = pvt_plmt_token_generated + foundation_held + weiRaised * 100000

     * _beneficiary: private sale buyer address

     * _wei_amount: amount in wei that the buyer bought

     * _rate: rate that the private sale buyer has agreed with NebulaAi

     */

    function distribute_private_sale_fund(address _beneficiary, uint256 _wei_amount, uint256 _rate) public onlyOwner returns(bool){

        require(pvt_plmt_set && _beneficiary != address(0) && pvt_plmt_remaining_in_Wei >= _wei_amount && _rate >= 100000 && _rate <= 125000);



        pvt_plmt_remaining_in_Wei = pvt_plmt_remaining_in_Wei.sub(_wei_amount);//remove from limit

        uint256 _token_amount = _wei_amount.mul(_rate); //calculate token amount to be generated

        pvt_plmt_token_generated = pvt_plmt_token_generated.add(_token_amount);//add generated amount to total private sale token



        //Mint token if unlocked time has been reached, directly mint to beneficiary, else create time locked contract

        address _ret;

        if(now < token_unlock_time) assert((_ret = mint_time_locked_token(_beneficiary, _token_amount))!=address(0));

        else assert(mint(_beneficiary, _token_amount));



        PrivateSaleTokenGenerated(_ret, _beneficiary, _token_amount);

        return true;

    }

    //used for private and public sale to create time locked contract before lock release time

    //Note: TokenTimelock constructor will throw after token unlock time is reached

    function mint_time_locked_token(address _beneficiary, uint256 _token_amount) internal returns(TokenTimelock _locked){

        _locked = new TokenTimelock(this, _beneficiary, token_unlock_time);

        time_locked_reclaim_addresses[_beneficiary].push(_locked);

        assert(mint(_locked, _token_amount));

    }



    //Release all tokens held by time locked contracts to the beneficiary address stored in the contract

    //Note: requirement is checked in time lock contract

    function release_all(address _beneficiary) external returns(bool){

        require(time_locked_reclaim_addresses[_beneficiary].length > 0);

        TokenTimelock[] memory _locks = time_locked_reclaim_addresses[_beneficiary];

        for(uint256 i = 0 ; i < _locks.length; ++i) _locks[i].release();

        return true;

    }



    //override to add a checker

    function finishMinting() onlyOwner canMint public returns (bool){

        require(pvt_plmt_set && pvt_plmt_remaining_in_Wei == 0);

        super.finishMinting();

    }



    function get_time_locked_contract_size(address _owner) external view returns(uint256){

        return time_locked_reclaim_addresses[_owner].length;

    }



    event PrivateSaleTokenGenerated(address indexed _time_locked, address indexed _beneficiary, uint256 _amount);

    event FoundationTokenGenerated(address indexed _vesting, address indexed _beneficiary, uint256 _amount);

    event PrivateSalePlacementLimitSet(uint256 _limit);

    function () public payable{revert();}//This contract is not payable

}

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  /**

  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    assert(token.transfer(to, value));

  }



  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {

    assert(token.transferFrom(from, to, value));

  }



  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    assert(token.approve(spender, value));

  }

}