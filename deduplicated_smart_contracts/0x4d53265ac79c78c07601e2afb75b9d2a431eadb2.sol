/**

 *Submitted for verification at Etherscan.io on 2018-10-24

*/



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



contract BossWage {

  uint256 public stakingRequirement;

  function buy(address _referredBy) public payable returns(uint256) {}

  function balanceOf(address _customerAddress) view public returns(uint256) {}

  function exit() public {}

  function calculateTokensReceived(uint256 _ethereumToSpend) public view returns(uint256) {}

  function calculateEthereumReceived(uint256 _tokensToSell) public view returns(uint256) { }

  function myDividends(bool _includeReferralBonus) public view returns(uint256) {}

  function withdraw() public {}

  function getDividends(address _customerAddress, bool _includeReferralBonus) public view returns(uint256) {}

}



contract Trends {

  using SafeMath for uint256;

  

  uint256 constant internal initialTokenPrice = 0.0000001 ether;

  uint256 constant internal tokenPriceIncremental = 0.00000001 ether;

  uint256 constant internal magnitude = 2**64;

  uint8 constant internal dividendFee = 20;

  uint8 constant internal bonusFee = 100;

  BossWage constant public bosswage = BossWage(0xbE67a76368dECa7420cEE6adcc9A86a887AE1716);

  

  struct Trend {

    string topic;

    uint256 supply;

    uint256 profitPerShare;

    uint256 created;

    mapping(address => uint256) balances;

    mapping(address => int256) payouts;

  }

  

  mapping(bytes32 => Trend) public trends;

  mapping(address => uint256) public referrals;

  

  event Purchase(

    bytes32 indexed trendId,

    address indexed owner,

    uint256 incomingEthereum,

    uint256 tokensMinted,

    address indexed referredBy

  );



  event Sell(

    bytes32 indexed trendId,

    address indexed owner,

    uint256 tokensBurned,

    uint256 ethereumEarned

  );



  event Reinvestment(

    bytes32 indexed trendId,

    address indexed owner,

    uint256 ethereumReinvested,

    uint256 tokensMinted,

    address indexed referredBy

  );

  

  event ReinvestReferrals(

    bytes32 indexed trendId,

    address indexed owner,

    uint256 ethereumReinvested,

    uint256 tokensMinted,

    address indexed referredBy

  );



  event Withdraw(

    bytes32 indexed trendId,

    address indexed owner,

    uint256 ethereumWithdrawn

  );

  

  event WithdrawReferrals(

    address indexed owner,

    uint256 ethereumWithdrawn

  );

  

  event Created(

    bytes32 indexed trendId,

    address indexed owner

  );

  

  // only people with tokens

  modifier onlyBagholders(bytes32 _trendId) {

    require(balanceOf(_trendId, msg.sender) > 0);

    _;

  }



  // only people with profits

  modifier onlyStronghands(bytes32 _trendId) {

    require(dividendsOf(_trendId, msg.sender) > 0);

    _;

  }

  

  // only existing trends

  modifier onlyTrends(bytes32 _trendId) {

    require(trends[_trendId].created != 0);

    _;

  }

  

  function() payable public {

    // only bosswage can send funds

    require(msg.sender == address(bosswage));

  }

  

  function createTrend(string _topic, address _referredBy) external payable returns (uint256) {

    // get trend id

    bytes32 trendId = keccak256(abi.encodePacked(_topic));

    

    // trend must not have already been created

    require(trends[trendId].created == 0);

    

    // create trend

    trends[trendId] = Trend(_topic, 0, 0, now);

    

    emit Created(trendId, msg.sender);

    

    if (msg.value > 0) {

      return purchase(trendId, msg.sender, msg.value, _referredBy);

    }

  }

  

  function buy(bytes32 _trendId, address _referredBy) onlyTrends(_trendId) external payable returns (uint256) {

    return purchase(_trendId, msg.sender, msg.value, _referredBy);

  }

  

  function reinvest(bytes32 _trendId, address _referredBy) onlyTrends(_trendId) onlyStronghands(_trendId) public {

    Trend storage trend = trends[_trendId];

        

    // pay out the dividends virtually

    address owner = msg.sender;



    // fetch dividends

    uint256 dividends = dividendsOf(_trendId, owner);



    trend.payouts[owner] += (int256) (dividends * magnitude);



    // dispatch a buy order with the virtualized "withdrawn dividends"

    uint256 tokens = purchase(_trendId, owner, dividends, _referredBy);



    // fire event

    emit Reinvestment(_trendId, owner, dividends, tokens, _referredBy);

  }

  

  function purchase(bytes32 _trendId, address _owner, uint256 _incomingEthereum, address _referredBy) internal returns (uint256) {

    Trend storage trend = trends[_trendId];



    uint256 undividedDividends = _incomingEthereum.div(dividendFee);

    uint256 taxedEthereum = _incomingEthereum.sub(undividedDividends);

    

    uint256 bonus = _incomingEthereum.div(bonusFee);

    uint256 dividends = undividedDividends.sub(bonus.mul(2));

    uint256 amountOfTokens = ethereumToTokens(taxedEthereum, trend.supply);

    uint256 fee = dividends * magnitude;

    

    disperse(bonus, _owner);



    require(amountOfTokens > 0 && (amountOfTokens.add(trend.supply) > trend.supply));



    // is the user referred by a masternode?

    if(

      // is this a referred purchase?

      _referredBy != 0x0000000000000000000000000000000000000000 &&

      

      // no cheating!

      _referredBy != _owner

    ) {

      // wealth redistribution

      referrals[_referredBy] = referrals[_referredBy].add(bonus);

    } else {

      // no ref purchase

      // add the referral bonus back to the global dividends cake

      dividends = dividends.add(bonus);

      fee = dividends * magnitude;

    }



    // we can't give people infinite ethereum

    if(trend.supply > 0){

      // add tokens to the pool

      trend.supply = trend.supply.add(amountOfTokens);



      // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder

      trend.profitPerShare += (dividends * magnitude / (trend.supply));



      // calculate the amount of tokens the customer receives over his purchase

      fee = fee - (fee-(amountOfTokens * (dividends * magnitude / (trend.supply))));

    } else {

      // add tokens to the pool

      trend.supply = amountOfTokens;

    }

    

    // update circulating supply & the ledger address for the customer

    trend.balances[_owner] = trend.balances[_owner].add(amountOfTokens);



    int256 updatedPayouts = (int256) ((trend.profitPerShare * amountOfTokens) - fee);

    trend.payouts[_owner] += updatedPayouts;

    

    emit Purchase(_trendId, _owner, _incomingEthereum, amountOfTokens, _referredBy);



    return amountOfTokens;

  }

  

  function sell(bytes32 _trendId, uint256 _amountOfTokens) onlyTrends(_trendId) onlyBagholders(_trendId) public {

    Trend storage trend = trends[_trendId];

    

    // setup data

    address owner = msg.sender;

    

    // russian hackers BTFO

    require(_amountOfTokens <= trend.balances[owner]);

    uint256 tokens = _amountOfTokens;

    uint256 ethereum = tokensToEthereum(tokens, trend.supply);



    // tax ethereum

    uint256 undividedDividends = ethereum.div(dividendFee);

    uint256 taxedEthereum = ethereum.sub(undividedDividends);



    // divide dividends

    uint256 bonus = ethereum.div(bonusFee);

    uint256 dividends = undividedDividends.sub(bonus);



    disperse(bonus, msg.sender);



    // burn the sold tokens

    trend.supply = trend.supply.sub(tokens);

    trend.balances[owner] = trend.balances[owner].sub(tokens);



    // update dividends tracker

    int256 updatedPayouts = (int256) (trend.profitPerShare * tokens + (taxedEthereum * magnitude));

    trend.payouts[owner] -= updatedPayouts;



    // dividing by zero is a bad idea

    if (trend.supply > 0) {

      // update the amount of dividends per token

      trend.profitPerShare = trend.profitPerShare.add((dividends * magnitude) / trend.supply);

    }



    // fire event

    emit Sell(_trendId, owner, tokens, taxedEthereum);

  }

    

  function exit(bytes32 _trendId) onlyTrends(_trendId) external {

    Trend storage trend = trends[_trendId];

    // get token count for caller & sell them all

    uint256 tokens = trend.balances[msg.sender];

    if(tokens > 0) sell(_trendId, tokens);



    withdraw(_trendId);

  }



  function withdraw(bytes32 _trendId) onlyTrends(_trendId) onlyStronghands(_trendId) public {

    Trend storage trend = trends[_trendId];

    

    // setup data

    address owner = msg.sender;

    uint256 dividends = dividendsOf(_trendId, owner);



    // update dividend tracker

    trend.payouts[owner] += (int256) (dividends * magnitude);

    

    // lambo delivery service

    owner.transfer(dividends);



    // fire event

    emit Withdraw(_trendId, owner, dividends);

  }

  

  function withdrawReferrals() external {

    address owner = msg.sender;

    uint256 dividends = referrals[owner];

    require(dividends > 0);

    referrals[owner] = 0;

    owner.transfer(dividends);

    emit WithdrawReferrals(owner, dividends);

  }

  

  function reinvestReferrals(bytes32 _trendId, address _referredBy) onlyTrends(_trendId) external {

    address owner = msg.sender;

    uint256 dividends = referrals[owner];

    require(dividends > 0);

    referrals[owner] = 0;

    

    uint256 tokens = purchase(_trendId, owner, dividends, _referredBy);

    

    emit ReinvestReferrals(_trendId, owner, dividends, tokens, _referredBy);

  }

  

  function disperse(uint256 _bonus, address _owner) internal {

    uint256 divs = bosswage.getDividends(address(this), true);

    if (divs > 0) {

      bosswage.withdraw();

    }

    uint256 totalBuy = _bonus.add(divs);

    bosswage.buy.value(totalBuy)(_owner);

  }

    

  function ethereumToTokens(uint256 _ethereum, uint256 _supply)

        internal

        pure

        returns(uint256)

    {

        uint256 tokenPriceInitial = initialTokenPrice * 1e18;

        uint256 tokensReceived =

         (

            (

                // underflow attempts BTFO

                SafeMath.sub(

                    (sqrt

                        (

                            (tokenPriceInitial**2)

                            +

                            (2*(tokenPriceIncremental * 1e18)*(_ethereum * 1e18))

                            +

                            (((tokenPriceIncremental)**2)*(_supply**2))

                            +

                            (2*(tokenPriceIncremental)*tokenPriceInitial*_supply)

                        )

                    ), tokenPriceInitial

                )

            )/(tokenPriceIncremental)

        )-(_supply)

        ;



        return tokensReceived;

  }



  function tokensToEthereum(uint256 _tokens, uint256 _supply)

        internal

        pure

        returns(uint256)

    {



        uint256 tokens = (_tokens + 1e18);

        uint256 tokenSupply = (_supply + 1e18);

        uint256 etherReceived =

        (

          SafeMath.sub(

            (

                (

                    (

                      initialTokenPrice +(tokenPriceIncremental * (tokenSupply/1e18))

                    )-tokenPriceIncremental

                )*(tokens - 1e18)

            ),(tokenPriceIncremental*((tokens**2-tokens)/1e18))/2

          )

        /1e18);

        return etherReceived;

  }



  function sqrt(uint x) internal pure returns (uint y) {

    uint z = (x + 1) / 2;

    y = x;

    while (z < y) {

      y = z;

      z = (x / z + z) / 2;

    }

  }

  

  function sellPrice(bytes32 _trendId) public view returns(uint256) {

    Trend memory trend = trends[_trendId];

    // our calculation relies on the token supply, so we need supply. Doh.

    if(trend.supply == 0){

      return initialTokenPrice - tokenPriceIncremental;

    } else {

      uint256 ethereum = tokensToEthereum(1e18, trend.supply);

      uint256 dividends = ethereum.div(dividendFee);

      uint256 taxedEthereum = ethereum.sub(dividends);

      return taxedEthereum;

    }

  }



  function buyPrice(bytes32 _trendId) public view returns(uint256) {

    Trend memory trend = trends[_trendId];

    // our calculation relies on the token supply, so we need supply. Doh.

    if(trend.supply == 0){

      return initialTokenPrice + tokenPriceIncremental;

    } else {

      uint256 ethereum = tokensToEthereum(1e18, trend.supply);

      uint256 dividends = ethereum.div(dividendFee);

      uint256 taxedEthereum = ethereum.sub(dividends);

      return taxedEthereum;

    }

  }



  function calculateTokensReceived(bytes32 _trendId, uint256 _ethereumToSpend) public view returns(uint256) {

    Trend memory trend = trends[_trendId];

    uint256 dividends = _ethereumToSpend.div(dividendFee);

    uint256 taxedEthereum = _ethereumToSpend.sub(dividends);

    uint256 amountOfTokens = ethereumToTokens(taxedEthereum, trend.supply);

    return amountOfTokens;

  }



  function calculateEthereumReceived(bytes32 _trendId, uint256 _tokensToSell) public view returns (uint256) {

    Trend memory trend = trends[_trendId];

    require(_tokensToSell <= trend.supply);

    uint256 ethereum = tokensToEthereum(_tokensToSell, trend.supply);

    uint256 dividends = ethereum.div(dividendFee);

    uint256 taxedEthereum = ethereum.sub(dividends);

    return taxedEthereum;

  }



  function balanceOf(bytes32 _trendId, address _owner) public view returns (uint256) {

    return trends[_trendId].balances[_owner];

  }

  

  function payoutsOf(bytes32 _trendId, address _owner) public  view returns (int256) {

    return trends[_trendId].payouts[_owner];

  }

  

  function dividendsOf(bytes32 _trendId, address _owner) public view returns(uint256) {

    return (uint256) ((int256)(trends[_trendId].profitPerShare * trends[_trendId].balances[_owner]) - trends[_trendId].payouts[_owner]) / magnitude;

  }

}