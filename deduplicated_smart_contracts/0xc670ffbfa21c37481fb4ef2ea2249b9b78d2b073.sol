/**

 *Submitted for verification at Etherscan.io on 2018-11-14

*/



// File: contracts/generic/Restricted.sol



/*

    Generic contract to authorise calls to certain functions only from a given address.

    The address authorised must be a contract (multisig or not, depending on the permission), except for local test



    deployment works as:

           1. contract deployer account deploys contracts

           2. constructor grants "PermissionGranter" permission to deployer account

           3. deployer account executes initial setup (no multiSig)

           4. deployer account grants PermissionGranter permission for the MultiSig contract

                (e.g. StabilityBoardProxy or PreTokenProxy)

           5. deployer account revokes its own PermissionGranter permission

*/



pragma solidity 0.4.24;





contract Restricted {



    // NB: using bytes32 rather than the string type because it's cheaper gas-wise:

    mapping (address => mapping (bytes32 => bool)) public permissions;



    event PermissionGranted(address indexed agent, bytes32 grantedPermission);

    event PermissionRevoked(address indexed agent, bytes32 revokedPermission);



    modifier restrict(bytes32 requiredPermission) {

        require(permissions[msg.sender][requiredPermission], "msg.sender must have permission");

        _;

    }



    constructor(address permissionGranterContract) public {

        require(permissionGranterContract != address(0), "permissionGranterContract must be set");

        permissions[permissionGranterContract]["PermissionGranter"] = true;

        emit PermissionGranted(permissionGranterContract, "PermissionGranter");

    }



    function grantPermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],

            "msg.sender must have PermissionGranter permission");

        permissions[agent][requiredPermission] = true;

        emit PermissionGranted(agent, requiredPermission);

    }



    function grantMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        require(permissions[msg.sender]["PermissionGranter"],

            "msg.sender must have PermissionGranter permission");

        uint256 length = requiredPermissions.length;

        for (uint256 i = 0; i < length; i++) {

            grantPermission(agent, requiredPermissions[i]);

        }

    }



    function revokePermission(address agent, bytes32 requiredPermission) public {

        require(permissions[msg.sender]["PermissionGranter"],

            "msg.sender must have PermissionGranter permission");

        permissions[agent][requiredPermission] = false;

        emit PermissionRevoked(agent, requiredPermission);

    }



    function revokeMultiplePermissions(address agent, bytes32[] requiredPermissions) public {

        uint256 length = requiredPermissions.length;

        for (uint256 i = 0; i < length; i++) {

            revokePermission(agent, requiredPermissions[i]);

        }

    }



}



// File: contracts/generic/SafeMath.sol



/**

* @title SafeMath

* @dev Math operations with safety checks that throw on error



    TODO: check against ds-math: https://blog.dapphub.com/ds-math/

    TODO: move roundedDiv to a sep lib? (eg. Math.sol)

    TODO: more unit tests!

*/

pragma solidity 0.4.24;





library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;

        require(a == 0 || c / a == b, "mul overflow");

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason

        uint256 c = a / b;

        // require(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "sub underflow");

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "add overflow");

        return c;

    }



    // Division, round to nearest integer, round half up

    function roundedDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason

        uint256 halfB = (b % 2 == 0) ? (b / 2) : (b / 2 + 1);

        return (a % b >= halfB) ? (a / b + 1) : (a / b);

    }



    // Division, always rounds up

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "div by 0"); // Solidity automatically throws for div by 0 but require to emit reason

        return (a % b != 0) ? (a / b + 1) : (a / b);

    }



    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;

    }



    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? b : a;

    }    

}



// File: contracts/Rates.sol



/*

 Generic symbol / WEI rates contract.

 only callable by trusted price oracles.

 Being regularly called by a price oracle

    TODO: trustless/decentrilezed price Oracle

    TODO: shall we use blockNumber instead of now for lastUpdated?

    TODO: consider if we need storing rates with variable decimals instead of fixed 4

    TODO: could we emit 1 RateChanged event from setMultipleRates (symbols and newrates arrays)?

*/

pragma solidity 0.4.24;









contract Rates is Restricted {

    using SafeMath for uint256;



    struct RateInfo {

        uint rate; // how much 1 WEI worth 1 unit , i.e. symbol/ETH rate

                    // 0 rate means no rate info available

        uint lastUpdated;

    }



    // mapping currency symbol => rate. all rates are stored with 2 decimals. i.e. EUR/ETH = 989.12 then rate = 98912

    mapping(bytes32 => RateInfo) public rates;



    event RateChanged(bytes32 symbol, uint newRate);



    constructor(address permissionGranterContract) public Restricted(permissionGranterContract) {} // solhint-disable-line no-empty-blocks



    function setRate(bytes32 symbol, uint newRate) external restrict("RatesFeeder") {

        rates[symbol] = RateInfo(newRate, now);

        emit RateChanged(symbol, newRate);

    }



    function setMultipleRates(bytes32[] symbols, uint[] newRates) external restrict("RatesFeeder") {

        require(symbols.length == newRates.length, "symobls and newRates lengths must be equal");

        for (uint256 i = 0; i < symbols.length; i++) {

            rates[symbols[i]] = RateInfo(newRates[i], now);

            emit RateChanged(symbols[i], newRates[i]);

        }

    }



    function convertFromWei(bytes32 bSymbol, uint weiValue) external view returns(uint value) {

        require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");

        return weiValue.mul(rates[bSymbol].rate).roundedDiv(1000000000000000000);

    }



    function convertToWei(bytes32 bSymbol, uint value) external view returns(uint weiValue) {

        // next line would revert with div by zero but require to emit reason

        require(rates[bSymbol].rate > 0, "rates[bSymbol] must be > 0");

        /* TODO: can we make this not loosing max scale? */

        return value.mul(1000000000000000000).roundedDiv(rates[bSymbol].rate);

    }



}



// File: contracts/interfaces/TransferFeeInterface.sol



/*

 *  transfer fee calculation interface

 *

 */

pragma solidity 0.4.24;





interface TransferFeeInterface {

    function calculateTransferFee(address from, address to, uint amount) external view returns (uint256 fee);

}



// File: contracts/interfaces/ERC20Interface.sol



/*

 * ERC20 interface

 * see https://github.com/ethereum/EIPs/issues/20

 */

pragma solidity 0.4.24;





interface ERC20Interface {

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event Transfer(address indexed from, address indexed to, uint amount);



    function transfer(address to, uint value) external returns (bool); // solhint-disable-line no-simple-event-func-name

    function transferFrom(address from, address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function balanceOf(address who) external view returns (uint);

    function allowance(address _owner, address _spender) external view returns (uint remaining);



}



// File: contracts/interfaces/TokenReceiver.sol



/*

 *  receiver contract interface

 * see https://github.com/ethereum/EIPs/issues/677

 */

pragma solidity 0.4.24;





interface TokenReceiver {

    function transferNotification(address from, uint256 amount, uint data) external;

}



// File: contracts/interfaces/AugmintTokenInterface.sol



/* Augmint Token interface (abstract contract)



TODO: overload transfer() & transferFrom() instead of transferWithNarrative() & transferFromWithNarrative()

      when this fix available in web3& truffle also uses that web3: https://github.com/ethereum/web3.js/pull/1185

TODO: shall we use bytes for narrative?

 */

pragma solidity 0.4.24;















contract AugmintTokenInterface is Restricted, ERC20Interface {

    using SafeMath for uint256;



    string public name;

    string public symbol;

    bytes32 public peggedSymbol;

    uint8 public decimals;



    uint public totalSupply;

    mapping(address => uint256) public balances; // Balances for each account

    mapping(address => mapping (address => uint256)) public allowed; // allowances added with approve()



    TransferFeeInterface public feeAccount;

    mapping(bytes32 => bool) public delegatedTxHashesUsed; // record txHashes used by delegatedTransfer



    event TransferFeesChanged(uint transferFeePt, uint transferFeeMin, uint transferFeeMax);

    event Transfer(address indexed from, address indexed to, uint amount);

    event AugmintTransfer(address indexed from, address indexed to, uint amount, string narrative, uint fee);

    event TokenIssued(uint amount);

    event TokenBurned(uint amount);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    function transfer(address to, uint value) external returns (bool); // solhint-disable-line no-simple-event-func-name

    function transferFrom(address from, address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);



    function delegatedTransfer(address from, address to, uint amount, string narrative,

                                    uint maxExecutorFeeInToken, /* client provided max fee for executing the tx */

                                    bytes32 nonce, /* random nonce generated by client */

                                    /* ^^^^ end of signed data ^^^^ */

                                    bytes signature,

                                    uint requestedExecutorFeeInToken /* the executor can decide to request lower fee */

                                ) external;



    function delegatedTransferAndNotify(address from, TokenReceiver target, uint amount, uint data,

                                    uint maxExecutorFeeInToken, /* client provided max fee for executing the tx */

                                    bytes32 nonce, /* random nonce generated by client */

                                    /* ^^^^ end of signed data ^^^^ */

                                    bytes signature,

                                    uint requestedExecutorFeeInToken /* the executor can decide to request lower fee */

                                ) external;



    function increaseApproval(address spender, uint addedValue) external;

    function decreaseApproval(address spender, uint subtractedValue) external;



    function issueTo(address to, uint amount) external; // restrict it to "MonetarySupervisor" in impl.;

    function burn(uint amount) external;



    function transferAndNotify(TokenReceiver target, uint amount, uint data) external;



    function transferWithNarrative(address to, uint256 amount, string narrative) external;

    function transferFromWithNarrative(address from, address to, uint256 amount, string narrative) external;



    function setName(string _name) external;

    function setSymbol(string _symbol) external;



    function allowance(address owner, address spender) external view returns (uint256 remaining);



    function balanceOf(address who) external view returns (uint);





}



// File: contracts/Exchange.sol



/* Augmint's Internal Exchange



  For flows see: https://github.com/Augmint/augmint-contracts/blob/master/docs/exchangeFlow.png



    TODO:

        - change to wihtdrawal pattern, see: https://github.com/Augmint/augmint-contracts/issues/17

        - deduct fee

        - consider take funcs (frequent rate changes with takeBuyToken? send more and send back remainder?)

        - use Rates interface?

*/

pragma solidity 0.4.24;













contract Exchange is Restricted {

    using SafeMath for uint256;



    AugmintTokenInterface public augmintToken;

    Rates public rates;



    struct Order {

        uint64 index;

        address maker;



        // % of published current peggedSymbol/ETH rates published by Rates contract. Stored as parts per million

        // I.e. 1,000,000 = 100% (parity), 990,000 = 1% below parity

        uint32 price;



        // buy order: amount in wei

        // sell order: token amount

        uint amount;

    }



    uint64 public orderCount;

    mapping(uint64 => Order) public buyTokenOrders;

    mapping(uint64 => Order) public sellTokenOrders;



    uint64[] private activeBuyOrders;

    uint64[] private activeSellOrders;



    /* used to stop executing matchMultiple when running out of gas.

        actual is much less, just leaving enough matchMultipleOrders() to finish TODO: fine tune & test it*/

    uint32 private constant ORDER_MATCH_WORST_GAS = 100000;



    event NewOrder(uint64 indexed orderId, address indexed maker, uint32 price, uint tokenAmount, uint weiAmount);



    event OrderFill(address indexed tokenBuyer, address indexed tokenSeller, uint64 buyTokenOrderId,

        uint64 sellTokenOrderId, uint publishedRate, uint32 price, uint weiAmount, uint tokenAmount);



    event CancelledOrder(uint64 indexed orderId, address indexed maker, uint tokenAmount, uint weiAmount);



    event RatesContractChanged(Rates newRatesContract);



    constructor(address permissionGranterContract, AugmintTokenInterface _augmintToken, Rates _rates)

    public Restricted(permissionGranterContract) {

        augmintToken = _augmintToken;

        rates = _rates;

    }



    /* to allow upgrade of Rates  contract */

    function setRatesContract(Rates newRatesContract)

    external restrict("StabilityBoard") {

        rates = newRatesContract;

        emit RatesContractChanged(newRatesContract);

    }



    function placeBuyTokenOrder(uint32 price) external payable returns (uint64 orderId) {

        require(price > 0, "price must be > 0");

        require(msg.value > 0, "msg.value must be > 0");



        orderId = ++orderCount;

        buyTokenOrders[orderId] = Order(uint64(activeBuyOrders.length), msg.sender, price, msg.value);

        activeBuyOrders.push(orderId);



        emit NewOrder(orderId, msg.sender, price, 0, msg.value);

    }



    /* this function requires previous approval to transfer tokens */

    function placeSellTokenOrder(uint32 price, uint tokenAmount) external returns (uint orderId) {

        augmintToken.transferFrom(msg.sender, this, tokenAmount);

        return _placeSellTokenOrder(msg.sender, price, tokenAmount);

    }



    /* place sell token order called from AugmintToken's transferAndNotify

     Flow:

        1) user calls token contract's transferAndNotify price passed in data arg

        2) transferAndNotify transfers tokens to the Exchange contract

        3) transferAndNotify calls Exchange.transferNotification with lockProductId

    */

    function transferNotification(address maker, uint tokenAmount, uint price) external {

        require(msg.sender == address(augmintToken), "msg.sender must be augmintToken");

        _placeSellTokenOrder(maker, uint32(price), tokenAmount);

    }



    function cancelBuyTokenOrder(uint64 buyTokenId) external {

        Order storage order = buyTokenOrders[buyTokenId];

        require(order.maker == msg.sender, "msg.sender must be order.maker");

        require(order.amount > 0, "buy order already removed");



        uint amount = order.amount;

        order.amount = 0;

        _removeBuyOrder(order);



        msg.sender.transfer(amount);



        emit CancelledOrder(buyTokenId, msg.sender, 0, amount);

    }



    function cancelSellTokenOrder(uint64 sellTokenId) external {

        Order storage order = sellTokenOrders[sellTokenId];

        require(order.maker == msg.sender, "msg.sender must be order.maker");

        require(order.amount > 0, "sell order already removed");



        uint amount = order.amount;

        order.amount = 0;

        _removeSellOrder(order);



        augmintToken.transferWithNarrative(msg.sender, amount, "Sell token order cancelled");



        emit CancelledOrder(sellTokenId, msg.sender, amount, 0);

    }



    /* matches any two orders if the sell price >= buy price

        trade price is the price of the maker (the order placed earlier)

        reverts if any of the orders have been removed

    */

    function matchOrders(uint64 buyTokenId, uint64 sellTokenId) external {

        require(_fillOrder(buyTokenId, sellTokenId), "fill order failed");

    }



    /*  matches as many orders as possible from the passed orders

        Runs as long as gas is available for the call.

        Reverts if any match is invalid (e.g sell price > buy price)

        Skips match if any of the matched orders is removed / already filled (i.e. amount = 0)

    */

    function matchMultipleOrders(uint64[] buyTokenIds, uint64[] sellTokenIds) external returns(uint matchCount) {

        uint len = buyTokenIds.length;

        require(len == sellTokenIds.length, "buyTokenIds and sellTokenIds lengths must be equal");



        for (uint i = 0; i < len && gasleft() > ORDER_MATCH_WORST_GAS; i++) {

            if(_fillOrder(buyTokenIds[i], sellTokenIds[i])) {

                matchCount++;

            }

        }

    }



    function getActiveOrderCounts() external view returns(uint buyTokenOrderCount, uint sellTokenOrderCount) {

        return(activeBuyOrders.length, activeSellOrders.length);

    }



    // returns <chunkSize> active buy orders starting from <offset>

    // orders are encoded as [id, maker, price, amount]

    function getActiveBuyOrders(uint offset, uint16 chunkSize)

    external view returns (uint[4][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), activeBuyOrders.length);

        uint[4][] memory response = new uint[4][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {

            uint64 orderId = activeBuyOrders[i];

            Order storage order = buyTokenOrders[orderId];

            response[i - offset] = [orderId, uint(order.maker), order.price, order.amount];

        }

        return response;

    }



    // returns <chunkSize> active sell orders starting from <offset>

    // orders are encoded as [id, maker, price, amount]

    function getActiveSellOrders(uint offset, uint16 chunkSize)

    external view returns (uint[4][]) {

        uint limit = SafeMath.min(offset.add(chunkSize), activeSellOrders.length);

        uint[4][] memory response = new uint[4][](limit.sub(offset));

        for (uint i = offset; i < limit; i++) {

            uint64 orderId = activeSellOrders[i];

            Order storage order = sellTokenOrders[orderId];

            response[i - offset] = [orderId, uint(order.maker), order.price, order.amount];

        }

        return response;

    }



    uint private constant E12 = 1000000000000;



    function _fillOrder(uint64 buyTokenId, uint64 sellTokenId) private returns(bool success) {

        Order storage buy = buyTokenOrders[buyTokenId];

        Order storage sell = sellTokenOrders[sellTokenId];

        if( buy.amount == 0 || sell.amount == 0 ) {

            return false; // one order is already filled and removed.

                          // we let matchMultiple continue, indivudal match will revert

        }



        require(buy.price >= sell.price, "buy price must be >= sell price");



        // pick maker's price (whoever placed order sooner considered as maker)

        uint32 price = buyTokenId > sellTokenId ? sell.price : buy.price;



        uint publishedRate;

        (publishedRate, ) = rates.rates(augmintToken.peggedSymbol());

        // fillRate = publishedRate * 1000000 / price



        uint sellWei = sell.amount.mul(uint(price)).mul(E12).roundedDiv(publishedRate);



        uint tradedWei;

        uint tradedTokens;

        if (sellWei <= buy.amount) {

            tradedWei = sellWei;

            tradedTokens = sell.amount;

        } else {

            tradedWei = buy.amount;

            tradedTokens = buy.amount.mul(publishedRate).roundedDiv(uint(price).mul(E12));

        }



        buy.amount = buy.amount.sub(tradedWei);

        if (buy.amount == 0) {

            _removeBuyOrder(buy);

        }



        sell.amount = sell.amount.sub(tradedTokens);

        if (sell.amount == 0) {

            _removeSellOrder(sell);

        }



        augmintToken.transferWithNarrative(buy.maker, tradedTokens, "Buy token order fill");

        sell.maker.transfer(tradedWei);



        emit OrderFill(buy.maker, sell.maker, buyTokenId,

            sellTokenId, publishedRate, price, tradedWei, tradedTokens);



        return true;

    }



    function _placeSellTokenOrder(address maker, uint32 price, uint tokenAmount)

    private returns (uint64 orderId) {

        require(price > 0, "price must be > 0");

        require(tokenAmount > 0, "tokenAmount must be > 0");



        orderId = ++orderCount;

        sellTokenOrders[orderId] = Order(uint64(activeSellOrders.length), maker, price, tokenAmount);

        activeSellOrders.push(orderId);



        emit NewOrder(orderId, maker, price, tokenAmount, 0);

    }



    function _removeBuyOrder(Order storage order) private {

        uint lastIndex = activeBuyOrders.length - 1;

        if (order.index < lastIndex) {

            uint64 movedOrderId = activeBuyOrders[lastIndex];

            activeBuyOrders[order.index] = movedOrderId;

            buyTokenOrders[movedOrderId].index = order.index;

        }

        activeBuyOrders.length--;

    }



    function _removeSellOrder(Order storage order) private {

        uint lastIndex = activeSellOrders.length - 1;

        if (order.index < lastIndex) {

            uint64 movedOrderId = activeSellOrders[lastIndex];

            activeSellOrders[order.index] = movedOrderId;

            sellTokenOrders[movedOrderId].index = order.index;

        }

        activeSellOrders.length--;

    }

}