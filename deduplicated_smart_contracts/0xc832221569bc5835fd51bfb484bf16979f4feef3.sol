/**
 *Submitted for verification at Etherscan.io on 2020-02-26
*/

/**
 *Submitted for verification at Etherscan.io on 2020-01-17
*/

// File: @openzeppelin\contracts\math\SafeMath.sol

pragma solidity ^0.5.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: @openzeppelin\contracts\ownership\Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: node_modules\@openzeppelin\contracts\access\Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: @openzeppelin\contracts\access\roles\WhiteListAdminRole.sol

pragma solidity ^0.5.0;


/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}



pragma solidity ^0.5.0;




contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Vesting is Ownable, WhitelistAdminRole {

    struct Round {
        uint cliff;
        uint ratePerWeek;
        uint count;
        bool isExist;
        address[] holder;
        uint[] balance;
        uint[] withdraw;
        bool[] enable;
    }

    uint listingDate = 0;

    address public tokenAddress;
    string public roundList;

    mapping (string => Round) public rounds;

    constructor() public {}

    modifier onlyListed() {
        require(listingDate > 0, "No ListingDate");
        _;
    }

    function setToken(address token) public onlyWhitelistAdmin {
        tokenAddress = token;
    }

    function setListingDate(uint timestamp) public onlyWhitelistAdmin {
        listingDate = timestamp;
    }

    function addHolders(string memory roundName, uint cliff, uint weekUnlock, address[] memory holders, uint256[] memory tokens) public onlyWhitelistAdmin {

        if (rounds[roundName].isExist != true) {

            if (bytes(roundList).length == 0){
                roundList = roundName;
            } else {
                roundList = concat(roundList, roundName);
            }

            rounds[roundName] = Round(cliff, weekUnlock, 0, true,
                new address[](0),
                new uint[](0),
                new uint[](0),
                new bool[](0)
            );
        }

        for (uint8 i = 0; i < holders.length; i++) {
            rounds[roundName].count++;
            rounds[roundName].holder.push(holders[i]);
            rounds[roundName].balance.push(tokens[i]);
            rounds[roundName].withdraw.push(0);
            rounds[roundName].enable.push(true);
        }
    }

 
    function setEnable(string memory roundName, address addr, bool enable) public onlyWhitelistAdmin {
        Round storage r = rounds[roundName];

        for (uint8 i = 0; i < r.holder.length; i++) {
            if (r.holder[i] == addr) {
                r.enable[i] = enable;
            }
        }

    }

  
    function send(string memory roundName) public onlyWhitelistAdmin onlyListed {
        Round storage r = rounds[roundName];

        for (uint8 i = 0; i < r.holder.length; i++) {

        uint available = calcUnlock(r.balance[i], r.cliff, listingDate, 7, r.ratePerWeek, now);
        	if(available > r.withdraw[i] ) {
    
    	    uint unlockBal = getRate(r.balance[i], r.ratePerWeek);
    
    	    uint afterBal = SafeMath.add(r.withdraw[i], unlockBal);
    
                if (r.balance[i] < afterBal) {
                    unlockBal = SafeMath.sub(r.balance[i], r.withdraw[i]);
                }
    
    
                if (unlockBal > 0) {
                    ERC20(tokenAddress).transfer(r.holder[i], unlockBal);
                    r.withdraw[i] = SafeMath.add(r.withdraw[i], unlockBal);
                }
    	    }
        }
    }

// 출금수량확인용
    function getAvailable(string memory roundName, address addr, uint timestamp) public view returns (uint256) {
        Round memory r = rounds[roundName];
        uint256 available = 0;

        for (uint8 i = 0; i < r.holder.length; i++) {
            if (r.holder[i] == addr) {
                available = calcUnlock(r.balance[i], r.cliff, listingDate, 7, r.ratePerWeek, timestamp) - r.withdraw[i];
                break;
            }
        }
        return available;
    }

    function getInfo(string memory roundName, address addr) public view returns (uint256, uint256) {
        Round memory r = rounds[roundName];
        uint256 withdraw;
        uint256 balance;

        for (uint8 i = 0; i < r.holder.length; i++) {
            if (r.holder[i] == addr) {
                balance = r.balance[i];
                withdraw = r.withdraw[i];
                break;
            }
        }

        return (balance, withdraw);
    }

    function calcUnlock(uint fund, uint cliff, uint listing, uint unlockTerm, uint unlockRate, uint target) public pure returns (uint256) {

    uint cliff_days = cliff * 86400; 
    uint unlock_days = unlockTerm * 86400;			
	uint deltaW = 0;
	uint delta = 0;
	if(target > (listing + cliff_days) ){

		
		delta = (target - listing) - cliff_days + unlock_days;		

		deltaW = SafeMath.mul(SafeMath.div(delta, unlock_days), getRate(fund, unlockRate));

		

		if(deltaW > fund){	
			deltaW=fund;
		}

	}else{	
			 deltaW = 0;
	}

        return deltaW;
    }

    function tokenBalance() public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    function distribute(address[] memory holders, uint256[] memory values) public onlyWhitelistAdmin {
        for (uint256 i = 0; i < holders.length; i++) {
            ERC20(tokenAddress).transfer(holders[i], values[i]);
        }
    }

    function withdraw() public onlyOwner {
        uint256 balance = ERC20(tokenAddress).balanceOf(address(this));
        ERC20(tokenAddress).transfer(owner(), balance);
    }

    function getRate(uint value, uint rate) public pure returns (uint256) {
        return (value * rate) / 1000;
    }

    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, ",", b));
    }
}