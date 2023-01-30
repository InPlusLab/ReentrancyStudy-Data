/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

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

// File: @airswap/types/contracts/Types.sol



/**
  * @title Types: Library of Swap Protocol Types and Hashes
  */
library Types {

  bytes constant internal EIP191_HEADER = "\x19\x01";

  struct Party {
    address wallet;   // Wallet address of the party
    address token;    // Contract address of the token
    uint256 param;    // Value (ERC-20) or ID (ERC-721)
    bytes4 kind;      // Interface ID of the token
  }

  struct Order {
    uint256 nonce;    // Unique per order and should be sequential
    uint256 expiry;   // Expiry in seconds since 1 January 1970
    Party maker;      // Party to the trade that sets terms
    Party taker;      // Party to the trade that accepts terms
    Party affiliate;  // Party compensated for facilitating (optional)
  }

  struct Signature {
    address signer;   // Address of the wallet used to sign
    uint8 v;          // `v` value of an ECDSA signature
    bytes32 r;        // `r` value of an ECDSA signature
    bytes32 s;        // `s` value of an ECDSA signature
    bytes1 version;   // EIP-191 signature version
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

// File: @airswap/swap/interfaces/ISwap.sol



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
    * @param signature Types.Signature
    */
  function swap(
    Types.Order calldata order,
    Types.Signature calldata signature
  ) external;

  /**
    * @notice Atomic Token Swap (Simple)
    * @param _nonce uint256
    * @param _expiry uint256
    * @param _makerWallet address
    * @param _makerParam uint256
    * @param _makerToken address
    * @param _takerWallet address
    * @param _takerParam uint256
    * @param _takerToken address
    * @param _v uint8
    * @param _r bytes32
    * @param _s bytes32
    */
  function swapSimple(
    uint256 _nonce,
    uint256 _expiry,
    address _makerWallet,
    uint256 _makerParam,
    address _makerToken,
    address _takerWallet,
    uint256 _takerParam,
    address _takerToken,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



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

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol



/**
 * @dev Interface of the ERC165 standard, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-165).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others (`ERC165Checker`).
 *
 * For an implementation, see `ERC165`.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol



/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either `approve` or `setApproveForAll`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either `approve` or `setApproveForAll`.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: contracts/Swap.sol



/**
  * @title Swap: The Atomic Swap used by the Swap Protocol
  */
contract Swap is ISwap {

  // Domain and version for use in signatures (EIP-712)
  bytes constant internal DOMAIN_NAME = "SWAP";
  bytes constant internal DOMAIN_VERSION = "2";

  // Unique domain identifier for use in signatures (EIP-712)
  bytes32 private domainSeparator;

  // Possible order statuses
  byte constant private OPEN = 0x00;
  byte constant private TAKEN = 0x01;
  byte constant private CANCELED = 0x02;

  // ERC-20 (fungible token) interface identifier (ERC-165)
  bytes4 constant internal ERC20_INTERFACE_ID = 0x277f8169;
  /*
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('allowance(address,address)'));
  */

  // ERC-721 (non-fungible token) interface identifier (ERC-165)
  bytes4 constant internal ERC721_INTERFACE_ID = 0x80ac58cd;
  /*
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('getApproved(uint256)')) ^
    bytes4(keccak256('setApprovalForAll(address,bool)')) ^
    bytes4(keccak256('isApprovedForAll(address,address)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
    bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'));
  */

  // Mapping of peer address to delegate address and expiry.
  mapping (address => mapping (address => uint256)) public delegateApprovals;

  // Mapping of makers to orders by nonce as TAKEN (0x01) or CANCELED (0x02)
  mapping (address => mapping (uint256 => byte)) public makerOrderStatus;

  // Mapping of makers to an optionally set minimum valid nonce
  mapping (address => uint256) public makerMinimumNonce;

  /**
    * @notice Contract Constructor
    * @dev Sets domain for signature validation (EIP-712)
    */
  constructor() public {
    domainSeparator = Types.hashDomain(
      DOMAIN_NAME,
      DOMAIN_VERSION,
      address(this)
    );
  }

  /**
    * @notice Atomic Token Swap
    * @param _order Types.Order
    * @param _signature Types.Signature
    */
  function swap(
    Types.Order calldata _order,
    Types.Signature calldata _signature
  )
    external
  {

    // Ensure the order is not expired.
    require(_order.expiry > block.timestamp,
      "ORDER_EXPIRED");

    // Ensure the order is not already taken.
    require(makerOrderStatus[_order.maker.wallet][_order.nonce] != TAKEN,
      "ORDER_ALREADY_TAKEN");

    // Ensure the order is not already canceled.
    require(makerOrderStatus[_order.maker.wallet][_order.nonce] != CANCELED,
      "ORDER_ALREADY_CANCELED");

    // Ensure the order nonce is above the minimum.
    require(_order.nonce >= makerMinimumNonce[_order.maker.wallet],
      "NONCE_TOO_LOW");

    // Mark the order TAKEN (0x01).
    makerOrderStatus[_order.maker.wallet][_order.nonce] = TAKEN;

    // Validate the taker side of the trade.
    address finalTakerWallet;

    if (_order.taker.wallet == address(0)) {
      /**
        * Taker is not specified. The sender of the transaction becomes
        * the taker of the _order.
        */
      finalTakerWallet = msg.sender;

    } else {
      /**
        * Taker is specified. If the sender is not the specified taker,
        * determine whether the sender has been authorized by the taker.
        */
      if (msg.sender != _order.taker.wallet) {
        require(isAuthorized(_order.taker.wallet, msg.sender),
          "SENDER_UNAUTHORIZED");
      }
      // The specified taker is all clear.
      finalTakerWallet = _order.taker.wallet;

    }

    // Validate the maker side of the trade.
    if (_signature.v == 0) {
      /**
        * Signature is not provided. The maker may have authorized the sender
        * to swap on its behalf, which does not require a _signature.
        */
      require(isAuthorized(_order.maker.wallet, msg.sender),
        "SIGNER_UNAUTHORIZED");

    } else {
      /**
        * The signature is provided. Determine whether the signer is
        * authorized by the maker and if so validate the signature itself.
        */
      require(isAuthorized(_order.maker.wallet, _signature.signer),
        "SIGNER_UNAUTHORIZED");

      // Ensure the signature is valid.
      require(isValid(_order, _signature, domainSeparator),
        "SIGNATURE_INVALID");

    }
    // Transfer token from taker to maker.
    transferToken(
      finalTakerWallet,
      _order.maker.wallet,
      _order.taker.param,
      _order.taker.token,
      _order.taker.kind
    );

    // Transfer token from maker to taker.
    transferToken(
      _order.maker.wallet,
      finalTakerWallet,
      _order.maker.param,
      _order.maker.token,
      _order.maker.kind
    );

    // Transfer token from maker to affiliate if specified.
    if (_order.affiliate.wallet != address(0)) {
      transferToken(
        _order.maker.wallet,
        _order.affiliate.wallet,
        _order.affiliate.param,
        _order.affiliate.token,
        _order.affiliate.kind
      );
    }

    emit Swap(_order.nonce, block.timestamp,
      _order.maker.wallet, _order.maker.param, _order.maker.token,
      finalTakerWallet, _order.taker.param, _order.taker.token,
      _order.affiliate.wallet, _order.affiliate.param, _order.affiliate.token
    );
  }

  /**
    * @notice Atomic Token Swap (Simple)
    * @dev Supports fungible token transfers (ERC-20)
    * @param _nonce uint256
    * @param _expiry uint256
    * @param _makerWallet address
    * @param _makerParam uint256
    * @param _makerToken address
    * @param _takerWallet address
    * @param _takerParam uint256
    * @param _takerToken address
    * @param _v uint8
    * @param _r bytes32
    * @param _s bytes32
    */
  function swapSimple(
    uint256 _nonce,
    uint256 _expiry,
    address _makerWallet,
    uint256 _makerParam,
    address _makerToken,
    address _takerWallet,
    uint256 _takerParam,
    address _takerToken,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  )
      external
  {

    // Ensure the order has not already been taken or canceled.
    require(makerOrderStatus[_makerWallet][_nonce] == OPEN,
      "ORDER_UNAVAILABLE");

    // Ensure the order is not expired.
    require(_expiry > block.timestamp,
      "ORDER_EXPIRED");

    require(_nonce >= makerMinimumNonce[_makerWallet],
      "NONCE_TOO_LOW");

    // Validate the taker side of the trade.
    address finalTakerWallet;

    if (_takerWallet == address(0)) {

      // Set a null taker to be the order sender.
      finalTakerWallet = msg.sender;

    } else {

      // Ensure the order sender is authorized.
      if (msg.sender != _takerWallet) {
        require(isAuthorized(_takerWallet, msg.sender),
          "SENDER_UNAUTHORIZED");
      }

      finalTakerWallet = _takerWallet;

    }

    // Validate the maker side of the trade.
    if (_v == 0) {
      /**
        * Signature is not provided. The maker may have authorized the sender
        * to swap on its behalf, which does not require a signature.
        */
      require(isAuthorized(_makerWallet, msg.sender),
        "SIGNER_UNAUTHORIZED");

    } else {

      // Signature is provided. Ensure that it is valid.
      require(_makerWallet == ecrecover(
        keccak256(abi.encodePacked(
          "\x19Ethereum Signed Message:\n32",
          keccak256(abi.encodePacked(
            byte(0),
            address(this),
            _nonce,
            _expiry,
            _makerWallet,
            _makerParam,
            _makerToken,
            _takerWallet,
            _takerParam,
            _takerToken
          ))
        )), _v, _r, _s), "SIGNATURE_INVALID");
    }

    // Mark the order TAKEN (0x01).
    makerOrderStatus[_makerWallet][_nonce] = TAKEN;

    // Transfer token from taker to maker.
    transferToken(
      finalTakerWallet,
      _makerWallet,
      _takerParam,
      _takerToken,
      ERC20_INTERFACE_ID
    );

    // Transfer token from maker to taker.
    transferToken(
      _makerWallet,
      finalTakerWallet,
      _makerParam,
      _makerToken,
      ERC20_INTERFACE_ID
    );

    emit Swap(_nonce, block.timestamp,
      _makerWallet, _makerParam, _makerToken,
      finalTakerWallet, _takerParam, _takerToken,
      address(0), 0, address(0)
    );

  }

  /**
    * @notice Cancel one or more open orders by nonce
    * @dev Canceled orders are marked CANCELED (0x02)
    * @dev Emits a Cancel event
    * @param _nonces uint256[]
    */
  function cancel(
    uint256[] calldata _nonces
  ) external {
    for (uint256 i = 0; i < _nonces.length; i++) {
      if (makerOrderStatus[msg.sender][_nonces[i]] == OPEN) {
        makerOrderStatus[msg.sender][_nonces[i]] = CANCELED;
        emit Cancel(_nonces[i], msg.sender);
      }
    }
  }

  /**
    * @notice Invalidate all orders below a nonce value
    * @dev Emits an Invalidate event
    * @param _minimumNonce uint256
    */
  function invalidate(
    uint256 _minimumNonce
  ) external {
    makerMinimumNonce[msg.sender] = _minimumNonce;
    emit Invalidate(_minimumNonce, msg.sender);
  }

  /**
    * @notice Authorize a delegate
    * @dev Emits an Authorize event
    * @param _delegate address
    * @param _expiry uint256
    */
  function authorize(
    address _delegate,
    uint256 _expiry
  ) external {
    require(msg.sender != _delegate, "INVALID_AUTH_DELEGATE");
    require(_expiry > block.timestamp, "INVALID_AUTH_EXPIRY");
    delegateApprovals[msg.sender][_delegate] = _expiry;
    emit Authorize(msg.sender, _delegate, _expiry);
  }

  /**
    * @notice Revoke an authorization
    * @dev Emits a Revoke event
    * @param _delegate address
    */
  function revoke(
    address _delegate
  ) external {
    delete delegateApprovals[msg.sender][_delegate];
    emit Revoke(msg.sender, _delegate);
  }

  /**
    * @notice Determine whether a delegate is authorized
    * @param _approver address
    * @param _delegate address
    * @return bool returns whether a delegate is authorized
    */
  function isAuthorized(
    address _approver,
    address _delegate
  ) internal view returns (bool) {
    if (_approver == _delegate) return true;
    return (delegateApprovals[_approver][_delegate] > block.timestamp);
  }

  /**
    * @notice Validate signature using an EIP-712 typed data hash
    * @param _order Order
    * @param _signature Signature
    * @return bool returns whether the signature + order is valid
    */
  function isValid(
    Types.Order memory _order,
    Types.Signature memory _signature,
    bytes32 _domainSeparator
  ) internal pure returns (bool) {
    if (_signature.version == byte(0x01)) {
      return _signature.signer == ecrecover(
        Types.hashOrder(
          _order,
          _domainSeparator),
          _signature.v,
          _signature.r,
          _signature.s
      );
    }
    if (_signature.version == byte(0x45)) {
      return _signature.signer == ecrecover(
        keccak256(
          abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            Types.hashOrder(_order, _domainSeparator)
          )
        ),
        _signature.v,
        _signature.r,
        _signature.s
      );
    }
    return false;
  }

  /**
    * @notice Perform an ERC-20 or ERC-721 token transfer
    * @dev Transfer type specified by the bytes4 _kind param
    * @param _from address wallet address to send from
    * @param _to address wallet address to send to
    * @param _param uint256 amount for ERC-20 or token ID for ERC-721
    * @param _token address contract address of token
    * @param _kind bytes4 EIP-165 interface ID of the token
    */
  function transferToken(
      address _from,
      address _to,
      uint256 _param,
      address _token,
      bytes4 _kind
  ) internal {
    if (_kind == ERC721_INTERFACE_ID) {
      // Attempt to transfer an ERC-721 token.
      IERC721(_token).safeTransferFrom(_from, _to, _param);
    } else {
      // Attempt to transfer an ERC-20 token.
      require(IERC20(_token).transferFrom(_from, _to, _param));
    }
  }
}