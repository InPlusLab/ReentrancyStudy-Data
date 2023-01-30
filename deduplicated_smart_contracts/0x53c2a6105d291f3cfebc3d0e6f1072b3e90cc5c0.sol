/**
 *Submitted for verification at Etherscan.io on 2019-10-22
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

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes memory hint) public payable returns(uint);

    function trade(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId) public payable returns(uint);

    function swapEtherToToken(ERC20 token, uint minConversionRate) external payable returns(uint);
    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external payable returns(uint);
    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) public returns(uint);
}

interface ExchangeInterface {
    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) payable external returns(uint, uint);
    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint);
    function swapTokenToToken(address _src, address _dest, uint _amount) external payable returns(uint);

    function getExpectedRate(address src, address dest, uint srcQty) external view
        returns (uint expectedRate);
}

contract ConstantAddressesMainnet {
    address public constant MAKER_DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    address public constant IDAI_ADDRESS = 0x14094949152EDDBFcd073717200DA82fEd8dC960;
    address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;
    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant MKR_ADDRESS = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant VOX_ADDRESS = 0x9B0F70Df76165442ca6092939132bBAEA77f2d7A;
    address public constant PETH_ADDRESS = 0xf53AD2c6851052A81B42133467480961B2321C09;
    address public constant TUB_ADDRESS = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;
    address payable public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;
    address public constant LOGGER_ADDRESS = 0xeCf88e1ceC2D2894A0295DB3D86Fe7CE4991E6dF;
    address public constant OTC_ADDRESS = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;
    address public constant DISCOUNT_ADDRESS = 0x1b14E8D511c9A4395425314f849bD737BAF8208F;

    address public constant KYBER_WRAPPER = 0x8F337bD3b7F2b05d9A8dC8Ac518584e833424893;
    address public constant UNISWAP_WRAPPER = 0x1e30124FDE14533231216D95F7798cD0061e5cf8;
    address public constant ETH2DAI_WRAPPER = 0xd7BBB1777E13b6F535Dec414f575b858ed300baF;
    address public constant OASIS_WRAPPER = 0xCbE344DBBcCEbF04c0D045102A4bfA76c49b33c9;

    address public constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    address public constant UNISWAP_FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;
    address public constant PIP_INTERFACE_ADDRESS = 0x729D19f657BD0614b4985Cf1D82531c67569197B;

    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;
    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;

    address public constant SAVINGS_LOGGER_ADDRESS = 0x89b3635BD2bAD145C6f92E82C9e83f06D5654984;

    
    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;
    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;
}

contract ConstantAddressesKovan {
    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant WETH_ADDRESS = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    address public constant MAKER_DAI_ADDRESS = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    address public constant MKR_ADDRESS = 0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD;
    address public constant VOX_ADDRESS = 0xBb4339c0aB5B1d9f14Bd6e3426444A1e9d86A1d9;
    address public constant PETH_ADDRESS = 0xf4d791139cE033Ad35DB2B2201435fAd668B1b64;
    address public constant TUB_ADDRESS = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;
    address public constant LOGGER_ADDRESS = 0x32d0e18f988F952Eb3524aCE762042381a2c39E5;
    address payable public  constant WALLET_ID = 0x54b44C6B18fc0b4A1010B21d524c338D1f8065F6;
    address public constant OTC_ADDRESS = 0x4A6bC4e803c62081ffEbCc8d227B5a87a58f1F8F;
    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;
    address public constant SOLO_MARGIN_ADDRESS = 0x4EC3570cADaAEE08Ae384779B0f3A45EF85289DE;
    address public constant IDAI_ADDRESS = 0xA1e58F3B1927743393b25f261471E1f2D3D9f0F6;
    address public constant CDAI_ADDRESS = 0xb6b09fBffBa6A5C4631e5F7B2e3Ee183aC259c0d;
    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;
    address public constant DISCOUNT_ADDRESS = 0x1297c1105FEDf45E0CF6C102934f32C4EB780929;

    address public constant KYBER_WRAPPER = 0x0eED9d768BBed73A66201ab1441fa6a039e65228;
    address public constant UNISWAP_WRAPPER = 0xb07a1Cb9661957E6949362bce42BD6930f861673;
    address public constant ETH2DAI_WRAPPER = 0x823cde416973a19f98Bb9C96d97F4FE6C9A7238B;
    address public constant OASIS_WRAPPER = 0x6Ab7e1d38B16731cdd0540d2494FeE6d000D451C;

    address public constant FACTORY_ADDRESS = 0xc72E74E474682680a414b506699bBcA44ab9a930;
    
    address public constant PIP_INTERFACE_ADDRESS = 0xA944bd4b25C9F186A846fd5668941AA3d3B8425F;
    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x64A436ae831C1672AE81F674CAb8B6775df3475C;
    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000170CcC93903185bE5A2094C870Df62;
    address public constant KYBER_INTERFACE = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;

    address public constant SAVINGS_LOGGER_ADDRESS = 0xA6E5d5F489b1c00d9C11E1caF45BAb6e6e26443d;

    
    address public constant UNISWAP_FACTORY = 0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36;
}

contract ConstantAddresses is ConstantAddressesMainnet {
}

contract KyberWrapper is ExchangeInterface, ConstantAddresses {

    function swapTokenToToken(address _src, address _dest, uint _amount) external payable returns(uint) {
        require(_src != KYBER_ETH_ADDRESS && _dest != KYBER_ETH_ADDRESS);

        uint minRate;
        uint destAmount;
        ERC20 SRC_TOKEN = ERC20(_src);
        ERC20 DEST_TOKEN = ERC20(_dest);

        KyberNetworkProxyInterface _kyberNetworkProxy = KyberNetworkProxyInterface(KYBER_INTERFACE);

        (, minRate) = _kyberNetworkProxy.getExpectedRate(SRC_TOKEN, DEST_TOKEN, _amount);

        
        require(SRC_TOKEN.approve(address(_kyberNetworkProxy), 0));
        
        SRC_TOKEN.approve(address(_kyberNetworkProxy), _amount);

        destAmount = _kyberNetworkProxy.trade(
            SRC_TOKEN,
            _amount,
            DEST_TOKEN,
            msg.sender,
            uint(-1),
            minRate,
            WALLET_ID
        );


        return destAmount;
    }


    function swapEtherToToken(uint _ethAmount, address _tokenAddress, uint _maxAmount) external payable returns(uint, uint) {
        uint minRate;
        ERC20 ETH_TOKEN_ADDRESS = ERC20(KYBER_ETH_ADDRESS);
        ERC20 token = ERC20(_tokenAddress);

        KyberNetworkProxyInterface _kyberNetworkProxy = KyberNetworkProxyInterface(KYBER_INTERFACE);

        (, minRate) = _kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, _ethAmount);

        uint destAmount = _kyberNetworkProxy.trade.value(_ethAmount)(
            ETH_TOKEN_ADDRESS,
            _ethAmount,
            token,
            msg.sender,
            _maxAmount,
            minRate,
            WALLET_ID
        );

        uint balance = address(this).balance;

        msg.sender.transfer(balance);

        return (destAmount, balance);
    }

    function swapTokenToEther(address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint) {
        uint minRate;
        ERC20 ETH_TOKEN_ADDRESS = ERC20(KYBER_ETH_ADDRESS);
        ERC20 token = ERC20(_tokenAddress);

        KyberNetworkProxyInterface _kyberNetworkProxy = KyberNetworkProxyInterface(KYBER_INTERFACE);

        (, minRate) = _kyberNetworkProxy.getExpectedRate(token, ETH_TOKEN_ADDRESS, _amount);

        
        require(token.approve(address(_kyberNetworkProxy), 0));

        
        token.approve(address(_kyberNetworkProxy), _amount);

        uint destAmount = _kyberNetworkProxy.trade(
            token,
            _amount,
            ETH_TOKEN_ADDRESS,
            msg.sender,
            _maxAmount,
            minRate,
            WALLET_ID
        );

        return destAmount;
    }

    function getExpectedRate(address _src, address _dest, uint _srcQty) public view returns (uint) {
        uint rate;
        (rate, ) = KyberNetworkProxyInterface(KYBER_INTERFACE).getExpectedRate(ERC20(_src), ERC20(_dest), _srcQty);

        return rate;
    }

    function() payable external {
    }
}