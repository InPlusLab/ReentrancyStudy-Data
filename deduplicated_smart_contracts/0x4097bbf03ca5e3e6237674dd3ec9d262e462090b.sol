/**

 *Submitted for verification at Etherscan.io on 2018-11-06

*/



pragma solidity 0.4.24;

pragma experimental "v0.5.0";



/*



    Copyright 2018 dYdX Trading Inc.



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



// File: openzeppelin-solidity/contracts/math/Math.sol



/**

 * @title Math

 * @dev Assorted math operations

 */

library Math {

  function max64(uint64 _a, uint64 _b) internal pure returns (uint64) {

    return _a >= _b ? _a : _b;

  }



  function min64(uint64 _a, uint64 _b) internal pure returns (uint64) {

    return _a < _b ? _a : _b;

  }



  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a >= _b ? _a : _b;

  }



  function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a < _b ? _a : _b;

  }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: contracts/lib/Fraction.sol



/**

 * @title Fraction

 * @author dYdX

 *

 * This library contains implementations for fraction structs.

 */

library Fraction {

    struct Fraction128 {

        uint128 num;

        uint128 den;

    }

}



// File: contracts/lib/FractionMath.sol



/**

 * @title FractionMath

 * @author dYdX

 *

 * This library contains safe math functions for manipulating fractions.

 */

library FractionMath {

    using SafeMath for uint256;

    using SafeMath for uint128;



    /**

     * Returns a Fraction128 that is equal to a + b

     *

     * @param  a  The first Fraction128

     * @param  b  The second Fraction128

     * @return    The result (sum)

     */

    function add(

        Fraction.Fraction128 memory a,

        Fraction.Fraction128 memory b

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        uint256 left = a.num.mul(b.den);

        uint256 right = b.num.mul(a.den);

        uint256 denominator = a.den.mul(b.den);



        // if left + right overflows, prevent overflow

        if (left + right < left) {

            left = left.div(2);

            right = right.div(2);

            denominator = denominator.div(2);

        }



        return bound(left.add(right), denominator);

    }



    /**

     * Returns a Fraction128 that is equal to a - (1/2)^d

     *

     * @param  a  The Fraction128

     * @param  d  The power of (1/2)

     * @return    The result

     */

    function sub1Over(

        Fraction.Fraction128 memory a,

        uint128 d

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        if (a.den % d == 0) {

            return bound(

                a.num.sub(a.den.div(d)),

                a.den

            );

        }

        return bound(

            a.num.mul(d).sub(a.den),

            a.den.mul(d)

        );

    }



    /**

     * Returns a Fraction128 that is equal to a / d

     *

     * @param  a  The first Fraction128

     * @param  d  The divisor

     * @return    The result (quotient)

     */

    function div(

        Fraction.Fraction128 memory a,

        uint128 d

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        if (a.num % d == 0) {

            return bound(

                a.num.div(d),

                a.den

            );

        }

        return bound(

            a.num,

            a.den.mul(d)

        );

    }



    /**

     * Returns a Fraction128 that is equal to a * b.

     *

     * @param  a  The first Fraction128

     * @param  b  The second Fraction128

     * @return    The result (product)

     */

    function mul(

        Fraction.Fraction128 memory a,

        Fraction.Fraction128 memory b

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        return bound(

            a.num.mul(b.num),

            a.den.mul(b.den)

        );

    }



    /**

     * Returns a fraction from two uint256's. Fits them into uint128 if necessary.

     *

     * @param  num  The numerator

     * @param  den  The denominator

     * @return      The Fraction128 that matches num/den most closely

     */

    /* solium-disable-next-line security/no-assign-params */

    function bound(

        uint256 num,

        uint256 den

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        uint256 max = num > den ? num : den;

        uint256 first128Bits = (max >> 128);

        if (first128Bits != 0) {

            first128Bits += 1;

            num /= first128Bits;

            den /= first128Bits;

        }



        assert(den != 0); // coverage-enable-line

        assert(den < 2**128);

        assert(num < 2**128);



        return Fraction.Fraction128({

            num: uint128(num),

            den: uint128(den)

        });

    }



    /**

     * Returns an in-memory copy of a Fraction128

     *

     * @param  a  The Fraction128 to copy

     * @return    A copy of the Fraction128

     */

    function copy(

        Fraction.Fraction128 memory a

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        validate(a);

        return Fraction.Fraction128({ num: a.num, den: a.den });

    }



    // ============ Private Helper-Functions ============



    /**

     * Asserts that a Fraction128 is valid (i.e. the denominator is non-zero)

     *

     * @param  a  The Fraction128 to validate

     */

    function validate(

        Fraction.Fraction128 memory a

    )

        private

        pure

    {

        assert(a.den != 0); // coverage-enable-line

    }

}



// File: contracts/lib/Exponent.sol



/**

 * @title Exponent

 * @author dYdX

 *

 * This library contains an implementation for calculating e^X for arbitrary fraction X

 */

library Exponent {

    using SafeMath for uint256;

    using FractionMath for Fraction.Fraction128;



    // ============ Constants ============



    // 2**128 - 1

    uint128 constant public MAX_NUMERATOR = 340282366920938463463374607431768211455;



    // Number of precomputed integers, X, for E^((1/2)^X)

    uint256 constant public MAX_PRECOMPUTE_PRECISION = 32;



    // Number of precomputed integers, X, for E^X

    uint256 constant public NUM_PRECOMPUTED_INTEGERS = 32;



    // ============ Public Implementation Functions ============



    /**

     * Returns e^X for any fraction X

     *

     * @param  X                    The exponent

     * @param  precomputePrecision  Accuracy of precomputed terms

     * @param  maclaurinPrecision   Accuracy of Maclaurin terms

     * @return                      e^X

     */

    function exp(

        Fraction.Fraction128 memory X,

        uint256 precomputePrecision,

        uint256 maclaurinPrecision

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        require(

            precomputePrecision <= MAX_PRECOMPUTE_PRECISION,

            "Exponent#exp: Precompute precision over maximum"

        );



        Fraction.Fraction128 memory Xcopy = X.copy();

        if (Xcopy.num == 0) { // e^0 = 1

            return ONE();

        }



        // get the integer value of the fraction (example: 9/4 is 2.25 so has integerValue of 2)

        uint256 integerX = uint256(Xcopy.num).div(Xcopy.den);



        // if X is less than 1, then just calculate X

        if (integerX == 0) {

            return expHybrid(Xcopy, precomputePrecision, maclaurinPrecision);

        }



        // get e^integerX

        Fraction.Fraction128 memory expOfInt =

            getPrecomputedEToThe(integerX % NUM_PRECOMPUTED_INTEGERS);

        while (integerX >= NUM_PRECOMPUTED_INTEGERS) {

            expOfInt = expOfInt.mul(getPrecomputedEToThe(NUM_PRECOMPUTED_INTEGERS));

            integerX -= NUM_PRECOMPUTED_INTEGERS;

        }



        // multiply e^integerX by e^decimalX

        Fraction.Fraction128 memory decimalX = Fraction.Fraction128({

            num: Xcopy.num % Xcopy.den,

            den: Xcopy.den

        });

        return expHybrid(decimalX, precomputePrecision, maclaurinPrecision).mul(expOfInt);

    }



    /**

     * Returns e^X for any X < 1. Multiplies precomputed values to get close to the real value, then

     * Maclaurin Series approximation to reduce error.

     *

     * @param  X                    Exponent

     * @param  precomputePrecision  Accuracy of precomputed terms

     * @param  maclaurinPrecision   Accuracy of Maclaurin terms

     * @return                      e^X

     */

    function expHybrid(

        Fraction.Fraction128 memory X,

        uint256 precomputePrecision,

        uint256 maclaurinPrecision

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        assert(precomputePrecision <= MAX_PRECOMPUTE_PRECISION);

        assert(X.num < X.den);

        // will also throw if precomputePrecision is larger than the array length in getDenominator



        Fraction.Fraction128 memory Xtemp = X.copy();

        if (Xtemp.num == 0) { // e^0 = 1

            return ONE();

        }



        Fraction.Fraction128 memory result = ONE();



        uint256 d = 1; // 2^i

        for (uint256 i = 1; i <= precomputePrecision; i++) {

            d *= 2;



            // if Fraction > 1/d, subtract 1/d and multiply result by precomputed e^(1/d)

            if (d.mul(Xtemp.num) >= Xtemp.den) {

                Xtemp = Xtemp.sub1Over(uint128(d));

                result = result.mul(getPrecomputedEToTheHalfToThe(i));

            }

        }

        return result.mul(expMaclaurin(Xtemp, maclaurinPrecision));

    }



    /**

     * Returns e^X for any X, using Maclaurin Series approximation

     *

     * e^X = SUM(X^n / n!) for n >= 0

     * e^X = 1 + X/1! + X^2/2! + X^3/3! ...

     *

     * @param  X           Exponent

     * @param  precision   Accuracy of Maclaurin terms

     * @return             e^X

     */

    function expMaclaurin(

        Fraction.Fraction128 memory X,

        uint256 precision

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        Fraction.Fraction128 memory Xcopy = X.copy();

        if (Xcopy.num == 0) { // e^0 = 1

            return ONE();

        }



        Fraction.Fraction128 memory result = ONE();

        Fraction.Fraction128 memory Xtemp = ONE();

        for (uint256 i = 1; i <= precision; i++) {

            Xtemp = Xtemp.mul(Xcopy.div(uint128(i)));

            result = result.add(Xtemp);

        }

        return result;

    }



    /**

     * Returns a fraction roughly equaling E^((1/2)^x) for integer x

     */

    function getPrecomputedEToTheHalfToThe(

        uint256 x

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        assert(x <= MAX_PRECOMPUTE_PRECISION);



        uint128 denominator = [

            125182886983370532117250726298150828301,

            206391688497133195273760705512282642279,

            265012173823417992016237332255925138361,

            300298134811882980317033350418940119802,

            319665700530617779809390163992561606014,

            329812979126047300897653247035862915816,

            335006777809430963166468914297166288162,

            337634268532609249517744113622081347950,

            338955731696479810470146282672867036734,

            339618401537809365075354109784799900812,

            339950222128463181389559457827561204959,

            340116253979683015278260491021941090650,

            340199300311581465057079429423749235412,

            340240831081268226777032180141478221816,

            340261598367316729254995498374473399540,

            340271982485676106947851156443492415142,

            340277174663693808406010255284800906112,

            340279770782412691177936847400746725466,

            340281068849199706686796915841848278311,

            340281717884450116236033378667952410919,

            340282042402539547492367191008339680733,

            340282204661700319870089970029119685699,

            340282285791309720262481214385569134454,

            340282326356121674011576912006427792656,

            340282346638529464274601981200276914173,

            340282356779733812753265346086924801364,

            340282361850336100329388676752133324799,

            340282364385637272451648746721404212564,

            340282365653287865596328444437856608255,

            340282366287113163939555716675618384724,

            340282366604025813553891209601455838559,

            340282366762482138471739420386372790954,

            340282366841710300958333641874363209044

        ][x];

        return Fraction.Fraction128({

            num: MAX_NUMERATOR,

            den: denominator

        });

    }



    /**

     * Returns a fraction roughly equaling E^(x) for integer x

     */

    function getPrecomputedEToThe(

        uint256 x

    )

        internal

        pure

        returns (Fraction.Fraction128 memory)

    {

        assert(x <= NUM_PRECOMPUTED_INTEGERS);



        uint128 denominator = [

            340282366920938463463374607431768211455,

            125182886983370532117250726298150828301,

            46052210507670172419625860892627118820,

            16941661466271327126146327822211253888,

            6232488952727653950957829210887653621,

            2292804553036637136093891217529878878,

            843475657686456657683449904934172134,

            310297353591408453462393329342695980,

            114152017036184782947077973323212575,

            41994180235864621538772677139808695,

            15448795557622704876497742989562086,

            5683294276510101335127414470015662,

            2090767122455392675095471286328463,

            769150240628514374138961856925097,

            282954560699298259527814398449860,

            104093165666968799599694528310221,

            38293735615330848145349245349513,

            14087478058534870382224480725096,

            5182493555688763339001418388912,

            1906532833141383353974257736699,

            701374233231058797338605168652,

            258021160973090761055471434334,

            94920680509187392077350434438,

            34919366901332874995585576427,

            12846117181722897538509298435,

            4725822410035083116489797150,

            1738532907279185132707372378,

            639570514388029575350057932,

            235284843422800231081973821,

            86556456714490055457751527,

            31842340925906738090071268,

            11714142585413118080082437,

            4309392228124372433711936

        ][x];

        return Fraction.Fraction128({

            num: MAX_NUMERATOR,

            den: denominator

        });

    }



    // ============ Private Helper-Functions ============



    function ONE()

        private

        pure

        returns (Fraction.Fraction128 memory)

    {

        return Fraction.Fraction128({ num: 1, den: 1 });

    }

}



// File: contracts/lib/MathHelpers.sol



/**

 * @title MathHelpers

 * @author dYdX

 *

 * This library helps with common math functions in Solidity

 */

library MathHelpers {

    using SafeMath for uint256;



    /**

     * Calculates partial value given a numerator and denominator.

     *

     * @param  numerator    Numerator

     * @param  denominator  Denominator

     * @param  target       Value to calculate partial of

     * @return              target * numerator / denominator

     */

    function getPartialAmount(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

        internal

        pure

        returns (uint256)

    {

        return numerator.mul(target).div(denominator);

    }



    /**

     * Calculates partial value given a numerator and denominator, rounded up.

     *

     * @param  numerator    Numerator

     * @param  denominator  Denominator

     * @param  target       Value to calculate partial of

     * @return              Rounded-up result of target * numerator / denominator

     */

    function getPartialAmountRoundedUp(

        uint256 numerator,

        uint256 denominator,

        uint256 target

    )

        internal

        pure

        returns (uint256)

    {

        return divisionRoundedUp(numerator.mul(target), denominator);

    }



    /**

     * Calculates division given a numerator and denominator, rounded up.

     *

     * @param  numerator    Numerator.

     * @param  denominator  Denominator.

     * @return              Rounded-up result of numerator / denominator

     */

    function divisionRoundedUp(

        uint256 numerator,

        uint256 denominator

    )

        internal

        pure

        returns (uint256)

    {

        assert(denominator != 0); // coverage-enable-line

        if (numerator == 0) {

            return 0;

        }

        return numerator.sub(1).div(denominator).add(1);

    }



    /**

     * Calculates and returns the maximum value for a uint256 in solidity

     *

     * @return  The maximum value for uint256

     */

    function maxUint256(

    )

        internal

        pure

        returns (uint256)

    {

        return 2 ** 256 - 1;

    }



    /**

     * Calculates and returns the maximum value for a uint256 in solidity

     *

     * @return  The maximum value for uint256

     */

    function maxUint32(

    )

        internal

        pure

        returns (uint32)

    {

        return 2 ** 32 - 1;

    }



    /**

     * Returns the number of bits in a uint256. That is, the lowest number, x, such that n >> x == 0

     *

     * @param  n  The uint256 to get the number of bits in

     * @return    The number of bits in n

     */

    function getNumBits(

        uint256 n

    )

        internal

        pure

        returns (uint256)

    {

        uint256 first = 0;

        uint256 last = 256;

        while (first < last) {

            uint256 check = (first + last) / 2;

            if ((n >> check) == 0) {

                last = check;

            } else {

                first = check + 1;

            }

        }

        assert(first <= 256);

        return first;

    }

}



// File: contracts/margin/impl/InterestImpl.sol



/**

 * @title InterestImpl

 * @author dYdX

 *

 * A library that calculates continuously compounded interest for principal, time period, and

 * interest rate.

 */

library InterestImpl {

    using SafeMath for uint256;

    using FractionMath for Fraction.Fraction128;



    // ============ Constants ============



    uint256 constant DEFAULT_PRECOMPUTE_PRECISION = 11;



    uint256 constant DEFAULT_MACLAURIN_PRECISION = 5;



    uint256 constant MAXIMUM_EXPONENT = 80;



    uint128 constant E_TO_MAXIUMUM_EXPONENT = 55406223843935100525711733958316613;



    // ============ Public Implementation Functions ============



    /**

     * Returns total tokens owed after accruing interest. Continuously compounding and accurate to

     * roughly 10^18 decimal places. Continuously compounding interest follows the formula:

     * I = P * e^(R*T)

     *

     * @param  principal           Principal of the interest calculation

     * @param  interestRate        Annual nominal interest percentage times 10**6.

     *                             (example: 5% = 5e6)

     * @param  secondsOfInterest   Number of seconds that interest has been accruing

     * @return                     Total amount of tokens owed. Greater than tokenAmount.

     */

    function getCompoundedInterest(

        uint256 principal,

        uint256 interestRate,

        uint256 secondsOfInterest

    )

        public

        pure

        returns (uint256)

    {

        uint256 numerator = interestRate.mul(secondsOfInterest);

        uint128 denominator = (10**8) * (365 * 1 days);



        // interestRate and secondsOfInterest should both be uint32

        assert(numerator < 2**128);



        // fraction representing (Rate * Time)

        Fraction.Fraction128 memory rt = Fraction.Fraction128({

            num: uint128(numerator),

            den: denominator

        });



        // calculate e^(RT)

        Fraction.Fraction128 memory eToRT;

        if (numerator.div(denominator) >= MAXIMUM_EXPONENT) {

            // degenerate case: cap calculation

            eToRT = Fraction.Fraction128({

                num: E_TO_MAXIUMUM_EXPONENT,

                den: 1

            });

        } else {

            // normal case: calculate e^(RT)

            eToRT = Exponent.exp(

                rt,

                DEFAULT_PRECOMPUTE_PRECISION,

                DEFAULT_MACLAURIN_PRECISION

            );

        }



        // e^X for positive X should be greater-than or equal to 1

        assert(eToRT.num >= eToRT.den);



        return safeMultiplyUint256ByFraction(principal, eToRT);

    }



    // ============ Private Helper-Functions ============



    /**

     * Returns n * f, trying to prevent overflow as much as possible. Assumes that the numerator

     * and denominator of f are less than 2**128.

     */

    function safeMultiplyUint256ByFraction(

        uint256 n,

        Fraction.Fraction128 memory f

    )

        private

        pure

        returns (uint256)

    {

        uint256 term1 = n.div(2 ** 128); // first 128 bits

        uint256 term2 = n % (2 ** 128); // second 128 bits



        // uncommon scenario, requires n >= 2**128. calculates term1 = term1 * f

        if (term1 > 0) {

            term1 = term1.mul(f.num);

            uint256 numBits = MathHelpers.getNumBits(term1);



            // reduce rounding error by shifting all the way to the left before dividing

            term1 = MathHelpers.divisionRoundedUp(

                term1 << (uint256(256).sub(numBits)),

                f.den);



            // continue shifting or reduce shifting to get the right number

            if (numBits > 128) {

                term1 = term1 << (numBits.sub(128));

            } else if (numBits < 128) {

                term1 = term1 >> (uint256(128).sub(numBits));

            }

        }



        // calculates term2 = term2 * f

        term2 = MathHelpers.getPartialAmountRoundedUp(

            f.num,

            f.den,

            term2

        );



        return term1.add(term2);

    }

}



// File: contracts/margin/impl/MarginState.sol



/**

 * @title MarginState

 * @author dYdX

 *

 * Contains state for the Margin contract. Also used by libraries that implement Margin functions.

 */

library MarginState {

    struct State {

        // Address of the Vault contract

        address VAULT;



        // Address of the TokenProxy contract

        address TOKEN_PROXY;



        // Mapping from loanHash -> amount, which stores the amount of a loan which has

        // already been filled.

        mapping (bytes32 => uint256) loanFills;



        // Mapping from loanHash -> amount, which stores the amount of a loan which has

        // already been canceled.

        mapping (bytes32 => uint256) loanCancels;



        // Mapping from positionId -> Position, which stores all the open margin positions.

        mapping (bytes32 => MarginCommon.Position) positions;



        // Mapping from positionId -> bool, which stores whether the position has previously been

        // open, but is now closed.

        mapping (bytes32 => bool) closedPositions;



        // Mapping from positionId -> uint256, which stores the total amount of owedToken that has

        // ever been repaid to the lender for each position. Does not reset.

        mapping (bytes32 => uint256) totalOwedTokenRepaidToLender;

    }

}



// File: openzeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */

library AddressUtils {



  /**

   * Returns whether the target address is a contract

   * @dev This function will return false if invoked during the constructor of a contract,

   * as the code is not actually created until after the constructor finishes.

   * @param _addr address to check

   * @return whether the target address is a contract

   */

  function isContract(address _addr) internal view returns (bool) {

    uint256 size;

    // XXX Currently there is no better way to check if there is a contract in an address

    // than to check the size of the code at that address.

    // See https://ethereum.stackexchange.com/a/14016/36603

    // for more details about how this works.

    // TODO Check this again before the Serenity release, because all addresses will be

    // contracts then.

    // solium-disable-next-line security/no-inline-assembly

    assembly { size := extcodesize(_addr) }

    return size > 0;

  }



}



// File: contracts/margin/interfaces/lender/LoanOwner.sol



/**

 * @title LoanOwner

 * @author dYdX

 *

 * Interface that smart contracts must implement in order to own loans on behalf of other accounts.

 *

 * NOTE: Any contract implementing this interface should also use OnlyMargin to control access

 *       to these functions

 */

interface LoanOwner {



    // ============ Public Interface functions ============



    /**

     * Function a contract must implement in order to receive ownership of a loan sell via the

     * transferLoan function or the atomic-assign to the "owner" field in a loan offering.

     *

     * @param  from        Address of the previous owner

     * @param  positionId  Unique ID of the position

     * @return             This address to keep ownership, a different address to pass-on ownership

     */

    function receiveLoanOwnership(

        address from,

        bytes32 positionId

    )

        external

        /* onlyMargin */

        returns (address);

}



// File: contracts/margin/interfaces/owner/PositionOwner.sol



/**

 * @title PositionOwner

 * @author dYdX

 *

 * Interface that smart contracts must implement in order to own position on behalf of other

 * accounts

 *

 * NOTE: Any contract implementing this interface should also use OnlyMargin to control access

 *       to these functions

 */

interface PositionOwner {



    // ============ Public Interface functions ============



    /**

     * Function a contract must implement in order to receive ownership of a position via the

     * transferPosition function or the atomic-assign to the "owner" field when opening a position.

     *

     * @param  from        Address of the previous owner

     * @param  positionId  Unique ID of the position

     * @return             This address to keep ownership, a different address to pass-on ownership

     */

    function receivePositionOwnership(

        address from,

        bytes32 positionId

    )

        external

        /* onlyMargin */

        returns (address);

}



// File: contracts/margin/impl/TransferInternal.sol



/**

 * @title TransferInternal

 * @author dYdX

 *

 * This library contains the implementation for transferring ownership of loans and positions.

 */

library TransferInternal {



    // ============ Events ============



    /**

     * Ownership of a loan was transferred to a new address

     */

    event LoanTransferred(

        bytes32 indexed positionId,

        address indexed from,

        address indexed to

    );



    /**

     * Ownership of a postion was transferred to a new address

     */

    event PositionTransferred(

        bytes32 indexed positionId,

        address indexed from,

        address indexed to

    );



    // ============ Internal Implementation Functions ============



    /**

     * Returns either the address of the new loan owner, or the address to which they wish to

     * pass ownership of the loan. This function does not actually set the state of the position

     *

     * @param  positionId  The Unique ID of the position

     * @param  oldOwner    The previous owner of the loan

     * @param  newOwner    The intended owner of the loan

     * @return             The address that the intended owner wishes to assign the loan to (may be

     *                     the same as the intended owner).

     */

    function grantLoanOwnership(

        bytes32 positionId,

        address oldOwner,

        address newOwner

    )

        internal

        returns (address)

    {

        // log event except upon position creation

        if (oldOwner != address(0)) {

            emit LoanTransferred(positionId, oldOwner, newOwner);

        }



        if (AddressUtils.isContract(newOwner)) {

            address nextOwner =

                LoanOwner(newOwner).receiveLoanOwnership(oldOwner, positionId);

            if (nextOwner != newOwner) {

                return grantLoanOwnership(positionId, newOwner, nextOwner);

            }

        }



        require(

            newOwner != address(0),

            "TransferInternal#grantLoanOwnership: New owner did not consent to owning loan"

        );



        return newOwner;

    }



    /**

     * Returns either the address of the new position owner, or the address to which they wish to

     * pass ownership of the position. This function does not actually set the state of the position

     *

     * @param  positionId  The Unique ID of the position

     * @param  oldOwner    The previous owner of the position

     * @param  newOwner    The intended owner of the position

     * @return             The address that the intended owner wishes to assign the position to (may

     *                     be the same as the intended owner).

     */

    function grantPositionOwnership(

        bytes32 positionId,

        address oldOwner,

        address newOwner

    )

        internal

        returns (address)

    {

        // log event except upon position creation

        if (oldOwner != address(0)) {

            emit PositionTransferred(positionId, oldOwner, newOwner);

        }



        if (AddressUtils.isContract(newOwner)) {

            address nextOwner =

                PositionOwner(newOwner).receivePositionOwnership(oldOwner, positionId);

            if (nextOwner != newOwner) {

                return grantPositionOwnership(positionId, newOwner, nextOwner);

            }

        }



        require(

            newOwner != address(0),

            "TransferInternal#grantPositionOwnership: New owner did not consent to owning position"

        );



        return newOwner;

    }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;



  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );



  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



// File: contracts/lib/AccessControlledBase.sol



/**

 * @title AccessControlledBase

 * @author dYdX

 *

 * Base functionality for access control. Requires an implementation to

 * provide a way to grant and optionally revoke access

 */

contract AccessControlledBase {

    // ============ State Variables ============



    mapping (address => bool) public authorized;



    // ============ Events ============



    event AccessGranted(

        address who

    );



    event AccessRevoked(

        address who

    );



    // ============ Modifiers ============



    modifier requiresAuthorization() {

        require(

            authorized[msg.sender],

            "AccessControlledBase#requiresAuthorization: Sender not authorized"

        );

        _;

    }

}



// File: contracts/lib/StaticAccessControlled.sol



/**

 * @title StaticAccessControlled

 * @author dYdX

 *

 * Allows for functions to be access controled

 * Permissions cannot be changed after a grace period

 */

contract StaticAccessControlled is AccessControlledBase, Ownable {

    using SafeMath for uint256;



    // ============ State Variables ============



    // Timestamp after which no additional access can be granted

    uint256 public GRACE_PERIOD_EXPIRATION;



    // ============ Constructor ============



    constructor(

        uint256 gracePeriod

    )

        public

        Ownable()

    {

        GRACE_PERIOD_EXPIRATION = block.timestamp.add(gracePeriod);

    }



    // ============ Owner-Only State-Changing Functions ============



    function grantAccess(

        address who

    )

        external

        onlyOwner

    {

        require(

            block.timestamp < GRACE_PERIOD_EXPIRATION,

            "StaticAccessControlled#grantAccess: Cannot grant access after grace period"

        );



        emit AccessGranted(who);

        authorized[who] = true;

    }

}



// File: contracts/lib/GeneralERC20.sol



/**

 * @title GeneralERC20

 * @author dYdX

 *

 * Interface for using ERC20 Tokens. We have to use a special interface to call ERC20 functions so

 * that we dont automatically revert when calling non-compliant tokens that have no return value for

 * transfer(), transferFrom(), or approve().

 */

interface GeneralERC20 {

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

}



// File: contracts/lib/TokenInteract.sol



/**

 * @title TokenInteract

 * @author dYdX

 *

 * This library contains functions for interacting with ERC20 tokens

 */

library TokenInteract {

    function balanceOf(

        address token,

        address owner

    )

        internal

        view

        returns (uint256)

    {

        return GeneralERC20(token).balanceOf(owner);

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

        return GeneralERC20(token).allowance(owner, spender);

    }



    function approve(

        address token,

        address spender,

        uint256 amount

    )

        internal

    {

        GeneralERC20(token).approve(spender, amount);



        require(

            checkSuccess(),

            "TokenInteract#approve: Approval failed"

        );

    }



    function transfer(

        address token,

        address to,

        uint256 amount

    )

        internal

    {

        address from = address(this);

        if (

            amount == 0

            || from == to

        ) {

            return;

        }



        GeneralERC20(token).transfer(to, amount);



        require(

            checkSuccess(),

            "TokenInteract#transfer: Transfer failed"

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

        if (

            amount == 0

            || from == to

        ) {

            return;

        }



        GeneralERC20(token).transferFrom(from, to, amount);



        require(

            checkSuccess(),

            "TokenInteract#transferFrom: TransferFrom failed"

        );

    }



    // ============ Private Helper-Functions ============



    /**

     * Checks the return value of the previous function up to 32 bytes. Returns true if the previous

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



            // not sure what was returned: dont mark as success

            default { }

        }



        return returnValue != 0;

    }

}



// File: contracts/margin/TokenProxy.sol



/**

 * @title TokenProxy

 * @author dYdX

 *

 * Used to transfer tokens between addresses which have set allowance on this contract.

 */

contract TokenProxy is StaticAccessControlled {

    using SafeMath for uint256;



    // ============ Constructor ============



    constructor(

        uint256 gracePeriod

    )

        public

        StaticAccessControlled(gracePeriod)

    {}



    // ============ Authorized-Only State Changing Functions ============



    /**

     * Transfers tokens from an address (that has set allowance on the proxy) to another address.

     *

     * @param  token  The address of the ERC20 token

     * @param  from   The address to transfer token from

     * @param  to     The address to transfer tokens to

     * @param  value  The number of tokens to transfer

     */

    function transferTokens(

        address token,

        address from,

        address to,

        uint256 value

    )

        external

        requiresAuthorization

    {

        TokenInteract.transferFrom(

            token,

            from,

            to,

            value

        );

    }



    // ============ Public Constant Functions ============



    /**

     * Getter function to get the amount of token that the proxy is able to move for a particular

     * address. The minimum of 1) the balance of that address and 2) the allowance given to proxy.

     *

     * @param  who    The owner of the tokens

     * @param  token  The address of the ERC20 token

     * @return        The number of tokens able to be moved by the proxy from the address specified

     */

    function available(

        address who,

        address token

    )

        external

        view

        returns (uint256)

    {

        return Math.min256(

            TokenInteract.allowance(token, who, address(this)),

            TokenInteract.balanceOf(token, who)

        );

    }

}



// File: contracts/margin/Vault.sol



/**

 * @title Vault

 * @author dYdX

 *

 * Holds and transfers tokens in vaults denominated by id

 *

 * Vault only supports ERC20 tokens, and will not accept any tokens that require

 * a tokenFallback or equivalent function (See ERC223, ERC777, etc.)

 */

contract Vault is StaticAccessControlled

{

    using SafeMath for uint256;



    // ============ Events ============



    event ExcessTokensWithdrawn(

        address indexed token,

        address indexed to,

        address caller

    );



    // ============ State Variables ============



    // Address of the TokenProxy contract. Used for moving tokens.

    address public TOKEN_PROXY;



    // Map from vault ID to map from token address to amount of that token attributed to the

    // particular vault ID.

    mapping (bytes32 => mapping (address => uint256)) public balances;



    // Map from token address to total amount of that token attributed to some account.

    mapping (address => uint256) public totalBalances;



    // ============ Constructor ============



    constructor(

        address proxy,

        uint256 gracePeriod

    )

        public

        StaticAccessControlled(gracePeriod)

    {

        TOKEN_PROXY = proxy;

    }



    // ============ Owner-Only State-Changing Functions ============



    /**

     * Allows the owner to withdraw any excess tokens sent to the vault by unconventional means,

     * including (but not limited-to) token airdrops. Any tokens moved to the vault by TOKEN_PROXY

     * will be accounted for and will not be withdrawable by this function.

     *

     * @param  token  ERC20 token address

     * @param  to     Address to transfer tokens to

     * @return        Amount of tokens withdrawn

     */

    function withdrawExcessToken(

        address token,

        address to

    )

        external

        onlyOwner

        returns (uint256)

    {

        uint256 actualBalance = TokenInteract.balanceOf(token, address(this));

        uint256 accountedBalance = totalBalances[token];

        uint256 withdrawableBalance = actualBalance.sub(accountedBalance);



        require(

            withdrawableBalance != 0,

            "Vault#withdrawExcessToken: Withdrawable token amount must be non-zero"

        );



        TokenInteract.transfer(token, to, withdrawableBalance);



        emit ExcessTokensWithdrawn(token, to, msg.sender);



        return withdrawableBalance;

    }



    // ============ Authorized-Only State-Changing Functions ============



    /**

     * Transfers tokens from an address (that has approved the proxy) to the vault.

     *

     * @param  id      The vault which will receive the tokens

     * @param  token   ERC20 token address

     * @param  from    Address from which the tokens will be taken

     * @param  amount  Number of the token to be sent

     */

    function transferToVault(

        bytes32 id,

        address token,

        address from,

        uint256 amount

    )

        external

        requiresAuthorization

    {

        // First send tokens to this contract

        TokenProxy(TOKEN_PROXY).transferTokens(

            token,

            from,

            address(this),

            amount

        );



        // Then increment balances

        balances[id][token] = balances[id][token].add(amount);

        totalBalances[token] = totalBalances[token].add(amount);



        // This should always be true. If not, something is very wrong

        assert(totalBalances[token] >= balances[id][token]);



        validateBalance(token);

    }



    /**

     * Transfers a certain amount of funds to an address.

     *

     * @param  id      The vault from which to send the tokens

     * @param  token   ERC20 token address

     * @param  to      Address to transfer tokens to

     * @param  amount  Number of the token to be sent

     */

    function transferFromVault(

        bytes32 id,

        address token,

        address to,

        uint256 amount

    )

        external

        requiresAuthorization

    {

        // Next line also asserts that (balances[id][token] >= amount);

        balances[id][token] = balances[id][token].sub(amount);



        // Next line also asserts that (totalBalances[token] >= amount);

        totalBalances[token] = totalBalances[token].sub(amount);



        // This should always be true. If not, something is very wrong

        assert(totalBalances[token] >= balances[id][token]);



        // Do the sending

        TokenInteract.transfer(token, to, amount); // asserts transfer succeeded



        // Final validation

        validateBalance(token);

    }



    // ============ Private Helper-Functions ============



    /**

     * Verifies that this contract is in control of at least as many tokens as accounted for

     *

     * @param  token  Address of ERC20 token

     */

    function validateBalance(

        address token

    )

        private

        view

    {

        // The actual balance could be greater than totalBalances[token] because anyone

        // can send tokens to the contract's address which cannot be accounted for

        assert(TokenInteract.balanceOf(token, address(this)) >= totalBalances[token]);

    }

}



// File: contracts/lib/TimestampHelper.sol



/**

 * @title TimestampHelper

 * @author dYdX

 *

 * Helper to get block timestamps in other formats

 */

library TimestampHelper {

    function getBlockTimestamp32()

        internal

        view

        returns (uint32)

    {

        // Should not still be in-use in the year 2106

        assert(uint256(uint32(block.timestamp)) == block.timestamp);



        assert(block.timestamp > 0);



        return uint32(block.timestamp);

    }

}



// File: contracts/margin/impl/MarginCommon.sol



/**

 * @title MarginCommon

 * @author dYdX

 *

 * This library contains common functions for implementations of public facing Margin functions

 */

library MarginCommon {

    using SafeMath for uint256;



    // ============ Structs ============



    struct Position {

        address owedToken;       // Immutable

        address heldToken;       // Immutable

        address lender;

        address owner;

        uint256 principal;

        uint256 requiredDeposit;

        uint32  callTimeLimit;   // Immutable

        uint32  startTimestamp;  // Immutable, cannot be 0

        uint32  callTimestamp;

        uint32  maxDuration;     // Immutable

        uint32  interestRate;    // Immutable

        uint32  interestPeriod;  // Immutable

    }



    struct LoanOffering {

        address   owedToken;

        address   heldToken;

        address   payer;

        address   owner;

        address   taker;

        address   positionOwner;

        address   feeRecipient;

        address   lenderFeeToken;

        address   takerFeeToken;

        LoanRates rates;

        uint256   expirationTimestamp;

        uint32    callTimeLimit;

        uint32    maxDuration;

        uint256   salt;

        bytes32   loanHash;

        bytes     signature;

    }



    struct LoanRates {

        uint256 maxAmount;

        uint256 minAmount;

        uint256 minHeldToken;

        uint256 lenderFee;

        uint256 takerFee;

        uint32  interestRate;

        uint32  interestPeriod;

    }



    // ============ Internal Implementation Functions ============



    function storeNewPosition(

        MarginState.State storage state,

        bytes32 positionId,

        Position memory position,

        address loanPayer

    )

        internal

    {

        assert(!positionHasExisted(state, positionId));

        assert(position.owedToken != address(0));

        assert(position.heldToken != address(0));

        assert(position.owedToken != position.heldToken);

        assert(position.owner != address(0));

        assert(position.lender != address(0));

        assert(position.maxDuration != 0);

        assert(position.interestPeriod <= position.maxDuration);

        assert(position.callTimestamp == 0);

        assert(position.requiredDeposit == 0);



        state.positions[positionId].owedToken = position.owedToken;

        state.positions[positionId].heldToken = position.heldToken;

        state.positions[positionId].principal = position.principal;

        state.positions[positionId].callTimeLimit = position.callTimeLimit;

        state.positions[positionId].startTimestamp = TimestampHelper.getBlockTimestamp32();

        state.positions[positionId].maxDuration = position.maxDuration;

        state.positions[positionId].interestRate = position.interestRate;

        state.positions[positionId].interestPeriod = position.interestPeriod;



        state.positions[positionId].owner = TransferInternal.grantPositionOwnership(

            positionId,

            (position.owner != msg.sender) ? msg.sender : address(0),

            position.owner

        );



        state.positions[positionId].lender = TransferInternal.grantLoanOwnership(

            positionId,

            (position.lender != loanPayer) ? loanPayer : address(0),

            position.lender

        );

    }



    function getPositionIdFromNonce(

        uint256 nonce

    )

        internal

        view

        returns (bytes32)

    {

        return keccak256(abi.encodePacked(msg.sender, nonce));

    }



    function getUnavailableLoanOfferingAmountImpl(

        MarginState.State storage state,

        bytes32 loanHash

    )

        internal

        view

        returns (uint256)

    {

        return state.loanFills[loanHash].add(state.loanCancels[loanHash]);

    }



    function cleanupPosition(

        MarginState.State storage state,

        bytes32 positionId

    )

        internal

    {

        delete state.positions[positionId];

        state.closedPositions[positionId] = true;

    }



    function calculateOwedAmount(

        Position storage position,

        uint256 closeAmount,

        uint256 endTimestamp

    )

        internal

        view

        returns (uint256)

    {

        uint256 timeElapsed = calculateEffectiveTimeElapsed(position, endTimestamp);



        return InterestImpl.getCompoundedInterest(

            closeAmount,

            position.interestRate,

            timeElapsed

        );

    }



    /**

     * Calculates time elapsed rounded up to the nearest interestPeriod

     */

    function calculateEffectiveTimeElapsed(

        Position storage position,

        uint256 timestamp

    )

        internal

        view

        returns (uint256)

    {

        uint256 elapsed = timestamp.sub(position.startTimestamp);



        // round up to interestPeriod

        uint256 period = position.interestPeriod;

        if (period > 1) {

            elapsed = MathHelpers.divisionRoundedUp(elapsed, period).mul(period);

        }



        // bound by maxDuration

        return Math.min256(

            elapsed,

            position.maxDuration

        );

    }



    function calculateLenderAmountForIncreasePosition(

        Position storage position,

        uint256 principalToAdd,

        uint256 endTimestamp

    )

        internal

        view

        returns (uint256)

    {

        uint256 timeElapsed = calculateEffectiveTimeElapsedForNewLender(position, endTimestamp);



        return InterestImpl.getCompoundedInterest(

            principalToAdd,

            position.interestRate,

            timeElapsed

        );

    }



    function getLoanOfferingHash(

        LoanOffering loanOffering

    )

        internal

        view

        returns (bytes32)

    {

        return keccak256(

            abi.encodePacked(

                address(this),

                loanOffering.owedToken,

                loanOffering.heldToken,

                loanOffering.payer,

                loanOffering.owner,

                loanOffering.taker,

                loanOffering.positionOwner,

                loanOffering.feeRecipient,

                loanOffering.lenderFeeToken,

                loanOffering.takerFeeToken,

                getValuesHash(loanOffering)

            )

        );

    }



    function getPositionBalanceImpl(

        MarginState.State storage state,

        bytes32 positionId

    )

        internal

        view

        returns(uint256)

    {

        return Vault(state.VAULT).balances(positionId, state.positions[positionId].heldToken);

    }



    function containsPositionImpl(

        MarginState.State storage state,

        bytes32 positionId

    )

        internal

        view

        returns (bool)

    {

        return state.positions[positionId].startTimestamp != 0;

    }



    function positionHasExisted(

        MarginState.State storage state,

        bytes32 positionId

    )

        internal

        view

        returns (bool)

    {

        return containsPositionImpl(state, positionId) || state.closedPositions[positionId];

    }



    function getPositionFromStorage(

        MarginState.State storage state,

        bytes32 positionId

    )

        internal

        view

        returns (Position storage)

    {

        Position storage position = state.positions[positionId];



        require(

            position.startTimestamp != 0,

            "MarginCommon#getPositionFromStorage: The position does not exist"

        );



        return position;

    }



    // ============ Private Helper-Functions ============



    /**

     * Calculates time elapsed rounded down to the nearest interestPeriod

     */

    function calculateEffectiveTimeElapsedForNewLender(

        Position storage position,

        uint256 timestamp

    )

        private

        view

        returns (uint256)

    {

        uint256 elapsed = timestamp.sub(position.startTimestamp);



        // round down to interestPeriod

        uint256 period = position.interestPeriod;

        if (period > 1) {

            elapsed = elapsed.div(period).mul(period);

        }



        // bound by maxDuration

        return Math.min256(

            elapsed,

            position.maxDuration

        );

    }



    function getValuesHash(

        LoanOffering loanOffering

    )

        private

        pure

        returns (bytes32)

    {

        return keccak256(

            abi.encodePacked(

                loanOffering.rates.maxAmount,

                loanOffering.rates.minAmount,

                loanOffering.rates.minHeldToken,

                loanOffering.rates.lenderFee,

                loanOffering.rates.takerFee,

                loanOffering.expirationTimestamp,

                loanOffering.salt,

                loanOffering.callTimeLimit,

                loanOffering.maxDuration,

                loanOffering.rates.interestRate,

                loanOffering.rates.interestPeriod

            )

        );

    }

}



// File: contracts/margin/interfaces/lender/CancelMarginCallDelegator.sol



/**

 * @title CancelMarginCallDelegator

 * @author dYdX

 *

 * Interface that smart contracts must implement in order to let other addresses cancel a

 * margin-call for a loan owned by the smart contract.

 *

 * NOTE: Any contract implementing this interface should also use OnlyMargin to control access

 *       to these functions

 */

interface CancelMarginCallDelegator {



    // ============ Public Interface functions ============



    /**

     * Function a contract must implement in order to let other addresses call cancelMarginCall().

     *

     * NOTE: If not returning zero (or not reverting), this contract must assume that Margin will

     * either revert the entire transaction or that the margin-call was successfully canceled.

     *

     * @param  canceler    Address of the caller of the cancelMarginCall function

     * @param  positionId  Unique ID of the position

     * @return             This address to accept, a different address to ask that contract

     */

    function cancelMarginCallOnBehalfOf(

        address canceler,

        bytes32 positionId

    )

        external

        /* onlyMargin */

        returns (address);

}



// File: contracts/margin/interfaces/lender/MarginCallDelegator.sol



/**

 * @title MarginCallDelegator

 * @author dYdX

 *

 * Interface that smart contracts must implement in order to let other addresses margin-call a loan

 * owned by the smart contract.

 *

 * NOTE: Any contract implementing this interface should also use OnlyMargin to control access

 *       to these functions

 */

interface MarginCallDelegator {



    // ============ Public Interface functions ============



    /**

     * Function a contract must implement in order to let other addresses call marginCall().

     *

     * NOTE: If not returning zero (or not reverting), this contract must assume that Margin will

     * either revert the entire transaction or that the loan was successfully margin-called.

     *

     * @param  caller         Address of the caller of the marginCall function

     * @param  positionId     Unique ID of the position

     * @param  depositAmount  Amount of heldToken deposit that will be required to cancel the call

     * @return                This address to accept, a different address to ask that contract

     */

    function marginCallOnBehalfOf(

        address caller,

        bytes32 positionId,

        uint256 depositAmount

    )

        external

        /* onlyMargin */

        returns (address);

}



// File: contracts/margin/impl/LoanImpl.sol



/**

 * @title LoanImpl

 * @author dYdX

 *

 * This library contains the implementation for the following functions of Margin:

 *

 *      - marginCall

 *      - cancelMarginCallImpl

 *      - cancelLoanOffering

 */

library LoanImpl {

    using SafeMath for uint256;



    // ============ Events ============



    /**

     * A position was margin-called

     */

    event MarginCallInitiated(

        bytes32 indexed positionId,

        address indexed lender,

        address indexed owner,

        uint256 requiredDeposit

    );



    /**

     * A margin call was canceled

     */

    event MarginCallCanceled(

        bytes32 indexed positionId,

        address indexed lender,

        address indexed owner,

        uint256 depositAmount

    );



    /**

     * A loan offering was canceled before it was used. Any amount less than the

     * total for the loan offering can be canceled.

     */

    event LoanOfferingCanceled(

        bytes32 indexed loanHash,

        address indexed payer,

        address indexed feeRecipient,

        uint256 cancelAmount

    );



    // ============ Public Implementation Functions ============



    function marginCallImpl(

        MarginState.State storage state,

        bytes32 positionId,

        uint256 requiredDeposit

    )

        public

    {

        MarginCommon.Position storage position =

            MarginCommon.getPositionFromStorage(state, positionId);



        require(

            position.callTimestamp == 0,

            "LoanImpl#marginCallImpl: The position has already been margin-called"

        );



        // Ensure lender consent

        marginCallOnBehalfOfRecurse(

            position.lender,

            msg.sender,

            positionId,

            requiredDeposit

        );



        position.callTimestamp = TimestampHelper.getBlockTimestamp32();

        position.requiredDeposit = requiredDeposit;



        emit MarginCallInitiated(

            positionId,

            position.lender,

            position.owner,

            requiredDeposit

        );

    }



    function cancelMarginCallImpl(

        MarginState.State storage state,

        bytes32 positionId

    )

        public

    {

        MarginCommon.Position storage position =

            MarginCommon.getPositionFromStorage(state, positionId);



        require(

            position.callTimestamp > 0,

            "LoanImpl#cancelMarginCallImpl: Position has not been margin-called"

        );



        // Ensure lender consent

        cancelMarginCallOnBehalfOfRecurse(

            position.lender,

            msg.sender,

            positionId

        );



        state.positions[positionId].callTimestamp = 0;

        state.positions[positionId].requiredDeposit = 0;



        emit MarginCallCanceled(

            positionId,

            position.lender,

            position.owner,

            0

        );

    }



    function cancelLoanOfferingImpl(

        MarginState.State storage state,

        address[9] addresses,

        uint256[7] values256,

        uint32[4]  values32,

        uint256    cancelAmount

    )

        public

        returns (uint256)

    {

        MarginCommon.LoanOffering memory loanOffering = parseLoanOffering(

            addresses,

            values256,

            values32

        );



        require(

            msg.sender == loanOffering.payer,

            "LoanImpl#cancelLoanOfferingImpl: Only loan offering payer can cancel"

        );

        require(

            loanOffering.expirationTimestamp > block.timestamp,

            "LoanImpl#cancelLoanOfferingImpl: Loan offering has already expired"

        );



        uint256 remainingAmount = loanOffering.rates.maxAmount.sub(

            MarginCommon.getUnavailableLoanOfferingAmountImpl(state, loanOffering.loanHash)

        );

        uint256 amountToCancel = Math.min256(remainingAmount, cancelAmount);



        // If the loan was already fully canceled, then just return 0 amount was canceled

        if (amountToCancel == 0) {

            return 0;

        }



        state.loanCancels[loanOffering.loanHash] =

            state.loanCancels[loanOffering.loanHash].add(amountToCancel);



        emit LoanOfferingCanceled(

            loanOffering.loanHash,

            loanOffering.payer,

            loanOffering.feeRecipient,

            amountToCancel

        );



        return amountToCancel;

    }



    // ============ Private Helper-Functions ============



    function marginCallOnBehalfOfRecurse(

        address contractAddr,

        address who,

        bytes32 positionId,

        uint256 requiredDeposit

    )

        private

    {

        // no need to ask for permission

        if (who == contractAddr) {

            return;

        }



        address newContractAddr =

            MarginCallDelegator(contractAddr).marginCallOnBehalfOf(

                msg.sender,

                positionId,

                requiredDeposit

            );



        if (newContractAddr != contractAddr) {

            marginCallOnBehalfOfRecurse(

                newContractAddr,

                who,

                positionId,

                requiredDeposit

            );

        }

    }



    function cancelMarginCallOnBehalfOfRecurse(

        address contractAddr,

        address who,

        bytes32 positionId

    )

        private

    {

        // no need to ask for permission

        if (who == contractAddr) {

            return;

        }



        address newContractAddr =

            CancelMarginCallDelegator(contractAddr).cancelMarginCallOnBehalfOf(

                msg.sender,

                positionId

            );



        if (newContractAddr != contractAddr) {

            cancelMarginCallOnBehalfOfRecurse(

                newContractAddr,

                who,

                positionId

            );

        }

    }



    // ============ Parsing Functions ============



    function parseLoanOffering(

        address[9] addresses,

        uint256[7] values256,

        uint32[4]  values32

    )

        private

        view

        returns (MarginCommon.LoanOffering memory)

    {

        MarginCommon.LoanOffering memory loanOffering = MarginCommon.LoanOffering({

            owedToken: addresses[0],

            heldToken: addresses[1],

            payer: addresses[2],

            owner: addresses[3],

            taker: addresses[4],

            positionOwner: addresses[5],

            feeRecipient: addresses[6],

            lenderFeeToken: addresses[7],

            takerFeeToken: addresses[8],

            rates: parseLoanOfferRates(values256, values32),

            expirationTimestamp: values256[5],

            callTimeLimit: values32[0],

            maxDuration: values32[1],

            salt: values256[6],

            loanHash: 0,

            signature: new bytes(0)

        });



        loanOffering.loanHash = MarginCommon.getLoanOfferingHash(loanOffering);



        return loanOffering;

    }



    function parseLoanOfferRates(

        uint256[7] values256,

        uint32[4] values32

    )

        private

        pure

        returns (MarginCommon.LoanRates memory)

    {

        MarginCommon.LoanRates memory rates = MarginCommon.LoanRates({

            maxAmount: values256[0],

            minAmount: values256[1],

            minHeldToken: values256[2],

            interestRate: values32[2],

            lenderFee: values256[3],

            takerFee: values256[4],

            interestPeriod: values32[3]

        });



        return rates;

    }

}