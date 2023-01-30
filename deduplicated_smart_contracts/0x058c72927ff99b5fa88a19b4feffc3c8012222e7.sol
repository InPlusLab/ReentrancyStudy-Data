/**

 *Submitted for verification at Etherscan.io on 2019-05-21

*/



pragma solidity >0.5.0;

// ------------------------------------------------------------------------

// TokenSale (TUSD) by Tentech Group OU Limited.

// 

// author: Tentech Group Team

// contact: Tentech [email protected]

//--------------------------------------------------------------------------



library SafeMath {

    /**

     * @dev Multiplies two unsigned integers, reverts on overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Adds two unsigned integers, reverts on overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

     * reverts when dividing by zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

    

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a>b) return a;

        return b;

    }

}



contract ERC20 {

    // Get the total token supply

    function totalSupply() public view returns (uint256 _totalSupply);

 

    // Get the account balance of another account with address _owner

    function balanceOf(address _owner) public view returns (uint256 balance);

    

    function decimals() public view returns (uint8);

 

    // Send _value amount of tokens to address _to

    function transfer(address _to, uint256 _value) public returns (bool success);

    

    // transfer _value amount of token approved by address _from

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    

    // approve an address with _value amount of tokens

    function approve(address _spender, uint256 _value) public returns (bool success);



    // get remaining token approved by _owner to _spender

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  

    // Triggered when tokens are transferred.

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

 

    // Triggered whenever approve(address _spender, uint256 _value) is called.

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract ERC20RcvContract {     

    function tokenFallback(address _from, uint _value) public;

}



contract TokenSale  is ERC20RcvContract {



    using SafeMath for uint;

    

    string public description = "TokenSale by TUSD v1.0";

    uint baseDecimals = 10**18;

    uint quoteDecimals = 10**6;

    uint ratioDecimals = 10**3;

    uint maxVerifyPerBatch = 50; // Specify the maximum buyers can be verified in a call to verifyBuyer()



    address internal baseToken =  0x0000000000085d4780B73119b644AE5ecd22b376;        // Address of the base token (TUSD)

    address internal quoteToken = 0xC9b965df61f634b35e34043545572F468aF6599D;        // Address of the quote token (GDEM - TenToken)

    address public fundOwner;           // Who own the fund wallet.

    address public broker;              // Who can fire contract methods



    uint public refundFeePerc;



    uint public exchangeRatio=0;        // How much of the quote currency is needed to purchase one unit of the base currency?

    uint public quoteTotal;             // Total token amount of the TokenSale

    uint public quoteBalance;           // The remaining amount of quoteTotal

    uint public baseTotalSold;          // We'll store the total baseToken raised via TokenSale    

    

    bool public issueTokenOnBuy=false;  //Auto issue token on receiving TUSD



    // Retail mode means

    // - Can purchase many times

    // - Token is issued upon receiving fund (TUSD)

    bool public retailMode=false;

    bool public isClosed=false; 



    uint public buyMin;   

    uint public buyMax;    

    uint public dateStart;

    uint public dateEnd;



    mapping (address => bool) public isVerified;

    mapping (address => bool) public isQuoteIssued;

    mapping (address => uint) public notVerifiedTransfer;

    

    event eBuyReceived(address indexed _from, uint _baseReceived, uint _quoteIssue);

    event eIssueToken(address indexed _to, uint _baseReceived, uint _quoteIssue);

    event eBuyRefund(address indexed _to, uint _refund, uint _refundFee);

    

    modifier onlyBroker() {

        require(msg.sender == broker, "The method can only be called by BROKER");

        _;

    }



    modifier validBuyDate() {

        require(now >= dateStart && now<=dateEnd, "TokenSale was not opened now");

        _;

    }    

      

    constructor ()  public 

    {

        // Wallet which deploy contract will become broker

        broker = msg.sender;

    }

            

    // Setup token sale paramenters

    function setup (uint _exChangeRatio, uint _buyMin, uint _buyMax, uint _refundFeePerc, uint _start, uint _end,

                    bool _retailMode)  public onlyBroker 

    {

        require(exchangeRatio==0, "Cannot resetup contract.");

        require(_exChangeRatio>0, "exchangeRatio must be greater than 0");

        require(_refundFeePerc>=0 && _refundFeePerc<ratioDecimals, "refundFeePerc is out of range");

        require(_buyMin>0, "buyMin must be greater than 0");

        require(_buyMax>=_buyMin, "buyMax must be greater or equal buyMin");

        require(_start<=_end, "dateStart must be greater or equal dateEnd");

        

        refundFeePerc = _refundFeePerc;

        exchangeRatio = _exChangeRatio.mul(quoteDecimals).div(ratioDecimals);



        buyMin = _buyMin;

        buyMax = _buyMax;

        dateStart = _start;

        dateEnd = _end;

        retailMode = _retailMode;      

    }

   

    // Calculate baseToken amount in exchange for received TUSD 

    function calcSellToken (uint _baseReceived) internal view returns(uint)

    {

        return _baseReceived.mul(exchangeRatio).div(baseDecimals);

    }



    // Calculate baseToken amount in exchange for received TUSD 

    function calcRefundFee (uint _amt) internal view returns(uint)

    {

        return _amt.mul(refundFeePerc).div(ratioDecimals);        

    }

    

    /// Issue baseToken

    function issueToken(address _to) public onlyBroker

    {

        require(retailMode==false, "Cannot run this method in Retail mode"); 



        uint _baseReceived = notVerifiedTransfer[_to];

        notVerifiedTransfer[_to] = 0;



        uint _quoteIssue = calcSellToken(_baseReceived);

        issueTokenInternal(_to,_baseReceived,_quoteIssue);

    }  

   

    /// Refund

    function refund(address _to)  public onlyBroker

    {

        require(retailMode==false, "Cannot run this method in Retail mode");  



        uint _baseReceived = notVerifiedTransfer[_to];

        require(_baseReceived>0, "No amount to refund");

        notVerifiedTransfer[_to] = 0;

     

        uint _refundFeeAmt = calcRefundFee(_baseReceived);

        uint _refundAmt = _baseReceived.sub(_refundFeeAmt);



        //Transfer refund amt from the contract to buyer

        ERC20(baseToken).transfer(_to, _refundAmt);



        //Transfer refund fee from the contract to fundOwner

        ERC20(baseToken).transfer(fundOwner, _refundFeeAmt);



        emit eBuyRefund(_to, _refundAmt, _refundFeeAmt); 

        

    }

        

    /// Transfer remain baseToken amount to fundOwner when the TokenSale was over/end by fundOwner

    function close() public onlyBroker 

    {    

        require(isClosed==false, "Contract was closed already");

        isClosed = true;



        uint _balanceAmt = quoteBalance;

        require(_balanceAmt>0, "Cannot close : Contract balance is 0");

        quoteBalance = 0;

        ERC20(quoteToken).transfer(fundOwner,_balanceAmt);

    } 



    // Set verified address who can receive quoteToken imediately upon transfering baseToken

    function verifyBuyer( address[] memory _list)  public onlyBroker 

    {

        require(isClosed==false, "Contract was closed");

        require(retailMode==false, "Cannot run this method in Retail mode");



        require(_list.length<=maxVerifyPerBatch, "Out of list : can only verify maxVerifyPerBatch addresses");

        for (uint idx=0; idx<_list.length; idx++) {

            isVerified[_list[idx]] = true;

        }

    }



    function setDate(uint _start, uint _end) public onlyBroker

    {    

        require(isClosed==false, "Contract was closed");

        dateStart = _start;

        dateEnd = _end;

    }



    function setBroker(address _broker) public onlyBroker

    {

        require(isClosed==false, "Contract was closed");

        require(_broker != broker);

        broker = _broker;

    } 

   

    function setAutoIssue(bool _auto)  public onlyBroker 

    {

        require(isClosed==false, "Contract was closed");

        require(retailMode==false, "Cannot run this method in Retail mode");        

        require(exchangeRatio>0, "exchangeRatio was out of range");

        require(issueTokenOnBuy!=_auto, "issueTokenOnBuy was set already");

        issueTokenOnBuy = _auto;

    }

           

    // Called when baseToken was transfered to setup the contract total

    function tokenFallback(address _from, uint _value)  public 

    {

        require(isClosed==false, "Contract was closed");

        require(_value>0, "Invalid : value must be greater than 0");

        // Buyer transfer token to buy TokenSale

        if (msg.sender==baseToken) {

            purchaseToken(_from, _value);

            return;

        }



        // Onwer send token to setup the TokenSale amount

        if (msg.sender==quoteToken) {

            setupTokenBalance(_from, _value);

            return;

        }

        revert();

    }

    

    function setupTokenBalance(address _from, uint _value) internal 

    {

        require(exchangeRatio>0, "exchangeRatio was not setup");

        

        if (fundOwner==address(0)) {

            // Wallet which transfered token will become fund owner

           fundOwner = _from;

        }

        else{

            //Ensure that only the owner can add more fund

            require(fundOwner==_from, "Only owner can add more fund");

        }



        //Add fund   

        uint _quoteTotal = _value;



        quoteTotal = quoteTotal.add(_quoteTotal);

        quoteBalance = quoteBalance.add(_quoteTotal);

    }

    

    function purchaseToken(address  _from, uint _baseReceived) internal validBuyDate 

    {

        require(quoteBalance>0, "quoteBalance was out of range");

        require(exchangeRatio>0, "exchangeRatio was out of range");



        uint _quoteIssue = validateBuyValue(_baseReceived);



        if (retailMode) issueTokenAndCollectFund(_from, _baseReceived, _quoteIssue);

        else{



            require(isQuoteIssued[_from]==false, "Cannot buy any more token");

            if (issueTokenOnBuy || isVerified[_from]==true)

                issueTokenInternal(_from, _baseReceived, _quoteIssue);

            else{

                require(notVerifiedTransfer[_from]==0, "Cannot transfer to buy more token");

                notVerifiedTransfer[_from] = _baseReceived;

            }

        }

        emit eBuyReceived(_from, _baseReceived, _quoteIssue); 

    }



    function issueTokenInternal(address _to,uint _baseReceived, uint  _quoteIssue) internal

    {

        require(_baseReceived>0, "_baseReceived is out of range");

        require(_quoteIssue>0, "_quoteIssue is out of range");     

        require(isQuoteIssued[_to]==false, "Cannot issue token any more");

        isQuoteIssued[_to]=true;

        issueTokenAndCollectFund(_to,_baseReceived,_quoteIssue);              

    }



    // Issue token to buyer and collect fund to owner

    function issueTokenAndCollectFund(address _to, uint _baseReceived, uint _quoteIssue) internal

    {

        require(quoteBalance>=_quoteIssue, "Insufficient quote token to issue"); 

        quoteBalance = quoteBalance.sub(_quoteIssue);

        baseTotalSold = baseTotalSold.add(_baseReceived);



        //Transfer quoteToken from the contract to buyer

        ERC20(quoteToken).transfer(_to, _quoteIssue);



        //Transfer baseToken from the contract to fundOwner

        ERC20(baseToken).transfer(fundOwner, _baseReceived);



        emit eIssueToken(_to, _quoteIssue, _baseReceived);        

    }

    

    // Validate buy amount and return the valid amount

    function validateBuyValue(uint _value) internal view returns(uint)

    {

        require(isClosed==false, "Contract was closed");    

        uint _buyAmt = calcSellToken(_value);

        require(_buyAmt >= buyMin && _buyAmt<=buyMax, "Buy amount was out of range");

        require(_buyAmt <= quoteBalance, "Insufficient token to supply");

        return _buyAmt;

    }   

}