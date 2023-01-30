/**
 *Submitted for verification at Etherscan.io on 2019-09-10
*/

// File: @airswap/types/contracts/Types.sol

/*
  Copyright 2019 Swap Holdings Ltd.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;

/**
  * @title Types: Library of Swap Protocol Types and Hashes
  */
library Types {

  bytes constant internal EIP191_HEADER = "\x19\x01";

  struct Order {
    uint256 nonce;        // Unique per order and should be sequential
    uint256 expiry;       // Expiry in seconds since 1 January 1970
    Party maker;          // Party to the trade that sets terms
    Party taker;          // Party to the trade that accepts terms
    Party affiliate;      // Party compensated for facilitating (optional)
    Signature signature;  // Signature of the order
  }

  struct Party {
    address wallet;       // Wallet address of the party
    address token;        // Contract address of the token
    uint256 param;        // Value (ERC-20) or ID (ERC-721)
    bytes4 kind;          // Interface ID of the token
  }

  struct Signature {
    address signer;       // Address of the wallet used to sign
    uint8 v;              // `v` value of an ECDSA signature
    bytes32 r;            // `r` value of an ECDSA signature
    bytes32 s;            // `s` value of an ECDSA signature
    bytes1 version;       // EIP-191 signature version
  }

  bytes32 constant DOMAIN_TYPEHASH = keccak256(abi.encodePacked(
    "EIP712Domain(",
    "string name,",
    "string version,",
    "address verifyingContract",
    ")"
  ));

  bytes32 constant ORDER_TYPEHASH = keccak256(abi.encodePacked(
    "Order(",
    "uint256 nonce,",
    "uint256 expiry,",
    "Party maker,",
    "Party taker,",
    "Party affiliate",
    ")",
    "Party(",
    "address wallet,",
    "address token,",
    "uint256 param,",
    "bytes4 kind",
    ")"
  ));

  bytes32 constant PARTY_TYPEHASH = keccak256(abi.encodePacked(
    "Party(",
    "address wallet,",
    "address token,",
    "uint256 param,",
    "bytes4 kind",
    ")"
  ));

  /**
    * @notice Hash an order into bytes32
    * @dev EIP-191 header and domain separator included
    * @param _order Order
    * @param _domainSeparator bytes32
    * @return bytes32 returns a keccak256 abi.encodePacked value
    */
  function hashOrder(
    Order calldata _order,
    bytes32 _domainSeparator
  ) external pure returns (bytes32) {
    return keccak256(abi.encodePacked(
      EIP191_HEADER,
      _domainSeparator,
      keccak256(abi.encode(
        ORDER_TYPEHASH,
        _order.nonce,
        _order.expiry,
        keccak256(abi.encode(
          PARTY_TYPEHASH,
          _order.maker.wallet,
          _order.maker.token,
          _order.maker.param,
          _order.maker.kind
        )),
        keccak256(abi.encode(
          PARTY_TYPEHASH,
          _order.taker.wallet,
          _order.taker.token,
          _order.taker.param,
          _order.taker.kind
        )),
        keccak256(abi.encode(
          PARTY_TYPEHASH,
          _order.affiliate.wallet,
          _order.affiliate.token,
          _order.affiliate.param,
          _order.affiliate.kind
        ))
      ))
    ));
  }

  /**
    * @notice Hash domain parameters into bytes32
    * @dev Used for signature validation (EIP-712)
    * @param _name bytes
    * @param _version bytes
    * @param _verifyingContract address
    * @return bytes32 returns a keccak256 abi.encodePacked value
    */
  function hashDomain(
    bytes calldata _name,
    bytes calldata _version,
    address _verifyingContract
  ) external pure returns (bytes32) {
    return keccak256(abi.encode(
      DOMAIN_TYPEHASH,
      keccak256(_name),
      keccak256(_version),
      _verifyingContract
    ));
  }

}

// File: @airswap/swap/contracts/interfaces/ISwap.sol

interface ISwap {

  event Swap(
    uint256 indexed nonce,
    uint256 timestamp,
    address indexed makerWallet,
    uint256 makerParam,
    address makerToken,
    address indexed takerWallet,
    uint256 takerParam,
    address takerToken,
    address affiliateWallet,
    uint256 affiliateParam,
    address affiliateToken
  );

  event Cancel(
    uint256 indexed nonce,
    address indexed makerWallet
  );

  event Invalidate(
    uint256 indexed nonce,
    address indexed makerWallet
  );

  event Authorize(
    address indexed approverAddress,
    address indexed delegateAddress,
    uint256 expiry
  );

  event Revoke(
    address indexed approverAddress,
    address indexed delegateAddress
  );

  function delegateApprovals(address, address) external returns (uint256);
  function makerOrderStatus(address, uint256) external returns (byte);
  function makerMinimumNonce(address) external returns (uint256);

  /**
    * @notice Atomic Token Swap
    * @param order Types.Order
    */
  function swap(
    Types.Order calldata order
  ) external;

  /**
    * @notice Cancel one or more open orders by nonce
    * @param _nonces uint256[]
    */
  function cancel(
    uint256[] calldata _nonces
  ) external;

  /**
    * @notice Invalidate all orders below a nonce value
    * @param _minimumNonce uint256
    */
  function invalidate(
    uint256 _minimumNonce
  ) external;

  /**
    * @notice Authorize a delegate
    * @param _delegate address
    * @param _expiry uint256
    */
  function authorize(
    address _delegate,
    uint256 _expiry
  ) external;

  /**
    * @notice Revoke an authorization
    * @param _delegate address
    */
  function revoke(
    address _delegate
  ) external;

}

// File: @airswap/tokens/contracts/interfaces/IWETH.sol

interface IWETH {

  function deposit() external payable;
  function withdraw(uint256) external;
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/Wrapper.sol

/**
  * @title Wrapper: Send and receive ether for WETH trades
  */
contract Wrapper {

  // Swap contract to settle trades
  ISwap public swapContract;

  // WETH contract to wrap ether
  IWETH public wethContract;

  uint256 constant MAX_INT = 2**256 - 1;
  /**
    * @notice Contract Constructor
    * @param _swapContract address
    * @param _wethContract address
    */
  constructor(
    address _swapContract,
    address _wethContract
  ) public {
    swapContract = ISwap(_swapContract);
    wethContract = IWETH(_wethContract);

    // Sets unlimited allowance for the Wrapper contract.
    wethContract.approve(_swapContract, MAX_INT);
  }

  /**
    * @notice Required when withdrawing from WETH
    * @dev During unwraps, WETH.withdraw transfers ether to msg.sender (this contract)
    */
  function() external payable {
    // Ensure the message sender is the WETH contract.
    if(msg.sender != address(wethContract)) {
      revert("DO_NOT_SEND_ETHER");
    }
  }

  /**
    * @notice Send an Order
    * @dev Taker must authorize this contract on the swapContract
    * @dev Taker must approve this contract on the wethContract
    * @param _order Types.Order
    */
  function swap(
    Types.Order calldata _order
  ) external payable {

    // Ensure message sender is taker wallet.
    require(_order.taker.wallet == msg.sender,
      "SENDER_MUST_BE_TAKER");

    // The taker is sending ether that must be wrapped.
    if (_order.taker.token == address(wethContract)) {

      // Ensure  message value is taker param.
      require(_order.taker.param == msg.value,
        "VALUE_MUST_BE_SENT");

      // Wrap (deposit) the ether.
      wethContract.deposit.value(msg.value)();

      // Transfer from wrapper to taker.
      wethContract.transfer(_order.taker.wallet, _order.taker.param);

    } else {

      // Ensure no unexpected ether is sent.
      require(msg.value == 0,
        "VALUE_MUST_BE_ZERO");

    }

    // Perform the swap.
    swapContract.swap(_order);

    // The taker is receiving ether that must be unwrapped.
    if (_order.maker.token == address(wethContract)) {

      // Transfer from the taker to the wrapper.
      wethContract.transferFrom(_order.taker.wallet, address(this), _order.maker.param);

      // Unwrap (withdraw) the ether.
      wethContract.withdraw(_order.maker.param);

      // Transfer ether to the user.
      msg.sender.transfer(_order.maker.param);

    }
  }
}