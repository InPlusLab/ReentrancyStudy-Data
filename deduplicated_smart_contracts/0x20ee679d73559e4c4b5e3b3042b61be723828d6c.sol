pragma solidity ^0.5.2;

import "./Eraswap.sol";
import "./TimeAlly.sol";


contract NRTManager {

    using SafeMath for uint256;

    uint256 public lastNRTRelease;              // variable to store last release date
    uint256 public monthlyNRTAmount;            // variable to store Monthly NRT amount to be released
    uint256 public annualNRTAmount;             // variable to store Annual NRT amount to be released
    uint256 public monthCount;                  // variable to store the count of months from the intial date
    uint256 public luckPoolBal;                 // Luckpool Balance
    uint256 public burnTokenBal;                // tokens to be burned
    Eraswap token;
    address Owner;
    //Eraswap public eraswapToken;

    // different pool address
    address public newTalentsAndPartnerships = 0xb4024468D052B36b6904a47541dDE69E44594607;
    address public platformMaintenance = 0x922a2d6B0B2A24779B0623452AdB28233B456D9c;
    address public marketingAndRNR = 0xDFBC0aE48f3DAb5b0A1B154849Ee963430AA0c3E;
    address public kmPards = 0x4881964ac9AD9480585425716A8708f0EE66DA88;
    address public contingencyFunds = 0xF4E731a107D7FFb2785f696543dE8BF6EB558167;
    address public researchAndDevelopment = 0xb209B4cec04cE9C0E1Fa741dE0a8566bf70aDbe9;
    address public powerToken = 0xbc24BfAC401860ce536aeF9dE10EF0104b09f657;
    address public timeSwappers = 0x4b65109E11CF0Ff8fA58A7122a5E84e397C6Ceb8;                 // which include powerToken , curators ,timeTraders , daySwappers
    address public timeAlly;   /// @dev address of timeAlly Contract set when called UpdateAddresses function on this contract


    uint256 public newTalentsAndPartnershipsBal; // variable to store last NRT released to the address;
    uint256 public platformMaintenanceBal;       // variable to store last NRT released to the address;
    uint256 public marketingAndRNRBal;           // variable to store last NRT released to the address;
    uint256 public kmPardsBal;                   // variable to store last NRT released to the address;
    uint256 public contingencyFundsBal;          // variable to store last NRT released to the address;
    uint256 public researchAndDevelopmentBal;    // variable to store last NRT released to the address;
    uint256 public powerTokenNRT;                  // variable to store last NRT released to the address;
    uint256 public timeAllyNRT;                   // variable to store last NRT released to the address;
    uint256 public timeSwappersNRT;              // variable to store last NRT released to the address;


      // Event to watch NRT distribution
      // @param NRTReleased The amount of NRT released in the month
      event NRTDistributed(uint256 NRTReleased);

      /**
      * Event to watch Transfer of NRT to different Pool
      * @param pool - The pool name
      * @param sendAddress - The address of pool
      * @param value - The value of NRT released
      **/
      event NRTTransfer(string pool, address sendAddress, uint256 value);


      // Event to watch Tokens Burned
      // @param amount The amount burned
      event TokensBurned(uint256 amount);

    /**
      * Event to watch the addition of pool address
      * @param pool - The pool name
      * @param sendAddress - The address of pool
      **/
      event PoolAddressAdded(string pool, address sendAddress);

      // Event to watch LuckPool Updation
      // @param luckPoolBal The current luckPoolBal
      event LuckPoolUpdated(uint256 luckPoolBal);

      // Event to watch BurnTokenBal Updation
      // @param burnTokenBal The current burnTokenBal
      event BurnTokenBalUpdated(uint256 burnTokenBal);




      /**
      * @dev Throws if caller is not timeAlly
      */
      modifier OnlyAllowed() {
        require(msg.sender == timeAlly || msg.sender == timeSwappers,"Only TimeAlly and Timeswapper is authorised");
        _;
      }

          /**
      * @dev Throws if caller is not owner
      */
      modifier OnlyOwner() {
        require(msg.sender == Owner,"Only Owner is authorised");
        _;
      }



      /**
      * @dev Should burn tokens according to the total circulation
      * @return true if success
      */

      function burnTokens() internal returns (bool){
        if(burnTokenBal == 0){
          return true;
        }
        else{
          uint MaxAmount = ((token.totalSupply()).mul(2)).div(100);   // max amount permitted to burn in a month
          if(MaxAmount >= burnTokenBal ){
            token.burn(burnTokenBal);
            burnTokenBal = 0;
          }
          else{
            burnTokenBal = burnTokenBal.sub(MaxAmount);
            token.burn(MaxAmount);
          }
          return true;
        }
      }


      /**
      * @dev To update pool addresses
      * @param  pool - A List of pool addresses
      * Updates if pool address is not already set and if given address is not zero
      * @return true if success
      */

      function UpdateAddresses (address[9] calldata pool) external OnlyOwner  returns(bool){

        if((pool[0] != address(0)) && (newTalentsAndPartnerships == address(0))){
          newTalentsAndPartnerships = pool[0];
          emit PoolAddressAdded( "NewTalentsAndPartnerships", newTalentsAndPartnerships);
        }
        if((pool[1] != address(0)) && (platformMaintenance == address(0))){
          platformMaintenance = pool[1];
          emit PoolAddressAdded( "PlatformMaintenance", platformMaintenance);
        }
        if((pool[2] != address(0)) && (marketingAndRNR == address(0))){
          marketingAndRNR = pool[2];
          emit PoolAddressAdded( "MarketingAndRNR", marketingAndRNR);
        }
        if((pool[3] != address(0)) && (kmPards == address(0))){
          kmPards = pool[3];
          emit PoolAddressAdded( "KmPards", kmPards);
        }
        if((pool[4] != address(0)) && (contingencyFunds == address(0))){
          contingencyFunds = pool[4];
          emit PoolAddressAdded( "ContingencyFunds", contingencyFunds);
        }
        if((pool[5] != address(0)) && (researchAndDevelopment == address(0))){
          researchAndDevelopment = pool[5];
          emit PoolAddressAdded( "ResearchAndDevelopment", researchAndDevelopment);
        }
        if((pool[6] != address(0)) && (powerToken == address(0))){
          powerToken = pool[6];
          emit PoolAddressAdded( "PowerToken", powerToken);
        }
        if((pool[7] != address(0)) && (timeSwappers == address(0))){
          timeSwappers = pool[7];
          emit PoolAddressAdded( "TimeSwapper", timeSwappers);
        }
        if((pool[8] != address(0)) && (timeAlly == address(0))){
          timeAlly = pool[8];
          emit PoolAddressAdded( "TimeAlly", timeAlly);
        }

        return true;
      }


      /**
      * @dev Function to update luckpool balance
      * @param amount Amount to be updated
      */
      function UpdateLuckpool(uint256 amount) external OnlyAllowed returns(bool){
              luckPoolBal = luckPoolBal.add(amount);
        emit LuckPoolUpdated(luckPoolBal);
        return true;
      }

      /**
      * @dev Function to trigger to update  for burning of tokens
      * @param amount Amount to be updated
      */
      function UpdateBurnBal(uint256 amount) external OnlyAllowed returns(bool){
             burnTokenBal = burnTokenBal.add(amount);
        emit BurnTokenBalUpdated(burnTokenBal);
        return true;
      }

      /**
      * @dev To invoke monthly release
      * @return true if success
      */

      function MonthlyNRTRelease() external returns (bool) {
        require(now.sub(lastNRTRelease)> 2629744,"NRT release happens once every month");
        uint256 NRTBal = monthlyNRTAmount.add(luckPoolBal);        // Total NRT available.

        // Calculating NRT to be released to each of the pools
        newTalentsAndPartnershipsBal = (NRTBal.mul(5)).div(100);
        platformMaintenanceBal = (NRTBal.mul(10)).div(100);
        marketingAndRNRBal = (NRTBal.mul(10)).div(100);
        kmPardsBal = (NRTBal.mul(10)).div(100);
        contingencyFundsBal = (NRTBal.mul(10)).div(100);
        researchAndDevelopmentBal = (NRTBal.mul(5)).div(100);

        powerTokenNRT = (NRTBal.mul(10)).div(100);
        timeAllyNRT = (NRTBal.mul(15)).div(100);
        timeSwappersNRT = (NRTBal.mul(25)).div(100);

        // sending tokens to respective wallets and emitting events
        token.mint(newTalentsAndPartnerships,newTalentsAndPartnershipsBal);
        emit NRTTransfer("newTalentsAndPartnerships", newTalentsAndPartnerships, newTalentsAndPartnershipsBal);

        token.mint(platformMaintenance,platformMaintenanceBal);
        emit NRTTransfer("platformMaintenance", platformMaintenance, platformMaintenanceBal);

        token.mint(marketingAndRNR,marketingAndRNRBal);
        emit NRTTransfer("marketingAndRNR", marketingAndRNR, marketingAndRNRBal);

        token.mint(kmPards,kmPardsBal);
        emit NRTTransfer("kmPards", kmPards, kmPardsBal);

        token.mint(contingencyFunds,contingencyFundsBal);
        emit NRTTransfer("contingencyFunds", contingencyFunds, contingencyFundsBal);

        token.mint(researchAndDevelopment,researchAndDevelopmentBal);
        emit NRTTransfer("researchAndDevelopment", researchAndDevelopment, researchAndDevelopmentBal);

        token.mint(powerToken,powerTokenNRT);
        emit NRTTransfer("powerToken", powerToken, powerTokenNRT);

        token.mint(timeAlly,timeAllyNRT);
        TimeAlly timeAllyContract = TimeAlly(timeAlly);
        timeAllyContract.increaseMonth(timeAllyNRT);
        emit NRTTransfer("stakingContract", timeAlly, timeAllyNRT);

        token.mint(timeSwappers,timeSwappersNRT);
        emit NRTTransfer("timeSwappers", timeSwappers, timeSwappersNRT);

        // Reseting NRT
        emit NRTDistributed(NRTBal);
        luckPoolBal = 0;
        lastNRTRelease = lastNRTRelease.add(2629744); // @dev adding seconds according to 1 Year = 365.242 days
        burnTokens();                                 // burning burnTokenBal
        emit TokensBurned(burnTokenBal);


        if(monthCount == 11){
          monthCount = 0;
          annualNRTAmount = (annualNRTAmount.mul(90)).div(100);
          monthlyNRTAmount = annualNRTAmount.div(12);
        }
        else{
          monthCount = monthCount.add(1);
        }
        return true;
      }


    /**
    * @dev Constructor
    */

    constructor(address eraswaptoken) public{
      token = Eraswap(eraswaptoken);
      lastNRTRelease = now;
      annualNRTAmount = 819000000000000000000000000;
      monthlyNRTAmount = annualNRTAmount.div(uint256(12));
      monthCount = 0;
      Owner = msg.sender;
    }

}
