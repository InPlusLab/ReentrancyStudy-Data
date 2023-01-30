/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

// SPDX-License-Identifier: UNLICENSED AND MIT

// File: contracts/IArtBlocksMinter.sol

pragma solidity ^0.6.0;

interface IArtBlocksMinter {
    function artblocksContract() external view returns (address);

    function artistSetBonusContractAddress(
        uint256 _projectId,
        address _bonusContractAddress
    ) external;

    function artistToggleBonus(uint256 _projectId) external;

    function checkYourAllowanceOfProjectERC20(uint256 _projectId)
        external
        view
        returns (uint256);

    function getYourBalanceOfProjectERC20(uint256 _projectId)
        external
        view
        returns (uint256);

    function projectIdToBonus(uint256) external view returns (bool);

    function projectIdToBonusContractAddress(uint256)
        external
        view
        returns (address);

    function purchase(uint256 _projectId)
        external
        payable
        returns (uint256 _tokenId);

    function purchaseTo(address _to, uint256 _projectId)
        external
        payable
        returns (uint256 _tokenId);
}

// File: contracts/IArtBlocksMain.sol

pragma solidity ^0.6.0;

interface IArtBlocksMain {
    function projectIdToCurrencyAddress(uint256)
        external
        view
        returns (address);

    function projectIdToCurrencySymbol(uint256)
        external
        view
        returns (string memory);

    function projectIdToPricePerTokenInWei(uint256)
        external
        view
        returns (uint256);
}

// File: @openzeppelin/contracts/utils/Address.sol


pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// File: contracts/BulkMinter.sol

pragma solidity ^0.6.0;




contract BulkMinter {
    IArtBlocksMinter _artBlocksMinter;
    IArtBlocksMain _artBlocksMain;

    constructor() public {
        _artBlocksMinter = IArtBlocksMinter(
            address(0x091dcd914fCEB1d47423e532955d1E62d1b2dAEf)
        );
        _artBlocksMain = IArtBlocksMain(
            address(0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270)
        );
    }

    function getPrice(uint256 projectId, uint256 numItems)
        public
        view
        returns (uint256)
    {
        require(
            _artBlocksMain.projectIdToCurrencyAddress(projectId) ==
                address(0x0000000000000000000000000000000000000000),
            "project not in ETH"
        );
        return
            _artBlocksMain.projectIdToPricePerTokenInWei(projectId) * numItems;
    }

    function bulkMint(
        uint256 projectId,
        uint256 numItems,
        uint256 tipAmount
    ) public payable {
        uint256 expectedAmount = getPrice(projectId, numItems) + tipAmount;
        require(msg.value == expectedAmount, "incorrect amount");
        uint256 pricePerMint =
            _artBlocksMain.projectIdToPricePerTokenInWei(projectId);
        for (uint256 x = 0; x < numItems; x++) {
            _artBlocksMinter.purchaseTo{value: pricePerMint}(
                msg.sender,
                projectId
            );
        }
    }

    function moveDonations() public {
        Address.sendValue(
            payable(address(0x8a333a18B924554D6e83EF9E9944DE6260f61D3B)),
            address(this).balance
        );
    }
}