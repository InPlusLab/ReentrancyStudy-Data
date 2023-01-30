/**
 *Submitted for verification at Etherscan.io on 2019-09-04
*/

// File: contracts\lib\Ownable.sol

pragma solidity 0.5.9;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Only owner is able call this function!");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
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

// File: contracts\lib\SafeMath.sol

pragma solidity ^0.5.9;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMul overflow!');

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, 'SafeDiv cannot divide by 0!');
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'SafeSub underflow!');
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeAdd overflow!');

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'SafeMod cannot compute modulo of 0!');
        return a % b;
    }
}

// File: contracts\lib\ERC20Plus.sol

pragma solidity 0.5.9;

/**
 * @title ERC20 interface with additional functions
 * @dev it has added functions that deals to minting, pausing token and token information
 */
contract ERC20Plus {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    // additonal functions
    function mint(address _to, uint256 _amount) public returns (bool);
    function owner() public view returns (address);
    function transferOwnership(address newOwner) public;
    function name() public view returns (string memory);
    function symbol() public view returns (string memory);
    function decimals() public view returns (uint8);
    function paused() public view returns (bool);
}

// File: contracts\lib\Lockable.sol

pragma solidity 0.5.9;


contract Lockable is Ownable {

    bool public locked;

    modifier onlyWhenUnlocked() {
        require(!locked, 'Contract is locked by owner!');
        _;
    }

    function lock() external onlyOwner {
        locked = true;
    }

    function unlock() external onlyOwner {
        locked = false;
    }
}

// File: contracts\BonusTokenDistribution.sol

pragma solidity 0.5.9;





/**
 * @title BonusTokenDistribution - contract for handling bonus tokens
 * @author Markus Waas - <markus@starbase.co>
 */

contract BonusTokenDistribution is Lockable {
    using SafeMath for uint256;

    ERC20Plus public tokenOnSale;

    uint256 public startTime;
    uint256 public endTime;

    mapping (address => uint256) public bonusTokenBalances;

    modifier isAfterClaimPeriod {
        require(
            (now > endTime.add(60 days)),
            'Claim period is not yet finished!'
        );

        _;
    }

    modifier hasStarted {
        require(
            now >= startTime,
            "Distribution period not yet started!"
        );

        _;
    }

    /**
     * @param _startTime Timestamp for the beginning of the bonus campaign
     * @param _endTime Timestamp of the end of the bonus campaign
     * @param _tokenOnSale Token that will be distributed
     */
    constructor(
        uint256 _startTime,
        uint256 _endTime,
        address _tokenOnSale
    ) public {
        require(_startTime >= now, "startTime must be more than current time!");
        require(_endTime >= _startTime, "endTime must be more than startTime!");
        require(_tokenOnSale != address(0), "tokenOnSale cannot be 0!");

        startTime = _startTime;
        endTime = _endTime;
        tokenOnSale = ERC20Plus(_tokenOnSale);
    }

    /**
     * @dev Adds bonus claim for user
     * @param _user Address of the user
     * @param _amount Amount of tokens he can claim
     */
    function addBonusClaim(address _user, uint256 _amount)
        public
        onlyOwner
        hasStarted {
        require(_user != address(0), "user cannot be 0!");
        require(_amount > 0, "amount cannot be 0!");

        bonusTokenBalances[_user] = bonusTokenBalances[_user].add(_amount);
    }

    /**
     * @dev Withdraw bonus tokens
     */
    function withdrawBonusTokens() public onlyWhenUnlocked hasStarted {
        uint256 bonusTokens = bonusTokenBalances[msg.sender];
        uint256 tokenBalance = tokenOnSale.balanceOf(address(this));

        require(bonusTokens > 0, 'No bonus tokens to withdraw!');
        require(tokenBalance >= bonusTokens, 'Not enough bonus tokens left!');

        bonusTokenBalances[msg.sender] = 0;
        tokenOnSale.transfer(msg.sender, bonusTokens);
    }

    /**
     * @dev Withdraw any left over tokens for owner after 60 days claim period.
     */
    function withdrawLeftoverBonusTokensOwner()
        public
        isAfterClaimPeriod
        onlyOwner {
        uint256 tokenBalance = tokenOnSale.balanceOf(address(this));
        require(tokenBalance > 0, 'No bonus tokens leftover!');

        tokenOnSale.transfer(msg.sender, tokenBalance);
    }
}