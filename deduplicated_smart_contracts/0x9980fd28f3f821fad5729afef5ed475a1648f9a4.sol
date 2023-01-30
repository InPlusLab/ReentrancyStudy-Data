/**

 *Submitted for verification at Etherscan.io on 2018-10-26

*/



contract Crowdsale {

  using SafeMath for uint256;

  using SafeERC20 for ERC20;



  // The token being sold

  ERC20 public token;



  // Address where funds are collected

  address public wallet;



  // How many token units a buyer gets per wei.

  // The rate is the conversion between wei and the smallest and indivisible token unit.

  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK

  // 1 wei will give you 1 unit, or 0.001 TOK.

  uint256 public rate;



  // Amount of wei raised

  uint256 public weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param amount amount of tokens purchased

   */

  event TokenPurchase(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 amount

  );



  /**

   * @param _rate Number of token units a buyer gets per wei

   * @param _wallet Address where collected funds will be forwarded to

   * @param _token Address of the token being sold

   */

  constructor(uint256 _rate, address _wallet, ERC20 _token) public {

    require(_rate > 0);

    require(_wallet != address(0));

    require(_token != address(0));



    rate = _rate;

    wallet = _wallet;

    token = _token;

  }



  // -----------------------------------------

  // Crowdsale external interface

  // -----------------------------------------



  /**

   * @dev fallback function ***DO NOT OVERRIDE***

   */

  function () external payable {

    buyTokens(msg.sender);

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   * @param _beneficiary Address performing the token purchase

   */

  function buyTokens(address _beneficiary) public payable {



    uint256 weiAmount = msg.value;

    _preValidatePurchase(_beneficiary, weiAmount);



    // calculate token amount to be created

    uint256 tokens = _getTokenAmount(weiAmount);



    // update state

    weiRaised = weiRaised.add(weiAmount);



    _processPurchase(_beneficiary, tokens);

    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      tokens

    );



    _updatePurchasingState(_beneficiary, weiAmount);



    _forwardFunds();

    _postValidatePurchase(_beneficiary, weiAmount);

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.

   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 

   *   super._preValidatePurchase(_beneficiary, _weiAmount);

   *   require(weiRaised.add(_weiAmount) <= cap);

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    require(_beneficiary != address(0));

    require(_weiAmount != 0);

  }



  /**

   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.

   * @param _beneficiary Address performing the token purchase

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _postValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.

   * @param _beneficiary Address performing the token purchase

   * @param _tokenAmount Number of tokens to be emitted

   */

  function _deliverTokens(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    token.safeTransfer(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.

   * @param _beneficiary Address receiving the tokens

   * @param _tokenAmount Number of tokens to be purchased

   */

  function _processPurchase(

    address _beneficiary,

    uint256 _tokenAmount

  )

    internal

  {

    _deliverTokens(_beneficiary, _tokenAmount);

  }



  /**

   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)

   * @param _beneficiary Address receiving the tokens

   * @param _weiAmount Value in wei involved in the purchase

   */

  function _updatePurchasingState(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    // optional override

  }



  /**

   * @dev Override to extend the way in which ether is converted to tokens.

   * @param _weiAmount Value in wei to be converted into tokens

   * @return Number of tokens that can be purchased with the specified _weiAmount

   */

  function _getTokenAmount(uint256 _weiAmount)

    internal view returns (uint256)

  {

    return _weiAmount.mul(rate);

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    wallet.transfer(msg.value);

  }

}



contract CappedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 public cap;



  /**

   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.

   * @param _cap Max amount of wei to be contributed

   */

  constructor(uint256 _cap) public {

    require(_cap > 0);

    cap = _cap;

  }



  /**

   * @dev Checks whether the cap has been reached.

   * @return Whether the cap was reached

   */

  function capReached() public view returns (bool) {

    return weiRaised >= cap;

  }



  /**

   * @dev Extend parent behavior requiring purchase to respect the funding cap.

   * @param _beneficiary Token purchaser

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

    require(weiRaised.add(_weiAmount) <= cap);

  }



}



contract TimedCrowdsale is Crowdsale {

  using SafeMath for uint256;



  uint256 public openingTime;

  uint256 public closingTime;



  /**

   * @dev Reverts if not in crowdsale time range.

   */

  modifier onlyWhileOpen {

    // solium-disable-next-line security/no-block-members

    require(block.timestamp >= openingTime && block.timestamp <= closingTime);

    _;

  }



  /**

   * @dev Constructor, takes crowdsale opening and closing times.

   * @param _openingTime Crowdsale opening time

   * @param _closingTime Crowdsale closing time

   */

  constructor(uint256 _openingTime, uint256 _closingTime) public {

    // solium-disable-next-line security/no-block-members

    require(_openingTime >= block.timestamp);

    require(_closingTime >= _openingTime);



    openingTime = _openingTime;

    closingTime = _closingTime;

  }



  /**

   * @dev Checks whether the period in which the crowdsale is open has already elapsed.

   * @return Whether crowdsale period has elapsed

   */

  function hasClosed() public view returns (bool) {

    // solium-disable-next-line security/no-block-members

    return block.timestamp > closingTime;

  }



  /**

   * @dev Extend parent behavior requiring to be within contributing period

   * @param _beneficiary Token purchaser

   * @param _weiAmount Amount of wei contributed

   */

  function _preValidatePurchase(

    address _beneficiary,

    uint256 _weiAmount

  )

    internal

    onlyWhileOpen

  {

    super._preValidatePurchase(_beneficiary, _weiAmount);

  }



}



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



contract FinalizableCrowdsale is Ownable, TimedCrowdsale {

  using SafeMath for uint256;



  bool public isFinalized = false;



  event Finalized();



  /**

   * @dev Must be called after crowdsale ends, to do some extra finalization

   * work. Calls the contract's finalization function.

   */

  function finalize() public onlyOwner {

    require(!isFinalized);

    require(hasClosed());



    finalization();

    emit Finalized();



    isFinalized = true;

  }



  /**

   * @dev Can be overridden to add finalization logic. The overriding function

   * should call super.finalization() to ensure the chain of finalization is

   * executed entirely.

   */

  function finalization() internal {

  }



}



contract NeuronxCoinPreSale is CappedCrowdsale, TimedCrowdsale, FinalizableCrowdsale {

    using SafeMath for uint;



    uint8 public constant decimals = 8;

    uint256 public constant minDeposit = 10000 * (10 ** uint256(decimals)); // tokens ~ 1000 usd



    uint256 public tokensSold = 0;



    // uint256 cap = 12.000.000 * 1e8;

    // uint256 rate = 2000;



    uint256 public tokenConstant;



    // next stage for transfer remaining tokens

    NeuronxCoinSaleOne public next_stage;

    NeuronxCoin token;



    constructor(

        uint _start,

        uint _end,

        uint _cap,

        uint _rate,

        NeuronxCoin _token,

        NeuronxCoinSaleOne _next_stage,

        address _owner

    ) public

        Crowdsale(_rate, _owner, _token)

        CappedCrowdsale(_cap)

        TimedCrowdsale(_start, _end)

    {

        token = _token;

        next_stage = _next_stage;

        tokenConstant = (10 ** uint256(decimals)).div(_rate);

    }



    function _checkMinLimit(uint256 tokenAmount) internal {

        require(tokenAmount >= minDeposit);

    }



    function _checkAvailableTokens(uint256 tokenAmount) internal {

        require(tokensSold.add(tokenAmount) <= cap);

    }



    function _validatePurchase(address _beneficiary, uint256 _weiAmount) internal {

        require(_beneficiary != address(0));

        require(_weiAmount != 0);

    }



    function getWeiAmount(uint256 _tokenAmount)

        public view returns (uint256)

    {

        return _tokenAmount.mul(tokenConstant);

    }



    function getTokenAmount(uint256 _weiAmount)

        public view returns (uint256)

    {

        return _weiAmount.div(tokenConstant);

    }



    function buyTokens(address _beneficiary) public onlyWhileOpen payable {

        uint256 weiAmount = msg.value;

        _validatePurchase(_beneficiary, weiAmount);



        uint256 tokenAmount = getTokenAmount(weiAmount);

        _checkAvailableTokens(tokenAmount);

        _checkMinLimit(tokenAmount);



        weiRaised = weiRaised.add(weiAmount);

        tokensSold = tokensSold.add(tokenAmount);



        token.transfer(_beneficiary, tokenAmount);



        emit TokenPurchase(

            msg.sender,

            _beneficiary,

            weiAmount,

            tokenAmount

        );

    }



    function() external payable {

        buyTokens(msg.sender);

    }



    function finalization() internal {

        super.finalization();



        uint256 amount = token.balanceOf(this);

        if (amount > 0) {

            token.transfer(next_stage, amount);

        }

    }

}



contract NeuronxCoinSaleOne is CappedCrowdsale, TimedCrowdsale, FinalizableCrowdsale {

    using SafeMath for uint;



    uint8 public constant decimals = 8;

    uint256 public constant minDeposit = 3333 * (10 ** uint256(decimals)); // tokens ~ 500 usd



    uint256 public tokensSold = 0;



    // uint256 cap = 40.000.000 * 1e8;

    // uint256 rate = 1333;



    uint256 public tokenConstant;



    bool isCapUpdated = false;

    NeuronxCoinSaleTwo public next_stage;

    NeuronxCoin token;



    constructor(

        uint _start,

        uint _end,

        uint _cap,

        uint _rate,

        NeuronxCoin _token,

        NeuronxCoinSaleTwo _next_stage,

        address _owner

    ) public

        Crowdsale(_rate, _owner, _token)

        CappedCrowdsale(_cap)

        TimedCrowdsale(_start, _end)

    {

        token = _token;

        next_stage = _next_stage;

        tokenConstant = (10 ** uint256(decimals)).div(_rate);

    }



    function _checkMinLimit(uint256 tokenAmount) internal {

        require(tokenAmount >= minDeposit);

    }



    function _checkAvailableTokens(uint256 tokenAmount) internal {

        require(tokensSold.add(tokenAmount) <= cap);

    }



    function _validatePurchase(address _beneficiary, uint256 _weiAmount) internal {

        require(_beneficiary != address(0));

        require(_weiAmount != 0);

    }



    function getWeiAmount(uint256 _tokenAmount)

        public view returns (uint256)

    {

        return _tokenAmount.mul(tokenConstant);

    }



    function getTokenAmount(uint256 _weiAmount)

        public view returns (uint256)

    {

        return _weiAmount.div(tokenConstant);

    }



    function buyTokens(address _beneficiary) public onlyWhileOpen payable {

        uint256 weiAmount = msg.value;

        _validatePurchase(_beneficiary, weiAmount);



        uint256 tokenAmount = getTokenAmount(weiAmount);

        _checkAvailableTokens(tokenAmount);

        _checkMinLimit(tokenAmount);



        weiRaised = weiRaised.add(weiAmount);

        tokensSold = tokensSold.add(tokenAmount);



        token.transfer(_beneficiary, tokenAmount);



        emit TokenPurchase(

            msg.sender,

            _beneficiary,

            weiAmount,

            tokenAmount

        );

    }



    function() external payable {

        buyTokens(msg.sender);

    }



    function finalization() internal {

        super.finalization();



        uint256 amount = token.balanceOf(this);

        if (amount > 0) {

            token.transfer(next_stage, amount);

        }

    }



    modifier isCapNotUpdated() {

        require(isCapUpdated == false);

        _;

    }



    function updateCap() public onlyOwner isCapNotUpdated {

        uint currentBalance = token.balanceOf(this);

        uint remainingTokens = currentBalance.sub(cap);

        cap = cap.add(remainingTokens);

        isCapUpdated = true;

    }

}



contract NeuronxCoinSaleTwo is CappedCrowdsale, TimedCrowdsale, FinalizableCrowdsale {

    using SafeMath for uint;



    uint8 public constant decimals = 8;

    uint256 public minDeposit = 1000 * (10 ** uint256(decimals)); // tokens ~ 200 usd



    uint256 public tokensSold = 0;



    // uint256 cap = 52.000.000 * 1e8;

    // uint256 rate = 1000;



    uint256 public tokenConstant;



    bool isCapUpdated = false;

    NeuronxCoin token;



    constructor(

        uint _start,

        uint _end,

        uint _cap,

        uint _rate,

        NeuronxCoin _token,

        address _owner

    ) public

        Crowdsale(_rate, _owner, _token)

        CappedCrowdsale(_cap)

        TimedCrowdsale(_start, _end)

    {

        token = _token;

        tokenConstant = (10 ** uint256(decimals)).div(_rate);

    }



    function _checkMinLimit(uint256 tokenAmount) internal {

        require(tokenAmount >= minDeposit);

    }



    function _checkAvailableTokens(uint256 tokenAmount) internal {

        require(tokensSold.add(tokenAmount) <= cap);

    }



    function _validatePurchase(address _beneficiary, uint256 _weiAmount) internal {

        require(_beneficiary != address(0));

        require(_weiAmount != 0);

    }



    function getWeiAmount(uint256 _tokenAmount)

        public view returns (uint256)

    {

        return _tokenAmount.mul(tokenConstant);

    }



    function getTokenAmount(uint256 _weiAmount)

        public view returns (uint256)

    {

        return _weiAmount.div(tokenConstant);

    }



    function buyTokens(address _beneficiary) public onlyWhileOpen payable {

        uint256 weiAmount = msg.value;

        _validatePurchase(_beneficiary, weiAmount);



        uint256 tokenAmount = getTokenAmount(weiAmount);

        _checkAvailableTokens(tokenAmount);

        _checkMinLimit(tokenAmount);



        weiRaised = weiRaised.add(weiAmount);

        tokensSold = tokensSold.add(tokenAmount);



        token.transfer(_beneficiary, tokenAmount);



        emit TokenPurchase(

            msg.sender,

            _beneficiary,

            weiAmount,

            tokenAmount

        );

    }



    function() external payable {

        buyTokens(msg.sender);

    }



    function finalization() internal {

        if (tokensSold < cap) {

            uint256 remainingTokens = token.balanceOf(this);

            if (remainingTokens > 0) {

                token.burn(remainingTokens);

            }

        }

    }



    modifier isCapNotUpdated() {

        require(isCapUpdated == false);

        _;

    }



    function updateCap() public onlyOwner isCapNotUpdated {

        uint currentBalance = token.balanceOf(this);

        uint remainingTokens = currentBalance.sub(cap);

        cap = cap.add(remainingTokens);

        isCapUpdated = true;

    }

}



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) internal balances;



  uint256 internal totalSupply_;



  /**

  * @dev Total number of tokens in existence

  */

  function totalSupply() public view returns (uint256) {

    return totalSupply_;

  }



  /**

  * @dev Transfer token for a specified address

  * @param _to The address to transfer to.

  * @param _value The amount to be transferred.

  */

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);

    require(_to != address(0));



    balances[msg.sender] = balances[msg.sender].sub(_value);

    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;

  }



  /**

  * @dev Gets the balance of the specified address.

  * @param _owner The address to query the the balance of.

  * @return An uint256 representing the amount owned by the passed address.

  */

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];

  }



}



contract BurnableToken is BasicToken {



  event Burn(address indexed burner, uint256 value);



  /**

   * @dev Burns a specific amount of tokens.

   * @param _value The amount of token to be burned.

   */

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);

  }



  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    // no need to require value <= totalSupply, since that would imply the

    // sender's balance is greater than the totalSupply, which *should* be an assertion failure



    balances[_who] = balances[_who].sub(_value);

    totalSupply_ = totalSupply_.sub(_value);

    emit Burn(_who, _value);

    emit Transfer(_who, address(0), _value);

  }

}



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



contract StandardToken is ERC20, BasicToken {



  mapping (address => mapping (address => uint256)) internal allowed;





  /**

   * @dev Transfer tokens from one address to another

   * @param _from address The address which you want to send tokens from

   * @param _to address The address which you want to transfer to

   * @param _value uint256 the amount of tokens to be transferred

   */

  function transferFrom(

    address _from,

    address _to,

    uint256 _value

  )

    public

    returns (bool)

  {

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    require(_to != address(0));



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);

    return true;

  }



  /**

   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   * Beware that changing an allowance with this method brings the risk that someone may use both the old

   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

   * @param _spender The address which will spend the funds.

   * @param _value The amount of tokens to be spent.

   */

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);

    return true;

  }



  /**

   * @dev Function to check the amount of tokens that an owner allowed to a spender.

   * @param _owner address The address which owns the funds.

   * @param _spender address The address which will spend the funds.

   * @return A uint256 specifying the amount of tokens still available for the spender.

   */

  function allowance(

    address _owner,

    address _spender

   )

    public

    view

    returns (uint256)

  {

    return allowed[_owner][_spender];

  }



  /**

   * @dev Increase the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To increment

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _addedValue The amount of tokens to increase the allowance by.

   */

  function increaseApproval(

    address _spender,

    uint256 _addedValue

  )

    public

    returns (bool)

  {

    allowed[msg.sender][_spender] = (

      allowed[msg.sender][_spender].add(_addedValue));

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



  /**

   * @dev Decrease the amount of tokens that an owner allowed to a spender.

   * approve should be called when allowed[_spender] == 0. To decrement

   * allowed value is better to use this function to avoid 2 calls (and wait until

   * the first transaction is mined)

   * From MonolithDAO Token.sol

   * @param _spender The address which will spend the funds.

   * @param _subtractedValue The amount of tokens to decrease the allowance by.

   */

  function decreaseApproval(

    address _spender,

    uint256 _subtractedValue

  )

    public

    returns (bool)

  {

    uint256 oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue >= oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}



contract NeuronxCoin is StandardToken, BurnableToken {

    string public name = "NeuronX blockchain token";

    string public symbol = "NXBT";

    uint8 public decimals = 8;



    uint256 public constant INITIAL_SUPPLY = 200 * 1e6 * 1e8; // 200.000.000 total with decimals



    constructor() public {

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

    }

}