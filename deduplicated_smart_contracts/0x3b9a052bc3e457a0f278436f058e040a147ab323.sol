/**
 *Submitted for verification at Etherscan.io on 2019-10-09
*/

pragma solidity >= 0.5.12;

interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/**
 * @title  ChainValidator interface
 * @author Jakub Fornadel
 * @notice External chain validator contract, can be used for more sophisticated validation of new validators and transactors, e.g. custom min. required conditions,
 *         concrete users whitelisting, etc...
 **/
interface ChainValidator {
    /**
     * @notice Validation function for new validators
     * 
     * @param vesting               How many tokens new validator wants to vest
     * @param acc                   Account address of the validator
     * @param mining                Flag if validator is going to mine. 
     *                               mining == false in case validateNewValidator is called during vestInChain method
     *                               mining == true in case validateNewValidator is called during startMining method
     * @param actNumOfValidators    How many active validators is currently in chain
     **/
    function validateNewValidator(uint256 vesting, address acc, bool mining, uint256 actNumOfValidators) external returns (bool);
    
    /**
     * @notice Validation function for new transactors
     * 
     * @param deposit               How many tokens new transactor wants to deposit
     * @param acc                   Account address of the transactor
     * @param actNumOfTransactors   How many whitelisted transactors (their deposit balance >= min. required balance) is currently in chain
     **/
    function validateNewTransactor(uint256 deposit, address acc, uint256 actNumOfTransactors) external returns (bool);
}

/**
 * @title   Lition Registry Contract
 * @author  Jakub Fornadel
 * @notice  This contract is used for anchoring statistics (users gas consumption, validators stats - blocks mined, etc...) from Lition blockchain network into the ethereum, 
 *          base on which users consumption and validators rewards in LIT (ERC20) tokens are calculated and distributed
 **/
contract LitionRegistry {
    using SafeMath for uint256;
    
    /**************************************************************************************************************************/
    /************************************************** Constants *************************************************************/
    /**************************************************************************************************************************/
    
    // Token precision. 1 LIT token = 1*10^18
    uint256 constant LIT_PRECISION               = 10**18;
    
    // Largest tx fee fixed at 0.1 LIT
    uint256 constant LARGEST_TX_FEE              = LIT_PRECISION/10;
    
    // Min notary period = 1440 blocks (2 hours)
    uint256 constant MIN_NOTARY_PERIOD           = 1440;    // testnet 60 
    
    // Max notary period = 34560 blocks (48 hours)
    uint256 constant MAX_NOTARY_PERIOD           = 34560;
    
    // Time after which chain becomes inactive in case there was no successfull notary processed
    // Users can then increase/descrease their vesting/deposit instantly and bypass 2-step process with confirmations.
    uint256 constant CHAIN_INACTIVITY_TIMEOUT    = 7 days;  // testnet 1 days 
    
    // Time after which validators can withdraw their vesting
    uint256 constant VESTING_LOCKUP_TIMEOUT      = 7 days;  // testnet 1 days
    
    // Max num of characters in chain url
    uint256 constant MAX_URL_LENGTH              = 100;
    
    // Max num of characters in chain description
    uint256 constant MAX_DESCRIPTION_LENGTH      = 200;
    
    // Min. required deposit for all chains
    uint256 constant LITION_MIN_REQUIRED_DEPOSIT = 1000*LIT_PRECISION;
    
    // Min. required vesting for all chains
    uint256 constant LITION_MIN_REQUIRED_VESTING = 1000*LIT_PRECISION;
    
    
    /**************************************************************************************************************************/
    /**************************************************** Events **************************************************************/
    /**************************************************************************************************************************/
    
    // New chain was registered
    event NewChain(uint256 chainId, string description, string endpoint);
    
    // Deposit request created
    // in case confirmed == true, tokens were transferred and account's deposit balance was updated
    // in case confirmed == false, listener needs to wait for another DepositInChain event with confirmed flag == true.
    // It can paired up with the first event if first 4 parameters are the same
    event DepositInChain(uint256 indexed chainId, address indexed account, uint256 deposit, uint256 lastNotaryBlock, bool confirmed);
    
    // Vesting request created
    // in case confirmed == true, tokens were transferred and account's vesting balance was updated
    // in case confirmed == false, listener needs to wait for another VestInChain event with confirmed flag == true.
    // It can paired up with the first event if first 4 parameters are the same
    event VestInChain(uint256 indexed chainId, address indexed account, uint256 vesting, uint256 lastNotaryBlock, bool confirmed);
    
    // if whitelisted == true  - allow user to transact
    // if whitelisted == false - do not allow user to transact
    event AccountWhitelisted(uint256 indexed chainId, address indexed account, bool whitelisted);
    
    // Validator start/stop mining
    event AccountMining(uint256 indexed chainId, address indexed account, bool mining);

    // Validator's new mining reward 
    event MiningReward(uint256 indexed chainId, address indexed account, uint256 reward);
    
    // New notary was processed
    event Notary(uint256 indexed chainId, uint256 lastBlock, uint256 blocksProcessed);

    /**************************************************************************************************************************/
    /***************************************** Structs related to the list of users *******************************************/
    /**************************************************************************************************************************/
    
    // Iterable map that is used only together with the Users mapping as data holder
    struct IterableMap {
        // map of indexes to the list array
        // indexes are shifted +1 compared to the real indexes of this list, because 0 means non-existing element
        mapping(address => uint256) listIndex;
        // list of addresses 
        address[]                   list;        
    }
    
    struct VestingRequest {
        // Flag if there is ongoing request for user
        bool                    exist;
        // Last notary block number when the request was accepted 
        uint256                 notaryBlock;
        // New value of vesting to be set
        uint256                 newVesting;
    }
    
    struct Validator {
        // Flag if validator mined at least 1 block in current notary window
        bool                    currentNotaryMined;
        // Flag if validator mined at least 1 block in the previous notary window
        bool                    prevNotaryMined;
        // Vesting request
        VestingRequest          vestingRequest;
        // Actual user's vesting
        uint256                  vesting;
        // Last time when the user increased his vesting balance. It is used to calculate the time when he can withdraw his vesting 
        uint256                 lastVestingIncreaseTime;
    }
    
    // Only full deposit withdrawals are saved as deposit requests - other types of deposits do not need to be confirmed
    struct DepositWithdrawalRequest {
        // Last notary block number when the request was accepted 
        uint256                  notaryBlock;
        // Flag if there is ongoing request for user
        bool                     exist;
    }
    
    struct Transactor {
        // Actual user's deposit
        uint256                  deposit;
        // DepositWithdrawalRequest request
        DepositWithdrawalRequest depositWithdrawalRequest;
        // Flag if user is whitelisted (allowed to transact) -> actual deposit must be greater than min. required deposit condition 
        bool                     whitelisted;
    }
    
    struct User {
        // Transactor's data
        Transactor   transactor;
        
        // Validator's data
        Validator    validator;
    }

    
    /**************************************************************************************************************************/
    /***************************************************** Other structs ******************************************************/
    /**************************************************************************************************************************/
    
    ERC20 token;
    
    struct LastNotary {
        // Timestamp(eth block time), when last notary was accepted
        uint256 timestamp;
        // Actual Lition block number, when the last notary was accepted
        uint256 block;
    }
    
    struct ChainInfo {
        // Internal chain ID
        uint256                         id;
        
        // Min. required deposit for transactors (more sophisticated conditions might be set in external validator contract)
        // Must be >= MIN_REQUIRED_DEPOSIT (1000 LIT)
        uint256                         minRequiredDeposit;
        
        // Min. required vesting for validators (more sophisticated conditions might be set in external validator contract)
        // Must be >= MIN_REQUIRED_VESTING (1000 LIT)
        uint256                         minRequiredVesting;
        
        // Actual number of whitelisted transactors (their current depost > min.required deposit)
        uint256                         actNumOfTransactors;
        
        // Max number of active validators for chain. There is no limit to how many users can vest.
        // Tthis is limit for active validators (startMining function) 
        // 0  means unlimited
        // It must be some reasonable value together with min. required vesting condition as 
        // too small num of validators limit with too low min. required vesting condition might lead to chain being stuck
        uint256                         maxNumOfValidators;
        
        // Max number of users(transactors) for chain.
        // Tthis is limit for whitelisted transactors (their current depost > min.required deposit)
        // 0  means unlimited
        // It must be some reasonable value together with min. required deposit condition as 
        // too small num of validators limit with too low min. required deposit condition might lead to chain being stuck
        uint256                         maxNumOfTransactors;
        
        // Required vesting balance for reward bonus to be applied  
        // 0 means no bonus is ever appliedm must be >= MIN_REQUIRED_VESTING (1000 LIT)
        uint256                         rewardBonusRequiredVesting;
        
        // Reward bonus percentage, must be > 0%
        uint256                         rewardBonusPercentage;
        
        // How much vesting in total is vested in the chain by the active validators
        uint256                         totalVesting;
        
        // Number of blocks after which notary is called, 1 block is generated every 5 seconds, e.g notaryPeriod = 1440 blocks = 2 hours
        uint256                         notaryPeriod;
        
        // When was the last notary function called (block and time)
        LastNotary                      lastNotary;
        
        // Flag for condition to be checked during notary:
        // InvolvedVesting of validators who signed notary statistics must be greater than 50% of chain total vesting(sum of all active validator's vesting)
        // to notary statistics to be accepted is accepted
        bool                            involvedVestingNotaryCond;
        
        // Flag for condition to be checked during notary:
        // Number of validators who signed notary statistics must be greater or equal than 2/3+1 of all active validators
        // to notary statistics to be accepted is accepted
        bool                            participationNotaryCond;
        
        // Flag that says if the chain was already(& sucessfully) registered
        bool                            registered;
        
        // Flag that says if chain is active - num of active validators > 0 && first block was already mined 
        bool                            active;
        
        // Address of the chain creator
        address                         creator;
        
        // Validator with the smallest vesting balance among all existing validators
        // In case someone vests more tokens, he will replace the one with smallest vesting balance
        address                         lastValidator;
        
        // Smart-contract for validating min.required deposit and vesting
        ChainValidator                  chainValidator;
        
        // Chain description
        string                          description;
        
        // Chain endpoint
        string                          endpoint;
        
        // List of existing users - all users, who have deposited or vested
        IterableMap                     users;
        
        // List of existing validators - only those who vested enough and are actively mining are here
        // Active validator are in separate array because of heavy processing furing notary (no need to filter them out of users thanks tot this)
        IterableMap                     validators;
        
        // Mapping data holder for users (validators & transactors) data
        mapping(address => User)        usersData;
    }
    
    // Registered chains
    mapping(uint256 => ChainInfo)   private chains;
    
    // Next chain id
    uint256                         public  nextId = 0;

    
    /**************************************************************************************************************************/
    /************************************ Contract interface - external/public functions **************************************/
    /**************************************************************************************************************************/
    
    /**
     * @notice Requests vest in chain
     *
     * @param chainId  ChainId that sender wants to interact with
     * 
     * @param vesting  New requested vesting balance. Possible scenarios:
     *                 1. vesting == 0 
     *                      - stopMining must be called first
     *                      - can be called after VESTING_LOCKUP_TIMEOUT (7 days) since the last vesting increase
     *                      - vestingRequest is created
     *                      - if chain.active == true
     *                           * confirmVestInChain can be called in the next notary window to finalize full vesting withdrawal
     *                      - if chain.active == false
     *                           * confirmVestInChain can be called immediately to finalize full vesting withdrawal
     *                 
     *                 2. vesting == actual validators vesting balance
     *                      - not allowed
     * 
     *                 3. vesting > actual validators vesting balance
     *                      - in case all active validators slots are taken, vesting must be > than the lastValidator vesting (last == smallest vesting among all active validators) 
     *                      - vestingRequest is created
     *                      - LIT token transfer is processed
     *                      - if chain.active == true
     *                           * confirmVestInChain can be called in the next notary window to finalize vesting increase
     *                      - if chain.active == false
     *                           * confirmVestInChain can be called immediately to finalize full vesting increase
     *
     *                 4. vesting < actual validators vesting balance
     *                      - can be called after VESTING_LOCKUP_TIMEOUT (7 days) since the last vesting increase
     *                      - processed immediately, no confirmation needed
     *                      - LIT token transfer is processed
     **/
    function requestVestInChain(uint256 chainId, uint256 vesting) external {
        ChainInfo storage chain = chains[chainId];
        Validator storage validator = chain.usersData[msg.sender].validator;
        
        // Enable users to vest into registered (but non-active) chain and start minig so it becomes active
        require(chain.registered == true,                                 "Non-registered chain");
        require(transactorExist(chain, msg.sender) == false,              "Validator cannot be transactor at the same time. Withdraw your depoist or use different account");
        require(vestingRequestExist(chain, msg.sender) == false,          "There is already one vesting request being processed for this acc");
        
        // Checks if chain is active, if not set it active flag to false 
        checkAndSetChainActivity(chain);
        
        // Full vesting withdrawal
        if (vesting == 0) {
            require(validatorExist(chain, msg.sender) == true,            "Non-existing validator account (0 vesting balance)");
            require(activeValidatorExist(chain, msg.sender) == false,     "StopMinig must be called first");
            
            // In case user wants to withdraw full vesting and chain is active, check vesting lockup timeout
            if (chain.active == true) {
                require(validator.lastVestingIncreaseTime + VESTING_LOCKUP_TIMEOUT < now,  "Unable to decrease vesting balance, validators need to wait VESTING_LOCKUP_TIMEOUT(7 days) since the last increase");
            }
        }
        // Vest in chain or withdraw just part of vesting
        else {
            require(validator.vesting != vesting,                         "Cannot vest the same amount of tokens as you already has vested");
            require(vesting >= chain.minRequiredVesting,                  "User does not meet min.required vesting condition");
            
            if (chain.chainValidator != ChainValidator(0)) {
                require(chain.chainValidator.validateNewValidator(vesting, msg.sender, false /* not mining yet */, chain.validators.list.length), "Validator not allowed by external chainvalidator SC");
            }
            
            // In case user wants to decrease vesting and chain is active, check vesting lockup timeout
            if (vesting < validator.vesting) {
                if (chain.active == true) {
                    require(validator.lastVestingIncreaseTime + VESTING_LOCKUP_TIMEOUT < now,  "Unable to decrease vesting balance, validators need to wait VESTING_LOCKUP_TIMEOUT(7 days) since the last increase");
                }
            }
            // In case user wants to increase vesting, do not allow him if there is no more places for active validators and user does not vest more than the the one with smallest vesting balance 
            else if (chain.maxNumOfValidators != 0 && chain.validators.list.length >= chain.maxNumOfValidators) {
           
                require(vesting > chain.usersData[chain.lastValidator].validator.vesting, "Upper limit of validators reached. Must vest more than the last validator to be able to start mining and replace him");
            }
        }
        
        requestVest(chain, vesting, msg.sender);
    }
    
    /**
     * @notice Confirms existing vesting request
     *
     * @param chainId ChainId that sender wants to interact with
     *                
     *                Possible values for existing vestig request:
     *                1. vesting == 0 
     *                      - vestingRequest is deleted
     *                      - LIT token transfer is processed 
     *                      - validator's vesting balance is updated
     *                2. vesting > actual validators vesting balance
     *                      - vestingRequest is deleted
     *                      - validator's vesting balance is updated
     * 
     *                - if chain.active == true
     *                      * confirmVestInChain can be called in the next notary window after the one, in which change was requeted
     *                - if chain.active == false
     *                      * confirmVestInChain can be called immediately
     **/
    function confirmVestInChain(uint256 chainId) external {
        ChainInfo storage chain = chains[chainId];
        
        // Enable users to confirm vesting request into registered (but non-active) chain and start minig so it becomes active
        require(chain.registered == true, "Non-registered chain");
        require(vestingRequestExist(chain, msg.sender) == true, "Non-existing vesting request");
        
        // Checks if chain is active, if not set it active flag to false 
        checkAndSetChainActivity(chain);
        
        // Chain is active
        if (chain.active == true) {
            require(chain.lastNotary.block > chain.usersData[msg.sender].validator.vestingRequest.notaryBlock, "Confirm can be called in the next notary window after request was accepted");    
        }
        
        confirmVest(chain, msg.sender);
    }
    
    /**
     * @notice Requests deposit in chain
     *
     * @param chainId  ChainId that sender wants to interact with
     * 
     * @param deposit  New requested deposit balance. Possible scenarios:
     *                 1. deposit == 0 
     *                      - depositWithdrawalRequest is created
     *                      - validators whitelisted flag is set to false and AccountWhitelisted event is emmited
     *                      - if chain.active == true
     *                           * confirmDepositWithdrawalFromChain can be called in the next notary window to finalize full deposit withdrawal
     *                      - if chain.active == false
     *                           * confirmDepositWithdrawalFromChain can be called immediately to finalize full deposit withdrawal
     *                 
     *                 2. deposit == actual transactors deposit balance
     *                      - not allowed
     * 
     *                 3. deposit > actual validators deposit balance
     *                      - processed immediately, no confirmation needed
     * 
     *                 4. deposit < actual validators deposit balance
     *                      - processed immediately, no confirmation needed
     **/
    function requestDepositInChain(uint256 chainId, uint256 deposit) external {
        ChainInfo storage chain = chains[chainId];
        
        require(chain.registered == true,                                             "Non-registered chain");
        require(validatorExist(chain, msg.sender) == false,                           "Transactor cannot be validator at the same time. Withdraw your vesting or use different account");
        require(depositWithdrawalRequestExist(chain, msg.sender) == false,            "There is already existing withdrawal request being processed for this acc");
        
        // Checks if chain is active, if not set it active flag to false 
        checkAndSetChainActivity(chain);
        
        // Withdraw whole deposit
        if (deposit == 0) {
            require(transactorExist(chain, msg.sender) == true,                       "Non-existing transactor account (0 deposit balance)");
        }
        // Deposit in chain or withdraw just part of deposit
        else {
            require(chain.usersData[msg.sender].transactor.deposit != deposit,        "Cannot deposit the same amount of tokens as you already has deposited");
            require(deposit >= chain.minRequiredDeposit,                              "User does not meet min.required deposit condition");
            
            if (chain.chainValidator != ChainValidator(0)) {
                require(chain.chainValidator.validateNewTransactor(deposit, msg.sender, chain.actNumOfTransactors), "Transactor not allowed by external chainvalidator SC");
            }
            
            // Upper limit of transactors reached
            if (chain.maxNumOfTransactors != 0 && chain.usersData[msg.sender].transactor.whitelisted == false) {
                require(chain.actNumOfTransactors <= chain.maxNumOfTransactors, "Upper limit of transactors reached");
            }
        }
                
        requestDeposit(chain, deposit, msg.sender);
    }
    
    /**
     * @notice Confirms existing full deposit withdrawal request
     *
     * @param chainId ChainId that sender wants to interact with
     *                Possible values for existing full deposit withdrawal request:
     *                1. deposit == 0 
     *                      - depositWithdrawalRequest is deleted
     *                      - LIT token transfer is processed 
     *                      - validator's vesting balance is updated
     * 
     *                - if chain.active == true
     *                      * confirmDepositWithdrawalFromChain can be called in the next notary window after the one, in which change was requeted
     *                - if chain.active == false
     *                      * confirmDepositWithdrawalFromChain can be called immediately
     **/
    function confirmDepositWithdrawalFromChain(uint256 chainId) external {
        ChainInfo storage chain = chains[chainId];

        require(chain.registered == true, "Non-registered chain");
        require(depositWithdrawalRequestExist(chain, msg.sender) == true, "Non-existing deposit withdrawal request");
        
        // Checks if chain is active, if not set it active flag to false 
        checkAndSetChainActivity(chain);
        
        // Chain is active
        if (chain.active == true) {
            require(chain.lastNotary.block > chain.usersData[msg.sender].transactor.depositWithdrawalRequest.notaryBlock, "Confirm can be called in the next notary window after request was accepted");
        }
        
        confirmDepositWithdrawal(chain, msg.sender);
    }
    
    /**
     * @notice Internally creates/registers new chain.
     * 
     * @param description                     Description of the chain (e.g name, short purpose description, etc...). Max 200 characters
     *                                         Cannot be empty. Max num of characters is 200
     * @param initEndpoint                    Chain endpoint, might be a website with chain description, condition to join and nodes ip:port addresses that can be used fo joining
     *                                         Cannot be empty. Max num of characters is 100
     * @param chainValidator                  External validator contract, might imolement more sophisticated rules for joing the chain as validator or as user (e.g. accounts whitelisting, etc...)
     *                                         0 means no external validator contract
     * @param minRequiredDeposit              Min.required deposit to become transactor (user). It must be some reasonable number as user should never be able to run out of tokens during notaryPeriod considering 
     *                                         max. tx fee is fixed to 0.1 LIT tokens E.g. there is private chain with whitelisted users and user creator know they will send max. 100 000 txs / notaryPeriod. 
     *                                         Min. required deposit should be then 10 000 LIT tokens. 
     *                                         It is something like prebought credit for transactions that is required to have on your account before each notary. In fact, users will have to deposit more than minRequiredDeposit as 
     *                                         they will be automatically blacklisted during the notary even if they sent only 1 tx, because their deposit balance would be < minRequiredDeposit before the next notary. 
     *                                         On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     *                                         0 means default (1000 LIT), otherwise must be >= 1000 LIT tokens
     * @param minRequiredVesting              Min.required deposit to become validator.
     *                                         On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     *                                         0 means default (1000 LIT), otherwise must be >= 1000 LIT tokens
     * @param rewardBonusRequiredVesting      Min. required vesting balance for bonus reward to be applied.
     *                                         0 means that chain will not support rewards bonus 
     * @param rewardBonusPercentage           Reward bonus (percentage) to be applied if validator's vesting balance >= rewardBonusRequiredVesting.
     *                                         In case rewardBonusRequiredVesting > 0, rewardBonusPercentage must be > 0%, otherwise it is ignored
     * @param notaryPeriod                    Notary period in blocks (1 block every 5s), it is basically time interval notary periodic calls where users consumptions are processed and rewards distributed. 
     *                                         Must be in range <1440 (2 hours), 34560 (48 hours)>
     * @param maxNumOfValidators              Max. number of active validators (those who vested and started mining). As Lition is using BFT consensus alg., it is recommended to use max no more than 51 validators(21 recommended).
     *                                         On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     *                                         0 means unlimited
     * @param maxNumOfTransactors             Max. number of transactors/users (those who deposited. It is recommended to restrict this number as notary will not be able to process theoretically unlimited number of users
     *                                         On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     *                                         0 means unlimited
     * @param involvedVestingNotaryCond       Flag, if 50% invloved vesting condition should be checked during notary. It means that vesting balances sum of those validators, who signed statistics 
     *                                         sent to the notary must be > 50% of the sum of all active validators vesting balances on chain 
     *                                         At least one of the involvedVestingNotaryCond or participationNotaryCond must be specified
     * @param participationNotaryCond         Flag, 2/3 + 1 participation condition should be checked during notary. It means that more or equal to 2/3+1 of all active validators on chain 
     *                                         must sign statistics sent to the notary for notary to be accepted 
     *                                         At least one of the involvedVestingNotaryCond or participationNotaryCond must be specified
     * 
     * @return chainId of the created chain
     **/ 
    function registerChain(string memory description, string memory initEndpoint, ChainValidator chainValidator, uint256 minRequiredDeposit, uint256 minRequiredVesting, uint256 rewardBonusRequiredVesting, uint256 rewardBonusPercentage, 
                           uint256 notaryPeriod, uint256 maxNumOfValidators, uint256 maxNumOfTransactors, bool involvedVestingNotaryCond, bool participationNotaryCond) public returns (uint256 chainId) {
        require(bytes(description).length > 0 && bytes(description).length <= MAX_DESCRIPTION_LENGTH,   "Chain description length must be: > 0 && <= MAX_DESCRIPTION_LENGTH(200)");
        require(bytes(initEndpoint).length > 0 && bytes(initEndpoint).length <= MAX_URL_LENGTH,         "Chain endpoint length must be: > 0 && <= MAX_URL_LENGTH(100)");
        require(notaryPeriod >= MIN_NOTARY_PERIOD && notaryPeriod <= MAX_NOTARY_PERIOD,                 "Notary period must be in range <MIN_NOTARY_PERIOD(1440), MAX_NOTARY_PERIOD(34560)>");
        require(involvedVestingNotaryCond == true || participationNotaryCond == true,                   "At least one notary condition must be specified");
        
        if (minRequiredDeposit > 0) {
            require(minRequiredDeposit >= LITION_MIN_REQUIRED_DEPOSIT,                                  "Min. required deposit for all chains must be >= LITION_MIN_REQUIRED_DEPOSIT (1000 LIT)");
        }
        
        if (minRequiredVesting > 0) {
            require(minRequiredVesting >= LITION_MIN_REQUIRED_VESTING,                                  "Min. required vesting for all chains must be >= LITION_MIN_REQUIRED_VESTING (1000 LIT)");
        }
        
        if (rewardBonusRequiredVesting > 0) {
            require(rewardBonusPercentage > 0,                                                          "Reward bonus percentage must be > 0%");    
        }
    
        chainId                         = nextId;
        ChainInfo storage chain         = chains[chainId];
        
        chain.id                        = chainId;
        chain.description               = description;
        chain.endpoint                  = initEndpoint;
        chain.minRequiredDeposit        = minRequiredDeposit;
        chain.minRequiredVesting        = minRequiredVesting;
        chain.notaryPeriod              = notaryPeriod;
        chain.registered                = true;
        chain.creator                   = msg.sender;
        
        if (chainValidator != ChainValidator(0)) {
            chain.chainValidator = chainValidator;
        }
        
        // Sets min required deposit
        if (minRequiredDeposit == 0) {
            chain.minRequiredDeposit = LITION_MIN_REQUIRED_DEPOSIT;
        } 
        else {
            chain.minRequiredDeposit = minRequiredDeposit;
        }
        
        // Sets min required vesting
        if (minRequiredVesting == 0) {
            chain.minRequiredVesting = LITION_MIN_REQUIRED_VESTING;
        } 
        else {
            chain.minRequiredVesting = minRequiredVesting;
        }

        
        if (involvedVestingNotaryCond == true) {
            chain.involvedVestingNotaryCond  = true;    
        }
        
        if (participationNotaryCond == true) {
            chain.participationNotaryCond    = true;
        }
        
        if (maxNumOfValidators > 0) {
            chain.maxNumOfValidators         = maxNumOfValidators;
        }
        
        if (maxNumOfTransactors > 0) {
            chain.maxNumOfTransactors        = maxNumOfTransactors;
        }
        
        if (rewardBonusRequiredVesting > 0) {
            chain.rewardBonusRequiredVesting = rewardBonusRequiredVesting;
            chain.rewardBonusPercentage      = rewardBonusPercentage;
        }
        
        emit NewChain(chainId, description, initEndpoint);
        
        nextId++;
    }
    
    /**
     * @notice Sets some of the static chain details. Only chain creator can call this method
     *
     * @param chainId       ChainId that sender wants to interact with
     * @param description   New chain description (e.g name, short purpose description, etc...)
     * @param endpoint      New chain endpoint, might be a website with chain description, condition to join and nodes ip:port addresses that can be used fo joining
     **/
    function setChainStaticDetails(uint256 chainId, string calldata description, string calldata endpoint) external {
        ChainInfo storage chain = chains[chainId];
        require(msg.sender == chain.creator, "Only chain creator can call this method");
    
        require(bytes(description).length <= MAX_DESCRIPTION_LENGTH,   "Chain description length must be: > 0 && <= MAX_DESCRIPTION_LENGTH(200)");
        require(bytes(endpoint).length <= MAX_URL_LENGTH,              "Chain endpoint length must be: > 0 && <= MAX_URL_LENGTH(100)");
        
        if (bytes(description).length > 0) {
            chain.description = description;
        }
        if (bytes(endpoint).length > 0) {
            chain.endpoint = endpoint;
        }
    }
    
    /**
     * @notice Returns chain static details (those that do not change).
     *
     * @param chainId                         ChainId that sender wants to interact with
     * 
     * @return description                   Description of the chain (e.g name, short purpose description, etc...)
     * @return endpoint                      Chain endpoint, might be a website with chain description, condition to join and nodes ip:port addresses that can be used fo joining
     * @return registered                    Flag if chain with specified chainId is registered
     * @return minRequiredDeposit            Min.required deposit to become transactor (user). 
     *                                        On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     * @return minRequiredVesting            Min.required deposit to become validator.
     *                                        On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     * @return rewardBonusRequiredVesting    Min. required vesting balance for bonus reward to be applied.
     *                                        In case rewardBonusRequiredVesting == 0, there is no reward bonus fot this chain
     * @return rewardBonusPercentage         Reward bonus (percentage) to be applied if validator's vesting balance >= rewardBonusRequiredVesting.
     * @return notaryPeriod                  Notary period in blocks (1 block every 5s), it is basically time interval notary periodic calls where users consumptions are processed and rewards distributed. 
     * @return maxNumOfValidators            Max. number of active validators (those who vested and started mining).
     *                                        On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     *                                        0 means unlimited
     * @return maxNumOfTransactors           Max. number of transactors/users (those who deposited.
     *                                        On top of this condition, chain creator might implement more sophisticated condition in external validator contract
     *                                        0 means unlimited
     * @return involvedVestingNotaryCond     Flag, if 50% invloved vesting condition is checked during notary. It means that vesting balances sum of those validators, who signed statistics 
     *                                        sent to the notary must be > 50% of the sum of all active validators vesting balances on chain 
     * @return participationNotaryCond       Flag, 2/3 + 1 participation condition is checked during notary. It means that more or equal to 2/3+1 of all active validators on chain 
     *                                        must sign statistics sent to the notary for notary to be accepted 
     **/
    function getChainStaticDetails(uint256 chainId) external view returns (string memory description, string memory endpoint, bool registered, uint256 minRequiredDeposit, uint256 minRequiredVesting, 
                                                                           uint256 rewardBonusRequiredVesting, uint256 rewardBonusPercentage, uint256 notaryPeriod, uint256 maxNumOfValidators, 
                                                                           uint256 maxNumOfTransactors, bool involvedVestingNotaryCond, bool participationNotaryCond) {
        ChainInfo storage chain = chains[chainId];
        
        description                 = chain.description;
        endpoint                    = chain.endpoint;
        registered                  = chain.registered;
        minRequiredDeposit          = chain.minRequiredDeposit;
        minRequiredVesting          = chain.minRequiredVesting;
        rewardBonusRequiredVesting  = chain.rewardBonusRequiredVesting;
        rewardBonusPercentage       = chain.rewardBonusPercentage;
        notaryPeriod                = chain.notaryPeriod;
        maxNumOfValidators          = chain.maxNumOfValidators;
        maxNumOfTransactors         = chain.maxNumOfTransactors;
        involvedVestingNotaryCond   = chain.involvedVestingNotaryCond;
        participationNotaryCond     = chain.participationNotaryCond;
    }
    
    /**
     * @notice Returns dynamic chain details
     *
     * @param chainId                    ChainId that sender wants to interact with
     * 
     * @return active                    Flag if chain is active. 
     *                                   True if there is > 0 active validatoes and there was successfull notary processed during last CHAIN_INACTIVITY_TIMEOUT (7 days), otherwise false
     * @return totalVesting              Actual chain total vesting - sum of all active validators vesting balance 
     * @return validatorsCount           Number of chain active validators
     * @return transactorsCount          Number of chain whitelisted transactors (their deposit balance >= min. required deposit)
     * @return lastValidatorVesting      Vesting of the last active validator (with the smallest vesting balance among all active validators). He is to be
     *                                    by anyone who vests more and want to become validator
     * @return lastNotaryBlock           Last processed block from Lition blockchain network during the last notary
     * @return lastNotaryTimestamp       Time of the last notary
     **/
    function getChainDynamicDetails(uint256 chainId) public view returns (bool active, uint256 totalVesting, uint256 validatorsCount, uint256 transactorsCount,
                                                                          uint256 lastValidatorVesting, uint256 lastNotaryBlock, uint256 lastNotaryTimestamp) {
        ChainInfo storage chain = chains[chainId];
        
        active               = chain.active;
        totalVesting         = chain.totalVesting;
        validatorsCount      = chain.validators.list.length;
        transactorsCount     = chain.actNumOfTransactors;
        lastValidatorVesting = chain.usersData[chain.lastValidator].validator.vesting;   
        lastNotaryBlock      = chain.lastNotary.block;
        lastNotaryTimestamp  = chain.lastNotary.timestamp;
    }
    
    /**
     * @notice Returns user details
     *
     * @param chainId                           ChainId that sender wants to interact with
     * @param acc                               Account to get details about
     * 
     * @return deposit                         Actual deposit balance
     * @return whitelisted                     Flag if user is allowed to transact (his deposit balance >= min. requred deposit)
     * @return vesting                         Actual veseting balance
     * @return lastVestingIncreaseTime         Last time, when validator increased his vesting. Validators then have to wait VESTING_LOCKUP_TIMEOUT (14 days)
     *                                          since lastVestingIncreaseTime before they can withraw full or just part of the vesting
     * @return mining                          Flag if user validator is actively mining (called startMining method)
     * @return prevNotaryMined                 Flag if validator mined at least one block during the previous notary window
     * @return vestingReqExist                 Flag if there is onoging request for vesting increse or full withdrawal
     * @return vestingReqNotary                Last known block accepted by notary in time when vesting request was created
     * @return vestingReqValue                 New value of vesting specified in request
     * @return depositFullWithdrawalReqExist   Flag if there is onoging request for deposit full withdrawal
     * @return depositReqNotary                Last known block accepted by notary in time when deposit withdrawal request was created
     **/
    function getUserDetails(uint256 chainId, address acc) external view returns (uint256 deposit, bool whitelisted, 
                                                                                 uint256 vesting, uint256 lastVestingIncreaseTime, bool mining, bool prevNotaryMined,
                                                                                 bool vestingReqExist, uint256 vestingReqNotary, uint256 vestingReqValue,
                                                                                 bool depositFullWithdrawalReqExist, uint256 depositReqNotary) {
        ChainInfo storage chain = chains[chainId];
        User storage user       = chain.usersData[acc];
         
        deposit                 = user.transactor.deposit;
        whitelisted             = user.transactor.whitelisted;
        vesting                 = user.validator.vesting;
        lastVestingIncreaseTime = user.validator.lastVestingIncreaseTime;
        mining                  = activeValidatorExist(chain, acc);
        prevNotaryMined         = user.validator.currentNotaryMined;  
        
        if (vestingRequestExist(chain, acc)) {
            vestingReqExist            = true;
            vestingReqNotary           = user.validator.vestingRequest.notaryBlock;
            vestingReqValue            = user.validator.vestingRequest.newVesting;
        }
        
        if (depositWithdrawalRequestExist(chain, acc)) {
            depositFullWithdrawalReqExist  = true;
            depositReqNotary               = user.transactor.depositWithdrawalRequest.notaryBlock;
        }
    }
    
    /**
     * @notice Notarization function - calculates user consumption as well as validators rewards. First, calculate hash from statistics sent to the notary, then, 
     *        do ec_recover of the signatures to determine signers, checks if there is enough signers (total vesting of signers > 50% of all vestings) or total num of signes >= 2/3+1 out of all validators
     *        and calculates users consuptions and validators rewards. Consuptions are deducted from the transactors deposit balances and rewards are added to the validators vesting balances.
     *        In case chain.active flag is false, it sets it to true.
     *        All active validators, who did not mine at least 1 block during last 2 notary windows are automatically removed from list of active validators
     * 
     * @param chainId          ChainId that sender wants to interact with
     * @param notaryStartBlock Start block of statistics from Lition blockchain network     
     * @param notaryEndBlock   End block of statistics from Lition blockchain network    
     * @param validators       List of validators from Lition blockchain network
     * @param blocksMined      List of mined blocks counts by validators 
     * @param users            List of users (transactors) from Lition blockchain network
     * @param userGas          List of users sums of gas consumption for all transactions they sent 
     * @param largestTx        Gas consumption of the largest (most expensive) transaction in statistics 
     * @param v, r, s          Parts of ecc signatures
     * 
     * @dev MiningReward(uint256 indexed chainId, address indexed account, uint256 reward) for each calculated reward
     * @dev Notary(uint256 indexed chainId, uint256 lastBlock, uint256 blocksProcessed) at the end of notary
     **/
    function notary(uint256 chainId, uint256 notaryStartBlock, uint256 notaryEndBlock, address[] memory validators, uint32[] memory blocksMined,
                    address[] memory users, uint64[] memory userGas, uint64 largestTx,
                    uint8[] memory v, bytes32[] memory r, bytes32[] memory s) public {
                  
        ChainInfo storage chain = chains[chainId];
        require(chain.registered    == true,                            "Invalid chain data: Non-registered chain");
        require(validatorExist(chain, msg.sender) == true,              "Sender must have vesting balance > 0");
        require(chain.totalVesting  > 0,                                "Current chain total_vesting == 0, there are no active validators");
        
        require(validators.length       > 0,                            "Invalid statistics data: validators.length == 0");
        require(validators.length       == blocksMined.length,          "Invalid statistics data: validators.length != num of block mined");
        if (chain.maxNumOfValidators != 0) {
            require(validators.length   <= chain.maxNumOfValidators,    "Invalid statistics data: validators.length > maxNumOfValidators");
            require(v.length            <= chain.maxNumOfValidators,    "Invalid statistics data: signatures.length > maxNumOfValidators");
        }
        
        if (chain.maxNumOfTransactors != 0) {
            require(users.length    <= chain.maxNumOfTransactors,   "Invalid statistics data: users.length > maxNumOfTransactors");
        }
        require(users.length        > 0,                            "Invalid statistics data: users.length == 0");
        require(users.length        == userGas.length,              "Invalid statistics data: users.length != usersGas.length");
        
        require(v.length            == r.length,                    "Invalid statistics data: v.length != r.length");
        require(v.length            == s.length,                    "Invalid statistics data: v.length != s.length");
        require(notaryStartBlock    >  chain.lastNotary.block,      "Invalid statistics data: notaryBlock_start <= last known notary block");
        require(notaryEndBlock      >  notaryStartBlock,            "Invalid statistics data: notaryEndBlock <= notaryStartBlock");
        require(largestTx           >  0,                           "Invalid statistics data: Largest tx <= 0");
        
        bytes32 signatureHash = keccak256(abi.encodePacked(notaryEndBlock, validators, blocksMined, users, userGas, largestTx));
        
        // Validates notary conditions(involvedVesting && participation) to statistics to be accepted
        validateNotaryConditions(chain, signatureHash, v, r, s);
        
        // Calculates total cost based on user's usage durint current notary window
        uint256 totalCost = processUsersConsumptions(chain, users, userGas, largestTx);
        
        // In case totalCost == 0, something is wrong and there is no need for notary to continue as there is no tokens to be distributed to the validators.
        // There is probably ongoing coordinated attack based on invalid statistics sent to the notary
        require(totalCost > 0, "Invalid statistics data: users totalUsageCost == 0");
        
        // How many block could validator mined since the last notary in case he did sign every possible block 
        uint256 maxBlocksMined = (notaryEndBlock - notaryStartBlock) + 1;
        
        // Calculates total involved vesting from provided list of validators and removes all validators that did not mine during last 2 notyary windows
        uint256 totalInvolvedVesting = processNotaryValidators(chain, validators, blocksMined, maxBlocksMined);
        
        // In case totalInvolvedVesting == 0, something is wrong and there is no need for notary to continue as rewards cannot be calculated. It might happen
        // as edge case when the last validator stopped mining durint current notary window or there is ongoing coordinated attack based on invalid statistics sent to the notary
        require(totalInvolvedVesting > 0, "totalInvolvedVesting == 0. Invalid statistics or 0 active validators left in the chain");
        
        // Calculates and process validator's rewards based on their participation rate and vesting balance
        processValidatorsRewards(chain, totalInvolvedVesting, validators, blocksMined, maxBlocksMined, totalCost);
        
        // Updates info when the last notary was processed 
        chain.lastNotary.block = notaryEndBlock;
        chain.lastNotary.timestamp = now;
        
        if (chain.active == false) {
            chain.active = true;
        }
        
        emit Notary(chainId, notaryEndBlock, maxBlocksMined);
    }
    

    /**
     * @notice Returns list of transactors (users) that are allowed to transact - their deposit >= min. required deposit (their accounts)
     *
     * @param chainId       ChainId that sender wants to interact with
     * @param batch         Batch number to be fetched. If the list is too big it cannot return all validators in one call. Instead, users are fetching batches of 100 account at a time 
     * 
     * @return validators  List(batch of 100) of account
     * @return count       How many accounts are returned in specified batch
     * @return end         Flag if there are no more accounts left. To get all accounts, caller should fetch all batches until he sees end == true
     **/
    function getTransactors(uint256 chainId, uint256 batch) external view returns (address[100] memory transactors, uint256 count, bool end) {
        return getUsers(chains[chainId], true, batch);
    }
    
    /**
     * @notice Returns list of active and non-active validators (their accounts)
     *
     * @param chainId       ChainId that sender wants to interact with
     * @param batch         Batch number to be fetched. If the list is too big it cannot return all validators in one call. Instead, users are fetching batches of 100 account at a time 
     * 
     * @return validators  List(batch of 100) of account
     * @return count       How many accounts are returned in specified batch
     * @return end         Flag if there are no more accounts left. To get all accounts, caller should fetch all batches until he sees end == true
     **/
    function getAllowedToValidate(uint256 chainId, uint256 batch) view external returns (address[100] memory validators, uint256 count, bool end) {
        return getUsers(chains[chainId], false, batch);
    }
    
    /**
     * @notice Returns list of active validators (their accounts)
     *
     * @param chainId       ChainId that sender wants to interact with
     * @param batch         Batch number to be fetched. If the list is too big it cannot return all validators in one call. Instead, users are fetching batches of 100 account at a time 
     * 
     * @return validators  List(batch of 100) of account
     * @return count       How many accounts are returned in specified batch
     * @return end         Flag if there are no more accounts left. To get all accounts, caller should fetch all batches until he sees end == true
     **/
    function getValidators(uint256 chainId, uint256 batch) view external returns (address[100] memory validators, uint256 count, bool end) {
        ChainInfo storage chain = chains[chainId];
        
        count = 0;
        uint256 validatorsTotalCount = chain.validators.list.length;
        
        address acc;
        uint256 i;
        for(i = batch * 100; i < (batch + 1)*100 && i < validatorsTotalCount; i++) {
            acc = chain.validators.list[i];
            
            validators[count] = acc;
            count++;
        }
        
        if (i >= validatorsTotalCount) {
            end = true;
        }
        else {
            end = false;
        }
    }
    
    /**
     * @notice Sets mining validator's mining flag to true and emit event so other nodes vote him
     *
     * @param chainId ChainId that sender wants to interact with
     * 
     * @dev AccountMining(uint256 indexed chainId, address indexed account, bool mining) event with mining == true
     **/
    function startMining(uint256 chainId) external {
        ChainInfo storage chain = chains[chainId];
        address acc = msg.sender;
        uint256 validatorVesting = chain.usersData[acc].validator.vesting;
        
        require(chain.registered == true,                         "Non-registered chain");
        require(validatorExist(chain, acc) == true,               "Non-existing validator (0 vesting balance)");
        require(vestingRequestExist(chain, acc) == false,         "Cannot start mining - there is ongoing vesting request");
        
        if (chain.chainValidator != ChainValidator(0)) {
            require(chain.chainValidator.validateNewValidator(validatorVesting, acc, true /* mining */, chain.validators.list.length) == true, "Validator not allowed by external chainvalidator SC");
        }
        
        if (activeValidatorExist(chain, acc) == true) {
            // Emit event even if validator is already active - user might want to explicitely emit this event in case something went wrong on the nodes and
            // others did not vote him
            emit AccountMining(chainId, acc, true);
            
            return;
        }
            
        // Upper limit of validators reached
        if (chain.maxNumOfValidators != 0 && chain.validators.list.length >= chain.maxNumOfValidators) {
            require(validatorVesting > chain.usersData[chain.lastValidator].validator.vesting, "Upper limit of validators reached. Must vest more than the last validator to replace him");
            activeValidatorReplace(chain, acc);
        }
        // There is still empty place for new validator
        else {
            activeValidatorInsert(chain, acc);
        }
    }
  
    /**
     * @notice Sets mining validator's mining flag to false and emit event so other nodes unvote. In case stopMining is called 
     *        by the last active validator, so there is 0 active validators left, it sets chain.active flag to false 
     *
     * @param chainId ChainId that sender wants to interact with
     * 
     * @dev AccountMining(uint256 indexed chainId, address indexed account, bool mining) event with mining == false
     **/
    function stopMining(uint256 chainId) external {
        ChainInfo storage chain = chains[chainId];
        address acc = msg.sender;
        
        require(chain.registered == true, "Non-registered chain");
        require(validatorExist(chain, acc) == true, "Non-existing validator (0 vesting balance)");
    
        if (activeValidatorExist(chain, acc) == false) {
            // Emit event even if validator is already inactive - user might want to explicitely emit this event in case something went wrong on the nodes and
            // others did not unvote him
            emit AccountMining(chainId, acc, false);
            
            return;
        }
        
        activeValidatorRemove(chain, acc);
    }
    

    /**************************************************************************************************************************/
    /**************************************** Functions related to the list of users ******************************************/
    /**************************************************************************************************************************/
    
    // Adds acc from the map
    function insertAcc(IterableMap storage map, address acc) internal {
        map.list.push(acc);
        // indexes are stored + 1   
        map.listIndex[acc] = map.list.length;
    }
    
    // Removes acc from the map
    function removeAcc(IterableMap storage map, address acc) internal {
        uint256 index = map.listIndex[acc];
        require(index > 0 && index <= map.list.length, "RemoveAcc invalid index");
        
        // Move an last element of array into the vacated key slot.
        uint256 foundIndex = index - 1;
        uint256 lastIndex  = map.list.length - 1;
    
        map.listIndex[map.list[lastIndex]] = foundIndex + 1;
        map.list[foundIndex] = map.list[lastIndex];
        map.list.length--;
    
        // Deletes element
        map.listIndex[acc] = 0;
    }
    
    // Returns true, if acc exists in the iterable map, otherwise false
    function existAcc(IterableMap storage map, address acc) internal view returns (bool) {
        return map.listIndex[acc] != 0;
    }
    
    // Inits validator data holder in the users mapping and inserts it into the list of users
    function validatorCreate(ChainInfo storage chain, address acc, uint256 vesting) internal {
        Validator storage validator     = chain.usersData[acc].validator;
        
        validator.vesting                   = vesting;
        validator.lastVestingIncreaseTime   = now;
        // Inits previously notary windows as mined so validator does not get removed from the list of actively mining validators right after the creation
        validator.currentNotaryMined        = true;
        validator.prevNotaryMined           = true;
        
        
        // No need to check if validatorExist for the same acc as it is not possible to have vesting > 0 & deosit > 0 at the same time
        insertAcc(chain.users, acc);
    }
    
    // Deinits validator data holder in the users mapping and removes it from the list of users
    function validatorDelete(ChainInfo storage chain, address acc) internal {
        Validator storage validator = chain.usersData[acc].validator;
        
        if (activeValidatorExist(chain, acc) == true) {
            activeValidatorRemove(chain, acc);
        }
        
        validator.vesting                   = 0;
        validator.lastVestingIncreaseTime   = 0;
        validator.currentNotaryMined        = false;
        validator.prevNotaryMined           = false;
        
        // No need to check if transactorExist for the same acc as it is not possible to have vesting > 0 & deosit > 0 at the same time
        removeAcc(chain.users, acc);
    }
    
    // Inserts validator into the list of actively mining validators
    function activeValidatorInsert(ChainInfo storage chain, address acc) internal {
        Validator storage validator = chain.usersData[acc].validator;
        
        // Updates lastValidator in case this is first validator or new validator's vesting balance is less
        if (chain.validators.list.length == 0 || validator.vesting <= chain.usersData[chain.lastValidator].validator.vesting) {
            chain.lastValidator = acc;
        }
        
        insertAcc(chain.validators, acc);   
        
        // Updates chain total vesting
        chain.totalVesting = chain.totalVesting.add(validator.vesting);
        
        emit AccountMining(chain.id, acc, true);
    }
    
    // Removes validator from the list of actively mining validators
    function activeValidatorRemove(ChainInfo storage chain, address acc) internal {
        Validator storage validator = chain.usersData[acc].validator;
        
        removeAcc(chain.validators, acc);   
        
        // Updates chain total vesting
        chain.totalVesting = chain.totalVesting.sub(validator.vesting);
        
        // If there is no active validator left, set chain.active flag to false so others might vest in chain without
        // waiting for the next notary window to be processed
        if (chain.validators.list.length == 0) {
            chain.active = false;
            chain.lastValidator = address(0x0);
        }
        // There are still some active validators left
        else {
            // If lastValidator is being removed, find a new validator with the smallest vesting balance
            if (chain.lastValidator == acc) {
                resetLastActiveValidator(chain);
            }
        }
        
        emit AccountMining(chain.id, acc, false);
    }
    
    // Replaces lastValidator for the new one in the list of actively mining validators
    function activeValidatorReplace(ChainInfo storage chain, address acc) internal {
        address accToBeReplaced                 = chain.lastValidator;
        Validator memory validatorToBeReplaced  = chain.usersData[accToBeReplaced].validator;
        Validator memory newValidator           = chain.usersData[acc].validator;
        
        // Updates chain total vesting
        chain.totalVesting = chain.totalVesting.sub(validatorToBeReplaced.vesting);
        chain.totalVesting = chain.totalVesting.add(newValidator.vesting);
        
        // Updates active validarors list
        removeAcc(chain.validators, accToBeReplaced);
        insertAcc(chain.validators, acc);
        
        // Finds a new validator with the smallest vesting balance
        resetLastActiveValidator(chain);
        
        emit AccountMining(chain.id, accToBeReplaced, false);
        emit AccountMining(chain.id, acc, true);
    }
    
    // Resets last validator - the one with the smallest vesting balance
    function resetLastActiveValidator(ChainInfo storage chain) internal {
        address foundLastValidatorAcc     = chain.validators.list[0];
        uint256 foundLastValidatorVesting = chain.usersData[foundLastValidatorAcc].validator.vesting;
        
        address actValidatorAcc;
        uint256 actValidatorVesting;
        for (uint256 i = 1; i < chain.validators.list.length; i++) {
            actValidatorAcc     = chain.validators.list[i];
            actValidatorVesting = chain.usersData[actValidatorAcc].validator.vesting;
            
            if (actValidatorVesting <= foundLastValidatorVesting) {
                foundLastValidatorAcc     = actValidatorAcc;
                foundLastValidatorVesting = actValidatorVesting;
            }
        }
        
        chain.lastValidator = foundLastValidatorAcc;
    }
    
    // Returns true, if acc is in the list of actively mining validators, otherwise false
    function activeValidatorExist(ChainInfo storage chain, address acc) internal view returns (bool) {
        return existAcc(chain.validators, acc);
    }
    
    // Returns true, if acc hase vesting > 0, otherwise false
    function validatorExist(ChainInfo storage chain, address acc) internal view returns (bool) {
        return chain.usersData[acc].validator.vesting > 0;
    }
    
    // Inits transactor data holder in the users mapping and inserts it into the list of users
    function transactorCreate(ChainInfo storage chain, address acc, uint256 deposit) internal {
        Transactor storage transactor = chain.usersData[acc].transactor;
        
        transactor.deposit = deposit;
        transactorWhitelist(chain, acc);
        
        // No need to check if validatorExist for the same acc as it is not possible to have vesting > 0 & deosit > 0 at the same time
        insertAcc(chain.users, acc);
    }
    
    // Deinits transactor data holder in the users mapping and removes it from the list of users
    function transactorDelete(ChainInfo storage chain, address acc) internal {
        Transactor storage transactor = chain.usersData[acc].transactor;
        
        transactor.deposit = 0;
        transactorBlacklist(chain, acc);
        
        // No need to check if validatorExist for the same acc as it is not possible to have vesting > 0 & deosit > 0 at the same time
        removeAcc(chain.users, acc);
    }
    
    // Returns true, if acc hase deposit > 0, otherwise false
    function transactorExist(ChainInfo storage chain, address acc) internal view returns (bool) {
        return chain.usersData[acc].transactor.deposit > 0;
    }
    
    // Blacklists transactor
    function transactorBlacklist(ChainInfo storage chain, address acc) internal {
        Transactor storage transactor   = chain.usersData[acc].transactor;
        
        if (transactor.whitelisted == true) {
            chain.actNumOfTransactors--;
            
            transactor.whitelisted = false;
            emit AccountWhitelisted(chain.id, acc, false);
        }
    }
    
    // Whitelists transactor
    function transactorWhitelist(ChainInfo storage chain, address acc) internal {
        Transactor storage transactor   = chain.usersData[acc].transactor;
        
        if (transactor.whitelisted == false) {
            chain.actNumOfTransactors++;
            
            transactor.whitelisted = true;
            emit AccountWhitelisted(chain.id, acc, true);
        }
    }
    
    // Returns list of users
    function getUsers(ChainInfo storage chain, bool transactorsFlag, uint256 batch) internal view returns (address[100] memory users, uint256 count, bool end) {
        count = 0;
        uint256 usersTotalCount = chain.users.list.length;
        
        address acc;
        uint256 i;
        for(i = batch * 100; i < (batch + 1)*100 && i < usersTotalCount; i++) {
            acc = chain.users.list[i];
            
            // Get transactors (only those who are whitelisted - their depist passed min.required conditions)
            if (transactorsFlag == true) {
                if (chain.usersData[acc].transactor.whitelisted == false) {
                    continue;
                } 
            }
            // Get validators (active and non-active)
            else {
                if (chain.usersData[acc].validator.vesting == 0) {
                    continue;
                }
            }
            
            users[count] = acc;
            count++;
        }
        
        if (i >= usersTotalCount) {
            end = true;
        }
        else {
            end = false;
        }
    }
    
    /**************************************************************************************************************************/
    /*********************************** Functions related to the vesting/deposit requests ************************************/
    /**************************************************************************************************************************/
    
    // Creates new vesting request
    function vestingRequestCreate(ChainInfo storage chain, address acc, uint256 vesting) internal {
        VestingRequest storage request = chain.usersData[acc].validator.vestingRequest;
        
        request.exist       = true;
        request.newVesting  = vesting;
        request.notaryBlock = chain.lastNotary.block; 
    }

    // Creates new deposit withdrawal request
    function depositWithdrawalRequestCreate(ChainInfo storage chain, address acc) internal {
        DepositWithdrawalRequest storage request = chain.usersData[acc].transactor.depositWithdrawalRequest;
        
        request.exist       = true;
        request.notaryBlock = chain.lastNotary.block; 
    }
    
    function vestingRequestDelete(ChainInfo storage chain, address acc) internal {
        // There is ongoing deposit request for this account - only reset vesting request
        VestingRequest storage request = chain.usersData[acc].validator.vestingRequest;
        request.exist          = false;
        request.notaryBlock    = 0;
        request.newVesting     = 0;
    }
    
    function depositWithdrawalRequestDelete(ChainInfo storage chain, address acc) internal {
        // There is ongoing vesting request for this account - only reset vesting request
        DepositWithdrawalRequest storage request = chain.usersData[acc].transactor.depositWithdrawalRequest;
        request.exist          = false;
        request.notaryBlock    = 0;
    }
    
    // Checks if acc has any ongoing vesting request
    function vestingRequestExist(ChainInfo storage chain, address acc) internal view returns (bool) {
        return chain.usersData[acc].validator.vestingRequest.exist;
    }
    
    // Checks if acc has any ongoing DEPOSIT WITHDRAWAL request
    function depositWithdrawalRequestExist(ChainInfo storage chain, address acc) internal view returns (bool) {
        return chain.usersData[acc].transactor.depositWithdrawalRequest.exist;
    }
    
    // Full vesting withdrawal  and vesting increase are procesed in 2 steps with confirmaition
    // Immediate full withdrawal is not allowed as validators might already mine some blocks so they can get rewards 
    // based on theirs vesting balance for that
    function requestVest(ChainInfo storage chain, uint256 vesting, address acc) internal {
        Validator storage validator = chain.usersData[acc].validator;
        
        uint256 validatorVesting = validator.vesting;
        
        // Vesting increase - process in 2 steps
        if (vesting > validatorVesting) {
            uint256 toVest = vesting - validatorVesting;
            token.transferFrom(acc, address(this), toVest);
        }
        // Vesting decrease - process immediately
        else if (vesting != 0) {
            uint256 toWithdraw = validatorVesting - vesting;
            
            validator.vesting = vesting;    
            
            // If validator is actively mining, decrease chain's total vesting
            if (activeValidatorExist(chain, acc) == true) {
                chain.totalVesting = chain.totalVesting.sub(toWithdraw);
                
                // Updates lastValidator in case it is needed - if user is decreasing vesting and there ist last validator 
                // with the same amount of tokens, keep him as last one because he had lower vesting for more time
                if (acc != chain.lastValidator && validator.vesting < chain.usersData[chain.lastValidator].validator.vesting) {
                    chain.lastValidator = acc;
                }
            }
            
            // Transfers tokens
            token.transfer(acc, toWithdraw);
            
            emit VestInChain(chain.id, acc, vesting, chain.lastNotary.block, true);
            return;
        }
        // else full vesting withdrawal - process in 2 steps
        
        vestingRequestCreate(chain, acc, vesting);
        emit VestInChain(chain.id, acc, vesting, chain.usersData[acc].validator.vestingRequest.notaryBlock, false);
        
        return;
    }
    
    function confirmVest(ChainInfo storage chain, address acc) internal {
        Validator storage validator             = chain.usersData[acc].validator;
        VestingRequest memory request           = chain.usersData[acc].validator.vestingRequest;
        
        vestingRequestDelete(chain, acc);
        uint256 origVesting = validator.vesting;
        
        // Vesting increase
        if (request.newVesting > origVesting) {
            // Non-existing validator - internally creates new one
            if (validatorExist(chain, acc) == false) {
                validatorCreate(chain, acc, request.newVesting);
            }
            // Existing validator
            else {
                validator.vesting = request.newVesting;
                validator.lastVestingIncreaseTime = now;
                
                if (activeValidatorExist(chain, acc) == true) {
                    chain.totalVesting = chain.totalVesting.add(request.newVesting - origVesting);
                    
                    // Updates last validator in case it is him who is increasing vesting balance
                    if (acc == chain.lastValidator) {
                        resetLastActiveValidator(chain);
                    }
                }    
            }
        }
        // Full vesting withdrawal - stopMining must be called before
        else {
            uint256 toWithdraw = origVesting;
            validatorDelete(chain, acc);
            
            // Transfers tokens
            token.transfer(acc, toWithdraw);
        }
        
        emit VestInChain(chain.id, acc, request.newVesting, request.notaryBlock, true);
    }
    
    function requestDeposit(ChainInfo storage chain, uint256 deposit, address acc) internal {
        Transactor storage transactor = chain.usersData[acc].transactor;
        
        // If user wants to withdraw whole deposit
        if (deposit == 0) {
            // Chain is not active - enable full deposit withdrawal immmediately
            if (chain.active == false) {
                uint256 toWithdraw = transactor.deposit;
                transactorDelete(chain, acc);
                
                // Withdraw whole deposit
                token.transfer(acc, toWithdraw);
                
                emit DepositInChain(chain.id, acc, deposit, chain.lastNotary.block, true);
            }
            // Chain is active - create withdrawal request and process full deposit withdrawal in 2 steps
            else {
                depositWithdrawalRequestCreate(chain, acc);
                
                transactorBlacklist(chain, acc);
                emit DepositInChain(chain.id, acc, deposit, chain.usersData[acc].transactor.depositWithdrawalRequest.notaryBlock, false);  
            }  
          
            return;
        }
      
        // If user wants to deposit in chain, process it immediately
        uint256 actTransactorDeposit = transactor.deposit;
        
        if(actTransactorDeposit > deposit) {
            transactor.deposit = deposit;
         
            uint256 toWithdraw = actTransactorDeposit - deposit;
            token.transfer(acc, toWithdraw);
        } else {
            uint256 toDeposit = deposit - actTransactorDeposit;
            token.transferFrom(acc, address(this), toDeposit);
         
            // First deposit - create internally new user
            if (transactorExist(chain, acc) == false) {
                transactorCreate(chain, acc, deposit);
            }
            else {
                transactor.deposit = deposit;
                transactorWhitelist(chain, acc);
            }
        }
        
        emit DepositInChain(chain.id, acc, deposit, chain.lastNotary.block, true);
    }
    
    function confirmDepositWithdrawal(ChainInfo storage chain, address acc) internal {
        Transactor storage transactor   = chain.usersData[acc].transactor;
        
        uint256 toWithdraw              = transactor.deposit;
        uint256 requestNotaryBlock      = transactor.depositWithdrawalRequest.notaryBlock;
        
        transactorDelete(chain, acc);
        depositWithdrawalRequestDelete(chain, acc);
        
        // Withdraw whole deposit
        token.transfer(acc, toWithdraw);
        
        emit DepositInChain(chain.id, acc, 0, requestNotaryBlock, true);
    }
    
    /**************************************************************************************************************************/
    /*************************************************** Other functions ******************************************************/
    /**************************************************************************************************************************/

    constructor(ERC20 _token) public {
        token = _token;
    }
  
    // Process users consumption based on their usage
    function processUsersConsumptions(ChainInfo storage chain, address[] memory users, uint64[] memory userGas, uint64 largestTxGas) internal returns (uint256 totalCost) {
        // Total usage cost in LIT tokens
        totalCost = 0;
        
        // Individual user's usage cost in LIT tokens
        uint256 userCost;
        
        uint256 transactorDeposit;
        address acc;
        for(uint256 i = 0; i < users.length; i++) {
            acc = users[i];
            Transactor storage transactor = chain.usersData[acc].transactor;
            transactorDeposit = transactor.deposit;
            
            // This can happen only if there is non-registered transactor(user) in statistics, which means that there is probaly
            // ongoing coordinated attack based on invalid statistics sent to the notary
            // Ignores non-registred user
            if (transactorExist(chain, acc) == false || userGas[i] == 0) {
                // Let nodes know that this user is not allowed to transact only if chain is active - in case it is not and becomes active again 
                // there might be some users that already withdrawed their deposit  
                if (chain.active == true) {
                    emit AccountWhitelisted(chain.id, users[i], false);
                }
                continue;
            }
            
            userCost = (userGas[i] * LARGEST_TX_FEE) / largestTxGas;
            
            // This can happen only if user runs out of tokens(which should not happen due to min.required deposit)
            if(userCost > transactorDeposit ) {
                userCost = transactorDeposit;
            
                transactorDelete(chain, acc);
            }
            else {
                transactorDeposit = transactorDeposit.sub(userCost);
                
                // Updates user's stored deposit balance based on his usage
                transactor.deposit = transactorDeposit;
                
                // Check if user's deposit balance is >= min. required deposit conditions
                if (transactorDeposit < chain.minRequiredDeposit) {
                    transactorBlacklist(chain, acc);
                }
            }
            
            // Adds user's cost to the total cost
            totalCost = totalCost.add(userCost);
        }
    }
    
    // Calculates validators invloved total vesting and removes validators that did not mine at all during the last 2 notary windows
    function processNotaryValidators(ChainInfo storage chain, address[] memory validators, uint32[] memory blocksMined, uint256 maxBlocksMined) internal returns (uint256 totalInvolvedVesting) {
        // Array of flags if active validators mined this notary window 
        bool[] memory miningValidators = new bool[](chain.validators.list.length); 
        
        // Selected validator's account address, index and vesting balance
        address actValidatorAcc;
        uint256 actValidatorIdx;
        uint256 actValidatorVesting;
        
        for(uint256 i = 0; i < validators.length; i++) {
            actValidatorAcc = validators[i];
        
            // Validators, who are not actively mining anymore (their node probably crashed) do not receive no rewaeds
            if (activeValidatorExist(chain, actValidatorAcc) == false || blocksMined[i] == 0) {
                continue;
            }
            
            actValidatorIdx = chain.validators.listIndex[actValidatorAcc] - 1;
            
            // In case there miningValidators[actValidatorIdx] is already true, it means the same validator address is twice in the statistics,
            // This should never happen, ignore such validators 
            if (miningValidators[actValidatorIdx] == true) {
                continue;
            }
            else {
                miningValidators[actValidatorIdx] = true;
            }
            
            actValidatorVesting = chain.usersData[actValidatorAcc].validator.vesting;
            
            // In case rewardBonusRequiredVesting is specified && actValidatorVesting is bigger, apply bonus
            if (chain.rewardBonusRequiredVesting > 0 && actValidatorVesting >= chain.rewardBonusRequiredVesting) {
                actValidatorVesting = actValidatorVesting.mul(chain.rewardBonusPercentage + 100) / 100;
            }
            
            totalInvolvedVesting = totalInvolvedVesting.add(actValidatorVesting.mul(blocksMined[i])); 
        }
        totalInvolvedVesting /= maxBlocksMined;

        // Process miningValidators from statistics and set current validators(registered in sc as active validators) mining flags accordingly
        for(uint256 i = 0; i < chain.validators.list.length; i++) {
            actValidatorAcc = chain.validators.list[i];
            
            Validator storage validator = chain.usersData[actValidatorAcc].validator;
            validator.prevNotaryMined   = validator.currentNotaryMined;
            
            if (miningValidators[i] == true) {
                validator.currentNotaryMined = true;
            }
            else {
                validator.currentNotaryMined = false;
            }
        }
        
        // Deletes validators who did not mine in the last 2 notary windows 
        uint256 activeValidatorsCount = chain.validators.list.length; 
        for (uint256 i = 0; i < activeValidatorsCount; ) {
            actValidatorAcc = chain.validators.list[i];
            Validator memory validator = chain.usersData[actValidatorAcc].validator;
           
            if (validator.currentNotaryMined == true || validator.prevNotaryMined == true) {
                i++;
                continue;
            }
           
            activeValidatorRemove(chain, actValidatorAcc);
            activeValidatorsCount--;
        } 
     
        delete miningValidators;   
    }

    // Process validators rewards based on their participation rate(how many blocks they signed) and their vesting balance
    function processValidatorsRewards(ChainInfo storage chain, uint256 totalInvolvedVesting, address[] memory validators, uint32[] memory blocksMined, uint256 maxBlocksMined, uint256 litToDistribute) internal {
        // Array of flags if active validators mined this notary window 
        bool[] memory miningValidators = new bool[](chain.validators.list.length); 
        
        // Selected validator's account address and vesting balance
        address actValidatorAcc;
        uint256 actValidatorIdx;
        uint256 actValidatorVesting;
        uint256 actValidatorReward;
        
        // Whats left after all rewards are distributed (math rounding)
        uint256 litToDistributeRest = litToDistribute;
        
        // Runs through all validators and calculates their reward based on:
        //     1. How many blocks out of max_blocks_mined each validator signed
        //     2. How many token each validator vested
        for(uint256 i = 0; i < validators.length; i++) {
            actValidatorAcc = validators[i];
            
            // Validators, who are not actively mining anymore (their node probably crashed) do not receive no rewaeds
            if (activeValidatorExist(chain, actValidatorAcc) == false || blocksMined[i] == 0) {
                continue;
            } 
            
            actValidatorIdx = chain.validators.listIndex[actValidatorAcc] - 1;
            
            // In case there miningValidators[actValidatorIdx] is already true, it means the same validator address is twice in the statistics,
            // This should never happen, ignore such validators 
            if (miningValidators[actValidatorIdx] == true) {
                continue;
            }
            else {
                miningValidators[actValidatorIdx] = true;
            }
            
            Validator storage actValidator = chain.usersData[actValidatorAcc].validator;
            actValidatorVesting = actValidator.vesting;
            
            // In case rewardBonusRequiredVesting is specified && actValidatorVesting is bigger, apply bonus
            if (chain.rewardBonusRequiredVesting > 0 && actValidatorVesting >= chain.rewardBonusRequiredVesting) {
                actValidatorVesting = actValidatorVesting.mul(chain.rewardBonusPercentage + 100) / 100;
            }
        
            actValidatorReward = actValidatorVesting.mul(blocksMined[i]).mul(litToDistribute) / maxBlocksMined / totalInvolvedVesting;
            
            litToDistributeRest = litToDistributeRest.sub(actValidatorReward);
            
            // Add rewards to the validator's vesting balance
            actValidator.vesting = actValidator.vesting.add(actValidatorReward);
            
            emit MiningReward(chain.id, actValidatorAcc, actValidatorReward);
        }
        
        if(litToDistributeRest > 0) {
            // Add the rest(math rounding) to the validator, who called notary function
            Validator storage sender = chain.usersData[msg.sender].validator;
            
            sender.vesting = sender.vesting.add(litToDistributeRest);
            
            if (activeValidatorExist(chain, msg.sender) == false) {
                chain.totalVesting = chain.totalVesting.sub(litToDistributeRest);
            }
            
            emit MiningReward(chain.id, msg.sender, litToDistributeRest);
        }
        
        // Updates chain total vesting
        chain.totalVesting = chain.totalVesting.add(litToDistribute); 
        
        // As validators vestings were updated, last validator might change so find a new one
        resetLastActiveValidator(chain);

        delete miningValidators;
    }
   
   // Validates notary conditions(involvedVesting && participation) to statistics to be accepted
    function validateNotaryConditions(ChainInfo storage chain, bytes32 signatureHash, uint8[] memory v, bytes32[] memory r, bytes32[] memory s) internal view {
        uint256 involvedVestingSum = 0;
        uint256 involvedSignaturesCount = 0;
        
        bool[] memory signedValidators = new bool[](chain.validators.list.length); 
        
        address signerAcc;
        for(uint256 i = 0; i < v.length; i++) {
            signerAcc = ecrecover(signatureHash, v[i], r[i], s[i]);
            
            // In case statistics is signed by validator, who is not registered in SC, ignore him   
            if (activeValidatorExist(chain, signerAcc) == false) {
                continue;
            }
            
            uint256 validatorIdx = chain.validators.listIndex[signerAcc] - 1;
            
            // In case there is duplicit signature from the same validator, ignore it
            if (signedValidators[validatorIdx] == true) {
                continue;
            }
            else {
                signedValidators[validatorIdx] = true;
            }
            
            
            involvedVestingSum = involvedVestingSum.add(chain.usersData[signerAcc].validator.vesting);
            involvedSignaturesCount++;
        }
        
        delete signedValidators;
        
        // There must be more than 50% out of total possible vesting involved in signatures
        if (chain.involvedVestingNotaryCond == true) {
            // There must be more than 50% out of total possible vesting involved
            involvedVestingSum = involvedVestingSum.mul(2);
            require(involvedVestingSum > chain.totalVesting, "Invalid statistics data: involvedVesting <= 50% of chain.totalVesting");
        }
        
        
        // There must be more than 2/3 + 1 out of all active validators unique signatures
        if (chain.participationNotaryCond == true) {
            uint256 actNumOfValidators = chain.validators.list.length;
            
            // min. number of active validators for BFT to work properly is 4
            if (actNumOfValidators >= 4) {
                uint256 minRequiredSignaturesCount = ((2 * actNumOfValidators) / 3) + 1;
                
                require(involvedSignaturesCount >= minRequiredSignaturesCount, "Invalid statistics data: Not enough signatures provided (2/3 + 1 cond)");
            }
            // if there is less than 4 active validators, everyone has to sign statistics
            else {
                require(involvedSignaturesCount == actNumOfValidators, "Invalid statistics data: Not enough signatures provided (involvedSignatures == activeValidatorsCount)");
            }
        }
    }
   
    // Checks if chain is active(successfull notary processed during last CHAIN_INACTIVITY_TIMEOUT), if not set it active flag to false
    // If last notary is older than CHAIN_INACTIVITY_TIMEOUT, it means that validators cannot reach consensus or there is no active validator and chain is basically stuck.
    function checkAndSetChainActivity(ChainInfo storage chain) internal {
        if (chain.active == true && chain.lastNotary.timestamp + CHAIN_INACTIVITY_TIMEOUT < now) {
            chain.active = false;   
        }
    }
}

// SafeMath library. Source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}