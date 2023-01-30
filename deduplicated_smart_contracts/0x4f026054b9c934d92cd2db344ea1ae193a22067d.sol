/**
 *Submitted for verification at Etherscan.io on 2020-03-08
*/

// Copyright (C) 2019, 2020 dipeshsukhani, nodarjonashi, suhailg

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// Visit <https://www.gnu.org/licenses/>for a copy of the GNU Affero General Public License


// File: localhost/defizap/node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol

///@author DeFiZap
///@notice this contract implements one click conversion from ERC20 to UniPoolZap


pragma solidity ^0.5.0;

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

// File: localhost/defizap/node_modules/@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol

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

// File: localhost/defizap/node_modules/@openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


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



pragma solidity ^0.5.0;


// interface
interface IuniswapFactory_ERC20toUniPoolZapV1 {
    function getExchange(address token)
        external
        view
        returns (address exchange);
}

interface IuniswapExchange_ERC20toUniPoolZapV1 {
    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function tokenToEthSwapInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline
    ) external returns (uint256 eth_bought);
    function tokenToEthTransferInput(
        uint256 tokens_sold,
        uint256 min_eth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 eth_bought);
    function tokenToTokenSwapInput(
        uint256 tokens_sold,
        uint256 min_tokens_bought,
        uint256 min_eth_bought,
        uint256 deadline,
        address token_addr
    ) external returns (uint256 tokens_bought);
    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 deadline
    ) external payable returns (uint256);

}

contract Ownable {
    address payable public owner = 0x19627796b318E27C333530aD67c464Cfc37596ec;

    modifier onlyOwner() {
        require(isOwner(), "you are not authorised to call this function");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address payable newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        owner = newOwner;
    }

}

contract ERC20toUniPoolZapV2_General is Initializable, Ownable {
    using SafeMath for uint256;

    // state variables

    // - THESE MUST ALWAYS STAY IN THE SAME LAYOUT
    bool private stopped = false;

    IuniswapFactory_ERC20toUniPoolZapV1 public UniSwapFactoryAddress = IuniswapFactory_ERC20toUniPoolZapV1(
        0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95
    );

    mapping(address => uint256) private userBalance;

    // events
    event details(
        address indexed user,
        address toWhomIssued,
        address indexed IncomingTokenAddress,
        address indexed UniPoolUnderlyingTokenAddressTokenAddress
    );
    event residualETH(uint256 residualETHtransferred);

    // circuit breaker modifiers
    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    constructor() public {}

    function LetsInvest(
        address _toWhomToIssue,
        address _IncomingTokenContractAddress,
        uint256 _IncomingTokenQty,
        address _UniPoolsUnderlyingTokenAddress
    )
        public
        stopInEmergency
        returns (bool)
    {
        uint256 investmentQTY = _IncomingTokenQty;
        require(
            IERC20(_IncomingTokenContractAddress).transferFrom(
                msg.sender,
                address(this),
                investmentQTY
            ),
            "Error in transferring token:1"
        );
        require(
            (
                invest2UniPool(
                    investmentQTY,
                    _toWhomToIssue,
                    _IncomingTokenContractAddress,
                    _UniPoolsUnderlyingTokenAddress
                )
            ),
            "error in invest2UniPool"
        );
        emit details(
            msg.sender,
            _toWhomToIssue,
            _IncomingTokenContractAddress,
            _UniPoolsUnderlyingTokenAddress
        );
        return (true);
    }

    function invest2UniPool(
        uint256 _ERC20QTY,
        address _toWhomToIssue,
        address _IncomingTokenContractAddress,
        address _UniPoolsUnderlyingTokenAddress
    ) internal returns (bool) {
        // setting some internal variables
        uint256 EthOnConversion;
        uint256 nonConvertiblePortion;
        IuniswapExchange_ERC20toUniPoolZapV1 UniSwapExchangeContractAddress;
        // computation
        if (_IncomingTokenContractAddress == _UniPoolsUnderlyingTokenAddress) {
            nonConvertiblePortion = SafeMath.div(
                SafeMath.mul(_ERC20QTY, 503),
                1000
            );
            uint256 convertiblePortion = SafeMath.sub(
                _ERC20QTY,
                nonConvertiblePortion
            );
            // finding the uniswap address
            UniSwapExchangeContractAddress = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(_IncomingTokenContractAddress)
            );
            // approving the address
            IERC20(_IncomingTokenContractAddress).approve(
                address(UniSwapExchangeContractAddress),
                _ERC20QTY
            );
            // converting the required portion to ETH
            EthOnConversion = UniSwapExchangeContractAddress
                .tokenToEthSwapInput(
                convertiblePortion,
                1,
                SafeMath.add(now, 1800)
            );

        } else {
            // convert ERCs
            IuniswapExchange_ERC20toUniPoolZapV1 UniSwapExchangeContractAddress_incomingToken = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(_IncomingTokenContractAddress)
            );

            require(
                (
                    IERC20(_IncomingTokenContractAddress).approve(
                        address(UniSwapExchangeContractAddress_incomingToken),
                        _ERC20QTY
                    )
                ),
                "error in approval:3"
            );
            uint256 nonConvertiblePortion_beforeConversion = SafeMath.div(
                SafeMath.mul(_ERC20QTY, 503),
                1000
            );
            nonConvertiblePortion = UniSwapExchangeContractAddress_incomingToken
                .tokenToTokenSwapInput(
                nonConvertiblePortion_beforeConversion,
                1,
                1,
                SafeMath.add(now, 1800),
                _UniPoolsUnderlyingTokenAddress
            );

            uint256 convertiblePortion = SafeMath.sub(
                _ERC20QTY,
                nonConvertiblePortion_beforeConversion
            );

            EthOnConversion = UniSwapExchangeContractAddress_incomingToken
                .tokenToEthSwapInput(
                convertiblePortion,
                1,
                SafeMath.add(now, 1800)
            );

            require(
                (
                    IERC20(_IncomingTokenContractAddress).approve(
                        address(UniSwapExchangeContractAddress_incomingToken),
                        0
                    )
                ),
                "error in setting approval back to zero"
            );
            UniSwapExchangeContractAddress = IuniswapExchange_ERC20toUniPoolZapV1(
                UniSwapFactoryAddress.getExchange(
                    _UniPoolsUnderlyingTokenAddress
                )
            );

        }
        require(
            (
                addLiquidity(
                    _toWhomToIssue,
                    _UniPoolsUnderlyingTokenAddress,
                    nonConvertiblePortion,
                    UniSwapExchangeContractAddress,
                    EthOnConversion
                )
            ),
            "issue in adding Liquidity"
        );
        return (true);
    }

    function addLiquidity(
        address _toWhomToIssue,
        address _UniPoolsUnderlyingTokenAddress,
        uint256 _UsableERC20,
        IuniswapExchange_ERC20toUniPoolZapV1 _UniSwapExchangeContractAddress,
        uint256 _valueinETH
    ) internal returns (bool) {
        uint256 max_tokens_ans = getMaxTokens(
            address(_UniSwapExchangeContractAddress),
            IERC20(_UniPoolsUnderlyingTokenAddress),
            _valueinETH
        );

        require(
            (
                IERC20(_UniPoolsUnderlyingTokenAddress).approve(
                    address(_UniSwapExchangeContractAddress),
                    _UsableERC20
                )
            ),
            "error in approving the unicontract, addLiquidity"
        );
        uint256 LiquidityTokens = _UniSwapExchangeContractAddress
            .addLiquidity
            .value(_valueinETH)(1, max_tokens_ans, SafeMath.add(now, 1800));
        require(
            LiquidityTokens ==
                _UniSwapExchangeContractAddress.balanceOf(address(this)),
            "error3:DeFiZap"
        );
        require(
            _UniSwapExchangeContractAddress.transfer(
                _toWhomToIssue,
                LiquidityTokens
            ),
            "error6:DeFiZap"
        );

        // computing the remainder of the tokens
        uint256 residual = IERC20(_UniPoolsUnderlyingTokenAddress).balanceOf(
            address(this)
        );
        uint256 ETHfromResidual = _UniSwapExchangeContractAddress
            .tokenToEthTransferInput(
            residual,
            1,
            SafeMath.add(now, 1800),
            _toWhomToIssue
        );
        emit residualETH(ETHfromResidual);
        require(
            (
                IERC20(_UniPoolsUnderlyingTokenAddress).approve(
                    address(_UniSwapExchangeContractAddress),
                    0
                )
            ),
            "error in resetting the approval to zero"
        );
        return true;
    }

    function getMaxTokens(
        address _UniSwapExchangeContractAddress,
        IERC20 _ERC20TokenAddress,
        uint256 _value
    ) internal view returns (uint256) {
        uint256 contractBalance = address(_UniSwapExchangeContractAddress)
            .balance;
        uint256 eth_reserve = SafeMath.sub(contractBalance, _value);
        uint256 token_reserve = _ERC20TokenAddress.balanceOf(
            _UniSwapExchangeContractAddress
        );
        uint256 token_amount = SafeMath.div(
            SafeMath.mul(_value, token_reserve),
            eth_reserve
        ) +
            1;
        return token_amount;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner, qty);
    }

    // - to Pause the contract
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    // - to withdraw any ETH balance sitting in the contract
    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    // - fallback function let you / anyone send ETH to this wallet without the need to call any function
    function() external payable {
    }
}