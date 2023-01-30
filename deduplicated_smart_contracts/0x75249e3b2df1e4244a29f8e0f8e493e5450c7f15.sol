/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
interface ILock3rV1Mini {
    function isLocker(address) external returns (bool);
    function worked(address locker) external;
    function totalBonded() external view returns (uint);
    function bonds(address locker, address credit) external view returns (uint);
    function votes(address locker) external view returns (uint);
    function isMinLocker(address locker, uint minBond, uint earned, uint age) external returns (bool);
    function addCreditETH(address job) external payable;
    function workedETH(address locker) external;
    function credits(address job, address credit) external view returns (uint);
    function receipt(address credit, address locker, uint amount) external;
    function ETH() external view returns (address);
    function receiptETH(address locker, uint amount) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


enum OrderState {Placed, Cancelled, Executed}

interface UnitradeInterface {
    function cancelOrder(uint256 orderId) external returns (bool);

    function executeOrder(uint256 orderId)
        external
        returns (uint256[] memory amounts);

    function feeDiv() external view returns (uint16);

    function feeMul() external view returns (uint16);

    function getActiveOrderId(uint256 index) external view returns (uint256);

    function getActiveOrdersLength() external view returns (uint256);

    function getOrder(uint256 orderId)
        external
        view
        returns (
            uint8 orderType,
            address maker,
            address tokenIn,
            address tokenOut,
            uint256 amountInOffered,
            uint256 amountOutExpected,
            uint256 executorFee,
            uint256 totalEthDeposited,
            OrderState orderState,
            bool deflationary
        );

    function getOrderIdForAddress(address _address, uint256 index)
        external
        view
        returns (uint256);

    function getOrdersForAddressLength(address _address)
        external
        view
        returns (uint256);

    function incinerator() external view returns (address);

    function owner() external view returns (address);

    function placeOrder(
        uint8 orderType,
        address tokenIn,
        address tokenOut,
        uint256 amountInOffered,
        uint256 amountOutExpected,
        uint256 executorFee
    ) external returns (uint256);

    function renounceOwnership() external;

    function splitDiv() external view returns (uint16);

    function splitMul() external view returns (uint16);

    function staker() external view returns (address);

    function transferOwnership(address newOwner) external;

    function uniswapV2Factory() external view returns (address);

    function uniswapV2Router() external view returns (address);

    function updateFee(uint16 _feeMul, uint16 _feeDiv) external;

    function updateOrder(
        uint256 orderId,
        uint256 amountInOffered,
        uint256 amountOutExpected,
        uint256 executorFee
    ) external returns (bool);

    function updateSplit(uint16 _splitMul, uint16 _splitDiv) external;

    function updateStaker(address newStaker) external;
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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


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
abstract contract Context {
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


contract LK3RsExecutingOnUnitrade is Ownable{

    UnitradeInterface iUniTrade = UnitradeInterface(
        0xC1bF1B4929DA9303773eCEa5E251fDEc22cC6828
    );

    //change this to lock3r on deploy
    ILock3rV1Mini public LK3R;
    uint public minKeep = 100e18;

    bool TryDeflationaryOrders = false;
    bool public payoutETH = true;
    bool public payoutLK3R = true;

    mapping(address => bool) public tokenOutSkip;


    constructor(address lockertoken) public {
        LK3R = ILock3rV1Mini(lockertoken);
        addSkipTokenOut(0x610c67be018A5C5bdC70ACd8DC19688A11421073);
    }

    modifier upkeep() {
        require(LK3R.isMinLocker(msg.sender, minKeep, 0, 0), "::isLocker: locker is not registered");
        _;
        if(payoutLK3R) {
            //Payout LK3R
            LK3R.worked(msg.sender);
        }
    }

    function togglePayETH() public onlyOwner {
        payoutETH = !payoutETH;
    }

    function togglePayLK3R() public onlyOwner {
        payoutLK3R = !payoutLK3R;
    }

    function addSkipTokenOut(address token) public onlyOwner {
        tokenOutSkip[token] = true;
    }

    function setMinKeep(uint _keep) public onlyOwner {
        minKeep = _keep;
    }

    //Use this to depricate this job to move rlr to another job later
    function destructJob() public onlyOwner {
     //Get the credits for this job first
     uint256 currLK3RCreds = LK3R.credits(address(this),address(LK3R));
     uint256 currETHCreds = LK3R.credits(address(this),LK3R.ETH());
     //Send out LK3R Credits if any
     if(currLK3RCreds > 0) {
        //Invoke receipt to send all the credits of job to owner
        LK3R.receipt(address(LK3R),owner(),currLK3RCreds);
     }
     //Send out ETH credits if any
     if (currETHCreds > 0) {
        LK3R.receiptETH(owner(),currETHCreds);
     }
     //Finally self destruct the contract after sending the credits
     selfdestruct(payable(owner()));
    }

    function setTryBurnabletokens(bool fTry) public onlyOwner{
        TryDeflationaryOrders = fTry;
    }


    function getIfExecuteable(uint256 i) public view returns (bool) {
        (
            ,
            ,
            address tokenIn,
            address tokenOut,
            uint256 amountInOffered,
            uint256 amountOutExpected,
            uint256 executorFee,
            ,
            OrderState orderState,
            bool deflationary
        ) = iUniTrade.getOrder(i);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        if(executorFee <= 0) return false;//Dont execute unprofitable orders
        if(deflationary && !TryDeflationaryOrders) return false;//Skip deflationary token orders as it is not supported atm
        if(tokenOutSkip[tokenOut]) return false;//Skip tokens that are set in mapping
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(
            iUniTrade.uniswapV2Factory(),
            amountInOffered,
            path
        );
        if (
            amounts[1] >= amountOutExpected && orderState == OrderState.Placed
        ) {
            return true;
        }
        return false;
    }

    function hasExecutableOrdersPending() public view returns (bool) {
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                return true;
            }
        }
        return false;
    }

    //Get count of executable orders
    function getExectuableOrdersCount() public view returns (uint count){
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                count++;
            }
        }
    }

    function getExecutableOrdersList() public view returns (uint[] memory) {
        uint[] memory orderArr = new uint[](getExectuableOrdersCount());
        uint index = 0;
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                orderArr[index] = iUniTrade.getActiveOrderId(i);
                index++;
            }
        }
        return orderArr;
    }

    receive() external payable {}

    function sendETHRewards() internal {
        if(!payoutETH) {
            //Transfer received eth to treasury
            (bool success,  ) = payable(owner()).call{value : address(this).balance}("");
            require(success,"!treasurysend");
        }
        else {
            (bool success,  ) = payable(msg.sender).call{value : address(this).balance}("");
            require(success,"!sendETHRewards");
        }
    }

    function workable() public view returns (bool) {
        return hasExecutableOrdersPending();
    }

    function work() public upkeep{
        require(workable(),"!workable");
        for (uint256 i = 0; i < iUniTrade.getActiveOrdersLength() - 1; i++) {
            if (getIfExecuteable(iUniTrade.getActiveOrderId(i))) {
                iUniTrade.executeOrder(i);
            }
        }
        //After order executions send all the eth to locker
        sendETHRewards();
    }

    //Use this to save on gas
    function workBatch(uint[] memory orderList) public upkeep {
        require(workable(),"!workable");
        for (uint256 i = 0; i < orderList.length; i++) {
            iUniTrade.executeOrder(orderList[i]);
        }
        //After order executions send all the eth to locker
        sendETHRewards();
    }
}