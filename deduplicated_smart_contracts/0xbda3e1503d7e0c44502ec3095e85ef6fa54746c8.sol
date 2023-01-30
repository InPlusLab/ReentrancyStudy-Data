/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.4.25;

/*
* FETH
*��ٵ�ETH
*
* FETH��һ�����ܺ�Լʵ�飬���Ϊ���ڹ�Ϣ�Ĵ��ң��ɴ�ÿ�����������з����Ϣ��ÿ�ι������ʱ����һ�����ҵļ۸񶼻����ӣ����������д��ҳ����߷����Ϣ��ÿ���۳�����ʱ����һ�����ҵļ۸񶼻ή�ͣ��������д��ҳ����߷����Ϣ��
*��ĳ�˹���FETHʱ��FETH������ƽ������5������95����ΪFETH�˻�������
*��ĳ������FETHʱ��FETH������ƽ������10����90����ΪETH�˻�����������Ϊ�˹����������Ʋ���ֹ�� pump and dumps����
*
*Ҫ����FETH�������Խ�ETH���͵���Լ��ַ�����߿�����etherscan�Ͻ�������д�����ܺ�Լ����ÿ�ι���֮�󶼻��Զ���ʼ��ȡ��Ϣ��
*
*Ҫ����FETH����������etherscan�ϱ�д�˳����ܣ����߿���ʹ��0xe9fad8ee���˳����ܵĴ��룩�����׷��͵���ͬ��ַ��ȷ��Ϊ�������������ơ�
*
*Ҫ�鿴���ж��ٴ��ң����ж��ٹ�������ǰ���Ҽ۸��Ƕ��٣����߿������������ܺ�Լ���н����Ĺ����б����򣬳��ۣ�ת�ƣ����˳���
*ת��etherscan�ϵĺ�ͬѡ���Ȼ�󵥻�����ȡ��ͬ����д���ͬ��
*
* FETH���а�ȫϵ�����������Է�ֹPOWH�е���ʧ�����Ƶ����ܺ�Լ�Ѿ�ʹ�ܶ���׬�˺ܶ�Ǯ���������ܱ�֤�κ��˵��������Ե����ա�
*
* FETH����վ���ڽ����У��⽫ʹ���ٴ��������ͼ۸�������ף�����ʹ��ͬ�����������ס���վ���ӳ�������ʵ�����Ҫ���֡���վ����ʱ�� FETH.io    ���ǻ��ڴ��������������ǻ�ȵ���ʱ�Ź����ǳ�����㹺��ֻ��ʱ�������𰸡�

* ף����
* FETH
* Fake ETH
* 
* FETH is a smart contract experiment designed as dividend based token that distributes dividends from every buy and sell transaction. Every time a token is purchased, the price of the next token increases and a dividend is given out to all token holders. Every time a token is sold, the price of the next token decreases and a dividend is given out to all token holders.
* When someone buys FETH, 5% is distributed evenly among FETH holders, and 95% is returned to you as FETH.
* When someone sells FETH, 10% is distributed evenly among FETH holders, and 90% is returned to you as ETH. This is to encourage token holding and prevent "pump and dumps".
* 
* To buy FETH, you can send ETH to the contract address, or you can write the buy function to the smart contract on etherscan. You will automatically start collection dividends on each buy and sell after yours.
*
* To sell FETH, you can write the exit function on etherscan, or you can send a transaction to the contract address with 0xe9fad8ee (the code for the exit function). Make sure to increase gas limit for this.
*
* To see how many tokens you have, how many dividends you have, what the current token price is, or a list of functions that you can use to interact with the smart contract (buy, sell, transfer, withdraw, exit)
* Go to the contract tab on etherscan and click "read contract" or "write contract"
*
* FETH has safemath parameters to prevent drains like in POWH, and similar smart contracts have made a lot of people a lot of money, but does not guarantee profit for anybody. Please participate at your own risk.
*
* FETH has a website in progress which will allow for easier tracking of token amounts and prices, and easier contract interaction.   FETH.io   The delayed launch of the website is the main part of the experiment. Will people anticipate a large amount of volume when the website launches? Will people wait to buy until then or try to get in early? Only time will tell.

* Good Luck
*/

contract FETH {


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

    string public name = "FETH";
    string public symbol = "FETH";
    uint8 constant public decimals = 18;

    /// @dev 5% dividends for token purchase
    uint8 constant internal entryFee_ = 5;

    /// @dev 0% dividends for token transfer
    uint8 constant internal transferFee_ = 0;

    /// @dev 10% dividends for token selling
    uint8 constant internal exitFee_ = 10;

    /// @dev 33% of entryFee_ (i.e. 1.66% dividends) is given to referrer
    uint8 constant internal refferalFee_ = 33;

    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2 ** 64;

    /// @dev proof of stake (defaults at 50 tokens)
    uint256 public stakingRequirement = 50e18;


   /*=================================
    =            DATASETS            =
    ================================*/

    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_;
    uint256 internal profitPerShare_;


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
        onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());
    }


    /**
     * @dev Transfer tokens from the caller to a new holder.
     *  
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
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy) internal returns (uint256) {
        // data setup
        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, entryFee_), 100);
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
        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());

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