/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;
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
/**
  * @title Types: Library of Swap Protocol Types and Hashes
  */
library Types {
  bytes constant internal EIP191_HEADER = "\x19\x01";
  struct Order {
    uint256 nonce;                // Unique per order and should be sequential
    uint256 expiry;               // Expiry in seconds since 1 January 1970
    Party signer;                 // Party to the trade that sets terms
    Party sender;                 // Party to the trade that accepts terms
    Party affiliate;              // Party compensated for facilitating (optional)
    Signature signature;          // Signature of the order
  }
  struct Party {
    bytes4 kind;                  // Interface ID of the token
    address wallet;               // Wallet address of the party
    address token;                // Contract address of the token
    uint256 param;                // Value (ERC-20) or ID (ERC-721)
  }
  struct Signature {
    address signatory;            // Address of the wallet used to sign
    address validator;            // Address of the intended swap contract
    bytes1 version;               // EIP-191 signature version
    uint8 v;                      // `v` value of an ECDSA signature
    bytes32 r;                    // `r` value of an ECDSA signature
    bytes32 s;                    // `s` value of an ECDSA signature
  }
  bytes32 constant internal DOMAIN_TYPEHASH = keccak256(abi.encodePacked(
    "EIP712Domain(",
    "string name,",
    "string version,",
    "address verifyingContract",
    ")"
  ));
  bytes32 constant internal ORDER_TYPEHASH = keccak256(abi.encodePacked(
    "Order(",
    "uint256 nonce,",
    "uint256 expiry,",
    "Party signer,",
    "Party sender,",
    "Party affiliate",
    ")",
    "Party(",
    "bytes4 kind,",
    "address wallet,",
    "address token,",
    "uint256 param",
    ")"
  ));
  bytes32 constant internal PARTY_TYPEHASH = keccak256(abi.encodePacked(
    "Party(",
    "bytes4 kind,",
    "address wallet,",
    "address token,",
    "uint256 param",
    ")"
  ));
  /**
    * @notice Hash an order into bytes32
    * @dev EIP-191 header and domain separator included
    * @param order Order The order to be hashed
    * @param domainSeparator bytes32
    * @return bytes32 A keccak256 abi.encodePacked value
    */
  function hashOrder(
    Order calldata order,
    bytes32 domainSeparator
  ) external pure returns (bytes32) {
    return keccak256(abi.encodePacked(
      EIP191_HEADER,
      domainSeparator,
      keccak256(abi.encode(
        ORDER_TYPEHASH,
        order.nonce,
        order.expiry,
        keccak256(abi.encode(
          PARTY_TYPEHASH,
          order.signer.kind,
          order.signer.wallet,
          order.signer.token,
          order.signer.param
        )),
        keccak256(abi.encode(
          PARTY_TYPEHASH,
          order.sender.kind,
          order.sender.wallet,
          order.sender.token,
          order.sender.param
        )),
        keccak256(abi.encode(
          PARTY_TYPEHASH,
          order.affiliate.kind,
          order.affiliate.wallet,
          order.affiliate.token,
          order.affiliate.param
        ))
      ))
    ));
  }
  /**
    * @notice Hash domain parameters into bytes32
    * @dev Used for signature validation (EIP-712)
    * @param name bytes
    * @param version bytes
    * @param verifyingContract address
    * @return bytes32 returns a keccak256 abi.encodePacked value
    */
  function hashDomain(
    bytes calldata name,
    bytes calldata version,
    address verifyingContract
  ) external pure returns (bytes32) {
    return keccak256(abi.encode(
      DOMAIN_TYPEHASH,
      keccak256(name),
      keccak256(version),
      verifyingContract
    ));
  }
}
// File: @airswap/swap/contracts/interfaces/ISwap.sol
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
interface ISwap {
  event Swap(
    uint256 indexed nonce,
    uint256 timestamp,
    address indexed signerWallet,
    uint256 signerParam,
    address signerToken,
    address indexed senderWallet,
    uint256 senderParam,
    address senderToken,
    address affiliateWallet,
    uint256 affiliateParam,
    address affiliateToken
  );
  event Cancel(
    uint256 indexed nonce,
    address indexed signerWallet
  );
  event Invalidate(
    uint256 indexed nonce,
    address indexed signerWallet
  );
  event AuthorizeSender(
    address indexed authorizerAddress,
    address indexed authorizedSender
  );
  event AuthorizeSigner(
    address indexed authorizerAddress,
    address indexed authorizedSigner
  );
  event RevokeSender(
    address indexed authorizerAddress,
    address indexed revokedSender
  );
  event RevokeSigner(
    address indexed authorizerAddress,
    address indexed revokedSigner
  );
  function senderAuthorizations(address, address) external returns (uint256);
  function signerAuthorizations(address, address) external returns (uint256);
  function signerNonceStatus(address, uint256) external returns (byte);
  function signerMinimumNonce(address) external returns (uint256);
  /**
    * @notice Atomic Token Swap
    * @param order Types.Order
    */
  function swap(
    Types.Order calldata order
  ) external;
  /**
    * @notice Cancel one or more open orders by nonce
    * @param nonces uint256[]
    */
  function cancel(
    uint256[] calldata nonces
  ) external;
  /**
    * @notice Invalidate all orders below a nonce value
    * @param minimumNonce uint256
    */
  function invalidate(
    uint256 minimumNonce
  ) external;
  /**
    * @notice Authorize a delegated sender
    * @param authorizedSender address
    */
  function authorizeSender(
    address authorizedSender
  ) external;
  /**
    * @notice Authorize a delegated signer
    * @param authorizedSigner address
    */
  function authorizeSigner(
    address authorizedSigner
  ) external;
  /**
    * @notice Revoke an authorization
    * @param authorizedSender address
    */
  function revokeSender(
    address authorizedSender
  ) external;
  /**
    * @notice Revoke an authorization
    * @param authorizedSigner address
    */
  function revokeSigner(
    address authorizedSigner
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
// File: openzeppelin-solidity/contracts/ownership/Ownable.sol
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: contracts/Wrapper.sol
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
/**
  * @title Wrapper: Send and receive ether for WETH trades
  */
contract Wrapper is Ownable {
  // The Swap contract to settle trades
  ISwap public swapContract;
  // The WETH contract to wrap ether
  IWETH public wethContract;
  // Boolean marking when the contract is paused - users cannot call functions when true
  // defaults to false
  bool public contractPaused;
  /**
    * @notice Contract Constructor
    * @param wrapperSwapContract address
    * @param wrapperWethContract address
    */
  constructor(
    address wrapperSwapContract,
    address wrapperWethContract
  ) public {
    swapContract = ISwap(wrapperSwapContract);
    wethContract = IWETH(wrapperWethContract);
  }
  /**
  * @notice Modifier to prevent function calling unless the contract is not paused
  */
  modifier notPaused() {
    require(!contractPaused, "CONTRACT_IS_PAUSED");
    _;
  }
  /**
    * @notice Modifier to prevent function calling unless the contract is paused
    */
  modifier paused() {
    require(contractPaused, "CONTRACT_NOT_PAUSED");
    _;
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
    * @notice Set whether the contract is paused
    * @dev Only callable by owner
    * @param newStatus bool New status of contractPaused
    */
  function setPausedStatus(bool newStatus) external onlyOwner {
    contractPaused = newStatus;
  }
  /**
    * @notice Destroy the Contract
    * @dev Only callable by owner and when contractPaused
    * @param recipient address Recipient of any ETH in the contract
    */
  function killContract(address payable recipient) external onlyOwner paused {
    selfdestruct(recipient);
  }
  /**
    * @notice Send an Order
    * @dev Sender must authorize this contract on the swapContract
    * @dev Sender must approve this contract on the wethContract
    * @param order Types.Order The Order
    */
  function swap(
    Types.Order calldata order
  ) external payable notPaused {
    // Ensure msg.sender is sender wallet.
    require(order.sender.wallet == msg.sender,
      "MSG_SENDER_MUST_BE_ORDER_SENDER");
    // Ensure that the signature is present.
    // It will be explicitly checked in Swap.
    require(order.signature.v != 0,
      "SIGNATURE_MUST_BE_SENT");
    // The sender is sending ether that must be wrapped.
    if (order.sender.token == address(wethContract)) {
      // Ensure message value is sender param.
      require(order.sender.param == msg.value,
        "VALUE_MUST_BE_SENT");
      // Wrap (deposit) the ether.
      wethContract.deposit.value(msg.value)();
      // Transfer the WETH from the wrapper to sender.
      wethContract.transfer(order.sender.wallet, order.sender.param);
    } else {
      // Ensure no unexpected ether is sent.
      require(msg.value == 0,
        "VALUE_MUST_BE_ZERO");
    }
    // Perform the swap.
    swapContract.swap(order);
    // The sender is receiving ether that must be unwrapped.
    if (order.signer.token == address(wethContract)) {
      // Transfer from the sender to the wrapper.
      wethContract.transferFrom(order.sender.wallet, address(this), order.signer.param);
      // Unwrap (withdraw) the ether.
      wethContract.withdraw(order.signer.param);
      // Transfer ether to the user.
      // solium-disable-next-line security/no-call-value
      msg.sender.call.value(order.signer.param)("");
    }
  }
}