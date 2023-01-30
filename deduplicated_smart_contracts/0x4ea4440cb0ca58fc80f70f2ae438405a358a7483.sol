/**
 *Submitted for verification at Etherscan.io on 2020-07-10
*/

pragma solidity ^ 0.4.26;

library SafeMath {

    function mul(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns(uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns(uint256) 
    {
        return a / b;
    }
    
    function sub(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns(uint256) 
    {
        assert(b <= a);
        return a - b;
    }
    
    function add(
        uint256 a, 
        uint256 b
    ) 
        internal 
        pure 
        returns(uint256 c) 
    {
        c = a + b;
        assert(c >= a);
        return c;
    }

}


contract IERC20 {

    function totalSupply() 
        external 
        view 
        returns(uint256);
    
    function balanceOf(
        address account
    ) 
        external 
        view 
        returns(uint256);
    
    function transfer(
        address recipient, 
        uint256 amount
    ) 
        external 
        returns(bool);
    
    function allowance(
        address owner, 
        address spender
    ) 
        external 
        view 
        returns(uint256);
    
    function approve(
        address spender, 
        uint256 amount
    ) 
        external returns(bool);
    
    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
    ) 
        external returns(bool);

}


contract TrustStake {

    mapping(address => bool) internal ambassadors_;

    uint256 constant internal ambassadorMaxPurchase_ = 1000000e18;

    mapping(address => uint256) internal ambassadorAccumulatedQuota_;

    bool public onlyAmbassadors = true;

    uint256 ACTIVATION_TIME = now;

    modifier antiEarlyWhale(
        uint256 _amountOfERC20, 
        address _customerAddress
    )
    {
        if (now >= ACTIVATION_TIME) {
            onlyAmbassadors = false;
        }
        
        if (onlyAmbassadors) {
            
            require((ambassadors_[_customerAddress] == true && 
            
            (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfERC20) <= 
                ambassadorMaxPurchase_));
                
            ambassadorAccumulatedQuota_[_customerAddress] = 
                SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfERC20);
    
            _;
        
        } else {
            onlyAmbassadors = false;
            _;
        }
    }

    modifier onlyTokenHolders {
        require(myTokens() > 0);
        _;
    }

    modifier onlyDivis {
        require(myDividends(true) > 0);
        _;
    }

    event onDistribute(
        address indexed customerAddress,
        uint256 price
    );

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingERC20,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ERC20Earned,
        uint timestamp
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ERC20Reinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ERC20Withdrawn
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    string public name = "TrustStake";
    
    string public symbol = "TRUST";
    
    uint8 constant public decimals = 18;
    
    uint256 internal entryFee_ = 5;
    
    uint256 internal exitFee_ = 5;
    
    uint256 internal referralFee_ = 10;
    
    uint256 internal maintenanceFee_ = 10;
    
    address internal maintenanceAddress;
    
    uint256 constant internal magnitude = 2 ** 64;
    
    mapping(address => uint256) public tokenBalanceLedger_;
    
    mapping(address => uint256) public referralBalance_;
    
    mapping(address => uint256) public totalReferralEarnings_;
    
    mapping(address => int256) public payoutsTo_;
    
    mapping(address => uint256) public invested_;
    
    uint256 internal tokenSupply_;
    
    uint256 internal profitPerShare_;
    
    IERC20 erc20;

    constructor() public {
        maintenanceAddress = address(0x1682135756404355F58811F8E495D999ef3Ca0eC);
        erc20 = IERC20(address(0xCC4304A31d09258b0029eA7FE63d032f52e44EFe));
    }
    
    function checkAndTransfer(
        uint256 _amount
    ) 
        private 
    {
        require(
            erc20.transferFrom(
                msg.sender, 
                address(this), 
                _amount
            ) == true, "transfer must succeed"
        );
    }

    function buy(
        uint256 _amount, 
        address _referredBy
    ) 
        public 
        returns(uint256) 
    {
        checkAndTransfer(_amount);
        
        return purchaseTokens(
            _referredBy, 
            msg.sender, 
            _amount
        );
    }
    
    function buyFor(
        uint256 _amount, 
        address _customerAddress, 
        address _referredBy
    ) 
        public 
        returns(uint256) 
    {
        checkAndTransfer(_amount);
        return purchaseTokens(
            _referredBy, 
            _customerAddress,
            _amount
        );
    }
    
    function() payable public {
        revert();
    }
    
    function reinvest() 
        onlyDivis 
        public 
    {
        address _customerAddress = msg.sender;
        
        uint256 _dividends = myDividends(false);
        
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);
        
        _dividends += referralBalance_[_customerAddress];
        
        referralBalance_[_customerAddress] = 0;
        
        uint256 _tokens = purchaseTokens(0x0, _customerAddress, _dividends);
        
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }
    
    function exit() external {
        
        address _customerAddress = msg.sender;
        
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        
        if (_tokens > 0) sell(_tokens);
        
        withdraw();
    }
    
    function withdraw() 
        onlyDivis
        public 
    {
        address _customerAddress = msg.sender;
        
        uint256 _dividends = myDividends(false);
        
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);
        
        _dividends += referralBalance_[_customerAddress];
        
        referralBalance_[_customerAddress] = 0;
        
        erc20.transfer(_customerAddress, _dividends);
        
        emit onWithdraw(_customerAddress, _dividends);
    }
    
    function sell(
        uint256 _amountOfERC20s
    ) 
        onlyTokenHolders 
        public 
    {
        address _customerAddress = msg.sender;
        require(_amountOfERC20s <= tokenBalanceLedger_[_customerAddress]);
        
        uint256 _dividends = SafeMath.div(SafeMath.mul(_amountOfERC20s, exitFee_), 100);
        uint256 _taxedERC20 = SafeMath.sub(_amountOfERC20s, _dividends);
        
        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfERC20s);
        
        tokenBalanceLedger_[_customerAddress] = 
            SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfERC20s);
        
        int256 _updatedPayouts = 
            (int256)(profitPerShare_ * _amountOfERC20s + (_taxedERC20 * magnitude));
            
        payoutsTo_[_customerAddress] -= _updatedPayouts;
        
        if (tokenSupply_ > 0) {
            profitPerShare_ = SafeMath.add(
                profitPerShare_, (_dividends * magnitude) / tokenSupply_
            );
        }
        
        emit Transfer(_customerAddress, address(0), _amountOfERC20s);
        emit onTokenSell(_customerAddress, _amountOfERC20s, _taxedERC20, now);
    }
    
    function transfer(
        address _toAddress, 
        uint256 _amountOfERC20s
    ) 
        onlyTokenHolders 
        external 
        returns(bool) 
    {
        address _customerAddress = msg.sender;
        require(_amountOfERC20s <= tokenBalanceLedger_[_customerAddress]);
    
        if (myDividends(true) > 0) {
            withdraw();
        }
        
        tokenSupply_ = SafeMath.sub(tokenSupply_, _amountOfERC20s);
        
        tokenBalanceLedger_[_customerAddress] = 
            SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfERC20s);
            
        tokenBalanceLedger_[_toAddress] = 
            SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfERC20s);
        
        payoutsTo_[_customerAddress] -= (int256)(profitPerShare_ * _amountOfERC20s);
        payoutsTo_[_toAddress] += (int256)(profitPerShare_ * _amountOfERC20s);
        
        profitPerShare_ = SafeMath.add(profitPerShare_, (_amountOfERC20s * magnitude) / tokenSupply_);
        
        emit Transfer(_customerAddress, _toAddress, _amountOfERC20s);
        
        return true;
    }
    
    function totalERC20Balance() 
        public 
        view 
        returns(uint256) 
    {
        return erc20.balanceOf(address(this));
    }

    function totalSupply() 
        public 
        view 
        returns(uint256) 
    {
        return tokenSupply_;
    }

    function myTokens() 
        public 
        view 
        returns(uint256) 
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
    
    function myDividends(
        bool _includeReferralBonus
    ) 
        public 
        view 
        returns(uint256) 
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + 
            referralBalance_[_customerAddress] : dividendsOf(_customerAddress);
    }
    
    function balanceOf(
        address _customerAddress
    ) 
        public 
        view 
        returns(uint256) 
    {
        return tokenBalanceLedger_[_customerAddress];
    }
    
    function dividendsOf(
        address _customerAddress
    ) 
        public 
        view 
        returns(uint256) 
    {
        return (uint256)((int256)(
            profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - 
            payoutsTo_[_customerAddress]) / magnitude;
    }
    
    function sellPrice() 
        public 
        view 
        returns(uint256) 
    {
        uint256 _erc20 = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_erc20, exitFee_), 100);
        uint256 _taxedERC20 = SafeMath.sub(_erc20, _dividends);
        
        return _taxedERC20;
    }
    
    function buyPrice() 
        public 
        view 
        returns(uint256) 
    {
        uint256 _erc20 = 1e18;
        uint256 _dividends = SafeMath.div(SafeMath.mul(_erc20, entryFee_), 100);
        uint256 _taxedERC20 = SafeMath.add(_erc20, _dividends);
        
        return _taxedERC20;
    }
    
    function getInvested() 
        public 
        view 
        returns(uint256) 
    {
        return invested_[msg.sender];
    }
    
    function totalReferralEarnings(
        address _client
    )
        public 
        view 
        returns(uint256)
    {
        return totalReferralEarnings_[_client];
    }
    
    function referralBalance(
        address _client 
    )
        public 
        view 
        returns(uint256)
    {
        return referralBalance_[_client];
    }
    
    function purchaseTokens(
        address _referredBy, 
        address _customerAddress, 
        uint256 _incomingERC20
    ) 
        internal 
        antiEarlyWhale(_incomingERC20, _customerAddress) 
        returns(uint256) 
    {
    invested_[msg.sender] += _incomingERC20;
    
    uint256 _undividedDividends = 
        SafeMath.div(
            SafeMath.mul(
                _incomingERC20, entryFee_
            ), 
        100);
    
    uint256 _maintenance = 
        SafeMath.div(
            SafeMath.mul(
                _undividedDividends, maintenanceFee_
            ), 
        100);
        
        
    uint256 _referralBonus = 
        SafeMath.div(
            SafeMath.mul(
                _undividedDividends, referralFee_
            ), 
        100);
    
    uint256 _dividends = 
        SafeMath.sub(
            _undividedDividends, SafeMath.add(
                _referralBonus, _maintenance
            )
        );
        
    uint256 _amountOfERC20s = 
        SafeMath.sub(_incomingERC20, _undividedDividends);
        
    uint256 _fee = _dividends * magnitude;
    
    require(
        _amountOfERC20s > 0 && 
        SafeMath.add(_amountOfERC20s, tokenSupply_) > tokenSupply_
    );
    
    referralBalance_[maintenanceAddress] = 
        SafeMath.add(referralBalance_[maintenanceAddress], _maintenance);
    
    if (_referredBy != address(0) && 
        _referredBy != _customerAddress)
    {
        referralBalance_[_referredBy] = 
            SafeMath.add(referralBalance_[_referredBy], _referralBonus);
            
        totalReferralEarnings_[_referredBy] = 
            SafeMath.add(totalReferralEarnings_[_referredBy], _referralBonus);
    } else {
        _dividends = SafeMath.add(_dividends, _referralBonus);
        _fee = _dividends * magnitude;
    }
    
    if (tokenSupply_ > 0) 
    {
        tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfERC20s);
        
        profitPerShare_ += ((_dividends * magnitude) / (tokenSupply_));
        _fee = _fee - (_fee - (_amountOfERC20s * ((_dividends * magnitude) / (tokenSupply_))));
        
    } else {
        tokenSupply_ = _amountOfERC20s;
    }

    tokenBalanceLedger_[_customerAddress] = 
        SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfERC20s);
    
    int256 _updatedPayouts = (int256)((profitPerShare_ * _amountOfERC20s) - _fee);
        
    payoutsTo_[_customerAddress] += _updatedPayouts;
    
    emit Transfer(
        address(0), 
        msg.sender, 
        _amountOfERC20s
    );
    
    emit onTokenPurchase(
        _customerAddress, 
        _incomingERC20, 
        _amountOfERC20s, 
        _referredBy, 
        now
    );
    
    return _amountOfERC20s;
    }

    function multiData()
    public
    view
    returns(
        uint256, 
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
        
        // [0] Total ERC20 in contract 
        totalERC20Balance(),
        
        // [1] Total STAKE TOKEN supply
        totalSupply(),
        
        // [2] User STAKE TOKEN balance 
        balanceOf(msg.sender),
        
        // [3] User ERC20 balance
        erc20.balanceOf(msg.sender),
        
        // [4] User divs 
        dividendsOf(msg.sender),
        
        // [5] Buy price 
        buyPrice(),
        
        // [6] Sell price 
        sellPrice(),
        
        // [7] Total referral earnings  
        totalReferralEarnings(msg.sender),
        
        // [8] Current referral earnings 
        referralBalance(msg.sender)
        );
    }
}