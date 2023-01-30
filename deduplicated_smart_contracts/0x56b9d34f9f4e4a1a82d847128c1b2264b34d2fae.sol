/**
 *Submitted for verification at Etherscan.io on 2020-07-28
*/

pragma solidity 0.6.6;

// SPDX-License-Identifier: Unlicensed


// SPDX-License-Identifier: Unlicensed

library AddressSet {
    
    struct Set {
        mapping(address => uint) keyPointers;
        address[] keyList;
    }

    /**
     * @notice insert a key. 
     * @dev duplicate keys are not permitted.
     * @param self storage pointer to a Set. 
     * @param key value to insert.
     */    
    function insert(Set storage self, address key) internal {
        require(!exists(self, key), "AddressSet: key already exists in the set.");
        self.keyPointers[key] = self.keyList.length;
        self.keyList.push(key);
    }

    /**
     * @notice remove a key.
     * @dev key to remove must exist. 
     * @param self storage pointer to a Set.
     * @param key value to remove.
     */    
    function remove(Set storage self, address key) internal {
        require(exists(self, key), "AddressSet: key does not exist in the set.");
        uint last = count(self) - 1;
        uint rowToReplace = self.keyPointers[key];
        if(rowToReplace != last) {
            address keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        self.keyList.pop;
    }

    /**
     * @notice count the keys.
     * @param self storage pointer to a Set. 
     */       
    function count(Set storage self) internal view returns(uint) {
        return(self.keyList.length);
    }

    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param key value to check. 
     * @return bool true: Set member, false: not a Set member.
     */  
    function exists(Set storage self, address key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param index row to enumerate. Must be < count() - 1.
     */      
    function keyAtIndex(Set storage self, uint index) internal view returns(address) {
        return self.keyList[index];
    }
}

// SPDX-License-Identifier: MIT

// SPDX-License-Identifier: MIT


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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: Unlicensed

library Bytes32Set {
    
    struct Set {
        mapping(bytes32 => uint) keyPointers;
        bytes32[] keyList;
    }
    
    /**
     * @notice insert a key. 
     * @dev duplicate keys are not permitted.
     * @param self storage pointer to a Set. 
     * @param key value to insert.
     */
    function insert(Set storage self, bytes32 key) internal {
        require(!exists(self, key), "Bytes32Set: key already exists in the set.");
        self.keyPointers[key] = self.keyList.length;
        self.keyList.push(key);
    }

    /**
     * @notice remove a key.
     * @dev key to remove must exist. 
     * @param self storage pointer to a Set.
     * @param key value to remove.
     */
    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "Bytes32Set: key does not exist in the set.");
        uint last = count(self) - 1;
        uint rowToReplace = self.keyPointers[key];
        if(rowToReplace != last) {
            bytes32 keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        self.keyList.pop();
    }

    /**
     * @notice count the keys.
     * @param self storage pointer to a Set. 
     */    
    function count(Set storage self) internal view returns(uint) {
        return(self.keyList.length);
    }
    
    /**
     * @notice check if a key is in the Set.
     * @param self storage pointer to a Set.
     * @param key value to check. 
     * @return bool true: Set member, false: not a Set member.
     */
    function exists(Set storage self, bytes32 key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    /**
     * @notice fetch a key by row (enumerate).
     * @param self storage pointer to a Set.
     * @param index row to enumerate. Must be < count() - 1.
     */    
    function keyAtIndex(Set storage self, uint index) internal view returns(bytes32) {
        return self.keyList[index];
    }
}

library FIFOSet {
    
    using SafeMath for uint;
    using Bytes32Set for Bytes32Set.Set;
    
    bytes32 constant NULL = bytes32(0);
    
    struct FIFO {
        bytes32 firstKey;
        bytes32 lastKey;
        mapping(bytes32 => KeyStruct) keyStructs;
        Bytes32Set.Set keySet;
    }

    struct KeyStruct {
            bytes32 nextKey;
            bytes32 previousKey;
    }

    function count(FIFO storage self) internal view returns(uint) {
        return self.keySet.count();
    }
    
    function first(FIFO storage self) internal view returns(bytes32) {
        return self.firstKey;
    }
    
    function last(FIFO storage self) internal view returns(bytes32) {
        return self.lastKey;
    }
    
    function exists(FIFO storage self, bytes32 key) internal view returns(bool) {
        return self.keySet.exists(key);
    }
    
    function isFirst(FIFO storage self, bytes32 key) internal view returns(bool) {
        return key==self.firstKey;
    }
    
    function isLast(FIFO storage self, bytes32 key) internal view returns(bool) {
        return key==self.lastKey;
    }    
    
    function previous(FIFO storage self, bytes32 key) internal view returns(bytes32) {
        require(exists(self, key), "FIFOSet: key not found") ;
        return self.keyStructs[key].previousKey;
    }
    
    function next(FIFO storage self, bytes32 key) internal view returns(bytes32) {
        require(exists(self, key), "FIFOSet: key not found");
        return self.keyStructs[key].nextKey;
    }
    
    function append(FIFO storage self, bytes32 key) internal {
        require(key != NULL, "FIFOSet: key cannot be zero");
        require(!exists(self, key), "FIFOSet: duplicate key"); 
        bytes32 lastKey = self.lastKey;
        KeyStruct storage k = self.keyStructs[key];
        KeyStruct storage l = self.keyStructs[lastKey];
        if(lastKey==NULL) {                
            self.firstKey = key;
        } else {
            l.nextKey = key;
        }
        k.previousKey = lastKey;
        self.keySet.insert(key);
        self.lastKey = key;
    }

    function remove(FIFO storage self, bytes32 key) internal {
        require(exists(self, key), "FIFOSet: key not found");
        KeyStruct storage k = self.keyStructs[key];
        bytes32 keyBefore = k.previousKey;
        bytes32 keyAfter = k.nextKey;
        bytes32 firstKey = first(self);
        bytes32 lastKey = last(self);
        KeyStruct storage p = self.keyStructs[keyBefore];
        KeyStruct storage n = self.keyStructs[keyAfter];
        
        if(count(self) == 1) {
            self.firstKey = NULL;
            self.lastKey = NULL;
        } else {
            if(key == firstKey) {
                n.previousKey = NULL;
                self.firstKey = keyAfter;  
            } else 
            if(key == lastKey) {
                p.nextKey = NULL;
                self.lastKey = keyBefore;
            } else {
                p.nextKey = keyAfter;
                n.previousKey = keyBefore;
            }
        }
        self.keySet.remove(key);
        delete self.keyStructs[key];
    }
}
// SPDX-License-Identifier: MIT


// SPDX-License-Identifier: MIT


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// SPDX-License-Identifier: MIT


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface Maker {
    function read() external view returns(uint);
}

contract HodlDex is Ownable {
    
    using Address for address payable;                              // OpenZeppelin address utility
    using SafeMath for uint;                                        // OpenZeppelin safeMath utility
    using Bytes32Set for Bytes32Set.Set;                            // Unordered key sets
    using AddressSet for AddressSet.Set;                            // Unordered address sets
    using FIFOSet for FIFOSet.FIFO;                                 // FIFO key sets
    
    Maker maker = Maker(0x729D19f657BD0614b4985Cf1D82531c67569197B);// EthUsd price Oracle

    bytes32 constant NULL = bytes32(0); 
    uint constant HODL_PRECISION = 10 ** 10;                        // HODL token decimal places
    uint constant USD_PRECISION = 10 ** 18;                         // Precision for HODL:USD
    uint constant TOTAL_SUPPLY = 20000000 * (10**10);               // Total supply - initially goes to the reserve, which is address(this)
    uint constant SLEEP_TIME = 30 days;                             // Grace period before time-based accrual kicks in
    uint constant DAILY_ACCRUAL_RATE_DECAY = 999999838576236000;    // Rate of decay applied daily reduces daily accrual APR to about 5% after 30 years
    uint constant USD_TXN_ADJUSTMENT = 10**14;                      // $0.0001 with 18 decimal places of precision - 1/100th of a cent
    
    uint public BIRTHDAY;                                           // Now time when the contract was deployed
    uint public minOrderUsd = 50 * 10 ** 18;                        // Minimum order size is $50 in USD precision
    uint public maxOrderUsd = 500 * 10 ** 18;                       // Maximum order size is $500 is USD precision
    uint public maxThresholdUsd = 10 * 10 ** 18;                    // Order limits removed when HODL_USD exceeds $10
    uint public maxDistributionUsd = 250 * 10 ** 18;                // Maximum distribution value
    uint public accrualDaysProcessed;                               // Days of stateful accrual applied
    uint public distributionNext;                                   // Next distribution to process cursor
    uint public entropyCounter;                                     // Tally of unique order IDs and distributions generated 
    uint public distributionDelay = 1 days;                         // Reserve sale distribution delay

    IERC20 token;                                                   // The HODL ERC20 tradable token 
 
    /**************************************************************************************
     * @dev The following values are inspected through the rates() function
     **************************************************************************************/

    uint private HODL_USD;                                          // HODL:USD exchange rate last recorded
    uint private DAILY_ACCRUAL_RATE = 1001900837677230000;          // Initial daily accrual is 0.19% (100.19% multiplier) which is about 100% APR     
    
    struct User {
        FIFOSet.FIFO sellOrderIdFifo;                               // User sell orders in no particular order
        FIFOSet.FIFO buyOrderIdFifo;                                // User buy orders in no particular order
        uint balanceEth;
        uint balanceHodl;
    }   
    struct SellOrder {
        address seller;
        uint volumeHodl;
        uint askUsd;
    }    
    struct BuyOrder {
        address buyer;
        uint bidEth;
    }
    struct Distribution {
        uint amountEth;
        uint timeStamp;
    }
    
    mapping(address => User) userStruct;
    mapping(bytes32 => SellOrder) public sellOrder;
    mapping(bytes32 => BuyOrder) public buyOrder; 

    FIFOSet.FIFO sellOrderIdFifo;                                   // SELL orders in order of declaration
    FIFOSet.FIFO buyOrderIdFifo;                                    // BUY orders in order of declaration
    AddressSet.Set hodlerAddrSet;                                   // Users with a HODL balance > 0 in no particular order
    Distribution[] public distribution;                             // Pending distributions in order of declaration
    
    modifier ifRunning {
        require(isRunning(), "Contact is not initialized.");
        _;
    }
    
    // Deferred pseudo-random reserve sale proceeds distribution
    modifier distribute {
        uint distroEth;
        if(distribution.length > distributionNext) {
            Distribution storage d = distribution[distributionNext];
            if(d.timeStamp.add(distributionDelay) < now) {
                uint entropy = uint(keccak256(abi.encodePacked(entropyCounter, HODL_USD, maker.read(), blockhash(block.number))));
                uint luckyWinnerRow = entropy % hodlerAddrSet.count();
                address winnerAddr = hodlerAddrSet.keyAtIndex(luckyWinnerRow);
                User storage w = userStruct[winnerAddr];
                if(convertEthToUsd(d.amountEth) > maxDistributionUsd) {
                    distroEth = convertUsdToEth(maxDistributionUsd);
                    d.amountEth = d.amountEth.sub(distroEth);
                } else {
                    distroEth = d.amountEth;
                    delete distribution[distributionNext];
                    distributionNext = distributionNext.add(1);
                }
                w.balanceEth = w.balanceEth.add(distroEth);
                entropyCounter++;
                emit DistributionAwarded(msg.sender, distributionNext, winnerAddr, distroEth);
            }
        }
        _;
    }

    modifier accrueByTime {
        _accrueByTime();
        _;
    }
    
    event DistributionAwarded(address processor, uint indexed index, address indexed recipient, uint amount);
    event Deployed(address admin);
    event HodlTIssued(address indexed user, uint amount);
    event HodlTRedeemed(address indexed user, uint amount);
    event SellHodlC(address indexed seller, uint quantityHodl, uint lowGas);
    event SellOrderFilled(address indexed buyer, bytes32 indexed orderId, address indexed seller, uint txnEth, uint txnHodl);
    event SellOrderOpened(bytes32 indexed orderId, address indexed seller, uint quantityHodl, uint askUsd);
    event BuyHodlC(address indexed buyer, uint amountEth, uint lowGas);
    event BuyOrderFilled(address indexed seller, bytes32 indexed orderId, address indexed buyer, uint txnEth, uint txnHodl);
    event BuyOrderRefunded(address indexed seller, bytes32 indexed orderId, uint refundedEth);
    event BuyFromReserve(address indexed buyer, uint txnEth, uint txnHodl);
    event BuyOrderOpened(bytes32 indexed orderedId, address indexed buyer, uint amountEth);
    event SellOrderCancelled(address indexed userAddr, bytes32 indexed orderId);
    event BuyOrderCancelled(address indexed userAddr, bytes32 indexed orderId);
    event UserDepositEth(address indexed user, uint amountEth);
    event UserWithdrawEth(address indexed user, uint amountEth);
    event UserInitialized(address admin, address indexed user, uint hodlCR, uint ethCR);
    event UserUninitialized(address admin, address indexed user, uint hodlDB, uint ethDB);
    event PriceSet(address admin, uint hodlUsd);
    event TokenSet(address admin, address hodlToken);
    event MakerSet(address admin, address maker);
    
    constructor() public {
        userStruct[address(this)].balanceHodl = TOTAL_SUPPLY;
        BIRTHDAY = now;
        emit Deployed(msg.sender);
    }

    function keyGen() private returns(bytes32 key) {
        entropyCounter++;
        return keccak256(abi.encodePacked(address(this), msg.sender, entropyCounter));
    }

    /**************************************************************************************
     * Anyone can nudge the time-based accrual forward
     **************************************************************************************/ 

    function poke() external distribute ifRunning {
        _accrueByTime();
    }

    /**************************************************************************************
     * 1:1 Convertability to HODLT ERC20
     **************************************************************************************/    

    function hodlTIssue(uint amount) external distribute accrueByTime ifRunning {
        User storage u = userStruct[msg.sender];
        User storage t = userStruct[address(token)];
        u.balanceHodl = u.balanceHodl.sub(amount);
        t.balanceHodl = t.balanceHodl.add(amount);
        _pruneHodler(msg.sender);
        token.transfer(msg.sender, amount);
        emit HodlTIssued(msg.sender, amount);
    }

    function hodlTRedeem(uint amount) external distribute accrueByTime ifRunning {
        User storage u = userStruct[msg.sender];
        User storage t = userStruct[address(token)];
        u.balanceHodl = u.balanceHodl.add(amount);
        t.balanceHodl = t.balanceHodl.sub(amount);
        _makeHodler(msg.sender);
        token.transferFrom(msg.sender, address(this), amount);
        emit HodlTRedeemed(msg.sender, amount);
    }

    /**************************************************************************************
     * Sell HodlC to buy orders, or if no buy orders open a sell order.
     * Selectable low gas protects against future EVM price changes.
     * Completes as much as possible (gas) and return unprocessed Hodl.
     **************************************************************************************/ 

    function sellHodlC(uint quantityHodl, uint lowGas) external accrueByTime distribute ifRunning returns(bytes32 orderId) {
        emit SellHodlC(msg.sender, quantityHodl, lowGas);
        uint orderUsd = convertHodlToUsd(quantityHodl); 
        uint orderLimit = orderLimit();
        require(orderUsd >= minOrderUsd, "Sell order is less than minimum USD value");
        require(orderUsd <= orderLimit || orderLimit == 0, "Order exceeds USD limit");
        quantityHodl = _fillBuyOrders(quantityHodl, lowGas);
        orderId = _openSellOrder(quantityHodl);
        _pruneHodler(msg.sender);
    }

    function _fillBuyOrders(uint quantityHodl, uint lowGas) private returns(uint remainingHodl) {
        User storage u = userStruct[msg.sender];
        address buyerAddr;
        bytes32 buyId;
        uint orderHodl;
        uint orderEth;
        uint txnEth;
        uint txnHodl;

        while(buyOrderIdFifo.count() > 0 && quantityHodl > 0) { //
            if(gasleft() < lowGas) return 0;
            buyId = buyOrderIdFifo.first();
            BuyOrder storage o = buyOrder[buyId]; 
            buyerAddr = o.buyer;
            User storage b = userStruct[o.buyer];
            
            orderEth = o.bidEth;
            orderHodl = convertEthToHodl(orderEth);
            if(orderHodl == 0) {
                // Order is now too small to fill. Refund eth and prune.
                if(orderEth > 0) {
                    b.balanceEth = b.balanceEth.add(orderEth);
                    emit BuyOrderRefunded(msg.sender, buyId, orderEth); 
                }
                delete buyOrder[buyId];
                buyOrderIdFifo.remove(buyId);
                b.buyOrderIdFifo.remove(buyId);                   
            } else {
                txnEth  = convertHodlToEth(quantityHodl);
                txnHodl = quantityHodl;
                if(orderEth < txnEth) {
                    txnEth = orderEth;
                    txnHodl = orderHodl;
                }
                u.balanceHodl = u.balanceHodl.sub(txnHodl, "Insufficient Hodl for computed order volume");
                b.balanceHodl = b.balanceHodl.add(txnHodl);
                u.balanceEth = u.balanceEth.add(txnEth);
                o.bidEth = o.bidEth.sub(txnEth, "500 - Insufficient ETH for computed order volume");
                quantityHodl = quantityHodl.sub(txnHodl, "500 - Insufficient order Hodl remaining to fill order");  
                _makeHodler(buyerAddr);
                _accrueByTransaction();
                emit BuyOrderFilled(msg.sender, buyId, o.buyer, txnEth, txnHodl);
            }          
        }
        remainingHodl = quantityHodl;
    }

    function _openSellOrder(uint quantityHodl) private returns(bytes32 orderId) {
        User storage u = userStruct[msg.sender];
        // Do not allow low gas to result in small sell orders or sell orders to exist while buy orders exist
        if(convertHodlToUsd(quantityHodl) > minOrderUsd && buyOrderIdFifo.count() == 0) { 
            orderId = keyGen();
            (uint askUsd, /*uint accrualRate*/) = rates();
            SellOrder storage o = sellOrder[orderId];
            sellOrderIdFifo.append(orderId);
            u.sellOrderIdFifo.append(orderId);           
            o.seller = msg.sender;
            o.volumeHodl = quantityHodl;
            o.askUsd = askUsd;
            u.balanceHodl = u.balanceHodl.sub(quantityHodl, "Insufficient Hodl to open sell order");
            emit SellOrderOpened(orderId, msg.sender, quantityHodl, askUsd);
        }
    }

    /**************************************************************************************
     * Buy HodlC from sell orders, or if no sell orders, from reserve. Lastly, open a 
     * buy order is the reserve is sold out.
     * Selectable low gas protects against future EVM price changes.
     * Completes as much as possible (gas) and returns unspent Eth.
     **************************************************************************************/ 

    function buyHodlC(uint amountEth, uint lowGas) external accrueByTime distribute ifRunning returns(bytes32 orderId) {
        emit BuyHodlC(msg.sender, amountEth, lowGas);
        uint orderLimit = orderLimit();         
        uint orderUsd = convertEthToUsd(amountEth);
        require(orderUsd >= minOrderUsd, "Buy order is less than minimum USD value");
        require(orderUsd <= orderLimit || orderLimit == 0, "Order exceeds USD limit");
        amountEth = _fillSellOrders(amountEth, lowGas);
        amountEth = _buyFromReserve(amountEth);
        orderId = _openBuyOrder(amountEth);
        _makeHodler(msg.sender);
    }

    function _fillSellOrders(uint amountEth, uint lowGas) private returns(uint remainingEth) {
        User storage u = userStruct[msg.sender];
        address sellerAddr;
        bytes32 sellId;
        uint orderEth;
        uint orderHodl;
        uint txnEth;
        uint txnHodl; 

        while(sellOrderIdFifo.count() > 0 && amountEth > 0) {
            if(gasleft() < lowGas) return 0;
            sellId = sellOrderIdFifo.first();
            SellOrder storage o = sellOrder[sellId];
            sellerAddr = o.seller;
            User storage s = userStruct[sellerAddr];
            
            orderHodl = o.volumeHodl; 
            orderEth = convertHodlToEth(orderHodl);
            txnEth = amountEth;
            txnHodl = convertEthToHodl(txnEth);
            if(orderEth < txnEth) {
                txnEth = orderEth;
                txnHodl = orderHodl;
            }
            u.balanceEth = u.balanceEth.sub(txnEth, "Insufficient funds to buy from sell order");
            s.balanceEth = s.balanceEth.add(txnEth);
            u.balanceHodl = u.balanceHodl.add(txnHodl);
            o.volumeHodl = o.volumeHodl.sub(txnHodl, "500 - order has insufficient Hodl for computed volume");
            amountEth = amountEth.sub(txnEth, "500 - overspent buy order"); 
            _accrueByTransaction();
            emit SellOrderFilled(msg.sender, sellId, o.seller, txnEth, txnHodl);
            if(o.volumeHodl == 0) {
                delete sellOrder[sellId];
                sellOrderIdFifo.remove(sellId);
                s.sellOrderIdFifo.remove(sellId);
                _pruneHodler(sellerAddr); 
            }      
        }
        remainingEth = amountEth;
    }
    
    function _buyFromReserve(uint amountEth) private returns(uint remainingEth) {
        uint txnHodl;
        uint txnEth;
        if(amountEth > 0) {
            Distribution memory d;
            User storage u = userStruct[msg.sender];
            User storage r = userStruct[address(this)];
            txnHodl = (convertEthToHodl(amountEth) <= r.balanceHodl) ? convertEthToHodl(amountEth) : r.balanceHodl;
            if(txnHodl > 0) {
                txnEth = convertHodlToEth(txnHodl);
                r.balanceHodl = r.balanceHodl.sub(txnHodl, "500 - reserve has insufficient Hodl for computed volume");
                u.balanceHodl = u.balanceHodl.add(txnHodl);
                u.balanceEth = u.balanceEth.sub(txnEth, "Insufficient funds to buy from reserve");            
                d.amountEth = txnEth;
                d.timeStamp = now;
                distribution.push(d);
                amountEth = amountEth.sub(txnEth, "500 - buy order has insufficient ETH to complete reserve purchase");
                _accrueByTransaction();    
                emit BuyFromReserve(msg.sender, txnEth, txnHodl);
            }
        }
        remainingEth = amountEth;
    }

    function _openBuyOrder(uint amountEth) private returns(bytes32 orderId) {
        User storage u = userStruct[msg.sender];
        // do not allow low gas to open a small buy order or buy orders to exist while sell orders exist
        if(convertEthToUsd(amountEth) > minOrderUsd && sellOrderIdFifo.count() == 0) {
            orderId = keyGen();
            BuyOrder storage o = buyOrder[orderId];
            buyOrderIdFifo.append(orderId);
            u.buyOrderIdFifo.append(orderId);
            u.balanceEth = u.balanceEth.sub(amountEth, "Insufficient funds to open buy order");
            o.bidEth = amountEth;
            o.buyer = msg.sender;
            emit BuyOrderOpened(orderId, msg.sender, amountEth);
        }
    }
    
    /**************************************************************************************
     * Cancel orders
     **************************************************************************************/ 

    function cancelSell(bytes32 orderId) external accrueByTime distribute ifRunning {
        SellOrder storage o = sellOrder[orderId];
        User storage u = userStruct[o.seller];
        require(o.seller == msg.sender, "Sender is not the seller.");
        u.balanceHodl = u.balanceHodl.add(o.volumeHodl);
        u.sellOrderIdFifo.remove(orderId);
        sellOrderIdFifo.remove(orderId);
        emit SellOrderCancelled(msg.sender, orderId);
    }
    function cancelBuy(bytes32 orderId) external distribute accrueByTime ifRunning {
        BuyOrder storage o = buyOrder[orderId];
        User storage u = userStruct[o.buyer];
        require(o.buyer == msg.sender, "Sender is not the buyer.");
        u.balanceEth = u.balanceEth.add(o.bidEth);
        u.buyOrderIdFifo.remove(orderId);
        buyOrderIdFifo.remove(orderId);
        emit BuyOrderCancelled(msg.sender, orderId);
    }

    /**************************************************************************************
     * Prices and quotes
     **************************************************************************************/    
    
    function convertEthToUsd(uint amtEth) public view returns(uint inUsd) {
        inUsd = amtEth.mul(maker.read()).div(USD_PRECISION);
    }
    function convertUsdToEth(uint amtUsd) public view returns(uint inEth) {
        inEth = amtUsd.mul(USD_PRECISION).div(convertEthToUsd(USD_PRECISION));
    }
    function convertHodlToUsd(uint amtHodl) public view returns(uint inUsd) {
        (uint _hodlUsd, /*uint _accrualRate*/) = rates();
        inUsd = amtHodl.mul(_hodlUsd).div(HODL_PRECISION);
    }
    function convertUsdToHodl(uint amtUsd) public view returns(uint inHodl) {
         (uint _hodlUsd, /*uint _accrualRate*/) = rates();
        inHodl = amtUsd.mul(HODL_PRECISION).div(_hodlUsd);
    }
    function convertEthToHodl(uint amtEth) public view returns(uint inHodl) {
        uint inUsd = convertEthToUsd(amtEth);
        inHodl = convertUsdToHodl(inUsd);
    }
    function convertHodlToEth(uint amtHodl) public view returns(uint inEth) { 
        uint inUsd = convertHodlToUsd(amtHodl);
        inEth = convertUsdToEth(inUsd);
    }

    /**************************************************************************************
     * Eth accounts
     **************************************************************************************/ 

    function depositEth() external accrueByTime distribute ifRunning payable {
        require(msg.value > 0, "You must send Eth to this function");
        User storage u = userStruct[msg.sender];
        u.balanceEth = u.balanceEth.add(msg.value);
        emit UserDepositEth(msg.sender, msg.value);
    }   
    function withdrawEth(uint amount) external accrueByTime distribute ifRunning {
        User storage u = userStruct[msg.sender];
        u.balanceEth = u.balanceEth.sub(amount);
        emit UserWithdrawEth(msg.sender, amount);  
        msg.sender.sendValue(amount); 
    }

    /**************************************************************************************
     * Accrual and rate decay over time
     **************************************************************************************/ 

    // Moves forward in 1-day steps to prevent overflow
    function rates() public view returns(uint hodlUsd, uint dailyAccrualRate) {
        hodlUsd = HODL_USD;
        dailyAccrualRate = DAILY_ACCRUAL_RATE;
        uint startTime = BIRTHDAY.add(SLEEP_TIME);
        if(now > startTime) {
            uint daysFromStart = (now.sub(startTime)) / 1 days;
            uint daysUnprocessed = daysFromStart.sub(accrualDaysProcessed);
            if(daysUnprocessed > 0) {
                hodlUsd = HODL_USD.mul(DAILY_ACCRUAL_RATE).div(USD_PRECISION);
                dailyAccrualRate = DAILY_ACCRUAL_RATE.mul(DAILY_ACCRUAL_RATE_DECAY).div(USD_PRECISION);
            }
        }
    }

    /**************************************************************************************
     * Stateful activity-based and time-based rate adjustments
     **************************************************************************************/

    function _accrueByTransaction() private {
        HODL_USD = HODL_USD.add(USD_TXN_ADJUSTMENT);
    }    
    function _accrueByTime() private returns(uint hodlUsdNow, uint dailyAccrualRateNow) {
        (hodlUsdNow, dailyAccrualRateNow) = rates();
        if(hodlUsdNow != HODL_USD || dailyAccrualRateNow != DAILY_ACCRUAL_RATE) { 
            HODL_USD = hodlUsdNow;
            DAILY_ACCRUAL_RATE = dailyAccrualRateNow; 
            accrualDaysProcessed = accrualDaysProcessed.add(1);  
        } 
    }
    
    /**************************************************************************************
     * Add and remove from hodlerAddrSet based on total HODLC owned/controlled
     **************************************************************************************/

    function _makeHodler(address user) private {
        User storage u = userStruct[user];
        if(convertHodlToUsd(u.balanceHodl) >= minOrderUsd) {
            if(!hodlerAddrSet.exists(user)) hodlerAddrSet.insert(user);   
        }
    }    
    function _pruneHodler(address user) private {
        User storage u = userStruct[user];
        if(convertHodlToUsd(u.balanceHodl) < minOrderUsd) {
            if(hodlerAddrSet.exists(user)) hodlerAddrSet.remove(user);
        }
    }
    
    /**************************************************************************************
     * View functions to enumerate the state
     **************************************************************************************/
    
    // Courtesy function 
    function contractBalanceEth() public view returns(uint ineth) { return address(this).balance; }

    // Distribution queue
    function distributionsLength() public view returns(uint row) { return distribution.length; }
    
    // Hodlers in no particular order
    function hodlerCount() public view returns(uint count) { return hodlerAddrSet.count(); }
    function hodlerAtIndex(uint index) public view returns(address userAddr) { return hodlerAddrSet.keyAtIndex(index); }    
    
    // Open orders, FIFO
    function sellOrderCount() public view returns(uint count) { return sellOrderIdFifo.count(); }
    function sellOrderFirst() public view returns(bytes32 orderId) { return sellOrderIdFifo.first(); }
    function sellOrderLast() public view returns(bytes32 orderId) { return sellOrderIdFifo.last(); }  
    function sellOrderIterate(bytes32 orderId) public view returns(bytes32 idBefore, bytes32 idAfter) { return (sellOrderIdFifo.previous(orderId), sellOrderIdFifo.next(orderId)); }
    function buyOrderCount() public view returns(uint count) { return buyOrderIdFifo.count(); }
    function buyOrderFirst() public view returns(bytes32 orderId) { return buyOrderIdFifo.first(); }
    function buyOrderLast() public view returns(bytes32 orderId) { return buyOrderIdFifo.last(); }    
    function buyOrderIterate(bytes32 orderId) public view returns(bytes32 ifBefore, bytes32 idAfter) { return(buyOrderIdFifo.previous(orderId), buyOrderIdFifo.next(orderId)); }

    // open orders by user, FIFO
    function userSellOrderCount(address userAddr) public view returns(uint count) { return userStruct[userAddr].sellOrderIdFifo.count(); }
    function userSellOrderFirst(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].sellOrderIdFifo.first(); }
    function userSellOrderLast(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].sellOrderIdFifo.last(); }  
    function userSellOrderIterate(address userAddr, bytes32 orderId) public view  returns(bytes32 idBefore, bytes32 idAfter) { return(userStruct[userAddr].sellOrderIdFifo.previous(orderId), userStruct[userAddr].sellOrderIdFifo.next(orderId)); }
    function userBuyOrderCount(address userAddr) public view returns(uint count) { return userStruct[userAddr].buyOrderIdFifo.count(); }
    function userBuyOrderFirst(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].buyOrderIdFifo.first(); }
    function userBuyOrderLast(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].buyOrderIdFifo.last(); }
    function userBuyOrderIdFifo(address userAddr, bytes32 orderId) public view  returns(bytes32 idBefore, bytes32 idAfter) { return(userStruct[userAddr].buyOrderIdFifo.previous(orderId), userStruct[userAddr].buyOrderIdFifo.next(orderId)); }
     
    function user(address userAddr) public view returns(uint balanceEth, uint balanceHodl) {
        User storage u = userStruct[userAddr];
        return(u.balanceEth, u.balanceHodl);
    }
    function isAccruing() public view returns(bool accruing) {
        return now > BIRTHDAY.add(SLEEP_TIME);
    }
    function isRunning() public view returns(bool running) {
        return owner() == address(0);
    }
    function orderLimit() public view returns(uint limitUsd) {
        // get selling price in USD
        (uint askUsd, /*uint accrualRate*/) = rates();
        return (askUsd > maxThresholdUsd) ? 0 : maxOrderUsd;
    }
    function makerAddr() public view returns(address) {
        return address(maker);
    }
    function hodlTAddr() public view returns(address) {
        return address(token);
    }
    
    /**************************************************************************************
     * Initialization functions that support migration cannot be used after trading starts
     **************************************************************************************/  

    function initUser(address userAddr, uint hodl) external onlyOwner payable {
        User storage u = userStruct[userAddr];
        User storage r = userStruct[address(this)];
        u.balanceEth  = u.balanceEth.add(msg.value);
        u.balanceHodl = u.balanceHodl.add(hodl);
        r.balanceHodl = r.balanceHodl.sub(hodl);
        _makeHodler(userAddr);
        emit UserInitialized(msg.sender, userAddr, hodl, msg.value);
    }
    function initResetUser(address userAddr) external onlyOwner {
        User storage u = userStruct[userAddr];
        User storage r = userStruct[address(this)];
        r.balanceHodl = r.balanceHodl.add(u.balanceHodl);
        if(u.balanceEth > 0) msg.sender.transfer(u.balanceEth);
        emit UserUninitialized(msg.sender, userAddr, u.balanceHodl, u.balanceEth);
        delete userStruct[userAddr];
        _pruneHodler(userAddr);
    }
    function initSetHodlTAddress(IERC20 hodlToken) external onlyOwner {
        /// @dev Transfer the total supply of these tokens to this contract during migration
        token = IERC20(hodlToken);
        emit TokenSet(msg.sender, address(token));
    }
    function initSetHodlUsd(uint price) external onlyOwner {
        HODL_USD = price;
        emit PriceSet(msg.sender, price);
    }
    function initSetMaker(address _maker) external onlyOwner {
        maker = Maker(_maker);
        emit MakerSet(msg.sender, _maker);
    }
    function renounceOwnership() public override onlyOwner {
        require(token.balanceOf(address(this)) == TOTAL_SUPPLY, "Assign the HoldT supply to this contract before trading starts");
        Ownable.renounceOwnership();
    }
}