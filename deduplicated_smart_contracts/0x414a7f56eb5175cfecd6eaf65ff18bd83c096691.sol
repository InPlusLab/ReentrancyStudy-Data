/**
 *Submitted for verification at Etherscan.io on 2020-01-14
*/

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

// File: contracts/interfaces/ILinkdropERC20.sol

pragma solidity ^0.5.6;

interface ILinkdropERC20 {

    function verifyLinkdropSignerSignature
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _signature
    )
    external view returns (bool);

    function verifyReceiverSignature
    (
        address _linkId,
	    address _receiver,
		bytes calldata _signature
    )
    external view returns (bool);

    function checkClaimParams
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address _receiver,
        bytes calldata _receiverSignature,
        uint _fee
    )
    external view returns (bool);

    function claim
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature,
        address payable _feeReceiver,
        uint _fee
    )
    external returns (bool);

    function claimUnlock
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature,
        address payable _lock
    )
    external returns (bool);

}

// File: contracts/interfaces/ILinkdropCommon.sol

pragma solidity ^0.5.6;

interface ILinkdropCommon {

    function initialize
    (
        address _owner,
        address payable _linkdropMaster,
        uint _version,
        uint _chainId
    )
    external returns (bool);

    function isClaimedLink(address _linkId) external view returns (bool);
    function isCanceledLink(address _linkId) external view returns (bool);
    function paused() external view returns (bool);
    function cancel(address _linkId) external  returns (bool);
    function withdraw() external returns (bool);
    function pause() external returns (bool);
    function unpause() external returns (bool);
    function addSigner(address _linkdropSigner) external payable returns (bool);
    function removeSigner(address _linkdropSigner) external returns (bool);
    function destroy() external;
    function getMasterCopyVersion() external view returns (uint);
    function () external payable;

}

// File: contracts/storage/LinkdropStorage.sol

pragma solidity ^0.5.6;

contract LinkdropStorage {

    // Address of owner deploying this contract (usually factory)
    address public owner;

    // Address corresponding to linkdrop master key
    address payable public linkdropMaster;

    // Version of mastercopy contract
    uint public version;

    // Network id
    uint public chainId;

    // Indicates whether an address corresponds to linkdrop signing key
    mapping (address => bool) public isLinkdropSigner;

    // Indicates who the link is claimed to
    mapping (address => address) public claimedTo;

    // Indicates whether the link is canceled or not
    mapping (address => bool) internal _canceled;

    // Indicates whether the initializer function has been called or not
    bool public initialized;

    // Indicates whether the contract is paused or not
    bool internal _paused;

    // Events
    event Canceled(address linkId);
    event Claimed(address indexed linkId, uint ethAmount, address indexed token, uint tokenAmount, address receiver);
    event ClaimedUnlock(address indexed linkId, uint ethAmount, address indexed token, uint tokenAmount, address receiver, address indexed lock);
    event ClaimedERC721(address indexed linkId, uint ethAmount, address indexed nft, uint tokenId, address receiver);
    event Paused();
    event Unpaused();
    event AddedSigningKey(address linkdropSigner);
    event RemovedSigningKey(address linkdropSigner);

}

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

pragma solidity ^0.5.0;

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
     * (.note) This call _does not revert_ if the signature is invalid, or
     * if the signer is otherwise unable to be retrieved. In those scenarios,
     * the zero address is returned.
     *
     * (.warning) `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise)
     * be too long), and then calling `toEthSignedMessageHash` on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n �� 2 + 1, and for v in (282): v �� {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * [`eth_sign`](https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign)
     * JSON-RPC method.
     *
     * See `recover`.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: contracts/linkdrop/LinkdropCommon.sol

pragma solidity ^0.5.6;





contract LinkdropCommon is ILinkdropCommon, LinkdropStorage {

    /**
    * @dev Function called only once to set owner, linkdrop master, contract version and chain id
    * @param _owner Owner address
    * @param _linkdropMaster Address corresponding to master key
    * @param _version Contract version
    * @param _chainId Network id
    */
    function initialize
    (
        address _owner,
        address payable _linkdropMaster,
        uint _version,
        uint _chainId
    )
    public
    returns (bool)
    {
        require(!initialized, "LINKDROP_PROXY_CONTRACT_ALREADY_INITIALIZED");
        owner = _owner;
        linkdropMaster = _linkdropMaster;
        isLinkdropSigner[linkdropMaster] = true;
        version = _version;
        chainId = _chainId;
        initialized = true;
        return true;
    }

    modifier onlyLinkdropMaster() {
        require(msg.sender == linkdropMaster, "ONLY_LINKDROP_MASTER");
        _;
    }

    modifier onlyLinkdropMasterOrFactory() {
        require (msg.sender == linkdropMaster || msg.sender == owner, "ONLY_LINKDROP_MASTER_OR_FACTORY");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == owner, "ONLY_FACTORY");
        _;
    }

    modifier whenNotPaused() {
        require(!paused(), "LINKDROP_PROXY_CONTRACT_PAUSED");
        _;
    }

    /**
    * @dev Indicates whether a link is claimed or not
    * @param _linkId Address corresponding to link key
    * @return True if claimed
    */
    function isClaimedLink(address _linkId) public view returns (bool) {
        return claimedTo[_linkId] != address(0);
    }

    /**
    * @dev Indicates whether a link is canceled or not
    * @param _linkId Address corresponding to link key
    * @return True if canceled
    */
    function isCanceledLink(address _linkId) public view returns (bool) {
        return _canceled[_linkId];
    }

    /**
    * @dev Indicates whether a contract is paused or not
    * @return True if paused
    */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
    * @dev Function to cancel a link, can only be called by linkdrop master
    * @param _linkId Address corresponding to link key
    * @return True if success
    */
    function cancel(address _linkId) external onlyLinkdropMaster returns (bool) {
        require(!isClaimedLink(_linkId), "LINK_CLAIMED");
        _canceled[_linkId] = true;
        emit Canceled(_linkId);
        return true;
    }

    /**
    * @dev Function to withdraw eth to linkdrop master, can only be called by linkdrop master
    * @return True if success
    */
    function withdraw() external onlyLinkdropMaster returns (bool) {
        linkdropMaster.transfer(address(this).balance);
        return true;
    }

    /**
    * @dev Function to pause contract, can only be called by linkdrop master
    * @return True if success
    */
    function pause() external onlyLinkdropMaster whenNotPaused returns (bool) {
        _paused = true;
        emit Paused();
        return true;
    }

    /**
    * @dev Function to unpause contract, can only be called by linkdrop master
    * @return True if success
    */
    function unpause() external onlyLinkdropMaster returns (bool) {
        require(paused(), "LINKDROP_CONTRACT_ALREADY_UNPAUSED");
        _paused = false;
        emit Unpaused();
        return true;
    }

    /**
    * @dev Function to add new signing key, can only be called by linkdrop master or owner (factory contract)
    * @param _linkdropSigner Address corresponding to signing key
    * @return True if success
    */
    function addSigner(address _linkdropSigner) external payable onlyLinkdropMasterOrFactory returns (bool) {
        require(_linkdropSigner != address(0), "INVALID_LINKDROP_SIGNER_ADDRESS");
        isLinkdropSigner[_linkdropSigner] = true;
        return true;
    }

    /**
    * @dev Function to remove signing key, can only be called by linkdrop master
    * @param _linkdropSigner Address corresponding to signing key
    * @return True if success
    */
    function removeSigner(address _linkdropSigner) external onlyLinkdropMaster returns (bool) {
        require(_linkdropSigner != address(0), "INVALID_LINKDROP_SIGNER_ADDRESS");
        isLinkdropSigner[_linkdropSigner] = false;
        return true;
    }

    /**
    * @dev Function to destroy this contract, can only be called by owner (factory) or linkdrop master
    * Withdraws all the remaining ETH to linkdrop master
    */
    function destroy() external onlyLinkdropMasterOrFactory {
        selfdestruct(linkdropMaster);
    }

    /**
    * @dev Function for other contracts to be able to fetch the mastercopy version
    * @return Master copy version
    */
    function getMasterCopyVersion() external view returns (uint) {
        return version;
    }

    /**
    * @dev Fallback function to accept ETH
    */
    function () external payable {}

}

// File: contracts/interfaces/IPublicLock.sol

pragma solidity ^0.5.6;

interface IPublicLock {
    function purchaseFor(address _recipient)  external payable;
}

// File: contracts/interfaces/ILinkdropFactory.sol

pragma solidity ^0.5.6;

interface ILinkdropFactory {
    function getFee(address _proxy) external view returns (uint);
}

// File: contracts/linkdrop/LinkdropERC20.sol

pragma solidity ^0.5.6;






contract LinkdropERC20 is ILinkdropERC20, LinkdropCommon {
    using SafeMath for uint;

    /**
    * @dev Function to verify linkdrop signer's signature
    * @param _weiAmount Amount of wei to be claimed
    * @param _tokenAddress Token address
    * @param _tokenAmount Amount of tokens to be claimed (in atomic value)
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _signature ECDSA signature of linkdrop signer
    * @return True if signed with linkdrop signer's private key
    */
    function verifyLinkdropSignerSignature
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes memory _signature
    )
    public view
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash
        (
            keccak256
            (
                abi.encodePacked
                (
                    _weiAmount,
                    _tokenAddress,
                    _tokenAmount,
                    _expiration,
                    version,
                    chainId,
                    _linkId,
                    address(this)
                )
            )
        );
        address signer = ECDSA.recover(prefixedHash, _signature);
        return isLinkdropSigner[signer];
    }

    /**
    * @dev Function to verify linkdrop receiver's signature
    * @param _linkId Address corresponding to link key
    * @param _receiver Address of linkdrop receiver
    * @param _signature ECDSA signature of linkdrop receiver
    * @return True if signed with link key
    */
    function verifyReceiverSignature
    (
        address _linkId,
        address _receiver,
        bytes memory _signature
    )
    public view
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_receiver)));
        address signer = ECDSA.recover(prefixedHash, _signature);
        return signer == _linkId;
    }

    /**
    * @dev Function to verify claim params and make sure the link is not claimed or canceled
    * @param _weiAmount Amount of wei to be claimed
    * @param _tokenAddress Token address
    * @param _tokenAmount Amount of tokens to be claimed (in atomic value)
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver,
    * @param _fee Amount of fee to send to fee receiver
    * @return True if success
    */
    function checkClaimParams
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes memory _linkdropSignerSignature,
        address _receiver,
        bytes memory _receiverSignature,
        uint _fee
    )
    public view
    whenNotPaused
    returns (bool)
    {
        // If tokens are being claimed
        if (_tokenAmount > 0) {
            require(_tokenAddress != address(0), "INVALID_TOKEN_ADDRESS");
        }

        // Make sure link is not claimed
        require(isClaimedLink(_linkId) == false, "LINK_CLAIMED");

        // Make sure link is not canceled
        require(isCanceledLink(_linkId) == false, "LINK_CANCELED");

        // Make sure link is not expired
        require(_expiration >= now, "LINK_EXPIRED");

        // Make sure eth amount is available for this contract
        require(address(this).balance >= _weiAmount.add(_fee), "INSUFFICIENT_ETHERS");

        // Make sure tokens are available for this contract
        if (_tokenAddress != address(0)) {
            require
            (
                IERC20(_tokenAddress).balanceOf(linkdropMaster) >= _tokenAmount,
                "INSUFFICIENT_TOKENS"
            );

            require
            (
                IERC20(_tokenAddress).allowance(linkdropMaster, address(this)) >= _tokenAmount, "INSUFFICIENT_ALLOWANCE"
            );
        }

        // Verify that link key is legit and signed by linkdrop signer
        require
        (
            verifyLinkdropSignerSignature
            (
                _weiAmount,
                _tokenAddress,
                _tokenAmount,
                _expiration,
                _linkId,
                _linkdropSignerSignature
            ),
            "INVALID_LINKDROP_SIGNER_SIGNATURE"
        );

        // Verify that receiver address is signed by ephemeral key assigned to claim link (link key)
        require
        (
            verifyReceiverSignature(_linkId, _receiver, _receiverSignature),
            "INVALID_RECEIVER_SIGNATURE"
        );

        return true;
    }

    /**
    * @dev Function to claim ETH and/or ERC20 tokens. Can only be called when contract is not paused
    * @param _weiAmount Amount of wei to be claimed
    * @param _tokenAddress Token address
    * @param _tokenAmount Amount of tokens to be claimed (in atomic value)
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver
    * @param _feeReceiver Address to transfer fees to
    * @param _fee Amount of fee to send to fee receiver
    * @return True if success
    */
    function claim
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature,
        address payable _feeReceiver,
        uint _fee
    )
    external
    onlyFactory
    whenNotPaused
    returns (bool)
    {

        // Make sure params are valid
        require
        (
            checkClaimParams
            (
                _weiAmount,
                _tokenAddress,
                _tokenAmount,
                _expiration,
                _linkId,
                _linkdropSignerSignature,
                _receiver,
                _receiverSignature,
                _fee
            ),
            "INVALID_CLAIM_PARAMS"
        );

        // Mark link as claimed
        claimedTo[_linkId] = _receiver;

        // Make sure transfer succeeds
        require(_transferFunds(_weiAmount, _tokenAddress, _tokenAmount, _receiver, _feeReceiver, _fee), "TRANSFER_FAILED");

        // Emit claim event
        emit Claimed(_linkId, _weiAmount, _tokenAddress, _tokenAmount, _receiver);

        return true;
    }

    /**
    * @dev Internal function to transfer ethers and/or ERC20 tokens
    * @param _weiAmount Amount of wei to be claimed
    * @param _tokenAddress Token address
    * @param _tokenAmount Amount of tokens to be claimed (in atomic value)
    * @param _receiver Address to transfer funds to
    * @param _feeReceiver Address to transfer fees to
    * @param _fee Amount of fee to send to fee receiver
    * @return True if success
    */
    function _transferFunds
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        address payable _receiver,
        address payable _feeReceiver,
        uint _fee
    )
    internal returns (bool)
    {
        // Transfer fees
        if (_fee > 0) {
            _feeReceiver.transfer(_fee);
        }

        // Transfer ethers
        if (_weiAmount > 0) {
            _receiver.transfer(_weiAmount);
        }

        // Transfer tokens
        if (_tokenAmount > 0) {
            IERC20(_tokenAddress).transferFrom(linkdropMaster, _receiver, _tokenAmount);
        }

        return true;
    }


// ======================================================================================================
//                                          UNLOCK
// ======================================================================================================

    function claimUnlock
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature,
        address payable _lock
    )
    external
    onlyFactory
    whenNotPaused
    returns (bool)
    {

        // Make sure params are valid
        require
        (
            checkClaimParams
            (
                _weiAmount,
                _tokenAddress,
                _tokenAmount,
                _expiration,
                _linkId,
                _linkdropSignerSignature,
                _receiver,
                _receiverSignature,
                ILinkdropFactory(owner).getFee(address(this)) // fee
            ),
            "INVALID_CLAIM_PARAMS"
        );

        // Mark link as claimed
        claimedTo[_linkId] = _receiver;

        // Make sure transfer succeeds
        require
        (
            _transferFundsUnlock(_weiAmount, _tokenAddress, _tokenAmount, _receiver, _lock),
            "TRANSFER_FAILED"
        );

        // Emit claim event
        emit ClaimedUnlock(_linkId, _weiAmount, _tokenAddress, _tokenAmount, _receiver, _lock);

        return true;
    }

    function _transferFundsUnlock
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        address payable _receiver,
        address payable _lock
    )
    internal returns (bool)
    {
        // Transfers fee to relayer who called this contract through factory
        tx.origin.transfer(ILinkdropFactory(owner).getFee(address(this)));

        // Transfer ethers
        if (_weiAmount > 0) {
            IPublicLock(_lock).purchaseFor.value(_weiAmount)(_receiver);
        }

        // Transfer tokens
        if (_tokenAmount > 0) {
            IERC20(_tokenAddress).transferFrom(linkdropMaster, _receiver, _tokenAmount);
        }

        return true;
    }

}

// File: contracts/interfaces/ILinkdropERC721.sol

pragma solidity ^0.5.6;

interface ILinkdropERC721 {

    function verifyLinkdropSignerSignatureERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _signature
    )
    external view returns (bool);

    function verifyReceiverSignatureERC721
    (
        address _linkId,
	    address _receiver,
		bytes calldata _signature
    )
    external view returns (bool);

    function checkClaimParamsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address _receiver,
        bytes calldata _receiverSignature,
        uint _fee
    )
    external view returns (bool);

    function claimERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature,
        address payable _feeReceiver,
        uint _fee
    )
    external returns (bool);

}

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

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

pragma solidity ^0.5.0;


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

// File: contracts/linkdrop/LinkdropERC721.sol

pragma solidity ^0.5.6;




contract LinkdropERC721 is ILinkdropERC721, LinkdropCommon {
    using SafeMath for uint;
    /**
    * @dev Function to verify linkdrop signer's signature
    * @param _weiAmount Amount of wei to be claimed
    * @param _nftAddress NFT address
    * @param _tokenId Token id to be claimed
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _signature ECDSA signature of linkdrop signer
    * @return True if signed with linkdrop signer's private key
    */
    function verifyLinkdropSignerSignatureERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes memory _signature
    )
    public view
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash
        (
            keccak256
            (
                abi.encodePacked
                (
                    _weiAmount,
                    _nftAddress,
                    _tokenId,
                    _expiration,
                    version,
                    chainId,
                    _linkId,
                    address(this)
                )
            )
        );
        address signer = ECDSA.recover(prefixedHash, _signature);
        return isLinkdropSigner[signer];
    }

    /**
    * @dev Function to verify linkdrop receiver's signature
    * @param _linkId Address corresponding to link key
    * @param _receiver Address of linkdrop receiver
    * @param _signature ECDSA signature of linkdrop receiver
    * @return True if signed with link key
    */
    function verifyReceiverSignatureERC721
    (
        address _linkId,
        address _receiver,
        bytes memory _signature
    )
    public view
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_receiver)));
        address signer = ECDSA.recover(prefixedHash, _signature);
        return signer == _linkId;
    }

    /**
    * @dev Function to verify claim params and make sure the link is not claimed or canceled
    * @param _weiAmount Amount of wei to be claimed
    * @param _nftAddress NFT address
    * @param _tokenId Token id to be claimed
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver
    * @param _fee Amount of fee to send to fee receiver
    * @return True if success
    */
    function checkClaimParamsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes memory _linkdropSignerSignature,
        address _receiver,
        bytes memory _receiverSignature,
        uint _fee
    )
    public view
    whenNotPaused
    returns (bool)
    {
        // Make sure nft address is not equal to address(0)
        require(_nftAddress != address(0), "INVALID_NFT_ADDRESS");

        // Make sure link is not claimed
        require(isClaimedLink(_linkId) == false, "LINK_CLAIMED");

        // Make sure link is not canceled
        require(isCanceledLink(_linkId) == false, "LINK_CANCELED");

        // Make sure link is not expired
        require(_expiration >= now, "LINK_EXPIRED");

        // Make sure eth amount is available for this contract
        require(address(this).balance >= _weiAmount.add(_fee), "INSUFFICIENT_ETHERS");

        // Make sure linkdrop master is owner of token
        require(IERC721(_nftAddress).ownerOf(_tokenId) == linkdropMaster, "LINKDROP_MASTER_DOES_NOT_OWN_TOKEN_ID");

        // Make sure nft is available for this contract
        require(IERC721(_nftAddress).isApprovedForAll(linkdropMaster, address(this)), "INSUFFICIENT_ALLOWANCE");

        // Verify that link key is legit and signed by linkdrop signer's private key
        require
        (
            verifyLinkdropSignerSignatureERC721
            (
                _weiAmount,
                _nftAddress,
                _tokenId,
                _expiration,
                _linkId,
                _linkdropSignerSignature
            ),
            "INVALID_LINKDROP_SIGNER_SIGNATURE"
        );

        // Verify that receiver address is signed by ephemeral key assigned to claim link (link key)
        require
        (
            verifyReceiverSignatureERC721(_linkId, _receiver, _receiverSignature),
            "INVALID_RECEIVER_SIGNATURE"
        );

        return true;
    }

    /**
    * @dev Function to claim ETH and/or ERC721 token. Can only be called when contract is not paused
    * @param _weiAmount Amount of wei to be claimed
    * @param _nftAddress NFT address
    * @param _tokenId Token id to be claimed
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver
    * @param _feeReceiver Address to transfer fees to
    * @param _fee Amount of fee to send to _feeReceiver
    * @return True if success
    */
    function claimERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature,
        address payable _feeReceiver,
        uint _fee
    )
    external
    onlyFactory
    whenNotPaused
    returns (bool)
    {

        // Make sure params are valid
        require
        (
            checkClaimParamsERC721
            (
                _weiAmount,
                _nftAddress,
                _tokenId,
                _expiration,
                _linkId,
                _linkdropSignerSignature,
                _receiver,
                _receiverSignature,
                _fee
            ),
            "INVALID_CLAIM_PARAMS"
        );

        // Mark link as claimed
        claimedTo[_linkId] = _receiver;

        // Make sure transfer succeeds
        require(_transferFundsERC721(_weiAmount, _nftAddress, _tokenId, _receiver, _feeReceiver, _fee), "TRANSFER_FAILED");

        // Log claim
        emit ClaimedERC721(_linkId, _weiAmount, _nftAddress, _tokenId, _receiver);

        return true;
    }

    /**
    * @dev Internal function to transfer ethers and/or ERC721 tokens
    * @param _weiAmount Amount of wei to be claimed
    * @param _nftAddress NFT address
    * @param _tokenId Amount of tokens to be claimed (in atomic value)
    * @param _receiver Address to transfer funds to
    * @param _feeReceiver Address to transfer fees to
    * @param _fee Amount of fee to send to _feeReceiver
    * @return True if success
    */
    function _transferFundsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        address payable _receiver,
        address payable _feeReceiver,
        uint _fee
    )
    internal returns (bool)
    {
        // Transfer fees
        _feeReceiver.transfer(_fee);

        // Transfer ethers
        if (_weiAmount > 0) {
            _receiver.transfer(_weiAmount);
        }

        // Transfer NFT
        IERC721(_nftAddress).safeTransferFrom(linkdropMaster, _receiver, _tokenId);

        return true;
    }

}

// File: contracts/linkdrop/LinkdropMastercopy.sol

pragma solidity ^0.5.6;




contract LinkdropMastercopy is LinkdropERC20, LinkdropERC721 {

}