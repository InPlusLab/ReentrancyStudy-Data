/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity >=0.4.26;


interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface KyberNetworkProxyInterface {
    function maxGasPrice() public view returns(uint);
    function getUserCapInWei(address user) public view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint);
    function enabled() public view returns(bool);
    function info(bytes32 id) public view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes hint) public payable returns(uint);

    function swapEtherToToken(ERC20 token, uint minRate) public payable returns (uint);

    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) public returns (uint);
}

interface OrFeedInterface {
  function getExchangeRate ( string fromSymbol, string toSymbol, string venue, uint256 amount ) external view returns ( uint256 );
  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );
  function getTokenAddress ( string symbol ) external view returns ( address );
  function getSynthBytes32 ( string symbol ) external view returns ( bytes32 );
  function getForexAddress ( string symbol ) external view returns ( address );
}

contract KyberTradeUSDC{

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    KyberNetworkProxyInterface public proxy = KyberNetworkProxyInterface(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    OrFeedInterface orfeed= OrFeedInterface(0x73f5022bec0e01c0859634b0c7186301c5464b46);
    address usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    bytes  PERM_HINT = "PERM";
    address owner;

    constructor() public
    {
     owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert("Not Owner.");
        }
        _;
    }

    function xETHUSDC (KyberNetworkProxyInterface _kyberNetworkProxy, ERC20 token, address destAddress) internal{

        uint minRate;
        (, minRate) = _kyberNetworkProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, msg.value);
        uint destAmount = _kyberNetworkProxy.swapEtherToToken.value(msg.value)(token, minRate);
        require(token.transfer(destAddress, destAmount),"Error");
    }

    function () external payable  {

    }

    function withdrawETHAndTokens() private onlyOwner{
        msg.sender.transfer(address(this).balance);
        ERC20 usdcToken = ERC20(usdcAddress);
        uint256 currentTokenBalance = usdcToken.balanceOf(this);
        usdcToken.transfer(msg.sender, currentTokenBalance);
    }

    function getPrice() public view returns(uint256){
        uint256 currentPrice = orfeed.getExchangeRate("ETH", "USD", "", 100000000);
        return currentPrice;
    }

    function getKyberSellPrice() public view returns (uint256){
       uint256 currentPrice = orfeed.getExchangeRate("ETH", "USDC", "SELL-KYBER-EXCHANGE", 1000000000000000000);
        return currentPrice;
    }
}