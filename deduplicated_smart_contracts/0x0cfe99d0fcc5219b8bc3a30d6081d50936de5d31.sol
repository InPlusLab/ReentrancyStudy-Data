/**

 *Submitted for verification at Etherscan.io on 2019-02-05

*/



pragma solidity ^0.5.2;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

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

        require(c / a == b);



        return c;

    }



    /**

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



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

        require(isOwner());

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







/**

 * @title TokenVesting

 * @dev A token holder contract that can release its token balance gradually like a

 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the

 * owner.

 */

contract TokenVesting is Ownable {

    // The vesting schedule is time-based (i.e. using block timestamps as opposed to e.g. block numbers), and is

    // therefore sensitive to timestamp manipulation (which is something miners can do, to a certain degree).Therefore,

    // it is recommended to avoid using short time durations (less than a minute). Typical vesting schemes, with a

    // cliff period of a year and a duration of four years, are safe to use.

    // solhint-disable not-rely-on-time



    using SafeMath for uint256;



    event TokensReleased(address token, uint256 amount);

    event TokenVestingRevoked(address token);



    // beneficiary of tokens after they are released

    address private _beneficiary;



    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.

    uint256 private _cliff;

    uint256 private _start;

    uint256 private _duration;



    bool private _revocable;



    mapping (address => uint256) private _released;

    mapping (address => bool) private _revoked;



    /**

     * @dev Creates a vesting contract that vests its balance of any ERC20 token to the

     * beneficiary, gradually in a linear fashion until start + duration. By then all

     * of the balance will have vested.

     * @param beneficiary address of the beneficiary to whom vested tokens are transferred

     * @param cliffDuration duration in seconds of the cliff in which tokens will begin to vest

     * @param start the time (as Unix time) at which point vesting starts

     * @param duration duration in seconds of the period in which the tokens will vest

     * @param revocable whether the vesting is revocable or not

     */

    constructor (address beneficiary, uint256 start, uint256 cliffDuration, uint256 duration, bool revocable) public {

        require(beneficiary != address(0));

        require(cliffDuration <= duration);

        require(duration > 0);

        require(start.add(duration) > block.timestamp);



        _beneficiary = beneficiary;

        _revocable = revocable;

        _duration = duration;

        _cliff = start.add(cliffDuration);

        _start = start;

    }



    /**

     * @return the beneficiary of the tokens.

     */

    function beneficiary() public view returns (address) {

        return _beneficiary;

    }



    /**

     * @return the cliff time of the token vesting.

     */

    function cliff() public view returns (uint256) {

        return _cliff;

    }



    /**

     * @return the start time of the token vesting.

     */

    function start() public view returns (uint256) {

        return _start;

    }



    /**

     * @return the duration of the token vesting.

     */

    function duration() public view returns (uint256) {

        return _duration;

    }



    /**

     * @return true if the vesting is revocable.

     */

    function revocable() public view returns (bool) {

        return _revocable;

    }



    /**

     * @return the amount of the token released.

     */

    function released(address token) public view returns (uint256) {

        return _released[token];

    }



    /**

     * @return true if the token is revoked.

     */

    function revoked(address token) public view returns (bool) {

        return _revoked[token];

    }



    /**

     * @notice Transfers vested tokens to beneficiary.

     * @param token ERC20 token which is being vested

     */

    function release(IERC20 token) public {

        uint256 unreleased = _releasableAmount(token);



        require(unreleased > 0);



        _released[address(token)] = _released[address(token)].add(unreleased);



        token.transfer(_beneficiary, unreleased);



        emit TokensReleased(address(token), unreleased);

    }



    /**

     * @notice Allows the owner to revoke the vesting. Tokens already vested

     * remain in the contract, the rest are returned to the owner.

     * @param token ERC20 token which is being vested

     */

    function revoke(IERC20 token) public onlyOwner {

        require(_revocable);

        require(!_revoked[address(token)]);



        uint256 balance = token.balanceOf(address(this));



        uint256 unreleased = _releasableAmount(token);

        uint256 refund = balance.sub(unreleased);



        _revoked[address(token)] = true;



        token.transfer(owner(), refund);



        emit TokenVestingRevoked(address(token));

    }



    /**

     * @dev Calculates the amount that has already vested but hasn't been released yet.

     * @param token ERC20 token which is being vested

     */

    function _releasableAmount(IERC20 token) private view returns (uint256) {

        return _vestedAmount(token).sub(_released[address(token)]);

    }



    /**

     * @dev Calculates the amount that has already vested.

     * @param token ERC20 token which is being vested

     */

    function _vestedAmount(IERC20 token) private view returns (uint256) {

        uint256 currentBalance = token.balanceOf(address(this));

        uint256 totalBalance = currentBalance.add(_released[address(token)]);



        if (block.timestamp < _cliff) {

            return 0;

        } else if (block.timestamp >= _start.add(_duration) || _revoked[address(token)]) {

            return totalBalance;

        } else {

            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);

        }

    }

}