/**

 *Submitted for verification at Etherscan.io on 2018-11-16

*/



pragma solidity ^0.4.25;



contract NeverEndingToken {





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



    string public name = "Never Ending Token";

    string public symbol = "NET"; // (Never Ending Token)

    uint8 constant public decimals = 18;



    /// @dev 15% dividends for token purchase

    uint8 constant internal entryFee_ = 15;



    /// @dev 4% dividends for token transfer

    uint8 constant internal transferFee_ = 4;



    /// @dev 5% dividends for token selling

    uint8 constant internal exitFee_ = 5;



    /// @dev 35% masternode

    uint8 constant internal refferalFee_ = 35;



    uint256 constant internal tokenPriceInitial_ = 0.000000000001 ether;

    uint256 constant internal tokenPriceIncremental_ = 0.0000000000009 ether;

    uint256 constant internal magnitude = 2 ** 64;



    /// @dev 100 Never Ending App Tokens needed for masternode activation

    uint256 public stakingRequirement = 100e18;

    

    // 8% Total extra fee to keep the FOMO going

    

    // Dev (3%)

    address internal devFeeAddress = 0xBf7da5d6236ad9A375E5121466bc6b0925E6CbB7;

    // Yes we need to pay for marketing (1% buy)

    address internal marketingFeeAddress = 0xBf7da5d6236ad9A375E5121466bc6b0925E6CbB7;

    // To make it rain dividends once in a while (1% sell)

    address internal feedingFeeAddress = 0x5aFa2A530B83E239261Aa46C6c29c9dF371FAA62;

    // Website and community runners (1% buy)

    address internal employeeFeeAddress1 = 0xa4940d54f21cb7d28ddfcd6c058a428704c08360; 

    // Admin/Moderator

    address internal employeeFeeAddress2 = 0xBf7da5d6236ad9A375E5121466bc6b0925E6CbB7;

    // Admin/Moderator

    address internal employeeFeeAddress3 = 0x5aFa2A530B83E239261Aa46C6c29c9dF371FAA62;

    

    address internal admin;

    mapping(address => bool) internal ambassadors_;





   /*=================================

    =            DATASETS            =

    ================================*/



    // amount of shares for each address (scaled number)

    mapping(address => uint256) internal tokenBalanceLedger_;

    mapping(address => uint256) internal referralBalance_;

    mapping(address => int256) internal payoutsTo_;

    uint256 internal tokenSupply_;

    uint256 internal profitPerShare_;

    uint256 constant internal ambassadorMaxPurchase_ = 0.55 ether;

    uint256 constant internal ambassadorQuota_ = 500 ether;

    bool public onlyAmbassadors = true;

    mapping(address => uint256) internal ambassadorAccumulatedQuota_;

    

    uint ACTIVATION_TIME = 1542378600;

    

    modifier antiEarlyWhale(uint256 _amountOfEthereum){

        if (now >= ACTIVATION_TIME) {

            onlyAmbassadors = false;

        }

        // are we still in the vulnerable phase?

        // if so, enact anti early whale protocol 

        if(onlyAmbassadors){

            require(

                // is the customer in the ambassador list?

                (ambassadors_[msg.sender] == true &&

                

                // does the customer purchase exceed the max ambassador quota?

                (ambassadorAccumulatedQuota_[msg.sender] + _amountOfEthereum) <= ambassadorMaxPurchase_)

                

            );

            

            // updated the accumulated quota    

            ambassadorAccumulatedQuota_[msg.sender] = SafeMath.add(ambassadorAccumulatedQuota_[msg.sender], _amountOfEthereum);

        

            // execute

            _;

        }else{

            onlyAmbassadors=false;

            _;

        }

        

    }

    

    

    function NeverEndingApp() public{

        admin=msg.sender;

                

        ambassadors_[0x77c192342F25a364FB17C25cdDddb194a8d34991] = true; // 

        ambassadors_[0xE206201116978a48080C4b65cFA4ae9f03DA3F0D] = true; // 

        ambassadors_[0x21adD73393635b26710C7689519a98b09ecdc474] = true; // 

        ambassadors_[0xEc31176d4df0509115abC8065A8a3F8275aafF2b] = true; // 

        ambassadors_[0xc7F15d0238d207e19cce6bd6C0B85f343896F046] = true; //

        ambassadors_[0xBa21d01125D6932ce8ABf3625977899Fd2C7fa30] = true; //

        ambassadors_[0x2277715856C6d9E0181BA01d21e059f76C79f2bD] = true; //

        ambassadors_[0xB1dB0FB75Df1cfb37FD7fF0D7189Ddd0A68C9AAF] = true; //

        ambassadors_[0xEafE863757a2b2a2c5C3f71988b7D59329d09A78] = true; //

        ambassadors_[0xBf7da5d6236ad9A375E5121466bc6b0925E6CbB7] = true; // 

        ambassadors_[0xB19772e5E8229aC499C67E820Db53BF52dbaf0dE] = true; //        

        ambassadors_[0x42830382f378d083A8Ae55Eb729A9d789fA4dEA6] = true; //

        ambassadors_[0x87f7a5708e384407B4ED494bE1ff22aE68aB11F9] = true; //

        ambassadors_[0x53e1eB6a53d9354d43155f76861C5a2AC80ef361] = true; //  

        ambassadors_[0x267fa9F2F846da2c7A07eCeCc52dF7F493589098] = true; // 

        

        



    }

    

  function disableAmbassadorPhase() public{

        require(admin==msg.sender);

        onlyAmbassadors=false;

    }

    

  function changeEmployee1(address _employeeAddress1) public{

        require(admin==msg.sender);

        employeeFeeAddress1=_employeeAddress1;

    }

    

  function changeEmployee2(address _employeeAddress2) public{

        require(admin==msg.sender);

        employeeFeeAddress2=_employeeAddress2;

    }

    

  function changeEmployee3(address _employeeAddress3) public{

        require(admin==msg.sender);

        employeeFeeAddress3=_employeeAddress3;

    }

    

  function changeMarketing(address _marketingAddress) public{

        require(admin==msg.sender);

        marketingFeeAddress=_marketingAddress;

    }

    

    /*=======================================

    =            PUBLIC FUNCTIONS           =

    =======================================*/



    /// @dev Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)

    function buy(address _referredBy) public payable returns (uint256) {

        purchaseTokens(msg.value, _referredBy);

    }



    /**

     * @dev Fallback function to handle ethereum that was send straight to the contract

     *  Unfortunately we cannot use a referral address this way.

     */

    function() payable public {

        purchaseTokens(msg.value, 0x0);

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

        uint256 _tokens = purchaseTokens(_dividends, 0x0);



        // fire event

         onReinvestment(_customerAddress, _dividends, _tokens);

    }



    /// @dev Alias of sell() and withdraw().

    function exit() public {

        // get token count for caller & sell them all

        address _customerAddress = msg.sender;

        uint256 _tokens = tokenBalanceLedger_[_customerAddress];

        if (_tokens > 0) sell(_tokens);



        // lambo delivery service

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

         onWithdraw(_customerAddress, _dividends);

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

        uint256 _devFee = SafeMath.div(SafeMath.mul(_ethereum, 1), 100);

        uint256 _marketingFee = SafeMath.div(SafeMath.mul(_ethereum, 1), 100);

        uint256 _feedingFee = SafeMath.div(SafeMath.mul(_ethereum, 1), 100);

        

        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _devFee), _marketingFee), _feedingFee);



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

        devFeeAddress.transfer(_devFee);

        marketingFeeAddress.transfer(_marketingFee);

        feedingFeeAddress.transfer(_feedingFee);

        // fire event

         onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());

       

    }





    /**

     * @dev Transfer tokens from the caller to a new holder.

     *  Remember, there's a 5% fee here as well.

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



        // liquify 5% of the tokens that are transfered

        // these are dispersed to shareholders

        uint256 _tokenFee = SafeMath.div(SafeMath.mul(_amountOfTokens, transferFee_), 100);

        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);

        uint256 _dividends = tokensToEthereum_(_tokenFee);



        // burn the fee tokens

        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);



        // exchange tokens

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);



        // update dividend trackers

        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);

        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);



        // disperse dividends among holders

        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);



        // fire event

         Transfer(_customerAddress, _toAddress, _taxedTokens);



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

        return this.balance;

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

            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, entryFee_), 100);

            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);



            return _taxedEthereum;

        }

    }



    /// @dev Function for the frontend to dynamically retrieve the price scaling of buy orders.

    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns (uint256) {

        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, entryFee_), 100);

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





    /*==========================================

    =            INTERNAL FUNCTIONS            =

    ==========================================*/



    /// @dev Internal function to actually purchase the tokens.

    function purchaseTokens(uint256 _incomingEthereum, address _referredBy) antiEarlyWhale(_incomingEthereum)

       internal returns (uint256) {

        // data setup

        address _customerAddress = msg.sender;

        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, entryFee_), 100);

        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, refferalFee_), 100);

        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);

        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);

        _taxedEthereum = SafeMath.sub(_taxedEthereum, SafeMath.div(SafeMath.mul(_incomingEthereum, 3), 100));

        _taxedEthereum = SafeMath.sub(_taxedEthereum, SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        _taxedEthereum = SafeMath.sub(_taxedEthereum, SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        _taxedEthereum = SafeMath.sub(_taxedEthereum, SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        _taxedEthereum = SafeMath.sub(_taxedEthereum, SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        _taxedEthereum = SafeMath.sub(_taxedEthereum, SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        

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

         onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());

        devFeeAddress.transfer(SafeMath.div(SafeMath.mul(_incomingEthereum, 3), 100));

        marketingFeeAddress.transfer(SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        feedingFeeAddress.transfer(SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        employeeFeeAddress1.transfer(SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        employeeFeeAddress2.transfer(SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

        employeeFeeAddress3.transfer(SafeMath.div(SafeMath.mul(_incomingEthereum, 1), 100));

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