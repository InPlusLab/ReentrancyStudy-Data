/**

 *Submitted for verification at Etherscan.io on 2019-05-23

*/



contract IERC20 {

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);

    function balanceOf(address _owner) public view returns (uint256 balance);

}



// File: contracts/interfaces/TokenConverter.sol



contract TokenConverter {

    address public constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    function getReturn(IERC20 _fromToken, IERC20 _toToken, uint256 _fromAmount) external view returns (uint256 amount);

    function convert(IERC20 _fromToken, IERC20 _toToken, uint256 _fromAmount, uint256 _minReturn) external payable returns (uint256 amount);

}



contract Uniswap {

    // Address of ERC20 token sold on this exchange

    function tokenAddress() external view returns (IERC20 token);

    // Address of Uniswap Factory

    function factoryAddress() external view returns (address factory);

    // Provide Liquidity

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    // Get Prices

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    // Trade ETH to ERC20

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    // Trade ERC20 to ETH

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens, uint256 deadline, address recipient) external returns (uint256  eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    // Trade ERC20 to ERC20

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    // Trade ERC20 to Custom Pool

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);

    // ERC20 comaptibility for liquidity tokens

    bytes32 public name;

    bytes32 public symbol;

    uint256 public decimals;

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    // Never use

    function setup(address token_addr) external;

}



/*

    Only supports convertion from and to ETH, fails on ERC20 <-> ERC20 convertions

*/

contract UniswapMinimalTokenConverter is TokenConverter {

    Uniswap public uniswap;

    IERC20 public ogToken;



    constructor(Uniswap _uniswap) public {

        uniswap = _uniswap;

        ogToken = _uniswap.tokenAddress();

        ogToken.approve(address(uniswap), uint(-1));

    }



    function getReturn(IERC20 _fromToken, IERC20 _toToken, uint256 _fromAmount) external view returns (uint256 amount) {

        IERC20 _ogToken = ogToken;

        if (_fromToken == _ogToken && address(_toToken) == ETH_ADDRESS) {

            // ERC20 -> ETH

            return uniswap.getTokenToEthInputPrice(_fromAmount);

        } else if (address(_fromToken) == ETH_ADDRESS && _toToken == _ogToken) {

            // ETH -> ERC20

            return uniswap.getEthToTokenInputPrice(_fromAmount);

        } else {

            // Not supported

            return 0;

        }

    }



    function convert(IERC20 _fromToken, IERC20 _toToken, uint256 _fromAmount, uint256 _minReturn) external payable returns (uint256 amount) {

        IERC20 _ogToken = ogToken;



        if (_fromToken == _ogToken && address(_toToken) == ETH_ADDRESS) {

            // ERC20 -> ETH

            require(msg.value == 0);

            require(_fromToken.transferFrom(msg.sender, address(this), _fromAmount), "Error pulling tokens");

            amount = uniswap.tokenToEthTransferInput(_fromAmount, 1, uint(-1), msg.sender);

            require(amount >= _minReturn, "Low return");

        } else if (address(_fromToken) == ETH_ADDRESS && _toToken == _ogToken) {

            // ETH -> ERC20

            require(msg.value == _fromAmount, "Low msg.value");

            amount = uniswap.ethToTokenTransferInput.value(_fromAmount)(1, uint(-1), msg.sender);

            require(amount >= _minReturn, "Low return");

        } else {

            // Not supported

            revert("Not supported");

        }

    }

}