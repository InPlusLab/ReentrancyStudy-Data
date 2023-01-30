pragma solidity ^0.4.18;

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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
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

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract GimmerTokenSale is Pausable {
    using SafeMath for uint256;

    /**
    * @dev Supporter structure, which allows us to track
    * how much the user has bought so far, and if he&#39;s flagged as known
    */
    struct Supporter {
        uint256 weiSpent; // the total amount of Wei this address has sent to this contract
        bool hasKYC; // if the user has KYC flagged
    }

    // Variables
    mapping(address => Supporter) public supportersMap; // Mapping with all the campaign supporters
    GimmerToken public token; // ERC20 GMR Token contract address
    address public fundWallet; // Wallet address to forward all Ether to
    address public kycManagerWallet; // Wallet address that manages the approval of KYC
    uint256 public tokensSold; // How many tokens sold have been sold in total
    uint256 public weiRaised; // Total amount of raised money in Wei
    uint256 public maxTxGas; // Maximum transaction gas price allowed for fair-chance transactions
    uint256 public saleWeiLimitWithoutKYC; // The maximum amount of Wei an address can spend here without needing KYC approval during CrowdSale
    bool public finished; // Flag denoting the owner has invoked finishContract()

    uint256 public constant ONE_MILLION = 1000000; // One million for token cap calculation reference
    uint256 public constant PRE_SALE_GMR_TOKEN_CAP = 15 * ONE_MILLION * 1 ether; // Maximum amount that can be sold during the Pre Sale period
    uint256 public constant GMR_TOKEN_SALE_CAP = 100 * ONE_MILLION * 1 ether; // Maximum amount of tokens that can be sold by this contract
    uint256 public constant MIN_ETHER = 0.1 ether; // Minimum ETH Contribution allowed during the crowd sale

    /* Allowed Contribution in Ether */
    uint256 public constant PRE_SALE_30_ETH = 30 ether; // Minimum 30 Ether to get 25% Bonus Tokens
    uint256 public constant PRE_SALE_300_ETH = 300 ether; // Minimum 300 Ether to get 30% Bonus Tokens
    uint256 public constant PRE_SALE_1000_ETH = 1000 ether; // Minimum 3000 Ether to get 40% Bonus Tokens

    /* Bonus Tokens based on the ETH Contributed in single transaction */
    uint256 public constant TOKEN_RATE_BASE_RATE = 2500; // Base Price for reference only
    uint256 public constant TOKEN_RATE_05_PERCENT_BONUS = 2625; // 05% Bonus Tokens During Crowd Sale&#39;s Week 4
    uint256 public constant TOKEN_RATE_10_PERCENT_BONUS = 2750; // 10% Bonus Tokens During Crowd Sale&#39;s Week 3
    uint256 public constant TOKEN_RATE_15_PERCENT_BONUS = 2875; // 15% Bonus Tokens During Crowd Sale&#39;sWeek 2
    uint256 public constant TOKEN_RATE_20_PERCENT_BONUS = 3000; // 20% Bonus Tokens During Crowd Sale&#39;sWeek 1
    uint256 public constant TOKEN_RATE_25_PERCENT_BONUS = 3125; // 25% Bonus Tokens, During PreSale when >= 30 ETH & < 300 ETH
    uint256 public constant TOKEN_RATE_30_PERCENT_BONUS = 3250; // 30% Bonus Tokens, During PreSale when >= 300 ETH & < 3000 ETH
    uint256 public constant TOKEN_RATE_40_PERCENT_BONUS = 3500; // 40% Bonus Tokens, During PreSale when >= 3000 ETH

    /* Timestamps where investments are allowed */
    uint256 public constant PRE_SALE_START_TIME = 1516190400; // PreSale Start Time : UTC: Wednesday, 17 January 2018 12:00:00 
    uint256 public constant PRE_SALE_END_TIME = 1517400000; // PreSale End Time : UTC: Wednesday, 31 January 2018 12:00:00
    uint256 public constant START_WEEK_1 = 1517486400; // CrowdSale Start Week-1 : UTC: Thursday, 1 February 2018 12:00:00
    uint256 public constant START_WEEK_2 = 1518091200; // CrowdSale Start Week-2 : UTC: Thursday, 8 February 2018 12:00:00
    uint256 public constant START_WEEK_3 = 1518696000; // CrowdSale Start Week-3 : UTC: Thursday, 15 February 2018 12:00:00
    uint256 public constant START_WEEK_4 = 1519300800; // CrowdSale Start Week-4 : UTC: Thursday, 22 February 2018 12:00:00
    uint256 public constant SALE_END_TIME = 1519905600; // CrowdSale End Time : UTC: Thursday, 1 March 2018 12:00:00

    /**
    * @dev Modifier to only allow KYCManager Wallet
    * to execute a function
    */
    modifier onlyKycManager() {
        require(msg.sender == kycManagerWallet);
        _;
    }

    /**
    * Event for token purchase logging
    * @param purchaser The wallet address that bought the tokens
    * @param value How many Weis were paid for the purchase
    * @param amount The amount of tokens purchased
    */
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

    /**
     * Event for kyc status change logging
     * @param user User who has had his KYC status changed
     * @param isApproved A boolean representing the KYC approval the user has been changed to
     */
    event KYC(address indexed user, bool isApproved);

    /**
     * Constructor
     * @param _fundWallet Address to forward all received Ethers to
     * @param _kycManagerWallet KYC Manager wallet to approve / disapprove user&#39;s KYC
     * @param _saleWeiLimitWithoutKYC Maximum amount of Wei an address can spend in the contract without KYC during the crowdsale
     * @param _maxTxGas Maximum gas price a transaction can have before being reverted
     */
    function GimmerTokenSale(
        address _fundWallet, 
        address _kycManagerWallet,
        uint256 _saleWeiLimitWithoutKYC, 
        uint256 _maxTxGas
    )
    public 
    {
        require(_fundWallet != address(0));
        require(_kycManagerWallet != address(0));
        require(_saleWeiLimitWithoutKYC > 0);
        require(_maxTxGas > 0);

        fundWallet = _fundWallet;
        kycManagerWallet = _kycManagerWallet;
        saleWeiLimitWithoutKYC = _saleWeiLimitWithoutKYC;
        maxTxGas = _maxTxGas;

        token = new GimmerToken();
    }

    /* fallback function can be used to buy tokens */
    function () public payable {
        buyTokens();
    }

    /* low level token purchase function */
    function buyTokens() public payable whenNotPaused {
        // Do not allow if gasprice is bigger than the maximum
        // This is for fair-chance for all contributors, so no one can
        // set a too-high transaction price and be able to buy earlier
        require(tx.gasprice <= maxTxGas);
        // valid purchase identifies which stage the contract is at (PreState/Token Sale)
        // making sure were inside the contribution period and the user
        // is sending enough Wei for the stage&#39;s rules
        require(validPurchase());

        address sender = msg.sender;
        uint256 weiAmountSent = msg.value;

        // calculate token amount to be created
        uint256 rate = getRate(weiAmountSent);
        uint256 newTokens = weiAmountSent.mul(rate);

        // look if we have not yet reached the cap
        uint256 totalTokensSold = tokensSold.add(newTokens);
        if (isCrowdSaleRunning()) {
            require(totalTokensSold <= GMR_TOKEN_SALE_CAP);
        } else if (isPreSaleRunning()) { 
            require(totalTokensSold <= PRE_SALE_GMR_TOKEN_CAP);
        }

        // update supporter state
        Supporter storage sup = supportersMap[sender];
        uint256 totalWei = sup.weiSpent.add(weiAmountSent);
        sup.weiSpent = totalWei;

        // update contract state
        weiRaised = weiRaised.add(weiAmountSent);
        tokensSold = totalTokensSold;

        // mint the coins
        token.mint(sender, newTokens);
        TokenPurchase(sender, weiAmountSent, newTokens);

        // forward the funds to the wallet
        fundWallet.transfer(msg.value);
    }

    /**
    * @dev Ends the operation of the contract
    */
    function finishContract() public onlyOwner {
        // make sure the contribution period has ended
        require(now > SALE_END_TIME);
        require(!finished);

        finished = true;

        // send the 10% commission to Gimmer&#39;s fund wallet
        uint256 tenPC = tokensSold.div(10);
        token.mint(fundWallet, tenPC);

        // finish the minting of the token, so the system allows transfers
        token.finishMinting();

        // transfer ownership of the token contract to the fund wallet,
        // so it isn&#39;t locked to be a child of the crowd sale contract
        token.transferOwnership(fundWallet);
    }

    function setSaleWeiLimitWithoutKYC(uint256 _newSaleWeiLimitWithoutKYC) public onlyKycManager {
        require(_newSaleWeiLimitWithoutKYC > 0);
        saleWeiLimitWithoutKYC = _newSaleWeiLimitWithoutKYC;
    }

    /**
    * @dev Updates the maximum allowed transaction cost that can be received
    * on the buyTokens() function.
    * @param _newMaxTxGas The new maximum transaction cost
    */
    function updateMaxTxGas(uint256 _newMaxTxGas) public onlyKycManager {
        require(_newMaxTxGas > 0);
        maxTxGas = _newMaxTxGas;
    }

    /**
    * @dev Flag an user as known
    * @param _user The user to flag as known
    */
    function approveUserKYC(address _user) onlyKycManager public {
        require(_user != address(0));

        Supporter storage sup = supportersMap[_user];
        sup.hasKYC = true;
        KYC(_user, true);
    }

    /**
     * @dev Flag an user as unknown/disapproved
     * @param _user The user to flag as unknown / suspecious
     */
    function disapproveUserKYC(address _user) onlyKycManager public {
        require(_user != address(0));
        
        Supporter storage sup = supportersMap[_user];
        sup.hasKYC = false;
        KYC(_user, false);
    }

    /**
    * @dev Changes the KYC manager to a new address
    * @param _newKYCManagerWallet The new address that will be managing KYC approval
    */
    function setKYCManager(address _newKYCManagerWallet) onlyOwner public {
        require(_newKYCManagerWallet != address(0));
        kycManagerWallet = _newKYCManagerWallet;
    }
    
    /**
    * @dev Returns true if any of the token sale stages are currently running
    * @return A boolean representing the state of this contract
    */
    function isTokenSaleRunning() public constant returns (bool) {
        return (isPreSaleRunning() || isCrowdSaleRunning());
    }

    /**
    * @dev Returns true if the presale sale is currently running
    * @return A boolean representing the state of the presale
    */
    function isPreSaleRunning() public constant returns (bool) {
        return (now >= PRE_SALE_START_TIME && now < PRE_SALE_END_TIME);
    }

    /**
    * @dev Returns true if the public sale is currently running
    * @return A boolean representing the state of the crowd sale
    */
    function isCrowdSaleRunning() public constant returns (bool) {
        return (now >= START_WEEK_1 && now <= SALE_END_TIME);
    }

    /**
    * @dev Returns true if the public sale has ended
    * @return A boolean representing if we are past the contribution date for this contract
    */
    function hasEnded() public constant returns (bool) {
        return now > SALE_END_TIME;
    }

    /**
    * @dev Returns true if the pre sale has ended
    * @return A boolean representing if we are past the pre sale contribution dates
    */
    function hasPreSaleEnded() public constant returns (bool) {
        return now > PRE_SALE_END_TIME;
    }

    /**
    * @dev Returns if an user has KYC approval or not
    * @return A boolean representing the user&#39;s KYC status
    */
    function userHasKYC(address _user) public constant returns (bool) {
        return supportersMap[_user].hasKYC;
    }

    /**
     * @dev Returns the weiSpent of a user
     */
    function userWeiSpent(address _user) public constant returns (uint256) {
        return supportersMap[_user].weiSpent;
    }

    /**
     * @dev Returns the rate the user will be paying at,
     * based on the amount of Wei sent to the contract, and the current time
     * @return An uint256 representing the rate the user will pay for the GMR tokens
     */
    function getRate(uint256 _weiAmount) internal constant returns (uint256) {   
        if (isCrowdSaleRunning()) {
            if (now >= START_WEEK_4) { return TOKEN_RATE_05_PERCENT_BONUS; }
            else if (now >= START_WEEK_3) { return TOKEN_RATE_10_PERCENT_BONUS; }
            else if (now >= START_WEEK_2) { return TOKEN_RATE_15_PERCENT_BONUS; }
            else if (now >= START_WEEK_1) { return TOKEN_RATE_20_PERCENT_BONUS; }
        }
        else if (isPreSaleRunning()) {
            if (_weiAmount >= PRE_SALE_1000_ETH) { return TOKEN_RATE_40_PERCENT_BONUS; }
            else if (_weiAmount >= PRE_SALE_300_ETH) { return TOKEN_RATE_30_PERCENT_BONUS; }
            else if (_weiAmount >= PRE_SALE_30_ETH) { return TOKEN_RATE_25_PERCENT_BONUS; }
        }
    }

    /* @return true if the transaction can buy tokens, otherwise false */
    function validPurchase() internal constant returns (bool) {
        bool userHasKyc = userHasKYC(msg.sender);

        if (isCrowdSaleRunning()) {
            // crowdsale restrictions (KYC only needed after wei limit, minimum of 0.1 ETH tx)
            if(!userHasKyc) {
                Supporter storage sup = supportersMap[msg.sender];
                uint256 ethContribution = sup.weiSpent.add(msg.value);
                if (ethContribution > saleWeiLimitWithoutKYC) {
                    return false;
                }
            }
            return msg.value >= MIN_ETHER;
        }
        else if (isPreSaleRunning()) {
            // presale restrictions (at least 30 eth, always KYC)
            return userHasKyc && msg.value >= PRE_SALE_30_ETH;
        } else {
            return false;
        }
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract GimmerToken is MintableToken  {
    // Constants
    string public constant name = "GimmerToken";
    string public constant symbol = "GMR";  
    uint8 public constant decimals = 18;

    /**
    * @dev Modifier to only allow transfers after the minting has been done
    */
    modifier onlyWhenTransferEnabled() {
        require(mintingFinished);
        _;
    }

    modifier validDestination(address _to) {
        require(_to != address(0x0));
        require(_to != address(this));
        _;
    }

    function GimmerToken() public {
    }

    function transferFrom(address _from, address _to, uint256 _value) public        
        onlyWhenTransferEnabled
        validDestination(_to)         
        returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public
        onlyWhenTransferEnabled         
        returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval (address _spender, uint _addedValue) public
        onlyWhenTransferEnabled         
        returns (bool) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public
        onlyWhenTransferEnabled         
        returns (bool) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function transfer(address _to, uint256 _value) public
        onlyWhenTransferEnabled
        validDestination(_to)         
        returns (bool) {
        return super.transfer(_to, _value);
    }
}