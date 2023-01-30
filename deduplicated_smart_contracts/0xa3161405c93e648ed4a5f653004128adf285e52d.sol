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
    address founders = 0x2ed2de73f7aB776A6DB15A30ad7CB8f337CF499D; // 30% - §à§ã§ß§à§Ó§Ñ§ß§ä§Ö§Ý§Ú §á§â§à§Ö§Ü§ä§Ñ
    address bounty = 0x7a3B004E8A68BCD6C5D0c3936D2f582Acb89E5DD; // 10% - §Õ§Ý§ñ §Ò§Ñ§å§ß§ä§Ú §á§â§à§Ô§â§Ñ§Þ§Þ§í
    address reserve = 0xd9DADf245d04fB1566e7330be591445Ad9953476; // 10% - §Õ§Ý§ñ §â§Ö§Ù§Ö§â§Ó§Ñ

    mapping(address=>bool) public whitelist;

    uint256 public startPreSale = now; //1529020801; // Thursday, 15-Jun-18 00:00:01 UTC
    uint256 public endPreSale = 1535759999; // Friday, 31-Aug-18 23:59:59 UTC
    uint256 public startMainSale = 1538352001; // Monday, 01-Oct-18 00:00:01 UTC
    uint256 public endMainSale = 1554076799; // Sunday, 31-Mar-19 23:59:59 UTC

    uint256 public investors; // §à§Ò§ë§Ö§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó
    uint256 public weisRaised; // - §à§Ò§ë§Ö§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §ï§æ§Ú§â§Ñ §ã§à§Ò§â§Ñ§ß§ß§à§Ö §Ó §á§Ö§â§Ú§à§Õ §ã§Ö§Û§Ý§Ñ

    uint256 hardCapPreSale = 3200000*1e6; //  3 200 000 tokens
    uint256 hardCapSale = 15000000*1e6; // 15 000 000 tokens

    uint256 public preSalePrice; // 0.50 $ - §è§Ö§ß§Ñ §ä§à§Ü§Ö§ß§Ñ §ß§Ñ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ö
    uint256 public MainSalePrice; //1.00 $ - §è§Ö§ß§Ñ §ä§à§Ü§Ö§ß§Ñ §ß§Ñ §à§ã§ß§à§Ó§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ö
    uint256 public dollarPrice; // §è§Ö§ß§Ñ Ether §Ü USD

    uint256 public soldTokensPreSale; // 3 200 000 - §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §á§â§à§Õ§Ñ§ß§ß§í§ç §ß§Ñ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§à§á§â§à§Õ§Ñ§Ø§Ö §ä§à§Ü§Ö§ß§à§Ó
    uint256 public soldTokensSale; // 36 400 000 - §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §á§â§à§Õ§Ñ§ß§ß§í§ç §ß§Ñ §à§ã§ß§à§Ó§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ö §ä§à§Ü§Ö§ß§à§Ó

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
    // §Ü§à§ß§ã§ä§â§å§Ü§ä§à§â §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ
    constructor(uint256 _dollareth) public {
        dollarPrice = _dollareth;
        preSalePrice = (1e18/dollarPrice)/2; // 16 §Ù§ß§Ñ§Ü§à§Ó §á§à§ä§à§Þ§å §é§ä§à 1 §è§Ö§ß§ä !!!!!!!!!!!!
        MainSalePrice = 1e18/dollarPrice;
    }
    // §Ñ§Ó§ä§à§â§Ú§Ù§Ñ§è§Ú§ñ §ä§à§Ü§Ö§ß§Ñ/ §Ú§Ý§Ú §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Ñ§Õ§â§Ö§ã§Ñ
    function setToken (ERC20 _token) public onlyOwner {
        token = _token;
    }
    // §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §è§Ö§ß§í Ether §Ü USD
    function setDollarRate(uint256 _usdether) public onlyOwner {
        dollarPrice = _usdether;
        preSalePrice = (1e18/dollarPrice)/2; // 16 §Ù§ß§Ñ§Ü§à§Ó §á§à§ä§à§Þ§å §é§ä§à 1 §è§Ö§ß§ä !!!!!!!!!!!!
        MainSalePrice = 1e18/dollarPrice;
    }
    // §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Õ§Ñ§ä§í §ß§Ñ§é§Ñ§Ý§Ñ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú
    function setStartPreSale(uint256 newStartPreSale) public onlyOwner {
        startPreSale = newStartPreSale;
    }
    // §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Õ§Ñ§ä§í §à§Ü§à§ß§é§Ñ§ß§Ú§ñ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú
    function setEndPreSale(uint256 newEndPreSaled) public onlyOwner {
        endPreSale = newEndPreSaled;
    }
    // §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Õ§Ñ§ä§í §ß§Ñ§é§Ñ§Ý§Ñ §à§ã§ß§à§Ó§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú
    function setStartSale(uint256 newStartSale) public onlyOwner {
        startMainSale = newStartSale;
    }
    // §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Õ§Ñ§ä§í §à§Ü§à§ß§é§Ñ§ß§Ú§ñ §à§ã§ß§à§Ó§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú
    function setEndSale(uint256 newEndSaled) public onlyOwner {
        endMainSale = newEndSaled;
    }
    // §ª§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Ñ§Õ§â§Ö§ã§Ñ §à§á§Ö§â§Ñ§ä§à§â§Ñ §Ò§Ö§Ü§ï§ß§Õ§Ñ
    function setBackEndAddress(address newBackEndOperator) public onlyOwner {
        backEndOperator = newBackEndOperator;
    }

    /*******************************************************************************
     * Whitelist's section
     */
    // §ã §ã§Ñ§Û§ä§Ñ backEndOperator §Ñ§Ó§ä§à§â§Ú§Ù§å§Ö§ä §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ
    function authorize(address wlCandidate) public backEnd  {

        require(wlCandidate != address(0x0));
        require(!isWhitelisted(wlCandidate));
        whitelist[wlCandidate] = true;
        investors++;
        emit Authorized(wlCandidate, now);
    }
    // §à§ä§Þ§Ö§ß§Ñ §Ñ§Ó§ä§à§â§Ú§Ù§Ñ§è§Ú§Ú §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ §Ó WL(§ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ)
    function revoke(address wlCandidate) public  onlyOwner {
        whitelist[wlCandidate] = false;
        investors--;
        emit Revoked(wlCandidate, now);
    }
    // §á§â§à§Ó§Ö§â§Ü§Ñ §ß§Ñ §ß§Ñ§ç§à§Ø§Õ§Ö§ß§Ú§Ö §Ñ§Õ§â§Ö§ã§Ñ §Ú§ß§Ó§Ö§ã§ä§à§â§Ñ §Ó WL
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
    // callback §æ§å§ß§Ü§è§Ú§ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ
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

    // §Ó§í§á§å§ã§Ü §ä§à§Ü§Ö§ß§à§Ó §Ó §á§Ö§â§Ú§à§Õ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú
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

    // §Ó§í§á§å§ã§Ü §ä§à§Ü§Ö§ß§à§Ó §Ó §á§Ö§â§Ú§à§Õ §à§ã§ß§à§Ó§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú
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

    // §¶§å§ß§Ü§è§Ú§ñ §à§ä§á§â§Ñ§Ó§Ü§Ú §ä§à§Ü§Ö§ß§à§Ó §á§à§Ý§å§é§Ñ§ä§Ö§Ý§ñ§Þ §Ó §â§å§é§ß§à§Þ §â§Ö§Ø§Ú§Þ§Ö(§ä§à§Ý§î§Ü§à §Ó§Ý§Ñ§Õ§Ö§Ý§Ö§è §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ)
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

    // §°§ä§á§â§Ñ§Ó§Ü§Ñ §ï§æ§Ú§â§Ñ §ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ
    function transferEthFromContract(address _to, uint256 amount) public onlyOwner {
        _to.transfer(amount);
    }
}