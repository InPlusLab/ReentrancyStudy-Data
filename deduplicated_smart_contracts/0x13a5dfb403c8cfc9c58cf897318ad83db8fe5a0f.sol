/**
 *Submitted for verification at Etherscan.io on 2019-09-23
*/

/*
 * Copyright 2019 Dolomite
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;


interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);

  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);

  function transfer(address to, uint256 value) external;
  function transferFrom(address from, address to, uint256 value) external;
  function approve(address spender, uint256 value) external;
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/// @title Utility Functions for bytes
/// @author Daniel Wang - <daniel@loopring.org>
library LoopringBytesUtil {
    function bytesToBytes32(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (bytes32)
    {
        return bytes32(bytesToUintX(b, offset, 32));
    }

    function bytesToUint(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (uint)
    {
        return bytesToUintX(b, offset, 32);
    }

    function bytesToAddress(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (address)
    {
        return address(bytesToUintX(b, offset, 20) & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function bytesToUint16(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (uint16)
    {
        return uint16(bytesToUintX(b, offset, 2) & 0xFFFF);
    }

    function bytesToUintX(
        bytes memory b,
        uint offset,
        uint numBytes
        )
        private
        pure
        returns (uint data)
    {
        require(b.length >= offset + numBytes, "INVALID_SIZE");
        assembly {
            data := mload(add(add(b, numBytes), offset))
        }
    }

    function subBytes(
        bytes memory b,
        uint offset
        )
        internal
        pure
        returns (bytes memory data)
    {
        require(b.length >= offset + 32, "INVALID_SIZE");
        assembly {
            data := add(add(b, 32), offset)
        }
    }
}


library DydxTypes {

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par  // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}


library DydxPosition {
    enum Status {
        Normal,
        Liquid,
        Vapor
    }

    struct Info {
        address owner;
        uint256 number;
    }

    struct Storage {
        mapping (uint256 => DydxTypes.Par) balances;
        Status status;
    }

    function equals(
        Info memory a,
        Info memory b
    )
        internal
        pure
        returns (bool)
    {
        return a.owner == b.owner && a.number == b.number;
    }
}


library DydxActions {

    enum ActionType {
        Deposit,   // supply tokens
        Withdraw,  // borrow tokens
        Transfer,  // transfer balance between accounts
        Buy,       // buy an amount of some token (externally)
        Sell,      // sell an amount of some token (externally)
        Trade,     // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize,  // use excess tokens to zero-out a completely negative account
        Call       // send arbitrary data to an address
    }

    enum AccountLayout {
        OnePrimary,
        TwoPrimary,
        PrimaryAndSecondary
    }

    enum MarketLayout {
        ZeroMarkets,
        OneMarket,
        TwoMarkets
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        DydxTypes.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct DepositArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info account;
        uint256 market;
        address from;
    }

    struct WithdrawArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info account;
        uint256 market;
        address to;
    }

    struct TransferArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info accountOne;
        DydxPosition.Info accountTwo;
        uint256 market;
    }

    struct BuyArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info account;
        uint256 makerMarket;
        uint256 takerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct SellArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info account;
        uint256 takerMarket;
        uint256 makerMarket;
        address exchangeWrapper;
        bytes orderData;
    }

    struct TradeArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info takerAccount;
        DydxPosition.Info makerAccount;
        uint256 inputMarket;
        uint256 outputMarket;
        address autoTrader;
        bytes tradeData;
    }

    struct LiquidateArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info solidAccount;
        DydxPosition.Info liquidAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct VaporizeArgs {
        DydxTypes.AssetAmount amount;
        DydxPosition.Info solidAccount;
        DydxPosition.Info vaporAccount;
        uint256 owedMarket;
        uint256 heldMarket;
    }

    struct CallArgs {
        DydxPosition.Info account;
        address callee;
        bytes data;
    }
}


interface IDydxExchangeWrapper {

  function exchange(
    address tradeOriginator,
    address receiver,
    address makerToken,
    address takerToken,
    uint256 requestedFillAmount,
    bytes calldata orderData
  )
    external
    returns (uint256);

  function getExchangeCost(
    address makerToken,
    address takerToken,
    uint256 desiredMakerToken,
    bytes calldata orderData
  )
    external
    view
    returns (uint256);
}


contract DydxProtocol {
  
  struct OperatorArg {
      address operator;
      bool trusted;
  }

  function operate(
      DydxPosition.Info[] calldata accounts,
      DydxActions.ActionArgs[] calldata actions
  ) external;

  function getMarketTokenAddress(uint256 marketId)
      external
      view
      returns (address);

  function setOperators(OperatorArg[] calldata args) external;
}


library LoopringTypes {

    enum TokenType { ERC20 }

    struct Header {
        uint version;
        uint numOrders;
        uint numRings;
        uint numSpendables;
    }

    struct Spendable {
        bool initialized;
        uint amount;
        uint reserved;
    }

    struct Order {
        uint      version;

        // required fields
        address   owner;
        address   tokenS;
        address   tokenB;
        uint      amountS;
        uint      amountB;
        uint      validSince;
        Spendable tokenSpendableS;
        Spendable tokenSpendableFee;

        // optional fields
        address   dualAuthAddr;
        address   broker;
        Spendable brokerSpendableS;
        Spendable brokerSpendableFee;
        address   orderInterceptor;
        address   wallet;
        uint      validUntil;
        bytes     sig;
        bytes     dualAuthSig;
        bool      allOrNone;
        address   feeToken;
        uint      feeAmount;
        int16     waiveFeePercentage;
        uint16    tokenSFeePercentage;    // Pre-trading
        uint16    tokenBFeePercentage;   // Post-trading
        address   tokenRecipient;
        uint16    walletSplitPercentage;

        // computed fields
        bool    P2P;
        bytes32 hash;
        address brokerInterceptor;
        uint    filledAmountS;
        uint    initialFilledAmountS;
        bool    valid;

        TokenType tokenTypeS;
        TokenType tokenTypeB;
        TokenType tokenTypeFee;
        bytes32 trancheS;
        bytes32 trancheB;
        bytes   transferDataS;
    }

    struct Participation {
        // required fields
        Order order;

        // computed fields
        uint splitS;
        uint feeAmount;
        uint feeAmountS;
        uint feeAmountB;
        uint rebateFee;
        uint rebateS;
        uint rebateB;
        uint fillAmountS;
        uint fillAmountB;
    }

    struct Ring {
        uint size;
        Participation[] participations;
        bytes32 hash;
        uint minerFeesToOrdersPercentage;
        bool valid;
    }
}


library Types {

  struct MarginRingSubmission {
    uint positionId;
    uint marginOrderIndex;
    uint marketIdS;
    uint marketIdB;
    uint fillAmountS;
    uint fillAmountB;
    bytes ringData;
  }

  struct RelayerInfo {
    uint positionId;
    uint marginOrderIndex;
    uint marketIdS;
    uint marketIdB;
    uint fillAmountS;
    uint fillAmountB;
  }

  enum MarginOrderType { OPEN_LONG, OPEN_SHORT, CLOSE_LONG, CLOSE_SHORT }
  
  struct MarginOrderDetails {
    MarginOrderType positionType;
    uint depositAmount;
    uint depositMarketId;
    uint expiration;

    // calculated
    address owner;
    address depositToken;
    uint withdrawalMarketId;
    bool isOpen;
    bool isLong;
  }

  enum OrderDataSide { BUY, SELL }

  struct OrderData {
    OrderDataSide side;
    uint fillAmountS;
    uint fillAmountB;
    bytes ringData;
    uint marginOrderIndex;
    address trader;

    // Helper (not encoded/decoded)
    bool bringToZero; // should bring the account balance to zero
  }
}


contract LoopringProtocol {
  address public lrcTokenAddress;
  address public delegateAddress;
  function submitRings(bytes calldata data) external;
}


contract ITradeDelegate {
  function batchTransfer(bytes32[] calldata batch) external;
}


library DecodeHelper {
  using LoopringBytesUtil for bytes;

  function decodeRelayerInfo(bytes memory self) internal pure returns (Types.RelayerInfo memory relayerInfo) {
    (
      relayerInfo.positionId,
      relayerInfo.marginOrderIndex,
      relayerInfo.marketIdS,
      relayerInfo.marketIdB,
      relayerInfo.fillAmountS,
      relayerInfo.fillAmountB
    ) = abi.decode(self, (uint, uint, uint, uint, uint, uint));
  }

  function decodeMarginTradeDetails(bytes memory self, bytes4 requiredOrderSelector) 
    internal 
    pure 
    returns (Types.MarginOrderDetails memory details) 
  {
    uint typeRaw;
    bytes4 orderSelector;

    (
      orderSelector,
      typeRaw,
      details.depositAmount,
      details.depositMarketId,
      details.expiration
    ) = abi.decode(self, (bytes4, uint, uint, uint, uint));

    require(orderSelector == requiredOrderSelector, "Margin order must have proper selector header in transferDataS");

    if (typeRaw == 0) details.positionType = Types.MarginOrderType.OPEN_LONG;
    else if (typeRaw == 1) details.positionType = Types.MarginOrderType.OPEN_SHORT;
    else if (typeRaw == 2) details.positionType = Types.MarginOrderType.CLOSE_LONG;
    else if (typeRaw == 3) details.positionType = Types.MarginOrderType.CLOSE_SHORT;
    else revert("Invalid margin order type");

    details.isOpen = typeRaw < 2;
    details.isLong = typeRaw == 0 || typeRaw == 2;
  }

  function decodeOrderData(bytes memory self) internal pure returns (Types.OrderData memory orderData) {
    uint sideRaw;

    (
      sideRaw,
      orderData.fillAmountS,
      orderData.fillAmountB,
      orderData.ringData,
      orderData.marginOrderIndex,
      orderData.trader
    ) = abi.decode(self, (uint, uint, uint, bytes, uint, address));

    orderData.side = sideRaw == 0 ? Types.OrderDataSide.BUY : Types.OrderDataSide.SELL;
  }

  /**
   * Find the location of the specified order in the given bytes and
   * decode it into a Loopring Order struct
   */
  uint private constant ORDER_STRUCT_SIZE = 38 * 32;

  function decodeMinimalOrderAtIndex(
    bytes memory self, 
    uint orderIndex, 
    address lrcTokenAddress
  ) 
    internal 
    pure 
    returns (LoopringTypes.Order memory order) 
  {
    
    // Read the header
    uint numOrders = self.bytesToUint16(2);
    uint numRings = self.bytesToUint16(4);

    // Calculate data pointers
    uint dataPtr;
    assembly { dataPtr := self }
    uint tablesPtr = dataPtr + 8 + (3 * 2);
    uint data = (tablesPtr + (30 * numOrders) * 2) + (numRings * 9) + 32;
    
    // Decode single order 
    bytes memory emptyBytes = new bytes(0);
    uint offset = orderIndex * ORDER_STRUCT_SIZE; // start offset at specified order index
    tablesPtr += 2;

    assembly {
      
      // order.owner
      offset := mul(and(mload(add(tablesPtr,  2)), 0xFFFF), 4)
      mstore(
        add(order,  32),
        and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      )

      // order.tokenS
      offset := mul(and(mload(add(tablesPtr,  4)), 0xFFFF), 4)
      mstore(
        add(order,  64),
        and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      )

      // order.tokenB
      offset := mul(and(mload(add(tablesPtr,  6)), 0xFFFF), 4)
      mstore(
        add(order,  96),
        and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      )

      // order.amountS
      offset := mul(and(mload(add(tablesPtr,  8)), 0xFFFF), 4)
      mstore(
        add(order, 128),
        mload(add(add(data, 32), offset))
      )

      // order.amountB
      offset := mul(and(mload(add(tablesPtr, 10)), 0xFFFF), 4)
      mstore(
        add(order, 160),
        mload(add(add(data, 32), offset))
      )

      // order.broker
      offset := mul(and(mload(add(tablesPtr, 20)), 0xFFFF), 4)
      mstore(
          add(order, 320),
          and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      )

      // lrcTokenAddress is the default value for feeToken
      mstore(add(data, 20), lrcTokenAddress)

      // order.feeToken
      offset := mul(and(mload(add(tablesPtr, 34)), 0xFFFF), 4)
      mstore(
          add(order, 608),
          and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      )

      // Restore default to 0
      mstore(add(data, 20), 0)

      // order.feeAmount
      offset := mul(and(mload(add(tablesPtr, 36)), 0xFFFF), 4)
      mstore(
          add(order, 640),
          mload(add(add(data, 32), offset))
      )

      // The owner is the default value of tokenRecipient
      mstore(add(data, 20), mload(add(order, 32))) // order.owner

      // order.tokenRecipient
      offset := mul(and(mload(add(tablesPtr, 44)), 0xFFFF), 4)
      mstore(
          add(order, 768),
          and(mload(add(add(data, 20), offset)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
      )

      // Restore default to 0
      mstore(add(data, 20), 0)

      // Default to empty bytes array for transferDataS
      mstore(add(data, 32), emptyBytes)

      // order.transferDataS
      offset := mul(and(mload(add(tablesPtr, 58)), 0xFFFF), 4)
      mstore(
          add(order, 1184),
          add(data, add(offset, 32))
      )
    }
  }
}


library MarginOrderHelper {
  using DecodeHelper for bytes;
  using SafeMath for uint;

  function getAmountB(LoopringTypes.Order memory self) internal pure returns (uint) {
    return calculateActualAmount(self, self.amountB, self.tokenB);
  }

  function getAmountS(LoopringTypes.Order memory self) internal pure returns (uint) {
    return calculateActualAmount(self, self.amountS, self.tokenS);
  }

  /**
   * Calculate actual amount by matching feeToken with the given token
   * and then adding/subtracting the feeAmount from the given amount
   */
  function calculateActualAmount(
    LoopringTypes.Order memory self, 
    uint fillAmount, 
    address token
  ) 
    internal 
    pure 
    returns (uint) 
  {
    if (token == self.tokenS && token == self.feeToken) return fillAmount.add(self.feeAmount);
    if (token == self.tokenB && token == self.feeToken) return fillAmount.sub(self.feeAmount);
    return fillAmount;
  }

  /**
   * Decode the fields necessary to open/close a long/short position from the Order.
   * These fields are encoded in the `bytes transferDataS` field of an order.
   */
  function getMarginOrderDetails(LoopringTypes.Order memory self, bytes4 requiredOrderSelector) 
    internal 
    view 
    returns (Types.MarginOrderDetails memory details) 
  {
    details = self.transferDataS.decodeMarginTradeDetails(requiredOrderSelector);
    details.owner = self.owner;
    details.depositToken = self.tokenB;
  }

  /**
   * Check the validity of the provided Loopring order and the 
   * margin order details encoded in it's transferDataS field
   * as well as confirming the validity of the information provided
   * by the relayer.
   */
  string constant INVALID_MARKET_S = "marketIdS provided by relayer must be have address equal to tokenS";
  string constant INVALID_MARKET_B = "marketIdB provided by relayer must be have address equal to tokenB";
  string constant INVALID_DEPOSIT_MARKET = "depositMarketId must have an address equal to tokenB";
  string constant INVALID_TOKEN_RECIPIENT = "Invalid tokenRecipient - must be set correctly";

  function checkValidity(
    LoopringTypes.Order memory self, 
    Types.RelayerInfo memory relayerInfo,
    Types.MarginOrderDetails memory marginDetails,
    DydxProtocol dydxProtocol
  ) 
    internal
    view 
  {
    // Set withdrawal market id
    marginDetails.withdrawalMarketId = relayerInfo.marketIdS;

    // Check that marketIdS from relayer matches order's tokenS
    address marketAddressS = dydxProtocol.getMarketTokenAddress(relayerInfo.marketIdS);
    require(self.tokenS == marketAddressS, INVALID_MARKET_S);

    // Check that marketIdB from relayer matches order's tokenB
    address marketAddressB = dydxProtocol.getMarketTokenAddress(relayerInfo.marketIdB);
    require(self.tokenB == marketAddressB, INVALID_MARKET_B);

    // Check that depositMarketId is equal to the order's tokenB
    if (marginDetails.isOpen) {
      require(marginDetails.depositMarketId == relayerInfo.marketIdB, INVALID_DEPOSIT_MARKET);
    }

    // Token recipient must be this contract
    require(self.tokenRecipient == address(this), INVALID_TOKEN_RECIPIENT);
  }
}


library ERC20SafeTransfer {

    function safeTransfer(
        address token,
        address to,
        uint256 value)
        internal
        returns (bool success)
    {
        // A transfer is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)

        // bytes4(keccak256("transfer(address,uint256)")) = 0xa9059cbb
        bytes memory callData = abi.encodeWithSelector(
            bytes4(0xa9059cbb),
            to,
            value
        );
        (success, ) = token.call(callData);
        return checkReturnValue(success);
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value)
        internal
        returns (bool success)
    {
        // A transferFrom is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)

        // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd
        bytes memory callData = abi.encodeWithSelector(
            bytes4(0x23b872dd),
            from,
            to,
            value
        );
        (success, ) = token.call(callData);
        return checkReturnValue(success);
    }

    function checkReturnValue(
        bool success
        )
        internal
        pure
        returns (bool)
    {
        // A transfer/transferFrom is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)
        if (success) {
            assembly {
                switch returndatasize()
                // Non-standard ERC20: nothing is returned so if 'call' was successful we assume the transfer succeeded
                case 0 {
                    success := 1
                }
                // Standard ERC20: a single boolean value is returned which needs to be true
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                // None of the above: not successful
                default {
                    success := 0
                }
            }
        }
        return success;
    }

}


library MiscHelper {
  using MiscHelper for *;
  using ERC20SafeTransfer for address;

  // ----------------------------------------------
  // TradeDelegate

  /**
   * Transfers tokens on behalf of a user. Transfers are done through 
   * Loopring's TradeDelegate which has a `batchTransfer` method that takes in encoded bytes
   */
  function transferTokenFrom(
    ITradeDelegate self, 
    address token,
    address from, 
    address to, 
    uint256 amount
  ) internal {
    bytes32[] memory transferData = new bytes32[](4);
    transferData[0] = token.toBytes32();
    transferData[1] = from.toBytes32();
    transferData[2] = to.toBytes32();
    transferData[3] = bytes32(amount);

    self.batchTransfer(transferData);
  }

  // ----------------------------------------------
  // ERC20

  function safeTransfer(IERC20 self, address to, uint amount) internal {
    require(address(self).safeTransfer(to, amount), "Transfer failed");
  }

  function safeTransferFrom(IERC20 self, address from, address to, uint amount) internal {
    require(address(self).safeTransferFrom(from, to, amount), "TransferFrom failed");
  }

  // ----------------------------------------------
  // Address

  function toPayable(address self) internal pure returns (address payable) {
    return address(uint160(self));
  }

  function toBytes32(address self) internal pure returns (bytes32) {
    return bytes32(uint256(self));
  }
}


library OrderDataHelper {

  /**
   * Encode exchange action helper
   */
  function encodeWithRingData(Types.OrderData memory self, bytes memory ringData) 
    internal 
    returns (bytes memory) 
  {
    self.ringData = ringData;
    return abi.encode(
      uint(self.side), 
      self.fillAmountS, 
      self.fillAmountB, 
      self.ringData,
      self.marginOrderIndex,
      self.trader
    );
  }
}


interface IDolomiteMarginTradingBroker {
  
  /*
   * Called by the DolomiteMarginTrading contract to request approval to deposit funds
   * into itself (the msg.sender) and then into DyDx Solo. Check that the msg.sender is
   * the DolomiteMarginTrading contract
   */
  function brokerMarginRequestApproval(address owner, address token, uint amount) external;

  /*
   * Called by the DolomiteMarginTrading contract to get the address that borrowed funds are expected
   * to be placed into for Loopring settlement. For DolomiteDirectV1, for example, this function 
   * returns the address for the owner's DepositContract 
   */
  function brokerMarginGetTrader(address owner, bytes calldata orderData) external returns (address);
}


contract Globals {
  using MiscHelper for *;

  string constant public ORDER_SIGNATURE = "dolomiteMarginOrder(version 1.0.0)";
  bytes4 constant public ORDER_SELECTOR = bytes4(keccak256(bytes(ORDER_SIGNATURE)));

  address internal LRC_TOKEN_ADDRESS;
  LoopringProtocol internal LOOPRING_PROTOCOL;
  ITradeDelegate internal TRADE_DELEGATE;
  DydxProtocol internal DYDX_PROTOCOL;
  address internal DYDX_EXPIRATION_CONTRACT;

  constructor(
    address payable loopringRingSubmitterAddress, 
    address dydxProtocolAddress,
    address dydxExpirationContractAddress
  ) public {

    LOOPRING_PROTOCOL = LoopringProtocol(loopringRingSubmitterAddress);
    LRC_TOKEN_ADDRESS = LOOPRING_PROTOCOL.lrcTokenAddress();

    address payable tradeDelegateAddress = LOOPRING_PROTOCOL.delegateAddress().toPayable();
    TRADE_DELEGATE = ITradeDelegate(tradeDelegateAddress);
    
    DYDX_PROTOCOL = DydxProtocol(dydxProtocolAddress);
    DYDX_EXPIRATION_CONTRACT = dydxExpirationContractAddress;
  }
}


/**
 * @title MarginRingSubmitterWrapper
 * @author Zack Rubenstein
 *
 * Entry point for margin trading though Dydx and Loopring. Dolomite
 * relay calls `submitRingsWithMarginOrder` passing the same ringData 
 * that would be passed to Loopring's `submitRings` plus some additional
 * info about the margin order being filled in the rings.
 */
contract MarginRingSubmitterWrapper is Globals {
  using MiscHelper for *;
  using DecodeHelper for bytes;
  using MarginOrderHelper for LoopringTypes.Order;
  using OrderDataHelper for Types.OrderData;

  event OpenPosition(address indexed trader, uint indexed id);
  event ClosePosition(address indexed trader, uint indexed id);

  /*
   * TODO: make this the default way to use this contract
   */
  function structuredSubmitRingsWithMarginOrder(Types.MarginRingSubmission calldata submissionData) external {
    this.submitRingsWithMarginOrder(
      submissionData.ringData,
      abi.encode(
        submissionData.positionId,
        submissionData.marginOrderIndex,
        submissionData.marketIdS,
        submissionData.marketIdB,
        submissionData.fillAmountS,
        submissionData.fillAmountB
      )
    );
  }

  /**
   * Loopring protocol middleman that opens/closes a margin position with Dy/dx using
   * Loopring as the medium of exchange
   */
  function submitRingsWithMarginOrder(
    bytes calldata ringData, 
    bytes calldata relayData
  ) external {

    (
      Types.RelayerInfo memory relayerInfo,
      LoopringTypes.Order memory order,
      Types.MarginOrderDetails memory marginDetails
    ) = decodeParams(ringData, relayData);

    // ----------------------
    // Construct order data

    Types.OrderData memory orderData;

    if (order.broker == address(0x0)) {
      orderData.trader = order.owner;
    } else {
      orderData.trader = IDolomiteMarginTradingBroker(order.broker).brokerMarginGetTrader(
        order.owner, 
        order.transferDataS
      );
    }

    if (marginDetails.isOpen && marginDetails.isLong) {
      // Open Long
      orderData.side = Types.OrderDataSide.BUY;
      orderData.fillAmountS = order.calculateActualAmount(relayerInfo.fillAmountS, order.tokenS);
      orderData.fillAmountB = order.getAmountB();

    } else if (marginDetails.isOpen && !marginDetails.isLong) {
      // Open Short
      orderData.side = Types.OrderDataSide.SELL;
      orderData.fillAmountS = order.getAmountS();
      orderData.fillAmountB = order.calculateActualAmount(relayerInfo.fillAmountB, order.tokenB);

    } else if (!marginDetails.isOpen && marginDetails.isLong) {
      // Close Long
      orderData.side = Types.OrderDataSide.BUY;
      orderData.fillAmountS = order.getAmountS();
      orderData.fillAmountB = order.calculateActualAmount(relayerInfo.fillAmountB, order.tokenB);
      orderData.bringToZero = true;

    } else if (!marginDetails.isOpen && !marginDetails.isLong) {
      // Close Short
      orderData.side = Types.OrderDataSide.BUY;
      orderData.fillAmountS = order.calculateActualAmount(relayerInfo.fillAmountS, order.tokenS);
      orderData.fillAmountB = order.getAmountB();
      orderData.bringToZero = true;
    }

    bytes memory encodedOrderData = orderData.encodeWithRingData(ringData);

    // ----------------------
    // Construct dydx actions

    DydxActions.ActionArgs[] memory actions;
    DydxPosition.Info[] memory positions = new DydxPosition.Info[](1);
    
    // Add dydx position (account) that actions will operate on
    positions[0] = DydxPosition.Info({
      owner: orderData.trader,
      number: marginDetails.isOpen ? generatePositionId(ringData, relayData) : relayerInfo.positionId
    });

    // Construct exchange action (buy or sell)
    DydxActions.ActionArgs memory exchangeAction;
    exchangeAction.otherAddress = address(this);
    exchangeAction.data = encodedOrderData;

    if (orderData.side == Types.OrderDataSide.BUY) {
      // Buy Order
      exchangeAction.actionType = DydxActions.ActionType.Buy;
      exchangeAction.primaryMarketId = relayerInfo.marketIdB;
      exchangeAction.secondaryMarketId = relayerInfo.marketIdS;

      if (orderData.bringToZero) {
        // Buy enough to repay the loan (end balance will be 0)
        exchangeAction.amount = DydxTypes.AssetAmount({
          sign: true,
          denomination: DydxTypes.AssetDenomination.Wei,
          ref: DydxTypes.AssetReference.Target,
          value: 0
        });

      } else {
        exchangeAction.amount = DydxTypes.AssetAmount({
          sign: true,
          denomination: DydxTypes.AssetDenomination.Wei,
          ref: DydxTypes.AssetReference.Delta,
          value: orderData.fillAmountB
        });
      }
      
    } else if (orderData.side == Types.OrderDataSide.SELL) {
      // Sell Order
      exchangeAction.actionType = DydxActions.ActionType.Sell;
      exchangeAction.primaryMarketId = relayerInfo.marketIdS;
      exchangeAction.secondaryMarketId = relayerInfo.marketIdB;
      exchangeAction.amount = DydxTypes.AssetAmount({
        sign: false,
        denomination: DydxTypes.AssetDenomination.Wei,
        ref: DydxTypes.AssetReference.Delta,
        value: orderData.fillAmountS
      });
    }

    if (marginDetails.isOpen) {
      
      if (order.broker == address(0x0)) {
        // Pull deposit funds from owner to this contract
        TRADE_DELEGATE.transferTokenFrom(
          marginDetails.depositToken, 
          marginDetails.owner,
          address(this), 
          marginDetails.depositAmount
        );
      } else {

        // Request approval for deposit funds from the broker
        IDolomiteMarginTradingBroker(order.broker).brokerMarginRequestApproval(
          marginDetails.owner, 
          marginDetails.depositToken, 
          marginDetails.depositAmount
        );

        // Pull deposit funds from the broker into this contract
        IERC20(marginDetails.depositToken).transferFrom(
          order.broker,
          address(this),
          marginDetails.depositAmount
        );
      }

      // Set allowance for dydx contract
      IERC20(marginDetails.depositToken).approve(
        address(DYDX_PROTOCOL), 
        marginDetails.depositAmount
      );

      // Construct action to deposit funds from this contract into a dydx position
      DydxActions.ActionArgs memory depositAction;
      depositAction.actionType = DydxActions.ActionType.Deposit;
      depositAction.primaryMarketId = marginDetails.depositMarketId;
      depositAction.otherAddress = address(this);
      depositAction.amount = DydxTypes.AssetAmount({
        sign: true,
        denomination: DydxTypes.AssetDenomination.Wei,
        ref: DydxTypes.AssetReference.Delta,
        value: marginDetails.depositAmount
      });

      if (marginDetails.expiration == 0) {
        actions = new DydxActions.ActionArgs[](2);
      } else {
        // Construct action to set the expiration of the dydx position
        DydxActions.ActionArgs memory expirationAction;
        expirationAction.actionType = DydxActions.ActionType.Call;
        expirationAction.otherAddress = DYDX_EXPIRATION_CONTRACT;
        expirationAction.data = encodeExpiration(relayerInfo.marketIdS, marginDetails.expiration);

        actions = new DydxActions.ActionArgs[](3);
        actions[2] = expirationAction;
      }

      // Build deposit and exchange actions in correct order
      actions[0] = depositAction;
      actions[1] = exchangeAction;
      
    } else {
      // Construct action to withdraw funds to order owner or order broker trader (orderData.trader)
      DydxActions.ActionArgs memory withdrawAction;
      withdrawAction.actionType = DydxActions.ActionType.Withdraw;
      withdrawAction.primaryMarketId = marginDetails.withdrawalMarketId;
      withdrawAction.otherAddress = orderData.trader;
      withdrawAction.amount = DydxTypes.AssetAmount({
        sign: true,
        denomination: DydxTypes.AssetDenomination.Wei,
        ref: DydxTypes.AssetReference.Target,
        value: 0
      });

      // Build actions in correct order
      actions = new DydxActions.ActionArgs[](2);
      actions[0] = exchangeAction;
      actions[1] = withdrawAction;
    }

    // ----------------------
    // Perform operation with dydx

    DYDX_PROTOCOL.operate(positions, actions);

    // ----------------------
    // Finalize margin order 

    if (marginDetails.isOpen) emit OpenPosition(positions[0].owner, positions[0].number);
    else emit ClosePosition(positions[0].owner, positions[0].number);
  }

  // ============================================
  // Helpers

  function decodeParams(bytes memory ringData, bytes memory relayData)
    private
    view
    returns (
      Types.RelayerInfo memory relayerInfo,
      LoopringTypes.Order memory order,
      Types.MarginOrderDetails memory marginDetails
    ) 
  {
    relayerInfo = relayData.decodeRelayerInfo();
    order = ringData.decodeMinimalOrderAtIndex(
      relayerInfo.marginOrderIndex, 
      LRC_TOKEN_ADDRESS
    );
    marginDetails = order.getMarginOrderDetails(ORDER_SELECTOR);
    order.checkValidity(relayerInfo, marginDetails, DYDX_PROTOCOL);
  }

  function encodeExpiration(uint marketId, uint expiration) private pure returns (bytes memory) {
    return abi.encode(marketId, expiration);
  }

  function generatePositionId(bytes memory ringData, bytes memory relayData)
    private
    pure
    returns (uint)
  {
    return uint(keccak256(abi.encode(ringData, relayData)));
  }
}


/**
 * @title LoopringV2ExchangeWrapper
 * @author Zack Rubenstein
 *
 * Dydx compatible `ExchangeWrapper` implementation to enable
 * Loopring ring settlement to be performed through Dydx to settle
 * trades for performing margin trading with Dydx and Loopring
 */
contract LoopringV2ExchangeWrapper is IDydxExchangeWrapper, Globals {
  using MiscHelper for *;
  using DecodeHelper for bytes;
  using SafeMath for uint;

  address constant ZERO_ADDRESS = address(0x0);

  string constant INVALID_MSG_SENDER = "The msg.sender must be Dydx protocol";
  string constant INVALID_RECEIVER = "Bought token receiver must be Dydx protocol";
  string constant INVALID_TOKEN_RECIPIENT = "Invalid tokenRecipient in Loopring order";
  string constant INVALID_TRADE_ORIGINATOR = "Loopring order owner must be originator";
  string constant INCORRECT_FILL_AMOUNT = "Amount received must be exactly equal to expected amountB (either provided by relayer or order)";
  string constant NOTHING_RECEIVED = "Amount received is zero. Ring submission most likely failed";

  /**
   * Exchange some amount of takerToken for makerToken.
   *
   * @param  tradeOriginator      Address of the initiator of the trade (however, this value
   *                              cannot always be trusted as it is set at the discretion of the
   *                              msg.sender)
   * @param  receiver             Address to set allowance on once the trade has completed
   * @param  makerToken           Address of makerToken, the token to receive
   * @param  takerToken           Address of takerToken, the token to pay
   * @param  requestedFillAmount  Amount of takerToken being paid
   * @param  orderData            Arbitrary bytes data for any information to pass to the exchange
   * @return                      The amount of makerToken received
   */
  function exchange(
    address tradeOriginator,
    address receiver,
    address makerToken,
    address takerToken,
    uint256 requestedFillAmount,
    bytes calldata orderData
  ) external returns (uint256) {
    require(msg.sender == address(DYDX_PROTOCOL), INVALID_MSG_SENDER);
    require(receiver == address(DYDX_PROTOCOL), INVALID_RECEIVER);

    Types.OrderData memory orderInfo = orderData.decodeOrderData();
    LoopringTypes.Order memory order = orderInfo.ringData.decodeMinimalOrderAtIndex(
      orderInfo.marginOrderIndex,
      ZERO_ADDRESS
    );

    require(order.tokenRecipient == address(this), INVALID_TOKEN_RECIPIENT);
    require(order.broker == address(0x0)
      ? tradeOriginator == order.owner
      : tradeOriginator == orderInfo.trader
    , INVALID_TRADE_ORIGINATOR);

    // Transfer sell tokens to order owner
    IERC20(takerToken).safeTransfer(orderInfo.trader, requestedFillAmount);

    // Record balance of buy tokens prior to ring submission
    uint balanceBeforeSubmission = IERC20(makerToken).balanceOf(address(this));

    // Submit & settle rings
    LOOPRING_PROTOCOL.submitRings(orderInfo.ringData);

    // Get actual amount of tokens received
    uint amountReceived = IERC20(makerToken).balanceOf(address(this)).sub(balanceBeforeSubmission);
    require(amountReceived > 0, NOTHING_RECEIVED);
    require(amountReceived == orderInfo.fillAmountB, INCORRECT_FILL_AMOUNT);

    // Allow Dy/dx to pull received tokens from this contract
    IERC20(makerToken).approve(receiver, amountReceived);

    return amountReceived;
  }

  /**
   * Get amount of takerToken required to buy a certain amount of makerToken for a given trade.
   * Should match the takerToken amount used in exchangeForAmount. If the order cannot provide
   * exactly desiredMakerToken, then it must return the price to buy the minimum amount greater
   * than desiredMakerToken
   *
   * @param  makerToken         Address of makerToken, the token to receive
   * @param  takerToken         Address of takerToken, the token to pay
   * @param  desiredMakerToken  Amount of makerToken requested
   * @param  orderData          Arbitrary bytes data for any information to pass to the exchange
   * @return                    Amount of takerToken the needed to complete the exchange
   */
  function getExchangeCost(
    address makerToken,
    address takerToken,
    uint256 desiredMakerToken,
    bytes calldata orderData
  ) external view returns (uint256) {
    return orderData.decodeOrderData().fillAmountS;
  }
}


/**
 * @title DolomiteMarginTrading
 * @author Zack Rubenstein
 *
 * Combines `MarginRingSubmitterWrapper` and `LoopringV2ExchangeWrapper` into one
 * contract. Takes in the address to Loopring's `RingSubmitter` contract and
 * Dy/Dx's `SoloMargin` contract to intialize the wrappers that integrate the two.
 */
contract DolomiteMarginTrading is Globals, MarginRingSubmitterWrapper, LoopringV2ExchangeWrapper {

  constructor(
    address payable loopringRingSubmitterAddress, 
    address dydxProtocolAddress,
    address dydxExpirationContractAddress
  ) 
    public 
    Globals(loopringRingSubmitterAddress, dydxProtocolAddress, dydxExpirationContractAddress) { }

}