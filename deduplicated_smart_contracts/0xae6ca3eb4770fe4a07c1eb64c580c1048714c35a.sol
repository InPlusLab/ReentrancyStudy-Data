/**
 *Submitted for verification at Etherscan.io on 2019-09-05
*/

pragma solidity ^0.5.0;


interface TokenInterface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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

     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
* @title Tellor Community Sale
* @dev This contract allows for the sale of Tributes to early miners
*/

contract TellorCommunitySale{
    using SafeMath for uint256;

    /*Variables*/
    uint public tribPrice;
    uint public endDate;
    uint public saleAmount;
    address public tellorAddress;
    address payable public owner;
    TokenInterface tellor;

    mapping(address => uint) saleByAddress;

    /*Events*/
    event NewPrice(uint _price);
    event NewAddress(address _newAddress, uint _amount);
    event NewSale(address _buyer,uint _amount);


    /*Constructor*/
    /*
    * @dev This sets the sale period to 7 days, and the TellorMaster address for the interface
    * @param _Tellor is the TellorMaster address
    */
    constructor(address _Tellor) public {
        owner = msg.sender;
        endDate = now + 7 days;
        tellorAddress = _Tellor;
        tellor = TokenInterface(_Tellor);
    }


    /**
    * @dev Allows the contract owner(Tellor) to set the price per Tribute
    * @param _price per Tribute
    */
    function setPrice(uint _price) external {
        require(msg.sender == owner);
        tribPrice = _price;
        emit NewPrice(_price);
    }


    /**
    * @dev Allows the contract owner(Tellor) to add approved addresses for the sale
    * It only allows for each address to be approved once and it checks that this contract contains 
    * enough Tellor Tributes available before authorizing
    * @param _address of approved party
    * @param _amount of tokens authorized for the party to buy
    */
    function enterAddress(address _address, uint _amount) external {
        require(msg.sender == owner);
        require(checkThisAddressTokens()/1e18 >= saleAmount.add(_amount));
        saleAmount += _amount;
        saleByAddress[_address] += _amount;
        emit NewAddress(_address,_amount);
    }


    /**
    * @dev Allows the contract owner(Tellor) to withdraw any Tributes left on this contract
    * after the sale's end date
    */
    function withdrawTokens() external{
        require(msg.sender == owner);
        require(now > endDate);
        tellor.transfer(owner,tellor.balanceOf(address(this)));
    }


    /**
    * @dev Allows the contract owner(Tellor) to withdraw ETH from this contract
    */
    function withdrawETH() external{
        require(msg.sender == owner);
        address(owner).transfer(address(this).balance);
    }
    

    /**
    * @dev Allows the approved addresses to pay ETH and withdraw the authorized number of Tributes
    */
    function () external payable{
        require (saleByAddress[msg.sender] > 0);
        require(msg.value >= tribPrice.mul(saleByAddress[msg.sender]));//are decimals an issue?
        tellor.transfer(msg.sender,saleByAddress[msg.sender]*1e18); 
        emit NewSale(msg.sender,saleByAddress[msg.sender]);
        saleByAddress[msg.sender] = 0;
    }    


    /*Getters*/

    /**
    * @dev Gets the amount of Tributes authorized for the specified address
    * @param _address of approved party
    */
    function getSaleByAddress(address _address) external view returns(uint){
        return saleByAddress[_address];
    }


    /**
    * @dev Checks if this contract has enough Tributes before approving more addresses 
    */
    function checkThisAddressTokens() public view returns(uint){
        return tellor.balanceOf(address(this));
    }


    /**
    * @dev Gives the user the price for their assigned tokens
    */
    function priceForUserTokens(address _address) public view returns(uint){
        return tribPrice.mul(saleByAddress[_address]);
    }
}