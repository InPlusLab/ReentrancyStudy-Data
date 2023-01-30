/**

 *Submitted for verification at Etherscan.io on 2018-10-16

*/



pragma solidity ^0.4.23;



/*** @title SafeMath

 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol */

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

    function isWhitelisted(address wlCandidate) external returns(bool);

}

/**

 * @title Ownable

 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol

 */

contract Ownable {

    address public owner;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

}



/**

 * @title CrowdSale

 * @dev https://github.com/

 */

contract OneStageMainSale is Ownable {



    ERC20 public token;

    

    ERC20 public authorize;

    

    using SafeMath for uint;



    address public backEndOperator = msg.sender;

    address team = 0x7eDE8260e573d3A3dDfc058f19309DF5a1f7397E; // 33% - team §Ú §â§Ñ§ß§ß§Ú§Ö §Ú§ß§Ó§Ö§ã§ä§à§â§í §á§â§à§Ö§Ü§ä§Ñ

    address bounty = 0x0cdb839B52404d49417C8Ded6c3E2157A06CdD37; // 2% - §Õ§Ý§ñ §Ò§Ñ§å§ß§ä§Ú §á§â§à§Ô§â§Ñ§Þ§Þ§í

    address reserve = 0xC032D3fCA001b73e8cC3be0B75772329395caA49; // 5%  - §Õ§Ý§ñ §â§Ö§Ù§Ö§â§Ó§Ñ



    mapping(address=>bool) public whitelist;



    mapping(address => uint256) public investedEther;



    uint256 public start1StageSale = 1539561601; // Monday, 15-Oct-18 00:00:01 UTC

    uint256 public end1StageSale = 1542326399; // Thursday, 15-Nov-18 23:59:59 UTC



    uint256 public investors; // §à§Ò§ë§Ö§Ö §Ü§à§Ý§Ú§é§Ö§ã§ä§Ó§à §Ú§ß§Ó§Ö§ã§ä§à§â§à§Ó

    uint256 public weisRaised; // §à§Ò§ë§Ö§Ö §Ü§à§Ý§Ú§Ö§ã§ä§Ó§à §ã§à§Ò§â§Ñ§ß§ß§í§ç Ether



    uint256 public softCap1Stage = 1000000*1e18; // $2,600,000 = 1,000,000 INM

    uint256 public hardCap1Stage = 1700000*1e18; // 1,700,000 INM = $4,420,000 USD



    uint256 public buyPrice; // 2.6 USD 

    uint256 public dollarPrice; // Ether by USD



    uint256 public soldTokens; // solded tokens - > 1,700,000 INM



    event Authorized(address wlCandidate, uint timestamp);

    event Revoked(address wlCandidate, uint timestamp);

    event UpdateDollar(uint256 time, uint256 _rate);



    modifier backEnd() {

        require(msg.sender == backEndOperator || msg.sender == owner);

        _;

    }



    // §Ü§à§ß§ã§ä§â§å§Ü§ä§à§â §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ

    constructor(ERC20 _token, ERC20 _authorize, uint256 usdETH) public {

        token = _token;

        authorize = _authorize;

        dollarPrice = usdETH;

        buyPrice = (1e17/dollarPrice)*26; // 2.60 usd

    }



    // §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Õ§Ñ§ä§í §ß§Ñ§é§Ñ§Ý§Ñ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú

    function setStartOneSale(uint256 newStart1Sale) public onlyOwner {

        start1StageSale = newStart1Sale;

    }



    // §Ú§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Õ§Ñ§ä§í §à§Ü§à§ß§é§Ñ§ß§Ú§ñ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú

    function setEndOneSale(uint256 newEnd1Sale) public onlyOwner {

        end1StageSale = newEnd1Sale;

    }



    // §ª§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Ñ§Õ§â§Ö§ã§Ñ §à§á§Ö§â§Ñ§ä§à§â§Ñ §Ò§Ö§Ü§ï§ß§Õ§Ñ

    function setBackEndAddress(address newBackEndOperator) public onlyOwner {

        backEndOperator = newBackEndOperator;

    }



    // §ª§Ù§Þ§Ö§ß§Ö§ß§Ú§Ö §Ü§å§â§ã§Ñ §Õ§à§Ý§Ý§â§Ñ §Ü §ï§æ§Ú§â§å

    function setBuyPrice(uint256 _dollar) public backEnd {

        dollarPrice = _dollar;

        buyPrice = (1e17/dollarPrice)*26; // 2.60 usd

        emit UpdateDollar(now, dollarPrice);

    }





    /*******************************************************************************

     * Payable's section

     */



    function isOneStageSale() public constant returns(bool) {

        return now >= start1StageSale && now <= end1StageSale;

    }



    // callback §æ§å§ß§Ü§è§Ú§ñ §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ

    function () public payable {

        require(authorize.isWhitelisted(msg.sender));

        require(isOneStageSale());

        require(msg.value >= 19*buyPrice); // ~ 50 USD

        SaleOneStage(msg.sender, msg.value);

        require(soldTokens<=hardCap1Stage);

        investedEther[msg.sender] = investedEther[msg.sender].add(msg.value);

    }



    // §Ó§í§á§å§ã§Ü §ä§à§Ü§Ö§ß§à§Ó §Ó §á§Ö§â§Ú§à§Õ §á§â§Ö§Õ§Ó§Ñ§â§Ú§ä§Ö§Ý§î§ß§à§Û §â§Ñ§ã§á§â§à§Õ§Ñ§Ø§Ú

    function SaleOneStage(address _investor, uint256 _value) internal {

        uint256 tokens = _value.mul(1e18).div(buyPrice);

        uint256 tokensByDate = tokens.div(10);

        uint256 bonusSumTokens = tokens.mul(bonusSum(tokens)).div(100);

        tokens = tokens.add(tokensByDate).add(bonusSumTokens); // 60%

        token.mintFromICO(_investor, tokens);

        soldTokens = soldTokens.add(tokens);



        uint256 tokensTeam = tokens.mul(11).div(20); // 33 %

        token.mintFromICO(team, tokensTeam);



        uint256 tokensBoynty = tokens.div(30); // 2 %

        token.mintFromICO(bounty, tokensBoynty);



        uint256 tokensReserve = tokens.div(12);  // 5 %

        token.mintFromICO(reserve, tokensReserve);



        weisRaised = weisRaised.add(_value);

    }



    function bonusSum(uint256 _amount) pure private returns(uint256) {

        if (_amount > 76923*1e18) { // 200k+	10% INMCoin

            return 10;

        } else if (_amount > 19230*1e18) { // 50k - 200k	7% INMCoin

            return 7;

        } else if (_amount > 7692*1e18) { // 20k - 50k	5% INMCoin

            return 5;

        } else if (_amount > 1923*1e18) { // 5k - 20k	3% INMCoin

            return 3;

        } else {

            return 0;

        }

    }



    // §°§ä§á§â§Ñ§Ó§Ü§Ñ §ï§æ§Ú§â§Ñ §ã §Ü§à§ß§ä§â§Ñ§Ü§ä§Ñ

    function transferEthFromContract(address _to, uint256 amount) public onlyOwner {

        _to.transfer(amount);

    }



    /*******************************************************************************

     * Refundable

     */

    function refund1ICO() public {

        require(soldTokens < softCap1Stage && now > end1StageSale);

        uint rate = investedEther[msg.sender];

        require(investedEther[msg.sender] >= 0);

        investedEther[msg.sender] = 0;

        msg.sender.transfer(rate);

        weisRaised = weisRaised.sub(rate);

    }

}