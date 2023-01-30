/**
 *Submitted for verification at Etherscan.io on 2019-11-18
*/

pragma solidity =0.5.13;

// * Gods Unchained Cards Exchange
//
// * Version 1.0
//
// * A dedicated, specialized contract enabling exchange of Gods Unchained cards.
//   Considers Gods Unchained specific characteristics like quality and proto
//   and allows multicard offchain listing and dynamic package purchases.
//
// * https://gu.cards
// * Copyright gu.cards

interface ICards {
    function cardProtos(uint tokenId) external view returns (uint16 proto);
    function cardQualities(uint tokenId) external view returns (uint8 quality);
}

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract GodsUnchainedCards is IERC721, ICards {}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract CardExchange {
    using SafeMath for uint256;

    ////////////////////////////////////////////////
    //////// V A R I A B L E S
    //
    // Current address of the Gods Unchained cards (CARD) token contract.
    //
    GodsUnchainedCards constant public godsUnchainedCards = GodsUnchainedCards(0x0E3A2A1f2146d86A604adc220b4967A898D7Fe07);
    //
    // Mapping of all buy orders.
    //
    mapping (address => mapping(uint256 => BuyOrder)) public buyOrdersById;
    //
    // Mapping of all sell orders.
    //
    mapping (address => mapping(uint256 => SellOrder)) public sellOrdersById;
    //
    // EIP712 sellOrder implementation, to safely create sell orders without chain interaction.
    //
    string private constant domain = "EIP712Domain(string name)";
    bytes32 public constant domainTypeHash = keccak256(abi.encodePacked(domain));
    bytes32 private domainSeparator = keccak256(abi.encode(domainTypeHash, keccak256("Sell Gods Unchained cards on gu.cards")));
    string private constant sellOrdersForTokenIdsType = "SellOrders(uint256[] ids,uint256[] tokenIds,uint256[] prices)";
    bytes32 public constant sellOrdersForTokenIdsTypeHash = keccak256(abi.encodePacked(sellOrdersForTokenIdsType));
    string private constant sellOrdersForProtosAndQualitiesType = "SellOrders(uint256[] ids,uint256[] protos,uint256[] qualities,uint256[] prices)";
    bytes32 public constant sellOrdersForProtosAndQualitiesTypeHash = keccak256(abi.encodePacked(sellOrdersForProtosAndQualitiesType));
    //
    // Accumulated locked funds from binding buy orders are save from contract killing or withdraw
    // until the orders are executed or canceled.
    //
    uint256 public lockedInFunds;
    //
    // In case the exchange needs to be paused.
    //
    bool public paused;
    //
    // Exchange fee. 
    // Devided by 1000 than applied to the price.
    // e.g. 25 = 2.5%
    //
    uint256 public exchangeFee;
    //
    // Standard contract ownership.
    //
    address payable public owner;
    address payable private nextOwner;
    
    ////////////////////////////////////////////////
    //////// E V E N T S
    //
    event BuyOrderCreated(uint256 id);
    event SellOrderCreated(uint256 id);
    event BuyOrderCanceled(uint256 id);
    event SellOrderCanceled(uint256 id);
    event Settled(uint256 buyOrderId, uint256 sellOrderId);

    ////////////////////////////////////////////////
    //////// S T R U C T S
    //
    //  An instruction from an orderer to buy a card.
    //
    struct BuyOrder {
        //
        // The id of the buy order.
        //
        uint256 id;
        //
        // Price in wei.
        //
        uint256 price;
        //
        // Exchange fee set the moment buy order is created.
        //
        uint256 fee;
        //
        // Which concrete card.
        //
        uint16 proto;
        //
        // The quality of the card.
        //
        uint8 quality;
        //
        // Where to send the card or refund to.
        //
        address payable buyer;
        //
        // Has the order been settled yet?
        //
        bool settled;
        //
        // Has the order been canceled yet?
        //
        bool canceled;
    }
    //
    //  An instruction from a seller to sell a concrete card (token) for a certain amount of ETH.
    //
    struct SellOrder {
        //
        // The id of the sell order.
        //
        uint256 id;
        //
        // The concrete token id of the card.
        //
        uint256 tokenId;
        //
        // Which concrete card.
        //
        uint16 proto;
        //
        // The quality of the card.
        //
        uint8 quality;
        //
        // Price in wei.
        //
        uint256 price;
        //
        // Where to send the ETH to?
        //
        address payable seller;
        //
        // Has the order been settled yet?
        //
        bool settled;
        //
        // Has the order been canceled yet?
        //
        bool canceled;
        //
        // Has the orders tokenId been set?
        // tokenId 0 is actually an existing token.
        //
        bool tokenIsSet;
    }

    ////////////////////////////////////////////////
    //////// M O D I F I E R S
    //
    // Invokable only by contract owner.
    //
    modifier onlyOwner {
        require(msg.sender == owner, "Function called by non-owner.");
        _;
    }
    //
    // Invokable only if exchange is not paused.
    //
    modifier onlyUnpaused {
        require(paused == false, "Exchange is paused.");
        _;
    }

    ////////////////////////////////////////////////
    //////// C O N S T R U C T O R
    //
    // Sets the contract owner
    // and initalizes the EIP712 domain separator.
    //
    constructor() public {
        owner = msg.sender;
    }

    ////////////////////////////////////////////////
    //////// F U N C T I O N S
    //
    // Public method to create one or multiple buy orders.
    //
    function createBuyOrders(uint256[] calldata ids, uint256[] calldata protos, uint256[] calldata prices, uint256[] calldata qualities) onlyUnpaused external payable {
        _createBuyOrders(ids, protos, prices, qualities);
    }
    //
    // Public Method to create one or multiple buy orders and settles them right after.
    //
    function createBuyOrdersAndSettle(uint256[] calldata orderData, uint256[] calldata sellOrderIds, uint256[] calldata tokenIds, address[] calldata sellOrderAddresses) onlyUnpaused external payable {
        uint256[] memory buyOrderIds = _unpackOrderData(orderData, 0);
        _createBuyOrders(
            buyOrderIds,
            _unpackOrderData(orderData, 1),
            _unpackOrderData(orderData, 3),
            _unpackOrderData(orderData, 2)
        );
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
            _updateSellOrderTokenId(sellOrdersById[sellOrderAddresses[i]][sellOrderIds[i]], tokenIds[i]);
            _settle(
                buyOrdersById[msg.sender][buyOrderIds[i]],
                sellOrdersById[sellOrderAddresses[i]][sellOrderIds[i]]
            );
        }
    }
    //
    // Public method to create a single buy order and settle with offchain/onchain sell order for token ids.
    // Dedicated for offchain listings, use createBuyOrdersAndSettle otherwise.
    //
    // orderData[0] == buyOrderId
    // orderData[1] == buyOrderProto
    // orderData[2] == buyOrderPrice
    // orderData[3] == buyOrderQuality
    // orderData[4] == sellOrderId
    //
    function createBuyOrderAndSettleWithOffChainSellOrderForTokenIds(uint256[] calldata orderData, address sellOrderAddress, uint256[] calldata sellOrderIds, uint256[] calldata sellOrderTokenIds, uint256[] calldata sellOrderPrices, uint8 v, bytes32 r, bytes32 s) onlyUnpaused external payable {
        _ensureBuyOrderPrice(orderData[2]);
        _createBuyOrder(orderData[0], uint16(orderData[1]), orderData[2], uint8(orderData[3]));
        _createOffChainSignedSellOrdersForTokenIds(sellOrderIds, sellOrderTokenIds, sellOrderPrices, v, r, s);
        _settle(buyOrdersById[msg.sender][orderData[0]], sellOrdersById[sellOrderAddress][orderData[4]]);
    }
    //
    // Public method to create a single buy order and settle with offchain/onchain sell order for proto and qualities.
    // Dedicated for offchain listings, use createBuyOrdersAndSettle otherwise.
    //
    function createBuyOrderAndSettleWithOffChainSellOrderForProtosAndQualities(uint256 buyOrderId, uint16 buyOrderProto, uint256 buyOrderPrice, uint8 buyOrderQuality, uint256 sellOrderId, address sellOrderAddress, uint256 tokenId, uint256[] calldata sellOrderData, uint8 v, bytes32 r, bytes32 s) onlyUnpaused external payable {
        _ensureBuyOrderPrice(buyOrderPrice);
        _createBuyOrder(buyOrderId, buyOrderProto, buyOrderPrice, buyOrderQuality);
        _createOffChainSignedSellOrdersForProtosAndQualities(
            _unpackOrderData(sellOrderData, 0),
            _unpackOrderData(sellOrderData, 1),
            _unpackOrderData(sellOrderData, 2),
            _unpackOrderData(sellOrderData, 3),
            v,
            r,
            s
        );
        _updateSellOrderTokenId(sellOrdersById[sellOrderAddress][sellOrderId], tokenId);
        _settle(buyOrdersById[msg.sender][buyOrderId], sellOrdersById[sellOrderAddress][sellOrderId]);
    }
    //
    // Ensures buy order pice is bigger than zero 
    // and send ether is more then buy order price + fee.
    //
    function _ensureBuyOrderPrice(uint256 price) private view {
        require(
            msg.value >= (price.add(price.mul(exchangeFee).div(1000))) &&
            price > 0,
            "Amount sent to the contract needs to cover at least this buy order's price and fee (and needs to be bigger than 0)."
        );
    }
    //
    // Internal, private method to unpack order data
    // Parts:
    // 0    ids
    // 1    protos
    // 2    qualities
    // 3    prices
    //
    function _unpackOrderData(uint256[] memory orderData, uint256 part) private pure returns (uint256[] memory data) {
        uint256 length = orderData.length/4;
        uint256[] memory returnData = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            returnData[i] = orderData[i*4+part];
        }
        return returnData;
    }
    //
    // Internal, private method to create buy orders.
    //
    function _createBuyOrders(uint256[] memory ids, uint256[] memory protos, uint256[] memory prices, uint256[] memory qualities) private {
        uint256 totalAmountToPay = 0;
        uint256 length = ids.length;

        for (uint256 i = 0; i < length; i++) {
            _createBuyOrder(ids[i], uint16(protos[i]), prices[i], uint8(qualities[i]));
            totalAmountToPay = totalAmountToPay.add(
                prices[i].add(prices[i].mul(exchangeFee).div(1000))
            );
        }
        
        require(msg.value >= totalAmountToPay && msg.value > 0, "ETH sent to the contract is insufficient (prices + exchange fees)!");
    }
    //
    // Internal, private method to create a single buy order.
    //
    function _createBuyOrder(uint256 id, uint16 proto, uint256 price, uint8 quality) private {
        BuyOrder storage buyOrder = buyOrdersById[msg.sender][id];
        require(buyOrder.id == 0, "Buy order with this ID does already exist!");
        buyOrder.id = id;
        buyOrder.proto = proto;
        buyOrder.price = price;
        buyOrder.fee = price.mul(exchangeFee).div(1000);
        buyOrder.quality = quality;
        buyOrder.buyer = msg.sender;
        
        lockedInFunds = lockedInFunds.add(buyOrder.price.add(buyOrder.fee));

        emit BuyOrderCreated(buyOrder.id);
    }
    //
    // Public method to cancel buy orders.
    //
    function cancelBuyOrders(uint256[] calldata ids) external {
        uint256 length = ids.length;
        for (uint256 i = 0; i < length; i++) {
            BuyOrder storage buyOrder = buyOrdersById[msg.sender][ids[i]];
            require(buyOrder.settled == false, "Order has already been settled!");
            require(buyOrder.canceled == false, "Order has already been canceled!");
            buyOrder.canceled = true; // prevent reentrancy, before transfer
            lockedInFunds = lockedInFunds.sub(buyOrder.price.add(buyOrder.fee));
            buyOrder.buyer.transfer(buyOrder.price.add(buyOrder.fee)); // refund
            emit BuyOrderCanceled(buyOrder.id);
        }
    }
    //
    // Public method to creates sell orders for token ids.
    //
    function createSellOrdersForTokenIds(uint256[] calldata ids, uint256[] calldata prices, uint256[] calldata tokenIds) onlyUnpaused external {
        _createSellOrdersForTokenIds(ids, prices, tokenIds, msg.sender);
    }
    //
    // Internal, private method to create sell orders.
    //
    function _createSellOrdersForTokenIds(uint256[] memory ids, uint256[] memory prices, uint256[] memory tokenIds, address payable seller) private {
        uint256 length = ids.length;
        for (uint256 i = 0; i < length; i++) {
            _createSellOrderForTokenId(ids[i], prices[i], tokenIds[i], seller);
        }
    }
    //
    // Internal, private method to create sell orders for token ids.
    //
    function _createSellOrderForTokenId(uint256 id, uint256 price, uint256 tokenId, address seller) private {
        _createSellOrder(
            id,
            price,
            tokenId,
            godsUnchainedCards.cardProtos(tokenId),
            godsUnchainedCards.cardQualities(tokenId),
            seller,
            true
        );
    }
     //
    // Public method to creates sell orders for protos and qualities.
    //
    function createSellOrdersForProtosAndQualities(uint256[] calldata ids, uint256[] calldata prices, uint256[] calldata protos, uint256[] calldata qualities) onlyUnpaused external {
        _createSellOrdersForProtosAndQualities(ids, prices, protos, qualities, msg.sender);
    }
    //
    // Internal, private method to create sell orders.
    //
    function _createSellOrdersForProtosAndQualities(uint256[] memory ids, uint256[] memory prices, uint256[] memory protos, uint256[] memory qualities, address payable seller) private {
        uint256 length = ids.length;
        for (uint256 i = 0; i < length; i++) {
            _createSellOrderForProtoAndQuality(ids[i], prices[i], protos[i], qualities[i], seller);
        }
    }
    //
    // Internal, private method to create sell orders for token ids.
    //
    function _createSellOrderForProtoAndQuality(uint256 id, uint256 price, uint256 proto, uint256 quality, address seller) private {
        _createSellOrder(
            id,
            price,
            0,
            proto,
            quality,
            seller,
            false
        );
    }
    //
    // Internal, private method to create sell orders.
    //
    function _createSellOrder(uint256 id, uint256 price, uint256 tokenId, uint256 proto, uint256 quality, address seller, bool tokenIsSet) private {
        address payable payableSeller = address(uint160(seller));
        require(price > 0, "Sell order price needs to be bigger than 0.");

        SellOrder storage sellOrder = sellOrdersById[seller][id];
        require(sellOrder.id == 0, "Sell order with this ID does already exist!");
        require(godsUnchainedCards.isApprovedForAll(payableSeller, address(this)), "Operator approval missing!");
        sellOrder.id = id;
        sellOrder.price = price;
        sellOrder.proto = uint16(proto);
        sellOrder.quality = uint8(quality);
        sellOrder.seller = payableSeller;
        
        if(tokenIsSet) { _updateSellOrderTokenId(sellOrder, tokenId); }
        
        emit SellOrderCreated(sellOrder.id);
    }
    //
    // Internal, private method to update sell order tokenId.
    //
    function _updateSellOrderTokenId(SellOrder storage sellOrder, uint256 tokenId) private {
        if(
            sellOrder.tokenIsSet ||
            sellOrder.canceled ||
            sellOrder.settled
        ) { return; }
        require(godsUnchainedCards.ownerOf(tokenId) == sellOrder.seller, "Seller is not owner of this token!");
        require(
            sellOrder.proto == godsUnchainedCards.cardProtos(tokenId) &&
            sellOrder.quality == godsUnchainedCards.cardQualities(tokenId)
            , "Token does not correspond to sell order proto/quality!"
        );
        sellOrder.tokenIsSet = true;
        sellOrder.tokenId = tokenId;
    }
    //
    // Public method to create sell orders for token ids and settle (e.g. into existing buy orders).
    //
    function createSellOrdersForTokenIdsAndSettle(uint256[] calldata sellOrderIds, address[] calldata sellOrderAddresses, uint256[] calldata sellOrderPrices, uint256[] calldata sellOrderTokenIds, uint256[] calldata buyOrderIds, address[] calldata buyOrderAddresses) onlyUnpaused external {
        _createSellOrdersForTokenIds(sellOrderIds, sellOrderPrices, sellOrderTokenIds, msg.sender);
        _settle(buyOrderIds, buyOrderAddresses, sellOrderIds, sellOrderAddresses);
    }
    //
    // Turns sell orders created off chain into onchain sell orders for token ids.
    //
    function createOffChainSignedSellOrdersForTokenIds(uint256[] calldata sellOrderIds, uint256[] calldata sellOrderTokenIds, uint256[] calldata sellOrderPrices, uint8 v, bytes32 r, bytes32 s) onlyUnpaused external {
        _createOffChainSignedSellOrdersForTokenIds(sellOrderIds, sellOrderTokenIds, sellOrderPrices, v, r, s);
    }
    //
    // Internal private method to turn off chain sell orders into on chain sell orders for token ids.
    //
    function _createOffChainSignedSellOrdersForTokenIds(uint256[] memory sellOrderIds, uint256[] memory sellOrderTokenIds, uint256[] memory sellOrderPrices, uint8 v, bytes32 r, bytes32 s) private {
        uint256 length = sellOrderIds.length;
        address seller = _recoverForTokenIds(sellOrderIds, sellOrderTokenIds, sellOrderPrices, v, r, s);
        for (
            uint256 i = 0;
            i < length;
            i++
        ) {
            if(sellOrdersById[seller][sellOrderIds[i]].id == 0) {
                // onchain sell order does not exist yet, create it
                _createSellOrderForTokenId(
                    sellOrderIds[i],
                    sellOrderPrices[i],
                    sellOrderTokenIds[i],
                    seller
                );
            }
        }
    }
    //
    // Public method to create sell orders for protos and qualities and settle (e.g. into existing buy orders).
    //
    function createSellOrdersForProtosAndQualitiesAndSettle(uint256[] calldata sellOrderData, uint256[] calldata tokenIds, uint256[] calldata buyOrderIds, address[] calldata buyOrderAddresses) onlyUnpaused external {
        uint256[] memory sellOrderIds = _unpackOrderData(sellOrderData, 0);
        _createSellOrdersForProtosAndQualities(
            sellOrderIds,
            _unpackOrderData(sellOrderData, 3),
            _unpackOrderData(sellOrderData, 1),
            _unpackOrderData(sellOrderData, 2),
            msg.sender
        );
        uint256 length = buyOrderIds.length;
        for (uint256 i = 0; i < length; i++) {
          _updateSellOrderTokenId(sellOrdersById[msg.sender][sellOrderIds[i]], tokenIds[i]);
          _settle(buyOrdersById[buyOrderAddresses[i]][buyOrderIds[i]], sellOrdersById[msg.sender][sellOrderIds[i]]);
        }
    }
    //
    // Turns sell orders created off chain into onchain sell orders for protos and qualities.
    //
    function createOffChainSignedSellOrdersForProtosAndQualities(uint256[] calldata sellOrderIds, uint256[] calldata sellOrderProtos, uint256[] calldata sellOrderQualities, uint256[] calldata sellOrderPrices, uint8 v, bytes32 r, bytes32 s) onlyUnpaused external {
        _createOffChainSignedSellOrdersForProtosAndQualities(sellOrderIds, sellOrderProtos, sellOrderQualities, sellOrderPrices, v, r, s);
    }
    //
    // Internal private method to turn off chain sell orders into on chain sell orders for protos and qualities.
    //
    function _createOffChainSignedSellOrdersForProtosAndQualities(uint256[] memory sellOrderIds, uint256[] memory sellOrderProtos, uint256[] memory sellOrderQualities, uint256[] memory sellOrderPrices, uint8 v, bytes32 r, bytes32 s) private {
        uint256 length = sellOrderIds.length;
        address seller = _recoverForProtosAndQualities(sellOrderIds, sellOrderProtos, sellOrderQualities, sellOrderPrices, v, r, s);
        for (
            uint256 i = 0;
            i < length;
            i++
        ) {
            if(sellOrdersById[seller][sellOrderIds[i]].id == 0) {
                // onchain sell order does not exist yet, create it
                _createSellOrderForProtoAndQuality(
                    sellOrderIds[i],
                    sellOrderPrices[i],
                    sellOrderProtos[i],
                    sellOrderQualities[i],
                    seller
                );
            }
        }
    }
    //
    // Public method that allows to recover an off chain sell order for token ids
    //
    function recoverSellOrderForTokenIds(uint256[] calldata ids, uint256[] calldata tokenIds, uint256[] calldata prices,  uint8 v, bytes32 r, bytes32 s) external view returns (address) {
        return _recoverForTokenIds(ids, tokenIds, prices, v, r, s);
    }
    //
    // Internal, private method to recover off chain sell order
    //
    function _recoverForTokenIds(uint256[] memory ids, uint256[] memory tokenIds, uint256[] memory prices, uint8 v, bytes32 r, bytes32 s) private view returns (address) {
        return ecrecover(hashSellOrdersForTokenIds(ids, tokenIds, prices), v, r, s);
    }
    //
    // Internal, private method to hash a sell orders for token ids
    //
    function hashSellOrdersForTokenIds(uint256[] memory ids, uint256[] memory tokenIds, uint256[] memory prices) private view returns (bytes32){
        return keccak256(abi.encodePacked(
           "\x19\x01",
           domainSeparator,
           keccak256(abi.encode(
                sellOrdersForTokenIdsTypeHash,
                keccak256(abi.encodePacked(ids)),
                keccak256(abi.encodePacked(tokenIds)),
                keccak256(abi.encodePacked(prices))
            ))
        ));
    }
    //
    // Public method that allows to recover an off chain sell order for token ids
    //
    function recoverSellOrderForProtosAndQualities(uint256[] calldata ids, uint256[] calldata protos, uint256[] calldata qualities, uint256[] calldata prices,  uint8 v, bytes32 r, bytes32 s) external view returns (address) {
        return _recoverForProtosAndQualities(ids, protos, qualities, prices, v, r, s);
    }
    //
    // Internal, private method to recover off chain sell orders for protos and qualities
    //
    function _recoverForProtosAndQualities(uint256[] memory ids, uint256[] memory protos, uint256[] memory qualities, uint256[] memory prices, uint8 v, bytes32 r, bytes32 s) private view returns (address) {
        return ecrecover(hashSellOrdersForProtosAndQualitiesIds(ids, protos, qualities, prices), v, r, s);
    }
     //
    // Internal, private method to hash a sell order for protos & qualities
    //
    function hashSellOrdersForProtosAndQualitiesIds(uint256[] memory ids, uint256[] memory protos, uint256[] memory qualities, uint256[] memory prices) private view returns (bytes32){
        return keccak256(abi.encodePacked(
           "\x19\x01",
           domainSeparator,
           keccak256(abi.encode(
                sellOrdersForProtosAndQualitiesTypeHash,
                keccak256(abi.encodePacked(ids)),
                keccak256(abi.encodePacked(protos)),
                keccak256(abi.encodePacked(qualities)),
                keccak256(abi.encodePacked(prices))
            ))
        ));
    }
    //
    // Cancels sell orders.
    //
    function cancelSellOrders(uint256[] calldata ids) onlyUnpaused external {
        uint256 length = ids.length;
        for (uint256 i = 0; i < length; i++) {
            SellOrder storage sellOrder = sellOrdersById[msg.sender][ids[i]];
            if(sellOrder.id == 0) { // off-chain sell order
                sellOrder.id = ids[i];
            }
            require(sellOrder.canceled == false, "Order has already been canceled!");
            require(sellOrder.settled == false, "Order has already been settled!");
            sellOrder.canceled = true;
            emit SellOrderCanceled(sellOrder.id);
        }
    }
    //
    // Public method to settle buy and sell orders (transfers cards for ETH).
    //
    function settle(uint256[] calldata buyOrderIds, address[] calldata buyOrderAddresses, uint256[] calldata sellOrderIds, address[] calldata sellOrderAddresses) onlyUnpaused external {
        _settle(buyOrderIds, buyOrderAddresses, sellOrderIds, sellOrderAddresses);
    }
    //
    // Public method to settle .
    //
    function settleWithToken(uint256[] calldata buyOrderIds, address[] calldata buyOrderAddresses, uint256[] calldata sellOrderIds, address[] calldata sellOrderAddresses, uint256[] calldata tokenIds) onlyUnpaused external {
        uint256 length = tokenIds.length;
        for (uint256 i = 0; i < length; i++) {
          _updateSellOrderTokenId(
              sellOrdersById[sellOrderAddresses[i]][sellOrderIds[i]],
              tokenIds[i]
          );
          _settle(buyOrdersById[buyOrderAddresses[i]][buyOrderIds[i]], sellOrdersById[sellOrderAddresses[i]][sellOrderIds[i]]);
        }
    }
    //
    // Internal, private method to settle buy orders with sell order.
    //
    function _settle(uint256[] memory buyOrderIds, address[] memory buyOrderAddresses, uint256[] memory sellOrderIds, address[] memory sellOrderAddresses) private {
        uint256 length = buyOrderIds.length;
        for (uint256 i = 0; i < length; i++) {
            _settle(
                buyOrdersById[buyOrderAddresses[i]][buyOrderIds[i]],
                sellOrdersById[sellOrderAddresses[i]][sellOrderIds[i]]
            );
        }
    }
    //
    // Internal, private method to settle a buy order with a sell order.
    function _settle(BuyOrder storage buyOrder, SellOrder storage sellOrder) private {
        if(
            sellOrder.settled || sellOrder.canceled ||
            buyOrder.settled || buyOrder.canceled
        ) { return; }

        uint256 proto = godsUnchainedCards.cardProtos(sellOrder.tokenId);
        uint256 quality = godsUnchainedCards.cardQualities(sellOrder.tokenId);
        require(buyOrder.price >= sellOrder.price, "Sell order exceeds what the buyer is willing to pay!");
        require(buyOrder.proto == proto && sellOrder.proto == proto, "Order protos are not matching!");
        require(buyOrder.quality == quality && sellOrder.quality == quality, "Order qualities are not matching!");
        
        sellOrder.settled = buyOrder.settled = true; // prevent reentrancy, before transfer or unlocking funds
        lockedInFunds = lockedInFunds.sub(buyOrder.price.add(buyOrder.fee));
        godsUnchainedCards.transferFrom(sellOrder.seller, buyOrder.buyer, sellOrder.tokenId);
        sellOrder.seller.transfer(sellOrder.price);

        emit Settled(buyOrder.id, sellOrder.id);
    }
    //
    // Public method to pause or unpause the exchange.
    //
    function setPausedTo(bool value) external onlyOwner {
        paused = value;
    }
    //
    // Set exchange fee.
    //
    function setExchangeFee(uint256 value) external onlyOwner {
        exchangeFee = value;
    }
    //
    // Funds withdrawal, considers unresolved orders and keeps user funds save.
    //
    function withdraw(address payable beneficiary, uint256 amount) external onlyOwner {
        require(lockedInFunds.add(amount) <= address(this).balance, "Not enough funds. Funds are partially locked from unsettled buy orders.");
        beneficiary.transfer(amount);
    }
    //
    // Standard contract ownership transfer.
    //
    function approveNextOwner(address payable _nextOwner) external onlyOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }
    //
    // Accept the next owner.
    //
    function acceptNextOwner() external {
        require(msg.sender == nextOwner, "The new owner has to accept the previously set new owner.");
        owner = nextOwner;
    }
    //
    // Contract may be destroyed only when there are no ongoing orders and no locked in funds.
    // So it would be required to either refund everybody or resolve all the orders,
    // before the contract can be killed
    //
    function kill() external onlyOwner {
        require(lockedInFunds == 0, "All orders need to be settled or refundeded before self-destruct.");
        selfdestruct(owner);
    }
    //
    // Fallback function deliberately left empty. It's primary use case
    // is to top up the exchange.
    //
    function () external payable {}
    
}