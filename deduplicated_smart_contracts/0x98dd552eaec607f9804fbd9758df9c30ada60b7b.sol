/**
 *Submitted for verification at Etherscan.io on 2020-04-06
*/

// Verified using https://dapp.tools

// hevm: flattened sources of src/adapters/mainnet/mainnetUsdcAdapter.sol
pragma solidity >0.4.13 >=0.4.23 >=0.5.0 <0.6.0 >=0.5.6 <0.6.0 >=0.5.12 <0.6.0 >=0.5.15 <0.6.0;

////// lib/openzeppelin-contracts/src/contracts/token/ERC20/IERC20.sol
/* pragma solidity ^0.5.0; */

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

////// src/interfaces/ICToken.sol
/* pragma solidity ^0.5.15; */

interface ICToken {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);
    function getCash() external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function balanceOfUnderlying(address account) external returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
////// src/adapters/mainnet/mainnetUsdcAdapter.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.5.12; */

/* import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol"; */
/* import "../../interfaces/ICToken.sol"; */

contract MainnetUsdcAdapter {

    constructor () public { }

    IERC20 constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    ICToken constant cusdc = ICToken(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
    uint256 constant WAD = 10 ** 18;

    // transfers usdc in
    // wraps it in csudc
    function intakeRaw (uint256 amount) public returns (uint256) {

        usdc.transferFrom(msg.sender, address(this), amount);
        uint256 success = cusdc.mint(amount);
        if (success != 0) revert("CUsdc/mint-failed");
        return amount * 1000000000000;

    }

    // transfers usdc in
    // wraps it in csudc
    function intakeNumeraire (uint256 amount) public returns (uint256) {

        amount /= 1000000000000;
        usdc.transferFrom(msg.sender, address(this), amount);
        uint256 success = cusdc.mint(amount);
        if (success != 0) revert("CUsdc/mint-failed");
        return amount;

    }

    function outputRaw (address dst, uint256 amount) public returns (uint256) {

        uint256 success = cusdc.redeemUnderlying(amount);
        if (success != 0) revert("CUsdc/redeemUnderlying-failed");
        usdc.transfer(dst, amount);
        return amount * 1000000000000;

    }

    function outputNumeraire (address dst, uint256 amount) public returns (uint256) {

        amount /= 1000000000000;
        uint256 success = cusdc.redeemUnderlying(amount);
        if (success != 0) revert("CUsdc/redeemUnderlying-failed");
        usdc.transfer(dst, amount);
        return amount;

    }

    function viewRawAmount (uint256 amount) public view returns (uint256) {

        return amount / 1000000000000;

    }

    function viewNumeraireAmount (uint256 amount) public pure returns (uint256) {

        return amount * 1000000000000;

    }

    function viewNumeraireBalance (address addr) public view returns (uint256) {

        uint256 rate = cusdc.exchangeRateStored();
        uint256 balance = cusdc.balanceOf(addr);
        if (balance == 0) return 0;
        return wmul(balance, rate) * 1000000000000;

    }

    function getRawAmount (uint256 amount) public pure returns (uint256) {

        return amount / 1000000000000;

    }

    // is already numeraire amount
    function getNumeraireAmount (uint256 amount) public pure returns (uint256) {

        return amount * 1000000000000;

    }

    // returns numeraire balance
    function getNumeraireBalance () public returns (uint256) {

        uint256 bal = cusdc.balanceOfUnderlying(address(this));
        return bal * 1000000000000;

    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
}