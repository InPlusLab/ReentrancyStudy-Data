/**
 *Submitted for verification at Etherscan.io on 2019-09-18
*/

/*

    Copyright 2019 The Hydro Protocol Foundation

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

pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;
interface IEth2Dai{
    function isClosed()
        external
        view
        returns (bool);

    function buyEnabled()
        external
        view
        returns (bool);

    function matchingEnabled()
        external
        view
        returns (bool);

    function getBuyAmount(
        address buy_gem,
        address pay_gem,
        uint256 pay_amt
    )
        external
        view
        returns (uint256);

    function getPayAmount(
        address pay_gem,
        address buy_gem,
        uint256 buy_amt
    )
        external
        view
        returns (uint256);
}

interface IMakerDaoOracle{
    function peek()
        external
        view
        returns (bytes32, bool);
}

interface IStandardToken {
    function transfer(
        address _to,
        uint256 _amount
    )
        external
        returns (bool);

    function balanceOf(
        address _owner)
        external
        view
        returns (uint256 balance);

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )
        external
        returns (bool);

    function approve(
        address _spender,
        uint256 _amount
    )
        external
        returns (bool);

    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /** @dev The Ownable constructor sets the original `owner` of the contract to the sender account. */
    constructor()
        internal
    {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /** @return the address of the owner. */
    function owner()
        public
        view
        returns(address)
    {
        return _owner;
    }

    /** @dev Throws if called by any account other than the owner. */
    modifier onlyOwner() {
        require(isOwner(), "NOT_OWNER");
        _;
    }

    /** @return true if `msg.sender` is the owner of the contract. */
    function isOwner()
        public
        view
        returns(bool)
    {
        return msg.sender == _owner;
    }

    /** @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership()
        public
        onlyOwner
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /** @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(
        address newOwner
    )
        public
        onlyOwner
    {
        require(newOwner != address(0), "INVALID_OWNER");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    // Multiplies two numbers, reverts on overflow.
    function mul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    // Integer division of two numbers truncating the quotient, reverts on division by zero.
    function div(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    // Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    function sub(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function sub(
        int256 a,
        uint256 b
    )
        internal
        pure
        returns (int256)
    {
        require(b <= 2**255-1, "INT256_SUB_ERROR");
        int256 c = a - int256(b);
        require(c <= a, "INT256_SUB_ERROR");
        return c;
    }

    // Adds two numbers, reverts on overflow.
    function add(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function add(
        int256 a,
        uint256 b
    )
        internal
        pure
        returns (int256)
    {
        require(b <= 2**255 - 1, "INT256_ADD_ERROR");
        int256 c = a + int256(b);
        require(c >= a, "INT256_ADD_ERROR");
        return c;
    }

    // Divides two numbers and returns the remainder (unsigned integer modulo), reverts when dividing by zero.
    function mod(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        require(b != 0, "MOD_ERROR");
        return a % b;
    }

    /**
     * Check the amount of precision lost by calculating multiple * (numerator / denominator). To
     * do this, we check the remainder and make sure it's proportionally less than 0.1%. So we have:
     *
     *     ((numerator * multiple) % denominator)     1
     *     -------------------------------------- < ----
     *              numerator * multiple            1000
     *
     * To avoid further division, we can move the denominators to the other sides and we get:
     *
     *     ((numerator * multiple) % denominator) * 1000 < numerator * multiple
     *
     * Since we want to return true if there IS a rounding error, we simply flip the sign and our
     * final equation becomes:
     *
     *     ((numerator * multiple) % denominator) * 1000 >= numerator * multiple
     *
     * @param numerator The numerator of the proportion
     * @param denominator The denominator of the proportion
     * @param multiple The amount we want a proportion of
     * @return Boolean indicating if there is a rounding error when calculating the proportion
     */
    function isRoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 multiple
    )
        internal
        pure
        returns (bool)
    {
        // numerator.mul(multiple).mod(denominator).mul(1000) >= numerator.mul(multiple)
        return mul(mod(mul(numerator, multiple), denominator), 1000) >= mul(numerator, multiple);
    }

    /**
     * Takes an amount (multiple) and calculates a proportion of it given a numerator/denominator
     * pair of values. The final value will be rounded down to the nearest integer value.
     *
     * This function will revert the transaction if rounding the final value down would lose more
     * than 0.1% precision.
     *
     * @param numerator The numerator of the proportion
     * @param denominator The denominator of the proportion
     * @param multiple The amount we want a proportion of
     * @return The final proportion of multiple rounded down
     */
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 multiple
    )
        internal
        pure
        returns (uint256)
    {
        require(!isRoundingError(numerator, denominator, multiple), "ROUNDING_ERROR");
        // numerator.mul(multiple).div(denominator)
        return div(mul(numerator, multiple), denominator);
    }

    /**
     * Returns the smaller integer of the two passed in.
     *
     * @param a Unsigned integer
     * @param b Unsigned integer
     * @return The smaller of the two integers
     */
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
}

contract DaiPriceOracle is Ownable{
    using SafeMath for uint256;

    uint256 public price;

    uint256 constant ONE = 10**18;

    IMakerDaoOracle public constant makerDaoOracle = IMakerDaoOracle(0x729D19f657BD0614b4985Cf1D82531c67569197B);
    IStandardToken public constant DAI = IStandardToken(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    IEth2Dai public constant Eth2Dai = IEth2Dai(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);

    address public constant UNISWAP = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public constant eth2daiETHAmount = 10 ether;
    uint256 public constant eth2daiMaxSpread = 2 * ONE / 100; // 2.00%
    uint256 public constant uniswapMinETHAmount = 2000 ether;

    event UpdatePrice(uint256 newPrice);

    uint256 public minPrice;
    uint256 public maxPrice;

    constructor (
        uint256 _minPrice,
        uint256 _maxPrice
    )
        public
    {
        require(_minPrice <= _maxPrice, "WRONG_PARAMS");
        minPrice = _minPrice;
        maxPrice = _maxPrice;
    }

    function getPrice(
        address asset
    )
        external
        view
        returns (uint256)
    {
        require(asset == address(DAI), "ASSET_NOT_MATCH");
        return price;
    }

    function adminSetPrice(
        uint256 _price
    )
        external
        onlyOwner
    {
        if (!updatePrice()){
            price = _price;
        }

        emit UpdatePrice(price);
    }

    function adminSetParams(
        uint256 _minPrice,
        uint256 _maxPrice
    )
        external
        onlyOwner
    {
        require(_minPrice <= _maxPrice, "WRONG_PARAMS");
        minPrice = _minPrice;
        maxPrice = _maxPrice;
    }

    function updatePrice()
        public
        returns (bool)
    {
        uint256 _price = peek();

        if (_price == 0) {
            return false;
        }

        if (_price == price) {
            return true;
        }

        if (_price > maxPrice) {
            _price = maxPrice;
        } else if (_price < minPrice) {
            _price = minPrice;
        }

        price = _price;
        emit UpdatePrice(price);

        return true;
    }

    function peek()
        public
        view
        returns (uint256 _price)
    {
        uint256 makerDaoPrice = getMakerDaoPrice();

        if (makerDaoPrice == 0) {
            return _price;
        }

        uint256 eth2daiPrice = getEth2DaiPrice();

        if (eth2daiPrice > 0) {
            _price = makerDaoPrice.mul(ONE).div(eth2daiPrice);
            return _price;
        }

        uint256 uniswapPrice = getUniswapPrice();

        if (uniswapPrice > 0) {
            _price = makerDaoPrice.mul(ONE).div(uniswapPrice);
            return _price;
        }

        return _price;
    }

    function getEth2DaiPrice()
        public
        view
        returns (uint256)
    {
        if (Eth2Dai.isClosed() || !Eth2Dai.buyEnabled() || !Eth2Dai.matchingEnabled()) {
            return 0;
        }

        uint256 bidDai = Eth2Dai.getBuyAmount(address(DAI), WETH, eth2daiETHAmount);
        uint256 askDai = Eth2Dai.getPayAmount(address(DAI), WETH, eth2daiETHAmount);

        uint256 bidPrice = bidDai.mul(ONE).div(eth2daiETHAmount);
        uint256 askPrice = askDai.mul(ONE).div(eth2daiETHAmount);

        uint256 spread = askPrice.mul(ONE).div(bidPrice).sub(ONE);

        if (spread > eth2daiMaxSpread) {
            return 0;
        } else {
            return bidPrice.add(askPrice).div(2);
        }
    }

    function getUniswapPrice()
        public
        view
        returns (uint256)
    {
        uint256 ethAmount = UNISWAP.balance;
        uint256 daiAmount = DAI.balanceOf(UNISWAP);
        uint256 uniswapPrice = daiAmount.mul(10**18).div(ethAmount);

        if (ethAmount < uniswapMinETHAmount) {
            return 0;
        } else {
            return uniswapPrice;
        }
    }

    function getMakerDaoPrice()
        public
        view
        returns (uint256)
    {
        (bytes32 value, bool has) = makerDaoOracle.peek();

        if (has) {
            return uint256(value);
        } else {
            return 0;
        }
    }
}