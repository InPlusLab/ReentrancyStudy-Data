/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

//diversified currency basket generation

contract synthMainInterface{
    function minimumDepositAmount (  ) external view returns ( uint256 );
  function exchangeEtherForSynthsAtRate ( uint256 guaranteedRate ) external payable returns ( uint256 );
  function synthsReceivedForEther ( uint256 amount ) external view returns ( uint256 );
  function synth (  ) external view returns ( address );
  function exchangeSynthsForSynthetix ( uint256 synthAmount ) external returns ( uint256 );
  function nominateNewOwner ( address _owner ) external;
  function setPaused ( bool _paused ) external;
  function initiationTime (  ) external view returns ( uint256 );
  function exchangeEtherForSynths (  ) external payable returns ( uint256 );
  function setSelfDestructBeneficiary ( address _beneficiary ) external;
  function fundsWallet (  ) external view returns ( address );
  function priceStalePeriod (  ) external view returns ( uint256 );
  function setPriceStalePeriod ( uint256 _time ) external;
  function terminateSelfDestruct (  ) external;
  function setSynth ( address _synth ) external;
  function pricesAreStale (  ) external view returns ( bool );
  function updatePrices ( uint256 newEthPrice, uint256 newSynthetixPrice, uint256 timeSent ) external;
  function lastPriceUpdateTime (  ) external view returns ( uint256 );
  function totalSellableDeposits (  ) external view returns ( uint256 );
  function nominatedOwner (  ) external view returns ( address );
  function exchangeSynthsForSynthetixAtRate ( uint256 synthAmount, uint256 guaranteedRate ) external returns ( uint256 );
  function paused (  ) external view returns ( bool );
  function setFundsWallet ( address _fundsWallet ) external;
  function depositStartIndex (  ) external view returns ( uint256 );
  function synthetix (  ) external view returns ( address );
  function acceptOwnership (  ) external;
  function exchangeEtherForSynthetix (  ) external payable returns ( uint256 );
  function setOracle ( address _oracle ) external;
  function exchangeEtherForSynthetixAtRate ( uint256 guaranteedEtherRate, uint256 guaranteedSynthetixRate ) external payable returns ( uint256 );
  function oracle (  ) external view returns ( address );
  function withdrawMyDepositedSynths (  ) external;
  function owner (  ) external view returns ( address );
  function lastPauseTime (  ) external view returns ( uint256 );
  function selfDestruct (  ) external;
  function synthetixReceivedForSynths ( uint256 amount ) external view returns ( uint256 );
  function SELFDESTRUCT_DELAY (  ) external view returns ( uint256 );
  function setMinimumDepositAmount ( uint256 _amount ) external;
  function feePool (  ) external view returns ( address );
  function deposits ( uint256 ) external view returns ( address user, uint256 amount );
  function selfDestructInitiated (  ) external view returns ( bool );
  function usdToEthPrice (  ) external view returns ( uint256 );
  function initiateSelfDestruct (  ) external;
  function tokenFallback ( address from, uint256 amount, bytes data ) external returns ( bool );
  function selfDestructBeneficiary (  ) external view returns ( address );
  function smallDeposits ( address ) external view returns ( uint256 );
  function synthetixReceivedForEther ( uint256 amount ) external view returns ( uint256 );
  function depositSynths ( uint256 amount ) external;
  function withdrawSynthetix ( uint256 amount ) external;
  function usdToSnxPrice (  ) external view returns ( uint256 );
  function ORACLE_FUTURE_LIMIT (  ) external view returns ( uint256 );
  function depositEndIndex (  ) external view returns ( uint256 );
  function setSynthetix ( address _synthetix ) external;
}

contract synthConvertInterface{
    function name (  ) external view returns ( string );
  function setGasPriceLimit ( uint256 _gasPriceLimit ) external;
  function approve ( address spender, uint256 value ) external returns ( bool );
  function removeSynth ( bytes32 currencyKey ) external;
  function issueSynths ( bytes32 currencyKey, uint256 amount ) external;
  function mint (  ) external returns ( bool );
  function setIntegrationProxy ( address _integrationProxy ) external;
  function nominateNewOwner ( address _owner ) external;
  function initiationTime (  ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function setFeePool ( address _feePool ) external;
  function exchange ( bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey, address destinationAddress ) external returns ( bool );
  function setSelfDestructBeneficiary ( address _beneficiary ) external;
  function transferFrom ( address from, address to, uint256 value ) external returns ( bool );
  function decimals (  ) external view returns ( uint8 );
  function synths ( bytes32 ) external view returns ( address );
  function terminateSelfDestruct (  ) external;
  function rewardsDistribution (  ) external view returns ( address );
  function exchangeRates (  ) external view returns ( address );
  function nominatedOwner (  ) external view returns ( address );
  function setExchangeRates ( address _exchangeRates ) external;
  function effectiveValue ( bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey ) external view returns ( uint256 );
  function transferableSynthetix ( address account ) external view returns ( uint256 );
  function validateGasPrice ( uint256 _givenGasPrice ) external view;
  function balanceOf ( address account ) external view returns ( uint256 );
  function availableCurrencyKeys (  ) external view returns ( bytes32[] );
  function acceptOwnership (  ) external;
  function remainingIssuableSynths ( address issuer, bytes32 currencyKey ) external view returns ( uint256 );
  function availableSynths ( uint256 ) external view returns ( address );
  function totalIssuedSynths ( bytes32 currencyKey ) external view returns ( uint256 );
  function addSynth ( address synth ) external;
  function owner (  ) external view returns ( address );
  function setExchangeEnabled ( bool _exchangeEnabled ) external;
  function symbol (  ) external view returns ( string );
  function gasPriceLimit (  ) external view returns ( uint256 );
  function setProxy ( address _proxy ) external;
  function selfDestruct (  ) external;
  function integrationProxy (  ) external view returns ( address );
  function setTokenState ( address _tokenState ) external;
  function collateralisationRatio ( address issuer ) external view returns ( uint256 );
  function rewardEscrow (  ) external view returns ( address );
  function SELFDESTRUCT_DELAY (  ) external view returns ( uint256 );
  function collateral ( address account ) external view returns ( uint256 );
  function maxIssuableSynths ( address issuer, bytes32 currencyKey ) external view returns ( uint256 );
  function transfer ( address to, uint256 value ) external returns ( bool );
  function synthInitiatedExchange ( address from, bytes32 sourceCurrencyKey, uint256 sourceAmount, bytes32 destinationCurrencyKey, address destinationAddress ) external returns ( bool );
  function transferFrom ( address from, address to, uint256 value, bytes data ) external returns ( bool );
  function feePool (  ) external view returns ( address );
  function selfDestructInitiated (  ) external view returns ( bool );
  function setMessageSender ( address sender ) external;
  function initiateSelfDestruct (  ) external;
  function transfer ( address to, uint256 value, bytes data ) external returns ( bool );
  function supplySchedule (  ) external view returns ( address );
  function selfDestructBeneficiary (  ) external view returns ( address );
  function setProtectionCircuit ( bool _protectionCircuitIsActivated ) external;
  function debtBalanceOf ( address issuer, bytes32 currencyKey ) external view returns ( uint256 );
  function synthetixState (  ) external view returns ( address );
  function availableSynthCount (  ) external view returns ( uint256 );
  function allowance ( address owner, address spender ) external view returns ( uint256 );
  function escrow (  ) external view returns ( address );
  function tokenState (  ) external view returns ( address );
  function burnSynths ( bytes32 currencyKey, uint256 amount ) external;
  function proxy (  ) external view returns ( address );
  function issueMaxSynths ( bytes32 currencyKey ) external;
  function exchangeEnabled (  ) external view returns ( bool );
}





library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

   
    contract Portfolio1 {

       
       synthMainInterface sInt = synthMainInterface(0x172e09691dfbbc035e37c73b62095caa16ee2388);
       synthConvertInterface sInt2 = synthConvertInterface(0x42d03f506c2308ecd06ae81d8fa22352bc7a8f2b);

      
        //sUSD code
        bytes32 sourceKey= 0x7355534400000000000000000000000000000000000000000000000000000000;

        //sJPY code
        bytes32 destKey = 0x734a505900000000000000000000000000000000000000000000000000000000;
    
        uint256 sUSDBack = 0;

        using SafeMath for uint256;
        
       
    

       
        function () payable{

          // buyPackage();
        }
        
        
        function getLastUSDBack() constant returns (uint256){
            return sUSDBack;
        }

       


        function buyPackage() payable returns(bool){

         


            //100 percent for now
            uint256 amountEthUsing = msg.value;
            // = sInt.synthsReceivedForEther(amountEthUsing).mul(100).div(95);
            sUSDBack= sInt.exchangeEtherForSynths.value(amountEthUsing)();
            sInt2.exchange(sourceKey, sUSDBack, destKey ,msg.sender);

            //sInt.transferFrom ( this, msg.sender, sUSDBack); 


         

            return true;

        }
}