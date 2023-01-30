/**
 *Submitted for verification at Etherscan.io on 2019-09-02
*/

pragma solidity ^0.4.25;

/* Interface for ERC20 Tokens */
contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

/* Interface for the DMEX base contract */
contract DMEX_Base {
    function getReserve(address token, address user) returns (uint256);
    function setReserve(address token, address user, uint256 amount) returns (bool);

    function availableBalanceOf(address token, address user) returns (uint256);
    function balanceOf(address token, address user) returns (uint256);


    function setBalance(address token, address user, uint256 amount) returns (bool);
    function getAffiliate(address user) returns (address);
    function getInactivityReleasePeriod() returns (uint256);
    function getMakerTakerBalances(address token, address maker, address taker) returns (uint256[4]);

    function getEtmTokenAddress() returns (address);

    function subBalanceAddReserve(address token, address user, uint256 subBalance, uint256 addReserve) returns (bool);
    function subBalanceSubReserve(address token, address user, uint256 subBalance, uint256 subReserve) returns (bool);
    function addBalanceAddReserve(address token, address user, uint256 addBalance, uint256 addReserve) returns (bool);
    function addBalanceSubReserve(address token, address user, uint256 addBalance, uint256 subReserve) returns (bool);
    
}



// The DMEX Futures Contract
contract Exchange {
    function assert(bool assertion) pure {
        
        if (!assertion) {
            throw;
        }
    }

    // Safe Multiply Function - prevents integer overflow 
    function safeMul(uint a, uint b) pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    // Safe Subtraction Function - prevents integer overflow 
    function safeSub(uint a, uint b) pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    // Safe Addition Function - prevents integer overflow 
    function safeAdd(uint a, uint b) pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    address public owner; // holds the address of the contract owner

    // Event fired when the owner of the contract is changed
    event SetOwner(address indexed previousOwner, address indexed newOwner);

    // Allows only the owner of the contract to execute the function
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    // Allows only the owner of the contract to execute the function
    modifier onlyOracle {
        assert(msg.sender == DmexOracleContract);
        _;
    }

    // Changes the owner of the contract
    function setOwner(address newOwner) onlyOwner {
        emit SetOwner(owner, newOwner);
        owner = newOwner;
    }

    // Owner getter function
    function getOwner() view returns (address out) {
        return owner;
    }

    mapping (address => bool) public admins;                    // mapping of admin addresses
    mapping (address => bool) public pools;                     // mapping of liquidity pool addresses
    mapping (address => uint256) public lastActiveTransaction;  // mapping of user addresses to last transaction block
    mapping (bytes32 => uint256) public orderFills;             // mapping of orders to filled qunatity
    
    address public feeAccount;          // the account that receives the trading fees
    address public exchangeContract;    // the address of the main DMEX_Base contract
    address public DmexOracleContract;    // the address of the DMEX math contract used for some calculations

    uint256 public makerFee;            // maker fee in percent expressed as a fraction of 1 ether (0.1 ETH = 10%)
    uint256 public takerFee;            // taker fee in percent expressed as a fraction of 1 ether (0.1 ETH = 10%)
    
    struct FuturesAsset {
        string name;                    // the name of the traded asset (ex. ETHUSD)
        address baseToken;              // the token for collateral
        string priceUrl;                // the url where the price of the asset will be taken for settlement
        string pricePath;               // price path in the returned JSON from the priceUrl (ex. path "last" will return tha value last from the json: {"high": "156.49", "last": "154.31", "timestamp": "1556522201", "bid": "154.22", "vwap": "154.65", "volume": "25578.79138868", "low": "152.33", "ask": "154.26", "open": "152.99"})
        bool disabled;                  // if true, the asset cannot be used in contract creation (when price url no longer valid)
        uint256 maintenanceMargin;      // the maintenance margin as a fraction times 1e18 (0.5% = 0.005 * 1e18)
        uint256 decimals;               // number of decimals in the price
    }

    function createFuturesAsset(string name, address baseToken, string priceUrl, string pricePath, uint256 maintenanceMargin, uint256 decimals) onlyAdmin returns (bytes32)
    {    
        bytes32 futuresAsset = keccak256(this, name, baseToken, priceUrl, pricePath, maintenanceMargin, decimals);
        if (futuresAssets[futuresAsset].disabled) throw; // asset already exists and is disabled

        futuresAssets[futuresAsset] = FuturesAsset({
            name                : name,
            baseToken           : baseToken,
            priceUrl            : priceUrl,
            pricePath           : pricePath,
            disabled            : false,
            maintenanceMargin   : maintenanceMargin,
            decimals            : decimals
        });

        emit FuturesAssetCreated(futuresAsset, name, baseToken, priceUrl, pricePath);
        return futuresAsset;
    }
    
    struct FuturesContract {
        bytes32 asset;                  // the hash of the underlying asset object
        uint256 expirationBlock;        // futures contract expiration block
        uint256 closingPrice;           // the closing price for the futures contract
        bool closed;                    // is the futures contract closed (0 - false, 1 - true)c
        bool broken;                    // if someone has forced release of funds the contract is marked as broken and can no longer close positions (0-false, 1-true)
        uint256 floorPrice;             // the minimum price that can be traded on the contract, once price is reached the contract expires and enters settlement state 
        uint256 capPrice;               // the maximum price that can be traded on the contract, once price is reached the contract expires and enters settlement state
        uint256 multiplier;             // the multiplier price, normally the ETHUSD price * 1e18
        uint256 fundingRate;            // funding rate expressed as proportion per block * 1e18
        uint256 closingBlock;           // the block in which the contract was closed
    }

    function createFuturesContract(bytes32 asset, uint256 expirationBlock, uint256 floorPrice, uint256 capPrice, uint256 multiplier, uint256 fundingRate) onlyAdmin returns (bytes32)
    {    
        bytes32 futuresContract = keccak256(this, asset, expirationBlock, floorPrice, capPrice, multiplier, fundingRate);
        if (futuresContracts[futuresContract].expirationBlock > 0) return futuresContract; // contract already exists

        futuresContracts[futuresContract] = FuturesContract({
            asset           : asset,
            expirationBlock : expirationBlock,
            closingPrice    : 0,
            closed          : false,
            broken          : false,
            floorPrice      : floorPrice,
            capPrice        : capPrice,
            multiplier      : multiplier,
            fundingRate     : fundingRate,
            closingBlock    : 0
        });

        emit FuturesContractCreated(futuresContract, asset, expirationBlock, floorPrice, capPrice, multiplier);

        return futuresContract;
    }

    function getContractExpiration (bytes32 futuresContractHash) view returns (uint256)
    {
        return futuresContracts[futuresContractHash].expirationBlock;
    }

    function getContractClosed (bytes32 futuresContractHash) returns (bool)
    {
        return futuresContracts[futuresContractHash].closed;
    }

    function getAssetDecimals (bytes32 futuresContractHash) returns (uint256)
    {
        return futuresAssets[futuresContracts[futuresContractHash].asset].decimals;
    }

    function getContractPriceUrl (bytes32 futuresContractHash) returns (string)
    {
        return futuresAssets[futuresContracts[futuresContractHash].asset].priceUrl;
    }

    function getContractPricePath (bytes32 futuresContractHash) returns (string)
    {
        return futuresAssets[futuresContracts[futuresContractHash].asset].pricePath;
    }

    function getFloorPrice (bytes32 futuresContractHash) returns (uint256) {
        return futuresContracts[futuresContractHash].floorPrice;
    }

    function getCapPrice (bytes32 futuresContractHash) returns (uint256) {
        return futuresContracts[futuresContractHash].capPrice;
    }

    function getMaintenanceMargin (bytes32 futuresContractHash) returns (uint256)
    {
        return futuresAssets[futuresContracts[futuresContractHash].asset].maintenanceMargin;
    }

    function setClosingPrice (bytes32 futuresContractHash, uint256 price) onlyOracle returns (bool) {
        if (futuresContracts[futuresContractHash].closingPrice != 0) revert();
        futuresContracts[futuresContractHash].closingPrice = price;
        futuresContracts[futuresContractHash].closed = true;
        futuresContracts[futuresContractHash].closingBlock = block.number;

        return true;
    }

    mapping (bytes32 => FuturesAsset)       public futuresAssets;      // mapping of futuresAsset hash to FuturesAsset structs
    mapping (bytes32 => FuturesContract)    public futuresContracts;   // mapping of futuresContract hash to FuturesContract structs
    mapping (bytes32 => uint256)            public positions;          // mapping of user addresses to position hashes to position


    enum Errors {
        /*  0 */INVALID_PRICE,                 
        /*  1 */INVALID_SIGNATURE,              
        /*  2 */ORDER_ALREADY_FILLED,           
        /*  3 */GAS_TOO_HIGH,                  
        /*  4 */OUT_OF_BALANCE,                 
        /*  5 */FUTURES_CONTRACT_EXPIRED,       
        /*  6 */FLOOR_OR_CAP_PRICE_REACHED,     
        /*  7 */POSITION_ALREADY_EXISTS,        
        /*  8 */UINT48_VALIDATION,              
        /*  9 */FAILED_ASSERTION,               
        /* 10 */NOT_A_POOL,
        /* 11 */POSITION_EMPTY,
        /* 12 */OLD_CONTRACT_OPEN,
        /* 13 */OLD_CONTRACT_IN_RANGE,
        /* 14 */NEW_CONTRACT_NOT_FOUND,
        /* 15 */DIFF_EXPIRATIONS,
        /* 16 */DIFF_ASSETS,
        /* 17 */WRONG_RANGE,
        /* 18 */IDENTICAL_CONTRACTS,
        /* 19 */USER_NOT_IN_PROFIT,
        /* 20 */WRONG_MULTIPLIER,
        /* 21 */USER_POSITION_GREATER,
        /* 22 */WRONG_FUNDING_RATE
    }

    event FuturesTrade(bool side, uint256 size, uint256 price, bytes32 indexed futuresContract, bytes32 indexed makerOrderHash, bytes32 indexed takerOrderHash);
    event FuturesPositionClosed(bytes32 indexed positionHash, uint256 closingPrice);
    event FuturesForcedRelease(bytes32 indexed futuresContract, bool side, address user);
    event FuturesAssetCreated(bytes32 indexed futuresAsset, string name, address baseToken, string priceUrl, string pricePath);
    event FuturesContractCreated(bytes32 indexed futuresContract, bytes32 asset, uint256 expirationBlock, uint256 floorPrice, uint256 capPrice, uint256 multiplier);
 
    // Fee change event
    event FeeChange(uint256 indexed makerFee, uint256 indexed takerFee);

    // Log event, logs errors in contract execution (for internal use)
    event LogError(uint8 indexed errorId, bytes32 indexed makerOrderHash, bytes32 indexed takerOrderHash);
    //event LogErrorLight(uint8 errorId);
    event LogUint(uint8 id, uint256 value);
    //event LogBool(uint8 id, bool value);
    //event LogAddress(uint8 id, address value);


    // Constructor function, initializes the contract and sets the core variables
    function Exchange(address feeAccount_, uint256 makerFee_, uint256 takerFee_, address exchangeContract_, address DmexOracleContract_, address poolAddress) {
        owner               = msg.sender;
        feeAccount          = feeAccount_;
        makerFee            = makerFee_;
        takerFee            = takerFee_;

        exchangeContract    = exchangeContract_;
        DmexOracleContract    = DmexOracleContract_;

        pools[poolAddress] = true;
    }

    // Changes the fees
    function setFees(uint256 makerFee_, uint256 takerFee_) onlyOwner {
        require(makerFee_       < 10 finney && takerFee_ < 10 finney); // The fees cannot be set higher then 1%
        makerFee                = makerFee_;
        takerFee                = takerFee_;

        emit FeeChange(makerFee, takerFee);
    }

    // Adds or disables an admin account
    function setAdmin(address admin, bool isAdmin) onlyOwner {
        admins[admin] = isAdmin;
    }

    // Adds or disables a liquidity pool address
    function setPool(address user, bool enabled) onlyOwner public {
        pools[user] = enabled;
    }

    // Allows for admins only to call the function
    modifier onlyAdmin {
        if (msg.sender != owner && !admins[msg.sender]) throw;
        _;
    }

    function() external {
        throw;
    }   


    function validateUint48(uint256 val) returns (bool)
    {
        if (val != uint48(val)) return false;
        return true;
    }

    function validateUint64(uint256 val) returns (bool)
    {
        if (val != uint64(val)) return false;
        return true;
    }

    function validateUint128(uint256 val) returns (bool)
    {
        if (val != uint128(val)) return false;
        return true;
    }


    // Structure that holds order values, used inside the trade() function
    struct FuturesOrderPair {
        uint256 makerNonce;                 // maker order nonce, makes the order unique
        uint256 takerNonce;                 // taker order nonce
        uint256 takerGasFee;                // taker gas fee, taker pays the gas
        uint256 takerIsBuying;              // true/false taker is the buyer

        address maker;                      // address of the maker
        address taker;                      // address of the taker

        bytes32 makerOrderHash;             // hash of the maker order
        bytes32 takerOrderHash;             // has of the taker order

        uint256 makerAmount;                // trade amount for maker
        uint256 takerAmount;                // trade amount for taker

        uint256 makerPrice;                 // maker order price in wei (18 decimal precision)
        uint256 takerPrice;                 // taker order price in wei (18 decimal precision)

        bytes32 futuresContract;            // the futures contract being traded

        address baseToken;                  // the address of the base token for futures contract
        uint256 floorPrice;                 // floor price of futures contract
        uint256 capPrice;                   // cap price of futures contract

        bytes32 makerPositionHash;          // hash for maker position
        bytes32 makerInversePositionHash;   // hash for inverse maker position 

        bytes32 takerPositionHash;          // hash for taker position
        bytes32 takerInversePositionHash;   // hash for inverse taker position
    }

    // Structure that holds trade values, used inside the trade() function
    struct FuturesTradeValues {
        uint256 qty;                // amount to be trade
        uint256 makerProfit;        // holds maker profit value
        uint256 makerLoss;          // holds maker loss value
        uint256 takerProfit;        // holds taker profit value
        uint256 takerLoss;          // holds taker loss value
        uint256 makerBalance;       // holds maker balance value
        uint256 takerBalance;       // holds taker balance value
        uint256 makerReserve;       // holds taker reserved value
        uint256 takerReserve;       // holds taker reserved value
    }

    // Opens/closes futures positions
    function futuresTrade(
        uint8[2] v,
        bytes32[4] rs,
        uint256[8] tradeValues,
        address[2] tradeAddresses,
        bool takerIsBuying,
        bytes32 futuresContractHash
    ) onlyAdmin returns (uint filledTakerTokenAmount)
    {
        /* tradeValues
          [0] makerNonce
          [1] takerNonce
          [2] takerGasFee
          [3] takerIsBuying
          [4] makerAmount
          [5] takerAmount
          [6] makerPrice
          [7] takerPrice

          tradeAddresses
          [0] maker
          [1] taker
        */

        FuturesOrderPair memory t  = FuturesOrderPair({
            makerNonce      : tradeValues[0],
            takerNonce      : tradeValues[1],
            takerGasFee     : tradeValues[2],
            takerIsBuying   : tradeValues[3],
            makerAmount     : tradeValues[4],      
            takerAmount     : tradeValues[5],   
            makerPrice      : tradeValues[6],         
            takerPrice      : tradeValues[7],

            maker           : tradeAddresses[0],
            taker           : tradeAddresses[1],

            //                                futuresContract      user               amount          price           side             nonce
            makerOrderHash  : keccak256(this, futuresContractHash, tradeAddresses[0], tradeValues[4], tradeValues[6], !takerIsBuying, tradeValues[0]),
            takerOrderHash  : keccak256(this, futuresContractHash, tradeAddresses[1], tradeValues[5], tradeValues[7],  takerIsBuying, tradeValues[1]),            

            futuresContract : futuresContractHash,

            baseToken       : futuresAssets[futuresContracts[futuresContractHash].asset].baseToken,
            floorPrice      : futuresContracts[futuresContractHash].floorPrice,
            capPrice        : futuresContracts[futuresContractHash].capPrice,

            //                                            user               futuresContractHash   side
            makerPositionHash           : keccak256(this, tradeAddresses[0], futuresContractHash, !takerIsBuying),
            makerInversePositionHash    : keccak256(this, tradeAddresses[0], futuresContractHash, takerIsBuying),

            takerPositionHash           : keccak256(this, tradeAddresses[1], futuresContractHash, takerIsBuying),
            takerInversePositionHash    : keccak256(this, tradeAddresses[1], futuresContractHash, !takerIsBuying)

        });

//--> 44 000
    
        // Valifate size and price values
        if (!validateUint128(t.makerAmount) || !validateUint128(t.takerAmount) || !validateUint64(t.makerPrice) || !validateUint64(t.takerPrice))
        {            
            emit LogError(uint8(Errors.UINT48_VALIDATION), t.makerOrderHash, t.takerOrderHash);
            return 0; 
        }


        // Check if futures contract has expired already
        if (block.number > futuresContracts[t.futuresContract].expirationBlock || futuresContracts[t.futuresContract].closed == true || futuresContracts[t.futuresContract].broken == true)
        {
            emit LogError(uint8(Errors.FUTURES_CONTRACT_EXPIRED), t.makerOrderHash, t.takerOrderHash);
            return 0; // futures contract is expired
        }

        // Checks the signature for the maker order
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", t.makerOrderHash), v[0], rs[0], rs[1]) != t.maker)
        {
            emit LogError(uint8(Errors.INVALID_SIGNATURE), t.makerOrderHash, t.takerOrderHash);
            return 0;
        }
       
        // Checks the signature for the taker order
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", t.takerOrderHash), v[1], rs[2], rs[3]) != t.taker)
        {
            emit LogError(uint8(Errors.INVALID_SIGNATURE), t.makerOrderHash, t.takerOrderHash);
            return 0;
        }



        // check prices
        if ((!takerIsBuying && t.makerPrice < t.takerPrice) || (takerIsBuying && t.takerPrice < t.makerPrice))
        {
            emit LogError(uint8(Errors.INVALID_PRICE), t.makerOrderHash, t.takerOrderHash);
            return 0; // prices don't match
        }      

//--> 54 000

         
        

        uint256[4] memory balances = DMEX_Base(exchangeContract).getMakerTakerBalances(t.baseToken, t.maker, t.taker);

        // Initializing trade values structure 
        FuturesTradeValues memory tv = FuturesTradeValues({
            qty                 : 0,
            makerProfit         : 0,
            makerLoss           : 0,
            takerProfit         : 0,
            takerLoss           : 0,
            makerBalance        : balances[0], 
            takerBalance        : balances[1],  
            makerReserve        : balances[2],  
            takerReserve        : balances[3] 
        });

//--> 60 000



        // traded quantity is the smallest quantity between the maker and the taker, takes into account amounts already filled on the orders
        // and open inverse positions
        tv.qty = min(safeSub(t.makerAmount, orderFills[t.makerOrderHash]), safeSub(t.takerAmount, orderFills[t.takerOrderHash]));
        
        if (positionExists(t.makerInversePositionHash) && positionExists(t.takerInversePositionHash))
        {
            tv.qty = min(tv.qty, min(retrievePosition(t.makerInversePositionHash)[0], retrievePosition(t.takerInversePositionHash)[0]));
        }
        else if (positionExists(t.makerInversePositionHash))
        {
            tv.qty = min(tv.qty, retrievePosition(t.makerInversePositionHash)[0]);
        }
        else if (positionExists(t.takerInversePositionHash))
        {
            tv.qty = min(tv.qty, retrievePosition(t.takerInversePositionHash)[0]);
        }

       



//--> 64 000       
        
        if (tv.qty == 0)
        {
            // no qty left on orders
            emit LogError(uint8(Errors.ORDER_ALREADY_FILLED), t.makerOrderHash, t.takerOrderHash);
            return 0;
        }

        // Cheks that gas fee is not higher than 10%
        if (safeMul(t.takerGasFee, 20) > calculateTradeValue(tv.qty, t.makerPrice, t.futuresContract))
        {
            emit LogError(uint8(Errors.GAS_TOO_HIGH), t.makerOrderHash, t.takerOrderHash);
            return 0;
        } // takerGasFee too high


//--> 66 000
        

       

        /*------------- Maker long, Taker short -------------*/
        if (!takerIsBuying)
        {     
            
      
            // position actions for maker
            if (!positionExists(t.makerInversePositionHash) && !positionExists(t.makerPositionHash))
            {


                // check if maker has enough balance   
                if (!checkEnoughBalance(t.floorPrice, t.makerPrice, tv.qty, true, makerFee, 0, futuresContractHash, safeSub(balances[0],tv.makerReserve)))
                {
                    // maker out of balance
                    emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                    return 0; 
                }

                
                
                // create new position
                recordNewPosition(t.makerPositionHash, tv.qty, t.makerPrice, 1, block.number);



                updateBalances(
                    t.futuresContract, 
                    [
                        t.baseToken, // base token
                        t.maker // make address
                    ], 
                    t.makerPositionHash,  // position hash
                    [
                        tv.qty, // qty
                        t.makerPrice,  // price
                        makerFee, // fee
                        0, // profit
                        0, // loss
                        tv.makerBalance, // balance
                        0, // gasFee
                        tv.makerReserve // reserve
                    ], 
                    [
                        true, // newPostion (if true position is new)
                        true, // side (if true - long)
                        false // increase position (if true)
                    ]
                );

            } else {               
                
                if (positionExists(t.makerPositionHash))
                {
                    // check if maker has enough balance            
                    if (!checkEnoughBalance(t.floorPrice, t.makerPrice, tv.qty, true, makerFee, 0, futuresContractHash, safeSub(balances[0],tv.makerReserve)))
                    {
                        // maker out of balance
                        emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                        return 0; 
                    }

                    // increase position size
                    updatePositionSize(t.makerPositionHash, safeAdd(retrievePosition(t.makerPositionHash)[0], tv.qty), t.makerPrice);
                
                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken,  // base token
                            t.maker // make address
                        ], 
                        t.makerPositionHash, // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            makerFee, // fee
                            0, // profit
                            0, // loss
                            tv.makerBalance, // balance
                            0, // gasFee
                            tv.makerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            true, // side (if true - long)
                            true // increase position (if true)
                        ]
                    );
                }
                else
                {

                    // close/partially close existing position
                    updatePositionSize(t.makerInversePositionHash, safeSub(retrievePosition(t.makerInversePositionHash)[0], tv.qty), 0);
                    
                    

                    if (t.makerPrice < retrievePosition(t.makerInversePositionHash)[1])
                    {
                        // user has made a profit
                        //tv.makerProfit                    = safeMul(safeSub(retrievePosition(t.makerInversePositionHash)[1], t.makerPrice), tv.qty) / t.makerPrice;
                        tv.makerProfit                      = calculateProfit(t.makerPrice, retrievePosition(t.makerInversePositionHash)[1], tv.qty, futuresContractHash, true);
                    }
                    else
                    {
                        // user has made a loss
                        //tv.makerLoss                      = safeMul(safeSub(t.makerPrice, retrievePosition(t.makerInversePositionHash)[1]), tv.qty) / t.makerPrice;    
                        tv.makerLoss                        = calculateLoss(t.makerPrice, retrievePosition(t.makerInversePositionHash)[1], tv.qty, futuresContractHash, true);                                        
                    }

                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken, // base token
                            t.maker // make address
                        ], 
                        t.makerInversePositionHash, // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            makerFee, // fee
                            tv.makerProfit,  // profit
                            tv.makerLoss,  // loss
                            tv.makerBalance, // balance
                            0, // gasFee
                            tv.makerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            true, // side (if true - long)
                            false // increase position (if true)
                        ]
                    );
                }                
            }

           


            // position actions for taker
            if (!positionExists(t.takerInversePositionHash) && !positionExists(t.takerPositionHash))
            {
                
                // check if taker has enough balance
                if (!checkEnoughBalance(t.capPrice, t.makerPrice, tv.qty, false, takerFee, t.takerGasFee, futuresContractHash, safeSub(balances[1],tv.takerReserve)))
                {
                    // maker out of balance
                    emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                    return 0; 
                }
                
                // create new position
                recordNewPosition(t.takerPositionHash, tv.qty, t.makerPrice, 0, block.number);
                
                updateBalances(
                    t.futuresContract, 
                    [
                        t.baseToken, // base token
                        t.taker // make address
                    ], 
                    t.takerPositionHash, // position hash
                    [
                        tv.qty, // qty
                        t.makerPrice,  // price
                        takerFee, // fee
                        0, // profit
                        0,  // loss
                        tv.takerBalance,  // balance
                        t.takerGasFee, // gasFee
                        tv.takerReserve // reserve
                    ], 
                    [
                        true, // newPostion (if true position is new)
                        false, // side (if true - long)
                        false // increase position (if true)
                    ]
                );

            } else {
                if (positionExists(t.takerPositionHash))
                {
                    // check if taker has enough balance
                    //if (safeAdd(safeAdd(safeMul(safeSub(t.capPrice, t.makerPrice), tv.qty)  / t.capPrice, safeMul(tv.qty, takerFee) / (1 ether))  * 1e10, t.takerGasFee) > safeSub(balances[1],tv.takerReserve))
                    if (!checkEnoughBalance(t.capPrice, t.makerPrice, tv.qty, false, takerFee, t.takerGasFee, futuresContractHash, safeSub(balances[1],tv.takerReserve)))
                    {
                        // maker out of balance
                        emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                        return 0; 
                    }

                    // increase position size
                    updatePositionSize(t.takerPositionHash, safeAdd(retrievePosition(t.takerPositionHash)[0], tv.qty), t.makerPrice);
                
                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken,  // base token
                            t.taker // make address
                        ], 
                        t.takerPositionHash, // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            takerFee, // fee
                            0, // profit
                            0, // loss
                            tv.takerBalance, // balance
                            t.takerGasFee, // gasFee
                            tv.takerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            false, // side (if true - long)
                            true // increase position (if true)
                        ]
                    );
                }
                else
                {    
                    // close/partially close existing position
                    updatePositionSize(t.takerInversePositionHash, safeSub(retrievePosition(t.takerInversePositionHash)[0], tv.qty), 0);
                    
                    if (t.makerPrice > retrievePosition(t.takerInversePositionHash)[1])
                    {
                        // user has made a profit
                        tv.takerProfit                      = calculateProfit(t.makerPrice, retrievePosition(t.takerInversePositionHash)[1], tv.qty, futuresContractHash, false);
                    }
                    else
                    {
                        // user has made a loss
                        tv.takerLoss                        = calculateLoss(t.makerPrice, retrievePosition(t.takerInversePositionHash)[1], tv.qty, futuresContractHash, false); 
                    }

                  

                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken, // base token
                            t.taker // make address
                        ], 
                        t.takerInversePositionHash, // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            takerFee, // fee
                            tv.takerProfit, // profit
                            tv.takerLoss, // loss
                            tv.takerBalance,  // balance
                            t.takerGasFee,  // gasFee
                            tv.takerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            false, // side (if true - long)
                            false // increase position (if true)
                        ]
                    );
                }
            }
        }


        /*------------- Maker short, Taker long -------------*/

        else
        {      
            // position actions for maker
            if (!positionExists(t.makerInversePositionHash) && !positionExists(t.makerPositionHash))
            {
                // check if maker has enough balance
                if (!checkEnoughBalance(t.capPrice, t.makerPrice, tv.qty, false, makerFee, 0, futuresContractHash, safeSub(balances[0],tv.makerReserve)))
                {
                    // maker out of balance
                    emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                    return 0; 
                }

                // create new position
                recordNewPosition(t.makerPositionHash, tv.qty, t.makerPrice, 0, block.number);
                updateBalances(
                    t.futuresContract, 
                    [
                        t.baseToken,   // base token
                        t.maker // make address
                    ], 
                    t.makerPositionHash, // position hash
                    [
                        tv.qty, // qty
                        t.makerPrice, // price
                        makerFee, // fee
                        0, // profit
                        0, // loss
                        tv.makerBalance, // balance
                        0, // gasFee
                        tv.makerReserve // reserve
                    ], 
                    [
                        true, // newPostion (if true position is new)
                        false, // side (if true - long)
                        false // increase position (if true)
                    ]
                );

            } else {
                if (positionExists(t.makerPositionHash))
                {
                    // check if maker has enough balance
                    if (!checkEnoughBalance(t.capPrice, t.makerPrice, tv.qty, false, makerFee, 0, futuresContractHash, safeSub(balances[0],tv.makerReserve)))
                    {
                        // maker out of balance
                        emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                        return 0; 
                    }

                    // increase position size
                    updatePositionSize(t.makerPositionHash, safeAdd(retrievePosition(t.makerPositionHash)[0], tv.qty), t.makerPrice);
                
                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken,  // base token
                            t.maker // make address
                        ], 
                        t.makerPositionHash, // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            makerFee, // fee
                            0, // profit
                            0, // loss
                            tv.makerBalance, // balance
                            0, // gasFee
                            tv.makerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            false, // side (if true - long)
                            true // increase position (if true)
                        ]
                    );
                }
                else
                {

                    // close/partially close existing position
                    updatePositionSize(t.makerInversePositionHash, safeSub(retrievePosition(t.makerInversePositionHash)[0], tv.qty), 0);       
                    


                    if (t.makerPrice > retrievePosition(t.makerInversePositionHash)[1])
                    {
                        // user has made a profit
                        tv.makerProfit                      = calculateProfit(t.makerPrice, retrievePosition(t.makerInversePositionHash)[1], tv.qty, futuresContractHash, false);
                    }
                    else
                    {
                        // user has made a loss
                        tv.makerLoss                        = calculateLoss(t.makerPrice, retrievePosition(t.makerInversePositionHash)[1], tv.qty, futuresContractHash, false);                               
                    }

                   

                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken, // base token
                            t.maker // user address
                        ], 
                        t.makerInversePositionHash, // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            makerFee, // fee
                            tv.makerProfit,  // profit
                            tv.makerLoss, // loss
                            tv.makerBalance, // balance
                            0, // gasFee
                            tv.makerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            false, // side (if true - long)
                            false // increase position (if true)
                        ]
                    );
                }
            }

            // position actions for taker
            if (!positionExists(t.takerInversePositionHash) && !positionExists(t.takerPositionHash))
            {
                // check if taker has enough balance
                if (!checkEnoughBalance(t.floorPrice, t.makerPrice, tv.qty, true, takerFee, t.takerGasFee, futuresContractHash, safeSub(balances[1],tv.takerReserve)))
                {
                    // maker out of balance
                    emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                    return 0; 
                }

                // create new position
                recordNewPosition(t.takerPositionHash, tv.qty, t.makerPrice, 1, block.number);
           
                updateBalances(
                    t.futuresContract, 
                    [
                        t.baseToken,  // base token
                        t.taker // user address
                    ], 
                    t.takerPositionHash, // position hash
                    [
                        tv.qty, // qty
                        t.makerPrice, // price
                        takerFee, // fee
                        0,  // profit
                        0,  // loss
                        tv.takerBalance, // balance
                        t.takerGasFee, // gasFee
                        tv.takerReserve // reserve
                    ], 
                    [
                        true, // newPostion (if true position is new)
                        true, // side (if true - long)
                        false // increase position (if true)
                    ]
                );

            } else {
                if (positionExists(t.takerPositionHash))
                {
                    // check if taker has enough balance
                    if (!checkEnoughBalance(t.floorPrice, t.makerPrice, tv.qty, true, takerFee, t.takerGasFee, futuresContractHash, safeSub(balances[1],tv.takerReserve)))
                    {
                        // maker out of balance
                        emit LogError(uint8(Errors.OUT_OF_BALANCE), t.makerOrderHash, t.takerOrderHash);
                        return 0; 
                    }
                    
                    // increase position size
                    updatePositionSize(t.takerPositionHash, safeAdd(retrievePosition(t.takerPositionHash)[0], tv.qty), t.makerPrice);
                
                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken,  // base token
                            t.taker // user address
                        ], 
                        t.takerPositionHash, // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            takerFee, // fee
                            0, // profit
                            0, // loss
                            tv.takerBalance, // balance
                            t.takerGasFee, // gasFee
                            tv.takerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            true, // side (if true - long)
                            true // increase position (if true)
                        ]
                    );
                }
                else
                {

                    // close/partially close existing position
                    updatePositionSize(t.takerInversePositionHash, safeSub(retrievePosition(t.takerInversePositionHash)[0], tv.qty), 0);
                                     
                    if (t.makerPrice < retrievePosition(t.takerInversePositionHash)[1])
                    {
                        // user has made a profit
                        tv.takerProfit                      = calculateProfit(t.makerPrice, retrievePosition(t.takerInversePositionHash)[1], tv.qty, futuresContractHash, true);
                    }
                    else
                    {
                        // user has made a loss
                        tv.takerLoss                        = calculateLoss(t.makerPrice, retrievePosition(t.takerInversePositionHash)[1], tv.qty, futuresContractHash, true);                                  
                    }

                    

                    updateBalances(
                        t.futuresContract, 
                        [
                            t.baseToken,   // base toke
                            t.taker // user address
                        ], 
                        t.takerInversePositionHash,  // position hash
                        [
                            tv.qty, // qty
                            t.makerPrice, // price
                            takerFee, // fee
                            tv.takerProfit, // profit
                            tv.takerLoss, // loss
                            tv.takerBalance, // balance
                            t.takerGasFee, // gasFee
                            tv.takerReserve // reserve
                        ], 
                        [
                            false, // newPostion (if true position is new)
                            true, // side (if true - long) 
                            false // increase position (if true)
                        ]
                    );
                }
            }           
        }

//--> 220 000
        orderFills[t.makerOrderHash]            = safeAdd(orderFills[t.makerOrderHash], tv.qty); // increase the maker order filled amount
        orderFills[t.takerOrderHash]            = safeAdd(orderFills[t.takerOrderHash], tv.qty); // increase the taker order filled amount

//--> 264 000
        emit FuturesTrade(takerIsBuying, tv.qty, t.makerPrice, t.futuresContract, t.makerOrderHash, t.takerOrderHash);

        return tv.qty;
    }


    function calculateProfit(uint256 closingPrice, uint256 entryPrice, uint256 qty, bytes32 futuresContractHash, bool side) returns (uint256)
    {
        uint256 multiplier = futuresContracts[futuresContractHash].multiplier;

        if (side)
        {           
            return safeMul(safeMul(safeSub(entryPrice, closingPrice), qty), multiplier / 1e10)  / 1e16;            
        }
        else
        {
            return safeMul(safeMul(safeSub(closingPrice, entryPrice), qty), multiplier / 1e10)  / 1e16; 
        }       
    }

    function calculateTradeValue(uint256 qty, uint256 price, bytes32 futuresContractHash) returns (uint256)
    {
        uint256 multiplier = futuresContracts[futuresContractHash].multiplier;
        return safeMul(safeMul(safeMul(qty, price), 1e2), multiplier) / 1e18 ;
    }



    function calculateLoss(uint256 closingPrice, uint256 entryPrice, uint256 qty,  bytes32 futuresContractHash, bool side) returns (uint256)
    {
        uint256 multiplier = futuresContracts[futuresContractHash].multiplier;

        if (side)
        {
            return safeMul(safeMul(safeSub(closingPrice, entryPrice), qty), multiplier/ 1e10) / 1e16 ;
        }
        else
        {
            return safeMul(safeMul(safeSub(entryPrice, closingPrice), qty), multiplier/ 1e10) / 1e16 ; 
        }
        
    }

    function calculateCollateral (uint256 limitPrice, uint256 tradePrice, uint256 qty, bool side, bytes32 futuresContractHash) view returns (uint256) // 1e8
    {
        uint256 multiplier = futuresContracts[futuresContractHash].multiplier;
        uint256 fundingCost;
        uint256 collateral;

        if (side)
        {    
            //fundingCost = calculateFundingCost(tradePrice, qty, fundingBlocks, futuresContractHash);
            collateral = safeMul(safeMul(safeSub(tradePrice, limitPrice), qty), multiplier / 1e10) / 1e16;

            return collateral; //safeAdd(collateral, fundingCost);
        }
        else
        {
            //fundingCost = calculateFundingCost(tradePrice, qty, fundingBlocks, futuresContractHash);
            collateral = safeMul(safeMul(safeSub(limitPrice, tradePrice), qty), multiplier / 1e10) / 1e16;
            
            return collateral; // safeAdd(collateral, fundingCost);
        }         
    }

    function calculateFundingCost (uint256 price, uint256 qty, uint256 fundingBlocks, bytes32 futuresContractHash) returns (uint256) // 1e8
    {
        uint256 fundingRate = futuresContracts[futuresContractHash].fundingRate;
        uint256 multiplier = futuresContracts[futuresContractHash].multiplier;

        uint256 fundingCost = safeMul(safeMul(safeMul(fundingBlocks, fundingRate), safeMul(qty, price)/1e8)/1e8, multiplier/1e10)/1e18
        ;

        return fundingCost;  
    }

    function calculateFee (uint256 qty, uint256 tradePrice, uint256 fee, bytes32 futuresContractHash) returns (uint256)
    {
        return safeMul(calculateTradeValue(qty, tradePrice, futuresContractHash), fee / 1e10) / 1e18;
    }


    function checkEnoughBalance (uint256 limitPrice, uint256 tradePrice, uint256 qty, bool side, uint256 fee, uint256 gasFee, bytes32 futuresContractHash, uint256 availableBalance) view returns (bool)
    {
        
        uint256 multiplier = futuresContracts[futuresContractHash].multiplier;
        uint256 expirationBlock = futuresContracts[futuresContractHash].expirationBlock;

        uint256 tradeFee = calculateFee(qty, tradePrice, fee, futuresContractHash);
        uint256 collateral = calculateCollateral(limitPrice, tradePrice, qty, side, futuresContractHash);
        uint256 fundingCost = calculateFundingCost(tradePrice, qty, safeSub(expirationBlock, min(block.number, expirationBlock)), futuresContractHash);

        if (safeAdd(
                safeMul(
                    safeAdd(
                        collateral, 
                        tradeFee
                    ),
                    1e10
                ),                     
                safeAdd(
                    gasFee,
                    safeMul(
                        fundingCost,
                        1e10
                    )                        
                ) 
            ) > availableBalance)
        {
            return false;
        }

        return true;
    }  

      

    // Executes multiple trades in one transaction, saves gas fees
    function batchFuturesTrade(
        uint8[2][] v,
        bytes32[4][] rs,
        uint256[8][] tradeValues,
        address[2][] tradeAddresses,
        bool[] takerIsBuying,
        bytes32[] assetHash,
        uint256[5][] contractValues
    ) onlyAdmin
    {
        // perform trades
        for (uint i = 0; i < tradeAddresses.length; i++) {
            futuresTrade(
                v[i],
                rs[i],
                tradeValues[i],
                tradeAddresses[i],
                takerIsBuying[i],
                createFuturesContract(assetHash[i], contractValues[i][0], contractValues[i][1], contractValues[i][2], contractValues[i][3], contractValues[i][4])
            );
        }
    }

    


    // Update user balance
    function updateBalances (bytes32 futuresContract, address[2] addressValues, bytes32 positionHash, uint256[8] uintValues, bool[3] boolValues) private
    {
        /*
            addressValues
            [0] baseToken
            [1] user

            uintValues
            [0] qty
            [1] price
            [2] fee
            [3] profit
            [4] loss
            [5] balance
            [6] gasFee
            [7] reserve

            boolValues
            [0] newPostion
            [1] side
            [2] increase position

        */

        // pam = [fee value, collateral, fundignCost, payableFundingCost]                        
        uint256[3] memory pam = [
            safeAdd(calculateFee(uintValues[0], uintValues[1], uintValues[2], futuresContract) * 1e10, uintValues[6]), 
            0,
            0
        ];
               
        if (boolValues[0] || boolValues[2])  
        {
            if (pools[addressValues[1]]) return;
            // Position is new or position is increased
            if (boolValues[1])
            {
                pam[1] = calculateCollateral(futuresContracts[futuresContract].floorPrice, uintValues[1], uintValues[0], true, futuresContract);
            }
            else
            {
                pam[1] = calculateCollateral(futuresContracts[futuresContract].capPrice, uintValues[1], uintValues[0], false, futuresContract);
            }

            pam[2] = calculateFundingCost(uintValues[1], uintValues[0], safeSub(futuresContracts[futuresContract].expirationBlock, block.number+1), futuresContract);


            subBalanceAddReserve(addressValues[0], addressValues[1], pam[0], safeAdd(safeAdd(pam[1], pam[2]),1));         
            pam[2] = 0;
        } 
        else 
        {
            // Position exists, decreasing
            if (retrievePosition(positionHash)[2] == 0)
            {
                // original position was short
                pam[1] = calculateCollateral(futuresContracts[futuresContract].capPrice, retrievePosition(positionHash)[1], uintValues[0], false, futuresContract);                          
            }
            else
            {                            
                // original position was long
                pam[1] = calculateCollateral(futuresContracts[futuresContract].floorPrice, retrievePosition(positionHash)[1], uintValues[0], true, futuresContract);
            }

            pam[2] = calculateFundingCost(retrievePosition(positionHash)[1], uintValues[0], safeSub(futuresContracts[futuresContract].expirationBlock, retrievePosition(positionHash)[3]+2), futuresContract);   

            if (pools[addressValues[1]]) {
                pam[0] = 0;
                pam[1] = 0;
                pam[2] = 0;
            }

            if (uintValues[3] > 0) 
            {
                // profi > 0
                if (safeAdd(pam[0], pam[2]*1e10) <= safeMul(uintValues[3],1e10))
                {
                    addBalanceSubReserve(addressValues[0], addressValues[1], safeSub(safeMul(uintValues[3],1e10), safeAdd(pam[0], pam[2]*1e10)), safeAdd(pam[1], pam[2]));
                }
                else
                {
                    subBalanceSubReserve(addressValues[0], addressValues[1], safeSub(safeAdd(pam[0], pam[2]*1e10), safeMul(uintValues[3],1e10)), safeAdd(pam[1], pam[2]));
                }                
            } 
            else 
            {   
                // loss >= 0
                subBalanceSubReserve(addressValues[0], addressValues[1], safeAdd(safeMul(uintValues[4],1e10), safeAdd(pam[0], pam[2]*1e10)), safeAdd(pam[1], pam[2])); // deduct loss from user balance
            }     

        }          
        
        addBalance(addressValues[0], feeAccount, DMEX_Base(exchangeContract).balanceOf(addressValues[0], feeAccount), safeAdd(pam[0], pam[2]*1e10)); // send fee to feeAccount
    }

    function recordNewPosition (bytes32 positionHash, uint256 size, uint256 price, uint256 side, uint256 block) private
    {
        if (!validateUint128(size) || !validateUint64(price)) 
        {
            throw;
        }

        uint256 character = uint128(size);
        character |= price<<128;
        character |= side<<192;
        character |= block<<208;

        positions[positionHash] = character;
    }

    function retrievePosition (bytes32 positionHash) public view returns (uint256[4])
    {
        uint256 character = positions[positionHash];
        uint256 size = uint256(uint128(character));
        uint256 price = uint256(uint64(character>>128));
        uint256 side = uint256(uint16(character>>192));
        uint256 entryBlock = uint256(uint48(character>>208));

        return [size, price, side, entryBlock];
    }

    function updatePositionSize(bytes32 positionHash, uint256 size, uint256 price) private
    {
        uint256[4] memory pos = retrievePosition(positionHash);

        if (size > pos[0])
        {
            uint256 totalValue = safeAdd(safeMul(pos[0], pos[1]), safeMul(price, safeSub(size, pos[0])));

            // position is increasing in size
            recordNewPosition(
                positionHash, 
                size, 
                totalValue / size, 
                pos[2], 
                safeAdd(safeMul(safeMul(pos[0], pos[1]), pos[3]), safeMul(safeMul(price, safeSub(size, pos[0])), block.number)) / totalValue // pos[3]
            );
        }
        else
        {
            // position is decreasing in size
            recordNewPosition(
                positionHash, 
                size, 
                pos[1], 
                pos[2], 
                pos[3]
            );
        }        
    }

    function positionExists (bytes32 positionHash) internal view returns (bool)
    {
        if (retrievePosition(positionHash)[0] == 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }




    // This function allows the user to manually release collateral in case the oracle service does not provide the price during the inactivityReleasePeriod
    function forceReleaseReserve (bytes32 futuresContract, bool side, address user) public
    {   
        if (futuresContracts[futuresContract].expirationBlock == 0) throw;       
        if (futuresContracts[futuresContract].expirationBlock > block.number) throw;
        if (safeAdd(futuresContracts[futuresContract].expirationBlock, DMEX_Base(exchangeContract).getInactivityReleasePeriod()) > block.number) throw;  
        if (pools[user]) return;

        bytes32 positionHash = keccak256(this, user, futuresContract, side);
        if (retrievePosition(positionHash)[1] == 0) throw;    
  

        futuresContracts[futuresContract].broken = true;

        uint256[4] memory pos = retrievePosition(positionHash);
        FuturesContract cont = futuresContracts[futuresContract];
        address baseToken = futuresAssets[cont.asset].baseToken;

        uint256 reservedFunding = calculateFundingCost(pos[1], pos[0], safeSub(cont.expirationBlock, pos[3]+1), futuresContract);
        uint256 collateral;

        if (side)
        {
            collateral = calculateCollateral(cont.floorPrice, pos[1], pos[0], true, futuresContract);

            subReserve(
                baseToken, 
                user, 
                DMEX_Base(exchangeContract).getReserve(baseToken, user), 
                safeAdd(reservedFunding, collateral)
            ); 
        }
        else
        {         
            collateral = calculateCollateral(cont.capPrice, pos[1], pos[0], false, futuresContract);
               
            subReserve(
                baseToken, 
                user, 
                DMEX_Base(exchangeContract).getReserve(baseToken, user), 
                safeAdd(reservedFunding, collateral)
            ); 
        }

        updatePositionSize(positionHash, 0, 0);

        emit FuturesForcedRelease(futuresContract, side, user);

    }

    function addBalance(address token, address user, uint256 balance, uint256 amount) private
    {
        DMEX_Base(exchangeContract).setBalance(token, user, safeAdd(balance, amount));
    }

    function subBalance(address token, address user, uint256 balance, uint256 amount) private
    {
        DMEX_Base(exchangeContract).setBalance(token, user, safeSub(balance, amount));
    }

    function subBalanceAddReserve(address token, address user, uint256 subBalance, uint256 addReserve) private
    {
        DMEX_Base(exchangeContract).subBalanceAddReserve(token, user, subBalance, safeMul(addReserve, 1e10));
    }

    function addBalanceSubReserve(address token, address user, uint256 addBalance, uint256 subReserve) private
    {
        DMEX_Base(exchangeContract).addBalanceSubReserve(token, user, addBalance, safeMul(subReserve, 1e10));
    }

    function addBalanceAddReserve(address token, address user, uint256 addBalance, uint256 addReserve) private
    {
        DMEX_Base(exchangeContract).addBalanceAddReserve(token, user, addBalance, safeMul(addReserve, 1e10));
    }

    function subBalanceSubReserve(address token, address user, uint256 subBalance, uint256 subReserve) private
    {
        DMEX_Base(exchangeContract).subBalanceSubReserve(token, user, subBalance, safeMul(subReserve, 1e10));
    }

    function addReserve(address token, address user, uint256 reserve, uint256 amount) private
    {
        DMEX_Base(exchangeContract).setReserve(token, user, safeAdd(reserve, safeMul(amount, 1e10)));
    }

    function subReserve(address token, address user, uint256 reserve, uint256 amount) private 
    {
        DMEX_Base(exchangeContract).setReserve(token, user, safeSub(reserve, safeMul(amount, 1e10)));
    }


    function getMakerTakerBalances(address maker, address taker, address token) public view returns (uint256[4])
    {
        return [
            DMEX_Base(exchangeContract).balanceOf(token, maker),
            DMEX_Base(exchangeContract).getReserve(token, maker),
            DMEX_Base(exchangeContract).balanceOf(token, taker),
            DMEX_Base(exchangeContract).getReserve(token, taker)
        ];
    }

    function getMakerTakerPositions(bytes32 makerPositionHash, bytes32 makerInversePositionHash, bytes32 takerPosition, bytes32 takerInversePosition) public view returns (uint256[4][4])
    {
        return [
            retrievePosition(makerPositionHash),
            retrievePosition(makerInversePositionHash),
            retrievePosition(takerPosition),
            retrievePosition(takerInversePosition)
        ];
    }


    struct FuturesClosePositionValues {
        uint256 reserve;                // amount to be trade
        uint256 balance;                // holds maker profit value
        uint256 floorPrice;             // holds maker loss value
        uint256 capPrice;               // holds taker profit value
        uint256 closingPrice;           // holds taker loss value
        bytes32 futuresContract;        // the futures contract hash
        uint256 expirationBlock;        // the expiration block for the contract
        uint256 entryBlock;             // the entry block for the position
        uint256 collateral;             // reserved collateral
        uint256 reservedFunding;        // reserved funding cost
        uint256 payableFunding;         // spent funding cost
        uint256 totalPayable;
        uint256 settlePrice;
        uint256 lowerLimit;
        uint256 upperLimit;
        uint256 closingBlock;
    }


    function closeFuturesPosition(bytes32 futuresContract, bool side)
    {
        closeFuturesPositionInternal(futuresContract, side, msg.sender);
    }

    function closeFuturesPositionInternal (bytes32 futuresContract, bool side, address user) private returns (bool)
    {
        bytes32 positionHash = keccak256(this, user, futuresContract, side);        

        if (futuresContracts[futuresContract].closed == false && futuresContracts[futuresContract].expirationBlock != 0) throw; // contract not yet settled
        if (retrievePosition(positionHash)[1] == 0) throw; // position not found
        if (retrievePosition(positionHash)[0] == 0) throw; // position already closed


        uint256 profit;
        uint256 loss;

        address baseToken = futuresAssets[futuresContracts[futuresContract].asset].baseToken;
        uint256[2] memory marginInfo = getLowerUpperLimit(futuresContract);

        FuturesClosePositionValues memory v = FuturesClosePositionValues({
            reserve         : DMEX_Base(exchangeContract).getReserve(baseToken, user),
            balance         : DMEX_Base(exchangeContract).balanceOf(baseToken, user),
            floorPrice      : futuresContracts[futuresContract].floorPrice,
            capPrice        : futuresContracts[futuresContract].capPrice,
            closingPrice    : futuresContracts[futuresContract].closingPrice,
            futuresContract : futuresContract,
            expirationBlock : futuresContracts[futuresContract].expirationBlock,
            entryBlock      : retrievePosition(positionHash)[3],
            collateral      : 0,
            reservedFunding : 0,
            payableFunding  : 0,
            totalPayable    : 0,
            settlePrice     : 0,
            lowerLimit      : marginInfo[0],
            upperLimit      : marginInfo[1],
            closingBlock    : futuresContracts[futuresContract].closingBlock
        });

        
        //uint256 fee = calculateFee(retrievePosition(positionHash)[0], v.closingPrice, takerFee, futuresContract);
        uint256 fee = 0;//calculateFee(retrievePosition(positionHash)[0], v.closingPrice, takerFee, futuresContract);


        // close long position
        if (side == true)
        {     
            if (!pools[user]) {
                v.collateral = calculateCollateral(v.floorPrice, retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], true, v.futuresContract);
                v.reservedFunding = calculateFundingCost(retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], safeSub(v.expirationBlock, v.entryBlock+1), futuresContract);
                v.payableFunding = calculateFundingCost(retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], safeSub(min(v.expirationBlock, v.closingBlock), v.entryBlock+1), futuresContract);


                subReserve(
                    baseToken, 
                    user, 
                    v.reserve, 
                    safeAdd(v.collateral, v.reservedFunding)
                );  
            }
            
            
            v.totalPayable = v.payableFunding; //min(safeAdd(v.collateral, v.reservedFunding), safeAdd(fee, v.payableFunding));

            if (v.closingPrice > retrievePosition(positionHash)[1])
            {   
                // user made a profit
                if (pools[user]) {
                    v.settlePrice = min(v.closingPrice, v.capPrice);
                }
                else
                {
                    v.settlePrice = v.closingPrice;
                }

                profit = calculateProfit(v.settlePrice, retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], futuresContract, false);
          
                if (profit > v.totalPayable)
                {
                    addBalance(baseToken, user, v.balance, safeSub(safeMul(profit, 1e10), safeMul(v.totalPayable, 1e10))); 
                }
                else
                {
                    subBalance(baseToken, user, v.balance, safeSub(safeMul(v.totalPayable, 1e10), safeMul(profit, 1e10))); 
                }
            }
            else
            {
                // user made a loss
                if (!pools[user]) {
                    v.settlePrice = v.closingPrice <= v.lowerLimit ? v.floorPrice : v.closingPrice;
                }
                else
                {
                    v.settlePrice = v.closingPrice;
                }

                loss = calculateLoss(v.settlePrice, retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], futuresContract, false);  

                subBalance(baseToken, user, v.balance, safeAdd(safeMul(loss, 1e10), safeMul(v.totalPayable, 1e10))); 

            }
        }   
        // close short position 
        else
        {
            if (!pools[user]) {
                v.collateral = calculateCollateral(v.capPrice, retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], false, v.futuresContract);
                v.reservedFunding = calculateFundingCost(retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], safeSub(v.expirationBlock, v.entryBlock+1), futuresContract);
                v.payableFunding = calculateFundingCost(retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], safeSub(min(v.expirationBlock, v.closingBlock), v.entryBlock+1), futuresContract);


                subReserve(
                    baseToken, 
                    user,  
                    v.reserve, 
                    safeAdd(v.collateral, v.reservedFunding)
                );
            }

            v.totalPayable = v.payableFunding;//min(safeAdd(v.collateral, v.reservedFunding), safeAdd(fee, v.payableFunding));

            if (v.closingPrice < retrievePosition(positionHash)[1])
            {
                // user made a profit
                if (pools[user]) {
                    v.settlePrice = max(v.closingPrice, v.floorPrice);
                }
                else
                {
                    v.settlePrice = v.closingPrice;
                }

                profit = calculateProfit(v.settlePrice, retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], futuresContract, true);
 
                if (profit > v.totalPayable)
                {
                    addBalance(baseToken, user, v.balance, safeSub(safeMul(profit, 1e10), safeMul(v.totalPayable, 1e10))); 
                }
                else
                {
                    subBalance(baseToken, user, v.balance, safeSub(safeMul(v.totalPayable, 1e10), safeMul(profit, 1e10))); 
                }

            }
            else
            {
                // user made a loss
                if (!pools[user]) {
                    v.settlePrice = v.closingPrice >= v.upperLimit ? v.capPrice : v.closingPrice;
                }
                else
                {
                    v.settlePrice = v.closingPrice;
                }

                loss = calculateLoss(v.settlePrice, retrievePosition(positionHash)[1], retrievePosition(positionHash)[0], futuresContract, true);  

                subBalance(baseToken, user, v.balance, safeAdd(safeMul(loss, 1e10), safeMul( v.totalPayable, 1e10)));

            }
        }  

        addBalance(baseToken, feeAccount, DMEX_Base(exchangeContract).balanceOf(baseToken, feeAccount), safeMul(v.totalPayable, 1e10)); // send fee to feeAccount
        

        updatePositionSize(positionHash, 0, 0);        

        emit FuturesPositionClosed(positionHash, v.closingPrice);

        return true;
    }

    function getLowerUpperLimit(bytes32 futuresContract) public view returns (uint256[2])
    {
        uint256 maintenanceMargin = getMaintenanceMargin(futuresContract);

        uint256 floorPrice = futuresContracts[futuresContract].floorPrice;
        uint256 capPrice = futuresContracts[futuresContract].capPrice;

        uint256[2] memory marginInfo = extractMargin(floorPrice, capPrice);
        
        uint256 lowerLimit =    safeAdd(
                                    floorPrice, 
                                    safeMul(
                                        marginInfo[0], 
                                        maintenanceMargin / marginInfo[1]
                                    ) / 1e18
                                );


        uint256 upperLimit =    safeSub(
                                    capPrice, 
                                    safeMul(
                                        marginInfo[0], 
                                        maintenanceMargin / marginInfo[1]
                                    ) / 1e18
                                );

        return [lowerLimit, upperLimit];
    }

    function extractMargin (uint256 floorPrice, uint256 capPrice) public view returns (uint256[2])
    {
        uint256 halfRange = safeSub(capPrice, floorPrice)/2;
        return [safeAdd(halfRange, floorPrice), safeAdd(halfRange, floorPrice) / halfRange];    
    }

    // closes position for user
    function closeFuturesPositionForUser (bytes32 futuresContract, bool side, address user) onlyAdmin
    {
        closeFuturesPositionInternal(futuresContract, side, user);
    }

    // Settle positions for closed contracts
    function batchSettlePositions (
        bytes32[] futuresContracts,
        bool[] sides,
        address[] users
    ) onlyAdmin {
        
        for (uint i = 0; i < futuresContracts.length; i++) 
        {
            closeFuturesPositionForUser(futuresContracts[i], sides[i], users[i]);
        }
    }

    // Returns the smaller of two values
    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }

    // Returns the largest of the two values
    function max(uint a, uint b) private pure returns (uint) {
        return a > b ? a : b;
    }
}