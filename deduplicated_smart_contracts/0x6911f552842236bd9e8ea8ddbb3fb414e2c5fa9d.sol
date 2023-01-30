// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import { EIP712 } from "./external/openzeppelin/draft-EIP712.sol";
import { ECDSA } from "./external/openzeppelin/ECDSA.sol";

import { IERC20 } from "./interfaces/IERC20.sol";
import { Ownable } from "./abstract/Ownable.sol";
import { TransactionThrottler } from "./abstract/TransactionThrottler.sol";
import { Constants } from "./libraries/Constants.sol";

contract SynapseNetwork is IERC20, EIP712, Ownable, TransactionThrottler {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    // keccak256("Transfer(address owner,address to,uint256 value,uint256 nonce,uint256 deadline)");
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public constant TRANSFER_TYPEHASH = 0x42ce63790c28229c123925d83266e77c04d28784552ab68b350a9003226cbd59;
    mapping(address => uint256) public override nonces;

    mapping(address => bool) private _excludedFromFees;
    // Basis points means divide by 10,000 to get decimal
    uint256 private constant MAX_TRANSFER_FEE_BASIS_POINTS = 1000;
    uint256 private constant BASIS_POINTS_MULTIPLIER = 10000;
    uint256 public transferFeeBasisPoints;
    address public feeContract;

    event MarkedExcluded(address indexed account, bool isExcluded);
    event FeeBasisPoints(uint256 feeBasisPoints);
    event FeeContractChanged(address feeContract);

    constructor(address _admin) EIP712(Constants.getName(), "1") {
        transferFeeBasisPoints = 50;
        setExcludedFromFees(_admin, true);

        _setOwner(_admin);

        _balances[_admin] = Constants.getTotalSupply();
        emit Transfer(address(0), _admin, Constants.getTotalSupply());
    }

    function name() external pure returns (string memory) {
        return Constants.getName();
    }

    function symbol() external pure returns (string memory) {
        return Constants.getSymbol();
    }

    function decimals() external pure override returns (uint8) {
        return Constants.getDecimals();
    }

    function totalSupply() external pure override returns (uint256) {
        return Constants.getTotalSupply();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        if (currentAllowance < type(uint256).max) {
            // DEXes can use max allowance
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private transactionThrottler(sender, recipient, amount) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount is 0");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        uint256 fee;
        if (feeContract != address(0) && transferFeeBasisPoints > 0 && !_excludedFromFees[sender] && !_excludedFromFees[recipient]) {
            fee = (amount * transferFeeBasisPoints) / BASIS_POINTS_MULTIPLIER;
            _balances[feeContract] += fee;
            emit Transfer(sender, feeContract, fee);
        }

        uint256 sendAmount = amount - fee;
        _balances[sender] -= amount;
        _balances[recipient] += sendAmount;
        emit Transfer(sender, recipient, sendAmount);
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function permit(
        address _owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        // Revert faster here then later on signature (gas saving for user)
        require(_owner != address(0), "ERC20Permit: Permit from zero address");
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, _owner, spender, value, nonces[_owner]++, deadline));
        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == _owner, "ERC20Permit: invalid signature");

        _approve(_owner, spender, value);
    }

    function transferWithPermit(
        address _owner,
        address to,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override returns (bool) {
        // Revert faster here then later on signature (gas saving for user)
        require(_owner != address(0) && to != address(0), "ERC20Permit: Zero address");
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(TRANSFER_TYPEHASH, _owner, to, value, nonces[_owner]++, deadline));
        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == _owner, "ERC20Permit: invalid signature");

        _transfer(_owner, to, value);
        return true;
    }

    function isExcludedFromFees(address account) external view returns (bool) {
        return _excludedFromFees[account];
    }

    function setExcludedFromFees(address account, bool isExcluded) public onlyOwner {
        require(account != address(0), "Zero address");
        _excludedFromFees[account] = isExcluded;
        emit MarkedExcluded(account, isExcluded);
    }

    function setTransferFeeBasisPoints(uint256 fee) external onlyOwner {
        require(fee <= MAX_TRANSFER_FEE_BASIS_POINTS, "Fee is outside of range 0-1000");
        transferFeeBasisPoints = fee;
        emit FeeBasisPoints(transferFeeBasisPoints);
    }

    function changeFeeContract(address newContract) external onlyOwner {
        feeContract = newContract;
        emit FeeContractChanged(feeContract);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

abstract contract OwnableData {
    address public owner;
    address public pendingOwner;
}

abstract contract Ownable is OwnableData {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev `owner` defaults to msg.sender on construction.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Transfers ownership to `newOwner`. Either directly or claimable by the new pending owner.
     *      Can only be invoked by the current `owner`.
     * @param _newOwner Address of the new owner.
     * @param _direct True if `newOwner` should be set immediately. False if `newOwner` needs to use `claimOwnership`.
     */
    function transferOwnership(address _newOwner, bool _direct) external onlyOwner {
        if (_direct) {
            require(_newOwner != address(0), "zero address");

            emit OwnershipTransferred(owner, _newOwner);
            owner = _newOwner;
            pendingOwner = address(0);
        } else {
            pendingOwner = _newOwner;
        }
    }

    /**
     * @dev Needs to be called by `pendingOwner` to claim ownership.
     */
    function claimOwnership() external {
        address _pendingOwner = pendingOwner;
        require(msg.sender == _pendingOwner, "caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    /**
     * @dev Throws if called by any account other than the Owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import { Ownable } from "./Ownable.sol";

abstract contract TransactionThrottler is Ownable {
    bool private _restrictionActive;
    uint256 private _tradingStart;
    uint256 private _restrictionEndTime;
    uint256 private _maxTransferAmount;
    uint256 private constant _delayBetweenTx = 30;
    mapping(address => bool) private _isWhitelisted;
    mapping(address => uint256) private _previousTx;

    event TradingTimeChanged(uint256 tradingTime);
    event RestrictionEndTimeChanged(uint256 endTime);
    event RestrictionActiveChanged(bool active);
    event MaxTransferAmountChanged(uint256 maxTransferAmount);
    event MarkedWhitelisted(address indexed account, bool isWhitelisted);

    constructor() {
        _tradingStart = block.timestamp + 3 days;
        _restrictionEndTime = _tradingStart + 30 * 60;
        _maxTransferAmount = 60000 * 10**18;
        _restrictionActive = true;
    }

    function setTradingStart(uint256 _time) external onlyOwner() {
        require(_tradingStart > block.timestamp, "Protection: To late");
        _tradingStart = _time;
        _restrictionEndTime = _time + 30 * 60;
        emit TradingTimeChanged(_tradingStart);
        emit RestrictionEndTimeChanged(_restrictionEndTime);
    }

    function setMaxTransferAmount(uint256 _amount) external onlyOwner() {
        require(_restrictionEndTime > block.timestamp, "Protection: To late");
        _maxTransferAmount = _amount;
        emit MaxTransferAmountChanged(_maxTransferAmount);
    }

    function setRestrictionActive(bool _active) external onlyOwner() {
        _restrictionActive = _active;
        emit RestrictionActiveChanged(_active);
    }

    function whitelistAccount(address _account, bool _whitelisted) external onlyOwner() {
        require(_account != address(0), "Zero address");
        _isWhitelisted[_account] = true;
        emit MarkedWhitelisted(_account, _whitelisted);
    }

    modifier transactionThrottler(
        address sender,
        address recipient,
        uint256 amount
    ) {
        if (_tradingStart > block.timestamp) {
            require(sender == owner || recipient == owner, "Protection: Transfers disabled");
        } else if (_restrictionActive) {
            uint256 requiredDelay;

            // During the first restricted period tokens amount are limited
            if (_restrictionEndTime > block.timestamp) {
                require(amount <= _maxTransferAmount, "Protection: Limit exceeded");
                requiredDelay = 60 seconds;
            } else {
                requiredDelay = _delayBetweenTx;
            }

            if (!_isWhitelisted[recipient]) {
                require(_previousTx[recipient] + requiredDelay <= block.timestamp, "Protection: 1 tx/min allowed");
                _previousTx[recipient] = block.timestamp;
            }
            if (!_isWhitelisted[sender]) {
                require(_previousTx[sender] + requiredDelay <= block.timestamp, "Protection: 1 tx/min allowed");
                _previousTx[sender] = block.timestamp;
            }
        }
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;
    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    // EIP 2612
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function transferWithPermit(address target, address to, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

library Constants {
    string private constant _name = "Synapse Network";
    string private constant _symbol = "SNP";
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 500_000_000 * 10**18;

    function getName() internal pure returns (string memory) {
        return _name;
    }

    function getSymbol() internal pure returns (string memory) {
        return _symbol;
    }

    function getDecimals() internal pure returns (uint8) {
        return _decimals;
    }

    function getTotalSupply() internal pure returns (uint256) {
        return _totalSupply;
    }
}

{
  "evmVersion": "berlin",
  "libraries": {},
  "metadata": {
    "bytecodeHash": "ipfs",
    "useLiteralContent": true
  },
  "optimizer": {
    "enabled": true,
    "runs": 999999
  },
  "remappings": [],
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  }
}