/**
 *Submitted for verification at Etherscan.io on 2019-06-19
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
    function allocateTo(address recipient, uint256 value) external;
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
contract UniswapExchangeInterface {
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
}

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract UniswapFactoryInterface {
    function getExchange(address token) external view returns (address exchange);
}

contract UniswapWrapper is ExchangeInterface, DSMath {

    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Mainnet
    address public constant UNISWAP_FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;

    // Rinkeby
    // address public constant UNISWAP_FACTORY = 0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36;

    function swapEtherToToken (uint _ethAmount, address _tokenAddress, uint _maxAmount) external payable returns(uint, uint) {
        address uniswapTokenAddress = UniswapFactoryInterface(UNISWAP_FACTORY).getExchange(_tokenAddress);

        uint tokenAmount = UniswapExchangeInterface(uniswapTokenAddress).
                ethToTokenTransferInput.value(_ethAmount)(1, block.timestamp + 1, msg.sender);

        return (tokenAmount, 0);
    }
    
    function swapTokenToEther (address _tokenAddress, uint _amount, uint _maxAmount) external returns(uint) {
        address uniswapTokenAddress = UniswapFactoryInterface(UNISWAP_FACTORY).getExchange(_tokenAddress);

        ERC20(_tokenAddress).approve(uniswapTokenAddress, _amount);

        uint ethAmount = UniswapExchangeInterface(uniswapTokenAddress).
                tokenToEthTransferInput(_amount, 1, block.timestamp + 1, msg.sender);

        return ethAmount;
    }

    function getExpectedRate(address _src, address _dest, uint _srcQty) public returns (uint, uint) {
        if(_src == KYBER_ETH_ADDRESS) {
            address uniswapTokenAddress = UniswapFactoryInterface(UNISWAP_FACTORY).getExchange(_dest);
            return (wdiv(UniswapExchangeInterface(uniswapTokenAddress).getEthToTokenInputPrice(_srcQty), _srcQty), 0);
        } else if (_dest == KYBER_ETH_ADDRESS) {
            address uniswapTokenAddress = UniswapFactoryInterface(UNISWAP_FACTORY).getExchange(_src);
            return (wdiv(UniswapExchangeInterface(uniswapTokenAddress).getTokenToEthInputPrice(_srcQty), _srcQty), 0);
        } else {
            uint ethBought = UniswapExchangeInterface(UniswapFactoryInterface(UNISWAP_FACTORY).getExchange(_src)).getTokenToEthInputPrice(_srcQty);
            return (wdiv(UniswapExchangeInterface(UniswapFactoryInterface(UNISWAP_FACTORY).getExchange(_dest)).getEthToTokenInputPrice(ethBought), ethBought), 0);
        }
    }

    function() payable external {
    }
}