/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity ^0.4.24;



/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.

/// @author Alan Lu - <[email protected]>

contract Proxied {

    address public masterCopy;

}



/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.

/// @author Stefan George - <[email protected]>

contract Proxy is Proxied {

    /// @dev Constructor function sets address of master copy contract.

    /// @param _masterCopy Master copy address.

    constructor(address _masterCopy)

        public

    {

        require(_masterCopy != 0);

        masterCopy = _masterCopy;

    }



    /// @dev Fallback function forwards all transactions and returns all received return data.

    function ()

        external

        payable

    {

        address _masterCopy = masterCopy;

        assembly {

            calldatacopy(0, 0, calldatasize())

            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch success

            case 0 { revert(0, returndatasize()) }

            default { return(0, returndatasize()) }

        }

    }

}



/// @title Fixed192x64Math library - Allows calculation of logarithmic and exponential functions

/// @author Alan Lu - <[email protected]>

/// @author Stefan George - <[email protected]>

library Fixed192x64Math {



    enum EstimationMode { LowerBound, UpperBound, Midpoint }



    /*

     *  Constants

     */

    // This is equal to 1 in our calculations

    uint public constant ONE =  0x10000000000000000;

    uint public constant LN2 = 0xb17217f7d1cf79ac;

    uint public constant LOG2_E = 0x171547652b82fe177;



    /*

     *  Public functions

     */

    /// @dev Returns natural exponential function value of given x

    /// @param x x

    /// @return e**x

    function exp(int x)

        public

        pure

        returns (uint)

    {

        // revert if x is > MAX_POWER, where

        // MAX_POWER = int(mp.floor(mp.log(mpf(2**256 - 1) / ONE) * ONE))

        require(x <= 2454971259878909886679);

        // return 0 if exp(x) is tiny, using

        // MIN_POWER = int(mp.floor(mp.log(mpf(1) / ONE) * ONE))

        if (x <= -818323753292969962227)

            return 0;



        // Transform so that e^x -> 2^x

        (uint lower, uint upper) = pow2Bounds(x * int(ONE) / int(LN2));

        return (upper - lower) / 2 + lower;

    }



    /// @dev Returns estimate of 2**x given x

    /// @param x exponent in fixed point

    /// @param estimationMode whether to return a lower bound, upper bound, or a midpoint

    /// @return estimate of 2**x in fixed point

    function pow2(int x, EstimationMode estimationMode)

        public

        pure

        returns (uint)

    {

        (uint lower, uint upper) = pow2Bounds(x);

        if(estimationMode == EstimationMode.LowerBound) {

            return lower;

        }

        if(estimationMode == EstimationMode.UpperBound) {

            return upper;

        }

        if(estimationMode == EstimationMode.Midpoint) {

            return (upper - lower) / 2 + lower;

        }

        revert();

    }



    /// @dev Returns bounds for value of 2**x given x

    /// @param x exponent in fixed point

    /// @return {

    ///   "lower": "lower bound of 2**x in fixed point",

    ///   "upper": "upper bound of 2**x in fixed point"

    /// }

    function pow2Bounds(int x)

        public

        pure

        returns (uint lower, uint upper)

    {

        // revert if x is > MAX_POWER, where

        // MAX_POWER = int(mp.floor(mp.log(mpf(2**256 - 1) / ONE, 2) * ONE))

        require(x <= 3541774862152233910271);

        // return 0 if exp(x) is tiny, using

        // MIN_POWER = int(mp.floor(mp.log(mpf(1) / ONE, 2) * ONE))

        if (x < -1180591620717411303424)

            return (0, 1);



        // 2^x = 2^(floor(x)) * 2^(x-floor(x))

        //       ^^^^^^^^^^^^^^ is a bit shift of ceil(x)

        // so Taylor expand on z = x-floor(x), z in [0, 1)

        int shift;

        int z;

        if (x >= 0) {

            shift = x / int(ONE);

            z = x % int(ONE);

        }

        else {

            shift = (x+1) / int(ONE) - 1;

            z = x - (int(ONE) * shift);

        }

        assert(z >= 0);

        // 2^x = 1 + (ln 2) x + (ln 2)^2/2! x^2 + ...

        //

        // Can generate the z coefficients using mpmath and the following lines

        // >>> from mpmath import mp

        // >>> mp.dps = 100

        // >>> coeffs = [mp.log(2)**i / mp.factorial(i) for i in range(1, 21)]

        // >>> shifts = [64 - int(mp.log(c, 2)) for c in coeffs]

        // >>> print('\n'.join(hex(int(c * (1 << s))) + ', ' + str(s) for c, s in zip(coeffs, shifts)))

        int result = int(ONE) << 64;

        int zpow = z;

        result += 0xb17217f7d1cf79ab * zpow;

        zpow = zpow * z / int(ONE);

        result += 0xf5fdeffc162c7543 * zpow >> (66 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xe35846b82505fc59 * zpow >> (68 - 64);

        zpow = zpow * z / int(ONE);

        result += 0x9d955b7dd273b94e * zpow >> (70 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xaec3ff3c53398883 * zpow >> (73 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xa184897c363c3b7a * zpow >> (76 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xffe5fe2c45863435 * zpow >> (80 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xb160111d2e411fec * zpow >> (83 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xda929e9caf3e1ed2 * zpow >> (87 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xf267a8ac5c764fb7 * zpow >> (91 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xf465639a8dd92607 * zpow >> (95 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xe1deb287e14c2f15 * zpow >> (99 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xc0b0c98b3687cb14 * zpow >> (103 - 64);

        zpow = zpow * z / int(ONE);

        result += 0x98a4b26ac3c54b9f * zpow >> (107 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xe1b7421d82010f33 * zpow >> (112 - 64);

        zpow = zpow * z / int(ONE);

        result += 0x9c744d73cfc59c91 * zpow >> (116 - 64);

        zpow = zpow * z / int(ONE);

        result += 0xcc2225a0e12d3eab * zpow >> (121 - 64);

        zpow = zpow * z / int(ONE);

        zpow = 0xfb8bb5eda1b4aeb9 * zpow >> (126 - 64);

        result += zpow;

        zpow = int(8 * ONE);



        shift -= 64;

        if (shift >= 0) {

            if (result >> (256-shift) == 0) {

                lower = uint(result) << shift;

                zpow <<= shift; // todo: is this safe?

                if (lower + uint(zpow) >= lower)

                    upper = lower + uint(zpow);

                else

                    upper = 2**256-1;

                return;

            }

            else

                return (2**256-1, 2**256-1);

        }

        zpow = (zpow >> (-shift)) + 1;

        lower = uint(result) >> (-shift);

        upper = lower + uint(zpow);

        return;

    }



    /// @dev Returns natural logarithm value of given x

    /// @param x x

    /// @return ln(x)

    function ln(uint x)

        public

        pure

        returns (int)

    {

        (int lower, int upper) = log2Bounds(x);

        return ((upper - lower) / 2 + lower) * int(ONE) / int(LOG2_E);

    }



    /// @dev Returns estimate of binaryLog(x) given x

    /// @param x logarithm argument in fixed point

    /// @param estimationMode whether to return a lower bound, upper bound, or a midpoint

    /// @return estimate of binaryLog(x) in fixed point

    function binaryLog(uint x, EstimationMode estimationMode)

        public

        pure

        returns (int)

    {

        (int lower, int upper) = log2Bounds(x);

        if(estimationMode == EstimationMode.LowerBound) {

            return lower;

        }

        if(estimationMode == EstimationMode.UpperBound) {

            return upper;

        }

        if(estimationMode == EstimationMode.Midpoint) {

            return (upper - lower) / 2 + lower;

        }

        revert();

    }



    /// @dev Returns bounds for value of binaryLog(x) given x

    /// @param x logarithm argument in fixed point

    /// @return {

    ///   "lower": "lower bound of binaryLog(x) in fixed point",

    ///   "upper": "upper bound of binaryLog(x) in fixed point"

    /// }

    function log2Bounds(uint x)

        public

        pure

        returns (int lower, int upper)

    {

        require(x > 0);

        // compute ⌊log₂x⌋

        lower = floorLog2(x);



        uint y;

        if (lower < 0)

            y = x << uint(-lower);

        else

            y = x >> uint(lower);



        lower *= int(ONE);



        // y = x * 2^(-⌊log₂x⌋)

        // so 1 <= y < 2

        // and log₂x = ⌊log₂x⌋ + log₂y

        for (int m = 1; m <= 64; m++) {

            if(y == ONE) {

                break;

            }

            y = y * y / ONE;

            if(y >= 2 * ONE) {

                lower += int(ONE >> m);

                y /= 2;

            }

        }



        return (lower, lower + 4);

    }



    /// @dev Returns base 2 logarithm value of given x

    /// @param x x

    /// @return logarithmic value

    function floorLog2(uint x)

        public

        pure

        returns (int lo)

    {

        lo = -64;

        int hi = 193;

        // I use a shift here instead of / 2 because it floors instead of rounding towards 0

        int mid = (hi + lo) >> 1;

        while((lo + 1) < hi) {

            if (mid < 0 && x << uint(-mid) < ONE || mid >= 0 && x >> uint(mid) < ONE)

                hi = mid;

            else

                lo = mid;

            mid = (hi + lo) >> 1;

        }

    }



    /// @dev Returns maximum of an array

    /// @param nums Numbers to look through

    /// @return Maximum number

    function max(int[] nums)

        public

        pure

        returns (int maxNum)

    {

        require(nums.length > 0);

        maxNum = -2**255;

        for (uint i = 0; i < nums.length; i++)

            if (nums[i] > maxNum)

                maxNum = nums[i];

    }

}









/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

  int256 constant INT256_MIN = int256((uint256(1) << 255));



  /**

  * @dev Multiplies two unsigned integers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Multiplies two signed integers, throws on overflow.

  */

  function mul(int256 a, int256 b) internal pure returns (int256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert((a != -1 || b != INT256_MIN) && c / a == b);

  }



  /**

  * @dev Integer division of two unsigned integers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Integer division of two signed integers, truncating the quotient.

  */

  function div(int256 a, int256 b) internal pure returns (int256) {

    // assert(b != 0); // Solidity automatically throws when dividing by 0

    // Overflow only happens when the smallest negative int is multiplied by -1.

    assert(a != INT256_MIN || b != -1);

    return a / b;

  }



  /**

  * @dev Subtracts two unsigned integers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Subtracts two signed integers, throws on overflow.

  */

  function sub(int256 a, int256 b) internal pure returns (int256 c) {

    c = a - b;

    assert((b >= 0 && c <= a) || (b < 0 && c > a));

  }



  /**

  * @dev Adds two unsigned integers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }



  /**

  * @dev Adds two signed integers, throws on overflow.

  */

  function add(int256 a, int256 b) internal pure returns (int256 c) {

    c = a + b;

    assert((b >= 0 && c >= a) || (b < 0 && c < a));

  }

}







/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title Basic token

 * @dev Basic version of StandardToken, with no allowances.

 */

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;



  mapping(address => uint256) balances;



  uint256 totalSupply_;



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

    require(_to != address(0));

    require(_value <= balances[msg.sender]);



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







/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/issues/20

 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 */

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

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);



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

    if (_subtractedValue > oldValue) {

      allowed[msg.sender][_spender] = 0;

    } else {

      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);

    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

    return true;

  }



}





contract OutcomeTokenProxy is Proxy {

    /*

     *  Storage

     */



    // HACK: Lining up storage with StandardToken and OutcomeToken

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    mapping (address => mapping (address => uint256)) internal allowed;



    address internal eventContract;



    /*

     *  Public functions

     */

    /// @dev Constructor sets events contract address

    constructor(address proxied)

        public

        Proxy(proxied)

    {

        eventContract = msg.sender;

    }

}



/// @title Outcome token contract - Issuing and revoking outcome tokens

/// @author Stefan George - <[email protected]>

contract OutcomeToken is Proxied, StandardToken {

    using SafeMath for *;



    /*

     *  Events

     */

    event Issuance(address indexed owner, uint amount);

    event Revocation(address indexed owner, uint amount);



    /*

     *  Storage

     */

    address public eventContract;



    /*

     *  Modifiers

     */

    modifier isEventContract () {

        // Only event contract is allowed to proceed

        require(msg.sender == eventContract);

        _;

    }



    /*

     *  Public functions

     */

    /// @dev Events contract issues new tokens for address. Returns success

    /// @param _for Address of receiver

    /// @param outcomeTokenCount Number of tokens to issue

    function issue(address _for, uint outcomeTokenCount)

        public

        isEventContract

    {

        balances[_for] = balances[_for].add(outcomeTokenCount);

        totalSupply_ = totalSupply_.add(outcomeTokenCount);

        emit Issuance(_for, outcomeTokenCount);

    }



    /// @dev Events contract revokes tokens for address. Returns success

    /// @param _for Address of token holder

    /// @param outcomeTokenCount Number of tokens to revoke

    function revoke(address _for, uint outcomeTokenCount)

        public

        isEventContract

    {

        balances[_for] = balances[_for].sub(outcomeTokenCount);

        totalSupply_ = totalSupply_.sub(outcomeTokenCount);

        emit Revocation(_for, outcomeTokenCount);

    }

}



/// @title Abstract oracle contract - Functions to be implemented by oracles

contract Oracle {



    function isOutcomeSet() public view returns (bool);

    function getOutcome() public view returns (int);

}





contract EventData {



    /*

     *  Events

     */

    event OutcomeTokenCreation(OutcomeToken outcomeToken, uint8 index);

    event OutcomeTokenSetIssuance(address indexed buyer, uint collateralTokenCount);

    event OutcomeTokenSetRevocation(address indexed seller, uint outcomeTokenCount);

    event OutcomeAssignment(int outcome);

    event WinningsRedemption(address indexed receiver, uint winnings);



    /*

     *  Storage

     */

    ERC20 public collateralToken;

    Oracle public oracle;

    bool public isOutcomeSet;

    int public outcome;

    OutcomeToken[] public outcomeTokens;

}



/// @title Event contract - Provide basic functionality required by different event types

/// @author Stefan George - <[email protected]>

contract Event is EventData {



    /*

     *  Public functions

     */

    /// @dev Buys equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1

    /// @param collateralTokenCount Number of collateral tokens

    function buyAllOutcomes(uint collateralTokenCount)

        public

    {

        // Transfer collateral tokens to events contract

        require(collateralToken.transferFrom(msg.sender, this, collateralTokenCount));

        // Issue new outcome tokens to sender

        for (uint8 i = 0; i < outcomeTokens.length; i++)

            outcomeTokens[i].issue(msg.sender, collateralTokenCount);

        emit OutcomeTokenSetIssuance(msg.sender, collateralTokenCount);

    }



    /// @dev Sells equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1

    /// @param outcomeTokenCount Number of outcome tokens

    function sellAllOutcomes(uint outcomeTokenCount)

        public

    {

        // Revoke sender's outcome tokens of all outcomes

        for (uint8 i = 0; i < outcomeTokens.length; i++)

            outcomeTokens[i].revoke(msg.sender, outcomeTokenCount);

        // Transfer collateral tokens to sender

        require(collateralToken.transfer(msg.sender, outcomeTokenCount));

        emit OutcomeTokenSetRevocation(msg.sender, outcomeTokenCount);

    }



    /// @dev Sets winning event outcome

    function setOutcome()

        public

    {

        // Winning outcome is not set yet in event contract but in oracle contract

        require(!isOutcomeSet && oracle.isOutcomeSet());

        // Set winning outcome

        outcome = oracle.getOutcome();

        isOutcomeSet = true;

        emit OutcomeAssignment(outcome);

    }



    /// @dev Returns outcome count

    /// @return Outcome count

    function getOutcomeCount()

        public

        view

        returns (uint8)

    {

        return uint8(outcomeTokens.length);

    }



    /// @dev Returns outcome tokens array

    /// @return Outcome tokens

    function getOutcomeTokens()

        public

        view

        returns (OutcomeToken[])

    {

        return outcomeTokens;

    }



    /// @dev Returns the amount of outcome tokens held by owner

    /// @return Outcome token distribution

    function getOutcomeTokenDistribution(address owner)

        public

        view

        returns (uint[] outcomeTokenDistribution)

    {

        outcomeTokenDistribution = new uint[](outcomeTokens.length);

        for (uint8 i = 0; i < outcomeTokenDistribution.length; i++)

            outcomeTokenDistribution[i] = outcomeTokens[i].balanceOf(owner);

    }



    /// @dev Calculates and returns event hash

    /// @return Event hash

    function getEventHash() public view returns (bytes32);



    /// @dev Exchanges sender's winning outcome tokens for collateral tokens

    /// @return Sender's winnings

    function redeemWinnings() public returns (uint);

}





contract MarketData {

    /*

     *  Events

     */

    event MarketFunding(uint funding);

    event MarketClosing();

    event FeeWithdrawal(uint fees);

    event OutcomeTokenPurchase(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenCost, uint marketFees);

    event OutcomeTokenSale(address indexed seller, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenProfit, uint marketFees);

    event OutcomeTokenShortSale(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint cost);

    event OutcomeTokenTrade(address indexed transactor, int[] outcomeTokenAmounts, int outcomeTokenNetCost, uint marketFees);



    /*

     *  Storage

     */

    address public creator;

    uint public createdAtBlock;

    Event public eventContract;

    MarketMaker public marketMaker;

    uint24 public fee;

    uint public funding;

    int[] public netOutcomeTokensSold;

    Stages public stage;



    enum Stages {

        MarketCreated,

        MarketFunded,

        MarketClosed

    }

}



/// @title Abstract market contract - Functions to be implemented by market contracts

contract Market is MarketData {

    /*

     *  Public functions

     */

    function fund(uint _funding) public;

    function close() public;

    function withdrawFees() public returns (uint);

    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost) public returns (uint);

    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);

    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);

    function trade(int[] outcomeTokenAmounts, int costLimit) public returns (int);

    function calcMarketFee(uint outcomeTokenCost) public view returns (uint);

}





/// @title Abstract market maker contract - Functions to be implemented by market maker contracts

contract MarketMaker {



    /*

     *  Public functions

     */

    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);

    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);

    function calcNetCost(Market market, int[] outcomeTokenAmounts) public view returns (int);

    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex) public view returns (uint);

}





/// @title LMSR market maker contract - Calculates share prices based on share distribution and initial funding

/// @author Alan Lu - <[email protected]>

contract LMSRMarketMaker is MarketMaker {

    using SafeMath for *;



    /*

     *  Constants

     */

    uint constant ONE = 0x10000000000000000;

    int constant EXP_LIMIT = 3394200909562557497344;



    /*

     *  Public functions

     */

    /// @dev Calculates the net cost for executing a given trade.

    /// @param market Market contract

    /// @param outcomeTokenAmounts Amounts of outcome tokens to buy from the market. If an amount is negative, represents an amount to sell to the market.

    /// @return Net cost of trade. If positive, represents amount of collateral which would be paid to the market for the trade. If negative, represents amount of collateral which would be received from the market for the trade.

    function calcNetCost(Market market, int[] outcomeTokenAmounts)

        public

        view

        returns (int netCost)

    {

        require(market.eventContract().getOutcomeCount() > 1);

        int[] memory netOutcomeTokensSold = getNetOutcomeTokensSold(market);



        // Calculate cost level based on net outcome token balances

        int log2N = Fixed192x64Math.binaryLog(netOutcomeTokensSold.length * ONE, Fixed192x64Math.EstimationMode.UpperBound);

        uint funding = market.funding();

        int costLevelBefore = calcCostLevel(log2N, netOutcomeTokensSold, funding, Fixed192x64Math.EstimationMode.LowerBound);



        // Change amounts based on outcomeTokenAmounts passed in

        require(netOutcomeTokensSold.length == outcomeTokenAmounts.length);

        for (uint8 i = 0; i < netOutcomeTokensSold.length; i++) {

            netOutcomeTokensSold[i] = netOutcomeTokensSold[i].add(outcomeTokenAmounts[i]);

        }



        // Calculate cost level after balance was updated

        int costLevelAfter = calcCostLevel(log2N, netOutcomeTokensSold, funding, Fixed192x64Math.EstimationMode.UpperBound);



        // Calculate net cost as cost level difference and use the ceil

        netCost = costLevelAfter.sub(costLevelBefore);

        // Integer division for negative numbers already uses ceiling,

        // so only check boundary condition for positive numbers

        if(netCost <= 0 || netCost / int(ONE) * int(ONE) == netCost) {

            netCost /= int(ONE);

        } else {

            netCost = netCost / int(ONE) + 1;

        }

    }



    /// @dev Returns cost to buy given number of outcome tokens

    /// @param market Market contract

    /// @param outcomeTokenIndex Index of outcome to buy

    /// @param outcomeTokenCount Number of outcome tokens to buy

    /// @return Cost

    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount)

        public

        view

        returns (uint cost)

    {

        require(market.eventContract().getOutcomeCount() > 1);

        int[] memory netOutcomeTokensSold = getNetOutcomeTokensSold(market);

        // Calculate cost level based on net outcome token balances

        int log2N = Fixed192x64Math.binaryLog(netOutcomeTokensSold.length * ONE, Fixed192x64Math.EstimationMode.UpperBound);

        uint funding = market.funding();

        int costLevelBefore = calcCostLevel(log2N, netOutcomeTokensSold, funding, Fixed192x64Math.EstimationMode.LowerBound);

        // Add outcome token count to net outcome token balance

        require(int(outcomeTokenCount) >= 0);

        netOutcomeTokensSold[outcomeTokenIndex] = netOutcomeTokensSold[outcomeTokenIndex].add(int(outcomeTokenCount));

        // Calculate cost level after balance was updated

        int costLevelAfter = calcCostLevel(log2N, netOutcomeTokensSold, funding, Fixed192x64Math.EstimationMode.UpperBound);

        // Calculate cost as cost level difference

        if(costLevelAfter < costLevelBefore)

            costLevelAfter = costLevelBefore;

        cost = uint(costLevelAfter - costLevelBefore);

        // Take the ceiling to account for rounding

        if (cost / ONE * ONE == cost)

            cost /= ONE;

        else

            // Integer division by ONE ensures there is room to (+ 1)

            cost = cost / ONE + 1;

        // Make sure cost is not bigger than 1 per share

        if (cost > outcomeTokenCount)

            cost = outcomeTokenCount;

    }



    /// @dev Returns profit for selling given number of outcome tokens

    /// @param market Market contract

    /// @param outcomeTokenIndex Index of outcome to sell

    /// @param outcomeTokenCount Number of outcome tokens to sell

    /// @return Profit

    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount)

        public

        view

        returns (uint profit)

    {

        require(market.eventContract().getOutcomeCount() > 1);

        int[] memory netOutcomeTokensSold = getNetOutcomeTokensSold(market);

        // Calculate cost level based on net outcome token balances

        int log2N = Fixed192x64Math.binaryLog(netOutcomeTokensSold.length * ONE, Fixed192x64Math.EstimationMode.UpperBound);

        uint funding = market.funding();

        int costLevelBefore = calcCostLevel(log2N, netOutcomeTokensSold, funding, Fixed192x64Math.EstimationMode.LowerBound);

        // Subtract outcome token count from the net outcome token balance

        require(int(outcomeTokenCount) >= 0);

        netOutcomeTokensSold[outcomeTokenIndex] = netOutcomeTokensSold[outcomeTokenIndex].sub(int(outcomeTokenCount));

        // Calculate cost level after balance was updated

        int costLevelAfter = calcCostLevel(log2N, netOutcomeTokensSold, funding, Fixed192x64Math.EstimationMode.UpperBound);

        // Calculate profit as cost level difference

        if(costLevelBefore <= costLevelAfter)

            costLevelBefore = costLevelAfter;

        // Take the floor

        profit = uint(costLevelBefore - costLevelAfter) / ONE;

    }



    /// @dev Returns marginal price of an outcome

    /// @param market Market contract

    /// @param outcomeTokenIndex Index of outcome to determine marginal price of

    /// @return Marginal price of an outcome as a fixed point number

    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex)

        public

        view

        returns (uint price)

    {

        require(market.eventContract().getOutcomeCount() > 1);

        int[] memory netOutcomeTokensSold = getNetOutcomeTokensSold(market);

        int logN = Fixed192x64Math.binaryLog(netOutcomeTokensSold.length * ONE, Fixed192x64Math.EstimationMode.Midpoint);

        uint funding = market.funding();

        // The price function is exp(quantities[i]/b) / sum(exp(q/b) for q in quantities)

        // To avoid overflow, calculate with

        // exp(quantities[i]/b - offset) / sum(exp(q/b - offset) for q in quantities)

        (uint sum, , uint outcomeExpTerm) = sumExpOffset(logN, netOutcomeTokensSold, funding, outcomeTokenIndex, Fixed192x64Math.EstimationMode.Midpoint);

        return outcomeExpTerm / (sum / ONE);

    }



    /*

     *  Private functions

     */

    /// @dev Calculates the result of the LMSR cost function which is used to

    ///      derive prices from the market state

    /// @param logN Logarithm of the number of outcomes

    /// @param netOutcomeTokensSold Net outcome tokens sold by market

    /// @param funding Initial funding for market

    /// @return Cost level

    function calcCostLevel(int logN, int[] netOutcomeTokensSold, uint funding, Fixed192x64Math.EstimationMode estimationMode)

        private

        pure

        returns(int costLevel)

    {

        // The cost function is C = b * log(sum(exp(q/b) for q in quantities)).

        // To avoid overflow, we need to calc with an exponent offset:

        // C = b * (offset + log(sum(exp(q/b - offset) for q in quantities)))

        (uint sum, int offset, ) = sumExpOffset(logN, netOutcomeTokensSold, funding, 0, estimationMode);

        costLevel = Fixed192x64Math.binaryLog(sum, estimationMode);

        costLevel = costLevel.add(offset);

        costLevel = (costLevel.mul(int(ONE)) / logN).mul(int(funding));

    }



    /// @dev Calculates sum(exp(q/b - offset) for q in quantities), where offset is set

    ///      so that the sum fits in 248-256 bits

    /// @param logN Logarithm of the number of outcomes

    /// @param netOutcomeTokensSold Net outcome tokens sold by market

    /// @param funding Initial funding for market

    /// @param outcomeIndex Index of exponential term to extract (for use by marginal price function)

    /// @return A result structure composed of the sum, the offset used, and the summand associated with the supplied index

    function sumExpOffset(int logN, int[] netOutcomeTokensSold, uint funding, uint8 outcomeIndex, Fixed192x64Math.EstimationMode estimationMode)

        private

        pure

        returns (uint sum, int offset, uint outcomeExpTerm)

    {

        // Naive calculation of this causes an overflow

        // since anything above a bit over 133*ONE supplied to exp will explode

        // as exp(133) just about fits into 192 bits of whole number data.



        // The choice of this offset is subject to another limit:

        // computing the inner sum successfully.

        // Since the index is 8 bits, there has to be 8 bits of headroom for

        // each summand, meaning q/b - offset <= exponential_limit,

        // where that limit can be found with `mp.floor(mp.log((2**248 - 1) / ONE) * ONE)`

        // That is what EXP_LIMIT is set to: it is about 127.5



        // finally, if the distribution looks like [BIG, tiny, tiny...], using a

        // BIG offset will cause the tiny quantities to go really negative

        // causing the associated exponentials to vanish.



        require(logN >= 0 && int(funding) >= 0);

        offset = Fixed192x64Math.max(netOutcomeTokensSold);

        offset = offset.mul(logN) / int(funding);

        offset = offset.sub(EXP_LIMIT);

        uint term;

        for (uint8 i = 0; i < netOutcomeTokensSold.length; i++) {

            term = Fixed192x64Math.pow2((netOutcomeTokensSold[i].mul(logN) / int(funding)).sub(offset), estimationMode);

            if (i == outcomeIndex)

                outcomeExpTerm = term;

            sum = sum.add(term);

        }

    }



    /// @dev Gets net outcome tokens sold by market. Since all sets of outcome tokens are backed by

    ///      corresponding collateral tokens, the net quantity of a token sold by the market is the

    ///      number of collateral tokens (which is the same as the number of outcome tokens the

    ///      market created) subtracted by the quantity of that token held by the market.

    /// @param market Market contract

    /// @return Net outcome tokens sold by market

    function getNetOutcomeTokensSold(Market market)

        private

        view

        returns (int[] quantities)

    {

        quantities = new int[](market.eventContract().getOutcomeCount());

        for (uint8 i = 0; i < quantities.length; i++)

            quantities[i] = market.netOutcomeTokensSold(i);

    }

}