/**
 *Submitted for verification at Etherscan.io on 2020-12-07
*/

pragma solidity^0.6.0;

/*
* Equitable Builds Inc presents..
* ====================================*
*        _____ ___ _______ ______     *
*       |  _  |  ||  |  __|   __|     *
*       |     |  |  |  __|   |__      *
*       |__|__|_____|____|_____|      *
*                                     *
*        _____ __________ ______      *
*       |     |   | | | ||   __|      *
*       |  |  |     | | ||__   |      *
*       |_____|_|___|___||_____|      *
*                                     *
*        _____ ____________ ___       *
*       |     |  |  |   | ||  |       *
*       |  |  |  |  |     ||  |       *
*       |_____|_|_|_|_|___||__|       *
*                                     *
* ====================================*
*/

contract AVEC{

    /*=================================

    =            MODIFIERS            =

    =================================*/

    //verify caller address members_ = true

    modifier onlyMembers(address _customerAddress) {

        require(

                // is the customer in the member whitelist?

                members_[_customerAddress] == true

            );

            // execute

        _;

    }

    //verify caller address founderdevelopers_ = true

    modifier onlyFounderDevelopers(address _customerAddress) {

        require(

                // is the customer in the Founder Developer whitelist?

                founderdevelopers_[_customerAddress] == true

            );

            // execute

        _;

    }

    //verify caller address ceva_ = true

    modifier onlyCEVA(address _customerAddress) {

        require(

                // is the customer in the ceva whitelist?

                ceva_[_customerAddress] == true

            );

            // execute

        _;

    }

    //verify caller address ceva_ = true
    
    modifier onlyAdministrator(address _customerAddress){

        require(

            administrators[_customerAddress] == true

            );

        _;

    }

    /*==============================

    =            EVENTS            =

    ==============================*/

    //Emit and Event to the blockcahin for AVECtoONUS
    
    event AVECtoONUS(

        address indexed MemberAddress,

        uint256 tokensConverted

    );

    //Emit and Event to the blockcahin for ONUStoAVEC
    
    event ONUStoAVEC(

        address indexed MemberAddress,

        uint256 tokensConverted

    );

    //Emit and Event to the blockcahin for OnWithdraw
    
    event OnWithdraw(

        address indexed MemberAddress,

        uint256 tokensWithdrawn,

        uint8 envelopeNumber

    );

    //Emit and Event to the blockcahin for Transfer
    // ERC20

    event Transfer(

        address indexed from,

        address indexed to,

        uint256 value

    );

    //Emit and Event to the blockcahin for PropertyTransfer
    
    event PropertyTransfer(

        address indexed from,

        address indexed to,

        uint256 value,

        bytes32 property

    );

    //Emit and Event to the blockcahin for Burn
    
    event Burn(

        address indexed from,

        uint256 tokens,

        uint256 propertyValue

    );

    // ERC20
    //Emit and Event to the blockcahin for Approval
    
    event Approval(

        address indexed _owner,

        address indexed _spender,

        uint256 _value

    );

    //Emit and Event to the blockcahin for PropertyValuation
    
    event PropertyValuation(

        address indexed from,

        bytes32 _propertyUniqueID,

        uint256 propertyValue

    );

    //Emit and Event to the blockcahin for PropertyWhitelisted
    
    event PropertyWhitelisted(

        address indexed from,

        bytes32 _propertyUniqueID,

        bool _trueFalse

    );

    //Emit and Event to the blockcahin for MemberWhitelisted
    
    event MemberWhitelisted(

        address indexed from,

        address indexed to,

        bool _trueFalse

    );

    //Emit and Event to the blockcahin for FounderDeveloperWhitelisted
    
    event FounderDeveloperWhitelisted(

        address indexed from,

        address indexed to,

        bool _trueFalse

    );

    //Emit and Event to the blockcahin for CEVAWhitelisted
    
    event CEVAWhitelisted(

        address indexed from,

        address indexed to,

        bool _trueFalse

    );

    //Emit and Event to the blockcahin for AdminWhitelisted
    
    event AdminWhitelisted(

        address indexed from,

        address indexed to,

        bool _trueFalse

    );

    /*=====================================

    =            CONFIGURABLES            =

    =====================================*/

    string public name = "AlternateVirtualEquityCredits";
    
    string public symbol = "AVEC";

    uint8 public decimals = 18;
    
    //Setting to change for whoaaddress_

    address internal whoaaddress_ = 0x314d0ED76d866826C809fb6a51d63642b2E9eC3e;
    
    //Global porfolio owner address
    
    address internal whoaaddressValue_ = 0x314d0ED76d866826C809fb6a51d63642b2E9eC3e;
    
    //Setting to change for whoamaintenanceaddress_

    address internal whoamaintenanceaddress_ = 0x2722B426B11978c29660e8395a423Ccb93AE0403;
    
    //Setting to change for whoarewardsaddress_

    address internal whoarewardsaddress_ = 0xA9d241b568DF9E8A7Ec9e44737f29a8Ee00bfF53;
    
    //Setting to change for cevaaddress_

    address internal cevaaddress_ = 0xdE281c22976dE2E9b3f4F87bEB60aE9E67DFf5C4;
    
    //Setting to change for credibleyouaddress_

    address internal credibleyouaddress_ = 0xc9c1Ffd6B4014232Ef474Daa4CA1506A6E39Be89;
    
    //Setting to change for techaddress_

    address internal techaddress_ = 0xB6148C62e6A6d48f41241D01e3C4841139144ABa;
    
    //Setting to change for existcryptoaddress_

    address internal existholdingsaddress_ = 0xac1B6580a175C1f2a4e3220A24e6f65fF3AB8A03;
    
    //Setting to change for existcryptoaddress_

    address internal existcryptoaddress_ = 0xb8C098eE976f1162aD277936a5D1BCA7a8Fe61f5;

    // members address whitelist archive

    mapping(address => bool) internal members_;

    // founder developers whitelist address archive

    mapping(address => bool) internal founderdevelopers_;

    // ceva whitelist address archive

    mapping(address => bool) internal ceva_;

    // administrator list (see above on what they can do)

    mapping(address => bool) internal administrators;

    // setting for allowance function determines amount of tokens address can spend from mapped address

    mapping (address => mapping (address => uint256)) private _allowed;

    // array mapping the mint request whitelist to keep track of all mint requests approved or disapproved by ceva
    
    mapping (address => mapping(bytes32 => bool)) internal mintrequestwhitelist_;
    
    // array mapping the burn request whitelist to keep track of all the token burnings made by ceva

    mapping (address => mapping(bytes32 => bool)) internal burnrequestwhitelist_;
    
    // array mapping the property whitelist to keep track of all properties on the platform

    mapping (address => mapping(bytes32 => bool)) internal propertywhitelist_;
    
    // array mapping the property Balance Ledger of a members current properties

    mapping (bytes32 => mapping(address => uint256)) internal propertyBalanceLedger_;
    
    // array mapping the property Last Known Value for members current properties

    mapping (bytes32 => mapping(address => uint256)) internal propertyLastKnownValue_;
    
    // array mapping the property value to keep track current property value 

    mapping (address => mapping(bytes32 => uint256)) internal propertyvalue_;
    
    // array mapping the old property value to keep track of the value previous to the current ceva value adjustment

    mapping (address => mapping(bytes32 => uint256)) internal propertyvalueOld_;
    
    // array mapping the property Price Update Count for a Members current properties

    mapping (address => mapping(bytes32 => uint256)) internal propertyPriceUpdateCountMember_;
    
    // array mapping the property Price Updates of the Asset to keep track of the number of times its been update
    
    mapping(bytes32 => uint256) internal propertyPriceUpdateCountAsset_;
    
    // array mapping the property Global Balance to keep track of all AVEC that is available for conversion into ONUS on a specific property

    mapping(bytes32 => uint256) internal propertyGlobalBalance_;
    
    // array mapping the property Owner to keep track of all related properties

    mapping(bytes32 => address) internal propertyOwner_;
    
    // array mapping the last Minting Price of any given minted property

    mapping(bytes32 => uint256) internal lastMintingPrice_;
    
    // array mapping the transfering Property id of members intended as a setting to move the different kinds of token value

    mapping(address => bytes32) internal transferingPropertyid_;
    
    // array mapping the working Property id's of founder developers and ceva to keep track of currently related working Property id's

    mapping(address => bytes32) internal workingPropertyid_;
    
    // array mapping the working Mint Request id's to keep track of all related working Mint Request id's

    mapping(address => bytes32) internal workingMintRequestid_;
    
    // array mapping the working Burn Request id's to keep track of all related working Burn Request id's

    mapping(address => bytes32) internal workingBurnRequestid_;

   /*================================

    =            DATASETS            =

    ================================*/
    
    //mapping the value of a wallets token balance ledger

    mapping(address => uint256) internal tokenBalanceLedger_ ;
    
    //mapping the amount of deposits a wallet has received for the purpose of 
    //valuating the amount of dividends they are entitled to for their respective envelope hold shareholds

    mapping(address => uint256) internal mintingDepositsOf_;
    
    //mapping to compare against the minting deposits of an address in order to determine amount of 
    //dividends they are enitled to

    mapping(address => uint256) internal amountCirculated_;

    mapping(address => uint256) internal taxesFeeTotalWithdrawn_;

    mapping(address => uint256) internal taxesPreviousWithdrawn_;

    mapping(address => uint256) internal taxesFeeSharehold_;

    mapping(address => uint256) internal insuranceFeeTotalWithdrawn_;

    mapping(address => uint256) internal insurancePreviousWithdrawn_;

    mapping(address => uint256) internal insuranceFeeSharehold_;

    mapping(address => uint256) internal maintenanceFeeTotalWithdrawn_;

    mapping(address => uint256) internal maintenancePreviousWithdrawn_;

    mapping(address => uint256) internal maintenanceFeeSharehold_;

    mapping(address => uint256) internal waECOFeeTotalWithdrawn_;

    mapping(address => uint256) internal waECOPreviousWithdrawn_;

    mapping(address => uint256) internal waECOFeeSharehold_;

    mapping(address => uint256) internal holdoneTotalWithdrawn_;

    mapping(address => uint256) internal holdonePreviousWithdrawn_;

    mapping(address => uint256) internal holdoneSharehold_;

    mapping(address => uint256) internal holdtwoTotalWithdrawn_;

    mapping(address => uint256) internal holdtwoPreviousWithdrawn_;

    mapping(address => uint256) internal holdtwoSharehold_;

    mapping(address => uint256) internal holdthreeTotalWithdrawn_;

    mapping(address => uint256) internal holdthreePreviousWithdrawn_;

    mapping(address => uint256) internal holdthreeSharehold_;

    mapping(address => uint256) internal rewardsTotalWithdrawn_;

    mapping(address => uint256) internal rewardsPreviousWithdrawn_;

    mapping(address => uint256) internal rewardsSharehold_;

    mapping(address => uint256) internal techTotalWithdrawn_;

    mapping(address => uint256) internal techPreviousWithdrawn_;

    mapping(address => uint256) internal techSharehold_;

    mapping(address => uint256) internal existholdingsTotalWithdrawn_;

    mapping(address => uint256) internal existholdingsPreviousWithdrawn_;

    mapping(address => uint256) internal existholdingsSharehold_;

    mapping(address => uint256) internal existcryptoTotalWithdrawn_;

    mapping(address => uint256) internal existcryptoPreviousWithdrawn_;

    mapping(address => uint256) internal existcryptoSharehold_;

    mapping(address => uint256) internal whoaTotalWithdrawn_;

    mapping(address => uint256) internal whoaPreviousWithdrawn_;

    mapping(address => uint256) internal whoaSharehold_;

    mapping(address => uint256) internal credibleyouTotalWithdrawn_;

    mapping(address => uint256) internal credibleyouPreviousWithdrawn_;

    mapping(address => uint256) internal credibleyouSharehold_;
    
    //mapping to keep track of number of whitelisted proofs on different events

    mapping(address => uint256) internal numberofmintingrequestswhitelisted_;

    mapping(address => uint256) internal numberofpropertieswhitelisted_;

    mapping(address => uint256) internal numberofburnrequestswhitelisted_;
    
    //mapping to keep track of transfering from wallet to ensure values arent changed during crucial processes

    mapping(address => uint256) internal transferingFromWallet_;
    
    //mapping to keeep track of the transfer type IE AVEC/ONUS/OMNI = 1/2/3
    
    mapping(address => uint8) internal transferType_;
    
    //property id that represents ONUS tokens property balance ledgers
    
    bytes32 internal onusCode_ = 0x676c6f62616c0000000000000000000000000000000000000000000000000000;
    
    //property id that represents OMNI tokens property balance ledgers
    
    bytes32 internal omniCode_ = 0x4f4d4e4900000000000000000000000000000000000000000000000000000000;
    
    //Total supply variable to keep track of all token minting
    
    uint256 public totalSupply;
    
    //Total Amount of Holds in existence

    uint256 internal feeTotalHolds_;
    
    //The total deposited over time into the global fee ledger

    uint256 internal globalFeeLedger_;
    
    //The total number of holds in each envelope

    uint256 internal taxesfeeTotalHolds_;

    uint256 internal insurancefeeTotalHolds_;

    uint256 internal maintencancefeeTotalHolds_;

    uint256 internal waECOfeeTotalHolds_;

    uint256 internal holdonefeeTotalHolds_;

    uint256 internal holdtwofeeTotalHolds_;

    uint256 internal holdthreefeeTotalHolds_;

    uint256 internal rewardsfeeTotalHolds_;

    uint256 internal techfeeTotalHolds_;

    uint256 internal existholdingsfeeTotalHolds_;

    uint256 internal existcryptofeeTotalHolds_;

    uint256 internal whoafeeTotalHolds_;

    uint256 internal credibleyoufeeTotalHolds_;

    /*=======================================

    =            MEMBER FUNCTIONS            =

    =======================================*/

    /*

    * -- APPLICATION ENTRY POINTS --

    */

    constructor()

        public

    {

    }

    /*

    * -- APPLICATION ENTRY POINTS --

    */

    function adminInitialSet()

        public

    {

        // add the first users
        
        propertyOwner_[0x676c6f62616c0000000000000000000000000000000000000000000000000000] = whoaaddress_;

        //James Admin

        administrators[0xA9873d93db3BCA9F68aDfEAb226Fa9189641069A] 
        = true;

        //Brenden Admin

        administrators[0x27851761A8fBC03f57965b42528B39af07cdC42b] 
        = true;

        members_[0x314d0ED76d866826C809fb6a51d63642b2E9eC3e] 
        = true;

        members_[0x2722B426B11978c29660e8395a423Ccb93AE0403] 
        = true;

        members_[0x27851761A8fBC03f57965b42528B39af07cdC42b] 
        = true;

        members_[0xA9873d93db3BCA9F68aDfEAb226Fa9189641069A] 
        = true;

        members_[0xdE281c22976dE2E9b3f4F87bEB60aE9E67DFf5C4] 
        = true;

        members_[0xc9c1Ffd6B4014232Ef474Daa4CA1506A6E39Be89] 
        = true;

        members_[0xac1B6580a175C1f2a4e3220A24e6f65fF3AB8A03] 
        = true;

        members_[0xB6148C62e6A6d48f41241D01e3C4841139144ABa] 
        = true;

        members_[0xb8C098eE976f1162aD277936a5D1BCA7a8Fe61f5] 
        = true;

        members_[0xA9d241b568DF9E8A7Ec9e44737f29a8Ee00bfF53] 
        = true;

        members_[0x27851761A8fBC03f57965b42528B39af07cdC42b] 
        = true;

        members_[0xa1Ff1474e0a5db4801E426289DB485b456de7882] 
        = true;



    }
    
    /*

    * -- APPLICATION ENTRY POINTS --

    */

    //Function to adjust corporate wallet address only usable by admin
    
    function adminGenesis(address _existcryptoaddress, address _existhooldingsaddress, address _techaddress,

        address _credibleyouaddress, address _cevaaddress, address _whoaddress, address _whoarewardsaddress, address _whoamaintenanceaddress)

        public

        onlyAdministrator(msg.sender)

    {

        require(administrators[msg.sender], "AdminFalse");

        // adds the _whoaddress input as the current whoa address

        whoaaddress_ 
        = _whoaddress;

        // adds the _whoamaintenanceaddress input as the current whoa maintenence address

        whoamaintenanceaddress_ 
        = _whoamaintenanceaddress;

        // adds the _whoarewardsaddress input as the current whoa rewards address

        whoarewardsaddress_ 
        = _whoarewardsaddress;

        // adds the )cevaaddress_ input as the current ceva address

        cevaaddress_ 
        = _cevaaddress;

        // adds the _credibleyouaddress input as the current credible you address

        credibleyouaddress_ 
        = _credibleyouaddress;

        // adds the _techaddress input as the current tech address

        techaddress_ 
        = _techaddress;

        // adds the __existhooldingsaddress input as the current exist holdings address

        existholdingsaddress_ 
        = _existhooldingsaddress;

        // adds the _existcryptoaddress input as the current exist crypto address

        existcryptoaddress_ 
        = _existcryptoaddress;
        
        numberofburnrequestswhitelisted_[msg.sender] 
        = 0;

        numberofpropertieswhitelisted_[msg.sender] 
        = 0;

        numberofmintingrequestswhitelisted_[msg.sender] 
        = 0;

    }

    /**

     * Function for member to purchase a founder developer license.
     * the fucntion checks if the member has have the required amount of tokens
     * as well as checking if both founder developers are in fact founder developers
     * along with ceva as an additional measure of verification.

     */

    function memberBuyFounderDeveloperLicense(address _founderDeveloperOne, address _founderDeveloperTwo, address _ceva)

        public

        onlyMembers(msg.sender)

        returns(bool _success)

    {

        require(founderdevelopers_[_founderDeveloperOne] == true 
        && ceva_[_ceva] == true 
        && founderdevelopers_[_founderDeveloperTwo] == true);

        // setup data

            address _customerAddress 
            = msg.sender;

            uint256 _licenseprice 
            = 1000 * 1e18;

            if(tokenBalanceLedger_[_customerAddress] > _licenseprice){

                propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_ceva] 
                = (_licenseprice / 5) + propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_ceva];

                tokenBalanceLedger_[_ceva] = tokenBalanceLedger_[_ceva] 
                + (_licenseprice / 5);

                propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_founderDeveloperOne] 
                =  (_licenseprice / 5) + propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_founderDeveloperOne];

                tokenBalanceLedger_[_founderDeveloperOne] = tokenBalanceLedger_[_founderDeveloperOne] + (_licenseprice / 5);

                propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_founderDeveloperTwo] 
                =  (_licenseprice / 10) + propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_founderDeveloperTwo];

                tokenBalanceLedger_[_founderDeveloperTwo] = tokenBalanceLedger_[_founderDeveloperTwo] 
                + (_licenseprice / 10);

                propertyBalanceLedger_[transferingPropertyid_[_customerAddress]][_customerAddress] 
                = propertyBalanceLedger_[transferingPropertyid_[_customerAddress]][_customerAddress] - _licenseprice;

                tokenBalanceLedger_[_customerAddress] 
                = tokenBalanceLedger_[_customerAddress] - _licenseprice;

                founderdevelopers_[_customerAddress] 
                = true;

                return true;

            } else {

                return false;

        }

    }

    /**
     * withdraw an envelope hold shareholders specific envelope dividends based on the chosen number
     * 1 = Taxes Envelope
     * 2 = Insurance Envelope
     * 3 = Maintenance Envelope
     * 4 = Wealth Architect Equity Coin Operator Envelope
     * 5 = Hold One Envelope
     * 6 = Hold Two Envelope
     * 7 = Hold Three Envelope
     * 8 = Rewards Envelope(OMNI)
     * 9 = Tech Envelope
     * 10 = Exist Holdings Envelope
     * 11 = Exist Crypto Envelope
     * 12 = WHOA Envelope
     * 13 = Credible You Envelope
     */

    function memberWithdrawDividends(uint8 _envelopeNumber)

        public

        onlyMembers(msg.sender)

    {

        // setup data

        address _customerAddress 
        = msg.sender;

        uint256 _dividends;

        if(_envelopeNumber == 1){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            taxesFeeTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 2){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            insuranceFeeTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 3){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            maintenanceFeeTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 4){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            waECOFeeTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 5){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            holdoneTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 6){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            holdtwoTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 7){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            holdthreeTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 8){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            rewardsTotalWithdrawn_[_customerAddress] 
            +=  _dividends;
            
            propertyBalanceLedger_[0x4f4d4e4900000000000000000000000000000000000000000000000000000000][_customerAddress] 
            +=  _dividends;

            tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress] +_dividends;

        } else if(_envelopeNumber == 9){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            techTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 10){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            existholdingsTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 11){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            existcryptoTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 12){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            whoaTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        } else if(_envelopeNumber == 13){

            _dividends 
            = checkDividendsOf(msg.sender, _envelopeNumber);

            credibleyouTotalWithdrawn_[_customerAddress] 
            +=  _dividends;

        }

        // update dividend tracker
        if(_envelopeNumber != 8){
            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_customerAddress] 
            +=  _dividends;
        }
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress] +_dividends;

        // fire event

        emit OnWithdraw(_customerAddress, _dividends, _envelopeNumber);

    }
    /**

     * Transfer tokens from the caller to a new holder.

     * Remember, there's a 2% fee here as well. members only

     */

    function transfer(address _toAddress, uint256 _amountOfTokens)

        public
        
        returns(bool)

    {
        transferingFromWallet_[msg.sender] = 1;
        
        uint256 _fee = _amountOfTokens / 50;
        
        _amountOfTokens += _fee;
        
        require(_amountOfTokens <= propertyBalanceLedger_[transferingPropertyid_[msg.sender]][msg.sender], "Not Enough Token");
        
        _amountOfTokens -= _fee;
        
        if(transferType_[msg.sender] == 1){
        
            require(members_[_toAddress] == true && members_[msg.sender], "Not a member");
            
        }
        
        updateRollingPropertyValueMember(_toAddress, transferingPropertyid_[msg.sender]);
        
        uint256 _value 
        = _amountOfTokens + _fee;
        
        address _ownerAddress 
        = propertyOwner_[transferingPropertyid_[msg.sender]];

        uint256 _divideby 
        = ((((propertyLastKnownValue_[transferingPropertyid_[msg.sender]][msg.sender] * 1e18) / 100) * 1000000) / propertyBalanceLedger_[transferingPropertyid_[msg.sender]][msg.sender]);

        uint256 _propertyValue 
        = ((propertyvalue_[_ownerAddress][transferingPropertyid_[msg.sender]] * 1e18) / 100) * 1000000;

        uint256 _pCalculate 
        = _propertyValue / _divideby;
            
        propertyBalanceLedger_[transferingPropertyid_[msg.sender]][msg.sender] 
        = _pCalculate - _value;
        
        propertyPriceUpdateCountMember_[msg.sender][transferingPropertyid_[msg.sender]] 
        = propertyPriceUpdateCountAsset_[transferingPropertyid_[msg.sender]];

        propertyLastKnownValue_[transferingPropertyid_[msg.sender]][msg.sender] 
        = propertyvalue_[_ownerAddress][transferingPropertyid_[msg.sender]];

        tokenBalanceLedger_[_toAddress] 
        = tokenBalanceLedger_[_toAddress] + _amountOfTokens;

        tokenBalanceLedger_[msg.sender] 
        -= _value ;

        propertyBalanceLedger_[transferingPropertyid_[msg.sender]][_toAddress] 
        = propertyBalanceLedger_[transferingPropertyid_[msg.sender]][_toAddress] + _amountOfTokens;

        updateEquityRents(_amountOfTokens);
        
        transferingFromWallet_[msg.sender] = 0;
        
        emit Transfer(msg.sender, _toAddress, _value);
        
        return true;
    }

    /**

     * Convert AVEC into ONUS

     */

    function memberConvertAVECtoONUS(uint256 tokens)

        public

    {

        bytes32 _propertyUniqueID 
        = transferingPropertyid_[msg.sender];

        uint256 _propertyBalanceLedger 
        = propertyBalanceLedger_[_propertyUniqueID][msg.sender];

        uint256 _value 
        = tokens;

        updateRollingPropertyValueMember(msg.sender, _propertyUniqueID);

        if(_propertyBalanceLedger >= _value 
        && transferingFromWallet_[msg.sender] == 0){

            // make sure we have the requested tokens
            // setup
            uint256 cValue;
            
            cValue = (propertyvalue_[propertyOwner_[_propertyUniqueID]][_propertyUniqueID] * 1e18) / 100;
            require(members_[msg.sender] == true 
            && tokens > 0, "Member or GlobalBalance");

            transferingFromWallet_[msg.sender] 
            = 1;

            //Exchange tokens

            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][msg.sender] 
            += tokens;
            
            propertyBalanceLedger_[_propertyUniqueID][msg.sender] 
            -= tokens;
            
            propertyGlobalBalance_[_propertyUniqueID] 
            += tokens;
            
            propertyLastKnownValue_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][msg.sender] 
            = propertyvalue_[propertyOwner_[0x676c6f62616c0000000000000000000000000000000000000000000000000000]][_propertyUniqueID];


            transferingFromWallet_[msg.sender] = 0;

            emit AVECtoONUS(msg.sender, _value);

        } else {

            _value 
            = 0;

            emit AVECtoONUS(msg.sender, _value);

        }

    }

    /**

     * Convert ONUS into AVEC

     */

    function memberConvertONUSintoAVEC(uint256 tokens)

        public

        onlyMembers(msg.sender)

    {

        bytes32 _propertyUniqueID 
        = transferingPropertyid_[msg.sender];

        uint256 _propertyBalanceLedger 
        = ((propertyvalue_[propertyOwner_[_propertyUniqueID]][_propertyUniqueID] * 1e18) / 100) - propertyGlobalBalance_[_propertyUniqueID];

        uint256 _value 
        = tokens;

        updateRollingPropertyValueMember(msg.sender, _propertyUniqueID);

        if(_propertyBalanceLedger >= _value 
        && transferingFromWallet_[msg.sender] == 0){

            // make sure we have the requested tokens
            // setup

            require(members_[msg.sender] == true 
            && tokens > 0);

            transferingFromWallet_[msg.sender] 
            = 1;

            //Exchange tokens

            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][msg.sender] 
            -= tokens;
            propertyBalanceLedger_[_propertyUniqueID][msg.sender] 
            += tokens;
            propertyGlobalBalance_[_propertyUniqueID] 
            -= tokens;
            propertyLastKnownValue_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][msg.sender] 
            = propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000];


            transferingFromWallet_[msg.sender] = 0;

            emit ONUStoAVEC(msg.sender, _value);
            

        } else {

            _value = 0;

            emit ONUStoAVEC(msg.sender, _value);

        }

    }

    //make an approved transfer from another wallet the transfer will verify 
    //based on the transfering ID of the from address input by the user
    
    function transferFrom(address from, address to, uint256 tokens)

        public

        onlyMembers(msg.sender)

        returns(bool)

    {

        bytes32 _propertyUniqueID 
        = transferingPropertyid_[from];

        uint256 _propertyBalanceLedger 
        = propertyBalanceLedger_[_propertyUniqueID][from];

        uint256 _value 
        = tokens + (tokens / 50);

        updateRollingPropertyValueMember(from, _propertyUniqueID);

        if(_propertyBalanceLedger >= _value){

            // setup

            address _customerAddress = msg.sender;

            // make sure we have the requested tokens

            require(members_[to] == true 
            && tokens > 0 
            &&from != to 
            && _value <= _allowed[from][msg.sender] 
            && msg.sender != from 
            && transferingFromWallet_[msg.sender] == 0);

            transferingFromWallet_[msg.sender] 
            = 1;

            updateEquityRents(tokens);

            //Exchange tokens

            tokenBalanceLedger_[to] 
            = tokenBalanceLedger_[to] + tokens;

            tokenBalanceLedger_[from] 
            -= tokens + (tokens / 50);

            propertyLastKnownValue_[_propertyUniqueID][msg.sender] 
            = propertyvalue_[propertyOwner_[_propertyUniqueID]][_propertyUniqueID];

            //Reduce Approval Amount

            _allowed[from][msg.sender] 
            -= tokens;

            amountCirculated_[from] 
            += _value;

            transferingFromWallet_[msg.sender] 
            = 0;

            address _ownerAddress 
            = propertyOwner_[_propertyUniqueID];

            address _holderAddress 
            = to;

            uint256 _divideby 
            = ((((propertyLastKnownValue_[_propertyUniqueID][_holderAddress] * 1e18) / 100) * 1000000) / _propertyBalanceLedger);

            uint256 _propertyValue 
            = ((propertyvalue_[_ownerAddress][_propertyUniqueID] * 1e18) / 100) * 1000000;

            uint256 _pCalculate 
            = _propertyValue / _divideby;

            propertyBalanceLedger_[_propertyUniqueID][_holderAddress] 
            = _pCalculate + tokens;

            propertyPriceUpdateCountMember_[_holderAddress][_propertyUniqueID] 
            = propertyPriceUpdateCountAsset_[_propertyUniqueID];

            propertyLastKnownValue_[_propertyUniqueID][_holderAddress] 
            = lastMintingPrice_[_propertyUniqueID];
            
            propertyBalanceLedger_[_propertyUniqueID][to] 
            = propertyBalanceLedger_[_propertyUniqueID][to] + tokens;

            transferingFromWallet_[msg.sender] 
            = 0;

            emit Transfer(_customerAddress, to, _value);

            return true;

        } else {

            return false;

        }

    }

    //approve another wallet to spend an amount of funds distributed based on 
    //the transfering ID you have set at the time they call the transfeFrom 
    //function that will check if you have the available funds in your 
    //currently selected property
    
    function approve(address spender, uint256 value)

        public

        onlyMembers(msg.sender)

        returns (bool) {

        require(spender != address(0));

        _allowed[msg.sender][spender] 
        = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }

    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender)

        public

        onlyMembers(msg.sender)

        view returns (uint remaining) {

        return _allowed[tokenOwner][spender];

    }

     /**

     * fucntion to clear the value of a title using a ceva whitelisted account when redemption clause is called.

     */

    function cevaClearTitle(uint256 _propertyValue, address _clearFrom)

        public

        onlyCEVA(msg.sender)

        returns(bool)

    {

        uint256 _amountOfTokens = ((_propertyValue * 1e18) / 100);
        
        uint256 _difference = _amountOfTokens - propertyBalanceLedger_[workingPropertyid_[msg.sender]][propertyOwner_[workingPropertyid_[msg.sender]]];
        
        if(workingPropertyid_[msg.sender] != 0x676c6f62616c0000000000000000000000000000000000000000000000000000){

            require(burnrequestwhitelist_[_clearFrom][transferingPropertyid_[msg.sender]] == true 
            && propertywhitelist_[propertyOwner_[workingPropertyid_[msg.sender]]][workingPropertyid_[msg.sender]] == true 
            && _difference <= propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][whoaaddress_] 
            && _amountOfTokens >= 0);

            //Burn Tokens

            totalSupply
            -= _amountOfTokens;

            // take tokens out of stockpile

            //Exchange tokens

            propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000] 
            -= (propertyGlobalBalance_[workingPropertyid_[msg.sender]] * 100) / 1e18;

            tokenBalanceLedger_[propertyOwner_[workingPropertyid_[msg.sender]]] 
            -= propertyBalanceLedger_[workingPropertyid_[msg.sender]][propertyOwner_[workingPropertyid_[msg.sender]]];
            
            propertyBalanceLedger_[workingPropertyid_[msg.sender]][propertyOwner_[workingPropertyid_[msg.sender]]]
            = 0;
            
            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][whoaaddress_]
            -= _amountOfTokens - propertyBalanceLedger_[workingPropertyid_[msg.sender]][propertyOwner_[workingPropertyid_[msg.sender]]];

            // returns bool true

            emit Burn(msg.sender, _amountOfTokens, _propertyValue);



            return true;

        } else {

            return false;

        }

    }

    /**

     * Transfer fee sharehold from the caller to a new holder based on envelope number see memberWithdrawDividends() 1-13 envelope names.

     */

    function memberSellFeeSharehold(address _toAddress, uint256 _amount, uint8 _envelopeNumber)

        public

        onlyMembers(msg.sender)

        returns(bool)

    {

        if(_amount > 0 
        && _envelopeNumber == 1){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= taxesFeeSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                taxesPreviousWithdrawn_[_toAddress] 
                += (taxesFeeTotalWithdrawn_[_customerAddress] / taxesFeeSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                taxesFeeSharehold_[_toAddress] 
                += _amount;

                taxesFeeSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 2){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= insuranceFeeSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                insurancePreviousWithdrawn_[_toAddress] 
                += (insuranceFeeTotalWithdrawn_[_customerAddress] / insuranceFeeSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                insuranceFeeSharehold_[_toAddress] 
                += _amount;

                insuranceFeeSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 3){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= maintenanceFeeSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                maintenancePreviousWithdrawn_[_toAddress] 
                += (maintenanceFeeTotalWithdrawn_[_customerAddress] / maintenanceFeeSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                maintenanceFeeSharehold_[_toAddress] 
                += _amount;

                maintenanceFeeSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 4){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= waECOFeeSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                waECOPreviousWithdrawn_[_toAddress] 
                += (waECOFeeTotalWithdrawn_[_customerAddress] / waECOFeeSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                waECOFeeSharehold_[_toAddress] 
                += _amount;

                waECOFeeSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 5){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= holdoneSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                holdonePreviousWithdrawn_[_toAddress] 
                += (holdoneTotalWithdrawn_[_customerAddress] / holdoneSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                holdoneSharehold_[_toAddress] 
                += _amount;

                holdoneSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 6){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= holdtwoSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                holdtwoPreviousWithdrawn_[_toAddress] 
                += (holdtwoTotalWithdrawn_[_customerAddress] / holdtwoSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                holdtwoSharehold_[_toAddress] 
                += _amount;

                holdtwoSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 && _envelopeNumber == 7){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= holdthreeSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                holdthreePreviousWithdrawn_[_toAddress] 
                += (holdthreeTotalWithdrawn_[_customerAddress] / holdthreeSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                holdthreeSharehold_[_toAddress] 
                += _amount;

                holdthreeSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 8){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= rewardsSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                rewardsPreviousWithdrawn_[_toAddress] 
                += (rewardsTotalWithdrawn_[_customerAddress] / rewardsSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                rewardsSharehold_[_toAddress] 
                += _amount;

                rewardsSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 9){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= techSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                techPreviousWithdrawn_[_toAddress] 
                += (techTotalWithdrawn_[_customerAddress] / techSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                techSharehold_[_toAddress] 
                += _amount;

                techSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 10){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress 
            = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= existholdingsSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                existholdingsPreviousWithdrawn_[_toAddress] 
                += (existholdingsTotalWithdrawn_[_customerAddress] / existholdingsSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                existholdingsSharehold_[_toAddress] 
                += _amount;

                existholdingsSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 11){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= existcryptoSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                existcryptoPreviousWithdrawn_[_toAddress] 
                += (existcryptoTotalWithdrawn_[_customerAddress] / existcryptoSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                existcryptoSharehold_[_toAddress] 
                += _amount;

                existcryptoSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 12){

            require(members_[_toAddress] == true);

        // setup

         address _customerAddress = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= whoaSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                whoaPreviousWithdrawn_[_toAddress] 
                += (whoaTotalWithdrawn_[_customerAddress] / whoaSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                whoaSharehold_[_toAddress] 
                += _amount;

                whoaSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else if(_amount > 0 
        && _envelopeNumber == 13){

            require(members_[_toAddress] == true);

        // setup

            address _customerAddress = msg.sender;

        // make sure we have the requested sharehold

            require(_amount <= credibleyouSharehold_[_customerAddress] 
            && _amount >= 0 
            && _toAddress != _customerAddress);

        //Update fee sharehold previous withdrawals   

                credibleyouPreviousWithdrawn_[_toAddress] 
                += (credibleyouTotalWithdrawn_[_customerAddress] / credibleyouSharehold_[_customerAddress]) * _amount;

        //Exchange sharehold

                credibleyouSharehold_[_toAddress] 
                += _amount;

                credibleyouSharehold_[_customerAddress] 
                -= _amount;

                return true;

        } else {

            return false;

        }

    }

    /**

     * Check and address to see if it has CEVA privileges or not

     */

    function checkCEVA(address _identifier)

        public

        view

        returns(bool)

    {

        if(ceva_[_identifier] == true){

            return true;

        } else {

            return false;

        }

    }

    /**

     * Check a property to see its value

     */

    function checkPropertyValue(address _ownerAddress, bytes32 _propertyUniqueID)

        public

        view

        returns(uint256)

    {

        if(propertyvalue_[_ownerAddress][_propertyUniqueID] >= 0){

            return propertyvalue_[_ownerAddress][_propertyUniqueID];

        } else {

            return 0;

        }

    }

    /**

     * Check a property to see its owner

     */

    function checkPropertyOwner(bytes32 _propertyUniqueID)

        public

        view

        returns(address)

    {

        return propertyOwner_[_propertyUniqueID];

    }
    
    /**

     * Check a property to see a related wallets last known value

     */

    function checkPropertyLastKnownValue(bytes32 _propertyUniqueID, address _memberWalletAddress)

        public

        view

        returns(uint256)

    {

        return propertyLastKnownValue_[_propertyUniqueID][_memberWalletAddress];

    }

    /**

     * Check an address for its current transfering propety id

     */

    function checkTransferingPropertyID(address _ownerAddress)

        public

        view

        returns(bytes32)

    {

        if(_ownerAddress == msg.sender){

            return transferingPropertyid_[msg.sender];

        } else {

            return transferingPropertyid_[_ownerAddress];

        }

    }

    /**

     * Check the globalFeeLedger_

     */

    function checkGlobalFeeLedger()

        public

        view

        returns(uint256)

    {

        if(globalFeeLedger_ >= 0){

            return globalFeeLedger_;

        } else {

            return 0;

        }

    }

    /**

     * Check an address to see if it has member privileges

     */

    function checkMember(address _identifier)

        public

        view

        returns(bool)

    {

        if(members_[_identifier] == true){

            return true;

        } else {

            return false;

        }

    }

    /**

     * Check an address to see is its got founder developer privileges

     */

    function checkFounderDeveloper(address _identifier)

        public

        view

        returns(bool)

    {

        if(founderdevelopers_[_identifier] == true){

            return true;

        } else {

            return false;

        }

    }

    /**

     * Check an address to see if it has admin privileges

     */

    function checkAdmin(address _identifier)

        public

        view

        returns(bool)

    {

        if(administrators[_identifier] == true){

            return true;

        } else {

            return false;

        }

    }

    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/

    /**

     * whitelist Admins admin only

     */

    function adminWhitelistAdministrator(address _identifier, bool _status)

        public

        onlyAdministrator(msg.sender)

    {

        require(msg.sender != _identifier);

            administrators[_identifier] 
            = _status;

            emit AdminWhitelisted(msg.sender, _identifier, _status);

    }

    /**

     *entrypoint to whitelist ceva_ admin only

     */

    function adminWhitelistCEVA(address _identifier, bool _status)

        public

        onlyAdministrator(msg.sender)

    {

        require(msg.sender != _identifier, "Invalid address");

            ceva_[_identifier] 
            = _status;

            numberofburnrequestswhitelisted_[msg.sender] 
            = 0;

            numberofpropertieswhitelisted_[msg.sender] 
            = 0;

            numberofmintingrequestswhitelisted_[msg.sender] 
            = 0;

            emit CEVAWhitelisted(msg.sender, _identifier, _status);

    }

    /**

     * Whitelist a Mint Request that has been confirmed on the site.. ceva only

     */

    function cevaWhitelistMintRequest(address _ownerAddress, bool _trueFalse, bytes32 _mintingRequestUniqueid)

        public

        onlyCEVA(msg.sender)

        returns(bool)

    {

        if(_mintingRequestUniqueid == workingPropertyid_[msg.sender]){

            require(msg.sender != _ownerAddress);

            mintrequestwhitelist_[_ownerAddress][_mintingRequestUniqueid] 
            = _trueFalse;

            return true;

        } else {

            return false;

        }

    }

    /**

     * Whitelist a Burn Request that has been confirmed on the site.. ceva only

     */

    function cevaWhitelistBurnRequest(address _ownerAddress, bool _trueFalse, bytes32 _burnrequestUniqueID)

        public

        onlyCEVA(msg.sender)

        returns(bool)

    {

        if(_burnrequestUniqueID == workingBurnRequestid_[msg.sender]){

            require(msg.sender != _ownerAddress);

            burnrequestwhitelist_[_ownerAddress][_burnrequestUniqueID] 
            = _trueFalse;

            return true;

        } else {

            return false;

        }

    }



    /**

     * Whitelist a Property that has been confirmed on the site.. ceva only

     */

    function cevaWhitelistProperty(address _ownerAddress, bool _trueFalse, bytes32 _propertyUniqueID)

        public

        onlyCEVA(msg.sender)

        returns(bool)

    {

        if(_trueFalse = true){

            require(workingPropertyid_[msg.sender] == _propertyUniqueID);

            propertywhitelist_[_ownerAddress][_propertyUniqueID] 
            = _trueFalse;

            propertyOwner_[_propertyUniqueID] 
            = _ownerAddress;

            lastMintingPrice_[_propertyUniqueID] 
            = 0 + ((lastMintingPrice_[_propertyUniqueID] + 1) - 1);
            
            propertyPriceUpdateCountAsset_[_propertyUniqueID] 
            += 0;

            emit PropertyWhitelisted(msg.sender, _propertyUniqueID, _trueFalse);

            return true;

        } else {

            propertywhitelist_[_ownerAddress][_propertyUniqueID] 
            = _trueFalse;

            lastMintingPrice_[_propertyUniqueID] 
            = 0 + ((lastMintingPrice_[_propertyUniqueID] + 1) - 1);

            return false;

        }

    }

    /**

     * Adjust a property value used by ceva for valuation events.. ceva only

     */

    function cevaUpdatePropertyValue(address _ownerAddress, uint256 _propertyValue)

        public

        onlyCEVA(msg.sender)

        returns(uint256, uint8)

    {

        require(propertywhitelist_[_ownerAddress][workingPropertyid_[msg.sender]] = true 
        && _propertyValue >= 0 
        && workingPropertyid_[msg.sender] != 0x676c6f62616c0000000000000000000000000000000000000000000000000000);

            if(_ownerAddress != msg.sender){

                propertyvalueOld_[_ownerAddress][workingPropertyid_[msg.sender]] 
                = propertyvalue_[_ownerAddress][workingPropertyid_[msg.sender]];
                
                if(propertyPriceUpdateCountAsset_[0x676c6f62616c0000000000000000000000000000000000000000000000000000] == 0 && propertyGlobalBalance_[workingPropertyid_[msg.sender]] == 0){
                    
                    propertyvalueOld_[_ownerAddress][workingPropertyid_[msg.sender]] 
                    = _propertyValue;
                    
                    propertyGlobalBalance_[workingPropertyid_[msg.sender]] += 1;
                }
                    
                propertyvalue_[_ownerAddress][workingPropertyid_[msg.sender]] 
                = _propertyValue;
                    
                uint256 _pCalculate 
                = (((propertyvalueOld_[_ownerAddress][workingPropertyid_[msg.sender]] * 1e18) / 100) * 1000000) / propertyGlobalBalance_[workingPropertyid_[msg.sender]];
                    
                uint256 _qCalculate 
                = ((( propertyvalue_[_ownerAddress][workingPropertyid_[msg.sender]] * 1e18) / 100) * 1000000) / _pCalculate;
                
                uint256 _propertyGlobalBalanceOld
                = propertyGlobalBalance_[workingPropertyid_[msg.sender]] ;
                    
                propertyGlobalBalance_[workingPropertyid_[msg.sender]] 
                = _qCalculate;
                    
                uint256 _globalFeeLedgerOld
                = propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000];
                
                propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000] 
                = (propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000] + (propertyGlobalBalance_[workingPropertyid_[msg.sender]] * 100) / 1e18) 
                - (_propertyGlobalBalanceOld * 100) / 1e18;
                
                uint256 _globalFeeLedger
                = (((_globalFeeLedgerOld * 1e18) / 100) * 1000000) / globalFeeLedger_;
                
                globalFeeLedger_
                = (((propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000]  * 1e18) / 100) * 1000000) / _globalFeeLedger;
                    
                lastMintingPrice_[workingPropertyid_[msg.sender]] 
                = _propertyValue;
                
                propertyvalue_[_ownerAddress][workingPropertyid_[msg.sender]] 
                = _propertyValue;
                
                uint256 _pValue 
                = propertyvalue_[_ownerAddress][workingPropertyid_[msg.sender]];
                
                uint256 _pValueOld 
                = propertyvalueOld_[_ownerAddress][workingPropertyid_[msg.sender]];
                
                propertyvalue_[_ownerAddress][workingPropertyid_[msg.sender]] 
                = (_pValue + _propertyValue) - _pValueOld;

                propertyPriceUpdateCountAsset_[workingPropertyid_[msg.sender]] 
                += 1;
                
                propertyPriceUpdateCountAsset_[0x676c6f62616c0000000000000000000000000000000000000000000000000000] 
                += 1;
                
                totalSupply 
                = (totalSupply - ((propertyvalueOld_[_ownerAddress][workingPropertyid_[msg.sender]] * 1e18) / 100)) + ((propertyvalue_[_ownerAddress][workingPropertyid_[msg.sender]] * 1e18) / 100);

                emit PropertyValuation(msg.sender, workingPropertyid_[msg.sender], propertyvalue_[propertyOwner_[workingPropertyid_[msg.sender]]][workingPropertyid_[msg.sender]]);

                return (propertyvalue_[propertyOwner_[workingPropertyid_[msg.sender]]][workingPropertyid_[msg.sender]], 1);

            } else {

                return (propertyvalue_[propertyOwner_[workingPropertyid_[msg.sender]]][workingPropertyid_[msg.sender]], 2);

            }

    }

    //update a members last known property value in order to keep supply current based on previously unknown value adjustments made by ceva
    
    function updateRollingPropertyValueMember(address _holderAddress, bytes32 _propertyUniqueId)

        internal

    {

        address _ownerAddress 
        = propertyOwner_[_propertyUniqueId];

        uint256 _propertyBalanceLedger 
        = propertyBalanceLedger_[_propertyUniqueId][_holderAddress];

        if(propertyPriceUpdateCountAsset_[_propertyUniqueId] > propertyPriceUpdateCountMember_[_holderAddress][_propertyUniqueId] 
        && propertyPriceUpdateCountMember_[_holderAddress][_propertyUniqueId] == 0) {
            
            propertyLastKnownValue_[_propertyUniqueId][_holderAddress] 
            = propertyvalue_[_ownerAddress][_propertyUniqueId];

            propertyPriceUpdateCountMember_[_holderAddress][_propertyUniqueId] 
            = propertyPriceUpdateCountAsset_[_propertyUniqueId];
            
        } else if(propertyPriceUpdateCountAsset_[_propertyUniqueId] > propertyPriceUpdateCountMember_[_holderAddress][_propertyUniqueId]){
            
            uint256 _divideby 
            = ((((propertyLastKnownValue_[_propertyUniqueId][_holderAddress] * 1e18) / 100) * 1000000) / _propertyBalanceLedger);

            uint256 _propertyValue 
            = ((propertyvalue_[_ownerAddress][_propertyUniqueId] * 1e18) / 100) * 1000000;

            uint256 _pCalculate 
            = _propertyValue / _divideby;

            propertyBalanceLedger_[_propertyUniqueId][_holderAddress] 
            = _pCalculate;
            
            tokenBalanceLedger_[_holderAddress] 
            = (tokenBalanceLedger_[_holderAddress] + _pCalculate) - _propertyBalanceLedger;

            propertyPriceUpdateCountMember_[_holderAddress][_propertyUniqueId] 
            = propertyPriceUpdateCountAsset_[_propertyUniqueId];
            
            propertyLastKnownValue_[_propertyUniqueId][_holderAddress] 
            = propertyvalue_[_ownerAddress][_propertyUniqueId];
            
        } else {
            return;
        }

    }

    //manual function to update a property balance ledger for a specific wallet in order to see new balance 
    //before calling other functions that auto update property balance ledgers after ceva value adjustments
    
    function memberUpdateRollingPropertyValue(address _holderAddress, bytes32 _propertyUniqueId)

        public

        onlyMembers(msg.sender)

        returns(uint8)

    {

        address _ownerAddress 
        = propertyOwner_[_propertyUniqueId];

        if(propertyPriceUpdateCountAsset_[_propertyUniqueId] != propertyPriceUpdateCountMember_[_holderAddress][_propertyUniqueId]

        && propertyBalanceLedger_[_propertyUniqueId][_holderAddress] > 0){

            require(propertywhitelist_[_ownerAddress][_propertyUniqueId] = true);

            assert(propertyvalue_[_ownerAddress][_propertyUniqueId] > 0);

            updateRollingPropertyValueMember(_holderAddress,_propertyUniqueId);

            return 1;

        } else {

            return 2;

        }

    }

    /*----------  FOUNDER DEVELOPER ONLY FUNCTIONS  ----------*/

    // Mint an amount of tokens to an address

    // using the minting request unique ID, and property unique ID set by the founder developer

    function founderDeveloperMintAVEC(uint256 _founderDeveloperFee, address _toAddress, address _holdOne, address _holdTwo, address _holdThree,

        uint256 _propertyValue, address _commissionFounderDeveloper)

        public

        onlyFounderDevelopers(msg.sender)

    {
        bytes32 _propertyUniqueID = workingPropertyid_[msg.sender];
        
        bytes32 _mintingRequestUniqueid = workingMintRequestid_[msg.sender];
        
        uint256 _amountOfTokens 
        = (_propertyValue * 1e18) / 100;

        if(_propertyValue == propertyvalue_[propertyOwner_[_propertyUniqueID]][_propertyUniqueID]){

        // data setup
            
            require(members_[_toAddress] == true 
            
            && _founderDeveloperFee >= 20001 
            
            && _founderDeveloperFee <= 100000 
            
            && msg.sender != _toAddress 
            
            && _propertyUniqueID == workingPropertyid_[msg.sender]

            && _mintingRequestUniqueid == workingMintRequestid_[msg.sender]);

            // add tokens to the pool

            updateHoldsandSupply(_amountOfTokens);

            // credit founder developer fee

            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_commissionFounderDeveloper] 
            += (_amountOfTokens * 1000) / _founderDeveloperFee;

            tokenBalanceLedger_[_commissionFounderDeveloper] 
            = tokenBalanceLedger_[_commissionFounderDeveloper] + (_amountOfTokens * 1000) / _founderDeveloperFee;

            //credit Envelope Fee Shareholds

            creditFeeSharehold(_amountOfTokens, _toAddress, _holdOne, _holdTwo, _holdThree);

            // credit tech feeSharehold_    ;

            uint256 _techFee 
            = (_amountOfTokens * 100) / 25000;

            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][techaddress_] 
            += _techFee;

            propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000] 
            += (_amountOfTokens * 100000000000) / 1111234581620;

            tokenBalanceLedger_[techaddress_] 
            = tokenBalanceLedger_[techaddress_] + _techFee;

            uint256 _whoaFees 
            = (_amountOfTokens * 100000000000000) / 2500000000000625;

            uint256 _fee 
            = (_amountOfTokens * (1000 * 100000)) / (_founderDeveloperFee * 100000);

            // add tokens to the _toAddress

            propertyBalanceLedger_[_propertyUniqueID][_toAddress] 
            = propertyBalanceLedger_[_propertyUniqueID][_toAddress] + ((_amountOfTokens - _whoaFees)- _fee);

            tokenBalanceLedger_[_toAddress] 
            = tokenBalanceLedger_[_toAddress] + ((_amountOfTokens - _whoaFees)- _fee);

            mintingDepositsOf_[_toAddress] 
            += ((_amountOfTokens - _whoaFees)- _fee);

            propertyGlobalBalance_[_propertyUniqueID] 
            += _whoaFees + _fee;

            // whoa fee

            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][whoaaddress_] 
            += _whoaFees - _techFee;
            
            tokenBalanceLedger_[whoaaddress_] 
            += _whoaFees - _techFee;

            // fire event

            emit Transfer(msg.sender, _toAddress, _amountOfTokens);

        } else {

            // fire event

            _amountOfTokens 
            = 0;

            emit Transfer(msg.sender, _toAddress, _amountOfTokens);

        }

    }
    
    function globalReplace()
        
        public
        
    {
        if(ceva_[msg.sender] == true && propertywhitelist_[propertyOwner_[workingPropertyid_[msg.sender]]][workingPropertyid_[msg.sender]]){

            uint256 _amountOfTokens = (propertyvalue_[propertyOwner_[workingPropertyid_[msg.sender]]][workingPropertyid_[msg.sender]] * 1e18) / 100;
            
            propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][whoaaddress_] 
            += _amountOfTokens;
            
            propertyGlobalBalance_[workingPropertyid_[msg.sender]] += _amountOfTokens;

            propertyvalue_[whoaaddressValue_][0x676c6f62616c0000000000000000000000000000000000000000000000000000] 
            += (_amountOfTokens * 100) / 1e18;

            tokenBalanceLedger_[whoaaddress_] 
            += _amountOfTokens;

            // fire event

            emit Transfer(msg.sender, whoaaddress_, _amountOfTokens);
        }
    }

    /**

     * choose the property id that you will be working on ceva/Founder Developer

     */

    function propertyId(address _ownerAddress, bytes32 _propertyUniqueId)

        public

        returns(bool)

    {

        if(members_[_ownerAddress] == true){

            workingPropertyid_[msg.sender] 
            = _propertyUniqueId;

            return true;

        } else {

            return false;

        }

    }

    /**

     * Select a specific property unique id to swap its AVEC when calling the transfer function.

     */

    function swapType(bytes32 _propertyUniqueID, uint8 _tokenType)

        public

        returns(bytes32, uint8)

    {

        if(transferingFromWallet_[msg.sender] == 0 && _tokenType <= 3 && _tokenType >= 1){
            
            updateRollingPropertyValueMember(msg.sender, _propertyUniqueID);
            
            transferingPropertyid_[msg.sender] 
            = _propertyUniqueID;
            
            transferType_[msg.sender]
            = _tokenType;

            return (transferingPropertyid_[msg.sender], _tokenType);
        } else {
            return (transferingPropertyid_[msg.sender], _tokenType);
        }



    }

    /**

     * choose the whitelisted minting request you want to work workingMintRequestid_
     * 
     * founder developer only

     */

    function founderDeveloperMintingRequest(address _ownerAddress, bytes32 _mintingRequestUniqueid)

        public

        onlyFounderDevelopers(msg.sender)

        returns(bool)

    {

        require(mintrequestwhitelist_[_ownerAddress][_mintingRequestUniqueid] = true);

            if(members_[_ownerAddress] == true){

                workingMintRequestid_[msg.sender] 
                = _mintingRequestUniqueid;

                return true;

            } else {

                return false;

            }

    }

    /**

     * select the burn request id you would like to use for the clear title function
     * 
     * ceva only

     */

    function cevaBurnRequestId(address _ownerAddress, bytes32 _propertyUniqueID, uint256 _propertyValue)

        public

        onlyCEVA(msg.sender)

        returns(bytes32)

    {

        require(burnrequestwhitelist_[_ownerAddress][_propertyUniqueID] = true);

            if(members_[_ownerAddress] == true){

                workingPropertyid_[msg.sender] = _propertyUniqueID;

                numberofburnrequestswhitelisted_[msg.sender] 
                += 1;

                emit PropertyValuation(msg.sender, _propertyUniqueID, _propertyValue);

                return _propertyUniqueID;

            } else {

                numberofmintingrequestswhitelisted_[msg.sender] 
                -= 1;

                _propertyValue = 0;

                return _propertyUniqueID;

            }

    }

    //Function to Convert Bytes32 codes into a string.
    
    function bytes32ToString(bytes32 _bytes32)

    public

    view

    onlyMembers(msg.sender)

    returns (string memory) {

        uint8 i = 0;

        while(i < 32 && _bytes32[i] != 0) {

            i++;

        }

        bytes memory bytesArray = new bytes(i);

        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {

            bytesArray[i] = _bytes32[i];

        }

        return string(bytesArray);

    }

    //function to convert strings into bytes32 code
    
    function stringToBytes32(string memory source)

    public

    view

    onlyMembers(msg.sender)

    returns (bytes32 result) {

    bytes memory tempEmptyStringTest = bytes(source);

    if (tempEmptyStringTest.length == 0) {

        return 0x0;

    }



    assembly {

        result := mload(add(source, 32))

    }

    }

    /**

     * Whitelist a Founder Developer ceva only

     */

    function cevaWhitelistFounderDeveloper(address _identifier, bool _status)

        public

        onlyCEVA(msg.sender)

    {

            founderdevelopers_[_identifier] = _status;

            numberofburnrequestswhitelisted_[_identifier] = 0;

            numberofpropertieswhitelisted_[_identifier] = 0;

            numberofmintingrequestswhitelisted_[_identifier] = 0;

            emit FounderDeveloperWhitelisted(msg.sender, _identifier, _status);

    }

    //check the property id of an address used on ceva/founder developer
    
    function checkPropertyIDOf(address _user)

        public

        view

        returns(bytes32)

    {

        return workingPropertyid_[_user];

    }
    
    //check the available avec you can acquire on a specific property using onus
    
    function checkAvailableAVEC(bytes32 _propertyUniqueID)

        public

        view

        returns(uint256)

    {

        uint256 _availableAVEC = propertyGlobalBalance_[_propertyUniqueID];
        
        return _availableAVEC;

    }
    
    //check ceva addresses current burn request id
    
    function checkBurnRequestIDOf(address _user)

        public

        view

        returns(bytes32)

    {

        return workingBurnRequestid_[_user];

    }
    
    //check the mint id of a founder developer

    function checkMintIDOf(address _user)

        public

        view

        returns(bytes32)

    {

        return workingMintRequestid_[_user];

    }

    /**

     * whitelist a member founder developer only

     */

    function founderDeveloperWhitelistMember(address _identifier, bool _status)

        public

        onlyFounderDevelopers(msg.sender)

    {

        require(msg.sender != _identifier);

            members_[_identifier] = _status;

            emit MemberWhitelisted(msg.sender, _identifier, _status);

    }

    /*----------  HELPERS AND CALCULATORS  ----------*/

    /**

     * Retrieve the tokens owned by the caller without 18 zeros of decimal.

     */

    function tokensNoDecimals()

        view

        public

        returns(uint256)

    {

        address _customerAddress = msg.sender;

        uint256 _tokens =  (balanceOf(_customerAddress) / 1e18);

        if(_tokens >= 1){

            return _tokens;

        } else {

            return 0;

        }

    }
    
    //retrieve the balance of a specific address this balance is the total
    //combined value of all property balance ledgers onus tokens and omni tokens

    function balanceOf(address _owner)

        view

        public

        returns(uint256)

    {

        return tokenBalanceLedger_[_owner];

    }
    
    //retrieve the balance of a specific address this balance is the total
    //combined value of all property balance ledgers onus tokens and omni tokens

    function checkOnusBalanceOf(address _owner)

        view

        public

        returns(uint256)

    {

        return propertyBalanceLedger_[0x676c6f62616c0000000000000000000000000000000000000000000000000000][_owner];

    }

    //check the property balance of a specific wallet and property pair using wallet address and property unique id
    
    function checkPropertyBalanceOf(address _wallet, bytes32 _propertyUniqueID)

        view

        public

        returns(uint256)

    {

        return propertyBalanceLedger_[_propertyUniqueID][_wallet];

    }
    
    //check the dividends still not withdrawn by a specific wallet using the 
    //wallet address and evelope number of the envelope you are currently auditing

    function checkDividendsOf(address _customerAddress, uint8 _envelopeNumber)

        view

        public

        returns(uint256)

    {

        if(_envelopeNumber == 1){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / taxesfeeTotalHolds_;

            uint256 _taxesSharehold 
            = taxesFeeSharehold_[_customerAddress];

            uint256 _pCalculate 
            = ((_dividendPershare * _taxesSharehold) -

            (taxesFeeTotalWithdrawn_[_customerAddress] + taxesPreviousWithdrawn_[_customerAddress])) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 2){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / insurancefeeTotalHolds_;

            uint256 _insuranceSharehold 
            = insuranceFeeSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_insuranceSharehold + 0)) -

            ((insuranceFeeTotalWithdrawn_[_customerAddress] + 0) + (insurancePreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 3){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / maintencancefeeTotalHolds_;

            uint256 _maintenanceSharehold 
            = maintenanceFeeSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_maintenanceSharehold + 0)) -

            ((maintenanceFeeTotalWithdrawn_[_customerAddress] + 0) + (maintenancePreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 4){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / waECOfeeTotalHolds_;

            uint256 _waECOSharehold 
            = waECOFeeSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_waECOSharehold + 0)) -

            ((waECOFeeTotalWithdrawn_[_customerAddress] + 0) + (waECOPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 5){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / holdonefeeTotalHolds_;

            uint256 _holdOneSharehold 
            = holdoneSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare) * (_holdOneSharehold)) -

            ((holdoneTotalWithdrawn_[_customerAddress]) + (holdonePreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 6){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / holdtwofeeTotalHolds_;

            uint256 _holdtwoSharehold 
            = holdtwoSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_holdtwoSharehold + 0)) -

            ((holdtwoTotalWithdrawn_[_customerAddress] + 0) + (holdtwoPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 7){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / holdthreefeeTotalHolds_;

            uint256 _holdthreeSharehold 
            = holdthreeSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_holdthreeSharehold + 0)) -

            ((holdthreeTotalWithdrawn_[_customerAddress] + 0) + (holdthreePreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 8){

            uint256 _dividendPershare = ((globalFeeLedger_ / 2) / 8) / rewardsfeeTotalHolds_;

            uint256 _rewardsSharehold = rewardsSharehold_[_customerAddress];

            uint256 _pCalculate =  (((_dividendPershare + 0) * (_rewardsSharehold + 0)) -

            ((rewardsTotalWithdrawn_[_customerAddress] + 0) + (rewardsPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 9){

            uint256 _dividendPershare 
            = (((globalFeeLedger_ / 2) / 5) * 2) / techfeeTotalHolds_;

            uint256 _techSharehold 
            = techSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_techSharehold + 0)) -

            ((techTotalWithdrawn_[_customerAddress] + 0) + (techPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 10){

            uint256 _dividendPershare = (((globalFeeLedger_ / 2) / 5) + (globalFeeLedger_ / 40)) / existholdingsfeeTotalHolds_;

            uint256 _existholdingsSharehold = existholdingsSharehold_[_customerAddress];

            uint256 _pCalculate =  (((_dividendPershare + 0) * (_existholdingsSharehold + 0)) -

            ((existholdingsTotalWithdrawn_[_customerAddress] + 0) + (existholdingsPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 11){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / existcryptofeeTotalHolds_;

            uint256 _existcryptoSharehold 
            = existcryptoSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_existcryptoSharehold + 0)) -

            ((existcryptoTotalWithdrawn_[_customerAddress] + 0) + (existcryptoPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 12){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / whoafeeTotalHolds_;

            uint256 _whoaSharehold 
            = whoaSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_whoaSharehold + 0)) -

            ((whoaTotalWithdrawn_[_customerAddress] + 0) + (whoaPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else if(_envelopeNumber == 13){

            uint256 _dividendPershare 
            = ((globalFeeLedger_ / 2) / 8) / credibleyoufeeTotalHolds_;

            uint256 _credibleyouSharehold 
            = credibleyouSharehold_[_customerAddress];

            uint256 _pCalculate 
            = (((_dividendPershare + 0) * (_credibleyouSharehold + 0)) -

            ((credibleyouTotalWithdrawn_[_customerAddress] + 0) + (credibleyouPreviousWithdrawn_[_customerAddress] + 0))) /

            ((mintingDepositsOf_[_customerAddress] + 1) / (amountCirculated_[_customerAddress] + 1));

            return _pCalculate;

        } else {

            return 0;

        }

    }

    /**

     * check the sharehold an address has of a specific hold envelope

     */

    function checkShareHoldOf(address _customerAddress, uint8 _envelopeNumber)

        view

        public

        returns(uint256, uint8)

    {



        if(_envelopeNumber == 1){

            return (taxesFeeSharehold_[_customerAddress], 1);

        } else if(_envelopeNumber == 2){

            return (insuranceFeeSharehold_[_customerAddress], 2);

        } else if(_envelopeNumber == 3){

            return (maintenanceFeeSharehold_[_customerAddress], 3);

        } else if(_envelopeNumber == 4){

            return (waECOFeeSharehold_[_customerAddress], 4);

        } else if(_envelopeNumber == 5){

            return (holdoneSharehold_[_customerAddress], 5);

        } else if(_envelopeNumber == 6){

            return (holdtwoSharehold_[_customerAddress], 6);

        } else if(_envelopeNumber == 7){

            return (holdthreeSharehold_[_customerAddress], 7);

        } else if(_envelopeNumber == 8){

            return (rewardsSharehold_[_customerAddress], 8);

        } else if(_envelopeNumber == 9){

            return (techSharehold_[_customerAddress], 9);

        } else if(_envelopeNumber == 10){

            return (existholdingsSharehold_[_customerAddress], 10);

        } else if(_envelopeNumber == 11){

            return (existcryptoSharehold_[_customerAddress], 11);

        } else if(_envelopeNumber == 12){

            return (whoaSharehold_[_customerAddress], 12);

        } else if(_envelopeNumber == 13){

            return (credibleyouSharehold_[_customerAddress], 13);

        } else {

            return (0, 0);

        }

    }


    /*==========================================

    =            INTERNAL FUNCTIONS            =

    ==========================================*/

    /**

     * Update totals holds of all envelopes and total supply of all enevelopes.

     */

    function updateHoldsandSupply(uint256 _amountOfTokens)

        internal

        returns(bool)

    {

        totalSupply 
        = totalSupply + _amountOfTokens;

        taxesfeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + taxesfeeTotalHolds_;

        insurancefeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + insurancefeeTotalHolds_;

        maintencancefeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + maintencancefeeTotalHolds_;

        waECOfeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + waECOfeeTotalHolds_;

        holdonefeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + holdonefeeTotalHolds_;

        holdtwofeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + holdtwofeeTotalHolds_;

        holdthreefeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + holdthreefeeTotalHolds_;

        rewardsfeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + rewardsfeeTotalHolds_;

        techfeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + techfeeTotalHolds_;

        existholdingsfeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + existholdingsfeeTotalHolds_;

        existcryptofeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + existcryptofeeTotalHolds_;

        whoafeeTotalHolds_ 
        = (_amountOfTokens / 1e18) + whoafeeTotalHolds_;

        credibleyoufeeTotalHolds_
        = (_amountOfTokens / 1e18) + credibleyoufeeTotalHolds_;

        feeTotalHolds_ 
        = ((_amountOfTokens / 1e18)* 13) + feeTotalHolds_;

        return true;

    }

    //adds tokens to the global fee ledger for distribution betweens envelope hold shareholders
    
    function updateEquityRents(uint256 _amountOfTokens)

        internal

        returns(bool)

    {

        if(_amountOfTokens > 0){

            globalFeeLedger_ 
            = globalFeeLedger_ + (_amountOfTokens / 50);

            return true;

        } else {

            _amountOfTokens = 0;

            return false;

        }

    }

    //credits envelope hold shareholds to respective envelope chosen during minting process
    
    function creditFeeSharehold(uint256 _amountOfTokens, address _owner, address _toAddress, address _toAddresstwo, address _toAddressthree)

        internal

        returns(bool)

    {

        taxesFeeSharehold_[_owner] 
        += _amountOfTokens / 1e18;

        insuranceFeeSharehold_[_owner] 
        += _amountOfTokens / 1e18;

        maintenanceFeeSharehold_[whoamaintenanceaddress_] 
        += _amountOfTokens / 1e18;

        waECOFeeSharehold_[_owner] 
        += _amountOfTokens / 1e18;

        holdoneSharehold_[_toAddress] 
        += _amountOfTokens / 1e18;

        holdtwoSharehold_[_toAddresstwo] 
        += _amountOfTokens / 1e18;

        holdthreeSharehold_[_toAddressthree] 
        += _amountOfTokens / 1e18;

        rewardsSharehold_[whoarewardsaddress_] 
        += _amountOfTokens / 1e18;

        techSharehold_[techaddress_] 
        += _amountOfTokens / 1e18;

        existholdingsSharehold_[existholdingsaddress_] 
        += _amountOfTokens / 1e18;

        existcryptoSharehold_[existcryptoaddress_] 
        += _amountOfTokens / 1e18;

        whoaSharehold_[whoaaddress_]
        += _amountOfTokens / 1e18;

        credibleyouSharehold_[credibleyouaddress_] 
        += _amountOfTokens / 1e18;

        return true;

    }
}