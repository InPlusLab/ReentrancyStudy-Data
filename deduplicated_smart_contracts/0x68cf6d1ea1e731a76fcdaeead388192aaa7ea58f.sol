pragma solidity 0.5.11;

import "./ERC20InterfaceV5.sol";
import "./KyberReserveInterfaceV5.sol";
import "./WithdrawableV5.sol";
import "./UtilsV5.sol";
import "./IBancorContracts.sol";

contract KyberBancorReserve is KyberReserveInterface, Withdrawable, Utils {

    uint  constant internal BPS = 10000; // 10^4

    address public kyberNetwork;
    IContractRegistry public contractRegistry; // 0x52Ae12ABe5D8BD778BD5397F99cA900624CfADD4
    IBancorNetwork public bancorNetwork;
    IBancorNetworkPathFinder public bancorPathFinder;
    address public converterRegistry;

    bool public tradeEnabled;
    uint public feeBps;

    ERC20 public bancorEth = ERC20(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
    ERC20 public bancorToken = ERC20(0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C);

    mapping(address => bool) public isTokenListed;

    constructor(
        address _contractRegistry,
        address _kyberNetwork,
        uint _feeBps,
        address _admin
    )
        public
    {
        require(_contractRegistry != address(0), "contractRegistry address is missing");
        require(_kyberNetwork != address(0), "kyberNetwork address is missing");
        require(_admin != address(0), "admin address is missing");
        require(_feeBps < BPS, "fee is too big");

        contractRegistry = IContractRegistry(_contractRegistry);
        bancorNetwork = IBancorNetwork(contractRegistry.getAddress("BancorNetwork"));
        bancorPathFinder = IBancorNetworkPathFinder(contractRegistry.getAddress("BancorNetworkPathFinder"));
        converterRegistry = contractRegistry.getAddress("BancorConverterRegistry");

        kyberNetwork = _kyberNetwork;
        feeBps = _feeBps;
        admin = _admin;
        tradeEnabled = true;
    }

    function() external payable { }

    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint) public view returns(uint) {
        if (!tradeEnabled) return 0;

        ERC20 token = src == ETH_TOKEN_ADDRESS ? dest : src;
        if (!isTokenListed[address(token)]) { return 0; } // not listed

        ERC20[] memory path = getConversionPath(src, dest, bancorPathFinder);

        uint destQty;
        (destQty, ) = bancorNetwork.getReturnByPath(path, srcQty);

        uint rate = calcRateFromQty(srcQty, destQty, getDecimals(src), getDecimals(dest));

        rate = valueAfterReducingFee(rate);

        return rate;
    }

    event TradeExecute(
        address indexed sender,
        address src,
        uint srcAmount,
        address destToken,
        uint destAmount,
        address payable destAddress
    );

    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address payable destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool)
    {

        require(tradeEnabled);
        require(msg.sender == kyberNetwork);
        require(srcToken == ETH_TOKEN_ADDRESS || destToken == ETH_TOKEN_ADDRESS);

        require(doTrade(srcToken, srcAmount, destToken, destAddress, conversionRate, validate));

        return true;
    }

    // test func
    function testGetReturns(ERC20 token, bool isEthToToken, uint srcAmount) public returns(uint) {
        uint destAmount;
        ERC20[] memory path = getConversionPath(
            isEthToToken ? bancorEth : token,
            isEthToToken ? token : bancorEth,
            bancorPathFinder
        );
        if (isEthToToken) {
            (destAmount, ) = bancorNetwork.getReturnByPath(path, srcAmount);
        } else {
            (destAmount, ) = bancorNetwork.getReturnByPath(path, srcAmount);
        }
        tradeEnabled = true;
        return destAmount;
    }

    event ContractsSet(address kyberNetwork, address _contractRegistry);

    function setContracts(address _kyberNetwork, address _contractRegistry) public onlyAdmin {
        require(_contractRegistry != address(0), "contractRegistry address is missing");
        require(_kyberNetwork != address(0), "kyberNetwork address is missing");

        kyberNetwork = _kyberNetwork;
        contractRegistry = IContractRegistry(_contractRegistry);

        bancorNetwork = IBancorNetwork(contractRegistry.getAddress("BancorNetwork"));
        bancorPathFinder = IBancorNetworkPathFinder(contractRegistry.getAddress("BancorNetworkPathFinder"));
        converterRegistry = contractRegistry.getAddress("BancorConverterRegistry");

        emit ContractsSet(_kyberNetwork, _contractRegistry);
    }

    event BasicTokensSet(address bancorEth, address bancorToken);

    function setBasicTokens(address _bancorEth, address _bancorToken) public {
        require(_bancorEth != address(0), "setBasicTokens: bancorEth is missing");
        require(_bancorToken != address(0), "setBasicTokens: bancorToken is missing");

        bancorEth = ERC20(_bancorEth);
        bancorToken = ERC20(_bancorToken);

        emit BasicTokensSet(_bancorEth, _bancorToken);
    }

    event TokenListed(ERC20 token);

    function listToken(ERC20 token) public onlyAdmin {
        require(address(token) != address(0), "listToken: token's address is missing");
        require(!isTokenListed[address(token)], "listToken: duplicated");

        require(token.approve(address(bancorNetwork), 2**255), "listToken: fail to approve bancor network");

        isTokenListed[address(token)] = true;

        emit TokenListed(token);
    }

    event TokenDelisted(ERC20 token);

    function delistToken(ERC20 token) public onlyAdmin {
        require(address(token) != address(0), "listToken: token's address is missing");
        require(isTokenListed[address(token)], "listToken: duplicated");

        require(token.approve(address(bancorNetwork), 0), "listToken: fail to approve bancor network");

        delete isTokenListed[address(token)];

        emit TokenDelisted(token);
    }

    event FeeBpsSet(uint feeBps);

    function setFeeBps(uint _feeBps) public onlyAdmin {
        require(_feeBps < BPS, "setFeeBps: feeBps >= bps");

        feeBps = _feeBps;
        emit FeeBpsSet(feeBps);
    }

    event TradeEnabled(bool enable);

    function enableTrade() public onlyAdmin returns(bool) {
        tradeEnabled = true;
        emit TradeEnabled(true);

        return true;
    }

    function disableTrade() public onlyAlerter returns(bool) {
        tradeEnabled = false;
        emit TradeEnabled(false);

        return true;
    }

    function doTrade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address payable destAddress,
        uint conversionRate,
        bool validate
    )
        internal
        returns(bool)
    {
        // can skip validation if done at kyber network level
        if (validate) {
            require(conversionRate > 0);
            if (srcToken == ETH_TOKEN_ADDRESS)
                require(msg.value == srcAmount, "doTrade: msg value is not correct for ETH trade");
            else
                require(msg.value == 0, "doTrade: msg value is not correct for token trade");
        }

        if (srcToken != ETH_TOKEN_ADDRESS) {
            // collect source amount
            require(srcToken.transferFrom(msg.sender, address(this), srcAmount), "doTrade: collect src token failed");
        }

        ERC20[] memory path = getConversionPath(srcToken, destToken, bancorPathFinder);
        require(path.length > 0, "doTrade: couldn't find path");

        uint userExpectedDestAmount = calcDstQty(srcAmount, getDecimals(srcToken), getDecimals(destToken), conversionRate);
        uint destAmount;

        if (srcToken == ETH_TOKEN_ADDRESS) {
            destAmount = bancorNetwork.convert2.value(srcAmount)(path, srcAmount, userExpectedDestAmount, address(0), 0);
        } else {
            destAmount = bancorNetwork.convert2(path, srcAmount, userExpectedDestAmount, address(0), 0);
        }

        require(destAmount >= userExpectedDestAmount, "doTrade: dest amount is lower than expected amount");

        if (destToken == ETH_TOKEN_ADDRESS) {
            destAddress.transfer(userExpectedDestAmount);
        } else {
            require(destToken.transfer(destAddress, userExpectedDestAmount), "doTrade: transfer back dest token failed");
        }

        emit TradeExecute(msg.sender, address(srcToken), srcAmount, address(destToken), userExpectedDestAmount, destAddress);
        return true;
    }

    function getConversionPath(ERC20 src, ERC20 dest, IBancorNetworkPathFinder finder) public view returns(ERC20[] memory path) {
        ERC20 bntToken = bancorToken;

        address[] memory converterRegistries = new address[](1);
        converterRegistries[0] = converterRegistry;

        if (src == ETH_TOKEN_ADDRESS) {
            address[] memory newPath = finder.get(bntToken, dest, converterRegistries);
            if (newPath.length == 0) { return path; }
            path = new ERC20[](newPath.length + 2);
            path[0] = bancorEth;
            path[1] = bntToken;
            for(uint i = 0; i < newPath.length; i++) {
                path[i + 2] = ERC20(newPath[i]);
            }
        } else {
            address[] memory newPath = finder.get(src, bntToken, converterRegistries);
            if (newPath.length == 0) { return path; }
            path = new ERC20[](newPath.length + 2);
            for(uint i = 0; i < newPath.length; i++) {
                path[i] = ERC20(newPath[i]);
            }
            path[newPath.length] = bntToken;
            path[newPath.length + 1] = bancorEth;
        }

        return path;
    }

    function valueAfterReducingFee(uint val) internal view returns(uint) {
        require(val <= MAX_QTY, "valueAfterReducingFee: val > MAX_QTY");
        return ((BPS - feeBps) * val) / BPS;
    }
}
