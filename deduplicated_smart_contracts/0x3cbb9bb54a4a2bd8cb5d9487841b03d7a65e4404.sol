pragma solidity ^0.4.15;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract DNNTDE {

    using SafeMath for uint256;

    /////////////////////////
    // DNN Token Contract  //
    /////////////////////////
    DNNToken public dnnToken;

    //////////////////////////////////////////
    // Addresses of the co-founders of DNN. //
    //////////////////////////////////////////
    address public cofounderA;
    address public cofounderB;

    ///////////////////////////
    // DNN Holding Multisig //
    //////////////////////////
    address public dnnHoldingMultisig;

    ///////////////////////////
    // Start date of the TDE //
    ///////////////////////////
    uint256 public TDEStartDate;  // Epoch

    /////////////////////////
    // End date of the TDE //
    /////////////////////////
    uint256 public TDEEndDate;  // Epoch

    /////////////////////////////////
    // Amount of atto-DNN per wei //
    /////////////////////////////////
    uint256 public tokenExchangeRateBase = 3000; // 1 Wei = 3000 atto-DNN

    /////////////////////////////////////////////////
    // Number of tokens distributed (in atto-DNN) //
    /////////////////////////////////////////////////
    uint256 public tokensDistributed = 0;

    ///////////////////////////////////////////////
    // Minumum Contributions for pre-TDE and TDE //
    ///////////////////////////////////////////////
    uint256 public minimumTDEContributionInWei = 0.001 ether;
    uint256 public minimumPRETDEContributionInWei = 5 ether;

    //////////////////////
    // Funding Hard cap //
    //////////////////////
    uint256 public maximumFundingGoalInETH;

    //////////////////
    // Funds Raised //
    //////////////////
    uint256 public fundsRaisedInWei = 0;
    uint256 public presaleFundsRaisedInWei = 0;

    ////////////////////////////////////////////
    // Keep track of Wei contributed per user //
    ////////////////////////////////////////////
    mapping(address => uint256) ETHContributions;


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Keeps track of pre-tde contributors and how many tokens they are entitled to get based on their contribution //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    mapping(address => uint256) PRETDEContributorTokensPendingRelease;
    uint256 PRETDEContributorsTokensPendingCount = 0; // keep track of contributors waiting for tokens
    uint256 TokensPurchasedDuringPRETDE = 0; // keep track of how many tokens need to be issued to presale contributors

    ///////////////////////////////////////////////////////////////////
    // Checks if all pre-tde contributors have received their tokens //
    ///////////////////////////////////////////////////////////////////
    modifier NoPRETDEContributorsAwaitingTokens() {

        // Determine if all pre-tde contributors have received tokens
        require(PRETDEContributorsTokensPendingCount == 0);

        _;
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    // Checks if there are any pre-tde contributors that have not recieved their tokens  //
    ///////////////////////////////////////////////////////////////////////////////////////
    modifier PRETDEContributorsAwaitingTokens() {

        // Determine if there pre-tde contributors that have not received tokens
        require(PRETDEContributorsTokensPendingCount > 0);

        _;
    }

    ////////////////////////////////////////////////////
    // Checks if CoFounders are performing the action //
    ////////////////////////////////////////////////////
    modifier onlyCofounders() {
        require (msg.sender == cofounderA || msg.sender == cofounderB);
        _;
    }

    ////////////////////////////////////////////////////
    // Checks if CoFounder A is performing the action //
    ////////////////////////////////////////////////////
    modifier onlyCofounderA() {
        require (msg.sender == cofounderA);
        _;
    }

    ////////////////////////////////////////////////////
    // Checks if CoFounder B is performing the action //
    ////////////////////////////////////////////////////
    modifier onlyCofounderB() {
        require (msg.sender == cofounderB);
        _;
    }

    //////////////////////////////////////
    // Check if the pre-tde is going on //
    //////////////////////////////////////
    modifier PRETDEHasNotEnded() {
       require (now < TDEStartDate);
       _;
    }

    ////////////////////////////////s
    // Check if the tde has ended //
    ////////////////////////////////
    modifier TDEHasEnded() {
       require (now >= TDEEndDate || fundsRaisedInWei >= maximumFundingGoalInETH);
       _;
    }

    //////////////////////////////////////////////////////////////////////////////
    // Checksto see if the contribution is at least the minimum allowed for tde //
    //////////////////////////////////////////////////////////////////////////////
    modifier ContributionIsAtLeastMinimum() {
        require (msg.value >= minimumTDEContributionInWei);
        _;
    }

    ///////////////////////////////////////////////////////////////
    // Make sure max cap is not exceeded with added contribution //
    ///////////////////////////////////////////////////////////////
    modifier ContributionDoesNotCauseGoalExceedance() {
       uint256 newFundsRaised = msg.value+fundsRaisedInWei;
       require (newFundsRaised <= maximumFundingGoalInETH);
       _;
    }

    /////////////////////////////////////////////////////////////////
    // Check if the specified beneficiary has sent us funds before //
    /////////////////////////////////////////////////////////////////
    modifier HasPendingPRETDETokens(address _contributor) {
        require (PRETDEContributorTokensPendingRelease[_contributor] !=  0);
        _;
    }

    /////////////////////////////////////////////////////////////
    // Check if pre-tde contributors is not waiting for tokens //
    /////////////////////////////////////////////////////////////
    modifier IsNotAwaitingPRETDETokens(address _contributor) {
        require (PRETDEContributorTokensPendingRelease[_contributor] ==  0);
        _;
    }

    ///////////////////////////////////////////////////////
    //  @des Function to change founder A address.       //
    //  @param newAddress Address of new founder A.      //
    ///////////////////////////////////////////////////////
    function changeCofounderA(address newAddress)
        onlyCofounderA
    {
        cofounderA = newAddress;
    }

    //////////////////////////////////////////////////////
    //  @des Function to change founder B address.      //
    //  @param newAddress Address of new founder B.     //
    //////////////////////////////////////////////////////
    function changeCofounderB(address newAddress)
        onlyCofounderB
    {
        cofounderB = newAddress;
    }

    ////////////////////////////////////////
    //  @des Function to extend pre-tde   //
    //  @param new crowdsale start date   //
    ////////////////////////////////////////
    function extendPRETDE(uint256 startDate)
        onlyCofounders
        PRETDEHasNotEnded
        returns (bool)
    {
        // Make sure that the new date is past the existing date and
        // is not in the past.
        if (startDate > now && startDate > TDEStartDate) {
            TDEEndDate = TDEEndDate + (startDate-TDEStartDate); // Move end date the same amount of days as start date
            TDEStartDate = startDate; // set new start date
            return true;
        }

        return false;
    }

    //////////////////////////////////////////////////////
    //  @des Function to change multisig address.       //
    //  @param newAddress Address of new multisig.      //
    //////////////////////////////////////////////////////
    function changeDNNHoldingMultisig(address newAddress)
        onlyCofounders
    {
        dnnHoldingMultisig = newAddress;
    }

    //////////////////////////////////////////
    // @des ETH balance of each contributor //
    //////////////////////////////////////////
    function contributorETHBalance(address _owner)
      constant
      returns (uint256 balance)
    {
        return ETHContributions[_owner];
    }

    ////////////////////////////////////////////////////////////
    // @des Determines if an address is a pre-TDE contributor //
    ////////////////////////////////////////////////////////////
    function isAwaitingPRETDETokens(address _contributorAddress)
       internal
       returns (bool)
    {
        return PRETDEContributorTokensPendingRelease[_contributorAddress] > 0;
    }

    /////////////////////////////////////////////////////////////
    // @des Returns pending presale tokens for a given address //
    /////////////////////////////////////////////////////////////
    function getPendingPresaleTokens(address _contributor)
        constant
        returns (uint256)
    {
        return PRETDEContributorTokensPendingRelease[_contributor];
    }

    ////////////////////////////////
    // @des Returns current bonus //
    ////////////////////////////////
    function getCurrentTDEBonus()
        constant
        returns (uint256)
    {
        return getTDETokenExchangeRate(now);
    }


    ////////////////////////////////
    // @des Returns current bonus //
    ////////////////////////////////
    function getCurrentPRETDEBonus()
        constant
        returns (uint256)
    {
        return getPRETDETokenExchangeRate(now);
    }

    ///////////////////////////////////////////////////////////////////////
    // @des Returns bonus (in atto-DNN) per wei for the specific moment //
    // @param timestamp Time of purchase (in seconds)                    //
    ///////////////////////////////////////////////////////////////////////
    function getTDETokenExchangeRate(uint256 timestamp)
        constant
        returns (uint256)
    {
        // No bonus - TDE ended
        if (timestamp > TDEEndDate) {
            return uint256(0);
        }

        // No bonus - TDE has not started
        if (TDEStartDate > timestamp) {
            return uint256(0);
        }

        // 1 ETH = 3600 DNN (0 - 20% of funding goal) - 20% Bonus
        if (fundsRaisedInWei <= maximumFundingGoalInETH.mul(20).div(100)) {
            return tokenExchangeRateBase.mul(120).div(100);

        // 1 ETH = 3450 DNN (>20% to 60% of funding goal) - 15% Bonus
        } else if (fundsRaisedInWei > maximumFundingGoalInETH.mul(20).div(100) && fundsRaisedInWei <= maximumFundingGoalInETH.mul(60).div(100)) {
            return tokenExchangeRateBase.mul(115).div(100);

        // 1 ETH = 3300 DNN (>60% to Funding Goal) - 10% Bonus
        } else if (fundsRaisedInWei > maximumFundingGoalInETH.mul(60).div(100) && fundsRaisedInWei <= maximumFundingGoalInETH) {
            return tokenExchangeRateBase.mul(110).div(100);

        // Default: 1 ETH = 3000 DNN
        } else {
            return tokenExchangeRateBase;
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////
    // @des Returns bonus (in atto-DNN) per wei for the specific contribution amount //
    // @param weiamount The amount of wei being contributed                           //
    ////////////////////////////////////////////////////////////////////////////////////
    function getPRETDETokenExchangeRate(uint256 weiamount)
        constant
        returns (uint256)
    {
        // Presale will only accept contributions above minimum
        if (weiamount < minimumPRETDEContributionInWei) {
            return uint256(0);
        }

        // Minimum Contribution - 199 ETH (25% Bonus)
        if (weiamount >= minimumPRETDEContributionInWei && weiamount <= 199 ether) {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(25).div(100);

        // 200 ETH - 300 ETH Bonus (30% Bonus)
        } else if (weiamount >= 200 ether && weiamount <= 300 ether) {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(30).div(100);

        // 301 ETH - 2665 ETH Bonus (35% Bonus)
        } else if (weiamount >= 301 ether && weiamount <= 2665 ether) {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(35).div(100);

        // 2666+ ETH Bonus (50% Bonus)
        } else {
            return tokenExchangeRateBase + tokenExchangeRateBase.mul(50).div(100);
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // @des Computes how many tokens a buyer is entitled to based on contribution and time. //
    //////////////////////////////////////////////////////////////////////////////////////////
    function calculateTokens(uint256 weiamount, uint256 timestamp)
        constant
        returns (uint256)
    {

        // Compute how many atto-DNN user is entitled to.
        uint256 computedTokensForPurchase = weiamount.mul(timestamp >= TDEStartDate ? getTDETokenExchangeRate(timestamp) : getPRETDETokenExchangeRate(weiamount));

        // Amount of atto-DNN to issue
        return computedTokensForPurchase;
     }


    ///////////////////////////////////////////////////////////////
    // @des Issues tokens for users who made purchase with ETH   //
    // @param beneficiary Address the tokens will be issued to.  //
    // @param weiamount ETH amount (in Wei)                      //
    // @param timestamp Time of purchase (in seconds)            //
    ///////////////////////////////////////////////////////////////
    function buyTokens()
        internal
        ContributionIsAtLeastMinimum
        ContributionDoesNotCauseGoalExceedance
        returns (bool)
    {

        // Determine how many tokens should be issued
        uint256 tokenCount = calculateTokens(msg.value, now);

        // Update total amount of tokens distributed (in atto-DNN)
        tokensDistributed = tokensDistributed.add(tokenCount);

        // Keep track of contributions (in Wei)
        ETHContributions[msg.sender] = ETHContributions[msg.sender].add(msg.value);

        // Increase total funds raised by contribution
        fundsRaisedInWei = fundsRaisedInWei.add(msg.value);

        // Determine which token allocation we should be deducting from
        DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.TDESupplyAllocation;

        // Attempt to issue tokens to contributor
        if (!dnnToken.issueTokens(msg.sender, tokenCount, allocationType)) {
            revert();
        }

        // Transfer funds to multisig
        dnnHoldingMultisig.transfer(msg.value);

        return true;
    }

    ////////////////////////////////////////////////////////////////////////////////////////
    // @des Issues tokens for users who made purchase without using ETH during presale.   //
    // @param beneficiary Address the tokens will be issued to.                           //
    // @param weiamount ETH amount (in Wei)                                               //
    ////////////////////////////////////////////////////////////////////////////////////////
    function buyPRETDETokensWithoutETH(address beneficiary, uint256 weiamount, uint256 tokenCount)
        onlyCofounders
        PRETDEHasNotEnded
        IsNotAwaitingPRETDETokens(beneficiary)
        returns (bool)
    {
          // Keep track of contributions (in Wei)
          ETHContributions[beneficiary] = ETHContributions[beneficiary].add(weiamount);

          // Increase total funds raised by contribution
          fundsRaisedInWei = fundsRaisedInWei.add(weiamount);

          // Keep track of presale funds in addition, separately
          presaleFundsRaisedInWei = presaleFundsRaisedInWei.add(weiamount);

          // Add these tokens to the total amount of tokens this contributor is entitled to
          PRETDEContributorTokensPendingRelease[beneficiary] = PRETDEContributorTokensPendingRelease[beneficiary].add(tokenCount);

          // Incrment number of pre-tde contributors waiting for tokens
          PRETDEContributorsTokensPendingCount += 1;

          // Send tokens to contibutor
          return issuePRETDETokens(beneficiary);
      }

    ///////////////////////////////////////////////////////////////
    // @des Issues pending tokens to pre-tde contributor         //
    // @param beneficiary Address the tokens will be issued to.  //
    ///////////////////////////////////////////////////////////////
    function issuePRETDETokens(address beneficiary)
        onlyCofounders
        PRETDEContributorsAwaitingTokens
        HasPendingPRETDETokens(beneficiary)
        returns (bool)
    {

        // Amount of tokens to credit pre-tde contributor
        uint256 tokenCount = PRETDEContributorTokensPendingRelease[beneficiary];

        // Update total amount of tokens distributed (in atto-DNN)
        tokensDistributed = tokensDistributed.add(tokenCount);

        // Allocation type will be PRETDESupplyAllocation
        DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.PRETDESupplyAllocation;

        // Attempt to issue tokens
        if (!dnnToken.issueTokens(beneficiary, tokenCount, allocationType)) {
            revert();
        }

        // Reduce number of pre-tde contributors waiting for tokens
        PRETDEContributorsTokensPendingCount -= 1;

        // Denote that tokens have been issued for this pre-tde contributor
        PRETDEContributorTokensPendingRelease[beneficiary] = 0;

        return true;
    }


    /////////////////////////////////
    // @des Marks TDE as completed //
    /////////////////////////////////
    function finalizeTDE()
       onlyCofounders
       TDEHasEnded
    {
        // Check if the tokens are locked and all pre-sale tokens have been
        // transferred to the TDE Supply before unlocking tokens.
        require(dnnToken.tokensLocked() == true && dnnToken.PRETDESupplyRemaining() == 0);

        // Unlock tokens
        dnnToken.unlockTokens();

        // Update tokens distributed
        tokensDistributed += dnnToken.TDESupplyRemaining();

        // Transfer unsold TDE tokens to platform
        dnnToken.sendUnsoldTDETokensToPlatform();
    }


    ////////////////////////////////////////////////////////////////////////////////
    // @des Marks pre-TDE as completed by moving remaining tokens into TDE supply //
    ////////////////////////////////////////////////////////////////////////////////
    function finalizePRETDE()
       onlyCofounders
       NoPRETDEContributorsAwaitingTokens
    {
        // Check if we have tokens to transfer to TDE
        require(dnnToken.PRETDESupplyRemaining() > 0);

        // Transfer unsold TDE tokens to platform
        dnnToken.sendUnsoldPRETDETokensToTDE();
    }


    ///////////////////////////////
    // @des Contract constructor //
    ///////////////////////////////
    function DNNTDE(address tokenAddress, address founderA, address founderB, address dnnHolding, uint256 hardCap, uint256 startDate, uint256 endDate)
    {

        // Set token address
        dnnToken = DNNToken(tokenAddress);

        // Set cofounder addresses
        cofounderA = founderA;
        cofounderB = founderB;

        // Set DNN holding address
        dnnHoldingMultisig = dnnHolding;

        // Set Hard Cap
        maximumFundingGoalInETH = hardCap * 1 ether;

        // Set Start Date
        TDEStartDate = startDate >= now ? startDate : now;

        // Set End date (Make sure the end date is at least 30 days from start date)
        // Will default to a date that is exactly 30 days from start date.
        TDEEndDate = endDate > TDEStartDate && (endDate-TDEStartDate) >= 30 days ? endDate : (TDEStartDate + 30 days);
    }

    /////////////////////////////////////////////////////////
    // @des Handle&#39;s ETH sent directly to contract address //
    /////////////////////////////////////////////////////////
    function () payable {

        // Handle pre-sale contribution (tokens held, until tx confirmation from contributor)
        // Makes sure the user sends minimum PRE-TDE contribution, and that  pre-tde contributors
        // are unable to send subsequent ETH contributors before being issued tokens.
        if (now < TDEStartDate && msg.value >= minimumPRETDEContributionInWei && PRETDEContributorTokensPendingRelease[msg.sender] == 0) {

            // Keep track of contributions (in Wei)
            ETHContributions[msg.sender] = ETHContributions[msg.sender].add(msg.value);

            // Increase total funds raised by contribution
            fundsRaisedInWei = fundsRaisedInWei.add(msg.value);

            // Keep track of presale funds in addition, separately
            presaleFundsRaisedInWei = presaleFundsRaisedInWei.add(msg.value);

            /// Make a note of how many tokens this user should get for their contribution to the presale
            PRETDEContributorTokensPendingRelease[msg.sender] = PRETDEContributorTokensPendingRelease[msg.sender].add(calculateTokens(msg.value, now));

            // Keep track of pending tokens
            TokensPurchasedDuringPRETDE += calculateTokens(msg.value, now);

            // Increment number of pre-tde contributors waiting for tokens
            PRETDEContributorsTokensPendingCount += 1;

            // Prevent contributions that will cause us to have a shortage of tokens during the pre-sale
            if (TokensPurchasedDuringPRETDE > dnnToken.TDESupplyRemaining()+dnnToken.PRETDESupplyRemaining()) {
                revert();
            }

            // Transfer contribution directly to multisig
            dnnHoldingMultisig.transfer(msg.value);
        }

        // Handle public-sale contribution (tokens issued immediately)
        else if (now >= TDEStartDate && now < TDEEndDate) buyTokens();

        // Otherwise, reject the contribution
        else revert();
    }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract DNNToken is StandardToken {

    using SafeMath for uint256;

    ////////////////////////////////////////////////////////////
    // Used to indicate which allocation we issue tokens from //
    ////////////////////////////////////////////////////////////
    enum DNNSupplyAllocations {
        EarlyBackerSupplyAllocation,
        PRETDESupplyAllocation,
        TDESupplyAllocation,
        BountySupplyAllocation,
        WriterAccountSupplyAllocation,
        AdvisorySupplyAllocation,
        PlatformSupplyAllocation
    }

    /////////////////////////////////////////////////////////////////////
    // Smart-Contract with permission to allocate tokens from supplies //
    /////////////////////////////////////////////////////////////////////
    address public allocatorAddress;
    address public crowdfundContract;

    /////////////////////
    // Token Meta Data //
    /////////////////////
    string constant public name = "DNN";
    string constant public symbol = "DNN";
    uint8 constant public decimals = 18; // 1 DNN = 1 * 10^18 atto-DNN

    /////////////////////////////////////////
    // Addresses of the co-founders of DNN //
    /////////////////////////////////////////
    address public cofounderA;
    address public cofounderB;

    /////////////////////////
    // Address of Platform //
    /////////////////////////
    address public platform;

    /////////////////////////////////////////////
    // Token Distributions (% of total supply) //
    /////////////////////////////////////////////
    uint256 public earlyBackerSupply; // 10%
    uint256 public PRETDESupply; // 10%
    uint256 public TDESupply; // 40%
    uint256 public bountySupply; // 1%
    uint256 public writerAccountSupply; // 4%
    uint256 public advisorySupply; // 14%
    uint256 public cofoundersSupply; // 10%
    uint256 public platformSupply; // 11%

    uint256 public earlyBackerSupplyRemaining; // 10%
    uint256 public PRETDESupplyRemaining; // 10%
    uint256 public TDESupplyRemaining; // 40%
    uint256 public bountySupplyRemaining; // 1%
    uint256 public writerAccountSupplyRemaining; // 4%
    uint256 public advisorySupplyRemaining; // 14%
    uint256 public cofoundersSupplyRemaining; // 10%
    uint256 public platformSupplyRemaining; // 11%

    ////////////////////////////////////////////////////////////////////////////////////
    // Amount of CoFounder Supply that has been distributed based on vesting schedule //
    ////////////////////////////////////////////////////////////////////////////////////
    uint256 public cofoundersSupplyVestingTranches = 10;
    uint256 public cofoundersSupplyVestingTranchesIssued = 0;
    uint256 public cofoundersSupplyVestingStartDate; // Epoch
    uint256 public cofoundersSupplyDistributed = 0;  // # of atto-DNN distributed to founders

    //////////////////////////////////////////////
    // Prevents tokens from being transferrable //
    //////////////////////////////////////////////
    bool public tokensLocked = true;

    /////////////////////////////////////////////////////////////////////////////
    // Event triggered when tokens are transferred from one address to another //
    /////////////////////////////////////////////////////////////////////////////
    event Transfer(address indexed from, address indexed to, uint256 value);

    ////////////////////////////////////////////////////////////
    // Checks if tokens can be issued to founder at this time //
    ////////////////////////////////////////////////////////////
    modifier CofoundersTokensVested()
    {
        // Make sure that a starting vesting date has been set and 4 weeks have passed since vesting date
        require (cofoundersSupplyVestingStartDate != 0 && (now-cofoundersSupplyVestingStartDate) >= 4 weeks);

        // Get current tranche based on the amount of time that has passed since vesting start date
        uint256 currentTranche = now.sub(cofoundersSupplyVestingStartDate) / 4 weeks;

        // Amount of tranches that have been issued so far
        uint256 issuedTranches = cofoundersSupplyVestingTranchesIssued;

        // Amount of tranches that cofounders are entitled to
        uint256 maxTranches = cofoundersSupplyVestingTranches;

        // Make sure that we still have unvested tokens and that
        // the tokens for the current tranche have not been issued.
        require (issuedTranches != maxTranches && currentTranche > issuedTranches);

        _;
    }

    ///////////////////////////////////
    // Checks if tokens are unlocked //
    ///////////////////////////////////
    modifier TokensUnlocked()
    {
        require (tokensLocked == false);
        _;
    }

    /////////////////////////////////
    // Checks if tokens are locked //
    /////////////////////////////////
    modifier TokensLocked()
    {
       require (tokensLocked == true);
       _;
    }

    ////////////////////////////////////////////////////
    // Checks if CoFounders are performing the action //
    ////////////////////////////////////////////////////
    modifier onlyCofounders()
    {
        require (msg.sender == cofounderA || msg.sender == cofounderB);
        _;
    }

    ////////////////////////////////////////////////////
    // Checks if CoFounder A is performing the action //
    ////////////////////////////////////////////////////
    modifier onlyCofounderA()
    {
        require (msg.sender == cofounderA);
        _;
    }

    ////////////////////////////////////////////////////
    // Checks if CoFounder B is performing the action //
    ////////////////////////////////////////////////////
    modifier onlyCofounderB()
    {
        require (msg.sender == cofounderB);
        _;
    }

    /////////////////////////////////////////////////////////////////////
    // Checks to see if we are allowed to change the allocator address //
    /////////////////////////////////////////////////////////////////////
    modifier CanSetAllocator()
    {
       require (allocatorAddress == address(0x0) || tokensLocked == false);
       _;
    }

    //////////////////////////////////////////////////////////////////////
    // Checks to see if we are allowed to change the crowdfund contract //
    //////////////////////////////////////////////////////////////////////
    modifier CanSetCrowdfundContract()
    {
       require (crowdfundContract == address(0x0));
       _;
    }

    //////////////////////////////////////////////////
    // Checks if Allocator is performing the action //
    //////////////////////////////////////////////////
    modifier onlyAllocator()
    {
        require (msg.sender == allocatorAddress && tokensLocked == false);
        _;
    }

    ///////////////////////////////////////////////////////////
    // Checks if Crowdfund Contract is performing the action //
    ///////////////////////////////////////////////////////////
    modifier onlyCrowdfundContract()
    {
        require (msg.sender == crowdfundContract);
        _;
    }

    ///////////////////////////////////////////////////////////////////////////////////
    // Checks if Crowdfund Contract, Platform, or Allocator is performing the action //
    ///////////////////////////////////////////////////////////////////////////////////
    modifier onlyAllocatorOrCrowdfundContractOrPlatform()
    {
        require (msg.sender == allocatorAddress || msg.sender == crowdfundContract || msg.sender == platform);
        _;
    }

    ///////////////////////////////////////////////////////////////////////
    //  @des Function to change address that is manage platform holding  //
    //  @param newAddress Address of new issuance contract.              //
    ///////////////////////////////////////////////////////////////////////
    function changePlatform(address newAddress)
        onlyCofounders
    {
        platform = newAddress;
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  @des Function to change address that is allowed to do token issuance. Crowdfund contract can only be set once.   //
    //  @param newAddress Address of new issuance contract.                                                              //
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function changeCrowdfundContract(address newAddress)
        onlyCofounders
        CanSetCrowdfundContract
    {
        crowdfundContract = newAddress;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //  @des Function to change address that is allowed to do token issuance. Allocator can only be set once.  //
    //  @param newAddress Address of new issuance contract.                                                    //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    function changeAllocator(address newAddress)
        onlyCofounders
        CanSetAllocator
    {
        allocatorAddress = newAddress;
    }

    ///////////////////////////////////////////////////////
    //  @des Function to change founder A address.       //
    //  @param newAddress Address of new founder A.      //
    ///////////////////////////////////////////////////////
    function changeCofounderA(address newAddress)
        onlyCofounderA
    {
        cofounderA = newAddress;
    }

    //////////////////////////////////////////////////////
    //  @des Function to change founder B address.      //
    //  @param newAddress Address of new founder B.     //
    //////////////////////////////////////////////////////
    function changeCofounderB(address newAddress)
        onlyCofounderB
    {
        cofounderB = newAddress;
    }


    //////////////////////////////////////////////////////////////
    // Transfers tokens from senders address to another address //
    //////////////////////////////////////////////////////////////
    function transfer(address _to, uint256 _value)
      TokensUnlocked
      returns (bool)
    {
          Transfer(msg.sender, _to, _value);
          return BasicToken.transfer(_to, _value);
    }

    //////////////////////////////////////////////////////////
    // Transfers tokens from one address to another address //
    //////////////////////////////////////////////////////////
    function transferFrom(address _from, address _to, uint256 _value)
      TokensUnlocked
      returns (bool)
    {
          Transfer(_from, _to, _value);
          return StandardToken.transferFrom(_from, _to, _value);
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////
    //  @des Cofounders issue tokens to themsleves if within vesting period. Returns success.    //
    //  @param beneficiary Address of receiver.                                                  //
    //  @param tokenCount Number of tokens to issue.                                             //
    ///////////////////////////////////////////////////////////////////////////////////////////////
    function issueCofoundersTokensIfPossible()
        onlyCofounders
        CofoundersTokensVested
        returns (bool)
    {
        // Compute total amount of vested tokens to issue
        uint256 tokenCount = cofoundersSupply.div(cofoundersSupplyVestingTranches);

        // Make sure that there are cofounder tokens left
        if (tokenCount > cofoundersSupplyRemaining) {
           return false;
        }

        // Decrease cofounders supply
        cofoundersSupplyRemaining = cofoundersSupplyRemaining.sub(tokenCount);

        // Update how many tokens have been distributed to cofounders
        cofoundersSupplyDistributed = cofoundersSupplyDistributed.add(tokenCount);

        // Split tokens between both founders
        balances[cofounderA] = balances[cofounderA].add(tokenCount.div(2));
        balances[cofounderB] = balances[cofounderB].add(tokenCount.div(2));

        // Update that a tranche has been issued
        cofoundersSupplyVestingTranchesIssued += 1;

        return true;
    }


    //////////////////
    // Issue tokens //
    //////////////////
    function issueTokens(address beneficiary, uint256 tokenCount, DNNSupplyAllocations allocationType)
      onlyAllocatorOrCrowdfundContractOrPlatform
      returns (bool)
    {
        // We&#39;ll use the following to determine whether the allocator, platform,
        // or the crowdfunding contract can allocate specified supply
        bool canAllocatorPerform = msg.sender == allocatorAddress && tokensLocked == false;
        bool canCrowdfundContractPerform = msg.sender == crowdfundContract;
        bool canPlatformPerform = msg.sender == platform && tokensLocked == false;

        // Early Backers
        if (canAllocatorPerform && allocationType == DNNSupplyAllocations.EarlyBackerSupplyAllocation && tokenCount <= earlyBackerSupplyRemaining) {
            earlyBackerSupplyRemaining = earlyBackerSupplyRemaining.sub(tokenCount);
        }

        // PRE-TDE
        else if (canCrowdfundContractPerform && msg.sender == crowdfundContract && allocationType == DNNSupplyAllocations.PRETDESupplyAllocation) {

              // Check to see if we have enough tokens to satisfy this purchase
              // using just the pre-tde.
              if (PRETDESupplyRemaining >= tokenCount) {

                    // Decrease pre-tde supply
                    PRETDESupplyRemaining = PRETDESupplyRemaining.sub(tokenCount);
              }

              // Check to see if we can satisfy this using pre-tde and tde supply combined
              else if (PRETDESupplyRemaining+TDESupplyRemaining >= tokenCount) {

                    // Decrease tde supply
                    TDESupplyRemaining = TDESupplyRemaining.sub(tokenCount-PRETDESupplyRemaining);

                    // Decrease pre-tde supply by its&#39; remaining tokens
                    PRETDESupplyRemaining = 0;
              }

              // Otherwise, we can&#39;t satisfy this sale because we don&#39;t have enough tokens.
              else {
                  return false;
              }
        }

        // TDE
        else if (canCrowdfundContractPerform && allocationType == DNNSupplyAllocations.TDESupplyAllocation && tokenCount <= TDESupplyRemaining) {
            TDESupplyRemaining = TDESupplyRemaining.sub(tokenCount);
        }

        // Bounty
        else if (canAllocatorPerform && allocationType == DNNSupplyAllocations.BountySupplyAllocation && tokenCount <= bountySupplyRemaining) {
            bountySupplyRemaining = bountySupplyRemaining.sub(tokenCount);
        }

        // Writer Accounts
        else if (canAllocatorPerform && allocationType == DNNSupplyAllocations.WriterAccountSupplyAllocation && tokenCount <= writerAccountSupplyRemaining) {
            writerAccountSupplyRemaining = writerAccountSupplyRemaining.sub(tokenCount);
        }

        // Advisory
        else if (canAllocatorPerform && allocationType == DNNSupplyAllocations.AdvisorySupplyAllocation && tokenCount <= advisorySupplyRemaining) {
            advisorySupplyRemaining = advisorySupplyRemaining.sub(tokenCount);
        }

        // Platform (Also makes sure that the beneficiary is the platform address specified in this contract)
        else if (canPlatformPerform && allocationType == DNNSupplyAllocations.PlatformSupplyAllocation && tokenCount <= platformSupplyRemaining) {
            platformSupplyRemaining = platformSupplyRemaining.sub(tokenCount);
        }

        else {
            return false;
        }

        // Credit tokens to the address specified
        balances[beneficiary] = balances[beneficiary].add(tokenCount);

        return true;
    }

    /////////////////////////////////////////////////
    // Transfer Unsold tokens from TDE to Platform //
    /////////////////////////////////////////////////
    function sendUnsoldTDETokensToPlatform()
      external
      onlyCrowdfundContract
    {
        // Make sure we have tokens to send from TDE
        if (TDESupplyRemaining > 0) {

            // Add remaining tde tokens to platform remaining tokens
            platformSupplyRemaining = platformSupplyRemaining.add(TDESupplyRemaining);

            // Clear remaining tde token count
            TDESupplyRemaining = 0;
        }
    }

    /////////////////////////////////////////////////////
    // Transfer Unsold tokens from pre-TDE to Platform //
    /////////////////////////////////////////////////////
    function sendUnsoldPRETDETokensToTDE()
      external
      onlyCrowdfundContract
    {
          // Make sure we have tokens to send from pre-TDE
          if (PRETDESupplyRemaining > 0) {

              // Add remaining pre-tde tokens to tde remaining tokens
              TDESupplyRemaining = TDESupplyRemaining.add(PRETDESupplyRemaining);

              // Clear remaining pre-tde token count
              PRETDESupplyRemaining = 0;
        }
    }

    ////////////////////////////////////////////////////////////////
    // @des Allows tokens to be transferrable. Returns lock state //
    ////////////////////////////////////////////////////////////////
    function unlockTokens()
        external
        onlyCrowdfundContract
    {
        // Make sure tokens are currently locked before proceeding to unlock them
        require(tokensLocked == true);

        tokensLocked = false;
    }

    ///////////////////////////////////////////////////////////////////////
    //  @des Contract constructor function sets initial token balances.  //
    ///////////////////////////////////////////////////////////////////////
    function DNNToken(address founderA, address founderB, address platformAddress, uint256 vestingStartDate)
    {
          // Set cofounder addresses
          cofounderA = founderA;
          cofounderB = founderB;

          // Sets platform address
          platform = platformAddress;

          // Set total supply - 1 Billion DNN Tokens = (1,000,000,000 * 10^18) atto-DNN
          // 1 DNN = 10^18 atto-DNN
          totalSupply = uint256(1000000000).mul(uint256(10)**decimals);

          // Set Token Distributions (% of total supply)
          earlyBackerSupply = totalSupply.mul(10).div(100); // 10%
          PRETDESupply = totalSupply.mul(10).div(100); // 10%
          TDESupply = totalSupply.mul(40).div(100); // 40%
          bountySupply = totalSupply.mul(1).div(100); // 1%
          writerAccountSupply = totalSupply.mul(4).div(100); // 4%
          advisorySupply = totalSupply.mul(14).div(100); // 14%
          cofoundersSupply = totalSupply.mul(10).div(100); // 10%
          platformSupply = totalSupply.mul(11).div(100); // 11%

          // Set each remaining token count equal to its&#39; respective supply
          earlyBackerSupplyRemaining = earlyBackerSupply;
          PRETDESupplyRemaining = PRETDESupply;
          TDESupplyRemaining = TDESupply;
          bountySupplyRemaining = bountySupply;
          writerAccountSupplyRemaining = writerAccountSupply;
          advisorySupplyRemaining = advisorySupply;
          cofoundersSupplyRemaining = cofoundersSupply;
          platformSupplyRemaining = platformSupply;

          // Sets cofounder vesting start date (Ensures that it is a date in the future, otherwise it will default to now)
          cofoundersSupplyVestingStartDate = vestingStartDate >= now ? vestingStartDate : now;
    }
}