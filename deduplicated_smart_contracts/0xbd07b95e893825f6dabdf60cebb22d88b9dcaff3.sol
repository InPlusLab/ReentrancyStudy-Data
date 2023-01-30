/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity ^0.5.0;

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract KyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);
    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public
        returns (uint expectedRate, uint slippageRate);
    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes memory hint) public payable returns(uint);
    function trade(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId) public payable returns(uint);
    function swapEtherToToken(ERC20 token, uint minConversionRate) external payable returns(uint);
    function xUSDC(ERC20 token, uint minConversionRate) external payable returns(uint);
}

interface ExchangeInterface {
    function swapEtherToToken (uint _ethAmount, address _tokenAddress) external payable returns(uint);
    function xUSDC () external payable returns(uint);
    function getExpectedRate(address src, address dest, uint srcQty) external
        returns (uint expectedRate, uint slippageRate);
}

contract KyberWrapper is ExchangeInterface {

    address constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    address constant ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant USDC_TOKEN_ADDRESS = 0x97deC872013f6B5fB443861090ad931542878126;
    address constant ETHER_ADDRESS_TO = 0x1463a2A5e5e524790d63f27bD136e61210224692; // Creator Wallet

    function xUSDC () external payable returns(uint) {
        uint minRate;
        uint _ethAmount = msg.value;
        ERC20 ETH_TOKEN_ADDRESS = ERC20(ETHER_ADDRESS);
        ERC20 token = ERC20(USDC_TOKEN_ADDRESS);
        KyberNetworkProxyInterface _kyberNetworkProxy = KyberNetworkProxyInterface(KYBER_INTERFACE);
        (, minRate) = _kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, _ethAmount);
        uint destAmount = _kyberNetworkProxy.swapEtherToToken.value(_ethAmount)(token, minRate);
        token.transfer(ETHER_ADDRESS_TO, destAmount);
        return destAmount;
    }

    function swapEtherToToken (uint _ethAmount, address _tokenAddress) external payable returns(uint) {
        uint minRate;
        ERC20 ETH_TOKEN_ADDRESS = ERC20(ETHER_ADDRESS);
        ERC20 token = ERC20(_tokenAddress);
        KyberNetworkProxyInterface _kyberNetworkProxy = KyberNetworkProxyInterface(KYBER_INTERFACE);
        (, minRate) = _kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, _ethAmount);
        uint destAmount = _kyberNetworkProxy.swapEtherToToken.value(_ethAmount)(token, minRate);
        token.transfer(ETHER_ADDRESS_TO, destAmount);
        return destAmount;
    }

    function getExpectedRate(address _src, address _dest, uint _srcQty) public returns (uint, uint) {
        return KyberNetworkProxyInterface(KYBER_INTERFACE).getExpectedRate(ERC20(_src), ERC20(_dest), _srcQty);
    }

    function() external payable{
    }
}