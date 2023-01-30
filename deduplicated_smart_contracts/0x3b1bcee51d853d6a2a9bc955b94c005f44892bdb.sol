pragma solidity ^0.4.21;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


interface ERC20 {
    function transfer (address _beneficiary, uint256 _tokenAmount) external returns (bool);
    function mint (address _to, uint256 _amount) external returns (bool);
}


contract Ownable {
    address public owner;
    function Ownable() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}


contract Crowdsale is Ownable {
    using SafeMath for uint256;

    modifier onlyWhileOpen {
        require(
            (now >= preICOStartDate && now < preICOEndDate) ||
            (now >= ICOStartDate && now < ICOEndDate)
        );
        _;
    }

    modifier onlyWhileICOOpen {
        require(now >= ICOStartDate && now < ICOEndDate);
        _;
    }

    // The token being sold
    ERC20 public token;

    // Address where funds are collected
    address public wallet;

    // §¡§Õ§â§Ö§ã §à§á§Ö§â§Ñ§ä§à§â§Ñ §Ò§Ö§Ü§¿§ß§Õ§Ñ §Õ§Ý§ñ §å§á§â§Ñ§Ó§Ý§Ö§ß§Ú§ñ §Ó§Ñ§Û§ä§Ý§Ú§ã§ä§à§Þ
    address public backendOperator = 0xd2420C5fDdA15B26AC3E13522e5cCD62CEB50e5F;

    // §³§Ü§à§Ý§î§Ü§à §ä§à§Ü§Ö§ß§à§Ó §á§à§Ü§å§á§Ñ§ä§Ö§Ý§î §á§à§Ý§å§é§Ñ§Ö§ä §Ù§Ñ 1 §ï§æ§Ú§â
    uint256 public rate = 100;

    // §³§Ü§à§Ý§î§Ü§à §ï§æ§Ú§â§à§Ó §á§â§Ú§Ó§Ý§Ö§é§Ö§ß§à §Ó §ç§à§Õ§Ö PreICO, wei
    uint256 public preICOWeiRaised = 1850570000000000000000;

    // §³§Ü§à§Ý§î§Ü§à §ï§æ§Ú§â§à§Ó §á§â§Ú§Ó§Ý§Ö§é§Ö§ß§à §Ó §ç§à§Õ§Ö ICO, wei
    uint256 public ICOWeiRaised;

    // §¸§Ö§ß§Ñ ETH §Ó §è§Ö§ß§ä§Ñ§ç
    uint256 public ETHUSD;

    // §¥§Ñ§ä§Ñ §ß§Ñ§é§Ñ§Ý§Ñ PreICO
    uint256 public preICOStartDate;

    // §¥§Ñ§ä§Ñ §à§Ü§à§ß§é§Ñ§ß§Ú§ñ PreICO
    uint256 public preICOEndDate;

    // §¥§Ñ§ä§Ñ §ß§Ñ§é§Ñ§Ý§Ñ ICO
    uint256 public ICOStartDate;

    // §¥§Ñ§ä§Ñ §à§Ü§à§ß§é§Ñ§ß§Ú§ñ ICO
    uint256 public ICOEndDate;

    // §®§Ú§ß§Ú§Þ§Ñ§Ý§î§ß§í§Û §à§Ò§ì§Ö§Þ §á§â§Ú§Ó§Ý§Ö§é§Ö§ß§Ú§ñ §ã§â§Ö§Õ§ã§ä§Ó §Ó §ç§à§Õ§Ö ICO §Ó §è§Ö§ß§ä§Ñ§ç
    uint256 public softcap = 300000000;

    // §±§à§ä§à§Ý§à§Ü §á§â§Ú§Ó§Ý§Ö§é§Ö§ß§Ú§ñ §ã§â§Ö§Õ§ã§ä§Ó §Ó §ç§à§Õ§Ö ICO §Ó §è§Ö§ß§ä§Ñ§ç
    uint256 public hardcap = 2500000000;

    // §¢§à§ß§å§ã §â§Ö§æ§Ö§â§Ñ§Ý§Ñ, %
    uint8 public referalBonus = 3;

    // §¢§à§ß§å§ã §á§â§Ú§Ô§Ý§Ñ§ê§Ö§ß§ß§à§Ô§à §â§Ö§æ§Ö§â§Ñ§Ý§à§Þ, %
    uint8 public invitedByReferalBonus = 2;

    // Whitelist
    mapping(address => bool) public whitelist;

    // §ª§ß§Ó§Ö§ã§ä§à§â§í, §Ü§à§ä§à§â§í§Ö §Ü§å§á§Ú§Ý§Ú §ä§à§Ü§Ö§ß
    mapping (address => uint256) public investors;

    event TokenPurchase(address indexed buyer, uint256 value, uint256 amount);

    function Crowdsale(
        address _wallet,
        uint256 _preICOStartDate,
        uint256 _preICOEndDate,
        uint256 _ICOStartDate,
        uint256 _ICOEndDate,
        uint256 _ETHUSD
    ) public {
        require(_preICOEndDate > _preICOStartDate);
        require(_ICOStartDate > _preICOEndDate);
        require(_ICOEndDate > _ICOStartDate);

        wallet = _wallet;
        preICOStartDate = _preICOStartDate;
        preICOEndDate = _preICOEndDate;
        ICOStartDate = _ICOStartDate;
        ICOEndDate = _ICOEndDate;
        ETHUSD = _ETHUSD;
    }

    modifier backEnd() {
        require(msg.sender == backendOperator || msg.sender == owner);
        _;
    }

    /* §±§å§Ò§Ý§Ú§é§ß§í§Ö §Þ§Ö§ä§à§Õ§í */

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §ã§ä§à§Ú§Þ§à§ã§ä§î §ä§à§Ü§Ö§ß§Ñ
    function setRate (uint16 _rate) public onlyOwner {
        require(_rate > 0);
        rate = _rate;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Ñ§Õ§â§Ö§ã §Ü§à§ê§Ö§Ý§î§Ü§Ñ §Õ§Ý§ñ §ã§Ò§à§â§Ñ §ã§â§Ö§Õ§ã§ä§Ó
    function setWallet (address _wallet) public onlyOwner {
        require (_wallet != 0x0);
        wallet = _wallet;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §ä§à§â§Ô§å§Ö§Þ§í§Û §ä§à§Ü§Ö§ß
    function setToken (ERC20 _token) public onlyOwner {
        token = _token;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Õ§Ñ§ä§å §ß§Ñ§é§Ñ§Ý§Ñ PreICO
    function setPreICOStartDate (uint256 _preICOStartDate) public onlyOwner {
        require(_preICOStartDate < preICOEndDate);
        preICOStartDate = _preICOStartDate;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Õ§Ñ§ä§å §à§Ü§à§ß§é§Ñ§ß§Ú§ñ PreICO
    function setPreICOEndDate (uint256 _preICOEndDate) public onlyOwner {
        require(_preICOEndDate > preICOStartDate);
        preICOEndDate = _preICOEndDate;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Õ§Ñ§ä§å §ß§Ñ§é§Ñ§Ý§Ñ ICO
    function setICOStartDate (uint256 _ICOStartDate) public onlyOwner {
        require(_ICOStartDate < ICOEndDate);
        ICOStartDate = _ICOStartDate;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §Õ§Ñ§ä§å §à§Ü§à§ß§é§Ñ§ß§Ú§ñ PreICO
    function setICOEndDate (uint256 _ICOEndDate) public onlyOwner {
        require(_ICOEndDate > ICOStartDate);
        ICOEndDate = _ICOEndDate;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §ã§ä§à§Ú§Þ§à§ã§ä§î §ï§æ§Ú§â§Ñ §Ó §è§Ö§ß§ä§Ñ§ç
    function setETHUSD (uint256 _ETHUSD) public onlyOwner {
        ETHUSD = _ETHUSD;
    }

    // §µ§ã§ä§Ñ§ß§à§Ó§Ú§ä§î §à§á§Ö§â§Ñ§ä§à§â§Ñ §¢§Ö§Ü§¿§ß§Õ§Ñ §Õ§Ý§ñ §å§á§â§Ñ§Ó§Ý§Ö§ß§Ú§ñ §Ó§Ñ§Û§ä§Ý§Ú§ã§ä§à§Þ
    function setBackendOperator(address newOperator) public onlyOwner {
        backendOperator = newOperator;
    }

    function () external payable {
        address beneficiary = msg.sender;
        uint256 weiAmount = msg.value;
        uint256 tokens;

        if(_isPreICO()){

            _preValidatePreICOPurchase(beneficiary, weiAmount);
            tokens = weiAmount.mul(rate.add(rate.mul(30).div(100)));
            preICOWeiRaised = preICOWeiRaised.add(weiAmount);
            wallet.transfer(weiAmount);
            investors[beneficiary] = weiAmount;
            _deliverTokens(beneficiary, tokens);
            emit TokenPurchase(beneficiary, weiAmount, tokens);

        } else if(_isICO()){

            _preValidateICOPurchase(beneficiary, weiAmount);
            tokens = _getTokenAmountWithBonus(weiAmount);
            ICOWeiRaised = ICOWeiRaised.add(weiAmount);
            investors[beneficiary] = weiAmount;
            _deliverTokens(beneficiary, tokens);
            emit TokenPurchase(beneficiary, weiAmount, tokens);

        }
    }

    // §±§à§Ü§å§á§Ü§Ñ §ä§à§Ü§Ö§ß§à§Ó §ã §â§Ö§æ§Ö§â§Ñ§Ý§î§ß§í§Þ §Ò§à§ß§å§ã§à§Þ
    function buyTokensWithReferal(address _referal) public onlyWhileICOOpen payable {
        address beneficiary = msg.sender;
        uint256 weiAmount = msg.value;

        _preValidateICOPurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmountWithBonus(weiAmount).add(_getTokenAmountWithReferal(weiAmount, 2));
        uint256 referalTokens = _getTokenAmountWithReferal(weiAmount, 3);

        ICOWeiRaised = ICOWeiRaised.add(weiAmount);
        investors[beneficiary] = weiAmount;

        _deliverTokens(beneficiary, tokens);
        _deliverTokens(_referal, referalTokens);

        emit TokenPurchase(beneficiary, weiAmount, tokens);
    }

    // §¥§à§Ò§Ñ§Ó§Ú§ä§î §Ñ§Õ§â§Ö§ã §Ó whitelist
    function addToWhitelist(address _beneficiary) public backEnd {
        whitelist[_beneficiary] = true;
    }

    // §¥§à§Ò§Ñ§Ó§Ú§ä§î §ß§Ö§ã§Ü§à§Ý§î§Ü§à §Ñ§Õ§â§Ö§ã§à§Ó §Ó whitelist
    function addManyToWhitelist(address[] _beneficiaries) public backEnd {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    // §ª§ã§Ü§Ý§ð§é§Ú§ä§î §Ñ§Õ§â§Ö§ã §Ú§Ù whitelist
    function removeFromWhitelist(address _beneficiary) public backEnd {
        whitelist[_beneficiary] = false;
    }

    // §µ§Ù§ß§Ñ§ä§î §Ú§ã§ä§Ö§Ü §Ý§Ú §ã§â§à§Ü §á§â§à§Ó§Ö§Õ§Ö§ß§Ú§ñ PreICO
    function hasPreICOClosed() public view returns (bool) {
        return now > preICOEndDate;
    }

    // §µ§Ù§ß§Ñ§ä§î §Ú§ã§ä§Ö§Ü §Ý§Ú §ã§â§à§Ü §á§â§à§Ó§Ö§Õ§Ö§ß§Ú§ñ ICO
    function hasICOClosed() public view returns (bool) {
        return now > ICOEndDate;
    }

    // §±§Ö§â§Ö§Ó§Ö§ã§ä§Ú §ã§à§Ò§â§Ñ§ß§ß§í§Ö §ã§â§Ö§Õ§ã§ä§Ó§Ñ §ß§Ñ §Ü§à§ê§Ö§Ý§Ö§Ü §Õ§Ý§ñ §ã§Ò§à§â§Ñ
    function forwardFunds () public onlyOwner {
        require(now > ICOEndDate);
        require((preICOWeiRaised.add(ICOWeiRaised)).mul(ETHUSD).div(10**18) >= softcap);

        wallet.transfer(ICOWeiRaised);
    }

    // §£§Ö§â§ß§å§ä§î §á§â§à§Ú§ß§Ó§Ö§ã§ä§Ú§â§à§Ó§Ñ§ß§ß§í§Ö §ã§â§Ö§Õ§ã§ä§Ó§Ñ, §Ö§ã§Ý§Ú §ß§Ö §Ò§í§Ý §Õ§à§ã§ä§Ú§Ô§ß§å§ä softcap
    function refund() public {
        require(now > ICOEndDate);
        require(preICOWeiRaised.add(ICOWeiRaised).mul(ETHUSD).div(10**18) < softcap);
        require(investors[msg.sender] > 0);

        address investor = msg.sender;
        investor.transfer(investors[investor]);
    }


    /* §£§ß§å§ä§â§Ö§ß§ß§Ú§Ö §Þ§Ö§ä§à§Õ§í */

    // §±§â§à§Ó§Ö§â§Ü§Ñ §Ñ§Ü§ä§å§Ñ§Ý§î§ß§à§ã§ä§Ú PreICO
    function _isPreICO() internal view returns(bool) {
        return now >= preICOStartDate && now < preICOEndDate;
    }

    // §±§â§à§Ó§Ö§â§Ü§Ñ §Ñ§Ü§ä§å§Ñ§Ý§î§ß§à§ã§ä§Ú ICO
    function _isICO() internal view returns(bool) {
        return now >= ICOStartDate && now < ICOEndDate;
    }

    // §£§Ñ§Ý§Ú§Õ§Ñ§è§Ú§ñ §á§Ö§â§Ö§Õ §á§à§Ü§å§á§Ü§à§Û §ä§à§Ü§Ö§ß§à§Ó

    function _preValidatePreICOPurchase(address _beneficiary, uint256 _weiAmount) internal view {
        require(_weiAmount != 0);
        require(whitelist[_beneficiary]);
        require(now >= preICOStartDate && now <= preICOEndDate);
    }

    function _preValidateICOPurchase(address _beneficiary, uint256 _weiAmount) internal view {
        require(_weiAmount != 0);
        require(whitelist[_beneficiary]);
        require((preICOWeiRaised + ICOWeiRaised + _weiAmount).mul(ETHUSD).div(10**18) <= hardcap);
        require(now >= ICOStartDate && now <= ICOEndDate);
    }

    // §±§à§Õ§ã§é§Ö§ä §Ò§à§ß§å§ã§à§Ó §ã §å§é§Ö§ä§à§Þ §Ò§à§ß§å§ã§à§Ó §Ù§Ñ §ï§ä§Ñ§á ICO §Ú §à§Ò§ì§Ö§Þ §Ú§ß§Ó§Ö§ã§ä§Ú§è§Ú§Û
    function _getTokenAmountWithBonus(uint256 _weiAmount) internal view returns(uint256) {
        uint256 baseTokenAmount = _weiAmount.mul(rate);
        uint256 tokenAmount = baseTokenAmount;
        uint256 usdAmount = _weiAmount.mul(ETHUSD).div(10**18);

        // §³§é§Ú§ä§Ñ§Ö§Þ §Ò§à§ß§å§ã§í §Ù§Ñ §à§Ò§ì§Ö§Þ §Ú§ß§Ó§Ö§ã§ä§Ú§è§Ú§Û
        if(usdAmount >= 10000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(7).div(100));
        } else if(usdAmount >= 5000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(5).div(100));
        } else if(usdAmount >= 1000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(3).div(100));
        }

        // §³§é§Ú§ä§Ñ§Ö§Þ §Ò§à§ß§å§ã§í §Ù§Ñ §ï§ä§Ñ§á ICO
        if(now < ICOStartDate + 30 days) {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(20).div(100));
        } else if(now < ICOStartDate + 60 days) {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(15).div(100));
        } else if(now < ICOStartDate + 90 days) {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(10).div(100));
        } else {
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(5).div(100));
        }

        return tokenAmount;
    }

    // §±§à§Õ§ã§é§Ö§ä §Ò§à§ß§å§ã§à§Ó §ã §å§é§Ö§ä§à§Þ §Ò§à§ß§å§ã§à§Ó §â§Ö§æ§Ö§â§Ñ§Ý§î§ß§à§Û §ã§Ú§ã§ä§Ö§Þ§í
    function _getTokenAmountWithReferal(uint256 _weiAmount, uint8 _percent) internal view returns(uint256) {
        return _weiAmount.mul(rate).mul(_percent).div(100);
    }

    // §±§Ö§â§Ö§Ó§à§Õ §ä§à§Ü§Ö§ß§à§Ó
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.mint(_beneficiary, _tokenAmount);
    }
}