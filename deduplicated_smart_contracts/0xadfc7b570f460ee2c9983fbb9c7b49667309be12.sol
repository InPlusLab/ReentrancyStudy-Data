/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

pragma solidity >=0.4.0 <0.7.0;

//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Ownable {

  // Owner of the contract
  address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

  /**
  * @dev Event to show ownership has been transferred
  * @param previousOwner representing the address of the previous owner
  * @param newOwner representing the address of the new owner
  */
  event OwnershipTransferred(address previousOwner, address newOwner);


  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(msg.sender == owner, "Not Owner");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address payable newOwner) public onlyOwner {
    require(newOwner != address(0), "Invalid Address");
    owner = newOwner;
  }
}

contract EtherSVContract is Ownable {

    using SafeMath for uint256;
    // using RealMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;
    uint256 public totalRemains;

    uint256 public exchangeRate = 10000;

    uint256 public unit = 1 ether;

    address payable public businessAddress;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed from, address indexed spender, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        owner = msg.sender;
        decimals = 18;
        totalSupply = 200000000 * (10 ** uint256(decimals));  // Update total supply with the decimal amount
        totalRemains = totalSupply;
        name = "Ether SV";                                   // Set the name for display purposes
        symbol = "ESV";                               // Set the symbol for display purposes
        balanceOf[address(this)] = totalSupply;                // Give the creator all initial tokens
        businessAddress = 0x0D1cc8A492db9390B5d36D68aCA5B919e35698C5;
        emit Transfer(address(0), address(this), totalSupply);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0), "Invalid Address");
        // Check if the sender has enough
        require(balanceOf[_from] >= _value, "Invalid balance");
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to], "Overflows");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Invalid allowance");     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Not enough balance");   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Not enough balance");                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender], "Invalid allowance");    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }

    function setBusinessAddress(address payable _businessAddress) public onlyOwner returns (bool success) {
        require(_businessAddress != address(0), "Invalid Business Address");
        businessAddress = _businessAddress;
        return true;
    }

    event BuyTokens(address indexed beneficiary, uint256 cost, uint256 tokenAmount, uint time);
    event SellTokens(address indexed seller, uint256 tokenAmount, uint time);

    function calculateDepositAmount(uint256 tokenAmount) public view returns(uint256 ethAmount) {
        uint256 buyRate = _calculateBuyPrice(tokenAmount).div(1 ether);
        return  buyRate.mul(101).div(100).div(100000);
    }

    function _calculateBuyPrice(uint256 _totalPurchased) internal view returns(uint256 price) {
        // return _totalPurchased.mul(1 ether).mul((2 * (totalSupply.sub(totalRemains))).add(_totalPurchased));
        return _totalPurchased.mul((2 * (totalSupply.sub(totalRemains))).add(_totalPurchased));
    }

    function _calculateSellPrice(uint256 _totalSold) internal view returns(uint256 price) {
        return _totalSold.mul((2 * (totalSupply.sub(totalRemains))).sub(_totalSold)).div(100000);
    }

    function buy(uint256 tokenAmount) public payable returns(bool success) {
        address beneficiary = msg.sender;
        uint256 weiAmount = msg.value;
        uint256 fee = weiAmount.div(101);

        uint256 price = _calculateBuyPrice(tokenAmount).div(1 ether);
        uint256 expectedDeposit = price.mul(101).div(100).div(100000);
        require(weiAmount == expectedDeposit, "Invalid Deposit Amount");

        _transfer(address(this), msg.sender, tokenAmount);
        totalRemains = totalRemains.sub(tokenAmount);
        address(businessAddress).transfer(fee);
        emit BuyTokens(beneficiary, weiAmount, tokenAmount, now);
        return true;
    }

    function sell(uint256 tokenAmount) public returns(bool success) {
        uint256 sellRate = _calculateSellPrice(tokenAmount).div(1 ether);
        _transfer(msg.sender, address(this), tokenAmount);
        totalRemains = totalRemains.add(tokenAmount);
        address(msg.sender).transfer(sellRate);
        emit SellTokens(msg.sender, tokenAmount, now);
        return true;
    }
}