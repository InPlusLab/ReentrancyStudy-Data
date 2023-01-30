/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity ^0.4.25;


interface ERC20 {
    function totalSupply() external view returns (uint256 supply);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function decimals() external view returns (uint256 digits);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract Swap3D {
    
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }

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

    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 tokens
    );

    string public name = "Swap3D";
    string public symbol = "S3D";
    uint8 public constant decimals = 18;
    uint8 internal constant dividendFee_ = 10; // 10%
    uint8 internal constant sellFee_ = 10; // 10%
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 internal constant magnitude = 2**64;
    address internal constant tokenAddress = address(0xCC4304A31d09258b0029eA7FE63d032f52e44EFe);  // TrustSwap (SWAP) token address
    ERC20 internal constant _contract = ERC20(tokenAddress);

    // Admin for premine lock 
    address internal administrator;
    uint256 public stakingRequirement = 10e18; // 10 SWAP minimum 
    uint256 public releaseTime = 1594728000; // Tuesday, July 14, 2020 12:00:00 PM GMT

    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

    constructor() public {
        administrator = msg.sender;
    }

    function() external payable {
        revert();
    }
    
    function checkAndTransfer(uint256 _amount) private {
        require(
            _contract.transferFrom(
                msg.sender, 
                address(this), 
                _amount
            ) == true, "transfer must succeed"
        );
    }

    function buy(uint256 _amount, address _referredBy) public returns(uint256) {
        checkAndTransfer(_amount);
        
        return purchaseTokens(
            _amount, 
            _referredBy, 
            msg.sender
        );
    }

    function reinvest() public onlyStronghands() {
        uint256 _dividends = myDividends(false); 

        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        uint256 _tokens = purchaseTokens(
            _dividends, 
            address(0x0), 
            _customerAddress
        );
        
        emit onReinvestment(
            _customerAddress,
            _dividends,
            _tokens
        );
    }

    function exit() public {
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);
        withdraw();
    }

    function withdraw() public onlyStronghands() {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false);

        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        _contract.transfer(_customerAddress, _dividends);

        emit onWithdraw(
            _customerAddress,
            _dividends
        );
    }

    function sell(uint256 _amountOfTokens) public onlyBagholders() {
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div((_ethereum * sellFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _tokens
        );

        int256 _updatedPayouts = (int256)(profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(
                profitPerShare_,
                (_dividends * magnitude) / tokenSupply_
            );
        }

        // fire sell event
        emit onTokenSell(
            _customerAddress,
            _tokens,
            _taxedEthereum
        );
        
        // fire burn event 
        emit Transfer(
            _customerAddress,
            address(0x0000000000000000000000000000000000000000),
            _tokens
        );
    }

    function transfer(address _toAddress, uint256 _amountOfTokens)
        public
        onlyBagholders()
        returns (bool)
    {
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
        if (myDividends(true) > 0) withdraw(); // withdraw divs if any 

        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );
        
        tokenBalanceLedger_[_toAddress] = SafeMath.add(
            tokenBalanceLedger_[_toAddress],
            _amountOfTokens
        );

        payoutsTo_[_customerAddress] -= (int256)(profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256)(profitPerShare_ * _amountOfTokens);

        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

        // ERC20
        return true;
    }

    /**
     * Method to view the current TrustSwap stored in the contract
     * Example: totalSwapBalance()
     */
    function totalSwapBalance() public view returns (uint256) {
        return _contract.balanceOf(address(this));
    }

    /**
     * Retrieve the total S3D supply.
     */
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
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
     * Retrieve the S3D token balance of any single address.
     */
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }
    
    /**
     * Retrieve the SWAP token balance of any single address.
     * You can call the SWAP contract directly, but the front end will thank you if you just do this one here.
     */
    function swapBalanceOf(address _customerAddress) public view returns (uint256) {
        return _contract.balanceOf(address(_customerAddress));
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
            uint256 _dividends = SafeMath.div((_ethereum * sellFee_), 100);
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
    
    /**
     * Function for the frontend to fetch all data in one call 
     */
    function getData()
        public 
        view 
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            // [0] - Total SWAP in contract 
            totalSwapBalance(),
            
            // [1] - Total supply of S3D
            totalSupply(),
            
            // [2] - S3D balance of msg.sender 
            balanceOf(msg.sender),
            
            // [3] - Referral balance of msg.sender
            getReferralBalance(msg.sender),
            
            // [4] - Dividends of msg.sender 
            dividendsOf(msg.sender),
            
            // [5] - Sell price of 1 token 
            sellPrice(),
            
            // [6] - Buy price of 1 token 
            buyPrice(),
            
            // [7] - Balance of SWAP token in user's wallet (free balance that isn't staked)
            swapBalanceOf(msg.sender)
        );
    }

    function purchaseTokens(
        uint256 _incomingEthereum,
        address _referredBy,
        address _sender
    ) 
        internal 
        returns (uint256) 
    {
        require((block.timestamp >= releaseTime) || (_sender == administrator));
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

        if (
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&
            // no cheating!
            _referredBy != _customerAddress &&
            // does the referrer meet the staking requirement?
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

        // we can't give people infinite tokens 
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

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        int256 _updatedPayouts = (int256)((profitPerShare_ * _amountOfTokens) - _fee);
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

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}