/**

 *Submitted for verification at Etherscan.io on 2019-05-18

*/



pragma solidity ^0.5.2;



/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract CERC20NoBorrowInterface {

    function mint(uint mintAmount) external returns (uint);

    address public underlying;

}



contract CEtherNoBorrowInterface {

    function mint() external payable;

}



contract CTokenNoBorrowInterface {

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function balanceOfUnderlying(address owner) external returns (uint);

    function exchangeRateStored() public view returns (uint);

}



contract UniswapExchangeInterface {

    // Address of ERC20 token sold on this exchange

    function tokenAddress() external view returns (address token);

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

    // Never use

    function setup(address token_addr) external;

}



contract UniswapFactoryInterface {

    // Public Variables

    address public exchangeTemplate;

    uint256 public tokenCount;

    // Create Exchange

    function createExchange(address token) external returns (address exchange);

    // Get Exchange and Token Info

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    // Never use

    function initializeFactory(address template) external;

}



contract MyEIP20NonStandardInterface {

    function transfer(address _to, uint256 _value) public;

    function transferFrom(address _from, address _to, uint256 _value) public;

}



contract MySafeToken {

    function doTransferIn(address asset, address from, uint amount) internal {

        MyEIP20NonStandardInterface token = MyEIP20NonStandardInterface(asset);

        bool result;

        token.transferFrom(from, address(this), amount);

        assembly {

            switch returndatasize()

            case 0 {

                result := not(0)

            }

            case 32 {

                returndatacopy(0, 0, 32)

                result := mload(0)

            }

            default {

                revert(0, 0)

            }

        }

        require(result);

    }



    function doTransferOut(address asset, address to, uint amount) internal {

        MyEIP20NonStandardInterface token = MyEIP20NonStandardInterface(asset);

        bool result;

        token.transfer(to, amount);

        assembly {

            switch returndatasize()

            case 0 {

                result := not(0)

            }

            case 32 {

                returndatacopy(0, 0, 32)

                result := mload(0)

            }

            default {

                revert(0, 0)

            }

        }

        require(result);

    }

}



contract ProxyData {

    address internal proxied;

}



contract FundHeader {

    address constant internal cEth = address(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);

    UniswapFactoryInterface constant internal uniswapFactory = UniswapFactoryInterface(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);

}



contract FundData is ProxyData, FundHeader {

    address public collateralOwner;

    address public interestWithdrawer;

    mapping(address => uint) public initialDepositCollateral;

    address[] public markets;

}



contract InterestOnlyWithdrawingSafe is FundData, MySafeToken {



    // deposits

    function depositEth() external payable {

        require(msg.sender == collateralOwner && msg.value > 0);

        CEtherNoBorrowInterface(cEth).mint.value(msg.value)();

        initialDepositCollateral[cEth] = initialDepositCollateral[cEth] + msg.value;

    }

    function depositToken(CERC20NoBorrowInterface cErc20Depositing, uint amount) external payable {

        require(msg.sender == collateralOwner && amount > 0);

        doTransferIn(cErc20Depositing.underlying(), msg.sender, amount);

        cErc20Depositing.mint(amount);

        initialDepositCollateral[address(cErc20Depositing)] = initialDepositCollateral[address(cErc20Depositing)] + amount;

    }



    // interest receiver

    // withdraw interest from each collateral type, sends each individually

    function withdrawInterestEach() external {

        require(msg.sender == interestWithdrawer);

        for (uint i=0; i < markets.length; i++) {

            address cTokenAddress = markets[i];

            if (initialDepositCollateral[cTokenAddress] > 0) {

                uint balanceInterestAvailable = CTokenNoBorrowInterface(cTokenAddress).balanceOfUnderlying(address(this)) - initialDepositCollateral[cTokenAddress];

                CTokenNoBorrowInterface(cTokenAddress).redeemUnderlying(balanceInterestAvailable);

                if (cTokenAddress != cEth) {

                    doTransferOut(CERC20NoBorrowInterface(cTokenAddress).underlying(), msg.sender, balanceInterestAvailable);

                } else {

                    address(msg.sender).send(balanceInterestAvailable);

                }

            }

        }

    }

    // uniswap each token interest to eth, withdraw eth

    function withdrawInterestAsEth() external {

        require(msg.sender == interestWithdrawer);

        for (uint i=0; i < markets.length; i++) {

            address cTokenAddress = markets[i];

            if (initialDepositCollateral[cTokenAddress] > 0) {

                uint balanceInterestAvailable = CTokenNoBorrowInterface(cTokenAddress).balanceOfUnderlying(address(this)) - initialDepositCollateral[cTokenAddress];

                CTokenNoBorrowInterface(cTokenAddress).redeemUnderlying(balanceInterestAvailable);

                if (cTokenAddress != cEth) {

                    UniswapExchangeInterface(uniswapFactory.getExchange(CERC20NoBorrowInterface(cTokenAddress).underlying())).tokenToEthSwapInput(balanceInterestAvailable, 1, block.timestamp+1);

                }

            }

        }

        address(msg.sender).send(address(this).balance);

    }

    // uniswap each token interest to eth, uniswap sum eth to withdraw-token

    function withdrawInterestAsToken(address withdrawTokenAddress) external {

        require(msg.sender == interestWithdrawer);

        for (uint i=0; i < markets.length; i++) {

            address cTokenAddress = markets[i];

            if (initialDepositCollateral[cTokenAddress] > 0) {

                uint balanceInterestAvailable = CTokenNoBorrowInterface(cTokenAddress).balanceOfUnderlying(address(this)) - initialDepositCollateral[cTokenAddress];

                CTokenNoBorrowInterface(cTokenAddress).redeemUnderlying(balanceInterestAvailable);

                if (cTokenAddress != cEth) {

                    UniswapExchangeInterface(uniswapFactory.getExchange(CERC20NoBorrowInterface(cTokenAddress).underlying())).tokenToEthSwapInput(balanceInterestAvailable, 1, block.timestamp+1);

                }

            }

        }

        UniswapExchangeInterface(uniswapFactory.getExchange(withdrawTokenAddress)).ethToTokenTransferInput.value(address(this).balance)(1, block.timestamp+1, msg.sender);

    }



    // owner

    function withdrawAll() external {

        require(msg.sender == collateralOwner);

        for (uint i=0; i < markets.length; i++) {

            address cTokenAddress = markets[i];

            if (initialDepositCollateral[cTokenAddress] > 0) {

                initialDepositCollateral[cTokenAddress] = 0;

                CTokenNoBorrowInterface(cTokenAddress).redeem(IERC20(cTokenAddress).balanceOf(address(this)));

                if (markets[i] != cEth) {

                    address underlying = CERC20NoBorrowInterface(cTokenAddress).underlying();

                    doTransferOut(underlying, msg.sender, IERC20(underlying).balanceOf(address(this)));

                } else {

                    address(msg.sender).send(address(this).balance);

                }

            }

        }

    }

    function withdrawAllAsEth() external {

        require(msg.sender == collateralOwner);

        for (uint i=0; i < markets.length; i++) {

            address cTokenAddress = markets[i];

            if (initialDepositCollateral[cTokenAddress] > 0) {

                initialDepositCollateral[cTokenAddress] = 0;

                CTokenNoBorrowInterface(cTokenAddress).redeem(IERC20(cTokenAddress).balanceOf(address(this)));

                if (markets[i] != cEth) {

                    address underlying = CERC20NoBorrowInterface(cTokenAddress).underlying();

                    UniswapExchangeInterface(uniswapFactory.getExchange(underlying)).tokenToEthSwapInput(IERC20(underlying).balanceOf(address(this)), 1, block.timestamp+1);

                }

            }

        }

        address(msg.sender).send(address(this).balance);

    }

    function withdrawAllAsToken(address withdrawTokenAddress) external {

        require(msg.sender == collateralOwner);

        for (uint i=0; i < markets.length; i++) {

            address cTokenAddress = markets[i];

            if (initialDepositCollateral[cTokenAddress] > 0) {

                initialDepositCollateral[cTokenAddress] = 0;

                CTokenNoBorrowInterface(cTokenAddress).redeem(IERC20(cTokenAddress).balanceOf(address(this)));

                if (markets[i] != cEth) {

                    address underlying = CERC20NoBorrowInterface(cTokenAddress).underlying();

                    UniswapExchangeInterface(uniswapFactory.getExchange(underlying)).tokenToEthSwapInput(IERC20(underlying).balanceOf(address(this)), 1, block.timestamp+1);

                }

            }

        }

        UniswapExchangeInterface(uniswapFactory.getExchange(withdrawTokenAddress)).ethToTokenTransferInput.value(address(this).balance)(1, block.timestamp+1, msg.sender);

    }



    // views

    function interestAvailableFromSingleToken(address cTokenAddress) public returns (uint) {

        uint ethCanWithdraw = 0;

        if (initialDepositCollateral[cTokenAddress] > 0) {

            uint underlyingBalance = CTokenNoBorrowInterface(cTokenAddress).balanceOfUnderlying(address(this));

            if (underlyingBalance < initialDepositCollateral[cTokenAddress]) {

                return 0;

            } else {

                return underlyingBalance - initialDepositCollateral[cTokenAddress];

            }

        }

        return 0;

    }

    function interestAvailableAllTokensAsEth() public returns (uint) {

        uint ethCanWithdraw = 0;

        for (uint i=0; i < markets.length; i++) {

            address cTokenAddress = markets[i];

            uint interestAvailable = interestAvailableFromSingleToken(cTokenAddress);

            if (interestAvailable == 0) {

                continue;

            }

            if (cTokenAddress == cEth) {

                ethCanWithdraw = ethCanWithdraw + interestAvailable;

            } else {

                ethCanWithdraw = ethCanWithdraw + UniswapExchangeInterface(uniswapFactory.getExchange(CERC20NoBorrowInterface(cTokenAddress).underlying())).getTokenToEthInputPrice(interestAvailable);

            }

        }

        return ethCanWithdraw;

    }

    function interestAvailableAsToken(address withdrawTokenAddress) external returns (uint) {

        uint ethCanWithdraw = interestAvailableAllTokensAsEth();

        if (ethCanWithdraw == 0) {

            return 0;

        } else {

            return UniswapExchangeInterface(uniswapFactory.getExchange(withdrawTokenAddress)).getEthToTokenInputPrice(ethCanWithdraw);

        }

    }

    function marketCount() external view returns (uint) {

        return markets.length;

    }



    // owner backup/safty functions.

    // TODO: dont allow duplicate markets.

    // TODO: adding invalid markets can break recipient withdraw loop.

    function enterNewMarkets(address[] calldata cTokens) external {

        require(msg.sender == collateralOwner);

        for (uint i=0; i < cTokens.length; i++) {

            markets.push(cTokens[i]);

            address underlying = CERC20NoBorrowInterface(cTokens[i]).underlying();

            tokenAllowAll(underlying, cTokens[i]);

            tokenAllowAll(underlying, uniswapFactory.getExchange(underlying));

        }

    }

    function withdrawEth() external {

        require(msg.sender == collateralOwner);

        msg.sender.transfer(address(this).balance);

    }

    function returnTokenAmount(address asset, uint amount) external {

        require(msg.sender == collateralOwner);

        doTransferOut(asset, msg.sender, amount);

    }

    function transferCollateralOwner(address newOwner) external {

        require(msg.sender == collateralOwner);

        require(newOwner != address(0));

        collateralOwner = newOwner;

    }

    function transferInterestWithdrawer(address newOwner) external {

        require(msg.sender == interestWithdrawer || msg.sender == collateralOwner);

        require(newOwner != address(0));

        interestWithdrawer = newOwner;

    }



    // allow receive eth

    function() external payable { }



    // internal

    function tokenAllowAll(address asset, address allowee) internal {

        require(IERC20(asset).approve(allowee, uint(-1)));

    }



}