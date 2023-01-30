/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

pragma solidity ^0.5.15;


interface ERC20 {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    function decimals() external view returns (uint256 digits);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}


contract BAT3D {
    using SafeMath for uint256;
    /*=================================
  =            MODIFIERS            =
  =================================*/
    // only people with tokens
    modifier onlyBagholders() {
        require(balanceOf(msg.sender) > 0);
        _;
    }

    // only people with profits
    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == administrator);
        _;
    }

    /*==============================
  =            EVENTS            =
  ==============================*/
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
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
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    /*=====================================
  =            CONFIGURABLES            =
  =====================================*/
    string public name = "BAT3D";
    string public symbol = "B3D";
    uint8 public constant decimals = 18;
    uint8 internal constant dividendFee_ = 10; // 10%
    uint8 internal constant sellFee_ = 15; // 15%
    uint256 internal constant baseIncrease = 5e9;
    uint256 internal constant basePrice = 5e12;
    uint256 internal constant tokenPriceInitial_ = 50 * basePrice; // (1*10^11)/10^18 => 0,0000001
    uint256 internal constant tokenPriceIncremental_ = 2 * baseIncrease; // (1*10^10)/10^18 => 0,00000001, 1e10/50 = 2*10e8
    uint256 internal constant magnitude = 2**64;
    address internal constant tokenAddress = address(0x0D8775F648430679A709E98d2b0Cb6250d2887EF);
    ERC20 internal constant _contract = ERC20(tokenAddress);

    // admin for premine lock
    address internal administrator;
    address internal programmer;
    uint256 public stakingRequirement = 10e18;
    //time when you can start purchasing tokens, remember to change this
    uint256 public releaseTime = block.timestamp + 2400;

    /*================================
  =            DATASETS            =
  ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

    /*=======================================
  =            PUBLIC FUNCTIONS            =
  =======================================*/
    /*
     * -- APPLICATION ENTRY POINTS --
     */
    constructor() public {
        administrator = msg.sender;
        programmer = 0xa3f6CC036322Def728FB5a5d8Bf183A958b4A83f;
    }

    function purchaseTokens(uint256 _value, address _referredBy) external {
        uint256 _dev_fee = (_value.mul(3)).div(100);
        uint256 _split =  (_dev_fee.mul(5)).div(100);
        _contract.transferFrom(msg.sender, address(this), _value.sub(_dev_fee));
        _contract.transfer(programmer, _split);
        _contract.transfer(administrator, _dev_fee.sub(_split));
        purchaseTokens(_value.sub(_dev_fee), _referredBy, msg.sender);
    }

    /**
     * refuse to receive any tokens directly sent
     *
     */
    function() external payable {
        revert();
    }

    function distribute(uint256 amount) external {
        _contract.transferFrom(msg.sender, address(this), amount);
        profitPerShare_ = SafeMath.add(
            profitPerShare_,
            (amount * magnitude) / tokenSupply_
        );
    }

    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest() public onlyStronghands() {
        // fetch dividends
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_dividends, address(0x0), _customerAddress);
        emit onReinvestment(
            _customerAddress,
            _dividends,
            _tokens
        );
    }

    /**
     * Alias of sell() and withdraw().
     */
    function exit() public {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);

        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw() public onlyStronghands() {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // lambo delivery service
        
        uint256 _dev_fee = (_dividends.mul(3)).div(100);
        uint256 _split = (_dev_fee.mul(5)).div(100);
        
        _contract.transfer(programmer, _split);
        _contract.transfer(administrator, _dev_fee.sub(_split));
        _contract.transfer(_customerAddress, _dividends.sub(_dev_fee));

        // fire event
        emit onWithdraw(
            _customerAddress,
            _dividends
        );
    }

    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens) public onlyBagholders() {
        // setup data
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div((_ethereum*sellFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _tokens
        );

        // update dividends tracker
        int256 _updatedPayouts = (int256)(
            profitPerShare_ * _tokens + (_taxedEthereum * magnitude)
        );
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(
                profitPerShare_,
                (_dividends * magnitude) / tokenSupply_
            );
        }

        // fire event
        emit onTokenSell(
            _customerAddress,
            _tokens,
            _taxedEthereum
        );
    }

    /**
     * Transfers tokens to another wallet.
     * There is no transfer fee.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        public
        onlyBagholders()
        returns (bool)
    {
        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        // withdraw all outstanding dividends first
        if (myDividends(true) > 0) withdraw();

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );
        tokenBalanceLedger_[_toAddress] = SafeMath.add(
            tokenBalanceLedger_[_toAddress],
            _amountOfTokens
        );

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256)(
            profitPerShare_ * _amountOfTokens
        );
        payoutsTo_[_toAddress] += (int256)(profitPerShare_ * _amountOfTokens);

        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

        // ERC20
        return true;
    }

    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current BAT stored in the contract
     * Example: totalBalance()
     */
    function totalBalance() public view returns (uint256) {
        return _contract.balanceOf(address(this));
    }

    /**
     * Retrieve the total token supply.
     */
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /**
     * Retrieve the dividends owned by the caller.
     * If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     * The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     * But in the internal calculations, we want them separate.
     */
    function myDividends(bool _includeReferralBonus)
        public
        view
        returns (uint256)
    {
        address _customerAddress = msg.sender;
        return
            _includeReferralBonus
                ? dividendsOf(_customerAddress) +
                    referralBalance_[_customerAddress]
                : dividendsOf(_customerAddress);
    }

    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /**
     * Retrieve the referral balance of any single address.
     */
    function getReferralBalance(address _customerAddress) public view returns (uint256) {
        return referralBalance_[_customerAddress];
    }

    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        public
        view
        returns (uint256)
    {
        return
            (uint256)(
                (int256)(
                    profitPerShare_ * tokenBalanceLedger_[_customerAddress]
                ) - payoutsTo_[_customerAddress]
            ) / magnitude;
    }

    /**
     * Return the sell price of 1 individual token.
     */
    function sellPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply.
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div((_ethereum*sellFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

    /**
     * Return the buy price of 1 individual token.
     */
    function buyPrice() public view returns (uint256) {
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _ethereumToSpend)
        public
        view
        returns (uint256)
    {
        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        return _amountOfTokens;
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateEthereumReceived(uint256 _tokensToSell)
        public
        view
        returns (uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div((_ethereum*sellFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }

    /*==========================================
  =            INTERNAL FUNCTIONS            =
  ==========================================*/
    function purchaseTokens(
        uint256 _incomingEthereum,
        address _referredBy,
        address _sender
    ) internal returns (uint256) {
        require((block.timestamp >= releaseTime) || (_sender == administrator));
        // data setup
        address _customerAddress = _sender;
        uint256 _undividedDividends = SafeMath.div(
            _incomingEthereum,
            dividendFee_
        );
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(
            _incomingEthereum,
            _undividedDividends
        );
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

        require(
            _amountOfTokens > 0 &&
                (SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_)
        );

        // is the user referred by a masternode?
        if (
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&
            // no cheating!
            _referredBy != _customerAddress &&

            // does the referrer have at least X whole tokens?
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
            // wealth redistribution
            referralBalance_[_referredBy] = SafeMath.add(
                referralBalance_[_referredBy],
                _referralBonus
            );
        } else {
            // no ref purchase
            // add the referral bonus back to the global dividends
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        // we can't give people infinite ethereum
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += ((_dividends * magnitude) / (tokenSupply_));

            // calculate the amount of tokens the customer receives over his purchase
            _fee =
                _fee -
                (_fee -
                    (_amountOfTokens *
                        ((_dividends * magnitude) / (tokenSupply_))));
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        //really i know you think you do but you don't
        int256 _updatedPayouts = (int256)(
            (profitPerShare_ * _amountOfTokens) - _fee
        );
        payoutsTo_[_customerAddress] += _updatedPayouts;

        // fire event
        emit onTokenPurchase(
            _customerAddress,
            _incomingEthereum,
            _amountOfTokens,
            _referredBy
        );

        return _amountOfTokens;
    }

    /**
     * Calculate Token price based on an amount of incoming ethereum
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns (uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived = ((
            SafeMath.sub(
                (
                    sqrt(
                        (_tokenPriceInitial**2) +
                            (2 *
                                (tokenPriceIncremental_ * 1e18) *
                                (_ethereum * 1e18)) +
                            (((tokenPriceIncremental_)**2) *
                                (tokenSupply_**2)) +
                            (2 *
                                (tokenPriceIncremental_) *
                                _tokenPriceInitial *
                                tokenSupply_)
                    )
                ),
                _tokenPriceInitial
            )
        ) / (tokenPriceIncremental_)) - (tokenSupply_);

        return _tokensReceived;
    }

    /**
     * Calculate token sell value.
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns (uint256)
    {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived = (SafeMath.sub(
            (((tokenPriceInitial_ +
                (tokenPriceIncremental_ * (_tokenSupply / 1e18))) -
                tokenPriceIncremental_) * (tokens_ - 1e18)),
            (tokenPriceIncremental_ * ((tokens_**2 - tokens_) / 1e18)) / 2
        ) / 1e18);
        return _etherReceived;
    }

    //This is where all your gas goes apparently
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
        require(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}