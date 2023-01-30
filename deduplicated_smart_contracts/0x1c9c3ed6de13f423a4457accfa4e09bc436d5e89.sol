/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


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

    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
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
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
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
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

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
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
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

interface IFlashLoanReceiver {
    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params) external;
}

contract ILendingPoolAddressesProvider {

    function getLendingPool() public view returns (address);
    function setLendingPoolImpl(address _pool) public;

    function getLendingPoolCore() public view returns (address payable);
    function setLendingPoolCoreImpl(address _lendingPoolCore) public;

    function getLendingPoolConfigurator() public view returns (address);
    function setLendingPoolConfiguratorImpl(address _configurator) public;

    function getLendingPoolDataProvider() public view returns (address);
    function setLendingPoolDataProviderImpl(address _provider) public;

    function getLendingPoolParametersProvider() public view returns (address);
    function setLendingPoolParametersProviderImpl(address _parametersProvider) public;

    function getTokenDistributor() public view returns (address);
    function setTokenDistributor(address _tokenDistributor) public;

    function getFeeProvider() public view returns (address);
    function setFeeProviderImpl(address _feeProvider) public;

    function getLendingPoolLiquidationManager() public view returns (address);
    function setLendingPoolLiquidationManager(address _manager) public;

    function getLendingPoolManager() public view returns (address);
    function setLendingPoolManager(address _lendingPoolManager) public;

    function getPriceOracle() public view returns (address);
    function setPriceOracle(address _priceOracle) public;

    function getLendingRateOracle() public view returns (address);
    function setLendingRateOracle(address _lendingRateOracle) public;

}

contract FlashLoanReceiverBase is IFlashLoanReceiver {
    using SafeMath for uint256;

    address constant ETHADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    ILendingPoolAddressesProvider public addressesProvider = ILendingPoolAddressesProvider(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);

    function () external payable {    }

    function transferFundsBackToPoolInternal(address _reserve, uint256 _amount) internal {
        address payable core = addressesProvider.getLendingPoolCore();
        transferInternal(core,_reserve, _amount);
    }

    function transferInternal(address payable _destination, address _reserve, uint256  _amount) internal {
        if(_reserve == ETHADDRESS) {
            //solium-disable-next-line
            _destination.call.value(_amount)("");
            return;
        }

        IERC20(_reserve).transfer(_destination, _amount);
    }

    function getBalanceInternal(address _target, address _reserve) internal view returns(uint256) {
        if(_reserve == ETHADDRESS) {

            return _target.balance;
        }

        return IERC20(_reserve).balanceOf(_target);
    }
}

contract GemLike {
    function approve(address, uint) public;
    function transfer(address, uint) public;
    function transferFrom(address, address, uint) public;
    function deposit() public payable;
    function withdraw(uint) public;
}

contract ManagerLike {
    function cdpCan(address, uint, address) public view returns (uint);
    function ilks(uint) public view returns (bytes32);
    function owns(uint) public view returns (address);
    function urns(uint) public view returns (address);
    function vat() public view returns (address);
    function open(bytes32, address) public returns (uint);
    function give(uint, address) public;
    function cdpAllow(uint, address, uint) public;
    function urnAllow(address, uint) public;
    function frob(uint, int, int) public;
    function flux(uint, address, uint) public;
    function move(uint, address, uint) public;
    function exit(address, uint, address, uint) public;
    function quit(uint, address) public;
    function enter(address, uint) public;
    function shift(uint, uint) public;
}

contract VatLike {
    function can(address, address) public view returns (uint);
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function dai(address) public view returns (uint);
    function urns(bytes32, address) public view returns (uint, uint);
    function frob(bytes32, address, address, address, int, int) public;
    function hope(address) public;
    function move(address, address, uint) public;
}

contract GemJoinLike {
    function dec() public returns (uint);
    function gem() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract DaiJoinLike {
    function vat() public returns (VatLike);
    function dai() public returns (GemLike);
    function join(address, uint) public payable;
    function exit(address, uint) public;
}

contract JugLike {
    function drip(bytes32) public returns (uint);
}

contract Common {
    uint256 constant RAY = 10 ** 27;

    // Internal functions

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    // Public functions

    function daiJoin_join(
        address apt,
        address urn,
        uint wad
    ) public {
        // DAI Already flashloaned
        // DaiJoinLike(apt).dai().transferFrom(dacProxyAddress, dedgeMakerManagerAddress, wad);
        // Approves adapter to take the DAI amount
        DaiJoinLike(apt).dai().approve(apt, wad);
        // Joins DAI into the vat
        DaiJoinLike(apt).join(urn, wad);
    }
}

contract DssProxyActionsBase is Common {
    // Internal functions

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

    function convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {
        // For those collaterals that have less than 18 decimals precision we need to do the conversion before passing to frob function
        // Adapters will automatically handle the difference of precision
        wad = mul(
            amt,
            10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }

    function convertToGemUnits(address gemJoin, uint256 wad) internal returns (uint256 amt) {
        // For those collaterals that have less than 18 decimals precision we need to do the conversion
        amt = wad / (10 ** (18 - GemJoinLike(gemJoin).dec()));
    }

    function _getDrawDart(
        address vat,
        address jug,
        address urn,
        bytes32 ilk,
        uint wad
    ) internal returns (int dart) {
        // Updates stability fee rate
        uint rate = JugLike(jug).drip(ilk);

        // Gets DAI balance of the urn in the vat
        uint dai = VatLike(vat).dai(urn);

        // If there was already enough DAI in the vat balance, just exits it without adding more debt
        if (dai < mul(wad, RAY)) {
            // Calculates the needed dart so together with the existing dai in the vat is enough to exit wad amount of DAI tokens
            dart = toInt(sub(mul(wad, RAY), dai) / rate);
            // This is neeeded due lack of precision. It might need to sum an extra dart wei (for the given DAI wad amount)
            dart = mul(uint(dart), rate) < mul(wad, RAY) ? dart + 1 : dart;
        }
    }

    function _getWipeAllWad(
        address vat,
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint wad) {
        // Gets actual rate from the vat
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        // Gets actual art value of the urn
        (, uint art) = VatLike(vat).urns(ilk, urn);
        // Gets actual dai amount in the urn
        uint dai = VatLike(vat).dai(usr);

        uint rad = sub(mul(art, rate), dai);
        wad = rad / RAY;

        // If the rad precision has some dust, it will need to request for 1 extra wad wei
        wad = mul(wad, RAY) < rad ? wad + 1 : wad;
    }

    function open(
        address manager,
        bytes32 ilk,
        address usr
    ) public returns (uint cdp) {
        cdp = ManagerLike(manager).open(ilk, usr);
    }

    function give(
        address manager,
        uint cdp,
        address usr
    ) public {
        ManagerLike(manager).give(cdp, usr);
    }

    function cdpAllow(
        address manager,
        uint cdp,
        address usr,
        uint ok
    ) public {
        ManagerLike(manager).cdpAllow(cdp, usr, ok);
    }

    function flux(
        address manager,
        uint cdp,
        address dst,
        uint wad
    ) public {
        ManagerLike(manager).flux(cdp, dst, wad);
    }

    function frob(
        address manager,
        uint cdp,
        int dink,
        int dart
    ) public {
        ManagerLike(manager).frob(cdp, dink, dart);
    }

    function wipeAllAndFreeETH(
        address manager,
        address ethJoin,
        address daiJoin,
        uint cdp,
        uint wadC
    ) public {
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        (, uint art) = VatLike(vat).urns(ilk, urn);

        // Joins DAI amount into the vat
        daiJoin_join(daiJoin, urn, _getWipeAllWad(vat, urn, urn, ilk));
        // Paybacks debt to the CDP and unlocks WETH amount from it
        frob(
            manager,
            cdp,
            -toInt(wadC),
            -int(art)
        );
        // Moves the amount from the CDP urn to proxy's address
        flux(manager, cdp, address(this), wadC);
        // Exits WETH amount to proxy address as a token
        GemJoinLike(ethJoin).exit(address(this), wadC);
        // Converts WETH to ETH
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        // Sends ETH back to the user's wallet
        // msg.sender.transfer(wadC);
    }

    function wipeAllAndFreeGem(
        address manager,
        address gemJoin,
        address daiJoin,
        uint cdp,
        uint wadC
    ) public {
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        (, uint art) = VatLike(vat).urns(ilk, urn);

        // Joins DAI amount into the vat
        daiJoin_join(daiJoin, urn, _getWipeAllWad(vat, urn, urn, ilk));
        uint wad18 = convertTo18(gemJoin, wadC);
        // Paybacks debt to the CDP and unlocks token amount from it
        frob(
            manager,
            cdp,
            -toInt(wad18),
            -int(art)
        );
        // Moves the amount from the CDP urn to proxy's address
        flux(manager, cdp, address(this), wad18);
        // Exits token amount to the user's wallet as a token
        GemJoinLike(gemJoin).exit(address(this), wadC);
    }
}

contract IUniswapExchange {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

contract IUniswapFactory {
    // Public Variables
    address public exchangeTemplate;
    uint256 public tokenCount;
    // Create Exchange
    function createExchange(address token) external returns (address exchange);
    // Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    // Never use
    function initializeFactory(address template) external;
}

contract UniswapBase {
    // Uniswap Mainnet factory address
    address constant UniswapFactoryAddress = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;

    function _getUniswapExchange(address tokenAddress) internal view returns (address) {
        return IUniswapFactory(UniswapFactoryAddress).getExchange(tokenAddress);
    }

    function _buyTokensWithEthFromUniswap(address tokenAddress, uint ethAmount) internal returns (uint) {
        return IUniswapExchange(_getUniswapExchange(tokenAddress))
            .ethToTokenSwapInput.value(ethAmount)(uint(1), uint(now + 60));
    }

    function _buyTokensWithEthFromUniswap(address tokenAddress, uint ethAmount, uint minAmount) internal returns (uint) {
        return IUniswapExchange(_getUniswapExchange(tokenAddress))
            .ethToTokenSwapInput.value(ethAmount)(minAmount, uint(now + 60));
    }

    function _sellTokensForEthFromUniswap(address tokenAddress, uint tokenAmount) internal returns (uint) {
        address exchange = _getUniswapExchange(tokenAddress);

        IERC20(tokenAddress).approve(exchange, tokenAmount);

        return IUniswapExchange(exchange)
            .tokenToEthSwapInput(tokenAmount, uint(1), uint(now + 60));
    }

    function _sellTokensForTokensFromUniswap(address from, address to, uint tokenAmount) internal returns (uint) {
        uint ethAmount = _sellTokensForEthFromUniswap(from, tokenAmount);
        return _buyTokensWithEthFromUniswap(to, ethAmount);
    }

    function getTokenToEthInputPriceFromUniswap(address tokenAddress, uint tokenAmount) public view returns (uint) {
        return IUniswapExchange(_getUniswapExchange(tokenAddress)).getTokenToEthInputPrice(tokenAmount);
    }

    function getEthToTokenInputPriceFromUniswap(address tokenAddress, uint ethAmount) public view returns (uint) {
        return IUniswapExchange(_getUniswapExchange(tokenAddress)).getEthToTokenInputPrice(ethAmount);
    }

    function getTokenToTokenPriceFromUniswap(address from, address to, uint fromAmount) public view returns (uint) {
        uint ethAmount = getTokenToEthInputPriceFromUniswap(from, fromAmount);
        return getEthToTokenInputPriceFromUniswap(to, ethAmount);
    }
}

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (address(authority) == address(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract DSGuardEvents {
    event LogPermit(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );

    event LogForbid(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );
}

contract DSGuard is DSAuth, DSAuthority, DSGuardEvents {
    bytes32 constant public ANY = bytes32(uint(-1));

    mapping (bytes32 => mapping (bytes32 => mapping (bytes32 => bool))) acl;

    function canCall(
        address src_, address dst_, bytes4 sig
    ) public view returns (bool) {
        bytes32 src = bytes32(bytes20(src_));
        bytes32 dst = bytes32(bytes20(dst_));

        return acl[src][dst][sig]
            || acl[src][dst][ANY]
            || acl[src][ANY][sig]
            || acl[src][ANY][ANY]
            || acl[ANY][dst][sig]
            || acl[ANY][dst][ANY]
            || acl[ANY][ANY][sig]
            || acl[ANY][ANY][ANY];
    }

    function permit(bytes32 src, bytes32 dst, bytes32 sig) public auth {
        acl[src][dst][sig] = true;
        emit LogPermit(src, dst, sig);
    }

    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public auth {
        acl[src][dst][sig] = false;
        emit LogForbid(src, dst, sig);
    }

    function permit(address src, address dst, bytes32 sig) public {
        permit(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);
    }
    function forbid(address src, address dst, bytes32 sig) public {
        forbid(bytes32(bytes20(src)), bytes32(bytes20(dst)), sig);
    }

}

contract DSGuardFactory {
    mapping (address => bool)  public  isGuard;

    function newGuard() public returns (DSGuard guard) {
        guard = new DSGuard();
        guard.setOwner(msg.sender);
        isGuard[address(guard)] = true;
    }
}

contract BytesLibLite {
    // A lite version of the ByteLib, containing only the "slice" function we need

    function sliceToEnd(
        bytes memory _bytes,
        uint256 _start
    ) internal pure returns (bytes memory) {
        require(_start < _bytes.length, "bytes-read-out-of-bounds");

        return slice(
            _bytes,
            _start,
            _bytes.length - _start
        );
    }
    
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length), "bytes-read-out-of-bounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function bytesToAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= (_start + 20), "Read out of bounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }
}

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);

        _;
    }
}

contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache;  // global cache for contracts

    constructor(address _cacheAddr) public {
        setCache(_cacheAddr);
    }

    function() external payable {
    }

    // use the proxy to execute calldata _data on contract _code
    function execute(bytes memory _code, bytes memory _data)
        public
        payable
        returns (address target, bytes memory response)
    {
        target = cache.read(_code);
        if (target == address(0)) {
            // deploy contract & store its address in cache
            target = cache.write(_code);
        }

        response = execute(target, _data);
    }

    function execute(address _target, bytes memory _data)
        public
        auth
        note
        payable
        returns (bytes memory response)
    {
        require(_target != address(0), "ds-proxy-target-address-required");

        // call contract in current context
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _target, add(_data, 0x20), mload(_data), 0, 0)
            let size := returndatasize

            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
            case 1 {
                // throw if delegatecall failed
                revert(add(response, 0x20), size)
            }
        }
    }

    //set new cache
    function setCache(address _cacheAddr)
        public
        auth
        note
        returns (bool)
    {
        require(_cacheAddr != address(0), "ds-proxy-cache-address-required");
        cache = DSProxyCache(_cacheAddr);  // overwrite cache
        return true;
    }
}

contract DSProxyFactory {
    event Created(address indexed sender, address indexed owner, address proxy, address cache);
    mapping(address=>address) public proxies;
    DSProxyCache public cache;

    constructor() public {
        cache = new DSProxyCache();
    }

    // deploys a new proxy instance
    // sets owner of proxy to caller
    function build() public returns (address payable proxy) {
        proxy = build(msg.sender);
    }

    // deploys a new proxy instance
    // sets custom owner of proxy
    function build(address owner) public returns (address payable proxy) {
        proxy = address(new DSProxy(address(cache)));
        emit Created(msg.sender, owner, address(proxy), address(cache));
        DSProxy(proxy).setOwner(owner);
        proxies[owner] = proxy;
    }
}

contract DSProxyCache {
    mapping(bytes32 => address) cache;

    function read(bytes memory _code) public view returns (address) {
        bytes32 hash = keccak256(_code);
        return cache[hash];
    }

    function write(bytes memory _code) public returns (address target) {
        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
            case 1 {
                // throw if contract failed to deploy
                revert(0, 0)
            }
        }
        bytes32 hash = keccak256(_code);
        cache[hash] = target;
    }
}

contract DACProxy is
    DSProxy(address(1)),
    FlashLoanReceiverBase,
    BytesLibLite
{
    // TODO: Change this value
    address payable constant protocolFeePayoutAddress1 = 0x773CCbFB422850617A5680D40B1260422d072f41;
    address payable constant protocolFeePayoutAddress2 = 0xAbcCB8f0a3c206Bb0468C52CCc20f3b81077417B;

    constructor(address _cacheAddr) public {
        setCache(_cacheAddr);
    }

    function() external payable {}

    // This is for Aave flashloans
    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee,
        bytes calldata _params
    ) external
        auth
    {
        // Assumes that once the action(s) are performed
        // we will have totalDebt would of _reserve to repay
        // aave and the protocol
        uint protocolFee = _fee.div(2);

        // Re-encodes new data 
        // Function signature should conform to:
        /* (
                // Note: for address, as abiEncoder pads it to 32 bytes our starting position is 12
                // due to addresses having 20 bytes in length
                address     - Address to call        | start: 12;  (20 bytes)
                bytes       - Function sig           | start: 32;  (4 bytes)
                uint        - Data of _amount        | start: 36;  (32 bytes)
                uint        - Data of _aaveFee       | start: 68;  (32 bytes)
                uint        - Data of _protocolFee   | start: 100; (32 bytes)
                bytes       - Data of _data          | start: 132; (dynamic length)
            )

            i.e.

            function myFunction(
                uint amount,
                uint aaveFee,
                uint protocolFee,
                bytes memory _data
            ) { ... }
        */
        address targetAddress = bytesToAddress(_params, 12);
        bytes memory fSig     = slice(_params, 32, 4);
        bytes memory data     = sliceToEnd(_params, 132);

        // Re-encodes function signature and injects new
        // _amount, _fee, and _protocolFee into _data
        bytes memory newData = abi.encodePacked(
            fSig,
            abi.encode(_amount),
            abi.encode(_fee),
            abi.encode(protocolFee),
            data
        );

        // Executes new target
        execute(targetAddress, newData);

        // Repays protocol fee
        if (_reserve == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            protocolFeePayoutAddress1.call.value(protocolFee.div(2))("");
            protocolFeePayoutAddress2.call.value(protocolFee.div(2))("");
        } else {
            IERC20(_reserve).transfer(protocolFeePayoutAddress1, protocolFee.div(2));
            IERC20(_reserve).transfer(protocolFeePayoutAddress2, protocolFee.div(2));
        }

        // Repays aave
        transferFundsBackToPoolInternal(_reserve, _amount.add(_fee));
    }
}

interface ILendingPool {
  function addressesProvider () external view returns ( address );
  function deposit ( address _reserve, uint256 _amount, uint16 _referralCode ) external payable;
  function redeemUnderlying ( address _reserve, address _user, uint256 _amount ) external;
  function borrow ( address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode ) external;
  function repay ( address _reserve, uint256 _amount, address _onBehalfOf ) external payable;
  function swapBorrowRateMode ( address _reserve ) external;
  function rebalanceFixedBorrowRate ( address _reserve, address _user ) external;
  function setUserUseReserveAsCollateral ( address _reserve, bool _useAsCollateral ) external;
  function liquidationCall ( address _collateral, address _reserve, address _user, uint256 _purchaseAmount, bool _receiveAToken ) external payable;
  function flashLoan ( address _receiver, address _reserve, uint256 _amount, bytes calldata _params ) external;
  function getReserveConfigurationData ( address _reserve ) external view returns ( uint256 ltv, uint256 liquidationThreshold, uint256 liquidationDiscount, address interestRateStrategyAddress, bool usageAsCollateralEnabled, bool borrowingEnabled, bool fixedBorrowRateEnabled, bool isActive );
  function getReserveData ( address _reserve ) external view returns ( uint256 totalLiquidity, uint256 availableLiquidity, uint256 totalBorrowsFixed, uint256 totalBorrowsVariable, uint256 liquidityRate, uint256 variableBorrowRate, uint256 fixedBorrowRate, uint256 averageFixedBorrowRate, uint256 utilizationRate, uint256 liquidityIndex, uint256 variableBorrowIndex, address aTokenAddress, uint40 lastUpdateTimestamp );
  function getUserAccountData ( address _user ) external view returns ( uint256 totalLiquidityETH, uint256 totalCollateralETH, uint256 totalBorrowsETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor );
  function getUserReserveData ( address _reserve, address _user ) external view returns ( uint256 currentATokenBalance, uint256 currentUnderlyingBalance, uint256 currentBorrowBalance, uint256 principalBorrowBalance, uint256 borrowRateMode, uint256 borrowRate, uint256 liquidityRate, uint256 originationFee, uint256 variableBorrowIndex, uint256 lastUpdateTimestamp, bool usageAsCollateralEnabled );
  function getReserves () external view;
}

interface IComptroller {
    /**
     * @notice Marker function used for light validation when updating the comptroller of a market
     * @dev Implementations should simply return true.
     * @return true
     */
    function isComptroller() external view returns (bool);

    /*** Assets You Are In ***/

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function exitMarket(address cToken) external returns (uint);

    /*** Policy Hooks ***/

    function getAccountLiquidity(address account) external view returns (uint, uint, uint);
    function getAssetsIn(address account) external view returns (address[] memory);

    function mintAllowed(address cToken, address minter, uint mintAmount) external returns (uint);
    function mintVerify(address cToken, address minter, uint mintAmount, uint mintTokens) external;

    function redeemAllowed(address cToken, address redeemer, uint redeemTokens) external returns (uint);
    function redeemVerify(address cToken, address redeemer, uint redeemAmount, uint redeemTokens) external;

    function borrowAllowed(address cToken, address borrower, uint borrowAmount) external returns (uint);
    function borrowVerify(address cToken, address borrower, uint borrowAmount) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);
    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);
    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);
    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;

    function transferAllowed(address cToken, address src, address dst, uint transferTokens) external returns (uint);
    function transferVerify(address cToken, address src, address dst, uint transferTokens) external;

    /*** Liquidity/Liquidation Calculations ***/

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint repayAmount) external view returns (uint, uint);
}

interface ICToken {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint256);
    function balanceOfUnderlying(address account) external returns (uint);
    
    function underlying() external view returns (address);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function allowance(address, address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}

contract ICEther {
    function mint() external payable;
    function borrow(uint borrowAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function repayBorrow() external payable;
    function repayBorrowBehalf(address borrower) external payable;
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrowBalanceStored(address account) external view returns (uint256);
    function balanceOfUnderlying(address account) external returns (uint);
    function balanceOf(address owner) external view returns (uint256);
}

contract IDssProxyActions {
    function cdpAllow(address manager,uint256 cdp,address usr,uint256 ok) external;
    function daiJoin_join(address apt,address urn,uint256 wad) external;
    function draw(address manager,address jug,address daiJoin,uint256 cdp,uint256 wad) external;
    function enter(address manager,address src,uint256 cdp) external;
    function ethJoin_join(address apt,address urn) external;
    function exitETH(address manager,address ethJoin,uint256 cdp,uint256 wad) external;
    function exitGem(address manager,address gemJoin,uint256 cdp,uint256 wad) external;
    function flux(address manager,uint256 cdp,address dst,uint256 wad) external;
    function freeETH(address manager,address ethJoin,uint256 cdp,uint256 wad) external;
    function freeGem(address manager,address gemJoin,uint256 cdp,uint256 wad) external;
    function frob(address manager,uint256 cdp,int256 dink,int256 dart) external;
    function gemJoin_join(address apt,address urn,uint256 wad,bool transferFrom) external;
    function give(address manager,uint256 cdp,address usr) external;
    function giveToProxy(address proxyRegistry,address manager,uint256 cdp,address dst) external;
    function hope(address obj,address usr) external;
    function lockETH(address manager,address ethJoin,uint256 cdp) external;
    function lockETHAndDraw(address manager,address jug,address ethJoin,address daiJoin,uint256 cdp,uint256 wadD) external;
    function lockGem(address manager,address gemJoin,uint256 cdp,uint256 wad,bool transferFrom) external;
    function lockGemAndDraw(address manager,address jug,address gemJoin,address daiJoin,uint256 cdp,uint256 wadC,uint256 wadD,bool transferFrom) external;
    function makeGemBag(address gemJoin) external returns (address bag);
    function move(address manager,uint256 cdp,address dst,uint256 rad) external;
    function nope(address obj,address usr) external;
    function open(address manager,bytes32 ilk,address usr) external returns (uint256 cdp);
    function openLockETHAndDraw(address manager,address jug,address ethJoin,address daiJoin,bytes32 ilk,uint256 wadD) external returns (uint256 cdp);
    function openLockGNTAndDraw(address manager,address jug,address gntJoin,address daiJoin,bytes32 ilk,uint256 wadC,uint256 wadD) external returns (address bag,uint256 cdp);
    function openLockGemAndDraw(address manager,address jug,address gemJoin,address daiJoin,bytes32 ilk,uint256 wadC,uint256 wadD,bool transferFrom) external returns (uint256 cdp);
    function quit(address manager,uint256 cdp,address dst) external;
    function safeLockETH(address manager,address ethJoin,uint256 cdp,address owner) external;
    function safeLockGem(address manager,address gemJoin,uint256 cdp,uint256 wad,bool transferFrom,address owner) external;
    function safeWipe(address manager,address daiJoin,uint256 cdp,uint256 wad,address owner) external;
    function safeWipeAll(address manager,address daiJoin,uint256 cdp,address owner) external;
    function shift(address manager,uint256 cdpSrc,uint256 cdpOrg) external;
    function transfer(address gem,address dst,uint256 wad) external;
    function urnAllow(address manager,address usr,uint256 ok) external;
    function wipe(address manager,address daiJoin,uint256 cdp,uint256 wad) external;
    function wipeAll(address manager,address daiJoin,uint256 cdp) external;
    function wipeAllAndFreeETH(address manager,address ethJoin,address daiJoin,uint256 cdp,uint256 wadC) external;
    function wipeAllAndFreeGem(address manager,address gemJoin,address daiJoin,uint256 cdp,uint256 wadC) external;
    function wipeAndFreeETH(address manager,address ethJoin,address daiJoin,uint256 cdp,uint256 wadC,uint256 wadD) external;
    function wipeAndFreeGem(address manager,address gemJoin,address daiJoin,uint256 cdp,uint256 wadC,uint256 wadD) external;
}

contract AddressRegistry {
    // Aave
    address public AaveLendingPoolAddressProviderAddress = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
    address public AaveEthAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Uniswap
    address public UniswapFactoryAddress = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;

    // Compound
    address public CompoundPriceOracleAddress = 0x1D8aEdc9E924730DD3f9641CDb4D1B92B848b4bd;
    address public CompoundComptrollerAddress = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    address public CEtherAddress = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    address public CUSDCAddress = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    address public CDaiAddress = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address public CSaiAddress = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;

    // Token(s)
    address public DaiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public BatAddress = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
    address public UsdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // MakerDAO
    // https://changelog.makerdao.com/
    // https://changelog.makerdao.com/releases/mainnet/1.0.4/contracts.json
    address public EthJoinAddress = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;
    address public UsdcJoinAddress = 0xA191e578a6736167326d05c119CE0c90849E84B7;
    address public BatJoinAddress = 0x3D0B1912B66114d4096F48A8CEe3A56C231772cA;
    address public DaiJoinAddress = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public JugAddress = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address public DssProxyActionsAddress = 0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038;
    address public DssCdpManagerAddress = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
}

contract DedgeMakerManager is DssProxyActionsBase {
    function () external payable {}

    constructor () public {}

    struct ImportMakerVaultCallData {
        address addressRegistryAddress;
        uint cdpId;
        address collateralCTokenAddress;
        address collateralJoinAddress;
        uint8 collateralDecimals;
    }

    // Helper functions
    function _proxyGuardPermit(address payable proxyAddress, address src) internal {
        address g = address(DACProxy(proxyAddress).authority());

        DSGuard(g).permit(
            bytes32(bytes20(address(src))),
            DSGuard(g).ANY(),
            DSGuard(g).ANY()
        );
    }

    function _proxyGuardForbid(address payable proxyAddress, address src) internal {
        address g = address(DACProxy(proxyAddress).authority());

        DSGuard(g).forbid(
            bytes32(bytes20(address(src))),
            DSGuard(g).ANY(),
            DSGuard(g).ANY()
        );
    }

    function _convert18ToDecimal(uint amount, uint8 decimals) internal returns (uint) {
        return amount / (10 ** (18 - uint(decimals)));
    }

    function _convert18ToGemUnits(address gemJoin, uint256 wad) internal returns (uint) {
        return wad / (10 ** (18 - GemJoinLike(gemJoin).dec()));
    }

    // Gets vault debt in 18 wei
    function getVaultDebt(address manager, uint cdp) public view returns (uint debt)
    {
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        address owner = ManagerLike(manager).owns(cdp);

        debt = _getWipeAllWad(vat, owner, urn, ilk);
    }

    function getVaultCollateral(
        address manager,
        uint cdp
    ) public view returns (uint ink) {
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);

        // Note: This returns in 18 decimals, need to
        // convert to gemUnits before passing it to
        // dss-proxy-actions
        (ink,) = VatLike(vat).urns(ilk, urn);
    }

    // Function to be called by proxy post loan
    // in order to import maker vault
    function importMakerVaultPostLoan(
        uint _amount,
        uint _aaveFee,
        uint _protocolFee,
        bytes calldata _data
    ) external {
        // Calculate total debt
        uint totalDebt = _amount + _aaveFee + _protocolFee;

        // Reconstruct data
        ImportMakerVaultCallData memory imvCalldata = abi.decode(_data, (ImportMakerVaultCallData));

        // Extract relevant data
        AddressRegistry addressRegistry = AddressRegistry(imvCalldata.addressRegistryAddress);
        address cdpManager = addressRegistry.DssCdpManagerAddress();
        address collateralCTokenAddress = imvCalldata.collateralCTokenAddress;

        // Collateral in 18 decimal places
        uint collateral18 = getVaultCollateral(cdpManager, imvCalldata.cdpId);

        // Joins the ETH/GEM/DAI market in compound if they haven't already
        address[] memory enterMarketsCToken = new address[](2);
        enterMarketsCToken[0] = collateralCTokenAddress;
        enterMarketsCToken[1] = addressRegistry.CDaiAddress();

        uint[] memory enterMarketErrors = IComptroller(
            addressRegistry.CompoundComptrollerAddress()
        ).enterMarkets(enterMarketsCToken);

        require(enterMarketErrors[0] == 0, "mkr-enter-gem-failed");
        require(enterMarketErrors[1] == 0, "mkr-enter-dai-failed");

        if (ManagerLike(cdpManager).ilks(imvCalldata.cdpId) == bytes32("ETH-A")) {
            wipeAllAndFreeETH(
                cdpManager,
                addressRegistry.EthJoinAddress(),
                addressRegistry.DaiJoinAddress(),
                imvCalldata.cdpId,
                collateral18
            );

            // Supply ETH and Borrow DAI (Compound)
            ICEther(addressRegistry.CEtherAddress()).mint.value(collateral18)();
            require(
                ICToken(addressRegistry.CDaiAddress()).borrow(totalDebt) == 0,
                "dai-borrow-fail"
            );
        } else {
            // Free GEM
            wipeAllAndFreeGem(
                cdpManager,
                imvCalldata.collateralJoinAddress,
                addressRegistry.DaiJoinAddress(),
                imvCalldata.cdpId,
                _convert18ToGemUnits(
                    imvCalldata.collateralJoinAddress,
                    collateral18
                )
            );

            // Convert collateral to relevant decimal places
            uint collateralFixedDec = _convert18ToDecimal(
                collateral18, imvCalldata.collateralDecimals
            );

            // Approve CToken Collateral underlying to enable call transferFrom
            IERC20(ICToken(collateralCTokenAddress).underlying())
                .approve(collateralCTokenAddress, collateralFixedDec);

            // Supply GEM and Borrow DAI (Compound)
            require(
                ICToken(collateralCTokenAddress).mint(
                    collateralFixedDec
                ) == 0,
                "gem-supply-fail"
            );
            require(
                ICToken(addressRegistry.CDaiAddress()).borrow(totalDebt) == 0,
                "dai-borrow-fail"
            );
        }
    }

    /* 
    Main entry point maker vault into Dedge

    @params:
        dacProxyAddress: User's proxy address
        addressRegistryAddress: AddressRegistry's Address
        cdpId: User's cdpId
        executeOperationCalldataParams:
            Abi-encoded `data` used by User's proxy's `execute(address, <data>)` function
            Used to delegatecall to another contract (i.e. this contract) in the context
            of the proxy. This allows for better flexibility and decoupling of logic from
            user's proxy. In this specific case, it is expecting the results from: (from JS)

            ```
                const IDedgeMakerManager = ethers.utils.Interface(DedgeMakerManager.abi)

                const executeOperationCalldataParams = IDedgeMakerManager
                    .functions
                    .importMakerVaultPostLoan
                    .encode([ <parameters> ])
            ```
    */
    function importMakerVault(
        address dedgeMakerManagerAddress,
        address payable dacProxyAddress,
        address addressRegistryAddress,
        uint cdpId,
        bytes calldata executeOperationCalldataParams
    ) external {
        // Get Address Registry
        AddressRegistry addressRegistry = AddressRegistry(addressRegistryAddress);

        // Get cdpManager and proxy's guard address
        address cdpManager = addressRegistry.DssCdpManagerAddress();

        // Get Debt
        uint daiDebt = getVaultDebt(cdpManager, cdpId);

        // Injects the target address into calldataParams
        // so user proxy knows which address it'll be calling `calldataParams` on
        bytes memory addressAndExecuteOperationCalldataParams = abi.encodePacked(
            abi.encode(dedgeMakerManagerAddress),
            executeOperationCalldataParams
        );
        
        // Get lending pool address
        ILendingPool lendingPool = ILendingPool(
            ILendingPoolAddressesProvider(
                addressRegistry.AaveLendingPoolAddressProviderAddress()
            ).getLendingPool()
        );

        cdpAllow(addressRegistry.DssCdpManagerAddress(), cdpId, dedgeMakerManagerAddress, 1);
        _proxyGuardPermit(dacProxyAddress, address(lendingPool));

        lendingPool.flashLoan(
            dacProxyAddress,
            addressRegistry.DaiAddress(),
            daiDebt,
            addressAndExecuteOperationCalldataParams
        );

        // Once we're done with the vault, give it away (its empty anyway)
        give(addressRegistry.DssCdpManagerAddress(), cdpId, address(1));
        // Lending pool can't call our proxy address anymore
        _proxyGuardForbid(dacProxyAddress, address(lendingPool));
    }
}