/**
 *Submitted for verification at Etherscan.io on 2020-03-28
*/

/*

    Copyright 2020 Kollateral LLC.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity ^0.5.0;

contract ExternalCaller {
    function externalTransfer(address _to, uint256 _value) internal {
        require(address(this).balance >= _value, "ExternalCaller: insufficient ether balance");
        externalCall(_to, _value, "");
    }

    function externalCall(address _to, uint256 _value, bytes memory _data) internal {
        (bool success, bytes memory returndata) = _to.call.value(_value)(_data);
        require(success, string(returndata));
    }
}

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

contract BalanceCarrier is ExternalCaller {
    address private _ethTokenAddress;

    constructor (address ethTokenAddress) internal {
        _ethTokenAddress = ethTokenAddress;
    }

    function transfer(address tokenAddress, address to, uint256 amount) internal returns (bool) {
        if (tokenAddress == _ethTokenAddress) {
            externalTransfer(to, amount);
            return true;
        } else {
            return IERC20(tokenAddress).transfer(to, amount);
        }
    }

    function balanceOf(address tokenAddress) internal view returns (uint256) {
        if (tokenAddress == _ethTokenAddress) {
            return address(this).balance;
        } else {
            return IERC20(tokenAddress).balanceOf(address(this));
        }
    }
}


pragma solidity ^0.5.0;

contract IInvocationHook {
    function currentSender() external view returns (address);

    function currentTokenAddress() external view returns (address);

    function currentTokenAmount() external view returns (uint256);

    function currentRepaymentAmount() external view returns (uint256);
}


pragma solidity ^0.5.0;

contract IInvokable {
    function execute(bytes calldata data) external payable;
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

contract KollateralInvokable is IInvokable, BalanceCarrier {
    using SafeMath for uint256;

    uint256 internal MAX_REWARD_BIPS = 100;

    constructor () BalanceCarrier(address(1)) internal { }

    function () external payable { }

    function repay() internal repaymentSafeguard {
        require(
            transfer(currentTokenAddress(), msg.sender, currentRepaymentAmount()),
                "KollateralInvokable: failed to repay");
    }

    function currentSender() internal view returns (address) {
        return IInvocationHook(msg.sender).currentSender();
    }

    function currentTokenAddress() internal view returns (address) {
        return IInvocationHook(msg.sender).currentTokenAddress();
    }

    function currentTokenAmount() internal view returns (uint256) {
        return IInvocationHook(msg.sender).currentTokenAmount();
    }

    function currentRepaymentAmount() internal view returns (uint256) {
        return IInvocationHook(msg.sender).currentRepaymentAmount();
    }

    function isCurrentTokenEther() internal view returns (bool) {
        return currentTokenAddress() == address(1);
    }

    modifier repaymentSafeguard() {
        uint256 effectiveReward = currentRepaymentAmount().sub(currentTokenAmount())
        .mul(10000).div(currentTokenAmount());

        require(effectiveReward <= MAX_REWARD_BIPS, "KollateralInvokable: repayment reward too high");

        _;
    }
}


contract OptionsContract {
    function liquidate(address payable vaultOwner, uint256 oTokensToLiquidate)
        public;

    function optionsExchange() public returns (address);

    function maxOTokensLiquidatable(address payable vaultOwner)
        public
        view
        returns (uint256);

    function isUnsafe(address payable vaultOwner) public view returns (bool);

    function hasVault(address valtowner) public view returns (bool);

    function openVault() public returns (bool);

    function addETHCollateral(address payable vaultOwner)
        public
        payable
        returns (uint256);

    function maxOTokensIssuable(uint256 collateralAmt)
        public
        view
        returns (uint256);

    function getVault(address payable vaultOwner)
        public
        view
        returns (uint256, uint256, uint256, bool);

    function issueOTokens(uint256 oTokensToIssue, address receiver) public;

    function approve(address spender, uint256 amount) public returns (bool);
}


contract OptionsExchange {
    function buyOTokens(
        address payable receiver,
        address oTokenAddress,
        address paymentTokenAddress,
        uint256 oTokensToBuy
    ) public payable;

    function premiumToPay(
        address oTokenAddress,
        address paymentTokenAddress,
        uint256 oTokensToBuy
    ) public view returns (uint256);
}



// Solidity Interface
contract IUniswapExchange {
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold)
        external
        view
        returns (uint256 tokens_bought);

    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline)
        external
        payable
        returns (uint256 tokens_bought);
}

// Solidity Interface
contract IUniswapFactory {
    // Public Variables
    address public exchangeTemplate;
    uint256 public tokenCount;

    // Get Exchange and Token Info
    function getExchange(address token)
        external
        view
        returns (address exchange);
}

contract KollateralLiquidator is KollateralInvokable {
    IUniswapFactory public factory;

    constructor(IUniswapFactory _factory) public {
        factory = _factory;
    }

    function execute(bytes calldata data) external payable {
        (address vaultAddr, address oTokenAddr) = abi.decode(
            data,
            (address, address)
        );

        address payable vaultOwner = address(uint160(vaultAddr));
        OptionsContract oToken = OptionsContract(oTokenAddr);

        // 2. Buy oTokens on uniswap
        uint256 oTokensToBuy = oToken.maxOTokensLiquidatable(vaultOwner);
        require(oTokensToBuy > 0, "cannot liquidate a safe vault");

        OptionsExchange exchange = OptionsExchange(oToken.optionsExchange());

        address opynExchangePaymentToken = currentTokenAddress();

        if (!isCurrentTokenEther()) {
            IERC20(opynExchangePaymentToken).approve(
                address(exchange),
                currentTokenAmount()
            );
        } else {
            opynExchangePaymentToken = address(0);
        }

        exchange.buyOTokens(
            address(uint160(address(this))),
            oTokenAddr,
            opynExchangePaymentToken,
            oTokensToBuy
        );
        // 3. Liquidate
        oToken.liquidate(vaultOwner, oTokensToBuy);

        // 4. Use eth to buy back _reserve
        if (!isCurrentTokenEther()) {
            IUniswapExchange uniswap = IUniswapExchange(
                factory.getExchange(currentTokenAddress())
            );
            uint256 buyAmount = uniswap.getEthToTokenInputPrice(
                address(this).balance
            );
            uniswap.ethToTokenSwapInput.value(address(this).balance)(
                buyAmount,
                now + 10 minutes
            );
        }

        // // 5. pay back the $
        repay();

        // // 6. pay the user who liquidated
        if (isCurrentTokenEther()) {
            address(uint160(currentSender())).transfer(address(this).balance);
        } else {
            uint256 balance = IERC20(currentTokenAddress()).balanceOf(
                address(this)
            );
            IERC20(currentTokenAddress()).transfer(currentSender(), balance);
        }
    }
}