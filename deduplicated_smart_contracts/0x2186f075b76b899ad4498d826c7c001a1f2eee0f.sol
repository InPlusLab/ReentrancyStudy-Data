pragma solidity 0.5.11;

import "./ERC20Interface.sol";
import "./Utils.sol";
import "./PermissionGroups.sol";


interface KyberProxy {
    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty)
        external view
        returns(uint expectedRate, uint slippageRate);
}


interface MedianizerInterface {
    function peek() external view returns (bytes32, bool);
}


contract PTToDaiConversionRate is Utils, PermissionGroups {
    KyberProxy public kyberProxy = KyberProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    MedianizerInterface public medianizer = MedianizerInterface(0x729D19f657BD0614b4985Cf1D82531c67569197B);
    ERC20 public constant ETH_ADDRESS = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    ERC20 public daiAddress = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    uint public constant MAX_REASONABLE_BPS = 250; //2.5%

    constructor(address _admin) public PermissionGroups (_admin) {}

    function setKyberContract(KyberProxy _kyberProxy) public onlyAdmin {
        require(address(_kyberProxy) != address(0), "contract address cannot be null");
        kyberProxy = _kyberProxy;
    }

    function setMedianizer(MedianizerInterface _medianizer) public onlyAdmin {
        require(address(_medianizer) != address(0), "contract address cannot be null");
        medianizer = _medianizer;
    }

    function setDAIAddress(ERC20 _daiAddress) public onlyAdmin {
        require(address(_daiAddress) != address(0), "contract address cannot be null");
        daiAddress = _daiAddress;
    }

    function recordImbalance(
        ERC20 token,
        int buyAmount,
        uint rateUpdateBlock,
        uint currentBlock
    )
        public {
            // do nothing
        }

    function getRateDiffInBps() public view returns(uint) {
        uint buyRate;
        uint sellRate;

        (buyRate,) = kyberProxy.getExpectedRate(
            ETH_ADDRESS,
            daiAddress,
            PRECISION
            );

        (bytes32 usdPerEthInWei, bool valid) = medianizer.peek();
        uint usdPerEthInPrecision = uint(usdPerEthInWei);
        if (usdPerEthInPrecision >= buyRate) {
            return (usdPerEthInPrecision - buyRate) * 10000 / usdPerEthInPrecision;
        } else {
            return (buyRate - usdPerEthInPrecision) * 10000 / buyRate;
        }
    }

    function getRate(ERC20 token, uint currentBlockNumber, bool buy, uint qty) public view returns(uint) {
        if(address(token) != address(daiAddress)) return 0;
        if(buy) return 0;

        uint buyRate;
        uint sellRate;
        uint rateDiffInBps;
        uint querySrcAmount = (10**17 * qty) / 10**18; //qty of 0.X ETH -> for X PT tokens (in precision)

        (buyRate,) = kyberProxy.getExpectedRate(
            ETH_ADDRESS,
            daiAddress,
            querySrcAmount
            );

        uint queryDestAmount = calcDstQty(querySrcAmount, 18, 18, buyRate);
        (sellRate, ) = kyberProxy.getExpectedRate(
            daiAddress,
            ETH_ADDRESS,
            queryDestAmount
            );

        //check no arbitrage
        require((buyRate * sellRate) <= (PRECISION ** 2), "internal arbitrage is present");

        //fetch value from Maker's Medianizer
        (bytes32 usdPerEthInWei, bool valid) = medianizer.peek();
        require(valid, "medianizer rate not valid");

        uint usdPerEthInPrecision = uint(usdPerEthInWei);

        //compare rates, that they are within reasonable spread
        if (usdPerEthInPrecision >= buyRate) {
            rateDiffInBps = (usdPerEthInPrecision - buyRate) * 10000 / usdPerEthInPrecision;
        } else {
            rateDiffInBps = (buyRate - usdPerEthInPrecision) * 10000 / buyRate;
        }
        require(rateDiffInBps <= MAX_REASONABLE_BPS, "medianizer and kyber rates differ greatly");

        /*
        buyRate = ETH -> DAI rate. We want to return a rate such that 1 PT token ~= 1.005 DAI
        Hence, sellRate = 1/buyRate * 1.005
        */
        return 1005 * (PRECISION * PRECISION / buyRate) / 1000;
    }
}
