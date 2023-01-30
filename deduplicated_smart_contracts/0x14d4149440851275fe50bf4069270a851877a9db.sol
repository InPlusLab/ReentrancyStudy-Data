/**

 *Submitted for verification at Etherscan.io on 2019-03-14

*/



pragma solidity ^0.4.25;



/*******************************************************************************

 *

 * Copyright (c) 2019 Decentralization Authority MDAO.

 * Released under the MIT License.

 *

 * ZeroDelta - The Official ZeroCache (DEX) Decentralized Exchange

 *

 *             This is the first non-custodial, blockchain exchange. ALL tokens

 *             are held securely in ZeroCache; plus require authorized signatures

 *             of both the MAKER and TAKER for ANY and ALL token transfers.

 *

 * Version 19.3.14

 *

 * https://d14na.org

 * [email protected]

 */





/*******************************************************************************

 *

 * SafeMath

 */

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}





/*******************************************************************************

 *

 * ECRecovery

 *

 * Contract function to validate signature of pre-approved token transfers.

 * (borrowed from LavaWallet)

 */

contract ECRecovery {

    function recover(bytes32 hash, bytes sig) public pure returns (address);

}





/*******************************************************************************

 *

 * ERC Token Standard #20 Interface

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

 */

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}





/*******************************************************************************

 *

 * ApproveAndCallFallBack

 *

 * Contract function to receive approval and execute function in one call

 * (borrowed from MiniMeToken)

 */

contract ApproveAndCallFallBack {

    function approveAndCall(address spender, uint tokens, bytes data) public;

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}





/*******************************************************************************

 *

 * Owned contract

 */

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }



    function acceptOwnership() public {

        require(msg.sender == newOwner);



        emit OwnershipTransferred(owner, newOwner);



        owner = newOwner;



        newOwner = address(0);

    }

}





/*******************************************************************************

 *

 * Zer0netDb Interface

 */

contract Zer0netDbInterface {

    /* Interface getters. */

    function getAddress(bytes32 _key) external view returns (address);

    function getBool(bytes32 _key)    external view returns (bool);

    function getBytes(bytes32 _key)   external view returns (bytes);

    function getInt(bytes32 _key)     external view returns (int);

    function getString(bytes32 _key)  external view returns (string);

    function getUint(bytes32 _key)    external view returns (uint);



    /* Interface setters. */

    function setAddress(bytes32 _key, address _value) external;

    function setBool(bytes32 _key, bool _value) external;

    function setBytes(bytes32 _key, bytes _value) external;

    function setInt(bytes32 _key, int _value) external;

    function setString(bytes32 _key, string _value) external;

    function setUint(bytes32 _key, uint _value) external;



    /* Interface deletes. */

    function deleteAddress(bytes32 _key) external;

    function deleteBool(bytes32 _key) external;

    function deleteBytes(bytes32 _key) external;

    function deleteInt(bytes32 _key) external;

    function deleteString(bytes32 _key) external;

    function deleteUint(bytes32 _key) external;

}





/*******************************************************************************

 *

 * ZeroCache Interface

 */

contract ZeroCacheInterface {

    function balanceOf(address _token, address _owner) public constant returns (uint balance);

    function transfer(address _to, address _token, uint _tokens) external returns (bool success);

    function transfer(address _token, address _from, address _to, uint _tokens, address _staekholder, uint _staek, uint _expires, uint _nonce, bytes _signature) external returns (bool success);

}





/*******************************************************************************

 *

 * @notice ZeroDelta

 *

 * @dev Decentralized Exchange (DEX) exclusively for use with ZeroCache.

 */

contract ZeroDelta is Owned {

    using SafeMath for uint;



    /* Initialize predecessor contract. */

    address private _predecessor;



    /* Initialize successor contract. */

    address private _successor;



    /* Initialize revision number. */

    uint private _revision;



    /* Initialize Zer0net Db contract. */

    Zer0netDbInterface private _zer0netDb;



    /**

     * Order Structure

     *

     * Stores the MAKER's desired trade parameters; along with their

     * ZeroCache transfer signature.

     *

     * NOTE: Transfer Signatures are required to move ANY funds within

     * the ZeroCache that come from a 3rd-party.

     */

    struct Order {

        address maker;

        bytes makerSig;

        address tokenRequest;

        uint amountRequest;

        address tokenOffer;

        uint amountOffer;

        uint expires;

        uint nonce;

        bool canPartialFill;

        uint amountFilled; // of `tokenRequest`

    }



    /**

     * Orders

     */

    mapping (bytes32 => Order) private _orders;



    /**

     * Trade Structure

     * 

     * NOTE: Transfer Signatures are required to move ANY funds within

     * the ZeroCache that come from a 3rd-party.

     */

    struct Trade {

        bytes32 orderId;

        address taker;

        bytes takerSig;

        uint paymentAmount;

        address staekholder;

        uint staek;

    }



    /**

     * Trades

     */

    mapping (bytes32 => Trade) private _trades;



    /* Maximum order expiration time. */

    // NOTE: 10,000 blocks = ~1 3/4 days

    uint private _MAX_ORDER_EXPIRATION = 10000;



    /* Set namespace. */

    string private _namespace = 'zerodelta';



    event OrderCancel(

        bytes32 indexed marketId,

        bytes32 orderId

    );



    event OrderRequest(

        bytes32 indexed marketId,

        bytes32 orderId

    );



    event TradeComplete(

        bytes32 indexed marketId,

        bytes32 tradeId

    );



    /***************************************************************************

     *

     * Constructor

     */

    constructor() public {

        /* Initialize Zer0netDb (eternal) storage database contract. */

        // NOTE We hard-code the address here, since it should never change.

        _zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);



        /* Initialize (aname) hash. */

        bytes32 hash = keccak256(abi.encodePacked('aname.', _namespace));



        /* Retrieve value from Zer0net Db. */

        _predecessor = _zer0netDb.getAddress(hash);



        /* Verify predecessor address. */

        if (_predecessor != 0x0) {

            /* Retrieve the last revision number (if available). */

            uint lastRevision = ZeroDelta(_predecessor).getRevision();



            /* Set (current) revision number. */

            _revision = lastRevision + 1;

        }

    }



    /**

     * @dev Only allow access to an authorized Zer0net administrator.

     */

    modifier onlyAuthBy0Admin() {

        /* Verify write access is only permitted to authorized accounts. */

        require(_zer0netDb.getBool(keccak256(

            abi.encodePacked(msg.sender, '.has.auth.for.', _namespace))) == true);



        _;      // function code is inserted here

    }



    /**

     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER

     */

    function () public payable {

        /* Cancel this transaction. */

        revert('Oops! Direct payments are NOT permitted here.');

    }





    /***************************************************************************

     *

     * ACTIONS

     *

     */



    /**

     * Create (On-chain) Order

     *

     * Allows a MARKET MAKER to place a new trade request on-chain.

     *

     * The maker's authorization signature is also stored on-chain,

     * which is required when fulfilling an order for a TAKER.

     *

     * Due to the "abolsute" security design of the ZeroCache; partial

     * fills can ONLY be supported by supplying 2x the order volume,

     * until the entire order has been FILLED. MAKERs can enable/disable

     * partial fills, by setting a flag.

     *

     * NOTE: Required to support fully decentralized (no 3rd-party)

     *       token transactions.

     */

    function createOrder(

        address _tokenRequest,

        uint _amountRequest,

        address _tokenOffer,

        uint _amountOffer,

        uint _expires,

        uint _nonce,

        bytes _makerSig,

        bool _canPartialFill

    ) external returns (bool success) {

        /* Create new order request. */

        bytes32 orderId = _createOrderRequest(

            msg.sender, // Market Maker

            _tokenRequest,

            _amountRequest,

            _tokenOffer,

            _amountOffer,

            _expires, // NOTE: This value is unchecked (NOT SAFE).

            _nonce // NOTE: This value is unchecked (NOT SAFE).

        );



        /* Build order. */

        Order memory order = Order(

            msg.sender, // Market Maker

            _makerSig,

            _tokenRequest,

            _amountRequest,

            _tokenOffer,

            _amountOffer,

            _expires,

            _nonce,

            _canPartialFill,

            uint(0) // amountFilled

        );



        /* Save order to storage. */

        _orders[orderId] = order;



        /* Calculate transfer hash. */

        bytes32 transferHash = _calcTransferHash(

            _tokenOffer,

            _amountOffer,

            address(0x0), // staekholder

            uint(0), // staek amount

            _expires,

            _nonce

        );



        /* Validate request has authorized signature. */

        // NOTE: A valid transfer signature is required for ZeroCache.

        bool requestHasAuthSig = _requestHasAuthSig(

            msg.sender, // Market Maker

            transferHash,

            _expires,

            _makerSig

        );

        

        /* Validate authorization. */

        if (!requestHasAuthSig) {

            revert('Oops! Your order has an INVALID signature.');

        }



        /* Broadcast event. */

        emit OrderRequest(

            _calcMarketId(

                _tokenRequest, 

                _tokenOffer

            ),

            orderId

        );



        /* Return success. */

        return true;

    }

    

    /**

     * Create Order Request

     *

     * Will validate all parameters and return a new order id.

     *

     * NOTE: Order Id creation follows the scheme common in DEXs

     *       (eg. EtherDelta / ForkDelta).

     */

    function _createOrderRequest(

        address _maker,

        address _tokenRequest,

        uint _amountRequest,

        address _tokenOffer,

        uint _amountOffer,

        uint _expires,

        uint _nonce

    ) private view returns (bytes32 orderId) {

        /* Validate expiration. */

        if (_expires > block.number.add(_MAX_ORDER_EXPIRATION)) {

            revert('Oops! You entered an INVALID expiration.');

        }



        /* Retrieve maker balance from ZeroCache. */

        uint makerBalance = _zeroCache()

            .balanceOf(_tokenOffer, _maker);



        /* Validate MAKER token balance. */

        if (_amountOffer > makerBalance) {

            revert('Oops! Maker DOES NOT have enough tokens.');

        }



        /* Calculate order id. */

        orderId = keccak256(abi.encodePacked(

            address(this),

            _tokenRequest,

            _amountRequest,

            _tokenOffer,

            _amountOffer,

            _expires,

            _nonce

        ));

    }



    /**

     * Cancel (On-chain) Order

     *

     * Allows market makers to discontinue a previously placed

     * on-chain order.

     *

     * NOTE: This procedure disables an active order by FILLING

     *       the available volume to the order's FULL capacity;

     *       thereby reducing the avaiable trade volume to ZERO.

     */

    function cancelOrder(

        bytes32 _orderId

    ) external {

        /* Validate MAKER authorized request. */

        if (msg.sender != _orders[_orderId].maker) {

            revert('Oops! Your request is NOT authorized.');

        }



        /* Fill order. */

        _setAmountFilled(

            _orderId, 

            _orders[_orderId].amountRequest

        );



        /* Broadcast event. */

        emit OrderCancel(

            _calcMarketId(

                _orders[_orderId].tokenRequest, 

                _orders[_orderId].tokenOffer

            ),

            _orderId

        );

    }



    /**

     * (On-chain <> On-chain) Trade Simulation

     *

     * Validates each of the trade/order parameters and returns a

     * success value, based on the result of an "actual" trade

     * occuring on the network at that (current block) time.

     *

     * NOTE: A successful result DOES NOT guarantee that the trade

     *       will be successful in subsequent blocks (as available

     *       volumes can change due to external token activites).

     */

    function tradeSimulation(

        bytes32 _orderId,

        bytes _takerSig,

        uint _paymentAmount,

        address _staekholder,

        uint _staek

    ) external view returns (bool success) {

        /* Initialize success. */

        success = true;

        

        // TODO Validate signature

        if (_takerSig[0] == 0x0 && _takerSig[0] != 0x0) {

            /* Set flag. */

            success = false;

        }



        // TODO Validate staekholder

        if (_staekholder == 0x0 && _staekholder != 0x0) {

            /* Set flag. */

            success = false;

        }



        // TODO Validate staek

        if (_staek == 0 && _staek != 0) {

            /* Set flag. */

            success = false;

        }



        /* Retrieve available volume. */

        uint availableVolume = getAvailableVolume(_orderId);



        /* Validate available (on-chain) volume. */

        if (_paymentAmount > availableVolume) {

            /* Set flag. */

            success = false;

        }

    }



    /**

     * (On-chain <> On-chain) Trade

     *

     * Executed 100% on-chain by both the MAKER and TAKER,

     * which allows for a FULLY decentralized trade experience.

     *

     * 1. Maker creates an on-chain `order` request, specifying

     *    their desired trade parameters.

     *

     * 2. Taker executes an on-chain transaction to fill any available

     *    volume from the maker's active order.

     *

     * NOTE: The is the MOST inefficient, timely, and costly of all the

     *       available trade procedures. However, this trade option

     *       WILL ALWAYS serve as the exchange's DEFAULT recommendation,

     *       as it requires ZERO intervention from ANY centralized

     *       (or 3rd-party) service(s); guaranteeing the MAXIMUM safety

     *       and security to both the maker and taker of the transaction.

     */

    function trade(

        bytes32 _orderId,

        bytes _takerSig,

        uint _paymentAmount,

        address _staekholder,

        uint _staek

    ) external returns (bool success) {

        /* Validate order. */

        if (_orders[_orderId].maker == 0x0) {

            revert('Oops! That order DOES NOT exist.');

        }



        /* Initialize taker. */

        address taker = msg.sender;

        

        /* Create new trade request. */

        bytes32 tradeId = _createTradeRequest(

            _orderId,

            taker,

            _paymentAmount,

            _staekholder,

            _staek

        );



        /* Build new (trade) request. */

        Trade memory request = Trade(

            _orderId,

            taker,

            _takerSig,

            _paymentAmount,

            _staekholder,

            _staek

        );



        /* Save trade to trades. */

        _trades[tradeId] = request;



        /* Retrieve available volume. */

        uint availableVolume = getAvailableVolume(_orderId);



        /* Validate available (trade) volume. */

        if (_paymentAmount > availableVolume) {

            revert('Oops! Amount to be paid EXCEEDS available volume.');

        }



        /* Request atomic trade. */

        return _trade(tradeId);

    }



    /**

     * Create Trade Request

     *

     * Will validate all parameters and return a new trade id.

     */

    function _createTradeRequest(

        bytes32 _orderId,

        address _taker,

        uint _paymentAmount,

        address _staekholder,

        uint _staek

    ) private view returns (bytes32 tradeId) {

        // TODO Do some validation before creating new id.



        /* Calculate trade id. */

        tradeId = keccak256(abi.encodePacked(

            address(this),

            _orderId,

            _taker,

            _paymentAmount,

            _staekholder,

            _staek

        ));

    }



    /**

     * (On-chain <> Off-chain) RELAYED | MARKET Trade

     *

     * Allows for ETH-less on-chain order fulfillment for takers.

     */

    // function trade(

    //     address _maker,

    //     address _taker,

    //     bytes _takerSig,

    //     address _staekholder,

    //     uint _staek,

    //     address _tokenRequest,

    //     uint _amountRequest,

    //     address _tokenOffer,

    //     uint _amountOffer,

    //     uint _expires,

    //     uint _nonce,

    //     uint _paymentAmount

    // ) external returns (bool success) {

    //     /* Retrieve available volume. */

    //     uint availableVolume = getAvailableVolume(_orderId);



    //     /* Validate available (trade) volume. */

    //     if (_paymentAmount > availableVolume) {

    //         revert('Oops! Amount requested EXCEEDS available volume.');

    //     }



    //     /* Calculate order id. */

    //     bytes32 orderId = keccak256(abi.encodePacked(

    //         address(this),

    //         _tokenGet,

    //         _amountRequest,

    //         _tokenGive,

    //         _amountGive,

    //         _expires,

    //         _nonce

    //     ));



    //     /* Validate maker. */

    //     bytes32 makerSig = keccak256(abi.encodePacked(

    //         '\x19Ethereum Signed Message:\n32', orderId));



    //     /* Calculate trade hash. */

    //     bytes32 tradeHash = keccak256(abi.encodePacked(

    //         _maker,

    //         orderId,

    //         _staekholder,

    //         _staek,

    //         _amount

    //     ));



    //     /* Validate maker. */

    //     bytes32 takerSig = keccak256(abi.encodePacked(

    //         '\x19Ethereum Signed Message:\n32', tradeHash));



    //     /* Retrieve authorized taker. */

    //     address authorizedTaker = _ecRecovery().recover(

    //         takerSig, _takerSig);



    //     /* Validate taker. */

    //     if (authorizedTaker != _taker) {

    //         revert('Oops! Taker signature is NOT valid.');

    //     }



    //     /* Add volume to reduce remaining order availability. */

    //     _orderFills[_maker][orderId] =

    //         _orderFills[_maker][orderId].add(_amount);



    //     /* Request atomic trade. */

    //     _trade(

    //         _maker,

    //         _taker,

    //         _tokenGet,

    //         _amountRequest,

    //         _tokenGive,

    //         _amountGive,

    //         _amount

    //     );



    //     /* Return success. */

    //     return true;

    // }



    /**

     * (Off-chain <> Off-chain) Trade

     *

     * Utilizes a CENTRALIZED order book to manage off-chain trades.

     *

     * 1. Maker provides a signed `orderId` along with desired

     *    order/trade parameters.

     *

     * 2. Taker provides a signed `tradeId` along with desired

     *    trade/fulfillment parameters.

     */

    // function trade(

    //     address _maker,

    //     bytes _makerSig,

    //     address _taker,

    //     bytes _takerSig,

    //     address _staekholder,

    //     uint _staek,

    //     address _tokenRequest,

    //     uint _amountRequest,

    //     address _tokenOffer,

    //     uint _amountOffer,

    //     uint _paymentAmount,

    //     uint _expires,

    //     uint _nonce

    // ) external returns (bool success) {

    //     /* Calculate order id. */

    //     bytes32 orderId = keccak256(abi.encodePacked(

    //         address(this),

    //         _tokenGet,

    //         _amountRequest,

    //         _tokenGive,

    //         _amountGive,

    //         _expires,

    //         _nonce

    //     ));



    //     /* Validate maker. */

    //     bytes32 makerSig = keccak256(abi.encodePacked(

    //         '\x19Ethereum Signed Message:\n32', orderId));



    //     /* Retrieve authorized maker. */

    //     address authorizedMaker = _ecRecovery().recover(

    //         makerSig, _makerSig);



    //     /* Validate maker. */

    //     if (authorizedMaker != _maker) {

    //         revert('Oops! Maker signature is NOT valid.');

    //     }



    //     /* Calculate trade hash. */

    //     bytes32 tradeHash = keccak256(abi.encodePacked(

    //         _maker,

    //         orderId,

    //         _staekholder,

    //         _staek,

    //         _paymentAmount

    //     ));



    //     /* Validate maker. */

    //     bytes32 takerSig = keccak256(abi.encodePacked(

    //         '\x19Ethereum Signed Message:\n32', tradeHash));



    //     /* Retrieve authorized taker. */

    //     address authorizedTaker = _ecRecovery().recover(

    //         takerSig, _takerSig);



    //     /* Validate taker. */

    //     if (authorizedTaker != _taker) {

    //         revert('Oops! Taker signature is NOT valid.');

    //     }



    //     /* Request atomic trade. */

    //     _trade(

    //         _maker,

    //         _makerSig,

    //         _taker,

    //         _takerSig,

    //         _staekholder,

    //         _staek,

    //         _tokenGet,

    //         _amountRequest,

    //         _tokenGive,

    //         _amountGive,

    //         _paymentAmount,

    //         _expires,

    //         _nonce

    //     );



    //     /* Return success. */

    //     return true;

    // }



    /**

     * (Off-chain <> Off-chain) RELAYED | MARKET Trade

     *

     * Allows a taker to fill an order at the BEST market price.

     *

     * NOTE: This will support the ability to execute MULTIPLE

     *       trades (on a taker's behalf), while insuring that

     *       the authorized staekholder is limited in the volume

     *       they can trade (on a taker's behalf).

     */

    // function trade(

    //     address _maker,

    //     bytes _makerSig,

    //     address _taker,

    //     bytes _takerSig,

    //     address _staekholder,

    //     uint _staek,

    //     address _tokenRequest,

    //     uint _amountRequest,

    //     address _tokenOffer,

    //     uint _amountOffer,

    //     uint _paymentAmount,

    //     uint _expires,

    //     uint _nonce

    // ) external returns (bool success) {

    //     /* Validate boost fee and pay (if necessary). */

    //     // if (_staekholder != 0x0 && _staek > 0) {

    //     //     _addStaek(_taker, _staekholder, _staek);

    //     // }



    //     /* Request OFF-CHAIN <> OFF-CHAIN trade. */

    //     trade(

    //         _maker,

    //         _makerSig,

    //         _taker,

    //         _takerSig,

    //         _staekholder,

    //         _staek,

    //         _tokenGet,

    //         _amountRequest,

    //         _tokenGive,

    //         _amountGive,

    //         _paymentAmount,

    //         _expires,

    //         _nonce

    //     );



    //     /* Return success. */

    //     return true;

    // }



    /**

     * (Atomic) Trade

     *

     * Executes an atomic trade between the maker and taker.

     *

     * 1. We TEMPORARILY transfer a pre-authorized `amountGive` quantity

     *    of the MAKER's tokens here from their ZeroCache.

     * 

     * 2. We calculate `_paymentAmount` of the TAKER's trade request, 

     *    immediately return the unused balance (if any) back to the MAKER.

     * 

     * 3. We then transfer the reserved balance to the TAKER, 

     *    completing the transaction.

     *

     * NOTE: Due to restrictions in ZeroCache "signature-based" design security; 

     *       it is recommended that a MAKER preserve 2x their `amountGive` within

     *       ZeroCache, to guarantee the ability to fill the order's entire volume.

     */

    function _trade(

        bytes32 _tradeId

    ) private returns (bool success) {

        /* Set order id. */

        bytes32 orderId = _trades[_tradeId].orderId;

    

        /* Validate permission to partial fill. */

        _canPartialFill(

            _orders[orderId].canPartialFill, 

            _orders[orderId].amountOffer, 

            _trades[_tradeId].paymentAmount

        );



        /* Calculate the amount recieved by TAKER. */

        uint amountTaken = _orders[orderId].amountOffer

            .mul(_trades[_tradeId].paymentAmount)

            .div(_orders[orderId].amountRequest);



        /* Calculate new fill amount. */

        uint newFillAmount = _orders[orderId].amountFilled

            .add(_trades[_tradeId].paymentAmount);



        /* Set amount filled. */

        _setAmountFilled(orderId, newFillAmount);



        /* Transer tokens from MAKER to ZeroDelta. */

        // NOTE: This is a PRE-AUTHORIZED transfer request using `makerSig`.

        _transferFromMaker(orderId);



        /* Transfer unneeded balance back to MAKER. */

        _transferChangeToMaker(

            orderId, 

            amountTaken

        );



        /* Transer (payment) tokens from TAKER to MAKER. */

        _transferFromTakerToMaker(

            _tradeId,

            _trades[_tradeId].paymentAmount

        );



        /* Transfer tokens from ZeroDelta to TAKER. */

        // WARNING This MUST be the LAST transfer to safeguard against

        // a re-entry attack.

        // NOTE: This reduces ZeroDelta's token holdings back to ZERO.

        _transferToTaker(

            _tradeId, 

            amountTaken

        );



        /* Broadcast event. */

        emit TradeComplete(

            _calcMarketId(

                _orders[orderId].tokenRequest, 

                _orders[orderId].tokenOffer

            ),

            _tradeId

        );



        /* Return success. */

        return true;

    }





    /***************************************************************************

     *

     * GETTERS

     *

     */



    /**

     * Get Order

     *

     * Retrieves the FULL details of an order.

     */

    function getOrder(

        bytes32 _orderId

    ) public view returns (

        address maker,

        bytes makerSig,

        address tokenRequest,

        uint amountRequest,

        address tokenOffer,

        uint amountOffer,

        uint expires,

        uint nonce,

        bool canPartialFill,

        uint amountFilled

    ) {

        /* Retrieve maker. */

        maker = _orders[_orderId].maker;



        /* Retrieve maker signature. */

        makerSig = _orders[_orderId].makerSig;



        /* Retrieve token requested. */

        tokenRequest = _orders[_orderId].tokenRequest;



        /* Retrieve amount requested. */

        amountRequest = _orders[_orderId].amountRequest;



        /* Retrieve token offered. */

        tokenOffer = _orders[_orderId].tokenOffer;



        /* Retrieve amount offered. */

        amountOffer = _orders[_orderId].amountOffer;



        /* Retrieve expiration. */

        expires = _orders[_orderId].expires;



        /* Retrieve nonce. */

        nonce = _orders[_orderId].nonce;



        /* Retrieve partial fill flag. */

        canPartialFill = _orders[_orderId].canPartialFill;



        /* Retrieve amount (has been) filled. */

        // NOTE: This is of `tokenRequest`.

        amountFilled = _orders[_orderId].amountFilled;

    }



    /**

     * Get Trade

     *

     * Retrieves the FULL details of a successful trade.

     */

    function getTrade(

        bytes32 _tradeId

    ) public view returns (

        bytes32 orderId,

        address taker,

        uint paymentAmount,

        address staekholder,

        uint staek

    ) {

        /* Retrieve order id. */

        orderId = _trades[_tradeId].orderId;



        /* Retrieve taker. */

        taker = _trades[_tradeId].taker;



        /* Retrieve payment amount. */

        paymentAmount = _trades[_tradeId].paymentAmount;



        /* Retrieve staekholder. */

        staekholder = _trades[_tradeId].staekholder;



        /* Retrieve staek. */

        staek = _trades[_tradeId].staek;

    }



    /**

     * Get Available (Order) Volume

     */

    function getAvailableVolume(

        bytes32 _orderId

    ) public view returns (uint availableVolume) {

        /* Validate expiration. */

        if (block.number > _orders[_orderId].expires) {

            availableVolume = 0;

        } else {

            /* Retrieve maker balance from ZeroCache. */

            uint makerBalance = _zeroCache()

                .balanceOf(

                    _orders[_orderId].tokenOffer, 

                    _orders[_orderId].maker

                );



            /* Calculate order (trade) balance. */

            uint orderBalance = _orders[_orderId].amountRequest

                .sub(_orders[_orderId].amountFilled);



            /* Calculate maker (trade) balance. */

            uint tradeBalance = makerBalance

                .mul(_orders[_orderId].amountRequest)

                .div(_orders[_orderId].amountOffer);



            /* Validate available volume. */

            if (orderBalance < tradeBalance) {

                availableVolume = orderBalance;

            } else {

                availableVolume = tradeBalance;

            }

        }

    }



    /**

     * Get Revision (Number)

     */

    function getRevision() public view returns (uint) {

        return _revision;

    }



    /**

     * Get Predecessor (Address)

     */

    function getPredecessor() public view returns (address) {

        return _predecessor;

    }



    /**

     * Get Successor (Address)

     */

    function getSuccessor() public view returns (address) {

        return _successor;

    }





    /***************************************************************************

     *

     * SETTERS

     *

     */



    /**

     * Set Successor

     *

     * This is the contract address that replaced this current instnace.

     */

    function setSuccessor(

        address _newSuccessor

    ) onlyAuthBy0Admin external returns (bool success) {

        /* Set successor contract. */

        _successor = _newSuccessor;



        /* Return success. */

        return true;

    }



    /**

     * Set (Volume) Amount Filled

     */

    function _setAmountFilled(

        bytes32 _orderId,

        uint _amountFilled

    ) private returns (bool success) {

        /* Set fill amount. */

        _orders[_orderId].amountFilled = _amountFilled;

        

        /* Return success. */

        return true;

    }





    /***************************************************************************

     *

     * INTERFACES

     *

     */



    /**

     * Supports Interface (EIP-165)

     *

     * (see: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md)

     *

     * NOTE: Must support the following conditions:

     *       1. (true) when interfaceID is 0x01ffc9a7 (EIP165 interface)

     *       2. (false) when interfaceID is 0xffffffff

     *       3. (true) for any other interfaceID this contract implements

     *       4. (false) for any other interfaceID

     */

    function supportsInterface(

        bytes4 _interfaceID

    ) external pure returns (bool) {

        /* Initialize constants. */

        bytes4 InvalidId = 0xffffffff;

        bytes4 ERC165Id = 0x01ffc9a7;



        /* Validate condition #2. */

        if (_interfaceID == InvalidId) {

            return false;

        }



        /* Validate condition #1. */

        if (_interfaceID == ERC165Id) {

            return true;

        }



        // TODO Add additional interfaces here.



        /* Return false (for condition #4). */

        return false;

    }



    /**

     * ECRecovery Interface

     */

    function _ecRecovery() private view returns (

        ECRecovery ecrecovery

    ) {

        /* Initialize hash. */

        bytes32 hash = keccak256('aname.ecrecovery');



        /* Retrieve value from Zer0net Db. */

        address aname = _zer0netDb.getAddress(hash);



        /* Initialize interface. */

        ecrecovery = ECRecovery(aname);

    }



    /**

     * ZeroCache Interface

     *

     * Retrieves the current ZeroCache interface,

     * using the aname record from Zer0netDb.

     */

    function _zeroCache() private view returns (

        ZeroCacheInterface zeroCache

    ) {

        /* Initialize hash. */

        bytes32 hash = keccak256('aname.zerocache');



        /* Retrieve value from Zer0net Db. */

        address aname = _zer0netDb.getAddress(hash);



        /* Initialize interface. */

        zeroCache = ZeroCacheInterface(aname);

    }



    /**

     * MakerDAO DAI Interface

     * 

     * Retrieves the current DAI interface,

     * using the aname record from Zer0netDb.

     */

    function _dai() private view returns (

        ERC20Interface dai

    ) {

        /* Initialize hash. */

        // NOTE: ERC tokens are case-sensitive.

        bytes32 hash = keccak256('aname.DAI');

        

        /* Retrieve value from Zer0net Db. */

        address aname = _zer0netDb.getAddress(hash);

        

        /* Initialize interface. */

        dai = ERC20Interface(aname);

    }



    /**

     * ZeroGold Interface

     *

     * Retrieves the current ZeroGold interface,

     * using the aname record from Zer0netDb.

     */

    function _zeroGold() private view returns (

        ERC20Interface zeroGold

    ) {

        /* Initialize hash. */

        // NOTE: ERC tokens are case-sensitive.

        bytes32 hash = keccak256('aname.0GOLD');



        /* Retrieve value from Zer0net Db. */

        address aname = _zer0netDb.getAddress(hash);



        /* Initialize interface. */

        zeroGold = ERC20Interface(aname);

    }





    /***************************************************************************

     *

     * UTILITIES

     *

     */



    /**

     * Calculate Market Identificaiton

     *

     * "Officially" Supported ZeroGold Markets

     * ---------------------------------------

     *

     * 1. 0GOLD / 0xBTC     ZeroGold / 0xBitcoin Token

     * 2. 0GOLD / DAI       ZeroGold / MakerDAO Dai

     * 3. 0GOLD / WBTC      ZeroGold / Wrapped Bitcoin

     * 4. 0GOLD / WETH      ZeroGold / Wrapped Ethereum

     * 

     * "Officially" Supported MakerDAO Dai Markets

     * -------------------------------------------

     *

     * 1. 0GOLD / DAI               ZeroGold / MakerDAO Dai

     * 2. 0xBTC / DAI        0xBitcoin Token / MakerDAO Dai

     * 3.  WBTC / DAI        Wrapped Bitcoin / MakerDAO Dai

     * 4.  WETH / DAI       Wrapped Ethereum / MakerDAO Dai

     *

     * NOTE: ZeroGold will serve as the "official" base token.

     *       MakerDAO Dai will serve as the "official" quote token.

     */

    function _calcMarketId(

        address _tokenRequest,

        address _tokenOffer

    ) private view returns (bytes32 market) {

        /* Set DAI address. */

        address daiAddress = _dai();



        /* Set ZeroGold address. */

        address zgAddress = _zeroGold();



        /* Initialize base token. */

        address baseToken = 0x0;



        /* Initailize quote token. */

        address quoteToken = 0x0;



        /* Set ZeroGold as base token. */

        if (_tokenRequest == zgAddress || _tokenOffer == zgAddress) {

            baseToken = zgAddress;

        }



        /* Set ZeroGold as base token. */

        if (_tokenRequest == daiAddress || _tokenOffer == daiAddress) {

            quoteToken = daiAddress;

        }



        /* Validate market pair. */

        // NOTE: Either ZeroGold OR Dai MUST be specified for a valid 

        //       market to be available.

        if (baseToken == 0x0 && quoteToken == 0x0) {

            revert('Oops! That market is NOT currently supported.');

        }



        /* Validate/set quote token. */

        if (quoteToken == 0x0) {

            if (baseToken == _tokenRequest) {

                quoteToken = _tokenOffer;

            } else {

                quoteToken = _tokenRequest;

            }

        }

        

        /* Validate/set base token. */

        if (baseToken == 0x0) {

            if (quoteToken == _tokenRequest) {

                baseToken = _tokenOffer;

            } else {

                baseToken = _tokenRequest;

            }

        }

        

        /* Calculate market id. */

        market = keccak256(abi.encodePacked(

            baseToken, quoteToken));

    }



    /**

     * Calculate Transfer Hash

     * 

     * Calculate the "authorized" transfer hash used by ZeroCache.

     * 

     * NOTE: We utilize this primarily to help defeat stack depth issues.

     */

    function _calcTransferHash(

        address _token,

        uint _tokens,

        address _staekholder,

        uint _staek,

        uint _expires,

        uint _nonce

    ) private view returns (bytes32 transferHash) {

        /* Calculate transfer hash. */

        transferHash = keccak256(abi.encodePacked(

            address(_zeroCache()),

            _token, 

            msg.sender,

            address(this),

            _tokens,

            _staekholder,

            _staek,

            _expires,

            _nonce

        ));

    }



    /**

     * Can Partial Fill?

     */

    function _canPartialFill(

        bool _allowed,

        uint _amountOffer,

        uint _amountTaken

    ) private pure returns (bool success) {

        if (!_allowed && _amountOffer != _amountTaken) {

            revert('Oops! You CANNOT partial fill this order.');

        }

        

        /* Return success. */

        return true;

    }



    /**

     * Request Hash Authorized Signature

     * 

     * Validates ALL signature requests by:

     *     1. Uses ECRecovery to validate the signature.

     *     2. Verify expiration against the current block number.

     */

    function _requestHasAuthSig(

        address _from,

        bytes32 _authHash,

        uint _expires,

        bytes _signature

    ) private view returns (bool success) {

        /* Calculate signature hash. */

        bytes32 sigHash = keccak256(abi.encodePacked(

            '\x19Ethereum Signed Message:\n32', _authHash));



        /* Validate the expiration time. */

        if (block.number > _expires) {

            return false;

        }

        

        /* Retrieve the authorized account (address). */

        address authorizedAccount = 

            _ecRecovery().recover(sigHash, _signature);



        /* Validate the signer matches owner of the tokens. */

        if (_from != authorizedAccount) {

            return false;

        }



        /* Return success. */    

        return true;

    }

    

    /**

     * Transfer Change (Back) to Maker

     * 

     * NOTE: We manage change because we require the MAKER to 

     *       keep at least 2x `amountOffer` tokens available for

     *       `cacanPartialFill` requests.

     */

    function _transferChangeToMaker(

        bytes32 _orderId,

        uint _amountTaken

    ) private returns (bool success) {

        /* Validate change. */

        if (_orders[_orderId].amountOffer > _amountTaken) {

            _zeroCache().transfer(

                _orders[_orderId].maker,

                _orders[_orderId].tokenOffer,

                _orders[_orderId].amountOffer.sub(_amountTaken)

            );

        }

        

        /* Return success. */

        return true;

    }

    

    /**

     * Transfer (Tokens) from Maker.

     * 

     * NOTE: This executes the SIGNED transfer request, 

     *       by the MAKER that allows ZeroDelta to perfom an 

     *       atomic token swap.

     * 

     *       *** THERE IS NO STAEKHOLDER SUPPORT FOR MAKERS ***

     */

    function _transferFromMaker(

        bytes32 _orderId

    ) private returns (bool success) {

        /* Transer tokens from MAKER to ZeroDelta. */

        // NOTE: This is a PRE-AUTHORIZED transfer request using `makerSig`.

        _zeroCache().transfer(

            _orders[_orderId].tokenOffer,

            _orders[_orderId].maker,

            address(this),

            _orders[_orderId].amountOffer,

            address(0x0),

            uint(0),

            _orders[_orderId].expires,

            _orders[_orderId].nonce,

            _orders[_orderId].makerSig

        );

        

        /* Return success. */

        return true;

    }

    

    /**

     * Tranfer (Tokens) from Taker to Maker

     * 

     * NOTE: This executes the SIGNED transfer request, 

     *       by the TAKER for the payment amount to MAKER.

     */

    function _transferFromTakerToMaker(

        bytes32 _tradeId,

        uint _paymentAmount

    ) private returns (bool success) {

        /* Set order id. */

        bytes32 orderId = _trades[_tradeId].orderId;

    

        // WARNING Do this BEFORE TAKER transfer to safeguard against

        // a re-entry attack.

        // NOTE: This is a PRE-AUTHORIZED transfer request using `takerSig`,

        //       while also allowing for a staekholder to expedite the transfer.

        _zeroCache().transfer(

            _orders[orderId].tokenRequest,

            _trades[_tradeId].taker,

            _orders[orderId].maker,

            _paymentAmount,

            _trades[_tradeId].staekholder,

            _trades[_tradeId].staek,

            _orders[orderId].expires,

            _orders[orderId].nonce,

            _trades[_tradeId].takerSig

        );



        /* Return success. */

        return true;

    }

    

    /**

     * Transfer (Tokens) to Taker

     */

    function _transferToTaker(

        bytes32 _tradeId,

        uint _amountTaken

    ) private returns (bool success) {

        /* Set order id. */

        bytes32 orderId = _trades[_tradeId].orderId;

    

        /* Transfer tokens to taker. */

        _zeroCache().transfer(

            _trades[_tradeId].taker,

            _orders[orderId].tokenOffer,

            _amountTaken

        );

        

        /* Return success. */

        return true;

    }



    /**

     * Convert Bytes to Bytes32

     */

    function _bytesToBytes32(

        bytes _data,

        uint _offset

    ) private pure returns (bytes32 result) {

        /* Loop through each byte. */

        for (uint i = 0; i < 32; i++) {

            /* Shift bytes onto result. */

            result |= bytes32(_data[i + _offset] & 0xFF) >> (i * 8);

        }

    }



    /**

     * Bytes-to-Address

     *

     * Converts bytes into type address.

     */

    function _bytesToAddress(

        bytes _address

    ) private pure returns (address) {

        uint160 m = 0;

        uint160 b = 0;



        for (uint8 i = 0; i < 20; i++) {

            m *= 256;

            b = uint160(_address[i]);

            m += (b);

        }



        return address(m);

    }



    /**

     * Transfer Any ERC20 Token

     *

     * @notice Owner can transfer out any accidentally sent ERC20 tokens.

     *

     * @dev Provides an ERC20 interface, which allows for the recover

     *      of any accidentally sent ERC20 tokens.

     */

    function transferAnyERC20Token(

        address _tokenAddress,

        uint _tokens

    ) public onlyOwner returns (bool success) {

        return ERC20Interface(_tokenAddress).transfer(owner, _tokens);

    }

}