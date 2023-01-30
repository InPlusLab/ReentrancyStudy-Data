/**

 *Submitted for verification at Etherscan.io on 2018-11-24

*/



pragma solidity ^0.4.24;

/***

 *  _____               _            __   ___ _____ _  _

 * |_   _|__ _ __  _ __| |___   ___ / _| | __|_   _| || |

 *   | |/ -_) '  \| '_ \ / -_) / _ \  _| | _|  | | | __ |

 *   |_|\___|_|_|_| .__/_\___| \___/_|   |___| |_| |_||_|

 *                    |_|

 * https://templeofeth.io

 *

 * The Temple.

 *

 * Volume Based Entry Fees

 * 0-10 eth 40%

 * 10-20 eth 35%

 * 20-50 eth 30%

 * 50-100 eth 25%

 * 100- 250 eth 20%

 * 250- infinity 15%

 *

 * Masternode referral bonus 33% of entry fee

 * Exit Fee: 15% - always.

 *

 * Temple Warning: Do not play with more than you can afford to lose.

 *

 */



contract TempleOfETH {



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

        require(myDividends(true) > 0);

        _;

    }



    /// @dev easyOnTheGas

    modifier easyOnTheGas() {

      require(tx.gasprice < 200999999999);

      _;

    }



    /// @dev Preventing unstable dumping and limit ambassador mine

    modifier antiEarlyWhale {

        if (address(this).balance  -msg.value < whaleBalanceLimit){

          require(msg.value <= maxEarlyStake);

        }

        if (depositCount_ == 0){

          require(ambassadors_[msg.sender] && msg.value == 1 ether);

        }else

        if (depositCount_ < 6){

          require(ambassadors_[msg.sender] && msg.value == 0.8 ether);

        }

        _;

    }



    /// @dev easyOnTheGas

    modifier isControlled() {

      require(isPremine() || isStarted());

      _;

    }



    /*==============================

    =            EVENTS            =

    ==============================*/



    event onTokenPurchase(

        address indexed customerAddress,

        uint256 incomingEthereum,

        uint256 tokensMinted,

        address indexed referredBy,

        uint timestamp,

        uint256 price

    );



    event onTokenSell(

        address indexed customerAddress,

        uint256 tokensBurned,

        uint256 ethereumEarned,

        uint timestamp,

        uint256 price

    );



    event onReinvestment(

        address indexed customerAddress,

        uint256 ethereumReinvested,

        uint256 tokensMinted

    );



    event onWithdraw(

        address indexed customerAddress,

        uint256 ethereumWithdrawn

    );



    // ERC20

    event Transfer(

        address indexed from,

        address indexed to,

        uint256 tokens

    );





    /*=====================================

    =            CONFIGURABLES            =

    =====================================*/



    string public name = "TempleOfETH Token";

    string public symbol = "TMPL";

    uint8 constant public decimals = 18;



    /// @dev 15% dividends for token selling

    uint8 constant internal exitFee_ = 15;



    /// @dev 33% masternode

    uint8 constant internal refferalFee_ = 33;



    /// @dev P3D pricing

    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;

    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;



    uint256 constant internal magnitude = 2 ** 64;



    /// @dev 100 needed for masternode activation

    uint256 public stakingRequirement = 100e18;



    /// @dev anti-early-whale

    uint256 public maxEarlyStake = 2.5 ether;

    uint256 public whaleBalanceLimit = 100 ether;



    /// @dev light the fuse

    address public fuse;



    /// @dev starting

    uint256 public startTime = 0; //  January 1, 1970 12:00:00



    /// @dev one shot

    bool public startCalled = false; //  January 1, 1970 12:00:00





   /*=================================

    =            DATASETS            =

    ================================*/



    // amount of shares for each address (scaled number)

    mapping(address => uint256) internal tokenBalanceLedger_;

    mapping(address => uint256) internal referralBalance_;

    mapping(address => int256) internal payoutsTo_;

    uint256 internal tokenSupply_;

    uint256 internal profitPerShare_;

    uint256 public depositCount_;



    mapping(address => bool) internal ambassadors_;



    /*=======================================

    =            CONSTRUCTOR                =

    =======================================*/



   constructor () public {



     fuse = msg.sender;

     // Masternode sales & promotional fund

     ambassadors_[fuse]=true;

     //cadmael

     ambassadors_[0xE4042aE1C40913bA00619392DE669BdB3becEd50]=true;

     //theodor

     ambassadors_[0xBAce3371fd1E65DD0255DDef233bD16bFa374DB2]=true;

     //khan

     ambassadors_[0x05f2c11996d73288AbE8a31d8b593a693FF2E5D8]=true;

     //karu

     ambassadors_[0x54d6fCa0CA37382b01304E6716420538604b447b]=true;

     //mart

     ambassadors_[0xaa49BF121D1C4498E3A4a1ADdA6860B9eB40fdDF]=true;



   }



    /*=======================================

    =            PUBLIC FUNCTIONS           =

    =======================================*/



    // @dev Function setting the start time of the system

    function setStartTime(uint256 _startTime) public {

      require(msg.sender==fuse && !isStarted() && now < _startTime && !startCalled);

      require(_startTime > now);

      startTime = _startTime;

      startCalled = true;

    }



    /// @dev Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)

    function buy(address _referredBy) antiEarlyWhale easyOnTheGas isControlled public payable  returns (uint256) {

        purchaseTokens(msg.value, _referredBy , msg.sender);

    }



    /// @dev Converts to tokens on behalf of the customer - this allows gifting and integration with other systems

    function purchaseFor(address _referredBy, address _customerAddress) antiEarlyWhale easyOnTheGas isControlled public payable returns (uint256) {

        purchaseTokens(msg.value, _referredBy , _customerAddress);

    }



    /**

     * @dev Fallback function to handle ethereum that was send straight to the contract

     *  Unfortunately we cannot use a referral address this way.

     */

    function() antiEarlyWhale easyOnTheGas isControlled payable public {

        purchaseTokens(msg.value, 0x0 , msg.sender);

    }



    /// @dev Converts all of caller's dividends to tokens.

    function reinvest() onlyStronghands public {

        // fetch dividends

        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code



        // pay out the dividends virtually

        address _customerAddress = msg.sender;

        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);



        // retrieve ref. bonus

        _dividends += referralBalance_[_customerAddress];

        referralBalance_[_customerAddress] = 0;



        // dispatch a buy order with the virtualized "withdrawn dividends"

        uint256 _tokens = purchaseTokens(_dividends, 0x0 , _customerAddress);



        // fire event

        emit onReinvestment(_customerAddress, _dividends, _tokens);

    }



    /// @dev Alias of sell() and withdraw().

    function exit() public {

        // get token count for caller & sell them all

        address _customerAddress = msg.sender;

        uint256 _tokens = tokenBalanceLedger_[_customerAddress];

        if (_tokens > 0) sell(_tokens);



        // capitulation

        withdraw();

    }



    /// @dev Withdraws all of the callers earnings.

    function withdraw() onlyStronghands public {

        // setup data

        address _customerAddress = msg.sender;

        uint256 _dividends = myDividends(false); // get ref. bonus later in the code



        // update dividend tracker

        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);



        // add ref. bonus

        _dividends += referralBalance_[_customerAddress];

        referralBalance_[_customerAddress] = 0;



        // lambo delivery service

        _customerAddress.transfer(_dividends);



        // fire event

        emit onWithdraw(_customerAddress, _dividends);

    }



    /// @dev Liquifies tokens to ethereum.

    function sell(uint256 _amountOfTokens) onlyBagholders public {

        // setup data

        address _customerAddress = msg.sender;

        // russian hackers BTFO

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        uint256 _tokens = _amountOfTokens;

        uint256 _ethereum = tokensToEthereum_(_tokens);

        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);

        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);



        // burn the sold tokens

        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);



        // update dividends tracker

        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));

        payoutsTo_[_customerAddress] -= _updatedPayouts;



        // dividing by zero is a bad idea

        if (tokenSupply_ > 0) {

            // update the amount of dividends per token

            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

        }



        // fire event

        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());

    }





    /**

     * @dev Transfer tokens from the caller to a new holder.

     */

    function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders public returns (bool) {

        // setup

        address _customerAddress = msg.sender;



        // make sure we have the requested tokens

        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);



        // withdraw all outstanding dividends first

        if (myDividends(true) > 0) {

            withdraw();

        }



        return transferInternal(_toAddress,_amountOfTokens,_customerAddress);

    }



    function transferInternal(address _toAddress, uint256 _amountOfTokens , address _fromAddress) internal returns (bool) {

        // setup

        address _customerAddress = _fromAddress;



        // exchange tokens

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);



        // update dividend trackers

        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);

        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);



        // fire event

        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);



        // ERC20

        return true;

    }





    /*=====================================

    =      HELPERS AND CALCULATORS        =

    =====================================*/



    /**

     * @dev Method to view the current Ethereum stored in the contract

     *  Example: totalEthereumBalance()

     */

    function totalEthereumBalance() public view returns (uint256) {

        return address(this).balance;

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

     *  If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.

     *  The reason for this, is that in the frontend, we will want to get the total divs (global + ref)

     *  But in the internal calculations, we want them separate.

     */

    function myDividends(bool _includeReferralBonus) public view returns (uint256) {

        address _customerAddress = msg.sender;

        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;

    }



    /// @dev Retrieve the token balance of any single address.

    function balanceOf(address _customerAddress) public view returns (uint256) {

        return tokenBalanceLedger_[_customerAddress];

    }



    /// @dev Retrieve the dividend balance of any single address.

    function dividendsOf(address _customerAddress) public view returns (uint256) {

        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;

    }



    /// @dev Return the sell price of 1 individual token.

    function sellPrice() public view returns (uint256) {

        // our calculation relies on the token supply, so we need supply. Doh.

        if (tokenSupply_ == 0) {

            return tokenPriceInitial_ - tokenPriceIncremental_;

        } else {

            uint256 _ethereum = tokensToEthereum_(1e18);

            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);

            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);



            return _taxedEthereum;

        }

    }



    /// @dev Return the buy price of 1 individual token.

    function buyPrice() public view returns (uint256) {

        // our calculation relies on the token supply, so we need supply. Doh.

        if (tokenSupply_ == 0) {

            return tokenPriceInitial_ + tokenPriceIncremental_;

        } else {

            uint256 _ethereum = tokensToEthereum_(1e18);

            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, entryFee()), 100);

            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);



            return _taxedEthereum;

        }

    }



    /// @dev Function for the frontend to dynamically retrieve the price scaling of buy orders.

    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns (uint256) {

        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, entryFee()), 100);

        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        return _amountOfTokens;

    }



    /// @dev Function for the frontend to dynamically retrieve the price scaling of sell orders.

    function calculateEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {

        require(_tokensToSell <= tokenSupply_);

        uint256 _ethereum = tokensToEthereum_(_tokensToSell);

        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);

        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        return _taxedEthereum;

    }



    /// @dev Function for the frontend to get untaxed receivable ethereum.

    function calculateUntaxedEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {

        require(_tokensToSell <= tokenSupply_);

        uint256 _ethereum = tokensToEthereum_(_tokensToSell);

        //uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee()), 100);

        //uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        return _ethereum;

    }



    function entryFee() public view returns (uint8){

      uint256 volume = address(this).balance  - msg.value;



      if (volume<=10 ether){

        return 40;

      }

      if (volume<=20 ether){

        return 35;

      }

      if (volume<=50 ether){

        return 30;

      }

      if (volume<=100 ether){

        return 25;

      }

      if (volume<=250 ether){

        return 20;

      }

      return 15;

    }



    // @dev Function for find if premine

    function isPremine() public view returns (bool) {

      return depositCount_<=5;

    }



    // @dev Function for find if premine

    function isStarted() public view returns (bool) {

      return startTime!=0 && now > startTime;

    }



    /*==========================================

    =            INTERNAL FUNCTIONS            =

    ==========================================*/



    /// @dev Internal function to actually purchase the tokens.

    function purchaseTokens(uint256 _incomingEthereum, address _referredBy , address _customerAddress) internal returns (uint256) {

        // data setup

        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, entryFee()), 100);

        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, refferalFee_), 100);

        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);

        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        uint256 _fee = _dividends * magnitude;



        // no point in continuing execution if OP is a poorfag russian hacker

        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world

        // (or hackers)

        // and yes we know that the safemath function automatically rules out the "greater then" equasion.

        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);



        // is the user referred by a masternode?

        if (

            // is this a referred purchase?

            _referredBy != 0x0000000000000000000000000000000000000000 &&



            // no cheating!

            _referredBy != _customerAddress &&



            // does the referrer have at least X whole tokens?

            // i.e is the referrer a godly chad masternode

            tokenBalanceLedger_[_referredBy] >= stakingRequirement

        ) {

            // wealth redistribution

            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);

        } else {

            // no ref purchase

            // add the referral bonus back to the global dividends cake

            _dividends = SafeMath.add(_dividends, _referralBonus);

            _fee = _dividends * magnitude;

        }



        // we can't give people infinite ethereum

        if (tokenSupply_ > 0) {

            // add tokens to the pool

            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);



            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder

            profitPerShare_ += (_dividends * magnitude / tokenSupply_);



            // calculate the amount of tokens the customer receives over his purchase

            _fee = _fee - (_fee - (_amountOfTokens * (_dividends * magnitude / tokenSupply_)));

        } else {

            // add tokens to the pool

            tokenSupply_ = _amountOfTokens;

        }



        // update circulating supply & the ledger address for the customer

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);



        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;

        // really i know you think you do but you don't

        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens - _fee);

        payoutsTo_[_customerAddress] += _updatedPayouts;



        // fire event

        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());



        // Keep track

        depositCount_++;

        return _amountOfTokens;

    }



    /**

     * @dev Calculate Token price based on an amount of incoming ethereum

     *  It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;

     *  Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.

     */

    function ethereumToTokens_(uint256 _ethereum) internal view returns (uint256) {

        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;

        uint256 _tokensReceived =

         (

            (

                // underflow attempts BTFO

                SafeMath.sub(

                    (sqrt

                        (

                            (_tokenPriceInitial ** 2)

                            +

                            (2 * (tokenPriceIncremental_ * 1e18) * (_ethereum * 1e18))

                            +

                            ((tokenPriceIncremental_ ** 2) * (tokenSupply_ ** 2))

                            +

                            (2 * tokenPriceIncremental_ * _tokenPriceInitial*tokenSupply_)

                        )

                    ), _tokenPriceInitial

                )

            ) / (tokenPriceIncremental_)

        ) - (tokenSupply_);



        return _tokensReceived;

    }



    /**

     * @dev Calculate token sell value.

     *  It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;

     *  Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.

     */

    function tokensToEthereum_(uint256 _tokens) internal view returns (uint256) {

        uint256 tokens_ = (_tokens + 1e18);

        uint256 _tokenSupply = (tokenSupply_ + 1e18);

        uint256 _etherReceived =

        (

            // underflow attempts BTFO

            SafeMath.sub(

                (

                    (

                        (

                            tokenPriceInitial_ + (tokenPriceIncremental_ * (_tokenSupply / 1e18))

                        ) - tokenPriceIncremental_

                    ) * (tokens_ - 1e18)

                ), (tokenPriceIncremental_ * ((tokens_ ** 2 - tokens_) / 1e18)) / 2

            )

        / 1e18);



        return _etherReceived;

    }



    /// @dev This is where all your gas goes.

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = (x + 1) / 2;

        y = x;



        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



}