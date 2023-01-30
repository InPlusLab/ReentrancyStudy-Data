/**
 *Submitted for verification at Etherscan.io on 2019-09-16
*/

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

}

interface ILinkdropFactoryERC20 {

    function checkClaimParams
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes calldata _linkdropSignerSignature,
        address _receiver,
        bytes calldata _receiverSignature
    )
    external view
    returns (bool);

    function claim
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external
    returns (bool);

}

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


interface ILinkdropFactoryERC721 {

    function checkClaimParamsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes calldata _linkdropSignerSignature,
        address _receiver,
        bytes calldata _receiverSignature
    )
    external view
    returns (bool);

    function claimERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external
    returns (bool);

}

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
        // the valid range for s in (281): 0 < s < secp256k1n ¡Â 2 + 1, and for v in (282): v ¡Ê {27, 28}. Most
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


contract LinkdropFactoryStorage is Ownable {

    // Current version of mastercopy contract
    uint public masterCopyVersion;

    // Contract bytecode to be installed when deploying proxy
    bytes internal _bytecode;

    // Bootstrap initcode to fetch the actual contract bytecode. Used to generate repeatable contract addresses
    bytes internal _initcode;

    // Network id
    uint public chainId;

    // Maps hash(sender address, campaign id) to its corresponding proxy address
    mapping (bytes32 => address) public deployed;

    // Events
    event Deployed(address payable indexed owner, uint campaignId, address payable proxy, bytes32 salt);
    event Destroyed(address payable owner, address payable proxy);
    event SetMasterCopy(address masterCopy, uint version);

}

contract FeeManager is Ownable {

    event FeeChanged(address proxy, uint fee);

    mapping (address => uint) fees;

    uint public standardFee = 0.002 ether;

    function setFee(address _proxy, uint _fee) external onlyOwner returns (bool) {
        _setFee(_proxy, _fee);
        return true;
    }

    function _setFee(address _proxy, uint _fee) internal {
        if (fees[_proxy] != 0) {
            require(_fee < fees[_proxy], "CANNOT_INCREASE_FEE");
        }
        fees[_proxy] = _fee;
        emit FeeChanged(_proxy, _fee);
    }

    function setStandardFee(uint _fee) external onlyOwner {
        standardFee = _fee;
    }

}

contract RelayerManager is Ownable {

    mapping (address => bool) public isRelayer;

    event RelayerAdded(address indexed relayer);

    event RelayerRemoved(address indexed relayer);

    function addRelayer(address _relayer) external onlyOwner returns (bool) {
        require(_relayer != address(0) && !isRelayer[_relayer], "INVALID_RELAYER_ADDRESS");
        isRelayer[_relayer] = true;
        emit RelayerAdded(_relayer);
        return true;
    }

    function removeRelayer(address _relayer) external onlyOwner returns (bool) {
        require(isRelayer[_relayer], "INVALID_RELAYER_ADDRESS");
        isRelayer[_relayer] = false;
        emit RelayerRemoved(_relayer);
        return true;
    }

}






contract LinkdropFactoryCommon is LinkdropFactoryStorage, FeeManager, RelayerManager {
    using SafeMath for uint;

    /**
    * @dev Indicates whether a proxy contract for linkdrop master is deployed or not
    * @param _linkdropMaster Address of linkdrop master
    * @param _campaignId Campaign id
    * @return True if deployed
    */
    function isDeployed(address _linkdropMaster, uint _campaignId) public view returns (bool) {
        return (deployed[salt(_linkdropMaster, _campaignId)] != address(0));
    }

    /**
    * @dev Indicates whether a link is claimed or not
    * @param _linkdropMaster Address of lindkrop master
    * @param _campaignId Campaign id
    * @param _linkId Address corresponding to link key
    * @return True if claimed
    */
    function isClaimedLink(address payable _linkdropMaster, uint _campaignId, address _linkId) public view returns (bool) {

        if (!isDeployed(_linkdropMaster, _campaignId)) {
            return false;
        }
        else {
            address payable proxy = address(uint160(deployed[salt(_linkdropMaster, _campaignId)]));
            return ILinkdropCommon(proxy).isClaimedLink(_linkId);
        }

    }

    /**
    * @dev Function to deploy a proxy contract for msg.sender
    * @param _campaignId Campaign id
    * @return Proxy contract address
    */
    function deployProxy(uint _campaignId)
    public
    payable
    returns (address payable proxy)
    {
        proxy = _deployProxy(msg.sender, _campaignId);
    }

    /**
    * @dev Function to deploy a proxy contract for msg.sender and add a new signing key
    * @param _campaignId Campaign id
    * @param _signer Address corresponding to signing key
    * @return Proxy contract address
    */
    function deployProxyWithSigner(uint _campaignId, address _signer)
    public
    payable
    returns (address payable proxy)
    {
        proxy = deployProxy(_campaignId);
        ILinkdropCommon(proxy).addSigner(_signer);
    }

    /**
    * @dev Internal function to deploy a proxy contract for linkdrop master
    * @param _linkdropMaster Address of linkdrop master
    * @param _campaignId Campaign id
    * @return Proxy contract address
    */
    function _deployProxy(address payable _linkdropMaster, uint _campaignId)
    internal
    returns (address payable proxy)
    {

        require(!isDeployed(_linkdropMaster, _campaignId), "LINKDROP_PROXY_CONTRACT_ALREADY_DEPLOYED");
        require(_linkdropMaster != address(0), "INVALID_LINKDROP_MASTER_ADDRESS");

        bytes32 salt = salt(_linkdropMaster, _campaignId);
        bytes memory initcode = getInitcode();

        assembly {
            proxy := create2(0, add(initcode, 0x20), mload(initcode), salt)
            if iszero(extcodesize(proxy)) { revert(0, 0) }
        }

        deployed[salt] = proxy;

        // Initialize owner address, linkdrop master address master copy version in proxy contract
        require
        (
            ILinkdropCommon(proxy).initialize
            (
                address(this), // Owner address
                _linkdropMaster, // Linkdrop master address
                masterCopyVersion,
                chainId
            ),
            "INITIALIZATION_FAILED"
        );

        // Send funds attached to proxy contract
        proxy.transfer(msg.value);

        // Set standard fee for the proxy
        _setFee(proxy, standardFee);

        emit Deployed(_linkdropMaster, _campaignId, proxy, salt);
        return proxy;
    }

    /**
    * @dev Function to destroy proxy contract, called by proxy owner
    * @param _campaignId Campaign id
    * @return True if destroyed successfully
    */
    function destroyProxy(uint _campaignId)
    public
    returns (bool)
    {
        require(isDeployed(msg.sender, _campaignId), "LINKDROP_PROXY_CONTRACT_NOT_DEPLOYED");
        address payable proxy = address(uint160(deployed[salt(msg.sender, _campaignId)]));
        ILinkdropCommon(proxy).destroy();
        delete deployed[salt(msg.sender, _campaignId)];
        delete fees[proxy];
        emit Destroyed(msg.sender, proxy);
        return true;
    }

    /**
    * @dev Function to get bootstrap initcode for generating repeatable contract addresses
    * @return Static bootstrap initcode
    */
    function getInitcode()
    public view
    returns (bytes memory)
    {
        return _initcode;
    }

    /**
    * @dev Function to fetch the actual contract bytecode to install. Called by proxy when executing initcode
    * @return Contract bytecode to install
    */
    function getBytecode()
    public view
    returns (bytes memory)
    {
        return _bytecode;
    }

    /**
    * @dev Function to set new master copy and update contract bytecode to install. Can only be called by factory owner
    * @param _masterCopy Address of linkdrop mastercopy contract to calculate bytecode from
    * @return True if updated successfully
    */
    function setMasterCopy(address payable _masterCopy)
    public onlyOwner
    returns (bool)
    {
        require(_masterCopy != address(0), "INVALID_MASTER_COPY_ADDRESS");
        masterCopyVersion = masterCopyVersion.add(1);

        require
        (
            ILinkdropCommon(_masterCopy).initialize
            (
                address(0), // Owner address
                address(0), // Linkdrop master address
                masterCopyVersion,
                chainId
            ),
            "INITIALIZATION_FAILED"
        );

        bytes memory bytecode = abi.encodePacked
        (
            hex"363d3d373d3d3d363d73",
            _masterCopy,
            hex"5af43d82803e903d91602b57fd5bf3"
        );

        _bytecode = bytecode;

        emit SetMasterCopy(_masterCopy, masterCopyVersion);
        return true;
    }

    /**
    * @dev Function to fetch the master copy version installed (or to be installed) to proxy
    * @param _linkdropMaster Address of linkdrop master
    * @param _campaignId Campaign id
    * @return Master copy version
    */
    function getProxyMasterCopyVersion(address _linkdropMaster, uint _campaignId) external view returns (uint) {

        if (!isDeployed(_linkdropMaster, _campaignId)) {
            return masterCopyVersion;
        }
        else {
            address payable proxy = address(uint160(deployed[salt(_linkdropMaster, _campaignId)]));
            return ILinkdropCommon(proxy).getMasterCopyVersion();
        }
    }

    /**
     * @dev Function to hash `_linkdropMaster` and `_campaignId` params. Used as salt when deploying with create2
     * @param _linkdropMaster Address of linkdrop master
     * @param _campaignId Campaign id
     * @return Hash of passed arguments
     */
    function salt(address _linkdropMaster, uint _campaignId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_linkdropMaster, _campaignId));
    }

}




contract LinkdropFactoryERC20 is ILinkdropFactoryERC20, LinkdropFactoryCommon {

    /**
    * @dev Function to verify claim params, make sure the link is not claimed or canceled and proxy has sufficient balance
    * @param _weiAmount Amount of wei to be claimed
    * @param _tokenAddress Token address
    * @param _tokenAmount Amount of tokens to be claimed (in atomic value)
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropMaster Address corresponding to linkdrop master key
    * @param _campaignId Campaign id
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver
    * @return True if success
    */
    function checkClaimParams
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes memory _linkdropSignerSignature,
        address _receiver,
        bytes memory _receiverSignature
    )
    public view
    returns (bool)
    {
        // Make sure proxy contract is deployed
        require(isDeployed(_linkdropMaster, _campaignId), "LINKDROP_PROXY_CONTRACT_NOT_DEPLOYED");

        uint fee = fees[deployed[salt(_linkdropMaster, _campaignId)]];

        return ILinkdropERC20(deployed[salt(_linkdropMaster, _campaignId)]).checkClaimParams
        (
            _weiAmount,
            _tokenAddress,
            _tokenAmount,
            _expiration,
            _linkId,
            _linkdropSignerSignature,
            _receiver,
            _receiverSignature,
            fee
        );
    }

    /**
    * @dev Function to claim ETH and/or ERC20 tokens
    * @param _weiAmount Amount of wei to be claimed
    * @param _tokenAddress Token address
    * @param _tokenAmount Amount of tokens to be claimed (in atomic value)
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropMaster Address corresponding to linkdrop master key
    * @param _campaignId Campaign id
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver
    * @return True if success
    */
    function claim
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external
    returns (bool)
    {
        // Make sure proxy contract is deployed
        require(isDeployed(_linkdropMaster, _campaignId), "LINKDROP_PROXY_CONTRACT_NOT_DEPLOYED");

        // Make sure only whitelisted relayer calls this function
        require(isRelayer[msg.sender], "ONLY_RELAYER");

        uint fee = fees[deployed[salt(_linkdropMaster, _campaignId)]];

        // Call claim function in the context of proxy contract
        ILinkdropERC20(deployed[salt(_linkdropMaster, _campaignId)]).claim
        (
            _weiAmount,
            _tokenAddress,
            _tokenAmount,
            _expiration,
            _linkId,
            _linkdropSignerSignature,
            _receiver,
            _receiverSignature,
            msg.sender, // Fee receiver
            fee
        );

        return true;
    }

}




contract LinkdropFactoryERC721 is ILinkdropFactoryERC721, LinkdropFactoryCommon {

    /**
    * @dev Function to verify claim params, make sure the link is not claimed or canceled and proxy is allowed to spend token
    * @param _weiAmount Amount of wei to be claimed
    * @param _nftAddress NFT address
    * @param _tokenId Token id to be claimed
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropMaster Address corresponding to linkdrop master key
    * @param _campaignId Campaign id
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver
    * @return True if success
    */
    function checkClaimParamsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes memory _linkdropSignerSignature,
        address _receiver,
        bytes memory _receiverSignature
    )
    public view
    returns (bool)
    {
        // Make sure proxy contract is deployed
        require(isDeployed(_linkdropMaster, _campaignId), "LINKDROP_PROXY_CONTRACT_NOT_DEPLOYED");

        uint fee = fees[deployed[salt(_linkdropMaster, _campaignId)]];

        return ILinkdropERC721(deployed[salt(_linkdropMaster, _campaignId)]).checkClaimParamsERC721
        (
            _weiAmount,
            _nftAddress,
            _tokenId,
            _expiration,
            _linkId,
            _linkdropSignerSignature,
            _receiver,
            _receiverSignature,
            fee
        );
    }

    /**
    * @dev Function to claim ETH and/or ERC721 token
    * @param _weiAmount Amount of wei to be claimed
    * @param _nftAddress NFT address
    * @param _tokenId Token id to be claimed
    * @param _expiration Unix timestamp of link expiration time
    * @param _linkId Address corresponding to link key
    * @param _linkdropMaster Address corresponding to linkdrop master key
    * @param _campaignId Campaign id
    * @param _linkdropSignerSignature ECDSA signature of linkdrop signer
    * @param _receiver Address of linkdrop receiver
    * @param _receiverSignature ECDSA signature of linkdrop receiver
    * @return True if success
    */
    function claimERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        address payable _linkdropMaster,
        uint _campaignId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external
    returns (bool)
    {
        // Make sure proxy contract is deployed
        require(isDeployed(_linkdropMaster, _campaignId), "LINKDROP_PROXY_CONTRACT_NOT_DEPLOYED");

        // Make sure only whitelisted relayer calls this function
        require(isRelayer[msg.sender], "ONLY_RELAYER");

        uint fee = fees[deployed[salt(_linkdropMaster, _campaignId)]];

        // Call claim function in the context of proxy contract
        ILinkdropERC721(deployed[salt(_linkdropMaster, _campaignId)]).claimERC721
        (
            _weiAmount,
            _nftAddress,
            _tokenId,
            _expiration,
            _linkId,
            _linkdropSignerSignature,
            _receiver,
            _receiverSignature,
            msg.sender, // Fee receiver
            fee
        );

        return true;
    }

}


contract LinkdropFactory is LinkdropFactoryERC20, LinkdropFactoryERC721 {

    /**
    * @dev Constructor that sets bootstap initcode, factory owner, chainId and master copy
    * @param _masterCopy Linkdrop mastercopy contract address to calculate bytecode from
    * @param _chainId Chain id
    */
    constructor(address payable _masterCopy, uint _chainId) public {
        _initcode = (hex"6352c7420d6000526103ff60206004601c335afa6040516060f3");
        chainId = _chainId;
        setMasterCopy(_masterCopy);
    }

}