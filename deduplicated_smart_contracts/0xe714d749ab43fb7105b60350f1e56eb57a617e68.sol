/**

 *Submitted for verification at Etherscan.io on 2019-05-03

*/



// File: contracts/lib/ERC20SafeTransfer.sol



/*



  Copyright 2017 Loopring Project Ltd (Loopring Foundation).



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

pragma solidity ^0.5.7;





/// @title ERC20 safe transfer

/// @dev see https://github.com/sec-bit/badERC20Fix

/// @author Brecht Devos - <[email protected]>

library ERC20SafeTransfer {



    function safeTransfer(

        address token,

        address to,

        uint256 value)

    internal

    returns (bool success)

    {

        // A transfer is successful when 'call' is successful and depending on the token:

        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)

        // - A single boolean is returned: this boolean needs to be true (non-zero)



        // bytes4(keccak256("transfer(address,uint256)")) = 0xa9059cbb

        bytes memory callData = abi.encodeWithSelector(

            bytes4(0xa9059cbb),

            to,

            value

        );

        (success, ) = token.call(callData);

        return checkReturnValue(success);

    }



    function safeTransferFrom(

        address token,

        address from,

        address to,

        uint256 value)

    internal

    returns (bool success)

    {

        // A transferFrom is successful when 'call' is successful and depending on the token:

        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)

        // - A single boolean is returned: this boolean needs to be true (non-zero)



        // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd

        bytes memory callData = abi.encodeWithSelector(

            bytes4(0x23b872dd),

            from,

            to,

            value

        );

        (success, ) = token.call(callData);

        return checkReturnValue(success);

    }



    function checkReturnValue(

        bool success

    )

    internal

    pure

    returns (bool)

    {

        // A transfer/transferFrom is successful when 'call' is successful and depending on the token:

        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)

        // - A single boolean is returned: this boolean needs to be true (non-zero)

        if (success) {

            assembly {

                switch returndatasize()

                // Non-standard ERC20: nothing is returned so if 'call' was successful we assume the transfer succeeded

                case 0 {

                    success := 1

                }

                // Standard ERC20: a single boolean value is returned which needs to be true

                case 32 {

                    returndatacopy(0, 0, 32)

                    success := mload(0)

                }

                // None of the above: not successful

                default {

                    success := 0

                }

            }

        }

        return success;

    }



}



// File: contracts/lib/LibBytes.sol



pragma solidity ^0.5.7;



// Modified from 0x LibBytes

/*



  Copyright 2018 ZeroEx Intl.



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

library LibBytes {



    using LibBytes for bytes;



    /// @dev Gets the memory address for the contents of a byte array.

    /// @param input Byte array to lookup.

    /// @return memoryAddress Memory address of the contents of the byte array.

    function contentAddress(bytes memory input)

    internal

    pure

    returns (uint256 memoryAddress)

    {

        assembly {

            memoryAddress := add(input, 32)

        }

        return memoryAddress;

    }



    /// @dev Copies `length` bytes from memory location `source` to `dest`.

    /// @param dest memory address to copy bytes to.

    /// @param source memory address to copy bytes from.

    /// @param length number of bytes to copy.

    function memCopy(

        uint256 dest,

        uint256 source,

        uint256 length

    )

    internal

    pure

    {

        if (length < 32) {

            // Handle a partial word by reading destination and masking

            // off the bits we are interested in.

            // This correctly handles overlap, zero lengths and source == dest

            assembly {

                let mask := sub(exp(256, sub(32, length)), 1)

                let s := and(mload(source), not(mask))

                let d := and(mload(dest), mask)

                mstore(dest, or(s, d))

            }

        } else {

            // Skip the O(length) loop when source == dest.

            if (source == dest) {

                return;

            }



            // For large copies we copy whole words at a time. The final

            // word is aligned to the end of the range (instead of after the

            // previous) to handle partial words. So a copy will look like this:

            //

            //  ####

            //      ####

            //          ####

            //            ####

            //

            // We handle overlap in the source and destination range by

            // changing the copying direction. This prevents us from

            // overwriting parts of source that we still need to copy.

            //

            // This correctly handles source == dest

            //

            if (source > dest) {

                assembly {

                // We subtract 32 from `sEnd` and `dEnd` because it

                // is easier to compare with in the loop, and these

                // are also the addresses we need for copying the

                // last bytes.

                    length := sub(length, 32)

                    let sEnd := add(source, length)

                    let dEnd := add(dest, length)



                // Remember the last 32 bytes of source

                // This needs to be done here and not after the loop

                // because we may have overwritten the last bytes in

                // source already due to overlap.

                    let last := mload(sEnd)



                // Copy whole words front to back

                // Note: the first check is always true,

                // this could have been a do-while loop.

                // solhint-disable-next-line no-empty-blocks

                    for {} lt(source, sEnd) {} {

                        mstore(dest, mload(source))

                        source := add(source, 32)

                        dest := add(dest, 32)

                    }



                // Write the last 32 bytes

                    mstore(dEnd, last)

                }

            } else {

                assembly {

                // We subtract 32 from `sEnd` and `dEnd` because those

                // are the starting points when copying a word at the end.

                    length := sub(length, 32)

                    let sEnd := add(source, length)

                    let dEnd := add(dest, length)



                // Remember the first 32 bytes of source

                // This needs to be done here and not after the loop

                // because we may have overwritten the first bytes in

                // source already due to overlap.

                    let first := mload(source)



                // Copy whole words back to front

                // We use a signed comparisson here to allow dEnd to become

                // negative (happens when source and dest < 32). Valid

                // addresses in local memory will never be larger than

                // 2**255, so they can be safely re-interpreted as signed.

                // Note: the first check is always true,

                // this could have been a do-while loop.

                // solhint-disable-next-line no-empty-blocks

                    for {} slt(dest, dEnd) {} {

                        mstore(dEnd, mload(sEnd))

                        sEnd := sub(sEnd, 32)

                        dEnd := sub(dEnd, 32)

                    }



                // Write the first 32 bytes

                    mstore(dest, first)

                }

            }

        }

    }



    /// @dev Returns a slices from a byte array.

    /// @param b The byte array to take a slice from.

    /// @param from The starting index for the slice (inclusive).

    /// @param to The final index for the slice (exclusive).

    /// @return result The slice containing bytes at indices [from, to)

    function slice(

        bytes memory b,

        uint256 from,

        uint256 to

    )

    internal

    pure

    returns (bytes memory result)

    {

        if (from > to || to > b.length) {

            return "";

        }



        // Create a new bytes structure and copy contents

        result = new bytes(to - from);

        memCopy(

            result.contentAddress(),

            b.contentAddress() + from,

            result.length

        );

        return result;

    }



    /// @dev Reads an address from a position in a byte array.

    /// @param b Byte array containing an address.

    /// @param index Index in byte array of address.

    /// @return address from byte array.

    function readAddress(

        bytes memory b,

        uint256 index

    )

    internal

    pure

    returns (address result)

    {

        require(

            b.length >= index + 20,  // 20 is length of address

            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"

        );



        // Add offset to index:

        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)

        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)

        index += 20;



        // Read address from array memory

        assembly {

        // 1. Add index to address of bytes array

        // 2. Load 32-byte word from memory

        // 3. Apply 20-byte mask to obtain address

            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)

        }

        return result;

    }



    /// @dev Reads a bytes32 value from a position in a byte array.

    /// @param b Byte array containing a bytes32 value.

    /// @param index Index in byte array of bytes32 value.

    /// @return bytes32 value from byte array.

    function readBytes32(

        bytes memory b,

        uint256 index

    )

    internal

    pure

    returns (bytes32 result)

    {

        require(

            b.length >= index + 32,

            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"

        );



        // Arrays are prefixed by a 256 bit length parameter

        index += 32;



        // Read the bytes32 from array memory

        assembly {

            result := mload(add(b, index))

        }

        return result;

    }



    /// @dev Reads a uint256 value from a position in a byte array.

    /// @param b Byte array containing a uint256 value.

    /// @param index Index in byte array of uint256 value.

    /// @return uint256 value from byte array.

    function readUint256(

        bytes memory b,

        uint256 index

    )

    internal

    pure

    returns (uint256 result)

    {

        result = uint256(readBytes32(b, index));

        return result;

    }



    /// @dev Reads an unpadded bytes4 value from a position in a byte array.

    /// @param b Byte array containing a bytes4 value.

    /// @param index Index in byte array of bytes4 value.

    /// @return bytes4 value from byte array.

    function readBytes4(

        bytes memory b,

        uint256 index

    )

    internal

    pure

    returns (bytes4 result)

    {

        require(

            b.length >= index + 4,

            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"

        );



        // Arrays are prefixed by a 32 byte length field

        index += 32;



        // Read the bytes4 from array memory

        assembly {

            result := mload(add(b, index))

        // Solidity does not require us to clean the trailing bytes.

        // We do it anyway

            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)

        }

        return result;

    }

}



// File: contracts/lib/LibMath.sol



pragma solidity ^0.5.7;



contract LibMath {

    // Copied from openzeppelin Math

    /**

    * @dev Returns the largest of two numbers.

    */

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;

    }



    /**

    * @dev Returns the smallest of two numbers.

    */

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    /**

    * @dev Calculates the average of two numbers. Since these are integers,

    * averages of an even and odd number cannot be represented, and will be

    * rounded down.

    */

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        // (a + b) / 2 can overflow, so we distribute

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);

    }



    // Modified from openzeppelin SafeMath

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }



    // Copied from 0x LibMath

    /*

      Copyright 2018 ZeroEx Intl.

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

    /// @dev Calculates partial value given a numerator and denominator rounded down.

    ///      Reverts if rounding error is >= 0.1%

    /// @param numerator Numerator.

    /// @param denominator Denominator.

    /// @param target Value to calculate partial of.

    /// @return Partial value of target rounded down.

    function safeGetPartialAmountFloor(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

    internal

    pure

    returns (uint256 partialAmount)

    {

        require(

            denominator > 0,

            "DIVISION_BY_ZERO"

        );



        require(

            !isRoundingErrorFloor(

            numerator,

            denominator,

            target

        ),

            "ROUNDING_ERROR"

        );



        partialAmount = div(

            mul(numerator, target),

            denominator

        );

        return partialAmount;

    }



    /// @dev Calculates partial value given a numerator and denominator rounded down.

    ///      Reverts if rounding error is >= 0.1%

    /// @param numerator Numerator.

    /// @param denominator Denominator.

    /// @param target Value to calculate partial of.

    /// @return Partial value of target rounded up.

    function safeGetPartialAmountCeil(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

    internal

    pure

    returns (uint256 partialAmount)

    {

        require(

            denominator > 0,

            "DIVISION_BY_ZERO"

        );



        require(

            !isRoundingErrorCeil(

            numerator,

            denominator,

            target

        ),

            "ROUNDING_ERROR"

        );



        partialAmount = div(

            add(

                mul(numerator, target),

                sub(denominator, 1)

            ),

            denominator

        );

        return partialAmount;

    }



    /// @dev Calculates partial value given a numerator and denominator rounded down.

    /// @param numerator Numerator.

    /// @param denominator Denominator.

    /// @param target Value to calculate partial of.

    /// @return Partial value of target rounded down.

    function getPartialAmountFloor(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

    internal

    pure

    returns (uint256 partialAmount)

    {

        require(

            denominator > 0,

            "DIVISION_BY_ZERO"

        );



        partialAmount = div(

            mul(numerator, target),

            denominator

        );

        return partialAmount;

    }



    /// @dev Calculates partial value given a numerator and denominator rounded down.

    /// @param numerator Numerator.

    /// @param denominator Denominator.

    /// @param target Value to calculate partial of.

    /// @return Partial value of target rounded up.

    function getPartialAmountCeil(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

    internal

    pure

    returns (uint256 partialAmount)

    {

        require(

            denominator > 0,

            "DIVISION_BY_ZERO"

        );



        partialAmount = div(

            add(

                mul(numerator, target),

                sub(denominator, 1)

            ),

            denominator

        );

        return partialAmount;

    }



    /// @dev Checks if rounding error >= 0.1% when rounding down.

    /// @param numerator Numerator.

    /// @param denominator Denominator.

    /// @param target Value to multiply with numerator/denominator.

    /// @return Rounding error is present.

    function isRoundingErrorFloor(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

    internal

    pure

    returns (bool isError)

    {

        require(

            denominator > 0,

            "DIVISION_BY_ZERO"

        );



        // The absolute rounding error is the difference between the rounded

        // value and the ideal value. The relative rounding error is the

        // absolute rounding error divided by the absolute value of the

        // ideal value. This is undefined when the ideal value is zero.

        //

        // The ideal value is `numerator * target / denominator`.

        // Let's call `numerator * target % denominator` the remainder.

        // The absolute error is `remainder / denominator`.

        //

        // When the ideal value is zero, we require the absolute error to

        // be zero. Fortunately, this is always the case. The ideal value is

        // zero iff `numerator == 0` and/or `target == 0`. In this case the

        // remainder and absolute error are also zero.

        if (target == 0 || numerator == 0) {

            return false;

        }



        // Otherwise, we want the relative rounding error to be strictly

        // less than 0.1%.

        // The relative error is `remainder / (numerator * target)`.

        // We want the relative error less than 1 / 1000:

        //        remainder / (numerator * denominator)  <  1 / 1000

        // or equivalently:

        //        1000 * remainder  <  numerator * target

        // so we have a rounding error iff:

        //        1000 * remainder  >=  numerator * target

        uint256 remainder = mulmod(

            target,

            numerator,

            denominator

        );

        isError = mul(1000, remainder) >= mul(numerator, target);

        return isError;

    }



    /// @dev Checks if rounding error >= 0.1% when rounding up.

    /// @param numerator Numerator.

    /// @param denominator Denominator.

    /// @param target Value to multiply with numerator/denominator.

    /// @return Rounding error is present.

    function isRoundingErrorCeil(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

    internal

    pure

    returns (bool isError)

    {

        require(

            denominator > 0,

            "DIVISION_BY_ZERO"

        );



        // See the comments in `isRoundingError`.

        if (target == 0 || numerator == 0) {

            // When either is zero, the ideal value and rounded value are zero

            // and there is no rounding error. (Although the relative error

            // is undefined.)

            return false;

        }

        // Compute remainder as before

        uint256 remainder = mulmod(

            target,

            numerator,

            denominator

        );

        remainder = sub(denominator, remainder) % denominator;

        isError = mul(1000, remainder) >= mul(numerator, target);

        return isError;

    }

}



// File: contracts/bank/IBank.sol



pragma solidity ^0.5.7;



/// Bank Interface.

interface IBank {



    /// Modifies authorization of an address. Only contract owner can call this function.

    /// @param target Address to authorize / deauthorize.

    /// @param allowed Whether the target address is authorized.

    function authorize(address target, bool allowed) external;



    /// Modifies user approvals of an address.

    /// @param target Address to approve / unapprove.

    /// @param allowed Whether the target address is user approved.

    function userApprove(address target, bool allowed) external;



    /// Batch modifies user approvals.

    /// @param targetList Array of addresses to approve / unapprove.

    /// @param allowedList Array of booleans indicating whether the target address is user approved.

    function batchUserApprove(address[] calldata targetList, bool[] calldata allowedList) external;



    /// Gets all authorized addresses.

    /// @return Array of authorized addresses.

    function getAuthorizedAddresses() external view returns (address[] memory);



    /// Gets all user approved addresses.

    /// @return Array of user approved addresses.

    function getUserApprovedAddresses() external view returns (address[] memory);



    /// Checks whether the user has enough deposit.

    /// @param token Token address.

    /// @param user User address.

    /// @param amount Token amount.

    /// @param data Additional token data (e.g. tokenId for ERC721).

    /// @return Whether the user has enough deposit.

    function hasDeposit(address token, address user, uint256 amount, bytes calldata data) external view returns (bool);



    /// Checks token balance available to use (including user deposit amount + user approved allowance amount).

    /// @param token Token address.

    /// @param user User address.

    /// @param data Additional token data (e.g. tokenId for ERC721).

    /// @return Token amount available.

    function getAvailable(address token, address user, bytes calldata data) external view returns (uint256);



    /// Gets balance of user's deposit.

    /// @param token Token address.

    /// @param user User address.

    /// @return Token deposit amount.

    function balanceOf(address token, address user) external view returns (uint256);



    /// Deposits token from user wallet to bank.

    /// @param token Token address.

    /// @param user User address (allows third-party give tokens to any users).

    /// @param amount Token amount.

    /// @param data Additional token data (e.g. tokenId for ERC721).

    function deposit(address token, address user, uint256 amount, bytes calldata data) external payable;



    /// Withdraws token from bank to user wallet.

    /// @param token Token address.

    /// @param amount Token amount.

    /// @param data Additional token data (e.g. tokenId for ERC721).

    function withdraw(address token, uint256 amount, bytes calldata data) external;



    /// Transfers token from one address to another address.

    /// Only caller who are double-approved by both bank owner and token owner can invoke this function.

    /// @param token Token address.

    /// @param from The current token owner address.

    /// @param to The new token owner address.

    /// @param amount Token amount.

    /// @param data Additional token data (e.g. tokenId for ERC721).

    /// @param fromDeposit True if use fund from bank deposit. False if use fund from user wallet.

    /// @param toDeposit True if deposit fund to bank deposit. False if send fund to user wallet.

    function transferFrom(

        address token,

        address from,

        address to,

        uint256 amount,

        bytes calldata data,

        bool fromDeposit,

        bool toDeposit

    )

    external;

}



// File: contracts/router/IExchangeHandler.sol



pragma solidity ^0.5.7;

pragma experimental ABIEncoderV2;



/// Interface of exchange handler.

interface IExchangeHandler {



    /// Gets maximum available amount can be spent on order (fee not included).

    /// @param data General order data.

    /// @return availableToFill Amount can be spent on order.

    /// @return feePercentage Fee percentage of order.

    function getAvailableToFill(

        bytes calldata data

    )

    external

    view

    returns (uint256 availableToFill, uint256 feePercentage);



    /// Fills an order on the target exchange.

    /// NOTE: The required funds must be transferred to this contract in the same transaction of calling this function.

    /// @param data General order data.

    /// @param takerAmountToFill Taker token amount to spend on order (fee not included).

    /// @return makerAmountReceived Amount received from trade.

    function fillOrder(

        bytes calldata data,

        uint256 takerAmountToFill

    )

    external

    payable

    returns (uint256 makerAmountReceived);

}



// File: contracts/Common.sol



pragma solidity ^0.5.7;



contract Common {

    struct Order {

        address maker;

        address taker;

        address makerToken;

        address takerToken;

        address makerTokenBank;

        address takerTokenBank;

        address reseller;

        address verifier;

        uint256 makerAmount;

        uint256 takerAmount;

        uint256 expires;

        uint256 nonce;

        uint256 minimumTakerAmount;

        bytes makerData;

        bytes takerData;

        bytes signature;

    }



    struct OrderInfo {

        uint8 orderStatus;

        bytes32 orderHash;

        uint256 filledTakerAmount;

    }



    struct FillResults {

        uint256 makerFilledAmount;

        uint256 makerFeeExchange;

        uint256 makerFeeReseller;

        uint256 takerFilledAmount;

        uint256 takerFeeExchange;

        uint256 takerFeeReseller;

    }



    struct MatchedFillResults {

        FillResults left;

        FillResults right;

        uint256 spreadAmount;

    }

}



// File: contracts/router/RouterCommon.sol



pragma solidity ^0.5.7;



contract RouterCommon {

    struct GeneralOrder {

        address handler;

        address makerToken;

        address takerToken;

        uint256 makerAmount;

        uint256 takerAmount;

        bytes data;

    }



    struct FillResults {

        uint256 makerAmountReceived;

        uint256 takerAmountSpentOnOrder;

        uint256 takerAmountSpentOnFee;

    }

}



// File: contracts/router/EverbloomHandler.sol



pragma solidity ^0.5.7;



/// Interface of core Everbloom exchange contract.

interface IEB {

    function fees(

        address reseller,

        uint256 feeType

    )

    external

    view

    returns (uint256);



    function fillOrder(

        Common.Order calldata order,

        uint256 takerAmountToFill,

        bool allowInsufficient

    )

    external

    returns (Common.FillResults memory results);



    function getOrderInfo(

        Common.Order calldata order

    )

    external

    view

    returns (Common.OrderInfo memory orderInfo);

}



/// Interface of ERC20 approve function.

interface IERC20 {

    function approve(

        address spender,

        uint256 value

    ) external;

}



/// Everbloom exchange implementation of exchange handler. ERC721 orders, KYCed orders are not currently supported.

contract EverbloomHandler is IExchangeHandler, LibMath {



    using LibBytes for bytes;



    IEB public EXCHANGE;

    address public ROUTER;



    constructor(

        address exchange,

        address router

    )

    public

    {

        EXCHANGE = IEB(exchange);

        ROUTER = router;

    }



    /// Fallback function to receive ETH.

    function() external payable {}



    /// Gets maximum available amount can be spent on order (fee not included).

    /// @param data General order data.

    /// @return availableToFill Amount can be spent on order.

    /// @return feePercentage Fee percentage of order.

    function getAvailableToFill(

        bytes calldata data

    )

    external

    view

    returns (uint256 availableToFill, uint256 feePercentage)

    {

        Common.Order memory ebOrder = getOrder(data);

        Common.OrderInfo memory orderInfo = EXCHANGE.getOrderInfo(ebOrder);

        if ((ebOrder.taker != address(0) && ebOrder.taker != address(this)) ||

            ebOrder.minimumTakerAmount > 0 ||

            ebOrder.minimumTakerAmount > 0 ||

            orderInfo.orderStatus != 4

        ) {

            availableToFill = 0;

        } else {

            availableToFill = sub(ebOrder.takerAmount, orderInfo.filledTakerAmount);

        }

        feePercentage = EXCHANGE.fees(ebOrder.reseller, 2);

    }



    /// Fills an order on the target exchange.

    /// NOTE: The required funds must be transferred to this contract in the same transaction of calling this function.

    /// @param data General order data.

    /// @param takerAmountToFill Taker token amount to spend on order (fee not included).

    /// @return makerAmountReceived Amount received from trade.

    function fillOrder(

        bytes calldata data,

        uint256 takerAmountToFill

    )

    external

    payable

    returns (uint256 makerAmountReceived)

    {

        require(msg.sender == ROUTER, "SENDER_NOT_ROUTER");

        Common.Order memory ebOrder = getOrder(data);

        uint256 depositAmount = add(takerAmountToFill, mul(takerAmountToFill, EXCHANGE.fees(ebOrder.reseller, 2)) / (1 ether));

        // Makes deposit on exchange using taker token in this contract.

        if (ebOrder.takerToken == address(0)) {

            IBank(ebOrder.takerTokenBank).deposit.value(depositAmount)(address(0), address(this), depositAmount, "");

        } else {

            IERC20(ebOrder.takerToken).approve(ebOrder.takerTokenBank, depositAmount);

            IBank(ebOrder.takerTokenBank).deposit(ebOrder.takerToken, address(this), depositAmount, "");

        }

        // Approves exchange to access bank.

        IBank(ebOrder.takerTokenBank).userApprove(address(EXCHANGE), true);



        // Trades on exchange.

        Common.FillResults memory results = EXCHANGE.fillOrder(

            ebOrder,

            takerAmountToFill,

            false

        );

        // Withdraws maker tokens to this contract, then sends back to router.

        if (results.makerFilledAmount > 0) {

            IBank(ebOrder.makerTokenBank).withdraw(ebOrder.makerToken, results.makerFilledAmount, "");

            if (ebOrder.makerToken == address(0)) {

                require(msg.sender.send(results.makerFilledAmount), "FAILED_SEND_ETH_TO_ROUTER");

            } else {

                require(ERC20SafeTransfer.safeTransfer(ebOrder.makerToken, msg.sender, results.makerFilledAmount), "FAILED_SEND_ERC20_TO_ROUTER");

            }

        }

        makerAmountReceived = results.makerFilledAmount;

    }



    /// Assembles order object in EtherDelta format.

    /// @param data General order data.

    /// @return order Order object in EtherDelta format.

    function getOrder(

        bytes memory data

    )

    internal

    pure

    returns (Common.Order memory ebOrder)

    {

        uint256 makerDataOffset = data.readUint256(416);

        uint256 takerDataOffset = data.readUint256(448);

        uint256 signatureOffset = data.readUint256(480);

        ebOrder.maker = data.readAddress(12);

        ebOrder.taker = data.readAddress(44);

        ebOrder.makerToken = data.readAddress(76);

        ebOrder.takerToken = data.readAddress(108);

        ebOrder.makerTokenBank = data.readAddress(140);

        ebOrder.takerTokenBank = data.readAddress(172);

        ebOrder.reseller = data.readAddress(204);

        ebOrder.verifier = data.readAddress(236);

        ebOrder.makerAmount = data.readUint256(256);

        ebOrder.takerAmount = data.readUint256(288);

        ebOrder.expires = data.readUint256(320);

        ebOrder.nonce = data.readUint256(352);

        ebOrder.minimumTakerAmount = data.readUint256(384);

        ebOrder.makerData = data.slice(makerDataOffset + 32, makerDataOffset + 32 + data.readUint256(makerDataOffset));

        ebOrder.takerData = data.slice(takerDataOffset + 32, takerDataOffset + 32 + data.readUint256(takerDataOffset));

        ebOrder.signature = data.slice(signatureOffset + 32, signatureOffset + 32 + data.readUint256(signatureOffset));

    }

}