/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.5.14;

interface UniswapExchangeInterface {
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
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
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
}

interface HEX {
    function xfLobbyEnter(address referrerAddr)
    external
    payable;

    function xfLobbyExit(uint256 enterDay, uint256 count)
    external;

    function xfLobbyPendingDays(address memberAddr)
    external
    view
    returns (uint256[2] memory words);

    function balanceOf (address account)
    external
    view
    returns (uint256);

    function transfer (address recipient, uint256 amount)
    external
    returns (bool);

    function currentDay ()
    external
    view
    returns (uint256);
}

contract ReferralSplitter {

    event DistributedShares(
        uint256 timestamp,
        address indexed senderAddress,
        uint256 totalDistributed
    );
    
    event DistributedEthDonation(
        uint256 timestamp,
        address indexed donatorAddress,
        uint256 totalDonated
    );

    HEX internal hx = HEX(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39);
    
    //uniswap exchange needed to cover gas of batcher wallet
    UniswapExchangeInterface internal uni = UniswapExchangeInterface(0x05cDe89cCfa0adA8C88D5A23caaa79Ef129E7883);//uni hex exchange address
    uint256 public minGasHearts = 1000000000000;
    uint256 public allocatedGasHearts;
    address payable public gasWallet;
    
    address payable internal KYLE = 0xD30BC4859A79852157211E6db19dE159673a67E2; // 20
    address payable internal KEVIN = 0x3487b398546C9b757921df6dE78EC308203f5830; // 15
    address payable internal AMIRIS = 0x406D1fC98D231aD69807Cd41d4D6F8273401354f; // 6
    address payable internal MICHAEL = 0xe551072153c02fa33d4903CAb0435Fb86F1a80cb; // 13
    address payable internal JARED = 0x5eCb4D3B4b451b838242c3CF8404ef18f5C486aB; // 5
    address payable internal LOUIS = 0x454f203260a74C0A8B5c0a78fbA5B4e8B31dCC63; // 1
    address payable internal LOTTO = 0x1EF0Bab01329a6CE39e92eA6B88828430B1Cd91f;// 10
    address payable internal DONATOR = 0x723e82Eb1A1b419Fb36e9bD65E50A979cd13d341; // 7.5
    address payable internal MARCO = 0xbf1984B12878c6A25f0921535c76C05a60bdEf39; // 7.5
    address payable internal SWIFT = 0x88BA4dc5571660A1693E421D83EC97015B53580D; // 7.5
    address payable internal MARK = 0x35e9034f47cc00b8A9b555fC1FDB9598b2c245fD; // 7.5
    
    mapping(address => bool) contributors;
    
    modifier onlyContributors(){
        require(contributors[msg.sender], "not a contributor");
        _;
    }
    
    constructor() public {
        gasWallet = msg.sender;
        contributors[KYLE] = true;
        contributors[KEVIN] = true;
        contributors[AMIRIS] = true;
        contributors[MICHAEL] = true;
        contributors[JARED] = true;
        contributors[LOUIS] = true;
        contributors[LOTTO] = true;
        contributors[DONATOR] = true;
        contributors[MARCO] = true;
        contributors[SWIFT] = true;
        contributors[MARK] = true;
    }
    
    function distribute () public {
        //get balance    
        uint256 balance = hx.balanceOf(address(this));
        //deduct for gas
        require(balance > (minGasHearts + 99), "balance does not cover gas allocation");
        balance -= minGasHearts;
        //distribute
        if(balance > 99){
            allocatedGasHearts += minGasHearts;
            uint256 onePercent = balance / 100;
            uint256 fivePercent = balance / 20;
            hx.transfer(KYLE, 4*fivePercent); // 20%
            hx.transfer(KEVIN, 3*fivePercent); // 15%
            hx.transfer(AMIRIS, fivePercent + onePercent); // 6%
            hx.transfer(MICHAEL, (2*fivePercent) + (3*onePercent)); // 13%
            hx.transfer(JARED, fivePercent); // 5%
            hx.transfer(LOUIS, onePercent); // 1%
            hx.transfer(LOTTO, 2*fivePercent); // 10%
            hx.transfer(DONATOR, fivePercent + (fivePercent/2)); // 7.5%
            hx.transfer(MARCO, fivePercent + (fivePercent/2)); // 7.5%
            hx.transfer(SWIFT, fivePercent + (fivePercent/2)); // 7.5%
            hx.transfer(MARK, fivePercent + (fivePercent/2)); // 7.5%
            emit DistributedShares(now, msg.sender, balance);
        }
    }
    
    function setMinGasHearts(uint256 _minGasHearts) public onlyContributors{
        require(_minGasHearts> 0, "min hearts for gas cannot be zero");
        minGasHearts = _minGasHearts;
    }
    
    function withdrawGasAllocation() public onlyContributors{
        require(gasWallet != address(0), "gas wallet cannot be zero address");
        require(allocatedGasHearts > 0, "zero allocated hex for gas");
        //get eth balance before transfer
        uint256 ethBalance = address(this).balance;
        //get eth amount tradable for allocatedGasHearts
        uint256 minWei = uni.getTokenToEthInputPrice(allocatedGasHearts);
        //swap HEX to ETH via uniswap with tx confirmation deadline of 15min
        uni.tokenToEthSwapInput(allocatedGasHearts, minWei, now + 900000);
        //get eth balance again to calc received amount
        uint256 newEthBalance = address(this).balance;
        uint256 ethForGas = newEthBalance - ethBalance;
        //reset allocation
        allocatedGasHearts = 0;
        //transfer ETH to gas wallet
        gasWallet.transfer(ethForGas);
    }
    
    function setGasWallet(address payable _gasWallet) public onlyContributors{
        require(_gasWallet != address(0), "cannot be zero address");
        gasWallet = _gasWallet;
    }
    
    //fallback for eth sent to contract - auto distribute as donation
    function() external payable{
        donate();    
    }
    
    function donate() public payable {
        require(msg.value > 0);
        uint256 balance = msg.value;
        uint256 onePercent = balance / 100;
        uint256 fivePercent = balance / 20;
        KYLE.transfer(4*fivePercent); // 20%
        KEVIN.transfer(3*fivePercent); // 15%
        AMIRIS.transfer(fivePercent + onePercent); // 6%
        MICHAEL.transfer((2*fivePercent) + (3*onePercent)); // 13%
        JARED.transfer(fivePercent); // 5%
        LOUIS.transfer(onePercent); // 1%
        LOTTO.transfer(2*fivePercent); // 10%
        DONATOR.transfer(fivePercent + (fivePercent/2)); // 7.5%
        MARCO.transfer(fivePercent + (fivePercent/2)); // 7.5%
        SWIFT.transfer(fivePercent + (fivePercent/2)); // 7.5%
        MARK.transfer(fivePercent + (fivePercent/2)); // 7.5%
        emit DistributedEthDonation(now, msg.sender, balance);
    }
}