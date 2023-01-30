pragma solidity ^0.4.23;
/**
 * @title SafeMath
 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface ERC20 {
    function transfer (address _beneficiary, uint256 _tokenAmount) external returns (bool);
    function mintFromICO(address _to, uint256 _amount) external  returns(bool);
}
/**
 * @title Ownable
 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract GlowSale is Ownable {

    ERC20 public token;

    using SafeMath for uint;

    address public backEndOperator = msg.sender;
    address founders = 0x2ed2de73f7aB776A6DB15A30ad7CB8f337CF499D; // 30% - ���ߧ�ӧѧߧ�֧ݧ� ����֧ܧ��
    address bounty = 0x7a3B004E8A68BCD6C5D0c3936D2f582Acb89E5DD; // 10% - �էݧ� �ҧѧ�ߧ�� ����ԧ�ѧާާ�
    address reserve = 0xd9DADf245d04fB1566e7330be591445Ad9953476; // 10% - �էݧ� ��֧٧֧�ӧ�

    mapping(address=>bool) public whitelist;

    uint256 public startPreSale = now; //1529020801; // Thursday, 15-Jun-18 00:00:01 UTC
    uint256 public endPreSale = 1535759999; // Friday, 31-Aug-18 23:59:59 UTC
    uint256 public startMainSale = 1538352001; // Monday, 01-Oct-18 00:00:01 UTC
    uint256 public endMainSale = 1554076799; // Sunday, 31-Mar-19 23:59:59 UTC

    uint256 public investors; // ��ҧ�֧� �ܧ�ݧڧ�֧��ӧ� �ڧߧӧ֧������
    uint256 public weisRaised; // - ��ҧ�֧� �ܧ�ݧڧ�֧��ӧ� ���ڧ�� ���ҧ�ѧߧߧ�� �� ��֧�ڧ�� ��֧ۧݧ�

    uint256 hardCapPreSale = 3200000*1e6; //  3 200 000 tokens
    uint256 hardCapSale = 15000000*1e6; // 15 000 000 tokens

    uint256 public preSalePrice; // 0.50 $ - ��֧ߧ� ���ܧ֧ߧ� �ߧ� ���֧էӧѧ�ڧ�֧ݧ�ߧ�� ��ѧ����էѧا�
    uint256 public MainSalePrice; //1.00 $ - ��֧ߧ� ���ܧ֧ߧ� �ߧ� ���ߧ�ӧߧ�� ��ѧ����էѧا�
    uint256 public dollarPrice; // ��֧ߧ� Ether �� USD

    uint256 public soldTokensPreSale; // 3 200 000 - �ܧ�ݧڧ�֧��ӧ� ����էѧߧߧ�� �ߧ� ���֧էӧѧ�ڧ�֧ݧ�ߧ�� ��ѧ�����էѧا� ���ܧ֧ߧ��
    uint256 public soldTokensSale; // 36 400 000 - �ܧ�ݧڧ�֧��ӧ� ����էѧߧߧ�� �ߧ� ���ߧ�ӧߧ�� ��ѧ����էѧا� ���ܧ֧ߧ��

    event Finalized();
    event Authorized(address wlCandidate, uint timestamp);
    event Revoked(address wlCandidate, uint timestamp);

    modifier isUnderHardCap() {
        require(weisRaised <= hardCapSale);
        _;
    }

    modifier backEnd() {
        require(msg.sender == backEndOperator || msg.sender == owner);
        _;
    }
    // �ܧ�ߧ����ܧ��� �ܧ�ߧ��ѧܧ��
    constructor(uint256 _dollareth) public {
        dollarPrice = _dollareth;
        preSalePrice = (1e18/dollarPrice)/2; // 16 �٧ߧѧܧ�� �����ާ� ���� 1 ��֧ߧ� !!!!!!!!!!!!
        MainSalePrice = 1e18/dollarPrice;
    }
    // �ѧӧ���ڧ٧ѧ�ڧ� ���ܧ֧ߧ�/ �ڧݧ� �ڧ٧ާ֧ߧ֧ߧڧ� �ѧէ�֧��
    function setToken (ERC20 _token) public onlyOwner {
        token = _token;
    }
    // �ڧ٧ާ֧ߧ֧ߧڧ� ��֧ߧ� Ether �� USD
    function setDollarRate(uint256 _usdether) public onlyOwner {
        dollarPrice = _usdether;
        preSalePrice = (1e18/dollarPrice)/2; // 16 �٧ߧѧܧ�� �����ާ� ���� 1 ��֧ߧ� !!!!!!!!!!!!
        MainSalePrice = 1e18/dollarPrice;
    }
    // �ڧ٧ާ֧ߧ֧ߧڧ� �էѧ�� �ߧѧ�ѧݧ� ���֧էӧѧ�ڧ�֧ݧ�ߧ�� ��ѧ����էѧا�
    function setStartPreSale(uint256 newStartPreSale) public onlyOwner {
        startPreSale = newStartPreSale;
    }
    // �ڧ٧ާ֧ߧ֧ߧڧ� �էѧ�� ��ܧ�ߧ�ѧߧڧ� ���֧էӧѧ�ڧ�֧ݧ�ߧ�� ��ѧ����էѧا�
    function setEndPreSale(uint256 newEndPreSaled) public onlyOwner {
        endPreSale = newEndPreSaled;
    }
    // �ڧ٧ާ֧ߧ֧ߧڧ� �էѧ�� �ߧѧ�ѧݧ� ���ߧ�ӧߧ�� ��ѧ����էѧا�
    function setStartSale(uint256 newStartSale) public onlyOwner {
        startMainSale = newStartSale;
    }
    // �ڧ٧ާ֧ߧ֧ߧڧ� �էѧ�� ��ܧ�ߧ�ѧߧڧ� ���ߧ�ӧߧ�� ��ѧ����էѧا�
    function setEndSale(uint256 newEndSaled) public onlyOwner {
        endMainSale = newEndSaled;
    }
    // ���٧ާ֧ߧ֧ߧڧ� �ѧէ�֧�� ���֧�ѧ���� �ҧ֧ܧ�ߧէ�
    function setBackEndAddress(address newBackEndOperator) public onlyOwner {
        backEndOperator = newBackEndOperator;
    }

    /*******************************************************************************
     * Whitelist's section
     */
    // �� ��ѧۧ�� backEndOperator �ѧӧ���ڧ٧�֧� �ڧߧӧ֧�����
    function authorize(address wlCandidate) public backEnd  {

        require(wlCandidate != address(0x0));
        require(!isWhitelisted(wlCandidate));
        whitelist[wlCandidate] = true;
        investors++;
        emit Authorized(wlCandidate, now);
    }
    // ���ާ֧ߧ� �ѧӧ���ڧ٧ѧ�ڧ� �ڧߧӧ֧����� �� WL(���ݧ�ܧ� �ӧݧѧէ֧ݧ֧� �ܧ�ߧ��ѧܧ��)
    function revoke(address wlCandidate) public  onlyOwner {
        whitelist[wlCandidate] = false;
        investors--;
        emit Revoked(wlCandidate, now);
    }
    // ����ӧ֧�ܧ� �ߧ� �ߧѧ��اէ֧ߧڧ� �ѧէ�֧�� �ڧߧӧ֧����� �� WL
    function isWhitelisted(address wlCandidate) internal view returns(bool) {
        return whitelist[wlCandidate];
    }
    /*******************************************************************************
     * Payable's section
     */

    function isPreSale() public constant returns(bool) {
        return now >= startPreSale && now <= endPreSale;
    }

    function isMainSale() public constant returns(bool) {
        return now >= startMainSale && now <= endMainSale;
    }
    // callback ���ߧܧ�ڧ� �ܧ�ߧ��ѧܧ��
    function () public payable //isUnderHardCap
    {
        require(isWhitelisted(msg.sender));

        if(isPreSale()) {
            preSale(msg.sender, msg.value);
        }

        else if (isMainSale()) {
            mainSale(msg.sender, msg.value);
        }

        else {
            revert();
        }
    }

    // �ӧ����� ���ܧ֧ߧ�� �� ��֧�ڧ�� ���֧էӧѧ�ڧ�֧ݧ�ߧ�� ��ѧ����էѧا�
    function preSale(address _investor, uint256 _value) internal {

        uint256 tokens = _value.mul(1e6).div(preSalePrice); // 1e18*1e18/

        token.mintFromICO(_investor, tokens);

        uint256 tokensFounders = tokens.mul(3).div(5); // 3/5
        token.mintFromICO(founders, tokensFounders);

        uint256 tokensBoynty = tokens.div(5); // 1/5
        token.mintFromICO(bounty, tokensBoynty);

        uint256 tokenReserve = tokens.div(5); // 1/5
        token.mintFromICO(reserve, tokenReserve);

        weisRaised = weisRaised.add(msg.value);
        soldTokensPreSale = soldTokensPreSale.add(tokens);

        require(soldTokensPreSale <= hardCapPreSale);
    }

    // �ӧ����� ���ܧ֧ߧ�� �� ��֧�ڧ�� ���ߧ�ӧߧ�� ��ѧ����էѧا�
    function mainSale(address _investor, uint256 _value) internal {
        uint256 tokens = _value.mul(1e6).div(MainSalePrice); // 1e18*1e18/

        token.mintFromICO(_investor, tokens);

        uint256 tokensFounders = tokens.mul(3).div(5); //3/5
        token.mintFromICO(founders, tokensFounders);

        uint256 tokensBoynty = tokens.div(5); // 1/5
        token.mintFromICO(bounty, tokensBoynty);

        uint256 tokenReserve = tokens.div(5); // 1/5
        token.mintFromICO(reserve, tokenReserve);

        weisRaised = weisRaised.add(msg.value);
        soldTokensSale = soldTokensSale.add(tokens);

        require(soldTokensSale <= hardCapSale);
    }

    // ����ߧܧ�ڧ� �����ѧӧܧ� ���ܧ֧ߧ�� ���ݧ��ѧ�֧ݧ�� �� ����ߧ�� ��֧اڧާ�(���ݧ�ܧ� �ӧݧѧէ֧ݧ֧� �ܧ�ߧ��ѧܧ��)
    function mintManual(address _recipient, uint256 _value) public backEnd {
        token.mintFromICO(_recipient, _value);

        uint256 tokensFounders = _value.mul(3).div(5);  // 3/5
        token.mintFromICO(founders, tokensFounders);

        uint256 tokensBoynty = _value.div(5);  // 1/5
        token.mintFromICO(bounty, tokensBoynty);

        uint256 tokenReserve = _value.div(5); // 1/5
        token.mintFromICO(reserve, tokenReserve);
        soldTokensSale = soldTokensSale.add(_value);
        //require(soldTokensPreSale <= hardCapPreSale);
        //require(soldTokensSale <= hardCapSale);
    }

    // ������ѧӧܧ� ���ڧ�� �� �ܧ�ߧ��ѧܧ��
    function transferEthFromContract(address _to, uint256 amount) public onlyOwner {
        _to.transfer(amount);
    }
}