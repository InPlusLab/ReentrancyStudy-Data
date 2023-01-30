/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

pragma solidity ^0.5.12;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/ownership/Ownable.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Ownable implementation from an openzeppelin version.
 */
contract OpenZeppelinUpgradesOwnable {
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

interface Erc20 {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256 balance);
}

interface CErc20 {
    function mint(uint256) external returns (uint256);
    function borrow(uint256) external returns (uint256);
    function borrowRatePerBlock() external view returns (uint256);
    function borrowBalanceCurrent(address) external returns (uint256);
    function repayBorrow(uint256) external returns (uint256);
    function redeemUnderlying(uint) external returns (uint);
    function redeem(uint) external returns (uint);
}

interface CEth {
    function mint() external payable;
    function borrow(uint256) external returns (uint256);
    function repayBorrow() external payable;
    function borrowBalanceCurrent(address) external returns (uint256);
}

interface Comptroller {
    function markets(address) external returns (bool, uint256);
    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);
    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);
}

interface PriceOracle {
    function getUnderlyingPrice(address) external view returns (uint256);
}

interface CurveExchange {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
    function get_dy(int128, int128 j, uint256 dx) external view returns (uint256);
}

interface CurveExchangeAdapter {
    function swapThenBurn(bytes calldata _btcDestination, uint256 _amount, uint256 _minRenbtcAmount) external;
}

interface Gateway {
    function mint(bytes32 _pHash, uint256 _amount, bytes32 _nHash, bytes calldata _sig) external returns (uint256);
    function burn(bytes calldata _to, uint256 _amount) external returns (uint256);
}

interface GatewayRegistry {
    function getGatewayBySymbol(string calldata _tokenSymbol) external view returns (Gateway);
    function getGatewayByToken(address  _tokenAddress) external view returns (Gateway);
    function getTokenBySymbol(string calldata _tokenSymbol) external view returns (Erc20);
}

contract CompoundBorrower is Initializable {
    using SafeMath for uint256;
    address public owner;
    Erc20 public wbtc;
    CurveExchangeAdapter public curveAdapter;
    Erc20 public activeToken;
    CErc20 public activeCToken;
    
    function initialize(
        address _owner,
        address _wbtcToken,
        address _curveAdapter
    ) public {
        owner = _owner;
        wbtc = Erc20(_wbtcToken);
        curveAdapter = CurveExchangeAdapter(_curveAdapter);
        require(wbtc.approve(address(curveAdapter), uint256(-1)));
    }
    
    /// @notice Borrow WBTC from Compound Protocol, swap for renBTC, and redeem real BTC.
    ///
    /// @param _tokenAddress The address of the collateral token.
    /// @param _cTokenAddress The address of the collateral cToken.
    /// @param _tokenAmount The amount of collateral to provide to Compound.
    /// @param _comptrollerAddress The Compound comptroller address.
    /// @param _cWbtcAddress The address of cWBTC.
    /// @param _wbtcAmount The amount of WBTC to borrow.
    /// @param _minRenbtcAmount The minimum amount of renBTC to swap for.
    /// @param _btcDestination The bitcoin address to send BTC to.
    ///
    /// @return Nothing.
    function borrowWithErc20AndBurn(
        address _tokenAddress,
        address _cTokenAddress,
        uint256 _tokenAmount,
        address _comptrollerAddress,
        address _cWbtcAddress,
        uint256 _wbtcAmount,
        uint256 _minRenbtcAmount,
        bytes calldata _btcDestination
    ) external {
        Erc20 token = Erc20(_tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
        uint256 startWbtcBal = wbtc.balanceOf(address(this));
        
        // Approve cTokens before borrowing
        token.approve(address(_cTokenAddress), uint256(-1));
        token.approve(address(_cWbtcAddress), uint256(-1));
        wbtc.approve(address(_cTokenAddress), uint256(-1));
        wbtc.approve(address(_cWbtcAddress), uint256(-1));
        
        
        // Supply and Borrow WBTC from Compound
        borrowWbtcWithErc20(
            _cTokenAddress,
            _tokenAmount,
            _comptrollerAddress,
            _cWbtcAddress,
            _wbtcAmount
        );
        
        // Swap WBTC
        uint256 endWbtcBal = startWbtcBal.sub(wbtc.balanceOf(address(this)));
        curveAdapter.swapThenBurn(_btcDestination, endWbtcBal, _minRenbtcAmount);
        
        // Set active tokena and ctoken
        activeToken = Erc20(_tokenAddress);
        activeCToken = CErc20(_cTokenAddress);
    }
    
    /// @notice Borrow WBTC from Compound Protocol and keep funds in the contract.
    /// This is for testing purposes.
    ///
    /// @param _tokenAddress The address of the collateral token.
    /// @param _cTokenAddress The address of the collateral cToken.
    /// @param _tokenAmount The amount of collateral to provide to Compound.
    /// @param _comptrollerAddress The Compound comptroller address.
    /// @param _cWbtcAddress The address of cWBTC.
    /// @param _wbtcAmount The amount of WBTC to borrow.
    /// @param _minRenbtcAmount The minimum amount of renBTC to swap for.
    /// @param _btcDestination The bitcoin address to send BTC to.
    ///
    /// @return Nothing.
    function borrowWithErc20(
        address _tokenAddress,
        address _cTokenAddress,
        uint256 _tokenAmount,
        address _comptrollerAddress,
        address _cWbtcAddress,
        uint256 _wbtcAmount,
        uint256 _minRenbtcAmount,
        bytes calldata _btcDestination
    ) external {
        Erc20 token = Erc20(_tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
        
        // Approve cTokens before borrowing
        token.approve(address(_cTokenAddress), uint256(-1));
        token.approve(address(_cWbtcAddress), uint256(-1));
        wbtc.approve(address(_cTokenAddress), uint256(-1));
        wbtc.approve(address(_cWbtcAddress), uint256(-1));
        
        
        // Supply and Borrow WBTC from Compound
        borrowWbtcWithErc20(
            _cTokenAddress,
            _tokenAmount,
            _comptrollerAddress,
            _cWbtcAddress,
            _wbtcAmount
        );
        
        // Swap WBTC
        curveAdapter.swapThenBurn(_btcDestination, _wbtcAmount, _minRenbtcAmount);
        
        // Set active tokena and ctoken
        activeToken = Erc20(_tokenAddress);
        activeCToken = CErc20(_cTokenAddress);
    }
    
    /// @notice Borrow WBTC from Compound Protocol.
    ///
    /// @param _cTokenAddress The address of the collateral cToken.
    /// @param _tokenAmount The amount of collateral to provide to Compound.
    /// @param _comptrollerAddress The Compound comptroller address.
    /// @param _cWbtcAddress The address of cWBTC.
    /// @param _wbtcAmount The amount of WBTC to borrow.
    ///
    /// @return uint256.
    function borrowWbtcWithErc20(
        address _cTokenAddress,
        uint256 _tokenAmount,
        address _comptrollerAddress,
        address _cWbtcAddress,
        uint256 _wbtcAmount
    ) public returns (uint256) {
        CErc20 cToken = CErc20(_cTokenAddress);
        Comptroller comptroller = Comptroller(_comptrollerAddress);
        // PriceOracle priceOracle = PriceOracle(_priceOracleAddress);
        CErc20 cWbtc = CErc20(_cWbtcAddress);
        
        // Supply Token as collateral, get cToken in return
        cToken.mint(_tokenAmount);
        
        // Enter the Token market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = _cTokenAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }
        
        // Get my account's total liquidity value in Compound
        (uint256 error, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));
        if (error != 0) {
            revert("Comptroller.getAccountLiquidity failed.");
        }
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");
        
        // Borrow WBTC, check the WBTC balance for this contract's address
        cWbtc.borrow(_wbtcAmount);
        
        // Get the borrow balance
        uint256 borrows = cWbtc.borrowBalanceCurrent(address(this));
        return borrows;
    }
    
    /// @notice Repay current loan on Compound.
    ///
    /// @param _cWbtcAddress The address of cWBTC.
    /// @param _repayAmount The amount of WBTC to repay.
    ///
    /// @return Nothing.
    function repayBorrow(address _cWbtcAddress, uint _repayAmount) public {
        CErc20 cWbtc = CErc20(_cWbtcAddress);
        wbtc.transferFrom(msg.sender, address(this), _repayAmount);
        cWbtc.repayBorrow(_repayAmount);
    }
    
    /// @notice Redeem tokens from contract cTokens and transfer to owner.
    ///
    /// @param _cTokenAddress The address of the collateral cToken.
    /// @param _tokenAddress The address of the collateral token.
    /// @param _amount The amount of the collateral token to redeem and transfer.
    ///
    /// @return Nothing.
    function redeemUnderlyingAndWithdraw(address _cTokenAddress, address _tokenAddress, uint _amount) public {
        CErc20(_cTokenAddress).redeemUnderlying(_amount);
        Erc20(_tokenAddress).transfer(owner, _amount);
    }
    
    /// @notice Withdraw tokens from contract to owner.
    ///
    /// @param _tokenAddress The address of the token.
    /// @param _withdrawAmount The amount of the token to transfer.
    ///
    /// @return Nothing.
    function withdrawToken(address _tokenAddress, uint _withdrawAmount) public {
        Erc20(_tokenAddress).transfer(owner, _withdrawAmount);
    }
}