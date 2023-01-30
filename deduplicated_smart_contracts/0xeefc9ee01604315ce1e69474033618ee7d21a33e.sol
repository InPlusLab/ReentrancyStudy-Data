/**

 *Submitted for verification at Etherscan.io on 2018-11-20

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



// File: contracts/external/Maker/OasisV1/ISimpleMarketV1.sol



contract ISimpleMarketV1 {



    // ============ Structs ================



    struct OfferInfo {

        uint256     pay_amt;

        address  pay_gem;

        uint256     buy_amt;

        address  buy_gem;

        address  owner;

        uint64   timestamp;

    }



    // ============ Storage ================



    uint256 public last_offer_id;



    mapping (uint256 => OfferInfo) public offers;



    // ============ Functions ================



    function isActive(

        uint256 id

    )

        public

        view

        returns (bool active );



    function getOwner(

        uint256 id

    )

        public

        view

        returns (address owner);



    function getOffer(

        uint256 id

    )

        public

        view

        returns (uint, address, uint, address);



    function bump(

        bytes32 id_

    )

        public;



    function buy(

        uint256 id,

        uint256 quantity

    )

        public

        returns (bool);



    function cancel(

        uint256 id

    )

        public

        returns (bool success);



    function kill(

        bytes32 id

    )

        public;



    function make(

        address  pay_gem,

        address  buy_gem,

        uint128  pay_amt,

        uint128  buy_amt

    )

        public

        returns (bytes32 id);



    function offer(

        uint256 pay_amt,

        address pay_gem,

        uint256 buy_amt,

        address buy_gem

    )

        public

        returns (uint256 id);



    function take(

        bytes32 id,

        uint128 maxTakeAmount

    )

        public;

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

 * This library contains basic functions for interacting with ERC20 tokens

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



// File: contracts/lib/AdvancedTokenInteract.sol



/**

 * @title AdvancedTokenInteract

 * @author dYdX

 *

 * This library contains advanced functions for interacting with ERC20 tokens

 */

library AdvancedTokenInteract {

    using TokenInteract for address;



    /**

     * Checks if the spender has some amount of allowance. If it doesn't, then set allowance at

     * the maximum value.

     *

     * @param  token    Address of the ERC20 token

     * @param  spender  Argument of the allowance function

     * @param  amount   The minimum amount of allownce the the spender should be guaranteed

     */

    function ensureAllowance(

        address token,

        address spender,

        uint256 amount

    )

        internal

    {

        if (token.allowance(address(this), spender) < amount) {

            token.approve(spender, MathHelpers.maxUint256());

        }

    }

}



// File: contracts/margin/interfaces/ExchangeReader.sol



/**

 * @title ExchangeReader

 * @author dYdX

 *

 * Contract interface that wraps an exchange and provides information about the current state of the

 * exchange or particular orders

 */

interface ExchangeReader {



    // ============ Public Functions ============



    /**

     * Get the maxmimum amount of makerToken for some order

     *

     * @param  makerToken           Address of makerToken, the token to receive

     * @param  takerToken           Address of takerToken, the token to pay

     * @param  orderData            Arbitrary bytes data for any information to pass to the exchange

     * @return                      Maximum amount of makerToken

     */

    function getMaxMakerAmount(

        address makerToken,

        address takerToken,

        bytes orderData

    )

        external

        view

        returns (uint256);

}



// File: contracts/margin/interfaces/ExchangeWrapper.sol



/**

 * @title ExchangeWrapper

 * @author dYdX

 *

 * Contract interface that Exchange Wrapper smart contracts must implement in order to interface

 * with other smart contracts through a common interface.

 */

interface ExchangeWrapper {



    // ============ Public Functions ============



    /**

     * Exchange some amount of takerToken for makerToken.

     *

     * @param  tradeOriginator      Address of the initiator of the trade (however, this value

     *                              cannot always be trusted as it is set at the discretion of the

     *                              msg.sender)

     * @param  receiver             Address to set allowance on once the trade has completed

     * @param  makerToken           Address of makerToken, the token to receive

     * @param  takerToken           Address of takerToken, the token to pay

     * @param  requestedFillAmount  Amount of takerToken being paid

     * @param  orderData            Arbitrary bytes data for any information to pass to the exchange

     * @return                      The amount of makerToken received

     */

    function exchange(

        address tradeOriginator,

        address receiver,

        address makerToken,

        address takerToken,

        uint256 requestedFillAmount,

        bytes orderData

    )

        external

        returns (uint256);



    /**

     * Get amount of takerToken required to buy a certain amount of makerToken for a given trade.

     * Should match the takerToken amount used in exchangeForAmount. If the order cannot provide

     * exactly desiredMakerToken, then it must return the price to buy the minimum amount greater

     * than desiredMakerToken

     *

     * @param  makerToken         Address of makerToken, the token to receive

     * @param  takerToken         Address of takerToken, the token to pay

     * @param  desiredMakerToken  Amount of makerToken requested

     * @param  orderData          Arbitrary bytes data for any information to pass to the exchange

     * @return                    Amount of takerToken the needed to complete the transaction

     */

    function getExchangeCost(

        address makerToken,

        address takerToken,

        uint256 desiredMakerToken,

        bytes orderData

    )

        external

        view

        returns (uint256);

}



// File: contracts/margin/external/exchangewrappers/OasisV1SimpleExchangeWrapper.sol



/**

 * @title OasisV1SimpleExchangeWrapper

 * @author dYdX

 *

 * dYdX ExchangeWrapper to interface with Maker's (Oasis exchange) SimpleMarket or MatchingMarket

 * contracts to trade using a specific offer. Since any MatchingMarket is also a SimpleMarket, this

 * ExchangeWrapper can also be used for any MatchingMarket.

 */

contract OasisV1SimpleExchangeWrapper is

    ExchangeWrapper,

    ExchangeReader

{

    using SafeMath for uint256;

    using TokenInteract for address;

    using AdvancedTokenInteract for address;



    // ============ Structs ============



    struct Offer {

        uint256 makerAmount;

        address makerToken;

        uint256 takerAmount;

        address takerToken;

    }



    // ============ State Variables ============



    address public SIMPLE_MARKET;



    // ============ Constructor ============



    constructor(

        address simpleMarket

    )

        public

    {

        SIMPLE_MARKET = simpleMarket;

    }



    // ============ Public Functions ============



    function exchange(

        address /*tradeOriginator*/,

        address receiver,

        address makerToken,

        address takerToken,

        uint256 requestedFillAmount,

        bytes orderData

    )

        external

        returns (uint256)

    {

        ISimpleMarketV1 market = ISimpleMarketV1(SIMPLE_MARKET);

        uint256 offerId = bytesToOfferId(orderData);



        Offer memory offer = getOffer(market, offerId);

        verifyOffer(offer, makerToken, takerToken);



        // calculate maximum amount of makerToken to receive given requestedFillAmount

        uint256 makerAmount = getInversePartialAmount(

            offer.takerAmount,

            offer.makerAmount,

            requestedFillAmount

        );



        // make sure that the exchange can take the tokens from this contract

        takerToken.ensureAllowance(address(market), requestedFillAmount);



        // do the exchange

        require(

            market.buy(offerId, makerAmount),

            "OasisV1SimpleExchangeWrapper#exchange: Buy failed"

        );



        // set allowance for the receiver

        makerToken.ensureAllowance(receiver, makerAmount);



        return makerAmount;

    }



    function getExchangeCost(

        address makerToken,

        address takerToken,

        uint256 desiredMakerToken,

        bytes orderData

    )

        external

        view

        returns (uint256)

    {

        ISimpleMarketV1 market = ISimpleMarketV1(SIMPLE_MARKET);

        Offer memory offer = getOffer(market, bytesToOfferId(orderData));

        verifyOffer(offer, makerToken, takerToken);



        require(

            desiredMakerToken <= offer.makerAmount,

            "OasisV1SimpleExchangeWrapper#getExchangeCost: Offer is not large enough"

        );



        // return takerToken cost of desiredMakerToken

        return MathHelpers.getPartialAmount(

            desiredMakerToken,

            offer.makerAmount,

            offer.takerAmount

        );

    }



    function getMaxMakerAmount(

        address makerToken,

        address takerToken,

        bytes orderData

    )

        external

        view

        returns (uint256)

    {

        ISimpleMarketV1 market = ISimpleMarketV1(SIMPLE_MARKET);

        Offer memory offer = getOffer(market, bytesToOfferId(orderData));

        verifyOffer(offer, makerToken, takerToken);



        return offer.makerAmount;

    }



    // ============ Private Functions ============



    /**

     * Calculate the greatest target amount that can be passed into getPartialAmount such that a

     * certain result is achieved.

     *

     * @param  numerator    The numerator of the getPartialAmount function

     * @param  denominator  The denominator of the getPartialAmount function

     * @param  result       The result of the getPartialAmount function

     * @return              The largest value of target such that the result is achieved

     */

    function getInversePartialAmount(

        uint256 numerator,

        uint256 denominator,

        uint256 result

    )

        private

        pure

        returns (uint256)

    {

        uint256 temp = result.add(1).mul(denominator);

        uint256 target = temp.div(numerator);



        if (target.mul(numerator) == temp) {

            target = target.sub(1);

        }



        return target;

    }



    function getOffer(

        ISimpleMarketV1 market,

        uint256 offerId

    )

        private

        view

        returns (Offer memory)

    {

        (

            uint256 offerMakerAmount,

            address offerMakerToken,

            uint256 offerTakerAmount,

            address offerTakerToken

        ) = market.getOffer(offerId);



        return Offer({

            makerAmount: offerMakerAmount,

            makerToken: offerMakerToken,

            takerAmount: offerTakerAmount,

            takerToken: offerTakerToken

        });

    }



    function verifyOffer(

        Offer memory offer,

        address makerToken,

        address takerToken

    )

        private

        pure

    {

        require(

            makerToken == offer.makerToken,

            "OasisV1SimpleExchangeWrapper#verifyOffer: offer makerToken does not match"

        );

        require(

            takerToken == offer.takerToken,

            "OasisV1SimpleExchangeWrapper#verifyOffer: offer takerToken does not match"

        );

    }



    function bytesToOfferId(

        bytes orderData

    )

        private

        pure

        returns (uint256)

    {

        require(

            orderData.length == 32,

            "OasisV1SimpleExchangeWrapper:#bytesToOfferId: orderData is not the right length"

        );



        uint256 offerId;



        /* solium-disable-next-line security/no-inline-assembly */

        assembly {

            offerId := mload(add(orderData, 32))

        }



        return offerId;

    }

}