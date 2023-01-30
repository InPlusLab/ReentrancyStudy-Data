/**

 *Submitted for verification at Etherscan.io on 2019-05-13

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

    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external payable returns(uint);

    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) public returns(uint);

}



interface ExchangeInterface {

    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) payable external returns(uint, uint);

    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint);



    function getExpectedRate(address src, address dest, uint srcQty) external

        returns (uint expectedRate, uint slippageRate);

}



contract KyberWrapper is ExchangeInterface {



    // Kovan

    // address constant KYBER_INTERFACE = 0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D;

    // address constant ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    

    // Mainnet

    address constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;

    address constant ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;



    address constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;



    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) external payable returns(uint, uint) {

        uint minRate;

        ERC20 ETH_TOKEN_ADDRESS = ERC20(ETHER_ADDRESS);

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

    

    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint) {

        uint minRate;

        ERC20 ETH_TOKEN_ADDRESS = ERC20(ETHER_ADDRESS);

        ERC20 token = ERC20(_tokenAddress);

        

        KyberNetworkProxyInterface _kyberNetworkProxy = KyberNetworkProxyInterface(KYBER_INTERFACE);

        

        (, minRate) = _kyberNetworkProxy.getExpectedRate(token, ETH_TOKEN_ADDRESS, _amount);



        // Mitigate ERC20 Approve front-running attack, by initially setting, allowance to 0

        require(token.approve(address(_kyberNetworkProxy), 0));



        // Approve tokens so network can take them during the swap

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



    function getExpectedRate(address _src, address _dest, uint _srcQty) public returns (uint, uint) {

        return KyberNetworkProxyInterface(KYBER_INTERFACE).getExpectedRate(ERC20(_src), ERC20(_dest), _srcQty);

    }



    function() payable external {

    }

}