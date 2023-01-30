pragma solidity ^0.6.12;

import './RigelToken.sol';

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

contract RigelTokensCrowdsale {
    
        using SafeMath for uint256;
        AggregatorV3Interface internal priceFeed;
        
        /**
       * Event for RigelTokens purchase logging
       * @param purchaser who paid for the tokens
       * @param beneficiary who got the tokens
       * @param value weis paid for purchase
       * @param RigelTokenAmount amount of Rigel tokens purchased
       */
        event TokenPurchase(
            address indexed purchaser,
            address indexed beneficiary,
            uint256 value,
            uint256 RigelTokenAmount
        );
    
       bool public isEnded = false;
    
       event Ended(uint256 totalWeiRaisedInCrowdsale,uint256 unsoldTokensTransferredToOwner);
       
       uint256 public currentRigelTokenUSDRate;     //RigelTokens in $USD 
       
       RigelToken public Rigeltoken;

      // ICO Stage
      // ============
      enum CrowdsaleStage { PreICO, ICO ,Ended}
      CrowdsaleStage internal stage;      //0 for PreICO , 1 for ICO Stage & 2 for Ended
      // =============
    
      // Rigel Token Distribution
      // =============================
      uint256 public totalRigelTokensForSale = 4000*(1e18); // 4000 Rigel will be sold during the whole Crowdsale
      // ==============================
      
      // Amount of wei raised in Crowdsale
      // ==================
      uint256 public totalWeiRaisedDuringPreICO;
      uint256 public totalWeiRaisedDuringICO;
      // ===================
    
      // Rigel Token Amount remaining to Purchase
      // ==================
      uint256 public RigelRemainingForSaleInPreICO = 1800*(1e18);
      uint256 public RigelRemainingForSaleInICO = 2200*(1e18);
      // ===================
    
      // Events
      event EthTransferred(string text);
      
      //Modifier
        address payable public owner;    
        modifier onlyOwner() {
            require (msg.sender == owner);
            _;
        }
    
      // Constructor
      // ============
      constructor() public
      {   
          setCurrentUSDRate(7000000000);          //rate = $70
          owner = msg.sender;
          stage = CrowdsaleStage.PreICO; // By default it's PreICO
          priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
          Rigeltoken = new RigelToken(owner); // Rigel Token Deployment
      }
      // =============
    
      // Crowdsale Stage Management
      // =========================================================
    
      // Change Crowdsale Stage. Available Options: PreICO, ICO
      function switchToICOStage() public onlyOwner {
          require(stage == CrowdsaleStage.PreICO);
          stage = CrowdsaleStage.ICO;
          setCurrentUSDRate(9000000000);    //rate = $90
      }
      
      // Get CurrentStage of Crowdsale
      function currentCrowdsaleStage() public view returns(string memory) {
          if(stage == CrowdsaleStage.PreICO){
              return 'PreICO Stage';
          }
          else if(stage == CrowdsaleStage.ICO){
              return 'ICO Stage';
          }
          else{
              return 'Crowdsale Ended';
          }
      }
    
      // Change the current rate
      function setCurrentUSDRate(uint256 _usdRate) private {
          currentRigelTokenUSDRate = _usdRate.div(1e8);   
      }
    
      // ================ Stage Management Over =====================
      
       /**
       * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
       * @param _beneficiary Address performing the RakeFinanceToken purchase
       * @param _weiAmount Value in wei involved in the purchase
       */
      function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
      )
        internal pure
      {
        require(_beneficiary != address(0));
        require(_weiAmount >= 1e17 wei,"Minimum amount to invest: 0.1 ETH");
      }
    
      /**
       * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
       * @param _beneficiary Address performing the RakeFinanceToken purchase
       * @param _tokenAmount Number of Xfarm tokens to be purchased
       */
      function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
      )
        internal
      {
        Rigeltoken.transfer(_beneficiary, _tokenAmount);
      }
    
      /**
       * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
       * @param _beneficiary Address receiving the tokens
       * @param _tokenAmount Number of Xfarm tokens to be purchased
       */
      function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
      )
        internal
      {
        _deliverTokens(_beneficiary, _tokenAmount);
      }
    
      /**
       * @dev Override to extend the way in which ether is converted to tokens.
       * @param _weiAmount Value in wei to be converted into tokens
       * @return Number of tokens that can be purchased with the specified _weiAmount
       */
      function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
      {
        uint256 latestPrice = uint256(getLatestETHPrice());  
        return _weiAmount.mul(latestPrice).div(currentRigelTokenUSDRate.mul(1e8));
      }
      
      
      // RigelTokens Purchase
      // =========================
      fallback() external payable {
          if(isEnded){
              revert(); //Block Incoming ETH Deposits if Crowdsale has ended
          }
          buyRigelTokens(msg.sender);
      }
      
      function buyRigelTokens(address _beneficiary) public payable {
          uint256 weiAmount = msg.value;
          if(isEnded){
            revert();
          }
          _preValidatePurchase(_beneficiary, weiAmount);
          uint256 RigelTokensToBePurchased = _getTokenAmount(weiAmount);
          if ((stage == CrowdsaleStage.PreICO) && (RigelTokensToBePurchased > RigelRemainingForSaleInPreICO)) {
             revert();  //Block Incoming ETH Deposits for PreICO stage if tokens to be purchased, exceeds remaining tokens for sale in Pre ICO
          }
          
          else if ((stage == CrowdsaleStage.ICO) && (RigelTokensToBePurchased > RigelRemainingForSaleInICO)) {
            revert();  //Block Incoming ETH Deposits for ICO stage if tokens to be purchased, exceeds remaining tokens for sale in ICO
          }
          
            _processPurchase(_beneficiary, RigelTokensToBePurchased);
            emit TokenPurchase(
              msg.sender,
              _beneficiary,
              weiAmount,
              RigelTokensToBePurchased
            );
          
          if (stage == CrowdsaleStage.PreICO) {
              totalWeiRaisedDuringPreICO = totalWeiRaisedDuringPreICO.add(weiAmount);
              RigelRemainingForSaleInPreICO= RigelRemainingForSaleInPreICO.sub(RigelTokensToBePurchased);
              if(RigelRemainingForSaleInPreICO == 0){       // Switch to ICO Stage when all tokens allocated for PreICO stage are being sold out
                  switchToICOStage();
              }
          }
          else if (stage == CrowdsaleStage.ICO) {
              totalWeiRaisedDuringICO = totalWeiRaisedDuringICO.add(weiAmount);
              RigelRemainingForSaleInICO= RigelRemainingForSaleInICO.sub(RigelTokensToBePurchased);
              if(RigelRemainingForSaleInICO == 0){       // End Crowdsale when all tokens allocated for For Sale are being sold out
                  endCrowdsale();
              }
          }
      }
      
      // Finish: Finalizing the Crowdsale.
      // ====================================================================
    
      function endCrowdsale() public onlyOwner {
          require(!isEnded && stage == CrowdsaleStage.ICO,"Should be at ICO Stage to Finalize the Crowdsale");   
          uint256 unsoldTokens = RigelRemainingForSaleInPreICO.add(RigelRemainingForSaleInICO);
                                                              
          if (unsoldTokens > 0) {
              Rigeltoken.burn(unsoldTokens);
          }
          RigelRemainingForSaleInPreICO = 0;
          RigelRemainingForSaleInICO = 0;
          stage = CrowdsaleStage.Ended;
          emit Ended(totalWeiRaised(),unsoldTokens);
          isEnded = true;
      }
      // ===============================
        
      function RigelTokenBalance(address tokenHolder) external view returns(uint256 balance){
          return Rigeltoken.balanceOf(tokenHolder);
      }
      
      function totalWeiRaised() public view returns(uint256){
          return totalWeiRaisedDuringPreICO.add(totalWeiRaisedDuringICO);
      }

    /**
     * Returns the latest ETH-USD price
     */
    function getLatestETHPrice() internal view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    
    function getLatestETHUSDPriceRounded() public view returns (uint256) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return uint256(price).div(1e8);
    }
    
      function withdrawFunds(uint256 amountInWEI) public onlyOwner {
        require(amountInWEI <= address(this).balance,"Insufficient Funds");
        owner.transfer(amountInWEI);
        emit EthTransferred("Funds Withdrawn to Owner Account");
      }
      
      function transferRigelOwnership(address _bigBangAddr) public onlyOwner{
          return Rigeltoken.transferOwnership(_bigBangAddr);
      }
    }