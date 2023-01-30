/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
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
     * NOTE: Renouncing ownership will leave the contract without an owner,
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

contract Whitelist is Ownable {
    mapping (address => bool)       public  whitelist;

    constructor() public {
    }

    modifier whitelistOnly {
        require(whitelist[msg.sender], "MEMBERS_ONLY");
        _;
    }

    function addMember(address member)
        public
        onlyOwner
    {
        require(!whitelist[member], "ALREADY_EXISTS");
        whitelist[member] = true;
    }

    function removeMember(address member)
        public
        onlyOwner
    {
        require(whitelist[member], "NOT_EXISTS");
        whitelist[member] = false;
    }
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
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
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

    function safeTransfer(IERC20Token token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Token token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Token token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Token token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Token token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20Token token, bytes memory data) private {
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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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


library WadMath {
    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
    }
}


contract ERC20Token {
    uint8   public decimals = 18;
    string  public name;
    string  public symbol;
    uint256 public totalSupply;

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    event  Approval(address indexed _owner, address indexed _spender, uint _value);
    event  Transfer(address indexed _from, address indexed _to, uint _value);

    constructor(
        string memory _name,
        string memory _symbol
    ) public {
        name = _name;
        symbol = _symbol;
    }

    function approve(address guy, uint256 wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint256 wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad, "INSUFFICIENT_FUNDS");

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "NOT_ALLOWED");
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}


contract MintableERC20Token is ERC20Token {
    using SafeMath for uint256;

    constructor(
        string memory _name,
        string memory _symbol
    )
        public
        ERC20Token(_name, _symbol)
    {}

    function _mint(address to, uint256 wad)
        internal
    {
        balanceOf[to] = balanceOf[to].add(wad);
        totalSupply = totalSupply.add(wad);

        emit Transfer(address(0), to, wad);
    }

    function _burn(address owner, uint256 wad)
        internal
    {
        balanceOf[owner] = balanceOf[owner].sub(wad);
        totalSupply = totalSupply.sub(wad);

        emit Transfer(owner, address(0), wad);
    }
}



contract IERC20Token {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value)
        external
        returns (bool);

    function transferFrom(address _from, address _to, uint256 _value)
        external
        returns (bool);

    function approve(address _spender, uint256 _value)
        external
        returns (bool);

    function totalSupply()
        external
        view
        returns (uint256);

    function balanceOf(address _owner)
        external
        view
        returns (uint256);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);
}



contract MBFToken is
    MintableERC20Token,
    Ownable,
    Whitelist
{
    using SafeMath for uint256;
    using WadMath for uint256;
    using SafeERC20 for IERC20Token;

    // parameters
    uint256 constant             public   globalDecimals = 18;
    IERC20Token                  internal collateral;
    uint256                      public   maxSupply;

    bool                         public   finalized;
    uint256                      public   targetPrice;
    uint256                      public   totalProfit;
    uint256[]                    public   historyProfits;
    uint256[]                    public   historyTime;
    mapping (address => Account) public   accounts;

    // profit manager
    struct Account {
        uint256 profit;
        uint256 taken;
        uint256 settled;
    }

    // events
    event  Mint(address indexed _owner, uint256 _value);
    event  Burn(address indexed _owner, uint256 _value);
    event  Withdraw(address indexed _owner, uint256 _value);
    event  Pay(uint256 _value);

    constructor(
        address _collateralAddress,
        uint256 _maxSupply
    )
        public
        MintableERC20Token("P106 Token", "P106")
    {
        collateral = IERC20Token(_collateralAddress);
        maxSupply = _maxSupply;
        finalized = false;
    }

    function finalize()
        public
        onlyOwner
    {
        require(finalized == false, "CAN_ONLY_FINALIZE_ONCE");
        finalized = true;
        uint256 remaining = maxSupply.sub(totalSupply);
        _mint(owner(), remaining);

        emit Mint(owner(), remaining);
    }

    modifier beforeFinalized {
        require(finalized == false, "ALREADY_FINALIZED");
        _;
    }

    modifier afterFinalized {
        require(finalized == true, "NOT_FINALIZED");
        _;
    }

    function historyProfitsArray()
        public
        view
        returns (uint256[] memory)
    {
        return historyProfits;
    }

    function historyTimeArray()
        public
        view
        returns (uint256[] memory)
    {
        return historyTime;
    }

    function setTargetPrice(uint256 wad)
        public
        onlyOwner
    {
        require(wad > 0, "INVALID_RIG_PRICE");
        targetPrice = wad;
    }

    function pay(uint256 wad)
        public
        onlyOwner
        afterFinalized
    {
        totalProfit = totalProfit.add(wad);
        historyProfits.push(wad);
        historyTime.push(now);

        emit Pay(wad);
    }

    function unsettledProfitOf(address beneficiary)
        public
        view
        returns (uint256)
    {
        if (totalProfit == accounts[beneficiary].settled) {
            return 0;
        }
        uint256 toSettle = totalProfit.sub(accounts[beneficiary].settled);
        return toSettle.wmul(balanceOf[beneficiary]).wdiv(maxSupply);
    }

    function profitOf(address beneficiary)
        public
        view
        returns (uint256)
    {
        // unsettled { (total - settled) * balance / max } + settled { profit }
        return unsettledProfitOf(beneficiary) + accounts[beneficiary].profit;
    }

    function totalProfitOf(address beneficiary)
        public
        view
        returns (uint256)
    {
        return accounts[beneficiary].taken.add(profitOf(beneficiary));
    }

    function adjustProfit(address beneficiary)
        internal
    {
        if (accounts[beneficiary].settled == totalProfit) {
            return;
        }
        accounts[beneficiary].profit = profitOf(beneficiary);
        accounts[beneficiary].settled = totalProfit;
    }

    function withdraw()
        public
    {
        require(msg.sender != address(0), "INVALID_ADDRESS");

        adjustProfit(msg.sender);
        require(accounts[msg.sender].profit > 0, "NO_PROFIT");

        uint256 available = accounts[msg.sender].profit;
        accounts[msg.sender].profit = 0;
        accounts[msg.sender].taken = accounts[msg.sender].taken.add(available);
        collateral.safeTransferFrom(owner(), msg.sender, available);

        emit Withdraw(msg.sender, available);
    }

    function transferFrom(address src, address dst, uint256 wad)
        public
        returns (bool)
    {
        adjustProfit(src);
        if (balanceOf[dst] == 0) {
            accounts[dst].settled = totalProfit;
        } else {
            adjustProfit(dst);
        }
        return super.transferFrom(src, dst, wad);
    }

    function join(uint256 wad)
        public
        whitelistOnly
        beforeFinalized
    {
        require(targetPrice > 0, "PRICE_NOT_INIT");
        require(wad > 0 && wad <= maxSupply.sub(totalSupply), "EXCEEDS_MAX_SUPPLY");

        uint256 joinPrice = wad.wmul(targetPrice);
        collateral.safeTransferFrom(msg.sender, owner(), joinPrice);
        _mint(msg.sender, wad);

        emit Mint(msg.sender, wad);
    }
}