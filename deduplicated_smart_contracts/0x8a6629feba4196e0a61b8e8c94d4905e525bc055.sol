/**

 *Submitted for verification at Etherscan.io on 2019-05-07

*/



/*



    Copyright 2019 dYdX Trading Inc.



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



pragma solidity 0.5.7;

pragma experimental ABIEncoderV2;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

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

}



// File: contracts/protocol/lib/Require.sol



/**

 * @title Require

 * @author dYdX

 *

 * Stringifies parameters to pretty-print revert messages. Costs more gas than regular require()

 */

library Require {



    // ============ Constants ============



    uint256 constant ASCII_ZERO = 48; // '0'

    uint256 constant ASCII_RELATIVE_ZERO = 87; // 'a' - 10

    uint256 constant ASCII_LOWER_EX = 120; // 'x'

    bytes2 constant COLON = 0x3a20; // ': '

    bytes2 constant COMMA = 0x2c20; // ', '

    bytes2 constant LPAREN = 0x203c; // ' <'

    byte constant RPAREN = 0x3e; // '>'

    uint256 constant FOUR_BIT_MASK = 0xf;



    // ============ Library Functions ============



    function that(

        bool must,

        bytes32 file,

        bytes32 reason

    )

        internal

        pure

    {

        if (!must) {

            revert(

                string(

                    abi.encodePacked(

                        stringify(file),

                        COLON,

                        stringify(reason)

                    )

                )

            );

        }

    }



    function that(

        bool must,

        bytes32 file,

        bytes32 reason,

        uint256 payloadA

    )

        internal

        pure

    {

        if (!must) {

            revert(

                string(

                    abi.encodePacked(

                        stringify(file),

                        COLON,

                        stringify(reason),

                        LPAREN,

                        stringify(payloadA),

                        RPAREN

                    )

                )

            );

        }

    }



    function that(

        bool must,

        bytes32 file,

        bytes32 reason,

        uint256 payloadA,

        uint256 payloadB

    )

        internal

        pure

    {

        if (!must) {

            revert(

                string(

                    abi.encodePacked(

                        stringify(file),

                        COLON,

                        stringify(reason),

                        LPAREN,

                        stringify(payloadA),

                        COMMA,

                        stringify(payloadB),

                        RPAREN

                    )

                )

            );

        }

    }



    function that(

        bool must,

        bytes32 file,

        bytes32 reason,

        address payloadA

    )

        internal

        pure

    {

        if (!must) {

            revert(

                string(

                    abi.encodePacked(

                        stringify(file),

                        COLON,

                        stringify(reason),

                        LPAREN,

                        stringify(payloadA),

                        RPAREN

                    )

                )

            );

        }

    }



    function that(

        bool must,

        bytes32 file,

        bytes32 reason,

        address payloadA,

        uint256 payloadB

    )

        internal

        pure

    {

        if (!must) {

            revert(

                string(

                    abi.encodePacked(

                        stringify(file),

                        COLON,

                        stringify(reason),

                        LPAREN,

                        stringify(payloadA),

                        COMMA,

                        stringify(payloadB),

                        RPAREN

                    )

                )

            );

        }

    }



    function that(

        bool must,

        bytes32 file,

        bytes32 reason,

        address payloadA,

        uint256 payloadB,

        uint256 payloadC

    )

        internal

        pure

    {

        if (!must) {

            revert(

                string(

                    abi.encodePacked(

                        stringify(file),

                        COLON,

                        stringify(reason),

                        LPAREN,

                        stringify(payloadA),

                        COMMA,

                        stringify(payloadB),

                        COMMA,

                        stringify(payloadC),

                        RPAREN

                    )

                )

            );

        }

    }



    // ============ Private Functions ============



    function stringify(

        bytes32 input

    )

        private

        pure

        returns (bytes memory)

    {

        // put the input bytes into the result

        bytes memory result = abi.encodePacked(input);



        // determine the length of the input by finding the location of the last non-zero byte

        for (uint256 i = 32; i > 0; ) {

            // reverse-for-loops with unsigned integer

            /* solium-disable-next-line security/no-modify-for-iter-var */

            i--;



            // find the last non-zero byte in order to determine the length

            if (result[i] != 0) {

                uint256 length = i + 1;



                /* solium-disable-next-line security/no-inline-assembly */

                assembly {

                    mstore(result, length) // r.length = length;

                }



                return result;

            }

        }



        // all bytes are zero

        return new bytes(0);

    }



    function stringify(

        uint256 input

    )

        private

        pure

        returns (bytes memory)

    {

        if (input == 0) {

            return "0";

        }



        // get the final string length

        uint256 j = input;

        uint256 length;

        while (j != 0) {

            length++;

            j /= 10;

        }



        // allocate the string

        bytes memory bstr = new bytes(length);



        // populate the string starting with the least-significant character

        j = input;

        for (uint256 i = length; i > 0; ) {

            // reverse-for-loops with unsigned integer

            /* solium-disable-next-line security/no-modify-for-iter-var */

            i--;



            // take last decimal digit

            bstr[i] = byte(uint8(ASCII_ZERO + (j % 10)));



            // remove the last decimal digit

            j /= 10;

        }



        return bstr;

    }



    function stringify(

        address input

    )

        private

        pure

        returns (bytes memory)

    {

        uint256 z = uint256(input);



        // addresses are "0x" followed by 20 bytes of data which take up 2 characters each

        bytes memory result = new bytes(42);



        // populate the result with "0x"

        result[0] = byte(uint8(ASCII_ZERO));

        result[1] = byte(uint8(ASCII_LOWER_EX));



        // for each byte (starting from the lowest byte), populate the result with two characters

        for (uint256 i = 0; i < 20; i++) {

            // each byte takes two characters

            uint256 shift = i * 2;



            // populate the least-significant character

            result[41 - shift] = char(z & FOUR_BIT_MASK);

            z = z >> 4;



            // populate the most-significant character

            result[40 - shift] = char(z & FOUR_BIT_MASK);

            z = z >> 4;

        }



        return result;

    }



    function char(

        uint256 input

    )

        private

        pure

        returns (byte)

    {

        // return ASCII digit (0-9)

        if (input < 10) {

            return byte(uint8(input + ASCII_ZERO));

        }



        // return ASCII letter (a-f)

        return byte(uint8(input + ASCII_RELATIVE_ZERO));

    }

}



// File: contracts/protocol/lib/Math.sol



/**

 * @title Math

 * @author dYdX

 *

 * Library for non-standard Math functions

 */

library Math {

    using SafeMath for uint256;



    // ============ Constants ============



    bytes32 constant FILE = "Math";



    // ============ Library Functions ============



    /*

     * Return target * (numerator / denominator).

     */

    function getPartial(

        uint256 target,

        uint256 numerator,

        uint256 denominator

    )

        internal

        pure

        returns (uint256)

    {

        return target.mul(numerator).div(denominator);

    }



    /*

     * Return target * (numerator / denominator), but rounded up.

     */

    function getPartialRoundUp(

        uint256 target,

        uint256 numerator,

        uint256 denominator

    )

        internal

        pure

        returns (uint256)

    {

        if (target == 0 || numerator == 0) {

            // SafeMath will check for zero denominator

            return SafeMath.div(0, denominator);

        }

        return target.mul(numerator).sub(1).div(denominator).add(1);

    }



    function to128(

        uint256 number

    )

        internal

        pure

        returns (uint128)

    {

        uint128 result = uint128(number);

        Require.that(

            result == number,

            FILE,

            "Unsafe cast to uint128"

        );

        return result;

    }



    function to96(

        uint256 number

    )

        internal

        pure

        returns (uint96)

    {

        uint96 result = uint96(number);

        Require.that(

            result == number,

            FILE,

            "Unsafe cast to uint96"

        );

        return result;

    }



    function to32(

        uint256 number

    )

        internal

        pure

        returns (uint32)

    {

        uint32 result = uint32(number);

        Require.that(

            result == number,

            FILE,

            "Unsafe cast to uint32"

        );

        return result;

    }



    function min(

        uint256 a,

        uint256 b

    )

        internal

        pure

        returns (uint256)

    {

        return a < b ? a : b;

    }



    function max(

        uint256 a,

        uint256 b

    )

        internal

        pure

        returns (uint256)

    {

        return a > b ? a : b;

    }

}



// File: contracts/protocol/lib/Decimal.sol



/**

 * @title Decimal

 * @author dYdX

 *

 * Library that defines a fixed-point number with 18 decimal places.

 */

library Decimal {

    using SafeMath for uint256;



    // ============ Constants ============



    uint256 constant BASE = 10**18;



    // ============ Structs ============



    struct D256 {

        uint256 value;

    }



    // ============ Functions ============



    function one()

        internal

        pure

        returns (D256 memory)

    {

        return D256({ value: BASE });

    }



    function onePlus(

        D256 memory d

    )

        internal

        pure

        returns (D256 memory)

    {

        return D256({ value: d.value.add(BASE) });

    }



    function mul(

        uint256 target,

        D256 memory d

    )

        internal

        pure

        returns (uint256)

    {

        return Math.getPartial(target, d.value, BASE);

    }



    function div(

        uint256 target,

        D256 memory d

    )

        internal

        pure

        returns (uint256)

    {

        return Math.getPartial(target, BASE, d.value);

    }

}



// File: contracts/protocol/lib/Time.sol



/**

 * @title Time

 * @author dYdX

 *

 * Library for dealing with time, assuming timestamps fit within 32 bits (valid until year 2106)

 */

library Time {



    // ============ Library Functions ============



    function currentTime()

        internal

        view

        returns (uint32)

    {

        return Math.to32(block.timestamp);

    }

}



// File: contracts/protocol/lib/Types.sol



/**

 * @title Types

 * @author dYdX

 *

 * Library for interacting with the basic structs used in Solo

 */

library Types {

    using Math for uint256;



    // ============ AssetAmount ============



    enum AssetDenomination {

        Wei, // the amount is denominated in wei

        Par  // the amount is denominated in par

    }



    enum AssetReference {

        Delta, // the amount is given as a delta from the current value

        Target // the amount is given as an exact number to end up at

    }



    struct AssetAmount {

        bool sign; // true if positive

        AssetDenomination denomination;

        AssetReference ref;

        uint256 value;

    }



    // ============ Par (Principal Amount) ============



    // Total borrow and supply values for a market

    struct TotalPar {

        uint128 borrow;

        uint128 supply;

    }



    // Individual principal amount for an account

    struct Par {

        bool sign; // true if positive

        uint128 value;

    }



    function zeroPar()

        internal

        pure

        returns (Par memory)

    {

        return Par({

            sign: false,

            value: 0

        });

    }



    function sub(

        Par memory a,

        Par memory b

    )

        internal

        pure

        returns (Par memory)

    {

        return add(a, negative(b));

    }



    function add(

        Par memory a,

        Par memory b

    )

        internal

        pure

        returns (Par memory)

    {

        Par memory result;

        if (a.sign == b.sign) {

            result.sign = a.sign;

            result.value = SafeMath.add(a.value, b.value).to128();

        } else {

            if (a.value >= b.value) {

                result.sign = a.sign;

                result.value = SafeMath.sub(a.value, b.value).to128();

            } else {

                result.sign = b.sign;

                result.value = SafeMath.sub(b.value, a.value).to128();

            }

        }

        return result;

    }



    function equals(

        Par memory a,

        Par memory b

    )

        internal

        pure

        returns (bool)

    {

        if (a.value == b.value) {

            if (a.value == 0) {

                return true;

            }

            return a.sign == b.sign;

        }

        return false;

    }



    function negative(

        Par memory a

    )

        internal

        pure

        returns (Par memory)

    {

        return Par({

            sign: !a.sign,

            value: a.value

        });

    }



    function isNegative(

        Par memory a

    )

        internal

        pure

        returns (bool)

    {

        return !a.sign && a.value > 0;

    }



    function isPositive(

        Par memory a

    )

        internal

        pure

        returns (bool)

    {

        return a.sign && a.value > 0;

    }



    function isZero(

        Par memory a

    )

        internal

        pure

        returns (bool)

    {

        return a.value == 0;

    }



    // ============ Wei (Token Amount) ============



    // Individual token amount for an account

    struct Wei {

        bool sign; // true if positive

        uint256 value;

    }



    function zeroWei()

        internal

        pure

        returns (Wei memory)

    {

        return Wei({

            sign: false,

            value: 0

        });

    }



    function sub(

        Wei memory a,

        Wei memory b

    )

        internal

        pure

        returns (Wei memory)

    {

        return add(a, negative(b));

    }



    function add(

        Wei memory a,

        Wei memory b

    )

        internal

        pure

        returns (Wei memory)

    {

        Wei memory result;

        if (a.sign == b.sign) {

            result.sign = a.sign;

            result.value = SafeMath.add(a.value, b.value);

        } else {

            if (a.value >= b.value) {

                result.sign = a.sign;

                result.value = SafeMath.sub(a.value, b.value);

            } else {

                result.sign = b.sign;

                result.value = SafeMath.sub(b.value, a.value);

            }

        }

        return result;

    }



    function equals(

        Wei memory a,

        Wei memory b

    )

        internal

        pure

        returns (bool)

    {

        if (a.value == b.value) {

            if (a.value == 0) {

                return true;

            }

            return a.sign == b.sign;

        }

        return false;

    }



    function negative(

        Wei memory a

    )

        internal

        pure

        returns (Wei memory)

    {

        return Wei({

            sign: !a.sign,

            value: a.value

        });

    }



    function isNegative(

        Wei memory a

    )

        internal

        pure

        returns (bool)

    {

        return !a.sign && a.value > 0;

    }



    function isPositive(

        Wei memory a

    )

        internal

        pure

        returns (bool)

    {

        return a.sign && a.value > 0;

    }



    function isZero(

        Wei memory a

    )

        internal

        pure

        returns (bool)

    {

        return a.value == 0;

    }

}



// File: contracts/protocol/lib/Interest.sol



/**

 * @title Interest

 * @author dYdX

 *

 * Library for managing the interest rate and interest indexes of Solo

 */

library Interest {

    using Math for uint256;

    using SafeMath for uint256;



    // ============ Constants ============



    bytes32 constant FILE = "Interest";

    uint64 constant BASE = 10**18;



    // ============ Structs ============



    struct Rate {

        uint256 value;

    }



    struct Index {

        uint96 borrow;

        uint96 supply;

        uint32 lastUpdate;

    }



    // ============ Library Functions ============



    /**

     * Get a new market Index based on the old index and market interest rate.

     * Calculate interest for borrowers by using the formula rate * time. Approximates

     * continuously-compounded interest when called frequently, but is much more

     * gas-efficient to calculate. For suppliers, the interest rate is adjusted by the earningsRate,

     * then prorated the across all suppliers.

     *

     * @param  index         The old index for a market

     * @param  rate          The current interest rate of the market

     * @param  totalPar      The total supply and borrow par values of the market

     * @param  earningsRate  The portion of the interest that is forwarded to the suppliers

     * @return               The updated index for a market

     */

    function calculateNewIndex(

        Index memory index,

        Rate memory rate,

        Types.TotalPar memory totalPar,

        Decimal.D256 memory earningsRate

    )

        internal

        view

        returns (Index memory)

    {

        (

            Types.Wei memory supplyWei,

            Types.Wei memory borrowWei

        ) = totalParToWei(totalPar, index);



        // get interest increase for borrowers

        uint32 currentTime = Time.currentTime();

        uint256 borrowInterest = rate.value.mul(uint256(currentTime).sub(index.lastUpdate));



        // get interest increase for suppliers

        uint256 supplyInterest;

        if (Types.isZero(supplyWei)) {

            supplyInterest = 0;

        } else {

            supplyInterest = Decimal.mul(borrowInterest, earningsRate);

            if (borrowWei.value < supplyWei.value) {

                supplyInterest = Math.getPartial(supplyInterest, borrowWei.value, supplyWei.value);

            }

        }

        assert(supplyInterest <= borrowInterest);



        return Index({

            borrow: Math.getPartial(index.borrow, borrowInterest, BASE).add(index.borrow).to96(),

            supply: Math.getPartial(index.supply, supplyInterest, BASE).add(index.supply).to96(),

            lastUpdate: currentTime

        });

    }



    function newIndex()

        internal

        view

        returns (Index memory)

    {

        return Index({

            borrow: BASE,

            supply: BASE,

            lastUpdate: Time.currentTime()

        });

    }



    /*

     * Convert a principal amount to a token amount given an index.

     */

    function parToWei(

        Types.Par memory input,

        Index memory index

    )

        internal

        pure

        returns (Types.Wei memory)

    {

        uint256 inputValue = uint256(input.value);

        if (input.sign) {

            return Types.Wei({

                sign: true,

                value: inputValue.getPartial(index.supply, BASE)

            });

        } else {

            return Types.Wei({

                sign: false,

                value: inputValue.getPartialRoundUp(index.borrow, BASE)

            });

        }

    }



    /*

     * Convert a token amount to a principal amount given an index.

     */

    function weiToPar(

        Types.Wei memory input,

        Index memory index

    )

        internal

        pure

        returns (Types.Par memory)

    {

        if (input.sign) {

            return Types.Par({

                sign: true,

                value: input.value.getPartial(BASE, index.supply).to128()

            });

        } else {

            return Types.Par({

                sign: false,

                value: input.value.getPartialRoundUp(BASE, index.borrow).to128()

            });

        }

    }



    /*

     * Convert the total supply and borrow principal amounts of a market to total supply and borrow

     * token amounts.

     */

    function totalParToWei(

        Types.TotalPar memory totalPar,

        Index memory index

    )

        internal

        pure

        returns (Types.Wei memory, Types.Wei memory)

    {

        Types.Par memory supplyPar = Types.Par({

            sign: true,

            value: totalPar.supply

        });

        Types.Par memory borrowPar = Types.Par({

            sign: false,

            value: totalPar.borrow

        });

        Types.Wei memory supplyWei = parToWei(supplyPar, index);

        Types.Wei memory borrowWei = parToWei(borrowPar, index);

        return (supplyWei, borrowWei);

    }

}



// File: contracts/protocol/interfaces/IInterestSetter.sol



/**

 * @title IInterestSetter

 * @author dYdX

 *

 * Interface that Interest Setters for Solo must implement in order to report interest rates.

 */

interface IInterestSetter {



    // ============ Public Functions ============



    /**

     * Get the interest rate of a token given some borrowed and supplied amounts

     *

     * @param  token        The address of the ERC20 token for the market

     * @param  borrowWei    The total borrowed token amount for the market

     * @param  supplyWei    The total supplied token amount for the market

     * @return              The interest rate per second

     */

    function getInterestRate(

        address token,

        uint256 borrowWei,

        uint256 supplyWei

    )

        external

        view

        returns (Interest.Rate memory);

}



// File: contracts/protocol/lib/Monetary.sol



/**

 * @title Monetary

 * @author dYdX

 *

 * Library for types involving money

 */

library Monetary {



    /*

     * The price of a base-unit of an asset.

     */

    struct Price {

        uint256 value;

    }



    /*

     * Total value of an some amount of an asset. Equal to (price * amount).

     */

    struct Value {

        uint256 value;

    }

}



// File: contracts/protocol/interfaces/IPriceOracle.sol



/**

 * @title IPriceOracle

 * @author dYdX

 *

 * Interface that Price Oracles for Solo must implement in order to report prices.

 */

contract IPriceOracle {



    // ============ Constants ============



    uint256 public constant ONE_DOLLAR = 10 ** 36;



    // ============ Public Functions ============



    /**

     * Get the price of a token

     *

     * @param  token  The ERC20 token address of the market

     * @return        The USD price of a base unit of the token, then multiplied by 10^36.

     *                So a USD-stable coin with 18 decimal places would return 10^18.

     *                This is the price of the base unit rather than the price of a "human-readable"

     *                token amount. Every ERC20 may have a different number of decimals.

     */

    function getPrice(

        address token

    )

        public

        view

        returns (Monetary.Price memory);

}



// File: contracts/protocol/lib/Account.sol



/**

 * @title Account

 * @author dYdX

 *

 * Library of structs and functions that represent an account

 */

library Account {

    // ============ Enums ============



    /*

     * Most-recently-cached account status.

     *

     * Normal: Can only be liquidated if the account values are violating the global margin-ratio.

     * Liquid: Can be liquidated no matter the account values.

     *         Can be vaporized if there are no more positive account values.

     * Vapor:  Has only negative (or zeroed) account values. Can be vaporized.

     *

     */

    enum Status {

        Normal,

        Liquid,

        Vapor

    }



    // ============ Structs ============



    // Represents the unique key that specifies an account

    struct Info {

        address owner;  // The address that owns the account

        uint256 number; // A nonce that allows a single address to control many accounts

    }



    // The complete storage for any account

    struct Storage {

        mapping (uint256 => Types.Par) balances; // Mapping from marketId to principal

        Status status;

    }



    // ============ Library Functions ============



    function equals(

        Info memory a,

        Info memory b

    )

        internal

        pure

        returns (bool)

    {

        return a.owner == b.owner && a.number == b.number;

    }

}



// File: contracts/protocol/lib/Cache.sol



/**

 * @title Cache

 * @author dYdX

 *

 * Library for caching information about markets

 */

library Cache {

    using Cache for MarketCache;

    using Storage for Storage.State;



    // ============ Structs ============



    struct MarketInfo {

        bool isClosing;

        uint128 borrowPar;

        Monetary.Price price;

    }



    struct MarketCache {

        MarketInfo[] markets;

    }



    // ============ Setter Functions ============



    /**

     * Initialize an empty cache for some given number of total markets.

     */

    function create(

        uint256 numMarkets

    )

        internal

        pure

        returns (MarketCache memory)

    {

        return MarketCache({

            markets: new MarketInfo[](numMarkets)

        });

    }



    /**

     * Add market information (price and total borrowed par if the market is closing) to the cache.

     * Return true if the market information did not previously exist in the cache.

     */

    function addMarket(

        MarketCache memory cache,

        Storage.State storage state,

        uint256 marketId

    )

        internal

        view

        returns (bool)

    {

        if (cache.hasMarket(marketId)) {

            return false;

        }

        cache.markets[marketId].price = state.fetchPrice(marketId);

        if (state.markets[marketId].isClosing) {

            cache.markets[marketId].isClosing = true;

            cache.markets[marketId].borrowPar = state.getTotalPar(marketId).borrow;

        }

        return true;

    }



    // ============ Getter Functions ============



    function getNumMarkets(

        MarketCache memory cache

    )

        internal

        pure

        returns (uint256)

    {

        return cache.markets.length;

    }



    function hasMarket(

        MarketCache memory cache,

        uint256 marketId

    )

        internal

        pure

        returns (bool)

    {

        return cache.markets[marketId].price.value != 0;

    }



    function getIsClosing(

        MarketCache memory cache,

        uint256 marketId

    )

        internal

        pure

        returns (bool)

    {

        return cache.markets[marketId].isClosing;

    }



    function getPrice(

        MarketCache memory cache,

        uint256 marketId

    )

        internal

        pure

        returns (Monetary.Price memory)

    {

        return cache.markets[marketId].price;

    }



    function getBorrowPar(

        MarketCache memory cache,

        uint256 marketId

    )

        internal

        pure

        returns (uint128)

    {

        return cache.markets[marketId].borrowPar;

    }

}



// File: contracts/protocol/interfaces/IErc20.sol



/**

 * @title IErc20

 * @author dYdX

 *

 * Interface for using ERC20 Tokens. We have to use a special interface to call ERC20 functions so

 * that we don't automatically revert when calling non-compliant tokens that have no return value for

 * transfer(), transferFrom(), or approve().

 */

interface IErc20 {

    event Transfer(

        address indexed from,

        address indexed to,

        uint256 value

    );



    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );



    function totalSupply(

    )

        external

        view

        returns (uint256);



    function balanceOf(

        address who

    )

        external

        view

        returns (uint256);



    function allowance(

        address owner,

        address spender

    )

        external

        view

        returns (uint256);



    function transfer(

        address to,

        uint256 value

    )

        external;



    function transferFrom(

        address from,

        address to,

        uint256 value

    )

        external;



    function approve(

        address spender,

        uint256 value

    )

        external;



    function name()

        external

        view

        returns (string memory);



    function symbol()

        external

        view

        returns (string memory);



    function decimals()

        external

        view

        returns (uint8);

}



// File: contracts/protocol/lib/Token.sol



/**

 * @title Token

 * @author dYdX

 *

 * This library contains basic functions for interacting with ERC20 tokens. Modified to work with

 * tokens that don't adhere strictly to the ERC20 standard (for example tokens that don't return a

 * boolean value on success).

 */

library Token {



    // ============ Constants ============



    bytes32 constant FILE = "Token";



    // ============ Library Functions ============



    function balanceOf(

        address token,

        address owner

    )

        internal

        view

        returns (uint256)

    {

        return IErc20(token).balanceOf(owner);

    }



    function allowance(

        address token,

        address owner,

        address spender

    )

        internal

        view

        returns (uint256)

    {

        return IErc20(token).allowance(owner, spender);

    }



    function approve(

        address token,

        address spender,

        uint256 amount

    )

        internal

    {

        IErc20(token).approve(spender, amount);



        Require.that(

            checkSuccess(),

            FILE,

            "Approve failed"

        );

    }



    function approveMax(

        address token,

        address spender

    )

        internal

    {

        approve(

            token,

            spender,

            uint256(-1)

        );

    }



    function transfer(

        address token,

        address to,

        uint256 amount

    )

        internal

    {

        if (amount == 0 || to == address(this)) {

            return;

        }



        IErc20(token).transfer(to, amount);



        Require.that(

            checkSuccess(),

            FILE,

            "Transfer failed"

        );

    }



    function transferFrom(

        address token,

        address from,

        address to,

        uint256 amount

    )

        internal

    {

        if (amount == 0 || to == from) {

            return;

        }



        IErc20(token).transferFrom(from, to, amount);



        Require.that(

            checkSuccess(),

            FILE,

            "TransferFrom failed"

        );

    }



    // ============ Private Functions ============



    /**

     * Check the return value of the previous function up to 32 bytes. Return true if the previous

     * function returned 0 bytes or 32 bytes that are not all-zero.

     */

    function checkSuccess(

    )

        private

        pure

        returns (bool)

    {

        uint256 returnValue = 0;



        /* solium-disable-next-line security/no-inline-assembly */

        assembly {

            // check number of bytes returned from last function call

            switch returndatasize



            // no bytes returned: assume success

            case 0x0 {

                returnValue := 1

            }



            // 32 bytes returned: check if non-zero

            case 0x20 {

                // copy 32 bytes into scratch space

                returndatacopy(0x0, 0x0, 0x20)



                // load those bytes into returnValue

                returnValue := mload(0x0)

            }



            // not sure what was returned: don't mark as success

            default { }

        }



        return returnValue != 0;

    }

}



// File: contracts/protocol/lib/Storage.sol



/**

 * @title Storage

 * @author dYdX

 *

 * Functions for reading, writing, and verifying state in Solo

 */

library Storage {

    using Cache for Cache.MarketCache;

    using Storage for Storage.State;

    using Math for uint256;

    using Types for Types.Par;

    using Types for Types.Wei;

    using SafeMath for uint256;



    // ============ Constants ============



    bytes32 constant FILE = "Storage";



    // ============ Structs ============



    // All information necessary for tracking a market

    struct Market {

        // Contract address of the associated ERC20 token

        address token;



        // Total aggregated supply and borrow amount of the entire market

        Types.TotalPar totalPar;



        // Interest index of the market

        Interest.Index index;



        // Contract address of the price oracle for this market

        IPriceOracle priceOracle;



        // Contract address of the interest setter for this market

        IInterestSetter interestSetter;



        // Multiplier on the marginRatio for this market

        Decimal.D256 marginPremium;



        // Multiplier on the liquidationSpread for this market

        Decimal.D256 spreadPremium;



        // Whether additional borrows are allowed for this market

        bool isClosing;

    }



    // The global risk parameters that govern the health and security of the system

    struct RiskParams {

        // Required ratio of over-collateralization

        Decimal.D256 marginRatio;



        // Percentage penalty incurred by liquidated accounts

        Decimal.D256 liquidationSpread;



        // Percentage of the borrower's interest fee that gets passed to the suppliers

        Decimal.D256 earningsRate;



        // The minimum absolute borrow value of an account

        // There must be sufficient incentivize to liquidate undercollateralized accounts

        Monetary.Value minBorrowedValue;

    }



    // The maximum RiskParam values that can be set

    struct RiskLimits {

        uint64 marginRatioMax;

        uint64 liquidationSpreadMax;

        uint64 earningsRateMax;

        uint64 marginPremiumMax;

        uint64 spreadPremiumMax;

        uint128 minBorrowedValueMax;

    }



    // The entire storage state of Solo

    struct State {

        // number of markets

        uint256 numMarkets;



        // marketId => Market

        mapping (uint256 => Market) markets;



        // owner => account number => Account

        mapping (address => mapping (uint256 => Account.Storage)) accounts;



        // Addresses that can control other users accounts

        mapping (address => mapping (address => bool)) operators;



        // Addresses that can control all users accounts

        mapping (address => bool) globalOperators;



        // mutable risk parameters of the system

        RiskParams riskParams;



        // immutable risk limits of the system

        RiskLimits riskLimits;

    }



    // ============ Functions ============



    function getToken(

        Storage.State storage state,

        uint256 marketId

    )

        internal

        view

        returns (address)

    {

        return state.markets[marketId].token;

    }



    function getTotalPar(

        Storage.State storage state,

        uint256 marketId

    )

        internal

        view

        returns (Types.TotalPar memory)

    {

        return state.markets[marketId].totalPar;

    }



    function getIndex(

        Storage.State storage state,

        uint256 marketId

    )

        internal

        view

        returns (Interest.Index memory)

    {

        return state.markets[marketId].index;

    }



    function getNumExcessTokens(

        Storage.State storage state,

        uint256 marketId

    )

        internal

        view

        returns (Types.Wei memory)

    {

        Interest.Index memory index = state.getIndex(marketId);

        Types.TotalPar memory totalPar = state.getTotalPar(marketId);



        address token = state.getToken(marketId);



        Types.Wei memory balanceWei = Types.Wei({

            sign: true,

            value: Token.balanceOf(token, address(this))

        });



        (

            Types.Wei memory supplyWei,

            Types.Wei memory borrowWei

        ) = Interest.totalParToWei(totalPar, index);



        // borrowWei is negative, so subtracting it makes the value more positive

        return balanceWei.sub(borrowWei).sub(supplyWei);

    }



    function getStatus(

        Storage.State storage state,

        Account.Info memory account

    )

        internal

        view

        returns (Account.Status)

    {

        return state.accounts[account.owner][account.number].status;

    }



    function getPar(

        Storage.State storage state,

        Account.Info memory account,

        uint256 marketId

    )

        internal

        view

        returns (Types.Par memory)

    {

        return state.accounts[account.owner][account.number].balances[marketId];

    }



    function getWei(

        Storage.State storage state,

        Account.Info memory account,

        uint256 marketId

    )

        internal

        view

        returns (Types.Wei memory)

    {

        Types.Par memory par = state.getPar(account, marketId);



        if (par.isZero()) {

            return Types.zeroWei();

        }



        Interest.Index memory index = state.getIndex(marketId);

        return Interest.parToWei(par, index);

    }



    function getLiquidationSpreadForPair(

        Storage.State storage state,

        uint256 heldMarketId,

        uint256 owedMarketId

    )

        internal

        view

        returns (Decimal.D256 memory)

    {

        uint256 result = state.riskParams.liquidationSpread.value;

        result = Decimal.mul(result, Decimal.onePlus(state.markets[heldMarketId].spreadPremium));

        result = Decimal.mul(result, Decimal.onePlus(state.markets[owedMarketId].spreadPremium));

        return Decimal.D256({

            value: result

        });

    }



    function fetchNewIndex(

        Storage.State storage state,

        uint256 marketId,

        Interest.Index memory index

    )

        internal

        view

        returns (Interest.Index memory)

    {

        Interest.Rate memory rate = state.fetchInterestRate(marketId, index);



        return Interest.calculateNewIndex(

            index,

            rate,

            state.getTotalPar(marketId),

            state.riskParams.earningsRate

        );

    }



    function fetchInterestRate(

        Storage.State storage state,

        uint256 marketId,

        Interest.Index memory index

    )

        internal

        view

        returns (Interest.Rate memory)

    {

        Types.TotalPar memory totalPar = state.getTotalPar(marketId);

        (

            Types.Wei memory supplyWei,

            Types.Wei memory borrowWei

        ) = Interest.totalParToWei(totalPar, index);



        Interest.Rate memory rate = state.markets[marketId].interestSetter.getInterestRate(

            state.getToken(marketId),

            borrowWei.value,

            supplyWei.value

        );



        return rate;

    }



    function fetchPrice(

        Storage.State storage state,

        uint256 marketId

    )

        internal

        view

        returns (Monetary.Price memory)

    {

        IPriceOracle oracle = IPriceOracle(state.markets[marketId].priceOracle);

        Monetary.Price memory price = oracle.getPrice(state.getToken(marketId));

        Require.that(

            price.value != 0,

            FILE,

            "Price cannot be zero",

            marketId

        );

        return price;

    }



    function getAccountValues(

        Storage.State storage state,

        Account.Info memory account,

        Cache.MarketCache memory cache,

        bool adjustForLiquidity

    )

        internal

        view

        returns (Monetary.Value memory, Monetary.Value memory)

    {

        Monetary.Value memory supplyValue;

        Monetary.Value memory borrowValue;



        uint256 numMarkets = cache.getNumMarkets();

        for (uint256 m = 0; m < numMarkets; m++) {

            if (!cache.hasMarket(m)) {

                continue;

            }



            Types.Wei memory userWei = state.getWei(account, m);



            if (userWei.isZero()) {

                continue;

            }



            uint256 assetValue = userWei.value.mul(cache.getPrice(m).value);

            Decimal.D256 memory adjust = Decimal.one();

            if (adjustForLiquidity) {

                adjust = Decimal.onePlus(state.markets[m].marginPremium);

            }



            if (userWei.sign) {

                supplyValue.value = supplyValue.value.add(Decimal.div(assetValue, adjust));

            } else {

                borrowValue.value = borrowValue.value.add(Decimal.mul(assetValue, adjust));

            }

        }



        return (supplyValue, borrowValue);

    }



    function isCollateralized(

        Storage.State storage state,

        Account.Info memory account,

        Cache.MarketCache memory cache,

        bool requireMinBorrow

    )

        internal

        view

        returns (bool)

    {

        // get account values (adjusted for liquidity)

        (

            Monetary.Value memory supplyValue,

            Monetary.Value memory borrowValue

        ) = state.getAccountValues(account, cache, /* adjustForLiquidity = */ true);



        if (borrowValue.value == 0) {

            return true;

        }



        if (requireMinBorrow) {

            Require.that(

                borrowValue.value >= state.riskParams.minBorrowedValue.value,

                FILE,

                "Borrow value too low",

                account.owner,

                account.number,

                borrowValue.value

            );

        }



        uint256 requiredMargin = Decimal.mul(borrowValue.value, state.riskParams.marginRatio);



        return supplyValue.value >= borrowValue.value.add(requiredMargin);

    }



    function isGlobalOperator(

        Storage.State storage state,

        address operator

    )

        internal

        view

        returns (bool)

    {

        return state.globalOperators[operator];

    }



    function isLocalOperator(

        Storage.State storage state,

        address owner,

        address operator

    )

        internal

        view

        returns (bool)

    {

        return state.operators[owner][operator];

    }



    function requireIsOperator(

        Storage.State storage state,

        Account.Info memory account,

        address operator

    )

        internal

        view

    {

        bool isValidOperator =

            operator == account.owner

            || state.isGlobalOperator(operator)

            || state.isLocalOperator(account.owner, operator);



        Require.that(

            isValidOperator,

            FILE,

            "Unpermissioned operator",

            operator

        );

    }



    /**

     * Determine and set an account's balance based on the intended balance change. Return the

     * equivalent amount in wei

     */

    function getNewParAndDeltaWei(

        Storage.State storage state,

        Account.Info memory account,

        uint256 marketId,

        Types.AssetAmount memory amount

    )

        internal

        view

        returns (Types.Par memory, Types.Wei memory)

    {

        Types.Par memory oldPar = state.getPar(account, marketId);



        if (amount.value == 0 && amount.ref == Types.AssetReference.Delta) {

            return (oldPar, Types.zeroWei());

        }



        Interest.Index memory index = state.getIndex(marketId);

        Types.Wei memory oldWei = Interest.parToWei(oldPar, index);

        Types.Par memory newPar;

        Types.Wei memory deltaWei;



        if (amount.denomination == Types.AssetDenomination.Wei) {

            deltaWei = Types.Wei({

                sign: amount.sign,

                value: amount.value

            });

            if (amount.ref == Types.AssetReference.Target) {

                deltaWei = deltaWei.sub(oldWei);

            }

            newPar = Interest.weiToPar(oldWei.add(deltaWei), index);

        } else { // AssetDenomination.Par

            newPar = Types.Par({

                sign: amount.sign,

                value: amount.value.to128()

            });

            if (amount.ref == Types.AssetReference.Delta) {

                newPar = oldPar.add(newPar);

            }

            deltaWei = Interest.parToWei(newPar, index).sub(oldWei);

        }



        return (newPar, deltaWei);

    }



    function getNewParAndDeltaWeiForLiquidation(

        Storage.State storage state,

        Account.Info memory account,

        uint256 marketId,

        Types.AssetAmount memory amount

    )

        internal

        view

        returns (Types.Par memory, Types.Wei memory)

    {

        Types.Par memory oldPar = state.getPar(account, marketId);



        Require.that(

            !oldPar.isPositive(),

            FILE,

            "Owed balance cannot be positive",

            account.owner,

            account.number,

            marketId

        );



        (

            Types.Par memory newPar,

            Types.Wei memory deltaWei

        ) = state.getNewParAndDeltaWei(

            account,

            marketId,

            amount

        );



        // if attempting to over-repay the owed asset, bound it by the maximum

        if (newPar.isPositive()) {

            newPar = Types.zeroPar();

            deltaWei = state.getWei(account, marketId).negative();

        }



        Require.that(

            !deltaWei.isNegative() && oldPar.value >= newPar.value,

            FILE,

            "Owed balance cannot increase",

            account.owner,

            account.number,

            marketId

        );



        // if not paying back enough wei to repay any par, then bound wei to zero

        if (oldPar.equals(newPar)) {

            deltaWei = Types.zeroWei();

        }



        return (newPar, deltaWei);

    }



    function isVaporizable(

        Storage.State storage state,

        Account.Info memory account,

        Cache.MarketCache memory cache

    )

        internal

        view

        returns (bool)

    {

        bool hasNegative = false;

        uint256 numMarkets = cache.getNumMarkets();

        for (uint256 m = 0; m < numMarkets; m++) {

            if (!cache.hasMarket(m)) {

                continue;

            }

            Types.Par memory par = state.getPar(account, m);

            if (par.isZero()) {

                continue;

            } else if (par.sign) {

                return false;

            } else {

                hasNegative = true;

            }

        }

        return hasNegative;

    }



    // =============== Setter Functions ===============



    function updateIndex(

        Storage.State storage state,

        uint256 marketId

    )

        internal

        returns (Interest.Index memory)

    {

        Interest.Index memory index = state.getIndex(marketId);

        if (index.lastUpdate == Time.currentTime()) {

            return index;

        }

        return state.markets[marketId].index = state.fetchNewIndex(marketId, index);

    }



    function setStatus(

        Storage.State storage state,

        Account.Info memory account,

        Account.Status status

    )

        internal

    {

        state.accounts[account.owner][account.number].status = status;

    }



    function setPar(

        Storage.State storage state,

        Account.Info memory account,

        uint256 marketId,

        Types.Par memory newPar

    )

        internal

    {

        Types.Par memory oldPar = state.getPar(account, marketId);



        if (Types.equals(oldPar, newPar)) {

            return;

        }



        // updateTotalPar

        Types.TotalPar memory totalPar = state.getTotalPar(marketId);



        // roll-back oldPar

        if (oldPar.sign) {

            totalPar.supply = uint256(totalPar.supply).sub(oldPar.value).to128();

        } else {

            totalPar.borrow = uint256(totalPar.borrow).sub(oldPar.value).to128();

        }



        // roll-forward newPar

        if (newPar.sign) {

            totalPar.supply = uint256(totalPar.supply).add(newPar.value).to128();

        } else {

            totalPar.borrow = uint256(totalPar.borrow).add(newPar.value).to128();

        }



        state.markets[marketId].totalPar = totalPar;

        state.accounts[account.owner][account.number].balances[marketId] = newPar;

    }



    /**

     * Determine and set an account's balance based on a change in wei

     */

    function setParFromDeltaWei(

        Storage.State storage state,

        Account.Info memory account,

        uint256 marketId,

        Types.Wei memory deltaWei

    )

        internal

    {

        if (deltaWei.isZero()) {

            return;

        }

        Interest.Index memory index = state.getIndex(marketId);

        Types.Wei memory oldWei = state.getWei(account, marketId);

        Types.Wei memory newWei = oldWei.add(deltaWei);

        Types.Par memory newPar = Interest.weiToPar(newWei, index);

        state.setPar(

            account,

            marketId,

            newPar

        );

    }

}



// File: contracts/protocol/impl/AdminImpl.sol



/**

 * @title AdminImpl

 * @author dYdX

 *

 * Administrative functions to keep the protocol updated

 */

library AdminImpl {

    using Storage for Storage.State;

    using Token for address;

    using Types for Types.Wei;



    // ============ Constants ============



    bytes32 constant FILE = "AdminImpl";



    // ============ Events ============



    event LogWithdrawExcessTokens(

        address token,

        uint256 amount

    );



    event LogAddMarket(

        uint256 marketId,

        address token

    );



    event LogSetIsClosing(

        uint256 marketId,

        bool isClosing

    );



    event LogSetPriceOracle(

        uint256 marketId,

        address priceOracle

    );



    event LogSetInterestSetter(

        uint256 marketId,

        address interestSetter

    );



    event LogSetMarginPremium(

        uint256 marketId,

        Decimal.D256 marginPremium

    );



    event LogSetSpreadPremium(

        uint256 marketId,

        Decimal.D256 spreadPremium

    );



    event LogSetMarginRatio(

        Decimal.D256 marginRatio

    );



    event LogSetLiquidationSpread(

        Decimal.D256 liquidationSpread

    );



    event LogSetEarningsRate(

        Decimal.D256 earningsRate

    );



    event LogSetMinBorrowedValue(

        Monetary.Value minBorrowedValue

    );



    event LogSetGlobalOperator(

        address operator,

        bool approved

    );



    // ============ Token Functions ============



    function ownerWithdrawExcessTokens(

        Storage.State storage state,

        uint256 marketId,

        address recipient

    )

        public

        returns (uint256)

    {

        _validateMarketId(state, marketId);

        Types.Wei memory excessWei = state.getNumExcessTokens(marketId);



        Require.that(

            !excessWei.isNegative(),

            FILE,

            "Negative excess"

        );



        address token = state.getToken(marketId);



        uint256 actualBalance = token.balanceOf(address(this));

        if (excessWei.value > actualBalance) {

            excessWei.value = actualBalance;

        }



        token.transfer(recipient, excessWei.value);



        emit LogWithdrawExcessTokens(token, excessWei.value);



        return excessWei.value;

    }



    function ownerWithdrawUnsupportedTokens(

        Storage.State storage state,

        address token,

        address recipient

    )

        public

        returns (uint256)

    {

        _requireNoMarket(state, token);



        uint256 balance = token.balanceOf(address(this));

        token.transfer(recipient, balance);



        emit LogWithdrawExcessTokens(token, balance);



        return balance;

    }



    // ============ Market Functions ============



    function ownerAddMarket(

        Storage.State storage state,

        address token,

        IPriceOracle priceOracle,

        IInterestSetter interestSetter,

        Decimal.D256 memory marginPremium,

        Decimal.D256 memory spreadPremium

    )

        public

    {

        _requireNoMarket(state, token);



        uint256 marketId = state.numMarkets;



        state.numMarkets++;

        state.markets[marketId].token = token;

        state.markets[marketId].index = Interest.newIndex();



        emit LogAddMarket(marketId, token);



        _setPriceOracle(state, marketId, priceOracle);

        _setInterestSetter(state, marketId, interestSetter);

        _setMarginPremium(state, marketId, marginPremium);

        _setSpreadPremium(state, marketId, spreadPremium);

    }



    function ownerSetIsClosing(

        Storage.State storage state,

        uint256 marketId,

        bool isClosing

    )

        public

    {

        _validateMarketId(state, marketId);

        state.markets[marketId].isClosing = isClosing;

        emit LogSetIsClosing(marketId, isClosing);

    }



    function ownerSetPriceOracle(

        Storage.State storage state,

        uint256 marketId,

        IPriceOracle priceOracle

    )

        public

    {

        _validateMarketId(state, marketId);

        _setPriceOracle(state, marketId, priceOracle);

    }



    function ownerSetInterestSetter(

        Storage.State storage state,

        uint256 marketId,

        IInterestSetter interestSetter

    )

        public

    {

        _validateMarketId(state, marketId);

        _setInterestSetter(state, marketId, interestSetter);

    }



    function ownerSetMarginPremium(

        Storage.State storage state,

        uint256 marketId,

        Decimal.D256 memory marginPremium

    )

        public

    {

        _validateMarketId(state, marketId);

        _setMarginPremium(state, marketId, marginPremium);

    }



    function ownerSetSpreadPremium(

        Storage.State storage state,

        uint256 marketId,

        Decimal.D256 memory spreadPremium

    )

        public

    {

        _validateMarketId(state, marketId);

        _setSpreadPremium(state, marketId, spreadPremium);

    }



    // ============ Risk Functions ============



    function ownerSetMarginRatio(

        Storage.State storage state,

        Decimal.D256 memory ratio

    )

        public

    {

        Require.that(

            ratio.value <= state.riskLimits.marginRatioMax,

            FILE,

            "Ratio too high"

        );

        Require.that(

            ratio.value > state.riskParams.liquidationSpread.value,

            FILE,

            "Ratio cannot be <= spread"

        );

        state.riskParams.marginRatio = ratio;

        emit LogSetMarginRatio(ratio);

    }



    function ownerSetLiquidationSpread(

        Storage.State storage state,

        Decimal.D256 memory spread

    )

        public

    {

        Require.that(

            spread.value <= state.riskLimits.liquidationSpreadMax,

            FILE,

            "Spread too high"

        );

        Require.that(

            spread.value < state.riskParams.marginRatio.value,

            FILE,

            "Spread cannot be >= ratio"

        );

        state.riskParams.liquidationSpread = spread;

        emit LogSetLiquidationSpread(spread);

    }



    function ownerSetEarningsRate(

        Storage.State storage state,

        Decimal.D256 memory earningsRate

    )

        public

    {

        Require.that(

            earningsRate.value <= state.riskLimits.earningsRateMax,

            FILE,

            "Rate too high"

        );

        state.riskParams.earningsRate = earningsRate;

        emit LogSetEarningsRate(earningsRate);

    }



    function ownerSetMinBorrowedValue(

        Storage.State storage state,

        Monetary.Value memory minBorrowedValue

    )

        public

    {

        Require.that(

            minBorrowedValue.value <= state.riskLimits.minBorrowedValueMax,

            FILE,

            "Value too high"

        );

        state.riskParams.minBorrowedValue = minBorrowedValue;

        emit LogSetMinBorrowedValue(minBorrowedValue);

    }



    // ============ Global Operator Functions ============



    function ownerSetGlobalOperator(

        Storage.State storage state,

        address operator,

        bool approved

    )

        public

    {

        state.globalOperators[operator] = approved;



        emit LogSetGlobalOperator(operator, approved);

    }



    // ============ Private Functions ============



    function _setPriceOracle(

        Storage.State storage state,

        uint256 marketId,

        IPriceOracle priceOracle

    )

        private

    {

        // require oracle can return non-zero price

        address token = state.markets[marketId].token;



        Require.that(

            priceOracle.getPrice(token).value != 0,

            FILE,

            "Invalid oracle price"

        );



        state.markets[marketId].priceOracle = priceOracle;



        emit LogSetPriceOracle(marketId, address(priceOracle));

    }



    function _setInterestSetter(

        Storage.State storage state,

        uint256 marketId,

        IInterestSetter interestSetter

    )

        private

    {

        // ensure interestSetter can return a value without reverting

        address token = state.markets[marketId].token;

        interestSetter.getInterestRate(token, 0, 0);



        state.markets[marketId].interestSetter = interestSetter;



        emit LogSetInterestSetter(marketId, address(interestSetter));

    }



    function _setMarginPremium(

        Storage.State storage state,

        uint256 marketId,

        Decimal.D256 memory marginPremium

    )

        private

    {

        Require.that(

            marginPremium.value <= state.riskLimits.marginPremiumMax,

            FILE,

            "Margin premium too high"

        );

        state.markets[marketId].marginPremium = marginPremium;



        emit LogSetMarginPremium(marketId, marginPremium);

    }



    function _setSpreadPremium(

        Storage.State storage state,

        uint256 marketId,

        Decimal.D256 memory spreadPremium

    )

        private

    {

        Require.that(

            spreadPremium.value <= state.riskLimits.spreadPremiumMax,

            FILE,

            "Spread premium too high"

        );

        state.markets[marketId].spreadPremium = spreadPremium;



        emit LogSetSpreadPremium(marketId, spreadPremium);

    }



    function _requireNoMarket(

        Storage.State storage state,

        address token

    )

        private

        view

    {

        uint256 numMarkets = state.numMarkets;



        bool marketExists = false;



        for (uint256 m = 0; m < numMarkets; m++) {

            if (state.markets[m].token == token) {

                marketExists = true;

                break;

            }

        }



        Require.that(

            !marketExists,

            FILE,

            "Market exists"

        );

    }



    function _validateMarketId(

        Storage.State storage state,

        uint256 marketId

    )

        private

        view

    {

        Require.that(

            marketId < state.numMarkets,

            FILE,

            "Market OOB",

            marketId

        );

    }

}