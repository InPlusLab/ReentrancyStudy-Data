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

    // ���է�֧� ���֧�ѧ���� �ҧ֧ܧ��ߧէ� �էݧ� ����ѧӧݧ֧ߧڧ� �ӧѧۧ�ݧڧ����
    address public backendOperator = 0xd2420C5fDdA15B26AC3E13522e5cCD62CEB50e5F;

    // ���ܧ�ݧ�ܧ� ���ܧ֧ߧ�� ���ܧ��ѧ�֧ݧ� ���ݧ��ѧ֧� �٧� 1 ���ڧ�
    uint256 public rate = 100;

    // ���ܧ�ݧ�ܧ� ���ڧ��� ���ڧӧݧ֧�֧ߧ� �� ���է� PreICO, wei
    uint256 public preICOWeiRaised = 1850570000000000000000;

    // ���ܧ�ݧ�ܧ� ���ڧ��� ���ڧӧݧ֧�֧ߧ� �� ���է� ICO, wei
    uint256 public ICOWeiRaised;

    // ���֧ߧ� ETH �� ��֧ߧ�ѧ�
    uint256 public ETHUSD;

    // ���ѧ�� �ߧѧ�ѧݧ� PreICO
    uint256 public preICOStartDate;

    // ���ѧ�� ��ܧ�ߧ�ѧߧڧ� PreICO
    uint256 public preICOEndDate;

    // ���ѧ�� �ߧѧ�ѧݧ� ICO
    uint256 public ICOStartDate;

    // ���ѧ�� ��ܧ�ߧ�ѧߧڧ� ICO
    uint256 public ICOEndDate;

    // ���ڧߧڧާѧݧ�ߧ�� ��ҧ�֧� ���ڧӧݧ֧�֧ߧڧ� ���֧է��� �� ���է� ICO �� ��֧ߧ�ѧ�
    uint256 public softcap = 300000000;

    // ������ݧ�� ���ڧӧݧ֧�֧ߧڧ� ���֧է��� �� ���է� ICO �� ��֧ߧ�ѧ�
    uint256 public hardcap = 2500000000;

    // ����ߧ�� ��֧�֧�ѧݧ�, %
    uint8 public referalBonus = 3;

    // ����ߧ�� ���ڧԧݧѧ�֧ߧߧ�ԧ� ��֧�֧�ѧݧ��, %
    uint8 public invitedByReferalBonus = 2;

    // Whitelist
    mapping(address => bool) public whitelist;

    // ���ߧӧ֧�����, �ܧ������ �ܧ��ڧݧ� ���ܧ֧�
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

    /* ����ҧݧڧ�ߧ�� �ާ֧��է� */

    // �����ѧߧ�ӧڧ�� ����ڧާ���� ���ܧ֧ߧ�
    function setRate (uint16 _rate) public onlyOwner {
        require(_rate > 0);
        rate = _rate;
    }

    // �����ѧߧ�ӧڧ�� �ѧէ�֧� �ܧ��֧ݧ�ܧ� �էݧ� ��ҧ��� ���֧է���
    function setWallet (address _wallet) public onlyOwner {
        require (_wallet != 0x0);
        wallet = _wallet;
    }

    // �����ѧߧ�ӧڧ�� ����ԧ�֧ާ�� ���ܧ֧�
    function setToken (ERC20 _token) public onlyOwner {
        token = _token;
    }

    // �����ѧߧ�ӧڧ�� �էѧ�� �ߧѧ�ѧݧ� PreICO
    function setPreICOStartDate (uint256 _preICOStartDate) public onlyOwner {
        require(_preICOStartDate < preICOEndDate);
        preICOStartDate = _preICOStartDate;
    }

    // �����ѧߧ�ӧڧ�� �էѧ�� ��ܧ�ߧ�ѧߧڧ� PreICO
    function setPreICOEndDate (uint256 _preICOEndDate) public onlyOwner {
        require(_preICOEndDate > preICOStartDate);
        preICOEndDate = _preICOEndDate;
    }

    // �����ѧߧ�ӧڧ�� �էѧ�� �ߧѧ�ѧݧ� ICO
    function setICOStartDate (uint256 _ICOStartDate) public onlyOwner {
        require(_ICOStartDate < ICOEndDate);
        ICOStartDate = _ICOStartDate;
    }

    // �����ѧߧ�ӧڧ�� �էѧ�� ��ܧ�ߧ�ѧߧڧ� PreICO
    function setICOEndDate (uint256 _ICOEndDate) public onlyOwner {
        require(_ICOEndDate > ICOStartDate);
        ICOEndDate = _ICOEndDate;
    }

    // �����ѧߧ�ӧڧ�� ����ڧާ���� ���ڧ�� �� ��֧ߧ�ѧ�
    function setETHUSD (uint256 _ETHUSD) public onlyOwner {
        ETHUSD = _ETHUSD;
    }

    // �����ѧߧ�ӧڧ�� ���֧�ѧ���� ���֧ܧ��ߧէ� �էݧ� ����ѧӧݧ֧ߧڧ� �ӧѧۧ�ݧڧ����
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

    // ����ܧ��ܧ� ���ܧ֧ߧ�� �� ��֧�֧�ѧݧ�ߧ�� �ҧ�ߧ����
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

    // ����ҧѧӧڧ�� �ѧէ�֧� �� whitelist
    function addToWhitelist(address _beneficiary) public backEnd {
        whitelist[_beneficiary] = true;
    }

    // ����ҧѧӧڧ�� �ߧ֧�ܧ�ݧ�ܧ� �ѧէ�֧��� �� whitelist
    function addManyToWhitelist(address[] _beneficiaries) public backEnd {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    // ����ܧݧ��ڧ�� �ѧէ�֧� �ڧ� whitelist
    function removeFromWhitelist(address _beneficiary) public backEnd {
        whitelist[_beneficiary] = false;
    }

    // ���٧ߧѧ�� �ڧ��֧� �ݧ� ����� ����ӧ֧է֧ߧڧ� PreICO
    function hasPreICOClosed() public view returns (bool) {
        return now > preICOEndDate;
    }

    // ���٧ߧѧ�� �ڧ��֧� �ݧ� ����� ����ӧ֧է֧ߧڧ� ICO
    function hasICOClosed() public view returns (bool) {
        return now > ICOEndDate;
    }

    // ���֧�֧ӧ֧��� ���ҧ�ѧߧߧ�� ���֧է��ӧ� �ߧ� �ܧ��֧ݧ֧� �էݧ� ��ҧ���
    function forwardFunds () public onlyOwner {
        require(now > ICOEndDate);
        require((preICOWeiRaised.add(ICOWeiRaised)).mul(ETHUSD).div(10**18) >= softcap);

        wallet.transfer(ICOWeiRaised);
    }

    // ���֧�ߧ��� ����ڧߧӧ֧��ڧ��ӧѧߧߧ�� ���֧է��ӧ�, �֧�ݧ� �ߧ� �ҧ�� �է���ڧԧߧ�� softcap
    function refund() public {
        require(now > ICOEndDate);
        require(preICOWeiRaised.add(ICOWeiRaised).mul(ETHUSD).div(10**18) < softcap);
        require(investors[msg.sender] > 0);

        address investor = msg.sender;
        investor.transfer(investors[investor]);
    }


    /* ���ߧ���֧ߧߧڧ� �ާ֧��է� */

    // �����ӧ֧�ܧ� �ѧܧ��ѧݧ�ߧ���� PreICO
    function _isPreICO() internal view returns(bool) {
        return now >= preICOStartDate && now < preICOEndDate;
    }

    // �����ӧ֧�ܧ� �ѧܧ��ѧݧ�ߧ���� ICO
    function _isICO() internal view returns(bool) {
        return now >= ICOStartDate && now < ICOEndDate;
    }

    // ���ѧݧڧէѧ�ڧ� ��֧�֧� ���ܧ��ܧ�� ���ܧ֧ߧ��

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

    // ����է��֧� �ҧ�ߧ���� �� ���֧��� �ҧ�ߧ���� �٧� ���ѧ� ICO �� ��ҧ�֧� �ڧߧӧ֧��ڧ�ڧ�
    function _getTokenAmountWithBonus(uint256 _weiAmount) internal view returns(uint256) {
        uint256 baseTokenAmount = _weiAmount.mul(rate);
        uint256 tokenAmount = baseTokenAmount;
        uint256 usdAmount = _weiAmount.mul(ETHUSD).div(10**18);

        // ����ڧ�ѧ֧� �ҧ�ߧ��� �٧� ��ҧ�֧� �ڧߧӧ֧��ڧ�ڧ�
        if(usdAmount >= 10000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(7).div(100));
        } else if(usdAmount >= 5000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(5).div(100));
        } else if(usdAmount >= 1000000){
            tokenAmount = tokenAmount.add(baseTokenAmount.mul(3).div(100));
        }

        // ����ڧ�ѧ֧� �ҧ�ߧ��� �٧� ���ѧ� ICO
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

    // ����է��֧� �ҧ�ߧ���� �� ���֧��� �ҧ�ߧ���� ��֧�֧�ѧݧ�ߧ�� ��ڧ��֧ާ�
    function _getTokenAmountWithReferal(uint256 _weiAmount, uint8 _percent) internal view returns(uint256) {
        return _weiAmount.mul(rate).mul(_percent).div(100);
    }

    // ���֧�֧ӧ�� ���ܧ֧ߧ��
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.mint(_beneficiary, _tokenAmount);
    }
}