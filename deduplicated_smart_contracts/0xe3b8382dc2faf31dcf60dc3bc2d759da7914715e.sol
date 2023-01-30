/**
 *Submitted for verification at Etherscan.io on 2020-12-19
*/

// File: contracts\GFarmTokenInterface.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface GFarmTokenInterface{
	function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function burn(address from, uint256 amount) external;
    function mint(address to, uint256 amount) external;
}

// File: contracts\GFarmNFTInterface.sol

pragma solidity 0.7.5;

interface GFarmNFTInterface{
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function getLeverageFromID(uint id) external view returns(uint16);
    function leverageID(uint16 _leverage) external pure returns(uint16);
}

// File: @openzeppelin\contracts\math\SafeMath.sol

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @uniswap\v2-core\contracts\interfaces\IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: contracts\GFarmTrading.sol

pragma solidity 0.7.5;





contract GFarmTrading{

    using SafeMath for uint;

    // Tokens
    GFarmTokenInterface immutable token;
    IUniswapV2Pair immutable gfarmEthPair;
    GFarmNFTInterface immutable nft;

    // Trading
    uint constant MAX_GAIN_P = 900; // 10x
    uint constant STOP_LOSS_P = 90; // liquidated when -90% => 10% reward
    uint constant PRECISION = 1e5;  // computations decimals

    // Important uniswap addresses / pairs
	address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniswapV2Pair constant ethDaiPair = IUniswapV2Pair(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11);
    IUniswapV2Pair constant ethUsdtPair = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);
    IUniswapV2Pair constant ethUsdcPair = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);

    // Dev fund
    address public immutable DEV_FUND;
    uint constant DEV_FUND_FEE_P = 1;

    // Info about each trade
    struct Trade{
        uint openBlock;
        address initiator;
        bool buy; // True = up, False = down
        uint openPrice; // divide by PRECISION for real price
        uint ethPositionSize; // in wei
        uint16 leverage; // Used for custom leverage if user has the corresponding NFT
    }
    mapping(address => Trade) public trades;

    // Info about each user gains
    struct Gains{
        uint value; // Divide by PRECISION for real value
        uint lastTradeClosed;
    }
    mapping(address => Gains) public gains;

    // Useful to list open trades & trades that can be liquidated
    address[] public addressesTradeOpen;
    mapping(address => uint) private addressTradeOpenID;

    /*uint public fakeEthDaiPrice = 200*PRECISION;
    uint public fakeEthDaiReserve = 100*1e18;
    uint public fakeEthUsdtPrice = 300*PRECISION;
    uint public fakeEthUsdtReserve = 200*1e18;
    uint public fakeEthUsdcPrice = 400*PRECISION;
    uint public fakeEthUsdcReserve = 300*1e18;
    uint public fakeGFarmEthPrice = 10000;
    uint public fakeBlockNumber; // REPLACE EVERYWHERE BY BLOCK.NUMBER*/

    constructor(
        GFarmTokenInterface _token,
        IUniswapV2Pair _gfarmEthPair,
        GFarmNFTInterface _nft){

        token = _token;
        gfarmEthPair = _gfarmEthPair;
        nft = _nft;
        DEV_FUND = msg.sender;

        //fakeBlockNumber = block.number;
    }

    /*function increaseBlock(uint b) external { fakeBlockNumber += b; }
    function decreaseBlock(uint b) external { fakeBlockNumber -= b; }
    function setFakeEthDaiInfo(uint p, uint r) external { fakeEthDaiPrice = p; fakeEthDaiReserve = r; }
    function setFakeEthUsdtInfo(uint p, uint r) external { fakeEthUsdtPrice = p; fakeEthUsdtReserve = r; }
    function setFakeEthUsdcInfo(uint p, uint r) external { fakeEthUsdcPrice = p; fakeEthUsdcReserve = r; }
    function setFakeGFarmEthPrice(uint p) external { fakeGFarmEthPrice = p; }*/
    
    // PRICING FUNCTIONS

    // Get current ETH price from ETH/DAI pool and current ETH reserve
    // Divide price by PRECISION for real value
    function pairInfoDAI() private view returns(uint, uint){
        (uint112 reserves0, uint112 reserves1, ) = ethDaiPair.getReserves();
        uint reserveDAI;
        uint reserveETH;
        if(WETH == ethDaiPair.token0()){
            reserveETH = reserves0;
            reserveDAI = reserves1;
        }else{
            reserveDAI = reserves0;
            reserveETH = reserves1;
        }
        // Divide number of DAI by number of ETH
        return (reserveDAI.mul(PRECISION).div(reserveETH), reserveETH);
        
        //return (fakeEthDaiPrice, fakeEthDaiReserve);
    }
    // Get current ETH price from ETH/USDT pool and current ETH reserve
    // Divide price by PRECISION for real value
    function pairInfoUSDT() private view returns(uint, uint){
        (uint112 reserves0, uint112 reserves1, ) = ethUsdtPair.getReserves();
        uint reserveUSDT;
        uint reserveETH;
        if(WETH == ethUsdtPair.token0()){
            reserveETH = reserves0;
            reserveUSDT = reserves1;
        }else{
            reserveUSDT = reserves0;
            reserveETH = reserves1;
        }
        // Divide number of USDT by number of ETH
        // we multiply by 1e12 because USDT only has 6 decimals
        return (reserveUSDT.mul(1e12).mul(PRECISION).div(reserveETH), reserveETH);
    
        //return (fakeEthUsdtPrice, fakeEthUsdtReserve);
    }
    // Get current ETH price from ETH/USDC pool and current ETH reserve
    // Divide price by PRECISION for real value
    function pairInfoUSDC() private view returns(uint, uint){
        (uint112 reserves0, uint112 reserves1, ) = ethUsdcPair.getReserves();
        uint reserveUSDC;
        uint reserveETH;
        if(WETH == ethUsdcPair.token0()){
            reserveETH = reserves0;
            reserveUSDC = reserves1;
        }else{
            reserveUSDC = reserves0;
            reserveETH = reserves1;
        }
        // Divide number of USDC by number of ETH
        // we multiply by 1e12 because USDC only has 6 decimals
        return (reserveUSDC.mul(1e12).mul(PRECISION).div(reserveETH), reserveETH);
    
        //return (fakeEthUsdcPrice, fakeEthUsdcReserve);
    }
    // Get current Ethereum price as a weighted average of the 3 pools based on liquidity
    // Divide by PRECISION for real value
    function getEthPrice() public view returns(uint){
        (uint priceEthDAI, uint reserveEthDAI) = pairInfoDAI();
        (uint priceEthUSDT, uint reserveEthUSDT) = pairInfoUSDT();
        (uint priceEthUSDC, uint reserveEthUSDC) = pairInfoUSDC();

        uint reserveEth = reserveEthDAI.add(reserveEthUSDT).add(reserveEthUSDC);

    	return (
                priceEthDAI.mul(reserveEthDAI).add(
                    priceEthUSDT.mul(reserveEthUSDT)
                ).add(
                    priceEthUSDC.mul(reserveEthUSDC)
                )
            ).div(reserveEth);
    }
    // Get current GFarm price in ETH from the Uniswap pool
    // Divide by precision for real value
    function getGFarmPriceEth() private view returns(uint){
        (uint112 reserves0, uint112 reserves1, ) = gfarmEthPair.getReserves();

        uint reserveETH;
        uint reserveGFARM;

        if(WETH == gfarmEthPair.token0()){
            reserveETH = reserves0;
            reserveGFARM = reserves1;
        }else{
            reserveGFARM = reserves0;
            reserveETH = reserves1;
        }

        // Divide number of ETH by number of GFARM
        return reserveETH.mul(PRECISION).div(reserveGFARM);

        //return fakeGFarmEthPrice;
    }

    // MAX GFARM POS (important for security)

    // Maximum position size in GFARM
    function getMaxPosGFARM() public view returns(uint){
        (, uint reserveEthDAI) = pairInfoDAI();
        (, uint reserveEthUSDT) = pairInfoUSDT();
        (, uint reserveEthUSDC) = pairInfoUSDC();

        uint totalReserveETH = reserveEthDAI.add(reserveEthUSDT).add(reserveEthUSDC);
        uint sqrt10 = 3162277660168379331; // 1e18 precision

        return totalReserveETH.mul(sqrt10).sub(totalReserveETH.mul(1e18)).div(getGFarmPriceEth().mul(750000)).div(1e18/PRECISION);
    }

    // PRIVATE FUNCTIONS
    
    // Divide by PRECISION for real value
    function percentDiff(uint a, uint b) private pure returns(int){
        return (int(b) - int(a))*100*int(PRECISION)/int(a);
    }
    // Divide by PRECISION for real value
    function currentPercentProfit(uint _openPrice, uint _currentPrice, bool _buy, uint16 _leverage) private pure returns(int p){
        if(_buy){
            p = percentDiff(_openPrice, _currentPrice)*int(_leverage);
        }else{
        	p = percentDiff(_openPrice, _currentPrice)*(-1)*int(_leverage);
        }
        int maxLossPercentage = -100 * int(PRECISION);
        int maxGainPercentage = int(MAX_GAIN_P * PRECISION);
        if(p < maxLossPercentage){
            p = maxLossPercentage;
        }else if(p > maxGainPercentage){
        	p = maxGainPercentage;
        }
    }
    function canLiquidatePure(uint _openPrice, uint _currentPrice, bool _buy, uint16 _leverage) private pure returns(bool){
        if(_buy){
            return currentPercentProfit(_openPrice, _currentPrice, _buy, _leverage) <= (-1)*int(STOP_LOSS_P*PRECISION);
        }else{
            return currentPercentProfit(_openPrice, _currentPrice, _buy, _leverage) <= (-1)*int(STOP_LOSS_P*PRECISION);
        }
    }
    // Remove trade from list of open trades (useful to list liquidations)
    function unregisterOpenTrade(address a) private{
        delete trades[a];

        if(addressesTradeOpen.length > 1){
            addressesTradeOpen[addressTradeOpenID[a]] = addressesTradeOpen[addressesTradeOpen.length - 1];
            addressTradeOpenID[addressesTradeOpen[addressesTradeOpen.length - 1]] = addressTradeOpenID[a];
        }

        addressesTradeOpen.pop();
        delete addressTradeOpenID[a];
    }

    // PUBLIC FUNCTIONS (used internally and externally)

    function hasOpenTrade(address a) public view returns(bool){
        return trades[a].openBlock != 0;
    }
    function canLiquidate(address a) public view returns(bool){
        require(hasOpenTrade(a), "This address has no open trade.");
        Trade memory t = trades[a];
        return canLiquidatePure(t.openPrice, getEthPrice(), t.buy, t.leverage);
    }
    // Compute position size in GFARM based on GFARM/ETH price and ETH position size
    function positionSizeGFARM(address a) public view returns(uint){
        return trades[a].ethPositionSize.mul(PRECISION).div(getGFarmPriceEth());
    }
    // Token PNL in GFARM
    function myTokenPNL() public view returns(int){
        if(!hasOpenTrade(msg.sender)){ return 0; }
        Trade memory t = trades[msg.sender];
        return int(positionSizeGFARM(msg.sender)) * currentPercentProfit(t.openPrice, getEthPrice(), t.buy, t.leverage) / int(100*PRECISION);
    }
    // Amount you get when liquidating trade open by an address (GFARM)
    function liquidateAmountGFARM(address a) public view returns(uint){
        return positionSizeGFARM(a).mul((100 - STOP_LOSS_P)).div(100);
    }
    function myNftsCount() public view returns(uint){
        return nft.balanceOf(msg.sender);
    }

    // EXTERNAL TRADING FUNCTIONS
    
    function openTrade(bool _buy, uint _positionSize, uint16 _leverage) external{
        require(!hasOpenTrade(msg.sender), "You can only have 1 trade open at a time.");
        require(_positionSize > 0, "Opening a trade with 0 tokens.");
        require(_positionSize <= getMaxPosGFARM(), "Your position size exceeds the max authorized position size.");

        if(_leverage > 50){
            uint nftCount = myNftsCount();
            require(nftCount > 0, "You don't own any GFarm NFT.");

            bool hasCorrespondingNFT = false;

            for(uint i = 0; i < nftCount; i++){
                uint nftID = nft.tokenOfOwnerByIndex(msg.sender, i);
                uint correspondingLeverage = nft.getLeverageFromID(nftID);
                if(correspondingLeverage == _leverage){
                    hasCorrespondingNFT = true;
                    break;
                }
            }
            
            require(hasCorrespondingNFT, "You don't own the corresponding NFT for this leverage.");            
        }
        
        token.transferFrom(msg.sender, address(this), _positionSize);
        token.burn(address(this), _positionSize);

        uint DEV_FUND_fee = _positionSize.mul(DEV_FUND_FEE_P).div(100);
        uint positionSizeMinusFee = _positionSize.sub(DEV_FUND_fee);

        token.mint(DEV_FUND, DEV_FUND_fee);

        uint ethPosSize = positionSizeMinusFee.mul(getGFarmPriceEth()).div(PRECISION);

        trades[msg.sender] = Trade(block.number, msg.sender, _buy, getEthPrice(), ethPosSize, _leverage);
        addressesTradeOpen.push(msg.sender);
        addressTradeOpenID[msg.sender] = addressesTradeOpen.length.sub(1);
    }
    function closeTrade() external{
        require(hasOpenTrade(msg.sender), "You have no open trade.");
        Trade memory t = trades[msg.sender];
        require(block.number >= t.openBlock.add(3), "Trade must be open for at least 3 blocks.");

        if(!canLiquidate(msg.sender)){
            uint tokensBack = positionSizeGFARM(msg.sender);
            int pnl = myTokenPNL();

            // Gain
            if(pnl > 0){ 
                Gains storage userGains = gains[msg.sender];
                userGains.value = userGains.value.add(uint(pnl));
                userGains.lastTradeClosed = block.number;
            // Loss
            }else if(pnl < 0){
                tokensBack = tokensBack.sub(uint(pnl*(-1)));
            }

            token.mint(msg.sender, tokensBack);
        }

        unregisterOpenTrade(msg.sender);
    }
    function liquidate(address a) external{
        require(canLiquidate(a), "No trade to liquidate for this address.");
        require(myNftsCount() > 0 || msg.sender == DEV_FUND, "You don't own any GFarm NFT.");

        token.mint(msg.sender, liquidateAmountGFARM(a));
        unregisterOpenTrade(a);
    }
    function claimGains() external{
        Gains storage userGains = gains[msg.sender];
        require(block.number.sub(userGains.lastTradeClosed) >= 3, "You must wait 3 block after you close a trade.");
        token.mint(msg.sender, userGains.value);
        userGains.value = 0;
    }

    // UI VIEW FUNCTIONS (READ-ONLY)

    function myGains() external view returns(uint){
        return gains[msg.sender].value;
    }
    function canClaimGains() external view returns(bool){
        return block.number.sub(gains[msg.sender].lastTradeClosed) >= 3 && gains[msg.sender].value > 0;
    }
    // Divide by PRECISION for real value
    function myPercentPNL() external view returns(int){
        if(!hasOpenTrade(msg.sender)){ return 0; }

        Trade memory t = trades[msg.sender];
        return currentPercentProfit(t.openPrice, getEthPrice(), t.buy, t.leverage);
    }
    function myOpenPrice() external view returns(uint){
        return trades[msg.sender].openPrice;
    }
    function myPositionSizeETH() external view returns(uint){
        return trades[msg.sender].ethPositionSize;
    }
    function myPositionSizeGFARM() external view returns(uint){
        return positionSizeGFARM(msg.sender);
    }
    function myDirection() external view returns(string memory){
        if(trades[msg.sender].buy){ return 'Buy'; }
        return 'Sell';
    }
    function myLeverage() external view returns(uint){
        return trades[msg.sender].leverage;
    }
    function tradeOpenSinceThreeBlocks() external view returns(bool){
        Trade memory t = trades[msg.sender];
        if(!hasOpenTrade(msg.sender) || block.number < t.openBlock){ return false; }
        return block.number.sub(t.openBlock) >= 3;
    }
    function getAddressesTradeOpen() external view returns(address[] memory){
        return addressesTradeOpen;
    }
    function unlockedLeverages() external view returns(uint16[8] memory leverages){
        for(uint i = 0; i < myNftsCount(); i++){
            uint16 leverage = nft.getLeverageFromID(nft.tokenOfOwnerByIndex(msg.sender, i));
            uint id = nft.leverageID(leverage);
            leverages[id] = leverage;
        }
    }
}