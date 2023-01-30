/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



/* ===============================================

* Flattened with Solidifier by Coinage

* 

* https://solidifier.coina.ge

* ===============================================

*/





////////////////// SafeMath.sol //////////////////



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

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

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}





////////////////// SafeDecimalMath.sol //////////////////



/*



-----------------------------------------------------------------

FILE INFORMATION

-----------------------------------------------------------------



file:       SafeDecimalMath.sol

version:    2.0

author:     Kevin Brown

            Gavin Conway

date:       2018-10-18



-----------------------------------------------------------------

MODULE DESCRIPTION

-----------------------------------------------------------------



A library providing safe mathematical operations for division and

multiplication with the capability to round or truncate the results

to the nearest increment. Operations can return a standard precision

or high precision decimal. High precision decimals are useful for

example when attempting to calculate percentages or fractions

accurately.



-----------------------------------------------------------------

*/





/**

 * @title Safely manipulate unsigned fixed-point decimals at a given precision level.

 * @dev Functions accepting uints in this contract and derived contracts

 * are taken to be such fixed point decimals of a specified precision (either standard

 * or high).

 */

library SafeDecimalMath {



    using SafeMath for uint;



    /* Number of decimal places in the representations. */

    uint8 public constant decimals = 18;

    uint8 public constant highPrecisionDecimals = 27;



    /* The number representing 1.0. */

    uint public constant UNIT = 10 ** uint(decimals);



    /* The number representing 1.0 for higher fidelity numbers. */

    uint public constant PRECISE_UNIT = 10 ** uint(highPrecisionDecimals);

    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10 ** uint(highPrecisionDecimals - decimals);



    /** 

     * @return Provides an interface to UNIT.

     */

    function unit()

        external

        pure

        returns (uint)

    {

        return UNIT;

    }



    /** 

     * @return Provides an interface to PRECISE_UNIT.

     */

    function preciseUnit()

        external

        pure 

        returns (uint)

    {

        return PRECISE_UNIT;

    }



    /**

     * @return The result of multiplying x and y, interpreting the operands as fixed-point

     * decimals.

     * 

     * @dev A unit factor is divided out after the product of x and y is evaluated,

     * so that product must be less than 2**256. As this is an integer division,

     * the internal division always rounds down. This helps save on gas. Rounding

     * is more expensive on gas.

     */

    function multiplyDecimal(uint x, uint y)

        internal

        pure

        returns (uint)

    {

        /* Divide by UNIT to remove the extra factor introduced by the product. */

        return x.mul(y) / UNIT;

    }



    /**

     * @return The result of safely multiplying x and y, interpreting the operands

     * as fixed-point decimals of the specified precision unit.

     *

     * @dev The operands should be in the form of a the specified unit factor which will be

     * divided out after the product of x and y is evaluated, so that product must be

     * less than 2**256.

     *

     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.

     * Rounding is useful when you need to retain fidelity for small decimal numbers

     * (eg. small fractions or percentages).

     */

    function _multiplyDecimalRound(uint x, uint y, uint precisionUnit)

        private

        pure

        returns (uint)

    {

        /* Divide by UNIT to remove the extra factor introduced by the product. */

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);



        if (quotientTimesTen % 10 >= 5) {

            quotientTimesTen += 10;

        }



        return quotientTimesTen / 10;

    }



    /**

     * @return The result of safely multiplying x and y, interpreting the operands

     * as fixed-point decimals of a precise unit.

     *

     * @dev The operands should be in the precise unit factor which will be

     * divided out after the product of x and y is evaluated, so that product must be

     * less than 2**256.

     *

     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.

     * Rounding is useful when you need to retain fidelity for small decimal numbers

     * (eg. small fractions or percentages).

     */

    function multiplyDecimalRoundPrecise(uint x, uint y)

        internal

        pure

        returns (uint)

    {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);

    }



    /**

     * @return The result of safely multiplying x and y, interpreting the operands

     * as fixed-point decimals of a standard unit.

     *

     * @dev The operands should be in the standard unit factor which will be

     * divided out after the product of x and y is evaluated, so that product must be

     * less than 2**256.

     *

     * Unlike multiplyDecimal, this function rounds the result to the nearest increment.

     * Rounding is useful when you need to retain fidelity for small decimal numbers

     * (eg. small fractions or percentages).

     */

    function multiplyDecimalRound(uint x, uint y)

        internal

        pure

        returns (uint)

    {

        return _multiplyDecimalRound(x, y, UNIT);

    }



    /**

     * @return The result of safely dividing x and y. The return value is a high

     * precision decimal.

     * 

     * @dev y is divided after the product of x and the standard precision unit

     * is evaluated, so the product of x and UNIT must be less than 2**256. As

     * this is an integer division, the result is always rounded down.

     * This helps save on gas. Rounding is more expensive on gas.

     */

    function divideDecimal(uint x, uint y)

        internal

        pure

        returns (uint)

    {

        /* Reintroduce the UNIT factor that will be divided out by y. */

        return x.mul(UNIT).div(y);

    }



    /**

     * @return The result of safely dividing x and y. The return value is as a rounded

     * decimal in the precision unit specified in the parameter.

     *

     * @dev y is divided after the product of x and the specified precision unit

     * is evaluated, so the product of x and the specified precision unit must

     * be less than 2**256. The result is rounded to the nearest increment.

     */

    function _divideDecimalRound(uint x, uint y, uint precisionUnit)

        private

        pure

        returns (uint)

    {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);



        if (resultTimesTen % 10 >= 5) {

            resultTimesTen += 10;

        }



        return resultTimesTen / 10;

    }



    /**

     * @return The result of safely dividing x and y. The return value is as a rounded

     * standard precision decimal.

     *

     * @dev y is divided after the product of x and the standard precision unit

     * is evaluated, so the product of x and the standard precision unit must

     * be less than 2**256. The result is rounded to the nearest increment.

     */

    function divideDecimalRound(uint x, uint y)

        internal

        pure

        returns (uint)

    {

        return _divideDecimalRound(x, y, UNIT);

    }



    /**

     * @return The result of safely dividing x and y. The return value is as a rounded

     * high precision decimal.

     *

     * @dev y is divided after the product of x and the high precision unit

     * is evaluated, so the product of x and the high precision unit must

     * be less than 2**256. The result is rounded to the nearest increment.

     */

    function divideDecimalRoundPrecise(uint x, uint y)

        internal

        pure

        returns (uint)

    {

        return _divideDecimalRound(x, y, PRECISE_UNIT);

    }



    /**

     * @dev Convert a standard decimal representation to a high precision one.

     */

    function decimalToPreciseDecimal(uint i)

        internal

        pure

        returns (uint)

    {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);

    }



    /**

     * @dev Convert a high precision decimal to a standard decimal representation.

     */

    function preciseDecimalToDecimal(uint i)

        internal

        pure

        returns (uint)

    {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);



        if (quotientTimesTen % 10 >= 5) {

            quotientTimesTen += 10;

        }



        return quotientTimesTen / 10;

    }



}