/**
 *Submitted for verification at Etherscan.io on 2020-07-27
*/

/*
    SPDX-License-Identifier: MIT
    A Bankteller Production
    Bankroll Network
    Copyright 2020
*/
pragma solidity ^0.4.25;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Token {
    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function transfer(address to, uint256 value) public returns (bool);

    function balanceOf(address who) public view returns (uint256);
}

contract UniSwapV2LiteRouter {

    //function ethToTokenSwapInput(uint256 min_tokens) public payable returns (uint256);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] path, address to, uint deadline) external returns (uint[] amounts);

    function getAmountsOut(uint amountIn, address[] path) external returns (uint[] amounts);
}

/*
 * @dev Life is a perpetual rewards contract the collects 9% fee for a dividend pool that drips 2% daily.
 * A 1% fee is used to buy back a specified ERC20/TRC20 token and distribute to LYF holders via a 2% drip
*/


contract BankrollNetworkStackPlus is Ownable {

    using SafeMath for uint;

    /*=================================
    =            MODIFIERS            =
    =================================*/

    /// @dev Only people with tokens
    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

    /// @dev Only people with profits
    modifier onlyStronghands {
        require(myDividends() > 0);
        _;
    }



    /*==============================
    =            EVENTS            =
    ==============================*/


    event onLeaderBoard(
        address indexed customerAddress,
        uint256 invested,
        uint256 tokens,
        uint256 soldTokens,
        uint256 claims,
        uint256 timestamp
    );

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingeth,
        uint256 tokensMinted,
        uint timestamp
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethEarned,
        uint timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethReinvested,
        uint256 tokensMinted,
        uint256 timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethWithdrawn,
        uint256 timestamp
    );

    event onClaim(
        address indexed customerAddress,
        uint256 tokens,
        uint256 timestamp
    );

    event onTransfer(
        address indexed from,
        address indexed to,
        uint256 tokens,
        uint256 timestamp
    );

    event onBuyBack(
        uint ethAmount,
        uint tokenAmount,
        uint256 timestamp
    );


    event onBalance(
        uint256 balance,
        uint256 timestamp
    );

    event onDonation(
        address indexed from,
        uint256 amount,
        uint256 timestamp
    );

    event onRouterUpdate(
        address oldAddress,
        address newAddress
    );

    event onFlushUpdate(
        uint oldFlushSize,
        uint newFlushSize
    );

    // Onchain Stats!!!
    struct Stats {
        uint invested;
        uint reinvested;
        uint withdrawn;
        uint claims;
        uint rewarded;
        uint contributed;
        uint transferredTokens;
        uint receivedTokens;
        int256 tokenPayoutsTo;
        uint xInvested;
        uint xReinvested;
        uint xRewarded;
        uint xContributed;
        uint xWithdrawn;
        uint xTransferredTokens;
        uint xReceivedTokens;
        uint xClaimed;
    }


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    /// @dev 15% dividends for token purchase
    uint8 constant internal entryFee_ = 10;


    /// @dev 5% dividends for token selling
    uint8 constant internal exitFee_ = 10;

    uint8 constant internal dripFee = 60;  //80% of fees go to drip/instant, the rest, 20%,  to the Swap buyback

    uint8 constant internal instantFee = 20;

    uint8 constant payoutRate_ = 2;

    uint256 constant internal magnitude = 2 ** 64;

    /*=================================
     =            DATASETS            =
     ================================*/

    // amount of shares for each address (scaled number)
    mapping(address => uint256) private tokenBalanceLedger_;
    mapping(address => int256) private payoutsTo_;
    mapping(address => Stats) private stats;
    //on chain referral tracking
    uint256 private tokenSupply_;
    uint256 private profitPerShare_;
    uint256 private rewardsProfitPerShare_;
    uint256 public totalDeposits;
    uint256 internal lastBalance_;

    uint public players;
    uint public totalTxs;
    uint public dividendBalance_;
    uint public swapCollector_;
    uint public swapBalance_;
    uint public lastPayout;
    uint public lastBuyback;
    uint public totalClaims;

    uint256 public balanceInterval = 6 hours;
    uint256 public distributionInterval = 2 seconds;
    uint256 public depotFlushSize = 0.5 ether;


    address public swapAddress;
    address public vltAddress;
    address public collateralAddress;

    Token private vltToken;
    Token private cToken;
    UniSwapV2LiteRouter private swap;


    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/

    constructor(address _collateralAddress, address _vltAddress, address _swapAddress) Ownable() public {

        vltAddress = _vltAddress;
        vltToken = Token(_vltAddress);

        collateralAddress = _collateralAddress;
        cToken = Token(_collateralAddress);

        swapAddress = _swapAddress;
        swap = UniSwapV2LiteRouter(_swapAddress);

        lastPayout = now;

    }


    /// @dev This is how you pump pure "drip" dividends into the system
    function donatePool(uint _amount) public returns (uint256) {
        require(cToken.transferFrom(msg.sender, address(this), _amount), "Transferred failed");

        dividendBalance_ += _amount;

        emit onDonation(msg.sender, _amount, now);
    }

    /// @dev Converts all incoming eth to tokens for the caller, and passes down the referral addy (if any)
    function buy(uint _buy_amount) public returns (uint256)  {
        return buyFor(msg.sender, _buy_amount);
    }


    /// @dev Converts all incoming eth to tokens for the caller, and passes down the referral addy (if any)
    function buyFor(address _customerAddress, uint _buy_amount) public returns (uint256)  {
        require(cToken.transferFrom(_customerAddress, address(this), _buy_amount), "Transferred failed");
        totalDeposits += _buy_amount;
        uint amount = purchaseTokens(_customerAddress, _buy_amount);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        //distribute
        distribute();

        return amount;
    }




    /**
     * @dev Fallback function to handle eth that was send straight to the contract
     *  Unfortunately we cannot use a referral address this way.
     */
    function() public payable  {
        //Just bounce
        require(false, "This contract does not except ETH");
    }

    /// @dev Converts all of caller's dividends to tokens.
    function reinvest() public onlyStronghands  {
        // fetch dividends
        uint256 _dividends = myDividends();
        // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(msg.sender, _dividends);

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens, now);

        //Stats
        stats[_customerAddress].reinvested = SafeMath.add(stats[_customerAddress].reinvested, _dividends);
        stats[_customerAddress].xReinvested += 1;

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        //distribute
        distribute();
    }

    /// @dev Withdraws all of the callers earnings.
    function withdraw() public onlyStronghands  {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends();

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);


        // lambo delivery service
        cToken.transfer(_customerAddress, _dividends);

        //stats
        stats[_customerAddress].withdrawn = SafeMath.add(stats[_customerAddress].withdrawn, _dividends);
        stats[_customerAddress].xWithdrawn += 1;
        totalTxs += 1;

        // fire event
        emit onWithdraw(_customerAddress, _dividends, now);

        //distribute
        distribute();
    }

    /// @dev Withdraws all of the callers rewards.
    function claim() public {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myClaims();

        //only  to claim
        require(_dividends > 0, "No dividends to claim");

        // update dividend tracker
        stats[_customerAddress].tokenPayoutsTo += (int256) (_dividends * magnitude);


        // lambo delivery service
        vltToken.transfer(_customerAddress, _dividends);

        //stats
        stats[_customerAddress].claims = SafeMath.add(stats[_customerAddress].claims, _dividends);
        stats[_customerAddress].xClaimed += 1;
        totalTxs += 1;

        // fire event
        emit onClaim(_customerAddress, _dividends, now);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        //distribute
        distribute();
    }

    /// @dev Liquifies STCK to collateral tokens.
    function sell(uint256 _amountOfTokens) onlyBagholders public {
        // setup data
        address _customerAddress = msg.sender;

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress], "Amount of tokens is greater than balance");


        // data setup
        uint256 _undividedDividends = SafeMath.mul(_amountOfTokens, exitFee_) / 100;
        uint256 _taxedeth = SafeMath.sub(_amountOfTokens, _undividedDividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfTokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens + (_taxedeth * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        //update claims tracker; don't need to redeem extra claims
        stats[_customerAddress].tokenPayoutsTo -= (int256) (rewardsProfitPerShare_ * _amountOfTokens);


        //drip and buybacks applied after supply is updated
        allocateFees(_undividedDividends);

        // fire event
        emit onTokenSell(_customerAddress, _amountOfTokens, _taxedeth, now);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        //distribute
        distribute();
    }

    /**
    * @dev Transfer tokens from the caller to a new holder.
    *  Zero fees
    */
    function transfer(address _toAddress, uint256 _amountOfTokens) external onlyBagholders  returns (bool) {
        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress], "Amount of tokens is greater than balance");

        // withdraw all outstanding dividends first
        if (myDividends() > 0) {
            withdraw();
        }


        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);

        //update claims tracker
        stats[_customerAddress].tokenPayoutsTo -= (int256) (rewardsProfitPerShare_ * _amountOfTokens);
        stats[_toAddress].tokenPayoutsTo += (int256) (rewardsProfitPerShare_ * _amountOfTokens);


        /* Members
            A player can be initialized by buying or receiving and we want to add the user ASAP
         */
        if (stats[_toAddress].invested == 0 && stats[_toAddress].receivedTokens == 0) {
            players += 1;
        }

        //Stats
        stats[_customerAddress].xTransferredTokens += 1;
        stats[_customerAddress].transferredTokens += _amountOfTokens;
        stats[_toAddress].receivedTokens += _amountOfTokens;
        stats[_toAddress].xReceivedTokens += 1;
        totalTxs += 1;

        // fire event
        emit onTransfer(_customerAddress, _toAddress, _amountOfTokens, now);

        emit onLeaderBoard(_customerAddress,
            stats[_customerAddress].invested,
            tokenBalanceLedger_[_customerAddress],
            stats[_customerAddress].withdrawn,
            stats[_customerAddress].claims,
            now
        );

        emit onLeaderBoard(_toAddress,
            stats[_toAddress].invested,
            tokenBalanceLedger_[_toAddress],
            stats[_toAddress].withdrawn,
            stats[_toAddress].claims,
            now
        );

        // ERC20
        return true;
    }


    /*=====================================
    =      HELPERS AND CALCULATORS        =
    =====================================*/

    /**
     * @dev Method to view the current eth stored in the contract
     */
    function totalTokenBalance() public view returns (uint256) {
        return cToken.balanceOf(address(this));
    }

    /// @dev Retrieve the total token supply.
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /// @dev Retrieve the tokens owned by the caller.
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * @dev Retrieve the dividends owned by the caller.
     */
    function myDividends() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return dividendsOf(_customerAddress);
    }

    /**
     * @dev Retrieve token claims owned by the caller.
     */
    function myClaims() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return claimsOf(_customerAddress);
    }



    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /// @dev Retrieve the token balance of any single address.
    function tokenBalance(address _customerAddress) public view returns (uint256) {
        return _customerAddress.balance;
    }

    /// @dev Retrieve the dividend balance of any single address.
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    /// @dev Retrieve the claims balance of any single address.
    function claimsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (rewardsProfitPerShare_ * tokenBalanceLedger_[_customerAddress]) - stats[_customerAddress].tokenPayoutsTo) / magnitude;
    }

    /// @dev Return the sell price of 1 individual token.
    function sellPrice() public pure returns (uint256) {
        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);

        return _taxedeth;

    }

    /// @dev Return the buy price of 1 individual token.
    function buyPrice() public pure returns (uint256) {
        uint256 _eth = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, entryFee_), 100);
        uint256 _taxedeth = SafeMath.add(_eth, _dividends);

        return _taxedeth;

    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of buy orders.
    function calculateTokensReceived(uint256 _ethToSpend) public pure returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethToSpend, entryFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_ethToSpend, _dividends);
        uint256 _amountOfTokens = _taxedeth;

        return _amountOfTokens;
    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of sell orders.
    function calculateethReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_, "Tokens to sell greater than supply");
        uint256 _eth = _tokensToSell;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_eth, exitFee_), 100);
        uint256 _taxedeth = SafeMath.sub(_eth, _dividends);
        return _taxedeth;
    }


    /// @dev Stats of any single address
    function statsOf(address _customerAddress) public view returns (uint256[16] memory){
        Stats memory s = stats[_customerAddress];
        uint256[16] memory statArray = [s.invested, s.withdrawn, s.rewarded, s.contributed, s.transferredTokens, s.receivedTokens, s.xInvested, s.xRewarded, s.xContributed, s.xWithdrawn, s.xTransferredTokens, s.xReceivedTokens, s.reinvested, s.xReinvested, s.claims, s.xClaimed];
        return statArray;
    }

    /// @dev Calculate daily estimate of collateral tokens awarded
    function dailyEstimate(address _customerAddress) public view returns (uint256){
        uint256 share = dividendBalance_.mul(payoutRate_).div(100);

        return (tokenSupply_ > 0) ? share.mul(tokenBalanceLedger_[_customerAddress]).div(tokenSupply_) : 0;
    }

    /// @dev Calculate estimate of daily reward tokens
    function dailyClaimEstimate(address _customerAddress) public view returns (uint256){
        uint256 share = swapBalance_.mul(payoutRate_).div(100);

        return (tokenSupply_ > 0) ? share.mul(tokenBalanceLedger_[_customerAddress]).div(tokenSupply_) : 0;
    }


    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    /// @dev Distribute undividend in and out fees across drip pools and instant divs
    function allocateFees(uint fee) private {
        uint _share = fee.div(100);
        uint _drip = _share.mul(dripFee);
        uint _instant = _share.mul(instantFee);
        uint _swap = fee.safeSub(_drip + _instant);

        //Apply divs
        profitPerShare_ = SafeMath.add(profitPerShare_, (_instant * magnitude) / tokenSupply_);

        //Add to dividend drip pools
        dividendBalance_ += _drip;
        swapCollector_ += _swap;
    }

    // @dev Distribute drip pools
    function distribute() private {

        if (now.safeSub(lastBalance_) > balanceInterval) {
            emit onBalance(totalTokenBalance(), now);
            lastBalance_ = now;
        }


        if (SafeMath.safeSub(now, lastPayout) > distributionInterval && tokenSupply_ > 0) {

            //A portion of the dividend is paid out according to the rate
            uint256 share = dividendBalance_.mul(payoutRate_).div(100).div(24 hours);
            //divide the profit by seconds in the day
            uint256 profit = share * now.safeSub(lastPayout);
            //share times the amount of time elapsed
            dividendBalance_ = dividendBalance_.safeSub(profit);

            //Apply divs
            profitPerShare_ = SafeMath.add(profitPerShare_, (profit * magnitude) / tokenSupply_);


            //Don't distribute if we don't have  sufficient profit
            //A portion of the dividend is paid out according to the rate
            share = swapBalance_.mul(payoutRate_).div(100).div(24 hours);
            //divide the profit by seconds in the day
            profit = share * now.safeSub(lastPayout);

            //share times the amount of time elapsed
            swapBalance_ = swapBalance_.safeSub(profit);

            //Apply claimed token divs
            rewardsProfitPerShare_ = SafeMath.add(rewardsProfitPerShare_, (profit * magnitude) / tokenSupply_);

            processBuyBacks();

            lastPayout = now;

        }


    }


    /// @dev Process buybacks using the router; initial time and size logic gates and orchestration
    function processBuyBacks() private {

        //Only buy once
        if (SafeMath.safeSub(now, lastBuyback) > 1 hours) {

            //Get the amount of the token in ETH and compare to the swapSize
            address[] memory path = new address[](2);
            path[0] = collateralAddress;
            path[1] = swap.WETH();

            uint[] memory amounts = swap.getAmountsOut(swapCollector_, path);

            if (amounts[1] >= depotFlushSize) {

                uint amount = swapCollector_;

                //reset Collector
                swapCollector_ = 0;

                //VLT for ALL
                uint _tokens = buyback(amount);

                totalClaims += _tokens;

                //Add to the pool
                swapBalance_ += _tokens;

                lastBuyback = now;

            }
        }
    }

    //Execute the buyback against the router using WETH as a bridge
    function buyback(uint amount) private returns (uint) {
        address[] memory path = new address[](3);
        path[0] = collateralAddress;
        path[1] = swap.WETH();
        path[2] = vltAddress;

        //Need to be able to approve the collateral token for transfer
        require(cToken.approve(swapAddress, amount), "Amount approved not available");

        uint[] memory amounts = swap.swapExactTokensForTokens(amount, 1, path, address(this), now + 24 hours);

        //2nd index is token amount
        emit onBuyBack(amount, amounts[2], now);

        return amounts[2];

    }

    /// @dev Internal function to actually purchase the tokens.
    function purchaseTokens(address _customerAddress, uint256 _incomingtokens) internal returns (uint256) {

        /* Members */
        if (stats[_customerAddress].invested == 0 && stats[_customerAddress].receivedTokens == 0) {
            players += 1;
        }

        totalTxs += 1;

        // data setup
        uint256 _undividedDividends = SafeMath.mul(_incomingtokens, entryFee_) / 100;
        uint256 _amountOfTokens = SafeMath.sub(_incomingtokens, _undividedDividends);

        // fire event
        emit onTokenPurchase(_customerAddress, _incomingtokens, _amountOfTokens, now);

        // yes we know that the safemath function automatically rules out the "greater then" equation.
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_, "Tokens need to be positive");


        // we can't give people infinite eth
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ += _amountOfTokens;

        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        // really i know you think you do but you don't
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        _updatedPayouts = (int256) (rewardsProfitPerShare_ * _amountOfTokens);
        stats[_customerAddress].tokenPayoutsTo += _updatedPayouts;

        //drip and buybacks; instant requires being called after supply is updated
        allocateFees(_undividedDividends);

        //Stats
        stats[_customerAddress].invested += _incomingtokens;
        stats[_customerAddress].xInvested += 1;

        return _amountOfTokens;
    }

    /*==========================================
    =            ADMIN FUNCTIONS               =
    ==========================================*/


    /**
    * @dev Update the router address to account for movement in liquidity long term
    */
    function updateSwapRouter(address _swapAddress) onlyOwner() public {

        emit onRouterUpdate(swapAddress, _swapAddress);
        swapAddress = _swapAddress;
        swap = UniSwapV2LiteRouter(_swapAddress);
    }

    /**
    * @dev Update the flushSize (how often buy backs happen in terms of amount of ETH accumulated)
    */
    function updateFlushSize(uint _flushSize) onlyOwner() public {
        require(_flushSize >= 0.01 ether && _flushSize <= 5 ether, "Flush size is out of range");

        emit onFlushUpdate(depotFlushSize, _flushSize);
        depotFlushSize = _flushSize;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Subtracts two numbers, else returns zero */
    function safeSub(uint a, uint b) internal pure returns (uint) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}