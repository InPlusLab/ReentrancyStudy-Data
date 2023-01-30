/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

// File: contracts/access/Context.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

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

// File: contracts/access/Ownable.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
    function initialize() public {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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

// File: contracts/interfaces/IERC20.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
//pragma solidity ^0.5.16;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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

// File: contracts/interfaces/IOneSplit.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

//import "openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol";


interface IOneSplit {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        //address fromToken,
        //address destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        external
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        );

    /*
    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );
    */
    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags
    )
        external
        payable
        returns(uint256 returnAmount);
}

// File: contracts/interfaces/IUniswapV2Pair.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IUniswapV2Pair {
    //event Approval(address indexed owner, address indexed spender, uint value);
    //event Transfer(address indexed from, address indexed to, uint value);

    //function name() external pure returns (string memory);
    //function symbol() external pure returns (string memory);
    //function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    //function allowance(address owner, address spender) external view returns (uint);

    //function approve(address spender, uint value) external returns (bool);
    //function transfer(address to, uint value) external returns (bool);
    //function transferFrom(address from, address to, uint value) external returns (bool);

    //function DOMAIN_SEPARATOR() external view returns (bytes32);
    //function PERMIT_TYPEHASH() external pure returns (bytes32);
    //function nonces(address owner) external view returns (uint);

    //function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    //event Mint(address indexed sender, uint amount0, uint amount1);
    //event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    /*event Swap(
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
    */
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    /*
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    */
}

// File: contracts/interfaces/IExternalPool.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

abstract contract  IExternalPool {
    address public enterToken;
    function getPoolValue(address denominator) virtual external view returns (uint256);
    function getTokenStaked() virtual external view returns (uint256);
    function addPosition() virtual external returns (uint256);
    function exitPosition(uint amount) virtual external;
    function transferTokenTo(address TokenAddress, address recipient, uint amount) virtual external returns (uint256);
}

// File: contracts/interfaces/ISFToken.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


interface ISFToken {
    function rebase(uint totalSupply) external;
    function mint(address account, uint amount) external;
    function burn(address account, uint amount) external;
    function balanceOf(address account) external view returns (uint256);
}

// File: contracts/interfaces/IWETH.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

// File: contracts/interfaces/IUniRouter.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IUniRouter {
    function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);

    //function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    //function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    
}

// File: contracts/interfaces/ICHI.sol

pragma solidity ^0.6.0;

// SPDX-License-Identifier: MIT
//import "./IERC20.sol";
//import "openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol";

interface ICHI {
    function freeFromUpTo(address from, uint256 value)
        external
        returns (uint256);
        
    function freeUpTo(uint256 value)
        external
        returns (uint256);
    
    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function mint(uint256 value) external;
}

// File: contracts/CHIBurner.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;


contract CHIBurner {
    address
        public constant CHI_ADDRESS = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c;
        
    ICHI public constant chi = ICHI(CHI_ADDRESS);

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;

        /*uint256 availableAmount = chi.balanceOf(msg.sender);
        uint256 allowedAmount = chi.allowance(msg.sender, address(this));
        if (allowedAmount < availableAmount) {
            availableAmount = allowedAmount;
        }
        uint256 ourBalance = chi.balanceOf(address(this));

        address sender;
        if (ourBalance > availableAmount) {
            sender = address(this);
            ourBalance = availableAmount;
        } else {
            sender = msg.sender;
        }

        if (ourBalance > 0) {*/
        uint256 gasLeft = gasleft();
        uint256 gasSpent = 21000 +
            gasStart -
            gasLeft +
            16 *
            msg.data.length;
        //chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
        chi.freeUpTo((gasSpent + 14154) / 41947);
        //}
    }
}

// File: contracts/XChanger.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;






contract XChanger is CHIBurner {
    address
        public constant oneSplitAddress = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;
    address
        public constant uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        
    enum Exchange {UNI, ONESPLIT}
    
    //0x6B175474E89094C44Da98b954EedeAC495271d0F DAI
    //
    //0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 USDC
    //
    //  30000000000000000000
    //  30000000

    function swapSplit(address fromToken,
        address toToken, uint256 amount, uint256 flags) internal returns (uint256) {
        IOneSplit oneSplit = IOneSplit(oneSplitAddress);
        IERC20 _fromToken = IERC20(fromToken);
        IERC20 _toToken = IERC20(toToken);
        (uint256 returnAmount0, uint256[] memory distribution) = oneSplit
            .getExpectedReturn(_fromToken, IERC20(toToken), amount, 1, flags);

        require(returnAmount0 > 0, "nothing to return");
        
        if (_fromToken.allowance(address(this), oneSplitAddress) < amount) {
            _fromToken.approve(oneSplitAddress, uint256(-1));    
        }

        uint returnAmount = oneSplit.swap(
            _fromToken,
            _toToken,
            amount,
            1,
            distribution,
            flags
        );

        return returnAmount;
    }
    
    
    function swapUni(
        address fromToken,
        address toToken,
        uint256 amount
    ) internal returns (uint256) {
        IERC20 _token = IERC20(fromToken);

        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;
        IUniRouter UniswapV2Router02 = IUniRouter(uniRouter);

        if (_token.allowance(address(this), address(uniRouter)) != uint256(-1)) {
            _token.approve(address(uniRouter), uint256(-1));
        }

        uint256[] memory amounts = UniswapV2Router02.swapExactTokensForTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        return amounts[1];
    }
    
    function _getOneSplitExpReturn(
        address OneSplitAddress,
        address fromToken,
        address toToken,
        uint256 amount
    ) internal view returns (uint256) {
        IERC20 fromIERC20 = IERC20(fromToken);
        IERC20 toIERC20 = IERC20(toToken);

        (uint256 returnAmount0, ) = IOneSplit(OneSplitAddress)
            .getExpectedReturn(fromIERC20, toIERC20, amount, 1, 0x800000000000);

        return returnAmount0;
    }
    
    function swap(address fromToken, address toToken, uint amount, Exchange exchange) public payable returns (uint) {
        uint result;
        if (exchange == Exchange.ONESPLIT) {
            result = swapSplit(fromToken, toToken, amount, 0);
        } else {
            result = swapUni(fromToken, toToken, amount);    
        }
        return result;
    }
    
    function quote(address fromToken, address toToken, uint amount, Exchange exchange) public view returns (uint) {
        uint returnamount;
        
        if (exchange == Exchange.ONESPLIT) {
            returnamount = _getOneSplitExpReturn(oneSplitAddress, fromToken, toToken, amount);
        } else {
            
            address[] memory path = new address[](2);
            path[0] = fromToken;
            path[1] = toToken;
            IUniRouter UniswapV2Router02 = IUniRouter(uniRouter);
        uint256[] memory amounts = UniswapV2Router02.getAmountsOut(
            amount,
            path
        );
        returnamount = amounts[1];
        }
        
        return returnamount;
    }
    
    function reverseQuote(address fromToken, address toToken, uint amount) public view returns (uint) {
        address[] memory path = new address[](2);
            path[0] = fromToken;
            path[1] = toToken;
            IUniRouter UniswapV2Router02 = IUniRouter(uniRouter);
        uint256[] memory amounts = UniswapV2Router02.getAmountsIn(
            amount,
            path
        );
        return amounts[1];
    }
}

// File: contracts/utils/SafeMath.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
//pragma solidity ^0.5.16;

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

// File: contracts/ValueHolder.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;










contract ValueHolder is Ownable, XChanger {
    mapping (uint => address) public uniPools;
    mapping (uint => address) public externalPools;
    
    uint public uniLen;
    uint public extLen;

    address constant public WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public denominateTo;
    address public holderAddress;
    address public OneSplit;
    address public SFToken;
    
    address public votedUniPool;
    address public votedExtPool;
    uint public votedFee; // 1% = 100
    uint public votedChi; // number of Chi to hold
    
    uint256 private constant fpNumbers = 1e8;
    //uint public TotalValue;
    
    bool private initialized;
    using SafeMath for uint256;
    
    event LogValueManagerUpdated(address Manager);
    event LogVoterUpdated(address Voter);
    event LogVotedExtPoolUpdated(address pool);
    event LogVotedUniPoolUpdated(address pool);
    event LogSFTokenUpdated(address _NewSFToken);
    event LogFeeUpdated(uint newFee);
    event LogFeeTaken(uint feeAmount);
    event LogMintTaken(uint fromTokenAmount);
    event LogBurnGiven(uint toTokenAmount);
    event LogChiToppedUpdated(uint spendAmount);
    
    address public ValueManager;
    modifier onlyValueManager() {
        require(msg.sender == ValueManager);
        _;
    }
    
    address public Voter;
    modifier onlyVoter() {
        require(msg.sender == Voter);
        _;
    }

    function init(address _uniPool, address _extPool) public {
        require(!initialized, "Is already been initialized");
        initialized = true;

        Ownable.initialize(); // Do not forget this call!

        //0x3041CbD36888bECc7bbCBc0045E3B1f144466f5f
        
        uniPools[uniLen] = _uniPool;
        uniLen++;
        
        externalPools[uniLen] = _extPool;
        extLen++;
        
        votedExtPool = _extPool;
        emit LogVotedExtPoolUpdated(_extPool);
        
        denominateTo = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT
        OneSplit = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E; //opesplit.eth
        SFToken = 0xD39F6fC3d56A6EDe71f8677EA7C3e6A400000000; // 
        ValueManager = msg.sender;
        Voter = msg.sender;
        holderAddress = ValueManager;
        votedFee = 200;
        votedChi = 100;
    }
    
    function setSFToken(address _NewSFToken)
        public
        onlyOwner
    {
        SFToken = _NewSFToken;
        emit LogSFTokenUpdated(_NewSFToken);
    }
    
    function setValueManager(address _ValueManager)
        external
        onlyOwner
    {
        ValueManager = _ValueManager;
        emit LogValueManagerUpdated(_ValueManager);
    }
    
    function setVoter(address _Voter)
        external
        onlyOwner
    {
        Voter = _Voter;
        emit LogVoterUpdated(_Voter);
    }
    
    function setVotedExtPool(address pool)
        public
        onlyVoter
    {
        votedExtPool = pool;
        emit LogVotedExtPoolUpdated(pool);
    }
    
    function setVotedUniPool(address pool)
        public
        onlyVoter
    {
        votedUniPool = pool;
        emit LogVotedUniPoolUpdated(pool);
    }
    
    function setVotedFee(uint _votedFee)
        public
        onlyVoter
    {
        votedFee = _votedFee;
        emit LogFeeUpdated(_votedFee);
    }
    
    function setVotedChi(uint _votedChi)
        public
        onlyVoter
    {
        votedChi = _votedChi;
    }

    function topUpChi(address Token) public returns (uint) {
        uint currentChi = ICHI(CHI_ADDRESS).balanceOf(address(this));
        if (currentChi < votedChi) {
            //top up 1/2 votedChi
            uint spendAmount = reverseQuote(Token, CHI_ADDRESS, votedChi.div(2));
            swap(Token, CHI_ADDRESS, spendAmount, Exchange.UNI);
            LogChiToppedUpdated(spendAmount);
            return spendAmount;
        }
    }

    function mintQuote(address fromToken, uint amount, Exchange exchange) external view returns (uint) {
        if (votedExtPool != address(0)) {
            address toToken = IExternalPool(votedExtPool).enterToken();
        
            return quote(fromToken, toToken, amount, exchange);
            
        } else if (votedUniPool != address(0)) {
            revert('not yet implemented');
        }
    }
    
    function mint(address fromToken, uint amount) discountCHI payable external {
        if (fromToken != address(0)) {
            IERC20 _fromToken = IERC20(fromToken);
            require(
            _fromToken.allowance(msg.sender, address(this)) >= amount,
            "Allowance is not enough");
            _fromToken.transferFrom(msg.sender, address(this), amount);
        } else {
            //convert to WETH   
            IWETH(WETH_ADDRESS).deposit{value:msg.value}();
            amount = msg.value;
            fromToken = WETH_ADDRESS;
        }

        emit LogMintTaken(amount);
        
        amount = amount.sub(topUpChi(fromToken)); 
        
        if (votedExtPool != address(0)) {
            IExternalPool extPool = IExternalPool(votedExtPool);
            address toToken = extPool.enterToken();
            
            uint returnAmount = swap(fromToken, toToken, amount, Exchange.UNI);
            IERC20 _toToken = IERC20(toToken);
            
            _toToken.transfer(votedExtPool, returnAmount);
            
            extPool.addPosition();
            // convert return amount to USDT (denominateTo)
            
            uint toMint = quote(toToken, denominateTo, returnAmount, Exchange.UNI);
            
            // mint that amount to sender
            ISFToken(SFToken).mint(msg.sender, toMint);
            
            // rebase not needed
            
        } else if (votedUniPool != address(0)) {
            revert('not yet implemented');
        }
    }
    
    function burn(address toToken, uint amount) discountCHI external {
        if (votedExtPool != address(0)) {
            ISFToken _SFToken = ISFToken(SFToken);
            // get latest token value
            rebase();
            // limit by existing balance
            uint senderBalance = _SFToken.balanceOf(msg.sender);
            if ( senderBalance < amount) {
                amount = senderBalance;
            }
            
            IExternalPool extPool = IExternalPool(votedExtPool);
            address poolToken = extPool.enterToken();
            
            //get quote from sf token to pool token
            uint poolTokenWithdraw = quote(denominateTo, poolToken, amount, Exchange.UNI);
            
            require(extPool.getTokenStaked() >= poolTokenWithdraw, 'Not enough voted pool value to withdraw');
            
            uint feeTaken = poolTokenWithdraw.mul(votedFee).div(10000);
            emit LogFeeTaken(feeTaken);
            //discount with fee
            //leave fee in the pool
            poolTokenWithdraw = poolTokenWithdraw.sub(feeTaken);
            
            //pull out pool tokens 
            extPool.exitPosition(poolTokenWithdraw);
            //get them out from the pool here
            uint returnPoolTokenAmount = extPool.transferTokenTo(poolToken, address(this), poolTokenWithdraw);
            // topup with CHi
            returnPoolTokenAmount = returnPoolTokenAmount.sub(topUpChi(poolToken)); 
            _SFToken.burn(msg.sender, amount);
            
            uint returnAmount = swap(poolToken, toToken, returnPoolTokenAmount, Exchange.UNI);
            IERC20(toToken).transfer(msg.sender, returnAmount);
            
            emit LogMintTaken(returnAmount);
        } else if (votedUniPool != address(0)) 
        {
            revert('not yet implemented');
        }
    }
    
    function rebase() discountCHI onlyValueManager public {
        uint value = _getTotalValue().add(1);
        ISFToken SF = ISFToken(SFToken);
        SF.rebase(value);
    }
    
    function rebase(uint value) onlyValueManager external {
        ISFToken SF = ISFToken(SFToken);
        SF.rebase(value);
    }

    function _getUniBalance(IUniswapV2Pair uniPool)
        public
        view
        returns (uint256)
    {
        uint256 uniBalance = (uniPool.balanceOf(holderAddress)).add(
            uniPool.balanceOf(address(this))
        );
        return uniBalance;
    }

    function _getHolderPc(IUniswapV2Pair uniPool)
        public
        view
        returns (uint256)
    {
        uint256 uniTotalSupply = uniPool.totalSupply();
        uint256 holderPc = (_getUniBalance(uniPool).mul(fpNumbers)).div(
            uniTotalSupply
        );

        return holderPc;
    }

    function _getUniReserve(IUniswapV2Pair uniPool)
        public
        view
        returns (uint256, uint256)
    {
        uint256 holderPc = _getHolderPc(uniPool);

        (uint112 reserve0, uint112 reserve1, ) = uniPool.getReserves();

        uint256 myreserve0 = (uint256(reserve0).mul(holderPc)).div(fpNumbers);
        uint256 myreserve1 = (uint256(reserve1).mul(holderPc)).div(fpNumbers);

        return (myreserve0, myreserve1);
    }

    function _getExternalValue() public view returns (uint256) {
        uint256 totalReserve = 0;
        for (uint256 j = 0; j < extLen; j++) {
            address extAddress = externalPools[j];
            if (extAddress != address(0)) {
                IExternalPool externalPool = IExternalPool(extAddress);

                totalReserve = totalReserve.add(
                    externalPool.getPoolValue(denominateTo)
                );
            }    
        }
        return totalReserve;
    }

    function _getDenominatedValue(IUniswapV2Pair uniPool)
        public
        view
        returns (uint256, uint256)
    {
        (uint256 myreserve0, uint256 myreserve1) = _getUniReserve(uniPool);
        
        address token0 = uniPool.token0();
        address token1 = uniPool.token1();

        if (token0 != denominateTo) {
            //get amount and convert to denominate addr;
            if (token0 != SFToken) {
                myreserve0 = _getOneSplitExpReturn(
                    OneSplit,
                    uniPool.token0(),
                    denominateTo,
                    myreserve0
                );
            }
            else {
                myreserve0 = 0;
            }
            
        }

        if (uniPool.token1() != denominateTo) {
            //get amount and convert to denominate addr;
            if (token1 != SFToken) {
                myreserve1 = _getOneSplitExpReturn(
                    OneSplit,
                    uniPool.token1(),
                    denominateTo,
                    myreserve0
                );
            }
            else {
                myreserve1 = 0;
            }
        }
        return (myreserve0, myreserve1);
    }

    function _getTotalValue() public view returns (uint256) {
        uint256 totalReserve = 0;

        for (uint256 i = 0; i < uniLen; i++) {
            address uniAddress = uniPools[i];
            if (uniAddress != address(0)) {
                IUniswapV2Pair uniPool = IUniswapV2Pair(uniAddress);

            (uint256 myreserve0, uint256 myreserve1) = _getDenominatedValue(
                uniPool
            );

            totalReserve = totalReserve.add(myreserve0);
            totalReserve = totalReserve.add(myreserve1);
                
            }
        }

        totalReserve = totalReserve.add(_getExternalValue());

        return totalReserve;
    }

    function addUni(address pool) public onlyVoter {
        uniPools[uniLen] = pool;
        uniLen++;
    }

    function delUni(uint i) external onlyVoter {
        uniPools[i] = address(0);
    }
    
    function addExt(address pool) public onlyVoter {
        externalPools[uniLen] = pool;
        extLen++;
    }

    function delExt(uint i) external onlyVoter {
        externalPools[i] = address(0);
    }
}