pragma solidity ^0.4.18;


contract owned {
    address public owner;
    address public ownerCandidate;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier onlyOwnerCandidate() {
        assert(msg.sender == ownerCandidate);
        _;
    }

    function transferOwnership(address candidate) external onlyOwner {
        ownerCandidate = candidate;
    }

    function acceptOwnership() external onlyOwnerCandidate {
        owner = ownerCandidate;
        ownerCandidate = 0x0;
    }
}



contract SafeMath {
    function safeMul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) pure internal returns (uint) {
        uint c = a / b;
        assert(b == 0);
        return c;
    }

    function safeSub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}


contract VAAToken is SafeMath, owned {

    string public name = "VAAToken";        //  token name
    string public symbol = "VAAT";      //  token symbol
    uint public decimals = 8;           //  token digit

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    uint public totalSupply = 0;


    // �Ŷӵ�ַ
    address private addressTeam = 0x5b1FcBA12b4757549bf5d0550af253DE5E0F73c5;

    // �����ַ
    address private addressFund = 0xA703356488F7335269e5860ca41f787dFF50b76C;

    // �ƹ�Ǯ��
    address private addressPopular = 0x1db0304A3f2a861e7Ab8B7305AF1dC1ee4c3e94d;

    // ˽ļǮ��
    address private addressVip = 0x6e41aA4d64F9f4a190a9AF2292F815259BAef65c;

    //�ֲ�����
    uint constant valueTotal = 10 * 10000 * 10000 * 10 ** 8;  //���� 10E
    uint constant valueTeam = valueTotal / 100 * 20;   // �Ŷ� 20% 2E
    uint constant valueFund = valueTotal / 100 * 30; //���� 30% 3E
    uint constant valuePopular = valueTotal / 100 * 20; //ƽ̨���û��������ƹ�Ӫ��2E
    uint constant valueSale = valueTotal / 100 * 20;  // ICO 20% 2E
    uint constant valueVip = valueTotal / 100 * 10;   // ˽ļ 10% 1E


    // �Ƿ�ֹͣ����
    bool public saleStopped = false;

    // �׶�
    uint private constant BEFORE_SALE = 0;
    uint private constant IN_SALE = 1;
    uint private constant FINISHED = 2;

    // ICO��С��ֵ̫
    uint public minEth = 0.1 ether;

    // ICO�����ֵ̫
    uint public maxEth = 1000 ether;

    // ��ʼʱ�� 2018-03-29 00:00:00
    uint public openTime = 1522252800;
    // ����ʱ�� 2018-06-01 00:00:00
    uint public closeTime = 1527782400;

    // �۸�
    uint public price = 3500;

    // ��������������
    uint public saleQuantity = 0;

    // �����ETH����
    uint public ethQuantity = 0;

    // ���ֵĴ�������
    uint public withdrawQuantity = 0;


    modifier validAddress(address _address) {
        assert(0x0 != _address);
        _;
    }

    modifier validEth {
        assert(msg.value >= minEth && msg.value <= maxEth);
        _;
    }

    modifier validPeriod {
        assert(now >= openTime && now < closeTime);
        _;
    }

    modifier validQuantity {
        assert(valueSale >= saleQuantity);
        _;
    }

    modifier validStatue {
        assert(saleStopped == false);
        _;
    }

    function setOpenTime(uint newOpenTime) public onlyOwner {
        openTime = newOpenTime;
    }

    function setCloseTime(uint newCloseTime) public onlyOwner {
        closeTime = newCloseTime;
    }

    function VAAToken()
        public
    {
        owner = msg.sender;
        totalSupply = valueTotal;

        // ICO
        balanceOf[this] = valueSale;
        Transfer(0x0, this, valueSale);

        // Simu
        balanceOf[addressVip] = valueVip;
        Transfer(0x0, addressVip, valueVip);

        // Found
        balanceOf[addressFund] = valueFund;
        Transfer(0x0, addressFund, valueFund);

        // valuePopular
        balanceOf[addressPopular] = valuePopular;
        Transfer(0x0, addressPopular, valuePopular);

        // �Ŷ�
        balanceOf[addressTeam] = valueTeam;
        Transfer(0x0, addressTeam, valueTeam);
    }

    function transfer(address _to, uint _value)
        public
        validAddress(_to)
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(validTransfer(_value));
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferInner(address _to, uint _value)
        private
        returns (bool success)
    {
        balanceOf[this] -= _value;
        balanceOf[_to] += _value;
        Transfer(this, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint _value)
        public
        validAddress(_from)
        validAddress(_to)
        returns (bool success)
    {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        require(validTransfer(_value));
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    //����ת��
    function batchtransfer(address[] _to, uint256[] _amount) public returns(bool success) {
        for(uint i = 0; i < _to.length; i++){
            require(transfer(_to[i], _amount[i]));
        }
        return true;
    }

    function approve(address _spender, uint _value)
        public
        validAddress(_spender)
        returns (bool success)
    {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function validTransfer(uint _value)
        pure private
        returns (bool)
    {
        if (_value == 0)
            return false;

        return true;
    }

    function ()
        public
        payable
    {
        buy();
    }

    function buy()
        public
        payable
        validEth        // ��̫�Ƿ�������Χ
        validPeriod     // �Ƿ���ICO�ڼ�
        validQuantity   // �����Ƿ�������
        validStatue     // �����Ƿ��Ѿ���������
    {
        uint eth = msg.value;

        // �����������
        uint quantity = eth * price / 10 ** 10;

        // �Ƿ񳬳�ʣ�����
        uint leftQuantity = safeSub(valueSale, saleQuantity);
        if (quantity > leftQuantity) {
            quantity = leftQuantity;
        }

        saleQuantity = safeAdd(saleQuantity, quantity);
        ethQuantity = safeAdd(ethQuantity, eth);

        // ���ʹ���
        require(transferInner(msg.sender, quantity));

        // ������־
        Buy(msg.sender, eth, quantity);

    }

    function stopSale()
        public
        onlyOwner
        returns (bool)
    {
        assert(!saleStopped);
        saleStopped = true;
        StopSale();
        return true;
    }

    function getPeriod()
        public
        constant
        returns (uint)
    {
        if (saleStopped) {
            return FINISHED;
        }

        if (now < openTime) {
            return BEFORE_SALE;
        }

        if (valueSale == saleQuantity) {
            return FINISHED;
        }

        if (now >= openTime && now < closeTime) {
            return IN_SALE;
        }

        return FINISHED;
    }

    //�Ӻ�Լ��Eth
    function withdraw(uint amount)
        public
        onlyOwner
    {
        uint period = getPeriod();
        require(period == FINISHED);

        require(this.balance >= amount);
        msg.sender.transfer(amount);
    }

    // �Ӻ�Լ��token һ��Ҫ��ļ�����ſ�����
    function withdrawToken(uint amount)
        public
        onlyOwner
    {
        uint period = getPeriod();
        require(period == FINISHED);

        withdrawQuantity += safeAdd(withdrawQuantity, amount);
        require(transferInner(msg.sender, amount));
    }



    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Buy(address indexed sender, uint eth, uint token);
    event StopSale();
}