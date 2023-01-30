/**
 *Submitted for verification at Etherscan.io on 2020-11-20
*/

pragma solidity ^0.5.16;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface FRT {
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function governance() external view returns (address);

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function monetaryPolicy() external view returns (address);

    function name() external view returns (string memory);

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        returns (uint256);

    function setGovernance(address _governance) external;

    function setMonetaryPolicy(address monetaryPolicy_) external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface FRTTreasury {
    function sendReward(uint256 rate, address account) external;
}

contract FRTRebaser {
    using SafeMath for uint256;

    uint256 public constant PERIOD = 10 minutes; // will be 10 minutes in REAL CONTRACT

    IUniswapV2Pair public pair;
    FRT public token;
    FRTTreasury public treasury;

    uint256 public starttime = 1606266000; // EDIT_ME: 2020-11-25UTC:01:00+00:00
    uint256 public price0CumulativeLast = 0;
    uint32 public blockTimestampLast = 0;
    uint224 public price0RawAverage = 0;
    address public lastRebaser = 0x0000000000000000000000000000000000000000;

    uint256 public epoch = 0;

    constructor(address _pair, address _treasury) public {
        pair = IUniswapV2Pair(_pair);
        treasury = FRTTreasury(_treasury);
        token = FRT(pair.token0());
        price0CumulativeLast = pair.price0CumulativeLast();
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'NO_RESERVES');
    }

    event LogRebase(uint indexed epoch, uint totalSupply, uint256 rand, address account);

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);
    
    function rebaseTime() public view returns (bool) {
       return block.timestamp % 3600 < 3 * 60;
    }

    function toInt256Safe(uint256 a) internal pure returns (int256) {
        require(a <= MAX_INT256);
        return int256(a);
    }

    //Only callers that hold FRT can rebase.
    function hasFRT() private view returns (bool) {
        if (token.balanceOf(msg.sender) > 0) {
            return true;
        } else {
            return false;
        }
    }

    function rand() private view returns (uint256) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (now)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (now)) +
                        block.number
                )
            )
        );

        if ((seed - ((seed / 10) * 10)) == 0 || (seed - ((seed / 10) * 10)) > 9 ) {
            return 1;
        } else {
            return (seed - ((seed / 10) * 10));
        }
    }

    function rebase() external {
       // uint256 timestamp = block.timestamp;
        require(block.timestamp > starttime, 'REBASE IS NOT ACTIVE YET');
        require(lastRebaser != msg.sender, 'YOU_ALREADY_REBASED');
        require(rebaseTime(), 'IS_NOT_TIME_TO_REBASE'); // rebase can only happen between XX:00:00 ~ XX:02:59 of every hour
        require(hasFRT(), 'YOU_DO_NOT_HOLD_FRT'); //Only holders can rebase.
        uint256 price0Cumulative = pair.price0CumulativeLast();
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestamp;
        (reserve0, reserve1, blockTimestamp) = pair.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'NO_RESERVES');

        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= PERIOD, 'PERIOD_NOT_ELAPSED');

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0RawAverage = uint224(
            (price0Cumulative - price0CumulativeLast) / timeElapsed
        );

        price0CumulativeLast = price0Cumulative;
        blockTimestampLast = blockTimestamp;

        // compute rebase

        uint256 price = price0RawAverage;
        uint256 priceComp = 0;
        price = price.mul(10**5).div(2**112); // DAI decimals = 18, 100000 = 10^5, 18 - 18 + 5 = 5   ***Important***
        priceComp = price.mul(10**3).div(2**112);

        require(priceComp != 1000 || priceComp != 999, 'NO_NEED_TO_REBASE'); // don't rebase if price is close to 1.00000

        // rebase & sync
        uint256 random = rand();
        if (price > 100000) {
            // positive rebase
            uint256 delta = price.sub(100000);
            token.rebase(
                epoch,
                toInt256Safe(token.totalSupply().mul(delta).div(100000 * 10))
            ); // rebase using 10% of price delta
            treasury.sendReward(random, msg.sender);
        } else {
            // negative rebase
            uint256 delta = 100000;
            delta = delta.sub(price);
            token.rebase(
                epoch,
                -toInt256Safe(token.totalSupply().mul(delta).div(100000 * 2))
            ); // Use 2% of delta
            treasury.sendReward(random, msg.sender);
        }

        pair.sync();
        epoch = epoch.add(1);
        lastRebaser = msg.sender;
        emit LogRebase(epoch, token.totalSupply(), random, msg.sender);
    }
}