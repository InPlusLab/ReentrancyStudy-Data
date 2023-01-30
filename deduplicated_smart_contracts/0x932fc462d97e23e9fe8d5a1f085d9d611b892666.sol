/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity ^0.4.26;

contract TewkenBank
{
     using SafeMath for uint256;


    /*==============================
    =            EVENTS            =
    ==============================*/
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    event onBuyEvent(
        address from,
        uint256 tokens
    );

     event onSellEvent(
        address from,
        uint256 tokens
    );


    /*==============================
    =            MODIFIERS         =
    ==============================*/

    bool isActive = false;

    modifier isActivated {
        require(isActive == true || msg.sender == owner);
        _;
    }

    modifier onlyOwner
    {
        require (msg.sender == owner);
        _;
    }

    modifier onlyFromGameWhiteListed
    {
        require (gameWhiteListed[msg.sender] == true);
        _;
    }

    modifier onlyTokenHolders() {
        require(myTokens() > 0);
        _;
    }

    address public owner;

    constructor () public
    {
        owner = address(0xC3502531f3555Ee6B283Cf1513B1C074900B144a);
    }

    /*==============================
    =       TOKEN VARIABLES        =
    ==============================*/

    string public name = "TewkenBank";
    string public symbol = "Tewken";
    uint8 constant public decimals = 18;
    uint256 constant internal magnitude = 1e18;

    uint8 constant internal transferFee = 1;
    uint8 internal buyInFee = 30;
    uint8 internal sellOutFee = 5;
    uint8 internal devFee = 1;

    mapping(address => uint256) public investedETH;
    mapping(address => uint256) private tokenBalanceLedger;

    uint256 public totalInvestor = 0;
    uint256 public totalDonation = 0;

    uint256 private tokenSupply = 0;
    uint256 private contractValue = 0;
    uint256 private tokenPrice = 0.00001 ether;   //starting price


   /*================================
    =       TEWKEN VARIABLES         =
    ================================*/

    mapping(address => bool) private gameWhiteListed;

    /*================================
    =       PUBLIC FUNCTIONS         =
    ================================*/

     /**
     * Fallback function to process ethereum
     */
    function()
        payable
        public
    {
        appreciateTokenPrice();
    }

    function addGame(address _contractAddress) public
    onlyOwner
    {
        gameWhiteListed[_contractAddress] = true;
    }

    function removeGame(address _contractAddress) public
    onlyOwner
    {
        gameWhiteListed[_contractAddress] = false;
    }

    function buyTokenSub(uint256 _eth , address _customerAddress) private
    returns(uint256)
    {

        uint256 _nb_token = (_eth.mul(magnitude)) / tokenPrice;

        tokenBalanceLedger[_customerAddress] =  tokenBalanceLedger[_customerAddress].add(_nb_token);
        tokenSupply = tokenSupply.add(_nb_token);

        emit onBuyEvent(_customerAddress , _nb_token);

        return(_nb_token);

    }

    function buyTokenFromGame(address _customerAddress) public payable
    onlyFromGameWhiteListed
    returns(uint256)
    {
        uint256 _eth = msg.value;

        require(_eth>=0.0001 ether);

        if (getInvested() == 0)
        {
            totalInvestor = totalInvestor.add(1);
        }

        investedETH[msg.sender] = investedETH[msg.sender].add(_eth);

        uint256 _devfee = (_eth.mul(devFee)) / 100;
        uint256 _fee = (_eth.mul(buyInFee)) / 100;

        buyTokenSub((_devfee.mul(100-buyInFee)) / 100 , owner);

        //finally buy for the buyer
        uint256 _nb_token = buyTokenSub(_eth - _fee -_devfee, _customerAddress);

        //add the value to the contract
        contractValue = contractValue.add(_eth);

        if (tokenSupply>magnitude)
        {
            tokenPrice = (contractValue.mul(magnitude)) / tokenSupply;
        }

        return(_nb_token);

    }


    function buyToken() public payable
    isActivated
    returns(uint256)
    {
        if (isActive == false){
          isActive = true;
        }

        uint256 _eth = msg.value;
        address _customerAddress = msg.sender;

        require(_eth>=0.0001 ether);

        if (getInvested() == 0)
        {
            totalInvestor = totalInvestor.add(1);
        }

        investedETH[msg.sender] = investedETH[msg.sender].add(_eth);

        uint256 _devfee = (_eth.mul(devFee)) / 100;
        uint256 _fee = (_eth.mul(buyInFee)) / 100;

        buyTokenSub((_devfee.mul(100-buyInFee)) / 100 , owner);

        //finally buy for the buyer
        uint256 _nb_token = buyTokenSub(_eth - _fee -_devfee, _customerAddress);

        //add the value to the contract
        contractValue = contractValue.add(_eth);

        if (tokenSupply>magnitude)
        {
            tokenPrice = (contractValue.mul(magnitude)) / tokenSupply;
        }

        return(_nb_token);

    }

    function sellToken(uint256 _amount) public
    isActivated
    onlyTokenHolders
    {
        address _customerAddress = msg.sender;

        uint256 balance = tokenBalanceLedger[_customerAddress];

        require(_amount <= balance);

        uint256 _eth = (_amount.mul(tokenPrice)) / magnitude;

        uint256 _fee = (_eth.mul(sellOutFee)) / 100;
        uint256 _devfee = (_eth.mul(devFee)) / 100;

        tokenSupply = tokenSupply.sub(_amount);

        balance = balance.sub(_amount);

        tokenBalanceLedger[_customerAddress] = balance;

        buyTokenSub((_devfee.mul(100-sellOutFee)) / 100 , owner);

        //calculate what is really leaving the contract, basically eth-fee-devfee
        _eth = _eth - _fee - _devfee;

        contractValue = contractValue.sub(_eth);

        if (tokenSupply>magnitude)
        {
            tokenPrice = (contractValue.mul(magnitude)) / tokenSupply;
        }

         emit onSellEvent(_customerAddress , _amount);

         //finally transfer the money
        _customerAddress.transfer(_eth);

    }

    //there is no fee using token to play TewkenBank powered games

    function payWithToken(uint256 _eth ,address _player_address) public
    onlyFromGameWhiteListed
    returns(uint256)
    {
        require(_eth>0 && _eth <= ethBalanceOfNoFee(_player_address));

        address _game_contract = msg.sender;

        uint256 balance = tokenBalanceLedger[_player_address];

        uint256 _nb_token = (_eth.mul(magnitude)) / tokenPrice;

        require(_nb_token <= balance);

        //confirm the ETH value
        _eth = (_nb_token.mul(tokenPrice)) / magnitude;

        balance = balance.sub(_nb_token);

        tokenSupply = tokenSupply.sub(_nb_token);

        tokenBalanceLedger[_player_address] = balance;

        contractValue = contractValue.sub(_eth);

        if (tokenSupply>magnitude)
        {
            tokenPrice = (contractValue.mul(magnitude)) / tokenSupply;
        }

        //send the money to the game contract
        _game_contract.transfer(_eth);

        return(_eth);
    }

    function appreciateTokenPrice() public payable
    onlyFromGameWhiteListed
    {
        uint256 _eth =  msg.value;

        contractValue = contractValue.add(_eth);
        totalDonation = totalDonation.add(_eth);

        //we need a minimum of 1 Tewken before appreciation is activated
        if (tokenSupply>magnitude)
        {
            tokenPrice = (contractValue.mul(magnitude)) / tokenSupply;
        }
    }

    function transferSub(address _customerAddress, address _toAddress, uint256 _amountOfTokens)
    private
    returns(bool)
    {

        require(_amountOfTokens <= tokenBalanceLedger[_customerAddress]);

        //actually a transfer of 0 token is valid in ERC20
        if (_amountOfTokens>0)
        {
            {
                uint256 _token_fee = (_amountOfTokens.mul(transferFee)) / 100;

                //now proceed the transfer
                tokenBalanceLedger[_customerAddress] = tokenBalanceLedger[_customerAddress].sub(_amountOfTokens);
                tokenBalanceLedger[_toAddress] = tokenBalanceLedger[_toAddress].add(_amountOfTokens - _token_fee);

                //burning the other half of token to drive the price up
                tokenSupply = tokenSupply.sub(_token_fee);

                if (tokenSupply>magnitude)
                {
                    tokenPrice = (contractValue.mul(magnitude)) / tokenSupply;
                }
            }
        }


        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);

        // ERC20
        return true;

    }

    function transfer(address _toAddress, uint256 _amountOfTokens) public
    isActivated
    returns(bool)
    {
        return(transferSub( msg.sender ,  _toAddress, _amountOfTokens));
    }


    /*================================
    =  VIEW AND HELPERS FUNCTIONS    =
    ================================*/


    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }

    function totalContractBalance()
        public
        view
        returns(uint)
    {
        return contractValue;
    }

    function totalInvestor()
        public
        view
        returns(uint256)
    {
        return totalInvestor;
    }

    function totalDonation()
        public
        view
        returns(uint256)
    {
        return totalDonation;
    }

    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply;
    }

    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger[_customerAddress];
    }

    function sellingPrice( bool includeFees)
        view
        public
        returns(uint256)
    {
        uint256 _fee = 0;
        uint256 _devfee=0;

        if (includeFees)
        {
            _fee = (tokenPrice.mul(sellOutFee)) / 100;
            _devfee = (tokenPrice.mul(devFee)) / 100;
        }

        return(tokenPrice - _fee - _devfee);

    }

    function buyingPrice( bool includeFees)
        view
        public
        returns(uint256)
    {
        uint256 _fee = 0;
        uint256 _devfee=0;

        if (includeFees)
        {
            _fee = (tokenPrice.mul(buyInFee)) / 100;
            _devfee = (tokenPrice.mul(devFee)) / 100;
        }

        return(tokenPrice + _fee + _devfee);

    }

    function calculateTokensReceived(uint256 _eth) public view returns (uint256) {
        uint256 _devfee = (_eth.mul(devFee)) / 100;
        uint256 _fee = (_eth.mul(buyInFee)) / 100;

        uint256 _taxed_eth = _eth - _fee -_devfee;

        uint256 _nb_token = (_taxed_eth.mul(magnitude)) / tokenPrice;

        return(_nb_token);
    }

    function ethBalanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        uint256 _price = sellingPrice(true);

        uint256 _balance = tokenBalanceLedger[_customerAddress];

        uint256 _value = (_balance.mul(_price)) / magnitude;

        return( _value );
    }

    function myEthBalanceOf()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return ethBalanceOf(_customerAddress);
    }

    function ethBalanceOfNoFee(address _customerAddress)
        view
        public
        returns(uint256)
    {
        uint256 _price = sellingPrice(false);

        uint256 _balance = tokenBalanceLedger[_customerAddress];

        uint256 _value = (_balance.mul(_price)) / magnitude;

        return( _value );
    }

    function myEthBalanceOfNoFee()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return ethBalanceOfNoFee(_customerAddress);
    }

    function checkGameListed(address _contract)
        public
        view
        returns(bool)
    {

        return(gameWhiteListed[ _contract]);
    }

    function getInvested()
        public
        view
        returns(uint256)
    {
        return investedETH[msg.sender];
    }

}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a);
        return c;
    }
}