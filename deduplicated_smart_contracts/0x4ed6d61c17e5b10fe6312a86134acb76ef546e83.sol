/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: GPL-3.0-or-later

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.6.2;

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

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: contracts/IUSM.sol

pragma solidity ^0.6.6;

interface IUSM {
    function mint(address to, uint minUsmOut) external payable returns (uint);
    function burn(address from, address payable to, uint usmToBurn, uint minEthOut) external returns (uint);
    function fund(address to, uint minFumOut) external payable returns (uint);
    function defund(address from, address payable to, uint fumToBurn, uint minEthOut) external returns (uint);
    function defundFromFUM(address from, address payable to, uint fumToBurn, uint minEthOut) external returns (uint);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

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

// File: contracts/external/IWETH9.sol

pragma solidity ^0.6.6;

interface IWETH9 is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

// File: contracts/Proxy.sol

pragma solidity ^0.6.6;

/**
 * @title USM Frontend Proxy
 * @author Alberto Cuesta Cañada, Jacob Eliosoff, Alex Roan
 */
contract Proxy {
    using Address for address payable;
    IUSM public immutable usm;
    IWETH9 public immutable weth;

    constructor(IUSM usm_, IWETH9 weth_)
        public
    {
        usm = usm_;
        weth = weth_;
    }

    /**
     * @notice The USM contract's `burn`/`defund` functions will send ETH back to this contract, and the WETH9 contract will send
     * ETH here on `weth.withdraw` using this function.  If anyone else tries to send ETH here, reject it.
     */
    receive() external payable {
        require(msg.sender == address(usm) || msg.sender == address(weth), "Don't transfer here");
    }

    /**
     * @notice Accepts WETH, converts it to ETH, and passes it to `usm.mint`.
     * @param to address to send the minted USM to.
     * @param ethIn WETH to deduct.
     * @param minUsmOut Minimum accepted USM for a successful mint.
     */
    function mint(address to, uint ethIn, uint minUsmOut)
        external returns (uint usmOut)
    {
        require(weth.transferFrom(msg.sender, address(this), ethIn), "WETH transfer fail");
        weth.withdraw(ethIn);
        usmOut = usm.mint{ value: ethIn }(to, minUsmOut);
    }

    /**
     * @notice Burn USM in exchange for ETH, which is then converted to and returned as WETH.
     * @param to address to send the WETH to.
     * @param usmToBurn Amount of USM to burn.
     * @param minEthOut Minimum accepted WETH for a successful burn.
     */
    function burn(address to, uint usmToBurn, uint minEthOut)
        external returns (uint ethOut)
    {
        ethOut = usm.burn(msg.sender, address(this), usmToBurn, minEthOut);
        weth.deposit{ value: ethOut }();
        require(weth.transferFrom(address(this), to, ethOut), "WETH transfer fail");
    }

    /**
     * @notice Accepts WETH, converts it to ETH, and funds the pool by passing the ETH to `usm.fund`.
     * @param to address to send the minted FUM to.
     * @param ethIn WETH to deduct.
     * @param minFumOut Minimum accepted FUM for a successful mint.
     */
    function fund(address to, uint ethIn, uint minFumOut)
        external returns (uint fumOut)
    {
        require(weth.transferFrom(msg.sender, address(this), ethIn), "WETH transfer fail");
        weth.withdraw(ethIn);
        fumOut = usm.fund{ value: ethIn }(to, minFumOut);
    }

    /**
     * @notice Defunds the pool by redeeming FUM in exchange for equivalent ETH from the pool, which is then converted to and
     * returned as WETH.
     * @param to address to send the WETH to.
     * @param fumToBurn Amount of FUM to burn.
     * @param minEthOut Minimum accepted ETH for a successful defund.
     */
    function defund(address to, uint fumToBurn, uint minEthOut)
        external returns (uint ethOut)
    {
        ethOut = usm.defund(msg.sender, address(this), fumToBurn, minEthOut);
        weth.deposit{ value: ethOut }();
        require(weth.transferFrom(address(this), to, ethOut), "WETH transfer fail");
    }
}