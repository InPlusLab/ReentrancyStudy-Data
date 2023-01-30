/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 * 
 * @dev Default OpenZeppelin
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
 * 
 * @dev Completely default OpenZeppelin.
 */
contract Ownable {
    address payable private _owner;

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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev This has been changed slightly from OpenZeppelin to get rid of the Roles library 
 *      and only allow owner to add pausers (and allow them to renounce).
**/
contract Pauser is Ownable {

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    mapping (address => bool) private pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return pausers[account];
    }

    function addPauser(address account) public onlyOwner {
        _addPauser(account);
    }

    function renouncePauser(address account) public {
        require(msg.sender == account || isOwner());
        _removePauser(account);
    }

    function _addPauser(address account) internal {
        pausers[account] = true;
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        pausers[account] = false;
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable  is Pauser {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.
// ----------------------------------------------------------------------------

library BokkyDateTime {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        uint year;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        uint year;
        uint month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {

    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

/**
 * @dev Subscriptions allows recurring payments to be made to businesses or individuals with
 *      no interaction by the user required after the initial subscription.
**/
contract PostAuditSubscriptions is Pausable {

    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using BokkyDateTime for *;

    // Contract that will be inputting date and prices.
    address public subOracle;

    // Incrementing ID count to assign ID when a new subscription is created.
    // First ID is 1.
    uint256 public idCount;

    // Addresses to pay out fees to.
    address public monarch;

    // Fee to be sent to the Monarch wallet--a value of 100 == 1%.
    uint256 public adminFee;

    // Gas amount that will be paid for each payment call and the maximum gas price that can be used.
    uint256 public gasAmt;
    uint256 public gasPriceCap;

    // User => subscription id => subscription details.
    // Need to change to account for monthly payments and set length.
    mapping (address => mapping (uint256 => Subscription)) public subscriptions;

    // ID => universal data for subscription types.
    mapping (uint256 => Template) public templates;

    // IERC20 and Ether balances of users
    mapping (address => mapping (address => uint256)) public balances;

    // Mapping of tokens that are approved to be used as payment to their number of decimals (we don't want to take fees in worthless tokens).
    mapping (address => uint256) public approvedTokens;

    // Mapping of token => eth conversion in order to pay payment senders accurately. Only able to be changed by SubOracle. uint256 = amount of wei 1 token is worth.
    mapping (address => uint256) public tokenPrices;

    // Emitted when a company creates a new subscription structure.
    event Creation(uint256 indexed id, address indexed recipient, address token, uint256 price, uint256 interval,
                   uint8 target, bool setLen, uint48 payments, address creator, bool payNow, bool payInFiat);

    // User deposits Ether or IERC20 tokens to the contract.
    event Deposit(address indexed user, address indexed token, uint256 balance);

    // User withdraws Ether or IERC20 tokens from the contract.
    event Withdrawal(address indexed user, address indexed token, uint256 balance);

    // Used for when balance changes outside of deposit and withdrawal.
    event NewBals(address[4] users, uint256[4] balances, address token);

    // Emitted if a payment is attempting to be made for a subscription that never existed, has been cancelled, or is not yet due.
    event NotDue(address indexed user, uint256 indexed id);

    // Emit user, id of subscription, and time for subscription payment.
    event Paid(address indexed user, uint256 indexed id, uint48 nextDue, uint256 datetime, bool setLen, uint48 paymentsLeft);

    // Emit user, id of subscription, and time for a payment failure.
    event Failed(address indexed user, uint256 indexed id, uint256 datetime);

    // Emit user, id, and time for new subscription.
    event Subscribed(address indexed user, uint256 indexed id, uint256 datetime, uint48 nextDue);

    // Emit user, id, and time for cancelled subscription.
    event Unsubscribed(address indexed user, uint256 indexed id, uint256 datetime);

    /**
     * @dev Data for a subscription type created by company.
     * @param price The price of the template in token wei or USD wei in the case of payInFiat.
     * @param recipient Company/entity to receive funds.
     * @param token Token to receive funds in.
     * @param amount Amount of the token to receive.
     * @param interval Number of seconds between each payment.
     * @param monthly Whether this is made on a specific day of the month.
     * @param target If monthly, this is the day of the month that the payment should be made.
     * @param setLen Whether or not the subscriptions will have a fixed number of payments.
     * @param payments The number of payments to be made before the subscription cancels if setLen.
     * @param creator The address that created this template.
     * @param payNow Whether or not the first payment should be made immediately.
     * @param payInFiat Allows the template to be paid using a token's USD value.
    **/
    struct Template {
        uint256 price;
        address recipient;
        uint48 interval;
        uint8 target;
        address token;
        bool setLen;
        uint48 payments;
        address creator;
        bool payNow;
        bool payInFiat;
    }

    /**
     * @dev Data for each individual subscription.
     * @param startTime The original unix time this subscription was created.
     * @param lastPaid The last time this subscription was paid, either unix time or month.
     * @param nextDue The next unix time or next month that the subscription is due.
     * @param paymentsLeft The amount of payments left (if the template is setLen)
     * @param startPaid Whether or not the user has paid the first installment of a payNow template.
    **/
    struct Subscription {
        uint48 startTime;
        uint48 lastPaid;
        uint48 nextDue;
        uint48 paymentsLeft;
        bool startPaid;
    }

/** ************************************************* Constructor ******************************************************** **/

    /**
     * @param _subOracle The address of the subscription Oracle contract that will be fetching token prices.
     * @param _monarch The Monarch wallet that will be receiving admin fees.
    **/
    constructor(address _subOracle, address _monarch)
      public
    {
        subOracle = _subOracle;
        approveToken(address(0), true);
        approveToken(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359, true);
        tokenPrices[address(0)] = 1 ether;
        setMonarch(_monarch);
        setAdminFee(100);

        // 40 gwei for test, will lower.
        setGasFees(85000, 40000000000);
    }

/** ************************************************* Deposit/Withdrawal ******************************************************** **/

    /**
     * @dev Deposit an IERC20 or Ether to the contract to fund it for subscriptions.
     * @param _token The address of the token to deposit (0x000... for Ether).
     * @param _amount The amount of the token to deposit (for Ether this will change to msg.value).
    **/
    function deposit(address _token, uint256 _amount)
      public
      payable
      whenNotPaused
    {
        require(approvedTokens[_token] > 0, "You may only deposit approved tokens.");
        require(_amount > 0, "You must deposit a non-zero amount.");

        if (_token != address(0)) {

            IERC20 token = IERC20(_token);
            SafeERC20.safeTransferFrom(token, msg.sender, address(this), _amount);

        } else {

            _amount = msg.value;
            require(_amount > 0, "No Ether was included in the transaction.");

        }

        uint256 newBal = balances[msg.sender][_token].add(_amount);
        balances[msg.sender][_token] = newBal;

        emit Deposit(msg.sender, _token, newBal);
    }

    /**
     * @dev Deposit an IERC20 or Ether to the contract to fund it for subscriptions.
     * @param _token The address of the token to be withdrawn (address(0) for Ether).
     * @param _amount The amount of token to withdraw (msg.value is used for Ether).
    **/
    function withdraw(address _token, uint256 _amount)
      external
    {
        require(_amount > 0, "You must withdraw a non-zero amount.");

        // Will throw if there's an inadequate balance.
        uint256 newBal = balances[msg.sender][_token].sub(_amount);
        balances[msg.sender][_token] = newBal;

        if (_token != address(0)) {

            IERC20 token = IERC20(_token);
            SafeERC20.safeTransfer(token, msg.sender, _amount);

        } else {

            msg.sender.transfer(_amount);

        }

        emit Withdrawal(msg.sender, _token, newBal);
    }

/** ************************************************* Subscriptions ******************************************************** **/

    /**
     * @dev User creates a subscription.
     * @param _id The ID of the template to sign up for that was emitted on template creation.
    **/
    function subscribe(uint256 _id)
      public
      whenNotPaused
    {
        // Require subscription exists
        require(_id != 0 && _id <= idCount, "Subscription does not exist.");

        // Require user is not already subscribed.
        require(subscriptions[msg.sender][_id].lastPaid == 0, "User is already subscribed.");

        Template memory template = templates[_id];

        // Target and interval types require some different information.
        uint48 lastPaid;
        uint48 nextDue;

        if (template.target > 0) {

            lastPaid = uint48(now);

            // Pacific Standard Time
            uint256 pstNow = BokkyDateTime.subHours(now, 8);

            // Simply adding 1 month may not keep target accurate.
            uint256 year = BokkyDateTime.getYear(pstNow);
            uint256 month = BokkyDateTime.getMonth(pstNow);
            uint256 day = BokkyDateTime.getDay(pstNow);

            // If we're before the target in a month it's due, make nextDue this month's target, else next month's.
            if (day < template.target) nextDue = uint48(BokkyDateTime.timestampFromDate(year, month, template.target));
            else nextDue = uint48(BokkyDateTime.timestampFromDate(BokkyDateTime.getYear(BokkyDateTime.addMonths(pstNow, 1)), (month % 12) + 1, template.target));

        } else {

            lastPaid = uint48(now);
            nextDue = uint48(now + template.interval);

        }

        subscriptions[msg.sender][_id] = Subscription(uint48(now), lastPaid, nextDue, template.payments, false);
        emit Subscribed(msg.sender, _id, now, nextDue);

        if (template.payNow) require(payment(msg.sender, _id), "Payment failed.");
    }

    /**
     * @dev Unsubscribe from a service.
     * @param _id ID of the template that the user is currently subscribed to.
    **/
    function unsubscribe(uint256 _id)
      public
    {
        _unsubscribe(msg.sender, _id);
    }

    /**
     * @dev Unsubscribe one of your users from a subscription. May only be used by template creator.
     * @param _user The user to unsubscribe.
     * @param _id The template to unsubscribe the user from.
    **/
    function unsubscribeUser(address _user, uint256 _id)
      public
    {
        require(msg.sender == templates[_id].creator, "Only the template creator may unsubscribe a user.");
        _unsubscribe(_user, _id);
    }

    /**
     * @dev Internal unsubscribe.
     * @param _user The user to unsubscribe.
     * @param _id The of the subscription.
    **/
    function _unsubscribe(address _user, uint256 _id)
      internal
    {
        delete subscriptions[_user][_id];
        emit Unsubscribed(_user, _id, now);
    }

    /**
     * @dev If a user is depositing for a specific subscription, they can use this to do both at once.
     * @param _token The address of the token to be deposited.
     * @param _amount The amount of the token to be deposited.
     * @param _id The ID of the template to subscribe to.
    **/
    function depositAndSubscribe(address _token, uint256 _amount, uint256 _id)
      public
      payable
      whenNotPaused
    {
        deposit(_token, _amount);
        subscribe(_id);
    }

/** ************************************************* Payments ******************************************************** **/

    /**
     * @dev Make a payment for a subscription, may be called by anyone.
     * @param _user The user whose subscription is being paid.
     * @param _id The ID of the subscription.
     * @return Whether the payment was a success or not.
    **/
    function payment(address _user, uint256 _id)
      public
      whenNotPaused
    returns (bool)
    {
        Subscription memory sub = subscriptions[_user][_id];
        Template memory template = templates[_id];

        // Convert Fiat price to a token value. Original token price is in USD wei, return is token wei.
        if (template.payInFiat) template.price = tokenToFiat(template.token, template.price);

        // Check subscription for whether it's due.
        if (!checkDue(_user, _id, template, sub)) return false;

        // Update the 4 balances being altered (user, recipient, monarch, payment daemon).
        updateBals(_user, template);

        // Set new due dates.
        sub = updateDue(_user, _id, template, sub);

        emit Paid(_user, _id, sub.nextDue, now, template.setLen, sub.paymentsLeft);

        return true;
    }

    /**
     * @dev Accepts token and USD amount desired then finds token value equivalent.
     * @param _token The address of the token to convert.
     * @param _usdAmount The amount of USD the token amount must equal.
     * @return How much Dai the given token and amount is worth.
    **/
    function tokenToFiat(address _token, uint256 _usdAmount)
      public
      view
    returns (uint256 tokenAmount)
    {
        // Dai is our USD stand-in.
        uint256 daiPerEth = tokenPrices[0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359];
        uint256 tokenPerEth = tokenPrices[_token];

        // (USD * buffer) / ((Eth USD price * buffer) / Eth token price).
        tokenAmount = (_usdAmount.mul(1 ether)).div(((daiPerEth.mul(1 ether)).div((tokenPerEth))));

        // Hacked approvedTokens into also saving the decimals of a token.
        uint256 decimals = 10 ** approvedTokens[_token];
        tokenAmount = tokenAmount.mul(decimals).div(1 ether);
    }

    /**
     * @dev Check whether the payment is due and if it can be paid.
     * @param _user The address of the user who is paying.
     * @param _id The id of the subscription to update.
     * @param _template Memory struct of the template information.
     * @param _sub Memory struct of the user subscription information.
     * @return Whether or not a payment is currently due.
    **/
    function checkDue(address _user, uint256 _id, Template memory _template, Subscription memory _sub)
      internal
    returns (bool due)
    {
        // We must check user balance and allowance beforehand so, in the case of bulk payments, one failed payment won't revert everything.
        uint256 balance = balances[_user][_template.token];

        // Fail if not enough balance.
        if (balance < _template.price) {

            emit Failed(_user, _id, now);
            return false;

        }

        // Protection in case user is not subscribed.
        if (_sub.lastPaid == 0) {

            emit NotDue(_user, _id);
            return false;

        }

        // If this is the first payment and payNow is true, let it through.
        if (_template.payNow && !_sub.startPaid) return true;

        // Check if interval payment is owed.
        if (_sub.nextDue >= now) {

            emit NotDue(_user, _id);
            return false;

        }

        return true;
    }

    /**
     * @dev Update each relevant balance.
     * @param _user The address of the user who is paying.
     * @param _template Memory struct of the template information.
    **/
    function updateBals(address _user, Template memory _template)
      internal
    {
        address token = _template.token;
        uint256 price = _template.price;
        uint256 monarchFee = price / adminFee;

        uint256 gasPrice = tx.gasprice;
        if (gasPrice > gasPriceCap) gasPrice = gasPriceCap;

        // If a token is being paid, convert the Ether gas fee to equivalent token value.
        uint256 gasFee;
        if (token != address(0)) gasFee = (tokenPrices[token].mul(gasAmt).mul(gasPrice)).div(1 ether);
        else gasFee = gasAmt.mul(gasPrice);

        // User balance - price
        uint256 userBal = balances[_user][token].sub(price);
        balances[_user][token] = userBal;

        // Recipient balance + (price - (gasFee + monarchFee))
        uint256 recipBal = balances[_template.recipient][token].add(price.sub(gasFee.add(monarchFee)));
        balances[_template.recipient][token] = recipBal;

        // Pay daemon balance + gasFee
        uint256 paydBal = balances[msg.sender][token].add(gasFee);
        balances[msg.sender][token] = paydBal;

        // Monarch balance + monarchFee
        uint256 monarchBal = balances[monarch][token].add(monarchFee);
        balances[monarch][token] = monarchBal;

        emit NewBals([_user, _template.recipient, msg.sender, monarch], [userBal, recipBal, paydBal, monarchBal], token);
    }

    /**
     * @dev Update due dates and payments left.
     * @param _user The address of the user who is paying.
     * @param _id The id of the subscription to update.
     * @param _template Memory struct of the template information.
     * @param _sub Memory struct of the user subscription information.
     * @return The user's updated subscription struct.
    **/
    function updateDue(address _user, uint256 _id, Template memory _template, Subscription memory _sub)
      internal
    returns (Subscription memory)
    {
        // We don't want lastPaid and nextDue changed if it's a payNow payment.
        bool payNow = _template.payNow && !_sub.startPaid;

        // If this is called late, we don't want to use 'now' but rather give them 'interval' time from last payment.
        if (!payNow && _template.interval > 0) {

            _sub.lastPaid = _sub.nextDue;
            _sub.nextDue = _sub.lastPaid + _template.interval;

        } else if (!payNow) {

            _sub.lastPaid = _sub.nextDue;
            _sub.nextDue = uint48(BokkyDateTime.addMonths(_sub.lastPaid, 1));

        }

        // If there's a set length, alter paymentsLeft, unsubscribe if 0.
        if (_template.setLen) _sub.paymentsLeft = _sub.paymentsLeft - 1;

        // Set original payment to true.
        if (payNow) _sub.startPaid = true;

        if (_template.setLen && _sub.paymentsLeft == 0) _unsubscribe(_user, _id);
        else subscriptions[_user][_id] = _sub;

        return _sub;
    }

    /**
     * @dev Used for bulk payments.
     * @param _users Address of users to ping contracts for payments.
     * @param _ids IDs of template to pay for the corresponding user.
    **/
    function bulkPayments(address[] calldata _users, uint256[] calldata _ids)
      external
      whenNotPaused
    {
        require(_users.length == _ids.length, "The submitted arrays are of uneven length.");

        for (uint256 i = 0; i < _users.length; i++) {

            payment(_users[i], _ids[i]);

        }
    }

/** ************************************************* Creation ******************************************************** **/

    /**
     * @dev Used by a company to create a new subscription structure.
     * @param _recipient The entity to be paid by the subscription.
     * @param _token The token the subscription should be paid in.
     * @param _price The amount of tokens to be paid (token wei).
     * @param _interval How often the subscription should be paid.
     * @param _target The target day of the month to be paid (if not interval).
     * @param _setLen Whether or not there will be a fixed amount of payments.
     * @param _payments The number of payments if fixed.
     * @param _payNow True if the payment is to be made immediately.
     * @param _payInFiat True if the price should be paid in Fiat (i.e. $10 USD of the token each interval).
     * @return The ID of the newly created template.
    **/
    function createTemplate(address payable _recipient, address _token, uint256 _price, uint48 _interval,
                            uint8 _target, bool _setLen, uint48 _payments, bool _payNow, bool _payInFiat)
      public
      whenNotPaused
    returns (uint256 id)
    {
        // Make sure the template is EITHER interval or target. Interval should be more than a day to prevent payment spam.
        require((_interval >= 86400 && _target == 0) || (_interval == 0 && _target > 0), "You must choose >= 1 day interval or target.");

        // Prevent overflow with a max interval of 100 years.
        require(_interval <= 3153600000, "You may not have an interval of over 100 years.");

        // Target must be a valid day of the month.
        if (_target > 0) require(_target <= 28, "Target must be a valid day.");

        // Token must be on our approved list.
        require(approvedTokens[_token] > 0, "The desired token is not on the approved tokens list.");

        // Price must be above $1.
        require(_price >= tokenToFiat(_token, 1 ether), "Your subscription must have a price of at least $1.");

        // Must have a set amount of payments if it's a set length and vice versa.
        if (_setLen) require(_payments > 0, "A set-length template must have non-zero payments.");
        else require(_payments == 0, "A non-set-length template must have zero payments.");

        Template memory template = Template(_price, _recipient, _interval, _target, _token, _setLen, _payments, msg.sender, _payNow, _payInFiat);

        idCount++;
        id = idCount;
        templates[id] = template;

        emit Creation(id, _recipient, _token, _price, _interval, _target, _setLen, _payments, msg.sender, _payNow, _payInFiat);
    }

    /**
     * @dev Simpler way for an individual to make their own subscription and subscribe with only one function call.
     *      Same params as createSubscription.
    **/
    function createAndSubscribe(address payable _recipient, address _token, uint256 _price, uint48 _interval,
                                uint8 _target, bool _setLen, uint48 _payments, bool _payNow, bool _payInFiat)
      external
      whenNotPaused
    {
        uint256 id = createTemplate(_recipient, _token, _price, _interval, _target, _setLen, _payments, _payNow, _payInFiat);
        subscribe(id);
    }

    /**
     * @dev As above but with deposit added.
     * @param _amount The amount of token wei to deposit.
    **/
    function createDepositAndSubscribe(address payable _recipient, address _token, uint256 _price, uint48 _interval, uint8 _target,
                                       bool _setLen, uint48 _payments, bool _payNow, bool _payInFiat, uint256 _amount)
        external
        payable
        whenNotPaused
    {
        uint256 id = createTemplate(_recipient, _token, _price, _interval, _target, _setLen, _payments, _payNow, _payInFiat);
        deposit(_token, _amount);
        subscribe(id);
    }

/** ************************************************* onlyOracle ******************************************************** **/

    /**
     * @dev For functions that only admins can call.
    **/
    modifier onlyOracle
    {
        require(msg.sender == subOracle, "Only the oracle may call this function.");
        _;
    }

    /**
     * @dev Used by the subscription oracle to set the current token prices (in Ether).
     * @param _tokens Array of the token addresses.
     * @param _prices Array of the prices for each address.
    **/
    function setPrices(address[] calldata _tokens, uint256[] calldata _prices)
      external
      onlyOracle
    {
        require(_tokens.length == _prices.length, "Submitted arrays are of uneven length.");

        for (uint256 i = 0; i < _tokens.length; i++) {

            require(approvedTokens[_tokens[i]] > 0, "Price may only be set for approved tokens.");
            tokenPrices[_tokens[i]] = _prices[i];

        }
    }

/** ************************************************* Privileged ******************************************************** **/

    /**
     * @dev Used in the case that something happens to the contract or the contract is being updated and all funds must be withdrawn.
     * @param _users Array of users to withdraw for.
     * @param _tokens Token to withdraw for the corresponding user.
    **/
    function bulkWithdraw(address payable[] calldata _users, address[] calldata _tokens)
      external
      onlyOwner
    {
        require(_users.length == _tokens.length, "Submitted arrays are of uneven length.");

        for (uint256 i = 0; i < _users.length; i++) {

            address payable user = _users[i];
            address token = _tokens[i];

            uint256 balance = balances[user][token];
            if (balance == 0) continue;

            balances[user][token] = 0;

            if (token != address(0)) {

                IERC20 tokenC = IERC20(token);
                SafeERC20.safeTransfer(tokenC, user, balance);

                // require(tokenC.transfer(user, balance), "Token transfer failed.");

            } else {

                // We don't want one user to cause a revert so we're allowing send to fail.
                if (!user.send(balance)) {
                    balances[user][token] = balance;
                    continue;
                }

            }

            emit Withdrawal(user, token, balance);
        }

    }

    /**
     * @dev Used to change the Monarch address that will be given the admin fees.
     * @param _monarch The new Monarch wallet address.
    **/
    function setMonarch(address _monarch)
      public
      onlyOwner
    {
        monarch = _monarch;
    }

    /**
     * @dev Used by Monarch to approve (or disapprove) tokens that may be used for payment.
     * @param _token The address of the token in question.
     * @param _add Whether to add or remove the token.
    **/
    function approveToken(address _token, bool _add)
      public
      onlyPauser
    {
        if (_add) {

            uint256 decimals;
            //if (_token == address(0)) decimals = 18;
            //else decimals = uint256(IERC20(_token).decimals());
            decimals = 18;

            approvedTokens[_token] = decimals;

        } else {

            delete approvedTokens[_token];

        }
    }

    /**
     * @dev Used by Monarch to change the current gas fee.
     * @param _gasAmt The amount of gas that the payment function will cost to execute.
     * @param _gasPriceCap The maximum gwei cost that may be used to pay for sending payments.
    **/
    function setGasFees(uint256 _gasAmt, uint256 _gasPriceCap)
      public
      onlyPauser
    {
        // Generally this is a constant number but we may want it lowered in some cases.
        require(_gasAmt <= 85000, "Desired gas amount is too high.");

        // Limit gas price to 40 gwei to dissuade malicious admins.
        require(_gasPriceCap <= 40000000000, "Desired gas price is too high.");

        gasAmt = _gasAmt;
        gasPriceCap = _gasPriceCap;
    }

    /**
     * @dev Used by Monarch to change the current gas fee.
     * @param _adminFee is a number to divide price by: i.e. adminFee of 100 is 1%
    **/
    function setAdminFee(uint256 _adminFee)
      public
      onlyPauser
    {
        // Limit fee to 10% to dissuade malicious admins.
        require(_adminFee >= 10, "Desired fee is too large.");
        adminFee = _adminFee;
    }

}