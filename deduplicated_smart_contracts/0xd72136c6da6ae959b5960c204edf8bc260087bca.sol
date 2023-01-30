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



// File: contracts/external/Maker/OasisV1/IMatchingMarketV1.sol



contract IMatchingMarketV1 is ISimpleMarketV1 {



    // ============ Structs ================



    struct sortInfo {

        uint256 next;  //points to id of next higher offer

        uint256 prev;  //points to id of previous lower offer

        uint256 delb;  //the blocknumber where this entry was marked for delete

    }



    // ============ Storage ================



    uint64 public close_time;



    bool public stopped;



    bool public buyEnabled;



    bool public matchingEnabled;



    mapping(uint256 => sortInfo) public _rank;



    mapping(address => mapping(address => uint)) public _best;



    mapping(address => mapping(address => uint)) public _span;



    mapping(address => uint) public _dust;



    mapping(uint256 => uint) public _near;



    mapping(bytes32 => bool) public _menu;



    // ============ Functions ================



    function make(

        address  pay_gem,

        address  buy_gem,

        uint128  pay_amt,

        uint128  buy_amt

    )

        public

        returns (bytes32);



    function take(

        bytes32 id,

        uint128 maxTakeAmount

    )

        public;



    function kill(

        bytes32 id

    )

        public;



    function offer(

        uint256 pay_amt,

        address pay_gem,

        uint256 buy_amt,

        address buy_gem

    )

        public

        returns (uint);



    function offer(

        uint256 pay_amt,

        address pay_gem,

        uint256 buy_amt,

        address buy_gem,

        uint256 pos

    )

        public

        returns (uint);



    function offer(

        uint256 pay_amt,

        address pay_gem,

        uint256 buy_amt,

        address buy_gem,

        uint256 pos,

        bool rounding

    )

        public

        returns (uint);



    function buy(

        uint256 id,

        uint256 amount

    )

        public

        returns (bool);



    function cancel(

        uint256 id

    )

        public

        returns (bool success);



    function insert(

        uint256 id,

        uint256 pos

    )

        public

        returns (bool);



    function del_rank(

        uint256 id

    )

        public

        returns (bool);



    function sellAllAmount(

        address pay_gem,

        uint256 pay_amt,

        address buy_gem,

        uint256 min_fill_amount

    )

        public

        returns (uint256 fill_amt);



    function buyAllAmount(

        address buy_gem,

        uint256 buy_amt,

        address pay_gem,

        uint256 max_fill_amount

    )

        public

        returns (uint256 fill_amt);



    // ============ Constant Functions ================



    function isTokenPairWhitelisted(

        address baseToken,

        address quoteToken

    )

        public

        view

        returns (bool);



    function getMinSell(

        address pay_gem

    )

        public

        view

        returns (uint);



    function getBestOffer(

        address sell_gem,

        address buy_gem

    )

        public

        view

        returns(uint);



    function getWorseOffer(

        uint256 id

    )

        public

        view

        returns(uint);



    function getBetterOffer(

        uint256 id

    )

        public

        view

        returns(uint);



    function getOfferCount(

        address sell_gem,

        address buy_gem

    )

        public

        view

        returns(uint);



    function getFirstUnsortedOffer()

        public

        view

        returns(uint);



    function getNextUnsortedOffer(

        uint256 id

    )

        public

        view

        returns(uint);



    function isOfferSorted(

        uint256 id

    )

        public

        view

        returns(bool);



    function getBuyAmount(

        address buy_gem,

        address pay_gem,

        uint256 pay_amt

    )

        public

        view

        returns (uint256 fill_amt);



    function getPayAmount(

        address pay_gem,

        address buy_gem,

        uint256 buy_amt

    )

        public

        view

        returns (uint256 fill_amt);



    function isClosed()

        public

        view

        returns (bool closed);



    function getTime()

        public

        view

        returns (uint64);

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



// File: contracts/margin/external/exchangewrappers/OasisV1MatchingExchangeWrapper.sol



/**

 * @title OasisV1MatchingExchangeWrapper

 * @author dYdX

 *

 * dYdX ExchangeWrapper to interface with Maker's MatchingMarket contract (Oasis exchange)

 */

contract OasisV1MatchingExchangeWrapper is

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



    address public MATCHING_MARKET;



    // ============ Constructor ============



    constructor(

        address matchingMarket

    )

        public

    {

        MATCHING_MARKET = matchingMarket;

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

        IMatchingMarketV1 market = IMatchingMarketV1(MATCHING_MARKET);



        // make sure that the exchange can take the tokens from this contract

        takerToken.ensureAllowance(address(market), requestedFillAmount);



        // do the exchange

        uint256 receivedMakerAmount = market.sellAllAmount(

            takerToken,

            requestedFillAmount,

            makerToken,

            0

        );



        // validate results

        requireBelowMaximumPrice(requestedFillAmount, receivedMakerAmount, orderData);



        // set allowance for the receiver

        makerToken.ensureAllowance(receiver, receivedMakerAmount);



        return receivedMakerAmount;

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

        IMatchingMarketV1 market = IMatchingMarketV1(MATCHING_MARKET);



        uint256 costInTakerToken = market.getPayAmount(

            takerToken,

            makerToken,

            desiredMakerToken

        );



        requireBelowMaximumPrice(costInTakerToken, desiredMakerToken, orderData);



        return costInTakerToken;

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

        (uint256 takerAmountRatio, uint256 makerAmountRatio) = getMaximumPrice(orderData);

        require(

            makerAmountRatio > 0,

            "OasisV1MatchingExchangeWrapper#getMaxMakerAmount: No maximum price given"

        );



        IMatchingMarketV1 market = IMatchingMarketV1(MATCHING_MARKET);

        uint256 offerId = market.getBestOffer(makerToken, takerToken);

        uint256 totalMakerAmount = 0;



        while (offerId != 0) {

            // get the offer info

            Offer memory offer = getOffer(market, offerId);



            assert(makerToken == offer.makerToken);

            assert(takerToken == offer.takerToken);



            // decide whether the offer satisfies the price ratio provided

            if (offer.makerAmount.mul(takerAmountRatio) < offer.takerAmount.mul(makerAmountRatio)) {

                break;

            } else {

                totalMakerAmount = totalMakerAmount.add(offer.makerAmount);

            }

            offerId = market.getWorseOffer(offerId);

        }



        return totalMakerAmount;

    }



    // ============ Private Functions ============



    function requireBelowMaximumPrice(

        uint256 takerAmount,

        uint256 makerAmount,

        bytes orderData

    )

        private

        pure

    {

        (uint256 takerAmountRatio, uint256 makerAmountRatio) = getMaximumPrice(orderData);

        if (takerAmountRatio > 0 || makerAmountRatio > 0) {

            // all amounts have previously been required to fit within 128 bits each

            require(

                takerAmount.mul(makerAmountRatio) <= makerAmount.mul(takerAmountRatio),

                "OasisV1MatchingExchangeWrapper:#requireBelowMaximumPrice: price is too high"

            );

        }

    }



    function getOffer(

        IMatchingMarketV1 market,

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



    // ============ Parsing Functions ============



    function getMaximumPrice(

        bytes orderData

    )

        private

        pure

        returns (uint256, uint256)

    {

        uint256 takerAmountRatio = 0;

        uint256 makerAmountRatio = 0;



        if (orderData.length > 0) {

            require(

                orderData.length == 64,

                "OasisV1MatchingExchangeWrapper:#getMaximumPrice: orderData is not the right length"

            );



            /* solium-disable-next-line security/no-inline-assembly */

            assembly {

                takerAmountRatio := mload(add(orderData, 32))

                makerAmountRatio := mload(add(orderData, 64))

            }



            // require numbers to fit within 128 bits to prevent overflow when checking bounds

            require(

                uint128(takerAmountRatio) == takerAmountRatio,

                "OasisV1MatchingExchangeWrapper:#getMaximumPrice: takerAmountRatio > 128 bits"

            );

            require(

                uint128(makerAmountRatio) == makerAmountRatio,

                "OasisV1MatchingExchangeWrapper:#getMaximumPrice: makerAmountRatio > 128 bits"

            );



            // since this is a price ratio, the denominator cannot be zero

            require(

                makerAmountRatio > 0,

                "OasisV1MatchingExchangeWrapper:#getMaximumPrice: makerAmountRatio cannot be zero"

            );

        }



        return (takerAmountRatio, makerAmountRatio);

    }

}