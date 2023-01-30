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