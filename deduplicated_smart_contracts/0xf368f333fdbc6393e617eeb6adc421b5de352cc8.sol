/**
 *Submitted for verification at Etherscan.io on 2021-09-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGenArt {
    function getTokensByOwner(address owner)
        external
        view
        returns (uint256[] memory);

    function ownerOf(uint256 tokenId) external view returns (address);

    function isGoldToken(uint256 _tokenId) external view returns (bool);
}

interface IGenArtCollection {
    function mintGen(
        address _to,
        uint256 _groupId,
        uint256 _membershipId
    ) external;

    function mint(
        address _to,
        uint256 _groupId,
        uint256 _membershipId
    ) external;

    function mintMany(
        address _to,
        uint256 _groupId,
        uint256 _membershipId,
        uint256 _amount
    ) external;

    function mintManyGen(
        address _to,
        uint256 _groupId,
        uint256 _membershipId,
        uint256 _amount
    ) external;

    function getAllowedMintForMembership(uint256 _group, uint256 _membershipId)
        external
        view
        returns (uint256);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * Interface to the GEN.ART Membership and Governance Token Contracts
 */

contract GenArtInterfaceV2 is Ownable {
    IGenArt private _genArtMembership;
    IERC20 private _genArtToken;
    bool private _genAllowed = false;

    constructor(address genArtMembershipAddress_) {
        _genArtMembership = IGenArt(genArtMembershipAddress_);
    }

    function getMaxMintForMembership(uint256 _membershipId)
        public
        view
        returns (uint256)
    {
        _genArtMembership.ownerOf(_membershipId);
        bool isGold = _genArtMembership.isGoldToken(_membershipId);
        return (isGold ? 5 : 1);
    }

    function getMaxMintForOwner(address owner) public view returns (uint256) {
        uint256[] memory tokenIds = _genArtMembership.getTokensByOwner(owner);
        uint256 maxMint = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            maxMint += getMaxMintForMembership(tokenIds[i]);
        }

        return maxMint;
    }

    function upgradeGenArtTokenContract(address _genArtTokenAddress)
        public
        onlyOwner
    {
        _genArtToken = IERC20(_genArtTokenAddress);
    }

    function setAllowGen(bool allow) public onlyOwner {
        _genAllowed = allow;
    }

    function isGoldToken(uint256 _membershipId) public view returns (bool) {
        return _genArtMembership.isGoldToken(_membershipId);
    }

    function genAllowed() public view returns (bool) {
        return _genAllowed;
    }

    function ownerOf(uint256 _membershipId) public view returns (address) {
        return _genArtMembership.ownerOf(_membershipId);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _genArtToken.balanceOf(_owner);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public {
        _genArtToken.transferFrom(_from, _to, _amount);
    }

    function getRandomChoice(uint256[] memory choices, uint256 seed)
        public
        view
        returns (uint256)
    {
        require(
            choices.length > 0,
            "GenArtInterfaceV2: choices must have at least 1 value"
        );
        if (choices.length == 1) return choices[0];
        uint256 i = ((
            uint256(
                keccak256(abi.encodePacked(block.timestamp, seed, msg.sender))
            )
        ) % choices.length) + 1;

        return choices[i - 1];
    }
}